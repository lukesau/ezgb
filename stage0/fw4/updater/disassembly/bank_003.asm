; Disassembly of "updater-code.gb"
; This file was created with:
; mgbdis v3.0 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $003", ROMX[$4000], BANK[$3]

Call_003_4000:
    add hl, bc
    sub b
    nop
    or b
    ld c, $20
    cp l
    db $10
    or b
    nop
    ld [$000a], sp
    ld [hl], b
    nop
    dec b
    nop
    nop
    dec b
    nop

jr_003_4014:
    nop
    nop
    nop
    nop

Call_003_4018:
    nop
    nop
    nop
    nop
    add h
    nop
    ld b, $0e
    ld b, $08
    ld a, h
    ld [hl], $22

jr_003_4025:
    inc d
    jr z, jr_003_4028

jr_003_4028:
    add b
    add b
    ret nc

    ld [bc], a
    nop
    inc d
    jr c, @+$42

    add b
    ld [bc], a
    nop
    jr nc, @+$0a

    nop
    jr jr_003_4038

jr_003_4038:
    and c
    nop
    ld [bc], a
    ld sp, $8000
    ld d, b
    ld [$1010], sp
    jr nz, jr_003_40a8

    nop
    ld bc, $0035
    nop
    ld [hl], h
    ld a, l
    nop
    inc b
    ld [hl], b
    ld bc, $0031
    nop
    ld [hl], b
    ld h, c
    xor b
    db $20, $a2
    jr nc, jr_003_4059

jr_003_4059:
    ld [$01d4], sp
    nop
    ld hl, $3031
    ld a, h
    ld h, h
    nop
    ld h, b
    db $10
    jr nz, @+$3e

    ldh a, [$ffb2]
    inc h
    ld h, $c0
    ld [$1020], sp
    ld [$0433], sp
    ld l, e
    nop
    db $30, $80
    ld d, b
    jr nc, jr_003_40a9

    inc b
    ld d, b
    jr nc, jr_003_40cd

    ld a, [hl-]
    ret c

    ld [$1500], sp
    jr nz, jr_003_4014

    nop
    ld sp, $365c
    nop
    sbc d
    ld b, e
    dec b
    inc l
    dec d
    ld [hl], l
    or b
    ld d, h
    inc b
    ld d, b
    ld a, [bc]
    ld a, h
    nop
    ld a, d
    dec hl
    ld [$501c], sp
    nop
    ld d, b
    jr jr_003_4025

    inc b
    ld a, b
    ld d, b
    ld h, $0d
    ld hl, $0d80
    inc b

jr_003_40a8:
    nop

jr_003_40a9:
    nop
    jr nc, @+$08

    ld [hl], b
    inc de
    ld d, b
    ld b, c
    ld [$0c28], sp
    inc e
    ld hl, $5020
    inc c
    ld a, b
    call nc, $3608
    ld [$2193], sp
    ld e, $10
    ld [$260d], sp
    ld [$01b1], sp
    ld b, [hl]
    add hl, sp
    ld de, $3608
    ld l, h

jr_003_40cd:
    jr z, jr_003_40cf

jr_003_40cf:
    ld c, h
    ld a, h
    nop
    inc e
    jr jr_003_410d

    jp c, Jump_000_3c58

    inc d
    ld a, [hl-]
    sub [hl]
    ld [hl-], a
    inc l
    inc c
    inc [hl]
    ld [hl], h
    jr nz, jr_003_4102

    ld a, [hl+]
    or b
    ld d, $3c
    ld [de], a
    jr nc, jr_003_4139

    db $10
    ld [$1400], sp
    inc sp
    dec e
    ld de, $2470
    ld a, b
    ld [hl], $30
    inc a
    ld d, a
    jr z, jr_003_4175

    stop
    ld a, [hl-]
    inc c
    ld e, h
    inc e
    inc [hl]
    nop
    inc [hl]

jr_003_4102:
    and b
    nop
    inc a
    and b
    inc c
    sub b
    sub h
    ld [$1c38], sp
    inc c

jr_003_410d:
    db $10
    jr nz, jr_003_4120

    ld a, h
    db $10
    ld d, b
    ld [hl], h
    nop
    ld [hl], b
    stop
    jr nc, jr_003_4126

    jr nz, jr_003_411c

jr_003_411c:
    ld [$3130], sp
    db $10

jr_003_4120:
    jr nz, jr_003_4196

    nop
    ld [hl], b
    db $10
    db $10

jr_003_4126:
    ld h, b
    nop
    jr nz, jr_003_412a

jr_003_412a:
    ld [$080c], sp
    nop
    nop
    nop
    nop
    nop
    nop
    inc b
    nop
    nop
    nop
    inc b
    ld [bc], a

jr_003_4139:
    nop
    ld b, b
    nop
    ld [bc], a
    inc h
    nop
    nop
    nop
    nop
    ld [bc], a
    nop
    nop
    inc b
    nop
    inc b
    nop
    nop
    ld bc, $0804
    nop
    inc b
    nop
    nop
    nop
    ld b, b
    inc b
    nop
    ld [$0000], sp
    ld b, d
    nop
    ld b, b
    nop
    nop
    jr nz, jr_003_415f

jr_003_415f:
    jr nz, jr_003_4169

    db $10
    add b
    inc c
    ld [bc], a
    jr z, jr_003_416f

    nop
    inc c

jr_003_4169:
    ld bc, $0002
    ld b, d
    dec l
    ld b, d

jr_003_416f:
    ld [hl+], a
    nop
    inc b
    nop
    nop
    ld b, b

jr_003_4175:
    ld hl, $2040
    nop
    ld a, [bc]
    ld b, b
    db $10
    adc h
    nop
    inc b
    ld [bc], a
    nop
    nop
    nop
    inc c
    nop
    ld [$0485], sp
    nop
    inc b
    nop
    nop
    add b
    ld [$0c01], sp
    inc b
    nop
    nop
    ld [bc], a
    nop
    db $10

jr_003_4196:
    jr nz, jr_003_41b0

    ld [bc], a
    nop
    ld b, c
    nop
    nop
    inc c
    nop
    ld sp, $3c80
    nop
    nop
    ld b, b
    nop
    ld b, b
    jr nz, jr_003_41e9

    nop
    ld b, b
    nop
    ld [bc], a
    ld [bc], a
    add b
    add h

jr_003_41b0:
    add b
    nop
    nop
    jr nz, @+$4a

    inc c
    ld bc, $0080
    ld c, $00
    nop
    ld b, d
    ld de, $0480
    ld [bc], a
    ld [$3000], sp
    nop
    jr nz, jr_003_41c7

jr_003_41c7:
    inc b
    nop
    inc c
    ld b, b
    nop
    add b
    ld [bc], a
    adc d
    ld [bc], a

jr_003_41d0:
    ld b, b
    ld [hl+], a
    nop
    nop
    add b
    ld [$2040], sp
    add d
    nop
    add d
    nop
    ld [bc], a
    nop
    ld b, [hl]
    ld [bc], a
    ld b, b
    jr z, jr_003_4223

    nop
    ld [$8c21], sp
    nop
    ld b, [hl]

jr_003_41e9:
    db $10
    inc b
    ld [$0c08], sp
    nop
    ld c, $00
    ld [hl+], a
    ld [bc], a
    ld [bc], a
    add b
    nop
    add b
    ld [$1000], sp
    ld b, b
    nop
    ld bc, $0024
    ld [bc], a
    ld b, b
    ld b, $04
    nop
    ld h, b
    nop
    nop
    inc b
    inc b
    ld [bc], a
    ld b, $06
    nop
    nop
    nop
    inc b
    ld b, b
    ld c, $00
    ld [bc], a
    nop
    ld [$0001], sp
    nop
    nop
    nop
    nop
    nop
    ld [$0e00], sp
    nop
    ld [bc], a
    nop

jr_003_4223:
    nop
    nop
    ld [hl-], a
    nop
    nop
    nop
    ld [bc], a
    inc b
    nop
    nop
    nop
    ld [bc], a
    jr nz, jr_003_4231

jr_003_4231:
    ld [bc], a
    nop
    ld [bc], a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [bc], a
    nop
    nop
    nop
    add b
    inc b
    nop
    jr nz, jr_003_41d0

    nop
    add c
    nop
    nop
    jr nz, jr_003_4256

jr_003_4256:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$0002], sp
    inc c
    ld de, $0000
    nop
    jr nz, jr_003_4268

jr_003_4268:
    nop
    add hl, bc
    nop
    nop
    inc h
    nop
    nop
    nop
    nop
    nop
    nop
    ld [bc], a
    ld bc, $2080
    nop
    inc b
    nop
    ld bc, $0000
    nop

jr_003_427e:
    ld [$0c00], sp
    nop
    inc h
    ld [$0000], sp
    nop
    nop
    nop
    inc b
    nop
    add b
    db $10
    inc b
    nop
    add b
    ld hl, $0540
    ld c, b
    nop
    nop
    stop
    nop
    ld [$0126], sp
    nop
    nop
    nop
    nop
    nop
    add hl, bc
    nop
    nop
    nop
    nop
    nop
    inc b
    nop
    add b
    ld h, b
    add b
    nop
    ld [bc], a
    inc h
    nop
    nop
    nop
    nop
    ld b, b
    nop
    ld b, b
    nop
    ld bc, $0020
    jr nz, jr_003_42bc

jr_003_42bc:
    jr nz, jr_003_42be

jr_003_42be:
    nop
    ld bc, $0004
    ld [$2090], sp
    nop
    nop
    ld b, b
    ld [bc], a
    dec c
    ld [$0050], sp
    nop
    nop
    nop
    nop
    ld b, h
    nop
    add c
    nop
    nop
    nop
    ld b, c
    ld [$0001], sp
    nop
    nop
    ld bc, $0020
    jr nc, jr_003_42ee

    dec h
    ld b, b
    jr nz, jr_003_432e

    stop
    jr nz, jr_003_432a

    jr nz, @+$42

    inc b
    nop

jr_003_42ee:
    jr nz, jr_003_42f2

    dec c
    nop

jr_003_42f2:
    dec l
    inc b
    nop
    nop
    nop
    nop
    ld [bc], a
    inc b
    dec l
    nop
    jr z, jr_003_427e

    nop
    nop
    nop
    dec c
    inc b
    inc c
    ld [$0800], sp
    inc c
    jr nz, jr_003_430a

jr_003_430a:
    jr nc, @+$22

    nop
    add b
    jr nz, jr_003_4350

    ld [$0402], sp
    inc c
    jr nz, jr_003_431e

    nop
    nop
    nop
    nop
    inc b
    ld bc, $0400

jr_003_431e:
    ld [$0006], sp
    ld [bc], a
    inc b
    ld bc, $0420
    nop
    inc b
    nop
    add hl, bc

jr_003_432a:
    ld [$0000], sp
    nop

jr_003_432e:
    nop
    nop
    nop
    nop
    inc b
    inc b
    nop
    nop
    nop
    nop
    nop
    ld b, b
    nop
    nop
    nop
    inc b
    nop
    nop
    nop
    nop
    ld [$0000], sp
    inc b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_4350:
    nop
    nop
    nop
    nop
    nop
    ld c, $00
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld c, e
    jr nz, jr_003_4362

jr_003_4362:
    nop
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_003_436a

jr_003_436a:
    nop
    nop
    nop
    jr jr_003_436f

jr_003_436f:
    ld [$0800], sp
    nop
    nop
    ld [$200c], sp
    nop
    nop
    nop
    nop
    ld [$0400], sp
    nop
    nop

Jump_003_4380:
    nop
    stop
    stop
    stop
    stop
    nop
    nop
    ld [$1800], sp
    nop
    nop
    ld [$0000], sp
    nop
    nop
    jr jr_003_4397

jr_003_4397:
    stop
    ld [$0400], sp
    nop
    stop
    nop
    jr nz, jr_003_43ba

    nop
    nop
    nop
    nop
    rlca
    nop
    nop
    nop
    jr nz, jr_003_43b4

    nop
    inc c
    add b
    add b
    nop
    jr jr_003_43b3

jr_003_43b3:
    nop

jr_003_43b4:
    nop
    inc b
    nop
    jr @+$0a

    nop

jr_003_43ba:
    nop
    nop
    jr nz, jr_003_43be

jr_003_43be:
    inc l
    ld [$0000], sp
    ld [$0000], sp
    ld [$0008], sp
    nop
    ld [$0000], sp
    ld [$0000], sp
    stop
    nop
    nop
    nop
    ld [$45c0], sp
    inc c
    nop
    stop
    nop
    nop
    inc b
    ld b, c
    nop
    ld [$0008], sp
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$0004], sp
    inc b
    stop
    ld [$0000], sp
    ld [bc], a
    ld b, b
    nop
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_003_43fc

jr_003_43fc:
    nop
    ld [$0000], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    stop
    jr jr_003_440b

jr_003_440b:
    nop
    nop
    db $10
    inc b
    nop
    ld [$0800], sp
    ld [$0408], sp
    inc b
    ld [$1004], sp
    nop
    nop
    nop
    nop
    nop
    jr z, jr_003_4421

jr_003_4421:
    nop
    nop
    nop
    nop
    db $10
    inc b
    stop
    ld [$0008], sp
    db $10
    db $10
    inc b
    nop
    ld [$0800], sp
    nop
    nop
    nop
    inc b
    stop
    ld [$0000], sp
    nop
    inc b
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$0408], sp
    ld [$0000], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$0000], sp
    nop
    nop
    stop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld de, $0000
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ccf
    ld [hl], a
    rst RST_38
    cp a
    rst RST_38
    rst RST_38
    ld bc, $0300
    nop
    ld d, l
    push de
    or l
    ld d, c
    di
    ret nz

    inc bc
    inc sp
    rst RST_38
    rst RST_38
    db $e4
    call z, $c0f3
    rst RST_38
    ldh a, [$fffc]
    inc c
    rst RST_08
    ret nz

    rst RST_38
    rst RST_38
    cp e
    di
    rst RST_38
    ldh a, [rIE]
    rst RST_38
    rst RST_38
    rst RST_38
    ldh a, [$ffcc]
    rst RST_08
    ret nz

    xor c
    ld e, c
    rrca
    nop
    di
    ret nz

    db $fc
    jr nc, @+$01

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    db $e4
    add b
    nop
    rst RST_08
    ret nz

    rst RST_08
    ret nz

    rst RST_38
    rst RST_38
    inc c
    nop
    add b
    nop
    rst RST_18
    adc d
    add b
    nop
    ldh a, [rP1]
    rst RST_38
    rst RST_38
    add b
    nop
    db $dd
    ret nc

    push af
    call nz, $d0dd
    db $fc
    ld d, h
    xor $e0
    ld a, [$ac3a]
    db $fc
    rst RST_08
    adc d
    cp a
    or b
    rst RST_08
    adc d
    ld a, [$fa3a]
    ld a, [hl-]
    db $fc
    xor b
    push af
    call nz, $a8fc
    xor $e0
    db $fc
    xor b
    ret z

    ld a, [$e0ee]
    nop
    inc bc
    nop
    rrca
    ldh a, [rP1]
    rst RST_28
    rst RST_38
    xor $e0
    rst RST_38
    rst RST_28
    ld a, [$ffc8]
    rst RST_38
    rst RST_38
    rrca
    nop
    ld b, b
    rst RST_38
    rst RST_28
    db $fc
    xor b
    ccf
    rst RST_38
    db $fc
    xor b
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_18
    db $fc
    xor b
    rst RST_08
    ret nz

    rst RST_08
    ret nz

    rst RST_08
    ret nz

    db $fc
    inc c
    rst RST_38
    cp $fc
    xor b
    rst RST_38
    cp $fa
    ret z

    db $fc
    xor b
    db $fc
    rst RST_38
    cp a
    or b
    rst RST_38
    rst RST_38
    rst RST_18
    adc d
    rst RST_18
    adc d
    cp a
    adc h
    xor $4e
    cp b
    db $fc
    xor $2e
    push af
    pop af
    and b
    jr nz, @+$01

    rst RST_30
    rst RST_38
    ldh a, [$fffa]
    ret z

    xor a

jr_003_4539:
    adc h
    db $fc
    jr nc, jr_003_4539

    jr nc, @+$01

    rst RST_38
    inc c
    jr nc, @-$0b

jr_003_4543:
    ret nz

    db $fc
    jr nc, jr_003_4543

    jr nc, @-$0b

    ret nz

    db $fc
    xor d
    cp a
    adc h
    ld a, [$fcee]
    inc c
    rst RST_38
    rst RST_38
    call z, $ccc4
    ret z

    rst RST_38
    rst RST_38
    ld a, [$0afc]
    inc c
    ld a, [$fac8]
    ret z

    rst RST_38
    db $fc
    call c, $ee8c
    ldh [rIE], a
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    inc c
    nop
    call z, Call_000_00ca
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    ld bc, $3020
    nop
    ld bc, $7024
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    ld bc, $7024
    nop
    nop
    inc c
    ld a, b
    nop
    nop
    inc c
    ld a, b
    nop
    add hl, bc
    jr z, jr_003_45d5

    nop
    ld bc, $7024
    nop
    dec c
    ld [hl+], a
    ld bc, $0940
    inc h
    ld a, b
    nop
    ld bc, $7024
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    dec c
    ld [hl+], a
    ld bc, $0140
    inc h
    ld [hl], b
    nop
    inc de
    jr nz, jr_003_45f5

    inc b
    ld bc, $3020
    nop
    nop
    inc b
    ld a, b
    nop
    ld bc, $7024
    nop
    ld bc, $7024

jr_003_45d5:
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    nop
    inc b
    ld a, b
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    ld bc, $3020
    nop
    ld bc, $7024

jr_003_45f5:
    nop
    nop
    inc b
    ld a, b
    nop
    ld bc, $7024
    nop
    ld bc, $7824
    nop
    ld bc, $3020
    nop
    ld bc, $3020
    nop
    dec c
    ld h, $71
    nop
    ld bc, $3020
    nop
    ld bc, $3020
    nop
    ld bc, $3020
    nop
    ld bc, $3020
    nop
    ld [de], a
    inc c
    ld a, b
    inc b
    ld [de], a
    inc c
    ld a, b
    inc b
    ld bc, $3020
    nop
    ld bc, $3020
    nop
    ld bc, $3020
    nop
    add hl, bc
    jr nz, jr_003_4665

    nop
    add hl, bc
    inc h
    ld a, b
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    ld bc, $3020
    nop
    ld bc, $7024
    nop
    ld bc, $3020
    nop
    inc de
    jr nz, jr_003_4681

    inc b
    ld bc, $3020
    nop
    inc de
    jr nz, jr_003_4689

    inc b
    inc de
    jr nz, jr_003_468d

    inc b
    nop
    inc b
    ld a, b
    nop
    ld bc, $3020

jr_003_4665:
    nop
    dec c
    ld h, $71
    nop
    ld bc, $7024
    nop
    ld [de], a
    inc b
    ld a, b
    inc b
    ld bc, $7024
    nop
    nop
    inc b
    ld a, b
    nop
    nop
    nop
    jr nc, jr_003_467e

jr_003_467e:
    ld bc, $7024

jr_003_4681:
    nop
    nop
    inc b
    ld a, b
    nop
    nop
    nop
    nop

jr_003_4689:
    nop
    nop
    nop
    nop

jr_003_468d:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0020
    nop
    dec de
    add hl, hl
    ld [bc], a
    sub l
    di
    ld hl, $8d06
    nop
    dec c
    ld c, b
    inc d
    or e
    dec h
    ld b, d
    sbc l
    or e
    ld hl, $8d02
    add hl, bc
    inc l
    ld c, b
    nop
    add hl, bc
    inc l
    ld c, b
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    ld bc, $4024
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    ld bc, $4024
    nop
    nop
    inc b
    ld c, b
    nop
    nop
    inc b
    ld c, b
    nop
    nop
    inc b
    ld c, b
    nop
    ld bc, $0020
    nop
    nop
    inc b
    ld c, b
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    ld bc, $4024
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    nop
    inc b
    ld c, b
    nop
    nop
    inc b
    ld c, b
    nop
    nop
    inc b
    ld c, b
    nop
    nop
    inc b
    ld c, b
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    ld bc, $4024
    nop
    ld bc, $0020
    nop
    ld [de], a
    inc c
    ld c, b
    inc b
    ld [de], a
    inc c
    ld c, b
    inc b
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    ld bc, $4024
    nop
    nop
    inc b
    ld c, b
    nop
    ld bc, $4024
    nop
    ld [de], a
    inc b
    ld c, b
    inc b
    ld bc, $4024
    nop
    ld bc, $0020
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    add hl, bc
    jr nz, jr_003_4761

jr_003_4761:
    nop
    nop
    inc b
    ld c, b
    nop
    ld bc, $4024
    nop
    ld bc, $0020
    nop
    ld [de], a
    inc b
    ld c, b
    inc b
    inc de
    jr nz, jr_003_4775

jr_003_4775:
    inc b
    nop
    inc b
    ld c, b
    nop
    or e
    dec h
    ld b, [hl]
    sbc l
    di
    ld hl, $9d06
    di
    dec h
    ld b, [hl]
    sbc l
    di
    dec h
    ld b, d
    dec e
    or e
    dec h
    ld b, d
    dec e
    inc sp
    dec h
    ld b, d
    sbc l
    or e
    ld hl, $8d02
    nop
    inc b
    ld c, b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$0000], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rst RST_38
    rst RST_38

jr_003_47b0:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    nop
    rrca
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    nop
    jr nz, @+$01

    rst RST_38
    inc bc
    nop
    inc bc
    nop
    rst RST_38
    nop

jr_003_47c4:
    nop
    rst RST_38
    call z, $ccf0
    ldh a, [$fff0]
    call z, $ccf0
    db $fc
    jr nc, jr_003_47c4

    ret nz

    di
    ret nz

    db $fc
    jr nc, @-$2f

    ret nz

    rst RST_08
    ret nz

    db $fc
    db $dd
    inc c
    rrca
    db $fc
    jr nc, jr_003_47b0

    ret nz

    db $fc
    inc c
    call z, $fff0
    ld e, l
    rst RST_38
    rst RST_28
    di
    rst RST_38
    cp a
    rst RST_38
    rst RST_28
    db $ec
    xor $f0
    rst RST_38
    cp $f3
    xor d
    add b
    nop
    rst RST_38
    ldh a, [rIE]
    ei
    xor $2e
    xor $0e
    ldh [$ffee], a
    rst RST_38
    rst RST_38

Jump_003_4804:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    xor $ef
    rst RST_38
    ldh a, [rIE]
    rst RST_38
    ldh [c], a
    rst RST_38
    rst RST_38
    db $fd
    cp e
    or b
    push af
    call nz, $8acf
    rst RST_38
    cp b
    di
    and d
    db $fc
    xor b
    db $fc
    ld [hl], h
    xor $e0
    db $fc
    ld [hl], h
    xor $e0
    db $e4
    xor $7f
    rst RST_38
    nop
    inc c
    rst RST_38
    cp $fa
    ret z

    db $fc
    rst RST_38
    rst RST_38
    db $fd
    rst RST_38
    rst RST_28
    rst RST_38
    cp a
    nop
    db $10

jr_003_483c:
    rst RST_38
    rst RST_28
    xor $e0

jr_003_4840:
    xor b
    db $fc
    ei
    rst RST_38
    xor $e0
    db $fc
    jr nc, jr_003_483c

    ret nz

    db $fc
    jr nc, jr_003_4840

    ret nz

    rst RST_38
    db $fd
    xor $e0
    db $fd
    rst RST_38
    ld a, [$fcc8]
    xor b
    db $fc
    xor b
    db $dd
    ret nc

    rst RST_18
    adc d
    db $dd
    call $40c0
    xor h
    and b
    db $fc
    inc c
    xor b
    db $fc
    rst RST_38
    rst RST_38
    cp e
    or b
    ld a, [$fac8]
    ld a, [hl-]
    xor h
    db $fc
    call $ffc8
    rst RST_38
    ld a, [$fc32]
    nop
    ldh a, [rIE]
    ldh a, [$ffe0]
    ld b, h
    ld c, h

