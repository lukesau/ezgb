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
 * the outer corners rounded off in the screen's (color 0).
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

#define X0 32
#define X1 127

void MsgBox(u16 pad_thunk, u16 pad_af, u16 pad_ret, u8 which) {
    static const u8 text[3][11] = {
        {'R','e','a','d','i','n','g','.','.','.',0},
        {'L','o','a','d','i','n','g','.','.','.',0},
        {'E','r','r','o','r',' ','f','i','l','e',0},
    };
    u8 buf[11];
    u8 i, y0, y1;

    (void)pad_thunk;
    (void)pad_af;
    (void)pad_ret;
    for (i = 0; i < 11; i++) buf[i] = text[which][i];
    y0 = hUiMode ? 52 : 54;
    y1 = hUiMode ? 87 : 81;
    if (THEME) PopupDrawParams(3, 0); else StoreDrawParams(0, 3, 0);
    DrawRect(X0, y0, X1, y1, 1);                       /* paper, outer line */
    DrawRect(X0 + 1, y0 + 1, X1 - 1, y1 - 1, 0);       /* its second pixel */
    DrawRect(X0 + 3, y0 + 3, X1 - 3, y1 - 3, 0);       /* the inner line */
    if (!hUiMode) {
        DrawString(buf, 10, 5, 8);
    } else {
        hClip12 = X1 - 4;
        FarCallDrawString12(buf, 0, 44, 66);     /* row >= 18: pixel y, rounded down to 64 */
        hClip12 = 0;
    }
    /* the outer corners in the screen's color */
    StoreDrawParams(0, 0, 0);
    DrawRect(X0, y0, X0, y0, 0);
    DrawRect(X1, y0, X1, y0, 0);
    DrawRect(X0, y1, X0, y1, 0);
    DrawRect(X1, y1, X1, y1, 0);
    if (THEME) PopupDrawParams(3, 0); else StoreDrawParams(0, 3, 0);
}
