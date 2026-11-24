/* ============================================================================
   browser.c  -  mod: reading a folder for the file list (bank 8)
   ----------------------------------------------------------------------------
   Read_all_DIR was in main.c and stored a folder in the order the card has
   it, folders first. Here it also sorts by name and hides what is not a
   game (docs/browser.md has the 0918 mod's version of both).

   Sorting 254-byte records in banked save RAM would take minutes, so the
   folder is read twice and no record is ever moved:

     1. every shown entry gets a 16-byte key in save RAM bank KEY_BANK:
        a class byte (0 folder, 1 file), 13 upper-cased name characters
        and the entry's number in card order
     2. the keys are heapsorted
     3. the rank table (after the keys in the same bank) gets, for each
        number in card order, its row in the sorted list
     4. the folder is read again and each record is written straight to
        its row

   Two names with the same first 13 characters stay in card order.

   The list is banks Folder_sram_bank to KEY_BANK - 1 of save RAM, 32 records
   a bank, so it holds 416 entries where the kernel as received held 448.
   A folder with more is cut there and left in card order: a sorted pick of
   whatever came first on the card would look complete when it is not.
   ========================================================================== */

#include <gb/gb.h>
#include <string.h>

#include "ezgb_hw.h"
#include "main.h"
#include "ff.h"

#pragma bank 8

extern FILINFO fileinfo;
extern DIR dir;
extern TCHAR currentpath[];
extern FM_FILE_FS *pFilename_buffer;
extern UINT16 game_folder_total;
extern UINT8 Read_file_end;
extern UINT8 readdir_fail;
extern UINT8 readdir_stage;

#define KEY_BANK	31U
#define KEY_LEN		16U
#define LIST_MAX	((UINT16)Num_perBank * (UINT16)(KEY_BANK - Folder_sram_bank))
#define KEYS		((UINT8 *)FlashBase_SRAM)
#define RANKS		((UINT16 *)(FlashBase_SRAM + LIST_MAX * KEY_LEN))

static UINT8 key_a[KEY_LEN];
static UINT8 key_b[KEY_LEN];

/* The name the list shows for the entry in fileinfo */
static char *entry_name(void)
{
	return *fileinfo.lfname ? fileinfo.lfname : fileinfo.fname;
}

static UINT8 up(UINT8 c)
{
	if((c >= 'a') && (c <= 'z')) return (UINT8)(c - 0x20U);
	return c;
}

/* 1 when s is the same as t but for case. t is upper case. */
static UINT8 same_name(const char *s, const char *t)
{
	while(*t)
	{
		if(up((UINT8)*s) != (UINT8)*t) return 0U;
		s++;
		t++;
	}
	return (*s == 0) ? 1U : 0U;
}

/* 1 when the name's ending is one of those the list hides */
static UINT8 hidden_ending(const char *fn)
{
	UINT8 n;
	const char *e;

	n = (UINT8)strlen(fn);
	if(n < 4U) return 0U;
	e = fn + n - 4U;
	if(same_name(e, ".GBA")) return 1U;	/* GBA and DS ROMs on a shared card */
	if(same_name(e, ".NDS")) return 1U;
	if(same_name(e, ".SAV")) return 1U;	/* saves: the Jr keeps its own in SAVER */
	if(same_name(e, ".ESV")) return 1U;
	if(same_name(e, ".DAT")) return 1U;	/* kernels */
	return 0U;
}

/* 0 when the entry in fileinfo is not listed, 1 for a file, 2 for a folder */
static UINT8 entry_class(void)
{
	char *fn;
	UINT8 is_dir;

	if(fileinfo.fname[0] == '.') return 0U;		/* . and .., and dot files with no long name */
	fn = entry_name();
	if((fn[0] == '.') || (fn[0] == '_')) return 0U;	/* macOS sidecars and the like */
	if(fileinfo.fattrib & (AM_VOL | AM_HID | AM_SYS)) return 0U;

	is_dir = (fileinfo.fattrib & AM_DIR) ? 1U : 0U;
	if(hidden_ending(fn)) return 0U;
	if(same_name(fn, "EZGB.CFG")) return 0U;
	if(same_name(fn, "FLAUNCH.CFG")) return 0U;
	if(is_dir && same_name(fn, "SAVER")) return 0U;	/* the kernel's save folder */
	return is_dir ? 2U : 1U;
}

/* ---- the keys ---- */

static void keys_page(void)
{
	hw_set_page(A000Address_SRAM);
	HW_BANK = KEY_BANK;
}

static void key_store(UINT16 n, UINT8 cls)
{
	UINT8 i;
	UINT8 c;
	UINT8 *k;
	const char *fn;

	fn = entry_name();
	key_a[0] = (cls == 2U) ? 0U : 1U;
	for(i = 1U; i < 14U; i++)
	{
		c = (UINT8)*fn;
		if(c) fn++;
		key_a[i] = up(c);
	}
	key_a[14] = (UINT8)(n >> 8);
	key_a[15] = (UINT8)n;

	keys_page();
	k = KEYS + n * KEY_LEN;
	memcpy(k, key_a, KEY_LEN);
}

