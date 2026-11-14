/* The card's list of names to hide (docs/browser-hide-filter.md).
 *
 * /.ezgbhide in the card's root names files and folders the browser leaves
 * out, on top of the ones built into browser_hide.c. It is named like the
 * plays file, /.ezgbplays (play_file.c), and hidden by its leading dot the
 * same way. Plain text, one name a line, any case:
 *
 *   RTS            a file or folder with exactly this name, in any folder
 *   *.bak          any name with this ending
 *   # a comment    (blank lines are skipped too)
 *
 * Bank 14, injected at 0E:5000, far-called through HideLoadFar (08:7b80) by
 * BrowserSortAll (browser_sort.c) before it lists a folder. The first 512
 * bytes of the file are read into ezcfg's sector scratch ($d800) and packed
 * into the loader's scratch ($c0a0, 512 bytes, which nothing writes while a
 * folder is listed) in the shape of browser_hide.c's table: 'H', 'L', then
 * for each name a length byte (bit 7 = the whole name must match) and the
 * name in lowercase, ended by a zero length. browser_hide.c reads it there,
 * and trusts it only behind the 'H', 'L': the scratch belongs to whatever
 * ran last (the loader, the save manager, the text viewer), so it is packed
 * again for every listing, and without the file the mark is cleared.
 *
 * Every FatFs call is preceded by a VBlank wait and FPGA page 0, as ezcfg
 * does. DirList maps what it needs itself afterwards.
 *
 *   python3 tools/inject.py src/hide_list.c $V 14 5000 HideLoad \
 *       --pin FarCall_06_7309=1926 --pin FarCall_06_779a=1941 \
 *       --pin FarCall_03_768f=19a1 --pin WaitVBlankFlag=0688 --apply
 */

#include "types.h"

extern u8 FarCall_06_7309(u8 *fp, const u8 *path, u8 mode);         /* f_open  00:1926 */
extern u8 FarCall_06_779a(u8 *fp, u8 *buf, u16 btr, u16 *br);       /* f_read  00:1941 */
extern u8 FarCall_03_768f(u8 *fp);                                  /* f_close 00:19a1 */
extern void WaitVBlankFlag(void);                                   /* 00:0688 */

#define FIL_OBJ  ((u8 *)0xCA0F)          /* kernel FIL, idle in the browser */
#define SRC      ((u8 *)0xD800)          /* ezcfg's 512-byte sector scratch */
#define TAB      ((u8 *)0xC0A0)          /* the loader's 512-byte scratch: the packed list */
#define PATH     ((u8 *)0xDB00)          /* FL_SCR, 16: f_open wants the path in WRAM */
#define TAB_MAX  500                     /* leaves room for a last name and the end mark */
#define FA_READ  0x01

static void sd(void);

/* The entry point stays the first function in the file. Reached through the
 * `call`ed stub at 08:7b80: three pad parameters. */
void HideLoad(u16 far_pad_thunk, u16 far_pad_af, u16 far_pad_ret) {
    static const u8 name[11] = {'/','.','e','z','g','b','h','i','d','e',0};
    u16 br, i, o, s;
    u8 c, n, f;

    (void)far_pad_thunk;
    (void)far_pad_af;
    (void)far_pad_ret;
    TAB[0] = 0;
    for (n = 0; n < 11; n++) PATH[n] = name[n];
    sd();
    if (FarCall_06_7309(FIL_OBJ, PATH, FA_READ)) return;
    br = 0;
    sd();
    if (FarCall_06_779a(FIL_OBJ, SRC, 512, &br)) br = 0;
    sd();
    FarCall_03_768f(FIL_OBJ);

    o = 2;
    i = 0;
    while (i < br && o < TAB_MAX) {
        /* one line: s = where its length byte goes, n = characters kept */
        while (i < br && (SRC[i] == ' ' || SRC[i] == '\t')) i++;
        f = 0x80;
        if (i < br && SRC[i] == '*') {
            f = 0;
            i++;
        }
        s = o++;
        n = 0;
        if (i < br && SRC[i] == '#') f = 0xFF;      /* a comment: read to the line's end, keep nothing */
        for (; i < br; i++) {
            c = SRC[i];
            if (c == '\n') {
                i++;
                break;
            }
            if (c == '\r' || f == 0xFF || n == 127 || o >= TAB_MAX + 8) continue;
            if (c >= 'A' && c <= 'Z') c += 32;
            TAB[o++] = c;
            n++;
        }
        while (n && (TAB[o - 1] == ' ' || TAB[o - 1] == '\t')) {
            o--;
            n--;
        }
        if (n == 0 || f == 0xFF) o = s;             /* nothing on the line */
        else TAB[s] = f | n;
    }
    TAB[o] = 0;
    TAB[1] = 'L';
    TAB[0] = 'H';
}

static void sd(void) {
    WaitVBlankFlag();
    *(volatile u8 *)0x7F00 = 0xE1;
    *(volatile u8 *)0x7F10 = 0xE2;
    *(volatile u8 *)0x7F20 = 0xE3;
    *(volatile u8 *)0x7FC0 = 0;
    *(volatile u8 *)0x7FF0 = 0xE4;
}
