/* ============================================================================
   list12.c  -  mod: the file list in the 12px font (bank 13)
   ----------------------------------------------------------------------------
   What Show_filename, Refresh_filename and Filename_loop do when the font
   is 12px (ui_font): ten rows of 12 pixels from y 20, under the tab strip,
   each an icon and the name. The selected row is drawn inverted, ink 0 on
   paper 3, which the renderer flushes with plain writes and which reads on
   an original Game Boy. A folder shows by its icon, with no DIR tag, and a
   name is as long as CLEAN NAMES makes it (name_shown, browser.c).
   ========================================================================== */

#include <gb/gb.h>
#include <gb/drawing.h>
#include <string.h>

#include "ezgb_hw.h"
#include "main.h"
#include "ff.h"
#include "font12.h"
#include "ezcfg.h"
#include "list12.h"
#include "plays.h"

extern void fill_fast_rect(UINT8 x0, UINT8 y0, UINT8 x1, UINT8 y1, UINT8 bg) __banked;

#pragma bank 13

extern FM_FILE_FS *pFilename_buffer;
extern UINT16 game_folder_total;
extern void _ultoa(unsigned long value, char *string, unsigned char radix) __banked;

#define LIST_Y		20U
#define ROW_PITCH	12U
#define NAME_MAX	(FONT12_MAX - 2U)	/* characters of a name in one string */

static UINT8 up(UINT8 c)
{
	if((c >= 'a') && (c <= 'z')) return (UINT8)(c - 0x20U);
	return c;
}

/* The record of entry n, with its bank of save RAM mapped */
static FM_FILE_FS *entry(UINT16 n)
{
	HW_BANK = Folder_sram_bank + (UINT8)(n / Num_perBank);
	return &pFilename_buffer[n % Num_perBank];
}

/* The icon for a record, and in *shown the length of its name as drawn
   (name_shown, browser.c) */
static UINT8 icon_of(const FM_FILE_FS *e, UINT8 *shown)
{
	const UINT8 *nm = e->filename;
	UINT8 n = (UINT8)strlen((const char *)nm);

	*shown = name_shown(e);
	if(e->fattrib == AM_DIR) return F12_FOLDER;
	if(e->fattrib == FATTR_STARRED) return F12_STAR;	/* a star in place of the cart (plays.c) */
	if((n > 3U) && (nm[n - 3U] == '.') && (up(nm[n - 2U]) == 'G') && (up(nm[n - 1U]) == 'B')) return F12_GB;
	if((n > 4U) && (nm[n - 4U] == '.') && (up(nm[n - 3U]) == 'G') && (up(nm[n - 2U]) == 'B') &&
	   (up(nm[n - 1U]) == 'C')) return F12_GBC;
	if((n > 4U) && (nm[n - 4U] == '.') && (up(nm[n - 3U]) == 'S') && (up(nm[n - 2U]) == 'A') &&
	   (up(nm[n - 1U]) == 'V')) return F12_SAV;
	return F12_FILE;
}

/* One row: the icon, then the name from character `from`, wrapping round
   with three spaces between the end and the start when the name scrolls */
static void row_draw(UINT16 n, UINT8 line, UINT8 selected, UINT8 from)
{
	UINT8 s[FONT12_MAX + 1U];
	FM_FILE_FS *e = entry(n);
	UINT8 shown;
	UINT8 i;
	UINT8 pos;

	s[0] = icon_of(e, &shown);
	pos = from;
	for(i = 0U; i < NAME_MAX; i++)
	{
		if(pos < shown) s[i + 1U] = e->filename[pos];
		else if(!from) break;				/* not scrolling: the name ends here */
		else if(pos < (UINT8)(shown + 3U)) s[i + 1U] = ' ';
		else
		{
			pos = 0U;
			s[i + 1U] = e->filename[0];
		}
		pos++;
	}
	s[i + 1U] = 0U;
	font12_draw(s, 0U, (UINT8)(LIST_Y + line * ROW_PITCH), selected ? F12_INVERSE : F12_NORMAL);
}

/* The position in the folder, at the right of the tab strip: n/total when
   that fits right of HELP, else n alone */
static void counter(UINT16 n)
{
	UINT8 s[12];
	UINT8 len;
	UINT8 w;

	_ultoa((unsigned long)n + 1UL, (char *)s, 10u);
	len = (UINT8)strlen((char *)s);
	s[len] = '/';
	_ultoa((unsigned long)game_folder_total, (char *)s + len + 1U, 10u);
	w = font12_end(s, 0U);
	if(w > 44U)
	{
		s[len] = 0U;			/* the number alone */
		w = font12_end(s, 0U);
	}
	s[11] = 0U;
	/* clear the field, then the text against the right edge */
	font12_draw((const UINT8 *)"", 116U, 0U, F12_NORMAL);
	font12_draw(s, (UINT8)(160U - w), 0U, F12_NORMAL);
}

