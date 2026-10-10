; Disassembly of "updater-code.gb"
; This file was created with:
; mgbdis v3.0 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $002", ROMX[$4000], BANK[$2]

Jump_002_4000:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

jr_002_4005:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

jr_002_4015:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    xor d

jr_002_4021:
    sbc c
    db $30, $a1
    nop
    rlca
    jr nz, jr_002_4028

jr_002_4028:
    ld sp, $8961
    xor $33
    ld hl, $0f3c
    ld sp, $00a1
    adc c
    ld sp, $2f41
    ld [$c231], sp
    ld [bc], a
    ld hl, $9380
    jr nc, jr_002_4021

    rst RST_38
    rst RST_08
    jr nc, jr_002_4005

    nop
    add l
    ld sp, $0881
    add c
    ld [hl-], a
    ld bc, $1f00
    ld [hl-], a
    pop bc
    nop
    dec b
    ld [hl-], a
    pop hl
    nop
    inc b
    ld [hl-], a
    and c

jr_002_4058:
    nop
    ld c, $32
    ld h, c
    nop
    nop
    ld [hl-], a
    add c
    nop
    nop
    inc sp
    ld b, c
    jr jr_002_4058

    inc sp
    ld h, d
    nop
    nop
    nop
    nop
    jr nc, jr_002_4090

    nop
    nop
    nop
    nop
    jr nc, jr_002_4015

    nop
    ld bc, $6050
    nop
    ld bc, $a223
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_002_4090:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    jr nz, jr_002_4103

jr_002_4103:
    nop
    ld d, $40
    ld [bc], a
    jr z, jr_002_4109

jr_002_4109:
    nop
    ld de, $0090
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    and h
    nop
    nop
    inc d
    ld b, b
    nop
    xor d
    nop
    nop
    ld bc, $0010
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_002_4273:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $105e
    ld d, b
    jr nz, jr_002_4273

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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0910
    inc b
    nop
    db $10
    add b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_002_4476:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

Call_002_4483:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0741
    ld a, b
    nop
    inc l
    ld b, b
    ld [bc], a
    add b
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
    inc bc
    jr z, jr_002_4505

    ld c, b
    ret nz

    nop
    nop
    nop
    nop
    nop
    jr c, jr_002_4476

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_002_4505:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    dec b
    ld bc, $2887
    nop
    inc a
    jp $a880


    ld h, $01
    ld h, e
    jr c, jr_002_4565

    ld e, h
    pop bc
    add b
    ld c, b
    nop
    nop
    nop
    nop
    inc h
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    dec b
    ld bc, $2887
    nop
    inc a

jr_002_4565:
    jp $a880


    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld h, $01
    ld h, e
    jr c, jr_002_45e5

    inc e
    ld bc, $4880
    ld b, b
    ret z

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr nc, jr_002_45de

jr_002_45de:
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_002_45e5:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld b, b
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    inc b
    nop
    nop
    add b
    nop
    nop
    nop
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
    add hl, bc
    jr nz, jr_002_466c

jr_002_466c:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    stop
    nop
    inc b
    nop
    nop
    add b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld a, h
    ld d, b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add c
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add c
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add c
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add c
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add c
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add c
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add c
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add c
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0000
    nop
    add b
    nop
    nop
    nop
    ld bc, $0000
    nop
    add b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0000
    nop
    add b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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

jr_002_4a25:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_002_4a2d:
    nop
    nop
    nop
    nop
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
    add b
    ld b, b
    ld b, [hl]
    nop
    nop
    nop
    nop
    nop
    nop

jr_002_4a45:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    jr z, jr_002_4a25

    ld b, b
    ld b, [hl]
    nop
    ld h, c
    ld [bc], a
    inc b
    jr z, jr_002_4a2d

    ld b, b
    ld b, [hl]
    nop
    ld h, c
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
    inc b
    jr z, jr_002_4a45

    ld b, b
    ld b, [hl]
    nop
    ld h, c
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    add b
    ld b, b
    ld b, [hl]
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $6303
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ret nz

    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    ld [$0000], sp
    nop
    nop
    nop
    ld [bc], a
    nop
    nop
    db $e3
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0000
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    add b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    jr nz, jr_002_4de9

jr_002_4de9:
    add b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    jr nz, jr_002_4e03

jr_002_4e03:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    ld b, b
    nop
    nop
    nop
    nop
    nop
    nop
    add b
    nop
    ld bc, $0004
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    add b
    nop
    nop
    nop
    nop
    nop
    add b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld b, $00
    nop
    nop
    ld [$0000], sp
    nop
    ld c, $00
    nop
    nop
    inc bc
    nop
    nop
    nop
    nop
    nop
    nop
    ld d, b
    nop
    nop
    inc b
    nop
    nop
    nop
    nop
    sub b
    nop
    nop
    nop
    nop
    ld b, $00
    nop
    nop
    ld [$0040], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld e, $00
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    dec b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    dec b
    ld b, b
    nop
    nop
    ld [$0000], sp
    nop
    dec b
    nop
    stop
    nop
    nop
    ld [bc], a
    nop
    nop
    nop
    ld [hl], b
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    dec b
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    dec b
    nop
    nop
    nop
    inc d
    nop
    ld [$0000], sp
    nop
    nop
    jr nz, jr_002_5245

jr_002_5245:
    nop
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_002_524d

jr_002_524d:
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0000
    nop
    dec bc
    nop
    nop
    nop
    inc bc
    nop
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
    stop
    nop
    nop
    nop
    ret nz

    nop
    nop
    nop
    nop
    add hl, bc
    nop
    nop
    nop
    dec bc
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0000
    nop
    nop
    nop
    nop
    nop
    ld c, $00
    nop
    nop
    nop
    ld b, b
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
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld a, [bc]
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
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
    nop
    nop
    ld bc, $0000
    nop
    nop
    nop
    ld bc, $0000
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$2000], sp
    add b
    nop
    nop
    nop
    nop
    nop
    add b
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
    ld bc, $0040
    nop
    nop
    nop
    nop
    nop
    add b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_002_5547

jr_002_5547:
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
    nop
    nop
    nop
    nop
    ld [$0000], sp
    nop
    nop
    nop
    ld b, b
    nop
    nop
    nop
    add b
    ld bc, $0000
    nop
    nop
    inc b
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
    inc b
    nop
    db $10
    add b
    nop
    inc b
    nop
    nop
    nop
    add b
    nop
    ld b, b
    ld bc, $0100
    nop
    inc b
    nop
    inc b
    nop
    ld bc, $0004
    inc c
    nop
    nop
    ld [$0000], sp
    nop
    add b
    nop
    nop
    nop
    ld [$0080], sp
    ld [bc], a
    nop
    nop
    ld bc, $0000
    ld [bc], a
    add b
    ld b, b
    nop
    inc b
    add b
    ld b, h
    nop
    ld b, b
    nop
    nop
    nop
    ld b, b
    nop
    ld b, b
    inc b
    add b
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
    nop
    add b
    nop
    add b
    nop
    nop
    add b
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
    nop
    nop
    nop
    nop
    ld [de], a
    ld bc, $0000
    nop
    nop
    nop
    add b
    ld b, b
    nop
    nop
    nop
    nop
    nop
    ld b, b
    ld bc, $0000
    nop
    add b
    nop
    ld bc, $2000
    nop
    nop
    nop
    nop
    add b
    ld b, c
    nop
    nop
    nop
    add b
    nop
    nop
    add b
    sub c
    nop
    add b
    nop
    nop
    nop
    nop
    nop
    nop
    ld b, b
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
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
    nop
    nop
    ld a, [bc]
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
    stop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    inc b
    dec c
    ld a, [bc]
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld d, b
    nop
    ld [$0000], sp
    ld [$000c], sp
    nop
    nop
    jr nz, jr_002_56a5

jr_002_56a5:
    ld [$0008], sp
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
    ld [$0d00], sp
    nop
    nop
    nop
    nop
    nop
    add hl, bc
    nop
    add hl, bc
    nop
    nop
    nop
    nop
    nop
    nop
    ld a, [bc]
    nop
    nop
    add hl, bc
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
    inc b
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$0010], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    dec b
    ld a, [bc]
    nop
    nop
    dec b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    inc c
    nop
    nop
    nop
    nop
    nop
    dec c
    ld d, b
    nop
    nop
    nop
    nop
    nop
    nop
    ld b, b
    nop
    nop
    jr nc, jr_002_5773

    nop
    nop
    nop
    nop
    nop
    jr nc, jr_002_574a

jr_002_574a:
    nop
    nop
    nop
    nop
    nop
    ld a, [bc]
    nop
    nop
    nop
    nop
    ld h, b
    ld h, b
    ld [$0030], sp
    nop
    nop
    nop
    ld h, b
    nop
    stop
    nop
    ld bc, $0000
    ld h, b
    ld h, b
    nop
    ld h, b
    nop
    nop
    nop
    nop
    ld d, b
    jr nc, jr_002_576f

jr_002_576f:
    nop
    nop
    ld a, [bc]
    nop

jr_002_5773:
    nop
    nop
    jr nc, jr_002_5777

jr_002_5777:
    nop
    nop
    nop
    ld d, b
    nop
    nop
    ld b, $00
    nop
    nop
    nop
    nop
    stop
    nop
    nop
    jr nc, jr_002_578d

    nop
    ld b, $00
    nop

jr_002_578d:
    inc c
    nop
    add hl, bc
    nop
    ld h, d
    nop
    nop
    nop
    nop
    nop
    nop
    inc c
    nop
    nop
    ld a, $00
    inc c
    nop
    nop
    ld h, b
    stop
    ld de, $0008
    ld [$5c00], sp
    nop
    ld l, b
    nop
    inc c
    inc c
    ld h, b
    ld [$0060], sp
    ld b, $01
    nop
    nop
    jr nc, @-$74

    nop
    ld bc, $1000
    nop
    ld [$0100], sp
    inc c
    nop
    ld bc, $3068
    jr nc, jr_002_57c7

jr_002_57c7:
    inc c
    db $10
    jr jr_002_583c

    jr nc, jr_002_583d

    nop
    nop
    jr nc, jr_002_57d1

jr_002_57d1:
    jr nc, @+$0a

    jr nc, jr_002_57d5

jr_002_57d5:
    nop
    ld [hl], b
    nop
    nop
    nop
    stop
    nop
    ld h, b
    nop
    jr nc, jr_002_5841

    db $10
    ld h, b
    nop
    jr nc, jr_002_57e6

jr_002_57e6:
    nop
    ld bc, $0000
    nop
    jr nz, jr_002_57ed

jr_002_57ed:
    nop
    nop
    nop
    nop
    nop
    ld bc, $0808
    nop
    nop
    nop
    nop
    ld b, $00
    jr nc, jr_002_57fd

jr_002_57fd:
    nop
    nop
    ld h, b
    nop
    jr nc, @+$0a

    nop
    nop
    nop
    jr nc, jr_002_5808

jr_002_5808:
    inc c
    nop
    stop
    nop
    ld c, $00
    ld a, [hl-]
    jr c, jr_002_5812

jr_002_5812:
    nop
    nop
    jr nc, jr_002_5816

jr_002_5816:
    nop
    ld hl, $0014
    jr nc, jr_002_581c

jr_002_581c:
    nop
    nop
    ld [hl], b
    ld a, [bc]
    nop
    stop
    nop
    nop
    nop
    nop
    jr nc, jr_002_5829

jr_002_5829:
    nop
    nop
    nop
    nop
    ld h, b
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
    nop

jr_002_583c:
    nop

jr_002_583d:
    nop
    nop
    nop
    nop

jr_002_5841:
    nop
    nop
    nop
    nop
    jr nz, jr_002_5847

jr_002_5847:
    nop
    nop
    nop
    nop
    nop
    nop
    ld [bc], a
    nop
    jr nc, jr_002_5851

jr_002_5851:
    ld [bc], a
    nop
    nop
    nop
    jr nz, jr_002_5857

jr_002_5857:
    nop
    nop
    nop
    nop
    nop
    nop
    ld hl, $0000
    nop
    nop
    nop
    ld bc, $0000
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$0010], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    stop
    nop
    nop
    nop
    nop
    ld bc, $0040
    nop
    ld bc, $0008
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0000
    nop
    nop
    nop
    jr nz, jr_002_5897

jr_002_5897:
    stop
    nop
    nop
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
    inc b
    nop
    nop
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
    ld b, b
    nop
    nop
    nop
    nop
    nop
    nop
    stop
    nop
    ld [$0000], sp
    nop
    nop
    nop
    ld [bc], a
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld b, b
    ld bc, $0000
    nop
    nop

jr_002_58da:
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
    nop
    nop
    nop

jr_002_58ea:
    nop
    nop
    nop
    nop
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
    ld bc, $0200
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0030
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    jr nz, jr_002_58da

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$4000], sp
    nop
    ld [$0000], sp
    jr nz, jr_002_58ea

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    adc b
    nop
    nop
    nop
    nop
    nop
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
    nop
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
    nop
    nop
    ld [$0010], sp
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
    inc b
    nop
    nop
    nop
    nop
    nop
    ld b, b
    nop
    add b
    nop
    nop
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
    nop
    add b
    nop
    ld bc, $0020
    nop
    nop
    nop
    add b
    ld bc, $0000
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_002_59d2

jr_002_59d2:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0000
    add b
    nop
    nop
    inc l
    nop
    ld [$0000], sp
    nop
    nop
    nop
    jr nz, jr_002_59f2

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_002_59f2:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    ld [$0c00], sp
    nop
    nop
    nop
    nop
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
    ld b, b
    nop
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_002_5a4a

jr_002_5a4a:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_002_5a6e

jr_002_5a6e:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_002_5a7e

jr_002_5a7e:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    jr nz, jr_002_5ad4

jr_002_5ad4:
    jr nz, jr_002_5ad6

jr_002_5ad6:
    nop
    nop
    nop
    nop
    jr nz, jr_002_5adc

jr_002_5adc:
    nop
    nop
    nop
    nop
    nop
    nop
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
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_002_5af4

jr_002_5af4:
    jr nz, jr_002_5af6

jr_002_5af6:
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
    nop
    nop
    nop
    inc b
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_002_5b5e

jr_002_5b5e:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
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
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    ld a, [$ffd8]
    rst RST_38
    ld a, [$eed8]
    db $e4
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    ld a, [$d872]
    ld a, [$ffff]
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    di
    rst RST_38
    rst RST_38
    ld a, [$bf3a]
    or b
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_08
    rst RST_38
    rst RST_18
    add b
    ld hl, sp+$70
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    ldh a, [rIF]
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    ld l, a
    or $ff
    cp $0f
    ldh a, [$ffc3]
    inc a
    rst RST_38
    rst RST_38
    ld l, a
    or $ff
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    nop
    ldh a, [rIE]
    rst RST_38
    rst RST_38
    ld b, b
    rrca
    rst RST_38
    ldh [$fff0], a
    rst RST_38
    ldh a, [$ffcc]
    adc h
    rst RST_38
    nop
    xor [hl]
    and d
    jr nc, jr_002_5c60

