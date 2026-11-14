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
    ld hl, $c4b6
    jp Jump_000_0067


    rst RST_38

LCDCInterrupt::
    push hl
    ld hl, $c4c6
    jp Jump_000_0067


    rst RST_38

TimerOverflowInterrupt::
    push hl
    ld hl, $c4d6
    jp Jump_000_0067


    rst RST_38

SerialTransferCompleteInterrupt::
    push hl
    ld hl, $c4e6
    jp Jump_000_0067


    rst RST_38

JoypadTransitionInterrupt::
    push hl
    ld hl, $c4f6
    jp Jump_000_0067


Jump_000_0067:
    push af

    push bc
    push de
    ld a, [$c4b3]
    inc a
    ld [$c4b3], a

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
    ld a, [$c4b3]
    dec a
    ld [$c4b3], a
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
    db "BOOTLOADER", $00, $00, $00, $00, $00, $00

HeaderNewLicenseeCode::
    db $00, $00

HeaderSGBFlag::
    db $03

HeaderCartridgeType::
    db $01

HeaderROMSize::
    db $00

HeaderRAMSize::
    db $00

HeaderDestinationCode::
    db $00

HeaderOldLicenseeCode::
    db $33

HeaderMaskROMVersion::
    db $01

HeaderComplementCheck::
    db $c4

HeaderGlobalChecksum::
    db $8e, $e3

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
    ld [$c4ac], a
    ld a, $01
    ld [$c4b2], a
    ld [$2000], a
    xor a
    ld [$c4b3], a
    call Call_000_049f
    xor a
    ldh [rSCY], a
    ldh [rSCX], a
    ldh [rSTAT], a
    ldh [rWY], a
    ld a, $07
    ldh [rWX], a
    ld bc, $ff80
    ld hl, $04b6
    ld b, $0a

jr_000_019e:
    ld a, [hl+]
    ldh [c], a
    inc c
    dec b
    jr nz, jr_000_019e

    ld bc, $0477
    call Call_000_042e
    ld bc, $04c0
    call Call_000_0440
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
    ld [$c4b4], a
    ld [$c4b5], a
    call $4134
    call Call_000_0811

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
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    jp Jump_000_2fdb


    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Call_000_0400:
    ld a, l
    ld [$c4ad], a
    and $03
    ld l, a
    ld bc, $01e2
    sla l
    sla l
    add hl, bc
    jp hl


Call_000_0410:
    ld hl, $c4b6
    jp Jump_000_044c


Call_000_0416:
    ld hl, $c4c6
    jp Jump_000_044c


Call_000_041c:
    ld hl, $c4d6
    jp Jump_000_044c


Call_000_0422:
    ld hl, $c4e6
    jp Jump_000_044c


Call_000_0428:
    ld hl, $c4f6
    jp Jump_000_044c


Call_000_042e:
    ld hl, $c4b6
    jp Jump_000_046c


Call_000_0434:
    ld hl, $c4c6
    jp Jump_000_046c


Call_000_043a:
    ld hl, $c4d6
    jp Jump_000_046c


Call_000_0440:
    ld hl, $c4e6
    jp Jump_000_046c


Call_000_0446:
    ld hl, $c4f6
    jp Jump_000_046c


Call_000_044c:
Jump_000_044c:
jr_000_044c:
    ld a, [hl+]
    ld e, a
    ld d, [hl]
    or d
    ret z

    ld a, e
    cp c
    jr nz, jr_000_044c

    ld a, d
    cp b
    jr nz, jr_000_044c

    xor a
    ld [hl-], a
    ld [hl], a
    inc a
    ld d, h
    ld e, l
    dec de
    inc hl

jr_000_0461:
    ld a, [hl+]
    ld [de], a
    ld b, a
    inc de
    ld a, [hl+]
    ld [de], a
    inc de
    or b
    ret z

    jr jr_000_0461

Jump_000_046c:
jr_000_046c:
    ld a, [hl+]
    or [hl]
    jr z, jr_000_0473

    inc hl
    jr jr_000_046c

jr_000_0473:
    ld [hl], b
    dec hl
    ld [hl], c
    ret


    ld hl, $c4b4
    inc [hl]
    jr nz, jr_000_047f

    inc hl
    inc [hl]

jr_000_047f:
    call $ff80
    ld a, $01
    ld [$c4b1], a
    ret


    ldh a, [rLCDC]
    add a
    ret nc

    xor a
    di
    ld [$c4b1], a
    ei

jr_000_0492:
    halt
    nop
    ld a, [$c4b1]
    or a
    jr z, jr_000_0492

    xor a
    ld [$c4b1], a
    ret


Call_000_049f:
    ldh a, [rLCDC]
    add a
    ret nc

jr_000_04a3:
    ldh a, [rLY]
    cp $92
    jr nc, jr_000_04a3

jr_000_04a9:
    ldh a, [rLY]
    cp $91
    jr c, jr_000_04a9

    ldh a, [rLCDC]
    and $7f
    ldh [rLCDC], a
    ret


    ld a, $c0
    ldh [rDMA], a
    ld a, $28

jr_000_04bc:
    dec a
    jr nz, jr_000_04bc

    ret


    ld a, [$c4b0]
    cp $02
    jr nz, jr_000_04d0

    ldh a, [rSB]
    ld [$c4af], a
    ld a, $00
    jr jr_000_04de

jr_000_04d0:
    cp $01
    jr nz, jr_000_04ea

    ldh a, [rSB]
    cp $55
    jr z, jr_000_04de

    ld a, $04
    jr jr_000_04e0

jr_000_04de:
    ld a, $00

jr_000_04e0:
    ld [$c4b0], a
    xor a
    ldh [rSC], a
    ld a, $66
    ldh [rSB], a

jr_000_04ea:
    ld a, $80
    ldh [rSC], a
    ret


    ld hl, sp+$02
    ld l, [hl]
    ld h, $00
    call Call_000_0400
    ret


    ld hl, $c4ad
    ld e, [hl]
    ret


Call_000_04fd:
    di
    ld a, [$c4b3]
    inc a
    ld [$c4b3], a
    ret


Call_000_0506:
    ld a, [$c4b3]
    dec a
    ld [$c4b3], a
    ret nz

    ei
    ret


    call Call_000_04fd
    ld hl, sp+$02
    xor a
    ldh [rIF], a
    ld a, [hl]
    ldh [rIE], a
    call Call_000_0506
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_0410
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_0416
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_041c
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_0422
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_0428
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_042e
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_0434
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_043a
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_0440
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call Call_000_0446
    pop bc
    ret


Call_000_058d:
    call Call_000_04fd
    pop hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    inc hl
    push hl
    ld b, a
    ld a, [$c4b2]
    push af
    ld a, b
    ld [$c4b2], a
    ld [$2000], a
    call Call_000_0506
    ld hl, $05ae
    push hl
    ld l, e
    ld h, d
    jp hl


    call Call_000_04fd
    pop af
    ld [$2000], a
    ld [$c4b2], a
    call Call_000_0506
    ret


Call_000_05bc:
    push af
    ld hl, sp+$04
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e

Jump_000_05c5:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    or a
    jp z, Jump_000_05e1

    dec hl
    inc [hl]
    jr nz, jr_000_05d6

    inc hl
    inc [hl]

jr_000_05d6:
    ld a, c
    push af
    inc sp
    call Call_000_2923
    add sp, $01
    jp Jump_000_05c5


Jump_000_05e1:
    ld a, $0a
    push af
    inc sp
    call Call_000_2923
    add sp, $01
    add sp, $02
    ret


    add sp, -$13
    ld hl, sp+$15
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0d
    ld [hl+], a
    ld [hl], e
    ld a, [hl]
    bit 7, a
    jp z, Jump_000_060d

    xor a
    dec hl
    ld a, $00
    sbc [hl]
    ld c, a
    inc hl
    ld a, $00
    sbc [hl]
    ld b, a
    ld hl, sp+$15
    ld [hl], c
    inc hl
    ld [hl], b

Jump_000_060d:
    ld hl, sp+$11
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_000_0614:
    ld hl, sp+$11
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_000_061f

    inc hl
    inc [hl]

jr_000_061f:
    ld hl, sp+$11
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$17
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, $000a
    push hl
    ld hl, sp+$17
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_27fa
    add sp, $04
    ld b, d
    ld c, e
    ld a, c
    add $30
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, $000a
    push hl
    ld hl, sp+$17
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_27e6
    add sp, $04
    ld b, d
    ld c, e
    ld hl, sp+$15
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, $00
    sub c
    ld a, $00
    sbc b
    rlca
    jp c, Jump_000_0614

    ld hl, sp+$11
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$0e
    ld a, [hl]
    bit 7, a
    jp z, Jump_000_069c

    ld hl, sp+$11
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0001
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$11
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld a, $2d
    ld [bc], a

Jump_000_069c:
    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld a, $00
    ld [bc], a
    ld hl, sp+$06
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0f
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$08
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d

Jump_000_06bc:
    ld hl, sp+$10
    ld a, [hl]
    bit 7, a
    jp nz, Jump_000_070e

    ld hl, sp+$06
    ld c, [hl]
    ld hl, sp+$0f
    ld b, [hl]
    ld a, c
    sub b
    ld c, a
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld l, c
    ld h, $00
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$0f
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0001
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$01
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$00
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$00
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$0f
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_000_06bc


Jump_000_070e:
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_05bc
    add sp, $02
    add sp, $13
    ret


Jump_000_071c:
    call Call_000_3983
    ld c, e
    ld b, $00
    ld a, c
    sub $20
    jp nz, Jump_000_072e

    or b
    jp nz, Jump_000_072e

    jr jr_000_0731

Jump_000_072e:
    jp Jump_000_071c


jr_000_0731:
    ld hl, $00c8
    push hl
    call Call_000_39cc
    add sp, $02
    ret


Call_000_073b:
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


    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7f31
    ld a, $00
    ld [bc], a
    ld bc, $7f32
    ld a, $80
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    call Boot

Jump_000_0782:
    jp Jump_000_0782


    ret


    ld bc, $2000
    ld a, $01
    ld [bc], a
    ld bc, $3000
    ld a, $00
    ld [bc], a
    ld bc, $075b
    ld hl, $0100
    push hl
    push bc
    ld h, $d0
    push hl
    call Call_000_2bbe
    add sp, $06
    call $d000
    ret


    ld hl, $07ef
    push hl
    call Call_000_2bd7
    add sp, $02
    ld hl, $07ef
    push hl
    call Call_000_2bd7
    add sp, $02
    ld hl, $07ef
    push hl
    call Call_000_2bd7
    add sp, $02
    ld hl, $07ef
    push hl
    call Call_000_2bd7
    add sp, $02
    ld hl, $07ef
    push hl
    call Call_000_2bd7
    add sp, $02
    ld hl, $07ef
    push hl
    call Call_000_2bd7
    add sp, $02
    ld hl, $07ef
    push hl
    call Call_000_2bd7
    add sp, $02
    ld hl, $07ef
    push hl
    call Call_000_2bd7
    add sp, $02
    ret


    jr nz, jr_000_07f1

Call_000_07f1:
jr_000_07f1:
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7fd3
    ld hl, sp+$02
    ld a, [hl]
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ret


Call_000_0811:
    add sp, -$5a
    ld bc, $ff26
    ld a, $00
    ld [bc], a
    ld hl, $0b87
    push hl
    call Call_000_2bd7
    add sp, $02
    ld hl, $0b90
    push hl
    call Call_000_2bd7
    add sp, $02
    ld hl, $02bc
    push hl
    call Call_000_39cc
    add sp, $02
    ld hl, $c4ac
    ld a, [hl]
    push af
    inc sp
    call Call_000_07f1
    add sp, $01
    ld hl, $0b9f
    push hl
    call Call_000_2bd7
    add sp, $02
    ld a, $00
    push af
    inc sp
    call Call_000_073b
    add sp, $01
    ld hl, sp+$30
    ld c, l
    ld b, h
    push bc
    call Call_000_198c
    add sp, $02
    ld c, e
    xor a
    or c
    jp z, Jump_000_0870

    ld hl, $c2a6
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_2bd7
    add sp, $02

Jump_000_086d:
    jp Jump_000_086d


Jump_000_0870:
    ld hl, $0b7e
    push hl
    call Call_000_1f1f
    add sp, $02
    ld b, e
    ld c, b
    xor a
    or c
    jp z, Jump_000_08b6

    ld hl, $c2a0
    ld hl, $c2a0
    ld c, [hl]
    ld hl, $c2a1
    ld b, [hl]
    push bc
    call Call_000_2bd7
    add sp, $02
    ld hl, $c2a2
    ld hl, $c2a2
    ld c, [hl]
    ld hl, $c2a3
    ld b, [hl]
    push bc
    call Call_000_2bd7
    add sp, $02
    ld hl, $c2a4
    ld hl, $c2a4
    ld c, [hl]
    ld hl, $c2a5
    ld b, [hl]
    push bc
    call Call_000_2bd7
    add sp, $02

