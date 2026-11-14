/* DOWN and UP in the file browser (docs/browser.md).
 *
 * After davidesqalv's ezgb-dv fork, whose code this is: ezjr_scroll.c,
 * rows_repaint.c, move_highlight.c, bank2_hilite.asm, bank4_rows.asm and
 * bank2_tabnum.asm, in one block and fitted to this kernel: his are 12px and
 * one palette, these take either font and every theme.
 *
 * The list wraps at both ends. A move inside the page recolors two rows in
 * VRAM instead of drawing their names again. A scroll moves the rows that
 * stay in VRAM and draws only the ones it uncovers, the bar's row first. A
 * held key repeats after a pause and speeds up, and once the list scrolls it
 * moves up to 4 rows at a time. In 12px the entry number gains "/total".
 *
 * Bank 12, injected at 0C:4000. The table comes first, so the far stubs keep
 * their targets when the code changes:
 *
 *   0C:4000  NavDown    BrowserScrollDownHook, through the stub at 00:3d8c
 *   0C:4003  NavUp      BrowserScrollUpHook, through the stub at 00:3fa0
 *   0C:4006  TabNumFar  TabNum12 (00:0380) in 12px
 *
 * All three stubs are `call`ed, so the trampoline's three words sit between
 * the return address and the arguments: three pad parameters.
 *
 * Inside a page a selected row is the plain row with other colors, so it can
 * change look without its text being drawn. With g the row's glyph bits:
 *
 *   plain      plane 0 = plane 1 = g
 *   bar        plane 0 = plane 1 = ~g (ink 0 on paper 3)
 *   DV plain   as plain, except the blue icon: plane 0 clear in tile column 0
 *              and in bit 7 of tile column 1 (font12_dv.txt's icons, x 1..8)
 *   DV bar     plane 0 = ~g, plane 1 = 0 (ink 0 on paper 1, dv_params.c)
 *
 * Every theme draws the same indices and differs in the palette, so these
 * four cases are all of them. MoveBar declines when the bar's long name has
 * scrolled, or inside a DiNest section, where the sync's di / ei would end
 * the section early; the move then takes the stock repaint. The marquee keeps
 * the index it last drew at MQ_LAST and every move here puts the boot value
 * back, so that value says the old row is showing its name from the start.
 *
 * A group of 4 pixel rows of one tile column is 8 bytes inside one tile (row
 * tops are multiples of 4 in both fonts) and goes out in one VRAM window,
 * synced like draw12.c's blit_col1 (see the long comment there).
 *
 *   python3 tools/inject.py src/browser_nav.c $V 12 4000 BrowserNav \
 *       --pin GfxRowTable=2fbb --pin StoreDrawParams=2791 --pin DrawString=08b7 \
 *       --pin DrawNameWithIcon=3ec8 --pin FarCallDrawString12=05c0 --pin wIntNest=d6d0 \
 *       --pin wDrawOp=d723 --pin wDrawColorA=d734 --pin wDrawColorB=d735 --apply
 */

#include "types.h"
#include "draw.h"
#include "vars.h"

struct BrowserScrollState {
    u8 dirty;                       /* 0 none, 1 full page, 2 row-down, 3 row-up */
    u16 base;                       /* first visible entry */
    u8 sel;                         /* row within the window */
};

extern const u16 GfxRowTable[];     /* 00:2fbb pixel row -> VRAM address of tile column 0 */
extern void DrawNameWithIcon(const u8 *s, u8 len, u8 x, u8 y);      /* 00:3ec8 */
extern volatile u8 wIntNest;        /* $d6d0 DiNest depth */
extern volatile u8 wDrawOp;         /* $d723, StoreDrawParams' op, ink and paper */
extern volatile u8 wDrawColorA;     /* $d734 */
extern volatile u8 wDrawColorB;     /* $d735 */

