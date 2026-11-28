#include <gb/gb.h>
#include "ezgb_hw.h"
//#include <stdio.h>
#include <string.h>
#include <stdio.h>
#include <gbdk/console.h>
#include "Bank_fun.h"
#include "main.h"
UINT8 pad_take(void);	/* mod: sgb.s */
UINT8 cfg_played(UINT8 *dst) __banked;	/* mod: ezcfg.c */
void mq_start(const UINT8 *s, UINT8 x, UINT8 row, UINT8 cells, UINT8 ink, UINT8 paper) __banked;	/* mod: modmisc.c, a name that scrolls */
void mq_step(void) __banked;
#include "RTC.h"
#include "list12.h"		/* mod: the 12px list */
#include "UI.h"		/* Show_Error_file() - reported when the ROM's FAT chain is unusable */
#include "SD_operate.h"	/* sd_err_lba: sector that the read retry gave up on */

#define BANK_FUN_BANK
#include "banks.h"

#ifdef LANG_ZH
#include "ui_zh.h"		/* Chinese list renderer (list_zh.c) */
#include "zh_bg.h"		/* tracks the color() background (zh_text_row uses it to fill a row) */
#endif

#define psRAMBase_S3350	0xA000

extern FIL gfil;

enum CartridgeTypes m_Type;
UINT8 m_iROMSize;
UINT8 m_iRAMSize;
UINT8 m_iVersion;
BOOL m_bBattery;
BOOL m_bRTCPresent;
BOOL m_bRumblePresent;
	extern TCHAR currentpath_temp[MAX_path_len];
	extern TCHAR currentpath[MAX_path_len];

	extern TCHAR lfname_temp[MAX_path_len];


extern UINT16 ROMBankCount_real;
extern  UINT8 Header_Checksum;

UINT32 lasttime;
UINT8 is_lasttime;

UINT16 CheckSUM;

#ifdef LANG_ZH
/* GBDK-2020's char is signed (TCHAR = char): bytes of a GBK name >= 0x80
   become negative, so the "reject control chars" test (c < 0x20) kills the name.
   Result: game_name_is_sane rejects it, LoadSAVE2SRAM returns 2 at once,
   nothing is written to SRAM: no "save?" prompt on the next boot and the .sav
   is never created (why Chinese-named games could not save). Compare unsigned.
   The English build keeps its semantics ((c) < 0x20) and identical code. */
#define CHAR_IS_CTRL(c)  ((UINT8)(c) < 0x20)
#else
#define CHAR_IS_CTRL(c)  ((c) < 0x20)
#endif

// --------------------------------------------------------------------
static const char HEXD[] = "0123456789ABCDEF";

static void put_hex6(char *p, UINT32 v)
{
	p[0] = HEXD[(UINT8)((v >> 20) & 0x0F)];
	p[1] = HEXD[(UINT8)((v >> 16) & 0x0F)];
	p[2] = HEXD[(UINT8)((v >> 12) & 0x0F)];
	p[3] = HEXD[(UINT8)((v >> 8) & 0x0F)];
	p[4] = HEXD[(UINT8)((v >> 4) & 0x0F)];
	p[5] = HEXD[(UINT8)(v & 0x0F)];
}

/* Report a FatFs result and RECOVER instead of the old while(1) dead loop.
   On-screen layout (diagnostic build):
        row 0  "File system error!"
        row 1  FRESULT, two digits
        row 4  stage, then the sector whose read never completed
        row 6  fs->cdir, fs->dirbase, fs->csize
        row 8  the path that was being resolved
   stage: 1 f_chdir, 2 f_opendir, 3/4 f_readdir pass 1/2, 9 opendir inside the scan.
   Lives in bank 1: bank 0 has no room left. */
void Show_error_info(UINT8 code, UINT8 stage, const char *path)__banked
{
	char s[3];
	char h[9];
	char g[17];
	char w[18];
	UINT8 n;

	s[0] = (char)('0' + (UINT8)((code / 10U) % 10U));
	s[1] = (char)('0' + (UINT8)(code % 10U));
	s[2] = 0;

	h[0] = (char)('0' + stage);
	h[1] = ' ';
	h[2] = HEXD[sd_err_lba[2] >> 4];
	h[3] = HEXD[sd_err_lba[2] & 0x0F];
	h[4] = HEXD[sd_err_lba[1] >> 4];
	h[5] = HEXD[sd_err_lba[1] & 0x0F];
	h[6] = HEXD[sd_err_lba[0] >> 4];
	h[7] = HEXD[sd_err_lba[0] & 0x0F];
	h[8] = 0;

	put_hex6(g, EZcardFs.cdir);
	g[6] = ' ';
	put_hex6(&g[7], EZcardFs.dirbase);
	g[13] = ' ';
	g[14] = HEXD[EZcardFs.csize >> 4];
	g[15] = HEXD[EZcardFs.csize & 0x0F];
	g[16] = 0;

	Draw_Text(UI_ERR_FS, 0, 1, 0);
	Draw_Text((UINT8 *)s, 2, 1, 1);
	Draw_Text((UINT8 *)h, 8, 1, 4);
	Draw_Text((UINT8 *)g, 16, 1, 6);

	/* row 8: fs->winsect then the path. winsect tells whether the FatFs window
	   still holds the sector it claims to (a mismatch means the window was
	   filled with something else than the card). */
	put_hex6(w, EZcardFs.winsect);
	w[6] = ' ';
	n = 7U;
	if(path)
	{
		while(n < 17U && path[n - 7U]) { w[n] = path[n - 7U]; n++; }
	}
	if(n > 7U) Draw_Text((UINT8 *)w, n, 1, 8);

	while(joypad() != J_B) delay(50);
	while(joypad() & J_B) delay(50);
}
//---------------------------------------------------------------------------------
void mystrcat(char *dst,const char *src)__banked
{
	char *p=dst;
	while(*p!='\0')p++;
	while(*src != '\0')*p++=*src++;
	*p='\0';
}

UINT8 mystrcat_n(char *dst,const char *src,UINT16 cap)__banked
{
	UINT16 n = 0;

	while((n < cap) && (dst[n] != '\0')) n++;
	if(n >= cap) return 1;				/* dst is not terminated: refuse */

	while(*src != '\0')
	{
		if((n + 1) >= cap)
		{
			dst[n] = '\0';
			return 1;
		}
		dst[n++] = *src++;
	}
	dst[n] = '\0';
	return 0;
}

//---------------------------------------------------------------------------------
int mystrcmp(const char *str1,const char *str2)__banked
{
    /* Do NOT use while(*str1++==*str2++): the ++ still runs once when they differ.
    Returns the difference of the two characters; ++ lives in the loop body. */
    while(*str1 == *str2)
    {
        if(*str1 == '\0')
            return 0;
         
        str1++;
        str2++;
    }
    return *str1 - *str2;
}

//---------------------------------------------------------------------------------
char *my_strrchr(const char *s, char c)__banked
{
	char *p_char = NULL;	
	if(s == NULL)
	{
		return NULL;
	}

	while(*s != '\0')
	{
		if(*s == (char)c)
		{
			p_char = (char *)s;
		}
		s++;
	}

	return p_char;
}

//---------------------------------------------------------------------------------
/* mod: where the save dialog's messages go. In the English build the dialog
   is the mod's band (Show_SAVE_info), with a message row and room under it. */
#ifdef LANG_ZH
#define SAVE_MSG_COL	5
#define SAVE_MSG_ROW	10
#define SAVE_MSG_ROW2	11
#define SAVE_MSG_ROW3	12
#else
/* the message row is the buttons' row, which is empty by then: row 9 has
   the Played line */
#define SAVE_MSG_COL	1
#define SAVE_MSG_ROW	11
#endif
#define SAVE_DOT_COL	11

void list8_counter(UINT16 n) __banked;	/* mod: list8.c, the position in the folder */
void list8_row(const FM_FILE_FS *e, UINT8 y) __banked;	/* mod: list8.c, a row's icon and name */

void Show_filename(UINT16 show_offset,UINT16 file_select)__banked
{
#if defined(LANG_ZH) && !defined(ZH_LIST_OFF)
	/* zh build: 12px bitmap list, LIST_ROWS rows per screen. See list_zh.c.
	   The English branch below is untouched, byte for byte. */
	list_zh_show(show_offset, file_select);
	return;
#endif
#ifndef LANG_ZH
	if(ui_font)		/* mod: the 12px list, list12.c */
	{
		list12_show(show_offset, file_select);
		return;
	}
#endif
	
	UINT16 need_show;
	
	UINT8 line;
	UINT8 cur_page = 0xFF;	/* cached SRAM page: skip redundant 0x4000 writes */
	
	UINT8 BANK_index;
	UINT8 BANK_num;
	
	UINT8 x_offset= 0;	
	UINT8 y_offset= 2;	
	UINT8 offset=0; // adjust if there are more than 255 folders
	

	if(show_offset >= game_folder_total)
	{
		need_show = 0;
	}
	else
	{
		need_show = game_folder_total-show_offset;
		if(need_show > 16)
			need_show = 16;
	}
	
	color(BLACK,WHITE,SOLID);
	for(line=0;line<need_show;line++)
	{
	
		if(line== file_select)
		{			
			/*color(BLACK,WHITE,SOLID);// selected frame colour
			box(0,y_offset+ file_select*14-2,159,y_offset+ file_select*14+12,M_NOFILL);
			color(BLACK,WHITE,SOLID);	// text colour */
			color(WHITE,BLACK,SOLID);	/* mod: the selected row is white on black, which an original Game Boy can read (was black on dark gray) */
		}			
		
		BANK_num = (show_offset+line)/Num_perBank;
		BANK_index = (show_offset+line)%Num_perBank;	
		
		if((Folder_sram_bank+BANK_num) != cur_page)
		{
			HW_BANK = Folder_sram_bank+BANK_num;
			cur_page = Folder_sram_bank+BANK_num;
		}
		
		list8_row(&pFilename_buffer[BANK_index], (UINT8)(y_offset + line));	/* mod: icon and name; folders had a DIR tag */
		
		color(BLACK,WHITE,SOLID);
	
	}

	list8_counter((UINT16)(show_offset + file_select));	/* mod: n/total */
		
}

