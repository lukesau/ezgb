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
#include "plays.h"

#ifdef LANG_ZH
#include "ui_zh.h"
#endif

#pragma bank 4

extern TCHAR lfname_temp[];
extern UINT16 game_folder_total;
extern void _ultoa(unsigned long value, char *string, unsigned char radix) __banked;

void vram_put2(UINT8 *dst, UINT16 planes);	/* vram_put.s */
UINT8 draw_colors(void);

static UINT8 up8(UINT8 c)
{
	if((c >= 'a') && (c <= 'z')) return (UINT8)(c - 0x20U);
	return c;
}

/* The icons of the 8px list, a byte a row with the left pixel in bit 7:
   folder, .gb cartridge, .gbc cartridge, any other file, a text file, a
   starred game. They are the 0918 mod's, which has them in the kernel's
   1bpp glyph sheet as codes $C0 to $C4 and $7F (docs/browser.md); the
   bytes here were read out of its build. The 12px fonts have theirs
   (font12.c). */
static const UINT8 icons8[6][8] = {
	{0xF0U, 0x90U, 0xFFU, 0x81U, 0x81U, 0x81U, 0xFFU, 0x00U},
	{0x7EU, 0x81U, 0xB5U, 0xB5U, 0x81U, 0x81U, 0x7EU, 0x00U},
	{0x7EU, 0x81U, 0xA9U, 0x95U, 0xA9U, 0x81U, 0x7EU, 0x00U},
	{0x7EU, 0x99U, 0xA5U, 0x89U, 0x81U, 0x89U, 0x7EU, 0x00U},
	{0xF8U, 0x8CU, 0x8EU, 0x81U, 0x81U, 0x81U, 0xFFU, 0x00U},
	{0x10U, 0x38U, 0xFEU, 0x7CU, 0x38U, 0x6CU, 0x44U, 0x00U},
};

static UINT8 icon8_of(const FM_FILE_FS *e)
{
	const UINT8 *nm = e->filename;
	UINT8 n = (UINT8)strlen((const char *)nm);

	if(e->fattrib == AM_DIR) return 0U;
	if(e->fattrib == FATTR_STARRED) return 5U;
	if((n > 3U) && (nm[n - 3U] == '.') && (up8(nm[n - 2U]) == 'G') && (up8(nm[n - 1U]) == 'B')) return 1U;
	if(n > 4U)
	{
		nm += n - 4U;
		if(nm[0] == '.')
		{
			if((up8(nm[1]) == 'G') && (up8(nm[2]) == 'B') && (up8(nm[3]) == 'C')) return 2U;
			if((up8(nm[1]) == 'T') && (up8(nm[2]) == 'X') && (up8(nm[3]) == 'T')) return 4U;
			if((up8(nm[1]) == 'I') && (up8(nm[2]) == 'N') && (up8(nm[3]) == 'I')) return 4U;
			if((up8(nm[1]) == 'C') && (up8(nm[2]) == 'F') && (up8(nm[3]) == 'G')) return 4U;
		}
	}
	if((n > 3U) && (e->filename[n - 3U] == '.') && (up8(e->filename[n - 2U]) == 'M') && (up8(e->filename[n - 1U]) == 'D')) return 4U;
	return 3U;
}

/* mod: the position in the folder, in the five columns right of HELP:
   n/total from a column that holds for the folder while the total has
   under three digits, else n alone from column 16. All five columns are
   written, so a shorter number leaves nothing of a longer one. */
void list8_counter(UINT16 n) __banked
{
	UINT8 s[12];
	UINT8 t[6];
	UINT8 tn;
	UINT8 x;
	UINT8 i;

	_ultoa((unsigned long)game_folder_total, (char *)t, 10u);
	tn = (UINT8)strlen((char *)t);
	x = (tn < 3U) ? (UINT8)(4U - tn - tn) : 1U;
	for(i = 0U; i < x; i++) s[i] = ' ';
	_ultoa((unsigned long)n + 1UL, (char *)s + x, 10u);
	x = (UINT8)strlen((char *)s);
	if(tn < 3U)
	{
		s[x++] = '/';
		for(i = 0U; i < tn; i++) s[x++] = t[i];
	}
	while(x < 5U) s[x++] = ' ';
	s[5] = 0U;
	color(BLACK, WHITE, SOLID);
	Draw_Text(s, 5, 15, 0);
}

/* mod: a row of the 8px list (docs/browser.md "Icons and the selection
   bar"): its icon in column 0, in the colors color() last set, so it
   inverts with the selected row, and the name in columns 1 to 19, for
   folders and files alike. The kernel as received gave a folder 17
   columns and a DIR tag. e's bank of save RAM is mapped. */
