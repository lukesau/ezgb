; Disassembly of "kernel.gb"
; This file was created with:
; mgbdis v3.0 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $001", ROMX[$4000], BANK[$1]

    push af
    push af
    ld hl, sp+$0a
    ld c, [hl]
    inc hl
    ld b, [hl]

Jump_001_4007:
    ld a, [bc]
    or a
    jp z, Jump_001_4010

    inc bc
    jp Jump_001_4007


Jump_001_4010:
    ld hl, sp+$0c
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    inc hl
    ld [hl], c
    inc hl
    ld [hl], b

Jump_001_401c:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    or a
    jp z, Jump_001_403d

    ld a, c
    dec hl
    inc [hl]
    jr nz, jr_001_402e

    inc hl
    inc [hl]

jr_001_402e:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_001_403a

    inc hl
    inc [hl]

jr_001_403a:
    jp Jump_001_401c


Jump_001_403d:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    add sp, $04
    ret


    push af
    push af
    ld hl, sp+$0a
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc hl
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], e

Jump_001_4056:
    ld a, [bc]
    ld hl, sp+$01
    ld [hl+], a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$00
    ld [hl+], a
    ld a, [hl]
    dec hl
    sub [hl]
    jp nz, Jump_001_4069

    jr jr_001_406c

Jump_001_4069:
    jp Jump_001_4084


jr_001_406c:
    xor a
    ld hl, sp+$01
    or [hl]
    jp nz, Jump_001_4079

    ld de, $0000
    jp Jump_001_40a0


Jump_001_4079:
    inc bc
    ld hl, sp+$02
    inc [hl]
    jr nz, jr_001_4081

    inc hl
    inc [hl]

jr_001_4081:
    jp Jump_001_4056


Jump_001_4084:
    ld hl, sp+$01
    ld a, [hl+]
    ld [hl-], a
    ld a, [hl]
    rla
    sbc a
    inc hl
    inc hl
    ld [hl], a
    ld hl, sp+$00
    ld c, [hl]
    ld a, [hl]
    rla
    sbc a
    ld b, a
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    sub c
    ld e, a
    ld a, d
    sbc b
    ld d, a

Jump_001_40a0:
    add sp, $04
    ret


    push af
    dec sp
    ld hl, sp+$01
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$09
    ld a, [hl+]
    or [hl]
    jp nz, Jump_001_40b9

    ld de, $0000
    jp Jump_001_40e0


Jump_001_40b9:
    ld hl, sp+$09
    ld c, [hl]
    inc hl
    ld b, [hl]

Jump_001_40be:
    ld a, [bc]
    ld hl, sp+$00
    ld [hl], a
    or a
    jp z, Jump_001_40db

    ld a, [hl]
    ld hl, sp+$0b
    sub [hl]
    jp nz, Jump_001_40cf

    jr jr_001_40d2

Jump_001_40cf:
    jp Jump_001_40d7


jr_001_40d2:
    ld hl, sp+$01
    ld [hl], c
    inc hl
    ld [hl], b

Jump_001_40d7:
    inc bc
    jp Jump_001_40be


Jump_001_40db:
    ld hl, sp+$01
    ld e, [hl]
    inc hl
    ld d, [hl]

Jump_001_40e0:
    add sp, $03
    ret


    add sp, -$20
    ld hl, sp+$26
    ld d, h
    ld e, l
    ld hl, $c2a2
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp c, Jump_001_40ff

    ld hl, sp+$1e
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp Jump_001_412c


Jump_001_40ff:
    ld hl, $c2a2
    ld hl, $c2a2
    ld e, [hl]
    ld hl, $c2a3
    ld d, [hl]
    ld hl, sp+$26
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
    ld hl, sp+$1e
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, $10
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp nc, Jump_001_412c

    dec hl
    ld [hl], $10
    inc hl
    ld [hl], $00

Jump_001_412c:
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, sp+$1d
    ld [hl], $00

Jump_001_413d:
    ld hl, sp+$1d
    ld c, [hl]
    ld b, $00
    ld a, c
    inc hl
    sub [hl]
    ld a, b
    inc hl
    sbc [hl]
    jp nc, Jump_001_4266

    ld a, c
    ld hl, sp+$28
    sub [hl]
    jp nz, Jump_001_415a

    ld a, b
    inc hl
    sub [hl]
    jp nz, Jump_001_415a

    jr jr_001_415d

Jump_001_415a:
    jp Jump_001_416a


jr_001_415d:
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03

Jump_001_416a:
    ld hl, sp+$1d
    ld c, [hl]
    ld b, $00
    ld hl, sp+$26
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, $05

jr_001_4181:
    srl b
    rr c
    dec a
    jr nz, jr_001_4181

    ld hl, sp+$1b
    ld [hl], c
    ld hl, sp+$05
    ld a, [hl]
    and $1f
    ld c, a
    ld b, $00
    ld hl, sp+$1c
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
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$05
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
    jp nz, Jump_001_41da

    jr jr_001_41dd

Jump_001_41da:
    jp Jump_001_4229


jr_001_41dd:
    ld hl, sp+$1d
    ld a, [hl]
    add $02
    ld hl, sp+$04
    ld [hl], a
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, $0000
    push hl
    push bc
    call Call_000_08b7
    add sp, $05
    ld hl, $0003
    push hl
    ld a, $00
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, $1103
    push hl
    ld hl, $42b6
    push hl
    call Call_000_08b7
    add sp, $05
    jp Jump_001_4253


Jump_001_4229:
    ld hl, sp+$1d
    ld a, [hl]
    add $02
    ld hl, sp+$04
    ld [hl], a
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, $0014
    push hl
    push bc
    call Call_000_08b7
    add sp, $05

Jump_001_4253:
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, sp+$1d
    inc [hl]
    jp Jump_001_413d


Jump_001_4266:
    ld hl, sp+$07
    ld a, l
    ld d, h
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$26
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    inc bc
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld a, $0a
    push af
    inc sp
    inc hl
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
    call Call_000_16f4
    add sp, $07
    ld hl, sp+$07
    ld c, l
    ld b, h
    ld hl, $0010
    push hl
    ld a, $04
    push af
    inc sp
    push bc
    call Call_000_08b7
    add sp, $05
    add sp, $20
    ret


    ld b, h
    ld c, c
    ld d, d
    nop
    add sp, -$24
    ld hl, sp+$2e
    ld a, [hl]
    sub $02
    jp nz, Jump_001_42c8

    ld a, $01
    jr jr_001_42c9

Jump_001_42c8:
    xor a

jr_001_42c9:
    ld hl, sp+$07
    ld [hl], a
    or a
    jp z, Jump_001_42fb

    ld hl, sp+$2c
    ld b, [hl]
    ld a, b
    dec a
    ld hl, sp+$09
    ld [hl-], a
    ld [hl], b
    ld hl, sp+$2c
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec bc
    ld hl, $0002
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$22
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$2c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$20
    ld [hl+], a
    ld [hl], d
    jp Jump_001_4324


Jump_001_42fb:
    ld hl, sp+$2c
    ld c, [hl]
    ld hl, sp+$09
    ld [hl], c
    ld a, c
    inc a
    dec hl
    ld [hl], a
    ld hl, sp+$2c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$22
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$2c
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld hl, $0002
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$20
    ld [hl+], a
    ld [hl], d

Jump_001_4324:
    ld hl, sp+$09
    ld c, [hl]
    ld b, $00
    ld hl, sp+$2a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, $05

jr_001_433b:
    srl b
    rr c
    dec a
    jr nz, jr_001_433b

    ld hl, sp+$1e
    ld [hl], c
    ld hl, sp+$05
    ld a, [hl]
    and $1f
    ld c, a
    ld b, $00
    ld hl, sp+$1f
    ld [hl], c
    ld bc, $4000
    dec hl
    ld a, [hl]
    add $12
    ld [bc], a
    ld hl, sp+$2e
    ld a, [hl]
    sub $03
    jp nz, Jump_001_4364

    ld a, $01
    jr jr_001_4365

Jump_001_4364:
    xor a

jr_001_4365:
    ld hl, sp+$09
    ld [hl], a
    or a
    jp z, Jump_001_437c

    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    jp Jump_001_4390


Jump_001_437c:
    xor a
    ld hl, sp+$07
    or [hl]
    jp z, Jump_001_4390

    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03

Jump_001_4390:
    ld hl, sp+$1f
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
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$05
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
    jp nz, Jump_001_43cd

    jr jr_001_43d0

Jump_001_43cd:
    jp Jump_001_441a


jr_001_43d0:
    ld hl, sp+$22
    ld a, [hl]
    ld hl, sp+$04
    ld [hl], a
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, $0000
    push hl
    push bc
    call Call_000_08b7
    add sp, $05
    ld hl, $0003
    push hl
    ld a, $00
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, $1103
    push hl
    ld hl, $45af
    push hl
    call Call_000_08b7
    add sp, $05
    jp Jump_001_4442


Jump_001_441a:
    ld hl, sp+$22
    ld a, [hl]
    ld hl, sp+$04
    ld [hl], a
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, $0014
    push hl
    push bc
    call Call_000_08b7
    add sp, $05

Jump_001_4442:
    xor a
    ld hl, sp+$09
    or [hl]
    jp z, Jump_001_4459

    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    jp Jump_001_446d


Jump_001_4459:
    xor a
    ld hl, sp+$07
    or [hl]
    jp z, Jump_001_446d

    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03

Jump_001_446d:
    ld hl, sp+$08
    ld c, [hl]
    ld b, $00
    ld hl, sp+$2a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, $05

jr_001_4484:
    srl b
    rr c
    dec a
    jr nz, jr_001_4484

    ld hl, sp+$1e
    ld [hl], c
    ld hl, sp+$05
    ld a, [hl]
    and $1f
    ld c, a
    ld b, $00
    ld hl, sp+$1f
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
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$05
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
    jp nz, Jump_001_44dd

    jr jr_001_44e0

Jump_001_44dd:
    jp Jump_001_452a


jr_001_44e0:
    ld hl, sp+$20
    ld a, [hl]
    ld hl, sp+$04
    ld [hl], a
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, $0000
    push hl
    push bc
    call Call_000_08b7
    add sp, $05
    ld hl, $0003
    push hl
    ld a, $00
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, $1103
    push hl
    ld hl, $45af
    push hl
    call Call_000_08b7
    add sp, $05
    jp Jump_001_4552


Jump_001_452a:
    ld hl, sp+$20
    ld a, [hl]
    ld hl, sp+$04
    ld [hl], a
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, $0014
    push hl
    push bc
    call Call_000_08b7
    add sp, $05

Jump_001_4552:
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, sp+$0a
    ld a, l
    ld d, h
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    inc bc
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld a, $0a
    push af
    inc sp
    inc hl
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
    call Call_000_16f4
    add sp, $07
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, $0010
    push hl
    ld a, $04
    push af
    inc sp
    push bc
    call Call_000_08b7
    add sp, $05
    add sp, $24
    ret


    ld b, h
    ld c, c
    ld d, d
    nop
    add sp, -$0a
    ld hl, sp+$10
    ld a, [hl]
    sub $00
    inc hl
    ld a, [hl]
    sbc $00
    inc hl
    ld a, [hl]
    sbc $01
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_001_479b

    ld hl, sp+$10
    ld a, [hl]
    ld hl, sp+$06
    ld [hl], a
    ld hl, sp+$11
    ld a, [hl]
    ld hl, sp+$07
    ld [hl-], a
    ld a, [hl]
    sub $00
    inc hl
    ld a, [hl]
    sbc $10
    jp nc, Jump_001_45e7

    ld de, $d3f9
    ld c, e
    ld b, d
    jp Jump_001_45ec


Jump_001_45e7:
    ld de, $d5eb
    ld c, e
    ld b, d

Jump_001_45ec:
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], b

Jump_001_45f1:
    ld hl, sp+$08
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
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], b
    dec hl
    ld a, [hl+]
    or [hl]
    jp z, Jump_001_478a

    inc hl
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
    jp c, Jump_001_478a

    ld hl, sp+$08
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
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$02
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], $00
    inc hl
    inc hl
    ld [hl], $00
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$06
    ld a, [hl]
    sub c
    inc hl
    ld a, [hl]
    sbc b
    jp nc, Jump_001_476c

    ld a, $08
    ld hl, sp+$00
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp c, Jump_001_478a

    dec hl
    ld e, [hl]
    ld d, $00
    ld hl, $4676
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp Jump_001_4691


    jp Jump_001_46bd


    jp Jump_001_46e2


    jp Jump_001_46f6


    jp Jump_001_470a


    jp Jump_001_471e


    jp Jump_001_4732


    jp Jump_001_4744


    jp Jump_001_4758


Jump_001_4691:
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
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
    ld hl, sp+$06
    ld [hl], c
    inc hl
    ld [hl], b
    jp Jump_001_478a


Jump_001_46bd:
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld a, e
    and $01
    ld c, a
    ld b, $00
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    sub c
    ld e, a
    ld a, d
    sbc b
    ld [hl-], a
    ld [hl], e
    jp Jump_001_478a


Jump_001_46e2:
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0010
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    jp Jump_001_478a


Jump_001_46f6:
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0020
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    jp Jump_001_478a


Jump_001_470a:
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0030
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    jp Jump_001_478a


Jump_001_471e:
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $001a
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    jp Jump_001_478a


Jump_001_4732:
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0008
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], d
    jp Jump_001_478a


Jump_001_4744:
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0050
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    jp Jump_001_478a


Jump_001_4758:
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $1c60
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    jp Jump_001_478a


