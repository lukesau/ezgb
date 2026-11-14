/* The kernel's own C in bank 0, from $07BC. Function names are kernel.sym's;
   the GBDK calls are GBDK 2.96a's library (gbdk/include), built with
   BYTE_IS_UNSIGNED so its types and FatFs's agree. */

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
extern UINT8 wDirEnd;			/* $C5A4: DirList read the last entry */
extern FILINFO wFno;			/* $C9DB */
extern DIR wDir;			/* $C9F5 */

void PsramPage (UINT8 page) __banked;	/* 04:41e7, name ours */
void CStrCat_B1 (char *dst, const char *src) __banked;	/* 01:4000 */

extern char wLabelBuf[];		/* $C4A4: the marquee text */
extern UINT16 wMarqueePos;		/* $CC31: the offset last drawn */

extern UINT8 wDebugTextRow;		/* $CC2F: row of the next boot message */
extern UINT8 wDebugTextCol;		/* $CC30 */

void U32ToAscii_B0 (UINT32 v, char *buf, UINT8 radix);
void DrawString (char *s, UINT8 len, UINT8 x, UINT8 y);

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

/* 00:08b6: empty and never called; the name is ours */
void Unused_08b6 (void)
{
}

/* 00:08b7: len characters of s at (x, y), blanks past its end; len 0 = 17 */
void DrawString (char *s, UINT8 len, UINT8 x, UINT8 y)
{
	UINT8 n, i;

	gotogxy(x, y);
	if (len == 0)
		n = 17;
	else
		n = len;
	for (i = 0; i < n; i++) {
		if (*s) {
			wrtchr(*s++);
		} else {
			color(3, 0, 0);
			wrtchr(' ');
		}
	}
}

/* 00:092a: v in decimal on the next boot message row */
void DrawU32Decimal (UINT32 v)
{
	char buf[20];
	UINT8 n;

	U32ToAscii_B0(v, buf, 10);
	n = strlen(buf);
	DrawString(buf, n, wDebugTextCol, wDebugTextRow);
	wDebugTextRow++;
	if (wDebugTextRow > 20)
		wDebugTextRow = 0;
}

/* 00:0985 */
void FileSystemErrorHang (void)
{
	DrawString("File system error!", 0, 1, wDebugTextRow);
	while (1)
		;
}

/* 00:09af: FatFs's mem_cmp, with EZ Flash's byte count (as in ff.c) */
int MemCmp_B0 (const void* dst, const void* src, UINT8 cnt)
{
	const UINT8 *d = (const UINT8 *)dst, *s = (const UINT8 *)src;
	int r = 0;

	while (cnt-- && (r = *d++ - *s++) == 0) ;
	return r;
}

/* 00:0a19: FatFs's mem_set, byte count */
void MemSet8_B0 (void* dst, int val, UINT8 cnt)
{
	UINT8 *d = (UINT8*)dst;

	while (cnt--)
		*d++ = (UINT8)val;
}

/* 00:0a43: up to 16 more directory entries into the table */
void DirList (void)
{
	FRESULT res;
	char *name;
	UINT8 slot, page;
	UINT8 n;

	n = 0;
	for (;;) {
		PsramPage(0);
		res = f_readdir(&wDir, &wFno);
		if (res != FR_OK || wFno.fname[0] == 0) {
			wDirEnd = 1;
			return;
		}
		if (wFno.fname[0] == '.')
			continue;
		name = *wFno.lfname ? wFno.lfname : wFno.fname;
		PsramPage(3);
		page = wEntryCount >> 5;
		slot = wEntryCount & 0x1F;
		*(UINT8 *)0x4000 = page + 0x12;
		if (wFno.fattrib == AM_DIR) {
			wEntries[slot].attr = AM_DIR;
			strcpy(wEntries[slot].name, name);
			n++;
			wEntryCount++;
		} else if ((wFno.fattrib & AM_ARC) == AM_ARC) {
			if (MemCmp_B0(name, "ezgb.dat", 8) == 0)
				continue;
			wEntries[slot].attr = AM_ARC;
			strcpy(wEntries[slot].name, name);
			n++;
			wEntryCount++;
		}
		if (n == 16)
			return;
	}
}

#ifdef UNMATCHED
/* Not matched yet (tools/match.py -D UNMATCHED): right frame, wrong from
   byte 45. Stock keeps top + row in a spill slot (sp+8) that it reuses for
   slot * 255, names page and slot (sp+12, sp+13), and writes $4000 after
   both; no source form tried so far gets SDCC to share the slot. */

/* 00:0bd1: scroll the name of entry top + row when it is too long for its
   line, once tick is past 20 */
void DrawDirEntryLabel (UINT32 tick, UINT16 top, UINT16 row)
{
	UINT16 pos;
	UINT16 ofs;
	UINT8 len, width;

	if (tick <= 20)
		return;
	color(3, 2, 0);
	ofs = top + row;
	*(UINT8 *)0x4000 = (ofs >> 5) + 0x12;
	len = strlen(wEntries[ofs & 0x1F].name);
	if (wEntries[ofs & 0x1F].attr == AM_DIR)
		width = 17;
	else
		width = 20;
	if (width >= len)
		return;
	pos = ((tick - 20) >> 1) % len;
	if (wMarqueePos == pos)
		return;
	wMarqueePos = pos;
	strncpy(wLabelBuf, wEntries[ofs & 0x1F].name + pos, 254);
	CStrCat_B1(wLabelBuf, "   ");
	strncpy(wLabelBuf + strlen(wLabelBuf), wEntries[ofs & 0x1F].name, 128 - strlen(wLabelBuf));
	DrawString(wLabelBuf, width, 0, row + 2);
}
#endif
