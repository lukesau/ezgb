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

MemCpy16_B3_wordLoop::
    ld hl, sp+$00
    ld a, [hl]
    sub $02
    jp c, MemCpy16_B3_byteTail

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
    jp MemCpy16_B3_wordLoop


MemCpy16_B3_byteTail::
    ld hl, sp+$00
    ld c, [hl]

MemCpy16_B3_byteLoop::
    ld b, c
    dec c
    xor a
    or b
    jp z, MemCpy16_B3_epilogue

    ld hl, sp+$01
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    dec hl
    inc [hl]
    jr nz, MemCpy16_B3_storeByte

    inc hl
    inc [hl]

MemCpy16_B3_storeByte::
    ld hl, sp+$03
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, MemCpy16_B3_byteNext

    inc hl
    inc [hl]

MemCpy16_B3_byteNext::
    jp MemCpy16_B3_byteLoop


MemCpy16_B3_epilogue::
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

MemSet8_B3_decN::
    ld b, c
    dec c
    xor a
    or b
    jp z, MemSet8_B3_epilogueRet

    ld hl, sp+$06
    ld a, [hl]
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, MemSet8_B3_storeCont

    inc hl
    inc [hl]

MemSet8_B3_storeCont::
    jp MemSet8_B3_decN


MemSet8_B3_epilogueRet::
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

MemCmp_B3_loop::
    ld hl, sp+$02
    ld b, [hl]
    dec [hl]
    xor a
    or b
    jp z, MemCmp_B3_epilogue

    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    dec hl
    inc [hl]
    jr nz, MemCmp_B3_storeA

    inc hl
    inc [hl]

MemCmp_B3_storeA::
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
    jr nz, MemCmp_B3_compare

    inc hl
    inc [hl]

MemCmp_B3_compare::
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
    jp z, MemCmp_B3_loop

MemCmp_B3_epilogue::
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

MemChr_B3_loop::
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    or a
    jp z, MemChr_B3_epilogue

    ld a, c
    rla
    sbc a
    ld b, a
    ld a, c
    ld hl, sp+$06
    sub [hl]
    jp nz, MemChr_B3_next

    ld a, b
    inc hl
    sub [hl]
    jp z, MemChr_B3_epilogue

MemChr_B3_next::
    ld hl, sp+$00
    inc [hl]
    jr nz, MemChr_B3_nextJr

    inc hl
    inc [hl]

MemChr_B3_nextJr::
    jp MemChr_B3_loop


MemChr_B3_epilogue::
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
    jp z, SyncWindow_B3_epilogue

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
    jp z, SyncWindow_B3_clearDirty

    ld hl, sp+$10
    ld [hl], $01
    jp SyncWindow_B3_epilogue


SyncWindow_B3_clearDirty::
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
    jp nc, SyncWindow_B3_epilogue

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

SyncWindow_B3_mirrorFat::
    ld hl, sp+$00
    ld a, [hl]
    sub $02
    inc hl
    ld a, [hl]
    sbc $00
    jp c, SyncWindow_B3_epilogue

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
    jp SyncWindow_B3_mirrorFat


SyncWindow_B3_epilogue::
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
    jp nz, MoveWindow_B3_reload

    ld hl, sp+$0e
    ld a, [hl]
    ld hl, sp+$01
    sub [hl]
    jp nz, MoveWindow_B3_reload

    ld hl, sp+$0f
    ld a, [hl]
    ld hl, sp+$02
    sub [hl]
    jp nz, MoveWindow_B3_reload

    ld hl, sp+$10
    ld a, [hl]
    ld hl, sp+$03
    sub [hl]
    jp z, MoveWindow_B3_epilogue

MoveWindow_B3_reload::
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
    jp nz, MoveWindow_B3_epilogue

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
    jp z, MoveWindow_B3_storeWinsect

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

MoveWindow_B3_storeWinsect::
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

MoveWindow_B3_epilogue::
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
    jp nz, SyncFs_B3_epilogue

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
    jp nz, SyncFs_B3_checkFsiFlag

    jr SyncFs_B3_fsiFlagBody

SyncFs_B3_checkFsiFlag::
    jp SyncFs_B3_ioctlSync


SyncFs_B3_fsiFlagBody::
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
    jp nz, SyncFs_B3_buildFsInfo

    jr SyncFs_B3_fillWin

SyncFs_B3_buildFsInfo::
    jp SyncFs_B3_ioctlSync


SyncFs_B3_fillWin::
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
    jr nz, SyncFs_B3_diskWrite

    inc hl
    inc [hl]
    jr nz, SyncFs_B3_diskWrite

    inc hl
    inc [hl]
    jr nz, SyncFs_B3_diskWrite

    inc hl
    inc [hl]

SyncFs_B3_diskWrite::
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

SyncFs_B3_ioctlSync::
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
    jp z, SyncFs_B3_epilogue

    ld hl, sp+$10
    ld [hl], $01

SyncFs_B3_epilogue::
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
    jp c, Clust2Sect_B3_inRange

    ld de, $0000
    ld hl, $0000
    jp Clust2Sect_B3_epilogue


Clust2Sect_B3_inRange::
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

Clust2Sect_B3_epilogue::
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
    jp c, GetFat_B3_intErr

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
    jp c, GetFat_B3_switchType

GetFat_B3_intErr::
    ld hl, sp+$08
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    jp GetFat_B3_epilogue


GetFat_B3_switchType::
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
    jp c, GetFat_B3_badType

    ld a, $03
    sub c
    jp c, GetFat_B3_badType

    dec c
    ld e, c
    ld d, $00
    ld hl, $478a
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp GetFat_B3_fat12


    jp GetFat_B3_fat16


    jp GetFat_B3_fat32


GetFat_B3_fat12::
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
    jp nz, GetFat_B3_epilogue

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
    jr nz, GetFat_B3_fat12WinOff

    inc hl
    inc [hl]

GetFat_B3_fat12WinOff::
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
    jp nz, GetFat_B3_epilogue

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
    jr nz, GetFat_B3_fat12Odd

    jp GetFat_B3_fat12Even


GetFat_B3_fat12Odd::
    ld hl, sp+$12
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, $04

GetFat_B3_fat12Shr4::
    srl b
    rr c
    dec a
    jr nz, GetFat_B3_fat12Shr4

    jp GetFat_B3_storeVal


GetFat_B3_fat12Even::
    ld hl, sp+$12
    ld c, [hl]
    inc hl
    ld a, [hl]
    and $0f
    ld b, a

GetFat_B3_storeVal::
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp GetFat_B3_epilogue


GetFat_B3_fat16::
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
    jp nz, GetFat_B3_epilogue

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
    jp GetFat_B3_epilogue


GetFat_B3_fat32::
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
    jp nz, GetFat_B3_epilogue

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
    jp GetFat_B3_epilogue


GetFat_B3_badType::
    ld hl, sp+$08
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

GetFat_B3_epilogue::
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
    jp c, PutFat_B3_intErr

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
    jp c, PutFat_B3_switchType

PutFat_B3_intErr::
    ld hl, sp+$14
    ld [hl], $02
    jp PutFat_B3_epilogue


PutFat_B3_switchType::
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    sub $01
    jp c, PutFat_B3_badType

    ld a, $03
    sub b
    jp c, PutFat_B3_badType

    dec b
    ld e, b
    ld d, $00
    ld hl, $4b5d
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp PutFat_B3_fat12


    jp PutFat_B3_fat16


    jp PutFat_B3_fat32


PutFat_B3_fat12::
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
    jp nz, PutFat_B3_epilogue

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
    jr nz, PutFat_B3_fat12WinOff

    inc hl
    inc [hl]

PutFat_B3_fat12WinOff::
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
    jp z, PutFat_B3_fat12EvenFirst

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
    jp PutFat_B3_fat12StoreFirst


PutFat_B3_fat12EvenFirst::
    ld hl, sp+$21
    ld b, [hl]

PutFat_B3_fat12StoreFirst::
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
    jp nz, PutFat_B3_epilogue

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
    jp z, PutFat_B3_fat12Second

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
    jp PutFat_B3_fat12StoreSecond


PutFat_B3_fat12Second::
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

PutFat_B3_fat12StoreSecond::
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
    jp PutFat_B3_epilogue


PutFat_B3_fat16::
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
    jp nz, PutFat_B3_epilogue

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
    jp PutFat_B3_epilogue


PutFat_B3_fat32::
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
    jp nz, PutFat_B3_epilogue

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
    jp PutFat_B3_epilogue


PutFat_B3_badType::
    ld hl, sp+$14
    ld [hl], $02

PutFat_B3_epilogue::
    ld hl, sp+$14
    ld e, [hl]
    add sp, $19
    ret


; [ezgb]
; RemoveChain_B3(fs, clst, pclst): FatFs remove_chain. Frame -$0e; walk FAT from fs+clst toward clst.
; clst<2 → RemoveChain_B3_intErr B=$02; start cluster > clst → RemoveChain_B3_okInit B=$00 else RemoveChain_B3_intErr.
; RemoveChain_B3_walkLoop loop: walker≥clst → RemoveChain_B3_epilogue ret B; GetFat_B3; FAT zero → RemoveChain_B3_epilogue.
; FAT==1 → RemoveChain_B3_fatIntErr B=$02 else RemoveChain_B3_notIntFat→RemoveChain_B3_checkDiskErr; inc FAT wraps → RemoveChain_B3_diskErr B=$01 else RemoveChain_B3_notDiskErr→RemoveChain_B3_putFatFree.
; RemoveChain_B3_putFatFree: PutFat_B3 free slot; err → RemoveChain_B3_epilogue; advance walker — inc hits 0 → RemoveChain_B3_stashFinal else RemoveChain_B3_decFreeClst (RemoveChain_B3_setDirty) + FA_DIRTY → RemoveChain_B3_walkLoop.
; RemoveChain_B3_stashFinal: stash final cluster@sp+$12 → RemoveChain_B3_walkLoop; RemoveChain_B3_epilogue: ld e,B / add sp,$0e / ret.

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
    jp c, RemoveChain_B3_intErr

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
    jp c, RemoveChain_B3_okInit

RemoveChain_B3_intErr::
    ld b, $02
    jp RemoveChain_B3_epilogue


RemoveChain_B3_okInit::
    ld b, $00

RemoveChain_B3_walkLoop::
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
    jp nc, RemoveChain_B3_epilogue

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
    jp z, RemoveChain_B3_epilogue

    ld hl, sp+$0a
    ld a, [hl]
    sub $01
    jp nz, RemoveChain_B3_notIntFat

    inc hl
    ld a, [hl]
    or a
    jp nz, RemoveChain_B3_notIntFat

    inc hl
    ld a, [hl]
    or a
    jp nz, RemoveChain_B3_notIntFat

    inc hl
    ld a, [hl]
    or a
    jp nz, RemoveChain_B3_notIntFat

    jr RemoveChain_B3_fatIntErr

RemoveChain_B3_notIntFat::
    jp RemoveChain_B3_checkDiskErr


RemoveChain_B3_fatIntErr::
    ld b, $02
    jp RemoveChain_B3_epilogue


RemoveChain_B3_checkDiskErr::
    ld hl, sp+$0a
    ld a, [hl]
    inc a
    jp nz, RemoveChain_B3_notDiskErr

    inc hl
    ld a, [hl]
    inc a
    jp nz, RemoveChain_B3_notDiskErr

    inc hl
    ld a, [hl]
    inc a
    jp nz, RemoveChain_B3_notDiskErr

    inc hl
    ld a, [hl]
    inc a
    jp nz, RemoveChain_B3_notDiskErr

    jr RemoveChain_B3_diskErr

RemoveChain_B3_notDiskErr::
    jp RemoveChain_B3_putFatFree


RemoveChain_B3_diskErr::
    ld b, $01
    jp RemoveChain_B3_epilogue


