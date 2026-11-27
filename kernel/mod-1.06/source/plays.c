/* ============================================================================
   plays.c  -  mod: stars and play counts
   ----------------------------------------------------------------------------
   docs/stars.md has the 0918 mod's, and this keeps its table and its file,
   so a card's stars and counts are the same under both kernels.

   The table is in save RAM, bank 17:

     $B7F8   'P', 'L', entries (up to 254), stars
     $B800   8 bytes an entry, sorted by hash: hash (4), launches (2, low
             byte first), flags (bit 0: starred), 0
     $A404   SORT BY PLAYS: 'S', 'O', 1, $FE when on

   A game gets an entry the first time it is launched or starred. The key
   is a hash of its file name alone, upper-cased: a = a * 33 + c from 5381
   and b = b + a, stored a high, a low, b high, b low. So a game keeps its
   count when it moves to another folder. A lookup is a binary search.

   When the table is full a new name takes the place of the least launched
   entry without a star; with every entry starred a new one is refused.
   Unstarring a game never launched drops its entry.

   /.ezgbplays in the card's root is the same 2048 bytes (bytes 4 to 7 hold
   the SORT BY PLAYS record), so a cart with no coin cell keeps its stars.
   At boot a file with the header replaces the table; after a star, a
   change of the setting, or a launch with SORT BY PLAYS on, the table is
   written to it. With the setting off a launch counts nothing and does
   not touch the card.
   ========================================================================== */

#include <gb/gb.h>
#include <string.h>

#include "ezgb_hw.h"
#include "main.h"
#include "ff.h"
#include "Bank_fun.h"
#include "plays.h"

#include "modbank2.h"

extern UINT8 SD_buffer[0x200];
extern FIL gfil;

#define HDR		((UINT8 *)0xB7F8U)
#define TBL		((UINT8 *)0xB800U)
#define SORTREC		((UINT8 *)0xA404U)
#define ENTRIES_MAX	254U
#define FILE_SIZE	2048U

static UINT8 key[4];
static char plays_path[12];

static void map(void)
{
	HW_BANK = SAVE_info_sram_bank;
	hw_set_page(A000Address_SRAM);
}

static void unmap(void)
{
	HW_BANK = 0;
	hw_set_page(A000Address_TF);
}

/* the hash of name into key */
static void hash(const UINT8 *name)
{
	UINT16 a = 5381U;
	UINT16 b = 0U;
	UINT8 c;

	while((c = *name++) != 0U)
	{
		if((c >= 'a') && (c <= 'z')) c -= 0x20U;
		a = (UINT16)(a * 33U + c);
		b = (UINT16)(b + a);
	}
	key[0] = (UINT8)(a >> 8);
	key[1] = (UINT8)a;
	key[2] = (UINT8)(b >> 8);
	key[3] = (UINT8)b;
}

/* With the table mapped: an empty one when the header is not ours */
static void check(void)
{
	if((HDR[0] == 'P') && (HDR[1] == 'L') && (HDR[2] <= ENTRIES_MAX) && (HDR[3] <= HDR[2])) return;
	HDR[0] = 'P';
	HDR[1] = 'L';
	HDR[2] = 0U;
	HDR[3] = 0U;
}

/* With the table mapped: the entry with key, or where it would go. *found
   says which. */
static UINT8 *find(UINT8 *found)
{
	UINT8 lo = 0U;
	UINT8 hi = HDR[2];
	UINT8 mid;
	UINT8 *e;
	int d;

	while(lo < hi)
	{
		mid = (UINT8)((lo + hi) >> 1);
		e = TBL + ((UINT16)mid << 3);
		d = memcmp(key, e, 4U);
		if(d == 0)
		{
			*found = 1U;
			return e;
		}
		if(d < 0) hi = mid;
		else lo = (UINT8)(mid + 1U);
	}
	*found = 0U;
	return TBL + ((UINT16)lo << 3);
}

static void drop(UINT8 *e)
{
	UINT8 *end = TBL + ((UINT16)HDR[2] << 3);

	if(e[6] & 1U) HDR[3]--;
	memmove(e, e + 8, (UINT16)(end - (e + 8)));
	HDR[2]--;
}

/* With the table mapped: a new entry for key, or 0 when a full table has
   nothing but stars */
static UINT8 *add(void)
{
	UINT8 *e;
	UINT8 *worst = 0;
	UINT16 least = 0xFFFFU;
	UINT16 n;
	UINT8 i;
	UINT8 found;

	if(HDR[2] >= ENTRIES_MAX)
	{
		e = TBL;
		for(i = 0U; i < HDR[2]; i++, e += 8)
		{
			if(e[6] & 1U) continue;
			n = ((UINT16)e[5] << 8) | e[4];
			if(n < least)
			{
				least = n;
				worst = e;
			}
		}
		if(!worst) return 0;
		drop(worst);
	}
	e = find(&found);
	memmove(e + 8, e, (UINT16)((TBL + ((UINT16)HDR[2] << 3)) - e));
	memcpy(e, key, 4U);
	e[4] = 0U;
	e[5] = 0U;
	e[6] = 0U;
	e[7] = 0U;
	HDR[2]++;
	return e;
}

/* ---- the file ---- */

