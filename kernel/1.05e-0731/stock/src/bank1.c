/* The kernel's C in bank 1, from $4000. Function names are kernel.sym's;
   built like src/kernel.c (GBDK 2.96a headers, BYTE_IS_UNSIGNED). */

#include <gb/gb.h>
#include <gb/drawing.h>
#include <string.h>
#include "ff.h"

/* the browser's entry table: 255-byte entries in pSRAM, 32 to a page */
typedef struct {
	char name[254];
	UINT8 attr;		/* AM_DIR or AM_ARC */
} ENTRY;

extern ENTRY *wEntries;			/* $C2A0 */
extern UINT16 wEntryCount;		/* $C2A2 */

extern char wPath[];			/* $C2A6: the browser's directory */
extern char wLabelBuf[];		/* $C4A4: the selected name */
extern UINT8 wSaveBuf[];		/* $C0A0: a 512-byte sector buffer; after a .sav's
					   48-byte RTC footer is read in, the game's MBC3
					   clock registers, one per 4 bytes */
extern char wTmp[];			/* $C3A5: save path */
extern FIL wFil;			/* $CA0F */
extern FATFS wFatFs;			/* $C7A9 */
extern UINT8 wD3EB, wD3EC, wD3ED, wD3EE, wD3EF, wD3F0, wD3F1;
extern UINT8 wD3F6;			/* $77: the save has an RTC footer */	/* launch settings: wD3EB/wD3ED save type,
						   wD3EF battery, wD3F0 RTC, wD3F1 rumble */
extern UINT16 wRomBanks;		/* $C2A4: the ROM's size in 16 KB banks */
extern UINT8 wHdrSum;			/* $C5A3: the header checksum, worked out */
extern UINT32 wD3F2;			/* $D3F2: the time a .sav's clock was saved */

/* bank 0 */
FRESULT fs_open (FIL* fp, const TCHAR* path, BYTE mode);
FRESULT fs_read (FIL* fp, void* buff, UINT btr, UINT* br);
FRESULT fs_write (FIL* fp, const void* buff, UINT btw, UINT* bw);
FRESULT fs_lseek (FIL* fp, DWORD ofs);
FRESULT fs_close (FIL* fp);
DWORD fs_clust2sect (FATFS* fs, DWORD clst);
DWORD fs_get_fat (FATFS* fs, DWORD clst);
void memset (void *dst, UINT8 c, UINT16 n);	/* Memset, 00:2ca5 */
void DrawString (char *s, UINT8 len, UINT8 x, UINT8 y);
void U32ToAscii_B0 (UINT32 v, char *buf, UINT8 radix);

/* 01:4000 */
void CStrCat_B1 (char *dst, const char *src) __banked
{
	char *d = dst;

	while (*d)
		d++;
	while (*src)
		*d++ = *src++;
	*d = 0;
}

/* 01:4048 */
int CStrCmp (const char *a, const char *b) __banked
{
	while (*a == *b) {
		if (!*a)
			return 0;
		a++;
		b++;
	}
	return *a - *b;
}

/* 01:40a3: the last c in s, or 0 */
char *CStrChr (char *s, char c) __banked
{
	char *last = 0;

	if (!s)
		return 0;
	for (; *s; s++)
		if (*s == c)
			last = s;
	return last;
}

/* 01:40e3: up to 16 rows of entries from top, row highlighted, and the
   1-based position of the selected one */
void DrawBrowserEntries (UINT16 top, UINT16 row) __banked
{
	UINT16 n;
	UINT8 i, slot, page;
	char buf[20];

	if (top >= wEntryCount)
		n = 0;
	else {
		n = wEntryCount - top;
		if (n > 16)
			n = 16;
	}
	color(3, 0, 0);
	for (i = 0; i < n; i++) {
		if (i == row)
			color(3, 2, 0);
		page = (top + i) / 32;
		slot = (top + i) % 32;
		*(UINT8 *)0x4000 = page + 0x12;
		if (wEntries[slot].attr == AM_DIR) {
			DrawString(wEntries[slot].name, 0, 0, i + 2);
			color(0, 3, 0);
			DrawString("DIR", 3, 17, i + 2);
		} else
			DrawString(wEntries[slot].name, 20, 0, i + 2);
		color(3, 0, 0);
	}
	U32ToAscii_B0(top + row + 1, buf, 10);
	DrawString(buf, 4, 16, 0);
}

/* 01:42ba: redraw rows row-1 and row (code 2, moved up) or row and row+1
   (code 3, moved down) with the highlight on the new one */