Call_003_4880:
    nop
    ret z

    call z, Call_000_0080
    ret z

jr_003_4886:
    rst RST_08
    ret nz

    db $fc
    inc c
    xor $e0
    di
    xor d

jr_003_488e:
    ld d, l
    ld d, l
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38

jr_003_4896:
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    ld a, a
    rst RST_38
    nop
    inc a

jr_003_489e:
    nop
    ld [de], a
    inc bc
    inc c
    inc bc
    inc c
    nop
    ld [de], a

jr_003_48a6:
    nop
    ld [de], a
    nop
    ld [de], a
    nop
    inc c
    xor d
    xor h
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_48b6:
    ld [$0800], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    or c
    sub b
    ld d, b
    jr nz, jr_003_48cb

    ld a, [bc]
    ld [$c280], sp

jr_003_48cb:
    ld [$2050], sp

jr_003_48ce:
    inc b
    ld a, [bc]
    ld [$ce00], sp
    ld [$2050], sp
    inc b
    ld a, [bc]
    nop
    jr nc, jr_003_48db

jr_003_48db:
    nop
    ld d, b
    jr nz, jr_003_48e3

    ld a, [bc]
    dec d
    ld a, [hl+]
    nop

jr_003_48e3:
    inc c
    ld d, b
    jr nz, @+$06

    ld a, [bc]
    nop
    ld h, b
    ld c, $90
    ld d, b
    jr nz, jr_003_48f3

    ld a, [bc]
    nop
    nop
    nop

jr_003_48f3:
    nop
    ld d, b
    jr nz, @+$06

    ld a, [bc]
    nop
    ld b, b
    ld bc, $20c0
    jr nz, jr_003_4900

    inc d

jr_003_4900:
    jr nz, jr_003_4953

    nop
    inc b
    jr z, jr_003_4886

jr_003_4906:
    ld bc, $0014
    ld [$0c01], sp
    jr z, jr_003_488e

    ld bc, $021a
    nop
    ld [hl+], a
    nop
    jr z, jr_003_4896

jr_003_4916:
    ld bc, $3214
    ld [hl], e
    add d
    nop
    jr z, jr_003_489e

    ld bc, $3514
    db $eb
    ld c, b
    nop
    jr z, jr_003_48a6

    ld bc, $3114
    rst RST_20
    ld bc, $281c
    add b
    ld bc, $1314
    ld h, [hl]
    nop
    ret nz

    jr z, jr_003_48b6

    ld bc, $1514
    ld a, [hl-]
    inc hl
    jr nc, @+$2a

    add b
    ld bc, $1114
    ld l, $cc
    inc c
    jr z, @-$7e

    ld bc, $2014
    add c
    adc [hl]
    sub b
    jr z, jr_003_48ce

    ld bc, $2414
    ret


    rst RST_08

jr_003_4953:
    ld [$8028], sp
    ld bc, $2214
    pop de
    nop
    nop
    jr nc, @-$7e

    ld bc, $080c
    ld h, e
    ld [hl+], a
    sbc h
    jr z, @-$7e

    ld bc, $0414
    ld [$0480], sp
    jr z, @-$7e

    ld bc, $1214
    db $10
    add b
    nop
    jr z, jr_003_4996

    ld bc, $0014
    ld [hl], e
    ret


    db $10
    jr z, @-$7e

    ld bc, $3114
    db $eb
    inc bc
    cp h
    jr z, jr_003_4906

    ld bc, $3114
    rst RST_28
    ld [$2808], sp
    add b
    ld bc, $3014
    ld [hl+], a
    ld d, c
    sbc h
    jr z, jr_003_4916

jr_003_4996:
    ld bc, $1714
    ld a, [hl+]
    nop
    nop
    ld c, b
    add b
    ld bc, $0114
    ld h, $c0
    nop
    and b
    jr nz, jr_003_49ab

    dec b
    jr nz, jr_003_49aa

jr_003_49aa:
    nop

jr_003_49ab:
    inc c
    ret nz

    jr nz, @+$06

    dec b
    nop
    ld bc, $0800
    ret nz

    jr nz, jr_003_49b7

jr_003_49b7:
    inc b
    nop
    add hl, bc
    inc c
    db $10
    ld c, b
    add b
    ld bc, $0212
    ret nc

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$0000], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add e
    inc b
    stop
    nop
    ld [$8000], sp
    xor e
    inc d
    stop
    nop
    ld [$8000], sp
    adc e
    inc d
    stop
    nop
    ld [$0000], sp
    add e
    inc b
    stop
    nop
    ld [$2002], sp
    add e
    inc d
    sub b
    jr nz, jr_003_49fb

jr_003_49fb:
    ld [$4400], sp
    add e
    inc b
    sub b
    nop
    nop
    add hl, bc
    nop
    nop
    add e
    inc b
    sub b
    jr nz, jr_003_4a0b

jr_003_4a0b:
    add hl, bc
    nop
    ld b, h
    sub e
    inc h
    inc d
    nop
    nop
    jr nz, jr_003_4a36

    ld d, c
    add e
    inc h
    inc b
    nop
    nop
    jr nz, jr_003_4a43

    pop hl
    jp Jump_000_0454


    nop
    nop
    nop
    ld hl, $83e0
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_4a4e

    pop de
    or e
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_4a57

    pop hl

jr_003_4a36:
    adc e
    inc b
    inc b
    nop
    nop
    jr nz, @+$36

    ret


    add e
    inc d
    inc b
    nop
    nop

jr_003_4a43:
    jr nz, jr_003_4a66

    pop de
    add e
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_4a6f

    pop bc

jr_003_4a4e:
    add e
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_4a89

    pop bc
    adc e

jr_003_4a57:
    inc d
    inc b
    nop
    nop
    jr nz, jr_003_4a91

    ret


    sub e
    inc d
    inc b
    nop
    nop
    jr nz, jr_003_4a87

    pop hl

jr_003_4a66:
    sub e
    inc e
    inc b
    nop
    nop
    jr nz, jr_003_4a8e

    pop de
    add e

jr_003_4a6f:
    inc b
    stop
    nop
    ld [$c728], sp
    adc e
    inc d
    inc b
    nop
    nop
    jr nz, jr_003_4a9f

    pop hl
    adc e
    inc h
    inc b
    nop
    nop
    jr nz, jr_003_4aa9

    pop de
    sub e

jr_003_4a87:
    inc b
    inc b

jr_003_4a89:
    nop
    nop
    jr nz, jr_003_4aae

    ld d, c

jr_003_4a8e:
    jp Jump_000_0404


jr_003_4a91:
    nop
    nop
    jr nz, jr_003_4ab8

    pop hl
    add a
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_4ac3

    pop bc
    add e

jr_003_4a9f:
    inc e
    inc b
    nop
    nop
    jr nz, jr_003_4ad9

    push de
    add e
    inc h
    inc b

jr_003_4aa9:
    nop
    nop
    jr nz, jr_003_4acd

    pop hl

jr_003_4aae:
    add e
    inc c
    ld [$0000], sp
    jr nz, jr_003_4ac5

    ret


    sub e
    inc b

jr_003_4ab8:
    inc b
    nop
    nop
    jr nz, jr_003_4ade

    ld bc, $1483
    ld [$0000], sp

jr_003_4ac3:
    jr nz, jr_003_4ac5

jr_003_4ac5:
    add hl, bc
    add d
    add h
    ld [$0000], sp
    jr nz, jr_003_4acd

jr_003_4acd:
    ld bc, $0483
    ld [$0000], sp
    stop
    ret nz

    nop
    nop
    nop

jr_003_4ad9:
    nop
    nop
    nop
    nop
    nop

jr_003_4ade:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [hl+], a
    and b
    ret nz

    nop
    ret nz

    rlc b
    ldh [rP1], a
    nop
    add c
    ret nz

    ld b, b
    inc bc
    nop
    ld b, b
    inc de
    ld b, d
    nop
    call nz, $e0c4
    nop
    ld b, h
    ret z

    add e
    ret nz

    nop
    ret nz

    nop
    add e
    add e
    ldh [c], a
    ret z

    jp $8700


    ret


    inc bc
    add $43
    db $e3
    call z, $87c2
    nop
    ld b, h
    add e
    rst RST_00
    ld b, a
    ld b, l
    push bc
    add a
    rlc b
    ld b, h
    and e
    db $e3
    ret nz

    ret nz

    ret nc

    ret nz

    add a
    nop
    nop
    inc bc
    ld bc, $0000
    nop
    nop
    ld hl, $0143
    inc bc
    ret nz

    inc bc
    ldh [rNR13], a
    ld b, a
    ld bc, $07c6
    ret nz

    ret nz

    inc bc
    inc bc
    inc bc
    inc de
    ld b, h
    nop
    nop
    ld [hl+], a
    nop
    inc de
    db $e3
    nop
    ld [$c262], sp
    inc bc
    nop
    rlca
    ret nz

    ld b, e
    jp $c001


    ret nz

    add b
    add b
    ld bc, $8000
    ld [hl+], a
    ret nz

    ld h, e
    and b
    nop
    ret nz

    jp nz, $e3c8

    ldh [rTIMA], a
    ld [bc], a
    rlca
    ld b, b
    jp Jump_000_0314


    ret z

    nop
    and e
    sub e
    and b
    dec b
    jp $0187


    add b
    inc bc
    inc b
    rst RST_00
    nop
    ret c

    nop
    ldh [$ffc0], a
    ret nz

    ld [hl+], a
    add b
    nop
    nop
    nop
    nop
    ret nz

    nop
    inc de
    ldh [$ff0c], a
    ret nz

    nop
    ret nz

    jp $0700


    inc bc
    dec bc
    push bc
    and e
    nop
    inc bc
    inc bc
    inc bc
    rst RST_00
    inc bc
    ld bc, $4407
    nop
    ld bc, $1310
    nop
    jp $c4c7


    ld [hl+], a
    ld bc, $1303
    inc de
    ld b, b
    jp Jump_003_6200


    add $00
    ret z

    nop
    rl e
    pop hl
    pop bc
    nop
    nop
    and c
    pop bc
    add e
    jp $9001


    pop bc
    nop
    add d
    ret nz

    ld b, b
    ld bc, $e200
    nop
    nop
    ld b, l
    reti


    jp $c107


    push bc
    nop
    nop
    add d
    ret nz

    bit 4, d
    ret nz

    nop
    nop
    nop
    ld [bc], a
    inc bc
    sub e
    ld b, b
    call nz, $4600
    nop
    nop
    jp Jump_000_0001


    ld b, h

jr_003_4be8:
    nop
    ld bc, $0000
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    stop
    ld [bc], a
    jr nz, jr_003_4c07

jr_003_4c07:
    nop
    nop
    nop
    inc bc
    add b
    jr nz, jr_003_4c17

    nop
    add hl, bc
    ld b, b
    dec b
    nop
    nop
    ld [bc], a
    nop
    nop

jr_003_4c17:
    nop
    nop
    add h
    ld [bc], a
    nop
    stop
    ld a, [bc]
    add h
    jr nz, @+$22

    ld de, $0410
    ld b, b
    ld bc, $2104
    ld b, b
    nop
    inc d
    ld [bc], a
    ld bc, $8820
    inc b
    ld b, b
    jr nz, jr_003_4c74

    ld [bc], a
    ld [$0000], sp
    ld [bc], a

jr_003_4c39:
    ld b, b
    ld b, b
    db $10
    db $10
    ld bc, $0102
    ld bc, $0114
    ld hl, $8000
    nop
    ld b, b
    ld hl, $84c0
    db $10
    add h
    ld [bc], a
    nop
    ld b, b
    ld hl, $2004
    db $10
    add d
    ld b, b
    ld hl, $2009
    ld [bc], a
    add d
    nop
    nop
    ld bc, $2000
    add b
    inc b
    jr nz, jr_003_4be8

    ld a, [bc]
    nop
    nop
    db $10
    ld b, c
    add h
    dec b
    add b
    and b
    ret nz

    inc b
    ld b, b
    inc b
    ret nz

    ld b, b
    db $10

jr_003_4c74:
    jr nz, jr_003_4c76

jr_003_4c76:
    nop
    jr nc, jr_003_4c39

    inc b
    jr nz, jr_003_4c7c

jr_003_4c7c:
    inc b
    inc b
    nop
    ld bc, $000a
    add d
    nop
    and b
    ld [bc], a
    inc b
    nop
    inc b
    add hl, bc
    inc b
    jr nz, jr_003_4c99

    ld d, b
    nop
    ld [$0004], sp
    ld bc, $0200
    dec b
    nop
    add b
    nop

jr_003_4c99:
    nop
    ld b, b
    nop
    jr nz, jr_003_4c9e

jr_003_4c9e:
    nop
    nop
    nop
    dec b
    nop
    ld bc, $880a
    nop
    jr jr_003_4cb1

    ld b, b
    ld [bc], a
    ld [$8211], sp
    ld bc, $0808

jr_003_4cb1:
    ld b, b
    nop
    nop
    add b
    ld b, b
    nop
    nop
    jr nz, @+$14

    ld [bc], a
    nop
    ld [bc], a
    jr nz, jr_003_4cc7

    nop
    nop
    ld bc, $3005
    ld b, b
    ld [bc], a
    nop

jr_003_4cc7:
    ld b, b
    jr nz, jr_003_4cce

    nop
    jr nz, jr_003_4cde

    ld d, b

jr_003_4cce:
    nop
    ld b, b
    dec b
    add d
    ld c, b
    ld d, b
    ld [bc], a
    ret nz

    nop
    add h
    ld [bc], a
    ld hl, $0001
    db $10
    add b

jr_003_4cde:
    nop
    jr nz, jr_003_4ce1

jr_003_4ce1:
    add h
    ld b, b
    jr nc, jr_003_4d05

    jr nc, jr_003_4ce7

jr_003_4ce7:
    add h
    add d
    inc b
    jr nz, jr_003_4cfc

    nop
    jr nz, jr_003_4cef

jr_003_4cef:
    ld [bc], a
    dec b
    add b
    ld b, b
    nop
    nop
    inc b
    add b
    ld [bc], a
    dec b
    ld b, b
    stop

jr_003_4cfc:
    db $10
    ld b, b
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_4d05:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_003_4d15

jr_003_4d15:
    add b
    ld [bc], a
    nop
    add b
    ld d, $30
    ld bc, $0008
    ld [$406a], sp
    ld b, [hl]
    ldh a, [$ff0b]
    add h

jr_003_4d25:
    nop
    jr nc, jr_003_4d28

jr_003_4d28:
    nop
    ld [hl-], a
    ld h, b
    ld [bc], a
    add b
    inc d
    nop
    ld d, e
    adc h
    ld b, b
    ld b, h
    jp nc, Jump_000_0ee0

    ld c, b
    ret nc

    inc bc
    ld b, $68
    add hl, bc
    ld a, [bc]
    ld a, [bc]
    jr c, jr_003_4d25

    adc a
    nop
    or b
    ld bc, $808e
    nop
    sub d
    ld d, a
    ld e, b
    ld sp, $00e1
    ld d, $48
    ld h, e
    ld b, h
    ld [hl], d
    jr c, jr_003_4d54

jr_003_4d54:
    ld c, $00
    inc l
    ld hl, $9887
    nop
    pop bc

jr_003_4d5c:
    add b

jr_003_4d5d:
    ld d, h
    ld [$2570], sp
    inc c
    nop
    ldh [$ff0e], a
    inc c
    nop
    ld d, e
    add b
    inc a
    ld bc, $00c2
    add b
    nop
    nop
    rrca
    ld c, $82
    dec b
    xor b
    nop
    ld a, [hl+]
    and c
    db $dd
    ld de, $2514
    ld [$3100], sp
    ldh [rBGP], a
    ld b, $f0
    ld b, c
    inc d
    ld [$1500], sp
    jp nz, RST_00

    nop
    inc b
    nop
    add b
    ld [hl], b
    rrca
    nop
    nop
    ld bc, $0088
    ld a, [hl+]
    ld [hl], h

jr_003_4d98:
    ld e, a
    nop
    jr nc, jr_003_4d5d

    adc [hl]
    ld [bc], a
    ld [$5f59], sp
    ld c, l
    ld c, b
    and $08
    ret nz

    xor h
    ld [hl], b
    rrca
    ld [hl+], a
    ld b, b
    ld bc, $3d00
    nop
    ld [bc], a
    ld c, d
    inc c
    ld b, d
    ld [hl+], a
    ld [$0000], sp
    ld l, c
    add e
    inc c
    ret nz

    dec h
    add b
    nop
    nop
    sub c
    add e
    add b
    ld [hl], d
    ld [de], a
    jr nz, jr_003_4dd2

    inc d
    ld l, b
    inc bc
    rlca
    db $10
    ld de, $1f86
    cp b
    ld bc, $4284

jr_003_4dd2:
    ld [$0fc0], sp
    inc c
    jr c, jr_003_4d5c

    nop
    inc bc
    ld b, b
    ld bc, $1040
    ld [$0254], sp
    ld c, b
    inc [hl]
    dec b
    nop
    nop
    xor h
    db $10
    inc b
    nop
    jr nc, jr_003_4df5

    inc b
    db $10
    adc b
    ld d, b
    ld h, a
    adc c
    ld bc, $1e01

jr_003_4df5:
    nop
    jr nc, jr_003_4d98

    inc hl
    nop
    ld [hl], h
    ld bc, $0d0e
    nop
    ld bc, $00c8
    inc b
    ld bc, $121e
    nop
    nop
    dec c
    ld bc, $0100
    add b
    nop
    ld a, [bc]
    add b
    rrca
    ld c, a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$0000], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_003_4e6a

    jr z, @+$32

    inc b
    ret nz

    nop
    ld c, b
    ldh a, [rP1]
    ld b, b
    add c
    ld h, c
    add l
    nop
    db $10
    ld bc, $4c00
    ld l, b
    ld h, c
    add b
    inc c
    ld l, b
    nop
    ret nz

    nop
    ld [bc], a
    nop
    inc bc
    nop
    ld c, b
    nop
    pop hl
    ld [$e215], sp
    db $10
    ld e, [hl]
    ld h, h
    ld [bc], a
    nop
    nop
    jr z, jr_003_4ec3

    add e
    ld b, $e0
    nop
    ld a, e
    ld [$c215], sp
    inc b
    and b
    inc c
    jr nz, jr_003_4ea1

    inc d
    inc bc
    add e
    jr nc, jr_003_4e66

jr_003_4e66:
    inc d
    inc b
    ld c, c
    inc l

jr_003_4e6a:
    nop
    sbc b
    inc b
    ld [$0a70], sp
    inc b
    sub l
    adc l
    jr nz, jr_003_4e7d

    nop
    ld a, b
    ldh [rTAC], a
    ld e, $01
    inc hl
    add b

jr_003_4e7d:
    nop
    nop
    ld b, c
    add $2c
    nop
    nop
    ld a, [bc]
    ld d, $10
    ld bc, $00c6
    add b
    nop
    inc b
    nop
    db $10
    and c
    inc b
    or b
    sub h
    ld [bc], a
    ld c, e
    ld [de], a
    ld a, b
    ret nc

    nop
    inc e
    ld c, $c3
    ld a, [bc]
    db $10
    inc e
    inc b
    ret nz

jr_003_4ea1:
    nop
    ld [hl], b
    ret nz

    ld [bc], a
    ld d, b
    ld [hl], h
    xor h
    db $10
    db $10
    ld [$80eb], sp
    ld l, b
    add l
    ld b, e
    ld [$0908], sp
    ld hl, $0283
    stop
    db $d3
    ld c, b
    ld a, [hl+]
    db $e4
    inc bc
    db $10
    ld [hl], h
    dec b
    sub b
    inc e
    nop

jr_003_4ec3:
    sub $04
    ld bc, $4385
    rst RST_08
    add b
    add b
    ld h, c
    add e
    inc c
    stop
    ld b, b
    inc c
    ld bc, $8408
    inc c
    inc b
    ld bc, $1680
    jr c, jr_003_4edf

jr_003_4edc:
    adc e
    add b
    add b

jr_003_4edf:
    inc b
    ld e, [hl]
    nop
    jr nc, jr_003_4ee5

    add l

jr_003_4ee5:
    rlca
    ld [hl], b
    nop
    inc b
    ld [bc], a
    jr z, jr_003_4eec

jr_003_4eec:
    nop
    ld b, a

Call_003_4eee:
    add h
    nop
    nop
    inc a
    ld a, [hl-]
    adc b
    jr nz, jr_003_4ef7

    ld l, b

jr_003_4ef7:
    nop
    ret nc

    nop
    ld a, [hl+]
    add b
    dec d
    db $10
    jr nc, jr_003_4f0a

    nop
    ld e, $4a
    pop bc
    call nz, Call_003_7418
    db $ed
    sub b
    db $10

jr_003_4f0a:
    ld c, h
    ld [bc], a
    inc b
    nop
    ret nz

    nop
    rlca
    ld c, c
    inc a
    sbc e
    and e
    db $10
    ld [de], a
    jr nz, jr_003_4f19

jr_003_4f19:
    inc [hl]
    ld bc, $2003
    ld [bc], a
    nop
    ld [bc], a
    ld b, b
    nop
    ld c, b
    ld h, b
    dec b
    ld b, $00
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    inc a
    jr nz, jr_003_4f3e

jr_003_4f3e:
    nop
    ld a, [bc]
    ld bc, $0c80
    ld bc, $0000
    inc b
    and h
    nop
    ld [hl], b
    inc [hl]
    ld de, $3800
    adc c
    inc b
    nop
    nop
    jr jr_003_4f54

jr_003_4f54:
    and b
    ld [$0221], sp
    nop
    jr nc, jr_003_4edc

    nop
    ld b, $02
    jr nz, jr_003_4f6e

    nop
    sub c
    inc b
    inc b
    ld b, [hl]
    inc b
    ret nc

    nop

jr_003_4f68:
    db $10
    jr nc, jr_003_4f6c

    db $10

jr_003_4f6c:
    ld b, c
    ld b, d

jr_003_4f6e:
    nop
    ld [bc], a
    nop
    add b
    inc d
    add b
    or h
    db $10
    ld h, b
    nop
    nop
    nop
    inc b
    ld bc, $4018
    ld bc, $0c20
    db $10
    ld a, [bc]
    ld [bc], a
    jr nz, jr_003_4fa6

    jr nz, jr_003_4fca

    ld b, $04
    ld [$022c], sp
    sub b
    ld h, $4c
    nop
    jr nz, jr_003_4f93

jr_003_4f93:
    ld h, b
    and d
    nop
    nop
    inc b
    add b
    ld a, [bc]
    nop
    inc [hl]
    add e
    ld b, b
    inc b

jr_003_4f9f:
    ld bc, $8018

jr_003_4fa2:
    inc h
    jr c, jr_003_4f68

    nop

jr_003_4fa6:
    add b
    inc c

jr_003_4fa8:
    inc h
    sub b
    dec b
    add c
    jr nz, jr_003_4fc6

    ld [bc], a
    dec b
    ld bc, $8002
    inc de
    ld [bc], a
    ret nz

    nop
    ld d, b
    nop
    add d
    sub d
    ld c, b
    ld [bc], a
    db $10
    sub b
    ld b, d
    ld [bc], a

jr_003_4fc1:
    jr z, @+$03

    ld [$3424], sp

jr_003_4fc6:
    jr jr_003_4fca

    adc b
    pop bc

