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

RleUnpack_fetchLen::
    ld e, [hl]
    inc hl
    bit 7, e
    jp z, RleUnpack_literalOrDone

    ld a, [hl]
    inc hl

RleUnpack_runStore::
    ld [bc], a
    inc bc
    inc e
    jp nz, RleUnpack_runStore

    jp RleUnpack_fetchLen


RleUnpack_literalOrDone::
    xor a
    or e
    jp z, RleUnpack_retPastStream

RleUnpack_copyLiteral::
    ld a, [hl]
    inc hl
    ld [bc], a
    inc bc
    dec e
    jp nz, RleUnpack_copyLiteral

    jp RleUnpack_fetchLen


RleUnpack_retPastStream::
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

ApplyBasename_copyLoop::
    ld a, [de]
    inc de
    ld [hl], a
    and a
    ret z

    inc hl
    jr ApplyBasename_copyLoop

; [ezgb]
; AdvanceTextCursor: ++wTextCursorX; wrap at $13 → X=0, ++Y; at Y=$11 → Y=0 (no scroll).
; jr_000_2100: X wrap + maybe ++Y; jr_000_210d: Y wrap to 0; jr_000_210f: pop HL ret.
; Mode-1 framebuffer text sibling of AdvanceTileCursor. Used by DrawGlyphAdvance.

AdvanceTextCursor::
    push hl
    ld hl, wTextCursorX
    ld a, $13
    cp [hl]
    jr z, AdvanceTextCursor_wrapX

    inc [hl]
    jr AdvanceTextCursor_epilogueRet

AdvanceTextCursor_wrapX::
    ld [hl], $00
    ld hl, wTextCursorY
    ld a, $11
    cp [hl]
    jr z, AdvanceTextCursor_wrapY

    inc [hl]
    jr AdvanceTextCursor_epilogueRet

AdvanceTextCursor_wrapY::
    ld [hl], $00

AdvanceTextCursor_epilogueRet::
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
    jr DrawCircle_midpointLoop

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
    jp DrawCircle_midpointLoop


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
    jr nc, DrawRectImpl_afterSwapX

    ld a, c
    ld [wDrawX0], a
    ld a, b
    ld [wDrawX1], a

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

DrawRectImpl_fillScan::
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
    jr DrawRectImpl_fillScan

DrawRectImpl_restoreColors::
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
    jr nz, ApplyPixel_checkPlane1

    push bc
    ld b, $00

ApplyPixel_checkPlane1::
    bit 1, d
    jr nz, ApplyPixel_waitStatWrite

    ld e, $00

ApplyPixel_waitStatWrite::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, ApplyPixel_waitStatWrite

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

GetPixel_waitStat::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, GetPixel_waitStat

    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld e, a
    ld b, $00
    ld a, d
    and c
    jr z, GetPixel_testPlane0

    set 0, b

GetPixel_testPlane0::
    ld a, e
    and c
    jr z, GetPixel_retColor

    set 1, b

GetPixel_retColor::
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

ApplyPixelSafe::
    db $16, $00, $fa, $33, $d7, $07, $07, $07
    db $5f, $19, $19, $46, $23, $66, $68, $fa
    db $32, $d7, $07, $07, $07, $5f, $19, $19
    db $79, $44, $4d, $62, $6f, $29, $29, $29
    db $11, $06, $32, $19, $54, $5d, $60, $69
    db $fa, $34, $d7, $4f, $1a, $13, $d5, $e5
    db $21, $35, $d7, $6e, $47, $af, $cb, $45
    db $28, $01, $2f, $b0, $cb, $41, $20, $01
    db $a8, $57

ReadJoypadLatched::
    db $af, $cb, $4d, $28, $01, $2f, $b0, $cb
    db $49, $20, $01, $a8, $5f, $e1, $f0, $41
    db $cb, $4f, $20, $fa, $7a, $22, $7b, $22
    db $d1, $7d, $e6, $0f, $20, $cc, $c9

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
    rst $08
    jp U16Mul


    ld a, $05
    rst $08
    jp S16Div


    ld a, $05
    rst $08
    jp U16Div


    ld a, $05
    rst $08
    jp S8Mul


    ld a, $05
    rst $08
    jp S8Div


    ld a, $05
    rst $08
    jp MulU8xU8Arg


    ld a, $05
    rst $08
    jp U8Div


    ld a, $05
    rst $08
    jp S8Mod


    ld a, $05
    rst $08
    jp U8Mod


    ld a, $05
    rst $08
    jp S16Mod


    ld a, $05
    rst $08
    jp U16Mod


    ld a, $05
    rst $08
    jp U32Shr


    ld a, $05
    rst $08
    jp S32Sar


    ld a, $05
    rst $08
    jp U32Shl


    ld a, $05
    rst $08
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
    jr nz, U16DivMod_setup

    ld bc, $0000
    ld d, b
    ld e, c
    scf
    ret


