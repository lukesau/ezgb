/* Reading / Loading / Error file boxes, in both UI modes (docs/tab-strip12.md
 * "Status boxes", docs/dark-mode.md "Popups").
 *
 * Bank 11, injected at 0B:4B00 (MsgBox12 at 08:7e80 until 2026-10-31). The
 * three stock drawers (DrawReadingBox 08:7344, DrawLoadingBox 08:737f,
 * DrawErrorFileBox 08:73ba) start with `jp MsgHook<n>` (08:7e10 / 7e24 /
 * 7e38), which call MsgBoxFar (08:7e4c), a far stub to this, with n.
 *
 * Ten characters need little room, so the box hugs them (after davidesqalv's
 * ezgb-dv fork): 96 px wide, x 32..127, and the text's height plus a margin,
 * y 52..87 in 12px (the text row at y 64) and 54..81 in 8px (tile row 8),
 * where the stock box was (35,37)-(125,108). Its frame is his too: a 2 px
 * outer line, a 1 px gap and a 1 px inner line, in the text's color, with
 * the outer corner pixels left as they were, so the box looks rounded.
 *
 * Light: ink 0 on paper 3, as stock. A dark theme: white ink on a lighter
 * shade of the background (PopupDrawParams), like the other popups; DV keeps
 * black. The strings are this file's own: bank 8's are out of reach here.
 *
 *   python3 tools/inject.py src/msgbox.c $V 11 4b00 MsgBox \
 *       --pin FarCallDrawString12=05c0 --pin DrawRect=27ba --pin StoreDrawParams=2791 \
 *       --pin PopupDrawParams=0290 --pin DrawString=08b7 --apply
 */

#include "types.h"
#include "draw.h"
#include "vars.h"

/* BATTERY DRY (BatteryCheck, 00:1857, which = 3) is the same box around two
 * lines, 112 px wide, x 24..135, y 46..89, tile rows 7 and 9. It comes up
 * before EZGB.CFG is read, so it is always 8px. which = 4 erases it once A
 * is pressed (00:1878), or the Reading box that follows is drawn over it. */

void MsgBox(u16 pad_thunk, u16 pad_af, u16 pad_ret, u8 which) {
    static const u8 text[3][11] = {
        {'R','e','a','d','i','n','g','.','.','.',0},
        {'L','o','a','d','i','n','g','.','.','.',0},
        {'E','r','r','o','r',' ','f','i','l','e',0},
    };
    static const u8 dry[] = "Battery dry!";
    static const u8 dry_ok[] = "[A] ok";
    u8 buf[11];
    u8 i, x0, x1, y0, y1;

    (void)pad_thunk;
    (void)pad_af;
    (void)pad_ret;
    x0 = 32;
    x1 = 127;
    y0 = hUiMode ? 52 : 54;
    y1 = hUiMode ? 87 : 81;
    if (which == 3) {
        x0 = 24;
        x1 = 135;
        y0 = 46;
        y1 = 89;
    }
    if (which == 4) {                    /* A was pressed: the box off the screen */
        StoreDrawParams(0, 0, 0);
        DrawRect(24, 46, 135, 89, 1);
        return;
    }
    if (THEME) PopupDrawParams(3, 0); else StoreDrawParams(0, 3, 0);
    /* paper and the outer line, without its four corner pixels: the corners
     * are rounded, and what is behind them (a list row, the bar, a theme's
     * background) stays as it is. Until 2026-11-11 they were painted in
     * color 0, which is only right over an empty background. */
    DrawRect(x0 + 1, y0, x1 - 1, y1, 1);
    DrawRect(x0, y0 + 1, x0, y1 - 1, 1);
    DrawRect(x1, y0 + 1, x1, y1 - 1, 1);
    DrawRect(x0 + 1, y0 + 1, x1 - 1, y1 - 1, 0);       /* its second pixel */
    DrawRect(x0 + 3, y0 + 3, x1 - 3, y1 - 3, 0);       /* the inner line */
    if (which == 3) {
        DrawString(dry, 12, 4, 7);
        DrawString(dry_ok, 6, 7, 9);
    } else {
        for (i = 0; i < 11; i++) buf[i] = text[which][i];
        if (!hUiMode) {
            DrawString(buf, 10, 5, 8);
        } else {
            hClip12 = 127 - 4;
            FarCallDrawString12(buf, 0, 44, 66);     /* row >= 18: pixel y, rounded down to 64 */
            hClip12 = 0;
        }
    }
}