Jump_000_08b3:
    jp Jump_000_08b3


Jump_000_08b6:
    ld hl, $0bae
    push hl
    call Call_000_2bd7
    add sp, $02
    call Call_000_249c
    ld c, e
    ld a, c
    sub $02
    jp nz, Jump_000_08cb

    jr jr_000_08ce

Jump_000_08cb:
    jp Jump_000_08de


jr_000_08ce:
    ld hl, sp+$0e
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp Jump_000_08eb


Jump_000_08de:
    ld hl, sp+$0e
    ld [hl], $f7
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $0f

Jump_000_08eb:
    call Call_000_24ab
    push hl
    ld hl, sp+$18
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    call Call_000_246e
    push hl
    ld hl, sp+$0c
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$1a
    ld [hl], $a0
    inc hl
    ld [hl], $c0
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$1a
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$18
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$18
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_1077
    add sp, $04
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
    ld hl, sp+$1a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld hl, sp+$1a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$1a
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$16
    ld d, h
    ld e, l
    ld hl, sp+$12
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
    ld hl, sp+$08
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_000_0987:
    ld hl, sp+$18
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$18
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_24d9
    add sp, $04
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
    ld hl, sp+$04
    ld d, h
    ld e, l
    ld hl, sp+$16
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
    ld hl, sp+$08
    inc [hl]
    jr nz, jr_000_09bb

    inc hl
    inc [hl]

jr_000_09bb:
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    add $01
    ld e, a
    ld a, d
    adc $00
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
    adc $00
    ld e, a
    ld a, d
    adc $00
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$16
    ld a, [hl]
    ld hl, sp+$04
    sub [hl]
    jp nz, Jump_000_0a01

    ld hl, sp+$17
    ld a, [hl]
    ld hl, sp+$05
    sub [hl]
    jp nz, Jump_000_0a01

    ld hl, sp+$18
    ld a, [hl]
    ld hl, sp+$06
    sub [hl]
    jp nz, Jump_000_0a01

    ld hl, sp+$19
    ld a, [hl]
    ld hl, sp+$07
    sub [hl]
    jp z, Jump_000_0a84

Jump_000_0a01:
    call Call_000_2503
    ld c, e
    ld b, $00
    push bc
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_2b4b
    add sp, $04
    ld b, d
    ld c, e
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$1a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld hl, sp+$1a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$1a
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$18
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$18
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_1077
    add sp, $04
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
    ld hl, sp+$1a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld hl, sp+$1a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$1a
    ld [hl+], a
    ld [hl], d

Jump_000_0a84:
    ld hl, sp+$16
    ld d, h
    ld e, l
    ld hl, sp+$12
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
    ld hl, sp+$16
    ld d, h
    ld e, l
    ld hl, sp+$0e
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp c, Jump_000_0987

    ld hl, sp+$1a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$1b
    ld [hl-], a
    ld [hl], e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$1b
    ld [hl-], a
    ld [hl], e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $ff
    ld [de], a
    inc de
    ld a, $ff
    ld [de], a
    inc de
    ld a, $ff
    ld [de], a
    inc de
    ld a, $ff
    ld [de], a
    dec hl
    ld [hl], $a0
    inc hl
    ld [hl], $c0
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $01f0
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld hl, sp+$0a
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld hl, sp+$1a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $01f4
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, $01
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    ld hl, sp+$1a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $01f8
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    call Call_000_2503
    ld c, e
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$00
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld a, $02
    push af
    inc sp
    call Call_000_073b
    add sp, $01
    call Call_000_04fd
    ld hl, $c0a0
    push hl
    call Call_000_058d
    rst RST_38
    ld b, b
    ld bc, $e800
    ld [bc], a
    add sp, $5a
    ret


    ld b, l
    ld e, d
    ld b, a
    ld b, d
    ld l, $44
    ld b, c
    ld d, h
    nop
    jr nz, @+$0c

    ld a, [bc]
    ld a, [bc]
    ld a, [bc]
    ld a, [bc]
    ld a, [bc]
    ld a, [bc]
    nop
    jr nz, jr_000_0bb2

    jr nz, jr_000_0bb4

    jr nz, jr_000_0bb6

    ld b, l
    ld e, d
    dec l
    ld b, [hl]
    ld c, h
    ld b, c
    ld d, e
    ld c, b
    nop
    ld a, [bc]
    ld a, [bc]
    ld a, [bc]
    ld a, [bc]
    ld c, h
    ld c, a
    ld b, c
    ld b, h
    ld c, c
    ld c, [hl]
    ld b, a
    ld l, $2e
    ld l, $00
    ld c, a
    ld d, e
    ld c, c
    ld c, [hl]

jr_000_0bb2:
    ld c, c
    ld d, h

jr_000_0bb4:
    ld l, $2e

jr_000_0bb6:
    ld l, $00
    ld h, l
    ld a, d
    ld h, a
    ld h, d
    ld l, $64
    ld h, c
    ld [hl], h
    jr nz, jr_000_0c30

    ld l, a
    ld [hl], h
    jr nz, jr_000_0c2c

    ld l, a
    ld [hl], l
    ld l, [hl]
    ld h, h
    jr nz, jr_000_0bec

    ld l, a
    ld l, [hl]
    jr nz, jr_000_0c23

    ld b, h
    jr nz, jr_000_0c36

    ld h, c
    ld [hl], d
    ld h, h
    nop
    ld d, b
    ld l, h
    ld h, l
    ld h, c
    ld [hl], e
    ld h, l
    jr nz, jr_000_0c43

    ld l, a
    ld [hl], a
    ld l, [hl]
    ld l, h
    ld l, a
    ld h, c
    ld h, h
    jr nz, jr_000_0c51

    ld [hl], h
    jr nz, jr_000_0beb

jr_000_0beb:
    ld h, [hl]

jr_000_0bec:
    ld [hl], d
    ld l, a
    ld l, l
    jr nz, @+$79

    ld [hl], a
    ld [hl], a
    ld l, $65
    ld a, d
    ld h, [hl]
    ld l, h
    ld h, c
    ld [hl], e
    ld l, b
    ld l, $63
    ld l, [hl]
    nop
    ld c, l
    ld l, c
    ld h, e
    ld [hl], d
    ld l, a
    jr nz, jr_000_0c59

    ld b, h
    jr nz, jr_000_0c72

    ld l, [hl]
    ld l, c
    ld [hl], h
    ld l, c
    ld h, c
    ld l, h
    jr nz, jr_000_0c76

    ld [hl], d
    ld [hl], d
    ld l, a
    ld [hl], d
    ld hl, $1e00
    nop
    ret


Call_000_0c1a:
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0c
    ld a, [hl+]

jr_000_0c23:
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl

jr_000_0c2c:
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]

jr_000_0c30:
    ld l, a
    push hl
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]

jr_000_0c36:
    ld l, a
    push hl
    call Call_000_058d
    dec sp
    dec h
    rst RST_38
    rst RST_38
    add sp, $0a
    ld e, $00

jr_000_0c43:
    ret


    ld e, $00
    ret


Call_000_0c47:
    push af
    push af
    ld hl, sp+$06
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, [bc]
    ld c, a

jr_000_0c51:
    ld hl, sp+$02
    ld [hl], c
    inc hl
    ld [hl], $00
    dec hl
    ld a, [hl]

jr_000_0c59:
    dec hl
    ld [hl-], a
    ld [hl], $00
    ld hl, sp+$06
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, [bc]
    ld c, a
    ld b, $00
    ld a, c
    ld hl, sp+$00
    or [hl]
    ld c, a
    ld a, b
    inc hl
    or [hl]
    ld b, a
    inc hl
    ld [hl], c
    inc hl

jr_000_0c72:
    ld [hl], b
    dec hl
    ld e, [hl]
    inc hl

jr_000_0c76:
    ld d, [hl]
    add sp, $04
    ret


Call_000_0c7a:
    add sp, -$0c
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0003
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld a, $08
    push af
    inc sp
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0b
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_2906
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
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    inc bc
    ld a, [bc]
    ld c, a
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
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
    ld d, h
    ld e, l
    ld hl, sp+$08
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
    ld a, $08
    push af
    inc sp
    ld hl, sp+$0b
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0b
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_2906
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
    ld hl, sp+$0e
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, [bc]
    ld c, a
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
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
    ld d, h
    ld e, l
    ld hl, sp+$08
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
    ld a, $08
    push af
    inc sp
    ld hl, sp+$0b
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0b
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_2906
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
    ld hl, sp+$0e
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, [bc]
    ld c, a
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
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
    ld d, h
    ld e, l
    ld hl, sp+$08
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
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add sp, $0c
    ret


Call_000_0dc9:
    push af
    push af
    ld hl, sp+$06
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$02
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$0a
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e

Jump_000_0ddd:
    ld hl, sp+$00
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
    jp z, Jump_000_0e02

    ld hl, sp+$08
    ld a, [hl]
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_000_0dff

    inc hl
    inc [hl]

jr_000_0dff:
    jp Jump_000_0ddd


Jump_000_0e02:
    add sp, $04
    ret


Call_000_0e05:
    add sp, -$0a
    ld hl, sp+$0c
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$04
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$0e
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$10
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], e

Jump_000_0e28:
    ld hl, sp+$02
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
    jp z, Jump_000_0e77

    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    dec hl
    inc [hl]
    jr nz, jr_000_0e48

    inc hl
    inc [hl]

jr_000_0e48:
    ld hl, sp+$00
    ld [hl], c
    ld a, c
    rla
    sbc a
    inc hl
    ld [hl], a
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    dec hl
    inc [hl]
    jr nz, jr_000_0e5d

    inc hl
    inc [hl]

jr_000_0e5d:
    ld a, c
    rla
    sbc a
    ld b, a
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
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, c
    or b
    jp z, Jump_000_0e28

Jump_000_0e77:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $0a
    ret


Call_000_0e7f:
    add sp, -$12
    ld hl, $c2a8
    ld a, [hl]
    ld hl, $c2a9
    ld e, [hl]
    ld hl, sp+$0c
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$14
    ld a, [hl]
    sub $02
    inc hl
    ld a, [hl]
    sbc $00
    inc hl
    ld a, [hl]
    sbc $00
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_000_0ed2

    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$08
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
    ld hl, sp+$14
    ld d, h
    ld e, l
    ld hl, sp+$08
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp c, Jump_000_0edb

Jump_000_0ed2:
    ld de, $0001
    ld hl, $0000
    jp Jump_000_1074


Jump_000_0edb:
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $02
    jp z, Jump_000_0ef0

    ld a, c
    sub $03
    jp z, Jump_000_0fa5

    jp Jump_000_106e


Jump_000_0ef0:
    ld hl, sp+$14
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld b, $00
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], b
    dec hl
    sla [hl]
    inc hl
    rl [hl]
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000a
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$04
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
    ld a, $08
    push af
    inc sp
    ld hl, sp+$17
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$17
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_28cc
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
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$00
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$0e
    ld c, l
    ld b, h
    ld hl, $0002
    push hl
    ld hl, sp+$0a
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
    push bc
    call Call_000_0c1a
    add sp, $0a
    ld c, e
    xor a
    or c
    jp nz, Jump_000_106e

    ld hl, sp+$0e
    ld c, l
    ld b, h
    push bc
    call Call_000_0c47
    add sp, $02
    ld b, d
    ld c, e
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp Jump_000_1074


Jump_000_0fa5:
    ld hl, sp+$14
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, c
    and $7f
    ld c, a
    ld b, $00
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, $03
    jr jr_000_0fc0

jr_000_0fb9:
    ld hl, sp+$00
    sla [hl]
    inc hl
    rl [hl]

jr_000_0fc0:
    dec a
    jr nz, jr_000_0fb9

    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000a
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$04
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
    ld a, $07
    push af
    inc sp
    ld hl, sp+$17
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$17
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_28cc
    add sp, $05
    push hl
    ld hl, sp+$0a
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$08
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$0c
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$0e
    ld c, l
    ld b, h
    ld hl, $0004
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
    push bc
    call Call_000_0c1a
    add sp, $0a
    ld c, e
    xor a
    or c
    jp nz, Jump_000_106e

    ld hl, sp+$0e
    ld c, l
    ld b, h
    push bc
    call Call_000_0c7a
    add sp, $02
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
    ld hl, sp+$03
    ld a, [hl]
    and $0f
    ld [hl], a
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp Jump_000_1074


Jump_000_106e:
    ld de, $0001
    ld hl, $0000

Jump_000_1074:
    add sp, $12
    ret


