; Disassembly of "kernel.gb"
; This file was created with:
; mgbdis v3.0 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $003", ROMX[$4000], BANK[$3]

; [ezgb]
; MemCpy16_B3: copy (count/2) little-endian words dest←src while count≥2.
; Bank-local FatFs mem helper. Canonical MemCpy16_B9 at 09:4001; B6/B7 siblings.

MemCpy16_B3::
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

Jump_003_401b:
    ld hl, sp+$00
    ld a, [hl]
    sub $02
    jp c, Jump_003_4059

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
    jp Jump_003_401b


Jump_003_4059:
    ld hl, sp+$00
    ld c, [hl]

Jump_003_405c:
    ld b, c
    dec c
    xor a
    or b
    jp z, Jump_003_407e

    ld hl, sp+$01
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    dec hl
    inc [hl]
    jr nz, jr_003_406f

    inc hl
    inc [hl]

jr_003_406f:
    ld hl, sp+$03
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_003_407b

    inc hl
    inc [hl]

jr_003_407b:
    jp Jump_003_405c


Jump_003_407e:
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

; [ezgb]
; MemSet8_B3: fill dest with byte, 8-bit count (FatFs mem_set). B5/B6/B7 siblings;
; bank9 has MemSet16_B9 ($4102) with a 16-bit count instead.

MemSet8_B3::
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

Jump_003_410f:
    ld b, c
    dec c
    xor a
    or b
    jp z, Jump_003_4128

    ld hl, sp+$06
    ld a, [hl]
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_003_4125

    inc hl
    inc [hl]

jr_003_4125:
    jp Jump_003_410f


Jump_003_4128:
    add sp, $02
    ret


MemCmp_B3::
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

Jump_003_414c:
    ld hl, sp+$02
    ld b, [hl]
    dec [hl]
    xor a
    or b
    jp z, Jump_003_418d

    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    dec hl
    inc [hl]
    jr nz, jr_003_4162

    inc hl
    inc [hl]

jr_003_4162:
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
    jr nz, jr_003_4175

    inc hl
    inc [hl]

jr_003_4175:
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
    jp z, Jump_003_414c

Jump_003_418d:
    ld hl, sp+$03
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $09
    ret


MemChr_B3::
    push af
    ld hl, sp+$04
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e

Jump_003_419e:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    or a
    jp z, Jump_003_41c4

    ld a, c
    rla
    sbc a
    ld b, a
    ld a, c
    ld hl, sp+$06
    sub [hl]
    jp nz, Jump_003_41ba

    ld a, b
    inc hl
    sub [hl]
    jp z, Jump_003_41c4

Jump_003_41ba:
    ld hl, sp+$00
    inc [hl]
    jr nz, jr_003_41c1

    inc hl
    inc [hl]

jr_003_41c1:
    jp Jump_003_419e


Jump_003_41c4:
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
; SyncWindow_B3: same as SyncWindow_B9 (09:41e5). Bank-local FatFs copy.

SyncWindow_B3::
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
    jp z, Jump_003_4365

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
    call FarCallDiskWrite
    add sp, $09
    ld c, e
    xor a
    or c
    jp z, Jump_003_425a

    ld hl, sp+$10
    ld [hl], $01
    jp Jump_003_4365


Jump_003_425a:
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
    jp nc, Jump_003_4365

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

Jump_003_42e2:
    ld hl, sp+$00
    ld a, [hl]
    sub $02
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_003_4365

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
    call FarCallDiskWrite
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
    jp Jump_003_42e2


Jump_003_4365:
    ld hl, sp+$10
    ld e, [hl]
    add sp, $15
    ret


; [ezgb]
; MoveWindow_B3: same as MoveWindow_B9 (09:437e). Byte-identical to MoveWindow_B7;
; banks 3 and 7 share a ~4KB identical block from $4000 (linked FS + callers).

MoveWindow_B3::
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
    jp nz, Jump_003_43b9

    ld hl, sp+$0e
    ld a, [hl]
    ld hl, sp+$01
    sub [hl]
    jp nz, Jump_003_43b9

    ld hl, sp+$0f
    ld a, [hl]
    ld hl, sp+$02
    sub [hl]
    jp nz, Jump_003_43b9

    ld hl, sp+$10
    ld a, [hl]
    ld hl, sp+$03
    sub [hl]
    jp z, Jump_003_442e

Jump_003_43b9:
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call SyncWindow_B3
    add sp, $02
    ld c, e
    ld hl, sp+$08
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_003_442e

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
    call FarCallDiskRead
    add sp, $09
    ld c, e
    xor a
    or c
    jp z, Jump_003_4419

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

Jump_003_4419:
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

Jump_003_442e:
    ld hl, sp+$08
    ld e, [hl]
    add sp, $09
    ret


; [ezgb]
; SyncFs_B3(fs): same as SyncFs_B9 (09:4447). Bank-local FatFs sync_fs copy.

SyncFs_B3::
    add sp, -$11
    ld hl, sp+$13
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call SyncWindow_B3
    add sp, $02
    ld c, e
    ld hl, sp+$10
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_003_4602

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
    jp nz, Jump_003_445f

    jr jr_003_4462

Jump_003_445f:
    jp Jump_003_45e0


jr_003_4462:
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
    jp nz, Jump_003_447b

    jr jr_003_447e

Jump_003_447b:
    jp Jump_003_45e0


jr_003_447e:
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
    call MemSet8_B3
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
    jr nz, jr_003_459d

    inc hl
    inc [hl]
    jr nz, jr_003_459d

    inc hl
    inc [hl]
    jr nz, jr_003_459d

    inc hl
    inc [hl]

jr_003_459d:
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
    call FarCallDiskWrite
    add sp, $09
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a

Jump_003_45e0:
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
    jp z, Jump_003_4602

    ld hl, sp+$10
    ld [hl], $01

Jump_003_4602:
    ld hl, sp+$10
    ld e, [hl]
    add sp, $11
    ret


; [ezgb]
; Clust2Sect_B3: FatFs clust2sect(fs, clst). clst-=2; reject if >= n_fatent-2;
; return clst*csize + database via U32Mul. Canonical Clust2Sect_B9 at 09:4614.

Clust2Sect_B3::
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
    jp c, Jump_003_4687

    ld de, $0000
    ld hl, $0000
    jp Jump_003_4704


Jump_003_4687:
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

Jump_003_4704:
    add sp, $0a
    ret


; [ezgb]
; GetFat_B3: FatFs get_fat(fs, clst). Rejects clst<2 or clst>=fs->n_fatent (+$16);
; dispatches FAT12/16/32 via fs_type jump table (FAT12 uses clst+clst/2).
; Canonical GetFat_B9 at 09:4713; also GetFat_B6/$4534, GetFat_B7/$4707.

GetFat_B3::
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
    jp c, Jump_003_4755

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
    jp c, Jump_003_4761

Jump_003_4755:
    ld hl, sp+$08
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    jp Jump_003_4adf


Jump_003_4761:
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
    jp c, Jump_003_4ad6

    ld a, $03
    sub c
    jp c, Jump_003_4ad6

    dec c
    ld e, c
    ld d, $00
    ld hl, $478a
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp Jump_003_4793


    jp Jump_003_4913


    jp Jump_003_49e9


Jump_003_4793:
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
    call MoveWindow_B3
    add sp, $06
    ld c, e
    xor a
    or c
    jp nz, Jump_003_4adf

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
    jr nz, jr_003_4833

    inc hl
    inc [hl]

jr_003_4833:
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
    call MoveWindow_B3
    add sp, $06
    ld c, e
    xor a
    or c
    jp nz, Jump_003_4adf

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
    jr nz, jr_003_48ec

    jp Jump_003_48fd


jr_003_48ec:
    ld hl, sp+$12
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, $04

jr_003_48f3:
    srl b
    rr c
    dec a
    jr nz, jr_003_48f3

    jp Jump_003_4905


Jump_003_48fd:
    ld hl, sp+$12
    ld c, [hl]
    inc hl
    ld a, [hl]
    and $0f
    ld b, a

Jump_003_4905:
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp Jump_003_4adf


Jump_003_4913:
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
    call MoveWindow_B3
    add sp, $06
    ld c, e
    xor a
    or c
    jp nz, Jump_003_4adf

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
    jp Jump_003_4adf


Jump_003_49e9:
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
    call MoveWindow_B3
    add sp, $06
    ld c, e
    xor a
    or c
    jp nz, Jump_003_4adf

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
    jp Jump_003_4adf


Jump_003_4ad6:
    ld hl, sp+$08
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

Jump_003_4adf:
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


PutFat_B3::
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
    jp c, Jump_003_4b39

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
    jp c, Jump_003_4b40

Jump_003_4b39:
    ld hl, sp+$14
    ld [hl], $02
    jp Jump_003_4f82


Jump_003_4b40:
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    sub $01
    jp c, Jump_003_4f7e

    ld a, $03
    sub b
    jp c, Jump_003_4f7e

    dec b
    ld e, b
    ld d, $00
    ld hl, $4b5d
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp Jump_003_4b66


    jp Jump_003_4d76


    jp Jump_003_4e58


Jump_003_4b66:
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
    call MoveWindow_B3
    add sp, $06
    ld b, e
    ld hl, sp+$14
    ld [hl], b
    xor a
    or [hl]
    jp nz, Jump_003_4f82

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
    jr nz, jr_003_4c0a

    inc hl
    inc [hl]

jr_003_4c0a:
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
    jp z, Jump_003_4c57

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
    jp Jump_003_4c5a


Jump_003_4c57:
    ld hl, sp+$21
    ld b, [hl]

Jump_003_4c5a:
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
    call MoveWindow_B3
    add sp, $06
    ld b, e
    ld hl, sp+$14
    ld [hl], b
    xor a
    or [hl]
    jp nz, Jump_003_4f82

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
    jp z, Jump_003_4d27

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
    jp Jump_003_4d5e


Jump_003_4d27:
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

Jump_003_4d5e:
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
    jp Jump_003_4f82


Jump_003_4d76:
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
    call MoveWindow_B3
    add sp, $06
    ld c, e
    ld hl, sp+$14
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_003_4f82

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
    jp Jump_003_4f82


Jump_003_4e58:
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
    call MoveWindow_B3
    add sp, $06
    ld c, e
    ld hl, sp+$14
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_003_4f82

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
    jp Jump_003_4f82


Jump_003_4f7e:
    ld hl, sp+$14
    ld [hl], $02

Jump_003_4f82:
    ld hl, sp+$14
    ld e, [hl]
    add sp, $19
    ret


