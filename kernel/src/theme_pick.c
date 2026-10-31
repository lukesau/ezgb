/* Theme colors' bank-2 side (docs/dark-mode.md).
 *
 * Bank 2, injected at 02:4990, after ThemeRamps. Two entries:
 *
 *   FarCallColors  02:4990, ezcfg's stub to 05:7b50 (theme_colors.c),
 *                  which writes THEME= and BOOTROM= on a save and still
 *                  reads a COLORS= line, which no theme uses since custom
 *                  was retired (2026-10-31)
 *   theme_ramp     02:4998, the four colors THEME draws in, for theme.c: a
 *                  row of theme_ramps.c. It cannot far-call: the boot runs
 *                  theme with interrupts off.
 */

#include "types.h"
#include "vars.h"
#include "ezcfg.h"

extern void FarCallTrampoline(void);           /* 00:078d */
extern const u8 theme_ramps[3][8];             /* 02:4960, theme_ramps.c: light, dark, DV */

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
	ld	a, (#0xdbf7)		; THEME: 0 light, 1 dark, 7 DV (row 2),
	cp	#7			; and 2..6, retired, dark
	jr	nz, 1$
	ld	a, #2
	jr	2$
1$:
	cp	#2
	jr	c, 2$
	ld	a, #1
2$:
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
