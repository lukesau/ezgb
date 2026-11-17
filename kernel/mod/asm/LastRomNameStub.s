;; LastRomNameStub: 00:0368 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_MOD0A

LastRomNameStub::
_LastRomNameStub::
	call	FarCallTrampoline
	.dw	_LastRomName
	.dw	0x02
	ret
