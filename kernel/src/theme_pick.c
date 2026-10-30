/* The custom theme's bank-2 side (docs/dark-mode.md).
 *
 * Bank 2, injected at 02:4990, after ThemeRamps. Two entries:
 *
 *   FarCallColors  02:4990, ezcfg's stub for colors (05:7b50,
 *                  theme_colors.c): parsing and writing COLORS=
 *   theme_ramp     02:4998, the four colors THEME draws in, for theme.c,
 *                  called with the pSRAM mark mapped. It cannot far-call:
 *                  the boot runs theme with interrupts off.
 *
 * Before the file is read (boot), the mark's colors become CUST_RAMP, so a
 * custom theme's first frames need no file. After, THEME is only custom
 * with a valid COLORS= (ezcfg's cfg_load, theme_row.c), which set CUST_RAMP.
 */

#include "types.h"
#include "vars.h"
#include "ezcfg.h"

extern void FarCallTrampoline(void);           /* 00:078d */
extern const u8 theme_ramps[THEME_CUSTOM][8];  /* 02:4960, theme_ramps.c */

u8 *FarCallColors(u8 op, u8 *p, u8 len) __naked {
    (void)op; (void)p; (void)len;
    __asm
	call	_FarCallTrampoline
	.dw	0x7b50
	.db	5, 0
	ret
    __endasm;
}

const u8 *theme_ramp(void) __naked {
    __asm
	ld	de, #0xdb58		; CUST_RAMP
	ld	a, (#0xdbf9)		; CFG_LOADED
	or	a
	jr	nz, 2$
	ld	hl, #0xa418		; the mark colors, page $11
	ld	b, #8
1$:
	ld	a, (hl+)
	ld	(de), a
	inc	de
	dec	b
	jr	nz, 1$
	ld	de, #0xdb58
2$:
	ld	a, (#0xdbf7)		; THEME
	cp	#6			; THEME_CUSTOM
	ret	z

	add	a
	add	a
	add	a
	add	#<_theme_ramps
	ld	e, a
	adc	#>_theme_ramps
	sub	e
	ld	d, a
	ret
    __endasm;
}
