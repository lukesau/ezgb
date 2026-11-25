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
