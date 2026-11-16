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
    ld hl, wVBlankCallbacks
    jp RunCallbackList


    rst RST_38

LCDCInterrupt::
    push hl
    ld hl, wLcdCallbacks
    jp RunCallbackList


    rst RST_38

TimerOverflowInterrupt::
    push hl
    ld hl, wTimerCallbacks
    jp RunCallbackList


    rst RST_38

SerialTransferCompleteInterrupt::
    push hl
    ld hl, wSerialCallbacks
    jp RunCallbackList


    rst RST_38

JoypadTransitionInterrupt::
    push hl
    ld hl, wJoypadCallbacks
    jp RunCallbackList


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s
; RunCallbackList: shared IRQ dispatcher. HL = list base (uint16 fn ptrs,
; 0-terminated). Nest via wIntNest; CallHL each slot. Vectors: VBlank→wVBlankCallbacks
; ($d6d3), LCD→$d6e3, Timer→$d6f3, Serial→$d703, Joypad→$d713.
; RunCallbackList_walk: walk until NUL ptr; RunCallbackList_decNest: --wIntNest; nest≠0 → ret else jr_000_008e reti.

RunCallbackList::
    push af

    push bc
    push de
    ld a, [wIntNest]
    inc a
    ld [wIntNest], a

RunCallbackList_walk::
    ld a, [hl+]
    or [hl]
    jr z, RunCallbackList_decNest

    push hl
    ld a, [hl-]
    ld l, [hl]
    ld h, a
    call CallHL
    pop hl
    inc hl
    jr RunCallbackList_walk

RunCallbackList_decNest::
    ld a, [wIntNest]
    dec a
    ld [wIntNest], a
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


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

CallHL::
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
    jp KernelEntry


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

; [ezgb]
; Source: kernel/stock/gbdk/crt0.s
; KernelEntry: after boot ROM (title EZGB). See docs/boot-and-launch.md. di; SP=$e000; save A in D.
; KernelEntry_clearWram: zero WRAM $DFFF down $2000 (B/C nested); KernelEntry_clearOam: OAM $FEFF..$100; KernelEntry_clearHram: HRAM $FFFF..$80.
; Save boot A@$d6c9; bank1; LcdOff; scroll/STAT/WY/WX init; KernelEntry_copyOamDmaStub: copy OamDmaStub → $FF80.
; Register VBlank/Serial; BGP/OBP/LCDC/IE; serial SB=$66 SC=$80; BootUnpackWramTables ($5c87); BatteryCheck; fall HaltLoop.

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

KernelEntry_clearOam::
    ld [hl-], a
    dec b
    jr nz, KernelEntry_clearOam

    ld hl, $ffff
    ld b, $80

KernelEntry_clearHram::
    ld [hl-], a
    dec b
    jr nz, KernelEntry_clearHram

    ld a, d
    ld [$d6a2], a
    ld a, $01
    ld [wRomBank], a
    ld [$2000], a
    xor a
    ld [wIntNest], a
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
    ld [$d6aa], a
    ld [$d6ab], a
    call $5c87
    call BatteryCheck

; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

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
    jp EnterGfxMode1


    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

; [ezgb]
; Source: kernel/stock/gbdk/crt0.s
; SetGfxMode: wGfxMode=L; jp 4-byte table at $01e2 (mode&3). Wrappers:
; SetGfxModeStack ($06ef), GetGfxMode ($06f8) returns E=wGfxMode.

SetGfxMode::
    ld a, l
    ld [$d6a3], a
    and $03
    ld l, a
    ld bc, $01e2
    sla l
    sla l
    add hl, bc
    jp hl


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

RemoveVBlankCallback::
    ld hl, wVBlankCallbacks
    jp RemoveCallbackSlot


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

RemoveLcdCallback::
    ld hl, wLcdCallbacks
    jp RemoveCallbackSlot


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

RemoveTimerCallback::
    ld hl, wTimerCallbacks
    jp RemoveCallbackSlot


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

RemoveSerialCallback::
    ld hl, wSerialCallbacks
    jp RemoveCallbackSlot


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

RemoveJoypadCallback::
    ld hl, wJoypadCallbacks
    jp RemoveCallbackSlot


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s
; RegisterVBlankCallback: HL=wVBlankCallbacks, jp InstallCallbackSlot (BC=fn).
; Siblings: RegisterLcdCallback $0634, RegisterTimerCallback $063a,
; RegisterSerialCallback $0640, RegisterJoypadCallback $0646. Matching Remove*
; wrappers at $0610–$0628. See kernel/stock/gbdk/crt0.s.

RegisterVBlankCallback::
    ld hl, wVBlankCallbacks
    jp InstallCallbackSlot


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s
; RegisterLcdCallback: install BC into wLcdCallbacks ($d6e3). EnterGfxMode1
; registers LycCb_Bg8800 ($26b1) here and enables STAT LYC after RegisterVBlankCallback.

RegisterLcdCallback::
    ld hl, wLcdCallbacks
    jp InstallCallbackSlot


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

RegisterTimerCallback::
    ld hl, wTimerCallbacks
    jp InstallCallbackSlot


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

RegisterSerialCallback::
    ld hl, wSerialCallbacks
    jp InstallCallbackSlot


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

RegisterJoypadCallback::
    ld hl, wJoypadCallbacks
    jp InstallCallbackSlot


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s
; RemoveCallbackSlot: find BC in uint16 list at HL; zero slot; compact tail (RemoveCallbackSlot_compactTail).
; Empty head → ret; mismatch → recurse/self walk; match → clear + slide remaining ptrs until NUL.

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

; [ezgb]
; Source: kernel/stock/gbdk/crt0.s
; InstallCallbackSlot: walk uint16 list at HL, store BC (fn ptr) in first free slot.
; RemoveCallbackSlot ($064c) finds BC and compacts the tail. HL/BC register ABI.
; Occupied → skip+self; InstallCallbackSlot_storeFree: write BC at free NUL slot (hi then lo) ret.

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


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s
; VBlankCallback: ++frame counter $d6d1/$d6d2 (VBlankCallback_oamDmaFlag carry); call OAM DMA $FF80; set $d6ce=1.
; Registered by KernelEntry via RegisterVBlankCallback. WaitVBlankFlag polls $d6ce.

VBlankCallback::
    ld hl, $d6aa
    inc [hl]
    jr nz, VBlankCallback_oamDmaFlag

    inc hl
    inc [hl]

VBlankCallback_oamDmaFlag::
    call $ff80
    ld a, $01
    ld [$d6a7], a
    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s
; WaitVBlankFlag: halt until VBlank sets $D6CE; no-op if LCD is off.
; LCDC bit7 clear → ret. Clear $d6ce under di/ei; WaitVBlankFlag_haltLoop: halt until $d6ce≠0; clear + ret.

WaitVBlankFlag::
    ldh a, [rLCDC]
    add a
    ret nc

    xor a
    di
    ld [$d6a7], a
    ei

WaitVBlankFlag_haltLoop::
    halt
    nop
    ld a, [$d6a7]
    or a
    jr z, WaitVBlankFlag_haltLoop

    xor a
    ld [$d6a7], a
    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s
; LcdOff: wait for a safe LY window, then clear LCDC bit 7; no-op if already off.
; LCDC bit7 clear (add a → NC) → ret. LcdOff_waitLyHigh: spin while LY≥$92; LcdOff_waitLyLow: spin while LY<$91; then LCDC&=$7f.

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


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s
; OamDmaStub: source for HRAM OAM DMA at $FF80 (KernelEntry copies 10 bytes).
; ldh [rDMA],$c0; OamDmaStub_delayLoop: delay loop A=$28 then ret. Called from VBlankCallback.

OamDmaStub::
    ld a, $c0
    ldh [rDMA], a
    ld a, $28

OamDmaStub_delayLoop::
    dec a
    jr nz, OamDmaStub_delayLoop

    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s
; SerialCallback: ISR for serial xfer; state in $d6cd, payload $d6cc.
; SerialCallback_ifState1: state≠2 → if state==1 expect rSB=$55 else $d6cd=$04 (SerialCallback_storeState); state2: store rSB→$d6cc.
; SerialCallback_clearState/06e0: clear/set $d6cd, SC=0, SB=$66; SerialCallback_rearmSc: re-arm SC=$80 ret. Orphan before SetGfxModeStack.

SerialCallback::
    ld a, [$d6a6]
    cp $02
    jr nz, SerialCallback_ifState1

    ldh a, [rSB]
    ld [$d6a5], a
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
    ld [$d6a6], a
    xor a
    ldh [rSC], a
    ld a, $66
    ldh [rSB], a

SerialCallback_rearmSc::
    ld a, $80
    ldh [rSC], a
    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

SetGfxModeStack::
    ld hl, sp+$02
    ld l, [hl]
    ld h, $00
    call SetGfxMode
    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

GetGfxMode::
    ld hl, $d6a3
    ld e, [hl]
    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s
; DiNest: di; ++wIntNest ($d6d0). Pair EiNest ($0706) decs and ei when nest hits 0.
; FarCallTrampoline and critical sections use this nest counter.

DiNest::
    di
    ld a, [wIntNest]
    inc a
    ld [wIntNest], a
    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s
; EiNest: --wIntNest; ei only when counter reaches 0 (nested DI safe).

EiNest::
    ld a, [wIntNest]
    dec a
    ld [wIntNest], a
    ret nz

    ei
    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s
; SetIeReg: DiNest; clear rIF; load rIE from stack u8; EiNest. Safe IE write.

SetIeReg::
    call DiNest
    ld hl, sp+$02
    xor a
    ldh [rIF], a
    ld a, [hl]
    ldh [rIE], a
    call EiNest
    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s
; RemoveVBlankCallbackArg / RemoveLcdCallbackArg / RemoveTimerCallbackArg /
; RemoveSerialCallbackArg / RemoveJoypadCallbackArg: stack ptr → BC then Remove*.
; Register*CallbackArg siblings at $0756..$0782 likewise wrap Register*.

RemoveVBlankCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RemoveVBlankCallback
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

RemoveLcdCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RemoveLcdCallback
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

RemoveTimerCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RemoveTimerCallback
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

RemoveSerialCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RemoveSerialCallback
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

RemoveJoypadCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RemoveJoypadCallback
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

RegisterVBlankCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RegisterVBlankCallback
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

RegisterLcdCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RegisterLcdCallback
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

RegisterTimerCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RegisterTimerCallback
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

RegisterSerialCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RegisterSerialCallback
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

RegisterJoypadCallbackArg::
    push bc
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    call RegisterJoypadCallback
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/crt0.s

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
    ld a, [wRomBank]
    push af
    ld a, b
    ld [wRomBank], a
    ld [$2000], a
    call EiNest
    ld hl, $07ae
    push hl
    ld l, e
    ld h, d
    jp hl


    call DiNest
    pop af
    ld [$2000], a
    ld [wRomBank], a
    call EiNest
    ret


; [ezgb]
; Source: kernel/stock/src/kernel.c
; WaitJoypadSelect: spin ReadJoypad until pad==$40 (SELECT); then Delay+$00c8.
; WaitJoypadSelect_retry: retry; WaitJoypadSelect_delayRet: delay ret. Orphan before PlotBitRowXY.

WaitJoypadSelect::
    call ReadJoypad
    ld c, e
    ld b, $00
    ld a, c
    sub $40
    jp nz, WaitJoypadSelect_retry

    or b
    jp nz, WaitJoypadSelect_retry

    jr WaitJoypadSelect_delayRet

; [ezgb]
; Source: kernel/stock/src/kernel.c

WaitJoypadSelect_retry::
    jp WaitJoypadSelect


; [ezgb]
; Source: kernel/stock/src/kernel.c

WaitJoypadSelect_delayRet::
    ld hl, $00c8
    push hl
    call Delay
    add sp, $02
    ret


; [ezgb]
; Source: kernel/stock/src/kernel.c
; PlotBitRowXY(flags@sp+$02, x@sp+$03, y@sp+$04): plot up to 8 pixels via PlotPixelXY. bit0→x+7 … bit7→x (MSB left).
; Per bit: test flag; set → jr_ plot PlotPixelXY(x+offset,y); clear → Jump_ skip. Chain:
; bit0 PlotBitRowXY_bit0Plot / PlotBitRowXY_bit0Skip; bit1 PlotBitRowXY_bit1Plot / PlotBitRowXY_bit1Skip; bit2 PlotBitRowXY_bit2Plot / PlotBitRowXY_bit2Skip; bit3 PlotBitRowXY_bit3Plot / PlotBitRowXY_bit3Skip;
; bit4 PlotBitRowXY_bit4Plot / PlotBitRowXY_bit4Skip; bit5 PlotBitRowXY_bit5Plot / PlotBitRowXY_bit5Skip; bit6 PlotBitRowXY_bit6Plot / PlotBitRowXY_bit6Skip; bit7 PlotBitRowXY_bit7Plot / PlotBitRowXY_ret ret.

PlotBitRowXY::
    ld hl, sp+$02
    ld a, [hl]
    and $01
    jr nz, PlotBitRowXY_bit0Plot

    jp PlotBitRowXY_bit0Skip


; [ezgb]
; Source: kernel/stock/src/kernel.c

PlotBitRowXY_bit0Plot::
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
    call PlotPixelXY
    add sp, $02

; [ezgb]
; Source: kernel/stock/src/kernel.c

PlotBitRowXY_bit0Skip::
    ld hl, sp+$02
    ld a, [hl]
    and $02
    jr nz, PlotBitRowXY_bit1Plot

    jp PlotBitRowXY_bit1Skip


; [ezgb]
; Source: kernel/stock/src/kernel.c

PlotBitRowXY_bit1Plot::
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
    call PlotPixelXY
    add sp, $02

; [ezgb]
; Source: kernel/stock/src/kernel.c

PlotBitRowXY_bit1Skip::
    ld hl, sp+$02
    ld a, [hl]
    and $04
    jr nz, PlotBitRowXY_bit2Plot

    jp PlotBitRowXY_bit2Skip


; [ezgb]
; Source: kernel/stock/src/kernel.c

PlotBitRowXY_bit2Plot::
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
    call PlotPixelXY
    add sp, $02

; [ezgb]
; Source: kernel/stock/src/kernel.c

PlotBitRowXY_bit2Skip::
    ld hl, sp+$02
    ld a, [hl]
    and $08
    jr nz, PlotBitRowXY_bit3Plot

    jp PlotBitRowXY_bit3Skip


; [ezgb]
; Source: kernel/stock/src/kernel.c

PlotBitRowXY_bit3Plot::
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
    call PlotPixelXY
    add sp, $02

; [ezgb]
; Source: kernel/stock/src/kernel.c

PlotBitRowXY_bit3Skip::
    ld hl, sp+$02
    ld a, [hl]
    and $10
    jr nz, PlotBitRowXY_bit4Plot

    jp PlotBitRowXY_bit4Skip


; [ezgb]
; Source: kernel/stock/src/kernel.c

PlotBitRowXY_bit4Plot::
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
    call PlotPixelXY
    add sp, $02

; [ezgb]
; Source: kernel/stock/src/kernel.c

PlotBitRowXY_bit4Skip::
    ld hl, sp+$02
    ld a, [hl]
    and $20
    jr nz, PlotBitRowXY_bit5Plot

    jp PlotBitRowXY_bit5Skip


; [ezgb]
; Source: kernel/stock/src/kernel.c

PlotBitRowXY_bit5Plot::
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
    call PlotPixelXY
    add sp, $02

; [ezgb]
; Source: kernel/stock/src/kernel.c

PlotBitRowXY_bit5Skip::
    ld hl, sp+$02
    ld a, [hl]
    and $40
    jr nz, PlotBitRowXY_bit6Plot

    jp PlotBitRowXY_bit6Skip


; [ezgb]
; Source: kernel/stock/src/kernel.c

PlotBitRowXY_bit6Plot::
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
    call PlotPixelXY
    add sp, $02

; [ezgb]
; Source: kernel/stock/src/kernel.c

PlotBitRowXY_bit6Skip::
    ld hl, sp+$02
    ld a, [hl]
    and $80
    jr nz, PlotBitRowXY_bit7Plot

    jp PlotBitRowXY_ret


; [ezgb]
; Source: kernel/stock/src/kernel.c

PlotBitRowXY_bit7Plot::
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    dec hl
    ld a, [hl]
    push af
    inc sp
    call PlotPixelXY
    add sp, $02

; [ezgb]
; Source: kernel/stock/src/kernel.c

PlotBitRowXY_ret::
    ret


    ret


; [ezgb]
; Source: kernel/stock/src/kernel.c
; DrawString(ptr, len, screen pos): highest fan-in text primitive (~86 callers). SetTextCursor then glyph loop.
; len==0 → max=$11 else DrawString_copyLen copy len; both meet DrawString_stashPtr stash ptr@sp+$00, C=0.
; DrawString_glyphLoop: if C≥max → DrawString_epilogueRet ret; *ptr==0 → DrawString_drawSpace StoreDrawParams + DrawGlyphAdvance $20; else ++ptr (DrawString_drawChar) DrawGlyphAdvance(char).
; DrawString_incC: ++C → DrawString_glyphLoop; DrawString_epilogueRet ret.

DrawString::
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
    call SetTextCursor
    add sp, $02
    xor a
    ld hl, sp+$07
    or [hl]
    jp nz, DrawString_copyLen

    ld hl, sp+$02
    ld [hl], $11
    jp DrawString_stashPtr


; [ezgb]
; Source: kernel/stock/src/kernel.c

DrawString_copyLen::
    ld hl, sp+$07
    ld a, [hl]
    ld hl, sp+$02
    ld [hl], a

; [ezgb]
; Source: kernel/stock/src/kernel.c

DrawString_stashPtr::
    ld hl, sp+$05
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    ld c, $00

; [ezgb]
; Source: kernel/stock/src/kernel.c

DrawString_glyphLoop::
    ld a, c
    ld hl, sp+$02
    sub [hl]
    jp nc, DrawString_epilogueRet

    dec hl
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    or a
    jp z, DrawString_drawSpace

    dec hl
    inc [hl]
    jr nz, DrawString_drawChar

    inc hl
    inc [hl]

; [ezgb]
; Source: kernel/stock/src/kernel.c

DrawString_drawChar::
    push bc
    push bc
    inc sp
    call DrawGlyphAdvance
    add sp, $01
    pop bc
    jp DrawString_incC


; [ezgb]
; Source: kernel/stock/src/kernel.c

DrawString_drawSpace::
    push bc
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    pop bc
    push bc
    ld a, $20
    push af
    inc sp
    call DrawGlyphAdvance
    add sp, $01
    pop bc

; [ezgb]
; Source: kernel/stock/src/kernel.c

DrawString_incC::
    inc c
    jp DrawString_glyphLoop


; [ezgb]
; Source: kernel/stock/src/kernel.c

DrawString_epilogueRet::
    add sp, $03
    ret


; [ezgb]
; Source: kernel/stock/src/kernel.c
; DrawU32Decimal: debug number printer. U32ToAscii_B0 (radix $0a) then DrawString at ($cc30,$cc2f).
; Inc $cc2f; wrap to 0 past $14 (20). Unlabeled orphan after DrawString_epilogueRet epilogue.
; wDebugTextCol/wDebugTextRow ($cc30/$cc2f) are its text cursor; the row is also where the boot messages draw (SdMenuMain,
; FileSystemErrorHang). No callers in 1.04e or 0731; 0918 calls it only from the unused RtcDebugDump.
; 1.04e: radix $10, steps $cc30 and carries into $cc2f. See docs/kernel-diffs.md.
; Scratch@sp+$01; CStrLen → DrawString(len,x=$cc30,y=$cc2f); ++$cc2f; >$14 → 0; DrawU32Decimal_epilogueRet ret.

DrawU32Decimal::
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
    call U32ToAscii_B0
    add sp, $07
    ld hl, sp+$01
    ld c, l
    ld b, h
    push bc
    call CStrLen
    add sp, $02
    ld b, d
    ld c, e
    ld hl, sp+$00
    ld [hl], c
    ld hl, sp+$01
    ld c, l
    ld b, h
    ld hl, wDebugTextRow
    ld a, [hl]
    push af
    inc sp
    ld hl, wDebugTextCol
    ld a, [hl]
    push af
    inc sp
    ld hl, sp+$02
    ld a, [hl]
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05
    ld hl, wDebugTextCol
    inc [hl]
    ld a, $14
    ld hl, wDebugTextCol
    sub [hl]
    jp nc, DrawU32Decimal_epilogueRet

    ld hl, wDebugTextCol
    ld [hl], $00
    ld hl, wDebugTextRow
    inc [hl]

