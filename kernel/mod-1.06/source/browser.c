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

   Names with the same first 13 characters (12 with SORT BY PLAYS) are
   then put in order by their whole names, case aside, by swapping their
   records (ties_fix): there are few of them and they are next to each
   other.

   After a star or an unstar nothing is read from the card: the keys are
   made again from the records, sorted, and each record that has a new row
   is moved to it (list_resort).

   The list is banks Folder_sram_bank to KEY_BANK - 1 of save RAM, 32 records
   a bank, so it holds 416 entries where the kernel as received held 448.
   A folder with more is cut there and left in card order: a sorted pick of
   whatever came first on the card would look complete when it is not.
   ========================================================================== */

#include <gb/gb.h>
#include <string.h>
#include <gb/drawing.h>

#include "ezgb_hw.h"
#include "main.h"
#include "ff.h"
#include "plays.h"

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

/* ---- the card's hide list ---- */

extern UINT8 SD_buffer[0x200];
extern FIL gfil;
extern FRESULT f_open_bank(FIL *fp, const TCHAR *path, BYTE mode);
extern FRESULT f_read_bank(FIL *fp, void *buff, UINT btr, UINT *br);
extern FRESULT f_close_bank(FIL *fp);

static UINT8 hide_ok;			/* SD_buffer holds the packed list */
static char hide_path[11];

/* /.ezgbhide in the card's root names files and folders the list leaves
   out, on top of the ones built in (docs/browser.md). One name a line, any
   case:

     RTS            a file or folder with exactly this name, in any folder
     *.bak          any name with this ending
     # a comment    (blank lines are skipped too)

   Its first 510 bytes are read into SD_buffer and packed there in place,
   which nothing else uses while a folder is read: for each name a length
   byte (bit 7: the whole name must match) and the name in lower case, and
   a zero length at the end. A packed line is never longer than the line.
   It is read again for every listing. */
static void hide_load(void)
{
	UINT16 br = 0U;
	UINT16 i = 1U;
	UINT16 o = 0U;
	UINT16 at;
	UINT8 c;
	UINT8 n;
	UINT8 f;

	hide_ok = 0U;
	memcpy(hide_path, "/.ezgbhide", 11U);
	hw_set_page(A000Address_TF);
	if(f_open_bank(&gfil, hide_path, FA_READ) != FR_OK) return;
	/* read one byte in: a packed name has its length in front, so the
	   packing would otherwise write a byte it has not read yet */
	if(f_read_bank(&gfil, SD_buffer + 1, 0x1FEU, &br) != FR_OK) br = 0U;
	f_close_bank(&gfil);
	if(br > 0x1FEU) br = 0x1FEU;
	br++;				/* the end of what was read, as an index */

	while(i < br)
	{
		while((i < br) && ((SD_buffer[i] == ' ') || (SD_buffer[i] == '\t'))) i++;
		f = 0x80U;
		if((i < br) && (SD_buffer[i] == '*'))
		{
			f = 0U;
			i++;
		}
		if((i < br) && (SD_buffer[i] == '#')) f = 0xFFU;	/* a comment: nothing of it is kept */
		at = o++;			/* the length byte; the line had at least this one byte, or ends the file */
		n = 0U;
		for(; i < br; i++)
		{
			c = SD_buffer[i];
			if(c == '\n')
			{
				i++;
				break;
			}
			if((c == '\r') || (f == 0xFFU) || (n == 127U)) continue;
			if((c >= 'A') && (c <= 'Z')) c += 32U;
			SD_buffer[o++] = c;
			n++;
		}
		while(n && ((SD_buffer[o - 1U] == ' ') || (SD_buffer[o - 1U] == '\t')))
		{
			o--;
			n--;
		}
		if((n == 0U) || (f == 0xFFU)) o = at;	/* nothing on the line */
		else SD_buffer[at] = (UINT8)(f | n);
	}
	SD_buffer[o] = 0U;
	hide_ok = 1U;
}

static UINT8 low(UINT8 c)
{
	if((c >= 'A') && (c <= 'Z')) return (UINT8)(c + 32U);
	return c;
}

/* 1 when the card's list has this name */
static UINT8 hide_listed(const char *fn)
{
	const UINT8 *t;
	const UINT8 *p;
	UINT8 len;
	UINT8 n;
	UINT8 i;

	if(!hide_ok) return 0U;
	len = (UINT8)strlen(fn);
	t = SD_buffer;
	while(*t)
	{
		n = (UINT8)(*t & 0x7FU);
		if((n <= len) && (!(*t & 0x80U) || (n == len)))
		{
			p = (const UINT8 *)fn + (len - n);	/* the ending, or the whole name */
			for(i = 0U; i < n; i++) if(low(p[i]) != t[1U + i]) break;
			if(i == n) return 1U;
		}
		t += 1U + n;
	}
	return 0U;
}

