/* The kernel's bank 0 C after SdMenuMain, from $16F4. In stock this is the
   same file as kernel.c; it is apart here until SdMenuMain matches. */

#include "kernel.h"

/* 00:16f4: v in radix (2 to 16, lower-case digits) into buf */
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

/* 00:1835: the boot battery check. pSRAM $A201 holds $88 once the user has
   seen the warning; then the menu */
void BatteryCheck (void)
{
	wDebugTextRow = 0;
	*(UINT8 *)0x4000 = 0x11;
	SetFpgaPageAlt_B4(3);
	if (*(volatile UINT8 *)0xA201 != 0x88) {
		DrawString(" ", 1, 5, 8);
		color(3, 2, 0);
		box(35, 37, 125, 108, M_FILL);
		DrawString("BATTERY", 7, 5, 7);
		DrawString("DRY!!!", 6, 5, 8);
		color(3, 2, 0);
		box(78, 93, 123, 106, M_FILL);
		DrawString("[A]OK", 5, 10, 12);
		while (!(joypad() & J_A))
			;
		*(UINT8 *)0xA201 = 0x88;
	}
	color(3, 0, 0);
	*(UINT8 *)0x4000 = 0;
	SetFpgaPageAlt_B4(0);
	SdMenuMain();
}
