; Disassembly of "kernel.gb"
; This file was created with:
; mgbdis v3.0 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $007", ROMX[$4000], BANK[$7]

MemCpy16_B7::
    push af
    push af
    dec sp
    ld hl, sp+$07
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$03
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$09
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$01
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$0b
    ld a, [hl]
    ld hl, sp+$00
    ld [hl], a

Jump_007_401b:
    ld hl, sp+$00
    ld a, [hl]
    sub $02
    jp c, Jump_007_4059

    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$03
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$01
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$01
    ld [hl+], a
    ld [hl], d
    dec hl
    dec hl
    dec [hl]
    dec [hl]
    jp Jump_007_401b


Jump_007_4059:
    ld hl, sp+$00
    ld c, [hl]

Jump_007_405c:
    ld b, c
    dec c
    xor a
    or b
    jp z, Jump_007_407e

    ld hl, sp+$01
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    dec hl
    inc [hl]
    jr nz, jr_007_406f

    inc hl
    inc [hl]

jr_007_406f:
    ld hl, sp+$03
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_007_407b

    inc hl
    inc [hl]

jr_007_407b:
    jp Jump_007_405c


Jump_007_407e:
    add sp, $05
    ret


    add b
    sbc d
    ld b, l
    ld b, c
    adc [hl]
    ld b, c
    adc a
    add b
    ld b, l
    ld b, l
    ld b, l
    ld c, c
    ld c, c
    ld c, c
    adc [hl]
    adc a
    sub b
    sub d
    sub d
    ld c, a
    sbc c
    ld c, a
    ld d, l
    ld d, l
    ld e, c
    sbc c
    sbc d
    sbc e
    sbc h
    sbc l
    sbc [hl]
    sbc a
    ld b, c
    ld c, c
    ld c, a
    ld d, l
    and l
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

MemSet8_B7::
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

Jump_007_410f:
    ld b, c
    dec c
    xor a
    or b
    jp z, Jump_007_4128

    ld hl, sp+$06
    ld a, [hl]
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_007_4125

    inc hl
    inc [hl]

jr_007_4125:
    jp Jump_007_410f


Jump_007_4128:
    add sp, $02
    ret


Clone_09413e_B7::
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

Jump_007_414c:
    ld hl, sp+$02
    ld b, [hl]
    dec [hl]
    xor a
    or b
    jp z, Jump_007_418d

    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    dec hl
    inc [hl]
    jr nz, jr_007_4162

    inc hl
    inc [hl]

jr_007_4162:
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
    jr nz, jr_007_4175

    inc hl
    inc [hl]

jr_007_4175:
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
    jp z, Jump_007_414c

Jump_007_418d:
    ld hl, sp+$03
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $09
    ret


Clone_0941a8_B7::
    push af
    ld hl, sp+$04
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e

Jump_007_419e:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    or a
    jp z, Jump_007_41c4

    ld a, c
    rla
    sbc a
    ld b, a
    ld a, c
    ld hl, sp+$06
    sub [hl]
    jp nz, Jump_007_41ba

    ld a, b
    inc hl
    sub [hl]
    jp z, Jump_007_41c4

Jump_007_41ba:
    ld hl, sp+$00
    inc [hl]
    jr nz, jr_007_41c1

    inc hl
    inc [hl]

jr_007_41c1:
    jp Jump_007_419e


Jump_007_41c4:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld e, a
    rla
    sbc a
    ld d, a
    add sp, $02
    ret


; [ezgb]
; SyncWindow_B7: same as SyncWindow_B9 (09:41e5). Byte-identical to SyncWindow_B3.

SyncWindow_B7::
    add sp, -$15
    ld hl, sp+$10
    ld [hl], $00
    ld hl, sp+$17
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0c
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
    ld hl, sp+$0e
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    or a
    jp z, Jump_007_4365

    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $002e
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$11
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
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0032
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0001
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld c, a
    ld hl, $0001
    push hl
    ld hl, sp+$15
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$15
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld a, c
    push af
    inc sp
    call FarCall_02_41d5
    add sp, $09
    ld c, e
    xor a
    or c
    jp z, Jump_007_425a

    ld hl, sp+$10
    ld [hl], $01
    jp Jump_007_4365


Jump_007_425a:
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0022
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
    ld hl, sp+$11
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
    ld hl, sp+$15
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
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $001a
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld e, a
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
    jp nc, Jump_007_4365

    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0003
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld b, $00
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b

Jump_007_42e2:
    ld hl, sp+$00
    ld a, [hl]
    sub $02
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_007_4365

    ld hl, sp+$08
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
    ld hl, sp+$11
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
    ld hl, sp+$14
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
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
    ld hl, sp+$14
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0032
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld hl, $0001
    push hl
    ld hl, sp+$15
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$15
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld a, c
    push af
    inc sp
    call FarCall_02_41d5
    add sp, $09
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    dec de
    dec hl
    ld [hl], e
    inc hl
    ld [hl], d
    jp Jump_007_42e2


Jump_007_4365:
    ld hl, sp+$10
    ld e, [hl]
    add sp, $15
    ret


; [ezgb]
; MoveWindow_B7: same as MoveWindow_B9 (09:437e). Byte-identical to MoveWindow_B3.

MoveWindow_B7::
    add sp, -$09
    ld hl, sp+$08
    ld [hl], $00
    ld hl, sp+$0b
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $002e
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], d
    ld e, a
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
    ld hl, sp+$0d
    ld a, [hl]
    ld hl, sp+$00
    sub [hl]
    jp nz, Jump_007_43b9

    ld hl, sp+$0e
    ld a, [hl]
    ld hl, sp+$01
    sub [hl]
    jp nz, Jump_007_43b9

    ld hl, sp+$0f
    ld a, [hl]
    ld hl, sp+$02
    sub [hl]
    jp nz, Jump_007_43b9

    ld hl, sp+$10
    ld a, [hl]
    ld hl, sp+$03
    sub [hl]
    jp z, Jump_007_442e

Jump_007_43b9:
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call SyncWindow_B7
    add sp, $02
    ld c, e
    ld hl, sp+$08
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_007_442e

    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0032
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, [bc]
    ld c, a
    ld hl, $0001
    push hl
    ld hl, sp+$11
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$11
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld a, c
    push af
    inc sp
    call FarCall_02_4027
    add sp, $09
    ld c, e
    xor a
    or c
    jp z, Jump_007_4419

    ld hl, sp+$0d
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    ld hl, sp+$08
    ld [hl], $01

Jump_007_4419:
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$0d
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

Jump_007_442e:
    ld hl, sp+$08
    ld e, [hl]
    add sp, $09
    ret


    add sp, -$11
    ld hl, sp+$13
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call SyncWindow_B7
    add sp, $02
    ld c, e
    ld hl, sp+$10
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_007_4602

    ld hl, sp+$13
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0e
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $03
    jp nz, Jump_007_445f

    jr jr_007_4462

Jump_007_445f:
    jp Jump_007_45e0


jr_007_4462:
    ld hl, sp+$0e
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
    ld e, a
    ld a, [de]
    ld c, a
    sub $01
    jp nz, Jump_007_447b

    jr jr_007_447e

Jump_007_447b:
    jp Jump_007_45e0


jr_007_447e:
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0032
    add hl, de
    ld c, l
    ld b, h
    ld a, $00
    push af
    inc sp
    ld l, $00
    push hl
    push bc
    call MemSet8_B7
    add sp, $05
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0032
    add hl, de
    ld c, l
    ld b, h
    ld hl, $01fe
    add hl, bc
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, $55
    ld [de], a
    inc de
    ld a, $aa
    ld [de], a
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0032
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
    ld a, $52
    ld [de], a
    inc de
    ld a, $52
    ld [de], a
    inc de
    ld a, $61
    ld [de], a
    inc de
    ld a, $41
    ld [de], a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $01e4
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, $72
    ld [de], a
    inc de
    ld a, $72
    ld [de], a
    inc de
    ld a, $41
    ld [de], a
    inc de
    ld a, $61
    ld [de], a
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $01e8
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$0e
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
    ld [hl+], a
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
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $01ec
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$0e
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
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $002e
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
    ld hl, $001e
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
    inc [hl]
    jr nz, jr_007_459d

    inc hl
    inc [hl]
    jr nz, jr_007_459d

    inc hl
    inc [hl]
    jr nz, jr_007_459d

    inc hl
    inc [hl]

jr_007_459d:
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
    ld hl, sp+$0e
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, [bc]
    ld c, a
    ld hl, $0001
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
    ld hl, sp+$10
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld a, c
    push af
    inc sp
    call FarCall_02_41d5
    add sp, $09
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a

Jump_007_45e0:
    ld hl, sp+$0e
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, [bc]
    ld c, a
    ld hl, $0000
    push hl
    ld a, $00
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call ReturnZero
    add sp, $04
    ld c, e
    xor a
    or c
    jp z, Jump_007_4602

    ld hl, sp+$10
    ld [hl], $01

Jump_007_4602:
    ld hl, sp+$10
    ld e, [hl]
    add sp, $11
    ret


Clust2Sect_B7::
    add sp, -$0a
    ld hl, sp+$0e
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
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], e
    dec hl
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
    ld hl, sp+$0e
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
    jp c, Jump_007_4687

    ld de, $0000
    ld hl, $0000
    jp Jump_007_4704


Jump_007_4687:
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
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Mul
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
    ld hl, $002a
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

Jump_007_4704:
    add sp, $0a
    ret


GetFat_B7::
    add sp, -$14
    ld hl, sp+$18
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
    jp c, Jump_007_4755

    ld hl, sp+$16
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0c
    ld [hl+], a
    ld [hl], e
    dec hl
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
    ld hl, sp+$18
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
    jp c, Jump_007_4761

Jump_007_4755:
    ld hl, sp+$08
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    jp Jump_007_4adf


Jump_007_4761:
    ld hl, sp+$08
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $01
    jp c, Jump_007_4ad6

    ld a, $03
    sub c
    jp c, Jump_007_4ad6

    dec c
    ld e, c
    ld d, $00
    ld hl, $478a
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp Jump_007_4793


    jp Jump_007_4913


    jp Jump_007_49e9


Jump_007_4793:
    ld hl, sp+$18
    ld a, [hl]
    ld hl, sp+$10
    ld [hl], a
    ld hl, sp+$19
    ld a, [hl]
    ld hl, sp+$11
    ld [hl-], a
    ld c, [hl]
    inc hl
    ld b, [hl]
    srl b
    rr c
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$10
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0022
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
    ld hl, sp+$11
    ld a, [hl]
    rrca
    and $7f
    ld c, a
    ld b, $00
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
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$10
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call MoveWindow_B7
    add sp, $06
    ld c, e
    xor a
    or c
    jp nz, Jump_007_4adf

    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0032
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
    dec hl
    inc [hl]
    jr nz, jr_007_4833

    inc hl
    inc [hl]

jr_007_4833:
    ld a, b
    and $01
    ld b, a
    ld hl, sp+$00
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, sp+$12
    ld [hl], c
    inc hl
    ld [hl], $00
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0022
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
    ld hl, sp+$11
    ld a, [hl]
    rrca
    and $7f
    ld c, a
    ld b, $00
    ld hl, sp+$04
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
    ld a, e
    ld hl, sp+$04
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
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
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$10
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call MoveWindow_B7
    add sp, $06
    ld c, e
    xor a
    or c
    jp nz, Jump_007_4adf

    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0032
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$10
    ld c, [hl]
    inc hl
    ld a, [hl]
    and $01
    ld b, a
    ld hl, sp+$00
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld b, $00
    ld b, c
    ld c, $00
    ld hl, sp+$12
    ld a, [hl]
    or c
    ld [hl+], a
    ld a, [hl]
    or b
    ld [hl], a
    ld hl, sp+$18
    ld a, [hl]
    and $01
    jr nz, jr_007_48ec

    jp Jump_007_48fd


jr_007_48ec:
    ld hl, sp+$12
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, $04

jr_007_48f3:
    srl b
    rr c
    dec a
    jr nz, jr_007_48f3

    jp Jump_007_4905


Jump_007_48fd:
    ld hl, sp+$12
    ld c, [hl]
    inc hl
    ld a, [hl]
    and $0f
    ld b, a

Jump_007_4905:
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp Jump_007_4adf


Jump_007_4913:
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0022
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
    ld a, $08
    push af
    inc sp
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
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
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
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$10
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call MoveWindow_B7
    add sp, $06
    ld c, e
    xor a
    or c
    jp nz, Jump_007_4adf

    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0032
    add hl, de
    ld c, l
    ld b, h
    push bc
    ld a, $01
    push af
    inc sp
    ld hl, sp+$1d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$1d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shl
    add sp, $05
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
    ld hl, sp+$05
    ld a, [hl]
    and $01
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld a, c
    ld hl, sp+$04
    add [hl]
    ld c, a
    ld a, b
    inc hl
    adc [hl]
    ld b, a
    ld hl, sp+$0e
    ld [hl], c
    inc hl
    ld [hl], b
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp Jump_007_4adf