//---------------------------------------------------------------------------------
void Refresh_filename(UINT16 show_offset,UINT16 file_select,UINT8 updown)__banked
{
#if defined(LANG_ZH) && !defined(ZH_LIST_OFF)
	list_zh_refresh(show_offset, file_select, updown);
	return;
#endif
#ifndef LANG_ZH
	if(ui_font)		/* mod: the 12px list, list12.c */
	{
		list12_refresh(show_offset, file_select, updown);
		return;
	}
#endif

	UINT8 x_offset= 0;
	UINT16 y_offset= 2;	
	UINT8 xx1;
	UINT8 xx2;
	UINT16 showy1;
	UINT16 showy2;	
	UINT8 cur_page = 0xFF;	/* cached SRAM page */
	UINT8 BANK_index;
	UINT8 BANK_num;
	
	if(updown ==2) //down
	{
		xx1 = file_select-1;
		xx2 = file_select;
		showy1 = y_offset +(file_select-1);
		showy2 = y_offset +(file_select);
	}
	else// if(updown ==3)//up
	{
		xx1 = file_select;
		xx2 = file_select+1;
		showy1 = y_offset +(file_select);
		showy2 = y_offset +(file_select+1);			
	}
	//color(BLACK,WHITE,SOLID);// text colour
	
	BANK_num = (show_offset+xx1)/Num_perBank;
	BANK_index = (show_offset+xx1)%Num_perBank;			
	if((Folder_sram_bank+BANK_num) != cur_page)
	{
		HW_BANK = Folder_sram_bank+BANK_num;
		cur_page = Folder_sram_bank+BANK_num;
	}
	
	if(updown==3)//up
	{
		color(WHITE,BLACK,SOLID);	/* mod: as in Show_filename */
	}
	else if(updown==2)
	{
		color(BLACK,WHITE,SOLID);
	}	
	list8_row(&pFilename_buffer[BANK_index], (UINT8)(showy1));	/* mod: icon and name; folders had a DIR tag */
	
	if(updown==3)//up
	{
		color(BLACK,WHITE,SOLID);
	}		
	else if(updown==2)
	{
		color(WHITE,BLACK,SOLID);	/* mod: as in Show_filename */
	}	
	
	BANK_num = (show_offset+xx2)/Num_perBank;
	BANK_index = (show_offset+xx2)%Num_perBank;			
	if((Folder_sram_bank+BANK_num) != cur_page)
	{
		HW_BANK = Folder_sram_bank+BANK_num;
		cur_page = Folder_sram_bank+BANK_num;
	}

	list8_row(&pFilename_buffer[BANK_index], (UINT8)(showy2));	/* mod: icon and name; folders had a DIR tag */
	
	color(BLACK,WHITE,SOLID);

	list8_counter((UINT16)(show_offset + file_select));	/* mod: n/total */
}

// --------------------------------------------------------------------
void Set_GBboy(UINT8 select)__banked
{ 
  HW_BEGIN();
	HW_FAST_ADD = 0;		/* mod: stage1 leaves the console's boot A here, 0x11 only on a color console */
	HW_GBBOY_MODE = select;
	HW_END(); 
}	
//---------------------------------------------------------------------------------
// --------------------------------------------------------------------
void Save_filename(void)__banked
{//save filename
	UINT16 count;
	UINT8 res;
	UINT16 saved_len;
	
	/* currentpath means "current directory"; the file name is appended only
	   to write SRAM. It MUST be restored before returning: otherwise a failed
	   launch would goto refind_file, f_chdir to a file path (always fails) and
	   hang in Show_error_info() until the batteries are pulled. */
	saved_len = (UINT16)strlen(currentpath);
	
	res =  mystrcmp(currentpath,"/");
	if(res !=0){	
		if(mystrcat_n(currentpath,"/",MAX_path_len))
		{
			currentpath[saved_len] = 0;		/* restore; never hand the truncated path to the caller */
			return;
		}
	}
	if(mystrcat_n(currentpath,lfname_temp,MAX_path_len))
	{
		currentpath[saved_len] = 0;
		return;
	}
	
	HW_BANK = SAVE_info_sram_bank;
	hw_set_page(A000Address_SRAM);
	for(count=0;count<MAX_path_len;count++)
	{
		*((volatile UINT8 *)(FlashBase_SRAM+0x300+count)) = currentpath[count] ;
	}
	/* Set the "pending write" flag; on the next boot Recently_Commit() appends
	   it to /SAVER/RecentlyPlay_gb.txt. Do NOT touch the card here: rewriting a file
	   under /SAVER before launching corrupts the directory entry (0x2FF is the
	   free byte right before the 0x300 path area). */
	*((volatile UINT8 *)(FlashBase_SRAM+0x2FF)) = 0xA5;
	HW_BANK = 0;
	hw_set_page(A000Address_TF);

	/* Append this path to /SAVER/RecentlyPlay_gb.txt now (append, never rewrite).
	   currentpath still holds "dir/name" here, which is exactly what we need.
	   If the write fails the 0x2FF flag stays set and Recently_Commit() retries. */
	Recently_Add(currentpath);

	currentpath[saved_len] = 0;		/* restore the directory path for the caller */
}

/* ==========================================================================
   Recently played games: /SAVER/RecentlyPlay_gb.txt
   --------------------------------------------------------------------------
   Format: one full path per line, newest first, at most RECENT_MAX lines. A game
   that starts again moves to line 1 instead of being duplicated.

   Two hardware constraints to keep in mind:
   1) Buffers of f_read / f_write must not live in the 0xA000 window. While FatFs
      reads the card that window is mapped to the TF page, so 0xA000 does not hold
      SRAM data at all. Everything between SRAM and SD goes through WRAM.
   2) The records are kept in the list area (from bank 18), shared with the
      directory list, so returning with B must re-read the directory (refind_file).
   ========================================================================== */

/* Paths must live in WRAM - never use string literals!
   f_open/f_mkdir are __banked and switch to FatFs' bank while running, but this
   file is compiled into bank 1, so a literal sits at 0x4000-0x7FFF. After the
   bank switch that address holds another bank's data: f_open gets garbage and
   creates a garbage file name in the root directory. (All existing call sites
   pass WRAM buffers such as currentpath / lfname_temp.)

   The trap is not limited to paths: no buffer passed to a __banked function may
   point into this bank's ROM. `f_write_bank(&gfil, "\n", 1, &bw)` hit it: f_write
   lives in bank 7 and read code instead of '\n', merging all records into one line.
   Hence the CR/LF bytes below are a local array as well (the stack is in WRAM).

   Note that bank 0 literals (0x0600-0x3FFF) are visible from every bank, so
   f_mkdir_bank("/SAVER") in main.c is safe and needs no change. */

/* Always size buffers with sizeof(literal) so length + '\0' is computed right.
   A subtle bug lived here: recent_path was 24 bytes while the file name is
   exactly 24 characters, so 25 bytes were needed. The extra '\0' landed in the
   neighbouring recent_dir[0], which the later "/SAVER" copy overwrote with '/',
   producing "/SAVER/RecentlyPlay_gb.txt/SAVER". FatFs returned FR_NO_PATH and
   f_open only creates on FR_NO_FILE: no file was created and no error shown. */
#define RECENT_FILE_NAME "/SAVER/RecentlyPlay_gb.txt"
#define RECENT_DIR_NAME  "/SAVER"

static TCHAR recent_path[sizeof(RECENT_FILE_NAME)];
static TCHAR recent_dir[sizeof(RECENT_DIR_NAME)];

/* Copy the path into WRAM at run time. Not a static initialised array, because
   that would put it in _INITIALIZED and rely on the crt0 copy; this per-byte copy
   runs in this bank, where reading the literal is safe (no bank switch). sizeof
   includes the trailing '\0', so the length matches the buffer. */
static void recent_set_paths(void)
{
	UINT8 i;

	for(i = 0; i < (UINT8)sizeof(RECENT_FILE_NAME); i++)
		recent_path[i] = (TCHAR)RECENT_FILE_NAME[i];

	for(i = 0; i < (UINT8)sizeof(RECENT_DIR_NAME); i++)
		recent_dir[i] = (TCHAR)RECENT_DIR_NAME[i];
}

/* Rows that fit on screen: row 0 is the title, row 1 is reserved for the two
   separator lines, and the bottom bar starts at y=128 (row 16), so rows 2..15
   are usable - 14 rows (y=16..127). Starting at row 1 would fit 15 rows, but the
   first row would paint over both separator lines, so we keep row 2.
   RECENT_MAX is also the number of ring-buffer slots. */
