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
; RunCallbackList: shared IRQ dispatcher. HL = list base (uint16 fn ptrs,
; 0-terminated). Nest via wIntNest; CallHL each slot. Vectors: VBlank→wVBlankCallbacks
; ($d6d3), LCD→$d6e3, Timer→$d6f3, Serial→$d703, Joypad→$d713.
; jr_000_0071: walk until NUL ptr; jr_000_0080: --wIntNest; nest≠0 → ret else jr_000_008e reti.

RunCallbackList::
    push af

    push bc
    push de
    ld a, [wIntNest]
    inc a
    ld [wIntNest], a

jr_000_0071:
    ld a, [hl+]
    or [hl]
    jr z, jr_000_0080

    push hl
    ld a, [hl-]
    ld l, [hl]
    ld h, a
    call CallHL
    pop hl
    inc hl
    jr jr_000_0071

jr_000_0080:
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
    db $7b, $57

; [ezgb]
; KernelEntry: after boot ROM (title EZGB). See docs/boot-map.md. di; SP=$e000; save A in D.
; jr_000_015d: zero WRAM $DFFF down $2000 (B/C nested); jr_000_0169: OAM $FEFF..$100; jr_000_0172: HRAM $FFFF..$80.
; Save boot A@$d6c9; bank1; LcdOff; scroll/STAT/WY/WX init; jr_000_019e: copy OamDmaStub → $FF80.
; Register VBlank/Serial; BGP/OBP/LCDC/IE; serial SB=$66 SC=$80; BootUnpackWramTables ($68b6); BatteryCheck; fall HaltLoop.

KernelEntry::
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

jr_000_019e:
    ld a, [hl+]
    ldh [c], a
    inc c
    dec b
    jr nz, jr_000_019e

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
    ld [$d6d1], a
    ld [$d6d2], a
    call $68b6
    call BatteryCheck

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
; SetGfxMode: wGfxMode=L; jp 4-byte table at $01e2 (mode&3). Wrappers:
; SetGfxModeStack ($06ef), GetGfxMode ($06f8) returns E=wGfxMode.

SetGfxMode::
    ld a, l
    ld [wGfxMode], a
    and $03
    ld l, a
    ld bc, $01e2
    sla l
    sla l
    add hl, bc
    jp hl


RemoveVBlankCallback::
    ld hl, wVBlankCallbacks
    jp RemoveCallbackSlot


RemoveLcdCallback::
    ld hl, wLcdCallbacks
    jp RemoveCallbackSlot


RemoveTimerCallback::
    ld hl, wTimerCallbacks
    jp RemoveCallbackSlot


RemoveSerialCallback::
    ld hl, wSerialCallbacks
    jp RemoveCallbackSlot


RemoveJoypadCallback::
    ld hl, wJoypadCallbacks
    jp RemoveCallbackSlot


; [ezgb]
; RegisterVBlankCallback: HL=wVBlankCallbacks, jp InstallCallbackSlot (BC=fn).
; Siblings: RegisterLcdCallback $0634, RegisterTimerCallback $063a,
; RegisterSerialCallback $0640, RegisterJoypadCallback $0646. Matching Remove*
; wrappers at $0610–$0628. See decomp/src/register_callback_slots.c.

RegisterVBlankCallback::
    ld hl, wVBlankCallbacks
    jp InstallCallbackSlot


; [ezgb]
; RegisterLcdCallback: install BC into wLcdCallbacks ($d6e3). EnterGfxMode1
; registers LycCb_Bg8800 ($2a6a) here and enables STAT LYC after RegisterVBlankCallback.

RegisterLcdCallback::
    ld hl, wLcdCallbacks
    jp InstallCallbackSlot


RegisterTimerCallback::
    ld hl, wTimerCallbacks
    jp InstallCallbackSlot


RegisterSerialCallback::
    ld hl, wSerialCallbacks
    jp InstallCallbackSlot


RegisterJoypadCallback::
    ld hl, wJoypadCallbacks
    jp InstallCallbackSlot


; [ezgb]
; RemoveCallbackSlot: find BC in uint16 list at HL; zero slot; compact tail (jr_000_0661).
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

; [ezgb]
; InstallCallbackSlot: walk uint16 list at HL, store BC (fn ptr) in first free slot.
; RemoveCallbackSlot ($064c) finds BC and compacts the tail. HL/BC register ABI.
; Occupied → skip+self; jr_000_0673: write BC at free NUL slot (hi then lo) ret.

InstallCallbackSlot::
    ld a, [hl+]
    or [hl]
    jr z, jr_000_0673

    inc hl
    jr InstallCallbackSlot

jr_000_0673:
    ld [hl], b
    dec hl
    ld [hl], c
    ret


; [ezgb]
; VBlankCallback: ++frame counter $d6d1/$d6d2 (jr_000_067f carry); call OAM DMA $FF80; set $d6ce=1.
; Registered by KernelEntry via RegisterVBlankCallback. WaitVBlankFlag polls $d6ce.

VBlankCallback::
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


; [ezgb]
; WaitVBlankFlag: halt until VBlank sets $D6CE; no-op if LCD is off.
; LCDC bit7 clear → ret. Clear $d6ce under di/ei; jr_000_0692: halt until $d6ce≠0; clear + ret.

WaitVBlankFlag::
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


; [ezgb]
; LcdOff: wait for a safe LY window, then clear LCDC bit 7; no-op if already off.
; LCDC bit7 clear (add a → NC) → ret. jr_000_06a3: spin while LY≥$92; jr_000_06a9: spin while LY<$91; then LCDC&=$7f.

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
; OamDmaStub: source for HRAM OAM DMA at $FF80 (KernelEntry copies 10 bytes).
; ldh [rDMA],$c0; jr_000_06bc: delay loop A=$28 then ret. Called from VBlankCallback.

OamDmaStub::
    ld a, $c0
    ldh [rDMA], a
    ld a, $28

jr_000_06bc:
    dec a
    jr nz, jr_000_06bc

    ret


; [ezgb]
; SerialCallback: ISR for serial xfer; state in $d6cd, payload $d6cc.
; jr_000_06d0: state≠2 → if state==1 expect rSB=$55 else $d6cd=$04 (jr_000_06e0); state2: store rSB→$d6cc.
; jr_000_06de/06e0: clear/set $d6cd, SC=0, SB=$66; jr_000_06ea: re-arm SC=$80 ret. Orphan before SetGfxModeStack.

SerialCallback::
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


SetGfxModeStack::
    ld hl, sp+$02
    ld l, [hl]
    ld h, $00
    call SetGfxMode
    ret


GetGfxMode::
    ld hl, wGfxMode
    ld e, [hl]
    ret


; [ezgb]
; DiNest: di; ++wIntNest ($d6d0). Pair EiNest ($0706) decs and ei when nest hits 0.
; FarCallTrampoline and critical sections use this nest counter.

DiNest::
    di
    ld a, [wIntNest]
    inc a
    ld [wIntNest], a
    ret


; [ezgb]
; EiNest: --wIntNest; ei only when counter reaches 0 (nested DI safe).

EiNest::
    ld a, [wIntNest]
    dec a
    ld [wIntNest], a
    ret nz

    ei
    ret


; [ezgb]
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
; WaitJoypadSelect: spin ReadJoypad until pad==$40 (SELECT); then Delay+$00c8.
; Jump_000_07ce: retry; jr_000_07d1: delay ret. Orphan before PlotBitRowXY.

WaitJoypadSelect::
    call ReadJoypad
    ld c, e
    ld b, $00
    ld a, c
    sub $40
    jp nz, Jump_000_07ce

    or b
    jp nz, Jump_000_07ce

    jr jr_000_07d1

Jump_000_07ce:
    jp WaitJoypadSelect


jr_000_07d1:
    ld hl, $00c8
    push hl
    call Delay
    add sp, $02
    ret


; [ezgb]
; PlotBitRowXY(flags@sp+$02, x@sp+$03, y@sp+$04): plot up to 8 pixels via PlotPixelXY. bit0→x+7 … bit7→x (MSB left).
; Per bit: test flag; set → jr_ plot PlotPixelXY(x+offset,y); clear → Jump_ skip. Chain:
; bit0 jr_000_07e5 / Jump_000_07f7; bit1 jr_000_0801 / Jump_000_0813; bit2 jr_000_081d / Jump_000_082f; bit3 jr_000_0839 / Jump_000_084c;
; bit4 jr_000_0856 / Jump_000_0868; bit5 jr_000_0872 / Jump_000_0883; bit6 jr_000_088d / Jump_000_089d; bit7 jr_000_08a7 / Jump_000_08b5 ret.

PlotBitRowXY::
    ld hl, sp+$02
    ld a, [hl]
    and $01
    jr nz, PlotBitRowXY_bit0Plot

    jp PlotBitRowXY_bit0Skip


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

PlotBitRowXY_bit0Skip::
    ld hl, sp+$02
    ld a, [hl]
    and $02
    jr nz, PlotBitRowXY_bit1Plot

    jp PlotBitRowXY_bit1Skip


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

PlotBitRowXY_bit1Skip::
    ld hl, sp+$02
    ld a, [hl]
    and $04
    jr nz, PlotBitRowXY_bit2Plot

    jp PlotBitRowXY_bit2Skip


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

PlotBitRowXY_bit2Skip::
    ld hl, sp+$02
    ld a, [hl]
    and $08
    jr nz, PlotBitRowXY_bit3Plot

    jp PlotBitRowXY_bit3Skip


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

PlotBitRowXY_bit3Skip::
    ld hl, sp+$02
    ld a, [hl]
    and $10
    jr nz, PlotBitRowXY_bit4Plot

    jp PlotBitRowXY_bit4Skip


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

PlotBitRowXY_bit4Skip::
    ld hl, sp+$02
    ld a, [hl]
    and $20
    jr nz, PlotBitRowXY_bit5Plot

    jp PlotBitRowXY_bit5Skip


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

PlotBitRowXY_bit5Skip::
    ld hl, sp+$02
    ld a, [hl]
    and $40
    jr nz, PlotBitRowXY_bit6Plot

    jp PlotBitRowXY_bit6Skip


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

PlotBitRowXY_bit6Skip::
    ld hl, sp+$02
    ld a, [hl]
    and $80
    jr nz, PlotBitRowXY_bit7Plot

    jp PlotBitRowXY_ret


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

PlotBitRowXY_ret::
    ret


    ret


; [ezgb]
; DrawString(ptr, len, screen pos): highest fan-in text primitive (~86 callers). SetTextCursor then glyph loop.
; len==0 → max=$11 else Jump_000_08d5 copy len; both meet Jump_000_08db stash ptr@sp+$00, C=0.
; Jump_000_08e5: if C≥max → Jump_000_0927 ret; *ptr==0 → Jump_000_0909 StoreDrawParams + DrawGlyphAdvance $20; else ++ptr (jr_000_08fd) DrawGlyphAdvance(char).
; Jump_000_0923: ++C → Jump_000_08e5; Jump_000_0927 ret.

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


