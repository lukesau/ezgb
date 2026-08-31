; Disassembly of "kernel.gb"
; This file was created with:
; mgbdis v3.0 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $008", ROMX[$4000], BANK[$8]

PlotIconGlyphs::
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

PlotIconGlyphs_loopHead::
    ld hl, sp+$0a
    ld a, [hl]
    sub $0c
    jp nc, PlotIconGlyphs_epilogueRet

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
    ld hl, Bank8ReservedSpace2
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    and $01
    jr nz, PlotIconGlyphs_bit0

    jp PlotIconGlyphs_bit1Check


PlotIconGlyphs_bit0::
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
    call PlotPixelXY
    add sp, $02
    pop bc

PlotIconGlyphs_bit1Check::
    ld a, c
    and $02
    jr nz, PlotIconGlyphs_bit1

    jp PlotIconGlyphs_bit2Check


PlotIconGlyphs_bit1::
    push bc
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
    pop bc

PlotIconGlyphs_bit2Check::
    ld a, c
    and $04
    jr nz, PlotIconGlyphs_bit2

    jp PlotIconGlyphs_bit3Check


PlotIconGlyphs_bit2::
    push bc
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, sp+$0a
    ld a, [hl]
    push af
    inc sp
    call PlotPixelXY
    add sp, $02
    pop bc

PlotIconGlyphs_bit3Check::
    ld a, c
    and $08
    jr nz, PlotIconGlyphs_bit3

    jp PlotIconGlyphs_bit4Check


PlotIconGlyphs_bit3::
    push bc
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, sp+$09
    ld a, [hl]
    push af
    inc sp
    call PlotPixelXY
    add sp, $02
    pop bc

PlotIconGlyphs_bit4Check::
    ld a, c
    and $10
    jr nz, PlotIconGlyphs_bit4

    jp PlotIconGlyphs_bit5Check


PlotIconGlyphs_bit4::
    push bc
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, sp+$08
    ld a, [hl]
    push af
    inc sp
    call PlotPixelXY
    add sp, $02
    pop bc

PlotIconGlyphs_bit5Check::
    ld a, c
    and $20
    jr nz, PlotIconGlyphs_bit5

    jp PlotIconGlyphs_bit6Check


PlotIconGlyphs_bit5::
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
    call PlotPixelXY
    add sp, $02
    pop bc

PlotIconGlyphs_bit6Check::
    ld a, c
    and $40
    jr nz, PlotIconGlyphs_bit6

    jp PlotIconGlyphs_bit7Check


PlotIconGlyphs_bit6::
    push bc
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    inc hl
    ld a, [hl]
    push af
    inc sp
    call PlotPixelXY
    add sp, $02
    pop bc

PlotIconGlyphs_bit7Check::
    ld a, c
    and $80
    jr nz, PlotIconGlyphs_bit7

    jp PlotIconGlyphs_next


PlotIconGlyphs_bit7::
    ld hl, sp+$02
    ld a, [hl]
    push af
    inc sp
    ld hl, sp+$13
    ld a, [hl]
    push af
    inc sp
    call PlotPixelXY
    add sp, $02

PlotIconGlyphs_next::
    ld hl, sp+$02
    inc [hl]
    ld hl, sp+$0a
    inc [hl]
    jp PlotIconGlyphs_loopHead


PlotIconGlyphs_epilogueRet::
    add sp, $0b
    ret


