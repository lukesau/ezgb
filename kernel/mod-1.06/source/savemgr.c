/* ============================================================================
   savemgr.c  -  mod: Manage saves, from a game's hold-A menu
   ----------------------------------------------------------------------------
   docs/save-manager.md has the 0918 mod's. For the game the menu is on:

     Saves                     "Working...", then "Done" or "Error"
     <the game's name>
     > Back up save            "No save yet" when the game has none
       26-10-11 12:00          its backups, newest first
       26-10-10 14:32 (2)
     [B]back          [A]ok

   Back up save copies /SAVER/<base>.sav to a backup named after the save's
   last-modified time:

     /SAVER/<base> YYYY-MM-DD HH-MM.sav
     /SAVER/<base> YYYY-MM-DD HH-MM (2).sav      when that name is taken

   A on a backup offers Restore and Delete. Restore backs the current save
   up first, then copies the backup over <base>.sav: the next launch loads
   it, since every launch reads the save from the card. Delete removes that
   backup; the live save is never deleted. <base> is the game's file name
   without its ending, as the kernel names the save.

   The names are the 0918 mod's, so a card's backups show under both.

   File work: the source is on the kernel's FIL and the destination on a
   second one, 512 bytes at a time through SD_buffer. Every FatFs call has
   the SD page selected first, and a path is always in RAM.
   ========================================================================== */

#include <gb/gb.h>
#include <gb/drawing.h>
#include <string.h>

#include "ezgb_hw.h"
#include "main.h"
#include "ff.h"
#include "Bank_fun.h"
#include "savemgr.h"
#include "ezcfg.h"
#include "list12.h"
#include "font12.h"

#include "modbank.h"

extern UINT8 SD_buffer[0x200];
extern FIL gfil;
extern FILINFO fileinfo;
extern DIR dir;
extern TCHAR lfname_temp[];

#define LIST_MAX	37U		/* backups listed, the newest */
#define BASE_MAX	60U		/* a longer name's saves are not looked for */
#define PATH_MAX	100U
/* list rows on screen: a text row each, where the Chinese build's taller
   text has every other row */
#ifdef LANG_ZH
#define ROWS		4U
#else
#define ROWS		(ui_font ? 5U : 7U)
#endif

UINT8 draw_colors(void);	/* vram_put.s */

typedef struct {
	UINT8 y, mo, d, h, mi;		/* year - 1980 */
	UINT8 n;			/* the counter: 0 for none, else 2 to 250 */
} stamp_t;

static FIL fil2;
static stamp_t list[LIST_MAX];
static UINT8 count;
static UINT8 have_live;
static stamp_t live;			/* the live save's modified time */
static char base[BASE_MAX + 1U];
static UINT8 blen;
static char path[PATH_MAX];
static char path2[PATH_MAX];

static UINT8 up(UINT8 c)
{
	if((c >= 'a') && (c <= 'z')) return (UINT8)(c - 0x20U);
	return c;
}

/* two digits at p, or $FF */
static UINT8 two(const char *p)
{
	if((p[0] < '0') || (p[0] > '9') || (p[1] < '0') || (p[1] > '9')) return 0xFFU;
	return (UINT8)((p[0] - '0') * 10U + (p[1] - '0'));
}

static char *put2(char *p, UINT8 v)
{
	*p++ = (char)('0' + v / 10U);
	*p++ = (char)('0' + v % 10U);
	return p;
}

/* Is name this game's save (returns 1) or one of its backups (2, with its
   stamp in *s)? Strict: <base>, any case; then ".sav", or a space, the time
   with every field in range, optionally " (n)" with n from 2 to 250, and
   ".sav". So "Tetris DX.sav" is not a backup of Tetris. */
