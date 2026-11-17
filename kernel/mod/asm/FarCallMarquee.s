;; FarCallMarquee: 00:0410 in the patched 1.05e-0731 kernel, hand-assembled there

	.area	_MOD0A

FarCallMarquee::
_FarCallMarquee::
	call	FarCallTrampoline
	.dw	_Marquee
	.dw	0x02
	ret
