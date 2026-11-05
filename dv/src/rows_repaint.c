/* ezgb-dv: draw the list rows a scroll or a wrap uncovers, the selection bar
 * first. dv/build.py places it at 04:7d60 (bank 4's free tail, after
 * ShiftRows) and points RepaintRowsStub (00:3eba) at it.
 *
 * ezjr_scroll.c calls it, through the stub, for every move that shows new
 * entries. A scroll of k rows (1 to 4; going down the bar is on row 9, going
 * up on row 0): the window moves k entries, ShiftRows (bank4_rows.asm) moves
 * the 9 - k rows that stay in VRAM, and the k rows next to the bar are drawn
 * with it (going down, rows 9-k..9; going up, 0..k). A wrap on a list longer
 * than a page, with the window and the bar already where they go: k = 9, all
 * ten rows. Either way the bar's row comes first, so the cursor is at its
 * new place from the start (the stock full repaint drew top to bottom, so
 * after UP on the first entry the bar was missing until the last row), then
 * for a wrap the row at the other end, where the old bar still shows, then
 * the others away from the bar, then the counter. The stock paths (dirty 1 to 3)
 * went through DrawBrowserEntries / DrawBrowserDetail, which draw a row the
 * same way: the entry's record from its pSRAM page, DrawNameWithIcon with
 * len 0 for a folder, $14 for a file.
 *
 * It then leaves the state as the stock repaint does: nothing dirty, and the
 * 32-bit marquee tick (st - 8, see browser_scroll_repaint.c) zeroed.
 *
 * Reached through a `call`ed stub, so FarCallTrampoline's three words sit
 * between its return address and the arguments: three pad parameters.
 */

typedef unsigned char u8;
typedef unsigned int u16;

struct BrowserScrollState {
    u8 dirty;
    u16 base;
    u8 sel;
};

extern void ShiftRows(u8 dst_y, u8 src_y, u8 batches, signed char step);   /* bank4_rows.asm */
extern void StoreDrawParams(u8 ink, u16 paper);                       /* 00:2791 */
extern void DrawNameWithIcon(const u8 *s, u8 len, u8 x, u8 y);        /* 00:3ec8 -> 02:6b80 */
extern void CounterDigitsStub(unsigned long v, u8 *buf, u8 radix);    /* 00:3eb2 -> 02 CounterDigits */
extern void TabNum12(const u8 *s, u8 len, u8 x, u8 y);                /* 00:0380 -> 02 TabNumFar */

#define ROWS 10
#define LIST_Y 20                       /* pixel y of list row 0 */
#define UP_DST_Y 136                    /* going up, bottom first: the last 4-pixel-row group lands at y 136..139 */
#define RAM_BANK (*(volatile u8 *)0x4000)
#define WIN ((const u8 *)0xa000)
#define REC_BANK_BASE 0x12              /* 32 records of 255 bytes a page */
#define ATTR_OFS 254
#define ATTR_DIR 0x10

static void draw_row(u16 base, u8 n, u8 bar);

/* The entry point stays the first function in the file. */
void RepaintRows(u16 far_pad_thunk, u16 far_pad_af, u16 far_pad_ret, struct BrowserScrollState *st, u8 k, u8 up) {
    volatile u8 *tick = (volatile u8 *)st - 8;
    u16 base;
    u8 sel = st->sel, n, d, b, lo, hi;
    u8 buf[5];

    (void)far_pad_thunk;
    (void)far_pad_af;
    (void)far_pad_ret;
    if (k < ROWS - 1) {
        d = (u8)((k << 3) + (k << 2));          /* k * ROW_H */
        b = (u8)(27 - k - k - k);               /* 9 - k rows, 3 groups of 4 pixel rows each */
        if (up) {
            st->base -= k;
            ShiftRows(UP_DST_Y, (u8)(UP_DST_Y - d), b, -4);     /* rows 9-k..1 -> 9..1+k */
        } else {
            st->base += k;
            ShiftRows(LIST_Y, (u8)(LIST_Y + d), b, 4);          /* rows k..8 -> 0..8-k */
        }
    }
    base = st->base;
    /* SetFpgaPageAlt_B4 (04:41e7) inlined, as browser_scroll_repaint.c does:
     * the record reads need the pSRAM window on page $03 */
    *(volatile u8 *)0x7f00 = 0xe1;
    *(volatile u8 *)0x7f10 = 0xe2;
    *(volatile u8 *)0x7f20 = 0xe3;
    *(volatile u8 *)0x7fc0 = 0x03;
    *(volatile u8 *)0x7ff0 = 0xe4;

    /* the plain rows: 1..k with the bar on row 0, 9-k..8 with it on row 9 */
    if (sel == 0) {
        lo = 1;
        hi = k;
    } else {
        lo = (u8)(ROWS - 1 - k);
        hi = ROWS - 2;
    }
    draw_row(base, sel, 1);
    if (k == ROWS - 1) {                        /* a wrap: the old bar is on the other end row, so that one next */
        if (sel == 0) {
            draw_row(base, ROWS - 1, 0);
            hi = ROWS - 2;
        } else {
            draw_row(base, 0, 0);
            lo = 1;
        }
    }
    if (sel == 0) {
        for (n = lo; n <= hi; n++) {            /* away from the bar: downwards */
            draw_row(base, n, 0);
        }
    } else {
        for (n = (u8)(hi + 1); n != lo;) {      /* ...upwards */
            draw_row(base, --n, 0);
        }
    }
    StoreDrawParams(3, 0x0000);
    CounterDigitsStub((unsigned long)(base + sel + 1), buf, 10);
    TabNum12(buf, 0, 0, 0);
    tick[0] = 0;
    tick[1] = 0;
    tick[2] = 0;
    tick[3] = 0;
    st->dirty = 0;
}

/* Row n of the window (entry base + n), in the bar's colors or plain. */
static void draw_row(u16 base, u8 n, u8 bar) {
    u16 idx = base + n;
    u8 slot = (u8)idx & 31;
    const u8 *rec;

    RAM_BANK = (u8)(REC_BANK_BASE + (u8)(idx >> 5));
    rec = WIN + (((u16)slot << 8) - slot);      /* slot * 255 */
    if (bar) {
        StoreDrawParams(0, 0x0001);             /* ink 0 on paper 1: the bar */
    } else {
        StoreDrawParams(3, 0x0000);
    }
    DrawNameWithIcon(rec, rec[ATTR_OFS] == ATTR_DIR ? 0 : 0x14, 0, (u8)(n + 2));
}
