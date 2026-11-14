/* Play counts and stars (docs/stars.md).
 *
 * Bank 5, injected at 05:7c9f. Asm: SDCC made 1982 bytes of the C, more
 * than twice the room. A table in battery-backed pSRAM, page $11, keeps one
 * 8-byte entry per ROM that was launched or starred:
 *
 *   [0..3] hash of the file name (below), the sort key
 *   [4..5] launches, little-endian
 *   [6]    bit 0: starred
 *   [7]    0
 *
 * from $B800, sorted by hash, so a lookup is a binary search. The header at
 * $B7F8 is 'P', 'L', the entry count (up to 254) and the star count;
 * anything else (a new cart, a dry battery) starts an empty table. When the
 * table is full a new name takes the place of the least-launched entry that
 * has no star; with every entry starred, a new star is refused.
 *
 * The name is the file name alone, uppercased, so a ROM keeps its count
 * when it moves to another folder, and two copies in different folders
 * share one. The hash is two 16-bit sums over it, a = a * 33 + c (djb2,
 * from 5381) and b = b + a, stored a hi, a lo, b hi, b lo.
 *
 * Entry points (Bump is the block's address, the rest are exports), all
 * far-called:
 *
 *   Bump         one more launch for the basename of the path at $c2a6.
 *                PlayLaunchHook (01:7ec6) calls it and goes on to
 *                LastRomSaveHook; 01:48c1, LastRomPersist's tail, jumps
 *                there.
 *   PlayKeys     the sort (browser_sort.c), after build_keys(n): a starred
 *                file's key class becomes 1, any other file's 2, and with
 *                SORT BY PLAYS on, key byte 1 becomes 255 - launches (the
 *                name moves up a byte). Writes the directory and star counts
 *                after the keys, at $BA00 on the key page, for PlayMark
 *                (play_mark.c), which marks the starred records.
 *   StarQuery    the hold-A menu (rom_menu.c): E = 1 when the ROM in $c4a4
 *                is starred
 *   StarToggle   the hold-A menu's Star: toggle, sort the folder again and
 *                put the cursor back on the ROM
 *
 * The last three are far-called through `call`ed stubs, so their argument
 * (n, or the browser frame's slot pointer, rom_menu.c) is at sp+8; both
 * menu calls map the cursor record page again before they return.
 *
 * SORT BY PLAYS is a pSRAM record next to SGB BOOT's, page $11 $A404:
 * 'S', 'O', 1, $FE (setpage.c sets it).
 *
 *   python3 tools/inject.py src/play.c $V 5 7c9f Bump \
 *       --pin BrowserSortAllStub=03d4 --apply
 */

#include "types.h"

extern void BrowserSortAllStub(void);     /* 00:03d4 -> BrowserSortAll (08:746b) */