jr_002_5c60:
    xor d
    xor h
    rst RST_38
    nop
    ei
    ld [$00ff], sp
    xor [hl]
    and d
    di
    ret nz

    di
    ret nz

    di
    ret nz

    rst RST_38
    nop
    rst RST_38
    ei
    and b
    add b
    rst RST_38
    nop
    cp $10
    nop
    nop
    nop
    nop
    jr nz, jr_002_5c91

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
    ld bc, $3020

jr_002_5c91:
    nop
    ld bc, $7024
    nop
    ld bc, $7024
    nop
    ld bc, $3020
    nop
    ld bc, $3020
    nop
    ld bc, $7024
    nop
    ld bc, $7024
    nop
    ld bc, $3020
    nop
    add hl, bc
    jr nz, jr_002_5ce1

    nop
    add hl, bc
    inc h
    ld a, b
    nop
    ld d, $06
    ld c, c
    ld b, h
    ld d, $06
    ld c, c
    ld b, h
    ld d, $06
    ld c, c
    ld b, h
    ld d, $06
    ld c, c
    ld b, h
    ld d, $06
    ld c, c
    ld b, h
    ld d, $06
    ld c, c
    ld b, h
    dec c
    ld h, $f8
    nop
    dec c
    ld h, $71
    nop
    dec c
    ld [hl+], a
    ld sp, $0100
    inc h
    ld [hl], b
    nop
    ld bc, $7024

jr_002_5ce1:
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
    jr nz, jr_002_5d21

    nop
    add hl, bc
    inc h
    ld a, b
    nop
    ld bc, $3020
    nop
    ld bc, $7024
    nop
    ld bc, $7024
    nop
    ld bc, $3020
    nop
    ld bc, $7024
    nop
    ld bc, $3000
    nop
    ld bc, $3020
    nop
    ld bc, $3020
    nop
    ld bc, $7024
    nop
    ld bc, $7024
    nop
    ld bc, $7024

jr_002_5d21:
    nop
    ld bc, $7024
    nop
    add hl, bc
    jr nz, jr_002_5d59

    nop
    ld bc, $7024
    nop
    nop
    inc b
    ld a, b
    nop
    ld bc, $7824
    nop
    ld bc, $3020
    nop
    ld bc, $7024
    nop
    ld bc, $7024
    nop
    ld bc, $3020
    nop
    ld bc, $3020
    nop
    ld bc, $7024
    nop
    ld bc, $7024
    nop
    ld bc, $7024
    nop
    ld bc, $7024

jr_002_5d59:
    nop
    ld bc, $7024
    nop
    ld bc, $3020
    nop
    ld bc, $3020
    nop
    ld bc, $7020
    nop
    ld bc, $3020
    nop
    ld [de], a
    inc b
    ld a, b
    inc b
    nop
    inc b
    ld a, b
    nop
    ld [de], a
    inc b
    ld a, b
    inc b
    ld [de], a
    inc b
    ld a, b
    inc b
    inc de
    ld hl, $0430
    ld [bc], a
    ld bc, $0430
    nop
    inc b
    ld a, b
    nop
    ld [de], a
    inc b
    ld a, b
    inc b
    nop
    nop
    nop
    db $10
    and b
    ld de, $0010
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
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    ld bc, $4024
    nop
    ld bc, $0020
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
    ld bc, $4026
    nop
    add hl, bc
    ld h, $48
    nop
    ld [de], a
    ld b, $48
    inc b
    ld bc, $4026
    nop
    add hl, bc
    ld [hl+], a
    nop
    nop
    ld bc, $4026
    nop
    ld bc, $0020
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
    ld bc, $4024
    nop
    ld bc, $0020
    nop
    add hl, bc
    jr nz, jr_002_5e01

jr_002_5e01:
    nop
    ld bc, $0020
    nop
    ld [de], a
    inc b
    ld c, b
    inc b
    ld bc, $4024
    nop
    nop
    inc b
    ld c, b
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    ld bc, $0020
    nop
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    nop
    inc b
    ld c, b
    nop
    inc de
    jr nz, jr_002_5e29

jr_002_5e29:
    inc b
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    ld bc, $0020
    nop
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    ld bc, $0020
    nop
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    ld bc, $0020
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
    ld [de], a
    inc b
    ld c, b
    inc b
    ld bc, $0000
    nop
    ld bc, $0020
    nop
    ld [de], a
    inc b
    ld c, b
    inc b
    ld [de], a
    inc b
    ld c, b
    inc b
    inc de
    inc h
    ld c, b
    inc b
    ld bc, $0020
    nop
    ld [de], a
    inc b
    ld c, b
    inc b
    ld [de], a
    inc b
    ld c, b
    inc b
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
    ld bc, $0000
    nop
    nop
    nop
    ld [$0008], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    xor $f0
    db $fc
    xor d
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    ei
    ret z

    db $fc
    cp b
    push de
    ld e, l
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    db $dd
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
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    xor $2e
    xor a
    call z, $ffff
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    xor $2e
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    ldh a, [$fffa]
    ret z

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    nop
    inc c
    cp e
    dec bc
    db $dd
    ldh a, [$fff7]
    call nz, $ffff
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_18
    rst RST_38
    rst RST_38
    di
    rst RST_38
    ld [hl], d
    xor b
    and b
    inc sp
    rrca
    adc b
    ld [$ffff], sp
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    call z, $f0c8
    ret nz

jr_002_5f56:
    rst RST_38
    rst RST_38
    ld a, l
    cp [hl]
    rst RST_38
    ccf
    rst RST_38
    rst RST_38

jr_002_5f5e:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

jr_002_5f66:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

jr_002_5f6e:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

jr_002_5f76:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

jr_002_5f7e:
    call z, $ffc8
    rst RST_38
    rst RST_38
    db $fc
    ret z

    call z, $ccc8
    db $fd

jr_002_5f89:
    jr nz, jr_002_5f89

    cp d
    ld d, h
    db $10

jr_002_5f8e:
    ld [bc], a
    nop
    xor $ce
    rst RST_08
    rst RST_38
    call z, $ffc8
    nop
    cp d
    adc d
    rst RST_38
    nop
    cp $02

jr_002_5f9e:
    call z, $cca0
    ldh a, [rIE]

jr_002_5fa3:
    rst RST_38
    rst RST_38
    rst RST_38

jr_002_5fa6:
    rst RST_38
    nop
    xor h
    xor d
    rst RST_38
    nop
    cp $02

jr_002_5fae:
    rst RST_38
    rst RST_28
    ldh [rP1], a
    rst RST_38
    rst RST_28
    ldh [rP1], a

jr_002_5fb6:
    nop
    nop
    nop
    ld b, b
    ld b, [hl]
    ret nz

    nop
    nop
    ld [$0800], sp
    ld a, [bc]
    nop
    nop
    nop
    nop

jr_002_5fc6:
    nop
    nop
    nop
    nop
    ld hl, $2814
    add b

jr_002_5fce:
    ld bc, $090c
    nop
    add hl, bc
    sub b
    jr z, jr_002_5f56

    ld bc, $0914
    jr nz, @+$1c

    nop
    jr z, jr_002_5f5e

jr_002_5fde:
    ld bc, $1d1a
    jr nz, jr_002_5fa3

    nop
    jr z, jr_002_5f66

jr_002_5fe6:
    ld bc, $0014
    inc h
    nop
    nop
    jr z, jr_002_5f6e

jr_002_5fee:
    ld bc, $0314
    di
    stop
    jr z, jr_002_5f76

    inc b
    ld a, [bc]
    inc sp
    and d
    ld [bc], a
    nop
    jr z, jr_002_5f7e

jr_002_5ffe:
    inc b
    ld a, [bc]
    ld sp, $02e3
    nop
    jr z, @-$7e

jr_002_6006:
    inc b
    ld a, [bc]
    ld bc, $82a2
    nop
    jr z, jr_002_5f8e

    ld bc, $1314
    nop
    ld h, a
    db $10
    jr z, @-$7e

jr_002_6016:
    ld bc, $1614
    jr nz, @+$06

    inc c
    jr z, jr_002_5f9e

jr_002_601e:
    ld bc, $3314
    ldh a, [c]
    ld d, b
    sub b
    jr z, jr_002_5fa6

jr_002_6026:
    ld bc, $3514
    rst RST_08
    ld b, b
    nop
    jr z, jr_002_5fae

    ld bc, $3114
    rst RST_20
    sub b
    inc b
    jr z, jr_002_5fb6

    ld bc, $2214
    add d
    ld [$28ac], sp
    add b

jr_002_603e:
    ld bc, $1514
    ld a, [hl+]
    nop
    sub b
    jr z, jr_002_5fc6

jr_002_6046:
    inc b
    inc b
    inc b
    nop
    dec c
    db $10
    jr z, jr_002_5fce

    ld bc, $2014
    push bc
    ld d, b
    jr z, @+$2a

    add b
    ld bc, $2414
    add hl, bc
    inc h
    inc l
    jr z, jr_002_5fde

    ld bc, $2214
    adc e
    daa
    adc h
    jr z, jr_002_5fe6

    ld bc, $0114
    db $e4
    ld c, $9c
    jr z, jr_002_5fee

    ld bc, $0c14
    adc b
    call z, $2808
    add b
    ld bc, $0914
    ld b, b
    adc b
    ret nz

    jr z, jr_002_5ffe

    ld bc, $3314
    ldh a, [rTMA]
    add h
    jr z, jr_002_6006

    ld bc, $3414
    db $eb
    nop
    ld [$8028], sp
    ld bc, $0014
    inc bc
    ld h, $0c
    jr z, jr_002_6016

    ld bc, $0214
    add c
    adc b
    adc b
    jr z, jr_002_601e

    ld bc, $1014
    ld a, [hl+]
    ld [hl], $c0
    jr z, jr_002_6026

    ld bc, $0114
    inc h
    call $288c
    add b
    ld bc, $0214
    db $10
    ld bc, $48ac
    add b
    ld bc, $0014
    ld d, c
    sub $00
    jr z, jr_002_603e

    nop
    ld [bc], a
    nop
    nop
    adc l
    inc e
    jr z, jr_002_6046

    ld bc, $0414
    ld bc, $0000
    nop
    nop
    nop
    sbc c
    ld [bc], a
    nop
    ld [$0006], sp
    stop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add e
    inc d
    inc b
    nop
    nop
    ld [$8000], sp
    add e
    inc b
    inc b
    nop
    nop
    jr nz, jr_002_60ed

jr_002_60ed:
    call nz, Call_002_4483
    inc b
    nop
    nop
    nop
    jr nz, @-$1e

    adc e
    inc c
    inc b
    nop
    nop
    jr nz, jr_002_6125

    ld b, b
    add e
    inc b
    inc b
    nop
    nop
    jr nz, jr_002_6105

jr_002_6105:
    pop de
    add e
    inc b
    inc b
    nop
    nop
    ld [$8621], sp
    and e
    inc b
    inc b
    nop
    nop
    ld [$8626], sp
    add a
    inc b
    inc b
    nop
    nop
    ld [$8634], sp
    sub a
    inc b
    inc b
    nop
    nop
    jr nz, jr_002_6146

jr_002_6125:
    pop bc
    adc e
    inc b
    inc b
    nop
    nop
    jr nz, jr_002_614d

    pop hl
    and e
    inc d
    inc b
    nop
    nop
    jr nz, jr_002_6156

    ret


    add e
    inc d
    inc b
    nop
    nop
    jr nz, jr_002_615f

    pop bc
    sub e
    inc b
    inc b
    nop
    nop
    jr nz, jr_002_6179

    ret


jr_002_6146:
    add e
    inc d
    inc b
    nop
    nop
    jr nz, @+$23

jr_002_614d:
    sub c
    add e
    inc c
    inc b
    nop
    nop
    jr nz, jr_002_6177

    pop hl

jr_002_6156:
    adc e
    inc b
    inc b
    nop
    nop
    jr z, jr_002_617d

    nop
    add e

jr_002_615f:
    inc d
    inc b
    nop
    nop
    jr nz, jr_002_6199

    ret


    add e
    inc b
    inc b
    nop
    nop
    jr nz, jr_002_618d

    ld bc, $048b
    inc b
    nop
    nop
    jr nz, @+$23

    add c
    add e

jr_002_6177:
    inc e
    inc b

jr_002_6179:
    nop
    nop
    jr nz, jr_002_618d

jr_002_617d:
    jp Jump_000_148b


    inc b
    nop
    nop
    jr nz, jr_002_61a5

    push bc
    sub e
    ld d, h
    inc b
    nop
    nop
    jr nz, jr_002_61ae

jr_002_618d:
    push de
    adc e
    inc h
    inc b
    nop
    nop
    jr nz, jr_002_61b6

    jp Jump_002_64ab


    inc b

jr_002_6199:
    nop
    nop
    jr nz, jr_002_61cd

    pop hl
    add e
    inc h
    inc b
    nop
    nop
    jr nz, jr_002_61a5

jr_002_61a5:
    add hl, bc
    add e
    inc h
    inc b
    nop
    nop
    jr nz, jr_002_61ad

jr_002_61ad:
    sub c

jr_002_61ae:
    jp Jump_000_041c


    nop
    nop
    jr nz, jr_002_61e6

    pop hl

jr_002_61b6:
    inc bc
    inc b
    inc b
    nop
    nop
    jr nz, jr_002_61cd

    ret nz

    adc e
    inc e
    inc b
    nop
    nop
    jr nz, jr_002_61e6

    pop de
    add e
    inc c
    inc b
    nop
    nop
    jr nz, jr_002_61cd

jr_002_61cd:
    ld d, c
    and d
    inc b
    inc b
    nop
    nop
    db $10
    inc [hl]
    add b
    adc e
    inc d
    inc b
    nop
    nop
    jr nz, jr_002_61ff

    db $e3
    ld [bc], a
    nop
    nop
    nop
    nop
    nop
    nop
    add b

jr_002_61e6:
    nop
    jr jr_002_61e9

jr_002_61e9:
    inc b
    nop
    nop
    nop
    jr nz, jr_002_61ef

jr_002_61ef:
    nop
    ld b, h
    nop
    nop
    ld bc, $c3c0
    nop
    ret z

    ret nz

    nop
    nop
    inc bc
    nop
    ld [bc], a
    rst RST_08