Jump_007_49e9:
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0022
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
    ld a, $07
    push af
    inc sp
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
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
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
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$10
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call MoveWindow_B7
    add sp, $06
    ld c, e
    xor a
    or c
    jp nz, Jump_007_4adf

    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0032
    add hl, de
    ld c, l
    ld b, h
    push bc
    ld a, $02
    push af
    inc sp
    ld hl, sp+$1d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$1d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shl
    add sp, $05
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
    ld hl, sp+$05
    ld a, [hl]
    and $01
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld a, c
    ld hl, sp+$04
    add [hl]
    ld c, a
    ld a, b
    inc hl
    adc [hl]
    ld b, a
    ld hl, sp+$0e
    ld [hl], c
    inc hl
    ld [hl], b
    dec hl
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
    ld hl, sp+$00
    ld a, [hl]
    ld hl, sp+$08
    ld [hl], a
    ld hl, sp+$01
    ld a, [hl]
    ld hl, sp+$09
    ld [hl], a
    ld hl, sp+$02
    ld a, [hl]
    ld hl, sp+$0a
    ld [hl], a
    ld hl, sp+$03
    ld a, [hl]
    and $0f
    ld hl, sp+$0b
    ld [hl], a
    jp Jump_007_4adf


Jump_007_4ad6:
    ld hl, sp+$08
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

Jump_007_4adf:
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add sp, $14
    ret


Clone_094af7_B7::
    add sp, -$19
    ld hl, sp+$1d
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
    jp c, Jump_007_4b39

    ld hl, sp+$1b
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$12
    ld [hl+], a
    ld [hl], e
    dec hl
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
    ld hl, sp+$0e
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
    ld hl, sp+$1d
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
    jp c, Jump_007_4b40

Jump_007_4b39:
    ld hl, sp+$14
    ld [hl], $02
    jp Jump_007_4f82


Jump_007_4b40:
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    sub $01
    jp c, Jump_007_4f7e

    ld a, $03
    sub b
    jp c, Jump_007_4f7e

    dec b
    ld e, b
    ld d, $00
    ld hl, $4b5d
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp Jump_007_4b66


    jp Jump_007_4d76


    jp Jump_007_4e58


Jump_007_4b66:
    ld hl, sp+$1d
    ld a, [hl]
    ld hl, sp+$17
    ld [hl], a
    ld hl, sp+$1e
    ld a, [hl]
    ld hl, sp+$18
    ld [hl-], a
    ld c, [hl]
    inc hl
    ld b, [hl]
    srl b
    rr c
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$17
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0022
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$0e
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
    ld a, [hl]
    rrca
    and $7f
    ld c, a
    ld b, $00
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$0e
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
    ld hl, sp+$12
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
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$16
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call MoveWindow_B7
    add sp, $06
    ld b, e
    ld hl, sp+$14
    ld [hl], b
    xor a
    or [hl]
    jp nz, Jump_007_4f82

    dec hl
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0032
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$17
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_007_4c0a

    inc hl
    inc [hl]

jr_007_4c0a:
    ld a, b
    and $01
    ld b, a
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$15
    ld [hl], c
    inc hl
    ld [hl], b
    dec hl
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0c
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$1d
    ld a, [hl]
    and $01
    ld hl, sp+$0e
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$0e
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, Jump_007_4c57

    ld hl, sp+$15
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    and $0f
    ld c, a
    ld hl, sp+$21
    ld b, [hl]
    ld a, b
    rlca
    rlca
    rlca
    rlca
    and $f0
    ld b, a
    or c
    ld b, a
    jp Jump_007_4c5a


Jump_007_4c57:
    ld hl, sp+$21
    ld b, [hl]

Jump_007_4c5a:
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, b
    ld [de], a
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld c, l
    ld b, h
    ld a, $01
    ld [bc], a
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0022
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
    ld hl, sp+$18
    ld a, [hl]
    rrca
    and $7f
    ld c, a
    ld b, $00
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
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$16
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call MoveWindow_B7
    add sp, $06
    ld b, e
    ld hl, sp+$14
    ld [hl], b
    xor a
    or [hl]
    jp nz, Jump_007_4f82

    ld hl, sp+$17
    ld c, [hl]
    inc hl
    ld a, [hl]
    and $01
    ld b, a
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$15
    ld [hl], c
    inc hl
    ld [hl], b
    dec hl
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$0e
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, Jump_007_4d27

    ld a, $04
    push af
    inc sp
    ld hl, sp+$24
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$24
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
    ld hl, sp+$04
    ld c, [hl]
    jp Jump_007_4d5e


Jump_007_4d27:
    ld hl, sp+$15
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    and $f0
    ld hl, sp+$04
    ld [hl], a
    ld a, $08
    push af
    inc sp
    ld hl, sp+$24
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$24
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shr
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
    ld hl, sp+$08
    ld a, [hl]
    and $0f
    ld b, a
    ld hl, sp+$04
    ld a, [hl]
    or b
    ld c, a

Jump_007_4d5e:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld c, l
    ld b, h
    ld a, $01
    ld [bc], a
    jp Jump_007_4f82


Jump_007_4d76:
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0022
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
    ld a, $08
    push af
    inc sp
    ld hl, sp+$20
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$20
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
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
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
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$16
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call MoveWindow_B7
    add sp, $06
    ld c, e
    ld hl, sp+$14
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_007_4f82

    dec hl
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0032
    add hl, de
    ld c, l
    ld b, h
    push bc
    ld a, $01
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
    call U32Shl
    add sp, $05
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
    ld hl, sp+$05
    ld a, [hl]
    and $01
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld a, c
    ld hl, sp+$04
    add [hl]
    ld c, a
    ld a, b
    inc hl
    adc [hl]
    ld b, a
    ld hl, sp+$15
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$21
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$15
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
    ld hl, $0004
    add hl, de
    ld c, l
    ld b, h
    ld a, $01
    ld [bc], a
    jp Jump_007_4f82


Jump_007_4e58:
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0022
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
    ld a, $07
    push af
    inc sp
    ld hl, sp+$20
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$20
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
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
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
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$16
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call MoveWindow_B7
    add sp, $06
    ld c, e
    ld hl, sp+$14
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_007_4f82

    dec hl
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0032
    add hl, de
    ld c, l
    ld b, h
    push bc
    ld a, $02
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
    call U32Shl
    add sp, $05
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
    ld hl, sp+$05
    ld a, [hl]
    and $01
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld a, c
    ld hl, sp+$04
    add [hl]
    ld c, a
    ld a, b
    inc hl
    adc [hl]
    ld b, a
    ld hl, sp+$15
    ld [hl], c
    inc hl
    ld [hl], b
    dec hl
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
    ld hl, sp+$00
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld a, [hl]
    and $f0
    ld [hl], a
    ld hl, sp+$21
    ld a, [hl]
    ld hl, sp+$00
    or [hl]
    ld hl, sp+$21
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$01
    or [hl]
    ld hl, sp+$22
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$02
    or [hl]
    ld hl, sp+$23
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$03
    or [hl]
    ld hl, sp+$24
    ld [hl], a
    ld hl, sp+$15
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$21
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
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld c, l
    ld b, h
    ld a, $01
    ld [bc], a
    jp Jump_007_4f82


Jump_007_4f7e:
    ld hl, sp+$14
    ld [hl], $02

Jump_007_4f82:
    ld hl, sp+$14
    ld e, [hl]
    add sp, $19
    ret


Clone_095139_B7::
    add sp, -$1b
    ld hl, sp+$1f
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_007_4ffe

    ld hl, sp+$1d
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0d
    ld [hl+], a
    ld [hl], e
    dec hl
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
    ld hl, sp+$0f
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
    ld hl, sp+$0f
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, Jump_007_4ff2

    ld hl, sp+$0d
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
    ld hl, sp+$09
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
    ld hl, sp+$0f
    ld d, h
    ld e, l
    ld hl, sp+$09
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
    jp c, Jump_007_50b5

Jump_007_4ff2:
    ld hl, sp+$0f
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    jp Jump_007_50b5


Jump_007_4ffe:
    ld hl, sp+$21
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$21
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$21
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call GetFat_B7
    add sp, $06
    push hl
    ld hl, sp+$19
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$17
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
    jp nc, Jump_007_503d

    ld de, $0001
    ld hl, $0000
    jp Jump_007_5327


Jump_007_503d:
    ld hl, sp+$17
    ld a, [hl]
    inc a
    jp nz, Jump_007_5058

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_5058

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_5058

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_5058

    jr jr_007_505b

Jump_007_5058:
    jp Jump_007_5067


jr_007_505b:
    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp Jump_007_5327


Jump_007_5067:
    ld hl, sp+$1d
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, $0016
    add hl, bc
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$09
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
    ld hl, sp+$17
    ld d, h
    ld e, l
    ld hl, sp+$09
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
    jp nc, Jump_007_50a4

    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp Jump_007_5327


Jump_007_50a4:
    ld hl, sp+$1f
    ld d, h
    ld e, l
    ld hl, sp+$0f
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

Jump_007_50b5:
    ld hl, sp+$0f
    ld d, h
    ld e, l
    ld hl, sp+$13
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
    ld hl, sp+$0f
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
    ld a, $00
    rla
    ld hl, sp+$08
    ld [hl], a
    ld hl, sp+$1d
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$09
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0016
    add hl, de
    ld c, l
    ld b, h

Jump_007_50ef:
    ld hl, sp+$13
    inc [hl]
    jr nz, jr_007_50fe

    inc hl
    inc [hl]
    jr nz, jr_007_50fe

    inc hl
    inc [hl]
    jr nz, jr_007_50fe

    inc hl
    inc [hl]

jr_007_50fe:
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
    ld hl, sp+$13
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
    jp c, Jump_007_513d

    ld hl, sp+$13
    ld [hl], $02
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    xor a
    ld hl, sp+$08
    or [hl]
    jp z, Jump_007_513d

    ld de, $0000
    ld hl, $0000
    jp Jump_007_5327


Jump_007_513d:
    push bc
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
    ld hl, sp+$0f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call GetFat_B7
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
    ld d, h
    ld e, l
    ld hl, sp+$17
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
    ld hl, sp+$17
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, Jump_007_51f3

    ld hl, sp+$17
    ld a, [hl]
    inc a
    jp nz, Jump_007_5196

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_5196

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_5196

    inc hl
    ld a, [hl]
    inc a
    jp z, Jump_007_51b5

Jump_007_5196:
    ld hl, sp+$17
    ld a, [hl]
    sub $01
    jp nz, Jump_007_51b2

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_51b2

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_51b2

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_51b2

    jr jr_007_51b5

Jump_007_51b2:
    jp Jump_007_51c1


Jump_007_51b5:
jr_007_51b5:
    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp Jump_007_5327


Jump_007_51c1:
    ld hl, sp+$13
    ld a, [hl]
    ld hl, sp+$0f
    sub [hl]
    jp nz, Jump_007_51e7

    ld hl, sp+$14
    ld a, [hl]
    ld hl, sp+$10
    sub [hl]
    jp nz, Jump_007_51e7

    ld hl, sp+$15
    ld a, [hl]
    ld hl, sp+$11
    sub [hl]
    jp nz, Jump_007_51e7

    ld hl, sp+$16
    ld a, [hl]
    ld hl, sp+$12
    sub [hl]
    jp nz, Jump_007_51e7

    jr jr_007_51ea

Jump_007_51e7:
    jp Jump_007_50ef


jr_007_51ea:
    ld de, $0000
    ld hl, $0000
    jp Jump_007_5327


Jump_007_51f3:
    ld hl, $0fff
    push hl
    ld hl, $ffff
    push hl
    ld hl, sp+$19
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$19
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$11
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_094af7_B7
    add sp, $0a
    ld c, e
    xor a
    or c
    jp nz, Jump_007_5248

    ld hl, sp+$1f
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, Jump_007_5248

    ld hl, sp+$15
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$15
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$25
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$25
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$11
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_094af7_B7
    add sp, $0a
    ld b, e
    ld c, b

Jump_007_5248:
    xor a
    or c
    jp nz, Jump_007_52e9

    ld hl, sp+$09
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000a
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld hl, sp+$13
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
    ld hl, sp+$09
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
    ld a, [hl]
    inc a
    jp nz, Jump_007_529d

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_529d

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_529d

    inc hl
    ld a, [hl]
    inc a
    jp z, Jump_007_531e

Jump_007_529d:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    sub $01
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
    ld hl, sp+$09
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0005
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld b, a
    or $01
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    jp Jump_007_531e


Jump_007_52e9:
    ld a, c
    sub $01
    jp nz, Jump_007_52f1

    jr jr_007_52f4

Jump_007_52f1:
    jp Jump_007_5304


