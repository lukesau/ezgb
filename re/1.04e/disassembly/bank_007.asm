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

MemCpy16_B7_wordLoop::
    ld hl, sp+$00
    ld a, [hl]
    sub $02
    jp c, MemCpy16_B7_byteTail

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
    jp MemCpy16_B7_wordLoop


MemCpy16_B7_byteTail::
    ld hl, sp+$00
    ld c, [hl]

MemCpy16_B7_byteLoop::
    ld b, c
    dec c
    xor a
    or b
    jp z, MemCpy16_B7_epilogue

    ld hl, sp+$01
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    dec hl
    inc [hl]
    jr nz, MemCpy16_B7_storeByte

    inc hl
    inc [hl]

MemCpy16_B7_storeByte::
    ld hl, sp+$03
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, MemCpy16_B7_byteNext

    inc hl
    inc [hl]

MemCpy16_B7_byteNext::
    jp MemCpy16_B7_byteLoop


MemCpy16_B7_epilogue::
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

MemSet8_B7_decN::
    ld b, c
    dec c
    xor a
    or b
    jp z, MemSet8_B7_epilogueRet

    ld hl, sp+$06
    ld a, [hl]
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, MemSet8_B7_storeCont

    inc hl
    inc [hl]

MemSet8_B7_storeCont::
    jp MemSet8_B7_decN


MemSet8_B7_epilogueRet::
    add sp, $02
    ret


MemCmp_B7::
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

MemCmp_B7_loop::
    ld hl, sp+$02
    ld b, [hl]
    dec [hl]
    xor a
    or b
    jp z, MemCmp_B7_epilogue

    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    dec hl
    inc [hl]
    jr nz, MemCmp_B7_storeA

    inc hl
    inc [hl]

MemCmp_B7_storeA::
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
    jr nz, MemCmp_B7_compare

    inc hl
    inc [hl]

MemCmp_B7_compare::
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
    jp z, MemCmp_B7_loop

MemCmp_B7_epilogue::
    ld hl, sp+$03
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $09
    ret


MemChr_B7::
    push af
    ld hl, sp+$04
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e

MemChr_B7_loop::
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    or a
    jp z, MemChr_B7_epilogue

    ld a, c
    rla
    sbc a
    ld b, a
    ld a, c
    ld hl, sp+$06
    sub [hl]
    jp nz, MemChr_B7_next

    ld a, b
    inc hl
    sub [hl]
    jp z, MemChr_B7_epilogue

MemChr_B7_next::
    ld hl, sp+$00
    inc [hl]
    jr nz, MemChr_B7_nextJr

    inc hl
    inc [hl]

MemChr_B7_nextJr::
    jp MemChr_B7_loop


MemChr_B7_epilogue::
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
    jp z, SyncWindow_B7_epilogue

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
    jp z, SyncWindow_B7_clearDirty

    ld hl, sp+$10
    ld [hl], $01
    jp SyncWindow_B7_epilogue


SyncWindow_B7_clearDirty::
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
    jp nc, SyncWindow_B7_epilogue

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

SyncWindow_B7_mirrorFat::
    ld hl, sp+$00
    ld a, [hl]
    sub $02
    inc hl
    ld a, [hl]
    sbc $00
    jp c, SyncWindow_B7_epilogue

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
    jp SyncWindow_B7_mirrorFat


SyncWindow_B7_epilogue::
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
    jp nz, MoveWindow_B7_reload

    ld hl, sp+$0e
    ld a, [hl]
    ld hl, sp+$01
    sub [hl]
    jp nz, MoveWindow_B7_reload

    ld hl, sp+$0f
    ld a, [hl]
    ld hl, sp+$02
    sub [hl]
    jp nz, MoveWindow_B7_reload

    ld hl, sp+$10
    ld a, [hl]
    ld hl, sp+$03
    sub [hl]
    jp z, MoveWindow_B7_epilogue

MoveWindow_B7_reload::
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
    jp nz, MoveWindow_B7_epilogue

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
    jp z, MoveWindow_B7_storeWinsect

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

MoveWindow_B7_storeWinsect::
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

MoveWindow_B7_epilogue::
    ld hl, sp+$08
    ld e, [hl]
    add sp, $09
    ret


; [ezgb]
; SyncFs_B7(fs): same as SyncFs_B9 (09:4447). Unlabeled mgbdis entry after MoveWindow_B7.

SyncFs_B7::
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
    jp nz, SyncFs_B7_epilogue

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
    jp nz, SyncFs_B7_checkFsiFlag

    jr SyncFs_B7_fsiFlagBody

SyncFs_B7_checkFsiFlag::
    jp SyncFs_B7_ioctlSync


SyncFs_B7_fsiFlagBody::
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
    jp nz, SyncFs_B7_buildFsInfo

    jr SyncFs_B7_fillWin

SyncFs_B7_buildFsInfo::
    jp SyncFs_B7_ioctlSync


SyncFs_B7_fillWin::
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
    jr nz, SyncFs_B7_diskWrite

    inc hl
    inc [hl]
    jr nz, SyncFs_B7_diskWrite

    inc hl
    inc [hl]
    jr nz, SyncFs_B7_diskWrite

    inc hl
    inc [hl]

SyncFs_B7_diskWrite::
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

SyncFs_B7_ioctlSync::
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
    jp z, SyncFs_B7_epilogue

    ld hl, sp+$10
    ld [hl], $01

SyncFs_B7_epilogue::
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
    jp c, Clust2Sect_B7_inRange

    ld de, $0000
    ld hl, $0000
    jp Clust2Sect_B7_epilogue


Clust2Sect_B7_inRange::
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

Clust2Sect_B7_epilogue::
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
    jp c, GetFat_B7_intErr

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
    jp c, GetFat_B7_switchType

GetFat_B7_intErr::
    ld hl, sp+$08
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    jp GetFat_B7_epilogue


GetFat_B7_switchType::
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
    jp c, GetFat_B7_badType

    ld a, $03
    sub c
    jp c, GetFat_B7_badType

    dec c
    ld e, c
    ld d, $00
    ld hl, $478a
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp GetFat_B7_fat12


    jp GetFat_B7_fat16


    jp GetFat_B7_fat32


GetFat_B7_fat12::
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
    jp nz, GetFat_B7_epilogue

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
    jr nz, GetFat_B7_fat12WinOff

    inc hl
    inc [hl]

GetFat_B7_fat12WinOff::
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
    jp nz, GetFat_B7_epilogue

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
    jr nz, GetFat_B7_fat12Odd

    jp GetFat_B7_fat12Even


GetFat_B7_fat12Odd::
    ld hl, sp+$12
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, $04

GetFat_B7_fat12Shr4::
    srl b
    rr c
    dec a
    jr nz, GetFat_B7_fat12Shr4

    jp GetFat_B7_storeVal


GetFat_B7_fat12Even::
    ld hl, sp+$12
    ld c, [hl]
    inc hl
    ld a, [hl]
    and $0f
    ld b, a

GetFat_B7_storeVal::
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp GetFat_B7_epilogue


GetFat_B7_fat16::
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
    jp nz, GetFat_B7_epilogue

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
    jp GetFat_B7_epilogue


GetFat_B7_fat32::
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
    jp nz, GetFat_B7_epilogue

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
    jp GetFat_B7_epilogue


GetFat_B7_badType::
    ld hl, sp+$08
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

GetFat_B7_epilogue::
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


PutFat_B7::
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
    jp c, PutFat_B7_intErr

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
    jp c, PutFat_B7_switchType

PutFat_B7_intErr::
    ld hl, sp+$14
    ld [hl], $02
    jp PutFat_B7_epilogue


PutFat_B7_switchType::
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    sub $01
    jp c, PutFat_B7_badType

    ld a, $03
    sub b
    jp c, PutFat_B7_badType

    dec b
    ld e, b
    ld d, $00
    ld hl, $4b5d
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp PutFat_B7_fat12


    jp PutFat_B7_fat16


    jp PutFat_B7_fat32


PutFat_B7_fat12::
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
    jp nz, PutFat_B7_epilogue

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
    jr nz, PutFat_B7_fat12WinOff

    inc hl
    inc [hl]

PutFat_B7_fat12WinOff::
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
    jp z, PutFat_B7_fat12EvenFirst

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
    jp PutFat_B7_fat12StoreFirst


PutFat_B7_fat12EvenFirst::
    ld hl, sp+$21
    ld b, [hl]

PutFat_B7_fat12StoreFirst::
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
    jp nz, PutFat_B7_epilogue

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
    jp z, PutFat_B7_fat12Second

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
    jp PutFat_B7_fat12StoreSecond


PutFat_B7_fat12Second::
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

PutFat_B7_fat12StoreSecond::
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
    jp PutFat_B7_epilogue


PutFat_B7_fat16::
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
    jp nz, PutFat_B7_epilogue

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
    jp PutFat_B7_epilogue


PutFat_B7_fat32::
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
    jp nz, PutFat_B7_epilogue

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
    jp PutFat_B7_epilogue


PutFat_B7_badType::
    ld hl, sp+$14
    ld [hl], $02

PutFat_B7_epilogue::
    ld hl, sp+$14
    ld e, [hl]
    add sp, $19
    ret


; [ezgb]
; CreateChain_B7(fs, clst, target): FatFs create_chain / cluster extend.
; clst!=0 Jump_007_4ffe GetFat_B7: clst<2 → Jump_007_5327 (1,0); Jump_007_503d: clst==-1 jr_007_505b else Jump_007_5058/Jump_007_5067 compare n_fatent (past Jump_007_50a4 else Jump_007_5327).
; clst==0: free_clst vs n_fatent; empty Jump_007_4ff2 clst=1; join Jump_007_50b5 copy state.
; Jump_007_50b5 alloc scan Jump_007_50ef (jr_007_50fe): hit end Jump_007_513d GetFat_B7; no free + scan done → Jump_007_5327 (0,0).
; Jump_007_5196/Jump_007_51b2/Jump_007_51b5/jr_007_51b5 EOF checks; Jump_007_51c1 match jr_007_51ea (0,0) else Jump_007_51e7 → Jump_007_50ef.
; Jump_007_513d free slot Jump_007_51f3 PutFat_B7 link; fail Jump_007_52e9/Jump_007_52f1/jr_007_52f4/Jump_007_5304 set FR_NO_FILESYSTEM.
; Jump_007_5248: update fs free_clst/fatbase; Jump_007_529d link + FA_DIRTY or Jump_007_531e; Jump_007_530d store; Jump_007_5327 epilogue (add sp,$1b / ret).

CreateChain_B7::
    add sp, -$1b
    ld hl, sp+$1f
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, CreateChain_B7_getFatExisting

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
    jp z, CreateChain_B7_clstEmptySet1

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
    jp c, CreateChain_B7_copyScanState

CreateChain_B7_clstEmptySet1::
    ld hl, sp+$0f
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    jp CreateChain_B7_copyScanState


CreateChain_B7_getFatExisting::
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
    jp nc, CreateChain_B7_afterGetFat

    ld de, $0001
    ld hl, $0000
    jp CreateChain_B7_epilogue


CreateChain_B7_afterGetFat::
    ld hl, sp+$17
    ld a, [hl]
    inc a
    jp nz, CreateChain_B7_notEofCluster

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B7_notEofCluster

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B7_notEofCluster

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B7_notEofCluster

    jr CreateChain_B7_eofCluster

CreateChain_B7_notEofCluster::
    jp CreateChain_B7_cmpNFatent


CreateChain_B7_eofCluster::
    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp CreateChain_B7_epilogue


CreateChain_B7_cmpNFatent::
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
    jp nc, CreateChain_B7_stretchOk

    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp CreateChain_B7_epilogue


CreateChain_B7_stretchOk::
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

CreateChain_B7_copyScanState::
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

