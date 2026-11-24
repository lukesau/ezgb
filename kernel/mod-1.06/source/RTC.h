
#include <gb/gb.h>
#include <gb/drawing.h>

#define _YEAR	6
#define _MONTH	5
#define _WKD	4
#define _DAY	3
#define _HOUR	2
#define _MIN	1
#define _SEC	0

#define UNBCD(x) (((x) & 0xF) + (((x) >> 4) * 10))

#define BCD(x)  ((((x)/10)<<4) + ((x)%10))	/* no trailing semicolon, safe inside expressions */
/* this firmware covers 2000-2099, the century bit stays 0 */

extern void DrawHEX(unsigned long uc);
extern void _ultoa(unsigned long value, char *string, unsigned char radix);


extern void Read_RTC(void)__banked;
extern void Set_window(void)__banked;
extern void Help_window(void)__banked;



typedef struct rtc_time_struct
{
    UINT16 ui8Year;       // 1970~2038
    UINT8 ui8Month;       // 1~12
    UINT8 ui8DayOfMonth;  // 1~31
    UINT8 ui8Week;
    UINT8 ui8Hour;        // 0~23
    UINT8 ui8Minute;      // 0~59
    UINT8 ui8Second;      // 0~59
   

}rtc_time_t;
