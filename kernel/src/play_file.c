/* Stars and play counts on the SD card (docs/stars.md "On the card").
 *
 * The table lives in battery-backed pSRAM (play.c), which a cart without a
 * coin cell loses at every power-off. So it is mirrored in a file in the
 * card's root, /.ezgbplays: hidden from the browser and from stage1's kernel
 * picker by its leading dot, 2048 bytes, four sectors. File offset k is
 * pSRAM page $11 at $B7F8 + k, except bytes 4..7, which hold the SORT BY
 * PLAYS record ($A404, 'S', 'O', flag, ~flag):
 *
 *   0..3     'P', 'L', entries, stars        ($B7F8)
 *   4..7     the SORT BY PLAYS record        ($A404)
 *   8..2047  the entries, 8 bytes each       ($B800)
 *
 * Bank 11, injected at 0B:4700. Three far entries:
 *
 *   PlayLoad        ezcfg's boot restore (02:78b0 stub): a valid file
 *                   replaces the pSRAM table, so the card is the source of
 *                   truth and a batteryless cart starts with its history. No
 *                   file: pSRAM is kept (a cart with a battery carries its
 *                   table over, and the first sync writes the file).
 *   PlaySync        after a launch (PlayLaunchHook, 01:7ec6) and a SORT BY
 *                   PLAYS toggle (setpage.c): each sector of the file is read
 *                   and compared with pSRAM, and only a sector that differs
 *                   is written, so a launch writes one sector, a star two.
 *                   The file is written whole, and closed, only when it is
 *                   created; after that it keeps its size and clusters and
 *                   is not closed, so FatFs never rewrites its directory
 *                   entry. Whole aligned sectors only: this FatFs mishandles
 *                   partial-sector writes (ezcfg.c far_write).
 *   StarToggleSync  RomMenu's Star (the 04:59a0 stub): StarToggle (play.c,
 *                   bank 5), then PlaySync, then the cursor's record page
 *                   mapped again, as StarToggle leaves it.
 *
 * FatFs goes through the kernel's bank-0 wrappers with the kernel FIL at
 * $CA0F and ezcfg's sector buffer at $D800, both idle wherever these run;
 * every call is preceded by a VBlank wait and FPGA page 0, as ezcfg does.
 *
 *   python3 tools/inject.py src/play_file.c $V 11 4700 PlayLoad \
 *       --pin FarCall_06_7309=1926 --pin FarCall_06_779a=1941 \
 *       --pin FarCall_07_7739=1963 --pin FarCall_03_76cc=1985 \
 *       --pin FarCall_03_768f=19a1 --pin WaitVBlankFlag=0688 \
 *       --pin FarCallTrampoline=078d --apply
 */

#include "types.h"
#include "vars.h"

extern u8 FarCall_06_7309(u8 *fp, const u8 *path, u8 mode);         /* f_open  00:1926 */
extern u8 FarCall_06_779a(u8 *fp, u8 *buf, u16 btr, u16 *br);       /* f_read  00:1941 */
extern u8 FarCall_07_7739(u8 *fp, const u8 *buf, u16 btw, u16 *bw); /* f_write 00:1963 */
extern u8 FarCall_03_76cc(u8 *fp, u32 ofs);                          /* f_lseek 00:1985 */
extern u8 FarCall_03_768f(u8 *fp);                                  /* f_close 00:19a1 */
extern void WaitVBlankFlag(void);                                   /* 00:0688 */
extern void FarCallTrampoline(void);                                /* 00:078d */

#define FIL_OBJ  ((u8 *)0xCA0F)
#define BUF      ((u8 *)0xD800)
#define PATH     ((u8 *)0xDB00)          /* FL_SCR: f_open wants the path in WRAM */
#define RAM_BANK (*(volatile u8 *)0x4000)
#define HDR      ((volatile u8 *)0xB7F8)  /* page $11 */
#define SORT_REC ((volatile u8 *)0xA404)
#define SECTORS  4
#define FA_READ   0x01
#define FA_RW     0x03                   /* FA_READ | FA_WRITE, open existing: a sync reads each sector to compare */
#define FA_CREATE 0x0A                   /* FA_WRITE | FA_CREATE_ALWAYS */

static void open_path(void);
static void sd(void);
static void meta(void);
static u8 sector_byte(u8 s, u16 k);
static void put_byte(u8 s, u16 k, u8 v);
static void star_toggle(u8 *slot);
static void fpga(u8 page);
void PlaySync(u16 pad_thunk, u16 pad_af, u16 pad_ret);