void list8_row(const FM_FILE_FS *e, UINT8 y) __banked
{
	const UINT8 *g = icons8[icon8_of(e)];
	UINT8 *dst = (UINT8 *)(UINT16)(0x8100U + (UINT16)y * 0x140U);
	UINT8 c = draw_colors();
	UINT8 a0 = (((c >> 2) ^ c) & 1U) ? 0xFFU : 0U;
	UINT8 x0 = (c & 1U) ? 0xFFU : 0U;
	UINT8 a1 = (((c >> 2) ^ c) & 2U) ? 0xFFU : 0U;
	UINT8 x1 = (c & 2U) ? 0xFFU : 0U;
	UINT8 e0[20];
	UINT8 n;
	UINT8 r;

	/* the name and blanks to the row's end, in one string: the selected
	   row is a bar across the screen */
	n = name_shown(e);
	if(n > 19U) n = 19U;
	memset(e0, ' ', 19U);
	e0[19] = 0U;
	memcpy(e0, e->filename, n);
	Draw_Text(e0, 19, 1, y);
	/* the icon last: Draw_Text is what puts the screen in graphics mode */
	for(r = 0U; r < 8U; r++, dst += 2)
		vram_put2(dst, (UINT16)(((UINT16)(UINT8)((g[r] & a1) ^ x1) << 8) | (UINT8)((g[r] & a0) ^ x0)));
}

void vram_copy_line(UINT8 *dst, UINT8 *src);	/* vram_put.s */

/* mod: entry idx drawn without the highlight on list row `row` */
static void list8_plain(UINT16 idx, UINT8 row)
{
	HW_BANK = Folder_sram_bank + (UINT8)(idx / Num_perBank);
	color(BLACK, WHITE, SOLID);
	list8_row(&pFilename_buffer[idx % Num_perBank], (UINT8)(2U + row));
}

/* mod: the 8px list scrolled from old_offset to show_offset with the
   cursor on its row, a full page of 16 on screen: the rows that stay are
   moved in VRAM. The row the cursor was on is drawn plain before the
   move, so the highlight is never on two rows; then the row under the
   cursor and the others the move uncovered (list12.c has the 12px list's). 0 when it is not such a scroll: the caller draws the page. */
UINT8 list8_scroll(UINT16 old_offset, UINT16 show_offset, UINT16 file_select) __banked
{
	UINT8 sel = (UINT8)file_select;
	UINT8 d;
	UINT8 n;
	UINT8 y;
	UINT8 r;
	UINT8 row;
	UINT8 pass;
	UINT16 idx;

	if(show_offset > old_offset)
	{
		d = (UINT8)(show_offset - old_offset);
		if((d >= 16U) || (sel != 15U)) return 0U;
		list8_plain((UINT16)(old_offset + 15U), 15U);
		n = (UINT8)((16U - d) << 3);
		for(y = 16U; n; n--, y++)
			vram_copy_line((UINT8 *)(UINT16)(0x8100U + (UINT16)(y >> 3) * 0x140U + (UINT16)((y & 7U) << 1)),
			               (UINT8 *)(UINT16)(0x8100U + (UINT16)((UINT8)(y + (d << 3)) >> 3) * 0x140U + (UINT16)((y & 7U) << 1)));
	}
	else
	{
		d = (UINT8)(old_offset - show_offset);
		if((d == 0U) || (d >= 16U) || (sel != 0U)) return 0U;
		list8_plain(old_offset, 0U);
		n = (UINT8)((16U - d) << 3);
		for(y = 143U; n; n--, y--)
			vram_copy_line((UINT8 *)(UINT16)(0x8100U + (UINT16)(y >> 3) * 0x140U + (UINT16)((y & 7U) << 1)),
			               (UINT8 *)(UINT16)(0x8100U + (UINT16)((UINT8)(y - (d << 3)) >> 3) * 0x140U + (UINT16)((y & 7U) << 1)));
	}
	/* pass 0: the row under the cursor. 1: the other rows the move uncovered. */
	for(pass = 0U; pass < 2U; pass++)
	{
		for(r = 0U; r < 16U; r++)
		{
			if(sel)
			{
				if(pass == 0U) row = 15U;
				else row = (UINT8)(16U - d + r);
				if(pass && (row >= 15U)) break;
			}
			else
			{
				if(pass == 0U) row = 0U;
				else row = (UINT8)(1U + r);
				if(pass && (row >= d)) break;
			}
			idx = (UINT16)(show_offset + row);
			HW_BANK = Folder_sram_bank + (UINT8)(idx / Num_perBank);
			if(pass == 0U) color(WHITE, BLACK, SOLID);
			else color(BLACK, WHITE, SOLID);
			list8_row(&pFilename_buffer[idx % Num_perBank], (UINT8)(2U + row));
			if(pass == 0U) break;
		}
	}
	color(BLACK, WHITE, SOLID);
	list8_counter((UINT16)(show_offset + file_select));
	return 1U;
}

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
	UINT8 x_offset= 1;	/* mod: column 0 is the row's icon */
	UINT8 y_offset= 2;		
	UINT8 BANK_index;
	UINT8 BANK_num;
	UINT16 tt;
	UINT8 i;
	static UINT16 orgtt = 0xeeee;
	
	if(shift > timeout)
	{
		color(WHITE,BLACK,SOLID);	/* mod: the selected row is white on black (Bank_fun.c, Show_filename) */
		BANK_num = (show_offset+file_select)/Num_perBank;
		BANK_index = (show_offset+file_select)%Num_perBank;	
		HW_BANK = Folder_sram_bank+BANK_num;

		namelen = name_shown(&pFilename_buffer[BANK_index]);	/* mod: the name as drawn (CLEAN NAMES) */
		Max_char = 19;	/* mod: every row has 19 columns beside its icon */
		
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
