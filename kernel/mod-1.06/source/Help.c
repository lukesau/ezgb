
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
/* mod: the three lines are on rows 3, 4 and 5; in the 12px font, which is
   taller than a row, on 3, 5 and 7 */
#ifdef LANG_ZH
#define HELP_ROW(r)	(r)
#else
#include "list12.h"
#define HELP_ROW(r)	(ui_font ? (UINT8)(2U * (r) - 3U) : (r))
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
	Draw_Text(s, UI_LEN(UI_HELP_FWVER), 5, 3);	/* the length comes from the macro, no hand-written 11 */
	
	Draw_Text(UI_HELP_VER, UI_LEN(UI_HELP_VER), 0, 3);
	/* mod: the mod's version, from the VERSION file (build/mod_version.h) */
	Draw_Text(UI_HELP_MOD, UI_LEN(UI_HELP_MOD), 0, HELP_ROW(4));

	
	Draw_Text(UI_HELP_SITE, UI_LEN(UI_HELP_SITE), 0, HELP_ROW(5));

	/* mod: once the firmware mod's SD recovery has dropped the card clock
	   to half speed it reports weekday 7 in the RTC window, a value the
	   clock chip never holds (stage0/docs/sd-recovery.md). On stock
	   firmware, and at full speed, nothing is shown. */
	hw_set_page(A000Address_RTC);
	i = *((volatile UINT8 *)(Base_RTCbuffer + 0xC)) & 0x07U;
	hw_set_page(A000Address_TF);
	if(i == 7U) Draw_Text("SD SPEED: HALF", 14, 0, HELP_ROW(6));
	
	
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