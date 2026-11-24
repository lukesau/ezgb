/* ============================================================================
   ui_zh.c  -  12px bitmap text engine for the Chinese build (LANG=zh)
   ----------------------------------------------------------------------------
   Rendering: GBDK's APA per-pixel drawing (plot_point from drawing.h), the same
   route as DrawHZText12 in the old 1.05c firmware.

   Why APA instead of a hand-built tile pool:
       A BG map entry is an 8-bit tile index, so at most 256 distinct tiles can be
       referenced at once and the console font owns 0-95, leaving 160 - only 5 rows
       at full 20-column width. GBDK's library maps the 144 pixel rows onto two tile
       sets via y_table and swaps them at scanline 72 with the LCD interrupt, trading
       time for space: a full 160px width still fits 9 rows (drawing is slower).

   Geometry: list area y = ZH_TOP + row*ZH_PITCH, full width 0..159.
   Selected row: a 1px frame (zh_frame) around the row; text stays black on white.

   Note: this file lives in bank 2; plot_point / box / color are banked library
   functions, the cross-bank calls are handled by SDCC.
   ========================================================================== */

#include <gb/gb.h>
#include <gb/drawing.h>

#include "ui_zh.h"
#include "ui_text.h"

#pragma bank 2

/* 6x12 ASCII glyphs (asc12x6.c): 12 bytes each, bit 7 leftmost, 6px wide */
extern const UINT8 ASC_DATA[1536];

/* Glyph staging area: zh_fetch switches banks in bank 0 and copies 24 bytes here.
   Always copy to RAM before drawing: after the bank switch the 0x4000 window
   holds font data, not code. (Not static: ui_zh_fast.s reads _zh_gbuf directly.) */
UINT8 zh_gbuf[24];

/* Last color() background plus the rectangle/colour of the last non-white fill.
   Why track it: in graphics mode color() does not touch BGP and BGP always reads
   white, which put a white bar inside the Reading dialog. zh_bg.h's macros write
   these at the call site; zh_box_track() wraps box() (see zh_bg.h). */
UINT8 zh_last_bg;
UINT8 zh_last_fg;

/* The last ZH_BOX_SLOTS non-white fills, newest last. A single slot is not
   enough: the save dialog fills the whole grey dialog and then two grey
   buttons inside it, so the one slot held only the OK button and the text of
   "No" (which starts outside that rect) got a white background. */
#define ZH_BOX_SLOTS	4
UINT8 zh_box_bg[ZH_BOX_SLOTS];
UINT8 zh_box_x1[ZH_BOX_SLOTS], zh_box_y1[ZH_BOX_SLOTS];
UINT8 zh_box_x2[ZH_BOX_SLOTS], zh_box_y2[ZH_BOX_SLOTS];
UINT8 zh_box_head;			/* next slot to write */

/* Forget every remembered fill; also used when a white fill covers the area. */
void zh_box_forget(void) __banked
{
	UINT8 i;

	for (i = 0U; i < ZH_BOX_SLOTS; i++) zh_box_bg[i] = 0U;
	zh_box_head = 0U;
}

void zh_box_track(UINT8 x1, UINT8 y1, UINT8 x2, UINT8 y2, UINT8 mode) __banked
{
	UINT8 bg = (UINT8)(zh_last_bg & 0x03U);

	/* Always the library box().
	   A fast path that wrote VRAM directly and patched the left/right edges with
	   plot_point was tried: it left a 4-5 pixel white band on the left edge of the
	   dialog (the edge branch never took effect on hardware although the generated
	   code was right). Reproduced twice on hardware, removed for good. Full-width
	   fills without edge pixels use zh_fill_rows byte writes, unrelated to this. */
	box(x1, y1, x2, y2, mode);

	if (mode == M_FILL)
	{
		if (bg != 0U)					/* non-white fill: remember this grey/black area */
		{
			zh_box_bg[zh_box_head] = bg;
			zh_box_x1[zh_box_head] = x1;
			zh_box_y1[zh_box_head] = y1;
			zh_box_x2[zh_box_head] = x2;
			zh_box_y2[zh_box_head] = y2;
			zh_box_head = (UINT8)((zh_box_head + 1U) & (ZH_BOX_SLOTS - 1U));
		}
		else							/* white fill: this area is white */
		{
			zh_box_forget();
		}
	}
}

