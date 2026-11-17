;; SoMatch: 01:7d50 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

SoMatch::
_SoMatch::
	ldhl	sp,#4
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	push	hl
	ldhl	sp,#4
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	push	hl
	call	FarCallTrampoline
	.dw	_SaveNameMatch
	.dw	0x04
	add	sp,#4
	ret
