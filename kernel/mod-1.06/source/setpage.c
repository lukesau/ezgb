/* ============================================================================
   setpage.c  -  mod: the SET tab's pages for the mod's settings (bank 4)
   ----------------------------------------------------------------------------
   DOWN from AUTO SAVE on the tab's first page comes here. Each page has up
   to four rows, on text rows 3, 5, 7 and 9: DOWN from a page's last row is
   the next page, UP from its first the one before, and UP from the very
   first row goes back to the tab's first page. SELECT leaves the tab. A
   acts on the row under the cursor, and the setting is written to
   /EZGB.CFG at once (cfg_changed, ezcfg.c).

   A row is a label and either a checkbox or a value: the value is drawn as
   text, in the highlight colors when the cursor is on it.
   ========================================================================== */

#include <gb/gb.h>
#include <gb/drawing.h>
#include <string.h>

#include "ezgb_hw.h"
#include "main.h"
#include "UI.h"
#include "ezcfg.h"
#include "list12.h"

#pragma bank 4

#define PER_PAGE	4U

#define ROW_SKIP	0U	/* page 1: launching */
#define ROW_FAST	1U
#define ROW_GAME	2U
#define ROW_SGB		3U
#define ROW_THEME	4U	/* page 2: the look */
#define ROW_FONT	5U
#define ROW_TAGS	6U
#define ROW_RTCSD	7U
#define ROWS		8U

/* 0 or 1 for a checkbox row */
static UINT8 row_on(UINT8 row)
{
	if(row == ROW_SKIP) return cfg_bootrom ? 0U : 1U;
	if(row == ROW_FAST) return (cfg_flaunch[0] == '/') ? 1U : 0U;
	if(row == ROW_SGB) return sgb_record();
	if(row == ROW_TAGS) return tags_hide;
	return cfg_rtcsd;
}

static void row_act(UINT8 row)
{
	UINT8 n;
	UINT8 what = CFG_OTHER;

	if(row == ROW_SKIP)
	{
		cfg_bootrom ^= 1U;
		what = CFG_BOOTROM;
	}
	else if(row == ROW_FAST)
	{
		n = (UINT8)strlen(cfg_flaunch);
		if(cfg_flaunch[0] == '/')
		{
			if(n >= FLAUNCH_MAX) return;
			memmove(cfg_flaunch + 1, cfg_flaunch, n + 1U);	/* off: a # keeps the path */
			cfg_flaunch[0] = '#';
		}
		else if(cfg_flaunch[0] == '#') memmove(cfg_flaunch, cfg_flaunch + 1, n);
		else if(!cfg_flaunch_last()) return;
	}
	else if(row == ROW_GAME)
	{
		if(!cfg_flaunch_last()) return;		/* the last game launched */
	}
	else if(row == ROW_SGB) what = CFG_SGB;
	else if(row == ROW_THEME)
	{
		/* the next theme; where only BGP can be set there are two */
		cfg_theme = (UINT8)(theme_now() + 1U);
		if(cfg_theme >= (cgb_mode ? THEMES : 2U)) cfg_theme = 0U;
		what = CFG_THEME;
	}
	else if(row == ROW_FONT)
	{
		cfg_ui = cfg_ui ? 0U : 1U;
		what = CFG_FONT;
	}
	else if(row == ROW_TAGS) tags_hide ^= 1U;
	else cfg_rtcsd ^= 1U;
	cfg_changed(what);
}