/* ----------------------------------------------------------------------------
   GB2312 code -> font bank / offset. The font is split into 6 ranges in banks
   10..21, each starting at its first code. Returns the byte offset (24 per glyph),
   -------------------------------------------------------------------------- */
static UINT16 zh_glyph(UINT8 c1, UINT8 c2, UINT8 *page)
{
	UINT16 code = ((UINT16)c1 << 8) | c2;
	UINT16 loc;

	if      (code >= 0xF1BCU) { *page = 21; loc = (UINT16)(c1 - 0xF1U) * 94U + (UINT16)(c2 - 0xBCU); }
	else if (code >= 0xEAA4U) { *page = 20; loc = (UINT16)(c1 - 0xEAU) * 94U + (UINT16)(c2 - 0xA4U); }
	else if (code >= 0xE2EAU) { *page = 19; loc = (UINT16)(c1 - 0xE2U) * 94U + (UINT16)(c2 - 0xEAU); }
	else if (code >= 0xDBD2U) { *page = 18; loc = (UINT16)(c1 - 0xDBU) * 94U + (UINT16)(c2 - 0xD2U); }
	else if (code >= 0xD4BAU) { *page = 17; loc = (UINT16)(c1 - 0xD4U) * 94U + (UINT16)(c2 - 0xBAU); }
	else if (code >= 0xCDA2U) { *page = 16; loc = (UINT16)(c1 - 0xCDU) * 94U + (UINT16)(c2 - 0xA2U); }
	else if (code >= 0xC5E8U) { *page = 15; loc = (UINT16)(c1 - 0xC5U) * 94U + (UINT16)(c2 - 0xE8U); }
	else if (code >= 0xBED0U) { *page = 14; loc = (UINT16)(c1 - 0xBEU) * 94U + (UINT16)(c2 - 0xD0U); }
	else if (code >= 0xB7B8U) { *page = 13; loc = (UINT16)(c1 - 0xB7U) * 94U + (UINT16)(c2 - 0xB8U); }
	else if (code >= 0xB0A0U) { *page = 12; loc = (UINT16)(c1 - 0xB0U) * 94U + (UINT16)(c2 - 0xA0U); }
	else if (code >= 0xA8B9U) { *page = 11; loc = (UINT16)(c1 - 0xA8U) * 94U + (UINT16)(c2 - 0xB9U); }
	else if (code >= 0xA1A0U) { *page = 10; loc = (UINT16)(c1 - 0xA1U) * 94U + (UINT16)(c2 - 0xA1U); }
	else                      { *page = 0;  return 0xFFFFU; }

	return loc * 24U;			/* 12 rows x 2 bytes per glyph */
}

/* ----------------------------------------------------------------------------
   Draw 8 pixels (bit 7 leftmost) at (x, y). The ink comes from color().
   -------------------------------------------------------------------------- */
static void zh_px8(UINT8 bits, UINT8 x, UINT8 y)
{
	if (bits & 0x80U) plot_point(x, y);
	if (bits & 0x40U) plot_point((UINT8)(x + 1U), y);
	if (bits & 0x20U) plot_point((UINT8)(x + 2U), y);
	if (bits & 0x10U) plot_point((UINT8)(x + 3U), y);
	if (bits & 0x08U) plot_point((UINT8)(x + 4U), y);
	if (bits & 0x04U) plot_point((UINT8)(x + 5U), y);
	if (bits & 0x02U) plot_point((UINT8)(x + 6U), y);
	if (bits & 0x01U) plot_point((UINT8)(x + 7U), y);
}

/* Draw a 12-row glyph. planes=1 = ASCII (12 bytes), 2 = CJK (24 bytes). */
static void zh_px_glyph(UINT8 x, UINT8 y, const UINT8 *g, UINT8 planes)
{
	UINT8 i;

	for (i = 0U; i < 12U; i++)
	{
		zh_px8(g[i * planes], x, (UINT8)(y + i));
		if (planes == 2U)
			zh_px8(g[i * planes + 1U], (UINT8)(x + 8U), (UINT8)(y + i));
	}
}