; [ezgb]
; RemoveChain_B3(fs, clst, pclst): FatFs remove_chain. Frame -$0e; walk FAT from fs+clst toward clst.
; clst<2 → Jump_003_4fd9 B=$02; start cluster > clst → Jump_003_4fde B=$00 else Jump_003_4fd9.
; Jump_003_4fe0 loop: walker≥clst → Jump_003_5129 ret B; GetFat_B3; FAT zero → Jump_003_5129.
; FAT==1 → jr_003_5057 B=$02 else Jump_003_5054→Jump_003_505c; inc FAT wraps → jr_003_507a B=$01 else Jump_003_5077→Jump_003_507f.
; Jump_003_507f: PutFat_B3 free slot; err → Jump_003_5129; advance walker — inc hits 0 → Jump_003_5115 else Jump_003_50da (jr_003_50e9) + FA_DIRTY → Jump_003_4fe0.
; Jump_003_5115: stash final cluster@sp+$12 → Jump_003_4fe0; Jump_003_5129: ld e,B / add sp,$0e / ret.

RemoveChain_B3::
    add sp, -$0e
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
    jp c, Jump_003_4fd9

    ld hl, sp+$10
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
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld e, a
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
    ld d, h
    ld e, l
    ld hl, sp+$02
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
    jp c, Jump_003_4fde

Jump_003_4fd9:
    ld b, $02
    jp Jump_003_5129


Jump_003_4fde:
    ld b, $00

Jump_003_4fe0:
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
    ld hl, sp+$12
    ld d, h
    ld e, l
    ld hl, sp+$02
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
    jp nc, Jump_003_5129

    push bc
    ld hl, sp+$16
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$16
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call GetFat_B3
    add sp, $06
    push hl
    ld hl, sp+$0e
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    pop bc
    ld hl, sp+$0a
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, Jump_003_5129

    ld hl, sp+$0a
    ld a, [hl]
    sub $01
    jp nz, Jump_003_5054

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_5054

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_5054

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_5054

    jr jr_003_5057

Jump_003_5054:
    jp Jump_003_505c


jr_003_5057:
    ld b, $02
    jp Jump_003_5129


Jump_003_505c:
    ld hl, sp+$0a
    ld a, [hl]
    inc a
    jp nz, Jump_003_5077

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_5077

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_5077

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_5077

    jr jr_003_507a

Jump_003_5077:
    jp Jump_003_507f


jr_003_507a:
    ld b, $01
    jp Jump_003_5129


Jump_003_507f:
    ld hl, $0000
    push hl
    ld hl, $0000
    push hl
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
    ld hl, sp+$0e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call PutFat_B3
    add sp, $0a
    ld c, e
    ld b, c
    xor a
    or b
    jp nz, Jump_003_5129

    ld hl, sp+$06
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
    ld hl, sp+$02
    ld a, [hl]
    inc a
    jp nz, Jump_003_50da

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_50da

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_50da

    inc hl
    ld a, [hl]
    inc a
    jp z, Jump_003_5115

Jump_003_50da:
    ld hl, sp+$02
    inc [hl]
    jr nz, jr_003_50e9

    inc hl
    inc [hl]
    jr nz, jr_003_50e9

    inc hl
    inc [hl]
    jr nz, jr_003_50e9

    inc hl
    inc [hl]

jr_003_50e9:
    ld hl, sp+$00
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
    ld hl, $0005
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld c, a
    or $01
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a

Jump_003_5115:
    ld hl, sp+$0a
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
    jp Jump_003_4fe0


Jump_003_5129:
    ld e, b
    add sp, $0e
    ret


; [ezgb]
; CreateChain_B3(fs, clst, target): FatFs create_chain / cluster extend.
; clst!=0 Jump_003_51a3 GetFat_B3: clst<2 → Jump_003_54cc (1,0); Jump_003_51e2: clst==-1 jr_003_5200 else Jump_003_51fd/Jump_003_520c compare n_fatent (past Jump_003_5249 else Jump_003_54cc).
; clst==0: free_clst vs n_fatent; empty Jump_003_5197 clst=1; join Jump_003_525a copy state.
; Jump_003_525a alloc scan Jump_003_5294 (jr_003_52a3): hit end Jump_003_52e2 GetFat_B3; no free + scan done → Jump_003_54cc (0,0).
; Jump_003_533b/Jump_003_5357/Jump_003_535a/jr_003_535a EOF checks; Jump_003_5366 match jr_003_538f (0,0) else Jump_003_538c → Jump_003_5294.
; Jump_003_52e2 free slot Jump_003_5398 PutFat_B3 link; fail Jump_003_548e/Jump_003_5496/jr_003_5499/Jump_003_54a9 set FR_NO_FILESYSTEM.
; Jump_003_53ed: update fs free_clst/fatbase; Jump_003_5442 link + FA_DIRTY or Jump_003_54c3; Jump_003_54b2 store; Jump_003_54cc epilogue (add sp,$1b / ret).

CreateChain_B3::
    add sp, -$1b
    ld hl, sp+$1f
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_003_51a3

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
    jp z, Jump_003_5197

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
    jp c, Jump_003_525a

Jump_003_5197:
    ld hl, sp+$0f
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    jp Jump_003_525a


Jump_003_51a3:
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
    call GetFat_B3
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
    jp nc, Jump_003_51e2

    ld de, $0001
    ld hl, $0000
    jp Jump_003_54cc


Jump_003_51e2:
    ld hl, sp+$17
    ld a, [hl]
    inc a
    jp nz, Jump_003_51fd

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_51fd

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_51fd

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_51fd

    jr jr_003_5200

Jump_003_51fd:
    jp Jump_003_520c


jr_003_5200:
    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp Jump_003_54cc


Jump_003_520c:
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
    jp nc, Jump_003_5249

    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp Jump_003_54cc


Jump_003_5249:
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

Jump_003_525a:
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

Jump_003_5294:
    ld hl, sp+$13
    inc [hl]
    jr nz, jr_003_52a3

    inc hl
    inc [hl]
    jr nz, jr_003_52a3

    inc hl
    inc [hl]
    jr nz, jr_003_52a3

    inc hl
    inc [hl]

jr_003_52a3:
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
    jp c, Jump_003_52e2

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
    jp z, Jump_003_52e2

    ld de, $0000
    ld hl, $0000
    jp Jump_003_54cc


Jump_003_52e2:
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
    call GetFat_B3
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
    jp z, Jump_003_5398

    ld hl, sp+$17
    ld a, [hl]
    inc a
    jp nz, Jump_003_533b

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_533b

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_533b

    inc hl
    ld a, [hl]
    inc a
    jp z, Jump_003_535a

Jump_003_533b:
    ld hl, sp+$17
    ld a, [hl]
    sub $01
    jp nz, Jump_003_5357

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_5357

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_5357

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_5357

    jr jr_003_535a

Jump_003_5357:
    jp Jump_003_5366


Jump_003_535a:
jr_003_535a:
    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp Jump_003_54cc


Jump_003_5366:
    ld hl, sp+$13
    ld a, [hl]
    ld hl, sp+$0f
    sub [hl]
    jp nz, Jump_003_538c

    ld hl, sp+$14
    ld a, [hl]
    ld hl, sp+$10
    sub [hl]
    jp nz, Jump_003_538c

    ld hl, sp+$15
    ld a, [hl]
    ld hl, sp+$11
    sub [hl]
    jp nz, Jump_003_538c

    ld hl, sp+$16
    ld a, [hl]
    ld hl, sp+$12
    sub [hl]
    jp nz, Jump_003_538c

    jr jr_003_538f

Jump_003_538c:
    jp Jump_003_5294


jr_003_538f:
    ld de, $0000
    ld hl, $0000
    jp Jump_003_54cc


Jump_003_5398:
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
    call PutFat_B3
    add sp, $0a
    ld c, e
    xor a
    or c
    jp nz, Jump_003_53ed

    ld hl, sp+$1f
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, Jump_003_53ed

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
    call PutFat_B3
    add sp, $0a
    ld b, e
    ld c, b

Jump_003_53ed:
    xor a
    or c
    jp nz, Jump_003_548e

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
    jp nz, Jump_003_5442

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_5442

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_5442

    inc hl
    ld a, [hl]
    inc a
    jp z, Jump_003_54c3

Jump_003_5442:
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
    jp Jump_003_54c3


Jump_003_548e:
    ld a, c
    sub $01
    jp nz, Jump_003_5496

    jr jr_003_5499

Jump_003_5496:
    jp Jump_003_54a9


jr_003_5499:
    ld hl, sp+$00
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    jp Jump_003_54b2


Jump_003_54a9:
    ld hl, sp+$00
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

Jump_003_54b2:
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

Jump_003_54c3:
    ld hl, sp+$13
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a

Jump_003_54cc:
    add sp, $1b
    ret


DirSdi_B3::
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
    jp nz, Jump_003_5521

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_5521

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_5521

    inc hl
    ld a, [hl]
    or a
    jp z, Jump_003_555c

Jump_003_5521:
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
    jp c, Jump_003_5561

Jump_003_555c:
    ld e, $02
    jp Jump_003_57fd


Jump_003_5561:
    ld hl, sp+$12
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_003_55b2

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
    jp nz, Jump_003_557f

    jr jr_003_5582

Jump_003_557f:
    jp Jump_003_55b2


jr_003_5582:
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

Jump_003_55b2:
    ld hl, sp+$12
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_003_55fb

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
    jp c, Jump_003_55de

    ld e, $02
    jp Jump_003_57fd


Jump_003_55de:
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
    jp Jump_003_5720


Jump_003_55fb:
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
    jr jr_003_5616

jr_003_560f:
    ld hl, sp+$0c
    sla [hl]
    inc hl
    rl [hl]

jr_003_5616:
    dec a
    jr nz, jr_003_560f

Jump_003_5619:
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
    jp c, Jump_003_56e8

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
    call GetFat_B3
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
    jp nz, Jump_003_567b

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_567b

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_567b

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_567b

    jr jr_003_567e

Jump_003_567b:
    jp Jump_003_5683


jr_003_567e:
    ld e, $01
    jp Jump_003_57fd


Jump_003_5683:
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
    jp c, Jump_003_56cd

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
    jp c, Jump_003_56d2

Jump_003_56cd:
    ld e, $02
    jp Jump_003_57fd


Jump_003_56d2:
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
    jp Jump_003_5619


Jump_003_56e8:
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
    call Clust2Sect_B3
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

Jump_003_5720:
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
    jp nz, Jump_003_574d

    ld e, $02
    jp Jump_003_57fd


Jump_003_574d:
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

jr_003_5763:
    srl b
    rr c
    dec a
    jr nz, jr_003_5763

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

Jump_003_57fd:
    add sp, $16
    ret


