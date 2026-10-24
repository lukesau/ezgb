/* Ink and paper for popups: the START overlay, the boot prompts, the ROM
 * menu, the save manager, the Reading / Loading / Error boxes
 * (docs/dark-mode.md "Popups").
 *
 * Bank 0, injected at 00:0290, in the room CgbInit left (cgb_init.c), so
 * every bank reaches it with a plain call. StoreDrawParams(ink, paper, 0),
 * except that in a dark theme (any THEME past 0) color 0 becomes color 1,
 * the background blended a fifth of the way to white (theme_ramps.c): a
 * popup is then a lighter shade of the background with white text, rather
 * than the background itself. Light keeps the stock colors. Erasing a popup
 * back to the screen goes through StoreDrawParams as before. */

#include "types.h"
#include "draw.h"
#include "vars.h"

void PopupDrawParams(u8 ink, u8 paper) {
    if (THEME) {
        if (ink == 0) ink = 1;
        if (paper == 0) paper = 1;
    }
    StoreDrawParams(ink, paper, 0);
}
