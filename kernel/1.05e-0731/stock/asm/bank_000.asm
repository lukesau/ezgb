; Disassembly of "kernel.gb"
; This file was created with:
; mgbdis v3.0 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $000", ROM0[$0]

INCLUDE "crt0_low.inc"



UiRows::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff

UiRowsHL::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff

UiRowsMinus1BC::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

ClampBrowserRows::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff

MarqueeWidth::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff

MarqueeDraw::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff

MarqueeShift::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff

MarqueeWidth12::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

CgbInit::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff

    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

PopupDrawParams::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff

    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

SgbVblTail::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff

    rst $38
    rst $38
    rst $38
    rst $38

BrowserScrollDownHook::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff

    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

BrowserScrollUpHook::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff

BrowserPageEnd::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff

    rst $38
    rst $38

LastRomNameStub::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

LastRomTickStub::
    db $ff, $ff, $ff, $ff, $ff, $ff

; [ezgb]
; InvalidFarCallTrap: rst $38 trap. Sole caller: FarCall_03_76cc (FatFs f_lseek far-call
; wrapper) does call z, InvalidFarCallTrap right after FarCallTrampoline — fires only if
; the trampoline signals failure. Followed by ~82 more rst $38 bytes (alignment filler
; reusing the same opcode, not separately reachable).

InvalidFarCallTrap::
    db $ff, $ff, $ff, $ff, $ff

    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

TabNum12::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff

    rst $38
    rst $38
    rst $38

BkSpinStub::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff

BkSavingStub::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff

SaveStampHook::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff

    rst $38
    rst $38
    jp EnterGfxMode1


    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

BrowserSortAllStub::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

FarCallDrawDetailBottom::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

BrowserPageEndHook::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff

    rst $38

FarCallScan::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

FarCallTagLen::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

fastlaunch_do_launch::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff

RomMenuPadTrack::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff

    rst $38
    rst $38

fastlaunch_hook::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff

FarCallDrawLoadingBox::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

fastlaunch_boot::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff

DirListHideNameStub::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff

FlPickHook::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff

SgbVblList::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff

FlSetExitHook::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff

    rst $38
    rst $38

FlPickCancelHook::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff

    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

RtcBootHook::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff

    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

BatteryDryHook::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff

    rst $38
    rst $38
    rst $38
    rst $38

LastRomFallbackHook::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff

DirEnterBoundCheck::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff

RelaunchRtcHook::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff

RomMenuHoldStub::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff

    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    jp EnterGfxMode2


    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

FarCallDrawString12::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

VramWaitSpin::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff

VBlankPadLatch::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff

SgbPadGate::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff

INCLUDE "crt0_home.inc"



; $07bc-$1926: src/kernel.c
INCLUDE "b0_kernel.inc"


; $1926-$20bb: src/fsglue.c, src/diskio.c, src/option/ccsbcs.c
INCLUDE "b0_fatfs.inc"


; $20bb-$20e2: sdcclib/crt0_rle.s
INCLUDE "b0_rle.inc"


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

ApplyBasename_copyLoop::
    ld a, [de]
    inc de
    ld [hl], a
    and a
    ret z

    inc hl
    jr ApplyBasename_copyLoop

; $20f4-$2826: GBDK drawing.s (_CODE)
INCLUDE "b0_gbdk_code.inc"


; $2826-$29e6: sdcclib/stubs.s, div.s, shift.s
INCLUDE "b0_sdccasm.inc"


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
    jr nz, S32DivImpl_checkDivisor

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp S32DivImpl_epilogueRet


S32DivImpl_checkDivisor::
    ld hl, sp+$0f
    call MemIsZero
    jr nz, S32DivImpl_clearSign

    ld a, $21
    ld [$d6c7], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp S32DivImpl_epilogueRet


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

S32DivImpl_loadQuot::
    ld hl, sp+$01
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

S32DivImpl_epilogueRet::
    add sp, $09
    ret


; $2a5f-$2a77: GBDK drawing.s (.vbl, .lcd)
INCLUDE "b0_gbdk_vbl.inc"


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
    jr nz, U32DivImpl_checkDivisor

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp U32DivImpl_epilogueRet


U32DivImpl_checkDivisor::
    ld hl, sp+$0e
    call MemIsZero
    jr nz, U32DivImpl_runEngine

    ld a, $21
    ld [$d6c7], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp U32DivImpl_epilogueRet


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

U32DivImpl_epilogueRet::
    add sp, $08
    ret


; [ezgb]
; MemIsZero: scan B bytes at HL; Z if all zero else NZ. Used by U32/S32 div/mod
; stubs to reject zero dividend/divisor before U32DivEngine.
; jr_000_2abf: while C--: *HL++==0 else NZ ret; fallthrough Z ret.

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


; [ezgb]
; ClearNegZero32: HL→MSB of 4-byte LE value; if value is 0 or $80000000,
; clear sign bit (force -0 → +0). Used by S32Cmp.
; jr_000_2ad9: if bit7 clear A=0 else A=$80; match MSB then scan 3 lower bytes==0 → res 7.

ClearNegZero32::
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


; [ezgb]
; MemCmp3Down: compare 3 bytes at DE vs HL walking downward; NZ on first diff.
; Local helper for S32Cmp MSB-side compare.
; jr_000_2aed: C=3; *DE-*HL; NZ ret; dec both; --C; Z after 3 → equal ret.

MemCmp3Down::
    ld c, $03

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
    jr z, S32Cmp_retALess

    ld hl, sp+$0b
    ld d, h
    ld e, l
    ld hl, sp+$07
    jr MemCmp3Down

