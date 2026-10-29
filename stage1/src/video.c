/* Boot screen: the EZ Flash icon, a line of title text, a status line.
 * Tiles $20-$5A are the font (tile number = ASCII), tiles $80+ the icon,
 * then the EZ-FLASH Jr. wordmark (scripts/fpga/mkwordmark.py), map $9800
 * with unsigned tile data at $8000. On a color console the text uses BG
 * palette 0 (grays), the icon palette 1 and the wordmark palette 2. The
 * colors are the kernel's UI theme (docs/dark-mode.md), from the mark and
 * colors it leaves in pSRAM. */
#include <string.h>
#include "hw.h"
#include "fpga.h"
#include "video.h"

#define ICON_W 6
#define ICON_H 7
#define ICON_X 7
#define ICON_Y 1
#define ICON_TILE 0x80
/* the letters are centered on the screen (canvas x 10 + tile 2 = pixel 26,
 * 108 wide); the Jr. hangs off to the right as on the cart label */
#define MARK_W 16
#define MARK_H 4
#define MARK_X 2
#define MARK_Y 9
#define MARK_TILE (ICON_TILE + ICON_W * ICON_H)

extern const uint8_t font8[];
extern const uint8_t icon_tiles[];                        /* packed */
extern const uint8_t wordmark_tiles[];                    /* packed */
extern const uint8_t wordmark_stages;
extern const uint8_t wordmark_maps[2][MARK_W * MARK_H];   /* letters alone, whole mark */
extern const uint8_t wordmark_cuts[];                      /* paint step tile columns */

/* BGR555: palette 0 = the shades for text, palette 1 = the icon:
 * background, orange screen, frames, lip (stage1-splash.asm), palette 2 =
 * the wordmark: background, brush orange, dark orange, letters */
static const uint16_t palettes[12] = {
    0x7FFF, 0x56B5, 0x294A, 0x0000,
    0x7FFF, 0x129E, 0x294A, 0x14A5,
    0x7FFF, 0x15F9, 0x0932, 0x0000,
};

/* The boot screen palettes in the kernel's UI theme (docs/dark-mode.md),
 * into pal; returns the theme. The kernel leaves its mark, 'T', 'H', theme,
 * ~theme, then the theme's four colors, so this needs no table of its own.
 * A dark theme takes the background and ink of every palette, the text's
 * two middle shades and the icon's frames from those colors; the orange
 * stays. Missing or faded mark: theme 0, the palettes above. */
static uint8_t theme(uint8_t *pal)
{
    volatile uint8_t *m = PSRAM + PSRAM_THEME;
    uint8_t i, k, t;

    memcpy(pal, palettes, sizeof palettes);
    psram_map(PSRAM_META);
    t = m[2];
    if (m[0] != 'T' || m[1] != 'H' || m[3] != (uint8_t)~t)
        t = 0;
    if (t)
        for (i = 0; i < sizeof palettes; i++) {
            k = i & 7;          /* byte k of color k / 2 */
            if (k < 2 || k > 5 || i < 8 || i == 12 || i == 13)
                pal[i] = m[4 + k];
        }
    psram_unmap();
    return t;
}

static uint8_t cgb;

static void vram_fill(uint16_t dst, uint8_t value, uint16_t n)
{
    memset((void *)dst, value, n);
}

/* Tile data packed by scripts/fpga/packbits.py: a control byte c, then c
 * literal bytes (c < $80) or the next byte c - $7D times; 0 ends. LCD off. */
static void unpack(uint8_t *dst, const uint8_t *src)
{
    uint8_t c, v;

    while ((c = *src++)) {
        if (c & 0x80) {
            v = *src++;
            for (c -= 0x7D; c; c--)
                *dst++ = v;
        } else {
            for (; c; c--)
                *dst++ = *src++;
        }
    }
}

static void icon_map(uint8_t first)
{
    uint8_t *p = (uint8_t *)(0x9800 + ICON_Y * 32 + ICON_X);
    uint8_t x, y;

    for (y = 0; y < ICON_H; y++, p += 32)
        for (x = 0; x < ICON_W; x++)
            p[x] = first ? first++ : 1;
}

/* LCD off: the letters alone (map 0), or with attrs set the CGB
 * attributes (palette 2) for the whole block */
static void wordmark_map_draw(uint8_t attrs)
{
    uint8_t *p = (uint8_t *)(0x9800 + MARK_Y * 32 + MARK_X);
    const uint8_t *m = wordmark_maps[0];
    uint8_t x, y;

    for (y = 0; y < MARK_H; y++, p += 32)
        for (x = 0; x < MARK_W; x++, m++)
            p[x] = attrs ? 2 : MARK_TILE + *m;
}

void video_init(void)
{
    const uint8_t *src = font8;
    uint8_t *dst = (uint8_t *)(0x8000 + 0x20 * 16);
    uint8_t pal[sizeof palettes];
    uint8_t i, t = theme(pal);
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
    rBGP = t ? 0x1B : 0xE4;             /* every dark theme: inverted */

    vram_fill(0x8000, 0, 0x2000);
    for (n = 0; n < (0x5B - 0x20) * 8; n++) {   /* 1 bpp -> color 3 */
        *dst++ = *src;
        *dst++ = *src++;
    }
    unpack((uint8_t *)(0x8000 + ICON_TILE * 16), icon_tiles);
    icon_map(ICON_TILE);
    unpack((uint8_t *)(0x8000 + MARK_TILE * 16), wordmark_tiles);
    wordmark_map_draw(0);

    rVBK = 0;
    cgb = !(rVBK & 1);
    if (cgb) {
        rVBK = 1;
        vram_fill(0x9800, 0, 0x800);
        icon_map(0);
        wordmark_map_draw(1);
        rVBK = 0;
        rBCPS = 0x80;
        for (i = 0; i < sizeof pal; i++)
            rBCPD = pal[i];
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

/* LCD on: the Jr. painted on over the letters, a run of tile columns of the
 * whole mark per step (mkwordmark.py --stages) */
void wordmark_paint(uint8_t frames_per_step)
{
    uint8_t step, x, y;

    for (step = 0; step < wordmark_stages; step++) {
        for (x = wordmark_cuts[step]; x < wordmark_cuts[step + 1]; x++)
            for (y = 0; y < MARK_H; y++)
                put((uint8_t *)(0x9800 + (MARK_Y + y) * 32 + MARK_X + x),
                    MARK_TILE + wordmark_maps[1][y * MARK_W + x]);
        wait_frames(frames_per_step);
    }
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
