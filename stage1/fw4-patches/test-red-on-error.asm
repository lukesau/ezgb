; TEST ONLY, never flashed: also run the OSINIT red hook when the
; "Micro SD initial error" message is set up, because the SameBoy stub
; can't take stage1 as far as OSINIT.
SECTION "test_site", ROMX[$4155], BANK[1]
    call TestRed                ; was: ld de,$0bce
SECTION "test_hook", ROM0[$0270]
TestRed:
    call $0228                  ; CgbOsinitRed (leaves hl = $0b7d; overwritten next)
    ld de, $0bce
    ret
