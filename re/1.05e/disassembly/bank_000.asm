; Disassembly of "kernel.gb"
; This file was created with:
; mgbdis v3.0 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $000", ROM0[$0]

RST_00::
    ret


    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

RST_08::
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

RST_10::
    add b
    ld b, b
    jr nz, jr_000_0024

    ld [$0204], sp
    db $01

RST_18::
    ld bc, $0402
    ld [$2010], sp
    ld b, b
    add b

RST_20::
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

jr_000_0024:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

RST_28::
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

RST_30::
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

RST_38::
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

VBlankInterrupt::
    push hl
    ld hl, $d6d3
    jp Jump_000_0067


    rst RST_38

LCDCInterrupt::
    push hl
    ld hl, $d6e3
    jp Jump_000_0067


    rst RST_38

TimerOverflowInterrupt::
    push hl
    ld hl, $d6f3
    jp Jump_000_0067


    rst RST_38

SerialTransferCompleteInterrupt::
    push hl
    ld hl, $d703
    jp Jump_000_0067


    rst RST_38

JoypadTransitionInterrupt::
    push hl
    ld hl, $d713
    jp Jump_000_0067


Jump_000_0067:
    push af

    push bc
    push de
    ld a, [$d6d0]
    inc a
    ld [$d6d0], a

jr_000_0071:
    ld a, [hl+]
    or [hl]
    jr z, jr_000_0080

    push hl
    ld a, [hl-]
    ld l, [hl]
    ld h, a
    call Call_000_0093
    pop hl
    inc hl
    jr jr_000_0071

jr_000_0080:
    ld a, [$d6d0]
    dec a
    ld [$d6d0], a
    jr z, jr_000_008e

    pop de
    pop bc
    pop af
    pop hl
    ret


jr_000_008e:
    pop de
    pop bc
    pop af
    pop hl
    reti


Call_000_0093:
    jp hl


    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Boot::
    nop
    jp Jump_000_0150


HeaderLogo::
    db $ce, $ed, $66, $66, $cc, $0d, $00, $0b, $03, $73, $00, $83, $00, $0c, $00, $0d
    db $00, $08, $11, $1f, $88, $89, $00, $0e, $dc, $cc, $6e, $e6, $dd, $dd, $d9, $99
    db $bb, $bb, $67, $63, $6e, $0e, $ec, $cc, $dd, $dc, $99, $9f, $bb, $b9, $33, $3e

HeaderTitle::
    db "EZGB", $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

HeaderNewLicenseeCode::
    db $00, $00

HeaderSGBFlag::
    db $00

HeaderCartridgeType::
    db $01

HeaderROMSize::
    db $00

HeaderRAMSize::
    db $00

HeaderDestinationCode::
    db $00

HeaderOldLicenseeCode::
    db $00

HeaderMaskROMVersion::
    db $01

HeaderComplementCheck::
    db $bd

HeaderGlobalChecksum::
    db $7b, $57

Jump_000_0150:
    di
    ld d, a
    xor a
    ld sp, $e000
    ld hl, $dfff
    ld c, $20
    ld b, $00

jr_000_015d:
    ld [hl-], a
    dec b
    jr nz, jr_000_015d

    dec c
    jr nz, jr_000_015d

    ld hl, $feff
    ld b, $00

jr_000_0169:
    ld [hl-], a
    dec b
    jr nz, jr_000_0169

    ld hl, $ffff
    ld b, $80

jr_000_0172:
    ld [hl-], a
    dec b
    jr nz, jr_000_0172

    ld a, d
    ld [$d6c9], a
    ld a, $01
    ld [$d6cf], a
    ld [$2000], a
    xor a
    ld [$d6d0], a
    call Call_000_069f
    xor a
    ldh [rSCY], a
    ldh [rSCX], a
    ldh [rSTAT], a
    ldh [rWY], a
    ld a, $07
    ldh [rWX], a
    ld bc, $ff80
    ld hl, $06b6
    ld b, $0a

jr_000_019e:
    ld a, [hl+]
    ldh [c], a
    inc c
    dec b
    jr nz, jr_000_019e

    ld bc, $0677
    call Call_000_062e
    ld bc, $06c0
    call Call_000_0640
    ld a, $e4
    ldh [rBGP], a
    ldh [rOBP0], a
    ld a, $1b
    ldh [rOBP1], a
    ld a, $c0
    ldh [rLCDC], a
    xor a
    ldh [rIF], a
    ld a, $09
    ldh [rIE], a
    xor a
    ldh [rNR52], a
    ldh [rSC], a
    ld a, $66
    ldh [rSB], a
    ld a, $80
    ldh [rSC], a
    xor a
    ld [$d6d1], a
    ld [$d6d2], a
    call $68b6
    call Call_000_1835

jr_000_01df:
    halt
    jr jr_000_01df

    ret


    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Call_000_0303:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Call_000_0376:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    jp Jump_000_2eea


    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    jp Jump_000_3d21


    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Call_000_0600:
    ld a, l
    ld [$d6ca], a
    and $03
    ld l, a
    ld bc, $01e2
    sla l
    sla l
    add hl, bc
    jp hl


Call_000_0610:
    ld hl, $d6d3
    jp Jump_000_064c


Call_000_0616:
    ld hl, $d6e3
    jp Jump_000_064c


Call_000_061c:
    ld hl, $d6f3
    jp Jump_000_064c


Call_000_0622:
    ld hl, $d703
    jp Jump_000_064c


Call_000_0628:
    ld hl, $d713
    jp Jump_000_064c


Call_000_062e:
    ld hl, $d6d3
    jp Jump_000_066c


Call_000_0634:
    ld hl, $d6e3
    jp Jump_000_066c


Call_000_063a:
    ld hl, $d6f3
    jp Jump_000_066c


Call_000_0640:
    ld hl, $d703
    jp Jump_000_066c


Call_000_0646:
    ld hl, $d713
    jp Jump_000_066c


Call_000_064c:
Jump_000_064c:
jr_000_064c:
    ld a, [hl+]
    ld e, a
    ld d, [hl]
    or d
    ret z

    ld a, e
    cp c
    jr nz, jr_000_064c

    ld a, d
    cp b
    jr nz, jr_000_064c

    xor a
    ld [hl-], a
    ld [hl], a
    inc a
    ld d, h
    ld e, l
    dec de
    inc hl

jr_000_0661:
    ld a, [hl+]
    ld [de], a
    ld b, a
    inc de
    ld a, [hl+]
    ld [de], a
    inc de
    or b
    ret z

    jr jr_000_0661

Jump_000_066c:
jr_000_066c:
    ld a, [hl+]
    or [hl]
    jr z, jr_000_0673

    inc hl
    jr jr_000_066c

jr_000_0673:
    ld [hl], b
    dec hl
    ld [hl], c
    ret


    ld hl, $d6d1
    inc [hl]
    jr nz, jr_000_067f

    inc hl
    inc [hl]

jr_000_067f:
    call $ff80
    ld a, $01
    ld [$d6ce], a
    ret


Call_000_0688:
    ldh a, [rLCDC]
    add a
    ret nc

    xor a
    di
    ld [$d6ce], a
    ei

jr_000_0692:
    halt
    nop
    ld a, [$d6ce]
    or a
    jr z, jr_000_0692

    xor a
    ld [$d6ce], a
    ret


Call_000_069f:
    ldh a, [rLCDC]
    add a
    ret nc

jr_000_06a3:
    ldh a, [rLY]
    cp $92
    jr nc, jr_000_06a3

jr_000_06a9:
    ldh a, [rLY]
    cp $91
    jr c, jr_000_06a9

    ldh a, [rLCDC]
    and $7f
    ldh [rLCDC], a
    ret


    ld a, $c0
    ldh [rDMA], a
    ld a, $28

jr_000_06bc:
    dec a
    jr nz, jr_000_06bc

    ret


    ld a, [$d6cd]
    cp $02
    jr nz, jr_000_06d0

    ldh a, [rSB]
    ld [$d6cc], a
    ld a, $00
    jr jr_000_06de

jr_000_06d0:
    cp $01
    jr nz, jr_000_06ea

    ldh a, [rSB]
    cp $55
    jr z, jr_000_06de

    ld a, $04
    jr jr_000_06e0

jr_000_06de:
    ld a, $00

jr_000_06e0:
    ld [$d6cd], a
    xor a
    ldh [rSC], a
    ld a, $66
    ldh [rSB], a

jr_000_06ea:
    ld a, $80
    ldh [rSC], a
    ret


    ld hl, sp+$02
    ld l, [hl]
    ld h, $00
    call Call_000_0600
    ret


    ld hl, $d6ca
    ld e, [hl]
    ret


Call_000_06fd:
    di
    ld a, [$d6d0]
    inc a
    ld [$d6d0], a
    ret


Call_000_0706:
    ld a, [$d6d0]
    dec a
    ld [$d6d0], a
    ret nz

    ei
    ret


    call Call_000_06fd
    ld hl, sp+$02
    xor a
    ldh [rIF], a
    ld a, [hl]
    ldh [rIE], a
    call Call_000_0706
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_0610
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_0616
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_061c
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_0622
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_0628
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_062e
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_0634
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_063a
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_0640
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_0646
    pop bc
    ret


Call_000_078d:
    call Call_000_06fd
    pop hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    inc hl
    push hl
    ld b, a
    ld a, [$d6cf]
    push af
    ld a, b
    ld [$d6cf], a
    ld [$2000], a
    call Call_000_0706
    ld hl, $07ae
    push hl
    ld l, e
    ld h, d
    jp hl


    call Call_000_06fd
    pop af
    ld [$2000], a
    ld [$d6cf], a
    call Call_000_0706
    ret


Call_000_07bc:
Jump_000_07bc:
    call Call_000_3a4a
    ld c, e
    ld b, $00
    ld a, c
    sub $40
    jp nz, Jump_000_07ce

    or b
    jp nz, Jump_000_07ce

    jr jr_000_07d1

Jump_000_07ce:
    jp Jump_000_07bc


jr_000_07d1:
    ld hl, $00c8
    push hl
    call Call_000_3a93
    add sp, $02
    ret


    ld hl, sp+$02
    ld a, [hl]
    and $01
    jr nz, jr_000_07e5

    jp Jump_000_07f7


jr_000_07e5:
    ld hl, sp+$03
    ld a, [hl]
    add $07
    ld c, a
    inc hl
    ld a, [hl]
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call Call_000_27f6
    add sp, $02

Jump_000_07f7:
    ld hl, sp+$02
    ld a, [hl]
    and $02
    jr nz, jr_000_0801

    jp Jump_000_0813


jr_000_0801:
    ld hl, sp+$03

Call_000_0803:
    ld a, [hl]
    add $06
    ld c, a
    inc hl
    ld a, [hl]
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call Call_000_27f6
    add sp, $02

Jump_000_0813:
    ld hl, sp+$02
    ld a, [hl]
    and $04
    jr nz, jr_000_081d

    jp Jump_000_082f


jr_000_081d:
    ld hl, sp+$03
    ld a, [hl]
    add $05
    ld c, a
    inc hl
    ld a, [hl]
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call Call_000_27f6
    add sp, $02

Jump_000_082f:
    ld hl, sp+$02
    ld a, [hl]
    and $08
    jr nz, jr_000_0839

    jp Jump_000_084c


jr_000_0839:
    ld hl, sp+$03
    ld c, [hl]
    inc c
    inc c
    inc c
    inc c
    inc hl
    ld a, [hl]
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call Call_000_27f6
    add sp, $02

Jump_000_084c:
    ld hl, sp+$02
    ld a, [hl]
    and $10
    jr nz, jr_000_0856

    jp Jump_000_0868


jr_000_0856:
    ld hl, sp+$03
    ld c, [hl]
    inc c
    inc c
    inc c
    inc hl
    ld a, [hl]
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call Call_000_27f6
    add sp, $02

Jump_000_0868:
    ld hl, sp+$02
    ld a, [hl]
    and $20
    jr nz, jr_000_0872

    jp Jump_000_0883


jr_000_0872:
    ld hl, sp+$03
    ld c, [hl]
    inc c
    inc c
    inc hl
    ld a, [hl]
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call Call_000_27f6
    add sp, $02

Jump_000_0883:
    ld hl, sp+$02
    ld a, [hl]
    and $40
    jr nz, jr_000_088d

    jp Jump_000_089d


jr_000_088d:
    ld hl, sp+$03
    ld c, [hl]
    inc c
    inc hl
    ld a, [hl]
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call Call_000_27f6
    add sp, $02

Jump_000_089d:
    ld hl, sp+$02
    ld a, [hl]
    and $80
    jr nz, jr_000_08a7

    jp Jump_000_08b5


jr_000_08a7:
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    dec hl
    ld a, [hl]
    push af
    inc sp
    call Call_000_27f6
    add sp, $02

Jump_000_08b5:
    ret


    ret


Call_000_08b7:
    push af
    dec sp
    ld hl, sp+$09
    ld a, [hl]
    push af
    inc sp
    dec hl
    ld a, [hl]
    push af
    inc sp
    call Call_000_2765
    add sp, $02
    xor a
    ld hl, sp+$07
    or [hl]
    jp nz, Jump_000_08d5

    ld hl, sp+$02
    ld [hl], $11
    jp Jump_000_08db


Jump_000_08d5:
    ld hl, sp+$07
    ld a, [hl]
    ld hl, sp+$02
    ld [hl], a

Jump_000_08db:
    ld hl, sp+$05
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    ld c, $00

Jump_000_08e5:
    ld a, c
    ld hl, sp+$02
    sub [hl]
    jp nc, Jump_000_0927

    dec hl
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    or a
    jp z, Jump_000_0909

    dec hl
    inc [hl]
    jr nz, jr_000_08fd

    inc hl
    inc [hl]

jr_000_08fd:
    push bc
    push bc
    inc sp
    call Call_000_2770
    add sp, $01
    pop bc
    jp Jump_000_0923


Jump_000_0909:
    push bc
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    pop bc
    push bc
    ld a, $20
    push af
    inc sp
    call Call_000_2770
    add sp, $01
    pop bc

Jump_000_0923:
    inc c
    jp Jump_000_08e5


Jump_000_0927:
    add sp, $03
    ret


    add sp, -$15
    ld hl, sp+$01
    ld c, l
    ld b, h
    ld a, $0a
    push af
    inc sp
    push bc
    ld hl, sp+$1c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$1c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_16f4
    add sp, $07
    ld hl, sp+$01
    ld c, l
    ld b, h
    push bc
    call Call_000_2d95
    add sp, $02
    ld b, d
    ld c, e
    ld hl, sp+$00
    ld [hl], c
    ld hl, sp+$01
    ld c, l
    ld b, h
    ld hl, $cc2f
    ld a, [hl]
    push af
    inc sp
    ld hl, $cc30
    ld a, [hl]
    push af
    inc sp
    ld hl, sp+$02
    ld a, [hl]
    push af
    inc sp
    push bc
    call Call_000_08b7
    add sp, $05
    ld hl, $cc2f
    inc [hl]
    ld a, $14
    ld hl, $cc2f
    sub [hl]
    jp nc, Jump_000_0982

    ld hl, $cc2f
    ld [hl], $00

Jump_000_0982:
    add sp, $15
    ret


Call_000_0985:
    ld hl, $cc2f
    ld a, [hl]
    push af
    inc sp
    ld hl, $0100
    push hl
    ld hl, $099c
    push hl
    call Call_000_08b7
    add sp, $05

Jump_000_0998:
    jp Jump_000_0998


    ret


    ld b, [hl]
    ld l, c
    ld l, h
    ld h, l
    jr nz, jr_000_0a15

    ld a, c
    ld [hl], e
    ld [hl], h
    ld h, l
    ld l, l
    jr nz, jr_000_0a0e

    ld [hl], d
    ld [hl], d
    ld l, a
    ld [hl], d
    ld hl, $e800
    rst RST_30
    ld hl, sp+$0b
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$03
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$07
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$0d
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$0f
    ld a, [hl]
    ld hl, sp+$02
    ld [hl], a

Jump_000_09d0:
    ld hl, sp+$02
    ld b, [hl]
    dec [hl]
    xor a
    or b
    jp z, Jump_000_0a11

    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    dec hl
    inc [hl]
    jr nz, jr_000_09e6

    inc hl
    inc [hl]

jr_000_09e6:
    ld hl, sp+$00
    ld [hl], b
    inc hl
    ld [hl], $00
    ld hl, sp+$05
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    dec hl
    inc [hl]
    jr nz, jr_000_09f9

    inc hl
    inc [hl]

jr_000_09f9:
    ld b, $00
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    sub c
    ld e, a
    ld a, d
    sbc b
    ld b, a
    ld c, e
    inc hl
    inc hl
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, c
    or b

jr_000_0a0e:
    jp z, Jump_000_09d0

Jump_000_0a11:
    ld hl, sp+$03
    ld e, [hl]
    inc hl

jr_000_0a15:
    ld d, [hl]
    add sp, $09
    ret


Call_000_0a19:
    push af
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$08
    ld c, [hl]

Jump_000_0a27:
    ld b, c
    dec c
    xor a
    or b
    jp z, Jump_000_0a40

    ld hl, sp+$06
    ld a, [hl]
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_000_0a3d

    inc hl
    inc [hl]

jr_000_0a3d:
    jp Jump_000_0a27


Jump_000_0a40:
    add sp, $02
    ret


Call_000_0a43:
    add sp, -$09
    ld hl, sp+$04
    ld [hl], $00
    ld de, $c9db
    ld hl, $0008
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], d

Jump_000_0a56:
    ld a, $00
    push af
    inc sp
    call Call_000_078d
    rst RST_20
    ld b, c
    inc b
    nop
    add sp, $01
    ld hl, $c9db
    push hl
    ld hl, $c9f5
    push hl
    call Call_000_078d
    halt
    ld [hl], l
    dec b
    nop
    add sp, $04
    ld c, e
    ld a, c
    or a
    jp nz, Jump_000_0a83

    ld bc, $c9e4
    ld a, [bc]
    ld c, a
    or a
    jp nz, Jump_000_0a8b

Jump_000_0a83:
    ld hl, $c5a4
    ld [hl], $01
    jp Jump_000_0bc5


Jump_000_0a8b:
    ld a, c
    sub $2e
    jp z, Jump_000_0a56

    ld bc, $c9f1
    ld e, c
    ld d, b
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld a, [bc]
    or a
    jp nz, Jump_000_0aa3

    ld bc, $c9e4

Jump_000_0aa3:
    ld hl, sp+$07
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, $03
    push af
    inc sp
    call Call_000_078d
    rst RST_20
    ld b, c
    inc b
    nop
    add sp, $01
    ld hl, $c2a2
    ld c, [hl]
    ld hl, $c2a3
    ld b, [hl]
    ld a, $05

jr_000_0abf:
    srl b
    rr c
    dec a
    jr nz, jr_000_0abf

    ld hl, sp+$05
    ld [hl], c
    ld hl, $c2a2
    ld a, [hl]
    and $1f
    ld c, a
    ld b, $00
    ld hl, sp+$06
    ld [hl], c
    ld bc, $4000
    dec hl
    ld a, [hl]
    add $12
    ld [bc], a
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $10
    jp nz, Jump_000_0aeb

    jr jr_000_0aee

Jump_000_0aeb:
    jp Jump_000_0b41


jr_000_0aee:
    ld hl, sp+$06
    ld e, [hl]
    ld d, $00
    ld l, e
    ld h, d
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    ld c, l
    ld b, h
    ld hl, $c2a0
    ld a, [hl]
    add c
    ld hl, $c2a1
    ld c, a
    ld hl, $c2a1
    ld a, [hl]
    adc b
    ld b, a
    ld hl, $00fe
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $10
    ld [de], a
    ld hl, sp+$07
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call Call_000_20e2
    add sp, $04
    ld hl, sp+$04
    inc [hl]
    ld hl, $c2a2
    inc [hl]
    jr nz, jr_000_0b3e

    ld hl, $c2a3
    inc [hl]

jr_000_0b3e:
    jp Jump_000_0bb8


Jump_000_0b41:
    ld a, c
    and $20
    ld c, a
    sub $20
    jp nz, Jump_000_0b4c

    jr jr_000_0b4f

Jump_000_0b4c:
    jp Jump_000_0bb8