void DrawBrowserDetail (UINT16 top, UINT16 row, UINT8 code) __banked
{
	UINT16 y0, y1;
	UINT8 slot, page;
	char buf[20];
	UINT8 r0, r1;

	if (code == 2) {
		r0 = row - 1;
		r1 = row;
		y0 = (UINT16)(row - 1) + 2;
		y1 = row + 2;
	} else {
		r0 = row;
		r1 = row + 1;
		y0 = row + 2;
		y1 = (UINT16)(row + 1) + 2;
	}
	page = (top + r0) / 32;
	slot = (top + r0) % 32;
	*(UINT8 *)0x4000 = page + 0x12;
	if (code == 3)
		color(3, 2, 0);
	else if (code == 2)
		color(3, 0, 0);
	if (wEntries[slot].attr == AM_DIR) {
		DrawString(wEntries[slot].name, 0, 0, y0);
		color(0, 3, 0);
		DrawString("DIR", 3, 17, y0);
	} else
		DrawString(wEntries[slot].name, 20, 0, y0);
	if (code == 3)
		color(3, 0, 0);
	else if (code == 2)
		color(3, 2, 0);
	page = (top + r1) / 32;
	slot = (top + r1) % 32;
	*(UINT8 *)0x4000 = page + 0x12;
	if (wEntries[slot].attr == AM_DIR) {
		DrawString(wEntries[slot].name, 0, 0, y1);
		color(0, 3, 0);
		DrawString("DIR", 3, 17, y1);
	} else
		DrawString(wEntries[slot].name, 20, 0, y1);
	color(3, 0, 0);
	U32ToAscii_B0(top + row + 1, buf, 10);
	DrawString(buf, 4, 16, 0);
}

/* 01:45b3: FatFs's ff_wtoupper as ffunicode.c has it from R0.12 on (this is
   R0.15's, tables included), banked. Nothing calls it. kernel.sym has it as
   FormatFileSize. FatFs code, (C) ChaN, under the FatFs license (src/ff.h). */
DWORD WToUpper_B1 (DWORD uni) __banked
{
	const WORD* p;
	WORD uc, bc, nc, cmd;
	static const WORD cvt1[] = {	/* Compressed up conversion table for U+0000 - U+0FFF */
		/* Basic Latin */
		0x0061,0x031A,
		/* Latin-1 Supplement */
		0x00E0,0x0317,
		0x00F8,0x0307,
		0x00FF,0x0001,0x0178,
		/* Latin Extended-A */
		0x0100,0x0130,
		0x0132,0x0106,
		0x0139,0x0110,
		0x014A,0x012E,
		0x0179,0x0106,
		/* Latin Extended-B */
		0x0180,0x004D,0x0243,0x0181,0x0182,0x0182,0x0184,0x0184,0x0186,0x0187,0x0187,0x0189,0x018A,0x018B,0x018B,0x018D,0x018E,0x018F,0x0190,0x0191,0x0191,0x0193,0x0194,0x01F6,0x0196,0x0197,0x0198,0x0198,0x023D,0x019B,0x019C,0x019D,0x0220,0x019F,0x01A0,0x01A0,0x01A2,0x01A2,0x01A4,0x01A4,0x01A6,0x01A7,0x01A7,0x01A9,0x01AA,0x01AB,0x01AC,0x01AC,0x01AE,0x01AF,0x01AF,0x01B1,0x01B2,0x01B3,0x01B3,0x01B5,0x01B5,0x01B7,0x01B8,0x01B8,0x01BA,0x01BB,0x01BC,0x01BC,0x01BE,0x01F7,0x01C0,0x01C1,0x01C2,0x01C3,0x01C4,0x01C5,0x01C4,0x01C7,0x01C8,0x01C7,0x01CA,0x01CB,0x01CA,
		0x01CD,0x0110,
		0x01DD,0x0001,0x018E,
		0x01DE,0x0112,
		0x01F3,0x0003,0x01F1,0x01F4,0x01F4,
		0x01F8,0x0128,
		0x0222,0x0112,
		0x023A,0x0009,0x2C65,0x023B,0x023B,0x023D,0x2C66,0x023F,0x0240,0x0241,0x0241,
		0x0246,0x010A,
		/* IPA Extensions */
		0x0253,0x0040,0x0181,0x0186,0x0255,0x0189,0x018A,0x0258,0x018F,0x025A,0x0190,0x025C,0x025D,0x025E,0x025F,0x0193,0x0261,0x0262,0x0194,0x0264,0x0265,0x0266,0x0267,0x0197,0x0196,0x026A,0x2C62,0x026C,0x026D,0x026E,0x019C,0x0270,0x0271,0x019D,0x0273,0x0274,0x019F,0x0276,0x0277,0x0278,0x0279,0x027A,0x027B,0x027C,0x2C64,0x027E,0x027F,0x01A6,0x0281,0x0282,0x01A9,0x0284,0x0285,0x0286,0x0287,0x01AE,0x0244,0x01B1,0x01B2,0x0245,0x028D,0x028E,0x028F,0x0290,0x0291,0x01B7,
		/* Greek, Coptic */
		0x037B,0x0003,0x03FD,0x03FE,0x03FF,
		0x03AC,0x0004,0x0386,0x0388,0x0389,0x038A,
		0x03B1,0x0311,
		0x03C2,0x0002,0x03A3,0x03A3,
		0x03C4,0x0308,
		0x03CC,0x0003,0x038C,0x038E,0x038F,
		0x03D8,0x0118,
		0x03F2,0x000A,0x03F9,0x03F3,0x03F4,0x03F5,0x03F6,0x03F7,0x03F7,0x03F9,0x03FA,0x03FA,
		/* Cyrillic */
		0x0430,0x0320,
		0x0450,0x0710,
		0x0460,0x0122,
		0x048A,0x0136,
		0x04C1,0x010E,
		0x04CF,0x0001,0x04C0,
		0x04D0,0x0144,
		/* Armenian */
		0x0561,0x0426,

		0x0000	/* EOT */
	};
	static const WORD cvt2[] = {	/* Compressed up conversion table for U+1000 - U+FFFF */
		/* Phonetic Extensions */
		0x1D7D,0x0001,0x2C63,
		/* Latin Extended Additional */
		0x1E00,0x0196,
		0x1EA0,0x015A,
		/* Greek Extended */
		0x1F00,0x0608,
		0x1F10,0x0606,
		0x1F20,0x0608,
		0x1F30,0x0608,
		0x1F40,0x0606,
		0x1F51,0x0007,0x1F59,0x1F52,0x1F5B,0x1F54,0x1F5D,0x1F56,0x1F5F,
		0x1F60,0x0608,
		0x1F70,0x000E,0x1FBA,0x1FBB,0x1FC8,0x1FC9,0x1FCA,0x1FCB,0x1FDA,0x1FDB,0x1FF8,0x1FF9,0x1FEA,0x1FEB,0x1FFA,0x1FFB,
		0x1F80,0x0608,
		0x1F90,0x0608,
		0x1FA0,0x0608,
		0x1FB0,0x0004,0x1FB8,0x1FB9,0x1FB2,0x1FBC,
		0x1FCC,0x0001,0x1FC3,
		0x1FD0,0x0602,
		0x1FE0,0x0602,
		0x1FE5,0x0001,0x1FEC,
		0x1FF3,0x0001,0x1FFC,
		/* Letterlike Symbols */
		0x214E,0x0001,0x2132,
		/* Number forms */
		0x2170,0x0210,
		0x2184,0x0001,0x2183,
		/* Enclosed Alphanumerics */
		0x24D0,0x051A,
		0x2C30,0x042F,
		/* Latin Extended-C */
		0x2C60,0x0102,
		0x2C67,0x0106, 0x2C75,0x0102,
		/* Coptic */
		0x2C80,0x0164,
		/* Georgian Supplement */
		0x2D00,0x0826,
		/* Full-width */
		0xFF41,0x031A,

		0x0000	/* EOT */
	};


	if (uni < 0x10000) {	/* Is it in BMP? */
		uc = (WORD)uni;
		p = uc < 0x1000 ? cvt1 : cvt2;
		for (;;) {
			bc = *p++;								/* Get the block base */
			if (bc == 0 || uc < bc) break;			/* Not matched? */
			nc = *p++; cmd = nc >> 8; nc &= 0xFF;	/* Get processing command and block size */
			if (uc < bc + nc) {	/* In the block? */
				switch (cmd) {
				case 0:	uc = p[uc - bc]; break;		/* Table conversion */
				case 1:	uc -= (uc - bc) & 1; break;	/* Case pairs */
				case 2: uc -= 16; break;			/* Shift -16 */
				case 3:	uc -= 32; break;			/* Shift -32 */
				case 4:	uc -= 48; break;			/* Shift -48 */
				case 5:	uc -= 26; break;			/* Shift -26 */
				case 6:	uc += 8; break;				/* Shift +8 */
				case 7: uc -= 80; break;			/* Shift -80 */
				case 8:	uc -= 0x1C60; break;		/* Shift -0x1C60 */
				}
				break;
			}
			if (cmd == 0) p += nc;	/* Skip table if needed */
		}
		uni = uc;
	}

	return uni;
}


