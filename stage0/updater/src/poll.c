/* 01:4000: start a flash operation and wait for it; RunFlashPoll copies it
   to $D000 and runs it there, since the ROM window is busy meanwhile. It is
   linked for $D000 and sits at $4000 in ROM, so it is its own object. */

#include <gb/gb.h>

UINT8 FlashPoll (void)
{
	UINT8 st;

	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7fd2 = 1;
	*(UINT8 *)0x7ff0 = 0xe4;
	do {
		st = *(volatile UINT8 *)0xa000;
	} while (st);
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7fd2 = 0;
	*(UINT8 *)0x7ff0 = 0xe4;
	return st;
}