/* ----------------------------------------------------------------------------
   Fast path (ui_zh_fast.s, same bank, plain CALL): black glyphs are written
   straight into both VRAM bit planes, bypassing per-pixel plot_point: a CJK glyph
   drops from ~144 library calls to ~36 byte accesses, an order of magnitude
   faster. Semantically identical to plot_point with black ink (both set the two
   planes), valid on any background; white glyphs still use the slow path.
   -------------------------------------------------------------------------- */
UINT8  zh_fa_x, zh_fa_y;		/* glyph top-left pixel coordinates */
UINT8  zh_fa_sh, zh_fa_row, zh_fa_hz, zh_fa_lc;
UINT16 zh_fa_off;				/* ASCII: offset into ASC_DATA */

extern void zh_fast_ascii(void);	/* not __banked: same bank 2 as ui_zh.c */
extern void zh_fast_hz(void);		/* the glyph must already be in zh_gbuf */

static UINT8 zh_ink = 3U;		/* 3 = black (fast path), 0 = white (plot_point) */

static void zh_draw_ascii(UINT8 x, UINT8 y, UINT8 c)
{
	if (zh_ink == 3U)
	{
		zh_fa_x = x;
		zh_fa_y = y;
		zh_fa_off = (UINT16)((UINT16)c * 12U);
		zh_fast_ascii();
	}
	else
	{
		zh_px_glyph(x, y, &ASC_DATA[(UINT16)c * 12U], 1U);
	}
}

static void zh_draw_hz(UINT8 x, UINT8 y)
{
	if (zh_ink == 3U)
	{
		zh_fa_x = x;
		zh_fa_y = y;
		zh_fast_hz();
	}
	else
	{
		zh_px_glyph(x, y, zh_gbuf, 2U);
	}
}

/* ----------------------------------------------------------------------------
   Full-row fast fill (zh_fast_fill in ui_zh_fast.s): width 0..159, writes both
   plane bytes per tile, bypassing the per-pixel box(M_FILL).
   Scale: a 160x144 clear took 23,000 plot calls (~0.8s); here it is 5,760 byte
   writes (~20-30ms). White = 0,0  black = 0xFF,0xFF  dark grey = 0x00,0xFF.
   -------------------------------------------------------------------------- */
UINT8 zh_ff_y0, zh_ff_y1, zh_ff_p0, zh_ff_p1;

extern void zh_fast_fill(void);		/* not __banked: same bank 2 as ui_zh.c */

static void zh_fill_rows(UINT8 y0, UINT8 y1, UINT8 p0, UINT8 p1)
{
	if (y0 > y1) return;

	/* Fallback .gmode trigger: on the first draw the library builds the tilemap
	   with the LCD off. The pixel written here is covered by the fill. */
	plot_point(0, y0);

	zh_ff_y0 = y0;
	zh_ff_y1 = y1;
	zh_ff_p0 = p0;
	zh_ff_p1 = p1;
	zh_fast_fill();
}

/* Fill full-width rows with white (screen/list clears in UI.c and main.c).
   Also clears the grey-background record: this area is white now, so later
   Draw_Text calls must not inherit a dialog colour. */
void zh_fill_white_rows(UINT8 y0, UINT8 y1) __banked
{
	zh_fill_rows(y0, y1, 0x00U, 0x00U);
	zh_box_forget();
}

/* ----------------------------------------------------------------------------
   Fill the whole list area with white. The APA tilemap is built by the drawing
   library on first use; do not write the map here - it uses two tile sets.
   -------------------------------------------------------------------------- */
void zh_screen_init(void) __banked
{
	zh_fill_rows(ZH_TOP, (UINT8)(ZH_TOP + ZH_ROWS * ZH_PITCH - 1U), 0x00U, 0x00U);
	color(BLACK, WHITE, SOLID);		/* default: black on white */
}

/* Fill the band [y, y+h) with white (full width). The fast fill writes VRAM
   directly, so the palette is not flipped and nothing flashes. */
void zh_clear_band(UINT8 y, UINT8 h) __banked
{
	if (h == 0U) return;
	zh_fill_rows(y, (UINT8)(y + h - 1U), 0x00U, 0x00U);
	color(BLACK, WHITE, SOLID);
}

/* The double black line under the tab bar (line(0,8,159,8)+line(0,9,159,9)).
   Two full rows = 2 x 40 byte writes instead of 320 plot_point calls. */
