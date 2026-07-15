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
    ld hl, $d6ac
    jp Jump_000_0067


    rst RST_38

LCDCInterrupt::
    push hl
    ld hl, $d6bc
    jp Jump_000_0067


    rst RST_38

TimerOverflowInterrupt::
    push hl
    ld hl, $d6cc
    jp Jump_000_0067


    rst RST_38

SerialTransferCompleteInterrupt::
    push hl
    ld hl, $d6dc
    jp Jump_000_0067


    rst RST_38

JoypadTransitionInterrupt::
    push hl
    ld hl, $d6ec
    jp Jump_000_0067


Jump_000_0067:
    push af

    push bc
    push de
    ld a, [$d6a9]
    inc a
    ld [$d6a9], a

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
    ld a, [$d6a9]
    dec a
    ld [$d6a9], a
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
    db $7a, $ed

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
    ld [$d6a2], a
    ld a, $01
    ld [$d6a8], a
    ld [$2000], a
    xor a
    ld [$d6a9], a
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
    ld [$d6aa], a
    ld [$d6ab], a
    call $5c87
    call Call_000_181c

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
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    jp Jump_000_2b31


    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    jp Jump_000_3968


    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    ld [$d6a3], a
    and $03
    ld l, a
    ld bc, $01e2
    sla l
    sla l
    add hl, bc
    jp hl


Call_000_0610:
    ld hl, $d6ac
    jp Jump_000_064c


Call_000_0616:
    ld hl, $d6bc
    jp Jump_000_064c


Call_000_061c:
    ld hl, $d6cc
    jp Jump_000_064c


Call_000_0622:
    ld hl, $d6dc
    jp Jump_000_064c


Call_000_0628:
    ld hl, $d6ec
    jp Jump_000_064c


Call_000_062e:
    ld hl, $d6ac
    jp Jump_000_066c


Call_000_0634:
    ld hl, $d6bc
    jp Jump_000_066c


Call_000_063a:
    ld hl, $d6cc
    jp Jump_000_066c


Call_000_0640:
    ld hl, $d6dc
    jp Jump_000_066c


Call_000_0646:
    ld hl, $d6ec
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


    ld hl, $d6aa
    inc [hl]
    jr nz, jr_000_067f

    inc hl
    inc [hl]

jr_000_067f:
    call $ff80
    ld a, $01
    ld [$d6a7], a
    ret


Call_000_0688:
    ldh a, [rLCDC]
    add a
    ret nc

    xor a
    di
    ld [$d6a7], a
    ei

jr_000_0692:
    halt
    nop
    ld a, [$d6a7]
    or a
    jr z, jr_000_0692

    xor a
    ld [$d6a7], a
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


    ld a, [$d6a6]
    cp $02
    jr nz, jr_000_06d0

    ldh a, [rSB]
    ld [$d6a5], a
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
    ld [$d6a6], a
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


    ld hl, $d6a3
    ld e, [hl]
    ret


Call_000_06fd:
    di
    ld a, [$d6a9]
    inc a
    ld [$d6a9], a
    ret


Call_000_0706:
    ld a, [$d6a9]
    dec a
    ld [$d6a9], a
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
    ld a, [$d6a8]
    push af
    ld a, b
    ld [$d6a8], a
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
    ld [$d6a8], a
    call Call_000_0706
    ret


Call_000_07bc:
Jump_000_07bc:
    call Call_000_3691
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
    call Call_000_36da
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
    call Call_000_243d
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
    call Call_000_243d
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
    call Call_000_243d
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
    call Call_000_243d
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
    call Call_000_243d
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
    call Call_000_243d
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
    call Call_000_243d
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
    call Call_000_243d
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
    call Call_000_23ac
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
    call Call_000_23b7
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
    call Call_000_23d8
    add sp, $03
    pop bc
    push bc
    ld a, $20
    push af
    inc sp
    call Call_000_23b7
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
    ld a, $10
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
    call Call_000_16db
    add sp, $07
    ld hl, sp+$01
    ld c, l
    ld b, h
    push bc
    call Call_000_29dc
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
    ld hl, $cc30
    inc [hl]
    ld a, $14
    ld hl, $cc30
    sub [hl]
    jp nc, Jump_000_0986

    ld hl, $cc30
    ld [hl], $00
    ld hl, $cc2f
    inc [hl]

Jump_000_0986:
    add sp, $15
    ret


Call_000_0989:
    ld hl, $cc2f
    ld a, [hl]
    push af
    inc sp
    ld hl, $0100
    push hl
    ld hl, $09a0
    push hl
    call Call_000_08b7
    add sp, $05

Jump_000_099c:
    jp Jump_000_099c


    ret


    ld b, [hl]
    ld l, c
    ld l, h
    ld h, l
    jr nz, jr_000_0a19

    ld a, c
    ld [hl], e
    ld [hl], h
    ld h, l
    ld l, l
    jr nz, jr_000_0a12

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

Jump_000_09d4:
    ld hl, sp+$02
    ld b, [hl]
    dec [hl]
    xor a
    or b
    jp z, Jump_000_0a15

    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    dec hl
    inc [hl]
    jr nz, jr_000_09ea

    inc hl
    inc [hl]

jr_000_09ea:
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
    jr nz, jr_000_09fd

    inc hl
    inc [hl]

jr_000_09fd:
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

jr_000_0a12:
    jp z, Jump_000_09d4

Jump_000_0a15:
    ld hl, sp+$03
    ld e, [hl]
    inc hl

jr_000_0a19:
    ld d, [hl]
    add sp, $09
    ret


Call_000_0a1d:
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

Jump_000_0a2b:
    ld b, c
    dec c
    xor a
    or b
    jp z, Jump_000_0a44

    ld hl, sp+$06
    ld a, [hl]
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_000_0a41

    inc hl
    inc [hl]

jr_000_0a41:
    jp Jump_000_0a2b


Jump_000_0a44:
    add sp, $02
    ret


Call_000_0a47:
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

Jump_000_0a5a:
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
    jp nz, Jump_000_0a87

    ld bc, $c9e4
    ld a, [bc]
    ld c, a
    or a
    jp nz, Jump_000_0a8f

Jump_000_0a87:
    ld hl, $c5a4
    ld [hl], $01
    jp Jump_000_0bc9


Jump_000_0a8f:
    ld a, c
    sub $2e
    jp z, Jump_000_0a5a

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
    jp nz, Jump_000_0aa7

    ld bc, $c9e4

Jump_000_0aa7:
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

jr_000_0ac3:
    srl b
    rr c
    dec a
    jr nz, jr_000_0ac3

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
    jp nz, Jump_000_0aef

    jr jr_000_0af2

Jump_000_0aef:
    jp Jump_000_0b45


jr_000_0af2:
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
    call Call_000_1d29
    add sp, $04
    ld hl, sp+$04
    inc [hl]
    ld hl, $c2a2
    inc [hl]
    jr nz, jr_000_0b42

    ld hl, $c2a3
    inc [hl]

jr_000_0b42:
    jp Jump_000_0bbc


Jump_000_0b45:
    ld a, c
    and $20
    ld c, a
    sub $20
    jp nz, Jump_000_0b50

    jr jr_000_0b53

Jump_000_0b50:
    jp Jump_000_0bbc


jr_000_0b53:
    ld a, $08
    push af
    inc sp
    ld hl, $0bcc
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call $09b3
    add sp, $05
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, Jump_000_0a5a

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
    call Call_000_1d29
    add sp, $04
    ld hl, sp+$04
    inc [hl]
    ld hl, $c2a2
    inc [hl]
    jr nz, jr_000_0bbc

    ld hl, $c2a3
    inc [hl]

Jump_000_0bbc:
jr_000_0bbc:
    ld hl, sp+$04
    ld a, [hl]
    sub $10
    jp nz, Jump_000_0bc6

    jr jr_000_0bc9

Jump_000_0bc6:
    jp Jump_000_0a5a


Jump_000_0bc9:
jr_000_0bc9:
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

Call_000_0bd5:
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
    jp nc, Jump_000_0de1

    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_23d8
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

jr_000_0c0e:
    srl b
    rr c
    dec a
    jr nz, jr_000_0c0e

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
    call Call_000_29dc
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
    jp nz, Jump_000_0c85

    jr jr_000_0c88

Jump_000_0c85:
    jp Jump_000_0c8f


jr_000_0c88:
    ld hl, sp+$0f
    ld [hl], $11
    jp Jump_000_0c93


Jump_000_0c8f:
    ld hl, sp+$0f
    ld [hl], $14

Jump_000_0c93:
    ld hl, sp+$0f
    ld a, [hl]
    dec hl
    sub [hl]
    jp nc, Jump_000_0de1

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
    call Call_000_25d6
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
    call Call_000_2473
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
    jp nz, Jump_000_0d30

    ld hl, $cc32
    ld a, [hl]
    ld hl, sp+$0b
    sub [hl]
    jp z, Jump_000_0de1

Jump_000_0d30:
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
    call Call_000_291a
    add sp, $06
    ld hl, $0de4
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
    call Call_000_29dc
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
    call Call_000_29dc
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
    call Call_000_291a
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

Jump_000_0de1:
    add sp, $10
    ret


    jr nz, jr_000_0e06

    jr nz, jr_000_0de8

Call_000_0de8:
jr_000_0de8:
    add sp, -$17
    ld hl, $c2a0
    ld [hl], $00
    ld hl, $c2a1
    ld [hl], $a0
    ld a, $01
    push af
    inc sp
    ld hl, $169b
    push hl
    ld hl, $c7a9
    push hl
    call Call_000_078d
    add hl, de
    ld l, [hl]
    dec b

jr_000_0e06:
    nop
    add sp, $05
    ld c, e
    ld hl, sp+$16
    ld [hl], c
    ld a, [hl]
    or a
    jp z, Jump_000_0e28

    ld hl, $cc2f
    ld a, [hl]
    push af
    inc sp
    ld hl, $0014
    push hl
    ld hl, $169c
    push hl
    call Call_000_08b7
    add sp, $05

Jump_000_0e25:
    jp Jump_000_0e25


Jump_000_0e28:
    ld hl, $cc2f
    ld a, [hl]
    push af
    inc sp
    ld hl, $0014
    push hl
    ld hl, $16b4
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
    jp nz, Jump_000_0e77

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_000_0e77

    jr jr_000_0e7a

Jump_000_0e77:
    jp Jump_000_0f4f


jr_000_0e7a:
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

Jump_000_0eb8:
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
    jp nc, Jump_000_0efc

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
    jr nz, jr_000_0ef9

    inc hl
    inc [hl]

jr_000_0ef9:
    jp Jump_000_0eb8


Jump_000_0efc:
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
    ld hl, $16c9
    push hl
    call Call_000_1998
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
    jr jr_000_0fa6

    ld bc, $e800
    dec b

Jump_000_0f4f:
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
    call Call_000_28ec
    add sp, $05
    ld de, $c2a6
    ld a, $2f
    ld [de], a

Jump_000_0f81:
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

jr_000_0fa6:
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
    jp z, Jump_000_0fc1

    call Call_000_0989

Jump_000_0fc1:
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
    jp z, Jump_000_0fe8

    call Call_000_0989

Jump_000_0fe8:
    ld hl, $00ff
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $c4a4
    push hl
    call Call_000_28ec
    add sp, $05
    ld c, $db
    ld b, $c9
    ld hl, $001a
    push hl
    ld a, $00
    push af
    inc sp
    push bc
    call Call_000_28ec
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
    call Call_000_0a47
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
    jr nz, jr_000_1065

    inc hl
    inc [hl]
    jr nz, jr_000_1065

    inc hl
    inc [hl]
    jr nz, jr_000_1065

    inc hl
    inc [hl]

jr_000_1065:
    xor a
    ld hl, sp+$12
    or [hl]
    jp z, Jump_000_10d3

    xor a
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    sub $01
    jp nz, Jump_000_107d

    jr jr_000_1080

