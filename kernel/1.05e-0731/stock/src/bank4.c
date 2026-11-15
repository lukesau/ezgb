/* The kernel's C in bank 4, $40AB-$5932 ($40E7 on is spliced): the FPGA ROM loader commands and
   register writes, string helpers and the time and autosave screen.
   Function names are kernel.sym's; built like src/kernel.c. */

#include <gb/gb.h>
#include <gb/drawing.h>
#include <string.h>
#include "ff.h"

extern UINT16 wRomBanks;		/* $C2A4: the ROM's size in 16 KB banks */
extern UINT8 wHdrSum;			/* $C5A3: the header checksum, worked out */
extern UINT8 wD3EB;			/* save type */

void RomLoad_InitiatePoll (void);	/* 04:4000, run from $D100 */
void DrawString (char *s, UINT8 len, UINT8 x, UINT8 y);
void memset (void *dst, UINT8 c, UINT16 n);	/* Memset, 00:2ca5 */

/* FPGA registers: $7F00/$7F10/$7F20 unlock, $7FF0 commits */

/* 04:40ab: copy n bytes. Not matched yet: stock keeps n in c, this in b;
   still disassembly, like RomLoad_InitiatePoll at $4000. */
#ifdef UNMATCHED
void RomLoad_Build_B4 (UINT8 *dst, UINT8 *src, UINT8 n)
{
	while (n--)
		*dst++ = *src++;
}
#else
void RomLoad_Build_B4 (UINT8 *dst, UINT8 *src, UINT8 n);
#endif

/* 04:40e7: run RomLoad_InitiatePoll from WRAM */
void RomLoad_BuildAndRunPoll (void)
{
	RomLoad_Build_B4((UINT8 *)0xd100, (UINT8 *)RomLoad_InitiatePoll, 0xff);
	((void (*)(void))0xd100)();
}

/* 04:40fc: v's low byte to $7F34, high byte to $7F35 */
void SetFpga7F34_35_B4 (UINT16 v) __banked
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

/* 04:4140 */
void SetRomLoadCtrl_B4 (UINT8 v)
{
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7f36 = v;
	*(UINT8 *)0x7ff0 = 0xe4;
}

/* 04:4160 */
void SetFpga7F37_B4 (UINT8 v) __banked
{
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7f37 = v;
	*(UINT8 *)0x7ff0 = 0xe4;
}

/* 04:4180: map the game's bank 1 and reset into it; run from $D000 */
void RomLoad_ResetIntoRom_B4 (void)
{
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
	for (;;)
		;
}

/* 04:41d2 */
void RomLoad_BuildAndRunReset_B4 (void)
{
	RomLoad_Build_B4((UINT8 *)0xd000, (UINT8 *)RomLoad_ResetIntoRom_B4, 0xff);
	((void (*)(void))0xd000)();
}

/* 04:41e7 */
void SetFpgaPageAlt_B4 (UINT8 page) __banked
{
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7fc0 = page;
	*(UINT8 *)0x7ff0 = 0xe4;
}

/* 04:4207: the ROM bank mask for the header's ROM size code, cut down to
   the file's real size */