jr_002_61ff:
    nop
    ret nz

    nop
    nop
    nop
    ret nz

    ret nz

    nop
    ret nz

    db $d3
    nop
    nop
    nop
    ld b, e
    nop
    rst RST_00
    nop
    ret


    ret nz

    nop
    add b
    ret nz

    pop bc
    inc bc
    ldh [$ffd3], a
    nop
    nop
    add c
    nop
    ret nz

    nop
    nop
    ld d, e
    call nz, RST_00
    ret nz

    inc bc
    ld [hl+], a
    add b
    db $d3
    nop
    nop
    nop
    nop
    ld b, a
    inc de
    ret nz

    ld bc, $0004
    ld b, a
    inc de
    add e
    pop bc
    nop
    sub e
    and b
    nop
    inc bc
    inc de
    rst RST_00
    add l
    ret nz

    add b
    nop
    nop
    jp $c223


    add b
    ldh [$ffeb], a
    ret nz

    nop
    inc de
    ret nz

    nop
    nop
    inc bc
    rst RST_08
    nop
    nop
    nop
    nop
    nop
    add c
    ret nz

    rst RST_00
    ret nz

    nop
    inc bc
    inc hl
    add b
    jp $81c4


    nop
    nop
    inc bc
    ld [hl+], a
    bit 4, e
    nop
    add a
    nop
    nop
    ret z

    ldh [c], a
    dec b
    ret nz

    nop
    ret nz

    call nz, RST_00
    nop
    nop
    db $e3
    ret z

    db $e3
    nop
    nop
    ret nz

    nop
    nop
    ret


    ld b, h
    rst RST_00
    call nz, RST_00
    ld bc, $80e2
    nop
    set 0, b
    ret nz

    ret nz

    add b
    inc bc
    jr nz, jr_002_6293

    inc de
    ldh [rP1], a

jr_002_6293:
    ld b, a
    ret nz

    ret z

    nop
    ret nz

    res 0, b
    nop
    inc de
    ret nz

    ld bc, $c8c0
    and e
    ldh [rP1], a
    ld b, a
    nop
    ret nz

    ld [$00e0], a
    nop
    nop
    inc bc
    nop
    nop
    pop bc
    ret z

    ret nz

    nop
    ret nz

    ret nz

    ret nz

    ld [bc], a
    ld b, b
    ld bc, $c807
    nop
    add e
    inc de
    jp nz, $c400

    nop
    ldh [rP1], a
    pop bc
    ret nz

    rst RST_00
    pop bc
    nop
    dec b
    jr nz, jr_002_62cb

jr_002_62cb:
    di
    add e
    inc bc
    inc bc
    nop
    ld h, b
    ld [$0100], sp
    ld b, b
    nop
    nop
    add b
    inc hl
    nop
    nop
    ret z

    ldh [c], a
    nop
    db $e3
    nop
    ld [hl+], a
    nop
    nop
    add c
    nop
    ldh [rP1], a
    call nz, Call_000_0023

jr_002_62ea:
    nop
    add e
    ret nz

    ld b, l
    ld [hl+], a
    nop
    nop
    nop
    nop
    add b
    add c
    nop
    nop
    nop
    nop
    nop
    nop
    dec c
    nop
    stop
    nop
    nop
    nop
    inc b
    nop
    ld b, b
    add b
    nop
    ld b, b
    jr nz, jr_002_635a

    nop
    nop
    inc b
    ld bc, $4000
    nop
    inc b
    nop
    nop
    stop
    ld b, b
    nop
    jr nz, jr_002_632a

    nop
    add b
    inc b
    nop
    nop
    nop
    ld hl, $1000
    nop
    ld bc, $0080
    add b
    jr nz, jr_002_62ea

jr_002_632a:
    ld c, b
    nop
    db $10
    ld bc, $c000
    nop
    add b
    nop
    ld bc, $0020
    nop
    nop
    jr nz, jr_002_633f

    nop
    add b
    jr nz, jr_002_633e

jr_002_633e:
    nop

jr_002_633f:
    nop
    ld b, b
    ld b, b
    nop
    add b
    ld hl, $0000
    jr nz, jr_002_6389

    adc b
    inc bc
    nop
    inc b
    nop
    nop
    jr nz, jr_002_6351

jr_002_6351:
    ld [$8204], sp
    ld [bc], a
    nop

jr_002_6356:
    nop
    ret nz

    ld b, b
    inc d

jr_002_635a:
    add d
    nop
    nop
    stop
    nop
    stop
    nop
    ld b, c
    nop
    nop
    nop
    ld [bc], a
    ld b, b
    nop
    inc bc
    add b
    inc b
    stop
    jr nz, jr_002_6371

jr_002_6371:
    add d
    ld a, [bc]
    nop
    inc bc
    nop
    nop
    ld [$4000], sp
    jr nz, jr_002_637c

jr_002_637c:
    inc b
    nop
    nop
    nop
    inc b
    ld b, b
    stop
    ld [bc], a
    nop
    nop
    nop
    nop

jr_002_6389:
    nop
    stop
    inc b
    nop
    nop
    db $10
    db $10
    ld [bc], a
    ld bc, $0200
    nop
    nop
    nop
    ld bc, $8204
    nop
    ld bc, $1010
    add b
    ld [bc], a
    inc b
    nop
    jr nz, @+$42

    nop
    nop
    ld b, b
    db $10
    ld b, b
    add b
    ld [de], a
    ld [$1080], sp
    nop
    db $10
    ld b, c
    ld [bc], a
    nop
    ld [bc], a
    nop
    nop
    ld b, b
    nop
    stop
    nop
    nop
    nop
    nop
    ld b, b
    nop
    ld bc, $0005
    stop
    db $10
    add b
    jr nz, jr_002_63ce

    jr nz, jr_002_640c

    ld b, b
    nop

jr_002_63ce:
    nop
    adc b
    jr nz, jr_002_6356

    add d
    nop
    ld bc, $0000
    ld d, b
    inc b
    inc b
    inc bc
    db $10
    inc b
    nop
    nop
    nop
    dec b
    ld [$0080], sp
    jr nz, jr_002_63e6

jr_002_63e6:
    nop
    ld b, b
    jr nz, jr_002_63ea

jr_002_63ea:
    add b
    add b
    ld b, b
    nop
    nop
    ld [bc], a
    jr nz, jr_002_63f3

    ld [bc], a

jr_002_63f3:
    nop
    nop
    nop
    nop
    ret nz

    nop
    nop
    nop
    nop
    inc b
    nop
    nop
    add h
    jr nz, jr_002_6442

    nop
    ld bc, $0080
    nop
    add b
    inc bc
    nop
    nop
    nop

jr_002_640c:
    nop
    nop
    nop
    ld [$0808], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr z, jr_002_6421

    nop
    nop

jr_002_6421:
    nop
    nop
    nop
    nop
    nop
    jr z, jr_002_6428

jr_002_6428:
    nop
    nop
    nop
    nop
    nop
    ld b, b
    jr c, jr_002_6430

jr_002_6430:
    nop
    nop
    nop
    nop
    nop
    ld d, b
    stop
    nop
    nop
    nop
    ld b, l
    inc d
    ret nz

    nop
    nop
    db $10
    inc c

jr_002_6442:
    nop
    and c
    adc d
    nop
    ld a, [hl-]
    nop
    add h
    ld [$0011], sp
    db $10
    add sp, $0a
    ld [bc], a
    ld d, b
    inc de
    db $10
    jr nz, jr_002_645d

    inc c
    stop
    nop
    nop
    nop
    nop
    nop

jr_002_645d:
    nop
    nop
    ld [bc], a
    sub b
    ld bc, $0000
    nop
    nop
    ld [$0000], sp
    nop
    nop
    nop
    ld b, $16
    rrca
    ld l, b
    nop
    ld l, $00
    nop
    nop
    nop
    ld b, b
    nop
    nop
    nop
    nop
    nop
    ld b, h
    ld d, [hl]
    inc b
    nop
    rlca
    ld c, $00
    nop
    nop
    nop
    jr nc, jr_002_6488

jr_002_6488:
    rrca
    ld b, b
    ld a, h
    nop
    nop
    nop
    xor b
    ld [hl], h
    nop
    nop
    nop
    ld b, $00
    ld [$0014], sp
    rrca
    ld b, b
    ld a, b
    dec b
    nop
    dec a
    add h
    ld [hl], b
    nop
    ld [$2000], sp
    nop
    ld c, [hl]
    inc b
    ld bc, $0080
    nop

Jump_002_64ab:
    nop
    nop
    inc d
    jr z, jr_002_64b0

jr_002_64b0:
    nop
    nop
    nop
    dec bc
    add b
    ld d, b
    inc d
    nop
    rrca
    nop
    nop
    and d
    nop
    ld d, $00
    ld [hl+], a
    add b
    nop
    nop
    nop
    nop
    ld d, $f0
    nop
    add b
    nop
    nop
    nop
    nop
    nop
    cp b
    nop
    nop
    nop
    nop
    nop
    nop
    inc d
    jr nc, jr_002_64d8

jr_002_64d8:
    nop
    nop
    nop
    nop
    nop
    ld c, $52
    nop
    nop
    nop
    ld [hl], b
    ld a, [bc]
    nop
    ld b, b
    inc d
    nop
    rrca
    nop
    stop
    nop
    ld e, [hl]
    add l
    ld d, b
    ld a, [bc]
    ld e, h
    dec e
    add hl, bc
    add b
    add c
    jr z, @+$72

    adc a
    inc c
    ld [de], a
    ld bc, $de00
    nop
    add d
    dec b
    ld c, $71
    nop
    nop
    nop
    nop
    ld [hl], c
    add b
    ld [bc], a
    ret nz

    ld [bc], a
    nop
    ld c, d
    ld [$1c92], sp
    ld bc, $4110
    nop
    nop
    nop
    ld hl, $02cf
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld b, b
    nop
    ld bc, $0800
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    inc c
    or b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    cp b
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$0090], sp
    nop
    nop
    nop
    nop
    nop
    ld bc, $0070
    nop
    nop
    nop
    ld bc, $0c04
    nop
    nop
    sub l
    rrca
    ld [bc], a
    xor b
    inc bc
    ld e, h
    or b
    ld [$08b0], sp
    ld [$0000], sp
    ld [$02b0], sp
    nop
    ld [bc], a
    ld [bc], a
    jr z, jr_002_656a

    ld d, [hl]

jr_002_656a:
    sub h
    add h
    ld b, b
    ld hl, $0802
    nop
    ld b, b
    adc b
    nop
    add b
    ld [$0800], sp
    nop
    nop
    inc [hl]
    inc bc
    add b
    nop
    jr c, jr_002_6580

jr_002_6580:
    ld b, $00
    jr nc, jr_002_65e4

    nop
    inc e
    nop
    nop
    nop
    nop
    jr z, jr_002_658c

jr_002_658c:
    dec b
    ld b, b
    nop
    inc b
    ret nz

    ld d, h
    nop
    inc b
    add a
    ld c, $00
    ld bc, $08a0
    jr z, jr_002_659c

jr_002_659c:
    nop
    nop
    jr nc, jr_002_65a0

jr_002_65a0:
    nop
    nop
    add b
    jr nz, jr_002_65a5

jr_002_65a5:
    nop
    nop
    ld bc, $3190
    ld [$0000], sp
    nop
    inc b
    ld bc, $1c00
    ld bc, $0060
    ld bc, $4002
    nop
    ld [$0c38], sp
    nop
    nop
    nop
    nop
    nop
    nop
    cp b
    nop
    nop
    nop
    nop
    nop
    db $10
    dec c
    nop
    nop
    nop
    ld b, b
    nop
    xor b
    stop
    ld a, [bc]
    inc bc
    add b
    nop
    nop
    nop
    nop
    inc a
    db $10
    ld [$0000], sp
    nop
    nop
    nop
    nop
    stop

jr_002_65e4:
    nop
    nop
    nop
    nop
    nop
    nop
    jr c, jr_002_65ec

jr_002_65ec:
    nop
    nop
    nop
    nop
    nop
    jr nc, @+$32

    nop
    nop
    nop
    nop
    inc bc
    add b
    inc d
    jr c, @-$1e

    dec bc
    nop
    nop
    nop
    inc b
    stop
    ld h, b
    ld [bc], a
    nop
    jr nc, jr_002_6609

    nop

jr_002_6609:
    db $10
    or b
    nop
    ld b, b
    nop
    db $10
    ld b, b
    inc b
    inc e
    nop
    nop
    nop
    ld d, $f4
    ldh [rP1], a
    jr nc, jr_002_661b

jr_002_661b:
    add b
    nop
    db $10
    stop
    nop
    ld [$0030], sp
    nop
    nop
    inc b
    jr nz, jr_002_666a

    stop
    sub d
    inc h
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
    ld de, $0200
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    inc d
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr z, jr_002_6657

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld b, b

jr_002_6657:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr z, jr_002_6660

jr_002_6660:
    nop
    nop
    nop
    pop bc
    ld de, $0000
    nop
    db $10
    add hl, de

jr_002_666a:
    nop
    ld b, d
    xor h
    db $10
    inc h
    ld a, [bc]
    db $10
    ld h, d
    nop
    sub h
    ld bc, HeaderNewLicenseeCode
    nop
    nop
    add c
    jr nz, jr_002_667c

jr_002_667c:
    inc c
    ld [bc], a
    ld h, $10
    nop
    nop
    nop
    ld b, b
    nop
    dec c
    inc c
    nop
    ld b, b
    nop
    nop
    ld b, b
    nop
    inc d
    db $10
    inc b
    nop
    nop
    ld [$0200], sp
    add h
    nop
    jr nz, jr_002_6699

jr_002_6699:
    nop
    nop
    ld [bc], a
    add b
    ld bc, $0008
    nop
    nop
    nop
    ld b, b
    nop
    add c
    nop
    nop
    ld d, $42
    nop
    ld bc, $1000
    sbc b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_002_66f8

    nop
    nop
    nop
    ld [bc], a
    nop
    inc b
    ld h, b

jr_002_66bf:
    nop
    nop
    nop
    nop
    ld bc, $4050
    nop
    ld b, b
    inc d
    nop
    nop
    inc h
    nop
    inc b
    inc c
    nop
    nop
    nop
    nop
    nop
    nop
    inc l
    ld [$0000], sp
    nop
    nop
    nop
    nop
    jr nz, jr_002_66df

jr_002_66df:
    nop
    nop
    nop
    ld [$0508], sp
    jr nz, jr_002_66ef

    ld c, $10
    inc c
    nop
    inc c
    nop
    inc b
    nop

jr_002_66ef:
    nop
    ld b, b
    nop
    nop
    nop
    nop
    nop
    stop

jr_002_66f8:
    nop
    nop
    nop
    nop
    nop
    jr z, jr_002_671b

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_002_6708

jr_002_6708:
    nop
    nop
    jr nz, jr_002_670e

    nop
    inc c