jr_003_4fca:
    add hl, bc
    jr nz, jr_003_5012

    nop
    nop
    db $10
    ld [de], a
    ld bc, $1406
    ld d, c
    ld b, b
    ld bc, $1000
    sub b
    nop
    nop
    ld hl, $4100
    and h
    sub e
    inc d
    ld b, $25
    ld d, d
    ld b, $92
    inc c
    inc b
    jr nc, jr_003_500f

    ld b, c
    ld [hl-], a
    ld [bc], a
    add hl, bc
    add h
    add b
    ld b, b
    nop
    inc c
    ld d, b
    add b
    inc de
    dec b
    inc b
    ld [hl+], a
    ld d, b
    jr nz, jr_003_4fc1

    and b
    ld a, [de]
    inc c
    ld b, b
    jr nz, @+$06

    nop
    jr nz, jr_003_500e

    ld e, $02
    inc b
    add b
    stop
    ld b, b
    ld c, h

jr_003_500e:
    inc bc

jr_003_500f:
    dec b
    jr nc, jr_003_4fa2

jr_003_5012:
    ld h, c
    inc e
    ld d, $10
    nop
    db $10
    ld b, [hl]
    add b
    inc b
    nop
    ld b, b
    jr c, jr_003_4f9f

    ld hl, $113c
    nop
    add hl, hl
    ld c, h
    jr nz, jr_003_4fa8

    ld a, [hl+]
    db $10
    jr nc, jr_003_502b

jr_003_502b:
    ld b, b
    add b
    jr nz, jr_003_502f

jr_003_502f:
    add hl, bc
    ld b, b
    jr nz, jr_003_5033

jr_003_5033:
    nop
    dec [hl]
    add b
    ld bc, $0200
    ld b, b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_504c:
    nop
    nop
    nop
    ldh [rDIV], a
    sbc h
    nop
    inc bc
    nop
    nop
    jr nc, jr_003_5068

    ld bc, $68b5
    jp Jump_000_0207


    ld [hl], b
    nop
    ld bc, $69d0
    nop
    add a
    db $10
    ld h, [hl]
    ld a, [bc]

jr_003_5068:
    ld h, b
    ld b, b
    db $10
    ld [bc], a
    nop
    ld [bc], a
    ld [hl], d
    push bc
    ret nc

    nop
    nop
    ld bc, $0680
    ld [hl], b
    dec l
    add [hl]
    nop
    ld l, b
    inc c
    add a
    ld d, $70
    db $f4
    ld b, b
    nop
    nop
    nop
    nop
    inc c
    ld b, e
    pop hl
    sub b
    ld d, l
    jr c, jr_003_504c

    sub b
    nop
    nop
    pop af
    sub [hl]
    nop
    nop
    ld h, b
    rlca
    inc hl
    add d
    dec c
    add $10
    dec c
    ld h, e
    inc b
    ld b, b
    ld b, h
    nop
    rlca
    add d
    ld [$008a], sp
    ld [bc], a
    nop
    or d
    rrca
    ld a, [hl+]
    nop
    ld [bc], a

jr_003_50ac:
    dec h
    nop
    ld [hl], h
    ldh [$ff61], a
    inc c
    jr z, jr_003_50b8

    ld b, d
    inc c
    nop
    pop bc

jr_003_50b8:
    ld b, $80
    jr z, jr_003_50ac

    inc de
    ld [$a940], sp
    rla
    ld [hl], d
    jr nc, jr_003_5135

    adc d
    or d
    ld c, b
    and b
    ld h, [hl]
    ld bc, $7548
    push bc
    ld b, $70
    ld de, $1c01
    ld [$0092], sp
    ld b, $30
    ld de, $1c20
    ld bc, $8a24
    nop
    ld h, b
    inc b

jr_003_50e0:
    jp $010c


    scf
    inc bc
    ld d, d
    ld c, b
    jr nz, jr_003_512a

    jr nc, @+$2a

    nop
    ld b, b
    ld b, $30
    ld de, $0c86
    nop
    add d
    ld h, h
    ld d, d
    pop bc
    ld b, b
    ld [$080c], sp
    add e
    rla

jr_003_50fd:
    nop
    jr c, jr_003_50e0

    rla
    jr nc, jr_003_5107

    rrca
    nop
    ld l, h
    nop

jr_003_5107:
    jp hl


    add [hl]
    ld [hl], c
    jr nc, @+$63

    or b
    ld d, $34
    jr @+$0d

    ld [$6300], sp
    dec b
    ld b, b
    add e
    and l
    add c
    add b
    ld c, b
    jp nz, $8020

    ld h, h
    ldh a, [$ffe6]
    inc c
    jr z, @-$7e

    inc d
    inc l
    ld [hl], h
    jr nz, jr_003_5179

    ld [hl], l

jr_003_512a:
    nop
    rlca

jr_003_512c:
    rlca
    ld c, $30
    ld e, b
    add sp, $02
    jr nc, jr_003_50fd

    add h

jr_003_5135:
    nop
    add hl, de
    push de
    add c
    ld c, h
    sub b
    ld h, e
    dec b
    ld b, b
    jr nc, jr_003_5150

    nop
    ld [de], a
    nop
    ld [hl+], a
    nop
    ld b, $00
    ld [bc], a
    rlca
    inc c
    ld b, l
    sub b
    nop
    jr nc, jr_003_514f

jr_003_514f:
    nop

jr_003_5150:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ldh [rP1], a
    ld b, b
    nop
    ld bc, $024a
    ld l, b
    pop de
    sbc $10
    db $10
    inc bc
    ldh [$ff50], a
    jr nc, jr_003_51b4

    ld c, $34
    jr z, jr_003_51d0

    dec e

jr_003_5179:
    add e
    db $10
    jp nz, Jump_000_0080

    ld [bc], a
    nop
    ld h, b
    nop
    ld [hl], b
    or e
    sub h
    nop
    nop
    ld bc, $0040
    jr c, jr_003_512c

    add hl, bc
    ld [$0010], sp
    add b
    adc b
    ld h, h
    pop hl
    add h
    nop
    nop
    nop
    db $10
    rlca
    ld [hl], b
    ldh [c], a
    nop
    ld c, h
    dec bc
    ld a, [de]
    and e
    rra
    jr jr_003_51a6

    add a
    nop

jr_003_51a6:
    nop
    jp nc, $8e40

    nop
    jp Jump_000_00a0


    jr nc, jr_003_51b0

jr_003_51b0:
    ld d, h
    jr @+$6a

    db $10

jr_003_51b4:
    ld d, $08
    ld [$4058], sp
    inc e
    nop
    ld b, e
    adc d
    adc b
    nop
    inc bc
    add b
    ld b, a
    nop
    ld [hl+], a
    ret z

    dec l
    nop
    ld l, b
    ld b, h
    ld c, l
    ld l, d
    push hl
    ld [$3c0a], sp
    daa

jr_003_51d0:
    ld b, h
    ld bc, $0872
    nop
    adc b
    add b
    ld h, e
    db $e3
    ld [bc], a
    ld [hl-], a
    ld b, d
    ld bc, $0b0c
    ld hl, $87c0
    db $10
    ld b, [hl]
    sub $de
    ld bc, $6470
    ld b, $b0
    pop de
    ret


    inc e
    ld [hl], b
    ld l, b
    nop
    inc c
    ret nz

    ld [de], a
    ld [$001f], sp
    jr nz, @+$09

    ld [$2240], sp

jr_003_51fc:
    ld [$6a00], sp
    ld bc, $0d90
    ld l, h
    or [hl]
    ret z

    xor l
    nop
    db $10
    ld b, b
    jr z, @+$12

    ld b, e
    adc b
    dec c
    nop
    and e
    ld b, h
    ld b, b
    ld b, c
    ldh [c], a
    ld e, $80
    nop
    dec b
    ld b, b
    inc e
    jr jr_003_521e

    ld a, [bc]
    adc h

jr_003_521e:
    cp h
    inc bc
    add l
    ld c, b
    db $10
    ld bc, $2c84
    ld b, b
    add hl, bc
    ld b, b
    ld e, $30
    ld b, b
    nop
    inc l
    jr z, jr_003_5230

jr_003_5230:
    inc b
    nop
    jr nc, @-$4d

    ld e, $01
    xor h
    ldh a, [c]
    ld d, l
    nop
    ld h, b
    ld [bc], a
    ld c, $00
    nop
    ld bc, $4fc4
    nop
    inc bc
    add h
    inc c
    inc b
    ld e, b
    stop
    ldh a, [$ffc1]
    ld [$000a], sp
    ld e, c
    ld b, b
    db $10
    add b
    ld hl, $0cd4
    nop
    inc b
    ld a, [bc]
    nop
    nop
    ld [bc], a
    ld [$3001], sp
    db $10
    ld [bc], a
    ld [$0000], sp
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$0000], sp
    nop
    ld bc, $0000
    ld [bc], a
    nop
    ld bc, $0000
    jr jr_003_51fc

    ld sp, $2200
    ld [de], a
    nop
    add b
    ld b, h
    nop
    ld c, b
    ld b, h
    ld bc, $2010
    ld b, b
    jr nz, @+$4e

    db $10
    add b
    ld [bc], a
    ld bc, $848c
    jr nz, jr_003_52b2

    add c
    inc h
    jr nz, jr_003_52d6

    ld [hl+], a
    adc d
    ld [hl+], a
    ld b, b
    ld bc, $0c10
    ld [hl+], a
    adc d
    ld c, b
    adc h
    inc b
    inc h

jr_003_52a1:
    add b

jr_003_52a2:
    add c
    nop
    inc l
    inc b
    inc e
    jr nc, jr_003_52a9

jr_003_52a9:
    ld sp, $2022
    add h
    ld b, b
    ld b, b
    ld b, c
    add b
    add hl, hl

jr_003_52b2:
    ld b, d
    ld bc, $0082
    ld [bc], a
    ld b, b

jr_003_52b8:
    inc b
    ld bc, $2000
    ld b, b
    jr z, @+$2a

    add d
    adc c
    inc l

jr_003_52c2:
    ld c, b
    ld bc, $0028
    nop
    add h
    ld hl, $8020
    ld d, d
    ld [hl+], a
    add c
    jr c, @+$2a

    sub d
    ld b, d
    nop
    ld hl, $2028

jr_003_52d6:
    nop
    ld bc, $2220
    jr z, @+$04

    inc b
    jr nz, jr_003_5300

    ld b, b
    ld b, b
    ld b, h
    jr nz, jr_003_5326

    db $10
    add hl, hl
    ld hl, $220a
    ld b, b
    jr z, @-$7e

    nop
    db $10
    sbc d
    ld hl, $4020
    ld c, b
    jr z, jr_003_52f5

jr_003_52f5:
    ld d, d
    ld sp, $2230
    adc b
    inc h
    ld b, d
    ld b, c
    ld b, d
    jr nz, jr_003_5300

jr_003_5300:
    nop
    inc b
    jr nc, jr_003_5305

    ld [bc], a

jr_003_5305:
    ld b, b
    sub d
    nop
    inc l
    inc c
    jr z, jr_003_5350

    jr z, jr_003_5356

    inc b
    db $10
    ld [de], a
    ld b, h
    ld b, d
    inc h
    jr z, jr_003_5316

jr_003_5316:
    nop
    ld d, h
    adc h
    ld b, b
    inc b
    jr z, jr_003_52a1

    ld b, d
    ld c, c
    jr nc, jr_003_52a2

    ld [bc], a
    add b
    adc b
    inc h
    ld c, h

jr_003_5326:
    inc [hl]
    ld de, $8184
    inc d
    ld b, d
    sbc d
    inc b
    jr nc, jr_003_5330

jr_003_5330:
    ld d, b
    add h
    jr nz, jr_003_52b8

    ld [hl-], a
    ld b, b
    adc b
    ld b, h
    ld d, b
    add c
    add c
    ld [bc], a
    inc b
    ld [bc], a
    add hl, bc
    jr nz, jr_003_52c2

    add d
    jr @-$7d

    ld [bc], a
    jr z, jr_003_538b

    inc b
    jr nz, jr_003_5396

    ld [de], a
    inc h
    ld d, b
    sbc d
    ld d, h
    adc c

jr_003_5350:
    ld bc, $2100
    ld b, c
    nop
    sub h

jr_003_5356:
    add d
    nop
    ld sp, $0208
    ld b, c
    sub b
    ld [bc], a
    jr nz, jr_003_53a1

    jr nz, jr_003_5386

    ld de, $1201
    ld bc, $205c
    add h
    inc c
    jr z, jr_003_536e

    sbc b
    ld [bc], a

jr_003_536e:
    nop
    ld bc, $5410
    ld e, b
    jr nz, @-$74

    nop
    ld b, b
    inc b
    db $10
    ld b, b
    nop
    jr nz, jr_003_537d

jr_003_537d:
    nop
    ld [$0000], sp
    nop
    nop
    nop
    nop
    nop

jr_003_5386:
    nop
    nop
    nop
    nop
    inc a

jr_003_538b:
    db $10
    jr nc, jr_003_538e

jr_003_538e:
    nop
    jr nc, jr_003_5391

jr_003_5391:
    ld h, b
    ld l, [hl]
    ld e, $b8
    nop

jr_003_5396:
    nop
    nop
    ld c, $50
    nop
    jr jr_003_53cb

jr_003_539d:
    ld [$0009], sp
    inc b

jr_003_53a1:
    ld e, $0e
    ld [$000e], sp
    nop
    nop
    nop
    inc b
    ld a, [de]
    ld a, [bc]
    nop
    db $10
    inc b
    inc b
    inc d
    inc c
    ld [$4040], sp
    nop
    nop
    ld a, [bc]
    inc c
    or b
    db $10
    inc d
    dec b
    db $10
    ld c, $42
    add hl, hl
    ld a, [bc]
    ld [bc], a
    ld [bc], a
    dec h
    jr nz, jr_003_53d4

    dec b
    or l
    dec b
    dec l

jr_003_53cb:
    ld [$9925], sp
    nop
    ld b, b
    ld d, b
    inc b
    ld d, h
    ld [hl], l

jr_003_53d4:
    ld a, h
    inc c
    cp h
    ld [$4004], sp
    inc b
    dec d
    jr nz, jr_003_53de

jr_003_53de:
    dec c
    jr nz, @+$52

    dec b
    inc a
    inc b
    dec e
    nop
    dec c
    dec l
    inc b
    ld a, [bc]
    ld a, [bc]
    jr nc, jr_003_539d

    xor b
    ld [$502a], sp
    nop
    jr nc, jr_003_5432

    add hl, bc
    nop
    nop
    sbc d
    ld [de], a
    inc c
    add hl, bc
    nop
    ld c, $70
    ld [$380a], sp
    ld d, $3c
    dec b
    stop
    inc b
    inc c
    nop
    ld c, $10
    ld h, $0a
    ld l, b
    ld [$b00a], sp
    ld [hl], b
    nop
    ld b, $69
    ld e, l
    ld a, [bc]
    ld h, b
    nop
    ld [hl+], a
    jr nz, jr_003_545c

    cp b
    xor b
    inc c
    ld c, l
    ld a, b
    jr z, jr_003_548b

    inc c
    jr nc, jr_003_5426

jr_003_5426:
    nop
    ld c, $08
    ld l, $40
    dec d
    xor h
    ld a, [bc]
    nop
    ld [$9e0e], sp

jr_003_5432:
    inc c
    ld a, [de]
    nop
    nop
    nop
    ld [$080e], sp
    jr nc, jr_003_543c

jr_003_543c:
    or l
    dec c
    ld a, [hl-]
    ld [hl], b
    inc h
    ld e, l
    ld a, [hl+]
    dec [hl]
    dec h
    xor b
    ld a, c
    nop
    ld a, [de]
    xor l
    ld e, b
    inc b
    add hl, bc
    dec c
    ld a, [bc]
    dec c
    dec b
    sub b
    nop
    ld a, [de]
    nop
    db $10
    inc a
    ld b, b
    ld a, [bc]
    sub b
    ld c, $05

jr_003_545c:
    db $10
    inc c
    dec e
    dec c
    ld a, [de]
    jr c, jr_003_549d

    ld [$3500], sp
    ld [$0e2a], sp
    jr jr_003_54d4

    dec a
    dec h
    stop
    xor b
    ld c, $0e
    nop
    sbc b
    dec b
    ld d, l
    ld a, [bc]
    dec b
    dec h
    dec b
    inc b
    or b
    dec b
    nop
    inc b
    ld a, [bc]
    jr c, @+$72

    nop
    ld e, b
    ld l, $00
    inc b
    nop
    ld b, h
    ld a, [bc]
    dec c

jr_003_548b:
    ld a, b
    nop
    nop
    or b
    sub b
    add hl, bc
    dec [hl]
    nop
    nop
    ld [$7c00], sp
    dec bc
    nop
    ld [$0c00], sp
    nop

jr_003_549d:
    nop
    ld [hl], b
    cp h
    jr jr_003_54a2

jr_003_54a2:
    jr jr_003_54f0

    ld [hl], d
    db $10
    inc e
    add b
    db $10
    inc c
    adc b
    nop
    ld [bc], a
    stop
    and h
    nop
    inc de
    inc c
    adc h
    inc d
    sbc b
    jr nz, @+$0f

    inc a
    inc [hl]
    db $10
    inc a
    ld [$8418], sp
    jr nc, jr_003_54c9

    ld a, [bc]
    ld d, h
    ld hl, $20b4
    jr jr_003_5530

    inc [hl]

jr_003_54c9:
    db $10
    inc e
    nop
    inc b
    nop
    ld l, b
    inc bc
    ld b, $3c
    db $10
    ld a, [hl-]

jr_003_54d4:
    cp h
    ld e, $26
    inc a
    xor d
    sbc b
    inc a
    inc b
    jr nc, jr_003_551e

    ret c

    ccf
    add h
    ld a, h
    ld h, b
    nop
    db $10
    ld a, $0e
    inc [hl]
    jr z, jr_003_5512

    jr nz, jr_003_5555

    jr nc, @+$62

    add a
    or b

jr_003_54f0:
    cp b
    jr nz, jr_003_5523

    db $10
    jr c, jr_003_5532

    db $10
    ld [hl+], a
    jr jr_003_5502

    ld [hl], b
    cp h
    db $10
    jr nz, jr_003_554f

    push hl
    jr nz, jr_003_551b

jr_003_5502:
    jr nz, jr_003_54d4

    ld a, h
    ld [hl], $98
    add b
    ld e, $3c
    ld [de], a
    db $10
    ld a, [hl]
    inc a
    jr jr_003_556c

    inc e
    ld [de], a

jr_003_5512:
    ld [hl], $30
    pop af
    ld l, d
    inc a
    inc b
    sub b
    jr nc, jr_003_552b

jr_003_551b:
    ld a, [hl-]
    ld l, e
    inc a

jr_003_551e:
    jr z, jr_003_5520

jr_003_5520:
    inc d
    ld a, [de]
    cp c

jr_003_5523:
    inc b
    inc b
    inc [hl]
    ld [de], a
    ld a, d
    ld [hl], b
    nop
    ld [hl-], a

jr_003_552b:
    inc c
    ld e, b
    sub d
    jr c, jr_003_5536

jr_003_5530:
    inc c
    ld b, b

jr_003_5532:
    ld [de], a
    inc a
    ld [de], a
    sub b

jr_003_5536:
    ld e, c
    dec bc
    ld a, h
    jr c, jr_003_5573

    cp h
    ld [hl], $d0
    ld b, [hl]
    nop
    inc h
    cp [hl]
    add hl, bc
    ld a, $10
    inc d
    jr c, @+$12

    inc [hl]
    ld hl, sp+$20
    ld a, [hl+]
    inc c
    jr c, jr_003_5567

jr_003_554f:
    ld e, h
    db $10
    inc l
    ld [$1801], sp

jr_003_5555:
    ld a, h
    ld a, [de]
    cp $10
    dec h
    jr nc, jr_003_5579

    inc e
    ld e, $20
    add hl, bc
    ld a, [hl-]
    inc h
    jr c, jr_003_5570

    ld a, b
    ld [hl], h
    ld e, h

jr_003_5567:
    add b
    jr c, jr_003_5523

    ld d, b
    inc [hl]

jr_003_556c:
    ld e, h
    db $10
    jr z, jr_003_55e0

jr_003_5570:
    sub [hl]
    jr jr_003_55cb

jr_003_5573:
    jr z, jr_003_55a5

    inc l
    inc a
    inc [hl]
    inc c

jr_003_5579:
    add [hl]
    dec d
    and h
    ld a, [bc]
    add hl, sp
    inc a
    add b
    ld [$0880], sp
    dec d
    ld a, $04
    jr nc, @+$0f

    jr nc, jr_003_55be

    inc b
    ld [$080c], sp
    jr nc, jr_003_55c0

    inc a
    nop
    nop
    inc c
    jr nz, @+$06

    ld d, b
    dec b
    nop
    jr c, jr_003_55cb

    nop
    jr nz, jr_003_559e

jr_003_559e:
    jr nc, jr_003_55a1

    nop

jr_003_55a1:
    jr nc, jr_003_55a3

jr_003_55a3:
    stop

jr_003_55a5:
    add b
    nop

jr_003_55a7:
    nop
    ld [$0000], sp
    stop
    nop
    nop
    db $10
    ld b, b
    jr nz, jr_003_55f4

    db $10
    ld [bc], a
    nop
    nop
    nop
    nop

jr_003_55b9:
    nop
    inc c
    inc b
    ld [bc], a
    nop

jr_003_55be:
    nop
    nop

jr_003_55c0:
    ld [bc], a
    nop
    ld [bc], a
    ld c, $02
    nop
    nop
    nop
    ld b, c
    inc b
    add b

jr_003_55cb:
    ld c, $00
    nop
    nop
    nop
    nop
    ld [$1500], sp
    inc b
    jr nc, jr_003_55d7

jr_003_55d7:
    nop
    nop
    ld a, [de]
    add b
    ld [de], a
    nop
    ld b, b
    inc b
    nop

jr_003_55e0:
    nop
    ld sp, $0001
    ld [bc], a
    nop
    ld b, $62
    ld b, h
    stop
    ld b, b
    nop
    nop
    inc b
    nop
    inc b
    nop
    ld c, [hl]
    ld a, [hl]

jr_003_55f4:
    nop
    ld bc, $0200
    ld [bc], a
    nop
    add b
    ld [hl], d
    ld b, b
    nop
    add b
    nop
    ld b, b
    jr nz, jr_003_560f

    jr nz, jr_003_5611

    nop
    ld [hl], d
    nop
    ld b, $34
    ld [bc], a
    nop
    nop
    jr nz, jr_003_561b

jr_003_560f:
    inc b
    ld b, b

jr_003_5611:
    inc b
    add d
    ld [hl-], a
    ld [bc], a
    nop
    ld [bc], a
    jr z, jr_003_5659

    ld [hl], b
    dec b

jr_003_561b:
    ld [bc], a
    nop
    ld b, b
    add b
    nop
    add h
    jr nc, jr_003_5627

    jr nc, @-$7a

    jr z, jr_003_55a7

jr_003_5627:
    nop
    ld b, d
    nop
    add l
    nop
    ld [bc], a
    nop
    add b
    jr nc, @+$43

    inc c
    add h
    nop
    inc h
    nop
    add d
    jr nc, jr_003_55b9

    inc c
    add [hl]
    ld c, $80
    inc a
    ld [bc], a
    inc c
    add b
    ld a, $00
    ld [hl+], a
    add d
    ld a, b
    add b
    stop
    jr @+$0e

    jr nc, jr_003_568d

    nop
    inc b
    inc c
    ld b, b
    ld [$0424], sp
    ld b, d
    ld bc, $3444
    ld [bc], a

jr_003_5659:
    inc a
    nop
    ld [$0442], sp
    ld [hl], d
    ld a, [hl+]
    add b
    dec b
    dec h
    db $10
    ld b, d
    jr nz, jr_003_566d

    ld [$0202], sp
    ld [$4220], sp

jr_003_566d:
    inc l
    ld c, [hl]
    inc c

