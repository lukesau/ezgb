#ifndef __BANK_FUN_H
#define __BANK_FUN_H
#include <gb/gb.h>
#include <gb/drawing.h>
#include "main.h"
#include "ff.h"	

    enum CartridgeTypes
    {
        CartridgeNoMBC,
        CartridgeMBC1,
        CartridgeMBC2,
        CartridgeMBC3,
        CartridgeMBC5,
        CartridgeMBC1Multi,
        CartridgeNotSupported
    };
    
extern FM_FILE_FS *pFilename_buffer;

extern FM_Folder_FS *pFolder_buffer;

extern UINT16 game_total_SD;
extern UINT16 folder_total;
extern UINT16 game_folder_total;
extern UINT8 SD_buffer[0x200];
/* _current_bank: declared by <gb/gb.h> in GBDK-2020 (extern volatile __sfr) */
extern FATFS EZcardFs;

extern void Show_filename(UINT16 show_offset,UINT16 file_select)__banked;

/* FatFs failure report: FRESULT + failing stage + failing sector (bank 1). */
extern void Show_error_info(UINT8 code, UINT8 stage, const char *path)__banked;
extern void Refresh_filename(UINT16 show_offset,UINT16 file_select,UINT8 updown)__banked;


extern void mystrcat(char *dst,const char *src)__banked;
extern UINT8 mystrcat_n(char *dst,const char *src,UINT16 cap)__banked;
extern int mystrcmp(const char *str1,const char *str2)__banked;
extern char *my_strrchr(const char *s, char c)__banked;


extern void _ultoa(unsigned long value, char *string, unsigned char radix) __banked;
extern void DrawHEX(unsigned long uc);


extern void LoadROM2PSRAM(UINT16 offsetRom)__banked;
extern UINT8 LoadSAVE2SRAM(TCHAR *pfilename,UINT32 filesize)__banked;
extern void Show_LOAD_info(UINT8 phase)__banked;
extern UINT32 Check_game_save_FAT(TCHAR *filename)__banked;
extern UINT8 GatherMetadata(TCHAR *pfilename)__banked;
extern void Show_SAVE_info(UINT32 readdata,UINT8 autosave)__banked;

extern void Test_SAVE(TCHAR *pfilename)__banked;
extern void Save_filename(void)__banked;
extern void Set_GBboy(UINT8 select)__banked;

extern FRESULT f_open_bank (FIL* fp,			const TCHAR* path,	BYTE mode);
extern FRESULT f_read_bank (FIL* fp, 		void* buff,		UINT btr,		UINT* br		);
extern FRESULT f_lseek_bank (FIL* fp,		DWORD ofs		);
extern FRESULT f_close_bank (FIL *fp		);
extern FRESULT f_mkdir_bank (TCHAR* path);

/* ---- recently played: /SAVER/RecentlyPlay_gb.txt ----
      Load borrows the list area (bank 18+) for the records, so the directory list
      is destroyed: re-read the directory when returning (goto refind_file). */
extern UINT8 Recently_Load(void)__banked;
/* Called before booting: append this path to /SAVER/RecentlyPlay_gb.txt (append only) */
extern void  Recently_Add(TCHAR *fullpath)__banked;
/* Called once at boot: write the record that failed last time */
extern void  Recently_Commit(void)__banked;
extern void  Show_recent_list(UINT8 count, UINT8 sel)__banked;
extern void  Show_recent_scroll(UINT8 count, UINT8 sel, UINT16 shift)__banked;

#endif