RemoveChain_B3_putFatFree::
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
    jp nz, RemoveChain_B3_epilogue

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
    jp nz, RemoveChain_B3_decFreeClst

    inc hl
    ld a, [hl]
    inc a
    jp nz, RemoveChain_B3_decFreeClst

    inc hl
    ld a, [hl]
    inc a
    jp nz, RemoveChain_B3_decFreeClst

    inc hl
    ld a, [hl]
    inc a
    jp z, RemoveChain_B3_stashFinal

RemoveChain_B3_decFreeClst::
    ld hl, sp+$02
    inc [hl]
    jr nz, RemoveChain_B3_setDirty

    inc hl
    inc [hl]
    jr nz, RemoveChain_B3_setDirty

    inc hl
    inc [hl]
    jr nz, RemoveChain_B3_setDirty

    inc hl
    inc [hl]

RemoveChain_B3_setDirty::
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

RemoveChain_B3_stashFinal::
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
    jp RemoveChain_B3_walkLoop


RemoveChain_B3_epilogue::
    ld e, b
    add sp, $0e
    ret


; [ezgb]
; CreateChain_B3(fs, clst, target): FatFs create_chain / cluster extend.
; clst!=0 CreateChain_B3_getFatExisting GetFat_B3: clst<2 → CreateChain_B3_epilogue (1,0); CreateChain_B3_afterGetFat: clst==-1 CreateChain_B3_eofCluster else CreateChain_B3_notEofCluster/CreateChain_B3_cmpNFatent compare n_fatent (past CreateChain_B3_stretchOk else CreateChain_B3_epilogue).
; clst==0: free_clst vs n_fatent; empty CreateChain_B3_clstEmptySet1 clst=1; join CreateChain_B3_copyScanState copy state.
; CreateChain_B3_copyScanState alloc scan CreateChain_B3_allocScan (CreateChain_B3_allocScanCont): hit end CreateChain_B3_scanHitEnd GetFat_B3; no free + scan done → CreateChain_B3_epilogue (0,0).
; CreateChain_B3_eofCheck/CreateChain_B3_eofCheckCont/CreateChain_B3_eofCheckVal/CreateChain_B3_eofCheckVal EOF checks; CreateChain_B3_matchScanStart match CreateChain_B3_noFreeRet0 (0,0) else CreateChain_B3_scanContinue → CreateChain_B3_allocScan.
; CreateChain_B3_scanHitEnd free slot CreateChain_B3_putFatLink PutFat_B3 link; fail CreateChain_B3_putFatFail/CreateChain_B3_putFatFailCont/CreateChain_B3_diskErrorRet/CreateChain_B3_setFrNoFilesystem set FR_NO_FILESYSTEM.
; CreateChain_B3_updateFreeClst: update fs free_clst/fatbase; CreateChain_B3_linkAndDirty link + FA_DIRTY or CreateChain_B3_newChainOnly; CreateChain_B3_storeResult store; CreateChain_B3_epilogue epilogue (add sp,$1b / ret).

CreateChain_B3::
    add sp, -$1b
    ld hl, sp+$1f
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, CreateChain_B3_getFatExisting

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
    jp z, CreateChain_B3_clstEmptySet1

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
    jp c, CreateChain_B3_copyScanState

CreateChain_B3_clstEmptySet1::
    ld hl, sp+$0f
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    jp CreateChain_B3_copyScanState


CreateChain_B3_getFatExisting::
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
    jp nc, CreateChain_B3_afterGetFat

    ld de, $0001
    ld hl, $0000
    jp CreateChain_B3_epilogue


CreateChain_B3_afterGetFat::
    ld hl, sp+$17
    ld a, [hl]
    inc a
    jp nz, CreateChain_B3_notEofCluster

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B3_notEofCluster

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B3_notEofCluster

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B3_notEofCluster

    jr CreateChain_B3_eofCluster

CreateChain_B3_notEofCluster::
    jp CreateChain_B3_cmpNFatent


CreateChain_B3_eofCluster::
    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp CreateChain_B3_epilogue


CreateChain_B3_cmpNFatent::
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
    jp nc, CreateChain_B3_stretchOk

    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp CreateChain_B3_epilogue


CreateChain_B3_stretchOk::
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

CreateChain_B3_copyScanState::
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

CreateChain_B3_allocScan::
    ld hl, sp+$13
    inc [hl]
    jr nz, CreateChain_B3_allocScanCont

    inc hl
    inc [hl]
    jr nz, CreateChain_B3_allocScanCont

    inc hl
    inc [hl]
    jr nz, CreateChain_B3_allocScanCont

    inc hl
    inc [hl]

CreateChain_B3_allocScanCont::
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
    jp c, CreateChain_B3_scanHitEnd

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
    jp z, CreateChain_B3_scanHitEnd

    ld de, $0000
    ld hl, $0000
    jp CreateChain_B3_epilogue


CreateChain_B3_scanHitEnd::
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
    jp z, CreateChain_B3_putFatLink

    ld hl, sp+$17
    ld a, [hl]
    inc a
    jp nz, CreateChain_B3_eofCheck

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B3_eofCheck

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B3_eofCheck

    inc hl
    ld a, [hl]
    inc a
    jp z, CreateChain_B3_eofCheckVal

CreateChain_B3_eofCheck::
    ld hl, sp+$17
    ld a, [hl]
    sub $01
    jp nz, CreateChain_B3_eofCheckCont

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateChain_B3_eofCheckCont

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateChain_B3_eofCheckCont

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateChain_B3_eofCheckCont

    jr CreateChain_B3_eofCheckVal

CreateChain_B3_eofCheckCont::
    jp CreateChain_B3_matchScanStart


CreateChain_B3_eofCheckVal::
    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp CreateChain_B3_epilogue


CreateChain_B3_matchScanStart::
    ld hl, sp+$13
    ld a, [hl]
    ld hl, sp+$0f
    sub [hl]
    jp nz, CreateChain_B3_scanContinue

    ld hl, sp+$14
    ld a, [hl]
    ld hl, sp+$10
    sub [hl]
    jp nz, CreateChain_B3_scanContinue

    ld hl, sp+$15
    ld a, [hl]
    ld hl, sp+$11
    sub [hl]
    jp nz, CreateChain_B3_scanContinue

    ld hl, sp+$16
    ld a, [hl]
    ld hl, sp+$12
    sub [hl]
    jp nz, CreateChain_B3_scanContinue

    jr CreateChain_B3_noFreeRet0

CreateChain_B3_scanContinue::
    jp CreateChain_B3_allocScan


CreateChain_B3_noFreeRet0::
    ld de, $0000
    ld hl, $0000
    jp CreateChain_B3_epilogue


CreateChain_B3_putFatLink::
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
    jp nz, CreateChain_B3_updateFreeClst

    ld hl, sp+$1f
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, CreateChain_B3_updateFreeClst

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

CreateChain_B3_updateFreeClst::
    xor a
    or c
    jp nz, CreateChain_B3_putFatFail

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
    jp nz, CreateChain_B3_linkAndDirty

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B3_linkAndDirty

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B3_linkAndDirty

    inc hl
    ld a, [hl]
    inc a
    jp z, CreateChain_B3_newChainOnly

CreateChain_B3_linkAndDirty::
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
    jp CreateChain_B3_newChainOnly


CreateChain_B3_putFatFail::
    ld a, c
    sub $01
    jp nz, CreateChain_B3_putFatFailCont

    jr CreateChain_B3_diskErrorRet

CreateChain_B3_putFatFailCont::
    jp CreateChain_B3_setFrNoFilesystem


CreateChain_B3_diskErrorRet::
    ld hl, sp+$00
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    jp CreateChain_B3_storeResult


CreateChain_B3_setFrNoFilesystem::
    ld hl, sp+$00
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

CreateChain_B3_storeResult::
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

CreateChain_B3_newChainOnly::
    ld hl, sp+$13
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a

CreateChain_B3_epilogue::
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
    jp nz, DirSdi_B3_rangeCheck

    inc hl
    ld a, [hl]
    or a
    jp nz, DirSdi_B3_rangeCheck

    inc hl
    ld a, [hl]
    or a
    jp nz, DirSdi_B3_rangeCheck

    inc hl
    ld a, [hl]
    or a
    jp z, DirSdi_B3_intErr

DirSdi_B3_rangeCheck::
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
    jp c, DirSdi_B3_afterRange

DirSdi_B3_intErr::
    ld e, $02
    jp DirSdi_B3_epilogue


DirSdi_B3_afterRange::
    ld hl, sp+$12
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, DirSdi_B3_staticOrDyn

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
    jp nz, DirSdi_B3_notFat32Root

    jr DirSdi_B3_fat32RootBase

DirSdi_B3_notFat32Root::
    jp DirSdi_B3_staticOrDyn


DirSdi_B3_fat32RootBase::
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

DirSdi_B3_staticOrDyn::
    ld hl, sp+$12
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, DirSdi_B3_dynCsize

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
    jp c, DirSdi_B3_staticSect

    ld e, $02
    jp DirSdi_B3_epilogue


DirSdi_B3_staticSect::
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
    jp DirSdi_B3_storeClust


DirSdi_B3_dynCsize::
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
    jr DirSdi_B3_csizeShiftLoop

DirSdi_B3_csizeShift::
    ld hl, sp+$0c
    sla [hl]
    inc hl
    rl [hl]

DirSdi_B3_csizeShiftLoop::
    dec a
    jr nz, DirSdi_B3_csizeShift

DirSdi_B3_followLoop::
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
    jp c, DirSdi_B3_clust2Sect

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
    jp nz, DirSdi_B3_afterGetFat

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirSdi_B3_afterGetFat

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirSdi_B3_afterGetFat

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirSdi_B3_afterGetFat

    jr DirSdi_B3_diskErr

DirSdi_B3_afterGetFat::
    jp DirSdi_B3_checkClust


DirSdi_B3_diskErr::
    ld e, $01
    jp DirSdi_B3_epilogue


DirSdi_B3_checkClust::
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
    jp c, DirSdi_B3_clustIntErr

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
    jp c, DirSdi_B3_subCsz

DirSdi_B3_clustIntErr::
    ld e, $02
    jp DirSdi_B3_epilogue


DirSdi_B3_subCsz::
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
    jp DirSdi_B3_followLoop


DirSdi_B3_clust2Sect::
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

DirSdi_B3_storeClust::
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
    jp nz, DirSdi_B3_setSectDir

    ld e, $02
    jp DirSdi_B3_epilogue


DirSdi_B3_setSectDir::
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

DirSdi_B3_sectDiv::
    srl b
    rr c
    dec a
    jr nz, DirSdi_B3_sectDiv

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

DirSdi_B3_epilogue::
    add sp, $16
    ret