Bank8ReservedSpace2::
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $20, $20
    db $20, $20, $20, $20, $00, $20, $00, $00
    db $00, $28, $50, $50, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $28, $28
    db $fc, $28, $50, $fc, $50, $50, $00, $00
    db $00, $20, $78, $a8, $a0, $60, $30, $28
    db $a8, $f0, $20, $00, $00, $00, $48, $a8
    db $b0, $50, $28, $34, $54, $48, $00, $00
    db $00, $00, $20, $50, $50, $78, $a8, $a8
    db $90, $6c, $00, $00, $00, $40, $40, $80
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $04, $08, $10, $10, $10, $10, $10
    db $10, $08, $04, $00, $00, $40, $20, $10
    db $10, $10, $10, $10, $10, $20, $40, $00
    db $00, $00, $00, $20, $a8, $70, $70, $a8
    db $20, $00, $00, $00, $00, $00, $20, $20
    db $20, $f8, $20, $20, $20, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $40, $40, $80, $00, $00, $00, $00
    db $00, $f8, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $40, $00, $00, $00, $08, $10, $10
    db $10, $20, $20, $40, $40, $40, $80, $00
    db $00, $00, $70, $88, $88, $88, $88, $88
    db $88, $70, $00, $00, $00, $00, $20, $60
    db $20, $20, $20, $20, $20, $70, $00, $00
    db $00, $00, $70, $88, $88, $10, $20, $40
    db $80, $f8, $00, $00, $00, $00, $70, $88
    db $08, $30, $08, $08, $88, $70, $00, $00
    db $00, $00, $10, $30, $50, $50, $90, $78
    db $10, $18, $00, $00, $00, $00, $f8, $80
    db $80, $f0, $08, $08, $88, $70, $00, $00
    db $00, $00, $70, $90, $80, $f0, $88, $88
    db $88, $70, $00, $00, $00, $00, $f8, $90
    db $10, $20, $20, $20, $20, $20, $00, $00
    db $00, $00, $70, $88, $88, $70, $88, $88
    db $88, $70, $00, $00, $00, $00, $70, $88
    db $88, $88, $78, $08, $48, $70, $00, $00
    db $00, $00, $00, $00, $20, $00, $00, $00
    db $00, $20, $00, $00, $00, $00, $00, $00
    db $00, $20, $00, $00, $00, $20, $20, $00
    db $00, $04, $08, $10, $20, $40, $20, $10
    db $08, $04, $00, $00, $00, $00, $00, $00
    db $f8, $00, $00, $f8, $00, $00, $00, $00
    db $00, $40, $20, $10, $08, $04, $08, $10
    db $20, $40, $00, $00, $00, $00, $70, $88
    db $88, $10, $20, $20, $00, $20, $00, $00
    db $00, $00, $70, $88, $98, $a8, $a8, $b8
    db $80, $78, $00, $00, $00, $00, $20, $20
    db $30, $50, $50, $78, $48, $cc, $00, $00
    db $00, $00, $f0, $48, $48, $70, $48, $48
    db $48, $f0, $00, $00, $00, $00, $78, $88
    db $80, $80, $80, $80, $88, $70, $00, $00
    db $00, $00, $f0, $48, $48, $48, $48, $48
    db $48, $f0, $00, $00, $00, $00, $f8, $48
    db $50, $70, $50, $40, $48, $f8, $00, $00
    db $00, $00, $f8, $48, $50, $70, $50, $40
    db $40, $e0, $00, $00, $00, $00, $38, $48
    db $80, $80, $9c, $88, $48, $30, $00, $00
    db $00, $00, $cc, $48, $48, $78, $48, $48
    db $48, $cc, $00, $00, $00, $00, $f8, $20
    db $20, $20, $20, $20, $20, $f8, $00, $00
    db $00, $00, $7c, $10, $10, $10, $10, $10
    db $10, $90, $e0, $00, $00, $00, $ec, $48
    db $50, $60, $50, $50, $48, $ec, $00, $00
    db $00, $00, $e0, $40, $40, $40, $40, $40
    db $44, $fc, $00, $00, $00, $00, $d8, $d8
    db $d8, $d8, $a8, $a8, $a8, $a8, $00, $00
    db $00, $00, $dc, $48, $68, $68, $58, $58
    db $48, $e8, $00, $00, $00, $00, $70, $88
    db $88, $88, $88, $88, $88, $70, $00, $00
    db $00, $00, $f0, $48, $48, $70, $40, $40
    db $40, $e0, $00, $00, $00, $00, $70, $88
    db $88, $88, $88, $e8, $98, $70, $18, $00
    db $00, $00, $f0, $48, $48, $70, $50, $48
    db $48, $ec, $00, $00, $00, $00, $78, $88
    db $80, $60, $10, $08, $88, $f0, $00, $00
    db $00, $00, $f8, $a8, $20, $20, $20, $20
    db $20, $70, $00, $00, $00, $00, $cc, $48
    db $48, $48, $48, $48, $48, $30, $00, $00
    db $00, $00, $cc, $48, $48, $50, $50, $30
    db $20, $20, $00, $00, $00, $00, $a8, $a8
    db $a8, $70, $50, $50, $50, $50, $00, $00
    db $00, $00, $d8, $50, $50, $20, $20, $50
    db $50, $d8, $00, $00, $00, $00, $d8, $50
    db $50, $20, $20, $20, $20, $70, $00, $00
    db $00, $00, $f8, $90, $10, $20, $20, $40
    db $48, $f8, $00, $00, $00, $38, $20, $20
    db $20, $20, $20, $20, $20, $20, $38, $00
    db $00, $40, $40, $40, $20, $20, $10, $10
    db $10, $08, $00, $00, $00, $70, $10, $10
    db $10, $10, $10, $10, $10, $10, $70, $00
    db $00, $20, $50, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $fc
    db $00, $20, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $30, $48, $38, $48, $3c, $00, $00
    db $00, $00, $c0, $40, $40, $70, $48, $48
    db $48, $70, $00, $00, $00, $00, $00, $00
    db $00, $38, $48, $40, $40, $38, $00, $00
    db $00, $00, $18, $08, $08, $38, $48, $48
    db $48, $3c, $00, $00, $00, $00, $00, $00
    db $00, $30, $48, $78, $40, $38, $00, $00
    db $00, $00, $1c, $20, $20, $78, $20, $20
    db $20, $78, $00, $00, $00, $00, $00, $00
    db $00, $3c, $48, $30, $40, $78, $44, $38
    db $00, $00, $c0, $40, $40, $70, $48, $48
    db $48, $ec, $00, $00, $00, $00, $20, $00
    db $00, $60, $20, $20, $20, $70, $00, $00
    db $00, $00, $10, $00, $00, $30, $10, $10
    db $10, $10, $10, $e0, $00, $00, $c0, $40
    db $40, $5c, $50, $70, $48, $ec, $00, $00
    db $00, $00, $e0, $20, $20, $20, $20, $20
    db $20, $f8, $00, $00, $00, $00, $00, $00
    db $00, $f0, $a8, $a8, $a8, $a8, $00, $00
    db $00, $00, $00, $00, $00, $f0, $48, $48
    db $48, $ec, $00, $00, $00, $00, $00, $00
    db $00, $30, $48, $48, $48, $30, $00, $00
    db $00, $00, $00, $00, $00, $f0, $48, $48
    db $48, $70, $40, $e0, $00, $00, $00, $00
    db $00, $38, $48, $48, $48, $38, $08, $1c
    db $00, $00, $00, $00, $00, $d8, $60, $40
    db $40, $e0, $00, $00, $00, $00, $00, $00
    db $00, $78, $40, $30, $08, $78, $00, $00
    db $00, $00, $00, $20, $20, $70, $20, $20
    db $20, $18, $00, $00, $00, $00, $00, $00
    db $00, $d8, $48, $48, $48, $3c, $00, $00
    db $00, $00, $00, $00, $00, $ec, $48, $50
    db $30, $20, $00, $00, $00, $00, $00, $00
    db $00, $a8, $a8, $70, $50, $50, $00, $00
    db $00, $00, $00, $00, $00, $d8, $50, $20
    db $50, $d8, $00, $00, $00, $00, $00, $00
    db $00, $ec, $48, $50, $30, $20, $20, $c0
    db $00, $00, $00, $00, $00, $78, $10, $20
    db $20, $78, $00, $00, $00, $18, $10, $10
    db $10, $20, $10, $10, $10, $10, $18, $00
    db $10, $10, $10, $10, $10, $10, $10, $10
    db $10, $10, $10, $10, $00, $60, $20, $20
    db $20, $10, $20, $20, $20, $20, $60, $00
    db $40, $a4, $18, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00

