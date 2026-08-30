/* Boot-time entry point for fast launch, hooked over the browser's
 * "call BrowserSortAllStub" at 00:102f (which is itself the sorted-browser
 * feature's replacement for the stock DirList call). By that point the SD card
 * is mounted, so the scan can read the root.
 *
 * Runs the scan first; on a hit it stages the full path in $c4a4 and launches
 * (never returns). Otherwise it performs the normal browser enumeration/sort it
 * displaced and returns, so a card with no fast-launch trigger boots to the
 * file browser exactly as before.
 */
extern void FarCallScan(void);                         /* -> bank 2 fastlaunch_scan (writes $c4a4) */
extern void fastlaunch_do_launch(void);                /* reuses LastRomRelaunch; no return */
extern void BrowserSortAllStub(void);                  /* 00:03d4, the displaced call */

void fastlaunch_boot(void) {
    unsigned char *c4a4 = (unsigned char *)0xC4A4;

    FarCallScan();                /* scans root, writes the launch path to $c4a4 */
    if (c4a4[0] != 0) {
        fastlaunch_do_launch();   /* boots the ROM; never returns */
    }

    BrowserSortAllStub();         /* no trigger: normal browser; ret -> $1032 */
}
