; Disassembly of "updater-code.gb"
; This file was created with:
; mgbdis v3.0 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $000", ROM0[$0]

RST_00::
    ret


Call_000_0001:
Jump_000_0001:
    rst RST_38
    rst RST_38

Jump_000_0003:
    rst RST_38
    rst RST_38
    rst RST_38

Jump_000_0006:
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

Call_000_0021:
    rst RST_38
    rst RST_38

Call_000_0023:
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

Call_000_0041:
    ld hl, $c2bb
    jp Jump_000_0067


    rst RST_38

LCDCInterrupt::
    push hl
    ld hl, $c2cb
    jp Jump_000_0067


    rst RST_38

TimerOverflowInterrupt::
    push hl
    ld hl, $c2db
    jp Jump_000_0067


    rst RST_38

SerialTransferCompleteInterrupt::
    push hl
    ld hl, $c2eb
    jp Jump_000_0067


    rst RST_38

JoypadTransitionInterrupt::
    push hl
    ld hl, $c2fb
    jp Jump_000_0067


Jump_000_0067:
    push af

    push bc
    push de
    ld a, [$c2b8]
    inc a
    ld [$c2b8], a

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

Call_000_0080:
Jump_000_0080:
jr_000_0080:
    ld a, [$c2b8]

Jump_000_0083:
    dec a
    ld [$c2b8], a
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

Jump_000_009a:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Jump_000_00a0:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Call_000_00c8:
Jump_000_00c8:
    rst RST_38
    rst RST_38

Call_000_00ca:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Call_000_00de:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    db "UPDATE", $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

HeaderNewLicenseeCode::
    db $00, $00

HeaderSGBFlag::
    db $00

HeaderCartridgeType::
    db $01

HeaderROMSize::
    db $01

HeaderRAMSize::
    db $00

HeaderDestinationCode::
    db $00

HeaderOldLicenseeCode::
    db $00

HeaderMaskROMVersion::
    db $01

HeaderComplementCheck::
    db $21

HeaderGlobalChecksum::
    db $54, $11

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
    ld [$c2b1], a
    ld a, $01
    ld [$c2b7], a
    ld [$2000], a
    xor a
    ld [$c2b8], a
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
    ld [$c2b9], a
    ld [$c2ba], a
    call $4182
    call Call_000_0ffd

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

Jump_000_0200:
    rst RST_38
    rst RST_38

Call_000_0202:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Jump_000_0207:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Call_000_020c:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Jump_000_0226:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Jump_000_0246:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Jump_000_0314:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Jump_000_0381:
    rst RST_38
    rst RST_38

Jump_000_0383:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Jump_000_0387:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    jp Jump_000_2c4f


    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Jump_000_0400:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Jump_000_0404:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Jump_000_041c:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Call_000_0422:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Jump_000_0454:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    jp Jump_000_3606


    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Jump_000_05c8:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    ld [$c2b2], a
    and $03
    ld l, a
    ld bc, $01e2
    sla l
    sla l
    add hl, bc
    jp hl


Call_000_0610:
    ld hl, $c2bb
    jp Jump_000_064c


Call_000_0616:
    ld hl, $c2cb
    jp Jump_000_064c


Call_000_061c:
    ld hl, $c2db
    jp Jump_000_064c


Call_000_0622:
    ld hl, $c2eb
    jp Jump_000_064c


Call_000_0628:
    ld hl, $c2fb
    jp Jump_000_064c


Call_000_062e:
    ld hl, $c2bb
    jp Jump_000_066c


Call_000_0634:
    ld hl, $c2cb
    jp Jump_000_066c


Call_000_063a:
    ld hl, $c2db
    jp Jump_000_066c


Call_000_0640:
    ld hl, $c2eb
    jp Jump_000_066c


Call_000_0646:
    ld hl, $c2fb
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


    ld hl, $c2b9
    inc [hl]
    jr nz, jr_000_067f

    inc hl
    inc [hl]

jr_000_067f:
    call $ff80
    ld a, $01
    ld [$c2b6], a
    ret


Call_000_0688:
    ldh a, [rLCDC]
    add a
    ret nc

    xor a
    di
    ld [$c2b6], a
    ei

jr_000_0692:
    halt
    nop
    ld a, [$c2b6]
    or a
    jr z, jr_000_0692

    xor a
    ld [$c2b6], a
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


    ld a, [$c2b5]
    cp $02
    jr nz, jr_000_06d0

    ldh a, [rSB]
    ld [$c2b4], a
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
    ld [$c2b5], a
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


    ld hl, $c2b2
    ld e, [hl]
    ret


Call_000_06fd:
    di
    ld a, [$c2b8]
    inc a
    ld [$c2b8], a
    ret


Call_000_0706:
    ld a, [$c2b8]
    dec a
    ld [$c2b8], a
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
    ld a, [$c2b7]
    push af
    ld a, b
    ld [$c2b7], a
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
    ld [$c2b7], a
    call Call_000_0706
    ret


Call_000_07bc:
Jump_000_07bc:
    call Call_000_35f7
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
    call Call_000_3831
    add sp, $02
    ret


Call_000_07db:
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
    call Call_000_2449
    add sp, $02

Jump_000_07f7:
    ld hl, sp+$02
    ld a, [hl]
    and $02
    jr nz, jr_000_0801

    jp Jump_000_0813


jr_000_0801:
    ld hl, sp+$03
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
    call Call_000_2449
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
    call Call_000_2449
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
    call Call_000_2449
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
    call Call_000_2449
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
    call Call_000_2449
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
    call Call_000_2449
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
    call Call_000_2449
    add sp, $02

Jump_000_08b5:
    ret


Call_000_08b6:
    add sp, -$12
    ld hl, sp+$0d
    ld [hl], $00
    xor a
    ld hl, sp+$16
    or [hl]
    jp nz, Jump_000_08d6

    dec hl
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    push bc
    call Call_000_2527
    add sp, $02
    ld b, d
    ld c, e
    ld hl, sp+$0e
    ld [hl], c
    jp Jump_000_090e


Jump_000_08d6:
    ld hl, sp+$14
    ld c, [hl]
    inc hl
    ld b, [hl]
    push bc
    call Call_000_2527
    add sp, $02
    ld b, d
    ld c, e
    ld hl, sp+$16
    ld a, [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], $00
    ld a, c
    dec hl
    sub [hl]
    ld a, b
    inc hl
    sbc [hl]
    rlca
    jp nc, Jump_000_0908

    ld hl, sp+$14
    ld c, [hl]
    inc hl
    ld b, [hl]
    push bc
    call Call_000_2527
    add sp, $02
    ld b, d
    ld c, e
    ld hl, sp+$0e
    ld [hl], c
    jp Jump_000_090e


Jump_000_0908:
    ld hl, sp+$16
    ld a, [hl]
    ld hl, sp+$0e
    ld [hl], a

Jump_000_090e:
    ld hl, sp+$17
    ld a, [hl]
    ld hl, sp+$0c
    ld [hl], a

Jump_000_0914:
    ld hl, sp+$0d
    ld a, [hl+]
    sub [hl]
    jp nc, Jump_000_0dc7

    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$0d
    ld l, [hl]
    ld h, $00
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, sp+$0a
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    inc hl
    inc [hl]
    ld hl, sp+$0a
    ld a, [hl]
    sub $80
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_000_0974

    ld hl, $c2b7
    ld a, [hl]
    ld hl, sp+$06
    ld [hl], a
    ld hl, sp+$0a
    ld c, [hl]
    ld hl, sp+$18
    ld a, [hl]
    push af
    inc sp
    ld hl, sp+$0d
    ld a, [hl]
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call Call_000_078d
    ld e, d
    dec d
    rst RST_38
    rst RST_38
    add sp, $03
    ld de, $c2b7
    ld hl, sp+$06
    ld a, [hl]
    ld [de], a
    ld bc, $2000
    ld a, [hl]
    ld [bc], a
    ld hl, sp+$0c
    ld a, [hl]
    add $06
    ld [hl], a
    jp Jump_000_0914


Jump_000_0974:
    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$0d
    ld l, [hl]
    ld h, $00
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], $00
    ld hl, sp+$0d
    inc [hl]
    ld hl, sp+$0a
    ld b, [hl]
    ld c, $00
    dec hl
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, $c2b7
    ld a, [hl]
    ld hl, sp+$06
    ld [hl], a
    ld a, c
    sub $bc
    ld a, b
    sbc $f1
    jp c, Jump_000_09ea

    inc hl
    ld [hl], $15
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00f1
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld c, e
    ld e, c
    ld d, b
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00bc
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$05
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$10
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_000_0d24


Jump_000_09ea:
    ld a, c
    sub $a4
    ld a, b
    sbc $ea
    jp c, Jump_000_0a35

    ld hl, sp+$07
    ld [hl], $14
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00ea
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld c, e
    ld e, c
    ld d, b
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00a4
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$05
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$10
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_000_0d24


Jump_000_0a35:
    ld a, c
    sub $ea
    ld a, b
    sbc $e2
    jp c, Jump_000_0a80

    ld hl, sp+$07
    ld [hl], $13
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00e2
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld c, e
    ld e, c
    ld d, b
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00ea
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$05
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$10
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_000_0d24


Jump_000_0a80:
    ld a, c
    sub $d2
    ld a, b
    sbc $db
    jp c, Jump_000_0acb

    ld hl, sp+$07
    ld [hl], $12
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00db
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld c, e
    ld e, c
    ld d, b
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00d2
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$05
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$10
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_000_0d24


Jump_000_0acb:
    ld a, c
    sub $ba
    ld a, b
    sbc $d4
    jp c, Jump_000_0b16

    ld hl, sp+$07
    ld [hl], $11
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00d4
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld c, e
    ld e, c
    ld d, b
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00ba
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$05
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$10
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_000_0d24


Jump_000_0b16:
    ld a, c
    sub $a2
    ld a, b
    sbc $cd
    jp c, Jump_000_0b61

    ld hl, sp+$07
    ld [hl], $10
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00cd
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld c, e
    ld e, c
    ld d, b
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00a2
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$05
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$10
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_000_0d24


Jump_000_0b61:
    ld a, c
    sub $e8
    ld a, b
    sbc $c5
    jp c, Jump_000_0bac

    ld hl, sp+$07
    ld [hl], $0f
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00c5
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld c, e
    ld e, c
    ld d, b
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00e8
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$05
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]

Jump_000_0ba0:
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$10
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_000_0d24


Jump_000_0bac:
    ld a, c
    sub $d0
    ld a, b
    sbc $be
    jp c, Jump_000_0bf7

    ld hl, sp+$07
    ld [hl], $0e
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00be
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld c, e
    ld e, c
    ld d, b
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00d0
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$05
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$10
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_000_0d24


Jump_000_0bf7:
    ld a, c
    sub $b8
    ld a, b
    sbc $b7
    jp c, Jump_000_0c42

    ld hl, sp+$07
    ld [hl], $0d
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]

Call_000_0c09:
    ld hl, $00b7
    ld a, e

Call_000_0c0d:
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld c, e
    ld e, c
    ld d, b
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00b8
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$05
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$10
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_000_0d24


Jump_000_0c42:
    ld a, c
    sub $a0
    ld a, b
    sbc $b0
    jp c, Jump_000_0c8d

    ld hl, sp+$07
    ld [hl], $0c
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00b0
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld c, e
    ld e, c
    ld d, b
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00a0
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$05
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$10
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_000_0d24


Jump_000_0c8d:
    ld a, c
    sub $b9
    ld a, b
    sbc $a8
    jp c, Jump_000_0cd8

    ld hl, sp+$07
    ld [hl], $0b
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00a8
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld c, e
    ld e, c
    ld d, b
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00b9
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$05
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$10
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_000_0d24


Jump_000_0cd8:
    ld a, c
    sub $a0
    ld a, b
    sbc $a1
    jp c, Jump_000_0d24

    ld hl, sp+$07
    ld [hl], $0a
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00a1
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld c, e
    ld e, c
    ld d, b
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    ld a, l
    ld d, h
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00a1
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld c, e
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$10
    ld [hl], c
    inc hl
    ld [hl], b

Jump_000_0d24:
    ld bc, $2000
    ld hl, sp+$07
    ld a, [hl]
    ld [bc], a
    ld hl, sp+$10
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld l, e
    ld h, d
    add hl, hl
    add hl, de
    add hl, hl
    add hl, hl
    add hl, hl
    ld a, l
    ld d, h
    ld hl, sp+$10
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $4000
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$10
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$18
    ld c, [hl]
    ld hl, sp+$0c
    ld a, [hl]
    add $08
    ld hl, sp+$02
    ld [hl+], a
    inc hl
    ld [hl], c
    ld hl, sp+$0f
    ld [hl], $00

Jump_000_0d5c:
    ld hl, sp+$0f
    ld a, [hl]
    sub $0c
    jp nc, Jump_000_0db2

    ld c, [hl]
    ld b, $00
    sla c
    rl b
    inc hl
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
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, [bc]
    ld c, a
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, sp+$0d
    ld a, [hl]
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call Call_000_07db
    add sp, $03
    ld hl, sp+$00
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, [bc]
    ld b, a
    ld c, b
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    dec hl
    dec hl
    ld a, [hl]
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call Call_000_07db
    add sp, $03
    ld hl, sp+$04
    inc [hl]
    ld hl, sp+$0f
    inc [hl]
    jp Jump_000_0d5c


Jump_000_0db2:
    ld hl, sp+$0c
    ld a, [hl]
    add $0c
    ld [hl], a
    ld de, $c2b7
    ld hl, sp+$06
    ld a, [hl]
    ld [de], a
    ld bc, $2000
    ld a, [hl]
    ld [bc], a
    jp Jump_000_0914


Jump_000_0dc7:
    add sp, $12
    ret


    add sp, -$14
    ld hl, sp+$00
    ld c, l
    ld b, h
    ld a, $10
    push af
    inc sp
    push bc
    ld hl, sp+$1b
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$1b
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call $0ebc
    add sp, $07