DrawString_copyLen::
    ld hl, sp+$07
    ld a, [hl]
    ld hl, sp+$02
    ld [hl], a

DrawString_stashPtr::
    ld hl, sp+$05
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    ld c, $00

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

DrawString_drawChar::
    push bc
    push bc
    inc sp
    call DrawGlyphAdvance
    add sp, $01
    pop bc
    jp DrawString_incC


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

DrawString_incC::
    inc c
    jp DrawString_glyphLoop


DrawString_epilogueRet::
    add sp, $03
    ret


; [ezgb]
; DrawU32Decimal: U32ToAscii_B0 (radix $0a) then DrawString at ($cc30,$cc2f).
; Inc $cc2f; wrap to 0 at $14 (20). Unlabeled orphan after Jump_000_0927 epilogue.
; See docs/DIFF_1.04e_vs_1.05e.md ($cc2f/$cc30 retry/display counters).
; Scratch@sp+$01; CStrLen → DrawString(len,x=$cc30,y=$cc2f); ++$cc2f; ≥$14 → 0; Jump_000_0982 ret.

DrawU32Decimal::
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
    call DrawString
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


; [ezgb]
; SdReadRetryCount: SD dir-read failure path. DrawString FileSystemErrorStr at ($0100,y);
; then infinite loop at $0998. Reads $cc2f (outer counter from DrawU32Decimal) but discards.
; Jump_000_0998: jp self hang. Orphan ret after; next FileSystemErrorStr.

SdReadRetryCount::
    ld hl, $cc2f
    ld a, [hl]
    push af
    inc sp
    ld hl, $0100
    push hl
    ld hl, FileSystemErrorStr
    push hl
    call DrawString
    add sp, $05

Jump_000_0998:
    jp Jump_000_0998


    ret


FileSystemErrorStr::
    db "File system error!", $00

; [ezgb]
; MemCmp_B0(s1@sp+$0b, s2@sp+$0d, n@sp+$0f): FatFs mem_cmp twin of MemCmp_B5/B9. Frame -$09; Diff@sp+$03=0.
; Jump_000_09d0: --n; if was0 → Jump_000_0a11; else *s1++ (jr_000_09e6 carry), *s2++ (jr_000_09f9 carry).
; jr_000_09f9: sex(*s1)-*s2 → diff@sp+$03; if 0 → Jump_000_09d0 else fall Jump_000_0a11.
; Jump_000_0a11: DE=diff ret. DirList hides ezgb.dat via this.

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
    jp z, Jump_000_09d0

Jump_000_0a11:
    ld hl, sp+$03
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $09
    ret


; [ezgb]
; MemSet8_B0(dest@sp+$04, byte@sp+$06, n@sp+$08): fill n bytes (u8 count) with byte.
; Jump_000_0a27: while n--: *dest++=byte (jr_000_0a3d); Jump_000_0a40 ret. Sibling of Memset; used near DirList.

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


; [ezgb]
; DirList: enumerate into $c2a0; count $c2a2/$c2a3; cap 16 (sp+$04).
; Jump_000_0a56: farcall readdir; fail/empty → Jump_000_0a83 → Jump_000_0bc5 ($c5a4=1); Jump_000_0a8b skip ".".
; Jump_000_0aa3/jr_000_0abf: bank slot; Jump_000_0aeb: if not dir → Jump_000_0b41; else jr_000_0aee attr $10 + ApplyBasename → jr_000_0b3e → Jump_000_0bb8.
; Jump_000_0b41: need AM_ARC else Jump_000_0b4c → Jump_000_0bb8; jr_000_0b4f MemCmp EzgbDatStr → skip Jump_000_0a56; else store $20+basename.
; Jump_000_0bb8/jr_000_0bb8: if count<$10 Jump_000_0bc2 → Jump_000_0a56 else Jump_000_0bc5/jr_000_0bc5 ret.

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

DirList_failEmpty::
    ld hl, $c5a4
    ld [hl], $01
    jp DirList_epilogueRet


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

DirList_notDir::
    jp DirList_needAmArc


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

DirList_afterDirStore::
    jp DirList_countCheck


DirList_needAmArc::
    ld a, c
    and $20
    ld c, a
    sub $20
    jp nz, DirList_skipNoArc

    jr DirList_memcmpEzgbDat

DirList_skipNoArc::
    jp DirList_countCheck


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

DirList_countCheck::
    ld hl, sp+$04
    ld a, [hl]
    sub $10
    jp nz, DirList_moreEntries

    jr DirList_epilogueRet

DirList_moreEntries::
    jp DirList_readdir


DirList_epilogueRet::
    add sp, $09
    ret


EzgbDatStr::
    db "ezgb.dat", $00

; [ezgb]
; DrawDirEntryLabel(size@sp+$12, ofs@sp+$16, y@sp+$18): frame -$10. size≤$14 → Jump_000_0ddd skip.
; jr_000_0c0a: >>5 bank from ofs; attr+$fe==$10 → jr_000_0c84 width $11 else Jump_000_0c81 → Jump_000_0c8b width $14.
; Jump_000_0c8f: if namelen≥width → Jump_000_0ddd; else U32Shr/Div scroll idx; if $cc31/$cc32 unchanged → Jump_000_0ddd.
; Jump_000_0d2c: update $cc31/32; Strncpy name+$fe ellipsis into $c4a4; DrawString at y+2; Jump_000_0ddd epilogue.

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

    jr DrawDirEntryLabel_dirWidth11

DrawDirEntryLabel_skipDirWidth::
    jp DrawDirEntryLabel_fileWidth14


DrawDirEntryLabel_dirWidth11::
    ld hl, sp+$0f
    ld [hl], $11
    jp DrawDirEntryLabel_scrollCheck


DrawDirEntryLabel_fileWidth14::
    ld hl, sp+$0f
    ld [hl], $14

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
    ld hl, $0de0
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

DrawDirEntryLabel_epilogueRet::
    add sp, $10
    ret


    jr nz, jr_000_0e02

    jr nz, SdMenuMain

; [ezgb]
; SdMenuMain: SD init, BACKUPSAVE, file browser. Kernel FPGA path; stays in menu loop.
; FarCall SD mount (inline after call); jr_000_0e02: check status@sp+$16; NZ → DrawString MicroSdInitErrorStr; Jump_000_0e21 hang.
; Jump_000_0e24: OK string; page $11 via $4000; if $A000≠$AA → GotoFileBrowser else jr BackupBranchEntry.
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
    ld hl, $16b4
    push hl
    ld hl, $c7a9
    push hl
    call FarCallTrampoline
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
    ld hl, MicroSdInitErrorStr
    push hl
    call DrawString
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

GotoFileBrowser::
    jp Jump_000_0f5b


; [ezgb]
; BackupBranchEntry: FRAM stamp → SAVER basename, then fall into FileBrowserEntry.
; Read $A202→$d3f6, $A001 auto flag, clear $A000, B=$A00F bank count.
; Jump_000_0ec4: copy $A010.. → $c3a5 (jr_000_0f05 carry); Jump_000_0f08: NUL-term + Open_B9 SaverDirStr + farcalls.
; Jump_000_0f5b: $4000=0, memset $c2a6, seed '/'; fallthrough FileBrowserEntry (00:0f8d).

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
; FileBrowserEntry: clear $cc2f/$cc30/$c5a4; farcall mount/list; fail SdReadRetryCount. Main browser loop.
; Jump_000_0fcd/Jump_000_0ff4: zero $c2a2/$c2a3; memset $c4a4+$c9db; wire $c9f1→$c4a4, $c9f3=$00fe; DirList.
; jr_000_1071 redraw: dirty → Jump_000_1089/jr_000_108c (code3 farcall+label) or Jump_000_10b1 (code≥2); Jump_000_10df DrawDirEntryLabel if count≠0 → Jump_000_1107.
; Jump_000_1107 Delay+ReadJoypad: $02 jr_000_1128 page-- (Jump_000_114d/Jump_000_1154/Jump_000_115b/Jump_000_116b); $01 jr_000_1175 DirList + Jump_000_1180 page++ (Jump_000_11bf/Jump_000_11d6/Jump_000_11dd).
; $04/$08 jr_000_11e7/Jump_000_11f6 / jr_000_1200/Jump_000_1223 row; $40 jr_000_122d mode (Jump_000_1238/jr_000_123b/Jump_000_1242/Jump_000_124c/jr_000_124f farcall) → Jump_000_1267/Jump_000_1271/jr_000_1274 or MenuKeyDispatch.

FileBrowserEntry::
    ld hl, $cc2f
    ld [hl], $00
    ld hl, $cc30
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

    call SdReadRetryCount

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

    call SdReadRetryCount

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

FileBrowserEntry_redrawSkipCode3::
    jp FileBrowserEntry_redrawCodeGe2


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


FileBrowserEntry_pageDecZero::
    ld hl, sp+$13
    ld [hl], $00
    inc hl
    ld [hl], $00

FileBrowserEntry_pageDecDirty::
    ld hl, sp+$12
    ld [hl], $01
    jp MenuDispatchAB_waitVBlankLoop


FileBrowserEntry_pageDecGate::
    xor a
    ld hl, sp+$15
    or [hl]
    jp z, MenuDispatchAB_waitVBlankLoop

    ld [hl], $00
    ld hl, sp+$12
    ld [hl], $01
    jp MenuDispatchAB_waitVBlankLoop


FileBrowserEntry_afterPageDec::
    ld hl, sp+$00
    ld a, [hl]
    and $01
    jr nz, FileBrowserEntry_dirListBtn

    jp FileBrowserEntry_afterPageInc


FileBrowserEntry_dirListBtn::
    xor a
    ld hl, $c5a4
    or [hl]
    jp nz, FileBrowserEntry_pageInc

    call DirList

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

FileBrowserEntry_pageIncDirty::
    ld hl, sp+$12
    ld [hl], $01
    jp MenuDispatchAB_waitVBlankLoop


FileBrowserEntry_afterPageInc::
    ld hl, sp+$00
    ld a, [hl]
    and $04
    jr nz, FileBrowserEntry_rowDec

    jp FileBrowserEntry_afterRowDec


FileBrowserEntry_rowDec::
    xor a
    ld hl, sp+$15
    or [hl]
    jp z, MenuDispatchAB_waitVBlankLoop

    dec [hl]
    ld hl, sp+$12
    ld [hl], $03
    jp MenuDispatchAB_waitVBlankLoop


FileBrowserEntry_afterRowDec::
    ld hl, sp+$00
    ld a, [hl]
    and $08
    jr nz, FileBrowserEntry_rowInc

    jp FileBrowserEntry_afterRow


FileBrowserEntry_rowInc::
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


FileBrowserEntry_afterRow::
    ld hl, sp+$00
    ld a, [hl]
    and $40
    jr nz, FileBrowserEntry_modeBtn

    jp MenuKeyDispatch


FileBrowserEntry_modeBtn::
    ld hl, sp+$0e
    inc [hl]
    ld a, [hl]
    sub $02
    jp nz, FileBrowserEntry_modeSkipWrap

    jr FileBrowserEntry_modeWrapZero