#define ENTRY_COUNT (*(volatile u16 *)0xc2a2)
#define MQ_LAST (*(volatile u16 *)0xcc31)   /* DrawDirEntryLabel's last drawn index */
#define MQ_CLEAN 0xEEEE                     /* its boot value: nothing scrolled */
#define RAM_BANK (*(volatile u8 *)0x4000)
#define WIN ((const u8 *)0xa000)
#define REC_BANK_BASE 0x12                  /* 32 records of 255 bytes a page */
#define ATTR_OFS 254
#define ATTR_DIR 0x10

#define PAD_PREV (*(volatile u8 *)0xfff5)   /* RomMenuPadTrack: the previous poll's report */
/* Mod WRAM, not HRAM: until 2026-11-10 these were $FFF2 and $FFF4, which are
 * the SGB sender's hSgbStep and hSgbBusy (docs/sgb-background-send.md). Every
 * press then put the frame count in hSgbStep, the VBlank interrupt ran the
 * SGB sender with it, and an SD read soon after could hang on Reading... */
#define HOLD_T   (*(volatile u8 *)0xdc1a)   /* HFRAME after the press, moved on at each repeat */
#define REP_N    (*(volatile u8 *)0xdc1b)   /* repeats since the press, up to RAMP_N */
#define PAD_UP   0x04
#define PAD_DOWN 0x08
#define REPEAT_DELAY 18                     /* frames held before the first repeat (0.3 s) */
#define REPEAT_RATE  6                      /* frames between the first repeats (10 a second) */
#define REPEAT_FAST  3                      /* ...and the last (20 a second) */
#define RAMP_SHIFT   1                      /* 1 << RAMP_SHIFT repeats at each rate on the way */
#define RAMP_N ((REPEAT_RATE - REPEAT_FAST) << RAMP_SHIFT)

#define COUNTER_X_MIN 105                   /* right of the tab strip's HELP */
#define COUNTER_X 15                        /* 8px: first column of the five right of HELP */

void NavDown(u16 p0, u16 p1, u16 p2, struct BrowserScrollState *st);
void NavUp(u16 p0, u16 p1, u16 p2, struct BrowserScrollState *st);
void TabNumFar(u16 p0, u16 p1, u16 p2, const u8 *s, u8 len, u8 x, u8 y);

static void InvertRow(u8 py, u8 groups) __naked;
static void HighlightRow(u8 py, u8 groups) __naked;
static void UnhighlightRow(u8 py, u8 groups) __naked;
static void ShiftRows(u8 dst_y, u8 src_y, u8 batches, signed char step) __naked;
static void VramSync(void) __naked;
static void RowAddr(void) __naked;

void BrowserNav(void) __naked {
    __asm
	jp	_NavDown
	jp	_NavUp
	jp	_TabNumFar
    __endasm;
}

static u8 list_rows(void) {
    return hUiMode ? 10 : 16;
}

static u8 row_y(u8 row) {
    u8 y = (u8)(row << 3);
    return hUiMode ? (u8)(20 + y + (u8)(row << 2)) : (u8)(16 + y);
}

/* The digits of v, no leading zeros; returns their number. */
static u8 put_dec(u8 *p, u16 v) {
    static const u16 pow[3] = {1000, 100, 10};
    u8 i, c, n = 0;

    for (i = 0; i < 3; i++) {
        c = '0';
        while (v >= pow[i]) {
            v -= pow[i];
            c++;
        }
        if (n || c != '0') p[n++] = c;
    }
    p[n++] = (u8)('0' + (u8)v);
    return n;
}

/* The position, 1-based: "n/total" from an x that holds for the whole
 * folder, so the number doesn't move and painting to the row's end leaves
 * nothing of a longer one. When total/total wouldn't fit right of HELP
 * (a three-digit total in 8px and in the 12px font; SLIM fits 416/416), n
 * alone for the whole folder, so the total never comes and goes. */