jr_000_0b4f:
    ld a, $08
    push af
    inc sp
    ld hl, $0bc8
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call $09af
    add sp, $05
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, Jump_000_0a56

    ld hl, sp+$06
    ld e, [hl]
    ld d, $00
    ld l, e
    ld h, d
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    ld c, l
    ld b, h
    ld hl, $c2a0
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00fe
    add hl, de
    ld c, l
    ld b, h
    ld a, $20
    ld [bc], a
    ld hl, sp+$07
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_20e2
    add sp, $04
    ld hl, sp+$04
    inc [hl]
    ld hl, $c2a2
    inc [hl]
    jr nz, jr_000_0bb8

    ld hl, $c2a3
    inc [hl]

Jump_000_0bb8:
jr_000_0bb8:
    ld hl, sp+$04
    ld a, [hl]
    sub $10
    jp nz, Jump_000_0bc2

    jr jr_000_0bc5

Jump_000_0bc2:
    jp Jump_000_0a56


Jump_000_0bc5:
jr_000_0bc5:
    add sp, $09
    ret


    ld h, l
    ld a, d
    ld h, a
    ld h, d
    ld l, $64
    ld h, c
    ld [hl], h
    nop

Call_000_0bd1:
    add sp, -$10
    ld a, $14
    ld hl, sp+$12
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    ld a, $00
    inc hl
    sbc [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp nc, Jump_000_0ddd

    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, $05

jr_000_0c0a:
    srl b
    rr c
    dec a
    jr nz, jr_000_0c0a

    ld hl, sp+$0c
    ld [hl], c
    ld hl, sp+$08
    ld a, [hl]
    and $1f
    ld c, a
    ld b, $00
    ld hl, sp+$0d
    ld [hl], c
    ld bc, $4000
    dec hl
    ld a, [hl]
    add $12
    ld [bc], a
    inc hl
    ld e, [hl]
    ld d, $00
    ld l, e
    ld h, d
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    push bc
    call Call_000_2d95
    add sp, $02
    ld b, d
    ld c, e
    ld hl, sp+$0e
    ld [hl], c
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, $00fe
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    sub $10
    jp nz, Jump_000_0c81

    jr jr_000_0c84

Jump_000_0c81:
    jp Jump_000_0c8b


jr_000_0c84:
    ld hl, sp+$0f
    ld [hl], $11
    jp Jump_000_0c8f


Jump_000_0c8b:
    ld hl, sp+$0f
    ld [hl], $14

Jump_000_0c8f:
    ld hl, sp+$0f
    ld a, [hl]
    dec hl
    sub [hl]
    jp nc, Jump_000_0ddd

    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    sub $14
    ld e, a
    ld a, d
    sbc $00
    push af
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    sbc $00
    ld e, a
    ld a, d
    sbc $00
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    ld a, $01
    push af
    inc sp
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$07
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_298f
    add sp, $05
    push hl
    ld hl, sp+$06
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$0e
    ld a, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_282c
    add sp, $08
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld a, [hl]
    ld hl, sp+$0a
    ld [hl], a
    ld hl, sp+$01
    ld a, [hl]
    ld hl, sp+$0b
    ld [hl], a
    ld hl, $cc31
    ld a, [hl]
    ld hl, sp+$0a
    sub [hl]
    jp nz, Jump_000_0d2c

    ld hl, $cc32
    ld a, [hl]
    ld hl, sp+$0b
    sub [hl]
    jp z, Jump_000_0ddd

Jump_000_0d2c:
    ld hl, sp+$0a
    ld a, [hl+]
    ld e, [hl]
    ld hl, $cc31
    ld [hl], a
    ld hl, $cc32
    ld [hl], e
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, $00fe
    push hl
    push bc
    ld hl, $c4a4
    push hl
    call Call_000_2cd3
    add sp, $06
    ld hl, $0de0
    push hl
    ld hl, $c4a4
    push hl
    call Call_000_078d
    nop
    ld b, b
    ld bc, $e800
    inc b
    ld hl, $c4a4
    push hl
    call Call_000_2d95
    add sp, $02
    ld b, d
    ld c, e
    ld de, $0080
    ld a, e
    sub c
    ld e, a
    ld a, d
    sbc b
    ld hl, sp+$01
    ld [hl-], a
    ld [hl], e
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, $c4a4
    push hl
    call Call_000_2d95
    add sp, $02
    ld b, d
    ld c, e
    ld hl, $c4a4
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$00
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call Call_000_2cd3
    add sp, $06
    ld hl, sp+$18
    ld c, [hl]
    inc c
    inc c
    ld a, c
    push af
    inc sp
    ld a, $00
    push af
    inc sp
    ld hl, sp+$11
    ld a, [hl]
    push af
    inc sp
    ld hl, $c4a4
    push hl
    call Call_000_08b7
    add sp, $05

Jump_000_0ddd:
    add sp, $10
    ret


    jr nz, jr_000_0e02

    jr nz, jr_000_0de4

Call_000_0de4:
jr_000_0de4:
    add sp, -$17
    ld hl, $c2a0
    ld [hl], $00
    ld hl, $c2a1
    ld [hl], $a0
    ld a, $01
    push af
    inc sp
    ld hl, $16b4
    push hl
    ld hl, $c7a9
    push hl
    call Call_000_078d
    add hl, de
    ld l, [hl]
    dec b

jr_000_0e02:
    nop
    add sp, $05
    ld c, e
    ld hl, sp+$16
    ld [hl], c
    ld a, [hl]
    or a
    jp z, Jump_000_0e24

    ld hl, $cc2f
    ld a, [hl]
    push af
    inc sp
    ld hl, $0014
    push hl
    ld hl, $16b5
    push hl
    call Call_000_08b7
    add sp, $05

Jump_000_0e21:
    jp Jump_000_0e21


Jump_000_0e24:
    ld hl, $cc2f
    ld a, [hl]
    push af
    inc sp
    ld hl, $0014
    push hl
    ld hl, $16cd
    push hl
    call Call_000_08b7
    add sp, $05
    ld hl, sp+$06
    ld [hl], $00
    inc hl
    ld [hl], $40
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $11
    ld [de], a
    ld a, $03
    push af
    inc sp
    call Call_000_078d
    rst RST_20
    ld b, c
    inc b
    nop
    add sp, $01
    ld hl, sp+$06
    ld [hl], $00
    inc hl
    ld [hl], $a0
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    dec hl
    ld [hl], b
    inc hl
    ld [hl], $00
    dec hl
    ld a, [hl]
    sub $aa
    jp nz, Jump_000_0e73

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_000_0e73

    jr jr_000_0e76

Jump_000_0e73:
    jp Jump_000_0f5b


jr_000_0e76:
    ld hl, sp+$06
    ld [hl], $00
    inc hl
    ld [hl], $a2
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    ld c, b
    dec hl
    ld [hl], $02
    inc hl
    ld [hl], $a2
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, $d3f6
    ld [hl], a
    ld hl, sp+$06
    ld [hl], $01
    inc hl
    ld [hl], $a0
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    ld hl, sp+$11
    ld [hl], b
    ld hl, sp+$06
    ld [hl], $00
    inc hl
    ld [hl], $a0
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    dec hl
    ld [hl], $0f
    inc hl
    ld [hl], $a0
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    ld hl, sp+$0f
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_000_0ec4:
    ld hl, sp+$06
    ld [hl], b
    inc hl
    ld [hl], $00
    ld hl, sp+$0f
    ld d, h
    ld e, l
    ld hl, sp+$06
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp nc, Jump_000_0f08

    ld de, $c3a5
    ld hl, sp+$0f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$0f
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $a010
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$0f
    inc [hl]
    jr nz, jr_000_0f05

    inc hl
    inc [hl]

jr_000_0f05:
    jp Jump_000_0ec4


Jump_000_0f08:
    ld de, $c3a5
    ld l, b
    ld h, $00
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    push bc
    ld a, $00
    push af
    inc sp
    call Call_000_078d
    rst RST_20
    ld b, c
    inc b
    nop
    add sp, $01
    pop bc
    push bc
    ld hl, $16e2
    push hl
    call Call_000_19b1
    add sp, $02
    pop bc
    ld hl, sp+$11
    ld a, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld a, c
    push af
    inc sp
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$03
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_078d
    ld b, a
    ld h, a
    ld bc, $e800
    dec b

Jump_000_0f5b:
    ld hl, sp+$00
    ld [hl], $00
    inc hl
    ld [hl], $40
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    ld a, $00
    push af
    inc sp
    call Call_000_078d
    rst RST_20
    ld b, c
    inc b
    nop
    add sp, $01
    ld hl, $00ff
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $c2a6
    push hl
    call Call_000_2ca5
    add sp, $05
    ld de, $c2a6
    ld a, $2f
    ld [de], a

Jump_000_0f8d:
    ld hl, $cc2f
    ld [hl], $00
    ld hl, $cc30
    ld [hl], $00
    ld hl, sp+$0e
    ld [hl], $00
    ld hl, $c5a4
    ld [hl], $00
    call Call_000_078d
    ld b, h
    ld [hl], e
    ld [$3e00], sp
    nop
    push af
    inc sp
    call Call_000_078d
    rst RST_20
    ld b, c
    inc b
    nop
    add sp, $01
    ld hl, $c2a6
    push hl
    call Call_000_078d
    and h
    ld l, [hl]
    dec b
    nop
    add sp, $02
    ld b, e
    ld hl, sp+$16
    ld [hl], b
    ld a, [hl]
    or a
    jp z, Jump_000_0fcd

    call Call_000_0985

Jump_000_0fcd:
    ld hl, $c2a2
    ld [hl], $00
    ld hl, $c2a3
    ld [hl], $00
    ld hl, $c2a6
    push hl
    ld hl, $c9f5
    push hl
    call Call_000_078d
    db $dd
    ld [hl], e
    dec b
    nop
    add sp, $04
    ld b, e
    ld hl, sp+$16
    ld [hl], b
    ld a, [hl]
    or a
    jp z, Jump_000_0ff4

    call Call_000_0985

Jump_000_0ff4:
    ld hl, $00ff
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $c4a4
    push hl
    call Call_000_2ca5
    add sp, $05
    ld c, $db
    ld b, $c9
    ld hl, $001a
    push hl
    ld a, $00
    push af
    inc sp
    push bc
    call Call_000_2ca5
    add sp, $05
    ld bc, $c9f1
    ld e, c
    ld d, b
    ld a, $a4
    ld [de], a
    inc de
    ld a, $c4
    ld [de], a
    ld bc, $c9f3
    ld e, c
    ld d, b
    ld a, $fe
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    call Call_000_0a43
    ld hl, sp+$15
    ld [hl], $00
    dec hl
    dec hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    dec hl
    dec hl
    ld [hl], $01
    xor a
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld a, $00
    push af
    inc sp
    call Call_000_078d
    ld l, c
    ld [hl], c
    ld [$e800], sp
    ld bc, $033e
    push af
    inc sp
    call Call_000_078d
    ld l, c
    ld [hl], c
    ld [$e800], sp
    ld bc, $0af8
    inc [hl]
    jr nz, jr_000_1071

    inc hl
    inc [hl]
    jr nz, jr_000_1071

    inc hl
    inc [hl]
    jr nz, jr_000_1071

    inc hl
    inc [hl]

jr_000_1071:
    xor a
    ld hl, sp+$12
    or [hl]
    jp z, Jump_000_10df

    xor a
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    sub $01
    jp nz, Jump_000_1089

    jr jr_000_108c

Jump_000_1089:
    jp Jump_000_10b1


jr_000_108c:
    ld a, $03
    push af
    inc sp
    call Call_000_078d
    rst RST_20
    ld b, c
    inc b
    nop
    add sp, $01
    ld hl, sp+$15
    ld c, [hl]
    ld b, $00
    push bc
    dec hl
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_078d
    db $e3
    ld b, b
    ld bc, $e800
    inc b
    jp Jump_000_10df


Jump_000_10b1:
    ld a, $01
    ld hl, sp+$12
    sub [hl]
    jp nc, Jump_000_10df

    ld a, $03
    push af
    inc sp
    call Call_000_078d
    rst RST_20
    ld b, c
    inc b
    nop
    add sp, $01
    ld hl, sp+$15
    ld c, [hl]
    ld b, $00
    ld hl, sp+$12
    ld a, [hl]
    push af
    inc sp
    push bc
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_078d
    cp d
    ld b, d
    ld bc, $e800
    dec b

Jump_000_10df:
    ld hl, $c2a2
    ld a, [hl]
    ld hl, $c2a3
    or [hl]
    jp z, Jump_000_1107

    ld hl, sp+$15
    ld c, [hl]
    ld b, $00
    push bc
    dec hl
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$10
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$10
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_0bd1
    add sp, $08

Jump_000_1107:
    ld hl, sp+$12
    ld [hl], $00
    ld hl, $002d
    push hl
    call Call_000_3a93
    add sp, $02
    call Call_000_3a4a
    ld b, e
    ld c, b
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], $00
    dec hl
    ld a, [hl]
    and $02
    jr nz, jr_000_1128

    jp Jump_000_116b


jr_000_1128:
    ld hl, sp+$13
    ld a, [hl+]
    or [hl]
    jp z, Jump_000_115b

    ld a, $0f
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp nc, Jump_000_114d

    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0010
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$14
    ld [hl-], a
    ld [hl], e
    jp Jump_000_1154


Jump_000_114d:
    ld hl, sp+$13
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_000_1154:
    ld hl, sp+$12
    ld [hl], $01
    jp Jump_000_16ab


Jump_000_115b:
    xor a
    ld hl, sp+$15
    or [hl]
    jp z, Jump_000_16ab

    ld [hl], $00
    ld hl, sp+$12
    ld [hl], $01
    jp Jump_000_16ab


Jump_000_116b:
    ld hl, sp+$00
    ld a, [hl]
    and $01
    jr nz, jr_000_1175

    jp Jump_000_11dd


jr_000_1175:
    xor a
    ld hl, $c5a4
    or [hl]
    jp nz, Jump_000_1180

    call Call_000_0a43

Jump_000_1180:
    ld hl, sp+$13
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0010
    add hl, de
    ld c, l
    ld b, h
    ld a, c
    ld hl, $c2a2
    sub [hl]
    ld a, b
    ld hl, $c2a3
    sbc [hl]
    jp nc, Jump_000_16ab

    ld hl, sp+$13
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0020
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], d
    ld hl, $c2a2
    ld d, h
    ld e, l
    ld hl, sp+$06
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp c, Jump_000_11bf

    ld hl, sp+$13
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_000_11d6


Jump_000_11bf:
    ld hl, $c2a2
    ld hl, $c2a2
    ld e, [hl]
    ld hl, $c2a3
    ld d, [hl]
    ld hl, $0010
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$14
    ld [hl-], a
    ld [hl], e

Jump_000_11d6:
    ld hl, sp+$12
    ld [hl], $01
    jp Jump_000_16ab


Jump_000_11dd:
    ld hl, sp+$00
    ld a, [hl]
    and $04
    jr nz, jr_000_11e7

    jp Jump_000_11f6


jr_000_11e7:
    xor a
    ld hl, sp+$15
    or [hl]
    jp z, Jump_000_16ab

    dec [hl]
    ld hl, sp+$12
    ld [hl], $03
    jp Jump_000_16ab


Jump_000_11f6:
    ld hl, sp+$00
    ld a, [hl]
    and $08
    jr nz, jr_000_1200

    jp Jump_000_1223


jr_000_1200:
    ld hl, sp+$15
    ld c, [hl]
    ld b, $00
    inc bc
    ld a, c
    ld hl, $c2a2
    sub [hl]
    ld a, b
    ld hl, $c2a3
    sbc [hl]
    jp nc, Jump_000_16ab

    ld hl, sp+$15
    ld a, [hl]
    sub $0f
    jp nc, Jump_000_16ab

    inc [hl]
    ld hl, sp+$12
    ld [hl], $02
    jp Jump_000_16ab


Jump_000_1223:
    ld hl, sp+$00
    ld a, [hl]
    and $40
    jr nz, jr_000_122d

    jp Jump_000_1294


jr_000_122d:
    ld hl, sp+$0e
    inc [hl]
    ld a, [hl]
    sub $02
    jp nz, Jump_000_1238

    jr jr_000_123b

Jump_000_1238:
    jp Jump_000_1242


jr_000_123b:
    ld hl, sp+$0e
    ld [hl], $00
    jp Jump_000_1267


Jump_000_1242:
    ld hl, sp+$0e
    ld a, [hl]
    sub $01
    jp nz, Jump_000_124c

    jr jr_000_124f

Jump_000_124c:
    jp Jump_000_1267


jr_000_124f:
    ld a, $01
    push af
    inc sp
    call Call_000_078d
    ld l, c
    ld [hl], c
    ld [$e800], sp
    ld bc, $8dcd
    rlca
    db $f4
    ld b, [hl]
    inc b
    nop
    ld hl, sp+$0e
    ld [hl], $02

Jump_000_1267:
    ld hl, sp+$0e
    ld a, [hl]
    sub $02
    jp nz, Jump_000_1271

    jr jr_000_1274

Jump_000_1271:
    jp Jump_000_16ab


jr_000_1274:
    ld a, $02
    push af
    inc sp
    call Call_000_078d
    ld l, c
    ld [hl], c
    ld [$e800], sp
    ld bc, $8dcd
    rlca
    ret nc

    ld l, a
    ld [$2100], sp
    ld [hl-], a
    nop
    push hl
    call Call_000_3a93
    add sp, $02
    jp Jump_000_0f8d


Jump_000_1294:
    ld hl, sp+$00
    ld a, [hl]
    and $80
    jr nz, jr_000_129e

    jp Jump_000_1392


jr_000_129e:
    call Call_000_078d
    push af
    ld [hl], e
    ld [$0100], sp
    nop
    ld b, b
    ld a, $11
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call Call_000_078d
    rst RST_20
    ld b, c
    inc b
    nop
    add sp, $01
    ld hl, sp+$0f
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_000_12bf:
    ld hl, sp+$0f
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_000_12f1

    ld de, $c4a4
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$0f
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $a300
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld [bc], a
    ld hl, sp+$0f
    inc [hl]
    jr nz, jr_000_12ee

    inc hl
    inc [hl]

jr_000_12ee:
    jp Jump_000_12bf


Jump_000_12f1:
    ld bc, $4000
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call Call_000_078d
    rst RST_20
    ld b, c
    inc b
    nop
    add sp, $01
    ld a, $2f
    push af
    inc sp
    ld hl, $c4a4
    push hl
    call Call_000_2c42
    add sp, $03
    ld b, d
    ld c, e
    ld hl, $0001
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld hl, $0f00
    push hl
    ld a, $14
    push af
    inc sp
    ld hl, sp+$0b
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_08b7
    add sp, $05

Jump_000_1330:
    call Call_000_3a4a
    ld b, e
    ld c, b
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], $00
    dec hl
    ld a, [hl]
    and $10
    jr nz, jr_000_1344

    jp Jump_000_1385


jr_000_1344:
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $c4a4
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld c, e
    dec bc
    push bc
    push hl
    ld hl, $c2a6
    push hl
    call Call_000_2cba
    add sp, $06
    ld hl, $c2a6
    push hl
    call Call_000_078d
    and h
    ld l, [hl]
    dec b
    nop
    add sp, $02
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $c4a4
    push hl
    call Call_000_20e2
    add sp, $04
    call Call_000_078d
    ld a, a
    ld [hl], e
    ld [$c300], sp
    ld [hl], b
    dec d

Jump_000_1385:
    ld hl, sp+$04
    ld a, [hl]
    and $20
    jr nz, jr_000_138f

    jp Jump_000_1330


jr_000_138f:
    jp Jump_000_0f8d


Jump_000_1392:
    ld hl, sp+$00
    ld a, [hl]
    and $10
    jr nz, jr_000_139c

    jp Jump_000_162f


jr_000_139c:
    ld hl, sp+$15
    ld c, [hl]
    ld b, $00
    dec hl
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, $05

jr_000_13b3:
    srl b
    rr c
    dec a
    jr nz, jr_000_13b3

    ld hl, sp+$04
    ld a, [hl]
    and $1f
    ld [hl+], a
    ld [hl], $00
    dec hl
    ld b, [hl]
    ld [hl], $00
    inc hl
    ld [hl], $40
    ld a, c
    add $12
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld e, b
    ld d, $00
    ld l, e
    ld h, d
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, $00fe
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld b, a
    sub $10
    jp nz, Jump_000_140c

    jr jr_000_140f

