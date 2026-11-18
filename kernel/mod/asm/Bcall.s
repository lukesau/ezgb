;; ___sdcc_bcall_ehl: the mod's C calls a __banked function through this
;; (SDCC 4: e = the bank, hl = the function). It leaves the stack as stock's
;; FarCallTrampoline does, two words between the return address and the
;; arguments, so either compiler's __banked function can be called from
;; either's C. The bank variable is written before the register, so the
;; VBlank tail, which puts back the bank the variable names, cannot leave
;; another one mapped.
	.area	_MOD0A
___sdcc_bcall_ehl::
	ld	a,(wRomBank)
	push	af
	ld	a,e
	ld	(wRomBank),a
	ld	(0x2000),a
	call	1$
	pop	bc
	ld	a,b
	ld	(wRomBank),a
	ld	(0x2000),a
	ret
1$:
	jp	(hl)