void PlayLoad(u16 pad_thunk, u16 pad_af, u16 pad_ret) {
    u16 br, k;
    u8 s;

    (void)pad_thunk;
    (void)pad_af;
    (void)pad_ret;
    open_path();
    sd();
    if (FarCall_06_7309(FIL_OBJ, PATH, FA_READ)) return;
    for (s = 0; s < SECTORS; s++) {
        sd();
        if (FarCall_06_779a(FIL_OBJ, BUF, 512, &br) || br != 512) break;
        /* a header that is not ours, or out of range: leave pSRAM alone */
        if (s == 0 && (BUF[0] != 'P' || BUF[1] != 'L' || BUF[2] > 254 || BUF[3] > BUF[2])) break;
        meta();
        for (k = 0; k < 512; k++) put_byte(s, k, BUF[k]);
        RAM_BANK = 0;
        fpga(0);
    }
    sd();
    FarCall_03_768f(FIL_OBJ);
}

void PlaySync(u16 pad_thunk, u16 pad_af, u16 pad_ret) {
    u16 br, k;
    u8 s, same;

    (void)pad_thunk;
    (void)pad_af;
    (void)pad_ret;
    open_path();
    sd();
    if (FarCall_06_7309(FIL_OBJ, PATH, FA_RW)) {
        /* first time on this card: the whole file, then closed */
        sd();
        if (FarCall_06_7309(FIL_OBJ, PATH, FA_CREATE)) return;
        for (s = 0; s < SECTORS; s++) {
            meta();
            for (k = 0; k < 512; k++) BUF[k] = sector_byte(s, k);
            RAM_BANK = 0;
            sd();
            if (FarCall_07_7739(FIL_OBJ, BUF, 512, &br)) break;
        }
        sd();
        FarCall_03_768f(FIL_OBJ);
        return;
    }
    for (s = 0; s < SECTORS; s++) {
        sd();
        if (FarCall_03_76cc(FIL_OBJ, (u32)s << 9)) return;
        sd();
        if (FarCall_06_779a(FIL_OBJ, BUF, 512, &br) || br != 512) return;
        meta();
        same = 1;
        for (k = 0; k < 512; k++) {
            u8 v = sector_byte(s, k);
            if (BUF[k] != v) {
                BUF[k] = v;
                same = 0;
            }
        }
        RAM_BANK = 0;
        if (same) continue;
        sd();
        if (FarCall_03_76cc(FIL_OBJ, (u32)s << 9)) return;
        sd();
        if (FarCall_07_7739(FIL_OBJ, BUF, 512, &br)) return;
    }
    /* not closed: size and clusters are unchanged, and a close would
     * rewrite the directory entry for nothing */
    fpga(0);
}

/* The cursor's record page again after the sync, as StarToggle left it: base
 * word at slot+$0f plus the row at slot+$11, page $12 + entry / 32. */
void StarToggleSync(u16 pad_thunk, u16 pad_af, u16 pad_ret, u8 *slot) {
    (void)pad_thunk;
    (void)pad_af;
    (void)pad_ret;
    star_toggle(slot);
    PlaySync(0, 0, 0);
    fpga(3);
    RAM_BANK = (u8)(0x12 + (u8)((u16)(*(u16 *)(slot + 0x0f) + slot[0x11]) >> 5));
}

/* StarToggle, 05:7db8, through a `call`ed stub: its slot at sp+8 */
static void star_toggle(u8 *slot) __naked {
    (void)slot;
    __asm
	call	_FarCallTrampoline
	.dw	0x7db8
	.db	5, 0
	ret
    __endasm;
}

/* file offset s * 512 + k in pSRAM, page $11 mapped */
static u8 sector_byte(u8 s, u16 k) {
    if (s == 0 && k >= 4 && k < 8) return SORT_REC[k - 4];
    return HDR[((u16)s << 9) + k];
}

static void put_byte(u8 s, u16 k, u8 v) {
    if (s == 0 && k >= 4 && k < 8) SORT_REC[k - 4] = v;
    else HDR[((u16)s << 9) + k] = v;
}

static void open_path(void) {
    static const u8 name[12] = {'/','.','e','z','g','b','p','l','a','y','s',0};
    u8 i;
    for (i = 0; i < 12; i++) PATH[i] = name[i];
}

static void sd(void) {
    WaitVBlankFlag();
    fpga(0);
}

static void meta(void) {
    fpga(3);
    RAM_BANK = 0x11;
}

/* unlock, $7FC0 = page, commit */
static void fpga(u8 page) {
    *(volatile u8 *)0x7F00 = 0xE1;
    *(volatile u8 *)0x7F10 = 0xE2;
    *(volatile u8 *)0x7F20 = 0xE3;
    *(volatile u8 *)0x7FC0 = page;
    *(volatile u8 *)0x7FF0 = 0xE4;
}