Jump_000_140c:
    jp Jump_000_145f


jr_000_140f:
    ld hl, $16e9
    push hl
    ld hl, $c2a6
    push hl
    call Call_000_078d
    ld c, b
    ld b, b
    ld bc, $e800
    inc b
    ld b, d
    ld c, e
    ld hl, sp+$16
    ld [hl], c
    xor a
    or [hl]
    jp z, Jump_000_143b

    ld hl, $16e9
    push hl
    ld hl, $c2a6
    push hl
    call Call_000_078d
    nop
    ld b, b
    ld bc, $e800
    inc b

Jump_000_143b:
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    push bc
    ld hl, $c2a6
    push hl
    call Call_000_078d
    nop
    ld b, b
    ld bc, $e800
    inc b
    jp Jump_000_0f8d


Jump_000_145f:
    call Call_000_078d
    ld a, a
    ld [hl], e
    ld [$3e00], sp
    rst RST_38
    push af
    inc sp
    ld hl, $0000
    push hl
    ld hl, $c4a4
    push hl
    call Call_000_0a19
    add sp, $05
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    push bc
    ld hl, $c4a4
    push hl
    call Call_000_20e2
    add sp, $04
    ld a, $2e
    push af
    inc sp
    ld hl, $c4a4
    push hl
    call Call_000_2c42
    add sp, $03
    ld b, d
    ld c, e
    ld hl, $0005
    push hl
    push bc
    ld hl, $c3a5
    push hl
    call Call_000_2cba
    add sp, $06
    ld de, $c3a5
    ld hl, $0001
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld b, a
    sub $61
    rlca
    jp c, Jump_000_14d6

    ld a, $7a
    sub b
    rlca
    jp c, Jump_000_14d6

    ld a, b
    add $e0
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a

Jump_000_14d6:
    ld de, $c3a5
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld b, a
    sub $61
    rlca
    jp c, Jump_000_14fb

    ld a, $7a
    sub b
    rlca
    jp c, Jump_000_14fb

    ld a, b
    add $e0
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a

Jump_000_14fb:
    ld de, $c3a5
    ld hl, $0003
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld b, a
    sub $61
    rlca
    jp c, Jump_000_1520

    ld a, $7a
    sub b
    rlca
    jp c, Jump_000_1520

    ld a, b
    add $e0
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a

Jump_000_1520:
    ld a, $05
    push af
    inc sp
    ld hl, $16eb
    push hl
    ld hl, $c3a5
    push hl
    call $09af
    add sp, $05
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, Jump_000_1569

    ld a, $04
    push af
    inc sp
    ld hl, $16f0
    push hl
    ld hl, $c3a5
    push hl
    call $09af
    add sp, $05
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, Jump_000_1569

    call Call_000_078d
    cp d
    ld [hl], e
    ld [$cd00], sp
    ld c, d
    ld a, [hl-]
    ld b, e
    ld c, b
    ld b, $00
    ld a, c
    and $20
    jr nz, jr_000_1566

    jp $1557


jr_000_1566:
    jp Jump_000_0f8d


Jump_000_1569:
    call Call_000_078d
    dec hl
    ld c, b
    ld bc, $2100
    and h
    call nz, $cde5
    adc l
    rlca
    inc d
    ld e, [hl]
    ld bc, $e800
    ld [bc], a
    ld b, e
    ld hl, sp+$16
    ld [hl], b
    ld a, [hl]
    inc a
    jp nz, Jump_000_1588

    jr jr_000_158b

Jump_000_1588:
    jp Jump_000_1591


jr_000_158b:
    call Call_000_07bc
    jp Jump_000_0f8d


Jump_000_1591:
    xor a
    ld hl, $d3ef
    or [hl]
    jp z, $15ae

    ld hl, $0000
    push hl
    ld hl, $2000
    push hl
    ld hl, $c4a4
    push hl
    call Call_000_078d
    ld h, e
    ld d, c
    ld bc, $e800
    ld b, $21
    and h
    call nz, $cde5
    adc l
    rlca
    or b
    ld e, b
    ld bc, $e800
    ld [bc], a
    ld a, $02
    push af
    inc sp
    call Call_000_078d
    rst RST_20
    ld b, c
    inc b
    nop
    add sp, $01
    ld hl, $d3f0
    ld a, [hl]
    rrca
    and $80
    ld b, a
    ld hl, $d3eb
    ld c, [hl]
    ld a, b
    or c
    ld b, a
    push bc
    inc sp
    call Call_000_078d
    ld h, b
    ld b, c
    inc b
    nop
    add sp, $01
    ld a, $00
    push af
    inc sp
    call Call_000_078d
    dec bc
    ld c, b
    ld bc, $e800
    ld bc, $ed21
    db $d3
    ld a, [hl]
    push af
    inc sp
    call Call_000_078d
    db $ec
    ld b, e
    inc b
    nop
    add sp, $01
    ld hl, $d3ec
    ld a, [hl]
    push af
    inc sp
    call Call_000_078d
    rlca
    ld b, d
    inc b
    nop
    add sp, $01
    call Call_000_078d
    ld l, [hl]
    ld b, h
    inc b
    nop
    call Call_000_069f
    call Call_000_06fd
    ld hl, sp+$16
    ld a, [hl]
    push af
    inc sp
    ld hl, $c0a0
    push hl
    call Call_000_078d
    adc a
    ld b, h
    inc b
    nop
    add sp, $03

Jump_000_162c:
    jp Jump_000_162c


Jump_000_162f:
    ld hl, sp+$00
    ld a, [hl]
    and $20
    jr nz, jr_000_1639

    jp Jump_000_16ab


jr_000_1639:
    ld hl, $16e9
    push hl
    ld hl, $c2a6
    push hl
    call Call_000_078d
    ld c, b
    ld b, b
    ld bc, $e800
    inc b
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, Jump_000_16ab

    ld hl, $00ff
    push hl
    ld hl, $c2a6
    push hl
    ld hl, $c3a5
    push hl
    call Call_000_2cba
    add sp, $06
    ld a, $2f
    push af
    inc sp
    ld hl, $c3a5
    push hl
    call Call_000_2c42
    add sp, $03
    ld b, d
    ld c, e
    push bc
    ld hl, $00ff
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $c2a6
    push hl
    call Call_000_2ca5
    add sp, $05
    pop bc
    ld a, c
    sub $a5
    ld c, a
    ld a, b
    sbc $c3
    ld b, a
    push bc
    ld hl, $c3a5
    push hl
    ld hl, $c2a6
    push hl
    call Call_000_2cba
    add sp, $06
    ld de, $c2a6
    ld a, [de]
    or a
    jp nz, Jump_000_0f8d

    ld de, $c2a6
    ld a, $2f
    ld [de], a
    jp Jump_000_0f8d


Jump_000_16ab:
    call Call_000_0688
    jp $1062


    add sp, $17
    ret


    nop
    ld c, l
    ld l, c
    ld h, e
    ld [hl], d
    ld l, a
    jr nz, jr_000_170f

    ld b, h
    jr nz, jr_000_1728

    ld l, [hl]
    ld l, c
    ld [hl], h
    ld l, c
    ld h, c
    ld l, h
    jr nz, @+$67

    ld [hl], d
    ld [hl], d
    ld l, a
    ld [hl], d
    ld hl, $4d00
    ld l, c
    ld h, e
    ld [hl], d
    ld l, a
    jr nz, jr_000_1727

    ld b, h
    jr nz, @+$6b

    ld l, [hl]
    ld l, c
    ld [hl], h
    ld l, c
    ld h, c
    ld l, h
    jr nz, jr_000_172e

    ld c, e
    ld hl, $2f00
    ld d, e
    ld b, c
    ld d, [hl]
    ld b, l
    ld d, d
    nop
    cpl
    nop
    ld l, $47
    ld b, d
    ld b, e
    nop
    ld l, $47
    ld b, d
    nop

Call_000_16f4:
    add sp, -$33
    ld hl, sp+$12
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$0a
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$35
    ld d, h
    ld e, l
    ld hl, sp+$06
    ld a, [de]
    ld [hl+], a

jr_000_170f:
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a

Jump_000_1718:
    ld hl, sp+$06
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_000_1739

    inc hl
    ld a, [hl]
    ld hl, sp+$04

jr_000_1727:
    sub [hl]

jr_000_1728:
    jp nz, Jump_000_1736

    ld hl, sp+$0b
    ld a, [hl]

jr_000_172e:
    ld hl, sp+$05
    sub [hl]
    jp nz, Jump_000_1736

    jr jr_000_1739

Jump_000_1736:
    jp Jump_000_17e5


Jump_000_1739:
jr_000_1739:
    ld hl, sp+$3b
    ld a, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_282c
    add sp, $08
    push hl
    ld hl, sp+$10
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_2832
    add sp, $08
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld d, h
    ld e, l
    ld hl, sp+$06
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld hl, sp+$0e
    ld a, [hl]
    sub $0a
    inc hl
    ld a, [hl]
    sbc $00
    inc hl
    ld a, [hl]
    sbc $00
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_000_17d0

    ld hl, sp+$0e
    ld c, [hl]
    ld a, c
    add $30
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_000_17cd

    inc hl
    inc [hl]

jr_000_17cd:
    jp Jump_000_1718


Jump_000_17d0:
    ld hl, sp+$0e
    ld c, [hl]
    ld a, c
    add $57
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_000_17e2

    inc hl
    inc [hl]

jr_000_17e2:
    jp Jump_000_1718


Jump_000_17e5:
    ld hl, sp+$39
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0c
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$0a
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$0c
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], e

Jump_000_1802:
    ld a, c
    ld hl, sp+$00
    sub [hl]
    ld a, b
    inc hl
    sbc [hl]
    rlca
    jp nc, Jump_000_182a

    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    dec de
    dec hl
    ld [hl], e
    inc hl
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_000_1827

    inc hl
    inc [hl]

jr_000_1827:
    jp Jump_000_1802


Jump_000_182a:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    add sp, $33
    ret


Call_000_1835:
    ld hl, $cc2f
    ld [hl], $00
    ld bc, $4000
    ld a, $11
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call Call_000_078d
    rst RST_20
    ld b, c
    inc b
    nop
    add sp, $01
    ld bc, $a201
    ld a, [bc]
    ld c, a
    sub $88
    jp z, Jump_000_18eb

    ld hl, $0805
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, $190f
    push hl
    call Call_000_08b7
    add sp, $05
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, $016c
    push hl
    ld hl, $7d25
    push hl
    ld a, $23
    push af
    inc sp
    call Call_000_27ba
    add sp, $05
    ld hl, $0705
    push hl
    ld a, $07
    push af
    inc sp
    ld hl, $1911
    push hl
    call Call_000_08b7
    add sp, $05
    ld hl, $0805
    push hl
    ld a, $06
    push af
    inc sp
    ld hl, $1919
    push hl
    call Call_000_08b7
    add sp, $05
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, $016a
    push hl
    ld hl, $7b5d
    push hl
    ld a, $4e
    push af
    inc sp
    call Call_000_27ba
    add sp, $05
    ld hl, $0c0a
    push hl
    ld a, $05
    push af
    inc sp
    ld hl, $1920
    push hl
    call Call_000_08b7
    add sp, $05

Jump_000_18d7:
    call Call_000_3a4a
    ld c, e
    ld b, $00
    ld a, c
    and $10
    jr nz, jr_000_18e5

    jp Jump_000_18d7


jr_000_18e5:
    ld bc, $a201
    ld a, $88
    ld [bc], a

Jump_000_18eb:
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld bc, $4000
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call Call_000_078d
    rst RST_20
    ld b, c
    inc b
    nop
    add sp, $01
    call Call_000_0de4
    ret


    jr nz, jr_000_1911

jr_000_1911:
    ld b, d
    ld b, c
    ld d, h
    ld d, h
    ld b, l
    ld d, d
    ld e, c
    nop
    ld b, h
    ld d, d
    ld e, c
    ld hl, $2121
    nop
    ld e, e
    ld b, c
    ld e, l
    ld c, a
    ld c, e
    nop

Call_000_1926:
    ld hl, sp+$06
    ld a, [hl]
    push af
    inc sp
    dec hl
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_078d
    add hl, bc
    ld [hl], e
    ld b, $00
    add sp, $05
    ret


Call_000_1941:
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_078d
    sbc d
    ld [hl], a
    ld b, $00
    add sp, $08
    ret


Call_000_1963:
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_078d
    add hl, sp
    ld [hl], a
    rlca
    nop
    add sp, $08
    ret


Call_000_1985:
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_078d
    call z, Call_000_0376
    nop
    add sp, $06
    ret


Call_000_19a1:
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_078d
    adc a
    halt
    inc bc
    nop
    add sp, $02
    ret


Call_000_19b1:
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_078d
    rst RST_38
    ld [hl], a
    add hl, bc
    nop
    add sp, $02
    ret


Call_000_19c1:
    push af
    push af
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_078d
    ld a, c
    ld b, d
    dec b
    nop
    add sp, $06
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add sp, $04
    ret


Call_000_19f5:
    push af
    push af
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_078d
    ld a, b
    ld b, e
    dec b
    nop
    add sp, $06
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add sp, $04
    ret


Call_000_1a29:
    ld e, $00
    ret


Call_000_1a2c:
    ld e, $00
    ret


Call_000_1a2f:
    ld hl, sp+$09
    ld c, [hl]
    ld hl, sp+$03
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld a, c
    push af
    inc sp
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_078d
    daa
    ld b, b
    ld [bc], a
    nop
    add sp, $07
    ld c, e
    ld e, c
    ret


Call_000_1a53:
    ld hl, sp+$09
    ld c, [hl]
    ld hl, sp+$03
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld a, c
    push af
    inc sp
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_078d
    push de
    ld b, c
    ld [bc], a
    nop
    add sp, $07
    ld c, e
    ld e, c
    ret


Call_000_1a77:
    ld e, $00
    ret


Call_000_1a7a:
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7fc0
    ld hl, sp+$02
    ld a, [hl]
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ret