void SetFpgaRomSize_B4 (UINT8 code) __banked
{
	UINT16 mask;
	UINT8 *p;

	switch (code) {
	case 0x00: mask = 0x00; break;
	case 0x01: mask = 0x03; break;
	case 0x02: mask = 0x07; break;
	case 0x03: mask = 0x0f; break;
	case 0x04: mask = 0x1f; break;
	case 0x05: mask = 0x3f; break;
	case 0x06: mask = 0x7f; break;
	case 0x07: mask = 0xff; break;
	case 0x08: mask = 0x1ff; break;
	case 0x52: mask = 0x47; break;
	case 0x53: mask = 0x4f; break;
	case 0x54: mask = 0x5f; break;
	default: mask = 0; break;
	}
	if (mask < wRomBanks - 1) {
		if (wRomBanks & 0x01) mask = 0x01;
		if (wRomBanks & 0x02) mask = 0x03;
		if (wRomBanks & 0x04) mask = 0x07;
		if (wRomBanks & 0x08) mask = 0x0f;
		if (wRomBanks & 0x10) mask = 0x1f;
		if (wRomBanks & 0x20) mask = 0x3f;
		if (wRomBanks & 0x40) mask = 0x7f;
		if (wRomBanks & 0x80) mask = 0xff;
		if (wRomBanks & 0x100) mask = 0x1ff;
	}
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7fc1 = mask;
	*(UINT8 *)0x7ff0 = 0xe4;
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	p = (UINT8 *)0x7fc2;
	*p = mask >> 8;
	*(UINT8 *)0x7ff0 = 0xe4;
}

/* 04:43ec: the save RAM mask for the header's RAM size code */
void SetFpga7FC4_B4 (UINT8 code) __banked
{
	UINT8 v;

	switch (code) {
	case 0:
		if (wD3EB == 2)
			v = 0;
		else
			v = 0;
		break;
	case 1:
	case 2:
		v = 0;
		break;
	case 4:
		v = 0x0f;
		break;
	case 5:
		v = 0x07;
		break;
	default:
		v = 0x03;
		break;
	}
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7fc4 = v;
	*(UINT8 *)0x7ff0 = 0xe4;
}

/* 04:446e */
void SetFpga7FC3_B4 (void) __banked
{
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7fc3 = wHdrSum;
	*(UINT8 *)0x7ff0 = 0xe4;
}

/* 04:448f: hand the loader its 512-byte command block */
void RomLoad_CopyCmdWindowPoll_B4 (UINT8 *cmd, UINT8 res) __banked
{
	SetRomLoadCtrl_B4(1);
	set_data((unsigned char *)0xa000, cmd, 512);
	RomLoad_BuildAndRunPoll();
}

/* 04:44af */
void CStrCat (char *dst, const char *src)
{
	char *d = dst;

	while (*d)
		d++;
	while (*src)
		*d++ = *src++;
	*d = 0;
}

/* 04:44f7: v in radix into buf, at least two digits */
void U32ToAscii (UINT32 v, char *buf, UINT8 radix)
{
	char tmp[33];
	UINT32 digit;
	char *q, *p;
	UINT32 n;
	char c;

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
	if (buf[1] == 0) {
		c = buf[0];
		buf[0] = '0';
		buf[1] = c;
		buf[2] = 0;
	}
}

/* 04:466e */
void SetFpgaPage_B4 (UINT8 page)
{
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7fc0 = page;
	*(UINT8 *)0x7ff0 = 0xe4;
}

/* 04:468e */
void SetFpga7FD0_B4 (UINT8 v)
{
	*(UINT8 *)0x7f00 = 0xe1;
	*(UINT8 *)0x7f10 = 0xe2;
	*(UINT8 *)0x7f20 = 0xe3;
	*(UINT8 *)0x7fd0 = v;
	*(UINT8 *)0x7ff0 = 0xe4;
}

/* 04:46ae: set the cart RTC to 2019-07-24 11:22:33 (BCD, page 6) */
void InitTimeAutosaveFpga_B4 (void)
{
	SetFpgaPage_B4(6);
	*(UINT8 *)0xa008 = 0x33;
	*(UINT8 *)0xa009 = 0x22;
	*(UINT8 *)0xa00a = 0x11;
	*(UINT8 *)0xa00b = 0x24;
	*(UINT8 *)0xa00c = 0x03;
	*(UINT8 *)0xa00d = 0x07;
	*(UINT8 *)0xa00e = 0x19;
	SetFpga7FD0_B4(1);
	SetFpgaPage_B4(0);
}

/* 04:46f4: the TIME and AUTO SAVE screen. A on TIME starts setting the
   clock (the cart RTC, BCD on page 6) and A again writes it; A on AUTO
   SAVE toggles pSRAM $A200; SELECT leaves. */
