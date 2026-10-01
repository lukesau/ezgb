/* 12px HELP pane (docs/tab-strip12.md "HELP pane").
 *
 * Bank 8, injected at 08:7d00. DrawFwVersionScreen_drawChrome (08:70e1) now
 * starts with `jp HelpHook` (08:7b40): in 8px mode the hook replays the
 * displaced `ld hl,$0000` and continues in the stock code (which ends in
 * DrawHelpModVersion); in 12px mode it calls this function with the stock
 * routine's version buffer ("FW" + one or two digits, blank-padded, then
 * " K1.05e") and jumps to the stock wait loop (08:7141).
 *
 * The five lines of the 8px pane, in the 12px font, on DrawString12's
 * pixel-y rows from x 4:
 *
 *   y 24  FW5 K1.05e-0731          (the 8px pane's "ver:" label is dropped)
 *   y 44  www.ezflash.cn
 *   y 64  MOD 5.1
 *   y 84  github.com/lukesau/
 *   y 96  ezgb
 *
 * The strings are the stock ones and DrawHelpModVersion's (the kernel text
 * and the stamped MODSTR), so nothing is duplicated; they live in bank 8,
 * out of the bank-2 renderer's reach, and are copied to the stack first.
 * The tab drawer has already cleared the canvas.
 *
 *   python3 tools/inject.py src/help12.c $V 8 7d00 Help12 \
 *       --pin FarCallDrawString12=05c0 --pin StoreDrawParams=2791 \
 *       --pin HelpUrlStr=715a --pin HelpKStr=7af4 --pin HelpModStr=7aff \
 *       --pin HelpGitStr=7b09 --replace --apply
 */

typedef unsigned char u8;

extern void FarCallDrawString12(const u8 *s, u8 len, u8 col, u8 row);   /* 00:05c0 -> 02:7500 */
extern void StoreDrawParams(u8 color, u8 colorB, u8 op);                /* 00:2791 */
extern const u8 HelpUrlStr[];      /* 08:715a "www.ezflash.cn" */
extern const u8 HelpKStr[];        /* 08:7af4 kernel text, 11 bytes */
extern const u8 HelpModStr[];      /* 08:7aff MODSTR, 10 bytes */
extern const u8 HelpGitStr[];      /* 08:7b09 "github.com/lukesau/ezgb", 23 bytes */

#define X0 4

static void line(const u8 *s, u8 n, u8 y);

/* The entry point stays the first function in the file. */
void Help12(const u8 *fw) {
    u8 buf[24];
    u8 i, k;

    StoreDrawParams(3, 0, 0);
    /* no "ver:" label here: with the fixed-width digits the full line
     * would reach the right edge (159 px from x 4) */
    buf[0] = fw[0]; buf[1] = fw[1]; buf[2] = fw[2];
    k = 3;
    if (fw[3] != ' ') buf[k++] = fw[3];
    buf[k++] = ' ';
    for (i = 0; i < 11; i++) buf[k++] = HelpKStr[i];
    buf[k] = 0;
    FarCallDrawString12(buf, 0, X0, 24);
    line(HelpUrlStr, 14, 44);
    line(HelpModStr, 10, 64);
    line(HelpGitStr, 19, 84);          /* "github.com/lukesau/" */
    line(HelpGitStr + 19, 4, 96);      /* "ezgb": nothing under the first row's g */
}

static void line(const u8 *s, u8 n, u8 y) {
    u8 buf[20];
    u8 i;

    for (i = 0; i < n; i++) buf[i] = s[i];
    buf[n] = 0;
    FarCallDrawString12(buf, 0, X0, y);
}