Call_000_1a9a:
    add sp, -$1d
    ld a, $06
    push af
    inc sp
    call Call_000_1a7a
    add sp, $01
    ld hl, sp+$16
    ld a, l
    ld d, h
    ld hl, sp+$14
    ld [hl+], a
    ld [hl], d
    ld bc, $a008
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0001
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$12
    ld [hl+], a
    ld [hl], d
    ld bc, $a009
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$10
    ld [hl+], a
    ld [hl], d
    ld bc, $a00a
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0003
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0e
    ld [hl+], a
    ld [hl], d
    ld bc, $a00b
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0c
    ld [hl+], a
    ld [hl], d
    ld bc, $a00c
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0005
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0c
    ld [hl+], a
    ld [hl], d
    ld bc, $a00d
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl], d
    ld bc, $a00e
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld a, $00
    push af
    inc sp
    call Call_000_1a7a
    add sp, $01
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    and $0f
    ld c, a
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    srl c
    srl c
    srl c
    srl c
    ld e, c
    ld d, $00
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, $0014
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, b
    rla
    sbc a
    inc hl
    ld [hl+], a
    ld [hl], a
    ld a, $19
    push af
    inc sp
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$07
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_29c9
    add sp, $05
    push hl
    ld hl, sp+$06
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    and $0f
    ld c, a
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], $00
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    srl c
    srl c
    srl c
    srl c
    ld e, c
    ld d, $00
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, b
    rla
    sbc a
    inc hl
    ld [hl+], a
    ld [hl], a
    ld a, $15
    push af
    inc sp
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$03
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_29c9
    add sp, $05
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld a, [hl]
    ld hl, sp+$04
    or [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$05
    or [hl]
    ld hl, sp+$01
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$06
    or [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$07
    or [hl]
    ld hl, sp+$03
    ld [hl], a
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    and $0f
    ld c, a
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], $00
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    and $3f
    ld c, a
    srl c
    srl c
    srl c
    srl c
    ld e, c
    ld d, $00
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, b
    rla
    sbc a
    inc hl
    ld [hl+], a
    ld [hl], a
    ld a, $10
    push af
    inc sp
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$07
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_29c9
    add sp, $05
    push hl
    ld hl, sp+$06
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld a, [hl]
    ld hl, sp+$04
    or [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$05
    or [hl]
    ld hl, sp+$01
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$06
    or [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$07
    or [hl]
    ld hl, sp+$03
    ld [hl], a
    ld hl, sp+$10
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    and $0f
    ld c, a
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], $00
    ld hl, sp+$10
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    and $3f
    ld c, a
    srl c
    srl c
    srl c
    srl c
    ld e, c
    ld d, $00
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, b
    rla
    sbc a
    inc hl
    ld [hl+], a
    ld [hl], a
    ld a, $0b
    push af
    inc sp
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$07
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_29c9
    add sp, $05
    push hl
    ld hl, sp+$06
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld a, [hl]
    ld hl, sp+$04
    or [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$05
    or [hl]
    ld hl, sp+$01
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$06
    or [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$07
    or [hl]
    ld hl, sp+$03
    ld [hl], a
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    and $0f
    ld c, a
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], $00
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    srl c
    srl c
    srl c
    srl c
    ld e, c
    ld d, $00
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, b
    rla
    sbc a
    inc hl
    ld [hl+], a
    ld [hl], a
    ld a, $05
    push af
    inc sp
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$07
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_29c9
    add sp, $05
    push hl
    ld hl, sp+$06
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld a, [hl]
    ld hl, sp+$04
    or [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$05
    or [hl]
    ld hl, sp+$01
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$06
    or [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$07
    or [hl]
    ld hl, sp+$03
    ld [hl], a
    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    and $0f
    ld c, a
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], $00
    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    srl c
    srl c
    srl c
    srl c
    ld e, c
    ld d, $00
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, b
    rla
    sbc a
    inc hl
    ld [hl+], a
    ld [hl], a
    ld a, $01
    push af
    inc sp
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$07
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_298f
    add sp, $05
    push hl
    ld hl, sp+$06
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld a, [hl]
    ld hl, sp+$04
    or [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$05
    or [hl]
    ld hl, sp+$01
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$06
    or [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$07
    or [hl]
    ld hl, sp+$03
    ld [hl], a
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add sp, $1d
    ret


Call_000_1e1a:
    push af
    push af
    dec sp
    ld hl, sp+$07
    ld a, [hl]
    sub $80
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_000_1e30

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    jp Jump_000_1ed0


Jump_000_1e30:
    ld hl, sp+$09
    ld a, [hl+]
    or [hl]
    jp z, Jump_000_1e7e

    ld hl, sp+$07
    ld a, [hl]
    sub $00
    inc hl
    ld a, [hl]
    sbc $01
    ld a, $00
    rla
    ld hl, sp+$02
    ld [hl], a
    or a
    sub $01
    ld a, $00
    rla
    ld [hl], a
    or a
    jp z, Jump_000_1e5a

    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp Jump_000_1e76


Jump_000_1e5a:
    ld hl, sp+$07
    ld c, [hl]
    ld a, c
    add $80
    ld c, a
    ld b, $00
    sla c
    rl b
    ld hl, $1ed5
    add hl, bc
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$03
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a

Jump_000_1e76:
    ld hl, sp+$03
    ld c, [hl]
    inc hl
    ld b, [hl]
    jp Jump_000_1ed0


Jump_000_1e7e:
    ld hl, sp+$03
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_000_1e85:
    ld hl, sp+$03
    ld a, [hl]
    sub $80
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_000_1ebd

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    sla c
    rl b
    ld hl, $1ed5
    add hl, bc
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a

jr_000_1ea6:
    ld hl, sp+$07
    ld a, [hl]
    sub c
    jp nz, Jump_000_1eb3

    inc hl
    ld a, [hl]
    sub b
    jp z, Jump_000_1ebd

Jump_000_1eb3:
    ld hl, sp+$03
    inc [hl]
    jr nz, jr_000_1eba

    inc hl
    inc [hl]

jr_000_1eba:
    jp Jump_000_1e85


Jump_000_1ebd:
    ld hl, sp+$03
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0080
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    dec hl
    ld c, [hl]
    ld b, $00

Jump_000_1ed0:
    ld e, c
    ld d, b
    add sp, $05
    ret


    rst RST_00
    nop
    db $fc
    nop
    jp hl


    nop
    ldh [c], a
    nop
    db $e4
    nop
    ldh [rP1], a
    push hl
    nop
    rst RST_20
    nop
    ld [$eb00], a
    nop
    add sp, $00
    rst RST_28
    nop
    xor $00
    db $ec
    nop
    call nz, $c500
    nop
    ret


    nop
    and $00
    add $00
    db $f4
    nop
    or $00
    ldh a, [c]
    nop
    ei
    nop
    ld sp, hl
    nop
    rst RST_38
    nop
    sub $00
    call c, $a200
    nop
    and e
    nop
    and l
    nop
    and a
    jr nz, jr_000_1ea6

    ld bc, $00e1
    db $ed
    nop
    di
    nop
    ld a, [$f100]
    nop
    pop de
    nop
    xor d
    nop
    cp d
    nop
    cp a
    nop
    db $10
    inc hl
    xor h
    nop
    cp l
    nop
    cp h
    nop
    and c
    nop
    xor e
    nop
    cp e
    nop
    sub c
    dec h
    sub d
    dec h
    sub e
    dec h
    ld [bc], a
    dec h
    inc h
    dec h
    ld h, c
    dec h
    ld h, d
    dec h
    ld d, [hl]
    dec h
    ld d, l
    dec h
    ld h, e
    dec h
    ld d, c
    dec h
    ld d, a
    dec h
    ld e, l
    dec h
    ld e, h
    dec h
    ld e, e
    dec h
    db $10
    dec h
    inc d
    dec h
    inc [hl]
    dec h
    inc l
    dec h
    inc e
    dec h
    nop
    dec h
    inc a
    dec h
    ld e, [hl]
    dec h
    ld e, a
    dec h
    ld e, d
    dec h
    ld d, h
    dec h
    ld l, c
    dec h
    ld h, [hl]
    dec h
    ld h, b
    dec h
    ld d, b
    dec h
    ld l, h
    dec h
    ld h, a
    dec h
    ld l, b
    dec h
    ld h, h
    dec h
    ld h, l
    dec h
    ld e, c
    dec h
    ld e, b
    dec h
    ld d, d
    dec h
    ld d, e

jr_000_1f82:
    dec h
    ld l, e
    dec h
    ld l, d
    dec h
    jr @+$27

    inc c
    dec h
    adc b
    dec h
    add h
    dec h
    adc h
    dec h
    sub b
    dec h
    add b
    dec h
    or c
    inc bc
    rst RST_18
    nop
    sub e
    inc bc
    ret nz

    inc bc
    and e
    inc bc
    jp $b503


    nop
    call nz, $a603
    inc bc
    sbc b
    inc bc
    xor c
    inc bc
    or h
    inc bc
    ld e, $22
    add $03
    or l
    inc bc
    add hl, hl
    ld [hl+], a
    ld h, c
    ld [hl+], a
    or c
    nop
    ld h, l
    ld [hl+], a
    ld h, h
    ld [hl+], a
    jr nz, jr_000_1fe2

    ld hl, $f723
    nop
    ld c, b
    ld [hl+], a
    or b
    nop
    add hl, de
    ld [hl+], a
    or a
    nop
    ld a, [de]
    ld [hl+], a
    ld a, a
    jr nz, jr_000_1f82

    nop
    and b
    dec h
    and b
    nop

Call_000_1fd5:
    push af
    push af
    push af
    push af
    ld hl, sp+$0a
    ld a, [hl]
    sub $80
    inc hl
    ld a, [hl]
    sbc $00

jr_000_1fe2:
    jp nc, Jump_000_200e

    dec hl
    ld a, [hl]
    sub $61
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_000_20b3

    ld a, $7a
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp c, Jump_000_20b3

    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0020
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$0b
    ld [hl-], a
    ld [hl], e
    jp Jump_000_20b3


Jump_000_200e:
    ld hl, sp+$00
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $ee
    inc hl
    ld [hl], $01
    inc hl
    ld [hl], $0c
    inc hl
    ld [hl], $00

Jump_000_2021:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$00
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld c, e
    srl b
    rr c
    ld hl, sp+$00
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$06
    ld [hl], c
    inc hl
    ld [hl], b
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    sla c
    rl b
    ld hl, $cc33
    add hl, bc
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$0a
    ld a, [hl]
    sub c
    jp nz, Jump_000_2065

    inc hl
    ld a, [hl]
    sub b
    jp z, Jump_000_2092

Jump_000_2065:
    ld a, c
    ld hl, sp+$0a
    sub [hl]
    ld a, b
    inc hl
    sbc [hl]
    jp nc, Jump_000_207a

    ld hl, sp+$06
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    jp Jump_000_2082


Jump_000_207a:
    ld hl, sp+$06
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], e

Jump_000_2082:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    dec de
    dec hl
    ld [hl], e
    inc hl
    ld [hl], d
    dec hl
    ld a, [hl+]
    or [hl]
    jp nz, Jump_000_2021

Jump_000_2092:
    ld hl, sp+$04
    ld a, [hl+]
    or [hl]
    jp z, Jump_000_20b3

    inc hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    sla c
    rl b
    ld hl, $d00f
    add hl, bc
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$0a
    ld [hl], c
    inc hl
    ld [hl], b

Jump_000_20b3:
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $08
    ret


Call_000_20bb:
    ld c, l
    ld b, h
    pop hl

Jump_000_20be:
    ld e, [hl]
    inc hl
    bit 7, e
    jp z, Jump_000_20d0

    ld a, [hl]
    inc hl

Jump_000_20c7:
    ld [bc], a
    inc bc
    inc e
    jp nz, Jump_000_20c7

    jp Jump_000_20be


Jump_000_20d0:
    xor a
    or e
    jp z, Jump_000_20e0

Jump_000_20d5:
    ld a, [hl]
    inc hl
    ld [bc], a
    inc bc
    dec e
    jp nz, Jump_000_20d5

    jp Jump_000_20be


Jump_000_20e0:
    push hl
    ret


Call_000_20e2:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a

jr_000_20ec:
    ld a, [de]
    inc de
    ld [hl], a
    and a
    ret z

    inc hl
    jr jr_000_20ec

Call_000_20f4:
    push hl
    ld hl, $d732
    ld a, $13
    cp [hl]
    jr z, jr_000_2100

    inc [hl]
    jr jr_000_210f

jr_000_2100:
    ld [hl], $00
    ld hl, $d733
    ld a, $11
    cp [hl]
    jr z, jr_000_210d

    inc [hl]
    jr jr_000_210f

jr_000_210d:
    ld [hl], $00

jr_000_210f:
    pop hl
    ret


Call_000_2111:
    ld a, b
    ld [$d725], a
    ld a, c
    ld [$d727], a
    xor a
    ld [$d726], a
    ld a, d
    ld [$d728], a
    cpl
    ld l, a
    ld h, $ff
    inc hl
    ld bc, $0000
    add hl, bc
    ld a, l
    ld [$d72d], a
    ld a, h
    ld [$d72c], a

Jump_000_2132:
jr_000_2132:
    ld a, [$d726]
    ld b, a
    ld a, [$d728]
    sub b
    ret c

    ld a, [$d724]
    or a
    call z, Call_000_2248
    ld a, [$d72c]
    bit 7, a
    jr z, jr_000_2176

    ld a, [$d724]
    or a
    call nz, Call_000_21b4
    ld a, [$d726]
    inc a
    ld [$d726], a
    ld a, [$d72c]
    ld b, a
    ld a, [$d72d]
    ld c, a
    ld h, $00
    ld a, [$d726]
    ld l, a
    add hl, hl
    add hl, hl
    add hl, bc
    ld bc, $0006
    add hl, bc
    ld a, h
    ld [$d72c], a
    ld a, l
    ld [$d72d], a
    jr jr_000_2132

jr_000_2176:
    ld a, [$d724]
    or a
    call nz, Call_000_21ec
    ld a, [$d726]
    inc a
    ld [$d726], a
    ld b, $00
    ld a, [$d726]
    ld c, a
    ld h, $ff
    ld a, [$d728]
    cpl
    ld l, a
    inc hl
    add hl, bc
    ld a, [$d72c]
    ld b, a
    ld a, [$d72d]
    ld c, a
    add hl, hl
    add hl, hl
    add hl, bc
    ld bc, $000a
    add hl, bc
    ld a, h
    ld [$d72c], a
    ld a, l
    ld [$d72d], a
    ld a, [$d728]
    dec a
    ld [$d728], a
    jp Jump_000_2132


Call_000_21b4:
    ld a, [$d725]
    ld b, a
    ld a, [$d727]
    ld c, a
    ld a, [$d726]
    ld d, a
    ld a, [$d728]
    ld e, a
    push bc
    push de
    ld a, b
    sub e
    ld h, a
    ld a, b
    add e
    ld b, a
    ld a, c
    add d
    ld c, a
    ld d, h
    ld e, c
    call Call_000_239c
    pop de
    pop bc
    ld a, d
    or a
    ret z

    push bc
    push de
    ld a, b
    sub e
    ld h, a
    ld a, b
    add e
    ld b, a
    ld a, c
    sub d
    ld c, a
    ld d, h
    ld e, c
    call Call_000_239c
    pop de
    pop bc
    ret


Call_000_21ec:
    ld a, [$d725]
    ld b, a
    ld a, [$d727]
    ld c, a
    ld a, [$d726]
    ld d, a
    ld a, [$d728]
    ld e, a
    push bc
    push de
    ld a, b
    sub e
    ld h, a
    ld a, b
    add e
    ld b, a
    ld a, c
    add d
    ld c, a
    ld d, h
    ld e, c
    call Call_000_239c
    pop de
    pop bc
    push bc
    push de
    ld a, b
    sub e
    ld h, a
    ld a, b
    add e
    ld b, a
    ld a, c
    sub d
    ld c, a
    ld d, h
    ld e, c
    call Call_000_239c
    pop de
    pop bc
    ld a, d
    sub e
    ret z

    push bc
    push de
    ld a, b
    sub d
    ld h, a
    ld a, b
    add d
    ld b, a
    ld a, c
    sub e
    ld c, a
    ld d, h
    ld e, c
    call Call_000_239c
    pop de
    pop bc
    push bc
    push de
    ld a, b
    sub d
    ld h, a
    ld a, b
    add d
    ld b, a
    ld a, c
    add e
    ld c, a
    ld d, h
    ld e, c
    call Call_000_239c
    pop de
    pop bc
    ret


Call_000_2248:
    ld a, [$d725]
    ld b, a
    ld a, [$d727]
    ld c, a
    ld a, [$d726]
    ld d, a
    ld a, [$d728]
    ld e, a
    push bc
    push de
    ld a, b
    add d
    ld b, a
    ld a, c
    sub e
    ld c, a
    call Call_000_262d
    pop de
    pop bc
    push bc
    push de
    ld a, b
    sub e
    ld b, a
    ld a, c
    sub d
    ld c, a
    call Call_000_262d
    pop de
    pop bc
    push bc
    push de
    ld a, b
    sub d
    ld b, a
    ld a, c
    add e
    ld c, a
    call Call_000_262d
    pop de
    pop bc
    push bc
    push de
    ld a, b
    add e
    ld b, a
    ld a, c
    add d
    ld c, a
    call Call_000_262d
    pop de
    pop bc
    ld a, d
    or a
    ret z

    sub e
    ret z

    push bc
    push de
    ld a, b
    sub d
    ld b, a
    ld a, c
    sub e
    ld c, a
    call Call_000_262d
    pop de
    pop bc
    push bc
    push de
    ld a, b
    sub e
    ld b, a
    ld a, c
    add d
    ld c, a
    call Call_000_262d
    pop de
    pop bc
    push bc
    push de
    ld a, b
    add d
    ld b, a
    ld a, c
    add e
    ld c, a
    call Call_000_262d
    pop de
    pop bc
    push bc
    push de
    ld a, b
    add e
    ld b, a
    ld a, c
    sub d
    ld c, a
    call Call_000_262d
    pop de
    pop bc
    ret


Call_000_22c6:
    ld a, [$d725]
    ld b, a
    ld a, [$d726]
    ld c, a
    sub b
    jr nc, jr_000_22d9

    ld a, c
    ld [$d725], a
    ld a, b
    ld [$d726], a

jr_000_22d9:
    ld a, [$d727]
    ld b, a
    ld a, [$d728]
    ld c, a
    sub b
    jr nc, jr_000_22ec

    ld a, c
    ld [$d727], a
    ld a, b
    ld [$d728], a

jr_000_22ec:
    ld a, [$d725]
    ld b, a
    ld d, a
    ld a, [$d727]
    ld c, a
    ld a, [$d728]
    ld e, a
    call Call_000_239c
    ld a, [$d726]
    ld b, a
    ld d, a
    ld a, [$d727]
    ld c, a
    ld a, [$d728]
    ld e, a
    call Call_000_239c
    ld a, [$d725]
    inc a
    ld [$d725], a
    ld a, [$d726]
    dec a
    ld [$d726], a
    ld a, [$d725]
    ld b, a
    ld a, [$d726]
    ld d, a
    ld a, [$d727]
    ld c, a
    ld e, a
    call Call_000_239c
    ld a, [$d725]
    ld b, a
    ld a, [$d726]
    ld d, a
    ld a, [$d728]
    ld c, a
    ld e, a
    call Call_000_239c
    ld a, [$d724]
    or a
    ret z

    ld a, [$d725]
    ld b, a
    ld a, [$d726]
    sub b
    ret c

    ld a, [$d727]
    inc a
    ld [$d727], a
    ld a, [$d728]
    dec a
    ld [$d728], a
    ld a, [$d727]
    ld b, a
    ld a, [$d728]
    sub b
    ret c

    ld a, [$d734]
    ld c, a
    ld a, [$d735]
    ld [$d734], a
    ld a, c
    ld [$d735], a

jr_000_236d:
    ld a, [$d725]
    ld b, a
    ld a, [$d726]
    ld d, a
    ld a, [$d727]
    ld c, a
    ld e, a
    call Call_000_239c
    ld a, [$d728]
    ld b, a
    ld a, [$d727]
    cp b
    jr z, jr_000_238d

    inc a
    ld [$d727], a
    jr jr_000_236d

jr_000_238d:
    ld a, [$d734]
    ld c, a
    ld a, [$d735]
    ld [$d734], a
    ld a, c
    ld [$d735], a
    ret


Call_000_239c:
    ld a, c
    sub e
    jr nc, jr_000_23a2

    cpl
    inc a

jr_000_23a2:
    ld [$d72a], a
    ld h, a
    ld a, b
    sub d
    jr nc, jr_000_23ac

    cpl
    inc a

jr_000_23ac:
    ld [$d729], a
    sub h
    jp c, Jump_000_2519

    ld a, b
    sub d
    jp nc, Jump_000_23c4

    ld a, c
    sub e
    jr z, jr_000_23d0

    ld a, $00
    jr nc, jr_000_23d0

    ld a, $ff
    jr jr_000_23d0

Jump_000_23c4:
    ld a, e
    sub c
    jr z, jr_000_23ce

    ld a, $00
    jr nc, jr_000_23ce

    ld a, $ff

jr_000_23ce:
    ld b, d
    ld c, e

jr_000_23d0:
    ld [$d72b], a
    ld hl, $2fbb
    ld d, $00
    ld e, c
    add hl, de
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, b
    and $f8
    ld e, a
    add hl, de
    add hl, de
    ld a, [$d72a]
    or a
    jp z, Jump_000_24bd

    push hl
    ld h, $00
    ld l, a
    add hl, hl
    ld a, h
    ld [$d72e], a
    ld a, l
    ld [$d72f], a
    ld d, h
    ld e, l
    ld a, [$d729]
    cpl
    ld l, a
    ld h, $ff
    inc hl
    add hl, de
    ld a, h
    ld [$d72c], a
    ld a, l
    ld [$d72d], a
    ld a, [$d729]
    cpl
    ld l, a
    ld h, $ff
    inc hl
    ld a, [$d72a]
    ld d, $00
    ld e, a
    add hl, de
    add hl, hl
    ld a, h
    ld [$d730], a
    ld a, l
    ld [$d731], a
    pop hl
    ld a, [$d729]
    ld e, a
    ld a, b
    and $07
    add $10
    ld c, a
    ld b, $00
    ld a, [bc]
    ld b, a
    ld c, a

Jump_000_2433:
    rrc c
    ld a, [$d72c]
    bit 7, a
    jr z, jr_000_2464

    push de
    bit 7, c
    jr z, jr_000_244b

    ld a, b
    cpl
    ld c, a
    call Call_000_264a
    dec hl
    ld c, $80
    ld b, c

jr_000_244b:
    ld a, [$d72d]
    ld d, a
    ld a, [$d72f]
    add d
    ld [$d72d], a
    ld a, [$d72c]
    ld d, a
    ld a, [$d72e]
    adc d
    ld [$d72c], a
    pop de
    jr jr_000_24a5

jr_000_2464:
    push de
    push bc
    ld a, b
    cpl
    ld c, a
    call Call_000_264a
    ld a, [$d72b]
    or a
    jr z, jr_000_247e

    inc hl
    ld a, l
    and $0f
    jr nz, jr_000_248c

    ld de, $0130
    add hl, de
    jr jr_000_248c

jr_000_247e:
    dec hl
    dec hl
    dec hl
    ld a, l
    and $0f
    xor $0e
    jr nz, jr_000_248c

    ld de, $fed0
    add hl, de

jr_000_248c:
    ld a, [$d72d]
    ld d, a
    ld a, [$d731]
    add d
    ld [$d72d], a
    ld a, [$d72c]
    ld d, a
    ld a, [$d730]
    adc d
    ld [$d72c], a
    pop bc
    ld b, c
    pop de

jr_000_24a5:
    bit 7, c
    jr z, jr_000_24b0

    push de
    ld de, $0010
    add hl, de
    pop de
    ld b, c

jr_000_24b0:
    ld a, b
    or c
    ld b, a
    dec e
    jp nz, Jump_000_2433

    ld a, b
    cpl
    ld c, a
    jp Jump_000_264a


Jump_000_24bd:
    ld a, [$d729]
    ld e, a
    inc e
    ld a, b
    and $07
    jr z, jr_000_24db

    push hl
    add $10
    ld l, a
    ld h, $00
    ld c, [hl]
    pop hl
    xor a

jr_000_24d0:
    rrca
    or c
    dec e
    jr z, jr_000_24e3

    bit 0, a
    jr z, jr_000_24d0

    jr jr_000_24e3

jr_000_24db:
    ld a, e
    dec a
    and $f8
    jr z, jr_000_250a

    jr jr_000_24ef

jr_000_24e3:
    ld b, a
    cpl
    ld c, a
    push de
    call Call_000_264a
    ld de, $000f
    add hl, de
    pop de

jr_000_24ef:
    ld a, e
    or a
    ret z

    and $f8
    jr z, jr_000_250a

    xor a
    ld c, a
    cpl
    ld b, a
    push de
    call Call_000_264a
    ld de, $000f
    add hl, de
    pop de
    ld a, e
    sub $08
    ret z

    ld e, a
    jr jr_000_24ef

jr_000_250a:
    ld a, $80

jr_000_250c:
    dec e
    jr z, jr_000_2513

    sra a
    jr jr_000_250c

jr_000_2513:
    ld b, a
    cpl
    ld c, a
    jp Jump_000_264a


Jump_000_2519:
    ld a, c
    sub e
    jp nc, Jump_000_252a

    ld a, b
    sub d
    jr z, jr_000_2536

    ld a, $00
    jr nc, jr_000_2536

    ld a, $ff
    jr jr_000_2536

Jump_000_252a:
    ld a, c
    sub e
    jr z, jr_000_2534

    ld a, $00
    jr nc, jr_000_2534

    ld a, $ff

jr_000_2534:
    ld b, d
    ld c, e

jr_000_2536:
    ld [$d72b], a
    ld hl, $2fbb
    ld d, $00
    ld e, c
    add hl, de
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, b
    and $f8
    ld e, a
    add hl, de
    add hl, de
    ld a, [$d72a]
    ld e, a
    inc e
    ld a, [$d729]
    or a
    jp z, Jump_000_260c

    push hl
    ld h, $00
    ld l, a
    add hl, hl
    ld a, h
    ld [$d72e], a
    ld a, l
    ld [$d72f], a
    ld d, h
    ld e, l
    ld a, [$d72a]
    cpl
    ld l, a
    ld h, $ff
    inc hl
    add hl, de
    ld a, h
    ld [$d72c], a
    ld a, l
    ld [$d72d], a
    ld a, [$d72a]
    cpl
    ld l, a
    ld h, $ff
    inc hl
    ld a, [$d729]
    ld d, $00
    ld e, a
    add hl, de
    add hl, hl
    ld a, h
    ld [$d730], a
    ld a, l
    ld [$d731], a
    pop hl
    ld a, [$d72a]
    ld e, a
    ld a, b
    and $07
    add $10
    ld c, a
    ld b, $00
    ld a, [bc]
    ld b, a
    ld c, a

jr_000_259e:
    push de
    push bc
    ld a, b
    cpl
    ld c, a
    call Call_000_264a
    inc hl
    ld a, l
    and $0f
    jr nz, jr_000_25b0

    ld de, $0130
    add hl, de

jr_000_25b0:
    pop bc
    ld a, [$d72c]
    bit 7, a
    jr z, jr_000_25d0

    ld a, [$d72d]
    ld d, a
    ld a, [$d72f]
    add d
    ld [$d72d], a
    ld a, [$d72c]
    ld d, a
    ld a, [$d72e]
    adc d
    ld [$d72c], a
    jr jr_000_2602

jr_000_25d0:
    ld a, [$d72b]
    or a
    jr nz, jr_000_25e2

    rlc b
    bit 0, b
    jr z, jr_000_25ec

    ld de, $fff0
    add hl, de
    jr jr_000_25ec

jr_000_25e2:
    rrc b
    bit 7, b
    jr z, jr_000_25ec

    ld de, $0010
    add hl, de

jr_000_25ec:
    ld a, [$d72d]
    ld d, a
    ld a, [$d731]
    add d
    ld [$d72d], a
    ld a, [$d72c]
    ld d, a
    ld a, [$d730]
    adc d
    ld [$d72c], a

jr_000_2602:
    pop de
    dec e
    jr nz, jr_000_259e

    ld a, b
    cpl
    ld c, a
    jp Jump_000_264a


Jump_000_260c:
    ld a, b
    and $07
    push hl
    add $10
    ld l, a
    ld h, $00
    ld a, [hl]
    pop hl
    ld b, a
    cpl
    ld c, a

jr_000_261a:
    push de
    call Call_000_264a
    inc hl
    ld a, l
    and $0f
    jr nz, jr_000_2628

    ld de, $0130
    add hl, de

jr_000_2628:
    pop de
    dec e
    ret z

    jr jr_000_261a

Call_000_262d:
    ld hl, $2fbb
    ld d, $00
    ld e, c
    add hl, de
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, b
    and $f8
    ld e, a
    add hl, de
    add hl, de
    ld a, b
    and $07
    add $10
    ld c, a
    ld b, $00
    ld a, [bc]
    ld b, a
    cpl
    ld c, a

Call_000_264a:
Jump_000_264a:
    ld a, [$d734]
    ld d, a
    ld a, [$d723]
    cp $01
    jr z, jr_000_267e

    cp $02
    jr z, jr_000_2698

    cp $03
    jr z, jr_000_26b2

    ld e, b
    bit 0, d
    jr nz, jr_000_2665

    push bc
    ld b, $00

jr_000_2665:
    bit 1, d
    jr nz, jr_000_266b

    ld e, $00

jr_000_266b:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_266b

    ld a, [hl]
    and c
    or b
    ld [hl+], a
    ld a, [hl]
    and c
    or e
    ld [hl], a
    ld a, b
    or a
    ret nz

    pop bc
    ret


jr_000_267e:
    ld c, b
    bit 0, d
    jr nz, jr_000_2685

    ld b, $00

jr_000_2685:
    bit 1, d
    jr nz, jr_000_268b

    ld c, $00

jr_000_268b:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_268b

    ld a, [hl]
    or b
    ld [hl+], a
    ld a, [hl]
    or c
    ld [hl], a
    ret


jr_000_2698:
    ld c, b
    bit 0, d
    jr nz, jr_000_269f

    ld b, $00

jr_000_269f:
    bit 1, d
    jr nz, jr_000_26a5

    ld c, $00

jr_000_26a5:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_26a5

    ld a, [hl]
    xor b
    ld [hl+], a
    ld a, [hl]
    xor c
    ld [hl], a
    ret


jr_000_26b2:
    ld b, c
    bit 0, d
    jr z, jr_000_26b9

    ld b, $ff

jr_000_26b9:
    bit 1, d
    jr z, jr_000_26bf

    ld c, $ff

jr_000_26bf:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_26bf

    ld a, [hl]
    and b
    ld [hl+], a
    ld a, [hl]
    and c
    ld [hl], a
    ret


Call_000_26cc:
    ld hl, $2fbb
    ld d, $00
    ld e, c
    add hl, de
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, b
    and $f8
    ld e, a
    add hl, de
    add hl, de
    ld a, b
    and $07
    add $10
    ld c, a
    ld b, $00
    ld a, [bc]
    ld c, a

jr_000_26e7:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_26e7

    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld e, a
    ld b, $00
    ld a, d
    and c
    jr z, jr_000_26f9

    set 0, b

jr_000_26f9:
    ld a, e
    and c
    jr z, jr_000_26ff

    set 1, b

jr_000_26ff:
    ld e, b
    ret


Call_000_2701:
    ld hl, $2fbb
    ld d, $00
    ld a, [$d733]
    rlca
    rlca
    rlca
    ld e, a
    add hl, de
    add hl, de
    ld b, [hl]
    inc hl
    ld h, [hl]
    ld l, b
    ld a, [$d732]
    rlca
    rlca
    rlca
    ld e, a
    add hl, de
    add hl, de
    ld a, c
    ld b, h
    ld c, l
    ld h, d
    ld l, a
    add hl, hl
    add hl, hl
    add hl, hl
    ld de, $3206
    add hl, de
    ld d, h
    ld e, l
    ld h, b
    ld l, c
    ld a, [$d734]
    ld c, a

jr_000_2730:
    ld a, [de]
    inc de
    push de
    push hl
    ld hl, $d735
    ld l, [hl]
    ld b, a
    xor a
    bit 0, l
    jr z, jr_000_273f

    cpl

jr_000_273f:
    or b
    bit 0, c
    jr nz, jr_000_2745

    xor b

jr_000_2745:
    ld d, a
    xor a
    bit 1, l
    jr z, jr_000_274c

    cpl

jr_000_274c:
    or b
    bit 1, c
    jr nz, jr_000_2752

    xor b

jr_000_2752:
    ld e, a
    pop hl

jr_000_2754:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_2754

    ld a, d
    ld [hl+], a
    ld a, e
    ld [hl+], a
    pop de
    ld a, l
    and $0f
    jr nz, jr_000_2730

    ret


Call_000_2765:
    ld hl, sp+$02
    ld a, [hl+]
    ld [$d732], a
    ld a, [hl+]
    ld [$d733], a
    ret


Call_000_2770:
    push bc
    ld a, [$d6ca]
    cp $01
    call nz, Call_000_2eea
    ld hl, sp+$04
    ld a, [hl]
    ld c, a
    call Call_000_2701
    call Call_000_20f4
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    call Call_000_26cc
    pop bc
    ret


Call_000_2791:
    ld hl, sp+$02
    ld a, [hl+]
    ld [$d734], a
    ld a, [hl+]
    ld [$d735], a
    ld a, [hl]
    ld [$d723], a
    ret


    push bc
    ld a, [$d6ca]
    cp $01
    call nz, Call_000_2eea
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld d, a
    ld a, [hl]
    ld [$d724], a
    call Call_000_2111
    pop bc
    ret


Call_000_27ba:
    push bc
    ld a, [$d6ca]
    cp $01
    call nz, Call_000_2eea
    ld hl, sp+$04
    ld a, [hl+]
    ld [$d725], a
    ld a, [hl+]
    ld [$d727], a
    ld a, [hl+]
    ld [$d726], a
    ld a, [hl+]
    ld [$d728], a
    ld a, [hl]
    ld [$d724], a
    call Call_000_22c6
    pop bc
    ret


Call_000_27de:
    push bc
    ld a, [$d6ca]
    cp $01
    call nz, Call_000_2eea
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld e, a
    call Call_000_239c
    pop bc
    ret


Call_000_27f6:
    push bc
    ld a, [$d6ca]
    cp $01
    call nz, Call_000_2eea
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    call Call_000_262d
    pop bc
    ret


    push bc
    ld a, [$d6ca]
    cp $01
    call nz, Call_000_2eea
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld [$d734], a
    ld a, [hl+]
    ld [$d723], a
    call Call_000_262d
    pop bc
    ret


Call_000_2826:
    jp Jump_000_2dc1


Call_000_2829:
    jp Jump_000_29e6


Call_000_282c:
    jp Jump_000_2a77


Call_000_282f:
    jp Jump_000_2b28


Call_000_2832:
    jp Jump_000_2bfc


    ld a, $05
    rst RST_08
    jp Jump_000_2bcf


    ld a, $05
    rst RST_08
    jp Jump_000_28a9


    ld a, $05
    rst RST_08
    jp Jump_000_28e9


    ld a, $05
    rst RST_08
    jp Jump_000_2ba2


    ld a, $05
    rst RST_08
    jp Jump_000_288f


    ld a, $05
    rst RST_08
    jp Jump_000_2bb1


    ld a, $05
    rst RST_08
    jp Jump_000_28cf


    ld a, $05
    rst RST_08
    jp Jump_000_289d


    ld a, $05
    rst RST_08
    jp Jump_000_28dd


    ld a, $05
    rst RST_08
    jp Jump_000_28bd


    ld a, $05
    rst RST_08
    jp Jump_000_28fd


    ld a, $05
    rst RST_08
    jp Jump_000_298f


    ld a, $05
    rst RST_08
    jp Jump_000_29ac


    ld a, $05
    rst RST_08
    jp Jump_000_29c9


    ld a, $05
    rst RST_08
    jp Jump_000_29c9


Jump_000_288f:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_290f
    ld e, c
    ld d, b
    ret


Jump_000_289d:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_290f
    ret


Jump_000_28a9:
    ld hl, $0005
    add hl, sp
    ld d, [hl]
    dec hl
    ld e, [hl]
    dec hl
    ld a, [hl]
    dec hl
    ld l, [hl]
    ld h, a
    ld b, h
    ld c, l
    call Call_000_2917
    ld e, c
    ld d, b
    ret


Jump_000_28bd:
    ld hl, $0005
    add hl, sp
    ld d, [hl]
    dec hl
    ld e, [hl]
    dec hl
    ld a, [hl]
    dec hl
    ld l, [hl]
    ld h, a
    ld b, h
    ld c, l
    call Call_000_2917
    ret


Call_000_28cf:
Jump_000_28cf:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_2949
    ld e, c
    ld d, b
    ret


Call_000_28dd:
Jump_000_28dd:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_2949
    ret


Call_000_28e9:
Jump_000_28e9:
    ld hl, $0005
    add hl, sp
    ld d, [hl]
    dec hl
    ld e, [hl]
    dec hl
    ld a, [hl]
    dec hl
    ld l, [hl]
    ld h, a
    ld b, h
    ld c, l
    call Call_000_294c
    ld e, c
    ld d, b
    ret


Call_000_28fd:
Jump_000_28fd:
    ld hl, $0005
    add hl, sp
    ld d, [hl]
    dec hl
    ld e, [hl]
    dec hl
    ld a, [hl]
    dec hl
    ld l, [hl]
    ld h, a
    ld b, h
    ld c, l
    call Call_000_294c
    ret


Call_000_290f:
    ld a, c
    rlca
    sbc a
    ld b, a
    ld a, e
    rlca
    sbc a
    ld d, a

Call_000_2917:
    ld a, b
    push af
    xor d
    push af
    bit 7, d
    jr z, jr_000_2925

    sub a
    sub e
    ld e, a
    sbc a
    sub d
    ld d, a

jr_000_2925:
    bit 7, b
    jr z, jr_000_292f

    sub a
    sub c
    ld c, a
    sbc a
    sub b
    ld b, a

jr_000_292f:
    call Call_000_294c
    ret c

    pop af
    and $80
    jr z, jr_000_293e

    sub a
    sub c
    ld c, a
    sbc a
    sub b
    ld b, a

jr_000_293e:
    pop af
    and $80
    ret z

    sub a
    sub e
    ld e, a
    sbc a
    sub d
    ld d, a
    ret


Call_000_2949:
    ld b, $00
    ld d, b

Call_000_294c:
    ld a, e
    or d
    jr nz, jr_000_2957

    ld bc, $0000
    ld d, b
    ld e, c
    scf
    ret


jr_000_2957:
    ld l, c
    ld h, b
    ld bc, $0000
    or a
    ld a, $10

jr_000_295f:
    push af
    rl l
    rl h
    rl c
    rl b
    push bc
    ld a, c
    sbc e
    ld c, a
    ld a, b
    sbc d
    ld b, a
    ccf
    jr c, jr_000_2975

    pop bc
    jr jr_000_2977

jr_000_2975:
    inc sp
    inc sp

jr_000_2977:
    jr c, jr_000_2980

    pop af
    dec a
    or a
    jr nz, jr_000_295f

    jr jr_000_2985

jr_000_2980:
    pop af
    dec a
    scf
    jr nz, jr_000_295f

jr_000_2985:
    ld d, b
    ld e, c
    rl l
    ld c, l
    rl h
    ld b, h
    or a
    ret


Call_000_298f:
Jump_000_298f:
    ld hl, $0002
    add hl, sp
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc hl
    ld a, [hl]
    ld l, c
    ld h, b

Jump_000_299e:
    or a
    ret z

    rr h
    rr l
    rr d
    rr e
    dec a
    jp Jump_000_299e


Jump_000_29ac:
    ld hl, $0002
    add hl, sp
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc hl
    ld a, [hl]
    ld l, c
    ld h, b

Jump_000_29bb:
    or a
    ret z

    sra h
    rr l
    rr d
    rr e
    dec a
    jp Jump_000_29bb


Call_000_29c9:
Jump_000_29c9:
    ld hl, $0002
    add hl, sp
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc hl
    ld a, [hl]
    ld l, c
    ld h, b

Jump_000_29d8:
    or a
    ret z

    rl e
    rl d
    rl l
    rl h
    dec a
    jp Jump_000_29d8


Jump_000_29e6:
    add sp, -$09
    ld b, $04
    ld hl, sp+$0b
    call Call_000_2abd
    jr nz, jr_000_29f9

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_2a5c


jr_000_29f9:
    ld hl, sp+$0f
    call Call_000_2abd
    jr nz, jr_000_2a0f

    ld a, $21
    ld [$d6c7], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_2a5c


jr_000_2a0f:
    ld hl, sp+$00
    xor a
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    bit 7, a
    jr z, jr_000_2a23

    ld hl, sp+$0f
    call Call_000_2d4c
    ld hl, sp+$00
    ld [hl], $01

jr_000_2a23:
    ld hl, sp+$0e
    ld a, [hl]
    bit 7, a
    jr z, jr_000_2a35

    ld hl, sp+$0b
    call Call_000_2d4c
    ld hl, sp+$00
    ld a, $01
    xor [hl]
    ld [hl], a

jr_000_2a35:
    ld hl, sp+$0f
    push hl
    ld hl, sp+$0d
    push hl
    ld hl, sp+$09
    push hl
    ld hl, sp+$07
    push hl
    call Call_000_2de0
    add sp, $08
    ld hl, sp+$00
    rr [hl]
    jr nc, jr_000_2a53

    ld b, $04
    ld hl, sp+$01
    call Call_000_2d4c

jr_000_2a53:
    ld hl, sp+$01
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_2a5c:
    add sp, $09
    ret


    ldh a, [rLCDC]
    or $10
    ldh [rLCDC], a
    ld a, $48
    ldh [rLYC], a
    ret


jr_000_2a6a:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_2a6a

    ldh a, [rLCDC]
    and $ef
    ldh [rLCDC], a
    ret


Jump_000_2a77:
    add sp, -$08
    ld b, $04
    ld hl, sp+$0a
    call Call_000_2abd
    jr nz, jr_000_2a8a

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_2aba


jr_000_2a8a:
    ld hl, sp+$0e
    call Call_000_2abd
    jr nz, jr_000_2aa0

    ld a, $21
    ld [$d6c7], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_2aba


jr_000_2aa0:
    ld hl, sp+$0e
    push hl
    ld hl, sp+$0c
    push hl
    ld hl, sp+$08
    push hl
    ld hl, sp+$06
    push hl
    call Call_000_2de0
    add sp, $08
    ld hl, sp+$00
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_2aba:
    add sp, $08
    ret


Call_000_2abd:
    xor a
    ld c, b

jr_000_2abf:
    cp [hl]
    ret nz

    inc hl
    dec c
    jr nz, jr_000_2abf

    ret


    push hl
    ld a, [hl-]
    ld c, a
    ld a, [hl]
    set 7, [hl]
    rla
    ld a, c
    rla
    pop hl
    ld [hl], a
    ret


Call_000_2ad2:
    xor a
    bit 7, [hl]
    jr z, jr_000_2ad9

    ld a, $80

jr_000_2ad9:
    cp [hl]
    ret nz

    xor a
    dec hl
    cp [hl]
    ret nz

    dec hl
    cp [hl]
    ret nz

    dec hl
    cp [hl]
    ret nz

    inc hl
    inc hl
    inc hl
    res 7, [hl]
    ret


jr_000_2aeb:
    ld c, $03

jr_000_2aed:
    ld a, [de]
    sub [hl]
    ret nz

    dec de
    dec hl
    dec c
    ret z

    jr jr_000_2aed

    ld hl, sp+$07
    call Call_000_2ad2
    ld hl, sp+$0b
    call Call_000_2ad2
    ld hl, sp+$07
    bit 7, [hl]
    jr z, jr_000_2b17

    ld hl, sp+$0b
    bit 7, [hl]
    jr z, jr_000_2b14

    ld hl, sp+$0b
    ld d, h
    ld e, l
    ld hl, sp+$07
    jr jr_000_2aeb

jr_000_2b14:
    xor a
    ccf
    ret


jr_000_2b17:
    ld hl, sp+$0b
    bit 7, [hl]
    jr z, jr_000_2b20

    xor a
    dec a
    ret


jr_000_2b20:
    ld hl, sp+$07
    ld d, h
    ld e, l
    ld hl, sp+$0b
    jr jr_000_2aeb

Jump_000_2b28:
    add sp, -$09
    ld b, $04
    ld hl, sp+$0b
    call Call_000_2abd
    jr nz, jr_000_2b3b

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_2b9f


jr_000_2b3b:
    ld hl, sp+$0f
    call Call_000_2abd
    jr nz, jr_000_2b51

    ld a, $21
    ld [$d6c7], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_2b9f


jr_000_2b51:
    ld hl, sp+$00
    xor a
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    bit 7, a
    jr z, jr_000_2b65

    ld hl, sp+$0f
    call Call_000_2d4c
    ld hl, sp+$00
    ld [hl], $01

jr_000_2b65:
    ld hl, sp+$0e
    ld a, [hl]
    bit 7, a
    jr z, jr_000_2b77

    ld hl, sp+$0b
    call Call_000_2d4c
    ld hl, sp+$00
    ld a, $01
    xor [hl]
    ld [hl], a

jr_000_2b77:
    ld hl, sp+$0f
    push hl
    ld hl, sp+$0d
    push hl
    ld hl, sp+$09
    push hl
    ld hl, sp+$07
    push hl
    call Call_000_2de0
    add sp, $08
    ld hl, sp+$00
    rr [hl]
    jr nc, jr_000_2b96

    ld b, $04
    xor a
    ld hl, sp+$05
    call Call_000_2d4c

jr_000_2b96:
    ld hl, sp+$05
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_2b9f:
    add sp, $09
    ret


Jump_000_2ba2:
    ld hl, sp+$02
    ld a, [hl+]
    ld c, a
    ld e, [hl]
    ld a, c
    rla
    sbc a
    ld b, a
    ld a, e
    rla
    sbc a
    ld d, a
    jr jr_000_2bd8

Jump_000_2bb1:
    ld hl, sp+$02
    ld a, [hl+]
    ld c, a
    ld e, [hl]

Call_000_2bb6:
    xor a
    ld h, a
    ld l, a
    ld d, a

jr_000_2bba:
    xor a
    rr c
    jr nc, jr_000_2bc0

    add hl, de

jr_000_2bc0:
    sla e
    jr z, jr_000_2bc8

    rl d
    jr jr_000_2bba

jr_000_2bc8:
    rl d
    jr nz, jr_000_2bba

    ld e, l
    ld d, h
    ret


Jump_000_2bcf:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld c, [hl]
    inc hl
    ld b, [hl]

jr_000_2bd8:
    ld hl, $0000

jr_000_2bdb:
    sra b
    jr nz, jr_000_2be8

    rr c
    jr nc, jr_000_2be4

    add hl, de

jr_000_2be4:
    jr z, jr_000_2bf9

    jr jr_000_2bed

jr_000_2be8:
    rr c
    jr nc, jr_000_2bed

    add hl, de

jr_000_2bed:
    sla e
    jr z, jr_000_2bf5

    rl d
    jr jr_000_2bdb

jr_000_2bf5:
    rl d
    jr nz, jr_000_2bdb

jr_000_2bf9:
    ld e, l
    ld d, h
    ret


Jump_000_2bfc:
    add sp, -$08
    ld b, $04
    ld hl, sp+$0a
    call Call_000_2abd
    jr nz, jr_000_2c0f

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_2c3f


jr_000_2c0f:
    ld hl, sp+$0e
    call Call_000_2abd
    jr nz, jr_000_2c25

    ld a, $21
    ld [$d6c7], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_2c3f


jr_000_2c25:
    ld hl, sp+$0e
    push hl
    ld hl, sp+$0c
    push hl
    ld hl, sp+$08
    push hl
    ld hl, sp+$06
    push hl
    call Call_000_2de0
    add sp, $08
    ld hl, sp+$04
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_2c3f:
    add sp, $08
    ret


Call_000_2c42:
    push af
    push af
    ld hl, sp+$06
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], e
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]

Jump_000_2c50:
    ld a, [bc]
    inc bc
    or a
    jp nz, Jump_000_2c50

    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b

Jump_000_2c5b:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    dec de
    dec hl
    ld [hl], e
    inc hl
    ld [hl], d
    dec hl
    ld a, [hl+]
    inc hl
    sub [hl]
    jp nz, Jump_000_2c73

    dec hl
    ld a, [hl+]
    inc hl
    sub [hl]
    jp z, Jump_000_2c85

Jump_000_2c73:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld hl, sp+$08
    sub [hl]
    jp nz, Jump_000_2c82

    jr jr_000_2c85

Jump_000_2c82:
    jp Jump_000_2c5b


Jump_000_2c85:
jr_000_2c85:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld hl, sp+$08
    sub [hl]
    jp nz, Jump_000_2c94

    jr jr_000_2c97

Jump_000_2c94:
    jp Jump_000_2c9f


jr_000_2c97:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    jp Jump_000_2ca2


Jump_000_2c9f:
    ld de, $0000

Jump_000_2ca2:
    add sp, $04
    ret


Call_000_2ca5:
    ld hl, sp+$05
    ld a, [hl+]
    ld c, a
    ld b, [hl]
    ld hl, sp+$04
    ld d, [hl]
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a

jr_000_2cb2:
    ld a, b
    or c
    ret z

    dec bc
    ld [hl], d
    inc hl
    jr jr_000_2cb2

Call_000_2cba:
    ld hl, sp+$06
    ld a, [hl+]
    ld c, a
    ld b, [hl]
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a

jr_000_2cc9:
    ld a, b
    or c
    ret z

    ld a, [de]
    inc de
    ld [hl], a
    dec bc
    inc hl
    jr jr_000_2cc9

Call_000_2cd3:
    add sp, -$07
    ld hl, sp+$09
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$0d
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$0b
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$03
    ld [hl+], a
    ld [hl], e
    inc hl
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$01
    ld [hl+], a
    ld [hl], e

Jump_000_2cf1:
    ld a, c
    or b
    jp z, Jump_000_2d1b

    ld hl, sp+$03
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$00
    ld [hl], a
    or a
    jp z, Jump_000_2d1b

    dec bc
    ld a, [hl]
    ld hl, sp+$03
    inc [hl]
    jr nz, jr_000_2d0c

    inc hl
    inc [hl]

jr_000_2d0c:
    ld hl, sp+$01
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_000_2d18

    inc hl
    inc [hl]

jr_000_2d18:
    jp Jump_000_2cf1


Jump_000_2d1b:
    ld hl, sp+$03
    ld [hl], c
    inc hl
    ld [hl], b

Jump_000_2d20:
    ld hl, sp+$03
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    dec de
    dec hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld a, c
    or b
    jp z, Jump_000_2d44

    ld hl, sp+$01
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_000_2d41

    inc hl
    inc [hl]

jr_000_2d41:
    jp Jump_000_2d20


Jump_000_2d44:
    ld hl, sp+$05
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $07
    ret


Call_000_2d4c:
    ld c, b
    xor a
    ld d, a

jr_000_2d4f:
    ld a, d
    sbc [hl]
    ld [hl+], a
    dec c
    jr nz, jr_000_2d4f

    ret


    push bc
    ld hl, sp+$04
    ld a, [hl]
    call Call_000_3bc4
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld a, [hl]
    call Call_000_3bed
    pop bc
    ret


    ld hl, sp+$02
    ld a, [hl+]
    ld [$d74c], a
    ld a, [hl]
    ld [$d74d], a
    ret


    ld a, [$d6ca]
    and $02
    jr nz, jr_000_2d7f

    push bc
    call Call_000_3d21
    pop bc

jr_000_2d7f:
    ld a, [$d74c]
    ld e, a
    ret


    ld a, [$d6ca]
    and $02
    jr nz, jr_000_2d90

    push bc
    call Call_000_3d21
    pop bc

jr_000_2d90:
    ld a, [$d74d]
    ld e, a
    ret


Call_000_2d95:
    push af
    ld hl, sp+$00
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]

Jump_000_2da2:
    ld a, [bc]
    inc bc
    or a
    jp z, Jump_000_2db2

    ld hl, sp+$00
    inc [hl]
    jr nz, jr_000_2daf

    inc hl
    inc [hl]

jr_000_2daf:
    jp Jump_000_2da2


Jump_000_2db2:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $02
    ret


Call_000_2dba:
    ld c, b
    xor a

jr_000_2dbc:
    ld [hl+], a
    dec c
    jr nz, jr_000_2dbc

    ret


Jump_000_2dc1:
    add sp, -$04
    ld hl, sp+$0a
    push hl
    ld hl, sp+$08
    push hl
    ld hl, sp+$04
    push hl
    ld b, $04
    call Call_000_2e40
    add sp, $06
    ld hl, sp+$00
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add sp, $04
    ret


    ret


Call_000_2de0:
    ld a, b
    sla a
    sla a
    sla a
    ld c, a
    push bc
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call Call_000_2dba
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call Call_000_2dba

jr_000_2df9:
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    xor a
    call Call_000_2ee2
    push af
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    pop af
    push hl
    call Call_000_2ee2
    pop de
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push de
    push hl
    call Call_000_2ed8
    pop hl
    pop de
    jr c, jr_000_2e1f

    call Call_000_2e30

jr_000_2e1f:
    ccf
    push af
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    pop af
    call Call_000_2ee2
    pop bc
    dec c
    ret z

    push bc
    jr jr_000_2df9

Call_000_2e30:
    ld c, b

jr_000_2e31:
    ld a, [de]
    sbc [hl]
    ld [de], a
    inc hl
    inc de
    dec c
    jr nz, jr_000_2e31

    ret


    ld c, b

jr_000_2e3b:
    ld [hl+], a
    dec c
    jr nz, jr_000_2e3b

    ret


Call_000_2e40:
    add sp, -$06
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$00
    ld [hl], e
    inc hl
    ld [hl], d
    ld h, d
    ld l, e
    call Call_000_2dba
    ld hl, sp+$04
    ld [hl], b

Jump_000_2e5e:
    ld hl, sp+$04
    ld a, [hl]
    ld hl, sp+$05
    ld [hl], a

jr_000_2e64:
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld c, [hl]
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld e, [hl]
    call Call_000_2bb6
    ld hl, sp+$05
    ld c, [hl]
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [hl]
    add e
    ld [hl+], a
    dec c
    jr z, jr_000_2e98

    ld a, [hl]
    adc d
    ld [hl+], a
    call Call_000_2ec3
    ld hl, sp+$05
    dec [hl]
    jr z, jr_000_2e98

    ld hl, sp+$0c
    call Call_000_2ecb
    ld hl, sp+$08
    call Call_000_2ecb
    jr jr_000_2e64

jr_000_2e98:
    ld hl, sp+$04
    dec [hl]
    jr z, jr_000_2ec0

    ld hl, sp+$00
    call Call_000_2ecb
    ld hl, sp+$0a
    call Call_000_2ecb
    push bc
    ld b, $02
    ld hl, sp+$02
    ld d, h
    ld e, l
    ld hl, sp+$0a
    call Call_000_2ed0
    ld hl, sp+$04
    ld d, h
    ld e, l
    ld hl, sp+$0e
    call Call_000_2ed0
    pop bc
    jp Jump_000_2e5e


jr_000_2ec0:
    add sp, $06
    ret


Call_000_2ec3:
jr_000_2ec3:
    dec c
    ret z

    ld a, $00
    adc [hl]
    ld [hl+], a
    jr jr_000_2ec3

Call_000_2ecb:
    inc [hl]
    ret nz

    inc hl
    inc [hl]
    ret


Call_000_2ed0:
    ld c, b

jr_000_2ed1:
    ld a, [de]
    inc de
    ld [hl+], a
    dec c
    jr nz, jr_000_2ed1

    ret


Call_000_2ed8:
    ld c, b
    xor a

jr_000_2eda:
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    dec c
    jr nz, jr_000_2eda

    ret


Call_000_2ee2:
    ld c, b

jr_000_2ee3:
    rl [hl]
    inc hl
    dec c
    jr nz, jr_000_2ee3

    ret


Call_000_2eea:
Jump_000_2eea:
    di
    ldh a, [rLCDC]
    bit 7, a
    jr z, jr_000_2ef4

    call Call_000_069f

jr_000_2ef4:
    ld hl, $8100
    ld de, $1680
    ld b, $00
    call Call_000_3d5a
    ld bc, $2a5f
    call Call_000_062e
    ld bc, $2a6a
    call Call_000_0634
    ld a, $48
    ldh [rLYC], a
    ld a, $44
    ldh [rSTAT], a
    ldh a, [rIE]
    or $02
    ldh [rIE], a
    ld hl, $9800
    ld a, $10
    ld bc, $000c
    ld e, $12

jr_000_2f23:
    ld d, $14

jr_000_2f25:
    ld [hl+], a
    inc a
    dec d
    jr nz, jr_000_2f25

    add hl, bc
    dec e
    jr nz, jr_000_2f23

    ldh a, [rLCDC]
    or $91
    and $f7
    ldh [rLCDC], a
    ld a, $01
    ld [$d6ca], a
    ld a, $00
    ld [$d723], a
    ld a, $03
    ld [$d734], a
    ld a, $00
    ld [$d735], a
    ei
    ret


Call_000_2f4c:
    ld hl, $8100
    ld de, $1680
    call Call_000_30db
    ret


Call_000_2f56:
    push de
    push hl
    ld l, b
    sla l
    sla l
    sla l
    ld h, $00
    add hl, hl
    ld d, h
    ld e, l
    ld hl, $2fbb
    sla c
    sla c
    sla c
    ld b, $00
    add hl, bc
    add hl, bc
    ld b, [hl]
    inc hl
    ld h, [hl]
    ld l, b
    add hl, de
    ld b, h
    ld c, l
    pop hl
    push bc
    ld a, h
    or l
    jr z, jr_000_2f84

    ld de, $0010
    call Call_000_30db

jr_000_2f84:
    pop hl
    pop bc
    ld de, $0010
    call Call_000_30db
    ret


    push bc
    ld a, [$d6ca]
    cp $01
    call nz, Call_000_2eea
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call Call_000_2f56
    pop bc
    ret


    push bc
    ld a, [$d6ca]
    cp $01
    call nz, Call_000_2eea
    ld hl, sp+$04
    ld a, [hl+]
    ld c, a
    ld b, [hl]
    call Call_000_2f4c
    pop bc
    ret


    nop
    add c
    ld [bc], a
    add c
    inc b
    add c
    ld b, $81
    ld [$0a81], sp
    add c
    inc c
    add c
    ld c, $81
    ld b, b
    add d
    ld b, d
    add d
    ld b, h
    add d
    ld b, [hl]
    add d
    ld c, b
    add d
    ld c, d
    add d
    ld c, h
    add d
    ld c, [hl]
    add d
    add b
    add e
    add d
    add e
    add h
    add e
    add [hl]
    add e
    adc b
    add e
    adc d
    add e
    adc h
    add e
    adc [hl]
    add e
    ret nz

    add h
    jp nz, $c484

    add h
    add $84
    ret z

    add h
    jp z, $cc84

    add h
    adc $84
    nop
    add [hl]
    ld [bc], a
    add [hl]
    inc b
    add [hl]
    ld b, $86
    ld [$0a86], sp
    add [hl]
    inc c
    add [hl]
    ld c, $86
    ld b, b
    add a
    ld b, d
    add a
    ld b, h
    add a
    ld b, [hl]
    add a
    ld c, b
    add a
    ld c, d
    add a
    ld c, h
    add a
    ld c, [hl]
    add a
    add b
    adc b
    add d
    adc b
    add h
    adc b
    add [hl]
    adc b
    adc b
    adc b
    adc d
    adc b
    adc h
    adc b
    adc [hl]
    adc b
    ret nz

    adc c
    jp nz, $c489

    adc c
    add $89
    ret z

    adc c
    jp z, $cc89

    adc c
    adc $89
    nop
    adc e
    ld [bc], a
    adc e
    inc b
    adc e
    ld b, $8b
    ld [$0a8b], sp
    adc e
    inc c
    adc e
    ld c, $8b
    ld b, b
    adc h
    ld b, d
    adc h
    ld b, h
    adc h
    ld b, [hl]
    adc h
    ld c, b
    adc h
    ld c, d
    adc h
    ld c, h
    adc h
    ld c, [hl]
    adc h
    add b
    adc l
    add d
    adc l
    add h
    adc l
    add [hl]
    adc l
    adc b
    adc l
    adc d
    adc l
    adc h
    adc l
    adc [hl]
    adc l
    ret nz

    adc [hl]
    jp nz, $c48e

    adc [hl]
    add $8e
    ret z

    adc [hl]
    jp z, $cc8e

    adc [hl]
    adc $8e
    nop
    sub b
    ld [bc], a
    sub b
    inc b
    sub b
    ld b, $90
    ld [$0a90], sp
    sub b
    inc c
    sub b
    ld c, $90
    ld b, b
    sub c
    ld b, d
    sub c
    ld b, h
    sub c
    ld b, [hl]
    sub c
    ld c, b
    sub c
    ld c, d
    sub c
    ld c, h
    sub c
    ld c, [hl]
    sub c
    add b
    sub d
    add d
    sub d
    add h
    sub d
    add [hl]
    sub d
    adc b
    sub d
    adc d
    sub d
    adc h
    sub d
    adc [hl]
    sub d
    ret nz

    sub e
    jp nz, $c493

    sub e
    add $93
    ret z

    sub e
    jp z, $cc93

    sub e
    adc $93
    nop
    sub l
    ld [bc], a
    sub l
    inc b
    sub l
    ld b, $95
    ld [$0a95], sp
    sub l
    inc c
    sub l
    ld c, $95
    ld b, b
    sub [hl]
    ld b, d
    sub [hl]
    ld b, h
    sub [hl]
    ld b, [hl]
    sub [hl]
    ld c, b
    sub [hl]
    ld c, d
    sub [hl]
    ld c, h
    sub [hl]
    ld c, [hl]
    sub [hl]

Call_000_30db:
jr_000_30db:
    ldh a, [rSTAT]
    and $02
    jr nz, jr_000_30db

    ld a, [bc]
    ld [hl+], a
    inc bc
    dec de
    ld a, d
    or e
    jr nz, jr_000_30db

    ret


Call_000_30ea:
    push bc
    ld hl, sp+$09
    ld d, [hl]
    dec hl
    ld e, [hl]
    dec hl
    ld b, [hl]
    dec hl
    ld c, [hl]
    dec hl
    ld a, [hl-]
    ld l, [hl]
    ld h, a
    call Call_000_30db
    pop bc
    ret


    ld hl, $3104
    call Call_000_3b27
    ret


    inc b
    rst RST_38
    nop
    ld bc, $0302
    inc b
    dec b
    ld b, $07
    ld [$0a09], sp
    dec bc
    inc c
    dec c
    ld c, $0f
    db $10
    ld de, $1312
    inc d
    dec d
    ld d, $17
    jr jr_000_3139

    ld a, [de]
    dec de
    inc e
    dec e
    ld e, $1f
    jr nz, jr_000_3149

    ld [hl+], a
    inc hl
    inc h
    dec h
    ld h, $27
    jr z, jr_000_3159

    ld a, [hl+]
    dec hl
    inc l
    dec l
    ld l, $2f
    jr nc, jr_000_3169

    ld [hl-], a

jr_000_3139:
    inc sp
    inc [hl]
    dec [hl]
    ld [hl], $37
    jr c, jr_000_3179

    ld a, [hl-]
    dec sp
    inc a
    dec a
    ld a, $3f
    ld b, b
    ld b, c
    ld b, d

jr_000_3149:
    ld b, e
    ld b, h
    ld b, l
    ld b, [hl]
    ld b, a
    ld c, b
    ld c, c
    ld c, d
    ld c, e
    ld c, h
    ld c, l
    ld c, [hl]
    ld c, a
    ld d, b
    ld d, c
    ld d, d

jr_000_3159:
    ld d, e
    ld d, h
    ld d, l
    ld d, [hl]
    ld d, a
    ld e, b
    ld e, c
    ld e, d
    ld e, e
    ld e, h
    ld e, l
    ld e, [hl]
    ld e, a
    ld h, b
    ld h, c
    ld h, d

jr_000_3169:
    ld h, e
    ld h, h
    ld h, l
    ld h, [hl]
    ld h, a
    ld l, b
    ld l, c
    ld l, d
    ld l, e
    ld l, h
    ld l, l
    ld l, [hl]
    ld l, a
    ld [hl], b
    ld [hl], c
    ld [hl], d

jr_000_3179:
    ld [hl], e
    ld [hl], h
    ld [hl], l
    halt
    ld [hl], a
    ld a, b
    ld a, c
    ld a, d
    ld a, e
    ld a, h
    ld a, l
    ld a, [hl]
    ld a, a
    add b
    add c
    add d
    add e
    add h
    add l
    add [hl]
    add a
    adc b
    adc c
    adc d
    adc e
    adc h
    adc l
    adc [hl]
    adc a
    sub b
    sub c
    sub d
    sub e
    sub h
    sub l
    sub [hl]
    sub a
    sbc b
    sbc c
    sbc d
    sbc e
    sbc h
    sbc l
    sbc [hl]
    sbc a
    and b
    and c
    and d
    and e
    and h
    and l
    and [hl]
    and a
    xor b
    xor c
    xor d
    xor e
    xor h
    xor l
    xor [hl]
    xor a
    or b
    or c
    or d
    or e
    or h
    or l
    or [hl]
    or a
    cp b
    cp c
    cp d
    cp e
    cp h
    cp l
    cp [hl]
    cp a
    ret nz

    pop bc
    jp nz, $c4c3

    push bc
    add $c7
    ret z

    ret


    jp z, $cccb

    call $cfce
    ret nc

    pop de
    jp nc, $d4d3

    push de
    sub $d7
    ret c

    reti


    jp c, $dcdb

    db $dd
    sbc $df
    ldh [$ffe1], a
    ldh [c], a
    db $e3
    db $e4
    push hl
    and $e7
    add sp, -$17
    ld [$eceb], a
    db $ed
    xor $ef
    ldh a, [$fff1]
    ldh a, [c]
    di
    db $f4
    push af
    or $f7
    ld hl, sp-$07
    ld a, [$fcfb]
    db $fd
    cp $ff
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr jr_000_3234

    ld b, d
    add c
    rst RST_20
    inc h
    inc h
    inc a
    inc a
    inc h
    inc h
    rst RST_20
    add c
    ld b, d
    inc h
    jr @+$1a

    inc d
    ldh a, [c]
    add c
    add c
    ldh a, [c]
    inc d
    jr jr_000_323f

    jr z, jr_000_3278

    add c
    add c
    ld c, a
    jr z, jr_000_3246

    rst RST_38
    add c
    add c
    add c
    add c
    add c

jr_000_3234:
    add c
    rst RST_38
    ld hl, sp-$78
    adc a
    adc c
    ld sp, hl
    ld b, c
    ld b, c
    ld a, a
    rst RST_38

jr_000_323f:
    adc c
    adc c
    adc c
    ld sp, hl
    add c
    add c
    rst RST_38

jr_000_3246:
    ld bc, $0603
    adc h
    ret c

    ld [hl], b
    jr nz, jr_000_324e

jr_000_324e:
    ld a, [hl]
    jp $d3d3


    db $db
    jp $7ec3


    jr jr_000_3294

    inc l
    inc l
    ld a, [hl]
    jr jr_000_3275

    nop
    db $10
    inc e
    ld [de], a
    db $10
    db $10
    ld [hl], b
    ldh a, [$ff60]
    ldh a, [$ffc0]
    cp $d8
    sbc $18
    jr jr_000_326e

jr_000_326e:
    ld [hl], b
    ret z

    sbc $db
    db $db
    ld a, [hl]
    dec de

jr_000_3275:
    dec de
    nop
    nop

jr_000_3278:
    nop
    rst RST_38
    rst RST_38
    rst RST_38
    nop
    nop
    inc e
    inc e
    inc e
    inc e
    inc e
    inc e
    inc e
    inc e
    ld a, h
    add $c6
    nop
    add $c6
    ld a, h
    nop
    ld b, $06
    ld b, $00
    ld b, $06

jr_000_3294:
    ld b, $00
    ld a, h
    ld b, $06
    ld a, h
    ret nz

    ret nz

    ld a, h
    nop
    ld a, h
    ld b, $06
    ld a, h
    ld b, $06
    ld a, h
    nop
    add $c6
    add $7c
    ld b, $06
    ld b, $00
    ld a, h
    ret nz

    ret nz

    ld a, h
    ld b, $06
    ld a, h
    nop
    ld a, h
    ret nz

    ret nz

    ld a, h
    add $c6
    ld a, h
    nop
    ld a, h
    ld b, $06
    nop
    ld b, $06
    ld b, $00
    ld a, h
    add $c6
    ld a, h
    add $c6
    ld a, h
    nop
    ld a, h
    add $c6
    ld a, h
    ld b, $06
    ld a, h
    nop
    nop
    inc a
    ld b, [hl]
    ld b, $7e
    ld h, [hl]
    inc a
    nop
    ld a, b
    ld h, [hl]
    ld a, l
    ld h, h
    ld a, [hl]
    inc bc
    dec bc
    ld b, $00
    nop
    nop
    rra
    rra
    rra
    inc e
    inc e
    nop
    nop
    nop
    db $fc
    db $fc
    db $fc
    inc e
    inc e
    inc e
    inc e
    inc e
    rra
    rra
    rra
    nop
    nop
    inc e
    inc e
    inc e
    db $fc
    db $fc
    db $fc
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr @+$1a

    jr jr_000_332a

    jr jr_000_3314

jr_000_3314:
    jr jr_000_3316

jr_000_3316:
    ld h, [hl]
    ld h, [hl]
    ld b, h
    nop
    nop
    nop
    nop
    nop
    nop
    inc h
    ld a, [hl]
    inc h
    inc h
    ld a, [hl]
    inc h
    nop
    inc d
    ld a, $55
    inc a

jr_000_332a:
    ld e, $55
    ld a, $14
    ld h, d
    ld h, [hl]
    inc c
    jr @+$32

    ld h, [hl]
    ld b, [hl]
    nop
    ld a, b
    call z, $ce61
    call z, $78cc
    nop
    jr jr_000_3358

    stop
    nop
    nop
    nop
    nop
    inc b
    ld [$1818], sp
    jr jr_000_3364

    ld [$2004], sp
    db $10
    jr jr_000_336a

    jr @+$1a

    db $10
    jr nz, jr_000_3357

jr_000_3357:
    ld d, h

jr_000_3358:
    jr c, jr_000_3358

    jr c, jr_000_33b0

    nop
    nop
    nop
    jr jr_000_3379

    ld a, [hl]
    jr @+$1a

jr_000_3364:
    nop
    nop
    nop
    nop
    nop
    nop

jr_000_336a:
    nop
    jr nc, jr_000_339d

    jr nz, jr_000_336f

jr_000_336f:
    nop
    nop
    inc a
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_000_3379:
    nop
    nop
    jr @+$1a

    nop
    inc bc
    ld b, $0c
    jr jr_000_33b3

    ld h, b
    ret nz

    nop
    inc a
    ld h, [hl]
    ld l, [hl]
    halt
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    jr jr_000_33c8

    jr jr_000_33aa

    jr jr_000_33ac

    jr jr_000_3396

jr_000_3396:
    inc a
    ld h, [hl]
    ld c, $1c
    jr c, jr_000_340c

    ld a, [hl]

jr_000_339d:
    nop
    ld a, [hl]
    inc c
    jr jr_000_33de

    ld b, $46
    inc a
    nop
    inc c
    inc e
    inc l
    ld c, h

jr_000_33aa:
    ld a, [hl]
    inc c

jr_000_33ac:
    inc c
    nop
    ld a, [hl]
    ld h, b

jr_000_33b0:
    ld a, h
    ld b, $06

jr_000_33b3:
    ld b, [hl]
    inc a
    nop
    inc e
    jr nz, jr_000_3419

    ld a, h
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    ld a, [hl]
    ld b, $0e
    inc e
    jr @+$1a

    jr jr_000_33c6

jr_000_33c6:
    inc a
    ld h, [hl]

jr_000_33c8:
    ld h, [hl]
    inc a
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    inc a
    ld h, [hl]
    ld h, [hl]
    ld a, $06
    inc c
    jr c, jr_000_33d6

jr_000_33d6:
    nop
    jr jr_000_33f1

    nop
    nop
    jr jr_000_33f5

    nop

jr_000_33de:
    nop
    jr jr_000_33f9

    nop
    jr jr_000_33fc

    stop
    ld b, $0c
    jr jr_000_341a

    jr @+$0e

    ld b, $00
    nop
    nop
    inc a

jr_000_33f1:
    nop
    nop
    inc a
    nop

jr_000_33f5:
    nop
    ld h, b
    jr nc, jr_000_3411

jr_000_33f9:
    inc c
    jr jr_000_342c

jr_000_33fc:
    ld h, b
    nop
    inc a
    ld b, [hl]
    ld b, $0c
    jr jr_000_341c

    nop
    jr jr_000_3443

    ld h, [hl]
    ld l, [hl]
    ld l, d
    ld l, [hl]
    ld h, b

jr_000_340c:
    inc a
    nop
    inc a
    ld h, [hl]
    ld h, [hl]

jr_000_3411:
    ld a, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    nop
    ld a, h
    ld h, [hl]
    ld h, [hl]

jr_000_3419:
    ld a, h

jr_000_341a:
    ld h, [hl]
    ld h, [hl]

jr_000_341c:
    ld a, h
    nop
    inc a
    ld h, d
    ld h, b
    ld h, b
    ld h, b
    ld h, d
    inc a
    nop
    ld a, h
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]

jr_000_342c:
    ld a, h
    nop
    ld a, [hl]
    ld h, b
    ld h, b
    ld a, h
    ld h, b
    ld h, b
    ld a, [hl]
    nop
    ld a, [hl]
    ld h, b
    ld h, b
    ld a, h
    ld h, b
    ld h, b
    ld h, b
    nop
    inc a
    ld h, d
    ld h, b
    ld l, [hl]
    ld h, [hl]

jr_000_3443:
    ld h, [hl]
    ld a, $00
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld a, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    nop
    jr jr_000_3468

    jr jr_000_346a

    jr jr_000_346c

    jr jr_000_3456

jr_000_3456:
    ld b, $06
    ld b, $06
    ld b, $46
    inc a
    nop
    ld h, [hl]
    ld l, h
    ld a, b
    ld [hl], b
    ld a, b
    ld l, h
    ld h, [hl]
    nop
    ld h, b
    ld h, b

jr_000_3468:
    ld h, b
    ld h, b

jr_000_346a:
    ld h, b
    ld h, b

jr_000_346c:
    ld a, h
    nop
    db $fc
    sub $d6
    sub $d6
    add $c6
    nop
    ld h, d
    ld [hl], d
    ld a, d
    ld e, [hl]
    ld c, [hl]
    ld b, [hl]
    ld b, d
    nop
    inc a
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    ld a, h
    ld h, [hl]
    ld h, [hl]
    ld a, h
    ld h, b
    ld h, b
    ld h, b
    nop
    inc a
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    ld b, $7c
    ld h, [hl]
    ld h, [hl]
    ld a, h
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    nop
    inc a
    ld h, d
    ld [hl], b
    inc a
    ld c, $46
    inc a
    nop
    ld a, [hl]
    jr @+$1a

    jr @+$1a

    jr jr_000_34c5

    nop
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, h
    ld a, b
    nop
    add $c6
    add $d6
    sub $d6
    db $fc

jr_000_34c5:
    nop
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    nop
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    jr @+$1a

    jr jr_000_34d6

jr_000_34d6:
    ld a, [hl]
    ld c, $1c
    jr c, jr_000_354b

    ld h, b
    ld a, [hl]
    nop
    ld e, $18
    jr jr_000_34fa

    jr jr_000_34fc

    ld e, $00
    ld b, b
    ld h, b
    jr nc, jr_000_3502

    inc c
    ld b, $02
    nop
    ld a, b
    jr jr_000_3509

    jr jr_000_350b

    jr jr_000_356d

    nop
    db $10
    jr c, jr_000_3565

    nop

jr_000_34fa:
    nop
    nop

jr_000_34fc:
    nop
    nop
    nop
    nop
    nop
    nop

jr_000_3502:
    nop
    nop
    ld a, [hl]
    nop
    nop
    ret nz

    ret nz

jr_000_3509:
    ld h, b
    nop

jr_000_350b:
    nop
    nop
    nop
    nop
    inc a
    ld b, [hl]
    ld a, $66
    ld h, [hl]
    ld a, $00
    ld h, b
    ld a, h
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld a, h
    nop
    nop
    inc a
    ld h, d
    ld h, b
    ld h, b
    ld h, d
    inc a
    nop
    ld b, $3e
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld a, $00
    nop
    inc a
    ld h, [hl]
    ld a, [hl]
    ld h, b
    ld h, d
    inc a
    nop
    ld e, $30
    ld a, h
    jr nc, @+$32

    jr nc, jr_000_356d

    nop
    nop
    ld a, $66
    ld h, [hl]
    ld h, [hl]
    ld a, $46
    inc a
    ld h, b
    ld a, h
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]

