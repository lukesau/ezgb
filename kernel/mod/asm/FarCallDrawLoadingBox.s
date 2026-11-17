;; FarCallDrawLoadingBox: 00:0483 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_MOD0A

FarCallDrawLoadingBox::
_FarCallDrawLoadingBox::
	call	FarCallTrampoline
	.dw	DrawLoadingBox
	.dw	0x08
	ret
