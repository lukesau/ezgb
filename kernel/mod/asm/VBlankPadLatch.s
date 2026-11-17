;; VBlankPadLatch: 00:05cf in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_MOD0B

VBlankPadLatch::
_VBlankPadLatch::
	ldh	a,(#0x40)
	or	#0x10
	ldh	(#0x40),a
	ld	a,#0x48
	ldh	(#0x45),a
	push	bc
	call	ReadJoypadRaw
	ld	b,a
	ldh	a,(#0xfc)
	cpl
	and	b
	ld	c,a
	ld	a,b
	ldh	(#0xfc),a
	ldh	a,(#0xfd)
	or	c
	ldh	(#0xfd),a
	ldh	a,(#0xfa)
	inc	a
	ldh	(#0xfa),a
	pop	bc
	ret
