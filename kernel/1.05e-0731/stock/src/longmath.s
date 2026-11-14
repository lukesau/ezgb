	;; Long, char and int math for bank 0 (stock $29E6-$2EEA, in five pieces).
	;; SDCC 2.9.0's stubs.s jumps here. The source this came from is not
	;; known: no SDCC (2.7.0 to 4.x), GBDK (2.0.17, 2.96a, 4.0) or GBDK-2020
	;; library has it. This file is a reconstruction from the stock kernel's
	;; bytes, with the names SDCC's runtime gives the entry points. It also
	;; holds memset, memcpy and two unreferenced float helpers.
	;;
	;; Stock links the pieces between other library objects, so each is its
	;; own area here (_MATH1 to _MATH5) and the Makefile places them. The
	;; helpers take a byte count in B; most work on 4-byte little-endian values.
	;;
	;; kernel.sym's S32DivImpl/U32DivImpl/S32ModImpl/U32ModImpl have division
	;; and modulo the wrong way round: $29E6 and $2A77 return the remainder.

	.globl	__mullong, __modslong, __modulong, __divslong, __divulong
	.globl	__mulschar_rrx_s, __muluchar_rrx_s, __mulint_rrx_s
	.globl	_memset, _memcpy
	.globl	_errno

	.area	_MATH1
