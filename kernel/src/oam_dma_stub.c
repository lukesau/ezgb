/* OAM DMA template @ 1.05e/1.04e $06b6 (10 bytes).
 *
 * Copied to HRAM $FF80 at boot; VBlank callback calls it. Starts DMA from
 * $C000, then spins $28 iterations (standard GB DMA wait).
 */

void oam_dma_stub(void) __naked {
    __asm
	ld	a, #0xc0
	ldh	(#0xff46), a
	ld	a, #0x28
00100$:
	dec	a
	jr	nz, 00100$
	ret
    __endasm;
}