static UINT8 match(const char *name, stamp_t *s)
{
	const char *p;
	UINT8 i;
	UINT8 v;
	UINT16 yr;

	for(i = 0U; i < blen; i++) if(up((UINT8)name[i]) != up((UINT8)base[i])) return 0U;
	p = name + blen;
	if((p[0] == '.') && (up((UINT8)p[1]) == 'S') && (up((UINT8)p[2]) == 'A') && (up((UINT8)p[3]) == 'V') && !p[4])
		return 1U;
	/* " YYYY-MM-DD HH-MM" */
	if((p[0] != ' ') || (p[5] != '-') || (p[8] != '-') || (p[11] != ' ') || (p[14] != '-')) return 0U;
	v = two(p + 1);
	i = two(p + 3);
	if((v == 0xFFU) || (i == 0xFFU)) return 0U;
	yr = (UINT16)v * 100U + i;
	if((yr < 1980U) || (yr > 2107U)) return 0U;
	s->y = (UINT8)(yr - 1980U);
	s->mo = two(p + 6);
	s->d = two(p + 9);
	s->h = two(p + 12);
	s->mi = two(p + 15);
	if((s->mo < 1U) || (s->mo > 12U) || (s->d < 1U) || (s->d > 31U) || (s->h > 23U) || (s->mi > 59U)) return 0U;
	p += 17;
	s->n = 0U;
	if((p[0] == ' ') && (p[1] == '('))
	{
		yr = 0U;
		p += 2;
		while((*p >= '0') && (*p <= '9') && (yr < 1000U)) yr = (UINT16)(yr * 10U + (UINT16)(*p++ - '0'));
		if((*p != ')') || (yr < 2U) || (yr > 250U)) return 0U;
		s->n = (UINT8)yr;
		p++;
	}
	if((p[0] == '.') && (up((UINT8)p[1]) == 'S') && (up((UINT8)p[2]) == 'A') && (up((UINT8)p[3]) == 'V') && !p[4])
		return 2U;
	return 0U;
}

/* 1 when a is newer than b, or as new with the higher counter */
static UINT8 newer(const stamp_t *a, const stamp_t *b)
{
	UINT8 i;
	const UINT8 *pa = (const UINT8 *)a;
	const UINT8 *pb = (const UINT8 *)b;

	for(i = 0U; i < 6U; i++) if(pa[i] != pb[i]) return (pa[i] > pb[i]) ? 1U : 0U;
	return 0U;
}

/* /SAVER/<base>.sav, or a backup's name, into dst */
static void path_of(char *dst, const stamp_t *s)
{
	char *p;
	UINT16 yr;

	memcpy(dst, "/SAVER/", 7U);
	memcpy(dst + 7, base, blen);
	p = dst + 7 + blen;
	if(s)
	{
		yr = (UINT16)1980U + s->y;
		*p++ = ' ';
		p = put2(p, (UINT8)(yr / 100U));
		p = put2(p, (UINT8)(yr % 100U));
		*p++ = '-';
		p = put2(p, s->mo);
		*p++ = '-';
		p = put2(p, s->d);
		*p++ = ' ';
		p = put2(p, s->h);
		*p++ = '-';
		p = put2(p, s->mi);
		if(s->n)
		{
			*p++ = ' ';
			*p++ = '(';
			if(s->n >= 100U) *p++ = (char)('0' + s->n / 100U);
			if(s->n >= 10U) *p++ = (char)('0' + (s->n / 10U) % 10U);
			*p++ = (char)('0' + s->n % 10U);
			*p++ = ')';
		}
	}
	memcpy(p, ".sav", 5U);
}

/* Reads /SAVER: the live save and the newest backups, newest first */
static void scan(void)
{
	stamp_t s;
	UINT8 k;
	UINT8 i;
	const char *fn;

	count = 0U;
	have_live = 0U;
	memcpy(path, "/SAVER", 7U);
	fileinfo.lfname = lfname_temp;
	fileinfo.lfsize = MAX_filename_len;
	hw_set_page(A000Address_TF);
	if(f_opendir(&dir, path) != FR_OK) return;
	while(1)
	{
		hw_set_page(A000Address_TF);
		if(f_readdir(&dir, &fileinfo) != FR_OK) break;
		if(fileinfo.fname[0] == 0) break;
		if(fileinfo.fattrib & AM_DIR) continue;
		fn = *fileinfo.lfname ? fileinfo.lfname : fileinfo.fname;
		if(strlen(fn) < (UINT16)(blen + 4U)) continue;
		k = match(fn, &s);
		if(k == 1U)
		{
			have_live = 1U;
			live.y = (UINT8)(fileinfo.fdate >> 9);
			live.mo = (UINT8)((fileinfo.fdate >> 5) & 15U);
			live.d = (UINT8)(fileinfo.fdate & 31U);
			live.h = (UINT8)(fileinfo.ftime >> 11);
			live.mi = (UINT8)((fileinfo.ftime >> 5) & 63U);
			live.n = 0U;
		}
		else if(k == 2U)
		{
			/* insert, newest first; the oldest falls off a full list */
			for(i = 0U; i < count; i++) if(newer(&s, &list[i])) break;
			if(i >= LIST_MAX) continue;
			if(count < LIST_MAX) count++;
			for(k = (UINT8)(count - 1U); k > i; k--) list[k] = list[k - 1U];
			list[i] = s;
		}
	}
	hw_set_page(A000Address_TF);
}