FileBrowserEntry_modeSkipWrap::
    jp FileBrowserEntry_modeCheck1


FileBrowserEntry_modeWrapZero::
    ld hl, sp+$0e
    ld [hl], $00
    jp FileBrowserEntry_modeCheck2


FileBrowserEntry_modeCheck1::
    ld hl, sp+$0e
    ld a, [hl]
    sub $01
    jp nz, FileBrowserEntry_modeSkipFarcall1

    jr FileBrowserEntry_modeFarcall1

FileBrowserEntry_modeSkipFarcall1::
    jp FileBrowserEntry_modeCheck2


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

FileBrowserEntry_modeCheck2::
    ld hl, sp+$0e
    ld a, [hl]
    sub $02
    jp nz, FileBrowserEntry_modeSkipFarcall2

    jr FileBrowserEntry_modeFarcall2

FileBrowserEntry_modeSkipFarcall2::
    jp MenuDispatchAB_waitVBlankLoop


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
; MenuKeyDispatch: START ($80) -> LastRomOverlay; else MenuDispatchAB.
; Joypad byte is post-swap: A=$10, B=$20, START=$80 (see docs/launch-trace.md).

MenuKeyDispatch::
    ld hl, sp+$00
    ld a, [hl]
    and $80
    jr nz, LastRomOverlay

    jp MenuDispatchAB


; [ezgb]
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
; LastRomLoadRecord: copy $A300..+$00ff → $c4a4 (idx@sp+$0f); then LastRomDrawBasename.
; Loop via jr_000_12ee → self until idx≥$00ff; fallthrough jp LastRomDrawBasename when done.

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
    jr nz, jr_000_12ee

    inc hl
    inc [hl]

jr_000_12ee:
    jp LastRomLoadRecord


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
    ld [hl], b
    dec d

LastRomCheckReturn::
    ld hl, sp+$04
    ld a, [hl]
    and $20
    jr nz, LastRomReturn

    jp LastRomInputLoop


LastRomReturn::
    jp FileBrowserEntry


; [ezgb]
; MenuDispatchAB: A($10) open selection; B($20) parent dir; else Jump_000_16ab WaitVBlankFlag → browser loop $1062.
; jr_000_139c/jr_000_13b3: bank entry >>5+$12@$4000; Jump_000_140c: file → Jump_000_145f else jr_000_140f/Jump_000_143b dir append → FileBrowserEntry.
; Jump_000_145f: ApplyBasename+$c4a4; Jump_000_14d6/Jump_000_14fb toupper ext@$c3a5; Jump_000_1520 MemCmp .gbc/.gb.
; Match jr_000_1566 → Jump_000_1569 launch farcalls; fail Jump_000_1588/jr_000_158b WaitJoypadSelect; Jump_000_1591..Jump_000_162c hang.
; Jump_000_162f: B → jr_000_1639 strip last /$c2a6 (Strrchr); empty "/"; jp FileBrowserEntry; else Jump_000_16ab.

MenuDispatchAB::
    ld hl, sp+$00
    ld a, [hl]
    and $10
    jr nz, MenuDispatchAB_bankEntry

    jp MenuDispatchAB_checkB


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

    jr MenuDispatchAB_dirAppend

MenuDispatchAB_fileSkipDir::
    jp MenuDispatchAB_fileOpen


MenuDispatchAB_dirAppend::
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
    jp z, MenuDispatchAB_launchFarcalls

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
    jp z, MenuDispatchAB_launchFarcalls

    call FarCallTrampoline
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
    jr nz, MenuDispatchAB_extMatch

    jp $1557


MenuDispatchAB_extMatch::
    jp FileBrowserEntry


MenuDispatchAB_launchFarcalls::
    call FarCallTrampoline
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
    jp nz, MenuDispatchAB_failSkipWait

    jr MenuDispatchAB_failWaitSelect

MenuDispatchAB_failSkipWait::
    jp MenuDispatchAB_failHang


MenuDispatchAB_failWaitSelect::
    call WaitJoypadSelect
    jp FileBrowserEntry


MenuDispatchAB_failHang::
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
    call FarCallTrampoline
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
    ld a, $00
    push af
    inc sp
    call FarCallTrampoline
    dec bc
    ld c, b
    ld bc, $e800
    ld bc, $ed21
    db $d3
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

MenuDispatchAB_failHangLoop::
    jp MenuDispatchAB_failHangLoop


MenuDispatchAB_checkB::
    ld hl, sp+$00
    ld a, [hl]
    and $20
    jr nz, MenuDispatchAB_parentDir

    jp MenuDispatchAB_waitVBlankLoop


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


MenuDispatchAB_waitVBlankLoop::
    call WaitVBlankFlag
    jp $1062


    add sp, $17
    ret


    nop

MicroSdInitErrorStr::
    db "Micro SD initial error!", $00

; [ezgb]
; MicroSdInitOkStr: NUL-term "Micro SD initial OK!" for SdMenuMain.

MicroSdInitOkStr::
    db "Micro SD initial OK!", $00

; [ezgb]
; SaverDirStr: NUL-term "/SAVER"; BackupBranchEntry Open_B9 path.

SaverDirStr::
    db "/SAVER", $00

; [ezgb]
; PathSlashStr: NUL-term "/"; path join in browser/backup helpers.

PathSlashStr::
    db "/", $00

; [ezgb]
; ExtGbcStr: NUL-term ".GBC" extension compare/append.

ExtGbcStr::
    db ".GBC", $00

; [ezgb]
; ExtGbStr: NUL-term ".GB" extension compare/append.

ExtGbStr::
    db ".GB", $00

; [ezgb]
; U32ToAscii_B0: bank0 twin of U32ToAscii (04:44f7); same ABI val/buf/radix. Used from bank0/1/8 UI chrome.
; Jump_000_1718: if val!=0 → Jump_000_1739; elif digits → Jump_000_1736 → Jump_000_17e5; else jr_000_1739 fall emit.
; Jump_000_1739/jr_000_1739: U32Div+U32Mod; rem<$0a → '0'+n (jr_000_17cd) else Jump_000_17d0 +$57 (jr_000_17e2) → Jump_000_1718.
; Jump_000_17e5: setup reverse; Jump_000_1802 copy (jr_000_1827) → Jump_000_182a NUL / plant "0".

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
; Battery gate: FPGA SRAM page $11, read $A201 (expect $88 = not dry).
; ≠$88: draw BatteryDry* UI; Jump_000_18d7 wait A ($10); jr_000_18e5 write $A201=$88.
; Jump_000_18eb: teardown page0, call SdMenuMain. Orphan before BatteryDryPadStr.

BatteryCheck::
    ld hl, $cc2f
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
    jp z, Jump_000_18eb

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
    ld hl, DrawDirEntryLabel_bankShift
    push hl
    ld a, $05
    push af
    inc sp
    ld hl, BatteryDryOkStr
    push hl
    call DrawString
    add sp, $05

Jump_000_18d7:
    call ReadJoypad
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
; BatteryDryTitleStr: NUL-term "BATTERY" for BatteryCheck dry notice.

BatteryDryTitleStr::
    db "BATTERY", $00

; [ezgb]
; BatteryDryMsgStr: NUL-term "DRY!!!" for BatteryCheck dry notice.

BatteryDryMsgStr::
    db "DRY!!!", $00

; [ezgb]
; BatteryDryOkStr: NUL-term "[A]OK" dismiss prompt for BatteryCheck.

BatteryDryOkStr::
    db "[A]OK", $00

; [ezgb]
; FarCall_06_7309: stack thunk → bank6:$7309 via FarCallTrampoline (embedded
; addr/bank after call). Siblings: FarCall_06_779a ($1941), FarCall_03_76cc
; ($1985), FarCall_03_768f ($19a1), FarCall_09_77ff ($19b1).

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
    sbc d
    ld [hl], a
    ld b, $00
    add sp, $08
    ret


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
    call z, Call_000_0376
    nop
    add sp, $06
    ret


FarCall_03_768f::
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call FarCallTrampoline
    adc a
    halt
    inc bc
    nop
    add sp, $02
    ret


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
; DiskStatus(pdrv): FatFs disk_status stub — ld e,0 / ret (always ready).
; Callers test E bits STA_NOINIT ($01) / STA_PROTECT ($04) and map to FR_
; codes ($0c FR_NOT_ENABLED, $0a FR_WRITE_PROTECTED). Sibling DiskInitialize
; ($1a2c) is the same body; ReturnZero ($1a77) is the no-arg FR_OK stub.

DiskStatus::
    ld e, $00
    ret


; [ezgb]
; DiskInitialize(pdrv): FatFs disk_initialize stub — same ld e,0 / ret as
; DiskStatus. Mount path maps STA_NOINIT -> FR_NOT_READY ($03).

DiskInitialize::
    ld e, $00
    ret


; [ezgb]
; FarCall stub: repack stack args, FarCallTrampoline to DiskRead_B2 (SD sector
; read), return E. Sibling FarCallDiskWrite ($1a53) is the write path.

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
; FarCall stub: repack stack args, FarCallTrampoline to DiskWrite_B2 (SD sector
; write), return E. Sibling FarCallDiskRead ($1a2f) is the read path.

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


ReturnZero::
    ld e, $00
    ret


; [ezgb]
; SetFpgaPage ($7FC0). Bank-0 leaf; used before RTC reads at $A008+.

SetFpgaPage_B0::
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


RtcReadPage::
    add sp, -$1d
    ld a, $06
    push af
    inc sp
    call SetFpgaPage_B0
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
    call SetFpgaPage_B0
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
    call U32Shl
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
    call U32Shl
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
    call U32Shl
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
    call U32Shl
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
    call U32Shl
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


; [ezgb]
; MapCp437(code@sp+$07, dir@sp+$09) → DE. codes <$80 pass-through Jump_000_1ed0. Table IBM CP437 high-half @1ed5.
; Jump_000_1e30 dir!=0: if code≥$100 plant 0 → Jump_000_1e76; else Jump_000_1e5a table[(code-$80)*2] → Jump_000_1e76 → Jump_000_1ed0.
; Jump_000_1e7e dir==0: idx=0; Jump_000_1e85 while idx<$80: cmp word (jr_000_1ea6); miss Jump_000_1eb3 ++idx (jr_000_1eba) → Jump_000_1e85.
; Hit/exhaust Jump_000_1ebd: idx+$80 → Jump_000_1ed0 ret.

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

MapCp437_afterEncode::
    ld hl, sp+$03
    ld c, [hl]
    inc hl
    ld b, [hl]
    jp MapCp437_retDe


MapCp437_dirDecode::
    ld hl, sp+$03
    ld [hl], $00
    inc hl
    ld [hl], $00

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

MapCp437_decodeCmp::
    ld hl, sp+$07
    ld a, [hl]
    sub c
    jp nz, MapCp437_decodeMiss

    inc hl
    ld a, [hl]
    sub b
    jp z, MapCp437_decodeHit

