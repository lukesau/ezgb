/* A SET tab checkbox (docs/fastlaunch-set-tab.md), shared by flcfg.c and
 * setpage.c, which each had a copy until 2026-11-11.
 *
 * Bank 4, injected at 04:77a0, near-called. The box is 9 px square at pixel
 * x, y (the stock AUTO SAVE sequence, 04:496a): clear, outline, tick.
 *
 *   python3 tools/inject.py src/setbox.c $V 4 77a0 SetBox \
 *       --pin DrawRect=27ba --pin StoreDrawParams=2791 --apply
 */

#include "types.h"
#include "draw.h"

/* hi: 0 plain, 1 under the cursor, 2 a box that can't be set, drawn in color
 * index 2 as themepage.c draws its locked rows. */
void SetBox(u8 x, u8 y, u8 on, u8 hi) {
    /* the cursor: the outline in shade 1, as stock, and since 2026-11-11 a
     * second outline one pixel outside it in the text's color, because
     * shade 1 alone is lost on a dark background. The clear takes that
     * ring off again. */
    StoreDrawParams(0, 0, 0);
    DrawRect(x - 1, y - 1, x + 9, y + 9, 1);
    StoreDrawParams(3, 0, 0);
    if (hi == 1) {
        DrawRect(x - 1, y - 1, x + 9, y + 9, 0);
        StoreDrawParams(1, 1, 0);
    } else if (hi) {
        StoreDrawParams(2, 0, 0);       /* a box that can't be set: color index 2 */
    }
    DrawRect(x, y, x + 8, y + 8, 0);
    if (on) {
        StoreDrawParams(3, 3, 0);
        DrawRect(x + 2, y + 2, x + 6, y + 6, 1);
    }
}
