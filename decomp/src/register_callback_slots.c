/* Call_000_062e / 0634 / 063a / 0640 / 0646 @ 1.05e/1.04e $062e–$064b.
 *
 * Five contiguous register-ABI wrappers. Each sets HL to a WRAM callback
 * list base, then jp Jump_000_066c ($066c) which stores BC into the first
 * free slot. Lists are 16 bytes apart: $D6D3, $D6E3, $D6F3, $D703, $D713.
 *
 * Absolute jp target is the live kernel address of install_callback_slot;
 * byte-identical match needs that pin until verify grows callee fixing.
 */

void register_callback_slot_d6d3(void) __naked {
    __asm
	ld	hl, #0xd6d3
	jp	0x066c
    __endasm;
}

void register_callback_slot_d6e3(void) __naked {
    __asm
	ld	hl, #0xd6e3
	jp	0x066c
    __endasm;
}

void register_callback_slot_d6f3(void) __naked {
    __asm
	ld	hl, #0xd6f3
	jp	0x066c
    __endasm;
}

void register_callback_slot_d703(void) __naked {
    __asm
	ld	hl, #0xd703
	jp	0x066c
    __endasm;
}

void register_callback_slot_d713(void) __naked {
    __asm
	ld	hl, #0xd713
	jp	0x066c
    __endasm;
}
