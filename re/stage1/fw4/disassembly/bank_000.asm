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
    db $80, $40, $20, $10, $08, $04, $02, $01

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


    db $ff

LCDCInterrupt::
    push hl
    ld hl, $c4c6
    jp Jump_000_0067


    db $ff

TimerOverflowInterrupt::
    push hl
    ld hl, $c4d6
    jp Jump_000_0067


    db $ff

SerialTransferCompleteInterrupt::
    push hl
    ld hl, $c4e6
    jp Jump_000_0067


    db $ff

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


    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

Boot::
    nop
    jp KernelEntry


HeaderLogo::
    db $ce, $ed, $66, $66, $cc, $0d, $00, $0b, $03, $73, $00, $83, $00, $0c, $00, $0d
    db $00, $08, $11, $1f, $88, $89, $00, $0e, $dc, $cc, $6e, $e6, $dd, $dd, $d9, $99
    db $bb, $bb, $67, $63, $6e, $0e, $ec, $cc, $dd, $dc, $99, $9f, $bb, $b9, $33, $3e

HeaderTitle::
    db "BOOTLOADER", $00, $00, $00, $00, $00, $00

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
    db $fa

HeaderGlobalChecksum::
    db $b3, $2e

KernelEntry::
    di
    ld d, a
    xor a
    ld sp, $e000
    ld hl, $dfff
    ld c, $20
    ld b, $00

KernelEntry_clearWram::
    ld [hl-], a
    dec b
    jr nz, KernelEntry_clearWram

    dec c
    jr nz, KernelEntry_clearWram

    ld hl, $feff
    ld b, $00

jr_000_0169:
    ld [hl-], a
    dec b
    jr nz, jr_000_0169

    ld hl, $ffff
    ld b, $80

KernelEntry_clearHram::
    ld [hl-], a
    dec b
    jr nz, KernelEntry_clearHram

    ld a, d
    ld [$c4ac], a
    ld a, $01
    ld [$c4b2], a
    ld [$2000], a
    xor a
    ld [$c4b3], a
    call LcdOff
    xor a
    ldh [rSCY], a
    ldh [rSCX], a
    ldh [rSTAT], a
    ldh [rWY], a
    ld a, $07
    ldh [rWX], a
    ld bc, $ff80
    ld hl, OamDmaStub
    ld b, $0a

KernelEntry_copyOamDmaStub::
    ld a, [hl+]
    ldh [c], a
    inc c
    dec b
    jr nz, KernelEntry_copyOamDmaStub

    ld bc, VBlankCallback
    call RegisterVBlankCallback
    ld bc, SerialCallback
    call RegisterSerialCallback
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
    call main

; [ezgb]
; crt0 ends here: main() returned; stage1 never gets here in practice (LoadKernel calls the kernel).

HaltLoop::
    halt
    jr HaltLoop

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
    jp EnterGfxMode2


    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

SetGfxMode::
    ld a, l
    ld [$c4ad], a
    and $03
    ld l, a
    ld bc, $01e2
    sla l
    sla l
    add hl, bc
    jp hl


RemoveVBlankCallback::
    ld hl, $c4b6
    jp RemoveCallbackSlot


RemoveLcdCallback::
    ld hl, $c4c6
    jp RemoveCallbackSlot


RemoveTimerCallback::
    ld hl, $c4d6
    jp RemoveCallbackSlot


RemoveSerialCallback::
    ld hl, $c4e6
    jp RemoveCallbackSlot


RemoveJoypadCallback::
    ld hl, $c4f6
    jp RemoveCallbackSlot


RegisterVBlankCallback::
    ld hl, $c4b6
    jp InstallCallbackSlot


RegisterLcdCallback::
    ld hl, $c4c6
    jp InstallCallbackSlot


RegisterTimerCallback::
    ld hl, $c4d6
    jp InstallCallbackSlot


RegisterSerialCallback::
    ld hl, $c4e6
    jp InstallCallbackSlot


RegisterJoypadCallback::
    ld hl, $c4f6
    jp InstallCallbackSlot


RemoveCallbackSlot::
    ld a, [hl+]
    ld e, a
    ld d, [hl]
    or d
    ret z

    ld a, e
    cp c
    jr nz, RemoveCallbackSlot

    ld a, d
    cp b
    jr nz, RemoveCallbackSlot

    xor a
    ld [hl-], a
    ld [hl], a
    inc a
    ld d, h
    ld e, l
    dec de
    inc hl

RemoveCallbackSlot_compactTail::
    ld a, [hl+]
    ld [de], a
    ld b, a
    inc de
    ld a, [hl+]
    ld [de], a
    inc de
    or b
    ret z

    jr RemoveCallbackSlot_compactTail

InstallCallbackSlot::
    ld a, [hl+]
    or [hl]
    jr z, InstallCallbackSlot_storeFree

    inc hl
    jr InstallCallbackSlot

InstallCallbackSlot_storeFree::
    ld [hl], b
    dec hl
    ld [hl], c
    ret


VBlankCallback::
    ld hl, $c4b4
    inc [hl]
    jr nz, VBlankCallback_oamDmaFlag

    inc hl
    inc [hl]

VBlankCallback_oamDmaFlag::
    call $ff80
    ld a, $01
    ld [$c4b1], a
    ret


WaitVBlankFlag::
    ldh a, [rLCDC]
    add a
    ret nc

    xor a
    di
    ld [$c4b1], a
    ei

WaitVBlankFlag_haltLoop::
    halt
    nop
    ld a, [$c4b1]
    or a
    jr z, WaitVBlankFlag_haltLoop

    xor a
    ld [$c4b1], a
    ret


LcdOff::
    ldh a, [rLCDC]
    add a
    ret nc

LcdOff_waitLyHigh::
    ldh a, [rLY]
    cp $92
    jr nc, LcdOff_waitLyHigh

LcdOff_waitLyLow::
    ldh a, [rLY]
    cp $91
    jr c, LcdOff_waitLyLow

    ldh a, [rLCDC]
    and $7f
    ldh [rLCDC], a
    ret


OamDmaStub::
    ld a, $c0
    ldh [rDMA], a
    ld a, $28

OamDmaStub_delayLoop::
    dec a
    jr nz, OamDmaStub_delayLoop

    ret


SerialCallback::
    ld a, [$c4b0]
    cp $02
    jr nz, SerialCallback_ifState1

    ldh a, [rSB]
    ld [$c4af], a
    ld a, $00
    jr SerialCallback_clearState

SerialCallback_ifState1::
    cp $01
    jr nz, SerialCallback_rearmSc

    ldh a, [rSB]
    cp $55
    jr z, SerialCallback_clearState

    ld a, $04
    jr SerialCallback_storeState

SerialCallback_clearState::
    ld a, $00

SerialCallback_storeState::
    ld [$c4b0], a
    xor a
    ldh [rSC], a
    ld a, $66
    ldh [rSB], a

SerialCallback_rearmSc::
    ld a, $80
    ldh [rSC], a
    ret


SetGfxModeStack::
    ld hl, sp+$02
    ld l, [hl]
    ld h, $00
    call SetGfxMode
    ret


GetGfxMode::
    ld hl, $c4ad
    ld e, [hl]
    ret


DiNest::
    di
    ld a, [$c4b3]
    inc a
    ld [$c4b3], a
    ret


EiNest::
    ld a, [$c4b3]
    dec a
    ld [$c4b3], a
    ret nz

    ei
    ret


SetIeReg::
    call DiNest
    ld hl, sp+$02
    xor a
    ldh [rIF], a
    ld a, [hl]
    ldh [rIE], a
    call EiNest
    ret


RemoveVBlankCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RemoveVBlankCallback
    pop bc
    ret


RemoveLcdCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RemoveLcdCallback
    pop bc
    ret


RemoveTimerCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RemoveTimerCallback
    pop bc
    ret


RemoveSerialCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RemoveSerialCallback
    pop bc
    ret


RemoveJoypadCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RemoveJoypadCallback
    pop bc
    ret


RegisterVBlankCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RegisterVBlankCallback
    pop bc
    ret


RegisterLcdCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RegisterLcdCallback
    pop bc
    ret


RegisterTimerCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RegisterTimerCallback
    pop bc
    ret


RegisterSerialCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RegisterSerialCallback
    pop bc
    ret


RegisterJoypadCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RegisterJoypadCallback
    pop bc
    ret


FarCallTrampoline::
    call DiNest
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
    call EiNest
    ld hl, $05ae
    push hl
    ld l, e
    ld h, d
    jp hl


    call DiNest
    pop af
    ld [$2000], a
    ld [$c4b2], a
    call EiNest
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
    call putchar
    add sp, $01
    jp Jump_000_05c5


Jump_000_05e1:
    ld a, $0a
    push af
    inc sp
    call putchar
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
    call Call_000_27c9
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
    call Call_000_27b5
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
    call Call_000_3952
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
    call delay
    add sp, $02
    ret


; [ezgb]
; FpgaSetMode(m): FPGA register write $7FC0 = m. Every FPGA register write is the unlock
; sequence $7F00=$E1, $7F10=$E2, $7F20=$E3, then the register, then $7FF0=$E4 (same as the kernel).
; main() sets 0 before mounting the SD card and 2 just before handing the load command over.

FpgaSetMode::
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

; [ezgb]
; BootRomDirect / RunFromWram / PrintBlankLines: unreferenced (dead) user code.

BootRomDirect::
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


RunFromWram::
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
    call Memcpy
    add sp, $06
    call $d000
    ret


    ld hl, $07ef
    push hl
    call puts
    add sp, $02
    ld hl, $07ef
    push hl
    call puts
    add sp, $02
    ld hl, $07ef
    push hl
    call puts
    add sp, $02
    ld hl, $07ef
    push hl
    call puts
    add sp, $02
    ld hl, $07ef
    push hl
    call puts
    add sp, $02
    ld hl, $07ef
    push hl
    call puts
    add sp, $02
    ld hl, $07ef
    push hl
    call puts
    add sp, $02
    ld hl, $07ef
    push hl
    call puts
    add sp, $02
    ret


    jr nz, main

; [ezgb]
; main(): print EZ-FLASH, delay(700), LOADING; pf_mount; pf_open("EZGB.DAT"); OSINIT;
; build the 512-byte load command at $C0A0 from the file's cluster chain; LoadKernel($C0A0).
; Load command: +$000 = 0, then {u32 lba, u32 end} extents, one per contiguous cluster run;
; end = running total of file sectors (not a count); last end $FFFFFFFF, then 0;
; +$1F0 file size in bytes; +$1F4 = 1;
; +$1F8 sectors per cluster. Room for 61 extents + terminator before +$1F0, and nothing
; checks: a more fragmented EZGB.DAT corrupts the tail, then $C2A0+ (messages, FATFS pointer).

