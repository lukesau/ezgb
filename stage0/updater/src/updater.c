/* The updater's C in bank 0, from $07BC: text drawing and main. Several
   functions are the kernel's (kernel/stock/src/kernel.c). */

#include <gb/gb.h>
#include <gb/drawing.h>
#include <gb/console.h>
#include <stdio.h>
#include <string.h>
#include "label.h"		/* LABEL: the line that names the version, 16 characters */

extern UINT8 _current_bank;		/* crt0's */

UINT8 wBlock[0x206];			/* $C0A0: a block's flash address, then the block */
UINT8 wTextRow;				/* $C2A6: pixel row of DrawU32Hex's next number */
UINT8 wTextCol;				/* $C2A7 */
UINT8 wUnused[7];			/* $C2A8: nothing reads or writes these */

void PlotGlyph12 (UINT8 ch, UINT8 x, UINT8 y) __banked;
void SetFpga7FC0 (UINT8 v) __banked;
void Update (void);
void U32ToAscii_B0 (UINT32 v, char *buf, UINT8 radix);

/* 00:07bc */
void WaitJoypadSelect (void)
{
	while (joypad() != J_SELECT)
		;
	delay(200);
}

/* 00:07db: plot the set bits of one byte, bit 7 leftmost */
void PlotBitRowXY (UINT8 bits, UINT8 x, UINT8 y)
{
	if (bits & 0x01) plot_point(x + 7, y);
	if (bits & 0x02) plot_point(x + 6, y);
	if (bits & 0x04) plot_point(x + 5, y);
	if (bits & 0x08) plot_point(x + 4, y);
	if (bits & 0x10) plot_point(x + 3, y);
	if (bits & 0x20) plot_point(x + 2, y);
	if (bits & 0x40) plot_point(x + 1, y);
	if (bits & 0x80) plot_point(x, y);
}

/* 00:08b6: len characters of s (0: all of it) in the 12-pixel font at
   pixel x, y. A byte from $80 starts a two-byte GB2312 character, drawn
   from a 12x12 font in ROM banks $0A-$15, which the updater does not have. */
void DrawString12 (UINT8 *s, UINT8 len, UINT8 x, UINT8 y)
{
	UINT16 off;
	UINT8 r;
	UINT8 n;
	UINT8 i;
	UINT8 cx;
	UINT16 c1;
	UINT16 c2;
	UINT8 fbank;
	UINT8 bank;
	UINT16 hz;
	UINT8 yy;
	UINT8 d;

	i = 0;
	if (len == 0)
		n = strlen(s);
	else if (strlen(s) < len)
		n = strlen(s);
	else
		n = len;
	cx = x;
	while (i < n) {
		c1 = s[i];
		i++;
		if (c1 < 0x80) {
			bank = _current_bank;
			PlotGlyph12(c1, cx, y);
			*(UINT8 *)&_current_bank = bank;
			SWITCH_ROM_MBC1(bank);
			cx += 6;
		} else {
			c2 = s[i];
			i++;
			hz = (c1 << 8) + c2;
			bank = _current_bank;
			if (hz >= 0xf1bc) {
				fbank = 0x15;
				off = (c1 - 0xf1) * 94 + (c2 - 0xbc);
			} else if (hz >= 0xeaa4) {
				fbank = 0x14;
				off = (c1 - 0xea) * 94 + (c2 - 0xa4);
			} else if (hz >= 0xe2ea) {
				fbank = 0x13;
				off = (c1 - 0xe2) * 94 + (c2 - 0xea);
			} else if (hz >= 0xdbd2) {
				fbank = 0x12;
				off = (c1 - 0xdb) * 94 + (c2 - 0xd2);
			} else if (hz >= 0xd4ba) {
				fbank = 0x11;
				off = (c1 - 0xd4) * 94 + (c2 - 0xba);
			} else if (hz >= 0xcda2) {
				fbank = 0x10;
				off = (c1 - 0xcd) * 94 + (c2 - 0xa2);
			} else if (hz >= 0xc5e8) {
				fbank = 0x0f;
				off = (c1 - 0xc5) * 94 + (c2 - 0xe8);
			} else if (hz >= 0xbed0) {
				fbank = 0x0e;
				off = (c1 - 0xbe) * 94 + (c2 - 0xd0);
			} else if (hz >= 0xb7b8) {
				fbank = 0x0d;
				off = (c1 - 0xb7) * 94 + (c2 - 0xb8);
			} else if (hz >= 0xb0a0) {
				fbank = 0x0c;
				off = (c1 - 0xb0) * 94 + (c2 - 0xa0);
			} else if (hz >= 0xa8b9) {
				fbank = 0x0b;
				off = (c1 - 0xa8) * 94 + (c2 - 0xb9);
			} else if (hz >= 0xa1a0) {
				fbank = 0x0a;
				off = (c1 - 0xa1) * 94 + (c2 - 0xa1);
			}
			*(UINT8 *)0x2000 = fbank;
			off = off * 24;
			off = 0x4000 + off;
			yy = y;
			for (r = 0; r < 12; r++) {
				d = *(UINT8 *)(off + r * 2);
				PlotBitRowXY(d, cx, yy);
				d = *(UINT8 *)(off + r * 2 + 1);
				PlotBitRowXY(d, cx + 8, yy);
				yy++;
			}
			cx += 12;
			*(UINT8 *)&_current_bank = bank;
			SWITCH_ROM_MBC1(bank);
		}
	}
}

