#ifndef __MAIN_H
#define __MAIN_H

#include <gb/gb.h>
#include "ff.h"	
#include "ui_text.h"		/* all fixed on-screen strings */

/* ---- portability shim: SDCC 2.9 / GBDK 3.0 -> SDCC 4.5 / GBDK-2020 ----
   BOOL was typedef'd in the old <asm/types.h>; GBDK-2020 only provides
   BOOLEAN. Keep the original signed 8-bit semantics.                  */
#ifndef __MAIN_BOOL_DEFINED
#define __MAIN_BOOL_DEFINED
typedef INT8 BOOL;
#endif


#define XIAOXIE(x) (x>='a' && x<='z') // is the byte a lowercase letter
#define ZHUANDAXIE(x) (x-'a'+'A') // to uppercase 



//#define MAX_files     100
//#define MAX_folder    100
#define MAX_filename_len  254

#define MAX_path_len  255


#define PAGE_num0  0
#define PAGE_num1  1
#define PAGE_num2  2


#define Folder_sram_bank  18
#define Filename_sram_bank  1
#define SAVE_info_sram_bank  17


#define Num_perBank 32

/* Rows per screen. The English build uses the 8x8 console font (16 rows), the
   zh build 12px glyphs (9 rows, see ui_zh.h). Every paging/boundary calculation
   below uses this macro - never hard-code 16. */
#ifdef LANG_ZH
#define LIST_ROWS   9
#else
/* mod: 16 rows in the 8px font and 10 in the 12px one (ezcfg.c sets it) */
extern UINT8 list_rows;
#define LIST_ROWS   list_rows
#endif
/*  in PSRAM
#define A000Address_TF 		0x0U
#define A000Address_PSRAM 0x1U
//#define A000Address_NOR		0x2U
#define A000Address_FATbuffer	0x2U
#define A000Address_SRAM	0x3U
*/
#define A000Address_TF 						0x0U
#define A000Address_PSRAM 				0x1U
#define A000Address_FATbuffer			0x2U
#define A000Address_SRAM					0x3U
#define A000Address_read_FPGA_ver	0x4U
#define A000Address_Read_SPI_state 0x5U
#define A000Address_RTC						0x6U


//#define FlashBase_S71	0x4000
#define FlashBase_S98	0xA000
#define FlashBase_SRAM	0xA000

#define Base_FATbuffer	0xA000
#define Base_RTCbuffer	0xA000


typedef struct FM_Folder_SECT{
	unsigned char filename[MAX_filename_len];	
} FM_Folder_FS;

typedef struct FM_FILE_SECT{
	unsigned char filename[MAX_filename_len];
	UINT8 fattrib;	
#ifdef LANG_ZH
	UINT32 fsize;			/* the size column (2M/128K) is only used by the zh build.
							      The English build keeps its layout, byte for byte. */
#endif
} FM_FILE_FS;


void Draw_Text(UINT8 *str, UINT8 len, UINT8 x, UINT8 y);
void Read_all_DIR(void) __banked;	/* mod: browser.c */
void battery_box(UINT8 erase) __banked;	/* mod: msgbox.c, BATTERY DRY */
void flaunch_box(void) __banked;	/* mod: msgbox.c, FAST LAUNCH was ticked */
void popup_rules(UINT8 row, UINT8 y1, UINT8 xv) __banked;	/* mod: msgbox.c, the rules of a two-button popup */
void msg_box(const UINT8 *text) __banked;	/* mod: msgbox.c, the small status box */
void Filename_loop(UINT32 shift,UINT16 show_offset,UINT16 file_select) __banked;	/* mod: list8.c */
void list_follow(UINT16 *show_offset, UINT8 *file_select) __banked;	/* mod: browser.c */
UINT8 name_shown(const FM_FILE_FS *e) __banked;	/* mod: browser.c, a name's length as the list draws it */
extern UINT8 tags_hide;		/* mod: CLEAN NAMES, ezcfg.c */
void Draw_SRAM_Text(UINT8 num_num, UINT8 isFolder, UINT8 x, UINT8 y);
void wait_select(void);				/* waits for SELECT (not B); see the note in main.c */

UINT32 ClustToSect(FATFS* fs,	UINT32 clst);
UINT32 Get_NextCluster(FATFS* fs,UINT32 clst);

extern UINT32 clust2sect (	FATFS* fs,	DWORD clst		)__banked;
extern UINT32 get_fat (FATFS* fs,	DWORD clst	)__banked;

FRESULT f_write_bank (FIL* fp,void *buff,	UINT btw,UINT* bw	);

#endif