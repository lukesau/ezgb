
#include <gb/gb.h>
#include "ezgb_hw.h"
#include <gb/drawing.h>
#include <string.h>
#include "main.h"

#ifdef LANG_ZH
#include "ui_zh.h"
#include "zh_bg.h"		/* tracks the color() background (zh_text_row uses it to fill a row) */
#endif

/* In the zh build box() is no longer a no-op: Draw_Text goes through the single
   entry (zh_text_row, 12px APA) and box/text share the graphics canvas. The box()
   calls here (SET button background, top clear strip) draw again in zh. The
   checkbox keeps its #ifdef branch (the whole-cell grey highlight of
   zh_frame/zh_fill is zh-only; the English DKGREY style stays byte-identical). */

/* Bottom edge of the SET button box: zh glyphs are 12px (y=22..33), so the box
   runs to 34 to leave 1px above and below (21..33 put the text on the edge). The
   English build uses 8px glyphs (y=24..31) and keeps 33 - one constant, two builds. */
#ifdef LANG_ZH
#define SET_BTN_Y1	34
#else
/* mod: the 12px font's SET is three rows taller than the 8px one */
#define SET_BTN_Y1	(ui_font ? 36 : 33)
#endif

#define RTC_BANK
#include "banks.h"

#include "RTC.h"
#include "ezcfg.h"		/* mod: the settings file */
#include "list12.h"		/* mod: the 12px font */
#include "UI.h"			/* mod: DrawGB, to clear between the SET pages */



#define UNBCD(x) (((x) & 0xF) + (((x) >> 4) * 10))

#define BCD(x)  (((x/10)<<4) + (x%10));

//---------------------------------------------------------------------------------
static void mystrcat(char *dst,const char *src)
{
	char *p=dst;
	while(*p!='\0')p++;
	while(*src != '\0')*p++=*src++;
	*p='\0';
}

void _ultoa_0(unsigned long value, char *string, unsigned char radix)
{
	char tmp[33];

	unsigned long i;
	char *sp;	
	char *tp = tmp;	
	unsigned long v = value;

	char temp;
	
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

	
	if(string[1]==0)
	{
		temp = string[0];
		string[0]= '0';
		string[1]= temp;
		string[2]= 0;
	}
	
	
}
// --------------------------------------------------------------------
	
// --------------------------------------------------------------------
static void Set_RTCplus(UINT8 page)
{ 
  HW_BEGIN();
	HW_RTC_PAGE = page;
	HW_END(); 
}	

// --------------------------------------------------------------------
//OS mode	read RTC 

// --------------------------------------------------------------------
/* Key divider of the time editor: the loop is already 60Hz-synced and a key is
   handled every KEY_EDIT_DIV frames: 4 = ~67ms per step (2 = 33ms, 5 = 83ms). */
#define KEY_EDIT_DIV	4

// --------------------------------------------------------------------
/* Days in a month. year2 = 0..99 means 2000..2099, where every 4 years is a
   leap (2000 is leap, 2100 is out of range). On bad input 31 is returned so the
   caller cannot decrement from 0 and underflow. */
static UINT8 days_in_month(UINT8 year2, UINT8 month)
{
	static const UINT8 dim[13] = {0,31,28,31,30,31,30,31,31,30,31,30,31};
	if(month < 1 || month > 12) return 31;
	if(month == 2 && (year2 % 4) == 0) return 29;
	return dim[month];
}

/* Clamp the day to [1, days in that month] */
static UINT8 clamp_day(UINT8 year2, UINT8 month, UINT8 day)
{
	UINT8 last = days_in_month(year2, month);
	if(day < 1)    return 1;
	if(day > last) return last;
	return day;
}

/* Weekday: 1=Sunday .. 7=Saturday (the RTC register normally holds 1-7).
   2000-01-01 was a Saturday; computed with Sakamoto's algorithm. */
