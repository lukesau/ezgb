;; The VBL and LCD handlers of GBDK's drawing.s, without the rest of it
;; (.vbl puts the background tiles at $8000, .lcd at $8800 from line $48),
;; and its two colour variables, which font.s uses. FW4 00:2931-2948.
;; Converted from the stock stage1 disassembly (stage1/fw4) to sdas syntax,
;; not from a published source: no library found has this code (README.md).
;; Labels keep the disassembly's names; the globals are the names the rest
;; of the program links against.

	.module	drawing_isr
	.area	_BSS
.fg_colour::
	.ds	1
.bg_colour::
	.ds	1

	.area	_CODE

.vbl::
VBlankCb_Bg8000:
	ldh	a,(0x40)
	or	a,#0x10
	ldh	(0x40),a
	ld	a,#0x48
	ldh	(0x45),a
	ret
.lcd::
LycCb_Bg8800:
	ldh	a,(0x41)
	bit	1,a
	jr	nz,LycCb_Bg8800
	ldh	a,(0x40)
	and	a,#0xef
	ldh	(0x40),a
	ret