/* Copies the file at path to the one at path2. 0 when it worked. */
static UINT8 copy(void)
{
	UINT16 got;
	UINT16 put;
	UINT8 bad = 0U;

	hw_set_page(A000Address_TF);
	if(f_open_bank(&gfil, path, FA_READ) != FR_OK) return 1U;
	if(f_open_bank(&fil2, path2, FA_WRITE | FA_OPEN_ALWAYS) != FR_OK)
	{
		f_close_bank(&gfil);
		return 1U;
	}
	while(1)
	{
		hw_set_page(A000Address_TF);
		if(f_read_bank(&gfil, SD_buffer, 0x200U, &got) != FR_OK)
		{
			bad = 1U;
			break;
		}
		if(got == 0U) break;
		if((f_write_bank(&fil2, SD_buffer, got, &put) != FR_OK) || (put != got))
		{
			bad = 1U;
			break;
		}
		if(got < 0x200U) break;
	}
	f_close_bank(&gfil);
	if(f_close_bank(&fil2) != FR_OK) bad = 1U;
	hw_set_page(A000Address_TF);
	return bad;
}

/* 1 when a file with this name is on the card */
static UINT8 exists(const char *p)
{
	hw_set_page(A000Address_TF);
	if(f_open_bank(&gfil, p, FA_READ) != FR_OK) return 0U;
	f_close_bank(&gfil);
	return 1U;
}

/* The live save to a backup named after its modified time: the first
   name, counting up from no counter, that is not on the card */
static UINT8 backup(void)
{
	stamp_t s;

	if(!have_live) return 1U;
	s = live;
	if((s.mo < 1U) || (s.mo > 12U) || (s.d < 1U)) { s.mo = 1U; s.d = 1U; }	/* a file with no date */
	while(1)
	{
		path_of(path2, &s);
		if(!exists(path2)) break;
		if(s.n == 0U) s.n = 2U;
		else if(s.n >= 250U) return 1U;
		else s.n++;
	}
	path_of(path, 0);
	return copy();
}

static UINT8 restore(UINT8 i)
{
	stamp_t s = list[i];

	if(have_live && backup()) return 1U;	/* the current save is kept first */
	path_of(path, &s);
	path_of(path2, 0);
	return copy();
}

static UINT8 del_backup(UINT8 i)
{
	path_of(path, &list[i]);
	hw_set_page(A000Address_TF);
	i = (f_unlink(path) != FR_OK) ? 1U : 0U;
	hw_set_page(A000Address_TF);
	return i;
}

/* ---- the screens ---- */

static void text(const char *s, UINT8 x, UINT8 row, UINT8 width)
{
	UINT8 b[27];
	UINT8 n = (UINT8)strlen(s);

	memset(b, ' ', 26U);
	b[26] = 0U;
	/* a 12px font takes what fits the field's pixels, which is more
	   characters than its cells */
	if(n > (ui_font ? 26U : width)) n = ui_font ? 26U : width;
	memcpy(b, s, n);
#ifndef LANG_ZH
	if(ui_font) text12(b, width, x, row);	/* Draw_Text would cut the string to its cells */
	else
#endif
	Draw_Text(b, width, x, row);
}

/* "YY-MM-DD HH:MM" and the counter, into dst */
static void label(char *dst, const stamp_t *s)
{
	char *p = dst;

	p = put2(p, (UINT8)((s->y + 80U) % 100U));
	*p++ = '-';
	p = put2(p, s->mo);
	*p++ = '-';
	p = put2(p, s->d);
	*p++ = ' ';
	p = put2(p, s->h);
	*p++ = ':';
	p = put2(p, s->mi);
	if(s->n)
	{
		*p++ = ' ';
		*p++ = '(';
		if(s->n >= 100U) *p++ = (char)('0' + s->n / 100U);
		if(s->n >= 10U) *p++ = (char)('0' + (s->n / 10U) % 10U);
		*p++ = (char)('0' + s->n % 10U);
		*p++ = ')';
	}
	*p = 0;
}

/* A row of the list, t or blank, on screen row r: the selected one is a
   band in the selection's colors */