Call_000_1077:
    add sp, -$0a
    ld hl, $c2a8
    ld a, [hl]
    ld hl, $c2a9
    ld e, [hl]
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    sub $02
    ld e, a
    ld a, d
    sbc $00
    push af
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    sbc $00
    ld e, a
    ld a, d
    sbc $00
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$04
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
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    sub $02
    ld e, a
    ld a, d
    sbc $00
    push af
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    sbc $00
    ld e, a
    ld a, d
    sbc $00
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$0c
    ld d, h
    ld e, l
    ld hl, sp+$04
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp c, Jump_000_10fb

    ld de, $0000
    ld hl, $0000
    jp Jump_000_1178


Jump_000_10fb:
    ld hl, sp+$08
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    inc bc
    ld a, [bc]
    ld c, a
    ld hl, sp+$04
    ld [hl], c
    inc hl
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
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$12
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$12
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_2763
    add sp, $08
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
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0012
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$00
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$00
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld [hl-], a
    ld [hl], e
    dec hl
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_1178:
    add sp, $0a
    ret


Call_000_117b:
    add sp, -$08
    ld hl, $c2a8
    ld hl, $c2a8
    ld c, [hl]
    ld hl, $c2a9
    ld b, [hl]
    xor a
    ld hl, sp+$04
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld a, [bc]
    ld c, a
    sub $03
    jp nz, Jump_000_1198

    jr jr_000_119b

Jump_000_1198:
    jp Jump_000_11e9


jr_000_119b:
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0014
    add hl, de
    ld c, l
    ld b, h
    push bc
    call Call_000_0c47
    add sp, $02
    ld b, d
    ld c, e
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
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
    call Call_000_2906
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
    ld d, h
    ld e, l
    ld hl, sp+$04
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

Jump_000_11e9:
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $001a
    add hl, de
    ld c, l
    ld b, h
    push bc
    call Call_000_0c47
    add sp, $02
    ld b, d
    ld c, e
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld a, [hl]
    ld hl, sp+$00
    or [hl]
    ld hl, sp+$04
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$01
    or [hl]
    ld hl, sp+$05
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$02
    or [hl]
    ld hl, sp+$06
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$03
    or [hl]
    ld hl, sp+$07
    ld [hl], a
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add sp, $08
    ret


Call_000_1230:
    add sp, -$0c
    ld hl, $c2a8
    ld a, [hl]
    ld hl, $c2a9
    ld e, [hl]
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$0e
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$08
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
    ld hl, sp+$08
    ld a, [hl]
    sub $01
    jp nz, Jump_000_1284

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_000_1284

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_000_1284

    inc hl
    ld a, [hl]
    or a
    jp z, Jump_000_12b5

Jump_000_1284:
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$00
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
    ld hl, sp+$08
    ld d, h
    ld e, l
    ld hl, sp+$00
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp c, Jump_000_12ba

Jump_000_12b5:
    ld e, $01
    jp Jump_000_1393


Jump_000_12ba:
    ld hl, sp+$08
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_000_1301

    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $03
    jp nz, Jump_000_12d3

    jr jr_000_12d6

Jump_000_12d3:
    jp Jump_000_1301


jr_000_12d6:
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000e
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$00
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
    ld hl, sp+$00
    ld d, h
    ld e, l
    ld hl, sp+$08
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

Jump_000_1301:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0008
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld hl, sp+$08
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000c
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$08
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_000_133c

    ld c, a
    jp Jump_000_133e


Jump_000_133c:
    ld c, $01

Jump_000_133e:
    xor a
    or c
    jp z, Jump_000_1362

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
    call Call_000_1077
    add sp, $04
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
    jp Jump_000_137c


Jump_000_1362:
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000e
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$00
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

Jump_000_137c:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$00
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld e, $00

Jump_000_1393:
    add sp, $0c
    ret


Call_000_1396:
    add sp, -$14
    ld hl, $c2a8
    ld a, [hl]
    ld hl, $c2a9
    ld e, [hl]
    ld hl, sp+$0c
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$16
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, $0001
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$0e
    ld [hl+], a
    ld [hl], d
    dec hl
    ld a, [hl+]
    or [hl]
    jp z, Jump_000_13ec

    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000c
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    inc hl
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
    ld hl, sp+$06
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_000_13f1

Jump_000_13ec:
    ld e, $03
    jp Jump_000_1563


Jump_000_13f1:
    ld hl, sp+$0e
    ld a, [hl]
    and $0f
    jr nz, jr_000_13fb

    jp Jump_000_13fe


jr_000_13fb:
    jp Jump_000_1554


Jump_000_13fe:
    ld hl, sp+$06
    inc [hl]
    jr nz, jr_000_140d

    inc hl
    inc [hl]
    jr nz, jr_000_140d

    inc hl
    inc [hl]
    jr nz, jr_000_140d

    inc hl
    inc [hl]

jr_000_140d:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0008
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld hl, sp+$06
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
    ld hl, sp+$06
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_000_1469

    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$0e
    ld a, [hl]
    sub c
    inc hl
    ld a, [hl]
    sbc b
    jp c, Jump_000_1554

    ld e, $03
    jp Jump_000_1563


Jump_000_1469:
    ld hl, sp+$0e
    ld a, [hl]
    ld hl, sp+$00
    ld [hl], a
    ld hl, sp+$0f
    ld a, [hl]
    ld hl, sp+$01
    ld [hl], a
    srl [hl]
    dec hl
    rr [hl]
    inc hl
    srl [hl]
    dec hl
    rr [hl]
    inc hl
    srl [hl]
    dec hl
    rr [hl]
    inc hl
    srl [hl]
    dec hl
    rr [hl]
    ld hl, sp+$0c
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    inc bc
    ld a, [bc]
    ld c, a
    ld b, $00
    dec bc
    ld a, c
    ld hl, sp+$00
    and [hl]
    ld c, a
    ld a, b
    inc hl
    and [hl]
    ld b, a
    or c
    jp nz, Jump_000_1554

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
    call Call_000_0e7f
    add sp, $04
    push hl
    ld hl, sp+$12
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld a, $01
    ld hl, sp+$10
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
    jp c, Jump_000_14da

    ld e, $01
    jp Jump_000_1563


Jump_000_14da:
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$06
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
    ld hl, sp+$10
    ld d, h
    ld e, l
    ld hl, sp+$06
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp c, Jump_000_1510

    ld e, $03
    jp Jump_000_1563


Jump_000_1510:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$10
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$12
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_1077
    add sp, $04
    push hl
    ld hl, sp+$08
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a

Jump_000_1554:
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$0e
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld e, $00

Jump_000_1563:
    add sp, $14
    ret


Call_000_1566:
    add sp, -$0b
    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_1230
    add sp, $02
    ld c, e
    ld hl, sp+$0a
    ld [hl], c
    xor a
    or [hl]
    jp z, Jump_000_1580

    ld e, [hl]
    jp Jump_000_1670


Jump_000_1580:
    ld hl, sp+$0d
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000c
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], d

Jump_000_1596:
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld a, c
    and $0f
    ld c, a
    ld b, $00
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$00
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
    ld hl, $0020
    push hl
    push bc
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
    ld hl, sp+$17
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_0c1a
    add sp, $0a
    ld b, e
    xor a
    or b
    jp z, Jump_000_15f3

    ld b, $01
    jp Jump_000_15f5


Jump_000_15f3:
    ld b, $00

Jump_000_15f5:
    ld hl, sp+$0a
    ld [hl], b
    xor a
    or [hl]
    jp nz, Jump_000_166d

    ld hl, sp+$0f
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    or a
    jp nz, Jump_000_1616

    ld hl, sp+$0a
    ld [hl], $03
    jp Jump_000_166d


Jump_000_1616:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000b
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    and $08
    jr nz, jr_000_162a

    jp Jump_000_162d


jr_000_162a:
    jp Jump_000_1659


Jump_000_162d:
    ld hl, sp+$08
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    inc bc
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$04
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld hl, sp+$00
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, $000b
    push hl
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call Call_000_0e05
    add sp, $06
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, Jump_000_166d

Jump_000_1659:
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_1396
    add sp, $02
    ld c, e
    ld hl, sp+$0a
    ld [hl], c
    xor a
    or [hl]
    jp z, Jump_000_1596

Jump_000_166d:
    ld hl, sp+$0a
    ld e, [hl]

Jump_000_1670:
    add sp, $0b
    ret


Call_000_1673:
    add sp, -$0b
    ld hl, sp+$0d
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    inc bc
    ld e, c
    ld d, b
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$06
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, $000b
    push hl
    ld l, $20
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_0dc9
    add sp, $06
    ld hl, sp+$08
    ld [hl], $00
    inc hl
    inc hl
    ld [hl], $08
    ld hl, sp+$0f
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    inc hl
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$09
    ld [hl], $00

Jump_000_16bb:
    ld hl, sp+$09
    ld b, [hl]
    inc [hl]
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld l, b
    ld h, $00
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld b, c
    ld a, $20
    sub b
    ld a, $00
    rla
    ld hl, sp+$00
    ld [hl], a
    or a
    jp z, Jump_000_1731

    ld a, b
    sub $2f
    jp z, Jump_000_1731

    ld a, b
    sub $2e
    jp nz, Jump_000_16ea

    ld a, $01
    jr jr_000_16eb

Jump_000_16ea:
    xor a

jr_000_16eb:
    ld c, a
    or a
    jp nz, Jump_000_16f8

    ld hl, sp+$08
    ld a, [hl+]
    inc hl
    sub [hl]
    jp c, Jump_000_1715

Jump_000_16f8:
    ld hl, sp+$0a
    ld a, [hl]
    sub $08
    jp nz, Jump_000_1702

    jr jr_000_1705

Jump_000_1702:
    jp Jump_000_1731


jr_000_1705:
    xor a
    or c
    jp z, Jump_000_1731

    ld hl, sp+$08
    ld [hl], $08
    inc hl
    inc hl
    ld [hl], $0b
    jp Jump_000_16bb


Jump_000_1715:
    ld hl, sp+$08
    ld c, [hl]
    inc [hl]
    dec hl
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld l, c
    ld h, $00
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, b
    ld [de], a
    jp Jump_000_16bb


Jump_000_1731:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$09
    ld l, [hl]
    ld h, $00
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000b
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], d
    xor a
    ld hl, sp+$00
    or [hl]
    sub $01
    ld a, $00
    rla
    ld c, a
    or a
    jp z, Jump_000_176a

    ld c, $01
    jp Jump_000_176c


Jump_000_176a:
    ld c, $00

Jump_000_176c:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    ld e, $00
    add sp, $0b
    ret


Call_000_1778:
    add sp, -$0e
    ld hl, sp+$14
    ld c, [hl]
    inc hl
    ld b, [hl]

Jump_000_177f:
    ld a, [bc]
    ld hl, sp+$0c
    ld [hl], a
    sub $20
    jp nz, Jump_000_178a

    jr jr_000_178d

Jump_000_178a:
    jp Jump_000_1796


jr_000_178d:
    inc bc
    ld hl, sp+$14
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_000_177f


Jump_000_1796:
    ld hl, sp+$14
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$0c
    ld a, [hl]
    sub $2f
    jp nz, Jump_000_17a5

    jr jr_000_17a8

Jump_000_17a5:
    jp Jump_000_17b2


jr_000_17a8:
    ld hl, $0001
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$14
    ld [hl+], a
    ld [hl], d

Jump_000_17b2:
    ld hl, sp+$10
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    ld hl, sp+$14
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, [bc]
    ld c, a
    sub $20
    jp nc, Jump_000_1801

    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_1230
    add sp, $02
    ld c, e
    ld hl, sp+$0d
    ld [hl], c
    ld hl, sp+$12
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, $00
    ld [bc], a
    jp Jump_000_18ad


Jump_000_1801:
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000b
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], d

Jump_000_181f:
    ld hl, sp+$14
    ld c, l
    ld b, h
    push bc
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_1673
    add sp, $04
    ld c, e
    ld hl, sp+$0d
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_000_18ad

    ld hl, sp+$12
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_1566
    add sp, $04
    ld c, e
    ld hl, sp+$0d
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_000_18ad

    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, $000b
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    or a
    jp nz, Jump_000_18ad

    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $10
    jr nz, jr_000_1875

    jp Jump_000_1878


jr_000_1875:
    jp Jump_000_187f


Jump_000_1878:
    ld hl, sp+$0d
    ld [hl], $03
    jp Jump_000_18ad


Jump_000_187f:
    ld hl, sp+$12
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_117b
    add sp, $02
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
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$00
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    jp Jump_000_181f


Jump_000_18ad:
    ld hl, sp+$0d
    ld e, [hl]
    add sp, $0e
    ret


Call_000_18b3:
    ld hl, $0002
    push hl
    ld hl, $01fe
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
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_0c1a
    add sp, $0a
    ld c, e
    xor a
    or c
    jp z, Jump_000_18dd

    ld e, $03
    jp Jump_000_198b


