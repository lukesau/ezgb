;; FarCallPlayLoad: 02:78b0 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

FarCallPlayLoad::
_FarCallPlayLoad::
	call	FarCallTrampoline
	.dw	_PlayLoad
	.dw	0x0b
	ret