#define RECENT_MAX    14		/* max rows on screen (also the ring-buffer slot count) */
#define RECENT_CHUNK  32		/* SRAM<->SD staging buffer size */
#define RECENT_ROW_TOP 2		/* first list row (row 0 title, row 1 separators); bottom bar from y=128 */
#define RECENT_NAME_X    1		/* column 0 is reserved for the '>' cursor */
#define RECENT_NAME_COLS 19		/* 20 screen columns minus the cursor column */
#define RECENT_SCROLL_DELAY 30	/* dwell loops before scrolling a long selected name (~0.5s) */
#define RECENT_SCROLL_STEP  20	/* loops per 1-character step: larger = slower (20 ~ 333ms) */
#define RECENT_TAIL_BYTES 4096	/* read only the last N bytes of the file (enough for ~15 records) */
#define RECENT_COMPACT_AT 8192	/* rewrite the whole file at boot once it grows this big (~400 boots) */
#define RECENT_FLAG_ADDR 0x2FF	/* "pending write" flag in SRAM (bank 17), just before the 0x300 path area */
#define RECENT_FLAG_MAGIC 0xA5

/* Copy entry src's name over entry dst (string part only: in a 255-byte slot
   only strlen+1 bytes matter, so copy just those - faster). Window must be SRAM. */
static void recent_copy_str(UINT8 dst, UINT8 src)
{
	UINT8 *d = pFilename_buffer[dst].filename;
	UINT8 *s = pFilename_buffer[src].filename;

	while((*d++ = *s++) != 0) ;
}

/* Put a WRAM path into list entry 0 (window must be mapped to SRAM) */
static void recent_put_str0(TCHAR *s)
{
	UINT8 *d = pFilename_buffer[0].filename;

	while((*d++ = (UINT8)*s++) != 0) ;
}

/* Clear the "pending write" flag in SRAM (bank 17) */
static void recent_clear_flag(void)
{
	HW_BANK = SAVE_info_sram_bank;
	hw_set_page(A000Address_SRAM);
	*((volatile UINT8 *)(FlashBase_SRAM + RECENT_FLAG_ADDR)) = 0;
	hw_set_page(A000Address_TF);
	HW_BANK = 0;
}

/* ==========================================================================
   Append one record (path + CRLF) to the log. Returns 0 on success (already last = 0).
   --------------------------------------------------------------------------
   **Append only**: f_open(FA_OPEN_ALWAYS) + f_lseek(end) + one f_write.
   Never FA_CREATE_ALWAYS, never truncate.

   Why this rule is hard: FA_CREATE_ALWAYS calls remove_chain to free the cluster
   chain. Log files left by older firmware may have a broken chain (possibly
   sharing clusters with the /SAVER directory); remove_chain would then free other
   files' clusters and data would land in the directory - every .sav name turned
   ========================================================================== */
static UINT8 recent_append(const TCHAR *path)
{
	UINT8  line[257];				/* 254-char path + CRLF */
	UINT16 len, written;
	FRESULT res;

	len = (UINT16)strlen((char*)path);
	if(len > 254) len = 254;
	memcpy(line, path, len);
	line[len++] = '\r';
	line[len++] = '\n';

	recent_set_paths();
	hw_set_page(A000Address_TF);

	if(f_open_bank(&gfil, recent_path, FA_READ | FA_WRITE | FA_OPEN_ALWAYS) != FR_OK)
	{
		/* mod: no /SAVER yet: make it and try once more, as the kernel of
		   2026-11-27 does */
		f_mkdir_bank(recent_dir);
		hw_set_page(A000Address_TF);
		if(f_open_bank(&gfil, recent_path, FA_READ | FA_WRITE | FA_OPEN_ALWAYS) != FR_OK) return 1;
	}

	/* The file already ends with this exact record (same game twice): do not
	   append again, or replaying one game would bloat the log. */
	if(f_size(&gfil) >= (DWORD)len)
	{
		UINT8  tail[260];
		UINT16 tr, j;
		UINT8  same = 1;

		f_lseek_bank(&gfil, f_size(&gfil) - (DWORD)len);
		if(f_read_bank(&gfil, tail, len, &tr) == FR_OK && tr == len)
		{
			for(j = 0; j < len; j++)
			{
				if(tail[j] != line[j]) { same = 0; break; }
			}
			if(same)
			{
				f_close_bank(&gfil);
				hw_set_page(A000Address_TF);
				HW_BANK = 0;
				return 0;				/* already the last record: treat as success */
			}
		}
	}

	f_lseek_bank(&gfil, f_size(&gfil));			/* seek to end */
	res = f_write_bank(&gfil, line, len, &written);
	f_close_bank(&gfil);
	hw_set_page(A000Address_TF);
	HW_BANK = 0;

	return (UINT8)((res != FR_OK) || (written != len));
}

/* ==========================================================================
   Merge one path into the list: drop a duplicate, insert at the front, keep <= RECENT_MAX.
   The list stays "newest first, one entry per path"; returns the new count.
   --------------------------------------------------------------------------
   Why insert while reading instead of filling a ring buffer first: the ring only
   holds RECENT_MAX lines, so duplicates would shrink the visible list (measured:
   3 duplicates among the last 14 lines left only 11 rows). A set is maintained
   instead, so any scan length can fill RECENT_MAX entries.
   ========================================================================== */
static UINT8 recent_insert(TCHAR *s, UINT8 n)
{
	UINT8 i, j;

	/* Already listed: delete it (shift the rest up); it is re-inserted at the front */
	for(i = 0; i < n; i++)
	{
		if(mystrcmp((char*)pFilename_buffer[i].filename, s) == 0)
		{
			for(j = i; (UINT8)(j + 1) < n; j++) recent_copy_str(j, (UINT8)(j + 1));
			n--;
			break;
		}
	}

	if(n >= RECENT_MAX) n = (UINT8)(RECENT_MAX - 1);	/* full: drop the oldest entry */

	for(j = n; j > 0; j--) recent_copy_str(j, (UINT8)(j - 1));

	recent_put_str0(s);
	return (UINT8)(n + 1);
}

/* ==========================================================================
   Read records: scan the file tail (<= RECENT_TAIL_BYTES) and maintain a list of
   "newest first, de-duplicated, <= RECENT_MAX" entries; returns the count.
   ========================================================================== */
UINT8 Recently_Load(void)__banked
{
	/* No local FIL here: with _FS_TINY=0 a FIL embeds a 512-byte sector buffer,
	   538 bytes each. The whole project shares gfil. */
	UINT8   buf[RECENT_CHUNK];
	TCHAR   cur[MAX_filename_len];		/* the line currently being assembled */
	UINT16  br;
	UINT8   n = 0;						/* number of entries */
	UINT8   len = 0;
	UINT8   i, c;
	UINT8   skip_head = 0;				/* when starting mid-file the first line is a fragment */
	FRESULT res;

	recent_set_paths();
	hw_set_page(A000Address_TF);
	if(f_open_bank(&gfil, recent_path, FA_READ) != FR_OK) return 0;

	if(f_size(&gfil) > RECENT_TAIL_BYTES)
	{
		f_lseek_bank(&gfil, f_size(&gfil) - RECENT_TAIL_BYTES);
		skip_head = 1;
	}

	while(1)
	{
		hw_set_page(A000Address_TF);
		res = f_read_bank(&gfil, buf, RECENT_CHUNK, &br);
		if(res != FR_OK || br == 0) break;

		HW_BANK = Folder_sram_bank;
		hw_set_page(A000Address_SRAM);

		for(i = 0; i < (UINT8)br; i++)
		{
			c = buf[i];

			if(skip_head)				/* no newline seen yet: this line is a fragment */
			{
				if(c == '\n') skip_head = 0;
				continue;
			}
			if(c == '\r') continue;			/* tolerate CRLF */
			if(c == '\n')
			{
				if(len)
				{
					cur[len] = 0;
					n = recent_insert(cur, n);
					len = 0;
				}
				continue;
			}
			if(len < MAX_filename_len - 1) cur[len++] = (TCHAR)c;
		}
	}

	if(len && !skip_head)				/* the last line may lack '\n' */
	{
		cur[len] = 0;
		HW_BANK = Folder_sram_bank;
		hw_set_page(A000Address_SRAM);
		n = recent_insert(cur, n);
	}

	f_close_bank(&gfil);
	hw_set_page(A000Address_TF);
	HW_BANK = 0;
	return n;
}

/* ==========================================================================
   Record one launch: called right before booting, so the entry shows up at once.
   Nothing is written when fullpath is invalid (not absolute / has control chars).
   On failure the SRAM flag remains and Recently_Commit() retries at next boot.
   ========================================================================== */
void Recently_Add(TCHAR *fullpath)__banked
{
	UINT8 i;

	if(fullpath == NULL || *fullpath == 0) return;
	if(fullpath[0] != '/') return;
	for(i = 0; fullpath[i] != 0; i++)
		if(CHAR_IS_CTRL(fullpath[i])) return;

	if(recent_append(fullpath) == 0)
		recent_clear_flag();		/* clear the flag only after a successful write */
}

/* ==========================================================================
   Rewrite the whole file when it gets too big (keep the newest RECENT_MAX).
   --------------------------------------------------------------------------
   The log is append-only and unbounded: one line per launch, growing forever
   (reads only touch the last 4KB, so boot time is unaffected, but clusters).
   This compaction runs at boot, before reading the directory:
     1) load the newest RECENT_MAX entries into the list area;
     2) FA_CREATE_ALWAYS the file (it is the file we appended ourselves, so its
        chain is intact and remove_chain frees only its own clusters);
     3) re-append them oldest-first.
   RECENT_COMPACT_AT = 8KB, about 20 bytes per line, so roughly every 400 boots.
   ========================================================================== */