static void draw_counter(u16 n) {
    u8 buf[12];
    u8 i, nn, tn, x, w, dv, adv;

    if (!hUiMode) {
        /* five cells right of " HELP " (columns 15-19), always all painted:
         * n/total, from a column that holds for the folder, while the total
         * has two digits, else n alone in the stock column (16) */
        tn = put_dec(buf + 6, ENTRY_COUNT);
        x = (u8)(tn < 3 ? 4 - tn - tn : 1);
        for (i = 0; i < x; i++) buf[i] = ' ';
        x = (u8)(x + put_dec(buf + x, n));
        if (tn < 3) {
            buf[x++] = '/';
            for (i = 0; i < tn; i++) buf[x++] = buf[6 + i];
        }
        while (x < 5) buf[x++] = ' ';
        {
            u8 ink = wDrawColorA, paper = wDrawColorB, op = wDrawOp;
            StoreDrawParams(3, 0, 0);
            DrawString(buf, 5, COUNTER_X, 0);
            wDrawColorA = ink;
            wDrawColorB = paper;
            wDrawOp = op;
        }
        return;
    }
    nn = put_dec(buf, n);
    dv = GLYPHS_DV;
    adv = dv ? 6 : 9;
    buf[nn] = '/';
    tn = put_dec(buf + nn + 1, ENTRY_COUNT);
    w = 160 - (dv ? 6 : 8);
    x = w;
    for (i = 0; i < tn; i++) x = (u8)(x - adv - adv);
    if (x < COUNTER_X_MIN) {
        /* total/total doesn't fit (three digits in the 9 px font): n alone
         * for the whole folder, from where a number that long starts */
        x = w;
        for (i = 0; i < tn; i++) x = (u8)(x - adv);
        tn = 0;
    }
    buf[tn ? (u8)(nn + 1 + tn) : nn] = 0;
    /* on the strip's plain background in every theme, whatever the last
     * draw left (a move leaves the bar's paper, the accent); the caller's
     * ink, paper and op go back after */
    {
        u8 ink = wDrawColorA, paper = wDrawColorB, op = wDrawOp;
        StoreDrawParams(3, 0, 0);
        FarCallDrawString12(buf, 0, x, 0);
        wDrawColorA = ink;
        wDrawColorB = paper;
        wDrawOp = op;
    }
}

/* 12px's TabNum12, with DrawString's frame: s holds the stock digits. */
void TabNumFar(u16 p0, u16 p1, u16 p2, const u8 *s, u8 len, u8 x, u8 y) {
    u16 v = 0;
    u8 i, c;

    (void)p0; (void)p1; (void)p2; (void)len; (void)x; (void)y;
    for (i = 0; i < 4; i++) {
        c = s[i];
        if (c < '0' || c > '9') continue;
        v = (u16)((v << 3) + (v << 1) + (u8)(c - '0'));
    }
    draw_counter(v);
}

/* The bar from its row to row `to` without drawing text; 0 when it can't. */
static u8 move_bar(struct BrowserScrollState *st, u8 to) {
    volatile u8 *tick = (volatile u8 *)st - 8;
    u8 groups = hUiMode ? 3 : 2;

    if (MQ_LAST != MQ_CLEAN || wIntNest) return 0;
    if (ACC_IDX) {                      /* a bar in the accent: DV, a color theme */
        UnhighlightRow(row_y(st->sel), groups);
        HighlightRow(row_y(to), groups);
    } else {
        InvertRow(row_y(st->sel), groups);
        InvertRow(row_y(to), groups);
    }
    tick[0] = 0;
    tick[1] = 0;
    tick[2] = 0;
    tick[3] = 0;
    st->sel = to;
    st->dirty = 0;
    draw_counter((u16)(st->base + to + 1));
    return 1;
}

