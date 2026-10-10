/* 12px text renderer for the file browser (docs/font12.md).
 *
 * The kernel draws the browser into a 20x18 tile canvas ($8100, one tile
 * per 8x8 cell, pixel row py of tile column tx lives at
 * GfxRowTable[py] + tx*16, planes in consecutive bytes). DrawGlyph is a
 * pure 8x8 blitter: one glyph == one tile, so the stock text grid is 8px.
 *
 * This renderer sets proportional 12px-tall text at arbitrary pixel
 * offsets instead. Fit12 (layout12.c) lays the string out first: each glyph
 * has its own advance and neighbors kern, so a row holds as many
 * characters as fit in the 148 px right of the icon (about 18 of a typical
 * name, 15 of the widest). Rows are 12px tall under the 16px tab strip, so
 * tile row r >= 2 maps to y = 20 + 12*(r - 2): ten list rows, r = 2..11.
 *
 * Nothing is precomposed in ROM. The whole row is composed in a WRAM
 * buffer, one 12-byte column per tile: every glyph row is a 16-bit word
 * with the leftmost ink pixel in bit 15, shifted right by x & 7 (one
 * unrolled routine per shift, cell_or0..7) and OR'd into the tile it starts
 * in and the next one; kerned glyphs simply overlap in the buffer. A tile
 * only partly covered by the string (the marquee starts at x = 12, 4px into
 * tile 1, next to the icon) is read from VRAM first so the icon's pixels
 * survive. Everything right of the last glyph stays paper: the row is
 * always painted to its end, so the selection bar is continuous and a
 * shorter name leaves nothing of a longer one behind.
 *
 * The fast path (the browser's ink 3 on paper 0 or the inverse, both planes
 * equal) flushes the buffer with blit_col1: pure writes, four tile rows per
 * HBlank/VBlank batch. Any other ink/paper pair, or a caller inside a DiNest
 * section, flushes it with flush_rmw: one masked read-modify-write per row
 * inside a DiNest .. EiNest window.
 *
 * Ink and paper come from the draw state StoreDrawParams sets ($d734 /
 * $d735), so the browser's selection bar (ink 0 / paper 3) inverts the row
 * exactly as before.
 *
 * Entry point DrawString12 keeps DrawString's (s, len, col, row) argument
 * order so the bank-0 far-call stub FarCallDrawString12 (00:05c0) can be
 * dropped in for DrawString by re-pinning. col is 0 for the icon cell and 1
 * for the name field (x = 12, an icon's advance; see Fit12); len caps the
 * characters, 0 meaning up to the NUL. It is reached through
 * FarCallTrampoline from a stub that is itself `call`ed, so the
 * trampoline's three words sit between the stub's return address and the
 * arguments: the first real argument is at sp+8, hence the three pad
 * parameters (an inline `call FarCallTrampoline` stub would need only two,
 * docs/browser-hide-filter.md).
 *
 * Bank 2, injected at 02:7500 (must stay the first definition in the file);
 * the glyph bitmaps are a separate raw block at 02:6000 (Font12, 101 glyphs
 * x 12 rows x 2 bytes, left-trimmed, pixels from bit 15) and the metrics
 * at 02:6978 (Font12Metrics), both produced by scripts/font12-pack.py from
 * kernel/font12/font12.txt.
 *
 *   python3 tools/inject.py src/draw12.c $V 2 7500 DrawString12 \\
 *       --pin wDrawColor=d734 --pin wDrawColorB=d735 --pin wIntNest=d6d0 \\
 *       --pin GfxRowTable=2fbb --pin Font12=6000 --pin Font12Metrics=6978 \\
 *       --pin Fit12=7100 --pin DiNest=06fd --pin EiNest=0706 --replace --apply
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
extern const u8 Font12Metrics[];   /* 02:6978, advances first (layout12.c has the layout) */
extern volatile u8 hClip12;        /* $fff9: right edge of the next draw, 0 = the row's (x 160) */
extern void DiNest(void);          /* 00:06fd */
extern void EiNest(void);          /* 00:0706 */
extern u8 Fit12(u16 pad_thunk, u16 pad_af, const u8 *s, u8 len, u8 col, u8 *xs);   /* 02:7100 */