U16DivMod_setup::
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
    jr c, U16DivMod_restoreBorrow

    pop bc
    jr U16DivMod_checkBit

U16DivMod_restoreBorrow::
    inc sp
    inc sp

U16DivMod_checkBit::
    jr c, U16DivMod_lastBit

    pop af
    dec a
    or a
    jr nz, U16DivMod_shiftLoop

    jr U16DivMod_finish

U16DivMod_lastBit::
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
    jr nz, GetTileCursorX_retX

    push bc
    call EnterGfxMode2
    pop bc

GetTileCursorX_retX::
    ld a, [wTileCursorX]
    ld e, a
    ret


; [ezgb]
; GetTileCursorY: ensure EnterGfxMode2 if needed; return wTileCursorY in E.
; jr_000_2d90: if wGfxMode bit1 clear → EnterGfxMode2; then E=wTileCursorY.

GetTileCursorY::
    ld a, [wGfxMode]
    and $02
    jr nz, GetTileCursorY_retY

    push bc
    call EnterGfxMode2
    pop bc

GetTileCursorY_retY::
    ld a, [wTileCursorY]
    ld e, a
    ret


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


; [ezgb]
; EnterGfxMode1: LCD off if on; prep VRAM/tilemap/callbacks; LCD on; wGfxMode=1.
; Defaults: wDrawOp=0, wDrawColor=3, wDrawColorB=0. Draw helpers call this when wGfxMode!=1.
; jr_000_2ef4: VramFill $8100×$1680; VBlankCb_Bg8000 + LycCb_Bg8800; LYC=$48 STAT=$44; IE bit1.
; jr_000_2f23: E=$12 rows; jr_000_2f25: fill 20 tiles/row ids $10+ (skip 12); LCDC on; ei ret.

EnterGfxMode1::
    di
    ldh a, [rLCDC]
    bit 7, a
    jr z, EnterGfxMode1_vramFill

    call LcdOff

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

EnterGfxMode1_rowSetup::
    ld d, $14

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
    jr z, BlitTile_copyPlane2

    ld de, $0010
    call VramCopy

BlitTile_copyPlane2::
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


    ld hl, DefaultFontData
    call RegisterFont
    ret


DefaultFontData::
    db $04, $ff
    db $00, $01
    db $02, $03
    db $04, $05
    db $06, $07
    db $08, $09
    db $0a, $0b
    db $0c, $0d
    db $0e, $0f
    db $10, $11
    db $12, $13
    db $14, $15
    db $16, $17
    db $18, $19
    db $1a, $1b
    db $1c, $1d
    db $1e, $1f
    db $20, $21
    db $22, $23
    db $24, $25
    db $26, $27
    db $28, $29
    db $2a, $2b
    db $2c, $2d
    db $2e, $2f
    db $30, $31
    db $32, $33
    db $34, $35
    db $36, $37
    db $38, $39
    db $3a, $3b
    db $3c, $3d
    db $3e, $3f
    db $40, $41
    db $42, $43
    db $44, $45
    db $46, $47
    db $48, $49
    db $4a, $4b
    db $4c, $4d
    db $4e, $4f
    db $50, $51
    db $52, $53
    db $54, $55
    db $56, $57
    db $58, $59
    db $5a, $5b
    db $5c, $5d
    db $5e, $5f
    db $60, $61
    db $62, $63
    db $64, $65
    db $66, $67
    db $68, $69
    db $6a, $6b
    db $6c, $6d
    db $6e, $6f
    db $70, $71
    db $72, $73
    db $74, $75
    db $76, $77
    db $78, $79
    db $7a, $7b
    db $7c, $7d
    db $7e, $7f
    db $80, $81
    db $82, $83
    db $84, $85
    db $86, $87
    db $88, $89
    db $8a, $8b
    db $8c, $8d
    db $8e, $8f
    db $90, $91
    db $92, $93
    db $94, $95
    db $96, $97
    db $98, $99
    db $9a, $9b
    db $9c, $9d
    db $9e, $9f
    db $a0, $a1
    db $a2, $a3
    db $a4, $a5
    db $a6, $a7
    db $a8, $a9
    db $aa, $ab
    db $ac, $ad
    db $ae, $af
    db $b0, $b1
    db $b2, $b3
    db $b4, $b5
    db $b6, $b7
    db $b8, $b9
    db $ba, $bb
    db $bc, $bd
    db $be, $bf
    db $c0, $c1
    db $c2, $c3
    db $c4, $c5
    db $c6, $c7
    db $c8, $c9
    db $ca, $cb
    db $cc, $cd
    db $ce, $cf
    db $d0, $d1
    db $d2, $d3
    db $d4, $d5
    db $d6, $d7
    db $d8, $d9
    db $da, $db
    db $dc, $dd
    db $de, $df
    db $e0, $e1
    db $e2, $e3
    db $e4, $e5
    db $e6, $e7
    db $e8, $e9
    db $ea, $eb
    db $ec, $ed
    db $ee, $ef
    db $f0, $f1
    db $f2, $f3
    db $f4, $f5
    db $f6, $f7
    db $f8, $f9
    db $fa, $fb
    db $fc, $fd
    db $fe, $ff

