/* ============================================================================
   setpage.c  -  mod: the SET tab's rows for the mod's settings (bank 4)
   ----------------------------------------------------------------------------
   The tab is three pages, as the 0918 mod's is (docs/set-tab.md), six rows
   to a page, two text rows apart:

     page 1   TIME / SET, the date and time, AUTO SAVE     (Set_window, RTC.c)
              RTC SD BACKUP, FAST LAUNCH, GAME             (here)
     page 2   CLEAN NAMES, SORT BY PLAYS, SGB BOOT, SKIP BOOT ROM, DAILY BACKUP
     page 3   THEME, FONT, and the color picker's BG, TEXT, ACCENT

   The cursor runs down through all of them: DOWN from a page's last row is
   the next page, UP from its first the one before. LEFT and RIGHT change
   the page from any row, and the pages go round. The first three rows
   are EZ Flash's screen, which keeps its own loop; the rest are a list
   here, and Set_window hands the cursor over when it leaves AUTO SAVE
   downward (set_page2) and takes it back when it comes up again. SELECT
   leaves the tab from anywhere. A acts on the row under the cursor, and the
   setting takes effect at once and is written to /EZGB.CFG on a change of
   page or on leaving the tab (cfg_changed and cfg_flush, ezcfg.c).

   A row is a label and either a checkbox or a value, the value drawn as
   text in the highlight colors when the cursor is on it.
   ========================================================================== */

#include <gb/gb.h>
#include <gb/drawing.h>
#include <string.h>

#include "ezgb_hw.h"
#include "main.h"
#include "UI.h"
#include "ezcfg.h"
#include "font12.h"
#include "list12.h"
#include "list12.h"
#include "plays.h"

#pragma bank 4

#define ROW_RTCSD	0U	/* page 1, under EZ Flash's rows */
#define ROW_FAST	1U
#define ROW_GAME	2U
#define ROW_TAGS	3U	/* page 2 */
#define ROW_PLAYS	4U
#define ROW_SGB		5U
#define ROW_SKIP	6U
#define ROW_DAILY	7U
#define ROW_THEME	8U	/* page 3 */
#define ROW_FONT	9U
#define ROW_BG		10U	/* the color picker, where the palettes can be set */
#define ROW_TEXT	11U
#define ROW_ACCENT	12U
#define ROWS		13U

/* how many rows this console has: the picker needs CGB palettes */
#define ROWS_NOW	(cgb_mode ? ROWS : ROW_BG)

static const UINT8 row_page[ROWS] = {0U, 0U, 0U, 1U, 1U, 1U, 1U, 1U, 2U, 2U, 2U, 2U, 2U};
static const UINT8 row_at[ROWS] = {9U, 11U, 13U, 3U, 5U, 7U, 9U, 11U, 3U, 5U, 9U, 11U, 13U};	/* the text row; the picker's heading is page 3's row 7 */

/* 0 or 1 for a checkbox row */
static UINT8 row_on(UINT8 row)
{
	if(row == ROW_SKIP) return cfg_bootrom ? 0U : 1U;
	if(row == ROW_FAST) return (cfg_flaunch[0] != '#') ? 1U : 0U;	/* no game set is on too: a card with one game starts it */
	if(row == ROW_SGB) return sgb_record();
	if(row == ROW_TAGS) return tags_hide;
	if(row == ROW_PLAYS) return plays_sort_on();
	if(row == ROW_DAILY) return cfg_daily;
	return cfg_rtcsd;
}

static UINT8 theme_back;		/* row_act steps THEME: the other way (B) */

