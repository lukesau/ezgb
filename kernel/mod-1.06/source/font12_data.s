;; kernel/mod-1.06: the 12px glyph set and its metrics (docs/font12.md), in
;; the renderer's bank (font12.c). The makefile packs them from
;; kernel/mod/font12/font12.txt with kernel/tools/font12-pack.py.

        .area   _CODE_8

_Font12::
        .incbin "build/font12.bin"

_Font12Metrics::
        .incbin "build/font12-metrics.bin"