Jump_001_476c:
    ld hl, sp+$00
    ld a, [hl+]
    or [hl]
    jp nz, Jump_001_45f1

    inc hl
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
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    jp Jump_001_45f1


Jump_001_478a:
    ld hl, sp+$06
    ld a, [hl]
    ld hl, sp+$10
    ld [hl], a
    ld hl, sp+$07
    ld a, [hl]
    ld hl, sp+$11
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_001_479b:
    ld hl, sp+$10
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add sp, $0a
    ret


Call_001_47a7:
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


    push af
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld hl, sp+$00
    ld [hl], $34
    inc hl
    ld [hl], $7f
    ld hl, sp+$04
    ld c, [hl]
    ld b, $00
    ld a, c
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    ld [hl], $35
    inc hl
    ld [hl], $7f
    ld c, $00
    ld hl, sp+$05
    ld b, [hl]
    ld c, b
    ld b, $00
    ld a, c
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    add sp, $02
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
    ld bc, $7fd4
    ld hl, sp+$06
    ld a, [hl]
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ret


    push af
    push af
    ld hl, $48c4
    push hl
    ld hl, $c2a6
    push hl
    call Call_000_078d
    ld c, b
    ld b, b
    ld bc, $e800
    inc b
    ld b, d
    ld c, e
    ld a, c
    or a
    jp z, Jump_001_4856

    ld hl, $48c4
    push hl
    ld hl, $c2a6
    push hl
    call Call_000_078d
    nop
    ld b, b
    ld bc, $e800
    inc b

Jump_001_4856:
    ld hl, $c4a4
    push hl
    ld hl, $c2a6
    push hl
    call Call_000_078d
    nop
    ld b, b
    ld bc, $e800
    inc b
    ld bc, $4000
    ld a, $11
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld hl, sp+$02
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_001_487d:
    ld hl, sp+$02
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, Jump_001_48b2

    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $a300
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    ld de, $c2a6
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    inc hl
    inc [hl]
    jr nz, jr_001_48af

    inc hl
    inc [hl]

jr_001_48af:
    jp Jump_001_487d


Jump_001_48b2:
    ld bc, $4000
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    add sp, $04
    ret


    cpl
    nop

Call_001_48c6:
    push af
    ld c, $00
    ld hl, sp+$04
    ld a, [hl]
    and $03
    jr nz, jr_001_48d3

    jp Jump_001_48d6


jr_001_48d3:
    jp Jump_001_4913


Jump_001_48d6:
    ld hl, $0064
    push hl
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_28fd
    add sp, $04
    ld hl, sp+$01
    ld [hl], d
    dec hl
    ld [hl], e
    ld hl, sp+$00
    ld a, [hl+]
    or [hl]
    jp nz, Jump_001_4911

    ld hl, $0190
    push hl
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_28fd
    add sp, $04
    ld hl, sp+$01
    ld [hl], d
    dec hl
    ld [hl], e
    ld hl, sp+$00
    ld a, [hl+]
    or [hl]
    jp z, Jump_001_4911

    ld c, $00
    jp Jump_001_4913


Jump_001_4911:
    ld c, $01

Jump_001_4913:
    ld e, c
    add sp, $02
    ret


Call_001_4917:
    add sp, -$18
    xor a
    ld hl, sp+$14
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld hl, sp+$1a
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$0e
    ld [hl], $b2
    inc hl
    ld [hl], $07

Jump_001_492f:
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
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
    jp nc, Jump_001_499c

    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_001_48c6
    add sp, $02
    ld c, e
    xor a
    or c
    jp z, Jump_001_4974

    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    add $6e
    ld e, a
    ld a, d
    adc $01
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
    jp Jump_001_4992


Jump_001_4974:
    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    add $6d
    ld e, a
    ld a, d
    adc $01
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

Jump_001_4992:
    ld hl, sp+$0e
    inc [hl]
    jr nz, jr_001_4999

    inc hl
    inc [hl]

jr_001_4999:
    jp Jump_001_492f


Jump_001_499c:
    ld hl, sp+$06
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
    ld hl, sp+$0c
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_001_49b2:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld b, $00
    dec bc
    ld hl, sp+$0c
    ld a, [hl]
    sub c
    inc hl
    ld a, [hl]
    sbc b
    jp nc, Jump_001_4a63

    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    push bc
    call Call_001_48c6
    add sp, $02
    ld c, e
    xor a
    or c
    jp z, Jump_001_4a1c

    ld de, $d6b3
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
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
    ld hl, sp+$14
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
    ld hl, sp+$17
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
    ld hl, sp+$17
    ld [hl-], a
    ld [hl], e
    jp Jump_001_4a59


Jump_001_4a1c:
    ld de, $d6a7
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
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
    ld hl, sp+$14
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
    ld hl, sp+$17
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
    ld hl, sp+$17
    ld [hl-], a
    ld [hl], e

Jump_001_4a59:
    ld hl, sp+$0c
    inc [hl]
    jr nz, jr_001_4a60

    inc hl
    inc [hl]

jr_001_4a60:
    jp Jump_001_49b2


Jump_001_4a63:
    ld hl, sp+$06
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
    dec bc
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
    ld hl, sp+$14
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
    ld hl, sp+$17
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
    ld hl, sp+$17
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$16
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $0000
    push hl
    ld hl, $0018
    push hl
    call Call_000_2826
    add sp, $08
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
    ld hl, $0000
    push hl
    ld hl, $003c
    push hl
    call Call_000_2826
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
    ld hl, sp+$10
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
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$12
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $0000
    push hl
    ld hl, $003c
    push hl
    call Call_000_2826
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
    ld hl, sp+$10
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
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0005
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld e, c
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
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, b
    rla
    sbc a
    inc hl
    ld [hl+], a
    ld [hl-], a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $0000
    push hl
    ld hl, $003c
    push hl
    call Call_000_2826
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
    ld hl, sp+$10
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
    ld hl, sp+$13
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
    ld hl, sp+$13
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld e, c
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
    add hl, hl
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
    ld hl, sp+$10
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
    ld hl, sp+$13
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
    ld hl, sp+$13
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0007
    add hl, de
    ld c, l
    ld b, h
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
    ld hl, sp+$10
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
    ld hl, sp+$13
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
    ld hl, sp+$13
    ld [hl-], a
    ld [hl], e
    dec hl
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    sub $80
    ld e, a
    ld a, d
    sbc $70
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
    dec hl
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add sp, $18
    ret


Call_001_4c5e:
    add sp, -$11
    ld a, $06
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld hl, sp+$09
    ld a, l
    ld d, h
    ld hl, sp+$07
    ld [hl+], a
    ld [hl], d
    ld bc, $a00e
    ld a, [bc]
    and $0f
    ld c, a
    ld hl, sp+$05
    ld [hl], c
    inc hl
    ld [hl], $00
    ld bc, $a00e
    ld a, [bc]
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
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, $07d0
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a
    ld hl, sp+$09
    ld a, l
    ld d, h
    ld hl, sp+$05
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
    ld hl, sp+$07
    ld [hl+], a
    ld [hl], d
    ld bc, $a00d
    ld a, [bc]
    ld c, a
    and $0f
    ld hl, sp+$04
    ld [hl], a
    ld bc, $a00d
    ld a, [bc]
    ld c, a
    srl c
    srl c
    srl c
    srl c
    ld a, c
    ld e, a
    add a
    add a
    add e
    add a
    ld c, a
    ld hl, sp+$04
    ld a, [hl]
    add c
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$05
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0003
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$07
    ld [hl+], a
    ld [hl], d
    ld bc, $a00b
    ld a, [bc]
    ld c, a
    and $0f
    ld hl, sp+$04
    ld [hl], a
    ld bc, $a00b
    ld a, [bc]
    ld c, a
    srl c
    srl c
    srl c
    srl c
    ld a, c
    ld e, a
    add a
    add a
    add e
    add a
    ld c, a
    ld hl, sp+$04
    ld a, [hl]
    add c
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$05
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0005
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$07
    ld [hl+], a
    ld [hl], d
    ld bc, $a00a
    ld a, [bc]
    ld c, a
    and $0f
    ld hl, sp+$04
    ld [hl], a
    ld bc, $a00a
    ld a, [bc]
    ld c, a
    srl c
    srl c
    srl c
    srl c
    ld a, c
    ld e, a
    add a
    add a
    add e
    add a
    ld c, a
    ld hl, sp+$04
    ld a, [hl]
    add c
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$05
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$07
    ld [hl+], a
    ld [hl], d
    ld bc, $a009
    ld a, [bc]
    ld c, a
    and $0f
    ld hl, sp+$04
    ld [hl], a
    ld bc, $a009
    ld a, [bc]
    ld c, a
    srl c
    srl c
    srl c
    srl c
    ld a, c
    ld e, a
    add a
    add a
    add e
    add a
    ld c, a
    ld hl, sp+$04
    ld a, [hl]
    add c
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$05
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0007
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    ld bc, $a008
    ld a, [bc]
    ld c, a
    and $0f
    dec hl
    dec hl
    ld [hl], a
    ld bc, $a008
    ld a, [bc]
    ld c, a
    srl c
    srl c
    srl c
    srl c
    ld a, c
    ld e, a
    add a
    add a
    add e
    add a
    ld c, a
    ld hl, sp+$04
    ld a, [hl]
    add c
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld a, $03
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld hl, sp+$09
    ld c, l
    ld b, h
    push bc
    call Call_001_4917
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
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add sp, $11
    ret


Call_001_4df1:
    add sp, -$16
    call Call_001_4c5e
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
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$18
    sub [hl]
    ld e, a
    ld a, d
    inc hl
    sbc [hl]
    push af
    ld hl, sp+$11
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$1c
    pop af
    ld a, e
    sbc [hl]
    ld e, a
    ld a, d
    inc hl
    sbc [hl]
    ld hl, sp+$11
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$18
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, Jump_001_4e38

    ld hl, sp+$11
    ld a, [hl]
    bit 7, a
    jp z, Jump_001_4e50

Jump_001_4e38:
    ld hl, sp+$08
    ld [hl], $00
    dec hl
    ld [hl], $00
    dec hl
    ld [hl], $00
    xor a
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld hl, sp+$09
    ld [hl], $00
    jp Jump_001_5063


Jump_001_4e50:
    ld de, $c0a0
    ld a, [de]
    ld c, a
    ld hl, sp+$08
    ld [hl], c
    ld bc, $c0a4
    ld a, [bc]
    ld c, a
    dec hl
    ld [hl], c
    ld bc, $c0a8
    ld a, [bc]
    ld b, a
    dec hl
    ld [hl], b
    ld bc, $c0ac
    ld a, [bc]
    ld c, a
    ld hl, sp+$0a
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld bc, $c0b0
    ld a, [bc]
    ld c, a
    ld hl, sp+$09
    ld [hl], c
    ld a, $3b
    dec hl
    sub [hl]
    jp c, Jump_001_4e94

    ld a, $3b
    dec hl
    sub [hl]
    jp c, Jump_001_4e94

    ld a, $17
    dec hl
    sub [hl]
    jp nc, Jump_001_4ea9

Jump_001_4e94:
    ld hl, sp+$08
    ld [hl], $00
    dec hl
    ld [hl], $00
    dec hl
    ld [hl], $00
    xor a
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld hl, sp+$09
    ld [hl], $00

Jump_001_4ea9:
    ld hl, $0000
    push hl
    ld hl, $003c
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
    call Call_000_2829
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
    ld c, [hl]
    ld hl, sp+$08
    ld a, [hl]
    add c
    ld [hl], a
    ld a, $3b
    sub [hl]
    jp nc, Jump_001_4ee0

    ld a, [hl]
    add $c4
    ld [hl-], a
    inc [hl]

Jump_001_4ee0:
    ld hl, $0000
    push hl
    ld hl, $003c
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
    call Call_000_282f
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
    ld hl, $0000
    push hl
    ld hl, $003c
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
    call Call_000_2829
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
    ld c, [hl]
    ld hl, sp+$07
    ld a, [hl]
    add c
    ld [hl], a
    ld a, $3b
    sub [hl]
    jp nc, Jump_001_4f4c

    ld a, [hl]
    add $c4
    ld [hl-], a
    inc [hl]

Jump_001_4f4c:
    ld hl, $0000
    push hl
    ld hl, $003c
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
    call Call_000_282f
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
    ld hl, $0000
    push hl
    ld hl, $0018
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
    call Call_000_2829
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
    ld c, [hl]
    ld hl, sp+$06
    ld a, [hl]
    add c
    ld [hl], a
    ld a, $17
    sub [hl]
    jp nc, Jump_001_4fc6

    ld a, [hl]
    add $e8
    ld [hl], a
    ld hl, sp+$0a
    inc [hl]
    jr nz, jr_001_4fc6

    inc hl
    inc [hl]
    jr nz, jr_001_4fc6

    inc hl
    inc [hl]
    jr nz, jr_001_4fc6

    inc hl
    inc [hl]

