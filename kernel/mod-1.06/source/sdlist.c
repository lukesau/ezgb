/* ============================================================================
   sdlist.c  -  mod: Show_SD_list, moved out of bank 0
   ----------------------------------------------------------------------------
   The SD tab's main loop, from main.c as it was (with the mod's hooks in
   it), now banked: it was 2.9 KB of bank 0, where everything every bank
   calls has to live and which was full.

   One thing had to change with the move. A string literal of a banked
   function is in that function's bank, and a function in another bank
   cannot read it: so the literals this one passed to banked functions (the
   mount point, "/SAVER", and "/" four times) are now arrays in RAM, s_none,
   s_saver and s_root. Literals handed to Draw_Text are fine: it is in bank
   0 and this bank is still mapped when it reads them.
   ========================================================================== */

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
#include "ezcfg.h"		/* mod: the settings file */
#include "list12.h"		/* mod: the 12px list */
UINT8 list8_scroll(UINT16 old_offset, UINT16 show_offset, UINT16 file_select) __banked;	/* mod: list8.c */
#include "rommenu.h"		/* mod: the hold-A menu */
#include "savemgr.h"		/* mod: the daily backup */

#ifdef LANG_ZH
#include "ui_zh.h"		/* Chinese list renderer (list_zh.c) */
#include "zh_bg.h"		/* tracks the color() background (zh_text_row uses it to fill a row) */
#endif

#include "modbank.h"

/* main.c's */
extern UINT8 SD_buffer[0x200];
extern FM_FILE_FS *pFilename_buffer;
extern UINT16 game_folder_total;
extern UINT8 readdir_fail;
extern UINT8 readdir_stage;
extern UINT16 ROMBankCount_real;
extern TCHAR currentpath[MAX_path_len];
extern TCHAR currentpath_temp[MAX_path_len];
extern TCHAR lfname_temp[MAX_path_len];
extern enum CartridgeTypes m_Type;
extern BOOL m_bBattery;
extern BOOL m_bRTCPresent;
extern UINT8 m_iROMSize;
extern UINT8 m_iRAMSize;
extern UINT8 Header_Checksum;
extern UINT8 Read_file_end;
extern UINT8 is_lasttime;
extern FATFS EZcardFs;
extern FILINFO fileinfo;
extern DIR dir;
extern FIL gfil;
extern BYTE g_y;
extern BYTE g_x;

/* in RAM, so that a banked function can read them (see the top) */
static char s_none[1] = "";
static char s_root[2] = "/";
static char s_saver[7] = "/SAVER";

/* Direction-key sampling divider for the file list.
   The main loop is frame synced (~16.7ms), and joypad() has no built-in repeat
   delay, so the cursor speed equals the loop rate. 2 = every other frame
   (~33ms per step, half of the current speed); use 3 for ~50ms. */
#define KEY_DIR_DIV  2
/* Frames up or down is held before it repeats (0.3 s) */
#define KEY_HOLD_DELAY  19U

/* main.c has these too: they are static there */
static
int mem_cmp (const void* dst, const void* src, BYTE cnt) {
	const BYTE *d = (const BYTE *)dst, *s = (const BYTE *)src;
	int r = 0;

	while (cnt-- && (r = *d++ - *s++) == 0) ;
	return r;
}
static
void mem_set (void* dst, int val, BYTE cnt) {
	BYTE *d = (BYTE*)dst;

	while (cnt--)
		*d++ = (BYTE)val;
}

void Show_SD_list(void) __banked
{
	FRESULT res;
	BYTE file_select;
	UINT16 show_offset;
	BYTE updata;
	BYTE keysrepeat;
	BYTE keydiv = 0;
	UINT8 keyhold = 0;
	UINT8 keynext = 0;		/* mod: the frame of the hold the key next repeats on */
	UINT8 keystage = 0;		/* mod: how far the repeat has sped up */
	UINT8 navstep = 1;		/* mod: rows a scroll moves this poll */
	UINT8 key_t = 0;		/* mod: the frame the held key last acted on */
	UINT8 keymark = 0;		/* mod: a press was just acted on: key_t is taken once it is drawn */
	UINT8 to_set = 0;		/* mod: a game was picked: the SET tab is next */
	UINT8 count_play = 0U;	/* mod: this launch is one from the list */
	UINT16 scroll_from = 0;		/* mod: where the list was before a scroll (updata 4) */
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
	
	res = f_mount(&EZcardFs, s_none, 1);
	if( res != FR_OK)
	{
		Draw_Text(UI_ERR_SD_INIT, UI_LEN(UI_ERR_SD_INIT), 0, g_y); 
		while(1);
	}
	else
	{
		Draw_Text(UI_OK_SD_INIT, UI_LEN(UI_OK_SD_INIT), 0, g_y);
	}
	cfg_boot();		/* mod: read /EZGB.CFG, before the pending save is backed up */
	
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
				res = f_mkdir_bank(s_saver);


				/* mod: the stamp is in save RAM, where a weak cell leaves the flag
				   and garbage for the path: no prompt for anything but
				   "/SAVER/" and a save's name (docs/prompts.md) */
				if(save_stamp_ok())
				{
				save_daily(currentpath_temp, (UINT8)save_size);		/* mod: DAILY BACKUP, before the save is written (savemgr.c) */
				Show_SAVE_info(save_size,is_autosave);				
				cfg_backup();		/* mod: the clock to /EZGB.CFG, as at a launch */
				}
		}
		HW_BANK = 0;
		hw_set_page(A000Address_TF);
		
	}
	
	memset(currentpath,00,MAX_path_len);
	currentpath[0] = '/';

	/* Append the last launched game to /SAVER/RecentlyPlay_gb.txt.
	   Done here (at boot, before reading the directory) instead of just before
	   launching: that point is followed by LoadSAVE2SRAM / Check_game_save_FAT /
	   Send_FATbuffer, and rewriting a file there corrupts the directory entry. */
	Recently_Commit();

	/* mod: FLAUNCH= in /EZGB.CFG starts a game before the first listing */
	if(cfg_fastlaunch())
	{
		Save_filename();
		Show_loading();
		count_play = 0U;	/* mod: only a launch from the list is a play */
		goto BOOT;
	}

