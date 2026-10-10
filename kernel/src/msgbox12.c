/* Reading / Loading / Error file boxes in the 12px font (docs/tab-strip12.md
 * "Status boxes").
 *
 * Bank 8, injected at 08:7e80. The three stock drawers (DrawReadingBox
 * 08:7344, DrawLoadingBox 08:737f, DrawErrorFileBox 08:73ba) are the same
 * code with a different string: ink 0 on paper 3, a filled box
 * (35,37)-(125,108), ten characters at column 5 of tile row 8. Each now
 * starts with `jp MsgHook<n>` (08:7e10 / 7e24 / 7e38): 8px replays the
 * displaced `ld hl,$0003` and continues in the stock code; 12px calls this
 * function with n and returns.
 *
 * 12px: the same box, the same string on the 12px row at y 64 from x 44,
 * clipped at the box's right side so the row's paper stays inside it. The
 * strings are the stock ones, copied to the stack because the renderer runs
 * in bank 2. The draw state is left at 0 on 3, as the stock code leaves it.
 *
 *   python3 tools/inject.py src/msgbox12.c $V 8 7e80 MsgBox12 \
 *       --pin FarCallDrawString12=05c0 --pin DrawRect=27ba --pin StoreDrawParams=2791 \
 *       --pin hClip12=fff9 --pin ReadingStr=7374 --pin LoadingStr=73af --pin ErrorFileStr=73ea \
 *       --replace --apply
 */

typedef unsigned char u8;

extern void FarCallDrawString12(const u8 *s, u8 len, u8 col, u8 row);   /* 00:05c0 -> 02:7500 */
extern void DrawRect(u8 x0, u8 y0, u8 x1, u8 y1, u8 fill);          /* 00:27ba */
extern void StoreDrawParams(u8 color, u8 colorB, u8 op);            /* 00:2791 */
extern volatile u8 hClip12;                                         /* $fff9: DrawString12's right edge */
extern const u8 ReadingStr[];      /* 08:7374 "Reading..." */
extern const u8 LoadingStr[];      /* 08:73af "Loading..." */
extern const u8 ErrorFileStr[];    /* 08:73ea "Error file" */

void MsgBox12(u8 which) {
    u8 buf[12];
    const u8 *s;
    u8 i;

    s = which == 0 ? ReadingStr : which == 1 ? LoadingStr : ErrorFileStr;
    for (i = 0; i < 10 && s[i]; i++) buf[i] = s[i];
    buf[i] = 0;
    StoreDrawParams(0, 3, 0);
    DrawRect(0x23, 0x25, 0x7d, 0x6c, 1);
    hClip12 = 0x7d;
    FarCallDrawString12(buf, 0, 44, 66);     /* row >= 18: pixel y, rounded down to 64 */
    hClip12 = 0;
}
