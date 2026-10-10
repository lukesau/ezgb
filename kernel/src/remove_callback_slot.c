/* Call_000_064c @ 1.05e/1.04e $064c.
 *
 * Register ABI: HL = uint16 slot list (0-terminated), BC = function pointer
 * to remove. Finds BC, clears that slot, then slides the tail down so the
 * list stays packed. Sits between the register wrappers ($062e) and the
 * installer Jump_000_066c ($066c).
 *
 * Semantic C (not byte-identical; ROM uses HL/BC and a compacting slide):
 *   void remove_callback_slot(unsigned int *list, unsigned int fn) {
 *       while (*list) {
 *           if (*list == fn) {
 *               do {
 *                   list[0] = list[1];
 *                   list++;
 *               } while (list[-1]);
 *               return;
 *           }
 *           list++;
 *       }
 *   }
 */

void remove_callback_slot(void) __naked {
    __asm
00100$:
	ld	a, (hl+)
	ld	e, a
	ld	d, (hl)
	or	d
	ret	z

	ld	a, e
	cp	c
	jr	nz, 00100$

	ld	a, d
	cp	b
	jr	nz, 00100$

	xor	a
	ld	(hl-), a
	ld	(hl), a
	inc	a
	ld	d, h
	ld	e, l
	dec	de
	inc	hl

00110$:
	ld	a, (hl+)
	ld	(de), a
	ld	b, a
	inc	de
	ld	a, (hl+)
	ld	(de), a
	inc	de
	or	b
	ret	z

	jr	00110$
    __endasm;
}