; [ezgb]
; Source: kernel/stock/src/kernel.c

DrawU32Decimal_epilogueRet::
    add sp, $15
    ret


; [ezgb]
; Source: kernel/stock/src/kernel.c
; FileSystemErrorHang: fatal path for FileBrowserEntry (Chdir_B5 / Opendir_B5 failure). DrawString
; FileSystemErrorStr at col 1, row [$cc2f] (the boot-message row), then infinite loop at $0998.
; FileSystemErrorHang_loop: jp self hang. Orphan ret after; next FileSystemErrorStr.

FileSystemErrorHang::
    ld hl, wDebugTextRow
    ld a, [hl]
    push af
    inc sp
    ld hl, $0100
    push hl
    ld hl, FileSystemErrorStr
    push hl
    call DrawString
    add sp, $05

; [ezgb]
; Source: kernel/stock/src/kernel.c

FileSystemErrorHang_loop::
    jp FileSystemErrorHang_loop


    ret


FileSystemErrorStr::
    db "File system error!", $00

; [ezgb]
; Source: kernel/stock/src/kernel.c
; MemCmp_B0(s1@sp+$0b, s2@sp+$0d, n@sp+$0f): FatFs mem_cmp twin of MemCmp_B5/B9. Frame -$09; Diff@sp+$03=0.
; MemCmp_B0_decN: --n; if was0 → MemCmp_B0_retDiff; else *s1++ (MemCmp_B0_incS1 carry), *s2++ (MemCmp_B0_cmpBytes carry).
; MemCmp_B0_cmpBytes: sex(*s1)-*s2 → diff@sp+$03; if 0 → MemCmp_B0_decN else fall MemCmp_B0_retDiff.
; MemCmp_B0_retDiff: DE=diff ret. DirList hides ezgb.dat via this.

MemCmp_B0::
    add sp, -$09
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

MemCmp_B0_decN::
    ld hl, sp+$02
    ld b, [hl]
    dec [hl]
    xor a
    or b
    jp z, MemCmp_B0_retDiff

    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    dec hl
    inc [hl]
    jr nz, MemCmp_B0_incS1

    inc hl
    inc [hl]

MemCmp_B0_incS1::
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
    jr nz, MemCmp_B0_cmpBytes

    inc hl
    inc [hl]

MemCmp_B0_cmpBytes::
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
    jp z, MemCmp_B0_decN

MemCmp_B0_retDiff::
    ld hl, sp+$03
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $09
    ret


; [ezgb]
; Source: kernel/stock/src/kernel.c
; MemSet8_B0(dest@sp+$04, byte@sp+$06, n@sp+$08): fill n bytes (u8 count) with byte.
; MemSet8_B0_decN: while n--: *dest++=byte (MemSet8_B0_storeCont); MemSet8_B0_epilogueRet ret. Sibling of Memset; used near DirList.

MemSet8_B0::
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

MemSet8_B0_decN::
    ld b, c
    dec c
    xor a
    or b
    jp z, MemSet8_B0_epilogueRet

    ld hl, sp+$06
    ld a, [hl]
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, MemSet8_B0_storeCont

    inc hl
    inc [hl]

MemSet8_B0_storeCont::
    jp MemSet8_B0_decN


MemSet8_B0_epilogueRet::
    add sp, $02
    ret


; [ezgb]
; Source: kernel/stock/src/kernel.c
; DirList: enumerate into $c2a0; count $c2a2/$c2a3; cap 16 (sp+$04).
; DirList_readdir: farcall readdir; fail/empty → DirList_failEmpty → DirList_epilogueRet ($c5a4=1); DirList_skipDot skip ".".
; DirList_bankSlot/DirList_bankShift: bank slot; DirList_notDir: if not dir → DirList_needAmArc; else DirList_dirAttr attr $10 + ApplyBasename → DirList_afterDirStore → DirList_countCheck.
; DirList_needAmArc: need AM_ARC else DirList_skipNoArc → DirList_countCheck; DirList_memcmpEzgbDat MemCmp EzgbDatStr → skip DirList_readdir; else store $20+basename.
; DirList_countCheck/DirList_countCheck: if count<$10 DirList_moreEntries → DirList_readdir else DirList_epilogueRet/DirList_epilogueRet ret.

DirList::
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

; [ezgb]
; Source: kernel/stock/src/kernel.c

DirList_readdir::
    ld a, $00
    push af
    inc sp
    call FarCallTrampoline
    rst RST_20
    ld b, c
    inc b
    nop
    add sp, $01
    ld hl, $c9db
    push hl
    ld hl, $c9f5
    push hl
    call FarCallTrampoline
    halt
    ld [hl], l
    dec b
    nop
    add sp, $04
    ld c, e
    ld a, c
    or a
    jp nz, DirList_failEmpty

    ld bc, $c9e4
    ld a, [bc]
    ld c, a
    or a
    jp nz, DirList_skipDot

; [ezgb]
; Source: kernel/stock/src/kernel.c

DirList_failEmpty::
    ld hl, $c5a4
    ld [hl], $01
    jp DirList_epilogueRet


; [ezgb]
; Source: kernel/stock/src/kernel.c

DirList_skipDot::
    ld a, c
    sub $2e
    jp z, DirList_readdir

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
    jp nz, DirList_bankSlot

    ld bc, $c9e4

; [ezgb]
; Source: kernel/stock/src/kernel.c

DirList_bankSlot::
    ld hl, sp+$07
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, $03
    push af
    inc sp
    call FarCallTrampoline
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

; [ezgb]
; Source: kernel/stock/src/kernel.c

DirList_bankShift::
    srl b
    rr c
    dec a
    jr nz, DirList_bankShift

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
    jp nz, DirList_notDir

    jr DirList_dirAttr

; [ezgb]
; Source: kernel/stock/src/kernel.c

DirList_notDir::
    jp DirList_needAmArc


; [ezgb]
; Source: kernel/stock/src/kernel.c

DirList_dirAttr::
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
    call ApplyBasename
    add sp, $04
    ld hl, sp+$04
    inc [hl]
    ld hl, $c2a2
    inc [hl]
    jr nz, DirList_afterDirStore

    ld hl, $c2a3
    inc [hl]

; [ezgb]
; Source: kernel/stock/src/kernel.c

DirList_afterDirStore::
    jp DirList_countCheck


; [ezgb]
; Source: kernel/stock/src/kernel.c

DirList_needAmArc::
    ld a, c
    and $20
    ld c, a
    sub $20
    jp nz, DirList_skipNoArc

    jr DirList_memcmpEzgbDat

; [ezgb]
; Source: kernel/stock/src/kernel.c

DirList_skipNoArc::
    jp DirList_countCheck


; [ezgb]
; Source: kernel/stock/src/kernel.c

DirList_memcmpEzgbDat::
    ld a, $08
    push af
    inc sp
    ld hl, EzgbDatStr
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call MemCmp_B0
    add sp, $05
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, DirList_readdir

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
    call ApplyBasename
    add sp, $04
    ld hl, sp+$04
    inc [hl]
    ld hl, $c2a2
    inc [hl]
    jr nz, DirList_countCheck

    ld hl, $c2a3
    inc [hl]

; [ezgb]
; Source: kernel/stock/src/kernel.c

DirList_countCheck::
    ld hl, sp+$04
    ld a, [hl]
    sub $10
    jp nz, DirList_moreEntries

    jr DirList_epilogueRet

; [ezgb]
; Source: kernel/stock/src/kernel.c

DirList_moreEntries::
    jp DirList_readdir


; [ezgb]
; Source: kernel/stock/src/kernel.c

DirList_epilogueRet::
    add sp, $09
    ret


EzgbDatStr::
    db "ezgb.dat", $00

; [ezgb]
; Source: kernel/stock/src/kernel.c
; DrawDirEntryLabel(size@sp+$12, ofs@sp+$16, y@sp+$18): frame -$10. size≤$14 → DrawDirEntryLabel_epilogueRet skip.
; DrawDirEntryLabel_bankShift: >>5 bank from ofs; attr+$fe==$10 → jr_000_0c88 width $11 else DrawDirEntryLabel_skipDirWidth → Jump_000_0c8f width $14.
; Jump_000_0c8f: if namelen≥width → DrawDirEntryLabel_epilogueRet; else U32Shr/Div scroll idx; if $cc31/$cc32 unchanged → DrawDirEntryLabel_epilogueRet.
; DrawDirEntryLabel_drawEllipsis: update $cc31/32; Strncpy name+$fe ellipsis into $c4a4; DrawString at y+2; DrawDirEntryLabel_epilogueRet epilogue.

DrawDirEntryLabel::
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
    jp nc, DrawDirEntryLabel_epilogueRet

    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
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

; [ezgb]
; Source: kernel/stock/src/kernel.c

DrawDirEntryLabel_bankShift::
    srl b
    rr c
    dec a
    jr nz, DrawDirEntryLabel_bankShift

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
    call CStrLen
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
    jp nz, DrawDirEntryLabel_skipDirWidth

    jr jr_000_0c88

; [ezgb]
; Source: kernel/stock/src/kernel.c

DrawDirEntryLabel_skipDirWidth::
    jp Jump_000_0c8f


jr_000_0c88:
    ld hl, sp+$0f
    ld [hl], $11
    jp DrawDirEntryLabel_scrollCheck


Jump_000_0c8f:
    ld hl, sp+$0f
    ld [hl], $14

; [ezgb]
; Source: kernel/stock/src/kernel.c

DrawDirEntryLabel_scrollCheck::
    ld hl, sp+$0f
    ld a, [hl]
    dec hl
    sub [hl]
    jp nc, DrawDirEntryLabel_epilogueRet

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
    call U32Shr
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
    call U32Div
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
    jp nz, DrawDirEntryLabel_drawEllipsis

    ld hl, $cc32
    ld a, [hl]
    ld hl, sp+$0b
    sub [hl]
    jp z, DrawDirEntryLabel_epilogueRet

; [ezgb]
; Source: kernel/stock/src/kernel.c

DrawDirEntryLabel_drawEllipsis::
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
    call Strncpy
    add sp, $06
    ld hl, $0de4
    push hl
    ld hl, $c4a4
    push hl
    call FarCallTrampoline
    nop
    ld b, b
    ld bc, $e800
    inc b
    ld hl, $c4a4
    push hl
    call CStrLen
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
    call CStrLen
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
    call Strncpy
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
    call DrawString
    add sp, $05

; [ezgb]
; Source: kernel/stock/src/kernel.c

DrawDirEntryLabel_epilogueRet::
    add sp, $10
    ret


    jr nz, SdMenuMain_afterMount

    jr nz, SdMenuMain

; [ezgb]
; Source: kernel/stock/src/kernel.c
; SdMenuMain: SD init, BACKUPSAVE, file browser. Kernel FPGA path; stays in menu loop.
; FarCall SD mount (inline after call); SdMenuMain_afterMount: check status@sp+$16; NZ → DrawString MicroSdInitErrorStr; SdMenuMain_initErrorHang hang.
; SdMenuMain_mountOk: OK string; page $11 via $4000; if $A000≠$AA → GotoFileBrowser else jr BackupBranchEntry.
; Launched games never enter here. BackupBranchEntry clears $A000 (see 00:0e76 / 01:6747).

SdMenuMain::
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
    call FarCallTrampoline
    add hl, de
    ld l, [hl]
    dec b

; [ezgb]
; Source: kernel/stock/src/kernel.c

SdMenuMain_afterMount::
    nop
    add sp, $05
    ld c, e
    ld hl, sp+$16
    ld [hl], c
    ld a, [hl]
    or a
    jp z, SdMenuMain_mountOk

    ld hl, wDebugTextRow
    ld a, [hl]
    push af
    inc sp
    ld hl, $0014
    push hl
    ld hl, MicroSdInitErrorStr
    push hl
    call DrawString
    add sp, $05

; [ezgb]
; Source: kernel/stock/src/kernel.c

SdMenuMain_initErrorHang::
    jp SdMenuMain_initErrorHang


; [ezgb]
; Source: kernel/stock/src/kernel.c

SdMenuMain_mountOk::
    ld hl, wDebugTextRow
    ld a, [hl]
    push af
    inc sp
    ld hl, $0014
    push hl
    ld hl, MicroSdInitOkStr
    push hl
    call DrawString
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
    call FarCallTrampoline
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
    jp nz, GotoFileBrowser

    inc hl
    ld a, [hl]
    or a
    jp nz, GotoFileBrowser

    jr BackupBranchEntry

; [ezgb]
; Source: kernel/stock/src/kernel.c

GotoFileBrowser::
    jp BackupBranchEntry_seedSlashPath


; [ezgb]
; Source: kernel/stock/src/kernel.c
; BackupBranchEntry: save stamp → SAVER basename, then fall into FileBrowserEntry.
; C=$A200 auto-save flag, $A202→$d3f6, $A001 save size in banks, clear $A000, B=$A00F path length.
; BackupBranchEntry_copyBasename: copy $A010.. → $c3a5 (BackupBranchEntry_copyCont carry); BackupBranchEntry_openSaverDir: NUL-term + Open_B9 SaverDirStr + farcalls.
; BackupBranchEntry_seedSlashPath: $4000=0, memset $c2a6, seed '/'; fallthrough FileBrowserEntry (00:0f8d).

BackupBranchEntry::
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

; [ezgb]
; Source: kernel/stock/src/kernel.c

BackupBranchEntry_copyBasename::
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
    jp nc, BackupBranchEntry_openSaverDir

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
    jr nz, BackupBranchEntry_copyCont

    inc hl
    inc [hl]

; [ezgb]
; Source: kernel/stock/src/kernel.c

BackupBranchEntry_copyCont::
    jp BackupBranchEntry_copyBasename


; [ezgb]
; Source: kernel/stock/src/kernel.c

BackupBranchEntry_openSaverDir::
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
    call FarCallTrampoline
    rst RST_20
    ld b, c
    inc b
    nop
    add sp, $01
    pop bc
    push bc
    ld hl, SaverDirStr
    push hl
    call FarCall_09_77ff
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
    call FarCallTrampoline
    jr jr_000_0fa6

    ld bc, $e800
    dec b

; [ezgb]
; Source: kernel/stock/src/kernel.c

BackupBranchEntry_seedSlashPath::
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
    call FarCallTrampoline
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
    call Memset
    add sp, $05
    ld de, $c2a6
    ld a, $2f
    ld [de], a

; [ezgb]
; Source: kernel/stock/src/kernel.c
; FileBrowserEntry: clear $cc2f/$cc30/$c5a4; farcall mount/list; fail FileSystemErrorHang. Main browser loop.
; FileBrowserEntry_clearPageIdx/FileBrowserEntry_memsetWireDirList: zero $c2a2/$c2a3; memset $c4a4+$c9db; wire $c9f1→$c4a4, $c9f3=$00fe; DirList.
; FileBrowserEntry_redraw redraw: dirty → FileBrowserEntry_redrawSkipCode3/FileBrowserEntry_redrawCode3Farcall (code3 farcall+label) or FileBrowserEntry_redrawCodeGe2 (code≥2); FileBrowserEntry_drawDirEntryLabel DrawDirEntryLabel if count≠0 → FileBrowserEntry_inputLoop.
; FileBrowserEntry_inputLoop Delay+ReadJoypad: $02 FileBrowserEntry_pageDec page-- (FileBrowserEntry_pageDecZero/FileBrowserEntry_pageDecDirty/FileBrowserEntry_pageDecGate/FileBrowserEntry_afterPageDec); $01 FileBrowserEntry_dirListBtn DirList + FileBrowserEntry_pageInc page++ (FileBrowserEntry_pageIncClamp/FileBrowserEntry_pageIncDirty/FileBrowserEntry_afterPageInc).
; $04/$08 jr_000_11db/FileBrowserEntry_afterRowDec / jr_000_11f4/FileBrowserEntry_afterRow row; $40 FileBrowserEntry_modeBtn mode (FileBrowserEntry_modeSkipWrap/FileBrowserEntry_modeWrapZero/FileBrowserEntry_modeCheck1/FileBrowserEntry_modeSkipFarcall1/FileBrowserEntry_modeFarcall1 farcall) → FileBrowserEntry_modeCheck2/FileBrowserEntry_modeSkipFarcall2/FileBrowserEntry_modeFarcall2 or MenuKeyDispatch.

FileBrowserEntry::
    ld hl, wDebugTextRow
    ld [hl], $00
    ld hl, wDebugTextCol
    ld [hl], $00
    ld hl, sp+$0e
    ld [hl], $00
    ld hl, $c5a4
    ld [hl], $00
    call FarCallTrampoline
    ld b, h
    ld [hl], e
    ld [$3e00], sp
    nop
    push af
    inc sp
    call FarCallTrampoline
    rst RST_20
    ld b, c
    inc b
    nop

jr_000_0fa6:
    add sp, $01
    ld hl, $c2a6
    push hl
    call FarCallTrampoline
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
    jp z, FileBrowserEntry_clearPageIdx

    call FileSystemErrorHang

; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_clearPageIdx::
    ld hl, $c2a2
    ld [hl], $00
    ld hl, $c2a3
    ld [hl], $00
    ld hl, $c2a6
    push hl
    ld hl, $c9f5
    push hl
    call FarCallTrampoline
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
    jp z, FileBrowserEntry_memsetWireDirList

    call FileSystemErrorHang

; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_memsetWireDirList::
    ld hl, $00ff
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $c4a4
    push hl
    call Memset
    add sp, $05
    ld c, $db
    ld b, $c9
    ld hl, $001a
    push hl
    ld a, $00
    push af
    inc sp
    push bc
    call Memset
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
    call DirList
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
    call FarCallTrampoline
    ld l, c
    ld [hl], c
    ld [$e800], sp
    ld bc, $033e
    push af
    inc sp
    call FarCallTrampoline
    ld l, c
    ld [hl], c
    ld [$e800], sp
    ld bc, $0af8
    inc [hl]
    jr nz, FileBrowserEntry_redraw

    inc hl
    inc [hl]
    jr nz, FileBrowserEntry_redraw

    inc hl
    inc [hl]
    jr nz, FileBrowserEntry_redraw

    inc hl
    inc [hl]

; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_redraw::
    xor a
    ld hl, sp+$12
    or [hl]
    jp z, FileBrowserEntry_drawDirEntryLabel

    xor a
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    sub $01
    jp nz, FileBrowserEntry_redrawSkipCode3

    jr FileBrowserEntry_redrawCode3Farcall

; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_redrawSkipCode3::
    jp FileBrowserEntry_redrawCodeGe2


; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_redrawCode3Farcall::
    ld a, $03
    push af
    inc sp
    call FarCallTrampoline
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
    call FarCallTrampoline
    db $e3
    ld b, b
    ld bc, $e800
    inc b
    jp FileBrowserEntry_drawDirEntryLabel


; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_redrawCodeGe2::
    ld a, $01
    ld hl, sp+$12
    sub [hl]
    jp nc, FileBrowserEntry_drawDirEntryLabel

    ld a, $03
    push af
    inc sp
    call FarCallTrampoline
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
    call FarCallTrampoline
    cp d
    ld b, d
    ld bc, $e800
    dec b

; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_drawDirEntryLabel::
    ld hl, $c2a2
    ld a, [hl]
    ld hl, $c2a3
    or [hl]
    jp z, FileBrowserEntry_inputLoop

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
    call DrawDirEntryLabel
    add sp, $08

; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_inputLoop::
    ld hl, sp+$12
    ld [hl], $00
    ld hl, $002d
    push hl
    call Delay
    add sp, $02
    call ReadJoypad
    ld b, e
    ld c, b
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], $00
    dec hl
    ld a, [hl]
    and $02
    jr nz, FileBrowserEntry_pageDec

    jp FileBrowserEntry_afterPageDec


; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_pageDec::
    ld hl, sp+$13
    ld a, [hl+]
    or [hl]
    jp z, FileBrowserEntry_pageDecGate

    ld a, $0f
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp nc, FileBrowserEntry_pageDecZero

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
    jp FileBrowserEntry_pageDecDirty


; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_pageDecZero::
    ld hl, sp+$13
    ld [hl], $00
    inc hl
    ld [hl], $00

; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_pageDecDirty::
    ld hl, sp+$12
    ld [hl], $01
    jp MenuDispatchAB_waitVBlankLoop


; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_pageDecGate::
    xor a
    ld hl, sp+$15
    or [hl]
    jp z, MenuDispatchAB_waitVBlankLoop

    ld [hl], $00
    ld hl, sp+$12
    ld [hl], $01
    jp MenuDispatchAB_waitVBlankLoop


; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_afterPageDec::
    ld hl, sp+$00
    ld a, [hl]
    and $01
    jr nz, FileBrowserEntry_dirListBtn

    jp FileBrowserEntry_afterPageInc


; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_dirListBtn::
    xor a
    ld hl, $c5a4
    or [hl]
    jp nz, FileBrowserEntry_pageInc

    call DirList

; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_pageInc::
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
    jp nc, MenuDispatchAB_waitVBlankLoop

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
    jp c, FileBrowserEntry_pageIncClamp

    ld hl, sp+$13
    ld [hl], c
    inc hl
    ld [hl], b
    jp FileBrowserEntry_pageIncDirty


; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_pageIncClamp::
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

; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_pageIncDirty::
    ld hl, sp+$12
    ld [hl], $01
    jp MenuDispatchAB_waitVBlankLoop


; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_afterPageInc::
    ld hl, sp+$00
    ld a, [hl]
    and $04
    jr nz, jr_000_11db

    jp FileBrowserEntry_afterRowDec


jr_000_11db:
    xor a
    ld hl, sp+$15
    or [hl]
    jp z, MenuDispatchAB_waitVBlankLoop

    dec [hl]
    ld hl, sp+$12
    ld [hl], $03
    jp MenuDispatchAB_waitVBlankLoop


; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_afterRowDec::
    ld hl, sp+$00
    ld a, [hl]
    and $08
    jr nz, jr_000_11f4

    jp FileBrowserEntry_afterRow


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
    jp nc, MenuDispatchAB_waitVBlankLoop

    ld hl, sp+$15
    ld a, [hl]
    sub $0f
    jp nc, MenuDispatchAB_waitVBlankLoop

    inc [hl]
    ld hl, sp+$12
    ld [hl], $02
    jp MenuDispatchAB_waitVBlankLoop


; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_afterRow::
    ld hl, sp+$00
    ld a, [hl]
    and $40
    jr nz, FileBrowserEntry_modeBtn

    jp MenuKeyDispatch


; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_modeBtn::
    ld hl, sp+$0e
    inc [hl]
    ld a, [hl]
    sub $02
    jp nz, FileBrowserEntry_modeSkipWrap

    jr FileBrowserEntry_modeWrapZero

; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_modeSkipWrap::
    jp FileBrowserEntry_modeCheck1


; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_modeWrapZero::
    ld hl, sp+$0e
    ld [hl], $00
    jp FileBrowserEntry_modeCheck2


; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_modeCheck1::
    ld hl, sp+$0e
    ld a, [hl]
    sub $01
    jp nz, FileBrowserEntry_modeSkipFarcall1

    jr FileBrowserEntry_modeFarcall1

; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_modeSkipFarcall1::
    jp FileBrowserEntry_modeCheck2


; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_modeFarcall1::
    ld a, $01
    push af
    inc sp
    call FarCallTrampoline
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

; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_modeCheck2::
    ld hl, sp+$0e
    ld a, [hl]
    sub $02
    jp nz, FileBrowserEntry_modeSkipFarcall2

    jr FileBrowserEntry_modeFarcall2

; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_modeSkipFarcall2::
    jp MenuDispatchAB_waitVBlankLoop


; [ezgb]
; Source: kernel/stock/src/kernel.c

FileBrowserEntry_modeFarcall2::
    ld a, $02
    push af
    inc sp
    call FarCallTrampoline
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
    call Delay
    add sp, $02
    jp FileBrowserEntry


; [ezgb]
; Source: kernel/stock/src/kernel.c
; MenuKeyDispatch: START ($80) -> LastRomOverlay; else MenuDispatchAB.
; Joypad byte is post-swap: A=$10, B=$20, START=$80 (see docs/input.md).

MenuKeyDispatch::
    ld hl, sp+$00
    ld a, [hl]
    and $80
    jr nz, LastRomOverlay

    jp MenuDispatchAB


; [ezgb]
; Source: kernel/stock/src/kernel.c
; LastRomOverlay: draw chrome (bank8 DrawLastRomButtons) and copy the 255-byte
; path record $A300 -> $c4a4. Shows basename only; relaunch (A) uses the full
; path via LastRomRelaunch. See docs/last-rom.md.

LastRomOverlay::
    call FarCallTrampoline
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
    call FarCallTrampoline
    rst RST_20
    ld b, c
    inc b
    nop
    add sp, $01
    ld hl, sp+$0f
    ld [hl], $00
    inc hl
    ld [hl], $00

; [ezgb]
; Source: kernel/stock/src/kernel.c
; LastRomLoadRecord: copy $A300..+$00ff → $c4a4 (idx@sp+$0f); then LastRomDrawBasename.
; Loop via LastRomLoadRecord_copyCont → self until idx≥$00ff; fallthrough jp LastRomDrawBasename when done.

LastRomLoadRecord::
    ld hl, sp+$0f
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, LastRomDrawBasename

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
    jr nz, LastRomLoadRecord_copyCont

    inc hl
    inc [hl]

; [ezgb]
; Source: kernel/stock/src/kernel.c

LastRomLoadRecord_copyCont::
    jp LastRomLoadRecord


; [ezgb]
; Source: kernel/stock/src/kernel.c

LastRomDrawBasename::
    ld bc, $4000
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call FarCallTrampoline
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
    call Strrchr
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
    call DrawString
    add sp, $05

; [ezgb]
; Source: kernel/stock/src/kernel.c

LastRomInputLoop::
    call ReadJoypad
    ld b, e
    ld c, b
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], $00
    dec hl
    ld a, [hl]
    and $10
    jr nz, LastRomRelaunch

    jp LastRomCheckReturn


; [ezgb]
; Source: kernel/stock/src/kernel.c

LastRomRelaunch::
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
    call Memcpy
    add sp, $06
    ld hl, $c2a6
    push hl
    call FarCallTrampoline
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
    call ApplyBasename
    add sp, $04
    call FarCallTrampoline
    ld a, a
    ld [hl], e
    ld [$c300], sp
    ld h, h
    dec d

; [ezgb]
; Source: kernel/stock/src/kernel.c

LastRomCheckReturn::
    ld hl, sp+$04
    ld a, [hl]
    and $20
    jr nz, LastRomReturn

    jp LastRomInputLoop


; [ezgb]
; Source: kernel/stock/src/kernel.c

LastRomReturn::
    jp FileBrowserEntry


; [ezgb]
; Source: kernel/stock/src/kernel.c
; MenuDispatchAB: A($10) open selection; B($20) parent dir; else MenuDispatchAB_waitVBlankLoop WaitVBlankFlag → browser loop $1062.
; MenuDispatchAB_bankEntry/MenuDispatchAB_bankShift: bank entry >>5+$12@$4000; MenuDispatchAB_fileSkipDir: file → MenuDispatchAB_fileOpen else jr_000_1403/MenuDispatchAB_dirToBrowser dir append → FileBrowserEntry.
; MenuDispatchAB_fileOpen: ApplyBasename+$c4a4; MenuDispatchAB_toupperExtA/MenuDispatchAB_toupperExtB toupper ext@$c3a5; MenuDispatchAB_memcmpExt MemCmp .gbc/.gb.
; Match MenuDispatchAB_extMatch → Jump_000_155d launch farcalls; fail MenuDispatchAB_failSkipWait/MenuDispatchAB_failWaitSelect WaitJoypadSelect; MenuDispatchAB_failHang..MenuDispatchAB_failHangLoop hang.
; MenuDispatchAB_checkB: B → MenuDispatchAB_parentDir strip last /$c2a6 (Strrchr); empty "/"; jp FileBrowserEntry; else MenuDispatchAB_waitVBlankLoop.

MenuDispatchAB::
    ld hl, sp+$00
    ld a, [hl]
    and $10
    jr nz, MenuDispatchAB_bankEntry

    jp MenuDispatchAB_checkB


; [ezgb]
; Source: kernel/stock/src/kernel.c

MenuDispatchAB_bankEntry::
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

; [ezgb]
; Source: kernel/stock/src/kernel.c

MenuDispatchAB_bankShift::
    srl b
    rr c
    dec a
    jr nz, MenuDispatchAB_bankShift

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
    jp nz, MenuDispatchAB_fileSkipDir

    jr jr_000_1403

; [ezgb]
; Source: kernel/stock/src/kernel.c

MenuDispatchAB_fileSkipDir::
    jp MenuDispatchAB_fileOpen


jr_000_1403:
    ld hl, PathSlashStr
    push hl
    ld hl, $c2a6
    push hl
    call FarCallTrampoline
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
    jp z, MenuDispatchAB_dirToBrowser

    ld hl, PathSlashStr
    push hl
    ld hl, $c2a6
    push hl
    call FarCallTrampoline
    nop
    ld b, b
    ld bc, $e800
    inc b

; [ezgb]
; Source: kernel/stock/src/kernel.c

MenuDispatchAB_dirToBrowser::
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
    call FarCallTrampoline
    nop
    ld b, b
    ld bc, $e800
    inc b
    jp FileBrowserEntry


; [ezgb]
; Source: kernel/stock/src/kernel.c

MenuDispatchAB_fileOpen::
    call FarCallTrampoline
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
    call MemSet8_B0
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
    call ApplyBasename
    add sp, $04
    ld a, $2e
    push af
    inc sp
    ld hl, $c4a4
    push hl
    call Strrchr
    add sp, $03
    ld b, d
    ld c, e
    ld hl, $0005
    push hl
    push bc
    ld hl, $c3a5
    push hl
    call Memcpy
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
    jp c, MenuDispatchAB_toupperExtA

    ld a, $7a
    sub b
    rlca
    jp c, MenuDispatchAB_toupperExtA

    ld a, b
    add $e0
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a

; [ezgb]
; Source: kernel/stock/src/kernel.c

MenuDispatchAB_toupperExtA::
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
    jp c, MenuDispatchAB_toupperExtB

    ld a, $7a
    sub b
    rlca
    jp c, MenuDispatchAB_toupperExtB

    ld a, b
    add $e0
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a

; [ezgb]
; Source: kernel/stock/src/kernel.c

MenuDispatchAB_toupperExtB::
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
    jp c, MenuDispatchAB_memcmpExt

    ld a, $7a
    sub b
    rlca
    jp c, MenuDispatchAB_memcmpExt

    ld a, b
    add $e0
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a

; [ezgb]
; Source: kernel/stock/src/kernel.c

MenuDispatchAB_memcmpExt::
    ld a, $05
    push af
    inc sp
    ld hl, ExtGbcStr
    push hl
    ld hl, $c3a5
    push hl
    call MemCmp_B0
    add sp, $05
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, Jump_000_155d

    ld a, $04
    push af
    inc sp
    ld hl, ExtGbStr
    push hl
    ld hl, $c3a5
    push hl
    call MemCmp_B0
    add sp, $05
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, Jump_000_155d

    call FarCallTrampoline
    cp d
    ld [hl], e
    ld [$cd00], sp
    sub c
    ld [hl], $43
    ld c, b
    ld b, $00
    ld a, c
    and $20
    jr nz, MenuDispatchAB_extMatch

    jp $154b


; [ezgb]
; Source: kernel/stock/src/kernel.c

MenuDispatchAB_extMatch::
    jp FileBrowserEntry


Jump_000_155d:
    call FarCallTrampoline
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
    jp nz, MenuDispatchAB_failSkipWait

    jr MenuDispatchAB_failWaitSelect

; [ezgb]
; Source: kernel/stock/src/kernel.c

MenuDispatchAB_failSkipWait::
    jp MenuDispatchAB_failHang


; [ezgb]
; Source: kernel/stock/src/kernel.c

MenuDispatchAB_failWaitSelect::
    call WaitJoypadSelect
    jp FileBrowserEntry


; [ezgb]
; Source: kernel/stock/src/kernel.c

MenuDispatchAB_failHang::
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
    call FarCallTrampoline
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
    call FarCallTrampoline
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
    call FarCallTrampoline
    ld h, b
    ld b, c
    inc b
    nop
    add sp, $01
    ld hl, $d3ed
    ld a, [hl]
    push af
    inc sp
    call FarCallTrampoline
    db $ec
    ld b, e
    inc b
    nop
    add sp, $01
    ld hl, $d3ec
    ld a, [hl]
    push af
    inc sp
    call FarCallTrampoline
    rlca
    ld b, d
    inc b
    nop
    add sp, $01
    call FarCallTrampoline
    ld l, [hl]
    ld b, h
    inc b
    nop
    call LcdOff
    call DiNest
    ld hl, sp+$16
    ld a, [hl]
    push af
    inc sp
    ld hl, $c0a0
    push hl
    call FarCallTrampoline
    adc a
    ld b, h
    inc b
    nop
    add sp, $03

; [ezgb]
; Source: kernel/stock/src/kernel.c

MenuDispatchAB_failHangLoop::
    jp MenuDispatchAB_failHangLoop


; [ezgb]
; Source: kernel/stock/src/kernel.c

MenuDispatchAB_checkB::
    ld hl, sp+$00
    ld a, [hl]
    and $20
    jr nz, MenuDispatchAB_parentDir

    jp MenuDispatchAB_waitVBlankLoop


; [ezgb]
; Source: kernel/stock/src/kernel.c

MenuDispatchAB_parentDir::
    ld hl, PathSlashStr
    push hl
    ld hl, $c2a6
    push hl
    call FarCallTrampoline
    ld c, b
    ld b, b
    ld bc, $e800
    inc b
    ld b, d
    ld c, e
    ld a, c
    or b

; [ezgb]
; Source: kernel/stock/src/kernel.c

FlPickCancelSite::
    jp z, MenuDispatchAB_waitVBlankLoop

    ld hl, $00ff
    push hl
    ld hl, $c2a6
    push hl
    ld hl, $c3a5
    push hl
    call Memcpy
    add sp, $06
    ld a, $2f
    push af
    inc sp
    ld hl, $c3a5
    push hl
    call Strrchr
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
    call Memset
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
    call Memcpy
    add sp, $06
    ld de, $c2a6
    ld a, [de]
    or a
    jp nz, FileBrowserEntry

    ld de, $c2a6
    ld a, $2f
    ld [de], a
    jp FileBrowserEntry


; [ezgb]
; Source: kernel/stock/src/kernel.c

MenuDispatchAB_waitVBlankLoop::
    call WaitVBlankFlag
    jp $1056


    add sp, $17
    ret


    nop

MicroSdInitErrorStr::
    db "Micro SD initial error!", $00

; [ezgb]
; Source: kernel/stock/src/kernel.c
; MicroSdInitOkStr: NUL-term "Micro SD initial OK!" for SdMenuMain.

MicroSdInitOkStr::
    db "Micro SD initial OK!", $00

; [ezgb]
; Source: kernel/stock/src/kernel.c
; SaverDirStr: NUL-term "/SAVER"; BackupBranchEntry Open_B9 path.

SaverDirStr::
    db "/SAVER", $00

; [ezgb]
; Source: kernel/stock/src/kernel.c
; PathSlashStr: NUL-term "/"; path join in browser/backup helpers.

PathSlashStr::
    db "/", $00

; [ezgb]
; Source: kernel/stock/src/kernel.c
; ExtGbcStr: NUL-term ".GBC" extension compare/append.

ExtGbcStr::
    db ".GBC", $00

; [ezgb]
; Source: kernel/stock/src/kernel.c
; ExtGbStr: NUL-term ".GB" extension compare/append.

ExtGbStr::
    db ".GB", $00

; [ezgb]
; Source: kernel/stock/src/kernel.c
; U32ToAscii_B0: bank0 twin of U32ToAscii (04:44f7); same ABI val/buf/radix. Used from bank0/1/8 UI chrome.
; U32ToAscii_B0_digitLoop: if val!=0 → U32ToAscii_B0_emitDigit; elif digits → U32ToAscii_B0_skipEmit → U32ToAscii_B0_setupReverse; else U32ToAscii_B0_emitDigit fall emit.
; U32ToAscii_B0_emitDigit/U32ToAscii_B0_emitDigit: U32Div+U32Mod; rem<$0a → '0'+n (U32ToAscii_B0_digit0to9) else U32ToAscii_B0_digitAtoF +$57 (U32ToAscii_B0_afterAlpha) → U32ToAscii_B0_digitLoop.
; U32ToAscii_B0_setupReverse: setup reverse; U32ToAscii_B0_copyLoop copy (U32ToAscii_B0_copyCont) → U32ToAscii_B0_writeNul NUL / plant "0".

U32ToAscii_B0::
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
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a

U32ToAscii_B0_digitLoop::
    ld hl, sp+$06
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, U32ToAscii_B0_emitDigit

    inc hl
    ld a, [hl]
    ld hl, sp+$04
    sub [hl]
    jp nz, U32ToAscii_B0_skipEmit

    ld hl, sp+$0b
    ld a, [hl]
    ld hl, sp+$05
    sub [hl]
    jp nz, U32ToAscii_B0_skipEmit

    jr U32ToAscii_B0_emitDigit

U32ToAscii_B0_skipEmit::
    jp U32ToAscii_B0_setupReverse


U32ToAscii_B0_emitDigit::
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
    call U32Div
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
    jp nc, U32ToAscii_B0_digitAtoF

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
    jr nz, U32ToAscii_B0_digit0to9

    inc hl
    inc [hl]

U32ToAscii_B0_digit0to9::
    jp U32ToAscii_B0_digitLoop


U32ToAscii_B0_digitAtoF::
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
    jr nz, U32ToAscii_B0_afterAlpha

    inc hl
    inc [hl]

U32ToAscii_B0_afterAlpha::
    jp U32ToAscii_B0_digitLoop


U32ToAscii_B0_setupReverse::
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

U32ToAscii_B0_copyLoop::
    ld a, c
    ld hl, sp+$00
    sub [hl]
    ld a, b
    inc hl
    sbc [hl]
    rlca
    jp nc, U32ToAscii_B0_writeNul

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
    jr nz, U32ToAscii_B0_copyCont

    inc hl
    inc [hl]

U32ToAscii_B0_copyCont::
    jp U32ToAscii_B0_copyLoop


U32ToAscii_B0_writeNul::
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    add sp, $33
    ret


; [ezgb]
; Source: kernel/stock/src/kernel.c
; Battery gate: FPGA SRAM page $11, read $A201 (expect $88 = not dry).
; ≠$88: draw BatteryDry* UI; BatteryCheck_waitA wait A ($10); jr_000_18cc write $A201=$88.
; BatteryCheck_enterSdMenu: teardown page0, call SdMenuMain. Orphan before BatteryDryPadStr.

BatteryCheck::
    ld hl, wDebugTextRow
    ld [hl], $00
    ld bc, $4000
    ld a, $11
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call FarCallTrampoline
    rst RST_20
    ld b, c
    inc b
    nop
    add sp, $01
    ld bc, $a201
    ld a, [bc]
    ld c, a
    sub $88
    jp z, BatteryCheck_enterSdMenu

    ld hl, $0805
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, BatteryDryPadStr
    push hl
    call DrawString
    add sp, $05
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $016c
    push hl
    ld hl, $7d25
    push hl
    ld a, $23
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, $0705
    push hl
    ld a, $07
    push af
    inc sp
    ld hl, BatteryDryTitleStr
    push hl
    call DrawString
    add sp, $05
    ld hl, $0805
    push hl
    ld a, $06
    push af
    inc sp
    ld hl, BatteryDryMsgStr
    push hl
    call DrawString
    add sp, $05
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $016a
    push hl
    ld hl, $7b5d
    push hl
    ld a, $4e
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, $0c0a
    push hl
    ld a, $05
    push af
    inc sp
    ld hl, BatteryDryOkStr
    push hl
    call DrawString
    add sp, $05

; [ezgb]
; Source: kernel/stock/src/kernel.c

BatteryCheck_waitA::
    call ReadJoypad
    ld c, e
    ld b, $00
    ld a, c
    and $10
    jr nz, jr_000_18cc

    jp BatteryCheck_waitA


jr_000_18cc:
    ld bc, $a201
    ld a, $88
    ld [bc], a

; [ezgb]
; Source: kernel/stock/src/kernel.c

BatteryCheck_enterSdMenu::
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld bc, $4000
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call FarCallTrampoline
    rst RST_20
    ld b, c
    inc b
    nop
    add sp, $01
    call SdMenuMain
    ret


BatteryDryPadStr::
    db " ", $00

; [ezgb]
; Source: kernel/stock/src/kernel.c
; BatteryDryTitleStr: NUL-term "BATTERY" for BatteryCheck dry notice.

BatteryDryTitleStr::
    db "BATTERY", $00

