/* Launch the full path staged in $c4a4 by reusing the kernel's own
 * LastRomRelaunch (bank 0 $1344) verbatim — the exact sequence the START
 * overlay runs to relaunch the last ROM, which is proven to load and boot an
 * arbitrary path.
 *
 * LastRomRelaunch takes the basename pointer from its caller's stack frame at
 * sp+$08 (the START overlay's LastRomDrawBasename put it there via Strrchr).
 * We reproduce exactly that: compute basename = Strrchr($c4a4,'/')+1, then
 * build a stack frame whose sp+$08 slot holds it, and jp into LastRomRelaunch.
 * It then computes the directory prefix, opens it, applies the basename against
 * $c4a4, and far-calls the bank-8 loader ("Loading....") which ends in
 * $7fe0=$80 — the ROM is replaced and the game boots. So this never returns.
 *
 * The four extra pushes are padding so the basename lands at sp+$08 (=$10 below
 * the return-address; LastRomRelaunch reads sp+$08 twice and nothing else from
 * that frame before the machine reboots). $c4a4 must still hold the FULL path
 * here — LastRomRelaunch reads the prefix from it before ApplyBasename
 * overwrites it with the basename.
 *
 * Fast-launch ROMs live in the root, so the directory prefix is always empty
 * and LastRomRelaunch's prefix Memcpy copies 0 bytes, leaving $c2a6 as we set
 * it here: "/". (That is the one bit of state the START overlay gets from the
 * browser's own memset; we set it explicitly so we don't depend on it.)
 */
void fastlaunch_do_launch(void) __naked {
    __asm
        ld  hl, #0xc2a6       ; prefix dir = root
        ld  (hl), #0x2f       ; '/'
        inc hl
        ld  (hl), #0x00       ; NUL

        ld  a, #0x2f          ; '/'
        push af
        inc sp                ; push char arg (1 byte)
        ld  hl, #0xc4a4
        push hl               ; push ptr arg
        call 0x2c42           ; Strrchr($c4a4, '/') -> DE = ptr to last '/'
        add sp, #3            ; drop the 3 arg bytes
        inc de                ; DE = basename pointer (char after the '/')

        push de               ; -> sp+$08 slot once the 4 pads are below it
        push de               ; pad
        push de               ; pad
        push de               ; pad
        push de               ; pad
        jp  0x1344            ; LastRomRelaunch (reads sp+$08 = basename ptr)
    __endasm;
}
