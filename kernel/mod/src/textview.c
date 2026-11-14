/* Read-only text viewer (docs/text-viewer.md).
 *
 * Bank 14, injected at 0E:4000. A on a file that is not a ROM comes here from
 * RomMenu (rom_menu.c) through TextViewFar (04:59a8); a .txt, .ini or .md
 * file is shown, anything else is handed back. The text takes the list area
 * under the tab strip, the same in both UI modes: 12 rows of 26 characters
 * in the slim font (Tamzen 6x12, the DV glyph set) with the rows 10 px
 * apart. Lines wrap at the last space that fits, or mid-word when there is
 * none.
 *
 *   UP / DOWN      one line (repeats when held)
 *   LEFT / RIGHT   one page back / on (A also pages on)
 *   B              back to the browser
 *
 * The 12px renderer (draw12.c) places rows on 4 px steps and paints 12 of
 * them, so the viewer draws its own: the glyphs are a table in this block
 * (textview_font.h, scripts/textview-font.py: rows 1-10 of each 6x12 cell,
 * one byte a row), a row is composed in a stack buffer, one 10-byte column
 * per tile, and blit_col copies each column to the tile canvas, ink 3 on
 * paper 0, two pixel rows per HBlank with interrupts off across the sync
 * (docs/drawing-timing.md).
 *
 * The file is never held in RAM: one 512-byte sector at a time is read into
 * the loader's scratch ($c0a0) through the kernel FIL ($ca0f), both idle in
 * the browser. A line is laid out straight from that buffer. To scroll back,
 * the file position of every 32nd row is kept as the text is passed (CK),
 * and the row wanted is found by laying out forward from the nearest one.
 * Positions are 16 bits and CK has 96 entries, so the viewer shows the
 * first 65,024 bytes and the first 3,072 rows of a file and stops there.
 * The twelve rows on screen are kept as text (TXT), so one row down reads
 * only the new bottom row.
 *
 * Bytes: CR is dropped, TAB is a space, other control codes and $7F show as
 * "?"; a UTF-8 sequence shows as one "?" (its lead byte; the continuation
 * bytes $80-$BF are dropped).
 *
 * Every FatFs call is preceded by a VBlank wait and FPGA page 0, as ezcfg
 * does; on the way out the record page is mapped again (page 3 and the RAM
 * bank of the cursor's record), as SaveOp's SO_DONE does.
 *
 *   python3 tools/inject.py src/textview.c $V 14 4000 TextView \
 *       --pin FarCall_06_7309=1926 --pin FarCall_06_779a=1941 \
 *       --pin FarCall_03_76cc=1985 --pin FarCall_03_768f=19a1 \
 *       --pin GfxRowTable=2fbb --pin ReadJoypad=3a4a --pin DrawRect=27ba \
 *       --pin StoreDrawParams=2791 --pin WaitVBlankFlag=0688 --apply
 */

#include "types.h"
#include "draw.h"
#include "vars.h"
#include "textview_font.h"

extern u8 FarCall_06_7309(u8 *fp, const u8 *path, u8 mode);         /* f_open  00:1926 */
extern u8 FarCall_06_779a(u8 *fp, u8 *buf, u16 btr, u16 *br);       /* f_read  00:1941 */
extern u8 FarCall_03_76cc(u8 *fp, u32 ofs);                          /* f_lseek 00:1985 */
extern u8 FarCall_03_768f(u8 *fp);                                  /* f_close 00:19a1 */
extern const u16 GfxRowTable[];     /* 00:2fbb pixel row -> VRAM address of tile column 0 */
extern u8 ReadJoypad(void);                                         /* 00:3a4a */

#define CWD       ((const u8 *)0xC2A6)      /* browser: current directory ("/" or "/a/b") */
#define REC_BASE  (*(volatile u16 *)0xC2A0) /* the open page's records in the $A000 window */
#define NAME      ((u8 *)0xC4A4)            /* 255: the file's name, copied out of the record */
#define PAD_PREV  (*(volatile u8 *)0xFFF5)  /* RomMenuPadTrack: the browser's previous report */
#define FIL_OBJ   ((u8 *)0xCA0F)            /* kernel FIL, idle in the browser */
#define BUF       ((u8 *)0xC0A0)            /* the loader's 512-byte scratch */
#define RAM_BANK  (*(volatile u8 *)0x4000)

