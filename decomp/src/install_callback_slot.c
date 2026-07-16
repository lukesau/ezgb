/* Jump_000_066c @ 1.05e/1.04e $066c.
 *
 * Register ABI (not --sdcccall 0 stack): HL = uint16 slot list, BC = function
 * pointer. Walks the list for a free (0) slot and stores BC there.
 *
 * Semantic C (stack ABI; modern SDCC emits a different, larger shape):
 *   void install_callback_slot(unsigned int *list, unsigned int fn) {
 *       while (*list)
 *           list++;
 *       *list = fn;
 *   }
 *
 * Callers are the thin wrappers at $062e/$0634/$063a/$0640/$0646 (each loads
 * a different list base into HL then jp here). Stack-convention thunks
 * elsewhere load BC from the stack then call those wrappers.
 */

void install_callback_slot(void) __naked {
    __asm
00108$:
	ld	a, (hl+)
	or	(hl)
	jr	z, 00111$
	inc	hl
	jr	00108$
00111$:
	ld	(hl), b
	dec	hl
	ld	(hl), c
	ret
    __endasm;
}