/* Heapsort. The entry's number is the last two bytes of the key, high byte
   first, so comparing all 16 bytes orders equal names by card order. */
static void sift(UINT16 root, UINT16 n)
{
	UINT16 child;
	UINT8 *pc;

	memcpy(key_a, KEYS + root * KEY_LEN, KEY_LEN);
	while(1)
	{
		child = (UINT16)(root * 2U + 1U);
		if(child >= n) break;
		pc = KEYS + child * KEY_LEN;
		if(((UINT16)(child + 1U) < n) && (memcmp(pc, pc + KEY_LEN, KEY_LEN) < 0))
		{
			child++;
			pc += KEY_LEN;
		}
		if(memcmp(key_a, pc, KEY_LEN) >= 0) break;
		memcpy(KEYS + root * KEY_LEN, pc, KEY_LEN);
		root = child;
	}
	memcpy(KEYS + root * KEY_LEN, key_a, KEY_LEN);
}

static void keys_sort(UINT16 n)
{
	UINT16 i;
	UINT8 *last;

	if(n < 2U) return;
	keys_page();
	i = n >> 1;
	while(i)
	{
		i--;
		sift(i, n);
	}
	i = n;
	while(--i)
	{
		last = KEYS + i * KEY_LEN;
		memcpy(key_b, last, KEY_LEN);
		memcpy(last, KEYS, KEY_LEN);
		memcpy(KEYS, key_b, KEY_LEN);
		sift(0U, i);
	}
}

/* ranks[number in card order] = row. With sorted 0 the rows are card order. */
static void ranks_build(UINT16 n, UINT8 sorted)
{
	UINT16 i;
	UINT16 ord;
	UINT8 *k;

	keys_page();
	k = KEYS;
	for(i = 0U; i < n; i++)
	{
		if(sorted)
		{
			ord = ((UINT16)k[14] << 8) | k[15];
			RANKS[ord] = i;
			k += KEY_LEN;
		}
		else
		{
			RANKS[i] = i;
		}
	}
}

/* Opens the folder. 0 when it could not be opened. */
static UINT8 open_dir(void)
{
	UINT8 res;

	hw_set_page(A000Address_TF);
	res = f_opendir(&dir, currentpath);
	if(res != FR_OK)
	{
		readdir_fail = res;
		readdir_stage = 9U;		/* f_opendir inside the scan */
		return 0U;
	}
	return 1U;
}

/* The next listed entry into fileinfo. 0 at the end of the folder or on an
   error, otherwise its class. */
static UINT8 next_entry(UINT8 stage)
{
	UINT8 res;
	UINT8 cls;

	while(1)
	{
		hw_set_page(A000Address_TF);
		res = f_readdir(&dir, &fileinfo);
		if(res != FR_OK)
		{
			/* Not "end of directory": the card stopped answering. */
			readdir_fail = res;
			readdir_stage = stage;
			return 0U;
		}
		if(fileinfo.fname[0] == 0) return 0U;
		cls = entry_class();
		if(cls) return cls;
	}
}

void Read_all_DIR(void) __banked
{
	UINT8 cls;
	UINT8 cut = 0U;
	UINT8 *name;
	UINT16 n = 0U;
	UINT16 k;
	UINT16 row;
	UINT8 slot;

	game_folder_total = 0;
	Read_file_end = 1;			/* everything is read here: scrolling never touches the card */
	readdir_fail = 0;

	/* the keys */
	if(!open_dir()) return;
	while((cls = next_entry(3U)) != 0U)
	{
		if(n >= LIST_MAX)
		{
			cut = 1U;
			break;
		}
		key_store(n, cls);
		n++;
	}
	if(readdir_fail) return;

	if(!cut) keys_sort(n);
	ranks_build(n, cut ? 0U : 1U);

	/* the records, each to its row */
	if(!open_dir()) return;
	for(k = 0U; k < n; k++)
	{
		cls = next_entry(4U);
		if(!cls) break;

		keys_page();
		row = RANKS[k];
		HW_BANK = Folder_sram_bank + (UINT8)(row / Num_perBank);
		slot = (UINT8)(row % Num_perBank);
		name = pFilename_buffer[slot].filename;

		pFilename_buffer[slot].fattrib = (cls == 2U) ? AM_DIR : 0x20;
#ifdef LANG_ZH
		pFilename_buffer[slot].fsize = fileinfo.fsize;	/* size column shown by the zh list */
#endif
		strncpy((char *)name, entry_name(), MAX_filename_len - 1);
		name[MAX_filename_len - 1] = 0;
	}
	/* a short second read (the card stopped answering) leaves rows unwritten,
	   and readdir_fail set: the caller reports it and shows no list */
	game_folder_total = n;

	hw_set_page(A000Address_TF);
}