refind_file:
	pad_take();		/* mod: presses another screen acted on are not this list's */
	ui_font = ui_font_cfg;		/* mod: back from the recent list */
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
relisted:
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
	pad_take();		/* mod: presses another screen acted on are not this list's */
	while(1)
	{
		shift++;		
		if(updata)
		{
			shift = 0;
#ifndef LANG_ZH
			/* mod: a scroll by a few rows moves the rows that stay (list12.c,
			   list8.c) where a page draw takes most of half a second */
			if(updata==4){
				hw_set_page(A000Address_SRAM);
				if(ui_font) list12_scroll(scroll_from, show_offset, file_select);
				else if(!list8_scroll(scroll_from, show_offset, file_select)) Show_filename(show_offset,file_select);
			}
			else
#else
			if(updata==4) updata=1;
#endif
			if(updata==1){
				
				hw_set_page(A000Address_SRAM);
				Show_filename(show_offset,file_select);
			}
			else if((updata>1) && (updata<4)){
				hw_set_page(A000Address_SRAM);
				Refresh_filename(show_offset,file_select,updata);
			}
		}
		if(keymark)		/* mod: the press is drawn: its hold delay starts here */
		{
			keymark = 0;
			key_t = (UINT8)sys_time;
		}
		if(game_folder_total){
			Filename_loop(shift,show_offset,file_select);
		}

		
		updata=0;
		wait_vbl_done();		/* 16.7ms per loop instead of a fixed delay(45) */
		/* mod: the directions as held, the buttons once a press (sgb.s) */
		keysrepeat = (UINT8)((joypad() & 0x0FU) | (pad_take() & 0xF0U));
		/* joypad() has no repeat delay: sampling left and right only on
		   every KEY_DIR_DIV-th frame halves the cursor speed. */
		if(++keydiv >= KEY_DIR_DIV)
		{
			keydiv = 0;
		}
		else
		{
			keysrepeat &= (UINT8)~(J_LEFT | J_RIGHT);
		}
		/* mod: up and down repeat the way the released 1.06e does. The first
		   frame of a press moves the cursor, then nothing until the key has
		   been held KEY_HOLD_DELAY frames, then every fourth frame. */
		/* A held key speeds up (docs/browser.md "Moving around"): after the
		   delay it repeats 6, 6, 5, 5, 4, 4 and then every 3 frames, and
		   while the list scrolls it moves 1, 1, 2, 2, 3, 3 and then 4 rows
		   a step. */
		/* It is timed in frames (sys_time, which the VBlank handler counts),
		   not in passes of this loop: a pass is a frame or two and whatever
		   it drew, which made a held key half as fast as the 0918 mod's.
		   A press moves at once, and its 18 frames run from the end of
		   that move's drawing, so a slow draw is not a second move. */
		navstep = 1U;
		if(keysrepeat & (J_UP | J_DOWN))
		{
			if(!keyhold)
			{
				keyhold = 1U;
				keystage = 0U;
				keynext = 18U;
				keymark = 1U;
			}
			else if((UINT8)((UINT8)sys_time - key_t) >= keynext)
			{
				keynext = (keystage < 6U) ? (UINT8)(6U - (keystage >> 1)) : 3U;
				if(keystage < 6U) keystage++;
				navstep = (UINT8)((keystage >> 1) + 1U);
				key_t = (UINT8)sys_time;
			}
			else keysrepeat &= (UINT8)~(J_UP | J_DOWN);
		}
		else
		{
			keyhold = 0;
		}

		/* mod: the list is up to pick the fast launch game (docs/set-tab.md,
		   PICK ROM): A on a game takes it, SELECT or B in the root gives
		   up, and both go back to the SET tab, by way of the SELECT branch
		   below. START does nothing. */
		if(pick_rom || to_set)
		{
			keysrepeat &= (UINT8)~J_START;
			if(to_set || (keysrepeat & J_SELECT) || ((keysrepeat & J_B) && (currentpath[1] == 0)))
			{
				pick_rom = 0;
				to_set = 0;
				page_num = 0;
				keysrepeat = J_SELECT;
			}
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
			/* mod: on the last page RIGHT goes to its bottom row, as LEFT on
			   the first goes to the top one */
			else if(game_folder_total && ((UINT16)(show_offset + file_select + 1) < game_folder_total))
			{
				file_select = (BYTE)(game_folder_total - show_offset - 1);
				updata=1;
			}
		}
		else if(keysrepeat &  J_UP){
			if (file_select) {
				file_select--;
				updata=3;
			}
			else if (show_offset) {
				/* at the first row: scroll the window up (mod: by navstep) */
				scroll_from = show_offset;
				show_offset = (show_offset > navstep) ? (UINT16)(show_offset - navstep) : 0;
				updata=4;
			}
			/* mod: the list wraps. UP on the first entry is the last one. */
			else if (game_folder_total > 1) {
				if (game_folder_total > LIST_ROWS) {
					show_offset = game_folder_total - LIST_ROWS;
					file_select = LIST_ROWS - 1;
				}
				else file_select = (BYTE)(game_folder_total - 1);
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
				/* mod: by navstep, and not past the end */
				scroll_from = show_offset;
				show_offset += navstep;
				if((UINT16)(show_offset + LIST_ROWS) > game_folder_total)
					show_offset = game_folder_total - LIST_ROWS;
				updata=4;
			}
			/* mod: the list wraps. DOWN on the last entry is the first one. */
			if (!updata && (game_folder_total > 1) &&
			    ((UINT16)(show_offset + file_select + 1) >= game_folder_total))
			{
				show_offset = 0;
				file_select = 0;
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
				if(pick_rom)		/* mod: GAME: on the SET tab wants a game picked from the list */
				{
					updata=1;
					goto refind_file;
				}
				if(tab_to_sd)		/* mod: START on the SET tab is the SD tab, not HELP */
				{
					tab_to_sd = 0;
					updata=1;
					goto refind_file;
				}
				
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
				/* Recently played: read /SAVER/RecentlyPlay_gb.txt, up/down to select, A to boot,
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
				if(ui_font)
				{
					/* mod: centered by its width, not by cells */
					UINT8 rt[UI_LEN(UI_RECENT_TITLE) + 1U];

					memcpy(rt, UI_RECENT_TITLE, UI_LEN(UI_RECENT_TITLE) + 1U);
					text12_center(rt, 0U);
				}
				else
				Draw_Text(UI_RECENT_TITLE, UI_LEN(UI_RECENT_TITLE), 2, 0);	/* centred title */
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
						count_play = 0U;	/* mod: only a launch from the list is a play */
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
							res =  mystrcmp(currentpath,s_root);
							if(res !=0){
								mystrcat_n(currentpath,s_root,MAX_path_len);
							}
							mystrcat_n(currentpath,(char*)pFilename_buffer[BANK_index].filename,MAX_path_len);
							goto refind_file;
						}
			      
						else{   //  file
							if(pick_rom)
							{
								/* mod: this game is the fast launch game. The name
								   goes to WRAM first: the card is written. */
								const UINT8 *nm = pFilename_buffer[BANK_index].filename;
								UINT8 n = (UINT8)strlen((const char *)nm);

								if(!(((n > 3U) && (nm[n - 3U] == '.') && ((nm[n - 2U] | 0x20U) == 'g') && ((nm[n - 1U] | 0x20U) == 'b')) ||
								     ((n > 4U) && (nm[n - 4U] == '.') && ((nm[n - 3U] | 0x20U) == 'g') && ((nm[n - 2U] | 0x20U) == 'b') &&
								      ((nm[n - 1U] | 0x20U) == 'c'))))
									continue;			/* not a game */
								strcpy(lfname_temp, (const char *)nm);
								cfg_flaunch_pick(lfname_temp);
								to_set = 1;
								continue;
							}
							/* mod: a hold of A is the game's menu, and an A still held
							   from opening the folder is no press (rommenu.c) */
							{
								UINT8 rm = rom_menu(show_offset, file_select);
								if(rm == 2U)
								{
									/* starred or unstarred: its new place, from the
									   records, with no card read (browser.c) */
									list_resort(&show_offset, &file_select);
									goto relisted;
								}
								if(rm)
								{
									pad_take();	/* the menu's presses are not the list's */
									continue;
								}
							}
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

							if( mem_cmp(currentpath_temp,".GBC",5)  )//mystrcmp(currentpath,s_root);
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
							count_play = 1U;	/* mod: a launch from the list (plays.c) */
								
							BOOT:
							cfg_launch(count_play);		/* mod: the clock and AUTO SAVE to /EZGB.CFG */
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
								Set_GBboy(/*is_gbboy*/0x11);	/* mod: the fast-load key, on every console */

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
		   			if(mystrcmp(currentpath,s_root) !=0 ){		
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
    
		if(!keyhold) wait_vbl_done();	/* mod: a held UP or DOWN polls every frame */
	}
}
// --------------------------------------------------------------------