/* $D780-$D9FF is scratch that ezcfg and SaveOp use only while they run. */
#define CK        ((u16 *)0xD780)           /* file position of row 32k, 96 entries */
#define CK_MAX    96
#define CK_SHIFT  5
#define PATH      ((u8 *)0xD900)            /* 256, for f_open only; it overlaps what follows */
#define TXT       ((u8 *)0xD840)            /* 12 x 28: the rows on screen, NUL-terminated */
#define TXT_W     28
#define OFF       ((u8 *)0xD990)            /* 28: each character's distance from its row's start */
#define START     ((u16 *)0xD9AC)           /* 13: position of each row on screen, and of the next */
#define EXT       ((u8 *)0xD9C6)            /* 12: tile columns each screen row has ink in */
#define CUR_SEC   (*(volatile u8 *)0xD9D2)  /* sector in BUF, $FF = none */
#define CUR_LEN   (*(volatile u16 *)0xD9D4) /* bytes of it that are file */
#define TOP_LN    (*(volatile u16 *)0xD9D6) /* row number of the top row */
#define TOP       (START[0])                /* its file position */

#define MAX_SEC   127                       /* 16-bit positions */
#define LINE_MAX  250                       /* file bytes one row may consume */
#define FA_READ   0x01

#define PAD_RIGHT 0x01
#define PAD_LEFT  0x02
#define PAD_UP    0x04
#define PAD_DOWN  0x08
#define PAD_A     0x10
#define PAD_B     0x20
#define REPEAT_FRAMES 14

#define ROWS      12
#define COLS      26
#define ROW_H     10
#define TOP_Y     22                        /* under either tab strip (16 or 20 px) */
#define LEFT_X    2

static void sd(void);
static u8 have(u16 pos);
static u16 next_line(u16 pos, u8 *line);
static void layout(u8 from);
static void paint(void);
static void zero(u8 *p, u8 n) __naked;
static void move_up(void) __naked;
static void glyph_or(const u8 *g, u8 *q, u8 sh) __naked;
static void blit_col(const u8 *src, u16 addr) __naked;
static void up(u8 k);
static void clear(void);

/* The entry point stays the first function in the file. Reached through the
 * `call`ed stub at 04:59a8: three pad parameters. slot is the browser
 * frame's record-offset slot, as RomMenu gets it. Returns 0 when the file
 * is not a text file (RomMenu goes on with the stock open), 1 when done. */
