/* Save backup from stage1, the kernel's BackupSaveDump (01:643a) done in
 * place: pSRAM pages 0.. are written over the existing /SAVER file along
 * its own clusters. The file must already exist at exactly the stamp's
 * size, so no FAT or directory entry changes; anything else (no file yet,
 * a different size, a clock footer) is left to the kernel, which creates
 * and truncates files. */
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

uint8_t backup_offer(uint8_t *buf)
{
    uint8_t len, pages, timer, keys;
    uint32_t size, off;
    const char *base;

    psram_map(PSRAM_META);
    len = PSRAM[0x00F];
    pages = PSRAM[0x001];
    timer = PSRAM[0x202] == 0x77;
    if (PSRAM[0x000] != 0xAA || !len || len > 250) {
        psram_unmap();
        say("NO SAVE TO BACK UP", "");
        wait_frames(60);
        say("", "");
        return 0;
    }
    memcpy(path, (const void *)(PSRAM + 0x010), len);
    path[len] = 0;
    psram_unmap();
    size = (uint32_t)pages << 13;

    base = strrchr(path, '/');
    print_center(NAME_ROW, base ? base + 1 : path);
    say("BACK UP SAVE?", "A:YES   B:NO");
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

    if (memcmp(path, "/SAVER/", 7) || timer || !size ||
        fat_open(path) || file_size != size) {
        say("BACKING UP IN", "THE KERNEL");
        wait_frames(60);
        return 1;
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
    psram_map(PSRAM_META);
    PSRAM[0x000] = 0;                   /* backed up: no stamp */
    psram_unmap();
    say("SAVE BACKED UP", "");
    wait_frames(60);
    say("", "");
    clear_row(NAME_ROW);
    return 0;
}