Jump_000_0de6:
    ld hl, $0000
    push hl
    ld a, $00
    push af
    inc sp
    call Call_000_23e4
    add sp, $03
    ld hl, $c2a6
    ld a, [hl]
    add $0c
    ld c, a
    ld hl, $c2a7
    ld a, [hl]
    add $1e
    ld b, a
    ld a, $01
    push af
    inc sp
    ld a, c
    push af
    inc sp
    push bc
    inc sp
    ld hl, $c2a6
    ld a, [hl]
    push af
    inc sp
    ld hl, $c2a7
    ld a, [hl]
    push af
    inc sp
    call Call_000_240d
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_23e4
    add sp, $03
    ld hl, sp+$00
    ld c, l
    ld b, h
    ld hl, $c2a6
    ld a, [hl]
    push af
    inc sp
    ld hl, $c2a7
    ld a, [hl]
    push af
    inc sp
    ld a, $00
    push af
    inc sp
    push bc
    call Call_000_08b6
    add sp, $05
    ld hl, sp+$00
    ld c, l
    ld b, h
    push bc
    call Call_000_2527
    add sp, $02
    ld b, d
    ld c, e
    ld a, c
    ld e, a
    add a
    add e
    add a
    ld c, a
    inc c
    inc c
    inc c
    ld hl, $c2a7
    ld b, [hl]
    ld a, b
    add c
    ld hl, $c2a7
    ld [hl], a
    ld a, $82
    ld hl, $c2a7
    sub [hl]
    jp nc, Jump_000_0e79

    ld hl, $c2a7
    ld [hl], $00
    ld hl, $c2a6
    ld a, [hl]
    add $0d
    ld hl, $c2a6
    ld [hl], a

Jump_000_0e79:
    ld a, $82
    ld hl, $c2a6
    sub [hl]
    jp nc, Jump_000_0e8f

    ld hl, $c2a7
    ld [hl], $00
    ld hl, $c2a6
    ld [hl], $32
    call Call_000_07bc

Jump_000_0e8f:
    add sp, $14
    ret


    ld hl, $c2a6
    ld a, [hl]
    push af
    inc sp
    ld hl, $0800
    push hl
    ld hl, $0ea9
    push hl
    call Call_000_08b6
    add sp, $05

Jump_000_0ea5:
    jp Jump_000_0ea5


    ret


    ld b, [hl]
    ld l, c
    ld l, h
    ld h, l
    jr nz, jr_000_0f22

    ld a, c
    ld [hl], e
    ld [hl], h
    ld h, l
    ld l, l
    jr nz, @+$67

    ld [hl], d
    ld [hl], d
    ld l, a
    ld [hl], d
    ld hl, $e800
    call Call_000_12f8
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
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a

Jump_000_0ee0:
    ld hl, sp+$06
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_000_0f01

    inc hl
    ld a, [hl]
    ld hl, sp+$04
    sub [hl]
    jp nz, Jump_000_0efe

    ld hl, sp+$0b
    ld a, [hl]
    ld hl, sp+$05
    sub [hl]
    jp nz, Jump_000_0efe

    jr jr_000_0f01

Jump_000_0efe:
    jp Jump_000_0fad


Jump_000_0f01:
jr_000_0f01:
    ld hl, sp+$3b
    ld a, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], $00

Call_000_0f09:
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

jr_000_0f22:
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_24c4
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
    call Call_000_24ca
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
    jp nc, Jump_000_0f98

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
    jr nz, jr_000_0f95

    inc hl
    inc [hl]

jr_000_0f95:
    jp Jump_000_0ee0


Jump_000_0f98:
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
    jr nz, jr_000_0faa

    inc hl
    inc [hl]

jr_000_0faa:
    jp Jump_000_0ee0


Jump_000_0fad:
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

Jump_000_0fca:
    ld a, c
    ld hl, sp+$00
    sub [hl]
    ld a, b
    inc hl
    sbc [hl]
    rlca
    jp nc, Jump_000_0ff2

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
    jr nz, jr_000_0fef

    inc hl
    inc [hl]

jr_000_0fef:
    jp Jump_000_0fca


Jump_000_0ff2:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    add sp, $33
    ret


Call_000_0ffd:
    add sp, -$30
    ld hl, sp+$08
    ld a, l
    ld d, h
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $43
    ld [de], a
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, $75
    ld [bc], a
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    inc bc
    ld a, $72
    ld [bc], a
    dec hl

Jump_000_1020:
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0003
    add hl, de
    ld c, l

Call_000_1028:
    ld b, h
    ld a, $72
    ld [bc], a
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld c, l
    ld b, h
    ld a, $65
    ld [bc], a
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0005
    add hl, de
    ld c, l
    ld b, h
    ld a, $6e
    ld [bc], a
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld c, l
    ld b, h
    ld a, $74
    ld [bc], a
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0007
    add hl, de
    ld c, l
    ld b, h
    ld a, $20
    ld [bc], a
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0008
    add hl, de
    ld c, l
    ld b, h
    ld a, $76
    ld [bc], a
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0009
    add hl, de
    ld c, l
    ld b, h
    ld a, $65
    ld [bc], a
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000a
    add hl, de
    ld c, l
    ld b, h
    ld a, $72
    ld [bc], a
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000b
    add hl, de
    ld c, l
    ld b, h
    ld a, $3a
    ld [bc], a
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000c
    add hl, de
    ld c, l
    ld b, h
    ld a, $20
    ld [bc], a
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000d
    add hl, de
    ld c, l
    ld b, h
    ld a, $20
    ld [bc], a
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000e
    add hl, de
    ld c, l
    ld b, h
    ld a, $00
    ld [bc], a
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
    ld hl, $c2a6
    ld [hl], $0d
    ld hl, $11be
    push hl
    call Call_000_2479
    add sp, $02
    ld a, $04
    push af
    inc sp
    call Call_000_078d
    ld a, [hl-]
    dec d
    rst RST_38
    rst RST_38
    add sp, $01
    call Call_000_12f0
    ld b, d
    ld c, e
    push bc
    ld a, $00
    push af
    inc sp
    call Call_000_078d
    ld a, [hl-]
    dec d
    rst RST_38
    rst RST_38
    add sp, $01
    pop bc
    ld hl, sp+$1c
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld a, $0a
    push af
    inc sp
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call $0ebc
    add sp, $07
    ld hl, $0300
    push hl
    call Call_000_1cab
    add sp, $02
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_2479
    add sp, $02
    ld hl, $030d
    push hl
    call Call_000_1cab
    add sp, $02
    ld hl, sp+$1c
    ld c, l
    ld b, h
    push bc
    call Call_000_2479
    add sp, $02
    ld hl, $0500
    push hl
    call Call_000_1cab
    add sp, $02
    ld hl, $11d2
    push hl
    call Call_000_2479
    add sp, $02
    ld hl, $0700
    push hl
    call Call_000_1cab
    add sp, $02
    ld hl, $11e3
    push hl
    call Call_000_2479
    add sp, $02

Jump_000_1192:
    call Call_000_0688
    call Call_000_35f7
    ld c, e
    ld b, $00
    ld a, c
    and $10
    jr nz, jr_000_11a3

    jp Jump_000_1192


jr_000_11a3:
    call Call_000_134d
    ld hl, $0b00
    push hl
    call Call_000_1cab
    add sp, $02
    ld hl, $11f7
    push hl
    call Call_000_2479
    add sp, $02

Jump_000_11b8:
    jp Jump_000_11b8


    add sp, $30
    ret


    jr nz, jr_000_1205

    ld e, d
    dec l
    ld b, [hl]
    ld c, h
    ld b, c
    ld d, e
    ld c, b
    jr nz, jr_000_120f

    ld d, a
    jr nz, jr_000_1221

    ld d, b
    ld b, h
    ld b, c
    ld d, h
    ld b, l
    nop
    ld d, l
    ld [hl], b
    ld h, h
    ld h, c
    ld [hl], h
    ld h, l
    jr nz, jr_000_124e

    ld l, a
    jr nz, @+$78

    ld h, l
    ld [hl], d
    ld a, [hl-]
    inc [hl]
    jr nz, jr_000_11e3

jr_000_11e3:
    ld d, b
    ld [hl], d
    ld h, l
    ld [hl], e
    ld [hl], e
    jr nz, jr_000_1245

    ld b, c
    ld e, l
    jr nz, @+$76

    ld l, a
    jr nz, @+$77

    ld [hl], b
    ld h, h
    ld h, c
    ld [hl], h
    ld h, l
    nop
    ld d, l
    ld [hl], b
    ld h, h
    ld h, c
    ld [hl], h
    ld h, l
    jr nz, @+$68

    ld l, c
    ld l, [hl]
    ld l, c
    ld [hl], e
    ld l, b
    inc l

jr_000_1205:
    ld [hl], b
    ld l, a
    ld [hl], a
    ld h, l
    ld [hl], d
    jr nz, @+$71

    ld h, [hl]
    ld h, [hl]
    nop

Call_000_120f:
jr_000_120f:
    push af
    push af
    ld hl, sp+$08
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$06
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$02

jr_000_1221:
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$0a
    ld c, [hl]

Jump_000_1226:
    ld b, c
    dec c
    xor a
    or b
    jp z, Jump_000_1248

    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    dec hl
    inc [hl]
    jr nz, jr_000_1239

    inc hl
    inc [hl]

jr_000_1239:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_000_1245

    inc hl
    inc [hl]

jr_000_1245:
    jp Jump_000_1226


Jump_000_1248:
    add sp, $04
    ret


    ld bc, $a000

jr_000_124e:
    ld a, [bc]
    ld c, a
    ld e, c
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
    ld bc, $7fd2
    ld a, $01
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ret


Call_000_1271:
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7fd2
    ld a, $00
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ret


Call_000_1290:
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7f36
    ld hl, sp+$02
    ld a, [hl]
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ret


Call_000_12b0:
    ld a, $02
    push af
    inc sp
    call Call_000_078d
    ld a, [hl-]
    dec d
    rst RST_38
    rst RST_38
    add sp, $01
    ld a, $01
    push af
    inc sp
    call Call_000_1290
    add sp, $01
    ld hl, $0110
    push hl
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $a000
    push hl
    call Call_000_35a0
    add sp, $06
    ld a, $00
    push af
    inc sp
    call Call_000_1290
    add sp, $01
    ld a, $00
    push af
    inc sp
    call Call_000_078d
    ld a, [hl-]
    dec d
    rst RST_38
    rst RST_38
    add sp, $01
    ret


Call_000_12f0:
    ld bc, $124b
    ld a, $ff
    push af
    inc sp
    push bc

Call_000_12f8:
    ld hl, $d000
    push hl
    call Call_000_120f
    add sp, $05
    call $d000
    ret


Call_000_1305:
    push af
    push af
    ld hl, sp+$06
    ld c, [hl]
    inc hl
    ld b, [hl]

Jump_000_130c:
    ld a, [bc]
    or a
    jp z, Jump_000_1315

    inc bc
    jp Jump_000_130c


Jump_000_1315:
    ld hl, sp+$08
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    inc hl
    ld [hl], c
    inc hl
    ld [hl], b

Jump_000_1321:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    or a
    jp z, Jump_000_1342

    ld a, c
    dec hl
    inc [hl]
    jr nz, jr_000_1333

    inc hl
    inc [hl]

jr_000_1333:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_000_133f

    inc hl
    inc [hl]

jr_000_133f:
    jp Jump_000_1321


Jump_000_1342:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    add sp, $04
    ret


Call_000_134d:
    add sp, -$23
    call Call_000_1271
    xor a
    ld hl, sp+$1f
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    xor a
    ld hl, sp+$04
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

Jump_000_1360:
    ld hl, sp+$1f
    ld a, [hl]
    sub $0c
    inc hl
    ld a, [hl]
    sbc $48
    inc hl
    ld a, [hl]
    sbc $02
    inc hl
    ld a, [hl]
    sbc $00
    rlca
    jp nc, Jump_000_14f9

    ld hl, sp+$08
    ld c, l
    ld b, h
    push bc
    ld hl, $0002
    push hl
    ld hl, $480c
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
    call Call_000_24c7
    add sp, $08
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
    inc [hl]
    jr nz, jr_000_13ae

    inc hl
    inc [hl]
    jr nz, jr_000_13ae

    inc hl
    inc [hl]
    jr nz, jr_000_13ae

    inc hl
    inc [hl]

jr_000_13ae:
    ld a, $0a
    push af
    inc sp
    push bc
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call $0ebc
    add sp, $07
    ld hl, sp+$08
    ld c, l
    ld b, h
    ld hl, $14fc
    push hl
    push bc
    call Call_000_1305
    add sp, $04
    ld hl, $0900
    push hl
    call Call_000_1cab
    add sp, $02
    ld hl, sp+$08
    ld c, l
    ld b, h
    push bc
    call Call_000_2479
    add sp, $02
    ld hl, sp+$1f
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld a, d
    add $00
    push af
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$23
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    adc $04
    ld e, a
    ld a, d
    adc $00
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    ld de, $c0a0
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
    ld a, $0e
    push af
    inc sp
    ld hl, sp+$22
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$22
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_1cf5
    add sp, $05

Jump_000_142c:
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
    ld c, [hl]
    ld a, c
    add $02
    ld hl, sp+$1e
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$00
    ld [hl], a
    ld hl, sp+$20
    ld a, [hl]
    and $3f
    ld hl, sp+$01
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$00
    ld a, [hl]
    ld hl, sp+$1c
    ld [hl], a
    ld hl, sp+$01
    ld a, [hl]
    ld hl, sp+$1d
    ld [hl], a
    ld bc, $2000
    inc hl
    ld a, [hl]
    ld [bc], a
    dec hl
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $4000
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$1c
    ld [hl+], a
    ld [hl], d
    dec hl
    ld a, [hl]
    ld hl, sp+$00
    ld [hl], a
    ld hl, sp+$1d
    ld a, [hl]
    ld hl, sp+$01
    ld [hl], a
    ld bc, $c0a4
    ld hl, $0110
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc

Jump_000_148b:
    call Call_000_35a0
    add sp, $06
    ld hl, $c0a0
    push hl
    call Call_000_12b0
    add sp, $02
    ld a, $05
    push af
    inc sp
    call Call_000_078d
    ld a, [hl-]
    dec d
    rst RST_38
    rst RST_38
    add sp, $01
    call Call_000_06fd
    call Call_000_078d
    adc d
    ld b, b
    ld bc, $cd00
    ld b, $07
    ld a, $00
    push af
    inc sp
    call Call_000_078d
    ld a, [hl-]
    dec d
    rst RST_38
    rst RST_38
    add sp, $01
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld a, d
    add $64
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
    adc $00
    ld e, a
    ld a, d
    adc $00
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$1f
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld a, d
    add $01
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
    adc $00
    ld e, a
    ld a, d
    adc $00
    ld [hl-], a
    ld [hl], e
    jp Jump_000_1360


