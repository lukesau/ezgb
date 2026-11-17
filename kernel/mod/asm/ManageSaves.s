;; ManageSaves: 04:6d11 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

ManageSaves::
_ManageSaves::
	call	FarCallTrampoline
	.dw	_ManageSavesImpl
	.dw	0x0b
	ret
