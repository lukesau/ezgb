/* 04:4000-$40AB: RomLoad_InitiatePoll, which RomLoad_BuildAndRunPoll copies
   to $D100 and runs there. It is linked for $D100 (its jumps go to $D1xx)
   and sits at $4000 in ROM, so it is its own object. Built like
   src/kernel.c. */

#include <gb/gb.h>

/* start a ROM load ($7F36=3), wait while $A000 reads 0 and then while it
   reads 1, then reset into the game: bank 1 mapped and $7FE0=$80. Only
   this form of the second loop reads p through its stack slot as stock
   does. */
void RomLoad_InitiatePoll (void)
{
	UINT8 * volatile p;
	UINT8 st;

	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7f36 = 3;
	*(UINT8 *)0x7ff0 = 0xe4;
	do {
		st = *(volatile UINT8 *)0xa000;
	} while (st == 0);
	do {
		p = (volatile UINT8 *)0xa000;
		st = *p;
	} while (st == 1);
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7f36 = 0;
	*(UINT8 *)0x7ff0 = 0xe4;
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7f31 = 0;
	*(UINT8 *)0x7f32 = 0;
	*(UINT8 *)0x7ff0 = 0xe4;
	*(UINT8 *)0x2000 = 1;
	*(UINT8 *)0x3000 = 0;
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7fe0 = 0x80;
	*(UINT8 *)0x7ff0 = 0xe4;
}