static void row_text(const char *t, UINT8 r, UINT8 sel)
{
	char s[20];
	UINT8 n = (UINT8)strlen(t);

	memset(s, ' ', 19U);
	s[19] = 0;
	if(n > 17U) n = 17U;
	memcpy(s + 1, t, n);
	if(sel) color(SEL_INK, SEL_PAPER, SOLID);
	else color(BLACK, DKGREY, SOLID);
#ifdef LANG_ZH
	Draw_Text(s, 18U, 1U, (UINT8)(7U + r * 2U));
#else
	if(ui_font) font12_field((const UINT8 *)s, 8U, (UINT8)(56U + r * 12U), draw_colors(), 152U);
	else Draw_Text(s, 18U, 1U, (UINT8)(7U + r));
#endif
	color(BLACK, DKGREY, SOLID);
}

/* Item i of the list screen (0 is Back up save), on screen row r; a blank
   row past the last */
static void item(UINT8 i, UINT8 r, UINT8 sel)
{
	char s[20];

	s[0] = 0;
	if(i == 0U) strcpy(s, have_live ? "Back up save" : "No save yet");
	else if(i <= count) label(s, &list[i - 1U]);
	row_text(s, r, sel);
}

static const char *rom;			/* the game's file name, for the band */

static void buttons(const char *keys)
{
	color(BLACK, DKGREY, SOLID);
	text(keys, 1U, 15U, 18U);
#ifdef LANG_ZH
	popup_rules(15U, 135U, 84U);
#else
	popup_rules(15U, ui_font ? 139U : 135U, 84U);
#endif
}

static void frame(const char *title, const char *keys)
{
	color(BLACK, DKGREY, SOLID);
	/* to the bottom of a list row, in either font */
#ifdef LANG_ZH
	box(0, 16, 159, 135, M_FILL);
#else
	box(0, 16, 159, ui_font ? 139 : 135, M_FILL);
#endif
	text(title, 1U, 3U, 18U);
	mq_start((const UINT8 *)rom, 1U, 5U, 18U, WHITE, BLACK);	/* the whole name, scrolling (modmisc.c) */
	buttons(keys);
}

/* A press of A or B, or UP or DOWN with its repeat (pad_menu) */
static UINT8 key(void)
{
	UINT8 k;

	while(1)
	{
		wait_vbl_done();
		mq_step();
		k = pad_menu();
		if(k & (J_A | J_B | J_UP | J_DOWN)) return k;
	}
}

/* A backup was picked: Restore or Delete, then a yes or no. Returns the
   status text for the list's title, or 0 when nothing was done. */
static const char *act(UINT8 i)
{
	char s[20];
	UINT8 sel = 0U;
	UINT8 k;
	UINT8 r;
	UINT8 bad;

	label(s, &list[i]);
	color(BLACK, DKGREY, SOLID);
	text(s, 1U, 3U, 18U);
	for(r = 2U; r < ROWS; r++) row_text("", r, 0U);
	while(1)
	{
		row_text("Restore", 0U, (UINT8)!sel);
		row_text("Delete", 1U, sel);
		k = key();
		if(k & J_B) return 0;
		if(k & (J_UP | J_DOWN)) sel ^= 1U;
		else if(k & J_A) break;
	}
	text(sel ? "Delete this save?" : "Restore this save?", 1U, 3U, 18U);
	buttons("[B]no       [A]yes");
	do k = key(); while(!(k & (J_A | J_B)));
	buttons("[B]back      [A]ok");
	if(k & J_B) return 0;
	text("Working...", 1U, 3U, 18U);
	bad = sel ? del_backup(i) : restore(i);
	return bad ? "Error" : "Done";
}

/* The game is name, a .gb or .gbc. Returns when B leaves the screen: the
   caller draws what was under it. */