CreateChain_B7_allocScan::
    ld hl, sp+$13
    inc [hl]
    jr nz, CreateChain_B7_allocScanCont

    inc hl
    inc [hl]
    jr nz, CreateChain_B7_allocScanCont

    inc hl
    inc [hl]
    jr nz, CreateChain_B7_allocScanCont

    inc hl
    inc [hl]

CreateChain_B7_allocScanCont::
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
    jp c, CreateChain_B7_scanHitEnd

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
    jp z, CreateChain_B7_scanHitEnd

    ld de, $0000
    ld hl, $0000
    jp CreateChain_B7_epilogue


CreateChain_B7_scanHitEnd::
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
    jp z, CreateChain_B7_putFatLink

    ld hl, sp+$17
    ld a, [hl]
    inc a
    jp nz, CreateChain_B7_eofCheck

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B7_eofCheck

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B7_eofCheck

    inc hl
    ld a, [hl]
    inc a
    jp z, CreateChain_B7_eofCheckVal

CreateChain_B7_eofCheck::
    ld hl, sp+$17
    ld a, [hl]
    sub $01
    jp nz, CreateChain_B7_eofCheckCont

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateChain_B7_eofCheckCont

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateChain_B7_eofCheckCont

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateChain_B7_eofCheckCont

    jr CreateChain_B7_eofCheckVal

CreateChain_B7_eofCheckCont::
    jp CreateChain_B7_matchScanStart


CreateChain_B7_eofCheckVal::
    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp CreateChain_B7_epilogue


CreateChain_B7_matchScanStart::
    ld hl, sp+$13
    ld a, [hl]
    ld hl, sp+$0f
    sub [hl]
    jp nz, CreateChain_B7_scanContinue

    ld hl, sp+$14
    ld a, [hl]
    ld hl, sp+$10
    sub [hl]
    jp nz, CreateChain_B7_scanContinue

    ld hl, sp+$15
    ld a, [hl]
    ld hl, sp+$11
    sub [hl]
    jp nz, CreateChain_B7_scanContinue

    ld hl, sp+$16
    ld a, [hl]
    ld hl, sp+$12
    sub [hl]
    jp nz, CreateChain_B7_scanContinue

    jr CreateChain_B7_noFreeRet0

CreateChain_B7_scanContinue::
    jp CreateChain_B7_allocScan


CreateChain_B7_noFreeRet0::
    ld de, $0000
    ld hl, $0000
    jp CreateChain_B7_epilogue


CreateChain_B7_putFatLink::
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
    call PutFat_B7
    add sp, $0a
    ld c, e
    xor a
    or c
    jp nz, CreateChain_B7_updateFreeClst

    ld hl, sp+$1f
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, CreateChain_B7_updateFreeClst

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
    call PutFat_B7
    add sp, $0a
    ld b, e
    ld c, b

CreateChain_B7_updateFreeClst::
    xor a
    or c
    jp nz, CreateChain_B7_putFatFail

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
    jp nz, CreateChain_B7_linkAndDirty

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B7_linkAndDirty

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B7_linkAndDirty

    inc hl
    ld a, [hl]
    inc a
    jp z, CreateChain_B7_newChainOnly

CreateChain_B7_linkAndDirty::
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
    jp CreateChain_B7_newChainOnly


CreateChain_B7_putFatFail::
    ld a, c
    sub $01
    jp nz, CreateChain_B7_putFatFailCont

    jr CreateChain_B7_diskErrorRet

CreateChain_B7_putFatFailCont::
    jp CreateChain_B7_setFrNoFilesystem


CreateChain_B7_diskErrorRet::
    ld hl, sp+$00
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    jp CreateChain_B7_storeResult


CreateChain_B7_setFrNoFilesystem::
    ld hl, sp+$00
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

CreateChain_B7_storeResult::
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

CreateChain_B7_newChainOnly::
    ld hl, sp+$13
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a

CreateChain_B7_epilogue::
    add sp, $1b
    ret


DirSdi_B7::
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
    jp nz, DirSdi_B7_rangeCheck

    inc hl
    ld a, [hl]
    or a
    jp nz, DirSdi_B7_rangeCheck

    inc hl
    ld a, [hl]
    or a
    jp nz, DirSdi_B7_rangeCheck

    inc hl
    ld a, [hl]
    or a
    jp z, DirSdi_B7_intErr

DirSdi_B7_rangeCheck::
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
    jp c, DirSdi_B7_afterRange

DirSdi_B7_intErr::
    ld e, $02
    jp DirSdi_B7_epilogue


DirSdi_B7_afterRange::
    ld hl, sp+$12
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, DirSdi_B7_staticOrDyn

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
    jp nz, DirSdi_B7_notFat32Root

    jr DirSdi_B7_fat32RootBase

DirSdi_B7_notFat32Root::
    jp DirSdi_B7_staticOrDyn


DirSdi_B7_fat32RootBase::
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

DirSdi_B7_staticOrDyn::
    ld hl, sp+$12
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, DirSdi_B7_dynCsize

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
    jp c, DirSdi_B7_staticSect

    ld e, $02
    jp DirSdi_B7_epilogue


DirSdi_B7_staticSect::
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
    jp DirSdi_B7_storeClust


DirSdi_B7_dynCsize::
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
    jr DirSdi_B7_csizeShiftLoop

DirSdi_B7_csizeShift::
    ld hl, sp+$0c
    sla [hl]
    inc hl
    rl [hl]

DirSdi_B7_csizeShiftLoop::
    dec a
    jr nz, DirSdi_B7_csizeShift

DirSdi_B7_followLoop::
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
    jp c, DirSdi_B7_clust2Sect

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
    jp nz, DirSdi_B7_afterGetFat

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirSdi_B7_afterGetFat

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirSdi_B7_afterGetFat

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirSdi_B7_afterGetFat

    jr DirSdi_B7_diskErr

DirSdi_B7_afterGetFat::
    jp DirSdi_B7_checkClust


DirSdi_B7_diskErr::
    ld e, $01
    jp DirSdi_B7_epilogue


DirSdi_B7_checkClust::
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
    jp c, DirSdi_B7_clustIntErr

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
    jp c, DirSdi_B7_subCsz

DirSdi_B7_clustIntErr::
    ld e, $02
    jp DirSdi_B7_epilogue


DirSdi_B7_subCsz::
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
    jp DirSdi_B7_followLoop


DirSdi_B7_clust2Sect::
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

DirSdi_B7_storeClust::
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
    jp nz, DirSdi_B7_setSectDir

    ld e, $02
    jp DirSdi_B7_epilogue


DirSdi_B7_setSectDir::
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

DirSdi_B7_sectDiv::
    srl b
    rr c
    dec a
    jr nz, DirSdi_B7_sectDiv

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

DirSdi_B7_epilogue::
    add sp, $16
    ret


; [ezgb]
; DirNext_B7(dp, stretch): FatFs dir_next. Frame -$22; ++dp->dptr index; walk dir sectors/clusters.
; Index+1==0 → Jump_007_56b1 E=$04 (FR_NO_FILE); load dir entry@dp+$0e — four dwords zero → Jump_007_56b1.
; Jump_007_56b6: index&$0f≠0 → Jump_007_5a7f in-sector advance; else inc sector (jr_007_56d4 carry chain) + copy 32-byte slot.
; Next cluster from dp chain zero → Jump_007_5735 stretch path; volsize compare fail → Jump_007_5a7f else E=$04 → Jump_007_5adc.
; Jump_007_5735: sector→cluster via jr_007_5743 ÷16; fs-type mask vs cluster → nz Jump_007_5a7f; GetFat_B7.
; Cluster−1 underflow → Jump_007_57ab: inc cluster words — all zero jr_007_57c9 E=$01 else Jump_007_57c6→Jump_007_57ce.
; Jump_007_57ce: cluster<saved → Jump_007_5a2e; stretch==0 → E=$04 Jump_007_5adc else Jump_007_5815 CreateChain_B7.
; CreateChain result zero → E=$07 Jump_007_5adc; else Jump_007_5868 cluster−1 all zero → jr_007_5887 E=$02 else Jump_007_5884→Jump_007_588c.
; Jump_007_588c: inc cluster words — all wrap jr_007_58aa E=$01 else Jump_007_58a7→Jump_007_58af SyncWindow_B7.
; Jump_007_58af: SyncWindow_B7 err→E=$01 Jump_007_5adc else Jump_007_58ca MemSet8 dir buf + Clust2Sect → Jump_007_593c sector loop.
; Jump_007_593c: offset≥ssize → Jump_007_59d1 else dirty+SyncWindow; err E=$01; Jump_007_597f stamp template (jr_007_59ad/jr_007_59c6) → Jump_007_593c.
; Jump_007_59d1: partial tail copy + sector base for index; Jump_007_5a2e store cluster + Clust2Sect → window sector.
; Jump_007_5a7f: write index@dp+$04, ptr@dp+$12+idx*32, E=0; Jump_007_5adc add sp,$22 ret E.

DirNext_B7::
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
    jp z, DirNext_B7_noFile

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
    jp nz, DirNext_B7_checkInSector

DirNext_B7_noFile::
    ld e, $04
    jp DirNext_B7_epilogue


DirNext_B7_checkInSector::
    ld hl, sp+$1c
    ld a, [hl]
    and $0f
    ld hl, sp+$10
    ld [hl+], a
    ld [hl], $00
    dec hl
    ld a, [hl+]
    or [hl]
    jp nz, DirNext_B7_advanceOk

    inc hl
    inc [hl]
    jr nz, DirNext_B7_incSector

    inc hl
    inc [hl]
    jr nz, DirNext_B7_incSector

    inc hl
    inc [hl]
    jr nz, DirNext_B7_incSector

    inc hl
    inc [hl]

DirNext_B7_incSector::
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
    jp nz, DirNext_B7_stretchPath

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
    jp c, DirNext_B7_advanceOk

    ld e, $04
    jp DirNext_B7_epilogue


DirNext_B7_stretchPath::
    ld hl, sp+$1c
    ld a, [hl]
    ld hl, sp+$08
    ld [hl], a
    ld hl, sp+$1d
    ld a, [hl]
    ld hl, sp+$09
    ld [hl], a
    ld a, $04

DirNext_B7_sectToClust::
    ld hl, sp+$09
    srl [hl]
    dec hl
    rr [hl]
    dec a
    jr nz, DirNext_B7_sectToClust

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
    jp nz, DirNext_B7_advanceOk

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
    jp c, DirNext_B7_clustUnderflow

    ld e, $02
    jp DirNext_B7_epilogue


DirNext_B7_clustUnderflow::
    ld hl, sp+$1e
    ld a, [hl]
    inc a
    jp nz, DirNext_B7_clustIncOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirNext_B7_clustIncOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirNext_B7_clustIncOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirNext_B7_clustIncOk

    jr DirNext_B7_intErr

DirNext_B7_clustIncOk::
    jp DirNext_B7_afterClustInc


DirNext_B7_intErr::
    ld e, $01
    jp DirNext_B7_epilogue


DirNext_B7_afterClustInc::
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
    jp c, DirNext_B7_storeClust

    ld hl, sp+$26
    ld a, [hl+]
    or [hl]
    jp nz, DirNext_B7_createChain

    ld e, $04
    jp DirNext_B7_epilogue


DirNext_B7_createChain::
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
    call CreateChain_B7
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
    jp nz, DirNext_B7_afterCreateChain

    ld e, $07
    jp DirNext_B7_epilogue


DirNext_B7_afterCreateChain::
    ld hl, sp+$1e
    ld a, [hl]
    sub $01
    jp nz, DirNext_B7_newClustOk

    inc hl
    ld a, [hl]
    or a
    jp nz, DirNext_B7_newClustOk

    inc hl
    ld a, [hl]
    or a
    jp nz, DirNext_B7_newClustOk

    inc hl
    ld a, [hl]
    or a
    jp nz, DirNext_B7_newClustOk

    jr DirNext_B7_diskErr

