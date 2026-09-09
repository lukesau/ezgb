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
 * Font codes: $C0 folder, $C1 .gb cart, $C2 .gbc cart, $C3 boxed "?" for
 * anything else (FolderIconGlyphs, 00:3806). */

typedef unsigned char u8;

extern void DrawString(const u8 *s, u8 len, u8 x, u8 y);   /* 00:08b7 */

static u8 up(u8 c);   /* defined after: inject.py pins the FIRST-defined function at the origin */

void DrawNameWithIcon(const u8 *s, u8 len, u8 x, u8 y) {
    static const u8 icon_dir[2]  = { 0xC0, 0 };
    static const u8 icon_gb[2]   = { 0xC1, 0 };
    static const u8 icon_gbc[2]  = { 0xC2, 0 };
    static const u8 icon_unk[2]  = { 0xC3, 0 };
    const u8 *icon;
    u8 i, dot, n, e;

    (void)x;
    if (len == 0) {
        icon = icon_dir;
        len = 16;
    } else {
        dot = 0xFF;
        for (i = 0; i < 254 && s[i]; i++) if (s[i] == '.') dot = i;
        n = i;
        icon = icon_unk;
        if (dot != 0xFF && up(s[dot + 1]) == 'G' && up(s[dot + 2]) == 'B') {
            e = (u8)(n - dot - 1);
            if (e == 2) icon = icon_gb;
            else if (e == 3 && up(s[dot + 3]) == 'C') icon = icon_gbc;
        }
        len--;
    }
    DrawString(icon, 1, 0, y);
    DrawString(s, len, 1, y);
}

static u8 up(u8 c) { return (c >= 'a' && c <= 'z') ? (u8)(c - 32) : c; }
