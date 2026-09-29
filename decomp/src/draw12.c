/* 12x12 text renderer for the file browser (prototype, docs/font12.md).
 *
 * The kernel draws the browser into a 20x18 tile canvas ($8100, one tile
 * per 8x8 cell, pixel row py of tile column tx lives at
 * GfxRowTable[py] + tx*16, planes in consecutive bytes). DrawGlyph is a
 * pure 8x8 blitter: one glyph == one tile, so the stock text grid is 8px.
 *
 * This renderer places 12x12 cells at arbitrary pixel offsets instead. A
 * 12-wide glyph at x = 12*col straddles two tiles (x & 7 is 0 or 4, so the
 * 12 bits plus the shift never exceed 16), and a 12-tall cell straddles two
 * or three tile rows. Nothing is precomposed: each glyph row is shifted to
 * its pixel position and merged into VRAM with a masked read-modify-write,
 * so the neighbouring cells' pixels that share the tile are left alone.
 * Ink and paper come from the draw state StoreDrawParams sets ($d734 /
 * $d735), so the browser's selection bar (ink 0 / paper 3) inverts the cell
 * exactly as before, and every cell paints all 144 of its pixels so the bar
 * is continuous.
 *
 * Geometry: 13 cells across (156 px; the 4 px slack at the right edge is
 * painted in paper when a string runs to the last cell) and rows of 12 px
 * starting under the 16 px tab strip, so tile row r >= 2 maps to
 * y = 16 + 12*(r - 2): ten list rows, r = 2..11.
 *
 * Entry point DrawString12 keeps DrawString's (s, len, x, y) argument order
 * so the bank-0 far-call stub FarCallDrawString12 (00:05c0) can be dropped
 * in for DrawString by re-pinning. It is reached through FarCallTrampoline
 * from a stub that is itself `call`ed, so the trampoline's three words sit
 * between the stub's return address and the arguments: the first real
 * argument is at sp+8, hence the three pad parameters (an inline
 * `call FarCallTrampoline` stub would need only two, docs/browser-hide-filter.md). Like
 * DrawString, a NUL inside len pads the rest with spaces, and len is capped
 * at the cells left on the row.
 *
 * Bank 2, injected at 02:5800 (must stay the first definition in the file);
 * the glyph table is a separate raw block at 02:6000 (Font12), produced by
 * scripts/font12-pack.py from decomp/font12/font12.txt.
 *
 *   python3 tools/inject.py src/draw12.c $V 2 5800 DrawString12 \\
 *       --pin wDrawColor=d734 --pin wDrawColorB=d735 --pin wIntNest=d6d0 \\
 *       --pin GfxRowTable=2fbb --pin Font12=6000 --pin DiNest=06fd --pin EiNest=0706 --apply
 */

typedef unsigned char u8;
typedef unsigned int u16;

/* Kernel symbols, all --pin'd so scripts/port-mod.py can re-pin them for a
 * kernel whose WRAM map differs (1.04e shifts $d6cc and up). */
extern volatile u8 wDrawColor;     /* $d734 ink   (StoreDrawParams) */
extern volatile u8 wDrawColorB;    /* $d735 paper */
extern volatile u8 wIntNest;       /* $d6d0 DiNest depth */
extern const u16 GfxRowTable[];    /* 00:2fbb pixel row -> VRAM address of tile column 0 */
extern const u8 Font12[];          /* 02:6000, 101 glyphs x 24 bytes, then the same shifted right by 4 (scripts/font12-pack.py) */
extern void DiNest(void);          /* 00:06fd */
extern void EiNest(void);          /* 00:0706 */

#define INK   wDrawColor
#define PAPER wDrawColorB
#define INT_NEST wIntNest
#define ROWTAB GfxRowTable
#define FONT12 Font12
#define FONT12_SH4 (Font12 + 101 * 24)

#define CELL 12
#define COLS 13
#define STRIP_H 16
#define SCREEN_H 144