void zh_rule(UINT8 y) __banked
{
	UINT8 i;

	for (i = 0U; i < 2U; i++)
		zh_fill_rows((UINT8)(y + i), (UINT8)(y + i), 0xFFU, 0xFFU);
}

/* 1px rectangle: the old code used box(...,M_NOFILL); here plot_point is used
   because box() switches drawing modes and can eat neighbouring pixels.
   For full-width frames (list selection 0..159) the horizontal lines use the fast
   fill; only the two vertical lines use plot_point: ~700 plots become ~30. */
void zh_frame(UINT8 x0, UINT8 y0, UINT8 x1, UINT8 y1) __banked
{
	UINT8 i;

	if (x0 == 0U && x1 == 159U)
	{
		zh_fill_rows(y0, y0, 0xFFU, 0xFFU);
		zh_fill_rows(y1, y1, 0xFFU, 0xFFU);
	}
	else
	{
		for (i = x0; i <= x1; i++) { plot_point(i, y0); plot_point(i, y1); }
	}

	for (i = y0; i <= y1; i++) { plot_point(x0, i); plot_point(x1, i); }
}

/* Solid black block. box()'s fill writes the BACKGROUND index, so bg must be
   BLACK to write 3; the palette is restored to black-on-white afterwards. */
void zh_fill_black(UINT8 x0, UINT8 y0, UINT8 x1, UINT8 y1) __banked
{
	color(BLACK, BLACK, SOLID);
	box(x0, y0, x1, y1, M_FILL);
	color(BLACK, WHITE, SOLID);
}

/* White with a black border: box() draws the border in the FOREGROUND and the
   fill in the BACKGROUND, so (BLACK,WHITE) means "white with black border" -
   what UI.c uses for tab cells. (zh_clear_band uses (WHITE,WHITE): no border.) */
void zh_fill_white(UINT8 x0, UINT8 y0, UINT8 x1, UINT8 y1) __banked
{
	color(BLACK, WHITE, SOLID);
	box(x0, y0, x1, y1, M_FILL);
}

/* Flat fill without a border (used to wipe a small area, no black edge) */
void zh_fill_flat(UINT8 x0, UINT8 y0, UINT8 x1, UINT8 y1) __banked
{
	color(WHITE, WHITE, SOLID);
	box(x0, y0, x1, y1, M_FILL);
	color(BLACK, WHITE, SOLID);
}

/* Dark grey fill: the fill writes the background index, bg=DKGREY writes 2,
   matching the tab background of color(BLACK,DKGREY)+box(M_FILL) in UI.c. */
void zh_fill_grey(UINT8 x0, UINT8 y0, UINT8 x1, UINT8 y1) __banked
{
	color(BLACK, DKGREY, SOLID);
	box(x0, y0, x1, y1, M_FILL);
	color(BLACK, WHITE, SOLID);
}

/* Erase a frame to white: plot_point writes 0 only under (WHITE,WHITE).
   Full-width frames use the fast fill for the horizontal lines. */
void zh_frame_erase(UINT8 x0, UINT8 y0, UINT8 x1, UINT8 y1) __banked
{
	UINT8 i;

	if (x0 == 0U && x1 == 159U)
	{
		zh_fill_rows(y0, y0, 0x00U, 0x00U);
		zh_fill_rows(y1, y1, 0x00U, 0x00U);
	}

	color(WHITE, WHITE, SOLID);
	if (x0 != 0U || x1 != 159U)
	{
		for (i = x0; i <= x1; i++) { plot_point(i, y0); plot_point(i, y1); }
	}
	for (i = y0; i <= y1; i++) { plot_point(x0, i); plot_point(x1, i); }
	color(BLACK, WHITE, SOLID);
}

/* White on black: under (WHITE,WHITE) plot_point writes 0, i.e. real white.
   Used only for the inverted tab cell, drawn once per screen entry.
   White glyphs cannot use the fast path (it only sets black), so zh_ink disables it. */
UINT8 zh_ascii_inv(UINT8 y, UINT8 x, const UINT8 *s, UINT8 x_limit) __banked
{
	UINT8 r;

	zh_ink = 0U;						/* white ink: use plot_point */
	color(WHITE, WHITE, SOLID);
	r = zh_ascii_at(y, x, s, x_limit);
	color(BLACK, WHITE, SOLID);
	zh_ink = 3U;
	return r;
}

