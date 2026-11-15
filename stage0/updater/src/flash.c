/* The flash write, $120F-$14FD. */

#include <gb/gb.h>
#include <gb/drawing.h>
#include <gb/console.h>
#include <stdio.h>
#include <string.h>

extern UINT8 wBlock[];			/* $C0A0: the address, then the block */

void SetFpga7FC0 (UINT8 v) __banked;
void RunFlashPoll (void) __banked;
void U32ToAscii_B0 (UINT32 v, char *buf, UINT8 radix);

/* 00:120f: copy n bytes */
#pragma save
#pragma noinduction
void MemCopy8 (UINT8 *dst, char *src, UINT8 n)
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

/* 00:124b: copied to $D000 and run there */
UINT8 ReadA000 (void)
{
	return *(volatile UINT8 *)0xa000;
}

/* 00:1252 */
void SetFpga7FD2On (void)
{
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7fd2 = 1;
	*(UINT8 *)0x7ff0 = 0xe4;
}

/* 00:1271 */
void SetFpga7FD2Off (void)
{
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7fd2 = 0;
	*(UINT8 *)0x7ff0 = 0xe4;
}

/* 00:1290 */
void SetFpga7F36 (UINT8 v)
{
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7f36 = v;
	*(UINT8 *)0x7ff0 = 0xe4;
}

/* 00:12b0: one block, its address first, into the command window */
void StageBlock (UINT8 *block)
{
	SetFpga7FC0(2);
	SetFpga7F36(1);
	set_data((UINT8 *)0xa000, block, 0x110);
	SetFpga7F36(0);
	SetFpga7FC0(0);
}

/* 00:12f0 */
UINT8 ReadVersion (void)
{
	MemCopy8((UINT8 *)0xd000, (char *)ReadA000, 0xff);
	return ((UINT8 (*)(void))0xd000)();
}

/* 00:1305 */
void CStrCat (char *dst, const char *src)
{
	char *d = dst;

	while (*d)
		d++;
	while (*src)
		*d++ = *src++;
	*d = 0;
}

/* 00:134d: the bitstream at ROM offset $8000, 256 bytes a block, to config
   flash $040000 on. FW4's updater turns interrupts off around each block's
   flash operation; FW5's keeps them off for the whole update and says not
   to touch the keys. */
void Update (void)
{
	INT32 i;
	UINT8 bank;
	UINT16 off;
	char buf[20];

	SetFpga7FD2Off();
#if FW == 5
	gotoxy(0, 9);
	puts("Do not touch any key when updating!!!");
	disable_interrupts();
#endif
	for (i = 0; i < 0x2480c; i += 0x100) {
		U32ToAscii_B0(i * 100 / 0x2480c + 1, buf, 10);
		CStrCat(buf, "%");
#if FW == 5
		gotoxy(0, 12);
#else
		gotoxy(0, 9);
#endif
		puts(buf);
		*(UINT32 *)wBlock = i + 0x40000;
		bank = (i >> 14) + 2;
		off = i & 0x3fff;
		*(UINT8 *)0x2000 = bank;
		off = 0x4000 + off;
		set_data(wBlock + 4, (UINT8 *)off, 0x110);
		StageBlock(wBlock);
		SetFpga7FC0(5);
#if FW == 5
		RunFlashPoll();
#else
		disable_interrupts();
		RunFlashPoll();
		enable_interrupts();
#endif
		SetFpga7FC0(0);
	}
#if FW == 5
	enable_interrupts();
#endif
}