jr_000_354b:
    ld h, [hl]
    ld h, [hl]
    nop
    jr jr_000_3550

jr_000_3550:
    jr jr_000_356a

    jr jr_000_356c

    jr jr_000_3556

jr_000_3556:
    nop
    ld [$1818], sp
    jr jr_000_3574

    ld e, b
    jr nc, jr_000_35bf

    ld h, h
    ld l, b
    ld [hl], b
    ld a, b
    ld l, h
    ld h, [hl]

jr_000_3565:
    nop
    jr jr_000_3580

    jr jr_000_3582

jr_000_356a:
    jr jr_000_3584

jr_000_356c:
    inc c

jr_000_356d:
    nop
    nop
    db $fc
    sub $d6
    sub $d6

jr_000_3574:
    add $00
    nop
    ld a, h
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    nop
    nop
    inc a

jr_000_3580:
    ld h, [hl]
    ld h, [hl]

jr_000_3582:
    ld h, [hl]
    ld h, [hl]

jr_000_3584:
    inc a
    nop
    nop
    ld a, h
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld a, h
    ld h, b
    ld h, b
    nop
    ld a, $66
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld a, $06
    nop
    ld l, h
    ld [hl], b
    ld h, b
    ld h, b
    ld h, b
    ld h, b
    nop
    nop
    inc a
    ld [hl], d
    jr c, jr_000_35bf

    ld c, [hl]
    inc a
    nop
    jr jr_000_35e4

    jr @+$1a

    jr @+$1a

    inc c
    nop
    nop
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld a, $00
    nop
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, h
    ld a, b
    nop
    nop