jr_007_52f4:
    ld hl, sp+$00
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    jp Jump_007_530d


Jump_007_5304:
    ld hl, sp+$00
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

Jump_007_530d:
    ld hl, sp+$00
    ld d, h
    ld e, l
    ld hl, sp+$13
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

Jump_007_531e:
    ld hl, sp+$13
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_007_5327:
    add sp, $1b
    ret


Clone_0954db_B7::
    add sp, -$16
    ld hl, sp+$18
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl], e
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
    ld hl, sp+$1a
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld hl, sp+$0a
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
    ld hl, sp+$12
    ld a, [hl]
    sub $01
    jp nz, Jump_007_537c

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_537c

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_537c

    inc hl
    ld a, [hl]
    or a
    jp z, Jump_007_53b7

Jump_007_537c:
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$08
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl-], a
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
    ld hl, sp+$12
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
    jp c, Jump_007_53bc

Jump_007_53b7:
    ld e, $02
    jp Jump_007_5658


Jump_007_53bc:
    ld hl, sp+$12
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_007_540d

    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld a, [bc]
    ld c, a
    sub $03
    jp nz, Jump_007_53da

    jr jr_007_53dd

Jump_007_53da:
    jp Jump_007_540d


jr_007_53dd:
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, $0026
    add hl, bc
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

Jump_007_540d:
    ld hl, sp+$12
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_007_5456

    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0008
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
    ld hl, sp+$1a
    ld a, [hl]
    sub c
    inc hl
    ld a, [hl]
    sbc b
    jp c, Jump_007_5439

    ld e, $02
    jp Jump_007_5658


Jump_007_5439:
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0026
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$0e
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
    jp Jump_007_557b


Jump_007_5456:
    ld hl, sp+$08
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    inc bc
    ld a, [bc]
    ld c, a
    ld b, $00
    ld hl, sp+$0c
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, $05
    jr jr_007_5471

jr_007_546a:
    ld hl, sp+$0c
    sla [hl]
    inc hl
    rl [hl]

jr_007_5471:
    dec a
    jr nz, jr_007_546a

Jump_007_5474:
    ld hl, sp+$1a
    ld d, h
    ld e, l
    ld hl, sp+$0c
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp c, Jump_007_5543

    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call GetFat_B7
    add sp, $06
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
    ld hl, sp+$12
    ld a, [hl]
    inc a
    jp nz, Jump_007_54d6

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_54d6

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_54d6

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_54d6

    jr jr_007_54d9

Jump_007_54d6:
    jp Jump_007_54de


jr_007_54d9:
    ld e, $01
    jp Jump_007_5658


Jump_007_54de:
    ld hl, sp+$12
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
    jp c, Jump_007_5528

    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, $0016
    add hl, bc
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
    ld hl, sp+$12
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
    jp c, Jump_007_552d

Jump_007_5528:
    ld e, $02
    jp Jump_007_5658


Jump_007_552d:
    ld hl, sp+$1a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$1b
    ld [hl-], a
    ld [hl], e
    jp Jump_007_5474


Jump_007_5543:
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call Clust2Sect_B7
    add sp, $06
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
    ld hl, sp+$0e
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

Jump_007_557b:
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000a
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld hl, sp+$12
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
    ld hl, sp+$0e
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_007_55a8

    ld e, $02
    jp Jump_007_5658


Jump_007_55a8:
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000e
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$1a
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, $04

jr_007_55be:
    srl b
    rr c
    dec a
    jr nz, jr_007_55be

    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$0e
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
    ld hl, sp+$12
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
    inc hl
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
    ld hl, sp+$0a
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
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, $0032
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$1a
    ld a, [hl]
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
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a
    ld e, $00

Jump_007_5658:
    add sp, $16
    ret


Clone_09580c_B7::
    add sp, -$22
    ld hl, sp+$24
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$16
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
    ld hl, sp+$18
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, $0001
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$1c
    ld [hl+], a
    ld [hl], d
    dec hl
    ld a, [hl+]
    or [hl]
    jp z, Jump_007_56b1

    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000e
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0e
    ld [hl+], a
    ld [hl], d
    ld e, a
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
    ld hl, sp+$12
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_007_56b6

Jump_007_56b1:
    ld e, $04
    jp Jump_007_5adc


Jump_007_56b6:
    ld hl, sp+$1c
    ld a, [hl]
    and $0f
    ld hl, sp+$10
    ld [hl+], a
    ld [hl], $00
    dec hl
    ld a, [hl+]
    or [hl]
    jp nz, Jump_007_5a7f

    inc hl
    inc [hl]
    jr nz, jr_007_56d4

    inc hl
    inc [hl]
    jr nz, jr_007_56d4

    inc hl
    inc [hl]
    jr nz, jr_007_56d4

    inc hl
    inc [hl]

jr_007_56d4:
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$12
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
    ld hl, $000a
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0c
    ld [hl+], a
    ld [hl], d
    ld e, a
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
    ld hl, sp+$12
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_007_5735

    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, $0008
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
    ld hl, sp+$1c
    ld a, [hl]
    sub c
    inc hl
    ld a, [hl]
    sbc b
    jp c, Jump_007_5a7f

    ld e, $04
    jp Jump_007_5adc


Jump_007_5735:
    ld hl, sp+$1c
    ld a, [hl]
    ld hl, sp+$08
    ld [hl], a
    ld hl, sp+$1d
    ld a, [hl]
    ld hl, sp+$09
    ld [hl], a
    ld a, $04

jr_007_5743:
    ld hl, sp+$09
    srl [hl]
    dec hl
    rr [hl]
    dec a
    jr nz, jr_007_5743

    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$0a
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl-], a
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
    ld hl, sp+$08
    and [hl]
    ld c, a
    ld a, b
    inc hl
    and [hl]
    ld b, a
    or c
    jp nz, Jump_007_5a7f

    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call GetFat_B7
    add sp, $06
    push hl
    ld hl, sp+$20
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld a, $01
    ld hl, sp+$1e
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
    jp c, Jump_007_57ab

    ld e, $02
    jp Jump_007_5adc


Jump_007_57ab:
    ld hl, sp+$1e
    ld a, [hl]
    inc a
    jp nz, Jump_007_57c6

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_57c6

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_57c6

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_57c6

    jr jr_007_57c9

Jump_007_57c6:
    jp Jump_007_57ce


jr_007_57c9:
    ld e, $01
    jp Jump_007_5adc


Jump_007_57ce:
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$08
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl-], a
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
    ld hl, sp+$1e
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
    jp c, Jump_007_5a2e

    ld hl, sp+$26
    ld a, [hl+]
    or [hl]
    jp nz, Jump_007_5815

    ld e, $04
    jp Jump_007_5adc


Jump_007_5815:
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
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
    ld [hl-], a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_095139_B7
    add sp, $06
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
    ld hl, sp+$1e
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
    ld hl, sp+$1e
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_007_5868

    ld e, $07
    jp Jump_007_5adc


Jump_007_5868:
    ld hl, sp+$1e
    ld a, [hl]
    sub $01
    jp nz, Jump_007_5884

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_5884

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_5884

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_5884

    jr jr_007_5887

Jump_007_5884:
    jp Jump_007_588c


jr_007_5887:
    ld e, $02
    jp Jump_007_5adc


Jump_007_588c:
    ld hl, sp+$1e
    ld a, [hl]
    inc a
    jp nz, Jump_007_58a7

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_58a7

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_58a7

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_58a7

    jr jr_007_58aa

Jump_007_58a7:
    jp Jump_007_58af


jr_007_58aa:
    ld e, $01
    jp Jump_007_5adc


Jump_007_58af:
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    push bc
    call SyncWindow_B7
    add sp, $02
    ld c, e
    xor a
    or c
    jp z, Jump_007_58ca

    ld e, $01
    jp Jump_007_5adc


Jump_007_58ca:
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, $0032
    add hl, bc
    ld c, l
    ld b, h
    ld a, $00
    push af
    inc sp
    ld hl, $0000
    push hl
    push bc
    call MemSet8_B7
    add sp, $05
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, $002e
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$20
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$20
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call Clust2Sect_B7
    add sp, $06
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
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$12
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
    ld hl, sp+$08
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$1a
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_007_593c:
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$0a
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl-], a
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    inc bc
    ld a, [bc]
    ld c, a
    ld b, $00
    ld hl, sp+$1a
    ld a, [hl]
    sub c
    inc hl
    ld a, [hl]
    sbc b
    jp nc, Jump_007_59d1

    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld c, l
    ld b, h
    ld a, $01
    ld [bc], a
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call SyncWindow_B7
    add sp, $02
    ld c, e
    xor a
    or c
    jp z, Jump_007_597f

    ld e, $01
    jp Jump_007_5adc


Jump_007_597f:
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, $002e
    add hl, bc
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
    inc [hl]
    jr nz, jr_007_59ad

    inc hl
    inc [hl]
    jr nz, jr_007_59ad

    inc hl
    inc [hl]
    jr nz, jr_007_59ad

    inc hl
    inc [hl]

jr_007_59ad:
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
    ld hl, sp+$1a
    inc [hl]
    jr nz, jr_007_59c6

    inc hl
    inc [hl]

jr_007_59c6:
    ld hl, sp+$1a
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], e
    jp Jump_007_593c


Jump_007_59d1:
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $002e
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
    ld hl, sp+$08
    ld a, [hl]
    ld hl, sp+$00
    ld [hl], a
    ld hl, sp+$09
    ld a, [hl]
    ld hl, sp+$01
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$12
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
    ld hl, sp+$16
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

Jump_007_5a2e:
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$1e
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
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$20
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$20
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call Clust2Sect_B7
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
    ld hl, sp+$0e
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

Jump_007_5a7f:
    ld hl, sp+$18
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$1c
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
    ld hl, $0012
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, $0032
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$10
    ld c, [hl]
    inc hl
    ld b, [hl]
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
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a
    ld e, $00

Jump_007_5adc:
    add sp, $22
    ret


Clone_095c8f_B7::
    add sp, -$0b
    ld hl, $0000
    push hl
    ld hl, sp+$0f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_0954db_B7
    add sp, $04
    ld c, e
    ld hl, sp+$0a
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_007_5bab

    dec hl
    dec hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$0d
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000e
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d

Jump_007_5b16:
    ld hl, sp+$04
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
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
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
    push bc
    call MoveWindow_B7
    add sp, $06
    ld b, e
    ld hl, sp+$0a
    ld [hl], b
    xor a
    or [hl]
    jp nz, Jump_007_5bab

    ld hl, sp+$06
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
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld a, [bc]
    ld c, a
    sub $e5
    jp z, Jump_007_5b6b

    xor a
    or c
    jp nz, Jump_007_5b8c

Jump_007_5b6b:
    ld hl, sp+$08
    inc [hl]
    jr nz, jr_007_5b72

    inc hl
    inc [hl]

jr_007_5b72:
    ld hl, sp+$08
    ld a, [hl]
    ld hl, sp+$0f
    sub [hl]
    jp nz, Jump_007_5b86

    ld hl, sp+$09
    ld a, [hl]
    ld hl, sp+$10
    sub [hl]
    jp nz, Jump_007_5b86

    jr jr_007_5b89

Jump_007_5b86:
    jp Jump_007_5b93


jr_007_5b89:
    jp Jump_007_5bab


Jump_007_5b8c:
    ld hl, sp+$08
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_007_5b93:
    ld hl, $0001
    push hl
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_09580c_B7
    add sp, $04
    ld c, e
    ld hl, sp+$0a
    ld [hl], c
    xor a
    or [hl]
    jp z, Jump_007_5b16

Jump_007_5bab:
    ld hl, sp+$0a
    ld a, [hl]
    sub $04
    jp nz, Jump_007_5bb5

    jr jr_007_5bb8

Jump_007_5bb5:
    jp Jump_007_5bbc


jr_007_5bb8:
    ld hl, sp+$0a
    ld [hl], $07

Jump_007_5bbc:
    ld hl, sp+$0a
    ld e, [hl]
    add sp, $0b
    ret


Clone_095d72_B7::
    push af
    push af
    push af
    push af
    ld hl, sp+$0c
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
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$0a
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, [bc]
    ld c, a
    sub $03
    jp nz, Jump_007_5bf1

    jr jr_007_5bf4

Jump_007_5bf1:
    jp Jump_007_5c4e


jr_007_5bf4:
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0014
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
    ld hl, sp+$00
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
    ld hl, sp+$04
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

Jump_007_5c4e:
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


    push af
    push af
    push af
    ld hl, sp+$08
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
    ld hl, sp+$0a
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0014
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld a, $10
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
    call U32Shr
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
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a
    add sp, $06
    ret


Clone_095e6c_B7::
    add sp, -$0e
    ld hl, sp+$12
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
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    or c
    jp z, Jump_007_5cda

    ld de, $0000
    jp Jump_007_5e05


