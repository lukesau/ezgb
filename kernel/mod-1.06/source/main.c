
#include <gb/gb.h>
#include "ezgb_hw.h"
#include <gb/drawing.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <gbdk/console.h>

#include "main.h"
#include "ff.h"
#include "UI.h"

#include "SD_operate.h"
#include "GBcard_OP.h"
#include "Bank_fun.h"

#include "RTC.h"

#ifdef LANG_ZH
#include "ui_zh.h"		/* Chinese list renderer (list_zh.c) */
#include "zh_bg.h"		/* tracks the color() background (zh_text_row uses it to fill a row) */
#endif


/* Direction-key sampling divider for the file list.
   The main loop is frame synced (~16.7ms), and joypad() has no built-in repeat
   delay, so the cursor speed equals the loop rate. 2 = every other frame
   (~33ms per step, half of the current speed); use 3 for ~50ms. */
#define KEY_DIR_DIV  2

UINT8 SD_buffer[0x200];

FM_FILE_FS *pFilename_buffer;


	UINT16 game_folder_total;

/* Diagnostic only: a failed f_readdir used to be indistinguishable from "end of
   directory", which made a card that stops answering look like an empty folder.
   Kept so Show_error_info() can name the stage and the sector. */
UINT8 readdir_fail;
UINT8 readdir_stage;


UINT16 ROMBankCount_real;


TCHAR currentpath[MAX_path_len];
TCHAR currentpath_temp[MAX_path_len];
TCHAR lfname_temp[MAX_path_len];

/* _current_bank: declared by <gb/gb.h> in GBDK-2020 (extern volatile __sfr) */

extern enum CartridgeTypes m_Type;
extern BOOL m_bBattery;
extern BOOL m_bRTCPresent;

extern UINT8 m_iROMSize;
extern UINT8 m_iRAMSize;
UINT8 Header_Checksum;
UINT8 Read_file_end;

extern UINT8 is_lasttime;
// --------------------------------------------------------------------
FATFS *FatFs[_VOLUMES];	/* Pointer to the file system objects (logical drives) */
WORD Fsid;				/* File system mount ID */

WCHAR LfnBuf[_MAX_LFN + 1];

FATFS EZcardFs;
FILINFO fileinfo;
DIR dir;

FIL gfil;

BYTE g_y;
BYTE g_x;
// --------------------------------------------------------------------
/* Wait for a key. NOTE: this accepts SELECT, not B - the name wait_select made
   people think B worked. (Show_SAVE_error() waits for a real B; the two differ.) */
   
void wait_select(void)
{
	while(1) 
	{
		if(joypad() == J_SELECT) {
			break;
		}
	}
	delay(200);
}
// --------------------------------------------------------------------
void Draw_Text(UINT8 *str, UINT8 len, UINT8 x, UINT8 y)
{
#ifndef LANG_ZH
	UINT8 l,tt;
	UINT8 pad_set = 0;
#endif

#ifdef LANG_ZH
	/* Single entry point: in the zh build Draw_Text uses 12px APA from the very
	   first call (zh_text_row maps console semantics: coordinates, len, background).
	   The console path (gotogxy/wrtchr) is not compiled at all: on the graphics
	   canvas wrtchr writes glyphs into the wrong tile for rows >= 9, which was the
	   cause of the corrupted dialogs. The string is copied onto the stack (WRAM)
	   before the cross-bank call: while Draw_Text runs in bank 0 the 0x4000 window
	   maps the caller's bank, so zh_text_row in bank 2 cannot see the literal. */
	{
		UINT8 zhbuf[18];
		UINT8 n, zlen, zraw;

		/* len==0 means "pad to 17 cells and overwrite the whole row" in console
		   terms; zh_text_row needs the original value to fill the full row. */
		zraw = (len > 17U) ? 17U : len;
		zlen = (len == 0U) ? 17U : zraw;
		for (n = 0U; n < zlen && str[n] != 0U; n++) zhbuf[n] = str[n];
		zhbuf[n] = 0U;
		zh_text_row(y, x, zhbuf, zraw);
	}
#else
	gotogxy(x,y);
	
	if(len==0)
		tt=17;
	else 	
		tt = len;
	
	for(l=0;l<tt;l++)
	{
		if(*str)
			wrtchr(*str++);
		else 
			{
				/* BGP is a global register: set it once for the whole padding run */
				if(!pad_set)
				{
					color(BLACK,WHITE,SOLID);
					pad_set = 1;
				}
			wrtchr(' ');
		}
	}

#endif /* !LANG_ZH */
}
// --------------------------------------------------------------------
void DrawHEX(unsigned long uc)
{
	 char s[20];
	_ultoa(uc,s,10u);
								
	Draw_Text(s, strlen(s), g_x, g_y);
	g_y++;
	if(g_y>20)
	{
		g_y = 0;
	}		
	
	
}
// --------------------------------------------------------------------
// --------------------------------------------------------------------
static
int mem_cmp (const void* dst, const void* src, BYTE cnt) {
	const BYTE *d = (const BYTE *)dst, *s = (const BYTE *)src;
	int r = 0;

	while (cnt-- && (r = *d++ - *s++) == 0) ;
	return r;
}
static
// --------------------------------------------------------------------
void mem_set (void* dst, int val, BYTE cnt) {
	BYTE *d = (BYTE*)dst;

	while (cnt--)
		*d++ = (BYTE)val;
}
// --------------------------------------------------------------------
/* --------------------------------------------------------------------
   Reads the whole directory at once, directories first.
   --------------------------------------------------------------------
   Two passes instead of a sort:
       pass 1: walk the directory, write only directories
       pass 2: walk again from the start, write only files (continuing the pointer)
   game_folder_total keeps growing between passes, so directories come first.

   Why not sort: entries are 255 bytes and an insert sort moves whole entries.
   SDCC's byte loop is 106 instructions (~130 M-cycles/byte), 8s for 32 items;
   hand-written asm (8 M-cycles/byte) still needs 8s for 128. Two passes move no
   data at all: ~77ms for 128 items.

   Cost: the whole directory is read on entry (~60ms for 100 items).
   Win: scrolling no longer touches the card, and the dir/file split is global.
        The view indexes with (show_offset+line)/Num_perBank, so the full list works
        so Show_filename / Refresh_filename need no changes at all.
   ------------------------------------------------------------------ */