Jump_000_107d:
    jp Jump_000_10a5


jr_000_1080:
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
    jp Jump_000_10d3


Jump_000_10a5:
    ld a, $01
    ld hl, sp+$12
    sub [hl]
    jp nc, Jump_000_10d3

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

Jump_000_10d3:
    ld hl, $c2a2
    ld a, [hl]
    ld hl, $c2a3
    or [hl]
    jp z, Jump_000_10fb

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
    call Call_000_0bd5
    add sp, $08

Jump_000_10fb:
    ld hl, sp+$12
    ld [hl], $00
    ld hl, $002d
    push hl
    call Call_000_36da
    add sp, $02
    call Call_000_3691
    ld b, e
    ld c, b
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], $00
    dec hl
    ld a, [hl]
    and $02
    jr nz, jr_000_111c

    jp Jump_000_115f


jr_000_111c:
    ld hl, sp+$13
    ld a, [hl+]
    or [hl]
    jp z, Jump_000_114f

    ld a, $0f
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp nc, Jump_000_1141

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
    jp Jump_000_1148


Jump_000_1141:
    ld hl, sp+$13
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_000_1148:
    ld hl, sp+$12
    ld [hl], $01
    jp Jump_000_1692


Jump_000_114f:
    xor a
    ld hl, sp+$15
    or [hl]
    jp z, Jump_000_1692

    ld [hl], $00
    ld hl, sp+$12
    ld [hl], $01
    jp Jump_000_1692


Jump_000_115f:
    ld hl, sp+$00
    ld a, [hl]
    and $01
    jr nz, jr_000_1169

    jp Jump_000_11d1


jr_000_1169:
    xor a
    ld hl, $c5a4
    or [hl]
    jp nz, Jump_000_1174

    call Call_000_0a47

Jump_000_1174:
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
    jp nc, Jump_000_1692

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
    jp c, Jump_000_11b3

    ld hl, sp+$13
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_000_11ca


Jump_000_11b3:
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

Jump_000_11ca:
    ld hl, sp+$12
    ld [hl], $01
    jp Jump_000_1692


Jump_000_11d1:
    ld hl, sp+$00
    ld a, [hl]
    and $04
    jr nz, jr_000_11db

    jp Jump_000_11ea


jr_000_11db:
    xor a
    ld hl, sp+$15
    or [hl]
    jp z, Jump_000_1692

    dec [hl]
    ld hl, sp+$12
    ld [hl], $03
    jp Jump_000_1692


Jump_000_11ea:
    ld hl, sp+$00
    ld a, [hl]
    and $08
    jr nz, jr_000_11f4

    jp Jump_000_1217


jr_000_11f4:
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
    jp nc, Jump_000_1692

    ld hl, sp+$15
    ld a, [hl]
    sub $0f
    jp nc, Jump_000_1692

    inc [hl]
    ld hl, sp+$12
    ld [hl], $02
    jp Jump_000_1692


Jump_000_1217:
    ld hl, sp+$00
    ld a, [hl]
    and $40
    jr nz, jr_000_1221

    jp Jump_000_1288


jr_000_1221:
    ld hl, sp+$0e
    inc [hl]
    ld a, [hl]
    sub $02
    jp nz, Jump_000_122c

    jr jr_000_122f

Jump_000_122c:
    jp Jump_000_1236


jr_000_122f:
    ld hl, sp+$0e
    ld [hl], $00
    jp Jump_000_125b


Jump_000_1236:
    ld hl, sp+$0e
    ld a, [hl]
    sub $01
    jp nz, Jump_000_1240

    jr jr_000_1243

Jump_000_1240:
    jp Jump_000_125b


jr_000_1243:
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

Jump_000_125b:
    ld hl, sp+$0e
    ld a, [hl]
    sub $02
    jp nz, Jump_000_1265

    jr jr_000_1268

Jump_000_1265:
    jp Jump_000_1692


jr_000_1268:
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
    call Call_000_36da
    add sp, $02
    jp Jump_000_0f81


Jump_000_1288:
    ld hl, sp+$00
    ld a, [hl]
    and $80
    jr nz, jr_000_1292

    jp Jump_000_1386


jr_000_1292:
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

Jump_000_12b3:
    ld hl, sp+$0f
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_000_12e5

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
    jr nz, jr_000_12e2

    inc hl
    inc [hl]

jr_000_12e2:
    jp Jump_000_12b3


Jump_000_12e5:
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
    call Call_000_2889
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

Jump_000_1324:
    call Call_000_3691
    ld b, e
    ld c, b
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], $00
    dec hl
    ld a, [hl]
    and $10
    jr nz, jr_000_1338

    jp Jump_000_1379


jr_000_1338:
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
    call Call_000_2901
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
    call Call_000_1d29
    add sp, $04
    call Call_000_078d
    ld a, a
    ld [hl], e
    ld [$c300], sp
    ld h, h
    dec d

Jump_000_1379:
    ld hl, sp+$04
    ld a, [hl]
    and $20
    jr nz, jr_000_1383

    jp Jump_000_1324


jr_000_1383:
    jp Jump_000_0f81


Jump_000_1386:
    ld hl, sp+$00
    ld a, [hl]
    and $10
    jr nz, jr_000_1390

    jp Jump_000_1616


jr_000_1390:
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

jr_000_13a7:
    srl b
    rr c
    dec a
    jr nz, jr_000_13a7

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
    jp nz, Jump_000_1400

    jr jr_000_1403

Jump_000_1400:
    jp Jump_000_1453


jr_000_1403:
    ld hl, $16d0
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
    jp z, Jump_000_142f

    ld hl, $16d0
    push hl
    ld hl, $c2a6
    push hl
    call Call_000_078d
    nop
    ld b, b
    ld bc, $e800
    inc b

Jump_000_142f:
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
    jp Jump_000_0f81


Jump_000_1453:
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
    call Call_000_0a1d
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
    call Call_000_1d29
    add sp, $04
    ld a, $2e
    push af
    inc sp
    ld hl, $c4a4
    push hl
    call Call_000_2889
    add sp, $03
    ld b, d
    ld c, e
    ld hl, $0005
    push hl
    push bc
    ld hl, $c3a5
    push hl
    call Call_000_2901
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
    jp c, Jump_000_14ca

    ld a, $7a
    sub b
    rlca
    jp c, Jump_000_14ca

    ld a, b
    add $e0
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a

Jump_000_14ca:
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
    jp c, Jump_000_14ef

    ld a, $7a
    sub b
    rlca
    jp c, Jump_000_14ef

    ld a, b
    add $e0
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a

Jump_000_14ef:
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
    jp c, Jump_000_1514

    ld a, $7a
    sub b
    rlca
    jp c, Jump_000_1514

    ld a, b
    add $e0
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a

Jump_000_1514:
    ld a, $05
    push af
    inc sp
    ld hl, $16d2
    push hl
    ld hl, $c3a5
    push hl
    call $09b3
    add sp, $05
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, Jump_000_155d

    ld a, $04
    push af
    inc sp
    ld hl, $16d7
    push hl
    ld hl, $c3a5
    push hl
    call $09b3
    add sp, $05
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, Jump_000_155d

    call Call_000_078d
    cp d
    ld [hl], e
    ld [$cd00], sp
    sub c
    ld [hl], $43
    ld c, b
    ld b, $00
    ld a, c
    and $20
    jr nz, jr_000_155a

    jp $154b


jr_000_155a:
    jp Jump_000_0f81


Jump_000_155d:
    call Call_000_078d
    dec bc
    ld c, b
    ld bc, $2100
    and h
    call nz, $cde5
    adc l
    rlca
    ld h, [hl]
    ld d, e
    ld bc, $e800
    ld [bc], a
    ld b, e
    ld hl, sp+$16
    ld [hl], b
    ld a, [hl]
    inc a
    jp nz, Jump_000_157c

    jr jr_000_157f

Jump_000_157c:
    jp Jump_000_1585


jr_000_157f:
    call Call_000_07bc
    jp Jump_000_0f81


Jump_000_1585:
    xor a
    ld hl, $d3ef
    or [hl]
    jp z, $15a2

    ld hl, $0000
    push hl
    ld hl, $2000
    push hl
    ld hl, $c4a4
    push hl
    call Call_000_078d
    and [hl]
    ld c, b
    ld bc, $e800
    ld b, $21
    and h
    call nz, $cde5
    adc l
    rlca
    ld [bc], a
    ld c, [hl]
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
    ld hl, $d3ed
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

Jump_000_1613:
    jp Jump_000_1613


Jump_000_1616:
    ld hl, sp+$00
    ld a, [hl]
    and $20
    jr nz, jr_000_1620

    jp Jump_000_1692


jr_000_1620:
    ld hl, $16d0
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
    jp z, Jump_000_1692

    ld hl, $00ff
    push hl
    ld hl, $c2a6
    push hl
    ld hl, $c3a5
    push hl
    call Call_000_2901
    add sp, $06
    ld a, $2f
    push af
    inc sp
    ld hl, $c3a5
    push hl
    call Call_000_2889
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
    call Call_000_28ec
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
    call Call_000_2901
    add sp, $06
    ld de, $c2a6
    ld a, [de]
    or a
    jp nz, Jump_000_0f81

    ld de, $c2a6
    ld a, $2f
    ld [de], a
    jp Jump_000_0f81


Jump_000_1692:
    call Call_000_0688
    jp $1056


    add sp, $17
    ret


    nop
    ld c, l
    ld l, c
    ld h, e
    ld [hl], d
    ld l, a
    jr nz, jr_000_16f6

    ld b, h
    jr nz, jr_000_170f

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
    jr nz, jr_000_170e

    ld b, h
    jr nz, @+$6b

    ld l, [hl]
    ld l, c
    ld [hl], h
    ld l, c
    ld h, c
    ld l, h
    jr nz, jr_000_1715

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

Call_000_16db:
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

jr_000_16f6:
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a

Jump_000_16ff:
    ld hl, sp+$06
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_000_1720

    inc hl
    ld a, [hl]
    ld hl, sp+$04

jr_000_170e:
    sub [hl]

jr_000_170f:
    jp nz, Jump_000_171d

    ld hl, sp+$0b
    ld a, [hl]

jr_000_1715:
    ld hl, sp+$05
    sub [hl]
    jp nz, Jump_000_171d

    jr jr_000_1720

Jump_000_171d:
    jp Jump_000_17cc


Jump_000_1720:
jr_000_1720:
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
    call Call_000_2473
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
    call Call_000_2479
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
    jp nc, Jump_000_17b7

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
    jr nz, jr_000_17b4

    inc hl
    inc [hl]

jr_000_17b4:
    jp Jump_000_16ff


Jump_000_17b7:
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
    jr nz, jr_000_17c9

    inc hl
    inc [hl]

jr_000_17c9:
    jp Jump_000_16ff


Jump_000_17cc:
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

Jump_000_17e9:
    ld a, c
    ld hl, sp+$00
    sub [hl]
    ld a, b
    inc hl
    sbc [hl]
    rlca
    jp nc, Jump_000_1811

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
    jr nz, jr_000_180e

    inc hl
    inc [hl]

jr_000_180e:
    jp Jump_000_17e9


Jump_000_1811:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    add sp, $33
    ret


Call_000_181c:
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
    jp z, Jump_000_18d2

    ld hl, $0805
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, $18f6
    push hl
    call Call_000_08b7
    add sp, $05
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_23d8
    add sp, $03
    ld hl, $016c
    push hl
    ld hl, $7d25
    push hl
    ld a, $23
    push af
    inc sp
    call Call_000_2401
    add sp, $05
    ld hl, $0705
    push hl
    ld a, $07
    push af
    inc sp
    ld hl, $18f8
    push hl
    call Call_000_08b7
    add sp, $05
    ld hl, $0805
    push hl
    ld a, $06
    push af
    inc sp
    ld hl, $1900
    push hl
    call Call_000_08b7
    add sp, $05
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_23d8
    add sp, $03
    ld hl, $016a
    push hl
    ld hl, $7b5d
    push hl
    ld a, $4e
    push af
    inc sp
    call Call_000_2401
    add sp, $05
    ld hl, $0c0a
    push hl
    ld a, $05
    push af
    inc sp
    ld hl, $1907
    push hl
    call Call_000_08b7
    add sp, $05