main::
    add sp, -$5a
    ld hl, MsgTopMargin
    push hl
    call puts
    add sp, $02
    ld hl, MsgEzFlash
    push hl
    call puts
    add sp, $02
    ld hl, $02bc
    push hl
    call delay
    add sp, $02
    ld hl, MsgLoading
    push hl
    call puts
    add sp, $02
    ld a, $00
    push af
    inc sp
    call FpgaSetMode
    add sp, $01
    ld hl, sp+$30
    ld c, l
    ld b, h
    push bc
    call pf_mount
    add sp, $02
    ld c, e
    xor a
    or c
    jp z, main_openKernel

    ld hl, $c2a6
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call puts
    add sp, $02

main_sdErrorHang::
    jp main_sdErrorHang


; [ezgb]
; pf_open(KernelFileName). KernelFileName at $0B4D is the only place the kernel's name lives.

main_openKernel::
    ld hl, KernelFileName
    push hl
    call pf_open
    add sp, $02
    ld b, e
    ld c, b
    xor a
    or c
    jp z, main_buildLoadCmd

    ld hl, $c2a0
    ld hl, $c2a0
    ld c, [hl]
    ld hl, $c2a1
    ld b, [hl]
    push bc
    call puts
    add sp, $02
    ld hl, $c2a2
    ld hl, $c2a2
    ld c, [hl]
    ld hl, $c2a3
    ld b, [hl]
    push bc
    call puts
    add sp, $02
    ld hl, $c2a4
    ld hl, $c2a4
    ld c, [hl]
    ld hl, $c2a5
    ld b, [hl]
    push bc
    call puts
    add sp, $02

main_notFoundHang::
    jp main_notFoundHang


; [ezgb]
; End marker: FAT16 (FsType()==2) $0000FFFF, else (FAT32) $0FFFFFF7. FAT12 is not handled.

main_buildLoadCmd::
    ld hl, MsgOsinit
    push hl
    call puts
    add sp, $02
    call FsType
    ld c, e
    ld a, c
    sub $02
    jp nz, Jump_000_089a

    jr jr_000_089d

Jump_000_089a:
    jp Jump_000_08ad


jr_000_089d:
    ld hl, sp+$0e
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp Jump_000_08ba


Jump_000_08ad:
    ld hl, sp+$0e
    ld [hl], $f7
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $0f

Jump_000_08ba:
    call FsFileCluster
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
    call FsFileSize
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
    call clust2sect
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

main_extentLoop::
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
    call FsNextCluster
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
    jr nz, jr_000_098a

    inc hl
    inc [hl]

jr_000_098a:
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
    jp nz, Jump_000_09d0

    ld hl, sp+$17
    ld a, [hl]
    ld hl, sp+$05
    sub [hl]
    jp nz, Jump_000_09d0

    ld hl, sp+$18
    ld a, [hl]
    ld hl, sp+$06
    sub [hl]
    jp nz, Jump_000_09d0

    ld hl, sp+$19
    ld a, [hl]
    ld hl, sp+$07
    sub [hl]
    jp z, Jump_000_0a53

Jump_000_09d0:
    call FsClusterSectors
    ld c, e
    ld b, $00
    push bc
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call S16Mul
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
    call clust2sect
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

Jump_000_0a53:
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
    jp c, main_extentLoop

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
    call FsClusterSectors
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
    call FpgaSetMode
    add sp, $01
    call DiNest
    ld hl, $c0a0
    push hl
    call FarCallTrampoline

    db $ff, $40, $01, $00

    add sp, $02
    add sp, $5a
    ret


KernelFileName::
    db $45, $5a, $47, $42, $2e, $44, $41, $54, $00

MsgTopMargin::
    db $20, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $00

MsgEzFlash::
    db $20, $20, $20, $20, $20, $20, $45, $5a, $2d, $46, $4c, $41, $53, $48, $00

MsgLoading::
    db $0a, $0a, $0a, $0a, $4c, $4f, $41, $44, $49, $4e, $47, $2e, $2e, $2e, $00

MsgOsinit::
    db $4f, $53, $49, $4e, $49, $54, $2e, $2e, $2e, $00

MsgNotFound1::
    db $65, $7a, $67, $62, $2e, $64, $61, $74, $20, $6e, $6f, $74, $20, $66, $6f, $75
    db $6e, $64, $20, $20, $6f, $6e, $20, $53, $44, $20, $63, $61, $72, $64, $00

MsgNotFound2::
    db $50, $6c, $65, $61, $73, $65, $20, $64, $6f, $77, $6e, $6c, $6f, $61, $64, $20
    db $69, $74, $20, $00

MsgNotFound3::
    db $66, $72, $6f, $6d, $20, $77, $77, $77, $2e, $65, $7a, $66, $6c, $61, $73, $68
    db $2e, $63, $6e, $00

MsgSdError::
    db $4d, $69, $63, $72, $6f, $20, $53, $44, $20, $69, $6e, $69, $74, $69, $61, $6c
    db $20, $65, $72, $72, $6f, $72, $21, $00

disk_initialize::
    ld e, $00
    ret


; [ezgb]
; disk_readp(buf, lba, ofs, count): Petit FatFs disk hook, far call to disk_readp_impl.

disk_readp::
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
    call FarCallTrampoline

    db $0a, $25, $ff, $ff

    add sp, $0a
    ld e, $00
    ret


    ld e, $00
    ret


ld_word::
    push af
    push af
    ld hl, sp+$06
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, [bc]
    ld c, a
    ld hl, sp+$02
    ld [hl], c
    inc hl
    ld [hl], $00
    dec hl
    ld a, [hl]
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
    ld [hl], b
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $04
    ret


ld_dword::
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
    call Call_000_28d5
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
    call Call_000_28d5
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
    call Call_000_28d5
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


mem_set::
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

mem_set_loop::
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
    jp z, Jump_000_0dd1

    ld hl, sp+$08
    ld a, [hl]
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_000_0dce

    inc hl
    inc [hl]

jr_000_0dce:
    jp mem_set_loop


Jump_000_0dd1:
    add sp, $04
    ret


mem_cmp::
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

Jump_000_0df7:
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
    jp z, Jump_000_0e46

    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    dec hl
    inc [hl]
    jr nz, jr_000_0e17

    inc hl
    inc [hl]

jr_000_0e17:
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
    jr nz, jr_000_0e2c

    inc hl
    inc [hl]

jr_000_0e2c:
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
    jp z, Jump_000_0df7

Jump_000_0e46:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $0a
    ret


get_fat::
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
    jp c, Jump_000_0ea1

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
    jp c, Jump_000_0eaa

Jump_000_0ea1:
    ld de, $0001
    ld hl, $0000
    jp Jump_000_1043


Jump_000_0eaa:
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $02
    jp z, Jump_000_0ebf

    ld a, c
    sub $03
    jp z, Jump_000_0f74

    jp Jump_000_103d


Jump_000_0ebf:
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
    call Call_000_289b
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
    call disk_readp
    add sp, $0a
    ld c, e
    xor a
    or c
    jp nz, Jump_000_103d

    ld hl, sp+$0e
    ld c, l
    ld b, h
    push bc
    call ld_word
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
    jp Jump_000_1043


Jump_000_0f74:
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
    jr jr_000_0f8f

jr_000_0f88:
    ld hl, sp+$00
    sla [hl]
    inc hl
    rl [hl]

jr_000_0f8f:
    dec a
    jr nz, jr_000_0f88

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
    call Call_000_289b
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
    call disk_readp
    add sp, $0a
    ld c, e
    xor a
    or c
    jp nz, Jump_000_103d

    ld hl, sp+$0e
    ld c, l
    ld b, h
    push bc
    call ld_dword
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
    jp Jump_000_1043


Jump_000_103d:
    ld de, $0001
    ld hl, $0000

Jump_000_1043:
    add sp, $12
    ret


clust2sect::
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
    jp c, Jump_000_10ca

    ld de, $0000
    ld hl, $0000
    jp Jump_000_1147


Jump_000_10ca:
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
    call Call_000_2732
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

Jump_000_1147:
    add sp, $0a
    ret


get_clust::
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
    jp nz, Jump_000_1167

    jr jr_000_116a

Jump_000_1167:
    jp Jump_000_11b8


jr_000_116a:
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0014
    add hl, de
    ld c, l
    ld b, h
    push bc
    call ld_word
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
    call Call_000_28d5
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

Jump_000_11b8:
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $001a
    add hl, de
    ld c, l
    ld b, h
    push bc
    call ld_word
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


dir_rewind::
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
    jp nz, Jump_000_1253

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_000_1253

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_000_1253

    inc hl
    ld a, [hl]
    or a
    jp z, Jump_000_1284

Jump_000_1253:
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
    jp c, Jump_000_1289

Jump_000_1284:
    ld e, $01
    jp Jump_000_1362


Jump_000_1289:
    ld hl, sp+$08
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_000_12d0

    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $03
    jp nz, Jump_000_12a2

    jr jr_000_12a5

Jump_000_12a2:
    jp Jump_000_12d0


jr_000_12a5:
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

Jump_000_12d0:
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
    jp nz, Jump_000_130b

    ld c, a
    jp Jump_000_130d


Jump_000_130b:
    ld c, $01

Jump_000_130d:
    xor a
    or c
    jp z, Jump_000_1331

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
    call clust2sect
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
    jp Jump_000_134b


Jump_000_1331:
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

Jump_000_134b:
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

Jump_000_1362:
    add sp, $0c
    ret


dir_next::
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
    jp z, Jump_000_13bb

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
    jp nz, Jump_000_13c0

Jump_000_13bb:
    ld e, $03
    jp Jump_000_1532


Jump_000_13c0:
    ld hl, sp+$0e
    ld a, [hl]
    and $0f
    jr nz, jr_000_13ca

    jp Jump_000_13cd


jr_000_13ca:
    jp Jump_000_1523


Jump_000_13cd:
    ld hl, sp+$06
    inc [hl]
    jr nz, jr_000_13dc

    inc hl
    inc [hl]
    jr nz, jr_000_13dc

    inc hl
    inc [hl]
    jr nz, jr_000_13dc

    inc hl
    inc [hl]