Jump_000_14f9:
    add sp, $23
    ret


    dec h
    nop
    push af
    push af
    ld hl, sp+$08
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$06
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$0a
    ld c, [hl]

Jump_000_1515:
    ld b, c
    dec c
    xor a
    or b
    jp z, Jump_000_1537

    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    dec hl
    inc [hl]
    jr nz, jr_000_1528

    inc hl
    inc [hl]

jr_000_1528:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_000_1534

    inc hl
    inc [hl]

jr_000_1534:
    jp Jump_000_1515


Jump_000_1537:
    add sp, $04
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
    ld bc, $7fc0
    ld hl, sp+$06
    ld a, [hl]
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ret


    add sp, -$0b
    ld hl, sp+$11
    ld e, [hl]
    ld d, $00
    ld l, e
    ld h, d
    add hl, hl
    add hl, de
    add hl, hl
    add hl, hl
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$12
    ld a, [hl]
    add $07
    ld hl, sp+$00
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    add $06
    ld hl, sp+$01
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    add $05
    ld hl, sp+$07
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    add $04
    ld hl, sp+$06
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    add $03
    ld hl, sp+$05
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    add $02
    ld hl, sp+$04
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    inc a
    ld hl, sp+$03
    ld [hl], a
    ld hl, sp+$13
    ld a, [hl]
    ld hl, sp+$02
    ld [hl], a
    ld hl, sp+$0a
    ld [hl], $00

Jump_000_15ae:
    ld hl, sp+$0a
    ld a, [hl]
    sub $0c
    jp nc, Jump_000_1695

    ld c, [hl]
    ld b, $00
    dec hl
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, $1698
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    and $01
    jr nz, jr_000_15d0

    jp Jump_000_15e1


jr_000_15d0:
    push bc
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    dec hl
    dec hl
    ld a, [hl]
    push af
    inc sp
    call Call_000_2449
    add sp, $02
    pop bc

Jump_000_15e1:
    ld a, c
    and $02
    jr nz, jr_000_15e9

    jp Jump_000_15f9


jr_000_15e9:
    push bc
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    dec hl
    ld a, [hl]
    push af
    inc sp
    call Call_000_2449
    add sp, $02
    pop bc

Jump_000_15f9:
    ld a, c
    and $04
    jr nz, jr_000_1601

    jp Jump_000_1612


jr_000_1601:
    push bc
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, sp+$0a
    ld a, [hl]
    push af
    inc sp
    call Call_000_2449
    add sp, $02
    pop bc

Jump_000_1612:
    ld a, c
    and $08
    jr nz, jr_000_161a

    jp Jump_000_162b


jr_000_161a:
    push bc
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, sp+$09
    ld a, [hl]
    push af
    inc sp
    call Call_000_2449
    add sp, $02
    pop bc

Jump_000_162b:
    ld a, c
    and $10
    jr nz, jr_000_1633

    jp Jump_000_1644


jr_000_1633:
    push bc
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, sp+$08
    ld a, [hl]
    push af
    inc sp
    call Call_000_2449
    add sp, $02
    pop bc

Jump_000_1644:
    ld a, c
    and $20
    jr nz, jr_000_164c

    jp Jump_000_165d


jr_000_164c:
    push bc
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    inc hl
    inc hl
    ld a, [hl]
    push af
    inc sp
    call Call_000_2449
    add sp, $02
    pop bc

Jump_000_165d:
    ld a, c
    and $40
    jr nz, jr_000_1665

    jp Jump_000_1675


jr_000_1665:
    push bc
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    inc hl
    ld a, [hl]
    push af
    inc sp
    call Call_000_2449
    add sp, $02
    pop bc

Jump_000_1675:
    ld a, c
    and $80
    jr nz, jr_000_167d

    jp Jump_000_168c


jr_000_167d:
    ld hl, sp+$02
    ld a, [hl]
    push af
    inc sp
    ld hl, sp+$13
    ld a, [hl]
    push af
    inc sp
    call Call_000_2449
    add sp, $02

Jump_000_168c:
    ld hl, sp+$02
    inc [hl]
    ld hl, sp+$0a
    inc [hl]
    jp Jump_000_15ae


Jump_000_1695:
    add sp, $0b
    ret


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
    nop
    nop

Jump_000_1802:
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
    nop
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_000_1848

    jr nz, @+$22

    jr nz, jr_000_184c

    nop
    jr nz, jr_000_182f

jr_000_182f:
    nop
    nop
    jr z, @+$52

    ld d, b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_000_183d:
    nop
    jr z, jr_000_1868

    db $fc
    jr z, jr_000_1893

    db $fc
    ld d, b
    ld d, b
    nop
    nop

jr_000_1848:
    nop
    jr nz, jr_000_18c3

    xor b

jr_000_184c:
    and b
    ld h, b
    jr nc, jr_000_1878

    xor b
    ldh a, [rNR41]
    nop
    nop
    nop
    ld c, b
    xor b
    or b
    ld d, b
    jr z, jr_000_1890

    ld d, h
    ld c, b
    nop
    nop
    nop
    nop
    jr nz, jr_000_18b4

    ld d, b
    ld a, b
    xor b
    xor b

jr_000_1868:
    sub b
    ld l, h
    nop
    nop
    nop
    ld b, b
    ld b, b
    add b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_000_1878:
    nop
    inc b
    ld [$1010], sp
    db $10
    db $10
    db $10
    db $10
    ld [$0004], sp
    nop
    ld b, b
    jr nz, jr_000_1898

    db $10
    db $10
    db $10
    db $10
    db $10
    jr nz, @+$42

    nop

jr_000_1890:
    nop
    nop
    nop

jr_000_1893:
    jr nz, jr_000_183d

    ld [hl], b
    ld [hl], b
    xor b

jr_000_1898:
    jr nz, jr_000_189a

jr_000_189a:
    nop
    nop
    nop
    nop
    jr nz, jr_000_18c0

    jr nz, jr_000_189a

    jr nz, jr_000_18c4

    jr nz, jr_000_18a6

jr_000_18a6:
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
    nop
    ld b, b
    ld b, b
    add b

jr_000_18b4:
    nop
    nop
    nop
    nop
    nop
    ld hl, sp+$00
    nop
    nop
    nop
    nop
    nop

jr_000_18c0:
    nop
    nop
    nop

jr_000_18c3:
    nop

jr_000_18c4:
    nop
    nop
    nop
    nop
    nop
    ld b, b
    nop
    nop
    nop
    ld [$1010], sp
    db $10
    jr nz, jr_000_18f3

    ld b, b
    ld b, b
    ld b, b
    add b
    nop
    nop
    nop
    ld [hl], b
    adc b
    adc b
    adc b
    adc b
    adc b
    adc b
    ld [hl], b
    nop
    nop
    nop
    nop
    jr nz, jr_000_1948

    jr nz, jr_000_190a

    jr nz, @+$22

    jr nz, jr_000_195e

    nop
    nop
    nop
    nop
    ld [hl], b

jr_000_18f3:
    adc b
    adc b
    db $10
    jr nz, jr_000_1938

    add b
    ld hl, sp+$00
    nop
    nop
    nop
    ld [hl], b
    adc b
    ld [$0830], sp
    ld [$7088], sp
    nop
    nop
    nop
    nop

jr_000_190a:
    db $10
    jr nc, jr_000_195d

    ld d, b
    sub b
    ld a, b
    db $10
    jr jr_000_1913

jr_000_1913:
    nop
    nop
    nop
    ld hl, sp-$80
    add b
    ldh a, [$ff08]
    ld [$7088], sp
    nop
    nop
    nop
    nop
    ld [hl], b
    sub b
    add b
    ldh a, [$ff88]
    adc b
    adc b
    ld [hl], b
    nop
    nop
    nop
    nop
    ld hl, sp-$70
    db $10
    jr nz, jr_000_1953

    jr nz, @+$22

    jr nz, jr_000_1937

jr_000_1937:
    nop

jr_000_1938:
    nop
    nop
    ld [hl], b
    adc b
    adc b
    ld [hl], b
    adc b
    adc b
    adc b
    ld [hl], b
    nop
    nop
    nop
    nop
    ld [hl], b
    adc b

jr_000_1948:
    adc b
    adc b
    ld a, b
    ld [$7048], sp
    nop
    nop
    nop
    nop
    nop

jr_000_1953:
    nop
    jr nz, jr_000_1956

jr_000_1956:
    nop
    nop
    nop
    jr nz, jr_000_195b

jr_000_195b:
    nop
    nop

jr_000_195d:
    nop

jr_000_195e:
    nop
    nop
    nop
    jr nz, jr_000_1963

jr_000_1963:
    nop
    nop
    jr nz, jr_000_1987

    nop
    nop
    inc b
    ld [$2010], sp
    ld b, b
    jr nz, jr_000_1980

    ld [$0004], sp
    nop
    nop
    nop
    nop
    nop
    ld hl, sp+$00
    nop
    ld hl, sp+$00
    nop
    nop
    nop

jr_000_1980:
    nop
    ld b, b
    jr nz, jr_000_1994

    ld [$0804], sp

jr_000_1987:
    db $10
    jr nz, jr_000_19ca

    nop
    nop
    nop
    nop
    ld [hl], b
    adc b
    adc b
    db $10
    jr nz, jr_000_19b4

jr_000_1994:
    nop
    jr nz, jr_000_1997

jr_000_1997:
    nop
    nop
    nop
    ld [hl], b
    adc b
    sbc b
    xor b
    xor b
    cp b
    add b
    ld a, b
    nop
    nop
    nop
    nop
    jr nz, jr_000_19c8

    jr nc, jr_000_19fa

    ld d, b
    ld a, b
    ld c, b
    call z, RST_00
    nop
    nop
    ldh a, [rOBP0]

jr_000_19b4:
    ld c, b
    ld [hl], b
    ld c, b
    ld c, b
    ld c, b
    ldh a, [rP1]
    nop
    nop
    nop
    ld a, b
    adc b
    add b
    add b
    add b
    add b
    adc b
    ld [hl], b
    nop
    nop

jr_000_19c8:
    nop
    nop

jr_000_19ca:
    ldh a, [rOBP0]
    ld c, b
    ld c, b
    ld c, b
    ld c, b
    ld c, b
    ldh a, [rP1]
    nop
    nop
    nop
    ld hl, sp+$48
    ld d, b
    ld [hl], b
    ld d, b
    ld b, b
    ld c, b
    ld hl, sp+$00
    nop
    nop
    nop
    ld hl, sp+$48
    ld d, b
    ld [hl], b
    ld d, b
    ld b, b
    ld b, b
    ldh [rP1], a
    nop
    nop
    nop
    jr c, jr_000_1a38

    add b
    add b
    sbc h
    adc b
    ld c, b
    jr nc, jr_000_19f7

jr_000_19f7:
    nop
    nop
    nop

jr_000_19fa:
    call z, $4848
    ld a, b
    ld c, b
    ld c, b
    ld c, b
    call z, RST_00
    nop
    nop

jr_000_1a06:
    ld hl, sp+$20
    jr nz, jr_000_1a2a

    jr nz, jr_000_1a2c

    jr nz, jr_000_1a06

    nop
    nop
    nop
    nop
    ld a, h
    db $10
    db $10
    db $10
    db $10
    db $10
    db $10
    sub b
    ldh [rP1], a
    nop
    nop
    db $ec
    ld c, b
    ld d, b
    ld h, b
    ld d, b
    ld d, b
    ld c, b
    db $ec
    nop
    nop
    nop
    nop

jr_000_1a2a:
    ldh [rLCDC], a

jr_000_1a2c:
    ld b, b
    ld b, b
    ld b, b
    ld b, b
    ld b, h
    db $fc
    nop
    nop
    nop
    nop
    ret c

    ret c

jr_000_1a38:
    ret c

    ret c

    xor b
    xor b
    xor b
    xor b
    nop
    nop
    nop
    nop
    call c, $6848
    ld l, b
    ld e, b
    ld e, b
    ld c, b
    add sp, $00
    nop
    nop
    nop
    ld [hl], b
    adc b
    adc b
    adc b
    adc b
    adc b
    adc b
    ld [hl], b
    nop
    nop
    nop
    nop
    ldh a, [rOBP0]
    ld c, b
    ld [hl], b
    ld b, b
    ld b, b
    ld b, b
    ldh [rP1], a
    nop
    nop
    nop
    ld [hl], b
    adc b
    adc b
    adc b
    adc b
    add sp, -$68
    ld [hl], b
    jr jr_000_1a70

jr_000_1a70:
    nop
    nop
    ldh a, [rOBP0]
    ld c, b
    ld [hl], b
    ld d, b
    ld c, b
    ld c, b
    db $ec
    nop
    nop
    nop
    nop
    ld a, b
    adc b
    add b
    ld h, b
    db $10
    ld [$f088], sp
    nop
    nop
    nop
    nop
    ld hl, sp-$58
    jr nz, jr_000_1aae

    jr nz, jr_000_1ab0

    jr nz, @+$72

    nop
    nop
    nop
    nop
    call z, $4848
    ld c, b
    ld c, b
    ld c, b
    ld c, b
    jr nc, jr_000_1a9f

jr_000_1a9f:
    nop
    nop
    nop
    call z, $4848
    ld d, b
    ld d, b
    jr nc, jr_000_1ac9

    jr nz, jr_000_1aab

jr_000_1aab:
    nop
    nop
    nop

jr_000_1aae:
    xor b
    xor b

jr_000_1ab0:
    xor b
    ld [hl], b
    ld d, b
    ld d, b
    ld d, b
    ld d, b
    nop
    nop
    nop
    nop
    ret c

    ld d, b
    ld d, b
    jr nz, jr_000_1adf

    ld d, b
    ld d, b
    ret c

    nop
    nop
    nop
    nop
    ret c

    ld d, b
    ld d, b

