/* ============================================================================
   font12.c  -  mod: the 12px proportional font (bank 8)
   ----------------------------------------------------------------------------
   The 0918 mod's renderer and layout (kernel/mod/src/draw12.c and
   layout12.c, docs/font12.md), for this kernel: no DV, and
   the ink and paper are arguments, since GBDK's draw state is not readable
   from C. The glyph tables are packed from kernel/mod/font12/font12.txt by
   kernel/tools/font12-pack.py (the makefile does it) and sit in this bank,
   font12_data.s. A second set is EZ Flash's 6x12 font, the one the Chinese
   build draws ASCII in (tools/ezf-pack.py): the SET tab's EZF.

   The screen is GBDK's graphics canvas, a framebuffer: pixel row y of tile
   column t is at $8100 + (y / 8) * $140 + (y % 8) * 2 + t * 16, plane 0
   then plane 1. A row of text is composed in a buffer on the stack, one
   12-byte column per tile, and flushed: ink 3 on paper 0 and the inverse
   with plain writes, four tile rows to an HBlank; any other pair with a
   masked read-modify-write a row. Every VRAM access is made with
   interrupts off from the STAT sample on (docs/drawing-timing.md).

   A string passed in must be readable with bank 8 mapped: WRAM, the stack
   or save RAM, never a literal of another bank.
   ========================================================================== */

#include <gb/gb.h>
#include <string.h>

#include "font12.h"

#pragma bank 8

typedef UINT8 u8;
typedef UINT16 u16;

extern const u8 Font12[];		/* 101 glyphs x 24 bytes */
extern const u8 Font12Metrics[];
extern const u8 Font12Ezf[];		/* EZ Flash's 6x12 font in the same shape (tools/ezf-pack.py) */
extern const u8 Font12EzfMetrics[];
extern UINT8 ui_font;			/* 2: the EZF set */

/* the glyph set in use and its metrics */
#define FONT	((ui_font == 2U) ? Font12Ezf : Font12)
#define METRICS	((ui_font == 2U) ? Font12EzfMetrics : Font12Metrics)

#define M_ADV   0			/* u8[101] advance */
#define M_W     101			/* u8[101] ink width */
#define M_LCOL  202			/* u8[101] left kerning class = matrix column */
#define M_RROW  303			/* u16[101] byte offset of the right class row */
#define ICON0   96			/* glyph index of the first icon ($C0) */

#define ROW_W 160
#define ROW_H 12
#define SCREEN_H 144
#define GLYPH 24
#define MAX_TILES 20
#define MAX_GLYPHS FONT12_MAX

static void blit_col1(const u8 *src, u16 addr, u8 n, u8 xm) __naked __sdcccall(0);
static void fill0(u8 *p, u8 n4) __naked __sdcccall(0);
static void vram_rmw2(u16 addr, u8 keep, u8 v0, u8 v1) __naked __sdcccall(0);
static void cell_or0(const u8 *g, u8 *buf) __naked __sdcccall(0);
static void cell_or1(const u8 *g, u8 *buf) __naked __sdcccall(0);
static void cell_or2(const u8 *g, u8 *buf) __naked __sdcccall(0);
static void cell_or3(const u8 *g, u8 *buf) __naked __sdcccall(0);
static void cell_or4(const u8 *g, u8 *buf) __naked __sdcccall(0);
static void cell_or5(const u8 *g, u8 *buf) __naked __sdcccall(0);
static void cell_or6(const u8 *g, u8 *buf) __naked __sdcccall(0);
static void cell_or7(const u8 *g, u8 *buf) __naked __sdcccall(0);
static void flush_rmw(const u8 *buf, u16 addr, u8 n, u8 nt, u8 kf, u8 kl, u8 ink, u8 paper);

static u8 glyph_index(u8 c)
{
	if (c >= 0x20 && c < 0x80) return (u8)(c - 0x20);
	if (c >= 0xC0 && c <= 0xC4) return (u8)(ICON0 + (c - 0xC0));
	return (u8)('?' - 0x20);
}

/* Pixels glyph b moves left when it follows glyph a: the 2-bit entry at
   (a's right class row, b's left class column). Class 0 never kerns. */
static u8 kern(u8 a, u8 b)
{
	const u8 *M = METRICS;
	u8 l = M[M_LCOL + b];
	u16 r;

	if (l == 0) return 0;
	r = *(const u16 *)(M + M_RROW + (u8)(a << 1));
	return (u8)((M[r + (l >> 2)] >> ((l & 3) << 1)) & 3);
}

