/* Temporary: call fastlaunch_scan_debug() and dump its result to WRAM.
 * Not part of the final feature.
 *   $d700..     : trace log written by fastlaunch_scan_debug itself
 *                 (starts with a $C0 canary as its very first write)
 *   $da20       : $33 marker (test wrapper reached this point)
 *   $da21..     : result path, NUL-terminated
 * ($d780-$da1b is fastlaunch_scan_debug's own WRAM scratch — see its header
 * comment — so this must not overlap that range.) */
extern void fastlaunch_scan_debug(unsigned char *result_path);

void fastlaunch_scan_debug_test(void) {
    unsigned char *out = (unsigned char *)0xda20;
    out[0] = 0x33;
    fastlaunch_scan_debug(out + 1);
    for (;;) {
    }
}
