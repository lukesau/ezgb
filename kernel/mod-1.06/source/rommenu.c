/* ============================================================================
   rommenu.c  -  mod: hold A on a game for its options (bank 4)
   ----------------------------------------------------------------------------
   docs/rom-menu.md has the 0918 mod's. A tap of A on a .gb or .gbc starts
   it, as before, when A comes up. A held for half a second opens a menu
   for that game instead:

     <the whole name>          on an inverted band; scrolls when too long
     > Start
       Manage saves            savemgr.c
       Star                    Unstar for a starred game (plays.c)
       Fast launch: NO         YES when this is the game power-on starts
     [B]back          [A]ok

   Nothing is spare in the list (SELECT is the tabs, START the recent
   list), so the menu has to come from a hold, and until A comes up a tap
   and a hold look the same: a tap is delayed by its own length.

   An A that was already down at the list's poll before this one is not a
   press on this row: it is what opened the folder, still held. It is
   ignored until it is let go.
   ========================================================================== */

#include <gb/gb.h>
#include <gb/drawing.h>
#include <string.h>

#include "ezgb_hw.h"
#include "main.h"
#include "ff.h"
#include "UI.h"
#include "Bank_fun.h"
#include "ezcfg.h"
#include "rommenu.h"
#include "savemgr.h"
#include "plays.h"
#include "textview.h"
#include "list12.h"
#include "font12.h"

#pragma bank 4

extern FM_FILE_FS *pFilename_buffer;
extern TCHAR currentpath[];
extern UINT8 pad_prev;			/* sgb.s: the joypad read before the last one */

#define HOLD_FRAMES	30U
#define NAME_COLS	18U		/* the band, in 8 pixel cells */
#define NAME_MAX12	26U		/* characters a 12px font can put in it */
#define ITEMS		4U

static UINT8 up(UINT8 c)
{
	if((c >= 'a') && (c <= 'z')) return (UINT8)(c - 0x20U);
	return c;
}

static UINT8 is_rom(const UINT8 *nm)
{
	UINT8 n = (UINT8)strlen((const char *)nm);

	if((n > 3U) && (nm[n - 3U] == '.') && (up(nm[n - 2U]) == 'G') && (up(nm[n - 1U]) == 'B')) return 1U;
	if((n > 4U) && (nm[n - 4U] == '.') && (up(nm[n - 3U]) == 'G') && (up(nm[n - 2U]) == 'B') &&
	   (up(nm[n - 1U]) == 'C')) return 1U;
	return 0U;
}

/* The game's whole path into dst (FLAUNCH_MAX + 1 bytes), with a # in
   front when lead is set. 0 when it does not fit. */
static UINT8 path_of(const char *name, char *dst, UINT8 lead)
{
	UINT16 n = (UINT16)strlen(currentpath) + (UINT16)strlen(name) + 1U + lead;

	if(n > FLAUNCH_MAX) return 0U;
	dst[0] = '#';
	strcpy(dst + lead, currentpath);
	if(currentpath[1]) strcat(dst, "/");		/* the root is "/" already */
	strcat(dst, name);
	return 1U;
}

/* 1 when name is the fast launch game, whether fast launch is on or off
   (a # in front of the path) */
static UINT8 is_flaunch(const char *name)
{
	char p[FLAUNCH_MAX + 1U];

	if(!path_of(name, p, 0U)) return 0U;
	return strcmp(p, cfg_flaunch + ((cfg_flaunch[0] == '#') ? 1U : 0U)) ? 0U : 1U;
}

static void item_draw(UINT8 i, UINT8 sel, const char *name)
{
	UINT8 s[20];

	memset(s, ' ', 19U);
	s[19] = 0U;
	s[0] = sel ? '>' : ' ';
	if(i == 0U) memcpy(s + 2, "Start", 5U);
	else if(i == 1U) memcpy(s + 2, "Manage saves", 12U);
	else if(i == 2U) memcpy(s + 2, star_query((const UINT8 *)name) ? "Unstar" : "Star  ", 6U);
	else
	{
		memcpy(s + 2, "Fast launch: ", 13U);
		/* the game it is, with FAST LAUNCH off on the SET tab, reads OFF */
		memcpy(s + 15, is_flaunch(name) ? ((cfg_flaunch[0] == '/') ? "YES" : "OFF") : "NO ", 3U);
	}
	color(BLACK, DKGREY, SOLID);
	Draw_Text(s, 18U, 1U, (UINT8)(7U + i * 2U));
}

static UINT8 name_scrolls;		/* the name does not fit its band */

/* The name on its band, from character `from`, wrapping with a gap */
static void name_draw(const char *name, UINT8 len, UINT8 from)
{
	UINT8 s[NAME_MAX12 + 1U];
	UINT8 cols = ui_font ? NAME_MAX12 : NAME_COLS;
	UINT8 i;
	UINT8 pos = from;

	for(i = 0U; i < cols; i++)
	{
		if(pos < len) s[i] = (UINT8)name[pos];
		else if(!name_scrolls || (pos < (UINT8)(len + 3U))) s[i] = ' ';
		else
		{
			pos = 0U;
			s[i] = (UINT8)name[0];
		}
		pos++;
	}
	s[cols] = 0U;
	color(WHITE, BLACK, SOLID);
#ifndef LANG_ZH
	if(ui_font) text12(s, NAME_COLS, 1U, 5U);	/* Draw_Text would cut the name to its cells */
	else
#endif
	Draw_Text(s, NAME_COLS, 1U, 5U);
	color(BLACK, DKGREY, SOLID);
}