; [ezgb]
; DirNext_B3(dp, stretch): FatFs dir_next. Frame -$22; ++dp->dptr index; walk dir sectors/clusters.
; Index+1==0 → Jump_003_5856 E=$04 (FR_NO_FILE); load dir entry@dp+$0e — four dwords zero → Jump_003_5856.
; Jump_003_585b: index&$0f≠0 → Jump_003_5c24 in-sector advance; else inc sector (jr_003_5879 carry chain) + copy 32-byte slot.
; Next cluster from dp chain zero → Jump_003_58da stretch path; volsize compare fail → Jump_003_5c24 else E=$04 → Jump_003_5c81.
; Jump_003_58da: sector→cluster via jr_003_58e8 ÷16; fs-type mask vs cluster → nz Jump_003_5c24; GetFat_B3.
; Cluster−1 underflow → Jump_003_5950: inc cluster words — all zero jr_003_596e E=$01 else Jump_003_596b→Jump_003_5973.
; Jump_003_5973: cluster<saved → Jump_003_5bd3; stretch==0 → E=$04 Jump_003_5c81 else Jump_003_59ba CreateChain_B3.
; CreateChain result zero → E=$07 Jump_003_5c81; else Jump_003_5a0d cluster−1 all zero → jr_003_5a2c E=$02 else Jump_003_5a29→Jump_003_5a31.
; Jump_003_5a31: inc cluster words — all wrap jr_003_5a4f E=$01 else Jump_003_5a4c→Jump_003_5a54 SyncWindow_B3.
; Jump_003_5a54: SyncWindow_B3 err→E=$01 Jump_003_5c81 else Jump_003_5a6f MemSet8 dir buf + Clust2Sect → Jump_003_5ae1 sector loop.
; Jump_003_5ae1: offset≥ssize → Jump_003_5b76 else dirty+SyncWindow; err E=$01; Jump_003_5b24 stamp template (jr_003_5b52/jr_003_5b6b) → Jump_003_5ae1.
; Jump_003_5b76: partial tail copy + sector base for index; Jump_003_5bd3 store cluster + Clust2Sect → window sector.
; Jump_003_5c24: write index@dp+$04, ptr@dp+$12+idx*32, E=0; Jump_003_5c81 add sp,$22 ret E.

DirNext_B3::
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
    jp z, Jump_003_5856

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
    jp nz, Jump_003_585b

Jump_003_5856:
    ld e, $04
    jp Jump_003_5c81


Jump_003_585b:
    ld hl, sp+$1c
    ld a, [hl]
    and $0f
    ld hl, sp+$10
    ld [hl+], a
    ld [hl], $00
    dec hl
    ld a, [hl+]
    or [hl]
    jp nz, Jump_003_5c24

    inc hl
    inc [hl]
    jr nz, jr_003_5879

    inc hl
    inc [hl]
    jr nz, jr_003_5879

    inc hl
    inc [hl]
    jr nz, jr_003_5879

    inc hl
    inc [hl]

jr_003_5879:
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
    jp nz, Jump_003_58da

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
    jp c, Jump_003_5c24

    ld e, $04
    jp Jump_003_5c81


Jump_003_58da:
    ld hl, sp+$1c
    ld a, [hl]
    ld hl, sp+$08
    ld [hl], a
    ld hl, sp+$1d
    ld a, [hl]
    ld hl, sp+$09
    ld [hl], a
    ld a, $04

jr_003_58e8:
    ld hl, sp+$09
    srl [hl]
    dec hl
    rr [hl]
    dec a
    jr nz, jr_003_58e8

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
    jp nz, Jump_003_5c24

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
    call GetFat_B3
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
    jp c, Jump_003_5950

    ld e, $02
    jp Jump_003_5c81


Jump_003_5950:
    ld hl, sp+$1e
    ld a, [hl]
    inc a
    jp nz, Jump_003_596b

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_596b

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_596b

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_596b

    jr jr_003_596e

Jump_003_596b:
    jp Jump_003_5973


jr_003_596e:
    ld e, $01
    jp Jump_003_5c81


Jump_003_5973:
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
    jp c, Jump_003_5bd3

    ld hl, sp+$26
    ld a, [hl+]
    or [hl]
    jp nz, Jump_003_59ba

    ld e, $04
    jp Jump_003_5c81


Jump_003_59ba:
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
    call CreateChain_B3
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
    jp nz, Jump_003_5a0d

    ld e, $07
    jp Jump_003_5c81


Jump_003_5a0d:
    ld hl, sp+$1e
    ld a, [hl]
    sub $01
    jp nz, Jump_003_5a29

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_5a29

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_5a29

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_5a29

    jr jr_003_5a2c

Jump_003_5a29:
    jp Jump_003_5a31


jr_003_5a2c:
    ld e, $02
    jp Jump_003_5c81


Jump_003_5a31:
    ld hl, sp+$1e
    ld a, [hl]
    inc a
    jp nz, Jump_003_5a4c

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_5a4c

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_5a4c

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_5a4c

    jr jr_003_5a4f

Jump_003_5a4c:
    jp Jump_003_5a54


jr_003_5a4f:
    ld e, $01
    jp Jump_003_5c81


Jump_003_5a54:
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
    call SyncWindow_B3
    add sp, $02
    ld c, e
    xor a
    or c
    jp z, Jump_003_5a6f

    ld e, $01
    jp Jump_003_5c81


Jump_003_5a6f:
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
    call MemSet8_B3
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
    call Clust2Sect_B3
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

Jump_003_5ae1:
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
    jp nc, Jump_003_5b76

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
    call SyncWindow_B3
    add sp, $02
    ld c, e
    xor a
    or c
    jp z, Jump_003_5b24

    ld e, $01
    jp Jump_003_5c81


Jump_003_5b24:
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
    jr nz, jr_003_5b52

    inc hl
    inc [hl]
    jr nz, jr_003_5b52

    inc hl
    inc [hl]
    jr nz, jr_003_5b52

    inc hl
    inc [hl]

jr_003_5b52:
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
    jr nz, jr_003_5b6b

    inc hl
    inc [hl]

jr_003_5b6b:
    ld hl, sp+$1a
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], e
    jp Jump_003_5ae1


Jump_003_5b76:
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

Jump_003_5bd3:
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
    call Clust2Sect_B3
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

Jump_003_5c24:
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

Jump_003_5c81:
    add sp, $22
    ret


; [ezgb]
; DirAlloc_B3(dp): FatFs dir_alloc. Frame -$0b; scan for free dir slot via DirSdi_B3(0) + DirNext_B3(1).
; DirSdi err → Jump_003_5d50; Jump_003_5cbb: load cluster@dp+$0e, MoveWindow_B3 err → Jump_003_5d50.
; SFN[0] DDEM $E5 or empty → Jump_003_5d10 else Jump_003_5d31 reset run counter → Jump_003_5d38 DirNext_B3(1).
; Jump_003_5d10: ++free-run (jr_003_5d17); run==n_dir → jr_003_5d2e→Jump_003_5d50 else Jump_003_5d2b→Jump_003_5d38.
; DirNext ok → Jump_003_5cbb; Jump_003_5d50: E==$04 → jr_003_5d5d E=$07 else Jump_003_5d5a→Jump_003_5d61 ret E.

DirAlloc_B3::
    add sp, -$0b
    ld hl, $0000
    push hl
    ld hl, sp+$0f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirSdi_B3
    add sp, $04
    ld c, e
    ld hl, sp+$0a
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_003_5d50

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

Jump_003_5cbb:
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
    call MoveWindow_B3
    add sp, $06
    ld b, e
    ld hl, sp+$0a
    ld [hl], b
    xor a
    or [hl]
    jp nz, Jump_003_5d50

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
    jp z, Jump_003_5d10

    xor a
    or c
    jp nz, Jump_003_5d31

Jump_003_5d10:
    ld hl, sp+$08
    inc [hl]
    jr nz, jr_003_5d17

    inc hl
    inc [hl]

jr_003_5d17:
    ld hl, sp+$08
    ld a, [hl]
    ld hl, sp+$0f
    sub [hl]
    jp nz, Jump_003_5d2b

    ld hl, sp+$09
    ld a, [hl]
    ld hl, sp+$10
    sub [hl]
    jp nz, Jump_003_5d2b

    jr jr_003_5d2e

Jump_003_5d2b:
    jp Jump_003_5d38


jr_003_5d2e:
    jp Jump_003_5d50


Jump_003_5d31:
    ld hl, sp+$08
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_003_5d38:
    ld hl, $0001
    push hl
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirNext_B3
    add sp, $04
    ld c, e
    ld hl, sp+$0a
    ld [hl], c
    xor a
    or [hl]
    jp z, Jump_003_5cbb

Jump_003_5d50:
    ld hl, sp+$0a
    ld a, [hl]
    sub $04
    jp nz, Jump_003_5d5a

    jr jr_003_5d5d

Jump_003_5d5a:
    jp Jump_003_5d61


jr_003_5d5d:
    ld hl, sp+$0a
    ld [hl], $07

Jump_003_5d61:
    ld hl, sp+$0a
    ld e, [hl]
    add sp, $0b
    ret


LdClust_B3::
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
    jp nz, Jump_003_5d96

    jr jr_003_5d99

Jump_003_5d96:
    jp Jump_003_5df3


jr_003_5d99:
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

Jump_003_5df3:
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


StClust_B3::
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


CmpLfn_B3::
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
    jp z, Jump_003_5e7f

    ld de, $0000
    jp Jump_003_5faa


Jump_003_5e7f:
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

Jump_003_5eb7:
    ld hl, sp+$0a
    ld a, [hl]
    sub $0d
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_003_5f70

    ld de, $5fad
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
    jp z, Jump_003_5f53

    ld hl, sp+$02
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_003_5f43

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
    jr nz, jr_003_5f13

    inc hl
    inc [hl]

jr_003_5f13:
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
    jp nz, Jump_003_5f43

    inc hl
    ld a, [hl]
    sub b
    jp z, Jump_003_5f49

Jump_003_5f43:
    ld de, $0000
    jp Jump_003_5faa


Jump_003_5f49:
    ld hl, sp+$06
    ld a, [hl+]
    ld e, [hl]
    inc hl
    ld [hl+], a
    ld [hl], e
    jp Jump_003_5f66


Jump_003_5f53:
    ld hl, sp+$06
    ld a, [hl]
    inc a
    jp nz, Jump_003_5f60

    inc hl
    ld a, [hl]
    inc a
    jp z, Jump_003_5f66

Jump_003_5f60:
    ld de, $0000
    jp Jump_003_5faa


Jump_003_5f66:
    ld hl, sp+$0a
    inc [hl]
    jr nz, jr_003_5f6d

    inc hl
    inc [hl]

jr_003_5f6d:
    jp Jump_003_5eb7


