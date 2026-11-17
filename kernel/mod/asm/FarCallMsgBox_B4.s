;; FarCallMsgBox_B4: 04:59b0 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

FarCallMsgBox_B4::
_FarCallMsgBox_B4::
	call	FarCallTrampoline
	.dw	_MsgBox
	.dw	0x0b
	ret