FontGlyphSheet::
    db $00, $00
    db $00, $00
    db $00, $00
    db $00, $00
    db $18, $24
    db $42, $81
    db $e7, $24
    db $24, $3c
    db $3c, $24
    db $24, $e7
    db $81, $42
    db $24, $18
    db $18, $14
    db $f2, $81
    db $81, $f2
    db $14, $18
    db $18, $28
    db $4f, $81
    db $81, $4f
    db $28, $18
    db $ff, $81
    db $81, $81
    db $81, $81
    db $81, $ff
    db $f8, $88
    db $8f, $89
    db $f9, $41
    db $41, $7f
    db $ff, $89
    db $89, $89
    db $f9, $81
    db $81, $ff
    db $01, $03
    db $06, $8c
    db $d8, $70
    db $20, $00
    db $7e, $c3
    db $d3, $d3
    db $db, $c3
    db $c3, $7e
    db $18, $3c
    db $2c, $2c
    db $7e, $18
    db $18, $00
    db $10, $1c
    db $12, $10
    db $10, $70
    db $f0, $60
    db $f0, $c0
    db $fe, $d8
    db $de, $18
    db $18, $00
    db $70, $c8
    db $de, $db
    db $db, $7e
    db $1b, $1b
    db $00, $00
    db $00, $ff
    db $ff, $ff
    db $00, $00
    db $1c, $1c
    db $1c, $1c
    db $1c, $1c
    db $1c, $1c
    db $7c, $c6
    db $c6, $00
    db $c6, $c6
    db $7c, $00
    db $06, $06
    db $06, $00
    db $06, $06
    db $06, $00
    db $7c, $06
    db $06, $7c
    db $c0, $c0
    db $7c, $00
    db $7c, $06
    db $06, $7c
    db $06, $06
    db $7c, $00
    db $c6, $c6
    db $c6, $7c
    db $06, $06
    db $06, $00
    db $7c, $c0
    db $c0, $7c
    db $06, $06
    db $7c, $00
    db $7c, $c0
    db $c0, $7c
    db $c6, $c6
    db $7c, $00
    db $7c, $06
    db $06, $00
    db $06, $06
    db $06, $00
    db $7c, $c6
    db $c6, $7c
    db $c6, $c6
    db $7c, $00
    db $7c, $c6
    db $c6, $7c
    db $06, $06
    db $7c, $00
    db $00, $3c
    db $46, $06
    db $7e, $66
    db $3c, $00
    db $78, $66
    db $7d, $64
    db $7e, $03
    db $0b, $06
    db $00, $00
    db $00, $1f
    db $1f, $1f
    db $1c, $1c
    db $00, $00
    db $00, $fc
    db $fc, $fc
    db $1c, $1c
    db $1c, $1c
    db $1c, $1f
    db $1f, $1f
    db $00, $00
    db $1c, $1c
    db $1c, $fc
    db $fc, $fc
    db $00, $00
    db $00, $00
    db $00, $00
    db $00, $00
    db $00, $00
    db $18, $18
    db $18, $18
    db $18, $00
    db $18, $00
    db $66, $66
    db $44, $00
    db $00, $00
    db $00, $00
    db $00, $24
    db $7e, $24
    db $24, $7e
    db $24, $00
    db $14, $3e
    db $55, $3c
    db $1e, $55
    db $3e, $14
    db $62, $66
    db $0c, $18
    db $30, $66
    db $46, $00
    db $78, $cc
    db $61, $ce
    db $cc, $cc
    db $78, $00
    db $18, $18
    db $10, $00
    db $00, $00
    db $00, $00
    db $04, $08
    db $18, $18
    db $18, $18
    db $08, $04
    db $20, $10
    db $18, $18
    db $18, $18
    db $10, $20
    db $00, $54
    db $38, $fe
    db $38, $54
    db $00, $00
    db $00, $18
    db $18, $7e
    db $18, $18
    db $00, $00
    db $00, $00
    db $00, $00
    db $00, $30
    db $30, $20
    db $00, $00
    db $00, $3c
    db $00, $00
    db $00, $00
    db $00, $00
    db $00, $00
    db $00, $18
    db $18, $00
    db $03, $06
    db $0c, $18
    db $30, $60
    db $c0, $00
    db $3c, $66
    db $6e, $76
    db $66, $66
    db $3c, $00
    db $18, $38
    db $18, $18
    db $18, $18
    db $18, $00
    db $3c, $66
    db $0e, $1c
    db $38, $70
    db $7e, $00
    db $7e, $0c
    db $18, $3c
    db $06, $46
    db $3c, $00
    db $0c, $1c
    db $2c, $4c
    db $7e, $0c
    db $0c, $00
    db $7e, $60
    db $7c, $06
    db $06, $46
    db $3c, $00
    db $1c, $20
    db $60, $7c
    db $66, $66
    db $3c, $00
    db $7e, $06
    db $0e, $1c
    db $18, $18
    db $18, $00
    db $3c, $66
    db $66, $3c
    db $66, $66
    db $3c, $00
    db $3c, $66
    db $66, $3e
    db $06, $0c
    db $38, $00
    db $00, $18
    db $18, $00
    db $00, $18
    db $18, $00
    db $00, $18
    db $18, $00
    db $18, $18
    db $10, $00
    db $06, $0c
    db $18, $30
    db $18, $0c
    db $06, $00
    db $00, $00
    db $3c, $00
    db $00, $3c
    db $00, $00
    db $60, $30
    db $18, $0c
    db $18, $30
    db $60, $00
    db $3c, $46
    db $06, $0c
    db $18, $18
    db $00, $18
    db $3c, $66
    db $6e, $6a
    db $6e, $60
    db $3c, $00
    db $3c, $66
    db $66, $7e
    db $66, $66
    db $66, $00
    db $7c, $66
    db $66, $7c
    db $66, $66
    db $7c, $00
    db $3c, $62
    db $60, $60
    db $60, $62
    db $3c, $00
    db $7c, $66
    db $66, $66
    db $66, $66
    db $7c, $00
    db $7e, $60
    db $60, $7c
    db $60, $60
    db $7e, $00
    db $7e, $60
    db $60, $7c
    db $60, $60
    db $60, $00
    db $3c, $62
    db $60, $6e
    db $66, $66
    db $3e, $00
    db $66, $66
    db $66, $7e
    db $66, $66
    db $66, $00
    db $18, $18
    db $18, $18
    db $18, $18
    db $18, $00
    db $06, $06
    db $06, $06
    db $06, $46
    db $3c, $00
    db $66, $6c
    db $78, $70
    db $78, $6c
    db $66, $00
    db $60, $60
    db $60, $60
    db $60, $60
    db $7c, $00
    db $fc, $d6
    db $d6, $d6
    db $d6, $c6
    db $c6, $00
    db $62, $72
    db $7a, $5e
    db $4e, $46
    db $42, $00
    db $3c, $66
    db $66, $66
    db $66, $66
    db $3c, $00
    db $7c, $66
    db $66, $7c
    db $60, $60
    db $60, $00
    db $3c, $66
    db $66, $66
    db $66, $66
    db $3c, $06
    db $7c, $66
    db $66, $7c
    db $66, $66
    db $66, $00
    db $3c, $62
    db $70, $3c
    db $0e, $46
    db $3c, $00
    db $7e, $18
    db $18, $18
    db $18, $18
    db $18, $00
    db $66, $66
    db $66, $66
    db $66, $66
    db $3c, $00
    db $66, $66
    db $66, $66
    db $66, $64
    db $78, $00
    db $c6, $c6
    db $c6, $d6
    db $d6, $d6
    db $fc, $00
    db $66, $66
    db $66, $3c
    db $66, $66
    db $66, $00
    db $66, $66
    db $66, $3c
    db $18, $18
    db $18, $00
    db $7e, $0e
    db $1c, $38
    db $70, $60
    db $7e, $00
    db $1e, $18
    db $18, $18
    db $18, $18
    db $1e, $00
    db $40, $60
    db $30, $18
    db $0c, $06
    db $02, $00
    db $78, $18
    db $18, $18
    db $18, $18
    db $78, $00
    db $10, $38
    db $6c, $00
    db $00, $00
    db $00, $00
    db $00, $00
    db $00, $00
    db $00, $00
    db $7e, $00
    db $00, $c0
    db $c0, $60
    db $00, $00
    db $00, $00
    db $00, $3c
    db $46, $3e
    db $66, $66
    db $3e, $00
    db $60, $7c
    db $66, $66
    db $66, $66
    db $7c, $00
    db $00, $3c
    db $62, $60
    db $60, $62
    db $3c, $00
    db $06, $3e
    db $66, $66
    db $66, $66
    db $3e, $00
    db $00, $3c
    db $66, $7e
    db $60, $62
    db $3c, $00
    db $1e, $30
    db $7c, $30
    db $30, $30
    db $30, $00
    db $00, $3e
    db $66, $66
    db $66, $3e
    db $46, $3c
    db $60, $7c
    db $66, $66
    db $66, $66
    db $66, $00
    db $18, $00
    db $18, $18
    db $18, $18
    db $18, $00
    db $00, $08
    db $18, $18
    db $18, $18
    db $58, $30
    db $60, $64
    db $68, $70
    db $78, $6c
    db $66, $00
    db $18, $18
    db $18, $18
    db $18, $18
    db $0c, $00
    db $00, $fc
    db $d6, $d6
    db $d6, $d6
    db $c6, $00
    db $00, $7c
    db $66, $66
    db $66, $66
    db $66, $00
    db $00, $3c
    db $66, $66
    db $66, $66
    db $3c, $00
    db $00, $7c
    db $66, $66
    db $66, $7c
    db $60, $60
    db $00, $3e
    db $66, $66
    db $66, $66
    db $3e, $06
    db $00, $6c
    db $70, $60
    db $60, $60
    db $60, $00
    db $00, $3c
    db $72, $38
    db $1c, $4e
    db $3c, $00
    db $18, $3c
    db $18, $18
    db $18, $18
    db $0c, $00
    db $00, $66
    db $66, $66
    db $66, $66
    db $3e, $00
    db $00, $66
    db $66, $66
    db $66, $64
    db $78, $00
    db $00, $c6
    db $c6, $d6
    db $d6, $d6
    db $fc, $00
    db $00, $66
    db $66, $3c
    db $66, $66
    db $66, $00
    db $00, $66
    db $66, $66
    db $26, $1e
    db $46, $3c
    db $00, $7e
    db $0e, $1c
    db $38, $70
    db $7e, $00
    db $0e, $18
    db $18, $30
    db $18, $18
    db $0e, $00
    db $18, $18
    db $18, $18
    db $18, $18
    db $18, $18
    db $70, $18
    db $18, $0c
    db $18, $18
    db $70, $00
    db $00, $60
    db $f2, $9e
    db $0c, $00
    db $00, $00
    db $10, $10
    db $28, $28
    db $44, $44
    db $82, $fe
    db $3c, $62
    db $60, $60
    db $60, $62
    db $1c, $30
    db $24, $00
    db $66, $66
    db $66, $66
    db $3e, $00
    db $0c, $18
    db $00, $3c
    db $7e, $60
    db $3c, $00
    db $18, $66
    db $00, $3c
    db $06, $7e
    db $3e, $00
    db $24, $00
    db $3c, $46
    db $3e, $46
    db $3e, $00
    db $30, $18
    db $00, $3c
    db $06, $7e
    db $3e, $00
    db $18, $18
    db $00, $3c
    db $06, $7e
    db $3e, $00
    db $00, $3c
    db $62, $60
    db $62, $3c
    db $08, $18
    db $18, $34
    db $00, $3c
    db $7e, $60
    db $3e, $00
    db $24, $00
    db $3c, $66
    db $7e, $60
    db $3e, $00
    db $30, $18
    db $00, $3c
    db $7e, $60
    db $3c, $00
    db $24, $00
    db $18, $18
    db $18, $18
    db $18, $00
    db $18, $24
    db $00, $18
    db $18, $18
    db $18, $00
    db $10, $08
    db $00, $18
    db $18, $18
    db $18, $00
    db $24, $00
    db $3c, $66
    db $7e, $66
    db $66, $00
    db $18, $00
    db $3c, $66
    db $7e, $66
    db $66, $00
    db $0c, $18
    db $7e, $60
    db $7c, $60
    db $7e, $00
    db $00, $00
    db $7e, $1b
    db $7f, $d8
    db $7e, $00
    db $3f, $78
    db $d8, $de
    db $f8, $d8
    db $df, $00
    db $18, $34
    db $00, $3c
    db $66, $66
    db $3c, $00
    db $24, $00
    db $3c, $66
    db $66, $66
    db $3c, $00
    db $30, $18
    db $00, $3c
    db $66, $66
    db $3c, $00
    db $18, $24
    db $00, $66
    db $66, $66
    db $3c, $00
    db $30, $18
    db $00, $66
    db $66, $66
    db $3c, $00
    db $66, $00
    db $66, $66
    db $66, $3e
    db $46, $3c
    db $66, $00
    db $3c, $66
    db $66, $66
    db $3c, $00
    db $66, $00
    db $66, $66
    db $66, $66
    db $3c, $00
    db $18, $3c
    db $62, $60
    db $60, $62
    db $3c, $18
    db $1c, $3a
    db $30, $7c
    db $30, $30
    db $7e, $00
    db $66, $66
    db $3c, $18
    db $3c, $18
    db $18, $00
    db $3c, $66
    db $66, $6c
    db $66, $66
    db $ec, $00
    db $18, $18
    db $18, $18
    db $18, $18
    db $18, $18
    db $0c, $18
    db $00, $3c
    db $06, $7e
    db $3e, $00
    db $0c, $18
    db $00, $18
    db $18, $18
    db $18, $00
    db $0c, $18
    db $00, $3c
    db $66, $66
    db $3c, $00
    db $0c, $18
    db $00, $66
    db $66, $66
    db $3e, $00
    db $34, $58
    db $00, $7c
    db $66, $66
    db $66, $00
    db $1a, $2c
    db $62, $72
    db $5a, $4e
    db $46, $00
    db $00, $3c
    db $46, $3e
    db $66, $3e
    db $00, $7e
    db $00, $3c
    db $66, $66
    db $66, $3c
    db $00, $7e
    db $00, $18
    db $00, $18
    db $30, $60
    db $66, $3c
    db $00, $00
    db $00, $3e
    db $30, $30
    db $30, $00
    db $00, $00
    db $00, $7c
    db $0c, $0c
    db $0c, $00
    db $62, $e4
    db $68, $76
    db $2b, $43
    db $86, $0f
    db $62, $e4
    db $68, $76
    db $2e, $56
    db $9f, $06
    db $00, $18
    db $00, $18
    db $18, $18
    db $18, $18
    db $1b, $36
    db $6c, $d8
    db $6c, $36
    db $1b, $00
    db $d8, $6c
    db $36, $1b
    db $36, $6c
    db $d8, $00
    db $34, $58
    db $00, $3c
    db $06, $7e
    db $3e, $00
    db $34, $58
    db $00, $3c
    db $66, $66
    db $3c, $00
    db $02, $3c
    db $66, $6e
    db $76, $66
    db $3c, $40
    db $00, $02
    db $3c, $6e
    db $76, $66
    db $3c, $40
    db $00, $00
    db $7e, $db
    db $de, $d8
    db $7f, $00
    db $00, $7e
    db $d8, $d8
    db $fc, $d8
    db $d8, $de
    db $20, $10
    db $3c, $66
    db $66, $7e
    db $66, $66
    db $34, $58
    db $3c, $66
    db $66, $7e
    db $66, $66
    db $34, $58
    db $3c, $66
    db $66, $66
    db $66, $3c
    db $66, $00
    db $00, $00
    db $00, $00
    db $00, $00
    db $0c, $18
    db $30, $00
    db $00, $00
    db $00, $00
    db $00, $10
    db $38, $10
    db $10, $10
    db $00, $00
    db $7a, $ca
    db $ca, $ca
    db $7a, $0a
    db $0a, $0a
    db $3c, $42
    db $99, $b5
    db $b1, $9d
    db $42, $3c
    db $3c, $42
    db $b9, $b5
    db $b9, $b5
    db $42, $3c
    db $f1, $5b
    db $55, $51
    db $51, $00
    db $00, $00

