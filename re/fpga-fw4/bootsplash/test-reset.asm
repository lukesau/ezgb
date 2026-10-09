; TEST ONLY, never flashed. The SameBoy stub can't take stage1 as far as the
; kernel hand-off, so at LOADING... ($080E, after the icon is drawn) this
; copies $4000-$41FF to $D100 the way the hand-off stub does, turns the
; copy's final jp $0100 into ret, runs HandoffBlank from WRAM, records LCDC
; as it was left, then switches the LCD back on. Expected on CGB: icon
; screen grey (attributes reset to palette 0), icon still drawn, $C012 = 00.
SECTION "test_site", ROM0[$080E]
    call TestHandoff            ; was: ld hl,$0b6e (the LOADING string)
SECTION "test_hook", ROM0[$0300]
TestHandoff:
    ld hl, $4000
    ld de, $D100
    ld bc, $0200
.copy
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .copy
    ld a, $C9                   ; ret instead of jp $0100 (after the pops)
    ld [HandoffBlank.kernel + 4], a
    ld a, $E4                   ; what stock stage1 hands the kernel in A
    ld bc, $7FF0
    call HandoffBlank
    ldh a, [$FF40]
    ld [$C012], a               ; LCDC as HandoffBlank left it: expect 00
    ld a, $C1
    ldh [$FF40], a
    ei
    ld hl, $0b6e
    ret
