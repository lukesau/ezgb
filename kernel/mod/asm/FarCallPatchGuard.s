;; FarCallPatchGuard: 02:43c0 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_CODE

FarCallPatchGuard::
_FarCallPatchGuard::
	call	FarCallTrampoline
	.dw	_patch_guard
	.dw	0x01
	ret
