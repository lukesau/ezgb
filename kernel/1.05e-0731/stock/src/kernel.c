/* The kernel's own C in bank 0, from $07BC. Function names are kernel.sym's;
   the GBDK calls are GBDK 2.96a's library (gbdk/include), built with
   BYTE_IS_UNSIGNED so its types and FatFs's agree. */

#include "kernel.h"

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
		SetFpgaPageAlt_B4(0);
		res = f_readdir(&wDir, &wFno);
		if (res != FR_OK || wFno.fname[0] == 0) {
			wDirEnd = 1;
			return;
		}
		if (wFno.fname[0] == '.')
			continue;
		name = *wFno.lfname ? wFno.lfname : wFno.fname;
		SetFpgaPageAlt_B4(3);
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

/* 00:0bd1: scroll the name of entry top + row when it is too long for its
   line, once tick is past 20 */
void DrawDirEntryLabel (UINT32 tick, UINT16 top, UINT16 row)
{
	UINT8 width, len, slot, page;
	UINT16 pos;

	if (tick <= 20)
		return;
	color(3, 2, 0);
	page = (top + row) / 32;
	slot = (top + row) % 32;
	*(UINT8 *)0x4000 = page + 0x12;
	len = strlen(wEntries[slot].name);
	if (wEntries[slot].attr == AM_DIR)
		width = 17;
	else
		width = 20;
	if (width >= len)
		return;
	pos = ((tick - 20) >> 1) % len;
	if (wMarqueePos != pos) {
		wMarqueePos = pos;
		strncpy(wLabelBuf, wEntries[slot].name + pos, 254);
		CStrCat_B1(wLabelBuf, "   ");
		strncpy(wLabelBuf + strlen(wLabelBuf), wEntries[slot].name, 128 - strlen(wLabelBuf));
		DrawString(wLabelBuf, width, 0, row + 2);
	}
}

#ifdef UNMATCHED
/* Not matched yet (tools/match.py -D UNMATCHED). The code is right but
   SDCC allocates registers differently: stock spills res to the stack
   (sp+$16) and loads &wFno for memset into bc, where this keeps res in c
   for the whole function and rematerializes &wFno. Until it matches,
   $0de4-$16f4 stays disassembly and the functions after it are in
   kernel2.c. */