Jump_003_5f70:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $40
    jr nz, jr_003_5f7e

    jp Jump_003_5fa7


jr_003_5f7e:
    ld hl, sp+$08
    ld a, [hl+]
    or [hl]
    jp z, Jump_003_5fa7

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
    jp z, Jump_003_5fa7

    ld de, $0000
    jp Jump_003_5faa


Jump_003_5fa7:
    ld de, $0001

Jump_003_5faa:
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
    jp z, Jump_003_5fd8

    ld de, $0000
    jp Jump_003_60e2


Jump_003_5fd8:
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

Jump_003_6012:
    ld hl, sp+$09
    ld a, [hl]
    sub $0d
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_003_60a9

    ld de, $5fad
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
    jp z, Jump_003_608c

    ld hl, sp+$00
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_003_6059

    ld de, $0000
    jp Jump_003_60e2


Jump_003_6059:
    ld hl, sp+$00
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_003_6064

    inc hl
    inc [hl]

jr_003_6064:
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
    jp Jump_003_609f


Jump_003_608c:
    ld hl, sp+$05
    ld a, [hl]
    inc a
    jp nz, Jump_003_6099

    inc hl
    ld a, [hl]
    inc a
    jp z, Jump_003_609f

Jump_003_6099:
    ld de, $0000
    jp Jump_003_60e2


Jump_003_609f:
    ld hl, sp+$09
    inc [hl]
    jr nz, jr_003_60a6

    inc hl
    inc [hl]

jr_003_60a6:
    jp Jump_003_6012


Jump_003_60a9:
    ld hl, sp+$04
    ld a, [hl]
    and $40
    jr nz, jr_003_60b3

    jp Jump_003_60df


jr_003_60b3:
    ld hl, sp+$0b
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_003_60c5

    ld de, $0000
    jp Jump_003_60e2


Jump_003_60c5:
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

Jump_003_60df:
    ld de, $0001

Jump_003_60e2:
    add sp, $0d
    ret


PutLfn_B3::
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

Jump_003_614b:
    ld hl, sp+$02
    ld a, [hl]
    inc a
    jp nz, Jump_003_6158

    inc hl
    ld a, [hl]
    inc a
    jp z, Jump_003_617b

Jump_003_6158:
    ld hl, sp+$00
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_003_6163

    inc hl
    inc [hl]

jr_003_6163:
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

Jump_003_617b:
    ld de, $5fad
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
    jp nz, Jump_003_61a9

    dec hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff

Jump_003_61a9:
    ld hl, sp+$04
    inc [hl]
    jr nz, jr_003_61b0

    inc hl
    inc [hl]

jr_003_61b0:
    ld hl, sp+$04
    ld a, [hl]
    sub $0d
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_003_614b

    ld hl, sp+$02
    ld a, [hl]
    inc a
    jp nz, Jump_003_61c9

    inc hl
    ld a, [hl]
    inc a
    jp z, Jump_003_61e5

Jump_003_61c9:
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
    jp nz, Jump_003_61eb

Jump_003_61e5:
    ld hl, sp+$0c
    ld a, [hl]
    or $40
    ld [hl], a

Jump_003_61eb:
    ld hl, sp+$0a
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc hl
    ld a, [hl]
    ld [bc], a
    add sp, $06
    ret


; [ezgb]
; GenNumName_B3: same as GenNumName_B9 (09:6201). Bank-local FatFs gen_numname copy.

GenNumName_B3::
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
    call MemCpy16_B3
    add sp, $05
    ld a, $05
    ld hl, sp+$25
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp nc, Jump_003_62f9

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

Jump_003_6230:
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
    jp z, Jump_003_62ed

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

Jump_003_6258:
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
    jr nz, jr_003_62cc

    jp Jump_003_62da


jr_003_62cc:
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

Jump_003_62da:
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
    jp nz, Jump_003_6258

    jp Jump_003_6230


Jump_003_62ed:
    ld hl, sp+$0a
    ld a, [hl]
    ld hl, sp+$25
    ld [hl], a
    ld hl, sp+$0b
    ld a, [hl]
    ld hl, sp+$26
    ld [hl], a

Jump_003_62f9:
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

Jump_003_6308:
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
    jp nc, Jump_003_6320

    ld a, [hl]
    add $07
    ld [hl], a

Jump_003_6320:
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

jr_003_6343:
    ld hl, sp+$26
    srl [hl]
    dec hl
    rr [hl]
    dec a
    jr nz, jr_003_6343

    ld a, [hl+]
    or [hl]
    jp nz, Jump_003_6308

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

Jump_003_6371:
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
    jp nc, Jump_003_639e

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
    jp z, Jump_003_639e

    ld hl, sp+$10
    inc [hl]
    jr nz, jr_003_639b

    inc hl
    inc [hl]

jr_003_639b:
    jp Jump_003_6371


Jump_003_639e:
    ld hl, sp+$04
    ld a, [hl+]
    ld e, [hl]
    dec hl
    ld [hl+], a
    ld [hl], e

Jump_003_63a5:
    ld hl, sp+$10
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_003_63b0

    inc hl
    inc [hl]

jr_003_63b0:
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
    jp nc, Jump_003_63df

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_003_63d2

    inc hl
    inc [hl]

jr_003_63d2:
    ld hl, sp+$00
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    jp Jump_003_63e1


Jump_003_63df:
    ld c, $20

Jump_003_63e1:
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
    jp c, Jump_003_63a5

    add sp, $1d
    ret


SumSfn_B3::
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

Jump_003_640c:
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
    jr nz, jr_003_6425

    inc hl
    inc [hl]

jr_003_6425:
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
    jp nz, Jump_003_640c

    inc hl
    ld e, [hl]
    add sp, $05
    ret


; [ezgb]
; DirFind_B3(dp): FatFs dir_find. DirSdi_B3(0); fail Jump_003_645e init else err Jump_003_6698.
; Jump_003_645e: clear ord/hash ptrs; Jump_003_64d0 read entry + MoveWindow_B3; fail Jump_003_6695; LFN chain Jump_003_6529 else ord=4 Jump_003_6695.
; Jump_003_6529: attr — deleted $E5 Jump_003_654e; volume jr_003_6548; LFN ord $0F Jump_003_6569 else Jump_003_6561/Jump_003_6569 SFN path.
; jr_003_656c: empty LFN chk Jump_003_667d; AM_LFN jr_003_6584 store ord/chksum else Jump_003_65b0 ord compare (Jump_003_65bb/jr_003_65be/Jump_003_65d2/Jump_003_65d7/Jump_003_65d9 CmpLfn_B3).
; Jump_003_65fb/Jump_003_6600/Jump_003_6602/Jump_003_660f/Jump_003_6611: LFN ord update Jump_003_667d; Jump_003_6617 SumSfn_B3 match Jump_003_6695.
; Jump_003_6630 NTRES jr_003_664e skip; Jump_003_6651 MemCmp_B3 SFN match Jump_003_6695 else Jump_003_666d invalidate; Jump_003_667d DirNext_B3 loop Jump_003_64d0; Jump_003_6695/Jump_003_6698 epilogue.

DirFind_B3::
    add sp, -$1a
    ld hl, $0000
    push hl
    ld hl, sp+$1e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirSdi_B3
    add sp, $04
    ld c, e
    ld hl, sp+$19
    ld [hl], c
    xor a
    or [hl]
    jp z, Jump_003_645e

    ld e, [hl]
    jp Jump_003_6698


Jump_003_645e:
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

Jump_003_64d0:
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
    call MoveWindow_B3
    add sp, $06
    ld b, e
    ld hl, sp+$19
    ld [hl], b
    xor a
    or [hl]
    jp nz, Jump_003_6695

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
    jp nz, Jump_003_6529

    inc hl
    ld [hl], $04
    jp Jump_003_6695


Jump_003_6529:
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
    jp z, Jump_003_654e

    ld a, c
    and $08
    jr nz, jr_003_6548

    jp Jump_003_6561


jr_003_6548:
    ld a, c
    sub $0f
    jp z, Jump_003_6561

Jump_003_654e:
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
    jp Jump_003_667d


Jump_003_6561:
    ld a, c
    sub $0f
    jp nz, Jump_003_6569

    jr jr_003_656c

Jump_003_6569:
    jp Jump_003_6617


jr_003_656c:
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
    jp z, Jump_003_667d

    ld hl, sp+$18
    ld a, [hl]
    and $40
    jr nz, jr_003_6584

    jp Jump_003_65b0


jr_003_6584:
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

Jump_003_65b0:
    ld hl, sp+$18
    ld a, [hl]
    ld hl, sp+$15
    sub [hl]
    jp nz, Jump_003_65bb

    jr jr_003_65be

Jump_003_65bb:
    jp Jump_003_65d2


jr_003_65be:
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
    jp z, Jump_003_65d7

Jump_003_65d2:
    ld c, $00
    jp Jump_003_65d9


Jump_003_65d7:
    ld c, $01

Jump_003_65d9:
    xor a
    or c
    jp z, Jump_003_65fb

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
    call CmpLfn_B3
    add sp, $04
    ld b, d
    ld c, e
    ld a, c
    or b
    jp nz, Jump_003_6600

Jump_003_65fb:
    ld c, $00
    jp Jump_003_6602


Jump_003_6600:
    ld c, $01

Jump_003_6602:
    xor a
    or c
    jp z, Jump_003_660f

    ld hl, sp+$15
    ld a, [hl]
    dec a
    ld c, a
    jp Jump_003_6611


Jump_003_660f:
    ld c, $ff

Jump_003_6611:
    ld hl, sp+$15
    ld [hl], c
    jp Jump_003_667d


Jump_003_6617:
    xor a
    ld hl, sp+$15
    or [hl]
    jp nz, Jump_003_6630

    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call SumSfn_B3
    add sp, $02
    ld c, e
    ld hl, sp+$14
    ld a, [hl]
    sub c
    jp z, Jump_003_6695

Jump_003_6630:
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
    jr nz, jr_003_664e

    jp Jump_003_6651


jr_003_664e:
    jp Jump_003_666d


Jump_003_6651:
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
    call MemCmp_B3
    add sp, $05
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, Jump_003_6695

Jump_003_666d:
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

Jump_003_667d:
    ld hl, $0000
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirNext_B3
    add sp, $04
    ld c, e
    ld hl, sp+$19
    ld [hl], c
    xor a
    or [hl]
    jp z, Jump_003_64d0

Jump_003_6695:
    ld hl, sp+$19
    ld e, [hl]

Jump_003_6698:
    add sp, $1a
    ret


