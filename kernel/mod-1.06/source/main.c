
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
#include "rommenu.h"		/* mod: the hold-A menu */

#ifdef LANG_ZH
#include "ui_zh.h"		/* Chinese list renderer (list_zh.c) */
#include "zh_bg.h"		/* tracks the color() background (zh_text_row uses it to fill a row) */
#endif



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
	if(ui_font)
	{
		/* mod: the 12px font draws it (text12 in list12.c, bank 8). The
		   string may be a literal of the caller's bank, so it goes over
		   on the stack. */
		UINT8 b12[21];

		tt = (len == 0U || len > 20U) ? 20U : len;
		for(l = 0U; l < tt && str[l] != 0U; l++) b12[l] = str[l];
		b12[l] = 0U;
		text12(b12, len, x, y);
		return;
	}
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

/* mod: Read_all_DIR is in browser.c, where it also sorts and hides */
// --------------------------------------------------------------------
/* mod: Filename_loop is in list8.c (bank 4): bank 0 is full */
// --------------------------------------------------------------------
/* mod: Show_SD_list is in sdlist.c, banked: it was 2.9 KB of bank 0 */
/* mod: _ultoa is in modmisc.c, banked */
// --------------------------------------------------------------------
void Show_SD_list(void) __banked;	/* mod: sdlist.c */
void main() {
	UINT16 Read;
	UINT8 xx;

	g_y = 0;
	console_init();		/* mod: the palettes when the kernel runs in CGB mode */
	{
		UINT8 battery_flag;	
		BYTE keysrepeat;
						
		HW_BANK = SAVE_info_sram_bank;
		hw_set_page(A000Address_SRAM);
		battery_flag = *((volatile UINT8 *)(FlashBase_SRAM+0x201));
		if(battery_flag != 0x88)
		{
			cfg_dry = 1;		/* mod: cfg_boot puts AUTO SAVE back from the card */
			Draw_Text(" ", 1, 5, 8);	
#ifndef LANG_ZH
			battery_box(0);		/* mod: the small box, msgbox.c */
#else
			color(BLACK,DKGREY,SOLID);
	
			box(35,37,125,108,M_FILL);
			Draw_Text(UI_BATTERY, UI_LEN(UI_BATTERY), 5, 7);	
			Draw_Text(UI_BATTERY_DRY, UI_LEN(UI_BATTERY_DRY), 5, 8);
			
			color(BLACK,DKGREY,SOLID);
			box(78,93,123,106,M_FILL);  //A btn
			/* same as the save dialog: 12px glyphs at y94, no background fill,
			   so they stay inside the box and its border survives */
			zh_text_at(94, 83, (const UINT8 *)UI_BTN_OK, 160);	/* 80 + 3px, same as the save dialog */
#endif
			while(1)//3
			{
				keysrepeat = joypad();
				
				if(keysrepeat &  J_A){
					*((volatile UINT8 *)(FlashBase_SRAM+0x201)) = 0x88;			
		

					break;
		    }
			}		
#ifndef LANG_ZH
			battery_box(1);		/* mod: gone before the first Reading... box, which is smaller */
#endif
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