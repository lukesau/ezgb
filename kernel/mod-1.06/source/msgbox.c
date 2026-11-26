/* ============================================================================
   msgbox.c  -  mod: the small status box
   ----------------------------------------------------------------------------
   Reading..., Loading..., Error file and the save load's messages
   (docs/prompts.md "Status boxes"). The kernel as received draws each as a
   91 by 72 pixel block of dark gray with its line of text in the middle;
   this is the 0918 mod's box: 96 pixels wide, only as tall as the text and
   a margin, the text's color on the page's, in a frame of a 2 pixel line,
   a 1 pixel gap and a 1 pixel line.

   The text is centered, and is in the font the list is in.
   ========================================================================== */

#include <gb/gb.h>
#include <gb/drawing.h>
#include <string.h>

#include "ezgb_hw.h"
#include "main.h"
#include "list12.h"
#include "font12.h"

#include "modbank2.h"

/* text is in RAM. Blanks at its end are not counted. */
void msg_box(const UINT8 *text) __banked
{
	UINT8 s[20];
	UINT8 n = (UINT8)strlen((const char *)text);
	UINT8 y0;
	UINT8 y1;

	if(n > 19U) n = 19U;
	while(n && (text[n - 1U] == ' ')) n--;
	memcpy(s, text, n);
	s[n] = 0U;
#ifndef LANG_ZH
	y0 = ui_font ? 52U : 54U;
	y1 = ui_font ? 87U : 81U;
#else
	y0 = 52U;
	y1 = 87U;
#endif
	color(WHITE, WHITE, SOLID);
	box(33, y0, 126, y1, M_FILL);
	color(BLACK, WHITE, SOLID);
	box(33, y0, 126, y1, M_NOFILL);
	box(34, (UINT8)(y0 + 1U), 125, (UINT8)(y1 - 1U), M_NOFILL);
	box(36, (UINT8)(y0 + 3U), 123, (UINT8)(y1 - 3U), M_NOFILL);
#ifndef LANG_ZH
	if(ui_font)
	{
		y0 = font12_end(s, 0U);			/* its width */
		font12_field(s, (UINT8)(80U - (y0 >> 1)), 64U, F12_NORMAL, 122U);
		return;
	}
#endif
	/* 8 pixel cells: an odd length leans half a cell left */
	Draw_Text(s, n, (UINT8)((20U - n) >> 1), 8U);
}

/* BATTERY DRY (docs/prompts.md): the same frame, 112 pixels wide, round two
   lines. It comes up before the settings are read, so it is always in the
   8px font and the light theme's indices. erase takes it off again. */
void battery_box(UINT8 erase) __banked
{
	UINT8 s[13];

	color(WHITE, WHITE, SOLID);
	box(25, 46, 134, 89, M_FILL);
	color(BLACK, WHITE, SOLID);
	if(erase) return;
	box(25, 46, 134, 89, M_NOFILL);
	box(26, 47, 133, 88, M_NOFILL);
	box(28, 49, 131, 86, M_NOFILL);
	memcpy(s, "Battery dry!", 13U);
	Draw_Text(s, 12U, 4U, 7U);
	memcpy(s, "[A] ok", 7U);
	Draw_Text(s, 6U, 7U, 9U);
}

/* The rules of a popup with two buttons (docs/prompts.md): one across it
   above the button row, and one down between the buttons to the box's
   bottom edge at pixel row y1. row is the buttons' text row; xv is where
   the second goes in the 8px font, whose callers space the buttons by
   cells (a 12px font has them at the two ends: list12.c, text12). Called
   after the buttons are drawn, since their row paints over it. */
void popup_rules(UINT8 row, UINT8 y1, UINT8 xv) __banked
{
	UINT8 yr = (UINT8)(row << 3);

#ifndef LANG_ZH
	if(ui_font)
	{
		yr -= 3U;
		xv = 79U;
	}
	else
#endif
	yr -= 5U;
	color(BLACK, WHITE, SOLID);
	line(1, yr, 158, yr);
	line(xv, yr, xv, (UINT8)(y1 - 1U));
	color(BLACK, DKGREY, SOLID);
}

UINT8 pad_take(void);		/* sgb.s */

/* FAST LAUNCH was just ticked (docs/fast-launch.md): how to get the list
   back at power-on. Three lines in the status box's frame, and it waits
   for a press of A. The caller draws its page again. */
void flaunch_box(void) __banked
{
	UINT8 s[15];

	color(WHITE, WHITE, SOLID);
	box(17, 40, 142, 103, M_FILL);
	color(BLACK, WHITE, SOLID);
	box(17, 40, 142, 103, M_NOFILL);
	box(18, 41, 141, 102, M_NOFILL);
	box(20, 43, 139, 100, M_NOFILL);
	memcpy(s, "Hold START at", 14U);
	Draw_Text(s, 13U, 3U, 6U);
	memcpy(s, "boot to cancel", 15U);
	Draw_Text(s, 14U, 3U, 8U);
	memcpy(s, "[A] ok", 7U);
	Draw_Text(s, 6U, 7U, 10U);
	pad_take();
	while(!(pad_take() & J_A)) wait_vbl_done();
}

/* A folder with more entries than the list holds (browser.c): the same
   frame, nearly the screen's width, round two lines, for two seconds. */
void cut_box(void) __banked
{
	UINT8 s[18];

	color(WHITE, WHITE, SOLID);
	box(4, 46, 155, 89, M_FILL);
	color(BLACK, WHITE, SOLID);
	box(4, 46, 155, 89, M_NOFILL);
	box(5, 47, 154, 88, M_NOFILL);
	box(7, 49, 152, 86, M_NOFILL);
	memcpy(s, "Too many files.", 16U);
#ifndef LANG_ZH
	if(ui_font)
	{
		/* inside the frame: text12_center would paint the row across it */
		font12_field(s, (UINT8)(80U - (font12_end(s, 0U) >> 1)), 54U, F12_NORMAL, 150U);
		memcpy(s, "Showing first 416", 18U);
		font12_field(s, (UINT8)(80U - (font12_end(s, 0U) >> 1)), 68U, F12_NORMAL, 150U);
	}
	else
#endif
	{
		Draw_Text(s, 15U, 2U, 7U);
		memcpy(s, "Showing first 416", 18U);
		Draw_Text(s, 17U, 1U, 9U);
	}
	delay(2000);
}