; [ezgb]
; Fpga7FD2WaitClear_B8: $7FD2=$01, poll [$A000] until 0, then $7FD2=$00.
; Entry is $473f (after nop pad at $473e).
; Unlock e1/e2/e3 + $7FF0=$e4; Jump_008_475e: spin while [$A000]≠0; clear $7FD2 + commit; E=0 ret.

Fpga7FD2WaitClear_B8::
    dec sp
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

Fpga7FD2WaitClear_B8_pollA000::
    ld bc, $a000
    ld a, [bc]
    ld c, a
    ld hl, sp+$00
    ld [hl], c
    xor a
    or [hl]
    jp nz, Fpga7FD2WaitClear_B8_pollA000

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
    ld e, [hl]
    add sp, $01
    ret


    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    nop
    nop
    nop
    nop
    nop
    nop
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    nop
    nop
    nop
    nop
    nop
    nop
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    nop
    nop
    nop
    nop
    nop
    nop
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38

Bank8ReservedSpace::
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $00
    db $00, $00, $00, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
    db $7f, $0c, $48, $02, $00

; [ezgb]
; RomLoad_Build_B8(dst@sp+$06, src@sp+$08, n@sp+$0a): memcpy n bytes src→dst. Twin of RomLoad_Build_B4.
; Jump_008_6df0: while n--: *src++ (jr_008_6e03 carry) → *dst++ (jr_008_6e0f carry); Jump_008_6e12 add sp,$04 ret.
; Used by RomLoad_BuildAndRunPeek_B8 / 7FD2Wait to plant $D000 trampolines.

RomLoad_Build_B8::
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

RomLoad_Build_B8_decN::
    ld b, c
    dec c
    xor a
    or b
    jp z, RomLoad_Build_B8_epilogueRet

    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    dec hl
    inc [hl]
    jr nz, RomLoad_Build_B8_incSrc

    inc hl
    inc [hl]

RomLoad_Build_B8_incSrc::
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, RomLoad_Build_B8_storeCont

    inc hl
    inc [hl]

RomLoad_Build_B8_storeCont::
    jp RomLoad_Build_B8_decN


RomLoad_Build_B8_epilogueRet::
    add sp, $04
    ret


; [ezgb]
; SdWindowPeek_B8: ld a,[$a000] → E. Bank-8 sibling of SdWindowPeek; used after
; FPGA page switches (ready poll). Was briefly mislabeled SetFpga7FD2_B8.

SdWindowPeek_B8::
    ld bc, $a000
    ld a, [bc]
    ld c, a
    ld e, c
    ret


; [ezgb]
; SetFpga7FD2On_B8: unlock $7F00/10/20, write $01 to $7FD2, commit $7FF0.

SetFpga7FD2On_B8::
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


; [ezgb]
; SetFpga7FD2Off_B8: unlock $7F00/10/20, write $00 to $7FD2, commit $7FF0.

SetFpga7FD2Off_B8::
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


; [ezgb]
; SetRomLoadCtrl_B8: bank-8 copy of SetRomLoadCtrl_B4 — unlock, $7F36=stack u8,
; commit. SetFpgaPage_B8 ($6e7a) is the $7FC0 sibling beside it.

SetRomLoadCtrl_B8::
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


; [ezgb]
; SetFpgaPage_B8: bank-8 copy of SetFpgaPage (unlock, $7FC0=page, commit).

SetFpgaPage_B8::
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


; [ezgb]
; RomLoad_WriteCmdWindow_B8(buf): page=$02, $7F36=$01, copy $0200 bytes
; from buf to $A000 (load cmd window), then ctrl/page off.

RomLoad_WriteCmdWindow_B8::
    ld a, $02
    push af
    inc sp
    call SetFpgaPage_B8
    add sp, $01
    ld a, $01
    push af
    inc sp
    call SetRomLoadCtrl_B8
    add sp, $01
    ld hl, $0200
    push hl
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $a000
    push hl
    call VramCopyStack
    add sp, $06
    ld a, $00
    push af
    inc sp
    call SetRomLoadCtrl_B8
    add sp, $01
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B8
    add sp, $01
    ret


; [ezgb]
; RomLoad_BuildAndRunPeek_B8: build SdWindowPeek_B8 trampoline at $D000
; (arg $ff) via RomLoad_Build_B8, then call $D000.

RomLoad_BuildAndRunPeek_B8::
    ld bc, SdWindowPeek_B8
    ld a, $ff
    push af
    inc sp
    push bc
    ld hl, $d000
    push hl
    call RomLoad_Build_B8
    add sp, $05
    call $d000
    ret


; [ezgb]
; RomLoad_BuildAndRun7FD2Wait_B8: build Fpga7FD2WaitClear_B8 trampoline at
; $D000 (arg $ff), then call it. Caller wraps with DiNest/EiNest.

RomLoad_BuildAndRun7FD2Wait_B8::
    ld bc, Fpga7FD2WaitClear_B8
    ld a, $ff
    push af
    inc sp
    push bc
    ld hl, $d000
    push hl
    call RomLoad_Build_B8
    add sp, $05
    call $d000
    ret