;; long __modslong(long a, long b): a % b. A zero a returns 0; a zero b sets
;; errno to 33 (EDOM in SDCC's errno.h) and returns 0x7FFFFFFF. Divides
;; the magnitudes; the remainder is negated when the signs differ.
__modslong::
	lda	sp,-9(sp)
	ld	b,#0x04
	lda	hl,11(sp)
	call	.lm_iszero
	jr	nz,.modslong_checkDivisor

	xor	a,a
	ld	e,a
	ld	d,a
	ld	l,a
	ld	h,a
	jp	.modslong_epilogueRet

.modslong_checkDivisor:
	lda	hl,15(sp)
	call	.lm_iszero
	jr	nz,.modslong_clearSign

	ld	a,#0x21
	ld	(_errno),a
	ld	a,#0xff
	ld	e,a
	ld	d,a
	ld	l,a
	ld	h,#0x7f
	jp	.modslong_epilogueRet

.modslong_clearSign:
	lda	hl,0(sp)
	xor	a,a
	ld	(hl),a
	lda	hl,18(sp)
	ld	a,(hl)
	bit	7,a
	jr	z,.modslong_checkDividendSign

	lda	hl,15(sp)
	call	.lm_neg
	lda	hl,0(sp)
	ld	(hl),#0x01

.modslong_checkDividendSign:
	lda	hl,14(sp)
	ld	a,(hl)
	bit	7,a
	jr	z,.modslong_divide

	lda	hl,11(sp)
	call	.lm_neg
	lda	hl,0(sp)
	ld	a,#0x01
	xor	a,(hl)
	ld	(hl),a

.modslong_divide:
	lda	hl,15(sp)
	push	hl
	lda	hl,13(sp)
	push	hl
	lda	hl,9(sp)
	push	hl
	lda	hl,7(sp)
	push	hl
	call	.lm_divmod
	lda	sp,8(sp)
	lda	hl,0(sp)
	rr	(hl)
	jr	nc,.modslong_loadRem

	ld	b,#0x04
	lda	hl,1(sp)
	call	.lm_neg

.modslong_loadRem:
	lda	hl,1(sp)
	ld	a,(hl+)
	ld	e,a
	ld	a,(hl+)
	ld	d,a
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a

.modslong_epilogueRet:
	lda	sp,9(sp)
	ret

	.area	_MATH2
;; unsigned long __modulong(unsigned long a, unsigned long b): a % b, with
;; __modslong's zero checks
__modulong::
	lda	sp,-8(sp)
	ld	b,#0x04
	lda	hl,10(sp)
	call	.lm_iszero
	jr	nz,.modulong_checkDivisor

	xor	a,a
	ld	e,a
	ld	d,a
	ld	l,a
	ld	h,a
	jp	.modulong_epilogueRet

.modulong_checkDivisor:
	lda	hl,14(sp)
	call	.lm_iszero
	jr	nz,.modulong_runEngine

	ld	a,#0x21
	ld	(_errno),a
	ld	a,#0xff
	ld	e,a
	ld	d,a
	ld	l,a
	ld	h,#0x7f
	jp	.modulong_epilogueRet

.modulong_runEngine:
	lda	hl,14(sp)
	push	hl
	lda	hl,12(sp)
	push	hl
	lda	hl,8(sp)
	push	hl
	lda	hl,6(sp)
	push	hl
	call	.lm_divmod
	lda	sp,8(sp)
	lda	hl,0(sp)
	ld	a,(hl+)
	ld	e,a
	ld	a,(hl+)
	ld	d,a
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a

.modulong_epilogueRet:
	lda	sp,8(sp)
	ret

;; Z if the B bytes at HL are all zero
.lm_iszero:
	xor	a,a
	ld	c,b

.lm_iszero_scanLoop:
	cp	a,(hl)
	ret	nz

	inc	hl
	dec	c
	jr	nz,.lm_iszero_scanLoop

	ret

;; Unreferenced. Moves the exponent of the float whose top byte is at HL
;; into that byte and sets the mantissa's implicit bit.
.fs_unpack:
	push	hl
	ld	a,(hl-)
	ld	c,a
	ld	a,(hl)
	set	7,(hl)
	rla
	ld	a,c
	rla
	pop	hl
	ld	(hl),a
	ret

;; HL = top byte of a 4-byte value: turns 0x80000000 into 0
.fs_clearnegzero:
	xor	a,a
	bit	7,(hl)
	jr	z,.fs_clearnegzero_matchMsb

	ld	a,#0x80

.fs_clearnegzero_matchMsb:
	cp	a,(hl)
	ret	nz

	xor	a,a
	dec	hl
	cp	a,(hl)
	ret	nz

	dec	hl
	cp	a,(hl)
	ret	nz

	dec	hl
	cp	a,(hl)
	ret	nz

	inc	hl
	inc	hl
	inc	hl
	res	7,(hl)
	ret

;; compares the 3 bytes below DE and HL, top first; NZ at the first difference
.lm_cmp3:
	ld	c,#0x03

.lm_cmp3_cmpLoop:
	ld	a,(de)
	sub	a,(hl)
	ret	nz

	dec	de
	dec	hl
	dec	c
	ret	z

	jr	.lm_cmp3_cmpLoop

;; Unreferenced. Signed compare of the 4-byte values at sp+4 and sp+8
;; (after the return address), with -0 equal to 0.
.fs_cmp:
	lda	hl,7(sp)
	call	.fs_clearnegzero
	lda	hl,11(sp)
	call	.fs_clearnegzero
	lda	hl,7(sp)
	bit	7,(hl)
	jr	z,.fs_cmp_apos

	lda	hl,11(sp)
	bit	7,(hl)
	jr	z,.fs_cmp_retALess

	lda	hl,11(sp)
	ld	d,h
	ld	e,l
	lda	hl,7(sp)
	jr	.lm_cmp3

.fs_cmp_retALess:
	xor	a,a
	ccf
	ret

.fs_cmp_apos:
	lda	hl,11(sp)
	bit	7,(hl)
	jr	z,.fs_cmp_bpos

	xor	a,a
	dec	a
	ret

.fs_cmp_bpos:
	lda	hl,7(sp)
	ld	d,h
	ld	e,l
	lda	hl,11(sp)
	jr	.lm_cmp3

;; long __divslong(long a, long b): a / b, with __modslong's zero checks
__divslong::
	lda	sp,-9(sp)
	ld	b,#0x04
	lda	hl,11(sp)
	call	.lm_iszero
	jr	nz,.divslong_checkDivisor

	xor	a,a
	ld	e,a
	ld	d,a
	ld	l,a
	ld	h,a
	jp	.divslong_epilogueRet

.divslong_checkDivisor:
	lda	hl,15(sp)
	call	.lm_iszero
	jr	nz,.divslong_clearSign

	ld	a,#0x21
	ld	(_errno),a
	ld	a,#0xff
	ld	e,a
	ld	d,a
	ld	l,a
	ld	h,#0x7f
	jp	.divslong_epilogueRet

.divslong_clearSign:
	lda	hl,0(sp)
	xor	a,a
	ld	(hl),a
	lda	hl,18(sp)
	ld	a,(hl)
	bit	7,a
	jr	z,.divslong_checkDividendSign

	lda	hl,15(sp)
	call	.lm_neg
	lda	hl,0(sp)
	ld	(hl),#0x01

.divslong_checkDividendSign:
	lda	hl,14(sp)
	ld	a,(hl)
	bit	7,a
	jr	z,.divslong_divide

	lda	hl,11(sp)
	call	.lm_neg
	lda	hl,0(sp)
	ld	a,#0x01
	xor	a,(hl)
	ld	(hl),a

.divslong_divide:
	lda	hl,15(sp)
	push	hl
	lda	hl,13(sp)
	push	hl
	lda	hl,9(sp)
	push	hl
	lda	hl,7(sp)
	push	hl
	call	.lm_divmod
	lda	sp,8(sp)
	lda	hl,0(sp)
	rr	(hl)
	jr	nc,.divslong_loadQuot

	ld	b,#0x04
	xor	a,a
	lda	hl,5(sp)
	call	.lm_neg

.divslong_loadQuot:
	lda	hl,5(sp)
	ld	a,(hl+)
	ld	e,a
	ld	a,(hl+)
	ld	d,a
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a

.divslong_epilogueRet:
	lda	sp,9(sp)
	ret

;; char and int multiplies for stubs.s's _rrf_s entries: operands on the
;; stack, product in DE
__mulschar_rrx_s::
	lda	hl,2(sp)
	ld	a,(hl+)
	ld	c,a
	ld	e,(hl)
	ld	a,c
	rla
	sbc	a,a
	ld	b,a
	ld	a,e
	rla
	sbc	a,a
	ld	d,a
	jr	.mulint_initHl0

__muluchar_rrx_s::
	lda	hl,2(sp)
	ld	a,(hl+)
	ld	c,a
	ld	e,(hl)

;; DE = C * E
.mul8:
	xor	a,a
	ld	h,a
	ld	l,a
	ld	d,a

.mul8_rrC:
	xor	a,a
	rr	c
	jr	nc,.mul8_shiftE

	add	hl,de

.mul8_shiftE:
	sla	e
	jr	z,.mul8_finish

	rl	d
	jr	.mul8_rrC

.mul8_finish:
	rl	d
	jr	nz,.mul8_rrC

	ld	e,l
	ld	d,h
	ret

__mulint_rrx_s::
	lda	hl,2(sp)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)

