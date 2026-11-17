;; FarCallSetPage: 02:43ac in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

FarCallSetPage::
_FarCallSetPage::
	ldhl	sp,#2
	ld	a,(hl)
	push	af
	inc	sp
	call	FarCallTrampoline
	.dw	SetFpgaPageAlt_B4
	.dw	0x04
	add	sp,#1
	ret
