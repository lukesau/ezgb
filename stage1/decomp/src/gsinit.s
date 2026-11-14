; Startup code for initialized globals, at 01:4134 where stock crt0 calls
; InitMessages. Stock's compiler stored each pointer with code; SDCC 4
; keeps the values in _INITIALIZER and expects a copy to _INITIALIZED.
        .module gsinit
        .area _GSINIT

InitMessages::
        ld      de, #s__INITIALIZED
        ld      hl, #s__INITIALIZER
        ld      bc, #l__INITIALIZER
1$:     ld      a, b
        or      c
        ret     z
        ld      a, (hl+)
        ld      (de), a
        inc     de
        dec     bc
        jr      1$
