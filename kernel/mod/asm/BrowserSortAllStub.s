;; BrowserSortAllStub: 00:03d4 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_MOD0A

BrowserSortAllStub::
_BrowserSortAllStub::
	call	FarCallTrampoline
	.dw	_browser_sort_all
	.dw	0x08
	ret