MapCp437_decodeMiss::
    ld hl, sp+$03
    inc [hl]
    jr nz, MapCp437_decodeCont

    inc hl
    inc [hl]

MapCp437_decodeCont::
    jp MapCp437_decodeScan


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

MapCp437_retDe::
    ld e, c
    ld d, b
    add sp, $05
    ret


; [ezgb]
; Cp437UnicodeTable: 128 LE uint16s, CP437 $80+$i -> Unicode. Perfect match to
; IBM code page 437 (e.g. $80->U+00C7, $B0->U+2591, $FF->U+00A0).

Cp437UnicodeTable::
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
    jr nz, MapCp437_decodeCmp

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
    jr nz, WToUpper_asciiGate

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

; [ezgb]
; WToUpper(code@sp+$0a): FatFs WCHAR toupper → DE. Frame -$08.
; jr_000_1fe2: if code≥$80 → Jump_000_200e; else if not in 'a'..'z' → Jump_000_20b3; else code-=$20 → Jump_000_20b3.
; Jump_000_200e: init lo/hi/count; Jump_000_2021: mid key from wWToUpperKeys; eq → Jump_000_2092; else Jump_000_2065.
; Jump_000_2065: key<code → raise lo else Jump_000_207a lower hi; Jump_000_2082 --count; NZ → Jump_000_2021 else fall Jump_000_2092.
; Jump_000_2092: if count==0 miss → Jump_000_20b3; else replace from wWToUpperVals; Jump_000_20b3: DE=code ret.

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


WToUpper_lowerHi::
    ld hl, sp+$06
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], e

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

WToUpper_retDe::
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $08
    ret


; [ezgb]
; RleUnpack: inline RLE decompress. HL=dest on entry; stream follows the call
; (pop return addr as src). Bit7 run vs literal; 0 terminates; ret past stream.
; Bank1 uses it to pack WToUpper tables into $CC33/$D00F and other WRAM blobs.
; Jump_000_20be: fetch len E; bit7 → run: load byte, Jump_000_20c7 store+inc E until wrap → loop.
; Jump_000_20d0: E==0 → Jump_000_20e0 push HL ret; else Jump_000_20d5 copy E literals → 20be.

RleUnpack::
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


; [ezgb]
; ApplyBasename(dest@sp+$02, src@sp+$04): strcpy incl. NUL (jr_000_20ec).
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

jr_000_20ec:
    ld a, [de]
    inc de
    ld [hl], a
    and a
    ret z

    inc hl
    jr jr_000_20ec

; [ezgb]
; AdvanceTextCursor: ++wTextCursorX; wrap at $13 → X=0, ++Y; at Y=$11 → Y=0 (no scroll).
; jr_000_2100: X wrap + maybe ++Y; jr_000_210d: Y wrap to 0; jr_000_210f: pop HL ret.
; Mode-1 framebuffer text sibling of AdvanceTileCursor. Used by DrawGlyphAdvance.

AdvanceTextCursor::
    push hl
    ld hl, wTextCursorX
    ld a, $13
    cp [hl]
    jr z, jr_000_2100

    inc [hl]
    jr jr_000_210f

jr_000_2100:
    ld [hl], $00
    ld hl, wTextCursorY
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


; [ezgb]
; DrawCircle: midpoint circle. BC=center, D=radius; wDrawRectFill selects outline (CirclePlot8) vs filled chords.
; Error in wCircleErr/$d72d. Stack wrapper DrawCircleXY ($27a0).
; Jump_000_2132/jr_000_2132: while X1≤Y1; outline if fill==0; err≥0 → jr_000_2176 else CircleFillH + ++X1 +err+$06 loop.
; jr_000_2176: CircleFillV + ++X1 --Y1 +err+$0a → Jump_000_2132.

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
    ld [$d72d], a
    ld a, h
    ld [wCircleErr], a

Jump_000_2132:
jr_000_2132:
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
    jr z, jr_000_2176

    ld a, [wDrawRectFill]
    or a
    call nz, CircleFillH
    ld a, [wDrawX1]
    inc a
    ld [wDrawX1], a
    ld a, [wCircleErr]
    ld b, a
    ld a, [$d72d]
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
    ld [$d72d], a
    jr jr_000_2132

jr_000_2176:
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
    ld a, [$d72d]
    ld c, a
    add hl, hl
    add hl, hl
    add hl, bc
    ld bc, $000a
    add hl, bc
    ld a, h
    ld [wCircleErr], a
    ld a, l
    ld [$d72d], a
    ld a, [wDrawY1]
    dec a
    ld [wDrawY1], a
    jp Jump_000_2132


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
; DrawRectImpl: normalize corners; outline via four DrawLine; optional fill if wDrawRectFill ($d724). Called by DrawRect.
; jr_000_22d9: if X1<X0 swap; fall. jr_000_22ec: if Y1<Y0 swap; then L/R verts + inset top/bot horiz DrawLine.
; If fill==0 or empty inset ret; else swap wDrawColor/wDrawColorB; jr_000_236d: horiz DrawLine at Y0; if Y0!=Y1 ++Y0 loop.
; jr_000_238d: restore colors (swap again) ret.

DrawRectImpl::
    ld a, [wDrawX0]
    ld b, a
    ld a, [wDrawX1]
    ld c, a
    sub b
    jr nc, jr_000_22d9

    ld a, c
    ld [wDrawX0], a
    ld a, b
    ld [wDrawX1], a

jr_000_22d9:
    ld a, [wDrawY0]
    ld b, a
    ld a, [wDrawY1]
    ld c, a
    sub b
    jr nc, jr_000_22ec

    ld a, c
    ld [wDrawY0], a
    ld a, b
    ld [wDrawY1], a

jr_000_22ec:
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

jr_000_236d:
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
    jr z, jr_000_238d

    inc a
    ld [wDrawY0], a
    jr jr_000_236d

jr_000_238d:
    ld a, [wDrawColor]
    ld c, a
    ld a, [wDrawColorB]
    ld [wDrawColor], a
    ld a, c
    ld [wDrawColorB], a
    ret


; [ezgb]
; DrawLine: Bresenham. ABI BC=(x0,y0) DE=(x1,y1). |dy|@$d72a, |dx|@$d729; err wCircleErr/$d72d..$d731.
; Setup: jr_000_23a2/jr_000_23ac abs dy/dx; |dx|<|dy| → Jump_000_2519 y-major; else Jump_000_23c4 maybe swap ends; jr_000_23ce/jr_000_23d0 set $d72b ±ystep + GfxRowTable/err.
; X-major Jump_000_2433: err≥0 jr_000_2464 plot+ystep (jr_000_247e/jr_000_248c row wrap $0130/$fed0); else jr_000_244b err+=2dy; jr_000_24a5/jr_000_24b0 byte advance; --E loop.
; Horiz Jump_000_24bd: jr_000_24d0/jr_000_24db/jr_000_24e3/jr_000_24ef/jr_000_250a/jr_000_250c/jr_000_2513 mask runs.
; Y-major Jump_000_2519: Jump_000_252a/jr_000_2534/jr_000_2536 swap+$d72b; dx==0 → Jump_000_260c; else jr_000_259e plot (jr_000_25b0), err jr_000_25d0/jr_000_25e2/jr_000_25ec xstep → jr_000_2602.
; Vert Jump_000_260c: jr_000_261a/jr_000_2628 ApplyPixel down. Callers: DrawRect edges + circle chords.

DrawLine::
    ld a, c
    sub e
    jr nc, DrawLine_absDy

    cpl
    inc a

DrawLine_absDy::
    ld [$d72a], a
    ld h, a
    ld a, b
    sub d
    jr nc, DrawLine_absDx

    cpl
    inc a

DrawLine_absDx::
    ld [$d729], a
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

DrawLine_maybeSwapEnds::
    ld a, e
    sub c
    jr z, DrawLine_swapEndsDone

    ld a, $00
    jr nc, DrawLine_swapEndsDone

    ld a, $ff

DrawLine_swapEndsDone::
    ld b, d
    ld c, e

DrawLine_setYstepErr::
    ld [$d72b], a
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
    ld a, [$d72a]
    or a
    jp z, DrawLine_horiz

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
    ld [wCircleErr], a
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

DrawLine_xMajorErrAdd::
    ld a, [$d72d]
    ld d, a
    ld a, [$d72f]
    add d
    ld [$d72d], a
    ld a, [wCircleErr]
    ld d, a
    ld a, [$d72e]
    adc d
    ld [wCircleErr], a
    pop de
    jr DrawLine_xMajorByteAdv

DrawLine_xMajorPlotYstep::
    push de
    push bc
    ld a, b
    cpl
    ld c, a
    call ApplyPixel
    ld a, [$d72b]
    or a
    jr z, DrawLine_xMajorRowWrapA

    inc hl
    ld a, l
    and $0f
    jr nz, DrawLine_xMajorRowWrapB

    ld de, $0130
    add hl, de
    jr DrawLine_xMajorRowWrapB

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

DrawLine_xMajorRowWrapB::
    ld a, [$d72d]
    ld d, a
    ld a, [$d731]
    add d
    ld [$d72d], a
    ld a, [wCircleErr]
    ld d, a
    ld a, [$d730]
    adc d
    ld [wCircleErr], a
    pop bc
    ld b, c
    pop de

DrawLine_xMajorByteAdv::
    bit 7, c
    jr z, DrawLine_xMajorLoopDec

    push de
    ld de, $0010
    add hl, de
    pop de
    ld b, c

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


DrawLine_horiz::
    ld a, [$d729]
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

DrawLine_horizMaskShift::
    rrca
    or c
    dec e
    jr z, DrawLine_horizTailPixel

    bit 0, a
    jr z, DrawLine_horizMaskShift

    jr DrawLine_horizTailPixel

DrawLine_horizMidRun::
    ld a, e
    dec a
    and $f8
    jr z, DrawLine_horizMaskInit

    jr DrawLine_horizDoneCheck

DrawLine_horizTailPixel::
    ld b, a
    cpl
    ld c, a
    push de
    call ApplyPixel
    ld de, $000f
    add hl, de
    pop de

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

DrawLine_horizMaskInit::
    ld a, $80

DrawLine_horizMaskLoop::
    dec e
    jr z, DrawLine_horizApplyPixel

    sra a
    jr DrawLine_horizMaskLoop

DrawLine_horizApplyPixel::
    ld b, a
    cpl
    ld c, a
    jp ApplyPixel


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

DrawLine_yMajorMaybeSwap::
    ld a, c
    sub e
    jr z, DrawLine_yMajorSwapDone

    ld a, $00
    jr nc, DrawLine_yMajorSwapDone

    ld a, $ff

DrawLine_yMajorSwapDone::
    ld b, d
    ld c, e

DrawLine_yMajorSetYstep::
    ld [$d72b], a
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
    ld a, [$d72a]
    ld e, a
    inc e
    ld a, [$d729]
    or a
    jp z, DrawLine_vert

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
    ld [wCircleErr], a
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