static void row_draw(UINT8 row, UINT8 sel)
{
	static const char names[THEMES][7] = {"LIGHT", "DARK", "RED", "GREEN", "PURPLE", "BLUE"};
	UINT8 s[21];
	UINT8 trow = (UINT8)(3U + (row % PER_PAGE) * 2U);
	UINT8 y = (UINT8)(trow << 3);
	UINT8 n;
	UINT8 i;
	const char *v;

	if((row == ROW_GAME) || (row == ROW_THEME) || (row == ROW_FONT))
	{
		/* a value, from column 6 for the game and 13 for the others */
		memset(s, ' ', 20U);
		s[20] = 0U;
		if(row == ROW_GAME)
		{
			v = cfg_flaunch;
			n = (UINT8)strlen(v);
			for(i = 0U; i < n; i++) if(cfg_flaunch[i] == '/') v = cfg_flaunch + i + 1U;
			if(!*v) v = "NOT SET";
		}
		else if(row == ROW_THEME) v = names[theme_now()];
#ifdef LANG_ZH
		else v = "12PX";			/* the Chinese build's text is always 12px */
#else
		else v = ui_font_cfg ? "12PX" : "8PX";
#endif
		n = (UINT8)strlen(v);
		if(n > 14U) n = 14U;
		memcpy(s, v, n);
		if(sel) color(BLACK, DKGREY, SOLID);
		else color(BLACK, WHITE, SOLID);
		if(row == ROW_GAME) Draw_Text(s, 14U, 6U, trow);
		else Draw_Text(s, 7U, 13U, trow);
		color(BLACK, WHITE, SOLID);
		return;
	}
	color(WHITE, WHITE, SOLID);
	box(130, y, 138, (UINT8)(y + 8U), M_FILL);
	if(sel) color(DKGREY, DKGREY, SOLID);
	else color(BLACK, WHITE, SOLID);
	box(130, y, 138, (UINT8)(y + 8U), M_NOFILL);
	if(row_on(row))
	{
		color(DKGREY, DKGREY, SOLID);
		box(132, (UINT8)(y + 2U), 136, (UINT8)(y + 6U), M_FILL);
	}
	color(BLACK, WHITE, SOLID);
}

/* Clears the page and draws the labels and rows of the page row is on */
static void page_draw(UINT8 row)
{
	static const char labels[ROWS][15] = {
		"SKIP BOOT ROM:", "FAST LAUNCH:", "GAME:", "SGB BOOT:",
		"THEME:", "FONT:", "CLEAN NAMES:", "RTC SD BACKUP:",
	};
	UINT8 s[16];
	UINT8 first = (UINT8)(row - (row % PER_PAGE));
	UINT8 i;

	DrawGB(1);
	color(BLACK, WHITE, SOLID);
	for(i = first; (i < (UINT8)(first + PER_PAGE)) && (i < ROWS); i++)
	{
		strcpy((char *)s, labels[i]);
		Draw_Text(s, (UINT8)strlen((char *)s), 0U, (UINT8)(3U + (i % PER_PAGE) * 2U));
		row_draw(i, (i == row) ? 1U : 0U);
	}
}

/* Returns 0 to go back to the tab's first page and 1 when SELECT was
   pressed, which leaves the tab. */
UINT8 set_page2(void) __banked
{
	UINT8 row = 0U;
	UINT8 keys;
	UINT8 last;
	UINT8 to;

	page_draw(row);
	/* the DOWN that opened the page is not a press on it */
	while(joypad()) wait_vbl_done();
	last = 0U;
	while(1)
	{
		wait_vbl_done();
		keys = joypad();
		if(keys == last) continue;
		last = keys;
		if(keys & J_SELECT) return 1U;
		to = row;
		if(keys & J_UP)
		{
			if(row == 0U)
			{
				while(joypad()) wait_vbl_done();	/* nor is this UP one on the first page */
				return 0U;
			}
			to = (UINT8)(row - 1U);
		}
		else if(keys & J_DOWN)
		{
			if(row + 1U < ROWS) to = (UINT8)(row + 1U);
		}
		else if(keys & J_A)
		{
			row_act(row);
			/* the font and the theme change the whole page; FAST LAUNCH and
			   the game change each other */
			if(row == ROW_FONT) DrawGB(4);		/* the tab strip is another height */
			if((row == ROW_FONT) || (row == ROW_THEME)) page_draw(row);
			else
			{
				if((row == ROW_FAST) || (row == ROW_GAME))
				{
					row_draw(ROW_FAST, (row == ROW_FAST) ? 1U : 0U);
					row_draw(ROW_GAME, (row == ROW_GAME) ? 1U : 0U);
				}
				else row_draw(row, 1U);
			}
		}
		if(to != row)
		{
			if((to / PER_PAGE) != (row / PER_PAGE)) page_draw(to);
			else
			{
				row_draw(row, 0U);
				row_draw(to, 1U);
			}
			row = to;
		}
	}
}
