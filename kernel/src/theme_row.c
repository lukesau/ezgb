/* SET tab THEME button (docs/dark-mode.md).
 *
 * Bank 4, injected at 04:7670, near-called by setpage.c (04:7a00). The
 * button sits on row 2 of the SET tab's second page, after THEME:, and is
 * cursor row 7 (flcfg.c ROW_THEME):
 *
 *   op 0  draw it plain
 *   op 1  draw it highlighted (the cursor is on it)
 *   op 2  A: the next theme, wrapping, past CUSTOM when EZGB.CFG has no
 *         valid COLORS=; save EZGB.CFG, set the palettes and the pSRAM
 *         mark (theme.c, through FarCallTheme_B4), draw it highlighted
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

extern void FarCallEzCfg(void);         /* 04:5f00 -> ezcfg (02:4a00) */
extern void FarCallTheme_B4(void);      /* 04:5990 -> theme (02:43d0) */
extern const u8 theme_names[THEME_COUNT][7];  /* 04:7f20, theme_names.c */

void ThemeRow(u8 op) {
    const u8 *n;
    u8 buf[7];
    u8 i;

    if (op == 2) {
        i = THEME + 1;
        if (i == THEME_CUSTOM && !CUST_OK) i = THEME_COUNT;
        THEME = i < THEME_COUNT ? i : 0;
        EZ_OP = OP_SAVE;
        FarCallEzCfg();
        FarCallTheme_B4();
    }
    if (op) StoreDrawParams(0, 3, 0); else StoreDrawParams(3, 0, 0);
    if (hUiMode) {
        DrawRect(0x56, 0x0f, 0x9b, 0x1c, 1);
        /* DrawString12 runs in bank 2: the text goes on the stack. It
         * repaints the whole field, so the 8px padding is left out. */
        n = theme_names[THEME];
        while (*n == ' ') n++;
        for (i = 0; (buf[i] = n[i]) != 0; i++) {}
        hClip12 = 0x9a;
        FarCallDrawString12(buf, 0, 0x5b, 2 * 8 + 2);
        hClip12 = 0;
    } else {
        DrawRect(0x63, 0x0d, 0x9b, 0x19, 1);
        DrawString(theme_names[THEME], 6, 13, 2);
    }
    StoreDrawParams(3, 0, 0);
}