void Bump(void) __naked {
    __asm
	add	sp, #-4
	ld	hl, #0xC2A6		; the launch path
	ld	d, h
	ld	e, l
1$:
	ld	a, (hl+)
	or	a
	jr	z, 2$
	cp	#0x2F			; '/'
	jr	nz, 1$
	ld	d, h
	ld	e, l
	jr	1$
2$:
	ldhl	sp, #0
	call	Hash
	call	Meta
	call	Make
	jr	c, 3$
	ld	a, l
	or	#4
	ld	l, a
	inc	(hl)
	jr	nz, 3$
	inc	l
	inc	(hl)
3$:
	xor	a
	ld	(0x4000), a
	call	Fpga			; page 0, as LastRomPersist left it
	add	sp, #4
	ret

; ---------------------------------------------------------------- the sort

_PlayKeys::
	add	sp, #-10		; [0..3] hash, [4] by plays, [5..6] dirs, [7] stars, [8..9] i; n at sp+18
	call	Meta
	ld	hl, #0xA404		; 'S', 'O', 1, $FE: SORT BY PLAYS
	ld	a, (hl+)
	cp	#0x53
	jr	nz, 1$
	ld	a, (hl+)
	cp	#0x4F
	jr	nz, 1$
	ld	a, (hl+)
	dec	a
	jr	nz, 1$
	ld	a, (hl)
	cp	#0xFE
	ld	a, #1
	jr	z, 2$
1$:
	xor	a
2$:
	ldhl	sp, #4
	ld	(hl+), a
	ld	b, a
	xor	a
	ld	(hl+), a
	ld	(hl+), a
	ld	(hl+), a
	ld	(hl+), a
	ld	(hl), a
	ld	a, (0xB7FB)		; nothing to do with no star and A-Z
	or	b
	jp	z, 9$
3$:
	ldhl	sp, #8
	ld	a, (hl+)
	ld	c, a
	ld	b, (hl)			; bc = i
	ldhl	sp, #18
	ld	a, c
	sub	(hl)
	inc	hl
	ld	a, b
	sbc	(hl)
	jp	nc, 9$
	ld	a, #0x1F		; the key page
	ld	(0x4000), a
	ld	h, b
	ld	l, c
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	a, h
	add	a, #0xA0
	ld	h, a			; hl = key i
	ld	a, (hl)
	or	a
	jr	nz, 4$
	ldhl	sp, #5			; class 0: a directory
	inc	(hl)
	jr	nz, 8$
	inc	hl
	inc	(hl)
	jr	8$
4$:
	push	hl
	call	RecMap
	ldhl	sp, #2
	call	Hash
	ld	a, #0x11
	ld	(0x4000), a
	call	Find
	ld	bc, #0xFF02		; b = score, c = class
	jr	nc, 6$
	ld	a, l
	or	#4
	ld	l, a
	ld	a, (hl+)
	cpl
	ld	b, a			; 255 - launches
	ld	a, (hl+)
	or	a
	jr	z, 5$
	ld	b, #0			; 256 or more
5$:
	bit	0, (hl)
	jr	z, 6$
	dec	c			; starred: class 1
	ldhl	sp, #9
	inc	(hl)
6$:
	ld	a, #0x1F
	ld	(0x4000), a
	ldhl	sp, #6
	ld	a, (hl)
	pop	hl
	ld	(hl), c
	or	a
	jr	z, 8$
	ld	de, #13			; by plays: key[2..13] = key[1..12], key[1] = score
	add	hl, de
	ld	c, #12
7$:
	dec	hl
	ld	a, (hl+)
	ld	(hl-), a
	dec	c
	jr	nz, 7$
	ld	(hl), b
8$:
	ldhl	sp, #8
	inc	(hl)
	jp	nz, 3$
	inc	hl
	inc	(hl)
	jp	3$
9$:
	ld	a, #0x1F
	ld	(0x4000), a
	ldhl	sp, #5
	ld	a, (hl+)
	ld	(0xBA00), a
	ld	a, (hl+)
	ld	(0xBA01), a
	ld	a, (hl)
	ld	(0xBA02), a
	add	sp, #10
	ret

; ---------------------------------------------------------------- the menu

_StarQuery::
	add	sp, #-4
	ld	de, #0xC4A4		; the menu copied the name here
	ldhl	sp, #0
	call	Hash
	call	Meta
	call	Find
	ld	e, #0
	jr	nc, 1$
	ld	a, l
	or	#6
	ld	l, a
	ld	a, (hl)
	and	#1
	ld	e, a
1$:
	push	de
	ldhl	sp, #14			; slot
	call	Back
	pop	de
	add	sp, #4
	ret

_StarToggle::
	add	sp, #-8			; [0..3] the ROM hash, [4..7] a record hash; slot at sp+16
	ld	de, #0xC4A4		; hashed before the sort reuses $c4a4
	ldhl	sp, #0
	call	Hash
	call	Meta
	call	Make
	jr	c, 2$
	ld	a, l
	or	#6
	ld	l, a
	ld	a, (hl)
	xor	#1
	ld	(hl), a
	rra
	ld	a, (0xB7FB)
	jr	nc, 1$
	inc	a
	ld	(0xB7FB), a
	jr	2$
1$:
	dec	a
	ld	(0xB7FB), a
	dec	l			; no star and no launches: drop it
	ld	a, (hl-)
	or	(hl)
	jr	nz, 2$
	ld	a, l
	and	#0xF8
	ld	l, a
	call	Drop
2$:
	ld	a, (0xDBFA)		; LIST_CUT: the listing stays as it is
	or	a
	jr	nz, 9$
	call	_BrowserSortAllStub
	ld	bc, #0
3$:
	ld	hl, #0xC2A2
	ld	a, c
	sub	(hl)
	inc	hl
	ld	a, b
	sbc	(hl)
	jr	nc, 9$
	push	bc
	call	RecMap
	ldhl	sp, #6
	call	Hash
	ldhl	sp, #2
	call	Cmp4
	pop	bc
	jr	z, 4$
	inc	bc
	jr	3$
4$:
	ldhl	sp, #16			; the cursor on entry i, on the same row if it can be
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	ld	de, #0x0F
	add	hl, de
	push	hl			; &base
	inc	hl
	inc	hl
	ld	e, (hl)			; sel
	ld	a, c
	sub	e
	ld	l, a
	ld	a, b
	sbc	#0
	ld	h, a			; base = i - sel
	jr	nc, 5$
	ld	hl, #0
5$:
	ldh	a, (0xFB)		; hUiMode: 10 rows, else 16
	or	a
	ld	a, #16
	jr	z, 6$
	ld	a, #10
6$:
	ld	e, a
	push	hl
	ld	hl, #0xC2A2
	ld	a, (hl+)
	sub	e
	ld	e, a
	ld	a, (hl)
	sbc	#0
	ld	d, a			; at most n - rows
	jr	nc, 7$
	ld	de, #0
7$:
	pop	hl
	ld	a, e
	sub	l
	ld	a, d
	sbc	h
	jr	nc, 8$
	ld	h, d
	ld	l, e
8$:
	ld	d, h
	ld	e, l
	pop	hl
	ld	(hl), e
	inc	hl
	ld	(hl), d
	inc	hl
	ld	a, c
	sub	e
	ld	(hl), a
9$:
	ldhl	sp, #16
	call	Back
	add	sp, #8
	ret

; hl = where the slot pointer is: maps the record page of the cursor
; entry (the base word of the slot at +$0f plus its row at +$11)
Back:
	ld	a, (hl+)
	ld	h, (hl)
	ld	l, a
	ld	bc, #0x0F
	add	hl, bc
	ld	a, (hl+)
	ld	c, a
	ld	a, (hl+)
	ld	b, a
	ld	a, (hl)
	add	a, c
	ld	c, a
	jr	nc, RecPage
	inc	b
; bc = entry -> its record page mapped (a = the page)
RecPage:
	ld	a, c
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
	ret

; bc = entry -> de = its record, page mapped; keeps bc
RecMap:
	call	RecPage
	ld	a, c
	and	#0x1F
	ld	d, a			; de = $A000 + 255 * slot
	ld	e, a
	xor	a
	sub	e
	ld	e, a
	jr	z, 1$
	dec	d
1$:
	ld	a, d
	add	a, #0xA0
	ld	d, a
	ret

; ---------------------------------------------------------------- the table

; de = name, hl = 4-byte buffer -> the hash of the name in it, de = the buffer
Hash:
	push	hl
	ld	hl, #5381
	ld	bc, #0
1$:
	ld	a, (de)
	inc	de
	or	a
	jr	z, 3$
	cp	#0x61
	jr	c, 2$
	cp	#0x7B
	jr	nc, 2$
	sub	#0x20
2$:
	push	de
	ld	d, h
	ld	e, l
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	ld	e, a
	ld	d, #0
	add	hl, de
	ld	a, c
	add	a, l
	ld	c, a
	ld	a, b
	adc	a, h
	ld	b, a
	pop	de
	jr	1$
3$:
	ld	d, h
	ld	e, l
	pop	hl
	push	hl
	ld	(hl), d
	inc	hl
	ld	(hl), e
	inc	hl
	ld	(hl), b
	inc	hl
	ld	(hl), c
	pop	de
	ret

; a = page: unlock, $7FC0 = a, commit
Fpga:
	ld	hl, #0x7F00
	ld	(hl), #0xE1
	ld	l, #0x10
	ld	(hl), #0xE2
	ld	l, #0x20
	ld	(hl), #0xE3
	ld	l, #0xC0
	ld	(hl), a
	ld	l, #0xF0
	ld	(hl), #0xE4
	ret

; page $11 mapped, the header checked; keeps bc, de
Meta:
	ld	a, #3
	call	Fpga
	ld	a, #0x11
	ld	(0x4000), a
	ld	hl, #0xB7F8
	ld	a, (hl+)
	cp	#0x50			; 'P'
	jr	nz, 1$
	ld	a, (hl+)
	cp	#0x4C			; 'L'
	jr	nz, 1$
	ld	a, (hl+)
	cp	#0xFF			; up to 254 entries
	jr	nc, 1$
	cp	(hl)			; stars <= entries
	ret	nc
1$:
	ld	l, #0xF8		; h is still $B7
	ld	(hl), #0x50
	inc	hl
	ld	(hl), #0x4C
	inc	hl
	xor	a
	ld	(hl+), a
	ld	(hl), a
	ret

; a = index -> hl = its entry ($B800 + 8a); keeps a, bc, de
Entry:
	push	af
	ld	l, a
	ld	h, #0x17
	add	hl, hl
	add	hl, hl
	add	hl, hl
	pop	af
	ret

; hl, de = two hashes -> z when equal, c when de is lower; keeps bc, de, hl
Cmp4:
	push	bc
	push	de
	push	hl
	ld	b, #4
1$:
	ld	a, (de)
	cp	(hl)
	jr	nz, 2$
	inc	de
	inc	hl
	dec	b
	jr	nz, 1$
2$:
	pop	hl
	pop	de
	pop	bc
	ret

; de = hash -> a = its index (or where it would go), hl = that entry,
; c when found; keeps de
Find:
	ld	a, (0xB7FA)
	ld	b, a			; hi
	ld	c, #0			; lo
1$:
	ld	a, c
	cp	b
	jr	nc, 4$
	add	a, b
	rra				; mid
	call	Entry
	push	af			; Cmp4 uses a
	call	Cmp4
	jr	z, 3$
	jr	c, 2$
	pop	af
	inc	a
	ld	c, a
	jr	1$
2$:
	pop	af
	ld	b, a
	jr	1$
3$:
	pop	af
	scf
	ret
4$:
	ld	a, c
	call	Entry
	and	a
	ret

; de = hash -> hl = its entry, made (no launches, no star) when new; c when
; every entry is starred and there is no room
Make:
	call	Find
	ccf
	ret	nc
	ld	a, (0xB7FA)
	cp	#254
	jr	c, 1$
	call	Evict
	ret	c
	jr	Make
1$:
	push	de
	push	hl			; its place: entries from here move up one
	call	Entry			; hl = the end
	ld	b, h
	ld	c, l
	ld	a, c
	add	a, #8
	ld	c, a
	jr	nc, 2$
	inc	b
2$:
	pop	de
3$:
	ld	a, l
	cp	e
	jr	nz, 4$
	ld	a, h
	cp	d
	jr	z, 5$
4$:
	dec	hl
	dec	bc
	ld	a, (hl)
	ld	(bc), a
	jr	3$
5$:
	pop	de
	push	hl
	ld	c, #4
6$:
	ld	a, (de)
	inc	de
	ld	(hl+), a
	dec	c
	jr	nz, 6$
	xor	a
	ld	(hl+), a
	ld	(hl+), a
	ld	(hl+), a
	ld	(hl), a
	ld	hl, #0xB7FA
	inc	(hl)
	pop	hl
	and	a
	ret

; drop the least-launched entry without a star (launches past 254 count
; as 255); c when every entry is starred; keeps de
Evict:
	push	de
	ld	a, (0xB7FA)
	ld	c, a
	ld	b, #0xFF
	ld	hl, #0xB800
	ld	de, #0
1$:
	ld	a, c
	or	a
	jr	z, 4$
	dec	c
	push	hl
	ld	a, l
	or	#6
	ld	l, a
	bit	0, (hl)
	jr	nz, 3$
	dec	l
	ld	a, (hl-)
	or	a
	ld	a, #0xFF
	jr	nz, 2$
	ld	a, (hl)
2$:
	cp	b
	jr	z, 21$
	jr	nc, 3$
21$:
	ld	b, a
	pop	de
	push	de
3$:
	pop	hl
	ld	a, l
	add	a, #8
	ld	l, a
	jr	nc, 1$
	inc	h
	jr	1$
4$:
	ld	a, d
	or	e
	jr	z, 5$
	ld	h, d
	ld	l, e
	call	Drop
	pop	de
	and	a
	ret
5$:
	pop	de
	scf
	ret

; hl = entry: remove it, the entries after it move down one
Drop:
	ld	a, (0xB7FA)
	dec	a
	ld	(0xB7FA), a
	push	hl
	call	Entry
	ld	d, h
	ld	e, l			; stop at the new end
	pop	hl
1$:
	ld	a, l
	cp	e
	jr	nz, 2$
	ld	a, h
	cp	d
	ret	z
2$:
	push	hl
	ld	bc, #8
	add	hl, bc
	ld	a, (hl)
	pop	hl
	ld	(hl+), a
	jr	1$
    __endasm;
}