/* Row n of the window (entry base + n), in the bar's colors or plain. */
static void draw_row(u16 base, u8 n, u8 bar) {
    u16 idx = base + n;
    u8 slot = (u8)idx & 31;
    const u8 *rec;

    RAM_BANK = (u8)(REC_BANK_BASE + (u8)(idx >> 5));
    rec = WIN + (((u16)slot << 8) - slot);      /* slot * 255 */
    if (bar) StoreDrawParams(0, 3, 0);
    else StoreDrawParams(3, 0, 0);
    DrawNameWithIcon(rec, rec[ATTR_OFS] == ATTR_DIR ? 0 : 0x14, 0, (u8)(n + 2));
}

/* A scroll of k rows (going down the bar is on the last row, going up on row
 * 0): moves the window, moves the ROWS - 1 - k rows that stay, and draws the
 * k + 1 next to the bar. A wrap, with the window and the bar already where
 * they go: k = ROWS - 1, every row. The bar's row comes first, so the cursor
 * is at its new place from the start, then for a wrap the row at the other
 * end, where the old bar still shows, then the others away from the bar. */
static void repaint_rows(struct BrowserScrollState *st, u8 k, u8 up) {
    volatile u8 *tick = (volatile u8 *)st - 8;
    u8 rows = list_rows();
    u8 last = (u8)(rows - 1);
    u8 sel = st->sel, n, lo, hi, d, b, i;
    u16 base;

    if (k < last) {
        d = b = 0;
        for (i = 0; i < k; i++) d = (u8)(d + (hUiMode ? 12 : 8));
        for (i = k; i < last; i++) b = (u8)(b + (hUiMode ? 3 : 2));
        if (up) {
            st->base -= k;
            n = (u8)(row_y(last) + (hUiMode ? 8 : 4));
            ShiftRows(n, (u8)(n - d), b, -4);
        } else {
            st->base += k;
            n = row_y(0);
            ShiftRows(n, (u8)(n + d), b, 4);
        }
    }
    base = st->base;
    /* SetFpgaPageAlt_B4 (04:41e7) inlined: the record reads need the pSRAM
     * window on page $03 */
    *(volatile u8 *)0x7f00 = 0xe1;
    *(volatile u8 *)0x7f10 = 0xe2;
    *(volatile u8 *)0x7f20 = 0xe3;
    *(volatile u8 *)0x7fc0 = 0x03;
    *(volatile u8 *)0x7ff0 = 0xe4;

    if (sel == 0) {
        lo = 1;
        hi = k;
    } else {
        lo = (u8)(last - k);
        hi = (u8)(last - 1);
    }
    draw_row(base, sel, 1);
    if (k == last) {
        if (sel == 0) {
            draw_row(base, last, 0);
            hi = (u8)(last - 1);
        } else {
            draw_row(base, 0, 0);
            lo = 1;
        }
    }
    if (sel == 0) {
        for (n = lo; n <= hi; n++) draw_row(base, n, 0);
    } else {
        for (n = (u8)(hi + 1); n != lo;) draw_row(base, --n, 0);
    }
    StoreDrawParams(3, 0, 0);
    draw_counter((u16)(base + sel + 1));
    tick[0] = 0;
    tick[1] = 0;
    tick[2] = 0;
    tick[3] = 0;
    st->dirty = 0;
}

/* Rows to scroll by: 1 for a press, then 1 1 2 2 3 3 4 as the repeats go on. */
static u8 step_rows(void) {
    return (u8)((REP_N >> RAMP_SHIFT) + 1);
}

static void move_in_page(struct BrowserScrollState *st, u8 to, u8 dirty) {
    if (!move_bar(st, to)) {
        st->sel = to;
        st->dirty = dirty;
    }
}

