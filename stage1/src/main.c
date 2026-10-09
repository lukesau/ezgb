/* stage1: show the boot screen, find EZGB.DAT on the SD card, have the
 * FPGA load it, enter it at $0100. Same steps as the stock bootstrap
 * (docs/fpga-stage1.md), written from scratch. */
#include <string.h>
#include "hw.h"
#include "fpga.h"
#include "fat.h"
#include "video.h"

#define TITLE_ROW  9
#define STATUS_ROW 12
#define HANDOFF ((uint8_t *)0xD000)
#ifndef PAUSE_FRAMES
#define PAUSE_FRAMES 42                 /* ~700 ms, the stock pause */
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
    print_center(TITLE_ROW, "EZ-FLASH");
    wait_frames(PAUSE_FRAMES);
    print_center(STATUS_ROW, "LOADING...");

    /* keep retrying: the card may still be starting up, or be swapped */
    while ((err = prepare())) {
        print_center(STATUS_ROW, errors[err]);
        wait_frames(60);
    }

    fpga_set(FPGA_SRAM_MAP, 2);
    fpga_set(FPGA_LOAD_MAP, 1);
    memcpy((void *)WINDOW, load_cmd, 512);
    memcpy(HANDOFF, handoff_start, handoff_end - handoff_start);
    ((void (*)(void))HANDOFF)();
}
