/* Call_000_0688 @ 1.05e $0688 (1.04e same code, flag at $D6A7).
 *
 * If LCD is on, clear $D6CE under di/ei, halt until the VBlank path sets it
 * nonzero (see handler near $0677), then clear it again. No-op if LCD off.
 *
 * Semantic C:
 *   void wait_vblank_flag(void) {
 *       if (!(LCDC & 0x80))
 *           return;
 *       di(); D6CE = 0; ei();
 *       do { halt(); } while (!D6CE);
 *       D6CE = 0;
 *   }
 *
 * Byte match uses __naked: modern SDCC widens the LCDC bit test and the
 * final store vs the kernel's add-a / xor-a abs store shape.
 */

void wait_vblank_flag(void) __naked {
    __asm
	ldh	a, (#0xff40)
	add	a, a
	ret	nc

	xor	a
	di
	ld	(#0xd6ce), a
	ei

00100$:
	halt
	nop
	ld	a, (#0xd6ce)
	or	a
	jr	z, 00100$

	xor	a
	ld	(#0xd6ce), a
	ret
    __endasm;
}