static void down(struct BrowserScrollState *st) {
    u16 base = st->base, left;
    u8 sel = st->sel, rows = list_rows(), k;

    if (base + sel + 1 >= ENTRY_COUNT) {
        if (base == 0) {                /* the whole list is on the page */
            move_in_page(st, 0, 1);
            return;
        }
        st->base = 0;
        st->sel = 0;
        repaint_rows(st, (u8)(rows - 1), 0);
        return;
    }
    if ((u8)(sel + 1) < rows) {
        move_in_page(st, (u8)(sel + 1), 2);
        return;
    }
    k = step_rows();
    left = ENTRY_COUNT - base - rows;   /* entries below the window, at least 1 here */
    if (k > left) k = (u8)left;
    repaint_rows(st, k, 0);
}

static void up(struct BrowserScrollState *st) {
    u8 sel = st->sel, rows = list_rows(), k;
    u16 n;

    if (sel != 0) {
        move_in_page(st, (u8)(sel - 1), 3);
        return;
    }
    if (st->base != 0) {
        k = step_rows();
        if (k > st->base) k = (u8)st->base;
        repaint_rows(st, k, 1);
        return;
    }
    n = ENTRY_COUNT;
    if (n == 0) return;
    if (n <= rows) {                    /* the whole list is on the page */
        move_in_page(st, (u8)(n - 1), 1);
        return;
    }
    st->base = n - rows;
    st->sel = (u8)(rows - 1);
    repaint_rows(st, (u8)(rows - 1), 1);
}

/* Nonzero when this report of `key` should move: 2 for a press, 1 for a key
 * held for REPEAT_DELAY frames, then after 6 6 5 5 4 4 3 3 ... frames. The
 * browser reports a held key on every pass of its loop, and a recolored move
 * is quick enough that a tap would otherwise move twice. The delay counts
 * from the end of a press's move: a long repaint can outlast it, and the
 * latched report that follows (docs/joypad-latch.md) would be a second move. */
static u8 repeat_ok(u8 key) {
    u8 now = HFRAME, n, rate;

    if (!(PAD_PREV & key)) {
        REP_N = 0;
        return 2;
    }
    if ((u8)(now - HOLD_T) < REPEAT_DELAY) return 0;
    n = REP_N;
    rate = REPEAT_FAST;
    if (n < RAMP_N) {
        rate = (u8)(REPEAT_RATE - (n >> RAMP_SHIFT));
        REP_N = (u8)(n + 1);
    }
    HOLD_T = (u8)(now - (REPEAT_DELAY - rate));
    return 1;
}

void NavDown(u16 p0, u16 p1, u16 p2, struct BrowserScrollState *st) {
    (void)p0; (void)p1; (void)p2;
    u8 r = repeat_ok(PAD_DOWN);

    if (r) {
        down(st);
        MQ_LAST = MQ_CLEAN;
        if (r == 2) HOLD_T = HFRAME;
    }
}

void NavUp(u16 p0, u16 p1, u16 p2, struct BrowserScrollState *st) {
    (void)p0; (void)p1; (void)p2;
    u8 r = repeat_ok(PAD_UP);

    if (r) {
        up(st);
        MQ_LAST = MQ_CLEAN;
        if (r == 2) HOLD_T = HFRAME;
    }
}

/* plain <-> bar, outside DV: both planes inverted. */
static void InvertRow(u8 py, u8 groups) __naked {
    (void)py; (void)groups;
    __asm
	ldhl	sp, #3
	ld	b, (hl)
	dec	hl
	ld	c, (hl)
invert_group:
	push	bc
	ld	a, c
	call	_RowAddr
	ld	b, #20
invert_col:
	call	_VramSync
	ld	a, (hl)
	cpl
	ld	(hl+), a
	ld	(hl+), a
	ld	a, (hl)
	cpl
	ld	(hl+), a
	ld	(hl+), a
	ld	a, (hl)
	cpl
	ld	(hl+), a
	ld	(hl+), a
	ld	a, (hl)
	cpl
	ld	(hl+), a
	ld	(hl+), a
	ei
	ld	de, #8
	add	hl, de
	dec	b
	jr	nz, invert_col
	pop	bc
	ld	a, c
	add	a, #4
	ld	c, a
	dec	b
	jr	nz, invert_group
	ret
    __endasm;
}

