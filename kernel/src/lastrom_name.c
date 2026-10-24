/* START overlay name line and its marquee (docs/last-rom.md "Overlay layout").
 *
 * Bank 2, injected at 02:7260 and reached through the 8-byte far stub
 * LastRomNameStub (00:0368, `cd 8d 07 60 72 02 00 c9`). The stub is
 * `call`ed: three pad parameters. Two callers:
 *
 *   LastRomDrawBasename's `call DrawString` (00:132b) now calls the stub
 *   with the same (s, len, x, y) frame: s != 0 sets the name up (start of
 *   the name, marquee state reset) and draws it. ezcfg's "(none)" line
 *   near-calls the same entry with dummies for the pads.
 *
 *   LastRomInputLoop's `call ReadJoypad` (00:1330) now calls
 *   LastRomTickStub (00:0370), which pushes s = 0, calls the stub and
 *   leaves through `jp ReadJoypad`: s == 0 is the marquee tick.
 *
 * 8px: tile row 14, column 1, 18 characters (the caller's x, y are not
 * used). 12px: a 12px row at y 112 from x 12. DrawString12 clips at x 160, one pixel past the box's right
 * side, so the glyph count comes from Fit12 and is trimmed until the last
 * glyph starts at x <= 148 (ink is at most 8 px wide: it ends two pixels
 * short of the border). The name is drawn in paper on ink, on the solid
 * band LastRomBox laid across the box; the 12px row is painted in ink out
 * to x 159, which is the box's right side anyway.
 *
 * A name that does not fit (more than 18 characters in 8px, more glyphs
 * than the trimmed count in 12px) scrolls like the SET tab's name
 * (flcfg.c): it holds for a second, then steps one character every 20
 * frames and repeats after three blanks. The state reuses that marquee's
 * bytes (MQ_*: the SET tab resets them on entry and is never on screen with
 * the overlay) plus the name pointer and length at $DB3C.
 *
 * A second line scrolls the same way: the BACKUPSAVE prompt's "Played"
 * line (bkprompt.c), set up with LR_GEO = 2 and drawn in ink on paper on
 * the box's info row. Its state is a copy of the first line's bytes $20
 * higher ($DB58-$DB5F: position, tick, frame stamp, pointer, length and
 * LR_GEO, all but RTC_OFF), which swap() trades in around the same set-up,
 * tick and draw code. Every other set-up (LR_GEO 0 or 1) clears its length,
 * so it never outlives the prompt.
 *
 *   python3 tools/inject.py src/lastrom_name.c $V 2 7260 LastRomName \
 *       --pin DrawString12=7500 --pin Fit12=7100 --pin DrawString=08b7 \
 *       --pin DrawRect=27ba --pin StoreDrawParams=2791 --replace --apply
 */

#include "types.h"
#include "draw.h"
#include "vars.h"

#include "marquee.h"

#define LR_NAME  (*(const u8 * volatile *)0xDB3C)  /* the name being shown */
#define LR_LEN   (*(volatile u8 *)0xDB3E)   /* its length when it scrolls, else 0 */

#define LR2_LEN  (*(volatile u8 *)0xDB5E)   /* the second line's LR_LEN */

#define NAME_W   18                         /* 8px field, characters */

static void tick(void);
static void swap(void);
static u8 fit(const u8 *s);
static void draw(void);

/* The entry point stays the first function in the file: the far stub
 * jumps to the block's first byte. */
void LastRomName(u16 far_pad_thunk, u16 far_pad_af, u16 far_pad_ret, const u8 *s) {
    u8 len;

    (void)far_pad_thunk;
    (void)far_pad_af;
    (void)far_pad_ret;
    if (s) {
        /* the second line: its state in the first line's place */
        if (LR_GEO == 2) { LR_GEO = 1; swap(); LR_GEO = 2; } else LR2_LEN = 0;
        for (len = 0; len < 252 && s[len]; len++) {}   /* len + MQ_GAP stays a byte */
        LR_NAME = s;
        MQ_POS = 0;
        MQ_TICK = 0;
        MQ_FR = HFRAME;
        if (hUiMode) { if (fit(s) >= len) len = 0; }
        else if (len <= NAME_W) len = 0;
        LR_LEN = len;
        draw();
        if (LR_GEO == 2) swap();
        return;
    }
    tick();
    if (LR2_LEN) { swap(); tick(); swap(); }
}

static void tick(void) {
    u8 len, f, d;

    len = LR_LEN;
    if (len == 0) return;
    f = HFRAME;
    d = f - MQ_FR;
    MQ_FR = f;
    if (d > 100) d = 100;                 /* MQ_TICK stays below 256 */
    MQ_TICK += d;
    if (MQ_TICK >= (MQ_POS == 0 ? MQ_HOLD : MQ_RATE)) {
        MQ_TICK = 0;
        if (++MQ_POS >= (u8)(len + MQ_GAP)) MQ_POS = 0;
        draw();
    }
}

/* Trade the two lines' state: $DB38-$DB3F and $DB58-$DB5F, all but RTC_OFF. */
static void swap(void) {
    u8 *a = (u8 *)0xDB38;
    u8 i, t;

    for (i = 0; i < 8; i++, a++) {
        if (i == 2) continue;
        t = *a; *a = a[0x20]; a[0x20] = t;
    }
}

/* Glyphs of s that fit the 12px field, clear of the box's right side. */
static u8 fit(const u8 *s) {
    u8 xs[40];
    u8 n = Fit12(0, 0, s, 0, 1, xs);
    while (n > 1 && xs[n - 1] > 148) n--;
    return n;
}

static void draw(void) {
    /* tile row by LR_GEO; the 12px row is at 8x that y */
    static const u8 row8[3] = {14, 7, 9};
    u8 buf[40];
    const u8 *s = LR_NAME;
    u8 i, k, g, len = LR_LEN;

    if (len == 0) {
        for (i = 0; i < 39 && s[i]; i++) buf[i] = s[i];
        buf[i] = 0;
    } else {
        k = MQ_POS;
        for (i = 0; i < 39; i++) {
            buf[i] = k < len ? s[k] : ' ';
            if (++k >= (u8)(len + MQ_GAP)) k = 0;
        }
        buf[39] = 0;
    }
    /* the name in paper on ink (its row is LastRomBox's band), the second
     * line in ink on paper */
    g = row8[LR_GEO];
    k = LR_GEO == 2 ? 3 : 0;
    PopupDrawParams(k, k ^ 3);
    if (!hUiMode) {
        DrawString(buf, NAME_W, 1, g);
        PopupDrawParams(3, 0);
        return;
    }
    i = fit(buf);
    if (i == 0) i = 1;
    DrawString12(0, 0, 0, buf, i, 1, (u8)(g << 3));
    PopupDrawParams(3, 0);
}
