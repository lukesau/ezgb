;; PadWait: 00:0502 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_MOD0A

PadWait::
_PadWait::
	call	WaitVBlankFlag
	jp	ReadJoypad
