/* Pre-paint boot hook for fast launch, hooked over the browser's
 * "call BrowserSortAllStub" at 00:102f (itself the sorted-browser feature's
 * replacement for the stock DirList call). This runs after the SD card is
 * mounted but BEFORE FileBrowserEntry_redraw ($1071) paints the list, so a
 * fast-launch card goes straight to Loading without the browser flashing.
 *
 * One-shot via the $DBFF flag (cleared at boot): the scan runs only on the
 * first FileBrowserEntry - later entries (directory navigation) skip it and
 * just do the sort, so browsing stays fast and never re-triggers a launch. The
 * sort (BrowserSortAllStub) runs on every entry either way, so a no-trigger
 * card browses exactly as before.
 *
 * Alternative to the post-paint hook in fastlaunch_hook.c (00:110B). Only one
 * of the two should wire the launch at a time.
 */
extern void FarCallScan(void);                /* -> bank 2 fastlaunch_scan (writes $c4a4) */
extern void fastlaunch_do_launch(void);       /* reuses LastRomRelaunch; no return */
extern void BrowserSortAllStub(void);         /* 00:03d4, the displaced call (sort/enum) */
extern unsigned char ReadJoypad(void);        /* 00:3a4a - post-swap key byte in E; B = $20 */

void fastlaunch_boot(void) {
    unsigned char *c4a4 = (unsigned char *)0xC4A4;
    unsigned char *flag = (unsigned char *)0xDBFF;

    BrowserSortAllStub();             /* enumerate/sort FIRST (the launch needs its state) */

    if (*flag == 0) {
        *flag = 1;
        if ((ReadJoypad() & 0x20) == 0) {   /* hold B at boot to skip fast launch */
            FarCallScan();            /* scans root, writes the launch path to $c4a4 */
            if (c4a4[0] != 0) {
                fastlaunch_do_launch(); /* boots the ROM; never returns */
            }
        }
    }
    /* no trigger / B held: return -> $1032 -> FileBrowserEntry_redraw paints */
}