Jump_000_18dd:
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_0c47
    add sp, $02
    ld b, d
    ld c, e
    ld a, c
    sub $55
    jp nz, Jump_000_18f6

    ld a, b
    sub $aa
    jp z, Jump_000_18fb

Jump_000_18f6:
    ld e, $02
    jp Jump_000_198b


Jump_000_18fb:
    ld hl, $0002
    push hl
    ld l, $36
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
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_0c1a
    add sp, $0a
    ld c, e
    xor a
    or c
    jp nz, Jump_000_1942

    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_0c47
    add sp, $02
    ld b, d
    ld c, e
    ld a, c
    sub $46
    jp nz, Jump_000_193a

    ld a, b
    sub $41
    jp nz, Jump_000_193a

    jr jr_000_193d

Jump_000_193a:
    jp Jump_000_1942


jr_000_193d:
    ld e, $00
    jp Jump_000_198b


Jump_000_1942:
    ld hl, $0002
    push hl
    ld l, $52
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
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_0c1a
    add sp, $0a
    ld c, e
    xor a
    or c
    jp nz, Jump_000_1989

    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_0c47
    add sp, $02
    ld b, d
    ld c, e
    ld a, c
    sub $46
    jp nz, Jump_000_1981

    ld a, b
    sub $41
    jp nz, Jump_000_1981

    jr jr_000_1984

Jump_000_1981:
    jp Jump_000_1989


jr_000_1984:
    ld e, $00
    jp Jump_000_198b


Jump_000_1989:
    ld e, $01

Jump_000_198b:
    ret


Call_000_198c:
    add sp, -$4d
    ld hl, $c2a8
    ld [hl], $00
    ld hl, $c2a9
    ld [hl], $00
    call $0c17
    ld c, e
    ld a, c
    and $01
    jr nz, jr_000_19a4

    jp Jump_000_19a9


jr_000_19a4:
    ld e, $02
    jp Jump_000_1f1c


Jump_000_19a9:
    xor a
    ld hl, sp+$24
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld hl, sp+$28
    ld c, l
    ld b, h
    ld hl, $0000
    push hl
    ld hl, $0000
    push hl
    push bc
    call Call_000_18b3
    add sp, $06
    ld c, e
    ld hl, sp+$4c
    ld [hl], c
    ld a, [hl]
    sub $01
    jp nz, Jump_000_19ce

    jr jr_000_19d1

Jump_000_19ce:
    jp Jump_000_1a57


jr_000_19d1:
    ld hl, sp+$28
    ld c, l
    ld b, h
    ld hl, $0010
    push hl
    ld hl, $01be
    push hl
    ld hl, $0000
    push hl
    ld hl, $0000
    push hl
    push bc
    call Call_000_0c1a
    add sp, $0a
    ld c, e
    xor a
    or c
    jp z, Jump_000_19f8

    ld hl, sp+$4c
    ld [hl], $03
    jp Jump_000_1a57


Jump_000_19f8:
    ld hl, sp+$28
    ld a, l
    ld d, h
    ld hl, sp+$16
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    or a
    jp z, Jump_000_1a57

    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0008
    add hl, de
    ld c, l
    ld b, h
    push bc
    call Call_000_0c7a
    add sp, $02
    push hl
    ld hl, sp+$14
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$12
    ld d, h
    ld e, l
    ld hl, sp+$24
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
    ld hl, sp+$26
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$26
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$1a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_18b3
    add sp, $06
    ld c, e
    ld hl, sp+$4c
    ld [hl], c

Jump_000_1a57:
    ld hl, sp+$4c
    ld a, [hl]
    sub $03
    jp nz, Jump_000_1a61

    jr jr_000_1a64

Jump_000_1a61:
    jp Jump_000_1a69


jr_000_1a64:
    ld e, $01
    jp Jump_000_1f1c


Jump_000_1a69:
    xor a
    ld hl, sp+$4c
    or [hl]
    jp z, Jump_000_1a75

    ld e, $06
    jp Jump_000_1f1c


Jump_000_1a75:
    ld hl, sp+$28
    ld c, l
    ld b, h
    ld hl, $0024
    push hl
    ld l, $0d
    push hl
    ld hl, sp+$2a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$2a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call Call_000_0c1a
    add sp, $0a
    ld c, e
    xor a
    or c
    jp z, Jump_000_1a9d

    ld e, $01
    jp Jump_000_1f1c


Jump_000_1a9d:
    ld hl, sp+$28
    ld a, l
    ld d, h
    ld hl, sp+$12
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0009
    add hl, de
    ld c, l
    ld b, h
    push bc
    call Call_000_0c47
    add sp, $02
    ld b, d
    ld c, e
    ld hl, sp+$20
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$20
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_000_1afa

    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0017
    add hl, de
    ld c, l
    ld b, h
    push bc
    call Call_000_0c7a
    add sp, $02
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
    ld hl, sp+$0e
    ld d, h
    ld e, l
    ld hl, sp+$20
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

Jump_000_1afa:
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0003
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, sp+$0e
    ld [hl], c
    inc hl
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
    ld hl, sp+$10
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$26
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$26
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_2763
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
    ld hl, sp+$0e
    ld d, h
    ld e, l
    ld hl, sp+$20
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
    ld hl, sp+$4f
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$16
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000a
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0e
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$12
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    push bc
    call Call_000_0c47
    add sp, $02
    ld b, d
    ld c, e
    ld hl, sp+$0a
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$0a
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$28
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$0e
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$0a
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld c, l
    ld b, h
    push bc
    call Call_000_0c47
    add sp, $02
    ld b, d
    ld c, e
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld c, l
    ld b, h
    push bc
    call Call_000_0c47
    add sp, $02
    ld b, d
    ld c, e
    ld hl, sp+$1c
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$1c
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_000_1c4c

    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0013
    add hl, de
    ld c, l
    ld b, h
    push bc
    call Call_000_0c7a
    add sp, $02
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
    ld hl, sp+$04
    ld d, h
    ld e, l
    ld hl, sp+$1c
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

Jump_000_1c4c:
    ld hl, sp+$12
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    push bc
    call Call_000_0c47
    add sp, $02
    ld b, d
    ld c, e
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$1c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$04
    sub [hl]
    ld e, a
    ld a, d
    inc hl
    sbc [hl]
    push af
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$20
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$08
    pop af
    ld a, e
    sbc [hl]
    ld e, a
    ld a, d
    inc hl
    sbc [hl]
    ld [hl-], a
    ld [hl], e
    dec hl
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$20
    sub [hl]
    ld e, a
    ld a, d
    inc hl
    sbc [hl]
    push af
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$24
    pop af
    ld a, e
    sbc [hl]
    ld e, a
    ld a, d
    inc hl
    sbc [hl]
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    srl b
    rr c
    srl b
    rr c
    srl b
    rr c
    srl b
    rr c
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$00
    sub [hl]
    ld e, a
    ld a, d
    inc hl
    sbc [hl]
    push af
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    pop af
    ld a, e
    sbc [hl]
    ld e, a
    ld a, d
    inc hl
    sbc [hl]
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld hl, sp+$04
    ld [hl], c
    inc hl
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
    call Call_000_276f
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
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    add $02
    ld e, a
    ld a, d
    adc $00
    push af
    ld hl, sp+$1b
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    adc $00
    ld e, a
    ld a, d
    adc $00
    ld hl, sp+$1b
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld hl, sp+$18
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld hl, sp+$4c
    ld [hl], $00
    ld hl, sp+$18
    ld a, [hl]
    sub $f8
    inc hl
    ld a, [hl]
    sbc $0f
    inc hl
    ld a, [hl]
    sbc $00
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_000_1d96

    ld hl, sp+$18
    ld a, [hl]
    sub $f7
    inc hl
    ld a, [hl]
    sbc $ff
    inc hl
    ld a, [hl]
    sbc $00
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_000_1d96

    ld hl, sp+$4c
    ld [hl], $02

Jump_000_1d96:
    ld hl, sp+$18
    ld a, [hl]
    sub $f7
    inc hl
    ld a, [hl]
    sbc $ff
    inc hl
    ld a, [hl]
    sbc $00
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_000_1dae

    ld hl, sp+$4c
    ld [hl], $03

Jump_000_1dae:
    xor a
    ld hl, sp+$4c
    or [hl]
    jp nz, Jump_000_1dba

    ld e, $06
    jp Jump_000_1f1c


Jump_000_1dba:
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$4c
    ld a, [hl]
    ld [de], a
    ld a, [hl]
    sub $03
    jp nz, Jump_000_1dcb

    jr jr_000_1dce

Jump_000_1dcb:
    jp Jump_000_1e11


jr_000_1dce:
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000e
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $001f
    add hl, de
    ld c, l
    ld b, h
    push bc
    call Call_000_0c7a
    add sp, $02
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
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    jp Jump_000_1e64


Jump_000_1e11:
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000e
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$04
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
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$20
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$24
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    ld e, c
    ld d, b
    dec hl
    dec hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a

Jump_000_1e64:
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0012
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$04
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
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$20
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$24
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    srl b
    rr c
    srl b
    rr c
    srl b
    rr c
    srl b
    rr c
    dec hl
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$0a
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$0e
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld hl, sp+$16
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, $00
    ld [bc], a
    dec hl
    ld a, [hl+]
    ld e, [hl]
    ld hl, $c2a8
    ld [hl], a
    ld hl, $c2a9
    ld [hl], e
    ld e, $00

Jump_000_1f1c:
    add sp, $4d
    ret


Call_000_1f1f:
    add sp, -$4a
    ld hl, $c2a8
    ld a, [hl]
    ld hl, $c2a9
    ld e, [hl]
    ld hl, sp+$0c
    ld [hl+], a
    ld [hl], e
    dec hl
    ld a, [hl+]
    or [hl]
    jp nz, Jump_000_1f38

    ld e, $05
    jp Jump_000_2046


Jump_000_1f38:
    ld hl, sp+$0c
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, $00
    ld [bc], a
    ld hl, sp+$3a
    ld a, l
    ld d, h
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$2e
    ld c, l
    ld b, h
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a
    ld hl, sp+$0e
    ld c, l
    ld b, h
    ld hl, sp+$4c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    ld hl, sp+$0e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_1778
    add sp, $06
    ld c, e
    xor a
    or c
    jp z, Jump_000_1f85

    ld e, c
    jp Jump_000_2046


Jump_000_1f85:
    ld hl, sp+$0e
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    or a
    jp z, Jump_000_1fa6

    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000b
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    and $10
    jr nz, jr_000_1fa6

    jp Jump_000_1fab


Jump_000_1fa6:
jr_000_1fa6:
    ld e, $03
    jp Jump_000_2046


Jump_000_1fab:
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $001e
    add hl, de
    ld c, l
    ld b, h
    push bc
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_117b
    add sp, $02
    push hl
    ld hl, sp+$08
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    pop bc
    ld e, c
    ld d, b
    ld hl, sp+$04
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $001a
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$0e
    ld c, l
    ld b, h
    ld hl, $001c
    add hl, bc
    ld c, l
    ld b, h
    push bc
    call Call_000_0c7a
    add sp, $02
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
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$00
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0016
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    ld hl, sp+$0c
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, $01
    ld [bc], a
    ld e, $00

Jump_000_2046:
    add sp, $4a
    ret


    add sp, -$31
    ld hl, sp+$33
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$20
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, $c2a8
    ld a, [hl]
    ld hl, $c2a9
    ld e, [hl]
    ld hl, sp+$1e
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$37
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$1c
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    inc hl
    ld a, [hl+]
    or [hl]
    jp nz, Jump_000_207f

    ld e, $05
    jp Jump_000_246b


Jump_000_207f:
    ld hl, sp+$1e
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, [bc]
    ld c, a
    and $01
    jr nz, jr_000_208e

    jp Jump_000_2091


jr_000_208e:
    jp Jump_000_2096


Jump_000_2091:
    ld e, $04
    jp Jump_000_246b


Jump_000_2096:
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $001a
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$18
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
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0016
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$12
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
    ld hl, sp+$18
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$12
    sub [hl]
    ld e, a
    ld a, d
    inc hl
    sbc [hl]
    push af
    ld hl, sp+$28
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$1c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$16
    pop af
    ld a, e
    sbc [hl]
    ld e, a
    ld a, d
    inc hl
    sbc [hl]
    ld hl, sp+$28
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$35
    ld a, [hl]
    ld hl, sp+$12
    ld [hl], a
    ld hl, sp+$36
    ld a, [hl]
    ld hl, sp+$13
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$25
    ld d, h
    ld e, l
    ld hl, sp+$12
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp nc, Jump_000_2122

    ld hl, sp+$25
    ld a, [hl]
    ld hl, sp+$35
    ld [hl], a
    ld hl, sp+$26
    ld a, [hl]
    ld hl, sp+$36
    ld [hl], a

Jump_000_2122:
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0022
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $001e
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$12
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$18
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$08
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$10
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$16
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0026
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0e
    ld [hl+], a
    ld [hl], d