/* 0 when the entry in fileinfo is not listed, 1 for a file, 2 for a folder */
static UINT8 lone_scan;		/* entry_class is asked for browser_lone_rom */

static UINT8 entry_class(void)
{
	char *fn;
	UINT8 is_dir;
	UINT8 n;

	if(!tags_hide && !lone_scan)
	{
		/* CLEAN NAMES off: the card as it is. Nothing is left out but the
		   volume label and the folder's . and .. entries, which are not
		   files. */
		if(fileinfo.fattrib & AM_VOL) return 0U;
		if((fileinfo.fname[0] == '.') && ((fileinfo.fname[1] == 0) ||
		   ((fileinfo.fname[1] == '.') && (fileinfo.fname[2] == 0)))) return 0U;
		return (fileinfo.fattrib & AM_DIR) ? 2U : 1U;
	}
	if(fileinfo.fname[0] == '.') return 0U;		/* . and .., and dot files with no long name */
	fn = entry_name();
	if((fn[0] == '.') || (fn[0] == '_')) return 0U;	/* macOS sidecars and the like */
	if(fileinfo.fattrib & (AM_VOL | AM_HID | AM_SYS)) return 0U;

	is_dir = (fileinfo.fattrib & AM_DIR) ? 1U : 0U;
	if(lone_scan)
	{
		/* a card with one game (browser_lone_rom): every file counts but
		   the kernels and the settings, shown in the list or not */
		if(is_dir) return 2U;
		n = (UINT8)strlen(fn);
		if((n >= 4U) && same_name(fn + n - 4U, ".DAT")) return 0U;
		if(same_name(fn, "EZGB.CFG") || same_name(fn, "FLAUNCH.CFG")) return 0U;
		return 1U;
	}
	if(hidden_ending(fn)) return 0U;
	if(same_name(fn, "EZGB.CFG")) return 0U;
	if(same_name(fn, "FLAUNCH.CFG")) return 0U;
	if(same_name(fn, "SAVER")) return 0U;		/* the kernel's save folder, or a file in its way */
	if(hide_listed(fn)) return 0U;			/* the card's own list */
	return is_dir ? 2U : 1U;
}

/* ---- the keys ---- */

static void keys_page(void)
{
	hw_set_page(A000Address_SRAM);
	HW_BANK = KEY_BANK;
}

static UINT8 plays_mode;		/* plays_active() for this listing */

/* The class byte is 0 for a folder, 1 for a starred file and 2 for any
   other file, so stars come right after the folders. With SORT BY PLAYS
   the next byte is 255 less the launches, most played first, and the name
   starts a byte later (docs/stars.md). */
static void key_store(UINT16 n, UINT8 cls, const char *fn)
{
	UINT8 i = 1U;
	UINT8 c;
	UINT8 *k;
	UINT8 launches;

	key_a[0] = (cls == 2U) ? 0U : 2U;
	if((cls != 2U) && plays_mode)
	{
		if(plays_lookup((const UINT8 *)fn, &launches) & 1U) key_a[0] = 1U;
		if(plays_mode & 2U)
		{
			key_a[1] = (UINT8)(255U - launches);
			i = 2U;
		}
	}
	for(; i < 14U; i++)
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
			RANKS[ord] = (k[0] == 1U) ? (UINT16)(i | 0x8000U) : i;	/* bit 15: starred */
			k += KEY_LEN;
		}
		else
		{
			RANKS[i] = i;
		}
	}
}

/* ---- records ---- */

static UINT8 list_cut;			/* the folder had more than the list holds: card order */

#define BUF_A	(SD_buffer)
#define BUF_B	(SD_buffer + 0x100U)

static UINT8 *rec_at(UINT16 row)
{
	hw_set_page(A000Address_SRAM);
	HW_BANK = Folder_sram_bank + (UINT8)(row / Num_perBank);
	return (UINT8 *)&pFilename_buffer[row % Num_perBank];
}

/* Records a and b change places, through SD_buffer, which a listing only
   uses for the hide list while it reads the card. In pieces, as the zh
   record is longer than half of it. */
static void rec_swap(UINT16 a, UINT16 b)
{
	UINT16 off;
	UINT16 len;

	for(off = 0U; off < sizeof(FM_FILE_FS); off += 0x100U)
	{
		len = sizeof(FM_FILE_FS) - off;
		if(len > 0x100U) len = 0x100U;
		memcpy(BUF_A, rec_at(a) + off, len);
		memcpy(BUF_B, rec_at(b) + off, len);
		memcpy(rec_at(b) + off, BUF_A, len);
		memcpy(rec_at(a) + off, BUF_B, len);
	}
}