jr_000_35bf:
    add $c6
    sub $d6
    sub $fc
    nop
    nop
    ld h, [hl]
    ld h, [hl]
    inc a
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    nop
    nop
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, $1e
    ld b, [hl]
    inc a
    nop
    ld a, [hl]
    ld c, $1c
    jr c, jr_000_364c

    ld a, [hl]
    nop
    ld c, $18
    jr jr_000_3612

    jr jr_000_35fc

jr_000_35e4:
    ld c, $00
    jr jr_000_3600

    jr jr_000_3602

    jr jr_000_3604

    jr @+$1a

    ld [hl], b
    jr jr_000_3609

    inc c
    jr jr_000_360c

    ld [hl], b
    nop
    nop
    ld h, b
    ldh a, [c]
    sbc [hl]
    inc c
    nop

jr_000_35fc:
    nop
    nop
    db $10
    db $10

jr_000_3600:
    jr z, jr_000_362a

jr_000_3602:
    ld b, h
    ld b, h

jr_000_3604:
    add d
    cp $3c
    ld h, d
    ld h, b

jr_000_3609:
    ld h, b
    ld h, b
    ld h, d

jr_000_360c:
    inc e
    jr nc, @+$26

    nop
    ld h, [hl]
    ld h, [hl]

jr_000_3612:
    ld h, [hl]
    ld h, [hl]
    ld a, $00
    inc c
    jr jr_000_3619