Jump_000_216b:
    ld hl, sp+$35
    ld a, [hl+]
    or [hl]
    jp z, Jump_000_2469

    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$0a
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
    ld hl, sp+$0a
    ld a, [hl]
    or a
    jr nz, jr_000_2193

    inc hl
    ld a, [hl]
    and $01
    jr nz, jr_000_2193

    jp Jump_000_2196


jr_000_2193:
    jp Jump_000_231e


Jump_000_2196:
    ld a, $09
    push af
    inc sp
    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_28cc
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
    ld hl, sp+$18
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    dec c
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$00
    ld a, [hl]
    ld hl, sp+$04
    and [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$05
    and [hl]
    ld hl, sp+$01
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$06
    and [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$07
    and [hl]
    ld hl, sp+$03
    ld [hl], a
    ld hl, sp+$00
    ld a, [hl]
    ld hl, sp+$22
    ld [hl], a
    or a
    jp nz, Jump_000_228e

    ld hl, sp+$0a
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_000_2212

    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$2d
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
    jp Jump_000_224f


Jump_000_2212:
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$00
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl-], a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_0e7f
    add sp, $04
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
    ld hl, sp+$2d
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

Jump_000_224f:
    ld a, $01
    ld hl, sp+$2d
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
    jp c, Jump_000_2271

    ld hl, sp+$1e
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, $00
    ld [bc], a
    ld e, $01
    jp Jump_000_246b


Jump_000_2271:
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0022
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld hl, sp+$2d
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a

Jump_000_228e:
    ld hl, sp+$10
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$00
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl-], a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_1077
    add sp, $04
    push hl
    ld hl, sp+$2b
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$29
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_000_22d3

    ld hl, sp+$1e
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, $00
    ld [bc], a
    ld e, $01
    jp Jump_000_246b


Jump_000_22d3:
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0026
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$22
    ld a, [hl]
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$29
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$04
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$2d
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$08
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld [hl-], a
    ld [hl], e
    ld e, c
    ld d, b
    dec hl
    dec hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a

Jump_000_231e:
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0016
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld hl, sp+$04
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
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld a, [hl]
    and $01
    ld b, a
    ld de, $0200
    ld a, e
    sub c
    ld e, a
    ld a, d
    sbc b
    ld hl, sp+$24
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$35
    ld d, h
    ld e, l
    ld hl, sp+$23
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp nc, Jump_000_2366

    ld hl, sp+$35
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$23
    ld [hl+], a
    ld [hl], e

Jump_000_2366:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$04
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
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld a, [hl]
    and $01
    ld b, a
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$0a
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
    ld hl, sp+$23
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
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
    ld hl, sp+$28
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_0c1a
    add sp, $0a
    ld c, e
    ld a, c
    or a
    jp z, Jump_000_23c4

    ld hl, sp+$1e
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, $00
    ld [bc], a
    ld e, $01
    jp Jump_000_246b


Jump_000_23c4:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$04
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
    ld hl, sp+$23
    ld a, [hl]
    ld hl, sp+$0a
    ld [hl], a
    ld hl, sp+$24
    ld a, [hl]
    ld hl, sp+$0b
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$0a
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$0e
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld hl, sp+$35
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$23
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$36
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$1c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$23
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$1c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a
    ld hl, sp+$20
    ld a, [hl+]
    or [hl]
    jp z, Jump_000_216b

    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$20
    ld [hl+], a
    ld [hl], d
    jp Jump_000_216b


Jump_000_2469:
    ld e, $00

Jump_000_246b:
    add sp, $31
    ret


Call_000_246e:
    push af
    push af
    ld hl, $c2a8
    ld hl, $c2a8
    ld c, [hl]
    ld hl, $c2a9
    ld b, [hl]
    ld hl, $001a
    add hl, bc
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$00
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


Call_000_249c:
    ld hl, $c2a8
    ld hl, $c2a8
    ld c, [hl]
    ld hl, $c2a9
    ld b, [hl]
    ld a, [bc]
    ld c, a
    ld e, c
    ret


Call_000_24ab:
    push af
    push af
    ld hl, $c2a8
    ld hl, $c2a8
    ld c, [hl]
    ld hl, $c2a9
    ld b, [hl]
    ld hl, $001e
    add hl, bc
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$00
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


Call_000_24d9:
    push af
    push af
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
    call Call_000_0e7f
    add sp, $04
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


Call_000_2503:
    ld hl, $c2a8
    ld hl, $c2a8
    ld c, [hl]
    ld hl, $c2a9
    ld b, [hl]
    inc bc
    inc bc
    ld a, [bc]
    ld c, a
    ld e, c
    ret


Call_000_2514:
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7f30
    ld hl, sp+$02
    ld a, [hl]
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ret


Call_000_2534:
    ld de, $a000
    ld a, [de]
    ld c, a
    ld e, c
    ret


    push af
    ld hl, sp+$0e
    ld a, [hl]
    or a
    jp nz, Jump_000_254c

    inc hl
    ld a, [hl]
    sub $02
    jp nz, Jump_000_254c

    jr jr_000_254f

Jump_000_254c:
    jp Jump_000_2571


jr_000_254f:
    ld hl, sp+$10
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_058d
    or a
    dec h
    rst RST_38
    rst RST_38
    add sp, $07
    jp Jump_000_25b4


Jump_000_2571:
    ld hl, $c2aa
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_058d
    or a
    dec h
    rst RST_38
    rst RST_38
    add sp, $07
    ld de, $c2aa
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$10
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$0e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call Call_000_2bbe
    add sp, $06

Jump_000_25b4:
    add sp, $02
    ret


    add sp, -$13
    ld a, $01
    push af
    inc sp
    call Call_000_2514
    add sp, $01
    ld hl, sp+$12
    ld [hl], $00

Jump_000_25c6:
    ld hl, sp+$12
    ld a, [hl]
    ld hl, sp+$1d
    sub [hl]
    jp nc, Jump_000_2757

    ld a, [hl]
    ld hl, sp+$0f
    ld [hl+], a
    ld [hl], $00
    inc hl
    inc hl
    ld c, [hl]
    ld b, $00
    ld hl, sp+$0f
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
    ld a, $04
    sub c
    ld a, $00
    sbc b
    jp nc, Jump_000_25f5

    ld bc, $0004
    jp Jump_000_2601


Jump_000_25f5:
    ld hl, sp+$1d
    ld a, [hl]
    ld hl, sp+$12
    sub [hl]
    ld hl, sp+$0e
    ld [hl], a
    ld c, a
    ld b, $00

Jump_000_2601:
    ld hl, sp+$11
    ld [hl], c
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld hl, sp+$0c
    ld [hl], $b0
    inc hl
    ld [hl], $7f
    ld hl, sp+$19
    ld c, [hl]
    ld a, c
    ld hl, sp+$12
    add [hl]
    ld c, a
    ld b, $00
    ld b, $00
    ld a, c
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld bc, $7fb1
    ld hl, sp+$12
    ld a, [hl]
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$19
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$08
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$1d
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$0c
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$04
    ld [hl], $00
    ld hl, sp+$09
    ld a, [hl]
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    push bc
    ld hl, $0008
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
    call Call_000_28cc
    add sp, $06
    push hl
    ld hl, sp+$08
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    pop bc
    ld hl, sp+$04
    ld a, [hl]
    ld [bc], a
    ld bc, $7fb2
    ld hl, sp+$00
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$0a
    ld a, [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], $00
    push bc
    ld hl, $0010
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
    call Call_000_28cc
    add sp, $06
    push hl
    ld hl, sp+$04
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    pop bc
    ld hl, sp+$00
    ld a, [hl]
    ld [bc], a
    ld bc, $7fb3
    ld hl, sp+$04
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$0b
    ld a, [hl]
    ld hl, sp+$07
    ld [hl], a
    push bc
    ld hl, $0018
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
    call Call_000_28cc
    add sp, $06
    push hl
    ld hl, sp+$08
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    pop bc
    ld hl, sp+$04
    ld a, [hl]
    ld [bc], a
    ld bc, $7fb4
    ld hl, sp+$11
    ld a, [hl]
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call Call_000_2514
    add sp, $01

Jump_000_271d:
    call Call_000_2534
    ld c, e
    ld b, $00
    ld a, c
    sub $e1
    jp nz, Jump_000_272d

    or b
    jp z, Jump_000_271d

Jump_000_272d:
    ld a, $01
    push af
    inc sp
    call Call_000_2514
    add sp, $01
    ld hl, sp+$0f
    ld b, [hl]
    ld a, [hl]
    add a
    ld b, a
    ld c, $00
    push bc
    ld hl, $a000
    push hl
    ld hl, sp+$22
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_3023
    add sp, $06
    ld hl, sp+$12
    inc [hl]
    inc [hl]
    inc [hl]
    inc [hl]
    jp Jump_000_25c6


Jump_000_2757:
    ld a, $00
    push af
    inc sp
    call Call_000_2514
    add sp, $01
    add sp, $13
    ret


Call_000_2763:
    jp Jump_000_2c2d


    jp Jump_000_297a


    jp Jump_000_29f3


    jp Jump_000_2aa4


Call_000_276f:
    jp Jump_000_2b78


    ld a, $05
    rst RST_08
    jp Jump_000_2b4b


    ld a, $05
    rst RST_08
    jp Jump_000_27e6


    ld a, $05
    rst RST_08
    jp Jump_000_2826


    ld a, $05
    rst RST_08
    jp Jump_000_2b1e


    ld a, $05
    rst RST_08
    jp Jump_000_27cc


    ld a, $05
    rst RST_08
    jp Jump_000_2b2d


    ld a, $05
    rst RST_08
    jp Jump_000_280c


    ld a, $05
    rst RST_08
    jp Jump_000_27da


    ld a, $05
    rst RST_08
    jp Jump_000_281a


    ld a, $05
    rst RST_08
    jp Jump_000_27fa


    ld a, $05
    rst RST_08
    jp Jump_000_283a


    ld a, $05
    rst RST_08
    jp Jump_000_28cc


    ld a, $05
    rst RST_08
    jp Jump_000_28e9


    ld a, $05
    rst RST_08
    jp Jump_000_2906


    ld a, $05
    rst RST_08
    jp Jump_000_2906


Jump_000_27cc:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_284c
    ld e, c
    ld d, b
    ret


Jump_000_27da:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_284c
    ret


Call_000_27e6:
Jump_000_27e6:
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
    call Call_000_2854
    ld e, c
    ld d, b
    ret


Call_000_27fa:
Jump_000_27fa:
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
    call Call_000_2854
    ret


Jump_000_280c:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_2886
    ld e, c
    ld d, b
    ret


Jump_000_281a:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_2886
    ret


Jump_000_2826:
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
    call Call_000_2889
    ld e, c
    ld d, b
    ret


Jump_000_283a:
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
    call Call_000_2889
    ret


Call_000_284c:
    ld a, c
    rlca
    sbc a
    ld b, a
    ld a, e
    rlca
    sbc a
    ld d, a

Call_000_2854:
    ld a, b
    push af
    xor d
    push af
    bit 7, d
    jr z, jr_000_2862

    sub a
    sub e
    ld e, a
    sbc a
    sub d
    ld d, a

jr_000_2862:
    bit 7, b
    jr z, jr_000_286c

    sub a
    sub c
    ld c, a
    sbc a
    sub b
    ld b, a

jr_000_286c:
    call Call_000_2889
    ret c

    pop af
    and $80
    jr z, jr_000_287b

    sub a
    sub c
    ld c, a
    sbc a
    sub b
    ld b, a

jr_000_287b:
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


Call_000_2886:
    ld b, $00
    ld d, b

Call_000_2889:
    ld a, e
    or d
    jr nz, jr_000_2894

    ld bc, $0000
    ld d, b
    ld e, c
    scf
    ret


jr_000_2894:
    ld l, c
    ld h, b
    ld bc, $0000
    or a
    ld a, $10

jr_000_289c:
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
    jr c, jr_000_28b2

    pop bc
    jr jr_000_28b4

jr_000_28b2:
    inc sp
    inc sp

jr_000_28b4:
    jr c, jr_000_28bd

    pop af
    dec a
    or a
    jr nz, jr_000_289c

    jr jr_000_28c2

jr_000_28bd:
    pop af
    dec a
    scf
    jr nz, jr_000_289c

jr_000_28c2:
    ld d, b
    ld e, c
    rl l
    ld c, l
    rl h
    ld b, h
    or a
    ret


Call_000_28cc:
Jump_000_28cc:
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

Jump_000_28db:
    or a
    ret z

    rr h
    rr l
    rr d
    rr e
    dec a
    jp Jump_000_28db


Jump_000_28e9:
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

Jump_000_28f8:
    or a
    ret z

    sra h
    rr l
    rr d
    rr e
    dec a
    jp Jump_000_28f8