static void recent_compact_if_needed(void)
{
	UINT8  k, i;
	TCHAR  wbuf[MAX_path_len];
	UINT16 j;

	recent_set_paths();
	hw_set_page(A000Address_TF);
	if(f_open_bank(&gfil, recent_path, FA_READ) != FR_OK) return;
	k = (UINT8)(f_size(&gfil) > RECENT_COMPACT_AT);
	f_close_bank(&gfil);
	hw_set_page(A000Address_TF);
	HW_BANK = 0;
	if(!k) return;

	Show_recent();							/* mod: as the kernel of 2026-11-27 */
	k = Recently_Load();					/* newest first */
	if(k == 0) return;

	hw_set_page(A000Address_TF);
	if(f_open_bank(&gfil, recent_path, FA_CREATE_ALWAYS | FA_WRITE) != FR_OK) return;
	f_close_bank(&gfil);
	hw_set_page(A000Address_TF);
	HW_BANK = 0;

	for(i = k; i-- > 0; )					/* write backwards so the oldest ends up first */
	{
		HW_BANK = Folder_sram_bank;
		hw_set_page(A000Address_SRAM);
		for(j = 0; j < MAX_path_len - 1 && pFilename_buffer[i].filename[j]; j++)
			wbuf[j] = (TCHAR)pFilename_buffer[i].filename[j];
		wbuf[j] = 0;
		hw_set_page(A000Address_TF);
		HW_BANK = 0;

		if(recent_append(wbuf) != 0) return;	/* stop on failure; the next boot retries */
	}
}

/* ==========================================================================
   Boot-time catch-up: if the SRAM "pending write" flag is still set (the append
   failed or did not happen last time), add that path to the log.
   ========================================================================== */
void Recently_Commit(void)__banked
{
	UINT8  flag, i;
	UINT8  line[257];
	FRESULT res;

	/* first check whether compaction is due (almost always returns here) */
	recent_compact_if_needed();

	HW_BANK = SAVE_info_sram_bank;
	hw_set_page(A000Address_SRAM);
	flag = *((volatile UINT8 *)(FlashBase_SRAM + RECENT_FLAG_ADDR));
	if(flag != RECENT_FLAG_MAGIC)
	{
		hw_set_page(A000Address_TF);
		HW_BANK = 0;
		return;
	}
	for(i = 0; i < 254; i++)
		line[i] = *((volatile UINT8 *)(FlashBase_SRAM + 0x300 + i));
	line[254] = 0;
	hw_set_page(A000Address_TF);
	HW_BANK = 0;

	if(line[0] != '/') { recent_clear_flag(); return; }
	for(i = 0; line[i] != 0; i++)
		if(line[i] < 0x20) { recent_clear_flag(); return; }

	Show_recent();							/* mod: as the kernel of 2026-11-27 */
	res = (FRESULT)recent_append(line);
	if(res == FR_OK) recent_clear_flag();
}

/* The 8px console versions of the recent list: the English build uses these,
   the Chinese build draws the same screen with list_zh_recent* (12px APA),
   so there is no point compiling them into the zh image. */
#ifndef LANG_ZH
/* Show the recently played list.
   The cursor is a '>' at the start of the line: BGP is a global register, a single
   row cannot have its own background - why color(BLACK,DKGREY) seems inert there.

   Names are always drawn from character 1 and truncated if needed (the selected
   row scrolls via Show_recent_scroll). The old code kept the tail (name += len-18),
   so a 20-character name lost its first 2 characters. */
void Show_recent_list(UINT8 count, UINT8 sel)__banked
{
	UINT8  i, j, len;
	UINT8 *p;
	TCHAR *name;
	UINT8  line[RECENT_NAME_COLS + 1];

#ifndef LANG_ZH
	if(ui_font)		/* mod: the 12px recent list, list12.c */
	{
		recent12_show(count, sel);
		return;
	}
#endif
	HW_BANK = Folder_sram_bank;
	/* The records live in the A000 window, so the window must be mapped to SRAM.
	   Recently_Load leaves it on the TF page (needed for card access); setting only
	   HW_BANK would read card data and the list would be garbage. */
	hw_set_page(A000Address_SRAM);

	for(i = 0; i < count; i++)
	{
		p = pFilename_buffer[i].filename;

		name = my_strrchr((char*)p, '/');	/* show the file name only; the full path is too long */
		name = (name == NULL) ? (TCHAR*)p : name + 1;

		len = (UINT8)strlen(name);

		for(j = 0; j < RECENT_NAME_COLS; j++) line[j] = ' ';	/* fixed width: wipes leftovers from the previous screen */
		for(j = 0; j < len && j < RECENT_NAME_COLS; j++) line[j] = (UINT8)name[j];
		line[RECENT_NAME_COLS] = 0;

		Draw_Text(line, RECENT_NAME_COLS, RECENT_NAME_X, (UINT8)(i + RECENT_ROW_TOP));
		Draw_Text((sel == i) ? ">" : " ", 1, 0, (UINT8)(i + RECENT_ROW_TOP));
	}
}

/* Scroll a selected name longer than 19 columns, like Filename_loop:
   dwell first, then shift one character every 5 loops, wrapping around.
   Redraw only that row, and only when the position actually changed.
   shift increments once per frame (the loop is synced by wait_vbl_done, ~16.7ms). */
void Show_recent_scroll(UINT8 count, UINT8 sel, UINT16 shift)__banked
{
#ifndef LANG_ZH
	if(ui_font) return;		/* mod: the 12px recent list does not scroll a name */
#endif
	static UINT16 last = 0xFFFF;
	UINT8  j, len;
	TCHAR *name;
	UINT16 off, pos;
	UINT8  line[RECENT_NAME_COLS + 1];

	if(sel >= count) return;

	HW_BANK = Folder_sram_bank;
	hw_set_page(A000Address_SRAM);

	name = my_strrchr((char*)pFilename_buffer[sel].filename, '/');
	if(name == NULL)
		name = (TCHAR*)pFilename_buffer[sel].filename;
	else
		name++;

	len = (UINT8)strlen(name);
	if(len <= RECENT_NAME_COLS) return;			/* fits: no scrolling needed */

	off = (shift > RECENT_SCROLL_DELAY)
	    ? (UINT16)((shift - RECENT_SCROLL_DELAY) / RECENT_SCROLL_STEP) : 0;
	off %= (UINT16)(len + 3);
	if(off == last) return;
	last = off;

	for(j = 0; j < RECENT_NAME_COLS; j++)
	{
		pos = (UINT16)(off + j);
		if(pos < len)
		{
			line[j] = (UINT8)name[pos];
		}
		else
		{
			pos -= len;
			if(pos < 3)							/* 3 spaces between tail and head */
				line[j] = ' ';
			else if((pos - 3) < len)
				line[j] = (UINT8)name[pos - 3];
			else
				line[j] = ' ';
		}
		if(line[j] == 0) line[j] = ' ';
	}
	line[RECENT_NAME_COLS] = 0;

	Draw_Text(line, RECENT_NAME_COLS, RECENT_NAME_X, (UINT8)(sel + RECENT_ROW_TOP));
}
#endif /* !LANG_ZH */


UINT8 month_day[12]={31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}; // non-leap year
UINT8 Leap_month_day[12]={31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}; // leap year
 
// is the year a leap year?
// year: the year to test
// return: 1 = leap year
//         0 = common year
UINT8 isLeapYear(UINT16 year)
{
	UINT8 res=0;
	
	if(year%4 == 0) // divisible by 4
	{
		if((year%100 == 0) && (year%400 != 0))	// divisible by 100 but not by 400
		{
			res = 0;
		}
		else
		{
			res =1;
		}
	}
	return res;

}
//---------------------------------------------------------------------------------
// convert Beijing time to a Unix timestamp
// year: the year to test
// return: Unix timestamp (seconds since 1970/1/1 00:00:00)

UINT32 covBeijing2UnixTimeStp(rtc_time_t  *beijingTime)
{
	UINT32 daynum=0, SecNum=0; // total days from the epoch to the Beijing time
	UINT16 tempYear=1970, tempMonth=0;
 	UINT32 temp;
 
// 1) years

	while(tempYear < beijingTime->ui8Year) 
	{
		if(isLeapYear(tempYear)){
			daynum += 366;
		}
		else{
			daynum += 365;
		}
		tempYear++;
	}
// 2) accumulate months
 	while(tempMonth < beijingTime->ui8Month-1) 
 	{
    if(isLeapYear(beijingTime->ui8Year)){ // leap year
        daynum += Leap_month_day[tempMonth];
    }
    else{
    	daynum += month_day[tempMonth];
    }
		tempMonth++;
	}

// 3) days
	daynum += (beijingTime->ui8DayOfMonth-1);

// 4) hour/minute/second
    
    
    SecNum = daynum*24; //s  
    SecNum = SecNum*60; //s 
    SecNum = SecNum*60; //s     
     
    temp = beijingTime->ui8Hour*60;
 
    temp = temp*60; 
    SecNum += temp;

    SecNum += beijingTime->ui8Minute*60;    
    SecNum += beijingTime->ui8Second;

// 5) timezone shift
    SecNum -= 28800;
 
    return SecNum;
}