FolderIconGlyphs::
    db $66, $00
    db $e6, $66
    db $66, $f6
    db $06, $1c
    db $f6, $66
    db $66, $66
    db $66, $f6
    db $06, $1c
    db $00, $66
    db $76, $3c
    db $6e, $66
    db $00, $00
    db $00, $7c
    db $0c, $0c
    db $0c, $7e
    db $00, $00
    db $00, $1e
    db $06, $0e
    db $1e, $36
    db $00, $00
    db $00, $7e
    db $0c, $0c
    db $0c, $0c
    db $00, $00
    db $00, $7c
    db $06, $66
    db $66, $66
    db $00, $00
    db $00, $1c
    db $0c, $0c
    db $0c, $0c
    db $00, $00
    db $00, $1e
    db $0c, $06
    db $06, $06
    db $00, $00
    db $00, $7e
    db $36, $36
    db $36, $36
    db $00, $00
    db $60, $6e
    db $66, $66
    db $66, $7e
    db $00, $00
    db $00, $3c
    db $0c, $0c
    db $00, $00
    db $00, $00
    db $00, $3e
    db $06, $06
    db $06, $3e
    db $00, $00
    db $60, $7e
    db $06, $06
    db $06, $0e
    db $00, $00
    db $00, $6c
    db $3e, $66
    db $66, $6e
    db $00, $00
    db $00, $1c
    db $0c, $0c
    db $0c, $3c
    db $00, $00
    db $00, $3e
    db $36, $36
    db $36, $1c
    db $00, $00
    db $00, $36
    db $36, $36
    db $36, $7e
    db $00, $00
    db $00, $7e
    db $66, $76
    db $06, $7e
    db $00, $00
    db $00, $66
    db $66, $3c
    db $0e, $7e
    db $00, $00
    db $00, $3e
    db $06, $36
    db $36, $34
    db $30, $00
    db $00, $78
    db $0c, $0c
    db $0c, $0c
    db $00, $00
    db $00, $d6
    db $d6, $d6
    db $d6, $fe
    db $00, $00
    db $00, $7c
    db $6c, $6c
    db $6c, $ec
    db $00, $00
    db $00, $1c
    db $0c, $0c
    db $0c, $0c
    db $0c, $00
    db $00, $3e
    db $06, $06
    db $06, $06
    db $06, $00
    db $00, $fe
    db $66, $66
    db $66, $7e
    db $00, $00
    db $00, $7e
    db $66, $76
    db $06, $06
    db $06, $00
    db $00, $36
    db $36, $1c
    db $0c, $0c
    db $0c, $00
    db $1c, $32
    db $3c, $66
    db $66, $3c
    db $4c, $38
    db $00, $10
    db $38, $6c
    db $c6, $82
    db $00, $00
    db $66, $f7
    db $99, $99
    db $ef, $66
    db $00, $00
    db $00, $00
    db $76, $dc
    db $c8, $dc
    db $76, $00
    db $1c, $36
    db $66, $7c
    db $66, $66
    db $7c, $60
    db $00, $fe
    db $66, $62
    db $60, $60
    db $60, $f8
    db $00, $00
    db $fe, $6c
    db $6c, $6c
    db $6c, $48
    db $fe, $66
    db $30, $18
    db $30, $66
    db $fe, $00
    db $00, $1e
    db $38, $6c
    db $6c, $6c
    db $38, $00
    db $00, $00
    db $6c, $6c
    db $6c, $6c
    db $7f, $c0
    db $00, $00
    db $7e, $18
    db $18, $18
    db $18, $10
    db $3c, $18
    db $3c, $66
    db $66, $3c
    db $18, $3c
    db $00, $3c
    db $66, $7e
    db $66, $66
    db $3c, $00
    db $00, $3c
    db $66, $66
    db $66, $24
    db $66, $00
    db $1c, $36
    db $78, $dc
    db $cc, $ec
    db $78, $00
    db $0c, $18
    db $38, $54
    db $54, $38
    db $30, $60
    db $00, $10
    db $7c, $d6
    db $d6, $d6
    db $7c, $10
    db $3e, $70
    db $60, $7e
    db $60, $70
    db $3e, $00
    db $3c, $66
    db $66, $66
    db $66, $66
    db $66, $00
    db $00, $7e
    db $00, $7e
    db $00, $7e
    db $00, $00
    db $18, $18
    db $7e, $18
    db $18, $00
    db $7e, $00
    db $30, $18
    db $0c, $18
    db $30, $00
    db $7e, $00
    db $0c, $18
    db $30, $18
    db $0c, $00
    db $7e, $00
    db $00, $0e
    db $1b, $1b
    db $18, $18
    db $18, $18
    db $18, $18
    db $18, $18
    db $d8, $d8
    db $70, $00
    db $18, $18
    db $00, $7e
    db $00, $18
    db $18, $00
    db $00, $32
    db $4c, $00
    db $32, $4c
    db $00, $00
    db $38, $6c
    db $38, $00
    db $00, $00
    db $00, $00
    db $38, $7c
    db $38, $00
    db $00, $00
    db $00, $00
    db $00, $00
    db $00, $00
    db $18, $18
    db $00, $00
    db $00, $00
    db $0f, $18
    db $d8, $70
    db $30, $00
    db $38, $6c
    db $6c, $6c
    db $6c, $00
    db $00, $00
    db $38, $6c
    db $18, $30
    db $7c, $00
    db $00, $00
    db $78, $0c
    db $38, $0c
    db $78, $00
    db $00, $00
    db $00, $fe
    db $00, $00
    db $00, $00
    db $00, $00
    db $f5, $c5
    db $06, $ff
    db $cd, $16
    db $3a, $b7
    db $20, $f8
    db $05, $20
    db $f7, $c1
    db $f1, $c9

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
    jr c, CopyTilesVram_checkE

    sub $10
    ld h, a