jr_002_670e:
    ld [$0010], sp
    nop
    ld c, $00
    xor b
    jr nz, jr_002_6717

jr_002_6717:
    ld b, b
    nop
    add b
    nop

jr_002_671b:
    ld b, c
    ld bc, $0b00
    ld c, b
    db $10
    ld h, b
    ld h, h
    dec b
    dec h
    nop
    nop
    nop
    inc c
    ld de, $0010
    nop
    db $e4
    ld [bc], a
    ld e, c
    nop
    and b
    jr nz, jr_002_6739

    jr nz, jr_002_673a

    ld d, b
    nop
    ld [bc], a

jr_002_6739:
    nop

jr_002_673a:
    or b
    srl b
    jr jr_002_66bf

    sub e
    ld [$0040], sp
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_002_6754:
    nop
    nop
    nop
    nop
    nop
    inc a
    inc [hl]
    nop
    nop
    nop
    nop
    nop
    nop
    ld bc, $0040
    nop
    nop
    nop
    nop
    nop
    nop
    jr nc, jr_002_676c

jr_002_676c:
    nop
    nop
    nop
    nop
    nop
    ld e, $00
    nop
    nop
    nop
    nop
    nop
    inc b
    nop
    nop
    inc bc
    inc sp
    ld b, $00
    ld hl, $7407
    ld [$0300], sp
    db $10
    ld [$0120], sp
    nop
    add hl, hl
    ld l, e
    jr nz, jr_002_6794

    ld a, [bc]
    xor b
    inc bc
    ld b, b
    jr nc, jr_002_6754

jr_002_6794:
    nop
    nop
    nop
    nop
    nop
    inc c
    add b
    inc bc
    add b
    ld c, $00
    nop
    nop
    inc c
    nop
    inc bc
    add b
    nop
    ld h, b
    nop
    inc bc
    add b
    add b
    ret nz

    nop
    ld bc, $0000
    nop
    inc d
    jr z, jr_002_67b4

jr_002_67b4:
    inc bc
    nop
    nop
    ld bc, $1480
    nop
    ld [bc], a
    nop
    stop
    inc bc
    nop
    ld [$0000], sp
    nop

jr_002_67c5:
    nop
    ld l, h
    nop
    nop
    ld [hl], $04
    ret nz

    nop
    nop
    nop
    nop
    ret nz

    inc e
    nop
    nop
    inc bc
    nop
    jr jr_002_67d9

    inc b

jr_002_67d9:
    ld a, [bc]
    inc bc
    ld h, b
    nop
    add c
    ld bc, $0020
    inc a
    ld c, b
    ld [$0000], sp
    nop
    nop
    nop
    inc c
    inc l
    nop
    nop
    nop
    nop
    ld bc, $01b0
    jr z, jr_002_67f6

    inc hl
    ld b, b

jr_002_67f6:
    ld b, h
    ld a, [de]
    ld bc, $0012
    ld bc, $0c80
    nop
    nop
    nop
    inc a
    jr z, jr_002_6804

jr_002_6804:
    nop
    nop
    nop
    nop
    nop
    ld [hl], $80
    nop
    nop
    nop
    nop
    nop
    nop
    ld [de], a
    ld [$0000], sp
    nop
    nop
    nop
    nop
    ld [$0034], sp
    nop
    nop
    nop
    nop
    nop
    ld [$c034], sp
    nop
    add b
    ld a, b
    nop
    nop
    nop
    add d
    ld [$4015], sp
    ld l, b
    or b
    rst RST_20
    ld [bc], a
    inc b
    ld [$9000], sp
    ld [hl], b
    pop hl
    ldh [rP1], a
    ld b, b
    dec bc
    nop
    ld d, $10
    ld b, b
    inc b
    inc c
    jr z, jr_002_67c5

    add b
    inc c
    ld h, c
    ld b, c
    adc b
    nop
    jr c, jr_002_684c

jr_002_684c:
    ld b, b
    ld [de], a
    nop
    db $10
    ld bc, $3000
    rst RST_20
    add l
    nop
    nop
    nop
    nop
    ld b, b
    nop
    nop
    nop
    nop
    ld [$0008], sp
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
    nop
    stop
    nop
    nop
    nop
    nop
    nop
    ld [hl], b
    add b
    nop
    nop
    nop
    nop
    nop
    nop
    ld d, h
    nop
    nop
    nop
    nop
    nop
    pop bc
    ld h, [hl]
    ld bc, $0000
    inc b
    ld b, b
    ld bc, $0e25
    nop
    ld [$0800], sp
    ld b, b
    nop
    jr nz, jr_002_68a5

    ld [$016a], sp
    ld b, b
    ld b, $00
    and b
    ld a, [bc]

jr_002_68a5:
    ld a, [bc]
    jr nc, @+$04

    db $10
    ld de, $0001
    stop
    jr z, @+$03

    ldh [rNR41], a
    nop
    nop
    nop
    ld b, b
    add b
    nop
    jr nz, jr_002_68ba

jr_002_68ba:
    adc b
    nop
    ld e, $00
    nop
    ldh [rP1], a
    jr nz, jr_002_68c3

jr_002_68c3:
    ld bc, $0080
    ld [bc], a
    nop
    nop
    ld b, b
    nop
    call nz, Call_000_0021
    nop
    nop
    dec h
    jr nz, jr_002_68d3

jr_002_68d3:
    dec bc
    add b
    ld b, b
    nop
    nop
    dec bc
    nop
    nop
    nop
    nop
    db $10
    add hl, bc
    ld e, b
    nop
    nop
    nop
    add hl, bc
    add b
    ld b, b
    nop
    nop
    nop
    add b
    inc d
    ld [bc], a
    nop
    dec d
    nop
    db $10
    inc bc
    inc c
    nop
    and b
    nop
    inc c
    jr nc, jr_002_68f9

    sub b

jr_002_68f9:
    nop
    nop
    nop
    nop
    nop
    ld b, b
    nop
    nop
    nop
    nop
    ld [hl-], a
    nop
    inc c
    ld [bc], a
    nop
    nop
    nop
    nop
    ld [hl+], a
    adc [hl]
    db $10
    ld [bc], a
    ld a, b
    add b
    rlca
    nop
    nop
    nop
    nop
    ld [bc], a
    nop
    nop
    nop
    nop
    nop
    nop
    inc d
    jr z, jr_002_6920

jr_002_6920:
    nop
    nop
    nop
    nop
    nop
    inc e
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [hl], h
    ld [$0000], sp
    nop
    ld [$800b], sp
    ld e, h
    ld a, c
    nop
    ld [bc], a
    nop
    ld [hl-], a
    ld [$0060], sp
    nop
    inc b
    dec b
    ld b, $f0
    ldh [c], a
    adc $d0
    ld a, b
    add c
    add e
    ld [$0000], sp
    ld c, $00
    jr nc, @-$1e

    ld h, b
    ld [$00f1], sp
    nop
    db $10
    xor h
    inc bc
    add b
    nop
    add b
    db $e4
    ld a, [bc]
    db $10
    cp h
    pop hl
    sub b
    inc bc
    db $10
    ld b, c
    jr nz, jr_002_6974

    nop
    inc b
    nop
    cp h
    nop
    nop
    ld b, $00
    nop
    nop
    nop
    ld b, b
    nop
    inc b

jr_002_6974:
    nop
    ld [de], a
    nop
    nop
    ld bc, $0000
    nop
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
    adc b
    nop
    nop
    nop
    inc b
    nop
    add b
    ld c, b
    nop
    nop
    ld b, b
    nop
    nop
    ld bc, $0000
    nop
    nop
    nop
    nop
    nop
    nop
    inc b
    ld [bc], a
    nop
    inc b
    add h
    nop
    nop
    ld bc, $8002
    nop
    ld [$1404], sp
    nop
    nop
    ld [bc], a
    inc c
    inc b
    ld bc, $0048
    inc b
    add c
    ld [bc], a
    ld b, b
    nop
    adc b
    nop
    ld [$8040], sp
    nop
    nop
    inc c
    nop
    nop
    nop
    db $10
    ld b, b
    ld b, b
    nop
    ld [bc], a
    nop
    nop
    ld bc, $8088
    ld [$4004], sp
    nop
    inc c
    nop
    ld [$0200], sp
    jr nz, jr_002_69d8

jr_002_69d8:
    ld bc, $0000
    ld [bc], a
    ld [$0400], sp
    jr jr_002_69ea

    ld [$4400], sp
    ld [$0402], sp
    ld hl, $8000

jr_002_69ea:
    add c
    inc b
    ld [$2081], sp
    ld b, b
    adc b
    add h
    ld [$0408], sp
    nop
    inc b
    add hl, bc
    add b
    add h
    inc d
    inc b
    add hl, bc
    inc b
    add b
    inc b
    inc b
    ld b, b
    inc b
    ld b, c
    nop
    inc b
    ld b, b
    ld [$8080], sp
    ld [HeaderLogo], sp
    inc b
    ld b, b
    add h
    nop
    db $10
    add b
    add b
    inc h
    add d
    ld [bc], a
    ld b, b
    ld b, b
    ld [bc], a
    ld [$0010], sp
    add h
    add b
    jr nz, @+$06

    nop
    nop
    ld [bc], a
    ld [$8002], sp
    ld b, b
    stop
    nop
    ld [bc], a
    add b
    add d
    nop
    sub b
    adc b
    ld [bc], a
    ld de, $8840
    add b
    nop
    adc b
    nop
    ld b, d
    add b
    inc b
    inc b
    nop
    nop
    ld b, b
    nop
    add c
    nop
    add h
    inc c
    ld [$3020], sp
    nop
    ld b, d
    nop
    ld b, h
    nop
    ld [bc], a
    nop
    add b
    ld c, b
    add b
    ld c, c
    add b
    ld c, c
    ld b, b
    ld b, h
    ld [$400a], sp
    nop
    ld b, h
    ld b, d
    ld b, b
    ld [hl+], a
    inc b
    ld bc, $080a
    nop
    inc h
    ld [bc], a
    jr nz, jr_002_6aac

    ld [bc], a
    ld bc, $020c
    ld a, [hl+]
    ld b, c
    inc h
    inc d
    adc b
    nop
    db $10
    ld b, b
    nop
    inc b
    adc b
    add b
    nop
    nop
    nop
    ld b, c
    ld c, c
    add b
    nop
    nop
    nop
    nop
    nop
    nop
    add b
    nop
    ld [$0014], sp
    ld a, [bc]
    nop
    nop
    nop
    nop
    nop
    nop
    inc c
    nop
    nop
    ld h, b
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
    nop
    nop
    nop
    inc c
    ld a, [bc]
    nop
    nop
    ld c, $20
    nop
    ld [$0000], sp

jr_002_6aac:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    sub b
    nop
    ld b, b
    nop
    nop
    nop
    nop
    ld [$200c], sp
    nop
    nop
    nop
    inc c
    ld e, b
    nop
    inc c
    add hl, bc
    inc c
    add hl, bc
    ld a, [bc]
    nop
    nop
    inc b
    nop
    inc b
    nop
    nop
    nop
    nop
    ld l, b
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
    inc c
    dec c
    inc c
    nop
    ld [$0400], sp
    ld [$0008], sp
    nop
    nop
    ld [$0000], sp
    nop
    nop
    inc b
    inc b
    nop
    inc b
    inc c
    ld [$0400], sp
    inc c
    nop
    nop
    nop
    nop
    nop
    or b
    ld a, [bc]
    inc c
    nop
    nop
    nop
    ld [$040a], sp
    inc [hl]
    nop
    ld c, $06
    ld [$10a0], sp
    nop
    ld d, l
    inc c
    ld b, $0d
    nop
    ld [$043a], sp
    nop
    dec a
    nop
    nop
    nop
    nop
    nop
    ld [$0400], sp
    nop
    nop
    nop
    nop
    inc l
    nop
    nop
    dec c
    dec h
    nop
    ld d, b
    nop
    ld a, [bc]
    ld [$0010], sp
    nop
    nop
    nop
    nop
    nop
    nop
    ld h, b
    ld [$b000], sp
    nop
    add hl, bc
    nop
    dec c
    ld [hl+], a
    add hl, bc
    nop
    ld [$0800], sp
    nop
    nop
    sub b
    inc b
    ld c, $00
    ld [$0000], sp
    nop
    nop
    nop
    nop
    add hl, bc
    ld c, $0d
    nop
    nop
    nop
    nop
    inc b
    dec c
    ld a, [bc]
    db $10
    ld [$4000], sp
    nop
    ld b, $00
    nop
    inc b
    nop
    ld [$0860], sp
    nop
    and d
    sub b
    ld [$000a], sp
    ld b, $00
    nop
    ld l, c
    ld l, b
    add hl, bc
    inc c
    ld [$a908], sp
    nop
    nop
    nop
    add hl, bc
    and b
    inc c
    nop
    ld [$0900], sp
    db $10
    inc c
    inc c
    jr c, jr_002_6b92

    nop
    dec b
    nop
    nop
    inc b
    nop
    nop
    jr z, jr_002_6b91

jr_002_6b91:
    dec b

jr_002_6b92:
    nop
    dec b
    nop
    nop
    dec b
    nop
    dec b
    dec b
    nop
    nop
    ld [$0000], sp
    nop
    ld [$0000], sp
    nop
    jr nz, jr_002_6ba6

jr_002_6ba6:
    ld b, b
    ld h, [hl]
    nop
    ld h, b
    nop
    nop
    ld d, b
    nop
    ld b, b
    jr nc, jr_002_6bb1

jr_002_6bb1:
    nop
    nop
    inc b
    nop
    jr nc, jr_002_6bc7

    ld [bc], a
    nop
    stop
    add b
    inc c
    ld bc, $0040
    nop
    nop
    nop
    nop
    nop
    inc b
    inc b

jr_002_6bc7:
    nop
    ld bc, $0010
    nop
    ld a, c
    inc b
    jr nc, jr_002_6bd0

jr_002_6bd0:
    nop
    ld bc, $0000
    ld b, e
    inc b
    inc c
    ld bc, $3008
    nop
    add hl, bc
    jr jr_002_6be6

    stop
    stop

jr_002_6be2:
    ld b, $00
    db $10
    ld [hl], b

jr_002_6be6:
    ld h, b
    ld [$0051], sp
    nop
    nop
    ld [de], a
    db $10
    ld b, b
    ld [$5a00], sp
    inc b
    db $10
    jr nc, jr_002_6bf6