/* The list area starts at bank 18, 32 entries per 8KB bank.
   The bank latched at 0x4000 is an 8-bit register, but the SRAM behind it is
   finite: banks 0..15 hold the biggest save this kernel supports (128KB), bank 17
   the save info, so only banks 18..31 are certainly there. Going past that would
   wrap the bank number and write the list straight into the save area, so the
   bound is 14 banks = 448 entries (32 x 14). The old 255-bank assumption
   (7616 entries) was an index limit, not a memory limit. */
#define FOLDER_LIST_MAX  ((UINT16)Num_perBank * (UINT16)(32U - Folder_sram_bank))

void Read_all_DIR(void)
{
	char  *fn;
	UINT8  res;
	UINT8  pass;
	UINT8  is_dir;
	UINT8  slot;
	UINT8  want_bank;
	UINT8  cur_bank = 0xFF;
	UINT8 *name;

	game_folder_total = 0;
	Read_file_end = 1;			/* both passes done: everything read, scrolling never touches the card */
	readdir_fail = 0;

	for(pass = 0U; pass < 2U; pass++)
	{
		hw_set_page(A000Address_TF);
		res = f_opendir(&dir, currentpath);	/* every pass starts at the directory head */
		if(res != FR_OK)
		{
			Read_file_end = 1;
			readdir_fail = res;
			readdir_stage = 9U;				/* f_opendir inside the scan */
			return;
		}

		while(1)
		{
			hw_set_page(A000Address_TF);
			res = f_readdir(&dir, &fileinfo);
			if(res != FR_OK)
			{
				/* Not "end of directory": the card stopped answering. */
				readdir_fail = res;
				readdir_stage = (UINT8)(pass + 3U);
				break;
			}
			if(fileinfo.fname[0] == 0)
				break;				/* directory exhausted */
			if(fileinfo.fname[0] == '.')
				continue;			/* skip . and .. */

			fn = *fileinfo.lfname ? fileinfo.lfname : fileinfo.fname;

			/* Same rules as before: must be a directory and not hidden/system, otherwise
			   Windows' System Volume Information (0x12) at the card root would show up */
			is_dir = ((fileinfo.fattrib & AM_DIR) &&
			          !(fileinfo.fattrib & (AM_HID|AM_SYS))) ? 1U : 0U;

			if(pass == 0U)
			{
				if(!is_dir) continue;		/* pass 1: directories only */
			}
			else
			{
				if(is_dir) continue;		/* pass 2: files only */
				if(fileinfo.fattrib & (AM_VOL|AM_HID|AM_SYS)) continue;
				if(mem_cmp(fn,"ezgb.dat",8)==0) continue;
			}

			if(game_folder_total >= FOLDER_LIST_MAX)
			{
				Read_file_end = 1;
				return;				/* list area exhausted (never in practice) */
			}

			hw_set_page(A000Address_SRAM);
			want_bank = Folder_sram_bank + (UINT8)(game_folder_total / Num_perBank);
			if(want_bank != cur_bank)		/* no need to re-select the same page */
			{
				HW_BANK  = want_bank;
				cur_bank = want_bank;
			}

			slot = (UINT8)(game_folder_total % Num_perBank);
			name = pFilename_buffer[slot].filename;

			pFilename_buffer[slot].fattrib = is_dir ? AM_DIR : 0x20;
#ifdef LANG_ZH
			pFilename_buffer[slot].fsize = fileinfo.fsize;	/* size column shown by the zh list */
#endif
			strncpy((char*)name, fn, MAX_filename_len-1);
			name[MAX_filename_len-1] = 0;

			game_folder_total++;
		}
	}

	hw_set_page(A000Address_TF);
}
// --------------------------------------------------------------------
void Filename_loop(UINT32 shift,UINT16 show_offset,UINT16 file_select)
{
#if defined(LANG_ZH) && !defined(ZH_LIST_OFF)
	list_zh_loop(shift, show_offset, file_select);
	return;
#endif
	UINT8 Max_char;	
	UINT8 namelen;
	/* Dwell before scrolling, in main-loop iterations. The loop is now frame
	   synced (~16.7ms), so 30 iterations ~= 0.5s. */
	UINT32 timeout = 30;	// dwell before scrolling (in main-loop iterations)
	UINT8 x_offset= 0;	
	UINT8 y_offset= 2;		
	UINT8 BANK_index;
	UINT8 BANK_num;
	UINT16 tt;
	UINT8 i;
	static UINT16 orgtt = 0xeeee;
	
	if(shift > timeout)
	{
		color(BLACK,DKGREY,SOLID);
		BANK_num = (show_offset+file_select)/Num_perBank;
		BANK_index = (show_offset+file_select)%Num_perBank;	
		HW_BANK = Folder_sram_bank+BANK_num;

		namelen = strlen(pFilename_buffer[BANK_index].filename);
		if(pFilename_buffer[BANK_index].fattrib == AM_DIR)
		{
			Max_char = 17;
		}
		else
		{
			Max_char = 20;
		}
		
		if(namelen > Max_char) 
		{
			tt = ((shift-timeout)/5)% (namelen);	/* 5 loops ~= 83ms per character */
			if(orgtt!= tt )
			{	
				orgtt = tt ;
				/* Ring window: render exactly Max_char visible characters. The old code
				   concatenated into lfname_temp and used (128 - strlen(...)) as the strncpy
				   length, which underflows for names longer than ~125 chars. */
				for(i=0;i<Max_char;i++)
				{
					UINT16 pos = (UINT16)tt + i;
					if(pos < namelen)
					{
						lfname_temp[i] = pFilename_buffer[BANK_index].filename[pos];
					}
					else
					{
						pos -= namelen;
						if(pos < 3)
						{
							lfname_temp[i] = ' ';			/* separator between tail and head */
						}
						else if((pos-3) < namelen)
						{
							lfname_temp[i] = pFilename_buffer[BANK_index].filename[pos-3];
						}
						else
						{
							lfname_temp[i] = ' ';
						}
					}
					if(lfname_temp[i] == 0) lfname_temp[i] = ' ';
				}
				lfname_temp[Max_char] = 0;
				Draw_Text(lfname_temp, Max_char, x_offset, y_offset + file_select);
				
			}
		}

	}		
}
// --------------------------------------------------------------------
void Show_SD_list(void)
{
	FRESULT res;
	BYTE file_select;
	UINT16 show_offset;
	BYTE updata;
	BYTE keysrepeat;
	BYTE keydiv = 0;
	/* There used to be a local `BYTE FR_OK=0;` shadowing FatFs' FR_OK enum (0): the
	   comparison below tested that variable and only looked right because it was 0,
	   the same value as the enum. Removed so it refers to the real enum. */
	UINT8 save_flag;
	
	UINT8 save_size	;	
	UINT8 namelen;
	UINT16 count;	
	
	UINT8 page_num;
	UINT8 try_level;		/* 0: the path itself, 1: its parent, 2: the card root */
	UINT8 err_stage;		/* which call failed, shown by Show_error_info() */
	UINT16 plen;
	TCHAR *pext;
	/* locals for the recently played list (START) */
	UINT8  rn, rsel, rdiv, rkey;
#ifdef LANG_ZH
	UINT8  rtop;					/* first entry of the recent-list scroll window (9 rows on screen in zh) */
#endif
	UINT16 rshift;			/* scroll counter for long selected names in the recent list */
	TCHAR *rext;
	INT16  rpathlen;
	
	UINT8 BANK_index;
	UINT8 BANK_num;
	
	UINT32 shift;
	pFilename_buffer = (FM_FILE_FS*)0xa000;
	
	res = f_mount(&EZcardFs, "", 1);
	if( res != FR_OK)
	{
		Draw_Text(UI_ERR_SD_INIT, UI_LEN(UI_ERR_SD_INIT), 0, g_y); 
		while(1);
	}
	else
	{
		Draw_Text(UI_OK_SD_INIT, UI_LEN(UI_OK_SD_INIT), 0, g_y);
	}
	
	//check save info
	{	
		UINT8 is_autosave;	
					
		HW_BANK = SAVE_info_sram_bank;
		hw_set_page(A000Address_SRAM);
		save_flag = *((volatile UINT8 *)(FlashBase_SRAM+0));
		
		if(save_flag == 0xAAu){
			
				is_autosave = *((volatile UINT8 *)(FlashBase_SRAM+0x200));
				is_lasttime = *((volatile UINT8 *)(FlashBase_SRAM+0x202));

				save_size = *((volatile UINT8 *)(FlashBase_SRAM+1));			//save size	
				*((volatile UINT8 *)(FlashBase_SRAM+0)) = 0;
				
				namelen =  *((volatile UINT8 *)(FlashBase_SRAM+0xF));			//save name len	
				/* SRAM survives power-off and old firmware can corrupt it: namelen can be 255
				      while currentpath_temp only reaches [MAX_path_len-1] (254), so writing
				      currentpath_temp[namelen] would overflow by one byte. */
				if(namelen > MAX_path_len-1) namelen = MAX_path_len-1;
				
				
				for(count=0;count<namelen;count++)
				{
					currentpath_temp[count] = *((volatile UINT8 *)(FlashBase_SRAM+0x10+count));
				}
				
				currentpath_temp[namelen] =0;
				
				hw_set_page(A000Address_TF);
				res = f_mkdir_bank("/SAVER");


				Show_SAVE_info(save_size,is_autosave);				
		}
		HW_BANK = 0;
		hw_set_page(A000Address_TF);
		
	}
	
	memset(currentpath,00,MAX_path_len);
	currentpath[0] = '/';

	/* Append the last launched game to /SAVER/Recently play.txt.
	   Done here (at boot, before reading the directory) instead of just before
	   launching: that point is followed by LoadSAVE2SRAM / Check_game_save_FAT /
	   Send_FATbuffer, and rewriting a file there corrupts the directory entry. */
	Recently_Commit();

refind_file:
	g_y = 0;
	g_x = 0;
	page_num = 0;
	Read_file_end = 0;
#ifdef LANG_ZH
	/* Draw the page frame before reading the card (en keeps the old behaviour):
	   Read_all_DIR can take seconds on a big card and a blank screen looks bad.
	   Clear, draw the SD/SET/HELP tabs, then put the grey Reading dialog in the list
	   area, so the wait shows a full page frame instead of a white screen.
	   After reading, DrawGB(0) clears again (the list is drawn from SRAM, fast). */
	DrawGB(0);
	zh_tabbar(0);
#endif
	Show_reading();
	
	/* Resolve the directory, degrading one level at a time.
	   One unreadable folder used to either spin forever in Show_error_info() or
	   throw the user all the way back to the card root. Walking up a single level
	   keeps the rest of the folder list usable, so a bad folder is a detour and
	   not a dead end. */
	for(try_level = 0U; try_level < 3U; try_level++)
	{
		hw_set_page(A000Address_TF);	// switch back to the TF (SD) page
		res = f_chdir(currentpath);
		err_stage = 1U;					/* f_chdir failed */
		if(res == FR_OK)
		{
			res = f_opendir(&dir, currentpath);
			err_stage = 2U;				/* f_opendir failed */
		}
		if(res == FR_OK) break;

		Show_error_info((UINT8)res, err_stage, (const char *)currentpath);
		if(currentpath[0] == '/' && currentpath[1] == 0)
			break;			/* already at the root: nothing left to fall back to */

		if(try_level == 0U)
		{
			/* drop the last component: /A/B -> /A, /A -> / */
			plen = (UINT16)strlen(currentpath);
			while(plen > 1U && currentpath[plen - 1U] != '/') plen--;
			if(plen > 1U) currentpath[plen - 1U] = 0;
			else { currentpath[0] = '/'; currentpath[1] = 0; }
		}
		else
		{
			currentpath[0] = '/';
			currentpath[1] = 0;
		}
	}

	game_folder_total = 0;
	memset(lfname_temp,00,MAX_path_len);
	/* fileinfo is a struct, not a pointer: (void*)fileinfo relies on SDCC's
	   "struct name is its address" extension. &fileinfo is standard C. */
	memset(&fileinfo,00,sizeof(fileinfo));
	fileinfo.lfname = lfname_temp;
	fileinfo.lfsize  =MAX_filename_len;


	/* Two passes: directories first, then files. The whole directory is read here. */
	Read_all_DIR();

	/* A failed read while scanning the directory used to look like an empty
	   folder. Report it instead of showing a list that silently stopped. */
	if(readdir_fail)
		Show_error_info(readdir_fail, readdir_stage, (const char *)currentpath);
	
	file_select = 0;
	show_offset = 0;
	updata = 1;
	shift = 0;

#ifdef LANG_ZH
	/* No visible clear after reading: list_zh_show repaints progressively and its
	   list-area fill wipes the Reading dialog on the way, so no white flash.
	   Only the grey-background tracker is reset: zh_screen_init (ui_zh.c) does not
	   use the box macro, so a stale Reading rect would make Draw_Text paint a grey
	   background for anything landing inside (35..125, 37..108). */
	zh_box_forget();
#else
	DrawGB(0);
	DrawGB(3);//clean all
#endif
	
re_showfile:
	while(1)
	{
		shift++;		
		if(updata)
		{
			shift = 0;
			if(updata==1){
				
				hw_set_page(A000Address_SRAM);
				Show_filename(show_offset,file_select);
			}
			else if(updata>1){
				hw_set_page(A000Address_SRAM);
				Refresh_filename(show_offset,file_select,updata);
			}
		}
		if(game_folder_total){
			Filename_loop(shift,show_offset,file_select);
		}

		
		updata=0;
		wait_vbl_done();		/* 16.7ms per loop instead of a fixed delay(45) */
		keysrepeat = joypad();
		/* joypad() has no repeat delay: sampling the direction keys only on
		   every KEY_DIR_DIV-th frame halves the cursor speed. */
		if(++keydiv >= KEY_DIR_DIV)
		{
			keydiv = 0;
		}
		else
		{
			keysrepeat &= (UINT8)~(J_LEFT | J_RIGHT | J_UP | J_DOWN);
		}

		if(keysrepeat & J_LEFT){
	    if ( show_offset )
	    {
	      if ( show_offset > (LIST_ROWS - 1))
	        show_offset -= LIST_ROWS;
	      else
	        show_offset = 0;

	      updata=1;
	    }
	    else{
	    	if(file_select){
	    		file_select=0;
	    		updata=1;
	   	 	}
	    }
    }
		else if(keysrepeat &  J_RIGHT){
			/* The directory was read on entry (Read_all_DIR); paging only moves the window */
      if ( show_offset + LIST_ROWS < game_folder_total )
      {
        if ( show_offset + (LIST_ROWS * 2) <= game_folder_total )
          show_offset += LIST_ROWS;
        else
          show_offset = game_folder_total - LIST_ROWS;

				updata=1;
      }
		}
		else if(keysrepeat &  J_UP){
			if (file_select) {
				file_select--;
				updata=3;
			}
			else if (show_offset) {
				show_offset--;		/* at the first row: scroll the window up by one */
				updata=1;
			}
    }
		else if(keysrepeat &  J_DOWN){
			/* At the last row, scrolling moves the whole window down by one.
			   The English build only tested file_select and never advanced show_offset, so
			   the cursor stuck on the last row (that block is commented out in 1.06e). */
			if (file_select < (LIST_ROWS - 1))
			{
				if ((UINT16)(show_offset + file_select + 1) < game_folder_total)
				{
					file_select++;
					updata=2;
				}
			}
			else if ((UINT16)(show_offset + LIST_ROWS) < game_folder_total)
			{
				show_offset++;
				updata=1;
			}
    }
		else if(keysrepeat &  J_SELECT){
			page_num++;
			if(page_num==2){
				page_num=0;
			}
			else if(page_num==1){
				DrawGB(1);
				Set_window();
				page_num	=2;	
				
				/*updata=1;
				delay(200);
				goto refind_file;*/
			}
			
			if(page_num==2){//help
				DrawGB(2);
				Help_window();
				updata=1;
				delay(50);
				goto refind_file;	// re-read the folder (the SRAM list has been overwritten)
			}
    }
    else if(keysrepeat & J_START){
				/* Recently played: read /SAVER/Recently play.txt, up/down to select, A to boot,
				   B to go back. Recently_Load borrows the list area (bank 18+) for the records,
				   so B must goto refind_file to re-read the directory. */
				rn = Recently_Load();
				if(rn == 0)
				{
					/* no records yet: go straight back to the list */
					updata = 1;
					goto re_showfile;
				}

				rsel = 0;
#ifdef LANG_ZH
				rtop = 0;				/* scroll window starts at entry 0 */
#endif
				rdiv = 0;
				rshift = 0;

				DrawGB(4);				/* clear the whole screen: no tab bar */
#ifdef LANG_ZH
				/* zh build: the recent list is also 12px APA, so Chinese names render.
				   list_zh_recent draws the title (y0); no bottom bar (font set too small). */
				list_zh_recent(rn, rsel);
#else
				Draw_Text(UI_RECENT_TITLE, UI_LEN(UI_RECENT_TITLE), 3, 0);	/* centred title */
				Show_gamelist_BG();		/* bottom [B]return / [A]start */
				Show_recent_list(rn, rsel);
#endif

				while(1)
				{
					wait_vbl_done();
					rshift++;				/* long-name scrolling (Show_recent_scroll dwells first) */
#ifndef LANG_ZH
					Show_recent_scroll(rn, rsel, rshift);
#endif
					if(++rdiv >= 2)			/* sample every 33ms, matching the list speed */
					{
						rdiv = 0;
						rkey = joypad();
					}
					else
					{
						rkey = 0;
					}

					if(rkey & J_UP)
					{
#ifdef LANG_ZH
						/* Redraw two rows only: per-pixel drawing is expensive, a full repaint stutters.
						   rtop is the first visible entry; scrolling above it shifts the window up. */
						if(rsel)
						{
							UINT8 oldsel = rsel;
							rsel--;
							rshift = 0;
							if(rsel < rtop) { rtop = rsel; list_zh_recent_window(rn, rtop, rsel); }
							else list_zh_recent_refresh(rtop, oldsel, rsel);
						}
#else
						if(rsel) { rsel--; rshift = 0; Show_recent_list(rn, rsel); }
#endif
					}
					else if(rkey & J_DOWN)
					{
#ifdef LANG_ZH
						/* Up to 14 records but only 9 rows: when the cursor leaves the bottom of the
						   window it scrolls down by one (the English build shows all 14 rows).
						   The old code pinned an out-of-range index to the last row, so the cursor could
						   reach entries 10..14 off screen (A would boot a game that was not shown):
						   the "one extra row when scrolling down" report. */
						if(rsel + 1 < rn)
						{
							UINT8 oldsel = rsel;
							rsel++;
							rshift = 0;
							if((UINT8)(rsel - rtop) >= ZH_RECENT_ROWS)
							{
								rtop = (UINT8)(rsel - (ZH_RECENT_ROWS - 1U));
								list_zh_recent_window(rn, rtop, rsel);
							}
							else list_zh_recent_refresh(rtop, oldsel, rsel);
						}
#else
						if(rsel + 1 < rn) { rsel++; rshift = 0; Show_recent_list(rn, rsel); }
#endif
					}
					else if(rkey & J_A)
					{
						HW_BANK = Folder_sram_bank;
						strncpy(lfname_temp, (char*)pFilename_buffer[rsel].filename, MAX_path_len-1);
						lfname_temp[MAX_path_len-1] = 0;

						rext = my_strrchr(lfname_temp, '/');
						if(rext == NULL) continue;
						rpathlen = (INT16)(rext - lfname_temp);
						if(rpathlen < 0 || rpathlen >= MAX_path_len) continue;

						memcpy(currentpath, lfname_temp, (UINT16)rpathlen);
						currentpath[rpathlen] = 0;
						if(rpathlen == 0) { currentpath[0]='/'; currentpath[1]=0; }

						hw_set_page(A000Address_TF);
						f_chdir(currentpath);
						memmove(lfname_temp, rext+1, strlen(rext+1)+1);

						Save_filename();	/* also updates SRAM 0x300 and the recent-record order */
						Show_loading();
						goto BOOT;
					}
					else if(rkey & J_B)
					{
						updata = 1;
						goto refind_file;	/* the list was overwritten: re-read the directory */
					}
				}
    }
		else if(keysrepeat &  J_A){
						BANK_num = (show_offset+file_select)/Num_perBank;
						BANK_index = (show_offset+file_select)%Num_perBank;			
						HW_BANK = Folder_sram_bank+BANK_num;
						if(pFilename_buffer[BANK_index].fattrib == AM_DIR)
						{
								UINT16 plen = strlen(currentpath);
							UINT16 flen = strlen((char*)pFilename_buffer[BANK_index].filename);
							/* check the length first: refuse instead of overrunning currentpath */
							if(plen + flen + 2 >= MAX_path_len)
							{
								/* This used to be Draw_Text("Path too long!",15,0,20):
								      1) row 20 is off a 144-pixel-high screen, so nothing showed;
								      2) len=15 is one longer than the string, triggering the white fill (a flash).
								   Just go back to the list. */
								goto refind_file;
							}
							res =  mystrcmp(currentpath,"/");
							if(res !=0){
								mystrcat_n(currentpath,"/",MAX_path_len);
							}
							mystrcat_n(currentpath,(char*)pFilename_buffer[BANK_index].filename,MAX_path_len);
							goto refind_file;
						}
			      
						else{   //  file
							Show_loading();
	
							mem_set(lfname_temp,0x00,MAX_path_len);
							strcpy(lfname_temp,pFilename_buffer[BANK_index].filename);
	
			      								
							pext=my_strrchr(lfname_temp, '.');
							/* with no extension pext is NULL: the old code copied 5 bytes from 0x0000 */
							if((pext == NULL) || ((UINT16)(pext - lfname_temp) + 5 > MAX_path_len))
							{
								Show_Error_file();
								while(joypad() != J_B) delay(50);
								goto refind_file;
							}
							mem_set(currentpath_temp,0x00,6);
							memcpy(currentpath_temp,pext,5);
							if(XIAOXIE(currentpath_temp[1])) currentpath_temp[1] = ZHUANDAXIE(currentpath_temp[1]);
							if(XIAOXIE(currentpath_temp[2])) currentpath_temp[2] = ZHUANDAXIE(currentpath_temp[2]);	// lowercase to uppercase
							if(XIAOXIE(currentpath_temp[3])) currentpath_temp[3] = ZHUANDAXIE(currentpath_temp[3]);

							if( mem_cmp(currentpath_temp,".GBC",5)  )//mystrcmp(currentpath,"/");
							{			
								 		
				      	if( mem_cmp(currentpath_temp,".GB",4)  )
								{
									Show_Error_file();
									while(1)//3
									{
										keysrepeat = joypad();
										
										if(keysrepeat &  J_B){
											break;
								    }
									}
									goto refind_file;	
								}							
							}
							Save_filename();
								
							BOOT:
							res = GatherMetadata(lfname_temp/*pFilename_buffer[show_offset+file_select-folder_total].filename*/);
							if(res == 0xFF){
								/* The ROM could not be opened. Two causes: unreadable/corrupt,
								   or the name holds a character the code page cannot convert
								   (FatFs' create_name rejects the whole name then, and a
								   GBK-only ideograph is still unsupported). Say so instead of
								   leaving the user staring at the "Loading..." dialog, which
								   looked exactly like a freeze. */
								Show_Error_file();
								while(joypad() != J_B) delay(50);
								goto refind_file;
							}							
							
							
							{// 0 1
								if(m_bBattery){	// save exists
									Show_LOAD_info(0);							/* loading: show a hint so it does not look frozen */
									if(LoadSAVE2SRAM(lfname_temp,0x2000) == 0)
										Show_LOAD_info(1);					/* existing save read */
									else
										Show_LOAD_info(2);					/* no save file: blank save created */
								}	

								//	
								/* Non-zero = the ROM's FAT chain cannot be described to the FPGA
								   (broken chain / too fragmented). Booting it would hang the DMA
								   for ever, so abort to the list instead; Check_game_save_FAT
								   already showed the message. */
								if(Check_game_save_FAT(lfname_temp) != 0) goto refind_file;
								hw_set_page(A000Address_FATbuffer);
															
								SetTypesControl((m_bRTCPresent<<7) |m_Type);
								Set_GBboy(/*is_gbboy*/0);

								SetRAMBankCount(m_iRAMSize);
								SetROMBankCount(m_iROMSize );
								SetROMHeader_Checksum();

								DISPLAY_OFF;									//
								disable_interrupts();	
								Send_FATbuffer(SD_buffer);//   boot 	/* the second argument (bootmode) is unused inside the function */

								while(1);							
							}
							break;							
						}
				}
		else if(keysrepeat &  J_B){
		   			if(mystrcmp(currentpath,"/") !=0 ){		
			    		memcpy(currentpath_temp,currentpath,MAX_path_len);
			    		{
			    			TCHAR *p=my_strrchr(currentpath_temp, '/');
			    			memset(currentpath,0x00,MAX_path_len);
			    			memcpy(currentpath, currentpath_temp, p-currentpath_temp);
			    		}
			    		if(currentpath[0]==0) currentpath[0]='/';

					    goto refind_file;
				    }
    }
    
		wait_vbl_done();
	}
}
// --------------------------------------------------------------------
void _ultoa(unsigned long value, char *string, unsigned char radix)
{
	char tmp[33];

	unsigned long i;
	char *sp;	
	char *tp = tmp;	
	unsigned long v = value;

	while (v || tp == tmp)
	{
		i = v % radix;
		v = v / radix;
		if (i < 10)
		*tp++ = i+'0';
		else
		*tp++ = i + 'a' - 10;
	}	

	sp = string;
	
	while (tp > tmp)
	*sp++ = *--tp;
	*sp = 0;

}
// --------------------------------------------------------------------
void main() {
	UINT16 Read;
	UINT8 xx;

	g_y = 0;
	{
		UINT8 battery_flag;	
		BYTE keysrepeat;
						
		HW_BANK = SAVE_info_sram_bank;
		hw_set_page(A000Address_SRAM);
		battery_flag = *((volatile UINT8 *)(FlashBase_SRAM+0x201));
		if(battery_flag != 0x88)
		{
			Draw_Text(" ", 1, 5, 8);	
			color(BLACK,DKGREY,SOLID);
	
			box(35,37,125,108,M_FILL);
			Draw_Text(UI_BATTERY, UI_LEN(UI_BATTERY), 5, 7);	
			Draw_Text(UI_BATTERY_DRY, UI_LEN(UI_BATTERY_DRY), 5, 8);
			
			color(BLACK,DKGREY,SOLID);
			box(78,93,123,106,M_FILL);  //A btn
#ifdef LANG_ZH
			/* same as the save dialog: 12px glyphs at y94, no background fill,
			   so they stay inside the box and its border survives */
			zh_text_at(94, 83, (const UINT8 *)UI_BTN_OK, 160);	/* 80 + 3px, same as the save dialog */
#else
			Draw_Text(UI_BTN_OK, UI_LEN(UI_BTN_OK), 10, 12);
#endif
			while(1)//3
			{
				keysrepeat = joypad();
				
				if(keysrepeat &  J_A){
					*((volatile UINT8 *)(FlashBase_SRAM+0x201)) = 0x88;			
		

					break;
		    }
			}		
		}
		color(BLACK,WHITE,SOLID);
		HW_BANK = 0;
		hw_set_page(A000Address_TF);		
	}
	Show_SD_list();
}
// --------------------------------------------------------------------
FRESULT f_open_bank (
	FIL* fp,			/* Pointer to the blank file object */
	const TCHAR* path,	/* Pointer to the file name */
	BYTE mode			/* Access mode and file open mode flags */
)
{
	return  f_open (fp,path,mode);
}
// --------------------------------------------------------------------
FRESULT f_read_bank (
	FIL* fp, 		/* Pointer to the file object */
	void* buff,		/* Pointer to data buffer */
	UINT btr,		/* Number of bytes to read */
	UINT* br		/* Pointer to number of bytes read */
)
{
	return  f_read (fp,buff,btr,br);
}
// --------------------------------------------------------------------
FRESULT f_write_bank (
	FIL* fp,			/* Pointer to the file object */
	void *buff,	/* Pointer to the data to be written */
	UINT btw,			/* Number of bytes to write */
	UINT* bw			/* Pointer to number of bytes written */
)
{
	return f_write(fp,buff,btw,bw);
}
// --------------------------------------------------------------------
FRESULT f_lseek_bank (
	FIL* fp,		/* Pointer to the file object */
	DWORD ofs		/* File pointer from top of file */
)
{
	return  f_lseek (fp,ofs);
}
// --------------------------------------------------------------------
FRESULT f_close_bank (
	FIL *fp		/* Pointer to the file object to be closed */
)
{
	return  f_close (fp);
}
// --------------------------------------------------------------------
FRESULT f_mkdir_bank  (
	const TCHAR* path		/* Pointer to the directory path */
)
{
	return  f_mkdir (path);
}
// --------------------------------------------------------------------
UINT32 ClustToSect(
	FATFS* fs,		/* File system object */
	UINT32 clst		/* Cluster# to be converted */
	)
{
	return clust2sect(fs,clst);
}
// --------------------------------------------------------------------
UINT32 Get_NextCluster(FATFS* fs,UINT32 clst)
{
	return get_fat (fs,clst);
}