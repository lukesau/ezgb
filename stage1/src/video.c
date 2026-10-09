/* Boot screen: the EZ Flash icon, a line of title text, a status line.
 * Tiles $20-$5A are the font (tile number = ASCII), tiles $80+ the icon,
 * map $9800 with unsigned tile data at $8000. On a colour console the
 * text uses BG palette 0 (greys) and the icon palette 1. */
#include <string.h>
#include "hw.h"
#include "video.h"

#define ICON_W 6
#define ICON_H 7
#define ICON_X 7
#define ICON_Y 1
#define ICON_TILE 0x80

extern const uint8_t font8[];
extern const uint8_t icon_tiles[ICON_W * ICON_H * 16];

/* BGR555: palette 0 = the DMG shades for text, palette 1 = the icon:
 * background, orange screen, frames, lip (stage1-splash.asm) */
static const uint16_t palettes[8] = {
    0x7FFF, 0x56B5, 0x294A, 0x0000,
    0x7FFF, 0x129E, 0x294A, 0x14A5,
};

static uint8_t cgb;

static void vram_fill(uint16_t dst, uint8_t value, uint16_t n)
{
    memset((void *)dst, value, n);
}

static void icon_map(uint8_t first)
{
    uint8_t *p = (uint8_t *)(0x9800 + ICON_Y * 32 + ICON_X);
    uint8_t x, y;

    for (y = 0; y < ICON_H; y++, p += 32)
        for (x = 0; x < ICON_W; x++)
            p[x] = first ? first++ : 1;
}

void video_init(void)
{
    const uint8_t *src = font8;
    uint8_t *dst = (uint8_t *)(0x8000 + 0x20 * 16);
    uint8_t i;
    uint16_t n;

    /* the boot ROM leaves the LCD on: off at vblank */
    if (rLCDC & 0x80) {
        while (rLY != 144)
            ;
    }
    rLCDC = 0;
    rSCY = 0;
    rSCX = 0;
    rSTAT = 0;
    rWY = 0;
    rWX = 7;
    rBGP = 0xE4;

    vram_fill(0x8000, 0, 0x2000);
    for (n = 0; n < (0x5B - 0x20) * 8; n++) {   /* 1 bpp -> colour 3 */
        *dst++ = *src;
        *dst++ = *src++;
    }
    memcpy((void *)(0x8000 + ICON_TILE * 16), icon_tiles, sizeof icon_tiles);
    icon_map(ICON_TILE);

    rVBK = 0;
    cgb = !(rVBK & 1);
    if (cgb) {
        rVBK = 1;
        vram_fill(0x9800, 0, 0x800);
        icon_map(0);
        rVBK = 0;
        rBCPS = 0x80;
        src = (const uint8_t *)palettes;
        for (i = 0; i < sizeof palettes; i++)
            rBCPD = *src++;
    }
    rLCDC = 0x91;                       /* on, BG tiles $8000, map $9800 */
}

/* VRAM write with the LCD on: wait for mode 0/1 */
static void put(uint8_t *p, uint8_t c)
{
    while (rSTAT & 2)
        ;
    *p = c;
}

void clear_row(uint8_t row)
{
    uint8_t *p = (uint8_t *)(0x9800 + row * 32);
    uint8_t x;

    for (x = 0; x < 20; x++)
        put(p + x, 0);
}

void print_center(uint8_t row, const char *s)
{
    uint8_t *p = (uint8_t *)(0x9800 + row * 32 + (20 - strlen(s)) / 2);
    char c;

    clear_row(row);
    while ((c = *s++)) {
        if (c >= 'a' && c <= 'z')
            c -= 32;
        put(p++, (uint8_t)c);
    }
}

void wait_frames(uint8_t n)
{
    while (n--) {
        while (rLY == 144)
            ;
        while (rLY != 144)
            ;
    }
}
