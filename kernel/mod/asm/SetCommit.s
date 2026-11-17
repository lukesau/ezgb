;; SetCommit: 04:5fc0 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

SetCommit::
_SetCommit::
	ld	a,(0xdafd)
	or	a
	ret	z
	xor	a
	ld	(0xdafd),a
	ld	a,#0x01
	ld	(0xdbfc),a
	call	FarCallEzCfg
	call	FarCallPlaySync_B4
	xor	a
	push	af
	inc	sp
	call	SetFpgaPage_B4
	inc	sp
	ret