; [ezgb]
; DirNext_B3(dp, stretch): FatFs dir_next. Frame -$22; ++dp->dptr index; walk dir sectors/clusters.
; Index+1==0 → DirNext_B3_noFile E=$04 (FR_NO_FILE); load dir entry@dp+$0e — four dwords zero → DirNext_B3_noFile.
; DirNext_B3_checkInSector: index&$0f≠0 → DirNext_B3_advanceOk in-sector advance; else inc sector (DirNext_B3_incSector carry chain) + copy 32-byte slot.
; Next cluster from dp chain zero → DirNext_B3_stretchPath stretch path; volsize compare fail → DirNext_B3_advanceOk else E=$04 → DirNext_B3_epilogue.
; DirNext_B3_stretchPath: sector→cluster via DirNext_B3_sectToClust ÷16; fs-type mask vs cluster → nz DirNext_B3_advanceOk; GetFat_B3.
; Cluster−1 underflow → DirNext_B3_clustUnderflow: inc cluster words — all zero DirNext_B3_intErr E=$01 else DirNext_B3_clustIncOk→DirNext_B3_afterClustInc.
; DirNext_B3_afterClustInc: cluster<saved → DirNext_B3_storeClust; stretch==0 → E=$04 DirNext_B3_epilogue else DirNext_B3_createChain CreateChain_B3.
; CreateChain result zero → E=$07 DirNext_B3_epilogue; else DirNext_B3_afterCreateChain cluster−1 all zero → DirNext_B3_diskErr E=$02 else DirNext_B3_newClustOk→DirNext_B3_incNewClust.
; DirNext_B3_incNewClust: inc cluster words — all wrap DirNext_B3_syncIntErr E=$01 else DirNext_B3_newClustWrapOk→DirNext_B3_syncWindow SyncWindow_B3.
; DirNext_B3_syncWindow: SyncWindow_B3 err→E=$01 DirNext_B3_epilogue else DirNext_B3_clearDirBuf MemSet8 dir buf + Clust2Sect → DirNext_B3_sectorLoop sector loop.
; DirNext_B3_sectorLoop: offset≥ssize → DirNext_B3_partialTail else dirty+SyncWindow; err E=$01; DirNext_B3_stampTemplate stamp template (DirNext_B3_stampCont/DirNext_B3_stampNext) → DirNext_B3_sectorLoop.
; DirNext_B3_partialTail: partial tail copy + sector base for index; DirNext_B3_storeClust store cluster + Clust2Sect → window sector.
; DirNext_B3_advanceOk: write index@dp+$04, ptr@dp+$12+idx*32, E=0; DirNext_B3_epilogue add sp,$22 ret E.

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
    jp z, DirNext_B3_noFile

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
    jp nz, DirNext_B3_checkInSector

DirNext_B3_noFile::
    ld e, $04
    jp DirNext_B3_epilogue


DirNext_B3_checkInSector::
    ld hl, sp+$1c
    ld a, [hl]
    and $0f
    ld hl, sp+$10
    ld [hl+], a
    ld [hl], $00
    dec hl
    ld a, [hl+]
    or [hl]
    jp nz, DirNext_B3_advanceOk

    inc hl
    inc [hl]
    jr nz, DirNext_B3_incSector

    inc hl
    inc [hl]
    jr nz, DirNext_B3_incSector

    inc hl
    inc [hl]
    jr nz, DirNext_B3_incSector

    inc hl
    inc [hl]

DirNext_B3_incSector::
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
    jp nz, DirNext_B3_stretchPath

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
    jp c, DirNext_B3_advanceOk

    ld e, $04
    jp DirNext_B3_epilogue


DirNext_B3_stretchPath::
    ld hl, sp+$1c
    ld a, [hl]
    ld hl, sp+$08
    ld [hl], a
    ld hl, sp+$1d
    ld a, [hl]
    ld hl, sp+$09
    ld [hl], a
    ld a, $04

DirNext_B3_sectToClust::
    ld hl, sp+$09
    srl [hl]
    dec hl
    rr [hl]
    dec a
    jr nz, DirNext_B3_sectToClust

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
    jp nz, DirNext_B3_advanceOk

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
    jp c, DirNext_B3_clustUnderflow

    ld e, $02
    jp DirNext_B3_epilogue


DirNext_B3_clustUnderflow::
    ld hl, sp+$1e
    ld a, [hl]
    inc a
    jp nz, DirNext_B3_clustIncOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirNext_B3_clustIncOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirNext_B3_clustIncOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirNext_B3_clustIncOk

    jr DirNext_B3_intErr

DirNext_B3_clustIncOk::
    jp DirNext_B3_afterClustInc


DirNext_B3_intErr::
    ld e, $01
    jp DirNext_B3_epilogue


DirNext_B3_afterClustInc::
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
    jp c, DirNext_B3_storeClust

    ld hl, sp+$26
    ld a, [hl+]
    or [hl]
    jp nz, DirNext_B3_createChain

    ld e, $04
    jp DirNext_B3_epilogue


DirNext_B3_createChain::
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
    jp nz, DirNext_B3_afterCreateChain

    ld e, $07
    jp DirNext_B3_epilogue


DirNext_B3_afterCreateChain::
    ld hl, sp+$1e
    ld a, [hl]
    sub $01
    jp nz, DirNext_B3_newClustOk

    inc hl
    ld a, [hl]
    or a
    jp nz, DirNext_B3_newClustOk

    inc hl
    ld a, [hl]
    or a
    jp nz, DirNext_B3_newClustOk

    inc hl
    ld a, [hl]
    or a
    jp nz, DirNext_B3_newClustOk

    jr DirNext_B3_diskErr

DirNext_B3_newClustOk::
    jp DirNext_B3_incNewClust


DirNext_B3_diskErr::
    ld e, $02
    jp DirNext_B3_epilogue


DirNext_B3_incNewClust::
    ld hl, sp+$1e
    ld a, [hl]
    inc a
    jp nz, DirNext_B3_newClustWrapOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirNext_B3_newClustWrapOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirNext_B3_newClustWrapOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirNext_B3_newClustWrapOk

    jr DirNext_B3_syncIntErr

DirNext_B3_newClustWrapOk::
    jp DirNext_B3_syncWindow


DirNext_B3_syncIntErr::
    ld e, $01
    jp DirNext_B3_epilogue


DirNext_B3_syncWindow::
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
    jp z, DirNext_B3_clearDirBuf

    ld e, $01
    jp DirNext_B3_epilogue


DirNext_B3_clearDirBuf::
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

DirNext_B3_sectorLoop::
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
    jp nc, DirNext_B3_partialTail

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
    jp z, DirNext_B3_stampTemplate

    ld e, $01
    jp DirNext_B3_epilogue


DirNext_B3_stampTemplate::
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
    jr nz, DirNext_B3_stampCont

    inc hl
    inc [hl]
    jr nz, DirNext_B3_stampCont

    inc hl
    inc [hl]
    jr nz, DirNext_B3_stampCont

    inc hl
    inc [hl]

DirNext_B3_stampCont::
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
    jr nz, DirNext_B3_stampNext

    inc hl
    inc [hl]

DirNext_B3_stampNext::
    ld hl, sp+$1a
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], e
    jp DirNext_B3_sectorLoop


DirNext_B3_partialTail::
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

DirNext_B3_storeClust::
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

DirNext_B3_advanceOk::
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

DirNext_B3_epilogue::
    add sp, $22
    ret


; [ezgb]
; DirAlloc_B3(dp): FatFs dir_alloc. Frame -$0b; scan for free dir slot via DirSdi_B3(0) + DirNext_B3(1).
; DirSdi err → DirAlloc_B3_done; DirAlloc_B3_scanLoop: load cluster@dp+$0e, MoveWindow_B3 err → DirAlloc_B3_done.
; SFN[0] DDEM $E5 or empty → DirAlloc_B3_incFreeRun else DirAlloc_B3_resetRun reset run counter → DirAlloc_B3_dirNext DirNext_B3(1).
; DirAlloc_B3_incFreeRun: ++free-run (DirAlloc_B3_checkRunLen); run==n_dir → DirAlloc_B3_runComplete→DirAlloc_B3_done else DirAlloc_B3_needMore→DirAlloc_B3_dirNext.
; DirNext ok → DirAlloc_B3_scanLoop; DirAlloc_B3_done: E==$04 → DirAlloc_B3_denied E=$07 else DirAlloc_B3_keepErr→DirAlloc_B3_epilogue ret E.

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
    jp nz, DirAlloc_B3_done

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

DirAlloc_B3_scanLoop::
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
    jp nz, DirAlloc_B3_done

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
    jp z, DirAlloc_B3_incFreeRun

    xor a
    or c
    jp nz, DirAlloc_B3_resetRun

DirAlloc_B3_incFreeRun::
    ld hl, sp+$08
    inc [hl]
    jr nz, DirAlloc_B3_checkRunLen

    inc hl
    inc [hl]

DirAlloc_B3_checkRunLen::
    ld hl, sp+$08
    ld a, [hl]
    ld hl, sp+$0f
    sub [hl]
    jp nz, DirAlloc_B3_needMore

    ld hl, sp+$09
    ld a, [hl]
    ld hl, sp+$10
    sub [hl]
    jp nz, DirAlloc_B3_needMore

    jr DirAlloc_B3_runComplete

DirAlloc_B3_needMore::
    jp DirAlloc_B3_dirNext


DirAlloc_B3_runComplete::
    jp DirAlloc_B3_done


DirAlloc_B3_resetRun::
    ld hl, sp+$08
    ld [hl], $00
    inc hl
    ld [hl], $00

DirAlloc_B3_dirNext::
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
    jp z, DirAlloc_B3_scanLoop

DirAlloc_B3_done::
    ld hl, sp+$0a
    ld a, [hl]
    sub $04
    jp nz, DirAlloc_B3_keepErr

    jr DirAlloc_B3_denied

DirAlloc_B3_keepErr::
    jp DirAlloc_B3_epilogue


DirAlloc_B3_denied::
    ld hl, sp+$0a
    ld [hl], $07

DirAlloc_B3_epilogue::
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
    jp nz, LdClust_B3_notFat32

    jr LdClust_B3_orHiWord

LdClust_B3_notFat32::
    jp LdClust_B3_epilogue


LdClust_B3_orHiWord::
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

LdClust_B3_epilogue::
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
    jp z, CmpLfn_B3_initOffset

    ld de, $0000
    jp CmpLfn_B3_epilogue


CmpLfn_B3_initOffset::
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

CmpLfn_B3_charLoop::
    ld hl, sp+$0a
    ld a, [hl]
    sub $0d
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, CmpLfn_B3_checkLastSeg

    ld de, LfnOfs_B3
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
    jp z, CmpLfn_B3_checkFiller

    ld hl, sp+$02
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, CmpLfn_B3_mismatch

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
    jr nz, CmpLfn_B3_compareUpper

    inc hl
    inc [hl]

CmpLfn_B3_compareUpper::
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
    jp nz, CmpLfn_B3_mismatch

    inc hl
    ld a, [hl]
    sub b
    jp z, CmpLfn_B3_storeWc

CmpLfn_B3_mismatch::
    ld de, $0000
    jp CmpLfn_B3_epilogue


CmpLfn_B3_storeWc::
    ld hl, sp+$06
    ld a, [hl+]
    ld e, [hl]
    inc hl
    ld [hl+], a
    ld [hl], e
    jp CmpLfn_B3_nextChar


CmpLfn_B3_checkFiller::
    ld hl, sp+$06
    ld a, [hl]
    inc a
    jp nz, CmpLfn_B3_fillerBad

    inc hl
    ld a, [hl]
    inc a
    jp z, CmpLfn_B3_nextChar

CmpLfn_B3_fillerBad::
    ld de, $0000
    jp CmpLfn_B3_epilogue


CmpLfn_B3_nextChar::
    ld hl, sp+$0a
    inc [hl]
    jr nz, CmpLfn_B3_nextCharJr

    inc hl
    inc [hl]

CmpLfn_B3_nextCharJr::
    jp CmpLfn_B3_charLoop


CmpLfn_B3_checkLastSeg::
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $40
    jr nz, CmpLfn_B3_lastSegLen

    jp CmpLfn_B3_matched


CmpLfn_B3_lastSegLen::
    ld hl, sp+$08
    ld a, [hl+]
    or [hl]
    jp z, CmpLfn_B3_matched

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
    jp z, CmpLfn_B3_matched

    ld de, $0000
    jp CmpLfn_B3_epilogue


CmpLfn_B3_matched::
    ld de, $0001

CmpLfn_B3_epilogue::
    add sp, $0e
    ret


