
#include <gb/gb.h>
#include "ezgb_hw.h"
#include <gb/drawing.h>
#include <string.h>
#include "main.h"


#define HELP_BANK
#include "banks.h"

#include "Help.h"
UINT8 pad_take(void);	/* mod: sgb.s */


extern void _ultoa(unsigned long value, char *string, unsigned char radix) __banked;
extern UINT8 SD_buffer[0x200];

// --------------------------------------------------------------------
UINT8 ramfun_Get_FPGA_ver(void)
{	
	UINT8 Read_SPI;
	/*	
	HW_BEGIN();
	HW_SPI_WRITE_EN = 0x01;
	HW_END(); */
	
	Read_SPI =  HW_WINDOW_REG;
	/*
	HW_BEGIN();
	HW_SPI_WRITE_EN = 0x00;
	HW_END();*/
	
	return Read_SPI;	
}
// --------------------------------------------------------------------
	




// --------------------------------------------------------------------
/* mod: the tab is laid out as the 0918 mod's (kernel/mod/base/src/bank8.c,
   kernel/mod/src/help12.c). The 8px font: the versions on row 3, the site
   on 5, the mod on 7, where it is from on 9 and 10, the SD speed on 12.
   The 12px fonts: the same lines from x 4 at pixel rows 24, 44, 64, 84, 96
   and 116, with no "ver:" label. The Chinese build keeps its rows. */
#ifdef LANG_ZH
#define HELP_MOD	4
#define HELP_SITE	5
#define HELP_SD		6
#define HELP_GIT	7
#else
#include "list12.h"
#include "font12.h"
#define HELP_MOD	7
#define HELP_SITE	5
#define HELP_SD		12
#define HELP_GIT	9

/* a line of the 12px tab; the text may be a literal of this bank, so it
   goes over on the stack */
static void help12(const char *t, UINT8 y)
{
	UINT8 b[21];
	UINT8 i;

	for(i = 0U; (i < 20U) && t[i]; i++) b[i] = (UINT8)t[i];
	b[i] = 0U;
	font12_draw(b, 4U, y, F12_NORMAL);
}
#endif

void Help_window(void)__banked
{
	UINT8 i,j;
	UINT8 cc;
	UINT8 xx;
	UINT8 yy;
		BYTE keysrepeat;	
	char msg[20];
	char s[20]=UI_HELP_FWVER;			/* the version string lives in ui_text.h */
	
	
	UINT8 Current_FW_ver;	
	UINT8 Built_in_ver = 15;		/* built-in FPGA/kernel version shown on the help page */

			
	xx=160-72;
	yy=144-72;
	
	hw_set_page(A000Address_read_FPGA_ver);//	
	Current_FW_ver = ramfun_Get_FPGA_ver();
	hw_set_page(A000Address_TF);//	
	
	_ultoa(Current_FW_ver,msg,10u);
			
	s[2]	= msg[0];
	if(msg[1] !=0)
		s[3]	= msg[1];
	
	/* Clear strip at the top right (safe in zh too: Draw_Text uses the 12px APA
	   APA entry point and box no longer disturbs the console font) */
	color(WHITE,WHITE,SOLID);
	box(15*8,0,159,7,M_FILL);
	color(BLACK,WHITE,SOLID);

	/* mod: once the firmware mod's SD recovery has dropped the card clock
	   to half speed it reports weekday 7 in the RTC window, a value the
	   clock chip never holds (stage0/docs/sd-recovery.md). On stock
	   firmware, and at full speed, nothing is shown. */
	hw_set_page(A000Address_RTC);
	i = *((volatile UINT8 *)(Base_RTCbuffer + 0xC)) & 0x07U;
	hw_set_page(A000Address_TF);

#ifndef LANG_ZH
	if(ui_font)
	{
		/* "FW5 K1.06e": one blank between the two, whatever the digits */
		j = (s[3] == ' ') ? 3U : 4U;
		msg[0] = s[0]; msg[1] = s[1]; msg[2] = s[2]; msg[3] = s[3];
		msg[j] = ' ';
		for(cc = 5U; s[cc]; cc++) msg[(UINT8)(j + cc - 4U)] = s[cc];
		msg[(UINT8)(j + cc - 4U)] = 0;
		help12(msg, 24U);
		help12(UI_HELP_SITE, 44U);
		help12(UI_HELP_MOD, 64U);
		help12("github.com/lukesau/", 84U);
		help12("ezgb", 96U);		/* nothing under the first row's g */
		if(i == 7U) help12("SD SPEED: HALF", 116U);
	}
	else
#endif
	{
	Draw_Text(s, UI_LEN(UI_HELP_FWVER), 5, 3);	/* the length comes from the macro, no hand-written 11 */
	Draw_Text(UI_HELP_VER, UI_LEN(UI_HELP_VER), 0, 3);
	Draw_Text(UI_HELP_SITE, UI_LEN(UI_HELP_SITE), 0, HELP_SITE);
	/* mod: the mod's version, from the VERSION file (build/mod_version.h) */
	Draw_Text(UI_HELP_MOD, UI_LEN(UI_HELP_MOD), 0, HELP_MOD);
	/* mod: where the mod is from, as the 0918 mod's HELP tab has it */
	Draw_Text("github.com/lukesau/", 19, 0, HELP_GIT);
	Draw_Text("ezgb", 4, 0, HELP_GIT + 1);
	if(i == 7U) Draw_Text("SD SPEED: HALF", 14, 0, HELP_SD);
	}

	while(1)
	{
		wait_vbl_done();
		keysrepeat = pad_take();	/* mod: once a press, so a held SELECT does not go on round the tabs */
		/* Firmware update used to hook in here on A; that path (and
		   Check_FW_update) was never finished, so only SELECT leaves this page. */
		if(keysrepeat &  J_SELECT){
			return;
		}
		/* mod: START leaves too, as on the SET tab. Both go to the SD tab
		   from here; START is let go first, since there it is the recent
		   list. */
		if(keysrepeat & J_START){
			while(joypad() & J_START) wait_vbl_done();
			return;
		}
	}
}