/* FPGA registers: $7F00/$7F10/$7F20 unlock, $7FF0 commits */

/* 01:47a7 */
void SetFpgaPage_B1 (UINT8 page)
{
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7fc0 = page;
	*(UINT8 *)0x7ff0 = 0xe4;
}

/* 01:47c7: v's low byte to $7F34, high byte to $7F35. Nothing calls it. */
void SetFpga7F34_35_B1 (UINT16 v)
{
	UINT8 *p;

	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	p = (UINT8 *)0x7f34;
	*p = v & 0xff;
	p = (UINT8 *)0x7f35;
	*p = (v & 0xff00) >> 8;
	*(UINT8 *)0x7ff0 = 0xe4;
}

/* 01:480b */
void SetFpga7FD4_B1 (UINT8 v) __banked
{
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7fd4 = v;
	*(UINT8 *)0x7ff0 = 0xe4;
}

/* 01:482b: append the selected name to the directory path, and keep a copy
   of the path in pSRAM page $11 at $A300 for the last-ROM menu */
void LoaderPrepPath (void) __banked
{
	UINT16 i;
	UINT8 *p;
	UINT8 r;
	r = CStrCmp(wPath, "/");
	if (r)
		CStrCat_B1(wPath, "/");
	CStrCat_B1(wPath, wLabelBuf);
	*(UINT8 *)0x4000 = 0x11;
	SetFpgaPage_B1(3);
	for (i = 0; i < 255; i++)
		{
		p = (UINT8 *)(0xa300 + i);
		*p = wPath[i];
	}
	*(UINT8 *)0x4000 = 0;
	SetFpgaPage_B1(0);
}

