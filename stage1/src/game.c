/* Fast launch: start a game straight from stage1, doing what the kernel's
 * launch does (MenuDispatchAB_launchFarcalls 00:1569, RomLoaderMain
 * 01:5e14, BackupOpenSaverPath 01:5163, LaunchSetup 01:58b0; see
 * docs/fpga-stage1.md "Fast launch"). Anything it can't do exactly the
 * kernel's way returns, and the caller boots the kernel instead.
 *
 * Saves live in battery-backed pSRAM while a game runs; the kernel copies
 * them back to /SAVER on its next boot when page $11 holds the $AA stamp.
 * So: a stamp for another game means its save isn't on the SD card yet, and
 * only the kernel may launch over it. A stamp for this game means pSRAM
 * already has the newest save: launch without copying the old .sav in. */
#include <string.h>
#include "hw.h"
#include "fpga.h"
#include "fat.h"
#include "game.h"
#include "rtc.h"

#define SRAM PSRAM
#define STAMP_PAGE PSRAM_META
#define GAME_HANDOFF ((uint8_t *)0xD000)

extern const uint8_t game_handoff_start[], game_handoff_end[];

static uint32_t cmd[128];
static char save_path[8 + 255 + 2];

/* $0147 -> $7F37 MBC code: 0 none, 1 MBC1, 2 MBC2, 3 MBC3, 4 MBC5, 6 other */
static uint8_t mbc_code(uint8_t t)
{
    if (t == 0x00 || t == 0x08 || t == 0x09)
        return 0;
    if ((t >= 0x01 && t <= 0x03) || t == 0xEA || t == 0xFF)
        return 1;
    if (t == 0x05 || t == 0x06)
        return 2;
    if ((t >= 0x0F && t <= 0x13) || t == 0xFC)
        return 3;
    if (t >= 0x19 && t <= 0x1E)
        return 4;
    return 6;
}

static uint8_t has_battery(uint8_t t)
{
    static const uint8_t list[] = {0x03, 0x06, 0x09, 0x0D, 0x0F, 0x10, 0x13,
                                   0x17, 0x1B, 0x1E, 0x22, 0xFD, 0xFF};
    uint8_t i;

    for (i = 0; i < sizeof list; i++)
        if (list[i] == t)
            return 1;
    return 0;
}

/* $0148 -> ROM bank mask, raised to cover the file when the header is small */
static uint16_t rom_mask(uint8_t code, uint16_t banks)
{
    uint16_t mask = 0, m;

    if (code >= 1 && code <= 8)
        mask = (2 << code) - 1;
    else if (code == 0x52)
        mask = 0x47;
    else if (code == 0x53)
        mask = 0x4F;
    else if (code == 0x54)
        mask = 0x5F;
    if (banks && mask < banks - 1) {
        for (m = 1; m <= banks && m < 0x200; m <<= 1)
            ;
        mask = m - 1;
        if (mask > 0x1FF)
            mask = 0x1FF;
    }
    return mask;
}

/* $0149 -> pSRAM bank mask ($7FC4) */
static uint8_t ram_mask(uint8_t code, uint8_t mbc)
{
    if (mbc == 2 || code <= 2)
        return 0x00;
    if (code == 4)
        return 0x0F;
    if (code == 5)
        return 0x07;
    return 0x03;
}

/* $0149 -> save size when there is no .sav yet */
static uint32_t save_size(uint8_t code, uint8_t mbc)
{
    if (code == 0)
        return mbc == 2 ? 0x2000 : 0;
    if (code <= 2)
        return 0x2000;
    if (code == 4)
        return 0x20000;
    if (code == 5)
        return 0x10000;
    return 0x8000;
}

/* "/SAVER/" + the ROM's name with .gb/.gbc -> .sav; 0 for other names */
static uint8_t make_save_path(const char *rom)
{
    uint8_t n = strlen(rom), cut;

    if (n >= 4 && (rom[n - 1] | 32) == 'c' && rom[n - 4] == '.' &&
        (rom[n - 3] | 32) == 'g' && (rom[n - 2] | 32) == 'b')
        cut = 3;
    else if (n >= 3 && rom[n - 3] == '.' && (rom[n - 2] | 32) == 'g' && (rom[n - 1] | 32) == 'b')
        cut = 2;
    else
        return 0;
    memcpy(save_path, "/SAVER/", 7);
    memcpy(save_path + 7, rom, n - cut);
    memcpy(save_path + 7 + n - cut, "sav", 4);
    return 1;
}

/* little-endian u32 from a buffer */
static int32_t get32(const uint8_t *p)
{
    return (int32_t)((uint32_t)p[0] | (uint32_t)p[1] << 8 | (uint32_t)p[2] << 16 | (uint32_t)p[3] << 24);
}

/* .sav (or $FF when there is none) -> pSRAM, the game clock for a timer
 * cart, then the stamp: BackupOpenSaverPath 01:53c5 and PreLaunchSaveStamp
 * 01:5824. The clock: a 48-byte footer is advanced by the time since its
 * launch stamp (rtc.c); no footer or no .sav zeroes it. */