jr_003_5670:
    ld sp, $0e3e
    ld c, $42
    ld b, $8c
    nop
    ld c, h
    nop
    inc h
    ld a, [bc]
    add b
    nop
    nop
    ld b, [hl]
    jr nz, jr_003_5686

    ld [bc], a
    nop
    nop
    ld [bc], a

jr_003_5686:
    adc b
    nop
    nop
    ld [$0001], sp
    nop

jr_003_568d:
    ld [bc], a
    ld b, b
    nop
    nop
    nop
    jr z, @+$04

jr_003_5694:
    nop
    ld bc, $0082
    nop
    adc b
    ld b, $02
    nop
    ld b, b
    nop
    nop
    nop
    ld c, $04
    nop
    inc c
    add d
    nop
    nop
    nop
    nop
    ld b, $00
    nop
    ld [bc], a
    nop
    nop
    nop
    ld b, b
    nop
    nop
    nop

jr_003_56b5:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add b
    nop
    nop
    nop
    add b
    nop
    ld b, b
    inc a
    add b
    inc b
    nop
    nop
    nop
    nop
    nop
    ld [bc], a
    nop
    inc b
    nop
    jr nz, jr_003_56d4

jr_003_56d4:
    inc b
    nop
    inc c
    ld [de], a
    inc b
    nop
    stop
    jr z, @+$03

    ld bc, $000e
    nop
    stop
    nop
    ld bc, $0201
    nop
    ld b, b
    nop
    nop
    nop
    add l
    jr nz, jr_003_5670

    nop
    stop
    nop
    nop
    ld b, h
    inc l
    nop
    ld [$0000], sp
    inc [hl]
    ld hl, $0080
    nop
    db $10
    add b
    nop
    nop
    stop
    ld h, b
    ld h, b
    jr nz, jr_003_570a

jr_003_570a:
    db $10
    inc b
    inc c
    nop
    inc h
    ld h, h
    nop
    nop
    jr nz, jr_003_5694

    nop

jr_003_5715:
    add h
    dec c
    or d
    ld [bc], a
    nop
    inc h
    nop
    nop
    add d
    ld bc, $0000
    nop
    dec c
    ld b, b
    ld h, b
    ld bc, $4420
    inc c
    nop
    nop
    nop
    nop
    ld h, b
    nop
    inc b
    nop
    nop
    jr z, jr_003_56b5

    jr nz, jr_003_577a

    ld bc, $3145
    ld b, b
    jr nz, jr_003_573c

jr_003_573c:
    inc c
    nop
    dec l
    nop
    nop
    ld b, b
    jr nz, jr_003_5784

    jr z, jr_003_5753

    ld hl, $8100
    nop
    inc l
    ld b, b
    jr nc, @+$0f

    add hl, sp
    ld b, $30
    ld b, b
    inc b

jr_003_5753:
    ld b, b
    jr nz, jr_003_57a2

    dec b
    add [hl]
    jr c, jr_003_57aa

    ld sp, $0880
    add b
    ld [bc], a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0001
    ld b, h
    nop
    ld b, c
    inc b
    ld b, d
    dec d
    nop
    nop
    nop
    jr z, jr_003_5778

    ld sp, $8606
    add b

jr_003_5778:
    inc b
    ld b, b

jr_003_577a:
    dec c
    nop
    nop
    inc c
    inc b
    nop
    jr z, jr_003_5782

jr_003_5782:
    jr z, jr_003_5784

jr_003_5784:
    ld b, h
    ld c, b
    nop
    inc c
    inc l
    dec c
    jr nz, @+$03

    jr nz, jr_003_578e

jr_003_578e:
    add hl, bc
    nop
    nop
    add b
    db $10
    jr z, jr_003_5715

    ld [bc], a
    nop
    nop
    jr nz, jr_003_579a

jr_003_579a:
    ld sp, $0000
    nop
    ld [$0000], sp
    nop

jr_003_57a2:
    nop
    nop
    nop
    ld [$0440], sp
    nop
    inc b

jr_003_57aa:
    inc [hl]
    nop
    nop
    add hl, sp
    add hl, bc
    nop
    nop
    jr nc, jr_003_57b3

jr_003_57b3:
    nop
    nop
    ld b, $01
    nop
    ld [bc], a
    inc b
    nop
    nop
    nop
    nop
    dec c
    nop
    nop
    inc b
    nop
    nop
    nop
    jr nz, jr_003_57c7

jr_003_57c7:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$0800], sp
    jr nz, jr_003_57f0

    nop
    ld [$2000], sp
    nop
    nop
    jr nz, jr_003_57f4

jr_003_57f0:
    nop
    nop
    nop
    nop

jr_003_57f4:
    nop
    nop
    jr nz, jr_003_57f8

jr_003_57f8:
    nop
    nop
    nop
    db $10
    ld [$0400], sp
    nop
    nop
    nop
    nop
    ld [$0800], sp
    ld [$0000], sp
    nop
    jr z, jr_003_5814

    nop
    ld [$1008], sp
    nop
    nop
    nop
    db $10

jr_003_5814:
    jr nz, jr_003_5816

jr_003_5816:
    ld [$2810], sp
    inc b
    ld [$2008], sp
    nop
    jr nz, jr_003_5820

jr_003_5820:
    nop
    nop
    ld b, h
    ld [$0400], sp
    nop
    nop
    nop
    inc c
    inc b
    ld [hl+], a
    add b
    nop
    ld d, c
    nop
    ld [$0000], sp
    jr jr_003_5875

    sbc c
    inc b
    ld [$0008], sp
    ld [$0008], sp
    nop
    nop
    jr jr_003_5841

jr_003_5841:
    nop
    ld [$0010], sp
    nop
    inc b
    nop
    ld [$0004], sp
    inc b
    nop
    ld [$0000], sp
    nop
    ld [$0000], sp
    nop
    ld [$0404], sp
    ld [$0004], sp
    nop
    inc b
    ld [$0100], sp
    ld b, b
    inc b
    nop
    nop
    inc b
    ld [$0800], sp
    inc b
    ld [$0004], sp
    nop
    ld [$0000], sp
    inc b
    ld [$1000], sp
    nop

jr_003_5875:
    nop
    ld [$0008], sp
    jr jr_003_588b

    nop
    nop
    nop
    inc c
    nop
    nop
    nop
    inc h
    ld [$0800], sp
    db $10
    jr jr_003_5889

jr_003_5889:
    nop
    nop

jr_003_588b:
    nop
    nop
    nop
    nop
    ld [$0000], sp
    inc c
    jr jr_003_5895

jr_003_5895:
    jr @+$0a

    ld [$0800], sp
    ld [$0008], sp
    nop
    ld [$0800], sp
    nop
    inc d
    ld [$0000], sp
    jr nz, jr_003_58b0

    nop
    nop
    ld [$2800], sp
    nop
    nop
    nop

jr_003_58b0:
    nop
    ld [$0008], sp
    nop
    nop
    nop
    stop
    inc b
    ld [$0000], sp
    nop
    ld [$0004], sp
    inc b
    nop
    nop
    nop
    nop
    nop
    inc b
    ld [$0000], sp
    nop
    nop
    nop
    db $10
    inc b
    ld [$0000], sp
    nop
    nop
    nop
    nop
    inc b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    cp $bc
    rst RST_38
    rst RST_18
    cp b
    ldh a, [rIE]
    ldh a, [rIE]
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    ret nz

    nop
    di
    ret nz

    call c, $bac1
    and c
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    cp $f3
    xor d
    inc bc
    nop
    rst RST_18
    rst RST_38
    rst RST_38
    rst RST_38
    cp a
    rst RST_38
    rst RST_38
    db $fc
    rst RST_38
    rst RST_38
    ld a, a
    rst RST_38
    cp $ff
    db $fc
    rst RST_38
    cp $ff
    rst RST_08
    adc d
    rst RST_08
    adc d
    rst RST_38
    rst RST_38
    di
    rst RST_38
    xor a
    adc h
    db $dd
    ret nc

    rst RST_38
    rst RST_38
    rst RST_38
    ldh [c], a
    rst RST_38
    rst RST_38
    rst RST_38
    db $e4
    rst RST_38
    db $e4
    ldh [c], a
    xor $ff
    rst RST_18
    xor h
    db $fc
    ld a, [$ffc8]
    db $e4
    rst RST_08
    adc d
    ld a, [$ff32]
    cp $fa
    ret z

    push af
    call z, $0eee
    rst RST_38
    cp $ee
    ld c, $ff
    rst RST_28
    xor $e0
    xor $0e
    xor $0e
    rst RST_38
    cp a
    ei
    rst RST_38
    ldh a, [$ffc3]
    ldh a, [rIF]
    di
    rst RST_38
    xor $e0
    rst RST_38
    di
    ld a, [$cfc8]
    ret nz

    rst RST_08
    ret nz

    db $fc
    inc c
    rst RST_08
    ret nz

    rst RST_38
    rst RST_38
    rst RST_38
    db $fc
    xor $e0
    xor a
    call z, $ffff
    rst RST_38
    rst RST_38
    di
    rst RST_38
    rst RST_38
    db $fc
    db $fc
    xor b
    rst RST_38
    rst RST_38
    xor $e0
    xor $e0
    db $fc
    xor b
    ld a, [$eec8]
    ldh [$ffee], a
    ldh [$ffcc], a
    adc h
    ld a, [$ffc8]
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    cp $ff
    ret nz

    jp $ff3c


    rst RST_38
    ld a, [$f0c8]
    ldh [$fff0], a
    ret nz

    adc b
    add b
    rst RST_38
    rst RST_28
    ret nz

    add b
    rst RST_38
    db $fc
    ldh a, [$ffe0]
    cp e
    ldh a, [$ffdf]
    adc d
    rst RST_38
    rst RST_28
    rst RST_18
    adc d
    db $fc
    xor b
    ldh a, [$ffc0]
    xor $c2
    call z, $fcc8
    xor b
    ldh a, [$ffc0]
    rst RST_38
    ldh a, [$ffcc]
    jp nz, $ffcf

    db $fc
    inc c
    rst RST_38
    di
    ldh a, [$ffe0]
    nop
    nop
    nop
    nop
    ld [$0488], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $7024
    nop
    ld bc, $7024
    nop
    ld d, $03
    ld bc, $0b44
    inc sp
    ld bc, $1644
    inc bc
    ld bc, $0b44
    inc sp
    ld bc, $1344
    jr z, jr_003_5a4d

    inc b
    add hl, bc
    inc l
    ld a, b
    nop
    dec c
    ld [hl+], a
    ld bc, $0d40
    ld [hl+], a
    ld bc, $0d40
    ld [hl+], a
    ld bc, $0d40
    ld [hl+], a
    ld bc, $0d40
    ld [hl+], a
    ld bc, $0d40
    ld [hl+], a
    ld bc, $0040
    inc b
    ld a, b
    nop
    ld bc, $7024
    nop
    dec c
    ld h, $71
    nop
    ld bc, $7024
    nop
    ld bc, $3020

jr_003_5a4d:
    nop
    ld bc, $3020
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    dec c
    ld h, $71
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    ld bc, $7024
    nop
    dec c
    ld h, $71
    nop
    nop
    inc b
    ld a, b
    nop
    nop
    inc b
    ld a, b
    nop
    ld bc, $7024
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    ld bc, $7024
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    nop
    inc b
    ld a, b
    nop
    ld bc, $7024
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    nop
    ld [$0030], sp
    add hl, bc
    inc h
    ld a, b
    nop
    ld bc, $3020
    nop
    ld bc, $3020
    nop
    ld [de], a
    inc c
    ld a, b
    inc b
    ld [de], a
    inc c
    ld a, b
    inc b
    dec c
    ld h, $71
    nop
    nop
    inc b
    ld a, b
    nop
    dec c
    ld h, $71
    nop
    ld bc, $7024
    nop
    ld bc, $3020
    nop
    ld bc, $3020
    nop
    ld bc, $7024
    nop
    ld bc, $3020
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    ld bc, $3020
    nop
    ld bc, $7024
    nop
    add hl, bc
    inc h
    ld [hl], b
    nop
    nop
    inc b
    ld a, b
    nop
    ld [de], a
    inc b
    ld a, b
    inc b
    nop
    inc b
    ld a, b
    nop
    nop
    inc b
    ld a, b
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    nop
    inc b
    ld a, b
    nop
    nop
    nop
    jr nc, jr_003_5aee

jr_003_5aee:
    nop
    inc b
    ld a, b
    nop
    nop
    inc b
    ld a, b
    nop
    inc de
    jr nz, jr_003_5b29

    inc b
    nop
    inc b
    ld a, b
    nop
    nop
    ld [$0030], sp
    nop
    nop
    nop
    nop
    nop
    adc b
    dec b
    ld [$0300], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $4024
    nop
    dec de
    dec l
    ld c, d
    sub l
    dec sp
    cpl
    ld c, d
    dec e
    dec sp
    cpl
    ld c, d
    dec e
    cp e
    cpl
    ld c, d

jr_003_5b29:
    dec e
    cp e
    dec hl
    ld b, $8d
    ld bc, $4024
    nop
    nop
    inc c
    ld c, b
    nop
    add hl, bc
    inc l
    ld c, b
    nop
    nop
    inc c
    ld c, b
    nop
    ld bc, $4024
    nop
    nop
    inc c
    ld c, b
    nop
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    ld bc, $0020
    nop
    ld [de], a
    inc b
    ld c, b
    inc b
    nop
    inc b
    ld c, b
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    ld bc, $4024
    nop
    nop
    inc b
    ld c, b
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    nop
    inc b
    ld c, b
    nop
    nop
    inc b
    ld c, b
    nop
    nop
    inc b
    ld c, b
    nop
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    nop
    inc b
    ld c, b
    nop
    ld [de], a
    inc b
    ld c, b
    inc b
    add hl, bc
    inc h
    ld c, b
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    ld bc, $4024
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    nop
    inc b
    ld c, b
    nop
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    nop
    inc b
    ld c, b
    nop
    ld bc, $0020
    nop
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    ld [de], a
    inc b
    ld c, b
    inc b
    ld [de], a
    inc b
    ld c, b
    inc b
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    nop
    inc b
    ld c, b
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    nop
    inc b
    ld c, b
    nop
    ld bc, $4024
    nop
    nop
    inc c
    ld c, b
    nop
    nop
    inc c
    ld c, b
    nop
    nop
    ld [$0000], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add b
    nop
    nop
    ld [$0000], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ccf
    rst RST_38
    ld [$ccee], a
    call z, $9600
    nop
    sub [hl]
    nop
    sub [hl]
    nop
    sub [hl]
    nop
    sub [hl]
    nop
    sub [hl]
    nop
    sub [hl]
    nop
    sub [hl]
    ld a, [bc]
    add hl, bc
    ld b, b
    nop
    ld [$ff00], a
    ei
    db $fc
    inc c
    xor $09
    ldh a, [c]
    and c
    ret nz

    adc b
    rst RST_38
    rst RST_28
    db $ec
    ld c, h
    rst RST_38
    rst RST_08
    rst RST_30
    rst RST_38
    rst RST_30
    rst RST_38
    rst RST_38
    cp $ff
    rst RST_28
    rst RST_38
    ld a, a
    ccf
    rst RST_38
    ld b, b
    and b
    rst RST_38
    ldh a, [$ffbf]
    db $fd
    ldh a, [rP1]
    rst RST_28
    rst RST_38
    rst RST_38
    rst RST_30
    inc c
    nop
    ld a, [hl+]
    xor d
    adc b
    dec sp
    nop
    ld b, b
    rst RST_38
    ldh [$fffc], a
    cp b
    rst RST_18
    push de
    push af
    db $dd
    rst RST_38
    rst RST_10
    ld [hl], b
    nop
    xor $e0
    rst RST_30
    call nz, $0eee
    rst RST_08
    adc d
    di
    and d
    cp e
    or b
    cp $ff
    ld a, [$faee]
    ret z

    di
    and d
    rst RST_18
    rst RST_38
    rst RST_38
    cp $0f
    rst RST_38
    rst RST_38
    db $fd
    ld a, [$fac8]
    ld [hl-], a
    xor $e0
    db $e4
    xor $fa
    ret z

    xor a
    adc h
    rst RST_38
    rst RST_28
    rst RST_28
    rst RST_38
    ld a, [$fac8]
    ret z

    adc $cc
    cp $01
    rst RST_38
    cp $00
    ld bc, $ccf5
    xor a
    call z, Call_003_4eee
    xor a
    call z, $fcff
    db $fc
    xor b
    db $fc
    rst RST_38
    db $fc
    xor b
    cp $ff
    ldh a, [rIE]
    rst RST_38
    ei
    ld a, [$fac8]
    ld [hl-], a
    db $fc
    xor b
    di
    and d
    rst RST_38
    rst RST_38
    ld a, [$fac8]
    ret z

    rst RST_30
    and d
    ld a, [$e472]
    xor $fa
    ld [hl], d
    xor $e0
    ld a, [$ff72]
    rst RST_08
    db $fc
    call z, $ffff
    ld a, [$f0c8]
    or b
    adc b
    ld a, [$3cc3]
    ldh a, [rIF]
    call z, $c8c0
    nop
    call z, $88c0
    add b
    cp $ff
    rst RST_38
    di
    db $fc
    xor b

jr_003_5d08:
    ldh a, [$ffc0]
    ldh a, [$ffb0]
    xor $c2
    ldh a, [rIE]
    ldh [rP1], a

jr_003_5d12:
    xor d
    and d
    xor d
    xor b
    xor d
    adc d
    xor d
    xor b

jr_003_5d1a:
    db $fd
    ld [$a8aa], sp
    call $aa00
    xor c

jr_003_5d22:
    call z, $f08c
    rrca
    or b
    jr nc, jr_003_5d08

    rst RST_38

jr_003_5d2a:
    nop
    nop
    nop
    nop
    nop
    inc bc
    ld h, c
    ld [bc], a
    ld [$0800], sp
    nop
    nop
    nop
    nop
    nop

jr_003_5d3a:
    nop
    nop
    nop
    nop
    pop bc
    sbc h
    ld d, b
    jr nz, jr_003_5d47

    ld a, [bc]
    ld bc, $0000

jr_003_5d47:
    nop
    ld d, b
    jr nz, jr_003_5d4f

    ld a, [bc]
    ld de, $0067

jr_003_5d4f:
    nop
    ld d, b
    jr nz, jr_003_5d57

    ld a, [bc]
    jr z, jr_003_5d08

    add b

jr_003_5d57:
    nop
    ld d, b
    jr nz, jr_003_5d5f

    ld a, [bc]
    ld [$00a5], sp

jr_003_5d5f:
    nop
    ld d, b
    jr nz, jr_003_5d67

    ld a, [bc]
    add hl, hl
    ld [hl+], a
    ld b, b

jr_003_5d67:
    nop
    ld d, b
    jr nz, jr_003_5d6f

    ld a, [bc]
    ld [$d6c1], sp

jr_003_5d6f:
    nop
    ld d, b
    jr nz, jr_003_5d77

    ld a, [bc]
    nop
    nop
    and e

jr_003_5d77:
    ret nz

    ld d, b
    jr nz, jr_003_5d7f

    inc b
    nop
    nop
    add b

jr_003_5d7f:
    nop
    ld e, b
    add b

jr_003_5d82:
    ld bc, $0014
    nop
    pop bc
    ld b, h
    ld e, b
    add b

jr_003_5d8a:
    ld bc, $0114
    db $10
    ld b, b
    nop
    jr z, jr_003_5d12

jr_003_5d92:
    ld bc, $3114
    inc bc
    nop
    ld b, b
    jr z, jr_003_5d1a

    ld bc, $3514
    ei
    nop
    nop
    jr z, jr_003_5d22

jr_003_5da2:
    ld bc, $3114
    db $e4
    dec c
    add b
    jr z, jr_003_5d2a

jr_003_5daa:
    ld bc, $1314
    ld [hl-], a
    sub c
    nop
    ld e, b
    add b

jr_003_5db2:
    inc b
    inc b
    ld bc, $000a
    nop
    jr z, jr_003_5d3a

    ld bc, $1114
    ld h, $a2
    inc b
    jr z, @-$7e

    ld bc, $1114
    ld b, [hl]
    and e
    nop
    jr nc, @-$7e

    ld bc, $390c
    and d
    ld bc, $2814
    add b
    ld bc, $2214
    pop de
    ldh [c], a
    nop
    jr z, @-$7e

    ld bc, $100c
    ld [hl+], a
    add [hl]
    nop
    jr z, @-$7e

    ld bc, $0414
    nop
    add hl, bc
    sub b
    jr z, @-$7e

    ld bc, $0d14
    ldh [$ff80], a
    ld [$8028], sp
    ld bc, $3314
    ldh a, [c]
    ld bc, $28c0
    add b
    ld bc, $3514
    db $e3
    ld b, c
    db $10
    jr z, jr_003_5d82

    ld bc, $3114
    rst RST_28
    adc d
    sbc b
    jr z, jr_003_5d8a

    ld bc, $2814
    db $e3
    nop
    nop
    jr z, jr_003_5d92

    ld bc, $1314
    ld [hl-], a
    call nz, Call_000_2800
    add b
    ld bc, $1114
    ld a, [hl+]
    stop
    jr z, jr_003_5da2

    ld bc, $2114
    ld b, l
    nop
    nop
    jr z, jr_003_5daa

    ld bc, $2010
    call nz, Call_000_00de
    jr z, jr_003_5db2

    inc b
    dec b
    inc h
    adc c
    add b
    inc b
    jr nz, jr_003_5e5a

    inc b
    inc b
    dec l
    pop bc
    nop
    nop
    nop
    nop
    nop
    sbc c
    nop
    inc b
    ld [$0020], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    adc e
    inc d
    stop
    nop
    ld [$8002], sp

jr_003_5e5a:
    add e
    nop
    stop
    nop
    ld [$c934], sp
    add e
    nop
    stop
    nop
    ld [$d128], sp
    jp $1004


    ld [$0800], sp
    nop
    ld b, e
    add e
    inc b
    stop
    nop
    ld [$c728], sp
    sub e
    inc b
    stop
    nop
    ld [$c700], sp
    add a
    inc b
    stop
    nop
    ld [$4700], sp
    sub e
    inc b
    stop
    nop
    jr z, jr_003_5e91

jr_003_5e91:
    add hl, bc
    sub e
    inc b
    nop
    nop
    nop
    jr nz, jr_003_5e99

jr_003_5e99:
    ld bc, $14c3
    nop
    nop
    nop
    jr nz, jr_003_5ea3

    pop de
    adc e

jr_003_5ea3:
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_5eda

    pop de
    add e
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_5ed3

    pop bc
    add a
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_5edf

    pop bc
    add e
    inc c
    inc b
    nop
    nop
    jr nz, jr_003_5ee2

    pop de
    add e
    ld b, h
    nop
    nop
    nop
    jr z, jr_003_5ecb

    add c
    add e

jr_003_5ecb:
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_5f05

    ret


    sub e

jr_003_5ed3:
    inc h
    inc b
    nop
    nop
    jr nz, jr_003_5f0d

    ret


jr_003_5eda:
    db $10
    inc c
    stop
    nop

jr_003_5edf:
    ld [$cd28], sp

jr_003_5ee2:
    add e
    inc h
    inc b
    nop
    nop
    jr nz, @+$23

    pop de
    adc e
    inc b
    inc b
    nop
    nop
    ld [$c738], sp
    or e
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_5f1b

    pop hl
    add e
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_5f21

    push bc
    adc e
    ld d, h
    inc b

jr_003_5f05:
    nop
    nop
    jr nz, jr_003_5f31

    jp $8483


    inc b

jr_003_5f0d:
    nop
    nop
    jr nz, jr_003_5f33

    pop af
    adc a
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_5f3f

    pop bc
    adc e

