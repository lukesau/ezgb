/* Declarations shared by the kernel's bank 0 C (kernel.c, kernel2.c). */
#ifndef KERNEL_H
#define KERNEL_H

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

/* not GBDK 2.96a's: EZ Flash's, as they are called */
void memset (void *dst, UINT8 c, UINT16 n);	/* Memset, 00:2ca5 */
char *strrchr (char *s, char c);		/* Strrchr, 00:2c42 */

/* banked, in other banks; kernel.sym's names */
void SetFpgaPageAlt_B4 (UINT8 page) __banked;
void CStrCat_B1 (char *dst, const char *src) __banked;
int CStrCmp (const char *a, const char *b) __banked;
void DrawReadingBox (void) __banked;
void DrawLoadingBox (void) __banked;
void DrawErrorFileBox (void) __banked;
void DrawLastRomButtons (void) __banked;
void DrawTimeAutosaveScreen (void) __banked;
void DrawFwVersionScreen (void) __banked;
void Bank8_7169 (UINT8 mode) __banked;		/* 08:7169, name ours */
void DrawBrowserEntries (UINT16 top, UINT16 row) __banked;
void DrawBrowserDetail (UINT16 top, UINT16 row, UINT8 code) __banked;
void BackupSavePrompt (UINT32 save, UINT8 flag) __banked;
void LoaderPrepPath (void) __banked;
UINT8 RomLoaderMain (char *path) __banked;
void BackupOpenSaverPath (char *path, UINT32 size) __banked;
void LaunchSetup (char *path) __banked;
void SetFpga7F37_B4 (UINT8 v) __banked;
void SetFpga7FD4_B1 (UINT8 v) __banked;
void SetFpga7FC4_B4 (UINT8 v) __banked;
void SetFpgaRomSize_B4 (UINT8 v) __banked;
void SetFpga7FC3_B4 (void) __banked;
void RomLoad_CopyCmdWindowPoll_B4 (UINT8 *cmd, UINT8 res) __banked;
FRESULT fs_mkdir (const TCHAR* path);

extern char wLabelBuf[];		/* $C4A4: marquee text, FILINFO lfname, ROM path */
extern char wPath[];			/* $C2A6: the browser's directory */
extern char wTmp[];			/* $C3A5: save name, extension, path scratch */
extern FATFS wFatFs;			/* $C7A9 */
extern UINT8 wD3EB, wD3EC, wD3ED, wD3EF, wD3F0;	/* launch settings */
extern UINT8 wD3F6;
extern UINT16 wMarqueePos;		/* $CC31: the offset last drawn */

extern UINT8 wDebugTextRow;		/* $CC2F: row of the next boot message */
extern UINT8 wDebugTextCol;		/* $CC30 */

void U32ToAscii_B0 (UINT32 v, char *buf, UINT8 radix);
void DrawString (char *s, UINT8 len, UINT8 x, UINT8 y);
void SdMenuMain (void);

void WaitJoypadSelect (void);
void FileSystemErrorHang (void);
int MemCmp_B0 (const void* dst, const void* src, UINT8 cnt);
void MemSet8_B0 (void* dst, int val, UINT8 cnt);
void DirList (void);
void DrawDirEntryLabel (UINT32 tick, UINT16 top, UINT16 row);

#endif