CopyTilesVram_checkE::
    xor a
    cp e
    jr nz, CopyTilesVram_waitStatLo

    dec d

CopyTilesVram_waitStatLo::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, CopyTilesVram_waitStatLo

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
    jr nz, CopyTilesVram_decCount

    inc h
    ld a, h
    cp $98
    jr nz, CopyTilesVram_decCount

    ld h, $88

CopyTilesVram_decCount::
    dec e
    jr nz, CopyTilesVram_waitStatLo

    dec d
    bit 7, d
    jr z, CopyTilesVram_waitStatLo

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
    ld a, [wDrawColorB]
    bit 0, a
    jr z, CopyTilesColor_afterColorB0

    ld b, $ff

CopyTilesColor_afterColorB0::
    bit 1, a
    jr z, CopyTilesColor_xorMask

    ld c, $ff

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

CopyTilesColor_afterBit0::
    bit 1, d
    jr z, CopyTilesColor_statWaitB

    ld a, e
    xor c
    ld c, a

CopyTilesColor_statWaitB::
    ldh a, [rSTAT]
    bit 1, a
    jr nz, CopyTilesColor_statWaitB

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
    jr nz, CopyTilesColor_decCount

    ld h, $88

CopyTilesColor_decCount::
    pop bc
    pop de
    dec de
    ld a, d
    or e
    jr nz, CopyTilesColor_loop

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

