/* 12px text renderer for the file browser (docs/font12.md).
 *
 * The kernel draws the browser into a 20x18 tile canvas ($8100, one tile
 * per 8x8 cell, pixel row py of tile column tx lives at
 * GfxRowTable[py] + tx*16, planes in consecutive bytes). DrawGlyph is a
 * pure 8x8 blitter: one glyph == one tile, so the stock text grid is 8px.
 *
 * This renderer places 10x12 cells at arbitrary pixel offsets instead: 16
 * cells at x = 10*col fill the 160px row exactly (the browser puts the icon
 * in cell 0 and 15 name characters after it). Rows are 12px tall under the
 * 16px tab strip, so tile row r >= 2 maps to y = 16 + 12*(r - 2): ten list
 * rows, r = 2..11.
 *
 * Nothing is precomposed in ROM. The fast path (the browser's ink 3 on
 * paper 0 or the inverse, both planes equal) composes the row in a WRAM
 * buffer, one 12-byte column per tile touched: every glyph row is a 16-bit
 * word with the leftmost pixel in bit 15, shifted right by x & 7 (0, 2, 4
 * or 6 for these cells) and OR'd into the tile it starts in and the next
 * one. A tile only partly covered by the string (the marquee starts at
 * cell 1, 2px into tile 1, next to the icon) is read from VRAM
 * first so the neighbour's pixels survive. The buffer is then flushed with
 * blit_col1: pure writes, four tile rows per HBlank/VBlank batch. Any other
 * ink/paper pair, or a caller inside a DiNest section, takes the generic
 * per-cell masked read-modify-write path (blit_cell / blit_rows).
 *
 * Ink and paper come from the draw state StoreDrawParams sets ($d734 /
 * $d735), so the browser's selection bar (ink 0 / paper 3) inverts the cell
 * exactly as before, and every cell paints all of its pixels so the bar is
 * continuous.
 *
 * Entry point DrawString12 keeps DrawString's (s, len, col, row) argument
 * order so the bank-0 far-call stub FarCallDrawString12 (00:05c0) can be
 * dropped in for DrawString by re-pinning. It is reached through
 * FarCallTrampoline from a stub that is itself `call`ed, so the
 * trampoline's three words sit between the stub's return address and the
 * arguments: the first real argument is at sp+8, hence the three pad
 * parameters (an inline `call FarCallTrampoline` stub would need only two,
 * docs/browser-hide-filter.md). Like DrawString, a NUL inside len pads the
 * rest with spaces, and len is capped at the cells left on the row.
 *
 * Bank 2, injected at 02:7500 (must stay the first definition in the file);
 * the glyph table is a separate raw block at 02:6000 (Font12), produced by
 * scripts/font12-pack.py from decomp/font12/font12.txt: 101 glyphs x 12
 * rows x 2 bytes, pixels in bits 15..6.
 *
 *   python3 tools/inject.py src/draw12.c $V 2 7500 DrawString12 \\
 *       --pin wDrawColor=d734 --pin wDrawColorB=d735 --pin wIntNest=d6d0 \\
 *       --pin GfxRowTable=2fbb --pin Font12=6000 --pin DiNest=06fd --pin EiNest=0706 --replace --apply
 */

typedef unsigned char u8;
typedef unsigned int u16;

/* Kernel symbols, all --pin'd so scripts/port-mod.py can re-pin them for a
 * kernel whose WRAM map differs (1.04e shifts $d6cc and up). */
extern volatile u8 wDrawColor;     /* $d734 ink   (StoreDrawParams) */
extern volatile u8 wDrawColorB;    /* $d735 paper */
extern volatile u8 wIntNest;       /* $d6d0 DiNest depth */
extern const u16 GfxRowTable[];    /* 00:2fbb pixel row -> VRAM address of tile column 0 */
extern const u8 Font12[];          /* 02:6000, 101 glyphs x 24 bytes (scripts/font12-pack.py) */
extern void DiNest(void);          /* 00:06fd */
extern void EiNest(void);          /* 00:0706 */

#define INK   wDrawColor
#define PAPER wDrawColorB
#define INT_NEST wIntNest
#define ROWTAB GfxRowTable
#define FONT12 Font12

#define CELL 10
#define COLS 16            /* 160 px: the icon cell and 15 text cells */
#define ROW_W 160
#define ROW_H 12
#define STRIP_H 16
#define SCREEN_H 144
#define GLYPH 24
#define MAX_TILES 20

