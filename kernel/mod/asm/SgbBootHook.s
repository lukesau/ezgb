;; SgbBootHook: 01:7f00 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

SgbBootHook::
_SgbBootHook::
	dec	e
	jr	nz,L7f0b$
	ld	a,#0x01
	ldh	(#0xf2),a
	ld	a,#0xc0
	ldh	(#0xf3),a
L7f0b$:
	jp	_cgb_init_and_lcd_on