DirNext_B7_newClustOk::
    jp DirNext_B7_incNewClust


DirNext_B7_diskErr::
    ld e, $02
    jp DirNext_B7_epilogue


DirNext_B7_incNewClust::
    ld hl, sp+$1e
    ld a, [hl]
    inc a
    jp nz, DirNext_B7_newClustWrapOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirNext_B7_newClustWrapOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirNext_B7_newClustWrapOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirNext_B7_newClustWrapOk

    jr DirNext_B7_syncIntErr

DirNext_B7_newClustWrapOk::
    jp DirNext_B7_syncWindow


DirNext_B7_syncIntErr::
    ld e, $01
    jp DirNext_B7_epilogue


DirNext_B7_syncWindow::
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
    jp z, DirNext_B7_clearDirBuf

    ld e, $01
    jp DirNext_B7_epilogue


DirNext_B7_clearDirBuf::
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

DirNext_B7_sectorLoop::
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
    jp nc, DirNext_B7_partialTail

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
    jp z, DirNext_B7_stampTemplate

    ld e, $01
    jp DirNext_B7_epilogue


DirNext_B7_stampTemplate::
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
    jr nz, DirNext_B7_stampCont

    inc hl
    inc [hl]
    jr nz, DirNext_B7_stampCont

    inc hl
    inc [hl]
    jr nz, DirNext_B7_stampCont

    inc hl
    inc [hl]

DirNext_B7_stampCont::
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
    jr nz, DirNext_B7_stampNext

    inc hl
    inc [hl]

DirNext_B7_stampNext::
    ld hl, sp+$1a
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], e
    jp DirNext_B7_sectorLoop


DirNext_B7_partialTail::
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

DirNext_B7_storeClust::
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

DirNext_B7_advanceOk::
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

DirNext_B7_epilogue::
    add sp, $22
    ret


; [ezgb]
; DirAlloc_B7(dp): FatFs dir_alloc. Frame -$0b; scan for free dir slot via DirSdi_B7(0) + DirNext_B7(1).
; DirSdi err → Jump_007_5bab; Jump_007_5b16: load cluster@dp+$0e, MoveWindow_B7 err → Jump_007_5bab.
; SFN[0] DDEM $E5 or empty → Jump_007_5b6b else Jump_007_5b8c reset run counter → Jump_007_5b93 DirNext_B7(1).
; Jump_007_5b6b: ++free-run (jr_007_5b72); run==n_dir → jr_007_5b89→Jump_007_5bab else Jump_007_5b86→Jump_007_5b93.
; DirNext ok → Jump_007_5b16; Jump_007_5bab: E==$04 → jr_007_5bb8 E=$07 else Jump_007_5bb5→Jump_007_5bbc ret E.

DirAlloc_B7::
    add sp, -$0b
    ld hl, $0000
    push hl
    ld hl, sp+$0f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirSdi_B7
    add sp, $04
    ld c, e
    ld hl, sp+$0a
    ld [hl], c
    xor a
    or [hl]
    jp nz, DirAlloc_B7_done

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

DirAlloc_B7_scanLoop::
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
    jp nz, DirAlloc_B7_done

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
    jp z, DirAlloc_B7_incFreeRun

    xor a
    or c
    jp nz, DirAlloc_B7_resetRun

DirAlloc_B7_incFreeRun::
    ld hl, sp+$08
    inc [hl]
    jr nz, DirAlloc_B7_checkRunLen

    inc hl
    inc [hl]

DirAlloc_B7_checkRunLen::
    ld hl, sp+$08
    ld a, [hl]
    ld hl, sp+$0f
    sub [hl]
    jp nz, DirAlloc_B7_needMore

    ld hl, sp+$09
    ld a, [hl]
    ld hl, sp+$10
    sub [hl]
    jp nz, DirAlloc_B7_needMore

    jr DirAlloc_B7_runComplete

DirAlloc_B7_needMore::
    jp DirAlloc_B7_dirNext


DirAlloc_B7_runComplete::
    jp DirAlloc_B7_done


DirAlloc_B7_resetRun::
    ld hl, sp+$08
    ld [hl], $00
    inc hl
    ld [hl], $00

DirAlloc_B7_dirNext::
    ld hl, $0001
    push hl
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirNext_B7
    add sp, $04
    ld c, e
    ld hl, sp+$0a
    ld [hl], c
    xor a
    or [hl]
    jp z, DirAlloc_B7_scanLoop

DirAlloc_B7_done::
    ld hl, sp+$0a
    ld a, [hl]
    sub $04
    jp nz, DirAlloc_B7_keepErr

    jr DirAlloc_B7_denied

DirAlloc_B7_keepErr::
    jp DirAlloc_B7_epilogue


DirAlloc_B7_denied::
    ld hl, sp+$0a
    ld [hl], $07

DirAlloc_B7_epilogue::
    ld hl, sp+$0a
    ld e, [hl]
    add sp, $0b
    ret


LdClust_B7::
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
    jp nz, LdClust_B7_notFat32

    jr LdClust_B7_orHiWord

LdClust_B7_notFat32::
    jp LdClust_B7_epilogue


LdClust_B7_orHiWord::
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

LdClust_B7_epilogue::
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


; [ezgb]
; StClust_B7: same as StClust_B9 (09:5e0a). Bank-local FatFs st_clust copy.
; Orphan between LdClust_B7 and CmpLfn_B7.

StClust_B7::
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


CmpLfn_B7::
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
    jp z, CmpLfn_B7_initOffset

    ld de, $0000
    jp CmpLfn_B7_epilogue


CmpLfn_B7_initOffset::
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

CmpLfn_B7_charLoop::
    ld hl, sp+$0a
    ld a, [hl]
    sub $0d
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, CmpLfn_B7_checkLastSeg

    ld de, LfnOfs_B7
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
    jp z, CmpLfn_B7_checkFiller

    ld hl, sp+$02
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, CmpLfn_B7_mismatch

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
    jr nz, CmpLfn_B7_compareUpper

    inc hl
    inc [hl]

CmpLfn_B7_compareUpper::
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
    jp nz, CmpLfn_B7_mismatch

    inc hl
    ld a, [hl]
    sub b
    jp z, CmpLfn_B7_storeWc

CmpLfn_B7_mismatch::
    ld de, $0000
    jp CmpLfn_B7_epilogue


CmpLfn_B7_storeWc::
    ld hl, sp+$06
    ld a, [hl+]
    ld e, [hl]
    inc hl
    ld [hl+], a
    ld [hl], e
    jp CmpLfn_B7_nextChar


CmpLfn_B7_checkFiller::
    ld hl, sp+$06
    ld a, [hl]
    inc a
    jp nz, CmpLfn_B7_fillerBad

    inc hl
    ld a, [hl]
    inc a
    jp z, CmpLfn_B7_nextChar

CmpLfn_B7_fillerBad::
    ld de, $0000
    jp CmpLfn_B7_epilogue


CmpLfn_B7_nextChar::
    ld hl, sp+$0a
    inc [hl]
    jr nz, CmpLfn_B7_nextCharJr

    inc hl
    inc [hl]

CmpLfn_B7_nextCharJr::
    jp CmpLfn_B7_charLoop


CmpLfn_B7_checkLastSeg::
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $40
    jr nz, CmpLfn_B7_lastSegLen

    jp CmpLfn_B7_matched


CmpLfn_B7_lastSegLen::
    ld hl, sp+$08
    ld a, [hl+]
    or [hl]
    jp z, CmpLfn_B7_matched

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
    jp z, CmpLfn_B7_matched

    ld de, $0000
    jp CmpLfn_B7_epilogue


CmpLfn_B7_matched::
    ld de, $0001

CmpLfn_B7_epilogue::
    add sp, $0e
    ret


LfnOfs_B7::
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
    db $33
    db $5e
    db $11
    db $00
    db $00
    db $c3
    db $3d
    db $5f

MatchLfnEntry_B7::
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

MatchLfnEntry_charLoop_B7::
    ld hl, sp+$09
    ld a, [hl]
    sub $0d
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, MatchLfnEntry_checkLastFlag_B7

    ld de, LfnOfs_B7
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
    jp z, MatchLfnEntry_checkSentinel_B7

    ld hl, sp+$00
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp c, MatchLfnEntry_advance_B7

    ld de, $0000
    jp MatchLfnEntry_epilogue_B7


MatchLfnEntry_advance_B7::
    ld hl, sp+$00
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, MatchLfnEntry_storeOfs_B7

    inc hl
    inc [hl]

MatchLfnEntry_storeOfs_B7::
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
    jp MatchLfnEntry_nextOrd_B7


MatchLfnEntry_checkSentinel_B7::
    ld hl, sp+$05
    ld a, [hl]
    inc a
    jp nz, MatchLfnEntry_noMatch_B7

    inc hl
    ld a, [hl]
    inc a
    jp z, MatchLfnEntry_nextOrd_B7

MatchLfnEntry_noMatch_B7::
    ld de, $0000
    jp MatchLfnEntry_epilogue_B7


MatchLfnEntry_nextOrd_B7::
    ld hl, sp+$09
    inc [hl]
    jr nz, MatchLfnEntry_loopBack_B7

    inc hl
    inc [hl]

MatchLfnEntry_loopBack_B7::
    jp MatchLfnEntry_charLoop_B7


MatchLfnEntry_checkLastFlag_B7::
    ld hl, sp+$04
    ld a, [hl]
    and $40
    jr nz, MatchLfnEntry_checkSpare_B7

    jp MatchLfnEntry_matched_B7


MatchLfnEntry_checkSpare_B7::
    ld hl, sp+$0b
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp c, MatchLfnEntry_clearSpare_B7

    ld de, $0000
    jp MatchLfnEntry_epilogue_B7


MatchLfnEntry_clearSpare_B7::
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

MatchLfnEntry_matched_B7::
    ld de, $0001

MatchLfnEntry_epilogue_B7::
    add sp, $0d
    ret


PutLfn_B7::
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

PutLfn_B7_charLoop::
    ld hl, sp+$02
    ld a, [hl]
    inc a
    jp nz, PutLfn_B7_loadWchar

    inc hl
    ld a, [hl]
    inc a
    jp z, PutLfn_B7_storeWchar

PutLfn_B7_loadWchar::
    ld hl, sp+$00
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, PutLfn_B7_indexLfn

    inc hl
    inc [hl]

PutLfn_B7_indexLfn::
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

PutLfn_B7_storeWchar::
    ld de, LfnOfs_B7
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
    jp nz, PutLfn_B7_nextSlot

    dec hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff

PutLfn_B7_nextSlot::
    ld hl, sp+$04
    inc [hl]
    jr nz, PutLfn_B7_checkDone

    inc hl
    inc [hl]

PutLfn_B7_checkDone::
    ld hl, sp+$04
    ld a, [hl]
    sub $0d
    inc hl
    ld a, [hl]
    sbc $00
    jp c, PutLfn_B7_charLoop

    ld hl, sp+$02
    ld a, [hl]
    inc a
    jp nz, PutLfn_B7_moreLfn

    inc hl
    ld a, [hl]
    inc a
    jp z, PutLfn_B7_setLlef

PutLfn_B7_moreLfn::
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
    jp nz, PutLfn_B7_storeOrd

PutLfn_B7_setLlef::
    ld hl, sp+$0c
    ld a, [hl]
    or $40
    ld [hl], a

PutLfn_B7_storeOrd::
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
; GenNumName_B7: same as GenNumName_B9 (09:6201). Bank-local FatFs gen_numname copy.

GenNumName_B7::
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
    jp nc, GenNumName_B7_makeSuffix

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

GenNumName_B7_crcLfnLoop::
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
    jp z, GenNumName_B7_storeHashSeq

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

GenNumName_B7_crcBitLoop::
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
    jr nz, GenNumName_B7_crcPolyXor

    jp GenNumName_B7_crcBitNext