/* the date code: the cart RTC as a calendar date (year in full) */
typedef struct {
	UINT16 year;
	UINT8 month, day, weekday, hour, min, sec;
} RTCTIME;

UINT8 wDaysInMonth[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};	/* $D6A7 */
UINT8 wDaysInMonthLeap[12] = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};	/* $D6B3 */
UINT16 wDaysInYearTab[4] = {365, 365, 365, 366};				/* $D6BF */

/* 01:48c6 */
UINT8 IsLeapYear (UINT16 year)
{
	UINT8 leap = 0;

	if (year % 4 == 0) {
		if (year % 100 == 0 && year % 400 != 0)
			leap = 0;
		else
			leap = 1;
	}
	return leap;
}

/* 01:4917: seconds from 1970 to t, less eight hours (t is UTC+8).
   kernel.sym's name says days. */
UINT32 DateToDaysSince1970 (RTCTIME *t)
{
	UINT32 days = 0;
	UINT32 secs;
	UINT16 y;
	UINT16 m;
	UINT32 h;

	for (y = 1970; y < t->year; y++)
		if (IsLeapYear(y))
			days += 366;
		else
			days += 365;
	for (m = 0; m < t->month - 1; m++)
		if (IsLeapYear(t->year))
			days += wDaysInMonthLeap[m];
		else
			days += wDaysInMonth[m];
	days += t->day - 1;
	secs = days * 24;
	secs = secs * 60;
	secs = secs * 60;
	h = t->hour * 60;
	h = h * 60;
	secs += h;
	secs += t->min * 60;
	secs += t->sec;
	secs -= 28800;
	return secs;
}

#ifdef K0918
void DrawU32Decimal (UINT32 v);
void WaitJoypadSelect (void);

/* 01:4c5e, 0918 only: an RTC test screen nothing calls. It reads the clock
   like RtcToDayCount, prints 12345678 and the date and time, and waits for
   SELECT. */
void RtcDebugDump (void)
{
	RTCTIME t;

	SetFpgaPage_B1(6);
	t.year = (*(volatile UINT8 *)0xa00e & 0x0f) + (*(volatile UINT8 *)0xa00e >> 4) * 10 + 2000;
	t.month = (*(volatile UINT8 *)0xa00d & 0x0f) + (*(volatile UINT8 *)0xa00d >> 4) * 10;
	t.day = (*(volatile UINT8 *)0xa00b & 0x0f) + (*(volatile UINT8 *)0xa00b >> 4) * 10;
	t.hour = (*(volatile UINT8 *)0xa00a & 0x0f) + (*(volatile UINT8 *)0xa00a >> 4) * 10;
	t.min = (*(volatile UINT8 *)0xa009 & 0x0f) + (*(volatile UINT8 *)0xa009 >> 4) * 10;
	t.sec = (*(volatile UINT8 *)0xa008 & 0x0f) + (*(volatile UINT8 *)0xa008 >> 4) * 10;
	SetFpgaPage_B1(3);
	DrawU32Decimal(12345678);
	DrawU32Decimal(t.year);
	DrawU32Decimal(t.month);
	DrawU32Decimal(t.day);
	DrawU32Decimal(t.hour);
	DrawU32Decimal(t.min);
	DrawU32Decimal(t.sec);
	WaitJoypadSelect();
}
#endif

/* 01:4c5e (0918: 01:4ec9): the cart RTC (page 6, BCD from $A008) as
   DateToDaysSince1970's seconds */
UINT32 RtcToDayCount (void)
{
	RTCTIME t;

	SetFpgaPage_B1(6);
	t.year = (*(volatile UINT8 *)0xa00e & 0x0f) + (*(volatile UINT8 *)0xa00e >> 4) * 10 + 2000;
	t.month = (*(volatile UINT8 *)0xa00d & 0x0f) + (*(volatile UINT8 *)0xa00d >> 4) * 10;
	t.day = (*(volatile UINT8 *)0xa00b & 0x0f) + (*(volatile UINT8 *)0xa00b >> 4) * 10;
	t.hour = (*(volatile UINT8 *)0xa00a & 0x0f) + (*(volatile UINT8 *)0xa00a >> 4) * 10;
	t.min = (*(volatile UINT8 *)0xa009 & 0x0f) + (*(volatile UINT8 *)0xa009 >> 4) * 10;
	t.sec = (*(volatile UINT8 *)0xa008 & 0x0f) + (*(volatile UINT8 *)0xa008 >> 4) * 10;
	SetFpgaPage_B1(3);
	return DateToDaysSince1970(&t);
}

/* 01:4df1: advance the game's MBC3 clock (wSaveBuf) by the seconds since
   base and write it to the cart RTC (page 6, $A018) and to pSRAM page $11
   ($A220); returns the time now */