RegisterFont_lcdOn::
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
    jr nz, PrintChar_putChar

    push af
    ld a, [wGfxMode]
    and $08
    jr nz, PrintChar_skipNewline

    call TileNewline
    pop af
    ret


PrintChar_skipNewline::
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


; [ezgb]
; PutBgTile(A): map char through font at wFontPtr → tile id at BG $9800+y*32+x (wTileCursorY/X). STAT-safe.
; If wFontFarFlag==0: ResetTileText + FarCallTrampoline; jr_000_3c01 nop fallthrough.
; jr_000_3c02: if font hdr&3!=2 index glyph table else keep A; jr_000_3c19 +wFontBaseTile; map ptr; jr_000_3c34 STAT-wait store E.

PutBgTile::
    push af
    ld a, [wFontFarFlag]
    or a
    jr nz, PutBgTile_mapGlyph

    call ResetTileText
    xor a
    ld [wFontNextTile], a
    call FarCallTrampoline
    db $fd
    jr nc, PutBgTile_afterFarCall

PutBgTile_afterFarCall::
    nop

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
; ClearBgMap: fill BG map $9800 with tile 0 (32×32), STAT-safe.
; jr_000_3c85: 32 rows; jr_000_3c87: STAT-wait write 0, 32 cols/row. Orphan before RetreatTileCursor.