jr_002_6bf6:
    nop
    ld sp, $0800
    ld b, c
    nop
    nop
    inc b
    nop
    ld bc, $0008
    nop
    inc c
    ld h, b
    ld bc, $700c
    ld e, b
    nop
    ld d, [hl]
    dec [hl]
    ld b, $04
    ld h, b
    inc b
    ld [hl], b
    cp [hl]
    inc d
    inc c
    ld h, d
    inc [hl]
    db $10
    ld a, [hl-]
    ld [hl], $10
    nop
    ld [$006c], a
    inc c
    inc b
    jr nc, @-$4e

    inc c
    inc c
    ld l, h
    inc c
    jr nc, @+$72

    ld h, c
    sbc d
    dec b
    inc d
    add d
    inc b
    jr nc, jr_002_6c30

jr_002_6c30:
    ld sp, $7010
    inc b
    ld a, c
    ld [$2c21], sp
    ld d, b
    ld bc, $1021
    jr z, jr_002_6be2

    inc b
    ld a, [de]
    jr nc, jr_002_6cba

    nop
    nop
    nop
    jr @+$32

    nop
    nop
    ld bc, $0072
    ld [hl], b
    inc b
    jr nc, jr_002_6c70

    halt
    nop
    ld a, [bc]
    adc b
    jr nz, @+$36

    ld bc, $1230
    ld a, b
    ld [$3636], sp
    db $10
    ld [hl], b
    ld [hl], $50
    jr c, jr_002_6c83

    inc c
    ld [$0000], sp
    jr nc, jr_002_6c69

jr_002_6c69:
    inc d
    nop
    inc e
    ld l, b
    nop
    nop
    db $10

jr_002_6c70:
    add b

jr_002_6c71:
    ld sp, $1c50
    ld a, [bc]
    ld [$3050], sp
    db $10
    jr nc, @+$06

    jr nc, jr_002_6cb5

    db $10
    ld [$7470], sp
    jr nz, jr_002_6cf3

jr_002_6c83:
    inc d
    jr nz, @+$22

    inc h
    ld [hl], c
    ld [hl], h
    ld [$4b70], sp
    ld [$2008], sp
    jr nc, jr_002_6d0d

    inc b
    ld [$2c78], sp
    inc a
    ld [$300c], sp
    ld bc, $3001
    ld d, b
    ld a, b
    db $10
    jr nc, jr_002_6ca2

    nop

jr_002_6ca2:
    nop
    add l
    inc a
    ld a, $00
    nop
    nop
    ld [hl], b
    nop
    nop
    stop
    nop
    ld [hl+], a
    ld [$0000], sp
    nop
    nop

jr_002_6cb5:
    nop
    nop
    nop
    nop
    nop

jr_002_6cba:
    ld b, b
    nop
    nop
    nop
    ld [bc], a
    nop
    nop
    nop
    add b
    nop
    ld [bc], a
    nop
    nop
    nop
    nop
    nop
    nop
    inc h
    nop
    nop
    nop
    nop
    ld b, b
    nop
    ld [$0420], sp
    nop
    ld [bc], a
    nop
    ld b, b
    ld [$4002], sp
    nop
    nop
    nop
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
    nop
    inc b
    nop
    nop
    nop
    ld [bc], a
    jr nz, jr_002_6c71

    inc b
    inc b

jr_002_6cf3:
    add hl, hl
    nop
    nop
    ld [bc], a
    jr nc, jr_002_6d39

    inc c
    ld c, c
    ld sp, $0000
    nop
    jr nz, jr_002_6d41

    nop
    ld c, b
    inc b
    nop
    nop
    add b
    ld [$0040], sp
    nop
    jr nc, @-$70

jr_002_6d0d:
    nop
    add b
    db $10
    ld [$0008], sp
    db $10
    ld [bc], a
    nop
    nop
    nop
    ld [$0200], sp
    jr nc, jr_002_6d5d

    ld bc, $0000
    ld b, d
    ld b, c
    nop
    inc c
    add b
    nop
    ld b, d
    ld [bc], a
    ld b, b
    nop
    ld a, [bc]
    ld [bc], a
    ld b, h
    nop
    nop
    jr nz, jr_002_6d71

    nop
    add h
    jr nz, jr_002_6d35

jr_002_6d35:
    nop
    nop
    jr nc, jr_002_6d39

jr_002_6d39:
    inc c
    ld [bc], a
    nop
    nop
    nop
    add b
    ld [bc], a
    nop

jr_002_6d41:
    nop
    nop
    jr nz, @+$04

    nop
    ld b, $00
    ld b, b
    nop
    ld [bc], a
    nop
    nop
    ld c, $80
    nop
    nop
    ld h, b
    add b
    jr nc, jr_002_6d55

jr_002_6d55:
    ld a, [bc]
    nop
    jr nz, jr_002_6d5d

    inc b
    ld b, c
    nop
    nop

jr_002_6d5d:
    nop
    ld [bc], a
    ld [$1400], sp
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
    ld [bc], a
    nop
    nop
    inc b
    adc h

jr_002_6d71:
    inc l
    ld b, $00
    ld b, $0c
    add b
    nop
    add c
    ld [bc], a
    ld b, $00
    nop
    nop
    ld [$0000], sp
    nop
    ld [$0004], sp
    nop
    nop
    ld b, $02
    inc c
    inc b
    inc b
    nop
    ld [bc], a
    ld b, $00
    ld b, d
    ld [$0000], sp
    nop
    nop
    nop
    nop
    nop
    inc c
    ld a, [bc]
    nop

jr_002_6d9c:
    ld b, $00
    nop
    nop
    add b
    ld bc, $0006
    nop
    inc b
    ld b, b
    nop
    nop
    jr nc, jr_002_6dab

jr_002_6dab:
    nop
    ld b, b
    nop
    nop
    nop
    nop
    nop
    inc c
    nop
    nop
    nop
    nop
    inc b
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
    jr nz, jr_002_6dce

jr_002_6dce:
    jr nz, jr_002_6dd0

jr_002_6dd0:
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
    add d
    nop
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
    jr nz, jr_002_6df7

    nop
    jr nz, jr_002_6df1

jr_002_6df1:
    nop
    nop
    add b
    nop
    nop
    nop

jr_002_6df7:
    nop
    nop
    nop
    nop
    add b
    jr nz, jr_002_6dfe

jr_002_6dfe:
    dec d
    nop
    nop
    nop
    inc c
    ld bc, $0000
    db $10
    add h
    db $10
    ld b, b
    ld [$0040], sp
    nop
    jr z, jr_002_6e54

    nop
    ld b, b
    nop
    nop
    nop
    nop
    nop
    ld [bc], a
    nop
    nop
    jr nz, jr_002_6d9c

    nop
    ld [$4000], sp
    jr nc, jr_002_6e22

jr_002_6e22:
    nop
    add c
    ld bc, $0009
    add b
    nop
    nop
    nop
    ld [bc], a
    ld [bc], a
    nop
    inc c
    ld b, b
    nop
    ld [bc], a
    nop
    ld bc, $6600
    jr nz, jr_002_6e78

    jr nz, jr_002_6e3a

jr_002_6e3a:
    inc b
    nop
    nop
    ld b, b
    ld bc, $2000
    ld [bc], a
    stop
    jr nz, jr_002_6e46

jr_002_6e46:
    jr nz, jr_002_6e48

jr_002_6e48:
    nop
    add b
    ld [$0042], sp
    dec c
    nop
    ld bc, $0200
    jr nz, jr_002_6e54

jr_002_6e54:
    nop
    nop
    nop
    add b
    nop
    nop
    ld [$0080], sp
    nop
    inc c
    nop
    nop
    inc b
    jr nz, jr_002_6e64

jr_002_6e64:
    nop
    ld b, b
    jr nz, jr_002_6ea8

    nop
    inc c
    nop
    nop
    nop
    ld bc, $0028
    nop
    nop
    inc b
    nop
    nop
    add b
    nop
    nop

jr_002_6e78:
    nop
    nop
    nop
    nop
    nop
    nop
    inc c
    nop
    nop
    nop
    nop
    add b
    nop
    ld c, l
    stop
    ld [$3000], sp
    add b
    jr c, jr_002_6e92

    ld bc, $0000
    nop

jr_002_6e92:
    ld bc, $0000
    ld [bc], a
    ld d, $01
    nop
    nop
    nop
    ld c, $00
    nop
    ld a, [bc]
    ld bc, $0400
    inc b
    ld bc, $0000
    inc b
    nop

jr_002_6ea8:
    nop
    add b
    nop
    nop
    nop
    ld [$0002], sp
    nop
    nop
    nop
    nop
    inc l
    inc b
    ld bc, $0000
    ld [bc], a
    nop
    ld b, b
    nop
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
    stop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr nz, jr_002_6ee2

jr_002_6ee2:
    nop
    nop
    jr nz, jr_002_6ef6

    nop
    nop
    nop
    ld [$0800], sp
    nop
    nop
    nop
    nop
    nop
    ld [$8003], sp
    nop
    nop

jr_002_6ef6:
    nop
    nop
    nop
    nop
    ld [$0810], sp
    ld [$0000], sp
    nop
    inc b
    nop
    nop
    nop
    nop
    nop
    ld [$0800], sp
    ld [$0008], sp
    nop
    nop
    nop
    nop
    nop
    inc h
    nop
    nop
    nop
    nop
    stop
    ld [$0828], sp
    jr nz, jr_002_6f1e

jr_002_6f1e:
    nop
    ld [$0800], sp
    ld [$0000], sp
    nop
    nop
    stop
    nop
    adc c
    add b
    nop
    nop
    nop
    ld [$0400], sp
    ld [$0800], sp
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
    jr nz, jr_002_6f54

    nop
    ld [$0000], sp
    nop
    nop
    nop
    nop

jr_002_6f54:
    ld [$2000], sp
    db $10
    ld [$4800], sp
    stop
    nop
    inc b
    nop
    nop
    inc b
    ld b, b
    nop
    inc b
    nop
    ld [$0000], sp
    nop
    inc b
    nop
    nop
    ld [$0008], sp
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
    ld [$1000], sp
    ld [$0000], sp
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
    ld [$0000], sp
    nop
    nop
    nop
    ld [$0408], sp
    jr z, jr_002_6f9c

jr_002_6f9c:
    ld [$0008], sp
    nop
    nop
    nop
    nop
    ld [$0000], sp
    nop
    nop
    nop
    nop
    inc h
    nop
    nop
    nop
    nop
    nop
    nop
    ld [$0004], sp
    nop
    nop
    ld [$0000], sp
    ld [$0004], sp
    nop
    nop
    nop
    nop
    nop
    inc c
    nop
    nop
    ld [$0000], sp
    nop
    inc b
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
    ld [$0000], sp
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
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    ret nz

    nop
    ldh [c], a
    nop
    db $fc
    xor d

Call_002_7000:
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    db $fd
    rst RST_38
    rst RST_38
    db $fc
    xor d
    ld a, [$efcc]
    rst RST_08
    rst RST_08
    ret nz

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    call z, $f0f0
    call z, $d8fa
    ld a, [$efd8]
    ldh [$ffee], a
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

jr_002_7045:
    rst RST_38
    cp a
    or b
    ld a, [$ff3a]
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    cp a
    or b
    ld a, [$f03a]
    nop
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

jr_002_705e:
    jp z, $eefa

    ld c, $f0
    jr nc, jr_002_7045

    nop
    jp z, $fffa

    ldh a, [$fffc]
    xor b
    ld a, [$ff72]
    rst RST_38
    xor b
    db $fc
    rst RST_38
    rst RST_38
    rrca
    rst RST_38
    add b
    nop
    ret nc

    ldh a, [$ff08]
    nop
    ld [hl], b
    jr nz, jr_002_705e

    adc d
    ld a, [$fe72]
    rst RST_38
    rst RST_38
    db $fd
    db $fc
    xor b
    rst RST_30
    and d
    rst RST_38
    rst RST_38
    ld a, l
    cp [hl]
    ld a, [$cfc8]
    xor d
    rst RST_38
    db $fc
    adc h
    call z, $dfff
    rst RST_18
    rst RST_38
    rst RST_38
    ei
    db $fd
    rst RST_38
    ldh a, [rIF]
    rst RST_38
    rst RST_30
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_30
    call nz, $faca
    cp a
    or b
    db $fc
    ld [hl], h
    db $fc
    xor b
    jp z, $fefa

    rst RST_38
    cp a
    or b
    jp z, $acfa

    db $fc
    rst RST_38
    rst RST_38
    rst RST_38
    ccf
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    ld a, [$ffc8]
    rst RST_38
    db $fc
    rst RST_38
    call z, $fcc8
    xor b
    call z, Call_000_3fc4
    rst RST_38
    rst RST_38
    ldh a, [$ffee]
    ldh [$fff0], a
    pop hl
    ldh a, [rIE]
    xor h
    xor d
    ldh a, [rIE]
    xor d
    adc d
    rst RST_38
    rrca
    xor d
    xor b
    rst RST_38
    nop
    ld [$ff2a], a
    nop
    xor e
    xor b
    rst RST_38
    nop
    cp $10
    rst RST_38
    rst RST_08
    db $f4
    or b
    ret nz

    nop
    ldh a, [$ffe4]
    nop
    nop
    nop
    nop
    ld [$1081], sp
    nop
    nop
    nop
    nop
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
    ld bc, $3020
    nop
    add hl, bc
    jr nz, jr_002_7145

    nop
    dec c
    ld h, $f8
    nop
    ld bc, $7024
    nop
    ld bc, $7024
    nop
    ld bc, $3020
    nop
    add hl, bc
    inc l
    ld [hl], b
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    nop
    inc b
    ld a, b
    nop
    ld d, $06
    ld c, c
    ld b, h
    ld d, $06
    ld c, c
    ld b, h
    ld d, $06
    ld c, c
    ld b, h
    ld d, $06
    ld c, c
    ld b, h
    add hl, bc
    inc h
    ld a, b

jr_002_7145:
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    dec c
    ld h, $71
    nop
    ld bc, $7024
    nop
    ld bc, $7024
    nop
    add hl, bc
    inc h
    ld a, b
    nop
    dec c
    ld h, $f8
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
    dec c
    ld h, $71
    nop
    dec c
    ld h, $71
    nop
    nop
    nop
    jr c, jr_002_718e

jr_002_718e:
    nop
    inc b
    ld a, b
    nop
    add hl, bc
    inc h
    ld a, b
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
    ld bc, $7024
    nop
    ld bc, $3020
    nop
    ld bc, $7024
    nop
    ld bc, $7024
    nop
    ld bc, $3020
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
    nop
    inc b
    ld a, b
    nop
    add hl, bc
    inc h
    ld a, b
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
    ld bc, $3020
    nop
    ld bc, $782c
    nop
    ld bc, $3020
    nop
    nop
    nop
    jr nc, jr_002_71f2

