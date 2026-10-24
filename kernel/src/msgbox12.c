/* Reading / Loading / Error file boxes, in both UI modes (docs/tab-strip12.md
 * "Status boxes", docs/dark-mode.md "Popups").
 *
 * Bank 8, injected at 08:7e80. The three stock drawers (DrawReadingBox
 * 08:7344, DrawLoadingBox 08:737f, DrawErrorFileBox 08:73ba) are the same
 * code with a different string: ink 0 on paper 3, a filled box
 * (35,37)-(125,108), ten characters at column 5 of tile row 8. Each now
 * starts with `jp MsgHook<n>` (08:7e10 / 7e24 / 7e38), which calls this
 * function with n and returns. (Until dark mode, 8px replayed the displaced
 * `ld hl,$0003` and ran the stock code; the hooks' `jr nz` is now `jr`.)
 *
 * Light: ink 0 on paper 3, as stock. A dark theme: white ink on a lighter
 * shade of the background (PopupDrawParams), like the other popups.
 *
 * 8px: the stock box and string. 12px: the same box, the string on the
 * 12px row at y 64 from x 44, clipped at the box's right side so the row's
 * paper stays inside it. The strings are the stock ones, copied to the
 * stack because the renderer runs in bank 2.
 *
 *   python3 tools/inject.py src/msgbox12.c $V 8 7e80 MsgBox12 \
 *       --pin FarCallDrawString12=05c0 --pin DrawRect=27ba --pin StoreDrawParams=2791 \
 *       --pin PopupDrawParams=0290 --pin DrawString=08b7 \
 *       --pin ReadingStr=7374 --pin LoadingStr=73af --pin ErrorFileStr=73ea \
 *       --replace --apply
 */

#include "types.h"
#include "draw.h"
#include "vars.h"

extern const u8 ReadingStr[];      /* 08:7374 "Reading..." */
extern const u8 LoadingStr[];      /* 08:73af "Loading..." */
extern const u8 ErrorFileStr[];    /* 08:73ea "Error file" */

void MsgBox12(u8 which) {
    u8 buf[12];
    const u8 *s;
    u8 i;

    s = which == 0 ? ReadingStr : which == 1 ? LoadingStr : ErrorFileStr;
    for (i = 0; i < 10 && s[i]; i++) buf[i] = s[i];
    buf[i] = 0;
    if (THEME) PopupDrawParams(3, 0); else StoreDrawParams(0, 3, 0);
    DrawRect(0x23, 0x25, 0x7d, 0x6c, 1);
    if (!hUiMode) {
        DrawString(buf, 10, 5, 8);
        return;
    }
    hClip12 = 0x7d;
    FarCallDrawString12(buf, 0, 44, 66);     /* row >= 18: pixel y, rounded down to 64 */
    hClip12 = 0;
}