Jump_001_4fc6:
jr_001_4fc6:
    ld hl, $0000
    push hl
    ld hl, $0018
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
    call Call_000_282f
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
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$0e
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld hl, sp+$0d
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$12
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld hl, sp+$0d
    ld [hl-], a
    ld [hl], e
    ld a, $ff
    dec hl
    dec hl
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
    jp nc, Jump_001_5063

    ld hl, sp+$09
    ld a, [hl]
    and $c1
    ld c, a
    or $01
    ld [hl], a
    ld a, $ff
    inc hl
    sub [hl]
    ld a, $01
    inc hl
    sbc [hl]
    ld a, $00
    inc hl
    sbc [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp nc, Jump_001_5063

    dec hl
    dec hl
    ld a, [hl]
    and $01
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$09
    ld a, [hl]
    or $80
    ld [hl], a
    and $c0
    ld [hl], a

Jump_001_5063:
    ld a, $06
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld bc, $a018
    ld hl, sp+$08
    ld a, [hl]
    ld [bc], a
    ld bc, $a019
    dec hl
    ld a, [hl]
    ld [bc], a
    ld bc, $a01a
    dec hl
    ld a, [hl]
    ld [bc], a
    ld bc, $a01b
    ld hl, sp+$0a
    ld a, [hl]
    ld hl, sp+$04
    ld [hl], a
    ld [bc], a
    ld bc, $a01c
    ld hl, sp+$09
    ld a, [hl]
    ld [bc], a
    ld bc, $4000
    ld a, $11
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld bc, $a220
    ld hl, sp+$08
    ld a, [hl]
    ld [bc], a
    ld bc, $a221
    dec hl
    ld a, [hl]
    ld [bc], a
    ld bc, $a222
    dec hl
    ld a, [hl]
    ld [bc], a
    ld bc, $a223
    dec hl
    dec hl
    ld a, [hl]
    ld [bc], a
    ld bc, $a224
    ld hl, sp+$09
    ld a, [hl]
    ld [bc], a
    ld bc, $4000
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld a, $00
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add sp, $16
    ret


Call_001_50e4:
    push af
    push af
    call Call_001_4c5e
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
    ld a, $06
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld bc, $a018
    ld a, $00
    ld [bc], a
    ld bc, $a019
    ld a, $00
    ld [bc], a
    ld bc, $a01a
    ld a, $00
    ld [bc], a
    ld bc, $a01b
    ld a, $00
    ld [bc], a
    ld bc, $a01c
    ld a, $00
    ld [bc], a
    ld bc, $4000
    ld a, $11
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld bc, $a220
    ld a, $00
    ld [bc], a
    ld bc, $a221
    ld a, $00
    ld [bc], a
    ld bc, $a222
    ld a, $00
    ld [bc], a
    ld bc, $a223
    ld a, $00
    ld [bc], a
    ld bc, $a224
    ld a, $00
    ld [bc], a
    ld bc, $4000
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
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


    add sp, -$1e
    ld hl, $001e
    push hl
    ld hl, $572e
    push hl
    ld hl, $c3a5
    push hl
    call Call_000_2cba
    add sp, $06
    ld hl, sp+$24
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $c3a5
    push hl
    call Call_000_078d
    nop
    ld b, b
    ld bc, $e800
    inc b
    ld hl, $c3a5
    push hl
    call Call_000_2d95
    add sp, $02
    ld b, d
    ld c, e
    ld hl, sp+$0b
    ld [hl], c
    ld a, [hl]
    dec a
    ld b, a
    add $a5
    ld c, a
    ld a, $c3
    adc $00
    ld b, a
    ld a, [bc]
    ld c, a
    sub $63
    jp z, Jump_001_51b2

    ld a, c
    sub $43
    jp z, Jump_001_51b2

    ld hl, sp+$0b
    inc [hl]

Jump_001_51b2:
    ld hl, sp+$0b
    ld a, [hl]
    add $fd
    add $a5
    ld c, a
    ld a, $c3
    adc $00
    ld b, a
    ld a, $73
    ld [bc], a
    ld a, [hl]
    add $fe
    add $a5
    ld c, a
    ld a, $c3
    adc $00
    ld b, a
    ld a, $61
    ld [bc], a
    ld a, [hl]
    dec a
    add $a5
    ld c, a
    ld a, $c3
    adc $00
    ld b, a
    ld a, $76
    ld [bc], a
    ld de, $c3a5
    ld l, [hl]
    ld h, $00
    add hl, de
    ld c, l
    ld b, h
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld a, $00
    push af
    inc sp
    ld hl, $c3a5
    push hl
    ld hl, $ca0f
    push hl
    call Call_000_1926
    add sp, $05
    ld c, e
    ld hl, $d3ed
    ld a, [hl]
    or a
    jp z, Jump_001_5233

    ld hl, $d3ed
    ld a, [hl]
    sub $01
    jp z, Jump_001_525b

    ld hl, $d3ed
    ld a, [hl]
    sub $02
    jp z, Jump_001_525b

    ld hl, $d3ed
    ld a, [hl]
    sub $04
    jp z, Jump_001_526b

    ld hl, $d3ed
    ld a, [hl]
    sub $05
    jp z, Jump_001_527b

    jp Jump_001_528b


Jump_001_5233:
    ld hl, $d3eb
    ld a, [hl]
    sub $02
    jp nz, Jump_001_523e

    jr jr_001_5241

Jump_001_523e:
    jp Jump_001_5251


jr_001_5241:
    ld hl, sp+$14
    ld [hl], $00
    inc hl
    ld [hl], $20
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp Jump_001_5298


Jump_001_5251:
    xor a
    ld hl, sp+$14
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    jp Jump_001_5298


Jump_001_525b:
    ld hl, sp+$14
    ld [hl], $00
    inc hl
    ld [hl], $20
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp Jump_001_5298


Jump_001_526b:
    ld hl, sp+$14
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $02
    inc hl
    ld [hl], $00
    jp Jump_001_5298


Jump_001_527b:
    ld hl, sp+$14
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $01
    inc hl
    ld [hl], $00
    jp Jump_001_5298


Jump_001_528b:
    ld hl, sp+$14
    ld [hl], $00
    inc hl
    ld [hl], $80
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_001_5298:
    xor a
    or c
    jp nz, Jump_001_54d1

    ld a, $03
    push af
    inc sp
    ld hl, $c3a5
    push hl
    ld hl, $ca0f
    push hl
    call Call_000_1926
    add sp, $05
    ld bc, $ca19
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
    ld hl, sp+$14
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
    ld hl, $0000
    push hl
    ld hl, $0000
    push hl
    ld hl, $ca0f
    push hl
    call Call_000_1985
    add sp, $06
    ld hl, sp+$14
    ld a, [hl]
    and $30
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$04
    ld a, [hl]
    sub $30
    jp nz, Jump_001_530e

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_001_530e

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_001_530e

    inc hl
    ld a, [hl]
    or a
    jp nz, Jump_001_530e

    jr jr_001_5311

Jump_001_530e:
    jp Jump_001_531c


jr_001_5311:
    ld hl, sp+$08
    ld [hl], $01
    ld hl, sp+$14
    ld [hl], $00
    jp Jump_001_5320


Jump_001_531c:
    ld hl, sp+$08
    ld [hl], $00

Jump_001_5320:
    xor a
    ld hl, sp+$1a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

Jump_001_5327:
    ld hl, sp+$1a
    ld d, h
    ld e, l
    ld hl, sp+$14
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
    jp nc, Jump_001_53ee

    ld a, $00
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld hl, sp+$18
    ld c, l
    ld b, h
    push bc
    ld hl, $0200
    push hl
    ld hl, $c0a0
    push hl
    ld hl, $ca0f
    push hl
    call Call_000_1941
    add sp, $08
    ld bc, $4000
    push bc
    ld a, $0d
    push af
    inc sp
    ld hl, sp+$1f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$1f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_298f
    add sp, $05
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
    ld a, $03
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld hl, sp+$1a
    ld a, [hl]
    ld hl, sp+$00
    ld [hl], a
    ld hl, sp+$1b
    ld a, [hl]
    and $1f
    ld hl, sp+$01
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld a, d
    add $a0
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
    dec hl
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, $0200
    push hl
    ld hl, $c0a0
    push hl
    push bc
    call Call_000_30ea
    add sp, $06
    ld hl, sp+$1a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld a, d
    add $02
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
    jp Jump_001_5327


Jump_001_53ee:
    xor a
    ld hl, sp+$08
    or [hl]
    jp z, Jump_001_5495

    ld a, $00
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    add $28
    ld e, a
    ld a, d
    adc $00
    push af
    ld hl, sp+$13
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$18
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    adc $00
    ld e, a
    ld a, d
    adc $00
    ld hl, sp+$13
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$12
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $ca0f
    push hl
    call Call_000_1985
    add sp, $06
    ld hl, sp+$18
    ld c, l
    ld b, h
    push bc
    ld hl, $0004
    push hl
    ld hl, $d3f2
    push hl
    ld hl, $ca0f
    push hl
    call Call_000_1941
    add sp, $08
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
    ld hl, $ca0f
    push hl
    call Call_000_1985
    add sp, $06
    ld hl, sp+$18
    ld c, l
    ld b, h
    push bc
    ld hl, $0030
    push hl
    ld hl, $c0a0
    push hl
    ld hl, $ca0f
    push hl
    call Call_000_1941
    add sp, $08
    ld hl, $d3f4
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $d3f2
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_001_4df1
    add sp, $04
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
    jp Jump_001_54bc


Jump_001_5495:
    xor a
    ld hl, $d3f0
    or [hl]
    jp z, Jump_001_54bc

    call Call_001_50e4
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
    ld hl, sp+$0c
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

Jump_001_54bc:
    ld a, $00
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld hl, $ca0f
    push hl
    call Call_000_19a1
    add sp, $02
    jp Jump_001_55c2


Jump_001_54d1:
    ld hl, $0200
    push hl
    ld a, $ff
    push af
    inc sp
    ld hl, $c0a0
    push hl
    call Call_000_2ca5
    add sp, $05
    xor a
    ld hl, sp+$1a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

Jump_001_54e9:
    ld hl, sp+$1a
    ld d, h
    ld e, l
    ld hl, sp+$14
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
    jp nc, Jump_001_559a

    ld a, $00
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld bc, $4000
    push bc
    ld a, $0d
    push af
    inc sp
    ld hl, sp+$1f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$1f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_298f
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
    ld hl, sp+$04
    ld a, [hl]
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld hl, sp+$1a
    ld a, [hl]
    ld hl, sp+$00
    ld [hl], a
    ld hl, sp+$1b
    ld a, [hl]
    and $1f
    ld hl, sp+$01
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld a, d
    add $a0
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
    dec hl
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, $0200
    push hl
    ld hl, $c0a0
    push hl
    push bc
    call Call_000_30ea
    add sp, $06
    ld hl, sp+$1a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld a, d
    add $02
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
    jp Jump_001_54e9


Jump_001_559a:
    call Call_001_50e4
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
    ld hl, sp+$0c
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
    ld a, $00
    push af
    inc sp
    call Call_001_47a7
    add sp, $01

Jump_001_55c2:
    ld a, $0d
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
    call Call_000_298f
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
    ld hl, sp+$14
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
    ld bc, $4000
    ld a, $11
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld bc, $a000
    ld a, $aa
    ld [bc], a
    ld bc, $a001
    ld hl, sp+$14
    ld a, [hl]
    ld [bc], a
    ld bc, $a00f
    ld hl, sp+$0b
    ld a, [hl]
    ld [bc], a
    dec hl
    dec hl
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_001_561d:
    ld hl, sp+$0b
    ld c, [hl]
    ld b, $00
    dec hl
    dec hl
    ld a, [hl]
    sub c
    inc hl
    ld a, [hl]
    sbc b
    jp nc, Jump_001_5657

    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $a010
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    ld de, $c3a5
    ld hl, sp+$09
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$09
    inc [hl]
    jr nz, jr_001_5654

    inc hl
    inc [hl]

jr_001_5654:
    jp Jump_001_561d


Jump_001_5657:
    xor a
    ld hl, $d3f0
    or [hl]
    jp z, Jump_001_5716

    ld bc, $a202
    ld a, $77
    ld [bc], a
    ld bc, $a210
    ld hl, sp+$0c
    ld a, [hl]
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$04
    ld a, [hl]
    ld [bc], a
    ld bc, $a211
    push bc
    ld a, $08
    push af
    inc sp
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
    call Call_000_298f
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
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$04
    ld a, [hl]
    ld [bc], a
    ld bc, $a212
    push bc
    ld a, $10
    push af
    inc sp
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
    call Call_000_298f
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
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$04
    ld a, [hl]
    ld [bc], a
    ld bc, $a213
    push bc
    ld a, $18
    push af
    inc sp
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
    call Call_000_298f
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
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$04
    ld a, [hl]
    ld [bc], a
    jp Jump_001_571c


Jump_001_5716:
    ld bc, $a202
    ld a, $00
    ld [bc], a

Jump_001_571c:
    ld bc, $4000
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    add sp, $1e
    ret


    cpl
    ld d, e
    ld b, c
    ld d, [hl]
    ld b, l
    ld d, d
    cpl
    nop
    add sp, -$0e
    ld a, $01
    ld hl, sp+$14
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp nc, Jump_001_58ad

    ld bc, $4000
    ld a, $01
    ld [bc], a
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
    ld hl, sp+$09
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$0c
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_001_5761:
    ld hl, sp+$0c
    ld d, h
    ld e, l
    ld hl, sp+$08
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp nc, Jump_001_58ad

    ld hl, sp+$14
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
    ld b, a
    ld c, e
    ld de, $0001
    ld a, c
    sub e
    ld e, a
    ld a, b
    sbc d
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$0a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$04
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_001_579b:
    ld hl, sp+$0a
    ld d, h
    ld e, l
    ld hl, sp+$06
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp nc, Jump_001_58a3

    ld hl, sp+$0a
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld e, c
    ld d, b
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
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], d
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
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
    ld hl, sp+$00
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call Call_000_078d
    ld c, b
    ld b, b
    ld bc, $e800
    inc b
    ld b, d
    ld c, e
    ld a, $00
    sub c
    ld a, $00
    sbc b
    rlca
    jp nc, Jump_001_588a

    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, $00ff
    push hl
    push bc
    ld hl, $c0a0
    push hl
    call Call_000_2cba
    add sp, $06
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
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, $00ff
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call Call_000_2cba
    add sp, $06
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
    ld hl, $00ff
    push hl
    ld hl, $c0a0
    push hl
    push bc
    call Call_000_2cba
    add sp, $06

