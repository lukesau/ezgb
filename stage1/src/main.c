/* stage1: show the boot screen, find EZGB.DAT on the SD card, have the
 * FPGA load it, enter it at $0100. Same steps as the stock bootstrap
 * (docs/fpga-stage1.md), written from scratch. */
#include <string.h>
#include "hw.h"
#include "fpga.h"
#include "fat.h"
#include "video.h"

/* the wordmark takes tile rows 9-12 (video.c); text stays clear below it */
#define STATUS_ROW 15
#define DETAIL_ROW 16
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

static const char *const errors[] = {
    0,
    "SD CARD ERROR",
    "FAT12 NOT SUPPORTED",
    "EZGB.DAT NOT FOUND",
    "EZGB.DAT DAMAGED",
    "EZGB.DAT FRAGMENTED",
};

static uint8_t prepare(void)
{
    uint8_t err;

    fpga_set(FPGA_SRAM_MAP, 0);
    err = fat_mount();
    if (!err)
        err = fat_find("EZGB    DAT");
    if (!err)
        err = fat_load_command(load_cmd);
    return err;
}

void main(void)
{
    uint8_t err;

    rNR52 = 0;                          /* sound off, as stock */
    video_init();
    wait_frames(JR_DELAY);
    wordmark_paint(JR_STEP);
    wait_frames(PAUSE_FRAMES - JR_DELAY - 4 * JR_STEP);
    print_center(STATUS_ROW, "LOADING...");

    /* keep retrying: the card may still be starting up, or be swapped */
    while ((err = prepare())) {
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