//---------------------------------------------------------------------------------
UINT32 Get_now_time(void)
{
	rtc_time_t testTime;	

	hw_set_page(A000Address_RTC);//read RTC	OS mode	
  testTime.ui8Year = 2000+ UNBCD( *((volatile UINT8 *)(Base_RTCbuffer+0xE)));
  testTime.ui8Month = UNBCD(*((volatile UINT8 *)(Base_RTCbuffer+0xD)));
  testTime.ui8DayOfMonth = UNBCD(*((volatile UINT8 *)(Base_RTCbuffer+0xB)));
  testTime.ui8Hour =  UNBCD(*((volatile UINT8 *)(Base_RTCbuffer+0xA)));
  testTime.ui8Minute = UNBCD(*((volatile UINT8 *)(Base_RTCbuffer+9)));
  testTime.ui8Second = UNBCD(*((volatile UINT8 *)(Base_RTCbuffer+8)));
	hw_set_page(A000Address_SRAM);			
	return covBeijing2UnixTimeStp(&testTime);
}
//---------------------------------------------------------------------------------
UINT32 Send_different_time(UINT32 lasttime)
{
	UINT32 now;
	INT32 difference; 

	
	UINT32 Days;
	UINT8 Control=0;
	
	UINT8 Seconds_re,Minutes_re,Hours_re;
	now = Get_now_time();
	difference = now - lasttime;
			
	/* There used to be four DrawHEX debug dumps (12345678 / now / lasttime /
	   difference) that painted over the load dialog. Removed. */
				
	/* mod: as the released 1.06e does, the saved clock is kept when it is a
	   valid time and the time the cart was off is added to it. The 11-18
	   source zeroed it. A clock moved back counts as no time passed. Two
	   things are the mod's: a halted clock (DH bit 6) stays where it was, as
	   an MBC3's does, and DH bit 0 is always day bit 8. */
	if((lasttime==0) || (lasttime==0xFFFFFFFF))
	{
		Seconds_re=0;
		Minutes_re=0;
		Hours_re=0;
		Days=0;
		Control=0;
	}
	else
	{
		Seconds_re = SD_buffer[0x0];
		Minutes_re = SD_buffer[0x4];
		Hours_re = SD_buffer[0x8];
		Control = SD_buffer[0x10];
		Days = SD_buffer[0xC];
		if(Control & 0x01) Days += 256;

		if((Seconds_re > 59) || (Minutes_re > 59) || (Hours_re > 23))
		{
			Seconds_re=0;
			Minutes_re=0;
			Hours_re=0;
			Days=0;
			Control=0;
		}
		if((difference<0) || (Control & 0x40))
			difference = 0;

		Seconds_re += (difference % 60);
		if (Seconds_re > 59)
		{
			Seconds_re -= 60;
			Minutes_re++;
		}
		difference /= 60;
		Minutes_re += difference%60;
		if (Minutes_re > 59)
		{
			Minutes_re -= 60;
			Hours_re++;
		}
		difference /= 60;
		Hours_re += difference%24;
		if (Hours_re > 23)
		{
			Hours_re -= 24;
			Days++;
		}
		difference /= 24;
		Days += difference;
		if (Days > 511)
		{
			Days %= 512;
			Control |= 0x80;		/* day counter carry */
		}
		Control &= 0xC0;
		if (Days > 0xFF) Control |= 0x01;
	}

 	hw_set_page(A000Address_RTC);
	*((volatile UINT8 *)(Base_RTCbuffer+0x18))=Seconds_re;
	*((volatile UINT8 *)(Base_RTCbuffer+0x19))=Minutes_re;
	*((volatile UINT8 *)(Base_RTCbuffer+0x1A))=Hours_re;
	*((volatile UINT8 *)(Base_RTCbuffer+0x1B))=Days;
	*((volatile UINT8 *)(Base_RTCbuffer+0x1C))=Control;		
			
			
	HW_BANK = SAVE_info_sram_bank;
	hw_set_page(A000Address_SRAM);

	*((volatile UINT8 *)(FlashBase_SRAM+0x220)) = Seconds_re;
	*((volatile UINT8 *)(FlashBase_SRAM+0x221)) = Minutes_re;
	*((volatile UINT8 *)(FlashBase_SRAM+0x222)) = Hours_re;
	*((volatile UINT8 *)(FlashBase_SRAM+0x223)) = Days;
	*((volatile UINT8 *)(FlashBase_SRAM+0x224)) = Control;	
	
	HW_BANK = 0;
	hw_set_page(A000Address_TF);
		

	/* There used to be six DrawHEX calls + wait_select() here. This runs inside the
	   load path (LoadSAVE2SRAM), so wait_select() forced a SELECT press per load - it
	   looked like the loader had frozen. Both are gone. */
	
	return now;
}
//---------------------------------------------------------------------------------
UINT32 Send_different_time_0(void)
{
	UINT32 now;	
	UINT32 Days;
	UINT8 Control=0;
	
	UINT8 Seconds_re,Minutes_re,Hours_re;
	now = Get_now_time();

	Seconds_re=0;
	Minutes_re=0;
	Hours_re=0;
	Days=0;
	Control=0;

 	hw_set_page(A000Address_RTC);
	*((volatile UINT8 *)(Base_RTCbuffer+0x18))=Seconds_re;
	*((volatile UINT8 *)(Base_RTCbuffer+0x19))=Minutes_re;
	*((volatile UINT8 *)(Base_RTCbuffer+0x1A))=Hours_re;
	*((volatile UINT8 *)(Base_RTCbuffer+0x1B))=Days;
	*((volatile UINT8 *)(Base_RTCbuffer+0x1C))=Control;		
			
			
	HW_BANK = SAVE_info_sram_bank;
	hw_set_page(A000Address_SRAM);
	*((volatile UINT8 *)(FlashBase_SRAM+0x220)) = Seconds_re;
	*((volatile UINT8 *)(FlashBase_SRAM+0x221)) = Minutes_re;
	*((volatile UINT8 *)(FlashBase_SRAM+0x222)) = Hours_re;
	*((volatile UINT8 *)(FlashBase_SRAM+0x223)) = Days;
	*((volatile UINT8 *)(FlashBase_SRAM+0x224)) = Control;		
	HW_BANK = 0;
	hw_set_page(A000Address_TF);

	return now;
}
//---------------------------------------------------------------------------------
/* ==========================================================================
   Save-file name validation
   --------------------------------------------------------------------------
   The name "/SAVER/xxx.sav" has two sources, and both can be corrupt:
     1) the game name (lfname_temp) may come from stale data, e.g. an old entry in
        the recently played list;
     2) SRAM (bank 17: length at 0x00F, name from 0x010) survives power-off, so old
        firmware or a dying battery can leave half a name behind.
   Passing such a string to f_open(FA_OPEN_ALWAYS) creates a garbage-named file;
   repeating that scrambles the directory. Every path that opens a file with this
   name therefore goes through the two checks below.
   ========================================================================== */
static UINT8 game_name_is_sane(const TCHAR *p)
{
	UINT16 i;

	if(p == NULL || *p == 0) return 0;

	for(i = 0; i < MAX_path_len && p[i] != 0; i++)
	{
		/* Only control characters are rejected: card names are CP437/OEM bytes, so
		     values >= 0x80 are legal (Chinese/Japanese ROM names) and must be kept. */
		if(CHAR_IS_CTRL(p[i])) return 0;
		if(p[i] == '/' || p[i] == '\\') return 0;		/* a bare file name is required here */
	}
	if(i >= MAX_path_len) return 0;						/* no terminator */

	return (UINT8)(i >= 4);								/* at least "a.gb" */
}

static UINT8 save_name_is_sane(const TCHAR *p)
{
	UINT16 i;
	const TCHAR *pre = "/SAVER/";

	if(p == NULL || *p == 0) return 0;

	for(i = 0; i < 7; i++)
	{
		if(p[i] != pre[i]) return 0;					/* must start with /SAVER/ */
	}

	for(i = 7; i < MAX_path_len && p[i] != 0; i++)
	{
		if(CHAR_IS_CTRL(p[i])) return 0;
	}
	if(i >= MAX_path_len) return 0;
	if(i < 11) return 0;								/* "/SAVER/" + "a.sav" */

	if(p[i-4] != '.') return 0;
	if((p[i-3] != 's') && (p[i-3] != 'S')) return 0;
	if((p[i-2] != 'a') && (p[i-2] != 'A')) return 0;
	if((p[i-1] != 'v') && (p[i-1] != 'V')) return 0;

	return 1;
}

/* mod: 1 when currentpath_temp, the path of the boot stamp, is a save's */
UINT8 save_stamp_ok(void) __banked
{
	return save_name_is_sane(currentpath_temp);
}

