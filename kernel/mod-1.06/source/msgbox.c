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

/* the box's line: s is n characters, in RAM */
static void msg_draw(const UINT8 *s, UINT8 n)
{
#ifndef LANG_ZH
	UINT8 w;

	if(ui_font)
	{
		w = font12_end(s, 0U);			/* its width */
		font12_field(s, (UINT8)(80U - (w >> 1)), 64U, F12_NORMAL, 122U);
		return;
	}
#endif
	/* 8 pixel cells: an odd length leans half a cell left */
	Draw_Text(s, n, (UINT8)((20U - n) >> 1), 8U);
}

#ifdef MOD_DBGLOG
/* ---- a make DEBUG=1 build: a launch's stages as a list ----
   From dbg_begin to dbg_end every message of the box is a line of the
   page instead, under the one before, and when the next comes the line
   before gets the time it took, in seconds and tenths by the frame count
   (sys_time: it stands still while interrupts are off). */
#include "UI.h"

static UINT8 dbg_on;
static UINT8 dbg_n;			/* lines so far */
static UINT16 dbg_t0;			/* when the last line was drawn */

#define DBG_LINES	8U

static void dbg_at(const UINT8 *s, UINT8 n, UINT8 col, UINT8 line)
{
	if(ui_font)
	{
		font12_draw(s, (UINT8)(col ? 124U : 2U), (UINT8)(16U + (line << 4)), F12_NORMAL);
		return;
	}
	Draw_Text((UINT8 *)s, n, col, (UINT8)(2U + line));
}

static UINT8 dbg_line(const UINT8 *s, UINT8 n)
{
	UINT8 t[6];
	UINT16 d;

	if(!dbg_on) return 0U;
	color(BLACK, WHITE, SOLID);
	if(dbg_n)
	{
		/* the stage before: frames to tenths of a second */
		d = (UINT16)(sys_time - dbg_t0) / 6U;
		if(d > 999U) d = 999U;
		t[0] = (d >= 100U) ? (UINT8)('0' + d / 100U) : ' ';
		t[1] = (UINT8)('0' + (d / 10U) % 10U);
		t[2] = '.';
		t[3] = (UINT8)('0' + d % 10U);
		t[4] = 0U;
		dbg_at(t, 4U, 15U, (UINT8)(dbg_n - 1U));
	}
	if(dbg_n < DBG_LINES)
	{
		dbg_at(s, n, 0U, dbg_n);
		dbg_n++;
	}
	dbg_t0 = sys_time;
	return 1U;
}

void dbg_begin(void) __banked
{
	DrawGB(3);		/* the page, not the tab strip */
	dbg_on = 1U;
	dbg_n = 0U;
}

void dbg_end(void) __banked
{
	dbg_on = 0U;
}
#endif

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
#ifdef MOD_DBGLOG
	if(dbg_line(s, n)) return;
#endif
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
	msg_draw(s, n);
}

/* Another message in the box that is up: its line is cleared and drawn,
   the frame is left alone, so the box does not blink. */
void msg_text(const UINT8 *text) __banked
{
	UINT8 s[20];
	UINT8 n = (UINT8)strlen((const char *)text);

	if(n > 19U) n = 19U;
	while(n && (text[n - 1U] == ' ')) n--;
	memcpy(s, text, n);
	s[n] = 0U;
#ifdef MOD_DBGLOG
	if(dbg_line(s, n)) return;
#endif
	color(WHITE, WHITE, SOLID);
#ifndef LANG_ZH
	box(38, 64, 121, ui_font ? 75U : 71U, M_FILL);
#else
	box(38, 64, 121, 75, M_FILL);
#endif
	color(BLACK, WHITE, SOLID);
	msg_draw(s, n);
}

/* The rules and the buttons of a two-button popup taken off again, when
   the answer is in and the popup stays up: row and y1 as popup_rules has
   them. */
void popup_rules_clear(UINT8 row, UINT8 y1) __banked
{
	UINT8 yr = (UINT8)(row << 3);

#ifndef LANG_ZH
	if(ui_font) yr -= 3U;
	else
#endif
	yr -= 5U;
	color(WHITE, DKGREY, SOLID);		/* the band's paper, with an outline of the same */
	box(1, yr, 158, (UINT8)(y1 - 1U), M_FILL);
	color(BLACK, DKGREY, SOLID);
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