static void blit_cell(const u8 *g, u8 x, u8 y);
static void blit_rows(const u8 *g, u16 tile, u8 sh, u8 mhi, u8 mlo,
                      u8 a0, u8 x0, u8 a1, u8 x1, u8 y, u8 n) __naked;
static void blit_col1(const u8 *src, u16 addr, u8 n, u8 xm) __naked;
static void fill0(u8 *p, u8 n4) __naked;
static void vram_rd_col(u16 addr, u8 *dst, u8 n) __naked;
static void cell_or0(const u8 *g, u8 *buf) __naked;
static void cell_or2(const u8 *g, u8 *buf) __naked;
static void cell_or4(const u8 *g, u8 *buf) __naked;
static void cell_or6(const u8 *g, u8 *buf) __naked;
static void preserve(u8 *dst, u16 addr, u8 n, u8 keep, u8 xm);
static u8 glyph_at(const u8 *s, u8 i, u8 *ended);
static u8 glyph_index(u8 c);
static u8 cell_x(u8 col);

void DrawString12(u16 far_pad_thunk, u16 far_pad_af, u16 far_pad_ret, const u8 *s, u8 len, u8 col, u8 row) {
    u8 i, x, y, left, ended, n, ink, paper, xm, x0, x1, t0, nt, kf, kl;
    u8 buf[MAX_TILES * ROW_H];
    u16 addr;
    const u8 *g;
    u8 *p;

    (void)far_pad_thunk;
    (void)far_pad_af;
    (void)far_pad_ret;
    if (col >= COLS) {
        return;
    }
    y = (row >= 2) ? (u8)(STRIP_H + (row - 2) * ROW_H) : (u8)(row * 8);
    if (y >= SCREEN_H) {
        return;
    }
    left = (u8)(COLS - col);
    if (len == 0 || len > left) {
        len = left;
    }
    ended = 0;
    ink = INK;
    paper = PAPER;
    if (INT_NEST != 0 || (ink | paper) != 3 || (ink & paper) != 0) {
        /* general ink/paper: cell by cell through the generic loop */
        for (i = 0; i < len; i++) {
            blit_cell(FONT12 + (u16)glyph_at(s, i, &ended) * GLYPH, cell_x((u8)(col + i)), y);
        }
        return;
    }
    n = ROW_H;
    if ((u8)(SCREEN_H - y) < ROW_H) {
        n = (u8)((SCREEN_H - y) & 0xFC);   /* batches of 4 rows; only the clipped bottom row is short (8) */
        if (n == 0) {
            return;
        }
    }
    xm = paper ? 0xFF : 0;
    x0 = cell_x(col);
    x1 = cell_x((u8)(col + len));      /* 160 past the last cell */
    t0 = (u8)(x0 >> 3);
    nt = (u8)(((u8)(x1 - 1) >> 3) - t0 + 1);
    fill0(buf, (u8)(nt * 3));
    /* tiles the string only partly covers keep their other pixels */
    kf = (x0 & 7) ? (u8)(0xFF << (8 - (x0 & 7))) : 0;
    kl = (x1 & 7) ? (u8)(0xFF >> (x1 & 7)) : 0;
    addr = ROWTAB[y] + ((u16)t0 << 4);
    if (nt == 1) {
        if (kf | kl) {
            preserve(buf, addr, n, (u8)(kf | kl), xm);
        }
    } else {
        if (kf) {
            preserve(buf, addr, n, kf, xm);
        }
        if (kl) {
            preserve(buf + (u8)((nt - 1) * ROW_H), (u16)(addr + ((u16)(nt - 1) << 4)), n, kl, xm);
        }
    }
    for (i = 0; i < len; i++) {
        x = cell_x((u8)(col + i));
        g = FONT12 + (u16)glyph_at(s, i, &ended) * GLYPH;
        p = buf + (u8)((u8)((x >> 3) - t0) * ROW_H);
        switch (x & 7) {
        case 0:  cell_or0(g, p); break;
        case 2:  cell_or2(g, p); break;
        case 4:  cell_or4(g, p); break;
        default: cell_or6(g, p); break;
        }
    }
    p = buf;
    for (i = 0; i < nt; i++, p += ROW_H, addr += 16) {
        blit_col1(p, addr, n, xm);
    }
}

/* Left pixel of a cell (col 16 = 160, the row's end). */
static u8 cell_x(u8 col) {
    return (u8)(col * CELL);
}