jr_000_1ac9:
    jr nz, jr_000_1aeb

    jr nz, @+$22

    ld [hl], b
    nop
    nop
    nop
    nop
    ld hl, sp-$70
    db $10
    jr nz, jr_000_1af7

    ld b, b
    ld c, b
    ld hl, sp+$00
    nop
    nop
    jr c, jr_000_1aff

jr_000_1adf:
    jr nz, jr_000_1b01

    jr nz, jr_000_1b03

    jr nz, jr_000_1b05

    jr nz, jr_000_1b1f

    nop
    nop
    ld b, b
    ld b, b

jr_000_1aeb:
    ld b, b
    jr nz, jr_000_1b0e

    db $10
    db $10
    db $10
    ld [$0000], sp
    nop
    ld [hl], b
    db $10

jr_000_1af7:
    db $10
    db $10
    db $10
    db $10
    db $10
    db $10
    db $10
    ld [hl], b

jr_000_1aff:
    nop

Jump_000_1b00:
    nop

jr_000_1b01:
    jr nz, jr_000_1b53

jr_000_1b03:
    nop
    nop

jr_000_1b05:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_000_1b0e:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    db $fc
    nop
    jr nz, jr_000_1b1b

jr_000_1b1b:
    nop
    nop
    nop
    nop

jr_000_1b1f:
    nop

Jump_000_1b20:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr nc, jr_000_1b73

    jr c, jr_000_1b75

    inc a
    nop
    nop
    nop
    nop
    ret nz

    ld b, b
    ld b, b
    ld [hl], b
    ld c, b
    ld c, b
    ld c, b
    ld [hl], b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr c, @+$4a

    ld b, b
    ld b, b
    jr c, jr_000_1b47

jr_000_1b47:
    nop
    nop
    nop
    jr jr_000_1b54

    ld [$4838], sp
    ld c, b
    ld c, b
    inc a
    nop

jr_000_1b53:
    nop

jr_000_1b54:
    nop
    nop
    nop
    nop
    nop
    jr nc, jr_000_1ba3

    ld a, b
    ld b, b
    jr c, jr_000_1b5f

jr_000_1b5f:
    nop
    nop
    nop
    inc e
    jr nz, jr_000_1b85

    ld a, b
    jr nz, jr_000_1b88

    jr nz, jr_000_1be2

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    inc a
    ld c, b

jr_000_1b73:
    jr nc, jr_000_1bb5

jr_000_1b75:
    ld a, b
    ld b, h
    jr c, jr_000_1b79

jr_000_1b79:
    nop
    ret nz

    ld b, b
    ld b, b
    ld [hl], b
    ld c, b
    ld c, b
    ld c, b
    db $ec
    nop
    nop
    nop

jr_000_1b85:
    nop
    jr nz, jr_000_1b88

jr_000_1b88:
    nop
    ld h, b
    jr nz, jr_000_1bac

    jr nz, jr_000_1bfe

    nop
    nop
    nop
    nop
    stop
    nop
    jr nc, jr_000_1ba7

    db $10
    db $10
    db $10
    db $10
    ldh [rP1], a
    nop
    ret nz

    ld b, b
    ld b, b
    ld e, h
    ld d, b

jr_000_1ba3:
    ld [hl], b
    ld c, b
    db $ec
    nop

jr_000_1ba7:
    nop
    nop
    nop

jr_000_1baa:
    ldh [rNR41], a

jr_000_1bac:
    jr nz, jr_000_1bce

    jr nz, jr_000_1bd0

    jr nz, jr_000_1baa

    nop
    nop
    nop

jr_000_1bb5:
    nop
    nop
    nop
    nop
    ldh a, [$ffa8]
    xor b
    xor b
    xor b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ldh a, [rOBP0]
    ld c, b
    ld c, b
    db $ec
    nop
    nop
    nop
    nop

jr_000_1bce:
    nop
    nop

jr_000_1bd0:
    nop
    jr nc, jr_000_1c1b

    ld c, b
    ld c, b
    jr nc, jr_000_1bd7

jr_000_1bd7:
    nop
    nop
    nop
    nop
    nop
    nop
    ldh a, [rOBP0]
    ld c, b
    ld c, b
    ld [hl], b

jr_000_1be2:
    ld b, b
    ldh [rP1], a
    nop
    nop
    nop
    nop
    jr c, jr_000_1c33

    ld c, b
    ld c, b
    jr c, jr_000_1bf7

    inc e
    nop
    nop
    nop
    nop
    nop
    ret c

    ld h, b

jr_000_1bf7:
    ld b, b
    ld b, b
    ldh [rP1], a
    nop
    nop
    nop

jr_000_1bfe:
    nop
    nop
    nop
    ld a, b
    ld b, b
    jr nc, jr_000_1c0d

    ld a, b
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_000_1c2d

jr_000_1c0d:
    ld [hl], b
    jr nz, jr_000_1c30

jr_000_1c10:
    jr nz, jr_000_1c2a

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ret c

    ld c, b

jr_000_1c1b:
    ld c, b
    ld c, b
    inc a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    db $ec
    ld c, b
    ld d, b
    jr nc, jr_000_1c4a

jr_000_1c2a:
    nop
    nop
    nop

jr_000_1c2d:
    nop
    nop
    nop

jr_000_1c30:
    nop
    xor b
    xor b

jr_000_1c33:
    ld [hl], b
    ld d, b
    ld d, b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ret c

    ld d, b
    jr nz, jr_000_1c91

    ret c

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    db $ec

jr_000_1c4a:
    ld c, b
    ld d, b
    jr nc, jr_000_1c6e

    jr nz, jr_000_1c10

    nop
    nop
    nop
    nop
    nop
    ld a, b
    db $10
    jr nz, @+$22

    ld a, b
    nop
    nop
    nop
    jr jr_000_1c6f

    db $10
    db $10
    jr nz, jr_000_1c73

    db $10
    db $10
    db $10
    jr jr_000_1c68

jr_000_1c68:
    db $10
    db $10
    db $10
    db $10
    db $10
    db $10

jr_000_1c6e:
    db $10

jr_000_1c6f:
    db $10
    db $10
    db $10
    db $10

jr_000_1c73:
    stop
    ld h, b
    jr nz, jr_000_1c98

    jr nz, jr_000_1c8a

    jr nz, jr_000_1c9c

    jr nz, @+$22

    ld h, b
    nop
    ld b, b
    and h
    jr jr_000_1c84

jr_000_1c84:
    nop
    nop
    nop
    nop
    nop
    nop

jr_000_1c8a:
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_000_1c91:
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_000_1c98:
    nop

Call_000_1c99:
    push bc
    ld hl, sp+$04

jr_000_1c9c:
    ld a, [hl]
    call Call_000_2af2
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld a, [hl]
    call Call_000_2b1b
    pop bc
    ret


Call_000_1cab:
    ld hl, sp+$02
    ld a, [hl+]
    ld [$c321], a
    ld a, [hl]
    ld [$c322], a
    ret


    ld a, [$c2b2]
    and $02
    jr nz, jr_000_1cc2

    push bc
    call Call_000_2c4f

Jump_000_1cc1:
    pop bc

jr_000_1cc2:
    ld a, [$c321]
    ld e, a
    ret


    ld a, [$c2b2]
    and $02
    jr nz, jr_000_1cd3

    push bc
    call Call_000_2c4f
    pop bc

jr_000_1cd3:
    ld a, [$c322]
    ld e, a
    ret


Jump_000_1cd8:
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

Jump_000_1ce7:
    or a
    ret z

    rr h
    rr l
    rr d
    rr e
    dec a
    jp Jump_000_1ce7


Call_000_1cf5:
Jump_000_1cf5:
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

Jump_000_1d04:
    or a
    ret z

    sra h
    rr l
    rr d
    rr e
    dec a
    jp Jump_000_1d04


Jump_000_1d12:
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

Jump_000_1d21:
    or a
    ret z

    rl e
    rl d
    rl l
    rl h
    dec a
    jp Jump_000_1d21


    ldh a, [rLCDC]
    or $10
    ldh [rLCDC], a
    ld a, $48
    ldh [rLYC], a
    ret


jr_000_1d3a:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_1d3a

    ldh a, [rLCDC]
    and $ef
    ldh [rLCDC], a
    ret


Call_000_1d47:
    push hl
    ld hl, $c334
    ld a, $13
    cp [hl]
    jr z, jr_000_1d53

    inc [hl]
    jr jr_000_1d62

jr_000_1d53:
    ld [hl], $00
    ld hl, $c335
    ld a, $11
    cp [hl]
    jr z, jr_000_1d60

    inc [hl]
    jr jr_000_1d62

jr_000_1d60:
    ld [hl], $00

jr_000_1d62:
    pop hl
    ret


Call_000_1d64:
    ld a, b
    ld [$c327], a
    ld a, c
    ld [$c329], a
    xor a
    ld [$c328], a
    ld a, d
    ld [$c32a], a
    cpl
    ld l, a
    ld h, $ff
    inc hl
    ld bc, $0000
    add hl, bc
    ld a, l
    ld [$c32f], a
    ld a, h
    ld [$c32e], a

Jump_000_1d85:
jr_000_1d85:
    ld a, [$c328]
    ld b, a
    ld a, [$c32a]
    sub b
    ret c

    ld a, [$c326]
    or a
    call z, Call_000_1e9b
    ld a, [$c32e]
    bit 7, a
    jr z, jr_000_1dc9

    ld a, [$c326]
    or a
    call nz, Call_000_1e07
    ld a, [$c328]
    inc a
    ld [$c328], a
    ld a, [$c32e]
    ld b, a
    ld a, [$c32f]
    ld c, a
    ld h, $00
    ld a, [$c328]
    ld l, a
    add hl, hl
    add hl, hl
    add hl, bc
    ld bc, $0006
    add hl, bc
    ld a, h
    ld [$c32e], a
    ld a, l
    ld [$c32f], a
    jr jr_000_1d85

jr_000_1dc9:
    ld a, [$c326]
    or a
    call nz, Call_000_1e3f
    ld a, [$c328]
    inc a
    ld [$c328], a
    ld b, $00
    ld a, [$c328]
    ld c, a
    ld h, $ff
    ld a, [$c32a]
    cpl
    ld l, a
    inc hl
    add hl, bc
    ld a, [$c32e]
    ld b, a
    ld a, [$c32f]
    ld c, a
    add hl, hl
    add hl, hl
    add hl, bc
    ld bc, $000a
    add hl, bc
    ld a, h
    ld [$c32e], a
    ld a, l
    ld [$c32f], a
    ld a, [$c32a]
    dec a
    ld [$c32a], a
    jp Jump_000_1d85


Call_000_1e07:
    ld a, [$c327]
    ld b, a
    ld a, [$c329]
    ld c, a
    ld a, [$c328]
    ld d, a
    ld a, [$c32a]
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
    call Call_000_1fef
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
    call Call_000_1fef
    pop de
    pop bc
    ret


Call_000_1e3f:
    ld a, [$c327]
    ld b, a
    ld a, [$c329]
    ld c, a
    ld a, [$c328]
    ld d, a
    ld a, [$c32a]
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
    call Call_000_1fef
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
    call Call_000_1fef
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
    call Call_000_1fef
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
    call Call_000_1fef
    pop de
    pop bc
    ret


Call_000_1e9b:
    ld a, [$c327]
    ld b, a
    ld a, [$c329]
    ld c, a
    ld a, [$c328]
    ld d, a
    ld a, [$c32a]
    ld e, a
    push bc
    push de
    ld a, b
    add d
    ld b, a
    ld a, c
    sub e
    ld c, a
    call Call_000_2280
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
    call Call_000_2280
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
    call Call_000_2280
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
    call Call_000_2280
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
    call Call_000_2280
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
    call Call_000_2280
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
    call Call_000_2280
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
    call Call_000_2280
    pop de
    pop bc
    ret


Call_000_1f19:
    ld a, [$c327]
    ld b, a
    ld a, [$c328]
    ld c, a
    sub b
    jr nc, jr_000_1f2c

    ld a, c
    ld [$c327], a
    ld a, b
    ld [$c328], a

jr_000_1f2c:
    ld a, [$c329]
    ld b, a
    ld a, [$c32a]
    ld c, a
    sub b
    jr nc, jr_000_1f3f

    ld a, c
    ld [$c329], a
    ld a, b
    ld [$c32a], a

jr_000_1f3f:
    ld a, [$c327]
    ld b, a
    ld d, a
    ld a, [$c329]
    ld c, a
    ld a, [$c32a]
    ld e, a
    call Call_000_1fef
    ld a, [$c328]
    ld b, a
    ld d, a
    ld a, [$c329]
    ld c, a
    ld a, [$c32a]
    ld e, a
    call Call_000_1fef
    ld a, [$c327]
    inc a
    ld [$c327], a
    ld a, [$c328]
    dec a
    ld [$c328], a
    ld a, [$c327]
    ld b, a
    ld a, [$c328]
    ld d, a
    ld a, [$c329]
    ld c, a
    ld e, a
    call Call_000_1fef
    ld a, [$c327]
    ld b, a
    ld a, [$c328]
    ld d, a
    ld a, [$c32a]
    ld c, a
    ld e, a
    call Call_000_1fef
    ld a, [$c326]
    or a
    ret z

    ld a, [$c327]
    ld b, a
    ld a, [$c328]
    sub b
    ret c

    ld a, [$c329]
    inc a
    ld [$c329], a
    ld a, [$c32a]
    dec a
    ld [$c32a], a
    ld a, [$c329]
    ld b, a
    ld a, [$c32a]
    sub b
    ret c

    ld a, [$c323]
    ld c, a
    ld a, [$c324]
    ld [$c323], a
    ld a, c
    ld [$c324], a

jr_000_1fc0:
    ld a, [$c327]
    ld b, a
    ld a, [$c328]
    ld d, a
    ld a, [$c329]
    ld c, a
    ld e, a
    call Call_000_1fef
    ld a, [$c32a]
    ld b, a
    ld a, [$c329]
    cp b
    jr z, jr_000_1fe0

    inc a
    ld [$c329], a
    jr jr_000_1fc0

jr_000_1fe0:
    ld a, [$c323]
    ld c, a
    ld a, [$c324]
    ld [$c323], a
    ld a, c
    ld [$c324], a
    ret


