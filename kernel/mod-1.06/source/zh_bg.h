/* ============================================================================
   zh_bg.h  -  records the last non-white fill rect and its colour (LANG_ZH only)
   ----------------------------------------------------------------------------
   Why: zh Draw_Text is 12px bitmap, so the row must be filled before drawing.
   Where does that colour come from? The English build reads BGP, but GBDK-2020's
   graphics color() never touches BGP_REG (that is a text-mode register), so it
   always reads white: the Reading dialog got a white bar.

   Approach: wrap color() and box().
     color() -> record the background colour (used to classify the next fill)
     box()   -> M_FILL with a non-white background: push rect and colour
                M_FILL with a white background: forget everything (white area)
    The last few fills are kept (ZH_BOX_SLOTS in ui_zh.c) because dialogs are
    drawn as "big fill, then smaller fills inside it": a single slot held only
    the innermost one, so text outside it got a white band.
    zh_text_row takes the newest remembered rect that contains the text origin.
   White text can therefore never inherit a dialog's grey - safer than tracking bg.

   NOTE: include this AFTER <gb/gb.h> / <gb/drawing.h>, or the color/box prototypes
   get rewritten by the macros and the build fails.
   ========================================================================== */
#ifndef ZH_BG_H
#define ZH_BG_H

#include <gb/gb.h>
#include <gb/drawing.h>

#ifdef LANG_ZH
extern UINT8 zh_last_bg;		/* background of the last color() call */
extern UINT8 zh_last_fg;		/* foreground of the last color() call (border colour of fast fills) */
/* Forget every remembered fill (used after a full-screen white fill). */
void zh_box_forget(void) __banked;

/* box() wrapper: records the fill, then calls the real box() (in ui_zh.c) */
void zh_box_track(UINT8 x1, UINT8 y1, UINT8 x2, UINT8 y2, UINT8 mode) __banked;

#define color(fg, bg, mode)	(zh_last_fg = (UINT8)(fg), zh_last_bg = (UINT8)(bg), color(fg, bg, mode))
#define box(x1, y1, x2, y2, mode)	zh_box_track((x1), (y1), (x2), (y2), (mode))
#endif

#endif