u8 TextView(u16 far_pad_thunk, u16 far_pad_af, u16 far_pad_ret, u8 *slot) {
    static const u8 text_ext[] = "txt" "ini" "md";
    const u8 *rec;
    u8 i, n, f, pad, prev, hold, k, page;

    (void)far_pad_thunk;
    (void)far_pad_af;
    (void)far_pad_ret;
    /* the record is in the pSRAM window: the name goes to WRAM first */
    rec = (const u8 *)(*(u16 *)slot + REC_BASE);
    k = 0xFF;
    for (i = 0; i < 254 && rec[i]; i++) {
        NAME[i] = rec[i];
        if (rec[i] == '.') k = i;
    }
    NAME[i] = 0;
    NAME[i + 1] = 0;
    if (k == 0xFF || i - k > 4) return 0;
    f = 0;
    for (n = 0; n < 9; n += 3) {
        /* the table's NUL is .md's third character */
        if ((NAME[k + 1] | 0x20) == text_ext[n] && (NAME[k + 2] | 0x20) == text_ext[n + 1] &&
            (NAME[k + 3] ? (NAME[k + 3] | 0x20) : 0) == text_ext[n + 2]) f = 1;
    }
    if (!f) return 0;
    /* an A held on from the press that opened the folder: wait it out */
    if (PAD_PREV & PAD_A) {
        while (ReadJoypad() & PAD_A) WaitVBlankFlag();
        return 1;
    }
    /* the record page MenuDispatchAB_bankEntry mapped (rom_menu.c) */
    page = (u8)((u16)(*(u16 *)(slot + 0x0f) + slot[0x11]) >> 5) + 0x12;
    for (n = 0; CWD[n]; n++) PATH[n] = CWD[n];
    if (n != 1) PATH[n++] = '/';
    for (i = 0; NAME[i] && n < 255; i++) PATH[n++] = NAME[i];
    PATH[n] = 0;
    sd();
    if (NAME[i] == 0 && FarCall_06_7309(FIL_OBJ, PATH, FA_READ) == 0) {
        CUR_SEC = 0xFF;
        TOP_LN = 0;
        TOP = 0;
        for (i = 0; i < ROWS; i++) EXT[i] = 0;
        clear();
        layout(0);
        paint();
        prev = 0xFF;
        hold = 0;
        for (;;) {
            f = HFRAME;
            while (HFRAME == f) WaitVBlankFlag();
            pad = ReadJoypad();
            f = pad & (u8)~prev;
            if (pad == prev && (pad & (PAD_UP | PAD_DOWN))) {
                if (hold < REPEAT_FRAMES) hold++;
                else f = pad & (PAD_UP | PAD_DOWN);
            } else {
                hold = 0;
            }
            prev = pad;
            if (f & PAD_B) break;
            if (f & (PAD_DOWN | PAD_RIGHT | PAD_A)) {
                /* nothing below the screen, or past the last row CK covers */
                if (!have(START[ROWS]) || TOP_LN + ROWS + ROWS >= ((u16)CK_MAX << CK_SHIFT)) continue;
                if (f & PAD_DOWN) {
                    /* one row: the rows kept in TXT move up, only the new
                     * bottom row is read from the file */
                    for (n = 0; n < ROWS; n++) START[n] = START[n + 1];
                    move_up();
                    TOP_LN++;
                    layout(ROWS - 1);
                } else {
                    TOP = START[ROWS - 1];
                    TOP_LN += ROWS - 1;
                    layout(0);
                }
            } else if (f & (PAD_UP | PAD_LEFT)) {
                if (TOP_LN == 0) continue;
                up((f & PAD_UP) ? 1 : ROWS - 1);
                layout(0);
            } else {
                continue;
            }
            paint();
        }
        while (ReadJoypad() & PAD_B) WaitVBlankFlag();
        sd();
        FarCall_03_768f(FIL_OBJ);
        clear();
    }
    *(volatile u8 *)0x7F00 = 0xE1;
    *(volatile u8 *)0x7F10 = 0xE2;
    *(volatile u8 *)0x7F20 = 0xE3;
    *(volatile u8 *)0x7FC0 = 3;
    *(volatile u8 *)0x7FF0 = 0xE4;
    RAM_BANK = page;
    return 1;
}

static void sd(void) {
    WaitVBlankFlag();
    *(volatile u8 *)0x7F00 = 0xE1;
    *(volatile u8 *)0x7F10 = 0xE2;
    *(volatile u8 *)0x7F20 = 0xE3;
    *(volatile u8 *)0x7FC0 = 0;
    *(volatile u8 *)0x7FF0 = 0xE4;
}

/* Is there a file byte at pos? Leaves its sector in BUF. */
static u8 have(u16 pos) {
    u8 s = (u8)(pos >> 9);

    if (s != CUR_SEC) {
        CUR_SEC = s;
        CUR_LEN = 0;
        if (s < MAX_SEC) {
            sd();
            if (FarCall_03_76cc(FIL_OBJ, (u32)(pos & 0xFE00)) == 0) {
                sd();
                if (FarCall_06_779a(FIL_OBJ, BUF, 512, (u16 *)0xD9D4)) CUR_LEN = 0;
            }
        }
    }
    return (pos & 0x1FF) < CUR_LEN;
}

/* Lay out the row that starts at pos into line (28 bytes, NUL-terminated)
 * and return where the next row starts. */
static u16 next_line(u16 pos, u8 *line) {
    u16 p = pos;
    u8 n = 0, c, j;

    /* one character more than a row holds, to know whether it must wrap */
    while (n <= COLS && (u8)(p - pos) < LINE_MAX && have(p)) {
        c = BUF[p & 0x1FF];
        p++;
        if (c == '\n') break;
        if (c == '\r') continue;
        if (c == '\t') {
            c = ' ';
        } else if (c >= 0x80) {
            if (c < 0xC0) continue;
            c = '?';
        } else if (c < 0x20 || c == 0x7F) {
            c = '?';
        }
        OFF[n] = (u8)(p - 1 - pos);
        line[n] = c;
        n++;
    }
    line[n] = 0;
    if (n <= COLS) return p;
    for (j = COLS; j; j--) if (line[j] == ' ') break;
    if (j) {
        p = pos + OFF[j] + 1;           /* the space is the break */
        /* a line end right after it belongs to this row, not a blank one */
        while (have(p) && BUF[p & 0x1FF] == '\r') p++;
        if (have(p) && BUF[p & 0x1FF] == '\n') p++;
    } else {
        j = COLS;
        p = pos + OFF[j];
    }
    line[j] = 0;
    return p;
}

