;; The other half of long.s, after SDCC's puts in the link: __mullong, the
;; divide and multiply engines and the N-byte helpers, FW4 00:2BEB-2D24.
;; Converted from the stock stage1 disassembly (stage1/fw4) to sdas syntax,
;; not from a published source: no library found has this code (README.md).
;; Labels keep the disassembly's names; the globals are the names the rest
;; of the program links against.

	.module	long2
	.area	_CODE

Call_000_2beb::
	ld	c,b
	xor	a,a
	ld	d,a
jr_000_2bee:
	ld	a,d
	sbc	a,(hl)
	ld	(hl+),a
	dec	c
	jr	nz,jr_000_2bee
	ret
Call_000_2bf5:
	ld	c,b
	xor	a,a
jr_000_2bf7:
	ld	(hl+),a
	dec	c
	jr	nz,jr_000_2bf7
	ret
__mullong::
U32MulImpl:
	lda	sp,-4(sp)
	lda	hl,10(sp)
	push	hl
	lda	hl,8(sp)
	push	hl
	lda	hl,4(sp)
	push	hl
	ld	b,#0x04
	call	U32MulEngine
	lda	sp,6(sp)
	lda	hl,0(sp)
	ld	a,(hl+)
	ld	e,a
	ld	a,(hl+)
	ld	d,a
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	lda	sp,4(sp)
	ret
	ret
U32DivEngine::
	ld	a,b
	sla	a
	sla	a
	sla	a
	ld	c,a
	push	bc
	lda	hl,6(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	call	Call_000_2bf5
	lda	hl,4(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	call	Call_000_2bf5
U32DivEngine_bitLoop:
	lda	hl,8(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	xor	a,a
	call	Call_000_2d1d
	push	af
	lda	hl,6(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	pop	af
	push	hl
	call	Call_000_2d1d
	pop	de
	lda	hl,10(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	push	de
	push	hl
	call	Call_000_2d13
	pop	hl
	pop	de
	jr	c,U32DivEngine_rolQuot
	call	Call_000_2c6b
U32DivEngine_rolQuot:
	ccf
	push	af
	lda	hl,8(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	pop	af
	call	Call_000_2d1d
	pop	bc
	dec	c
	ret	z
	push	bc
	jr	U32DivEngine_bitLoop
Call_000_2c6b:
	ld	c,b
jr_000_2c6c:
	ld	a,(de)
	sbc	a,(hl)
	ld	(de),a
	inc	hl
	inc	de
	dec	c
	jr	nz,jr_000_2c6c
	ret
	ld	c,b
jr_000_2c76:
	ld	(hl+),a
	dec	c
	jr	nz,jr_000_2c76
	ret
U32MulEngine:
	lda	sp,-6(sp)
	lda	hl,12(sp)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	lda	hl,2(sp)
	ld	(hl),e
	inc	hl
	ld	(hl),d
	lda	hl,8(sp)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	lda	hl,0(sp)
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ld	h,d
	ld	l,e
	call	Call_000_2bf5
	lda	hl,4(sp)
	ld	(hl),b
Jump_000_2c99:
	lda	hl,4(sp)
	ld	a,(hl)
	lda	hl,5(sp)
	ld	(hl),a
U32MulEngine_innerDigit:
	lda	hl,12(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	ld	c,(hl)
	lda	hl,10(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	ld	e,(hl)
	call	U8Mul
	lda	hl,5(sp)
	ld	c,(hl)
	lda	hl,8(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	ld	a,(hl)
	add	a,e
	ld	(hl+),a
	dec	c
	jr	z,U32MulEngine_nextOuter
	ld	a,(hl)
	adc	a,d
	ld	(hl+),a
	call	Call_000_2cfe
	lda	hl,5(sp)
	dec	(hl)
	jr	z,U32MulEngine_nextOuter
	lda	hl,12(sp)
	call	Call_000_2d06
	lda	hl,8(sp)
	call	Call_000_2d06
	jr	U32MulEngine_innerDigit
U32MulEngine_nextOuter:
	lda	hl,4(sp)
	dec	(hl)
	jr	z,jr_000_2cfb
	lda	hl,0(sp)
	call	Call_000_2d06
	lda	hl,10(sp)
	call	Call_000_2d06
	push	bc
	ld	b,#0x02
	lda	hl,2(sp)
	ld	d,h
	ld	e,l
	lda	hl,10(sp)
	call	Call_000_2d0b
	lda	hl,4(sp)
	ld	d,h
	ld	e,l
	lda	hl,14(sp)
	call	Call_000_2d0b
	pop	bc
	jp	Jump_000_2c99
jr_000_2cfb:
	lda	sp,6(sp)
	ret
Call_000_2cfe:
jr_000_2cfe:
	dec	c
	ret	z
	ld	a,#0x00
	adc	a,(hl)
	ld	(hl+),a
	jr	jr_000_2cfe
Call_000_2d06:
	inc	(hl)
	ret	nz
	inc	hl
	inc	(hl)
	ret
Call_000_2d0b:
	ld	c,b
jr_000_2d0c:
	ld	a,(de)
	inc	de
	ld	(hl+),a
	dec	c
	jr	nz,jr_000_2d0c
	ret
Call_000_2d13:
	ld	c,b
	xor	a,a
jr_000_2d15:
	ld	a,(de)
	sbc	a,(hl)
	inc	hl
	inc	de
	dec	c
	jr	nz,jr_000_2d15
	ret
Call_000_2d1d:
	ld	c,b
jr_000_2d1e:
	rl	(hl)
	inc	hl
	dec	c
	jr	nz,jr_000_2d1e
	ret
