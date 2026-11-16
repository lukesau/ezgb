/* The kernel's C in bank 2, $4000-$4380: SD sector reads and writes through
   the FPGA's SD window. src/diskio.c calls SdRead and SdWrite.
   Function names are kernel.sym's (the mod's has SdRead as DiskRead_B2 and
   SdWrite as DiskWrite_B2); built like src/kernel.c. */

#include <gb/gb.h>
#include "integer.h"
#include "diskio.h"

/* FPGA registers: $7F00/$7F10/$7F20 unlock, $7FF0 commits */

/* 02:4000: the SD controller's mode: 0 idle, 1 window, 3 go */
void SetFpga7F30_B2 (UINT8 v)
{
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7f30 = v;
	*(UINT8 *)0x7ff0 = 0xe4;
}

/* 02:4020: $E1 while the controller is busy */
UINT8 SdWindowPeek (void)
{
	return *(UINT8 *)0xa000;
}

/* read count sectors from sector on, at most four a command. Each command
   copies count * 512 bytes to buff, not the chunk's. */
/* 02:4027 */
DRESULT SdRead (DWORD sector, BYTE count, BYTE *buff) __banked
{
	BYTE i, n;
	BYTE *p;

	SetFpga7F30_B2(1);
	for (i = 0; i < count; i += 4) {
		n = (count - i > 4u) ? 4u : (BYTE)(count - i);
		*(UINT8 *)0x7f00 = 0xe1;
		*(UINT8 *)0x7f10 = 0xe2;
		*(UINT8 *)0x7f20 = 0xe3;
		p = (BYTE *)0x7fb0;
		*p = (sector + i) & 0xffu;
		*(BYTE *)0x7fb1 = ((sector + i) & 0xff00) >> 8u;
		*(BYTE *)0x7fb2 = ((sector + i) & 0xff0000) >> 16u;
		*(BYTE *)0x7fb3 = ((sector + i) & 0xff000000) >> 24u;
		*(BYTE *)0x7fb4 = n;
		*(UINT8 *)0x7ff0 = 0xe4;
		SetFpga7F30_B2(3);
		while (SdWindowPeek() == 0xe1u)
			;
		SetFpga7F30_B2(1);
		set_data(buff, (unsigned char *)0xa000, count * 512);
	}
	SetFpga7F30_B2(0);
	return RES_OK;
}

/* write count sectors from sector on, at most four a command; like
   SdRead, each command copies count * 512 bytes */
/* 02:41d5 */
DRESULT SdWrite (DWORD sector, BYTE count, const BYTE *buff) __banked
{
	BYTE i, n;
	BYTE *p;

	SetFpga7F30_B2(1);
	SetFpga7F30_B2(3);
	for (i = 0; i < count; i += 4) {
		n = (count - i > 4) ? 4 : count - i;
		set_data((unsigned char *)0xa000, (unsigned char *)buff, count * 512);
		*(UINT8 *)0x7f00 = 0xe1;
		*(UINT8 *)0x7f10 = 0xe2;
		*(UINT8 *)0x7f20 = 0xe3;
		p = (BYTE *)0x7fb0;
		*p = (sector + i) & 0xffu;
		*(BYTE *)0x7fb1 = ((sector + i) & 0xff00) >> 8u;
		*(BYTE *)0x7fb2 = ((sector + i) & 0xff0000) >> 16u;
		*(BYTE *)0x7fb3 = ((sector + i) & 0xff000000) >> 24u;
		*(BYTE *)0x7fb4 = n + 0x80;
		*(UINT8 *)0x7ff0 = 0xe4;
		while (SdWindowPeek() == 0xe1u)
			;
	}
	delay(10);
	SetFpga7F30_B2(0);
	return RES_OK;
}
