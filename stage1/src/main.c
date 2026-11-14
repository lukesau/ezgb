/* stage1: show the boot screen, find the kernel (EZGB.DAT) on the SD card,
 * have the FPGA load it, enter it at $0100. Same steps as the stock
 * bootstrap (docs/fpga-stage1.md), written from scratch. With fast launch
 * set in EZGB.CFG it launches that game instead (game.c), unless START is
 * held or pressed while the boot screen is up, and boots the kernel
 * whenever that isn't possible. Before a fast
 * launch it offers to back up the pending save (backup.c), as the kernel
 * does at boot; SELECT at power-on asks on a kernel boot too. With more
 * than one *.dat file in the card's root it asks which kernel to boot
 * (docs/kernel-picker.md). */
#include <string.h>
#include "hw.h"
#include "fpga.h"
#include "fat.h"
#include "cfg.h"
#include "game.h"
#include "backup.h"
#include "video.h"
#include "sgb.h"

/* the wordmark takes tile rows 9-12 (video.c); text stays clear below it */
#define HINT_ROW 14                  /* a fast launch: how to get the kernel instead */
#define STATUS_ROW 15
#define DETAIL_ROW 16
#define VERSION_ROW 17
#define PICK_ROW 13                  /* CHOOSE A KERNEL; the kernels on the rows below */
#define KERNELS_MAX 4                /* rows 14-17 */
#include "version.h"                 /* generated from stage1/VERSION */
#define HANDOFF ((uint8_t *)0xD000)
/* Boot screen timing, in frames (60 per second). The whole intro fits in
 * the stock 700 ms pause: EZ-FLASH alone, then the Jr. painted on left to
 * right, then a hold before LOADING. */
#ifndef PAUSE_FRAMES
#define PAUSE_FRAMES 42                 /* ~700 ms, the stock pause */
#endif
#ifndef JR_DELAY
#define JR_DELAY 18                     /* EZ-FLASH alone */
#endif
#ifndef JR_STEP
#define JR_STEP 2                       /* per paint step (4 steps) */
#endif

extern const uint8_t handoff_start[], handoff_end[];

static uint32_t load_cmd[128];
static uint8_t text[512];
static char launch_path[CFG_PATH_MAX + 1];
static char fw_text[sizeof FW_TEXT];    /* "FW5-MOD <m>", the version line */
static const char loading[] = "LOADING...";
static uint8_t held;                    /* every button seen down since power-on */

static const char *const errors[] = {
    0,
    "SD CARD ERROR",
    "FAT12 NOT SUPPORTED",
    "EZGB.DAT NOT FOUND",           /* no *.dat in the root at all */
    "KERNEL DAMAGED",
    "KERNEL FRAGMENTED",
    "GPT CARD: USE MBR",            /* reformat with an MBR partition table */
};

void sd_wait_notice(uint8_t waiting)
{
    if (waiting)
        print_center(DETAIL_ROW, "INSERT SD CARD");
    else
        clear_row(DETAIL_ROW);
}

/* Tell the kernel whether the user canceled fast launch (PSRAM_SKIP_FL):
 * set when START was held or pressed, cleared otherwise, so a kernel
 * without support never sees a stale mark. */
static void mark_skip(uint8_t skip)
{
    psram_map(PSRAM_META);
    PSRAM[PSRAM_SKIP_FL] = skip ? 'S' : 0;
    PSRAM[PSRAM_SKIP_FL + 1] = skip ? '1' : 0;
    psram_unmap();
}

/* Tell the kernel this stage1 handles the SGB (PSRAM_SGB_SENT): "SB" when
 * it sent the header packets, "SN" when there was no SGB to send them to.
 * The boot registers go along (PSRAM_BOOT_REGS). */
static void mark_sgb(uint8_t sent)
{
    uint8_t i;
#ifdef FORCE_DMG
    /* stage1/build.sh: a DMG's registers on any console */
    static const uint8_t dmg_regs[8] = {0xB0, 0x01, 0x13, 0x00, 0xD8, 0x00, 0x4D, 0x01};

    memcpy((void *)BOOT_REGS, dmg_regs, 8);
#endif
    psram_map(PSRAM_META);
    for (i = 0; i < 8; i++)
        PSRAM[PSRAM_BOOT_REGS + i] = BOOT_REGS[i];
    PSRAM[PSRAM_SGB_SENT] = 'S';
    PSRAM[PSRAM_SGB_SENT + 1] = sent ? 'B' : 'N';
    psram_unmap();
}

/* FLAUNCH= target from EZGB.CFG, opened; 0 when there is none */
static uint8_t fast_launch_target(void)
{
    uint16_t n;

    if (fat_open("/EZGB.CFG"))
        return 0;
    n = file_size < 512 ? (uint16_t)file_size : 512;
    fat_read_first(text);
    if (!cfg_flaunch(text, n, launch_path))
        return 0;
    return fat_open(launch_path) == FAT_OK;
}

/* The boot screen's waits, watching the buttons: START cancels a fast
 * launch at power-on and at any time until the launch is decided. */
static void wait_poll(uint8_t n)
{
    while (n--) {
        wait_frames(1);
        held |= buttons();
    }
}

/* With the card mounted: is this a fast-launch boot? Then say how to get
 * the kernel instead, while there is still time to. */
static uint8_t fast_launch_check(void)
{
    held |= buttons();
    if (held & BTN_START || !fast_launch_target())
        return 0;
    print_center(HINT_ROW, "HOLD START TO CANCEL");
    return 1;
}

