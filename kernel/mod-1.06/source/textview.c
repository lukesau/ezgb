/* ============================================================================
   textview.c  -  mod: a read-only viewer for text files
   ----------------------------------------------------------------------------
   docs/text-viewer.md has the 0918 mod's. A on a .txt, .ini, .md or .cfg
   file in the list opens it:

     UP, LEFT            a page back
     DOWN, RIGHT, A      a page on
     B                   back to the list

   The text is in the font the list is in. Lines wrap at the last space
   that fits, or mid-word when a word is longer than a row. CR is dropped,
   TAB is a space, and any other byte outside ASCII shows as '?'. The first
   65,024 bytes of a file are shown, and it pages back through at most 127
   pages.

   The file stays open on the kernel's FIL and is read a sector at a time
   into SD_buffer, the sector that holds the byte wanted.
   ========================================================================== */

#include <gb/gb.h>
#include <gb/drawing.h>
#include <string.h>

#include "ezgb_hw.h"
#include "main.h"
#include "ff.h"
#include "UI.h"
#include "Bank_fun.h"
#include "list12.h"
#include "font12.h"
#include "textview.h"

#include "modbank2.h"

extern UINT8 SD_buffer[0x200];
extern FIL gfil;
extern TCHAR currentpath[];
extern TCHAR currentpath_temp[];

#define SIZE_MAX_TV	65024U
#define PAGES_MAX	127U
#define COLS_MAX	40U

static UINT16 size;
static UINT16 loaded;			/* the offset of the sector in SD_buffer, $FFFF for none */
static UINT16 pages[PAGES_MAX + 1U];

static UINT8 up(UINT8 c)
{
	if((c >= 'a') && (c <= 'z')) return (UINT8)(c - 0x20U);
	return c;
}

/* 1 for a name the viewer opens */
static UINT8 is_text(const char *nm)
{
	UINT8 n = (UINT8)strlen(nm);
	const char *e;

	if(n < 4U) return 0U;
	e = nm + n - 3U;
	if((e[0] == '.') && (up((UINT8)e[1]) == 'M') && (up((UINT8)e[2]) == 'D')) return 1U;
	if(n < 5U) return 0U;
	e--;
	if(e[0] != '.') return 0U;
	if((up((UINT8)e[1]) == 'T') && (up((UINT8)e[2]) == 'X') && (up((UINT8)e[3]) == 'T')) return 1U;
	if((up((UINT8)e[1]) == 'I') && (up((UINT8)e[2]) == 'N') && (up((UINT8)e[3]) == 'I')) return 1U;
	if((up((UINT8)e[1]) == 'C') && (up((UINT8)e[2]) == 'F') && (up((UINT8)e[3]) == 'G')) return 1U;
	return 0U;
}

/* the byte at pos, as the viewer shows it: 0 for one it drops */
static UINT8 at(UINT16 pos)
{
	UINT16 base = pos & 0xFE00U;
	UINT16 got;
	UINT8 c;

	if(base != loaded)
	{
		hw_set_page(A000Address_TF);
		f_lseek_bank(&gfil, (DWORD)base);
		memset(SD_buffer, 0, 0x200U);
		f_read_bank(&gfil, SD_buffer, 0x200U, &got);
		loaded = base;
	}
	c = SD_buffer[pos & 0x1FFU];
	if(c == '\r') return 0U;
	if(c == '\t') return ' ';
	if(c == '\n') return c;
	if((c < 0x20U) || (c > 0x7EU)) return '?';
	return c;
}

/* One row of text from pos into s. Returns where the next row starts. */
static UINT16 row(UINT16 pos, UINT8 *s)
{
	UINT8 n = 0U;
	UINT8 fits;
	UINT8 cut;
	UINT8 c;
	UINT16 p = pos;
	UINT16 after = 0U;			/* past the line's newline, when the row reached it */
	UINT16 ends[COLS_MAX + 1U];

	while((p < size) && (n < COLS_MAX))
	{
		c = at(p);
		p++;
		if(c == '\n')
		{
			after = p;
			break;
		}
		if(c == 0U) continue;
		s[n] = c;
		ends[n] = p;
		n++;
	}
	s[n] = 0U;
	if(n == 0U) return p;
#ifndef LANG_ZH
	fits = ui_font ? font12_fit(s, 0U) : ((n > 20U) ? 20U : n);
#else
	fits = (n > 20U) ? 20U : n;
#endif
	if(fits >= n) return after ? after : p;		/* the row holds all that was read */
	if(fits == 0U) fits = 1U;
	/* back to the last blank that fits, when there is one */
	cut = fits;
	while((cut > 1U) && (s[cut] != ' ') && (s[cut - 1U] != ' ')) cut--;
	if(cut <= 1U) cut = fits;
	s[cut] = 0U;
	p = ends[cut - 1U];
	while((p < size) && (at(p) == ' ')) p++;	/* the blank the row broke at is not shown */
	return p;
}

/* Draws the page that starts at pos. Returns where the next one starts. */
static UINT16 page(UINT16 pos)
{
	UINT8 s[COLS_MAX + 1U];
	UINT8 r;
	UINT8 rows;

	color(BLACK, WHITE, SOLID);
	DrawGB(3);
#ifndef LANG_ZH
	rows = ui_font ? 9U : 15U;
#else
	rows = 15U;
#endif
	for(r = 0U; (r < rows) && (pos < size); r++)
	{
		pos = row(pos, s);
#ifndef LANG_ZH
		if(ui_font) font12_draw(s, 0U, (UINT8)(16U + r * 12U), F12_NORMAL);
		else
#endif
		if(s[0]) Draw_Text(s, 20U, 0U, (UINT8)(2U + r));
	}
	color(BLACK, WHITE, SOLID);
	return pos;
}

/* name is the file's, in the list's folder. 0 when it is not a text file
   or does not open: the caller treats it as it did. Otherwise the file was
   shown, and the caller draws the list again. */
UINT8 text_view(const char *name) __banked
{
	UINT8 pg = 0U;
	UINT8 keys;
	UINT16 next;
	UINT16 n;

	if(!is_text(name)) return 0U;
	n = (UINT16)strlen(currentpath) + (UINT16)strlen(name) + 2U;
	if(n > MAX_path_len) return 0U;
	strcpy(currentpath_temp, currentpath);
	if(currentpath[1]) strcat(currentpath_temp, "/");
	strcat(currentpath_temp, name);
	hw_set_page(A000Address_TF);
	if(f_open_bank(&gfil, currentpath_temp, FA_READ) != FR_OK) return 0U;
	size = (f_size(&gfil) > (DWORD)SIZE_MAX_TV) ? SIZE_MAX_TV : (UINT16)f_size(&gfil);
	loaded = 0xFFFFU;

	while(joypad()) wait_vbl_done();
	pages[0] = 0U;
	while(1)
	{
		next = page(pages[pg]);
		while(1)
		{
			wait_vbl_done();
			keys = joypad();
			if(keys & (J_A | J_B | J_UP | J_DOWN | J_LEFT | J_RIGHT)) break;
		}
		while(joypad()) wait_vbl_done();
		if(keys & J_B) break;
		if(keys & (J_UP | J_LEFT))
		{
			if(pg) pg--;
		}
		else if((next < size) && (pg < PAGES_MAX))
		{
			pg++;
			pages[pg] = next;
		}
	}
	hw_set_page(A000Address_TF);
	f_close_bank(&gfil);
	return 1U;
}