DrawLine_yMajorAfterPlot::
    pop bc
    ld a, [wCircleErr]
    bit 7, a
    jr z, DrawLine_yMajorErrCheck

    ld a, [$d72d]
    ld d, a
    ld a, [$d72f]
    add d
    ld [$d72d], a
    ld a, [wCircleErr]
    ld d, a
    ld a, [$d72e]
    adc d
    ld [wCircleErr], a
    jr DrawLine_yMajorLoopDec

DrawLine_yMajorErrCheck::
    ld a, [$d72b]
    or a
    jr nz, DrawLine_yMajorXstep

    rlc b
    bit 0, b
    jr z, DrawLine_yMajorErrAdd

    ld de, $fff0
    add hl, de
    jr DrawLine_yMajorErrAdd

DrawLine_yMajorXstep::
    rrc b
    bit 7, b
    jr z, DrawLine_yMajorErrAdd

    ld de, $0010
    add hl, de

DrawLine_yMajorErrAdd::
    ld a, [$d72d]
    ld d, a
    ld a, [$d731]
    add d
    ld [$d72d], a
    ld a, [wCircleErr]
    ld d, a
    ld a, [$d730]
    adc d
    ld [wCircleErr], a

DrawLine_yMajorLoopDec::
    pop de
    dec e
    jr nz, DrawLine_yMajorPlot

    ld a, b
    cpl
    ld c, a
    jp ApplyPixel


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

DrawLine_vertApplyPixel::
    push de
    call ApplyPixel
    inc hl
    ld a, l
    and $0f
    jr nz, DrawLine_vertLoopDec

    ld de, $0130
    add hl, de

DrawLine_vertLoopDec::
    pop de
    dec e
    ret z

    jr DrawLine_vertApplyPixel

; [ezgb]
; PlotPixel: set one pixel in the mode-1 framebuffer. Register ABI: B=x, C=y.
; Uses GfxRowTable ($2fbb) for scanline->VRAM; x bit from ROM $0010 masks.
; Falls into ApplyPixel ($264a). Sibling GetPixel ($26cc) reads the same address.

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
; ApplyPixel: blit one masked pixel at HL (B=mask, C=~mask). STAT-safe VRAM RMW. wDrawColor@$D734 planes; wDrawOp@$D723.
; Dispatch: op1 → jr_000_267e OR; op2 → jr_000_2698 XOR; op3 → jr_000_26b2 AND-clear; else replace.
; Replace: plane0 clear → B=0 then jr_000_2665; plane1 clear → E=0; jr_000_266b STAT-wait and/or write lo/hi; maybe pop BC.
; OR jr_000_267e: jr_000_2685/jr_000_268b plane gates + STAT or-write. XOR jr_000_2698: jr_000_269f/jr_000_26a5. AND jr_000_26b2: jr_000_26b9/jr_000_26bf.

ApplyPixel::
    ld a, [wDrawColor]
    ld d, a
    ld a, [wDrawOp]
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


; [ezgb]
; GetPixel(B=x, C=y): same address math as PlotPixel; returns plane bits in E (0-3).
; jr_000_26e7: STAT-wait read 2bpp pair; mask from $10+(x&7).
; jr_000_26f9: if plane0 bit clear skip; set0 B. jr_000_26ff: plane1 bit → set1 B; E=B ret.

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


; [ezgb]
; DrawGlyph(C=tile): blit 8×8 from font sheet $3206 into framebuffer at wTextCursorX/Y via GfxRowTable.
; Setup: row ptr from GfxRowTable[Y<<3]; +X<<3; glyph base $3206+C*8; C=wDrawColor.
; jr_000_2730: A=*src++; B=src bits. colorB.0 → A=$ff else jr_000_273f; A|=B; color.0 clear → A^=B; jr_000_2745 D=A.
; jr_000_2745: colorB.1 → A=$ff else jr_000_274c; A|=B; color.1 clear → A^=B; jr_000_2752 E=A; pop HL.
; jr_000_2754: STAT-wait; [HL++]=D,E; pop DE; if L&$0f → jr_000_2730 else ret. DrawGlyphAdvance wraps + AdvanceTextCursor.

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
    ld de, $3206
    add hl, de
    ld d, h
    ld e, l
    ld h, b
    ld l, c
    ld a, [wDrawColor]
    ld c, a

jr_000_2730:
    ld a, [de]
    inc de
    push de
    push hl
    ld hl, wDrawColorB
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


; [ezgb]
; SetTextCursor: store stack col/row into wTextCursorX/Y ($d732/$d733).

SetTextCursor::
    ld hl, sp+$02
    ld a, [hl+]
    ld [wTextCursorX], a
    ld a, [hl+]
    ld [wTextCursorY], a
    ret


DrawGlyphAdvance::
    push bc
    ld a, [wGfxMode]
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
; DrawCircleXY: stack (x, y, r, fill); ensure EnterGfxMode1 then DrawCircle.

DrawCircleXY::
    push bc
    ld a, [wGfxMode]
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
; DrawRect: if wGfxMode!=1 call EnterGfxMode1; copy 5 stack args into wDrawX0/Y0/
; X1/Y1/wDrawRectFill; call DrawRectImpl. C-shape ~ (u8 fill, u16, u16).
; Used e.g. from BatteryCheck chrome; generic (many callers).

DrawRect::
    push bc
    ld a, [wGfxMode]
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
; DrawLineXY: stack ABI (x0,y0,x1,y1); ensure EnterGfxMode1 then DrawLine (BC/DE).
; Thin C wrapper; e.g. bank8 chrome draws horizontal rules via this.

DrawLineXY::
    push bc
    ld a, [wGfxMode]
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
; PlotPixelXY: stack ABI (x, y); ensure EnterGfxMode1 then PlotPixel (B/C).
; Thin C wrapper over PlotPixel; used by bit-pattern glyph drawers.

PlotPixelXY::
    push bc
    ld a, [wGfxMode]
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
; PlotPixelEx: stack (x, y, wDrawColor, wDrawOp); set params then PlotPixel.
; Like PlotPixelXY but also writes draw color/op before the blit.

PlotPixelEx::
    push bc
    ld a, [wGfxMode]
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
; U32Mul: SDCC runtime __mullong. Stub jp U32MulImpl ($2dc1); multiplies two stack u32s,
; returns product in HL:DE. Body zeros a 4-byte acc then U32MulEngine (B=4)
; which uses MulU8xU8 (8x8->16 shift-add mul) per byte. Callers e.g. bank1
; scale time fields by 24/60. Sibling stubs: S32Div/U32Div/S32Mod/U32Mod.

U32Mul::
    jp U32MulImpl


; [ezgb]
; S32Div: SDCC __divslong stub jp S32DivImpl ($29e6). Signed long ÷; quotient in HL:DE.
; Zero/overflow via MemIsZero; uses signed negate helpers then unsigned engine.

S32Div::
    jp S32DivImpl


; [ezgb]
; U32Div: SDCC __divulong stub jp U32DivImpl ($2a77). Unsigned long ÷ via U32DivEngine;
; returns quotient from scratch. U32ToAscii uses this with radix.

U32Div::
    jp U32DivImpl


; [ezgb]
; S32Mod: SDCC __modslong stub jp S32ModImpl ($2b28). Signed long %; remainder in HL:DE.

S32Mod::
    jp S32ModImpl


; [ezgb]
; U32Mod: SDCC __modulong stub jp U32ModImpl ($2bfc). Unsigned long %; U32ToAscii digit path.

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


S8Mod::
    ld hl, $0003
    add hl, sp
    ld e, [hl]
    dec hl
    ld l, [hl]
    ld c, l
    call S16DivSex8
    ret


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
; S16DivMod(BC=dividend, DE=divisor): signed wrapper around U16DivMod.
; Abs DE if neg; jr_000_2925: abs BC if neg; jr_000_292f: U16DivMod (C set → early ret).
; jr_000_293e: restore quot sign (B^D) on BC; rem sign (dividend) on DE.

S16DivMod::
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
    call U16DivMod
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


U16DivZext8::
    ld b, $00
    ld d, b

; [ezgb]
; U16DivMod: unsigned 16-bit restoring divide. BC/DE in → BC=quot, DE=rem.
; U16DivZext8 ($2949) zeros high bytes then falls in. S16DivMod ($2917) abs,
; calls this, re-applies signs.

U16DivMod::
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


; [ezgb]
; U32Shr: SDCC runtime, logical >> on unsigned long. Stack: u32 + shift count;
; returns in HL:DE. Sibling S32Sar ($29ac) uses sra; U32Shl ($29c9) uses rl.
; High fan-in is every C << >> on longs — name from the loop, no emulator needed.
; Jump_000_299e: while count--: rr HL:DE (logical); count==0 ret.

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

Jump_000_299e:
    or a
    ret z

    rr h
    rr l
    rr d
    rr e
    dec a
    jp Jump_000_299e


; [ezgb]
; S32Sar: SDCC runtime, arithmetic >> on signed long (sra on high byte).
; Stack: s32 + shift count → HL:DE. Jump_000_29bb: while count--: sra H, rr L/D/E; twin of U32Shr.

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

Jump_000_29bb:
    or a
    ret z

    sra h
    rr l
    rr d
    rr e
    dec a
    jp Jump_000_29bb


; [ezgb]
; U32Shl: SDCC runtime, << on unsigned long. Stack: u32 + shift count → HL:DE.
; Jump_000_29d8: while count--: rl E/D/L/H; twin of U32Shr/S32Sar.

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

Jump_000_29d8:
    or a
    ret z

    rl e
    rl d
    rl l
    rl h
    dec a
    jp Jump_000_29d8


; [ezgb]
; S32DivImpl: body of S32Div stub. Frame -$09; dividend@sp+$0b, divisor@sp+$0f → DEHL quotient.
; div0: MemIsZero dividend → DEHL=0 Jump_000_2a5c; else jr_000_29f9.
; jr_000_29f9: MemIsZero divisor → $d6c7=$21 + DEHL=$7fffffff Jump_000_2a5c; else jr_000_2a0f.
; jr_000_2a0f: clear sign@sp+$00; if divisor MSB set NegateBytes divisor + sign=1; fall jr_000_2a23.
; jr_000_2a23: if dividend MSB set NegateBytes dividend + xor sign; fall jr_000_2a35.
; jr_000_2a35: U32DivEngine → quot@sp+$01; rr sign → if set NegateBytes quot; jr_000_2a53 load DEHL; Jump_000_2a5c epilogue.

S32DivImpl::
    add sp, -$09
    ld b, $04
    ld hl, sp+$0b
    call MemIsZero
    jr nz, jr_000_29f9

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_2a5c


jr_000_29f9:
    ld hl, sp+$0f
    call MemIsZero
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
    call NegateBytes
    ld hl, sp+$00
    ld [hl], $01

jr_000_2a23:
    ld hl, sp+$0e
    ld a, [hl]
    bit 7, a
    jr z, jr_000_2a35

    ld hl, sp+$0b
    call NegateBytes
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
    call U32DivEngine
    add sp, $08
    ld hl, sp+$00
    rr [hl]
    jr nc, jr_000_2a53

    ld b, $04
    ld hl, sp+$01
    call NegateBytes

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


