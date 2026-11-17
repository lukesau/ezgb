;; DrawNameWithIcon: 00:3ec8 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_MOD0B

DrawNameWithIcon::
_DrawNameWithIcon::
	call	FarCallTrampoline
	.dw	_DrawNameWithIconImpl
	.dw	0x02
	ret
