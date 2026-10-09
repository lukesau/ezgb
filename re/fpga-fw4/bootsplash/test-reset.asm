; TEST ONLY, never flashed: when LOADING... is printed ($080E, after the
; icon is drawn and EZ-FLASH has shown for 700 ms), run ResetAttrs. On CGB
; the icon must turn grey (palette 0) but stay drawn.
SECTION "test_site", ROM0[$080E]
    call TestReset              ; was: ld hl,$0b6e (the LOADING string)
SECTION "test_hook", ROM0[$0300]
TestReset:
    call ResetAttrs
    ld hl, $0b6e
    ret