LfnOfs_B3::
    db $01
    db $03
    db $05
    db $07
    db $09
    db $0e
    db $10
    db $12
    db $14
    db $16
    db $18
    db $1c
    db $1e
    db $e8
    db $f3
    db $f8
    db $11
    db $5e
    db $23
    db $56
    db $21
    db $1a
    db $00
    db $19
    db $4d
    db $44
    db $59
    db $50
    db $1a
    db $4f
    db $13
    db $1a
    db $47
    db $b1
    db $ca
    db $d8
    db $5f
    db $11
    db $00
    db $00
    db $c3
    db $e2
    db $60

MatchLfnEntry_B3::
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

MatchLfnEntry_charLoop_B3::
    ld hl, sp+$09
    ld a, [hl]
    sub $0d
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, MatchLfnEntry_checkLastFlag_B3

    ld de, LfnOfs_B3
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
    jp z, MatchLfnEntry_checkSentinel_B3

    ld hl, sp+$00
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp c, MatchLfnEntry_advance_B3

    ld de, $0000
    jp MatchLfnEntry_epilogue_B3


MatchLfnEntry_advance_B3::
    ld hl, sp+$00
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, MatchLfnEntry_storeOfs_B3

    inc hl
    inc [hl]

MatchLfnEntry_storeOfs_B3::
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
    jp MatchLfnEntry_nextOrd_B3


MatchLfnEntry_checkSentinel_B3::
    ld hl, sp+$05
    ld a, [hl]
    inc a
    jp nz, MatchLfnEntry_noMatch_B3

    inc hl
    ld a, [hl]
    inc a
    jp z, MatchLfnEntry_nextOrd_B3

MatchLfnEntry_noMatch_B3::
    ld de, $0000
    jp MatchLfnEntry_epilogue_B3


MatchLfnEntry_nextOrd_B3::
    ld hl, sp+$09
    inc [hl]
    jr nz, MatchLfnEntry_loopBack_B3

    inc hl
    inc [hl]

MatchLfnEntry_loopBack_B3::
    jp MatchLfnEntry_charLoop_B3


MatchLfnEntry_checkLastFlag_B3::
    ld hl, sp+$04
    ld a, [hl]
    and $40
    jr nz, MatchLfnEntry_checkSpare_B3

    jp MatchLfnEntry_matched_B3


MatchLfnEntry_checkSpare_B3::
    ld hl, sp+$0b
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp c, MatchLfnEntry_clearSpare_B3

    ld de, $0000
    jp MatchLfnEntry_epilogue_B3


MatchLfnEntry_clearSpare_B3::
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

MatchLfnEntry_matched_B3::
    ld de, $0001

MatchLfnEntry_epilogue_B3::
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

PutLfn_B3_charLoop::
    ld hl, sp+$02
    ld a, [hl]
    inc a
    jp nz, PutLfn_B3_loadWchar

    inc hl
    ld a, [hl]
    inc a
    jp z, PutLfn_B3_storeWchar

PutLfn_B3_loadWchar::
    ld hl, sp+$00
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, PutLfn_B3_indexLfn

    inc hl
    inc [hl]

PutLfn_B3_indexLfn::
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

PutLfn_B3_storeWchar::
    ld de, LfnOfs_B3
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
    jp nz, PutLfn_B3_nextSlot

    dec hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff

PutLfn_B3_nextSlot::
    ld hl, sp+$04
    inc [hl]
    jr nz, PutLfn_B3_checkDone

    inc hl
    inc [hl]

PutLfn_B3_checkDone::
    ld hl, sp+$04
    ld a, [hl]
    sub $0d
    inc hl
    ld a, [hl]
    sbc $00
    jp c, PutLfn_B3_charLoop

    ld hl, sp+$02
    ld a, [hl]
    inc a
    jp nz, PutLfn_B3_moreLfn

    inc hl
    ld a, [hl]
    inc a
    jp z, PutLfn_B3_setLlef

PutLfn_B3_moreLfn::
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
    jp nz, PutLfn_B3_storeOrd

PutLfn_B3_setLlef::
    ld hl, sp+$0c
    ld a, [hl]
    or $40
    ld [hl], a

PutLfn_B3_storeOrd::
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
    jp nc, GenNumName_B3_makeSuffix

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

GenNumName_B3_crcLfnLoop::
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
    jp z, GenNumName_B3_storeHashSeq

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

GenNumName_B3_crcBitLoop::
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
    jr nz, GenNumName_B3_crcPolyXor

    jp GenNumName_B3_crcBitNext


GenNumName_B3_crcPolyXor::
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

GenNumName_B3_crcBitNext::
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
    jp nz, GenNumName_B3_crcBitLoop

    jp GenNumName_B3_crcLfnLoop


GenNumName_B3_storeHashSeq::
    ld hl, sp+$0a
    ld a, [hl]
    ld hl, sp+$25
    ld [hl], a
    ld hl, sp+$0b
    ld a, [hl]
    ld hl, sp+$26
    ld [hl], a

GenNumName_B3_makeSuffix::
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

GenNumName_B3_hexDigit::
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
    jp nc, GenNumName_B3_storeDigit

    ld a, [hl]
    add $07
    ld [hl], a

GenNumName_B3_storeDigit::
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

GenNumName_B3_seqShr4::
    ld hl, sp+$26
    srl [hl]
    dec hl
    rr [hl]
    dec a
    jr nz, GenNumName_B3_seqShr4

    ld a, [hl+]
    or [hl]
    jp nz, GenNumName_B3_hexDigit

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

GenNumName_B3_findAppend::
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
    jp nc, GenNumName_B3_appendStart

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
    jp z, GenNumName_B3_appendStart

    ld hl, sp+$10
    inc [hl]
    jr nz, GenNumName_B3_findAppendCont

    inc hl
    inc [hl]

GenNumName_B3_findAppendCont::
    jp GenNumName_B3_findAppend


GenNumName_B3_appendStart::
    ld hl, sp+$04
    ld a, [hl+]
    ld e, [hl]
    dec hl
    ld [hl+], a
    ld [hl], e

GenNumName_B3_appendLoop::
    ld hl, sp+$10
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, GenNumName_B3_appendInc

    inc hl
    inc [hl]

GenNumName_B3_appendInc::
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
    jp nc, GenNumName_B3_appendSpace

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, GenNumName_B3_appendFromNs

    inc hl
    inc [hl]

GenNumName_B3_appendFromNs::
    ld hl, sp+$00
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    jp GenNumName_B3_appendStore


GenNumName_B3_appendSpace::
    ld c, $20

GenNumName_B3_appendStore::
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
    jp c, GenNumName_B3_appendLoop

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

SumSfn_B3_loop::
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
    jr nz, SumSfn_B3_afterPtrInc

    inc hl
    inc [hl]

SumSfn_B3_afterPtrInc::
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
    jp nz, SumSfn_B3_loop

    inc hl
    ld e, [hl]
    add sp, $05
    ret


; [ezgb]
; DirFind_B3(dp): FatFs dir_find. DirSdi_B3(0); fail DirFind_B3_initOrd init else err DirFind_B3_epilogue.
; DirFind_B3_initOrd: clear ord/hash ptrs; DirFind_B3_readEntry read entry + MoveWindow_B3; fail DirFind_B3_found; LFN chain DirFind_B3_checkAttr else ord=4 DirFind_B3_found.
; DirFind_B3_checkAttr: attr — deleted $E5 DirFind_B3_deletedEntry; volume DirFind_B3_volumeSkip; LFN ord $0F DirFind_B3_sfnPath else DirFind_B3_checkAmLfn/DirFind_B3_sfnPath SFN path.
; DirFind_B3_lfnChain: empty LFN chk DirFind_B3_dirNextLoop; AM_LFN DirFind_B3_storeOrdChksum store ord/chksum else DirFind_B3_ordCompare ord compare (DirFind_B3_ordMismatch/DirFind_B3_ordMatch/DirFind_B3_cmpLfnFail/DirFind_B3_cmpLfnOk/DirFind_B3_afterCmpLfn CmpLfn_B3).
; DirFind_B3_ordUpdateFail/DirFind_B3_ordUpdateOk/DirFind_B3_afterOrdUpdate/DirFind_B3_ordInvalidate/DirFind_B3_storeOrd: LFN ord update DirFind_B3_dirNextLoop; DirFind_B3_sumSfnMatch SumSfn_B3 match DirFind_B3_found.
; DirFind_B3_checkNtres NTRES DirFind_B3_ntresSkip skip; DirFind_B3_memcmpSfn MemCmp_B3 SFN match DirFind_B3_found else DirFind_B3_invalidate invalidate; DirFind_B3_dirNextLoop DirNext_B3 loop DirFind_B3_readEntry; DirFind_B3_found/DirFind_B3_epilogue epilogue.

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
    jp z, DirFind_B3_initOrd

    ld e, [hl]
    jp DirFind_B3_epilogue


DirFind_B3_initOrd::
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

DirFind_B3_readEntry::
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
    jp nz, DirFind_B3_found

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
    jp nz, DirFind_B3_checkAttr

    inc hl
    ld [hl], $04
    jp DirFind_B3_found


DirFind_B3_checkAttr::
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
    jp z, DirFind_B3_deletedEntry

    ld a, c
    and $08
    jr nz, DirFind_B3_volumeSkip

    jp DirFind_B3_checkAmLfn


DirFind_B3_volumeSkip::
    ld a, c
    sub $0f
    jp z, DirFind_B3_checkAmLfn

DirFind_B3_deletedEntry::
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
    jp DirFind_B3_dirNextLoop


DirFind_B3_checkAmLfn::
    ld a, c
    sub $0f
    jp nz, DirFind_B3_sfnPath

    jr DirFind_B3_lfnChain

DirFind_B3_sfnPath::
    jp DirFind_B3_sumSfnMatch


DirFind_B3_lfnChain::
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
    jp z, DirFind_B3_dirNextLoop

    ld hl, sp+$18
    ld a, [hl]
    and $40
    jr nz, DirFind_B3_storeOrdChksum

    jp DirFind_B3_ordCompare


DirFind_B3_storeOrdChksum::
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

DirFind_B3_ordCompare::
    ld hl, sp+$18
    ld a, [hl]
    ld hl, sp+$15
    sub [hl]
    jp nz, DirFind_B3_ordMismatch

    jr DirFind_B3_ordMatch

DirFind_B3_ordMismatch::
    jp DirFind_B3_cmpLfnFail


DirFind_B3_ordMatch::
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
    jp z, DirFind_B3_cmpLfnOk

DirFind_B3_cmpLfnFail::
    ld c, $00
    jp DirFind_B3_afterCmpLfn


DirFind_B3_cmpLfnOk::
    ld c, $01

DirFind_B3_afterCmpLfn::
    xor a
    or c
    jp z, DirFind_B3_ordUpdateFail

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
    jp nz, DirFind_B3_ordUpdateOk

DirFind_B3_ordUpdateFail::
    ld c, $00
    jp DirFind_B3_afterOrdUpdate


DirFind_B3_ordUpdateOk::
    ld c, $01

DirFind_B3_afterOrdUpdate::
    xor a
    or c
    jp z, DirFind_B3_ordInvalidate

    ld hl, sp+$15
    ld a, [hl]
    dec a
    ld c, a
    jp DirFind_B3_storeOrd


DirFind_B3_ordInvalidate::
    ld c, $ff

DirFind_B3_storeOrd::
    ld hl, sp+$15
    ld [hl], c
    jp DirFind_B3_dirNextLoop


DirFind_B3_sumSfnMatch::
    xor a
    ld hl, sp+$15
    or [hl]
    jp nz, DirFind_B3_checkNtres

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
    jp z, DirFind_B3_found

DirFind_B3_checkNtres::
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
    jr nz, DirFind_B3_ntresSkip

    jp DirFind_B3_memcmpSfn


DirFind_B3_ntresSkip::
    jp DirFind_B3_invalidate


DirFind_B3_memcmpSfn::
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
    jp z, DirFind_B3_found