jr_003_5f1b:
    inc d
    inc b
    nop
    nop
    jr nz, jr_003_5f49

jr_003_5f21:
    rst RST_00
    add e
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_5f4a

    pop de
    xor e
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_5f65

jr_003_5f31:
    pop hl
    add e

jr_003_5f33:
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_5f6d

    ret


    add e
    nop
    inc b
    nop
    nop

jr_003_5f3f:
    nop
    inc [hl]
    ret nz

    add e
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_5f79

jr_003_5f49:
    add c

jr_003_5f4a:
    adc e
    inc h
    inc d
    nop
    nop
    jr z, jr_003_5f71

    dec d
    ld bc, $0000
    nop
    nop
    nop
    nop
    ld b, b
    nop
    ld [hl+], a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_5f65:
    nop
    nop
    inc bc
    ld [hl+], a
    rst RST_00
    sub e
    nop
    push bc

jr_003_5f6d:
    inc bc
    nop
    inc bc
    nop

jr_003_5f71:
    call nz, Call_000_00c8
    add e
    nop
    nop
    nop
    nop

jr_003_5f79:
    ret nz

    ret nz

    nop
    inc de
    call nz, $c023
    nop
    nop
    nop
    ldh [$ff83], a
    db $e3
    ld b, b
    ld [hl+], a
    jp nz, $a3c0

    ret nz

    rlca
    and e
    inc b
    add c
    ld a, [bc]
    rst RST_00
    ld b, a
    jp $c3c3


    jr nz, jr_003_5f1b

    ret nz

    or b
    db $eb
    ret nc

    rst RST_00
    db $e3
    inc de
    ret nz

    nop
    ld a, [bc]
    ret nz

    add c
    inc bc
    ld b, c
    inc bc
    db $e3
    dec hl
    db $d3
    inc bc
    inc bc
    ld [hl+], a
    dec b
    inc de
    push bc
    dec b
    add e
    sub e
    jp $cbe3


    ld [hl+], a
    ret nc

    add e
    add d
    rst RST_00
    ld b, [hl]
    add e
    inc bc
    inc hl
    or e
    rst RST_00
    ld bc, $03e2
    ld b, b
    ld d, a
    inc b
    inc b
    rst RST_00
    ret z

    jp $e380


    add $13
    add $e0
    inc bc
    and e
    nop
    ld [hl+], a
    nop
    inc bc
    ld hl, $0880
    rlca
    jp nz, $83a2

jr_003_5fde:
    ld b, c
    add e
    nop
    db $e3
    add b
    ld b, a
    ld [hl+], a
    add d
    nop
    call nc, $c843
    add a
    ret nz

    ret nz

    inc bc
    nop
    jp Jump_000_0387


    ld bc, $00c4
    inc bc
    ld [bc], a
    db $d3
    inc bc
    ld b, e
    ld b, e
    ret z

    and e
    add b
    nop
    nop
    ld [$d3c3], sp
    nop
    ld h, e
    ret nz

    rlca
    nop
    db $d3

jr_003_6009:
    ld [$0050], sp
    jr nz, jr_003_5fde

    ld [hl+], a
    jr nz, @+$05

    add e
    ret z

    ld bc, $c7e3
    db $d3
    pop bc
    ld [$d3c5], sp
    jp Jump_003_4380


    nop
    ld bc, $e043
    and e
    nop
    inc bc
    nop
    inc bc
    inc bc
    pop bc
    ldh [c], a
    ldh [$ffc0], a
    ld b, b
    ret z

    nop
    nop
    jp Jump_003_62cb


    add e
    jp Jump_000_05c8


    ld [bc], a
    nop
    nop
    and e
    ld b, h
    nop
    nop
    nop
    jr nz, jr_003_6009

    nop
    inc c
    ld b, h
    inc bc
    inc bc
    nop
    add e
    nop
    ld bc, $4400
    jp $43c0


    ret nz

    add b
    nop
    inc hl
    nop
    jp Jump_000_0381


    ret nz

jr_003_6058:
    ret nz

    add $62
    ld b, [hl]
    ld bc, $c2b0
    ld b, a
    inc de
    rst RST_00
    inc hl
    ld bc, $00c0
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_6079:
    nop
    nop
    ld [bc], a
    ld b, b
    ld [$1002], sp
    inc b
    ld b, b
    nop
    ld [$0000], sp
    nop
    nop
    inc bc
    nop
    nop
    nop
    nop
    add b
    stop
    nop
    nop
    nop
    db $10
    ld [$0a03], sp
    nop
    inc bc
    jr nz, jr_003_60db

    ld [bc], a
    add h
    ld d, b
    ld [bc], a
    adc b
    nop
    ld [$a002], sp
    add b
    jr nz, jr_003_60e7

    and b
    jr jr_003_60cb

    nop
    adc b
    ld b, b
    nop
    nop
    db $10
    ld [bc], a
    ld [$8000], sp
    jr nz, @+$06

    jr nz, jr_003_6058

    ld c, b
    ld hl, $0408
    nop
    add b
    ld b, c
    dec b
    db $10
    ld b, b
    nop
    ld b, b
    db $10
    add h
    inc b
    adc b
    ld [bc], a
    jr nz, jr_003_60cb

jr_003_60cb:
    db $10
    inc bc
    add h
    inc b
    inc b
    add d
    ld hl, $0000
    ld b, b
    ld b, b
    db $10
    ld hl, $0020
    nop

jr_003_60db:
    nop
    jr nz, jr_003_60e0

    inc bc
    ret nz

jr_003_60e0:
    ld [bc], a
    inc b
    nop
    inc b
    db $10
    inc bc
    inc b

jr_003_60e7:
    nop
    inc b
    nop
    dec b
    ld b, b
    add d
    ld b, b
    nop
    inc d
    ld [bc], a
    and b
    ld hl, $8284
    jr nz, jr_003_6079

    inc b
    ld b, b
    add h
    add b
    nop
    jr z, @+$06

    ld [bc], a
    add d
    sub b
    jr jr_003_6103

jr_003_6103:
    dec b
    ld [bc], a
    ld [$0011], sp
    add b
    add hl, bc
    add b
    db $10
    ld bc, $4121
    ld [$8004], sp
    ld hl, $8080
    add h
    ld [bc], a
    ld b, b
    jr nz, jr_003_611b

    nop

jr_003_611b:
    inc bc
    ld b, b
    jr nz, jr_003_613f

    nop
    ld [bc], a
    add b
    stop
    ld a, [bc]
    adc b
    add b
    ld b, c
    ld b, b
    jr nz, @+$22

    ret nz

    ld [$0420], sp
    ld [de], a
    ld a, [bc]
    ld b, c
    nop
    ld b, b
    jr z, jr_003_6176

    ld [bc], a
    nop
    ld bc, $0830
    jr nz, jr_003_6142

    inc b
    ld b, b

jr_003_613f:
    add b
    jr nz, jr_003_6142

jr_003_6142:
    nop
    inc bc
    ld c, b
    inc b
    ld b, b
    adc b
    dec b
    ld [$0400], sp
    nop
    ld [bc], a
    ld [bc], a
    nop
    add b
    nop
    inc b
    ld [bc], a
    add b
    nop
    nop
    nop
    add b
    ld b, b
    nop
    and b
    nop
    ld b, b
    ret nz

    nop
    dec b
    ld bc, $c041
    ld [bc], a
    ld [bc], a
    nop
    add b
    ld hl, $80c0
    add b
    db $10
    inc b
    jr nz, jr_003_6174

    ld bc, $a000
    inc b

jr_003_6174:
    jr nz, jr_003_617e

jr_003_6176:
    nop
    jr nz, jr_003_61ba

    nop
    add b
    nop
    add b
    ld [bc], a

jr_003_617e:
    nop
    ld bc, $0000
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    or b
    nop
    ld [$2e00], sp
    ld d, l
    sub b
    jr nz, jr_003_6197

jr_003_6197:
    jr nz, jr_003_61a1

    jr nz, @+$0e

    ld bc, $0c80
    nop
    jr nz, jr_003_61a9

jr_003_61a1:
    nop
    ld l, $02
    db $10
    ld de, $0310
    sbc [hl]

jr_003_61a9:
    ld c, $30
    ret nc

    ld b, a
    ld b, d
    ld [hl], c
    or c
    adc e
    sub h
    nop
    sub c
    and b
    ld l, h
    ld [hl-], a
    dec h
    jr jr_003_61ba

jr_003_61ba:
    jr nc, jr_003_6212

    ld c, a
    sub d
    db $10
    add $06
    inc [hl]
    add b
    ld d, b
    db $10
    ld b, c
    db $10
    ld a, [hl+]
    ld h, b
    ld e, $00
    ld d, d
    adc e
    sub c
    ldh a, [c]
    inc bc
    add b
    ld [$0030], sp
    rrca
    ld b, b
    ld b, b
    pop hl
    and b
    jr z, jr_003_61e3

    pop de
    sbc e
    ld [bc], a
    cp b
    ld b, b
    ld a, [bc]
    jr z, jr_003_6217

jr_003_61e3:
    ld h, h
    inc c
    ld e, h
    ld a, [bc]
    ret z

    nop
    dec [hl]
    ld [$e211], sp
    inc e
    ld [hl], h
    ld hl, $ac84
    inc c
    add hl, bc
    adc l
    inc bc
    ld h, b
    push bc
    ld bc, $3080
    ld [hl], c
    rst RST_08
    ld [bc], a
    ld h, b
    ld b, c

Jump_003_6200:
    jr nz, jr_003_6242

    add hl, hl
    pop hl
    add d
    ld c, a
    halt
    add hl, hl
    xor b
    jr nz, jr_003_6237

    ld hl, $068c
    inc d
    inc hl
    add h
    sub [hl]

jr_003_6212:
    jr z, jr_003_6225

    add a
    inc c
    db $10

jr_003_6217:
    jr nz, jr_003_6219

jr_003_6219:
    ld l, b
    cp b
    ldh [$ff8b], a
    ld b, c
    ld [hl], b
    nop
    nop
    inc [hl]
    jr nc, jr_003_623c

    add h

jr_003_6225:
    add [hl]
    ld b, b
    ld [bc], a
    nop
    nop
    inc bc
    ld [hl], c
    ld l, a
    add b
    db $10
    and l
    ld a, [bc]
    nop
    or c
    db $10
    adc a
    rrca
    ld b, h

jr_003_6237:
    ldh a, [c]
    nop
    inc d
    jr z, jr_003_624c

jr_003_623c:
    jr nz, jr_003_6280

    ld b, b
    ld hl, $0188

jr_003_6242:
    inc [hl]
    inc b
    inc b
    ld b, $b0
    ldh a, [c]
    ld b, $10
    jr c, @+$26

jr_003_624c:
    ld b, d
    rla
    add hl, bc
    ld b, b
    nop
    inc l
    adc c
    pop hl
    add b
    nop
    ld [hl], h
    ldh [rP1], a
    ld b, b
    jr c, jr_003_62cd

    sub l
    nop
    inc c
    ld [bc], a
    nop
    ld c, d
    inc [hl]
    ld [hl], b
    dec bc
    ld c, l
    ld h, d
    ld b, c
    add b
    nop
    ret nz

    daa
    rst RST_28
    ld l, $41
    ld bc, $8008
    nop
    nop
    dec h
    ld c, a
    inc b
    ld [de], a
    add hl, bc
    nop
    inc c
    pop af
    ld b, h
    rrca
    ld h, b
    or c

jr_003_6280:
    add b
    ld bc, $9704
    ret nz

    ld [de], a
    jr nc, @+$0c

    add b
    nop
    nop
    ld d, b
    ld b, h
    ld [$0000], sp
    ld [$0000], sp
    nop
    nop
    add b

jr_003_6296:
    ld [$0008], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    db $10
    ld d, b
    ld [$0a08], sp
    adc d
    nop
    inc c
    nop
    jr nz, jr_003_62ae

    nop

jr_003_62ae:
    ld a, [bc]
    ld bc, $5c90
    ld [bc], a
    jr z, jr_003_6296

    ld b, b
    jr z, jr_003_62b8

jr_003_62b8:
    nop
    nop
    inc b
    nop
    rst RST_00
    adc b
    xor c
    inc bc
    and b
    sub b
    add b
    inc hl
    and c
    nop
    ld l, c
    ld [$0203], a
    ld [hl], b

Jump_003_62cb:
    and c
    add [hl]

jr_003_62cd:
    adc h
    inc [hl]
    ld hl, $0ca3
    ld [hl], c
    ldh a, [rVBK]
    sbc h
    db $10
    pop bc
    call nc, $620d
    ret


    add c
    db $10
    jr z, jr_003_62e2

    nop
    ld [bc], a

jr_003_62e2:
    db $10
    ld c, c
    ldh a, [$ff2e]
    ld [hl], e
    adc a
    add h
    ld b, $40
    ld a, [de]
    inc b
    inc c
    add hl, bc
    add d

jr_003_62f0:
    rlca
    inc l
    nop
    pop de
    add sp, $00
    ld c, $63
    add b
    ld h, $14
    pop hl
    ld b, $1c
    inc c
    ld [hl], c
    adc d
    add b
    ld [hl], d
    ld c, l
    inc d
    ld d, b
    inc d
    db $ec
    adc e
    db $10
    ld a, b
    ld [bc], a
    add $00
    xor b
    adc l
    add b
    ld bc, $e80c
    ld [$841c], sp
    dec hl

jr_003_6318:
    add l
    adc h
    ld b, b
    db $e3
    rst RST_08
    nop
    jr c, jr_003_62f0

    cpl
    ld [bc], a
    ld [de], a
    and d
    rlca
    ld [hl], h
    inc a
    add a
    ld [bc], a
    call z, $d808
    nop
    inc d
    jr z, @+$03

    jp Jump_003_7a0c


    pop hl
    add $90
    or b
    ldh [c], a
    ld b, h
    ld [bc], a
    add h
    ld b, $40
    inc l
    ld a, [bc]
    ld bc, $0380
    or h
    ld bc, $54c0
    ld d, b
    call nz, $0887
    jr nc, jr_003_634c

jr_003_634c:
    nop
    nop
    cp c
    add e
    add h
    jr nz, jr_003_6383

    nop
    ld bc, $0c08
    add b
    scf
    inc c
    ld [$14d0], sp
    ret nz

    ld c, $63
    dec h
    ld b, [hl]
    inc b
    ret nz

    nop
    nop
    ld [$9003], sp
    nop
    ld a, b
    nop
    nop
    inc c
    nop
    ld [de], a
    dec b
    ld b, $30
    and d
    ld h, e
    ld [$e314], sp
    inc hl
    dec c
    inc b
    ld [bc], a
    inc b
    nop
    ld a, [bc]
    ld bc, $5c84
    inc c

jr_003_6383:
    ldh [$ffc7], a
    inc a
    inc bc
    ld [hl+], a
    inc bc
    ld d, $78
    nop
    rla
    inc a
    inc b
    add h
    add h
    ld c, h
    or b
    ld [bc], a
    add $80
    jr nc, jr_003_6318

    adc l
    nop
    add b
    ld bc, $80c6
    ld l, $20
    adc b
    or b
    nop
    nop
    nop
    ld b, b
    nop
    nop
    inc bc
    nop
    nop
    ld [$0000], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    and b

jr_003_63b7:
    add b
    ld d, h
    jr jr_003_63bb

jr_003_63bb:
    ld [bc], a
    inc c
    nop
    add b
    jr z, jr_003_6403

    add b
    ret nz

    dec [hl]
    nop
    stop
    nop
    ld c, b
    nop
    dec h
    ret nz

    jr jr_003_63ce

jr_003_63ce:
    ld hl, $a100
    db $10
    ld [$00a1], sp
    add e
    add hl, bc
    inc b
    nop
    ld c, b
    ld b, [hl]
    ld [$e009], sp
    dec bc
    sub c
    ld bc, $1230
    ld b, b
    nop
    ld [bc], a
    ld b, e
    ld bc, $1040
    ld de, $20c8
    jr nz, @+$45

    ld b, h
    ld b, c
    db $10
    ld h, a
    ld b, [hl]
    nop
    jr nz, @+$22

    nop
    ld d, b
    ld bc, $0040
    ld [$4222], sp
    nop
    jr nz, @+$12

    sbc b

jr_003_6403:
    add hl, bc
    ld [hl-], a
    ld h, b
    add b
    pop bc
    ld b, l
    nop
    and d
    add h
    and d
    ld bc, $9010
    sbc b
    jr nz, @+$32

    ld de, $0800
    jr nc, jr_003_6458

    nop
    ld b, [hl]
    ld bc, $0802
    jr nz, jr_003_642b

    adc d
    db $10

jr_003_6421:
    inc b
    dec c
    ret z

    ld d, b
    add d
    nop
    ld [$01a0], sp
    nop

jr_003_642b:
    inc b
    nop
    ld b, b
    ld hl, $0090
    jr nc, jr_003_643b

    jr nc, jr_003_63b7

    inc d
    jr nz, @+$62

    ld hl, $3144

jr_003_643b:
    ld h, b
    add b
    ld b, e
    inc c
    ld b, b
    pop af
    nop
    ld de, $020c
    nop
    inc c
    db $10
    and l
    ld [bc], a
    ld b, e
    inc c
    inc bc
    inc [hl]
    dec b

jr_003_644f:
    nop
    inc d
    jr nz, jr_003_6453

jr_003_6453:
    ld [$1080], sp
    nop
    dec h

jr_003_6458:
    nop
    sub b
    nop
    ld b, b
    sub b
    ld b, b
    inc h
    db $10
    add h
    inc l
    adc b
    ld b, b
    nop
    ld h, b
    add hl, hl
    ld sp, $c023
    add b
    ret z

    jr c, jr_003_6483

    stop
    jr nc, jr_003_647a

    inc d
    nop
    and h
    nop
    add b
    inc [hl]
    jr nz, jr_003_647b

jr_003_647a:
    db $10

jr_003_647b:
    inc b
    jp nz, $8000

    jr nz, jr_003_6421

    inc l
    inc d

jr_003_6483:
    db $10
    sub h
    jr nc, jr_003_6497

    ld a, [hl-]
    ld [$0140], sp
    ld b, b
    jp nz, Jump_000_0200

    ld h, b
    jr nz, @-$7e

    nop
    nop
    nop
    nop
    nop

jr_003_6497:
    jr nc, jr_003_644f

    nop
    nop
    ld [$0081], sp
    add c
    ld [bc], a
    dec l
    inc b
    inc bc
    adc c
    inc c
    inc b
    ld b, b
    nop
    jr nc, @+$06

    ld b, h
    inc c
    inc b
    ld [$0508], sp
    ld b, b
    dec b
    inc bc
    inc b
    add b
    ld bc, $0000
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld a, [de]
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add b
    jr jr_003_650e

    ld e, [hl]
    xor h
    inc bc
    nop
    nop
    add hl, bc
    pop de
    adc $80
    add b
    ld [hl], l
    ret nz

    db $ed
    add c
    ldh a, [$ffef]
    add b
    nop
    ret nz

    nop
    ld b, b
    ld h, b
    add hl, bc
    or [hl]
    sub c
    nop
    add e
    rst RST_00
    ld [$e634], sp
    rlca
    ld bc, $2830
    nop
    nop
    jr nc, jr_003_653a

    ld b, h
    ld bc, $6100
    sbc e
    inc e
    ld h, b
    ld hl, sp+$07
    ldh a, [$ff31]
    inc hl
    add e
    ld c, $00
    nop
    inc bc
    inc [hl]
    jr z, jr_003_656b

    dec b
    ld [de], a
    ldh [$ffa0], a
    ld b, b
    ld c, l

jr_003_650e:
    ld sp, $2083
    ld b, $c4
    add hl, de
    rlca
    ld c, b
    add hl, bc
    ld a, b
    rlca
    ld [de], a
    jr c, @-$1e

    ld b, a
    nop
    nop
    add b
    add b
    ld [de], a
    db $10
    ld b, d
    ld b, $1d
    ld a, [hl-]
    rst RST_00
    ld c, l
    add b
    ld [hl], b
    ld d, h
    ld c, b
    nop
    nop
    call nz, Call_000_0c0d
    ld a, c
    and b
    call z, Call_000_3880
    ld h, b
    ld a, [de]
    ld [hl+], a

jr_003_653a:
    nop
    xor $44
    inc c
    ld [hl], h

jr_003_653f:
    inc bc
    add e
    db $10
    ld [hl], b
    ldh a, [$fff7]
    call c, Call_000_2302
    ld [hl+], a
    add hl, hl
    nop
    ld [de], a
    call nz, Call_000_020c
    inc hl
    ld h, b
    add $08
    db $10
    inc bc
    ld [bc], a
    nop
    ldh [c], a
    ld b, h
    ld [bc], a
    ld [$1715], sp
    nop
    nop
    add c
    adc d
    inc c
    ld [hl], d
    ret


    sub [hl]
    ld b, c
    ld l, h
    ld a, [de]
    nop
    cp b
    add b

jr_003_656b:
    ldh [$fffb], a
    ld a, $40
    ld c, $02
    sbc [hl]
    ldh a, [rSC]
    inc bc
    inc c
    jr z, jr_003_653f

    add h
    inc e
    ld b, h
    nop
    ld bc, $013c
    ld h, c
    add h
    rlca
    jr nc, @-$05

    sbc h
    or b
    nop
    add hl, hl
    and b
    dec c
    stop
    ldh [rNR21], a
    ld b, b
    inc bc
    jr nz, jr_003_6592

jr_003_6592:
    jr nc, jr_003_65a4

    nop
    ld b, b
    jr z, jr_003_65b8

    and b
    ld c, $60
    ld de, $00e0
    ld b, h
    db $10
    and b
    dec c
    ldh [rNR12], a

jr_003_65a4:
    rlca
    inc c
    inc b
    ret z

    add h
    ld e, b
    jp nz, Jump_000_0ba0

    jr nc, jr_003_65e0

    sbc c
    add b
    ld [hl+], a
    ld b, c
    inc d
    ld b, [hl]
    nop
    nop
    inc hl

jr_003_65b8:
    nop
    ld c, a
    or h
    dec de
    add [hl]
    inc a
    jr nc, @-$1b

    nop
    inc l
    add b
    call z, $ccc1
    jr nc, @+$27

    rl d
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld h, b
    inc hl

jr_003_65e0:
    adc [hl]
    ld c, h
    jr z, @-$1e

    ld h, l
    ld a, $30
    push bc
    ld b, $00
    nop
    ld bc, $0c83
    ldh a, [$ffe2]
    ld c, $00
    nop
    ld h, [hl]
    inc d
    ld de, $4282
    ld c, $0d
    inc d
    ld d, b
    jr nz, @+$4a

    db $10
    ld [de], a
    ld bc, $3c08
    ldh a, [$ff83]
    ld c, b
    ld h, l
    pop bc
    ld b, $88
    nop
    inc bc
    db $e3
    ld l, $b0
    ld c, c
    inc b
    ld c, $f0
    ld [de], a
    nop
    db $10
    ld [hl], b
    ld b, e
    xor [hl]
    ld e, $30
    nop
    jr nz, jr_003_6666

    ldh [c], a
    ld de, $140e
    ret nz

    sub d
    ld b, b
    nop
    ld b, b
    inc h
    ld b, b
    add c
    inc d
    ld h, c
    add e
    ld [bc], a
    ld de, $0ae6
    ld bc, $1228
    sub d
    ld [bc], a
    pop af
    ldh [c], a
    and b
    nop
    adc c
    ld de, $0045
    ld [hl], h
    ld hl, $00ce
    ld b, c
    pop hl
    add e
    jr @+$34

    db $e3
    add [hl]
    db $10
    ld bc, $0010
    inc c
    add c
    inc hl
    and c
    ld e, $38
    add e
    sbc a
    adc c
    inc [hl]
    ld [bc], a
    nop
    nop
    nop
    ld d, e
    add b
    add b
    adc b
    add hl, bc
    inc b
    dec c
    nop
    jr nz, jr_003_6668

    inc e

