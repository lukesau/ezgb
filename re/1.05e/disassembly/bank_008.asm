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
    jp $746b


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

EzgbTabBanner::
    db $af, $0f, $f5, $af, $3e, $03, $f5, $33
    db $cd, $91, $27, $e8, $03, $af, $67, $2e
    db $0f, $e5, $3e, $05, $f5, $33, $11, $8b
    db $74, $d5, $cd, $b7, $08, $e8, $05, $c9
    db $2a, $4d, $4f, $44, $2a, $00

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