Call_000_2906:
Jump_000_2906:
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

Jump_000_2915:
    or a
    ret z

    rl e
    rl d
    rl l
    rl h
    dec a
    jp Jump_000_2915


Call_000_2923:
    push bc
    ld hl, sp+$04
    ld a, [hl]
    call Call_000_2e7e
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld a, [hl]
    call Call_000_2ea7
    pop bc
    ret


    ld hl, sp+$02
    ld a, [hl+]
    ld [$c51c], a
    ld a, [hl]
    ld [$c51d], a
    ret


    ld a, [$c4ad]
    and $02
    jr nz, jr_000_294c

    push bc
    call Call_000_2fdb
    pop bc

jr_000_294c:
    ld a, [$c51c]
    ld e, a
    ret


    ld a, [$c4ad]
    and $02
    jr nz, jr_000_295d

    push bc
    call Call_000_2fdb
    pop bc

jr_000_295d:
    ld a, [$c51d]
    ld e, a
    ret


    ldh a, [rLCDC]
    or $10
    ldh [rLCDC], a
    ld a, $48
    ldh [rLYC], a
    ret


jr_000_296d:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_296d

    ldh a, [rLCDC]
    and $ef
    ldh [rLCDC], a
    ret


Jump_000_297a:
    add sp, -$09
    ld b, $04
    ld hl, sp+$0b
    call Call_000_2a39
    jr nz, jr_000_298d

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_29f0


jr_000_298d:
    ld hl, sp+$0f
    call Call_000_2a39
    jr nz, jr_000_29a3

    ld a, $21
    ld [$c4aa], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_29f0


jr_000_29a3:
    ld hl, sp+$00
    xor a
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    bit 7, a
    jr z, jr_000_29b7

    ld hl, sp+$0f
    call Call_000_2c1c
    ld hl, sp+$00
    ld [hl], $01

jr_000_29b7:
    ld hl, sp+$0e
    ld a, [hl]
    bit 7, a
    jr z, jr_000_29c9

    ld hl, sp+$0b
    call Call_000_2c1c
    ld hl, sp+$00
    ld a, $01
    xor [hl]
    ld [hl], a

jr_000_29c9:
    ld hl, sp+$0f
    push hl
    ld hl, sp+$0d
    push hl
    ld hl, sp+$09
    push hl
    ld hl, sp+$07
    push hl
    call Call_000_2c4c
    add sp, $08
    ld hl, sp+$00
    rr [hl]
    jr nc, jr_000_29e7

    ld b, $04
    ld hl, sp+$01
    call Call_000_2c1c

jr_000_29e7:
    ld hl, sp+$01
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_29f0:
    add sp, $09
    ret


Jump_000_29f3:
    add sp, -$08
    ld b, $04
    ld hl, sp+$0a
    call Call_000_2a39
    jr nz, jr_000_2a06

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_2a36


jr_000_2a06:
    ld hl, sp+$0e
    call Call_000_2a39
    jr nz, jr_000_2a1c

    ld a, $21
    ld [$c4aa], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_2a36


jr_000_2a1c:
    ld hl, sp+$0e
    push hl
    ld hl, sp+$0c
    push hl
    ld hl, sp+$08
    push hl
    ld hl, sp+$06
    push hl
    call Call_000_2c4c
    add sp, $08
    ld hl, sp+$00
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_2a36:
    add sp, $08
    ret


Call_000_2a39:
    xor a
    ld c, b

jr_000_2a3b:
    cp [hl]
    ret nz

    inc hl
    dec c
    jr nz, jr_000_2a3b

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


Call_000_2a4e:
    xor a
    bit 7, [hl]
    jr z, jr_000_2a55

    ld a, $80

jr_000_2a55:
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


jr_000_2a67:
    ld c, $03

jr_000_2a69:
    ld a, [de]
    sub [hl]
    ret nz

    dec de
    dec hl
    dec c
    ret z

    jr jr_000_2a69

    ld hl, sp+$07
    call Call_000_2a4e
    ld hl, sp+$0b
    call Call_000_2a4e
    ld hl, sp+$07
    bit 7, [hl]
    jr z, jr_000_2a93

    ld hl, sp+$0b
    bit 7, [hl]
    jr z, jr_000_2a90

    ld hl, sp+$0b
    ld d, h
    ld e, l
    ld hl, sp+$07
    jr jr_000_2a67

jr_000_2a90:
    xor a
    ccf
    ret


jr_000_2a93:
    ld hl, sp+$0b
    bit 7, [hl]
    jr z, jr_000_2a9c

    xor a
    dec a
    ret


jr_000_2a9c:
    ld hl, sp+$07
    ld d, h
    ld e, l
    ld hl, sp+$0b
    jr jr_000_2a67

Jump_000_2aa4:
    add sp, -$09
    ld b, $04
    ld hl, sp+$0b
    call Call_000_2a39
    jr nz, jr_000_2ab7

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_2b1b


jr_000_2ab7:
    ld hl, sp+$0f
    call Call_000_2a39
    jr nz, jr_000_2acd

    ld a, $21
    ld [$c4aa], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_2b1b


jr_000_2acd:
    ld hl, sp+$00
    xor a
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    bit 7, a
    jr z, jr_000_2ae1

    ld hl, sp+$0f
    call Call_000_2c1c
    ld hl, sp+$00
    ld [hl], $01

jr_000_2ae1:
    ld hl, sp+$0e
    ld a, [hl]
    bit 7, a
    jr z, jr_000_2af3

    ld hl, sp+$0b
    call Call_000_2c1c
    ld hl, sp+$00
    ld a, $01
    xor [hl]
    ld [hl], a

jr_000_2af3:
    ld hl, sp+$0f
    push hl
    ld hl, sp+$0d
    push hl
    ld hl, sp+$09
    push hl
    ld hl, sp+$07
    push hl
    call Call_000_2c4c
    add sp, $08
    ld hl, sp+$00
    rr [hl]
    jr nc, jr_000_2b12

    ld b, $04
    xor a
    ld hl, sp+$05
    call Call_000_2c1c

jr_000_2b12:
    ld hl, sp+$05
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_2b1b:
    add sp, $09
    ret


Jump_000_2b1e:
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
    jr jr_000_2b54

Jump_000_2b2d:
    ld hl, sp+$02
    ld a, [hl+]
    ld c, a
    ld e, [hl]

Call_000_2b32:
    xor a
    ld h, a
    ld l, a
    ld d, a

jr_000_2b36:
    xor a
    rr c
    jr nc, jr_000_2b3c

    add hl, de

jr_000_2b3c:
    sla e
    jr z, jr_000_2b44

    rl d
    jr jr_000_2b36

jr_000_2b44:
    rl d
    jr nz, jr_000_2b36

    ld e, l
    ld d, h
    ret


Call_000_2b4b:
Jump_000_2b4b:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld c, [hl]
    inc hl
    ld b, [hl]

jr_000_2b54:
    ld hl, $0000

jr_000_2b57:
    sra b
    jr nz, jr_000_2b64

    rr c
    jr nc, jr_000_2b60

    add hl, de

jr_000_2b60:
    jr z, jr_000_2b75

    jr jr_000_2b69

jr_000_2b64:
    rr c
    jr nc, jr_000_2b69

    add hl, de

jr_000_2b69:
    sla e
    jr z, jr_000_2b71

    rl d
    jr jr_000_2b57

jr_000_2b71:
    rl d
    jr nz, jr_000_2b57

jr_000_2b75:
    ld e, l
    ld d, h
    ret


Jump_000_2b78:
    add sp, -$08
    ld b, $04
    ld hl, sp+$0a
    call Call_000_2a39
    jr nz, jr_000_2b8b

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_2bbb


jr_000_2b8b:
    ld hl, sp+$0e
    call Call_000_2a39
    jr nz, jr_000_2ba1

    ld a, $21
    ld [$c4aa], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_2bbb


jr_000_2ba1:
    ld hl, sp+$0e
    push hl
    ld hl, sp+$0c
    push hl
    ld hl, sp+$08
    push hl
    ld hl, sp+$06
    push hl
    call Call_000_2c4c
    add sp, $08
    ld hl, sp+$04
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_2bbb:
    add sp, $08
    ret


Call_000_2bbe:
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

jr_000_2bcd:
    ld a, b
    or c
    ret z

    ld a, [de]
    inc de
    ld [hl], a
    dec bc
    inc hl
    jr jr_000_2bcd

Call_000_2bd7:
    push af
    push af
    ld hl, sp+$06
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_000_2be7:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    or a
    jp z, Jump_000_2c0a

    dec hl
    inc [hl]
    jr nz, jr_000_2bf8

    inc hl
    inc [hl]

jr_000_2bf8:
    ld a, c
    push af
    inc sp
    call Call_000_2923
    add sp, $01
    ld hl, sp+$02
    inc [hl]
    jr nz, jr_000_2c07

    inc hl
    inc [hl]

jr_000_2c07:
    jp Jump_000_2be7


Jump_000_2c0a:
    ld a, $0a
    push af
    inc sp
    call Call_000_2923
    add sp, $01
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc de
    add sp, $04
    ret


Call_000_2c1c:
    ld c, b
    xor a
    ld d, a

jr_000_2c1f:
    ld a, d
    sbc [hl]
    ld [hl+], a
    dec c
    jr nz, jr_000_2c1f

    ret


Call_000_2c26:
    ld c, b
    xor a

jr_000_2c28:
    ld [hl+], a
    dec c
    jr nz, jr_000_2c28

    ret


Jump_000_2c2d:
    add sp, -$04
    ld hl, sp+$0a
    push hl
    ld hl, sp+$08
    push hl
    ld hl, sp+$04
    push hl
    ld b, $04
    call Call_000_2cac
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


Call_000_2c4c:
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
    call Call_000_2c26
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call Call_000_2c26

jr_000_2c65:
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    xor a
    call Call_000_2d4e
    push af
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    pop af
    push hl
    call Call_000_2d4e
    pop de
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push de
    push hl
    call Call_000_2d44
    pop hl
    pop de
    jr c, jr_000_2c8b

    call Call_000_2c9c

jr_000_2c8b:
    ccf
    push af
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    pop af
    call Call_000_2d4e
    pop bc
    dec c
    ret z

    push bc
    jr jr_000_2c65

Call_000_2c9c:
    ld c, b

jr_000_2c9d:
    ld a, [de]
    sbc [hl]
    ld [de], a
    inc hl
    inc de
    dec c
    jr nz, jr_000_2c9d

    ret


    ld c, b

jr_000_2ca7:
    ld [hl+], a
    dec c
    jr nz, jr_000_2ca7

    ret


Call_000_2cac:
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
    call Call_000_2c26
    ld hl, sp+$04
    ld [hl], b

Jump_000_2cca:
    ld hl, sp+$04
    ld a, [hl]
    ld hl, sp+$05
    ld [hl], a

jr_000_2cd0:
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
    call Call_000_2b32
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
    jr z, jr_000_2d04

    ld a, [hl]
    adc d
    ld [hl+], a
    call Call_000_2d2f
    ld hl, sp+$05
    dec [hl]
    jr z, jr_000_2d04

    ld hl, sp+$0c
    call Call_000_2d37
    ld hl, sp+$08
    call Call_000_2d37
    jr jr_000_2cd0

jr_000_2d04:
    ld hl, sp+$04
    dec [hl]
    jr z, jr_000_2d2c

    ld hl, sp+$00
    call Call_000_2d37
    ld hl, sp+$0a
    call Call_000_2d37
    push bc
    ld b, $02
    ld hl, sp+$02
    ld d, h
    ld e, l
    ld hl, sp+$0a
    call Call_000_2d3c
    ld hl, sp+$04
    ld d, h
    ld e, l
    ld hl, sp+$0e
    call Call_000_2d3c
    pop bc
    jp Jump_000_2cca


jr_000_2d2c:
    add sp, $06
    ret


Call_000_2d2f:
jr_000_2d2f:
    dec c
    ret z

    ld a, $00
    adc [hl]
    ld [hl+], a
    jr jr_000_2d2f

Call_000_2d37:
    inc [hl]
    ret nz

    inc hl
    inc [hl]
    ret


Call_000_2d3c:
    ld c, b

jr_000_2d3d:
    ld a, [de]
    inc de
    ld [hl+], a
    dec c
    jr nz, jr_000_2d3d

    ret


Call_000_2d44:
    ld c, b
    xor a

jr_000_2d46:
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    dec c
    jr nz, jr_000_2d46

    ret


Call_000_2d4e:
    ld c, b

jr_000_2d4f:
    rl [hl]
    inc hl
    dec c
    jr nz, jr_000_2d4f

    ret


Jump_000_2d56:
    ld a, d
    or e
    ret z

    ld a, h
    cp $98
    jr c, jr_000_2d61

    sub $10
    ld h, a

jr_000_2d61:
    xor a
    cp e
    jr nz, jr_000_2d66

    dec d