/* With an accent: plain -> bar. A plain row is white (both planes) or DV's
 * blue icon (plane 1) on black, so plane 1 is every lit pixel, and the bar is
 * its complement, black text on the accent: in plane 0 for DV's lime
 * (ACC_IDX 1), plane 1 for a color theme's shade 2. groups of 4 pixel rows,
 * 3 for 12px, 2 for 8px. */
static void HighlightRow(u8 py, u8 groups) __naked {
    (void)py; (void)groups;
    __asm
	ldhl	sp, #3
	ld	b, (hl)
	dec	hl
	ld	c, (hl)
hilite_group:
	push	bc
	ld	a, c
	call	_RowAddr
	ld	a, (#0xdc0b)		; ACC_IDX: 1 -> c $FF, e $00; 2 -> c $00, e $FF
	rra
	sbc	a, a
	ld	c, a
	cpl
	ld	e, a
	ld	b, #20
hilite_col:
	call	_VramSync
	inc	l			; plane 1 (a tile is 16-aligned: no carry)
	ld	a, (hl)
	cpl
	ld	d, a
	and	a, e
	ld	(hl-), a		; plane 1
	ld	a, d
	and	a, c
	ld	(hl+), a		; plane 0
	inc	l			; plane 1 of the next pixel row
	inc	l
	ld	a, (hl)
	cpl
	ld	d, a
	and	a, e
	ld	(hl-), a
	ld	a, d
	and	a, c
	ld	(hl+), a
	inc	l			; plane 1 of the next pixel row
	inc	l
	ld	a, (hl)
	cpl
	ld	d, a
	and	a, e
	ld	(hl-), a
	ld	a, d
	and	a, c
	ld	(hl+), a
	inc	l			; plane 1 of the next pixel row
	inc	l
	ld	a, (hl)
	cpl
	ld	d, a
	and	a, e
	ld	(hl-), a
	ld	a, d
	and	a, c
	ld	(hl+), a
	inc	hl
	ei
	ld	a, l			; next tile column: 16 on, 8 of them done
	add	a, #8
	ld	l, a
	jr	nc, hilite_next
	inc	h
hilite_next:
	dec	b
	jr	nz, hilite_col
	pop	bc
	ld	a, c
	add	a, #4
	ld	c, a
	dec	b
	jr	nz, hilite_group
	ret
    __endasm;
}

/* With an accent: bar -> plain. The bar's accent is in one plane or the
 * other and its text is black, so plane 0 | plane 1 is the bar, and white
 * text is the rest. DV's icon is blue: plane 0 masked off in tile column 0
 * and the first pixel of column 1. */
static void UnhighlightRow(u8 py, u8 groups) __naked {
    (void)py; (void)groups;
    __asm
	ldhl	sp, #3
	ld	b, (hl)
	dec	hl
	ld	c, (hl)
unhilite_group:
	push	bc
	ld	a, c
	call	_RowAddr
	ld	a, (#0xdc0b)		; ACC_IDX: 1 (DV) -> mask $00, else $FF
	rra
	sbc	a, a
	cpl
	ld	c, a
	ld	b, #20
unhilite_col:
	call	_VramSync
	ld	a, (hl+)
	or	a, (hl)
	cpl
	ld	(hl-), a		; plane 1
	and	a, c
	ld	(hl+), a		; plane 0
	inc	l
	ld	a, (hl+)
	or	a, (hl)
	cpl
	ld	(hl-), a
	and	a, c
	ld	(hl+), a
	inc	l
	ld	a, (hl+)
	or	a, (hl)
	cpl
	ld	(hl-), a
	and	a, c
	ld	(hl+), a
	inc	l
	ld	a, (hl+)
	or	a, (hl)
	cpl
	ld	(hl-), a
	and	a, c
	ld	(hl+), a
	inc	hl
	ei
	ld	de, #8
	add	hl, de
	ld	a, c			; next mask: $00 -> $7F -> $FF
	cp	a, #0x7f
	ld	c, #0xff
	jr	nc, unhilite_mask
	ld	c, #0x7f
unhilite_mask:
	dec	b
	jr	nz, unhilite_col
	pop	bc
	ld	a, c
	add	a, #4
	ld	c, a
	dec	b
	jr	nz, unhilite_group
	ret
    __endasm;
}

/* Copies `batches` groups of 4 pixel rows, all 20 tile columns, from src_y to
 * dst_y, stepping both by `step`: 4, or -4 to copy bottom first when moving
 * rows down, so nothing is overwritten before it is read. */
static void ShiftRows(u8 dst_y, u8 src_y, u8 batches, signed char step) __naked {
    (void)dst_y; (void)src_y; (void)batches; (void)step;
    __asm
shift_batch:
	ldhl	sp, #3
	ld	a, (hl)
	call	_RowAddr
	push	hl
	ldhl	sp, #4
	ld	a, (hl)
	call	_RowAddr
	ld	d, h
	ld	e, l
	pop	hl
	ld	b, #20
shift_col:
	call	_VramSync
	ld	c, #2
shift_half:
	ld	a, (hl+)
	ld	(de), a
	inc	de
	ld	a, (hl+)
	ld	(de), a
	inc	de
	ld	a, (hl+)
	ld	(de), a
	inc	de
	ld	a, (hl+)
	ld	(de), a
	inc	de
	dec	c
	jr	nz, shift_half
	ei
	ld	a, l			; next tile column: 16 on, 8 of them done
	add	a, #8
	ld	l, a
	jr	nc, shift_src
	inc	h
shift_src:
	ld	a, e
	add	a, #8
	ld	e, a
	jr	nc, shift_dst
	inc	d
shift_dst:
	dec	b
	jr	nz, shift_col
	ldhl	sp, #5
	ld	c, (hl)
	dec	hl
	dec	(hl)
	ret	z
	dec	hl
	ld	a, (hl)
	add	a, c
	ld	(hl-), a
	ld	a, (hl)
	add	a, c
	ld	(hl), a
	jp	shift_batch
    __endasm;
}

/* Returns in a VRAM window with interrupts off (blit_col1's sync): a fresh
 * HBlank, or straight away while LY reads 144..151 in mode 1. A sync from
 * LY >= 143 waits with interrupts on for LY 145..150 or the next frame, so the
 * VBlank callback that points the BG tile data back at $8000 is never
 * delayed. Leaves bc, de and hl alone. */
static void VramSync(void) __naked {
    __asm
vs_try:
	di
	ldh	a, (#0xff41)
	and	a, #3
	cp	a, #1
	jr	nz, vs_sync
	ldh	a, (#0xff44)
	cp	a, #144
	jr	c, vs_sync
	cp	a, #152
	ret	c
vs_sync:
	ldh	a, (#0xff44)
	cp	a, #143
	jr	c, vs_m3
	ei
vs_vb:
	ldh	a, (#0xff44)
	cp	a, #143
	jr	c, vs_try
	cp	a, #145
	jr	c, vs_vb
	cp	a, #151
	jr	c, vs_try
	jr	vs_vb
vs_m3:
	ldh	a, (#0xff41)
	and	a, #3
	cp	a, #3
	jr	nz, vs_m3
vs_w0:
	ldh	a, (#0xff41)
	and	a, #3
	jr	nz, vs_w0
	ret
    __endasm;
}

/* a = pixel row -> hl = its VRAM address in tile column 0. Clobbers de. */
static void RowAddr(void) __naked {
    __asm
	ld	l, a
	ld	h, #0
	add	hl, hl
	ld	de, #_GfxRowTable
	add	hl, de
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	ret
    __endasm;
}