; [ezgb]
; Source: kernel/stock/src/kernel.c
; BatteryDryMsgStr: NUL-term "DRY!!!" for BatteryCheck dry notice.

BatteryDryMsgStr::
    db "DRY!!!", $00

; [ezgb]
; Source: kernel/stock/src/kernel.c
; BatteryDryOkStr: NUL-term "[A]OK" dismiss prompt for BatteryCheck.

BatteryDryOkStr::
    db "[A]OK", $00

; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c
; FarCall_06_7309: stack thunk → bank6:$7309 via FarCallTrampoline (embedded
; addr/bank after call). Siblings: FarCall_06_779a ($1928), FarCall_03_76cc
; ($1985), FarCall_03_768f ($1988), FarCall_09_77ff ($1998).

FarCall_06_7309::
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
    call FarCallTrampoline
    add hl, bc
    ld [hl], e
    ld b, $00
    add sp, $05
    ret


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

FarCall_06_779a::
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
    call FarCallTrampoline
    ld [hl], a
    ld [hl], a
    ld b, $00
    add sp, $08
    ret


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

FarCall_07_7739::
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
    call FarCallTrampoline
    add hl, sp
    ld [hl], a
    rlca
    nop
    add sp, $08
    ret


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c
; FarCall_03_76cc: 3-arg farcall to Lseek_B3 (03:76cc). Callers in bank1 push $ca0f
; (FIL/fp) plus ofs words — FatFs f_lseek.

FarCall_03_76cc::
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
    call FarCallTrampoline
    cp l
    halt
    inc bc
    nop
    add sp, $06
    ret


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

FarCall_03_768f::
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call FarCallTrampoline
    add b
    halt
    inc bc
    nop
    add sp, $02
    ret


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

FarCall_09_77ff::
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call FarCallTrampoline
    rst RST_38
    ld [hl], a
    add hl, bc
    nop
    add sp, $02
    ret


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

FarCall_05_4279::
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
    call FarCallTrampoline
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


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c
; FarCall_05_4378: stack thunk via FarCallTrampoline to 05:4378.
; Auto-proposed by scripts/propose-labels.py.

FarCall_05_4378::
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
    call FarCallTrampoline
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


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c
; DiskStatus(pdrv): FatFs disk_status stub — ld e,0 / ret (always ready).
; Callers test E bits STA_NOINIT ($01) / STA_PROTECT ($04) and map to FR_
; codes ($0c FR_NOT_ENABLED, $0a FR_WRITE_PROTECTED). Sibling DiskInitialize
; ($1a2c) is the same body; ReturnZero ($1a5e) is the no-arg FR_OK stub.

DiskStatus::
    ld e, $00
    ret


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c
; DiskInitialize(pdrv): FatFs disk_initialize stub — same ld e,0 / ret as
; DiskStatus. Mount path maps STA_NOINIT -> FR_NOT_READY ($03).

DiskInitialize::
    ld e, $00
    ret


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c
; FarCall stub: repack stack args, FarCallTrampoline to DiskRead_B2 (SD sector
; read), return E. Sibling FarCallDiskWrite ($1a3a) is the write path.

FarCallDiskRead::
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
    call FarCallTrampoline
    daa
    ld b, b
    ld [bc], a
    nop
    add sp, $07
    ld c, e
    ld e, c
    ret


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c
; FarCall stub: repack stack args, FarCallTrampoline to DiskWrite_B2 (SD sector
; write), return E. Sibling FarCallDiskRead ($1a16) is the read path.

FarCallDiskWrite::
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
    call FarCallTrampoline
    push de
    ld b, c
    ld [bc], a
    nop
    add sp, $07
    ld c, e
    ld e, c
    ret


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

ReturnZero::
    ld e, $00
    ret


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c
; MapCp437(code@sp+$07, dir@sp+$09) → DE. codes <$80 pass-through MapCp437_retDe. Table IBM CP437 high-half @1ed5.
; MapCp437_dirEncode dir!=0: if code≥$100 plant 0 → MapCp437_afterEncode; else MapCp437_tableLookup table[(code-$80)*2] → MapCp437_afterEncode → MapCp437_retDe.
; MapCp437_dirDecode dir==0: idx=0; MapCp437_decodeScan while idx<$80: cmp word (MapCp437_decodeCmp); miss MapCp437_decodeMiss ++idx (MapCp437_decodeCont) → MapCp437_decodeScan.
; Hit/exhaust MapCp437_decodeHit: idx+$80 → MapCp437_retDe ret.

MapCp437::
    push af
    push af
    dec sp
    ld hl, sp+$07
    ld a, [hl]
    sub $80
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, MapCp437_dirEncode

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    jp MapCp437_retDe


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

MapCp437_dirEncode::
    ld hl, sp+$09
    ld a, [hl+]
    or [hl]
    jp z, MapCp437_dirDecode

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
    jp z, MapCp437_tableLookup

    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp MapCp437_afterEncode


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

MapCp437_tableLookup::
    ld hl, sp+$07
    ld c, [hl]
    ld a, c
    add $80
    ld c, a
    ld b, $00
    sla c
    rl b
    ld hl, Cp437UnicodeTable
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

; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

MapCp437_afterEncode::
    ld hl, sp+$03
    ld c, [hl]
    inc hl
    ld b, [hl]
    jp MapCp437_retDe


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

MapCp437_dirDecode::
    ld hl, sp+$03
    ld [hl], $00
    inc hl
    ld [hl], $00

; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

MapCp437_decodeScan::
    ld hl, sp+$03
    ld a, [hl]
    sub $80
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, MapCp437_decodeHit

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    sla c
    rl b
    ld hl, Cp437UnicodeTable
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

; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

MapCp437_decodeCmp::
    ld hl, sp+$07
    ld a, [hl]
    sub c
    jp nz, MapCp437_decodeMiss

    inc hl
    ld a, [hl]
    sub b
    jp z, MapCp437_decodeHit

; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

MapCp437_decodeMiss::
    ld hl, sp+$03
    inc [hl]
    jr nz, MapCp437_decodeCont

    inc hl
    inc [hl]

; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

MapCp437_decodeCont::
    jp MapCp437_decodeScan


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

MapCp437_decodeHit::
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

; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

MapCp437_retDe::
    ld e, c
    ld d, b
    add sp, $05
    ret


Cp437UnicodeTable::
    db $c7, $00
    db $fc, $00
    db $e9, $00
    db $e2, $00
    db $e4, $00
    db $e0, $00
    db $e5, $00
    db $e7, $00
    db $ea, $00
    db $eb, $00
    db $e8, $00
    db $ef, $00
    db $ee, $00
    db $ec, $00
    db $c4, $00
    db $c5, $00
    db $c9, $00
    db $e6, $00
    db $c6, $00
    db $f4, $00
    db $f6, $00
    db $f2, $00
    db $fb, $00
    db $f9, $00
    db $ff, $00
    db $d6, $00
    db $dc, $00
    db $a2, $00
    db $a3, $00
    db $a5, $00
    db $a7, $20
    db $92, $01
    db $e1, $00
    db $ed, $00
    db $f3, $00
    db $fa, $00
    db $f1, $00
    db $d1, $00
    db $aa, $00
    db $ba, $00
    db $bf, $00
    db $10, $23
    db $ac, $00
    db $bd, $00
    db $bc, $00
    db $a1, $00
    db $ab, $00
    db $bb, $00
    db $91, $25
    db $92, $25
    db $93, $25
    db $02, $25
    db $24, $25
    db $61, $25
    db $62, $25
    db $56, $25
    db $55, $25
    db $63, $25
    db $51, $25
    db $57, $25
    db $5d, $25
    db $5c, $25
    db $5b, $25
    db $10, $25
    db $14, $25
    db $34, $25
    db $2c, $25
    db $1c, $25
    db $00, $25
    db $3c, $25
    db $5e, $25
    db $5f, $25
    db $5a, $25
    db $54, $25
    db $69, $25
    db $66, $25
    db $60, $25
    db $50, $25
    db $6c, $25
    db $67, $25
    db $68, $25
    db $64, $25
    db $65, $25
    db $59, $25
    db $58, $25
    db $52, $25
    db $53, $25
    db $6b, $25
    db $6a, $25
    db $18, $25
    db $0c, $25
    db $88, $25
    db $84, $25
    db $8c, $25
    db $90, $25
    db $80, $25
    db $b1, $03
    db $df, $00
    db $93, $03
    db $c0, $03
    db $a3, $03
    db $c3, $03
    db $b5, $00
    db $c4, $03
    db $a6, $03
    db $98, $03
    db $a9, $03
    db $b4, $03
    db $1e, $22
    db $c6, $03
    db $b5, $03
    db $29, $22
    db $61, $22
    db $b1, $00
    db $65, $22
    db $64, $22
    db $20, $23
    db $21, $23
    db $f7, $00
    db $48, $22
    db $b0, $00
    db $19, $22
    db $b7, $00
    db $1a, $22
    db $7f, $20
    db $b2, $00
    db $a0, $25
    db $a0, $00

; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c
; WToUpper(code@sp+$0a): FatFs WCHAR toupper → DE. Frame -$08.
; WToUpper_asciiGate: if code≥$80 → WToUpper_initSearch; else if not in 'a'..'z' → WToUpper_retDe; else code-=$20 → WToUpper_retDe.
; WToUpper_initSearch: init lo/hi/count; WToUpper_midKey: mid key from wWToUpperKeys; eq → DrawLine_xMajorErrAdd; else WToUpper_cmpKey.
; WToUpper_cmpKey: key<code → raise lo else DrawLine_xMajor lower hi; WToUpper_decCount --count; NZ → WToUpper_midKey else fall DrawLine_xMajorErrAdd.
; DrawLine_xMajorErrAdd: if count==0 miss → WToUpper_retDe; else replace from wWToUpperVals; WToUpper_retDe: DE=code ret.

WToUpper::
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

; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

WToUpper_asciiGate::
    jp nc, WToUpper_initSearch

    dec hl
    ld a, [hl]
    sub $61
    inc hl
    ld a, [hl]
    sbc $00
    jp c, WToUpper_retDe

    ld a, $7a
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp c, WToUpper_retDe

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
    jp WToUpper_retDe


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

WToUpper_initSearch::
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

; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

WToUpper_midKey::
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
    ld hl, wWToUpperKeys
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
    jp nz, WToUpper_cmpKey

    inc hl
    ld a, [hl]
    sub b
    jp z, WToUpper_hitOrMiss

; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

WToUpper_cmpKey::
    ld a, c
    ld hl, sp+$0a
    sub [hl]
    ld a, b
    inc hl
    sbc [hl]
    jp nc, WToUpper_lowerHi

    ld hl, sp+$06
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    jp WToUpper_decCount


; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

WToUpper_lowerHi::
    ld hl, sp+$06
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], e

; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

WToUpper_decCount::
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
    jp nz, WToUpper_midKey

; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

WToUpper_hitOrMiss::
    ld hl, sp+$04
    ld a, [hl+]
    or [hl]
    jp z, WToUpper_retDe

    inc hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    sla c
    rl b
    ld hl, wWToUpperVals
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

; [ezgb]
; Source: kernel/stock/src/fsglue.c, kernel/stock/src/diskio.c, kernel/stock/src/option/ccsbcs.c

WToUpper_retDe::
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $08
    ret


; [ezgb]
; Source: kernel/stock/sdcclib/crt0_rle.s
; RleUnpack: inline RLE decompress. HL=dest on entry; stream follows the call
; (pop return addr as src). Bit7 run vs literal; 0 terminates; ret past stream.
; Bank1 uses it to pack WToUpper tables into $CC33/$D00F and other WRAM blobs.
; RleUnpack_fetchLen: fetch len E; bit7 → run: load byte, RleUnpack_runStore store+inc E until wrap → loop.
; RleUnpack_literalOrDone: E==0 → RleUnpack_retPastStream push HL ret; else RleUnpack_copyLiteral copy E literals → 20be.

RleUnpack::
    ld c, l
    ld b, h
    pop hl

; [ezgb]
; Source: kernel/stock/sdcclib/crt0_rle.s

RleUnpack_fetchLen::
    ld e, [hl]
    inc hl
    bit 7, e
    jp z, RleUnpack_literalOrDone

    ld a, [hl]
    inc hl

; [ezgb]
; Source: kernel/stock/sdcclib/crt0_rle.s

RleUnpack_runStore::
    ld [bc], a
    inc bc
    inc e
    jp nz, RleUnpack_runStore

    jp RleUnpack_fetchLen


; [ezgb]
; Source: kernel/stock/sdcclib/crt0_rle.s

RleUnpack_literalOrDone::
    xor a
    or e
    jp z, RleUnpack_retPastStream

; [ezgb]
; Source: kernel/stock/sdcclib/crt0_rle.s

RleUnpack_copyLiteral::
    ld a, [hl]
    inc hl
    ld [bc], a
    inc bc
    dec e
    jp nz, RleUnpack_copyLiteral

    jp RleUnpack_fetchLen


; [ezgb]
; Source: kernel/stock/sdcclib/crt0_rle.s

RleUnpack_retPastStream::
    push hl
    ret


; [ezgb]
; Source: kernel/stock/src/libasm.s
; ApplyBasename(dest@sp+$02, src@sp+$04): strcpy incl. NUL (DrawLine_xMajorByteAdv).
; DirList uses this to copy entry names into the browser table.

ApplyBasename::
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a

; [ezgb]
; Source: kernel/stock/src/libasm.s

ApplyBasename_copyLoop::
    ld a, [de]
    inc de
    ld [hl], a
    and a
    ret z

    inc hl
    jr ApplyBasename_copyLoop

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; AdvanceTextCursor: ++wTextCursorX; wrap at $13 → X=0, ++Y; at Y=$11 → Y=0 (no scroll).
; AdvanceTextCursor_wrapX: X wrap + maybe ++Y; AdvanceTextCursor_wrapY: Y wrap to 0; AdvanceTextCursor_epilogueRet: pop HL ret.
; Mode-1 framebuffer text sibling of AdvanceTileCursor. Used by DrawGlyphAdvance.

AdvanceTextCursor::
    push hl
    ld hl, wTextCursorX
    ld a, $13
    cp [hl]
    jr z, AdvanceTextCursor_wrapX

    inc [hl]
    jr AdvanceTextCursor_epilogueRet

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

AdvanceTextCursor_wrapX::
    ld [hl], $00
    ld hl, wTextCursorY
    ld a, $11
    cp [hl]
    jr z, AdvanceTextCursor_wrapY

    inc [hl]
    jr AdvanceTextCursor_epilogueRet

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

AdvanceTextCursor_wrapY::
    ld [hl], $00

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

AdvanceTextCursor_epilogueRet::
    pop hl
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; DrawCircle: midpoint circle. BC=center, D=radius; wDrawRectFill selects outline (CirclePlot8) vs filled chords.
; Error in wCircleErr/$d72d. Stack wrapper DrawCircleXY ($23e7).
; DrawCircle_midpointLoop/DrawCircle_midpointLoop: while X1≤Y1; outline if fill==0; err≥0 → DrawCircle_errGe0 else CircleFillH + ++X1 +err+$06 loop.
; DrawCircle_errGe0: CircleFillV + ++X1 --Y1 +err+$0a → DrawCircle_midpointLoop.

DrawCircle::
    ld a, b
    ld [wDrawX0], a
    ld a, c
    ld [wDrawY0], a
    xor a
    ld [wDrawX1], a
    ld a, d
    ld [wDrawY1], a
    cpl
    ld l, a
    ld h, $ff
    inc hl
    ld bc, $0000
    add hl, bc
    ld a, l
    ld [$d706], a
    ld a, h
    ld [wCircleErr], a

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawCircle_midpointLoop::
    ld a, [wDrawX1]
    ld b, a
    ld a, [wDrawY1]
    sub b
    ret c

    ld a, [wDrawRectFill]
    or a
    call z, CirclePlot8
    ld a, [wCircleErr]
    bit 7, a
    jr z, DrawCircle_errGe0

    ld a, [wDrawRectFill]
    or a
    call nz, CircleFillH
    ld a, [wDrawX1]
    inc a
    ld [wDrawX1], a
    ld a, [wCircleErr]
    ld b, a
    ld a, [$d706]
    ld c, a
    ld h, $00
    ld a, [wDrawX1]
    ld l, a
    add hl, hl
    add hl, hl
    add hl, bc
    ld bc, $0006
    add hl, bc
    ld a, h
    ld [wCircleErr], a
    ld a, l
    ld [$d706], a
    jr DrawCircle_midpointLoop

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawCircle_errGe0::
    ld a, [wDrawRectFill]
    or a
    call nz, CircleFillV
    ld a, [wDrawX1]
    inc a
    ld [wDrawX1], a
    ld b, $00
    ld a, [wDrawX1]
    ld c, a
    ld h, $ff
    ld a, [wDrawY1]
    cpl
    ld l, a
    inc hl
    add hl, bc
    ld a, [wCircleErr]
    ld b, a
    ld a, [$d706]
    ld c, a
    add hl, hl
    add hl, hl
    add hl, bc
    ld bc, $000a
    add hl, bc
    ld a, h
    ld [wCircleErr], a
    ld a, l
    ld [$d706], a
    ld a, [wDrawY1]
    dec a
    ld [wDrawY1], a
    jp DrawCircle_midpointLoop


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

CircleFillH::
    ld a, [wDrawX0]
    ld b, a
    ld a, [wDrawY0]
    ld c, a
    ld a, [wDrawX1]
    ld d, a
    ld a, [wDrawY1]
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
    call DrawLine
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
    call DrawLine
    pop de
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

CircleFillV::
    ld a, [wDrawX0]
    ld b, a
    ld a, [wDrawY0]
    ld c, a
    ld a, [wDrawX1]
    ld d, a
    ld a, [wDrawY1]
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
    call DrawLine
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
    call DrawLine
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
    call DrawLine
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
    call DrawLine
    pop de
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; CirclePlot8: plot the 8 symmetric pixels for current (x,y) on the circle.

CirclePlot8::
    ld a, [wDrawX0]
    ld b, a
    ld a, [wDrawY0]
    ld c, a
    ld a, [wDrawX1]
    ld d, a
    ld a, [wDrawY1]
    ld e, a
    push bc
    push de
    ld a, b
    add d
    ld b, a
    ld a, c
    sub e
    ld c, a
    call PlotPixel
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
    call PlotPixel
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
    call PlotPixel
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
    call PlotPixel
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
    call PlotPixel
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
    call PlotPixel
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
    call PlotPixel
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
    call PlotPixel
    pop de
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; DrawRectImpl: normalize corners; outline via four DrawLine; optional fill if wDrawRectFill ($d724). Called by DrawRect.
; DrawRectImpl_afterSwapX: if X1<X0 swap; fall. jr_000_22ec: if Y1<Y0 swap; then L/R verts + inset top/bot horiz DrawLine.
; If fill==0 or empty inset ret; else swap wDrawColor/wDrawColorB; jr_000_1fb4: horiz DrawLine at Y0; if Y0!=Y1 ++Y0 loop.
; DrawRectImpl_restoreColors: restore colors (swap again) ret.

DrawRectImpl::
    ld a, [wDrawX0]
    ld b, a
    ld a, [wDrawX1]
    ld c, a
    sub b
    jr nc, DrawRectImpl_afterSwapX

    ld a, c
    ld [wDrawX0], a
    ld a, b
    ld [wDrawX1], a

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawRectImpl_afterSwapX::
    ld a, [wDrawY0]
    ld b, a
    ld a, [wDrawY1]
    ld c, a
    sub b
    jr nc, DrawRectImpl_drawOutline

    ld a, c
    ld [wDrawY0], a
    ld a, b
    ld [wDrawY1], a

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawRectImpl_drawOutline::
    ld a, [wDrawX0]
    ld b, a
    ld d, a
    ld a, [wDrawY0]
    ld c, a
    ld a, [wDrawY1]
    ld e, a
    call DrawLine
    ld a, [wDrawX1]
    ld b, a
    ld d, a
    ld a, [wDrawY0]
    ld c, a
    ld a, [wDrawY1]
    ld e, a
    call DrawLine
    ld a, [wDrawX0]
    inc a
    ld [wDrawX0], a
    ld a, [wDrawX1]
    dec a
    ld [wDrawX1], a
    ld a, [wDrawX0]
    ld b, a
    ld a, [wDrawX1]
    ld d, a
    ld a, [wDrawY0]
    ld c, a
    ld e, a
    call DrawLine
    ld a, [wDrawX0]
    ld b, a
    ld a, [wDrawX1]
    ld d, a
    ld a, [wDrawY1]
    ld c, a
    ld e, a
    call DrawLine
    ld a, [wDrawRectFill]
    or a
    ret z

    ld a, [wDrawX0]
    ld b, a
    ld a, [wDrawX1]
    sub b
    ret c

    ld a, [wDrawY0]
    inc a
    ld [wDrawY0], a
    ld a, [wDrawY1]
    dec a
    ld [wDrawY1], a
    ld a, [wDrawY0]
    ld b, a
    ld a, [wDrawY1]
    sub b
    ret c

    ld a, [wDrawColor]
    ld c, a
    ld a, [wDrawColorB]
    ld [wDrawColor], a
    ld a, c
    ld [wDrawColorB], a