Call_000_1fef:
    ld a, c
    sub e
    jr nc, jr_000_1ff5

    cpl
    inc a

jr_000_1ff5:
    ld [$c32c], a
    ld h, a
    ld a, b
    sub d
    jr nc, jr_000_1fff

    cpl
    inc a

jr_000_1fff:
    ld [$c32b], a
    sub h
    jp c, Jump_000_216c

    ld a, b
    sub d
    jp nc, Jump_000_2017

    ld a, c
    sub e
    jr z, jr_000_2023

    ld a, $00
    jr nc, jr_000_2023

    ld a, $ff
    jr jr_000_2023

Jump_000_2017:
    ld a, e
    sub c
    jr z, jr_000_2021

    ld a, $00
    jr nc, jr_000_2021

    ld a, $ff

jr_000_2021:
    ld b, d
    ld c, e

jr_000_2023:
    ld [$c32d], a
    ld hl, $36d7
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
    ld a, [$c32c]
    or a
    jp z, Jump_000_2110

    push hl
    ld h, $00
    ld l, a
    add hl, hl
    ld a, h
    ld [$c330], a
    ld a, l
    ld [$c331], a
    ld d, h
    ld e, l
    ld a, [$c32b]
    cpl
    ld l, a
    ld h, $ff
    inc hl
    add hl, de
    ld a, h
    ld [$c32e], a
    ld a, l
    ld [$c32f], a
    ld a, [$c32b]
    cpl
    ld l, a
    ld h, $ff
    inc hl
    ld a, [$c32c]
    ld d, $00
    ld e, a
    add hl, de
    add hl, hl
    ld a, h
    ld [$c332], a
    ld a, l
    ld [$c333], a
    pop hl
    ld a, [$c32b]
    ld e, a
    ld a, b
    and $07
    add $10
    ld c, a
    ld b, $00
    ld a, [bc]
    ld b, a
    ld c, a

Jump_000_2086:
    rrc c
    ld a, [$c32e]
    bit 7, a
    jr z, jr_000_20b7

    push de
    bit 7, c
    jr z, jr_000_209e

    ld a, b
    cpl
    ld c, a
    call Call_000_229d
    dec hl
    ld c, $80
    ld b, c

jr_000_209e:
    ld a, [$c32f]
    ld d, a
    ld a, [$c331]
    add d
    ld [$c32f], a
    ld a, [$c32e]
    ld d, a
    ld a, [$c330]
    adc d
    ld [$c32e], a
    pop de
    jr jr_000_20f8

jr_000_20b7:
    push de
    push bc
    ld a, b
    cpl
    ld c, a
    call Call_000_229d
    ld a, [$c32d]
    or a
    jr z, jr_000_20d1

    inc hl
    ld a, l
    and $0f
    jr nz, jr_000_20df

    ld de, $0130
    add hl, de
    jr jr_000_20df

jr_000_20d1:
    dec hl
    dec hl
    dec hl
    ld a, l
    and $0f
    xor $0e
    jr nz, jr_000_20df

    ld de, $fed0
    add hl, de

jr_000_20df:
    ld a, [$c32f]
    ld d, a
    ld a, [$c333]
    add d
    ld [$c32f], a
    ld a, [$c32e]
    ld d, a
    ld a, [$c332]
    adc d
    ld [$c32e], a
    pop bc
    ld b, c
    pop de

jr_000_20f8:
    bit 7, c
    jr z, jr_000_2103

    push de
    ld de, $0010
    add hl, de
    pop de
    ld b, c

jr_000_2103:
    ld a, b
    or c
    ld b, a
    dec e
    jp nz, Jump_000_2086

    ld a, b
    cpl
    ld c, a
    jp Jump_000_229d


Jump_000_2110:
    ld a, [$c32b]
    ld e, a
    inc e
    ld a, b
    and $07
    jr z, jr_000_212e

    push hl
    add $10
    ld l, a
    ld h, $00
    ld c, [hl]
    pop hl
    xor a

jr_000_2123:
    rrca
    or c
    dec e
    jr z, jr_000_2136

    bit 0, a
    jr z, jr_000_2123

    jr jr_000_2136

jr_000_212e:
    ld a, e
    dec a
    and $f8
    jr z, jr_000_215d

    jr jr_000_2142

jr_000_2136:
    ld b, a
    cpl
    ld c, a
    push de
    call Call_000_229d
    ld de, $000f
    add hl, de
    pop de

jr_000_2142:
    ld a, e
    or a
    ret z

    and $f8
    jr z, jr_000_215d

    xor a
    ld c, a
    cpl
    ld b, a
    push de
    call Call_000_229d
    ld de, $000f
    add hl, de
    pop de
    ld a, e
    sub $08
    ret z

    ld e, a
    jr jr_000_2142

jr_000_215d:
    ld a, $80

jr_000_215f:
    dec e
    jr z, jr_000_2166

    sra a
    jr jr_000_215f

jr_000_2166:
    ld b, a
    cpl
    ld c, a
    jp Jump_000_229d


Jump_000_216c:
    ld a, c
    sub e
    jp nc, Jump_000_217d

    ld a, b
    sub d
    jr z, jr_000_2189

    ld a, $00
    jr nc, jr_000_2189

    ld a, $ff
    jr jr_000_2189

Jump_000_217d:
    ld a, c
    sub e
    jr z, jr_000_2187

    ld a, $00
    jr nc, jr_000_2187

    ld a, $ff

jr_000_2187:
    ld b, d
    ld c, e

jr_000_2189:
    ld [$c32d], a
    ld hl, $36d7
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
    ld a, [$c32c]
    ld e, a
    inc e
    ld a, [$c32b]
    or a
    jp z, Jump_000_225f

    push hl
    ld h, $00
    ld l, a
    add hl, hl
    ld a, h
    ld [$c330], a
    ld a, l
    ld [$c331], a
    ld d, h
    ld e, l
    ld a, [$c32c]
    cpl
    ld l, a
    ld h, $ff
    inc hl
    add hl, de
    ld a, h
    ld [$c32e], a
    ld a, l
    ld [$c32f], a
    ld a, [$c32c]
    cpl
    ld l, a
    ld h, $ff
    inc hl
    ld a, [$c32b]
    ld d, $00
    ld e, a
    add hl, de
    add hl, hl
    ld a, h
    ld [$c332], a
    ld a, l
    ld [$c333], a
    pop hl
    ld a, [$c32c]
    ld e, a
    ld a, b
    and $07
    add $10
    ld c, a
    ld b, $00
    ld a, [bc]
    ld b, a
    ld c, a

jr_000_21f1:
    push de
    push bc
    ld a, b
    cpl
    ld c, a
    call Call_000_229d
    inc hl
    ld a, l
    and $0f
    jr nz, jr_000_2203

    ld de, $0130
    add hl, de

jr_000_2203:
    pop bc
    ld a, [$c32e]
    bit 7, a
    jr z, jr_000_2223

    ld a, [$c32f]
    ld d, a
    ld a, [$c331]
    add d
    ld [$c32f], a
    ld a, [$c32e]
    ld d, a
    ld a, [$c330]
    adc d
    ld [$c32e], a
    jr jr_000_2255

jr_000_2223:
    ld a, [$c32d]
    or a
    jr nz, jr_000_2235

    rlc b
    bit 0, b
    jr z, jr_000_223f

    ld de, $fff0
    add hl, de
    jr jr_000_223f

jr_000_2235:
    rrc b
    bit 7, b
    jr z, jr_000_223f

    ld de, $0010
    add hl, de

jr_000_223f:
    ld a, [$c32f]
    ld d, a
    ld a, [$c333]
    add d
    ld [$c32f], a
    ld a, [$c32e]
    ld d, a
    ld a, [$c332]
    adc d
    ld [$c32e], a

jr_000_2255:
    pop de
    dec e
    jr nz, jr_000_21f1

    ld a, b
    cpl
    ld c, a
    jp Jump_000_229d


Jump_000_225f:
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

jr_000_226d:
    push de
    call Call_000_229d
    inc hl
    ld a, l
    and $0f
    jr nz, jr_000_227b

    ld de, $0130
    add hl, de

jr_000_227b:
    pop de
    dec e
    ret z

    jr jr_000_226d

Call_000_2280:
    ld hl, $36d7
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

Call_000_229d:
Jump_000_229d:
    ld a, [$c323]
    ld d, a
    ld a, [$c325]
    cp $01
    jr z, jr_000_22d1

    cp $02
    jr z, jr_000_22eb

    cp $03
    jr z, jr_000_2305

    ld e, b
    bit 0, d
    jr nz, jr_000_22b8

    push bc
    ld b, $00

jr_000_22b8:
    bit 1, d
    jr nz, jr_000_22be

    ld e, $00

jr_000_22be:
    ldh a, [rSTAT]

Jump_000_22c0:
    bit 1, a
    jr nz, jr_000_22be

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


jr_000_22d1:
    ld c, b
    bit 0, d
    jr nz, jr_000_22d8

    ld b, $00

jr_000_22d8:
    bit 1, d
    jr nz, jr_000_22de

    ld c, $00

jr_000_22de:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_22de

    ld a, [hl]
    or b
    ld [hl+], a
    ld a, [hl]
    or c
    ld [hl], a
    ret


jr_000_22eb:
    ld c, b
    bit 0, d
    jr nz, jr_000_22f2

    ld b, $00

jr_000_22f2:
    bit 1, d
    jr nz, jr_000_22f8

    ld c, $00

jr_000_22f8:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_22f8

    ld a, [hl]
    xor b
    ld [hl+], a
    ld a, [hl]

Call_000_2302:
    xor c
    ld [hl], a
    ret


jr_000_2305:
    ld b, c
    bit 0, d
    jr z, jr_000_230c

    ld b, $ff

jr_000_230c:
    bit 1, d
    jr z, jr_000_2312

    ld c, $ff

jr_000_2312:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_2312

    ld a, [hl]
    and b
    ld [hl+], a
    ld a, [hl]
    and c
    ld [hl], a
    ret


Call_000_231f:
    ld hl, $36d7
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

jr_000_233a:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_233a

    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld e, a
    ld b, $00
    ld a, d
    and c
    jr z, jr_000_234c

    set 0, b

jr_000_234c:
    ld a, e
    and c
    jr z, jr_000_2352

    set 1, b

jr_000_2352:
    ld e, b
    ret


Call_000_2354:
    ld hl, $36d7
    ld d, $00
    ld a, [$c335]
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
    ld a, [$c334]
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
    ld de, $2d91
    add hl, de
    ld d, h
    ld e, l
    ld h, b
    ld l, c
    ld a, [$c323]
    ld c, a

jr_000_2383:
    ld a, [de]
    inc de
    push de
    push hl
    ld hl, $c324
    ld l, [hl]
    ld b, a
    xor a
    bit 0, l
    jr z, jr_000_2392

    cpl

jr_000_2392:
    or b
    bit 0, c
    jr nz, jr_000_2398

    xor b

jr_000_2398:
    ld d, a
    xor a
    bit 1, l
    jr z, jr_000_239f

    cpl

jr_000_239f:
    or b
    bit 1, c
    jr nz, jr_000_23a5

    xor b

jr_000_23a5:
    ld e, a
    pop hl

jr_000_23a7:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_23a7

    ld a, d
    ld [hl+], a
    ld a, e
    ld [hl+], a
    pop de
    ld a, l
    and $0f
    jr nz, jr_000_2383

    ret


    ld hl, sp+$02
    ld a, [hl+]
    ld [$c334], a
    ld a, [hl+]
    ld [$c335], a
    ret


    push bc
    ld a, [$c2b2]
    cp $01
    call nz, Call_000_3606
    ld hl, sp+$04
    ld a, [hl]
    ld c, a
    call Call_000_2354
    call Call_000_1d47
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    call Call_000_231f
    pop bc
    ret


Call_000_23e4:
    ld hl, sp+$02
    ld a, [hl+]
    ld [$c323], a
    ld a, [hl+]
    ld [$c324], a
    ld a, [hl]
    ld [$c325], a
    ret


    push bc
    ld a, [$c2b2]
    cp $01
    call nz, Call_000_3606
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld d, a
    ld a, [hl]
    ld [$c326], a
    call Call_000_1d64
    pop bc
    ret


Call_000_240d:
    push bc
    ld a, [$c2b2]
    cp $01
    call nz, Call_000_3606
    ld hl, sp+$04
    ld a, [hl+]
    ld [$c327], a
    ld a, [hl+]
    ld [$c329], a
    ld a, [hl+]
    ld [$c328], a
    ld a, [hl+]
    ld [$c32a], a
    ld a, [hl]
    ld [$c326], a
    call Call_000_1f19
    pop bc
    ret


    push bc
    ld a, [$c2b2]
    cp $01
    call nz, Call_000_3606
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld e, a
    call Call_000_1fef
    pop bc
    ret


Call_000_2449:
    push bc
    ld a, [$c2b2]
    cp $01
    call nz, Call_000_3606
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    call Call_000_2280
    pop bc
    ret


    push bc
    ld a, [$c2b2]
    cp $01
    call nz, Call_000_3606
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld [$c323], a
    ld a, [hl+]
    ld [$c325], a
    call Call_000_2280
    pop bc
    ret


Call_000_2479:
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

Jump_000_2489:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    or a
    jp z, Jump_000_24ac

    dec hl
    inc [hl]
    jr nz, jr_000_249a

    inc hl
    inc [hl]

jr_000_249a:
    ld a, c
    push af
    inc sp
    call Call_000_1c99
    add sp, $01
    ld hl, sp+$02
    inc [hl]
    jr nz, jr_000_24a9

    inc hl
    inc [hl]

jr_000_24a9:
    jp Jump_000_2489


Jump_000_24ac:
    ld a, $0a
    push af
    inc sp
    call Call_000_1c99
    add sp, $01
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc de
    add sp, $04
    ret


    jp Jump_000_254c


    jp Jump_000_2703


Call_000_24c4:
    jp Jump_000_277c


Call_000_24c7:
    jp Jump_000_282d


