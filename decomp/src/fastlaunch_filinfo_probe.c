/* Minimal FILINFO-layout probe: opendir("/"), set the FILINFO lfname pointer,
 * read the first several entries, and dump the raw FILINFO bytes + the head of
 * the long-name buffer to WRAM for inspection. Then loop forever so a debugger
 * breakpoint lands at a settled point.
 *
 * Purpose: confirm the classic FatFs _USE_LFN external-buffer layout derived
 * statically from FileBrowserEntry_memsetWireDirList (see memory
 * ezgb-filinfo-lfn-layout) against the live kernel, BEFORE rewriting the full
 * fastlaunch scan on top of it. Not part of the final feature.
 *
 * Scratch/dump WRAM (safe window $D780-$DA60, below the $E000 stack, above the
 * kernel's variables which top out ~$D73B):
 *   DUMP  $D700  canary $C0, then per read: [res][26 raw FILINFO][32 LFN head]
 *   DIRO  $D900  DIR object written by opendir
 *   FNO   $D940  FILINFO (26 bytes)
 *   LFN   $D960  long-name buffer (256 bytes), ends ~$DA60
 */

extern unsigned char FarCallOpendir_B5(unsigned char *dp, const unsigned char *path);
extern unsigned char FarCallReaddir_B5(unsigned char *dp, unsigned char *fno);

#define DIRO ((unsigned char *)0xD900)
#define FNO  ((unsigned char *)0xD940)
#define LFN  ((unsigned char *)0xD960)
#define DUMP ((unsigned char *)0xD700)

void fastlaunch_filinfo_probe(void) {
    unsigned char i, k, res;
    unsigned char root[2];
    unsigned char *d = DUMP;

    *d++ = 0xC0; /* canary: probe reached */

    /* FILINFO.lfname = LFN ; FILINFO.lfsize = 254 */
    FNO[22] = (unsigned char)((unsigned int)LFN & 0xFF);
    FNO[23] = (unsigned char)((unsigned int)LFN >> 8);
    FNO[24] = 254;
    FNO[25] = 0;

    root[0] = '/';
    root[1] = 0;

    res = FarCallOpendir_B5(DIRO, root);
    *d++ = res; /* opendir FRESULT (0 == FR_OK) */

    for (i = 0; i < 6; i++) {
        FNO[9] = 0; /* fname[0]; readdir sets 0 at end-of-dir */
        LFN[0] = 0; /* cleared so a leftover long name can't masquerade */
        res = FarCallReaddir_B5(DIRO, FNO);
        *d++ = res;
        for (k = 0; k < 26; k++) *d++ = FNO[k];
        for (k = 0; k < 32; k++) *d++ = LFN[k];
    }

    /* Sentinel in the gap $D864-$D8FF (below the DIR/FILINFO scratch at $D900,
     * above the dump area which ends ~$D863). Nothing but the boot WRAM clear
     * (value $00) ever writes here, so a value-conditional watch on $A5 fires
     * exactly when the probe finishes. */
    *((unsigned char *)0xD8FF) = 0xA5;

    for (;;) {
    }
}
