;; FarCallPlaySync_B4: 04:7792 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

FarCallPlaySync_B4::
_FarCallPlaySync_B4::
	call	FarCallTrampoline
	.dw	_PlaySync
	.dw	0x0b
	ret