jr_000_13dc:
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
    jp nz, Jump_000_1438

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
    jp c, Jump_000_1523

    ld e, $03
    jp Jump_000_1532


Jump_000_1438:
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
    jp nz, Jump_000_1523

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
    call get_fat
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
    jp c, Jump_000_14a9

    ld e, $01
    jp Jump_000_1532


Jump_000_14a9:
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
    jp c, Jump_000_14df

    ld e, $03
    jp Jump_000_1532


Jump_000_14df:
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
    call clust2sect
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

Jump_000_1523:
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

Jump_000_1532:
    add sp, $14
    ret


dir_find::
    add sp, -$0b
    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call dir_rewind
    add sp, $02
    ld c, e
    ld hl, sp+$0a
    ld [hl], c
    xor a
    or [hl]
    jp z, Jump_000_154f

    ld e, [hl]
    jp Jump_000_163f


Jump_000_154f:
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

Jump_000_1565:
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
    call disk_readp
    add sp, $0a
    ld b, e
    xor a
    or b
    jp z, Jump_000_15c2

    ld b, $01
    jp Jump_000_15c4


Jump_000_15c2:
    ld b, $00

Jump_000_15c4:
    ld hl, sp+$0a
    ld [hl], b
    xor a
    or [hl]
    jp nz, Jump_000_163c

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
    jp nz, Jump_000_15e5

    ld hl, sp+$0a
    ld [hl], $03
    jp Jump_000_163c


Jump_000_15e5:
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
    jr nz, jr_000_15f9

    jp Jump_000_15fc


jr_000_15f9:
    jp Jump_000_1628


Jump_000_15fc:
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
    call mem_cmp
    add sp, $06
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, Jump_000_163c

Jump_000_1628:
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call dir_next
    add sp, $02
    ld c, e
    ld hl, sp+$0a
    ld [hl], c
    xor a
    or [hl]
    jp z, Jump_000_1565

Jump_000_163c:
    ld hl, sp+$0a
    ld e, [hl]

Jump_000_163f:
    add sp, $0b
    ret


create_name::
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
    call mem_set
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

Jump_000_168a:
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
    jp z, Jump_000_1700

    ld a, b
    sub $2f
    jp z, Jump_000_1700

    ld a, b
    sub $2e
    jp nz, Jump_000_16b9

    ld a, $01
    jr jr_000_16ba

Jump_000_16b9:
    xor a

jr_000_16ba:
    ld c, a
    or a
    jp nz, Jump_000_16c7

    ld hl, sp+$08
    ld a, [hl+]
    inc hl
    sub [hl]
    jp c, Jump_000_16e4

Jump_000_16c7:
    ld hl, sp+$0a
    ld a, [hl]
    sub $08
    jp nz, Jump_000_16d1

    jr jr_000_16d4

Jump_000_16d1:
    jp Jump_000_1700


jr_000_16d4:
    xor a
    or c
    jp z, Jump_000_1700

    ld hl, sp+$08
    ld [hl], $08
    inc hl
    inc hl
    ld [hl], $0b
    jp Jump_000_168a


Jump_000_16e4:
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
    jp Jump_000_168a


Jump_000_1700:
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
    jp z, Jump_000_1739

    ld c, $01
    jp Jump_000_173b


Jump_000_1739:
    ld c, $00

Jump_000_173b:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    ld e, $00
    add sp, $0b
    ret


follow_path::
    add sp, -$0e
    ld hl, sp+$14
    ld c, [hl]
    inc hl
    ld b, [hl]

Jump_000_174e:
    ld a, [bc]
    ld hl, sp+$0c
    ld [hl], a
    sub $20
    jp nz, Jump_000_1759

    jr jr_000_175c

Jump_000_1759:
    jp Jump_000_1765


jr_000_175c:
    inc bc
    ld hl, sp+$14
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_000_174e


Jump_000_1765:
    ld hl, sp+$14
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$0c
    ld a, [hl]
    sub $2f
    jp nz, Jump_000_1774

    jr jr_000_1777

Jump_000_1774:
    jp Jump_000_1781


jr_000_1777:
    ld hl, $0001
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$14
    ld [hl+], a
    ld [hl], d

Jump_000_1781:
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
    jp nc, Jump_000_17d0

    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call dir_rewind
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
    jp Jump_000_187c


Jump_000_17d0:
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

Jump_000_17ee:
    ld hl, sp+$14
    ld c, l
    ld b, h
    push bc
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call create_name
    add sp, $04
    ld c, e
    ld hl, sp+$0d
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_000_187c

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
    call dir_find
    add sp, $04
    ld c, e
    ld hl, sp+$0d
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_000_187c

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
    jp nz, Jump_000_187c

    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $10
    jr nz, jr_000_1844

    jp Jump_000_1847


jr_000_1844:
    jp Jump_000_184e


Jump_000_1847:
    ld hl, sp+$0d
    ld [hl], $03
    jp Jump_000_187c


Jump_000_184e:
    ld hl, sp+$12
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call get_clust
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
    jp Jump_000_17ee


Jump_000_187c:
    ld hl, sp+$0d
    ld e, [hl]
    add sp, $0e
    ret


check_fs::
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
    call disk_readp
    add sp, $0a
    ld c, e
    xor a
    or c
    jp z, Jump_000_18ac

    ld e, $03
    jp Jump_000_195a


Jump_000_18ac:
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call ld_word
    add sp, $02
    ld b, d
    ld c, e
    ld a, c
    sub $55
    jp nz, Jump_000_18c5

    ld a, b
    sub $aa
    jp z, Jump_000_18ca

Jump_000_18c5:
    ld e, $02
    jp Jump_000_195a


Jump_000_18ca:
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
    call disk_readp
    add sp, $0a
    ld c, e
    xor a
    or c
    jp nz, Jump_000_1911

    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call ld_word
    add sp, $02
    ld b, d
    ld c, e
    ld a, c
    sub $46
    jp nz, Jump_000_1909

    ld a, b
    sub $41
    jp nz, Jump_000_1909

    jr jr_000_190c

Jump_000_1909:
    jp Jump_000_1911


jr_000_190c:
    ld e, $00
    jp Jump_000_195a


Jump_000_1911:
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
    call disk_readp
    add sp, $0a
    ld c, e
    xor a
    or c
    jp nz, Jump_000_1958

    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call ld_word
    add sp, $02
    ld b, d
    ld c, e
    ld a, c
    sub $46
    jp nz, Jump_000_1950

    ld a, b
    sub $41
    jp nz, Jump_000_1950

    jr jr_000_1953

Jump_000_1950:
    jp Jump_000_1958


jr_000_1953:
    ld e, $00
    jp Jump_000_195a


Jump_000_1958:
    ld e, $01

Jump_000_195a:
    ret


pf_mount::
    add sp, -$4d
    ld hl, $c2a8
    ld [hl], $00
    ld hl, $c2a9
    ld [hl], $00
    call disk_initialize
    ld c, e
    ld a, c
    and $01
    jr nz, jr_000_1973

    jp Jump_000_1978


jr_000_1973:
    ld e, $02
    jp Jump_000_1eeb


Jump_000_1978:
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
    call check_fs
    add sp, $06
    ld c, e
    ld hl, sp+$4c
    ld [hl], c
    ld a, [hl]
    sub $01
    jp nz, Jump_000_199d

    jr jr_000_19a0

Jump_000_199d:
    jp Jump_000_1a26


jr_000_19a0:
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
    call disk_readp
    add sp, $0a
    ld c, e
    xor a
    or c
    jp z, Jump_000_19c7

    ld hl, sp+$4c
    ld [hl], $03
    jp Jump_000_1a26


Jump_000_19c7:
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
    jp z, Jump_000_1a26

    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0008
    add hl, de
    ld c, l
    ld b, h
    push bc
    call ld_dword
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
    call check_fs
    add sp, $06
    ld c, e
    ld hl, sp+$4c
    ld [hl], c

Jump_000_1a26:
    ld hl, sp+$4c
    ld a, [hl]
    sub $03
    jp nz, Jump_000_1a30

    jr jr_000_1a33

Jump_000_1a30:
    jp Jump_000_1a38


jr_000_1a33:
    ld e, $01
    jp Jump_000_1eeb


Jump_000_1a38:
    xor a
    ld hl, sp+$4c
    or [hl]
    jp z, Jump_000_1a44

    ld e, $06
    jp Jump_000_1eeb


Jump_000_1a44:
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
    call disk_readp
    add sp, $0a
    ld c, e
    xor a
    or c
    jp z, Jump_000_1a6c

    ld e, $01
    jp Jump_000_1eeb


Jump_000_1a6c:
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
    call ld_word
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
    jp nz, Jump_000_1ac9

    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0017
    add hl, de
    ld c, l
    ld b, h
    push bc
    call ld_dword
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

Jump_000_1ac9:
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
    call Call_000_2732
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
    call ld_word
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
    call ld_word
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
    call ld_word
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
    jp nz, Jump_000_1c1b

    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0013
    add hl, de
    ld c, l
    ld b, h
    push bc
    call ld_dword
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

Jump_000_1c1b:
    ld hl, sp+$12
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    push bc
    call ld_word
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
    call U32Mod
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
    jp c, Jump_000_1d65

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
    jp nc, Jump_000_1d65

    ld hl, sp+$4c
    ld [hl], $02

Jump_000_1d65:
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
    jp c, Jump_000_1d7d

    ld hl, sp+$4c
    ld [hl], $03

Jump_000_1d7d:
    xor a
    ld hl, sp+$4c
    or [hl]
    jp nz, Jump_000_1d89

    ld e, $06
    jp Jump_000_1eeb


Jump_000_1d89:
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$4c
    ld a, [hl]
    ld [de], a
    ld a, [hl]
    sub $03
    jp nz, Jump_000_1d9a

    jr jr_000_1d9d

Jump_000_1d9a:
    jp Jump_000_1de0


jr_000_1d9d:
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
    call ld_dword
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
    jp Jump_000_1e33


Jump_000_1de0:
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

Jump_000_1e33:
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

Jump_000_1eeb:
    add sp, $4d
    ret


pf_open::
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
    jp nz, Jump_000_1f07

    ld e, $05
    jp Jump_000_2015


Jump_000_1f07:
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
    call follow_path
    add sp, $06
    ld c, e
    xor a
    or c
    jp z, Jump_000_1f54

    ld e, c
    jp Jump_000_2015