/* Runs the pen over s from pixel x: each glyph's x goes to xs[], and the
   count of glyphs that fit before the right edge comes back. len caps the
   characters, 0 meaning up to the NUL. */
static u8 fit_to(const u8 *s, u8 len, u8 x, u8 *xs, u8 lim);

static u8 fit(const u8 *s, u8 len, u8 x, u8 *xs)
{
	return fit_to(s, len, x, xs, ROW_W);
}

/* The same, with the right edge at pixel lim */
static u8 fit_to(const u8 *s, u8 len, u8 x, u8 *xs, u8 lim)
{
	const u8 *M = METRICS;
	u8 i, g, prev, c;

	if (len == 0 || len > MAX_GLYPHS) len = MAX_GLYPHS;
	prev = 0xFF;
	for (i = 0; i < len; i++) {
		c = s[i];
		if (c == 0) break;
		g = glyph_index(c);
		if (prev != 0xFF) x -= kern(prev, g);
		if (x >= lim || (u8)(x + M[M_W + g]) > lim) break;
		xs[i] = x;
		x += M[M_ADV + g];
		prev = g;
	}
	return i;
}

/* How many characters of s fit on a row that starts at pixel x */
UINT8 font12_fit(const UINT8 *s, UINT8 x) __banked
{
	u8 xs[MAX_GLYPHS];

	return fit(s, 0, x, xs);
}

/* Draws s at pixel (x, y) and paints the row from x to the right edge, so a
   shorter string leaves nothing of a longer one. y is rounded down to a
   multiple of 4. colors is ink * 4 + paper. */
void font12_draw(const UINT8 *s, UINT8 x0, UINT8 y, UINT8 colors) __banked
{
	font12_field(s, x0, y, colors, ROW_W);
}

/* Where the pen is after s drawn from pixel x: the x for what follows it */
UINT8 font12_end(const UINT8 *s, UINT8 x) __banked
{
	u8 xs[MAX_GLYPHS];
	u8 n = fit(s, 0, x, xs);

	if (n == 0) return x;
	return (u8)(xs[n - 1] + METRICS[M_ADV + glyph_index(s[n - 1])]);
}

/* The same for a field that ends at pixel xe: nothing is drawn or painted
   from xe on, so what is to the right of the field stays. */
