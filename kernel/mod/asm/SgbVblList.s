;; SgbVblList: 00:04e1 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_MOD0A

SgbVblList::
_SgbVblList::
	push	hl
	ld	hl,#wVBlankCallbacks
	jp	RunCallbackList