Jump_001_588a:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00ff
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$0a
    inc [hl]
    jr nz, jr_001_58a0

    inc hl
    inc [hl]

jr_001_58a0:
    jp Jump_001_579b


Jump_001_58a3:
    ld hl, sp+$0c
    inc [hl]
    jr nz, jr_001_58aa

    inc hl
    inc [hl]

jr_001_58aa:
    jp Jump_001_5761


Jump_001_58ad:
    add sp, $0e
    ret


    ld hl, $fdbc
    add hl, sp
    ld sp, hl
    ld a, $00
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld hl, sp+$20
    ld c, l
    ld b, h
    ld a, $01
    push af
    inc sp
    ld hl, $024b
    add hl, sp
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call Call_000_1926
    add sp, $05
    ld c, e
    ld hl, $0240
    add hl, sp
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, $0240
    add hl, sp
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, Jump_001_58f9

    ld de, $ffff
    ld hl, $ffff
    jp Jump_001_5c02


Jump_001_58f9:
    ld de, $c7a9
    ld a, [de]
    ld c, a
    sub $02
    jp nz, Jump_001_5905

    jr jr_001_5908

Jump_001_5905:
    jp Jump_001_5918


jr_001_5908:
    ld hl, sp+$0e
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp Jump_001_5925


Jump_001_5918:
    ld hl, sp+$0e
    ld [hl], $f7
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $0f

Jump_001_5925:
    ld hl, sp+$20
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
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
    ld hl, sp+$1a
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
    ld hl, $000a
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
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
    ld hl, sp+$1e
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
    ld hl, sp+$1e
    ld [hl+], a
    ld [hl], d
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
    ld hl, $c7a9
    push hl
    call Call_000_19c1
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
    ld hl, sp+$1e
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
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$1e
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$1a
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
    xor a
    ld hl, sp+$12
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

Jump_001_59e4:
    ld hl, sp+$20
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
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$1c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call Call_000_19f5
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
    ld hl, sp+$1a
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
    inc [hl]
    jr nz, jr_001_5a2c

    inc hl
    inc [hl]
    jr nz, jr_001_5a2c

    inc hl
    inc [hl]
    jr nz, jr_001_5a2c

    inc hl
    inc [hl]

jr_001_5a2c:
    ld hl, sp+$16
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
    ld hl, sp+$1a
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
    ld hl, sp+$1a
    ld a, [hl]
    ld hl, sp+$04
    sub [hl]
    jp nz, Jump_001_5a72

    ld hl, sp+$1b
    ld a, [hl]
    ld hl, sp+$05
    sub [hl]
    jp nz, Jump_001_5a72

    ld hl, sp+$1c
    ld a, [hl]
    ld hl, sp+$06
    sub [hl]
    jp nz, Jump_001_5a72

    ld hl, sp+$1d
    ld a, [hl]
    ld hl, sp+$07
    sub [hl]
    jp z, Jump_001_5b12

Jump_001_5a72:
    ld bc, $c7ab
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
    call Call_000_2826
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
    ld hl, sp+$1e
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
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$1e
    ld [hl+], a
    ld [hl], d
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
    ld hl, $c7a9
    push hl
    call Call_000_19c1
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
    ld hl, sp+$1e
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
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$1e
    ld [hl+], a
    ld [hl], d

Jump_001_5b12:
    ld hl, sp+$1a
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
    ld hl, sp+$1a
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
    jp c, Jump_001_59e4

    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$1f
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
    ld hl, sp+$1f
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
    ld hl, sp+$20
    ld c, l
    ld b, h
    push bc
    call Call_000_19a1
    add sp, $02
    ld hl, sp+$1e
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
    ld hl, sp+$1e
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
    ld hl, sp+$1e
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
    ld bc, $c7ab
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
    ld de, $0000
    ld hl, $0000

Jump_001_5c02:
    ld hl, $0244
    add hl, sp
    ld sp, hl
    ret


Call_001_5c08:
    ld hl, sp+$02
    ld a, [hl]
    or a
    jp z, Jump_001_5d11

    ld hl, sp+$02
    ld a, [hl]
    sub $01
    jp z, Jump_001_5d19

    ld hl, sp+$02
    ld a, [hl]
    sub $02
    jp z, Jump_001_5d19

    ld hl, sp+$02
    ld a, [hl]
    sub $03
    jp z, Jump_001_5d19

    ld hl, sp+$02
    ld a, [hl]
    sub $05
    jp z, Jump_001_5d21

    ld hl, sp+$02
    ld a, [hl]
    sub $06
    jp z, Jump_001_5d21

    ld hl, sp+$02
    ld a, [hl]
    sub $08
    jp z, Jump_001_5d11

    ld hl, sp+$02
    ld a, [hl]
    sub $09
    jp z, Jump_001_5d11

    ld hl, sp+$02
    ld a, [hl]
    sub $0b
    jp z, Jump_001_5d39

    ld hl, sp+$02
    ld a, [hl]
    sub $0c
    jp z, Jump_001_5d39

    ld hl, sp+$02
    ld a, [hl]
    sub $0d
    jp z, Jump_001_5d39

    ld hl, sp+$02
    ld a, [hl]
    sub $0f
    jp z, Jump_001_5d29

    ld hl, sp+$02
    ld a, [hl]
    sub $10
    jp z, Jump_001_5d29

    ld hl, sp+$02
    ld a, [hl]
    sub $11
    jp z, Jump_001_5d29

    ld hl, sp+$02
    ld a, [hl]
    sub $12
    jp z, Jump_001_5d29

    ld hl, sp+$02
    ld a, [hl]
    sub $13
    jp z, Jump_001_5d29

    ld hl, sp+$02
    ld a, [hl]
    sub $15
    jp z, Jump_001_5d39

    ld hl, sp+$02
    ld a, [hl]
    sub $16
    jp z, Jump_001_5d39

    ld hl, sp+$02
    ld a, [hl]
    sub $17
    jp z, Jump_001_5d39

    ld hl, sp+$02
    ld a, [hl]
    sub $19
    jp z, Jump_001_5d31

    ld hl, sp+$02
    ld a, [hl]
    sub $1a
    jp z, Jump_001_5d31

    ld hl, sp+$02
    ld a, [hl]
    sub $1b
    jp z, Jump_001_5d31

    ld hl, sp+$02
    ld a, [hl]
    sub $1c
    jp z, Jump_001_5d31

    ld hl, sp+$02
    ld a, [hl]
    sub $1d
    jp z, Jump_001_5d31

    ld hl, sp+$02
    ld a, [hl]
    sub $1e
    jp z, Jump_001_5d31

    ld hl, sp+$02
    ld a, [hl]
    sub $22
    jp z, Jump_001_5d39

    ld hl, sp+$02
    ld a, [hl]
    sub $55
    jp z, Jump_001_5d39

    ld hl, sp+$02
    ld a, [hl]
    sub $56
    jp z, Jump_001_5d39

    ld hl, sp+$02
    ld a, [hl]
    sub $ea
    jp z, Jump_001_5d19

    ld hl, sp+$02
    ld a, [hl]
    sub $fc
    jp z, Jump_001_5d29

    ld hl, sp+$02
    ld a, [hl]
    sub $fd
    jp z, Jump_001_5d39

    ld hl, sp+$02
    ld a, [hl]
    sub $fe
    jp z, Jump_001_5d39

    ld hl, sp+$02
    ld a, [hl]
    inc a
    jp z, Jump_001_5d19

    jp Jump_001_5d41


Jump_001_5d11:
    ld hl, $d3eb
    ld [hl], $00
    jp Jump_001_5d46


Jump_001_5d19:
    ld hl, $d3eb
    ld [hl], $01
    jp Jump_001_5d46


Jump_001_5d21:
    ld hl, $d3eb
    ld [hl], $02
    jp Jump_001_5d46


Jump_001_5d29:
    ld hl, $d3eb
    ld [hl], $03
    jp Jump_001_5d46


Jump_001_5d31:
    ld hl, $d3eb
    ld [hl], $04
    jp Jump_001_5d46


Jump_001_5d39:
    ld hl, $d3eb
    ld [hl], $06
    jp Jump_001_5d46


Jump_001_5d41:
    ld hl, $d3eb
    ld [hl], $06

Jump_001_5d46:
    ld hl, sp+$02
    ld a, [hl]
    sub $03
    jp z, Jump_001_5db2

    ld hl, sp+$02
    ld a, [hl]
    sub $06
    jp z, Jump_001_5db2

    ld hl, sp+$02
    ld a, [hl]
    sub $09
    jp z, Jump_001_5db2

    ld hl, sp+$02
    ld a, [hl]
    sub $0d
    jp z, Jump_001_5db2

    ld hl, sp+$02
    ld a, [hl]
    sub $0f
    jp z, Jump_001_5db2

    ld hl, sp+$02
    ld a, [hl]
    sub $10
    jp z, Jump_001_5db2

    ld hl, sp+$02
    ld a, [hl]
    sub $13
    jp z, Jump_001_5db2

    ld hl, sp+$02
    ld a, [hl]
    sub $17
    jp z, Jump_001_5db2

    ld hl, sp+$02
    ld a, [hl]
    sub $1b
    jp z, Jump_001_5db2

    ld hl, sp+$02
    ld a, [hl]
    sub $1e
    jp z, Jump_001_5db2

    ld hl, sp+$02
    ld a, [hl]
    sub $22
    jp z, Jump_001_5db2

    ld hl, sp+$02
    ld a, [hl]
    sub $fd
    jp z, Jump_001_5db2

    ld hl, sp+$02
    ld a, [hl]
    inc a
    jp nz, Jump_001_5daf

    jr jr_001_5db2

Jump_001_5daf:
    jp Jump_001_5dba


Jump_001_5db2:
jr_001_5db2:
    ld hl, $d3ef
    ld [hl], $01
    jp Jump_001_5dbf


Jump_001_5dba:
    ld hl, $d3ef
    ld [hl], $00

Jump_001_5dbf:
    ld hl, sp+$02
    ld a, [hl]
    sub $0f
    jp z, Jump_001_5dd4

    ld hl, sp+$02
    ld a, [hl]
    sub $10
    jp nz, Jump_001_5dd1

    jr jr_001_5dd4

Jump_001_5dd1:
    jp Jump_001_5ddc


Jump_001_5dd4:
jr_001_5dd4:
    ld hl, $d3f0
    ld [hl], $01
    jp Jump_001_5de1


Jump_001_5ddc:
    ld hl, $d3f0
    ld [hl], $00

Jump_001_5de1:
    ld hl, sp+$02
    ld a, [hl]
    sub $1c
    jp c, Jump_001_5e0e

    ld a, $1e
    sub [hl]
    jp c, Jump_001_5e0e

    ld a, [hl]
    add $e4
    ld c, a
    ld e, c
    ld d, $00
    ld hl, $5dfd
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp Jump_001_5e06


    jp Jump_001_5e06


    jp Jump_001_5e06


Jump_001_5e06:
    ld hl, $d3f1
    ld [hl], $01
    jp Jump_001_5e13


Jump_001_5e0e:
    ld hl, $d3f1
    ld [hl], $00

Jump_001_5e13:
    ret


    add sp, -$15
    xor a
    ld hl, sp+$08
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld a, $00
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld a, $01
    push af
    inc sp
    ld hl, sp+$1c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $ca0f
    push hl
    call Call_000_1926
    add sp, $05
    ld c, e
    ld hl, sp+$11
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$11
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, Jump_001_5e56

    ld e, $ff
    jp Jump_001_601b


Jump_001_5e56:
    ld bc, $ca19
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
    ld a, $0e
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
    call Call_000_298f
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
    ld a, [hl]
    ld hl, $c2a4
    ld [hl], a
    ld hl, sp+$05
    ld a, [hl]
    ld hl, $c2a5
    ld [hl], a
    ld hl, $0000
    push hl
    ld hl, $0000
    push hl
    ld hl, $ca0f
    push hl
    call Call_000_1985
    add sp, $06
    ld hl, sp+$0f
    ld c, l
    ld b, h
    push bc
    ld hl, $0200
    push hl
    ld hl, $c0a0
    push hl
    ld hl, $ca0f
    push hl
    call Call_000_1941
    add sp, $08
    ld hl, $c5a3
    ld [hl], $00
    ld hl, sp+$0d
    ld [hl], $34
    inc hl
    ld [hl], $01

Jump_001_5ec8:
    ld a, $4c
    ld hl, sp+$0d
    sub [hl]
    ld a, $01
    inc hl
    sbc [hl]
    jp c, Jump_001_5ef5

    ld de, $c0a0
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, $c5a3
    ld a, [hl]
    sub c
    ld c, a
    dec a
    ld hl, $c5a3
    ld [hl], a
    ld hl, sp+$0d
    inc [hl]
    jr nz, jr_001_5ef2

    inc hl
    inc [hl]

jr_001_5ef2:
    jp Jump_001_5ec8


