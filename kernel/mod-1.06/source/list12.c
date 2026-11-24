/* ============================================================================
   list12.c  -  mod: the file list in the 12px font (bank 8)
   ----------------------------------------------------------------------------
   What Show_filename, Refresh_filename and Filename_loop do when the font
   is 12px (ui_font): ten rows of 12 pixels from y 20, under the tab strip,
   each an icon and the name. The selected row is drawn inverted, ink 0 on
   paper 3, which the renderer flushes with plain writes and which reads on
   an original Game Boy. A folder shows by its icon, with no DIR tag, and a
   .gb or .gbc shows without its ending.
   ========================================================================== */

#include <gb/gb.h>
#include <gb/drawing.h>
#include <string.h>

#include "ezgb_hw.h"
#include "main.h"
#include "ff.h"
#include "font12.h"
#include "list12.h"

extern void fill_fast_rect(UINT8 x0, UINT8 y0, UINT8 x1, UINT8 y1, UINT8 bg) __banked;

#pragma bank 8

extern FM_FILE_FS *pFilename_buffer;
extern UINT16 game_folder_total;
extern void _ultoa(unsigned long value, char *string, unsigned char radix);

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

/* The icon for a record, and in *shown the length of the name without a
   .gb or .gbc ending */
static UINT8 icon_of(const FM_FILE_FS *e, UINT8 *shown)
{
	const UINT8 *nm = e->filename;
	UINT8 n = (UINT8)strlen((const char *)nm);

	*shown = n;
	if(e->fattrib == AM_DIR) return F12_FOLDER;
	if((n > 3U) && (nm[n - 3U] == '.') && (up(nm[n - 2U]) == 'G') && (up(nm[n - 1U]) == 'B'))
	{
		*shown = (UINT8)(n - 3U);
		return F12_GB;
	}
	if((n > 4U) && (nm[n - 4U] == '.') && (up(nm[n - 3U]) == 'G') && (up(nm[n - 2U]) == 'B') &&
	   (up(nm[n - 1U]) == 'C'))
	{
		*shown = (UINT8)(n - 4U);
		return F12_GBC;
	}
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

/* The position in the folder, at the right of the tab strip */
static void counter(UINT16 n)
{
	UINT8 s[8];

	_ultoa((unsigned long)n + 1UL, (char *)s, 10u);
	font12_draw(s, 128U, 0U, F12_NORMAL);
}

/* DrawGB for the 12px font. The strip is the 12 pixel rows from y 0 with a
   two pixel rule under it, and the page starts at y 16. page is DrawGB's:
   0 to 2 draw the strip with that tab inverted (0 clears the strip only, 1
   and 2 the page under it), 3 clears the page and leaves the strip, 4
   clears everything and draws the rule alone. */
void tabs12(UINT8 page) __banked
{
	static const UINT8 at[3] = {2U, 30U, 68U};
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
	fill_fast_rect(0U, 12U, 159U, 13U, 3U);
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