/* Row a is the row before b and their keys are the same: 1 when b's name
   comes first, case aside, and they have changed places */
static UINT8 rec_order(UINT16 a, UINT16 b)
{
	const UINT8 *p = BUF_A;
	const UINT8 *q = BUF_B;
	UINT8 ca;
	UINT8 cb;

	memcpy(BUF_A, rec_at(a), MAX_filename_len);
	memcpy(BUF_B, rec_at(b), MAX_filename_len);
	while(1)
	{
		ca = up(*p++);
		cb = up(*q++);
		if(ca != cb) break;
		if(!ca) return 0U;
	}
	if(ca < cb) return 0U;
	rec_swap(a, b);
	return 1U;
}

/* The sorted keys only hold the start of a name. Rows whose keys are the
   same but for the entry's number are next to each other: each such run is
   put in order by the whole names, an insertion sort on the records. */
static void ties_fix(UINT16 n)
{
	UINT16 i;
	UINT16 j;
	UINT16 start = 0U;
	UINT8 *k;

	for(i = 1U; i < n; i++)
	{
		keys_page();
		k = KEYS + i * KEY_LEN;
		if(memcmp(k - KEY_LEN, k, KEY_LEN - 2U))
		{
			start = i;
			continue;
		}
		for(j = i; j > start; j--) if(!rec_order((UINT16)(j - 1U), j)) break;
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
	UINT8 star;
	UINT8 *name;
	UINT16 n = 0U;
	UINT16 k;
	UINT16 row;
	UINT8 slot;

	game_folder_total = 0;
	Read_file_end = 1;			/* everything is read here: scrolling never touches the card */
	readdir_fail = 0;

	hide_load();
	plays_mode = plays_active();

	/* the keys */
	if(!open_dir()) return;
	while((cls = next_entry(3U)) != 0U)
	{
		if(n >= LIST_MAX)
		{
			cut = 1U;
			break;
		}
		key_store(n, cls, entry_name());
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
		star = (row & 0x8000U) ? 1U : 0U;
		row &= 0x7FFFU;
		HW_BANK = Folder_sram_bank + (UINT8)(row / Num_perBank);
		slot = (UINT8)(row % Num_perBank);
		name = pFilename_buffer[slot].filename;

		pFilename_buffer[slot].fattrib = (cls == 2U) ? AM_DIR : (star ? FATTR_STARRED : 0x20);
#ifdef LANG_ZH
		pFilename_buffer[slot].fsize = fileinfo.fsize;	/* size column shown by the zh list */
#endif
		strncpy((char *)name, entry_name(), MAX_filename_len - 1);
		name[MAX_filename_len - 1] = 0;
	}
	/* a short second read (the card stopped answering) leaves rows unwritten,
	   and readdir_fail set: the caller reports it and shows no list */
	game_folder_total = n;
	list_cut = cut;
	if(!cut && !readdir_fail && (k == n)) ties_fix(n);

	hw_set_page(A000Address_TF);
	if(cut) cut_box();		/* msgbox.c */
}

/* ---- a card with one game ---- */

/* 1 when the card's root has exactly one file, a .gb or .gbc, whatever
   folders it has: its name is then in lfname_temp (docs/fast-launch.md,
   "A lone ROM"). Kernels (*.dat), the settings file and dot files are not
   counted; a save, a text file or a hidden name beside the game is, as in
   the 0918 mod, so such a card opens the list. */
UINT8 browser_lone_rom(void) __banked
{
	extern TCHAR lfname_temp[];
	extern TCHAR currentpath_temp[];
	UINT8 cls;
	UINT8 files = 0U;
	UINT8 n;
	const char *fn;

	memset(&fileinfo, 0, sizeof(fileinfo));
	fileinfo.lfname = lfname_temp;
	fileinfo.lfsize = MAX_filename_len;
	readdir_fail = 0;
	if(!open_dir()) return 0U;
	lone_scan = 1U;
	while((cls = next_entry(3U)) != 0U)
	{
		if(cls == 2U) continue;
		if(++files > 1U) break;
		fn = entry_name();
		n = (UINT8)strlen(fn);
		if(!(((n > 3U) && same_name(fn + n - 3U, ".GB")) ||
		     ((n > 4U) && same_name(fn + n - 4U, ".GBC"))))
		{
			files = 2U;
			break;
		}
		/* kept aside: the entries read after it go through lfname_temp */
		strcpy(currentpath_temp, fn);
	}
	lone_scan = 0U;
	if(files != 1U) return 0U;
	strcpy(lfname_temp, currentpath_temp);
	return 1U;
}

/* ---- clean names ---- */

/* A name's length as the list draws it (docs/browser.md "Clean names").
   With CLEAN NAMES on a file's name is cut at the first " (" or " [", else
   at its last '.', with blanks before the cut dropped: "Tetris (World)
   (Rev 1).gb" and "Tetris.gb" both show as "Tetris". A name that starts
   with a tag or a dot is left alone, and a folder is never cut. The record
   keeps the whole name: only the drawing is shorter. */
UINT8 name_shown(const FM_FILE_FS *e) __banked
{
	const UINT8 *s = e->filename;
	UINT8 i;
	UINT8 cut = 0xFFU;

	if(tags_hide && (e->fattrib != AM_DIR))
	{
		for(i = 0U; (i < 0xFEU) && s[i]; i++)
		{
			if((i >= 2U) && (s[i - 1U] == ' ') && ((s[i] == '(') || (s[i] == '[')))
			{
				cut = (UINT8)(i - 1U);
				break;
			}
			if((i >= 1U) && (s[i] == '.')) cut = i;
		}
		while((cut != 0xFFU) && (cut > 1U) && (s[cut - 1U] == ' ')) cut--;
		if(cut != 0xFFU) return cut;
	}
	for(i = 0U; (i < 0xFEU) && s[i]; i++) {}
	return i;
}

/* ---- after a star ---- */

/* The cursor goes with the game that was starred (plays.c keeps which): on
   the screen row it was on when the list reaches that far, else as near. */
static void follow(UINT16 *show_offset, UINT8 *file_select)
{
	UINT16 i;
	UINT16 off;
	UINT16 max;
	UINT8 m;

	for(i = 0U; i < game_folder_total; i++)
	{
		m = follow_match(((FM_FILE_FS *)rec_at(i))->filename);
		if(m == 0U) return;
		if(m == 2U)
		{
			max = (game_folder_total > LIST_ROWS) ? (UINT16)(game_folder_total - LIST_ROWS) : 0U;
			off = (i >= *file_select) ? (UINT16)(i - *file_select) : 0U;
			if(off > max) off = max;
			*show_offset = off;
			*file_select = (UINT8)(i - off);
			break;
		}
	}
	follow_clear();
}

/* A game was starred or unstarred, so it has a new place in the list. The
   records are all in save RAM: the keys are made again from them and
   sorted, and the records are moved to their rows, each straight to where
   it goes. Nothing is read from the card. A folder that was cut is in
   card order, and there only the marks change. */
void list_resort(UINT16 *show_offset, UINT8 *file_select) __banked
{
	extern TCHAR lfname_temp[];
	FM_FILE_FS *e;
	UINT16 n = game_folder_total;
	UINT16 i;
	UINT16 r;
	UINT16 t;
	UINT8 launches;
	UINT8 dir_e;

	plays_mode = plays_active();
	if(list_cut)
	{
		for(i = 0U; i < n; i++)
		{
			e = (FM_FILE_FS *)rec_at(i);
			if(e->fattrib == AM_DIR) continue;
			strcpy(lfname_temp, (const char *)e->filename);
			r = plays_lookup((const UINT8 *)lfname_temp, &launches);
			((FM_FILE_FS *)rec_at(i))->fattrib = (r & 1U) ? FATTR_STARRED : 0x20;
		}
	}
	else
	{
		for(i = 0U; i < n; i++)
		{
			e = (FM_FILE_FS *)rec_at(i);
			dir_e = (e->fattrib == AM_DIR) ? 2U : 1U;
			/* a copy: looking the name up maps the table over the record */
			strcpy(lfname_temp, (const char *)e->filename);
			key_store(i, dir_e, lfname_temp);
		}
		keys_sort(n);
		ranks_build(n, 1U);
		for(i = 0U; i < n; i++)
		{
			while(1)
			{
				keys_page();
				r = RANKS[i];
				t = r & 0x7FFFU;
				if(t == i) break;
				rec_swap(i, t);			/* the record of row i goes home, to row t */
				keys_page();
				RANKS[i] = RANKS[t];
				RANKS[t] = r;
			}
			e = (FM_FILE_FS *)rec_at(i);
			if(e->fattrib != AM_DIR) e->fattrib = (r & 0x8000U) ? FATTR_STARRED : 0x20;
		}
		ties_fix(n);
	}
	follow(show_offset, file_select);
	hw_set_page(A000Address_TF);
}