void font12_field(const UINT8 *s, UINT8 x0, UINT8 y, UINT8 colors, UINT8 xe) __banked
{
	u8 i, x, n, ink, paper, xm, t0, nt, kf, kl, cnt, c;
	/* one spare column: a glyph ending in tile 19 still ORs its (zero) low
	   byte into "tile 20" */
	u8 buf[(MAX_TILES + 1) * ROW_H];
	u8 xs[MAX_GLYPHS];
	u16 addr;
	const u8 *g;
	u8 *p;

	y &= 0xFC;
	if (xe > ROW_W) xe = ROW_W;
	if (y >= SCREEN_H || x0 >= xe) return;
	n = ROW_H;
	if ((u8)(SCREEN_H - y) < ROW_H) n = (u8)((SCREEN_H - y) & 0xFC);
	if (n == 0) return;
	ink = (u8)(colors >> 2);
	paper = (u8)(colors & 3);
	t0 = (u8)(x0 >> 3);
	nt = (u8)((u8)((u8)(xe + 7) >> 3) - t0);
	/* the last tile keeps the pixels from xe on */
	kl = (xe & 7) ? (u8)(0xFF >> (xe & 7)) : 0;
	/* the first tile keeps the pixels left of x0 */
	kf = (x0 & 7) ? (u8)(0xFF << (8 - (x0 & 7))) : 0;
	addr = (u16)(0x8100U + (u16)(y >> 3) * 0x140U + (u16)((y & 7) << 1) + ((u16)t0 << 4));
	xm = paper ? 0xFF : 0;
	fill0(buf, (u8)((nt + 1) * 3));
	cnt = fit_to(s, 0, x0, xs, xe);
	for (i = 0; i < cnt; i++) {
		x = xs[i];
		c = glyph_index(s[i]);
		g = FONT + (u16)c * GLYPH;
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
	if (colors != 0x0C && colors != 0x03) {
		flush_rmw(buf, addr, n, nt, kf, kl, ink, paper);
		return;
	}
	/* a tile the field only partly covers goes through the masked write */
	p = buf;
	for (i = 0; i < nt; i++, p += ROW_H, addr += 16) {
		x = (u8)((i ? 0 : kf) | (i == (u8)(nt - 1) ? kl : 0));
		if (x) flush_rmw(p, addr, n, 1, x, 0, ink, paper);
		else blit_col1(p, addr, n, xm);
	}
}

/* Generic flush: any ink/paper pair. Each plane byte is (bits & a) ^ x,
   where a selects the plane bits that differ between ink and paper and x
   is paper's bit; the first tile column keeps its pixels outside the field
   (kf). Row addresses step by 2 within a tile and by $130 + 2 across a
   tile boundary, where the low nibble wraps to 0. */
static void flush_rmw(const u8 *buf, u16 addr, u8 n, u8 nt, u8 kf, u8 kl, u8 ink, u8 paper)
{
	u8 a0, x0, a1, x1, i, r, keep, v;
	u16 a;

	a0 = ((ink ^ paper) & 1) ? 0xFF : 0;
	x0 = (paper & 1) ? 0xFF : 0;
	a1 = ((ink ^ paper) & 2) ? 0xFF : 0;
	x1 = (paper & 2) ? 0xFF : 0;
	for (i = 0; i < nt; i++, buf += ROW_H, addr += 16) {
		keep = i ? 0 : kf;
		if (i == (u8)(nt - 1)) keep |= kl;
		a = addr;
		for (r = 0; r < n; r++) {
			v = buf[r];
			vram_rmw2(a, keep, (u8)(((v & a0) ^ x0) & ~keep), (u8)(((v & a1) ^ x1) & ~keep));
			a += 2;
			if ((a & 0x0F) == 0) a += 0x130;
		}
	}
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
static void fill0(u8 *p, u8 n4) __naked __sdcccall(0) {
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

static void cell_or0(const u8 *g, u8 *buf) __naked __sdcccall(0) {
    (void)g; (void)buf;
    __asm
	CELL_OR	0
    __endasm;
}

static void cell_or1(const u8 *g, u8 *buf) __naked __sdcccall(0) {
    (void)g; (void)buf;
    __asm
	CELL_OR	1
    __endasm;
}

static void cell_or2(const u8 *g, u8 *buf) __naked __sdcccall(0) {
    (void)g; (void)buf;
    __asm
	CELL_OR	2
    __endasm;
}

static void cell_or3(const u8 *g, u8 *buf) __naked __sdcccall(0) {
    (void)g; (void)buf;
    __asm
	CELL_OR	3
    __endasm;
}

static void cell_or4(const u8 *g, u8 *buf) __naked __sdcccall(0) {
    (void)g; (void)buf;
    __asm
	CELL_OR	4
    __endasm;
}

static void cell_or5(const u8 *g, u8 *buf) __naked __sdcccall(0) {
    (void)g; (void)buf;
    __asm
	CELL_OR	5
    __endasm;
}

static void cell_or6(const u8 *g, u8 *buf) __naked __sdcccall(0) {
    (void)g; (void)buf;
    __asm
	CELL_OR	6
    __endasm;
}

static void cell_or7(const u8 *g, u8 *buf) __naked __sdcccall(0) {
    (void)g; (void)buf;
    __asm
	CELL_OR	7
    __endasm;
}

/* One row of the generic flush: both plane bytes at addr become
 * (old & keep) | v, with interrupts off around the STAT wait
 * and the four accesses (13 M-cycles after the check passes, under the
 * ~20 that are then guaranteed, docs/drawing-timing.md). v0 and v1 must
 * already be masked with ~keep.
 * Frame (sdcccall 0): +2 addr  +4 keep  +5 v0  +6 v1. */
static void vram_rmw2(u16 addr, u8 keep, u8 v0, u8 v1) __naked __sdcccall(0) {
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
	di
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
	ei
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
 * never cross a tile (a row starts on tile row 0 or 4 and n is 12 or 8), so
 * the tile-boundary step is taken between batches only.
 * Frame (sdcccall 0): +2 src  +4 addr  +6 n  +7 xm. */
static void blit_col1(const u8 *src, u16 addr, u8 n, u8 xm) __naked __sdcccall(0) {
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