Jump_001_5ef5:
    ld bc, $c1e7
    ld a, [bc]
    ld c, a
    ld hl, sp+$0c
    ld [hl], c
    ld bc, $c1e8
    ld a, [bc]
    ld hl, $d3ec
    ld [hl], a
    ld bc, $c1e9
    ld a, [bc]
    ld hl, $d3ed
    ld [hl], a
    ld bc, $c1ec
    ld a, [bc]
    ld hl, $d3ee
    ld [hl], a
    ld hl, sp+$0c
    ld a, [hl]
    push af
    inc sp
    call Call_001_5c08
    add sp, $01
    ld hl, $d3eb
    ld a, [hl]
    sub $01
    jp nz, Jump_001_5f2a

    jr jr_001_5f2d

Jump_001_5f2a:
    jp Jump_001_600f


jr_001_5f2d:
    ld a, $20
    ld hl, $c2a4
    sub [hl]
    ld a, $00
    ld hl, $c2a5
    sbc [hl]
    jp nc, Jump_001_600f

    ld hl, $0004
    push hl
    ld hl, $0000
    push hl
    ld hl, $ca0f
    push hl
    call Call_000_1985
    add sp, $06
    ld hl, sp+$0f
    ld c, l
    ld b, h
    push bc
    ld hl, $0200
    push hl
    ld hl, $c0a0
    push hl
    ld hl, $ca0f
    push hl
    call Call_000_1941
    add sp, $08
    ld hl, sp+$0d
    ld [hl], $04
    inc hl
    ld [hl], $01