static void row_act(UINT8 row)
{
	UINT8 n;
	UINT8 what = CFG_OTHER;

	if(row == ROW_SKIP)
	{
		if(!cfg_skip_ok()) return;	/* nothing to choose: the setting keeps its value */
		cfg_bootrom ^= 1U;
		what = CFG_BOOTROM;
	}
	else if(row == ROW_FAST)
	{
		/* on and off is the # in front of FLAUNCH='s value, whatever is
		   after it: a game, or nothing, which is the card's one game */
		n = (UINT8)strlen(cfg_flaunch);
		if(cfg_flaunch[0] == '#') memmove(cfg_flaunch, cfg_flaunch + 1, n);
		else
		{
			if(n >= FLAUNCH_MAX) return;
			memmove(cfg_flaunch + 1, cfg_flaunch, n + 1U);
			cfg_flaunch[0] = '#';
		}
	}
	else if(row == ROW_SGB)
	{
		if(sgb_auto) return;
		what = CFG_SGB;
	}
	else if(row == ROW_THEME)
	{
		/* the next theme, or with back the one before: light, dark, DV,
		   red, green, purple, blue, custom. Where only BGP can be set there
		   are the first three. Custom needs its colors. */
		static const UINT8 order[THEMES] = {0U, 1U, 7U, 2U, 3U, 4U, 5U, 6U};
		UINT8 count = cgb_mode ? THEMES : 3U;
		UINT8 i;

		for(i = 0U; (i < THEMES) && (order[i] != theme_now()); i++) ;
		if(i >= count) i = 0U;
		do
		{
			if(theme_back) i = i ? (UINT8)(i - 1U) : (UINT8)(count - 1U);
			else i = (i + 1U < count) ? (UINT8)(i + 1U) : 0U;
		}
		while((order[i] == 6U) && !custom_ok);
		cfg_theme = order[i];
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

static UINT8 shown[9];			/* the colors on screen, as cfg_colors_seed gives them */

UINT8 draw_colors(void);		/* vram_put.s */

/* A row that cannot be set is drawn in index 2 and the cursor passes over
   it. DV is black, white and the slim font: its FONT:, BG: and TEXT: rows
   show what it has. SKIP BOOT ROM is one where the console has no choice. */
static UINT8 locked(UINT8 row)
{
	if(row == ROW_SKIP) return cfg_skip_ok() ? 0U : 1U;	/* a console with nothing to choose */
	if(theme_now() != 7U) return 0U;
	return ((row == ROW_FONT) || (row == ROW_BG) || (row == ROW_TEXT)) ? 1U : 0U;
}

/* A value in its box: s right-justified in the cells cells from text
   column col of row trow, in a frame a pixel or two outside them. how is 0
   plain, 1 under the cursor (the highlight), 2 locked. just 0 puts the
   text at the left instead. */
static void boxed(const UINT8 *s, UINT8 col, UINT8 cells, UINT8 trow, UINT8 how, UINT8 just)
{
	UINT8 t[9];
	UINT8 x0 = (UINT8)(col << 3);
	UINT8 xe = (UINT8)((col + cells) << 3);
	UINT8 y = (UINT8)(trow << 3);
	UINT8 n = (UINT8)strlen((const char *)s);
	UINT8 w;

	if(how == 2U) color(DKGREY, WHITE, SOLID);
	else color(BLACK, WHITE, SOLID);
#ifndef LANG_ZH
	if(ui_font) box((UINT8)(x0 - 2U), (UINT8)(y - 1U), (UINT8)(xe + 1U), (UINT8)(y + 12U), M_NOFILL);
	else
#endif
	box((UINT8)(x0 - 2U), (UINT8)(y - 2U), (UINT8)(xe + 1U), (UINT8)(y + 9U), M_NOFILL);
	if(how == 1U) color(SEL_INK, SEL_PAPER, SOLID);
#ifndef LANG_ZH
	if(ui_font)
	{
		/* the field cleared, then the text against its right edge */
		t[0] = 0U;
		font12_field(t, x0, y, draw_colors(), xe);
		w = (UINT8)(xe - x0 - 2U);
		if(just)
		{
			/* its width: the pen's advance can be less than the last
			   glyph needs, so widen until every glyph is placed */
			w = font12_end(s, 0U);
			while((w < (UINT8)(xe - x0)) && (font12_fit(s, (UINT8)(160U - w)) < n)) w++;
			if(w < (UINT8)(xe - x0)) w++;		/* a pixel off the frame */
		}
		font12_field(s, (UINT8)(xe - w), y, draw_colors(), xe);
		color(BLACK, WHITE, SOLID);
		return;
	}
#endif
	if(n > cells) n = cells;
	memset(t, ' ', cells);
	t[cells] = 0U;
	memcpy(just ? t + (cells - n) : t, s, n);
	Draw_Text(t, cells, col, trow);
	color(BLACK, WHITE, SOLID);
}

/* A row of the picker: three boxes, at text columns 8, 12 and 16. hot is
   the channel being set, 3 for the row under the cursor, 4 for neither. */
static void color_draw(UINT8 row, UINT8 hot)
{
	UINT8 s[3];
	UINT8 trow = row_at[row];
	UINT8 c;
	UINT8 v;

	for(c = 0U; c < 3U; c++)
	{
		v = shown[(row - ROW_BG) * 3U + c];
		s[0] = (UINT8)('0' + v / 10U);
		s[1] = (UINT8)('0' + v % 10U);
		s[2] = 0U;
		if(s[0] == '0')
		{
			s[0] = s[1];
			s[1] = 0U;
		}
		boxed(s, (UINT8)(8U + c * 4U), 3U, trow, locked(row) ? 2U : (((hot == c) || (hot == 3U)) ? 1U : 0U), 1U);
	}
}

/* A on a color row (docs/themes.md "The picker"): LEFT and RIGHT pick the
   channel, UP and DOWN change it, A or B ends. Every step applies, so the
   screen is the preview. The first change made in another theme starts
   from that theme's colors and turns the custom theme on. */
static void color_edit(UINT8 row)
{
	UINT8 c = 0U;
	UINT8 keys;
	UINT8 *v;

	if(theme_now() == 7U)
	{
		/* DV: the accent starts from the one on screen, and the custom
		   theme's other two colors are DV's when it has none */
		if(!custom_ok) memcpy(custom_ch, shown, 6U);
		memcpy(custom_ch + 6, shown + 6, 3U);
	}
	else if(theme_now() != 6U) cfg_colors_seed(custom_ch);
	color_draw(row, c);
	while(1)
	{
		wait_vbl_done();
		keys = pad_menu();		/* a held direction repeats after 24 frames, then every 6 */
		if(!keys) continue;
		if(keys & (J_A | J_B)) break;
		if(keys & J_LEFT) c = c ? (UINT8)(c - 1U) : 2U;
		else if(keys & J_RIGHT) c = (c < 2U) ? (UINT8)(c + 1U) : 0U;
		else if(keys & (J_UP | J_DOWN))
		{
			/* a channel stops at 0 and at 31 */
			v = &custom_ch[(row - ROW_BG) * 3U + c];
			if(keys & J_UP)
			{
				if(*v >= 31U) continue;
				(*v)++;
			}
			else
			{
				if(*v == 0U) continue;
				(*v)--;
			}
			cfg_colors_changed();
			cfg_colors_seed(shown);
		}
		else continue;
		color_draw(row, c);
	}
	cfg_changed(CFG_OTHER);			/* COLORS= and THEME=6 to the file */
}

/* The second outline of a checkbox under the cursor, as the 0918 mod's
   SetBox (kernel/mod/src/setbox.c): the pixels right outside the box whose
   top is at pixel row y, in the text's color. The box's frame is in the
   highlight color while the cursor is on it, and that alone is lost on a
   dark background or an original Game Boy. sel 0 takes the outline off.
   Set_window calls this for AUTO SAVE. */
void set_check_ring(UINT8 y, UINT8 sel) __banked
{
	if(sel) color(BLACK, WHITE, SOLID);
	else color(WHITE, WHITE, SOLID);
	box(129, (UINT8)(y - 1U), 139, (UINT8)(y + 9U), M_NOFILL);
	color(BLACK, WHITE, SOLID);
}

/* text for mq_start, which reads it from RAM: a literal here is in this
   bank, not its */
static UINT8 mq_text[32];

static void row_draw(UINT8 row, UINT8 sel)
{
	static const char names[THEMES][7] = {"LIGHT", "DARK", "RED", "GREEN", "PURPLE", "BLUE", "CUSTOM", "DV"};
	UINT8 s[41];
	UINT8 trow = row_at[row];
	UINT8 y = (UINT8)(trow << 3);
	UINT8 n;
	UINT8 i;
	const char *v;

	if(row >= ROW_BG)
	{
		color_draw(row, sel ? 3U : 4U);
		return;
	}
	if((row == ROW_GAME) || (row == ROW_THEME) || (row == ROW_FONT) || ((row == ROW_SGB) && sgb_auto))
	{
		/* a value, from column 6 for the game and 13 for the others */
		memset(s, ' ', 40U);
		s[40] = 0U;
		if(row == ROW_GAME)
		{
			v = cfg_flaunch;
			n = (UINT8)strlen(v);
			for(i = 0U; i < n; i++) if(cfg_flaunch[i] == '/') v = cfg_flaunch + i + 1U;
			if(*v == '#') v++;		/* off with no game: "#" alone */
			/* no game: on, it is the card's one game, if it has just one */
			if(!*v)
			{
				strcpy((char *)mq_text, (cfg_flaunch[0] == '#') ? "NOT SET" : "(AUTO)");
				v = (const char *)mq_text;
			}
			/* 14 cells from column 6, scrolling when the name is longer
			   (modmisc.c, which reads it from RAM) */
			mq_start((const UINT8 *)v, 6U, trow, 14U, sel ? SEL_INK : BLACK, sel ? SEL_PAPER : WHITE);
			color(BLACK, WHITE, SOLID);
			return;
		}
		else if(row == ROW_THEME) v = names[theme_now()];
		else if(row == ROW_SGB) v = "AUTO";		/* our stage1 sends the packets itself */
#ifdef LANG_ZH
		else v = "12PX";			/* the Chinese build's text is always 12px */
#else
		else v = (ui_font_cfg == 2U) ? "EZ-FLASH" : ((ui_font_cfg == 3U) ? "SLIM" : (ui_font_cfg ? "12PX" : "8PX"));
#endif
		n = (UINT8)strlen(v);
		/* 14 cells of the 8px font; a 12px font takes what fits the same
		   pixels, which is more of the name */
		if(n > (ui_font ? 26U : 14U)) n = ui_font ? 26U : 14U;
		memcpy(s, v, n);
		if((row == ROW_THEME) || (row == ROW_FONT))
		{
			s[n] = 0U;
			boxed(s, 12U, 7U, trow, locked(row) ? 2U : sel, 0U);
			return;
		}
		if(sel) color(SEL_INK, SEL_PAPER, SOLID);
		else color(BLACK, WHITE, SOLID);
		Draw_Text(s, 7U, 13U, trow);
		color(BLACK, WHITE, SOLID);
		return;
	}
	set_check_ring(y, sel);
	color(WHITE, WHITE, SOLID);
	box(130, y, 138, (UINT8)(y + 8U), M_FILL);
	if(locked(row))
	{
		/* an empty box in index 2, as its label is */
		color(DKGREY, WHITE, SOLID);
		box(130, y, 138, (UINT8)(y + 8U), M_NOFILL);
		color(BLACK, WHITE, SOLID);
		return;
	}
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

/* The labels and rows of a page, none under the cursor, and its number at
   the foot. Page 0's are drawn under EZ Flash's rows, which are on screen. */
static void rows_draw(UINT8 page)
{
	static const char labels[ROWS][15] = {
		"RTC SD BACKUP:", "FAST LAUNCH:", "GAME:",
		"CLEAN NAMES:", "SORT BY PLAYS:", "SGB BOOT:", "SKIP BOOT ROM:", "DAILY BACKUP:",
		"THEME:", "FONT:", "BG:", "TEXT:", "ACCENT:",
	};
	UINT8 s[16];
	UINT8 i;

	mq_stop();		/* the page before's name */
	color(BLACK, WHITE, SOLID);
	if(page == 2U) cfg_colors_seed(shown);
	for(i = 0U; i < ROWS_NOW; i++)
	{
		if(row_page[i] != page) continue;
		strcpy((char *)s, labels[i]);
		if((i == ROW_SKIP) && locked(i)) color(DKGREY, WHITE, SOLID);
		Draw_Text(s, (UINT8)strlen((char *)s), 0U, row_at[i]);
		color(BLACK, WHITE, SOLID);
		row_draw(i, 0U);
	}
	if((page == 2U) && cgb_mode)
	{
		/* the picker's heading, a letter over each column of boxes */
		memcpy(s, "COLORS:", 8U);
		Draw_Text(s, 7U, 0U, 7U);
		s[1] = 0U;
		for(i = 0U; i < 3U; i++)
		{
			s[0] = (UINT8)"RGB"[i];
			Draw_Text(s, 1U, (UINT8)(9U + i * 4U), 7U);
		}
	}
	/* the page, between arrows for what LEFT and RIGHT do. They are not
	   buttons: the cursor never goes there. */
	memcpy(s, "<  1/3  >", 10U);
	s[3] = (UINT8)('1' + page);
#ifndef LANG_ZH
	if(ui_font) text12_center(s, 128U);	/* by its width, not by cells */
	else
#endif
	Draw_Text(s, 9U, 5U, 16U);
}

/* Page 2 or 3 on a cleared page. The tab strip is left as it is: drawn
   again at each change of page it showed. The Chinese build's DrawGB has
   no call that clears the page alone. */
static void page_draw(UINT8 page)
{
#ifdef LANG_ZH
	DrawGB(1);
#else
	DrawGB(3);
#endif
	rows_draw(page);
}

/* The same with the strip, after a change that cleared it */
static void page_draw_all(UINT8 page)
{
	DrawGB(1);
	rows_draw(page);
}

/* Set_window calls this when it has drawn its page: the mod's rows of page 1 */
void set_page1_rows(void) __banked
{
	rows_draw(0U);
}

#ifndef LANG_ZH
/* The clock keeps time while the cursor is in the mod's rows of page 1 */
static void clock_tick(void)
{
	UINT8 t[7];
	UINT8 i;

	if(!ui_font) return;		/* the 8px clock is Set_window's, and waits for it */
	hw_set_page(A000Address_RTC);
	for(i = 0U; i < 7U; i++) t[i] = *((volatile UINT8 *)(Base_RTCbuffer + 8U + i));
	hw_set_page(A000Address_TF);
	clock12(t, 1U, 0xFFU);
}
#endif

/* The cursor is in the mod's rows, on row start: 0 when Set_window sends it
   down from AUTO SAVE, with page 1 on screen. Returns
     0  UP left the first row: back to AUTO SAVE, page 1 still on screen
     1  SELECT: leave the tab
     2  UP left page 2: Set_window draws page 1 and calls again with start
        SET_RESUME, its last row
     3  LEFT or RIGHT came round to page 1: Set_window draws it, the cursor
        on its first row
     4  START: back to the SD tab
     5  A on GAME: pick_rom is set, and the list comes up to pick from
     6  FAST LAUNCH was ticked and its notice shown: Set_window draws
        page 1 and calls again with start 1, that row */
static UINT8 page2_loop(UINT8 start)
{
	UINT8 row = start;
	UINT8 keys;
	UINT8 to;

	if(row_page[row]) page_draw(row_page[row]);	/* LEFT or RIGHT on page 1 came straight here */
	row_draw(row, 1U);
	/* the DOWN that brought the cursor here goes on repeating if it is
	   held (pad_menu); a button is only ever one press */
	while(1)
	{
		wait_vbl_done();
		mq_step();		/* the game's name */
#ifndef LANG_ZH
		if(row_page[row] == 0U) clock_tick();
#endif
		keys = pad_menu();		/* a held direction repeats; a button is one press */
		if(!keys) continue;
		if(keys & J_SELECT) return 1U;
		if(keys & J_START)
		{
			while(joypad() & J_START) wait_vbl_done();
			return 4U;
		}
		to = row;
		if(keys & J_UP)
		{
			if(row == 0U)
			{
				row_draw(row, 0U);
				while(joypad()) wait_vbl_done();	/* nor is this UP one for AUTO SAVE */
				return 0U;
			}
			to = (UINT8)(row - 1U);
			while(locked(to)) to--;		/* THEME: is never locked */
		}
		else if(keys & J_DOWN)
		{
			if(row + 1U < ROWS_NOW) to = (UINT8)(row + 1U);
			while(locked(to) && (to + 1U < ROWS_NOW)) to++;
			if(locked(to)) to = row;
		}
		else if(keys & (J_LEFT | J_RIGHT))
		{
			/* the page before or the next one, round and round: its first
			   row, which on page 1 is Set_window's TIME SET */
			to = (UINT8)((row_page[row] + ((keys & J_RIGHT) ? 1U : 2U)) % 3U);
			if(to == 0U)
			{
				while(joypad()) wait_vbl_done();
				return 3U;
			}
			to = (to == 1U) ? SET_PAGE2 : SET_PAGE3;
		}
		else if((keys & J_A) && (row == ROW_GAME))
		{
			pick_rom = 1U;			/* the list comes up to take a game from (sdlist.c) */
			return 5U;
		}
		else if((keys & J_B) && (row == ROW_THEME))
		{
			theme_back = 1U;
			row_act(row);
			theme_back = 0U;
			DrawGB(4);
			page_draw_all(2U);
			row_draw(row, 1U);
		}
		else if((keys & J_A) && (row >= ROW_BG))
		{
			color_edit(row);
			pad_take();			/* the picker's presses are not this page's */
			page_draw_all(2U);		/* the whole page is in the new colors */
			row_draw(row, 1U);
		}
		else if(keys & J_A)
		{
			row_act(row);
			/* the font and the theme change the whole page; FAST LAUNCH and
			   the game change each other */
			if((row == ROW_FONT) || (row == ROW_THEME)) DrawGB(4);	/* the tab strip is another height, and DV has its font */
			if((row == ROW_FONT) || (row == ROW_THEME))
			{
				page_draw_all(2U);
				row_draw(row, 1U);
			}
			else if((row == ROW_FAST) && row_on(ROW_FAST))
			{
				/* just ticked: how to get the list back at power-on, and
				   then page 1 again with the cursor here */
				flaunch_box();
				return 6U;
			}
			else if(row == ROW_SGB)
			{
				/* SKIP BOOT ROM may have become, or stopped being, a choice */
				page_draw(1U);
				row_draw(row, 1U);
			}
			else if((row == ROW_FAST) || (row == ROW_GAME))
			{
				row_draw(ROW_FAST, (row == ROW_FAST) ? 1U : 0U);
				row_draw(ROW_GAME, (row == ROW_GAME) ? 1U : 0U);
			}
			else row_draw(row, 1U);
		}
		if(to != row)
		{
			if(row_page[to] != row_page[row])
			{
				if(row_page[to] == 0U) return 2U;	/* page 1 is Set_window's to draw */
				cfg_flush();		/* a change of page: the settings to the file */
				page_draw(row_page[to]);
			}
			else row_draw(row, 0U);
			row = to;
			row_draw(row, 1U);
		}
	}
}

/* The settings go to the file when the cursor leaves the mod's rows, for
   another tab, the list or EZ Flash's rows (cfg_flush, ezcfg.c) */
UINT8 set_page2(UINT8 start) __banked
{
	UINT8 r = page2_loop(start);

	cfg_flush();
	return r;
}
