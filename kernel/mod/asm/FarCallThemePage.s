;; FarCallThemePage: 04:5990 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

FarCallThemePage::
_FarCallThemePage::
	call	FarCallTrampoline
	.dw	_ThemePage
	.dw	0x0d
	ret