GenNumName_B7_crcPolyXor::
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

GenNumName_B7_crcBitNext::
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
    jp nz, GenNumName_B7_crcBitLoop

    jp GenNumName_B7_crcLfnLoop


GenNumName_B7_storeHashSeq::
    ld hl, sp+$0a
    ld a, [hl]
    ld hl, sp+$25
    ld [hl], a
    ld hl, sp+$0b
    ld a, [hl]
    ld hl, sp+$26
    ld [hl], a

GenNumName_B7_makeSuffix::
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

GenNumName_B7_hexDigit::
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
    jp nc, GenNumName_B7_storeDigit

    ld a, [hl]
    add $07
    ld [hl], a

GenNumName_B7_storeDigit::
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

GenNumName_B7_seqShr4::
    ld hl, sp+$26
    srl [hl]
    dec hl
    rr [hl]
    dec a
    jr nz, GenNumName_B7_seqShr4

    ld a, [hl+]
    or [hl]
    jp nz, GenNumName_B7_hexDigit

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

GenNumName_B7_findAppend::
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
    jp nc, GenNumName_B7_appendStart

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
    jp z, GenNumName_B7_appendStart

    ld hl, sp+$10
    inc [hl]
    jr nz, GenNumName_B7_findAppendCont

    inc hl
    inc [hl]

GenNumName_B7_findAppendCont::
    jp GenNumName_B7_findAppend


GenNumName_B7_appendStart::
    ld hl, sp+$04
    ld a, [hl+]
    ld e, [hl]
    dec hl
    ld [hl+], a
    ld [hl], e

GenNumName_B7_appendLoop::
    ld hl, sp+$10
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, GenNumName_B7_appendInc

    inc hl
    inc [hl]

GenNumName_B7_appendInc::
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
    jp nc, GenNumName_B7_appendSpace

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, GenNumName_B7_appendFromNs

    inc hl
    inc [hl]

GenNumName_B7_appendFromNs::
    ld hl, sp+$00
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    jp GenNumName_B7_appendStore


GenNumName_B7_appendSpace::
    ld c, $20

GenNumName_B7_appendStore::
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
    jp c, GenNumName_B7_appendLoop

    add sp, $1d
    ret


SumSfn_B7::
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

SumSfn_B7_loop::
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
    jr nz, SumSfn_B7_afterPtrInc

    inc hl
    inc [hl]

SumSfn_B7_afterPtrInc::
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
    jp nz, SumSfn_B7_loop

    inc hl
    ld e, [hl]
    add sp, $05
    ret


; [ezgb]
; DirFind_B7(dp): FatFs dir_find. DirSdi_B7(0); fail Jump_007_62b9 init else err Jump_007_64f3.
; Jump_007_62b9: clear ord/hash ptrs; Jump_007_632b read entry + MoveWindow_B7; fail Jump_007_64f0; LFN chain Jump_007_6384 else ord=4 Jump_007_64f0.
; Jump_007_6384: attr — deleted $E5 Jump_007_63a9; volume jr_007_63a3; LFN ord $0F Jump_007_63c4 else Jump_007_63bc/Jump_007_63c4 SFN path.
; jr_007_63c7: empty LFN chk Jump_007_64d8; AM_LFN jr_007_63df store ord/chksum else Jump_007_640b ord compare (Jump_007_6416/jr_007_6419/Jump_007_642d/Jump_007_6432/Jump_007_6434 CmpLfn_B7).
; Jump_007_6456/Jump_007_645b/Jump_007_645d/Jump_007_646a/Jump_007_646c: LFN ord update Jump_007_64d8; Jump_007_6472 SumSfn_B7 match Jump_007_64f0.
; Jump_007_648b NTRES jr_007_64a9 skip; Jump_007_64ac MemCmp_B7 SFN match Jump_007_64f0 else Jump_007_64c8 invalidate; Jump_007_64d8 DirNext_B7 loop Jump_007_632b; Jump_007_64f0/Jump_007_64f3 epilogue.

DirFind_B7::
    add sp, -$1a
    ld hl, $0000
    push hl
    ld hl, sp+$1e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirSdi_B7
    add sp, $04
    ld c, e
    ld hl, sp+$19
    ld [hl], c
    xor a
    or [hl]
    jp z, DirFind_B7_initOrd

    ld e, [hl]
    jp DirFind_B7_epilogue


DirFind_B7_initOrd::
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

DirFind_B7_readEntry::
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
    jp nz, DirFind_B7_found

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
    jp nz, DirFind_B7_checkAttr

    inc hl
    ld [hl], $04
    jp DirFind_B7_found


DirFind_B7_checkAttr::
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
    jp z, DirFind_B7_deletedEntry

    ld a, c
    and $08
    jr nz, DirFind_B7_volumeSkip

    jp DirFind_B7_checkAmLfn


DirFind_B7_volumeSkip::
    ld a, c
    sub $0f
    jp z, DirFind_B7_checkAmLfn

DirFind_B7_deletedEntry::
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
    jp DirFind_B7_dirNextLoop


DirFind_B7_checkAmLfn::
    ld a, c
    sub $0f
    jp nz, DirFind_B7_sfnPath

    jr DirFind_B7_lfnChain

DirFind_B7_sfnPath::
    jp DirFind_B7_sumSfnMatch


DirFind_B7_lfnChain::
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
    jp z, DirFind_B7_dirNextLoop

    ld hl, sp+$18
    ld a, [hl]
    and $40
    jr nz, DirFind_B7_storeOrdChksum

    jp DirFind_B7_ordCompare


DirFind_B7_storeOrdChksum::
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

DirFind_B7_ordCompare::
    ld hl, sp+$18
    ld a, [hl]
    ld hl, sp+$15
    sub [hl]
    jp nz, DirFind_B7_ordMismatch

    jr DirFind_B7_ordMatch

DirFind_B7_ordMismatch::
    jp DirFind_B7_cmpLfnFail


DirFind_B7_ordMatch::
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
    jp z, DirFind_B7_cmpLfnOk

DirFind_B7_cmpLfnFail::
    ld c, $00
    jp DirFind_B7_afterCmpLfn


DirFind_B7_cmpLfnOk::
    ld c, $01

DirFind_B7_afterCmpLfn::
    xor a
    or c
    jp z, DirFind_B7_ordUpdateFail

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
    call CmpLfn_B7
    add sp, $04
    ld b, d
    ld c, e
    ld a, c
    or b
    jp nz, DirFind_B7_ordUpdateOk

DirFind_B7_ordUpdateFail::
    ld c, $00
    jp DirFind_B7_afterOrdUpdate


DirFind_B7_ordUpdateOk::
    ld c, $01

DirFind_B7_afterOrdUpdate::
    xor a
    or c
    jp z, DirFind_B7_ordInvalidate

    ld hl, sp+$15
    ld a, [hl]
    dec a
    ld c, a
    jp DirFind_B7_storeOrd


DirFind_B7_ordInvalidate::
    ld c, $ff

DirFind_B7_storeOrd::
    ld hl, sp+$15
    ld [hl], c
    jp DirFind_B7_dirNextLoop


DirFind_B7_sumSfnMatch::
    xor a
    ld hl, sp+$15
    or [hl]
    jp nz, DirFind_B7_checkNtres

    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call SumSfn_B7
    add sp, $02
    ld c, e
    ld hl, sp+$14
    ld a, [hl]
    sub c
    jp z, DirFind_B7_found

DirFind_B7_checkNtres::
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
    jr nz, DirFind_B7_ntresSkip

    jp DirFind_B7_memcmpSfn


DirFind_B7_ntresSkip::
    jp DirFind_B7_invalidate


DirFind_B7_memcmpSfn::
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
    call MemCmp_B7
    add sp, $05
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, DirFind_B7_found

DirFind_B7_invalidate::
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

DirFind_B7_dirNextLoop::
    ld hl, $0000
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirNext_B7
    add sp, $04
    ld c, e
    ld hl, sp+$19
    ld [hl], c
    xor a
    or [hl]
    jp z, DirFind_B7_readEntry

DirFind_B7_found::
    ld hl, sp+$19
    ld e, [hl]

DirFind_B7_epilogue::
    add sp, $1a
    ret


; [ezgb]
; DirRead_B7(dp, vol@sp+$13): FatFs dir_read. Frame -$0f; sp+$0e default E=$04; sp+$09 LFN ord/$ff.
; Jump_007_6519: load dir ptr@dp+$0e — cluster zero → Jump_007_66df; MoveWindow_B7 err → Jump_007_66df.
; NTRES@dp+$1c≠0 → Jump_007_6586; else set mode $04 → Jump_007_66df.
; Jump_007_6586: SFN[0] DDEM $E5 → Jump_007_65c6; AM_VOL vs vol arg (Jump_007_65b4/jr_007_65b5) mismatch → Jump_007_65c6.
; Jump_007_65cd: ord $0F → jr_007_65da else Jump_007_65d7→Jump_007_6697 SFN path.
; jr_007_65da: AM_VOL → jr_007_65e4 stash checksum + dptr else Jump_007_6628 attr filter.
; Jump_007_6628: attr≠sp+$09 → Jump_007_6633→Jump_007_664a; jr_007_6636 checksum match → Jump_007_664f else Jump_007_664a.
; Jump_007_6651: LFN ord ok → call $4ef7; fail Jump_007_667b else Jump_007_6680; Jump_007_6682 dec ord or Jump_007_668f→$ff → Jump_007_6691→Jump_007_66c7.
; Jump_007_6697: sp+$09≠0 → Jump_007_66b0 clear lfn ptr; else SumSfn_B7 match → Jump_007_66df.
; Jump_007_66c7: DirNext_B7(0); E=0 → Jump_007_6519; Jump_007_66df: E=0 Jump_007_66fa else zero dir ptr → Jump_007_66fa ret E.

DirRead_B7::
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

DirRead_B7_entryLoop::
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
    jp z, DirRead_B7_done

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
    jp nz, DirRead_B7_done

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
    jp nz, DirRead_B7_checkSfn

    inc hl
    inc hl
    ld [hl], $04
    jp DirRead_B7_done


DirRead_B7_checkSfn::
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
    jp z, DirRead_B7_skipEntry

    ld hl, sp+$0d
    ld c, [hl]
    ld b, $00
    ld a, c
    and $df
    ld c, a
    sub $08
    jp nz, DirRead_B7_volCompare

    or b
    jp nz, DirRead_B7_volCompare

    ld a, $01
    jr DirRead_B7_volCompareJr

DirRead_B7_volCompare::
    xor a

DirRead_B7_volCompareJr::
    ld c, a
    rla
    sbc a
    ld b, a
    ld a, c
    ld hl, sp+$13
    sub [hl]
    jp nz, DirRead_B7_skipEntry

    ld a, b
    inc hl
    sub [hl]
    jp z, DirRead_B7_checkOrd

DirRead_B7_skipEntry::
    ld hl, sp+$09
    ld [hl], $ff
    jp DirRead_B7_dirNext


DirRead_B7_checkOrd::
    ld hl, sp+$0d
    ld a, [hl]
    sub $0f
    jp nz, DirRead_B7_sfnPath

    jr DirRead_B7_lfnOrd

DirRead_B7_sfnPath::
    jp DirRead_B7_sfnSumCheck


DirRead_B7_lfnOrd::
    ld hl, sp+$0c
    ld a, [hl]
    and $40
    jr nz, DirRead_B7_stashChksum

    jp DirRead_B7_attrFilter


DirRead_B7_stashChksum::
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

DirRead_B7_attrFilter::
    ld hl, sp+$0c
    ld a, [hl]
    ld hl, sp+$09
    sub [hl]
    jp nz, DirRead_B7_attrMismatch

    jr DirRead_B7_chksumMatch

DirRead_B7_attrMismatch::
    jp DirRead_B7_lfnFail


DirRead_B7_chksumMatch::
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
    jp z, DirRead_B7_lfnOk