DirFind_B3_invalidate::
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

DirFind_B3_dirNextLoop::
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
    jp z, DirFind_B3_readEntry

DirFind_B3_found::
    ld hl, sp+$19
    ld e, [hl]

DirFind_B3_epilogue::
    add sp, $1a
    ret


; [ezgb]
; DirRegister_B3(dp): FatFs dir_register. Frame -$26; copy SFN/LFN from dp; sp+$25=E.
; NSFLAG directory → DirRegister_B3_deniedIsDir E=$06 DirRegister_B3_epilogue; DirRegister_B3_checkCollision: AM_DIR → DirRegister_B3_genNumInit GenNumName loop DirRegister_B3_genNumLoop.
; DirRegister_B3_genNumLoop: idx<100 GenNumName_B3+DirFind_B3; taken → DirRegister_B3_genNumNext ++idx; miss → DirRegister_B3_afterGenNum.
; DirRegister_B3_afterGenNum: idx==100 → DirRegister_B3_deniedTooMany E=$07 else DirRegister_B3_genNumOk→DirRegister_B3_checkNoFile; E==$04 → DirRegister_B3_patchAttrSize patch attr/size.
; DirRegister_B3_checkLfn: LFN (attr&$02) → DirRegister_B3_countLfnSlots count slots DirRegister_B3_lfnLenLoop/DirRegister_B3_lfnLenCont; DirRegister_B3_u16DivSlots U16Div → DirRegister_B3_dirAlloc else DirRegister_B3_slotsOne n=1.
; DirRegister_B3_dirAlloc: DirAlloc_B3; err → DirRegister_B3_finalizeSfn; LFN slots DirRegister_B3_putLfnLoop (DirSdi, SumSfn, MoveWindow, PutLfn_B3, DirNext) loop.
; DirRegister_B3_finalizeSfn: err → DirRegister_B3_loadResult else finalize SFN (MoveWindow, MemSet8, MemCpy16, attr mask) + FA_DIRTY.
; DirRegister_B3_loadResult/DirRegister_B3_epilogue add sp,$26 ret E.

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
    jr nz, DirRegister_B3_deniedIsDir

    jp DirRegister_B3_checkCollision


DirRegister_B3_deniedIsDir::
    ld e, $06
    jp DirRegister_B3_epilogue


DirRegister_B3_checkCollision::
    ld a, c
    and $01
    jr nz, DirRegister_B3_genNumInit

    jp DirRegister_B3_checkLfn


DirRegister_B3_genNumInit::
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

DirRegister_B3_genNumLoop::
    ld hl, sp+$23
    ld a, [hl]
    sub $64
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, DirRegister_B3_afterGenNum

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
    jp nz, DirRegister_B3_afterGenNum

    dec hl
    dec hl
    inc [hl]
    jr nz, DirRegister_B3_genNumNext

    inc hl
    inc [hl]

DirRegister_B3_genNumNext::
    jp DirRegister_B3_genNumLoop


DirRegister_B3_afterGenNum::
    ld hl, sp+$23
    ld a, [hl]
    sub $64
    jp nz, DirRegister_B3_genNumOk

    inc hl
    ld a, [hl]
    or a
    jp nz, DirRegister_B3_genNumOk

    jr DirRegister_B3_deniedTooMany

DirRegister_B3_genNumOk::
    jp DirRegister_B3_checkNoFile


DirRegister_B3_deniedTooMany::
    ld e, $07
    jp DirRegister_B3_epilogue


DirRegister_B3_checkNoFile::
    ld hl, sp+$25
    ld a, [hl]
    sub $04
    jp z, DirRegister_B3_patchAttrSize

    ld hl, sp+$25
    ld e, [hl]
    jp DirRegister_B3_epilogue


DirRegister_B3_patchAttrSize::
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

DirRegister_B3_checkLfn::
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $02
    jr nz, DirRegister_B3_countLfnSlots

    jp DirRegister_B3_slotsOne


DirRegister_B3_countLfnSlots::
    ld hl, sp+$23
    ld [hl], $00
    inc hl
    ld [hl], $00

DirRegister_B3_lfnLenLoop::
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
    jp z, DirRegister_B3_u16DivSlots

    ld hl, sp+$23
    inc [hl]
    jr nz, DirRegister_B3_lfnLenCont

    inc hl
    inc [hl]

DirRegister_B3_lfnLenCont::
    jp DirRegister_B3_lfnLenLoop


DirRegister_B3_u16DivSlots::
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
    jp DirRegister_B3_dirAlloc


DirRegister_B3_slotsOne::
    ld hl, sp+$21
    ld [hl], $01
    inc hl
    ld [hl], $00

DirRegister_B3_dirAlloc::
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
    jp nz, DirRegister_B3_finalizeSfn

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
    jp z, DirRegister_B3_finalizeSfn

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
    jp nz, DirRegister_B3_finalizeSfn

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

DirRegister_B3_putLfnLoop::
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
    jp nz, DirRegister_B3_finalizeSfn

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
    jp nz, DirRegister_B3_finalizeSfn

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
    jp nz, DirRegister_B3_putLfnLoop

DirRegister_B3_finalizeSfn::
    xor a
    ld hl, sp+$25
    or [hl]
    jp nz, DirRegister_B3_loadResult

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
    jp nz, DirRegister_B3_loadResult

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

DirRegister_B3_loadResult::
    ld hl, sp+$25
    ld e, [hl]

DirRegister_B3_epilogue::
    add sp, $26
    ret


; [ezgb]
; CreateName_B3(dp, path): FatFs create_name twin of CreateName_B9 (09:6c3e). Frame -$1b; parse next path segment; build SFN/LFN+NSFLAG.
; CreateName_B3_skipLeadSep: skip leading '/' ($2f) or '\\' ($5c): CreateName_B3_skipLeadSepInc/CreateName_B3_skipLeadSepInc ++BC loop; else CreateName_B3_skipLeadSepElse → CreateName_B3_startSegment start segment.
; CreateName_B3_startSegment: stash path; lfnbuf@dp+$16; clear counters. CreateName_B3_lfnCharLoop: ++idx (CreateName_B3_afterLfnPtrInc); load char; <' ' or '/' or '\\' → CreateName_B3_endSegment end segment.
; CreateName_B3_checkBackslashSep/CreateName_B3_notTerminator: not terminator; CreateName_B3_mapCp437: if lfn idx≥$ff → E=$06 CreateName_B3_cleanup; else MapCp437; fail → CreateName_B3_cleanup.
; CreateName_B3_checkIllegalAscii: if <*$80 MemChr illegal set; hit → CreateName_B3_cleanup; CreateName_B3_storeWcharLfn/CreateName_B3_afterWcharIdxInc store wchar to lfnbuf → CreateName_B3_lfnCharLoop.
; CreateName_B3_endSegment: write advanced path ptr; last char <' ' → C=$04 (NSFLAG) else CreateName_B3_nsflagNotLast C=0; CreateName_B3_storeNsflag store NSFLAG@sp+$19.
; If lfnlen!=1 CreateName_B3_notLen1Dot → CreateName_B3_checkDotDot; else CreateName_B3_checkSingleDot: last wchar=='.' → CreateName_B3_dotEntry/CreateName_B3_dotEntry else CreateName_B3_checkDotDot.
; CreateName_B3_checkDotDot: len!=2 → CreateName_B3_notLen2DotDot → CreateName_B3_normalPath; else CreateName_B3_checkDotDotTail: '..' check (CreateName_B3_dotDotMismatch/CreateName_B3_checkDotDotHead/CreateName_B3_notDotDot) → CreateName_B3_dotEntry or CreateName_B3_normalPath.
; CreateName_B3_dotEntry/CreateName_B3_dotEntry: NUL-term LFN; CreateName_B3_sfnPadLoop fill SFN 11 slots (CreateName_B3_sfnPadSpace/CreateName_B3_sfnPadStore); done CreateName_B3_dotEntryDone.
; SFN pad loop: CreateName_B3_sfnPadLoop; insert '.' CreateName_B3_sfnPadSpace else space CreateName_B3_sfnPadStore; CreateName_B3_afterSfnPadIdxInc → CreateName_B3_sfnPadLoop; done CreateName_B3_dotEntryDone OR NSFLAG|$20 → CreateName_B3_cleanup (dot-only names).
; CreateName_B3_normalPath: normal path; CreateName_B3_stripTrailing strip trailing ' '/' .' (CreateName_B3_stripTrailNotSpace / CreateName_B3_stripTrailBreak / CreateName_B3_stripTrailDec / CreateName_B3_stripTrailDec); CreateName_B3_afterStripTrail empty → E=$06 CreateName_B3_cleanup else CreateName_B3_nulTermClearSfn NUL-term + MemSet8_B3 spaces into SFN.
; CreateName_B3_skipLeadSpaceDot: skip leading ' '/' .' (CreateName_B3_skipLeadNotSpace / CreateName_B3_skipLeadNonLead / CreateName_B3_skipLeadInc / CreateName_B3_skipLeadInc / CreateName_B3_afterSkipLeadIdxInc); non-lead CreateName_B3_afterSkipLead; if skipped NSFLAG|$03 then CreateName_B3_findLastDot.
; CreateName_B3_findLastDot: walk for last '.' (CreateName_B3_findLastDotCont → CreateName_B3_findLastDot); none/done CreateName_B3_initBodyLen init body len=8 then CreateName_B3_sfnFillLoop.
; CreateName_B3_sfnFillLoop SFN fill: next wchar (CreateName_B3_afterSfnFillIdxInc); NUL→CreateName_B3_sfnDoneDdem; space CreateName_B3_sfnFillSpaceLoss; '.' CreateName_B3_sfnFillCheckDot/CreateName_B3_sfnFillNotDot/CreateName_B3_sfnFillDotPath; else CreateName_B3_sfnFillSlotCheck; slot full CreateName_B3_sfnFillSlotFull/CreateName_B3_sfnFillSlotFull/CreateName_B3_sfnFillToExt/CreateName_B3_sfnFillSlotFullLoss; body	oext CreateName_B3_sfnFillBodyToExt/CreateName_B3_sfnFillBodyOverflow/CreateName_B3_sfnFillEnterExt; else CreateName_B3_sfnFillToMap → CreateName_B3_sfnMapCp437 MapCp437.
; CreateName_B3_sfnMapCp437: wchar>=$80 MapCp437 (fail CreateName_B3_sfnMapCp437Fail NSFLAG|$02); then CreateName_B3_sfnCheckIllegal MemChr_B3 illegal set → '_' CreateName_B3_sfnReplaceUnderscore NSFLAG|$03 else CreateName_B3_sfnCaseUpper.
; Case: A-Z CreateName_B3_sfnCaseLower skip else NSFLAG|$02 → CreateName_B3_sfnStoreByte; a-z CreateName_B3_sfnCaseLower NSFLAG|$01 + toupper; store via CreateName_B3_sfnStoreByteJr → CreateName_B3_sfnFillLoop.
; CreateName_B3_sfnDoneDdem: SFN[0]==$E5 → $05 (CreateName_B3_replaceDdem) else CreateName_B3_afterDdem/CreateName_B3_checkBodyOnly; body-only CreateName_B3_afterBodyOnly/CreateName_B3_ntShiftBodyOnly NT<<2; case mix CreateName_B3_caseMixCheck/CreateName_B3_caseMixOk/CreateName_B3_caseMixSetLfn/CreateName_B3_caseMixSetLfn → NSFLAG|$02; CreateName_B3_storeNtFlags/CreateName_B3_skipNtFlags/CreateName_B3_ntExtCheck/CreateName_B3_afterNtExt/CreateName_B3_setNsExt/CreateName_B3_ntBodyCheck/CreateName_B3_afterNtBody/CreateName_B3_setNsBody/CreateName_B3_storeNsflagFinal store NSFLAG; E=0 → CreateName_B3_cleanup.
; CreateName CF ends CreateName_B3_cleanup (add sp,$1b / ret). Post-ret: illegal-char table then unnamed-until-sym FollowPath_B3 @ 03:70b2 (FollowPath_B3_hasLeadSep…FollowPath_B3_epilogue) — not CreateName interior; twin of FollowPath_B5/B6/B9.

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

