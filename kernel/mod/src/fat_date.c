/* File dates for the 1.04e kernel (docs/kernel-versions.md).
 *
 * 1.04e's FatFs stamps every file 2015-01-01 00:00 (_FS_NORTC in
 * kernel/stock/src/ffconf.h); 1.05e added RtcReadPage for this. The mod
 * builds 1.04e's FatFs with timestamps too, and this is the get_fattime it
 * calls and the RtcReadPage auto_backup.c asks the date from. The clock chip
 * and the FPGA's copy of it are on FW4 too, as the SET tab's TIME shows;
 * only the game clock is not, and nothing here touches that.
 *
 * 1.04e only (kernel/mod/mod.mk), bank 0.
 */

#include "types.h"

#define RTC_WIN ((volatile u8 *)0xA008)     /* page $06: s, m, h, day, weekday, month, year, BCD */

static void fpga_page(u8 page) {
    *(volatile u8 *)0x7f00 = 0xe1;
    *(volatile u8 *)0x7f10 = 0xe2;
    *(volatile u8 *)0x7f20 = 0xe3;
    *(volatile u8 *)0x7fc0 = page;
    *(volatile u8 *)0x7ff0 = 0xe4;
}

static u8 bcd(u8 v) {
    u8 t = (u8)(v >> 4);
    return (u8)((u8)(t << 3) + (u8)(t << 1) + (u8)(v & 0x0F));
}

u32 RtcReadPage(void) {
    u8 s, m, h, d, mon, y;
    u32 v;
    u8 *b = (u8 *)&v;

    fpga_page(6);
    s = bcd(RTC_WIN[0] & 0x7F);
    m = bcd(RTC_WIN[1] & 0x7F);
    h = bcd(RTC_WIN[2] & 0x3F);
    d = bcd(RTC_WIN[3] & 0x3F);
    mon = bcd(RTC_WIN[5] & 0x1F);
    y = bcd(RTC_WIN[6]);
    fpga_page(0);
    if (mon == 0 || mon > 12 || d == 0 || d > 31) {      /* the constant it replaced */
        b[0] = 0;
        b[1] = 0;
        b[2] = 0x21;
        b[3] = 0x46;
        return v;
    }
    b[0] = (u8)((u8)(m << 5) | (u8)(s >> 1));
    b[1] = (u8)((u8)(h << 3) | (u8)(m >> 3));
    b[2] = (u8)((u8)(mon << 5) | d);
    b[3] = (u8)((u8)((u8)(y + 20) << 1) | (u8)(mon >> 3));
    return v;
}

/* FatFs's name for it */
void get_fattime(void) __naked {
    __asm
	jp	_RtcReadPage
    __endasm;
}