; [ezgb]
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
; LycCb_Bg8800: STAT LYC callback (EnterGfxMode1 → RegisterLcdCallback). Wait
; STAT mode≠2, clear LCDC bit4 (BG tile data back to $8800). Was jr_000_2a6a.

LycCb_Bg8800::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, LycCb_Bg8800

    ldh a, [rLCDC]
    and $ef
    ldh [rLCDC], a
    ret


; [ezgb]
; U32DivImpl: body of U32Div stub. Frame -$08; dividend@sp+$0a, divisor@sp+$0e → DEHL quotient.
; MemIsZero dividend → DEHL=0 Jump_000_2aba; else jr_000_2a8a.
; jr_000_2a8a: MemIsZero divisor → $d6c7=$21 + DEHL=$7fffffff Jump_000_2aba; else jr_000_2aa0.
; jr_000_2aa0: U32DivEngine → load quot@sp+$00 into DEHL; Jump_000_2aba epilogue. Unsigned twin of S32DivImpl.

U32DivImpl::
    add sp, -$08
    ld b, $04
    ld hl, sp+$0a
    call MemIsZero
    jr nz, jr_000_2a8a

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_2aba


jr_000_2a8a:
    ld hl, sp+$0e
    call MemIsZero
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

Jump_000_2aba:
    add sp, $08
    ret


; [ezgb]
; MemIsZero: scan B bytes at HL; Z if all zero else NZ. Used by U32/S32 div/mod
; stubs to reject zero dividend/divisor before U32DivEngine.
; jr_000_2abf: while C--: *HL++==0 else NZ ret; fallthrough Z ret.

MemIsZero::
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


; [ezgb]
; ClearNegZero32: HL→MSB of 4-byte LE value; if value is 0 or $80000000,
; clear sign bit (force -0 → +0). Used by S32Cmp.
; jr_000_2ad9: if bit7 clear A=0 else A=$80; match MSB then scan 3 lower bytes==0 → res 7.

ClearNegZero32::
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


; [ezgb]
; MemCmp3Down: compare 3 bytes at DE vs HL walking downward; NZ on first diff.
; Local helper for S32Cmp MSB-side compare.
; jr_000_2aed: C=3; *DE-*HL; NZ ret; dec both; --C; Z after 3 → equal ret.

MemCmp3Down::
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

; [ezgb]
; S32Cmp: signed long compare sp+$07 vs sp+$0b (MSB high). ClearNegZero32 both; then sign-dispatch + MemCmp3Down.
; a MSB set: if b also neg → MemCmp3Down swapped; else jr_000_2b14 C-set (a<b) ret.
; jr_000_2b17: a pos; if b neg → A=$ff ret; else jr_000_2b20 MemCmp3Down a vs b.
; No external callers in this build (SDCC runtime residue).

S32Cmp::
    ld hl, sp+$07
    call ClearNegZero32
    ld hl, sp+$0b
    call ClearNegZero32
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
    jr MemCmp3Down

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
    jr MemCmp3Down

; [ezgb]
; S32ModImpl: body of S32Mod stub (twin of S32DivImpl). Frame -$09; dividend@sp+$0b, divisor@sp+$0f → DEHL rem.
; div0: MemIsZero dividend → DEHL=0 Jump_000_2b9f; else jr_000_2b3b.
; jr_000_2b3b: MemIsZero divisor → $d6c7=$21 + DEHL=$7fffffff Jump_000_2b9f; else jr_000_2b51.
; jr_000_2b51: clear sign@sp+$00; if divisor MSB set NegateBytes divisor + sign=1; fall jr_000_2b65.
; jr_000_2b65: if dividend MSB set NegateBytes dividend + xor sign; fall jr_000_2b77.
; jr_000_2b77: U32DivEngine → rem@sp+$05; rr sign → if set NegateBytes rem; jr_000_2b96 load DEHL; Jump_000_2b9f epilogue.

S32ModImpl::
    add sp, -$09
    ld b, $04
    ld hl, sp+$0b
    call MemIsZero
    jr nz, jr_000_2b3b

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_2b9f


jr_000_2b3b:
    ld hl, sp+$0f
    call MemIsZero
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
    call NegateBytes
    ld hl, sp+$00
    ld [hl], $01

jr_000_2b65:
    ld hl, sp+$0e
    ld a, [hl]
    bit 7, a
    jr z, jr_000_2b77

    ld hl, sp+$0b
    call NegateBytes
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
    call U32DivEngine
    add sp, $08
    ld hl, sp+$00
    rr [hl]
    jr nc, jr_000_2b96

    ld b, $04
    xor a
    ld hl, sp+$05
    call NegateBytes

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


; [ezgb]
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
    jr jr_000_2bd8

; [ezgb]
; MulU8xU8Arg: stack two u8 → C/E then MulU8xU8. Entry just above register ABI body.

MulU8xU8Arg::
    ld hl, sp+$02
    ld a, [hl+]
    ld c, a
    ld e, [hl]

; [ezgb]
; MulU8xU8(C×E) → DE: 8×8→16 shift-add. HL=0; jr_000_2bba: rr C, C-set → add hl,de.
; jr_000_2bc0: sla e / rl d; jr_000_2bc8 finish when DE shifted out. Used by U32MulEngine.

MulU8xU8::
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


; [ezgb]
; U16Mul(a@sp+$02, b@sp+$04) → DE: shift-add (Russian peasant). Load DE=a, BC=b.
; jr_000_2bd8: HL=0; fall jr_000_2bdb. jr_000_2bdb: sra B; NZ → jr_000_2be8 else rr C; C-set add HL,DE; jr_000_2be4.
; jr_000_2be4: Z after rr → jr_000_2bf9 else jr_000_2bed. jr_000_2be8: rr C; NC → jr_000_2bed else add HL,DE; fall jr_000_2bed.
; jr_000_2bed: sla E; Z → jr_000_2bf5 else rl D → jr_000_2bdb. jr_000_2bf5: rl D; NZ → jr_000_2bdb; fall jr_000_2bf9 DE=HL ret.

U16Mul::
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


; [ezgb]
; U32ModImpl: body of U32Mod stub. Twin of U32DivImpl; frame -$08; rem@sp+$04 → DEHL.
; MemIsZero dividend → DEHL=0 Jump_000_2c3f; else jr_000_2c0f.
; jr_000_2c0f: MemIsZero divisor → $d6c7=$21 + DEHL=$7fffffff Jump_000_2c3f; else jr_000_2c25.
; jr_000_2c25: U32DivEngine → load rem@sp+$04 into DEHL; Jump_000_2c3f epilogue.

U32ModImpl::
    add sp, -$08
    ld b, $04
    ld hl, sp+$0a
    call MemIsZero
    jr nz, jr_000_2c0f

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp Jump_000_2c3f


jr_000_2c0f:
    ld hl, sp+$0e
    call MemIsZero
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

Jump_000_2c3f:
    add sp, $08
    ret


; [ezgb]
; Strrchr(ptr@sp+$06, ch@sp+$08): last char in string → DE (0 if none). Used for '/' basename.
; Jump_000_2c50: ++BC until NUL; stash end@sp+$00. Jump_000_2c5b: --ptr; if at start → Jump_000_2c85 else Jump_000_2c73.
; Jump_000_2c73: *ptr!=ch → Jump_000_2c82 → Jump_000_2c5b; else jr_000_2c85. Jump_000_2c85/jr_000_2c85: recheck match.
; Hit jr_000_2c97 DE=ptr → Jump_000_2ca2; miss Jump_000_2c94 → Jump_000_2c9f DE=0 → Jump_000_2ca2 ret.

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

Strrchr_scanToNul::
    ld a, [bc]
    inc bc
    or a
    jp nz, Strrchr_scanToNul

    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b

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

Strrchr_mismatch::
    jp Strrchr_walkBack


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

Strrchr_missSkip::
    jp Strrchr_missZero


Strrchr_hitPtr::
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    jp Strrchr_epilogueRet


Strrchr_missZero::
    ld de, $0000

Strrchr_epilogueRet::
    add sp, $04
    ret


; [ezgb]
; Memset(dest, byte, len): fill dest with byte. Sibling of Memcpy.
; jr_000_2cb2: while BC≠0: *HL++=D, --BC. Stack: dest@sp+$02, byte@+$04, len@+$05.

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

jr_000_2cb2:
    ld a, b
    or c
    ret z

    dec bc
    ld [hl], d
    inc hl
    jr jr_000_2cb2

; [ezgb]
; Memcpy(dest, src, len).
; jr_000_2cc9: while BC≠0: *HL++=*DE++, --BC. Stack: dest@sp+$02, src@+$04, len@+$06.

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

; [ezgb]
; Strncpy(dest, src, n): frame -$07; stash dest@sp+$01, src@sp+$03, n=BC, ret-dest@sp+$05.
; Jump_000_2cf1: if BC==0 or *src==0 → Jump_000_2d1b; else --BC, ++src (jr_000_2d0c carry), *dest++=A (jr_000_2d18 carry) → Jump_000_2cf1.
; Jump_000_2d1b: stash rem n@sp+$03; Jump_000_2d20: --n; if 0 → Jump_000_2d44 else *dest++=0 (jr_000_2d41 carry) → Jump_000_2d20.
; Jump_000_2d44: DE=orig dest; add sp,$07 ret.

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


; [ezgb]
; NegateBytes: two's-complement negate of B bytes at HL (0-sbc loop).
; S32Div/S32Mod use this to abs signed long operands.
; jr_000_2d4f: D=0; for C=B: *HL++ = D-sbc-*HL (borrow chain); ret.

NegateBytes::
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


; [ezgb]
; PrintCharArg: stack u8 → PrintChar (A). Thin C ABI wrapper.

PrintCharArg::
    push bc
    ld hl, sp+$04
    ld a, [hl]
    call PrintChar
    pop bc
    ret


; [ezgb]
; PutBgTileArg: stack u8 → PutBgTile (A). Thin C ABI wrapper.

PutBgTileArg::
    push bc
    ld hl, sp+$04
    ld a, [hl]
    call PutBgTile
    pop bc
    ret


; [ezgb]
; SetTileCursor: stack (x, y) → wTileCursorX/Y. Tile-text cursor (vs SetTextCursor).

SetTileCursor::
    ld hl, sp+$02
    ld a, [hl+]
    ld [wTileCursorX], a
    ld a, [hl]
    ld [wTileCursorY], a
    ret


; [ezgb]
; GetTileCursorX: ensure EnterGfxMode2 if needed; return wTileCursorX in E.
; jr_000_2d7f: if wGfxMode bit1 clear → EnterGfxMode2; then E=wTileCursorX.

GetTileCursorX::
    ld a, [wGfxMode]
    and $02
    jr nz, jr_000_2d7f

    push bc
    call EnterGfxMode2
    pop bc

jr_000_2d7f:
    ld a, [wTileCursorX]
    ld e, a
    ret