CreateName_B3_skipLeadSep::
    ld a, [bc]
    ld hl, sp+$08
    ld [hl], a
    sub $2f
    jp z, CreateName_B3_skipLeadSepInc

    ld hl, sp+$08
    ld a, [hl]
    sub $5c
    jp nz, CreateName_B3_skipLeadSepElse

    jr CreateName_B3_skipLeadSepInc

CreateName_B3_skipLeadSepElse::
    jp CreateName_B3_startSegment


CreateName_B3_skipLeadSepInc::
    inc bc
    ld hl, sp+$0b
    ld [hl], c
    inc hl
    ld [hl], b
    jp CreateName_B3_skipLeadSep


CreateName_B3_startSegment::
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

CreateName_B3_lfnCharLoop::
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, CreateName_B3_afterLfnPtrInc

    inc hl
    inc [hl]

CreateName_B3_afterLfnPtrInc::
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
    jp c, CreateName_B3_endSegment

    dec hl
    ld a, [hl]
    sub $2f
    jp nz, CreateName_B3_checkBackslashSep

    inc hl
    ld a, [hl]
    or a
    jp z, CreateName_B3_endSegment

CreateName_B3_checkBackslashSep::
    ld hl, sp+$17
    ld a, [hl]
    sub $5c
    jp nz, CreateName_B3_notTerminator

    inc hl
    ld a, [hl]
    or a
    jp z, CreateName_B3_endSegment

CreateName_B3_notTerminator::
    ld hl, sp+$02
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp c, CreateName_B3_mapCp437

    ld e, $06
    jp CreateName_B3_cleanup


CreateName_B3_mapCp437::
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
    jp nz, CreateName_B3_checkIllegalAscii

    ld e, $06
    jp CreateName_B3_cleanup


CreateName_B3_checkIllegalAscii::
    ld hl, sp+$17
    ld a, [hl]
    sub $80
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, CreateName_B3_storeWcharLfn

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
    jp z, CreateName_B3_storeWcharLfn

    ld e, $06
    jp CreateName_B3_cleanup


CreateName_B3_storeWcharLfn::
    ld hl, sp+$02
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, CreateName_B3_afterWcharIdxInc

    inc hl
    inc [hl]

CreateName_B3_afterWcharIdxInc::
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
    jp CreateName_B3_lfnCharLoop


CreateName_B3_endSegment::
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
    jp nc, CreateName_B3_nsflagNotLast

    ld c, $04
    jp CreateName_B3_storeNsflag


CreateName_B3_nsflagNotLast::
    ld c, $00

CreateName_B3_storeNsflag::
    ld hl, sp+$19
    ld [hl], c
    ld hl, sp+$0d
    ld a, [hl]
    sub $01
    jp nz, CreateName_B3_notLen1Dot

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateName_B3_notLen1Dot

    jr CreateName_B3_checkSingleDot

CreateName_B3_notLen1Dot::
    jp CreateName_B3_checkDotDot


CreateName_B3_checkSingleDot::
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
    jp nz, CreateName_B3_checkDotDot

    or b
    jp z, CreateName_B3_dotEntry

CreateName_B3_checkDotDot::
    ld hl, sp+$0d
    ld a, [hl]
    sub $02
    jp nz, CreateName_B3_notLen2DotDot

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateName_B3_notLen2DotDot

    jr CreateName_B3_checkDotDotTail

CreateName_B3_notLen2DotDot::
    jp CreateName_B3_normalPath


CreateName_B3_checkDotDotTail::
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
    jp nz, CreateName_B3_dotDotMismatch

    or b
    jp nz, CreateName_B3_dotDotMismatch

    jr CreateName_B3_checkDotDotHead

CreateName_B3_dotDotMismatch::
    jp CreateName_B3_normalPath


CreateName_B3_checkDotDotHead::
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
    jp nz, CreateName_B3_notDotDot

    or b
    jp nz, CreateName_B3_notDotDot

    jr CreateName_B3_dotEntry

CreateName_B3_notDotDot::
    jp CreateName_B3_normalPath


CreateName_B3_dotEntry::
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

CreateName_B3_sfnPadLoop::
    ld hl, sp+$13
    ld a, [hl]
    sub $0b
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, CreateName_B3_dotEntryDone

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
    jp nc, CreateName_B3_sfnPadSpace

    ld hl, sp+$02
    ld [hl], $2e
    jp CreateName_B3_sfnPadStore


CreateName_B3_sfnPadSpace::
    ld hl, sp+$02
    ld [hl], $20

CreateName_B3_sfnPadStore::
    ld hl, sp+$02
    ld a, [hl]
    ld [bc], a
    ld hl, sp+$13
    inc [hl]
    jr nz, CreateName_B3_afterSfnPadIdxInc

    inc hl
    inc [hl]

CreateName_B3_afterSfnPadIdxInc::
    jp CreateName_B3_sfnPadLoop


CreateName_B3_dotEntryDone::
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
    jp CreateName_B3_cleanup


CreateName_B3_normalPath::
    ld hl, sp+$0d
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e

CreateName_B3_stripTrailing::
    ld hl, sp+$00
    ld a, [hl+]
    or [hl]
    jp z, CreateName_B3_afterStripTrail

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
    jp nz, CreateName_B3_stripTrailNotSpace

    inc hl
    ld a, [hl]
    or a
    jp z, CreateName_B3_stripTrailDec

CreateName_B3_stripTrailNotSpace::
    ld hl, sp+$17
    ld a, [hl]
    sub $2e
    jp nz, CreateName_B3_stripTrailBreak

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateName_B3_stripTrailBreak

    jr CreateName_B3_stripTrailDec

CreateName_B3_stripTrailBreak::
    jp CreateName_B3_afterStripTrail


CreateName_B3_stripTrailDec::
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
    jp CreateName_B3_stripTrailing


CreateName_B3_afterStripTrail::
    ld hl, sp+$00
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0d
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$00
    ld a, [hl+]
    or [hl]
    jp nz, CreateName_B3_nulTermClearSfn

    ld e, $06
    jp CreateName_B3_cleanup


CreateName_B3_nulTermClearSfn::
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

CreateName_B3_skipLeadSpaceDot::
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
    jp nz, CreateName_B3_skipLeadNotSpace

    or b
    jp z, CreateName_B3_skipLeadInc

CreateName_B3_skipLeadNotSpace::
    ld a, c
    sub $2e
    jp nz, CreateName_B3_skipLeadNonLead

    or b
    jp nz, CreateName_B3_skipLeadNonLead

    jr CreateName_B3_skipLeadInc

CreateName_B3_skipLeadNonLead::
    jp CreateName_B3_afterSkipLead


CreateName_B3_skipLeadInc::
    ld hl, sp+$02
    inc [hl]
    jr nz, CreateName_B3_afterSkipLeadIdxInc

    inc hl
    inc [hl]

CreateName_B3_afterSkipLeadIdxInc::
    ld hl, sp+$02
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0f
    ld [hl+], a
    ld [hl], e
    jp CreateName_B3_skipLeadSpaceDot


CreateName_B3_afterSkipLead::
    ld hl, sp+$02
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0f
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$02
    ld a, [hl+]
    or [hl]
    jp z, CreateName_B3_findLastDot

    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a

CreateName_B3_findLastDot::
    ld hl, sp+$0d
    ld a, [hl+]
    or [hl]
    jp z, CreateName_B3_initBodyLen

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
    jp nz, CreateName_B3_findLastDotCont

    or b
    jp z, CreateName_B3_initBodyLen

CreateName_B3_findLastDotCont::
    ld hl, sp+$02
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$0d
    ld [hl], c
    inc hl
    ld [hl], b
    jp CreateName_B3_findLastDot


CreateName_B3_initBodyLen::
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

CreateName_B3_sfnFillLoop::
    ld hl, sp+$0f
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, CreateName_B3_afterSfnFillIdxInc

    inc hl
    inc [hl]

CreateName_B3_afterSfnFillIdxInc::
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
    jp z, CreateName_B3_sfnDoneDdem

    dec hl
    ld a, [hl]
    sub $20
    jp nz, CreateName_B3_sfnFillCheckDot

    inc hl
    ld a, [hl]
    or a
    jp z, CreateName_B3_sfnFillSpaceLoss

CreateName_B3_sfnFillCheckDot::
    ld hl, sp+$17
    ld a, [hl]
    sub $2e
    jp nz, CreateName_B3_sfnFillNotDot

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateName_B3_sfnFillNotDot

    jr CreateName_B3_sfnFillDotPath

CreateName_B3_sfnFillNotDot::
    jp CreateName_B3_sfnFillSlotCheck


CreateName_B3_sfnFillDotPath::
    ld hl, sp+$0f
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, CreateName_B3_sfnFillSpaceLoss

    ld hl, sp+$10
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp z, CreateName_B3_sfnFillSlotCheck

CreateName_B3_sfnFillSpaceLoss::
    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a
    jp CreateName_B3_sfnFillLoop


CreateName_B3_sfnFillSlotCheck::
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
    jp nc, CreateName_B3_sfnFillSlotFull

    ld hl, sp+$0f
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, CreateName_B3_sfnFillToMap

    ld hl, sp+$10
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, CreateName_B3_sfnFillToMap

    jr CreateName_B3_sfnFillSlotFull

CreateName_B3_sfnFillToMap::
    jp CreateName_B3_sfnMapCp437


CreateName_B3_sfnFillSlotFull::
    ld hl, sp+$11
    ld a, [hl]
    sub $0b
    jp nz, CreateName_B3_sfnFillToExt

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateName_B3_sfnFillToExt

    jr CreateName_B3_sfnFillSlotFullLoss

CreateName_B3_sfnFillToExt::
    jp CreateName_B3_sfnFillBodyToExt


CreateName_B3_sfnFillSlotFullLoss::
    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a
    jp CreateName_B3_sfnDoneDdem


CreateName_B3_sfnFillBodyToExt::
    ld hl, sp+$0f
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, CreateName_B3_sfnFillBodyOverflow

    ld hl, sp+$10
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp z, CreateName_B3_sfnFillEnterExt

CreateName_B3_sfnFillBodyOverflow::
    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a

CreateName_B3_sfnFillEnterExt::
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
    jp c, CreateName_B3_sfnDoneDdem

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
    jp CreateName_B3_sfnFillLoop


CreateName_B3_sfnMapCp437::
    ld hl, sp+$17
    ld a, [hl]
    sub $80
    inc hl
    ld a, [hl]
    sbc $00
    jp c, CreateName_B3_sfnCheckIllegal

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
    jp z, CreateName_B3_sfnMapCp437Fail

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

CreateName_B3_sfnMapCp437Fail::
    ld hl, sp+$19
    ld a, [hl]
    or $02
    ld [hl], a

CreateName_B3_sfnCheckIllegal::
    ld hl, sp+$17
    ld a, [hl+]
    or [hl]
    jp z, CreateName_B3_sfnReplaceUnderscore

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
    jp z, CreateName_B3_sfnCaseUpper

CreateName_B3_sfnReplaceUnderscore::
    ld hl, sp+$17
    ld [hl], $5f
    inc hl
    ld [hl], $00
    inc hl
    ld a, [hl]
    or $03
    ld [hl], a
    jp CreateName_B3_sfnStoreByte