jr_002_71f2:
    ld bc, $3020
    nop
    ld [de], a
    inc b
    ld a, b
    inc b
    ld [de], a
    inc b
    ld a, b
    inc b
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
    nop
    nop
    nop
    add b
    nop
    ld de, $0000
    nop
    inc bc
    nop
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
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    ld bc, $0020
    nop
    ld bc, $4024
    nop
    ld bc, $4024
    nop
    add hl, bc
    jr z, jr_002_723d

jr_002_723d:
    nop
    nop
    dec c
    ld c, b
    inc d
    cp e
    dec l
    ld c, d
    dec e
    dec sp
    cpl
    ld c, d
    dec c
    dec de
    xor a
    ld c, [hl]
    sub l
    ei
    xor a
    ld c, [hl]
    sbc l
    ei
    xor a
    ld c, [hl]
    sbc l
    ei
    xor l
    ld c, [hl]
    sbc l
    ei
    xor l
    ld c, [hl]
    adc l
    ld bc, $0020
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    ld [de], a
    inc b
    ld c, b
    inc b
    ld bc, $0020
    nop
    nop
    inc b
    ld c, b
    nop
    add hl, bc
    jr nz, jr_002_7275

jr_002_7275:
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
    add hl, bc
    inc h
    ld c, b
    nop
    ld bc, $0020
    nop
    nop
    nop
    nop
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    ld bc, $4024
    nop
    ld bc, $0020
    nop
    nop
    inc b
    ld c, b
    nop
    ld bc, $0020
    nop
    nop
    nop
    ld [$0000], sp
    nop
    ld [$1200], sp
    inc b
    ld c, b
    inc b
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    add hl, bc
    inc h
    ld c, b
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    ld bc, $0020
    nop
    ld bc, $4024
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
    add hl, bc
    inc h
    ld c, b
    nop
    ld bc, $0020
    nop
    ld bc, $4024
    nop
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
    nop
    inc b
    ld c, b
    nop
    nop
    inc c
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
    ld [de], a
    inc b
    ld c, b
    inc b
    ld [de], a
    inc b
    ld c, b
    inc b
    ld [de], a
    inc b
    ld c, b
    inc b
    nop
    inc b
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
    nop
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

jr_002_7331:
    nop
    rst RST_38
    rst RST_38
    rst RST_38

jr_002_7335:
    rst RST_38
    rst RST_38
    rst RST_38
    cp $f4
    cp a
    db $fd
    db $fd
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    xor d
    xor b
    rst RST_38
    rst RST_38
    di
    rst RST_38
    rst RST_38
    rst RST_38
    ei
    rst RST_38
    ld h, [hl]
    ld l, d
    ld h, [hl]
    ld l, d
    ld h, [hl]
    ld l, h
    ld h, [hl]
    ld l, h
    inc sp

jr_002_735d:
    add hl, sp
    call z, $ccf0
    ldh a, [$fffc]
    jr nc, jr_002_7331

    ldh a, [$fffc]
    jr nc, jr_002_7335

    ldh a, [$fffc]
    jr nc, jr_002_735d

    call z, $f0cc
    call z, $fff0
    rst RST_38
    rst RST_38
    rst RST_38
    xor a
    call z, $ccaf
    rst RST_08
    ccf
    rrca
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    db $e4
    call z, $8cbf
    rst RST_08
    xor d
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    db $fc
    ld [hl], h
    cp a
    adc h
    ldh [c], a
    xor $8a
    nop
    rst RST_08
    xor d
    ldh a, [$ff30]
    db $fc
    xor b
    db $fc
    xor b
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    ld a, [$eec8]
    ldh [$fffc], a
    xor b
    db $fc
    xor b
    rst RST_38
    rst RST_38
    rst RST_38
    cp $80
    nop
    add b
    nop
    ret nz

    nop
    cp e
    or b
    ret nz

    nop
    ld a, a
    rst RST_38
    rrca

jr_002_73bb:
    ccf
    xor b
    jr nz, jr_002_73bb

    nop
    ldh a, [$ffc0]
    rst RST_38
    rrca
    rst RST_08
    db $fc
    ld a, e
    sbc $ff
    or $ff
    rst RST_38
    rst RST_38
    rst RST_38
    xor $4e
    ret c

    ld a, [$fe01]
    cp $ff
    rst RST_38
    rst RST_08
    rst RST_38
    cp $ff
    rst RST_38
    rst RST_38
    rst RST_38
    rrca
    inc a
    rst RST_38
    rst RST_28
    rst RST_30
    call nz, $d0df
    xor $e0
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_18
    ld a, [$fac8]
    ld [hl-], a
    rst RST_38
    cp $f5
    call z, $c4f7
    ret z

    ld a, [$ffff]
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    db $fc
    ld [hl], h
    db $fc
    ld [hl], h
    cp $00
    ld a, [$f73a]
    call nz, $c4f7

jr_002_740a:
    ldh a, [$ffe0]
    rst RST_30
    call nz, $e0f0
    db $fc
    inc bc

jr_002_7412:
    xor $fa
    ld b, h
    ld d, b
    rst RST_38
    nop
    ldh a, [$ffe4]

jr_002_741a:
    rst RST_38
    nop
    jp z, $ffaa

    nop
    jp z, $ffaa

    nop
    cp $04
    jr nc, jr_002_7428

jr_002_7428:
    cp $10
    rst RST_38
    nop
    call z, $ffca
    nop
    xor d
    xor h

jr_002_7432:
    nop
    nop
    nop
    nop
    nop
    add b
    nop
    nop

jr_002_743a:
    ld [$0800], sp
    nop
    nop
    nop
    nop
    nop

jr_002_7442:
    nop
    nop
    nop
    nop
    rst RST_08
    sbc h
    jr z, @-$7e

jr_002_744a:
    ld bc, $3114
    or d
    inc c
    nop
    ld e, b
    add b

jr_002_7452:
    ld bc, $0114
    ld a, [bc]
    rrca
    sub b
    jr z, @-$7e

jr_002_745a:
    ld bc, $0114
    inc h
    ldh [c], a
    inc b
    jr nz, @+$22

jr_002_7462:
    inc b
    ld a, [bc]
    add hl, hl
    jr nz, @+$4e

    nop
    ld d, b
    jr nz, jr_002_746f

    inc b
    ld [$c803], sp

jr_002_746f:
    nop
    ld d, b
    jr nz, jr_002_7477

    ld a, [bc]
    ld [$4c63], sp

jr_002_7477:
    nop
    ld d, b
    jr nz, jr_002_747f

    ld a, [bc]
    ld [$0822], sp

jr_002_747f:
    nop
    ld d, b
    jr nz, jr_002_7484

    ld a, [de]

jr_002_7484:
    jr z, @-$1a

    nop
    nop
    jr z, jr_002_740a

jr_002_748a:
    ld bc, $0414
    ld [bc], a
    dec bc
    or h
    jr z, jr_002_7412

jr_002_7492:
    ld bc, $1614
    ld a, [hl+]
    nop
    nop
    jr z, jr_002_741a

jr_002_749a:
    ld bc, $3314
    add e
    ret nz

    inc h
    jr z, @-$7e

jr_002_74a2:
    ld bc, $2114
    db $eb
    ld bc, $2884
    add b
    ld bc, $3114
    jp Jump_000_00c8


    jr z, jr_002_7432

jr_002_74b2:
    ld bc, $2314
    ld [hl-], a
    adc $00
    jr z, jr_002_743a

jr_002_74ba:
    ld bc, $1514
    ld a, [hl+]
    ld e, d
    nop
    jr z, jr_002_7442

    ld bc, $0514
    nop
    inc c
    nop
    jr z, jr_002_744a

    ld bc, $2014
    push bc
    nop
    ld b, b
    jr z, jr_002_7452

    ld bc, $2414
    ld sp, hl
    dec bc
    sub b
    jr z, jr_002_745a

    ld bc, $2214
    pop de
    ld b, c
    sub b
    jr z, jr_002_7462

    ld bc, $0014
    inc b
    call Call_000_284c
    add b
    ld bc, $0414
    jr c, @-$7b

    inc h
    jr z, @-$7e

    ld bc, $0114
    ld a, [hl+]
    ld [hl+], a
    nop
    jr z, @-$7e

    ld bc, $3114
    ld [hl], e
    adc [hl]
    nop
    jr z, @-$7e

    ld bc, $3514
    db $eb
    dec c
    add b
    jr z, jr_002_748a

    ld bc, $3114
    jp Jump_000_1cc1


    jr z, jr_002_7492

    ld bc, $2314
    ld sp, $c800
    jr z, jr_002_749a

    ld bc, $1514
    inc b
    add hl, bc
    sbc b
    jr z, jr_002_74a2

    ld bc, $1014
    add $0a
    jr z, jr_002_7551

    add b
    nop
    inc b
    ld [bc], a
    ld bc, $80c7
    jr z, jr_002_74b2

    ld bc, $2812
    and b
    ld c, b
    adc h
    jr z, jr_002_74ba

    ld bc, $0814
    ld h, e
    call c, Call_000_2814
    add b
    ld bc, $0814
    nop
    ld b, $00
    nop
    nop
    nop
    ld [bc], a
    nop
    nop
    ld [$0020], sp

jr_002_7551:
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
    inc b
    nop
    nop
    jr nz, @+$36

    pop de
    adc e
    inc b
    nop
    nop
    nop
    jr nz, jr_002_756b

    pop bc
    add e

jr_002_756b:
    inc b
    inc b
    nop
    nop
    jr nz, jr_002_7573

    ret nz

    adc e

jr_002_7573:
    inc d
    inc d
    nop
    nop
    ld [$c428], sp
    add hl, bc
    inc b
    stop
    inc b
    jr z, jr_002_75a9

    sub c
    add hl, bc
    inc b
    stop
    nop
    ld [$8628], sp
    add hl, bc
    inc b
    stop
    nop
    ld [$8628], sp
    add hl, bc
    inc b
    stop
    nop
    ld bc, $c028
    jp Jump_000_0404


    nop
    nop
    jr nz, jr_002_75c3

    pop de
    add e
    inc b
    inc b
    nop
    nop
    jr nz, jr_002_75c9

jr_002_75a9:
    pop hl
    add e
    inc b
    inc b
    nop
    nop
    jr nz, jr_002_75d2

    pop de
    jp Jump_000_0404


    nop
    nop
    jr nz, jr_002_75df

    pop hl
    add e
    ld d, h
    inc b
    nop
    nop
    jr nz, jr_002_75f5

    jp hl


    adc e

jr_002_75c3:
    inc b
    inc b
    nop
    nop
    jr nz, jr_002_75ea

jr_002_75c9:
    pop de
    sub e
    inc b
    inc b
    nop
    nop
    jr nz, jr_002_75f3

    pop hl

jr_002_75d2:
    add e
    inc b
    inc b
    nop
    nop
    jr nz, jr_002_7609

    pop bc
    add e
    inc b
    inc b
    nop
    nop

jr_002_75df:
    jr nz, jr_002_7615

    ret


    add e
    inc b
    inc b
    nop
    nop
    jr nz, jr_002_760b

    pop bc

jr_002_75ea:
    add e
    inc b
    inc b
    nop
    nop
    jr nz, jr_002_7612

    pop de
    adc e

jr_002_75f3:
    inc b
    inc b

jr_002_75f5:
    nop
    nop
    jr nz, jr_002_762d

    ret


    adc e
    inc d
    inc b
    nop
    nop
    jr nz, jr_002_7623

    pop bc
    sub a
    ld b, h
    inc b
    nop
    nop
    jr nz, jr_002_762c

jr_002_7609:
    pop hl
    add e

jr_002_760b:
    inc b
    inc b
    nop

jr_002_760e:
    nop
    jr nz, jr_002_7642

    pop de

jr_002_7612:
    adc e
    inc b
    inc b

jr_002_7615:
    nop
    nop
    jr nz, jr_002_763b

    pop hl
    add e
    ld b, h
    inc b
    nop
    nop
    jr nz, jr_002_7655

    jp hl


    sub e

jr_002_7623:
    inc h
    inc b
    nop
    nop
    jr nz, jr_002_764a

    pop de
    add e
    add h

jr_002_762c:
    inc b

jr_002_762d:
    nop
    nop
    jr nz, jr_002_7653

    ret


    add e
    inc d
    inc b
    nop
    ld [$3420], sp
    ret


    adc d

jr_002_763b:
    inc b
    inc b
    nop
    nop
    jr nz, jr_002_7662

    adc c

jr_002_7642:
    or e
    ld b, h
    inc b
    nop
    nop
    db $10
    jr z, jr_002_760e

jr_002_764a:
    adc e
    ld d, h
    inc b
    nop
    nop
    jr nz, jr_002_7679

    rst RST_00
    add e

jr_002_7653:
    inc d
    inc b

jr_002_7655:
    nop
    nop
    jr nz, jr_002_7681

    rst RST_00
    ld [hl+], a
    nop
    nop
    nop
    nop
    jr nz, jr_002_7661

jr_002_7661:
    nop

jr_002_7662:
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
    nop
    ret nz

    nop
    nop
    ld [bc], a
    rst RST_08
    add e
    rlca
    call nz, $c000
    add b

jr_002_7679:
    call nz, $c00f
    ret nz

    ret z

    inc bc
    nop
    nop

jr_002_7681:
    nop
    inc bc
    add d
    inc de
    inc bc

jr_002_7686:
    inc bc
    db $e3
    ret nz

    and b
    db $d3
    ret nz

    jp Jump_000_0003


    ld [bc], a
    nop
    inc bc
    inc de
    ld [hl+], a
    add b
    push bc
    inc hl
    add e
    inc de
    ld b, a
    res 0, e
    nop
    nop
    inc hl
    ret nz

    inc hl
    ret z

    inc bc
    add b
    ld [hl+], a
    nop
    jp $c0cb


    ld b, a
    db $d3
    add b
    inc bc
    nop
    nop
    jp nz, $8347

    rlca
    nop
    db $db
    add b
    nop
    ld b, a
    db $e3
    ret nz

    ret nz

    nop
    ret nz

    rlc b
    ret z

    ret nz

    inc de
    jr nz, jr_002_7686

    ldh [c], a
    call nz, $c300
    rst RST_08
    inc bc
    add b
    inc de
    pop bc
    nop
    ld bc, $2301
    inc bc
    inc bc
    jp $e113


    nop
    ldh [$ff2a], a
    ret nz

    inc de
    nop
    ld [hl+], a
    inc de
    nop
    nop
    inc de
    ld [$4407], sp
    nop
    jp nz, $c71b

    rst RST_00
    and c
    dec bc
    ld a, [bc]
    ret nz

    ld bc, $c800
    db $e3
    call nz, Call_000_0422
    nop
    ld b, a
    nop
    inc bc
    dec b
    pop bc
    rlca
    and b
    ld [hl+], a
    nop
    inc hl
    ld b, a
    nop
    ld [bc], a
    inc bc
    nop
    ret z

    nop
    nop
    inc bc
    call Call_000_0c09
    ld b, h
    inc bc
    ret z

    inc de
    nop
    db $10
    ld bc, $00c3
    ret nz

    ret nz

    nop
    ret z

    nop
    jp nz, Jump_000_0083

    ret nz

    nop
    ret nz

    add e
    ldh [c], a
    inc bc
    bit 0, h
    nop
    nop
    ret nz

    ld b, h
    dec de
    inc bc
    ld [hl+], a
    nop
    nop
    ld b, $00
    jp nz, $1340

    rlca
    ret nz

    inc hl
    and b
    nop
    db $d3
    inc bc
    rst RST_00
    nop
    nop
    ld bc, $0200
    db $e3
    inc hl
    ld b, l
    db $d3
    ld b, d
    ld bc, $0300
    pop bc
    rlca
    inc bc
    and e
    ret nz

    inc hl
    add b
    nop
    inc bc
    nop
    db $e3
    add c
    ld [bc], a
    inc hl
    ld bc, $0000
    rlca
    inc bc
    ret nz

    ld b, d
    ld bc, $0040
    add d
    ret nz

    nop
    ld bc, $40c4
    nop
    nop
    ld bc, $c700
    ld b, b
    ld b, b
    ld [hl+], a
    add b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_002_777f:
    nop
    nop
    nop
    ld [bc], a
    nop
    nop
    inc b

