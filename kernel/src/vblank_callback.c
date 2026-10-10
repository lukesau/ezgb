/* Anonymous handler @ 1.05e/1.04e $0677 (registered via Call_000_062e).
 *
 * VBlank callback: bump 16-bit frame counter at $D6D1, run HRAM OAM DMA
 * stub at $FF80, then set wait flag $D6CE for Call_000_0688.
 *
 * 1.04e WRAM: counter $D6AA, flag $D6A7 (same code shape).
 */

void vblank_callback(void) __naked {
    __asm
	ld	hl, #0xd6d1
	inc	(hl)
	jr	nz, 00100$
	inc	hl
	inc	(hl)
00100$:
	call	#0xff80
	ld	a, #0x01
	ld	(#0xd6ce), a
	ret
    __endasm;
}