/* Inverse-video field: black rectangle, then white glyphs on top.
   The zh build cannot use the console BGP trick the English build relies on
   (graphics-mode color() never touches BGP), so "this field is editable" is
   shown by inverting it. Width is 6px per glyph, matching the 12px font. */
void zh_field_inv(UINT8 x, UINT8 y, const UINT8 *s, UINT8 chars) __banked
{
	zh_fill_black(x, y, (UINT8)(x + chars * 6U - 1U), (UINT8)(y + 11U));
	zh_ascii_inv(y, x, s, 160U);
}

/* The three tab cells. Numbers and coordinates copied from 1.05c's UI.c:
     box(0,0,25,14) / (25,0,50,14) / (50,0,75,14)
     DrawHZText12("SD", 7) / ("SET", 30) / ("HELP", 52)，y=2
     line(0,14,159,14)
   the active page is white, the others dark grey (an earlier version had it backwards). */
void zh_tabbar(UINT8 active) __banked
{
	UINT8 x;

	zh_fill_flat(75, 0, 159, 13);					/* index area on the right (no black border) */

	if (active == 1U)
	{
		zh_fill_grey(0, 0, 25, 13);
		zh_fill_white(25, 0, 50, 13);
		zh_fill_grey(50, 0, 75, 13);
	}
	else if (active == 2U)
	{
		zh_fill_grey(0, 0, 25, 13);
		zh_fill_grey(25, 0, 50, 13);
		zh_fill_white(50, 0, 75, 13);
	}
	else
	{
		zh_fill_white(0, 0, 25, 13);
		zh_fill_grey(25, 0, 50, 13);
		zh_fill_grey(50, 0, 75, 13);
	}

	/* The labels in ui_text.h carry padding spaces (for the 8px console build);
	   the compact strings without padding are used here instead. */
	zh_ascii_at(2, 7,  (const UINT8 *)"SD",   25);
	zh_ascii_at(2, 30, (const UINT8 *)"SET",  52);
	zh_ascii_at(2, 52, (const UINT8 *)"HELP", 79);

	/* The cell bottom is y13; adding y14 reproduces the old thick black line */
	for (x = 0U; x < 160U; x++) plot_point(x, 14);
}


/* The old "RAM shadow" renderer (zh_row_clear / zh_row_select / zh_row_flush /
   zh_row_invert / zh_mark_at / zh_row_ascii) is gone: everything is drawn
   straight to VRAM now, so a per-row flush has nothing left to flush.
   Kept as a no-op because the list code still calls it once per repaint. */
void zh_flush_all(void) __banked
{
}


/* ----------------------------------------------------------------------------
   Draw one line of text (ASCII + CJK), x in pixels, truncated at x_limit.
   -------------------------------------------------------------------------- */
/* ----------------------------------------------------------------------------
   GB2312 rows 1-15 (punctuation / symbols).

   The 12px blob does carry those rows, but from row 1 position 8 on the data is
   shifted inside the cell and draws garbage: "—" (0xA1A9) comes out as a stray
   diagonal, "～" as a flat bar, "‖" as a hook. Seen on hardware on a ROM whose
   name contains a dash - it looked like a random letter in the SD list.

   So rows 1-15 are never taken from the font:
     - row 3 (0xA3A1..0xA3FE) is fullwidth ASCII - converted arithmetically, so
       "（）－，．０-９Ａ-Ｚ" all show as their halfwidth twins;
     - a handful of row-1 marks get an ASCII stand-in (table below);
     - everything else in rows 1-15 is skipped instead of drawing noise.
   Side benefit: a mapped mark advances 6px instead of 16px, so long names show
   more characters before the size column.
   -------------------------------------------------------------------------- */
/* Index = 位-1 (0xA1A1 -> 0). 0 = no stand-in, skip the character. */
static const UINT8 ZH_PUNCT1[94] = {
/* 位  1..10 */  ' ', ',', '.', '.', 0,   0,   0,   0,   '-', '-',
/* 位 11..20 */  '~', '.', '\'', '\'', '"', '"', '[', ']', '<', '>',
/* 位 21..30 */  '<', '>', '<', '>', '<', '>', '[', ']', '[', ']',
/* 位 31..40 */  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
/* 位 41..50 */  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
/* 位 51..60 */  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
/* 位 61..70 */  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
/* 位 71..80 */  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
/* 位 81..90 */  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
/* 位 91..94 */  0,   0,   0,   0
};

