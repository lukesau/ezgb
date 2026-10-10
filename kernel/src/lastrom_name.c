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
 *   python3 tools/inject.py src/lastrom_name.c $V 2 7260 LastRomName \
 *       --pin DrawString12=7500 --pin Fit12=7100 --pin DrawString=08b7 \
 *       --pin DrawRect=27ba --pin StoreDrawParams=2791 --pin hUiMode=fffb --replace --apply
 */

typedef unsigned char u8;
typedef unsigned int u16;

extern void DrawString12(u16 pad_thunk, u16 pad_af, u16 pad_ret, const u8 *s, u8 len, u8 col, u8 row); /* 02:7500 */
extern u8 Fit12(u16 pad_thunk, u16 pad_af, const u8 *s, u8 len, u8 col, u8 *xs);                        /* 02:7100 */
extern void DrawString(const u8 *s, u8 len, u8 x, u8 y);           /* 00:08b7 */
extern void DrawRect(u8 x0, u8 y0, u8 x1, u8 y1, u8 fill);          /* 00:27ba */
extern void StoreDrawParams(u8 color, u8 colorB, u8 op);            /* 00:2791 */
extern volatile u8 hUiMode;                                         /* $fffb: 0 = 8px, 1 = 12px */

#define MQ_POS   (*(volatile u8 *)0xDB38)   /* first shown char (shared with flcfg.c) */
#define MQ_TICK  (*(volatile u8 *)0xDB39)   /* frames since the last step */
#define MQ_FR    (*(volatile u8 *)0xDB3B)   /* hFrame at the previous tick */
#define LR_NAME  (*(const u8 * volatile *)0xDB3C)  /* the name being shown */
#define LR_LEN   (*(volatile u8 *)0xDB3E)   /* its length when it scrolls, else 0 */
#define LR_GEO   (*(volatile u8 *)0xDB3F)   /* whose band: 0 START overlay (lastrom_box.c), 1 BACKUPSAVE prompt (bkprompt.c) */
#define HFRAME   (*(volatile u8 *)0xFFFA)   /* +1 per VBlank (VBlankPadLatch) */

#define NAME_W   18                         /* 8px field, characters */
#define MQ_GAP   3                          /* blanks between repeats */
#define MQ_RATE  20                         /* frames per step (3 chars/s) */
#define MQ_HOLD  60                         /* ...at the start of the name (1 s) */

static u8 fit(const u8 *s);
static void draw(void);

/* The entry point stays the first function in the file: the far stub
 * jumps to the block's first byte. */
void LastRomName(u16 far_pad_thunk, u16 far_pad_af, u16 far_pad_ret, const u8 *s) {
    u8 len, f, d;

    (void)far_pad_thunk;
    (void)far_pad_af;
    (void)far_pad_ret;
    if (s) {
        for (len = 0; len < 254 && s[len]; len++) {}
        LR_NAME = s;
        MQ_POS = 0;
        MQ_TICK = 0;
        MQ_FR = HFRAME;
        if (hUiMode ? fit(s) >= len : len <= NAME_W) len = 0;
        LR_LEN = len;
        draw();
        return;
    }
    len = LR_LEN;
    if (len == 0) return;
    f = HFRAME;
    d = f - MQ_FR;
    MQ_FR = f;
    if (d > 100) d = 100;                 /* MQ_TICK stays below 256 */
    MQ_TICK += d;
    if (MQ_TICK >= (MQ_POS == 0 ? MQ_HOLD : MQ_RATE)) {
        MQ_TICK = 0;
        if (++MQ_POS >= len + MQ_GAP) MQ_POS = 0;
        draw();
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
    u8 buf[40];
    const u8 *s = LR_NAME;
    u8 i, k, len = LR_LEN;

    if (len == 0) {
        for (i = 0; i < 39 && s[i]; i++) buf[i] = s[i];
        buf[i] = 0;
    } else {
        k = MQ_POS;
        for (i = 0; i < 39; i++) {
            buf[i] = k < len ? s[k] : ' ';
            if (++k >= len + MQ_GAP) k = 0;
        }
        buf[39] = 0;
    }
    StoreDrawParams(0, 3, 0);             /* paper on ink: the row is LastRomBox's band */
    if (!hUiMode) {
        DrawString(buf, NAME_W, 1, LR_GEO ? 7 : 14);
        StoreDrawParams(3, 0, 0);
        return;
    }
    i = fit(buf);
    if (i == 0) i = 1;
    DrawString12(0, 0, 0, buf, i, 1, LR_GEO ? 56 : 112);
    StoreDrawParams(3, 0, 0);
}