/* 00:0de4: mount the card, offer the save backup, then the file browser */
void SdMenuMain (void)
{
	UINT8 res, row;
	UINT16 top;
	UINT8 redraw, save;
	UINT16 i;
	UINT8 mode;
	UINT32 tick;
	char *name;
	UINT8 flag, len, page, slot;
	UINT8 keys;
	char *p, *ext;

	wEntries = (ENTRY *)0xA000;
	res = f_mount(&wFatFs, "", 1);
	if (res) {
		DrawString("Micro SD initial error!", 20, 0, wDebugTextRow);
		while (1)
			;
	}
	DrawString("Micro SD initial OK!", 20, 0, wDebugTextRow);
		*(volatile UINT8 *)0x4000 = 0x11;
	SetFpgaPageAlt_B4(3);
		if (*(volatile UINT8 *)0xA000 == 0xAAU) {
				flag = *(volatile UINT8 *)0xA200;
				wD3F6 = *(volatile UINT8 *)0xA202;
				save = *(volatile UINT8 *)0xA001;
				*(volatile UINT8 *)0xA000 = 0;
				len = *(volatile UINT8 *)0xA00F;
		for (i = 0; i < len; i++)
			wTmp[i] = *(UINT8 *)(0xA010 + i);
		wTmp[len] = 0;
		SetFpgaPageAlt_B4(0);
		fs_mkdir("/SAVER");
		BackupSavePrompt(save, flag);
	}
		*(volatile UINT8 *)0x4000 = 0;
	SetFpgaPageAlt_B4(0);
	memset(wPath, 0, 255);
	wPath[0] = '/';

browse:
	wDebugTextRow = 0;
	wDebugTextCol = 0;
	mode = 0;
	wDirEnd = 0;
	DrawReadingBox();
	SetFpgaPageAlt_B4(0);
	res = f_chdir(wPath);
	if (res)
		FileSystemErrorHang();
	wEntryCount = 0;
	res = f_opendir(&wDir, wPath);
	if (res)
		FileSystemErrorHang();
	memset(wLabelBuf, 0, 255);
	memset(&wFno, 0, sizeof(FILINFO));
	wFno.lfname = wLabelBuf;
	wFno.lfsize = 254;
	DirList();
	row = 0;
	top = 0;
	redraw = 1;
	tick = 0;
	Bank8_7169(0);
	Bank8_7169(3);
	for (;;) {
		tick++;
		if (redraw) {
			tick = 0;
			if (redraw == 1) {
				SetFpgaPageAlt_B4(3);
				DrawBrowserEntries(top, row);
			} else if (redraw > 1) {
				SetFpgaPageAlt_B4(3);
				DrawBrowserDetail(top, row, redraw);
			}
		}
		if (wEntryCount)
			DrawDirEntryLabel(tick, top, row);
		redraw = 0;
		delay(45);
		keys = joypad();
		if (keys & J_LEFT) {
			if (top) {
				if (top > 15)
					top -= 16;
				else
					top = 0;
				redraw = 1;
			} else if (row) {
				row = 0;
				redraw = 1;
			}
		} else if (keys & J_RIGHT) {
			if (!wDirEnd)
				DirList();
			if (top + 16 < wEntryCount) {
				if (wEntryCount >= top + 32)
					top = top + 16;
				else
					top = wEntryCount - 16;
				redraw = 1;
			}
		} else if (keys & J_UP) {
			if (row) {
				row--;
				redraw = 3;
			}
		} else if (keys & J_DOWN) {
			if (row + 1 < wEntryCount && row < 15) {
				row++;
				redraw = 2;
			}
		} else if (keys & J_SELECT) {
			mode++;
			if (mode == 2) {
				mode = 0;
			} else if (mode == 1) {
				Bank8_7169(1);
				DrawTimeAutosaveScreen();
				mode = 2;
			}
			if (mode == 2) {
				Bank8_7169(2);
				DrawFwVersionScreen();
				delay(50);
				goto browse;
			}
		} else if (keys & J_START) {
			DrawLastRomButtons();
			*(UINT8 *)0x4000 = 0x11;
			SetFpgaPageAlt_B4(3);
			for (i = 0; i < 255; i++)
				wLabelBuf[i] = *(UINT8 *)(0xA300 + i);
			*(UINT8 *)0x4000 = 0;
			SetFpgaPageAlt_B4(0);
			name = strrchr(wLabelBuf, '/') + 1;
			DrawString(name, 20, 0, 15);
			for (;;) {
				keys = joypad();
				if (keys & J_A) {
					memcpy(wPath, wLabelBuf, name - wLabelBuf - 1);
					f_chdir(wPath);
					strcpy(wLabelBuf, name);
					DrawLoadingBox();
					goto launch;
				}
				if (keys & J_B)
					goto browse;
			}
		} else if (keys & J_A) {
			page = (top + row) / 32;
			slot = (top + row) % 32;
			*(UINT8 *)0x4000 = page + 0x12;
			if (wEntries[slot].attr == AM_DIR) {
				res = CStrCmp(wPath, "/");
				if (res)
					CStrCat_B1(wPath, "/");
				CStrCat_B1(wPath, wEntries[slot].name);
				goto browse;
			}
			DrawLoadingBox();
			MemSet8_B0(wLabelBuf, 0, 255);
			strcpy(wLabelBuf, wEntries[slot].name);
			ext = strrchr(wLabelBuf, '.');
			memcpy(wTmp, ext, 5);
			if (wTmp[1] >= 'a' && wTmp[1] <= 'z')
				wTmp[1] -= 32;
			if (wTmp[2] >= 'a' && wTmp[2] <= 'z')
				wTmp[2] -= 32;
			if (wTmp[3] >= 'a' && wTmp[3] <= 'z')
				wTmp[3] -= 32;
			if (MemCmp_B0(wTmp, ".GBC", 5) && MemCmp_B0(wTmp, ".GB", 4)) {
				DrawErrorFileBox();
				for (;;)
					if (joypad() & J_B)
						goto browse;
			}
			{
				LoaderPrepPath();
launch:
				res = RomLoaderMain(wLabelBuf);
				if (res == 0xFF) {
					WaitJoypadSelect();
					goto browse;
				}
				if (wD3EF)
					BackupOpenSaverPath(wLabelBuf, 0x2000);
				LaunchSetup(wLabelBuf);
				SetFpgaPageAlt_B4(2);
				SetFpga7F37_B4((wD3F0 << 7) | wD3EB);
				SetFpga7FD4_B1(0);
				SetFpga7FC4_B4(wD3ED);
				SetFpgaRomSize_B4(wD3EC);
				SetFpga7FC3_B4();
				display_off();
				disable_interrupts();
				RomLoad_CopyCmdWindowPoll_B4((UINT8 *)0xC0A0, res);
				while (1)
					;
			}
		} else if (keys & J_B) {
			if (CStrCmp(wPath, "/")) {
				memcpy(wTmp, wPath, 255);
				p = strrchr(wTmp, '/');
				memset(wPath, 0, 255);
				memcpy(wPath, wTmp, p - wTmp);
				if (!wPath[0])
					wPath[0] = '/';
				goto browse;
			}
		}
		wait_vbl_done();
	}
}
#endif