S32Cmp_retALess::
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
    jr nz, S32ModImpl_checkDivisor

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp S32ModImpl_epilogueRet


S32ModImpl_checkDivisor::
    ld hl, sp+$0f
    call MemIsZero
    jr nz, S32ModImpl_clearSign

    ld a, $21
    ld [$d6c7], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp S32ModImpl_epilogueRet


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

S32ModImpl_loadRem::
    ld hl, sp+$05
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld h, [hl]
    ld l, a

S32ModImpl_epilogueRet::
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
    jr U16Mul_initHl0

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

MulU8xU8_rrC::
    xor a
    rr c
    jr nc, MulU8xU8_shiftE

    add hl, de

MulU8xU8_shiftE::
    sla e
    jr z, MulU8xU8_finish

    rl d
    jr MulU8xU8_rrC

MulU8xU8_finish::
    rl d
    jr nz, MulU8xU8_rrC

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

U16Mul_initHl0::
    ld hl, $0000

U16Mul_loop::
    sra b
    jr nz, U16Mul_rrCPath

    rr c
    jr nc, U16Mul_afterAddLo

    add hl, de

U16Mul_afterAddLo::
    jr z, U16Mul_retDe

    jr U16Mul_slaE

U16Mul_rrCPath::
    rr c
    jr nc, U16Mul_slaE

    add hl, de

U16Mul_slaE::
    sla e
    jr z, U16Mul_rlDOnly

    rl d
    jr U16Mul_loop

U16Mul_rlDOnly::
    rl d
    jr nz, U16Mul_loop

U16Mul_retDe::
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
    jr nz, U32ModImpl_checkDivisor

    xor a
    ld e, a
    ld d, a
    ld l, a
    ld h, a
    jp U32ModImpl_epilogueRet


U32ModImpl_checkDivisor::
    ld hl, sp+$0e
    call MemIsZero
    jr nz, U32ModImpl_runEngine

    ld a, $21
    ld [$d6c7], a
    ld a, $ff
    ld e, a
    ld d, a
    ld l, a
    ld h, $7f
    jp U32ModImpl_epilogueRet


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

U32ModImpl_epilogueRet::
    add sp, $08
    ret


; $2c42-$2ca5: sdcclib/_strrchr.c
INCLUDE "b0_strrchr.inc"


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

Memset_fillLoop::
    ld a, b
    or c
    ret z

    dec bc
    ld [hl], d
    inc hl
    jr Memset_fillLoop

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

; $2cd3-$2d4c: sdcclib/_strncpy.c
INCLUDE "b0_strncpy.inc"


; [ezgb]
; NegateBytes: two's-complement negate of B bytes at HL (0-sbc loop).
; S32Div/S32Mod use this to abs signed long operands.
; jr_000_2d4f: D=0; for C=B: *HL++ = D-sbc-*HL (borrow chain); ret.

NegateBytes::
    ld c, b
    xor a
    ld d, a

NegateBytes_sbcLoop::
    ld a, d
    sbc [hl]
    ld [hl+], a
    dec c
    jr nz, NegateBytes_sbcLoop

    ret


; $2d56-$2d95: GBDK font.ms (_CODE)
INCLUDE "b0_gbdk_font.inc"


; $2d95-$2dba: sdcclib/_strlen.c
INCLUDE "b0_strlen.inc"


; [ezgb]
; MemZero: write 0 to B bytes at HL. U32DivEngine clears quot/rem scratch with this.
; jr_000_2dbc: C=B; store A=0 via [HL+], dec C until zero.

MemZero::
    ld c, b
    xor a

MemZero_fillLoop::
    ld [hl+], a
    dec c
    jr nz, MemZero_fillLoop

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
; MemSub: multi-byte SBC: [DE] -= [HL] for B bytes (carry chain). U32DivEngine rem -= divisor.
; jr_000_2e31: C=B; A=[DE] SBC [HL] → [DE]; ++HL/DE; until C=0.

MemSub::
    ld c, b

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
; MemFill: store A into B bytes at HL++ (register ABI). Orphan between MemSub and U32MulEngine.
; jr_000_2e3b: C=B; store A via [HL+], dec C until zero.

MemFill::
    ld c, b

MemFill_fillLoop::
    ld [hl+], a
    dec c
    jr nz, MemFill_fillLoop

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

U32MulEngine_outerSetup::
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


U32MulEngine_epilogueRet::
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

CopyBytes_copyLoop::
    ld a, [de]
    inc de
    ld [hl+], a
    dec c
    jr nz, CopyBytes_copyLoop

    ret


; [ezgb]
; MemSubCmp: multi-byte SBC compare [DE] vs [HL] for B bytes (no store). Flags = last SBC; U32DivEngine trial rem>=divisor.
; jr_000_2eda: C=B; A=[DE] SBC [HL]; ++HL/DE; until C=0 (result discarded, carry retained).

MemSubCmp::
    ld c, b
    xor a

MemSubCmp_sbcLoop::
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    dec c
    jr nz, MemSubCmp_sbcLoop

    ret


; [ezgb]
; MemRol: rotate-left B bytes at HL through carry (RL [HL]). U32DivEngine shifts rem←dividend bit.
; jr_000_2ee3: C=B; RL [HL]; ++HL; until C=0.

MemRol::
    ld c, b

MemRol_rlLoop::
    rl [hl]
    inc hl
    dec c
    jr nz, MemRol_rlLoop

    ret


; $2eea-$3d8c: GBDK drawing.s, cpy_data.s, ibmfixed.s, pad.s, delay.s, font.ms, init_tt.s (_BASE)
INCLUDE "b0_gbdk_base.inc"


BrowserScrollDownRepaint::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff

    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

DrawNameWithIcon::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

BrowserScroll::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff

    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