jr_000_1fb4:
    ld a, [wDrawX0]
    ld b, a
    ld a, [wDrawX1]
    ld d, a
    ld a, [wDrawY0]
    ld c, a
    ld e, a
    call DrawLine
    ld a, [wDrawY1]
    ld b, a
    ld a, [wDrawY0]
    cp b
    jr z, DrawRectImpl_restoreColors

    inc a
    ld [wDrawY0], a
    jr jr_000_1fb4

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawRectImpl_restoreColors::
    ld a, [wDrawColor]
    ld c, a
    ld a, [wDrawColorB]
    ld [wDrawColor], a
    ld a, c
    ld [wDrawColorB], a
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; DrawLine: Bresenham. ABI BC=(x0,y0) DE=(x1,y1). |dy|@$d72a, |dx|@$d729; err wCircleErr/$d72d..$d731.
; Setup: DrawLine_absDy/SetTextCursor abs dy/dx; |dx|<|dy| → DrawLine_yMajor y-major; else DrawLine_maybeSwapEnds maybe swap ends; DrawLine_swapEndsDone/DrawLine_setYstepErr set $d72b ±ystep + GfxRowTable/err.
; X-major DrawLine_xMajor: err≥0 DrawLine_xMajorPlotYstep plot+ystep (DrawLine_xMajorRowWrapA/DrawLine_xMajorRowWrapB row wrap $0130/$fed0); else DrawLine_xMajorErrAdd err+=2dy; DrawLine_xMajorByteAdv/DrawLine_xMajorLoopDec byte advance; --E loop.
; Horiz DrawLine_horiz: DrawLine_horizMaskShift/DrawLine_horizMidRun/DrawLine_horizTailPixel/DrawLine_horizDoneCheck/DrawLine_horizMaskInit/DrawLine_horizMaskLoop/DrawLine_horizApplyPixel mask runs.
; Y-major DrawLine_yMajor: DrawLine_yMajorMaybeSwap/DrawLine_yMajorSwapDone/DrawLine_yMajorSetYstep swap+$d72b; dx==0 → DrawLine_vert; else U16DivMod_setup plot (DrawLine_yMajorAfterPlot), err DrawLine_yMajorErrCheck/DrawLine_yMajorXstep/DrawLine_yMajorErrAdd xstep → S32Sar_shiftLoop.
; Vert DrawLine_vert: DrawLine_vertApplyPixel/DrawLine_vertLoopDec ApplyPixel down. Callers: DrawRect edges + circle chords.

DrawLine::
    ld a, c
    sub e
    jr nc, DrawLine_absDy

    cpl
    inc a

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_absDy::
    ld [$d703], a
    ld h, a
    ld a, b
    sub d
    jr nc, DrawLine_absDx

    cpl
    inc a

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_absDx::
    ld [$d702], a
    sub h
    jp c, DrawLine_yMajor

    ld a, b
    sub d
    jp nc, DrawLine_maybeSwapEnds

    ld a, c
    sub e
    jr z, DrawLine_setYstepErr

    ld a, $00
    jr nc, DrawLine_setYstepErr

    ld a, $ff
    jr DrawLine_setYstepErr

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_maybeSwapEnds::
    ld a, e
    sub c
    jr z, DrawLine_swapEndsDone

    ld a, $00
    jr nc, DrawLine_swapEndsDone

    ld a, $ff

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_swapEndsDone::
    ld b, d
    ld c, e

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_setYstepErr::
    ld [$d704], a
    ld hl, GfxRowTable
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
    jp z, DrawLine_horiz

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
    ld [wCircleErr], a
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

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_xMajor::
    rrc c
    ld a, [wCircleErr]
    bit 7, a
    jr z, DrawLine_xMajorPlotYstep

    push de
    bit 7, c
    jr z, DrawLine_xMajorErrAdd

    ld a, b
    cpl
    ld c, a
    call ApplyPixel
    dec hl
    ld c, $80
    ld b, c

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_xMajorErrAdd::
    ld a, [$d706]
    ld d, a
    ld a, [$d708]
    add d
    ld [$d706], a
    ld a, [wCircleErr]
    ld d, a
    ld a, [$d707]
    adc d
    ld [wCircleErr], a
    pop de
    jr DrawLine_xMajorByteAdv

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_xMajorPlotYstep::
    push de
    push bc
    ld a, b
    cpl
    ld c, a
    call ApplyPixel
    ld a, [$d704]
    or a
    jr z, DrawLine_xMajorRowWrapA

    inc hl
    ld a, l
    and $0f
    jr nz, DrawLine_xMajorRowWrapB

    ld de, $0130
    add hl, de
    jr DrawLine_xMajorRowWrapB

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_xMajorRowWrapA::
    dec hl
    dec hl
    dec hl
    ld a, l
    and $0f
    xor $0e
    jr nz, DrawLine_xMajorRowWrapB

    ld de, $fed0
    add hl, de

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_xMajorRowWrapB::
    ld a, [$d706]
    ld d, a
    ld a, [$d70a]
    add d
    ld [$d706], a
    ld a, [wCircleErr]
    ld d, a
    ld a, [$d709]
    adc d
    ld [wCircleErr], a
    pop bc
    ld b, c
    pop de

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_xMajorByteAdv::
    bit 7, c
    jr z, DrawLine_xMajorLoopDec

    push de
    ld de, $0010
    add hl, de
    pop de
    ld b, c

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_xMajorLoopDec::
    ld a, b
    or c
    ld b, a
    dec e
    jp nz, DrawLine_xMajor

    ld a, b
    cpl
    ld c, a
    jp ApplyPixel


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_horiz::
    ld a, [$d702]
    ld e, a
    inc e
    ld a, b
    and $07
    jr z, DrawLine_horizMidRun

    push hl
    add $10
    ld l, a
    ld h, $00
    ld c, [hl]
    pop hl
    xor a

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_horizMaskShift::
    rrca
    or c
    dec e
    jr z, DrawLine_horizTailPixel

    bit 0, a
    jr z, DrawLine_horizMaskShift

    jr DrawLine_horizTailPixel

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_horizMidRun::
    ld a, e
    dec a
    and $f8
    jr z, DrawLine_horizMaskInit

    jr DrawLine_horizDoneCheck

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_horizTailPixel::
    ld b, a
    cpl
    ld c, a
    push de
    call ApplyPixel
    ld de, $000f
    add hl, de
    pop de

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_horizDoneCheck::
    ld a, e
    or a
    ret z

    and $f8
    jr z, DrawLine_horizMaskInit

    xor a
    ld c, a
    cpl
    ld b, a
    push de
    call ApplyPixel
    ld de, $000f
    add hl, de
    pop de
    ld a, e
    sub $08
    ret z

    ld e, a
    jr DrawLine_horizDoneCheck

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_horizMaskInit::
    ld a, $80

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_horizMaskLoop::
    dec e
    jr z, DrawLine_horizApplyPixel

    sra a
    jr DrawLine_horizMaskLoop

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_horizApplyPixel::
    ld b, a
    cpl
    ld c, a
    jp ApplyPixel


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_yMajor::
    ld a, c
    sub e
    jp nc, DrawLine_yMajorMaybeSwap

    ld a, b
    sub d
    jr z, DrawLine_yMajorSetYstep

    ld a, $00
    jr nc, DrawLine_yMajorSetYstep

    ld a, $ff
    jr DrawLine_yMajorSetYstep

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_yMajorMaybeSwap::
    ld a, c
    sub e
    jr z, DrawLine_yMajorSwapDone

    ld a, $00
    jr nc, DrawLine_yMajorSwapDone

    ld a, $ff

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_yMajorSwapDone::
    ld b, d
    ld c, e

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_yMajorSetYstep::
    ld [$d704], a
    ld hl, GfxRowTable
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
    jp z, DrawLine_vert

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
    ld [wCircleErr], a
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

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_yMajorPlot::
    push de
    push bc
    ld a, b
    cpl
    ld c, a
    call ApplyPixel
    inc hl
    ld a, l
    and $0f
    jr nz, DrawLine_yMajorAfterPlot

    ld de, $0130
    add hl, de

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_yMajorAfterPlot::
    pop bc
    ld a, [wCircleErr]
    bit 7, a
    jr z, DrawLine_yMajorErrCheck

    ld a, [$d706]
    ld d, a
    ld a, [$d708]
    add d
    ld [$d706], a
    ld a, [wCircleErr]
    ld d, a
    ld a, [$d707]
    adc d
    ld [wCircleErr], a
    jr DrawLine_yMajorLoopDec

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_yMajorErrCheck::
    ld a, [$d704]
    or a
    jr nz, DrawLine_yMajorXstep

    rlc b
    bit 0, b
    jr z, DrawLine_yMajorErrAdd

    ld de, $fff0
    add hl, de
    jr DrawLine_yMajorErrAdd

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_yMajorXstep::
    rrc b
    bit 7, b
    jr z, DrawLine_yMajorErrAdd

    ld de, $0010
    add hl, de

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_yMajorErrAdd::
    ld a, [$d706]
    ld d, a
    ld a, [$d70a]
    add d
    ld [$d706], a
    ld a, [wCircleErr]
    ld d, a
    ld a, [$d709]
    adc d
    ld [wCircleErr], a

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_yMajorLoopDec::
    pop de
    dec e
    jr nz, DrawLine_yMajorPlot

    ld a, b
    cpl
    ld c, a
    jp ApplyPixel


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_vert::
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

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_vertApplyPixel::
    push de
    call ApplyPixel
    inc hl
    ld a, l
    and $0f
    jr nz, DrawLine_vertLoopDec

    ld de, $0130
    add hl, de

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawLine_vertLoopDec::
    pop de
    dec e
    ret z

    jr DrawLine_vertApplyPixel

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; PlotPixel: set one pixel in the mode-1 framebuffer. Register ABI: B=x, C=y.
; Uses GfxRowTable ($2c02) for scanline->VRAM; x bit from ROM $0010 masks.
; Falls into ApplyPixel ($2291). Sibling GetPixel ($2313) reads the same address.

PlotPixel::
    ld hl, GfxRowTable
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

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; ApplyPixel: blit one masked pixel at HL (B=mask, C=~mask). STAT-safe VRAM RMW. wDrawColor@$D734 planes; wDrawOp@$D723.
; Dispatch: op1 → jr_000_22c5 OR; op2 → jr_000_22df XOR; op3 → jr_000_22f9 AND-clear; else replace.
; Replace: plane0 clear → B=0 then ApplyPixel_checkPlane1; plane1 clear → E=0; jr_000_22b2 STAT-wait and/or write lo/hi; maybe pop BC.
; OR jr_000_22c5: jr_000_22cc/jr_000_22d2 plane gates + STAT or-write. XOR jr_000_22df: jr_000_22e6/jr_000_22ec. AND jr_000_22f9: jr_000_2300/jr_000_2306.

ApplyPixel::
    ld a, [wDrawColor]
    ld d, a
    ld a, [wDrawOp]
    cp $01
    jr z, jr_000_22c5

    cp $02
    jr z, jr_000_22df

    cp $03
    jr z, jr_000_22f9

    ld e, b
    bit 0, d
    jr nz, ApplyPixel_checkPlane1

    push bc
    ld b, $00

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

ApplyPixel_checkPlane1::
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


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; GetPixel(B=x, C=y): same address math as PlotPixel; returns plane bits in E (0-3).
; U32DivImpl_runEngine: STAT-wait read 2bpp pair; mask from $10+(x&7).
; GetPixel_testPlane0: if plane0 bit clear skip; set0 B. GetPixel_retColor: plane1 bit → set1 B; E=B ret.

GetPixel::
    ld hl, GfxRowTable
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
    jr z, GetPixel_testPlane0

    set 0, b

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

GetPixel_testPlane0::
    ld a, e
    and c
    jr z, GetPixel_retColor

    set 1, b

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

GetPixel_retColor::
    ld e, b
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; DrawGlyph(C=tile): blit 8×8 from font sheet $3206 into framebuffer at wTextCursorX/Y via GfxRowTable.
; Setup: row ptr from GfxRowTable[Y<<3]; +X<<3; glyph base $3206+C*8; C=wDrawColor.
; jr_000_2377: A=*src++; B=src bits. colorB.0 → A=$ff else jr_000_2386; A|=B; color.0 clear → A^=B; jr_000_238c D=A.
; jr_000_238c: colorB.1 → A=$ff else jr_000_2393; A|=B; color.1 clear → A^=B; jr_000_2399 E=A; pop HL.
; jr_000_239b: STAT-wait; [HL++]=D,E; pop DE; if L&$0f → jr_000_2377 else ret. DrawGlyphAdvance wraps + AdvanceTextCursor.

DrawGlyph::
    ld hl, GfxRowTable
    ld d, $00
    ld a, [wTextCursorY]
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
    ld a, [wTextCursorX]
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
    ld de, FontGlyphSheet
    add hl, de
    ld d, h
    ld e, l
    ld h, b
    ld l, c
    ld a, [wDrawColor]
    ld c, a

jr_000_2377:
    ld a, [de]
    inc de
    push de
    push hl
    ld hl, wDrawColorB
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


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; SetTextCursor: store stack col/row into wTextCursorX/Y ($d732/$d733).

SetTextCursor::
    ld hl, sp+$02
    ld a, [hl+]
    ld [wTextCursorX], a
    ld a, [hl+]
    ld [wTextCursorY], a
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DrawGlyphAdvance::
    push bc
    ld a, [$d6a3]
    cp $01
    call nz, EnterGfxMode1
    ld hl, sp+$04
    ld a, [hl]
    ld c, a
    call DrawGlyph
    call AdvanceTextCursor
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; GetPixelXY: stack ABI (x, y) → GetPixel (B/C). Sibling of PlotPixelXY.

GetPixelXY::
    push bc
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    call GetPixel
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; StoreDrawParams: store wDrawColor/wDrawColorB/wDrawOp ($D734/$D735/$D723);
; called widely (~73 callers) before tile/string/pixel helpers.

StoreDrawParams::
    ld hl, sp+$02
    ld a, [hl+]
    ld [wDrawColor], a
    ld a, [hl+]
    ld [wDrawColorB], a
    ld a, [hl]
    ld [wDrawOp], a
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; DrawCircleXY: stack (x, y, r, fill); ensure EnterGfxMode1 then DrawCircle.

DrawCircleXY::
    push bc
    ld a, [$d6a3]
    cp $01
    call nz, EnterGfxMode1
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld d, a
    ld a, [hl]
    ld [wDrawRectFill], a
    call DrawCircle
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; DrawRect: if wGfxMode!=1 call EnterGfxMode1; copy 5 stack args into wDrawX0/Y0/
; X1/Y1/wDrawRectFill; call DrawRectImpl. C-shape ~ (u8 fill, u16, u16).
; Used e.g. from BatteryCheck chrome; generic (many callers).

DrawRect::
    push bc
    ld a, [$d6a3]
    cp $01
    call nz, EnterGfxMode1
    ld hl, sp+$04
    ld a, [hl+]
    ld [wDrawX0], a
    ld a, [hl+]
    ld [wDrawY0], a
    ld a, [hl+]
    ld [wDrawX1], a
    ld a, [hl+]
    ld [wDrawY1], a
    ld a, [hl]
    ld [wDrawRectFill], a
    call DrawRectImpl
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; DrawLineXY: stack ABI (x0,y0,x1,y1); ensure EnterGfxMode1 then DrawLine (BC/DE).
; Thin C wrapper; e.g. bank8 chrome draws horizontal rules via this.

DrawLineXY::
    push bc
    ld a, [$d6a3]
    cp $01
    call nz, EnterGfxMode1
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld e, a
    call DrawLine
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; PlotPixelXY: stack ABI (x, y); ensure EnterGfxMode1 then PlotPixel (B/C).
; Thin C wrapper over PlotPixel; used by bit-pattern glyph drawers.

PlotPixelXY::
    push bc
    ld a, [$d6a3]
    cp $01
    call nz, EnterGfxMode1
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    call PlotPixel
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; PlotPixelEx: stack (x, y, wDrawColor, wDrawOp); set params then PlotPixel.
; Like PlotPixelXY but also writes draw color/op before the blit.

PlotPixelEx::
    push bc
    ld a, [$d6a3]
    cp $01
    call nz, EnterGfxMode1
    ld hl, sp+$04
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld [wDrawColor], a
    ld a, [hl+]
    ld [wDrawOp], a
    call PlotPixel
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s
; U32Mul: SDCC runtime __mullong. Stub jp U32MulImpl ($2a08); multiplies two stack u32s,
; returns product in HL:DE. Body zeros a 4-byte acc then U32MulEngine (B=4)
; which uses MulU8xU8 (8x8->16 shift-add mul) per byte. Callers e.g. bank1
; scale time fields by 24/60. Sibling stubs: S32Div/U32Div/S32Mod/U32Mod.

U32Mul::
    jp U32MulImpl


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s
; S32Div: SDCC __divslong stub jp S32DivImpl ($262d). Signed long ÷; quotient in HL:DE.
; Zero/overflow via MemIsZero; uses signed negate helpers then unsigned engine.

S32Div::
    jp S32DivImpl


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s
; U32Div: SDCC __divulong stub jp U32DivImpl ($26be). Unsigned long ÷ via U32DivEngine;
; returns quotient from scratch. U32ToAscii uses this with radix.

U32Div::
    jp U32DivImpl


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s
; S32Mod: SDCC __modslong stub jp S32ModImpl ($276f). Signed long %; remainder in HL:DE.

S32Mod::
    jp S32ModImpl


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s
; U32Mod: SDCC __modulong stub jp U32ModImpl ($2843). Unsigned long %; U32ToAscii digit path.

U32Mod::
    jp U32ModImpl


    ld a, $05
    rst RST_08
    jp U16Mul


    ld a, $05
    rst RST_08
    jp S16Div


    ld a, $05
    rst RST_08
    jp U16Div


    ld a, $05
    rst RST_08
    jp S8Mul


    ld a, $05
    rst RST_08
    jp S8Div


    ld a, $05
    rst RST_08
    jp MulU8xU8Arg


    ld a, $05
    rst RST_08
    jp U8Div


    ld a, $05
    rst RST_08
    jp S8Mod


    ld a, $05
    rst RST_08
    jp U8Mod


    ld a, $05
    rst RST_08
    jp S16Mod


    ld a, $05
    rst RST_08
    jp U16Mod


    ld a, $05
    rst RST_08
    jp U32Shr


    ld a, $05
    rst RST_08
    jp S32Sar


    ld a, $05
    rst RST_08
    jp U32Shl


    ld a, $05
    rst RST_08
    jp U32Shl


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s
; S8Div: SDCC __divschar. Stack two s8; sex via S16DivSex8; quotient in DE.
; Siblings: S8Mod $289d, S16Div $28a9, S16Mod $28bd.

S8Div::
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call S16DivSex8
    ld e, c
    ld d, b
    ret


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s

S8Mod::
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call S16DivSex8
    ret


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s

S16Div::
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


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s

S16Mod::
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


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s
; U8Div: SDCC __divuchar. Stack two u8; zero-extends via U16DivZext8; returns
; quotient in DE. Bank4 decimal digit path: push 10 / n then call (n/10).

U8Div::
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call U16DivZext8
    ld e, c
    ld d, b
    ret


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s
; U8Mod: SDCC __moduchar. Same stack as U8Div; returns remainder in DE (n%10).

U8Mod::
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call U16DivZext8
    ret


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s
; U16Div: SDCC __divuint. Stack two u16; U16DivMod engine; quotient in DE.

U16Div::
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


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s
; U16Mod: SDCC __moduint. Stack two u16; remainder in DE.

U16Mod::
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


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s

S16DivSex8::
    ld a, c
    rlca
    sbc a
    ld b, a
    ld a, e
    rlca
    sbc a
    ld d, a

; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s
; S16DivMod(BC=dividend, DE=divisor): signed wrapper around U16DivMod.
; Abs DE if neg; S16DivMod_absDividend: abs BC if neg; S16DivMod_u16Div: U16DivMod (C set → early ret).
; S16DivMod_restoreSigns: restore quot sign (B^D) on BC; rem sign (dividend) on DE.

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

; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s

S16DivMod_absDividend::
    bit 7, b
    jr z, S16DivMod_u16Div

    sub a
    sub c
    ld c, a
    sbc a
    sub b
    ld b, a

; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s

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

; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s

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


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s

U16DivZext8::
    ld b, $00
    ld d, b

; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s
; U16DivMod: unsigned 16-bit restoring divide. BC/DE in → BC=quot, DE=rem.
; U16DivZext8 ($2590) zeros high bytes then falls in. S16DivMod ($255e) abs,
; calls this, re-applies signs.

U16DivMod::
    ld a, e
    or d
    jr nz, U16DivMod_setup

    ld bc, $0000
    ld d, b
    ld e, c
    scf
    ret


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s

U16DivMod_setup::
    ld l, c
    ld h, b
    ld bc, $0000
    or a
    ld a, $10

; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s

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
    jr c, U16DivMod_restoreBorrow

    pop bc
    jr U16DivMod_checkBit

; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s

U16DivMod_restoreBorrow::
    inc sp
    inc sp

; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s

U16DivMod_checkBit::
    jr c, U16DivMod_lastBit

    pop af
    dec a
    or a
    jr nz, U16DivMod_shiftLoop

    jr U16DivMod_finish

; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s

U16DivMod_lastBit::
    pop af
    dec a
    scf
    jr nz, U16DivMod_shiftLoop

; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s

U16DivMod_finish::
    ld d, b
    ld e, c
    rl l
    ld c, l
    rl h
    ld b, h
    or a
    ret


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s
; U32Shr: SDCC runtime, logical >> on unsigned long. Stack: u32 + shift count;
; returns in HL:DE. Sibling S32Sar ($25f3) uses sra; U32Shl ($2610) uses rl.
; High fan-in is every C << >> on longs — name from the loop, no emulator needed.
; U32Shr_shiftLoop: while count--: rr HL:DE (logical); count==0 ret.

U32Shr::
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

; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s

U32Shr_shiftLoop::
    or a
    ret z

    rr h
    rr l
    rr d
    rr e
    dec a
    jp U32Shr_shiftLoop


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s
; S32Sar: SDCC runtime, arithmetic >> on signed long (sra on high byte).
; Stack: s32 + shift count → HL:DE. S32Sar_shiftLoop: while count--: sra H, rr L/D/E; twin of U32Shr.

S32Sar::
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

; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s

S32Sar_shiftLoop::
    or a
    ret z

    sra h
    rr l
    rr d
    rr e
    dec a
    jp S32Sar_shiftLoop


; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s
; U32Shl: SDCC runtime, << on unsigned long. Stack: u32 + shift count → HL:DE.
; U32Shl_shiftLoop: while count--: rl E/D/L/H; twin of U32Shr/S32Sar.

U32Shl::
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

; [ezgb]
; Source: kernel/stock/sdcclib/stubs.s, kernel/stock/sdcclib/div.s, kernel/stock/sdcclib/shift.s

U32Shl_shiftLoop::
    or a
    ret z

    rl e
    rl d
    rl l
    rl h
    dec a
    jp U32Shl_shiftLoop


; [ezgb]
; Source: kernel/stock/src/libasm.s
; S32DivImpl: body of S32Div stub. Frame -$09; dividend@sp+$0b, divisor@sp+$0f → DEHL quotient.
; div0: MemIsZero dividend → DEHL=0 S32DivImpl_epilogueRet; else CStrLen_retLen.
; CStrLen_retLen: MemIsZero divisor → $d6c7=$21 + DEHL=$7fffffff S32DivImpl_epilogueRet; else S32DivImpl_clearSign.
; S32DivImpl_clearSign: clear sign@sp+$00; if divisor MSB set NegateBytes divisor + sign=1; fall S32DivImpl_checkDividendSign.
; S32DivImpl_checkDividendSign: if dividend MSB set NegateBytes dividend + xor sign; fall S32DivImpl_u32DivEngine.
; S32DivImpl_u32DivEngine: U32DivEngine → quot@sp+$01; rr sign → if set NegateBytes quot; S32DivImpl_loadQuot load DEHL; S32DivImpl_epilogueRet epilogue.

S32DivImpl::
    add sp, -$09
    ld b, $04
    ld hl, sp+$0b
    call MemIsZero
    jr nz, S32DivImpl_checkDivisor

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp S32DivImpl_epilogueRet


; [ezgb]
; Source: kernel/stock/src/libasm.s

S32DivImpl_checkDivisor::
    ld hl, sp+$0f
    call MemIsZero
    jr nz, S32DivImpl_clearSign

    ld a, $21
    ld [$d6a0], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp S32DivImpl_epilogueRet


; [ezgb]
; Source: kernel/stock/src/libasm.s

S32DivImpl_clearSign::
    ld hl, sp+$00
    xor a
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    bit 7, a
    jr z, S32DivImpl_checkDividendSign

    ld hl, sp+$0f
    call NegateBytes
    ld hl, sp+$00
    ld [hl], $01

; [ezgb]
; Source: kernel/stock/src/libasm.s

S32DivImpl_checkDividendSign::
    ld hl, sp+$0e
    ld a, [hl]
    bit 7, a
    jr z, S32DivImpl_u32DivEngine

    ld hl, sp+$0b
    call NegateBytes
    ld hl, sp+$00
    ld a, $01
    xor [hl]
    ld [hl], a

; [ezgb]
; Source: kernel/stock/src/libasm.s

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
    jr nc, S32DivImpl_loadQuot

    ld b, $04
    ld hl, sp+$01
    call NegateBytes

; [ezgb]
; Source: kernel/stock/src/libasm.s

S32DivImpl_loadQuot::
    ld hl, sp+$01
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

; [ezgb]
; Source: kernel/stock/src/libasm.s

S32DivImpl_epilogueRet::
    add sp, $09
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; VBlankCb_Bg8000: VBlank callback registered by EnterGfxMode1. Sets LCDC bit4
; (BG tile data $8000) and LYC=$48. Pair with LycCb_Bg8800 STAT LYC ISR.

VBlankCb_Bg8000::
    ldh a, [rLCDC]
    or $10
    ldh [rLCDC], a
    ld a, $48
    ldh [rLYC], a
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; LycCb_Bg8800: STAT LYC callback (EnterGfxMode1 → RegisterLcdCallback). Wait
; STAT mode≠2, clear LCDC bit4 (BG tile data back to $8800). Was LycCb_Bg8800.

LycCb_Bg8800::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, LycCb_Bg8800

    ldh a, [rLCDC]
    and $ef
    ldh [rLCDC], a
    ret


; [ezgb]
; Source: kernel/stock/src/libasm.s
; U32DivImpl: body of U32Div stub. Frame -$08; dividend@sp+$0a, divisor@sp+$0e → DEHL quotient.
; MemIsZero dividend → DEHL=0 U32DivImpl_epilogueRet; else U32DivImpl_checkDivisor.
; U32DivImpl_checkDivisor: MemIsZero divisor → $d6c7=$21 + DEHL=$7fffffff U32DivImpl_epilogueRet; else U32DivImpl_runEngine.
; U32DivImpl_runEngine: U32DivEngine → load quot@sp+$00 into DEHL; U32DivImpl_epilogueRet epilogue. Unsigned twin of S32DivImpl.

U32DivImpl::
    add sp, -$08
    ld b, $04
    ld hl, sp+$0a
    call MemIsZero
    jr nz, U32DivImpl_checkDivisor

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp U32DivImpl_epilogueRet


; [ezgb]
; Source: kernel/stock/src/libasm.s

U32DivImpl_checkDivisor::
    ld hl, sp+$0e
    call MemIsZero
    jr nz, U32DivImpl_runEngine

    ld a, $21
    ld [$d6a0], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp U32DivImpl_epilogueRet


; [ezgb]
; Source: kernel/stock/src/libasm.s

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

; [ezgb]
; Source: kernel/stock/src/libasm.s

U32DivImpl_epilogueRet::
    add sp, $08
    ret


; [ezgb]
; Source: kernel/stock/src/libasm.s
; MemIsZero: scan B bytes at HL; Z if all zero else NZ. Used by U32/S32 div/mod
; stubs to reject zero dividend/divisor before U32DivEngine.
; MemIsZero_scanLoop: while C--: *HL++==0 else NZ ret; fallthrough Z ret.

MemIsZero::
    xor a
    ld c, b

; [ezgb]
; Source: kernel/stock/src/libasm.s

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


; [ezgb]
; Source: kernel/stock/src/libasm.s
; ClearNegZero32: HL→MSB of 4-byte LE value; if value is 0 or $80000000,
; clear sign bit (force -0 → +0). Used by S32Cmp.
; ClearNegZero32_matchMsb: if bit7 clear A=0 else A=$80; match MSB then scan 3 lower bytes==0 → res 7.

ClearNegZero32::
    xor a
    bit 7, [hl]
    jr z, ClearNegZero32_matchMsb

    ld a, $80

; [ezgb]
; Source: kernel/stock/src/libasm.s

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


; [ezgb]
; Source: kernel/stock/src/libasm.s
; MemCmp3Down: compare 3 bytes at DE vs HL walking downward; NZ on first diff.
; Local helper for S32Cmp MSB-side compare.
; MemCmp3Down_cmpLoop: C=3; *DE-*HL; NZ ret; dec both; --C; Z after 3 → equal ret.

MemCmp3Down::
    ld c, $03

; [ezgb]
; Source: kernel/stock/src/libasm.s

MemCmp3Down_cmpLoop::
    ld a, [de]
    sub [hl]
    ret nz

    dec de
    dec hl
    dec c
    ret z

    jr MemCmp3Down_cmpLoop

; [ezgb]
; Source: kernel/stock/src/libasm.s
; S32Cmp: signed long compare sp+$07 vs sp+$0b (MSB high). ClearNegZero32 both; then sign-dispatch + MemCmp3Down.
; a MSB set: if b also neg → MemCmp3Down swapped; else S32Cmp_retALess C-set (a<b) ret.
; CopyBytes: a pos; if b neg → A=$ff ret; else jr_000_2767 MemCmp3Down a vs b.
; No external callers in this build (SDCC runtime residue).

S32Cmp::
    ld hl, sp+$07
    call ClearNegZero32
    ld hl, sp+$0b
    call ClearNegZero32
    ld hl, sp+$07
    bit 7, [hl]
    jr z, jr_000_275e

    ld hl, sp+$0b
    bit 7, [hl]
    jr z, S32Cmp_retALess

    ld hl, sp+$0b
    ld d, h
    ld e, l
    ld hl, sp+$07
    jr MemCmp3Down

; [ezgb]
; Source: kernel/stock/src/libasm.s

S32Cmp_retALess::
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
    jr MemCmp3Down

; [ezgb]
; Source: kernel/stock/src/libasm.s
; S32ModImpl: body of S32Mod stub (twin of S32DivImpl). Frame -$09; dividend@sp+$0b, divisor@sp+$0f → DEHL rem.
; div0: MemIsZero dividend → DEHL=0 S32ModImpl_epilogueRet; else EnterGfxMode1_vramFill.
; EnterGfxMode1_vramFill: MemIsZero divisor → $d6c7=$21 + DEHL=$7fffffff S32ModImpl_epilogueRet; else S32ModImpl_clearSign.
; S32ModImpl_clearSign: clear sign@sp+$00; if divisor MSB set NegateBytes divisor + sign=1; fall S32ModImpl_checkDividendSign.
; S32ModImpl_checkDividendSign: if dividend MSB set NegateBytes dividend + xor sign; fall S32ModImpl_u32DivEngine.
; S32ModImpl_u32DivEngine: U32DivEngine → rem@sp+$05; rr sign → if set NegateBytes rem; S32ModImpl_loadRem load DEHL; S32ModImpl_epilogueRet epilogue.

S32ModImpl::
    add sp, -$09
    ld b, $04
    ld hl, sp+$0b
    call MemIsZero
    jr nz, S32ModImpl_checkDivisor

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp S32ModImpl_epilogueRet


; [ezgb]
; Source: kernel/stock/src/libasm.s

S32ModImpl_checkDivisor::
    ld hl, sp+$0f
    call MemIsZero
    jr nz, S32ModImpl_clearSign

    ld a, $21
    ld [$d6a0], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp S32ModImpl_epilogueRet


; [ezgb]
; Source: kernel/stock/src/libasm.s

S32ModImpl_clearSign::
    ld hl, sp+$00
    xor a
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl]
    bit 7, a
    jr z, S32ModImpl_checkDividendSign

    ld hl, sp+$0f
    call NegateBytes
    ld hl, sp+$00
    ld [hl], $01

; [ezgb]
; Source: kernel/stock/src/libasm.s

S32ModImpl_checkDividendSign::
    ld hl, sp+$0e
    ld a, [hl]
    bit 7, a
    jr z, S32ModImpl_u32DivEngine

    ld hl, sp+$0b
    call NegateBytes
    ld hl, sp+$00
    ld a, $01
    xor [hl]
    ld [hl], a

; [ezgb]
; Source: kernel/stock/src/libasm.s

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
    jr nc, S32ModImpl_loadRem

    ld b, $04
    xor a
    ld hl, sp+$05
    call NegateBytes

; [ezgb]
; Source: kernel/stock/src/libasm.s

S32ModImpl_loadRem::
    ld hl, sp+$05
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

; [ezgb]
; Source: kernel/stock/src/libasm.s

S32ModImpl_epilogueRet::
    add sp, $09
    ret


; [ezgb]
; Source: kernel/stock/src/libasm.s
; S8Mul: sex two stack s8 → s16, then U16Mul. Bank-5 RST stub jp target.

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
    jr U16Mul_initHl0

; [ezgb]
; Source: kernel/stock/src/libasm.s
; MulU8xU8Arg: stack two u8 → C/E then MulU8xU8. Entry just above register ABI body.

MulU8xU8Arg::
    ld hl, sp+$02
    ld a, [hl+]
    ld c, a
    ld e, [hl]

; [ezgb]
; Source: kernel/stock/src/libasm.s
; MulU8xU8(C×E) → DE: 8×8→16 shift-add. HL=0; MulU8xU8_rrC: rr C, C-set → add hl,de.
; MulU8xU8_shiftE: sla e / rl d; MulU8xU8_finish finish when DE shifted out. Used by U32MulEngine.

MulU8xU8::
    xor a
    ld h, a
    ld l, a
    ld d, a

; [ezgb]
; Source: kernel/stock/src/libasm.s

MulU8xU8_rrC::
    xor a
    rr c
    jr nc, MulU8xU8_shiftE

    add hl, de

; [ezgb]
; Source: kernel/stock/src/libasm.s

MulU8xU8_shiftE::
    sla e
    jr z, MulU8xU8_finish

    rl d
    jr MulU8xU8_rrC

; [ezgb]
; Source: kernel/stock/src/libasm.s

MulU8xU8_finish::
    rl d
    jr nz, MulU8xU8_rrC

    ld e, l
    ld d, h
    ret


; [ezgb]
; Source: kernel/stock/src/libasm.s
; U16Mul(a@sp+$02, b@sp+$04) → DE: shift-add (Russian peasant). Load DE=a, BC=b.
; U16Mul_initHl0: HL=0; fall U16Mul_loop. U16Mul_loop: sra B; NZ → U16Mul_rrCPath else rr C; C-set add HL,DE; U16Mul_afterAddLo.
; U16Mul_afterAddLo: Z after rr → U16Mul_retDe else U16Mul_slaE. U16Mul_rrCPath: rr C; NC → U16Mul_slaE else add HL,DE; fall U16Mul_slaE.
; U16Mul_slaE: sla E; Z → U16Mul_rlDOnly else rl D → U16Mul_loop. U16Mul_rlDOnly: rl D; NZ → U16Mul_loop; fall U16Mul_retDe DE=HL ret.

U16Mul::
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld c, [hl]
    inc hl
    ld b, [hl]

; [ezgb]
; Source: kernel/stock/src/libasm.s

U16Mul_initHl0::
    ld hl, $0000

; [ezgb]
; Source: kernel/stock/src/libasm.s

U16Mul_loop::
    sra b
    jr nz, U16Mul_rrCPath

    rr c
    jr nc, U16Mul_afterAddLo

    add hl, de

; [ezgb]
; Source: kernel/stock/src/libasm.s

U16Mul_afterAddLo::
    jr z, U16Mul_retDe

    jr U16Mul_slaE

; [ezgb]
; Source: kernel/stock/src/libasm.s

U16Mul_rrCPath::
    rr c
    jr nc, U16Mul_slaE

    add hl, de

; [ezgb]
; Source: kernel/stock/src/libasm.s

U16Mul_slaE::
    sla e
    jr z, U16Mul_rlDOnly

    rl d
    jr U16Mul_loop

; [ezgb]
; Source: kernel/stock/src/libasm.s

U16Mul_rlDOnly::
    rl d
    jr nz, U16Mul_loop

; [ezgb]
; Source: kernel/stock/src/libasm.s

U16Mul_retDe::
    ld e, l
    ld d, h
    ret


; [ezgb]
; Source: kernel/stock/src/libasm.s
; U32ModImpl: body of U32Mod stub. Twin of U32DivImpl; frame -$08; rem@sp+$04 → DEHL.
; MemIsZero dividend → DEHL=0 U32ModImpl_epilogueRet; else U32ModImpl_checkDivisor.
; U32ModImpl_checkDivisor: MemIsZero divisor → $d6c7=$21 + DEHL=$7fffffff U32ModImpl_epilogueRet; else U32ModImpl_runEngine.
; U32ModImpl_runEngine: U32DivEngine → load rem@sp+$04 into DEHL; U32ModImpl_epilogueRet epilogue.

U32ModImpl::
    add sp, -$08
    ld b, $04
    ld hl, sp+$0a
    call MemIsZero
    jr nz, U32ModImpl_checkDivisor

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp U32ModImpl_epilogueRet


; [ezgb]
; Source: kernel/stock/src/libasm.s

U32ModImpl_checkDivisor::
    ld hl, sp+$0e
    call MemIsZero
    jr nz, U32ModImpl_runEngine

    ld a, $21
    ld [$d6a0], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp U32ModImpl_epilogueRet


; [ezgb]
; Source: kernel/stock/src/libasm.s

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

; [ezgb]
; Source: kernel/stock/src/libasm.s

U32ModImpl_epilogueRet::
    add sp, $08
    ret


; [ezgb]
; Source: kernel/stock/sdcclib/_strrchr.c
; Strrchr(ptr@sp+$06, ch@sp+$08): last char in string → DE (0 if none). Used for '/' basename.
; Strrchr_scanToNul: ++BC until NUL; stash end@sp+$00. Strrchr_walkBack: --ptr; if at start → Strrchr_recheckMatch else Strrchr_cmpChar.
; Strrchr_cmpChar: *ptr!=ch → Strrchr_mismatch → Strrchr_walkBack; else Strrchr_recheckMatch. Strrchr_recheckMatch/Strrchr_recheckMatch: recheck match.
; Hit Strrchr_hitPtr DE=ptr → Strrchr_epilogueRet; miss Strrchr_missSkip → Strrchr_missZero DE=0 → Strrchr_epilogueRet ret.

Strrchr::
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

; [ezgb]
; Source: kernel/stock/sdcclib/_strrchr.c

Strrchr_scanToNul::
    ld a, [bc]
    inc bc
    or a
    jp nz, Strrchr_scanToNul

    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b

; [ezgb]
; Source: kernel/stock/sdcclib/_strrchr.c

Strrchr_walkBack::
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
    jp nz, Strrchr_cmpChar

    dec hl
    ld a, [hl+]
    inc hl
    sub [hl]
    jp z, Strrchr_recheckMatch

; [ezgb]
; Source: kernel/stock/sdcclib/_strrchr.c

Strrchr_cmpChar::
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld hl, sp+$08
    sub [hl]
    jp nz, Strrchr_mismatch

    jr Strrchr_recheckMatch

; [ezgb]
; Source: kernel/stock/sdcclib/_strrchr.c

Strrchr_mismatch::
    jp Strrchr_walkBack


; [ezgb]
; Source: kernel/stock/sdcclib/_strrchr.c

Strrchr_recheckMatch::
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld hl, sp+$08
    sub [hl]
    jp nz, Strrchr_missSkip

    jr Strrchr_hitPtr

