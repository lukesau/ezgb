// font layout: 12 rows x 8 bits, 6 pixels wide per row (6 bits used)
#include <gb/gb.h>
#include <gb/drawing.h>
#include <gbdk/console.h>
#include <stdio.h>
#include <stdlib.h>
#include "main.h"
#include <string.h>
void msg_box(const UINT8 *text) __banked;	/* mod: msgbox.c */
#include <string.h>
void msg_box(const UINT8 *text) __banked;	/* mod: msgbox.c */
#include "list12.h"		/* mod: the 12px tab strip */

#ifdef LANG_ZH
#include "ui_zh.h"
#include "zh_bg.h"		/* tracks the color() background (zh_text_row uses it to fill a row) */
#else
/* Fast rectangle fill (fill_fast.c, bank 1): writes both VRAM bit planes
   per tile, replacing large box(...,M_FILL) fills (23,000 .plot calls). */
void fill_fast_rect(UINT8 x0, UINT8 y0, UINT8 x1, UINT8 y1, UINT8 bg) __banked;
extern UINT8 pick_rom;	/* mod: ezcfg.c */
#endif

#define UI_BANK
#include "banks.h"


void DrawGB(UINT8 page)__banked
{
#ifdef LANG_ZH
	/* zh build: all text uses 12px APA (Draw_Text single entry), console is gone,
	      so mode(M_TEXT_OUT)+cls is gone as well - that pair belongs to console:
	     - mode(M_TEXT_OUT) removes the graphics LCD ISR and reloads the 96-char font
	     - the first drawing primitive afterwards (tabbar or the caller's box) then
	       triggers .gmode and rebuilds the whole canvas
	   i.e. two wasted passes per page switch, plus a flash. Now one white fill:
	     - when .mode != 1 the box triggers .gmode (clear canvas + install LCD ISR)
	     - otherwise it is a plain white fill: fast, no flash
	   The white fill also clears zh_box_track's record, so each page starts clean. */
	/* page 3 is the English "clean all": it clears the list area only, keeping the
	   tab bar. In zh, page 0 already cleared everything, so clearing again would
	   wipe the fresh SD/SET/HELP tabs (seen on hardware). Return early. */
	if (page == 3U) return;

	/* The screen clear uses the fast fill (both bit planes per tile); box(M_FILL)
	   is per-pixel .plot: 23,000 calls, about 0.8s per page switch on hardware.
	   Here it is 5,760 byte writes, 20-30ms, and it clears the grey-bg record too. */
	zh_fill_white_rows(0U, 143U);
	color(BLACK, WHITE, SOLID);

	/* All three pages draw the tab bar with zh_tabbar() in 12px (active white,
	   others dark grey). The SD page calls it from list_zh.c (which adds the index). */
	if (page == 1U || page == 2U)
		zh_tabbar(page);
#else
	if(ui_font)		/* mod: the 12px tab strip, list12.c */
	{
		tabs12(page);
		return;
	}
	color(BLACK,WHITE,SOLID);
	line(0,9,159,9);
	line(0,8,159,8);

	if(page==0)
	{
		fill_fast_rect(0U, 0U, 159U, 14U, 0U);

		if(pick_rom)		/* mod: the list is up to pick the fast launch game */
		{
			color(WHITE,BLACK,SOLID);
			Draw_Text(" PICK A ROM ", 12, 0, 0);
			color(BLACK,WHITE,SOLID);
		}
		else
		{
			color(WHITE,BLACK,SOLID)	/* mod: was black on dark gray */;
			Draw_Text(UI_TAB_SD, UI_LEN(UI_TAB_SD), 0, 0);

			color(BLACK,WHITE,SOLID);
			Draw_Text(UI_TAB_SET, UI_LEN(UI_TAB_SET), 4, 0);
			Draw_Text(UI_TAB_HELP, UI_LEN(UI_TAB_HELP), 9, 0);
		}
	}
	else if(page==1)
	{
		fill_fast_rect(0U, 15U, 159U, 143U, 0U);

		color(WHITE,BLACK,SOLID)	/* mod: was black on dark gray */;
		Draw_Text(UI_TAB_SET, UI_LEN(UI_TAB_SET), 4, 0);

		color(BLACK,WHITE,SOLID);
		Draw_Text(UI_TAB_SD, UI_LEN(UI_TAB_SD), 0, 0);
		Draw_Text(UI_TAB_HELP, UI_LEN(UI_TAB_HELP), 9, 0);
	}
	else if(page==2)
	{
		fill_fast_rect(0U, 15U, 159U, 143U, 0U);

		color(WHITE,BLACK,SOLID)	/* mod: was black on dark gray */;
		Draw_Text(UI_TAB_HELP, UI_LEN(UI_TAB_HELP), 9, 0);

		color(BLACK,WHITE,SOLID);
		Draw_Text(UI_TAB_SD, UI_LEN(UI_TAB_SD), 0, 0);
		Draw_Text(UI_TAB_SET, UI_LEN(UI_TAB_SET), 4, 0);
	}
	else if(page==3)
	{
		fill_fast_rect(0U, 15U, 159U, 143U, 0U);
		color(BLACK,WHITE,SOLID);
	}
	else if(page==4)
	{	/* Clear the whole screen including the tab bar (used by the recent list). */
		fill_fast_rect(0U, 0U, 159U, 143U, 0U);
		color(BLACK,WHITE,SOLID);
		line(0,9,159,9);
		line(0,8,159,8);
	}
#endif /* !LANG_ZH */
}