.mulint_initHl0:
	ld	hl,#0x00

.mulint_loop:
	sra	b
	jr	nz,.mulint_rrCPath

	rr	c
	jr	nc,.mulint_afterAddLo

	add	hl,de

.mulint_afterAddLo:
	jr	z,.mulint_retDe

	jr	.mulint_slaE

.mulint_rrCPath:
	rr	c
	jr	nc,.mulint_slaE

	add	hl,de

.mulint_slaE:
	sla	e
	jr	z,.mulint_rlDOnly

	rl	d
	jr	.mulint_loop

.mulint_rlDOnly:
	rl	d
	jr	nz,.mulint_loop

.mulint_retDe:
	ld	e,l
	ld	d,h
	ret

;; unsigned long __divulong(unsigned long a, unsigned long b): a / b
__divulong::
	lda	sp,-8(sp)
	ld	b,#0x04
	lda	hl,10(sp)
	call	.lm_iszero
	jr	nz,.divulong_checkDivisor

	xor	a,a
	ld	e,a
	ld	d,a
	ld	l,a
	ld	h,a
	jp	.divulong_epilogueRet

.divulong_checkDivisor:
	lda	hl,14(sp)
	call	.lm_iszero
	jr	nz,.divulong_runEngine

	ld	a,#0x21
	ld	(_errno),a
	ld	a,#0xff
	ld	e,a
	ld	d,a
	ld	l,a
	ld	h,#0x7f
	jp	.divulong_epilogueRet