Jump_000_1f54:
    ld hl, sp+$0e
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    or a
    jp z, Jump_000_1f75

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
    jr nz, jr_000_1f75

    jp Jump_000_1f7a


Jump_000_1f75:
jr_000_1f75:
    ld e, $03
    jp Jump_000_2015


Jump_000_1f7a:
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
    call get_clust
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
    call ld_dword
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

Jump_000_2015:
    add sp, $4a
    ret


; [ezgb]
; pf_read: linked but never called (1061 bytes of dead code).

pf_read::
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
    jp nz, Jump_000_204e

    ld e, $05
    jp Jump_000_243a


Jump_000_204e:
    ld hl, sp+$1e
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, [bc]
    ld c, a
    and $01
    jr nz, jr_000_205d

    jp Jump_000_2060


jr_000_205d:
    jp Jump_000_2065


Jump_000_2060:
    ld e, $04
    jp Jump_000_243a


Jump_000_2065:
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
    jp nc, Jump_000_20f1

    ld hl, sp+$25
    ld a, [hl]
    ld hl, sp+$35
    ld [hl], a
    ld hl, sp+$26
    ld a, [hl]
    ld hl, sp+$36
    ld [hl], a

Jump_000_20f1:
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

Jump_000_213a:
    ld hl, sp+$35
    ld a, [hl+]
    or [hl]
    jp z, Jump_000_2438

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
    jr nz, jr_000_2162

    inc hl
    ld a, [hl]
    and $01
    jr nz, jr_000_2162

    jp Jump_000_2165


jr_000_2162:
    jp Jump_000_22ed


Jump_000_2165:
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
    call Call_000_289b
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
    jp nz, Jump_000_225d

    ld hl, sp+$0a
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_000_21e1

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
    jp Jump_000_221e


Jump_000_21e1:
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
    call get_fat
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

Jump_000_221e:
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
    jp c, Jump_000_2240

    ld hl, sp+$1e
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, $00
    ld [bc], a
    ld e, $01
    jp Jump_000_243a


Jump_000_2240:
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

Jump_000_225d:
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
    call clust2sect
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
    jp nz, Jump_000_22a2

    ld hl, sp+$1e
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, $00
    ld [bc], a
    ld e, $01
    jp Jump_000_243a


Jump_000_22a2:
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

Jump_000_22ed:
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
    jp nc, Jump_000_2335

    ld hl, sp+$35
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$23
    ld [hl+], a
    ld [hl], e

Jump_000_2335:
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
    call disk_readp
    add sp, $0a
    ld c, e
    ld a, c
    or a
    jp z, Jump_000_2393

    ld hl, sp+$1e
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, $00
    ld [bc], a
    ld e, $01
    jp Jump_000_243a


Jump_000_2393:
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
    jp z, Jump_000_213a

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
    jp Jump_000_213a


Jump_000_2438:
    ld e, $00

Jump_000_243a:
    add sp, $31
    ret


FsFileSize::
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


FsType::
    ld hl, $c2a8
    ld hl, $c2a8
    ld c, [hl]
    ld hl, $c2a9
    ld b, [hl]
    ld a, [bc]
    ld c, a
    ld e, c
    ret


FsFileCluster::
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


FsNextCluster::
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
    call get_fat
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


FsClusterSectors::
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


; [ezgb]
; FpgaSetSdWindow(m): FPGA register $7F30 = m (1 = SD sector window at $A000).

FpgaSetSdWindow::
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


SdWindowStatus::
    ld de, $a000
    ld a, [de]
    ld c, a
    ld e, c
    ret


disk_readp_impl::
    push af
    ld hl, sp+$0e
    ld a, [hl]
    or a
    jp nz, Jump_000_251b

    inc hl
    ld a, [hl]
    sub $02
    jp nz, Jump_000_251b

    jr jr_000_251e

Jump_000_251b:
    jp Jump_000_2540


jr_000_251e:
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
    call FarCallTrampoline

    db $86, $25, $ff, $ff

    add sp, $07
    jp Jump_000_2583


Jump_000_2540:
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
    call FarCallTrampoline

    db $86, $25, $ff, $ff

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
    call Memcpy
    add sp, $06

Jump_000_2583:
    add sp, $02
    ret


; [ezgb]
; DiskRead(lba, buf, n): up to 4 sectors per request; LBA bytes go to the FPGA from $7FB0,
; then the sector window at $A000 is polled and copied. Same routine as the kernel's DiskRead_B2.

DiskRead::
    add sp, -$13
    ld a, $01
    push af
    inc sp
    call FpgaSetSdWindow
    add sp, $01
    ld hl, sp+$12
    ld [hl], $00

DiskRead_chunkLoop::
    ld hl, sp+$12
    ld a, [hl]
    ld hl, sp+$1d
    sub [hl]
    jp nc, Jump_000_2726

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
    jp nc, DiskRead_remChunk

    ld bc, $0004
    jp DiskRead_issueLba


DiskRead_remChunk::
    ld hl, sp+$1d
    ld a, [hl]
    ld hl, sp+$12
    sub [hl]
    ld hl, sp+$0e
    ld [hl], a
    ld c, a
    ld b, $00

DiskRead_issueLba::
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
    call Call_000_289b
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
    call Call_000_289b
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
    call Call_000_289b
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
    call FpgaSetSdWindow
    add sp, $01

DiskRead_waitPeek::
    call SdWindowStatus
    ld c, e
    ld b, $00
    ld a, c
    sub $e1
    jp nz, DiskRead_copyWindow

    or b
    jp z, DiskRead_waitPeek

DiskRead_copyWindow::
    ld a, $01
    push af
    inc sp
    call FpgaSetSdWindow
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
    call VramCopyStack
    add sp, $06
    ld hl, sp+$12
    inc [hl]
    inc [hl]
    inc [hl]
    inc [hl]
    jp DiskRead_chunkLoop


Jump_000_2726:
    ld a, $00
    push af
    inc sp
    call FpgaSetSdWindow
    add sp, $01
    add sp, $13
    ret


Call_000_2732:
    jp U32MulImpl


    jp Jump_000_2949


    jp Jump_000_29c2


    jp Jump_000_2a73


U32Mod::
    jp Jump_000_2b47


    ld a, $05
    rst RST_08
    jp S16Mul


    ld a, $05
    rst RST_08
    jp Jump_000_27b5


    ld a, $05
    rst RST_08
    jp Jump_000_27f5


    ld a, $05
    rst RST_08
    jp S8Mul


    ld a, $05
    rst RST_08
    jp Jump_000_279b


    ld a, $05
    rst RST_08
    jp Jump_000_2afc


    ld a, $05
    rst RST_08
    jp Jump_000_27db


    ld a, $05
    rst RST_08
    jp Jump_000_27a9


    ld a, $05
    rst RST_08
    jp Jump_000_27e9


    ld a, $05
    rst RST_08
    jp Jump_000_27c9


    ld a, $05
    rst RST_08
    jp Jump_000_2809


    ld a, $05
    rst RST_08
    jp Jump_000_289b


    ld a, $05
    rst RST_08
    jp Jump_000_28b8


    ld a, $05
    rst RST_08
    jp Jump_000_28d5


    ld a, $05
    rst RST_08
    jp Jump_000_28d5


Jump_000_279b:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_281b
    ld e, c
    ld d, b
    ret


Jump_000_27a9:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_281b
    ret


Call_000_27b5:
Jump_000_27b5:
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
    call S16DivMod
    ld e, c
    ld d, b
    ret


Call_000_27c9:
Jump_000_27c9:
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
    call S16DivMod
    ret


Jump_000_27db:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_2855
    ld e, c
    ld d, b
    ret


Jump_000_27e9:
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call Call_000_2855
    ret


Jump_000_27f5:
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
    call U16DivMod
    ld e, c
    ld d, b
    ret


Jump_000_2809:
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
    call U16DivMod
    ret


Call_000_281b:
    ld a, c
    rlca
    sbc a
    ld b, a
    ld a, e
    rlca
    sbc a
    ld d, a

S16DivMod::
    ld a, b
    push af
    xor d
    push af
    bit 7, d
    jr z, S16DivMod_absDividend

    sub a
    sub e
    ld e, a
    sbc a
    sub d
    ld d, a

S16DivMod_absDividend::
    bit 7, b
    jr z, S16DivMod_u16Div

    sub a
    sub c
    ld c, a
    sbc a
    sub b
    ld b, a

S16DivMod_u16Div::
    call U16DivMod
    ret c

    pop af
    and $80
    jr z, S16DivMod_restoreSigns

    sub a
    sub c
    ld c, a
    sbc a
    sub b
    ld b, a

S16DivMod_restoreSigns::
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


Call_000_2855:
    ld b, $00
    ld d, b

U16DivMod::
    ld a, e
    or d
    jr nz, jr_000_2863

    ld bc, $0000
    ld d, b
    ld e, c
    scf
    ret


jr_000_2863:
    ld l, c
    ld h, b
    ld bc, $0000
    or a
    ld a, $10

U16DivMod_shiftLoop::
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
    jr c, jr_000_2881

    pop bc
    jr jr_000_2883

jr_000_2881:
    inc sp
    inc sp

jr_000_2883:
    jr c, jr_000_288c

    pop af
    dec a
    or a
    jr nz, U16DivMod_shiftLoop

    jr U16DivMod_finish

jr_000_288c:
    pop af
    dec a
    scf
    jr nz, U16DivMod_shiftLoop

U16DivMod_finish::
    ld d, b
    ld e, c
    rl l
    ld c, l
    rl h
    ld b, h
    or a
    ret


Call_000_289b:
Jump_000_289b:
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

U32Shr_shiftLoop::
    or a
    ret z

    rr h
    rr l
    rr d
    rr e
    dec a
    jp U32Shr_shiftLoop


Jump_000_28b8:
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

S32Sar_shiftLoop::
    or a
    ret z

    sra h
    rr l
    rr d
    rr e
    dec a
    jp S32Sar_shiftLoop


Call_000_28d5:
Jump_000_28d5:
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

U32Shl_shiftLoop::
    or a
    ret z

    rl e
    rl d
    rl l
    rl h
    dec a
    jp U32Shl_shiftLoop


putchar::
    push bc
    ld hl, sp+$04
    ld a, [hl]
    call PrintChar
    pop bc
    ret


    push bc
    ld hl, sp+$04
    ld a, [hl]
    call PutBgTile
    pop bc
    ret