void save_manager(const char *name) __banked
{
	const char *title = "Saves";
	UINT8 sel = 0U;
	UINT8 top = 0U;
	UINT8 full = 1U;
	UINT8 n;
	UINT8 r;
	UINT8 k;

	rom = name;
	n = (UINT8)strlen(name);
	while(n && (name[n - 1U] != '.')) n--;
	if(n < 2U) return;
	count = 0U;
	have_live = 0U;
	if((UINT8)(n - 1U) <= BASE_MAX)
	{
		blen = (UINT8)(n - 1U);
		memcpy(base, name, blen);
		base[blen] = 0;
		scan();
	}
	/* else a name too long for the paths: the screen opens with no save */
	pad_take();			/* the press that opened it is not one for the list */
	while(1)
	{
		n = (UINT8)(count + 1U);
		if(sel >= n) sel = (UINT8)(n - 1U);
		if(sel < top) top = sel;
		if(sel >= (UINT8)(top + ROWS)) top = (UINT8)(sel - (ROWS - 1U));
		/* the box and the name once; after that only what changes, so the
		   name goes on scrolling */
		if(full) frame(title, "[B]back      [A]ok");
		else
		{
			color(BLACK, DKGREY, SOLID);
			text(title, 1U, 3U, 18U);
		}
		full = 0U;
		for(r = 0U; r < ROWS; r++)
			item((UINT8)(top + r), r, ((UINT8)(top + r) == sel) ? 1U : 0U);
		title = "Saves";

		k = key();
		if(k & J_B) break;
		/* UP and DOWN stop at the ends */
		if(k & J_UP)
		{
			if(sel) sel--;
		}
		else if(k & J_DOWN)
		{
			if((UINT8)(sel + 1U) < n) sel++;
		}
		else if(k & J_A)
		{
			if(sel == 0U)
			{
				if(!have_live) continue;
				color(BLACK, DKGREY, SOLID);
				text("Working...", 1U, 3U, 18U);
				title = backup() ? "Error" : "Done";
			}
			else
			{
				title = act((UINT8)(sel - 1U));
				if(!title)
				{
					title = "Saves";
					continue;
				}
			}
			scan();
			sel = 0U;
			top = 0U;
		}
	}
	while(joypad()) wait_vbl_done();
	color(BLACK, WHITE, SOLID);
}

/* ---- the daily backup ---- */

/* DAILY BACKUP (docs/save-manager.md): at boot, when a save is waiting to
   be written to savepath ("/SAVER/<base>.sav") and that file was last
   written before today by the cart's clock, it is copied to a backup first
   and then the game's other backups are deleted, so the game has one backup, of
   the save as it was before today's play. Later boots the same day find
   the file written today and leave the backup alone. The test is only as
   good as the clock. A 32 KB copy takes several seconds, at most once a
   day a game. */
void save_daily(const char *savepath, UINT8 banks) __banked
{
	DWORD t;
	char s[20];
	UINT8 n;
	UINT8 i;

	if(!cfg_daily) return;
	n = (UINT8)strlen(savepath);
	if((n < 12U) || (n - 11U > BASE_MAX) || memcmp(savepath, "/SAVER/", 7U)) return;
	blen = (UINT8)(n - 11U);			/* less "/SAVER/" and ".sav" */
	memcpy(base, savepath + 7, blen);
	base[blen] = 0;

	scan();
	if(!have_live) return;
	t = get_fattime() >> 16;
	if((live.y == (UINT8)(t >> 9)) && (live.mo == (UINT8)((t >> 5) & 15U)) && (live.d == (UINT8)(t & 31U))) return;

	/* the save prompt's band: what this is, the game, why, and how long.
	   About 1.75 s an 8 KB bank. */
	color(BLACK, DKGREY, SOLID);
#ifdef LANG_ZH
	box(0, 35, 159, 99, M_FILL);
#else
	box(0, 35, 159, ui_font ? 103 : 99, M_FILL);
#endif
	text("Daily save backup", 1U, 5U, 18U);
	color(WHITE, BLACK, SOLID);
	text(base, 1U, 7U, 18U);
	color(BLACK, DKGREY, SOLID);
	text("Copy of older save", 1U, 9U, 18U);
	n = banks ? (UINT8)((((banks << 3) - banks) + 2U) >> 2) : 2U;
	memcpy(s, "About ", 6U);
	i = 6U;
	if(n >= 10U) s[i++] = (char)('0' + n / 10U);
	s[i++] = (char)('0' + n % 10U);
	memcpy(s + i, " seconds...", 12U);
	text(s, 1U, 11U, 18U);

	/* The new backup first, and the older ones go only when it is on the
	   card: a copy that fails leaves what there was. Until 2026-11-25 the
	   old ones were deleted first. The list is newest first and the new
	   backup has the save's time, so it is the one that stays. */
	if(backup() == 0U)
	{
		for(i = 0U; i < 64U; i++)
		{
			scan();
			if(count <= 1U) break;
			if(del_backup((UINT8)(count - 1U))) break;
		}
	}
	color(BLACK, WHITE, SOLID);
}