static uint8_t load_save(uint8_t *buf, uint8_t code, uint8_t mbc, uint8_t timer)
{
    uint32_t size, off;
    uint16_t n;
    uint8_t len = strlen(save_path), footer = 0, i;
    uint8_t clock[RTC_FIELDS];
    int32_t stamp = 0, now;

    if (fat_open(save_path) == FAT_OK) {
        size = file_size;
        if ((size & 0x30) == 0x30) {    /* RTC footer after the save data */
            footer = 1;
            size &= ~0xFFUL;
        }
        for (off = 0; off < size; off += 512) {
            fpga_set(FPGA_SRAM_MAP, 0);
            if (!fat_read(off >> 9, buf))
                return 0;
            psram_map((uint8_t)(off >> 13));
            n = size - off < 512 ? (uint16_t)(size - off) : 512;
            memcpy((void *)(SRAM + ((uint16_t)off & 0x1FFF)), buf, n);
        }
        if (footer && timer) {
            /* size is a multiple of 256, so the footer sits in one sector */
            fpga_set(FPGA_SRAM_MAP, 0);
            if (!fat_read(size >> 9, buf))
                return 0;
            off = size & 0x1FF;
            for (i = 0; i < RTC_FIELDS; i++)
                clock[i] = buf[(uint16_t)off + 4 * i];
            stamp = get32(buf + (uint16_t)off + 40);
        }
    } else {
        size = save_size(code, mbc);
        for (off = 0; off < size; off += 0x2000) {
            psram_map((uint8_t)(off >> 13));
            memset((void *)SRAM, 0xFF, 0x2000);
        }
    }
    psram_map(STAMP_PAGE);
    SRAM[0x000] = 0xAA;
    SRAM[0x001] = (uint8_t)(size >> 13);
    SRAM[0x00F] = len;
    memcpy((void *)(SRAM + 0x010), save_path, len);
    SRAM[0x202] = 0x00;
    psram_unmap();
    if (timer) {
        now = rtc_now();
        rtc_advance(clock, footer ? stamp : 0, now);    /* stamp 0: zero */
        rtc_apply(clock, now);
    }
    return 1;
}

/* pSRAM already holds this game's save: move the kernel's copy of the clock
 * on from its stamp, as the kernel's dump and next launch would. 0 when
 * the last launch left no clock record, so the kernel does it instead. */
static uint8_t resume_clock(void)
{
    uint8_t clock[RTC_FIELDS], i, ok;
    int32_t stamp, now;

    psram_map(STAMP_PAGE);
    ok = SRAM[0x202] == 0x77;
    for (i = 0; i < RTC_FIELDS; i++)
        clock[i] = SRAM[0x220 + i];
    stamp = get32((const uint8_t *)(SRAM + 0x210));
    psram_unmap();
    if (!ok)
        return 0;
    now = rtc_now();
    rtc_advance(clock, stamp, now);
    rtc_apply(clock, now);
    return 1;
}

void game_launch(const char *path, uint8_t *buf)
{
    uint8_t type, code_rom, code_ram, mbc, battery, timer, chk, i;
    uint8_t stamped, same, len;
    uint16_t banks, mask;
    uint32_t acc;

    if (!make_save_path(fat_name()))
        return;                         /* not a .gb/.gbc */
    banks = (uint16_t)(file_size >> 14);

    fat_read_first(buf);
    type = buf[0x147];
    code_rom = buf[0x148];
    code_ram = buf[0x149];
    for (chk = 0, i = 0x34; i <= 0x4C; i++)
        chk = chk - buf[0x100 + i] - 1;
    mbc = mbc_code(type);
    battery = has_battery(type);
    timer = type == 0x0F || type == 0x10;
    if (mbc == 1 && banks > 0x20 && fat_read(0x40000 >> 9, buf)) {
        for (acc = 0, i = 0x04; i < 0x34; i++)
            acc = acc << 1 ^ buf[0x100 + i];
        if (acc == 0xE06C8834)
            mbc = 5;                    /* MBC1M multicart */
    }

    /* the stamp decides whether this launch is safe */
    psram_map(STAMP_PAGE);
    stamped = SRAM[0x000] == 0xAA;
    len = SRAM[0x00F];
    same = stamped && len == strlen(save_path) &&
           !memcmp((const void *)(SRAM + 0x010), save_path, len);
    psram_unmap();
    if (stamped && !(battery && same))
        return;                         /* another game's save isn't backed up */

    /* LASTROM record, the START overlay's relaunch target */
    psram_map(STAMP_PAGE);
    memcpy((void *)(SRAM + 0x300), path, strlen(path) + 1);
    psram_unmap();

    if (battery && !same && !load_save(buf, code_ram, mbc, timer))
        return;
    if (timer && same && !resume_clock())
        return;                         /* no clock record: kernel only */

    if (fat_open(path) || fat_load_command(cmd))
        return;
    mask = rom_mask(code_rom, banks);
    fpga_set(FPGA_SRAM_MAP, 2);
    fpga_set(0x7F37, mbc | (timer ? 0x80 : 0));
    fpga_set(0x7FD4, 0x11);             /* FW5: $7FD3 (0) + $7FD4 = $11 skips the
                                           loader's pause after each SD read */
    fpga_set(0x7FC4, ram_mask(code_ram, mbc));
    fpga_set(0x7FC1, (uint8_t)mask);
    fpga_set(0x7FC2, (uint8_t)(mask >> 8));
    fpga_set(0x7FC3, chk);

    if (rLCDC & 0x80) {
        while (rLY != 144)
            ;
    }
    rLCDC = 0;
    fpga_set(FPGA_LOAD_MAP, 1);
    memcpy((void *)WINDOW, cmd, 512);
    memcpy(GAME_HANDOFF, game_handoff_start, game_handoff_end - game_handoff_start);
    ((void (*)(void))GAME_HANDOFF)();
}
