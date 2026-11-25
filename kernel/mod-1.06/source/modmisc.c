/* ============================================================================
   modmisc.c  -  mod: small routines moved out of bank 0
   ----------------------------------------------------------------------------
   get_fattime (from diskio.c) and _ultoa (from main.c), as they were but
   for __banked: bank 0 is where everything every bank calls has to be, and
   it is full. Neither is called often enough for the bank switch to show.
   ========================================================================== */

#include <gb/gb.h>
#include <string.h>

#include "ezgb_hw.h"
#include "main.h"
#include "ff.h"
#include "RTC.h"

#include "modbank.h"

DWORD get_fattime (void) __banked
{
		UINT8 datetime[7];
		hw_set_page(A000Address_RTC);//read RTC	OS mode	
		datetime[_SEC] = *((volatile UINT8 *)(Base_RTCbuffer+8));//Seconds_re
		datetime[_MIN] = *((volatile UINT8 *)(Base_RTCbuffer+9));//Minutes_re
		datetime[_HOUR] = *((volatile UINT8 *)(Base_RTCbuffer+0xA));//Hours_re
		datetime[_DAY] = *((volatile UINT8 *)(Base_RTCbuffer+0xB));//Days_re
		datetime[_WKD] = *((volatile UINT8 *)(Base_RTCbuffer+0xC));//Weekdays_re
		datetime[_MONTH] = *((volatile UINT8 *)(Base_RTCbuffer+0xD));//Century_months_re
		datetime[_YEAR] = *((volatile UINT8 *)(Base_RTCbuffer+0xE));//Years_re					
		hw_set_page(A000Address_TF);		
		/* Mask the high bits first, as RTC.c does when displaying the time:
		        sec  bit7 = CH (clock halt); 0x80 becomes 80 via UNBCD and 80>>1 = 40 > 29
		        min  normally 0-59; a bad value <<5 overflows into the hour field
		        month bit7 = century; 0x91 becomes 91 via UNBCD and <<21 overflows the year
		   Without the mask, new/updated save files get wrong timestamps (no data loss,
		   but time-ordered listings look wrong). */
		return ((DWORD)(UNBCD(datetime[_YEAR]  & 0x7F)+20) << 25
		      | (DWORD)UNBCD(datetime[_MONTH] & 0x1F) << 21
		      | (DWORD)UNBCD(datetime[_DAY]   & 0x3F) << 16
		      | (DWORD)UNBCD(datetime[_HOUR]  & 0x3F) << 11
		      | (DWORD)UNBCD(datetime[_MIN]   & 0x7F) <<  5
		      | (DWORD)(UNBCD(datetime[_SEC]  & 0x7F) >> 1));
}

void _ultoa(unsigned long value, char *string, unsigned char radix) __banked
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
