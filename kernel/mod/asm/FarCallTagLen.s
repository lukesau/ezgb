;; FarCallTagLen: 00:0408 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_MOD0A

FarCallTagLen::
_FarCallTagLen::
	call	FarCallTrampoline
	.dw	_TagLen
	.dw	0x05
	ret
