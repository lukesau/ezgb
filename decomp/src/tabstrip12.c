/* 12px tab strip (docs/tab-strip12.md).
 *
 * Bank 2, injected at 02:5e00. The stock tab drawer DrawMenuTabs (08:7169)
 * now starts with `jp TabStripHook` (08:7b20): in 8px mode the hook replays
 * the displaced instruction and continues in the stock code; in 12px mode it
 * pushes the tab number and far-calls this function instead (inline
 * trampoline: two pad parameters), then, for the SD tab, falls into the
 * pick-mode banner like the stock SD arm.
 *
 * tab: 0 SD, 1 SET, 2 HELP, 3 = clear the content area and leave the strip.
 *
 * Geometry in 12px mode: labels on the 12px row at y 0..11, a 1 px rule at
 * y 12 (stock: 8x8 labels, 2 px rule at y 8..9), then the content: the
 * browser list from y 20 (draw12.c STRIP_H), the SET and HELP panes from
 * y 16 as before. The rule is one pixel because the SET pane's TIME button
 * box sits right under it: its top edge moves from y 13 to 14 in 12px mode
 * (SetBtnTopHL, 04:5f60), which leaves one blank row under the rule and
 * one row of padding above the button's text.
 *
 * DrawString12 always paints from its start x to the row's right edge, so
 * the labels are drawn left to right, each at its pixel x (the `col`
 * argument, values >= 2), the selected one in paper on ink; a last blank
 * after HELP ends that tab's highlight. The start positions come from one
 * Fit12 pass over the whole strip text, so they follow the font's metrics.
 * The entry number at the right (TabNum12, 00:0380) is drawn by the list
 * code afterwards.
 *
 *   python3 tools/inject.py src/tabstrip12.c $V 2 5e00 TabStrip12 \
 *       --pin DrawString12=7500 --pin Fit12=7100 --pin DrawRect=27ba \
 *       --pin StoreDrawParams=2791 --replace --apply
 */

typedef unsigned char u8;
typedef unsigned int u16;

extern void DrawString12(u16 pad_thunk, u16 pad_af, u16 pad_ret, const u8 *s, u8 len, u8 col, u8 row); /* 02:7500 */
extern u8 Fit12(u16 pad_thunk, u16 pad_af, const u8 *s, u8 len, u8 col, u8 *xs);                        /* 02:7100 */
extern void DrawRect(u8 x0, u8 y0, u8 x1, u8 y1, u8 fill);          /* 00:27ba */
extern void StoreDrawParams(u8 color, u8 colorB, u8 op);            /* 00:2791 */

#define FL_PICK (*(volatile u8 *)0xDBFE)   /* SET tab: PICK ROM armed (flcfg.c) */
#define RULE_Y  12                 /* the strip's rule, 1 px */
#define LIST_Y  20                 /* first list row (draw12.c STRIP_H) */

void TabStrip12(u16 far_pad_thunk, u16 far_pad_af, u8 tab) {
    /* " SD " at 0, " SET " at 4, " HELP " at 9, and one more blank */
    static const u8 text[17] = {' ','S','D',' ',' ','S','E','T',' ',' ','H','E','L','P',' ',' ',0};
    static const u8 start[4] = {0, 4, 9, 15};
    static const u8 banner[13] = {' ','P','I','C','K',' ','A',' ','R','O','M',' ',0};
    u8 xs[40];
    u8 i, k;

    (void)far_pad_thunk;
    (void)far_pad_af;
    StoreDrawParams(0, 0, 0);
    if (tab == 0) {
        DrawRect(0, 0, 159, LIST_Y - 1, 1);      /* the list repaints its own rows */
    } else if (tab == 3) {
        DrawRect(0, RULE_Y + 1, 159, 143, 1);
    } else {
        DrawRect(0, 0, 159, 143, 1);
    }
    if (tab == 0 && FL_PICK) {
        /* SET tab's pick mode (flpick_banner.c draws the 8px one); the entry
         * number repaints its field in the normal colours afterwards */
        StoreDrawParams(0, 3, 0);
        DrawString12(0, 0, 0, banner, 0, 0, 0);
    } else if (tab != 3) {
        Fit12(0, 0, text, 0, 0, xs);
        for (i = 0; i < 4; i++) {
            k = start[i];
            if (i == tab) StoreDrawParams(0, 3, 0); else StoreDrawParams(3, 0, 0);
            DrawString12(0, 0, 0, text + k, i == 3 ? 1 : (u8)(start[i + 1] - k), i ? xs[k] : 0, 0);
        }
    }
    StoreDrawParams(3, 3, 0);
    DrawRect(0, RULE_Y, 159, RULE_Y, 1);
    StoreDrawParams(3, 0, 0);
}