DirRead_B7_lfnFail::
    ld c, $00
    jp DirRead_B7_afterLfnGate


DirRead_B7_lfnOk::
    ld c, $01

DirRead_B7_afterLfnGate::
    xor a
    or c
    jp z, DirRead_B7_pickLfnFail

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
    jp nz, DirRead_B7_pickLfnOk

DirRead_B7_pickLfnFail::
    ld c, $00
    jp DirRead_B7_afterPickLfn


DirRead_B7_pickLfnOk::
    ld c, $01

DirRead_B7_afterPickLfn::
    xor a
    or c
    jp z, DirRead_B7_ordInvalidate

    ld hl, sp+$09
    ld a, [hl]
    dec a
    ld c, a
    jp DirRead_B7_storeOrd


DirRead_B7_ordInvalidate::
    ld c, $ff

DirRead_B7_storeOrd::
    ld hl, sp+$09
    ld [hl], c
    jp DirRead_B7_dirNext


DirRead_B7_sfnSumCheck::
    xor a
    ld hl, sp+$09
    or [hl]
    jp nz, DirRead_B7_clearLfnPtr

    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call SumSfn_B7
    add sp, $02
    ld c, e
    ld hl, sp+$08
    ld a, [hl]
    sub c
    jp z, DirRead_B7_done

DirRead_B7_clearLfnPtr::
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
    jp DirRead_B7_done


DirRead_B7_dirNext::
    ld hl, $0000
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirNext_B7
    add sp, $04
    ld c, e
    ld hl, sp+$0e
    ld [hl], c
    xor a
    or [hl]
    jp z, DirRead_B7_entryLoop

DirRead_B7_done::
    xor a
    ld hl, sp+$0e
    or [hl]
    jp z, DirRead_B7_epilogue

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

DirRead_B7_epilogue::
    ld hl, sp+$0e
    ld e, [hl]
    add sp, $0f
    ret


; [ezgb]
; DirRegister_B7(dp): FatFs dir_register. Frame -$26; copy SFN/LFN from dp; sp+$25=E.
; NSFLAG directory → jr_007_6771 E=$06 Jump_007_6a8c; Jump_007_6776: AM_DIR → jr_007_677e GenNumName loop Jump_007_679f.
; Jump_007_679f: idx<100 GenNumName_B7+DirFind_B7; taken → jr_007_67e2 ++idx; miss → Jump_007_67e5.
; Jump_007_67e5: idx==100 → jr_007_67f8 E=$07 else Jump_007_67f5→Jump_007_67fd; E==$04 → Jump_007_680b patch attr/size.
; Jump_007_682a: LFN (attr&$02) → jr_007_6838 count slots Jump_007_683f/jr_007_6862; Jump_007_6865 U16Div → Jump_007_688a else Jump_007_6883 n=1.
; Jump_007_688a: DirAlloc_B7; err → Jump_007_69bc; LFN slots Jump_007_6912 (DirSdi, SumSfn, MoveWindow, PutLfn_B7, DirNext) loop.
; Jump_007_69bc: err → Jump_007_6a89 else finalize SFN (MoveWindow, MemSet8, MemCpy16, attr mask) + FA_DIRTY.
; Jump_007_6a89/Jump_007_6a8c add sp,$26 ret E.

DirRegister_B7::
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
    jr nz, DirRegister_B7_deniedIsDir

    jp DirRegister_B7_checkCollision


DirRegister_B7_deniedIsDir::
    ld e, $06
    jp DirRegister_B7_epilogue


DirRegister_B7_checkCollision::
    ld a, c
    and $01
    jr nz, DirRegister_B7_genNumInit

    jp DirRegister_B7_checkLfn


DirRegister_B7_genNumInit::
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

DirRegister_B7_genNumLoop::
    ld hl, sp+$23
    ld a, [hl]
    sub $64
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, DirRegister_B7_afterGenNum

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
    call GenNumName_B7
    add sp, $08
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirFind_B7
    add sp, $02
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, DirRegister_B7_afterGenNum

    dec hl
    dec hl
    inc [hl]
    jr nz, DirRegister_B7_genNumNext

    inc hl
    inc [hl]

DirRegister_B7_genNumNext::
    jp DirRegister_B7_genNumLoop


DirRegister_B7_afterGenNum::
    ld hl, sp+$23
    ld a, [hl]
    sub $64
    jp nz, DirRegister_B7_genNumOk

    inc hl
    ld a, [hl]
    or a
    jp nz, DirRegister_B7_genNumOk

    jr DirRegister_B7_deniedTooMany

DirRegister_B7_genNumOk::
    jp DirRegister_B7_checkNoFile


DirRegister_B7_deniedTooMany::
    ld e, $07
    jp DirRegister_B7_epilogue


DirRegister_B7_checkNoFile::
    ld hl, sp+$25
    ld a, [hl]
    sub $04
    jp z, DirRegister_B7_patchAttrSize

    ld hl, sp+$25
    ld e, [hl]
    jp DirRegister_B7_epilogue


DirRegister_B7_patchAttrSize::
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

DirRegister_B7_checkLfn::
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $02
    jr nz, DirRegister_B7_countLfnSlots

    jp DirRegister_B7_slotsOne


DirRegister_B7_countLfnSlots::
    ld hl, sp+$23
    ld [hl], $00
    inc hl
    ld [hl], $00

DirRegister_B7_lfnLenLoop::
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
    jp z, DirRegister_B7_u16DivSlots

    ld hl, sp+$23
    inc [hl]
    jr nz, DirRegister_B7_lfnLenCont

    inc hl
    inc [hl]

DirRegister_B7_lfnLenCont::
    jp DirRegister_B7_lfnLenLoop


DirRegister_B7_u16DivSlots::
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
    jp DirRegister_B7_dirAlloc


DirRegister_B7_slotsOne::
    ld hl, sp+$21
    ld [hl], $01
    inc hl
    ld [hl], $00

DirRegister_B7_dirAlloc::
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
    call DirAlloc_B7
    add sp, $04
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, DirRegister_B7_finalizeSfn

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
    jp z, DirRegister_B7_finalizeSfn

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
    call DirSdi_B7
    add sp, $04
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, DirRegister_B7_finalizeSfn

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
    call SumSfn_B7
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

DirRegister_B7_putLfnLoop::
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
    jp nz, DirRegister_B7_finalizeSfn

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
    call PutLfn_B7
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
    call DirNext_B7
    add sp, $04
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, DirRegister_B7_finalizeSfn

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
    jp nz, DirRegister_B7_putLfnLoop

DirRegister_B7_finalizeSfn::
    xor a
    ld hl, sp+$25
    or [hl]
    jp nz, DirRegister_B7_loadResult

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
    jp nz, DirRegister_B7_loadResult

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

DirRegister_B7_loadResult::
    ld hl, sp+$25
    ld e, [hl]

DirRegister_B7_epilogue::
    add sp, $26
    ret


; [ezgb]
; GetFileInfo_B7(fno, dp): FatFs get_fileinfo. Frame -$16; copy dir cluster/fsize from dp+$0e.
; Cluster zero → Jump_007_6c27; else build SFN@fno+$09 via Jump_007_6afe loop (11 chars).
; Jump_007_6afe: space → continue (jr_007_6b14 ++idx); $05 → jr_007_6b2e $E5→Jump_007_6b30 else Jump_007_6b2b; idx==9 → jr_007_6b43 insert '.' else Jump_007_6b40→Jump_007_6b51.
; Jump_007_6b51/jr_007_6b51: A-Z/a-z case; NTRES.3 → jr_007_6b6d lowercase; Jump_007_6b71 store → jr_007_6b7e → Jump_007_6afe.
; Jump_007_6b81: copy attr/fsize/date/cluster/time into fno fields from dir entry.
; Jump_007_6c27: NUL-term SFN; lfnbuf@dp+$16 zero → Jump_007_6d48 else LFN walk.
; lfn_ptr/dp lfn refs zero → Jump_007_6d38; ord==$ff → Jump_007_6c91 else Jump_007_6d38.
; Jump_007_6caf: next wchar; zero → Jump_007_6d38; MapCp437 fail → Jump_007_6d38; ok Jump_007_6cf7 append.
; Jump_007_6d16/jr_007_6d21: advance fno LFN write idx → Jump_007_6caf; Jump_007_6d38 NUL-term LFN; Jump_007_6d48 add sp,$16 ret.

GetFileInfo_B7::
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
    jp z, GetFileInfo_B7_nulTermSfn

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

GetFileInfo_B7_sfnLoop::
    ld hl, sp+$14
    ld a, [hl]
    sub $0b
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, GetFileInfo_B7_copyMeta

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, GetFileInfo_B7_sfnSkipSpace

    inc hl
    inc [hl]

GetFileInfo_B7_sfnSkipSpace::
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
    jp z, GetFileInfo_B7_sfnLoop

    ld a, c
    sub $05
    jp nz, GetFileInfo_B7_afterKanji05

    jr GetFileInfo_B7_mapE5

GetFileInfo_B7_afterKanji05::
    jp GetFileInfo_B7_checkDotSlot


GetFileInfo_B7_mapE5::
    ld c, $e5

GetFileInfo_B7_checkDotSlot::
    ld hl, sp+$14
    ld a, [hl]
    sub $09
    jp nz, GetFileInfo_B7_noDotInsert

    inc hl
    ld a, [hl]
    or a
    jp nz, GetFileInfo_B7_noDotInsert

    jr GetFileInfo_B7_insertDot

GetFileInfo_B7_noDotInsert::
    jp GetFileInfo_B7_caseAdjust


GetFileInfo_B7_insertDot::
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $2e
    ld [de], a
    dec hl
    inc [hl]
    jr nz, GetFileInfo_B7_caseAdjust

    inc hl
    inc [hl]

GetFileInfo_B7_caseAdjust::
    ld a, c
    sub $41
    rlca
    jp c, GetFileInfo_B7_storeSfnByte

    ld a, $5a
    sub c
    rlca
    jp c, GetFileInfo_B7_storeSfnByte

    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    and $08
    jr nz, GetFileInfo_B7_toLower

    jp GetFileInfo_B7_storeSfnByte


GetFileInfo_B7_toLower::
    ld a, c
    add $20
    ld c, a

GetFileInfo_B7_storeSfnByte::
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    dec hl
    inc [hl]
    jr nz, GetFileInfo_B7_sfnLoopCont

    inc hl
    inc [hl]

GetFileInfo_B7_sfnLoopCont::
    jp GetFileInfo_B7_sfnLoop


GetFileInfo_B7_copyMeta::
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

GetFileInfo_B7_nulTermSfn::
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
    jp z, GetFileInfo_B7_epilogue

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
    jp z, GetFileInfo_B7_nulTermLfn

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
    jp z, GetFileInfo_B7_nulTermLfn

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
    jp nz, GetFileInfo_B7_lfnSetup

    ld a, b
    inc a
    jp z, GetFileInfo_B7_nulTermLfn

GetFileInfo_B7_lfnSetup::
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

GetFileInfo_B7_lfnLoop::
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
    jp z, GetFileInfo_B7_nulTermLfn

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
    jp nz, GetFileInfo_B7_lfnAppend

    ld hl, sp+$00
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp GetFileInfo_B7_nulTermLfn


GetFileInfo_B7_lfnAppend::
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
    jp c, GetFileInfo_B7_lfnAdvance

    ld hl, sp+$00
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp GetFileInfo_B7_nulTermLfn


GetFileInfo_B7_lfnAdvance::
    ld hl, sp+$14
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, GetFileInfo_B7_lfnAdvanceCont

    inc hl
    inc [hl]

GetFileInfo_B7_lfnAdvanceCont::
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
    jp GetFileInfo_B7_lfnLoop


GetFileInfo_B7_nulTermLfn::
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

GetFileInfo_B7_epilogue::
    add sp, $16
    ret


