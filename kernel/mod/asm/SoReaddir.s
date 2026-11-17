;; SoReaddir: 01:7646 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

SoReaddir::
_SoReaddir::
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
	.dw	Readdir_B5
	.dw	0x05
	add	sp,#4
	ret
