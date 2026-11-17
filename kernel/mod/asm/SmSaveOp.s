;; SmSaveOp: 04:65f0 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

SmSaveOp::
_SmSaveOp::
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