Jump_000_18be:
    call Call_000_3691
    ld c, e
    ld b, $00
    ld a, c
    and $10
    jr nz, jr_000_18cc

    jp Jump_000_18be


jr_000_18cc:
    ld bc, $a201
    ld a, $88
    ld [bc], a

Jump_000_18d2:
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_23d8
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
    call Call_000_0de8
    ret


    jr nz, jr_000_18f8

jr_000_18f8:
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

Call_000_190d:
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


Call_000_1928:
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
    ld [hl], a
    ld [hl], a
    ld b, $00
    add sp, $08
    ret


Call_000_194a:
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


Call_000_196c:
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
    cp l
    halt
    inc bc
    nop
    add sp, $06
    ret


Call_000_1988:
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_078d
    add b
    halt
    inc bc
    nop
    add sp, $02
    ret


Call_000_1998:
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


Call_000_19a8:
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


Call_000_19dc:
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


Call_000_1a10:
    ld e, $00
    ret


Call_000_1a13:
    ld e, $00
    ret


Call_000_1a16:
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


Call_000_1a3a:
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


Call_000_1a5e:
    ld e, $00
    ret


Call_000_1a61:
    push af
    push af
    dec sp
    ld hl, sp+$07
    ld a, [hl]
    sub $80
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_000_1a77

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    jp Jump_000_1b17


Jump_000_1a77:
    ld hl, sp+$09
    ld a, [hl+]
    or [hl]
    jp z, Jump_000_1ac5

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
    jp z, Jump_000_1aa1

    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp Jump_000_1abd


Jump_000_1aa1:
    ld hl, sp+$07
    ld c, [hl]
    ld a, c
    add $80
    ld c, a
    ld b, $00
    sla c
    rl b
    ld hl, $1b1c
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

Jump_000_1abd:
    ld hl, sp+$03
    ld c, [hl]
    inc hl
    ld b, [hl]
    jp Jump_000_1b17


Jump_000_1ac5:
    ld hl, sp+$03
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_000_1acc:
    ld hl, sp+$03
    ld a, [hl]
    sub $80
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_000_1b04

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    sla c
    rl b
    ld hl, $1b1c
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

jr_000_1aed:
    ld hl, sp+$07
    ld a, [hl]
    sub c
    jp nz, Jump_000_1afa

    inc hl
    ld a, [hl]
    sub b
    jp z, Jump_000_1b04

Jump_000_1afa:
    ld hl, sp+$03
    inc [hl]
    jr nz, jr_000_1b01

    inc hl
    inc [hl]

jr_000_1b01:
    jp Jump_000_1acc


Jump_000_1b04:
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

Jump_000_1b17:
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
    jr nz, jr_000_1aed

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

jr_000_1bc9:
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
    jr nz, jr_000_1c29

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
    jr nz, jr_000_1bc9

    nop
    and b
    dec h
    and b
    nop

Call_000_1c1c:
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

jr_000_1c29:
    jp nc, Jump_000_1c55

    dec hl
    ld a, [hl]
    sub $61
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_000_1cfa

    ld a, $7a
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp c, Jump_000_1cfa

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
    jp Jump_000_1cfa


Jump_000_1c55:
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

Jump_000_1c68:
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
    jp nz, Jump_000_1cac

    inc hl
    ld a, [hl]
    sub b
    jp z, Jump_000_1cd9

Jump_000_1cac:
    ld a, c
    ld hl, sp+$0a
    sub [hl]
    ld a, b
    inc hl
    sbc [hl]
    jp nc, Jump_000_1cc1

    ld hl, sp+$06
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    jp Jump_000_1cc9


Jump_000_1cc1:
    ld hl, sp+$06
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], e

Jump_000_1cc9:
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
    jp nz, Jump_000_1c68

Jump_000_1cd9:
    ld hl, sp+$04
    ld a, [hl+]
    or [hl]
    jp z, Jump_000_1cfa

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

Jump_000_1cfa:
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $08
    ret


Call_000_1d02:
    ld c, l
    ld b, h
    pop hl

Jump_000_1d05:
    ld e, [hl]
    inc hl
    bit 7, e
    jp z, Jump_000_1d17

    ld a, [hl]
    inc hl

Jump_000_1d0e:
    ld [bc], a
    inc bc
    inc e
    jp nz, Jump_000_1d0e

    jp Jump_000_1d05


Jump_000_1d17:
    xor a
    or e
    jp z, Jump_000_1d27

Jump_000_1d1c:
    ld a, [hl]
    inc hl
    ld [bc], a
    inc bc
    dec e
    jp nz, Jump_000_1d1c

    jp Jump_000_1d05


Jump_000_1d27:
    push hl
    ret


Call_000_1d29:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a

jr_000_1d33:
    ld a, [de]
    inc de
    ld [hl], a
    and a
    ret z

    inc hl
    jr jr_000_1d33

Call_000_1d3b:
    push hl
    ld hl, $d70b
    ld a, $13
    cp [hl]
    jr z, jr_000_1d47

    inc [hl]
    jr jr_000_1d56

jr_000_1d47:
    ld [hl], $00
    ld hl, $d70c
    ld a, $11
    cp [hl]
    jr z, jr_000_1d54

    inc [hl]
    jr jr_000_1d56

jr_000_1d54:
    ld [hl], $00

jr_000_1d56:
    pop hl
    ret


Call_000_1d58:
    ld a, b
    ld [$d6fe], a
    ld a, c
    ld [$d700], a
    xor a
    ld [$d6ff], a
    ld a, d
    ld [$d701], a
    cpl
    ld l, a
    ld h, $ff
    inc hl
    ld bc, $0000
    add hl, bc
    ld a, l
    ld [$d706], a
    ld a, h
    ld [$d705], a

Jump_000_1d79:
jr_000_1d79:
    ld a, [$d6ff]
    ld b, a
    ld a, [$d701]
    sub b
    ret c

    ld a, [$d6fd]
    or a
    call z, Call_000_1e8f
    ld a, [$d705]
    bit 7, a
    jr z, jr_000_1dbd

    ld a, [$d6fd]
    or a
    call nz, Call_000_1dfb
    ld a, [$d6ff]
    inc a
    ld [$d6ff], a
    ld a, [$d705]
    ld b, a
    ld a, [$d706]
    ld c, a
    ld h, $00
    ld a, [$d6ff]
    ld l, a
    add hl, hl
    add hl, hl
    add hl, bc
    ld bc, $0006
    add hl, bc
    ld a, h
    ld [$d705], a
    ld a, l
    ld [$d706], a
    jr jr_000_1d79

jr_000_1dbd:
    ld a, [$d6fd]
    or a
    call nz, Call_000_1e33
    ld a, [$d6ff]
    inc a
    ld [$d6ff], a
    ld b, $00
    ld a, [$d6ff]
    ld c, a
    ld h, $ff
    ld a, [$d701]
    cpl
    ld l, a
    inc hl
    add hl, bc
    ld a, [$d705]
    ld b, a
    ld a, [$d706]
    ld c, a
    add hl, hl
    add hl, hl
    add hl, bc
    ld bc, $000a
    add hl, bc
    ld a, h
    ld [$d705], a
    ld a, l
    ld [$d706], a
    ld a, [$d701]
    dec a
    ld [$d701], a
    jp Jump_000_1d79


Call_000_1dfb:
    ld a, [$d6fe]
    ld b, a
    ld a, [$d700]
    ld c, a
    ld a, [$d6ff]
    ld d, a
    ld a, [$d701]
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
    call Call_000_1fe3
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
    call Call_000_1fe3
    pop de
    pop bc
    ret


Call_000_1e33:
    ld a, [$d6fe]
    ld b, a
    ld a, [$d700]
    ld c, a
    ld a, [$d6ff]
    ld d, a
    ld a, [$d701]
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
    call Call_000_1fe3
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
    call Call_000_1fe3
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
    call Call_000_1fe3
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
    call Call_000_1fe3
    pop de
    pop bc
    ret


Call_000_1e8f:
    ld a, [$d6fe]
    ld b, a
    ld a, [$d700]
    ld c, a
    ld a, [$d6ff]
    ld d, a
    ld a, [$d701]
    ld e, a
    push bc
    push de
    ld a, b
    add d
    ld b, a
    ld a, c
    sub e
    ld c, a
    call Call_000_2274
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
    call Call_000_2274
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
    call Call_000_2274
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
    call Call_000_2274
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
    call Call_000_2274
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
    call Call_000_2274
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
    call Call_000_2274
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
    call Call_000_2274
    pop de
    pop bc
    ret


Call_000_1f0d:
    ld a, [$d6fe]
    ld b, a
    ld a, [$d6ff]
    ld c, a
    sub b
    jr nc, jr_000_1f20

    ld a, c
    ld [$d6fe], a
    ld a, b
    ld [$d6ff], a

jr_000_1f20:
    ld a, [$d700]
    ld b, a
    ld a, [$d701]
    ld c, a
    sub b
    jr nc, jr_000_1f33

    ld a, c
    ld [$d700], a
    ld a, b
    ld [$d701], a

jr_000_1f33:
    ld a, [$d6fe]
    ld b, a
    ld d, a
    ld a, [$d700]
    ld c, a
    ld a, [$d701]
    ld e, a
    call Call_000_1fe3
    ld a, [$d6ff]
    ld b, a
    ld d, a
    ld a, [$d700]
    ld c, a
    ld a, [$d701]
    ld e, a
    call Call_000_1fe3
    ld a, [$d6fe]
    inc a
    ld [$d6fe], a
    ld a, [$d6ff]
    dec a
    ld [$d6ff], a
    ld a, [$d6fe]
    ld b, a
    ld a, [$d6ff]
    ld d, a
    ld a, [$d700]
    ld c, a
    ld e, a
    call Call_000_1fe3
    ld a, [$d6fe]
    ld b, a
    ld a, [$d6ff]
    ld d, a
    ld a, [$d701]
    ld c, a
    ld e, a
    call Call_000_1fe3
    ld a, [$d6fd]
    or a
    ret z

    ld a, [$d6fe]
    ld b, a
    ld a, [$d6ff]
    sub b
    ret c

    ld a, [$d700]
    inc a
    ld [$d700], a
    ld a, [$d701]
    dec a
    ld [$d701], a
    ld a, [$d700]
    ld b, a
    ld a, [$d701]
    sub b
    ret c

    ld a, [$d70d]
    ld c, a
    ld a, [$d70e]
    ld [$d70d], a
    ld a, c
    ld [$d70e], a

jr_000_1fb4:
    ld a, [$d6fe]
    ld b, a
    ld a, [$d6ff]
    ld d, a
    ld a, [$d700]
    ld c, a
    ld e, a
    call Call_000_1fe3
    ld a, [$d701]
    ld b, a
    ld a, [$d700]
    cp b
    jr z, jr_000_1fd4

    inc a
    ld [$d700], a
    jr jr_000_1fb4

jr_000_1fd4:
    ld a, [$d70d]
    ld c, a
    ld a, [$d70e]
    ld [$d70d], a
    ld a, c
    ld [$d70e], a
    ret


Call_000_1fe3:
    ld a, c
    sub e
    jr nc, jr_000_1fe9

    cpl
    inc a

jr_000_1fe9:
    ld [$d703], a
    ld h, a
    ld a, b
    sub d
    jr nc, jr_000_1ff3

    cpl
    inc a

