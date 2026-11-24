/* ============================================================================
   ui_zh_home.c  -  the only Chinese-build code that must live in bank 0 (~100 bytes)
   ----------------------------------------------------------------------------
   Why a separate file:
     bank 0 is used up to 0x3E91, leaving 367 bytes. The whole engine would push
     _HOME to 0x41FA, overrunning bank 1 (linker: "Multiple write at 0x4000") and
     the console stays black at boot.

     The bank-switching glyph fetch cannot move: once banks 10-21 are mapped, the
     code at 0x4000 is gone and only bank 0 stays visible. So only "switch bank,
     copy 24 bytes, switch back" stays in bank 0; everything else lives in bank 2.

   Calling convention: a plain call (no __banked), always executable in bank 0.
   ========================================================================== */

#include <gb/gb.h>

#define ZH_GLYPH_BYTES 24			/* 12 rows x 2 bytes */

/* Copy the 24-byte glyph at offset `off` of ROM bank `page` into RAM dst.
      The ROM bank is restored before returning. */
void zh_fetch(UINT8 page, UINT16 off, UINT8 *dst)
{
	UINT8 i;
	UINT8 old = _current_bank;
	UINT8 *src;

	SWITCH_ROM(page);
	src = (UINT8 *)(0x4000U + off);
	for (i = 0; i < ZH_GLYPH_BYTES; i++)
		dst[i] = src[i];
	SWITCH_ROM(old);
}
