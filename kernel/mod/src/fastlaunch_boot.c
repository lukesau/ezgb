/* Pre-paint boot hook for fast launch, hooked over the browser's
 * "call BrowserSortAllStub" at 00:102f (itself the sorted-browser feature's
 * replacement for the stock DirList call). This runs after the SD card is
 * mounted but BEFORE FileBrowserEntry_redraw ($1071) paints the list, so a
 * fast-launch card goes straight to Loading without the browser flashing.
 *
 * One-shot via the $DBFF flag (cleared at boot): the scan runs only on the
 * first FileBrowserEntry; later entries (directory navigation) skip it and
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
extern unsigned char ReadJoypad(void);        /* 00:3a4a (post-swap key byte in E; START = $80) */

/* Naked so it fits the 30 bytes before DirListHideNameStub (00:04ae). The
 * START check lives in the scan (fastlaunch.c). After it, anything still
 * down (the A that confirmed a prompt or opened this folder) goes into the
 * held mask, so the browser needs a new press. */
void fastlaunch_boot(void) __naked {
    __asm
        call _BrowserSortAllStub ; enumerate/sort FIRST (the launch needs its state)
        ld  hl, #0xdbff
        ld  a, (hl)
        or  a
        jr  nz, 00001$        ; already ran this power-on
        inc (hl)
        call _FarCallScan     ; START check, then writes the launch path to $c4a4
        ld  a, (#0xc4a4)
        or  a
        jp  nz, _fastlaunch_do_launch ; boots the ROM; never returns
00001$:
        call _ReadJoypad      ; E = report
        ldh a, (#0xf7)        ; PAD_HELD |= report
        or  e
        ldh (#0xf7), a
        ret                   ; -> $1032 -> FileBrowserEntry_redraw paints
    __endasm;
}
