/* ezgb-dv: DOWN/UP in the file browser, with wrap-around.
 *
 * Replaces browser_scroll.c's DOWN entry (00:3ed0) and the UP code the hook at
 * 00:02f0 calls (00:3fbb), which become 8-byte far stubs (`cd 8d 07 <addr> 05 00 c9`) into this bank-5 block.
 * Reached through a `call`ed stub, so FarCallTrampoline's three words sit
 * between the caller's return and the argument: three pad parameters.
 *
 * 12px only (10 rows). The whole directory is enumerated before the first
 * draw (browser_sort.c), so the old "stream another DirList batch" fallback is
 * gone. DOWN on the last entry goes to the top; UP on the first goes to the
 * last, with the window on the final page.
 *
 * A scroll (the cursor on the bottom row going down, or the top row going
 * up) used to set dirty 1 and redraw all ten rows. Now RepaintRows
 * (rows_repaint.c, bank 4, through RepaintRowsStub at 00:3eba) moves the
 * window, has ShiftRows move the pixels of the rows that stay in VRAM, and
 * draws the rows it uncovers, the bar's row first, and the counter. A key held for a
 * while scrolls by more rows at a time (step_rows: 1, 2, 3, then 4), each
 * step costing a little more than one row does, so the list keeps pace with
 * the cursor's speed inside the page instead of dropping to one row at a
 * time when it reaches the edge.
 *
 * A move that keeps the window (a row down or up, or a wrap on a list that
 * fits one page) draws no text at all: MoveHighlight (move_highlight.c, bank
 * 2, through MoveHighlightStub at 00:3e9c) recolors the old and the new row
 * in VRAM, draws the counter and leaves dirty 0. It declines when the bar's
 * long name has scrolled since the last move; then the move goes to the
 * stock repaint as before (dirty 2 or 3, or 1 for a wrap, whose rows are not
 * next to each other). Every move leaves all rows showing their names from
 * the start, so afterwards the marquee's last index goes back to its boot
 * value, which is how MoveHighlight tells. A wrap on a longer list shows ten
 * new entries: RepaintRows draws all of them, starting with the bar's row.
 *
 * Key repeat. The browser reports a held D-pad key on every pass of its
 * loop, and the stock loop had no repeat delay of its own: a move simply
 * took long enough (about 13 frames) that a tap was over before the next
 * pass. A recolored move takes about 2, so a tap could move twice. Now a
 * press moves at once, and a key that was already down at the previous poll
 * (RomMenuPadTrack keeps that report at $fff5) moves again only after
 * REPEAT_DELAY frames, then every REPEAT_RATE, one frame quicker every
 * 1 << RAMP_SHIFT repeats down to REPEAT_FAST. While UP or DOWN is held the loop
 * also skips the stock 45 ms delay at its top (BrowserDelay,
 * dv/asm/bank0_browser.asm), so the pace is these frame counts and the time
 * a move takes, whichever is longer.
 */
#define ROWS 10
#define ENTRY_COUNT (*(volatile unsigned int *)0xc2a2)
#define MQ_LAST (*(volatile unsigned int *)0xcc31)   /* DrawDirEntryLabel's last drawn index */
#define MQ_CLEAN 0xEEEE                              /* its boot value: nothing scrolled */
__sfr __at(0xfff5) PAD_PREV;                           /* RomMenuPadTrack: the previous poll's report (HRAM, __sfr so that SDCC uses ldh) */
__sfr __at(0xfffa) HFRAME;                             /* +1 per VBlank */
__sfr __at(0xfff2) HOLD_T;                             /* hFrame at the press, moved on at each repeat (HRAM no code uses) */
#define PAD_UP   0x04
#define PAD_DOWN 0x08
__sfr __at(0xfff4) REP_N;                              /* repeats since the press, up to RAMP_N (HRAM no code uses) */
#define REPEAT_DELAY 18                              /* frames held before the first repeat (0.3 s) */
#define REPEAT_RATE  6                               /* frames between the first repeats (10 a second) */
#define REPEAT_FAST  3                               /* ...and the last (20 a second) */
#define RAMP_SHIFT   1                               /* 1 << RAMP_SHIFT repeats at each rate on the way */
#define RAMP_N ((REPEAT_RATE - REPEAT_FAST) << RAMP_SHIFT)