jr_000_1ff3:
    ld [$d702], a
    sub h
    jp c, Jump_000_2160

    ld a, b
    sub d
    jp nc, Jump_000_200b

    ld a, c
    sub e
    jr z, jr_000_2017

    ld a, $00
    jr nc, jr_000_2017

    ld a, $ff
    jr jr_000_2017

Jump_000_200b:
    ld a, e
    sub c
    jr z, jr_000_2015

    ld a, $00
    jr nc, jr_000_2015

    ld a, $ff

jr_000_2015:
    ld b, d
    ld c, e

jr_000_2017:
    ld [$d704], a
    ld hl, $2c02
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
    ld a, [$d703]
    or a
    jp z, Jump_000_2104

    push hl
    ld h, $00
    ld l, a
    add hl, hl
    ld a, h
    ld [$d707], a
    ld a, l
    ld [$d708], a
    ld d, h
    ld e, l
    ld a, [$d702]
    cpl
    ld l, a
    ld h, $ff
    inc hl
    add hl, de
    ld a, h
    ld [$d705], a
    ld a, l
    ld [$d706], a
    ld a, [$d702]
    cpl
    ld l, a
    ld h, $ff
    inc hl
    ld a, [$d703]
    ld d, $00
    ld e, a
    add hl, de
    add hl, hl
    ld a, h
    ld [$d709], a
    ld a, l
    ld [$d70a], a
    pop hl
    ld a, [$d702]
    ld e, a
    ld a, b
    and $07
    add $10
    ld c, a
    ld b, $00
    ld a, [bc]
    ld b, a
    ld c, a

Jump_000_207a:
    rrc c
    ld a, [$d705]
    bit 7, a
    jr z, jr_000_20ab

    push de
    bit 7, c
    jr z, jr_000_2092

    ld a, b
    cpl
    ld c, a
    call Call_000_2291
    dec hl
    ld c, $80
    ld b, c

jr_000_2092:
    ld a, [$d706]
    ld d, a
    ld a, [$d708]
    add d
    ld [$d706], a
    ld a, [$d705]
    ld d, a
    ld a, [$d707]
    adc d
    ld [$d705], a
    pop de
    jr jr_000_20ec

jr_000_20ab:
    push de
    push bc
    ld a, b
    cpl
    ld c, a
    call Call_000_2291
    ld a, [$d704]
    or a
    jr z, jr_000_20c5

    inc hl
    ld a, l
    and $0f
    jr nz, jr_000_20d3

    ld de, $0130
    add hl, de
    jr jr_000_20d3

jr_000_20c5:
    dec hl
    dec hl
    dec hl
    ld a, l
    and $0f
    xor $0e
    jr nz, jr_000_20d3

    ld de, $fed0
    add hl, de

jr_000_20d3:
    ld a, [$d706]
    ld d, a
    ld a, [$d70a]
    add d
    ld [$d706], a
    ld a, [$d705]
    ld d, a
    ld a, [$d709]
    adc d
    ld [$d705], a
    pop bc
    ld b, c
    pop de

jr_000_20ec:
    bit 7, c
    jr z, jr_000_20f7

    push de
    ld de, $0010
    add hl, de
    pop de
    ld b, c

jr_000_20f7:
    ld a, b
    or c
    ld b, a
    dec e
    jp nz, Jump_000_207a

    ld a, b
    cpl
    ld c, a
    jp Jump_000_2291


Jump_000_2104:
    ld a, [$d702]
    ld e, a
    inc e
    ld a, b
    and $07
    jr z, jr_000_2122

    push hl
    add $10
    ld l, a
    ld h, $00
    ld c, [hl]
    pop hl
    xor a

jr_000_2117:
    rrca
    or c
    dec e
    jr z, jr_000_212a

    bit 0, a
    jr z, jr_000_2117

    jr jr_000_212a

jr_000_2122:
    ld a, e
    dec a
    and $f8
    jr z, jr_000_2151

    jr jr_000_2136

jr_000_212a:
    ld b, a
    cpl
    ld c, a
    push de
    call Call_000_2291
    ld de, $000f
    add hl, de
    pop de

jr_000_2136:
    ld a, e
    or a
    ret z

    and $f8
    jr z, jr_000_2151

    xor a
    ld c, a
    cpl
    ld b, a
    push de
    call Call_000_2291
    ld de, $000f
    add hl, de
    pop de
    ld a, e
    sub $08
    ret z

    ld e, a
    jr jr_000_2136

jr_000_2151:
    ld a, $80

jr_000_2153:
    dec e
    jr z, jr_000_215a

    sra a
    jr jr_000_2153

jr_000_215a:
    ld b, a
    cpl
    ld c, a
    jp Jump_000_2291


Jump_000_2160:
    ld a, c
    sub e
    jp nc, Jump_000_2171

    ld a, b
    sub d
    jr z, jr_000_217d

    ld a, $00
    jr nc, jr_000_217d

    ld a, $ff
    jr jr_000_217d

Jump_000_2171:
    ld a, c
    sub e
    jr z, jr_000_217b

    ld a, $00
    jr nc, jr_000_217b

    ld a, $ff

jr_000_217b:
    ld b, d
    ld c, e

jr_000_217d:
    ld [$d704], a
    ld hl, $2c02
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
    ld a, [$d703]
    ld e, a
    inc e
    ld a, [$d702]
    or a
    jp z, Jump_000_2253

    push hl
    ld h, $00
    ld l, a
    add hl, hl
    ld a, h
    ld [$d707], a
    ld a, l
    ld [$d708], a
    ld d, h
    ld e, l
    ld a, [$d703]
    cpl
    ld l, a
    ld h, $ff
    inc hl
    add hl, de
    ld a, h
    ld [$d705], a
    ld a, l
    ld [$d706], a
    ld a, [$d703]
    cpl
    ld l, a
    ld h, $ff
    inc hl
    ld a, [$d702]
    ld d, $00
    ld e, a
    add hl, de
    add hl, hl
    ld a, h
    ld [$d709], a
    ld a, l
    ld [$d70a], a
    pop hl
    ld a, [$d703]
    ld e, a
    ld a, b
    and $07
    add $10
    ld c, a
    ld b, $00
    ld a, [bc]
    ld b, a
    ld c, a

jr_000_21e5:
    push de
    push bc
    ld a, b
    cpl
    ld c, a
    call Call_000_2291
    inc hl
    ld a, l
    and $0f
    jr nz, jr_000_21f7

    ld de, $0130
    add hl, de

jr_000_21f7:
    pop bc
    ld a, [$d705]
    bit 7, a
    jr z, jr_000_2217

    ld a, [$d706]
    ld d, a
    ld a, [$d708]
    add d
    ld [$d706], a
    ld a, [$d705]
    ld d, a
    ld a, [$d707]
    adc d
    ld [$d705], a
    jr jr_000_2249

jr_000_2217:
    ld a, [$d704]
    or a
    jr nz, jr_000_2229

    rlc b
    bit 0, b
    jr z, jr_000_2233

    ld de, $fff0
    add hl, de
    jr jr_000_2233

jr_000_2229:
    rrc b
    bit 7, b
    jr z, jr_000_2233

    ld de, $0010
    add hl, de

jr_000_2233:
    ld a, [$d706]
    ld d, a
    ld a, [$d70a]
    add d
    ld [$d706], a
    ld a, [$d705]
    ld d, a
    ld a, [$d709]
    adc d
    ld [$d705], a

jr_000_2249:
    pop de
    dec e
    jr nz, jr_000_21e5

    ld a, b
    cpl
    ld c, a
    jp Jump_000_2291


Jump_000_2253:
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

jr_000_2261:
    push de
    call Call_000_2291
    inc hl
    ld a, l
    and $0f
    jr nz, jr_000_226f

    ld de, $0130
    add hl, de

jr_000_226f:
    pop de
    dec e
    ret z

    jr jr_000_2261

Call_000_2274:
    ld hl, $2c02
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

Call_000_2291:
Jump_000_2291:
    ld a, [$d70d]
    ld d, a
    ld a, [$d6fc]
    cp $01
    jr z, jr_000_22c5

    cp $02
    jr z, jr_000_22df

    cp $03
    jr z, jr_000_22f9

    ld e, b
    bit 0, d
    jr nz, jr_000_22ac

    push bc
    ld b, $00

jr_000_22ac:
    bit 1, d
    jr nz, jr_000_22b2

    ld e, $00

jr_000_22b2:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_22b2

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


jr_000_22c5:
    ld c, b
    bit 0, d
    jr nz, jr_000_22cc

    ld b, $00

jr_000_22cc:
    bit 1, d
    jr nz, jr_000_22d2

    ld c, $00

jr_000_22d2:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_22d2

    ld a, [hl]
    or b
    ld [hl+], a
    ld a, [hl]
    or c
    ld [hl], a
    ret


jr_000_22df:
    ld c, b
    bit 0, d
    jr nz, jr_000_22e6

    ld b, $00

jr_000_22e6:
    bit 1, d
    jr nz, jr_000_22ec

    ld c, $00

jr_000_22ec:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_22ec

    ld a, [hl]
    xor b
    ld [hl+], a
    ld a, [hl]
    xor c
    ld [hl], a
    ret


jr_000_22f9:
    ld b, c
    bit 0, d
    jr z, jr_000_2300

    ld b, $ff

jr_000_2300:
    bit 1, d
    jr z, jr_000_2306

    ld c, $ff

jr_000_2306:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_2306

    ld a, [hl]
    and b
    ld [hl+], a
    ld a, [hl]
    and c
    ld [hl], a
    ret


Call_000_2313:
    ld hl, $2c02
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

jr_000_232e:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_232e

    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld e, a
    ld b, $00
    ld a, d
    and c
    jr z, jr_000_2340

    set 0, b

jr_000_2340:
    ld a, e
    and c
    jr z, jr_000_2346

    set 1, b

jr_000_2346:
    ld e, b
    ret


Call_000_2348:
    ld hl, $2c02
    ld d, $00
    ld a, [$d70c]
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
    ld a, [$d70b]
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
    ld de, $2e4d
    add hl, de
    ld d, h
    ld e, l
    ld h, b
    ld l, c
    ld a, [$d70d]
    ld c, a

jr_000_2377:
    ld a, [de]
    inc de
    push de
    push hl
    ld hl, $d70e
    ld l, [hl]
    ld b, a
    xor a
    bit 0, l
    jr z, jr_000_2386

    cpl

jr_000_2386:
    or b
    bit 0, c
    jr nz, jr_000_238c

    xor b

jr_000_238c:
    ld d, a
    xor a
    bit 1, l
    jr z, jr_000_2393

    cpl

jr_000_2393:
    or b
    bit 1, c
    jr nz, jr_000_2399

    xor b

jr_000_2399:
    ld e, a
    pop hl

jr_000_239b:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_239b

    ld a, d
    ld [hl+], a
    ld a, e
    ld [hl+], a
    pop de
    ld a, l
    and $0f
    jr nz, jr_000_2377

    ret


Call_000_23ac:
    ld hl, sp+$02
    ld a, [hl+]
    ld [$d70b], a
    ld a, [hl+]
    ld [$d70c], a
    ret


Call_000_23b7:
    push bc
    ld a, [$d6a3]
    cp $01
    call nz, Call_000_2b31
    ld hl, sp+$04
    ld a, [hl]
    ld c, a
    call Call_000_2348
    call Call_000_1d3b
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    call Call_000_2313
    pop bc
    ret


Call_000_23d8:
    ld hl, sp+$02
    ld a, [hl+]
    ld [$d70d], a
    ld a, [hl+]
    ld [$d70e], a
    ld a, [hl]
    ld [$d6fc], a
    ret


    push bc
    ld a, [$d6a3]
    cp $01
    call nz, Call_000_2b31
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld d, a
    ld a, [hl]
    ld [$d6fd], a
    call Call_000_1d58
    pop bc
    ret


