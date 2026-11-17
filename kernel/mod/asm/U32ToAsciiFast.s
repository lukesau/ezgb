;; U32ToAsciiFast: 04:7c00 in the patched 1.05e-0731 kernel, hand-assembled there
;; The mod's U32ToAscii: a 16-bit decimal here, anything else stock's C.

	.area	_CODE

_U32ToAscii::
	ldhl	sp,#8
	ld	a,(hl)
	cp	#0x0a
	jp	nz,L7cbb$
	ldhl	sp,#4
	ld	a,(hl+)
	or	(hl)
	jp	nz,L7cbb$
	ldhl	sp,#6
	ld	a,(hl+)
	ld	e,a
	ld	d,(hl)
	ldhl	sp,#2
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	ld	c,#0x00
	ld	b,#0x30
L7c1d$:
	ld	a,l
	sub	#0x10
	ld	l,a
	ld	a,h
	sbc	a,#0x27
	ld	h,a
	jr	c,L7c2a$
	inc	b
	jr	L7c1d$
L7c2a$:
	ld	a,l
	add	a,#0x10
	ld	l,a
	ld	a,h
	adc	a,#0x27
	ld	h,a
	ld	a,b
	cp	#0x30
	jr	nz,L7c3b$
	bit	0,c
	jr	z,L7c3f$
L7c3b$:
	ld	(de),a
	inc	de
	ld	c,#0x01
L7c3f$:
	ld	b,#0x30
L7c41$:
	ld	a,l
	sub	#0xe8
	ld	l,a
	ld	a,h
	sbc	a,#0x03
	ld	h,a
	jr	c,L7c4e$
	inc	b
	jr	L7c41$
L7c4e$:
	ld	a,l
	add	a,#0xe8
	ld	l,a
	ld	a,h
	adc	a,#0x03
	ld	h,a
	ld	a,b
	cp	#0x30
	jr	nz,L7c5f$
	bit	0,c
	jr	z,L7c63$
L7c5f$:
	ld	(de),a
	inc	de
	ld	c,#0x01
L7c63$:
	ld	b,#0x30
L7c65$:
	ld	a,l
	sub	#0x64
	ld	l,a
	ld	a,h
	sbc	a,#0x00
	ld	h,a
	jr	c,L7c72$
	inc	b
	jr	L7c65$
L7c72$:
	ld	a,l
	add	a,#0x64
	ld	l,a
	ld	a,h
	adc	a,#0x00
	ld	h,a
	ld	a,b
	cp	#0x30
	jr	nz,L7c83$
	bit	0,c
	jr	z,L7c87$
L7c83$:
	ld	(de),a
	inc	de
	ld	c,#0x01
L7c87$:
	ld	b,#0x30
L7c89$:
	ld	a,l
	sub	#0x0a
	ld	l,a
	ld	a,h
	sbc	a,#0x00
	ld	h,a
	jr	c,L7c96$
	inc	b
	jr	L7c89$
L7c96$:
	ld	a,l
	add	a,#0x0a
	ld	l,a
	ld	a,h
	adc	a,#0x00
	ld	h,a
	ld	a,b
	cp	#0x30
	jr	nz,L7ca7$
	bit	0,c
	jr	z,L7cab$
L7ca7$:
	ld	(de),a
	inc	de
	ld	c,#0x01
L7cab$:
	bit	0,c
	jr	nz,L7cb3$
	ld	a,#0x30
	ld	(de),a
	inc	de
L7cb3$:
	ld	a,l
	add	a,#0x30
	ld	(de),a
	inc	de
	xor	a
	ld	(de),a
	ret
L7cbb$:
	jp	_U32ToAsciiSlow		; the C (kernel/stock/src/bank4.c)