SetTileCursor::
    ld hl, sp+$02
    ld a, [hl+]
    ld [$c51c], a
    ld a, [hl]
    ld [$c51d], a
    ret


    ld a, [$c4ad]
    and $02
    jr nz, jr_000_291b

    push bc
    call EnterGfxMode2
    pop bc

jr_000_291b:
    ld a, [$c51c]
    ld e, a
    ret


    ld a, [$c4ad]
    and $02
    jr nz, jr_000_292c

    push bc
    call EnterGfxMode2
    pop bc

jr_000_292c:
    ld a, [$c51d]
    ld e, a
    ret


VBlankCb_Bg8000::
    ldh a, [rLCDC]
    or $10
    ldh [rLCDC], a
    ld a, $48
    ldh [rLYC], a
    ret


LycCb_Bg8800::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, LycCb_Bg8800

    ldh a, [rLCDC]
    and $ef
    ldh [rLCDC], a
    ret


Jump_000_2949:
    add sp, -$09
    ld b, $04
    ld hl, sp+$0b
    call MemIsZero
    jr nz, jr_000_295c

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_29bf


jr_000_295c:
    ld hl, sp+$0f
    call MemIsZero
    jr nz, jr_000_2972

    ld a, $21
    ld [$c4aa], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_29bf


jr_000_2972:
    ld hl, sp+$00
    xor a
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    bit 7, a
    jr z, jr_000_2986

    ld hl, sp+$0f
    call Call_000_2beb
    ld hl, sp+$00
    ld [hl], $01

jr_000_2986:
    ld hl, sp+$0e
    ld a, [hl]
    bit 7, a
    jr z, S32DivImpl_u32DivEngine

    ld hl, sp+$0b
    call Call_000_2beb
    ld hl, sp+$00
    ld a, $01
    xor [hl]
    ld [hl], a

S32DivImpl_u32DivEngine::
    ld hl, sp+$0f
    push hl
    ld hl, sp+$0d
    push hl
    ld hl, sp+$09
    push hl
    ld hl, sp+$07
    push hl
    call U32DivEngine
    add sp, $08
    ld hl, sp+$00
    rr [hl]
    jr nc, jr_000_29b6

    ld b, $04
    ld hl, sp+$01
    call Call_000_2beb

jr_000_29b6:
    ld hl, sp+$01
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_29bf:
    add sp, $09
    ret


Jump_000_29c2:
    add sp, -$08
    ld b, $04
    ld hl, sp+$0a
    call MemIsZero
    jr nz, jr_000_29d5

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_2a05


jr_000_29d5:
    ld hl, sp+$0e
    call MemIsZero
    jr nz, U32DivImpl_runEngine

    ld a, $21
    ld [$c4aa], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_2a05


U32DivImpl_runEngine::
    ld hl, sp+$0e
    push hl
    ld hl, sp+$0c
    push hl
    ld hl, sp+$08
    push hl
    ld hl, sp+$06
    push hl
    call U32DivEngine
    add sp, $08
    ld hl, sp+$00
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_2a05:
    add sp, $08
    ret


MemIsZero::
    xor a
    ld c, b

MemIsZero_scanLoop::
    cp [hl]
    ret nz

    inc hl
    dec c
    jr nz, MemIsZero_scanLoop

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


Call_000_2a1d:
    xor a
    bit 7, [hl]
    jr z, ClearNegZero32_matchMsb

    ld a, $80

ClearNegZero32_matchMsb::
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


jr_000_2a36:
    ld c, $03

jr_000_2a38:
    ld a, [de]
    sub [hl]
    ret nz

    dec de
    dec hl
    dec c
    ret z

    jr jr_000_2a38

S32Cmp::
    ld hl, sp+$07
    call Call_000_2a1d
    ld hl, sp+$0b
    call Call_000_2a1d
    ld hl, sp+$07
    bit 7, [hl]
    jr z, jr_000_2a62

    ld hl, sp+$0b
    bit 7, [hl]
    jr z, S32Cmp_retALess

    ld hl, sp+$0b
    ld d, h
    ld e, l
    ld hl, sp+$07
    jr jr_000_2a36

S32Cmp_retALess::
    xor a
    ccf
    ret


jr_000_2a62:
    ld hl, sp+$0b
    bit 7, [hl]
    jr z, jr_000_2a6b

    xor a
    dec a
    ret


jr_000_2a6b:
    ld hl, sp+$07
    ld d, h
    ld e, l
    ld hl, sp+$0b
    jr jr_000_2a36

Jump_000_2a73:
    add sp, -$09
    ld b, $04
    ld hl, sp+$0b
    call MemIsZero
    jr nz, jr_000_2a86

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_2aea


jr_000_2a86:
    ld hl, sp+$0f
    call MemIsZero
    jr nz, jr_000_2a9c

    ld a, $21
    ld [$c4aa], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_2aea


jr_000_2a9c:
    ld hl, sp+$00
    xor a
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    bit 7, a
    jr z, jr_000_2ab0

    ld hl, sp+$0f
    call Call_000_2beb
    ld hl, sp+$00
    ld [hl], $01

jr_000_2ab0:
    ld hl, sp+$0e
    ld a, [hl]
    bit 7, a
    jr z, S32ModImpl_u32DivEngine

    ld hl, sp+$0b
    call Call_000_2beb
    ld hl, sp+$00
    ld a, $01
    xor [hl]
    ld [hl], a

S32ModImpl_u32DivEngine::
    ld hl, sp+$0f
    push hl
    ld hl, sp+$0d
    push hl
    ld hl, sp+$09
    push hl
    ld hl, sp+$07
    push hl
    call U32DivEngine
    add sp, $08
    ld hl, sp+$00
    rr [hl]
    jr nc, jr_000_2ae1

    ld b, $04
    xor a
    ld hl, sp+$05
    call Call_000_2beb

jr_000_2ae1:
    ld hl, sp+$05
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_2aea:
    add sp, $09
    ret


S8Mul::
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
    jr jr_000_2b23

Jump_000_2afc:
    ld hl, sp+$02
    ld a, [hl+]
    ld c, a
    ld e, [hl]

U8Mul::
    xor a
    ld h, a
    ld l, a
    ld d, a

jr_000_2b05:
    xor a
    rr c
    jr nc, jr_000_2b0b

    add hl, de

jr_000_2b0b:
    sla e
    jr z, jr_000_2b13

    rl d
    jr jr_000_2b05

jr_000_2b13:
    rl d
    jr nz, jr_000_2b05

    ld e, l
    ld d, h
    ret


S16Mul::
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld c, [hl]
    inc hl
    ld b, [hl]

jr_000_2b23:
    ld hl, $0000

jr_000_2b26:
    sra b
    jr nz, jr_000_2b33

    rr c
    jr nc, jr_000_2b2f

    add hl, de

jr_000_2b2f:
    jr z, jr_000_2b44

    jr jr_000_2b38

jr_000_2b33:
    rr c
    jr nc, jr_000_2b38

    add hl, de

jr_000_2b38:
    sla e
    jr z, jr_000_2b40

    rl d
    jr jr_000_2b26

jr_000_2b40:
    rl d
    jr nz, jr_000_2b26

jr_000_2b44:
    ld e, l
    ld d, h
    ret


Jump_000_2b47:
    add sp, -$08
    ld b, $04
    ld hl, sp+$0a
    call MemIsZero
    jr nz, jr_000_2b5a

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_2b8a


jr_000_2b5a:
    ld hl, sp+$0e
    call MemIsZero
    jr nz, U32ModImpl_runEngine

    ld a, $21
    ld [$c4aa], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp Jump_000_2b8a


U32ModImpl_runEngine::
    ld hl, sp+$0e
    push hl
    ld hl, sp+$0c
    push hl
    ld hl, sp+$08
    push hl
    ld hl, sp+$06
    push hl
    call U32DivEngine
    add sp, $08
    ld hl, sp+$04
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_000_2b8a:
    add sp, $08
    ret


Memcpy::
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

Memcpy_copyLoop::
    ld a, b
    or c
    ret z

    ld a, [de]
    inc de
    ld [hl], a
    dec bc
    inc hl
    jr Memcpy_copyLoop

puts::
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

Jump_000_2bb6:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    or a
    jp z, Jump_000_2bd9

    dec hl
    inc [hl]
    jr nz, jr_000_2bc7

    inc hl
    inc [hl]

jr_000_2bc7:
    ld a, c
    push af
    inc sp
    call putchar
    add sp, $01
    ld hl, sp+$02
    inc [hl]
    jr nz, jr_000_2bd6

    inc hl
    inc [hl]

jr_000_2bd6:
    jp Jump_000_2bb6


Jump_000_2bd9:
    ld a, $0a
    push af
    inc sp
    call putchar
    add sp, $01
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc de
    add sp, $04
    ret


Call_000_2beb:
    ld c, b
    xor a
    ld d, a

jr_000_2bee:
    ld a, d
    sbc [hl]
    ld [hl+], a
    dec c
    jr nz, jr_000_2bee

    ret


Call_000_2bf5:
    ld c, b
    xor a

jr_000_2bf7:
    ld [hl+], a
    dec c
    jr nz, jr_000_2bf7

    ret


U32MulImpl::
    add sp, -$04
    ld hl, sp+$0a
    push hl
    ld hl, sp+$08
    push hl
    ld hl, sp+$04
    push hl
    ld b, $04
    call U32MulEngine
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


U32DivEngine::
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
    call Call_000_2bf5
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call Call_000_2bf5

U32DivEngine_bitLoop::
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    xor a
    call Call_000_2d1d
    push af
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    pop af
    push hl
    call Call_000_2d1d
    pop de
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push de
    push hl
    call Call_000_2d13
    pop hl
    pop de
    jr c, U32DivEngine_rolQuot

    call Call_000_2c6b

U32DivEngine_rolQuot::
    ccf
    push af
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    pop af
    call Call_000_2d1d
    pop bc
    dec c
    ret z

    push bc
    jr U32DivEngine_bitLoop

Call_000_2c6b:
    ld c, b

jr_000_2c6c:
    ld a, [de]
    sbc [hl]
    ld [de], a
    inc hl
    inc de
    dec c
    jr nz, jr_000_2c6c

    ret


    ld c, b

jr_000_2c76:
    ld [hl+], a
    dec c
    jr nz, jr_000_2c76

    ret


U32MulEngine::
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
    call Call_000_2bf5
    ld hl, sp+$04
    ld [hl], b

Jump_000_2c99:
    ld hl, sp+$04
    ld a, [hl]
    ld hl, sp+$05
    ld [hl], a