static void blit_cell(const u8 *g, u8 x, u8 y, u16 mask);
static void blit_rows(const u8 *g, u16 tile, u8 sh, u8 mhi, u8 mlo,
                      u8 a0, u8 x0, u8 a1, u8 x1, u8 y, u8 n) __naked;
static void blit_fast0(const u8 *g, u16 addr, u8 n) __naked;
static void blit_fast4(const u8 *g, u16 addr, u8 n) __naked;
static void blit_col1(const u8 *src, u16 addr, u8 n, u8 xm) __naked;
static void blit_col2(const u8 *src, u16 addr, u8 n, u8 xm) __naked;
static void compose_mid(const u8 *a, const u8 *b4, u8 *buf) __naked;
static u8 glyph_at(const u8 *s, u8 i, u8 *ended);
static u8 glyph_index(u8 c);

void DrawString12(u16 far_pad_thunk, u16 far_pad_af, u16 far_pad_ret, const u8 *s, u8 len, u8 col, u8 row) {
    u8 i, x, y, left, ended, n, ink, paper, xm;
    u8 mid[12];
    u16 addr;
    const u8 *ga, *gb;

    (void)far_pad_thunk;
    (void)far_pad_af;
    (void)far_pad_ret;
    if (col >= COLS) {
        return;
    }
    y = (row >= 2) ? (u8)(STRIP_H + (row - 2) * CELL) : (u8)(row * 8);
    if (y >= SCREEN_H) {
        return;
    }
    left = (u8)(COLS - col);
    if (len == 0 || len > left) {
        len = left;
    }
    x = (u8)(col * CELL);
    ended = 0;
    ink = INK;
    paper = PAPER;
    if (INT_NEST != 0 || (ink | paper) != 3 || (ink & paper) != 0) {
        /* general ink/paper: cell by cell through the generic loop */
        for (i = 0; i < len; i++, x += CELL) {
            blit_cell(FONT12 + (u16)glyph_at(s, i, &ended) * 24, x, y, 0xFFF0);
        }
        if ((u8)(col + len) == COLS) {
            blit_cell(FONT12, (u8)(COLS * CELL), y, 0xF000);
        }
        return;
    }
    n = CELL;
    if ((u8)(SCREEN_H - y) < CELL) {
        n = (u8)((SCREEN_H - y) & 0xFC);   /* batches of 4 rows; only the clipped bottom row is short (8) */
        if (n == 0) {
            return;
        }
    }
    xm = paper ? 0xFF : 0;
    i = 0;
    if (col & 1) {
        /* odd start: one cell alone, its left tile shared with the cell before */
        blit_cell(FONT12 + (u16)glyph_at(s, i, &ended) * 24, x, y, 0xFFF0);
        i++;
        x += CELL;
    }
    while ((u8)(len - i) >= 2) {
        /* an even cell and the next one cover three whole tiles: pure writes */
        ga = FONT12 + (u16)glyph_at(s, i, &ended) * 24;
        gb = FONT12_SH4 + (u16)glyph_at(s, (u8)(i + 1), &ended) * 24;
        addr = ROWTAB[y] + ((u16)(x >> 3) << 4);
        compose_mid(ga, gb, mid);
        blit_col2(ga, addr, n, xm);
        blit_col1(mid, (u16)(addr + 16), n, xm);
        blit_col2(gb + 1, (u16)(addr + 32), n, xm);
        i += 2;
        x += 2 * CELL;
    }
    if (i < len) {
        ga = FONT12 + (u16)glyph_at(s, i, &ended) * 24;
        if ((u8)(col + i) == COLS - 1) {
            /* cell 12 plus the 4 px slack: two whole tiles, the slack from the blank glyph */
            addr = ROWTAB[y] + ((u16)(x >> 3) << 4);
            compose_mid(ga, FONT12_SH4, mid);
            blit_col2(ga, addr, n, xm);
            blit_col1(mid, (u16)(addr + 16), n, xm);
        } else {
            blit_cell(ga, x, y, 0xFFF0);
        }
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

/* Pair path. Cells 2k and 2k+1 start at x = 24k, so together they cover
 * tiles 3k, 3k+1 and 3k+2 exactly and every byte of those tile rows is ours:
 * no reads, no masks. Tile 3k is the first cell's high byte, tile 3k+2 is
 * the low byte of the second cell taken from the pre-shifted table
 * (FONT12_SH4, rows >> 4), and the shared middle tile is
 * (first.lo & $F0) | shifted.hi, composed once into a 12-byte buffer by
 * compose_mid. Each tile is then written top to bottom by blit_col1/2 (the
 * source stride is 1 for the buffer, 2 for a table row), with an xor mask
 * ($FF for a highlighted row) applied on the way.
 *
 * Writes go out in batches of four tile rows. A STAT spin before every
 * write caps the rate at one or two writes per scanline (the rest of the
 * line is mode 2/3), which is what made a 13-cell row cost ~20k cycles. A
 * batch instead syncs to a fresh HBlank (wait for mode 3, then for mode 0)
 * and writes four rows inside the 51 + 20 cycles that are then guaranteed
 * (56 cycles from the sample to the last write at stride 2), or, in VBlank,
 * writes straight away when LY reads 144..151, so at least one full line of
 * mode 1 remains. LY is not trusted on its own: during the last VBlank
 * line the register already reads 0 (the line-153 alias), and a batch
 * started there ran into line 0's mode 3 and dropped its writes, one plane
 * of one tile row at a time; that was the streak seen on a real CGB in the
 * last cell of rows that had been highlighted, and it was caught in SameBoy
 * with `watch $8000 to $9800 if ([$ff41] & 3) == 3`, every hit at LY 0.
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
 * the tile-boundary step is taken between batches only. */
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

static void blit_col2(const u8 *src, u16 addr, u8 n, u8 xm) __naked {
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
blit_col2_batch:
	di
	ldh	a, (#0xff41)
	and	#3
	cp	#1
	jr	nz, blit_col2_sync
	ldh	a, (#0xff44)
	cp	#144
	jr	c, blit_col2_sync
	cp	#152
	jr	nc, blit_col2_sync
	jr	blit_col2_go
blit_col2_sync:
	ldh	a, (#0xff44)
	cp	#143
	jr	c, blit_col2_m3
	ei
blit_col2_vb:
	ldh	a, (#0xff44)
	cp	#143
	jr	c, blit_col2_batch
	cp	#145
	jr	c, blit_col2_vb
	cp	#151
	jr	c, blit_col2_batch
	jr	blit_col2_vb
blit_col2_m3:
	ldh	a, (#0xff41)
	and	#3
	cp	#3
	jr	nz, blit_col2_m3
blit_col2_w0:
	ldh	a, (#0xff41)
	and	#3
	jr	nz, blit_col2_w0
blit_col2_go:
	ld	a, (hl+)
	inc	hl
	xor	c
	ld	(de), a
	inc	e
	ld	(de), a
	inc	de
	ld	a, (hl+)
	inc	hl
	xor	c
	ld	(de), a
	inc	e
	ld	(de), a
	inc	de
	ld	a, (hl+)
	inc	hl
	xor	c
	ld	(de), a
	inc	e
	ld	(de), a
	inc	de
	ld	a, (hl+)
	inc	hl
	xor	c
	ld	(de), a
	inc	e
	ld	(de), a
	inc	de
	ei
	ld	a, e
	and	#0x0F
	jr	nz, blit_col2_next
	ld	a, e
	add	#0x30
	ld	e, a
	ld	a, d
	adc	#1
	ld	d, a
blit_col2_next:
	dec	b
	jr	nz, blit_col2_batch
	ret
    __endasm;
}

/* buf[r] = (a[2r+1] & $F0) | b4[2r] for r = 0..11.  Frame after the 1-byte
 * counter: +3 a  +5 b4  +7 buf. */
static void compose_mid(const u8 *a, const u8 *b4, u8 *buf) __naked {
    (void)a; (void)b4; (void)buf;
    __asm
	add	sp, #-1
	ldhl	sp, #0
	ld	(hl), #12
	ldhl	sp, #3
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	inc	de
	ldhl	sp, #5
	ld	a, (hl+)
	ld	c, a
	ld	b, (hl)
	ldhl	sp, #7
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
compose_mid_row:
	ld	a, (de)
	and	#0xF0
	ld	(hl), a
	ld	a, (bc)
	or	(hl)
	ld	(hl+), a
	inc	de
	inc	de
	inc	bc
	inc	bc
	push	hl
	ldhl	sp, #2
	dec	(hl)
	pop	hl
	jr	nz, compose_mid_row
	add	sp, #1
	ret
    __endasm;
}

/* Merge one 12-row cell whose leftmost pixel is at x (x & 7 must be 0 or 4)
 * into the canvas. g points at 12 big-endian 16-bit rows (bit 15 = left
 * pixel); mask selects which of the 16 shifted bits belong to the cell.
 *
 * Fast path: the browser only ever draws ink 3 on paper 0 or the inverse,
 * and for those both bit planes are the same byte, so blit_fast0/4 (one per
 * shift) write each plane pair from a single value; a highlighted cell just
 * blits a pre-inverted copy of the glyph. Any other ink/paper pair, or a
 * caller that holds DiNest (the fast loops use bare di/ei), takes the
 * general blit_rows, which composes both planes per row. */
static void blit_cell(const u8 *g, u8 x, u8 y, u16 mask) {
    u8 ink, paper, a0, x0, a1, x1, n, i;
    u8 tmp[24];

    if (y >= SCREEN_H) {
        return;
    }
    n = CELL;
    if ((u8)(SCREEN_H - y) < CELL) {
        n = (u8)(SCREEN_H - y);
    }
    ink = INK;
    paper = PAPER;
    if (INT_NEST == 0 && mask == 0xFFF0 && (ink | paper) == 3 && (ink & paper) == 0) {
        if (paper) {
            for (i = 0; i < 24; i++) {
                tmp[i] = (u8)~g[i];
            }
            g = tmp;
        }
        if (x & 7) {
            blit_fast4(g, ROWTAB[y] + ((u16)(x >> 3) << 4), n);
        } else {
            blit_fast0(g, ROWTAB[y] + ((u16)(x >> 3) << 4), n);
        }
        return;
    }
    a0 = ((ink ^ paper) & 1) ? 0xFF : 0;
    x0 = (paper & 1) ? 0xFF : 0;
    a1 = ((ink ^ paper) & 2) ? 0xFF : 0;
    x1 = (paper & 2) ? 0xFF : 0;
    mask >>= (x & 7);
    blit_rows(g, (u16)(x >> 3) << 4, (u8)(x & 7), (u8)(mask >> 8), (u8)mask, a0, x0, a1, x1, y, n);
}

/* Fast loops. Both planes of a tile row get the same byte. addr is the VRAM
 * address of the cell's first pixel row in its left tile (GfxRowTable[y] +
 * tile*16); rows advance by 2 within a tile (a 16-bit inc: a tile at $xxF0
 * has its last row at $xxFE, so the low byte alone would wrap) and by
 * $140 - 16 + 2 across a tile boundary, which is where the low nibble of
 * the address wraps to 0 (tiles are 16-aligned). Every VRAM access sits in its own di .. ei window
 * around a STAT check: a plain write of both planes (6 M-cycles after the
 * check) or a single read-modify-write byte (7). A last-moment pass of mode
 * 0 leaves the 20-cycle mode 2 before VRAM locks, and the sample itself is
 * 4 cycles before the first access, so 11 is the worst case; a two-byte RMW
 * (19) was seen to lose its second write on a DMG now and then.
 *
 * blit_fast0 (x & 7 == 0): the left tile is the cell's own (write both
 * planes from the high byte), the right tile keeps its low nibble (old & $0F
 * | low byte & $F0).
 * blit_fast4 (x & 7 == 4): the left tile keeps its high nibble (old & $F0 |
 * bits >> 12), the right tile is the cell's own ((hi << 4) | (lo >> 4)).
 *
 * Frame (sdcccall 0): +2 g  +4 addr  +6 n.  Registers: hl glyph, de left
 * tile, b rows left, c/a temporaries. */
static void blit_fast0(const u8 *g, u16 addr, u8 n) __naked {
    (void)g; (void)addr; (void)n;
    __asm
	ldhl	sp, #6
	ld	b, (hl)
	ldhl	sp, #4
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ldhl	sp, #2
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
blit_fast0_row:
	di
blit_fast0_w1:
	ldh	a, (#0xff41)
	bit	1, a
	jr	nz, blit_fast0_w1
	ld	a, (hl+)
	ld	(de), a
	inc	e
	ld	(de), a
	dec	e
	ei
	ld	a, (hl+)
	and	#0xF0
	ld	c, a
	push	hl
	ld	a, e
	add	#16
	ld	l, a
	ld	a, d
	adc	#0
	ld	h, a
	di
blit_fast0_w2:
	ldh	a, (#0xff41)
	bit	1, a
	jr	nz, blit_fast0_w2
	ld	a, (hl)
	and	#0x0F
	or	c
	ld	(hl+), a
	ei
	di
blit_fast0_w3:
	ldh	a, (#0xff41)
	bit	1, a
	jr	nz, blit_fast0_w3
	ld	a, (hl)
	and	#0x0F
	or	c
	ld	(hl), a
	ei
	pop	hl
	inc	de
	inc	de
	ld	a, e
	and	#0x0F
	jr	nz, blit_fast0_next
	ld	a, e
	add	#0x30
	ld	e, a
	ld	a, d
	adc	#1
	ld	d, a
blit_fast0_next:
	dec	b
	jp	nz, blit_fast0_row
	ret
    __endasm;
}

static void blit_fast4(const u8 *g, u16 addr, u8 n) __naked {
    (void)g; (void)addr; (void)n;
    __asm
	ldhl	sp, #6
	ld	b, (hl)
	ldhl	sp, #4
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	ldhl	sp, #2
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
blit_fast4_row:
	push	hl
	ld	a, (hl+)
	ld	l, (hl)
	swap	a
	ld	h, a
	swap	l
	ld	a, h
	and	#0xF0
	ld	c, a
	ld	a, l
	and	#0x0F
	or	c
	ld	c, a
	ld	a, h
	and	#0x0F
	ld	l, a
	di
blit_fast4_w1:
	ldh	a, (#0xff41)
	bit	1, a
	jr	nz, blit_fast4_w1
	ld	a, (de)
	and	#0xF0
	or	l
	ld	(de), a
	ei
	inc	e
	di
blit_fast4_w1b:
	ldh	a, (#0xff41)
	bit	1, a
	jr	nz, blit_fast4_w1b
	ld	a, (de)
	and	#0xF0
	or	l
	ld	(de), a
	ei
	ld	a, e
	add	#15
	ld	l, a
	ld	a, d
	adc	#0
	ld	h, a
	dec	e
	di
blit_fast4_w2:
	ldh	a, (#0xff41)
	bit	1, a
	jr	nz, blit_fast4_w2
	ld	a, c
	ld	(hl+), a
	ld	(hl), a
	ei
	pop	hl
	inc	hl
	inc	hl
	inc	de
	inc	de
	ld	a, e
	and	#0x0F
	jr	nz, blit_fast4_next
	ld	a, e
	add	#0x30
	ld	e, a
	ld	a, d
	adc	#1
	ld	d, a
blit_fast4_next:
	dec	b
	jp	nz, blit_fast4_row
	ret
    __endasm;
}

/* The row loop. Per glyph row: fetch the 16-bit row, shift it right by sh
 * (0 or 4), compose both planes, mask them, then merge the left tile and, if
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
	; shift right by 4 when sh != 0
	ldhl	sp, #10
	ld	a, (hl)
	or	a
	jr	z, blit_rows_noshift
	srl	b
	rr	c
	srl	b
	rr	c
	srl	b
	rr	c
	srl	b
	rr	c
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
