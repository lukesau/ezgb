;; StarQueryFar: 04:5998 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

StarQueryFar::
_StarQueryFar::
	call	FarCallTrampoline
	.dw	_StarQuery
	.dw	0x05
	ret
