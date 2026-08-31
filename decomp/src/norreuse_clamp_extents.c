/*
 * NorReuseClampExtents — NOR-reuse experiment v2 (partial copy).
 *
 * Called from NorReuseBootShim_B4 (04:5940) on the Start->A relaunch path,
 * after LaunchSetup has staged the 512-byte ROM-load command table at $c0a0
 * and before it is handed to RomLoad_CopyCmdWindowPoll_B4 ($448f).
 *
 * The table (daid/ezflashjr doc/Protocol.md) is 128 little-endian u32s:
 *   [0]      = 0
 *   [1..]    = (start sector, sector count) extent pairs; count $FFFFFFFF
 *              means "contiguous to end of file"; (0,0) terminates
 *   [$7C]    = ROM size in bytes   (left untouched -> FPGA mapping intact)
 *   [$7D/7E] = meta                (left untouched)
 *
 * We clamp the extent list to the first CLAMP_SECTORS sectors: the factory
 * stage1 bootstrap re-loads ezgb.dat (160KB) into the same rom area on every
 * power-on, so only that prefix is known-clobbered; the tail rides on whatever
 * the cart retained. 512 sectors = 256KB, a 96KB safety margin over the
 * kernel. Files smaller than the clamp hit the (0,0) terminator first and are
 * copied in full.
 */

#define CMD ((volatile unsigned long *)0xc0a0)
#define CLAMP_SECTORS 512UL

void NorReuseClampExtents(void)
{
    unsigned long remaining = CLAMP_SECTORS;
    unsigned char i;

    for (i = 1; i + 1 < 0x7c; i += 2) {
        unsigned long lba = CMD[i];
        unsigned long cnt = CMD[i + 1];
        if (lba == 0 && cnt == 0) {
            return;             /* file shorter than the clamp: copy all */
        }
        if (cnt >= remaining) { /* $FFFFFFFF tail marker lands here too */
            CMD[i + 1] = remaining;
            if (i + 3 < 0x7c) {
                CMD[i + 2] = 0; /* terminate the list */
                CMD[i + 3] = 0;
            }
            return;
        }
        remaining -= cnt;
    }
}
