;; StarToggleFar: 04:59a0 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

StarToggleFar::
_StarToggleFar::
	call	FarCallTrampoline
	.dw	_StarToggleSync
	.dw	0x0b
	ret