UINT32 RtcWriteTimeFromDayDelta (UINT32 base)
{
	UINT32 now;
	INT32 delta;
	UINT32 days;
	UINT8 ctl, sec, min, hour;

	now = RtcToDayCount();
	delta = now - base;
	if (base == 0 || delta < 0) {
		sec = 0;
		min = 0;
		hour = 0;
		days = 0;
		ctl = 0;
	} else {
		sec = wSaveBuf[0];
		min = wSaveBuf[4];
		hour = wSaveBuf[8];
		days = wSaveBuf[12];
		ctl = wSaveBuf[16];
		if (sec > 59 || min > 59 || hour > 23) {
			sec = 0;
			min = 0;
			hour = 0;
			days = 0;
			ctl = 0;
		}
		sec += delta % 60;
		if (sec > 59) {
			sec -= 60;
			min++;
		}
		delta = delta / 60;
		min += delta % 60;
		if (min > 59) {
			min -= 60;
			hour++;
		}
		delta = delta / 60;
		hour += delta % 24;
		if (hour > 23) {
			hour -= 24;
			days++;
		}
		delta = delta / 24;
		days += delta;
		if (days > 0xff) {
			ctl = (ctl & 0xc1) | 0x01;
			if (days > 0x1ff) {
				days &= 0x1ff;
				ctl |= 0x80;
				ctl &= 0xc0;
			}
		}
	}
	SetFpgaPage_B1(6);
	*(UINT8 *)0xa018 = sec;
	*(UINT8 *)0xa019 = min;
	*(UINT8 *)0xa01a = hour;
	*(UINT8 *)0xa01b = days;
	*(UINT8 *)0xa01c = ctl;
	*(UINT8 *)0x4000 = 0x11;
	SetFpgaPage_B1(3);
	*(UINT8 *)0xa220 = sec;
	*(UINT8 *)0xa221 = min;
	*(UINT8 *)0xa222 = hour;
	*(UINT8 *)0xa223 = days;
	*(UINT8 *)0xa224 = ctl;
	*(UINT8 *)0x4000 = 0;
	SetFpgaPage_B1(0);
#ifndef K0918
	SetFpgaPage_B1(0);
#endif
	return now;
}

/* 01:50e4: zero the game clock in the cart RTC and in pSRAM; returns the
   time now */
UINT32 RtcReadDaysClearRegs (void)
{
	UINT32 now;

	now = RtcToDayCount();
	SetFpgaPage_B1(6);
	*(UINT8 *)0xa018 = 0;
	*(UINT8 *)0xa019 = 0;
	*(UINT8 *)0xa01a = 0;
	*(UINT8 *)0xa01b = 0;
	*(UINT8 *)0xa01c = 0;
	*(UINT8 *)0x4000 = 0x11;
	SetFpgaPage_B1(3);
	*(UINT8 *)0xa220 = 0;
	*(UINT8 *)0xa221 = 0;
	*(UINT8 *)0xa222 = 0;
	*(UINT8 *)0xa223 = 0;
	*(UINT8 *)0xa224 = 0;
	*(UINT8 *)0x4000 = 0;
	SetFpgaPage_B1(0);
	return now;
}

/* 01:5163: load /SAVER/<name>.sav into the save pSRAM (or $FF when there is
   none), restore the game clock from a 48-byte RTC footer, and stamp page
   $11 with the save size, the name and the time. kernel.sym's
   PreLaunchSaveStamp ($55C2) is the common tail. The caller's second
   argument is not used. */