//---------------------------------------------------------------------------------
/* Load save: 0 = existing save read, 1 = no save file (blank one prepared), 2 = bad path */
UINT8 LoadSAVE2SRAM(TCHAR *pfilename,UINT32 filesize)__banked
{
		FRESULT res;
		UINT8 status = 1;			/* default: no save, create one */
		UINT32 address;
		UINT16 ret;
		UINT16 i;
		UINT32 savesize;
		UINT32 RTC_offset;
		UINT32 now;
		
		BYTE strlen8;
		UINT16 count;
		UINT8 is_RTCsave;
		
		/* Validate the name first: control characters or a non-bare name return
		   "bad path" at once - never build "/SAVER/xxx.sav" from it and store that in
		   SRAM, because Save_new_SAVE would create a file with it on the next boot. */
		if(!game_name_is_sane(pfilename)) return 2;

		/* 8 bytes = "/SAVER/" (7 chars) + '\0'. It used to be 30, which read past the end;
		   then 7, which no longer overflowed but dropped the terminator, so mystrcat_n
		   appended to the leftover name in currentpath_temp and produced duplicate names
		   such as "xxx.savLegend of Zelda.sav". */
		memcpy(currentpath_temp,"/SAVER/",8);
		if(mystrcat_n(currentpath_temp,pfilename,MAX_path_len))
		{
			return 2;					/* path too long: never open the wrong save file */
		}
		strlen8 = strlen(currentpath_temp) ;
		
		if((currentpath_temp[strlen8-1]=='c') || (currentpath_temp[strlen8-1]=='C') )
		{
		}
		else {
			strlen8++;
		}		
		(currentpath_temp)[strlen8-3] = 's';
		(currentpath_temp)[strlen8-2] = 'a';
		(currentpath_temp)[strlen8-1] = 'v';
		(currentpath_temp)[strlen8+0] = 0;
		
		hw_set_page(A000Address_TF);
		res = f_open_bank(&gfil,currentpath_temp, FA_OPEN_EXISTING);
		
	  switch (m_iRAMSize)
	  {
	      case 0x00:
	      		if(m_Type==CartridgeMBC2)
						{
							savesize= 0x2000;	
						}
						else {
	          	savesize = 0;//
	          }
	          break;
	      case 0x01:
	      case 0x02:
	          savesize = 0x2000;//8KB
	          break;
	      case 0x04:
	          savesize = 0x20000;//128KB
	          break;
	      case 0x05:
	          savesize = 0x10000;//64KB Pocket Monsters - Crystal Version (Japan)  
	          break;    		
	      default:
	          savesize = 0x8000;//32KB
	          break;
	  }			
		if(res == FR_OK)//have a old save file
		{
			status = 0;					/* save file exists and has been read */
			res = f_open_bank(&gfil, currentpath_temp, FA_READ| FA_WRITE);
			
			savesize = f_size(&gfil);
			f_lseek_bank(&gfil, 0x0000);
			
			if((savesize & 0x30) == 0x30)
			{
				is_RTCsave =1;
				savesize = savesize&0xFFFFFF00;
			}

			/* No cartridge here has more than 128KB of save RAM, so a bigger .sav
			   is junk: bound the copy loop (256 x 512 bytes) instead of grinding
			   through whatever size the directory entry claims. */
			if(savesize > 0x20000UL) savesize = 0x20000UL;
			else 
			{
				is_RTCsave =0;				
			}
			
			for(address=0x0000;address<savesize;address+=0x200)
			{		
				hw_set_page(A000Address_TF);			
				f_read_bank(&gfil, SD_buffer, 0x200, &ret);				
				HW_BANK = address>>13;
				hw_set_page(A000Address_SRAM);

				set_data(FlashBase_SRAM+(address&0x1FFF),SD_buffer,0x200);

			}

			if(is_RTCsave/*(savesize & 0x30) == 0x30*/)
			{
				
				hw_set_page(A000Address_TF);	
				
				RTC_offset = savesize+0x28;//-8;
				
				f_lseek_bank(&gfil, RTC_offset);
				f_read_bank(&gfil, (UINT8*)&lasttime, 0x4, &ret);
				f_lseek_bank(&gfil, savesize);
				f_read_bank(&gfil, SD_buffer, 0x30, &ret);

				now=Send_different_time(lasttime);	
	
			}
			else if(m_bRTCPresent){
				now=Send_different_time_0();
			}
			hw_set_page(A000Address_TF);	
			f_close_bank(&gfil);

		}					
		else //make a new one
		{
			// create it on the next boot? remember the name first
			//clean sram buffer
			memset(SD_buffer,0xff,0x200);
			for(address=0x0000;address<savesize;address+=0x200)
			{		
				hw_set_page(A000Address_TF);			
				HW_BANK = address>>13;
				hw_set_page(A000Address_SRAM);
				set_data(FlashBase_SRAM+(address&0x1FFF),SD_buffer,0x200);

			}	
			now=Send_different_time_0();
			hw_set_page(A000Address_TF);				
		}
				
		savesize = (savesize)  >>13;
		//set save info
		HW_BANK = SAVE_info_sram_bank;
		hw_set_page(A000Address_SRAM);
		*((volatile UINT8 *)(FlashBase_SRAM+0)) = 0xAA;
		
		*((volatile UINT8 *)(FlashBase_SRAM+1)) = savesize;
		*((volatile UINT8 *)(FlashBase_SRAM+0xF)) = strlen8;
		
		for(count=0;count<strlen8;count++)
		{
			*((volatile UINT8 *)(FlashBase_SRAM+0x10+count)) = currentpath_temp[count] ;
		}
		
		if(m_bRTCPresent)
		{
			*((volatile UINT8 *)(FlashBase_SRAM+0x202)) = 0x77;
			*((volatile UINT8 *)(FlashBase_SRAM+0x210)) = now&0xFF;
			*((volatile UINT8 *)(FlashBase_SRAM+0x211)) = ((now)>>8)&0xFF;
			*((volatile UINT8 *)(FlashBase_SRAM+0x212)) = ((now)>>16)&0xFF;
			*((volatile UINT8 *)(FlashBase_SRAM+0x213)) = ((now)>>24)&0xFF;
		}
		else 
		{
			*((volatile UINT8 *)(FlashBase_SRAM+0x202)) = 0x0;//clean flag
		}
		
		HW_BANK = 0;
		hw_set_page(A000Address_TF);

		return status;
}
//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------
/* The cluster list is written at the start of SD_buffer; 0x1F0..0x1FF carry the
   file size, the copy flag and the sectors-per-cluster, which leaves 61 entries. */
#define FAT_TABLE_MAX_ENTRIES	61U