.divulong_runEngine:
	lda	hl,14(sp)
	push	hl
	lda	hl,12(sp)
	push	hl
	lda	hl,8(sp)
	push	hl
	lda	hl,6(sp)
	push	hl
	call	.lm_divmod
	lda	sp,8(sp)
	lda	hl,4(sp)
	ld	a,(hl+)
	ld	e,a
	ld	a,(hl+)
	ld	d,a
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a

.divulong_epilogueRet:
	lda	sp,8(sp)
	ret

	.area	_MATH3
;; void *memset(void *s, int c, size_t n); does not return s
_memset::
	lda	hl,5(sp)
	ld	a,(hl+)
	ld	c,a
	ld	b,(hl)
	lda	hl,4(sp)
	ld	d,(hl)
	lda	hl,2(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a

.memset_fillLoop:
	ld	a,b
	or	a,c
	ret	z

	dec	bc
	ld	(hl),d
	inc	hl
	jr	.memset_fillLoop

;; void *memcpy(void *d, void *s, size_t n); does not return s
_memcpy::
	lda	hl,6(sp)
	ld	a,(hl+)
	ld	c,a
	ld	b,(hl)
	lda	hl,4(sp)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	lda	hl,2(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a

.memcpy_copyLoop:
	ld	a,b
	or	a,c
	ret	z

	ld	a,(de)
	inc	de
	ld	(hl),a
	dec	bc
	inc	hl
	jr	.memcpy_copyLoop

	.area	_MATH4
;; negates the B-byte value at HL (carry must be clear)
.lm_neg:
	ld	c,b
	xor	a,a
	ld	d,a

.lm_neg_sbcLoop:
	ld	a,d
	sbc	a,(hl)
	ld	(hl+),a
	dec	c
	jr	nz,.lm_neg_sbcLoop

	ret

	.area	_MATH5
;; zeroes B bytes at HL
.lm_zero:
	ld	c,b
	xor	a,a

.lm_zero_fillLoop:
	ld	(hl+),a
	dec	c
	jr	nz,.lm_zero_fillLoop

	ret

;; long __mullong(long a, long b)
__mullong::
	lda	sp,-4(sp)
	lda	hl,10(sp)
	push	hl
	lda	hl,8(sp)
	push	hl
	lda	hl,4(sp)
	push	hl
	ld	b,#0x04
	call	.lm_mul
	lda	sp,6(sp)
	lda	hl,0(sp)
	ld	a,(hl+)
	ld	e,a
	ld	a,(hl+)
	ld	d,a
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	lda	sp,4(sp)
	ret

	ret

;; lm_divmod(rem, quot, a, b), all B-byte pointers on the stack: shift-subtract
;; division of a by b, one bit per step (a is shifted out as it goes)
.lm_divmod:
	ld	a,b
	sla	a
	sla	a
	sla	a
	ld	c,a
	push	bc
	lda	hl,6(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	call	.lm_zero
	lda	hl,4(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	call	.lm_zero

.lm_divmod_bitLoop:
	lda	hl,8(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	xor	a,a
	call	.lm_rol
	push	af
	lda	hl,6(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	pop	af
	push	hl
	call	.lm_rol
	pop	de
	lda	hl,10(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	push	de
	push	hl
	call	.lm_cmpsub
	pop	hl
	pop	de
	jr	c,.lm_divmod_rolQuot

	call	.lm_sub

.lm_divmod_rolQuot:
	ccf
	push	af
	lda	hl,8(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	pop	af
	call	.lm_rol
	pop	bc
	dec	c
	ret	z

	push	bc
	jr	.lm_divmod_bitLoop

;; DE[] -= HL[], B bytes, with the carry in
.lm_sub:
	ld	c,b

.lm_sub_sbcLoop:
	ld	a,(de)
	sbc	a,(hl)
	ld	(de),a
	inc	hl
	inc	de
	dec	c
	jr	nz,.lm_sub_sbcLoop

	ret

;; fills B bytes at HL with A (unreferenced)
.lm_fill:
	ld	c,b

.lm_fill_fillLoop:
	ld	(hl+),a
	dec	c
	jr	nz,.lm_fill_fillLoop

	ret

;; lm_mul(prod, a, b), pointers on the stack, B-byte operands: byte by byte
;; schoolbook multiply with .mul8
.lm_mul:
	lda	sp,-6(sp)
	lda	hl,12(sp)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	lda	hl,2(sp)
	ld	(hl),e
	inc	hl
	ld	(hl),d
	lda	hl,8(sp)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	lda	hl,0(sp)
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ld	h,d
	ld	l,e
	call	.lm_zero
	lda	hl,4(sp)
	ld	(hl),b

.lm_mul_outerSetup:
	lda	hl,4(sp)
	ld	a,(hl)
	lda	hl,5(sp)
	ld	(hl),a

.lm_mul_innerDigit:
	lda	hl,12(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	ld	c,(hl)
	lda	hl,10(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	ld	e,(hl)
	call	.mul8
	lda	hl,5(sp)
	ld	c,(hl)
	lda	hl,8(sp)
	ld	a,(hl+)
	ld	h,(hl)
	ld	l,a
	ld	a,(hl)
	add	a,e
	ld	(hl+),a
	dec	c
	jr	z,.lm_mul_nextOuter

	ld	a,(hl)
	adc	a,d
	ld	(hl+),a
	call	.lm_carry
	lda	hl,5(sp)
	dec	(hl)
	jr	z,.lm_mul_nextOuter

	lda	hl,12(sp)
	call	.lm_incw
	lda	hl,8(sp)
	call	.lm_incw
	jr	.lm_mul_innerDigit

.lm_mul_nextOuter:
	lda	hl,4(sp)
	dec	(hl)
	jr	z,.lm_mul_epilogueRet

	lda	hl,0(sp)
	call	.lm_incw
	lda	hl,10(sp)
	call	.lm_incw
	push	bc
	ld	b,#0x02
	lda	hl,2(sp)
	ld	d,h
	ld	e,l
	lda	hl,10(sp)
	call	.lm_copy
	lda	hl,4(sp)
	ld	d,h
	ld	e,l
	lda	hl,14(sp)
	call	.lm_copy
	pop	bc
	jp	.lm_mul_outerSetup

.lm_mul_epilogueRet:
	lda	sp,6(sp)
	ret

;; adds the carry into the C-1 bytes at HL
.lm_carry:
	dec	c
	ret	z

	ld	a,#0x00
	adc	a,(hl)
	ld	(hl+),a
	jr	.lm_carry

;; increments the word at HL
.lm_incw:
	inc	(hl)
	ret	nz

	inc	hl
	inc	(hl)
	ret

;; copies B bytes from DE to HL
.lm_copy:
	ld	c,b

.lm_copy_copyLoop:
	ld	a,(de)
	inc	de
	ld	(hl+),a
	dec	c
	jr	nz,.lm_copy_copyLoop

	ret

;; carry from DE[] - HL[] over B bytes, nothing stored
.lm_cmpsub:
	ld	c,b
	xor	a,a

.lm_cmpsub_sbcLoop:
	ld	a,(de)
	sbc	a,(hl)
	inc	hl
	inc	de
	dec	c
	jr	nz,.lm_cmpsub_sbcLoop

	ret

;; rotates the B-byte value at HL left through the carry
.lm_rol:
	ld	c,b

.lm_rol_rlLoop:
	rl	(hl)
	inc	hl
	dec	c
	jr	nz,.lm_rol_rlLoop

	ret