/* The table to /.ezgbplays, all four sectors */
static void sync(void)
{
	UINT16 off;
	UINT16 put;
	UINT8 i;

	memcpy(plays_path, "/.ezgbplays", 12U);
	hw_set_page(A000Address_TF);
	if(f_open_bank(&gfil, plays_path, FA_WRITE | FA_OPEN_ALWAYS) != FR_OK) return;
	for(off = 0U; off < FILE_SIZE; off += 0x200U)
	{
		map();
		memcpy(SD_buffer, HDR + off, 0x200U);
		if(off == 0U) for(i = 0U; i < 4U; i++) SD_buffer[4U + i] = SORTREC[i];
		hw_set_page(A000Address_TF);
		if(f_write_bank(&gfil, SD_buffer, 0x200U, &put) != FR_OK) break;
	}
	f_close_bank(&gfil);
	unmap();
}

/* Boot: a file with the header replaces the table. No file, or one that is
   not ours, and save RAM's table is kept. Nothing is written. */
void plays_load(void) __banked
{
	UINT16 off;
	UINT16 got;
	UINT8 i;

	memcpy(plays_path, "/.ezgbplays", 12U);
	hw_set_page(A000Address_TF);
	if(f_open_bank(&gfil, plays_path, FA_READ) == FR_OK)
	{
		for(off = 0U; off < FILE_SIZE; off += 0x200U)
		{
			hw_set_page(A000Address_TF);
			if((f_read_bank(&gfil, SD_buffer, 0x200U, &got) != FR_OK) || (got != 0x200U)) break;
			if((off == 0U) && ((SD_buffer[0] != 'P') || (SD_buffer[1] != 'L'))) break;
			map();
			if(off == 0U)
			{
				for(i = 0U; i < 4U; i++) SORTREC[i] = SD_buffer[4U + i];
				memcpy(HDR, SD_buffer, 4U);
				memcpy(HDR + 8, SD_buffer + 8, 0x1F8U);
			}
			else memcpy(HDR + off, SD_buffer, 0x200U);
		}
		hw_set_page(A000Address_TF);
		f_close_bank(&gfil);
	}
	map();
	check();
	unmap();
}

/* ---- what the kernel calls ---- */

/* A game is about to be launched */
void plays_bump(const UINT8 *name) __banked
{
	UINT8 *e;
	UINT8 found;

	/* with SORT BY PLAYS off nothing is counted, and so nothing is written
	   to the card at a launch */
	if(!plays_sort_on()) return;
	hash(name);
	map();
	check();
	e = find(&found);
	if(!found) e = add();
	if(e)
	{
		if(++e[4] == 0U) if(++e[5] == 0U) { e[4] = 0xFFU; e[5] = 0xFFU; }
	}
	unmap();
	if(e) sync();
}

/* 1 when the game is starred */
UINT8 star_query(const UINT8 *name) __banked
{
	UINT8 *e;
	UINT8 found;
	UINT8 on;

	hash(name);
	map();
	check();
	e = find(&found);
	on = (found && (e[6] & 1U)) ? 1U : 0U;
	unmap();
	return on;
}

/* Stars the game, or unstars it. 0 when a full table refused. */
UINT8 star_toggle(const UINT8 *name) __banked
{
	UINT8 *e;
	UINT8 found;

	hash(name);
	map();
	check();
	e = find(&found);
	if(!found) e = add();
	if(!e)
	{
		unmap();
		return 0U;
	}
	if(e[6] & 1U)
	{
		e[6] &= 0xFEU;
		HDR[3]--;
		if(!e[4] && !e[5]) drop(e);		/* never launched: no reason to keep it */
	}
	else
	{
		e[6] |= 1U;
		HDR[3]++;
	}
	unmap();
	sync();
	return 1U;
}

/* SORT BY PLAYS */
UINT8 plays_sort_on(void) __banked
{
	UINT8 on;

	map();
	on = ((SORTREC[0] == 'S') && (SORTREC[1] == 'O') && (SORTREC[2] == 1U) && (SORTREC[3] == 0xFEU)) ? 1U : 0U;
	unmap();
	return on;
}

void plays_sort_set(UINT8 on) __banked
{
	map();
	check();
	SORTREC[0] = on ? 'S' : 0U;
	SORTREC[1] = 'O';
	SORTREC[2] = 1U;
	SORTREC[3] = 0xFEU;
	unmap();
	sync();
}

/* For the sort (browser.c): what the table has for a file's name. Bit 0 of
   the result is the star; *launches gets its count, 255 at most. With
   nothing starred and SORT BY PLAYS off the sort does not ask. */
UINT8 plays_lookup(const UINT8 *name, UINT8 *launches) __banked
{
	UINT8 *e;
	UINT8 found;
	UINT8 flags = 0U;

	*launches = 0U;
	hash(name);
	map();
	e = find(&found);
	if(found)
	{
		flags = e[6] & 1U;
		*launches = e[5] ? 0xFFU : e[4];
	}
	unmap();
	return flags;
}

/* 1 when the sort has anything to ask: a star somewhere, or SORT BY PLAYS */
UINT8 plays_active(void) __banked
{
	UINT8 any;

	map();
	check();
	any = HDR[3] ? 1U : 0U;
	unmap();
	return (UINT8)(any | (plays_sort_on() << 1));
}

/* ---- the cursor after a star ---- */

static UINT8 follow_key[4];
static UINT8 follow_on;

/* The folder is about to be listed again because this game was starred or
   unstarred: the list puts the cursor back on it (list_follow, browser.c) */
void follow_set(const UINT8 *name) __banked
{
	hash(name);
	memcpy(follow_key, key, 4U);
	follow_on = 1U;
}

/* 0: nothing to follow. 1: name is not the game. 2: it is. */
UINT8 follow_match(const UINT8 *name) __banked
{
	if(!follow_on) return 0U;
	hash(name);
	return memcmp(follow_key, key, 4U) ? 1U : 2U;
}

void follow_clear(void) __banked
{
	follow_on = 0U;
}