Jump_007_5cda:
    ld hl, sp+$12
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    and $3f
    ld c, a
    ld b, $00
    dec bc
    ld e, c
    ld d, b
    ld l, e
    ld h, d
    add hl, hl
    add hl, de
    add hl, hl
    add hl, hl
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0c
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$08
    ld [hl], $01
    inc hl
    ld [hl], $00
    ld hl, sp+$0c
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$0a
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_007_5d12:
    ld hl, sp+$0a
    ld a, [hl]
    sub $0d
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_007_5dcb

    ld de, $5e08
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld l, c
    ld h, $00
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
    ld hl, sp+$06
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld a, [hl+]
    or [hl]
    jp z, Jump_007_5dae

    ld hl, sp+$02
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_007_5d9e

    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call WToUpper
    add sp, $02
    ld hl, sp+$01
    ld [hl], d
    dec hl
    ld [hl], e
    ld hl, sp+$02
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_007_5d6e

    inc hl
    inc [hl]

jr_007_5d6e:
    ld hl, sp+$02
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0c
    ld [hl+], a
    ld [hl], e
    sla c
    rl b
    ld hl, sp+$10
    ld a, [hl+]
    ld h, [hl]
    ld l, a
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
    push bc
    call WToUpper
    add sp, $02
    ld b, d
    ld c, e
    ld hl, sp+$00
    ld a, [hl]
    sub c
    jp nz, Jump_007_5d9e

    inc hl
    ld a, [hl]
    sub b
    jp z, Jump_007_5da4

Jump_007_5d9e:
    ld de, $0000
    jp Jump_007_5e05


Jump_007_5da4:
    ld hl, sp+$06
    ld a, [hl+]
    ld e, [hl]
    inc hl
    ld [hl+], a
    ld [hl], e
    jp Jump_007_5dc1


Jump_007_5dae:
    ld hl, sp+$06
    ld a, [hl]
    inc a
    jp nz, Jump_007_5dbb

    inc hl
    ld a, [hl]
    inc a
    jp z, Jump_007_5dc1

Jump_007_5dbb:
    ld de, $0000
    jp Jump_007_5e05


Jump_007_5dc1:
    ld hl, sp+$0a
    inc [hl]
    jr nz, jr_007_5dc8

    inc hl
    inc [hl]

jr_007_5dc8:
    jp Jump_007_5d12


Jump_007_5dcb:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $40
    jr nz, jr_007_5dd9

    jp Jump_007_5e02


jr_007_5dd9:
    ld hl, sp+$08
    ld a, [hl+]
    or [hl]
    jp z, Jump_007_5e02

    ld hl, sp+$0c
    ld c, [hl]
    inc hl
    ld b, [hl]
    sla c
    rl b
    ld hl, sp+$10
    ld a, [hl+]
    ld h, [hl]
    ld l, a
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
    or c
    jp z, Jump_007_5e02

    ld de, $0000
    jp Jump_007_5e05


Jump_007_5e02:
    ld de, $0001

Jump_007_5e05:
    add sp, $0e
    ret


    ld bc, $0503
    rlca
    add hl, bc
    ld c, $10
    ld [de], a
    inc d
    ld d, $18
    inc e
    ld e, $e8
    di
    ld hl, sp+$11
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
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    or c
    jp z, Jump_007_5e33

    ld de, $0000
    jp Jump_007_5f3d


Jump_007_5e33:
    ld hl, sp+$11
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
    inc hl
    ld [hl], a
    and $3f
    ld c, a
    ld b, $00
    dec bc
    ld e, c
    ld d, b
    ld l, e
    ld h, d
    add hl, hl
    add hl, de
    add hl, hl
    add hl, hl
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0b
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$07
    ld [hl], $01
    inc hl
    ld [hl], $00
    ld hl, sp+$0b
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$09
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_007_5e6d:
    ld hl, sp+$09
    ld a, [hl]
    sub $0d
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_007_5f04

    ld de, $5e08
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld l, c
    ld h, $00
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
    ld hl, sp+$05
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld a, [hl+]
    or [hl]
    jp z, Jump_007_5ee7

    ld hl, sp+$00
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_007_5eb4

    ld de, $0000
    jp Jump_007_5f3d


Jump_007_5eb4:
    ld hl, sp+$00
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_007_5ebf

    inc hl
    inc [hl]

jr_007_5ebf:
    ld hl, sp+$00
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0b
    ld [hl+], a
    ld [hl], e
    sla c
    rl b
    ld hl, sp+$0f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$05
    ld a, [hl+]
    ld e, [hl]
    inc hl
    ld [hl+], a
    ld [hl], e
    ld e, c
    ld d, b
    ld hl, sp+$05
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    jp Jump_007_5efa


Jump_007_5ee7:
    ld hl, sp+$05
    ld a, [hl]
    inc a
    jp nz, Jump_007_5ef4

    inc hl
    ld a, [hl]
    inc a
    jp z, Jump_007_5efa

Jump_007_5ef4:
    ld de, $0000
    jp Jump_007_5f3d


Jump_007_5efa:
    ld hl, sp+$09
    inc [hl]
    jr nz, jr_007_5f01

    inc hl
    inc [hl]

jr_007_5f01:
    jp Jump_007_5e6d


Jump_007_5f04:
    ld hl, sp+$04
    ld a, [hl]
    and $40
    jr nz, jr_007_5f0e

    jp Jump_007_5f3a


jr_007_5f0e:
    ld hl, sp+$0b
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_007_5f20

    ld de, $0000
    jp Jump_007_5f3d


Jump_007_5f20:
    ld hl, sp+$0b
    ld c, [hl]
    inc hl
    ld b, [hl]
    sla c
    rl b
    ld hl, sp+$0f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a

Jump_007_5f3a:
    ld de, $0001

Jump_007_5f3d:
    add sp, $0d
    ret


Clone_0960f0_B7::
    push af
    push af
    push af
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000d
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$0d
    ld a, [hl]
    ld [bc], a
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000b
    add hl, de
    ld c, l
    ld b, h
    ld a, $0f
    ld [bc], a
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000c
    add hl, de
    ld c, l
    ld b, h
    ld a, $00
    ld [bc], a
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $001a
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
    ld hl, sp+$0c
    ld c, [hl]
    ld b, $00
    dec bc
    ld e, c
    ld d, b
    ld l, e
    ld h, d
    add hl, hl
    add hl, de
    add hl, hl
    add hl, hl
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$02
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$04
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_007_5fa6:
    ld hl, sp+$02
    ld a, [hl]
    inc a
    jp nz, Jump_007_5fb3

    inc hl
    ld a, [hl]
    inc a
    jp z, Jump_007_5fd6

Jump_007_5fb3:
    ld hl, sp+$00
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_007_5fbe

    inc hl
    inc [hl]

jr_007_5fbe:
    sla c
    rl b
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
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
    ld hl, sp+$02
    ld [hl], c
    inc hl
    ld [hl], b

Jump_007_5fd6:
    ld de, $5e08
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld l, c
    ld h, $00
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld hl, sp+$02
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    dec hl
    ld a, [hl+]
    or [hl]
    jp nz, Jump_007_6004

    dec hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff

Jump_007_6004:
    ld hl, sp+$04
    inc [hl]
    jr nz, jr_007_600b

    inc hl
    inc [hl]

jr_007_600b:
    ld hl, sp+$04
    ld a, [hl]
    sub $0d
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_007_5fa6

    ld hl, sp+$02
    ld a, [hl]
    inc a
    jp nz, Jump_007_6024

    inc hl
    ld a, [hl]
    inc a
    jp z, Jump_007_6040

Jump_007_6024:
    ld hl, sp+$00
    ld c, [hl]
    inc hl
    ld b, [hl]
    sla c
    rl b
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
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
    or c
    jp nz, Jump_007_6046

Jump_007_6040:
    ld hl, sp+$0c
    ld a, [hl]
    or $40
    ld [hl], a

Jump_007_6046:
    ld hl, sp+$0a
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc hl
    ld a, [hl]
    ld [bc], a
    add sp, $06
    ret


Call_007_6051:
    add sp, -$1d
    ld hl, sp+$1f
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, $0b
    push af
    inc sp
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call MemCpy16_B7
    add sp, $05
    ld a, $05
    ld hl, sp+$25
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp nc, Jump_007_6154

    dec hl
    ld a, [hl]
    ld hl, sp+$0a
    ld [hl], a
    ld hl, sp+$26
    ld a, [hl]
    ld hl, sp+$0b
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$23
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], e

Jump_007_608b:
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    or c
    jp z, Jump_007_6148

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
    ld hl, sp+$0e
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$12
    ld [hl], $10
    inc hl
    ld [hl], $00

Jump_007_60b3:
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
    ld hl, sp+$0e
    ld a, [hl]
    and $01
    ld c, a
    ld b, $00
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
    ld d, h
    ld e, l
    ld hl, sp+$0a
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
    ld hl, sp+$0f
    srl [hl]
    dec hl
    rr [hl]
    dec hl
    dec hl
    ld a, [hl]
    and $01
    jr nz, jr_007_6127

    jp Jump_007_6135


jr_007_6127:
    ld hl, sp+$0a
    ld a, [hl]
    xor $21
    ld [hl+], a
    ld a, [hl]
    xor $10
    ld [hl+], a
    ld a, [hl]
    xor $01
    ld [hl], a

Jump_007_6135:
    ld hl, sp+$12
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
    jp nz, Jump_007_60b3

    jp Jump_007_608b


Jump_007_6148:
    ld hl, sp+$0a
    ld a, [hl]
    ld hl, sp+$25
    ld [hl], a
    ld hl, sp+$0b
    ld a, [hl]
    ld hl, sp+$26
    ld [hl], a

Jump_007_6154:
    ld hl, sp+$15
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$12
    ld [hl], $07
    inc hl
    ld [hl], $00

Jump_007_6163:
    ld hl, sp+$25
    ld a, [hl]
    and $0f
    ld c, a
    ld b, $00
    ld a, c
    add $30
    ld hl, sp+$14
    ld [hl], a
    ld a, $39
    sub [hl]
    jp nc, Jump_007_617b

    ld a, [hl]
    add $07
    ld [hl], a

Jump_007_617b:
    ld hl, sp+$12
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
    dec hl
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$00
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$14
    ld a, [hl]
    ld [bc], a
    ld a, $04

jr_007_619e:
    ld hl, sp+$26
    srl [hl]
    dec hl
    rr [hl]
    dec a
    jr nz, jr_007_619e

    ld a, [hl+]
    or [hl]
    jp nz, Jump_007_6163

    ld hl, sp+$12
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$12
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld a, $7e
    ld [bc], a
    ld hl, sp+$10
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_007_61cc:
    ld hl, sp+$10
    ld d, h
    ld e, l
    ld hl, sp+$04
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp nc, Jump_007_61f9

    ld hl, sp+$1f
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$10
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    sub $20
    jp z, Jump_007_61f9

    ld hl, sp+$10
    inc [hl]
    jr nz, jr_007_61f6

    inc hl
    inc [hl]

jr_007_61f6:
    jp Jump_007_61cc


Jump_007_61f9:
    ld hl, sp+$04
    ld a, [hl+]
    ld e, [hl]
    dec hl
    ld [hl+], a
    ld [hl], e

Jump_007_6200:
    ld hl, sp+$10
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_007_620b

    inc hl
    inc [hl]

jr_007_620b:
    ld hl, sp+$1f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$04
    ld a, [hl]
    sub $08
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_007_623a

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_007_622d

    inc hl
    inc [hl]

jr_007_622d:
    ld hl, sp+$00
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    jp Jump_007_623c


Jump_007_623a:
    ld c, $20

Jump_007_623c:
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    ld hl, sp+$10
    ld a, [hl]
    sub $08
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_007_6200

    add sp, $1d
    ret


Clone_096402_B7::
    push af
    push af
    dec sp
    ld hl, sp+$04
    ld [hl], $00
    ld hl, sp+$07
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    inc hl
    ld [hl], $0b
    inc hl
    ld [hl], $00

Jump_007_6267:
    ld hl, sp+$04
    ld c, [hl]
    srl c
    ld a, [hl]
    rrca
    and $80
    ld b, a
    add c
    ld c, a
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    dec hl
    inc [hl]
    jr nz, jr_007_6280

    inc hl
    inc [hl]

jr_007_6280:
    ld a, c
    add b
    ld c, a
    ld hl, sp+$04
    ld [hl], c
    dec hl
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
    ld a, [hl+]
    or [hl]
    jp nz, Jump_007_6267

    inc hl
    ld e, [hl]
    add sp, $05
    ret


Clone_09644b_B7::
    add sp, -$1a
    ld hl, $0000
    push hl
    ld hl, sp+$1e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_0954db_B7
    add sp, $04
    ld c, e
    ld hl, sp+$19
    ld [hl], c
    xor a
    or [hl]
    jp z, Jump_007_62b9

    ld e, [hl]
    jp Jump_007_64f3