; [ezgb]
; GetTileCursorY: ensure EnterGfxMode2 if needed; return wTileCursorY in E.
; jr_000_2d90: if wGfxMode bit1 clear → EnterGfxMode2; then E=wTileCursorY.

GetTileCursorY::
    ld a, [wGfxMode]
    and $02
    jr nz, jr_000_2d90

    push bc
    call EnterGfxMode2
    pop bc

jr_000_2d90:
    ld a, [wTileCursorY]
    ld e, a
    ret


; [ezgb]
; CStrLen(s): count bytes until NUL; length in DE. (Not Strlen — RGBDS STRLEN.)
; Jump_000_2da2: while *s++: ++len@sp+$00 (jr_000_2daf); Jump_000_2db2 DE=len ret.

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


; [ezgb]
; MemZero: write 0 to B bytes at HL. U32DivEngine clears quot/rem scratch with this.
; jr_000_2dbc: C=B; store A=0 via [HL+], dec C until zero.

MemZero::
    ld c, b
    xor a

jr_000_2dbc:
    ld [hl+], a
    dec c
    jr nz, jr_000_2dbc

    ret


; [ezgb]
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
; U32DivEngine: multi-byte restoring divide used by U32Div/U32Mod. Helpers:
; MemZero, MemRol ($2ee2), MemSubCmp ($2ed8), MemSub ($2e30), IncWord ($2ecb).
; B=digit width; C=B*8 bit count. Zero quot+rem scratch; jr_000_2df9: rol rem←dividend,
; MemSubCmp divisor; NC → MemSub; jr_000_2e1f: rol quot bit; --C loop. Orphan before MemSub.

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

jr_000_2df9:
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
    jr c, jr_000_2e1f

    call MemSub

jr_000_2e1f:
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
    jr jr_000_2df9

; [ezgb]
; MemSub: multi-byte SBC: [DE] -= [HL] for B bytes (carry chain). U32DivEngine rem -= divisor.
; jr_000_2e31: C=B; A=[DE] SBC [HL] → [DE]; ++HL/DE; until C=0.

MemSub::
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


; [ezgb]
; MemFill: store A into B bytes at HL++ (register ABI). Orphan between MemSub and U32MulEngine.
; jr_000_2e3b: C=B; store A via [HL+], dec C until zero.

MemFill::
    ld c, b

jr_000_2e3b:
    ld [hl+], a
    dec c
    jr nz, jr_000_2e3b

    ret


; [ezgb]
; U32MulEngine: multi-byte unsigned mul (B digit pairs). Zeros dest via MemZero,
; per-byte MulU8xU8 + PropagateCarry. U32Mul stub drives this with B=4.
; Jump_000_2e5e/jr_000_2e64: inner digit cross-products; add to dest + PropagateCarry; IncWord ptrs.
; jr_000_2e98: next outer digit (CopyBytes reset ptrs) → 2e5e; jr_000_2ec0 ret when B exhausted.

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
    jr z, jr_000_2e98

    ld a, [hl]
    adc d
    ld [hl+], a
    call PropagateCarry
    ld hl, sp+$05
    dec [hl]
    jr z, jr_000_2e98

    ld hl, sp+$0c
    call IncWord
    ld hl, sp+$08
    call IncWord
    jr jr_000_2e64

jr_000_2e98:
    ld hl, sp+$04
    dec [hl]
    jr z, jr_000_2ec0

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
    jp Jump_000_2e5e


jr_000_2ec0:
    add sp, $06
    ret


; [ezgb]
; PropagateCarry: walk C bytes at HL adding 0+carry (adc). After multi-byte add in mul.

PropagateCarry::
    dec c
    ret z

    ld a, $00
    adc [hl]
    ld [hl+], a
    jr PropagateCarry

; [ezgb]
; IncWord: ++*(u16*)HL (inc low, carry into high).

IncWord::
    inc [hl]
    ret nz

    inc hl
    inc [hl]
    ret


; [ezgb]
; CopyBytes: copy B bytes DE→HL (register ABI).
; jr_000_2ed1: C=B; A=[DE++] → [HL+]; until C=0.

CopyBytes::
    ld c, b

jr_000_2ed1:
    ld a, [de]
    inc de
    ld [hl+], a
    dec c
    jr nz, jr_000_2ed1

    ret


; [ezgb]
; MemSubCmp: multi-byte SBC compare [DE] vs [HL] for B bytes (no store). Flags = last SBC; U32DivEngine trial rem>=divisor.
; jr_000_2eda: C=B; A=[DE] SBC [HL]; ++HL/DE; until C=0 (result discarded, carry retained).

MemSubCmp::
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


; [ezgb]
; MemRol: rotate-left B bytes at HL through carry (RL [HL]). U32DivEngine shifts rem←dividend bit.
; jr_000_2ee3: C=B; RL [HL]; ++HL; until C=0.

MemRol::
    ld c, b

jr_000_2ee3:
    rl [hl]
    inc hl
    dec c
    jr nz, jr_000_2ee3

    ret


; [ezgb]
; EnterGfxMode1: LCD off if on; prep VRAM/tilemap/callbacks; LCD on; wGfxMode=1.
; Defaults: wDrawOp=0, wDrawColor=3, wDrawColorB=0. Draw helpers call this when wGfxMode!=1.
; jr_000_2ef4: VramFill $8100×$1680; VBlankCb_Bg8000 + LycCb_Bg8800; LYC=$48 STAT=$44; IE bit1.
; jr_000_2f23: E=$12 rows; jr_000_2f25: fill 20 tiles/row ids $10+ (skip 12); LCDC on; ei ret.

EnterGfxMode1::
    di
    ldh a, [rLCDC]
    bit 7, a
    jr z, jr_000_2ef4

    call LcdOff

jr_000_2ef4:
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
    ld [wGfxMode], a
    ld a, $00
    ld [wDrawOp], a
    ld a, $03
    ld [wDrawColor], a
    ld a, $00
    ld [wDrawColorB], a
    ei
    ret


; [ezgb]
; VramLoadTiles8100: VramCopy BC→$8100 for $1680 bytes (tile $10+ framebuffer pool).
; Stack wrapper ensures EnterGfxMode1 first.

VramLoadTiles8100::
    ld hl, $8100
    ld de, $1680
    call VramCopy
    ret


; [ezgb]
; BlitTile: B/C tile row/col via GfxRowTable; VramCopy $10 bytes (2bpp tile) to FB.
; Optional second plane from saved DE. Stack wrapper ensures EnterGfxMode1.
; jr_000_2f84: dest=GfxRowTable[col]+row*16 on stack; if HL==0 skip first VramCopy $10; then pop dest + DE and VramCopy $10 (2nd plane).

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
    jr z, jr_000_2f84

    ld de, $0010
    call VramCopy

jr_000_2f84:
    pop hl
    pop bc
    ld de, $0010
    call VramCopy
    ret


; [ezgb]
; BlitTileXY: ensure mode-1; stack args → BlitTile (B/C/DE/HL).

BlitTileXY::
    push bc
    ld a, [wGfxMode]
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
; VramLoadTiles8100Arg: ensure mode-1; stack BC → VramLoadTiles8100.

VramLoadTiles8100Arg::
    push bc
    ld a, [wGfxMode]
    cp $01
    call nz, EnterGfxMode1
    ld hl, sp+$04
    ld a, [hl+]
    ld c, a
    ld b, [hl]
    call VramLoadTiles8100
    pop bc
    ret


; [ezgb]
; GfxRowTable: 144 words, scanline y -> VRAM address for mode-1 framebuffer.
; Starts at $8100 (tile $10), 20 tiles wide (160px). Used by PlotPixel/GetPixel.

GfxRowTable::
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
    ld [DirList_skipDot], sp
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

; [ezgb]
; VramCopy: copy DE bytes BC→HL waiting for STAT mode≠2 (VRAM-safe).
; VramCopyStack ($30ea) is the stack-ABI wrapper (dest, src, len).

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


    ld hl, $3104
    call RegisterFont
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
    call ReadJoypadRaw
    or a
    jr nz, jr_000_3a08

    dec b
    jr nz, jr_000_3a0a

    pop bc
    pop af
    ret


; [ezgb]
; ReadJoypadRaw: hardware P1 read → packed buttons in A (then swapped for menu ABI).
; jr_000_3a22: after d-pad nibble ($20 select), swap into B; read face buttons ($10); OR; final swap; P1=$30 idle.

ReadJoypadRaw::
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


; [ezgb]
; WaitJoypadMask: spin on ReadJoypadRaw until (A & B) nonzero. B = mask.

WaitJoypadMask::
    call ReadJoypadRaw
    and b
    jr z, WaitJoypadMask

    ret


; [ezgb]
; ReadJoypad: returns the menu key byte (post-swap: A=$10, B=$20, START=$80).
; ReadJoypadRaw ($3a16) is the lower-level read that ends with the swap.

ReadJoypad::
    call ReadJoypadRaw
    ld e, a
    ret


; [ezgb]
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
; DelayDE: push BC; DelayInner(DE); B=$32; Jump_000_3a5f pad loop; nop; pop BC; trail; ret. Used by Delay($3a93).
; Jump_000_3a5f → jr_000_3a61 → jr_000_3a63 → jr_000_3a65 → jr_000_3a67 → jr_000_3a69: five jr pads then --B; NZ → Jump_000_3a5f.
; After pad: nop; pop BC; jr_000_3a71 → jr_000_3a73 → jr_000_3a75 → ret (three more jr pads).

DelayDE::
    push bc
    call DelayInner
    ld b, $32

DelayDE_padLoop::
    jr DelayDE_padA

DelayDE_padA::
    jr DelayDE_padB

DelayDE_padB::
    jr DelayDE_padC

DelayDE_padC::
    jr DelayDE_padD

DelayDE_padD::
    jr DelayDE_padDecB

DelayDE_padDecB::
    dec b
    jp nz, DelayDE_padLoop

    nop
    pop bc
    jr DelayDE_trailA

DelayDE_trailA::
    jr DelayDE_trailB

DelayDE_trailB::
    jr DelayDE_ret

DelayDE_ret::
    ret


; [ezgb]
; DelayInner: --DE; if DE==0 ret; else B=$33; Jump_000_3a7c pad; nop; trail; jr DelayInner. Nested core for DelayDE.
; Jump_000_3a7c → jr_000_3a7e → jr_000_3a80 → jr_000_3a82 → jr_000_3a84 → jr_000_3a86: five jr pads then --B; NZ → Jump_000_3a7c.
; After pad: nop; jr_000_3a8d → jr_000_3a8f → jr_000_3a91 → DelayInner (three jr pads then outer loop).

DelayInner::
    dec de
    ld a, e
    or d
    ret z

    ld b, $33

DelayInner_padLoop::
    jr DelayInner_padA

DelayInner_padA::
    jr DelayInner_padB

DelayInner_padB::
    jr DelayInner_padC

DelayInner_padC::
    jr DelayInner_padD

DelayInner_padD::
    jr DelayInner_padDecB

DelayInner_padDecB::
    dec b
    jp nz, DelayInner_padLoop

    nop
    jr DelayInner_trailA