jr_000_3619:
    inc a
    ld a, [hl]
    ld h, b
    inc a
    nop
    jr jr_000_3686

    nop
    inc a
    ld b, $7e
    ld a, $00
    inc h
    nop
    inc a
    ld b, [hl]

jr_000_362a:
    ld a, $46
    ld a, $00
    jr nc, jr_000_3648

    nop
    inc a
    ld b, $7e
    ld a, $00
    jr jr_000_3650

    nop
    inc a
    ld b, $7e
    ld a, $00
    nop
    inc a
    ld h, d
    ld h, b
    ld h, d
    inc a
    ld [$1818], sp
    inc [hl]

jr_000_3648:
    nop
    inc a
    ld a, [hl]
    ld h, b

jr_000_364c:
    ld a, $00
    inc h
    nop

jr_000_3650:
    inc a
    ld h, [hl]
    ld a, [hl]
    ld h, b
    ld a, $00
    jr nc, @+$1a

    nop
    inc a
    ld a, [hl]
    ld h, b
    inc a
    nop
    inc h
    nop
    jr jr_000_367a

    jr jr_000_367c

    jr jr_000_3666

jr_000_3666:
    jr jr_000_368c

    nop
    jr jr_000_3683

    jr jr_000_3685

    nop
    db $10
    ld [$1800], sp
    jr jr_000_368c

    jr jr_000_3676

jr_000_3676:
    inc h
    nop
    inc a
    ld h, [hl]

jr_000_367a:
    ld a, [hl]
    ld h, [hl]

jr_000_367c:
    ld h, [hl]
    nop
    jr jr_000_3680

jr_000_3680:
    inc a
    ld h, [hl]
    ld a, [hl]

jr_000_3683:
    ld h, [hl]
    ld h, [hl]

jr_000_3685:
    nop

jr_000_3686:
    inc c
    jr jr_000_3707

    ld h, b
    ld a, h
    ld h, b

jr_000_368c:
    ld a, [hl]
    nop
    nop
    nop
    ld a, [hl]
    dec de
    ld a, a
    ret c

    ld a, [hl]
    nop
    ccf
    ld a, b
    ret c

    sbc $f8
    ret c

    rst RST_18
    nop
    jr jr_000_36d4

    nop
    inc a
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    inc h
    nop
    inc a
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    jr nc, jr_000_36c8

    nop
    inc a
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    jr jr_000_36dc

    nop
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    jr nc, jr_000_36d8

    nop
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    ld h, [hl]
    nop

jr_000_36c8:
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld a, $46
    inc a
    ld h, [hl]
    nop
    inc a
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]

jr_000_36d4:
    inc a
    nop
    ld h, [hl]
    nop

jr_000_36d8:
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]

jr_000_36dc:
    inc a
    nop
    jr jr_000_371c

    ld h, d
    ld h, b
    ld h, b
    ld h, d
    inc a
    jr @+$1e

    ld a, [hl-]
    jr nc, jr_000_3766

    jr nc, jr_000_371c

    ld a, [hl]
    nop
    ld h, [hl]
    ld h, [hl]
    inc a
    jr jr_000_372f

    jr @+$1a

    nop
    inc a
    ld h, [hl]
    ld h, [hl]
    ld l, h
    ld h, [hl]
    ld h, [hl]
    db $ec
    nop
    jr @+$1a

    jr jr_000_371a

    jr jr_000_371c

    jr jr_000_371e

    inc c

jr_000_3707:
    jr jr_000_3709

jr_000_3709:
    inc a
    ld b, $7e
    ld a, $00
    inc c
    jr jr_000_3711

jr_000_3711:
    jr jr_000_372b

    jr jr_000_372d

    nop
    inc c
    jr jr_000_3719

jr_000_3719:
    inc a

jr_000_371a:
    ld h, [hl]
    ld h, [hl]

jr_000_371c:
    inc a
    nop

jr_000_371e:
    inc c
    jr jr_000_3721

jr_000_3721:
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld a, $00
    inc [hl]
    ld e, b
    nop
    ld a, h
    ld h, [hl]

jr_000_372b:
    ld h, [hl]
    ld h, [hl]

jr_000_372d:
    nop
    ld a, [de]

jr_000_372f:
    inc l
    ld h, d
    ld [hl], d
    ld e, d
    ld c, [hl]
    ld b, [hl]
    nop
    nop
    inc a
    ld b, [hl]
    ld a, $66
    ld a, $00
    ld a, [hl]
    nop
    inc a
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    ld a, [hl]
    nop
    jr jr_000_3749

jr_000_3749:
    jr jr_000_377b

    ld h, b
    ld h, [hl]
    inc a
    nop
    nop
    nop
    ld a, $30
    jr nc, jr_000_3785

    nop
    nop
    nop
    nop
    ld a, h
    inc c
    inc c
    inc c
    nop
    ld h, d
    db $e4
    ld l, b
    halt
    dec hl
    ld b, e
    add [hl]
    rrca

jr_000_3766:
    ld h, d
    db $e4
    ld l, b
    halt
    ld l, $56
    sbc a
    ld b, $00
    jr jr_000_3771

jr_000_3771:
    jr @+$1a

    jr @+$1a

    jr jr_000_3792

    ld [hl], $6c
    ret c

    ld l, h

jr_000_377b:
    ld [hl], $1b
    nop
    ret c

    ld l, h
    ld [hl], $1b
    ld [hl], $6c
    ret c

jr_000_3785:
    nop
    inc [hl]
    ld e, b
    nop
    inc a
    ld b, $7e
    ld a, $00
    inc [hl]
    ld e, b
    nop
    inc a