jr_000_2d66:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_2d66

    ld a, [bc]
    ld [hl+], a
    inc bc

jr_000_2d6f:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_2d6f

    ld a, [bc]
    ld [hl], a
    inc bc
    inc l
    jr nz, jr_000_2d83

    inc h
    ld a, h
    cp $98
    jr nz, jr_000_2d83

    ld h, $88

jr_000_2d83:
    dec e
    jr nz, jr_000_2d66

    dec d
    bit 7, d
    jr z, jr_000_2d66

    ret


Jump_000_2d8c:
    ld a, d
    or e
    ret z

    ld a, h
    cp $98
    jr c, jr_000_2d97

    sub $10
    ld h, a

jr_000_2d97:
    push de
    ld a, [bc]
    ld e, a
    inc bc
    push bc
    ld bc, $0000
    ld a, [$c51f]
    bit 0, a
    jr z, jr_000_2da8

    ld b, $ff

jr_000_2da8:
    bit 1, a
    jr z, jr_000_2dae

    ld c, $ff

jr_000_2dae:
    ld d, a
    ld a, [$c51e]
    xor d
    ld d, a
    bit 0, d
    jr z, jr_000_2dbb

    ld a, e
    xor b
    ld b, a

jr_000_2dbb:
    bit 1, d
    jr z, jr_000_2dc2

    ld a, e
    xor c
    ld c, a

jr_000_2dc2:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_2dc2

    ld [hl], b
    inc hl

jr_000_2dca:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_2dca

    ld [hl], c
    inc hl
    ld a, h
    cp $98
    jr nz, jr_000_2dd9

    ld h, $88

jr_000_2dd9:
    pop bc
    pop de
    dec de
    ld a, d
    or e
    jr nz, jr_000_2d97

    ret


Call_000_2de1:
    call Call_000_049f
    push hl
    ld hl, $c50b
    ld b, $06

jr_000_2dea:
    ld a, [hl]
    inc hl
    or [hl]
    cp $00
    jr z, jr_000_2dfc

    inc hl
    inc hl
    dec b
    jr nz, jr_000_2dea

    pop hl
    ld hl, $0000
    jr jr_000_2e20

jr_000_2dfc:
    pop de
    ld [hl], d
    dec hl
    ld [hl], e
    ld a, [$c509]
    dec hl
    ld [hl], a
    push hl
    call Call_000_2e71
    ld a, [$c4ad]
    and $02
    call nz, Call_000_2e29
    ld hl, $c507
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    inc hl
    ld a, [$c509]
    add [hl]
    ld [$c509], a
    pop hl

jr_000_2e20:
    ldh a, [rLCDC]
    or $81
    and $e7
    ldh [rLCDC], a
    ret


Call_000_2e29:
    ld hl, $c507
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
    jr z, jr_000_2e55

    ld bc, $0000
    cp $02
    jr z, jr_000_2e55

    ld bc, $0100

jr_000_2e55:
    inc hl
    inc hl
    add hl, bc
    ld c, l
    ld b, h
    ld a, [$c506]
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
    jp z, Jump_000_2d56

    jp Jump_000_2d8c


Call_000_2e71:
    ld a, [hl+]
    ld [$c506], a
    ld a, [hl+]
    ld [$c507], a
    ld a, [hl+]
    ld [$c508], a
    ret


Call_000_2e7e:
    cp $0a
    jr nz, jr_000_2e90

    push af
    ld a, [$c4ad]
    and $08
    jr nz, jr_000_2e8f

    call Call_000_2f6a
    pop af
    ret


jr_000_2e8f:
    pop af

jr_000_2e90:
    call Call_000_2ea7
    call Call_000_2f7f
    ret


    call Call_000_2ea7
    call Call_000_2f7f
    ret


    call Call_000_2f53
    ld a, $00
    call Call_000_2ea7
    ret


Call_000_2ea7:
    push af
    ld a, [$c508]
    or a
    jr nz, jr_000_2ebc

    call Call_000_2f16
    xor a
    ld [$c509], a
    call Call_000_058d
    ld [hl], $30
    nop
    nop

jr_000_2ebc:
    pop af
    push bc
    push de
    push hl
    ld e, a
    ld hl, $c507
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [hl+]
    and $03
    cp $02
    jr z, jr_000_2ed3

    inc hl
    ld d, $00
    add hl, de
    ld e, [hl]

jr_000_2ed3:
    ld a, [$c506]
    add e
    ld e, a
    ld a, [$c51d]
    ld l, a
    ld h, $00
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld a, [$c51c]
    ld c, a
    ld b, $00
    add hl, bc
    ld bc, $9800
    add hl, bc

jr_000_2eee:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_2eee

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
    call Call_000_2de1
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
    call Call_000_2e71
    pop bc
    ld de, $0000
    ret


Call_000_2f16:
    push bc
    call Call_000_2fdb
    ld a, $01
    ld [$c509], a
    xor a
    ld hl, $c50a
    ld b, $12

jr_000_2f25:
    ld [hl+], a
    dec b
    jr nz, jr_000_2f25

    ld a, $03
    ld [$c51e], a
    ld a, $00
    ld [$c51f], a
    call Call_000_2f38
    pop bc
    ret


Call_000_2f38:
    push de
    push hl
    ld hl, $9800
    ld e, $20

jr_000_2f3f:
    ld d, $20

jr_000_2f41:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_2f41

    ld [hl], $00
    inc hl
    dec d
    jr nz, jr_000_2f41

    dec e
    jr nz, jr_000_2f3f

    pop hl
    pop de
    ret


Call_000_2f53:
    push hl
    ld hl, $c51c
    xor a
    cp [hl]
    jr z, jr_000_2f5e

    dec [hl]
    jr jr_000_2f68

jr_000_2f5e:
    ld [hl], $13
    ld hl, $c51d
    xor a
    cp [hl]
    jr z, jr_000_2f68

    dec [hl]

jr_000_2f68:
    pop hl
    ret


Call_000_2f6a:
    push hl
    xor a
    ld [$c51c], a
    ld hl, $c51d
    ld a, $11
    cp [hl]
    jr z, jr_000_2f7a

    inc [hl]
    jr jr_000_2f7d

jr_000_2f7a:
    call Call_000_2fad

jr_000_2f7d:
    pop hl
    ret


Call_000_2f7f:
    push hl
    ld hl, $c51c
    ld a, $13
    cp [hl]
    jr z, jr_000_2f8b

    inc [hl]
    jr jr_000_2fab

jr_000_2f8b:
    ld [hl], $00
    ld hl, $c51d
    ld a, $11
    cp [hl]
    jr z, jr_000_2f98

    inc [hl]
    jr jr_000_2fab

jr_000_2f98:
    ld a, [$c4ad]
    and $04
    jr z, jr_000_2fa8

    xor a
    ld [$c51d], a
    ld [$c51c], a
    jr jr_000_2fab

jr_000_2fa8:
    call Call_000_2fad

jr_000_2fab:
    pop hl
    ret


Call_000_2fad:
    push bc
    push de
    push hl
    ld hl, $9800
    ld bc, $9820
    ld e, $1f

jr_000_2fb8:
    ld d, $20

jr_000_2fba:
    ldh a, [rSTAT]
    and $02
    jr nz, jr_000_2fba

    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, jr_000_2fba

    dec e
    jr nz, jr_000_2fb8

    ld d, $20

jr_000_2fcb:
    ldh a, [rSTAT]
    and $02
    jr nz, jr_000_2fcb

    ld a, $00
    ld [hl+], a
    dec d
    jr nz, jr_000_2fcb

    pop hl
    pop de
    pop bc
    ret


Call_000_2fdb:
Jump_000_2fdb:
    di
    ldh a, [rLCDC]
    bit 7, a
    jr z, jr_000_2ff7

    call Call_000_049f
    ld bc, $2962
    ld hl, $c4b6
    call Call_000_044c
    ld bc, $296d
    ld hl, $c4c6
    call Call_000_044c

jr_000_2ff7:
    call Call_000_3004
    ldh a, [rLCDC]
    or $81
    and $e7
    ldh [rLCDC], a
    ei
    ret


Call_000_3004:
    xor a
    ld [$c51c], a
    ld [$c51d], a
    call Call_000_2f38
    ld a, $02
    ld [$c4ad], a
    ret


Call_000_3014:
jr_000_3014:
    ldh a, [rSTAT]
    and $02
    jr nz, jr_000_3014

    ld a, [bc]
    ld [hl+], a
    inc bc
    dec de
    ld a, d
    or e
    jr nz, jr_000_3014

    ret


Call_000_3023:
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
    call Call_000_3014
    pop bc
    ret


    ld hl, $303d
    call Call_000_2de1
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
    jr jr_000_3072

    ld a, [de]
    dec de
    inc e
    dec e
    ld e, $1f
    jr nz, jr_000_3082

    ld [hl+], a
    inc hl
    inc h
    dec h
    ld h, $27
    jr z, jr_000_3092

    ld a, [hl+]
    dec hl
    inc l
    dec l
    ld l, $2f
    jr nc, jr_000_30a2

    ld [hl-], a

jr_000_3072:
    inc sp
    inc [hl]
    dec [hl]
    ld [hl], $37
    jr c, jr_000_30b2

    ld a, [hl-]
    dec sp
    inc a
    dec a
    ld a, $3f
    ld b, b
    ld b, c
    ld b, d

jr_000_3082:
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

jr_000_3092:
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

jr_000_30a2:
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

jr_000_30b2:
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
    jr jr_000_316d

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
    jr jr_000_3178

    jr z, jr_000_31b1

    add c
    add c
    ld c, a
    jr z, jr_000_317f

    rst RST_38
    add c
    add c
    add c
    add c
    add c

jr_000_316d:
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

jr_000_3178:
    adc c
    adc c
    adc c
    ld sp, hl
    add c
    add c
    rst RST_38

jr_000_317f:
    ld bc, $0603
    adc h
    ret c

    ld [hl], b
    jr nz, jr_000_3187

jr_000_3187:
    ld a, [hl]
    jp $d3d3


    db $db
    jp $7ec3


    jr jr_000_31cd

    inc l
    inc l
    ld a, [hl]
    jr jr_000_31ae

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
    jr jr_000_31a7

jr_000_31a7:
    ld [hl], b
    ret z

    sbc $db
    db $db
    ld a, [hl]
    dec de

jr_000_31ae:
    dec de
    nop
    nop

jr_000_31b1:
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

jr_000_31cd:
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

    jr jr_000_3263

    jr jr_000_324d

jr_000_324d:
    jr jr_000_324f

jr_000_324f:
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

jr_000_3263:
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
    jr jr_000_3291

    stop
    nop
    nop
    nop
    nop
    inc b
    ld [$1818], sp
    jr jr_000_329d

    ld [$2004], sp
    db $10
    jr jr_000_32a3

    jr @+$1a

    db $10
    jr nz, jr_000_3290

jr_000_3290:
    ld d, h

jr_000_3291:
    jr c, jr_000_3291

    jr c, jr_000_32e9

    nop
    nop
    nop
    jr jr_000_32b2

    ld a, [hl]
    jr @+$1a

jr_000_329d:
    nop
    nop
    nop
    nop
    nop
    nop

jr_000_32a3:
    nop
    jr nc, jr_000_32d6

    jr nz, jr_000_32a8

jr_000_32a8:
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

jr_000_32b2:
    nop
    nop
    jr @+$1a

    nop
    inc bc
    ld b, $0c
    jr jr_000_32ec

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
    jr jr_000_3301

    jr jr_000_32e3

    jr jr_000_32e5

    jr jr_000_32cf

jr_000_32cf:
    inc a
    ld h, [hl]
    ld c, $1c
    jr c, jr_000_3345

    ld a, [hl]

jr_000_32d6:
    nop
    ld a, [hl]
    inc c
    jr jr_000_3317

    ld b, $46
    inc a
    nop
    inc c
    inc e
    inc l
    ld c, h

jr_000_32e3:
    ld a, [hl]
    inc c

jr_000_32e5:
    inc c
    nop
    ld a, [hl]
    ld h, b

jr_000_32e9:
    ld a, h
    ld b, $06

jr_000_32ec:
    ld b, [hl]
    inc a
    nop
    inc e
    jr nz, jr_000_3352

    ld a, h
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    ld a, [hl]
    ld b, $0e
    inc e
    jr @+$1a

    jr jr_000_32ff

jr_000_32ff:
    inc a
    ld h, [hl]

jr_000_3301:
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
    jr c, jr_000_330f

jr_000_330f:
    nop
    jr jr_000_332a

    nop
    nop
    jr jr_000_332e

    nop

jr_000_3317:
    nop
    jr jr_000_3332

    nop
    jr jr_000_3335

    stop
    ld b, $0c
    jr jr_000_3353

    jr @+$0e

    ld b, $00
    nop
    nop
    inc a

