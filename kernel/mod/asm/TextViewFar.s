;; TextViewFar: 04:59a8 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

TextViewFar::
_TextViewFar::
	call	FarCallTrampoline
	.dw	_TextView
	.dw	0x0e
	ret
