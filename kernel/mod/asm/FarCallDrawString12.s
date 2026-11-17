;; FarCallDrawString12: 00:05c0 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_MOD0B

FarCallDrawString12::
_FarCallDrawString12::
	call	FarCallTrampoline
	.dw	_DrawString12
	.dw	0x02
	ret
