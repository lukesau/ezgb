/* Proportional layout for the 12px browser font (docs/font12.md).
 *
 * The glyphs of Font12 have no cells any more: each has an ink width and an
 * advance (ink + gap), and a pair of neighbours may kern, pulling the second
 * glyph left by up to 2 px where their shapes leave room (T followed by o,
 * r followed by a period). All of that comes from the metrics table
 * scripts/font12-pack.py derives from the glyph sheet (Font12Metrics at
 * 02:6978): advances, ink widths, and a class-kerning matrix, each glyph
 * carrying a left class (its column) and a right class (its row).
 *
 * Fit12 runs the pen over a string: for each character it subtracts the
 * kern against the previous glyph, stops at the first glyph whose ink would
 * cross the right edge of the row (x + w > 160), records the pen x in xs[]
 * and advances. It returns how many glyphs were placed. DrawString12 draws
 * exactly those at exactly those positions, and the marquee cave in bank 0
 * (MarqueeWidth12, 00:0229) calls it on the raw name to learn whether the
 * whole name fits: count == strlen means no scrolling is needed, which is
 * how the stock "width >= namelen" test is fed a per-name width.
 *
 * col 0 starts the pen at x = 0 (the icon cell); any other col starts it at
 * the name field, which begins where an icon's advance ends (12 px), so the
 * marquee drawn at col 1 lands where DrawNameWithIcon put the name. len is
 * a character cap; 0 means up to the NUL. Never more than MAX_GLYPHS are
 * placed (xs[] is that big in every caller).
 *
 * The far entry has two pad parameters: MarqueeWidth12 reaches it through an
 * inline `call FarCallTrampoline`, so the trampoline's two words sit between
 * the cave's return address and the arguments (docs/browser-hide-filter.md);
 * draw12.c near-calls it with two dummies. The count comes back in E.
 *
 * Bank 2, injected at 02:7100 (must stay the first definition in the file;
 * the metrics table below it grows with the kerning classes, so it starts
 * at a round address well past the table's end):
 *
 *   python3 tools/inject.py src/layout12.c $V 2 7100 Fit12 \\
 *       --pin Font12Metrics=6978 --replace --apply
 */

typedef unsigned char u8;
typedef unsigned int u16;

extern const u8 Font12Metrics[];   /* 02:6978, scripts/font12-pack.py */
extern volatile u8 hClip12;        /* $fff9: right edge for the next layout, 0 = x 160 */

#define M Font12Metrics
#define M_ADV   0                  /* u8[101] advance */
#define M_W     101                /* u8[101] ink width */
#define M_LCOL  202                /* u8[101] left kerning class = matrix column */
#define M_RROW  303                /* u16[101] byte offset of the right class row, from M */
#define ICON0   96                 /* glyph index of the first icon ($C0) */
#define ROW_W   160
#define MAX_GLYPHS 40

static u8 glyph_index(u8 c);
static u8 kern(u8 a, u8 b);

u8 Fit12(u16 far_pad_thunk, u16 far_pad_af, const u8 *s, u8 len, u8 col, u8 *xs) {
    u8 i, x, g, prev, c, lim;

    (void)far_pad_thunk;
    (void)far_pad_af;
    x = col >= 2 ? col : col ? M[M_ADV + ICON0] : 0;   /* >= 2: a pixel x */
    lim = hClip12;                    /* a caller's right edge (draw12.c), else the row's */
    if (lim == 0 || lim > ROW_W) {
        lim = ROW_W;
    }
    if (len == 0 || len > MAX_GLYPHS) {
        len = MAX_GLYPHS;
    }
    prev = 0xFF;
    for (i = 0; i < len; i++) {
        c = s[i];
        if (c == 0) {
            break;
        }
        g = glyph_index(c);
        if (prev != 0xFF) {
            x -= kern(prev, g);
        }
        if (x >= lim || (u8)(x + M[M_W + g]) > lim) {
            break;
        }
        xs[i] = x;
        x += M[M_ADV + g];
        prev = g;
    }
    return i;
}

/* Pixels glyph b moves left when it follows glyph a: the 2-bit entry at
 * (a's right class row, b's left class column). Class 0 never kerns. */
static u8 kern(u8 a, u8 b) {
    u8 l = M[M_LCOL + b];
    u16 r;

    if (l == 0) {
        return 0;
    }
    r = *(const u16 *)(M + M_RROW + (u8)(a << 1));
    return (u8)((M[r + (l >> 2)] >> ((l & 3) << 1)) & 3);
}

static u8 glyph_index(u8 c) {
    if (c >= 0x20 && c < 0x80) {
        return (u8)(c - 0x20);
    }
    if (c >= 0xC0 && c <= 0xC4) {
        return (u8)(ICON0 + (c - 0xC0));
    }
    return (u8)('?' - 0x20);
}