; [ezgb]
; CreateName_B7(dp, path): FatFs create_name twin of CreateName_B9 (09:6c3e). Frame -$1b; parse next path segment; build SFN/LFN+NSFLAG.
; Jump_007_6d66: skip leading '/' ($2f) or '\\' ($5c): Jump_007_6d7c/jr_007_6d7c ++BC loop; else Jump_007_6d79 → Jump_007_6d85 start segment.
; Jump_007_6d85: stash path; lfnbuf@dp+$16; clear counters. Jump_007_6dbc: ++idx (jr_007_6dc7); load char; <' ' or '/' or '\\' → Jump_007_6e8e end segment.
; Jump_007_6df8/Jump_007_6e06: not terminator; Jump_007_6e17: if lfn idx≥$ff → E=$06 Jump_007_73c0; else MapCp437; fail → Jump_007_73c0.
; Jump_007_6e3c: if <*$80 MemChr illegal set; hit → Jump_007_73c0; Jump_007_6e62/jr_007_6e6d store wchar to lfnbuf → Jump_007_6dbc.
; Jump_007_6e8e: write advanced path ptr; last char <' ' → C=$04 (NSFLAG) else Jump_007_6eb6 C=0; Jump_007_6eb8 store NSFLAG@sp+$19.
; If lfnlen!=1 Jump_007_6ecb → Jump_007_6ef1; else jr_007_6ece: last wchar=='.' → Jump_007_6f55/jr_007_6f55 else Jump_007_6ef1.
; Jump_007_6ef1: len!=2 → Jump_007_6f01 → Jump_007_6fe8; else jr_007_6f04: '..' check (Jump_007_6f29/jr_007_6f2c/Jump_007_6f52) → Jump_007_6f55 or Jump_007_6fe8.
; Jump_007_6f55/jr_007_6f55: NUL-term LFN; Jump_007_6f85 fill SFN 11 slots (Jump_007_6fb9/Jump_007_6fbd); done Jump_007_6fcb.
; SFN pad loop: Jump_007_6f85; insert '.' Jump_007_6fb9 else space Jump_007_6fbd; jr_007_6fc8 → Jump_007_6f85; done Jump_007_6fcb OR NSFLAG|$20 → Jump_007_73c0 (dot-only names).
; Jump_007_6fe8: normal path; Jump_007_6ff0 strip trailing ' '/' .' (Jump_007_7021 / Jump_007_7031 / Jump_007_7034 / jr_007_7034); Jump_007_7048 empty → E=$06 Jump_007_73c0 else Jump_007_705c NUL-term + MemSet8_B7 spaces into SFN.
; Jump_007_70a7: skip leading ' '/' .' (Jump_007_70c9 / Jump_007_70d5 / Jump_007_70d8 / jr_007_70d8 / jr_007_70df); non-lead Jump_007_70ea; if skipped NSFLAG|$03 then Jump_007_70ff.
; Jump_007_70ff: walk for last '.' (Jump_007_7136 → Jump_007_70ff); none/done Jump_007_7143 init body len=8 then Jump_007_7155.
; Jump_007_7155 SFN fill: next wchar (jr_007_7160); NUL→Jump_007_731f; space Jump_007_71b0; '.' Jump_007_718b/Jump_007_719b/jr_007_719e; else Jump_007_71b9; slot full Jump_007_71df/jr_007_71df/Jump_007_71ef/jr_007_71f2; body	oext Jump_007_71fb/Jump_007_720d/Jump_007_7213; else Jump_007_71dc → Jump_007_7240 MapCp437.
; Jump_007_7240: wchar>=$80 MapCp437 (fail Jump_007_727b NSFLAG|$02); then Jump_007_7281 MemChr_B7 illegal set → '_' Jump_007_729d NSFLAG|$03 else Jump_007_72ac.
; Case: A-Z Jump_007_72cc skip else NSFLAG|$02 → Jump_007_72fa; a-z Jump_007_72cc NSFLAG|$01 + toupper; store via jr_007_7310 → Jump_007_7155.
; Jump_007_731f: SFN[0]==$E5 → $05 (jr_007_7339) else Jump_007_7336/Jump_007_7341; body-only Jump_007_7351/jr_007_7354 NT<<2; case mix Jump_007_735a/Jump_007_7372/Jump_007_7375/jr_007_7375 → NSFLAG|$02; Jump_007_737b/jr_007_7385/Jump_007_7388/Jump_007_7395/jr_007_7398/Jump_007_739e/Jump_007_73a6/jr_007_73a9/Jump_007_73af store NSFLAG; E=0 → Jump_007_73c0.
; CreateName CF ends at cleanup Jump (add sp,$1b / ret). Post-ret illegal-char table then FollowPath_B7 @ 07:73d3 (sym; twin of B5/B6/B9) — not CreateName interior.

CreateName_B7::
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

CreateName_B7_skipLeadSep::
    ld a, [bc]
    ld hl, sp+$08
    ld [hl], a
    sub $2f
    jp z, CreateName_B7_skipLeadSepInc

    ld hl, sp+$08
    ld a, [hl]
    sub $5c
    jp nz, CreateName_B7_skipLeadSepElse

    jr CreateName_B7_skipLeadSepInc

CreateName_B7_skipLeadSepElse::
    jp CreateName_B7_startSegment


CreateName_B7_skipLeadSepInc::
    inc bc
    ld hl, sp+$0b
    ld [hl], c
    inc hl
    ld [hl], b
    jp CreateName_B7_skipLeadSep


CreateName_B7_startSegment::
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

CreateName_B7_lfnCharLoop::
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, CreateName_B7_afterLfnPtrInc

    inc hl
    inc [hl]

CreateName_B7_afterLfnPtrInc::
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
    jp c, CreateName_B7_endSegment

    dec hl
    ld a, [hl]
    sub $2f
    jp nz, CreateName_B7_checkBackslashSep

    inc hl
    ld a, [hl]
    or a
    jp z, CreateName_B7_endSegment

CreateName_B7_checkBackslashSep::
    ld hl, sp+$17
    ld a, [hl]
    sub $5c
    jp nz, CreateName_B7_notTerminator

    inc hl
    ld a, [hl]
    or a
    jp z, CreateName_B7_endSegment

CreateName_B7_notTerminator::
    ld hl, sp+$02
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp c, CreateName_B7_mapCp437

    ld e, $06
    jp CreateName_B7_cleanup


CreateName_B7_mapCp437::
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
    jp nz, CreateName_B7_checkIllegalAscii

    ld e, $06
    jp CreateName_B7_cleanup


CreateName_B7_checkIllegalAscii::
    ld hl, sp+$17
    ld a, [hl]
    sub $80
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, CreateName_B7_storeWcharLfn

    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $73c3
    push hl
    call MemChr_B7
    add sp, $04
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, CreateName_B7_storeWcharLfn

    ld e, $06
    jp CreateName_B7_cleanup


CreateName_B7_storeWcharLfn::
    ld hl, sp+$02
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, CreateName_B7_afterWcharIdxInc

    inc hl
    inc [hl]

CreateName_B7_afterWcharIdxInc::
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
    jp CreateName_B7_lfnCharLoop


CreateName_B7_endSegment::
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
    jp nc, CreateName_B7_nsflagNotLast

    ld c, $04
    jp CreateName_B7_storeNsflag


CreateName_B7_nsflagNotLast::
    ld c, $00

CreateName_B7_storeNsflag::
    ld hl, sp+$19
    ld [hl], c
    ld hl, sp+$0d
    ld a, [hl]
    sub $01
    jp nz, CreateName_B7_notLen1Dot

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateName_B7_notLen1Dot

    jr CreateName_B7_checkSingleDot

CreateName_B7_notLen1Dot::
    jp CreateName_B7_checkDotDot


CreateName_B7_checkSingleDot::
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
    jp nz, CreateName_B7_checkDotDot

    or b
    jp z, CreateName_B7_dotEntry

CreateName_B7_checkDotDot::
    ld hl, sp+$0d
    ld a, [hl]
    sub $02
    jp nz, CreateName_B7_notLen2DotDot

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateName_B7_notLen2DotDot

    jr CreateName_B7_checkDotDotTail

CreateName_B7_notLen2DotDot::
    jp CreateName_B7_normalPath


CreateName_B7_checkDotDotTail::
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
    jp nz, CreateName_B7_dotDotMismatch

    or b
    jp nz, CreateName_B7_dotDotMismatch

    jr CreateName_B7_checkDotDotHead

CreateName_B7_dotDotMismatch::
    jp CreateName_B7_normalPath


CreateName_B7_checkDotDotHead::
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
    jp nz, CreateName_B7_notDotDot

    or b
    jp nz, CreateName_B7_notDotDot

    jr CreateName_B7_dotEntry

CreateName_B7_notDotDot::
    jp CreateName_B7_normalPath


CreateName_B7_dotEntry::
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

CreateName_B7_sfnPadLoop::
    ld hl, sp+$13
    ld a, [hl]
    sub $0b
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, CreateName_B7_dotEntryDone

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
    jp nc, CreateName_B7_sfnPadSpace

    ld hl, sp+$02
    ld [hl], $2e
    jp CreateName_B7_sfnPadStore


CreateName_B7_sfnPadSpace::
    ld hl, sp+$02
    ld [hl], $20

CreateName_B7_sfnPadStore::
    ld hl, sp+$02
    ld a, [hl]
    ld [bc], a
    ld hl, sp+$13
    inc [hl]
    jr nz, CreateName_B7_afterSfnPadIdxInc

    inc hl
    inc [hl]

CreateName_B7_afterSfnPadIdxInc::
    jp CreateName_B7_sfnPadLoop


CreateName_B7_dotEntryDone::
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
    jp CreateName_B7_cleanup


CreateName_B7_normalPath::
    ld hl, sp+$0d
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e

CreateName_B7_stripTrailing::
    ld hl, sp+$00
    ld a, [hl+]
    or [hl]
    jp z, CreateName_B7_afterStripTrail

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
    jp nz, CreateName_B7_stripTrailNotSpace

    inc hl
    ld a, [hl]
    or a
    jp z, CreateName_B7_stripTrailDec

CreateName_B7_stripTrailNotSpace::
    ld hl, sp+$17
    ld a, [hl]
    sub $2e
    jp nz, CreateName_B7_stripTrailBreak

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateName_B7_stripTrailBreak

    jr CreateName_B7_stripTrailDec

CreateName_B7_stripTrailBreak::
    jp CreateName_B7_afterStripTrail


CreateName_B7_stripTrailDec::
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
    jp CreateName_B7_stripTrailing


CreateName_B7_afterStripTrail::
    ld hl, sp+$00
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0d
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$00
    ld a, [hl+]
    or [hl]
    jp nz, CreateName_B7_nulTermClearSfn

    ld e, $06
    jp CreateName_B7_cleanup


CreateName_B7_nulTermClearSfn::
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

CreateName_B7_skipLeadSpaceDot::
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
    jp nz, CreateName_B7_skipLeadNotSpace

    or b
    jp z, CreateName_B7_skipLeadInc

CreateName_B7_skipLeadNotSpace::
    ld a, c
    sub $2e
    jp nz, CreateName_B7_skipLeadNonLead

    or b
    jp nz, CreateName_B7_skipLeadNonLead

    jr CreateName_B7_skipLeadInc

CreateName_B7_skipLeadNonLead::
    jp CreateName_B7_afterSkipLead


CreateName_B7_skipLeadInc::
    ld hl, sp+$02
    inc [hl]
    jr nz, CreateName_B7_afterSkipLeadIdxInc

    inc hl
    inc [hl]

CreateName_B7_afterSkipLeadIdxInc::
    ld hl, sp+$02
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0f
    ld [hl+], a
    ld [hl], e
    jp CreateName_B7_skipLeadSpaceDot