/* ASCII stand-in for a GBK double-byte punctuation mark; 0 = draw nothing.
   Also used by list_zh.c to measure names (a mapped mark is 6px wide). */
UINT8 zh_punct(UINT8 c1, UINT8 c2) __banked
{
	if ((c1 == 0xA3U) && (c2 >= 0xA1U))			/* fullwidth ASCII row */
		return (UINT8)(c2 - 0x80U);				/* 0xA3A1 -> '!', 0xA3FE -> '~' */

	if (c1 == 0xA1U)
		return ZH_PUNCT1[c2 - 0xA1U];

	/* GBK/5 extension block: CP936 puts EN DASH (U+2013) at 0xA843 and HORIZONTAL
	   BAR (U+2015) at 0xA844 - that is what a Chinese Windows writes when a file
	   name contains "–". There is no glyph for them anywhere in our font, so they
	   used to come out as an unrelated hanzi. */
	if ((c1 == 0xA8U) && ((c2 == 0x43U) || (c2 == 0x44U)))
		return '-';

	return 0U;
}

UINT8 zh_text_at(UINT8 y, UINT8 x, const UINT8 *s, UINT8 x_limit) __banked
{
	UINT8 c1, c2, pa, page;
	UINT16 off;

	while (*s)
	{
		c1 = *s++;

		if (c1 < 0x80U)						/* ASCII */
		{
			if ((UINT8)(x + ZH_ASC_W) > x_limit) break;
			zh_draw_ascii(x, y, c1);
			x = (UINT8)(x + ZH_ASC_W);
			continue;
		}

		if (*s == 0U) break;				/* half a CJK code: drop it */
		c2 = *s++;

		pa = zh_punct(c1, c2);			/* punctuation -> 6px ASCII stand-in */
		if (pa != 0U)
		{
			if ((UINT8)(x + ZH_ASC_W) > x_limit) break;
			zh_draw_ascii(x, y, pa);
			x = (UINT8)(x + ZH_ASC_W);
			continue;
		}

		if (c1 < 0xB0U) continue;		/* rows 1-15: the font data there is unusable */

		if ((UINT8)(x + ZH_HZ_W) > x_limit) break;

		off = zh_glyph(c1, c2, &page);
		if (off == 0xFFFFU) continue;		/* not GB2312: skip */

		zh_fetch(page, off, zh_gbuf);		/* switch banks in bank 0 and copy 24 bytes */
		zh_draw_hz(x, y);

		x = (UINT8)(x + ZH_HZ_W);
	}
	return x;
}

UINT8 zh_row_text(UINT8 row, UINT8 x, const UINT8 *s, UINT8 x_limit) __banked
{
	return zh_text_at((UINT8)(ZH_TOP + row * ZH_PITCH), x, s, x_limit);
}
UINT8 zh_row_ascii(UINT8 row, UINT8 x, const UINT8 *s, UINT8 x_limit) __banked
{
	return zh_ascii_at((UINT8)(ZH_TOP + row * ZH_PITCH), x, s, x_limit);
}

/* ASCII only (used for the "DIR" tag). */
UINT8 zh_ascii_at(UINT8 y, UINT8 x, const UINT8 *s, UINT8 x_limit) __banked
{
	UINT8 c;

	while ((c = *s++) != 0U)
	{
		if ((UINT8)(x + ZH_ASC_W) > x_limit) break;
		zh_draw_ascii(x, y, c);
		x = (UINT8)(x + ZH_ASC_W);
	}
	return x;
}