jr_003_6666:
    stop

jr_003_6668:
    nop
    adc h
    inc [hl]
    inc e
    inc b
    cp h
    ld [hl], b
    jr nz, @+$0a

    jr nz, jr_003_6673

jr_003_6673:
    db $e3
    ret nz

    ld e, $60
    jp nz, $1086

jr_003_667a:
    jr z, @+$62

    nop
    nop
    jr nc, jr_003_6691

    xor d
    inc e
    jr nc, jr_003_6688

    nop
    ld h, d
    db $10
    pop bc

jr_003_6688:
    dec b
    nop
    ld d, b
    db $e4
    nop
    ld b, b
    jr nc, jr_003_66b8

    ld c, b

jr_003_6691:
    nop
    inc b
    nop
    inc b
    ld b, $14
    ret nz

    inc b
    nop
    inc [hl]
    dec c
    ld c, d
    ld h, $38
    ldh [rP1], a
    inc e
    jr z, jr_003_66a4

jr_003_66a4:
    ld [bc], a
    nop
    jr c, jr_003_667a

    ret nz

    inc d
    inc [hl]
    ld l, a
    ret nz

    nop
    ld h, h
    jp nz, Jump_000_009a

    db $10
    jr nz, jr_003_66b9

    add hl, bc
    ld h, h
    ld c, d

jr_003_66b8:
    inc [hl]

jr_003_66b9:
    dec l
    nop
    dec b
    ld d, b
    dec c
    ldh a, [$ffa0]

jr_003_66c0:
    ld c, $00
    ld c, $60
    ld [$401c], sp
    db $e3
    add [hl]
    nop
    inc [hl]
    inc de
    jp Jump_000_1020


    and d
    jr nc, jr_003_66d2

jr_003_66d2:
    ld bc, $cb6b
    ld c, [hl]
    ld b, b
    pop bc
    adc d
    nop
    ld [bc], a
    ld bc, $08cb
    nop
    nop
    ld d, $00
    nop
    nop
    nop
    nop
    nop
    inc bc
    nop
    nop
    ld bc, $0482
    add b
    ld bc, $0882
    add d
    nop
    jr jr_003_6715

    jr nz, jr_003_66f7

jr_003_66f7:
    inc [hl]
    nop
    nop
    inc d
    inc d
    adc h
    inc d
    add hl, bc
    inc d
    inc a
    ld d, h
    inc b
    nop

jr_003_6704:
    jr nz, jr_003_670a

    ld b, h
    db $10
    add b
    inc c

jr_003_670a:
    ld b, d
    nop
    ld c, c
    inc [hl]
    inc l
    inc c
    ld [hl+], a
    add hl, hl
    ld b, d
    nop
    ld a, [hl+]

jr_003_6715:
    ld d, h
    ld [hl+], a
    inc l
    ld b, h
    ld b, h
    ld [de], a
    inc l
    ld bc, $3c24
    ld c, b
    inc h
    add d
    ld a, [bc]
    jr z, jr_003_6729

    jr z, jr_003_6768

    add c
    add b

jr_003_6729:
    ld [bc], a
    add h
    ld sp, $2180
    inc d
    adc h
    inc l
    ld bc, $5c80
    ld a, [hl+]
    ld b, h
    ld c, h
    jr z, jr_003_6759

    nop
    jr nz, jr_003_66c0

    adc b
    ld bc, $4c30
    ld b, b
    add b
    nop
    inc b
    ld hl, $0a89
    ld [hl+], a
    ld [$0089], sp
    inc h
    ld [bc], a
    inc b
    add b
    ld hl, $8124
    nop
    ld c, c
    inc l
    ld b, d
    ld bc, $8488

jr_003_6759:
    ld hl, $4100
    ld c, b
    ld [$0020], sp
    inc d
    nop
    adc d
    ld [hl-], a
    ld [hl+], a
    ld hl, $0882

jr_003_6768:
    ld [bc], a
    ld [bc], a
    nop
    nop
    nop
    inc h
    inc c
    inc c
    jr nz, jr_003_6704

    ld d, d
    inc h
    db $10
    ld c, b
    ld b, b
    add b
    inc h
    ld [hl-], a
    inc h
    ld b, h
    jr jr_003_67a2

    ld [$4c2a], sp
    add hl, bc
    adc c
    ld d, h
    inc h
    add h
    ld c, d
    jr nz, @-$6a

    ld b, d
    db $10
    inc b
    ld a, [bc]
    add hl, bc
    inc b
    jr nz, jr_003_67b9

    ld b, d
    sub h
    ld d, b
    ld c, h
    add c
    sbc c
    add d
    ld c, h
    adc b
    ld b, d
    add h
    adc c
    ld [hl+], a
    add d
    ld [bc], a
    inc c
    ld [hl+], a

jr_003_67a2:
    sub h
    add h
    sub c
    ld hl, $4c99
    db $10
    ld [$4032], sp
    inc h
    ld [hl+], a
    ld [hl+], a
    ld b, b
    add b
    ld b, d
    ld c, b
    ld [$4900], sp
    ld d, b
    nop
    inc b

jr_003_67b9:
    ld c, b
    db $10
    add c
    adc b
    db $10
    db $10
    jr nz, @-$6e

    inc d
    inc c
    inc d
    sbc b
    sub d
    add hl, hl
    ld b, b
    inc [hl]
    ld [$0000], sp
    ld b, c

jr_003_67cd:
    ld [$3252], sp
    ld de, $022c
    ld [bc], a
    inc c
    ld [bc], a
    ld b, h
    ld [bc], a
    inc b
    adc d
    adc h
    inc e
    inc b
    add hl, bc
    ld b, h
    inc c
    inc b
    inc c
    inc b
    jr @-$7c

    jr jr_003_67e7

jr_003_67e7:
    nop
    jr jr_003_67ea

jr_003_67ea:
    jr nz, jr_003_680d

    add b
    nop
    jr nz, @+$22

    ld [bc], a
    ld d, b
    ld bc, $0000
    nop
    nop
    nop
    nop
    nop
    ld [$0030], sp
    nop
    nop
    nop
    nop
    jr nz, jr_003_6803

jr_003_6803:
    nop
    ld [$0000], sp
    inc b
    jr nc, jr_003_680a

jr_003_680a:
    nop
    ld e, $00

jr_003_680d:
    nop
    db $10
    jr nc, jr_003_681d

    jr nc, jr_003_682b

    jr nz, jr_003_683d

    ld e, $00
    cp b
    dec c
    ld c, $30
    jr nz, jr_003_67cd

jr_003_681d:
    ld e, b
    nop
    nop
    ld d, h
    jr nz, jr_003_6873

    nop
    dec c
    ld [hl], b
    ld c, c
    jr nz, @+$1e

    ld a, [hl-]
    nop

jr_003_682b:
    nop
    ld a, $0e
    add hl, sp
    nop
    add hl, bc
    ld c, $14
    sub h
    ld l, $0a
    ld [$0038], sp
    nop
    ld [bc], a
    ld d, b
    sub b

jr_003_683d:
    ld e, [hl]
    add hl, bc
    jr nz, jr_003_6841

jr_003_6841:
    nop
    dec b
    ld [$9a00], sp
    dec c
    jr jr_003_6851

    ld [bc], a
    inc l
    inc c
    nop
    ld c, $09

jr_003_684f:
    jr nc, jr_003_687d

jr_003_6851:
    sub b
    jr nz, jr_003_6870

    ld [hl], h
    ld [$6d08], sp
    or h
    jr nz, jr_003_6863

    ld a, [hl]
    inc c
    ld a, b
    ld d, b
    jr nz, jr_003_686e

    dec e
    ld d, l

jr_003_6863:
    nop
    dec c
    sub l
    inc e
    inc b
    ld [$2d1e], sp
    jr jr_003_687a

    xor b

jr_003_686e:
    ld a, [hl-]
    ld [hl], b

jr_003_6870:
    inc [hl]
    nop
    nop

jr_003_6873:
    ld e, [hl]
    jr nz, jr_003_6876

jr_003_6876:
    inc e
    ld [de], a
    ld l, $9d

jr_003_687a:
    ld a, [bc]
    ld l, h
    ld a, [bc]

jr_003_687d:
    ld a, [bc]
    inc b
    ld h, [hl]
    ld a, [bc]
    ld d, b
    or h
    inc c
    halt
    nop
    inc b
    ld b, $0e
    ld b, b
    ld b, $58
    ld [hl], b
    ld [bc], a
    xor l
    ld h, b
    inc [hl]
    dec l
    inc l
    ld a, b
    nop
    inc c
    cp b
    stop
    inc a
    ld [$0e02], sp
    ld c, $3d
    dec e
    ld h, b
    inc [hl]
    nop
    inc c
    nop
    ld e, c
    inc h
    dec b
    ld [hl], b
    ld c, d
    inc l
    ld d, b
    ld e, h
    jr z, jr_003_684f

    or b
    ld [$60a0], sp
    dec b
    ld c, h
    ld a, [de]
    dec h
    ld e, $28
    ld b, $30
    ld [$a82e], sp
    jr nz, jr_003_690d

    ld c, $a0
    add hl, hl
    nop
    or l
    xor [hl]
    inc c
    inc a
    db $10
    ld [$4a29], sp
    dec h
    sbc b
    jr nc, @-$6e

    cp b
    jr nc, jr_003_6903

    inc c
    dec [hl]
    jr nc, jr_003_68ef

    nop
    jr c, jr_003_6908

    or b
    ld d, b
    db $10
    ld [$00a9], sp
    sbc c
    ld e, h
    ld a, $22
    jr nc, jr_003_68e6

jr_003_68e6:
    ld a, [hl-]
    inc e
    and b
    jr nc, @+$72

    and b
    and b
    and b
    ld a, b

jr_003_68ef:
    jr z, jr_003_6921

    inc c
    nop
    ld [$3470], sp
    ld a, d
    inc l
    ld a, d
    nop
    sbc d
    and l
    inc c
    ld b, $09
    xor l
    xor b
    ld a, [bc]
    dec b

jr_003_6903:
    ld a, [bc]
    dec c
    dec [hl]
    nop
    nop

jr_003_6908:
    nop
    ld c, $00
    nop
    sub b

jr_003_690d:
    ld a, [bc]
    nop
    nop
    ld [$0800], sp
    jr c, jr_003_6991

    sbc d
    ld c, b
    jr c, jr_003_691b

    jr c, jr_003_691b

jr_003_691b:
    ld b, b
    or c
    ld a, [hl+]
    ld [bc], a
    nop
    ld [hl], b

jr_003_6921:
    adc e
    ld [$380c], sp
    ld c, b
    call z, Call_000_2c5c
    jr c, @+$0a

    ld bc, $4000
    sub b
    ld c, [hl]
    jr nz, jr_003_698e

    jr jr_003_697f

    jr jr_003_6936

jr_003_6936:
    jr z, jr_003_6978

    jr jr_003_6956

    inc l
    ret nz

    adc b
    inc l
    inc c
    inc b
    and b
    inc l
    inc c
    inc [hl]
    ld [$2828], sp
    nop
    sub h
    jr c, jr_003_6957

    cp [hl]
    inc c
    ld e, $24
    inc [hl]
    jr nc, jr_003_695a

    jr z, @+$2a

    jr nz, jr_003_6972

jr_003_6956:
    inc c

jr_003_6957:
    sbc b
    jr z, jr_003_69d6

jr_003_695a:
    ld e, $38
    jr jr_003_6976

    cp b
    or b
    ld bc, $1676

jr_003_6963:
    xor b
    or b
    inc c
    ld a, $a4
    inc de
    scf
    ld d, c
    ld h, b
    dec a
    sub h
    ld [$0030], sp
    inc a

jr_003_6972:
    ld [hl], b
    or h
    ret c

    adc b

jr_003_6976:
    ld d, $0c

jr_003_6978:
    inc e
    inc [hl]
    add c
    jr c, jr_003_69a9

    sbc h
    adc b

jr_003_697f:
    or [hl]

jr_003_6980:
    jr z, jr_003_6997

    ret nc

    inc e
    sub d
    nop
    stop
    ld l, h
    ld b, d
    xor b
    inc b
    sbc h
    inc l

jr_003_698e:
    inc l
    nop
    inc b

jr_003_6991:
    nop
    ld bc, $0a40
    inc d
    ld l, b

jr_003_6997:
    ld d, b
    ld a, [bc]
    inc [hl]
    add hl, bc
    inc e
    ld d, b
    jr nc, jr_003_69cf

    dec sp
    inc [hl]
    nop
    inc [hl]
    jr jr_003_69e7

    sub b
    ldh a, [c]
    jr nz, @+$3a

jr_003_69a9:
    ld e, h
    inc e
    inc [hl]
    jr jr_003_6963

    nop
    jr nc, jr_003_69cd

    inc h
    ld c, $88
    ld l, h
    ld hl, sp+$68
    cpl
    ld e, $14
    add hl, de
    ld a, [hl-]
    inc [hl]
    inc d
    inc [hl]
    dec [hl]
    jr c, jr_003_6980

    jr jr_003_69f4

    inc a
    jr c, jr_003_69df

    ld c, b
    inc b
    cp h
    inc d
    cp b
    dec [hl]

jr_003_69cd:
    jr c, jr_003_6a0b

jr_003_69cf:
    sbc h
    nop
    ld [hl], b
    add hl, sp
    jr nc, jr_003_69e5

    inc a

jr_003_69d6:
    sbc b
    jr nc, jr_003_6a09

    inc e
    ld h, $8a
    jp nc, Jump_000_3238

jr_003_69df:
    ld h, [hl]
    ld hl, sp+$3e
    nop

jr_003_69e3:
    inc e
    ld a, [hl+]

jr_003_69e5:
    nop
    ld h, b

jr_003_69e7:
    ld hl, $0c10
    add b
    ld e, l
    ld a, [hl-]
    inc a
    jr c, jr_003_69f2

    inc b
    ld a, d

jr_003_69f2:
    halt
    nop

jr_003_69f4:
    jr z, jr_003_69f6

jr_003_69f6:
    db $10
    jr nc, jr_003_6a51

    inc l
    ret c

    adc c
    ld [$0c80], sp
    nop
    inc c
    db $10
    jr c, jr_003_6a0c

    add b
    inc c
    inc [hl]
    inc b
    nop

jr_003_6a09:
    add b
    inc c

jr_003_6a0b:
    nop

jr_003_6a0c:
    jr nc, jr_003_6a0e

jr_003_6a0e:
    nop
    nop
    nop
    ld a, [bc]
    jr nz, jr_003_6a28

    ld de, $1000
    jr nc, jr_003_6a1d

    jr nc, jr_003_6a27

    nop
    nop

jr_003_6a1d:
    nop
    nop
    nop
    nop
    nop
    ld [$080d], sp
    nop
    ld b, d

jr_003_6a27:
    nop

jr_003_6a28:
    add b
    nop
    nop
    nop
    ld b, b
    ld d, b
    nop
    nop
    nop
    nop
    ld bc, $0014
    inc b
    ld [bc], a
    inc b
    nop
    nop
    ld [bc], a
    ld [bc], a
    nop
    ld b, $80
    nop
    nop
    nop
    ld d, b
    sub d
    nop
    ld [bc], a
    ld bc, $0000
    stop
    ld [bc], a
    nop
    ld a, [bc]
    ld bc, $0000

jr_003_6a51:
    inc b
    ld b, b
    ld [hl+], a
    nop
    dec h
    nop
    nop
    ld b, b
    nop
    ld [hl], $00
    ld b, h
    inc d
    nop
    ld h, $44
    jr nz, jr_003_69e3

    nop
    ld [bc], a
    inc b
    add d

jr_003_6a67:
    nop
    nop
    ld b, b
    ld b, h
    nop
    nop
    ld l, h
    and h
    nop
    nop
    ld c, $40
    db $10
    ld b, h
    ld [bc], a
    nop
    and d
    ld b, b
    nop
    ld b, b
    jr nc, @-$7e

    db $10
    ld hl, $4201
    jr nc, jr_003_6ac3

    nop
    inc b

jr_003_6a85:
    ld h, $44
    jr nz, @+$42

    nop
    ld b, b
    nop
    ld b, b
    inc b
    nop
    nop
    nop
    cp b
    ld c, h
    ld [hl+], a
    ld bc, $4220
    jr nz, jr_003_6adb

    nop
    ld [bc], a
    ld [hl+], a
    ld b, b
    nop
    inc b
    ld b, $80
    ld b, $20
    nop
    ld b, [hl]
    ld a, [bc]
    ld c, b
    jr nz, jr_003_6aaa

    ld a, [hl-]

jr_003_6aaa:
    nop
    ld bc, $0c12
    ld l, $2c
    inc b
    nop
    ld [bc], a
    ld c, h
    ld b, c
    cp h
    inc b
    jr nz, jr_003_6b01

    jr nc, jr_003_6abb

jr_003_6abb:
    nop
    add d
    nop
    inc b
    nop
    ld b, d
    nop
    nop

jr_003_6ac3:
    ld bc, $10a2
    dec b
    ld [$140a], sp
    add c
    ld b, b
    ld [bc], a
    dec c
    ld b, l
    ld [bc], a
    ld b, d
    ld b, b
    nop
    ld [$0d42], sp
    ld b, [hl]
    nop
    ld b, c
    nop
    nop

jr_003_6adb:
    nop
    ld [hl+], a
    ld h, l
    ld b, b
    ld c, $80
    ld sp, $1c00
    ld b, [hl]
    jr nc, jr_003_6a67

    nop
    ld [$090c], sp
    nop
    ld b, h
    nop
    sub h
    nop
    add b
    inc c
    ld b, d
    inc b
    ld h, b
    ld hl, $0100

jr_003_6af8:
    nop
    ld [$0032], sp
    add b
    ld h, b
    ld a, [hl+]
    ld [hl+], a
    nop

jr_003_6b01:
    jr nc, jr_003_6a85

    ld bc, $0802
    dec b
    jr nz, jr_003_6b4b

    jr nc, jr_003_6b4b

    ld [bc], a
    nop
    ld [$0005], sp
    nop
    ld [bc], a
    nop
    ld [bc], a
    nop
    ld [$0200], sp
    nop
    inc b
    ld [bc], a
    nop
    nop
    inc c
    nop
    nop
    inc b
    ld [bc], a
    ld [$0000], sp
    nop
    inc b
    ld bc, $0000
    nop
    nop
    nop
    nop
    ld [$0002], sp
    ld sp, $00b0
    nop
    jr nc, jr_003_6b37

jr_003_6b37:
    nop
    nop
    nop
    inc c
    nop
    nop
    nop
    nop
    stop
    or b
    nop
    nop
    nop
    nop
    inc c
    add d
    nop
    add d
    inc b

jr_003_6b4b:
    nop
    nop
    nop
    nop
    nop
    nop
    ld [bc], a
    nop
    nop
    nop
    nop
    and b
    xor h
    nop
    inc b
    inc c
    nop
    nop
    add b
    inc b
    ld [$0500], sp
    ld [$0000], sp
    ld [bc], a
    jr nz, jr_003_6b6c

    nop
    dec b
    nop
    nop

jr_003_6b6c:
    jr nz, jr_003_6b72

    inc b
    nop
    jr nz, jr_003_6af8

jr_003_6b72:
    inc b
    ld [bc], a
    ld hl, $0140
    ld bc, $0608
    dec l
    ld bc, $2020
    nop
    nop
    db $10
    ld [de], a
    add l
    ld b, h
    nop
    ld b, $20
    add h
    ld hl, $2008
    sub b
    nop
    nop
    nop
    ld b, b
    inc [hl]
    ld b, b
    sbc h
    dec b
    inc b
    ld b, b
    nop
    add c
    nop
    add hl, bc
    ld bc, $2000
    nop
    nop
    nop
    jr nz, jr_003_6ba4

    inc h
    nop

jr_003_6ba4:
    nop
    ld h, b
    nop
    nop
    add hl, de
    nop
    add hl, bc
    add b
    jr z, @+$42

    inc b
    inc c
    jr z, jr_003_6bb2

jr_003_6bb2:
    db $10
    ld a, [bc]
    nop
    inc b
    nop
    ld b, b
    nop
    ld [$0022], sp
    ld [$0044], sp
    add c
    inc c
    dec c
    add l
    add b
    dec b
    nop
    ld [$0c80], sp
    ld a, l
    ld hl, $0600
    ld b, b
    nop
    add b
    inc h
    inc b
    db $10
    ld b, b
    ld [$0100], sp
    nop
    ld c, h
    add b
    dec h
    ld b, b
    ld a, [bc]
    add b
    inc a
    jr nz, jr_003_6bf9

    ld c, h
    dec c
    ld [$2420], sp
    nop
    nop
    inc c
    inc b
    jr nz, @+$04

    ld [$0800], sp
    ld b, b
    inc c
    dec b
    inc b
    inc c
    jr nz, jr_003_6c3a

    ld [$2980], sp

jr_003_6bf9:
    ld b, b
    jr nz, jr_003_6bfc

jr_003_6bfc:
    ld bc, $0402
    nop
    nop
    nop
    and c
    nop
    nop
    ld [bc], a
    ld [$4002], sp
    nop
    inc h
    inc b
    nop
    nop
    ld b, b
    adc b
    jr nc, jr_003_6c43

    adc d
    inc c
    nop
    ld b, b
    jr z, jr_003_6c38

    inc c
    nop
    add hl, bc
    nop
    inc l
    ld b, b
    jr nz, jr_003_6c20

jr_003_6c20:
    nop
    add hl, bc
    ld b, $40
    nop
    nop
    nop
    inc b
    nop
    add hl, bc
    nop
    nop
    nop
    nop
    inc b
    nop
    nop
    ld [bc], a
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_6c38:
    nop
    nop

jr_003_6c3a:
    ld bc, $0004
    nop
    add b
    nop
    nop
    nop
    ld [bc], a

jr_003_6c43:
    nop
    nop
    ld c, h
    ld h, b
    nop
    nop
    ld b, b
    nop
    ld bc, $0000
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_003_6c55

jr_003_6c55:
    nop
    nop
    stop
    nop
    jr nz, jr_003_6c5c

jr_003_6c5c:
    nop
    nop
    nop
    ld [$0000], sp
    nop
    nop
    ld bc, $00c0
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$0000], sp
    inc b
    nop
    stop
    ld [$0000], sp
    stop
    stop
    db $10
    ld [$0010], sp
    inc b
    jr c, jr_003_6c98

    ld [$0c24], sp
    stop
    inc b
    nop
    stop
    inc d
    nop
    nop
    jr nz, @+$1e

    ld [$3010], sp
    db $10
    inc b
    inc b

jr_003_6c98:
    stop
    nop
    inc c
    nop
    db $10
    ld h, c
    ld [$0800], sp
    nop
    ld b, h
    inc b
    nop
    jr nz, jr_003_6cb8

    nop
    nop
    nop
    ld [bc], a
    ld a, [bc]
    stop
    stop
    nop
    nop
    inc b
    nop
    nop
    inc h
    nop

jr_003_6cb8:
    nop
    ld [$1008], sp
    jr nz, jr_003_6cd6

    nop
    nop
    nop
    nop
    db $10
    jr jr_003_6cc9

    ld [$0028], sp
    nop

jr_003_6cc9:
    jr @+$1e

    inc b
    ld [$0008], sp
    stop
    ld [$0000], sp
    jr jr_003_6cda

jr_003_6cd6:
    nop
    ld [$0804], sp

jr_003_6cda:
    db $10
    ld [$04c2], sp
    jr nz, jr_003_6cf0

    inc b
    nop
    nop
    nop
    nop
    inc b
    jr z, jr_003_6ce8

jr_003_6ce8:
    nop
    nop
    nop
    nop
    ld [$2300], sp
    adc b