/* 00:0dca: v in hex in a box at the text position, which then moves right
   and wraps; past the bottom it waits for SELECT. Nothing calls it. */
void DrawU32Hex (UINT32 v)
{
	char buf[20];

	U32ToAscii_B0(v, buf, 16);
	color(0, 0, 0);
	box(wTextCol, wTextRow, wTextCol + 30, wTextRow + 12, M_FILL);
	color(3, 0, 0);
	DrawString12(buf, 0, wTextCol, wTextRow);
	wTextCol += strlen(buf) * 6 + 3;
	if (wTextCol > 130) {
		wTextCol = 0;
		wTextRow += 13;
	}
	if (wTextRow > 130) {
		wTextCol = 0;
		wTextRow = 50;
		WaitJoypadSelect();
	}
}

/* 00:0e92 */
void FileSystemErrorHang (void)
{
	DrawString12("File system error!", 0, 8, wTextRow);
	while (1)
		;
}

/* 00:0ebc: v in radix (2 to 16, lower-case digits) into buf */
void U32ToAscii_B0 (UINT32 v, char *buf, UINT8 radix)
{
	char tmp[33];
	UINT32 digit;
	char *q, *p;
	UINT32 n;

	p = tmp;
	n = v;
	while (n || p == (char *)tmp) {
		digit = n % radix;
		n = n / radix;
		if (digit < 10)
			*p++ = digit + '0';
		else
			*p++ = digit + 'a' - 10;
	}
	q = buf;
	while ((char *)tmp < p)
		*q++ = *--p;
	*q = 0;
}

/* 00:0ffd */
void main (void)
{
	char num[20];
	char cur[20] = "Current ver:  ";
	UINT8 ver;

	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7f31 = 0;
	*(UINT8 *)0x7f32 = 0x80;
	*(UINT8 *)0x7ff0 = 0xe4;
	wTextRow = 13;
	puts(" EZ-FLASH FW UPDATE");
	SetFpga7FC0(4);
	ver = ReadVersion();
	SetFpga7FC0(0);
	U32ToAscii_B0(ver, num, 10);
	gotoxy(0, 3);
	puts(cur);
	gotoxy(13, 3);
	puts(num);
	gotoxy(0, 5);
	puts(LABEL);
	gotoxy(0, 7);
	puts("Press [A] to update");
	while (1) {
		wait_vbl_done();
		if (joypad() & J_A)
			break;
	}
	Update();
#if FW == 5
	gotoxy(0, 14);
#else
	gotoxy(0, 11);
#endif
	puts("Update finish,power off");
	while (1)
		;
}