CreateName_B3_sfnCaseUpper::
    ld hl, sp+$17
    ld a, [hl]
    sub $41
    inc hl
    ld a, [hl]
    sbc $00
    jp c, CreateName_B3_sfnCaseLower

    ld a, $5a
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp c, CreateName_B3_sfnCaseLower

    inc hl
    inc hl
    ld a, [hl]
    or $02
    ld [hl], a
    jp CreateName_B3_sfnStoreByte


CreateName_B3_sfnCaseLower::
    ld hl, sp+$17
    ld a, [hl]
    sub $61
    inc hl
    ld a, [hl]
    sbc $00
    jp c, CreateName_B3_sfnStoreByte

    ld a, $7a
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp c, CreateName_B3_sfnStoreByte

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

CreateName_B3_sfnStoreByte::
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
    jr nz, CreateName_B3_sfnStoreByteJr

    inc hl
    inc [hl]

CreateName_B3_sfnStoreByteJr::
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
    jp CreateName_B3_sfnFillLoop


CreateName_B3_sfnDoneDdem::
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
    jp nz, CreateName_B3_afterDdem

    jr CreateName_B3_replaceDdem

CreateName_B3_afterDdem::
    jp CreateName_B3_checkBodyOnly


CreateName_B3_replaceDdem::
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $05
    ld [de], a

CreateName_B3_checkBodyOnly::
    ld hl, sp+$11
    ld a, [hl]
    sub $08
    jp nz, CreateName_B3_afterBodyOnly

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateName_B3_afterBodyOnly

    jr CreateName_B3_ntShiftBodyOnly

CreateName_B3_afterBodyOnly::
    jp CreateName_B3_caseMixCheck


CreateName_B3_ntShiftBodyOnly::
    ld hl, sp+$1a
    sla [hl]
    sla [hl]

CreateName_B3_caseMixCheck::
    ld hl, sp+$1a
    ld a, [hl]
    and $0c
    ld c, a
    sub $0c
    jp z, CreateName_B3_caseMixSetLfn

    ld hl, sp+$1a
    ld a, [hl]
    and $03
    ld b, a
    sub $03
    jp nz, CreateName_B3_caseMixOk

    jr CreateName_B3_caseMixSetLfn

CreateName_B3_caseMixOk::
    jp CreateName_B3_storeNtFlags


CreateName_B3_caseMixSetLfn::
    ld hl, sp+$19
    ld a, [hl]
    or $02
    ld [hl], a

CreateName_B3_storeNtFlags::
    ld hl, sp+$19
    ld a, [hl]
    and $02
    jr nz, CreateName_B3_skipNtFlags

    jp CreateName_B3_ntExtCheck


CreateName_B3_skipNtFlags::
    jp CreateName_B3_storeNsflagFinal


CreateName_B3_ntExtCheck::
    ld hl, sp+$1a
    ld a, [hl]
    and $03
    ld b, a
    sub $01
    jp nz, CreateName_B3_afterNtExt

    jr CreateName_B3_setNsExt

CreateName_B3_afterNtExt::
    jp CreateName_B3_ntBodyCheck


CreateName_B3_setNsExt::
    ld hl, sp+$19
    ld a, [hl]
    or $10
    ld [hl], a

CreateName_B3_ntBodyCheck::
    ld a, c
    sub $04
    jp nz, CreateName_B3_afterNtBody

    jr CreateName_B3_setNsBody

CreateName_B3_afterNtBody::
    jp CreateName_B3_storeNsflagFinal


CreateName_B3_setNsBody::
    ld hl, sp+$19
    ld a, [hl]
    or $08
    ld [hl], a

CreateName_B3_storeNsflagFinal::
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

CreateName_B3_cleanup::
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
; Entry: skip leading '/' '\' (FollowPath_B3_hasLeadSep → FollowPath_B3_copyCdir else FollowPath_B3_clearSclust / FollowPath_B3_clearSclust clear sclust → FollowPath_B3_checkEmptyPath).
; FollowPath_B3_copyCdir: copy fs->cdir into dp->sclust; Join FollowPath_B3_checkEmptyPath.
; FollowPath_B3_checkEmptyPath: path[0]<' ' → DirSdi_B3(0) + clear fn → FollowPath_B3_epilogue else FollowPath_B3_segmentLoop segment loop (CreateName_B3 / DirFind_B3).
; FollowPath_B3_segmentLoop segment loop: CreateName_B3; err→FollowPath_B3_epilogue; DirFind_B3; FR_NOFILE+$04 last-seg (FollowPath_B3_noFileLastSeg) else FollowPath_B3_findFail→FollowPath_B3_epilogue; NSFLAG|$20 (FollowPath_B3_dotEntry) clear sclust/fn + more path→FollowPath_B3_segmentLoop else last (FollowPath_B3_lastSegOk E=0); non-last NSFLAG FollowPath_B3_nonLastNsflag/FollowPath_B3_nsLastOk/FollowPath_B3_deniedNotDir E=$05.
; Found (FollowPath_B3_found): last-seg FollowPath_B3_foundLastSeg→FollowPath_B3_epilogue; else FollowPath_B3_checkAttrDir ATTR_DIR? FollowPath_B3_isDir→FollowPath_B3_enterSubdir LdClust_B3 into sclust → FollowPath_B3_segmentLoop else FollowPath_B3_notDir E=$05; FollowPath_B3_epilogue epilogue ret E.

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
    jp z, FollowPath_B3_clearSclust

    ld hl, sp+$06
    ld a, [hl]
    sub $5c
    jp nz, FollowPath_B3_hasLeadSep

    jr FollowPath_B3_clearSclust

FollowPath_B3_hasLeadSep::
    jp FollowPath_B3_copyCdir


FollowPath_B3_clearSclust::
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
    jp FollowPath_B3_checkEmptyPath


FollowPath_B3_copyCdir::
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

FollowPath_B3_checkEmptyPath::
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
    jp nc, FollowPath_B3_segmentLoop

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
    jp FollowPath_B3_epilogue


FollowPath_B3_segmentLoop::
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
    jp nz, FollowPath_B3_epilogue

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
    jp z, FollowPath_B3_found

    ld a, [hl]
    sub $04
    jp nz, FollowPath_B3_findFail

    jr FollowPath_B3_noFileLastSeg

FollowPath_B3_findFail::
    jp FollowPath_B3_epilogue


FollowPath_B3_noFileLastSeg::
    ld hl, sp+$07
    ld a, [hl]
    and $20
    jr nz, FollowPath_B3_dotEntry

    jp FollowPath_B3_nonLastNsflag


FollowPath_B3_dotEntry::
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
    jr nz, FollowPath_B3_lastSegOk

    jp FollowPath_B3_segmentLoop


FollowPath_B3_lastSegOk::
    ld hl, sp+$0a
    ld [hl], $00
    jp FollowPath_B3_epilogue


FollowPath_B3_nonLastNsflag::
    ld hl, sp+$07
    ld a, [hl]
    and $04
    jr nz, FollowPath_B3_nsLastOk

    jp FollowPath_B3_deniedNotDir


FollowPath_B3_nsLastOk::
    jp FollowPath_B3_epilogue


FollowPath_B3_deniedNotDir::
    ld hl, sp+$0a
    ld [hl], $05
    jp FollowPath_B3_epilogue


FollowPath_B3_found::
    ld hl, sp+$07
    ld a, [hl]
    and $04
    jr nz, FollowPath_B3_foundLastSeg

    jp FollowPath_B3_checkAttrDir


FollowPath_B3_foundLastSeg::
    jp FollowPath_B3_epilogue


FollowPath_B3_checkAttrDir::
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
    jr nz, FollowPath_B3_isDir

    jp FollowPath_B3_notDir


FollowPath_B3_isDir::
    jp FollowPath_B3_enterSubdir


FollowPath_B3_notDir::
    ld hl, sp+$0a
    ld [hl], $05
    jp FollowPath_B3_epilogue


FollowPath_B3_enterSubdir::
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
    jp FollowPath_B3_segmentLoop


FollowPath_B3_epilogue::
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
    jp z, GetLdNumber_B3_returnResult

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b

GetLdNumber_B3_scanColon::
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
    jp c, GetLdNumber_B3_afterScan

    ld a, [hl]
    sub $3a
    jp z, GetLdNumber_B3_afterScan

    ld hl, sp+$00
    inc [hl]
    jr nz, GetLdNumber_B3_scanCont

    inc hl
    inc [hl]

GetLdNumber_B3_scanCont::
    jp GetLdNumber_B3_scanColon


GetLdNumber_B3_afterScan::
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $3a
    jp nz, GetLdNumber_B3_noColon

    jr GetLdNumber_B3_parseDigit

GetLdNumber_B3_noColon::
    jp GetLdNumber_B3_defaultVol0


GetLdNumber_B3_parseDigit::
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
    jr nz, GetLdNumber_B3_digitSignExt

    inc hl
    inc [hl]

GetLdNumber_B3_digitSignExt::
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
    jp nc, GetLdNumber_B3_returnVol

    ld hl, sp+$09
    ld a, [hl]
    ld hl, sp+$00
    sub [hl]
    jp nz, GetLdNumber_B3_notSingleDigit

    ld hl, sp+$0a
    ld a, [hl]
    ld hl, sp+$01
    sub [hl]
    jp nz, GetLdNumber_B3_notSingleDigit

    jr GetLdNumber_B3_checkVolRange

GetLdNumber_B3_notSingleDigit::
    jp GetLdNumber_B3_returnVol


GetLdNumber_B3_checkVolRange::
    ld a, c
    sub $01
    ld a, b
    sbc $00
    jp nc, GetLdNumber_B3_returnVol

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

GetLdNumber_B3_returnVol::
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    jp GetLdNumber_B3_epilogue


GetLdNumber_B3_defaultVol0::
    ld hl, sp+$07
    ld [hl], $00
    inc hl
    ld [hl], $00

GetLdNumber_B3_returnResult::
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]

GetLdNumber_B3_epilogue::
    add sp, $0b
    ret


; [ezgb]
; FindVolume stub (bank-3 near-call): FatFs find_volume front only; full mount in FindVolume_B5.
; Clear *rfs; GetLdNumber_B3: bit7→E=$0b FindVolume_B3_epilogue; else FindVolume_B3_lookupFs: FatFs[vol] @$C5A5 null→E=$0c else FindVolume_B3_bindRfs.
; FindVolume_B3_bindRfs: bind *rfs; fs_type==0→FindVolume_B3_ok; DiskStatus STA_NOINIT FindVolume_B3_needInit→FindVolume_B3_ok else FindVolume_B3_checkMode; mode0 FindVolume_B3_ok else WP FindVolume_B3_writeProtect E=$0a; FindVolume_B3_ok E=0 → FindVolume_B3_epilogue (add sp,$12 / ret).

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
    jp z, FindVolume_B3_lookupFs

    ld e, $0b
    jp FindVolume_B3_epilogue


FindVolume_B3_lookupFs::
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
    jp nz, FindVolume_B3_bindRfs

    ld e, $0c
    jp FindVolume_B3_epilogue


FindVolume_B3_bindRfs::
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
    jp z, FindVolume_B3_ok

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
    jr nz, FindVolume_B3_needInit

    jp FindVolume_B3_checkMode


FindVolume_B3_needInit::
    jp FindVolume_B3_ok


FindVolume_B3_checkMode::
    xor a
    ld hl, sp+$18
    or [hl]
    jp z, FindVolume_B3_ok

    ld a, c
    and $04
    jr nz, FindVolume_B3_writeProtect

    jp FindVolume_B3_ok


FindVolume_B3_writeProtect::
    ld e, $0a
    jp FindVolume_B3_epilogue


FindVolume_B3_ok::
    ld e, $00

FindVolume_B3_epilogue::
    add sp, $12
    ret


