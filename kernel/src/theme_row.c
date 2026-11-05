/* SET tab THEME button (docs/dark-mode.md).
 *
 * Bank 4, injected at 04:77a0, near-called by setpage.c (04:6610) and flcfg.c
 * (04:6d19). The button sits on row 2 of the SET tab's second page, after
 * THEME:, and is cursor row 6 (flcfg.c ROW_THEME):
 *
 *   op 0  draw it plain
 *   op 1  draw it highlighted (the cursor is on it)
 *   op 2  A or B (THEME_BACK set): the next or the previous theme, wrapping;
 *         set the palettes and the pSRAM mark (theme.c, through
 *         FarCallTheme_B4), mark the settings changed (SetCommit writes the
 *         file on NEXT, on PREV and when the screen is left), draw it highlighted
 *
 * The order is light, dark, DV, red .. blue, then custom when EZGB.CFG has a
 * valid COLORS=. With palette RAM locked (PAL_LOCKED: a DMG, or a CGB in
 * compatibility mode) the colored themes and custom are the dark palette, so
 * it is only light, dark, DV, and one of the others set in the file shows as
 * DARK. THEME keeps its value until the button is pressed, so a card moved to
 * a color console keeps it.
 *
 * Shaped like the other SET buttons: 8px, the text right-aligned in columns
 * 13-18 with the box 5 px left and 4 px right of it, 3 px above and 5 below;
 * 12px, the text row plus a pixel above and below (docs/set-pane12.md), and
 * wider to the left, since 12px PURPLE is about 60 px: box x 86..155, text
 * from x 91.
 */

#include "types.h"
#include "draw.h"
#include "vars.h"
#include "ezcfg.h"

extern void FarCallTheme_B4(void);      /* 04:5990 -> theme (02:43d0) */
extern const u8 theme_names[THEME_COUNT][7];  /* 04:7eeb, theme_names.c */

void ThemeRow(u8 op) {
    const u8 *n;
    u8 buf[7];
    u8 i, t = THEME;

    if (PAL_LOCKED && t > 1 && t != THEME_DV) t = 1;
    if (op == 2) {
        /* DV keeps its number, 7, after custom (vars.h) */
        static const u8 order[8] = {0, 1, THEME_DV, 2, 3, 4, 5, THEME_CUSTOM};
        u8 n = PAL_LOCKED ? 3 : CUST_OK ? 8 : 7;
        for (i = 0; order[i] != t; i++) {}
        if (THEME_BACK) i = i ? i - 1 : n - 1;
        else i = i + 1 == n ? 0 : i + 1;
        THEME_BACK = 0;
        THEME = t = order[i];
        SET_DIRTY = 1;
        FarCallTheme_B4();
    }
    if (op) StoreDrawParams(0, 3, 0); else StoreDrawParams(3, 0, 0);
    if (hUiMode) {
        DrawRect(0x56, 0x0f, 0x9b, 0x1c, 1);
        /* DrawString12 runs in bank 2: the text goes on the stack. It
         * repaints the whole field, so the 8px padding is left out. */
        n = theme_names[t];
        while (*n == ' ') n++;
        for (i = 0; (buf[i] = n[i]) != 0; i++) {}
        hClip12 = 0x9a;
        FarCallDrawString12(buf, 0, 0x5b, 2 * 8 + 2);
        hClip12 = 0;
    } else {
        DrawRect(0x63, 0x0d, 0x9b, 0x19, 1);
        DrawString(theme_names[t], 6, 13, 2);
    }
    StoreDrawParams(3, 0, 0);
}