CreateName_B7_afterSkipLead::
    ld hl, sp+$02
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0f
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$02
    ld a, [hl+]
    or [hl]
    jp z, CreateName_B7_findLastDot

    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a

CreateName_B7_findLastDot::
    ld hl, sp+$0d
    ld a, [hl+]
    or [hl]
    jp z, CreateName_B7_initBodyLen

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
    jp nz, CreateName_B7_findLastDotCont

    or b
    jp z, CreateName_B7_initBodyLen

CreateName_B7_findLastDotCont::
    ld hl, sp+$02
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$0d
    ld [hl], c
    inc hl
    ld [hl], b
    jp CreateName_B7_findLastDot


CreateName_B7_initBodyLen::
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

CreateName_B7_sfnFillLoop::
    ld hl, sp+$0f
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, CreateName_B7_afterSfnFillIdxInc

    inc hl
    inc [hl]

CreateName_B7_afterSfnFillIdxInc::
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
    jp z, CreateName_B7_sfnDoneDdem

    dec hl
    ld a, [hl]
    sub $20
    jp nz, CreateName_B7_sfnFillCheckDot

    inc hl
    ld a, [hl]
    or a
    jp z, CreateName_B7_sfnFillSpaceLoss

CreateName_B7_sfnFillCheckDot::
    ld hl, sp+$17
    ld a, [hl]
    sub $2e
    jp nz, CreateName_B7_sfnFillNotDot

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateName_B7_sfnFillNotDot

    jr CreateName_B7_sfnFillDotPath

CreateName_B7_sfnFillNotDot::
    jp CreateName_B7_sfnFillSlotCheck


CreateName_B7_sfnFillDotPath::
    ld hl, sp+$0f
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, CreateName_B7_sfnFillSpaceLoss

    ld hl, sp+$10
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp z, CreateName_B7_sfnFillSlotCheck

CreateName_B7_sfnFillSpaceLoss::
    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a
    jp CreateName_B7_sfnFillLoop


CreateName_B7_sfnFillSlotCheck::
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
    jp nc, CreateName_B7_sfnFillSlotFull

    ld hl, sp+$0f
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, CreateName_B7_sfnFillToMap

    ld hl, sp+$10
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, CreateName_B7_sfnFillToMap

    jr CreateName_B7_sfnFillSlotFull

CreateName_B7_sfnFillToMap::
    jp CreateName_B7_sfnMapCp437


CreateName_B7_sfnFillSlotFull::
    ld hl, sp+$11
    ld a, [hl]
    sub $0b
    jp nz, CreateName_B7_sfnFillToExt

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateName_B7_sfnFillToExt

    jr CreateName_B7_sfnFillSlotFullLoss

CreateName_B7_sfnFillToExt::
    jp CreateName_B7_sfnFillBodyToExt


CreateName_B7_sfnFillSlotFullLoss::
    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a
    jp CreateName_B7_sfnDoneDdem


CreateName_B7_sfnFillBodyToExt::
    ld hl, sp+$0f
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, CreateName_B7_sfnFillBodyOverflow

    ld hl, sp+$10
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp z, CreateName_B7_sfnFillEnterExt

CreateName_B7_sfnFillBodyOverflow::
    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a

CreateName_B7_sfnFillEnterExt::
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
    jp c, CreateName_B7_sfnDoneDdem

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
    jp CreateName_B7_sfnFillLoop


CreateName_B7_sfnMapCp437::
    ld hl, sp+$17
    ld a, [hl]
    sub $80
    inc hl
    ld a, [hl]
    sbc $00
    jp c, CreateName_B7_sfnCheckIllegal

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
    jp z, CreateName_B7_sfnMapCp437Fail

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

CreateName_B7_sfnMapCp437Fail::
    ld hl, sp+$19
    ld a, [hl]
    or $02
    ld [hl], a

CreateName_B7_sfnCheckIllegal::
    ld hl, sp+$17
    ld a, [hl+]
    or [hl]
    jp z, CreateName_B7_sfnReplaceUnderscore

    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $73cc
    push hl
    call MemChr_B7
    add sp, $04
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, CreateName_B7_sfnCaseUpper

CreateName_B7_sfnReplaceUnderscore::
    ld hl, sp+$17
    ld [hl], $5f
    inc hl
    ld [hl], $00
    inc hl
    ld a, [hl]
    or $03
    ld [hl], a
    jp CreateName_B7_sfnStoreByte


CreateName_B7_sfnCaseUpper::
    ld hl, sp+$17
    ld a, [hl]
    sub $41
    inc hl
    ld a, [hl]
    sbc $00
    jp c, CreateName_B7_sfnCaseLower

    ld a, $5a
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp c, CreateName_B7_sfnCaseLower

    inc hl
    inc hl
    ld a, [hl]
    or $02
    ld [hl], a
    jp CreateName_B7_sfnStoreByte


CreateName_B7_sfnCaseLower::
    ld hl, sp+$17
    ld a, [hl]
    sub $61
    inc hl
    ld a, [hl]
    sbc $00
    jp c, CreateName_B7_sfnStoreByte

    ld a, $7a
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp c, CreateName_B7_sfnStoreByte

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

CreateName_B7_sfnStoreByte::
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
    jr nz, CreateName_B7_sfnStoreByteJr

    inc hl
    inc [hl]

CreateName_B7_sfnStoreByteJr::
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
    jp CreateName_B7_sfnFillLoop


CreateName_B7_sfnDoneDdem::
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
    jp nz, CreateName_B7_afterDdem

    jr CreateName_B7_replaceDdem

CreateName_B7_afterDdem::
    jp CreateName_B7_checkBodyOnly


CreateName_B7_replaceDdem::
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $05
    ld [de], a

CreateName_B7_checkBodyOnly::
    ld hl, sp+$11
    ld a, [hl]
    sub $08
    jp nz, CreateName_B7_afterBodyOnly

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateName_B7_afterBodyOnly

    jr CreateName_B7_ntShiftBodyOnly

CreateName_B7_afterBodyOnly::
    jp CreateName_B7_caseMixCheck


CreateName_B7_ntShiftBodyOnly::
    ld hl, sp+$1a
    sla [hl]
    sla [hl]

CreateName_B7_caseMixCheck::
    ld hl, sp+$1a
    ld a, [hl]
    and $0c
    ld c, a
    sub $0c
    jp z, CreateName_B7_caseMixSetLfn

    ld hl, sp+$1a
    ld a, [hl]
    and $03
    ld b, a
    sub $03
    jp nz, CreateName_B7_caseMixOk

    jr CreateName_B7_caseMixSetLfn

CreateName_B7_caseMixOk::
    jp CreateName_B7_storeNtFlags


CreateName_B7_caseMixSetLfn::
    ld hl, sp+$19
    ld a, [hl]
    or $02
    ld [hl], a

CreateName_B7_storeNtFlags::
    ld hl, sp+$19
    ld a, [hl]
    and $02
    jr nz, CreateName_B7_skipNtFlags

    jp CreateName_B7_ntExtCheck


CreateName_B7_skipNtFlags::
    jp CreateName_B7_storeNsflagFinal


CreateName_B7_ntExtCheck::
    ld hl, sp+$1a
    ld a, [hl]
    and $03
    ld b, a
    sub $01
    jp nz, CreateName_B7_afterNtExt

    jr CreateName_B7_setNsExt

CreateName_B7_afterNtExt::
    jp CreateName_B7_ntBodyCheck


CreateName_B7_setNsExt::
    ld hl, sp+$19
    ld a, [hl]
    or $10
    ld [hl], a

CreateName_B7_ntBodyCheck::
    ld a, c
    sub $04
    jp nz, CreateName_B7_afterNtBody

    jr CreateName_B7_setNsBody

CreateName_B7_afterNtBody::
    jp CreateName_B7_storeNsflagFinal


CreateName_B7_setNsBody::
    ld hl, sp+$19
    ld a, [hl]
    or $08
    ld [hl], a

CreateName_B7_storeNsflagFinal::
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

CreateName_B7_cleanup::
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
; FatFs follow_path (bank-7). Twin of FollowPath_B3/B5/B6/B9; CreateName_B7 sibling. Sym 07:73d3 (regen for asm label).
; Entry: skip leading '/' '\' (Jump_007_73ed → Jump_007_7419 else Jump_007_73f0 / jr_007_73f0 clear sclust → Jump_007_7457).
; Jump_007_7419: copy fs->cdir into dp->sclust; Join Jump_007_7457.
; Jump_007_7457: path[0]<' ' → DirSdi_B7(0) + clear fn → Jump_007_75d9 else Jump_007_7494 segment loop (CreateName_B7 / DirFind_B7).
; Jump_007_7494 segment loop: CreateName_B7; err→Jump_007_75d9; DirFind_B7; FR_NOFILE+$04 last-seg (jr_007_74f1) else Jump_007_74ee→Jump_007_75d9; NSFLAG|$20 (jr_007_74fb) clear sclust/fn + more path→Jump_007_7494 else last (jr_007_7535 E=0); non-last NSFLAG Jump_007_753c/jr_007_7546/Jump_007_7549 E=$05.
; Found (Jump_007_7550): last-seg jr_007_755a→Jump_007_75d9; else Jump_007_755d ATTR_DIR? jr_007_7587→Jump_007_7591 LdClust_B7 into sclust → Jump_007_7494 else Jump_007_758a E=$05; Jump_007_75d9 epilogue ret E.

FollowPath_B7::
    add sp, -$0b
    ld hl, sp+$0f
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, [bc]
    ld hl, sp+$06
    ld [hl], a
    sub $2f
    jp z, FollowPath_B7_clearSclust

    ld hl, sp+$06
    ld a, [hl]
    sub $5c
    jp nz, FollowPath_B7_hasLeadSep

    jr FollowPath_B7_clearSclust

FollowPath_B7_hasLeadSep::
    jp FollowPath_B7_copyCdir


FollowPath_B7_clearSclust::
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
    jp FollowPath_B7_checkEmptyPath


FollowPath_B7_copyCdir::
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

FollowPath_B7_checkEmptyPath::
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
    jp nc, FollowPath_B7_segmentLoop

    ld hl, $0000
    push hl
    ld hl, sp+$0f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirSdi_B7
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
    jp FollowPath_B7_epilogue


FollowPath_B7_segmentLoop::
    ld hl, sp+$0f
    ld c, l
    ld b, h
    push bc
    ld hl, sp+$0f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call CreateName_B7
    add sp, $04
    ld c, e
    ld hl, sp+$0a
    ld [hl], c
    xor a
    or [hl]
    jp nz, FollowPath_B7_epilogue

    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirFind_B7
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
    jp z, FollowPath_B7_found

    ld a, [hl]
    sub $04
    jp nz, FollowPath_B7_findFail

    jr FollowPath_B7_noFileLastSeg

FollowPath_B7_findFail::
    jp FollowPath_B7_epilogue


FollowPath_B7_noFileLastSeg::
    ld hl, sp+$07
    ld a, [hl]
    and $20
    jr nz, FollowPath_B7_dotEntry

    jp FollowPath_B7_nonLastNsflag


FollowPath_B7_dotEntry::
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
    jr nz, FollowPath_B7_lastSegOk

    jp FollowPath_B7_segmentLoop


FollowPath_B7_lastSegOk::
    ld hl, sp+$0a
    ld [hl], $00
    jp FollowPath_B7_epilogue


FollowPath_B7_nonLastNsflag::
    ld hl, sp+$07
    ld a, [hl]
    and $04
    jr nz, FollowPath_B7_nsLastOk

    jp FollowPath_B7_deniedNotDir


FollowPath_B7_nsLastOk::
    jp FollowPath_B7_epilogue


FollowPath_B7_deniedNotDir::
    ld hl, sp+$0a
    ld [hl], $05
    jp FollowPath_B7_epilogue


