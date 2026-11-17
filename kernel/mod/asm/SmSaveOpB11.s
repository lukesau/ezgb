;; SmSaveOpB11: 0b:4000 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

SmSaveOpB11::
_SmSaveOpB11::
	ldhl	sp,#2
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	push	hl
	call	FarCallTrampoline
	.dw	_SaveOp
	.dw	0x01
	add	sp,#2
	ret