; [ezgb]
; RomLoad_ClearCartWindow_B8: SetFpga7FD2Off; then clear cart cmd window before DrawFwVersionScreen.
; Jump_008_6f0a: fill $C0A0..+$200 with idx.lo (jr_008_6f3a); Jump_008_6f3d reset counter.
; Jump_008_6f44: 0x2000× pack addr=$40000+i → $C0A0, RomLoad_WriteCmdWindow, page $05 BuildAndRun wait, page0.
; Jump_008_6fcd: ret. Orphan before DrawFwVersionScreen.

RomLoad_ClearCartWindow_B8::
    push af
    push af
    push af
    push af
    call SetFpga7FD2Off_B8
    xor a
    ld hl, sp+$04
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

RomLoad_ClearCartWindow_B8_fillBuf::
    ld hl, sp+$04
    ld a, [hl]
    sub $00
    inc hl
    ld a, [hl]
    sbc $02
    inc hl
    ld a, [hl]
    sbc $00
    inc hl
    ld a, [hl]
    sbc $00
    rlca
    jp nc, RomLoad_ClearCartWindow_B8_resetCounter

    ld a, $a0
    ld hl, sp+$04
    add [hl]
    ld c, a
    ld a, $c0
    inc hl
    adc [hl]
    ld b, a
    dec hl
    ld a, [hl]
    ld [bc], a
    inc [hl]
    jr nz, RomLoad_ClearCartWindow_B8_fillCont

    inc hl
    inc [hl]
    jr nz, RomLoad_ClearCartWindow_B8_fillCont

    inc hl
    inc [hl]
    jr nz, RomLoad_ClearCartWindow_B8_fillCont

    inc hl
    inc [hl]

RomLoad_ClearCartWindow_B8_fillCont::
    jp RomLoad_ClearCartWindow_B8_fillBuf


RomLoad_ClearCartWindow_B8_resetCounter::
    xor a
    ld hl, sp+$04
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

RomLoad_ClearCartWindow_B8_cmdLoop::
    ld hl, sp+$04
    ld a, [hl]
    sub $00
    inc hl
    ld a, [hl]
    sbc $20
    inc hl
    ld a, [hl]
    sbc $00
    inc hl
    ld a, [hl]
    sbc $00
    rlca
    jp nc, RomLoad_ClearCartWindow_B8_epilogueRet

    ld hl, sp+$04
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
    ld hl, sp+$08
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
    ld hl, $c0a0
    push hl
    call RomLoad_WriteCmdWindow_B8
    add sp, $02
    ld a, $05
    push af
    inc sp
    call SetFpgaPage_B8
    add sp, $01
    call DiNest
    call RomLoad_BuildAndRun7FD2Wait_B8
    call EiNest
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B8
    add sp, $01
    ld hl, sp+$04
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
    jp RomLoad_ClearCartWindow_B8_cmdLoop


RomLoad_ClearCartWindow_B8_epilogueRet::
    add sp, $08
    ret


; [ezgb]
; DrawFwVersionScreen: -$34 frame; "FW…" + SdWindowPeek_B8 page $04; U32ToAscii_B0 radix $0a.
; Jump_008_70e1: DrawRect/DrawString chrome; Jump_008_7141 WaitVBlank+ReadJoypad until SELECT ($40); jr_008_7152 add sp,$34 ret.
; Post-ret orphans (no new ::): tab chrome by sp+$06. Jump_008_7203/Jump_008_720d/jr_008_7210 tab0; Jump_008_727e/Jump_008_7288/jr_008_728b tab1;
; Jump_008_72f9/Jump_008_7303/jr_008_7306 tab2/3; Jump_008_7331 ret. Before MenuTabSdStr.

DrawFwVersionScreen::
    add sp, -$34
    ld hl, sp+$0c
    ld a, l
    ld d, h
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $46
    ld [de], a
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, $57
    ld [bc], a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $78
    ld [de], a
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0003
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $20
    ld [de], a
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld c, l
    ld b, h
    ld a, $20
    ld [bc], a
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0005
    add hl, de
    ld c, l
    ld b, h
    ld a, $4b
    ld [bc], a
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld c, l
    ld b, h
    ld a, $31
    ld [bc], a
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0007
    add hl, de
    ld c, l
    ld b, h
    ld a, $2e
    ld [bc], a
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0008
    add hl, de
    ld c, l
    ld b, h
    ld a, $30
    ld [bc], a
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0009
    add hl, de
    ld c, l
    ld b, h
    ld a, $35
    ld [bc], a
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000a
    add hl, de
    ld c, l
    ld b, h
    ld a, $65
    ld [bc], a
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000b
    add hl, de
    ld c, l
    ld b, h
    ld a, $00
    ld [bc], a
    ld a, $04
    push af
    inc sp
    call SetFpgaPage_B8
    add sp, $01
    call SdWindowPeek_B8
    ld c, e
    push bc
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B8
    add sp, $01
    pop bc
    ld hl, sp+$20
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
    call U32ToAscii_B0
    add sp, $07
    ld hl, sp+$20
    ld c, l
    ld b, h
    ld a, [bc]
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    inc bc
    ld a, [bc]
    ld c, a
    or a
    jp z, DrawFwVersionScreen_drawChrome

    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a

DrawFwVersionScreen_drawChrome::
    ld hl, $0000
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0107
    push hl
    ld hl, $9f00
    push hl
    ld a, $78
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0305
    push hl
    ld a, $0b
    push af
    inc sp
    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DrawString
    add sp, $05
    ld hl, $0300
    push hl
    ld a, $04
    push af
    inc sp
    ld hl, $7155
    push hl
    call DrawString
    add sp, $05
    ld hl, $0500
    push hl
    ld a, $0e
    push af
    inc sp
    ld hl, $715a
    push hl
    call DrawString
    add sp, $05