static UINT8 weekday_of(UINT8 year2, UINT8 month, UINT8 day)
{
	static const UINT8 t[12] = {0,3,2,5,0,3,5,1,4,6,2,4};
	UINT16 y = (UINT16)2000 + year2;
	UINT16 w;
	if(month < 3) y--;
	w = (UINT16)(y + y/4 - y/100 + y/400 + t[month-1] + day);
	return (UINT8)((w % 7) + 1);
}

// --------------------------------------------------------------------
void Set_window(void)__banked
{
	char datetime[7];
	char datetime_old[7];
  char edit_datetime[7];
  
	char msg[20];
	BYTE keysrepeat;	
	BYTE key_div = 0;		/* key sampling divider */
	
	BYTE XX;
	BYTE edit_mode;
	BYTE pos;
	BYTE update;
	BYTE select=0;	
	BYTE autosave;
	UINT8 resume = 0;	/* mod: page 1 was drawn to go back into the mod's rows */
	UINT8 start2 = 0;
	UINT8 r2;

	
	XX = 5;
	edit_mode=0;
	pos =0;
	update=0;


page1:		/* mod: the second page comes back here to draw the first again */
	HW_BANK = SAVE_info_sram_bank;
	hw_set_page(A000Address_SRAM);
	autosave = *((volatile UINT8 *)(FlashBase_SRAM+0x200));
	 
	HW_BANK = 0;
	hw_set_page(A000Address_TF);

	
	color(WHITE,WHITE,SOLID);
	box(15*8,0,159,7,M_FILL);//clean num
	
	color(BLACK,WHITE,SOLID);
	Draw_Text(UI_RTC_TIME, UI_LEN(UI_RTC_TIME), 0, 3);	

	color(SEL_INK, SEL_PAPER, SOLID);
	box(123,21,155,SET_BTN_Y1,M_FILL);
	//color(BLACK,WHITE,SOLID);// text colour	
	Draw_Text(UI_RTC_SET, UI_LEN(UI_RTC_SET), 16, 3);	

	color(BLACK,WHITE,SOLID);//
	Draw_Text(UI_RTC_AUTOSAVE, UI_LEN(UI_RTC_AUTOSAVE), 0, 7);	
#ifdef LANG_ZH
	/* The checkbox is drawn in APA: 8x8 outline plus a 4x4 block when checked,
	      same position as the English build. (zh_frame/zh_fill are box plus palette
	      control; the English path keeps the original box code byte for byte.) */
	zh_frame(130, 56, 138, 64);
	if (autosave == 1) zh_fill_black(132, 58, 136, 62);
#else
	box(130,56,130+8,56+8,M_NOFILL);// empty AUTO SAVE box	
	if(autosave==1){
		color(DKGREY,DKGREY,SOLID);
		box(130+2,56+2,130+6,56+6,M_FILL);
	}	
#endif
	
	/*
	color(BLACK,WHITE,SOLID);//	
	Draw_Text("GB BOY:", 7, 0, 9);			
	box(130,56+16,130+8,56+16+8,M_NOFILL);// empty is_gbboy box
	if(is_gbboy==1){
		color(DKGREY,DKGREY,SOLID);
		box(130+2,56+16+2,130+6,56+16+6,M_FILL);
	}	*/


	memset(datetime_old,0xFF,7);
	set_page1_rows();		/* mod: RTC SD BACKUP, FAST LAUNCH, GAME under them (setpage.c) */
	update = 1;			/* mod: and the 12px clock starts from a cleared line */
			
	while(1)
	{
		/* wait_vbl_done() used to be commented out here: the loop free-ran at CPU speed
		   and one key press jumped dozens of digits. Now synced to 60Hz frames. */
		wait_vbl_done();
		if(edit_mode==0)
		{
		if(update==1){
				//color(DKGREY,DKGREY,SOLID);// selected frame colour
				//color(BLACK,WHITE,SOLID);// selected frame colour
			//color(BLACK,WHITE,SOLID);// text colour
			if(select==0){
				color(SEL_INK, SEL_PAPER, SOLID);
			}
			else {
				color(BLACK,WHITE,SOLID);
			}
			box(123,21,155,SET_BTN_Y1,M_FILL);// button background
			if(edit_mode==0)			
				Draw_Text(UI_RTC_SET, UI_LEN(UI_RTC_SET), 16, 3);	
			else			
				Draw_Text(UI_RTC_SAV, UI_LEN(UI_RTC_SAV), 16, 3);
								
			//	autosave	
#ifdef LANG_ZH
			/* With the cursor on this row the whole cell turns grey (the English build uses
			   a DKGREY frame). Order: wipe white, grey if selected, black frame, block if checked. */
			zh_fill_flat(129, 55, 139, 65);
			if (select == 1) zh_fill_grey(129, 55, 139, 65);
			zh_frame(130, 56, 138, 64);
			if (autosave == 1) zh_fill_black(132, 58, 136, 62);
#else
			set_check_ring(56, (select==1) ? 1 : 0);	/* mod: the second outline under the cursor */
			color(WHITE,WHITE,SOLID);
			box(130,56,130+8,56+8,M_FILL);

			if(select==1){
				color(DKGREY,DKGREY,SOLID);// selected frame colour
			}
			else {
				color(BLACK,WHITE,SOLID);// selected frame colour
			}
			
			box(130,56,130+8,56+8,M_NOFILL);// empty
			
			if(autosave==1){
				color(DKGREY,DKGREY,SOLID);
				box(130+2,56+2,130+6,56+6,M_FILL);
			}
#endif
			
			/*
			
			color(WHITE,WHITE,SOLID);
			box(130,56+16,130+8,56+16+8,M_FILL);
					
			if(select==2){
				color(DKGREY,DKGREY,SOLID);// selected frame colour
			}
			else {
				color(BLACK,WHITE,SOLID);// not selected
			}
			
			box(130,56+16,130+8,56+16+8,M_NOFILL);// empty
			
			if(is_gbboy==1){
				color(DKGREY,DKGREY,SOLID);
				box(130+2,56+16+2,130+6,56+16+6,M_FILL);
			}*/
		}//end update ==1


			hw_set_page(A000Address_RTC);//read RTC	OS mode	
			datetime[_SEC] = *((volatile UINT8 *)(Base_RTCbuffer+8));//Seconds_re
			datetime[_MIN] = *((volatile UINT8 *)(Base_RTCbuffer+9));//Minutes_re
			datetime[_HOUR] = *((volatile UINT8 *)(Base_RTCbuffer+0xA));//Hours_re
			datetime[_DAY] = *((volatile UINT8 *)(Base_RTCbuffer+0xB));//Days_re
			datetime[_WKD] = *((volatile UINT8 *)(Base_RTCbuffer+0xC));//Weekdays_re
			datetime[_MONTH] = *((volatile UINT8 *)(Base_RTCbuffer+0xD));//Century_months_re
			datetime[_YEAR] = *((volatile UINT8 *)(Base_RTCbuffer+0xE));//Years_re					
			hw_set_page(A000Address_TF);	
	

			color(BLACK,WHITE,SOLID);//time color
#ifdef LANG_ZH
			/* 12px glyphs are narrower than the 8px console cells this layout was
			   designed for, so a field redraw can leave a stale glyph behind (the
			   "/" of "2026/" stayed when edit mode split the year and the slash).
			   Wipe the whole line whenever everything is redrawn. */
			if(update) zh_fill_flat(0, (UINT8)(XX << 3), 159, (UINT8)((XX << 3) + 11U));
#endif
			
#ifndef LANG_ZH
			if(ui_font)		/* mod: one line in the 12px font, list12.c */
			{
				if(update) clock12_reset();	/* the page was drawn again */
				clock12((const UINT8 *)datetime, 1U, 0xFFU);	/* draws the fields that changed */
			}
			else
#endif
			{
			if((datetime[_YEAR] != datetime_old[_YEAR]) || update)
			{			
				_ultoa_0(UNBCD(datetime[_YEAR])+2000,msg,10u);//Years_re
				mystrcat(msg,"/");
				Draw_Text(msg, 5, 0, XX);
			}
			if((datetime[_MONTH] != datetime_old[_MONTH]) || update)
			{			
				_ultoa_0(UNBCD(datetime[_MONTH]&0x1F),msg,10u);//Century_months_re
				Draw_Text(msg, 2, 5, XX);
				Draw_Text("/", 1, 7, XX);
			}
			if((datetime[_DAY] != datetime_old[_DAY]) || update)
			{	
				_ultoa_0(UNBCD(datetime[_DAY]&0x3F),msg,10u);//Days_re
				Draw_Text(msg, 2, 8, XX);			
			}
			if((datetime[_HOUR] != datetime_old[_HOUR]) || update)
			{	
				_ultoa_0(UNBCD(datetime[_HOUR]&0x3F),msg,10u);//Hours_re
				Draw_Text(msg, 2, 11, XX);	
				Draw_Text(":", 1, 13, XX);				
			}
			if((datetime[_MIN] != datetime_old[_MIN]) || update)
			{	
				_ultoa_0(UNBCD(datetime[_MIN]&0x7F),msg,10u);//Minutes_re
				Draw_Text(msg, 2, 14, XX);	
				Draw_Text(":", 1, 16, XX);		
			}
			if((datetime[_SEC] != datetime_old[_SEC]) || update)
			{	
				_ultoa_0(UNBCD(datetime[_SEC]&0x7F),msg,10u);//Seconds_re
				Draw_Text(msg, 2, 17, XX);	
			}
			
			}
			update=0;
			memcpy(datetime_old,datetime,7);
			if(resume)		/* mod: this page was drawn for the cursor to go back to its last row */
			{
				resume = 0;
				start2 = SET_RESUME;
				goto enter2;
			}
		}
		else {//edit mode

			
			if(update){
#ifdef LANG_ZH
				/* same reason as above: wipe the line before splitting it into
				   fixed-width fields, or the old "/" of "2026/" survives */
				zh_fill_flat(0, (UINT8)(XX << 3), 159, (UINT8)((XX << 3) + 11U));
#endif
				
				color(SEL_INK, SEL_PAPER, SOLID);
				Draw_Text(UI_RTC_SAV, UI_LEN(UI_RTC_SAV), 16, 3);
			
				color(BLACK,WHITE,SOLID);// text colour	
			
#ifndef LANG_ZH
				if(ui_font)		/* mod: one line in the 12px font, the field being set inverted */
				{
					clock12((const UINT8 *)edit_datetime, 0U, pos);
				}
				else
#endif
				{
				_ultoa_0((edit_datetime[_YEAR])+2000,msg,10u);//Years_re
#ifdef LANG_ZH
				if(pos==0)
					zh_field_inv(0, (UINT8)(XX << 3), (const UINT8 *)msg, 4U);	/* inverse video */
				else
					Draw_Text(msg, 4, 0, XX);
#else
				if(pos==0){
					color(SEL_INK, SEL_PAPER, SOLID);
				}
				Draw_Text(msg, 4, 0, XX);
#endif
				color(BLACK,WHITE,SOLID);	
				Draw_Text("/", 1, 4, XX);
		
				_ultoa_0((edit_datetime[_MONTH]),msg,10u);//Century_months_re
#ifdef LANG_ZH
				if(pos==1)
					zh_field_inv(40, (UINT8)(XX << 3), (const UINT8 *)msg, 2U);	/* inverse video */
				else
					Draw_Text(msg, 2, 5, XX);
#else
				if(pos==1){
					color(SEL_INK, SEL_PAPER, SOLID);
				}
				Draw_Text(msg, 2, 5, XX);
#endif
				color(BLACK,WHITE,SOLID);	
				
				Draw_Text("/", 1, 7, XX);


				_ultoa_0((edit_datetime[_DAY]),msg,10u);//Days_re
#ifdef LANG_ZH
				if(pos==2)
					zh_field_inv(64, (UINT8)(XX << 3), (const UINT8 *)msg, 2U);	/* inverse video */
				else
					Draw_Text(msg, 2, 8, XX);
#else
				if(pos==2){
					color(SEL_INK, SEL_PAPER, SOLID);
				}
				Draw_Text(msg, 2, 8, XX);
#endif
				color(BLACK,WHITE,SOLID);	 		

				_ultoa_0((edit_datetime[_HOUR]),msg,10u);//Hours_re
#ifdef LANG_ZH
				if(pos==3)
					zh_field_inv(88, (UINT8)(XX << 3), (const UINT8 *)msg, 2U);	/* inverse video */
				else
					Draw_Text(msg, 2, 11, XX);
#else
				if(pos==3){
					color(SEL_INK, SEL_PAPER, SOLID);
				}
				Draw_Text(msg, 2, 11, XX);
#endif
				color(BLACK,WHITE,SOLID);	
					
				Draw_Text(":", 1, 13, XX);				

				_ultoa_0((edit_datetime[_MIN]),msg,10u);//Minutes_re		
#ifdef LANG_ZH
				if(pos==4)
					zh_field_inv(112, (UINT8)(XX << 3), (const UINT8 *)msg, 2U);	/* inverse video */
				else
					Draw_Text(msg, 2, 14, XX);
#else
				if(pos==4){
					color(SEL_INK, SEL_PAPER, SOLID);
				}
				Draw_Text(msg, 2, 14, XX);
#endif
				color(BLACK,WHITE,SOLID);	
				Draw_Text(":", 1, 16, XX);		

				_ultoa_0((edit_datetime[_SEC]),msg,10u);//Seconds_re
#ifdef LANG_ZH
				if(pos==5)
					zh_field_inv(136, (UINT8)(XX << 3), (const UINT8 *)msg, 2U);	/* inverse video */
				else
					Draw_Text(msg, 2, 17, XX);
#else
				if(pos==5){
					color(SEL_INK, SEL_PAPER, SOLID);
				}
				Draw_Text(msg, 2, 17, XX);
#endif
				color(BLACK,WHITE,SOLID);
				
				}
				update=0;
			}
		}	
		
	
		/* Sample the keys every KEY_EDIT_DIV frames; other frames count as no input */
		if(++key_div >= KEY_EDIT_DIV)
		{
			key_div = 0;
			keysrepeat = joypad();
		}
		else
		{
			keysrepeat = 0;
		}

		if(keysrepeat & J_LEFT){
			if(edit_mode)
			{
				if(select==0){
					if(pos) pos--;
					else    pos=5;		/* wrap from the first item to the last */				
					update=2;
				}
			}	
			else
			{
				/* mod: LEFT is the page before, and the pages go round */
				start2 = SET_PAGE3;
				goto enter2;
			}
    }
		else if(keysrepeat &  J_RIGHT){
			if(edit_mode)
			{
				if(select==0){
					pos++;
					if(pos==6)pos=0;
					update=3;
				}
			}
			else
			{
				/* mod: RIGHT is the next page */
				start2 = SET_PAGE2;
				goto enter2;
			}
		}
		else if(keysrepeat &  J_UP){	
			if(edit_mode)
			{
				if(select==0){
					if(pos==0){//Years
						if(edit_datetime[_YEAR]==99) {edit_datetime[_YEAR]=0;} else {edit_datetime[_YEAR]++;}
						/* a new year can invalidate Feb 29: clamp immediately */
						edit_datetime[_DAY] = clamp_day(edit_datetime[_YEAR],edit_datetime[_MONTH],edit_datetime[_DAY]);
					}	
					else if(pos==1){//months
						if(edit_datetime[_MONTH]>=12) {edit_datetime[_MONTH]=1;} else {edit_datetime[_MONTH]++;}
						/* a smaller month can overflow the day (Jan 31 -> Feb): clamp immediately */
						edit_datetime[_DAY] = clamp_day(edit_datetime[_YEAR],edit_datetime[_MONTH],edit_datetime[_DAY]);
					}	
					else if(pos==2){//Days
						if(edit_datetime[_DAY] >= days_in_month(edit_datetime[_YEAR],edit_datetime[_MONTH]))
							edit_datetime[_DAY] = 1;
						else
							edit_datetime[_DAY]++;
					}	
					else if(pos==3){//Hours
						if(edit_datetime[_HOUR]==23) {edit_datetime[_HOUR]=0;} else {edit_datetime[_HOUR]++;}
					}	
					else if(pos==4){//Minutes
						if(edit_datetime[_MIN]==59) {edit_datetime[_MIN]=0;} else {edit_datetime[_MIN]++;}
					}	
					else if(pos==5){//Seconds
						if(edit_datetime[_SEC]==59) {edit_datetime[_SEC]=0;} else {edit_datetime[_SEC]++;}
					}				
					
					update=1;
				}
			}	
			else {
				if(select){
					select--;
					update=1;
				}
			}		
    }
		else if(keysrepeat &  J_DOWN){
			if(edit_mode)
			{
				if(select==0){
					if(pos==0){//Years
						if(edit_datetime[_YEAR]==0) {edit_datetime[_YEAR]=99;} else {edit_datetime[_YEAR]--;}
						edit_datetime[_DAY] = clamp_day(edit_datetime[_YEAR],edit_datetime[_MONTH],edit_datetime[_DAY]);
					}	
					else if(pos==1){//months
						if(edit_datetime[_MONTH]<=1) {edit_datetime[_MONTH]=12;} else {edit_datetime[_MONTH]--;}
						edit_datetime[_DAY] = clamp_day(edit_datetime[_YEAR],edit_datetime[_MONTH],edit_datetime[_DAY]);
					}	
					else if(pos==2){//Days
						if(edit_datetime[_DAY] <= 1)
							edit_datetime[_DAY] = days_in_month(edit_datetime[_YEAR],edit_datetime[_MONTH]);
						else
							edit_datetime[_DAY]--;
					}	
					else if(pos==3){//Hours
						if(edit_datetime[_HOUR]==0) {edit_datetime[_HOUR]=23;} else {edit_datetime[_HOUR]--;}
					}	
					else if(pos==4){//Minutes
						if(edit_datetime[_MIN]==0) {edit_datetime[_MIN]=59;} else {edit_datetime[_MIN]--;}
					}	
					else if(pos==5){//Seconds
						if(edit_datetime[_SEC]==0) {edit_datetime[_SEC]=59;} else {edit_datetime[_SEC]--;}
					}				
					
					update=1;
				}
			}	
			else {
					if(select < 1){
						select++;		
						update=1;
					}
					else {
						/* mod: DOWN from AUTO SAVE is the mod's rows (setpage.c) */
						start2 = 0;
enter2:
						/* AUTO SAVE without the cursor, while it is below */
						set_check_ring(56, 0);
						color(WHITE,WHITE,SOLID);
						box(130,56,130+8,56+8,M_FILL);
						color(BLACK,WHITE,SOLID);
						box(130,56,130+8,56+8,M_NOFILL);
						if(autosave==1){
							color(DKGREY,DKGREY,SOLID);
							box(130+2,56+2,130+6,56+6,M_FILL);
						}
						color(BLACK,WHITE,SOLID);
						r2 = set_page2(start2);
						if(r2 == 1) return;
						if(r2 == 4)		/* START in the mod's rows: back to the SD tab */
						{
							tab_to_sd = 1;
							return;
						}
						if(r2 == 2)
						{
							/* back from page 2: this page again, then its last row */
							DrawGB(1);
							resume = 1;
							select = 1;
							goto page1;
						}
						if(r2 == 3)
						{
							/* LEFT or RIGHT came round to this page: its first row */
							DrawGB(1);
							select = 0;
							goto page1;
						}
						update=1;
					}
			}
    }
		else if(keysrepeat &  J_SELECT){
			return;
		}
		/* mod: START goes back to the SD tab, where SELECT goes on to HELP.
		   It is let go first: on the SD tab START is the recent list. */
		else if((keysrepeat & J_START) && !edit_mode){
			while(joypad() & J_START) wait_vbl_done();
			tab_to_sd = 1;
			return;
		}
		else if(keysrepeat &  J_B){
		}
		
		else if(keysrepeat &  J_A){
			if(select==0){
				color(SEL_INK, SEL_PAPER, SOLID);
				box(123,21,155,SET_BTN_Y1,M_FILL);	// 
				color(BLACK,WHITE,SOLID);// text colour	
				if(edit_mode == 0){
					edit_mode=1;
					update=1;
					pos = 0;
					edit_datetime[_YEAR] = UNBCD(datetime[_YEAR]);
					edit_datetime[_MONTH] = UNBCD(datetime[_MONTH]&0x1F);				
					edit_datetime[_DAY] = UNBCD(datetime[_DAY]&0x3F);	
					edit_datetime[_HOUR] = UNBCD(datetime[_HOUR]&0x3F);
					edit_datetime[_MIN] = UNBCD(datetime[_MIN]&0x7F);							
					edit_datetime[_SEC] = UNBCD(datetime[_SEC]&0x7F);		
			
				}
				else{ 
					edit_mode=0;
					update=1;
					
					/* Single validation point before writing back: every edit path is clamped here */
					if(edit_datetime[_MONTH] < 1 || edit_datetime[_MONTH] > 12) edit_datetime[_MONTH] = 1;
					edit_datetime[_DAY]  = clamp_day(edit_datetime[_YEAR],edit_datetime[_MONTH],edit_datetime[_DAY]);
					if(edit_datetime[_HOUR] > 23) edit_datetime[_HOUR] = 0;
					if(edit_datetime[_MIN]  > 59) edit_datetime[_MIN]  = 0;
					if(edit_datetime[_SEC]  > 59) edit_datetime[_SEC]  = 0;
					
					//send time
					hw_set_page(A000Address_RTC);
					*((volatile UINT8 *)(Base_RTCbuffer+8))=BCD(edit_datetime[_SEC]);//Seconds_re

					*((volatile UINT8 *)(Base_RTCbuffer+9))=BCD(edit_datetime[_MIN]);//Minutes_re
				
					*((volatile UINT8 *)(Base_RTCbuffer+0xA))=BCD(edit_datetime[_HOUR]);//Hours_re

					*((volatile UINT8 *)(Base_RTCbuffer+0xB))=BCD(edit_datetime[_DAY]);//Days_re
					
					*((volatile UINT8 *)(Base_RTCbuffer+0xC))=weekday_of(edit_datetime[_YEAR],edit_datetime[_MONTH],edit_datetime[_DAY]);//Weekdays_re
					
					*((volatile UINT8 *)(Base_RTCbuffer+0xD))=BCD(edit_datetime[_MONTH]);//Century_months_re
					
					*((volatile UINT8 *)(Base_RTCbuffer+0xE))=BCD(edit_datetime[_YEAR]);//Years_re
					
					
					Set_RTCplus(01);	
					hw_set_page(A000Address_TF);	
					cfg_timeset((const UINT8 *)edit_datetime);	/* mod: the new time to /EZGB.CFG */
				}
			}
			else/* if(select==1)*/ {//select==1
				// toggle the checkbox
				if(autosave==0)
					autosave=1;
				else{
					autosave=0;
				}
				update=1;
				
				//set save info
				HW_BANK = SAVE_info_sram_bank;
				hw_set_page(A000Address_SRAM);
				*((volatile UINT8 *)(FlashBase_SRAM+0x200)) = autosave;			
		
				HW_BANK = 0;
				hw_set_page(A000Address_TF);
				cfg_autosave_set(autosave);		/* mod: a copy in /EZGB.CFG */
			
			}
			/*else {//select==2
				// toggle the checkbox
				if(is_gbboy==0)
					is_gbboy=1;
				else{
					is_gbboy=0;
				}
				update=1;
				
				//set save info
				HW_BANK = SAVE_info_sram_bank;
				hw_set_page(A000Address_SRAM);
				*((volatile UINT8 *)(FlashBase_SRAM+0x203)) = is_gbboy;			
		
				HW_BANK = 0;
				hw_set_page(A000Address_TF);
				
				
			}*/


		}
		
	}
	
}
// --------------------------------------------------------------------