DelayInner_trailA::
    jr DelayInner_trailB

DelayInner_trailB::
    jr DelayInner_outerLoop

DelayInner_outerLoop::
    jr DelayInner

; [ezgb]
; Delay(count): stack u16 → DelayDE. Busy-wait; callers pass e.g. $00c8/$002d.
; DelayDE ($3a59) + DelayInner ($3a76) are the register/nested loops.

Delay::
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    call DelayDE
    ret


; [ezgb]
; CopyTilesVram(HL=dst VRAM, BC=src, DE=count): plain 2bpp byte-pair blit (no color remap). Sibling CopyTilesColor.
; DE==0 early ret; H≥$98 → H-=$10. jr_000_3aa7: if E==0 --D; jr_000_3aac STAT-wait [HL++]=[BC++]; jr_000_3ab5 STAT-wait second byte.
; jr_000_3ac9: --E; NZ → jr_000_3aac; --D; if D signed clear → jr_000_3aac else ret. H wrap $98→$88 after lo-byte wrap.

CopyTilesVram::
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


; [ezgb]
; CopyTilesColor(HL=dst VRAM, BC=src, DE=count): 2bpp byte-pair blit with wDrawColor/wDrawColorB remap. DE==0 early ret; H≥$98 → H-=$10.
; jr_000_3add: load *src++; colorB.0 → B=$ff else jr_000_3aee; colorB.1 → C=$ff else jr_000_3af4.
; jr_000_3af4: D=color^colorB; bit0 → B^=src (else jr_000_3b01); bit1 → C^=src (else jr_000_3b08).
; jr_000_3b08: STAT-wait [HL++]=B; jr_000_3b10: STAT-wait [HL++]=C; H==$98 → $88; jr_000_3b1f: --DE; NZ → jr_000_3add else ret. Used by UploadFontTiles.

CopyTilesColor::
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
    ld a, [wDrawColorB]
    bit 0, a
    jr z, jr_000_3aee

    ld b, $ff

jr_000_3aee:
    bit 1, a
    jr z, jr_000_3af4

    ld c, $ff

jr_000_3af4:
    ld d, a
    ld a, [wDrawColor]
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


; [ezgb]
; RegisterFont(HL=font desc): LCD off; find free 3-byte slot in wFontSlots ($d73a,
; 6 entries); store next-tile id + font ptr; SelectFont; if wGfxMode bit1 set,
; UploadFontTiles; bump wFontNextTile by glyph count; LCD on. Returns HL=slot or 0.
; jr_000_3b30: scan slots; free → jr_000_3b42 store+SelectFont+maybe Upload; full → HL=0.
; jr_000_3b66: LCDC on ($81 & ~$18) ret. Orphan before UploadFontTiles.

RegisterFont::
    call LcdOff
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
    ld a, [wFontNextTile]
    dec hl
    ld [hl], a
    push hl
    call SelectFont
    ld a, [wGfxMode]
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

jr_000_3b66:
    ldh a, [rLCDC]
    or $81
    and $e7
    ldh [rLCDC], a
    ret


; [ezgb]
; UploadFontTiles: blit current font glyphs into VRAM near $9000+wFontBaseTile.
; Uses CopyTilesVram ($3a9c) or CopyTilesColor ($3ad2) per font header flags.
; jr_000_3b9b: glyph src offset BC from header lo2 ($01→$80, $02→$0, else $100); dest=$9000+base*16; bit2→Color else Vram.

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
; PrintChar(A): if A==$0a TileNewline (unless wGfxMode bit3); else PutBgTile
; then AdvanceTileCursor. Tilemap text path (cursor wTileCursorX/Y).

PrintChar::
    cp $0a
    jr nz, jr_000_3bd6

    push af
    ld a, [wGfxMode]
    and $08
    jr nz, jr_000_3bd5

    call TileNewline
    pop af
    ret


jr_000_3bd5:
    pop af

jr_000_3bd6:
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
; PutBgTile(A): map char through font at wFontPtr → tile id at BG $9800+y*32+x (wTileCursorY/X). STAT-safe.
; If wFontFarFlag==0: ResetTileText + FarCallTrampoline; jr_000_3c01 nop fallthrough.
; jr_000_3c02: if font hdr&3!=2 index glyph table else keep A; jr_000_3c19 +wFontBaseTile; map ptr; jr_000_3c34 STAT-wait store E.

PutBgTile::
    push af
    ld a, [wFontFarFlag]
    or a
    jr nz, jr_000_3c02

    call ResetTileText
    xor a
    ld [wFontNextTile], a
    call FarCallTrampoline
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
    ld hl, wFontPtr
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

jr_000_3c34:
    ldh a, [rSTAT]
    bit 1, a
    jr nz, jr_000_3c34

    ld [hl], e
    pop hl
    pop de
    pop bc
    ret


; [ezgb]
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
; ResetTileText: EnterGfxMode2 path prep — InitGfxMode2 via $3d21, wFontNextTile=1,
; clear wFontSlots, default draw colors, ClearBgMap.
; jr_000_3c6b: zero $12 bytes at wFontSlots; then wDrawColor=3 / wDrawColorB=0; ClearBgMap.

ResetTileText::
    push bc
    call EnterGfxMode2
    ld a, $01
    ld [wFontNextTile], a
    xor a
    ld hl, wFontSlots
    ld b, $12

jr_000_3c6b:
    ld [hl+], a
    dec b
    jr nz, jr_000_3c6b

    ld a, $03
    ld [wDrawColor], a
    ld a, $00
    ld [wDrawColorB], a
    call ClearBgMap
    pop bc
    ret


; [ezgb]
; ClearBgMap: fill BG map $9800 with tile 0 (32×32), STAT-safe.
; jr_000_3c85: 32 rows; jr_000_3c87: STAT-wait write 0, 32 cols/row. Orphan before RetreatTileCursor.

ClearBgMap::
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


; [ezgb]
; RetreatTileCursor: --wTileCursorX; at X=0 wrap to $13 and --Y (clamp at Y=0).
; jr_000_3ca4: X wrap + maybe --Y; jr_000_3cae: pop HL ret. Inverse of AdvanceTileCursor.

RetreatTileCursor::
    push hl
    ld hl, wTileCursorX
    xor a
    cp [hl]
    jr z, jr_000_3ca4

    dec [hl]
    jr jr_000_3cae

jr_000_3ca4:
    ld [hl], $13
    ld hl, wTileCursorY
    xor a
    cp [hl]
    jr z, jr_000_3cae

    dec [hl]

jr_000_3cae:
    pop hl
    ret


; [ezgb]
; TileNewline: wTileCursorX=0; ++Y or ScrollBgUp at bottom row ($11).
; jr_000_3cc0: Y==$11 → ScrollBgUp; else ++Y; jr_000_3cc3 ret. Used by PrintChar on $0a.

TileNewline::
    push hl
    xor a
    ld [wTileCursorX], a
    ld hl, wTileCursorY
    ld a, $11
    cp [hl]
    jr z, jr_000_3cc0

    inc [hl]
    jr jr_000_3cc3

jr_000_3cc0:
    call ScrollBgUp

jr_000_3cc3:
    pop hl
    ret


; [ezgb]
; AdvanceTileCursor: ++wTileCursorX; wrap at $13 and bump Y (tilemap text).
; jr_000_3cd1: X wrap → Y++; at Y=$11 → jr_000_3cde: if wGfxMode bit2 set reset cursors else jr_000_3cee ScrollBgUp.
; jr_000_3cf1: pop HL ret. Sibling of AdvanceTextCursor.

AdvanceTileCursor::
    push hl
    ld hl, wTileCursorX
    ld a, $13
    cp [hl]
    jr z, jr_000_3cd1

    inc [hl]
    jr jr_000_3cf1

jr_000_3cd1:
    ld [hl], $00
    ld hl, wTileCursorY
    ld a, $11
    cp [hl]
    jr z, jr_000_3cde

    inc [hl]
    jr jr_000_3cf1

jr_000_3cde:
    ld a, [wGfxMode]
    and $04
    jr z, jr_000_3cee

    xor a
    ld [wTileCursorY], a
    ld [wTileCursorX], a
    jr jr_000_3cf1

jr_000_3cee:
    call ScrollBgUp

jr_000_3cf1:
    pop hl
    ret


; [ezgb]
; ScrollBgUp: shift BG map $9800 up one row (31 row copies $9820→$9800). Called by AdvanceTileCursor.
; jr_000_3cfe: D=$20 tiles/row; jr_000_3d00: STAT-wait copy [BC]→[HL++]; --E rows.
; jr_000_3d11: STAT-wait clear bottom row to 0; pop HL/DE/BC ret.

ScrollBgUp::
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


; [ezgb]
; EnterGfxMode2: tear down mode-1 VBlank/LCD callbacks if LCD on, InitGfxMode2
; (clear cursors + BG, wGfxMode=2), restore LCDC. Tilemap text mode.
; jr_000_3d3d: if LCD already off skip LcdOff+RemoveCallbackSlot; then InitGfxMode2, LCDC|=$81 &=$E7, ei.

EnterGfxMode2::
    di
    ldh a, [rLCDC]
    bit 7, a
    jr z, jr_000_3d3d

    call LcdOff
    ld bc, VBlankCb_Bg8000
    ld hl, wVBlankCallbacks
    call RemoveCallbackSlot
    ld bc, LycCb_Bg8800
    ld hl, wLcdCallbacks
    call RemoveCallbackSlot

jr_000_3d3d:
    call InitGfxMode2
    ldh a, [rLCDC]
    or $81
    and $e7
    ldh [rLCDC], a
    ei
    ret


InitGfxMode2::
    xor a
    ld [wTileCursorX], a
    ld [wTileCursorY], a
    call ClearBgMap
    ld a, $02
    ld [wGfxMode], a
    ret


; [ezgb]
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
; VramFillActiveWinMap: pick window tilemap base from LCDC bit6 ($9800/$9C00),
; then VramFill $0400 bytes with B. Sibling VramFillActiveBgMap uses BG map bit3.
; jr_000_3d73: bit6 set → HL=$9C00; else $9800; both jr to shared $3d86 VramFill tail.

VramFillActiveWinMap::
    ldh a, [rLCDC]
    bit 6, a
    jr nz, jr_000_3d73

    ld hl, $9800
    jr jr_000_3d86

jr_000_3d73:
    ld hl, $9c00
    jr jr_000_3d86

; [ezgb]
; VramFillActiveBgMap: pick BG tilemap base from LCDC bit3 ($9800/$9C00), then
; VramFill $0400 bytes with B. Shares tail at $3d86 with VramFillActiveWinMap.
; jr_000_3d83: bit3 set → HL=$9C00; else $9800; jr_000_3d86: DE=$0400 jp VramFill.

VramFillActiveBgMap::
    ldh a, [rLCDC]
    bit 3, a
    jr nz, jr_000_3d83

    ld hl, $9800
    jr jr_000_3d86

jr_000_3d83:
    ld hl, $9c00

jr_000_3d86:
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