/* Rows from..11 of the screen into TXT, from START[from]; START[from] of
 * the first is row TOP_LN + from. */
static void layout(u8 from) {
    u16 p = START[from], ln = TOP_LN + from;
    u8 *line = TXT + (u16)from * TXT_W;
    u8 i;

    for (i = from; i < ROWS; i++, line += TXT_W) {
        START[i] = p;
        if (!(ln & 31)) CK[ln >> CK_SHIFT] = p;
        ln++;
        if (have(p)) p = next_line(p, line);
        else line[0] = 0;
    }
    START[ROWS] = p;
}

/* TXT to the screen. Character i of a row is at x = 2 + 6i, so its shift
 * within a tile is 2, 0, 6 or 4; only the last two reach into the next
 * tile. A row is blitted as far as it, or what it replaces, has ink. */
static void paint(void) {
    u8 rb[21 * ROW_H];              /* a spare column for the last glyph's (empty) spill */
    const u8 *line = TXT;
    const u8 *q;
    u8 i, k, n, x, c;
    u16 addr, g;

    /* no multiplies in here (SDCC calls a routine for each): x10 by shifts */
    for (k = 0; k < ROWS; k++, line += TXT_W) {
        zero(rb, 21 * ROW_H);
        x = LEFT_X;
        for (i = 0; (c = line[i]) != 0; i++, x += 6) {
            g = (u8)(c - 0x20);
            g = (g << 3) + (g << 1);
            c = x >> 3;
            glyph_or(tv_font + g, rb + (u8)((u8)(c << 3) + (u8)(c << 1)), x & 7);
        }
        n = (u8)(x + 7) >> 3;       /* x is one cell past the last glyph: 6i + 2 */
        if (i == 0) n = 0;
        c = EXT[k];
        EXT[k] = n;
        if (c > n) n = c;
        addr = GfxRowTable[(u8)(TOP_Y + (u8)(k << 3) + (u8)(k << 1))];
        for (i = 0, q = rb; i < n; i++, addr += 16, q += ROW_H) blit_col(q, addr);
    }
}

/* Back k rows: forward from the nearest kept position. */
static void up(u8 k) {
    u16 t = TOP_LN > k ? TOP_LN - k : 0;
    u16 ln = t & 0xFFE0;
    u16 p = CK[t >> CK_SHIFT];

    while (ln < t) {
        p = next_line(p, TXT);          /* TXT is laid out again after this */
        ln++;
    }
    TOP = p;
    TOP_LN = t;
}

/* The list area, under the tab strip (16 px tall in 8px mode, 20 in 12px). */
static void clear(void) {
    StoreDrawParams(0, 0, 0);
    DrawRect(0, hUiMode ? 20 : 16, 159, 143, 1);
    StoreDrawParams(3, 0, 0);
}

/* TXT's rows 1-11 to rows 0-10: 308 bytes down by 28. */
static void move_up(void) __naked {
    __asm
	ld	hl, #0xD840 + 28
	ld	de, #0xD840
	ld	bc, #308
1$:
	ld	a, (hl+)
	ld	(de), a
	inc	de
	dec	bc
	ld	a, b
	or	c
	jr	nz, 1$
	ret
    __endasm;
}

/* Zero n bytes at p. Frame (sdcccall 0): +2 p  +4 n. */
static void zero(u8 *p, u8 n) __naked {
    (void)p; (void)n;
    __asm
	ldhl	sp, #4
	ld	b, (hl)
	ldhl	sp, #2
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	xor	a
1$:
	ld	(hl+), a
	dec	b
	jr	nz, 1$
	ret
    __endasm;
}

/* OR one glyph (ten rows, the six pixels in bits 7-2) into a tile column of
 * the row buffer at q, sh pixels in from the tile's left edge (0, 2, 4 or
 * 6); from 4 on, the pixels past the tile go into the next column, which
 * follows at q + 10.
 * Frame (sdcccall 0): +2 g  +4 q  +6 sh. */
