/* ============================================================================
   fill_fast.c  -  fast rectangle fill (**English build only**, bank 1)
   ----------------------------------------------------------------------------
   Why en only: the zh build handles fills in ui_zh.c / ui_zh_fast.s, which already
   have byte-level writes plus the whole 12px glyph fast path.

   The library's box(...,M_FILL) draws four border lines plus one .line per row,
   each pixel going through .plot: mode dispatch, y_table lookup, bit lookup and a
   read-modify-write of both planes. A 160x144 clear is 23,000 calls (about 0.7s
   on hardware), the most visible stall in the English build.

   This module writes both plane bytes per tile directly:
            byte address = 0x8100 + (y/8)*0x140 + (y%8)*2 + tile*16
            plane0 at that byte, plane1 at +1, tiles 16 bytes apart
   (identical to GBDK's drawing.s y_table / .plot, checked against the shipped ROM)

   The 8-pixel-aligned middle is written a byte at a time; edges shorter than 8
   pixels use plot_point so the colour index is exact (**no VRAM read-modify-write**
   - the zh build tried masked RMW and got stripes on hardware).

   Each write waits for STAT to leave mode 2/3 (like the library's WAIT_STAT).

   bg: 0 = white, 1 = light grey, 2 = dark grey, 3 = black.
   ========================================================================== */

#include <gb/gb.h>
#include <gb/drawing.h>

#pragma bank 1

#define FILL_STAT	(*(volatile UINT8 *)0xFF41)

void fill_fast_rect(UINT8 x0, UINT8 y0, UINT8 x1, UINT8 y1, UINT8 bg) __banked
{
	UINT8  p0, p1;
	UINT8  a, b, y, t, x, n;
	UINT8 *q;
	UINT16 base;

	if (x0 > x1 || y0 > y1) return;

	bg &= 0x03U;
	switch (bg)
	{
		case 0U:  p0 = 0x00U; p1 = 0x00U; break;	/* white */
		case 1U:  p0 = 0xFFU; p1 = 0x00U; break;	/* light grey */
		case 2U:  p0 = 0x00U; p1 = 0xFFU; break;	/* dark grey */
		default:  p0 = 0xFFU; p1 = 0xFFU; break;	/* black */
	}

	plot_point(x0, y0);		/* fallback .gmode trigger; the fill covers this pixel */

	a = (UINT8)((x0 + 7U) & 0xF8U);		/* left edge of the first whole tile */
	b = (UINT8)((x1 + 1U) & 0xF8U);		/* right edge of the whole-tile area (exclusive) */

	if ((a < b) && (a <= x1))
	{
		n = (UINT8)((b - a) >> 3);		/* number of whole tiles */
		for (y = y0; y <= y1; y++)
		{
			base = (UINT16)(0x8100U
					+ ((UINT16)(y >> 3) * 0x0140U)
					+ ((UINT16)(y & 0x07U) << 1));
			q = (UINT8 *)(UINT16)(base + ((UINT16)a << 1));
			for (t = 0U; t < n; t++)
			{
				while (FILL_STAT & 0x02U) ;	/* mode 2/3: VRAM not writable */
				q[0] = p0;
				q[1] = p1;
				q += 16;
			}
		}
	}

	/* edges: plot_point writes the foreground index, so set fg to the target colour */
	if ((x0 < a) || (b <= x1))
	{
		color(bg, WHITE, SOLID);
		for (y = y0; y <= y1; y++)
		{
			for (x = x0; x < a && x <= x1; x++)
				plot_point(x, y);
			for (x = (b > x0) ? b : x0; x <= x1; x++)
				plot_point(x, y);
		}
		color(BLACK, WHITE, SOLID);
	}
}