Call_000_2401:
    push bc
    ld a, [$d6a3]
    cp $01
    call nz, Call_000_2b31
    ld hl, sp+$04
    ld a, [hl+]
    ld [$d6fe], a
    ld a, [hl+]
    ld [$d700], a
    ld a, [hl+]
    ld [$d6ff], a
    ld a, [hl+]
    ld [$d701], a
    ld a, [hl]
    ld [$d6fd], a
    call Call_000_1f0d
    pop bc
    ret


Call_000_2425:
    push bc
    ld a, [$d6a3]
    cp $01
    call nz, Call_000_2b31
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld e, a
    call Call_000_1fe3
    pop bc
    ret


Call_000_243d:
    push bc
    ld a, [$d6a3]
    cp $01
    call nz, Call_000_2b31
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    call Call_000_2274
    pop bc
    ret


    push bc
    ld a, [$d6a3]
    cp $01
    call nz, Call_000_2b31
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld [$d70d], a
    ld a, [hl+]
    ld [$d6fc], a
    call Call_000_2274
    pop bc
    ret


Call_000_246d:
    jp Jump_000_2a08


    jp Jump_000_262d


Call_000_2473:
    jp Jump_000_26be


    jp Jump_000_276f


Call_000_2479:
    jp Jump_000_2843


    ld a, $05
    rst RST_08
    jp Jump_000_2816


    ld a, $05
    rst RST_08
    jp Jump_000_24f0


    ld a, $05
    rst RST_08
    jp Jump_000_2530


    ld a, $05
    rst RST_08
    jp Jump_000_27e9


    ld a, $05
    rst RST_08
    jp Jump_000_24d6


    ld a, $05
    rst RST_08
    jp Jump_000_27f8


    ld a, $05
    rst RST_08
    jp Jump_000_2516


    ld a, $05
    rst RST_08
    jp Jump_000_24e4


    ld a, $05
    rst RST_08
    jp Jump_000_2524


    ld a, $05
    rst RST_08
    jp Jump_000_2504


    ld a, $05
    rst RST_08
    jp Jump_000_2544


    ld a, $05
    rst RST_08
    jp Jump_000_25d6


    ld a, $05
    rst RST_08
    jp Jump_000_25f3


    ld a, $05
    rst RST_08
    jp Jump_000_2610


    ld a, $05
    rst RST_08
    jp Jump_000_2610


Jump_000_24d6:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_2556
    ld e, c
    ld d, b
    ret


Jump_000_24e4:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_2556
    ret


Jump_000_24f0:
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
    call Call_000_255e
    ld e, c
    ld d, b
    ret


Jump_000_2504:
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
    call Call_000_255e
    ret


Call_000_2516:
Jump_000_2516:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_2590
    ld e, c
    ld d, b
    ret


Call_000_2524:
Jump_000_2524:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_2590
    ret


Call_000_2530:
Jump_000_2530:
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
    call Call_000_2593
    ld e, c
    ld d, b
    ret


Jump_000_2544:
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
    call Call_000_2593
    ret


Call_000_2556:
    ld a, c
    rlca
    sbc a
    ld b, a
    ld a, e
    rlca
    sbc a
    ld d, a

Call_000_255e:
    ld a, b
    push af
    xor d
    push af
    bit 7, d
    jr z, jr_000_256c

    sub a
    sub e
    ld e, a
    sbc a
    sub d
    ld d, a

jr_000_256c:
    bit 7, b
    jr z, jr_000_2576

    sub a
    sub c
    ld c, a
    sbc a
    sub b
    ld b, a

jr_000_2576:
    call Call_000_2593
    ret c

    pop af
    and $80
    jr z, jr_000_2585

    sub a
    sub c
    ld c, a
    sbc a
    sub b
    ld b, a

jr_000_2585:
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


Call_000_2590:
    ld b, $00
    ld d, b

Call_000_2593:
    ld a, e
    or d
    jr nz, jr_000_259e

    ld bc, $0000
    ld d, b
    ld e, c
    scf
    ret


jr_000_259e:
    ld l, c
    ld h, b
    ld bc, $0000
    or a
    ld a, $10

jr_000_25a6:
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
    jr c, jr_000_25bc

    pop bc
    jr jr_000_25be

jr_000_25bc:
    inc sp
    inc sp

jr_000_25be:
    jr c, jr_000_25c7

    pop af
    dec a
    or a
    jr nz, jr_000_25a6

    jr jr_000_25cc

jr_000_25c7:
    pop af
    dec a
    scf
    jr nz, jr_000_25a6

jr_000_25cc:
    ld d, b
    ld e, c
    rl l
    ld c, l
    rl h
    ld b, h
    or a
    ret


Call_000_25d6:
Jump_000_25d6:
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

Jump_000_25e5:
    or a
    ret z

    rr h
    rr l
    rr d
    rr e
    dec a
    jp Jump_000_25e5


Jump_000_25f3:
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

Jump_000_2602:
    or a
    ret z

    sra h
    rr l
    rr d
    rr e
    dec a
    jp Jump_000_2602


Call_000_2610:
Jump_000_2610:
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

Jump_000_261f:
    or a
    ret z

    rl e
    rl d
    rl l
    rl h
    dec a
    jp Jump_000_261f


Jump_000_262d:
    add sp, -$09
    ld b, $04
    ld hl, sp+$0b
    call Call_000_2704
    jr nz, jr_000_2640

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_26a3


jr_000_2640:
    ld hl, sp+$0f
    call Call_000_2704
    jr nz, jr_000_2656

    ld a, $21
    ld [$d6a0], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_26a3


jr_000_2656:
    ld hl, sp+$00
    xor a
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    bit 7, a
    jr z, jr_000_266a

    ld hl, sp+$0f
    call Call_000_2993
    ld hl, sp+$00
    ld [hl], $01

jr_000_266a:
    ld hl, sp+$0e
    ld a, [hl]
    bit 7, a
    jr z, jr_000_267c

    ld hl, sp+$0b
    call Call_000_2993
    ld hl, sp+$00
    ld a, $01
    xor [hl]
    ld [hl], a

jr_000_267c:
    ld hl, sp+$0f
    push hl
    ld hl, sp+$0d
    push hl
    ld hl, sp+$09
    push hl
    ld hl, sp+$07
    push hl
    call Call_000_2a27
    add sp, $08
    ld hl, sp+$00
    rr [hl]
    jr nc, jr_000_269a

    ld b, $04
    ld hl, sp+$01
    call Call_000_2993

jr_000_269a:
    ld hl, sp+$01
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_26a3:
    add sp, $09
    ret


    ldh a, [rLCDC]
    or $10
    ldh [rLCDC], a
    ld a, $48
    ldh [rLYC], a
    ret


jr_000_26b1:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_26b1

    ldh a, [rLCDC]
    and $ef
    ldh [rLCDC], a
    ret


Jump_000_26be:
    add sp, -$08
    ld b, $04
    ld hl, sp+$0a
    call Call_000_2704
    jr nz, jr_000_26d1

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_2701


jr_000_26d1:
    ld hl, sp+$0e
    call Call_000_2704
    jr nz, jr_000_26e7

    ld a, $21
    ld [$d6a0], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_2701


jr_000_26e7:
    ld hl, sp+$0e
    push hl
    ld hl, sp+$0c
    push hl
    ld hl, sp+$08
    push hl
    ld hl, sp+$06
    push hl
    call Call_000_2a27
    add sp, $08
    ld hl, sp+$00
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_2701:
    add sp, $08
    ret


Call_000_2704:
    xor a
    ld c, b

jr_000_2706:
    cp [hl]
    ret nz

    inc hl
    dec c
    jr nz, jr_000_2706

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


Call_000_2719:
    xor a
    bit 7, [hl]
    jr z, jr_000_2720

    ld a, $80

jr_000_2720:
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


jr_000_2732:
    ld c, $03

jr_000_2734:
    ld a, [de]
    sub [hl]
    ret nz

    dec de
    dec hl
    dec c
    ret z

    jr jr_000_2734

    ld hl, sp+$07
    call Call_000_2719
    ld hl, sp+$0b
    call Call_000_2719
    ld hl, sp+$07
    bit 7, [hl]
    jr z, jr_000_275e

    ld hl, sp+$0b
    bit 7, [hl]
    jr z, jr_000_275b

    ld hl, sp+$0b
    ld d, h
    ld e, l
    ld hl, sp+$07
    jr jr_000_2732

jr_000_275b:
    xor a
    ccf
    ret


jr_000_275e:
    ld hl, sp+$0b
    bit 7, [hl]
    jr z, jr_000_2767

    xor a
    dec a
    ret


jr_000_2767:
    ld hl, sp+$07
    ld d, h
    ld e, l
    ld hl, sp+$0b
    jr jr_000_2732

Jump_000_276f:
    add sp, -$09
    ld b, $04
    ld hl, sp+$0b
    call Call_000_2704
    jr nz, jr_000_2782

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_27e6


jr_000_2782:
    ld hl, sp+$0f
    call Call_000_2704
    jr nz, jr_000_2798

    ld a, $21
    ld [$d6a0], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_27e6


jr_000_2798:
    ld hl, sp+$00
    xor a
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    bit 7, a
    jr z, jr_000_27ac

    ld hl, sp+$0f
    call Call_000_2993
    ld hl, sp+$00
    ld [hl], $01

jr_000_27ac:
    ld hl, sp+$0e
    ld a, [hl]
    bit 7, a
    jr z, jr_000_27be

    ld hl, sp+$0b
    call Call_000_2993
    ld hl, sp+$00
    ld a, $01
    xor [hl]
    ld [hl], a

jr_000_27be:
    ld hl, sp+$0f
    push hl
    ld hl, sp+$0d
    push hl
    ld hl, sp+$09
    push hl
    ld hl, sp+$07
    push hl
    call Call_000_2a27
    add sp, $08
    ld hl, sp+$00
    rr [hl]
    jr nc, jr_000_27dd

    ld b, $04
    xor a
    ld hl, sp+$05
    call Call_000_2993

jr_000_27dd:
    ld hl, sp+$05
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_27e6:
    add sp, $09
    ret


Jump_000_27e9:
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
    jr jr_000_281f

Jump_000_27f8:
    ld hl, sp+$02
    ld a, [hl+]
    ld c, a
    ld e, [hl]

Call_000_27fd:
    xor a
    ld h, a
    ld l, a
    ld d, a

jr_000_2801:
    xor a
    rr c
    jr nc, jr_000_2807

    add hl, de

jr_000_2807:
    sla e
    jr z, jr_000_280f

    rl d
    jr jr_000_2801

jr_000_280f:
    rl d
    jr nz, jr_000_2801

    ld e, l
    ld d, h
    ret


Jump_000_2816:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld c, [hl]
    inc hl
    ld b, [hl]

jr_000_281f:
    ld hl, $0000

jr_000_2822:
    sra b
    jr nz, jr_000_282f

    rr c
    jr nc, jr_000_282b

    add hl, de

jr_000_282b:
    jr z, jr_000_2840

    jr jr_000_2834

jr_000_282f:
    rr c
    jr nc, jr_000_2834

    add hl, de

jr_000_2834:
    sla e
    jr z, jr_000_283c

    rl d
    jr jr_000_2822

jr_000_283c:
    rl d
    jr nz, jr_000_2822

jr_000_2840:
    ld e, l
    ld d, h
    ret


Jump_000_2843:
    add sp, -$08
    ld b, $04
    ld hl, sp+$0a
    call Call_000_2704
    jr nz, jr_000_2856

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_2886


jr_000_2856:
    ld hl, sp+$0e
    call Call_000_2704
    jr nz, jr_000_286c

    ld a, $21
    ld [$d6a0], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_2886


