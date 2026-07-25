/* Diagnostic only, not part of the final feature: confirm FarCallOpendir_B5/
 * FarCallReaddir_B5 actually work against a live FatFs mount, and dump raw
 * DIR/FILINFO bytes so the real struct layout can be read off a live trace
 * instead of assumed from tools/omega-de-kernel's ff.h (which may not match
 * this kernel's exact FF_USE_LFN/FF_MAX_LFN build config).
 *
 * Writes results to WRAM starting at $d700, then halts so it's all still
 * there to `examine` in the debugger:
 *   $d700        : $11 marker (probe reached this point)
 *   $d701        : opendir result (FatFs FRESULT, 0 = FR_OK)
 *   $d708        : readdir #1 result
 *   $d709..$d76c : first 100 bytes of the fno buffer, raw
 *   $d770        : readdir #2 result
 *   $d771..$d7d4 : first 100 bytes of the fno buffer, raw (2nd entry)
 */
extern unsigned char FarCallOpendir_B5(unsigned char *dp, const char *path);
extern unsigned char FarCallReaddir_B5(unsigned char *dp, unsigned char *fno);

void fastlaunch_probe(void) {
    unsigned char *out = (unsigned char *)0xd700;
    unsigned char dp[48];
    unsigned char fno[128];
    unsigned char res, i;

    for (i = 0; i < 0xd0; i++) {
        out[i] = 0xEE; /* sentinel so "not written" is obvious in the dump */
    }
    out[0] = 0x11;

    res = FarCallOpendir_B5(dp, "/");
    out[1] = res;

    res = FarCallReaddir_B5(dp, fno);
    out[8] = res;
    for (i = 0; i < 100; i++) {
        out[9 + i] = fno[i];
    }

    res = FarCallReaddir_B5(dp, fno);
    out[0x70] = res;
    for (i = 0; i < 100; i++) {
        out[0x71 + i] = fno[i];
    }

    for (;;) {
    }
}