Jump_007_62b9:
    ld hl, sp+$14
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    ld hl, sp+$1c
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$12
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0018
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$10
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $ff
    ld [de], a
    inc de
    ld a, $ff
    ld [de], a
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0e
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0012
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0c
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0014
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
    ld hl, $0016
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
    ld hl, $000e
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], d

Jump_007_632b:
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$02
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
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call MoveWindow_B7
    add sp, $06
    ld b, e
    ld hl, sp+$19
    ld [hl], b
    xor a
    or [hl]
    jp nz, Jump_007_64f0

    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$16
    ld [hl], c
    inc hl
    ld [hl], b
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc hl
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_007_6384

    inc hl
    ld [hl], $04
    jp Jump_007_64f0


Jump_007_6384:
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000b
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    and $3f
    ld c, a
    ld hl, sp+$18
    ld a, [hl]
    sub $e5
    jp z, Jump_007_63a9

    ld a, c
    and $08
    jr nz, jr_007_63a3

    jp Jump_007_63bc


jr_007_63a3:
    ld a, c
    sub $0f
    jp z, Jump_007_63bc

Jump_007_63a9:
    ld hl, sp+$15
    ld [hl], $ff
    ld hl, sp+$10
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $ff
    ld [de], a
    inc de
    ld a, $ff
    ld [de], a
    jp Jump_007_64d8


Jump_007_63bc:
    ld a, c
    sub $0f
    jp nz, Jump_007_63c4

    jr jr_007_63c7

Jump_007_63c4:
    jp Jump_007_6472


jr_007_63c7:
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    or c
    jp z, Jump_007_64d8

    ld hl, sp+$18
    ld a, [hl]
    and $40
    jr nz, jr_007_63df

    jp Jump_007_640b


jr_007_63df:
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000d
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, sp+$14
    ld [hl], c
    ld hl, sp+$18
    ld a, [hl]
    and $bf
    ld [hl], a
    ld hl, sp+$15
    ld [hl], a
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a

Jump_007_640b:
    ld hl, sp+$18
    ld a, [hl]
    ld hl, sp+$15
    sub [hl]
    jp nz, Jump_007_6416

    jr jr_007_6419

Jump_007_6416:
    jp Jump_007_642d


jr_007_6419:
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000d
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, sp+$14
    ld a, [hl]
    sub c
    jp z, Jump_007_6432

Jump_007_642d:
    ld c, $00
    jp Jump_007_6434


Jump_007_6432:
    ld c, $01

Jump_007_6434:
    xor a
    or c
    jp z, Jump_007_6456

    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$16
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call Clone_095e6c_B7
    add sp, $04
    ld b, d
    ld c, e
    ld a, c
    or b
    jp nz, Jump_007_645b

Jump_007_6456:
    ld c, $00
    jp Jump_007_645d


Jump_007_645b:
    ld c, $01

Jump_007_645d:
    xor a
    or c
    jp z, Jump_007_646a

    ld hl, sp+$15
    ld a, [hl]
    dec a
    ld c, a
    jp Jump_007_646c


Jump_007_646a:
    ld c, $ff

Jump_007_646c:
    ld hl, sp+$15
    ld [hl], c
    jp Jump_007_64d8


Jump_007_6472:
    xor a
    ld hl, sp+$15
    or [hl]
    jp nz, Jump_007_648b

    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_096402_B7
    add sp, $02
    ld c, e
    ld hl, sp+$14
    ld a, [hl]
    sub c
    jp z, Jump_007_64f0

Jump_007_648b:
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$00
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl-], a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000b
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    and $01
    jr nz, jr_007_64a9

    jp Jump_007_64ac


jr_007_64a9:
    jp Jump_007_64c8


Jump_007_64ac:
    ld a, $0b
    push af
    inc sp
    ld hl, sp+$01
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$19
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_09413e_B7
    add sp, $05
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, Jump_007_64f0

Jump_007_64c8:
    ld hl, sp+$15
    ld [hl], $ff
    ld hl, sp+$10
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $ff
    ld [de], a
    inc de
    ld a, $ff
    ld [de], a

Jump_007_64d8:
    ld hl, $0000
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_09580c_B7
    add sp, $04
    ld c, e
    ld hl, sp+$19
    ld [hl], c
    xor a
    or [hl]
    jp z, Jump_007_632b

Jump_007_64f0:
    ld hl, sp+$19
    ld e, [hl]

Jump_007_64f3:
    add sp, $1a
    ret


    add sp, -$0f
    ld hl, sp+$09
    ld [hl], $ff
    dec hl
    ld [hl], $ff
    ld hl, sp+$0e
    ld [hl], $04
    ld hl, sp+$11
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000e
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], d

Jump_007_6519:
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$02
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
    ld hl, sp+$02
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, Jump_007_66df

    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call MoveWindow_B7
    add sp, $06
    ld c, e
    ld hl, sp+$0e
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_007_66df

    ld hl, sp+$00
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
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$0a
    ld [hl], c
    inc hl
    ld [hl], b
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc hl
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_007_6586

    inc hl
    inc hl
    ld [hl], $04
    jp Jump_007_66df


Jump_007_6586:
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000b
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    and $3f
    ld hl, sp+$0d
    ld [hl-], a
    ld a, [hl]
    sub $e5
    jp z, Jump_007_65c6

    ld hl, sp+$0d
    ld c, [hl]
    ld b, $00
    ld a, c
    and $df
    ld c, a
    sub $08
    jp nz, Jump_007_65b4

    or b
    jp nz, Jump_007_65b4

    ld a, $01
    jr jr_007_65b5

Jump_007_65b4:
    xor a

jr_007_65b5:
    ld c, a
    rla
    sbc a
    ld b, a
    ld a, c
    ld hl, sp+$13
    sub [hl]
    jp nz, Jump_007_65c6

    ld a, b
    inc hl
    sub [hl]
    jp z, Jump_007_65cd

Jump_007_65c6:
    ld hl, sp+$09
    ld [hl], $ff
    jp Jump_007_66c7


Jump_007_65cd:
    ld hl, sp+$0d
    ld a, [hl]
    sub $0f
    jp nz, Jump_007_65d7

    jr jr_007_65da

Jump_007_65d7:
    jp Jump_007_6697


jr_007_65da:
    ld hl, sp+$0c
    ld a, [hl]
    and $40
    jr nz, jr_007_65e4

    jp Jump_007_6628


jr_007_65e4:
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000d
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, sp+$08
    ld [hl], c
    ld hl, sp+$0c
    ld a, [hl]
    and $bf
    ld [hl], a
    ld hl, sp+$09
    ld [hl], a
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0018
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$00
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
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a

Jump_007_6628:
    ld hl, sp+$0c
    ld a, [hl]
    ld hl, sp+$09
    sub [hl]
    jp nz, Jump_007_6633

    jr jr_007_6636

Jump_007_6633:
    jp Jump_007_664a


jr_007_6636:
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000d
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, sp+$08
    ld a, [hl]
    sub c
    jp z, Jump_007_664f

Jump_007_664a:
    ld c, $00
    jp Jump_007_6651


Jump_007_664f:
    ld c, $01

Jump_007_6651:
    xor a
    or c
    jp z, Jump_007_667b

    ld hl, sp+$00
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
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call $5e15
    add sp, $04
    ld b, d
    ld c, e
    ld a, c
    or b
    jp nz, Jump_007_6680

Jump_007_667b:
    ld c, $00
    jp Jump_007_6682


Jump_007_6680:
    ld c, $01

Jump_007_6682:
    xor a
    or c
    jp z, Jump_007_668f

    ld hl, sp+$09
    ld a, [hl]
    dec a
    ld c, a
    jp Jump_007_6691


Jump_007_668f:
    ld c, $ff

Jump_007_6691:
    ld hl, sp+$09
    ld [hl], c
    jp Jump_007_66c7


Jump_007_6697:
    xor a
    ld hl, sp+$09
    or [hl]
    jp nz, Jump_007_66b0

    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_096402_B7
    add sp, $02
    ld c, e
    ld hl, sp+$08
    ld a, [hl]
    sub c
    jp z, Jump_007_66df

Jump_007_66b0:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0018
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, $ff
    ld [de], a
    inc de
    ld a, $ff
    ld [de], a
    jp Jump_007_66df


Jump_007_66c7:
    ld hl, $0000
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_09580c_B7
    add sp, $04
    ld c, e
    ld hl, sp+$0e
    ld [hl], c
    xor a
    or [hl]
    jp z, Jump_007_6519

Jump_007_66df:
    xor a
    ld hl, sp+$0e
    or [hl]
    jp z, Jump_007_66fa

    ld hl, sp+$06
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

Jump_007_66fa:
    ld hl, sp+$0e
    ld e, [hl]
    add sp, $0f
    ret


    add sp, -$26
    ld hl, sp+$28
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0014
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0e
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$13
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0016
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0c
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$10
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$15
    ld c, l
    ld b, h
    ld a, $0c
    push af
    inc sp
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call MemCpy16_B7
    add sp, $05
    ld hl, sp+$15
    ld a, l
    ld d, h
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000b
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld c, a
    and $20
    jr nz, jr_007_6771

    jp Jump_007_6776


jr_007_6771:
    ld e, $06
    jp Jump_007_6a8c


Jump_007_6776:
    ld a, c
    and $01
    jr nz, jr_007_677e

    jp Jump_007_682a


jr_007_677e:
    ld hl, sp+$13
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000b
    add hl, de
    ld c, l
    ld b, h
    ld a, $00
    ld [bc], a
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    ld hl, sp+$23
    ld [hl], $01
    inc hl
    ld [hl], $00

Jump_007_679f:
    ld hl, sp+$23
    ld a, [hl]
    sub $64
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_007_67e5

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
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$19
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_007_6051
    add sp, $08
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_09644b_B7
    add sp, $02
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_007_67e5

    dec hl
    dec hl
    inc [hl]
    jr nz, jr_007_67e2

    inc hl
    inc [hl]

jr_007_67e2:
    jp Jump_007_679f


Jump_007_67e5:
    ld hl, sp+$23
    ld a, [hl]
    sub $64
    jp nz, Jump_007_67f5

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_67f5

    jr jr_007_67f8

Jump_007_67f5:
    jp Jump_007_67fd


jr_007_67f8:
    ld e, $07
    jp Jump_007_6a8c


Jump_007_67fd:
    ld hl, sp+$25
    ld a, [hl]
    sub $04
    jp z, Jump_007_680b

    ld hl, sp+$25
    ld e, [hl]
    jp Jump_007_6a8c


Jump_007_680b:
    ld hl, sp+$13
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000b
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld [bc], a
    ld hl, sp+$0c
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

Jump_007_682a:
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $02
    jr nz, jr_007_6838

    jp Jump_007_6883


jr_007_6838:
    ld hl, sp+$23
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_007_683f:
    ld hl, sp+$23
    ld c, [hl]
    inc hl
    ld b, [hl]
    sla c
    rl b
    ld hl, sp+$10
    ld a, [hl+]
    ld h, [hl]
    ld l, a
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
    or c
    jp z, Jump_007_6865

    ld hl, sp+$23
    inc [hl]
    jr nz, jr_007_6862

    inc hl
    inc [hl]

jr_007_6862:
    jp Jump_007_683f


Jump_007_6865:
    ld hl, sp+$23
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0019
    add hl, de
    ld c, l
    ld b, h
    ld l, $0d
    push hl
    push bc
    call U16Div
    add sp, $04
    ld b, d
    ld c, e
    ld hl, sp+$21
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_007_688a


Jump_007_6883:
    ld hl, sp+$21
    ld [hl], $01
    inc hl
    ld [hl], $00

Jump_007_688a:
    ld hl, sp+$21
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_095c8f_B7
    add sp, $04
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_007_69bc

    ld hl, sp+$21
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
    jp z, Jump_007_69bc

    ld hl, sp+$0a
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
    ld hl, sp+$21
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    sub e
    ld e, a
    ld a, b
    sbc d
    ld b, a
    ld c, e
    push bc
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_0954db_B7
    add sp, $04
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_007_69bc

    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    push bc
    call Clone_096402_B7
    add sp, $02
    ld c, e
    ld hl, sp+$12
    ld [hl], c
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000e
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$21
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], e

Jump_007_6912:
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$02
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
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call MoveWindow_B7
    add sp, $06
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_007_69bc

    ld hl, sp+$06
    ld a, [hl]
    ld hl, sp+$02
    ld [hl], a
    ld hl, sp+$0a
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
    ld [hl], a
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$12
    ld a, [hl]
    push af
    inc sp
    ld hl, sp+$03
    ld a, [hl]
    push af
    inc sp
    dec hl
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call Clone_0960f0_B7
    add sp, $06
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    inc bc
    inc bc
    inc bc
    inc bc
    ld a, $01
    ld [bc], a
    ld hl, $0000
    push hl
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_09580c_B7
    add sp, $04
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_007_69bc

    ld hl, sp+$06
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
    jp nz, Jump_007_6912

