/* The sort's star pass (docs/stars.md), and its stub to PlayKeys.
 *
 * Bank 8, injected at 08:7f29, beside BrowserSortAll (browser_sort.c),
 * which calls both:
 *
 *   PlayKeysFar  after build_keys(n): far stub to PlayKeys (play.c, bank 5),
 *                which rewrites the keys for stars and SORT BY PLAYS and
 *                leaves the directory and star counts at $BA00 on the key
 *                page
 *   PlayMark     last, sorted or not: byte 253 of each starred file's record
 *                (the name's guard NUL) becomes $2A, every other record's 0,
 *                and browser_icons.c draws the star from it. Starred files
 *                sort right after the directories, so they are entries
 *                dirs .. dirs + stars - 1; a listing that was not sorted
 *                (under two entries, or cut, LIST_CUT) has none. A name that
 *                runs to byte 253 has no room for the mark. Leaves page 3
 *                and record page $12 mapped, as the sort did.
 *
 *   python3 tools/inject.py src/play_mark.c $V 8 7f29 PlayKeysFar \
 *       --pin FarCallTrampoline=078d --pin PlayKeys=<bank 5 export> --apply
 */

#include "types.h"

extern void FarCallTrampoline(void);      /* 00:078d */
extern void PlayKeys(void);               /* play.c, bank 5 */

void PlayKeysFar(u16 n) __naked {
    (void)n;
    __asm
	call	_FarCallTrampoline
	.dw	_PlayKeys
	.db	5, 0
	ret

_PlayMark::
	add	sp, #-6			; [0..1] i, [2..3] first star, [4] stars
	ld	hl, #0x7F00		; unlock, $7FC0 = 3, commit
	ld	(hl), #0xE1
	ld	l, #0x10
	ld	(hl), #0xE2
	ld	l, #0x20
	ld	(hl), #0xE3
	ld	l, #0xC0
	ld	(hl), #3
	ld	l, #0xF0
	ld	(hl), #0xE4
	ld	bc, #0
	ld	e, c
	ld	hl, #0xC2A3		; sorted: two or more entries and not cut
	ld	a, (hl-)
	or	a
	jr	nz, 1$
	ld	a, (hl)
	cp	#2
	jr	c, 2$
1$:
	ld	a, (0xDBFA)		; LIST_CUT
	or	a
	jr	nz, 2$
	ld	a, #0x1F
	ld	(0x4000), a
	ld	hl, #0xBA00
	ld	a, (hl+)
	ld	c, a
	ld	a, (hl+)
	ld	b, a
	ld	e, (hl)
2$:
	ldhl	sp, #0
	xor	a
	ld	(hl+), a
	ld	(hl+), a
	ld	(hl), c
	inc	hl
	ld	(hl), b
	inc	hl
	ld	(hl), e
3$:
	ldhl	sp, #0
	ld	a, (hl+)
	ld	c, a
	ld	b, (hl)			; bc = i
	ld	hl, #0xC2A2
	ld	a, c
	sub	(hl)
	inc	hl
	ld	a, b
	sbc	(hl)
	jr	nc, 9$
	ld	d, #0			; i - first < stars: the mark
	ldhl	sp, #2
	ld	a, c
	sub	(hl)
	ld	e, a
	inc	hl
	ld	a, b
	sbc	(hl)
	jr	c, 4$
	or	a
	jr	nz, 4$
	inc	hl
	ld	a, e
	cp	(hl)
	jr	nc, 4$
	ld	d, #0x2A
4$:
	ld	a, c			; record i: page $12 + i / 32
	rlca
	rlca
	rlca
	and	#7
	ld	e, a
	ld	a, b
	add	a, a
	add	a, a
	add	a, a
	or	e
	add	a, #0x12
	ld	(0x4000), a
	ld	a, c			; $A000 + 255 * (i & 31), + 253
	and	#0x1F
	ld	h, a
	ld	l, a
	xor	a
	sub	l
	ld	l, a
	jr	z, 5$
	dec	h
5$:
	ld	a, h
	add	a, #0xA0
	ld	h, a
	ld	b, d
	ld	a, d
	or	a
	jr	z, 7$
	push	hl			; only a name that ends before byte 253
	ld	c, #253
6$:
	ld	a, (hl+)
	or	a
	jr	z, 61$
	dec	c
	jr	nz, 6$
	ld	b, #0
61$:
	pop	hl
7$:
	ld	de, #253
	add	hl, de
	ld	(hl), b
	ldhl	sp, #0
	inc	(hl)
	jr	nz, 3$
	inc	hl
	inc	(hl)
	jr	3$
9$:
	ld	a, #0x12
	ld	(0x4000), a
	add	sp, #6
	ret
    __endasm;
}
