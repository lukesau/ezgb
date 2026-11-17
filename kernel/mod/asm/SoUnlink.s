;; SoUnlink: 01:765c in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

SoUnlink::
_SoUnlink::
	ldhl	sp,#2
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	push	hl
	call	FarCallTrampoline
	.dw	_FsUnlink
	.dw	0x09
	add	sp,#2
	ret
