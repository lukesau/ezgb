; SDCC 4's banked call: bank in e, address in hl. Does what stock's
; banked_call (FarCallTrampoline, 00:058D) does with the current bank
; variable at $C4B2 and the bank register at $2000, so a banked function
; finds its first argument at sp+6 either way.
        .module bcall
        .area _HOME

___sdcc_bcall_ehl::
        ld      a, (#0xc4b2)
        push    af
        ld      a, e
        ld      (#0xc4b2), a
        ld      (#0x2000), a
        call    1$
        pop     af
        ld      (#0xc4b2), a
        ld      (#0x2000), a
        ret
1$:     jp      (hl)
