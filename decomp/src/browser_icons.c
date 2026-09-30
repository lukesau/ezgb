/* Browser row icons (docs/dmg-ui-visibility.md "Change 4", docs/font12.md).
 *
 * Bank 2, injected at 02:7300 and reached through the 8-byte far stub that
 * now sits at the old bank-0 address 00:3ec8 (`cd 8d 07 00 73 02 00 c9`), so
 * the six stock name draws in DrawBrowserEntries / DrawBrowserDetail and
 * the scroll-repaint shim still `call $3ec8` with DrawString's (s, len, x,
 * y) frame. The stub is `call`ed, so FarCallTrampoline's three words sit
 * between its return address and the arguments: three pad parameters.
 *
 * Column 0 gets one icon glyph and the name follows from column 1.
 * Directories are recognised by the stock len 0; files come in with len
 * $14. The icon is drawn in whatever ink the row has, so it inverts with
 * the selection bar. Font codes: $C0 folder, $C1 .gb cart, $C2 .gbc cart,
 * $C4 .sav page, $C3 boxed "?" for anything else.
 *
 * Living in bank 2 next to the 12x12 renderer it calls DrawString12 (the
 * far entry, hence the three dummy pads) with a plain near call, one
 * trampoline hop per row instead of two, and it leaves bank 0 free for the
 * upcoming 8px/12px mode switch.
 *
 *   python3 tools/inject.py src/browser_icons.c $V 2 7300 DrawNameWithIconImpl \
 *       --pin DrawString12=7500 --pin DrawString=08b7 --pin hUiMode=fffb --replace --apply
 */

typedef unsigned char u8;
typedef unsigned int u16;

#define UP(c) ((u8)((c) & 0xDF))   /* case-fold letters (enough for ext compares) */

extern void DrawString12(u16 pad_thunk, u16 pad_af, u16 pad_ret, const u8 *s, u8 len, u8 col, u8 row); /* 02:5800 */
extern void DrawString(const u8 *s, u8 len, u8 x, u8 y);   /* 00:08b7, the stock 8x8 painter */
extern volatile u8 hUiMode;                                 /* $fffb: 0 = 8px, 1 = 12px (docs/ui-mode.md) */

void DrawNameWithIcon(u16 far_pad_thunk, u16 far_pad_af, u16 far_pad_ret, const u8 *s, u8 len, u8 x, u8 y) {
    u8 i, dot, n, e, c1, c2, ic;

    (void)far_pad_thunk;
    (void)far_pad_af;
    (void)far_pad_ret;
    u8 buf[41];

    (void)x;
    if (len == 0) {
        ic = 0xC0;                       /* folder */
        len = 19;
    } else {
        dot = 0xFF;
        for (i = 0; i < 254 && s[i]; i++) if (s[i] == '.') dot = i;
        n = i;
        ic = 0xC3;                       /* boxed "?" */
        if (dot != 0xFF) {
            e = (u8)(n - dot - 1);
            c1 = UP(s[dot + 1]);
            c2 = UP(s[dot + 2]);
            if (c1 == 'G' && c2 == 'B') {
                if (e == 2) ic = 0xC1;                            /* .gb  */
                else if (e == 3 && UP(s[dot + 3]) == 'C') ic = 0xC2;   /* .gbc */
            } else if (e == 3 && c1 == 'S' && c2 == 'A' && UP(s[dot + 3]) == 'V') {
                ic = 0xC4;               /* .sav page */
            }
        }
        len--;
    }
    /* One call for icon + name: the 12px renderer (docs/font12.md)
     * composes the whole row in one buffer from column 0. The font is
     * proportional, so how many characters fit is up to the renderer: it
     * lays out up to 40 glyphs and stops at the first that would cross the
     * row's right edge, painting paper after the NUL. 39 characters are
     * copied, more than the narrowest glyphs can fill the 148 px field
     * with. */
    if (!hUiMode) {
        /* 8px: icon in column 0, name from column 1, one column narrower
         * than stock (16 for the 17-wide default, 19 for files). */
        DrawString(&ic, 1, 0, y);
        DrawString(s, len, 1, y);
        return;
    }
    buf[0] = ic;
    for (i = 0; i < 39; i++) {
        buf[1 + i] = s[i];
        if (s[i] == 0) {
            break;
        }
    }
    buf[40] = 0;
    (void)len;
    DrawString12(0, 0, 0, buf, 0, 0, y);
}