#define INK   wDrawColor
#define PAPER wDrawColorB
#define INT_NEST wIntNest
#define ROWTAB GfxRowTable
#define FONT12 Font12

#define ROW_W 160
#define ROW_H 12
#define STRIP_H 20                 /* 12px tab strip: labels y 0..11, rule y 12 (tabstrip12.c) */
#define SCREEN_H 144
#define GLYPH 24
#define MAX_TILES 20
#define MAX_GLYPHS 40              /* Fit12 never places more; xs[] size */
#define M_ADV 0                    /* Font12Metrics: advance table */
#define ICON0 96                   /* glyph index of the first icon */

static void blit_col1(const u8 *src, u16 addr, u8 n, u8 xm) __naked;
static void fill0(u8 *p, u8 n4) __naked;
static void vram_rd_col(u16 addr, u8 *dst, u8 n) __naked;
static void vram_rmw2(u16 addr, u8 keep, u8 v0, u8 v1) __naked;
static void cell_or0(const u8 *g, u8 *buf) __naked;
static void cell_or1(const u8 *g, u8 *buf) __naked;
static void cell_or2(const u8 *g, u8 *buf) __naked;
static void cell_or3(const u8 *g, u8 *buf) __naked;
static void cell_or4(const u8 *g, u8 *buf) __naked;
static void cell_or5(const u8 *g, u8 *buf) __naked;
static void cell_or6(const u8 *g, u8 *buf) __naked;
static void cell_or7(const u8 *g, u8 *buf) __naked;
static void preserve(u8 *dst, u16 addr, u8 n, u8 keep, u8 xm);
static void flush_rmw(const u8 *buf, u16 addr, u8 n, u8 nt, u8 kf, u8 kl, u8 ink, u8 paper);
static u8 glyph_index(u8 c);

