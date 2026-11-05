/* File dates for the 1.04e kernel (docs/kernel-versions.md).
 *
 * 1.04e's FatFs stamps every file 2015-01-01 00:00: five sites, in banks 3, 6
 * and 9, store the constant bytes through de. 1.05e added RtcReadPage for this.
 * Here the five sites call FatStamp, and the mod's code that asks for the date
 * (auto_backup.c) gets RtcReadPage from the table below. The clock chip and the
 * FPGA's copy of it are on FW4 too, as the SET tab's TIME shows; only the game
 * clock is not, and nothing here touches that.
 *
 * 1.04e only: bank 0, 00:3db0, in the room browser_nav.c left. Not in REGISTRY:
 * port-mod.py builds it into the 1.04e port (TARGET_BLOCKS, TARGET_SITES), since
 * 0731, the development base, has the real thing. A jump table first, so the
 * five sites and the RtcReadPage pin keep their targets:
 *
 *   00:3db0  RtcReadPage   u32 get_fattime, date in the high word
 *   00:3db3  FatStamp      de = where the four bytes go; all registers free
 */

#include "types.h"

#define RTC_WIN ((volatile u8 *)0xA008)     /* page $06: s, m, h, day, weekday, month, year, BCD */

void FatDate(void) __naked {
    __asm
	jp	_RtcRead
	jp	_FatStamp
    __endasm;
}

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

u32 RtcRead(void) {
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

void FatStamp(void) __naked {
    __asm
	push	de
	call	_RtcRead
	pop	bc
	ld	a, e
	ld	(bc), a
	inc	bc
	ld	a, d
	ld	(bc), a
	inc	bc
	ld	a, l
	ld	(bc), a
	inc	bc
	ld	a, h
	ld	(bc), a
	ret
    __endasm;
}