; [ezgb]
; DirRegister_B3(dp): FatFs dir_register. Frame -$26; copy SFN/LFN from dp; sp+$25=E.
; NSFLAG directory → jr_003_670c E=$06 Jump_003_6a27; Jump_003_6711: AM_DIR → jr_003_6719 GenNumName loop Jump_003_673a.
; Jump_003_673a: idx<100 GenNumName_B3+DirFind_B3; taken → jr_003_677d ++idx; miss → Jump_003_6780.
; Jump_003_6780: idx==100 → jr_003_6793 E=$07 else Jump_003_6790→Jump_003_6798; E==$04 → Jump_003_67a6 patch attr/size.
; Jump_003_67c5: LFN (attr&$02) → jr_003_67d3 count slots Jump_003_67da/jr_003_67fd; Jump_003_6800 U16Div → Jump_003_6825 else Jump_003_681e n=1.
; Jump_003_6825: DirAlloc_B3; err → Jump_003_6957; LFN slots Jump_003_68ad (DirSdi, SumSfn, MoveWindow, PutLfn_B3, DirNext) loop.
; Jump_003_6957: err → Jump_003_6a24 else finalize SFN (MoveWindow, MemSet8, MemCpy16, attr mask) + FA_DIRTY.
; Jump_003_6a24/Jump_003_6a27 add sp,$26 ret E.

DirRegister_B3::
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
    call MemCpy16_B3
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
    jr nz, jr_003_670c

    jp Jump_003_6711


jr_003_670c:
    ld e, $06
    jp Jump_003_6a27


Jump_003_6711:
    ld a, c
    and $01
    jr nz, jr_003_6719

    jp Jump_003_67c5


jr_003_6719:
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

Jump_003_673a:
    ld hl, sp+$23
    ld a, [hl]
    sub $64
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_003_6780

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
    call GenNumName_B3
    add sp, $08
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirFind_B3
    add sp, $02
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_003_6780

    dec hl
    dec hl
    inc [hl]
    jr nz, jr_003_677d

    inc hl
    inc [hl]

jr_003_677d:
    jp Jump_003_673a


Jump_003_6780:
    ld hl, sp+$23
    ld a, [hl]
    sub $64
    jp nz, Jump_003_6790

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_6790

    jr jr_003_6793

Jump_003_6790:
    jp Jump_003_6798


jr_003_6793:
    ld e, $07
    jp Jump_003_6a27


Jump_003_6798:
    ld hl, sp+$25
    ld a, [hl]
    sub $04
    jp z, Jump_003_67a6

    ld hl, sp+$25
    ld e, [hl]
    jp Jump_003_6a27


Jump_003_67a6:
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

Jump_003_67c5:
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $02
    jr nz, jr_003_67d3

    jp Jump_003_681e


jr_003_67d3:
    ld hl, sp+$23
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_003_67da:
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
    jp z, Jump_003_6800

    ld hl, sp+$23
    inc [hl]
    jr nz, jr_003_67fd

    inc hl
    inc [hl]

jr_003_67fd:
    jp Jump_003_67da


Jump_003_6800:
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
    jp Jump_003_6825


Jump_003_681e:
    ld hl, sp+$21
    ld [hl], $01
    inc hl
    ld [hl], $00

Jump_003_6825:
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
    call DirAlloc_B3
    add sp, $04
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_003_6957

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
    jp z, Jump_003_6957

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
    call DirSdi_B3
    add sp, $04
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_003_6957

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
    call SumSfn_B3
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

Jump_003_68ad:
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
    call MoveWindow_B3
    add sp, $06
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_003_6957

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
    call PutLfn_B3
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
    call DirNext_B3
    add sp, $04
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_003_6957

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
    jp nz, Jump_003_68ad

Jump_003_6957:
    xor a
    ld hl, sp+$25
    or [hl]
    jp nz, Jump_003_6a24

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
    call MoveWindow_B3
    add sp, $06
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_003_6a24

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
    call MemSet8_B3
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
    call MemCpy16_B3
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

Jump_003_6a24:
    ld hl, sp+$25
    ld e, [hl]

Jump_003_6a27:
    add sp, $26
    ret


; [ezgb]
; CreateName_B3(dp, path): FatFs create_name twin of CreateName_B9 (09:6c3e). Frame -$1b; parse next path segment; build SFN/LFN+NSFLAG.
; Jump_003_6a45: skip leading '/' ($2f) or '\\' ($5c): Jump_003_6a5b/jr_003_6a5b ++BC loop; else Jump_003_6a58 → Jump_003_6a64 start segment.
; Jump_003_6a64: stash path; lfnbuf@dp+$16; clear counters. Jump_003_6a9b: ++idx (jr_003_6aa6); load char; <' ' or '/' or '\\' → Jump_003_6b6d end segment.
; Jump_003_6ad7/Jump_003_6ae5: not terminator; Jump_003_6af6: if lfn idx≥$ff → E=$06 Jump_003_709f; else MapCp437; fail → Jump_003_709f.
; Jump_003_6b1b: if <*$80 MemChr illegal set; hit → Jump_003_709f; Jump_003_6b41/jr_003_6b4c store wchar to lfnbuf → Jump_003_6a9b.
; Jump_003_6b6d: write advanced path ptr; last char <' ' → C=$04 (NSFLAG) else Jump_003_6b95 C=0; Jump_003_6b97 store NSFLAG@sp+$19.
; If lfnlen!=1 Jump_003_6baa → Jump_003_6bd0; else jr_003_6bad: last wchar=='.' → Jump_003_6c34/jr_003_6c34 else Jump_003_6bd0.
; Jump_003_6bd0: len!=2 → Jump_003_6be0 → Jump_003_6cc7; else jr_003_6be3: '..' check (Jump_003_6c08/jr_003_6c0b/Jump_003_6c31) → Jump_003_6c34 or Jump_003_6cc7.
; Jump_003_6c34/jr_003_6c34: NUL-term LFN; Jump_003_6c64 fill SFN 11 slots (Jump_003_6c98/Jump_003_6c9c); done Jump_003_6caa.
; SFN pad loop: Jump_003_6c64; insert '.' Jump_003_6c98 else space Jump_003_6c9c; jr_003_6ca7 → Jump_003_6c64; done Jump_003_6caa OR NSFLAG|$20 → Jump_003_709f (dot-only names).
; Jump_003_6cc7: normal path; Jump_003_6ccf strip trailing ' '/' .' (Jump_003_6d00 / Jump_003_6d10 / Jump_003_6d13 / jr_003_6d13); Jump_003_6d27 empty → E=$06 Jump_003_709f else Jump_003_6d3b NUL-term + MemSet8_B3 spaces into SFN.
; Jump_003_6d86: skip leading ' '/' .' (Jump_003_6da8 / Jump_003_6db4 / Jump_003_6db7 / jr_003_6db7 / jr_003_6dbe); non-lead Jump_003_6dc9; if skipped NSFLAG|$03 then Jump_003_6dde.
; Jump_003_6dde: walk for last '.' (Jump_003_6e15 → Jump_003_6dde); none/done Jump_003_6e22 init body len=8 then Jump_003_6e34.
; Jump_003_6e34 SFN fill: next wchar (jr_003_6e3f); NUL→Jump_003_6ffe; space Jump_003_6e8f; '.' Jump_003_6e6a/Jump_003_6e7a/jr_003_6e7d; else Jump_003_6e98; slot full Jump_003_6ebe/jr_003_6ebe/Jump_003_6ece/jr_003_6ed1; body	oext Jump_003_6eda/Jump_003_6eec/Jump_003_6ef2; else Jump_003_6ebb → Jump_003_6f1f MapCp437.
; Jump_003_6f1f: wchar>=$80 MapCp437 (fail Jump_003_6f5a NSFLAG|$02); then Jump_003_6f60 MemChr_B3 illegal set → '_' Jump_003_6f7c NSFLAG|$03 else Jump_003_6f8b.
; Case: A-Z Jump_003_6fab skip else NSFLAG|$02 → Jump_003_6fd9; a-z Jump_003_6fab NSFLAG|$01 + toupper; store via jr_003_6fef → Jump_003_6e34.
; Jump_003_6ffe: SFN[0]==$E5 → $05 (jr_003_7018) else Jump_003_7015/Jump_003_7020; body-only Jump_003_7030/jr_003_7033 NT<<2; case mix Jump_003_7039/Jump_003_7051/Jump_003_7054/jr_003_7054 → NSFLAG|$02; Jump_003_705a/jr_003_7064/Jump_003_7067/Jump_003_7074/jr_003_7077/Jump_003_707d/Jump_003_7085/jr_003_7088/Jump_003_708e store NSFLAG; E=0 → Jump_003_709f.
; CreateName CF ends Jump_003_709f (add sp,$1b / ret). Post-ret: illegal-char table then unnamed-until-sym FollowPath_B3 @ 03:70b2 (Jump_003_70cc…Jump_003_72b8) — not CreateName interior; twin of FollowPath_B5/B6/B9.

CreateName_B3::
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

Jump_003_6a45:
    ld a, [bc]
    ld hl, sp+$08
    ld [hl], a
    sub $2f
    jp z, Jump_003_6a5b

    ld hl, sp+$08
    ld a, [hl]
    sub $5c
    jp nz, Jump_003_6a58

    jr jr_003_6a5b

Jump_003_6a58:
    jp Jump_003_6a64


Jump_003_6a5b:
jr_003_6a5b:
    inc bc
    ld hl, sp+$0b
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_003_6a45


Jump_003_6a64:
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

Jump_003_6a9b:
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_003_6aa6

    inc hl
    inc [hl]

jr_003_6aa6:
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
    jp c, Jump_003_6b6d

    dec hl
    ld a, [hl]
    sub $2f
    jp nz, Jump_003_6ad7

    inc hl
    ld a, [hl]
    or a
    jp z, Jump_003_6b6d

Jump_003_6ad7:
    ld hl, sp+$17
    ld a, [hl]
    sub $5c
    jp nz, Jump_003_6ae5

    inc hl
    ld a, [hl]
    or a
    jp z, Jump_003_6b6d

Jump_003_6ae5:
    ld hl, sp+$02
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_003_6af6

    ld e, $06
    jp Jump_003_709f


Jump_003_6af6:
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
    jp nz, Jump_003_6b1b

    ld e, $06
    jp Jump_003_709f


Jump_003_6b1b:
    ld hl, sp+$17
    ld a, [hl]
    sub $80
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_003_6b41

    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $70a2
    push hl
    call MemChr_B3
    add sp, $04
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, Jump_003_6b41

    ld e, $06
    jp Jump_003_709f


Jump_003_6b41:
    ld hl, sp+$02
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_003_6b4c

    inc hl
    inc [hl]

jr_003_6b4c:
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
    jp Jump_003_6a9b


Jump_003_6b6d:
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
    jp nc, Jump_003_6b95

    ld c, $04
    jp Jump_003_6b97


