/* Call_000_062e / 0634 / 063a / 0640 / 0646 @ 1.05e/1.04e $062e–$064b.
 *
 * Five contiguous register-ABI wrappers. Each sets HL to a WRAM callback
 * list base, then jp install_callback_slot (Jump_000_066c) which stores BC
 * into the first free slot. Lists are 16 bytes apart:
 * $D6D3, $D6E3, $D6F3, $D703, $D713.
 *
 * Verify with the callee pinned to the kernel address:
 *   verify.py src/register_callback_slots.c 1.05e 0 062e \
 *       --pin install_callback_slot=066c
 *   # or: --pins tools/pins/1.05e.bank0
 */

extern void install_callback_slot(void);

void register_callback_slot_d6d3(void) __naked {
    __asm
	ld	hl, #0xd6d3
	jp	_install_callback_slot
    __endasm;
}

void register_callback_slot_d6e3(void) __naked {
    __asm
	ld	hl, #0xd6e3
	jp	_install_callback_slot
    __endasm;
}

void register_callback_slot_d6f3(void) __naked {
    __asm
	ld	hl, #0xd6f3
	jp	_install_callback_slot
    __endasm;
}

void register_callback_slot_d703(void) __naked {
    __asm
	ld	hl, #0xd703
	jp	_install_callback_slot
    __endasm;
}

void register_callback_slot_d713(void) __naked {
    __asm
	ld	hl, #0xd713
	jp	_install_callback_slot
    __endasm;
}
