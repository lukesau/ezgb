/* $14FE-$1559: a second copy of the byte copy, which nothing calls, and
   the $7FC0 write. Banked functions in bank 0: their callers go through
   banked_call with bank $FFFF. */

#include <gb/gb.h>

/* 00:14fe */
#pragma save
#pragma noinduction
void MemCopy8_B (UINT8 *dst, char *src, UINT8 n)
{
	UINT8 *d;
	UINT8 *s;
	UINT8 i;

	s = src;
	d = dst;
	i = n;
	while (i--)
		*d++ = *s++;
}
#pragma restore

/* 00:153a */
void SetFpga7FC0 (UINT8 v) __banked
{
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7fc0 = v;
	*(UINT8 *)0x7ff0 = 0xe4;
}