Jump_001_5f6a:
    ld a, $33
    ld hl, sp+$0d
    sub [hl]
    ld a, $01
    inc hl
    sbc [hl]
    jp c, Jump_001_5fe8

    ld a, $01
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
    call Call_000_29c9
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
    ld de, $c0a0
    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
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
    xor [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$05
    xor [hl]
    ld hl, sp+$01
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$06
    xor [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$07
    xor [hl]
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
    ld hl, sp+$0d
    inc [hl]
    jr nz, jr_001_5fe5

    inc hl
    inc [hl]

jr_001_5fe5:
    jp Jump_001_5f6a


Jump_001_5fe8:
    ld hl, sp+$08
    ld a, [hl]
    sub $34
    jp nz, Jump_001_6007

    inc hl
    ld a, [hl]
    sub $88
    jp nz, Jump_001_6007

    inc hl
    ld a, [hl]
    sub $6c
    jp nz, Jump_001_6007

    inc hl
    ld a, [hl]
    sub $e0
    jp nz, Jump_001_6007

    jr jr_001_600a

Jump_001_6007:
    jp Jump_001_600f


jr_001_600a:
    ld hl, $d3eb
    ld [hl], $05

Jump_001_600f:
    ld hl, $ca0f
    push hl
    call Call_000_19a1
    add sp, $02
    ld hl, sp+$11
    ld e, [hl]

Jump_001_601b:
    add sp, $15
    ret


Call_001_601e:
    add sp, -$1e
    call Call_001_62b1
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, $2a25
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $625b
    push hl
    call Call_000_08b7
    add sp, $05
    ld a, $06
    ld hl, $d3eb
    sub [hl]
    jp c, Jump_001_60e0

    ld hl, $d3eb
    ld e, [hl]
    ld d, $00
    ld hl, $6057
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp Jump_001_606c


    jp Jump_001_607d


    jp Jump_001_608e


    jp Jump_001_609f


    jp Jump_001_60b0


    jp Jump_001_60c1


    jp Jump_001_60d2


Jump_001_606c:
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, $6265
    push hl
    push bc
    call Call_000_20e2
    add sp, $04
    jp Jump_001_60e0


Jump_001_607d:
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, $626b
    push hl
    push bc
    call Call_000_20e2
    add sp, $04
    jp Jump_001_60e0


Jump_001_608e:
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, $6270
    push hl
    push bc
    call Call_000_20e2
    add sp, $04
    jp Jump_001_60e0


Jump_001_609f:
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, $6275
    push hl
    push bc
    call Call_000_20e2
    add sp, $04
    jp Jump_001_60e0


Jump_001_60b0:
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, $627a
    push hl
    push bc
    call Call_000_20e2
    add sp, $04
    jp Jump_001_60e0


Jump_001_60c1:
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, $627f
    push hl
    push bc
    call Call_000_20e2
    add sp, $04
    jp Jump_001_60e0


Jump_001_60d2:
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, $6285
    push hl
    push bc
    call Call_000_20e2
    add sp, $04

Jump_001_60e0:
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, $2a5c
    push hl
    ld a, $00
    push af
    inc sp
    push bc
    call Call_000_08b7
    add sp, $05
    ld hl, $3625
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $6289
    push hl
    call Call_000_08b7
    add sp, $05
    ld hl, sp+$0a
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld hl, $d3ec
    ld a, [hl]
    inc a
    push af
    ld bc, $0020
    pop af
    jr jr_001_611b

jr_001_6117:
    sla c
    rl b

jr_001_611b:
    dec a
    jr nz, jr_001_6117

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
    ld a, $0a
    push af
    inc sp
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$09
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$09
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Call_000_16f4
    add sp, $07
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, $6293
    push hl
    push bc
    call Call_000_078d
    nop
    ld b, b
    ld bc, $e800
    inc b
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, $365c
    push hl
    ld a, $00
    push af
    inc sp
    push bc
    call Call_000_08b7
    add sp, $05
    ld hl, $4225
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $6296
    push hl
    call Call_000_08b7
    add sp, $05
    ld hl, $d3ed
    ld a, [hl]
    or a
    jp z, Jump_001_619e

    ld hl, $d3ed
    ld a, [hl]
    sub $01
    jp z, Jump_001_61a3

    ld hl, $d3ed
    ld a, [hl]
    sub $02
    jp z, Jump_001_61a3

    ld hl, $d3ed
    ld a, [hl]
    sub $04
    jp z, Jump_001_61a8

    jp Jump_001_61ad


Jump_001_619e:
    ld c, $00
    jp Jump_001_61af


Jump_001_61a3:
    ld c, $08
    jp Jump_001_61af


Jump_001_61a8:
    ld c, $80
    jp Jump_001_61af


Jump_001_61ad:
    ld c, $20

Jump_001_61af:
    ld hl, sp+$0a
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
    ld a, $10
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
    call Call_000_16f4
    add sp, $07
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, $6293
    push hl
    push bc
    call Call_000_078d
    nop
    ld b, b
    ld bc, $e800
    inc b
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, $425c
    push hl
    ld a, $00
    push af
    inc sp
    push bc
    call Call_000_08b7
    add sp, $05
    ld hl, $4e25
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $62a0
    push hl
    call Call_000_08b7
    add sp, $05
    xor a
    ld hl, $d3ef
    or [hl]
    jp z, Jump_001_622e

    ld hl, $4e5c
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $62aa
    push hl
    call Call_000_08b7
    add sp, $05
    jp Jump_001_623f


Jump_001_622e:
    ld hl, $4e5c
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $62ae
    push hl
    call Call_000_08b7
    add sp, $05

Jump_001_623f:
    call Call_000_3a4a
    ld c, e
    ld b, $00
    ld a, c
    and $10
    jr nz, jr_001_624d

    jp Jump_001_6250


jr_001_624d:
    jp Jump_001_6258


Jump_001_6250:
    ld a, c
    and $20
    jr nz, jr_001_6258

    jp Jump_001_623f


Jump_001_6258:
jr_001_6258:
    add sp, $1e
    ret


    ld b, e
    ld h, c
    ld [hl], d
    ld h, h
    ld [hl], h
    ld a, c
    ld [hl], b
    ld h, l
    ld a, [hl-]
    nop
    ld c, [hl]
    ld l, a
    ld c, l
    ld b, d
    ld b, e
    nop
    ld c, l
    ld b, d
    ld b, e
    ld sp, $4d00
    ld b, d
    ld b, e
    ld [hl-], a
    nop
    ld c, l
    ld b, d
    ld b, e
    inc sp
    nop
    ld c, l
    ld b, d
    ld b, e
    dec [hl]
    nop
    ld c, l
    ld b, d
    ld b, e
    ld sp, $004d
    ld c, [hl]
    ld l, a
    ld [hl], h
    nop
    ld d, d
    ld c, a
    ld c, l
    jr nz, jr_001_6301

    ld l, c
    ld a, d
    ld h, l
    ld a, [hl-]
    nop
    ld c, e
    ld b, d
    nop
    ld d, d
    ld b, c
    ld c, l
    jr nz, jr_001_630e

    ld l, c
    ld a, d
    ld h, l
    ld a, [hl-]
    nop
    ld b, d
    ld h, c
    ld [hl], h
    ld [hl], h
    ld h, l
    ld [hl], d
    ld a, c
    jr nz, jr_001_62e3

    nop
    ld e, c
    ld h, l
    ld [hl], e
    nop
    ld c, [hl]
    ld l, a
    nop

Call_001_62b1:
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, $016c
    push hl
    ld hl, $7d25
    push hl
    ld a, $23
    push af
    inc sp
    call Call_000_27ba
    add sp, $05
    ret


    push af
    push af
    ld hl, sp+$03
    ld [hl], $01
    dec hl
    ld [hl], $00

Jump_001_62d9:
    call Call_001_62b1

Jump_001_62dc:
    xor a
    ld hl, sp+$03
    or [hl]
    jp z, Jump_001_6364

jr_001_62e3:
    xor a
    dec hl
    or [hl]
    jp nz, Jump_001_6328

    ld hl, $0002
    push hl
    ld a, $01
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, $2a25
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $6424

jr_001_6301:
    push hl
    call Call_000_08b7
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af

jr_001_630e:
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, $3a25
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $6429
    push hl
    call Call_000_08b7
    add sp, $05
    jp Jump_001_6364


Jump_001_6328:
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, $2a25
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $6424
    push hl
    call Call_000_08b7
    add sp, $05
    ld hl, $0002
    push hl
    ld a, $01
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, $3a25
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $6429
    push hl
    call Call_000_08b7
    add sp, $05

Jump_001_6364:
    ld hl, sp+$03
    ld [hl], $00
    call Call_000_3a4a
    ld c, e
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], $00
    dec hl
    ld a, [hl]
    and $04
    jr nz, jr_001_637b

    jp Jump_001_6386


jr_001_637b:
    xor a
    ld hl, sp+$02
    or [hl]
    jp z, Jump_001_6386

    dec [hl]
    inc hl
    ld [hl], $01

Jump_001_6386:
    ld hl, sp+$00
    ld a, [hl]
    and $08
    jr nz, jr_001_6390

    jp Jump_001_63a3


jr_001_6390:
    ld hl, sp+$02
    ld c, [hl]
    ld b, $00
    ld a, c
    sub $01
    ld a, b
    sbc $00
    rlca
    jp nc, Jump_001_63a3

    inc [hl]
    inc hl
    ld [hl], $01

Jump_001_63a3:
    ld hl, sp+$00
    ld a, [hl]
    and $10
    jr nz, jr_001_63ad

    jp Jump_001_63c7


jr_001_63ad:
    ld hl, sp+$02
    ld a, [hl]
    sub $01
    jp nz, Jump_001_63b7

    jr jr_001_63ba

Jump_001_63b7:
    jp Jump_001_63e2


jr_001_63ba:
    call Call_001_601e
    ld hl, sp+$03
    ld [hl], $01
    dec hl
    ld [hl], $00
    jp Jump_001_62d9


Jump_001_63c7:
    ld hl, sp+$00
    ld a, [hl]
    and $20
    jr nz, jr_001_63d1

    jp Jump_001_63d6


jr_001_63d1:
    ld e, $ff
    jp Jump_001_6421


Jump_001_63d6:
    ld hl, $0064
    push hl
    call Call_000_3a93
    add sp, $02
    jp Jump_001_62dc


Jump_001_63e2:
    ld hl, $0000
    push hl
    ld a, $00
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, $018f
    push hl
    ld hl, $9f00
    push hl
    ld a, $00
    push af
    inc sp
    call Call_000_27ba
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, $4133
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $6432
    push hl
    call Call_000_08b7
    add sp, $05
    ld hl, sp+$02
    ld e, [hl]

Jump_001_6421:
    add sp, $04
    ret


    ld b, d
    ld c, a
    ld c, a
    ld d, h
    nop
    ld d, d
    ld c, a
    ld c, l
    jr nz, @+$6b

    ld l, [hl]
    ld h, [hl]
    ld l, a
    nop
    ld c, h
    ld l, a
    ld h, c
    ld h, h
    ld l, c
    ld l, [hl]
    ld h, a
    nop

Call_001_643a:
    add sp, -$0b
    call Call_000_0688
    ld a, $00
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld a, $12
    push af
    inc sp
    ld hl, $c3a5
    push hl
    ld hl, $ca0f
    push hl
    call Call_000_1926
    add sp, $05
    ld c, e
    ld a, c
    or a
    jp nz, Jump_001_6738

    ld hl, $0000
    push hl
    ld hl, $0000
    push hl
    ld hl, $ca0f
    push hl
    call Call_000_1985
    add sp, $06
    ld hl, sp+$04
    ld [hl], $00
    xor a
    ld hl, sp+$07
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

Jump_001_647b:
    ld hl, sp+$07
    ld d, h
    ld e, l
    ld hl, sp+$0f
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
    jp nc, Jump_001_65a1

    ld bc, $4000
    push bc
    ld a, $0d
    push af
    inc sp
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
    call Call_000_298f
    add sp, $05
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
    ld a, $03
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld hl, sp+$07
    ld a, [hl]
    ld hl, sp+$00
    ld [hl], a
    ld hl, sp+$08
    ld a, [hl]
    and $1f
    ld hl, sp+$01
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld a, d
    add $a0
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
    dec hl
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, $0200
    push hl
    push bc
    ld hl, $c0a0
    push hl
    call Call_000_30ea
    add sp, $06
    ld a, $00
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld hl, sp+$05
    ld c, l
    ld b, h
    push bc
    ld hl, $0200
    push hl
    ld hl, $c0a0
    push hl
    ld hl, $ca0f
    push hl
    call Call_000_1963
    add sp, $08
    ld hl, sp+$04
    inc [hl]
    ld a, [hl]
    sub $03
    jp nz, Jump_001_652f

    jr jr_001_6532

Jump_001_652f:
    jp Jump_001_6536


jr_001_6532:
    ld hl, sp+$04
    ld [hl], $00

Jump_001_6536:
    xor a
    ld hl, sp+$04
    or [hl]
    jp nz, Jump_001_6551

    ld hl, $0a0b
    push hl
    ld a, $03
    push af
    inc sp
    ld hl, $673b
    push hl
    call Call_000_08b7
    add sp, $05
    jp Jump_001_6583


Jump_001_6551:
    ld hl, sp+$04
    ld a, [hl]
    sub $01
    jp nz, Jump_001_655b

    jr jr_001_655e

Jump_001_655b:
    jp Jump_001_6572


jr_001_655e:
    ld hl, $0a0b
    push hl
    ld a, $03
    push af
    inc sp
    ld hl, $673f
    push hl
    call Call_000_08b7
    add sp, $05
    jp Jump_001_6583


Jump_001_6572:
    ld hl, $0a0b
    push hl
    ld a, $03
    push af
    inc sp
    ld hl, $6743
    push hl
    call Call_000_08b7
    add sp, $05

Jump_001_6583:
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld a, d
    add $02
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
    jp Jump_001_647b


Jump_001_65a1:
    ld hl, $d3f6
    ld a, [hl]
    sub $77
    jp nz, Jump_001_65ac

    jr jr_001_65af

Jump_001_65ac:
    jp Jump_001_672f


jr_001_65af:
    ld hl, $0030
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $c0a0
    push hl
    call Call_000_2ca5
    add sp, $05
    ld bc, $4000
    ld a, $11
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
    ld bc, $a220
    ld a, [bc]
    ld de, $c0a0
    ld [de], a
    ld de, $c0a0
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a221
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $0008
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a222
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $000c
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a223
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $0010
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a224
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $0014
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a220
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $0018
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a221
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $001c
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a222
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $0020
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a223
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $0024
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a224
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $0028
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a210
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $0029
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a211
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $002a
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a212
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $002b
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a213
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld bc, $4000
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call Call_001_47a7
    add sp, $01
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
    ld hl, $ca0f
    push hl
    call Call_000_1985
    add sp, $06
    ld hl, sp+$05
    ld c, l
    ld b, h
    push bc
    ld hl, $0030
    push hl
    ld hl, $c0a0
    push hl
    ld hl, $ca0f
    push hl
    call Call_000_1963
    add sp, $08

Jump_001_672f:
    ld hl, $ca0f
    push hl
    call Call_000_19a1
    add sp, $02

Jump_001_6738:
    add sp, $0b
    ret


    ld l, $20
    jr nz, jr_001_673f

jr_001_673f:
    ld l, $2e
    jr nz, jr_001_6743

jr_001_6743:
    ld l, $2e
    ld l, $00
    push af
    push af
    push af
    push af
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, $016c
    push hl
    ld hl, $7d25
    push hl
    ld a, $23
    push af
    inc sp
    call Call_000_27ba
    add sp, $05
    ld hl, $0505
    push hl
    ld a, $0a
    push af
    inc sp
    ld hl, $6894
    push hl
    call Call_000_08b7
    add sp, $05
    ld hl, sp+$12
    ld a, [hl]
    sub $01
    jp nz, Jump_001_6784

    jr jr_001_6787

Jump_001_6784:
    jp Jump_001_67d0


jr_001_6787:
    ld hl, $0a05
    push hl
    ld a, $09
    push af
    inc sp
    ld hl, $689f
    push hl
    call Call_000_08b7
    add sp, $05
    ld a, $0d
    push af
    inc sp
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
    call Call_000_29c9
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
    ld hl, $68a9
    push hl
    call Call_001_643a
    add sp, $06
    jp Jump_001_6891


Jump_001_67d0:
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call Call_000_2791
    add sp, $03
    ld hl, $016a
    push hl
    ld hl, $505d
    push hl
    ld a, $27
    push af
    inc sp
    call Call_000_27ba
    add sp, $05
    ld hl, $016a
    push hl
    ld hl, $7b5d
    push hl
    ld a, $52
    push af
    inc sp
    call Call_000_27ba
    add sp, $05
    ld hl, $0c05
    push hl
    ld a, $05
    push af
    inc sp
    ld hl, $68aa
    push hl
    call Call_000_08b7
    add sp, $05
    ld hl, $0c0a
    push hl
    ld a, $05
    push af
    inc sp
    ld hl, $68b0
    push hl
    call Call_000_08b7
    add sp, $05

Jump_001_6821:
    call Call_000_3a4a
    ld c, e
    ld b, $00
    ld a, c
    and $10
    jr nz, jr_001_682f

    jp Jump_001_6889


jr_001_682f:
    ld hl, $0a05
    push hl
    ld a, $09
    push af
    inc sp
    ld hl, $689f
    push hl
    call Call_000_08b7
    add sp, $05
    ld a, $0d
    push af
    inc sp
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
    call Call_000_29c9
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
    ld hl, $68a9
    push hl
    call Call_001_643a
    add sp, $06
    jp Jump_001_6891


Jump_001_6889:
    ld a, c
    and $20
    jr nz, jr_001_6891

    jp Jump_001_6821


Jump_001_6891:
jr_001_6891:
    add sp, $08
    ret


    ld b, d
    ld b, c
    ld b, e
    ld c, e
    ld d, l
    ld d, b
    ld d, e
    ld b, c
    ld d, [hl]
    ld b, l
    nop
    ld d, e
    ld h, c
    halt
    ld l, c
    ld l, [hl]
    ld h, a
    ld l, $2e
    ld l, $00
    nop
    ld e, e
    ld b, d
    ld e, l
    ld c, [hl]
    ld c, a
    nop
    ld e, e
    ld b, c
    ld e, l
    ld c, a
    ld c, e
    nop
    ld hl, $cc31
    ld [hl], $ee
    ld hl, $cc32
    ld [hl], $ee
    ld hl, $cc33
    call Call_000_20bb
    ld a, a
    ldh [rP1], a
    pop hl
    nop
    ldh [c], a
    nop
    db $e3
    nop
    db $e4
    nop
    push hl
    nop
    and $00
    rst RST_20
    nop
    add sp, $00
    jp hl


    nop
    ld [$eb00], a
    nop
    db $ec
    nop
    db $ed
    nop
    xor $00
    rst RST_28
    nop
    ldh a, [rP1]
    pop af
    nop
    ldh a, [c]
    nop
    di
    nop
    db $f4
    nop
    push af
    nop
    or $00
    ld hl, sp+$00
    ld sp, hl
    nop
    ld a, [$fb00]
    nop
    db $fc
    nop
    db $fd
    nop
    cp $00
    rst RST_38
    nop
    ld bc, $0301
    ld bc, $0105
    rlca
    ld bc, $0109
    dec bc
    ld bc, $010d
    rrca
    ld bc, $0111
    inc de
    ld bc, $0115
    rla
    ld bc, $0119
    dec de
    ld bc, $011d
    rra
    ld bc, $0121
    inc hl
    ld bc, $0125
    daa
    ld bc, $0129
    dec hl
    ld bc, $012d
    cpl
    ld bc, $0131
    inc sp
    ld bc, $0135
    scf
    ld bc, $013a
    inc a
    ld bc, $013e
    ld b, b
    ld bc, $7f42
    ld bc, HeaderNewLicenseeCode
    ld b, [hl]
    ld bc, HeaderROMSize
    ld c, e
    ld bc, HeaderComplementCheck
    ld c, a
    ld bc, $0151
    ld d, e
    ld bc, $0155
    ld d, a
    ld bc, $0159
    ld e, e
    ld bc, $015d
    ld e, a
    ld bc, $0161
    ld h, e
    ld bc, $0165
    ld h, a
    ld bc, $0169
    ld l, e
    ld bc, $016d
    ld l, a
    ld bc, $0171
    ld [hl], e
    ld bc, $0175
    ld [hl], a
    ld bc, $017a
    ld a, h
    ld bc, $017e
    add e
    ld bc, $0185
    adc b
    ld bc, $018c
    sub d
    ld bc, $0199
    and c
    ld bc, $01a3
    xor b
    ld bc, $01ad
    or b
    ld bc, $01b4
    or [hl]
    ld bc, $01b9
    cp l
    ld bc, $01c6
    ret


    ld bc, $01cc
    adc $01
    ret nc

    ld bc, $01d2
    call nc, $d601
    ld bc, $01d8
    jp c, $dc01

    ld bc, $01dd
    rst RST_18
    ld bc, $01e1
    db $e3
    ld bc, $01e5
    rst RST_20
    ld bc, $01e9
    db $eb
    ld bc, $ed7f
    ld bc, $01ef
    di
    ld bc, $01f5
    ei
    ld bc, $01fd
    rst RST_38
    ld bc, $0201
    inc bc
    ld [bc], a
    dec b
    ld [bc], a
    rlca
    ld [bc], a
    add hl, bc
    ld [bc], a
    dec bc
    ld [bc], a
    dec c
    ld [bc], a
    rrca
    ld [bc], a
    ld de, $1302
    ld [bc], a
    dec d
    ld [bc], a
    rla
    ld [bc], a
    or c
    inc bc
    or d
    inc bc
    or e
    inc bc
    or h
    inc bc
    or l
    inc bc
    or [hl]
    inc bc
    or a
    inc bc
    cp b
    inc bc
    cp c
    inc bc
    cp d
    inc bc
    cp e
    inc bc
    cp h
    inc bc
    cp l
    inc bc
    cp [hl]
    inc bc
    cp a
    inc bc
    ret nz

    inc bc
    pop bc
    inc bc
    jp $c403


    inc bc
    push bc
    inc bc
    add $03
    rst RST_00
    inc bc
    ret z

    inc bc
    ret


    inc bc
    jp z, $cb03

    inc bc
    call z, $cd03
    inc bc
    adc $03
    db $e3
    inc bc
    push hl
    inc bc
    rst RST_20
    inc bc
    jp hl


    inc bc
    db $eb
    inc bc
    jr nc, jr_001_6a37

    ld sp, $3204
    inc b

jr_001_6a37:
    inc sp
    inc b
    inc [hl]
    inc b
    dec [hl]
    inc b
    ld [hl], $04
    scf
    inc b
    jr c, jr_001_6a47

    add hl, sp
    inc b
    ld a, [hl-]
    ld a, a

jr_001_6a47:
    inc b
    dec sp
    inc b
    inc a
    inc b
    dec a
    inc b
    ld a, $04
    ccf
    inc b
    ld b, b
    inc b
    ld b, c
    inc b
    ld b, d
    inc b
    ld b, e
    inc b
    ld b, h
    inc b
    ld b, l
    inc b
    ld b, [hl]
    inc b
    ld b, a
    inc b
    ld c, b
    inc b
    ld c, c
    inc b
    ld c, d
    inc b
    ld c, e
    inc b
    ld c, h
    inc b
    ld c, l
    inc b
    ld c, [hl]
    inc b
    ld c, a
    inc b
    ld d, d
    inc b
    ld d, e
    inc b
    ld d, h
    inc b
    ld d, l
    inc b
    ld d, [hl]
    inc b
    ld d, a
    inc b
    ld e, b
    inc b
    ld e, c
    inc b
    ld e, d
    inc b
    ld e, e
    inc b
    ld e, h
    inc b
    ld e, [hl]
    inc b
    ld e, a
    inc b
    ld h, c
    inc b
    ld h, e
    inc b
    ld h, l
    inc b
    ld h, a
    inc b
    ld l, c
    inc b
    ld l, e
    inc b
    ld l, l
    inc b
    ld l, a
    inc b
    ld [hl], c
    inc b
    ld [hl], e
    inc b
    ld [hl], l
    inc b
    ld [hl], a
    inc b
    ld a, c
    inc b
    ld a, e
    inc b
    ld a, l
    inc b
    ld a, a
    inc b
    add c
    inc b
    sub c
    inc b
    sub e
    inc b
    sub l
    inc b
    sub a
    inc b
    sbc c
    inc b
    sbc e
    inc b
    sbc l
    inc b
    sbc a
    inc b
    and c
    inc b
    and e
    inc b
    and l
    inc b
    and a
    inc b
    ld a, a
    xor c
    inc b
    xor e
    inc b
    xor l
    inc b
    xor a
    inc b
    or c
    inc b
    or e
    inc b
    or l
    inc b
    or a
    inc b
    cp c
    inc b
    cp e
    inc b
    cp l
    inc b
    cp a
    inc b
    jp nz, $c404

    inc b
    ret z

    inc b
    pop de
    inc b
    db $d3
    inc b
    push de
    inc b
    rst RST_10
    inc b
    reti


    inc b
    db $db
    inc b
    db $dd
    inc b
    rst RST_18
    inc b
    pop hl
    inc b
    db $e3
    inc b
    push hl
    inc b
    rst RST_20
    inc b
    jp hl


    inc b
    db $eb
    inc b
    db $ed
    inc b
    rst RST_28
    inc b
    pop af
    inc b
    di
    inc b
    push af
    inc b
    ld sp, hl
    inc b
    ld h, c
    dec b
    ld h, d
    dec b
    ld h, e
    dec b
    ld h, h
    dec b
    ld h, l
    dec b
    ld h, [hl]
    dec b
    ld h, a
    dec b
    ld l, b
    dec b
    ld l, c
    dec b
    ld l, d
    dec b
    ld l, e
    dec b
    ld l, h
    dec b
    ld l, l
    dec b
    ld l, [hl]
    dec b
    ld l, a
    dec b
    ld [hl], b
    dec b
    ld [hl], c
    dec b
    ld [hl], d
    dec b
    ld [hl], e
    dec b
    ld [hl], h
    dec b
    ld [hl], l
    dec b
    halt
    dec b
    ld [hl], a
    dec b
    ld a, b
    dec b
    ld a, c
    dec b
    ld a, d
    dec b
    ld a, e
    dec b
    ld a, h
    dec b
    ld a, l
    ld a, a
    dec b
    ld a, [hl]
    dec b
    ld a, a
    dec b
    add b
    dec b
    add c
    dec b
    add d
    dec b
    add e
    dec b
    add h
    dec b
    add l
    dec b
    add [hl]
    dec b
    ld bc, $031e
    ld e, $05
    ld e, $07
    ld e, $09
    ld e, $0b
    ld e, $0d
    ld e, $0f
    ld e, $11
    ld e, $13
    ld e, $15
    ld e, $17
    ld e, $19
    ld e, $1b
    ld e, $1d
    ld e, $1f
    ld e, $21
    ld e, $23
    ld e, $25
    ld e, $27
    ld e, $29
    ld e, $2b
    ld e, $2d
    ld e, $2f
    ld e, $31
    ld e, $33
    ld e, $35
    ld e, $37
    ld e, $39
    ld e, $3b
    ld e, $3d
    ld e, $3f
    ld e, $41
    ld e, $43
    ld e, $45
    ld e, $47
    ld e, $49
    ld e, $4b
    ld e, $4d
    ld e, $4f
    ld e, $51
    ld e, $53
    ld e, $55
    ld e, $57
    ld e, $59
    ld e, $5b
    ld e, $5d
    ld e, $5f
    ld e, $61
    ld e, $63
    ld e, $65
    ld e, $67
    ld e, $69
    ld e, $6b
    ld e, $7f
    ld l, l
    ld e, $6f
    ld e, $71
    ld e, $73
    ld e, $75
    ld e, $77
    ld e, $79
    ld e, $7b
    ld e, $7d
    ld e, $7f
    ld e, $81
    ld e, $83
    ld e, $85
    ld e, $87
    ld e, $89
    ld e, $8b
    ld e, $8d
    ld e, $8f
    ld e, $91
    ld e, $93
    ld e, $95
    ld e, $97
    ld e, $99
    ld e, $9b
    ld e, $9d
    ld e, $9f
    ld e, $a1
    ld e, $a3
    ld e, $a5
    ld e, $a7
    ld e, $a9
    ld e, $ab
    ld e, $ad
    ld e, $af
    ld e, $b1
    ld e, $b3
    ld e, $b5
    ld e, $b7
    ld e, $b9
    ld e, $bb
    ld e, $bd
    ld e, $bf
    ld e, $c1
    ld e, $c3
    ld e, $c5
    ld e, $c7
    ld e, $c9
    ld e, $cb
    ld e, $cd
    ld e, $cf
    ld e, $d1
    ld e, $d3
    ld e, $d5
    ld e, $d7
    ld e, $d9
    ld e, $db
    ld e, $dd
    ld e, $df
    ld e, $e1
    ld e, $e3
    ld e, $e5
    ld e, $e7
    ld e, $e9
    ld e, $eb
    ld h, e
    ld e, $ed
    ld e, $ef
    ld e, $f1
    ld e, $f3
    ld e, $f5
    ld e, $f7
    ld e, $f9
    ld e, $70
    ld hl, $2171
    ld [hl], d
    ld hl, $2173
    ld [hl], h
    ld hl, $2175
    halt
    ld hl, $2177
    ld a, b
    ld hl, $2179
    ld a, d
    ld hl, $217b
    ld a, h
    ld hl, $217d
    ld a, [hl]
    ld hl, $217f
    ld b, c
    rst RST_38
    ld b, d
    rst RST_38
    ld b, e
    rst RST_38
    ld b, h
    rst RST_38
    ld b, l
    rst RST_38
    ld b, [hl]
    rst RST_38
    ld b, a
    rst RST_38
    ld c, b
    rst RST_38
    ld c, c
    rst RST_38
    ld c, d
    rst RST_38
    ld c, e
    rst RST_38
    ld c, h
    rst RST_38
    ld c, l
    rst RST_38
    ld c, [hl]
    rst RST_38
    ld c, a
    rst RST_38
    ld d, b
    rst RST_38
    ld d, c
    rst RST_38
    ld d, d
    rst RST_38
    ld d, e
    rst RST_38
    ld d, h
    rst RST_38
    ld d, l
    rst RST_38
    ld d, [hl]
    rst RST_38
    ld d, a
    rst RST_38
    ld e, b
    rst RST_38
    ld e, c
    rst RST_38
    ld e, d
    rst RST_38
    nop
    ld hl, $d00f
    call Call_000_20bb
    ld a, a
    ret nz

    nop
    pop bc
    nop
    jp nz, $c300

    nop
    call nz, $c500
    nop
    add $00
    rst RST_00
    nop
    ret z

    nop
    ret


    nop
    jp z, $cb00

    nop
    call z, $cd00
    nop
    adc $00
    rst RST_08
    nop
    ret nc

    nop
    pop de
    nop
    jp nc, $d300

    nop
    call nc, $d500
    nop
    sub $00
    ret c

    nop
    reti


    nop
    jp c, $db00

    nop
    call c, $dd00
    nop
    sbc $00
    ld a, b
    ld bc, $0100
    ld [bc], a
    ld bc, HeaderLogo
    ld b, $01
    ld [$0a01], sp
    ld bc, $010c
    ld c, $01
    db $10
    ld bc, $0112
    inc d
    ld bc, $0116
    jr jr_001_6d0b

    ld a, [de]

jr_001_6d0b:
    ld bc, $011c
    ld e, $01
    jr nz, jr_001_6d13

    ld [hl+], a

jr_001_6d13:
    ld bc, $0124
    ld h, $01
    jr z, jr_001_6d1b

    ld a, [hl+]

jr_001_6d1b:
    ld bc, $012c
    ld l, $01
    jr nc, jr_001_6d23

    ld [hl-], a

jr_001_6d23:
    ld bc, HeaderTitle
    ld [hl], $01
    add hl, sp
    ld bc, $013b
    dec a
    ld bc, $013f
    ld b, c
    ld a, a
    ld bc, $0143
    ld b, l
    ld bc, HeaderCartridgeType
    ld c, d
    ld bc, HeaderMaskROMVersion
    ld c, [hl]
    ld bc, $0150
    ld d, d
    ld bc, $0154
    ld d, [hl]
    ld bc, $0158
    ld e, d
    ld bc, $015c
    ld e, [hl]
    ld bc, $0160
    ld h, d
    ld bc, $0164
    ld h, [hl]
    ld bc, $0168
    ld l, d
    ld bc, $016c
    ld l, [hl]
    ld bc, $0170
    ld [hl], d
    ld bc, $0174
    halt
    ld bc, $0179
    ld a, e
    ld bc, $017d
    add d
    ld bc, $0184
    add a
    ld bc, $018b
    sub c
    ld bc, $0198
    and b
    ld bc, $01a2
    and a
    ld bc, $01ac
    xor a
    ld bc, $01b3
    or l
    ld bc, $01b8
    cp h
    ld bc, $01c4
    rst RST_00
    ld bc, $01ca
    call $cf01
    ld bc, $01d1
    db $d3
    ld bc, $01d5
    rst RST_10
    ld bc, $01d9
    db $db
    ld bc, $018e
    sbc $01
    ldh [rSB], a
    ldh [c], a
    ld bc, $01e4
    and $01
    add sp, $01
    ld [$7f01], a
    db $ec
    ld bc, $01ee
    pop af
    ld bc, $01f4
    ld a, [$fc01]
    ld bc, $01fe
    nop
    ld [bc], a
    ld [bc], a
    ld [bc], a
    inc b
    ld [bc], a
    ld b, $02
    ld [$0a02], sp
    ld [bc], a
    inc c
    ld [bc], a
    ld c, $02
    db $10
    ld [bc], a
    ld [de], a
    ld [bc], a
    inc d
    ld [bc], a
    ld d, $02
    sub c
    inc bc
    sub d
    inc bc
    sub e
    inc bc
    sub h
    inc bc
    sub l
    inc bc
    sub [hl]
    inc bc
    sub a
    inc bc
    sbc b
    inc bc
    sbc c
    inc bc
    sbc d
    inc bc
    sbc e
    inc bc
    sbc h
    inc bc
    sbc l
    inc bc
    sbc [hl]
    inc bc
    sbc a
    inc bc
    and b
    inc bc
    and c
    inc bc
    and e
    inc bc
    and h
    inc bc
    and l
    inc bc
    and [hl]
    inc bc
    and a
    inc bc
    xor b
    inc bc
    xor c
    inc bc
    xor d
    inc bc
    xor e
    inc bc
    adc h
    inc bc
    adc [hl]
    inc bc
    adc a
    inc bc
    ldh [c], a
    inc bc
    db $e4
    inc bc
    and $03
    add sp, $03
    ld [$1003], a
    inc b
    ld de, $1204
    inc b
    inc de
    inc b
    inc d
    inc b
    dec d
    inc b
    ld d, $04
    rla
    inc b
    jr jr_001_6e32

    add hl, de
    inc b
    ld a, [de]
    ld a, a

jr_001_6e32:
    inc b
    dec de
    inc b
    inc e
    inc b
    dec e
    inc b
    ld e, $04
    rra
    inc b
    jr nz, jr_001_6e43

    ld hl, $2204
    inc b

jr_001_6e43:
    inc hl
    inc b
    inc h
    inc b
    dec h
    inc b
    ld h, $04
    daa
    inc b
    jr z, jr_001_6e53

    add hl, hl
    inc b
    ld a, [hl+]
    inc b

jr_001_6e53:
    dec hl
    inc b
    inc l
    inc b
    dec l
    inc b
    ld l, $04
    cpl
    inc b
    ld [bc], a
    inc b
    inc bc
    inc b
    inc b
    inc b
    dec b
    inc b
    ld b, $04
    rlca
    inc b
    ld [$0904], sp
    inc b
    ld a, [bc]
    inc b
    dec bc
    inc b
    inc c
    inc b
    ld c, $04
    rrca
    inc b
    ld h, b
    inc b
    ld h, d
    inc b
    ld h, h
    inc b
    ld h, [hl]
    inc b
    ld l, b
    inc b
    ld l, d
    inc b
    ld l, h
    inc b
    ld l, [hl]
    inc b
    ld [hl], b
    inc b
    ld [hl], d
    inc b
    ld [hl], h
    inc b
    halt
    inc b
    ld a, b
    inc b
    ld a, d
    inc b
    ld a, h
    inc b
    ld a, [hl]
    inc b
    add b
    inc b
    sub b
    inc b
    sub d
    inc b
    sub h
    inc b
    sub [hl]
    inc b
    sbc b
    inc b
    sbc d
    inc b
    sbc h
    inc b
    sbc [hl]
    inc b
    and b
    inc b
    and d
    inc b
    and h
    inc b
    and [hl]
    inc b
    ld a, a
    xor b
    inc b
    xor d
    inc b
    xor h
    inc b
    xor [hl]
    inc b
    or b
    inc b
    or d
    inc b
    or h
    inc b
    or [hl]
    inc b
    cp b
    inc b
    cp d
    inc b
    cp h
    inc b
    cp [hl]
    inc b
    pop bc
    inc b
    jp $c704


    dec b
    ret nc

    inc b
    jp nc, $d404

    inc b
    sub $04
    ret c

    inc b
    jp c, $dc04

    inc b
    sbc $04
    ldh [rDIV], a
    ldh [c], a
    inc b
    db $e4
    inc b
    and $04
    add sp, $04
    ld [$ec04], a
    inc b
    xor $04
    ldh a, [rDIV]
    ldh a, [c]
    inc b
    db $f4
    inc b
    ld hl, sp+$04
    ld sp, $3205
    dec b
    inc sp
    dec b
    inc [hl]
    dec b
    dec [hl]
    dec b
    ld [hl], $05
    scf
    dec b
    jr c, jr_001_6f0d

    add hl, sp
    dec b
    ld a, [hl-]
    dec b
    dec sp

jr_001_6f0d:
    dec b
    inc a
    dec b
    dec a
    dec b
    ld a, $05
    ccf
    dec b
    ld b, b
    dec b
    ld b, c
    dec b
    ld b, d
    dec b
    ld b, e
    dec b
    ld b, h
    dec b
    ld b, l
    dec b
    ld b, [hl]
    dec b
    ld b, a
    dec b
    ld c, b
    dec b
    ld c, c
    dec b
    ld c, d
    dec b
    ld c, e
    dec b
    ld c, h
    dec b
    ld c, l
    ld a, a
    dec b
    ld c, [hl]
    dec b
    ld c, a
    dec b
    ld d, b
    dec b
    ld d, c
    dec b
    ld d, d
    dec b
    ld d, e
    dec b
    ld d, h
    dec b
    ld d, l
    dec b
    ld d, [hl]
    dec b
    nop
    ld e, $02
    ld e, $04
    ld e, $06
    ld e, $08
    ld e, $0a
    ld e, $0c
    ld e, $0e
    ld e, $10
    ld e, $12
    ld e, $14
    ld e, $16
    ld e, $18
    ld e, $1a
    ld e, $1c
    ld e, $1e
    ld e, $20
    ld e, $22
    ld e, $24
    ld e, $26
    ld e, $28
    ld e, $2a
    ld e, $2c
    ld e, $2e
    ld e, $30
    ld e, $32
    ld e, $34
    ld e, $36
    ld e, $38
    ld e, $3a
    ld e, $3c
    ld e, $3e
    ld e, $40
    ld e, $42
    ld e, $44
    ld e, $46
    ld e, $48
    ld e, $4a
    ld e, $4c
    ld e, $4e
    ld e, $50
    ld e, $52
    ld e, $54
    ld e, $56
    ld e, $58
    ld e, $5a
    ld e, $5c
    ld e, $5e
    ld e, $60
    ld e, $62
    ld e, $64
    ld e, $66
    ld e, $68
    ld e, $6a
    ld e, $7f
    ld l, h
    ld e, $6e
    ld e, $70
    ld e, $72
    ld e, $74
    ld e, $76
    ld e, $78
    ld e, $7a
    ld e, $7c
    ld e, $7e
    ld e, $80
    ld e, $82
    ld e, $84
    ld e, $86
    ld e, $88
    ld e, $8a
    ld e, $8c
    ld e, $8e
    ld e, $90
    ld e, $92
    ld e, $94
    ld e, $96
    ld e, $98
    ld e, $9a
    ld e, $9c
    ld e, $9e
    ld e, $a0
    ld e, $a2
    ld e, $a4
    ld e, $a6
    ld e, $a8
    ld e, $aa
    ld e, $ac
    ld e, $ae
    ld e, $b0
    ld e, $b2
    ld e, $b4
    ld e, $b6
    ld e, $b8
    ld e, $ba
    ld e, $bc
    ld e, $be
    ld e, $c0
    ld e, $c2
    ld e, $c4
    ld e, $c6
    ld e, $c8
    ld e, $ca
    ld e, $cc
    ld e, $ce
    ld e, $d0
    ld e, $d2
    ld e, $d4
    ld e, $d6
    ld e, $d8
    ld e, $da
    ld e, $dc
    ld e, $de
    ld e, $e0
    ld e, $e2
    ld e, $e4
    ld e, $e6
    ld e, $e8
    ld e, $ea
    ld h, e
    ld e, $ec
    ld e, $ee
    ld e, $f0
    ld e, $f2
    ld e, $f4
    ld e, $f6
    ld e, $f8
    ld e, $60
    ld hl, $2161
    ld h, d
    ld hl, $2163
    ld h, h
    ld hl, $2165
    ld h, [hl]
    ld hl, $2167
    ld l, b
    ld hl, $2169
    ld l, d
    ld hl, $216b
    ld l, h
    ld hl, $216d
    ld l, [hl]
    ld hl, $216f
    ld hl, $22ff
    rst RST_38
    inc hl
    rst RST_38
    inc h
    rst RST_38
    dec h
    rst RST_38
    ld h, $ff
    daa
    rst RST_38
    jr z, @+$01

    add hl, hl
    rst RST_38
    ld a, [hl+]
    rst RST_38
    dec hl
    rst RST_38
    inc l
    rst RST_38
    dec l
    rst RST_38
    ld l, $ff
    cpl
    rst RST_38
    jr nc, @+$01

    ld sp, $32ff
    rst RST_38
    inc sp
    rst RST_38
    inc [hl]
    rst RST_38
    dec [hl]
    rst RST_38
    ld [hl], $ff
    scf
    rst RST_38
    jr c, @+$01

    add hl, sp
    rst RST_38
    ld a, [hl-]
    rst RST_38
    nop
    ld hl, $d3f9
    call Call_000_20bb
    ld a, a
    ld h, c
    nop
    ld a, [de]
    inc bc
    ldh [rP1], a
    rla
    inc bc
    ld hl, sp+$00
    rlca
    inc bc
    rst RST_38
    nop
    ld bc, $7800
    ld bc, $0100
    jr nc, jr_001_70b4

    ld [hl-], a

jr_001_70b4:
    ld bc, $0106
    add hl, sp
    ld bc, $0110
    ld c, d
    ld bc, $012e
    ld a, c
    ld bc, $0106
    add b
    ld bc, $004d
    ld b, e
    ld [bc], a
    add c
    ld bc, $0182
    add d
    ld bc, $0184
    add h
    ld bc, $0186
    add a
    ld bc, $0187
    adc c
    ld bc, $018a
    adc e
    ld bc, $018b
    adc l
    ld bc, $018e
    adc a
    ld bc, $0190
    sub c
    ld bc, $0191
    sub e
    ld bc, $0194
    or $01
    sub [hl]
    ld bc, $0197
    sbc b
    ld bc, $0198
    dec a
    ld [bc], a
    sbc e
    ld bc, $019c
    sbc l
    ld bc, $0220
    sbc a
    ld bc, $01a0
    and b
    ld bc, $01a2
    and d
    ld bc, $01a4
    and h
    ld bc, $01a6
    and a
    ld bc, $01a7
    xor c
    ld bc, $7faa
    ld bc, $01ab
    xor h
    ld bc, $01ac
    xor [hl]
    ld bc, $01af
    xor a
    ld bc, $01b1
    or d
    ld bc, $01b3
    or e
    ld bc, $01b5
    or l
    ld bc, $01b7
    cp b
    ld bc, $01b8
    cp d
    ld bc, $01bb
    cp h
    ld bc, $01bc
    cp [hl]
    ld bc, $01f7
    ret nz

    ld bc, $01c1
    jp nz, $c301

    ld bc, $01c4
    push bc
    ld bc, $01c4
    rst RST_00
    ld bc, $01c8
    rst RST_00
    ld bc, $01ca
    rlc c
    jp z, $cd01

    ld bc, $0110
    db $dd
    ld bc, $0001
    adc [hl]
    ld bc, $01de
    ld [de], a
    ld bc, $01f3
    inc bc
    nop
    pop af
    ld bc, $01f4
    db $f4
    ld bc, $01f8
    jr z, jr_001_717f

    ld [hl+], a

jr_001_717f:
    ld [bc], a
    ld [de], a
    ld bc, $023a
    add hl, bc
    nop
    ld h, l
    inc l
    dec sp
    ld [bc], a
    dec sp
    ld [bc], a
    dec a
    ld [bc], a
    ld h, [hl]
    inc l
    ccf
    ld [bc], a
    ld b, b
    ld [bc], a
    ld b, c
    ld [bc], a
    ld b, c
    ld [bc], a
    ld b, [hl]
    ld [bc], a
    ld a, [bc]
    ld bc, $537f
    ld [bc], a
    ld b, b
    nop
    add c
    ld bc, $0186
    ld d, l
    ld [bc], a
    adc c
    ld bc, $018a
    ld e, b
    ld [bc], a
    adc a
    ld bc, $025a
    sub b
    ld bc, $025c
    ld e, l
    ld [bc], a
    ld e, [hl]
    ld [bc], a
    ld e, a
    ld [bc], a
    sub e
    ld bc, $0261
    ld h, d
    ld [bc], a
    sub h
    ld bc, $0264
    ld h, l
    ld [bc], a
    ld h, [hl]
    ld [bc], a
    ld h, a
    ld [bc], a
    sub a
    ld bc, $0196
    ld l, d
    ld [bc], a
    ld h, d
    inc l
    ld l, h
    ld [bc], a
    ld l, l
    ld [bc], a
    ld l, [hl]
    ld [bc], a
    sbc h
    ld bc, $0270
    ld [hl], c
    ld [bc], a
    sbc l
    ld bc, $0273
    ld [hl], h
    ld [bc], a
    sbc a
    ld bc, $0276
    ld [hl], a
    ld [bc], a
    ld a, b
    ld [bc], a
    ld a, c
    ld [bc], a
    ld a, d
    ld [bc], a
    ld a, e
    ld [bc], a
    ld a, h
    ld [bc], a
    ld h, h
    inc l
    ld a, [hl]
    ld [bc], a
    ld a, a
    ld [bc], a
    and [hl]
    ld bc, $0281
    add d
    ld [bc], a
    xor c
    ld bc, $0284
    add l
    ld [bc], a
    add [hl]
    ld [bc], a
    add a
    ld [bc], a
    xor [hl]
    ld bc, $0244
    or c
    ld bc, $01b2
    ld b, l
    ld [bc], a
    adc l
    ld [bc], a
    adc [hl]
    ld [bc], a
    adc a
    ld [bc], a
    sub b
    ld [hl], l
    ld [bc], a
    sub c
    ld [bc], a
    or a
    ld bc, $037b
    inc bc
    nop
    db $fd
    inc bc
    cp $03
    rst RST_38
    inc bc
    xor h
    inc bc
    inc b
    nop
    add [hl]
    inc bc
    adc b
    inc bc
    adc c
    inc bc
    adc d
    inc bc
    or c
    inc bc
    ld de, $c203
    inc bc
    ld [bc], a
    nop
    and e
    inc bc
    and e
    inc bc
    call nz, Call_000_0803
    inc bc
    call z, Call_000_0303
    nop
    adc h
    inc bc
    adc [hl]
    inc bc
    adc a
    inc bc
    ret c

    inc bc
    jr jr_001_7257

    ldh a, [c]

jr_001_7257:
    inc bc
    ld a, [bc]
    nop
    ld sp, hl
    inc bc
    di
    inc bc
    db $f4
    inc bc
    push af
    inc bc
    or $03
    rst RST_30
    inc bc
    rst RST_30
    inc bc
    ld sp, hl
    inc bc
    ld a, [$fa03]
    inc bc
    jr nc, jr_001_7274

    jr nz, jr_001_7275

    ld d, b
    inc b

jr_001_7274:
    db $10

jr_001_7275:
    rlca
    ld h, b
    inc b
    ld [hl+], a
    ld bc, $048a
    ld [hl], $01
    pop bc
    inc b
    ld c, $01
    rst RST_08
    inc b
    ld bc, $c000
    inc b
    ret nc

    inc b
    ld b, h
    ld bc, $0561
    ld h, $04
    nop
    nop
    nop
    ld hl, $d5eb
    call Call_000_20bb
    ld a, a
    ld a, l
    dec e
    ld bc, $6300
    inc l
    nop
    ld e, $96
    ld bc, $1ea0
    ld e, d
    ld bc, $1f00
    ld [$1006], sp
    rra
    ld b, $06
    jr nz, @+$21

    ld [$3006], sp
    rra
    ld [$4006], sp
    rra
    ld b, $06
    ld d, c
    rra
    rlca
    nop
    ld e, c
    rra
    ld d, d
    rra
    ld e, e
    rra
    ld d, h
    rra
    ld e, l
    rra
    ld d, [hl]
    rra
    ld e, a
    rra
    ld h, b
    rra
    ld [$7006], sp
    rra
    ld c, $00
    cp d
    rra
    cp e
    rra
    ret z

    rra
    ret


    rra
    jp z, $cb1f

    rra
    jp c, $db1f

    rra
    ld hl, sp+$1f
    ld sp, hl
    rra
    ld [$eb1f], a
    rra
    ld a, [$fb1f]
    rra
    add b
    rra
    ld [$9006], sp
    rra
    ld [$a006], sp
    rra
    ld [$b006], sp
    rra
    inc b
    nop
    cp b
    rra
    cp c
    rra
    or d
    rra
    cp h
    rra
    call z, $011f
    nop
    jp $d01f


    rra
    ld [bc], a
    ld b, $e0
    rra
    ld [bc], a
    ld b, $e5
    dec a
    rra
    ld bc, $ec00
    rra
    di
    rra
    ld bc, $fc00
    rra
    ld c, [hl]
    ld hl, $0001
    ld [hl-], a
    ld hl, $2170
    db $10
    ld [bc], a
    add h
    ld hl, $0001
    add e
    ld hl, $24d0
    ld a, [de]
    dec b
    jr nc, jr_001_7367

    cpl
    inc b
    ld h, b
    inc l
    ld [bc], a
    ld bc, $2c67
    ld b, $01
    ld [hl], l
    inc l
    ld [bc], a
    ld bc, $2c80
    ld h, h
    ld bc, $2d00
    ld h, $08
    ld b, c
    rst RST_38
    ld a, [de]
    inc bc
    nop
    nop
    nop
    ld hl, $d6a7
    call Call_000_20bb
    inc c
    rra
    inc e
    rra
    ld e, $1f
    ld e, $1f
    rra

jr_001_7367:
    ld e, $1f
    ld e, $1f
    nop
    ld hl, $d6b3
    call Call_000_20bb
    inc c
    rra
    dec e
    rra
    ld e, $1f
    ld e, $1f
    rra
    ld e, $1f
    ld e, $1f
    nop
    ld hl, $d6bf
    call Call_000_20bb
    ld [$016d], sp
    ld l, l
    ld bc, $016d
    ld l, [hl]
    ld bc, $c900
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