Jump_003_6b95:
    ld c, $00

Jump_003_6b97:
    ld hl, sp+$19
    ld [hl], c
    ld hl, sp+$0d
    ld a, [hl]
    sub $01
    jp nz, Jump_003_6baa

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_6baa

    jr jr_003_6bad

Jump_003_6baa:
    jp Jump_003_6bd0


jr_003_6bad:
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
    jp nz, Jump_003_6bd0

    or b
    jp z, Jump_003_6c34

Jump_003_6bd0:
    ld hl, sp+$0d
    ld a, [hl]
    sub $02
    jp nz, Jump_003_6be0

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_6be0

    jr jr_003_6be3

Jump_003_6be0:
    jp Jump_003_6cc7


jr_003_6be3:
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
    jp nz, Jump_003_6c08

    or b
    jp nz, Jump_003_6c08

    jr jr_003_6c0b

Jump_003_6c08:
    jp Jump_003_6cc7


jr_003_6c0b:
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
    jp nz, Jump_003_6c31

    or b
    jp nz, Jump_003_6c31

    jr jr_003_6c34

Jump_003_6c31:
    jp Jump_003_6cc7


Jump_003_6c34:
jr_003_6c34:
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

Jump_003_6c64:
    ld hl, sp+$13
    ld a, [hl]
    sub $0b
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_003_6caa

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
    jp nc, Jump_003_6c98

    ld hl, sp+$02
    ld [hl], $2e
    jp Jump_003_6c9c


Jump_003_6c98:
    ld hl, sp+$02
    ld [hl], $20

Jump_003_6c9c:
    ld hl, sp+$02
    ld a, [hl]
    ld [bc], a
    ld hl, sp+$13
    inc [hl]
    jr nz, jr_003_6ca7

    inc hl
    inc [hl]

jr_003_6ca7:
    jp Jump_003_6c64


Jump_003_6caa:
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
    jp Jump_003_709f


Jump_003_6cc7:
    ld hl, sp+$0d
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e

Jump_003_6ccf:
    ld hl, sp+$00
    ld a, [hl+]
    or [hl]
    jp z, Jump_003_6d27

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
    jp nz, Jump_003_6d00

    inc hl
    ld a, [hl]
    or a
    jp z, Jump_003_6d13

Jump_003_6d00:
    ld hl, sp+$17
    ld a, [hl]
    sub $2e
    jp nz, Jump_003_6d10

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_6d10

    jr jr_003_6d13

Jump_003_6d10:
    jp Jump_003_6d27


Jump_003_6d13:
jr_003_6d13:
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
    jp Jump_003_6ccf


Jump_003_6d27:
    ld hl, sp+$00
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0d
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$00
    ld a, [hl+]
    or [hl]
    jp nz, Jump_003_6d3b

    ld e, $06
    jp Jump_003_709f


Jump_003_6d3b:
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
    call MemSet8_B3
    add sp, $05
    ld hl, sp+$0f
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$02
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_003_6d86:
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
    jp nz, Jump_003_6da8

    or b
    jp z, Jump_003_6db7

Jump_003_6da8:
    ld a, c
    sub $2e
    jp nz, Jump_003_6db4

    or b
    jp nz, Jump_003_6db4

    jr jr_003_6db7

Jump_003_6db4:
    jp Jump_003_6dc9


Jump_003_6db7:
jr_003_6db7:
    ld hl, sp+$02
    inc [hl]
    jr nz, jr_003_6dbe

    inc hl
    inc [hl]

jr_003_6dbe:
    ld hl, sp+$02
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0f
    ld [hl+], a
    ld [hl], e
    jp Jump_003_6d86


Jump_003_6dc9:
    ld hl, sp+$02
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0f
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$02
    ld a, [hl+]
    or [hl]
    jp z, Jump_003_6dde

    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a

Jump_003_6dde:
    ld hl, sp+$0d
    ld a, [hl+]
    or [hl]
    jp z, Jump_003_6e22

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
    jp nz, Jump_003_6e15

    or b
    jp z, Jump_003_6e22

Jump_003_6e15:
    ld hl, sp+$02
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$0d
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_003_6dde


Jump_003_6e22:
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

Jump_003_6e34:
    ld hl, sp+$0f
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, jr_003_6e3f

    inc hl
    inc [hl]

jr_003_6e3f:
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
    jp z, Jump_003_6ffe

    dec hl
    ld a, [hl]
    sub $20
    jp nz, Jump_003_6e6a

    inc hl
    ld a, [hl]
    or a
    jp z, Jump_003_6e8f

Jump_003_6e6a:
    ld hl, sp+$17
    ld a, [hl]
    sub $2e
    jp nz, Jump_003_6e7a

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_6e7a

    jr jr_003_6e7d

Jump_003_6e7a:
    jp Jump_003_6e98


jr_003_6e7d:
    ld hl, sp+$0f
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, Jump_003_6e8f

    ld hl, sp+$10
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp z, Jump_003_6e98

Jump_003_6e8f:
    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a
    jp Jump_003_6e34


Jump_003_6e98:
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
    jp nc, Jump_003_6ebe

    ld hl, sp+$0f
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, Jump_003_6ebb

    ld hl, sp+$10
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, Jump_003_6ebb

    jr jr_003_6ebe

Jump_003_6ebb:
    jp Jump_003_6f1f


Jump_003_6ebe:
jr_003_6ebe:
    ld hl, sp+$11
    ld a, [hl]
    sub $0b
    jp nz, Jump_003_6ece

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_6ece

    jr jr_003_6ed1

Jump_003_6ece:
    jp Jump_003_6eda


jr_003_6ed1:
    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a
    jp Jump_003_6ffe


Jump_003_6eda:
    ld hl, sp+$0f
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, Jump_003_6eec

    ld hl, sp+$10
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp z, Jump_003_6ef2

Jump_003_6eec:
    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a

Jump_003_6ef2:
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
    jp c, Jump_003_6ffe

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
    jp Jump_003_6e34


Jump_003_6f1f:
    ld hl, sp+$17
    ld a, [hl]
    sub $80
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_003_6f60

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
    jp z, Jump_003_6f5a

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

Jump_003_6f5a:
    ld hl, sp+$19
    ld a, [hl]
    or $02
    ld [hl], a

Jump_003_6f60:
    ld hl, sp+$17
    ld a, [hl+]
    or [hl]
    jp z, Jump_003_6f7c

    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $70ab
    push hl
    call MemChr_B3
    add sp, $04
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, Jump_003_6f8b

Jump_003_6f7c:
    ld hl, sp+$17
    ld [hl], $5f
    inc hl
    ld [hl], $00
    inc hl
    ld a, [hl]
    or $03
    ld [hl], a
    jp Jump_003_6fd9


Jump_003_6f8b:
    ld hl, sp+$17
    ld a, [hl]
    sub $41
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_003_6fab

    ld a, $5a
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp c, Jump_003_6fab

    inc hl
    inc hl
    ld a, [hl]
    or $02
    ld [hl], a
    jp Jump_003_6fd9


Jump_003_6fab:
    ld hl, sp+$17
    ld a, [hl]
    sub $61
    inc hl
    ld a, [hl]
    sbc $00
    jp c, Jump_003_6fd9

    ld a, $7a
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp c, Jump_003_6fd9

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

Jump_003_6fd9:
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
    jr nz, jr_003_6fef

    inc hl
    inc [hl]

jr_003_6fef:
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
    jp Jump_003_6e34


Jump_003_6ffe:
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
    jp nz, Jump_003_7015

    jr jr_003_7018

Jump_003_7015:
    jp Jump_003_7020


jr_003_7018:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $05
    ld [de], a

Jump_003_7020:
    ld hl, sp+$11
    ld a, [hl]
    sub $08
    jp nz, Jump_003_7030

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_7030

    jr jr_003_7033

Jump_003_7030:
    jp Jump_003_7039


jr_003_7033:
    ld hl, sp+$1a
    sla [hl]
    sla [hl]

Jump_003_7039:
    ld hl, sp+$1a
    ld a, [hl]
    and $0c
    ld c, a
    sub $0c
    jp z, Jump_003_7054

    ld hl, sp+$1a
    ld a, [hl]
    and $03
    ld b, a
    sub $03
    jp nz, Jump_003_7051

    jr jr_003_7054

Jump_003_7051:
    jp Jump_003_705a


Jump_003_7054:
jr_003_7054:
    ld hl, sp+$19
    ld a, [hl]
    or $02
    ld [hl], a

Jump_003_705a:
    ld hl, sp+$19
    ld a, [hl]
    and $02
    jr nz, jr_003_7064

    jp Jump_003_7067


jr_003_7064:
    jp Jump_003_708e


Jump_003_7067:
    ld hl, sp+$1a
    ld a, [hl]
    and $03
    ld b, a
    sub $01
    jp nz, Jump_003_7074

    jr jr_003_7077

Jump_003_7074:
    jp Jump_003_707d


jr_003_7077:
    ld hl, sp+$19
    ld a, [hl]
    or $10
    ld [hl], a

Jump_003_707d:
    ld a, c
    sub $04
    jp nz, Jump_003_7085

    jr jr_003_7088

Jump_003_7085:
    jp Jump_003_708e


jr_003_7088:
    ld hl, sp+$19
    ld a, [hl]
    or $08
    ld [hl], a

Jump_003_708e:
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

Jump_003_709f:
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

; [ezgb]
; FatFs follow_path (bank-3). Twin of FollowPath_B5/B6/B9; was mis-spanned under CreateName_B3 after illegal-char table.
; Entry: skip leading '/' '\' (Jump_003_70cc → Jump_003_70f8 else Jump_003_70cf / jr_003_70cf clear sclust → Jump_003_7136).
; Jump_003_70f8: copy fs->cdir into dp->sclust; Join Jump_003_7136.
; Jump_003_7136: path[0]<' ' → DirSdi_B3(0) + clear fn → Jump_003_72b8 else Jump_003_7173 segment loop (CreateName_B3 / DirFind_B3).
; Jump_003_7173 segment loop: CreateName_B3; err→Jump_003_72b8; DirFind_B3; FR_NOFILE+$04 last-seg (jr_003_71d0) else Jump_003_71cd→Jump_003_72b8; NSFLAG|$20 (jr_003_71da) clear sclust/fn + more path→Jump_003_7173 else last (jr_003_7214 E=0); non-last NSFLAG Jump_003_721b/jr_003_7225/Jump_003_7228 E=$05.
; Found (Jump_003_722f): last-seg jr_003_7239→Jump_003_72b8; else Jump_003_723c ATTR_DIR? jr_003_7266→Jump_003_7270 LdClust_B3 into sclust → Jump_003_7173 else Jump_003_7269 E=$05; Jump_003_72b8 epilogue ret E.