ClearBgMap::
    push de
    push hl
    ld hl, $9800
    ld e, $20

ClearBgMap_rowSetup::
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
    jr nz, ClearBgMap_rowSetup

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
    jr z, RetreatTileCursor_wrapX

    dec [hl]
    jr RetreatTileCursor_epilogueRet

RetreatTileCursor_wrapX::
    ld [hl], $13
    ld hl, wTileCursorY
    xor a
    cp [hl]
    jr z, RetreatTileCursor_epilogueRet

    dec [hl]

RetreatTileCursor_epilogueRet::
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
    jr z, TileNewline_scrollBg

    inc [hl]
    jr TileNewline_epilogueRet

TileNewline_scrollBg::
    call ScrollBgUp

TileNewline_epilogueRet::
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
    jr z, AdvanceTileCursor_wrapX

    inc [hl]
    jr AdvanceTileCursor_epilogueRet

AdvanceTileCursor_wrapX::
    ld [hl], $00
    ld hl, wTileCursorY
    ld a, $11
    cp [hl]
    jr z, AdvanceTileCursor_checkGfxMode

    inc [hl]
    jr AdvanceTileCursor_epilogueRet

AdvanceTileCursor_checkGfxMode::
    ld a, [wGfxMode]
    and $04
    jr z, AdvanceTileCursor_scrollBg

    xor a
    ld [wTileCursorY], a
    ld [wTileCursorX], a
    jr AdvanceTileCursor_epilogueRet

