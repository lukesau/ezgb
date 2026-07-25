/* Temporary: call fastlaunch_scan() and dump its result to WRAM for live
 * inspection, then halt. Not part of the final feature.
 *   $d700       : $22 marker (test reached this point)
 *   $d701..     : result path, NUL-terminated (empty = "nothing found") */
extern void fastlaunch_scan(unsigned char *result_path);

void fastlaunch_scan_test(void) {
    unsigned char *out = (unsigned char *)0xd700;
    out[0] = 0x22;
    fastlaunch_scan(out + 1);
    for (;;) {
    }
}