U32MulEngine_innerDigit::
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
    call U8Mul
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
    jr z, U32MulEngine_nextOuter

    ld a, [hl]
    adc d
    ld [hl+], a
    call Call_000_2cfe
    ld hl, sp+$05
    dec [hl]
    jr z, U32MulEngine_nextOuter

    ld hl, sp+$0c
    call Call_000_2d06
    ld hl, sp+$08
    call Call_000_2d06
    jr U32MulEngine_innerDigit

U32MulEngine_nextOuter::
    ld hl, sp+$04
    dec [hl]
    jr z, jr_000_2cfb

    ld hl, sp+$00
    call Call_000_2d06
    ld hl, sp+$0a
    call Call_000_2d06
    push bc
    ld b, $02
    ld hl, sp+$02
    ld d, h
    ld e, l
    ld hl, sp+$0a
    call Call_000_2d0b
    ld hl, sp+$04
    ld d, h
    ld e, l
    ld hl, sp+$0e
    call Call_000_2d0b
    pop bc
    jp Jump_000_2c99


jr_000_2cfb:
    add sp, $06
    ret


Call_000_2cfe:
jr_000_2cfe:
    dec c
    ret z

    ld a, $00
    adc [hl]
    ld [hl+], a
    jr jr_000_2cfe

Call_000_2d06:
    inc [hl]
    ret nz

    inc hl
    inc [hl]
    ret


Call_000_2d0b:
    ld c, b

jr_000_2d0c:
    ld a, [de]
    inc de
    ld [hl+], a
    dec c
    jr nz, jr_000_2d0c

    ret


Call_000_2d13:
    ld c, b
    xor a

jr_000_2d15:
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    dec c
    jr nz, jr_000_2d15

    ret


Call_000_2d1d:
    ld c, b

jr_000_2d1e:
    rl [hl]
    inc hl
    dec c
    jr nz, jr_000_2d1e

    ret


Jump_000_2d25:
    ld a, d
    or e
    ret z

    ld a, h
    cp $98
    jr c, jr_000_2d30

    sub $10
    ld h, a

jr_000_2d30:
    xor a
    cp e
    jr nz, jr_000_2d35

    dec d

jr_000_2d35:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_2d35

    ld a, [bc]
    ld [hl+], a
    inc bc

CopyTilesVram_waitStatHi::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, CopyTilesVram_waitStatHi

    ld a, [bc]
    ld [hl], a
    inc bc
    inc l
    jr nz, jr_000_2d52

    inc h
    ld a, h
    cp $98
    jr nz, jr_000_2d52

    ld h, $88

jr_000_2d52:
    dec e
    jr nz, jr_000_2d35

    dec d
    bit 7, d
    jr z, jr_000_2d35

    ret


Jump_000_2d5b:
    ld a, d
    or e
    ret z

    ld a, h
    cp $98
    jr c, CopyTilesColor_loop

    sub $10
    ld h, a

CopyTilesColor_loop::
    push de
    ld a, [bc]
    ld e, a
    inc bc
    push bc
    ld bc, $0000
    ld a, [$c51f]
    bit 0, a
    jr z, jr_000_2d77

    ld b, $ff

jr_000_2d77:
    bit 1, a
    jr z, CopyTilesColor_xorMask

    ld c, $ff

CopyTilesColor_xorMask::
    ld d, a
    ld a, [$c51e]
    xor d
    ld d, a
    bit 0, d
    jr z, jr_000_2d8a

    ld a, e
    xor b
    ld b, a

jr_000_2d8a:
    bit 1, d
    jr z, jr_000_2d91

    ld a, e
    xor c
    ld c, a

jr_000_2d91:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_2d91

    ld [hl], b
    inc hl

CopyTilesColor_statWaitC::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, CopyTilesColor_statWaitC

    ld [hl], c
    inc hl
    ld a, h
    cp $98
    jr nz, jr_000_2da8

    ld h, $88

jr_000_2da8:
    pop bc
    pop de
    dec de
    ld a, d
    or e
    jr nz, CopyTilesColor_loop

    ret


Call_000_2db0:
    call LcdOff
    push hl
    ld hl, $c50b
    ld b, $06

RegisterFont_scanSlots::
    ld a, [hl]
    inc hl
    or [hl]
    cp $00
    jr z, RegisterFont_storeSlot

    inc hl
    inc hl
    dec b
    jr nz, RegisterFont_scanSlots

    pop hl
    ld hl, $0000
    jr jr_000_2def

RegisterFont_storeSlot::
    pop de
    ld [hl], d
    dec hl
    ld [hl], e
    ld a, [$c509]
    dec hl
    ld [hl], a
    push hl
    call SelectFont
    ld a, [$c4ad]
    and $02
    call nz, UploadFontTiles
    ld hl, $c507
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    inc hl
    ld a, [$c509]
    add [hl]
    ld [$c509], a
    pop hl

jr_000_2def:
    ldh a, [rLCDC]
    or $81
    and $e7
    ldh [rLCDC], a
    ret


UploadFontTiles::
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
    jr z, UploadFontTiles_blitGlyphs

    ld bc, $0000
    cp $02
    jr z, UploadFontTiles_blitGlyphs

    ld bc, $0100

UploadFontTiles_blitGlyphs::
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
    jp z, Jump_000_2d25

    jp Jump_000_2d5b


SelectFont::
    ld a, [hl+]
    ld [$c506], a
    ld a, [hl+]
    ld [$c507], a
    ld a, [hl+]
    ld [$c508], a
    ret


PrintChar::
    cp $0a
    jr nz, PrintChar_putChar

    push af
    ld a, [$c4ad]
    and $08
    jr nz, jr_000_2e5e

    call TileNewline
    pop af
    ret


jr_000_2e5e:
    pop af

PrintChar_putChar::
    call PutBgTile
    call AdvanceTileCursor
    ret


    call PutBgTile
    call AdvanceTileCursor
    ret


    call RetreatTileCursor
    ld a, $00
    call PutBgTile
    ret


PutBgTile::
    push af
    ld a, [$c508]
    or a
    jr nz, PutBgTile_mapGlyph

    call ResetTileText
    xor a
    ld [$c509], a
    call FarCallTrampoline

    db $05, $30, $00, $00

PutBgTile_mapGlyph::
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
    jr z, PutBgTile_addBaseTile

    inc hl
    ld d, $00
    add hl, de
    ld e, [hl]

PutBgTile_addBaseTile::
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

PutBgTile_waitStatStore::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, PutBgTile_waitStatStore

    ld [hl], e
    pop hl
    pop de
    pop bc
    ret


RegisterFontArg::
    push bc
    ld hl, sp+$04
    ld a, [hl]
    inc hl
    ld h, [hl]
    ld l, a
    call Call_000_2db0
    push hl
    pop de
    pop bc
    ret


SelectFontArg::
    push bc
    ld hl, sp+$04
    ld a, [hl]
    inc hl
    ld h, [hl]
    ld l, a
    call SelectFont
    pop bc
    ld de, $0000
    ret


ResetTileText::
    push bc
    call EnterGfxMode2
    ld a, $01
    ld [$c509], a
    xor a
    ld hl, $c50a
    ld b, $12

ResetTileText_clearSlots::
    ld [hl+], a
    dec b
    jr nz, ResetTileText_clearSlots

    ld a, $03
    ld [$c51e], a
    ld a, $00
    ld [$c51f], a
    call Call_000_2f07
    pop bc
    ret


Call_000_2f07:
    push de
    push hl
    ld hl, $9800
    ld e, $20

jr_000_2f0e:
    ld d, $20

ClearBgMap_waitStatWrite::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, ClearBgMap_waitStatWrite

    ld [hl], $00
    inc hl
    dec d
    jr nz, ClearBgMap_waitStatWrite

    dec e
    jr nz, jr_000_2f0e

    pop hl
    pop de
    ret


RetreatTileCursor::
    push hl
    ld hl, $c51c
    xor a
    cp [hl]
    jr z, RetreatTileCursor_wrapX

    dec [hl]
    jr jr_000_2f37

RetreatTileCursor_wrapX::
    ld [hl], $13
    ld hl, $c51d
    xor a
    cp [hl]
    jr z, jr_000_2f37

    dec [hl]

jr_000_2f37:
    pop hl
    ret


TileNewline::
    push hl
    xor a
    ld [$c51c], a
    ld hl, $c51d
    ld a, $11
    cp [hl]
    jr z, jr_000_2f49

    inc [hl]
    jr jr_000_2f4c

jr_000_2f49:
    call ScrollBgUp

jr_000_2f4c:
    pop hl
    ret


AdvanceTileCursor::
    push hl
    ld hl, $c51c
    ld a, $13
    cp [hl]
    jr z, AdvanceTileCursor_wrapX

    inc [hl]
    jr jr_000_2f7a

AdvanceTileCursor_wrapX::
    ld [hl], $00
    ld hl, $c51d
    ld a, $11
    cp [hl]
    jr z, AdvanceTileCursor_checkGfxMode

    inc [hl]
    jr jr_000_2f7a

AdvanceTileCursor_checkGfxMode::
    ld a, [$c4ad]
    and $04
    jr z, jr_000_2f77

    xor a
    ld [$c51d], a
    ld [$c51c], a
    jr jr_000_2f7a

jr_000_2f77:
    call ScrollBgUp

jr_000_2f7a:
    pop hl
    ret


ScrollBgUp::
    push bc
    push de
    push hl
    ld hl, $9800
    ld bc, $9820
    ld e, $1f

jr_000_2f87:
    ld d, $20

ScrollBgUp_copyTile::
    ldh a, [rSTAT]
    and $02
    jr nz, ScrollBgUp_copyTile

    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, ScrollBgUp_copyTile

    dec e
    jr nz, jr_000_2f87

    ld d, $20

ScrollBgUp_clearBottom::
    ldh a, [rSTAT]
    and $02
    jr nz, ScrollBgUp_clearBottom

    ld a, $00
    ld [hl+], a
    dec d
    jr nz, ScrollBgUp_clearBottom

    pop hl
    pop de
    pop bc
    ret


EnterGfxMode2::
    di
    ldh a, [rLCDC]
    bit 7, a
    jr z, EnterGfxMode2_initAndEnableLcd

    call LcdOff
    ld bc, VBlankCb_Bg8000
    ld hl, $c4b6
    call RemoveCallbackSlot
    ld bc, LycCb_Bg8800
    ld hl, $c4c6
    call RemoveCallbackSlot

