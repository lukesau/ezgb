/* mod: the file list in the 12px font (list12.c) */
#ifndef LIST12_H
#define LIST12_H

#define LIST12_ROWS	10U

extern UINT8 ui_font;		/* 0: the 8px console font, 1: the mod's 12px, 2: EZF (ezcfg.c, UI= in /EZGB.CFG) */

void tabs12(UINT8 page) __banked;		/* DrawGB in the 12px font */
/* Draw_Text in the 12px font: s is in WRAM, the rest are Draw_Text's */
void text12(const UINT8 *s, UINT8 len, UINT8 x, UINT8 y) __banked;
void clock12(const UINT8 *t, UINT8 bcd, UINT8 hot) __banked;	/* the SET tab's date and time */
void clock12_reset(void) __banked;	/* its line cleared, every field to be drawn */
extern UINT8 ui_font_cfg;	/* the font the settings ask for: ui_font goes back to it */
void recent12_show(UINT8 count, UINT8 sel) __banked;	/* Show_recent_list in the 12px fonts */
void list12_show(UINT16 show_offset, UINT16 file_select) __banked;
void list12_refresh(UINT16 show_offset, UINT16 file_select, UINT8 updown) __banked;
void list12_loop(UINT32 shift, UINT16 show_offset, UINT16 file_select) __banked;

#endif