DrawFwVersionScreen_waitSelect::
    call WaitVBlankFlag
    call ReadJoypad
    ld c, e
    ld b, $00
    ld a, c
    and $40
    jr nz, DrawFwVersionScreen_epilogueRet

    jp DrawFwVersionScreen_waitSelect


DrawFwVersionScreen_epilogueRet::
    add sp, $34
    ret


    halt
    ld h, l
    ld [hl], d
    ld a, [hl-]
    nop
    ld [hl], a
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
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $099f
    push hl
    ld l, $00
    push hl
    call DrawLineXY
    add sp, $04
    ld hl, $089f
    push hl
    ld l, $00
    push hl
    call DrawLineXY
    add sp, $04
    xor a
    ld hl, sp+$06
    or [hl]
    jp nz, Jump_008_7203

    ld hl, $0000
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $010e
    push hl
    ld hl, $9f00
    push hl
    ld a, $00
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0000
    push hl
    ld a, $04
    push af
    inc sp
    ld hl, MenuTabSdStr
    push hl
    call DrawString
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0004
    push hl
    ld a, $05
    push af
    inc sp
    ld hl, MenuTabSetStr
    push hl
    call DrawString
    add sp, $05
    ld hl, $0009
    push hl
    ld a, $06
    push af
    inc sp
    ld hl, MenuTabHelpStr
    push hl
    call DrawString
    add sp, $05
    jp Jump_008_7331


Jump_008_7203:
    ld hl, sp+$06
    ld a, [hl]
    sub $01
    jp nz, Jump_008_720d

    jr jr_008_7210

Jump_008_720d:
    jp Jump_008_727e


jr_008_7210:
    ld hl, $0000
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $018f
    push hl
    ld hl, $9f0f
    push hl
    ld a, $00
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0004
    push hl
    ld a, $05
    push af
    inc sp
    ld hl, MenuTabSetStr
    push hl
    call DrawString
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0000
    push hl
    ld a, $04
    push af
    inc sp
    ld hl, MenuTabSdStr
    push hl
    call DrawString
    add sp, $05
    ld hl, $0009
    push hl
    ld a, $06
    push af
    inc sp
    ld hl, MenuTabHelpStr
    push hl
    call DrawString
    add sp, $05
    jp Jump_008_7331


Jump_008_727e:
    ld hl, sp+$06
    ld a, [hl]
    sub $02
    jp nz, Jump_008_7288

    jr jr_008_728b

Jump_008_7288:
    jp Jump_008_72f9


jr_008_728b:
    ld hl, $0000
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $018f
    push hl
    ld hl, $9f0f
    push hl
    ld a, $00
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0009
    push hl
    ld a, $06
    push af
    inc sp
    ld hl, MenuTabHelpStr
    push hl
    call DrawString
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0000
    push hl
    ld a, $04
    push af
    inc sp
    ld hl, MenuTabSdStr
    push hl
    call DrawString
    add sp, $05
    ld hl, $0004
    push hl
    ld a, $05
    push af
    inc sp
    ld hl, MenuTabSetStr
    push hl
    call DrawString
    add sp, $05
    jp Jump_008_7331


Jump_008_72f9:
    ld hl, sp+$06
    ld a, [hl]
    sub $03
    jp nz, Jump_008_7303

    jr jr_008_7306

Jump_008_7303:
    jp Jump_008_7331


jr_008_7306:
    ld hl, $0000
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $018f
    push hl
    ld hl, $9f0f
    push hl
    ld a, $00
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

Jump_008_7331:
    ret


MenuTabSdStr::
    db " SD ", $00

MenuTabSetStr::
    db " SET ", $00

MenuTabHelpStr::
    db " HELP ", $00

DrawReadingBox::
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
    ld hl, $0805
    push hl
    ld a, $0a
    push af
    inc sp
    ld hl, ReadingBoxStr
    push hl
    call DrawString
    add sp, $05
    ret


ReadingBoxStr::
    db "Reading...", $00

; [ezgb]
; Status-box draw family (bank 8), each reached via FarCallTrampoline:
; DrawReadingBox + ReadingBoxStr, DrawLoadingBox + LoadingBoxStr,
; DrawErrorFileBox + ErrorFileBoxStr, DrawLastRomButtons + LastRomReturnStr/StartStr.
; See docs/last-rom.md.

DrawLoadingBox::
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
    ld hl, $0805
    push hl
    ld a, $0a
    push af
    inc sp
    ld hl, LoadingBoxStr
    push hl
    call DrawString
    add sp, $05
    ret


LoadingBoxStr::
    db "Loading...", $00

DrawErrorFileBox::
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
    ld hl, $0805
    push hl
    ld a, $0a
    push af
    inc sp
    ld hl, ErrorFileBoxStr
    push hl
    call DrawString
    add sp, $05
    ret


ErrorFileBoxStr::
    db "Error file", $00

DrawLastRomButtons::
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $018f
    push hl
    ld hl, $9f70
    push hl
    ld a, $00
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, $018e
    push hl
    ld hl, $5184
    push hl
    ld a, $05
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, $018e
    push hl
    ld hl, $9b84
    push hl
    ld a, $55
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, $1101
    push hl
    ld a, $09
    push af
    inc sp
    ld hl, LastRomReturnStr
    push hl
    call DrawString
    add sp, $05
    ld hl, $110b
    push hl
    ld a, $08
    push af
    inc sp
    ld hl, LastRomStartStr
    push hl
    call DrawString
    add sp, $05
    ret


LastRomReturnStr::
    db "[B]return", $00

LastRomStartStr::
    db "[A]start", $00