void BackupOpenSaverPath (char *path, UINT32 unused) __banked
{
	UINT32 ofs;
	UINT br;
	UINT32 size;
	UINT32 rtcpos;
	UINT32 now;
	UINT8 len;
	UINT16 i;
	UINT8 hasrtc;
	FRESULT res;

	memcpy(wTmp, "/SAVER/", 30);
	CStrCat_B1(wTmp, path);
	len = strlen(wTmp);
	if (wTmp[(UINT8)(len - 1)] != 'c' && wTmp[(UINT8)(len - 1)] != 'C')
		len++;
	wTmp[(UINT8)(len - 3)] = 's';
	wTmp[(UINT8)(len - 2)] = 'a';
	wTmp[(UINT8)(len - 1)] = 'v';
	wTmp[len] = 0;
	SetFpgaPage_B1(0);
	res = fs_open(&wFil, wTmp, 0);
	switch (wD3ED) {
	case 0:
		if (wD3EB == 2)
			size = 0x2000;
		else
			size = 0;
		break;
	case 1:
	case 2:
		size = 0x2000;
		break;
	case 4:
		size = 0x20000;
		break;
	case 5:
		size = 0x10000;
		break;
	default:
		size = 0x8000;
		break;
	}
	if (res == FR_OK) {
		fs_open(&wFil, wTmp, 3);
		size = wFil.fsize;
		fs_lseek(&wFil, 0);
		if ((size & 0x30) == 0x30) {
			hasrtc = 1;
			size &= 0xffffff00;
		} else
			hasrtc = 0;
		for (ofs = 0; ofs < size; ofs += 512) {
			SetFpgaPage_B1(0);
			fs_read(&wFil, wSaveBuf, 512, &br);
			*(UINT8 *)0x4000 = ofs >> 13;
			SetFpgaPage_B1(3);
			set_data((unsigned char *)((ofs & 0x1fff) + 0xa000), wSaveBuf, 512);
		}
		if (hasrtc) {
			SetFpgaPage_B1(0);
			rtcpos = size + 0x28;
			fs_lseek(&wFil, rtcpos);
			fs_read(&wFil, &wD3F2, 4, &br);
			fs_lseek(&wFil, size);
			fs_read(&wFil, wSaveBuf, 0x30, &br);
			now = RtcWriteTimeFromDayDelta(wD3F2);
		} else if (wD3F0)
			now = RtcReadDaysClearRegs();
		SetFpgaPage_B1(0);
		fs_close(&wFil);
	} else {
		memset(wSaveBuf, 0xff, 512);
		for (ofs = 0; ofs < size; ofs += 512) {
			SetFpgaPage_B1(0);
			*(UINT8 *)0x4000 = ofs >> 13;
			SetFpgaPage_B1(3);
			set_data((unsigned char *)((ofs & 0x1fff) + 0xa000), wSaveBuf, 512);
		}
		now = RtcReadDaysClearRegs();
		SetFpgaPage_B1(0);
	}
	size = size >> 13;
	*(UINT8 *)0x4000 = 0x11;
	SetFpgaPage_B1(3);
	*(UINT8 *)0xa000 = 0xaa;
	*(UINT8 *)0xa001 = size;
	*(UINT8 *)0xa00f = len;
	for (i = 0; i < len; i++) *(UINT8 *)(0xa010 + i) = wTmp[i];
	if (wD3F0) {
		*(UINT8 *)0xa202 = 0x77;
		*(UINT8 *)0xa210 = now & 0xff;
		*(UINT8 *)0xa211 = (now >> 8) & 0xff;
		*(UINT8 *)0xa212 = (now >> 16) & 0xff;
		*(UINT8 *)0xa213 = (now >> 24) & 0xff;
	} else
		*(UINT8 *)0xa202 = 0;
	*(UINT8 *)0x4000 = 0;
	SetFpgaPage_B1(0);
}

/* 01:5736: bubble-sort the first n entries by name (page 1 of the table,
   swapping through wSaveBuf). kernel.sym has it as BuildSaverBackupPath. */
void SortEntries_B1 (UINT16 n) __banked
{
	UINT16 i, j, last, end;

	if (n > 1) {
		*(UINT8 *)0x4000 = 1;
		last = n - 1;
		for (i = 0; i < last; i++) {
			end = n - i - 1;
			for (j = 0; j < end; j++) {
				if (CStrCmp(wEntries[j].name, wEntries[j + 1].name) > 0) {
					memcpy(wSaveBuf, wEntries[j + 1].name, 255);
					memcpy(wEntries[j + 1].name, wEntries[j].name, 255);
					memcpy(wEntries[j].name, wSaveBuf, 255);
				}
			}
		}
	}
}

/* 01:58b0: the ROM file's sectors as runs for the FPGA loader, in wSaveBuf:
   0, then (sector count, start sector) pairs, ending 0, $FFFFFFFF; at
   $1F0 the file size, 1 and the cluster size. Returns $FFFFFFFF when the
   file does not open. */
UINT32 LaunchSetup (char *path) __banked
{
	UINT32 res;
	FIL fil;
	UINT32 *p;
	UINT32 clst;
	UINT32 prev;
	UINT32 n;
	UINT32 last;
	UINT32 fsize;

	SetFpgaPage_B1(0);
	res = fs_open(&fil, path, FA_READ);
	if (res)
		return 0xffffffff;
	if (wFatFs.fs_type == FS_FAT16)
		last = 0xffff;
	else
		last = 0x0ffffff7;
	clst = fil.sclust;
	fsize = fil.fsize;
	p = (UINT32 *)wSaveBuf;
	*p = 0;
	p++;
	*p = fs_clust2sect(&wFatFs, clst);
	p++;
	prev = clst;
	n = 0;
	do {
		clst = fs_get_fat(fil.fs, clst);
		n++;
		if (clst != prev + 1) {
			*p = n * wFatFs.csize;
			p++;
			*p = fs_clust2sect(&wFatFs, clst);
			p++;
		}
		prev = clst;
	} while (clst < last);
	p--;
	*p = 0;
	p--;
	*p = 0xffffffff;
	fs_close(&fil);
	p = (UINT32 *)wSaveBuf;
	p[124] = fsize;
	p[125] = 1;
	p[126] = wFatFs.csize;
	return 0;
}