/* DrawGB for the 12px font. The strip is the 12 pixel rows from y 0 with a
   two pixel rule under it, and the page starts at y 16. page is DrawGB's:
   0 to 2 draw the strip with that tab inverted (0 clears the strip only, 1
   and 2 the page under it), 3 clears the page and leaves the strip, 4
   clears everything and draws the rule alone. */
void tabs12(UINT8 page) __banked
{
	/* the first label starts at the screen's edge: from x 2 it left two
	   columns of an inverted SD tab unpainted */
	static const UINT8 at[3] = {0U, 30U, 68U};
	UINT8 s[6];
	UINT8 i;

	color(BLACK, WHITE, SOLID);
	if(page == 3U)
	{
		fill_fast_rect(0U, 16U, 159U, 143U, 0U);
		return;
	}
	if(page == 4U) fill_fast_rect(0U, 0U, 159U, 143U, 0U);
	else if(page) fill_fast_rect(0U, 16U, 159U, 143U, 0U);
	fill_fast_rect(0U, 12U, 159U, 13U, acc_idx ? acc_idx : 3U);	/* the rule, in the theme's accent */
	if(page == 4U) return;

	/* each label paints its row to the right edge, so they go left to
	   right, and a blank after the last ends an inverted HELP */
	for(i = 0U; i < 3U; i++)
	{
		if(i == 0U) memcpy(s, " SD ", 5U);
		else if(i == 1U) memcpy(s, " SET ", 6U);
		else memcpy(s, " HELP", 6U);
		font12_draw(s, at[i], 0U, (i == page) ? F12_INVERSE : F12_NORMAL);
	}
	s[0] = ' ';
	s[1] = 0U;
	font12_draw(s, 110U, 0U, F12_NORMAL);
}

void list12_show(UINT16 show_offset, UINT16 file_select) __banked
{
	UINT16 need;
	UINT8 line;

	need = (show_offset >= game_folder_total) ? 0U : (UINT16)(game_folder_total - show_offset);
	if(need > LIST12_ROWS) need = LIST12_ROWS;
	for(line = 0U; line < (UINT8)need; line++)
		row_draw((UINT16)(show_offset + line), line, (line == (UINT8)file_select) ? 1U : 0U, 0U);
	counter((UINT16)(show_offset + file_select));
}

/* The cursor moved one row: updown 2 is down, 3 is up */
void list12_refresh(UINT16 show_offset, UINT16 file_select, UINT8 updown) __banked
{
	UINT8 sel = (UINT8)file_select;
	UINT8 was = (updown == 2U) ? (UINT8)(sel - 1U) : (UINT8)(sel + 1U);

	row_draw((UINT16)(show_offset + was), was, 0U, 0U);
	row_draw((UINT16)(show_offset + sel), sel, 1U, 0U);
	counter((UINT16)(show_offset + sel));
}

/* The selected row's name scrolls when it does not fit: after half a second,
   one character every five frames */
void list12_loop(UINT32 shift, UINT16 show_offset, UINT16 file_select) __banked
{
	static UINT8 last = 0xFFU;
	UINT8 s[FONT12_MAX + 1U];
	FM_FILE_FS *e;
	UINT8 shown;
	UINT8 from;
	UINT8 i;

	if(shift <= 30UL)
	{
		last = 0xFFU;
		return;
	}
	e = entry((UINT16)(show_offset + file_select));
	s[0] = icon_of(e, &shown);
	for(i = 0U; (i < NAME_MAX) && (i < shown); i++) s[i + 1U] = e->filename[i];
	s[i + 1U] = 0U;
	/* it fits when every character was placed: then it stays as it is */
	if((shown <= NAME_MAX) && (font12_fit(s, 0U) == (UINT8)(shown + 1U))) return;

	from = (UINT8)(((shift - 30UL) / 5UL) % (UINT32)(shown + 3U));
	if(from == last) return;
	last = from;
	/* from 0 is the name from its start, which row_draw takes as "not
	   scrolling": the row then ends with the name, which is what it showed
	   before the scroll began */
	row_draw((UINT16)(show_offset + file_select), (UINT8)file_select, 1U, from);
}

/* GBDK's foreground and background color, as ink * 4 + paper (vram_put.s) */
UINT8 draw_colors(void);

/* Draw_Text in the 12px font. The callers lay their text out in 8 pixel
   cells: column x and row y are that cell, and the field is len cells
   wide (17 when len is 0, as Draw_Text pads). The text is 12 pixels tall
   from the top of the row, in the colors color() last set, and what is
   right of the field stays. */
void text12(const UINT8 *s, UINT8 len, UINT8 x, UINT8 y) __banked
{
	UINT8 w = len ? len : 17U;
	UINT8 xe;
	UINT8 py;

	if(x >= 20U) return;
	xe = ((UINT8)(x + w) >= 20U) ? 160U : (UINT8)((x + w) << 3);
	py = (UINT8)(y << 3);
	if(py > 132U) py = 132U;		/* the last row would run off the screen */
	font12_field(s, (UINT8)(x << 3), py, draw_colors(), xe);
}