BrowserSortAll::
    db $fa, $a4, $c5, $b7, $20, $11, $cd, $43
    db $0a, $21, $a2, $c2, $2a, $7e, $d6, $10
    db $38, $ee, $21, $a4, $c5, $36, $01, $21
    db $a2, $c2, $2a, $4f, $46, $79, $d6, $02
    db $78, $de, $00, $38, $55, $af, $b9, $3e
    db $02, $98, $38, $4e, $c5, $cd, $ee, $74
    db $c1, $c5, $c5, $cd, $93, $77, $e1, $c1
    db $59, $50, $cb, $3a, $cb, $1b, $7a, $b3
    db $28, $0e, $1b, $c5, $d5, $c5, $d5, $cd
    db $2d, $77, $e8, $04, $d1, $c1, $18, $ee
    db $59, $50, $3e, $01, $bb, $3e, $00, $9a
    db $30, $1b, $1b, $c5, $d5, $d5, $af, $0f
    db $f5, $cd, $c5, $76, $e8, $04, $d1, $d5
    db $d5, $af, $0f, $f5, $cd, $2d, $77, $e8
    db $04, $d1, $c1, $18, $dd, $c5, $cd, $08
    db $7a, $e1, $cd, $ee, $74, $21, $00, $40
    db $36, $12, $c9, $21, $00, $7f, $36, $e1
    db $2e, $10, $36, $e2, $2e, $20, $36, $e3
    db $2e, $c0, $36, $03, $2e, $f0, $36, $e4
    db $c9, $f8, $02, $7e, $e6, $1f, $4f, $06
    db $00, $2a, $5e, $cb, $3b, $cb, $1f, $cb
    db $3b, $cb, $1f, $cb, $3b, $cb, $1f, $cb
    db $3b, $cb, $1f, $cb, $3b, $cb, $1f, $c6
    db $12, $ea, $00, $40, $51, $af, $91, $5f
    db $7a, $98, $c6, $a0, $57, $c9, $21, $00
    db $40, $36, $ff, $f8, $02, $2a, $4e, $87
    db $cb, $11, $87, $cb, $11, $87, $cb, $11
    db $87, $cb, $11, $5f, $79, $c6, $a0, $57
    db $c9, $f8, $02, $7e, $d6, $61, $38, $0a
    db $3e, $7a, $96, $38, $05, $7e, $c6, $e0
    db $5f, $c9, $f8, $02, $5e, $c9, $e8, $fc
    db $f8, $08, $2a, $5f, $56, $d5, $cd, $04
    db $75, $e1, $4b, $42, $11, $00, $00, $69
    db $60, $19, $7e, $f8, $03, $77, $21, $a4
    db $c4, $19, $e5, $f8, $05, $7e, $e1, $77
    db $f8, $03, $7e, $b7, $28, $09, $13, $7b
    db $d6, $fd, $7a, $de, $00, $38, $e0, $21
    db $a1, $c5, $36, $00, $f8, $06, $2a, $5f
    db $56, $d5, $cd, $04, $75, $e1, $e1, $d5
    db $af, $f8, $02, $22, $77, $f8, $00, $2a
    db $23, $86, $2b, $4f, $2a, $23, $8e, $47
    db $0a, $f5, $33, $cd, $4c, $75, $33, $4b
    db $f8, $02, $2a, $c6, $a4, $5f, $7e, $ce
    db $c4, $57, $1a, $c5, $f5, $33, $cd, $4c
    db $75, $33, $c1, $79, $bb, $28, $12, $93
    db $30, $06, $f8, $03, $36, $ff, $18, $04
    db $f8, $03, $36, $01, $f8, $03, $5e, $18
    db $1b, $79, $b7, $28, $0a, $f8, $02, $2a
    db $d6, $fd, $7e, $de, $00, $38, $04, $1e
    db $00, $18, $09, $f8, $02, $34, $20, $ad
    db $23, $34, $18, $a9, $e8, $04, $c9, $e8
    db $f9, $21, $00, $40, $36, $ff, $f8, $09
    db $2a, $4e, $87, $cb, $11, $87, $cb, $11
    db $87, $cb, $11, $87, $cb, $11, $f5, $f8
    db $02, $f1, $22, $79, $c6, $a0, $77, $f8
    db $0b, $2a, $4e, $87, $cb, $11, $87, $cb
    db $11, $87, $cb, $11, $87, $cb, $11, $f5
    db $f8, $04, $f1, $22, $79, $c6, $a0, $77
    db $f8, $06, $36, $00, $f8, $00, $7e, $f8
    db $06, $86, $4f, $f5, $f8, $03, $f1, $7e
    db $ce, $00, $47, $0a, $f8, $04, $32, $2b
    db $7e, $f8, $06, $86, $2b, $2b, $2b, $4f
    db $2a, $23, $ce, $00, $47, $0a, $32, $2a
    db $96, $28, $0e, $f8, $04, $2a, $96, $30
    db $04, $1e, $ff, $18, $52, $1e, $01, $18
    db $4e, $f8, $06, $34, $7e, $d6, $0e, $38
    db $c3, $f8, $00, $7e, $c6, $0e, $f5, $f8
    db $07, $f1, $32, $2b, $2b, $2b, $7e, $ce
    db $00, $f8, $06, $32, $2a, $5f, $56, $1a
    db $4f, $f8, $00, $2a, $c6, $0f, $5f, $2a
    db $ce, $00, $57, $1a, $47, $2a, $c6, $0e
    db $5f, $2a, $23, $ce, $00, $57, $1a, $22
    db $36, $00, $f8, $02, $2a, $c6, $0f, $5f
    db $2a, $23, $ce, $00, $57, $1a, $57, $5e
    db $d5, $c5, $cd, $61, $75, $e8, $04, $e8
    db $07, $c9, $e8, $fa, $21, $00, $40, $36
    db $ff, $f8, $08, $2a, $4e, $87, $cb, $11
    db $87, $cb, $11, $87, $cb, $11, $87, $cb
    db $11, $f5, $f8, $02, $f1, $22, $79, $c6
    db $a0, $77, $f8, $0a, $2a, $4e, $87, $cb
    db $11, $87, $cb, $11, $87, $cb, $11, $87
    db $cb, $11, $f5, $f8, $04, $f1, $22, $79
    db $c6, $a0, $22, $23, $36, $00, $f8, $00
    db $7e, $f8, $05, $86, $2b, $2b, $2b, $2b
    db $5f, $7e, $ce, $00, $57, $1a, $f8, $04
    db $32, $2b, $7e, $f8, $05, $86, $2b, $2b
    db $4f, $2a, $ce, $00, $47, $0a, $12, $2a
    db $02, $34, $7e, $d6, $10, $38, $d7, $e8
    db $06, $c9, $3b, $3b, $f8, $04, $2a, $46
    db $23, $87, $cb, $10, $4f, $03, $79, $96
    db $23, $78, $9e, $30, $50, $69, $60, $23
    db $d1, $e5, $f8, $00, $5d, $54, $f8, $06
    db $1a, $13, $96, $23, $1a, $9e, $30, $15
    db $c5, $f8, $02, $2a, $5f, $56, $d5, $c5
    db $cd, $02, $76, $e8, $04, $6b, $c1, $cb
    db $7d, $28, $02, $c1, $c5, $c5, $c5, $f8
    db $08, $2a, $5f, $56, $d5, $cd, $02, $76
    db $e8, $04, $6b, $c1, $cb, $7d, $28, $15
    db $c5, $c5, $f8, $08, $2a, $5f, $56, $d5
    db $cd, $c5, $76, $e8, $04, $c1, $f8, $04
    db $79, $22, $70, $18, $9f, $33, $33, $c9
    db $e8, $e8, $af, $f8, $15, $22, $77, $f8
    db $15, $5d, $54, $f8, $1a, $1a, $13, $96
    db $23, $1a, $9e, $d2, $88, $78, $f8, $15
    db $2a, $5f, $56, $d5, $cd, $04, $75, $e1
    db $f8, $10, $7b, $22, $7a, $32, $2a, $c6
    db $fe, $4f, $7e, $ce, $00, $47, $0a, $fe
    db $10, $20, $03, $af, $18, $02, $3e, $01
    db $f8, $00, $77, $f8, $17, $36, $00, $f8
    db $17, $7e, $f8, $14, $77, $34, $5e, $16
    db $00, $21, $00, $00, $39, $19, $e5, $7d
    db $f8, $15, $77, $e1, $7c, $f8, $14, $32
    db $2a, $66, $6f, $36, $00, $f8, $17, $34
    db $7e, $d6, $0d, $38, $da, $36, $00, $f8
    db $10, $7e, $f8, $17, $86, $4f, $f5, $f8
    db $13, $f1, $7e, $ce, $00, $47, $0a, $f8
    db $14, $77, $3a, $2b, $22, $23, $7e, $b7
    db $28, $31, $f8, $17, $7e, $f8, $14, $77
    db $34, $5e, $16, $00, $21, $00, $00, $39
    db $19, $e5, $7d, $f8, $15, $77, $e1, $7c
    db $f8, $14, $32, $2b, $7e, $f5, $33, $cd
    db $4c, $75, $33, $7b, $f8, $13, $5e, $23
    db $66, $6b, $77, $f8, $17, $34, $7e, $d6
    db $0d, $38, $b4, $f8, $15, $7e, $f8, $0e
    db $77, $f8, $16, $7e, $f8, $0f, $77, $f8
    db $15, $2a, $5f, $56, $d5, $cd, $31, $75
    db $e1, $f8, $13, $7b, $22, $72, $1e, $00
    db $f8, $13, $2a, $83, $4f, $7e, $ce, $00
    db $47, $d5, $16, $00, $21, $02, $00, $39
    db $19, $d1, $7e, $02, $1c, $7b, $d6, $10
    db $38, $e6, $f8, $15, $34, $c2, $9a, $77
    db $23, $34, $c3, $9a, $77, $e8, $18, $c9
    db $f8, $02, $2a, $5f, $56, $d5, $cd, $04
    db $75, $e1, $4b, $42, $1e, $00, $6b, $26
    db $00, $09, $56, $7b, $c6, $a4, $6f, $3e
    db $00, $ce, $c4, $67, $72, $7a, $b7, $28
    db $06, $1c, $7b, $d6, $fd, $38, $e7, $21
    db $a1, $c5, $36, $00, $21, $fe, $00, $09
    db $5e, $c9, $f8, $02, $2a, $5f, $56, $d5
    db $cd, $04, $75, $e1, $4b, $42, $1e, $00
    db $21, $a4, $c4, $16, $00, $19, $56, $6b
    db $26, $00, $09, $7a, $77, $b7, $28, $06
    db $1c, $7b, $d6, $fd, $38, $ea, $21, $fd
    db $00, $09, $36, $00, $21, $fe, $00, $09
    db $4d, $44, $f8, $04, $7e, $02, $c9, $e8
    db $d6, $af, $f8, $27, $22, $77, $f8, $20
    db $36, $00, $f8, $2e, $2a, $5f, $56, $d5
    db $cd, $04, $75, $e1, $21, $fe, $00, $19
    db $7e, $f8, $21, $77, $f8, $20, $7e, $b7
    db $c2, $d3, $79, $23, $23, $36, $20, $f8
    db $27, $2a, $c6, $20, $4f, $7e, $ce, $00
    db $47, $3e, $fd, $b9, $3e, $00, $98, $30
    db $0a, $2b, $3e, $fd, $96, $f8, $22, $32
    db $2b, $36, $01, $f8, $2e, $2a, $5f, $56
    db $d5, $cd, $04, $75, $e1, $7b, $f8, $27
    db $86, $2b, $2b, $2b, $2b, $77, $7a, $f5
    db $f8, $2a, $f1, $8e, $f8, $24, $77, $06
    db $00, $f8, $29, $36, $00, $f8, $29, $7e
    db $f8, $22, $96, $30, $2e, $23, $7e, $f8
    db $29, $86, $2b, $2b, $2b, $2b, $32, $2a
    db $23, $ce, $00, $32, $2a, $5f, $56, $1a
    db $4f, $f8, $29, $5e, $16, $00, $21, $00
    db $00, $39, $19, $5d, $54, $79, $12, $f8
    db $29, $34, $46, $79, $b7, $20, $ce, $f8
    db $20, $36, $01, $c5, $f8, $2e, $2a, $5f
    db $56, $d5, $cd, $04, $75, $e1, $c1, $7b
    db $f8, $27, $86, $2b, $2b, $22, $23, $23
    db $7a, $8e, $2b, $2b, $77, $0e, $00, $79
    db $90, $30, $18, $f8, $25, $2a, $81, $5f
    db $7e, $ce, $00, $57, $d5, $59, $16, $00
    db $21, $02, $00, $39, $19, $d1, $7e, $12
    db $0c, $18, $e4, $78, $0e, $00, $f8, $27
    db $86, $22, $79, $8e, $77, $c3, $0f, $79
    db $f8, $2c, $2a, $5f, $56, $d5, $cd, $04
    db $75, $e1, $f8, $26, $7b, $22, $7a, $32
    db $2a, $23, $c6, $fd, $32, $2a, $23, $ce
    db $00, $32, $2a, $66, $6f, $36, $00, $f8
    db $26, $2a, $23, $c6, $fe, $32, $2a, $23
    db $ce, $00, $32, $2a, $5f, $56, $f8, $21
    db $7e, $12, $e8, $2a, $c9, $e8, $fd, $01
    db $00, $00, $f8, $05, $79, $96, $23, $78
    db $9e, $30, $0c, $c5, $c5, $cd, $31, $75
    db $e1, $c1, $af, $12, $03, $18, $eb, $01
    db $00, $00, $f8, $05, $79, $96, $23, $78
    db $9e, $30, $6b, $c5, $c5, $cd, $31, $75
    db $e1, $c1, $1a, $b7, $20, $5d, $c5, $c5
    db $cd, $8b, $78, $e1, $f8, $02, $7b, $22
    db $c1, $79, $22, $70, $c5, $f8, $03, $2a
    db $5f, $56, $d5, $cd, $31, $75, $e1, $c1
    db $3e, $01, $12, $21, $0e, $00, $19, $6e
    db $7b, $c6, $0f, $5f, $30, $01, $14, $1a
    db $57, $5d, $79, $93, $20, $16, $78, $92
    db $20, $12, $c5, $f8, $02, $2a, $f5, $33
    db $2a, $5f, $56, $d5, $cd, $bd, $78, $e8
    db $03, $c1, $18, $17, $c5, $d5, $d5, $f8
    db $07, $2a, $66, $6f, $e5, $cd, $f2, $78
    db $e8, $04, $d1, $c1, $f8, $01, $7b, $22
    db $72, $18, $b1, $03, $18, $8c, $e8, $03
    db $c9