jr_002_7786:
    nop
    adc b
    nop
    nop
    nop
    jr @+$0c

    ld [bc], a
    nop
    add b
    inc c
    nop
    ld bc, $0000
    ld [bc], a
    ld [$0084], sp
    jr nz, jr_002_77a3

    ld [$0240], sp
    ld [bc], a
    add b
    jr @+$06

    ld b, b

jr_002_77a3:
    dec b
    nop
    jr nz, jr_002_77a7

jr_002_77a7:
    inc b
    add d
    ld b, b
    nop
    add h
    nop
    ld b, b
    ld bc, $8084
    nop
    nop
    add b
    nop
    nop
    ld b, c
    add b
    nop
    nop
    ld hl, $8440
    inc b
    ld [bc], a
    add b
    ld [$8001], sp
    inc d
    jr nz, jr_002_7786

    ld b, b
    ld [bc], a
    nop
    add b
    nop
    inc b
    jr nz, jr_002_77de

    stop
    add h
    inc b
    nop
    nop
    inc b
    nop
    ld b, b
    inc d
    inc b
    nop
    nop
    jr jr_002_77dd

jr_002_77dd:
    inc b

jr_002_77de:
    ld [bc], a
    nop
    inc bc
    ld bc, $4101
    nop
    inc b
    ld bc, $0014
    ld b, b
    ret nz

    inc b
    nop
    add b
    jr nz, @+$03

    jr nz, jr_002_77f3

    nop

jr_002_77f3:
    nop
    ld [bc], a
    jr nz, jr_002_77f7

jr_002_77f7:
    ld [bc], a
    add b
    add h
    nop
    ld [bc], a
    db $10
    jr nz, jr_002_777f

    inc b
    add d
    jr nc, jr_002_7803

jr_002_7803:
    nop
    ld b, b
    ld [bc], a
    nop
    nop
    ret nz

    inc b
    nop
    dec b
    nop
    ld d, b
    nop
    nop
    nop
    nop
    nop
    inc b
    nop
    inc b
    ld [$0000], sp
    nop
    ld b, b
    ld b, c
    nop
    ld b, b
    nop
    nop
    ld [$0000], sp
    nop
    jr nz, jr_002_7846

    ld de, $8400
    ld bc, $0000
    db $10
    inc d
    inc bc
    inc b
    inc b
    add b
    db $10
    adc b
    jr nz, @+$22

    ld bc, $8000
    ld b, b
    ld [bc], a
    ld [bc], a
    nop
    ld [bc], a
    ld b, b
    jr nz, jr_002_7842

    ld [bc], a

jr_002_7842:
    nop
    inc d
    jr nz, jr_002_7846

jr_002_7846:
    nop
    ret nz

    ld b, b
    nop
    nop
    add b
    inc c
    jr nz, jr_002_784f

jr_002_784f:
    nop
    ld bc, $8000
    inc b
    inc b
    jr nz, jr_002_7867

    inc bc
    ld bc, $0800
    ld d, b
    ld [bc], a
    add hl, bc
    ld [bc], a
    jr jr_002_78a1

    and b
    inc b
    inc b
    nop
    inc b
    inc bc

jr_002_7867:
    ld [bc], a
    nop
    jr nz, jr_002_786b

jr_002_786b:
    ld [bc], a
    db $10
    inc b
    jr nz, @+$05

    ld b, c
    ld bc, $8400
    jr nz, jr_002_78b6

    ld b, c
    nop
    and b
    nop
    nop
    ld b, c
    nop
    inc b
    and b
    ld bc, $8000
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    or h
    ld d, b
    nop
    inc b
    inc de
    ret nz

    ret nz

    nop

jr_002_78a1:
    inc c
    inc c
    inc b
    nop
    ld l, $00
    nop
    nop
    stop
    nop
    nop
    nop
    ld h, b
    nop
    nop
    inc e
    nop
    nop
    nop
    nop

jr_002_78b6:
    ld [hl], b
    jr nz, jr_002_78d7

    nop
    ld bc, $0be0
    ld [hl], d
    ld b, h
    dec bc
    ret nz

    nop
    ld [hl-], a
    ld hl, $0eca
    ld b, c
    and c
    sbc d
    adc h
    ld [$1ad2], sp
    sub c
    db $10
    inc bc
    adc [hl]
    inc e
    nop
    db $10
    adc d
    inc de
    nop

jr_002_78d7:
    ld de, $0080
    nop
    nop
    inc b
    nop
    ld h, b
    nop
    nop
    nop
    ld d, c
    jr jr_002_78e5

jr_002_78e5:
    nop
    db $10
    ld d, e
    jp z, RST_00

    and d
    sub b
    ld c, $00
    ld bc, $c040
    ld [$0500], sp
    ld b, $e0
    inc bc
    ret nz

    nop
    ld c, b
    db $10
    inc bc
    nop
    ld c, c
    or b
    nop
    adc h
    nop
    inc bc
    add b
    ld c, $b0
    or l
    adc d
    add hl, bc
    nop
    ld d, b
    ld [bc], a
    ld [HeaderLogo], sp
    nop
    ld b, b
    jr z, jr_002_7916

    rrca
    nop

jr_002_7916:
    ld b, b
    pop bc
    add [hl]
    nop
    ld bc, $cfd1
    inc e
    ld b, d
    ld [de], a
    cpl
    ld [$550c], sp
    ld c, a
    nop
    ld b, $f1
    nop
    ld bc, $1800
    ld c, a
    inc e
    nop

jr_002_792f:
    reti


    ld b, b
    ld e, $2a
    ld [bc], a
    and a
    ld c, $30
    inc bc
    sub h
    inc c
    jr z, jr_002_792f

    rst RST_18
    ld e, $02
    dec bc
    add b
    inc c
    sub b
    inc bc
    rst RST_08
    nop
    ldh a, [rNR12]
    jr nz, jr_002_7972

    ld [$8012], sp
    ld b, d
    ld d, $21
    inc b
    nop
    nop
    sub c
    db $e3
    inc e
    ld hl, sp-$1d
    add b
    nop
    ld bc, $80e1
    ld b, d
    nop
    ld [$0014], sp
    stop
    rlca
    nop
    ld a, c
    inc bc
    add [hl]
    adc h
    add hl, bc
    ld [$024b], sp
    ldh [$ff03], a
    xor c
    nop

jr_002_7972:
    adc b
    ld [hl], h
    inc c
    ld d, d
    db $10
    inc bc
    add b
    inc a
    ld [hl], c
    ld a, d
    add a
    ld [de], a
    ldh a, [$ff0b]
    add b
    ld sp, $1938
    add h
    ld [bc], a
    ldh a, [rSC]
    nop
    add b
    nop
    and b
    add a
    jr jr_002_7a07

    inc bc
    ret nz

    inc e
    nop
    ld l, b
    inc hl
    ld l, $00
    nop
    nop
    nop
    nop

jr_002_799b:
    nop
    nop
    add b
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
    ld h, h
    inc c
    jr z, jr_002_79b0

jr_002_79b0:
    stop
    nop
    nop
    nop
    ld [hl-], a
    ld c, $83
    add b
    ld c, $00
    nop
    nop
    ld bc, $0088
    nop
    nop
    ld [$0000], sp
    ld [$8040], sp
    dec b
    ld c, [hl]
    dec b
    ld [bc], a
    jr nz, jr_002_79ce

jr_002_79ce:
    jr c, jr_002_7a3c

    inc bc
    inc c
    jr nc, jr_002_79d5

    ret nz

jr_002_79d5:
    db $10
    ld de, $8383
    ld e, $b4
    and c
    and e
    ld d, $14
    ldh [$ff03], a
    nop
    ld [hl], h
    inc bc
    rst RST_20
    ld [bc], a
    ld bc, $273b
    ld [bc], a
    nop
    ld bc, $4080
    ld l, b
    inc bc

jr_002_79f0:
    call nz, Call_002_7000
    nop
    nop
    nop
    ld [$00c0], sp
    nop
    jr @+$32

    dec bc
    add b
    jr z, jr_002_7a00

jr_002_7a00:
    add h
    ld e, $00
    nop
    ld h, a
    inc d
    ld b, b

jr_002_7a07:
    nop
    nop
    ld d, [hl]
    ld a, b
    nop
    nop
    nop
    jr c, jr_002_79f0

    inc d
    nop
    ld b, h
    ldh [rDIV], a
    ld bc, $8100
    add b
    jr nc, jr_002_799b

    ld bc, $0c07
    add d
    jp $908a


    ld [hl], c
    call nz, $1448
    xor d
    inc bc
    add h
    ld c, $84
    jr nc, @+$62

    add b
    nop
    add h
    ld [$0020], sp
    inc b
    ld b, a
    nop
    ld a, [hl-]
    db $e3
    add d
    nop
    ld c, b
    inc b

jr_002_7a3c:
    inc de
    nop
    ld l, b
    add c
    add a
    nop
    nop
    nop
    rlca
    nop
    jr nc, jr_002_7a48

jr_002_7a48:
    dec b
    sub b
    dec c
    ld [de], a
    jr nz, jr_002_79ce

    db $10
    inc bc
    add e
    ld b, b
    nop
    ld [hl+], a
    ld b, b
    inc d
    ld l, b
    nop
    nop
    ld b, b
    ld l, b
    and b
    stop
    ld [bc], a
    ldh [c], a
    jr nz, jr_002_7a64

    sub b
    xor c

jr_002_7a64:
    jr z, jr_002_7a72

    nop
    ld h, b
    ld a, [de]
    inc c
    db $10
    ld [bc], a
    nop
    nop
    jr c, jr_002_7a73

    add h
    nop

jr_002_7a72:
    nop

jr_002_7a73:
    ld bc, $00c0
    ld [$0400], sp
    and $00
    ld b, a
    adc a
    ld [de], a
    ld a, b
    add b
    rlca
    jr c, jr_002_7aeb

    nop
    rlca
    nop
    db $10
    pop bc
    and l
    nop
    db $10
    dec b
    ld bc, $001c
    ldh [rP1], a
    nop
    ld [hl], b
    ld hl, $10c0
    sub h
    nop
    nop
    nop
    jr jr_002_7a9f

    jp Jump_000_142c


jr_002_7a9f:
    nop
    inc b
    nop
    ld b, b
    ldh a, [rBGP]
    cp [hl]
    nop
    ld bc, $1c80
    nop
    nop
    nop
    nop
    nop
    nop
    inc bc
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

jr_002_7aba:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld b, $08
    nop
    ld [bc], a
    jr nz, @+$04

    add b
    ld b, $84
    nop
    inc h
    nop
    inc b
    nop
    nop
    nop
    nop
    ld b, b
    nop
    nop
    nop
    ld bc, $c300
    jr jr_002_7adc

    nop

jr_002_7adc:
    nop
    jr nc, @+$22

    jr jr_002_7ae2

    nop

jr_002_7ae2:
    ld [$000a], sp
    add b
    add d
    ld l, b
    ld [bc], a
    sbc b
    db $10

jr_002_7aeb:
    ld b, l
    db $10
    sub c
    ld bc, $0481
    inc [hl]
    ld de, $000a
    jr nz, @+$09

    nop
    ld [bc], a
    sub b
    nop
    nop
    db $10
    ld [$0800], sp
    pop hl
    nop
    ld b, b
    inc b
    ld d, $10
    jr z, jr_002_7b08

jr_002_7b08:
    nop
    db $10
    jr z, jr_002_7b0c

jr_002_7b0c:
    nop
    nop
    ld b, h
    inc d
    ld b, b
    jr nz, jr_002_7b55

    jr @+$12

    jr nc, jr_002_7b17

jr_002_7b17:
    nop
    ld [bc], a
    nop
    nop
    nop
    inc h
    jr jr_002_7b24

    db $10
    jr nz, jr_002_7b23

    add hl, bc

jr_002_7b23:
    ret nz

jr_002_7b24:
    jr nc, jr_002_7b26

jr_002_7b26:
    add b
    nop
    dec b
    ld bc, $5402
    nop
    nop
    add c
    inc b
    adc [hl]
    inc l
    nop
    inc d
    ld l, b
    stop
    jr jr_002_7aba

    jr nz, jr_002_7b47

    add h
    jr jr_002_7b4e

    nop
    jr nc, @-$2b

    ld b, b
    nop
    add hl, bc
    ld [$8b20], sp

jr_002_7b47:
    ld bc, $2840
    ld [$1005], sp
    ld c, d

jr_002_7b4e:
    nop
    inc b
    nop
    call nz, Call_000_0f09
    ld [hl-], a

jr_002_7b55:
    nop
    nop
    ld c, d
    dec d
    add b
    stop
    db $10
    ld de, $1404
    db $10
    ld l, h
    add hl, de
    xor d
    ld [$0011], sp
    inc d
    ld d, b
    add hl, de
    nop
    ld [$0042], sp
    add c
    jr jr_002_7b73

    ld b, b
    inc de

jr_002_7b73:
    add d
    nop
    ld d, c
    nop
    dec b
    nop
    jp nz, Jump_000_1b20

    nop
    ld [bc], a
    add b
    jr z, jr_002_7b85

    dec b
    ld a, [bc]
    adc [hl]
    add b

jr_002_7b85:
    inc b
    nop
    nop
    pop de
    db $10
    jr jr_002_7b8c

jr_002_7b8c:
    ld [bc], a
    nop
    jr jr_002_7b90

