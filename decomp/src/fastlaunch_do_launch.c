/* Launch the full path staged in $c4a4 by reusing the kernel's own
 * LastRomRelaunch (bank 0 $1344) verbatim - the exact sequence the START
 * overlay runs to relaunch the last ROM, which is proven to load and boot an
 * arbitrary path.
 *
 * LastRomRelaunch takes the basename pointer from its caller's stack frame at
 * sp+$08 (the START overlay's LastRomDrawBasename put it there via Strrchr).
 * We reproduce exactly that: compute basename = Strrchr($c4a4,'/')+1, then
 * build a stack frame whose sp+$08 slot holds it, and jp into LastRomRelaunch.
 * It then computes the directory prefix, opens it, applies the basename against
 * $c4a4, and far-calls the bank-8 loader ("Loading....") which ends in
 * $7fe0=$80 - the ROM is replaced and the game boots. So this never returns.
 *
 * The four extra pushes are padding so the basename lands at sp+$08 (=$10 below
 * the return-address; LastRomRelaunch reads sp+$08 twice and nothing else from
 * that frame before the machine reboots). $c4a4 must still hold the FULL path
 * here - LastRomRelaunch reads the prefix from it before ApplyBasename
 * overwrites it with the basename.
 *
 * $c2a4 must hold the FULL path here (may be nested, e.g. "/dir/rom.gb" from a
 * config file). LastRomRelaunch's prefix Memcpy copies the directory part into
 * $c2a6 and relies on the byte past it being NUL, which the browser normally
 * provides by memset. We don't depend on that: we zero $c2a6 first (so any
 * nested prefix is NUL-terminated) and seed '/', which also covers the root
 * case (prefix_len 0 copies nothing, leaving "/").
 */
void fastlaunch_do_launch(void) __naked {
    __asm
        ; SetFpgaPage($00): the START overlay's LastRomDrawBasename does exactly
        ; this before LastRomRelaunch, setting the SD personality for the
        ; directory traversal. We skip that draw step, so without it the nested
        ; opendir reads the wrong FPGA window and hangs on "Loading..." (root
        ; paths work because opening "/" does not traverse).
        ld  a, #0x00
        push af
        inc sp
        call 0x078d          ; FarCallTrampoline
        .db  0xe7, 0x41, 0x04, 0x00   ; -> SetFpgaPageAlt_B4 (04:41e7), page $00
        add sp, #1

        ld  hl, #0xc2a6       ; zero $c2a6[0..127] (NUL-terminates any prefix)
        ld  b, #128
        xor a
00002$:
        ld  (hl), a
        inc hl
        dec b
        jr  nz, 00002$
        ld  hl, #0xc2a6
        ld  (hl), #0x2f       ; seed '/' (root case)

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
