/* stage1: show the boot screen, find EZGB.DAT on the SD card, have the
 * FPGA load it, enter it at $0100. Same steps as the stock bootstrap
 * (docs/fpga-stage1.md), written from scratch. With fast launch set in
 * EZGB.CFG it launches that game instead (game.c), unless START is held,
 * and boots the kernel whenever that isn't possible. SELECT at power-on
 * offers to back up the pending save first (backup.c). */
#include <string.h>
#include "hw.h"
#include "fpga.h"
#include "fat.h"
#include "cfg.h"
#include "game.h"
#include "backup.h"
#include "video.h"

/* the wordmark takes tile rows 9-12 (video.c); text stays clear below it */
#define STATUS_ROW 15
#define DETAIL_ROW 16
#define VERSION_ROW 17
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

static const char *const errors[] = {
    0,
    "SD CARD ERROR",
    "FAT12 NOT SUPPORTED",
    "EZGB.DAT NOT FOUND",
    "EZGB.DAT DAMAGED",
    "EZGB.DAT FRAGMENTED",
};

/* Tell the kernel whether the user cancelled fast launch (PSRAM_SKIP_FL):
 * set when START is held, cleared otherwise, so a kernel without support
 * never sees a stale mark. */
static void mark_skip(uint8_t skip)
{
    psram_map(PSRAM_META);
    PSRAM[PSRAM_SKIP_FL] = skip ? 'S' : 0;
    PSRAM[PSRAM_SKIP_FL + 1] = skip ? '1' : 0;
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

static uint8_t kernel(void)
{
    uint8_t err = fat_open("/EZGB.DAT");

    return err ? err : fat_load_command(load_cmd);
}

void main(void)
{
    uint8_t err, keys, tried = 0;

    rNR52 = 0;                          /* sound off, as stock */
    video_init();
    keys = buttons();                   /* as held at power-on */
    wait_frames(JR_DELAY);
    wordmark_paint(JR_STEP);
    wait_frames(PAUSE_FRAMES - JR_DELAY - 4 * JR_STEP);
    print_center(STATUS_ROW, "LOADING...");
    print_center(VERSION_ROW, FW_TEXT);

    /* keep retrying: the card may still be starting up, or be swapped */
    for (;;) {
        fpga_set(FPGA_SRAM_MAP, 0);
        err = fat_mount();
        if (!err && !tried) {
            tried = 1;
            mark_skip(keys & BTN_START);
            if (keys & BTN_SELECT && backup_offer(text))
                keys |= BTN_START;      /* the kernel backs up instead */
            if (!(keys & BTN_START) && fast_launch_target()) {
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

    fpga_set(FPGA_SRAM_MAP, 2);
    fpga_set(FPGA_LOAD_MAP, 1);
    memcpy((void *)WINDOW, load_cmd, 512);
    memcpy(HANDOFF, handoff_start, handoff_end - handoff_start);
    ((void (*)(void))HANDOFF)();
}