/* The SET tab's date and time, at row 5: 2026/11/24 16:04:59. t is indexed
   as RTC.h's _SEC to _YEAR, BCD when bcd is set. hot is the field being
   set (0 the year to 5 the seconds), drawn inverted, or $FF.

   Each field has its place and only a field whose number or highlight
   changed is drawn, so the line does not blink as the seconds go by:
   clock12_reset draws the separators and marks every field to be drawn.

   The places are set by hand for the proportional font, whose digits are a
   fixed 7 pixels in 9 and whose slash leans across 6: the slashes and
   colons sit a pixel from the digits each side. The 6 pixel fonts are a
   grid. */
static const UINT8 clk_x12[6] = {0U, 42U, 66U, 90U, 111U, 132U};
static const UINT8 clk_sep12[4] = {35U, 59U, 107U, 128U};
static const UINT8 clk_x6[6] = {0U, 30U, 48U, 66U, 84U, 102U};
static const UINT8 clk_sep6[4] = {24U, 42U, 78U, 96U};
static UINT8 clk_old[6];
static UINT8 clk_hot;

void clock12_reset(void) __banked
{
	const UINT8 *sx = (ui_font == 1U) ? clk_sep12 : clk_sep6;
	UINT8 s[2];
	UINT8 i;

	s[1] = 0U;
	s[0] = 0U;
	font12_draw(s, 0U, 40U, F12_NORMAL);		/* the line, cleared */
	for(i = 0U; i < 4U; i++)
	{
		s[0] = (i < 2U) ? '/' : ':';
		font12_field(s, sx[i], 40U, F12_NORMAL, (UINT8)(sx[i] + 6U));
	}
	for(i = 0U; i < 6U; i++) clk_old[i] = 0xFFU;
	clk_hot = 0xFFU;
}

void clock12(const UINT8 *t, UINT8 bcd, UINT8 hot) __banked
{
	static const UINT8 idx[6] = {6U, 5U, 3U, 2U, 1U, 0U};
	static const UINT8 mask[6] = {0xFFU, 0x1FU, 0x3FU, 0x3FU, 0x7FU, 0x7FU};
	const UINT8 *fx = (ui_font == 1U) ? clk_x12 : clk_x6;
	UINT8 dw = (ui_font == 1U) ? 9U : 6U;		/* a digit's advance */
	UINT8 s[5];
	UINT8 i;
	UINT8 v;
	UINT8 n;

	for(i = 0U; i < 6U; i++)
	{
		v = t[idx[i]];
		if(bcd)
		{
			v &= mask[i];
			v = (UINT8)((v & 0x0FU) + (v >> 4) * 10U);
		}
		if((v == clk_old[i]) && ((i == hot) == (i == clk_hot))) continue;
		clk_old[i] = v;
		n = 0U;
		if(i == 0U)
		{
			s[n++] = '2';
			s[n++] = '0';
		}
		s[n++] = (UINT8)('0' + v / 10U);
		s[n++] = (UINT8)('0' + v % 10U);
		s[n] = 0U;
		/* the field ends where its last digit's ink does */
		font12_field(s, fx[i], 40U, (i == hot) ? F12_INVERSE : F12_NORMAL,
		             (UINT8)(fx[i] + n * dw - ((ui_font == 1U) ? 2U : 0U)));
	}
	clk_hot = hot;
}

/* The recent list in the 12px fonts: Show_recent_list's rows, nine of 12
   pixels from y 20, the selected one inverted. The list holds up to 14, so
   the nine are a window that follows the cursor. The records are full
   paths in the list area's first bank; the name alone is shown. */
void recent12_show(UINT8 count, UINT8 sel) __banked
{
	static UINT8 top;
	UINT8 s[FONT12_MAX + 1U];
	const UINT8 *p;
	const UINT8 *nm;
	UINT8 r;
	UINT8 i;

	if(sel < top) top = sel;
	if(sel >= (UINT8)(top + 9U)) top = (UINT8)(sel - 8U);
	if(top >= count) top = 0U;
	HW_BANK = Folder_sram_bank;
	hw_set_page(A000Address_SRAM);
	for(r = 0U; r < 9U; r++)
	{
		i = (UINT8)(top + r);
		s[0] = 0U;
		if(i < count)
		{
			p = pFilename_buffer[i].filename;
			nm = p;
			while(*p) if(*p++ == '/') nm = p;
			for(i = 0U; (i < (FONT12_MAX - 1U)) && nm[i]; i++) s[i] = nm[i];
			s[i] = 0U;
			i = (UINT8)(top + r);
		}
		font12_draw(s, 0U, (UINT8)(LIST_Y + r * ROW_PITCH), (i == sel) ? F12_INVERSE : F12_NORMAL);
	}
}
