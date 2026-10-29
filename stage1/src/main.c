/* stage1: show the boot screen, find the kernel (EZGB.DAT) on the SD card,
 * have the FPGA load it, enter it at $0100. Same steps as the stock
 * bootstrap (docs/fpga-stage1.md), written from scratch. With fast launch
 * set in EZGB.CFG it launches that game instead (game.c), unless START is
 * held, and boots the kernel whenever that isn't possible. Before a fast
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

static const char *const errors[] = {
    0,
    "SD CARD ERROR",
    "FAT12 NOT SUPPORTED",
    "EZGB.DAT NOT FOUND",           /* no *.dat in the root at all */
    "KERNEL DAMAGED",
    "KERNEL FRAGMENTED",
    "GPT CARD: USE MBR",            /* reformat with an MBR partition table */
};

/* Tell the kernel whether the user canceled fast launch (PSRAM_SKIP_FL):
 * set when START is held, cleared otherwise, so a kernel without support
 * never sees a stale mark. */
void sd_wait_notice(uint8_t waiting)
{
    if (waiting)
        print_center(DETAIL_ROW, "INSERT SD CARD");
    else
        clear_row(DETAIL_ROW);
}

static void mark_skip(uint8_t skip)
{
    psram_map(PSRAM_META);
    PSRAM[PSRAM_SKIP_FL] = skip ? 'S' : 0;
    PSRAM[PSRAM_SKIP_FL + 1] = skip ? '1' : 0;
    psram_unmap();
}

/* Tell the kernel this stage1 handles the SGB (PSRAM_SGB_SENT): "SB" when
 * it sent the header packets, "SN" when there was no SGB to send them to */
static void mark_sgb(uint8_t sent)
{
    psram_map(PSRAM_META);
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
    uint8_t err, keys, sgb, fl, fw, tried = 0;

    rNR52 = 0;                          /* sound off, as stock */
    video_init();
    sgb = sgb_detect();
    if (sgb)
        sgb_unlock();                   /* about 6.7 s, on an SGB only */
    mark_sgb(sgb);
    keys = buttons();                   /* as held at power-on */
    wait_frames(JR_DELAY);
    wordmark_paint(JR_STEP);
    wait_frames(PAUSE_FRAMES - JR_DELAY - 4 * JR_STEP);
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
        fpga_set(FPGA_SRAM_MAP, 0);
        err = fat_mount();
        if (!err && !tried) {
            tried = 1;
            mark_skip(keys & BTN_START);
            /* A fast-launch boot never reaches the kernel's BACKUPSAVE, so
             * stage1 offers the pending save itself; SELECT asks on any boot */
            fl = !(keys & BTN_START) && fast_launch_target();
            if ((fl || keys & BTN_SELECT) &&
                backup_offer(text, keys & BTN_SELECT, fl ? game_save_path() : 0))
                fl = 0;                 /* the kernel backs up instead */
            print_center(STATUS_ROW, loading);
            if (fl && fat_open(launch_path) == FAT_OK) {
                print_center(DETAIL_ROW, fat_name());
                game_launch(launch_path, text);  /* returns only if it can't */
            }
        }
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
