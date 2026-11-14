/* The accent's draw colors (docs/themes.md "Accents").
 *
 * Bank 0, injected at 00:3fe4, the end of StoreDrawParams (00:2791): its
 * last five bytes, `ld a, [hl]` / `ld [wDrawOp], a` / `ret`, became
 * `jp $3fe4`, and this does them, then, in a theme with an accent (ACC_IDX
 * not 0: DV, or a color theme), moves the kernel's black-on-white to black
 * on the accent: a stored paper of 3 (white) becomes ACC_IDX (DV's lime, a
 * color theme's shade 2), and when the ink is 3 too (a solid white fill) the
 * ink as well. So the selection bar, the active tab, the menus' name band,
 * the rules and the checkbox ticks are in the accent, and white text on the
 * background stays as it is: the same draws, another color index, nothing
 * redrawn. Like the stock routine it uses only A and HL, so a caller keeping
 * BC or DE across the call is safe. Until 2026-11-09 this was DV's alone,
 * testing THEME == 7 and writing 1.
 *
 *   python3 tools/inject.py src/dv_params.c $V 0 3fe4 DvParams \
 *       --pin wDrawOp=d723 --pin wDrawColorB=d735 --apply
 *   python3 tools/patch_bytes.py $V 0 279b 7eea23d7c9 c3e43f0000 --apply
 */

#include "types.h"

extern volatile u8 wDrawOp;        /* $d723 */
extern volatile u8 wDrawColorB;    /* $d735 paper; ink at $d734, just below */

void DvParams(void) __naked {
    __asm
	ld	a, (hl)
	ld	(_wDrawOp), a
	ld	hl, #_wDrawColorB
	ld	a, (hl)
	cp	#3
	ret	nz
	ld	a, (#0xdc0b)		; ACC_IDX
	or	a
	ret	z
	ld	(hl), a			; paper white -> the accent
	dec	hl
	ld	a, (hl)
	cp	#3
	ret	nz
	ld	a, (#0xdc0b)
	ld	(hl), a			; a solid white fill -> the accent
	ret
    __endasm;
}