jr_003_6cf0:
    nop
    ld [$0000], sp
    jr nz, jr_003_6cfe

    nop
    nop
    nop
    inc b
    nop
    ld [$1800], sp

jr_003_6cfe:
    ld [$0004], sp
    db $10
    inc b
    nop
    db $10
    db $10
    inc b
    ld [$0000], sp
    inc b
    ld [$0000], sp
    add h
    add b
    nop
    db $10
    ld [$0800], sp
    ld [$0000], sp
    nop
    stop
    stop
    jr nc, @+$26

    jr jr_003_6d21

jr_003_6d21:
    ld [$0400], sp
    nop
    stop
    db $10
    inc b
    nop
    nop
    jr nc, jr_003_6d2d

jr_003_6d2d:
    ld [$1000], sp
    nop
    nop
    nop
    nop
    nop
    inc d
    stop
    nop
    nop
    nop
    nop
    nop
    inc b
    ld [$0000], sp
    ld [$0008], sp
    nop
    nop
    nop
    nop
    ld [$0800], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    inc b
    nop
    nop
    nop
    ld de, $0000
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    di
    rst RST_38
    db $fc
    rst RST_38
    rst RST_30
    stop
    rst RST_38
    rst RST_38

jr_003_6d94:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    cpl
    xor a
    rst RST_38
    db $fc
    db $fc
    jr nc, jr_003_6d94

    ret nz

    nop
    rrca
    di
    ret nz

    nop
    jr nc, jr_003_6de8

    rst RST_38
    rst RST_30
    rst RST_38
    and d
    ld [hl+], a
    db $fd
    rst RST_38
    rst RST_30
    push de
    rst RST_38
    rst RST_38
    ld c, b
    nop
    ld h, b
    nop
    di
    or e
    inc c
    rrca
    rst RST_38
    rst RST_28
    rst RST_38
    ldh a, [c]
    rst RST_38
    di
    db $fc
    ld hl, sp-$20
    rst RST_38
    rrca
    rst RST_38
    db $dd
    dec c
    inc bc
    nop
    ccf
    dec sp
    rst RST_38
    rst RST_38
    inc sp
    inc hl
    cp a
    rst RST_38
    db $fc
    xor b
    db $10
    rst RST_38
    ret nz

    nop
    rst RST_38
    cp a
    xor $e0
    xor $e0
    xor $e0
    rst RST_08
    adc d
    rst RST_38
    ldh a, [$fffc]
    xor b

jr_003_6de8:
    db $dd
    ldh a, [rIE]
    ccf
    db $e4
    xor $ff
    ccf
    ret c

    ld a, [$e0ee]
    xor h
    db $fc
    inc a
    call z, $faee
    ld a, [$fcc8]
    xor b
    ld a, [$fac8]
    ld a, [hl-]
    rst RST_08
    ret nz

    rst RST_08
    ret nz

    rst RST_38
    ld l, h
    ret z

    adc b
    nop
    db $10
    inc a
    jp $fcb8


    ldh [c], a
    xor $fa
    ret z

    xor $e0
    db $fc
    xor b
    ldh a, [rIF]
    rst RST_38
    rst RST_38
    xor $e0
    xor $e0
    xor $e0
    rst RST_38
    rst RST_38
    xor $e0
    xor $e0
    db $dd
    ret nc

    rst RST_38
    rst RST_38
    scf
    ccf
    xor $e0
    rst RST_38
    rst RST_38
    di
    ld [hl+], a
    and b
    add b
    rst RST_30
    rst RST_38
    cp $ff
    ld c, $0a
    ldh a, [$ffe0]
    cp a
    adc h
    xor $4e
    ld a, [$f0f3]
    pop hl
    sbc c
    dec e
    rst RST_28
    ldh [rP1], a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $7024
    nop
    inc de
    inc h
    ld a, b
    inc b
    ld d, $03
    ld bc, $0b44
    inc sp
    ld bc, $0044
    inc c
    jr c, jr_003_6eb2

jr_003_6eb2:
    add hl, bc
    inc h
    ld a, b
    nop
    nop
    inc b
    ld a, b
    nop
    ld bc, $7024
    nop
    add hl, bc
    xor b
    jr nc, jr_003_6ec2

jr_003_6ec2:
    ld bc, $7024
    nop
    dec c
    ld [hl+], a
    ld sp, $0000
    inc b
    ld a, b
    nop
    ld bc, $3020
    nop
    ld bc, $7024
    nop
    nop
    inc b
    ld a, b
    nop
    ld bc, $3020
    nop
    nop
    inc b
    ld a, b
    nop
    dec c
    ld h, $71
    nop
    ld bc, $3020
    nop
    ld bc, $7024
    nop
    ld bc, $3020
    nop
    ld bc, $3020
    nop
    nop
    inc b
    ld a, b
    nop
    nop
    inc b
    ld a, b
    nop
    nop
    inc b
    ld a, b
    nop
    nop
    inc b
    ld a, b
    nop
    nop
    inc b
    ld a, b
    nop
    ld bc, $3020
    nop
    ld bc, $7024
    nop
    nop
    inc b
    ld a, b
    nop
    ld [de], a
    inc c
    ld a, b
    inc b
    nop
    inc b
    ld a, b
    nop
    ld bc, $3020
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    nop
    inc b
    ld a, b
    nop
    ld bc, $7824
    nop
    dec c
    ld h, $71
    nop
    ld bc, $7024
    nop
    dec c
    ld h, $71
    nop
    ld bc, $3020
    nop
    dec c
    ld [hl+], a
    ld sp, $0100
    inc h
    ld [hl], b
    nop
    nop
    inc b
    ld a, b
    nop
    ld bc, $3020
    nop
    nop
    inc b
    ld a, b
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    ld [de], a
    inc b
    ld a, b
    inc b
    nop
    inc b
    ld a, b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add hl, bc
    inc l
    ld c, b
    nop
    add hl, bc
    inc l
    ld c, b
    nop
    add hl, bc
    ld h, $48
    nop
    inc de
    daa
    ld b, [hl]
    sub l
    di
    dec h
    ld b, [hl]
    sbc l
    di
    dec h
    ld b, [hl]
    sbc l
    di
    dec h
    ld b, [hl]
    sbc l
    di
    ld hl, $8d06
    nop
    inc b
    ld c, b
    nop
    ld bc, $4024
    nop
    add hl, bc
    xor b
    nop
    nop
    nop
    inc b
    ld c, b
    nop
    add hl, bc
    xor b
    nop
    nop
    add hl, bc
    xor b
    nop
    nop
    add hl, bc
    jr nz, jr_003_6fed

jr_003_6fed:
    nop
    nop
    inc b
    ld c, b
    nop
    nop
    inc b
    ld c, b
    nop
    nop
    inc b
    ld c, b
    nop
    ld bc, $0020
    nop
    ld bc, $4024
    nop
    nop
    inc b
    ld c, b
    nop
    ld bc, $4024
    nop
    nop
    inc b
    ld c, b
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    nop
    inc b
    ld c, b
    nop
    nop
    inc c
    ld c, b
    nop
    ld [de], a
    inc c
    ld c, b
    inc b
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    ld bc, $0020
    nop
    add hl, bc
    ld hl, $9506
    ld [hl], e
    ld hl, $1d06
    ld [hl], e
    ld hl, $1d06
    ld [hl], e
    ld hl, $1d06
    ld [hl], e
    ld hl, $8d06
    add hl, bc
    inc h
    ld c, b
    nop
    nop
    inc b
    ld c, b
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    ld bc, $4024
    nop
    ld bc, $482c
    nop
    nop
    inc b
    ld c, b
    nop
    ld bc, $0020
    nop
    nop
    inc b
    ld c, b
    nop
    nop
    inc b
    ld c, b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$0000], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    xor [hl]
    adc c
    xor $09

jr_003_70ca:
    xor $09
    ldh a, [c]
    and c

jr_003_70ce:
    call z, $cff0
    ret nz

jr_003_70d2:
    di
    ret nz

    db $fc
    jr nc, jr_003_70ca

    ret nz

    db $fc
    jr nc, jr_003_70ce

    ret nz

    db $fc
    jr nc, jr_003_70d2

    ret nz

    db $fc
    inc c
    db $fc
    inc c
    rst RST_08
    ret nz

    rst RST_38
    db $fd
    db $dd
    ldh a, [$ffdf]
    rst RST_38
    rst RST_30
    push de
    cp a
    rst RST_38
    adc a
    nop
    rst RST_18
    adc a
    rst RST_30
    and d
    rst RST_30
    rst RST_38
    and d
    ld [hl+], a
    rst RST_30
    rst RST_38
    adc h
    inc c
    ldh [c], a
    xor $ff
    rst RST_38
    inc bc
    nop
    ccf
    dec sp
    inc bc
    ld d, a
    inc a
    rst RST_38
    ldh a, [rIF]
    rst RST_30
    call nz, $c8fa
    ldh [$ffee], a
    rst RST_38
    rst RST_30
    xor $e0
    ld [bc], a
    nop
    ld hl, sp+$0f
    xor $e0
    ld a, [$f3c8]
    rst RST_38
    di
    ld d, c
    ei
    rst RST_38
    nop
    ld c, $ff
    db $fc
    rst RST_38
    di
    rst RST_38
    rst RST_38
    cp a
    rst RST_38
    xor $e0
    rst RST_38
    rst RST_38
    rst RST_38
    dec bc

jr_003_7134:
    call nz, $fa00
    ret z

    xor $4e
    ld a, [$c3c8]
    rrca
    db $fc
    jr nc, jr_003_7134

    ret nz

    ldh a, [rIF]
    db $eb
    xor a
    rst RST_38
    ldh a, [$fffa]
    ret z

    rst RST_38
    ei
    ld a, [$bfc8]
    or b
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
    rst RST_38
    nop
    ld a, [$bb72]
    ldh a, [$ffdf]
    ld d, l
    ldh [$ffc0], a
    ret c

    ld a, [$a2f7]
    rst RST_38
    rst RST_38
    db $fd
    push af
    cp $ff
    db $fc
    inc bc
    rst RST_28
    ld [$0032], a
    db $fc
    xor b
    ldh a, [$ffc0]
    rst RST_38
    ldh a, [$fffa]
    jp nz, $d0f0

    xor a
    call z, RST_00
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_719e:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_71a6:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_71ae:
    ld [$0000], sp
    nop
    nop
    nop
    nop
    nop

jr_003_71b6:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_71be:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_71c6:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_71d6:
    nop
    nop
    nop
    nop
    nop
    ld [$2050], sp
    inc b
    ld a, [bc]
    ld [$0200], sp
    nop
    ld d, b
    jr nz, jr_003_71eb

    ld a, [bc]
    nop
    ld [hl+], a
    ld a, [bc]

jr_003_71eb:
    nop
    ld d, b
    jr nz, @+$06

    ld a, [bc]
    nop
    ld bc, $8003
    ld d, b
    add b

jr_003_71f6:
    inc b
    ld a, [bc]
    nop
    nop
    ld [hl+], a
    sub b
    jr nz, jr_003_721e

    ld bc, $141a
    ld [hl+], a
    nop
    nop
    ld e, b
    add b

jr_003_7206:
    ld bc, $1014
    nop
    nop
    inc c
    ld d, b
    jr nz, jr_003_7210

    ld a, [de]

jr_003_7210:
    add hl, sp
    add b
    ld bc, $2890
    add b

jr_003_7216:
    ld bc, $2714
    jp RST_00


    jr z, jr_003_719e

jr_003_721e:
    ld bc, $3614
    adc e
    sub b
    inc c
    jr z, jr_003_71a6

    ld bc, $0014
    ld h, h
    ld [bc], a
    sbc h
    jr z, jr_003_71ae

    ld bc, $1314
    ld [$0006], sp
    jr z, jr_003_71b6

    ld bc, $0214
    db $10
    adc b
    nop
    jr z, jr_003_71be

    ld bc, $3314
    di
    adc e
    sub b
    jr nz, jr_003_71c6

    ld bc, $3d14
    ld l, e
    ld [$282c], sp
    add b
    ld bc, $3814
    db $ed
    inc c
    nop
    jr c, jr_003_71d6

    ld bc, $081c
    or c
    ld h, d
    jr nz, @+$2a

    add b
    ld bc, $1514
    ld a, [hl+]
    nop
    sub b
    jr z, @-$7e

    ld bc, $1114
    jr z, @+$24

    add b
    jr z, @-$7e

    ld bc, $2014
    sub b
    pop de
    nop
    jr z, jr_003_71f6

    ld bc, $2414
    ret nz

    ld bc, $28c0
    add b
    ld bc, $3614
    ldh [$ffdb], a
    add b
    jr z, jr_003_7206

    ld bc, $3914
    add a
    inc c
    nop
    jr z, @-$7e

    ld bc, $1014
    ld [bc], a
    nop
    nop
    jr z, jr_003_7216

    ld bc, $1614
    ld a, [hl+]
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_72a6:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$0000], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add e
    inc d
    stop
    nop
    ld [$8028], sp
    add a
    nop
    stop
    nop
    ld [$4700], sp
    adc e
    inc b
    stop
    nop
    ld [$0900], sp
    xor e
    ld b, h
    stop
    nop
    add hl, bc
    nop
    nop
    add e
    inc b
    inc d
    nop
    nop
    ld bc, $6320
    add e
    inc b
    add b
    nop
    nop
    jr nz, jr_003_7347

    pop hl
    add e
    inc h
    sub b
    jr nz, jr_003_7323

jr_003_7323:
    nop
    jr z, jr_003_72a6

    add e
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_734d

    pop af
    add e
    inc b
    inc b

jr_003_7331:
    nop
    nop
    jr nz, jr_003_7355

    pop bc
    add e
    inc e
    inc b
    nop
    nop
    jr nz, jr_003_7361

    ld c, c
    and e
    inc h
    inc b
    nop
    nop
    jr nz, jr_003_7366

    pop hl
    add a

jr_003_7347:
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_736e

jr_003_734d:
    pop de
    adc e
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_7376

jr_003_7355:
    pop de
    sub c
    inc b
    inc d
    nop
    add b
    jr nz, jr_003_737d

    pop hl
    add e
    inc b
    inc b

jr_003_7361:
    nop
    nop
    jr nz, jr_003_7389

    pop bc

jr_003_7366:
    add e
    inc b
    nop
    nop
    nop
    nop
    jr z, jr_003_7331

jr_003_736e:
    adc e
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_7397

    pop hl

jr_003_7376:
    and e
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_73b1

jr_003_737d:
    push bc
    sub e
    inc c
    inc b
    nop
    nop
    jr nz, jr_003_73b9

    pop bc
    add e
    inc c
    inc b

jr_003_7389:
    nop
    nop
    jr nz, jr_003_73af

    pop hl
    add e
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_73b5

    pop hl
    add e

jr_003_7397:
    inc c
    inc b
    nop
    add b
    jr nz, jr_003_73c1

    ret


    add e
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_73c8

    pop af
    add e
    inc b
    inc b
    nop
    nop
    jr nz, jr_003_73cd

    pop hl
    nop

jr_003_73af:
    nop
    nop

jr_003_73b1:
    nop
    nop
    nop
    nop

jr_003_73b5:
    nop
    nop
    nop
    nop

jr_003_73b9:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_73c1:
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_73c8:
    nop
    nop
    nop
    nop
    nop

jr_003_73cd:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $cb03
    inc bc
    pop bc
    ld b, h
    ret nz

    inc bc
    ret nz

    pop bc
    ret nc

    ret nc

    pop bc
    call nz, $c3d3
    inc b
    ret nz

    push bc
    inc bc
    ldh [c], a
    ret z

Call_003_7418:
    jp Jump_000_0383


    ld b, h
    ld b, b
    ld b, a
    sub e
    ret nz

    and e
    nop
    dec b
    rst RST_00

jr_003_7424:
    inc bc
    db $e3
    nop
    add b
    nop
    rlc b
    nop
    inc bc
    nop
    pop bc
    inc bc
    rlca
    add b
    nop
    ret z

    inc bc
    ret nz

    ld h, b
    nop
    ret nz

    jr nz, jr_003_743b

jr_003_743b:
    ld a, [bc]
    ld [hl+], a
    inc hl
    jp $0108


    jr jr_003_7443

jr_003_7443:
    ld [bc], a
    nop
    ld b, h
    ld bc, $e380
    ret nz

    jp $0180


    nop
    ld b, e
    nop
    ret nz

    dec de
    rlca
    call nz, $c701
    db $eb
    ld b, b
    dec b
    ret nz

    jp Jump_000_22c0


    bit 0, b
    add $e2
    rlca
    jr nz, jr_003_7424

    jp z, Jump_000_0246

    inc b
    ldh [rNR10], a
    nop

jr_003_746b:
    jp nz, Jump_000_1b00

    dec bc
    inc b
    db $10
    ld d, a
    nop
    ld b, h
    ld b, b
    add b
    inc hl
    inc b
    ret nz

    nop
    nop
    call nz, Call_000_0001
    inc de
    ld b, h
    ret


    nop
    ld b, b
    rrc a
    nop
    ld [bc], a
    ret nz

    ret nz

    inc bc
    inc de
    ld b, b
    ld [bc], a
    ret nz

    ld [hl+], a
    nop
    ld b, e
    inc bc
    nop
    ldh [$ffa2], a
    nop
    ret nz

    nop
    inc de
    inc bc
    ld [hl+], a
    inc de
    dec b
    ret z

    add e
    nop
    pop bc
    ret nz

jr_003_74a2:
    add b
    and e
    dec b
    jp Jump_000_0001


    inc de
    jr nz, jr_003_746b

    ld d, a
    call nz, $c9c4
    and b
    and d
    ld b, c
    ld [bc], a
    inc bc
    ld b, b
    ld b, [hl]
    inc hl
    ret nz

    dec de
    ld [bc], a
    ld [hl+], a
    inc bc
    add e
    nop
    ld h, e
    call nz, Call_000_0041
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_74ee:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_74fa:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0108
    ld [$0021], sp
    add h
    inc b
    ld b, b
    ld b, c
    jr nz, jr_003_74a2

    inc bc
    nop
    jr nz, @-$76

    nop
    ld [de], a
    jr nz, jr_003_7533

    ld [bc], a
    nop
    jr jr_003_74ee

    ld bc, $2000
    ld [bc], a
    inc b

jr_003_7533:
    db $10
    inc b
    ld bc, $2000
    add h
    inc b
    nop
    add d
    inc b
    ld [$0200], sp
    dec b
    add hl, bc
    inc bc
    jr nz, jr_003_7545

jr_003_7545:
    add d
    nop
    nop
    inc c
    add b
    ld b, b
    ld bc, $0004
    nop
    inc b
    nop
    ld [$0003], sp
    ld bc, $0000
    inc b
    inc bc
    ld [bc], a
    ld bc, $2080
    db $10
    add h
    ret nz

    ld hl, $4108
    ld bc, $0011
    nop
    nop
    ld de, $0008
    ld bc, $0100
    ret nz

    inc bc
    inc b
    inc b
    and b
    inc b
    jr nz, jr_003_757a

    jr nz, jr_003_74fa

    add b
    inc b

jr_003_757a:
    and b
    nop
    ld b, b
    nop
    nop
    inc d
    nop
    nop
    ld bc, $0000
    nop
    nop
    nop
    ld b, b
    adc b
    nop
    nop
    add h
    add b
    nop
    nop
    ld bc, $0040
    ld [bc], a
    ld bc, $4100
    ld [$0200], sp
    and b
    ld d, b
    jr nz, jr_003_75ee

    nop
    add b
    ld bc, $0030
    ld bc, $4021
    nop
    nop
    inc b
    ld bc, $0010
    nop
    ld d, b
    nop
    nop
    stop
    inc bc
    nop
    dec b
    db $10
    inc b
    inc b
    nop
    jr nc, jr_003_75bc

    add hl, bc

jr_003_75bc:
    nop
    nop
    stop
    ld [bc], a
    jr nz, @+$03

    jr nz, @+$04

    ld hl, $0882
    jr nz, @+$04

    ld b, b
    stop
    inc bc
    nop
    ld [bc], a
    add d
    inc bc
    jr nz, jr_003_75d4

jr_003_75d4:
    ld hl, $0041
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_75ee:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$0000], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    ld a, [bc]
    adc d
    inc e
    dec b
    jr jr_003_7676

    add b
    ldh a, [$ffc1]
    add [hl]
    ld e, h
    jr z, jr_003_7659

    add e
    ld c, h
    or b
    ret nz

    ld b, b
    rra
    ld [hl], b
    pop de
    ld b, h
    ld l, b
    db $10
    ld bc, $1c80
    nop
    and e
    adc d
    ld c, l
    ldh [rLY], a
    jr nc, jr_003_768a

    sub b
    jr nz, jr_003_7665

    ld c, $10
    ld b, c
    ld a, [bc]
    ld [$0108], sp
    ret nz

jr_003_7659:
    inc e
    sub b
    add hl, bc
    inc d
    ld de, $74c8
    dec b
    ld [$0970], sp
    nop

jr_003_7665:
    nop
    nop
    nop
    rrca
    ld e, h
    ld c, b
    inc bc
    add $00
    ld [bc], a
    dec hl
    rst RST_00
    add b
    sub b
    pop hl
    ld e, $08

jr_003_7676:
    or b
    push hl
    call nz, Call_003_4018
    and e
    add h
    cp l
    jr z, jr_003_76f0

    ld d, h
    adc b
    sub b
    and l
    pop bc
    ld e, $28
    db $10
    inc hl
    ld c, a

jr_003_768a:
    ld sp, $0008
    add b
    nop
    db $10
    ld d, h
    ld [$cb10], sp
    add b
    nop
    inc c
    ld bc, $0dcf
    ret nz

    pop af
    add [hl]
    nop
    jr c, @+$13

    jp nc, Jump_000_1802

    inc bc
    adc d
    dec c
    inc [hl]
    ld [de], a
    ld b, b
    ld c, h
    ld b, b
    jr nz, @+$22

    ld h, b
    add hl, bc
    ld bc, $1dca
    jr c, jr_003_76fa

    ld [$0000], sp
    dec b
    call nc, $9000
    inc hl
    add [hl]
    inc e
    nop
    inc b
    adc b
    sbc b
    sub b
    and b
    ld b, $14
    ld sp, $2502
    ld b, d
    jr nc, @+$05

    adc $00
    jr nc, jr_003_7739

    sub a
    ld bc, $c900
    adc [hl]
    nop
    jr c, jr_003_76e9

    ld e, h
    or [hl]
    ld l, b
    xor d
    add b
    nop
    nop
    ld [hl], l
    rst RST_08
    inc c
    ld [hl], b
    ldh [c], a
    ld c, $01
    nop
    inc c
    inc c

jr_003_76e9:
    ld e, l
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_76f0:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_76fa:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$0000], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7721:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7739:
    nop
    nop
    nop
    nop
    nop
    db $10
    ld bc, $40c0
    inc a
    add d
    inc d
    db $10
    ld h, b
    pop bc
    ld [hl], $1c
    ld b, h
    ld [hl], l
    push bc
    dec l
    jr nc, jr_003_7750

jr_003_7750:
    ld b, b
    inc d
    ld bc, $030b

jr_003_7755:
    adc b
    inc d
    nop
    ld [hl], b
    ld [de], a
    db $10
    ret nz

    ld [bc], a
    nop
    jr nc, jr_003_7721

    jp $803c


    ld a, [de]
    nop
    pop hl
    ld sp, $e8b1
    ld a, [hl+]
    ld [hl], c
    inc b
    add l
    inc c
    ld l, b
    pop hl
    add b
    add hl, bc
    jr nc, jr_003_77ad

    sub a
    dec c
    nop
    ld a, [bc]
    inc b
    adc h
    ld b, b
    db $e4
    jp Jump_000_0400


    nop
    pop bc
    ld d, b
    ld sp, $0226
    ld [$c190], sp
    ldh a, [rP1]
    add b
    ld h, c
    rrc [hl]
    or h
    xor c
    ld h, $4c
    jr z, jr_003_7755

    add d
    xor b
    ld a, b
    ld bc, $8084
    ld bc, $0473
    ld d, $04
    and b
    ld b, e
    nop
    ld [bc], a
    ld hl, $0dc0
    nop
    ld a, [bc]
    inc b

