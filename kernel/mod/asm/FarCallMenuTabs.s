;; FarCallMenuTabs: 04:5f70 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

FarCallMenuTabs::
_FarCallMenuTabs::
	ldhl	sp,#2
	ld	a,(hl)
	push	af
	inc	sp
	call	FarCallTrampoline
	.dw	_DrawMenuTabs
	.dw	0x08
	inc	sp
	ret