EnterGfxMode2_initAndEnableLcd::
    call InitGfxMode2
    ldh a, [rLCDC]
    or $81
    and $e7
    ldh [rLCDC], a
    ei
    ret


InitGfxMode2::
    xor a
    ld [$c51c], a
    ld [$c51d], a
    call Call_000_2f07
    ld a, $02
    ld [$c4ad], a
    ret


VramCopy::
    ldh a, [rSTAT]
    and $02
    jr nz, VramCopy

    ld a, [bc]
    ld [hl+], a
    inc bc
    dec de
    ld a, d
    or e
    jr nz, VramCopy

    ret


VramCopyStack::
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
    call VramCopy
    pop bc
    ret


RegisterDefaultFont::
    ld hl, FontDesc
    call Call_000_2db0
    ret


FontDesc::
    db $04, $ff, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d
    db $0e, $0f, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d
    db $1e, $1f, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d
    db $2e, $2f, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $3d
    db $3e, $3f, $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4a, $4b, $4c, $4d
    db $4e, $4f, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5a, $5b, $5c, $5d
    db $5e, $5f, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d
    db $6e, $6f, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7a, $7b, $7c, $7d
    db $7e, $7f, $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8a, $8b, $8c, $8d
    db $8e, $8f, $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $9b, $9c, $9d
    db $9e, $9f, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $aa, $ab, $ac, $ad
    db $ae, $af, $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7, $b8, $b9, $ba, $bb, $bc, $bd
    db $be, $bf, $c0, $c1, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd
    db $ce, $cf, $d0, $d1, $d2, $d3, $d4, $d5, $d6, $d7, $d8, $d9, $da, $db, $dc, $dd
    db $de, $df, $e0, $e1, $e2, $e3, $e4, $e5, $e6, $e7, $e8, $e9, $ea, $eb, $ec, $ed
    db $ee, $ef, $f0, $f1, $f2, $f3, $f4, $f5, $f6, $f7, $f8, $f9, $fa, $fb, $fc, $fd
    db $fe, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $18, $24, $42, $81, $e7, $24
    db $24, $3c, $3c, $24, $24, $e7, $81, $42, $24, $18, $18, $14, $f2, $81, $81, $f2
    db $14, $18, $18, $28, $4f, $81, $81, $4f, $28, $18, $ff, $81, $81, $81, $81, $81
    db $81, $ff, $f8, $88, $8f, $89, $f9, $41, $41, $7f, $ff, $89, $89, $89, $f9, $81
    db $81, $ff, $01, $03, $06, $8c, $d8, $70, $20, $00, $7e, $c3, $d3, $d3, $db, $c3
    db $c3, $7e, $18, $3c, $2c, $2c, $7e, $18, $18, $00, $10, $1c, $12, $10, $10, $70
    db $f0, $60, $f0, $c0, $fe, $d8, $de, $18, $18, $00, $70, $c8, $de, $db, $db, $7e
    db $1b, $1b, $00, $00, $00, $ff, $ff, $ff, $00, $00, $1c, $1c, $1c, $1c, $1c, $1c
    db $1c, $1c, $7c, $c6, $c6, $00, $c6, $c6, $7c, $00, $06, $06, $06, $00, $06, $06
    db $06, $00, $7c, $06, $06, $7c, $c0, $c0, $7c, $00, $7c, $06, $06, $7c, $06, $06
    db $7c, $00, $c6, $c6, $c6, $7c, $06, $06, $06, $00, $7c, $c0, $c0, $7c, $06, $06
    db $7c, $00, $7c, $c0, $c0, $7c, $c6, $c6, $7c, $00, $7c, $06, $06, $00, $06, $06
    db $06, $00, $7c, $c6, $c6, $7c, $c6, $c6, $7c, $00, $7c, $c6, $c6, $7c, $06, $06
    db $7c, $00, $00, $3c, $46, $06, $7e, $66, $3c, $00, $78, $66, $7d, $64, $7e, $03
    db $0b, $06, $00, $00, $00, $1f, $1f, $1f, $1c, $1c, $00, $00, $00, $fc, $fc, $fc
    db $1c, $1c, $1c, $1c, $1c, $1f, $1f, $1f, $00, $00, $1c, $1c, $1c, $fc, $fc, $fc
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $18, $18, $18, $18, $18, $00
    db $18, $00, $66, $66, $44, $00, $00, $00, $00, $00, $00, $24, $7e, $24, $24, $7e
    db $24, $00, $14, $3e, $55, $3c, $1e, $55, $3e, $14, $62, $66, $0c, $18, $30, $66
    db $46, $00, $78, $cc, $61, $ce, $cc, $cc, $78, $00, $18, $18, $10, $00, $00, $00
    db $00, $00, $04, $08, $18, $18, $18, $18, $08, $04, $20, $10, $18, $18, $18, $18
    db $10, $20, $00, $54, $38, $fe, $38, $54, $00, $00, $00, $18, $18, $7e, $18, $18
    db $00, $00, $00, $00, $00, $00, $00, $30, $30, $20, $00, $00, $00, $3c, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $18, $18, $00, $03, $06, $0c, $18, $30, $60
    db $c0, $00, $3c, $66, $6e, $76, $66, $66, $3c, $00, $18, $38, $18, $18, $18, $18
    db $18, $00, $3c, $66, $0e, $1c, $38, $70, $7e, $00, $7e, $0c, $18, $3c, $06, $46
    db $3c, $00, $0c, $1c, $2c, $4c, $7e, $0c, $0c, $00, $7e, $60, $7c, $06, $06, $46
    db $3c, $00, $1c, $20, $60, $7c, $66, $66, $3c, $00, $7e, $06, $0e, $1c, $18, $18
    db $18, $00, $3c, $66, $66, $3c, $66, $66, $3c, $00, $3c, $66, $66, $3e, $06, $0c
    db $38, $00, $00, $18, $18, $00, $00, $18, $18, $00, $00, $18, $18, $00, $18, $18
    db $10, $00, $06, $0c, $18, $30, $18, $0c, $06, $00, $00, $00, $3c, $00, $00, $3c
    db $00, $00, $60, $30, $18, $0c, $18, $30, $60, $00, $3c, $46, $06, $0c, $18, $18
    db $00, $18, $3c, $66, $6e, $6a, $6e, $60, $3c, $00, $3c, $66, $66, $7e, $66, $66
    db $66, $00, $7c, $66, $66, $7c, $66, $66, $7c, $00, $3c, $62, $60, $60, $60, $62
    db $3c, $00, $7c, $66, $66, $66, $66, $66, $7c, $00, $7e, $60, $60, $7c, $60, $60
    db $7e, $00, $7e, $60, $60, $7c, $60, $60, $60, $00, $3c, $62, $60, $6e, $66, $66
    db $3e, $00, $66, $66, $66, $7e, $66, $66, $66, $00, $18, $18, $18, $18, $18, $18
    db $18, $00, $06, $06, $06, $06, $06, $46, $3c, $00, $66, $6c, $78, $70, $78, $6c
    db $66, $00, $60, $60, $60, $60, $60, $60, $7c, $00, $fc, $d6, $d6, $d6, $d6, $c6
    db $c6, $00, $62, $72, $7a, $5e, $4e, $46, $42, $00, $3c, $66, $66, $66, $66, $66
    db $3c, $00, $7c, $66, $66, $7c, $60, $60, $60, $00, $3c, $66, $66, $66, $66, $66
    db $3c, $06, $7c, $66, $66, $7c, $66, $66, $66, $00, $3c, $62, $70, $3c, $0e, $46
    db $3c, $00, $7e, $18, $18, $18, $18, $18, $18, $00, $66, $66, $66, $66, $66, $66
    db $3c, $00, $66, $66, $66, $66, $66, $64, $78, $00, $c6, $c6, $c6, $d6, $d6, $d6
    db $fc, $00, $66, $66, $66, $3c, $66, $66, $66, $00, $66, $66, $66, $3c, $18, $18
    db $18, $00, $7e, $0e, $1c, $38, $70, $60, $7e, $00, $1e, $18, $18, $18, $18, $18
    db $1e, $00, $40, $60, $30, $18, $0c, $06, $02, $00, $78, $18, $18, $18, $18, $18
    db $78, $00, $10, $38, $6c, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $7e, $00, $00, $c0, $c0, $60, $00, $00, $00, $00, $00, $3c, $46, $3e, $66, $66
    db $3e, $00, $60, $7c, $66, $66, $66, $66, $7c, $00, $00, $3c, $62, $60, $60, $62
    db $3c, $00, $06, $3e, $66, $66, $66, $66, $3e, $00, $00, $3c, $66, $7e, $60, $62
    db $3c, $00, $1e, $30, $7c, $30, $30, $30, $30, $00, $00, $3e, $66, $66, $66, $3e
    db $46, $3c, $60, $7c, $66, $66, $66, $66, $66, $00, $18, $00, $18, $18, $18, $18
    db $18, $00, $00, $08, $18, $18, $18, $18, $58, $30, $60, $64, $68, $70, $78, $6c
    db $66, $00, $18, $18, $18, $18, $18, $18, $0c, $00, $00, $fc, $d6, $d6, $d6, $d6
    db $c6, $00, $00, $7c, $66, $66, $66, $66, $66, $00, $00, $3c, $66, $66, $66, $66
    db $3c, $00, $00, $7c, $66, $66, $66, $7c, $60, $60, $00, $3e, $66, $66, $66, $66
    db $3e, $06, $00, $6c, $70, $60, $60, $60, $60, $00, $00, $3c, $72, $38, $1c, $4e
    db $3c, $00, $18, $3c, $18, $18, $18, $18, $0c, $00, $00, $66, $66, $66, $66, $66
    db $3e, $00, $00, $66, $66, $66, $66, $64, $78, $00, $00, $c6, $c6, $d6, $d6, $d6
    db $fc, $00, $00, $66, $66, $3c, $66, $66, $66, $00, $00, $66, $66, $66, $26, $1e
    db $46, $3c, $00, $7e, $0e, $1c, $38, $70, $7e, $00, $0e, $18, $18, $30, $18, $18
    db $0e, $00, $18, $18, $18, $18, $18, $18, $18, $18, $70, $18, $18, $0c, $18, $18
    db $70, $00, $00, $60, $f2, $9e, $0c, $00, $00, $00, $10, $10, $28, $28, $44, $44
    db $82, $fe, $3c, $62, $60, $60, $60, $62, $1c, $30, $24, $00, $66, $66, $66, $66
    db $3e, $00, $0c, $18, $00, $3c, $7e, $60, $3c, $00, $18, $66, $00, $3c, $06, $7e
    db $3e, $00, $24, $00, $3c, $46, $3e, $46, $3e, $00, $30, $18, $00, $3c, $06, $7e
    db $3e, $00, $18, $18, $00, $3c, $06, $7e, $3e, $00, $00, $3c, $62, $60, $62, $3c
    db $08, $18, $18, $34, $00, $3c, $7e, $60, $3e, $00, $24, $00, $3c, $66, $7e, $60
    db $3e, $00, $30, $18, $00, $3c, $7e, $60, $3c, $00, $24, $00, $18, $18, $18, $18
    db $18, $00, $18, $24, $00, $18, $18, $18, $18, $00, $10, $08, $00, $18, $18, $18
    db $18, $00, $24, $00, $3c, $66, $7e, $66, $66, $00, $18, $00, $3c, $66, $7e, $66
    db $66, $00, $0c, $18, $7e, $60, $7c, $60, $7e, $00, $00, $00, $7e, $1b, $7f, $d8
    db $7e, $00, $3f, $78, $d8, $de, $f8, $d8, $df, $00, $18, $34, $00, $3c, $66, $66
    db $3c, $00, $24, $00, $3c, $66, $66, $66, $3c, $00, $30, $18, $00, $3c, $66, $66
    db $3c, $00, $18, $24, $00, $66, $66, $66, $3c, $00, $30, $18, $00, $66, $66, $66
    db $3c, $00, $66, $00, $66, $66, $66, $3e, $46, $3c, $66, $00, $3c, $66, $66, $66
    db $3c, $00, $66, $00, $66, $66, $66, $66, $3c, $00, $18, $3c, $62, $60, $60, $62
    db $3c, $18, $1c, $3a, $30, $7c, $30, $30, $7e, $00, $66, $66, $3c, $18, $3c, $18
    db $18, $00, $3c, $66, $66, $6c, $66, $66, $ec, $00, $18, $18, $18, $18, $18, $18
    db $18, $18, $0c, $18, $00, $3c, $06, $7e, $3e, $00, $0c, $18, $00, $18, $18, $18
    db $18, $00, $0c, $18, $00, $3c, $66, $66, $3c, $00, $0c, $18, $00, $66, $66, $66
    db $3e, $00, $34, $58, $00, $7c, $66, $66, $66, $00, $1a, $2c, $62, $72, $5a, $4e
    db $46, $00, $00, $3c, $46, $3e, $66, $3e, $00, $7e, $00, $3c, $66, $66, $66, $3c
    db $00, $7e, $00, $18, $00, $18, $30, $60, $66, $3c, $00, $00, $00, $3e, $30, $30
    db $30, $00, $00, $00, $00, $7c, $0c, $0c, $0c, $00, $62, $e4, $68, $76, $2b, $43
    db $86, $0f, $62, $e4, $68, $76, $2e, $56, $9f, $06, $00, $18, $00, $18, $18, $18
    db $18, $18, $1b, $36, $6c, $d8, $6c, $36, $1b, $00, $d8, $6c, $36, $1b, $36, $6c
    db $d8, $00, $34, $58, $00, $3c, $06, $7e, $3e, $00, $34, $58, $00, $3c, $66, $66
    db $3c, $00, $02, $3c, $66, $6e, $76, $66, $3c, $40, $00, $02, $3c, $6e, $76, $66
    db $3c, $40, $00, $00, $7e, $db, $de, $d8, $7f, $00, $00, $7e, $d8, $d8, $fc, $d8
    db $d8, $de, $20, $10, $3c, $66, $66, $7e, $66, $66, $34, $58, $3c, $66, $66, $7e
    db $66, $66, $34, $58, $3c, $66, $66, $66, $66, $3c, $66, $00, $00, $00, $00, $00
    db $00, $00, $0c, $18, $30, $00, $00, $00, $00, $00, $00, $10, $38, $10, $10, $10
    db $00, $00, $7a, $ca, $ca, $ca, $7a, $0a, $0a, $0a, $3c, $42, $99, $b5, $b1, $9d
    db $42, $3c, $3c, $42, $b9, $b5, $b9, $b5, $42, $3c, $f1, $5b, $55, $51, $51, $00
    db $00, $00, $66, $00, $e6, $66, $66, $f6, $06, $1c, $f6, $66, $66, $66, $66, $f6
    db $06, $1c, $00, $66, $76, $3c, $6e, $66, $00, $00, $00, $7c, $0c, $0c, $0c, $7e
    db $00, $00, $00, $1e, $06, $0e, $1e, $36, $00, $00, $00, $7e, $0c, $0c, $0c, $0c
    db $00, $00, $00, $7c, $06, $66, $66, $66, $00, $00, $00, $1c, $0c, $0c, $0c, $0c
    db $00, $00, $00, $1e, $0c, $06, $06, $06, $00, $00, $00, $7e, $36, $36, $36, $36
    db $00, $00, $60, $6e, $66, $66, $66, $7e, $00, $00, $00, $3c, $0c, $0c, $00, $00
    db $00, $00, $00, $3e, $06, $06, $06, $3e, $00, $00, $60, $7e, $06, $06, $06, $0e
    db $00, $00, $00, $6c, $3e, $66, $66, $6e, $00, $00, $00, $1c, $0c, $0c, $0c, $3c
    db $00, $00, $00, $3e, $36, $36, $36, $1c, $00, $00, $00, $36, $36, $36, $36, $7e
    db $00, $00, $00, $7e, $66, $76, $06, $7e, $00, $00, $00, $66, $66, $3c, $0e, $7e
    db $00, $00, $00, $3e, $06, $36, $36, $34, $30, $00, $00, $78, $0c, $0c, $0c, $0c
    db $00, $00, $00, $d6, $d6, $d6, $d6, $fe, $00, $00, $00, $7c, $6c, $6c, $6c, $ec
    db $00, $00, $00, $1c, $0c, $0c, $0c, $0c, $0c, $00, $00, $3e, $06, $06, $06, $06
    db $06, $00, $00, $fe, $66, $66, $66, $7e, $00, $00, $00, $7e, $66, $76, $06, $06
    db $06, $00, $00, $36, $36, $1c, $0c, $0c, $0c, $00, $1c, $32, $3c, $66, $66, $3c
    db $4c, $38, $00, $10, $38, $6c, $c6, $82, $00, $00, $66, $f7, $99, $99, $ef, $66
    db $00, $00, $00, $00, $76, $dc, $c8, $dc, $76, $00, $1c, $36, $66, $7c, $66, $66
    db $7c, $60, $00, $fe, $66, $62, $60, $60, $60, $f8, $00, $00, $fe, $6c, $6c, $6c
    db $6c, $48, $fe, $66, $30, $18, $30, $66, $fe, $00, $00, $1e, $38, $6c, $6c, $6c
    db $38, $00, $00, $00, $6c, $6c, $6c, $6c, $7f, $c0, $00, $00, $7e, $18, $18, $18
    db $18, $10, $3c, $18, $3c, $66, $66, $3c, $18, $3c, $00, $3c, $66, $7e, $66, $66
    db $3c, $00, $00, $3c, $66, $66, $66, $24, $66, $00, $1c, $36, $78, $dc, $cc, $ec
    db $78, $00, $0c, $18, $38, $54, $54, $38, $30, $60, $00, $10, $7c, $d6, $d6, $d6
    db $7c, $10, $3e, $70, $60, $7e, $60, $70, $3e, $00, $3c, $66, $66, $66, $66, $66
    db $66, $00, $00, $7e, $00, $7e, $00, $7e, $00, $00, $18, $18, $7e, $18, $18, $00
    db $7e, $00, $30, $18, $0c, $18, $30, $00, $7e, $00, $0c, $18, $30, $18, $0c, $00
    db $7e, $00, $00, $0e, $1b, $1b, $18, $18, $18, $18, $18, $18, $18, $18, $d8, $d8
    db $70, $00, $18, $18, $00, $7e, $00, $18, $18, $00, $00, $32, $4c, $00, $32, $4c
    db $00, $00, $38, $6c, $38, $00, $00, $00, $00, $00, $38, $7c, $38, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $18, $18, $00, $00, $00, $00, $0f, $18, $d8, $70
    db $30, $00, $38, $6c, $6c, $6c, $6c, $00, $00, $00, $38, $6c, $18, $30, $7c, $00
    db $00, $00, $78, $0c, $38, $0c, $78, $00, $00, $00, $00, $fe, $00, $00, $00, $00
    db $00, $00

    push af
    push bc