FollowPath_B3::
    add sp, -$0b
    ld hl, sp+$0f
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, [bc]
    ld hl, sp+$06
    ld [hl], a
    sub $2f
    jp z, Jump_003_70cf

    ld hl, sp+$06
    ld a, [hl]
    sub $5c
    jp nz, Jump_003_70cc

    jr jr_003_70cf

Jump_003_70cc:
    jp Jump_003_70f8


Jump_003_70cf:
jr_003_70cf:
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
    jp Jump_003_7136


Jump_003_70f8:
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

Jump_003_7136:
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
    jp nc, Jump_003_7173

    ld hl, $0000
    push hl
    ld hl, sp+$0f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirSdi_B3
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
    jp Jump_003_72b8


Jump_003_7173:
    ld hl, sp+$0f
    ld c, l
    ld b, h
    push bc
    ld hl, sp+$0f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call CreateName_B3
    add sp, $04
    ld c, e
    ld hl, sp+$0a
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_003_72b8

    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirFind_B3
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
    jp z, Jump_003_722f

    ld a, [hl]
    sub $04
    jp nz, Jump_003_71cd

    jr jr_003_71d0

Jump_003_71cd:
    jp Jump_003_72b8


jr_003_71d0:
    ld hl, sp+$07
    ld a, [hl]
    and $20
    jr nz, jr_003_71da

    jp Jump_003_721b


jr_003_71da:
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
    jr nz, jr_003_7214

    jp Jump_003_7173


jr_003_7214:
    ld hl, sp+$0a
    ld [hl], $00
    jp Jump_003_72b8


Jump_003_721b:
    ld hl, sp+$07
    ld a, [hl]
    and $04
    jr nz, jr_003_7225

    jp Jump_003_7228


jr_003_7225:
    jp Jump_003_72b8


Jump_003_7228:
    ld hl, sp+$0a
    ld [hl], $05
    jp Jump_003_72b8


Jump_003_722f:
    ld hl, sp+$07
    ld a, [hl]
    and $04
    jr nz, jr_003_7239

    jp Jump_003_723c


jr_003_7239:
    jp Jump_003_72b8


Jump_003_723c:
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
    jr nz, jr_003_7266

    jp Jump_003_7269


jr_003_7266:
    jp Jump_003_7270


Jump_003_7269:
    ld hl, sp+$0a
    ld [hl], $05
    jp Jump_003_72b8


Jump_003_7270:
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
    call LdClust_B3
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
    jp Jump_003_7173


Jump_003_72b8:
    ld hl, sp+$0a
    ld e, [hl]
    add sp, $0b
    ret


GetLdNumber_B3::
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
    jp z, Jump_003_738d

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b

Jump_003_72e7:
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
    jp c, Jump_003_730d

    ld a, [hl]
    sub $3a
    jp z, Jump_003_730d

    ld hl, sp+$00
    inc [hl]
    jr nz, jr_003_730a

    inc hl
    inc [hl]

jr_003_730a:
    jp Jump_003_72e7


Jump_003_730d:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $3a
    jp nz, Jump_003_731b

    jr jr_003_731e

Jump_003_731b:
    jp Jump_003_7386


jr_003_731e:
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
    jr nz, jr_003_7334

    inc hl
    inc [hl]

jr_003_7334:
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
    jp nc, Jump_003_737e

    ld hl, sp+$09
    ld a, [hl]
    ld hl, sp+$00
    sub [hl]
    jp nz, Jump_003_735d

    ld hl, sp+$0a
    ld a, [hl]
    ld hl, sp+$01
    sub [hl]
    jp nz, Jump_003_735d

    jr jr_003_7360

Jump_003_735d:
    jp Jump_003_737e


jr_003_7360:
    ld a, c
    sub $01
    ld a, b
    sbc $00
    jp nc, Jump_003_737e

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

Jump_003_737e:
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    jp Jump_003_7392


Jump_003_7386:
    ld hl, sp+$07
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_003_738d:
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]

Jump_003_7392:
    add sp, $0b
    ret


; [ezgb]
; FindVolume stub (bank-3 near-call): FatFs find_volume front only; full mount in FindVolume_B5.
; Clear *rfs; GetLdNumber_B3: bit7→E=$0b Jump_003_7417; else Jump_003_73c2: FatFs[vol] @$C5A5 null→E=$0c else Jump_003_73dc.
; Jump_003_73dc: bind *rfs; fs_type==0→Jump_003_7415; DiskStatus STA_NOINIT jr_003_73fe→Jump_003_7415 else Jump_003_7401; mode0 Jump_003_7415 else WP jr_003_7410 E=$0a; Jump_003_7415 E=0 → Jump_003_7417 (add sp,$12 / ret).

FindVolume_B3::
    add sp, -$12
    ld hl, sp+$14
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
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
    ld hl, sp+$16
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call GetLdNumber_B3
    add sp, $02
    ld b, d
    ld c, e
    ld a, b
    bit 7, a
    jp z, Jump_003_73c2

    ld e, $0b
    jp Jump_003_7417


Jump_003_73c2:
    sla c
    rl b
    ld hl, $c5a5
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
    jp nz, Jump_003_73dc

    ld e, $0c
    jp Jump_003_7417


Jump_003_73dc:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a
    ld a, [bc]
    or a
    jp z, Jump_003_7415

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
    jr nz, jr_003_73fe

    jp Jump_003_7401


jr_003_73fe:
    jp Jump_003_7415


Jump_003_7401:
    xor a
    ld hl, sp+$18
    or [hl]
    jp z, Jump_003_7415

    ld a, c
    and $04
    jr nz, jr_003_7410

    jp Jump_003_7415


jr_003_7410:
    ld e, $0a
    jp Jump_003_7417


Jump_003_7415:
    ld e, $00

Jump_003_7417:
    add sp, $12
    ret


; [ezgb]
; Validate_B3(obj): FatFs validate. Push frame; reject null obj/fs, fs_type==0, or id mismatch → Jump_003_7493 E=$09.
; obj->id vs fs->id mismatch → Jump_003_7478→Jump_003_7493; jr_003_747b DiskStatus&$01 set → jr_003_7493 else Jump_003_7498 E=0.
; Jump_003_749a add sp,$04 ret E.

Validate_B3::
    push af
    push af
    ld hl, sp+$06
    ld a, [hl+]
    or [hl]
    jp z, Jump_003_7493

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
    jp z, Jump_003_7493

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
    jp z, Jump_003_7493

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
    jp nz, Jump_003_7478

    inc hl
    ld a, [hl]
    sub b
    jp nz, Jump_003_7478

    jr jr_003_747b

Jump_003_7478:
    jp Jump_003_7493


jr_003_747b:
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
    jr nz, jr_003_7493

    jp Jump_003_7498


Jump_003_7493:
jr_003_7493:
    ld e, $09
    jp Jump_003_749a


Jump_003_7498:
    ld e, $00

Jump_003_749a:
    add sp, $04
    ret


; [ezgb]
; Fsync_B3(fp): FatFs f_sync. Frame -$10; Validate_B3 fail → Jump_003_768b.
; fp->flag FA_DIRTY ($20) → jr_003_74d1 else Jump_003_768b E=0.
; jr_003_74d1: FA_DIRTY winsect ($40) → jr_003_74d9 FarCallDiskWrite; ok Jump_003_7536 clear dirty bit else E=$01 Jump_003_768c.
; Jump_003_7544: MoveWindow_B3 update dir fsize/attr; StClust_B3 + RtcReadPage timestamp; clear FA_WRITTEN; SyncFs_B3 → Jump_003_768b.
; Jump_003_768b/Jump_003_768c add sp,$10 ret E.

Fsync_B3::
    add sp, -$10
    ld hl, sp+$12
    ld c, [hl]
    inc hl
    ld b, [hl]
    push bc
    call Validate_B3
    add sp, $02
    ld c, e
    ld b, c
    xor a
    or b
    jp nz, Jump_003_768b

    ld hl, sp+$12
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$06
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
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld c, a
    and $20
    jr nz, jr_003_74d1

    jp Jump_003_768b


jr_003_74d1:
    ld a, c
    and $40
    jr nz, jr_003_74d9

    jp Jump_003_7544


jr_003_74d9:
    ld hl, sp+$06
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
    ld [hl+], a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0020
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$06
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
    ld a, c
    push af
    inc sp
    call FarCallDiskWrite
    add sp, $09
    ld c, e
    xor a
    or c
    jp z, Jump_003_7536

    ld e, $01
    jp Jump_003_768c


Jump_003_7536:
    ld hl, sp+$08
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

Jump_003_7544:
    ld hl, sp+$06
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
    ld [hl+], a
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
    call MoveWindow_B3
    add sp, $06
    ld c, e
    ld b, c
    xor a
    or b
    jp nz, Jump_003_768b

    ld hl, sp+$06
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
    ld hl, $000b
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld c, a
    or $20
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $001c
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$06
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
    ld hl, sp+$00
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
    ld [hl-], a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call StClust_B3
    add sp, $06
    call RtcReadPage
    push hl
    ld hl, sp+$0e
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
    ld hl, $0016
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld hl, sp+$0c
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
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $df
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$06
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
    ld hl, $0004
    add hl, de
    ld c, l
    ld b, h
    ld a, $01
    ld [bc], a
    ld hl, sp+$00
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call SyncFs_B3
    add sp, $02
    ld c, e
    ld b, c

Jump_003_768b:
    ld e, b

Jump_003_768c:
    add sp, $10
    ret


; [ezgb]
; Close_B3(fp): FatFs f_close. Fsync_B3 then Validate_B3; clears FIL fs ptr.
; Target of FarCall_03_768f; orphan after Fsync path epilogue Jump_003_768c.

Close_B3::
    dec sp
    ld hl, sp+$07
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Fsync_B3
    add sp, $02
    ld c, e
    ld hl, sp+$00
    ld [hl], c
    xor a
    or [hl]
    jp nz, Jump_003_76c6

    ld hl, sp+$07
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Validate_B3
    add sp, $02
    ld b, e
    ld hl, sp+$00
    ld [hl], b
    xor a
    or [hl]
    jp nz, Jump_003_76c6

    ld hl, sp+$07
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld e, c
    ld d, b
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a

Jump_003_76c6:
    ld hl, sp+$00
    ld e, [hl]
    add sp, $01
    ret


