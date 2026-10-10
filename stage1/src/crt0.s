; stage1 start-up. The header fields ($0104-$014F) are filled by rgbfix.
; Interrupts stay off for the whole of stage1.

        .module crt0
        .globl  _main

        .area   _HEADER (ABS)
        .org    0x0000
        ret
        .org    0x0040                  ; vectors: never enabled
        reti
        .org    0x0048
        reti
        .org    0x0050
        reti
        .org    0x0058
        reti
        .org    0x0060
        reti
        .org    0x0100
        nop
        jp      init

        ; area order for the linker: code and constants in ROM, then RAM
        .area   _HOME
        .area   _CODE
        .area   _INITIALIZER
        .area   _GSINIT
        .area   _GSFINAL
        .area   _DATA
        .area   _INITIALIZED
        .area   _BSEG
        .area   _BSS
        .area   _HEAP

        .area   _HOME
init:
        di
        ldh     (0x80), a               ; BOOT_A: $11 on a color console
        ld      sp, #0xE000
        xor     a, a
        ldh     (0xFF), a               ; IE
        ld      (#0x2000), a            ; ROM bank 1, as stock does at start
        inc     a
        ld      (#0x2000), a
        call    gsinit
        call    _main
1$:     halt
        nop
        jr      1$

        .area   _GSINIT
gsinit::
        ld      hl, #s__DATA            ; zero the uninitialized globals
        ld      bc, #l__DATA + 0x0101
        xor     a, a
        jr      3$
2$:     ld      (hl+), a
3$:     dec     c
        jr      nz, 2$
        dec     b
        jr      nz, 2$
        ld      de, #s__INITIALIZED     ; copy the initialized ones
        ld      hl, #s__INITIALIZER
        ld      bc, #l__INITIALIZER + 0x0101
        jr      5$
4$:     ld      a, (hl+)
        ld      (de), a
        inc     de
5$:     dec     c
        jr      nz, 4$
        dec     b
        jr      nz, 4$
        .area   _GSFINAL
        ret
