;; SgbVblTail: 00:02c3 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_MOD0A

SgbVblTail::
_SgbVblTail::
	push	af
	ldh	a,(#0xf2)
	and	a
	jr	z,L02da$
	di
	ld	a,(wRomBank)
	push	af
	ld	a,#0x04
	ld	(0x2000),a
	call	SgbVblStep
	pop	af
	ld	(0x2000),a
L02da$:
	pop	af
	reti