; [ezgb]
; Lseek_B3(fp, ofs): FatFs f_lseek. Validate_B3; U32Shl/Mod; CreateChain_B3 to
; extend; GetFat_B3 + Clust2Sect_B3. FarCall disk R/W helpers. -$29 frame.
; Target of FarCall_03_76cc; orphan after Jump_003_76c6.
; Validate_B3 fail → Jump_003_7eac; else Jump_003_76e6: fp->err nonzero → Jump_003_7eac else Jump_003_7707.
; Jump_003_7707: if ofs > fsize and not FA_WRITE (jr_003_774f/Jump_003_7752 clamp ofs=fsize); join Jump_003_7763 clear fptr.
; Jump_003_7763: ofs==0 → Jump_003_7cf6; else U32Shl csize; if fptr==0 Jump_003_793c (from sclust) else U32Mod cluster align — same-cluster Jump_003_7a29 else Jump_003_793c restart from sclust.
; Jump_003_793c: start from sclust; empty → CreateChain_B3 (clust==1 Jump_003_79bf/jr_003_79c2 E=$02; else Jump_003_79cf: clust==-1 jr_003_79ed E=$01; Jump_003_79ea/Jump_003_79fa write sclust); join Jump_003_7a0c set clust.
; Jump_003_7a29: clust==0 → Jump_003_7cf6; else Jump_003_7a43: while bc < ofs — FA_WRITE jr_003_7a68 CreateChain_B3 else Jump_003_7abf GetFat_B3; fail jr_003_7b15 E=$01 / Jump_003_7b6c E=$02; ok Jump_003_7af7/Jump_003_7b12/Jump_003_7b22; past EOF Jump_003_7b79 → Jump_003_7a43 else Jump_003_7c08.
; Jump_003_7c08: set fptr; zero ofs→Jump_003_7cf6 else jr_003_7c62 Clust2Sect_B3; sect ok Jump_003_7cb2 U32Shr sector offset else E=$02 → Jump_003_7eac.
; Jump_003_7cf6: same-sector jr_003_7d17 else Jump_003_7e2e; winsect mismatch Jump_003_7d58: dirty FA_DIRTY jr_003_7d71 FarCallDiskWrite else Jump_003_7dcc FarCallDiskRead; disk err E=$01 → Jump_003_7eac; Jump_003_7dbe clear FA_DIRTY; Jump_003_7e19 store winsect.
; Jump_003_7e2e: clamp fptr to fsize (Jump_003_7ea9); set FA_DIRTY if past; E from stack → Jump_003_7eac (add sp,$29 / ret).

Lseek_B3::
    add sp, -$29
    ld hl, sp+$2f
    ld c, [hl]
    inc hl
    ld b, [hl]
    push bc
    call Validate_B3
    add sp, $02
    ld c, e
    ld hl, sp+$28
    ld [hl], c
    xor a
    or [hl]
    jp z, Jump_003_76e6

    ld e, [hl]
    jp Jump_003_7eac


Jump_003_76e6:
    ld hl, sp+$2f
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0e
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
    ld hl, sp+$16
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld c, a
    or a
    jp z, Jump_003_7707

    ld e, c
    jp Jump_003_7eac


Jump_003_7707:
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000a
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$14
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld hl, sp+$10
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
    ld hl, sp+$31
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
    jp nc, Jump_003_7763

    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    and $02
    jr nz, jr_003_774f

    jp Jump_003_7752


jr_003_774f:
    jp Jump_003_7763


Jump_003_7752:
    ld hl, sp+$10
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

Jump_003_7763:
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0c
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
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld hl, sp+$0c
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
    ld hl, sp+$31
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, Jump_003_7cf6

    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    inc hl
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
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld a, $09
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
    call U32Shl
    add sp, $05
    push hl
    ld hl, sp+$22
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$18
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, Jump_003_793c

    ld hl, sp+$31
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    sub $01
    ld e, a
    ld a, d
    sbc $00
    push af
    ld hl, sp+$0b
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$35
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    sbc $00
    ld e, a
    ld a, d
    sbc $00
    ld hl, sp+$0b
    ld [hl-], a
    ld [hl], e
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
    ld hl, sp+$0e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Mod
    add sp, $08
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
    ld hl, sp+$18
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    sub $01
    ld e, a
    ld a, d
    sbc $00
    push af
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$1c
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
    jp c, Jump_003_793c

    ld hl, sp+$20
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    sub $01
    ld e, a
    ld a, d
    sbc $00
    push af
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    sbc $00
    ld e, a
    ld a, d
    sbc $00
    ld hl, sp+$03
    ld [hl-], a
    ld [hl], e
    dec hl
    dec hl
    ld a, [hl]
    cpl
    ld [hl+], a
    ld a, [hl]
    cpl
    ld [hl+], a
    ld a, [hl]
    cpl
    ld [hl+], a
    ld a, [hl]
    cpl
    ld [hl], a
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
    ld hl, sp+$31
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
    ld hl, sp+$34
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
    sbc [hl]
    ld e, a
    ld a, d
    inc hl
    sbc [hl]
    ld hl, sp+$34
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$0e
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
    ld hl, sp+$24
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
    jp Jump_003_7a29


Jump_003_793c:
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
    ld [hl], a
    ld hl, sp+$04
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
    ld hl, sp+$24
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_003_7a0c

    push bc
    ld hl, $0000
    push hl
    ld hl, $0000
    push hl
    ld hl, sp+$16
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call CreateChain_B3
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
    ld hl, sp+$24
    ld a, [hl]
    sub $01
    jp nz, Jump_003_79bf

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_79bf

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_79bf

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_003_79bf

    jr jr_003_79c2

Jump_003_79bf:
    jp Jump_003_79cf


jr_003_79c2:
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $02
    ld [de], a
    ld e, $02
    jp Jump_003_7eac


Jump_003_79cf:
    ld hl, sp+$24
    ld a, [hl]
    inc a
    jp nz, Jump_003_79ea

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_79ea

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_79ea

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_79ea

    jr jr_003_79ed

Jump_003_79ea:
    jp Jump_003_79fa


jr_003_79ed:
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    ld e, $01
    jp Jump_003_7eac


Jump_003_79fa:
    ld e, c
    ld d, b
    ld hl, sp+$24
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

Jump_003_7a0c:
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0012
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld hl, sp+$24
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

Jump_003_7a29:
    ld hl, sp+$24
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, Jump_003_7cf6

    ld hl, sp+$0e
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

Jump_003_7a43:
    ld hl, sp+$20
    ld d, h
    ld e, l
    ld hl, sp+$31
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
    jp nc, Jump_003_7c08

    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $02
    jr nz, jr_003_7a68

    jp Jump_003_7abf


jr_003_7a68:
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
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
    push bc
    call CreateChain_B3
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
    ld hl, sp+$24
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_003_7af7

    ld hl, sp+$20
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
    jp Jump_003_7c08


Jump_003_7abf:
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
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
    push bc
    call GetFat_B3
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

Jump_003_7af7:
    ld hl, sp+$24
    ld a, [hl]
    inc a
    jp nz, Jump_003_7b12

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_7b12

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_7b12

    inc hl
    ld a, [hl]
    inc a
    jp nz, Jump_003_7b12

    jr jr_003_7b15

Jump_003_7b12:
    jp Jump_003_7b22


jr_003_7b15:
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    ld e, $01
    jp Jump_003_7eac


Jump_003_7b22:
    ld a, $01
    ld hl, sp+$24
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
    jp nc, Jump_003_7b6c

    ld hl, sp+$0e
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
    ld hl, sp+$24
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
    jp c, Jump_003_7b79

Jump_003_7b6c:
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $02
    ld [de], a
    ld e, $02
    jp Jump_003_7eac


Jump_003_7b79:
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0012
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld hl, sp+$24
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
    ld hl, sp+$0c
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
    ld hl, sp+$31
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
    ld hl, sp+$34
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
    ld hl, sp+$34
    ld [hl-], a
    ld [hl], e
    jp Jump_003_7a43


Jump_003_7c08:
    ld hl, sp+$0c
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
    ld hl, sp+$31
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
    ld hl, sp+$35
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
    ld hl, sp+$31
    ld a, [hl]
    or a
    jr nz, jr_003_7c62

    inc hl
    ld a, [hl]
    and $01
    jr nz, jr_003_7c62

    jp Jump_003_7cf6


jr_003_7c62:
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
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
    push bc
    call Clust2Sect_B3
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
    ld hl, sp+$1c
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Jump_003_7cb2

    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $02
    ld [de], a
    ld e, $02
    jp Jump_003_7eac


Jump_003_7cb2:
    ld a, $09
    push af
    inc sp
    ld hl, sp+$34
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$34
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
    ld hl, sp+$1c
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
    ld hl, sp+$1f
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
    ld hl, sp+$1f
    ld [hl-], a
    ld [hl], e

Jump_003_7cf6:
    ld hl, sp+$0c
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
    or a
    jr nz, jr_003_7d17

    inc hl
    ld a, [hl]
    and $01
    jr nz, jr_003_7d17

    jp Jump_003_7e2e


jr_003_7d17:
    ld hl, sp+$0e
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
    ld hl, sp+$1c
    ld a, [hl]
    ld hl, sp+$00
    sub [hl]
    jp nz, Jump_003_7d58

    ld hl, sp+$1d
    ld a, [hl]
    ld hl, sp+$01
    sub [hl]
    jp nz, Jump_003_7d58

    ld hl, sp+$1e
    ld a, [hl]
    ld hl, sp+$02
    sub [hl]
    jp nz, Jump_003_7d58

    ld hl, sp+$1f
    ld a, [hl]
    ld hl, sp+$03
    sub [hl]
    jp z, Jump_003_7e2e

Jump_003_7d58:
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld c, a
    and $40
    jr nz, jr_003_7d71

    jp Jump_003_7dcc


jr_003_7d71:
    ld hl, sp+$0e
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
    ld hl, sp+$0e
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
    ld hl, sp+$16
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld a, c
    push af
    inc sp
    call FarCallDiskWrite
    add sp, $09
    ld c, e
    xor a
    or c
    jp z, Jump_003_7dbe

    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    ld e, $01
    jp Jump_003_7eac


Jump_003_7dbe:
    ld hl, sp+$04
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

Jump_003_7dcc:
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0020
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
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    inc bc
    ld a, [bc]
    ld c, a
    ld hl, $0001
    push hl
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
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld a, c
    push af
    inc sp
    call FarCallDiskRead
    add sp, $09
    ld c, e
    xor a
    or c
    jp z, Jump_003_7e19

    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    ld e, $01
    jp Jump_003_7eac


Jump_003_7e19:
    ld hl, sp+$08
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
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a

Jump_003_7e2e:
    ld hl, sp+$0c
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
    ld hl, sp+$14
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
    jp nc, Jump_003_7ea9

    ld hl, sp+$0c
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
    ld hl, sp+$14
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
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld c, a
    or $20
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a

Jump_003_7ea9:
    ld hl, sp+$28
    ld e, [hl]

Jump_003_7eac:
    add sp, $29
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