; [ezgb]
; Validate_B3(obj): FatFs validate. Push frame; reject null obj/fs, fs_type==0, or id mismatch → Validate_B3_invalid E=$09.
; obj->id vs fs->id mismatch → Validate_B3_idMismatch→Validate_B3_invalid; Validate_B3_diskStatus DiskStatus&$01 set → Validate_B3_invalid else Validate_B3_ok E=0.
; Validate_B3_epilogue add sp,$04 ret E.

Validate_B3::
    push af
    push af
    ld hl, sp+$06
    ld a, [hl+]
    or [hl]
    jp z, Validate_B3_invalid

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
    jp z, Validate_B3_invalid

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
    jp z, Validate_B3_invalid

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
    jp nz, Validate_B3_idMismatch

    inc hl
    ld a, [hl]
    sub b
    jp nz, Validate_B3_idMismatch

    jr Validate_B3_diskStatus

Validate_B3_idMismatch::
    jp Validate_B3_invalid


Validate_B3_diskStatus::
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
    jr nz, Validate_B3_invalid

    jp Validate_B3_ok


Validate_B3_invalid::
    ld e, $09
    jp Validate_B3_epilogue


Validate_B3_ok::
    ld e, $00

Validate_B3_epilogue::
    add sp, $04
    ret


; [ezgb]
; Fsync_B3(fp): FatFs f_sync. Frame -$10; Validate_B3 fail → Fsync_B3_loadResult.
; fp->flag FA_DIRTY ($20) → Fsync_B3_hasModified else Fsync_B3_loadResult E=0.
; Fsync_B3_hasModified: FA_DIRTY winsect ($40) → Fsync_B3_flushWin FarCallDiskWrite; ok Fsync_B3_clearDirty clear dirty bit else E=$01 Fsync_B3_epilogue.
; Fsync_B3_updateDir: MoveWindow_B3 update dir fsize/attr; StClust_B3 + RtcReadPage timestamp; clear FA_WRITTEN; SyncFs_B3 → Fsync_B3_loadResult.
; Fsync_B3_loadResult/Fsync_B3_epilogue add sp,$10 ret E.

Fsync_B3::
    add sp, -$0c
    ld hl, sp+$0e
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
    jp nz, Fsync_B3_loadResult

    ld hl, sp+$0e
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
    jr nz, Fsync_B3_hasModified

    jp Fsync_B3_loadResult


Fsync_B3_hasModified::
    ld a, c
    and $40
    jr nz, Fsync_B3_flushWin

    jp Fsync_B3_updateDir


Fsync_B3_flushWin::
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
    jp z, Fsync_B3_clearDirty

    ld e, $01
    jp Fsync_B3_epilogue


Fsync_B3_clearDirty::
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

Fsync_B3_updateDir::
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
    jp nz, Fsync_B3_loadResult

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
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    inc de
    ld a, $21
    ld [de], a
    inc de
    ld a, $46
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

Fsync_B3_loadResult::
    ld e, b

Fsync_B3_epilogue::
    add sp, $0c
    ret


; [ezgb]
; Close_B3(fp): FatFs f_close. Fsync_B3 then Validate_B3; clears FIL fs ptr.
; Target of FarCall_03_768f; orphan after Fsync path epilogue Fsync_B3_epilogue.

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
    jp nz, Close_B3_epilogue

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
    jp nz, Close_B3_epilogue

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

Close_B3_epilogue::
    ld hl, sp+$00
    ld e, [hl]
    add sp, $01
    ret


; [ezgb]
; Lseek_B3(fp, ofs): FatFs f_lseek. Validate_B3; U32Shl/Mod; CreateChain_B3 to
; extend; GetFat_B3 + Clust2Sect_B3. FarCall disk R/W helpers. -$29 frame.
; Target of FarCall_03_76cc; orphan after Close_B3_epilogue.
; Validate_B3 fail → Lseek_B3_epilogue; else Lseek_B3_afterValidate: fp->err nonzero → Lseek_B3_epilogue else Lseek_B3_checkOfsVsFsize.
; Lseek_B3_checkOfsVsFsize: if ofs > fsize and not FA_WRITE (Lseek_B3_ofsInRange/Lseek_B3_clampOfs clamp ofs=fsize); join Lseek_B3_clearFptr clear fptr.
; Lseek_B3_clearFptr: ofs==0 → Lseek_B3_fillWindow; else U32Shl csize; if fptr==0 Lseek_B3_fromSclust (from sclust) else U32Div by the cluster size: same-cluster Lseek_B3_sameCluster else Lseek_B3_fromSclust restart from sclust.
; Lseek_B3_fromSclust: start from sclust; empty → CreateChain_B3 (clust==1 Lseek_B3_afterCreateChain/Lseek_B3_createChainDiskErr E=$02; else Lseek_B3_checkChainClust: clust==-1 Lseek_B3_chainAborted E=$01; Lseek_B3_chainOk/Lseek_B3_writeSclust write sclust); join Lseek_B3_setClust set clust.
; Lseek_B3_sameCluster: clust==0 → Lseek_B3_fillWindow; else Lseek_B3_followLoop: while bc < ofs — FA_WRITE Lseek_B3_extendChain CreateChain_B3 else Lseek_B3_getFatNext GetFat_B3; fail Lseek_B3_getFatDiskErr E=$01 / Lseek_B3_getFatIntErr E=$02; ok Lseek_B3_afterGetFat/Lseek_B3_getFatOk/Lseek_B3_checkFatClust; past EOF Lseek_B3_pastEof → Lseek_B3_followLoop else Lseek_B3_setFptr.
; Lseek_B3_setFptr: set fptr; zero ofs→Lseek_B3_fillWindow else Lseek_B3_clust2Sect Clust2Sect_B3; sect ok Lseek_B3_sectOffset U32Shr sector offset else E=$02 → Lseek_B3_epilogue.
; Lseek_B3_fillWindow: same-sector Lseek_B3_sameSector else Lseek_B3_clampFptr; winsect mismatch Lseek_B3_winsectMismatch: dirty FA_DIRTY Lseek_B3_flushDirty FarCallDiskWrite else Lseek_B3_diskRead FarCallDiskRead; disk err E=$01 → Lseek_B3_epilogue; Lseek_B3_clearDirty clear FA_DIRTY; Lseek_B3_storeWinsect store winsect.
; Lseek_B3_clampFptr: clamp fptr to fsize (Lseek_B3_loadResult); set FA_DIRTY if past; E from stack → Lseek_B3_epilogue (add sp,$29 / ret).

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
    jp z, Lseek_B3_afterValidate

    ld e, [hl]
    jp Lseek_B3_epilogue


Lseek_B3_afterValidate::
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
    jp z, Lseek_B3_checkOfsVsFsize

    ld e, c
    jp Lseek_B3_epilogue


Lseek_B3_checkOfsVsFsize::
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
    jp nc, Lseek_B3_clearFptr

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
    jr nz, Lseek_B3_ofsInRange

    jp Lseek_B3_clampOfs


Lseek_B3_ofsInRange::
    jp Lseek_B3_clearFptr


Lseek_B3_clampOfs::
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

Lseek_B3_clearFptr::
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
    jp z, Lseek_B3_fillWindow

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
    jp z, Lseek_B3_fromSclust

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
    call U32Div
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
    jp c, Lseek_B3_fromSclust

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
    jp Lseek_B3_sameCluster


Lseek_B3_fromSclust::
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
    jp nz, Lseek_B3_setClust

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
    jp nz, Lseek_B3_afterCreateChain

    inc hl
    ld a, [hl]
    or a
    jp nz, Lseek_B3_afterCreateChain

    inc hl
    ld a, [hl]
    or a
    jp nz, Lseek_B3_afterCreateChain

    inc hl
    ld a, [hl]
    or a
    jp nz, Lseek_B3_afterCreateChain

    jr Lseek_B3_createChainDiskErr

Lseek_B3_afterCreateChain::
    jp Lseek_B3_checkChainClust


Lseek_B3_createChainDiskErr::
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $02
    ld [de], a
    ld e, $02
    jp Lseek_B3_epilogue


Lseek_B3_checkChainClust::
    ld hl, sp+$24
    ld a, [hl]
    inc a
    jp nz, Lseek_B3_chainOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, Lseek_B3_chainOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, Lseek_B3_chainOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, Lseek_B3_chainOk

    jr Lseek_B3_chainAborted

Lseek_B3_chainOk::
    jp Lseek_B3_writeSclust


Lseek_B3_chainAborted::
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    ld e, $01
    jp Lseek_B3_epilogue


Lseek_B3_writeSclust::
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

Lseek_B3_setClust::
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

Lseek_B3_sameCluster::
    ld hl, sp+$24
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, Lseek_B3_fillWindow

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

Lseek_B3_followLoop::
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
    jp nc, Lseek_B3_setFptr

    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $02
    jr nz, Lseek_B3_extendChain

    jp Lseek_B3_getFatNext


Lseek_B3_extendChain::
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
    jp nz, Lseek_B3_afterGetFat

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
    jp Lseek_B3_setFptr


Lseek_B3_getFatNext::
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

Lseek_B3_afterGetFat::
    ld hl, sp+$24
    ld a, [hl]
    inc a
    jp nz, Lseek_B3_getFatOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, Lseek_B3_getFatOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, Lseek_B3_getFatOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, Lseek_B3_getFatOk

    jr Lseek_B3_getFatDiskErr

Lseek_B3_getFatOk::
    jp Lseek_B3_checkFatClust


Lseek_B3_getFatDiskErr::
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    ld e, $01
    jp Lseek_B3_epilogue


Lseek_B3_checkFatClust::
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
    jp nc, Lseek_B3_getFatIntErr

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
    jp c, Lseek_B3_pastEof

Lseek_B3_getFatIntErr::
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $02
    ld [de], a
    ld e, $02
    jp Lseek_B3_epilogue


Lseek_B3_pastEof::
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
    jp Lseek_B3_followLoop


Lseek_B3_setFptr::
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
    jr nz, Lseek_B3_clust2Sect

    inc hl
    ld a, [hl]
    and $01
    jr nz, Lseek_B3_clust2Sect

    jp Lseek_B3_fillWindow


Lseek_B3_clust2Sect::
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
    jp nz, Lseek_B3_sectOffset

    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $02
    ld [de], a
    ld e, $02
    jp Lseek_B3_epilogue


Lseek_B3_sectOffset::
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

Lseek_B3_fillWindow::
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
    jr nz, Lseek_B3_sameSector

    inc hl
    ld a, [hl]
    and $01
    jr nz, Lseek_B3_sameSector

    jp Lseek_B3_clampFptr


Lseek_B3_sameSector::
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
    jp nz, Lseek_B3_winsectMismatch

    ld hl, sp+$1d
    ld a, [hl]
    ld hl, sp+$01
    sub [hl]
    jp nz, Lseek_B3_winsectMismatch

    ld hl, sp+$1e
    ld a, [hl]
    ld hl, sp+$02
    sub [hl]
    jp nz, Lseek_B3_winsectMismatch

    ld hl, sp+$1f
    ld a, [hl]
    ld hl, sp+$03
    sub [hl]
    jp z, Lseek_B3_clampFptr

Lseek_B3_winsectMismatch::
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
    jr nz, Lseek_B3_flushDirty

    jp Lseek_B3_diskRead


Lseek_B3_flushDirty::
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
    jp z, Lseek_B3_clearDirty

    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    ld e, $01
    jp Lseek_B3_epilogue


Lseek_B3_clearDirty::
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

Lseek_B3_diskRead::
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
    jp z, Lseek_B3_storeWinsect

    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    ld e, $01
    jp Lseek_B3_epilogue


Lseek_B3_storeWinsect::
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

Lseek_B3_clampFptr::
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
    jp nc, Lseek_B3_loadResult

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

Lseek_B3_loadResult::
    ld hl, sp+$28
    ld e, [hl]

Lseek_B3_epilogue::
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
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
