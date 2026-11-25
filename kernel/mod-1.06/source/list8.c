/* ============================================================================
   list8.c  -  mod: the 8px list's name scroll (bank 4)
   ----------------------------------------------------------------------------
   Filename_loop, moved here from main.c as it was, because bank 0 has no
   room left. Two changes: it hands over to the 12px list when that is the
   font, and it scrolls the name as it is drawn (name_shown, browser.c).
   ========================================================================== */

#include <gb/gb.h>
#include <gb/drawing.h>
#include <string.h>

#include "ezgb_hw.h"
#include "main.h"
#include "ff.h"
#include "Bank_fun.h"
#include "list12.h"

#ifdef LANG_ZH
#include "ui_zh.h"
#endif

#pragma bank 4

extern TCHAR lfname_temp[];

void Filename_loop(UINT32 shift,UINT16 show_offset,UINT16 file_select) __banked
{
#if defined(LANG_ZH) && !defined(ZH_LIST_OFF)
	list_zh_loop(shift, show_offset, file_select);
	return;
#endif
#ifndef LANG_ZH
	if(ui_font)		/* mod: the 12px list, list12.c */
	{
		list12_loop(shift, show_offset, file_select);
		return;
	}
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

		namelen = name_shown(&pFilename_buffer[BANK_index]);	/* mod: the name as drawn (CLEAN NAMES) */
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
