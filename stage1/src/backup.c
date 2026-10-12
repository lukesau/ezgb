/* Save backup from stage1, the kernel's BackupSaveDump (01:643a) done in
 * place: pSRAM pages 0.. are written over the existing /SAVER file along
 * its own clusters, then for a clock game ($A202 = $77) the 48-byte footer
 * the kernel appends: the clock at $A220-$A224 twice (registers, latched
 * copies) and the launch stamp $A210-$A213 at +40. The file must already
 * exist at exactly that size, so no FAT or directory entry changes;
 * anything else (no file yet, a different size) is left to the kernel,
 * which creates and truncates files. */
#include <string.h>
#include "hw.h"
#include "fpga.h"
#include "fat.h"
#include "video.h"
#include "backup.h"

#define NAME_ROW   14
#define ASK_ROW    15
#define KEYS_ROW   16

static char path[256];

static void say(const char *a, const char *b)
{
    print_center(ASK_ROW, a);
    print_center(KEYS_ROW, b);
}

static void wait_release(void)
{
    while (buttons())
        ;
}

uint8_t backup_offer(uint8_t *buf, uint8_t manual)
{
    uint8_t len, pages, timer, autosave, keys, i;
    uint8_t footer[9];
    uint32_t size, off;
    const char *base;

    psram_map(PSRAM_META);
    if (PSRAM[PSRAM_CANARY] != PSRAM_CANARY_OK) {
        /* BATTERY DRY: never write this save, not even with AUTO SAVE, and
         * don't fast launch it either; the kernel shows BATTERY DRY and drops
         * the stamp, and its own fast launch loads the .sav from the card */
        psram_unmap();
        if (manual) {
            say("BATTERY DRY", "NOT BACKED UP");
            wait_frames(90);
            say("", "");
        }
        return 1;
    }
    len = PSRAM[0x00F];
    pages = PSRAM[0x001];
    timer = PSRAM[0x202] == 0x77;
    autosave = PSRAM[0x200] == 1;
    if (PSRAM[0x000] != 0xAA || !len || len > 250) {
        psram_unmap();
        if (manual) {
            say("NO SAVE TO BACK UP", "");
            wait_frames(60);
            say("", "");
        }
        return 0;
    }
    memcpy(path, (const void *)(PSRAM + 0x010), len);
    path[len] = 0;
    for (i = 0; i < 5; i++)
        footer[i] = PSRAM[0x220 + i];
    for (i = 0; i < 4; i++)
        footer[5 + i] = PSRAM[0x210 + i];
    psram_unmap();
    size = (uint32_t)pages << 13;

    /* only what can be written in place; the kernel prompts for the rest */
    if (memcmp(path, "/SAVER/", 7) || !size || fat_open(path) ||
        file_size != size + (timer ? 48 : 0)) {
        if (manual) {
            say("BACKING UP IN", "THE KERNEL");
            wait_frames(60);
        }
        return 1;
    }

    base = strrchr(path, '/');
    print_center(NAME_ROW, base ? base + 1 : path);
    if (!autosave) {                    /* AUTO SAVE on the SET tab: no question */
        say("BACK UP SAVE?", "B:NO   A:YES");    /* B left, A right, as the buttons sit */
        wait_release();
        do
            keys = buttons();
        while (!(keys & (BTN_A | BTN_B)));
        wait_release();
        if (keys & BTN_B) {
            say("", "");
            clear_row(NAME_ROW);
            return 0;
        }
    }
    say("SAVING...", "");
    for (off = 0; off < size; off += 512) {
        psram_map((uint8_t)(off >> 13));
        memcpy(buf, (const void *)(PSRAM + ((uint16_t)off & 0x1FFF)), 512);
        psram_unmap();
        if (!fat_write(off >> 9, buf)) {
            say("SAVE ERROR", "");
            wait_frames(120);
            return 1;
        }
    }
    if (timer) {
        memset(buf, 0, 512);
        for (i = 0; i < 5; i++)
            buf[i * 4] = buf[20 + i * 4] = footer[i];
        memcpy(buf + 40, footer + 5, 4);
        if (!fat_write(size >> 9, buf)) {
            say("SAVE ERROR", "");
            wait_frames(120);
            return 1;
        }
    }
    psram_map(PSRAM_META);
    PSRAM[0x000] = 0;                   /* backed up: no stamp */
    psram_unmap();
    say("SAVE BACKED UP", "");
    wait_frames(60);
    say("", "");
    clear_row(NAME_ROW);
    return 0;
}
