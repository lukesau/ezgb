;; LastRomTickStub: 00:0370 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_MOD0A

LastRomTickStub::
_LastRomTickStub::
	ld	hl,#0x0000
	push	hl
	call	LastRomNameStub
	pop	hl
	jp	ReadJoypad