jr_000_332a:
    nop
    nop
    inc a
    nop

jr_000_332e:
    nop
    ld h, b
    jr nc, jr_000_334a

jr_000_3332:
    inc c
    jr jr_000_3365

jr_000_3335:
    ld h, b
    nop
    inc a
    ld b, [hl]
    ld b, $0c
    jr jr_000_3355

    nop
    jr jr_000_337c

    ld h, [hl]
    ld l, [hl]
    ld l, d
    ld l, [hl]
    ld h, b

jr_000_3345:
    inc a
    nop
    inc a
    ld h, [hl]
    ld h, [hl]

jr_000_334a:
    ld a, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    nop
    ld a, h
    ld h, [hl]
    ld h, [hl]

jr_000_3352:
    ld a, h

jr_000_3353:
    ld h, [hl]
    ld h, [hl]

jr_000_3355:
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

jr_000_3365:
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

jr_000_337c:
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
    jr jr_000_33a1

    jr jr_000_33a3

    jr jr_000_33a5

    jr jr_000_338f

jr_000_338f:
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

jr_000_33a1:
    ld h, b
    ld h, b

jr_000_33a3:
    ld h, b
    ld h, b

jr_000_33a5:
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

    jr jr_000_33fe

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

jr_000_33fe:
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

    jr jr_000_340f

jr_000_340f:
    ld a, [hl]
    ld c, $1c
    jr c, jr_000_3484

    ld h, b
    ld a, [hl]
    nop
    ld e, $18
    jr jr_000_3433

    jr jr_000_3435

    ld e, $00
    ld b, b
    ld h, b
    jr nc, jr_000_343b

    inc c
    ld b, $02
    nop
    ld a, b
    jr jr_000_3442

    jr jr_000_3444

    jr jr_000_34a6

    nop
    db $10
    jr c, jr_000_349e

    nop

jr_000_3433:
    nop
    nop

jr_000_3435:
    nop
    nop
    nop
    nop
    nop
    nop

jr_000_343b:
    nop
    nop
    ld a, [hl]
    nop
    nop
    ret nz

    ret nz

jr_000_3442:
    ld h, b
    nop

jr_000_3444:
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

    jr nc, jr_000_34a6

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

jr_000_3484:
    ld h, [hl]
    ld h, [hl]
    nop
    jr jr_000_3489

jr_000_3489:
    jr jr_000_34a3

    jr jr_000_34a5

    jr jr_000_348f

jr_000_348f:
    nop
    ld [$1818], sp
    jr jr_000_34ad

    ld e, b
    jr nc, jr_000_34f8

    ld h, h
    ld l, b
    ld [hl], b
    ld a, b
    ld l, h
    ld h, [hl]

jr_000_349e:
    nop
    jr jr_000_34b9

    jr jr_000_34bb

jr_000_34a3:
    jr jr_000_34bd

jr_000_34a5:
    inc c

jr_000_34a6:
    nop
    nop
    db $fc
    sub $d6
    sub $d6

jr_000_34ad:
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

jr_000_34b9:
    ld h, [hl]
    ld h, [hl]

jr_000_34bb:
    ld h, [hl]
    ld h, [hl]

jr_000_34bd:
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
    jr c, jr_000_34f8

    ld c, [hl]
    inc a
    nop
    jr jr_000_351d

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

jr_000_34f8:
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
    jr c, jr_000_3585

    ld a, [hl]
    nop
    ld c, $18
    jr jr_000_354b

    jr jr_000_3535

jr_000_351d:
    ld c, $00
    jr jr_000_3539

    jr jr_000_353b

    jr jr_000_353d

    jr @+$1a

    ld [hl], b
    jr jr_000_3542

    inc c
    jr jr_000_3545

    ld [hl], b
    nop
    nop
    ld h, b
    ldh a, [c]
    sbc [hl]
    inc c
    nop

jr_000_3535:
    nop
    nop
    db $10
    db $10

jr_000_3539:
    jr z, jr_000_3563

jr_000_353b:
    ld b, h
    ld b, h

jr_000_353d:
    add d
    cp $3c
    ld h, d
    ld h, b

jr_000_3542:
    ld h, b
    ld h, b
    ld h, d

jr_000_3545:
    inc e
    jr nc, @+$26

    nop
    ld h, [hl]
    ld h, [hl]

jr_000_354b:
    ld h, [hl]
    ld h, [hl]
    ld a, $00
    inc c
    jr jr_000_3552

jr_000_3552:
    inc a
    ld a, [hl]
    ld h, b
    inc a
    nop
    jr jr_000_35bf

    nop
    inc a
    ld b, $7e
    ld a, $00
    inc h
    nop
    inc a
    ld b, [hl]

jr_000_3563:
    ld a, $46
    ld a, $00
    jr nc, jr_000_3581

    nop
    inc a
    ld b, $7e
    ld a, $00
    jr jr_000_3589

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

jr_000_3581:
    nop
    inc a
    ld a, [hl]
    ld h, b

jr_000_3585:
    ld a, $00
    inc h
    nop

jr_000_3589:
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
    jr jr_000_35b3

    jr jr_000_35b5

    jr jr_000_359f

jr_000_359f:
    jr jr_000_35c5

    nop
    jr jr_000_35bc

    jr jr_000_35be

    nop
    db $10
    ld [$1800], sp
    jr jr_000_35c5

    jr jr_000_35af

jr_000_35af:
    inc h
    nop
    inc a
    ld h, [hl]

jr_000_35b3:
    ld a, [hl]
    ld h, [hl]

jr_000_35b5:
    ld h, [hl]
    nop
    jr jr_000_35b9

jr_000_35b9:
    inc a
    ld h, [hl]
    ld a, [hl]

jr_000_35bc:
    ld h, [hl]
    ld h, [hl]

jr_000_35be:
    nop

jr_000_35bf:
    inc c
    jr jr_000_3640

    ld h, b
    ld a, h
    ld h, b

jr_000_35c5:
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
    jr jr_000_360d

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
    jr nc, jr_000_3601

    nop
    inc a
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    jr jr_000_3615

    nop
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    jr nc, jr_000_3611

    nop
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    ld h, [hl]
    nop

jr_000_3601:
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

jr_000_360d:
    inc a
    nop
    ld h, [hl]
    nop

jr_000_3611:
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]

jr_000_3615:
    inc a
    nop
    jr jr_000_3655

    ld h, d
    ld h, b
    ld h, b
    ld h, d
    inc a
    jr @+$1e

    ld a, [hl-]
    jr nc, jr_000_369f

    jr nc, jr_000_3655

    ld a, [hl]
    nop
    ld h, [hl]
    ld h, [hl]
    inc a
    jr jr_000_3668

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

    jr jr_000_3653

    jr jr_000_3655

    jr jr_000_3657

    inc c

jr_000_3640:
    jr jr_000_3642

jr_000_3642:
    inc a
    ld b, $7e
    ld a, $00
    inc c
    jr jr_000_364a

jr_000_364a:
    jr jr_000_3664

    jr jr_000_3666

    nop
    inc c
    jr jr_000_3652

jr_000_3652:
    inc a

jr_000_3653:
    ld h, [hl]
    ld h, [hl]

jr_000_3655:
    inc a
    nop

jr_000_3657:
    inc c
    jr jr_000_365a

jr_000_365a:
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld a, $00
    inc [hl]
    ld e, b
    nop
    ld a, h
    ld h, [hl]

jr_000_3664:
    ld h, [hl]
    ld h, [hl]

jr_000_3666:
    nop
    ld a, [de]

jr_000_3668:
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
    jr jr_000_3682

jr_000_3682:
    jr jr_000_36b4

    ld h, b
    ld h, [hl]
    inc a
    nop
    nop
    nop
    ld a, $30
    jr nc, jr_000_36be

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

jr_000_369f:
    ld h, d
    db $e4
    ld l, b
    halt
    ld l, $56
    sbc a
    ld b, $00
    jr jr_000_36aa

jr_000_36aa:
    jr @+$1a

    jr @+$1a

    jr jr_000_36cb

    ld [hl], $6c
    ret c

    ld l, h

jr_000_36b4:
    ld [hl], $1b
    nop
    ret c

    ld l, h
    ld [hl], $1b
    ld [hl], $6c
    ret c

jr_000_36be:
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

jr_000_36cb:
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
    jr c, jr_000_372b

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

jr_000_372b:
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
    jr nc, jr_000_37e7

jr_000_37e7:
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
    jr c, jr_000_3830

jr_000_3830:
    db $10
    jr c, jr_000_389f

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
    jr c, jr_000_386f

jr_000_386f:
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
    jr jr_000_3894

    jr jr_000_3896

    db $10
    inc a
    jr jr_000_38be

    ld h, [hl]
    ld h, [hl]
    inc a
    jr jr_000_38c3

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

jr_000_3894:
    inc h
    ld h, [hl]

jr_000_3896:
    nop
    inc e
    ld [hl], $78
    call c, $eccc
    ld a, b
    nop

jr_000_389f:
    inc c
    jr jr_000_38da

    ld d, h
    ld d, h
    jr c, jr_000_38d6

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

jr_000_38be:
    nop
    nop
    ld a, [hl]
    nop
    ld a, [hl]

jr_000_38c3:
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
    jr nc, jr_000_38e9

    inc c
    jr jr_000_3904

    nop
    ld a, [hl]

jr_000_38d6:
    nop
    inc c
    jr @+$32

jr_000_38da:
    jr @+$0e

    nop
    ld a, [hl]
    nop
    nop
    ld c, $1b
    dec de
    jr jr_000_38fd

    jr jr_000_38ff

    jr jr_000_3901

jr_000_38e9:
    jr jr_000_3903

    ret c

    ret c

    ld [hl], b
    nop
    jr jr_000_3909

    nop
    ld a, [hl]
    nop

jr_000_38f4:
    jr jr_000_390e

    nop
    nop
    ld [hl-], a
    ld c, h
    nop
    ld [hl-], a
    ld c, h

jr_000_38fd:
    nop
    nop

jr_000_38ff:
    jr c, @+$6e

jr_000_3901:
    jr c, jr_000_3903

jr_000_3903:
    nop

jr_000_3904:
    nop
    nop
    nop
    jr c, @+$7e

jr_000_3909:
    jr c, jr_000_390b

jr_000_390b:
    nop
    nop
    nop

jr_000_390e:
    nop
    nop
    nop
    nop
    nop
    jr jr_000_392d

    nop
    nop
    nop
    nop
    rrca
    jr jr_000_38f4

    ld [hl], b
    jr nc, jr_000_391f

jr_000_391f:
    jr c, @+$6e

    ld l, h
    ld l, h
    ld l, h
    nop
    nop
    nop
    jr c, @+$6e

    jr jr_000_395b

    ld a, h
    nop

jr_000_392d:
    nop
    nop
    ld a, b
    inc c
    jr c, jr_000_393f

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

jr_000_393f:
    push af
    push bc

jr_000_3941:
    ld b, $ff

jr_000_3943:
    call Call_000_394f
    or a
    jr nz, jr_000_3941

    dec b
    jr nz, jr_000_3943

    pop bc
    pop af
    ret


Call_000_394f:
    push bc
    ld a, $20
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    cpl
    and $0f

jr_000_395b:
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


Call_000_397c:
jr_000_397c:
    call Call_000_394f
    and b
    jr z, jr_000_397c

    ret


Call_000_3983:
    call Call_000_394f
    ld e, a
    ret


    push bc
    ld hl, sp+$04
    ld b, [hl]
    call Call_000_397c
    ld e, a
    pop bc
    ret


Call_000_3992:
    push bc
    call Call_000_39af
    ld b, $32

Jump_000_3998:
    jr jr_000_399a

jr_000_399a:
    jr jr_000_399c

jr_000_399c:
    jr jr_000_399e

jr_000_399e:
    jr jr_000_39a0

jr_000_39a0:
    jr jr_000_39a2

jr_000_39a2:
    dec b
    jp nz, Jump_000_3998

    nop
    pop bc
    jr jr_000_39aa

jr_000_39aa:
    jr jr_000_39ac

jr_000_39ac:
    jr jr_000_39ae

jr_000_39ae:
    ret


Call_000_39af:
jr_000_39af:
    dec de
    ld a, e
    or d
    ret z

    ld b, $33

Jump_000_39b5:
    jr jr_000_39b7

jr_000_39b7:
    jr jr_000_39b9

jr_000_39b9:
    jr jr_000_39bb

jr_000_39bb:
    jr jr_000_39bd

jr_000_39bd:
    jr jr_000_39bf

jr_000_39bf:
    dec b
    jp nz, Jump_000_39b5

    nop
    jr jr_000_39c6

jr_000_39c6:
    jr jr_000_39c8

jr_000_39c8:
    jr jr_000_39ca

jr_000_39ca:
    jr jr_000_39af

Call_000_39cc:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    call Call_000_3992
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
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