void DrawString12(u16 far_pad_thunk, u16 far_pad_af, u16 far_pad_ret, const u8 *s, u8 len, u8 col, u8 row) {
    u8 i, x, y, n, ink, paper, xm, x0, t0, nt, kf, kl, xe, cnt, fast;
    /* one spare column: a glyph ending in tile 19 still ORs its (zero) low
     * byte into "tile 20" */
    u8 buf[(MAX_TILES + 1) * ROW_H];
    u8 xs[MAX_GLYPHS];
    u16 addr;
    const u8 *g;
    u8 *p;

    (void)far_pad_thunk;
    (void)far_pad_af;
    (void)far_pad_ret;
    /* row >= 18 (past the last tile row) is a pixel y, for callers that
     * space their rows themselves (the START overlay, lastrom_box.c). It is
     * rounded down to a multiple of 4: the flush's 4-row batches must not
     * cross a tile. */
    if (row >= 18) {
        y = (u8)(row & 0xFC);
    } else {
        y = (row >= 2) ? (u8)(STRIP_H + (row - 2) * ROW_H) : (u8)(row * 8);
    }
    if (y >= SCREEN_H) {
        return;
    }
    n = ROW_H;
    if ((u8)(SCREEN_H - y) < ROW_H) {
        n = (u8)(SCREEN_H - y);
    }
    /* col 0: x 0 (the icon cell); 1: the name field, an icon's advance in;
     * >= 2: a pixel x (the tab strip's labels, tabstrip12.c). Same rule in
     * Fit12. */
    x0 = col >= 2 ? col : col ? Font12Metrics[M_ADV + ICON0] : 0;
    t0 = (u8)(x0 >> 3);
    /* The row is painted from x0 to its right edge: x 160, or hClip12 when
     * a caller set one (the SET pane's fields, settext.c). Fit12 reads the
     * same limit, so no ink crosses it; the last tile keeps its pixels
     * right of the limit (kl), like the first keeps those left of x0. */
    xe = hClip12;
    if (xe == 0 || xe > ROW_W) {
        xe = ROW_W;
    }
    if (xe <= x0) {
        return;
    }
    nt = (u8)((u8)((u8)(xe + 7) >> 3) - t0);
    kl = (xe & 7) ? (u8)(0xFF >> (xe & 7)) : 0;
    /* the first tile keeps the pixels left of the field (the icon's) */
    kf = (x0 & 7) ? (u8)(0xFF << (8 - (x0 & 7))) : 0;
    addr = ROWTAB[y] + ((u16)t0 << 4);
    ink = INK;
    paper = PAPER;
    xm = paper ? 0xFF : 0;
    fast = (u8)(INT_NEST == 0 && (ink | paper) == 3 && (ink & paper) == 0);
    fill0(buf, (u8)((nt + 1) * 3));
    if (fast) {
        n &= 0xFC;                     /* batches of 4 rows; only the clipped bottom row is short (8) */
        if (n == 0) {
            return;
        }
        if (kf) {
            preserve(buf, addr, n, kf, xm);   /* before the glyphs OR into that column */
        }
    }
    cnt = Fit12(0, 0, s, len, col, xs);
    for (i = 0; i < cnt; i++) {
        x = xs[i];
        g = FONT12 + (u16)glyph_index(s[i]) * GLYPH;
        p = buf + (u8)((u8)((x >> 3) - t0) * ROW_H);
        switch (x & 7) {
        case 0:  cell_or0(g, p); break;
        case 1:  cell_or1(g, p); break;
        case 2:  cell_or2(g, p); break;
        case 3:  cell_or3(g, p); break;
        case 4:  cell_or4(g, p); break;
        case 5:  cell_or5(g, p); break;
        case 6:  cell_or6(g, p); break;
        default: cell_or7(g, p); break;
        }
    }
    if (!fast) {
        flush_rmw(buf, addr, n, nt, kf, kl, ink, paper);
        return;
    }
    p = buf;
    for (i = 0; i < nt; i++, p += ROW_H, addr += 16) {
        if (kl && i == (u8)(nt - 1)) {
            /* the last tile's pixels right of the limit: read into the
             * spare column next to it (the glyphs are composed by now) and
             * merge; no ink reaches that side of the tile */
            preserve(p + ROW_H, addr, n, kl, xm);
            for (x = 0; x < n; x++) {
                p[x] |= p[ROW_H + x];
            }
        }
        blit_col1(p, addr, n, xm);
    }
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

/* Generic flush: any ink/paper pair, nesting-safe. Each plane byte is
 * (bits & a) ^ x, where a selects the plane bits that differ between ink
 * and paper and x is paper's bit; the first tile column keeps its pixels
 * outside the field (kf). Row addresses step by 2 within a tile and by
 * $130 + 2 across a tile boundary, where the low nibble wraps to 0. */
static void flush_rmw(const u8 *buf, u16 addr, u8 n, u8 nt, u8 kf, u8 kl, u8 ink, u8 paper) {
    u8 a0, x0, a1, x1, i, r, keep, v;
    u16 a;

    a0 = ((ink ^ paper) & 1) ? 0xFF : 0;
    x0 = (paper & 1) ? 0xFF : 0;
    a1 = ((ink ^ paper) & 2) ? 0xFF : 0;
    x1 = (paper & 2) ? 0xFF : 0;
    for (i = 0; i < nt; i++, buf += ROW_H, addr += 16) {
        keep = i ? 0 : kf;
        if (i == (u8)(nt - 1)) {
            keep |= kl;
        }
        a = addr;
        for (r = 0; r < n; r++) {
            v = buf[r];
            vram_rmw2(a, keep, (u8)(((v & a0) ^ x0) & ~keep), (u8)(((v & a1) ^ x1) & ~keep));
            a += 2;
            if ((a & 0x0F) == 0) {
                a += 0x130;
            }
        }
    }
}

static u8 glyph_index(u8 c) {
    if (c >= 0x20 && c < 0x80) {
        return (u8)(c - 0x20);
    }
    if (c >= 0xC0 && c <= 0xC4) {
        return (u8)(ICON0 + (c - 0xC0));
    }
    return (u8)('?' - 0x20);
}

/* Zero 4*n4 bytes at p.  Frame (sdcccall 0): +2 p  +4 n4.
 *
 * Also defines CELL_OR, the body shared by cell_or0..7 below: OR one glyph
 * into the row buffer, shifted right by n. g points at 12 big-endian
 * 16-bit rows (bit 15 = leftmost pixel), buf at the 12-byte column of the
 * tile the glyph starts in; the column of the next tile follows at
 * buf + 12. Each row's high byte is OR'd into this tile's row and its low
 * byte into the next tile's. Registers: de glyph, hl buffer (kept on the
 * next tile's row between rows), c high byte, a low byte, b rows left.
 * Frame (sdcccall 0): +2 g  +4 buf. The assembler expands the macro once
 * per routine, each with its own local label. */
static void fill0(u8 *p, u8 n4) __naked {
    (void)p; (void)n4;
    __asm
	.macro	CELL_OR n
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
1$:
	ld	a, (de)
	inc	de
	ld	c, a
	ld	a, (de)
	inc	de
	.rept	n
	srl	c
	rr	a
	.endm
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
	jr	nz, 1$
	ret
	.endm

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

static void cell_or0(const u8 *g, u8 *buf) __naked {
    (void)g; (void)buf;
    __asm
	CELL_OR	0
    __endasm;
}

static void cell_or1(const u8 *g, u8 *buf) __naked {
    (void)g; (void)buf;
    __asm
	CELL_OR	1
    __endasm;
}

static void cell_or2(const u8 *g, u8 *buf) __naked {
    (void)g; (void)buf;
    __asm
	CELL_OR	2
    __endasm;
}

static void cell_or3(const u8 *g, u8 *buf) __naked {
    (void)g; (void)buf;
    __asm
	CELL_OR	3
    __endasm;
}

static void cell_or4(const u8 *g, u8 *buf) __naked {
    (void)g; (void)buf;
    __asm
	CELL_OR	4
    __endasm;
}

static void cell_or5(const u8 *g, u8 *buf) __naked {
    (void)g; (void)buf;
    __asm
	CELL_OR	5
    __endasm;
}

static void cell_or6(const u8 *g, u8 *buf) __naked {
    (void)g; (void)buf;
    __asm
	CELL_OR	6
    __endasm;
}

static void cell_or7(const u8 *g, u8 *buf) __naked {
    (void)g; (void)buf;
    __asm
	CELL_OR	7
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

/* One row of the generic flush: both plane bytes at addr become
 * (old & keep) | v, inside a DiNest .. EiNest window around the STAT wait
 * and the four accesses (13 M-cycles after the check passes, under the
 * ~20 that are then guaranteed, docs/vram-write-race.md). v0 and v1 must
 * already be masked with ~keep.
 * Frame (sdcccall 0): +2 addr  +4 keep  +5 v0  +6 v1. */
static void vram_rmw2(u16 addr, u8 keep, u8 v0, u8 v1) __naked {
    (void)addr; (void)keep; (void)v0; (void)v1;
    __asm
	ldhl	sp, #2
	ld	a, (hl+)
	ld	e, a
	ld	a, (hl+)
	ld	d, a
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	l, (hl)
	call	_DiNest
vram_rmw2_wait:
	ldh	a, (#0xff41)
	bit	1, a
	jr	nz, vram_rmw2_wait
	ld	a, (de)
	and	c
	or	b
	ld	(de), a
	inc	e
	ld	a, (de)
	and	c
	or	l
	ld	(de), a
	jp	_EiNest
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
 * never cross a tile (a row starts on tile row 0 or 4 and n is 12 or 8), so
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
