/* Call_000_2765 @ 1.05e $2765.
 * Callers (e.g. Call_000_08b7) push two bytes then call; those WRAM cells are
 * read/advanced by Call_000_20f4 as roughly screen cursor col/row (wrap $13/$11).
 * Purpose still lightly inferred from that, not renamed to cursor_* yet. */

void store_d732_d733(unsigned char a, unsigned char b) {
    *((unsigned char *)0xd732) = a;
    *((unsigned char *)0xd733) = b;
}