struct BrowserScrollState {
    unsigned char dirty;            /* 0 none, 1 full page, 2 row-down, 3 row-up */
    unsigned int base;              /* first visible entry */
    unsigned char sel;              /* row within the window */
};

extern unsigned char MoveHighlightStub(struct BrowserScrollState *st, unsigned char to);  /* 00:3e9c -> 02 MoveHighlight */
extern void RepaintRowsStub(struct BrowserScrollState *st, unsigned char k, unsigned char up);  /* 00:3eba -> 04 RepaintRows */

/* Rows to scroll by: 1 for a press, then 1 1 2 2 3 3 4 ... as the repeats
 * go on (REP_N, counted by repeat_ok before the move). */
static unsigned char step_rows(void) {
    return (unsigned char)((REP_N >> RAMP_SHIFT) + 1);
}

/* The bar to row `to` of the same window: recolored, or the stock repaint. */
static void move_in_page(struct BrowserScrollState *st, unsigned char to, unsigned char dirty) {
    if (!MoveHighlightStub(st, to)) {
        st->sel = to;
        st->dirty = dirty;
    }
}

static void down(struct BrowserScrollState *st) {
    unsigned int base = st->base, left;
    unsigned char sel = st->sel, k;

    if (base + sel + 1 >= ENTRY_COUNT) {
        if (base == 0) {                /* the whole list is on the page */
            move_in_page(st, 0, 1);
            return;
        }
        st->base = 0;
        st->sel = 0;
        RepaintRowsStub(st, ROWS - 1, 0);                   /* all ten rows */
        return;
    }
    if (sel + 1 < ROWS) {
        move_in_page(st, sel + 1, 2);
        return;
    }
    k = step_rows();
    left = ENTRY_COUNT - base - ROWS;   /* entries below the window, at least 1 here */
    if (k > left) {
        k = (unsigned char)left;
    }
    RepaintRowsStub(st, k, 0);
}

static void up(struct BrowserScrollState *st) {
    unsigned char sel = st->sel, k;
    unsigned int n;

    if (sel != 0) {
        move_in_page(st, sel - 1, 3);
        return;
    }
    if (st->base != 0) {
        k = step_rows();
        if (k > st->base) {
            k = (unsigned char)st->base;
        }
        RepaintRowsStub(st, k, 1);
        return;
    }
    n = ENTRY_COUNT;
    if (n == 0) {
        return;
    }
    if (n <= ROWS) {                    /* the whole list is on the page */
        move_in_page(st, (unsigned char)(n - 1), 1);
        return;
    }
    st->base = n - ROWS;
    st->sel = ROWS - 1;
    RepaintRowsStub(st, ROWS - 1, 1);                       /* all ten rows */
}

/* 1 when this report of `key` should move: a press, or a key held for
 * REPEAT_DELAY frames, then after 6 6 5 5 4 4 3 3 ... frames (HOLD_T is set
 * so that the next repeat is `rate` frames on). */
static unsigned char repeat_ok(unsigned char key) {
    unsigned char now = HFRAME, n, rate;

    if (!(PAD_PREV & key)) {
        HOLD_T = now;
        REP_N = 0;
        return 1;
    }
    if ((unsigned char)(now - HOLD_T) < REPEAT_DELAY) {
        return 0;
    }
    n = REP_N;
    rate = REPEAT_FAST;
    if (n < RAMP_N) {
        rate = (unsigned char)(REPEAT_RATE - (n >> RAMP_SHIFT));
        REP_N = (unsigned char)(n + 1);
    }
    HOLD_T = (unsigned char)(now - (REPEAT_DELAY - rate));
    return 1;
}

void ezjr_scroll_down(unsigned int p0, unsigned int p1, unsigned int p2, struct BrowserScrollState *st) {
    (void)p0; (void)p1; (void)p2;
    if (repeat_ok(PAD_DOWN)) {
        down(st);
        MQ_LAST = MQ_CLEAN;
    }
}

void ezjr_scroll_up(unsigned int p0, unsigned int p1, unsigned int p2, struct BrowserScrollState *st) {
    (void)p0; (void)p1; (void)p2;
    if (repeat_ok(PAD_UP)) {
        up(st);
        MQ_LAST = MQ_CLEAN;
    }
}