jr_000_286c:
    ld hl, sp+$0e
    push hl
    ld hl, sp+$0c
    push hl
    ld hl, sp+$08
    push hl
    ld hl, sp+$06
    push hl
    call Call_000_2a27
    add sp, $08
    ld hl, sp+$04
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_2886:
    add sp, $08
    ret


Call_000_2889:
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

Jump_000_2897:
    ld a, [bc]
    inc bc
    or a
    jp nz, Jump_000_2897

    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b

Jump_000_28a2:
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
    jp nz, Jump_000_28ba

    dec hl
    ld a, [hl+]
    inc hl
    sub [hl]
    jp z, Jump_000_28cc

Jump_000_28ba:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld hl, sp+$08
    sub [hl]
    jp nz, Jump_000_28c9

    jr jr_000_28cc

Jump_000_28c9:
    jp Jump_000_28a2


Jump_000_28cc:
jr_000_28cc:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld hl, sp+$08
    sub [hl]
    jp nz, Jump_000_28db

    jr jr_000_28de

Jump_000_28db:
    jp Jump_000_28e6


jr_000_28de:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    jp Jump_000_28e9


Jump_000_28e6:
    ld de, $0000

Jump_000_28e9:
    add sp, $04
    ret


Call_000_28ec:
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

jr_000_28f9:
    ld a, b
    or c
    ret z

    dec bc
    ld [hl], d
    inc hl
    jr jr_000_28f9

Call_000_2901:
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

jr_000_2910:
    ld a, b
    or c
    ret z

    ld a, [de]
    inc de
    ld [hl], a
    dec bc
    inc hl
    jr jr_000_2910

Call_000_291a:
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

Jump_000_2938:
    ld a, c
    or b
    jp z, Jump_000_2962

    ld hl, sp+$03
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$00
    ld [hl], a
    or a
    jp z, Jump_000_2962

    dec bc
    ld a, [hl]
    ld hl, sp+$03
    inc [hl]
    jr nz, jr_000_2953

    inc hl
    inc [hl]

jr_000_2953:
    ld hl, sp+$01
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_000_295f

    inc hl
    inc [hl]

jr_000_295f:
    jp Jump_000_2938


Jump_000_2962:
    ld hl, sp+$03
    ld [hl], c
    inc hl
    ld [hl], b

Jump_000_2967:
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
    jp z, Jump_000_298b

    ld hl, sp+$01
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_000_2988

    inc hl
    inc [hl]

jr_000_2988:
    jp Jump_000_2967


Jump_000_298b:
    ld hl, sp+$05
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $07
    ret


Call_000_2993:
    ld c, b
    xor a
    ld d, a

jr_000_2996:
    ld a, d
    sbc [hl]
    ld [hl+], a
    dec c
    jr nz, jr_000_2996

    ret


    push bc
    ld hl, sp+$04
    ld a, [hl]
    call Call_000_380b
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld a, [hl]
    call Call_000_3834
    pop bc
    ret


    ld hl, sp+$02
    ld a, [hl+]
    ld [$d725], a
    ld a, [hl]
    ld [$d726], a
    ret


    ld a, [$d6a3]
    and $02
    jr nz, jr_000_29c6

    push bc
    call Call_000_3968
    pop bc

jr_000_29c6:
    ld a, [$d725]
    ld e, a
    ret


    ld a, [$d6a3]
    and $02
    jr nz, jr_000_29d7

    push bc
    call Call_000_3968
    pop bc

jr_000_29d7:
    ld a, [$d726]
    ld e, a
    ret


Call_000_29dc:
    push af
    ld hl, sp+$00
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]

Jump_000_29e9:
    ld a, [bc]
    inc bc
    or a
    jp z, Jump_000_29f9

    ld hl, sp+$00
    inc [hl]
    jr nz, jr_000_29f6

    inc hl
    inc [hl]

jr_000_29f6:
    jp Jump_000_29e9


Jump_000_29f9:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $02
    ret


Call_000_2a01:
    ld c, b
    xor a

jr_000_2a03:
    ld [hl+], a
    dec c
    jr nz, jr_000_2a03

    ret


Jump_000_2a08:
    add sp, -$04
    ld hl, sp+$0a
    push hl
    ld hl, sp+$08
    push hl
    ld hl, sp+$04
    push hl
    ld b, $04
    call Call_000_2a87
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


Call_000_2a27:
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
    call Call_000_2a01
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call Call_000_2a01

jr_000_2a40:
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    xor a
    call Call_000_2b29
    push af
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    pop af
    push hl
    call Call_000_2b29
    pop de
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push de
    push hl
    call Call_000_2b1f
    pop hl
    pop de
    jr c, jr_000_2a66

    call Call_000_2a77

jr_000_2a66:
    ccf
    push af
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    pop af
    call Call_000_2b29
    pop bc
    dec c
    ret z

    push bc
    jr jr_000_2a40

Call_000_2a77:
    ld c, b

jr_000_2a78:
    ld a, [de]
    sbc [hl]
    ld [de], a
    inc hl
    inc de
    dec c
    jr nz, jr_000_2a78

    ret


    ld c, b

jr_000_2a82:
    ld [hl+], a
    dec c
    jr nz, jr_000_2a82

    ret


Call_000_2a87:
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
    call Call_000_2a01
    ld hl, sp+$04
    ld [hl], b

Jump_000_2aa5:
    ld hl, sp+$04
    ld a, [hl]
    ld hl, sp+$05
    ld [hl], a

jr_000_2aab:
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
    call Call_000_27fd
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
    jr z, jr_000_2adf

    ld a, [hl]
    adc d
    ld [hl+], a
    call Call_000_2b0a
    ld hl, sp+$05
    dec [hl]
    jr z, jr_000_2adf

    ld hl, sp+$0c
    call Call_000_2b12
    ld hl, sp+$08
    call Call_000_2b12
    jr jr_000_2aab

jr_000_2adf:
    ld hl, sp+$04
    dec [hl]
    jr z, jr_000_2b07

    ld hl, sp+$00
    call Call_000_2b12
    ld hl, sp+$0a
    call Call_000_2b12
    push bc
    ld b, $02
    ld hl, sp+$02
    ld d, h
    ld e, l
    ld hl, sp+$0a
    call Call_000_2b17
    ld hl, sp+$04
    ld d, h
    ld e, l
    ld hl, sp+$0e
    call Call_000_2b17
    pop bc
    jp Jump_000_2aa5


jr_000_2b07:
    add sp, $06
    ret


Call_000_2b0a:
jr_000_2b0a:
    dec c
    ret z

    ld a, $00
    adc [hl]
    ld [hl+], a
    jr jr_000_2b0a

Call_000_2b12:
    inc [hl]
    ret nz

    inc hl
    inc [hl]
    ret


Call_000_2b17:
    ld c, b

jr_000_2b18:
    ld a, [de]
    inc de
    ld [hl+], a
    dec c
    jr nz, jr_000_2b18

    ret


Call_000_2b1f:
    ld c, b
    xor a

jr_000_2b21:
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    dec c
    jr nz, jr_000_2b21

    ret


Call_000_2b29:
    ld c, b

jr_000_2b2a:
    rl [hl]
    inc hl
    dec c
    jr nz, jr_000_2b2a

    ret


Call_000_2b31:
Jump_000_2b31:
    di
    ldh a, [rLCDC]
    bit 7, a
    jr z, jr_000_2b3b

    call Call_000_069f

jr_000_2b3b:
    ld hl, $8100
    ld de, $1680
    ld b, $00
    call Call_000_39a1
    ld bc, $26a6
    call Call_000_062e
    ld bc, $26b1
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

jr_000_2b6a:
    ld d, $14

jr_000_2b6c:
    ld [hl+], a
    inc a
    dec d
    jr nz, jr_000_2b6c

    add hl, bc
    dec e
    jr nz, jr_000_2b6a

    ldh a, [rLCDC]
    or $91
    and $f7
    ldh [rLCDC], a
    ld a, $01
    ld [$d6a3], a
    ld a, $00
    ld [$d6fc], a
    ld a, $03
    ld [$d70d], a
    ld a, $00
    ld [$d70e], a
    ei
    ret


Call_000_2b93:
    ld hl, $8100
    ld de, $1680
    call Call_000_2d22
    ret


Call_000_2b9d:
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
    ld hl, $2c02
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
    jr z, jr_000_2bcb

    ld de, $0010
    call Call_000_2d22

jr_000_2bcb:
    pop hl
    pop bc
    ld de, $0010
    call Call_000_2d22
    ret


    push bc
    ld a, [$d6a3]
    cp $01
    call nz, Call_000_2b31
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
    call Call_000_2b9d
    pop bc
    ret


    push bc
    ld a, [$d6a3]
    cp $01
    call nz, Call_000_2b31
    ld hl, sp+$04
    ld a, [hl+]
    ld c, a
    ld b, [hl]
    call Call_000_2b93
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

Call_000_2d22:
jr_000_2d22:
    ldh a, [rSTAT]
    and $02
    jr nz, jr_000_2d22

    ld a, [bc]
    ld [hl+], a
    inc bc
    dec de
    ld a, d
    or e
    jr nz, jr_000_2d22

    ret


Call_000_2d31:
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
    call Call_000_2d22
    pop bc
    ret


    ld hl, $2d4b
    call Call_000_376e
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
    jr jr_000_2d80

    ld a, [de]
    dec de
    inc e
    dec e
    ld e, $1f
    jr nz, jr_000_2d90

    ld [hl+], a
    inc hl
    inc h
    dec h
    ld h, $27
    jr z, jr_000_2da0

    ld a, [hl+]
    dec hl
    inc l
    dec l
    ld l, $2f
    jr nc, jr_000_2db0

    ld [hl-], a

jr_000_2d80:
    inc sp
    inc [hl]
    dec [hl]
    ld [hl], $37
    jr c, jr_000_2dc0

    ld a, [hl-]
    dec sp
    inc a
    dec a
    ld a, $3f
    ld b, b
    ld b, c
    ld b, d

jr_000_2d90:
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

jr_000_2da0:
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

jr_000_2db0:
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

jr_000_2dc0:
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
    jr jr_000_2e7b

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
    jr jr_000_2e86

    jr z, jr_000_2ebf

    add c
    add c
    ld c, a
    jr z, jr_000_2e8d

    rst RST_38
    add c
    add c
    add c
    add c
    add c

jr_000_2e7b:
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

jr_000_2e86:
    adc c
    adc c
    adc c
    ld sp, hl
    add c
    add c
    rst RST_38

jr_000_2e8d:
    ld bc, $0603
    adc h
    ret c

    ld [hl], b
    jr nz, jr_000_2e95

jr_000_2e95:
    ld a, [hl]
    jp $d3d3


    db $db
    jp $7ec3


    jr jr_000_2edb

    inc l
    inc l
    ld a, [hl]
    jr jr_000_2ebc

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
    jr jr_000_2eb5

jr_000_2eb5:
    ld [hl], b
    ret z

    sbc $db
    db $db
    ld a, [hl]
    dec de

jr_000_2ebc:
    dec de
    nop
    nop

jr_000_2ebf:
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

jr_000_2edb:
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

    jr jr_000_2f71

    jr jr_000_2f5b

jr_000_2f5b:
    jr jr_000_2f5d

jr_000_2f5d:
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

jr_000_2f71:
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
    jr jr_000_2f9f

    stop
    nop
    nop
    nop
    nop
    inc b
    ld [$1818], sp
    jr jr_000_2fab

    ld [$2004], sp
    db $10
    jr jr_000_2fb1

    jr @+$1a

    db $10
    jr nz, jr_000_2f9e

jr_000_2f9e:
    ld d, h

jr_000_2f9f:
    jr c, jr_000_2f9f

    jr c, jr_000_2ff7

    nop
    nop
    nop
    jr jr_000_2fc0

    ld a, [hl]
    jr @+$1a

