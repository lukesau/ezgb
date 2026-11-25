;; kernel/mod-1.06: the 12px glyph set and its metrics (docs/font12.md), in
;; the renderer's bank (font12.c). The makefile packs them from
;; kernel/mod/font12/font12.txt with kernel/tools/font12-pack.py.

        .area   _CODE_8

_Font12::
        .incbin "build/font12.bin"

_Font12Metrics::
        .incbin "build/font12-metrics.bin"

;; EZ Flash's 6x12 ASCII font as a second set (tools/ezf-pack.py, from
;; source/asc12x6.c): the SET tab's EZF
_Font12Ezf::
        .incbin "build/font12_ezf.bin"

_Font12EzfMetrics::
        .incbin "build/font12_ezf-metrics.bin"
