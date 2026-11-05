/* ezgb-dv: move the selection bar within the page by recoloring two rows in
 * VRAM instead of drawing their text. dv/build.py places it right after
 * bank2_hilite.asm's routines (02:7ecc).
 *
 * Bank 2, far target of the 8-byte stub MoveHighlightStub (00:3e9c), which
 * ezjr_scroll.c calls for every cursor move that keeps the window where it
 * is (a row down or up, or a wrap on a list that fits one page). The stub is
 * `call`ed, so FarCallTrampoline's three words sit between its return
 * address and the arguments: three pad parameters.
 *
 * The stock row move (dirty 2 or 3) drew both rows' names again through
 * DrawBrowserDetail, plus the size field, about 10 frames. Both rows already
 * show the right names, so the old row only goes back to plain and the new
 * one to the selection bar (UnhighlightRow / HighlightRow, bank2_hilite.asm,
 * about 0.4 frames each); then the counter is drawn the way
 * DrawBrowserDetail's epilogue does (TabNum12, 00:0380, "n/total") and the
 * state is left as the stock path leaves it: the new row selected, nothing
 * to repaint, and the 32-bit marquee tick (st - 8, see
 * browser_scroll_repaint.c) zeroed, its one side effect.
 *
 * The exception is a long name that has scrolled in the bar. The stock
 * marquee (DrawDirEntryLabel) keeps the index it last drew at MQ_LAST
 * ($cc31) and only writes it when it draws; a name that fits never gets
 * that far. ezjr_scroll.c puts the stock boot value $EEEE back after every
 * move, which leaves every row showing its name from the start, so while
 * MQ_LAST still reads $EEEE the old row is exact to recolor. Otherwise this
 * returns 0 without touching anything, and ezjr_scroll.c takes the stock
 * path, which draws both rows again. It also declines inside a DiNest
 * section, where the recolor's di / ei would end the section early (draw12.c
 * keeps to flush_rmw there for the same reason). Returns 1 when the move is
 * done.
 *
 * The position goes to TabNumFar as digits from Digits4 (bank2_hilite.asm),
 * which is also CounterDigits: DrawBrowserDetail's own conversion (the stock
 * repaint of two rows, used by a one-row scroll) took about 1.4 frames for a
 * number that is at most 416.
 */

typedef unsigned char u8;
typedef unsigned int u16;

struct BrowserScrollState {
    u8 dirty;
    u16 base;
    u8 sel;
};

extern void HighlightRow(u8 py);                                    /* bank2_hilite.asm */
extern void UnhighlightRow(u8 py);
extern void TabNum12(const u8 *s, u8 len, u8 x, u8 y);              /* 00:0380 -> TabNumFar (bank2_tabnum.asm) */
extern void Digits4(u16 n, u8 *buf);                                /* bank2_hilite.asm: 4 digits and a NUL */

#define MQ_LAST (*(volatile u16 *)0xcc31)   /* DrawDirEntryLabel's last drawn index */
#define MQ_CLEAN 0xEEEE                     /* the boot value: nothing scrolled since the last move */
#define INT_NEST (*(volatile u8 *)0xd6d0)   /* DiNest depth */

static u8 row_y(u8 row);

/* The entry point stays the first function in the file. */
u8 MoveHighlight(u16 far_pad_thunk, u16 far_pad_af, u16 far_pad_ret, struct BrowserScrollState *st, u8 to) {
    volatile u8 *tick = (volatile u8 *)st - 8;
    u8 buf[5];

    (void)far_pad_thunk;
    (void)far_pad_af;
    (void)far_pad_ret;
    if (MQ_LAST != MQ_CLEAN || INT_NEST) {
        return 0;
    }
    UnhighlightRow(row_y(st->sel));
    HighlightRow(row_y(to));
    tick[0] = 0;
    tick[1] = 0;
    tick[2] = 0;
    tick[3] = 0;
    st->sel = to;
    st->dirty = 0;

    /* the 1-based position as digits for TabNumFar, which adds "/total"
     * (the browser lists at most 416 entries) */
    Digits4(st->base + to + 1, buf);
    TabNum12(buf, 0, 0, 0);
    return 1;
}

/* Pixel y of list row `row` (0..9): 20 + 12 * row, without a multiply. */
static u8 row_y(u8 row) {
    return (u8)(20 + (u8)(row << 3) + (u8)(row << 2));
}
