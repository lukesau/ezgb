;; 32-bit divide and modulo (SDCC's __divslong, __divulong, __modslong,
;; __modulong), 8x8 and 16x16 multiply, 32-bit compare helpers and memcpy,
;; FW4 00:2949-2BA5. The 32-bit routines work on operands of any width
;; (the width in b) through the helpers here and in long2.s; a zero divisor
;; sets errno to 33 (SDCC's EDOM) and returns $7FFFFFFF.
;; Converted from the stock stage1 disassembly (stage1/fw4) to sdas syntax,
;; not from a published source: no library found has this code (README.md).
;; Labels keep the disassembly's names; the globals are the names the rest
;; of the program links against.

	.module	long
	.area	_DATA
_errno::
	.ds	2

	.area	_CODE

__modslong::
Jump_000_2949:
	lda	sp,-9(sp)
	ld	b,#0x04
	lda	hl,11(sp)
	call	MemIsZero
	jr	nz,jr_000_295c
	xor	a,a
	ld	e,a
	ld	d,a
	ld	l,a
	ld	h,a
	jp	Jump_000_29bf
jr_000_295c:
	lda	hl,15(sp)
	call	MemIsZero
	jr	nz,jr_000_2972
	ld	a,#0x21
	ld	(_errno),a
	ld	a,#0xff
	ld	e,a
	ld	d,a
	ld	l,a
	ld	h,#0x7f
	jp	Jump_000_29bf
jr_000_2972:
	lda	hl,0(sp)
	xor	a,a
	ld	(hl),a
	lda	hl,18(sp)
	ld	a,(hl)
	bit	7,a
	jr	z,jr_000_2986
	lda	hl,15(sp)
	call	Call_000_2beb
	lda	hl,0(sp)
	ld	(hl),#0x01
jr_000_2986:
	lda	hl,14(sp)
	ld	a,(hl)
	bit	7,a
	jr	z,S32DivImpl_u32DivEngine
	lda	hl,11(sp)
	call	Call_000_2beb
	lda	hl,0(sp)
	ld	a,#0x01
	xor	a,(hl)
	ld	(hl),a
S32DivImpl_u32DivEngine:
	lda	hl,15(sp)
	push	hl
	lda	hl,13(sp)
	push	hl
	lda	hl,9(sp)
	push	hl
	lda	hl,7(sp)
	push	hl
	call	U32DivEngine
	lda	sp,8(sp)
	lda	hl,0(sp)
	rr	(hl)
	jr	nc,jr_000_29b6
	ld	b,#0x04
	lda	hl,1(sp)
	call	Call_000_2beb
jr_000_29b6:
	lda	hl,1(sp)
	ld	a,(hl+)
	ld	e,a
	ld	a,(hl+)
	ld	d,a
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
Jump_000_29bf:
	lda	sp,9(sp)
	ret
__modulong::
Jump_000_29c2:
	lda	sp,-8(sp)
	ld	b,#0x04
	lda	hl,10(sp)
	call	MemIsZero
	jr	nz,jr_000_29d5
	xor	a,a
	ld	e,a
	ld	d,a
	ld	l,a
	ld	h,a
	jp	Jump_000_2a05
jr_000_29d5:
	lda	hl,14(sp)
	call	MemIsZero
	jr	nz,U32ModImpl_runEngine
	ld	a,#0x21
	ld	(_errno),a
	ld	a,#0xff
	ld	e,a
	ld	d,a
	ld	l,a
	ld	h,#0x7f
	jp	Jump_000_2a05
U32ModImpl_runEngine:
	lda	hl,14(sp)
	push	hl
	lda	hl,12(sp)
	push	hl
	lda	hl,8(sp)
	push	hl
	lda	hl,6(sp)
	push	hl
	call	U32DivEngine
	lda	sp,8(sp)
	lda	hl,0(sp)
	ld	a,(hl+)
	ld	e,a
	ld	a,(hl+)
	ld	d,a
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
Jump_000_2a05:
	lda	sp,8(sp)
	ret
MemIsZero:
	xor	a,a
	ld	c,b
MemIsZero_scanLoop:
	cp	a,(hl)
	ret	nz
	inc	hl
	dec	c
	jr	nz,MemIsZero_scanLoop
	ret
	push	hl
	ld	a,(hl-)
	ld	c,a
	ld	a,(hl)
	set	7,(hl)
	rla
	ld	a,c
	rla
	pop	hl
	ld	(hl),a
	ret
Call_000_2a1d:
	xor	a,a
	bit	7,(hl)
	jr	z,ClearNegZero32_matchMsb
	ld	a,#0x80
ClearNegZero32_matchMsb:
	cp	a,(hl)
	ret	nz
	xor	a,a
	dec	hl
	cp	a,(hl)
	ret	nz
	dec	hl
	cp	a,(hl)
	ret	nz
	dec	hl
	cp	a,(hl)
	ret	nz
	inc	hl
	inc	hl
	inc	hl
	res	7,(hl)
	ret
jr_000_2a36:
	ld	c,#0x03
jr_000_2a38:
	ld	a,(de)
	sub	a,(hl)
	ret	nz
	dec	de
	dec	hl
	dec	c
	ret	z
	jr	jr_000_2a38
S32Cmp:
	lda	hl,7(sp)
	call	Call_000_2a1d
	lda	hl,11(sp)
	call	Call_000_2a1d
	lda	hl,7(sp)
	bit	7,(hl)
	jr	z,jr_000_2a62
	lda	hl,11(sp)
	bit	7,(hl)
	jr	z,S32Cmp_retALess
	lda	hl,11(sp)
	ld	d,h
	ld	e,l
	lda	hl,7(sp)
	jr	jr_000_2a36
S32Cmp_retALess:
	xor	a,a
	ccf
	ret
jr_000_2a62:
	lda	hl,11(sp)
	bit	7,(hl)
	jr	z,jr_000_2a6b
	xor	a,a
	dec	a
	ret
jr_000_2a6b:
	lda	hl,7(sp)
	ld	d,h
	ld	e,l
	lda	hl,11(sp)
	jr	jr_000_2a36
__divslong::
Jump_000_2a73:
	lda	sp,-9(sp)
	ld	b,#0x04
	lda	hl,11(sp)
	call	MemIsZero
	jr	nz,jr_000_2a86
	xor	a,a
	ld	e,a
	ld	d,a
	ld	l,a
	ld	h,a
	jp	Jump_000_2aea
jr_000_2a86:
	lda	hl,15(sp)
	call	MemIsZero
	jr	nz,jr_000_2a9c
	ld	a,#0x21
	ld	(_errno),a
	ld	a,#0xff
	ld	e,a
	ld	d,a
	ld	l,a
	ld	h,#0x7f
	jp	Jump_000_2aea
jr_000_2a9c:
	lda	hl,0(sp)
	xor	a,a
	ld	(hl),a
	lda	hl,18(sp)
	ld	a,(hl)
	bit	7,a
	jr	z,jr_000_2ab0
	lda	hl,15(sp)
	call	Call_000_2beb
	lda	hl,0(sp)
	ld	(hl),#0x01
jr_000_2ab0:
	lda	hl,14(sp)
	ld	a,(hl)
	bit	7,a
	jr	z,S32ModImpl_u32DivEngine
	lda	hl,11(sp)
	call	Call_000_2beb
	lda	hl,0(sp)
	ld	a,#0x01
	xor	a,(hl)
	ld	(hl),a
S32ModImpl_u32DivEngine:
	lda	hl,15(sp)
	push	hl
	lda	hl,13(sp)
	push	hl
	lda	hl,9(sp)
	push	hl
	lda	hl,7(sp)
	push	hl
	call	U32DivEngine
	lda	sp,8(sp)
	lda	hl,0(sp)
	rr	(hl)
	jr	nc,jr_000_2ae1
	ld	b,#0x04
	xor	a,a
	lda	hl,5(sp)
	call	Call_000_2beb
jr_000_2ae1:
	lda	hl,5(sp)
	ld	a,(hl+)
	ld	e,a
	ld	a,(hl+)
	ld	d,a
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
Jump_000_2aea:
	lda	sp,9(sp)
	ret
__mulschar_rrx_s::
S8Mul:
	lda	hl,2(sp)
	ld	a,(hl+)
	ld	c,a
	ld	e,(hl)
	ld	a,c
	rla
	sbc	a,a
	ld	b,a
	ld	a,e
	rla
	sbc	a,a
	ld	d,a
	jr	jr_000_2b23
__muluchar_rrx_s::
Jump_000_2afc:
	lda	hl,2(sp)
	ld	a,(hl+)
	ld	c,a
	ld	e,(hl)
U8Mul::
	xor	a,a
	ld	h,a
	ld	l,a
	ld	d,a
jr_000_2b05:
	xor	a,a
	rr	c
	jr	nc,jr_000_2b0b
	add	hl,de
jr_000_2b0b:
	sla	e
	jr	z,jr_000_2b13
	rl	d
	jr	jr_000_2b05
jr_000_2b13:
	rl	d
	jr	nz,jr_000_2b05
	ld	e,l
	ld	d,h
	ret
__mulint_rrx_s::
S16Mul:
	lda	hl,2(sp)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
jr_000_2b23:
	ld	hl,#0x00
jr_000_2b26:
	sra	b
	jr	nz,jr_000_2b33
	rr	c
	jr	nc,jr_000_2b2f
	add	hl,de
jr_000_2b2f:
	jr	z,jr_000_2b44
	jr	jr_000_2b38
jr_000_2b33:
	rr	c
	jr	nc,jr_000_2b38
	add	hl,de
jr_000_2b38:
	sla	e
	jr	z,jr_000_2b40
	rl	d
	jr	jr_000_2b26
jr_000_2b40:
	rl	d
	jr	nz,jr_000_2b26
jr_000_2b44:
	ld	e,l
	ld	d,h
	ret
__divulong::
Jump_000_2b47:
	lda	sp,-8(sp)
	ld	b,#0x04
	lda	hl,10(sp)
	call	MemIsZero
	jr	nz,jr_000_2b5a
	xor	a,a
	ld	e,a
	ld	d,a
	ld	l,a
	ld	h,a
	jp	Jump_000_2b8a
jr_000_2b5a:
	lda	hl,14(sp)
	call	MemIsZero
	jr	nz,U32DivImpl_runEngine
	ld	a,#0x21
	ld	(_errno),a
	ld	a,#0xff
	ld	e,a
	ld	d,a
	ld	l,a
	ld	h,#0x7f
	jp	Jump_000_2b8a
U32DivImpl_runEngine:
	lda	hl,14(sp)
	push	hl
	lda	hl,12(sp)
	push	hl
	lda	hl,8(sp)
	push	hl
	lda	hl,6(sp)
	push	hl
	call	U32DivEngine
	lda	sp,8(sp)
	lda	hl,4(sp)
	ld	a,(hl+)
	ld	e,a
	ld	a,(hl+)
	ld	d,a
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
Jump_000_2b8a:
	lda	sp,8(sp)
	ret
_memcpy::
Memcpy:
	lda	hl,6(sp)
	ld	a,(hl+)
	ld	c,a
	ld	b,(hl)
	lda	hl,4(sp)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	lda	hl,2(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
Memcpy_copyLoop:
	ld	a,b
	or	a,c
	ret	z
	ld	a,(de)
	inc	de
	ld	(hl),a
	dec	bc
	inc	hl
	jr	Memcpy_copyLoop
