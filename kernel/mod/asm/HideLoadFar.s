;; HideLoadFar: 08:7b80 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

HideLoadFar::
_HideLoadFar::
	call	FarCallTrampoline
	.dw	_HideLoad
	.dw	0x0e
	ret