UINT32 Check_game_save_FAT(TCHAR *pfilename)__banked
{
	UINT32 res;
	FIL file;
	UINT32 *FAT_table_P;
	UINT32 getcluster;
	UINT32 getcluster_old;
	UINT32 cluster_num = 0;
	UINT32 gamefilesize;
	UINT32 max_clusters;
	UINT32 next;
	UINT8  entries = 0;
	
	hw_set_page(A000Address_TF);
	res = f_open_bank(&file, pfilename, FA_READ);
	if(res != FR_OK)
			return 0xffffffff;


	getcluster =  (&file)->sclust;

	gamefilesize = f_size(&file);

	/* A real chain has at most one step per cluster of the file; anything longer
	   means the FAT points back at itself. */
	max_clusters = (gamefilesize / (((UINT32)(&EZcardFs)->csize) << 9)) + 8UL;

	FAT_table_P = (UINT32*)SD_buffer;

	*FAT_table_P = 0x00000000;
	FAT_table_P++;
	*FAT_table_P = (ClustToSect(&EZcardFs,getcluster));
	FAT_table_P++;

	getcluster_old = getcluster;
	for (;;)
	{
		next = Get_NextCluster((&file)->fs, getcluster);

		/* get_fat() returns 1 for "cluster out of range" and 0xFFFFFFFF when the
		   FAT sector cannot be read. The old loop only stopped at the end-of-chain
		   marker, so a broken chain made it keep reading cluster 1 for ever and
		   write table entries past SD_buffer - the console froze on "Loading..."
		   (a 2MB ROM whose last FAT entry was not the 0xFFFF marker did exactly
		   that). Stop instead of spinning. */
		if ((next < 2UL) || (next == 0xFFFFFFFFUL)) goto fat_fail;

		cluster_num++;
		if (next != (getcluster_old + 1UL))
		{
			if (entries >= FAT_TABLE_MAX_ENTRIES) goto fat_fail;	/* would hit the metadata at 0x1F0 */
			*FAT_table_P = (cluster_num * (&EZcardFs)->csize);	/* sectors per cluster */
			FAT_table_P++;
			*FAT_table_P = (ClustToSect(&EZcardFs, next));
			FAT_table_P++;
			entries++;
		}
		getcluster_old = next;
		getcluster = next;

		/* Any cluster number >= n_fatent is out of range, which is exactly what an
		   end-of-chain marker looks like: 0xFFFF on FAT16, 0x0FFFFFFF on FAT32, but
		   0xFFF8..0xFFFE are equally valid FAT16 markers and the old comparison
		   (only 0xFFFF) walked straight past them into other files' clusters. */
		if (next >= (&file)->fs->n_fatent) break;

		if (cluster_num > max_clusters) goto fat_fail;
	}
	*--FAT_table_P = 0x0;
	*--FAT_table_P = 0xffffffff;

	f_close_bank(&file);
	
	FAT_table_P = (UINT32*)SD_buffer;
			FAT_table_P[0x1F0/4] = gamefilesize;//size
			FAT_table_P[0x1F4/4] = 0x1;  //rom copy to psram
			FAT_table_P[0x1F8/4] = (&EZcardFs)->csize;//0x40;  //secort of cluster
	return 0;

fat_fail:
	/* The ROM cannot be described to the FPGA (broken FAT chain, or more fragments
	   than the 61-entry table can hold), so booting it would only hang the DMA.
	   Say so and go back to the list: main.c aborts the boot on any non-zero
	   return. Waiting for B (and for the key to come back up) keeps the list loop
	   from reading the same press as "go up one directory". */
	f_close_bank(&file);
	Show_Error_file();
	while(!(joypad() & J_B)) wait_vbl_done();
	while(joypad() & (J_A | J_B)) wait_vbl_done();
	return 0xFFFFFFFEUL;
}
//---------------------------------------------------------------------------------
void CheckCartridgeType(UINT8 type)
{

	switch (type)
	{
		case 0x00:
				// NO MBC
    case 0x08:
        // ROM
        // SRAM
    case 0x09:
        // ROM
        // SRAM
        // BATT
        m_Type = CartridgeNoMBC;
        break;
    case 0x01:
        // MBC1
    case 0x02:
        // MBC1
        // SRAM
    case 0x03:
        // MBC1
        // SRAM
        // BATT
    case 0xEA:
    case 0xFF:
        // Hack to accept HuC1 as a MBC1
        m_Type = CartridgeMBC1;
        break;
    case 0x05:
        // MBC2
        // SRAM
    case 0x06:
        // MBC2
        // SRAM
        // BATT
        m_Type = CartridgeMBC2;
        break;
    case 0x0F:
        // MBC3
        // TIMER
        // BATT
    case 0x10:
        // MBC3
        // TIMER
        // BATT
        // SRAM
    case 0x11:
        // MBC3
    case 0x12:
        // MBC3
        // SRAM
    case 0x13:
        // MBC3
        // BATT
        // SRAM
    case 0xFC:
        // Game Boy Camera
        m_Type = CartridgeMBC3;
        break;
    case 0x19:
        // MBC5
    case 0x1A:
        // MBC5
        // SRAM
    case 0x1B:
        // MBC5
        // BATT
        // SRAM
    case 0x1C:
        // RUMBLE
    case 0x1D:
        // RUMBLE
        // SRAM
    case 0x1E:
        // RUMBLE
        // BATT
        // SRAM
        m_Type = CartridgeMBC5;
        break;
    case 0x0B:
        // MMMO1
    case 0x0C:
        // MMM01
        // SRAM
    case 0x0D:
        // MMM01
        // SRAM
        // BATT
    case 0x15:
        // MBC4
    case 0x16:
        // MBC4
        // SRAM
    case 0x17:
        // MBC4
        // SRAM
        // BATT
    case 0x22:
        // MBC7
        // BATT
        // SRAM
    case 0x55:
        // GG
    case 0x56:
        // GS3
    case 0xFD:
        // TAMA 5
    case 0xFE:
        // HuC3
        m_Type = CartridgeNotSupported;
        break;
    default:
        m_Type = CartridgeNotSupported;
	}

  switch (type)
  {
    case 0x03:
    case 0x06:
    case 0x09:
    case 0x0D:
    case 0x0F:
    case 0x10:
    case 0x13:
    case 0x17:
    case 0x1B:
    case 0x1E:
    case 0x22:
    case 0xFD:
    case 0xFF:
			m_bBattery = TRUE;
   		break;
    default:
   		m_bBattery = FALSE;
  }

  switch (type)
  {
		case 0x0F:
  	case 0x10:
    	m_bRTCPresent = TRUE;
    	break;
  	default:
    	m_bRTCPresent = FALSE;
  }

  switch (type)
  {
		case 0x1C:
		case 0x1D:
		case 0x1E:
    	m_bRumblePresent = TRUE;
    	break;
   	default:
    	m_bRumblePresent = FALSE;
  }
}
//---------------------------------------------------------------------------------
UINT8 GatherMetadata(TCHAR *pfilename)__banked
{
	UINT32 res;
	UINT16 ret;
	UINT16 i;
	UINT8 type;

	UINT32 logo_checksum = 0;
	
	hw_set_page(A000Address_TF);
	res = f_open_bank(&gfil, pfilename, FA_READ);
	if(res != FR_OK)
	{						
		return 0xff;
	}
	ROMBankCount_real = f_size(&gfil) / 0x4000;		
	f_lseek_bank(&gfil, 0x0000);
	
	/* On a failed read SD_buffer still holds the previous data; parsing it as a
	   ROM header yields the wrong cart type and ROM/RAM size, so the game would
	   boot with wrong MBC parameters (and could even corrupt the save area). */
	if(f_read_bank(&gfil, SD_buffer, 0x200, &ret) != FR_OK || ret != 0x200)
	{
		f_close_bank(&gfil);
		return 0xff;				/* let the caller take the "boot failed" path */
	}
	
	Header_Checksum = 0;

	for (i = 0x134; i <= 0x14C; i++)
	{		
		Header_Checksum =Header_Checksum-SD_buffer[i]-1;
	}

  type = SD_buffer[0x147];
  m_iROMSize = SD_buffer[0x148];
  m_iRAMSize = SD_buffer[0x149];
  m_iVersion = SD_buffer[0x14C];	
  CheckCartridgeType(type);
  
  if(m_Type == CartridgeMBC1)
  {
  	if(ROMBankCount_real>0x20)
  	{
			f_lseek_bank(&gfil, 0x40000);
	
			/* This read is only the optional multi-cart probe: on failure keep the normal
			   CartridgeMBC1 boot instead of rejecting the game. */
			if(f_read_bank(&gfil, SD_buffer, 0x200, &ret) == FR_OK && ret == 0x200)
			{
				for (i = 0x104; i <= 0x133; ++i) {
					logo_checksum = (logo_checksum << 1) ^ SD_buffer[i];
				}
				if(	logo_checksum == 0xe06c8834)
				{
					m_Type = CartridgeMBC1Multi;
				}
			}
					
  	}
  }	
	f_close_bank(&gfil);
  return res; 	
}
//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------
UINT8 Save_new_SAVE(TCHAR *pfilename,UINT32 filesize)
{
		FRESULT res;
		UINT8 fail = 0;			/* 0 = OK, 1 = open/close failed, 2 = write failed */
		UINT32 address;
  	UINT  written;
  	UINT8 mode;
		UINT16 page_address;
		
		
		wait_vbl_done();
		
		hw_set_page(A000Address_TF);	

		/* The save name comes from SRAM (survives power-off): validate it before
		   opening. A garbage name (especially a long one with control characters) creates
		   junk files in /SAVER and scrambles the directory. Bail out instead. */
		if(!save_name_is_sane(currentpath_temp)) return 1;
		
		res = f_open_bank(&gfil,currentpath_temp, FA_WRITE | FA_OPEN_ALWAYS);
		if(res != FR_OK)			/* cannot even open: report instead of silently doing nothing */
		{
			return 1;
		}
		if(res == FR_OK)
		{	
			f_lseek_bank(&gfil, 0x0000);
			mode = 0;
			for(address=0x0000;address<filesize;address+=0x200)
			{		
      	HW_BANK =address>>13;
      	hw_set_page(A000Address_SRAM);
      	
      	page_address = FlashBase_SRAM+(address&0x1FFF);
      	
				get_data(SD_buffer,page_address,0x200);
				
				hw_set_page(A000Address_TF);
				res=f_write_bank(&gfil, (void*)SD_buffer, 0x200, &written);
				if((res != FR_OK) || (written != 0x200))
				{
					fail = 2;		/* disk error or short write: stop before damaging more data */
					break;
				}
				
				
				mode++;
				if(mode==3)mode=0;
#ifndef LANG_ZH
				/* mod: the dots step inside the band's "Saving..." itself. The
				   source as received draws them at column 11, which is past
				   the end of the text here and left a second set beside it. */
				if(mode==0)
				{
					Draw_Text("Saving.  ", 9, SAVE_MSG_COL, SAVE_MSG_ROW);
				}
				else if(mode==1)
				{
					Draw_Text("Saving.. ", 9, SAVE_MSG_COL, SAVE_MSG_ROW);
				}
				else
				{
					Draw_Text("Saving...", 9, SAVE_MSG_COL, SAVE_MSG_ROW);
				}
#else
				if(mode==0)
				{
					Draw_Text(".  ", 3, SAVE_DOT_COL, SAVE_MSG_ROW);	
				}
				else if(mode==1)
				{
					Draw_Text(".. ", 3, SAVE_DOT_COL, SAVE_MSG_ROW);	
				}
				else 
				{
					Draw_Text("...", 3, SAVE_DOT_COL, SAVE_MSG_ROW);	
				}
#endif
			}			
						
			if(is_lasttime == 0x77)
			{
				{
					memset(SD_buffer,0x00,0x30);
					HW_BANK = SAVE_info_sram_bank;
					hw_set_page(A000Address_SRAM);
					SD_buffer[0x0] = *((volatile UINT8 *)(FlashBase_SRAM+0x220));
					SD_buffer[0x4] = *((volatile UINT8 *)(FlashBase_SRAM+0x221));
					SD_buffer[0x8] = *((volatile UINT8 *)(FlashBase_SRAM+0x222));
					SD_buffer[0xc] = *((volatile UINT8 *)(FlashBase_SRAM+0x223));
					SD_buffer[0x10] = *((volatile UINT8 *)(FlashBase_SRAM+0x224));

					SD_buffer[0x14] = *((volatile UINT8 *)(FlashBase_SRAM+0x220));
					SD_buffer[0x18] = *((volatile UINT8 *)(FlashBase_SRAM+0x221));
					SD_buffer[0x1c] = *((volatile UINT8 *)(FlashBase_SRAM+0x222));
					SD_buffer[0x20] = *((volatile UINT8 *)(FlashBase_SRAM+0x223));
					SD_buffer[0x24] = *((volatile UINT8 *)(FlashBase_SRAM+0x224));
					
					
					SD_buffer[0x28] = *((volatile UINT8 *)(FlashBase_SRAM+0x210));
					SD_buffer[0x29] = *((volatile UINT8 *)(FlashBase_SRAM+0x211));
					SD_buffer[0x2A] = *((volatile UINT8 *)(FlashBase_SRAM+0x212));
					SD_buffer[0x2B] = *((volatile UINT8 *)(FlashBase_SRAM+0x213));
					
					
					HW_BANK = 0;
					hw_set_page(A000Address_TF);	
			
					{
						f_lseek_bank(&gfil, filesize);
						res=f_write_bank(&gfil, (void*)SD_buffer, 0x30, &written);
						if((res != FR_OK) || (written != 0x30))
						{
							fail = 2;
						}
					}
				}
			}
			
			if(f_close_bank(&gfil) != FR_OK) fail = 1;	/* close flushes the dir entry: a failure matters */
		}

	return fail;
}
//---------------------------------------------------------------------------------
/* Save failure notice. Shown instead of leaving the user with the impression
   that the save went through; waits for B so it cannot be missed. */