Jump_007_69bc:
    xor a
    ld hl, sp+$25
    or [hl]
    jp nz, Jump_007_6a89

    ld hl, sp+$0a
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
    ld hl, sp+$02
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
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call MoveWindow_B7
    add sp, $06
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_007_6a89

    ld hl, sp+$0a
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
    ld e, a
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld a, $20
    push af
    inc sp
    ld hl, $0000
    push hl
    push bc
    call MemSet8_B7
    add sp, $05
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$02
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld a, $0b
    push af
    inc sp
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call MemCpy16_B7
    add sp, $05
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, $000c
    add hl, bc
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
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, $000b
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    and $18
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    inc bc
    inc bc
    inc bc
    inc bc
    ld a, $01
    ld [bc], a

Jump_007_6a89:
    ld hl, sp+$25
    ld e, [hl]

Jump_007_6a8c:
    add sp, $26
    ret


    add sp, -$16
    ld hl, sp+$1a
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0c
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0009
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$12
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$18
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl], e
    dec hl
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
    jp z, Jump_007_6c27

    inc hl
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
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$10
    ld [hl], c
    inc hl
    ld [hl], b
    dec hl
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
    ld hl, sp+$14
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_007_6afe:
    ld hl, sp+$14
    ld a, [hl]
    sub $0b
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_007_6b81

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_007_6b14

    inc hl
    inc [hl]

jr_007_6b14:
    ld hl, sp+$10
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    sub $20
    jp z, Jump_007_6afe

    ld a, c
    sub $05
    jp nz, Jump_007_6b2b

    jr jr_007_6b2e

Jump_007_6b2b:
    jp Jump_007_6b30


jr_007_6b2e:
    ld c, $e5

Jump_007_6b30:
    ld hl, sp+$14
    ld a, [hl]
    sub $09
    jp nz, Jump_007_6b40

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_6b40

    jr jr_007_6b43

Jump_007_6b40:
    jp Jump_007_6b51


jr_007_6b43:
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $2e
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_007_6b51

    inc hl
    inc [hl]

Jump_007_6b51:
jr_007_6b51:
    ld a, c
    sub $41
    rlca
    jp c, Jump_007_6b71

    ld a, $5a
    sub c
    rlca
    jp c, Jump_007_6b71

    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    and $08
    jr nz, jr_007_6b6d

    jp Jump_007_6b71


jr_007_6b6d:
    ld a, c
    add $20
    ld c, a

Jump_007_6b71:
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_007_6b7e

    inc hl
    inc [hl]

jr_007_6b7e:
    jp Jump_007_6afe


Jump_007_6b81:
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0008
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$10
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000b
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$10
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $001c
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
    ld hl, sp+$0c
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
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$10
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0018
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
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$10
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
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a

Jump_007_6c27:
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
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
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    or c
    jp z, Jump_007_6d48

    ld hl, sp+$00
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$12
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$06
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, Jump_007_6d38

    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0018
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    or c
    jp z, Jump_007_6d38

    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0018
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
    ld a, c
    inc a
    jp nz, Jump_007_6c91

    ld a, b
    inc a
    jp z, Jump_007_6d38

Jump_007_6c91:
    ld hl, sp+$0a
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
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$14
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$06
    ld [hl], c
    inc hl
    ld [hl], b

Jump_007_6caf:
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
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
    ld hl, sp+$0e
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, c
    or b
    jp z, Jump_007_6d38

    ld hl, $0000
    push hl
    ld hl, sp+$10
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call MapCp437
    add sp, $04
    ld b, d
    ld c, e
    ld hl, sp+$0e
    ld [hl], c
    inc hl
    ld [hl], b
    dec hl
    ld a, [hl+]
    or [hl]
    jp nz, Jump_007_6cf7

    ld hl, sp+$00
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp Jump_007_6d38


Jump_007_6cf7:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    dec bc
    ld hl, sp+$14
    ld a, [hl]
    sub c
    inc hl
    ld a, [hl]
    sbc b
    jp c, Jump_007_6d16

    ld hl, sp+$00
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp Jump_007_6d38


Jump_007_6d16:
    ld hl, sp+$14
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_007_6d21

    inc hl
    inc [hl]

jr_007_6d21:
    ld hl, sp+$14
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$12
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$0e
    ld a, [hl]
    ld [bc], a
    jp Jump_007_6caf


Jump_007_6d38:
    ld hl, sp+$12
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
    ld a, $00
    ld [bc], a

Jump_007_6d48:
    add sp, $16
    ret


Clone_096c3e_B7::
    add sp, -$1b
    ld hl, sp+$1f
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$09
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
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]

Jump_007_6d66:
    ld a, [bc]
    ld hl, sp+$08
    ld [hl], a
    sub $2f
    jp z, Jump_007_6d7c

    ld hl, sp+$08
    ld a, [hl]
    sub $5c
    jp nz, Jump_007_6d79

    jr jr_007_6d7c

Jump_007_6d79:
    jp Jump_007_6d85


Jump_007_6d7c:
jr_007_6d7c:
    inc bc
    ld hl, sp+$0b
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_007_6d66


Jump_007_6d85:
    ld hl, sp+$0b
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$1d
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], e
    dec hl
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
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$15
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$0d
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$02
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_007_6dbc:
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_007_6dc7

    inc hl
    inc [hl]

jr_007_6dc7:
    ld hl, sp+$04
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0f
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$0b
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, sp+$17
    ld [hl], c
    ld a, c
    rla
    sbc a
    inc hl
    ld [hl-], a
    ld a, [hl]
    sub $20
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_007_6e8e

    dec hl
    ld a, [hl]
    sub $2f
    jp nz, Jump_007_6df8

    inc hl
    ld a, [hl]
    or a
    jp z, Jump_007_6e8e

Jump_007_6df8:
    ld hl, sp+$17
    ld a, [hl]
    sub $5c
    jp nz, Jump_007_6e06

    inc hl
    ld a, [hl]
    or a
    jp z, Jump_007_6e8e

Jump_007_6e06:
    ld hl, sp+$02
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_007_6e17

    ld e, $06
    jp Jump_007_73c0


Jump_007_6e17:
    ld hl, sp+$18
    ld [hl], $00
    ld hl, $0001
    push hl
    ld hl, sp+$19
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call MapCp437
    add sp, $04
    ld b, d
    ld c, e
    ld hl, sp+$17
    ld [hl], c
    inc hl
    ld [hl], b
    dec hl
    ld a, [hl+]
    or [hl]
    jp nz, Jump_007_6e3c

    ld e, $06
    jp Jump_007_73c0


Jump_007_6e3c:
    ld hl, sp+$17
    ld a, [hl]
    sub $80
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_007_6e62

    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $73c3
    push hl
    call Clone_0941a8_B7
    add sp, $04
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, Jump_007_6e62

    ld e, $06
    jp Jump_007_73c0


Jump_007_6e62:
    ld hl, sp+$02
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_007_6e6d

    inc hl
    inc [hl]

jr_007_6e6d:
    ld hl, sp+$02
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0d
    ld [hl+], a
    ld [hl], e
    sla c
    rl b
    ld hl, sp+$15
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld hl, sp+$17
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    jp Jump_007_6dbc


Jump_007_6e8e:
    ld hl, sp+$0b
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$0f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$09
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a
    ld hl, sp+$17
    ld a, [hl]
    sub $20
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_007_6eb6

    ld c, $04
    jp Jump_007_6eb8


Jump_007_6eb6:
    ld c, $00

Jump_007_6eb8:
    ld hl, sp+$19
    ld [hl], c
    ld hl, sp+$0d
    ld a, [hl]
    sub $01
    jp nz, Jump_007_6ecb

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_6ecb

    jr jr_007_6ece

Jump_007_6ecb:
    jp Jump_007_6ef1


jr_007_6ece:
    ld hl, sp+$0d
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec bc
    sla c
    rl b
    ld hl, sp+$15
    ld a, [hl+]
    ld h, [hl]
    ld l, a
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
    ld a, c
    sub $2e
    jp nz, Jump_007_6ef1

    or b
    jp z, Jump_007_6f55

Jump_007_6ef1:
    ld hl, sp+$0d
    ld a, [hl]
    sub $02
    jp nz, Jump_007_6f01

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_6f01

    jr jr_007_6f04

Jump_007_6f01:
    jp Jump_007_6fe8


jr_007_6f04:
    ld hl, sp+$0d
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec bc
    sla c
    rl b
    ld hl, sp+$15
    ld a, [hl+]
    ld h, [hl]
    ld l, a
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
    ld a, c
    sub $2e
    jp nz, Jump_007_6f29

    or b
    jp nz, Jump_007_6f29

    jr jr_007_6f2c

Jump_007_6f29:
    jp Jump_007_6fe8


jr_007_6f2c:
    ld hl, sp+$0d
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec bc
    dec bc
    sla c
    rl b
    ld hl, sp+$15
    ld a, [hl+]
    ld h, [hl]
    ld l, a
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
    ld a, c
    sub $2e
    jp nz, Jump_007_6f52

    or b
    jp nz, Jump_007_6f52

    jr jr_007_6f55

Jump_007_6f52:
    jp Jump_007_6fe8


Jump_007_6f55:
jr_007_6f55:
    ld hl, sp+$0d
    ld c, [hl]
    inc hl
    ld b, [hl]
    sla c
    rl b
    ld hl, sp+$15
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0014
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$13
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_007_6f85:
    ld hl, sp+$13
    ld a, [hl]
    sub $0b
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_007_6fcb

    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$13
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$13
    ld d, h
    ld e, l
    ld hl, sp+$0d
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp nc, Jump_007_6fb9

    ld hl, sp+$02
    ld [hl], $2e
    jp Jump_007_6fbd


Jump_007_6fb9:
    ld hl, sp+$02
    ld [hl], $20

Jump_007_6fbd:
    ld hl, sp+$02
    ld a, [hl]
    ld [bc], a
    ld hl, sp+$13
    inc [hl]
    jr nz, jr_007_6fc8

    inc hl
    inc [hl]

jr_007_6fc8:
    jp Jump_007_6f85


Jump_007_6fcb:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$13
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$19
    ld a, [hl]
    or $20
    ld [bc], a
    ld e, $00
    jp Jump_007_73c0


Jump_007_6fe8:
    ld hl, sp+$0d
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e

Jump_007_6ff0:
    ld hl, sp+$00
    ld a, [hl+]
    or [hl]
    jp z, Jump_007_7048

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec bc
    sla c
    rl b
    ld hl, sp+$15
    ld a, [hl+]
    ld h, [hl]
    ld l, a
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
    ld hl, sp+$17
    ld [hl], c
    inc hl
    ld [hl], b
    dec hl
    ld a, [hl]
    sub $20
    jp nz, Jump_007_7021

    inc hl
    ld a, [hl]
    or a
    jp z, Jump_007_7034

Jump_007_7021:
    ld hl, sp+$17
    ld a, [hl]
    sub $2e
    jp nz, Jump_007_7031

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_7031

    jr jr_007_7034

Jump_007_7031:
    jp Jump_007_7048


Jump_007_7034:
jr_007_7034:
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
    ld e, [hl]
    ld hl, sp+$0d
    ld [hl+], a
    ld [hl], e
    jp Jump_007_6ff0


Jump_007_7048:
    ld hl, sp+$00
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0d
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$00
    ld a, [hl+]
    or [hl]
    jp nz, Jump_007_705c

    ld e, $06
    jp Jump_007_73c0


Jump_007_705c:
    ld hl, sp+$00
    ld c, [hl]
    inc hl
    ld b, [hl]
    sla c
    rl b
    ld hl, sp+$15
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0014
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld a, $0b
    push af
    inc sp
    ld hl, $0020
    push hl
    push bc
    call MemSet8_B7
    add sp, $05
    ld hl, sp+$0f
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$02
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_007_70a7:
    ld hl, sp+$02
    ld c, [hl]
    inc hl
    ld b, [hl]
    sla c
    rl b
    ld hl, sp+$15
    ld a, [hl+]
    ld h, [hl]
    ld l, a
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
    ld a, c
    sub $20
    jp nz, Jump_007_70c9

    or b
    jp z, Jump_007_70d8

Jump_007_70c9:
    ld a, c
    sub $2e
    jp nz, Jump_007_70d5

    or b
    jp nz, Jump_007_70d5

    jr jr_007_70d8

Jump_007_70d5:
    jp Jump_007_70ea


Jump_007_70d8:
jr_007_70d8:
    ld hl, sp+$02
    inc [hl]
    jr nz, jr_007_70df

    inc hl
    inc [hl]

jr_007_70df:
    ld hl, sp+$02
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0f
    ld [hl+], a
    ld [hl], e
    jp Jump_007_70a7