static void glyph_or(const u8 *g, u8 *q, u8 sh) __naked {
    (void)g; (void)q; (void)sh;
    __asm
	ldhl	sp, #6
	ld	c, (hl)
	ldhl	sp, #2
	ld	a, (hl+)
	ld	e, a
	ld	a, (hl+)
	ld	d, a
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	ld	b, #10
	ld	a, c
	or	a
	jr	z, 10$
	cp	#2
	jr	z, 20$
	push	de
	cp	#4
	jr	z, 40$
60$:
	ld	a, (de)
	inc	de
	rlca
	rlca
	and	#0x03
	or	(hl)
	ld	(hl+), a
	dec	b
	jr	nz, 60$
	pop	de
	ld	b, #10
61$:
	ld	a, (de)
	inc	de
	add	a, a
	add	a, a
	or	(hl)
	ld	(hl+), a
	dec	b
	jr	nz, 61$
	ret
40$:
	ld	a, (de)
	inc	de
	swap	a
	and	#0x0f
	or	(hl)
	ld	(hl+), a
	dec	b
	jr	nz, 40$
	pop	de
	ld	b, #10
41$:
	ld	a, (de)
	inc	de
	swap	a
	and	#0xf0
	or	(hl)
	ld	(hl+), a
	dec	b
	jr	nz, 41$
	ret
20$:
	ld	a, (de)
	inc	de
	rrca
	rrca
	and	#0x3f
	or	(hl)
	ld	(hl+), a
	dec	b
	jr	nz, 20$
	ret
10$:
	ld	a, (de)
	inc	de
	or	(hl)
	ld	(hl+), a
	dec	b
	jr	nz, 10$
	ret
    __endasm;
}

/* Ten bytes at src to one tile column of the canvas, from addr down, both
 * planes, two pixel rows a batch. The sync is blit_col1's (draw12.c):
 * during VBlank (lines 144-151) a batch is written at once; on a visible
 * line interrupts are off from before mode 3 is seen until the batch is
 * written, so the writes land in mode 0 or the mode 2 after it (71 cycles
 * with no sprites or window, which the menus never have; the last write
 * comes at most 48 after mode 0 began. Three rows a batch reach 70 when a
 * tile boundary falls in it, and SameBoy's DMG then drops a row now and
 * then). Interrupts are never held off over
 * the start of VBlank or of line 72, whose handlers switch the BG tile
 * addressing (EnterGfxMode1): a late one shows as a flickering row at the
 * top of the screen. A row address steps by 2 inside a tile and by
 * $130 + 2 into the tile below.
 * Frame (sdcccall 0): +2 src  +4 addr. */
static void blit_col(const u8 *src, u16 addr) __naked {
    (void)src; (void)addr;
    __asm
	ldhl	sp, #4
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ldhl	sp, #2
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	ld	b, #10
1$:
	ld	c, #2
	di
	ldh	a, (#0xff41)
	and	#3
	cp	#1
	jr	nz, 7$
	ldh	a, (#0xff44)
	cp	#144
	jr	c, 7$
	cp	#152
	jr	c, 4$			; in VBlank, lines 144-151: write now
7$:
	ldh	a, (#0xff44)
	cp	#71
	jr	z, 8$
	cp	#143
	jr	c, 2$
8$:
	ei				; let the line 72 and VBlank handlers run on time
9$:
	ldh	a, (#0xff44)
	cp	#71
	jr	z, 9$
	cp	#143
	jr	c, 1$
	cp	#145
	jr	c, 9$
	cp	#151
	jr	c, 1$
	jr	9$
2$:
	ldh	a, (#0xff41)
	and	#3
	cp	#3
	jr	nz, 2$
3$:
	ldh	a, (#0xff41)
	and	#3
	jr	nz, 3$
4$:
	ld	a, (hl+)
	ld	(de), a
	inc	e
	ld	(de), a
	inc	de
	ld	a, e
	and	#0x0f
	jr	nz, 5$
	ld	a, e
	add	#0x30
	ld	e, a
	ld	a, d
	adc	#0x01
	ld	d, a
5$:
	dec	b
	jr	z, 6$
	dec	c
	jr	nz, 4$
	ei
	jr	1$
6$:
	ei
	ret
    __endasm;
}