FollowPath_B7_found::
    ld hl, sp+$07
    ld a, [hl]
    and $04
    jr nz, FollowPath_B7_foundLastSeg

    jp FollowPath_B7_checkAttrDir


FollowPath_B7_foundLastSeg::
    jp FollowPath_B7_epilogue


FollowPath_B7_checkAttrDir::
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
    jr nz, FollowPath_B7_isDir

    jp FollowPath_B7_notDir


FollowPath_B7_isDir::
    jp FollowPath_B7_enterSubdir


FollowPath_B7_notDir::
    ld hl, sp+$0a
    ld [hl], $05
    jp FollowPath_B7_epilogue


FollowPath_B7_enterSubdir::
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
    call LdClust_B7
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
    jp FollowPath_B7_segmentLoop


FollowPath_B7_epilogue::
    ld hl, sp+$0a
    ld e, [hl]
    add sp, $0b
    ret


; [ezgb]
; GetLdNumber_B7: same as GetLdNumber_B9 (09:7510). Bank-local FatFs get_ldnumber copy.
; Orphan immediately before Validate_B7; size matches B5/B6 (0xd7).

GetLdNumber_B7::
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
    jp z, GetLdNumber_B7_returnResult

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b

GetLdNumber_B7_scanColon::
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
    jp c, GetLdNumber_B7_afterScan

    ld a, [hl]
    sub $3a
    jp z, GetLdNumber_B7_afterScan

    ld hl, sp+$00
    inc [hl]
    jr nz, GetLdNumber_B7_scanCont

    inc hl
    inc [hl]

GetLdNumber_B7_scanCont::
    jp GetLdNumber_B7_scanColon


GetLdNumber_B7_afterScan::
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $3a
    jp nz, GetLdNumber_B7_noColon

    jr GetLdNumber_B7_parseDigit

GetLdNumber_B7_noColon::
    jp GetLdNumber_B7_defaultVol0


GetLdNumber_B7_parseDigit::
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
    jr nz, GetLdNumber_B7_digitSignExt

    inc hl
    inc [hl]

GetLdNumber_B7_digitSignExt::
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
    jp nc, GetLdNumber_B7_returnVol

    ld hl, sp+$09
    ld a, [hl]
    ld hl, sp+$00
    sub [hl]
    jp nz, GetLdNumber_B7_notSingleDigit

    ld hl, sp+$0a
    ld a, [hl]
    ld hl, sp+$01
    sub [hl]
    jp nz, GetLdNumber_B7_notSingleDigit

    jr GetLdNumber_B7_checkVolRange

GetLdNumber_B7_notSingleDigit::
    jp GetLdNumber_B7_returnVol


GetLdNumber_B7_checkVolRange::
    ld a, c
    sub $01
    ld a, b
    sbc $00
    jp nc, GetLdNumber_B7_returnVol

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

GetLdNumber_B7_returnVol::
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    jp GetLdNumber_B7_epilogue


GetLdNumber_B7_defaultVol0::
    ld hl, sp+$07
    ld [hl], $00
    inc hl
    ld [hl], $00

GetLdNumber_B7_returnResult::
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]

GetLdNumber_B7_epilogue::
    add sp, $0b
    ret


; [ezgb]
; Validate_B7(obj): FatFs validate. Push frame; reject null obj/fs, fs_type==0, or id mismatch → Jump_007_772f E=$09.
; obj->id vs fs->id mismatch → Jump_007_7714→Jump_007_772f; jr_007_7717 DiskStatus&$01 set → jr_007_772f else Jump_007_7734 E=0.
; Jump_007_7736 add sp,$04 ret E.

Validate_B7::
    push af
    push af
    ld hl, sp+$06
    ld a, [hl+]
    or [hl]
    jp z, Validate_B7_invalid

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
    jp z, Validate_B7_invalid

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
    jp z, Validate_B7_invalid

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
    jp nz, Validate_B7_idMismatch

    inc hl
    ld a, [hl]
    sub b
    jp nz, Validate_B7_idMismatch

    jr Validate_B7_diskStatus

Validate_B7_idMismatch::
    jp Validate_B7_invalid


Validate_B7_diskStatus::
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
    jr nz, Validate_B7_invalid

    jp Validate_B7_ok


Validate_B7_invalid::
    ld e, $09
    jp Validate_B7_epilogue


Validate_B7_ok::
    ld e, $00

Validate_B7_epilogue::
    add sp, $04
    ret


; [ezgb]
; Write_B7(fp, buff, btw): FatFs f_write (bank-7). Target of FarCall_07_7739.
; Validate_B7 fail → Jump_007_7f0c; else Jump_007_776d: fp->err → Jump_007_7f0c.
; Jump_007_778e: FA_WRITE (jr_007_77a7/Jump_007_77af) else Jump_007_77aa E=$07; init remain/btw/fptr/fsize.
; Jump_007_781a setup win/buff ptrs; Jump_007_7865: btw==0 → Jump_007_7eac else win dirty jr_007_788d → Jump_007_7d81 else Jump_007_7890.
; Jump_007_7890: U32Shr cluster/sect; clust==0 CreateChain_B7 (Jump_007_7952 extend else Jump_007_7995); clust err Jump_007_79bc/jr_007_79bf E=$02 or Jump_007_79cc/Jump_007_79e7/jr_007_79ea E=$01; store clust Jump_007_79f7/Jump_007_7a3e.
; Jump_007_7a3e: FA_DIRTY jr_007_7a4c FarCallDiskWrite flush else Jump_007_7aab clear FA_DIRTY → Jump_007_7ab9 Clust2Sect_B7 (fail E=$02); Jump_007_7b0a partial sector Jump_007_7b97 FarCallDiskWrite else Jump_007_7ca9 same-sect Jump_007_7cdf/Jump_007_7d6c.
; Jump_007_7bd7: U32Shl + MemCpy16_B7 into win; Jump_007_7c97 → Jump_007_7e0d; Jump_007_7cdf winsect mismatch jr_007_7d36 FarCallDiskRead else Jump_007_7d6c; Jump_007_7d81 win copy path Jump_007_7dbe MemCpy16_B7 set FA_DIRTY.
; Jump_007_7e0d advance buff/fptr; loop Jump_007_7865; Jump_007_7eac grow fsize (Jump_007_7efc FA_MODIFIED); Jump_007_7f0c epilogue (add sp,$35 / ret).

Write_B7::
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
    call Validate_B7
    add sp, $02
    ld c, e
    xor a
    or c
    jp z, Write_B7_afterValidate

    ld e, c
    jp Write_B7_epilogue


Write_B7_afterValidate::
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
    jp z, Write_B7_checkFaWrite

    ld e, c
    jp Write_B7_epilogue


Write_B7_checkFaWrite::
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
    jr nz, Write_B7_hasWriteMode

    jp Write_B7_denied


Write_B7_hasWriteMode::
    jp Write_B7_initRemain


Write_B7_denied::
    ld e, $07
    jp Write_B7_epilogue


Write_B7_initRemain::
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
    jp nc, Write_B7_setupPtrs

    ld hl, sp+$3f
    ld [hl], $00
    inc hl
    ld [hl], $00

Write_B7_setupPtrs::
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

Write_B7_mainLoop::
    ld hl, sp+$3f
    ld a, [hl+]
    or [hl]
    jp z, Write_B7_growFsize

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
    jr nz, Write_B7_winDirtyPath

    inc hl
    ld a, [hl]
    and $01
    jr nz, Write_B7_winDirtyPath

    jp Write_B7_calcCluster


Write_B7_winDirtyPath::
    jp Write_B7_winCopyPath


Write_B7_calcCluster::
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
    jp nz, Write_B7_maybeFlush

    ld hl, sp+$0c
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Write_B7_extendChain

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
    jp nz, Write_B7_afterCreateChain

    ld hl, $0000
    push hl
    ld hl, $0000
    push hl
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call CreateChain_B7
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
    jp Write_B7_afterCreateChain


Write_B7_extendChain::
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
    call CreateChain_B7
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

Write_B7_afterCreateChain::
    ld hl, sp+$31
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, Write_B7_growFsize

    ld hl, sp+$31
    ld a, [hl]
    sub $01
    jp nz, Write_B7_afterChainOkCheck

    inc hl
    ld a, [hl]
    or a
    jp nz, Write_B7_afterChainOkCheck

    inc hl
    ld a, [hl]
    or a
    jp nz, Write_B7_afterChainOkCheck

    inc hl
    ld a, [hl]
    or a
    jp nz, Write_B7_afterChainOkCheck

    jr Write_B7_chainDiskErr

Write_B7_afterChainOkCheck::
    jp Write_B7_checkChainClust


Write_B7_chainDiskErr::
    ld hl, sp+$22
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $02
    ld [de], a
    ld e, $02
    jp Write_B7_epilogue


Write_B7_checkChainClust::
    ld hl, sp+$31
    ld a, [hl]
    inc a
    jp nz, Write_B7_chainClustOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, Write_B7_chainClustOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, Write_B7_chainClustOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, Write_B7_chainClustOk

    jr Write_B7_chainAborted

Write_B7_chainClustOk::
    jp Write_B7_storeClust


Write_B7_chainAborted::
    ld hl, sp+$22
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    ld e, $01
    jp Write_B7_epilogue


Write_B7_storeClust::
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
    jp nz, Write_B7_maybeFlush

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

Write_B7_maybeFlush::
    ld hl, sp+$20
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $40
    jr nz, Write_B7_flushDirty

    jp Write_B7_clust2Sect


Write_B7_flushDirty::
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
    call FarCallDiskWrite
    add sp, $09
    ld c, e
    xor a
    or c
    jp z, Write_B7_clearDirty

    ld hl, sp+$22
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    ld e, $01
    jp Write_B7_epilogue


Write_B7_clearDirty::
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

Write_B7_clust2Sect::
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
    jp nz, Write_B7_partialSector

    ld hl, sp+$22
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $02
    ld [de], a
    ld e, $02
    jp Write_B7_epilogue


Write_B7_partialSector::
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
    jp z, Write_B7_sameSectPath

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
    jp nc, Write_B7_directWrite

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

Write_B7_directWrite::
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
    call FarCallDiskWrite
    add sp, $09
    ld c, e
    xor a
    or c
    jp z, Write_B7_copyIntoWin

    ld hl, sp+$22
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    ld e, $01
    jp Write_B7_epilogue


Write_B7_copyIntoWin::
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
    jp nc, Write_B7_afterWinCopy

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

Write_B7_afterWinCopy::
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
    jp Write_B7_advance


Write_B7_sameSectPath::
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
    jp nz, Write_B7_checkWinsect

    ld hl, sp+$01
    ld a, [hl]
    ld hl, sp+$2e
    sub [hl]
    jp nz, Write_B7_checkWinsect

    ld hl, sp+$02
    ld a, [hl]
    ld hl, sp+$2f
    sub [hl]
    jp nz, Write_B7_checkWinsect

    ld hl, sp+$03
    ld a, [hl]
    ld hl, sp+$30
    sub [hl]
    jp z, Write_B7_afterWinReady

Write_B7_checkWinsect::
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
    jp nc, Write_B7_afterWinReady

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
    jr nz, Write_B7_diskRead

    inc hl
    inc [hl]

Write_B7_diskRead::
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
    call FarCallDiskRead
    add sp, $09
    ld c, e
    xor a
    or c
    jp z, Write_B7_afterWinReady

    ld hl, sp+$22
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    ld e, $01
    jp Write_B7_epilogue


Write_B7_afterWinReady::
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

Write_B7_winCopyPath::
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
    jp nc, Write_B7_memcpySetDirty

    ld hl, sp+$3f
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$2b
    ld [hl+], a
    ld [hl], e

Write_B7_memcpySetDirty::
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

Write_B7_advance::
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
    jp Write_B7_mainLoop


Write_B7_growFsize::
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
    jp nc, Write_B7_setModified

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

Write_B7_setModified::
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

Write_B7_epilogue::
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