Jump_007_70ea:
    ld hl, sp+$02
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0f
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$02
    ld a, [hl+]
    or [hl]
    jp z, Jump_007_70ff

    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a

Jump_007_70ff:
    ld hl, sp+$0d
    ld a, [hl+]
    or [hl]
    jp z, Jump_007_7143

    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0001
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    ld c, [hl]
    inc hl
    ld b, [hl]
    sla c
    rl b
    ld hl, sp+$15
    ld a, [hl+]
    ld h, [hl]
    ld l, a
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
    ld a, c
    sub $2e
    jp nz, Jump_007_7136

    or b
    jp z, Jump_007_7143

Jump_007_7136:
    ld hl, sp+$02
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$0d
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_007_70ff


Jump_007_7143:
    ld hl, sp+$13
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$1a
    ld [hl], $00
    ld hl, sp+$11
    ld [hl], $08
    inc hl
    ld [hl], $00

Jump_007_7155:
    ld hl, sp+$0f
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_007_7160

    inc hl
    inc [hl]

jr_007_7160:
    sla c
    rl b
    ld hl, sp+$15
    ld a, [hl+]
    ld h, [hl]
    ld l, a
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
    ld hl, sp+$17
    ld [hl], c
    inc hl
    ld [hl], b
    dec hl
    ld a, [hl+]
    or [hl]
    jp z, Jump_007_731f

    dec hl
    ld a, [hl]
    sub $20
    jp nz, Jump_007_718b

    inc hl
    ld a, [hl]
    or a
    jp z, Jump_007_71b0

Jump_007_718b:
    ld hl, sp+$17
    ld a, [hl]
    sub $2e
    jp nz, Jump_007_719b

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_719b

    jr jr_007_719e

Jump_007_719b:
    jp Jump_007_71b9


jr_007_719e:
    ld hl, sp+$0f
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, Jump_007_71b0

    ld hl, sp+$10
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp z, Jump_007_71b9

Jump_007_71b0:
    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a
    jp Jump_007_7155


Jump_007_71b9:
    ld hl, sp+$13
    ld d, h
    ld e, l
    dec hl
    dec hl
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp nc, Jump_007_71df

    ld hl, sp+$0f
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, Jump_007_71dc

    ld hl, sp+$10
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, Jump_007_71dc

    jr jr_007_71df

Jump_007_71dc:
    jp Jump_007_7240


Jump_007_71df:
jr_007_71df:
    ld hl, sp+$11
    ld a, [hl]
    sub $0b
    jp nz, Jump_007_71ef

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_71ef

    jr jr_007_71f2

Jump_007_71ef:
    jp Jump_007_71fb


jr_007_71f2:
    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a
    jp Jump_007_731f


Jump_007_71fb:
    ld hl, sp+$0f
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, Jump_007_720d

    ld hl, sp+$10
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp z, Jump_007_7213

Jump_007_720d:
    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a

Jump_007_7213:
    ld hl, sp+$0d
    ld d, h
    ld e, l
    inc hl
    inc hl
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp c, Jump_007_731f

    ld hl, sp+$0d
    ld a, [hl+]
    ld e, [hl]
    inc hl
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$13
    ld [hl], $08
    inc hl
    ld [hl], $00
    ld hl, sp+$11
    ld [hl], $0b
    inc hl
    ld [hl], $00
    ld hl, sp+$1a
    sla [hl]
    sla [hl]
    jp Jump_007_7155


Jump_007_7240:
    ld hl, sp+$17
    ld a, [hl]
    sub $80
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_007_7281

    ld hl, $0000
    push hl
    ld hl, sp+$19
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call MapCp437
    add sp, $04
    ld b, d
    ld c, e
    ld hl, sp+$17
    ld [hl], c
    inc hl
    ld [hl], b
    dec hl
    ld a, [hl+]
    or [hl]
    jp z, Jump_007_727b

    dec hl
    ld c, [hl]
    ld a, c
    add $80
    add $81
    ld c, a
    ld a, $40
    adc $00
    ld b, a
    ld a, [bc]
    ld c, a
    ld [hl], c
    inc hl
    ld [hl], $00

Jump_007_727b:
    ld hl, sp+$19
    ld a, [hl]
    or $02
    ld [hl], a

Jump_007_7281:
    ld hl, sp+$17
    ld a, [hl+]
    or [hl]
    jp z, Jump_007_729d

    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $73cc
    push hl
    call Clone_0941a8_B7
    add sp, $04
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, Jump_007_72ac

Jump_007_729d:
    ld hl, sp+$17
    ld [hl], $5f
    inc hl
    ld [hl], $00
    inc hl
    ld a, [hl]
    or $03
    ld [hl], a
    jp Jump_007_72fa


Jump_007_72ac:
    ld hl, sp+$17
    ld a, [hl]
    sub $41
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_007_72cc

    ld a, $5a
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp c, Jump_007_72cc

    inc hl
    inc hl
    ld a, [hl]
    or $02
    ld [hl], a
    jp Jump_007_72fa


Jump_007_72cc:
    ld hl, sp+$17
    ld a, [hl]
    sub $61
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_007_72fa

    ld a, $7a
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp c, Jump_007_72fa

    inc hl
    inc hl
    ld a, [hl]
    or $01
    ld [hl], a
    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0020
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$18
    ld [hl-], a
    ld [hl], e

Jump_007_72fa:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    inc hl
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld hl, sp+$13
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_007_7310

    inc hl
    inc [hl]

jr_007_7310:
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$17
    ld a, [hl]
    ld [bc], a
    jp Jump_007_7155


Jump_007_731f:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    dec hl
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl-], a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $e5
    jp nz, Jump_007_7336

    jr jr_007_7339

Jump_007_7336:
    jp Jump_007_7341


jr_007_7339:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $05
    ld [de], a

Jump_007_7341:
    ld hl, sp+$11
    ld a, [hl]
    sub $08
    jp nz, Jump_007_7351

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_7351

    jr jr_007_7354

Jump_007_7351:
    jp Jump_007_735a


jr_007_7354:
    ld hl, sp+$1a
    sla [hl]
    sla [hl]

Jump_007_735a:
    ld hl, sp+$1a
    ld a, [hl]
    and $0c
    ld c, a
    sub $0c
    jp z, Jump_007_7375

    ld hl, sp+$1a
    ld a, [hl]
    and $03
    ld b, a
    sub $03
    jp nz, Jump_007_7372

    jr jr_007_7375

Jump_007_7372:
    jp Jump_007_737b


Jump_007_7375:
jr_007_7375:
    ld hl, sp+$19
    ld a, [hl]
    or $02
    ld [hl], a

Jump_007_737b:
    ld hl, sp+$19
    ld a, [hl]
    and $02
    jr nz, jr_007_7385

    jp Jump_007_7388


jr_007_7385:
    jp Jump_007_73af


Jump_007_7388:
    ld hl, sp+$1a
    ld a, [hl]
    and $03
    ld b, a
    sub $01
    jp nz, Jump_007_7395

    jr jr_007_7398

Jump_007_7395:
    jp Jump_007_739e


jr_007_7398:
    ld hl, sp+$19
    ld a, [hl]
    or $10
    ld [hl], a

Jump_007_739e:
    ld a, c
    sub $04
    jp nz, Jump_007_73a6

    jr jr_007_73a9

Jump_007_73a6:
    jp Jump_007_73af


jr_007_73a9:
    ld hl, sp+$19
    ld a, [hl]
    or $08
    ld [hl], a

Jump_007_73af:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000b
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$19
    ld a, [hl]
    ld [bc], a
    ld e, $00

Jump_007_73c0:
    add sp, $1b
    ret


    ld [hl+], a
    ld a, [hl+]
    ld a, [hl-]
    inc a
    ld a, $3f
    ld a, h
    ld a, a
    nop
    dec hl
    inc l
    dec sp
    dec a
    ld e, e
    ld e, l
    nop
    add sp, -$0b
    ld hl, sp+$0f
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, [bc]
    ld hl, sp+$06
    ld [hl], a
    sub $2f
    jp z, Jump_007_73f0

    ld hl, sp+$06
    ld a, [hl]
    sub $5c
    jp nz, Jump_007_73ed

    jr jr_007_73f0

Jump_007_73ed:
    jp Jump_007_7419


Jump_007_73f0:
jr_007_73f0:
    ld hl, $0001
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$0f
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$0d
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, $0006
    add hl, bc
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
    jp Jump_007_7457


Jump_007_7419:
    ld hl, sp+$0d
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, $0006
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld e, c
    ld d, b
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, $0012
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
    ld [hl+], a
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

Jump_007_7457:
    ld hl, sp+$0f
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, [bc]
    ld c, a
    rla
    sbc a
    ld b, a
    ld a, c
    sub $20
    ld a, b
    sbc $00
    jp nc, Jump_007_7494

    ld hl, $0000
    push hl
    ld hl, sp+$0f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_0954db_B7
    add sp, $04
    ld c, e
    ld hl, sp+$0a
    ld [hl], c
    ld hl, sp+$0d
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, $0012
    add hl, bc
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    jp Jump_007_75d9


Jump_007_7494:
    ld hl, sp+$0f
    ld c, l
    ld b, h
    push bc
    ld hl, sp+$0f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_096c3e_B7
    add sp, $04
    ld c, e
    ld hl, sp+$0a
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_007_75d9

    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_09644b_B7
    add sp, $02
    ld c, e
    ld hl, sp+$0a
    ld [hl], c
    ld hl, sp+$0d
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0014
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
    ld l, $0b
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, sp+$07
    ld [hl], c
    xor a
    ld hl, sp+$0a
    or [hl]
    jp z, Jump_007_7550

    ld a, [hl]
    sub $04
    jp nz, Jump_007_74ee

    jr jr_007_74f1

Jump_007_74ee:
    jp Jump_007_75d9


jr_007_74f1:
    ld hl, sp+$07
    ld a, [hl]
    and $20
    jr nz, jr_007_74fb

    jp Jump_007_753c


jr_007_74fb:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
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
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0012
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
    ld hl, sp+$07
    ld a, [hl]
    and $04
    jr nz, jr_007_7535

    jp Jump_007_7494


jr_007_7535:
    ld hl, sp+$0a
    ld [hl], $00
    jp Jump_007_75d9


Jump_007_753c:
    ld hl, sp+$07
    ld a, [hl]
    and $04
    jr nz, jr_007_7546

    jp Jump_007_7549


jr_007_7546:
    jp Jump_007_75d9


Jump_007_7549:
    ld hl, sp+$0a
    ld [hl], $05
    jp Jump_007_75d9


Jump_007_7550:
    ld hl, sp+$07
    ld a, [hl]
    and $04
    jr nz, jr_007_755a

    jp Jump_007_755d


jr_007_755a:
    jp Jump_007_75d9


Jump_007_755d:
    ld hl, sp+$00
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
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], b
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
    jr nz, jr_007_7587

    jp Jump_007_758a


jr_007_7587:
    jp Jump_007_7591


Jump_007_758a:
    ld hl, sp+$0a
    ld [hl], $05
    jp Jump_007_75d9


Jump_007_7591:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call Clone_095d72_B7
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
    jp Jump_007_7494


Jump_007_75d9:
    ld hl, sp+$0a
    ld e, [hl]
    add sp, $0b
    ret


    add sp, -$0b
    ld hl, sp+$07
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    ld hl, sp+$0d
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$03
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    inc hl
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl-], a
    ld a, [hl+]
    or [hl]
    jp z, Jump_007_76ae

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b

Jump_007_7608:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    inc hl
    ld [hl], a
    ld c, a
    ld a, [hl]
    rla
    sbc a
    ld b, a
    ld a, c
    sub $20
    ld a, b
    sbc $00
    jp c, Jump_007_762e

    ld a, [hl]
    sub $3a
    jp z, Jump_007_762e

    ld hl, sp+$00
    inc [hl]
    jr nz, jr_007_762b

    inc hl
    inc [hl]

jr_007_762b:
    jp Jump_007_7608


Jump_007_762e:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $3a
    jp nz, Jump_007_763c

    jr jr_007_763f

Jump_007_763c:
    jp Jump_007_76a7


jr_007_763f:
    ld hl, sp+$05
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$09
    ld [hl], c
    inc hl
    ld [hl], b
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    dec hl
    inc [hl]
    jr nz, jr_007_7655

    inc hl
    inc [hl]

jr_007_7655:
    ld a, c
    rla
    sbc a
    ld b, a
    ld a, c
    add $d0
    ld c, a
    ld a, b
    adc $ff
    ld b, a
    ld a, c
    sub $0a
    ld a, b
    sbc $00
    jp nc, Jump_007_769f

    ld hl, sp+$09
    ld a, [hl]
    ld hl, sp+$00
    sub [hl]
    jp nz, Jump_007_767e

    ld hl, sp+$0a
    ld a, [hl]
    ld hl, sp+$01
    sub [hl]
    jp nz, Jump_007_767e

    jr jr_007_7681