/* 01:5c08: the launch settings from the cartridge type byte ($0147) */
void MapCartTypeToUi (UINT8 type)
{
	switch (type) {
	case 0x00:
	case 0x08:
	case 0x09:
		wD3EB = 0;
		break;
	case 0x01:
	case 0x02:
	case 0x03:
	case 0xea:
	case 0xff:
		wD3EB = 1;
		break;
	case 0x05:
	case 0x06:
		wD3EB = 2;
		break;
	case 0x0f:
	case 0x10:
	case 0x11:
	case 0x12:
	case 0x13:
	case 0xfc:
		wD3EB = 3;
		break;
	case 0x19:
	case 0x1a:
	case 0x1b:
	case 0x1c:
	case 0x1d:
	case 0x1e:
		wD3EB = 4;
		break;
	case 0x0b:
	case 0x0c:
	case 0x0d:
	case 0x15:
	case 0x16:
	case 0x17:
	case 0x22:
	case 0x55:
	case 0x56:
	case 0xfd:
	case 0xfe:
		wD3EB = 6;
		break;
	default:
		wD3EB = 6;
		break;
	}
	if (type == 0x03 || type == 0x06 || type == 0x09 || type == 0x0d || type == 0x0f
	    || type == 0x10 || type == 0x13 || type == 0x17 || type == 0x1b || type == 0x1e
	    || type == 0x22 || type == 0xfd || type == 0xff)
		wD3EF = 1;
	else
		wD3EF = 0;
	if (type == 0x0f || type == 0x10)
		wD3F0 = 1;
	else
		wD3F0 = 0;
	switch (type) {
	case 0x1c:
	case 0x1d:
	case 0x1e:
		wD3F1 = 1;
		break;
	default:
		wD3F1 = 0;
		break;
	}
}

/* 01:5e14: open the ROM, read its header into the launch settings, and
   tell MBC1M (a second header at 256 KB) from MBC1; returns f_open's
   result */
UINT8 RomLoaderMain (char *path) __banked
{
	UINT32 res;
	UINT br;
	UINT16 i;
	UINT8 type;
	UINT32 hash = 0;

	SetFpgaPage_B1(0);
	res = fs_open(&wFil, path, FA_READ);
	if (res)
		return 0xff;
	wRomBanks = wFil.fsize >> 14;
	fs_lseek(&wFil, 0);
	fs_read(&wFil, wSaveBuf, 512, &br);
	wHdrSum = 0;
	for (i = 0x134; i <= 0x14c; i++)
		wHdrSum = wHdrSum - wSaveBuf[i] - 1;
	type = wSaveBuf[0x147];
	wD3EC = wSaveBuf[0x148];
	wD3ED = wSaveBuf[0x149];
	wD3EE = wSaveBuf[0x14c];
	MapCartTypeToUi(type);
	if (wD3EB == 1 && wRomBanks > 32) {
		fs_lseek(&wFil, 0x40000);
		fs_read(&wFil, wSaveBuf, 512, &br);
		for (i = 0x104; i <= 0x133; i++)
			hash = (hash << 1) ^ wSaveBuf[i];
		if (hash == 0xe06c8834)
			wD3EB = 5;
	}
	fs_close(&wFil);
	return res;
}

void DrawInfoPanelRect (void);

/* 01:601e: the ROM info screen (cartridge type, ROM and RAM size, battery);
   waits for A or B. The RAM size is printed in hex. */
void DrawCardTypeScreen (void)
{
	char buf[20];
	UINT8 ram;
	UINT8 keys;

	DrawInfoPanelRect();
	color(3, 0, 0);
	DrawString("Cardtype:", 0, 0x25, 0x2a);
	switch (wD3EB) {
	case 0:
		strcpy(buf, "NoMBC");
		break;
	case 1:
		strcpy(buf, "MBC1");
		break;
	case 2:
		strcpy(buf, "MBC2");
		break;
	case 3:
		strcpy(buf, "MBC3");
		break;
	case 4:
		strcpy(buf, "MBC5");
		break;
	case 5:
		strcpy(buf, "MBC1M");
		break;
	case 6:
		strcpy(buf, "Not");
		break;
	}
	DrawString(buf, 0, 0x5c, 0x2a);
	DrawString("ROM size:", 0, 0x25, 0x36);
	U32ToAscii_B0(32 << wD3EC, buf, 10);
	CStrCat_B1(buf, "KB");
	DrawString(buf, 0, 0x5c, 0x36);
	DrawString("RAM size:", 0, 0x25, 0x42);
	switch (wD3ED) {
	case 0:
		ram = 0;
		break;
	case 1:
	case 2:
		ram = 8;
		break;
	case 4:
		ram = 128;
		break;
	default:
		ram = 32;
		break;
	}
	U32ToAscii_B0(ram, buf, 16);
	CStrCat_B1(buf, "KB");
	DrawString(buf, 0, 0x5c, 0x42);
	DrawString("Battery :", 0, 0x25, 0x4e);
	if (wD3EF)
		DrawString("Yes", 0, 0x5c, 0x4e);
	else
		DrawString("No", 0, 0x5c, 0x4e);
	for (;;) {
		keys = joypad();
		if (keys & J_A)
			break;
		if (keys & J_B)
			break;
	}
}

/* 01:62b1 */
void DrawInfoPanelRect (void)
{
	color(3, 2, 0);
	box(0x23, 0x25, 0x7d, 0x6c, M_FILL);
}

/* 01:62d0: BOOT / ROM info menu; returns the choice, or $FF for B.
   volatile on the locals reproduces stock's allocation (all three on the
   stack). */
