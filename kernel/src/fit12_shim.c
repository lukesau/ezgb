/* Fit12 at its old address (docs/font12.md).
 *
 * Bank 2, injected at 02:7100, where the 12px layout was until it moved to
 * bank 10 (Fit12Impl, layout12.c) beside the glyph sets and their metrics.
 * Callers keep calling here: marquee.c and tabstrip12.c with a near call and
 * two dummy pads, MarqueeWidth12 (00:0229) with an inline far call, whose
 * trampoline words stand where the pads are. Either way the arguments start
 * at sp+6: s, len, col, xs.
 *
 * As DrawString12's shim (draw12_shim.c) does, the string is copied to the
 * stack first (bank 2 ROM is out of reach from bank 10): up to 40
 * characters, or len when shorter, NUL-terminated. The pen x of each glyph
 * still goes to the caller's xs, and the count comes back in E.
 *
 *   python3 tools/inject.py src/fit12_shim.c $V 2 7100 Fit12 \
 *       --pin FarCallTrampoline=078d --pin Fit12Impl=4a00 --apply
 */

#include "types.h"

extern void FarCallTrampoline(void);      /* 00:078d */
extern void Fit12Impl(void);              /* 0A:4A00, layout12.c */

u8 Fit12(u16 pad_thunk, u16 pad_af, const u8 *s, u8 len, u8 col, u8 *xs) __naked {
    (void)pad_thunk; (void)pad_af; (void)s; (void)len; (void)col; (void)xs;
    __asm
	add	sp, #-42		; the copy, 41 bytes and a spare
	ldhl	sp, #48
	ld	a, (hl+)
	ld	e, a
	ld	a, (hl+)
	ld	d, a			; de = s
	ld	a, (hl)			; len, 0 = to the NUL
	or	a
	jr	z, 1$
	cp	#41
	jr	c, 2$
1$:
	ld	a, #40
2$:
	ld	c, a
	ldhl	sp, #0
3$:
	ld	a, (de)
	ld	(hl+), a
	or	a
	jr	z, 4$
	inc	de
	dec	c
	jr	nz, 3$
	ld	(hl), c			; c = 0: the NUL after a capped copy
4$:
	ldhl	sp, #53
	ld	a, (hl-)
	ld	d, a
	ld	a, (hl-)
	ld	e, a			; de = xs
	ld	a, (hl-)
	ld	b, a			; col
	ld	c, (hl)			; len
	push	de
	push	bc
	ldhl	sp, #4
	push	hl			; the copy
	call	_FarCallTrampoline
	.dw	_Fit12Impl
	.db	10, 0
	add	sp, #48			; the arguments and the copy; E is the count
	ret
    __endasm;
}
