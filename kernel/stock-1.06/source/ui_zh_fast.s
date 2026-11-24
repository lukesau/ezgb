; ============================================================================
;  ui_zh_fast.s  -  zh build only: fast glyph writes straight into VRAM (bank 2)
;  ----------------------------------------------------------------------------
;  Bypasses the library's per-pixel plot_point (144 cross-calls per CJK glyph)
;  and ORs the 6x12 / 16x12 glyph bytes into both VRAM bit planes. With black
;  ink this is identical to plot_point (both set the two planes, BGP index 3),
;  but an order of magnitude faster. White glyphs use ui_zh.c's slow path.
;
;  Addressing copied from drawing.s (.plot / y_table), checked against the ROM:
;     byte address = ytab[y] + 2*(x & 0xF8); plane0 there, plane1 at +1.
;  Each pixel row of a GB tile is two adjacent bytes (low/high plane), so both
;  planes hold the same glyph byte and the pixel comes out black.
;
;  Interface: parameters live in WRAM globals filled by ui_zh.c, then a plain CALL.
;  This file sits in _CODE_2 with ui_zh.c: callable from bank 2 code only, the
;  symbols are not __banked, so there is no trampoline: 
;     zh_fa_x / zh_fa_y   glyph top-left pixel coordinates
;     zh_fa_off           ASCII: offset in ASC_DATA (char * 12)
;  CJK glyphs must already be copied into zh_gbuf by zh_fetch.
;
;  WR_OR waits like the library's WAIT_STAT (while STAT bit1 is set). With the
;  LCD off the mode bits read 0 and it passes at once, so both off-screen and
;  display-on drawing are safe (the library's .gmode writes the same way).
; ============================================================================

	.module	ui_zh_fast
	.area	_CODE_2

	.globl	_zh_fast_ascii
	.globl	_zh_fast_hz
	.globl	_zh_fa_x, _zh_fa_y, _zh_fa_off
	.globl	_zh_fa_sh, _zh_fa_row, _zh_fa_hz, _zh_fa_lc
	.globl	_ASC_DATA, _zh_gbuf

rSTAT		= 0xFF41

; ---- OR B into the two planes at HL / HL+1 (HL ends at start+1)
.macro	WR_OR_B ?lbl
lbl:	LDH	A,(rSTAT)
	AND	#0x02
	JR	NZ,lbl
	LD	A,(HL)
	OR	B
	LD	(HL+),A
	LD	A,(HL)
	OR	B
	LD	(HL),A
.endm

; ---- same with C ----
.macro	WR_OR_C ?lbl
lbl:	LDH	A,(rSTAT)
	AND	#0x02
	JR	NZ,lbl
	LD	A,(HL)
	OR	C
	LD	(HL+),A
	LD	A,(HL)
	OR	C
	LD	(HL),A
.endm

; ---- HL += 0x10 ----
.macro	HL_ADD_16 ?lbl
	LD	A,L
	ADD	#0x10
	LD	L,A
	JR	NC,lbl
	INC	H
lbl:
.endm

; ---- y -> VRAM row base (plane0). 144 entries, same as the library's y_table:
;      0x8100 + 0x140*(y/8) + 2*(y%8), one tile row per 8 pixel rows
_zh_ytab2::
	.word	0x8100,0x8102,0x8104,0x8106,0x8108,0x810A,0x810C,0x810E
	.word	0x8240,0x8242,0x8244,0x8246,0x8248,0x824A,0x824C,0x824E
	.word	0x8380,0x8382,0x8384,0x8386,0x8388,0x838A,0x838C,0x838E
	.word	0x84C0,0x84C2,0x84C4,0x84C6,0x84C8,0x84CA,0x84CC,0x84CE
	.word	0x8600,0x8602,0x8604,0x8606,0x8608,0x860A,0x860C,0x860E
	.word	0x8740,0x8742,0x8744,0x8746,0x8748,0x874A,0x874C,0x874E
	.word	0x8880,0x8882,0x8884,0x8886,0x8888,0x888A,0x888C,0x888E
	.word	0x89C0,0x89C2,0x89C4,0x89C6,0x89C8,0x89CA,0x89CC,0x89CE
	.word	0x8B00,0x8B02,0x8B04,0x8B06,0x8B08,0x8B0A,0x8B0C,0x8B0E
	.word	0x8C40,0x8C42,0x8C44,0x8C46,0x8C48,0x8C4A,0x8C4C,0x8C4E
	.word	0x8D80,0x8D82,0x8D84,0x8D86,0x8D88,0x8D8A,0x8D8C,0x8D8E
	.word	0x8EC0,0x8EC2,0x8EC4,0x8EC6,0x8EC8,0x8ECA,0x8ECC,0x8ECE
	.word	0x9000,0x9002,0x9004,0x9006,0x9008,0x900A,0x900C,0x900E
	.word	0x9140,0x9142,0x9144,0x9146,0x9148,0x914A,0x914C,0x914E
	.word	0x9280,0x9282,0x9284,0x9286,0x9288,0x928A,0x928C,0x928E
	.word	0x93C0,0x93C2,0x93C4,0x93C6,0x93C8,0x93CA,0x93CC,0x93CE
	.word	0x9500,0x9502,0x9504,0x9506,0x9508,0x950A,0x950C,0x950E
	.word	0x9640,0x9642,0x9644,0x9646,0x9648,0x964A,0x964C,0x964E

; ============================================================================
;  Fast full-row fill (width 0..159)
;  ----------------------------------------------------------------------------
;  The library's box(...,M_FILL) is per-pixel .line/.plot: a 160x144 clear costs
;  23,000 plot calls (mode dispatch, y_table lookup, bit table, two-plane RMW),
;  about 0.8s per page switch on hardware. Here both plane bytes are written
;  directly: 20 tiles per row, 16 bytes apart, plane0 then plane1
;  A row is 40 byte writes, more than 10x faster than per-pixel drawing.
;
;  Parameters in WRAM (filled by ui_zh.c):
;     zh_ff_y0 / zh_ff_y1   first/last pixel row (inclusive)
;     zh_ff_p0 / zh_ff_p1   bytes written to plane0 / plane1
;                           white = 0,0  black = 0xFF,0xFF  dkgrey = 0x00,0xFF
;  Full width only: every large fill in this project is full width.
;  The caller guarantees graphics mode (.gmode is triggered by the first box).
; ============================================================================

	.globl	_zh_fast_fill
	.globl	_zh_ff_y0, _zh_ff_y1, _zh_ff_p0, _zh_ff_p1

_zh_fast_fill::
	LD	A,(_zh_ff_p0)
	LD	D,A				; D = plane0 byte
	LD	A,(_zh_ff_p1)
	LD	E,A				; E = plane1 byte
	LD	A,(_zh_ff_y0)
	LD	C,A				; C = current row
ff_row:
	LD	B,#0x00
	LD	HL,#_zh_ytab2
	ADD	HL,BC				; ytab2 + y*2
	ADD	HL,BC
	LD	A,(HL+)
	LD	H,(HL)
	LD	L,A				; HL = tile 0 plane0 of this row
	LD	B,#0x14			; 20 tiles
ff_tile:
1$:	LDH	A,(rSTAT)			; like the library's WAIT_STAT: wait while in mode 2/3
	AND	#0x02
	JR	NZ,1$
	LD	(HL),D				; plane0
	INC	HL
	LD	(HL),E				; plane1
	LD	A,L				; HL += 15 -> next tile's plane0
	ADD	#0x0F
	LD	L,A
	JR	NC,2$
	INC	H
2$:
	DEC	B
	JR	NZ,ff_tile
	INC	C
	LD	A,(_zh_ff_y1)
	CP	C				; continue while y1 >= y
	JR	NC,ff_row
	RET

; ---- CJK: glyph already in zh_gbuf (24 bytes copied by zh_fetch) ----
_zh_fast_hz::
	LD	A,#0x01
	LD	(_zh_fa_hz),A
	LD	HL,#_zh_gbuf
	LD	D,H
	LD	E,L
	JR	zh_init

; ---- ASCII: glyph in ASC_DATA (same bank, direct), offset in zh_fa_off ----
_zh_fast_ascii::
	XOR	A
	LD	(_zh_fa_hz),A
	LD	A,(_zh_fa_off)
	LD	E,A
	LD	A,(_zh_fa_off+1)
	LD	D,A
	LD	HL,#_ASC_DATA
	ADD	HL,DE
	LD	D,H
	LD	E,L

zh_init:
	; sh = x & 7 (constant for the whole glyph)
	LD	A,(_zh_fa_x)
	AND	#0x07
	LD	(_zh_fa_sh),A
	; 12 rows (the body is too long for one JR: one row is a subroutine)
	LD	A,#0x0C
	LD	(_zh_fa_row),A
zh_loop:
	CALL	zh_one_row
	LD	HL,#_zh_fa_row
	DEC	(HL)
	JR	NZ,zh_loop
	RET

; ============================================================================
;  One row (CALL in, RET out): DE = left byte of this row's glyph data.
;  Left byte g covers pixels x..x+7:
;     part landing in leftbase     = g >> sh        (into B)
;     part spilling to leftbase+16 = g << (8-sh)    (into C, 0 when sh=0)
;  CJK right byte g' covers x+8..x+15:
;     part landing in leftbase+16  = g' >> sh       (same byte as the spill, in B)
;     part spilling to leftbase+32 = g' << (8-sh)   (C)
;  ASCII glyphs are 6 columns wide with 2 zero bits, so C is always 0 there.
; ============================================================================
zh_one_row:
	; HL = ytab[y] + 2*(x&0xF8) = leftbase (BC as index, DE untouched)
	LD	A,(_zh_fa_y)
	LD	C,A
	LD	B,#0x00
	LD	HL,#_zh_ytab2
	ADD	HL,BC
	ADD	HL,BC
	LD	A,(HL+)
	LD	H,(HL)
	LD	L,A
	LD	A,(_zh_fa_x)
	AND	#0xF8
	LD	C,A
	LD	B,#0x00
	ADD	HL,BC
	ADD	HL,BC
	PUSH	HL			; keep leftbase

	; ---- left byte -> (B, C)
	LD	A,(DE)
	LD	B,A
	LD	C,#0x00
	LD	A,(_zh_fa_sh)
	OR	A
	JR	Z,30$
31$:	SRL	B
	RR	C
	DEC	A
	JR	NZ,31$
30$:
	WR_OR_B				; write both planes at leftbase
	DEC	HL			; back to leftbase
	LD	A,C
	LD	(_zh_fa_lc),A		; stash the left spill

	; ---- right byte (CJK only) -> (B, C)
	LD	A,(_zh_fa_hz)
	OR	A
	JR	Z,32$
	INC	DE
	LD	A,(DE)
	LD	B,A
	LD	C,#0x00
	LD	A,(_zh_fa_sh)
	OR	A
	JR	Z,33$
34$:	SRL	B
	RR	C
	DEC	A
	JR	NZ,34$
33$:
	JR	35$
32$:	XOR	A			; ASCII: no right byte
	LD	B,A
	LD	C,A
35$:
	LD	A,(_zh_fa_lc)
	OR	B
	LD	B,A			; B = left spill | right main (same +16 byte)

	; ---- write leftbase+16 (B) and leftbase+32 (C)
	POP	HL			; leftbase
	LD	A,B
	OR	C
	JR	Z,38$			; pure ASCII, no spill: one byte per row
	HL_ADD_16
	WR_OR_B
	DEC	HL			; leftbase+16
	HL_ADD_16
	WR_OR_C			; OR 0 is harmless when C is 0
38$:
	; ---- advance: DE to next row's left byte, y+1
	INC	DE
	LD	HL,#_zh_fa_y
	INC	(HL)
	RET