jr_003_77a9:
    add b
    ld [$2300], sp

jr_003_77ad:
    ld c, b
    nop
    ldh a, [c]
    ld h, [hl]
    ld c, b
    jr z, jr_003_7824

    rst RST_08
    and a
    jr nc, jr_003_77b8

jr_003_77b8:
    call nz, Call_000_0202
    jp $a000


    jr nc, jr_003_77cb

    inc b
    ld [$8140], sp
    and e
    inc c
    ld b, [hl]
    ld b, e
    nop
    ld b, b
    inc b

jr_003_77cb:
    ld h, b
    inc de
    inc c
    ld a, [de]
    pop bc
    and $f1
    ld c, [hl]
    add d
    ld h, h
    ld b, $10
    pop de
    call z, Call_003_4880
    ret nz

    sub l
    inc c
    add h
    jr jr_003_77a9

    nop
    cp b
    add c
    add b
    ld b, $00
    and b
    inc e
    sub b
    ld c, $00
    add b
    inc c
    inc b
    pop bc
    rlca
    cp h
    nop
    push bc
    jp nz, $8528

    pop af
    xor a
    sbc h
    jr nc, jr_003_7860

    add l
    inc c
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7824:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld b, [hl]
    nop
    pop bc
    xor h
    jr nz, jr_003_785d

    nop
    ld [bc], a
    dec h
    ld l, b
    ld [bc], a

jr_003_785d:
    adc b
    nop
    db $10

jr_003_7860:
    ld bc, $0600
    sub b
    ld [hl], h

jr_003_7865:
    inc b
    nop
    inc c
    nop
    inc b
    rlca
    ld b, b
    nop
    ld [hl+], a
    ld [$0018], sp
    inc h
    ld d, $8b
    ld bc, $0000
    jr jr_003_7879

jr_003_7879:
    nop
    jr c, jr_003_787c

jr_003_787c:
    sub b
    ret nz

    ld b, b
    ld l, c
    ld de, $8002
    ld [$4081], sp
    nop
    inc l
    jr jr_003_789a

    jr nc, @+$0a

    ld bc, $4142
    jr nz, jr_003_7891

jr_003_7891:
    jr nz, jr_003_7897

    ld [$a230], sp
    nop

jr_003_7897:
    nop
    inc b
    ld d, b

jr_003_789a:
    inc b
    jr z, jr_003_789d

jr_003_789d:
    ld c, b
    ld b, $06
    inc b
    ld [bc], a
    sub b
    dec de
    nop
    ld bc, $5318
    nop
    inc l
    ld bc, $0066
    jr nz, jr_003_78c3

    nop
    inc bc
    nop
    add d
    inc b
    nop
    inc [hl]
    ld hl, $0100
    add d
    inc bc
    ld [$0410], sp
    ld [$0013], sp
    inc b
    and b

jr_003_78c3:
    db $10
    db $10
    ldh [c], a
    ld d, b
    ld [de], a
    nop
    nop
    ld [$bb00], sp
    nop
    nop
    inc d
    nop
    inc b
    ldh [rP1], a
    ld [hl+], a
    ld b, b
    add b
    ld b, c
    ld [de], a
    nop
    nop
    jr nz, jr_003_78de

    nop

jr_003_78de:
    nop
    inc bc
    jr jr_003_7865

    add b
    add b
    add h
    nop
    ld b, $08
    nop
    db $10
    ld hl, $a420
    ld [$0040], sp
    ld b, b
    ld b, $80
    ld b, b
    jr nz, jr_003_78ff

    dec bc
    nop
    call nc, Call_003_4000
    jr z, jr_003_78fd

jr_003_78fd:
    ld c, d
    db $10

jr_003_78ff:
    ld bc, $0120
    nop
    adc c
    ld [bc], a
    nop
    ld [bc], a
    ld b, b
    db $10
    inc c
    inc b
    ld b, c
    ld bc, $4060
    add b
    ret nz

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld c, d
    inc c
    ld b, [hl]
    inc c
    ld sp, $ace8
    ld d, $70
    jp Jump_000_0226


    ld [hl], h
    rlca
    ret nz

    cpl
    ld c, b
    jr nc, jr_003_79bf

    ld c, h
    inc d
    add hl, bc
    add b
    inc e
    ld b, b
    ld d, l
    add b
    add hl, bc
    jr c, jr_003_7985

    ret nz

jr_003_7985:
    inc e
    nop
    jp hl


    rlca
    adc h
    ld a, [bc]
    ld [hl+], a
    ld [bc], a
    add hl, bc
    db $10
    jr c, jr_003_7998

    inc d
    add h
    ldh [c], a
    ld [de], a
    ld d, $b1
    ld [de], a

jr_003_7998:
    pop bc
    ld de, $ca34
    dec b
    ld d, [hl]
    ld bc, $4610
    nop
    add b
    inc bc
    ld b, b
    inc e
    ld [$c619], sp
    add d
    inc a
    ld h, e
    add b
    adc [hl]
    ld a, c
    jp Jump_000_3606


    cp b
    sub c
    and b
    inc e
    ld h, b
    inc [hl]
    ld b, h
    ld c, h
    sub d
    add $12
    ld b, $00

jr_003_79bf:
    dec b
    ret


    nop
    ld [$4516], sp
    ld [$0441], sp
    ld b, e
    ld c, h
    inc c
    ld [$0000], sp
    nop
    jp hl


    sub [hl]
    jr z, jr_003_79d4

    add b

jr_003_79d4:
    and l
    inc a
    jr nc, jr_003_7a19

    add a
    ld d, b
    ld [bc], a
    ld h, e
    inc bc
    jr nz, jr_003_7a0f

    ret nz

    rlca
    nop
    nop
    ld bc, $16f0
    ld h, b
    and b
    ldh [$ff71], a
    jr z, jr_003_79f4

    inc l
    dec l
    add b
    ld bc, $0034
    ld b, b
    ld h, l

jr_003_79f4:
    add h
    ld b, b
    jr c, jr_003_7a43

    jr nz, jr_003_7a46

    ld [hl], b
    jp Jump_000_2cdc


    nop
    jp z, Jump_000_0de6

    ld b, c
    daa
    adc h
    rrca
    add d
    ld b, $40
    ld d, b
    jr nc, jr_003_7a6f

Jump_003_7a0c:
    add d
    ld b, $74

jr_003_7a0f:
    ld b, h
    db $10
    ld e, l
    ld [bc], a
    inc bc
    nop
    inc c
    sub l
    push hl
    add [hl]

jr_003_7a19:
    ld [bc], a
    ld [bc], a
    ld l, h
    add a
    inc c
    nop
    ldh [c], a
    ld h, b
    dec e
    nop
    ld b, $08
    ld [hl-], a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7a43:
    nop
    nop
    nop

jr_003_7a46:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7a5e:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7a6f:
    nop
    nop
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
    ld [bc], a
    nop
    sub b
    or b
    ret nc

    adc a
    ld h, $31
    pop bc
    ld d, $9c
    jr nc, jr_003_7a89

    ret nz

jr_003_7a89:
    ld c, $40
    jp nz, Jump_003_4804

    ld [hl], b

jr_003_7a8f:
    ld bc, $2280
    ld h, b
    ld bc, $9cd6
    ld l, $01
    add b
    ld [$e412], sp
    inc b
    dec [hl]
    ld [bc], a
    ld b, $0a
    ld c, c
    sub b
    ld bc, $40c1
    nop
    ld l, e
    add d
    ld c, c
    ld h, b
    ld c, d
    add h
    ld b, b
    ld c, b
    jr z, jr_003_7af8

    rlca
    ld [hl], b
    ld c, c
    jp z, Jump_000_2800

    ld bc, $00db
    ld b, b
    jr nz, jr_003_7ad3

    inc d
    nop
    ld b, $14
    jr c, jr_003_7b35

    ret


    add c
    inc e
    db $10
    ld de, $a84b
    jr nc, jr_003_7a8f

    and h
    ld a, [bc]
    inc bc
    ld h, b
    dec b
    adc b
    add b

jr_003_7ad3:
    db $e3
    xor b
    jr nz, jr_003_7ad7

jr_003_7ad7:
    jr nz, jr_003_7a5e

    ld a, h
    jr c, jr_003_7afc

    ld h, $0c
    jr c, jr_003_7ae0

jr_003_7ae0:
    ld a, [hl+]
    ld bc, $e271
    dec b
    add b
    nop
    nop
    ld a, [bc]
    ld c, b
    ld a, [bc]
    ld b, b
    ld c, b
    nop
    dec [hl]
    ld d, b
    db $10
    sbc h
    cp d
    ret nc

    jr nz, @+$36

    inc d
    nop

jr_003_7af8:
    ld b, b
    jr z, @+$04

    or d

jr_003_7afc:
    add $00
    inc d
    add b
    ld b, e
    inc c
    ld h, d
    ld d, d
    add [hl]
    adc [hl]
    jr z, jr_003_7b0c

    ld b, l
    inc c
    ld [hl], d
    ldh [c], a

jr_003_7b0c:
    adc b
    ld c, [hl]
    db $10
    and c
    add b
    db $10
    ld h, d
    ld [bc], a
    add a
    ld d, b
    jr z, jr_003_7b19

    adc e

jr_003_7b19:
    dec c
    ld h, b
    and d
    ld b, $16
    cp h
    jr jr_003_7b7b

    ld b, c
    ld [bc], a
    db $d3
    adc [hl]
    ld b, b
    nop
    inc bc
    sub b
    ld d, $62
    ld b, d
    rst RST_20
    db $10
    add b
    ld d, b
    nop
    add c
    ld bc, $8ee2

jr_003_7b35:
    inc d
    cp h
    jr nz, jr_003_7b44

    ld [$0000], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7b44:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7b54:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_003_7b68

jr_003_7b68:
    ld d, b
    ld [bc], a
    ld [de], a
    ld [de], a
    ld hl, $0082
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7b7b:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7b86:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add hl, hl
    ld d, h
    nop
    ld a, [bc]
    sub b
    ld b, c
    ld a, [hl+]
    ld e, c
    nop
    ld hl, $0829
    inc h
    jr nc, @+$13

    jr c, jr_003_7bca

    ld bc, $2241
    ld b, h
    inc h
    inc l
    ld bc, $2080
    ld c, b
    ld [hl+], a
    ld b, b
    inc [hl]
    add h
    jr nz, @+$26

    nop
    ld [hl+], a
    add b
    adc b
    ld hl, $8180
    inc h
    ld b, b
    ld b, c
    ld b, d
    ld b, b
    ld b, c
    sbc d
    ld bc, $884c
    inc b
    nop
    ld a, [bc]
    jr z, jr_003_7c0a

    sub b
    add d
    add b
    ld b, c

jr_003_7bca:
    nop

jr_003_7bcb:
    add b
    inc c
    ld a, [hl-]
    ld e, b
    jr nz, jr_003_7c12

    jr nz, jr_003_7b54

    ld bc, $4240
    ld hl, $8224
    add c
    sub b
    add b
    jr z, jr_003_7c2a

    jr nz, jr_003_7c28

    jr nz, jr_003_7c26

    jr jr_003_7c04

    jr nz, jr_003_7c26

    add c
    inc h
    inc e
    ld [hl+], a
    add b
    ld b, b
    ld a, [de]
    sub b
    ld b, d
    ld b, h
    ld d, b
    inc h
    ld [$015a], sp
    ld b, c
    ld hl, $0491
    inc b
    add d
    ld e, d
    add d
    nop
    ld b, c
    inc b
    jr c, jr_003_7b86

    add d
    ld d, h

jr_003_7c04:
    ld [bc], a
    ld [hl+], a
    jr nz, jr_003_7c14

    inc h
    inc [hl]

jr_003_7c0a:
    ld b, h
    ld hl, $4c01
    inc h
    ld [hl+], a
    add b
    inc l

jr_003_7c12:
    inc h
    ld b, d

jr_003_7c14:
    ld [bc], a
    jr nc, jr_003_7c3b

    inc c
    ld [bc], a
    ld hl, $0102
    ld [de], a
    ld bc, $4182
    nop
    jr z, jr_003_7c23

jr_003_7c23:
    add c
    jr nz, jr_003_7c26

jr_003_7c26:
    nop
    ld b, b

jr_003_7c28:
    jr @+$22

jr_003_7c2a:
    add d
    ld b, b
    ld [hl+], a
    ld [hl+], a
    ld [bc], a
    inc [hl]
    ld hl, $0100
    jr nz, jr_003_7c35

jr_003_7c35:
    jr z, jr_003_7c37

jr_003_7c37:
    nop
    ld [bc], a
    add hl, hl
    ld a, [hl+]

jr_003_7c3b:
    jr nc, jr_003_7c5f

    jr nz, jr_003_7bcb

    ld b, b
    nop
    db $10
    ld [bc], a
    ld b, b
    ld a, [hl-]
    ld [bc], a
    ld d, b
    inc b
    sub h
    jr nc, jr_003_7bcb

    ld [hl+], a
    jr nz, jr_003_7c70

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7c5f:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr z, jr_003_7cb0

jr_003_7c70:
    add h
    nop
    ld b, b
    ld b, b
    nop
    ld b, b
    nop
    nop
    nop
    nop
    db $10
    or b
    inc d
    jr nz, jr_003_7caf

    stop
    or b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr nz, @-$66

    db $10
    or b
    cp h
    jr nz, jr_003_7cd9

    or h
    inc d
    ld [$0030], sp
    inc b

jr_003_7caf:
    ld e, [hl]

jr_003_7cb0:
    ld l, $1e
    ld [$6a14], sp
    ld b, b
    dec c
    ld h, b
    ld b, $78
    ld [hl], $90
    sub [hl]
    jr @+$32

    ld d, b
    jr nz, @-$40

    ld c, $0d
    ld d, b
    jr nc, jr_003_7d01

    ld [$0e10], sp
    ld [hl], b
    sbc h
    db $10
    ld c, l
    add hl, bc
    ld a, [hl+]
    nop
    inc a
    inc l
    ld d, h
    jr z, jr_003_7cf6

    add hl, bc
    ld l, h
    sbc h

jr_003_7cd9:
    ld a, [hl+]
    dec l
    add hl, hl

jr_003_7cdc:
    ld l, $2d
    and b
    inc l
    db $10
    jr jr_003_7cf3

    cp d
    ld e, [hl]
    ld a, [bc]
    xor c
    jr z, jr_003_7cf3

    add hl, hl
    ld l, d
    sbc d
    add hl, hl
    and b
    ld c, $10
    inc h
    inc l
    dec h

jr_003_7cf3:
    inc h
    ld a, [hl+]
    sbc b

jr_003_7cf6:
    inc l
    ld [hl], l
    db $10
    dec l
    ld c, d
    ld a, [de]
    jr z, jr_003_7d28

    jr nc, jr_003_7d2d

    inc b

jr_003_7d01:
    ld l, $5e
    inc h
    ld [bc], a
    ld b, b
    ld [$9428], sp
    jr @+$0c

jr_003_7d0b:
    add hl, hl
    ld a, [bc]
    ld a, l
    inc b
    inc d
    ld d, l
    or b
    nop
    ld h, [hl]
    jr nz, jr_003_7d72

    ld c, $1d
    ld a, [hl-]
    cp d
    nop
    sbc b
    ld a, c
    ld a, [bc]
    dec c
    or b
    ld a, [de]
    ld d, b
    ld a, l
    sbc l
    ld h, b
    ld e, b
    nop
    ld d, h

jr_003_7d28:
    nop
    ld a, [hl-]
    jr nc, jr_003_7d80

    inc b

jr_003_7d2d:
    ld [hl], b
    ld a, [hl]
    ld a, h
    jr z, jr_003_7cdc

    ld a, c
    ld a, $09
    inc a
    and b
    and b
    sub l
    sbc d
    ld c, $ae
    jr z, jr_003_7d7a

    and b
    sbc b
    xor d
    xor c
    ld l, d
    dec c
    nop
    or b
    sbc d
    ld a, l
    ld l, $08
    ld a, [hl-]
    nop
    xor [hl]
    ld c, h
    jr z, jr_003_7d74

    ld [$28a0], sp
    ld l, l
    and b
    db $10
    sub b
    ld d, b
    jr z, jr_003_7d87

    nop
    cp d
    ld a, [de]
    jr nc, jr_003_7d0b

    ld d, h
    ld l, $00
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7d72:
    nop
    nop

jr_003_7d74:
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7d7a:
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7d80:
    nop
    nop
    inc c
    dec b
    ld [hl], l

jr_003_7d85:
    ld e, b
    nop

jr_003_7d87:
    jr nc, jr_003_7d93

    jr nc, jr_003_7d8b

jr_003_7d8b:
    nop
    ld [$9000], sp
    ld a, [bc]
    ld de, $7c8c

jr_003_7d93:
    inc c
    ld [$001c], sp

jr_003_7d97:
    nop
    nop
    nop
    nop

jr_003_7d9b:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add b
    inc c
    inc d
    ld b, b
    inc c
    db $10
    add h
    jr z, jr_003_7ddb

    ld e, e

jr_003_7dc0:
    xor b
    inc l
    ld b, $24
    ld c, $68
    ld c, $a8
    ld a, b
    jr jr_003_7dd3

    inc [hl]
    inc l
    jr nz, jr_003_7d9b

    ld a, [hl-]
    ld a, [hl-]
    sub [hl]
    sub b

jr_003_7dd3:
    ld [hl-], a
    ld [$103c], sp
    jr c, jr_003_7de3

    sub h
    sub b

jr_003_7ddb:
    ld a, $98
    jr nc, jr_003_7e17

    ld hl, $1c91
    db $10

jr_003_7de3:
    sub d
    inc [hl]
    jr jr_003_7dc0

    jr z, jr_003_7d97

    ret c

    ld d, b
    ld h, b
    db $10
    or b
    ld e, $8c
    or b
    cp h

jr_003_7df2:
    ld [hl], b
    cp a
    add sp, $3c
    jr nc, jr_003_7e28

    jr jr_003_7e14

    jr c, jr_003_7d85

jr_003_7dfc:
    ld [hl-], a
    sbc b
    inc a
    ld [$08ac], sp
    db $10
    cp d
    and b
    cp b
    add b
    or b
    or b
    ld sp, $120a
    add b
    and b
    inc a
    cp h
    ld l, h
    and b
    or b
    or b

jr_003_7e14:
    inc c
    jr nz, jr_003_7e27

jr_003_7e17:
    or c
    ld e, $14
    halt
    jr jr_003_7e96

    xor c
    inc a
    inc [hl]
    ld a, h
    nop
    ld sp, $1c3c
    ld [hl], d
    inc l

jr_003_7e27:
    ld h, b

jr_003_7e28:
    ld d, $31
    jr z, jr_003_7e34

    ret c

    inc c
    db $10
    ld [$181c], sp
    sub h
    inc l

jr_003_7e34:
    call c, Call_000_3814
    inc c
    db $10
    inc l
    jr c, jr_003_7e41

    ld c, h
    db $10
    or h
    ld d, h
    ld c, l

jr_003_7e41:
    inc b
    ld e, b
    ld c, l
    ld a, c
    ld a, h
    jr jr_003_7dfc

    ld h, b
    sbc d
    nop
    inc [hl]
    nop
    nop
    ld a, [bc]
    jr nc, jr_003_7e51

jr_003_7e51:
    or c
    jr c, jr_003_7e8f

    inc d
    jr jr_003_7ebf

    inc b
    ld [$0806], sp
    nop
    ldh [rNR10], a
    ld a, [$6000]
    inc e
    sub b
    dec de
    add hl, de
    ld h, $bc
    ld h, $5e
    nop
    ld l, b
    db $10
    jr c, jr_003_7df2

    jr nc, @+$66

    jr jr_003_7e72

jr_003_7e72:
    ld sp, $b011
    inc d
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7e8f:
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7e96:
    db $10
    jr nc, jr_003_7ea9

    ld bc, $b030
    nop
    or b
    nop
    nop
    ld [$4000], sp
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7ea9:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7ebf:
    nop
    nop
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
    inc h
    ld [bc], a
    nop
    nop
    jr nz, jr_003_7ef1

    adc b
    ld b, d
    jr nz, jr_003_7f17

    inc h
    nop
    nop
    ld [bc], a
    inc h
    ld [bc], a
    nop
    ld b, h
    ld b, h
    ld [bc], a
    ld b, b
    ld [bc], a
    nop
    add c
    nop
    dec b
    nop
    ld b, d
    nop
    inc b
    nop
    ld b, l
    ld hl, $2040
    inc b
    inc b
    add b

jr_003_7ef1:
    nop
    ld [$000e], sp
    jr nz, jr_003_7ef9

    inc b
    ld [bc], a

jr_003_7ef9:
    inc l
    add b
    inc b
    add b
    dec b
    ld [hl+], a
    nop
    nop
    inc b
    dec c
    inc b
    ld a, [hl+]
    jr nz, jr_003_7f47

    nop
    ld [bc], a
    nop
    add c
    jr nz, jr_003_7f4d

    nop
    adc b
    ld [hl-], a
    add b
    ld b, b
    dec b
    and h
    ld b, d
    ld e, $40

jr_003_7f17:
    ld bc, $3880
    ld b, $30
    add b
    nop
    ld b, b
    jr nc, jr_003_7f71

    inc l
    add b
    jr nz, @+$2e

    inc b
    ld b, b
    ld c, $42
    nop
    inc l
    jr nz, jr_003_7f6d

    inc a
    ld [de], a
    ld [bc], a
    sub d
    inc a
    add d
    jr nz, jr_003_7f9d

    nop
    ld b, c
    inc b
    ld bc, $0020
    ld b, $20
    ld [$7001], sp
    ld b, h
    nop
    ld b, [hl]
    xor h
    ld bc, $8000

jr_003_7f47:
    inc b
    ld bc, $8421
    inc c
    ld b, b

jr_003_7f4d:
    nop
    nop
    ld bc, $8001
    nop
    add h
    ld b, b
    inc a
    nop
    nop
    ld bc, $0608
    inc c
    ld c, l
    and b
    ld [$4600], sp
    ld b, b
    inc [hl]
    nop
    ld b, b
    jr nz, jr_003_7f67

jr_003_7f67:
    nop
    add b
    ld b, c
    ld b, [hl]
    ld b, d
    nop

jr_003_7f6d:
    nop
    ld b, l
    nop
    nop

jr_003_7f71:
    nop
    ld c, $40
    add d
    ld b, b
    ld c, d
    nop
    jr nz, jr_003_7fba

    ld [$4020], sp
    jr nc, jr_003_7fbf

    nop
    nop
    nop
    add b
    jr nz, jr_003_7f85

jr_003_7f85:
    and b
    nop
    ld [hl+], a
    nop
    jr nz, jr_003_7f8b

jr_003_7f8b:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7f9d:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr nc, jr_003_7fcc

    nop
    nop
    inc c
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7fba:
    nop
    nop
    ld [$0000], sp

jr_003_7fbf:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_003_7fcc:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [bc], a
    inc b
    nop
    nop
    nop
    nop
    ld hl, $8008
    add b
    ld [bc], a
    stop
    inc b
    ld [bc], a
    ld b, [hl]
    nop
    add c
    jr nz, jr_003_7ff3

jr_003_7ff3:
    nop
    inc b
    nop
    ld l, h
    nop
    add b
    nop
    jr nz, @+$23

    nop
    nop
    dec e
    adc b
