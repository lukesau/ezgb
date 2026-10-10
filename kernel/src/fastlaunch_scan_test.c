/* Temporary: call fastlaunch_scan() and dump its result for live inspection,
 * then loop. Not part of the final feature.
 *
 * fastlaunch_scan uses $D780-$DA70 as scratch, so keep the result buffer and
 * sentinel clear of that window:
 *   $DB00       $22 marker (wrapper reached this point)
 *   $DB01..     result path, NUL-terminated (empty == "nothing found")
 *   $DBFF       $A5 sentinel, written last (watch trigger; boot clear writes
 *               $00 here twice, so the 3rd write to $DBFF is this one) */
extern void fastlaunch_scan(unsigned char *result_path);

void fastlaunch_scan_test(void) {
    unsigned char *out = (unsigned char *)0xDB00;
    out[0] = 0x22;
    fastlaunch_scan(out + 1);
    *((unsigned char *)0xDBFF) = 0xA5;
    for (;;) {
    }
}