; [ezgb]
; Source: kernel/stock/sdcclib/_strrchr.c

Strrchr_missSkip::
    jp Strrchr_missZero


; [ezgb]
; Source: kernel/stock/sdcclib/_strrchr.c

Strrchr_hitPtr::
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    jp Strrchr_epilogueRet


; [ezgb]
; Source: kernel/stock/sdcclib/_strrchr.c

Strrchr_missZero::
    ld de, $0000

; [ezgb]
; Source: kernel/stock/sdcclib/_strrchr.c

Strrchr_epilogueRet::
    add sp, $04
    ret


; [ezgb]
; Source: kernel/stock/src/libasm.s
; Memset(dest, byte, len): fill dest with byte. Sibling of Memcpy.
; Memset_fillLoop: while BC≠0: *HL++=D, --BC. Stack: dest@sp+$02, byte@+$04, len@+$05.

Memset::
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

; [ezgb]
; Source: kernel/stock/src/libasm.s

Memset_fillLoop::
    ld a, b
    or c
    ret z

    dec bc
    ld [hl], d
    inc hl
    jr Memset_fillLoop

; [ezgb]
; Source: kernel/stock/src/libasm.s
; Memcpy(dest, src, len).
; Memcpy_copyLoop: while BC≠0: *HL++=*DE++, --BC. Stack: dest@sp+$02, src@+$04, len@+$06.

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

; [ezgb]
; Source: kernel/stock/src/libasm.s

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

; [ezgb]
; Source: kernel/stock/sdcclib/_strncpy.c
; Strncpy(dest, src, n): frame -$07; stash dest@sp+$01, src@sp+$03, n=BC, ret-dest@sp+$05.
; Strncpy_copyLoop: if BC==0 or *src==0 → Strncpy_stashRem; else --BC, ++src (Strncpy_incSrc carry), *dest++=A (Strncpy_afterStore carry) → Strncpy_copyLoop.
; Strncpy_stashRem: stash rem n@sp+$03; Strncpy_padLoop: --n; if 0 → Strncpy_retDest else *dest++=0 (Strncpy_padCont carry) → Strncpy_padLoop.
; Strncpy_retDest: DE=orig dest; add sp,$07 ret.

Strncpy::
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

; [ezgb]
; Source: kernel/stock/sdcclib/_strncpy.c

Strncpy_copyLoop::
    ld a, c
    or b
    jp z, Strncpy_stashRem

    ld hl, sp+$03
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$00
    ld [hl], a
    or a
    jp z, Strncpy_stashRem

    dec bc
    ld a, [hl]
    ld hl, sp+$03
    inc [hl]
    jr nz, Strncpy_incSrc

    inc hl
    inc [hl]

; [ezgb]
; Source: kernel/stock/sdcclib/_strncpy.c

Strncpy_incSrc::
    ld hl, sp+$01
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, Strncpy_afterStore

    inc hl
    inc [hl]

; [ezgb]
; Source: kernel/stock/sdcclib/_strncpy.c

Strncpy_afterStore::
    jp Strncpy_copyLoop


; [ezgb]
; Source: kernel/stock/sdcclib/_strncpy.c

Strncpy_stashRem::
    ld hl, sp+$03
    ld [hl], c
    inc hl
    ld [hl], b

; [ezgb]
; Source: kernel/stock/sdcclib/_strncpy.c

Strncpy_padLoop::
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
    jp z, Strncpy_retDest

    ld hl, sp+$01
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    dec hl
    inc [hl]
    jr nz, Strncpy_padCont

    inc hl
    inc [hl]

; [ezgb]
; Source: kernel/stock/sdcclib/_strncpy.c

Strncpy_padCont::
    jp Strncpy_padLoop


; [ezgb]
; Source: kernel/stock/sdcclib/_strncpy.c

Strncpy_retDest::
    ld hl, sp+$05
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $07
    ret


; [ezgb]
; Source: kernel/stock/src/libasm.s
; NegateBytes: two's-complement negate of B bytes at HL (0-sbc loop).
; S32Div/S32Mod use this to abs signed long operands.
; NegateBytes_sbcLoop: D=0; for C=B: *HL++ = D-sbc-*HL (borrow chain); ret.

NegateBytes::
    ld c, b
    xor a
    ld d, a

; [ezgb]
; Source: kernel/stock/src/libasm.s

NegateBytes_sbcLoop::
    ld a, d
    sbc [hl]
    ld [hl+], a
    dec c
    jr nz, NegateBytes_sbcLoop

    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; PrintCharArg: stack u8 → PrintChar (A). Thin C ABI wrapper.

PrintCharArg::
    push bc
    ld hl, sp+$04
    ld a, [hl]
    call PrintChar
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; PutBgTileArg: stack u8 → PutBgTile (A). Thin C ABI wrapper.

PutBgTileArg::
    push bc
    ld hl, sp+$04
    ld a, [hl]
    call PutBgTile
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; SetTileCursor: stack (x, y) → wTileCursorX/Y. Tile-text cursor (vs SetTextCursor).

SetTileCursor::
    ld hl, sp+$02
    ld a, [hl+]
    ld [wTileCursorX], a
    ld a, [hl]
    ld [wTileCursorY], a
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; GetTileCursorX: ensure EnterGfxMode2 if needed; return wTileCursorX in E.
; GetTileCursorX_retX: if wGfxMode bit1 clear → EnterGfxMode2; then E=wTileCursorX.

GetTileCursorX::
    ld a, [$d6a3]
    and $02
    jr nz, GetTileCursorX_retX

    push bc
    call EnterGfxMode2
    pop bc

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

GetTileCursorX_retX::
    ld a, [wTileCursorX]
    ld e, a
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; GetTileCursorY: ensure EnterGfxMode2 if needed; return wTileCursorY in E.
; jr_000_2d90: if wGfxMode bit1 clear → EnterGfxMode2; then E=wTileCursorY.

GetTileCursorY::
    ld a, [$d6a3]
    and $02
    jr nz, GetTileCursorY_retY

    push bc
    call EnterGfxMode2
    pop bc

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

GetTileCursorY_retY::
    ld a, [wTileCursorY]
    ld e, a
    ret


; [ezgb]
; Source: kernel/stock/sdcclib/_strlen.c
; CStrLen(s): count bytes until NUL; length in DE. (Not Strlen — RGBDS STRLEN.)
; CStrLen_scan: while *s++: ++len@sp+$00 (CStrLen_incCont); CStrLen_retLen DE=len ret.

CStrLen::
    push af
    ld hl, sp+$00
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]

; [ezgb]
; Source: kernel/stock/sdcclib/_strlen.c

CStrLen_scan::
    ld a, [bc]
    inc bc
    or a
    jp z, CStrLen_retLen

    ld hl, sp+$00
    inc [hl]
    jr nz, CStrLen_incCont

    inc hl
    inc [hl]

; [ezgb]
; Source: kernel/stock/sdcclib/_strlen.c

CStrLen_incCont::
    jp CStrLen_scan


; [ezgb]
; Source: kernel/stock/sdcclib/_strlen.c

CStrLen_retLen::
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $02
    ret


; [ezgb]
; Source: kernel/stock/src/libasm.s
; MemZero: write 0 to B bytes at HL. U32DivEngine clears quot/rem scratch with this.
; MemZero_fillLoop: C=B; store A=0 via [HL+], dec C until zero.

MemZero::
    ld c, b
    xor a

; [ezgb]
; Source: kernel/stock/src/libasm.s

MemZero_fillLoop::
    ld [hl+], a
    dec c
    jr nz, MemZero_fillLoop

    ret


; [ezgb]
; Source: kernel/stock/src/libasm.s
; U32MulImpl: body of U32Mul stub. Thin frame around U32MulEngine with B=4.

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


; [ezgb]
; Source: kernel/stock/src/libasm.s
; U32DivEngine: multi-byte restoring divide used by U32Div/U32Mod. Helpers:
; MemZero, MemRol ($2b29), MemSubCmp ($2b1f), MemSub ($2a77), IncWord ($2b12).
; B=digit width; C=B*8 bit count. Zero quot+rem scratch; U32DivEngine_bitLoop: rol rem←dividend,
; MemSubCmp divisor; NC → MemSub; U32DivEngine_rolQuot: rol quot bit; --C loop. Orphan before MemSub.

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
    call MemZero
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call MemZero

; [ezgb]
; Source: kernel/stock/src/libasm.s

U32DivEngine_bitLoop::
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    xor a
    call MemRol
    push af
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    pop af
    push hl
    call MemRol
    pop de
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push de
    push hl
    call MemSubCmp
    pop hl
    pop de
    jr c, U32DivEngine_rolQuot

    call MemSub

; [ezgb]
; Source: kernel/stock/src/libasm.s

U32DivEngine_rolQuot::
    ccf
    push af
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    pop af
    call MemRol
    pop bc
    dec c
    ret z

    push bc
    jr U32DivEngine_bitLoop

; [ezgb]
; Source: kernel/stock/src/libasm.s
; MemSub: multi-byte SBC: [DE] -= [HL] for B bytes (carry chain). U32DivEngine rem -= divisor.
; MemSub_sbcLoop: C=B; A=[DE] SBC [HL] → [DE]; ++HL/DE; until C=0.

MemSub::
    ld c, b

; [ezgb]
; Source: kernel/stock/src/libasm.s

MemSub_sbcLoop::
    ld a, [de]
    sbc [hl]
    ld [de], a
    inc hl
    inc de
    dec c
    jr nz, MemSub_sbcLoop

    ret


; [ezgb]
; Source: kernel/stock/src/libasm.s
; MemFill: store A into B bytes at HL++ (register ABI). Orphan between MemSub and U32MulEngine.
; MemFill_fillLoop: C=B; store A via [HL+], dec C until zero.

MemFill::
    ld c, b

; [ezgb]
; Source: kernel/stock/src/libasm.s

MemFill_fillLoop::
    ld [hl+], a
    dec c
    jr nz, MemFill_fillLoop

    ret


; [ezgb]
; Source: kernel/stock/src/libasm.s
; U32MulEngine: multi-byte unsigned mul (B digit pairs). Zeros dest via MemZero,
; per-byte MulU8xU8 + PropagateCarry. U32Mul stub drives this with B=4.
; U32MulEngine_outerSetup/U32MulEngine_innerDigit: inner digit cross-products; add to dest + PropagateCarry; IncWord ptrs.
; U32MulEngine_nextOuter: next outer digit (CopyBytes reset ptrs) → 2e5e; U32MulEngine_epilogueRet ret when B exhausted.

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
    call MemZero
    ld hl, sp+$04
    ld [hl], b

; [ezgb]
; Source: kernel/stock/src/libasm.s

U32MulEngine_outerSetup::
    ld hl, sp+$04
    ld a, [hl]
    ld hl, sp+$05
    ld [hl], a

; [ezgb]
; Source: kernel/stock/src/libasm.s

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
    call MulU8xU8
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
    call PropagateCarry
    ld hl, sp+$05
    dec [hl]
    jr z, U32MulEngine_nextOuter

    ld hl, sp+$0c
    call IncWord
    ld hl, sp+$08
    call IncWord
    jr U32MulEngine_innerDigit

; [ezgb]
; Source: kernel/stock/src/libasm.s

U32MulEngine_nextOuter::
    ld hl, sp+$04
    dec [hl]
    jr z, U32MulEngine_epilogueRet

    ld hl, sp+$00
    call IncWord
    ld hl, sp+$0a
    call IncWord
    push bc
    ld b, $02
    ld hl, sp+$02
    ld d, h
    ld e, l
    ld hl, sp+$0a
    call CopyBytes
    ld hl, sp+$04
    ld d, h
    ld e, l
    ld hl, sp+$0e
    call CopyBytes
    pop bc
    jp U32MulEngine_outerSetup


; [ezgb]
; Source: kernel/stock/src/libasm.s

U32MulEngine_epilogueRet::
    add sp, $06
    ret


; [ezgb]
; Source: kernel/stock/src/libasm.s
; PropagateCarry: walk C bytes at HL adding 0+carry (adc). After multi-byte add in mul.

PropagateCarry::
    dec c
    ret z

    ld a, $00
    adc [hl]
    ld [hl+], a
    jr PropagateCarry

; [ezgb]
; Source: kernel/stock/src/libasm.s
; IncWord: ++*(u16*)HL (inc low, carry into high).

IncWord::
    inc [hl]
    ret nz

    inc hl
    inc [hl]
    ret


; [ezgb]
; Source: kernel/stock/src/libasm.s
; CopyBytes: copy B bytes DE→HL (register ABI).
; CopyBytes_copyLoop: C=B; A=[DE++] → [HL+]; until C=0.

CopyBytes::
    ld c, b

; [ezgb]
; Source: kernel/stock/src/libasm.s

CopyBytes_copyLoop::
    ld a, [de]
    inc de
    ld [hl+], a
    dec c
    jr nz, CopyBytes_copyLoop

    ret


; [ezgb]
; Source: kernel/stock/src/libasm.s
; MemSubCmp: multi-byte SBC compare [DE] vs [HL] for B bytes (no store). Flags = last SBC; U32DivEngine trial rem>=divisor.
; MemSubCmp_sbcLoop: C=B; A=[DE] SBC [HL]; ++HL/DE; until C=0 (result discarded, carry retained).

MemSubCmp::
    ld c, b
    xor a

; [ezgb]
; Source: kernel/stock/src/libasm.s

MemSubCmp_sbcLoop::
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    dec c
    jr nz, MemSubCmp_sbcLoop

    ret


; [ezgb]
; Source: kernel/stock/src/libasm.s
; MemRol: rotate-left B bytes at HL through carry (RL [HL]). U32DivEngine shifts rem←dividend bit.
; MemRol_rlLoop: C=B; RL [HL]; ++HL; until C=0.

MemRol::
    ld c, b

; [ezgb]
; Source: kernel/stock/src/libasm.s

MemRol_rlLoop::
    rl [hl]
    inc hl
    dec c
    jr nz, MemRol_rlLoop

    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; EnterGfxMode1: LCD off if on; prep VRAM/tilemap/callbacks; LCD on; wGfxMode=1.
; Defaults: wDrawOp=0, wDrawColor=3, wDrawColorB=0. Draw helpers call this when wGfxMode!=1.
; EnterGfxMode1_vramFill: VramFill $8100×$1680; VBlankCb_Bg8000 + LycCb_Bg8800; LYC=$48 STAT=$44; IE bit1.
; EnterGfxMode1_rowSetup: E=$12 rows; EnterGfxMode1_fillRow: fill 20 tiles/row ids $10+ (skip 12); LCDC on; ei ret.

EnterGfxMode1::
    di
    ldh a, [rLCDC]
    bit 7, a
    jr z, EnterGfxMode1_vramFill

    call LcdOff

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

EnterGfxMode1_vramFill::
    ld hl, $8100
    ld de, $1680
    ld b, $00
    call VramFill
    ld bc, VBlankCb_Bg8000
    call RegisterVBlankCallback
    ld bc, LycCb_Bg8800
    call RegisterLcdCallback
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

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

EnterGfxMode1_rowSetup::
    ld d, $14

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

EnterGfxMode1_fillRow::
    ld [hl+], a
    inc a
    dec d
    jr nz, EnterGfxMode1_fillRow

    add hl, bc
    dec e
    jr nz, EnterGfxMode1_rowSetup

    ldh a, [rLCDC]
    or $91
    and $f7
    ldh [rLCDC], a
    ld a, $01
    ld [$d6a3], a
    ld a, $00
    ld [wDrawOp], a
    ld a, $03
    ld [wDrawColor], a
    ld a, $00
    ld [wDrawColorB], a
    ei
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; VramLoadTiles8100: VramCopy BC→$8100 for $1680 bytes (tile $10+ framebuffer pool).
; Stack wrapper ensures EnterGfxMode1 first.

VramLoadTiles8100::
    ld hl, $8100
    ld de, $1680
    call VramCopy
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; BlitTile: B/C tile row/col via GfxRowTable; VramCopy $10 bytes (2bpp tile) to FB.
; Optional second plane from saved DE. Stack wrapper ensures EnterGfxMode1.
; BlitTile_copyPlane2: dest=GfxRowTable[col]+row*16 on stack; if HL==0 skip first VramCopy $10; then pop dest + DE and VramCopy $10 (2nd plane).

BlitTile::
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
    ld hl, GfxRowTable
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
    jr z, BlitTile_copyPlane2

    ld de, $0010
    call VramCopy

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

BlitTile_copyPlane2::
    pop hl
    pop bc
    ld de, $0010
    call VramCopy
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; BlitTileXY: ensure mode-1; stack args → BlitTile (B/C/DE/HL).

BlitTileXY::
    push bc
    ld a, [$d6a3]
    cp $01
    call nz, EnterGfxMode1
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
    call BlitTile
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; VramLoadTiles8100Arg: ensure mode-1; stack BC → VramLoadTiles8100.

VramLoadTiles8100Arg::
    push bc
    ld a, [$d6a3]
    cp $01
    call nz, EnterGfxMode1
    ld hl, sp+$04
    ld a, [hl+]
    ld c, a
    ld b, [hl]
    call VramLoadTiles8100
    pop bc
    ret


GfxRowTable::
    db $00, $81
    db $02, $81
    db $04, $81
    db $06, $81
    db $08, $81
    db $0a, $81
    db $0c, $81
    db $0e, $81
    db $40, $82
    db $42, $82
    db $44, $82
    db $46, $82
    db $48, $82
    db $4a, $82
    db $4c, $82
    db $4e, $82
    db $80, $83
    db $82, $83
    db $84, $83
    db $86, $83
    db $88, $83
    db $8a, $83
    db $8c, $83
    db $8e, $83
    db $c0, $84
    db $c2, $84
    db $c4, $84
    db $c6, $84
    db $c8, $84
    db $ca, $84
    db $cc, $84
    db $ce, $84
    db $00, $86
    db $02, $86
    db $04, $86
    db $06, $86
    db $08, $86
    db $0a, $86
    db $0c, $86
    db $0e, $86
    db $40, $87
    db $42, $87
    db $44, $87
    db $46, $87
    db $48, $87
    db $4a, $87
    db $4c, $87
    db $4e, $87
    db $80, $88
    db $82, $88
    db $84, $88
    db $86, $88
    db $88, $88
    db $8a, $88
    db $8c, $88
    db $8e, $88
    db $c0, $89
    db $c2, $89
    db $c4, $89
    db $c6, $89
    db $c8, $89
    db $ca, $89
    db $cc, $89
    db $ce, $89
    db $00, $8b
    db $02, $8b
    db $04, $8b
    db $06, $8b
    db $08, $8b
    db $0a, $8b
    db $0c, $8b
    db $0e, $8b
    db $40, $8c
    db $42, $8c
    db $44, $8c
    db $46, $8c
    db $48, $8c
    db $4a, $8c
    db $4c, $8c
    db $4e, $8c
    db $80, $8d
    db $82, $8d
    db $84, $8d
    db $86, $8d
    db $88, $8d
    db $8a, $8d
    db $8c, $8d
    db $8e, $8d
    db $c0, $8e
    db $c2, $8e
    db $c4, $8e
    db $c6, $8e
    db $c8, $8e
    db $ca, $8e
    db $cc, $8e
    db $ce, $8e
    db $00, $90
    db $02, $90
    db $04, $90
    db $06, $90
    db $08, $90
    db $0a, $90
    db $0c, $90
    db $0e, $90
    db $40, $91
    db $42, $91
    db $44, $91
    db $46, $91
    db $48, $91
    db $4a, $91
    db $4c, $91
    db $4e, $91
    db $80, $92
    db $82, $92
    db $84, $92
    db $86, $92
    db $88, $92
    db $8a, $92
    db $8c, $92
    db $8e, $92
    db $c0, $93
    db $c2, $93
    db $c4, $93
    db $c6, $93
    db $c8, $93
    db $ca, $93
    db $cc, $93
    db $ce, $93
    db $00, $95
    db $02, $95
    db $04, $95
    db $06, $95
    db $08, $95
    db $0a, $95
    db $0c, $95
    db $0e, $95
    db $40, $96
    db $42, $96
    db $44, $96
    db $46, $96
    db $48, $96
    db $4a, $96
    db $4c, $96
    db $4e, $96

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; VramCopy: copy DE bytes BC→HL waiting for STAT mode≠2 (VRAM-safe).
; VramCopyStack ($2d31) is the stack-ABI wrapper (dest, src, len).

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


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

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


    ld hl, DefaultFontData
    call RegisterFont
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DefaultFontData::
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

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

