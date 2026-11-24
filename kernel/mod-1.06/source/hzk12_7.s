; ------------------------------------------------------------------
;  hzk12_7.s  -  GB2312 16x12 font, ROM bank 17
;  ------------------------------------------------------------------
;  The glyph stream is packed contiguously over the GB2312 code space
;  (0xA1A0 upwards).  ui_zh.c locates a glyph as
;      addr = 0x4000 + index*24          (index = GB code - bank base)
;  so this bank MUST start exactly at the window base with no code in
;  front of it: the file therefore contains nothing but the blob.
;  hzk12_7.bin was extracted from the released 544KB image (bank 17),
;  which is identical across all builds.
; ------------------------------------------------------------------
	.module hzk12_7
	.area _CODE_17
	.globl _hzk12_7
_hzk12_7::
	.incbin "source/font/hzk12_7.bin"
