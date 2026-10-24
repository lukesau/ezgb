/* SET tab THEME button (docs/dark-mode.md).
 *
 * Bank 4, injected at 04:7670, near-called by flcfg.c (04:6600), which has
 * no room left for it. The button sits on row 14 between the UI: label and
 * the 8px/12px button, and is cursor row 5 (flcfg.c ROW_THEME):
 *
 *   op 0  draw it plain
 *   op 1  draw it highlighted (the cursor is on it)
 *   op 2  A: the next theme, wrapping; save EZGB.CFG, set the palettes and
 *         the pSRAM mark (theme.c, through FarCallTheme_B4), draw it
 *         highlighted
 *
 * Shaped like the other SET buttons: 8px, the text right-aligned in columns
 * 7-12 with the box 5 px left and 4 px right of it, 3 px above and 5 below;
 * 12px, the text row plus a pixel above and below (docs/set-pane12.md), and
 * wider to the left, since 12px PURPLE is about 60 px: box x 40..108, text
 * from x 45.
 */

#include "types.h"
#include "draw.h"
#include "vars.h"
#include "ezcfg.h"

extern void FarCallEzCfg(void);         /* 04:5f00 -> ezcfg (02:4a00) */
extern void FarCallTheme_B4(void);      /* 04:5990 -> theme (02:43d0) */

void ThemeRow(u8 op) {
    /* by theme number (theme_ramps.c), six wide so a shorter name covers
     * a longer one */
    static const u8 names[THEME_COUNT][7] = {
        {' ','L','I','G','H','T',0},
        {' ',' ','D','A','R','K',0},
        {' ',' ',' ','R','E','D',0},
        {' ','G','R','E','E','N',0},
        {'P','U','R','P','L','E',0},
        {' ',' ','B','L','U','E',0},
    };
    const u8 *n;
    u8 buf[7];
    u8 i;

    if (op == 2) {
        THEME = (u8)(THEME + 1) < THEME_COUNT ? THEME + 1 : 0;
        EZ_OP = OP_SAVE;
        FarCallEzCfg();
        FarCallTheme_B4();
    }
    if (op) StoreDrawParams(0, 3, 0); else StoreDrawParams(3, 0, 0);
    if (hUiMode) {
        DrawRect(0x28, 0x6f, 0x6c, 0x7c, 1);
        /* DrawString12 runs in bank 2: the text goes on the stack. It
         * repaints the whole field, so the 8px padding is left out. */
        n = names[THEME];
        while (*n == ' ') n++;
        for (i = 0; (buf[i] = n[i]) != 0; i++) {}
        hClip12 = 0x6b;
        FarCallDrawString12(buf, 0, 0x2d, 14 * 8 + 2);
        hClip12 = 0;
    } else {
        DrawRect(0x33, 0x6d, 0x6c, 0x79, 1);
        DrawString(names[THEME], 6, 7, 14);
    }
    StoreDrawParams(3, 0, 0);
}
