/* Browser row icons (docs/dmg-ui-visibility.md, "Change 4").
 *
 * Bank 0, injected at 00:3ec8 (the free tail of the 00:3d8c cave, after
 * BrowserScrollDownRepaint). Drop-in replacement for the six stock
 * DrawString(name, len, 0, row) calls in DrawBrowserEntries /
 * DrawBrowserDetail and the two in browser_scroll_repaint.c: same stack
 * convention as DrawString (--sdcccall 0), so each site is a 3-byte call
 * retarget and no stock code grows.
 *
 * Column 0 gets one icon glyph and the name moves to column 1, one column
 * narrower. Directories are recognised by the stock len 0 (17-wide field);
 * files come in with len $14. The icon is drawn in whatever ink the row
 * has, so it inverts with the selection bar. Any call with x != 0 (none of
 * the retargeted ones) falls through to DrawString unchanged.
 *
 * Font codes: $C0 folder, $C1 .gb cart, $C2 .gbc cart, $C4 .sav floppy,
 * $C3 boxed "?" for anything else (FolderIconGlyphs, 00:3806). */

typedef unsigned char u8;

#define UP(c) ((u8)((c) & 0xDF))   /* case-fold letters (enough for ext compares) */

extern void DrawString(const u8 *s, u8 len, u8 x, u8 y);   /* 00:08b7 */

void DrawNameWithIcon(const u8 *s, u8 len, u8 x, u8 y) {
    u8 i, dot, n, e, c1, c2, ic;

    (void)x;
    if (len == 0) {
        ic = 0xC0;                       /* folder */
        len = 16;
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
                ic = 0xC4;               /* .sav floppy */
            }
        }
        len--;
    }
    DrawString(&ic, 1, 0, y);
    DrawString(s, len, 1, y);
}