jr_000_3792:
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    ld [bc], a
    inc a
    ld h, [hl]
    ld l, [hl]
    halt
    ld h, [hl]
    inc a
    ld b, b
    nop
    ld [bc], a
    inc a
    ld l, [hl]
    halt
    ld h, [hl]
    inc a
    ld b, b
    nop
    nop
    ld a, [hl]
    db $db
    sbc $d8
    ld a, a
    nop
    nop
    ld a, [hl]
    ret c

    ret c

    db $fc
    ret c

    ret c

    sbc $20
    db $10
    inc a
    ld h, [hl]
    ld h, [hl]
    ld a, [hl]
    ld h, [hl]
    ld h, [hl]
    inc [hl]
    ld e, b
    inc a
    ld h, [hl]
    ld h, [hl]
    ld a, [hl]
    ld h, [hl]
    ld h, [hl]
    inc [hl]
    ld e, b
    inc a
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    ld h, [hl]
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    inc c
    jr @+$32

    nop
    nop
    nop
    nop
    nop
    nop
    db $10
    jr c, jr_000_37f2

    db $10
    stop
    nop
    ld a, d
    jp z, $caca

    ld a, d
    ld a, [bc]
    ld a, [bc]
    ld a, [bc]
    inc a
    ld b, d
    sbc c
    or l

jr_000_37f2:
    or c
    sbc l
    ld b, d
    inc a
    inc a
    ld b, d
    cp c
    or l
    cp c
    or l
    ld b, d
    inc a
    pop af
    ld e, e
    ld d, l
    ld d, c
    ld d, c
    nop
    nop
    nop
    ld h, [hl]
    nop
    and $66
    ld h, [hl]
    or $06
    inc e
    or $66
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    or $06
    inc e
    nop
    ld h, [hl]
    halt
    inc a
    ld l, [hl]
    ld h, [hl]
    nop
    nop
    nop
    ld a, h
    inc c
    inc c
    inc c
    ld a, [hl]
    nop
    nop
    nop
    ld e, $06
    ld c, $1e
    ld [hl], $00
    nop
    nop
    ld a, [hl]
    inc c
    inc c
    inc c
    inc c
    nop
    nop
    nop
    ld a, h
    ld b, $66
    ld h, [hl]
    ld h, [hl]
    nop
    nop
    nop
    inc e
    inc c
    inc c
    inc c
    inc c
    nop
    nop
    nop
    ld e, $0c
    ld b, $06
    ld b, $00
    nop
    nop
    ld a, [hl]
    ld [hl], $36
    ld [hl], $36
    nop
    nop
    ld h, b
    ld l, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld a, [hl]
    nop
    nop
    nop
    inc a
    inc c
    inc c
    nop
    nop
    nop
    nop
    nop
    ld a, $06
    ld b, $06
    ld a, $00
    nop
    ld h, b
    ld a, [hl]
    ld b, $06
    ld b, $0e
    nop
    nop
    nop
    ld l, h
    ld a, $66
    ld h, [hl]
    ld l, [hl]
    nop
    nop
    nop
    inc e
    inc c
    inc c
    inc c
    inc a
    nop
    nop
    nop
    ld a, $36
    ld [hl], $36
    inc e
    nop
    nop
    nop
    ld [hl], $36
    ld [hl], $36
    ld a, [hl]
    nop
    nop
    nop
    ld a, [hl]
    ld h, [hl]
    halt
    ld b, $7e
    nop
    nop
    nop
    ld h, [hl]
    ld h, [hl]
    inc a
    ld c, $7e
    nop
    nop
    nop
    ld a, $06
    ld [hl], $36
    inc [hl]
    jr nc, jr_000_38ae

jr_000_38ae:
    nop
    ld a, b
    inc c
    inc c
    inc c
    inc c
    nop
    nop
    nop
    sub $d6
    sub $d6
    cp $00
    nop
    nop
    ld a, h
    ld l, h
    ld l, h
    ld l, h
    db $ec
    nop
    nop
    nop
    inc e
    inc c
    inc c
    inc c
    inc c
    inc c
    nop
    nop
    ld a, $06
    ld b, $06
    ld b, $06
    nop
    nop
    cp $66
    ld h, [hl]
    ld h, [hl]
    ld a, [hl]
    nop
    nop
    nop
    ld a, [hl]
    ld h, [hl]
    halt
    ld b, $06
    ld b, $00
    nop
    ld [hl], $36
    inc e
    inc c
    inc c
    inc c
    nop
    inc e
    ld [hl-], a
    inc a
    ld h, [hl]
    ld h, [hl]
    inc a
    ld c, h
    jr c, jr_000_38f7

jr_000_38f7:
    db $10
    jr c, jr_000_3966

    add $82
    nop
    nop
    ld h, [hl]
    rst RST_30
    sbc c
    sbc c
    rst RST_28
    ld h, [hl]
    nop
    nop
    nop
    nop
    halt
    call c, $dcc8
    halt
    nop
    inc e
    ld [hl], $66
    ld a, h
    ld h, [hl]
    ld h, [hl]
    ld a, h
    ld h, b
    nop
    cp $66
    ld h, d
    ld h, b
    ld h, b
    ld h, b
    ld hl, sp+$00
    nop
    cp $6c
    ld l, h
    ld l, h
    ld l, h
    ld c, b
    cp $66
    jr nc, @+$1a

    jr nc, @+$68

    cp $00
    nop
    ld e, $38
    ld l, h
    ld l, h
    ld l, h
    jr c, jr_000_3936

jr_000_3936:
    nop
    nop
    ld l, h
    ld l, h
    ld l, h
    ld l, h
    ld a, a
    ret nz

    nop
    nop
    ld a, [hl]
    jr jr_000_395b

    jr jr_000_395d

    db $10
    inc a
    jr jr_000_3985

    ld h, [hl]
    ld h, [hl]
    inc a
    jr jr_000_398a

    nop
    inc a
    ld h, [hl]
    ld a, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    nop
    inc a
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]

jr_000_395b:
    inc h
    ld h, [hl]

jr_000_395d:
    nop
    inc e
    ld [hl], $78
    call c, $eccc
    ld a, b
    nop

jr_000_3966:
    inc c
    jr jr_000_39a1

    ld d, h
    ld d, h
    jr c, jr_000_399d

    ld h, b
    nop
    db $10
    ld a, h
    sub $d6
    sub $7c
    db $10
    ld a, $70
    ld h, b
    ld a, [hl]
    ld h, b
    ld [hl], b
    ld a, $00
    inc a
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]

jr_000_3985:
    nop
    nop
    ld a, [hl]
    nop
    ld a, [hl]

jr_000_398a:
    nop
    ld a, [hl]
    nop
    nop
    jr @+$1a

    ld a, [hl]
    jr @+$1a

    nop
    ld a, [hl]
    nop
    jr nc, jr_000_39b0

    inc c
    jr jr_000_39cb

    nop
    ld a, [hl]

jr_000_399d:
    nop
    inc c
    jr @+$32

jr_000_39a1:
    jr @+$0e

    nop
    ld a, [hl]
    nop
    nop
    ld c, $1b
    dec de
    jr jr_000_39c4

    jr jr_000_39c6

    jr jr_000_39c8

jr_000_39b0:
    jr jr_000_39ca

    ret c

    ret c

    ld [hl], b
    nop
    jr jr_000_39d0

    nop
    ld a, [hl]
    nop

jr_000_39bb:
    jr jr_000_39d5

    nop
    nop
    ld [hl-], a
    ld c, h
    nop
    ld [hl-], a
    ld c, h

jr_000_39c4:
    nop
    nop

jr_000_39c6:
    jr c, @+$6e

jr_000_39c8:
    jr c, jr_000_39ca

jr_000_39ca:
    nop

jr_000_39cb:
    nop
    nop
    nop
    jr c, @+$7e

jr_000_39d0:
    jr c, jr_000_39d2

jr_000_39d2:
    nop
    nop
    nop

jr_000_39d5:
    nop
    nop
    nop
    nop
    nop
    jr jr_000_39f4

    nop
    nop
    nop
    nop
    rrca
    jr jr_000_39bb

    ld [hl], b
    jr nc, jr_000_39e6

jr_000_39e6:
    jr c, @+$6e

    ld l, h
    ld l, h
    ld l, h
    nop
    nop
    nop
    jr c, @+$6e

    jr jr_000_3a22

    ld a, h
    nop

jr_000_39f4:
    nop
    nop
    ld a, b
    inc c
    jr c, jr_000_3a06

    ld a, b
    nop
    nop
    nop
    nop
    cp $00
    nop
    nop
    nop
    nop
    nop

jr_000_3a06:
    push af
    push bc

jr_000_3a08:
    ld b, $ff

jr_000_3a0a:
    call Call_000_3a16
    or a
    jr nz, jr_000_3a08

    dec b
    jr nz, jr_000_3a0a

    pop bc
    pop af
    ret


Call_000_3a16:
    push bc
    ld a, $20
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    cpl
    and $0f

jr_000_3a22:
    swap a
    ld b, a
    ld a, $10
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    cpl
    and $0f
    or b
    swap a
    ld b, a
    ld a, $30
    ldh [rP1], a
    ld a, b
    pop bc
    ret


Call_000_3a43:
jr_000_3a43:
    call Call_000_3a16
    and b
    jr z, jr_000_3a43

    ret


Call_000_3a4a:
    call Call_000_3a16
    ld e, a
    ret


    push bc
    ld hl, sp+$04
    ld b, [hl]
    call Call_000_3a43
    ld e, a
    pop bc
    ret


Call_000_3a59:
    push bc
    call Call_000_3a76
    ld b, $32

Jump_000_3a5f:
    jr jr_000_3a61

jr_000_3a61:
    jr jr_000_3a63

jr_000_3a63:
    jr jr_000_3a65

jr_000_3a65:
    jr jr_000_3a67

jr_000_3a67:
    jr jr_000_3a69

jr_000_3a69:
    dec b
    jp nz, Jump_000_3a5f

    nop
    pop bc
    jr jr_000_3a71

jr_000_3a71:
    jr jr_000_3a73

jr_000_3a73:
    jr jr_000_3a75

jr_000_3a75:
    ret


Call_000_3a76:
jr_000_3a76:
    dec de
    ld a, e
    or d
    ret z

    ld b, $33

Jump_000_3a7c:
    jr jr_000_3a7e

jr_000_3a7e:
    jr jr_000_3a80

jr_000_3a80:
    jr jr_000_3a82

jr_000_3a82:
    jr jr_000_3a84

jr_000_3a84:
    jr jr_000_3a86

jr_000_3a86:
    dec b
    jp nz, Jump_000_3a7c

    nop
    jr jr_000_3a8d

jr_000_3a8d:
    jr jr_000_3a8f

jr_000_3a8f:
    jr jr_000_3a91

jr_000_3a91:
    jr jr_000_3a76

Call_000_3a93:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    call Call_000_3a59
    ret


Jump_000_3a9c:
    ld a, d
    or e
    ret z

    ld a, h
    cp $98
    jr c, jr_000_3aa7

    sub $10
    ld h, a

jr_000_3aa7:
    xor a
    cp e
    jr nz, jr_000_3aac

    dec d

jr_000_3aac:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_3aac

    ld a, [bc]
    ld [hl+], a
    inc bc

jr_000_3ab5:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_3ab5

    ld a, [bc]
    ld [hl], a
    inc bc
    inc l
    jr nz, jr_000_3ac9

    inc h
    ld a, h
    cp $98
    jr nz, jr_000_3ac9

    ld h, $88

jr_000_3ac9:
    dec e
    jr nz, jr_000_3aac

    dec d
    bit 7, d
    jr z, jr_000_3aac

    ret


Jump_000_3ad2:
    ld a, d
    or e
    ret z

    ld a, h
    cp $98
    jr c, jr_000_3add

    sub $10
    ld h, a

jr_000_3add:
    push de
    ld a, [bc]
    ld e, a
    inc bc
    push bc
    ld bc, $0000
    ld a, [$d735]
    bit 0, a
    jr z, jr_000_3aee

    ld b, $ff

jr_000_3aee:
    bit 1, a
    jr z, jr_000_3af4

    ld c, $ff

jr_000_3af4:
    ld d, a
    ld a, [$d734]
    xor d
    ld d, a
    bit 0, d
    jr z, jr_000_3b01

    ld a, e
    xor b
    ld b, a

jr_000_3b01:
    bit 1, d
    jr z, jr_000_3b08

    ld a, e
    xor c
    ld c, a

jr_000_3b08:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_3b08

    ld [hl], b
    inc hl

jr_000_3b10:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_3b10

    ld [hl], c
    inc hl
    ld a, h
    cp $98
    jr nz, jr_000_3b1f

    ld h, $88

jr_000_3b1f:
    pop bc
    pop de
    dec de
    ld a, d
    or e
    jr nz, jr_000_3add

    ret


Call_000_3b27:
    call Call_000_069f
    push hl
    ld hl, $d73b
    ld b, $06

jr_000_3b30:
    ld a, [hl]
    inc hl
    or [hl]
    cp $00
    jr z, jr_000_3b42

    inc hl
    inc hl
    dec b
    jr nz, jr_000_3b30

    pop hl
    ld hl, $0000
    jr jr_000_3b66

jr_000_3b42:
    pop de
    ld [hl], d
    dec hl
    ld [hl], e
    ld a, [$d739]
    dec hl
    ld [hl], a
    push hl
    call Call_000_3bb7
    ld a, [$d6ca]
    and $02
    call nz, Call_000_3b6f
    ld hl, $d737
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    inc hl
    ld a, [$d739]
    add [hl]
    ld [$d739], a
    pop hl

jr_000_3b66:
    ldh a, [rLCDC]
    or $81
    and $e7
    ldh [rLCDC], a
    ret


Call_000_3b6f:
    ld hl, $d737
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    inc hl
    ld e, [hl]
    ld d, $00
    rl e
    rl d
    rl e
    rl d
    rl e
    rl d
    dec hl
    ld a, [hl]
    push af
    and $03
    ld bc, $0080
    cp $01
    jr z, jr_000_3b9b

    ld bc, $0000
    cp $02
    jr z, jr_000_3b9b

    ld bc, $0100

jr_000_3b9b:
    inc hl
    inc hl
    add hl, bc
    ld c, l
    ld b, h
    ld a, [$d736]
    ld l, a
    ld h, $00
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld a, $90
    add h
    ld h, a
    pop af
    bit 2, a
    jp z, Jump_000_3a9c

    jp Jump_000_3ad2


Call_000_3bb7:
    ld a, [hl+]
    ld [$d736], a
    ld a, [hl+]
    ld [$d737], a
    ld a, [hl+]
    ld [$d738], a
    ret


Call_000_3bc4:
    cp $0a
    jr nz, jr_000_3bd6

    push af
    ld a, [$d6ca]
    and $08
    jr nz, jr_000_3bd5

    call Call_000_3cb0
    pop af
    ret


jr_000_3bd5:
    pop af

jr_000_3bd6:
    call Call_000_3bed
    call Call_000_3cc5
    ret


    call Call_000_3bed
    call Call_000_3cc5
    ret


    call Call_000_3c99
    ld a, $00
    call Call_000_3bed
    ret


Call_000_3bed:
    push af
    ld a, [$d738]
    or a
    jr nz, jr_000_3c02

    call Call_000_3c5c
    xor a
    ld [$d739], a
    call Call_000_078d
    db $fd
    jr nc, jr_000_3c01

jr_000_3c01:
    nop

jr_000_3c02:
    pop af
    push bc
    push de
    push hl
    ld e, a
    ld hl, $d737
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [hl+]
    and $03
    cp $02
    jr z, jr_000_3c19

    inc hl
    ld d, $00
    add hl, de
    ld e, [hl]

jr_000_3c19:
    ld a, [$d736]
    add e
    ld e, a
    ld a, [$d74d]
    ld l, a
    ld h, $00
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld a, [$d74c]
    ld c, a
    ld b, $00
    add hl, bc
    ld bc, $9800
    add hl, bc

jr_000_3c34:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_3c34

    ld [hl], e
    pop hl
    pop de
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld a, [hl]
    inc hl
    ld h, [hl]
    ld l, a
    call Call_000_3b27
    push hl
    pop de
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld a, [hl]
    inc hl
    ld h, [hl]
    ld l, a
    call Call_000_3bb7
    pop bc
    ld de, $0000
    ret


Call_000_3c5c:
    push bc
    call Call_000_3d21
    ld a, $01
    ld [$d739], a
    xor a
    ld hl, $d73a
    ld b, $12

jr_000_3c6b:
    ld [hl+], a
    dec b
    jr nz, jr_000_3c6b

    ld a, $03
    ld [$d734], a
    ld a, $00
    ld [$d735], a
    call Call_000_3c7e
    pop bc
    ret


Call_000_3c7e:
    push de
    push hl
    ld hl, $9800
    ld e, $20

jr_000_3c85:
    ld d, $20

jr_000_3c87:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_3c87

    ld [hl], $00
    inc hl
    dec d
    jr nz, jr_000_3c87

    dec e
    jr nz, jr_000_3c85

    pop hl
    pop de
    ret


Call_000_3c99:
    push hl
    ld hl, $d74c
    xor a
    cp [hl]
    jr z, jr_000_3ca4

    dec [hl]
    jr jr_000_3cae

jr_000_3ca4:
    ld [hl], $13
    ld hl, $d74d
    xor a
    cp [hl]
    jr z, jr_000_3cae

    dec [hl]

jr_000_3cae:
    pop hl
    ret


Call_000_3cb0:
    push hl
    xor a
    ld [$d74c], a
    ld hl, $d74d
    ld a, $11
    cp [hl]
    jr z, jr_000_3cc0

    inc [hl]
    jr jr_000_3cc3

jr_000_3cc0:
    call Call_000_3cf3

jr_000_3cc3:
    pop hl
    ret


Call_000_3cc5:
    push hl
    ld hl, $d74c
    ld a, $13
    cp [hl]
    jr z, jr_000_3cd1

    inc [hl]
    jr jr_000_3cf1

jr_000_3cd1:
    ld [hl], $00
    ld hl, $d74d
    ld a, $11
    cp [hl]
    jr z, jr_000_3cde

    inc [hl]
    jr jr_000_3cf1

jr_000_3cde:
    ld a, [$d6ca]
    and $04
    jr z, jr_000_3cee

    xor a
    ld [$d74d], a
    ld [$d74c], a
    jr jr_000_3cf1

jr_000_3cee:
    call Call_000_3cf3

jr_000_3cf1:
    pop hl
    ret


Call_000_3cf3:
    push bc
    push de
    push hl
    ld hl, $9800
    ld bc, $9820
    ld e, $1f

jr_000_3cfe:
    ld d, $20

jr_000_3d00:
    ldh a, [rSTAT]
    and $02
    jr nz, jr_000_3d00

    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, jr_000_3d00

    dec e
    jr nz, jr_000_3cfe

    ld d, $20

jr_000_3d11:
    ldh a, [rSTAT]
    and $02
    jr nz, jr_000_3d11

    ld a, $00
    ld [hl+], a
    dec d
    jr nz, jr_000_3d11

    pop hl
    pop de
    pop bc
    ret


Call_000_3d21:
Jump_000_3d21:
    di
    ldh a, [rLCDC]
    bit 7, a
    jr z, jr_000_3d3d

    call Call_000_069f
    ld bc, $2a5f
    ld hl, $d6d3
    call Call_000_064c
    ld bc, $2a6a
    ld hl, $d6e3
    call Call_000_064c

jr_000_3d3d:
    call Call_000_3d4a
    ldh a, [rLCDC]
    or $81
    and $e7
    ldh [rLCDC], a
    ei
    ret


Call_000_3d4a:
    xor a
    ld [$d74c], a
    ld [$d74d], a
    call Call_000_3c7e
    ld a, $02
    ld [$d6ca], a
    ret


Call_000_3d5a:
Jump_000_3d5a:
jr_000_3d5a:
    ldh a, [rSTAT]
    and $02
    jr nz, jr_000_3d5a

    ld [hl], b
    inc hl
    dec de
    ld a, d
    or e
    jr nz, jr_000_3d5a

    ret


    ldh a, [rLCDC]
    bit 6, a
    jr nz, jr_000_3d73

    ld hl, $9800
    jr jr_000_3d86

jr_000_3d73:
    ld hl, $9c00
    jr jr_000_3d86

    ldh a, [rLCDC]
    bit 3, a
    jr nz, jr_000_3d83

    ld hl, $9800
    jr jr_000_3d86

jr_000_3d83:
    ld hl, $9c00

jr_000_3d86:
    ld de, $0400
    jp Jump_000_3d5a


    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
