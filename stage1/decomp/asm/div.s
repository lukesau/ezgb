;; 8- and 16-bit signed and unsigned divide and modulo, FW4 00:279B-289A.
;; SDCC 2.9.0's device/lib/gbz80/div.s, the same entry points, up to the
;; unsigned 16-bit loop, which differs from every SDCC and GBDK version
;; tried.
;; Converted from the stock stage1 disassembly (stage1/fw4) to sdas syntax,
;; not from a published source: no library found has this code (README.md).
;; Labels keep the disassembly's names; the globals are the names the rest
;; of the program links against.

	.module	div
	.area	_CODE

__divschar_rrx_s::
Jump_000_279b:
	ld	hl,#0x03
	add	hl,sp
	ld	e,(hl)
	dec	hl
	ld	l,(hl)
	ld	c,l
	call	Call_000_281b
	ld	e,c
	ld	d,b
	ret
__modschar_rrx_s::
Jump_000_27a9:
	ld	hl,#0x03
	add	hl,sp
	ld	e,(hl)
	dec	hl
	ld	l,(hl)
	ld	c,l
	call	Call_000_281b
	ret
__divsint_rrx_s::
S16Div:
	ld	hl,#0x05
	add	hl,sp
	ld	d,(hl)
	dec	hl
	ld	e,(hl)
	dec	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	h,a
	ld	b,h
	ld	c,l
	call	S16DivMod
	ld	e,c
	ld	d,b
	ret
__modsint_rrx_s::
S16Mod:
	ld	hl,#0x05
	add	hl,sp
	ld	d,(hl)
	dec	hl
	ld	e,(hl)
	dec	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	h,a
	ld	b,h
	ld	c,l
	call	S16DivMod
	ret
__divuchar_rrx_s::
Jump_000_27db:
	ld	hl,#0x03
	add	hl,sp
	ld	e,(hl)
	dec	hl
	ld	l,(hl)
	ld	c,l
	call	Call_000_2855
	ld	e,c
	ld	d,b
	ret
__moduchar_rrx_s::
Jump_000_27e9:
	ld	hl,#0x03
	add	hl,sp
	ld	e,(hl)
	dec	hl
	ld	l,(hl)
	ld	c,l
	call	Call_000_2855
	ret
__divuint_rrx_s::
Jump_000_27f5:
	ld	hl,#0x05
	add	hl,sp
	ld	d,(hl)
	dec	hl
	ld	e,(hl)
	dec	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	h,a
	ld	b,h
	ld	c,l
	call	U16DivMod
	ld	e,c
	ld	d,b
	ret
__moduint_rrx_s::
Jump_000_2809:
	ld	hl,#0x05
	add	hl,sp
	ld	d,(hl)
	dec	hl
	ld	e,(hl)
	dec	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	h,a
	ld	b,h
	ld	c,l
	call	U16DivMod
	ret
Call_000_281b:
	ld	a,c
	rlca
	sbc	a,a
	ld	b,a
	ld	a,e
	rlca
	sbc	a,a
	ld	d,a
S16DivMod:
	ld	a,b
	push	af
	xor	a,d
	push	af
	bit	7,d
	jr	z,S16DivMod_absDividend
	sub	a,a
	sub	a,e
	ld	e,a
	sbc	a,a
	sub	a,d
	ld	d,a
S16DivMod_absDividend:
	bit	7,b
	jr	z,S16DivMod_u16Div
	sub	a,a
	sub	a,c
	ld	c,a
	sbc	a,a
	sub	a,b
	ld	b,a
S16DivMod_u16Div:
	call	U16DivMod
	ret	c
	pop	af
	and	a,#0x80
	jr	z,S16DivMod_restoreSigns
	sub	a,a
	sub	a,c
	ld	c,a
	sbc	a,a
	sub	a,b
	ld	b,a
S16DivMod_restoreSigns:
	pop	af
	and	a,#0x80
	ret	z
	sub	a,a
	sub	a,e
	ld	e,a
	sbc	a,a
	sub	a,d
	ld	d,a
	ret
Call_000_2855:
	ld	b,#0x00
	ld	d,b
U16DivMod:
	ld	a,e
	or	a,d
	jr	nz,jr_000_2863
	ld	bc,#0x00
	ld	d,b
	ld	e,c
	scf
	ret
jr_000_2863:
	ld	l,c
	ld	h,b
	ld	bc,#0x00
	or	a,a
	ld	a,#0x10
U16DivMod_shiftLoop:
	push	af
	rl	l
	rl	h
	rl	c
	rl	b
	push	bc
	ld	a,c
	sbc	a,e
	ld	c,a
	ld	a,b
	sbc	a,d
	ld	b,a
	ccf
	jr	c,jr_000_2881
	pop	bc
	jr	jr_000_2883
jr_000_2881:
	inc	sp
	inc	sp
jr_000_2883:
	jr	c,jr_000_288c
	pop	af
	dec	a
	or	a,a
	jr	nz,U16DivMod_shiftLoop
	jr	U16DivMod_finish
jr_000_288c:
	pop	af
	dec	a
	scf
	jr	nz,U16DivMod_shiftLoop
U16DivMod_finish:
	ld	d,b
	ld	e,c
	rl	l
	ld	c,l
	rl	h
	ld	b,h
	or	a,a
	ret
