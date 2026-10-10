/* Anonymous handler @ 1.05e/1.04e $06c0 (registered via Call_000_0640).
 *
 * Serial (IO) interrupt callback. State machine on $D6CD:
 *   2: latch rSB into $D6CC, go to state 0
 *   1: if rSB == $55 go to 0, else go to 4; then restart SC transfer
 *   else: just ensure SC bit 7 is set (transfer requested)
 *
 * 1.04e WRAM: state $D6A6, latch $D6A5.
 */

#define rSB 0xff01
#define rSC 0xff02

void serial_callback(void) __naked {
    __asm
	ld	a, (#0xd6cd)
	cp	#0x02
	jr	nz, 00110$

	ldh	a, (#rSB)
	ld	(#0xd6cc), a
	ld	a, #0x00
	jr	00130$

00110$:
	cp	#0x01
	jr	nz, 00140$

	ldh	a, (#rSB)
	cp	#0x55
	jr	z, 00130$

	ld	a, #0x04
	jr	00131$

00130$:
	ld	a, #0x00

00131$:
	ld	(#0xd6cd), a
	xor	a
	ldh	(#rSC), a
	ld	a, #0x66
	ldh	(#rSB), a

00140$:
	ld	a, #0x80
	ldh	(#rSC), a
	ret
    __endasm;
}