/* Called for A on a file, before it is started. 0: go on and start it (a
   tap, a file that is not a game, or Start in the menu). 1: do not; the
   list is as it was, redrawn if the menu was up. 2: do not, and list the
   folder again (a star changed where the game sorts). */
UINT8 rom_menu(UINT16 show_offset, UINT16 file_select) __banked
{
	char name[MAX_filename_len];
	char p[FLAUNCH_MAX + 1U];
	UINT8 s[20];
	UINT16 n = (UINT16)(show_offset + file_select);
	UINT8 len;
	UINT8 t;
	UINT8 sel = 0U;
	UINT8 keys;
	UINT8 last;
	UINT8 from = 0U;
	UINT8 tick = 0U;

	HW_BANK = Folder_sram_bank + (UINT8)(n / Num_perBank);
	strcpy(name, (const char *)pFilename_buffer[n % Num_perBank].filename);
	/* the list calls this once a press (pad_take), so an A held from opening
	   the folder never gets here */
	if(!is_rom((const UINT8 *)name))
	{
		/* a text file opens in the viewer (textview.c); any other file
		   takes the path it did */
		if(!text_view(name)) return 0U;
		color(BLACK, WHITE, SOLID);
		DrawGB(3);
		hw_set_page(A000Address_SRAM);
		Show_filename(show_offset, file_select);
		return 1U;
	}

	for(t = 0U; t < HOLD_FRAMES; t++)
	{
		wait_vbl_done();
		if(!(joypad() & J_A)) return 0U;	/* a tap */
	}

	len = (UINT8)strlen(name);
	name_scrolls = (len > NAME_COLS) ? 1U : 0U;
#ifndef LANG_ZH
	/* a 12px font: by what it can place in the band's 144 pixels */
	if(ui_font) name_scrolls = (font12_fit((const UINT8 *)name, 8U) < len) ? 1U : 0U;
#endif
redraw:
	color(BLACK, DKGREY, SOLID);
	/* from the top of a list row to the bottom of one, in either font */
#ifdef LANG_ZH
	box(0, 32, 159, 135, M_FILL);
#else
	box(0, 32, 159, ui_font ? 139 : 135, M_FILL);
#endif
	name_draw(name, len, 0U);
	for(t = 0U; t < ITEMS; t++) item_draw(t, (t == sel) ? 1U : 0U, name);
	memcpy(s, "[B]back      [A]ok", 19U);
	Draw_Text(s, 18U, 1U, 15U);

	while(joypad()) wait_vbl_done();		/* the hold that opened it is not a press */
	last = 0U;
	while(1)
	{
		wait_vbl_done();
		if(name_scrolls && (++tick >= 12U))
		{
			tick = 0U;
			if(++from >= (UINT8)(len + 3U)) from = 0U;
			name_draw(name, len, from);
		}
		keys = joypad();
		if(keys == last) continue;
		last = keys;
		if(keys & J_B) break;
		if(keys & (J_UP | J_DOWN))
		{
			item_draw(sel, 0U, name);
			if(keys & J_UP) sel = sel ? (UINT8)(sel - 1U) : (UINT8)(ITEMS - 1U);	/* both wrap */
			else sel = ((UINT8)(sel + 1U) < ITEMS) ? (UINT8)(sel + 1U) : 0U;
			item_draw(sel, 1U, name);
		}
		else if(keys & J_A)
		{
			if(sel == 0U)
			{
				while(joypad()) wait_vbl_done();
				color(BLACK, WHITE, SOLID);
				DrawGB(3);				/* the list again, under the Loading box */
				hw_set_page(A000Address_SRAM);
				Show_filename(show_offset, file_select);
				HW_BANK = Folder_sram_bank + (UINT8)(n / Num_perBank);	/* the caller reads the record next */
				return 0U;
			}
			if(sel == 2U)
			{
				/* star or unstar: the folder is listed again, since the
				   game moves in it */
				star_toggle((const UINT8 *)name);
				follow_set((const UINT8 *)name);		/* the cursor goes with the game */
				while(joypad()) wait_vbl_done();
				color(BLACK, WHITE, SOLID);
				return 2U;
			}
			if(sel == 1U)
			{
				save_manager(name);		/* savemgr.c; it leaves its box up */
				color(BLACK, WHITE, SOLID);
				DrawGB(3);			/* its box is taller than this one: the list again first */
				hw_set_page(A000Address_SRAM);
				Show_filename(show_offset, file_select);
				from = 0U;
				goto redraw;
			}
			/* this game becomes the fast launch game, or stops being it.
			   Neither turns fast launch on or off: that is the SET tab's
			   FAST LAUNCH box, and the # in front of the path. */
			if(is_flaunch(name))
			{
				cfg_flaunch[(cfg_flaunch[0] == '#') ? 1U : 0U] = 0;
				cfg_changed(CFG_OTHER);
				item_draw(3U, 1U, name);
			}
			else if(path_of(name, p, (cfg_flaunch[0] == '/') ? 0U : 1U))
			{
				strcpy(cfg_flaunch, p);
				cfg_changed(CFG_OTHER);
				item_draw(3U, 1U, name);
			}
		}
	}
	while(joypad()) wait_vbl_done();		/* this B is not one for the list */
	color(BLACK, WHITE, SOLID);
	DrawGB(3);
	hw_set_page(A000Address_SRAM);
	Show_filename(show_offset, file_select);
	return 1U;
}