Call_000_24ca:
    jp Jump_000_2901


    ld a, $05
    rst RST_08
    jp Jump_000_28d4


    ld a, $05
    rst RST_08
    jp Jump_000_261d


    ld a, $05
    rst RST_08
    jp Jump_000_265d


    ld a, $05
    rst RST_08
    jp Jump_000_28a7


    ld a, $05
    rst RST_08
    jp Jump_000_2603


    ld a, $05
    rst RST_08
    jp Jump_000_28b6


    ld a, $05
    rst RST_08
    jp Jump_000_2643


    ld a, $05
    rst RST_08
    jp Jump_000_2611


    ld a, $05
    rst RST_08
    jp Jump_000_2651


    ld a, $05
    rst RST_08
    jp Jump_000_2631


    ld a, $05
    rst RST_08
    jp Jump_000_2671


    ld a, $05
    rst RST_08
    jp Jump_000_1cd8


    ld a, $05
    rst RST_08
    jp Jump_000_1cf5


    ld a, $05
    rst RST_08
    jp Jump_000_1d12


    ld a, $05
    rst RST_08
    jp Jump_000_1d12


Call_000_2527:
    push af
    ld hl, sp+$00
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]

Jump_000_2534:
    ld a, [bc]
    inc bc
    or a
    jp z, Jump_000_2544

    ld hl, sp+$00
    inc [hl]
    jr nz, jr_000_2541

    inc hl
    inc [hl]

jr_000_2541:
    jp Jump_000_2534


Jump_000_2544:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $02
    ret


Jump_000_254c:
    add sp, -$04
    ld hl, sp+$0a
    push hl
    ld hl, sp+$08
    push hl
    ld hl, sp+$04
    push hl
    ld b, $04
    call Call_000_256b
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


Call_000_256b:
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
    call Call_000_2951
    ld hl, sp+$04
    ld [hl], b

Jump_000_2589:
    ld hl, sp+$04
    ld a, [hl]
    ld hl, sp+$05
    ld [hl], a

jr_000_258f:
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
    call Call_000_28bb
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
    jr z, jr_000_25c3

    ld a, [hl]
    adc d
    ld [hl+], a
    call Call_000_25ee
    ld hl, sp+$05
    dec [hl]
    jr z, jr_000_25c3

    ld hl, sp+$0c
    call Call_000_25f6
    ld hl, sp+$08
    call Call_000_25f6
    jr jr_000_258f

jr_000_25c3:
    ld hl, sp+$04
    dec [hl]
    jr z, jr_000_25eb

    ld hl, sp+$00
    call Call_000_25f6
    ld hl, sp+$0a
    call Call_000_25f6
    push bc
    ld b, $02
    ld hl, sp+$02
    ld d, h
    ld e, l
    ld hl, sp+$0a
    call Call_000_25fb
    ld hl, sp+$04
    ld d, h
    ld e, l
    ld hl, sp+$0e
    call Call_000_25fb
    pop bc
    jp Jump_000_2589


jr_000_25eb:
    add sp, $06
    ret


Call_000_25ee:
jr_000_25ee:
    dec c
    ret z

    ld a, $00
    adc [hl]
    ld [hl+], a
    jr jr_000_25ee

Call_000_25f6:
    inc [hl]
    ret nz

    inc hl
    inc [hl]
    ret


Call_000_25fb:
    ld c, b

jr_000_25fc:
    ld a, [de]
    inc de
    ld [hl+], a
    dec c
    jr nz, jr_000_25fc

    ret


Jump_000_2603:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_2683
    ld e, c
    ld d, b
    ret


Jump_000_2611:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_2683
    ret


Jump_000_261d:
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
    call Call_000_268b
    ld e, c
    ld d, b
    ret


Jump_000_2631:
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
    call Call_000_268b
    ret


Jump_000_2643:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_26bd
    ld e, c
    ld d, b
    ret


Jump_000_2651:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_26bd
    ret


Jump_000_265d:
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
    call Call_000_26c0
    ld e, c
    ld d, b
    ret


Jump_000_2671:
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
    call Call_000_26c0
    ret


Call_000_2683:
    ld a, c
    rlca
    sbc a
    ld b, a
    ld a, e
    rlca
    sbc a
    ld d, a

Call_000_268b:
    ld a, b
    push af
    xor d
    push af
    bit 7, d
    jr z, jr_000_2699

    sub a
    sub e
    ld e, a
    sbc a
    sub d
    ld d, a

jr_000_2699:
    bit 7, b
    jr z, jr_000_26a3

    sub a
    sub c
    ld c, a
    sbc a
    sub b
    ld b, a

jr_000_26a3:
    call Call_000_26c0
    ret c

    pop af
    and $80
    jr z, jr_000_26b2

    sub a
    sub c
    ld c, a
    sbc a
    sub b
    ld b, a

jr_000_26b2:
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


Call_000_26bd:
    ld b, $00
    ld d, b

Call_000_26c0:
    ld a, e
    or d
    jr nz, jr_000_26cb

    ld bc, $0000
    ld d, b
    ld e, c
    scf
    ret


jr_000_26cb:
    ld l, c
    ld h, b
    ld bc, $0000
    or a
    ld a, $10

jr_000_26d3:
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
    jr c, jr_000_26e9

    pop bc
    jr jr_000_26eb

jr_000_26e9:
    inc sp
    inc sp

jr_000_26eb:
    jr c, jr_000_26f4

    pop af
    dec a
    or a
    jr nz, jr_000_26d3

    jr jr_000_26f9

jr_000_26f4:
    pop af
    dec a
    scf
    jr nz, jr_000_26d3

jr_000_26f9:
    ld d, b
    ld e, c
    rl l
    ld c, l
    rl h
    ld b, h
    or a
    ret


Jump_000_2703:
    add sp, -$09
    ld b, $04
    ld hl, sp+$0b
    call Call_000_27c2
    jr nz, jr_000_2716

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_2779


jr_000_2716:
    ld hl, sp+$0f
    call Call_000_27c2
    jr nz, jr_000_272c

    ld a, $21
    ld [$c2af], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_2779


jr_000_272c:
    ld hl, sp+$00
    xor a
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    bit 7, a
    jr z, jr_000_2740

    ld hl, sp+$0f
    call Call_000_2947
    ld hl, sp+$00
    ld [hl], $01

jr_000_2740:
    ld hl, sp+$0e
    ld a, [hl]
    bit 7, a
    jr z, jr_000_2752

    ld hl, sp+$0b
    call Call_000_2947
    ld hl, sp+$00
    ld a, $01
    xor [hl]
    ld [hl], a

jr_000_2752:
    ld hl, sp+$0f
    push hl
    ld hl, sp+$0d
    push hl
    ld hl, sp+$09
    push hl
    ld hl, sp+$07
    push hl
    call Call_000_2958
    add sp, $08
    ld hl, sp+$00
    rr [hl]
    jr nc, jr_000_2770

    ld b, $04
    ld hl, sp+$01
    call Call_000_2947

jr_000_2770:
    ld hl, sp+$01
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_2779:
    add sp, $09
    ret


Jump_000_277c:
    add sp, -$08
    ld b, $04
    ld hl, sp+$0a
    call Call_000_27c2
    jr nz, jr_000_278f

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_27bf


jr_000_278f:
    ld hl, sp+$0e
    call Call_000_27c2
    jr nz, jr_000_27a5

    ld a, $21
    ld [$c2af], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_27bf


jr_000_27a5:
    ld hl, sp+$0e
    push hl
    ld hl, sp+$0c
    push hl
    ld hl, sp+$08
    push hl
    ld hl, sp+$06
    push hl
    call Call_000_2958
    add sp, $08
    ld hl, sp+$00
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_27bf:
    add sp, $08
    ret


Call_000_27c2:
    xor a
    ld c, b

jr_000_27c4:
    cp [hl]
    ret nz

    inc hl
    dec c
    jr nz, jr_000_27c4

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


Call_000_27d7:
    xor a
    bit 7, [hl]
    jr z, jr_000_27de

    ld a, $80

jr_000_27de:
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


jr_000_27f0:
    ld c, $03

jr_000_27f2:
    ld a, [de]
    sub [hl]
    ret nz

    dec de
    dec hl
    dec c
    ret z

    jr jr_000_27f2

    ld hl, sp+$07
    call Call_000_27d7

Call_000_2800:
Jump_000_2800:
    ld hl, sp+$0b
    call Call_000_27d7
    ld hl, sp+$07
    bit 7, [hl]
    jr z, jr_000_281c

    ld hl, sp+$0b
    bit 7, [hl]
    jr z, jr_000_2819

    ld hl, sp+$0b
    ld d, h

Call_000_2814:
    ld e, l
    ld hl, sp+$07
    jr jr_000_27f0

jr_000_2819:
    xor a
    ccf
    ret


jr_000_281c:
    ld hl, sp+$0b
    bit 7, [hl]
    jr z, jr_000_2825

    xor a
    dec a
    ret


jr_000_2825:
    ld hl, sp+$07
    ld d, h
    ld e, l
    ld hl, sp+$0b
    jr jr_000_27f0

Jump_000_282d:
    add sp, -$09
    ld b, $04
    ld hl, sp+$0b
    call Call_000_27c2
    jr nz, jr_000_2840

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_28a4


jr_000_2840:
    ld hl, sp+$0f
    call Call_000_27c2
    jr nz, jr_000_2856

    ld a, $21
    ld [$c2af], a

Call_000_284c:
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_28a4


jr_000_2856:
    ld hl, sp+$00
    xor a
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    bit 7, a
    jr z, jr_000_286a

    ld hl, sp+$0f
    call Call_000_2947
    ld hl, sp+$00
    ld [hl], $01

jr_000_286a:
    ld hl, sp+$0e
    ld a, [hl]
    bit 7, a
    jr z, jr_000_287c

    ld hl, sp+$0b
    call Call_000_2947
    ld hl, sp+$00
    ld a, $01
    xor [hl]
    ld [hl], a

jr_000_287c:
    ld hl, sp+$0f
    push hl
    ld hl, sp+$0d
    push hl
    ld hl, sp+$09
    push hl
    ld hl, sp+$07
    push hl
    call Call_000_2958
    add sp, $08
    ld hl, sp+$00
    rr [hl]
    jr nc, jr_000_289b

    ld b, $04
    xor a
    ld hl, sp+$05
    call Call_000_2947

jr_000_289b:
    ld hl, sp+$05
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_28a4:
    add sp, $09
    ret


Jump_000_28a7:
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
    jr jr_000_28dd

Jump_000_28b6:
    ld hl, sp+$02
    ld a, [hl+]
    ld c, a
    ld e, [hl]

Call_000_28bb:
    xor a
    ld h, a
    ld l, a
    ld d, a

jr_000_28bf:
    xor a
    rr c
    jr nc, jr_000_28c5

    add hl, de

jr_000_28c5:
    sla e
    jr z, jr_000_28cd

    rl d
    jr jr_000_28bf

jr_000_28cd:
    rl d
    jr nz, jr_000_28bf

    ld e, l
    ld d, h
    ret


Jump_000_28d4:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld c, [hl]
    inc hl
    ld b, [hl]

jr_000_28dd:
    ld hl, $0000

jr_000_28e0:
    sra b
    jr nz, jr_000_28ed

    rr c
    jr nc, jr_000_28e9

    add hl, de

jr_000_28e9:
    jr z, jr_000_28fe

    jr jr_000_28f2

jr_000_28ed:
    rr c
    jr nc, jr_000_28f2

    add hl, de

jr_000_28f2:
    sla e
    jr z, jr_000_28fa

    rl d
    jr jr_000_28e0

jr_000_28fa:
    rl d
    jr nz, jr_000_28e0

jr_000_28fe:
    ld e, l
    ld d, h
    ret


Jump_000_2901:
    add sp, -$08
    ld b, $04
    ld hl, sp+$0a
    call Call_000_27c2
    jr nz, jr_000_2914

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_2944


jr_000_2914:
    ld hl, sp+$0e
    call Call_000_27c2
    jr nz, jr_000_292a

    ld a, $21
    ld [$c2af], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_2944


jr_000_292a:
    ld hl, sp+$0e
    push hl
    ld hl, sp+$0c
    push hl
    ld hl, sp+$08
    push hl
    ld hl, sp+$06
    push hl
    call Call_000_2958
    add sp, $08
    ld hl, sp+$04
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_2944:
    add sp, $08
    ret


Call_000_2947:
    ld c, b
    xor a
    ld d, a

jr_000_294a:
    ld a, d
    sbc [hl]
    ld [hl+], a
    dec c
    jr nz, jr_000_294a

    ret


Call_000_2951:
    ld c, b
    xor a

jr_000_2953:
    ld [hl+], a
    dec c
    jr nz, jr_000_2953

    ret


Call_000_2958:
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
    call Call_000_2951
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call Call_000_2951

jr_000_2971:
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    xor a
    call Call_000_29c2
    push af
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    pop af
    push hl
    call Call_000_29c2
    pop de
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push de
    push hl
    call Call_000_29b8
    pop hl
    pop de
    jr c, jr_000_2997

    call Call_000_29a8

jr_000_2997:
    ccf
    push af
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    pop af
    call Call_000_29c2
    pop bc
    dec c
    ret z

    push bc
    jr jr_000_2971

Call_000_29a8:
    ld c, b

jr_000_29a9:
    ld a, [de]
    sbc [hl]
    ld [de], a
    inc hl
    inc de
    dec c
    jr nz, jr_000_29a9

    ret


    ld c, b

jr_000_29b3:
    ld [hl+], a
    dec c
    jr nz, jr_000_29b3

    ret


Call_000_29b8:
    ld c, b
    xor a

jr_000_29ba:
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    dec c
    jr nz, jr_000_29ba

    ret


Call_000_29c2:
    ld c, b

jr_000_29c3:
    rl [hl]
    inc hl
    dec c
    jr nz, jr_000_29c3

    ret


Jump_000_29ca:
    ld a, d
    or e
    ret z

    ld a, h
    cp $98
    jr c, jr_000_29d5

    sub $10
    ld h, a

jr_000_29d5:
    xor a
    cp e
    jr nz, jr_000_29da

    dec d

jr_000_29da:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_29da

    ld a, [bc]
    ld [hl+], a
    inc bc

jr_000_29e3:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_29e3

    ld a, [bc]
    ld [hl], a
    inc bc
    inc l
    jr nz, jr_000_29f7

    inc h
    ld a, h
    cp $98
    jr nz, jr_000_29f7

    ld h, $88

