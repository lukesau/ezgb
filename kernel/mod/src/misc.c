/* Functions whose real purpose isn't confirmed yet, named after observed
 * behavior only. Rename once the calling context is understood. */

/* Call_000_1a77 in both 1.04e and 1.05e (unchanged, shifted address).
 * Called from bank_003, bank_007, bank_009, purpose not yet determined. */
unsigned char return_zero(void) {
    return 0;
}
