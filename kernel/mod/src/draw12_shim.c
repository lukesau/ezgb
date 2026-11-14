/* DrawString12 at its old address (docs/font12.md).
 *
 * Bank 2, injected at 02:7500, where the 12px renderer was until it moved to
 * bank 10 (DrawString12Impl, draw12.c) beside the glyph sets. Callers keep
 * calling here: bank-2 code with a near call and three dummy pads, other banks
 * through FarCallDrawString12 (00:05c0), whose trampoline words stand where
 * the pads are. Either way the arguments start at sp+8.
 *
 * Bank-2 callers pass strings in bank 2 ROM (labels, messages), which the
 * renderer cannot read from bank 10, so the string is copied to the stack
 * first: up to 40 characters, the most the renderer places, or len when it
 * is shorter, NUL-terminated. Then an inline far call to the renderer with
 * the copy and the same len, col and row.
 *
 *   python3 tools/inject.py src/draw12_shim.c $V 2 7500 DrawString12 \
 *       --pin FarCallTrampoline=078d --pin DrawString12Impl=4000 --apply
 */

#include "types.h"

extern void FarCallTrampoline(void);      /* 00:078d */
extern void DrawString12Impl(void);       /* 0A:4000, draw12.c */

void DrawString12(u16 pad_thunk, u16 pad_af, u16 pad_ret, const u8 *s, u8 len, u8 col, u8 row) __naked {
    (void)pad_thunk; (void)pad_af; (void)pad_ret; (void)s; (void)len; (void)col; (void)row;
    __asm
	add	sp, #-42		; the copy, 41 bytes and a spare
	ldhl	sp, #50
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
	ldhl	sp, #54
	ld	a, (hl-)
	ld	b, a			; row
	ld	a, (hl-)
	ld	c, a			; col
	ld	a, (hl)			; len
	push	bc
	push	af
	inc	sp
	ldhl	sp, #3
	push	hl			; the copy
	call	_FarCallTrampoline
	.dw	_DrawString12Impl
	.db	10, 0
	add	sp, #47			; the arguments and the copy
	ret
    __endasm;
}
