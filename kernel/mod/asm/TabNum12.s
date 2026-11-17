;; TabNum12: 00:0380 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_MOD0A

TabNum12::
_TabNum12::
	ldh	a,(#0xfb)
	or	a
	nop
	nop
	nop
	call	FarCallTrampoline
	.dw	_BrowserNav+6
	.dw	0x0c
	ret
