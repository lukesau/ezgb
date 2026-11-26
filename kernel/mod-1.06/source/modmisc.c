/* ============================================================================
   modmisc.c  -  mod: small routines moved out of bank 0
   ----------------------------------------------------------------------------
   get_fattime (from diskio.c) and _ultoa (from main.c), as they were but
   for __banked: bank 0 is where everything every bank calls has to be, and
   it is full. Neither is called often enough for the bank switch to show.
   ========================================================================== */

#include <gb/gb.h>
#include <string.h>

#include "ezgb_hw.h"
#include "main.h"
#include "ff.h"
#include "RTC.h"
#include "list12.h"
#include "font12.h"
#include <gb/drawing.h>

#include "modbank.h"

DWORD get_fattime (void) __banked
{
		UINT8 datetime[7];
		hw_set_page(A000Address_RTC);//read RTC	OS mode	
		datetime[_SEC] = *((volatile UINT8 *)(Base_RTCbuffer+8));//Seconds_re
		datetime[_MIN] = *((volatile UINT8 *)(Base_RTCbuffer+9));//Minutes_re
		datetime[_HOUR] = *((volatile UINT8 *)(Base_RTCbuffer+0xA));//Hours_re
		datetime[_DAY] = *((volatile UINT8 *)(Base_RTCbuffer+0xB));//Days_re
		datetime[_WKD] = *((volatile UINT8 *)(Base_RTCbuffer+0xC));//Weekdays_re
		datetime[_MONTH] = *((volatile UINT8 *)(Base_RTCbuffer+0xD));//Century_months_re
		datetime[_YEAR] = *((volatile UINT8 *)(Base_RTCbuffer+0xE));//Years_re					
		hw_set_page(A000Address_TF);		
		/* Mask the high bits first, as RTC.c does when displaying the time:
		        sec  bit7 = CH (clock halt); 0x80 becomes 80 via UNBCD and 80>>1 = 40 > 29
		        min  normally 0-59; a bad value <<5 overflows into the hour field
		        month bit7 = century; 0x91 becomes 91 via UNBCD and <<21 overflows the year
		   Without the mask, new/updated save files get wrong timestamps (no data loss,
		   but time-ordered listings look wrong). */
		return ((DWORD)(UNBCD(datetime[_YEAR]  & 0x7F)+20) << 25
		      | (DWORD)UNBCD(datetime[_MONTH] & 0x1F) << 21
		      | (DWORD)UNBCD(datetime[_DAY]   & 0x3F) << 16
		      | (DWORD)UNBCD(datetime[_HOUR]  & 0x3F) << 11
		      | (DWORD)UNBCD(datetime[_MIN]   & 0x7F) <<  5
		      | (DWORD)(UNBCD(datetime[_SEC]  & 0x7F) >> 1));
}

void _ultoa(unsigned long value, char *string, unsigned char radix) __banked
{
	char tmp[33];

	unsigned long i;
	char *sp;	
	char *tp = tmp;	
	unsigned long v = value;

	while (v || tp == tmp)
	{
		i = v % radix;
		v = v / radix;
		if (i < 10)
		*tp++ = i+'0';
		else
		*tp++ = i + 'a' - 10;
	}	

	sp = string;
	
	while (tp > tmp)
	*sp++ = *--tp;
	*sp = 0;

}

UINT8 pad_take(void);		/* sgb.s */
UINT8 draw_colors(void);	/* vram_put.s */

/* A menu's keys (ezcfg.h): the directions held, with a repeat timed in
   frames, and the buttons pressed since the last call. */
UINT8 pad_menu(void) __banked
{
	static UINT8 dir;
	static UINT8 t;
	static UINT8 wait;
	UINT8 d = joypad() & 0x0FU;
	UINT8 out = pad_take() & 0xF0U;

	if(!d)
	{
		dir = 0U;
		return out;
	}
	if(d != dir)
	{
		dir = d;
		t = (UINT8)sys_time;
		wait = 24U;
		return (UINT8)(out | d);
	}
	if((UINT8)((UINT8)sys_time - t) >= wait)
	{
		t = (UINT8)sys_time;
		wait = 6U;
		return (UINT8)(out | d);
	}
	return out;
}

/* ---- a name that scrolls in its field ---- */

/* One name at a time (docs/marquee.md has the 0918 mod's): the rom menu's,
   the save manager's, the save prompt's and the SET tab's. A name that
   does not fit its field holds for 60 frames, then moves a character every
   20, and starts again after three blanks.

   mq_start draws s in the field: cells 8 pixel cells from column x of row
   row, in ink on paper. s has to stay where it is, in RAM. mq_step is for
   once a frame while the name is up. In a 12px font the field is the same
   pixels and holds what the font places in them. The Chinese build draws
   the start of the name and does not scroll: a step could cut a character
   of two bytes in half. */
static const UINT8 *mq_s;
static UINT8 mq_len;
static UINT8 mq_pos;
static UINT8 mq_tick;
static UINT8 mq_x;
static UINT8 mq_row;
static UINT8 mq_cells;
static UINT8 mq_ink;
static UINT8 mq_paper;
static UINT8 mq_scrolls;

static void mq_draw(void)
{
	UINT8 b[27];
	UINT8 cols = mq_cells;
	UINT8 pos = mq_pos;
	UINT8 i;

#ifndef LANG_ZH
	if(ui_font) cols = 26U;
#endif
	if(cols > 26U) cols = 26U;
	for(i = 0U; i < cols; i++)
	{
		if(pos < mq_len) b[i] = mq_s[pos];
		else if(!mq_scrolls || (pos < (UINT8)(mq_len + 3U))) b[i] = ' ';
		else
		{
			pos = 0U;
			b[i] = mq_s[0];
		}
		pos++;
	}
	b[cols] = 0U;
	color(mq_ink, mq_paper, SOLID);
#ifndef LANG_ZH
	if(ui_font) font12_field(b, (UINT8)(mq_x << 3), (UINT8)(mq_row << 3), draw_colors(),
	                         (UINT8)((mq_x + mq_cells) << 3));
	else
#endif
	Draw_Text(b, mq_cells, mq_x, mq_row);
}

void mq_start(const UINT8 *s, UINT8 x, UINT8 row, UINT8 cells, UINT8 ink, UINT8 paper) __banked
{
	UINT16 n = (UINT16)strlen((const char *)s);

	mq_s = s;
	mq_len = (n > 250U) ? 250U : (UINT8)n;
	mq_pos = 0U;
	mq_tick = 0U;
	mq_x = x;
	mq_row = row;
	mq_cells = cells;
	mq_ink = ink;
	mq_paper = paper;
#ifdef LANG_ZH
	mq_scrolls = 0U;
#else
	if(ui_font) mq_scrolls = (font12_fit(s, (UINT8)(160U - (cells << 3))) < mq_len) ? 1U : 0U;
	else mq_scrolls = (mq_len > cells) ? 1U : 0U;
#endif
	mq_draw();
}

void mq_step(void) __banked
{
	if(!mq_scrolls) return;
	if(++mq_tick < (mq_pos ? 20U : 60U)) return;
	mq_tick = 0U;
	if(++mq_pos >= (UINT8)(mq_len + 3U)) mq_pos = 0U;
	mq_draw();
}

/* Nothing scrolls until the next mq_start: the screen is another's now */
void mq_stop(void) __banked
{
	mq_scrolls = 0U;
}