UINT8 BootRomInfoMenu (void)
{
	volatile UINT8 redraw = 1;
	volatile UINT8 sel = 0;
	volatile UINT16 keys;

panel:
	DrawInfoPanelRect();
	for (;;) {
		if (redraw) {
			if (sel == 0) {
				color(1, 2, 0);
				DrawString("BOOT", 0, 0x25, 0x2a);
				color(3, 0, 0);
				DrawString("ROM info", 0, 0x25, 0x3a);
			} else {
				color(3, 0, 0);
				DrawString("BOOT", 0, 0x25, 0x2a);
				color(1, 2, 0);
				DrawString("ROM info", 0, 0x25, 0x3a);
			}
		}
		redraw = 0;
		keys = joypad();
		if (keys & J_UP) {
			if (sel) {
				sel--;
				redraw = 1;
			}
		}
		if (keys & J_DOWN) {
			if ((int)sel < 1) {
				sel++;
				redraw = 1;
			}
		}
		if (keys & J_A) {
			if (sel == 1) {
				DrawCardTypeScreen();
				redraw = 1;
				sel = 0;
				goto panel;
			} else
				break;
		}
		if (keys & J_B)
			return 0xff;
		delay(100);
	}
	color(0, 0, 0);
	box(0, 0, 0x9f, 0x8f, M_FILL);
	color(3, 0, 0);
	DrawString("Loading", 0, 0x33, 0x41);
	return sel;
}

/* 01:643a: write the save pSRAM to wTmp (the .sav path), then the 48-byte
   RTC footer from page $11 when the save has one. path is not used. */
void BackupSaveDump (char *path, UINT32 size)
{
	UINT32 ofs;
	UINT bw;
	UINT8 spin;
	FRESULT res;

	wait_vbl_done();
	SetFpgaPage_B1(0);
	res = fs_open(&wFil, wTmp, FA_WRITE | FA_OPEN_ALWAYS);
	if (res)
		return;
	fs_lseek(&wFil, 0);
	spin = 0;
	for (ofs = 0; ofs < size; ofs += 512) {
		*(UINT8 *)0x4000 = ofs >> 13;
		SetFpgaPage_B1(3);
		set_data(wSaveBuf, (unsigned char *)((ofs & 0x1fff) + 0xa000), 512);
		SetFpgaPage_B1(0);
		fs_write(&wFil, wSaveBuf, 512, &bw);
		spin++;
		if (spin == 3)
			spin = 0;
		if (spin == 0)
			DrawString(".  ", 3, 11, 10);
		else if (spin == 1)
			DrawString(".. ", 3, 11, 10);
		else
			DrawString("...", 3, 11, 10);
	}
	if (wD3F6 == 0x77) {
		memset(wSaveBuf, 0, 48);
		*(UINT8 *)0x4000 = 0x11;
		SetFpgaPage_B1(3);
		*(wSaveBuf + 0) = *(volatile UINT8 *)0xa220;
		*(wSaveBuf + 4) = *(volatile UINT8 *)0xa221;
		*(wSaveBuf + 8) = *(volatile UINT8 *)0xa222;
		*(wSaveBuf + 12) = *(volatile UINT8 *)0xa223;
		*(wSaveBuf + 16) = *(volatile UINT8 *)0xa224;
		*(wSaveBuf + 20) = *(volatile UINT8 *)0xa220;
		*(wSaveBuf + 24) = *(volatile UINT8 *)0xa221;
		*(wSaveBuf + 28) = *(volatile UINT8 *)0xa222;
		*(wSaveBuf + 32) = *(volatile UINT8 *)0xa223;
		*(wSaveBuf + 36) = *(volatile UINT8 *)0xa224;
		*(wSaveBuf + 40) = *(volatile UINT8 *)0xa210;
		*(wSaveBuf + 41) = *(volatile UINT8 *)0xa211;
		*(wSaveBuf + 42) = *(volatile UINT8 *)0xa212;
		*(wSaveBuf + 43) = *(volatile UINT8 *)0xa213;
		*(UINT8 *)0x4000 = 0;
		SetFpgaPage_B1(0);
		fs_lseek(&wFil, size);
		fs_write(&wFil, wSaveBuf, 48, &bw);
	}
	fs_close(&wFil);
}

/* 01:6747: the BACKUPSAVE box; flag 1 saves without asking. save is the
   size in 8 KB pages. */
void BackupSavePrompt (UINT32 save, UINT8 flag) __banked
{
	UINT32 size;
	UINT16 keys;

	color(3, 2, 0);
	box(0x23, 0x25, 0x7d, 0x6c, M_FILL);
	DrawString("BACKUPSAVE", 10, 5, 5);
	if (flag == 1) {
		DrawString("Saving...", 9, 5, 10);
		size = save << 13;
		BackupSaveDump("", size);
		return;
	}
	color(3, 2, 0);
	box(0x27, 0x5d, 0x50, 0x6a, M_FILL);
	box(0x52, 0x5d, 0x7b, 0x6a, M_FILL);
	DrawString("[B]NO", 5, 5, 12);
	DrawString("[A]OK", 5, 10, 12);
	for (;;) {
		keys = joypad();
		if (keys & J_A) {
			DrawString("Saving...", 9, 5, 10);
			size = save << 13;
			BackupSaveDump("", size);
			return;
		}
		if (keys & J_B)
			return;
	}
}
