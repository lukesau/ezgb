;; FlPickCommitFar: 04:5976 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

FlPickCommitFar::
_FlPickCommitFar::
	ld	a,#0x03
	push	af
	inc	sp
	ld	hl,#0x0000
	push	hl
	call	FlCfgJump
	add	sp,#3
	ret
