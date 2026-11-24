
#include <gb/gb.h>
#include "ezgb_hw.h"
#include <gb/drawing.h>
#include <string.h>
#include "main.h"


#define HELP_BANK
#include "banks.h"

#include "Help.h"


extern void _ultoa(unsigned long value, char *string, unsigned char radix);
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

	
	Draw_Text(UI_HELP_SITE, UI_LEN(UI_HELP_SITE), 0, 5);
	
	
	while(1)
	{
		wait_vbl_done();
		keysrepeat = joypad();
		/* Firmware update used to hook in here on A; that path (and
		   Check_FW_update) was never finished, so only SELECT leaves this page. */
		if(keysrepeat &  J_SELECT){
			return;
		}
	}
}