static void Show_SAVE_error(void)
{
#ifndef LANG_ZH
	/* the band has two rows to give: the Played line's and the buttons' */
	Draw_Text("SAVE FAIL!        ", 18, SAVE_MSG_COL, 9);
	Draw_Text("SD ERROR   press B", 18, SAVE_MSG_COL, SAVE_MSG_ROW);
	while(joypad() != J_B) delay(50);
	Draw_Text("                  ", 18, SAVE_MSG_COL, 9);
	Draw_Text("                  ", 18, SAVE_MSG_COL, SAVE_MSG_ROW);
#else
	Draw_Text(UI_SAVE_FAIL, UI_LEN(UI_SAVE_FAIL), SAVE_MSG_COL, SAVE_MSG_ROW);	/* 10 chars max, same width as the dialog */
	Draw_Text(UI_SAVE_FAIL_SD, UI_LEN(UI_SAVE_FAIL_SD), SAVE_MSG_COL, SAVE_MSG_ROW2);
	Draw_Text(UI_SAVE_PRESS_B, UI_LEN(UI_SAVE_PRESS_B), SAVE_MSG_COL, SAVE_MSG_ROW3);
	while(joypad() != J_B) delay(50);
	/* Clear with an equally long run of spaces: Draw_Text switches the palette to
	   white as soon as it meets '\0', turning the dialog into a white bar. */
	Draw_Text("          ", 10, SAVE_MSG_COL, SAVE_MSG_ROW);
	Draw_Text("        ", 8, SAVE_MSG_COL, SAVE_MSG_ROW2);
	Draw_Text("       ", 7, SAVE_MSG_COL, SAVE_MSG_ROW3);
#endif
}
//---------------------------------------------------------------------------------
/* Save confirmation: there used to be no feedback at all, so the user could not
   tell whether the write worked. "Saving..." is 9 chars, so 9 are overwritten; it
   returns after a short pause and never blocks the auto-save flow. */
static void Show_SAVE_ok(void)
{
	color(BLACK,DKGREY,SOLID);			/* keep the dialog background */
	Draw_Text(UI_SAVE_OK, UI_LEN(UI_SAVE_OK), SAVE_MSG_COL, SAVE_MSG_ROW);	/* pad to 9 cells so the white-fill path is not triggered */
	delay(600);
	Draw_Text("         ", 9, SAVE_MSG_COL, SAVE_MSG_ROW);	/* clear with spaces; the caller redraws the list afterwards */
}
//---------------------------------------------------------------------------------
/* Load progress. mod: nothing is drawn. The box is up already with
   Loading... in it (Show_loading, before every launch) and stays as it is
   until the screen goes off: the source as received drew LOAD OK! or a new
   save's line here and held each for 0.4 or 0.6 s. */
void Show_LOAD_info(UINT8 phase)__banked
{
	phase;
}
//---------------------------------------------------------------------------------
/* ---- Save-dialog button coordinates ---------------------------------------
   Two coordinate systems: box() takes **pixels**, Draw_Text() x takes **tiles**.
   Text can only move in whole tiles, so nudging it by 1-3 pixels means moving the
   box instead. Everything below is in pixels; tweak the numbers to adjust.    */
#define BTN_NO_BOX_X1	38		/* was 39, moved 1px left */
#define BTN_NO_BOX_X2	78		/* was 80, moved 2px left */
#define BTN_NO_TXT_X	5			/* tile -> 40px, cannot move further left */
#define BTN_OK_BOX_X1	81		/* was 82, moved 1px left (= text 1px right) */
#define BTN_OK_BOX_X2	122		/* was 123 */
#define BTN_OK_TXT_X	10		/* tile -> 80px */
#define BTN_BOX_Y1		93
#define BTN_BOX_Y2		106
#define BTN_BOX_TXT_Y	12		/* tile -> 96px */

#ifndef LANG_ZH
UINT8 draw_colors(void);		/* vram_put.s */
void fill_fast_rect(UINT8 x0, UINT8 y0, UINT8 x1, UINT8 y1, UINT8 bg) __banked;
#endif

void Show_SAVE_info(UINT32 readdata,UINT8 autosave)__banked
{
#ifndef LANG_ZH
	/* mod: the 0918 mod's prompt (docs/prompts.md "BACKUPSAVE"), a band across
	   the screen with the save's name in it:
	       Back up save?
	       <the save's name>
	       Played Oct 23 14:05    when the settings file has the clock
	       Saving...              while it is written
	       [B]skip      [A]save
	   The Chinese build keeps the block the source as received draws, below. */
	UINT8 t[27];
	UINT8 n;
	UINT8 k;
	BYTE keys;

	color(BLACK,DKGREY,SOLID);
	box(0,35,159,ui_font ? 103 : 99,M_FILL);	/* 12px text is four pixels taller */
	memcpy(t, "Back up save?", 14);
	Draw_Text(t, 13, 1, 5);
	/* the save's file name on its band, scrolling when it is longer
	   (modmisc.c): currentpath_temp is "/SAVER/<name>.sav" */
	n = (UINT8)strlen(currentpath_temp);
	k = (n > 7) ? 7 : 0;
	/* the band runs from one side of the frame to the other: the name's
	   field is the 18 cells in the middle (fill_fast_rect leaves the colors
	   black on white) */
	color(WHITE,BLACK,SOLID);
	n = (UINT8)(draw_colors() & 3U);
	fill_fast_rect(1, 56, 7, ui_font ? 67 : 63, n);
	fill_fast_rect(152, 56, 158, ui_font ? 67 : 63, n);
	mq_start((const UINT8 *)currentpath_temp + k, 1, 7, 18, WHITE, BLACK);
	color(BLACK,DKGREY,SOLID);
	/* when the game was started: the clock the last launch stored (ezcfg.c) */
	if(cfg_played(t))
	{
		Draw_Text(t, 19, 1, 9);
		box(0,35,159,ui_font ? 103 : 99,M_NOFILL);	/* the line runs to the screen's edge, over the outline */
	}
	if(autosave != 1)
	{
		memcpy(t, "[B]skip    [A]save", 19);
		Draw_Text(t, 18, 1, 11);
		popup_rules(11, ui_font ? 103 : 99, 80);
		/* a press made now, not a button held since before the prompt */
		pad_take();
		while(1)
		{
			wait_vbl_done();
			mq_step();
			keys = pad_take();
			if(keys & J_A) break;
			if(keys & J_B) return;
		}
		/* the buttons and their rules come off: blanking the row alone
		   cut a gap in the line between them */
		popup_rules_clear(11, ui_font ? 103 : 99);
	}
	Draw_Text(UI_SAVE_BUSY, UI_LEN(UI_SAVE_BUSY), SAVE_MSG_COL, SAVE_MSG_ROW);
	if(Save_new_SAVE("", (UINT32)(readdata<<13)) != 0) Show_SAVE_error();
	else Show_SAVE_ok();
#else
	BYTE keysrepeat;
	UINT32 filesize;

	color(BLACK,DKGREY,SOLID);
	
	box(35,37,125,108,M_FILL);
//color(BLACK,WHITE,SOLID);
	Draw_Text(UI_SAVE_TITLE, UI_LEN(UI_SAVE_TITLE), 5, 5);	
	

	if(autosave==1){
		Draw_Text(UI_SAVE_BUSY, UI_LEN(UI_SAVE_BUSY), 5, 10);	
		filesize = (UINT32)(readdata<<13);	
		if(Save_new_SAVE("", filesize) != 0) Show_SAVE_error();
		else Show_SAVE_ok();
	}
	else{
		color(BLACK,DKGREY,SOLID);
		box(BTN_NO_BOX_X1,BTN_BOX_Y1,BTN_NO_BOX_X2,BTN_BOX_Y2,M_FILL);	//B btn
		box(BTN_OK_BOX_X1,BTN_BOX_Y1,BTN_OK_BOX_X2,BTN_BOX_Y2,M_FILL);  //A btn
//color(BLACK,WHITE,SOLID);
#ifdef LANG_ZH
		/* zh: 12px glyphs do not fit the 8px text row this dialog was designed
		   around - row 12 is y96, so the glyphs would end at 107, one pixel
		   below the button box (93..106), and the row fill would paint over the
		   box's bottom border. Draw them at y94 instead (centred in the box)
		   with zh_text_at, which does not fill any background.
		   The labels must be copied into WRAM first: zh_text_at runs in bank 2,
		   and these literals live in bank 1 - after the bank switch that address
		   holds other data and the loop sees a 0 (nothing drawn at all). */
		{
			char lbl[6];
			UINT8 i;

			for (i = 0U; UI_BTN_NO[i] != 0U; i++) lbl[i] = UI_BTN_NO[i];
			lbl[i] = 0U;
			zh_text_at(94, (UINT8)(BTN_NO_TXT_X * 8U), (const UINT8 *)lbl, 160);

			for (i = 0U; UI_BTN_OK[i] != 0U; i++) lbl[i] = UI_BTN_OK[i];
			lbl[i] = 0U;
			zh_text_at(94, (UINT8)(BTN_OK_TXT_X * 8U + 3U), (const UINT8 *)lbl, 160);	/* +3px: 12px glyphs sit tighter to the box */
		}
#else
		Draw_Text(UI_BTN_NO, UI_LEN(UI_BTN_NO), BTN_NO_TXT_X, BTN_BOX_TXT_Y);
		Draw_Text(UI_BTN_OK, UI_LEN(UI_BTN_OK), BTN_OK_TXT_X, BTN_BOX_TXT_Y);
#endif
		while(1)//3
		{
			keysrepeat = joypad();
			
			if(keysrepeat &  J_A){
				Draw_Text(UI_SAVE_BUSY, UI_LEN(UI_SAVE_BUSY), 5, 10);	
				filesize = (readdata<<13);
				if(Save_new_SAVE("", filesize) != 0) Show_SAVE_error();
				else Show_SAVE_ok();
				break;
	    }
			if(keysrepeat &  J_B){
				break;
	    }
		}
	}
#endif
}