/* Read the old plane-0 bytes of one tile column into dst, then keep only
 * the pixels outside the string (keep mask), pre-inverted for a
 * highlighted row so the flush's xor puts them back. */
static void preserve(u8 *dst, u16 addr, u8 n, u8 keep, u8 xm) {
    u8 r;

    vram_rd_col(addr, dst, n);
    for (r = 0; r < n; r++) {
        dst[r] = (u8)((dst[r] ^ xm) & keep);
    }
}

/* Character i of the string as a glyph index; a NUL ends the string and
 * everything after it is a space, like DrawString. */
static u8 glyph_at(const u8 *s, u8 i, u8 *ended) {
    u8 c = ' ';

    if (!*ended) {
        c = s[i];
        if (c == 0) {
            *ended = 1;
            c = ' ';
        }
    }
    return glyph_index(c);
}

static u8 glyph_index(u8 c) {
    if (c >= 0x20 && c < 0x80) {
        return (u8)(c - 0x20);
    }
    if (c >= 0xC0 && c <= 0xC4) {
        return (u8)(96 + (c - 0xC0));
    }
    return (u8)('?' - 0x20);
}

/* Zero 4*n4 bytes at p.  Frame (sdcccall 0): +2 p  +4 n4. */
static void fill0(u8 *p, u8 n4) __naked {
    (void)p; (void)n4;
    __asm
	ldhl	sp, #4
	ld	b, (hl)
	ldhl	sp, #2
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	xor	a
fill0_loop:
	ld	(hl+), a
	ld	(hl+), a
	ld	(hl+), a
	ld	(hl+), a
	dec	b
	jr	nz, fill0_loop
	ret
    __endasm;
}

/* Plane-0 bytes of n tile rows of one tile column, starting at VRAM addr,
 * into dst. Each read sits in its own di .. ei window right after a STAT
 * check (mode 3 would return $FF). Rows advance by 2 within a tile and by
 * $130 + 2 across a tile boundary, where the address' low nibble wraps to
 * 0.  Frame (sdcccall 0): +2 addr  +4 dst  +6 n. */
