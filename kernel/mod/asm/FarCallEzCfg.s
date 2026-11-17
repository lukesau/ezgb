;; FarCallEzCfg: 04:5f00 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

FarCallEzCfg::
_FarCallEzCfg::
	call	FarCallTrampoline
	.dw	_ezcfg
	.dw	0x02
	ret