jr_000_2fab:
    nop
    nop
    nop
    nop
    nop
    nop

jr_000_2fb1:
    nop
    jr nc, jr_000_2fe4

    jr nz, jr_000_2fb6

jr_000_2fb6:
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

jr_000_2fc0:
    nop
    nop
    jr @+$1a

    nop
    inc bc
    ld b, $0c
    jr jr_000_2ffa

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
    jr jr_000_300f

    jr jr_000_2ff1

    jr jr_000_2ff3

    jr jr_000_2fdd

jr_000_2fdd:
    inc a
    ld h, [hl]
    ld c, $1c
    jr c, jr_000_3053

    ld a, [hl]

jr_000_2fe4:
    nop
    ld a, [hl]
    inc c
    jr jr_000_3025

    ld b, $46
    inc a
    nop
    inc c
    inc e
    inc l
    ld c, h

jr_000_2ff1:
    ld a, [hl]
    inc c

jr_000_2ff3:
    inc c
    nop
    ld a, [hl]
    ld h, b

jr_000_2ff7:
    ld a, h
    ld b, $06

jr_000_2ffa:
    ld b, [hl]
    inc a
    nop
    inc e
    jr nz, jr_000_3060

    ld a, h
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    ld a, [hl]
    ld b, $0e
    inc e
    jr @+$1a

    jr jr_000_300d

jr_000_300d:
    inc a
    ld h, [hl]

jr_000_300f:
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
    jr c, jr_000_301d

jr_000_301d:
    nop
    jr jr_000_3038

    nop
    nop
    jr jr_000_303c

    nop

jr_000_3025:
    nop
    jr jr_000_3040

    nop
    jr jr_000_3043

    stop
    ld b, $0c
    jr jr_000_3061

    jr @+$0e

    ld b, $00
    nop
    nop
    inc a

jr_000_3038:
    nop
    nop
    inc a
    nop

jr_000_303c:
    nop
    ld h, b
    jr nc, jr_000_3058

jr_000_3040:
    inc c
    jr jr_000_3073

jr_000_3043:
    ld h, b
    nop
    inc a
    ld b, [hl]
    ld b, $0c
    jr jr_000_3063

    nop
    jr jr_000_308a

    ld h, [hl]
    ld l, [hl]
    ld l, d
    ld l, [hl]
    ld h, b

jr_000_3053:
    inc a
    nop
    inc a
    ld h, [hl]
    ld h, [hl]

jr_000_3058:
    ld a, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    nop
    ld a, h
    ld h, [hl]
    ld h, [hl]

jr_000_3060:
    ld a, h

jr_000_3061:
    ld h, [hl]
    ld h, [hl]

jr_000_3063:
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

jr_000_3073:
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

jr_000_308a:
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
    jr jr_000_30af

    jr jr_000_30b1

    jr jr_000_30b3

    jr jr_000_309d

jr_000_309d:
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

jr_000_30af:
    ld h, b
    ld h, b

jr_000_30b1:
    ld h, b
    ld h, b

jr_000_30b3:
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

    jr jr_000_310c

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

jr_000_310c:
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

    jr jr_000_311d

jr_000_311d:
    ld a, [hl]
    ld c, $1c
    jr c, jr_000_3192

    ld h, b
    ld a, [hl]
    nop
    ld e, $18
    jr jr_000_3141

    jr jr_000_3143

    ld e, $00
    ld b, b
    ld h, b
    jr nc, jr_000_3149

    inc c
    ld b, $02
    nop
    ld a, b
    jr jr_000_3150

    jr jr_000_3152

    jr jr_000_31b4

    nop
    db $10
    jr c, jr_000_31ac

    nop

jr_000_3141:
    nop
    nop

jr_000_3143:
    nop
    nop
    nop
    nop
    nop
    nop

jr_000_3149:
    nop
    nop
    ld a, [hl]
    nop
    nop
    ret nz

    ret nz

jr_000_3150:
    ld h, b
    nop

jr_000_3152:
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

    jr nc, jr_000_31b4

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

jr_000_3192:
    ld h, [hl]
    ld h, [hl]
    nop
    jr jr_000_3197

jr_000_3197:
    jr jr_000_31b1

    jr jr_000_31b3

    jr jr_000_319d

jr_000_319d:
    nop
    ld [$1818], sp
    jr jr_000_31bb

    ld e, b
    jr nc, jr_000_3206

    ld h, h
    ld l, b
    ld [hl], b
    ld a, b
    ld l, h
    ld h, [hl]

jr_000_31ac:
    nop
    jr jr_000_31c7

    jr jr_000_31c9

jr_000_31b1:
    jr jr_000_31cb

jr_000_31b3:
    inc c

jr_000_31b4:
    nop
    nop
    db $fc
    sub $d6
    sub $d6

jr_000_31bb:
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

jr_000_31c7:
    ld h, [hl]
    ld h, [hl]

jr_000_31c9:
    ld h, [hl]
    ld h, [hl]

jr_000_31cb:
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
    jr c, jr_000_3206

    ld c, [hl]
    inc a
    nop
    jr jr_000_322b

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

jr_000_3206:
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
    jr c, jr_000_3293

    ld a, [hl]
    nop
    ld c, $18
    jr jr_000_3259

    jr jr_000_3243

jr_000_322b:
    ld c, $00
    jr jr_000_3247

    jr jr_000_3249

    jr jr_000_324b

    jr @+$1a

    ld [hl], b
    jr jr_000_3250

    inc c
    jr jr_000_3253

    ld [hl], b
    nop
    nop
    ld h, b
    ldh a, [c]
    sbc [hl]
    inc c
    nop

jr_000_3243:
    nop
    nop
    db $10
    db $10

jr_000_3247:
    jr z, jr_000_3271

jr_000_3249:
    ld b, h
    ld b, h

jr_000_324b:
    add d
    cp $3c
    ld h, d
    ld h, b

jr_000_3250:
    ld h, b
    ld h, b
    ld h, d

jr_000_3253:
    inc e
    jr nc, @+$26

    nop
    ld h, [hl]
    ld h, [hl]

jr_000_3259:
    ld h, [hl]
    ld h, [hl]
    ld a, $00
    inc c
    jr jr_000_3260

jr_000_3260:
    inc a
    ld a, [hl]
    ld h, b
    inc a
    nop
    jr jr_000_32cd

    nop
    inc a
    ld b, $7e
    ld a, $00
    inc h
    nop
    inc a
    ld b, [hl]

jr_000_3271:
    ld a, $46
    ld a, $00
    jr nc, jr_000_328f

    nop
    inc a
    ld b, $7e
    ld a, $00
    jr jr_000_3297

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

jr_000_328f:
    nop
    inc a
    ld a, [hl]
    ld h, b

jr_000_3293:
    ld a, $00
    inc h
    nop

jr_000_3297:
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
    jr jr_000_32c1

    jr jr_000_32c3

    jr jr_000_32ad

jr_000_32ad:
    jr jr_000_32d3

    nop
    jr jr_000_32ca

    jr jr_000_32cc

    nop
    db $10
    ld [$1800], sp
    jr jr_000_32d3

    jr jr_000_32bd

jr_000_32bd:
    inc h
    nop
    inc a
    ld h, [hl]

jr_000_32c1:
    ld a, [hl]
    ld h, [hl]

jr_000_32c3:
    ld h, [hl]
    nop
    jr jr_000_32c7

jr_000_32c7:
    inc a
    ld h, [hl]
    ld a, [hl]

jr_000_32ca:
    ld h, [hl]
    ld h, [hl]

jr_000_32cc:
    nop

jr_000_32cd:
    inc c
    jr jr_000_334e

    ld h, b
    ld a, h
    ld h, b

jr_000_32d3:
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
    jr jr_000_331b

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
    jr nc, jr_000_330f

    nop
    inc a
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    jr jr_000_3323

    nop
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    jr nc, jr_000_331f

    nop
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    ld h, [hl]
    nop

jr_000_330f:
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

jr_000_331b:
    inc a
    nop
    ld h, [hl]
    nop

jr_000_331f:
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]

jr_000_3323:
    inc a
    nop
    jr jr_000_3363

    ld h, d
    ld h, b
    ld h, b
    ld h, d
    inc a
    jr @+$1e

    ld a, [hl-]
    jr nc, jr_000_33ad

    jr nc, jr_000_3363

    ld a, [hl]
    nop
    ld h, [hl]
    ld h, [hl]
    inc a
    jr jr_000_3376

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

    jr jr_000_3361

    jr jr_000_3363

    jr jr_000_3365

    inc c

jr_000_334e:
    jr jr_000_3350

jr_000_3350:
    inc a
    ld b, $7e
    ld a, $00
    inc c
    jr jr_000_3358

jr_000_3358:
    jr jr_000_3372

    jr jr_000_3374

    nop
    inc c
    jr jr_000_3360

jr_000_3360:
    inc a

jr_000_3361:
    ld h, [hl]
    ld h, [hl]

jr_000_3363:
    inc a
    nop

jr_000_3365:
    inc c
    jr jr_000_3368

jr_000_3368:
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld a, $00
    inc [hl]
    ld e, b
    nop
    ld a, h
    ld h, [hl]

jr_000_3372:
    ld h, [hl]
    ld h, [hl]

jr_000_3374:
    nop
    ld a, [de]

jr_000_3376:
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
    jr jr_000_3390

jr_000_3390:
    jr jr_000_33c2

    ld h, b
    ld h, [hl]
    inc a
    nop
    nop
    nop
    ld a, $30
    jr nc, jr_000_33cc

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

jr_000_33ad:
    ld h, d
    db $e4
    ld l, b
    halt
    ld l, $56
    sbc a
    ld b, $00
    jr jr_000_33b8

jr_000_33b8:
    jr @+$1a

    jr @+$1a

    jr jr_000_33d9

    ld [hl], $6c
    ret c

    ld l, h

jr_000_33c2:
    ld [hl], $1b
    nop
    ret c

    ld l, h
    ld [hl], $1b
    ld [hl], $6c
    ret c

jr_000_33cc:
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

jr_000_33d9:
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
    jr c, jr_000_3439

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

jr_000_3439:
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
    jr nc, jr_000_34f5

jr_000_34f5:
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
    jr c, jr_000_353e

jr_000_353e:
    db $10
    jr c, jr_000_35ad

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
    jr c, jr_000_357d

jr_000_357d:
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
    jr jr_000_35a2

    jr jr_000_35a4

    db $10
    inc a
    jr jr_000_35cc

    ld h, [hl]
    ld h, [hl]
    inc a
    jr jr_000_35d1

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

jr_000_35a2:
    inc h
    ld h, [hl]

jr_000_35a4:
    nop
    inc e
    ld [hl], $78
    call c, $eccc
    ld a, b
    nop

jr_000_35ad:
    inc c
    jr jr_000_35e8

    ld d, h
    ld d, h
    jr c, jr_000_35e4

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

jr_000_35cc:
    nop
    nop
    ld a, [hl]
    nop
    ld a, [hl]

jr_000_35d1:
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
    jr nc, jr_000_35f7

    inc c
    jr jr_000_3612

    nop
    ld a, [hl]

jr_000_35e4:
    nop
    inc c
    jr @+$32

jr_000_35e8:
    jr @+$0e

    nop
    ld a, [hl]
    nop
    nop
    ld c, $1b
    dec de
    jr jr_000_360b

    jr jr_000_360d

    jr jr_000_360f

jr_000_35f7:
    jr jr_000_3611

    ret c

    ret c

    ld [hl], b
    nop
    jr jr_000_3617

    nop
    ld a, [hl]
    nop

jr_000_3602:
    jr jr_000_361c

    nop
    nop
    ld [hl-], a
    ld c, h
    nop
    ld [hl-], a
    ld c, h

jr_000_360b:
    nop
    nop

jr_000_360d:
    jr c, @+$6e