static void vram_rd_col(u16 addr, u8 *dst, u8 n) __naked {
    (void)addr; (void)dst; (void)n;
    __asm
	ldhl	sp, #6
	ld	b, (hl)
	ldhl	sp, #2
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ldhl	sp, #4
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
vram_rd_col_row:
	di
vram_rd_col_wait:
	ldh	a, (#0xff41)
	bit	1, a
	jr	nz, vram_rd_col_wait
	ld	a, (de)
	ei
	ld	(hl+), a
	inc	de
	inc	de
	ld	a, e
	and	#0x0F
	jr	nz, vram_rd_col_next
	ld	a, e
	add	#0x30
	ld	e, a
	ld	a, d
	adc	#1
	ld	d, a
vram_rd_col_next:
	dec	b
	jr	nz, vram_rd_col_row
	ret
    __endasm;
}

/* OR one glyph into the row buffer. g points at 12 big-endian 16-bit rows
 * (bit 15 = leftmost pixel), buf at the 12-byte column of the tile the
 * cell starts in; the column of the next tile follows at buf + 12. Each
 * row is shifted right by the cell's x & 7 (one routine per shift, the
 * shift unrolled), its high byte OR'd into this tile's row and its low
 * byte into the next tile's. Registers: de glyph, hl buffer (kept on the
 * next tile's row between rows), c high byte, a low byte, b rows left.
 * Frame (sdcccall 0): +2 g  +4 buf. */
static void cell_or0(const u8 *g, u8 *buf) __naked {
    (void)g; (void)buf;
    __asm
	ldhl	sp, #2
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	inc	hl
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	ld	a, l
	add	#12
	ld	l, a
	adc	h
	sub	l
	ld	h, a
	ld	b, #12
cell_or0_row:
	ld	a, (de)
	inc	de
	ld	c, a
	ld	a, (de)
	inc	de
	or	(hl)
	ld	(hl), a
	ld	a, l
	sub	#12
	ld	l, a
	ld	a, h
	sbc	#0
	ld	h, a
	ld	a, (hl)
	or	c
	ld	(hl), a
	ld	a, l
	add	#13
	ld	l, a
	adc	h
	sub	l
	ld	h, a
	dec	b
	jr	nz, cell_or0_row
	ret
    __endasm;
}

static void cell_or2(const u8 *g, u8 *buf) __naked {
    (void)g; (void)buf;
    __asm
	ldhl	sp, #2
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	inc	hl
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	ld	a, l
	add	#12
	ld	l, a
	adc	h
	sub	l
	ld	h, a
	ld	b, #12
cell_or2_row:
	ld	a, (de)
	inc	de
	ld	c, a
	ld	a, (de)
	inc	de
	srl	c
	rr	a
	srl	c
	rr	a
	or	(hl)
	ld	(hl), a
	ld	a, l
	sub	#12
	ld	l, a
	ld	a, h
	sbc	#0
	ld	h, a
	ld	a, (hl)
	or	c
	ld	(hl), a
	ld	a, l
	add	#13
	ld	l, a
	adc	h
	sub	l
	ld	h, a
	dec	b
	jr	nz, cell_or2_row
	ret
    __endasm;
}

static void cell_or4(const u8 *g, u8 *buf) __naked {
    (void)g; (void)buf;
    __asm
	ldhl	sp, #2
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	inc	hl
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	ld	a, l
	add	#12
	ld	l, a
	adc	h
	sub	l
	ld	h, a
	ld	b, #12
cell_or4_row:
	ld	a, (de)
	inc	de
	ld	c, a
	ld	a, (de)
	inc	de
	srl	c
	rr	a
	srl	c
	rr	a
	srl	c
	rr	a
	srl	c
	rr	a
	or	(hl)
	ld	(hl), a
	ld	a, l
	sub	#12
	ld	l, a
	ld	a, h
	sbc	#0
	ld	h, a
	ld	a, (hl)
	or	c
	ld	(hl), a
	ld	a, l
	add	#13
	ld	l, a
	adc	h
	sub	l
	ld	h, a
	dec	b
	jr	nz, cell_or4_row
	ret
    __endasm;
}

static void cell_or6(const u8 *g, u8 *buf) __naked {
    (void)g; (void)buf;
    __asm
	ldhl	sp, #2
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	inc	hl
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	ld	a, l
	add	#12
	ld	l, a
	adc	h
	sub	l
	ld	h, a
	ld	b, #12
cell_or6_row:
	ld	a, (de)
	inc	de
	ld	c, a
	ld	a, (de)
	inc	de
	srl	c
	rr	a
	srl	c
	rr	a
	srl	c
	rr	a
	srl	c
	rr	a
	srl	c
	rr	a
	srl	c
	rr	a
	or	(hl)
	ld	(hl), a
	ld	a, l
	sub	#12
	ld	l, a
	ld	a, h
	sbc	#0
	ld	h, a
	ld	a, (hl)
	or	c
	ld	(hl), a
	ld	a, l
	add	#13
	ld	l, a
	adc	h
	sub	l
	ld	h, a
	dec	b
	jr	nz, cell_or6_row
	ret
    __endasm;
}

/* Flush one tile column from the row buffer: n tile rows, both planes
 * from the same byte, xor'd with xm ($FF for a highlighted row).
 *
 * Writes go out in batches of four tile rows. A STAT spin before every
 * write caps the rate at one or two writes per scanline (the rest of the
 * line is mode 2/3). A batch instead syncs to a fresh HBlank (wait for
 * mode 3, then for mode 0) and writes four rows inside the 51 + 20 cycles
 * that are then guaranteed, or, in VBlank, writes straight away when LY
 * reads 144..151, so at least one full line of mode 1 remains. LY is not
 * trusted on its own: during the last VBlank line the register already
 * reads 0 (the line-153 alias), and a batch started there ran into line
 * 0's mode 3 and dropped its writes, one plane of one tile row at a time;
 * that was the streak seen on a real CGB in the last cell of rows that
 * had been highlighted, and it was caught in SameBoy with
 * `watch $8000 to $9800 if ([$ff41] & 3) == 3`, every hit at LY 0.
 * Interrupts are off from the sync to the last write so no handler can eat
 * the window; the latency added is under two scanlines. One exception: a
 * batch that syncs at the end of the frame would wait for the next mode 3 on
 * the far side of VBlank with interrupts off, delaying the VBlank callback
 * that points the BG tile data back at $8000 (the canvas switches to $8800 at
 * LYC 72), so the top lines of the next frame drew from the wrong tiles: the
 * tab strip flickered while the 12px list redrew. LY can already read 144
 * while STAT still says mode 0, so testing for line 143 alone was not enough
 * (SameBoy: the callback's LCDC write landed at LY 3 right after a batch's
 * ei). Any sync from LY >= 143 therefore enables interrupts and waits for LY
 * 145..150 (callback done, VBlank window left) or the next frame, then
 * starts over; only syncs below line 143 wait for mode 3 with interrupts off,
 * and there the next mode 3 is at most about a line away. Rows within a batch
 * never cross a tile (a cell starts on tile row 0 or 4 and n is 12 or 8), so
 * the tile-boundary step is taken between batches only.
 * Frame (sdcccall 0): +2 src  +4 addr  +6 n  +7 xm. */
static void blit_col1(const u8 *src, u16 addr, u8 n, u8 xm) __naked {
    (void)src; (void)addr; (void)n; (void)xm;
    __asm
	ldhl	sp, #7
	ld	c, (hl)
	ldhl	sp, #6
	ld	a, (hl)
	srl	a
	srl	a
	ld	b, a
	ldhl	sp, #4
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ldhl	sp, #2
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
blit_col1_batch:
	di
	ldh	a, (#0xff41)
	and	#3
	cp	#1
	jr	nz, blit_col1_sync
	ldh	a, (#0xff44)
	cp	#144
	jr	c, blit_col1_sync
	cp	#152
	jr	nc, blit_col1_sync
	jr	blit_col1_go
blit_col1_sync:
	ldh	a, (#0xff44)
	cp	#143
	jr	c, blit_col1_m3
	ei
blit_col1_vb:
	ldh	a, (#0xff44)
	cp	#143
	jr	c, blit_col1_batch
	cp	#145
	jr	c, blit_col1_vb
	cp	#151
	jr	c, blit_col1_batch
	jr	blit_col1_vb
blit_col1_m3:
	ldh	a, (#0xff41)
	and	#3
	cp	#3
	jr	nz, blit_col1_m3
blit_col1_w0:
	ldh	a, (#0xff41)
	and	#3
	jr	nz, blit_col1_w0
blit_col1_go:
	ld	a, (hl+)
	xor	c
	ld	(de), a
	inc	e
	ld	(de), a
	inc	de
	ld	a, (hl+)
	xor	c
	ld	(de), a
	inc	e
	ld	(de), a
	inc	de
	ld	a, (hl+)
	xor	c
	ld	(de), a
	inc	e
	ld	(de), a
	inc	de
	ld	a, (hl+)
	xor	c
	ld	(de), a
	inc	e
	ld	(de), a
	inc	de
	ei
	ld	a, e
	and	#0x0F
	jr	nz, blit_col1_next
	ld	a, e
	add	#0x30
	ld	e, a
	ld	a, d
	adc	#1
	ld	d, a
blit_col1_next:
	dec	b
	jr	nz, blit_col1_batch
	ret
    __endasm;
}

/* Generic path: merge one 10x12 cell whose leftmost pixel is at x into
 * the canvas with any ink/paper pair.
 * g points at 12 big-endian 16-bit rows (bit 15 = left pixel); the mask
 * selects which of the 16 shifted bits belong to the cell. */
static void blit_cell(const u8 *g, u8 x, u8 y) {
    u8 ink, paper, a0, x0, a1, x1, n;
    u16 mask;

    if (y >= SCREEN_H) {
        return;
    }
    n = ROW_H;
    if ((u8)(SCREEN_H - y) < ROW_H) {
        n = (u8)(SCREEN_H - y);
    }
    ink = INK;
    paper = PAPER;
    a0 = ((ink ^ paper) & 1) ? 0xFF : 0;
    x0 = (paper & 1) ? 0xFF : 0;
    a1 = ((ink ^ paper) & 2) ? 0xFF : 0;
    x1 = (paper & 2) ? 0xFF : 0;
    mask = (u16)0xFFC0 >> (x & 7);
    blit_rows(g, (u16)(x >> 3) << 4, (u8)(x & 7), (u8)(mask >> 8), (u8)mask, a0, x0, a1, x1, y, n);
}

/* The row loop. Per glyph row: fetch the 16-bit row, shift it right by sh
 * (0..7), compose both planes, mask them, then merge the left tile and, if
 * the mask reaches it, the right tile (+16) into VRAM with a masked
 * read-modify-write. Every merge is one DiNest .. EiNest critical section
 * around the STAT wait and the two byte accesses (14 M-cycles after the
 * check), so no interrupt can push an access into mode 3 after the check
 * passed: a mode-3 write is dropped and a read returns $FF on a DMG, which
 * is exactly the one-tile streak the stock DrawGlyph (same check, interrupts
 * enabled) leaves now and then. VRAM addresses come from GfxRowTable
 * (00:2fbb, pixel row -> tile-column-0 address) plus the tile offset.
 *
 * Frame (sdcccall 0, right-to-left, u8 = 1 byte) after the 4-byte scratch:
 *   +6 g  +8 tile  +10 sh  +11 mhi  +12 mlo  +13 a0  +14 x0  +15 a1  +16 x1
 *   +17 y  +18 n;  scratch +0 v0hi  +1 v0lo  +2 v1hi  +3 v1lo. */
static void blit_rows(const u8 *g, u16 tile, u8 sh, u8 mhi, u8 mlo,
                      u8 a0, u8 x0, u8 a1, u8 x1, u8 y, u8 n) __naked {
    (void)g; (void)tile; (void)sh; (void)mhi; (void)mlo;
    (void)a0; (void)x0; (void)a1; (void)x1; (void)y; (void)n;
    __asm
	add	sp, #-4
blit_rows_row:
	; bc = glyph row, g += 2
	ldhl	sp, #6
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ld	a, (de)
	ld	b, a
	inc	de
	ld	a, (de)
	ld	c, a
	inc	de
	ld	(hl), d
	dec	hl
	ld	(hl), e
	; shift right by sh
	ldhl	sp, #10
	ld	a, (hl)
	or	a
	jr	z, blit_rows_noshift
blit_rows_shift:
	srl	b
	rr	c
	dec	a
	jr	nz, blit_rows_shift
blit_rows_noshift:
	; plane 0: v = (bits & a0) ^ x0, masked -> scratch +0/+1
	ldhl	sp, #13
	ld	a, (hl+)
	ld	d, a
	ld	e, (hl)
	ld	a, b
	and	d
	xor	e
	ldhl	sp, #11
	and	(hl)
	ldhl	sp, #0
	ld	(hl+), a
	ld	a, c
	and	d
	xor	e
	ldhl	sp, #12
	and	(hl)
	ldhl	sp, #1
	ld	(hl), a
	; plane 1: v = (bits & a1) ^ x1, masked -> scratch +2/+3
	ldhl	sp, #15
	ld	a, (hl+)
	ld	d, a
	ld	e, (hl)
	ld	a, b
	and	d
	xor	e
	ldhl	sp, #11
	and	(hl)
	ldhl	sp, #2
	ld	(hl+), a
	ld	a, c
	and	d
	xor	e
	ldhl	sp, #12
	and	(hl)
	ldhl	sp, #3
	ld	(hl), a
	; de = GfxRowTable[y] + tile
	ldhl	sp, #17
	ld	l, (hl)
	ld	h, #0
	add	hl, hl
	ld	de, #_GfxRowTable
	add	hl, de
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	push	hl
	ldhl	sp, #10
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	pop	hl
	add	hl, de
	ld	d, h
	ld	e, l
	; left tile: (old & ~mhi) | v0hi ; (old & ~mhi) | v1hi
	ldhl	sp, #11
	ld	a, (hl)
	or	a
	jr	z, blit_rows_noleft
	cpl
	ld	c, a
	ldhl	sp, #0
	ld	b, (hl)
	inc	hl
	inc	hl
	call	_DiNest
blit_rows_waitl:
	ldh	a, (#0xff41)
	bit	1, a
	jr	nz, blit_rows_waitl
	ld	a, (de)
	and	c
	or	b
	ld	(de), a
	inc	de
	ld	a, (de)
	and	c
	or	(hl)
	ld	(de), a
	call	_EiNest
	dec	de
blit_rows_noleft:
	; right tile (+16): (old & ~mlo) | v0lo ; (old & ~mlo) | v1lo
	ldhl	sp, #12
	ld	a, (hl)
	or	a
	jr	z, blit_rows_noright
	cpl
	ld	c, a
	ld	hl, #16
	add	hl, de
	ld	d, h
	ld	e, l
	ldhl	sp, #1
	ld	b, (hl)
	inc	hl
	inc	hl
	call	_DiNest
blit_rows_waitr:
	ldh	a, (#0xff41)
	bit	1, a
	jr	nz, blit_rows_waitr
	ld	a, (de)
	and	c
	or	b
	ld	(de), a
	inc	de
	ld	a, (de)
	and	c
	or	(hl)
	ld	(de), a
	call	_EiNest
blit_rows_noright:
	; next pixel row
	ldhl	sp, #17
	inc	(hl)
	ldhl	sp, #18
	dec	(hl)
	jp	nz, blit_rows_row
	add	sp, #4
	ret
    __endasm;
}