void DrawTimeAutosaveScreen (void) __banked
{
	char rtc[7];		/* the cart RTC, BCD */
	char shown[7];		/* rtc as last drawn */
	char edit[7];		/* the time being set, binary */
	char buf[20];
	UINT8 mode, field, dirty, row, autosave;
	UINT8 *p;
	UINT16 keys;
	char r;

	row = 0;
	mode = 0;
	field = 0;
	dirty = 0;
	*(UINT8 *)0x4000 = 0x11;
	SetFpgaPage_B4(3);
	autosave = *(volatile UINT8 *)0xa200;
	*(UINT8 *)0x4000 = 0;
	SetFpgaPage_B4(0);
	color(0, 0, 0);
	box(0x78, 0x00, 0x9f, 0x07, M_FILL);
	color(3, 0, 0);
	DrawString("TIME:", 5, 0, 3);
	color(3, 2, 0);
	box(0x7b, 0x15, 0x9b, 0x21, M_FILL);
	DrawString("SET", 3, 16, 3);
	color(3, 0, 0);
	DrawString("AUTO SAVE:", 10, 0, 7);
	box(0x82, 0x38, 0x8a, 0x40, M_NOFILL);
	if (autosave == 1) {
		color(2, 2, 0);
		box(0x84, 0x3a, 0x88, 0x3e, M_FILL);
	}
	memset(shown, 0xff, 7);
	for (;;) {
		if (mode == 0) {
			if (dirty == 1) {
				if (row == 0)
					color(3, 2, 0);
				else
					color(3, 0, 0);
				box(0x7b, 0x15, 0x9b, 0x21, M_FILL);
				if (mode == 0)
					DrawString("SET", 3, 16, 3);
				else
					DrawString("SAV", 3, 16, 3);
				color(0, 0, 0);
				box(0x82, 0x38, 0x8a, 0x40, M_FILL);
				if (row == 1)
					color(2, 2, 0);
				else
					color(3, 0, 0);
				box(0x82, 0x38, 0x8a, 0x40, M_NOFILL);
				if (autosave == 1) {
					color(2, 2, 0);
					box(0x84, 0x3a, 0x88, 0x3e, M_FILL);
				}
			}
			SetFpgaPage_B4(6);
			rtc[0] = *(volatile UINT8 *)0xa008;
			rtc[1] = *(volatile UINT8 *)0xa009;
			rtc[2] = *(volatile UINT8 *)0xa00a;
			rtc[3] = *(volatile UINT8 *)0xa00b;
			rtc[4] = *(volatile UINT8 *)0xa00c;
			rtc[5] = *(volatile UINT8 *)0xa00d;
			rtc[6] = *(volatile UINT8 *)0xa00e;
			SetFpgaPage_B4(0);
			color(3, 0, 0);
			if (rtc[6] != shown[6] || dirty) {
				U32ToAscii((rtc[6] & 0x0f) + (rtc[6] >> 4) * 10 + 2000, buf, 10);
				CStrCat(buf, "/");
				DrawString(buf, 5, 0, 5);
			}
			if (rtc[5] != shown[5] || dirty) {
				U32ToAscii((rtc[5] & 0x0f) + ((rtc[5] & 0x1f) >> 4) * 10, buf, 10);
				DrawString(buf, 2, 5, 5);
				DrawString("/", 1, 7, 5);
			}
			if (rtc[3] != shown[3] || dirty) {
				U32ToAscii((rtc[3] & 0x0f) + ((rtc[3] & 0x3f) >> 4) * 10, buf, 10);
				DrawString(buf, 2, 8, 5);
			}
			if (rtc[2] != shown[2] || dirty) {
				U32ToAscii((rtc[2] & 0x0f) + ((rtc[2] & 0x3f) >> 4) * 10, buf, 10);
				DrawString(buf, 2, 11, 5);
				DrawString(":", 1, 13, 5);
			}
			if (rtc[1] != shown[1] || dirty) {
				U32ToAscii((rtc[1] & 0x0f) + ((rtc[1] & 0x7f) >> 4) * 10, buf, 10);
				DrawString(buf, 2, 14, 5);
				DrawString(":", 1, 16, 5);
			}
			if (rtc[0] != shown[0] || dirty) {
				U32ToAscii((rtc[0] & 0x0f) + ((rtc[0] & 0x7f) >> 4) * 10, buf, 10);
				DrawString(buf, 2, 17, 5);
			}
			dirty = 0;
			memcpy(shown, rtc, 7);
		} else if (dirty) {
			color(3, 2, 0);
			DrawString("SAV", 3, 16, 3);
			color(3, 0, 0);
			U32ToAscii(edit[6] + 2000, buf, 10);
			if (field == 0)
				color(3, 2, 0);
			DrawString(buf, 4, 0, 5);
			color(3, 0, 0);
			DrawString("/", 1, 4, 5);
			U32ToAscii(edit[5] & 0x1f, buf, 10);
			if (field == 1)
				color(3, 2, 0);
			DrawString(buf, 2, 5, 5);
			color(3, 0, 0);
			DrawString("/", 1, 7, 5);
			U32ToAscii(edit[3] & 0x3f, buf, 10);
			if (field == 2)
				color(3, 2, 0);
			DrawString(buf, 2, 8, 5);
			color(3, 0, 0);
			U32ToAscii(edit[2] & 0x3f, buf, 10);
			if (field == 3)
				color(3, 2, 0);
			DrawString(buf, 2, 11, 5);
			color(3, 0, 0);
			DrawString(":", 1, 13, 5);
			U32ToAscii(edit[1] & 0x7f, buf, 10);
			if (field == 4)
				color(3, 2, 0);
			DrawString(buf, 2, 14, 5);
			color(3, 0, 0);
			DrawString(":", 1, 16, 5);
			U32ToAscii(edit[0] & 0x7f, buf, 10);
			if (field == 5)
				color(3, 2, 0);
			DrawString(buf, 2, 17, 5);
			color(3, 0, 0);
			dirty = 0;
		}
		keys = joypad();
		if (keys & J_LEFT) {
			if (mode && row == 0) {
				if (field)
					field--;
				else if (field == 0)
					field = 5;
				dirty = 2;
			}
		} else if (keys & J_RIGHT) {
			if (mode && row == 0) {
				field++;
				if (field == 6)
					field = 0;
				dirty = 3;
			}
		} else if (keys & J_UP) {
			if (mode) {
				if (row == 0) {
				if (field == 0) {
					if (edit[6] == 99)
						edit[6] = 0;
					else
						edit[6]++;
				} else if (field == 1) {
					if (edit[5] == 12)
						edit[5] = 1;
					else
						edit[5]++;
				} else if (field == 2) {
					switch (edit[5]) {
					case 1: case 3: case 5: case 7: case 8: case 10: case 12:
						if (edit[3] == 31)
							edit[3] = 1;
						else
							edit[3]++;
						break;
					case 4: case 6: case 9: case 11:
						if (edit[3] == 30)
							edit[3] = 1;
						else
							edit[3]++;
						break;
					case 2:
						r = edit[6] % 4;
						if ((r == 0 && edit[3] == 29) || (r > 0 && edit[3] == 28))
							edit[3] = 1;
						else
							edit[3]++;
						break;
					}
				} else if (field == 3) {
					if (edit[2] == 23)
						edit[2] = 0;
					else
						edit[2]++;
				} else if (field == 4) {
					if (edit[1] == 59)
						edit[1] = 0;
					else
						edit[1]++;
				} else if (field == 5) {
					if (edit[0] == 59)
						edit[0] = 0;
					else
						edit[0]++;
				}
				dirty = 1;
				}
			} else {
				if (row) {
					row--;
					dirty = 1;
				}
			}
		} else if (keys & J_DOWN) {
			if (mode) {
				if (row == 0) {
				if (field == 0) {
					if (edit[6] == 0)
						edit[6] = 99;
					else
						edit[6]--;
				} else if (field == 1) {
					if (edit[5] < 1)
						edit[5] = 12;
					else
						edit[5]--;
				} else if (field == 2) {
					switch (edit[5]) {
					case 1: case 3: case 5: case 7: case 8: case 10: case 12:
						if (edit[3] < 1)
							edit[3] = 31;
						else
							edit[3]--;
						break;
					case 4: case 6: case 9: case 11:
						if (edit[3] < 1)
							edit[3] = 30;
						else
							edit[3]--;
						break;
					case 2:
						if (edit[3] == 1) {
							if (edit[6] % 4 == 0)
								edit[3] = 29;
							else
								edit[3] = 28;
						} else
							edit[3]--;
						break;
					}
				} else if (field == 3) {
					if (edit[2] == 0)
						edit[2] = 23;
					else
						edit[2]--;
				} else if (field == 4) {
					if (edit[1] == 0)
						edit[1] = 59;
					else
						edit[1]--;
				} else if (field == 5) {
					if (edit[0] == 0)
						edit[0] = 59;
					else
						edit[0]--;
				}
				dirty = 1;
				}
			} else {
				if (row < 1) {
					row++;
					dirty = 1;
				}
			}
		} else if (keys & J_SELECT) {
			return;
		} else if (keys & J_B) {
		} else if (keys & J_A) {
			if (row == 0) {
				color(3, 2, 0);
				box(0x7b, 0x15, 0x9b, 0x21, M_FILL);
				color(3, 0, 0);
				if (mode == 0) {
					mode = 1;
					dirty = 1;
					field = 0;
					edit[6] = (rtc[6] & 0x0f) + (rtc[6] >> 4) * 10;
					edit[5] = (rtc[5] & 0x0f) + ((rtc[5] & 0x1f) >> 4) * 10;
					edit[3] = (rtc[3] & 0x0f) + ((rtc[3] & 0x3f) >> 4) * 10;
					edit[2] = (rtc[2] & 0x0f) + ((rtc[2] & 0x3f) >> 4) * 10;
					edit[1] = (rtc[1] & 0x0f) + ((rtc[1] & 0x7f) >> 4) * 10;
					edit[0] = (rtc[0] & 0x0f) + ((rtc[0] & 0x7f) >> 4) * 10;
				} else {
					mode = 0;
					dirty = 1;
					SetFpgaPage_B4(6);
					p = (UINT8 *)0xa008;
					*p = ((edit[0] / 10) << 4) + edit[0] % 10;
					p = (UINT8 *)0xa009;
					*p = ((edit[1] / 10) << 4) + edit[1] % 10;
					p = (UINT8 *)0xa00a;
					*p = ((edit[2] / 10) << 4) + edit[2] % 10;
					p = (UINT8 *)0xa00b;
					*p = ((edit[3] / 10) << 4) + edit[3] % 10;
					*(UINT8 *)0xa00c = 3;
					p = (UINT8 *)0xa00d;
					*p = ((edit[5] / 10) << 4) + edit[5] % 10;
					p = (UINT8 *)0xa00e;
					*p = ((edit[6] / 10) << 4) + edit[6] % 10;
					SetFpga7FD0_B4(1);
					SetFpgaPage_B4(0);
				}
			} else {
				if (autosave == 0)
					autosave = 1;
				else
					autosave = 0;
				dirty = 1;
				*(UINT8 *)0x4000 = 0x11;
				SetFpgaPage_B4(3);
				*(UINT8 *)0xa200 = autosave;
				*(UINT8 *)0x4000 = 0;
				SetFpgaPage_B4(0);
			}
		}
	}
}
