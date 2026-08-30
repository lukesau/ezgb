/* One-shot fast-launch hook, placed over `ld hl,$002d` (21 2D 00) at 00:110B,
 * inside FileBrowserEntry_inputLoop. By the time the browser reaches its idle
 * input loop the card is mounted, listed and drawn, so the scan runs in a
 * settled state and a no-launch outcome just lets the loop continue (unlike an
 * earlier hook before the browser's own DirList, which left FatFs in a state
 * that crashed the browser).
 *
 * A WRAM flag at $DBFF (cleared to 0 at boot) makes it fire only on the first
 * loop iteration. On every iteration it ends by executing the displaced
 * instruction, `ld hl,$002d` (the Delay argument the next instruction pushes),
 * then returns, so the input loop is unchanged.
 *
 * Escape hatch: holding B at boot skips fast launch and drops to the browser.
 * ReadJoypad ($3a4a) returns the post-swap key byte in E, where B is $20 (the
 * same bit the last-ROM overlay tests). The decision is made once (the flag is
 * set first), so it is locked to whatever is held on the first loop iteration.
 */
void fastlaunch_hook(void) __naked {
    __asm
        ld  a, (#0xdbff)
        or  a
        jr  nz, 00001$        ; already ran this power-on
        ld  a, #0x01
        ld  (#0xdbff), a
        call 0x3a4a           ; ReadJoypad -> E = keys held (post-swap; B = $20)
        ld  a, e
        and #0x20             ; hold B at boot to skip fast launch
        jr  nz, 00001$
        call 0x0400           ; FarCallScan -> scans root, writes $c4a4
        ld  a, (#0xc4a4)
        or  a
        jr  z, 00001$         ; no trigger -> continue browsing
        call 0x0420           ; fastlaunch_do_launch -> boots the ROM; no return
00001$:
        ld  hl, #0x002d       ; replay the displaced instruction
        ret
    __endasm;
}