BrowserHideName::
    db $f8, $06, $2a, $4f, $46, $0a, $fe, $2e
    db $20, $03, $1e, $01, $c9, $16, $00, $6a
    db $26, $00, $09, $7e, $b7, $28, $08, $7a
    db $d6, $fd, $30, $03, $14, $18, $f0, $c5
    db $d5, $3e, $04, $f5, $33, $21, $0e, $7b
    db $e5, $d5, $33, $c5, $cd, $40, $7b, $e8
    db $06, $7b, $d1, $c1, $b7, $28, $03, $1e
    db $01, $c9, $c5, $d5, $3e, $0b, $f5, $33
    db $21, $13, $7b, $e5, $d5, $33, $c5, $cd
    db $40, $7b, $e8, $06, $7b, $d1, $c1, $b7
    db $28, $03, $1e, $01, $c9, $7a, $d6, $0b
    db $20, $15, $3e, $0b, $f5, $33, $21, $1f
    db $7b, $e5, $d5, $33, $c5, $cd, $40, $7b
    db $e8, $06, $7b, $b7, $1e, $01, $c0, $1e
    db $00, $c9, $2e, $67, $62, $61, $00, $2e
    db $66, $61, $73, $74, $6c, $61, $75, $6e
    db $63, $68, $00, $66, $6c, $61, $75, $6e
    db $63, $68, $2e, $63, $66, $67, $00, $f8
    db $02, $7e, $d6, $41, $38, $0a, $3e, $5a
    db $96, $38, $05, $7e, $c6, $20, $5f, $c9
    db $f8, $02, $5e, $c9, $f8, $04, $7e, $f8
    db $07, $96, $30, $03, $1e, $00, $c9, $f8
    db $04, $7e, $f8, $07, $96, $5f, $9f, $57
    db $f8, $02, $7e, $83, $22, $7e, $8a, $77
    db $16, $00, $7a, $f8, $07, $96, $30, $26
    db $f8, $02, $2a, $82, $4f, $7e, $ce, $00
    db $47, $0a, $d5, $f5, $33, $cd, $2b, $7b
    db $33, $f1, $57, $f8, $05, $2a, $82, $4f
    db $7e, $ce, $00, $47, $0a, $93, $28, $03
    db $1e, $00, $c9, $14, $18, $d4, $1e, $01
    db $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
