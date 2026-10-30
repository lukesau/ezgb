/* The custom theme's colors: COLORS=RRGGBB,RRGGBB in EZGB.CFG, the
 * background, then the ink (docs/dark-mode.md).
 *
 * Bank 5, injected at 05:7b50: bank 2 has no room left. ezcfg reaches it
 * through FarCallColors (02:4990, theme_pick.c), so the args sit past the
 * trampoline's three words and the stub's return address. The op first:
 *
 *   op 0  parse the value at p, len bytes: 12 hex digits, any other byte
 *         ('#', ',', spaces) skipped. All 12 set CUST_RGB, CUST_OK and
 *         CUST_RAMP; fewer change nothing.
 *   op 1  write the theme lines at p for ezcfg's cfg_save: THEME= unless
 *         the theme is light, COLORS= if a valid one was read; returns
 *         past them
 *
 * The middle shades are the background moved 3/16 and 9/16 of the way to
 * the ink, about where every built-in dark theme has them. Each is four
 * halving steps, LSB first: acc = (acc + (bit ? ink : bg)) / 2, from acc =
 * bg (bit 4 clear) or ink (set), so a weight byte is the blend in
 * sixteenths, and $1F is the ink itself. Channels keep their top 5 bits;
 * CUST_RGB keeps all 8, so a save writes back what was read.
 *
 * Asm: SDCC made 610 bytes of the C version.
 */

#include "types.h"
#include "vars.h"
#include "ezcfg.h"

u8 *colors(u16 pad_thunk, u16 pad_af, u16 pad_ret, u8 op, u8 *p, u8 len) __naked {
    (void)pad_thunk; (void)pad_af; (void)pad_ret; (void)op; (void)p; (void)len;
    __asm
	ldhl	sp, #8
	ld	a, (hl+)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	c, (hl)
	dec	a
	jr	z, 20$

	; op 0: up to len bytes at de, the hex digits into a 6-byte frame
	add	sp, #-6
	ldhl	sp, #0
	ld	b, #12
1$:
	ld	a, c
	or	a
	jr	z, 9$			; ran out: fewer than 12
	dec	c
	ld	a, (de)
	inc	de
	or	#0x20			; letters to lowercase, digits unchanged
	sub	#0x30
	cp	#10
	jr	c, 2$
	sub	#0x31			; a..f
	cp	#6
	jr	nc, 1$
	add	#10
2$:
	bit	0, b
	jr	nz, 3$
	swap	a			; even count left: the high nibble
	ld	(hl), a
	jr	4$
3$:
	or	(hl)
	ld	(hl+), a
4$:
	dec	b
	jr	nz, 1$
	ldhl	sp, #0
	ld	de, #0xdbe4		; CUST_RGB
	ld	b, #6
5$:
	ld	a, (hl+)
	ld	(de), a
	inc	de
	dec	b
	jr	nz, 5$
	ld	a, #1
	ld	(#0xdbea), a		; CUST_OK
	add	sp, #6

	; CUST_RAMP: per weight, b then g then r, shifted into de
	ld	hl, #0xdb58		; CUST_RAMP
	push	hl
	ld	hl, #40$
6$:
	ld	c, (hl)
	inc	hl
	push	hl
	ld	hl, #0xdbe6		; CUST_RGB + 2: blue
	call	50$
	ld	e, a
	ld	d, #0
	dec	l
	call	60$
	dec	l
	call	60$
	pop	hl
	pop	bc
	ld	a, e
	ld	(bc), a
	inc	bc
	ld	a, d
	ld	(bc), a
	inc	bc
	push	bc
	ld	a, c
	cp	#0x60			; CUST_RAMP + 8
	jr	nz, 6$
	pop	bc
	ret
9$:
	add	sp, #6
	ret

	; op 1: THEME=n (unless light) and COLORS=RRGGBB,RRGGBB (if read)
	; at de, CR LF each; returns past them
20$:
	ld	a, (#0xdbf7)		; THEME
	or	a
	jr	z, 22$
	cp	#7			; THEME_COUNT
	jr	nc, 22$
	ld	hl, #42$
	ld	b, #6
	call	28$
	ld	a, (#0xdbf7)
	add	#0x30
	ld	(de), a
	inc	de
	call	29$
22$:
	ld	a, (#0xdbea)		; CUST_OK
	or	a
	ret	z
	ld	hl, #41$
	ld	b, #7
	call	28$
	ld	hl, #0xdbe4		; CUST_RGB
	ld	b, #6
23$:
	ld	a, b
	cp	#3
	jr	nz, 24$
	ld	a, #0x2c		; ','
	ld	(de), a
	inc	de
24$:
	ld	a, (hl)
	swap	a
	call	25$
	ld	a, (hl+)
	call	25$
	dec	b
	jr	nz, 23$
29$:					; CR LF
	ld	a, #0x0d
	ld	(de), a
	inc	de
	ld	a, #0x0a
	ld	(de), a
	inc	de
	ret
25$:					; low nibble of a to (de)+, upper case
	and	#0x0f
	cp	#10
	jr	c, 26$
	add	#7
26$:
	add	#0x30
	ld	(de), a
	inc	de
	ret
28$:					; b bytes from hl to (de)+
	ld	a, (hl+)
	ld	(de), a
	inc	de
	dec	b
	jr	nz, 28$
	ret

40$:	.db	0x00, 0x03, 0x09, 0x1f	; bg, 3/16, 9/16, ink
41$:	.ascii	"COLORS="
42$:	.ascii	"THEME="

	; one channel, hl = its CUST_RGB byte, c = the weight; keeps bc, de, hl
50$:
	push	bc
	ld	a, (hl)
	bit	4, c
	jr	z, 51$
	inc	l
	inc	l
	inc	l
	ld	a, (hl)
	dec	l
	dec	l
	dec	l
51$:
	ld	b, #4
52$:
	srl	c
	jr	nc, 53$
	inc	l			; inc and dec keep the carry
	inc	l
	inc	l
	add	(hl)
	dec	l
	dec	l
	dec	l
	jr	54$
53$:
	add	(hl)
54$:
	rra
	dec	b
	jr	nz, 52$
	pop	bc
	rrca
	rrca
	rrca
	and	#0x1f
	ret

	; the next channel: de = de << 5 | it
60$:
	call	50$
	ld	b, #5
61$:
	sla	e
	rl	d
	dec	b
	jr	nz, 61$
	or	e
	ld	e, a
	ret
    __endasm;
}
