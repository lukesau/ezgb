;; The 12px glyph sets and their metrics (docs/font12.md), beside the
;; renderer in bank 10 (kernel/mod/src/draw12.c, layout12.c).
;; the Makefile packs them from the sheets in kernel/mod/font12
;; with kernel/tools/font12-pack.py: font12.txt, and font12_dv.txt as a
;; fixed 6 px set (--mono 6).

	.area	_CODE

Font12::
_Font12::
	.incbin	"font12.bin"

Font12Metrics::
_Font12Metrics::
	.incbin	"font12-metrics.bin"

Font12Dv::
_Font12Dv::
	.incbin	"font12_dv.bin"

Font12DvMetrics::
_Font12DvMetrics::
	.incbin	"font12_dv-metrics.bin"