FontGlyphSheet::
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

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

StarGlyph8::
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

    jr ReadJoypadRaw_readFace

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
    call ReadJoypadRaw
    or a
    jr nz, jr_000_364f

    dec b
    jr nz, jr_000_3651

    pop bc
    pop af
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; ReadJoypadRaw: hardware P1 read → packed buttons in A (then swapped for menu ABI).
; ReadJoypadRaw_readFace: after d-pad nibble ($20 select), swap into B; read face buttons ($10); OR; final swap; P1=$30 idle.

ReadJoypadRaw::
    push bc
    ld a, $20
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    cpl
    and $0f

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

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


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; WaitJoypadMask: spin on ReadJoypadRaw until (A & B) nonzero. B = mask.

WaitJoypadMask::
    call ReadJoypadRaw
    and b
    jr z, WaitJoypadMask

    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; ReadJoypad: returns the menu key byte (post-swap: A=$10, B=$20, START=$80).
; ReadJoypadRaw ($365d) is the lower-level read that ends with the swap.

ReadJoypad::
    call ReadJoypadRaw
    ld e, a
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; WaitJoypadMaskArg: stack mask → WaitJoypadMask (B); return pressed in E.

WaitJoypadMaskArg::
    push bc
    ld hl, sp+$04
    ld b, [hl]
    call WaitJoypadMask
    ld e, a
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; DelayDE: push BC; DelayInner(DE); B=$32; DelayDE_padLoop pad loop; nop; pop BC; trail; ret. Used by Delay($3a93).
; DelayDE_padLoop → DelayDE_padA → DelayDE_padB → DelayDE_padC → DelayDE_padD → DelayDE_padDecB: five jr pads then --B; NZ → DelayDE_padLoop.
; After pad: nop; pop BC; DelayDE_trailA → DelayDE_trailB → DelayDE_ret → ret (three more jr pads).

DelayDE::
    push bc
    call DelayInner
    ld b, $32

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DelayDE_padLoop::
    jr DelayDE_padA

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DelayDE_padA::
    jr DelayDE_padB

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DelayDE_padB::
    jr DelayDE_padC

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DelayDE_padC::
    jr DelayDE_padD

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DelayDE_padD::
    jr DelayDE_padDecB

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DelayDE_padDecB::
    dec b
    jp nz, DelayDE_padLoop

    nop
    pop bc
    jr DelayDE_trailA

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DelayDE_trailA::
    jr DelayDE_trailB

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DelayDE_trailB::
    jr DelayDE_ret

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DelayDE_ret::
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; DelayInner: --DE; if DE==0 ret; else B=$33; DelayInner_padLoop pad; nop; trail; jr DelayInner. Nested core for DelayDE.
; DelayInner_padLoop → DelayInner_padA → DelayInner_padB → DelayInner_padC → DelayInner_padD → DelayInner_padDecB: five jr pads then --B; NZ → DelayInner_padLoop.
; After pad: nop; DelayInner_trailA → DelayInner_trailB → DelayInner_outerLoop → DelayInner (three jr pads then outer loop).

DelayInner::
    dec de
    ld a, e
    or d
    ret z

    ld b, $33

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DelayInner_padLoop::
    jr DelayInner_padA

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DelayInner_padA::
    jr DelayInner_padB

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DelayInner_padB::
    jr DelayInner_padC

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DelayInner_padC::
    jr DelayInner_padD

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DelayInner_padD::
    jr DelayInner_padDecB

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DelayInner_padDecB::
    dec b
    jp nz, DelayInner_padLoop

    nop
    jr DelayInner_trailA

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DelayInner_trailA::
    jr DelayInner_trailB

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DelayInner_trailB::
    jr DelayInner_outerLoop

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

DelayInner_outerLoop::
    jr DelayInner

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; Delay(count): stack u16 → DelayDE. Busy-wait; callers pass e.g. $00c8/$002d.
; DelayDE ($36a0) + DelayInner ($36bd) are the register/nested loops.

Delay::
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    call DelayDE
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; CopyTilesVram(HL=dst VRAM, BC=src, DE=count): plain 2bpp byte-pair blit (no color remap). Sibling CopyTilesColor.
; DE==0 early ret; H≥$98 → H-=$10. CopyTilesVram_checkE: if E==0 --D; CopyTilesVram_waitStatLo STAT-wait [HL++]=[BC++]; CopyTilesVram_waitStatHi STAT-wait second byte.
; CopyTilesVram_decCount: --E; NZ → CopyTilesVram_waitStatLo; --D; if D signed clear → CopyTilesVram_waitStatLo else ret. H wrap $98→$88 after lo-byte wrap.

CopyTilesVram::
    ld a, d
    or e
    ret z

    ld a, h
    cp $98
    jr c, CopyTilesVram_checkE

    sub $10
    ld h, a

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

CopyTilesVram_checkE::
    xor a
    cp e
    jr nz, CopyTilesVram_waitStatLo

    dec d

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

CopyTilesVram_waitStatLo::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, CopyTilesVram_waitStatLo

    ld a, [bc]
    ld [hl+], a
    inc bc

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

CopyTilesVram_waitStatHi::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, CopyTilesVram_waitStatHi

    ld a, [bc]
    ld [hl], a
    inc bc
    inc l
    jr nz, CopyTilesVram_decCount

    inc h
    ld a, h
    cp $98
    jr nz, CopyTilesVram_decCount

    ld h, $88

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

CopyTilesVram_decCount::
    dec e
    jr nz, CopyTilesVram_waitStatLo

    dec d
    bit 7, d
    jr z, CopyTilesVram_waitStatLo

    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; CopyTilesColor(HL=dst VRAM, BC=src, DE=count): 2bpp byte-pair blit with wDrawColor/wDrawColorB remap. DE==0 early ret; H≥$98 → H-=$10.
; CopyTilesColor_loop: load *src++; colorB.0 → B=$ff else CopyTilesColor_afterColorB0; colorB.1 → C=$ff else CopyTilesColor_xorMask.
; CopyTilesColor_xorMask: D=color^colorB; bit0 → B^=src (else CopyTilesColor_afterBit0); bit1 → C^=src (else CopyTilesColor_statWaitB).
; CopyTilesColor_statWaitB: STAT-wait [HL++]=B; CopyTilesColor_statWaitC: STAT-wait [HL++]=C; H==$98 → $88; CopyTilesColor_decCount: --DE; NZ → CopyTilesColor_loop else ret. Used by UploadFontTiles.

CopyTilesColor::
    ld a, d
    or e
    ret z

    ld a, h
    cp $98
    jr c, CopyTilesColor_loop

    sub $10
    ld h, a

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

CopyTilesColor_loop::
    push de
    ld a, [bc]
    ld e, a
    inc bc
    push bc
    ld bc, $0000
    ld a, [wDrawColorB]
    bit 0, a
    jr z, CopyTilesColor_afterColorB0

    ld b, $ff

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

CopyTilesColor_afterColorB0::
    bit 1, a
    jr z, CopyTilesColor_xorMask

    ld c, $ff

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

CopyTilesColor_xorMask::
    ld d, a
    ld a, [wDrawColor]
    xor d
    ld d, a
    bit 0, d
    jr z, CopyTilesColor_afterBit0

    ld a, e
    xor b
    ld b, a

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

CopyTilesColor_afterBit0::
    bit 1, d
    jr z, CopyTilesColor_statWaitB

    ld a, e
    xor c
    ld c, a

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

CopyTilesColor_statWaitB::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, CopyTilesColor_statWaitB

    ld [hl], b
    inc hl

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

CopyTilesColor_statWaitC::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, CopyTilesColor_statWaitC

    ld [hl], c
    inc hl
    ld a, h
    cp $98
    jr nz, CopyTilesColor_decCount

    ld h, $88

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

CopyTilesColor_decCount::
    pop bc
    pop de
    dec de
    ld a, d
    or e
    jr nz, CopyTilesColor_loop

    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; RegisterFont(HL=font desc): LCD off; find free 3-byte slot in wFontSlots ($d73a,
; 6 entries); store next-tile id + font ptr; SelectFont; if wGfxMode bit1 set,
; UploadFontTiles; bump wFontNextTile by glyph count; LCD on. Returns HL=slot or 0.
; RegisterFont_scanSlots: scan slots; free → RegisterFont_storeSlot store+SelectFont+maybe Upload; full → HL=0.
; RegisterFont_lcdOn: LCDC on ($81 & ~$18) ret. Orphan before UploadFontTiles.

RegisterFont::
    call LcdOff
    push hl
    ld hl, $d714
    ld b, $06

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

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
    jr RegisterFont_lcdOn

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

RegisterFont_storeSlot::
    pop de
    ld [hl], d
    dec hl
    ld [hl], e
    ld a, [wFontNextTile]
    dec hl
    ld [hl], a
    push hl
    call SelectFont
    ld a, [$d6a3]
    and $02
    call nz, UploadFontTiles
    ld hl, wFontPtr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    inc hl
    ld a, [wFontNextTile]
    add [hl]
    ld [wFontNextTile], a
    pop hl

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

RegisterFont_lcdOn::
    ldh a, [rLCDC]
    or $81
    and $e7
    ldh [rLCDC], a
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; UploadFontTiles: blit current font glyphs into VRAM near $9000+wFontBaseTile.
; Uses CopyTilesVram ($36e3) or CopyTilesColor ($3719) per font header flags.
; UploadFontTiles_blitGlyphs: glyph src offset BC from header lo2 ($01→$80, $02→$0, else $100); dest=$9000+base*16; bit2→Color else Vram.

UploadFontTiles::
    ld hl, wFontPtr
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

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

UploadFontTiles_blitGlyphs::
    inc hl
    inc hl
    add hl, bc
    ld c, l
    ld b, h
    ld a, [wFontBaseTile]
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
    jp z, CopyTilesVram

    jp CopyTilesColor


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; SelectFont: copy slot triple → wFontBaseTile / wFontPtr / wFontFarFlag.

SelectFont::
    ld a, [hl+]
    ld [wFontBaseTile], a
    ld a, [hl+]
    ld [wFontPtr], a
    ld a, [hl+]
    ld [wFontFarFlag], a
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; PrintChar(A): if A==$0a TileNewline (unless wGfxMode bit3); else PutBgTile
; then AdvanceTileCursor. Tilemap text path (cursor wTileCursorX/Y).

PrintChar::
    cp $0a
    jr nz, PrintChar_putChar

    push af
    ld a, [$d6a3]
    and $08
    jr nz, PrintChar_skipNewline

    call TileNewline
    pop af
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

PrintChar_skipNewline::
    pop af

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

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


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; PutBgTile(A): map char through font at wFontPtr → tile id at BG $9800+y*32+x (wTileCursorY/X). STAT-safe.
; If wFontFarFlag==0: ResetTileText + FarCallTrampoline; PutBgTile_afterFarCall nop fallthrough.
; PutBgTile_mapGlyph: if font hdr&3!=2 index glyph table else keep A; PutBgTile_addBaseTile +wFontBaseTile; map ptr; PutBgTile_waitStatStore STAT-wait store E.

PutBgTile::
    push af
    ld a, [wFontFarFlag]
    or a
    jr nz, PutBgTile_mapGlyph

    call ResetTileText
    xor a
    ld [wFontNextTile], a
    call FarCallTrampoline
    ld b, h
    dec l
    nop

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

PutBgTile_afterFarCall::
    nop

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

PutBgTile_mapGlyph::
    pop af
    push bc
    push de
    push hl
    ld e, a
    ld hl, wFontPtr
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

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

PutBgTile_addBaseTile::
    ld a, [wFontBaseTile]
    add e
    ld e, a
    ld a, [wTileCursorY]
    ld l, a
    ld h, $00
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld a, [wTileCursorX]
    ld c, a
    ld b, $00
    add hl, bc
    ld bc, $9800
    add hl, bc

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

PutBgTile_waitStatStore::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, PutBgTile_waitStatStore

    ld [hl], e
    pop hl
    pop de
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; RegisterFontArg: stack font-desc ptr → RegisterFont (HL); return slot in DE.

RegisterFontArg::
    push bc
    ld hl, sp+$04
    ld a, [hl]
    inc hl
    ld h, [hl]
    ld l, a
    call RegisterFont
    push hl
    pop de
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; SelectFontArg: stack font-desc ptr → SelectFont (HL); returns DE=0.

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


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; ResetTileText: EnterGfxMode2 path prep — InitGfxMode2 via $3d21, wFontNextTile=1,
; clear wFontSlots, default draw colors, ClearBgMap.
; ResetTileText_clearSlots: zero $12 bytes at wFontSlots; then wDrawColor=3 / wDrawColorB=0; ClearBgMap.

ResetTileText::
    push bc
    call EnterGfxMode2
    ld a, $01
    ld [wFontNextTile], a
    xor a
    ld hl, wFontSlots
    ld b, $12

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

ResetTileText_clearSlots::
    ld [hl+], a
    dec b
    jr nz, ResetTileText_clearSlots

    ld a, $03
    ld [wDrawColor], a
    ld a, $00
    ld [wDrawColorB], a
    call ClearBgMap
    pop bc
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; ClearBgMap: fill BG map $9800 with tile 0 (32×32), STAT-safe.
; ClearBgMap_rowSetup: 32 rows; ClearBgMap_waitStatWrite: STAT-wait write 0, 32 cols/row. Orphan before RetreatTileCursor.

ClearBgMap::
    push de
    push hl
    ld hl, $9800
    ld e, $20

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

ClearBgMap_rowSetup::
    ld d, $20

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

ClearBgMap_waitStatWrite::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, ClearBgMap_waitStatWrite

    ld [hl], $00
    inc hl
    dec d
    jr nz, ClearBgMap_waitStatWrite

    dec e
    jr nz, ClearBgMap_rowSetup

    pop hl
    pop de
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; RetreatTileCursor: --wTileCursorX; at X=0 wrap to $13 and --Y (clamp at Y=0).
; RetreatTileCursor_wrapX: X wrap + maybe --Y; RetreatTileCursor_epilogueRet: pop HL ret. Inverse of AdvanceTileCursor.

RetreatTileCursor::
    push hl
    ld hl, wTileCursorX
    xor a
    cp [hl]
    jr z, RetreatTileCursor_wrapX

    dec [hl]
    jr RetreatTileCursor_epilogueRet

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

RetreatTileCursor_wrapX::
    ld [hl], $13
    ld hl, wTileCursorY
    xor a
    cp [hl]
    jr z, RetreatTileCursor_epilogueRet

    dec [hl]

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

RetreatTileCursor_epilogueRet::
    pop hl
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; TileNewline: wTileCursorX=0; ++Y or ScrollBgUp at bottom row ($11).
; TileNewline_scrollBg: Y==$11 → ScrollBgUp; else ++Y; TileNewline_epilogueRet ret. Used by PrintChar on $0a.

TileNewline::
    push hl
    xor a
    ld [wTileCursorX], a
    ld hl, wTileCursorY
    ld a, $11
    cp [hl]
    jr z, TileNewline_scrollBg

    inc [hl]
    jr TileNewline_epilogueRet

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

TileNewline_scrollBg::
    call ScrollBgUp

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

TileNewline_epilogueRet::
    pop hl
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; AdvanceTileCursor: ++wTileCursorX; wrap at $13 and bump Y (tilemap text).
; AdvanceTileCursor_wrapX: X wrap → Y++; at Y=$11 → AdvanceTileCursor_checkGfxMode: if wGfxMode bit2 set reset cursors else AdvanceTileCursor_scrollBg ScrollBgUp.
; AdvanceTileCursor_epilogueRet: pop HL ret. Sibling of AdvanceTextCursor.

AdvanceTileCursor::
    push hl
    ld hl, wTileCursorX
    ld a, $13
    cp [hl]
    jr z, AdvanceTileCursor_wrapX

    inc [hl]
    jr AdvanceTileCursor_epilogueRet

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

AdvanceTileCursor_wrapX::
    ld [hl], $00
    ld hl, wTileCursorY
    ld a, $11
    cp [hl]
    jr z, AdvanceTileCursor_checkGfxMode

    inc [hl]
    jr AdvanceTileCursor_epilogueRet

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

AdvanceTileCursor_checkGfxMode::
    ld a, [$d6a3]
    and $04
    jr z, AdvanceTileCursor_scrollBg

    xor a
    ld [wTileCursorY], a
    ld [wTileCursorX], a
    jr AdvanceTileCursor_epilogueRet

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

AdvanceTileCursor_scrollBg::
    call ScrollBgUp

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

AdvanceTileCursor_epilogueRet::
    pop hl
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; ScrollBgUp: shift BG map $9800 up one row (31 row copies $9820→$9800). Called by AdvanceTileCursor.
; ScrollBgUp_rowSetup: D=$20 tiles/row; ScrollBgUp_copyTile: STAT-wait copy [BC]→[HL++]; --E rows.
; ScrollBgUp_clearBottom: STAT-wait clear bottom row to 0; pop HL/DE/BC ret.

ScrollBgUp::
    push bc
    push de
    push hl
    ld hl, $9800
    ld bc, $9820
    ld e, $1f

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

ScrollBgUp_rowSetup::
    ld d, $20

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

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
    jr nz, ScrollBgUp_rowSetup

    ld d, $20

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

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


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; EnterGfxMode2: tear down mode-1 VBlank/LCD callbacks if LCD on, InitGfxMode2
; (clear cursors + BG, wGfxMode=2), restore LCDC. Tilemap text mode.
; EnterGfxMode2_initAndEnableLcd: if LCD already off skip LcdOff+RemoveCallbackSlot; then InitGfxMode2, LCDC|=$81 &=$E7, ei.

EnterGfxMode2::
    di
    ldh a, [rLCDC]
    bit 7, a
    jr z, EnterGfxMode2_initAndEnableLcd

    call LcdOff
    ld bc, VBlankCb_Bg8000
    ld hl, wVBlankCallbacks
    call RemoveCallbackSlot
    ld bc, LycCb_Bg8800
    ld hl, wLcdCallbacks
    call RemoveCallbackSlot

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

EnterGfxMode2_initAndEnableLcd::
    call InitGfxMode2
    ldh a, [rLCDC]
    or $81
    and $e7
    ldh [rLCDC], a
    ei
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

InitGfxMode2::
    xor a
    ld [wTileCursorX], a
    ld [wTileCursorY], a
    call ClearBgMap
    ld a, $02
    ld [$d6a3], a
    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; VramFill: STAT-safe fill — wait mode≠2, write B to [HL++) DE times. EnterGfxMode1
; zeros $8100.. with this; VramFillActiveWinMap/BgMap clear $9800/$9C00 ($0400).

VramFill::
    ldh a, [rSTAT]
    and $02
    jr nz, VramFill

    ld [hl], b
    inc hl
    dec de
    ld a, d
    or e
    jr nz, VramFill

    ret


; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; VramFillActiveWinMap: pick window tilemap base from LCDC bit6 ($9800/$9C00),
; then VramFill $0400 bytes with B. Sibling VramFillActiveBgMap uses BG map bit3.
; VramFillActiveWinMap_map9C00: bit6 set → HL=$9C00; else $9800; both jr to shared $3d86 VramFill tail.

VramFillActiveWinMap::
    ldh a, [rLCDC]
    bit 6, a
    jr nz, VramFillActiveWinMap_map9C00

    ld hl, $9800
    jr VramFillActiveBgMap_doFill

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

VramFillActiveWinMap_map9C00::
    ld hl, $9c00
    jr VramFillActiveBgMap_doFill

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s
; VramFillActiveBgMap: pick BG tilemap base from LCDC bit3 ($9800/$9C00), then
; VramFill $0400 bytes with B. Shares tail at $3d86 with VramFillActiveWinMap.
; VramFillActiveBgMap_use9c00: bit3 set → HL=$9C00; else $9800; VramFillActiveBgMap_doFill: DE=$0400 jp VramFill.

VramFillActiveBgMap::
    ldh a, [rLCDC]
    bit 3, a
    jr nz, VramFillActiveBgMap_use9c00

    ld hl, $9800
    jr VramFillActiveBgMap_doFill

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

VramFillActiveBgMap_use9c00::
    ld hl, $9c00

; [ezgb]
; Source: kernel/stock/gbdk/drawing.s, kernel/stock/gbdk/cpy_data.s, kernel/stock/gbdk/ibmfixed.s, kernel/stock/gbdk/pad.s, kernel/stock/gbdk/delay.s, kernel/stock/gbdk/font.ms, kernel/stock/gbdk/init_tt.s

VramFillActiveBgMap_doFill::
    ld de, $0400
    jp VramFill


    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