jr_000_360f:
    jr c, jr_000_3611

jr_000_3611:
    nop

jr_000_3612:
    nop
    nop
    nop
    jr c, @+$7e

jr_000_3617:
    jr c, jr_000_3619

jr_000_3619:
    nop
    nop
    nop

jr_000_361c:
    nop
    nop
    nop
    nop
    nop
    jr jr_000_363b

    nop
    nop
    nop
    nop
    rrca
    jr jr_000_3602

    ld [hl], b
    jr nc, jr_000_362d

jr_000_362d:
    jr c, @+$6e

    ld l, h
    ld l, h
    ld l, h
    nop
    nop
    nop
    jr c, @+$6e

    jr jr_000_3669

    ld a, h
    nop

jr_000_363b:
    nop
    nop
    ld a, b
    inc c
    jr c, jr_000_364d

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

jr_000_364d:
    push af
    push bc

jr_000_364f:
    ld b, $ff

jr_000_3651:
    call Call_000_365d
    or a
    jr nz, jr_000_364f

    dec b
    jr nz, jr_000_3651

    pop bc
    pop af
    ret


Call_000_365d:
    push bc
    ld a, $20
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    cpl
    and $0f

jr_000_3669:
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


Call_000_368a:
jr_000_368a:
    call Call_000_365d
    and b
    jr z, jr_000_368a

    ret


Call_000_3691:
    call Call_000_365d
    ld e, a
    ret


    push bc
    ld hl, sp+$04
    ld b, [hl]
    call Call_000_368a
    ld e, a
    pop bc
    ret


Call_000_36a0:
    push bc
    call Call_000_36bd
    ld b, $32

Jump_000_36a6:
    jr jr_000_36a8

jr_000_36a8:
    jr jr_000_36aa

jr_000_36aa:
    jr jr_000_36ac

jr_000_36ac:
    jr jr_000_36ae

jr_000_36ae:
    jr jr_000_36b0

jr_000_36b0:
    dec b
    jp nz, Jump_000_36a6

    nop
    pop bc
    jr jr_000_36b8

jr_000_36b8:
    jr jr_000_36ba

jr_000_36ba:
    jr jr_000_36bc

jr_000_36bc:
    ret


Call_000_36bd:
jr_000_36bd:
    dec de
    ld a, e
    or d
    ret z

    ld b, $33

Jump_000_36c3:
    jr jr_000_36c5

jr_000_36c5:
    jr jr_000_36c7

jr_000_36c7:
    jr jr_000_36c9

jr_000_36c9:
    jr jr_000_36cb

jr_000_36cb:
    jr jr_000_36cd

jr_000_36cd:
    dec b
    jp nz, Jump_000_36c3

    nop
    jr jr_000_36d4

jr_000_36d4:
    jr jr_000_36d6

jr_000_36d6:
    jr jr_000_36d8

jr_000_36d8:
    jr jr_000_36bd

Call_000_36da:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    call Call_000_36a0
    ret


Jump_000_36e3:
    ld a, d
    or e
    ret z

    ld a, h
    cp $98
    jr c, jr_000_36ee

    sub $10
    ld h, a

jr_000_36ee:
    xor a
    cp e
    jr nz, jr_000_36f3

    dec d

jr_000_36f3:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_36f3

    ld a, [bc]
    ld [hl+], a
    inc bc

jr_000_36fc:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_36fc

    ld a, [bc]
    ld [hl], a
    inc bc
    inc l
    jr nz, jr_000_3710

    inc h
    ld a, h
    cp $98
    jr nz, jr_000_3710

    ld h, $88

jr_000_3710:
    dec e
    jr nz, jr_000_36f3

    dec d
    bit 7, d
    jr z, jr_000_36f3

    ret


Jump_000_3719:
    ld a, d
    or e
    ret z

    ld a, h
    cp $98
    jr c, jr_000_3724

    sub $10
    ld h, a

jr_000_3724:
    push de
    ld a, [bc]
    ld e, a
    inc bc
    push bc
    ld bc, $0000
    ld a, [$d70e]
    bit 0, a
    jr z, jr_000_3735

    ld b, $ff

jr_000_3735:
    bit 1, a
    jr z, jr_000_373b

    ld c, $ff

jr_000_373b:
    ld d, a
    ld a, [$d70d]
    xor d
    ld d, a
    bit 0, d
    jr z, jr_000_3748

    ld a, e
    xor b
    ld b, a

jr_000_3748:
    bit 1, d
    jr z, jr_000_374f

    ld a, e
    xor c
    ld c, a

jr_000_374f:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_374f

    ld [hl], b
    inc hl

jr_000_3757:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_3757

    ld [hl], c
    inc hl
    ld a, h
    cp $98
    jr nz, jr_000_3766

    ld h, $88

jr_000_3766:
    pop bc
    pop de
    dec de
    ld a, d
    or e
    jr nz, jr_000_3724

    ret


Call_000_376e:
    call Call_000_069f
    push hl
    ld hl, $d714
    ld b, $06

jr_000_3777:
    ld a, [hl]
    inc hl
    or [hl]
    cp $00
    jr z, jr_000_3789

    inc hl
    inc hl
    dec b
    jr nz, jr_000_3777

    pop hl
    ld hl, $0000
    jr jr_000_37ad

jr_000_3789:
    pop de
    ld [hl], d
    dec hl
    ld [hl], e
    ld a, [$d712]
    dec hl
    ld [hl], a
    push hl
    call Call_000_37fe
    ld a, [$d6a3]
    and $02
    call nz, Call_000_37b6
    ld hl, $d710
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    inc hl
    ld a, [$d712]
    add [hl]
    ld [$d712], a
    pop hl

jr_000_37ad:
    ldh a, [rLCDC]
    or $81
    and $e7
    ldh [rLCDC], a
    ret


Call_000_37b6:
    ld hl, $d710
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
    jr z, jr_000_37e2

    ld bc, $0000
    cp $02
    jr z, jr_000_37e2

    ld bc, $0100

jr_000_37e2:
    inc hl
    inc hl
    add hl, bc
    ld c, l
    ld b, h
    ld a, [$d70f]
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
    jp z, Jump_000_36e3

    jp Jump_000_3719


Call_000_37fe:
    ld a, [hl+]
    ld [$d70f], a
    ld a, [hl+]
    ld [$d710], a
    ld a, [hl+]
    ld [$d711], a
    ret


Call_000_380b:
    cp $0a
    jr nz, jr_000_381d

    push af
    ld a, [$d6a3]
    and $08
    jr nz, jr_000_381c

    call Call_000_38f7
    pop af
    ret


jr_000_381c:
    pop af

jr_000_381d:
    call Call_000_3834
    call Call_000_390c
    ret


    call Call_000_3834
    call Call_000_390c
    ret


    call Call_000_38e0
    ld a, $00
    call Call_000_3834
    ret


Call_000_3834:
    push af
    ld a, [$d711]
    or a
    jr nz, jr_000_3849

    call Call_000_38a3
    xor a
    ld [$d712], a
    call Call_000_078d
    ld b, h
    dec l
    nop
    nop

jr_000_3849:
    pop af
    push bc
    push de
    push hl
    ld e, a
    ld hl, $d710
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [hl+]
    and $03
    cp $02
    jr z, jr_000_3860

    inc hl
    ld d, $00
    add hl, de
    ld e, [hl]

jr_000_3860:
    ld a, [$d70f]
    add e
    ld e, a
    ld a, [$d726]
    ld l, a
    ld h, $00
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld a, [$d725]
    ld c, a
    ld b, $00
    add hl, bc
    ld bc, $9800
    add hl, bc

jr_000_387b:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_387b

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
    call Call_000_376e
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
    call Call_000_37fe
    pop bc
    ld de, $0000
    ret


Call_000_38a3:
    push bc
    call Call_000_3968
    ld a, $01
    ld [$d712], a
    xor a
    ld hl, $d713
    ld b, $12

jr_000_38b2:
    ld [hl+], a
    dec b
    jr nz, jr_000_38b2

    ld a, $03
    ld [$d70d], a
    ld a, $00
    ld [$d70e], a
    call Call_000_38c5
    pop bc
    ret


Call_000_38c5:
    push de
    push hl
    ld hl, $9800
    ld e, $20

jr_000_38cc:
    ld d, $20

jr_000_38ce:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_38ce

    ld [hl], $00
    inc hl
    dec d
    jr nz, jr_000_38ce

    dec e
    jr nz, jr_000_38cc

    pop hl
    pop de
    ret


Call_000_38e0:
    push hl
    ld hl, $d725
    xor a
    cp [hl]
    jr z, jr_000_38eb

    dec [hl]
    jr jr_000_38f5

jr_000_38eb:
    ld [hl], $13
    ld hl, $d726
    xor a
    cp [hl]
    jr z, jr_000_38f5

    dec [hl]

jr_000_38f5:
    pop hl
    ret


Call_000_38f7:
    push hl
    xor a
    ld [$d725], a
    ld hl, $d726
    ld a, $11
    cp [hl]
    jr z, jr_000_3907

    inc [hl]
    jr jr_000_390a

jr_000_3907:
    call Call_000_393a

jr_000_390a:
    pop hl
    ret


Call_000_390c:
    push hl
    ld hl, $d725
    ld a, $13
    cp [hl]
    jr z, jr_000_3918

    inc [hl]
    jr jr_000_3938

jr_000_3918:
    ld [hl], $00
    ld hl, $d726
    ld a, $11
    cp [hl]
    jr z, jr_000_3925

    inc [hl]
    jr jr_000_3938

jr_000_3925:
    ld a, [$d6a3]
    and $04
    jr z, jr_000_3935

    xor a
    ld [$d726], a
    ld [$d725], a
    jr jr_000_3938

jr_000_3935:
    call Call_000_393a

jr_000_3938:
    pop hl
    ret


Call_000_393a:
    push bc
    push de
    push hl
    ld hl, $9800
    ld bc, $9820
    ld e, $1f

jr_000_3945:
    ld d, $20

jr_000_3947:
    ldh a, [rSTAT]
    and $02
    jr nz, jr_000_3947

    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, jr_000_3947

    dec e
    jr nz, jr_000_3945

    ld d, $20

jr_000_3958:
    ldh a, [rSTAT]
    and $02
    jr nz, jr_000_3958

    ld a, $00
    ld [hl+], a
    dec d
    jr nz, jr_000_3958

    pop hl
    pop de
    pop bc
    ret


Call_000_3968:
Jump_000_3968:
    di
    ldh a, [rLCDC]
    bit 7, a
    jr z, jr_000_3984

    call Call_000_069f
    ld bc, $26a6
    ld hl, $d6ac
    call Call_000_064c
    ld bc, $26b1
    ld hl, $d6bc
    call Call_000_064c

jr_000_3984:
    call Call_000_3991
    ldh a, [rLCDC]
    or $81
    and $e7
    ldh [rLCDC], a
    ei
    ret


Call_000_3991:
    xor a
    ld [$d725], a
    ld [$d726], a
    call Call_000_38c5
    ld a, $02
    ld [$d6a3], a
    ret


Call_000_39a1:
Jump_000_39a1:
jr_000_39a1:
    ldh a, [rSTAT]
    and $02
    jr nz, jr_000_39a1

    ld [hl], b
    inc hl
    dec de
    ld a, d
    or e
    jr nz, jr_000_39a1

    ret


    ldh a, [rLCDC]
    bit 6, a
    jr nz, jr_000_39ba

    ld hl, $9800
    jr jr_000_39cd

jr_000_39ba:
    ld hl, $9c00
    jr jr_000_39cd

    ldh a, [rLCDC]
    bit 3, a
    jr nz, jr_000_39ca

    ld hl, $9800
    jr jr_000_39cd

jr_000_39ca:
    ld hl, $9c00

jr_000_39cd:
    ld de, $0400
    jp Jump_000_39a1


    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