/* ----------------------------------------------------------------------------
   Draw_Text's zh implementation (single entry point). Console semantics -> 12px APA:

       coords x/y are tiles (8px): px = x*8, py is normally y*8.
               rows 10/11 are special (70/83): the SAVE/LOAD dialogs use rows 10/11/12
               (Save fail / SD write error / press B; No sav fil / new file?), and 12px
               glyphs would overlap at an 8px pitch. 10->70, 11->83 and 12->96 are 13px
               apart, filling the dialog (35..125, 37..108) exactly: 96+12 = 108.
               (row 12, the button text, stays untouched.)
               row 17 (bottom bar): 136+12 would overflow, clamped to 132.
               row 3 is special (py=22): the SET button box is 14px tall (21..34), so 12px
               text at 22..33 is centred with 1px above and below. Only used on the SET page.
       len: console coverage = len 8px cells (erase, then draw).
              The background is narrowed to the actual glyphs (6px each, trailing spaces
              do not ink): 12px glyphs are 6px wide, so " SET " padded to len*8 would
              spill outside the button. len==0 = 17 cells (normalised in main.c);
              a whole row of spaces still fills the console width.
       bg: the caller does color(BLACK,DKGREY) before drawing a dialog (black on grey).
               BGP cannot tell us (color() does not touch it), so the zh build tracks the
               last non-white fill (rect + colour) via zh_bg.h: text landing inside that
               rect gets that colour, otherwise white. 0=white 1=ltgrey 2=dkgrey 3=black,
               ink == paper so the border is invisible. Black bg uses zh_ascii_inv.

   str is copied onto the stack by main.c: this function lives in bank 2 and cannot
   see the caller's literals (cross-bank rule). The first box() triggers .gmode,
   so even the very first line at boot never writes VRAM uninitialised.
   -------------------------------------------------------------------------- */
void zh_text_row(UINT8 y, UINT8 x, const UINT8 *str, UINT8 len) __banked
{
	UINT8 px, py, w;
	UINT8 bgc, n;

	px = (UINT8)(x * 8U);
	py = (UINT8)(y * 8U);
	if (y == 10U) py = 70U;			/* dialog rows are 13px apart, see above */
	else if (y == 11U) py = 83U;
	else if (y == 3U) py = 22U;		/* SET button box 21..34: 12px text at 22..33 */
	if (py > 132U) py = 132U;		/* row 17: 12px text sits on the bottom edge */

	w = (UINT8)(len * 8U);			/* console coverage width */
	if (w == 0U) w = 136U;			/* len==0: pad to 17 cells and overwrite the row */

	/* Narrow the background to the real glyphs: 12px glyphs are 6px wide and
	      trailing spaces do not ink. Filling " SET " at len*8 would spill past the
	      button (123..155); filling to 159 would grey the white gap up to the edge).
	      len==0 (erase the row) is not narrowed, or old names would remain. */
	if (len != 0U)
	{
		n = 0U;
		while (n < len && str[n] != 0U) n++;
		while (n > 0U && str[n - 1U] == ' ') n--;
		if (n > 0U) w = (UINT8)(n * 6U);
	}

	if ((UINT16)(px + w) > 160U) w = (UINT8)(160U - px);

	bgc = 0U;							/* default: white */
	{
		UINT8 i, sl;

		/* Walk the remembered fills from newest to oldest and take the first
		   one that contains the text origin (innermost wins, which is what
		   nested fills like "dialog, then a button inside it" need). */
		for (i = 0U; i < ZH_BOX_SLOTS; i++)
		{
			sl = (UINT8)((zh_box_head + ZH_BOX_SLOTS - 1U - i) & (ZH_BOX_SLOTS - 1U));
			if (zh_box_bg[sl] != 0U &&
			    px >= zh_box_x1[sl] && px <= zh_box_x2[sl] &&
			    py >= zh_box_y1[sl] && py <= zh_box_y2[sl])
			{
				bgc = zh_box_bg[sl];
				break;
			}
		}
	}

	/* Fill the row with the recorded colour: ink == paper hides the M_FILL border.
	      (M_FILL draws its border in the foreground; otherwise a black frame appears.)
	      NOTE: the "direct write + plot_point edges" fast path is not used - its edge
	      branch never took effect on hardware and left pixels unpainted. */
	color(bgc, bgc, SOLID);
	box(px, py, (UINT8)(px + w - 1U), (UINT8)(py + 11U), M_FILL);

	if (bgc == 3U)						/* black background (console's color(WHITE,BLACK)): white text */
	{
		color(BLACK, WHITE, SOLID);
		zh_ascii_inv(py, px, str, (UINT8)(px + w));
		return;
	}
	color(BLACK, WHITE, SOLID);

	zh_ascii_at(py, px, str, (UINT8)(px + w));
}