Jump_007_767e:
    jp Jump_007_769f


jr_007_7681:
    ld a, c
    sub $01
    ld a, b
    sbc $00
    jp nc, Jump_007_769f

    ld hl, sp+$07
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$00
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a

Jump_007_769f:
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    jp Jump_007_76b3


Jump_007_76a7:
    ld hl, sp+$07
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_007_76ae:
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]

Jump_007_76b3:
    add sp, $0b
    ret


Clone_056d96_B7::
    push af
    push af
    ld hl, sp+$06
    ld a, [hl+]
    or [hl]
    jp z, Jump_007_772f

    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    or c
    jp z, Jump_007_772f

    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld a, [bc]
    or a
    jp z, Jump_007_772f

    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$02
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl-], a
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
    ld [hl], a
    ld hl, sp+$06
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
    ld hl, sp+$00
    ld a, [hl]
    sub c
    jp nz, Jump_007_7714

    inc hl
    ld a, [hl]
    sub b
    jp nz, Jump_007_7714

    jr jr_007_7717

Jump_007_7714:
    jp Jump_007_772f


jr_007_7717:
    ld hl, sp+$02
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, [bc]
    ld c, a
    push af
    inc sp
    call DiskStatus
    add sp, $01
    ld c, e
    ld a, c
    and $01
    jr nz, jr_007_772f

    jp Jump_007_7734


Jump_007_772f:
jr_007_772f:
    ld e, $09
    jp Jump_007_7736


Jump_007_7734:
    ld e, $00

Jump_007_7736:
    add sp, $04
    ret


    add sp, -$35
    ld hl, sp+$3d
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$27
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$41
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$1e
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
    ld hl, sp+$3b
    ld c, [hl]
    inc hl
    ld b, [hl]
    push bc
    call Clone_056d96_B7
    add sp, $02
    ld c, e
    xor a
    or c
    jp z, Jump_007_776d

    ld e, c
    jp Jump_007_7f0c


Jump_007_776d:
    ld hl, sp+$3b
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$24
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0005
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$22
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld c, a
    or a
    jp z, Jump_007_778e

    ld e, c
    jp Jump_007_7f0c


Jump_007_778e:
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$20
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld c, a
    and $02
    jr nz, jr_007_77a7

    jp Jump_007_77aa


jr_007_77a7:
    jp Jump_007_77af


Jump_007_77aa:
    ld e, $07
    jp Jump_007_7f0c


Jump_007_77af:
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$1c
    ld [hl+], a
    ld [hl], d
    ld e, a
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
    ld hl, sp+$3f
    ld a, [hl]
    ld hl, sp+$14
    ld [hl], a
    ld hl, sp+$40
    ld a, [hl]
    ld hl, sp+$15
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$14
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$1c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$18
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
    ld d, h
    ld e, l
    ld hl, sp+$18
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
    jp nc, Jump_007_781a

    ld hl, sp+$3f
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_007_781a:
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0016
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0012
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$14
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000e
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$18
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000a
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$12
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0020
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$10
    ld [hl+], a
    ld [hl], d

Jump_007_7865:
    ld hl, sp+$3f
    ld a, [hl+]
    or [hl]
    jp z, Jump_007_7eac

    ld hl, sp+$1c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$0c
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
    ld hl, sp+$0c
    ld a, [hl]
    or a
    jr nz, jr_007_788d

    inc hl
    ld a, [hl]
    and $01
    jr nz, jr_007_788d

    jp Jump_007_7890


jr_007_788d:
    jp Jump_007_7d81


Jump_007_7890:
    ld a, $09
    push af
    inc sp
    ld hl, sp+$0f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shr
    add sp, $05
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
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$04
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl-], a
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    inc bc
    ld a, [bc]
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
    ld hl, sp+$06
    and [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$07
    and [hl]
    ld hl, sp+$01
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$08
    and [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$09
    and [hl]
    ld hl, sp+$03
    ld [hl], a
    ld hl, sp+$00
    ld a, [hl]
    ld hl, sp+$26
    ld [hl], a
    or a
    jp nz, Jump_007_7a3e

    ld hl, sp+$0c
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_007_7952

    ld hl, sp+$18
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$31
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
    ld hl, sp+$31
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_007_7995

    ld hl, $0000
    push hl
    ld hl, $0000
    push hl
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_095139_B7
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
    ld d, h
    ld e, l
    ld hl, sp+$31
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
    jp Jump_007_7995


Jump_007_7952:
    ld hl, sp+$14
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
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Clone_095139_B7
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
    ld d, h
    ld e, l
    ld hl, sp+$31
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

Jump_007_7995:
    ld hl, sp+$31
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, Jump_007_7eac

    ld hl, sp+$31
    ld a, [hl]
    sub $01
    jp nz, Jump_007_79bc

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_79bc

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_79bc

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_007_79bc

    jr jr_007_79bf

Jump_007_79bc:
    jp Jump_007_79cc


jr_007_79bf:
    ld hl, sp+$22
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $02
    ld [de], a
    ld e, $02
    jp Jump_007_7f0c


Jump_007_79cc:
    ld hl, sp+$31
    ld a, [hl]
    inc a
    jp nz, Jump_007_79e7

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_79e7

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_79e7

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_007_79e7

    jr jr_007_79ea

Jump_007_79e7:
    jp Jump_007_79f7


jr_007_79ea:
    ld hl, sp+$22
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    ld e, $01
    jp Jump_007_7f0c


Jump_007_79f7:
    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$31
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
    ld hl, sp+$18
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
    ld hl, sp+$00
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_007_7a3e

    ld hl, sp+$18
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$31
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

Jump_007_7a3e:
    ld hl, sp+$20
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $40
    jr nz, jr_007_7a4c

    jp Jump_007_7ab9


jr_007_7a4c:
    ld hl, sp+$0a
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
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0020
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    inc bc
    ld a, [bc]
    ld c, a
    ld hl, $0001
    push hl
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld a, c
    push af
    inc sp
    call FarCall_02_41d5
    add sp, $09
    ld c, e
    xor a
    or c
    jp z, Jump_007_7aab

    ld hl, sp+$22
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    ld e, $01
    jp Jump_007_7f0c


Jump_007_7aab:
    ld hl, sp+$20
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $bf
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a

Jump_007_7ab9:
    ld hl, sp+$14
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
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
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
    push bc
    call Clust2Sect_B7
    add sp, $06
    push hl
    ld hl, sp+$2f
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$2d
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_007_7b0a

    ld hl, sp+$22
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $02
    ld [de], a
    ld e, $02
    jp Jump_007_7f0c


Jump_007_7b0a:
    ld hl, sp+$26
    ld a, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$2d
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
    ld hl, sp+$30
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
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
    ld hl, sp+$30
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$40
    ld a, [hl]
    rrca
    and $7f
    ld hl, sp+$29
    ld [hl+], a
    ld [hl], $00
    dec hl
    ld a, [hl+]
    or [hl]
    jp z, Jump_007_7ca9

    ld hl, sp+$26
    ld a, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], $00
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$29
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    inc bc
    inc bc
    ld a, [bc]
    ld hl, sp+$06
    ld [hl], a
    ld c, a
    ld b, $00
    ld a, c
    dec hl
    dec hl
    sub [hl]
    ld a, b
    inc hl
    sbc [hl]
    jp nc, Jump_007_7b97

    inc hl
    ld c, [hl]
    ld b, $00
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    sub e
    ld e, a
    ld a, b
    sbc d
    ld b, a
    ld c, e
    ld hl, sp+$29
    ld [hl], c
    inc hl
    ld [hl], b

Jump_007_7b97:
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    inc bc
    ld a, [bc]
    ld c, a
    ld hl, sp+$29
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$31
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$31
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$2d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld a, c
    push af
    inc sp
    call FarCall_02_41d5
    add sp, $09
    ld c, e
    xor a
    or c
    jp z, Jump_007_7bd7

    ld hl, sp+$22
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    ld e, $01
    jp Jump_007_7f0c


Jump_007_7bd7:
    ld hl, sp+$0a
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
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$2d
    sub [hl]
    ld e, a
    ld a, d
    inc hl
    sbc [hl]
    push af
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$31
    pop af
    ld a, e
    sbc [hl]
    ld e, a
    ld a, d
    inc hl
    sbc [hl]
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$29
    ld a, [hl]
    ld hl, sp+$06
    ld [hl], a
    ld hl, sp+$2a
    ld a, [hl]
    ld hl, sp+$07
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$00
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
    jp nc, Jump_007_7c97

    ld a, $09
    push af
    inc sp
    ld hl, sp+$03
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
    ld hl, sp+$27
    ld a, [hl]
    ld hl, sp+$00
    add [hl]
    ld hl, sp+$28
    ld hl, sp+$00
    push bc
    ld c, a
    ld hl, sp+$28
    ld a, [hl]
    ld b, a
    ld a, c
    ld hl, sp+$00
    ld [hl], a
    ld a, b
    pop bc
    inc hl
    adc [hl]
    ld [hl], a
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0020
    add hl, de
    ld c, l
    ld b, h
    ld a, $00
    push af
    inc sp
    ld hl, sp+$01
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call MemCpy16_B7
    add sp, $05
    ld hl, sp+$20
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $bf
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a

Jump_007_7c97:
    ld hl, sp+$29
    ld a, [hl]
    ld hl, sp+$2c
    ld [hl], a
    ld hl, sp+$29
    ld a, [hl]
    add a
    ld hl, sp+$2c
    ld [hl-], a
    ld [hl], $00
    jp Jump_007_7e0d


Jump_007_7ca9:
    ld hl, sp+$0a
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
    ld hl, sp+$00
    ld a, [hl]
    ld hl, sp+$2d
    sub [hl]
    jp nz, Jump_007_7cdf

    ld hl, sp+$01
    ld a, [hl]
    ld hl, sp+$2e
    sub [hl]
    jp nz, Jump_007_7cdf

    ld hl, sp+$02
    ld a, [hl]
    ld hl, sp+$2f
    sub [hl]
    jp nz, Jump_007_7cdf

    ld hl, sp+$03
    ld a, [hl]
    ld hl, sp+$30
    sub [hl]
    jp z, Jump_007_7d6c

Jump_007_7cdf:
    ld hl, sp+$1c
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
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
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
    ld hl, sp+$00
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
    jp nc, Jump_007_7d6c

    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0020
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$04
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl-], a
    inc [hl]
    jr nz, jr_007_7d36

    inc hl
    inc [hl]

jr_007_7d36:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    dec hl
    ld [hl], a
    ld hl, $0001
    push hl
    ld hl, sp+$31
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$31
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    ld hl, sp+$0c
    ld a, [hl]
    push af
    inc sp
    call FarCall_02_4027
    add sp, $09
    ld c, e
    xor a
    or c
    jp z, Jump_007_7d6c

    ld hl, sp+$22
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    ld e, $01
    jp Jump_007_7f0c


Jump_007_7d6c:
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
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

Jump_007_7d81:
    ld hl, sp+$1c
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
    ld hl, sp+$00
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
    ld hl, sp+$2c
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$3f
    ld d, h
    ld e, l
    ld hl, sp+$2b
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp nc, Jump_007_7dbe

    ld hl, sp+$3f
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$2b
    ld [hl+], a
    ld [hl], e

Jump_007_7dbe:
    ld hl, sp+$2b
    ld a, [hl]
    ld hl, sp+$00
    ld [hl], a
    ld hl, sp+$1c
    ld e, [hl]
    inc hl
    ld d, [hl]
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
    ld [hl-], a
    dec hl
    ld a, [hl]
    and $01
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$10
    ld a, [hl]
    ld hl, sp+$06
    add [hl]
    ld hl, sp+$11
    ld c, a
    ld a, [hl]
    ld hl, sp+$07
    adc [hl]
    ld b, a
    ld hl, sp+$00
    ld a, [hl]
    push af
    inc sp
    ld hl, sp+$28
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call MemCpy16_B7
    add sp, $05
    ld hl, sp+$20
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    or $40
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a

Jump_007_7e0d:
    ld hl, sp+$27
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$2b
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$27
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$1c
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
    ld hl, sp+$2b
    ld a, [hl]
    ld hl, sp+$06
    ld [hl], a
    ld hl, sp+$2c
    ld a, [hl]
    ld hl, sp+$07
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$06
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$0a
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$1c
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
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$2b
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a
    ld hl, sp+$3f
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$2b
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$40
    ld [hl-], a
    ld [hl], e
    jp Jump_007_7865


Jump_007_7eac:
    ld hl, sp+$1c
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
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
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
    jp nc, Jump_007_7efc

    ld hl, sp+$12
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

Jump_007_7efc:
    ld hl, sp+$20
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    or $20
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld e, $00

Jump_007_7f0c:
    add sp, $35
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