jr_002_7b90:
    ld bc, $0e11
    dec b
    jr c, @-$7e

    dec b
    inc b
    and b
    jr nz, jr_002_7bab

    ld b, b
    nop
    ld a, [bc]
    ld b, [hl]
    ld c, b
    adc b
    inc d
    nop
    ld [bc], a
    inc b
    jr nz, jr_002_7bcb

    dec c
    nop
    add h
    nop

jr_002_7bab:
    ld bc, $0401
    inc b
    ld [$0030], sp
    nop
    ld bc, $0014
    inc c
    db $10
    ld hl, $0000
    add b
    add e
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ld [de], a
    nop
    nop
    nop

jr_002_7bcb:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    dec b
    add [hl]
    db $10
    ld b, b
    nop
    nop
    inc c
    add hl, de
    nop
    rlca
    ld c, b
    nop
    add b
    jr nz, @+$0e

    nop
    nop

jr_002_7be4:
    nop
    ld bc, $006c
    nop
    nop
    nop
    nop
    nop
    ld e, $38
    ld h, b
    nop
    nop
    ld c, [hl]
    jp nz, Jump_000_0006

    ld d, h
    ld h, b
    ld [$088c], sp
    ld bc, $1620
    ld bc, $20d8
    nop
    ld [hl-], a
    ret


    ld [hl], $48
    ld l, h
    nop
    nop
    stop

jr_002_7c0b:
    ld sp, hl
    ld h, $36
    nop
    inc b
    ret nz

    inc c
    nop
    and h
    ld b, b
    jr z, @+$3a

    nop
    ld b, e
    ld b, $08
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jr nc, jr_002_7be4

    rlca
    inc c
    nop
    add e
    dec b
    stop

jr_002_7c2b:
    ld [bc], a
    db $eb
    add b
    nop
    nop
    dec b
    inc c
    nop
    ld [bc], a
    ldh [rNR10], a
    ld sp, $2583
    nop
    ld b, b
    add sp, $06
    ld [bc], a
    ld b, b
    ret nz

    nop
    db $10
    jr nc, @+$23

    db $f4
    inc c
    ld bc, $0037
    inc c
    ld h, b
    dec b
    rst RST_10
    sbc l
    jr nc, jr_002_7c5b

    dec b
    ld b, a
    ld a, h
    ld de, $00c1
    ld b, d
    inc bc
    ld b, b
    ld b, $40

jr_002_7c5b:
    cp h
    ld b, e
    inc e
    jr nc, jr_002_7c73

    jr nz, @+$0e

    ld [hl], c
    ld bc, $0811
    inc d
    nop
    inc bc
    nop
    nop
    nop
    nop
    ld [$0334], sp
    nop
    ld [de], a
    ld [hl], b

jr_002_7c73:
    pop hl
    rst RST_00
    ld d, b
    jr c, @+$04

    nop
    stop
    jr nz, jr_002_7cbd

    inc d
    ld b, b
    nop
    nop
    nop
    ld [bc], a
    ldh [c], a
    inc b
    ld b, d
    jr nc, jr_002_7c0b

    nop
    nop
    sub h
    ld a, [hl+]
    jp hl


    nop
    ld [bc], a
    ld bc, $4184
    ld l, d
    xor d
    ld b, $14
    jr nc, @-$7c

    dec b
    ld d, b
    nop
    nop
    ld b, b
    jr nc, jr_002_7ccf

    nop
    nop
    ld c, $44
    inc e
    ret nc

    adc h
    jr nc, jr_002_7c2b

    inc hl
    jr z, @+$42

jr_002_7cab:
    add sp, $70
    nop
    ld b, $68
    inc hl
    nop
    ld a, [bc]
    ld hl, $70c3
    dec [hl]
    ld [hl], l
    add b
    db $10
    ld [hl], c
    ld b, c
    rst RST_00

jr_002_7cbd:
    cp h
    inc b
    inc b
    add b
    jr jr_002_7d33

    or d
    inc b
    nop
    ld b, h
    ld c, $00
    and d
    nop
    and b
    db $e3
    inc d
    nop

jr_002_7ccf:
    dec b
    add b
    inc a
    nop
    nop
    nop
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
    inc [hl]
    ld bc, $0028
    dec b
    db $10
    ld b, h
    ldh [$ff0e], a
    ld bc, $5802
    nop
    dec e
    nop
    nop
    nop
    dec c
    ld [$0000], sp
    nop
    nop
    ld [bc], a
    add b
    ld d, h
    add b
    inc b
    nop
    nop
    db $10
    ld a, [bc]
    inc b
    add b
    jr z, jr_002_7d18

    ld [bc], a
    ld bc, $0101
    ret nc

    sbc l
    ld b, d
    ld d, b
    nop
    nop
    inc b
    ret nz

jr_002_7d18:
    ld b, $08
    jr z, jr_002_7d1c

jr_002_7d1c:
    nop
    nop
    nop
    and c
    res 2, h
    nop
    nop
    add b
    ld bc, $3002
    ld a, [bc]
    jr nz, jr_002_7cab

    ld bc, $60d0
    jr nc, jr_002_7d30

jr_002_7d30:
    nop
    inc l
    adc b

jr_002_7d33:
    nop
    nop
    nop
    ld l, b
    ret nz

    cpl
    nop
    add b
    dec bc
    add b
    add b
    nop
    ld [bc], a
    adc d
    ld b, b
    nop
    nop
    dec bc
    jr nz, @+$42

    ld [hl+], a
    nop
    nop
    add b
    ld [hl], b
    nop
    nop
    add hl, de
    ret nz

    ld a, [bc]
    inc d
    db $10
    and e
    and b
    jr z, @+$32

    ld d, b
    inc d
    inc c
    nop
    ld de, $3cc0
    add d
    and d
    ld a, [bc]
    inc c
    inc [hl]
    nop
    ld h, h
    inc l
    ld [hl], b
    ld [hl+], a
    nop
    jr z, @+$2a

    ld de, $1685
    ld b, b
    nop
    dec hl
    nop
    add b
    ld h, e
    add b
    inc l
    add b
    ld a, [hl+]
    nop
    ld c, h
    ld b, b
    ld bc, $12c3
    ld [bc], a
    ld b, b
    ld b, $01
    nop
    ld [bc], a
    jr jr_002_7dc6

    ld [$40e1], sp
    db $10
    ld [bc], a
    db $10
    ld b, h
    ld [bc], a
    nop
    pop bc
    add b
    ld a, [bc]
    jr c, jr_002_7d95

    rst RST_00

jr_002_7d95:
    nop
    ld [hl], b
    inc bc
    adc [hl]
    db $10
    add b
    db $10
    ld d, b
    ld e, h
    ld h, b
    and e
    adc d
    ld hl, $1528
    ld c, b
    add hl, bc
    nop
    and e
    add b
    inc c
    or h
    db $10
    ld b, b
    nop
    nop
    ld [bc], a
    ld c, $00
    add b
    nop
    nop
    and b
    ld [hl], b

jr_002_7db7:
    ld [bc], a
    adc [hl]
    ld e, $34
    ld l, e
    jp Jump_002_4000


    ld hl, $00b4
    ld bc, $0060
    add c

jr_002_7dc6:
    nop
    call nz, Call_000_1028
    nop
    ld h, b
    rrca
    ld [$e400], sp
    nop
    nop
    nop
    ldh a, [c]
    dec bc
    dec c
    nop
    inc bc
    add b
    add b
    nop
    ld a, c
    add b
    inc e
    ld [bc], a
    ld b, b
    inc h
    ld bc, $6300
    add b
    ld [$0000], sp
    ld b, $00
    nop
    nop
    nop
    nop
    nop
    inc bc
    nop
    nop
    nop
    nop
    inc b
    nop
    nop
    nop
    nop
    ld [bc], a
    ld bc, $2090
    inc h
    ld [hl+], a
    nop
    jr nz, jr_002_7e02

jr_002_7e02:
    nop
    ld [$9200], sp
    sub c
    ld [$0000], sp
    db $10
    add b
    ld bc, $2400
    ld [$0020], sp
    nop
    add d
    nop
    nop
    inc c
    ld b, d
    jr z, @-$76

    inc l
    ld a, [bc]
    inc b
    nop
    ld b, h
    nop
    jr z, jr_002_7e3c

    ld bc, $0c08
    inc b
    nop
    add h
    jr z, jr_002_7e3e

    ld [$8400], sp
    jr nz, jr_002_7e4f

    add b
    ld [$0402], sp

jr_002_7e33:
    jr nz, @+$0a

    jr nz, jr_002_7db7

    add b
    ld bc, $2802
    nop

jr_002_7e3c:
    jr nz, jr_002_7e5e

jr_002_7e3e:
    ld hl, $8000
    ld [hl+], a
    add b
    ld [$2004], sp
    ld c, b
    ld a, [hl+]
    ld b, b
    ld [hl+], a
    nop
    nop
    jr nz, jr_002_7e4e

jr_002_7e4e:
    nop

jr_002_7e4f:
    add b
    add b
    ld [bc], a
    nop
    add b
    nop
    add b
    inc b
    ld a, [bc]
    jr nz, jr_002_7e9c

    add b
    ld b, b
    nop
    add b

jr_002_7e5e:
    ld [bc], a
    add b
    nop
    add b
    nop
    inc b
    ld b, d
    add c
    inc b
    add b
    inc b
    ld [bc], a
    jr jr_002_7e6c

jr_002_7e6c:
    ld [bc], a
    db $10
    ld [$0420], sp
    ld b, c
    jr @+$0a

    ld [bc], a
    ld b, h
    ld [$0401], sp
    nop
    ld d, b
    ld sp, $0040
    inc d
    inc b
    inc c
    ld [$1880], sp
    nop
    sub b
    ld [$0c00], sp
    ld d, h
    ld bc, $8032
    jr nc, jr_002_7e8f

jr_002_7e8f:
    inc b
    inc b
    ld bc, $4854
    ld bc, $8040
    add b
    ld b, b
    ld [bc], a
    ld d, c
    ld b, b

jr_002_7e9c:
    ld bc, $0042
    ld [$4042], sp
    ld b, c
    ld c, b
    inc d
    inc l
    ld [$090c], sp
    db $10
    inc h
    adc d
    add h
    nop
    ld [de], a
    ld b, h
    sub c
    jr nz, jr_002_7e33

    add b
    ld hl, $8104
    add hl, bc
    add b
    adc b
    jr nz, jr_002_7f06

    adc b
    inc h
    add b
    ld c, d
    ld [$0140], sp
    db $10
    add h
    add b
    add d
    ld b, b
    ld [$1121], sp
    add b
    ld b, b
    ld c, h
    nop
    adc h
    ld de, $4028
    ld c, b
    ld a, [bc]
    ld [de], a
    inc h
    ld b, h
    nop
    add d
    jr nz, jr_002_7edc

jr_002_7edc:
    sub d
    add b
    ld bc, $2220
    ld [hl+], a
    adc h
    add d
    ld sp, $2840
    jr nz, jr_002_7eea

    ld d, b

jr_002_7eea:
    nop
    ld bc, $0420
    jr nz, jr_002_7ef0

jr_002_7ef0:
    add b
    inc [hl]
    add b
    db $10
    add hl, bc
    ld b, b
    add b
    ld [hl+], a
    jr nz, jr_002_7efc

    nop
    nop

jr_002_7efc:
    add b
    ld b, b
    nop
    nop
    add b
    nop
    ld [$0000], sp
    nop

jr_002_7f06:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    sub b
    nop
    jr nc, jr_002_7f11

jr_002_7f11:
    nop
    nop
    or b
    jr nc, jr_002_7f16

jr_002_7f16:
    add hl, de
    ld [$1000], sp
    jr nc, jr_002_7f28

    dec [hl]
    and b
    dec l
    or b
    nop
    nop
    nop
    inc c
    nop
    sub b
    nop
    nop

jr_002_7f28:
    nop
    db $10
    ld [$0800], sp
    inc c
    sbc b
    ld [$0400], sp
    inc b
    ld a, [bc]
    cp h
    inc e
    inc b
    inc c
    cp b
    sub b
    ld [$0c48], sp
    jr nc, @+$52

    inc b
    jr nz, jr_002_7f50

    dec c
    ld b, d
    or h
    ld [hl], b
    add hl, de
    inc b
    ld [hl], h
    inc c
    inc b
    ld b, d
    ld c, $70
    nop
    nop

jr_002_7f50:
    nop
    nop
    nop
    ld a, [hl+]
    ld a, $00
    nop
    inc c
    nop
    nop
    inc c
    ld [$0004], sp
    ld [$0060], sp
    ld a, [bc]
    nop
    or d
    ld d, b
    ld b, $00
    ld h, b
    or b
    ld a, [bc]
    db $10
    ld [$9802], sp
    nop
    ld l, $b0
    inc c
    dec b
    ld a, [bc]
    nop
    ld b, $04
    or b
    ld d, b
    sub b
    ld [$0022], sp
    ld b, $20
    ld b, $40
    jr nc, @-$56

    ld [$7600], sp
    jr nz, jr_002_7fe4

    ld [bc], a
    ld c, $2c
    nop
    ld c, $92
    jr nc, jr_002_7fc8

    ld b, b
    db $10
    jr c, jr_002_7fa2

    inc c
    ld l, b
    sbc l
    jr jr_002_7fa7

    jr c, jr_002_7fa3

    ld [$0058], sp
    ld b, l
    db $10
    inc b
    db $10

jr_002_7fa2:
    and b

jr_002_7fa3:
    nop
    nop
    ld l, $19

jr_002_7fa7:
    ld l, h
    nop

jr_002_7fa9:
    nop
    inc b
    ld b, l
    dec c
    or b
    inc h
    nop
    nop
    inc a
    ld b, b
    ld [$7404], sp
    dec b
    ld [$0c06], sp
    ld [$985c], sp
    ld d, $90
    ld h, b
    nop
    dec d
    jr nc, @+$50

    dec [hl]
    nop
    dec a
    dec c

jr_002_7fc8:
    nop
    sub b
    ld c, $0c
    dec c
    xor b
    ld l, l
    inc h
    xor h
    nop
    nop
    or h
    nop
    nop
    ld c, $00
    or b
    sub b
    ld [$0c04], sp
    sub l
    jr nz, @-$6e

    dec c
    nop
    inc b
    ld c, b

jr_002_7fe4:
    ld [de], a
    ld [$0405], sp
    inc c
    jr nc, jr_002_7fa9

    ld c, l
    add hl, bc
    ld c, $3d
    sub b
    ld a, $30
    nop
    ld a, [de]
    ld [hl], $9d
    ld [$1000], sp
    ld a, [bc]
    ld [$0da0], sp
    jr nz, @-$6e

    ld h, b
