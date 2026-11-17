;; SoOpendir: 01:7630 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

SoOpendir::
_SoOpendir::
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
	.dw	Opendir_B5
	.dw	0x05
	add	sp,#4
	ret
