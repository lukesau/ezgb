;; SgbLaunchHook: 04:7d00 in the patched 1.05e-0731 kernel, hand-assembled there
;; SgbBootEntry: from SgbStub at boot. SgbVblStep: from the VBlank tail. SgbLaunchPrep: before a launch (bank4.c).

	.area	_CODE

SgbLaunchHook::
_SgbLaunchHook::
SgbBootEntry::
	call	L7d26$
	ld	e,#0x00
	jr	z,L7d22$
	xor	a
L7d11$:
	push	af
	call	L7d88$
	ld	d,#0x04
	call	L7de8$
	pop	af
	inc	a
	cp	#0x06
	jr	nz,L7d11$
	ld	e,#0x01
L7d22$:
	pop	af
	jp	KernelEntry
L7d26$:
	ld	a,#0x11
	ld	(0x4000),a
	ld	b,#0x03
	call	L7d6f$
	ld	hl,#0xa412
	ld	a,(hl+)
	cp	#0x53
	jr	nz,L7d45$
	ld	a,(hl)
	cp	#0x42
	jr	z,L7d41$
	cp	#0x4e
	jr	nz,L7d45$
L7d41$:
	ld	c,#0x00
	jr	L7d4f$
L7d45$:
	ld	hl,#0xa400
	ld	a,(hl+)
	ld	c,a
	ld	a,(hl+)
	ld	d,a
	ld	a,(hl+)
	ld	e,a
	ld	h,(hl)
L7d4f$:
	xor	a
	ld	(0x4000),a
	ld	b,a
	call	L7d6f$
	ld	a,c
	cp	#0x53
	jr	nz,L7d6d$
	ld	a,d
	cp	#0x47
	jr	nz,L7d6d$
	ld	a,e
	cp	#0x01
	jr	nz,L7d6d$
	ld	a,h
	cp	#0xfe
	jr	nz,L7d6d$
	or	a
	ret
L7d6d$:
	xor	a
	ret
L7d6f$:
	ld	a,#0xe1
	ld	(0x7f00),a
	ld	a,#0xe2
	ld	(0x7f10),a
	ld	a,#0xe3
	ld	(0x7f20),a
	ld	a,b
	ld	(0x7fc0),a
	ld	a,#0xe4
	ld	(0x7ff0),a
	ret
L7d88$:
	push	af
	ld	c,a
	add	a,a
	add	a,a
	add	a,a
	sub	c
	add	a,a
	add	a,#0x04
	ld	l,a
	ld	h,#0x01
	push	hl
	ld	c,#0x0e
	ld	e,#0x00
L7d99$:
	call	L7dca$
	add	a,e
	ld	e,a
	dec	c
	jr	nz,L7d99$
	pop	hl
	pop	af
	add	a,a
	add	a,#0xf1
	ld	d,a
	xor	a
	ldh	(#0x00),a
	ld	a,#0x30
	ldh	(#0x00),a
	call	L7dd4$
	ld	d,e
	call	L7dd4$
	ld	c,#0x0e
L7db7$:
	call	L7dca$
	ld	d,a
	call	L7dd4$
	dec	c
	jr	nz,L7db7$
	ld	a,#0x20
	ldh	(#0x00),a
	ld	a,#0x30
	ldh	(#0x00),a
	ret
L7dca$:
	ld	a,l
	cp	#0x50
	ld	a,#0x00
	jr	nc,L7dd2$
	ld	a,(hl)
L7dd2$:
	inc	hl
	ret
L7dd4$:
	ld	b,#0x08
L7dd6$:
	ld	a,#0x10
	rr	d
	jr	c,L7dde$
	ld	a,#0x20
L7dde$:
	ldh	(#0x00),a
	ld	a,#0x30
	ldh	(#0x00),a
	dec	b
	jr	nz,L7dd6$
	ret
L7de8$:
	ld	bc,#0x09cc
L7deb$:
	dec	bc
	ld	a,b
	or	c
	jr	nz,L7deb$
	dec	d
	jr	nz,L7de8$
	ret
SgbVblStep::
	push	bc
	push	de
	push	hl
	ldh	a,(#0xf4)
	and	a
	jr	z,L7dff$
	dec	a
	ldh	(#0xf4),a
L7dff$:
	ld	hl,#0xfff3
	dec	(hl)
	call	z,L7e0a$
	pop	hl
	pop	de
	pop	bc
	ret
L7e0a$:
	ldh	a,(#0xf2)
	cp	#0x13
	jr	c,L7e14$
	xor	a
	ldh	(#0xf2),a
	ret
L7e14$:
	dec	a
L7e15$:
	cp	#0x06
	jr	c,L7e1d$
	sub	#0x06
	jr	L7e15$
L7e1d$:
	call	L7d88$
	ld	a,#0x04
	ldh	(#0xf4),a
	ld	c,a
	ldh	a,(#0xf2)
	inc	a
	ldh	(#0xf2),a
	cp	#0x07
	jr	nz,L7e30$
	ld	c,#0x44
L7e30$:
	cp	#0x0d
	jr	nz,L7e36$
	ld	c,#0x34
L7e36$:
	ld	a,c
	ldh	(#0xf3),a
	ret
L7e3a$:
SgbLaunchPrep::
_SgbLaunchPrep::
	call	DiNest
L7e3d$:
	ldh	a,(#0xf2)
	and	a
	jr	z,L7e4d$
	ldh	a,(#0xf3)
	ld	d,a
	call	L7de8$
	call	L7e0a$
	jr	L7e3d$
L7e4d$:
	ldh	(#0xf4),a
	jp	EiNest