AdvanceTileCursor_scrollBg::
    call ScrollBgUp

AdvanceTileCursor_epilogueRet::
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

ScrollBgUp_rowSetup::
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
    jr nz, ScrollBgUp_rowSetup

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


; [ezgb]
; EnterGfxMode2: tear down mode-1 VBlank/LCD callbacks if LCD on, InitGfxMode2
; (clear cursors + BG, wGfxMode=2), restore LCDC. Tilemap text mode.
; jr_000_3d3d: if LCD already off skip LcdOff+RemoveCallbackSlot; then InitGfxMode2, LCDC|=$81 &=$E7, ei.

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
    jr nz, VramFillActiveWinMap_map9C00

    ld hl, $9800
    jr VramFillActiveBgMap_doFill

VramFillActiveWinMap_map9C00::
    ld hl, $9c00
    jr VramFillActiveBgMap_doFill

; [ezgb]
; VramFillActiveBgMap: pick BG tilemap base from LCDC bit3 ($9800/$9C00), then
; VramFill $0400 bytes with B. Shares tail at $3d86 with VramFillActiveWinMap.
; jr_000_3d83: bit3 set → HL=$9C00; else $9800; jr_000_3d86: DE=$0400 jp VramFill.

VramFillActiveBgMap::
    ldh a, [rLCDC]
    bit 3, a
    jr nz, VramFillActiveBgMap_use9c00

    ld hl, $9800
    jr VramFillActiveBgMap_doFill

VramFillActiveBgMap_use9c00::
    ld hl, $9c00

VramFillActiveBgMap_doFill::
    ld de, FarCallScan
    jp VramFill


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
