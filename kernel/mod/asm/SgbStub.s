;; SgbStub: 00:0020 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_MOD0A

SgbStub::
_SgbStub::
	push	af
	ld	a,#0x04
	ld	(0x2000),a
	jp	SgbBootEntry