jr_000_29f7:
    dec e
    jr nz, jr_000_29da

    dec d
    bit 7, d
    jr z, jr_000_29da

    ret


Jump_000_2a00:
    ld a, d
    or e
    ret z

    ld a, h
    cp $98
    jr c, jr_000_2a0b

    sub $10
    ld h, a

jr_000_2a0b:
    push de
    ld a, [bc]
    ld e, a
    inc bc
    push bc
    ld bc, $0000
    ld a, [$c324]
    bit 0, a
    jr z, jr_000_2a1c

    ld b, $ff

jr_000_2a1c:
    bit 1, a
    jr z, jr_000_2a22

    ld c, $ff

jr_000_2a22:
    ld d, a
    ld a, [$c323]
    xor d
    ld d, a
    bit 0, d
    jr z, jr_000_2a2f

    ld a, e
    xor b
    ld b, a

jr_000_2a2f:
    bit 1, d
    jr z, jr_000_2a36

    ld a, e
    xor c
    ld c, a

jr_000_2a36:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_2a36

    ld [hl], b
    inc hl

jr_000_2a3e:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_2a3e

    ld [hl], c
    inc hl
    ld a, h
    cp $98
    jr nz, jr_000_2a4d

    ld h, $88

jr_000_2a4d:
    pop bc
    pop de
    dec de
    ld a, d
    or e
    jr nz, jr_000_2a0b

    ret


Call_000_2a55:
    call Call_000_069f
    push hl
    ld hl, $c310
    ld b, $06

jr_000_2a5e:
    ld a, [hl]
    inc hl
    or [hl]
    cp $00
    jr z, jr_000_2a70

    inc hl
    inc hl
    dec b
    jr nz, jr_000_2a5e

    pop hl
    ld hl, $0000
    jr jr_000_2a94

jr_000_2a70:
    pop de
    ld [hl], d
    dec hl
    ld [hl], e
    ld a, [$c30e]
    dec hl
    ld [hl], a
    push hl
    call Call_000_2ae5
    ld a, [$c2b2]
    and $02
    call nz, Call_000_2a9d
    ld hl, $c30c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    inc hl
    ld a, [$c30e]
    add [hl]
    ld [$c30e], a
    pop hl

jr_000_2a94:
    ldh a, [rLCDC]
    or $81
    and $e7
    ldh [rLCDC], a
    ret


Call_000_2a9d:
    ld hl, $c30c
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
    jr z, jr_000_2ac9

    ld bc, $0000
    cp $02
    jr z, jr_000_2ac9

    ld bc, $0100

jr_000_2ac9:
    inc hl
    inc hl
    add hl, bc
    ld c, l
    ld b, h
    ld a, [$c30b]
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
    jp z, Jump_000_29ca

    jp Jump_000_2a00


Call_000_2ae5:
    ld a, [hl+]
    ld [$c30b], a
    ld a, [hl+]
    ld [$c30c], a
    ld a, [hl+]
    ld [$c30d], a
    ret


Call_000_2af2:
    cp $0a
    jr nz, jr_000_2b04

    push af
    ld a, [$c2b2]
    and $08
    jr nz, jr_000_2b03

    call Call_000_2bde
    pop af
    ret


jr_000_2b03:
    pop af

jr_000_2b04:
    call Call_000_2b1b
    call Call_000_2bf3
    ret


    call Call_000_2b1b
    call Call_000_2bf3
    ret


    call Call_000_2bc7
    ld a, $00
    call Call_000_2b1b
    ret


Call_000_2b1b:
    push af
    ld a, [$c30d]
    or a
    jr nz, jr_000_2b30

    call Call_000_2b8a
    xor a
    ld [$c30e], a
    call Call_000_078d
    adc b
    inc l
    nop
    nop

jr_000_2b30:
    pop af
    push bc
    push de
    push hl
    ld e, a
    ld hl, $c30c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [hl+]
    and $03
    cp $02
    jr z, jr_000_2b47

    inc hl
    ld d, $00
    add hl, de
    ld e, [hl]

jr_000_2b47:
    ld a, [$c30b]
    add e
    ld e, a
    ld a, [$c322]
    ld l, a
    ld h, $00
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld a, [$c321]
    ld c, a
    ld b, $00
    add hl, bc
    ld bc, $9800
    add hl, bc

jr_000_2b62:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_2b62

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
    call Call_000_2a55
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
    call Call_000_2ae5
    pop bc
    ld de, $0000
    ret


Call_000_2b8a:
    push bc
    call Call_000_2c4f
    ld a, $01
    ld [$c30e], a
    xor a
    ld hl, $c30f
    ld b, $12

jr_000_2b99:
    ld [hl+], a
    dec b
    jr nz, jr_000_2b99

    ld a, $03
    ld [$c323], a
    ld a, $00
    ld [$c324], a
    call Call_000_2bac
    pop bc
    ret


Call_000_2bac:
    push de
    push hl
    ld hl, $9800
    ld e, $20

jr_000_2bb3:
    ld d, $20

jr_000_2bb5:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_2bb5

    ld [hl], $00
    inc hl
    dec d
    jr nz, jr_000_2bb5

    dec e
    jr nz, jr_000_2bb3

    pop hl
    pop de
    ret


Call_000_2bc7:
    push hl
    ld hl, $c321
    xor a
    cp [hl]
    jr z, jr_000_2bd2

    dec [hl]
    jr jr_000_2bdc

jr_000_2bd2:
    ld [hl], $13
    ld hl, $c322
    xor a
    cp [hl]
    jr z, jr_000_2bdc

    dec [hl]

jr_000_2bdc:
    pop hl
    ret


Call_000_2bde:
    push hl
    xor a
    ld [$c321], a
    ld hl, $c322
    ld a, $11
    cp [hl]
    jr z, jr_000_2bee

    inc [hl]
    jr jr_000_2bf1

jr_000_2bee:
    call Call_000_2c21

jr_000_2bf1:
    pop hl
    ret


Call_000_2bf3:
    push hl
    ld hl, $c321
    ld a, $13
    cp [hl]
    jr z, jr_000_2bff

    inc [hl]
    jr jr_000_2c1f

jr_000_2bff:
    ld [hl], $00
    ld hl, $c322
    ld a, $11
    cp [hl]
    jr z, jr_000_2c0c

    inc [hl]
    jr jr_000_2c1f

jr_000_2c0c:
    ld a, [$c2b2]
    and $04
    jr z, jr_000_2c1c

    xor a
    ld [$c322], a
    ld [$c321], a
    jr jr_000_2c1f

jr_000_2c1c:
    call Call_000_2c21

jr_000_2c1f:
    pop hl
    ret


Call_000_2c21:
    push bc
    push de
    push hl
    ld hl, $9800
    ld bc, $9820
    ld e, $1f

jr_000_2c2c:
    ld d, $20

jr_000_2c2e:
    ldh a, [rSTAT]
    and $02
    jr nz, jr_000_2c2e

    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, jr_000_2c2e

    dec e
    jr nz, jr_000_2c2c

    ld d, $20

jr_000_2c3f:
    ldh a, [rSTAT]
    and $02
    jr nz, jr_000_2c3f

    ld a, $00
    ld [hl+], a
    dec d
    jr nz, jr_000_2c3f

    pop hl
    pop de
    pop bc
    ret


Call_000_2c4f:
Jump_000_2c4f:
    di
    ldh a, [rLCDC]
    bit 7, a
    jr z, jr_000_2c6b

    call Call_000_069f
    ld bc, $1d2f

Call_000_2c5c:
    ld hl, $c2bb
    call Call_000_064c
    ld bc, $1d3a
    ld hl, $c2cb
    call Call_000_064c

jr_000_2c6b:
    call Call_000_2c78
    ldh a, [rLCDC]
    or $81
    and $e7
    ldh [rLCDC], a
    ei
    ret


Call_000_2c78:
    xor a
    ld [$c321], a
    ld [$c322], a
    call Call_000_2bac
    ld a, $02
    ld [$c2b2], a
    ret


    ld hl, $2c8f
    call Call_000_2a55
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
    jr jr_000_2cc4

    ld a, [de]
    dec de
    inc e
    dec e
    ld e, $1f
    jr nz, jr_000_2cd4

    ld [hl+], a
    inc hl
    inc h
    dec h
    ld h, $27
    jr z, jr_000_2ce4

    ld a, [hl+]
    dec hl
    inc l
    dec l
    ld l, $2f
    jr nc, jr_000_2cf4

    ld [hl-], a

jr_000_2cc4:
    inc sp
    inc [hl]
    dec [hl]
    ld [hl], $37
    jr c, jr_000_2d04

    ld a, [hl-]
    dec sp
    inc a
    dec a
    ld a, $3f
    ld b, b
    ld b, c
    ld b, d

jr_000_2cd4:
    ld b, e
    ld b, h
    ld b, l
    ld b, [hl]
    ld b, a
    ld c, b
    ld c, c
    ld c, d

Jump_000_2cdc:
    ld c, e
    ld c, h
    ld c, l
    ld c, [hl]
    ld c, a
    ld d, b
    ld d, c
    ld d, d

jr_000_2ce4:
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

jr_000_2cf4:
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

jr_000_2d04:
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
    jr jr_000_2dbf

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
    jr jr_000_2dca

    jr z, jr_000_2e03

    add c
    add c
    ld c, a
    jr z, jr_000_2dd1

    rst RST_38
    add c
    add c
    add c
    add c
    add c

jr_000_2dbf:
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

jr_000_2dca:
    adc c
    adc c
    adc c
    ld sp, hl
    add c
    add c
    rst RST_38

jr_000_2dd1:
    ld bc, $0603
    adc h
    ret c

    ld [hl], b
    jr nz, jr_000_2dd9

jr_000_2dd9:
    ld a, [hl]
    jp $d3d3


    db $db
    jp $7ec3


    jr jr_000_2e1f

    inc l
    inc l
    ld a, [hl]
    jr jr_000_2e00

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
    jr jr_000_2df9

jr_000_2df9:
    ld [hl], b
    ret z

    sbc $db
    db $db
    ld a, [hl]
    dec de

jr_000_2e00:
    dec de
    nop
    nop

jr_000_2e03:
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

jr_000_2e1f:
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

    jr jr_000_2eb5

    jr jr_000_2e9f

jr_000_2e9f:
    jr jr_000_2ea1

jr_000_2ea1:
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

jr_000_2eb5:
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
    jr jr_000_2ee3

    stop
    nop
    nop
    nop
    nop
    inc b
    ld [$1818], sp
    jr jr_000_2eef

    ld [$2004], sp
    db $10
    jr jr_000_2ef5

    jr @+$1a

    db $10
    jr nz, jr_000_2ee2

jr_000_2ee2:
    ld d, h

jr_000_2ee3:
    jr c, jr_000_2ee3

    jr c, jr_000_2f3b

    nop
    nop
    nop
    jr jr_000_2f04

    ld a, [hl]
    jr @+$1a

jr_000_2eef:
    nop
    nop
    nop
    nop
    nop
    nop

jr_000_2ef5:
    nop
    jr nc, jr_000_2f28

    jr nz, jr_000_2efa

jr_000_2efa:
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

jr_000_2f04:
    nop
    nop
    jr @+$1a

    nop
    inc bc
    ld b, $0c
    jr jr_000_2f3e

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
    jr jr_000_2f53

    jr jr_000_2f35

    jr jr_000_2f37

    jr jr_000_2f21

jr_000_2f21:
    inc a
    ld h, [hl]
    ld c, $1c
    jr c, jr_000_2f97

    ld a, [hl]

jr_000_2f28:
    nop
    ld a, [hl]
    inc c
    jr jr_000_2f69

    ld b, $46
    inc a
    nop
    inc c
    inc e
    inc l
    ld c, h

jr_000_2f35:
    ld a, [hl]
    inc c

jr_000_2f37:
    inc c
    nop
    ld a, [hl]
    ld h, b

jr_000_2f3b:
    ld a, h
    ld b, $06

jr_000_2f3e:
    ld b, [hl]
    inc a
    nop
    inc e
    jr nz, jr_000_2fa4

    ld a, h
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    ld a, [hl]
    ld b, $0e
    inc e
    jr @+$1a

    jr jr_000_2f51

jr_000_2f51:
    inc a
    ld h, [hl]

jr_000_2f53:
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
    jr c, jr_000_2f61

jr_000_2f61:
    nop
    jr jr_000_2f7c

    nop
    nop
    jr jr_000_2f80

    nop

jr_000_2f69:
    nop
    jr jr_000_2f84

    nop
    jr jr_000_2f87

    stop
    ld b, $0c
    jr jr_000_2fa5

    jr @+$0e

    ld b, $00
    nop
    nop
    inc a

jr_000_2f7c:
    nop
    nop
    inc a
    nop

jr_000_2f80:
    nop
    ld h, b
    jr nc, jr_000_2f9c

jr_000_2f84:
    inc c
    jr jr_000_2fb7

jr_000_2f87:
    ld h, b
    nop
    inc a
    ld b, [hl]
    ld b, $0c
    jr jr_000_2fa7

    nop
    jr jr_000_2fce

    ld h, [hl]
    ld l, [hl]
    ld l, d
    ld l, [hl]
    ld h, b

jr_000_2f97:
    inc a
    nop
    inc a
    ld h, [hl]
    ld h, [hl]

jr_000_2f9c:
    ld a, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    nop
    ld a, h
    ld h, [hl]
    ld h, [hl]

jr_000_2fa4:
    ld a, h

jr_000_2fa5:
    ld h, [hl]
    ld h, [hl]

jr_000_2fa7:
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

jr_000_2fb7:
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

jr_000_2fce:
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
    jr jr_000_2ff3

    jr jr_000_2ff5

    jr jr_000_2ff7

    jr jr_000_2fe1

jr_000_2fe1:
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

jr_000_2ff3:
    ld h, b
    ld h, b

jr_000_2ff5:
    ld h, b
    ld h, b

jr_000_2ff7:
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

    jr jr_000_3050

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

jr_000_3050:
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

    jr jr_000_3061

