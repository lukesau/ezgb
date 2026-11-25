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
#include "plays.h"

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
#define ROW_PLAYS	8U	/* page 3 */
#define ROW_DAILY	9U
#define ROW_BG		12U	/* page 4: the color picker, where the palettes can be set */
#define ROW_TEXT	13U
#define ROW_ACCENT	14U
#define ROWS		15U	/* rows 10 and 11 are not rows: they end page 3 */

/* how many rows this console has: the picker needs CGB palettes */
#define ROWS_NOW	(cgb_mode ? ROWS : 10U)

/* 0 or 1 for a checkbox row */
static UINT8 row_on(UINT8 row)
{
	if(row == ROW_SKIP) return cfg_bootrom ? 0U : 1U;
	if(row == ROW_FAST) return (cfg_flaunch[0] == '/') ? 1U : 0U;
	if(row == ROW_SGB) return sgb_record();
	if(row == ROW_TAGS) return tags_hide;
	if(row == ROW_PLAYS) return plays_sort_on();
	if(row == ROW_DAILY) return cfg_daily;
	return cfg_rtcsd;
}

static void row_act(UINT8 row)
{
	UINT8 n;
	UINT8 what = CFG_OTHER;

	if(row == ROW_SKIP)
	{
		if(!cfg_can_jump) return;	/* nothing to choose: the setting keeps its value */
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
	else if(row == ROW_SGB)
	{
		if(sgb_auto) return;
		what = CFG_SGB;
	}
	else if(row == ROW_THEME)
	{
		/* the next theme; where only BGP can be set there are two */
		cfg_theme = (UINT8)(theme_now() + 1U);
		if((cfg_theme == 6U) && !custom_ok) cfg_theme = 7U;	/* custom needs a COLORS= line */
		if(cfg_theme >= (cgb_mode ? THEMES : 2U)) cfg_theme = 0U;
		what = CFG_THEME;
	}
	else if(row == ROW_FONT)
	{
		/* 8PX, 12PX, SLIM, EZF and round again */
		cfg_ui = (cfg_ui >= 3U) ? 0U : (UINT8)(cfg_ui + 1U);
		what = CFG_FONT;
	}
	else if(row == ROW_TAGS) tags_hide ^= 1U;
	else if(row == ROW_DAILY) cfg_daily ^= 1U;
	else if(row == ROW_PLAYS)
	{
		plays_sort_set(plays_sort_on() ? 0U : 1U);	/* its record and /.ezgbplays, not the settings file */
		return;
	}
	else cfg_rtcsd ^= 1U;
	cfg_changed(what);
}

/* A color row: its three channels, 0 to 31, at columns 8, 11 and 14. hot
   is the channel being set (inverted), 3 for the row under the cursor, 4
   for neither. */
static UINT8 shown[9];			/* the colors on screen, as cfg_colors_seed gives them */

static void color_draw(UINT8 row, UINT8 hot)
{
	UINT8 s[3];
	UINT8 trow = (UINT8)(3U + (row % PER_PAGE) * 2U);
	UINT8 c;
	UINT8 v;

	for(c = 0U; c < 3U; c++)
	{
		v = shown[(row - ROW_BG) * 3U + c];
		s[0] = (UINT8)('0' + v / 10U);
		s[1] = (UINT8)('0' + v % 10U);
		s[2] = 0U;
		if(hot == c) color(WHITE, BLACK, SOLID);
		else if(hot == 3U) color(BLACK, DKGREY, SOLID);
		else color(BLACK, WHITE, SOLID);
		Draw_Text(s, 2U, (UINT8)(8U + c * 3U), trow);
	}
	color(BLACK, WHITE, SOLID);
}

/* A on a color row (docs/themes.md "The picker"): LEFT and RIGHT pick the
   channel, UP and DOWN change it, A or B ends. Every step applies, so the
   screen is the preview. The first change made in another theme starts
   from that theme's colors and turns the custom theme on. */
static void color_edit(UINT8 row)
{
	UINT8 c = 0U;
	UINT8 keys;
	UINT8 last = 0xFFU;
	UINT8 held = 0U;
	UINT8 *v;

	if(theme_now() != 6U) cfg_colors_seed(custom_ch);
	while(joypad()) wait_vbl_done();
	color_draw(row, c);
	while(1)
	{
		wait_vbl_done();
		keys = joypad();
		if(keys == last)
		{
			/* a held UP or DOWN repeats, six frames apart */
			if(!(keys & (J_UP | J_DOWN)) || (++held < 6U)) continue;
		}
		held = 0U;
		last = keys;
		if(keys & (J_A | J_B)) break;
		if(keys & J_LEFT) c = c ? (UINT8)(c - 1U) : 2U;
		else if(keys & J_RIGHT) c = (c < 2U) ? (UINT8)(c + 1U) : 0U;
		else if(keys & (J_UP | J_DOWN))
		{
			v = &custom_ch[(row - ROW_BG) * 3U + c];
			if(keys & J_UP) *v = (*v < 31U) ? (UINT8)(*v + 1U) : 0U;
			else *v = *v ? (UINT8)(*v - 1U) : 31U;
			cfg_colors_changed();
			cfg_colors_seed(shown);
		}
		else continue;
		color_draw(row, c);
	}
	while(joypad()) wait_vbl_done();
	cfg_changed(CFG_OTHER);			/* COLORS= and THEME=6 to the file */
}

static void row_draw(UINT8 row, UINT8 sel)
{
	static const char names[THEMES][7] = {"LIGHT", "DARK", "RED", "GREEN", "PURPLE", "BLUE", "CUSTOM", "DV"};
	UINT8 s[21];
	UINT8 trow = (UINT8)(3U + (row % PER_PAGE) * 2U);
	UINT8 y = (UINT8)(trow << 3);
	UINT8 n;
	UINT8 i;
	const char *v;

	if(row >= ROW_BG)
	{
		color_draw(row, sel ? 3U : 4U);
		return;
	}
	if((row == ROW_GAME) || (row == ROW_THEME) || (row == ROW_FONT) || ((row == ROW_SGB) && sgb_auto) ||
	   ((row == ROW_SKIP) && !cfg_can_jump))
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
		else if(row == ROW_SGB) v = "AUTO";		/* our stage1 sends the packets itself */
		else if(row == ROW_SKIP) v = "N/A";		/* this console resets into every game */
#ifdef LANG_ZH
		else v = "12PX";			/* the Chinese build's text is always 12px */
#else
		else v = (ui_font_cfg == 2U) ? "EZF" : ((ui_font_cfg == 3U) ? "SLIM" : (ui_font_cfg ? "12PX" : "8PX"));
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
		"SORT BY PLAYS:", "DAILY BACKUP:", "", "",
		"BG:", "TEXT:", "ACCENT:",
	};
	UINT8 s[16];
	UINT8 first = (UINT8)(row - (row % PER_PAGE));
	UINT8 i;

	DrawGB(1);
	color(BLACK, WHITE, SOLID);
	if(first >= ROW_BG) cfg_colors_seed(shown);
	for(i = first; (i < (UINT8)(first + PER_PAGE)) && (i < ROWS_NOW); i++)
	{
		if((i == 10U) || (i == 11U)) continue;
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
			if(row + 1U < ROWS_NOW) to = (UINT8)(row + 1U);
		}
		/* rows 10 and 11 are the empty end of page 3 */
		if((to == 10U) || (to == 11U)) to = (keys & J_UP) ? ROW_DAILY : ((ROWS_NOW > 10U) ? ROW_BG : row);
		else if((keys & J_A) && (row >= ROW_BG))
		{
			color_edit(row);
			page_draw(row);			/* the whole page is in the new colors */
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
		if((to >= ROWS_NOW) || (to == 10U) || (to == 11U)) to = row;
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