/* Which of the n kernels listed in text[] to boot: their names under a
 * title, a cursor moved with UP and DOWN (wrapping), A or START to pick.
 * The cursor starts on EZGB.DAT, the name a stock stage1 boots, when it is
 * one of them. The five rows under the wordmark are the list's; LOADING...
 * and the version line come back after. */
static void clear_list(void)
{
    uint8_t i;

    for (i = PICK_ROW; i <= VERSION_ROW; i++)
        clear_row(i);
}

static uint8_t pick_kernel(uint8_t n)
{
    uint8_t i, cur = kernel_default, keys;
    const char *name = (const char *)text + 12;

    clear_list();
    print_center(PICK_ROW, "CHOOSE A KERNEL");
    for (i = 0; i < n; i++, name += KERNEL_ENTRY)
        print_at(PICK_ROW + 1 + i, 1, name);
    wait_release();
    for (;;) {
        print_at(PICK_ROW + 1 + cur, 0, ">");
        do
            keys = buttons();
        while (!keys);
        wait_release();
        if (keys & (BTN_A | BTN_START))
            break;
        print_at(PICK_ROW + 1 + cur, 0, " ");
        if (keys & BTN_UP)
            cur += n - 1;
        else if (keys & BTN_DOWN)
            cur++;
        if (cur >= n)
            cur -= n;
    }
    clear_list();
    print_center(STATUS_ROW, loading);
    print_center(VERSION_ROW, fw_text);
    return cur;
}

/* The kernel's load command: the root's one *.dat file, or the one picked
 * from up to four. A failed load comes back here, so another can be picked. */
static uint8_t kernel(void)
{
    uint8_t n = fat_scan_dat(text, KERNELS_MAX), which = 0;

    if (!n)
        return FAT_NOT_FOUND;
    if (n > 1)
        which = pick_kernel(n);
    fat_select(text, which);
    return fat_load_command(load_cmd);
}

void main(void)
{
    uint8_t err, keys, sgb, fl = 0, fw, tried = 0, early;

    rNR52 = 0;                          /* sound off, as stock */
    video_init();
    sgb = sgb_detect();
    if (sgb)
        sgb_unlock();                   /* about 6.7 s, on an SGB only */
    mark_sgb(sgb);
    keys = held = buttons();            /* as held at power-on */
    wait_poll(JR_DELAY);
    wordmark_paint(JR_STEP);
    /* The card is mounted and EZGB.CFG read during the rest of the pause
     * rather than after it, so a fast-launch boot shows its hint while
     * START can still cancel. A card that isn't up yet is left to the
     * loop below, as before. */
    fpga_set(FPGA_SRAM_MAP, 0);
    err = fat_mount();
    early = !err;
    if (early)
        fl = fast_launch_check();
    wait_poll(PAUSE_FRAMES - JR_DELAY - 4 * JR_STEP);
    print_center(STATUS_ROW, loading);
    /* FW_TEXT is "FW5-MOD <m>"; the digit is what this cart's version
     * register reads, so the FW4 updater's copy of stage1 says FW4 */
    memcpy(fw_text, FW_TEXT, sizeof FW_TEXT);
    fw = fw_version();
    if (fw >= 1 && fw <= 9)
        fw_text[2] = '0' + fw;
    print_center(VERSION_ROW, fw_text);

    /* keep retrying: the card may still be starting up, or be swapped */
    for (;;) {
        if (!early) {
            fpga_set(FPGA_SRAM_MAP, 0);
            err = fat_mount();
        }
        if (!err && !tried) {
            tried = 1;
            if (!early)
                fl = fast_launch_check();
            held |= buttons();
            if (held & BTN_START) {     /* pressed since the hint went up */
                fl = 0;
                clear_row(HINT_ROW);
            }
            mark_skip(held & BTN_START);
            /* A fast-launch boot never reaches the kernel's BACKUPSAVE, so
             * stage1 offers the pending save itself; SELECT asks on any boot */
            if ((fl || keys & BTN_SELECT) &&
                backup_offer(text, keys & BTN_SELECT, fl ? game_save_path() : 0))
                fl = 0;                 /* the kernel backs up instead */
            print_center(STATUS_ROW, loading);
            if (fl && fat_open(launch_path) == FAT_OK) {
                /* again: the backup prompt had its row. Past this point
                 * the launch is not canceled */
                print_center(HINT_ROW, "HOLD START TO CANCEL");
                print_center(DETAIL_ROW, fat_name());
                game_launch(launch_path, text);  /* returns only if it can't */
            }
            clear_row(HINT_ROW);        /* the kernel boots instead */
        }
        early = 0;
        if (!err)
            err = kernel();
        if (!err)
            break;
        print_center(DETAIL_ROW, errors[err]);
        wait_frames(60);
    }
    print_center(DETAIL_ROW, "OSINIT...");
    /* stock FW5 stage1 hands the FPGA the boot A: the kernel's $7FD4 is
     * added to it, so a stock kernel's $00 gives the $11 fast-load key on
     * CGB and GBA, as with stock firmware */
    if (fw >= 5)
        fpga_set(0x7FD3, BOOT_A);

    fpga_set(FPGA_SRAM_MAP, 2);
    fpga_set(FPGA_LOAD_MAP, 1);
    memcpy((void *)WINDOW, load_cmd, 512);
    memcpy(HANDOFF, handoff_start, handoff_end - handoff_start);
    ((void (*)(void))HANDOFF)();
}
