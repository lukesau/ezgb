;; FillRect: 02:6f40 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

FillRect::
_FillRect::
	ld	a,(wDrawOp)
	or	a
	jr	z,L6f65$
L6f46$:
	ld	a,(wDrawX0)
	ld	b,a
	ld	a,(wDrawX1)
	ld	d,a
	ld	a,(wDrawY0)
	ld	c,a
	ld	e,a
	call	DrawLine
	ld	a,(wDrawY1)
	ld	b,a
	ld	a,(wDrawY0)
	cp	b
	ret	z
	inc	a
	ld	(wDrawY0),a
	jr	L6f46$
L6f65$:
	ld	a,(wDrawColor)
	ld	b,a
	xor	a
	bit	0,b
	jr	z,L6f6f$
	cpl
L6f6f$:
	ld	(0xdbf3),a
	xor	a
	bit	1,b
	jr	z,L6f78$
	cpl
L6f78$:
	ld	(0xdbf4),a
	ld	a,(wDrawX0)
	and	#0x07
	ld	b,a
	ld	a,#0xff
	inc	b
	jr	L6f88$
L6f86$:
	srl	a
L6f88$:
	dec	b
	jr	nz,L6f86$
	ld	(0xdbf0),a
	ld	a,(wDrawX1)
	and	#0x07
	cpl
	add	a,#0x08
	ld	b,a
	ld	a,#0xff
	inc	b
	jr	L6f9d$
L6f9c$:
	add	a,a
L6f9d$:
	dec	b
	jr	nz,L6f9c$
	ld	(0xdbf1),a
	ld	a,(wDrawX0)
	srl	a
	srl	a
	srl	a
	ld	b,a
	ld	a,(wDrawX1)
	srl	a
	srl	a
	srl	a
	sub	b
	jr	nz,L6fcb$
	ld	a,(0xdbf1)
	ld	b,a
	ld	a,(0xdbf0)
	and	b
	ld	(0xdbf0),a
	ld	a,#0xff
	ld	(0xdbf2),a
	jr	L6fcf$
L6fcb$:
	dec	a
	ld	(0xdbf2),a
L6fcf$:
	ld	a,(wDrawY0)
	ld	e,a
	ld	d,#0x00
	ld	hl,#GfxRowTable
	add	hl,de
	add	hl,de
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	ld	a,(wDrawX0)
	and	#0xf8
	ld	e,a
	add	hl,de
	add	hl,de
	ld	a,(0xdbf0)
	call	L70a6$
	ld	a,(0xdbf2)
	cp	#0xff
	jp	z,L7096$
	or	a
	jp	z,L7090$
	ld	(0xdbf5),a
	ld	a,(0xdbf3)
	ld	d,a
	ld	a,(0xdbf4)
	ld	e,a
	ld	bc,#0x000f
	ldh	a,(#0x40)
	bit	7,a
	jr	nz,L7017$
	ld	a,(0xdbf5)
L700e$:
	ld	(hl),d
	inc	hl
	ld	(hl),e
	add	hl,bc
	dec	a
	jr	nz,L700e$
	jr	L7090$
L7017$:
	ld	a,(0xdbf5)
	cp	#0x05
	jr	c,L7077$
	di
	ldh	a,(#0x41)
	and	#0x03
	cp	#0x01
	jr	nz,L7031$
	ldh	a,(#0x44)
	cp	#0x90
	jr	c,L7031$
	cp	#0x98
	jr	c,L7056$
L7031$:
	ldh	a,(#0x44)
	cp	#0x8f
	jr	c,L7048$
	ei
L7038$:
	ldh	a,(#0x44)
	cp	#0x8f
	jr	c,L7017$
	cp	#0x91
	jr	c,L7038$
	cp	#0x97
	jr	c,L7017$
	jr	L7038$
L7048$:
	ldh	a,(#0x41)
	and	#0x03
	cp	#0x03
	jr	nz,L7048$
L7050$:
	ldh	a,(#0x41)
	and	#0x03
	jr	nz,L7050$
L7056$:
	ld	(hl),d
	inc	hl
	ld	(hl),e
	add	hl,bc
	ld	(hl),d
	inc	hl
	ld	(hl),e
	add	hl,bc
	ld	(hl),d
	inc	hl
	ld	(hl),e
	add	hl,bc
	ld	(hl),d
	inc	hl
	ld	(hl),e
	add	hl,bc
	ld	(hl),d
	inc	hl
	ld	(hl),e
	add	hl,bc
	ei
	ld	a,(0xdbf5)
	sub	#0x05
	ld	(0xdbf5),a
	jr	nz,L7017$
	jr	L7090$
L7077$:
	or	a
	jr	z,L7090$
	di
L707b$:
	ldh	a,(#0x41)
	bit	1,a
	jr	nz,L707b$
	ld	(hl),d
	inc	hl
	ld	a,e
	ei
	ld	(hl),a
	add	hl,bc
	ld	a,(0xdbf5)
	dec	a
	ld	(0xdbf5),a
	jr	L7077$
L7090$:
	ld	a,(0xdbf1)
	call	L70a6$
L7096$:
	ld	a,(wDrawY1)
	ld	b,a
	ld	a,(wDrawY0)
	cp	b
	ret	z
	inc	a
	ld	(wDrawY0),a
	jp	L6fcf$
L70a6$:
	ld	b,a
	cpl
	ld	c,a
	ld	a,(0xdbf3)
	and	b
	ld	d,a
	ld	a,(0xdbf4)
	and	b
	ld	e,a
	di
L70b4$:
	ldh	a,(#0x41)
	bit	1,a
	jr	nz,L70b4$
	ld	a,(hl)
	and	c
	or	d
	ld	(hl+),a
	ld	a,(hl)
	and	c
	or	e
	ei
	ld	(hl),a
	ld	a,l
	add	a,#0x0f
	ld	l,a
	ret	nc
	inc	h
	ret