//---------------------------------------------------------------------------------
void Show_reading(void)__banked
{
	/* mod: the small framed box (msgbox.c), where this drew a 91 by 72
	   block of dark gray with the text in it */
	UINT8 t[12];

	strcpy((char *)t, UI_READING);
	msg_box(t);
}
//---------------------------------------------------------------------------------
void Show_loading(void)__banked
{
	/* mod: the small framed box (msgbox.c), where this drew a 91 by 72
	   block of dark gray with the text in it */
	UINT8 t[12];

#ifdef MOD_DBGLOG
	dbg_begin();		/* a debug build lists the launch's stages (msgbox.c) */
#endif
	strcpy((char *)t, UI_LOAD_BUSY);
	msg_box(t);
}
//---------------------------------------------------------------------------------
/* mod: the box the kernel of 2026-11-27 shows while the recent list is written */
void Show_recent(void)__banked
{
	UINT8 t[12];

	strcpy((char *)t, "Recent...");
	msg_box(t);
}
//---------------------------------------------------------------------------------
void Show_Error_file(void)__banked
{
	/* mod: the small framed box (msgbox.c), where this drew a 91 by 72
	   block of dark gray with the text in it */
	UINT8 t[12];

	strcpy((char *)t, UI_ERROR_FILE);
	msg_box(t);
}
//---------------------------------------------------------------------------------
#ifndef LANG_ZH	/* zh draws its own bottom bar in list_zh.c */
void Show_gamelist_BG(void)__banked
{
	color(BLACK,WHITE,SOLID);

	/* box(...,M_FILL) also strokes a border in the foreground colour (black), so the
	   top edge of this white area is box's y1 line (currently 128); the sides at
	   x=0/159 and the bottom at y=143 sit on the screen edge.
	   To erase it, draw UI_BLANK_LINE on row 15:
	       Draw_Text((UINT8*)UI_BLANK_LINE, 20, 0, 15);
	   Note that a "white line" does not work: color() changes the global BGP while
	   the pixels stay inked and turn black again when the palette is restored. */

	line(0,130,159,130);
	line(0,131,159,131);
	//color(BLACK,WHITE,SOLID);
	Draw_Text(UI_BTN_RETURN, UI_LEN(UI_BTN_RETURN), 1, 17);
	Draw_Text(UI_BTN_START, UI_LEN(UI_BTN_START), 11, 17);						
}
#endif	/* !LANG_ZH */