jr_000_3061:
    ld a, [hl]
    ld c, $1c
    jr c, jr_000_30d6

    ld h, b
    ld a, [hl]
    nop
    ld e, $18
    jr jr_000_3085

    jr jr_000_3087

    ld e, $00
    ld b, b
    ld h, b
    jr nc, jr_000_308d

    inc c
    ld b, $02
    nop
    ld a, b
    jr jr_000_3094

    jr jr_000_3096

    jr jr_000_30f8

    nop
    db $10
    jr c, jr_000_30f0

    nop

jr_000_3085:
    nop
    nop

jr_000_3087:
    nop
    nop
    nop
    nop
    nop
    nop

jr_000_308d:
    nop
    nop
    ld a, [hl]
    nop
    nop
    ret nz

    ret nz

jr_000_3094:
    ld h, b
    nop

jr_000_3096:
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

    jr nc, jr_000_30f8

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

jr_000_30d6:
    ld h, [hl]
    ld h, [hl]
    nop
    jr jr_000_30db

jr_000_30db:
    jr jr_000_30f5

    jr jr_000_30f7

    jr jr_000_30e1

jr_000_30e1:
    nop
    ld [$1818], sp
    jr jr_000_30ff

    ld e, b
    jr nc, jr_000_314a

    ld h, h
    ld l, b
    ld [hl], b
    ld a, b
    ld l, h
    ld h, [hl]

jr_000_30f0:
    nop
    jr jr_000_310b

    jr jr_000_310d

jr_000_30f5:
    jr jr_000_310f

jr_000_30f7:
    inc c

jr_000_30f8:
    nop
    nop
    db $fc
    sub $d6
    sub $d6

jr_000_30ff:
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

jr_000_310b:
    ld h, [hl]
    ld h, [hl]

jr_000_310d:
    ld h, [hl]
    ld h, [hl]

jr_000_310f:
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
    jr c, jr_000_314a

    ld c, [hl]
    inc a
    nop
    jr jr_000_316f

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

jr_000_314a:
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
    jr c, jr_000_31d7

    ld a, [hl]
    nop
    ld c, $18
    jr jr_000_319d

    jr jr_000_3187

jr_000_316f:
    ld c, $00
    jr jr_000_318b

    jr jr_000_318d

    jr jr_000_318f

    jr @+$1a

    ld [hl], b
    jr jr_000_3194

    inc c
    jr jr_000_3197

    ld [hl], b
    nop
    nop
    ld h, b
    ldh a, [c]
    sbc [hl]
    inc c
    nop

jr_000_3187:
    nop
    nop
    db $10
    db $10

jr_000_318b:
    jr z, jr_000_31b5

jr_000_318d:
    ld b, h
    ld b, h

jr_000_318f:
    add d
    cp $3c
    ld h, d
    ld h, b

jr_000_3194:
    ld h, b
    ld h, b
    ld h, d

jr_000_3197:
    inc e
    jr nc, @+$26

    nop
    ld h, [hl]
    ld h, [hl]

jr_000_319d:
    ld h, [hl]
    ld h, [hl]
    ld a, $00
    inc c
    jr jr_000_31a4

jr_000_31a4:
    inc a
    ld a, [hl]
    ld h, b
    inc a
    nop
    jr jr_000_3211

    nop
    inc a
    ld b, $7e
    ld a, $00
    inc h
    nop
    inc a
    ld b, [hl]

jr_000_31b5:
    ld a, $46
    ld a, $00
    jr nc, jr_000_31d3

    nop
    inc a
    ld b, $7e
    ld a, $00
    jr jr_000_31db

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

jr_000_31d3:
    nop
    inc a
    ld a, [hl]
    ld h, b

jr_000_31d7:
    ld a, $00
    inc h
    nop

jr_000_31db:
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
    jr jr_000_3205

    jr jr_000_3207

    jr jr_000_31f1

jr_000_31f1:
    jr jr_000_3217

    nop
    jr jr_000_320e

    jr jr_000_3210

    nop
    db $10
    ld [$1800], sp
    jr jr_000_3217

    jr jr_000_3201

jr_000_3201:
    inc h
    nop
    inc a
    ld h, [hl]

jr_000_3205:
    ld a, [hl]
    ld h, [hl]

jr_000_3207:
    ld h, [hl]
    nop
    jr jr_000_320b

jr_000_320b:
    inc a
    ld h, [hl]
    ld a, [hl]

jr_000_320e:
    ld h, [hl]
    ld h, [hl]

jr_000_3210:
    nop

jr_000_3211:
    inc c
    jr jr_000_3292

    ld h, b
    ld a, h
    ld h, b

jr_000_3217:
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
    jr jr_000_325f

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

Jump_000_3238:
    nop
    jr nc, jr_000_3253

    nop
    inc a
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    jr jr_000_3267

    nop
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    jr nc, jr_000_3263

    nop
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    inc a
    nop
    ld h, [hl]
    nop

jr_000_3253:
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

jr_000_325f:
    inc a
    nop
    ld h, [hl]
    nop

jr_000_3263:
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]

jr_000_3267:
    inc a
    nop
    jr jr_000_32a7

    ld h, d
    ld h, b
    ld h, b
    ld h, d
    inc a
    jr @+$1e

    ld a, [hl-]
    jr nc, jr_000_32f1

    jr nc, jr_000_32a7

    ld a, [hl]
    nop
    ld h, [hl]
    ld h, [hl]
    inc a
    jr jr_000_32ba

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

    jr jr_000_32a5

    jr jr_000_32a7

    jr jr_000_32a9

    inc c

jr_000_3292:
    jr jr_000_3294

jr_000_3294:
    inc a
    ld b, $7e
    ld a, $00
    inc c
    jr jr_000_329c

jr_000_329c:
    jr jr_000_32b6

    jr jr_000_32b8

    nop
    inc c
    jr jr_000_32a4

jr_000_32a4:
    inc a

jr_000_32a5:
    ld h, [hl]
    ld h, [hl]

jr_000_32a7:
    inc a
    nop

jr_000_32a9:
    inc c
    jr jr_000_32ac

jr_000_32ac:
    ld h, [hl]
    ld h, [hl]
    ld h, [hl]
    ld a, $00
    inc [hl]
    ld e, b
    nop
    ld a, h
    ld h, [hl]

jr_000_32b6:
    ld h, [hl]
    ld h, [hl]

jr_000_32b8:
    nop
    ld a, [de]

jr_000_32ba:
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
    jr jr_000_32d4

jr_000_32d4:
    jr jr_000_3306

    ld h, b
    ld h, [hl]
    inc a
    nop
    nop
    nop
    ld a, $30
    jr nc, jr_000_3310

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

jr_000_32f1:
    ld h, d
    db $e4
    ld l, b
    halt
    ld l, $56
    sbc a
    ld b, $00
    jr jr_000_32fc

jr_000_32fc:
    jr @+$1a

    jr @+$1a

    jr jr_000_331d

    ld [hl], $6c
    ret c

    ld l, h

jr_000_3306:
    ld [hl], $1b
    nop
    ret c

    ld l, h
    ld [hl], $1b
    ld [hl], $6c
    ret c

jr_000_3310:
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

jr_000_331d:
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
    jr c, jr_000_337d

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

jr_000_337d:
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
    jr nc, jr_000_3439

jr_000_3439:
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
    jr c, jr_000_3482

jr_000_3482:
    db $10
    jr c, jr_000_34f1

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
    jr c, jr_000_34c1

jr_000_34c1:
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
    jr jr_000_34e6

    jr jr_000_34e8

    db $10
    inc a
    jr jr_000_3510

    ld h, [hl]
    ld h, [hl]
    inc a
    jr jr_000_3515

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

jr_000_34e6:
    inc h
    ld h, [hl]

jr_000_34e8:
    nop
    inc e
    ld [hl], $78
    call c, $eccc
    ld a, b
    nop

jr_000_34f1:
    inc c
    jr jr_000_352c

    ld d, h
    ld d, h
    jr c, jr_000_3528

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

jr_000_3510:
    nop
    nop
    ld a, [hl]
    nop
    ld a, [hl]

jr_000_3515:
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
    jr nc, jr_000_353b

    inc c
    jr jr_000_3556

    nop
    ld a, [hl]

jr_000_3528:
    nop
    inc c
    jr @+$32

jr_000_352c:
    jr @+$0e

    nop
    ld a, [hl]
    nop
    nop
    ld c, $1b
    dec de
    jr jr_000_354f

    jr jr_000_3551

    jr jr_000_3553

jr_000_353b:
    jr jr_000_3555

    ret c

    ret c

    ld [hl], b
    nop
    jr jr_000_355b

    nop
    ld a, [hl]
    nop

jr_000_3546:
    jr jr_000_3560

    nop
    nop
    ld [hl-], a
    ld c, h
    nop
    ld [hl-], a
    ld c, h

jr_000_354f:
    nop
    nop

jr_000_3551:
    jr c, @+$6e

jr_000_3553:
    jr c, jr_000_3555

jr_000_3555:
    nop

jr_000_3556:
    nop
    nop
    nop
    jr c, @+$7e

jr_000_355b:
    jr c, jr_000_355d

jr_000_355d:
    nop
    nop
    nop

jr_000_3560:
    nop
    nop
    nop
    nop
    nop
    jr jr_000_357f

    nop
    nop
    nop
    nop
    rrca
    jr jr_000_3546

    ld [hl], b
    jr nc, jr_000_3571

jr_000_3571:
    jr c, @+$6e

    ld l, h
    ld l, h
    ld l, h
    nop
    nop
    nop
    jr c, @+$6e

    jr jr_000_35ad

    ld a, h
    nop

jr_000_357f:
    nop
    nop
    ld a, b
    inc c
    jr c, jr_000_3591

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

Call_000_3591:
jr_000_3591:
    ldh a, [rSTAT]
    and $02
    jr nz, jr_000_3591

    ld a, [bc]
    ld [hl+], a
    inc bc
    dec de
    ld a, d
    or e
    jr nz, jr_000_3591

    ret


Call_000_35a0:
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

jr_000_35ad:
    ld h, a
    call Call_000_3591
    pop bc
    ret


    push af
    push bc

jr_000_35b5:
    ld b, $ff

jr_000_35b7:
    call Call_000_35c3
    or a
    jr nz, jr_000_35b5

    dec b
    jr nz, jr_000_35b7

    pop bc
    pop af
    ret


Call_000_35c3:
    push bc
    ld a, $20
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    cpl
    and $0f
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


Call_000_35f0:
jr_000_35f0:
    call Call_000_35c3
    and b
    jr z, jr_000_35f0

    ret


Call_000_35f7:
    call Call_000_35c3
    ld e, a
    ret


    push bc
    ld hl, sp+$04
    ld b, [hl]
    call Call_000_35f0
    ld e, a
    pop bc
    ret


Call_000_3606:
Jump_000_3606:
    di
    ldh a, [rLCDC]
    bit 7, a
    jr z, jr_000_3610

    call Call_000_069f

jr_000_3610:
    ld hl, $8100
    ld de, $1680
    ld b, $00
    call Call_000_383a
    ld bc, $1d2f
    call Call_000_062e
    ld bc, $1d3a
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

jr_000_363f:
    ld d, $14

jr_000_3641:
    ld [hl+], a
    inc a
    dec d
    jr nz, jr_000_3641

    add hl, bc
    dec e
    jr nz, jr_000_363f

    ldh a, [rLCDC]
    or $91
    and $f7
    ldh [rLCDC], a
    ld a, $01
    ld [$c2b2], a
    ld a, $00
    ld [$c325], a
    ld a, $03
    ld [$c323], a
    ld a, $00
    ld [$c324], a
    ei
    ret


Call_000_3668:
    ld hl, $8100
    ld de, $1680
    call Call_000_3591
    ret


Call_000_3672:
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
    ld hl, $36d7
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
    jr z, jr_000_36a0

    ld de, $0010
    call Call_000_3591

jr_000_36a0:
    pop hl
    pop bc
    ld de, $0010
    call Call_000_3591
    ret


    push bc
    ld a, [$c2b2]
    cp $01
    call nz, Call_000_3606
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
    call Call_000_3672
    pop bc
    ret


    push bc
    ld a, [$c2b2]
    cp $01
    call nz, Call_000_3606
    ld hl, sp+$04
    ld a, [hl+]
    ld c, a
    ld b, [hl]
    call Call_000_3668
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

Call_000_37f7:
    push bc
    call Call_000_3814
    ld b, $32

Jump_000_37fd:
    jr jr_000_37ff

jr_000_37ff:
    jr jr_000_3801

jr_000_3801:
    jr jr_000_3803

jr_000_3803:
    jr jr_000_3805

jr_000_3805:
    jr jr_000_3807

jr_000_3807:
    dec b
    jp nz, Jump_000_37fd

    nop
    pop bc
    jr jr_000_380f

jr_000_380f:
    jr jr_000_3811

jr_000_3811:
    jr jr_000_3813

jr_000_3813:
    ret


Call_000_3814:
jr_000_3814:
    dec de
    ld a, e
    or d
    ret z

    ld b, $33

Jump_000_381a:
    jr jr_000_381c

jr_000_381c:
    jr jr_000_381e

jr_000_381e:
    jr jr_000_3820

jr_000_3820:
    jr jr_000_3822

jr_000_3822:
    jr jr_000_3824

jr_000_3824:
    dec b
    jp nz, Jump_000_381a

    nop
    jr jr_000_382b

jr_000_382b:
    jr jr_000_382d

jr_000_382d:
    jr jr_000_382f

jr_000_382f:
    jr jr_000_3814

Call_000_3831:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    call Call_000_37f7
    ret


Call_000_383a:
Jump_000_383a:
jr_000_383a:
    ldh a, [rSTAT]
    and $02
    jr nz, jr_000_383a

    ld [hl], b
    inc hl
    dec de
    ld a, d
    or e
    jr nz, jr_000_383a

    ret


    ldh a, [rLCDC]
    bit 6, a
    jr nz, jr_000_3853

    ld hl, $9800
    jr jr_000_3866

jr_000_3853:
    ld hl, $9c00
    jr jr_000_3866

    ldh a, [rLCDC]
    bit 3, a
    jr nz, jr_000_3863

    ld hl, $9800
    jr jr_000_3866

jr_000_3863:
    ld hl, $9c00

jr_000_3866:
    ld de, $0400
    jp Jump_000_383a


    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Call_000_3880:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Jump_000_3c58:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Call_000_3fc4:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