jr_000_3910:
    ld b, $ff

jr_000_3912:
    call ReadJoypadRaw
    or a
    jr nz, jr_000_3910

    dec b
    jr nz, jr_000_3912

    pop bc
    pop af
    ret


ReadJoypadRaw::
    push bc
    ld a, $20
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    cpl
    and $0f

ReadJoypadRaw_readFace::
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


Call_000_394b:
jr_000_394b:
    call ReadJoypadRaw
    and b
    jr z, jr_000_394b

    ret


Call_000_3952:
    call ReadJoypadRaw
    ld e, a
    ret


WaitJoypadMaskArg::
    push bc
    ld hl, sp+$04
    ld b, [hl]
    call Call_000_394b
    ld e, a
    pop bc
    ret


DelayMs::
    push bc
    call DelayLoop
    ld b, $32

Jump_000_3967:
    jr jr_000_3969

jr_000_3969:
    jr jr_000_396b

jr_000_396b:
    jr jr_000_396d

jr_000_396d:
    jr jr_000_396f

jr_000_396f:
    jr jr_000_3971

jr_000_3971:
    dec b
    jp nz, Jump_000_3967

    nop
    pop bc
    jr jr_000_3979

jr_000_3979:
    jr jr_000_397b

jr_000_397b:
    jr jr_000_397d

jr_000_397d:
    ret


DelayLoop::
    dec de
    ld a, e
    or d
    ret z

    ld b, $33

Jump_000_3984:
    jr jr_000_3986

jr_000_3986:
    jr jr_000_3988

jr_000_3988:
    jr jr_000_398a

jr_000_398a:
    jr jr_000_398c

jr_000_398c:
    jr jr_000_398e

jr_000_398e:
    dec b
    jp nz, Jump_000_3984

    nop
    jr jr_000_3995

jr_000_3995:
    jr jr_000_3997

jr_000_3997:
    jr jr_000_3999

jr_000_3999:
    jr DelayLoop

delay::
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    call DelayMs
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
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
