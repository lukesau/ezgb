; Disassembly of "kernel.gb"
; This file was created with:
; mgbdis v3.0 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $009", ROMX[$4000], BANK[$9]

; [ezgb]
; RetStub_B9: Lone ret at bank start (before MemCpy16_B9). FatFs bank callers push 2 words then call; no-op.

RetStub_B9::
    ret


; [ezgb]
; MemCpy16_B9(dst, src, n): FatFs-shaped mem_cpy. Frame -$05; copy words while n≥2.
; Jump_009_401c: n<2 → Jump_009_405a byte tail; else copy word ++ptrs n-=2 → Jump_009_401c.
; Jump_009_405d: byte loop (jr_009_4070 store / jr_009_407c); Jump_009_407f epilogue.

MemCpy16_B9::
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

MemCpy16_B9_wordLoop::
    ld hl, sp+$00
    ld a, [hl]
    sub $02
    jp c, MemCpy16_B9_byteTail

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
    jp MemCpy16_B9_wordLoop


MemCpy16_B9_byteTail::
    ld hl, sp+$00
    ld c, [hl]

MemCpy16_B9_byteLoop::
    ld b, c
    dec c
    xor a
    or b
    jp z, MemCpy16_B9_epilogue

    ld hl, sp+$01
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    dec hl
    inc [hl]
    jr nz, MemCpy16_B9_storeByte

    inc hl
    inc [hl]

MemCpy16_B9_storeByte::
    ld hl, sp+$03
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, MemCpy16_B9_byteNext

    inc hl
    inc [hl]

MemCpy16_B9_byteNext::
    jp MemCpy16_B9_byteLoop


MemCpy16_B9_epilogue::
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
; MemSet16_B9(dst, val, n): FatFs mem_set. Fill n bytes with val.
; Jump_009_4116 loop: n--==0 → Jump_009_413b; *dst++=val (jr_009_4138) → Jump_009_4116.

MemSet16_B9::
    push af
    push af
    ld hl, sp+$06
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$02
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$0a
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e

MemSet16_B9_loop::
    ld hl, sp+$00
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
    ld a, c
    or b
    jp z, MemSet16_B9_epilogue

    ld hl, sp+$08
    ld a, [hl]
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, MemSet16_B9_next

    inc hl
    inc [hl]

MemSet16_B9_next::
    jp MemSet16_B9_loop


MemSet16_B9_epilogue::
    add sp, $04
    ret


; [ezgb]
; MemCmp_B9(a, b, n): memcmp. Frame -$09; returns DE=diff (0 if equal).
; Jump_009_415f loop: n--==0 → Jump_009_41a0; load *a++ (jr_009_4175) vs *b++ (jr_009_4188); diff≠0 exit else Jump_009_415f.

MemCmp_B9::
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

MemCmp_B9_loop::
    ld hl, sp+$02
    ld b, [hl]
    dec [hl]
    xor a
    or b
    jp z, MemCmp_B9_epilogue

    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    dec hl
    inc [hl]
    jr nz, MemCmp_B9_storeA

    inc hl
    inc [hl]

MemCmp_B9_storeA::
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
    jr nz, MemCmp_B9_compare

    inc hl
    inc [hl]

MemCmp_B9_compare::
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
    jp z, MemCmp_B9_loop

MemCmp_B9_epilogue::
    ld hl, sp+$03
    ld e, [hl]
    inc hl
    ld d, [hl]
    add sp, $09
    ret


; [ezgb]
; MemChr_B9(str, ch): FatFs mem_chr / strchr-shaped. Scan NUL-term set for ch; return DE=matched char or 0.
; Jump_009_41b1 loop: *p==0 or match → Jump_009_41d7; else Jump_009_41cd ++p (jr_009_41d4) → Jump_009_41b1.

MemChr_B9::
    push af
    ld hl, sp+$04
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e

MemChr_B9_loop::
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    or a
    jp z, MemChr_B9_epilogue

    ld a, c
    rla
    sbc a
    ld b, a
    ld a, c
    ld hl, sp+$06
    sub [hl]
    jp nz, MemChr_B9_next

    ld a, b
    inc hl
    sub [hl]
    jp z, MemChr_B9_epilogue

MemChr_B9_next::
    ld hl, sp+$00
    inc [hl]
    jr nz, MemChr_B9_nextJr

    inc hl
    inc [hl]

MemChr_B9_nextJr::
    jp MemChr_B9_loop


MemChr_B9_epilogue::
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
; SyncWindow_B9(fs): FatFs sync_window. Frame -$15; wflag==0 → Jump_009_4378; else DiskWrite winsect.
; Write fail → E=$01 Jump_009_4378; else Jump_009_426d clear wflag + mirror to other FAT copies (Jump_009_42f5 loop); Jump_009_4378 epilogue.

SyncWindow_B9::
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
    jp z, SyncWindow_B9_epilogue

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
    jp z, SyncWindow_B9_clearDirty

    ld hl, sp+$10
    ld [hl], $01
    jp SyncWindow_B9_epilogue


SyncWindow_B9_clearDirty::
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
    jp nc, SyncWindow_B9_epilogue

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

SyncWindow_B9_mirrorFat::
    ld hl, sp+$00
    ld a, [hl]
    sub $02
    inc hl
    ld a, [hl]
    sbc $00
    jp c, SyncWindow_B9_epilogue

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
    jp SyncWindow_B9_mirrorFat


SyncWindow_B9_epilogue::
    ld hl, sp+$10
    ld e, [hl]
    add sp, $15
    ret


; [ezgb]
; MoveWindow_B9(fs, sector): FatFs move_window. Frame -$09; sector==winsect → Jump_009_4441.
; Else Jump_009_43cc SyncWindow_B9 + DiskRead into win[]; fail invalidate winsect; Jump_009_442c store winsect; Jump_009_4441 epilogue.

MoveWindow_B9::
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
    jp nz, MoveWindow_B9_reload

    ld hl, sp+$0e
    ld a, [hl]
    ld hl, sp+$01
    sub [hl]
    jp nz, MoveWindow_B9_reload

    ld hl, sp+$0f
    ld a, [hl]
    ld hl, sp+$02
    sub [hl]
    jp nz, MoveWindow_B9_reload

    ld hl, sp+$10
    ld a, [hl]
    ld hl, sp+$03
    sub [hl]
    jp z, MoveWindow_B9_epilogue

MoveWindow_B9_reload::
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call SyncWindow_B9
    add sp, $02
    ld c, e
    ld hl, sp+$08
    ld [hl], c
    xor a
    or [hl]
    jp nz, MoveWindow_B9_epilogue

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
    jp z, MoveWindow_B9_storeWinsect

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

MoveWindow_B9_storeWinsect::
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

MoveWindow_B9_epilogue::
    ld hl, sp+$08
    ld e, [hl]
    add sp, $09
    ret


; [ezgb]
; SyncFs_B9(fs): FatFs sync_fs. Frame -$10; SyncWindow_B9 err → Jump_009_4610.
; fs_type!=FAT32 → Jump_009_446f→Jump_009_45e6; else jr_009_4472: fsi_flag!=1 → Jump_009_448b→Jump_009_45e6 else jr_009_448e build FSInfo in win.
; jr_009_45a7: DiskWrite FSInfo sector; Jump_009_45e6 clear fsi + CTRL_SYNC stand-in; Jump_009_4610 epilogue ret E.

SyncFs_B9::
    add sp, -$10
    ld hl, sp+$12
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call SyncWindow_B9
    add sp, $02
    ld c, e
    xor a
    or c
    jp nz, SyncFs_B9_epilogue

    ld hl, sp+$12
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
    ld b, a
    sub $03
    jp nz, SyncFs_B9_notFat32

    jr SyncFs_B9_checkFsiFlag

SyncFs_B9_notFat32::
    jp SyncFs_B9_ioctlSync


SyncFs_B9_checkFsiFlag::
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
    ld b, a
    sub $01
    jp nz, SyncFs_B9_fsiClean

    jr SyncFs_B9_buildFsInfo

SyncFs_B9_fsiClean::
    jp SyncFs_B9_ioctlSync


SyncFs_B9_buildFsInfo::
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0032
    add hl, de
    ld c, l
    ld b, h
    ld hl, $0200
    push hl
    ld h, $00
    push hl
    push bc
    call MemSet16_B9
    add sp, $06
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
    ld c, l
    ld b, h
    ld hl, sp+$0e
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
    ld e, a
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
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $01ec
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000a
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
    ld e, c
    ld d, b
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
    ld c, l
    ld b, h
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $001e
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    dec hl
    ld [hl+], a
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
    jr nz, SyncFs_B9_diskWrite

    inc hl
    inc [hl]
    jr nz, SyncFs_B9_diskWrite

    inc hl
    inc [hl]
    jr nz, SyncFs_B9_diskWrite

    inc hl
    inc [hl]

SyncFs_B9_diskWrite::
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
    ld hl, sp+$0e
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, [bc]
    ld b, a
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
    push bc
    inc sp
    call FarCallDiskWrite
    add sp, $09
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a

SyncFs_B9_ioctlSync::
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0001
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld e, a
    ld a, [de]
    ld b, a
    ld hl, $0000
    push hl
    ld a, $00
    push af
    inc sp
    push bc
    inc sp
    call ReturnZero
    add sp, $04
    ld b, e
    ld c, b
    xor a
    or c
    jp z, SyncFs_B9_epilogue

    ld c, $01

SyncFs_B9_epilogue::
    ld e, c
    add sp, $10
    ret


; [ezgb]
; Clust2Sect_B9(fs, clst): FatFs clust2sect. clst-=2; if clst>=n_fatent-2 → 0 @Jump_009_4710;
; else Jump_009_4693: sect = clst<<csize + database; Jump_009_4710 epilogue.

Clust2Sect_B9::
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
    jp c, Clust2Sect_B9_inRange

    ld de, $0000
    ld hl, $0000
    jp Clust2Sect_B9_epilogue


Clust2Sect_B9_inRange::
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

Clust2Sect_B9_epilogue::
    add sp, $0a
    ret


; [ezgb]
; GetFat_B9(fs, clst): FatFs get_fat. Frame -$14; returns cluster status (1=int err, -1=disk err).
; clst<2 or ≥n_fatent → Jump_009_4761 val=1; else Jump_009_476d val=-1 + switch fs_type: FAT12 Jump_009_479f / FAT16 Jump_009_491f / FAT32 Jump_009_49f5; else Jump_009_4ae2 val=1.
; Jump_009_479f FAT12: bc=clst+clst/2; MoveWindow; jr_009_483f win byte; 2nd MoveWindow; odd→jr_009_48f8 >>4 else Jump_009_4909; Jump_009_4911 store val.
; Jump_009_491f FAT16 / Jump_009_49f5 FAT32: MoveWindow + ld_word/ld_dword (mask); Jump_009_4aeb epilogue return val.

GetFat_B9::
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
    jp c, GetFat_B9_intErr

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
    jp c, GetFat_B9_switchType

GetFat_B9_intErr::
    ld hl, sp+$08
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    jp GetFat_B9_epilogue


GetFat_B9_switchType::
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
    jp c, GetFat_B9_badType

    ld a, $03
    sub c
    jp c, GetFat_B9_badType

    dec c
    ld e, c
    ld d, $00
    ld hl, $4796
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp GetFat_B9_fat12


    jp GetFat_B9_fat16


    jp GetFat_B9_fat32


GetFat_B9_fat12::
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
    call MoveWindow_B9
    add sp, $06
    ld c, e
    xor a
    or c
    jp nz, GetFat_B9_epilogue

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
    jr nz, GetFat_B9_fat12WinOff

    inc hl
    inc [hl]

GetFat_B9_fat12WinOff::
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
    call MoveWindow_B9
    add sp, $06
    ld c, e
    xor a
    or c
    jp nz, GetFat_B9_epilogue

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
    jr nz, GetFat_B9_fat12Odd

    jp GetFat_B9_fat12Even


GetFat_B9_fat12Odd::
    ld hl, sp+$12
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, $04

GetFat_B9_fat12Shr4::
    srl b
    rr c
    dec a
    jr nz, GetFat_B9_fat12Shr4

    jp GetFat_B9_storeVal


GetFat_B9_fat12Even::
    ld hl, sp+$12
    ld c, [hl]
    inc hl
    ld a, [hl]
    and $0f
    ld b, a

GetFat_B9_storeVal::
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp GetFat_B9_epilogue


GetFat_B9_fat16::
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
    call MoveWindow_B9
    add sp, $06
    ld c, e
    xor a
    or c
    jp nz, GetFat_B9_epilogue

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
    jp GetFat_B9_epilogue


GetFat_B9_fat32::
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
    call MoveWindow_B9
    add sp, $06
    ld c, e
    xor a
    or c
    jp nz, GetFat_B9_epilogue

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
    jp GetFat_B9_epilogue


GetFat_B9_badType::
    ld hl, sp+$08
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

GetFat_B9_epilogue::
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


; [ezgb]
; PutFat_B9(fs, clst, val): FatFs put_fat. Frame -$19; E=FRESULT (sp+$14).
; clst<2 or ≥n_fatent → Jump_009_4b45 E=$02; else Jump_009_4b4c switch fs_type: FAT12 Jump_009_4b72 / FAT16 Jump_009_4d82 / FAT32 Jump_009_4e64; else Jump_009_4f8a E=$02.
; Jump_009_4b72 FAT12: bc=clst+clst/2; MoveWindow; jr_009_4c16 win off; odd/even → Jump_009_4c63/Jump_009_4c66 store 1st byte + wflag; 2nd MoveWindow Jump_009_4d33/Jump_009_4d6a store 2nd.
; Jump_009_4d82 FAT16 st_word / Jump_009_4e64 FAT32 st_dword (mask); Jump_009_4f8e epilogue ret E.

PutFat_B9::
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
    jp c, PutFat_B9_intErr

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
    jp c, PutFat_B9_switchType

PutFat_B9_intErr::
    ld hl, sp+$14
    ld [hl], $02
    jp PutFat_B9_epilogue


PutFat_B9_switchType::
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    sub $01
    jp c, PutFat_B9_badType

    ld a, $03
    sub b
    jp c, PutFat_B9_badType

    dec b
    ld e, b
    ld d, $00
    ld hl, $4b69
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp PutFat_B9_fat12


    jp PutFat_B9_fat16


    jp PutFat_B9_fat32


PutFat_B9_fat12::
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
    call MoveWindow_B9
    add sp, $06
    ld b, e
    ld hl, sp+$14
    ld [hl], b
    xor a
    or [hl]
    jp nz, PutFat_B9_epilogue

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
    jr nz, PutFat_B9_fat12WinOff

    inc hl
    inc [hl]

PutFat_B9_fat12WinOff::
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
    jp z, PutFat_B9_fat12EvenFirst

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
    jp PutFat_B9_fat12StoreFirst


PutFat_B9_fat12EvenFirst::
    ld hl, sp+$21
    ld b, [hl]

PutFat_B9_fat12StoreFirst::
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
    call MoveWindow_B9
    add sp, $06
    ld b, e
    ld hl, sp+$14
    ld [hl], b
    xor a
    or [hl]
    jp nz, PutFat_B9_epilogue

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
    jp z, PutFat_B9_fat12Second

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
    jp PutFat_B9_fat12StoreSecond


PutFat_B9_fat12Second::
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

PutFat_B9_fat12StoreSecond::
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
    jp PutFat_B9_epilogue


PutFat_B9_fat16::
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
    call MoveWindow_B9
    add sp, $06
    ld c, e
    ld hl, sp+$14
    ld [hl], c
    xor a
    or [hl]
    jp nz, PutFat_B9_epilogue

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
    jp PutFat_B9_epilogue


PutFat_B9_fat32::
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
    call MoveWindow_B9
    add sp, $06
    ld c, e
    ld hl, sp+$14
    ld [hl], c
    xor a
    or [hl]
    jp nz, PutFat_B9_epilogue

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
    jp PutFat_B9_epilogue


PutFat_B9_badType::
    ld hl, sp+$14
    ld [hl], $02

PutFat_B9_epilogue::
    ld hl, sp+$14
    ld e, [hl]
    add sp, $19
    ret


; [ezgb]
; RemoveChain_B9(fs, clst, pclst): FatFs remove_chain. Frame -$0e; walk FAT from fs+clst toward clst.
; clst<2 → Jump_009_4fe5 B=$02; start cluster > clst → Jump_009_4fea B=$00 else Jump_009_4fe5.
; Jump_009_4fec loop: walker≥clst → Jump_009_5135 ret B; GetFat_B9; FAT zero → Jump_009_5135.
; FAT==1 → jr_009_5063 B=$02 else Jump_009_5060→Jump_009_5068; inc FAT wraps → jr_009_5086 B=$01 else Jump_009_5083→Jump_009_508b.
; Jump_009_508b: PutFat_B9 free slot; err → Jump_009_5135; advance walker - inc hits 0 → Jump_009_5121 else Jump_009_50e6 (jr_009_50f5) + FA_DIRTY → Jump_009_4fec.
; Jump_009_5121: stash final cluster@sp+$12 → Jump_009_4fec; Jump_009_5135: ld e,B / add sp,$0e / ret.

RemoveChain_B9::
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
    jp c, RemoveChain_B9_intErr

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
    jp c, RemoveChain_B9_okInit

RemoveChain_B9_intErr::
    ld b, $02
    jp RemoveChain_B9_epilogue


RemoveChain_B9_okInit::
    ld b, $00

RemoveChain_B9_walkLoop::
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
    jp nc, RemoveChain_B9_epilogue

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
    call GetFat_B9
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
    jp z, RemoveChain_B9_epilogue

    ld hl, sp+$0a
    ld a, [hl]
    sub $01
    jp nz, RemoveChain_B9_notIntFat

    inc hl
    ld a, [hl]
    or a
    jp nz, RemoveChain_B9_notIntFat

    inc hl
    ld a, [hl]
    or a
    jp nz, RemoveChain_B9_notIntFat

    inc hl
    ld a, [hl]
    or a
    jp nz, RemoveChain_B9_notIntFat

    jr RemoveChain_B9_fatIntErr

RemoveChain_B9_notIntFat::
    jp RemoveChain_B9_checkDiskErr


RemoveChain_B9_fatIntErr::
    ld b, $02
    jp RemoveChain_B9_epilogue


RemoveChain_B9_checkDiskErr::
    ld hl, sp+$0a
    ld a, [hl]
    inc a
    jp nz, RemoveChain_B9_notDiskErr

    inc hl
    ld a, [hl]
    inc a
    jp nz, RemoveChain_B9_notDiskErr

    inc hl
    ld a, [hl]
    inc a
    jp nz, RemoveChain_B9_notDiskErr

    inc hl
    ld a, [hl]
    inc a
    jp nz, RemoveChain_B9_notDiskErr

    jr RemoveChain_B9_diskErr

RemoveChain_B9_notDiskErr::
    jp RemoveChain_B9_putFatFree


RemoveChain_B9_diskErr::
    ld b, $01
    jp RemoveChain_B9_epilogue


RemoveChain_B9_putFatFree::
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
    call PutFat_B9
    add sp, $0a
    ld c, e
    ld b, c
    xor a
    or b
    jp nz, RemoveChain_B9_epilogue

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
    jp nz, RemoveChain_B9_decFreeClst

    inc hl
    ld a, [hl]
    inc a
    jp nz, RemoveChain_B9_decFreeClst

    inc hl
    ld a, [hl]
    inc a
    jp nz, RemoveChain_B9_decFreeClst

    inc hl
    ld a, [hl]
    inc a
    jp z, RemoveChain_B9_stashFinal

RemoveChain_B9_decFreeClst::
    ld hl, sp+$02
    inc [hl]
    jr nz, RemoveChain_B9_setDirty

    inc hl
    inc [hl]
    jr nz, RemoveChain_B9_setDirty

    inc hl
    inc [hl]
    jr nz, RemoveChain_B9_setDirty

    inc hl
    inc [hl]

RemoveChain_B9_setDirty::
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

RemoveChain_B9_stashFinal::
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
    jp RemoveChain_B9_walkLoop


RemoveChain_B9_epilogue::
    ld e, b
    add sp, $0e
    ret


; [ezgb]
; CreateChain_B9(fs, clst, target): FatFs create_chain / cluster extend.
; clst!=0 Jump_009_51af GetFat_B9: clst<2 → Jump_009_54d8 (1,0); Jump_009_51ee: clst==-1 jr_009_520c else Jump_009_5209/Jump_009_5218 compare n_fatent (past Jump_009_5255 else Jump_009_54d8).
; clst==0: free_clst vs n_fatent; empty Jump_009_51a3 clst=1; join Jump_009_5266 copy state.
; Jump_009_5266 alloc scan Jump_009_52a0 (jr_009_52af): hit end Jump_009_52ee GetFat_B9; no free + scan done → Jump_009_54d8 (0,0).
; Jump_009_5347/Jump_009_5363/Jump_009_5366/jr_009_5366 EOF checks; Jump_009_5372 match jr_009_539b (0,0) else Jump_009_5398 → Jump_009_52a0.
; Jump_009_52ee free slot Jump_009_53a4 PutFat_B9 link; fail Jump_009_549a/Jump_009_54a2/jr_009_54a5/Jump_009_54b5 set FR_NO_FILESYSTEM.
; Jump_009_53f9: update fs free_clst/fatbase; Jump_009_544e link + FA_DIRTY or Jump_009_54cf; Jump_009_54be store; Jump_009_54d8 epilogue (add sp,$1b / ret).

CreateChain_B9::
    add sp, -$1b
    ld hl, sp+$1f
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, CreateChain_B9_getFatExisting

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
    jp z, CreateChain_B9_clstEmptySet1

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
    jp c, CreateChain_B9_copyScanState

CreateChain_B9_clstEmptySet1::
    ld hl, sp+$0f
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    jp CreateChain_B9_copyScanState


CreateChain_B9_getFatExisting::
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
    call GetFat_B9
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
    jp nc, CreateChain_B9_afterGetFat

    ld de, $0001
    ld hl, $0000
    jp CreateChain_B9_epilogue


CreateChain_B9_afterGetFat::
    ld hl, sp+$17
    ld a, [hl]
    inc a
    jp nz, CreateChain_B9_notEofCluster

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B9_notEofCluster

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B9_notEofCluster

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B9_notEofCluster

    jr CreateChain_B9_eofCluster

CreateChain_B9_notEofCluster::
    jp CreateChain_B9_cmpNFatent


CreateChain_B9_eofCluster::
    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp CreateChain_B9_epilogue


CreateChain_B9_cmpNFatent::
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
    jp nc, CreateChain_B9_stretchOk

    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp CreateChain_B9_epilogue


CreateChain_B9_stretchOk::
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

CreateChain_B9_copyScanState::
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

CreateChain_B9_allocScan::
    ld hl, sp+$13
    inc [hl]
    jr nz, CreateChain_B9_allocScanCont

    inc hl
    inc [hl]
    jr nz, CreateChain_B9_allocScanCont

    inc hl
    inc [hl]
    jr nz, CreateChain_B9_allocScanCont

    inc hl
    inc [hl]

CreateChain_B9_allocScanCont::
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
    jp c, CreateChain_B9_scanHitEnd

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
    jp z, CreateChain_B9_scanHitEnd

    ld de, $0000
    ld hl, $0000
    jp CreateChain_B9_epilogue


CreateChain_B9_scanHitEnd::
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
    call GetFat_B9
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
    jp z, CreateChain_B9_putFatLink

    ld hl, sp+$17
    ld a, [hl]
    inc a
    jp nz, CreateChain_B9_eofCheck

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B9_eofCheck

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B9_eofCheck

    inc hl
    ld a, [hl]
    inc a
    jp z, CreateChain_B9_eofCheckVal

CreateChain_B9_eofCheck::
    ld hl, sp+$17
    ld a, [hl]
    sub $01
    jp nz, CreateChain_B9_eofCheckCont

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateChain_B9_eofCheckCont

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateChain_B9_eofCheckCont

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateChain_B9_eofCheckCont

    jr CreateChain_B9_eofCheckVal

CreateChain_B9_eofCheckCont::
    jp CreateChain_B9_matchScanStart


CreateChain_B9_eofCheckVal::
    ld hl, sp+$17
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp CreateChain_B9_epilogue


CreateChain_B9_matchScanStart::
    ld hl, sp+$13
    ld a, [hl]
    ld hl, sp+$0f
    sub [hl]
    jp nz, CreateChain_B9_scanContinue

    ld hl, sp+$14
    ld a, [hl]
    ld hl, sp+$10
    sub [hl]
    jp nz, CreateChain_B9_scanContinue

    ld hl, sp+$15
    ld a, [hl]
    ld hl, sp+$11
    sub [hl]
    jp nz, CreateChain_B9_scanContinue

    ld hl, sp+$16
    ld a, [hl]
    ld hl, sp+$12
    sub [hl]
    jp nz, CreateChain_B9_scanContinue

    jr CreateChain_B9_noFreeRet0

CreateChain_B9_scanContinue::
    jp CreateChain_B9_allocScan


CreateChain_B9_noFreeRet0::
    ld de, $0000
    ld hl, $0000
    jp CreateChain_B9_epilogue


CreateChain_B9_putFatLink::
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
    call PutFat_B9
    add sp, $0a
    ld c, e
    xor a
    or c
    jp nz, CreateChain_B9_updateFreeClst

    ld hl, sp+$1f
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, CreateChain_B9_updateFreeClst

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
    call PutFat_B9
    add sp, $0a
    ld b, e
    ld c, b

CreateChain_B9_updateFreeClst::
    xor a
    or c
    jp nz, CreateChain_B9_putFatFail

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
    jp nz, CreateChain_B9_linkAndDirty

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B9_linkAndDirty

    inc hl
    ld a, [hl]
    inc a
    jp nz, CreateChain_B9_linkAndDirty

    inc hl
    ld a, [hl]
    inc a
    jp z, CreateChain_B9_newChainOnly

CreateChain_B9_linkAndDirty::
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
    jp CreateChain_B9_newChainOnly


CreateChain_B9_putFatFail::
    ld a, c
    sub $01
    jp nz, CreateChain_B9_putFatFailCont

    jr CreateChain_B9_diskErrorRet

CreateChain_B9_putFatFailCont::
    jp CreateChain_B9_setFrNoFilesystem


CreateChain_B9_diskErrorRet::
    ld hl, sp+$00
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    jp CreateChain_B9_storeResult


CreateChain_B9_setFrNoFilesystem::
    ld hl, sp+$00
    ld [hl], $01
    xor a
    inc hl
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

CreateChain_B9_storeResult::
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

CreateChain_B9_newChainOnly::
    ld hl, sp+$13
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a

CreateChain_B9_epilogue::
    add sp, $1b
    ret


; [ezgb]
; DirSdi_B9(dp, ofs): FatFs dir_sdi. Frame -$16; store ofs→dptr@dp+$04; load sclust@dp+$06.
; sclust==1 → Jump_009_5568 E=$02 (FR_INT_ERR); else Jump_009_552d load fs + compare vs n_fatent/MAX → Jump_009_556d else Jump_009_5568.
; Jump_009_556d: sclust==0 → fs_type==3 jr_009_558e replace dirbase else Jump_009_558b→Jump_009_55be; nonzero → Jump_009_55be.
; Jump_009_55be: clst!=0 → Jump_009_5607 dynamic; else static root: ofs≥n_rootdir → E=$02 else Jump_009_55ea sect=dirbase → Jump_009_572c.
; Jump_009_5607: csize→csz (jr_009_561b/jr_009_5622 <<5); Jump_009_5625: ofs<csz → Jump_009_56f4 else GetFat_B9.
; GetFat==-1 → jr_009_568a E=$01 (FR_DISK_ERR); else Jump_009_5687→Jump_009_568f: clst<2 → Jump_009_56d9 E=$02; past n_fatent → Jump_009_56d9 else Jump_009_56de ofs-=csz → Jump_009_5625.
; Jump_009_56f4: Clust2Sect_B9; Jump_009_572c store clust; Jump_009_5759 sect+=ofs/SS + dir win ptr (jr_009_576f ÷SS); Jump_009_5809 epilogue (add sp,$16 / ret E).

DirSdi_B9::
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
    jp nz, DirSdi_B9_rangeCheck

    inc hl
    ld a, [hl]
    or a
    jp nz, DirSdi_B9_rangeCheck

    inc hl
    ld a, [hl]
    or a
    jp nz, DirSdi_B9_rangeCheck

    inc hl
    ld a, [hl]
    or a
    jp z, DirSdi_B9_intErr

DirSdi_B9_rangeCheck::
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
    jp c, DirSdi_B9_afterRange

DirSdi_B9_intErr::
    ld e, $02
    jp DirSdi_B9_epilogue


DirSdi_B9_afterRange::
    ld hl, sp+$12
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, DirSdi_B9_staticOrDyn

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
    jp nz, DirSdi_B9_notFat32Root

    jr DirSdi_B9_fat32RootBase

DirSdi_B9_notFat32Root::
    jp DirSdi_B9_staticOrDyn


DirSdi_B9_fat32RootBase::
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

DirSdi_B9_staticOrDyn::
    ld hl, sp+$12
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, DirSdi_B9_dynCsize

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
    jp c, DirSdi_B9_staticSect

    ld e, $02
    jp DirSdi_B9_epilogue


DirSdi_B9_staticSect::
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
    jp DirSdi_B9_storeClust


DirSdi_B9_dynCsize::
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
    jr DirSdi_B9_csizeShiftLoop

DirSdi_B9_csizeShift::
    ld hl, sp+$0c
    sla [hl]
    inc hl
    rl [hl]

DirSdi_B9_csizeShiftLoop::
    dec a
    jr nz, DirSdi_B9_csizeShift

DirSdi_B9_followLoop::
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
    jp c, DirSdi_B9_clust2Sect

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
    call GetFat_B9
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
    jp nz, DirSdi_B9_afterGetFat

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirSdi_B9_afterGetFat

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirSdi_B9_afterGetFat

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirSdi_B9_afterGetFat

    jr DirSdi_B9_diskErr

DirSdi_B9_afterGetFat::
    jp DirSdi_B9_checkClust


DirSdi_B9_diskErr::
    ld e, $01
    jp DirSdi_B9_epilogue


DirSdi_B9_checkClust::
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
    jp c, DirSdi_B9_clustIntErr

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
    jp c, DirSdi_B9_subCsz

DirSdi_B9_clustIntErr::
    ld e, $02
    jp DirSdi_B9_epilogue


DirSdi_B9_subCsz::
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
    jp DirSdi_B9_followLoop


DirSdi_B9_clust2Sect::
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
    call Clust2Sect_B9
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

DirSdi_B9_storeClust::
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
    jp nz, DirSdi_B9_setSectDir

    ld e, $02
    jp DirSdi_B9_epilogue


DirSdi_B9_setSectDir::
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

DirSdi_B9_sectDiv::
    srl b
    rr c
    dec a
    jr nz, DirSdi_B9_sectDiv

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

DirSdi_B9_epilogue::
    add sp, $16
    ret


; [ezgb]
; DirNext_B9(dp, stretch): FatFs dir_next. Frame -$22; ++dp->dptr index; walk dir sectors/clusters.
; Index+1==0 → Jump_009_5862 E=$04 (FR_NO_FILE); load dir entry@dp+$0e - four dwords zero → Jump_009_5862.
; Jump_009_5867: index&$0f≠0 → Jump_009_5c2f in-sector advance; else inc sector (jr_009_5885 carry chain) + copy 32-byte slot.
; Next cluster from dp chain zero → Jump_009_58e6 stretch path; volsize compare fail → Jump_009_5c2f else E=$04 → Jump_009_5c8c.
; Jump_009_58e6: sector→cluster via jr_009_58f4 ÷16; fs-type mask vs cluster → nz Jump_009_5c2f; GetFat_B9.
; Cluster−1 underflow → Jump_009_595c: inc cluster words - all zero jr_009_597a E=$01 else Jump_009_5977→Jump_009_597f.
; Jump_009_597f: cluster<saved → Jump_009_5bde; stretch==0 → E=$04 Jump_009_5c8c else Jump_009_59c6 CreateChain_B9.
; CreateChain result zero → E=$07 Jump_009_5c8c; else Jump_009_5a19 cluster−1 all zero → jr_009_5a38 E=$02 else Jump_009_5a35→Jump_009_5a3d.
; Jump_009_5a3d: inc cluster words - all wrap jr_009_5a5b E=$01 else Jump_009_5a58→Jump_009_5a60 SyncWindow_B9.
; Jump_009_5a60: SyncWindow_B9 err→E=$01 Jump_009_5c8c else Jump_009_5a7b MemSet8 dir buf + Clust2Sect → Jump_009_5aec sector loop.
; Jump_009_5aec: offset≥ssize → Jump_009_5b81 else dirty+SyncWindow; err E=$01; Jump_009_5b2f stamp template (jr_009_5b5d/jr_009_5b76) → Jump_009_5aec.
; Jump_009_5b81: partial tail copy + sector base for index; Jump_009_5bde store cluster + Clust2Sect → window sector.
; Jump_009_5c2f: write index@dp+$04, ptr@dp+$12+idx*32, E=0; Jump_009_5c8c add sp,$22 ret E.

DirNext_B9::
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
    jp z, DirNext_B9_noFile

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
    jp nz, DirNext_B9_checkInSector

DirNext_B9_noFile::
    ld e, $04
    jp DirNext_B9_epilogue


DirNext_B9_checkInSector::
    ld hl, sp+$1c
    ld a, [hl]
    and $0f
    ld hl, sp+$10
    ld [hl+], a
    ld [hl], $00
    dec hl
    ld a, [hl+]
    or [hl]
    jp nz, DirNext_B9_advanceOk

    inc hl
    inc [hl]
    jr nz, DirNext_B9_incSector

    inc hl
    inc [hl]
    jr nz, DirNext_B9_incSector

    inc hl
    inc [hl]
    jr nz, DirNext_B9_incSector

    inc hl
    inc [hl]

DirNext_B9_incSector::
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
    jp nz, DirNext_B9_stretchPath

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
    jp c, DirNext_B9_advanceOk

    ld e, $04
    jp DirNext_B9_epilogue


DirNext_B9_stretchPath::
    ld hl, sp+$1c
    ld a, [hl]
    ld hl, sp+$08
    ld [hl], a
    ld hl, sp+$1d
    ld a, [hl]
    ld hl, sp+$09
    ld [hl], a
    ld a, $04

DirNext_B9_sectToClust::
    ld hl, sp+$09
    srl [hl]
    dec hl
    rr [hl]
    dec a
    jr nz, DirNext_B9_sectToClust

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
    jp nz, DirNext_B9_advanceOk

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
    call GetFat_B9
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
    jp c, DirNext_B9_clustUnderflow

    ld e, $02
    jp DirNext_B9_epilogue


DirNext_B9_clustUnderflow::
    ld hl, sp+$1e
    ld a, [hl]
    inc a
    jp nz, DirNext_B9_clustIncOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirNext_B9_clustIncOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirNext_B9_clustIncOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirNext_B9_clustIncOk

    jr DirNext_B9_intErr

DirNext_B9_clustIncOk::
    jp DirNext_B9_afterClustInc


DirNext_B9_intErr::
    ld e, $01
    jp DirNext_B9_epilogue


DirNext_B9_afterClustInc::
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
    jp c, DirNext_B9_storeClust

    ld hl, sp+$26
    ld a, [hl+]
    or [hl]
    jp nz, DirNext_B9_createChain

    ld e, $04
    jp DirNext_B9_epilogue


DirNext_B9_createChain::
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
    call CreateChain_B9
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
    jp nz, DirNext_B9_afterCreateChain

    ld e, $07
    jp DirNext_B9_epilogue


DirNext_B9_afterCreateChain::
    ld hl, sp+$1e
    ld a, [hl]
    sub $01
    jp nz, DirNext_B9_newClustOk

    inc hl
    ld a, [hl]
    or a
    jp nz, DirNext_B9_newClustOk

    inc hl
    ld a, [hl]
    or a
    jp nz, DirNext_B9_newClustOk

    inc hl
    ld a, [hl]
    or a
    jp nz, DirNext_B9_newClustOk

    jr DirNext_B9_diskErr

DirNext_B9_newClustOk::
    jp DirNext_B9_incNewClust


DirNext_B9_diskErr::
    ld e, $02
    jp DirNext_B9_epilogue


DirNext_B9_incNewClust::
    ld hl, sp+$1e
    ld a, [hl]
    inc a
    jp nz, DirNext_B9_newClustWrapOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirNext_B9_newClustWrapOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirNext_B9_newClustWrapOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, DirNext_B9_newClustWrapOk

    jr DirNext_B9_syncIntErr

DirNext_B9_newClustWrapOk::
    jp DirNext_B9_syncWindow


DirNext_B9_syncIntErr::
    ld e, $01
    jp DirNext_B9_epilogue


DirNext_B9_syncWindow::
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
    call SyncWindow_B9
    add sp, $02
    ld c, e
    xor a
    or c
    jp z, DirNext_B9_clearDirBuf

    ld e, $01
    jp DirNext_B9_epilogue


DirNext_B9_clearDirBuf::
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
    ld hl, $0200
    push hl
    ld h, $00
    push hl
    push bc
    call MemSet16_B9
    add sp, $06
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
    call Clust2Sect_B9
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

DirNext_B9_sectorLoop::
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
    jp nc, DirNext_B9_partialTail

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
    call SyncWindow_B9
    add sp, $02
    ld c, e
    xor a
    or c
    jp z, DirNext_B9_stampTemplate

    ld e, $01
    jp DirNext_B9_epilogue


DirNext_B9_stampTemplate::
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
    jr nz, DirNext_B9_stampCont

    inc hl
    inc [hl]
    jr nz, DirNext_B9_stampCont

    inc hl
    inc [hl]
    jr nz, DirNext_B9_stampCont

    inc hl
    inc [hl]

DirNext_B9_stampCont::
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
    jr nz, DirNext_B9_stampNext

    inc hl
    inc [hl]

DirNext_B9_stampNext::
    ld hl, sp+$1a
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], e
    jp DirNext_B9_sectorLoop


DirNext_B9_partialTail::
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

DirNext_B9_storeClust::
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
    call Clust2Sect_B9
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

DirNext_B9_advanceOk::
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

DirNext_B9_epilogue::
    add sp, $22
    ret


; [ezgb]
; DirAlloc_B9(dp): FatFs dir_alloc. Frame -$0b; scan for free dir slot via DirSdi_B9(0) + DirNext_B9(1).
; DirSdi err → Jump_009_5d5b; Jump_009_5cc6: load cluster@dp+$0e, MoveWindow_B9 err → Jump_009_5d5b.
; SFN[0] DDEM $E5 or empty → Jump_009_5d1b else Jump_009_5d3c reset run counter → Jump_009_5d43 DirNext_B9(1).
; Jump_009_5d1b: ++free-run (jr_009_5d22); run==n_dir → jr_009_5d39→Jump_009_5d5b else Jump_009_5d36→Jump_009_5d43.
; DirNext ok → Jump_009_5cc6; Jump_009_5d5b: E==$04 → jr_009_5d68 E=$07 else Jump_009_5d65→Jump_009_5d6c ret E.

DirAlloc_B9::
    add sp, -$0b
    ld hl, $0000
    push hl
    ld hl, sp+$0f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirSdi_B9
    add sp, $04
    ld c, e
    ld hl, sp+$0a
    ld [hl], c
    xor a
    or [hl]
    jp nz, DirAlloc_B9_done

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

DirAlloc_B9_scanLoop::
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
    call MoveWindow_B9
    add sp, $06
    ld b, e
    ld hl, sp+$0a
    ld [hl], b
    xor a
    or [hl]
    jp nz, DirAlloc_B9_done

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
    jp z, DirAlloc_B9_incFreeRun

    xor a
    or c
    jp nz, DirAlloc_B9_resetRun

DirAlloc_B9_incFreeRun::
    ld hl, sp+$08
    inc [hl]
    jr nz, DirAlloc_B9_checkRunLen

    inc hl
    inc [hl]

DirAlloc_B9_checkRunLen::
    ld hl, sp+$08
    ld a, [hl]
    ld hl, sp+$0f
    sub [hl]
    jp nz, DirAlloc_B9_needMore

    ld hl, sp+$09
    ld a, [hl]
    ld hl, sp+$10
    sub [hl]
    jp nz, DirAlloc_B9_needMore

    jr DirAlloc_B9_runComplete

DirAlloc_B9_needMore::
    jp DirAlloc_B9_dirNext


DirAlloc_B9_runComplete::
    jp DirAlloc_B9_done


DirAlloc_B9_resetRun::
    ld hl, sp+$08
    ld [hl], $00
    inc hl
    ld [hl], $00

DirAlloc_B9_dirNext::
    ld hl, $0001
    push hl
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirNext_B9
    add sp, $04
    ld c, e
    ld hl, sp+$0a
    ld [hl], c
    xor a
    or [hl]
    jp z, DirAlloc_B9_scanLoop

DirAlloc_B9_done::
    ld hl, sp+$0a
    ld a, [hl]
    sub $04
    jp nz, DirAlloc_B9_keepErr

    jr DirAlloc_B9_denied

DirAlloc_B9_keepErr::
    jp DirAlloc_B9_epilogue


DirAlloc_B9_denied::
    ld hl, sp+$0a
    ld [hl], $07

DirAlloc_B9_epilogue::
    ld hl, sp+$0a
    ld e, [hl]
    add sp, $0b
    ret


; [ezgb]
; LdClust_B9(fs, dir): FatFs ld_clust. Load start cluster from SFN entry (LO@$1A).
; fs_type!=FAT32 → Jump_009_5da1→Jump_009_5dfe; else jr_009_5da4 OR HI@$14<<16; Jump_009_5dfe return cluster.

LdClust_B9::
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
    jp nz, LdClust_B9_notFat32

    jr LdClust_B9_orHiWord

LdClust_B9_notFat32::
    jp LdClust_B9_epilogue


LdClust_B9_orHiWord::
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

LdClust_B9_epilogue::
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


StClust_B9::
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


; [ezgb]
; CmpLfn_B9(lfnbuf, dir): FatFs cmp_lfn. Frame -$0e; returns DE=1 matched / 0 not.
; LDIR_FstClusLO!=0 → DE=0 Jump_009_5fb5; else Jump_009_5e8a: i=((Ord&$3F)-1)*13; wc=1; s=0.
; Jump_009_5ec2 char loop s<13: pick LfnOfs[s] wchar; wc!=0 → overflow/mismatch Jump_009_5f4e else WToUpper compare (jr_009_5f1e) → Jump_009_5f54 store wc; wc==0 filler≠$FFFF → Jump_009_5f6b else Jump_009_5f71 ++s (jr_009_5f78).
; Jump_009_5f7b: last-seg (LLEF) + wc + more LFN → fail (jr_009_5f89); else Jump_009_5fb2 DE=1; Jump_009_5fb5 epilogue.

CmpLfn_B9::
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
    jp z, CmpLfn_B9_initOffset

    ld de, $0000
    jp CmpLfn_B9_epilogue


CmpLfn_B9_initOffset::
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

CmpLfn_B9_charLoop::
    ld hl, sp+$0a
    ld a, [hl]
    sub $0d
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, CmpLfn_B9_checkLastSeg

    ld de, LfnOfs_B9
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
    jp z, CmpLfn_B9_checkFiller

    ld hl, sp+$02
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, CmpLfn_B9_mismatch

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
    jr nz, CmpLfn_B9_compareUpper

    inc hl
    inc [hl]

CmpLfn_B9_compareUpper::
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
    jp nz, CmpLfn_B9_mismatch

    inc hl
    ld a, [hl]
    sub b
    jp z, CmpLfn_B9_storeWc

CmpLfn_B9_mismatch::
    ld de, $0000
    jp CmpLfn_B9_epilogue


CmpLfn_B9_storeWc::
    ld hl, sp+$06
    ld a, [hl+]
    ld e, [hl]
    inc hl
    ld [hl+], a
    ld [hl], e
    jp CmpLfn_B9_nextChar


CmpLfn_B9_checkFiller::
    ld hl, sp+$06
    ld a, [hl]
    inc a
    jp nz, CmpLfn_B9_fillerBad

    inc hl
    ld a, [hl]
    inc a
    jp z, CmpLfn_B9_nextChar

CmpLfn_B9_fillerBad::
    ld de, $0000
    jp CmpLfn_B9_epilogue


CmpLfn_B9_nextChar::
    ld hl, sp+$0a
    inc [hl]
    jr nz, CmpLfn_B9_nextCharJr

    inc hl
    inc [hl]

CmpLfn_B9_nextCharJr::
    jp CmpLfn_B9_charLoop


CmpLfn_B9_checkLastSeg::
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $40
    jr nz, CmpLfn_B9_lastSegLen

    jp CmpLfn_B9_matched


CmpLfn_B9_lastSegLen::
    ld hl, sp+$08
    ld a, [hl+]
    or [hl]
    jp z, CmpLfn_B9_matched

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
    jp z, CmpLfn_B9_matched

    ld de, $0000
    jp CmpLfn_B9_epilogue


CmpLfn_B9_matched::
    ld de, $0001

CmpLfn_B9_epilogue::
    add sp, $0e
    ret


LfnOfs_B9::
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
    db $e3
    db $5f
    db $11
    db $00
    db $00
    db $c3
    db $ed
    db $60

; [ezgb]
; MatchLfnEntry_B9(ord, target, entry): walks 13 LFN chars via LfnOfs_B9, compares against
; target buffer; DE=1 on full match (checkLastFlag $40=LAST_LONG_ENTRY spare-byte cleanup),
; DE=0 on mismatch/sentinel. Shape matches FatFs LFN-entry matching; not textually called
; anywhere in this build (no caller found) - exact ff.c correspondence and caller not
; confirmed, named from its own control flow only. Twin of MatchLfnEntry_B3/B6/B7.

MatchLfnEntry_B9::
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

MatchLfnEntry_B9_charLoop::
    ld hl, sp+$09
    ld a, [hl]
    sub $0d
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, MatchLfnEntry_B9_checkLastFlag

    ld de, LfnOfs_B9
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
    jp z, MatchLfnEntry_B9_checkSentinel

    ld hl, sp+$00
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp c, MatchLfnEntry_B9_advance

    ld de, $0000
    jp MatchLfnEntry_B9_epilogue


MatchLfnEntry_B9_advance::
    ld hl, sp+$00
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, MatchLfnEntry_B9_storeOfs

    inc hl
    inc [hl]

MatchLfnEntry_B9_storeOfs::
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
    jp MatchLfnEntry_B9_nextOrd


MatchLfnEntry_B9_checkSentinel::
    ld hl, sp+$05
    ld a, [hl]
    inc a
    jp nz, MatchLfnEntry_B9_noMatch

    inc hl
    ld a, [hl]
    inc a
    jp z, MatchLfnEntry_B9_nextOrd

MatchLfnEntry_B9_noMatch::
    ld de, $0000
    jp MatchLfnEntry_B9_epilogue


MatchLfnEntry_B9_nextOrd::
    ld hl, sp+$09
    inc [hl]
    jr nz, MatchLfnEntry_B9_loopBack

    inc hl
    inc [hl]

MatchLfnEntry_B9_loopBack::
    jp MatchLfnEntry_B9_charLoop


MatchLfnEntry_B9_checkLastFlag::
    ld hl, sp+$04
    ld a, [hl]
    and $40
    jr nz, MatchLfnEntry_B9_checkSpare

    jp MatchLfnEntry_B9_matched


MatchLfnEntry_B9_checkSpare::
    ld hl, sp+$0b
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp c, MatchLfnEntry_B9_clearSpare

    ld de, $0000
    jp MatchLfnEntry_B9_epilogue


MatchLfnEntry_B9_clearSpare::
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

MatchLfnEntry_B9_matched::
    ld de, $0001

MatchLfnEntry_B9_epilogue::
    add sp, $0d
    ret


; [ezgb]
; PutLfn_B9(lfn, dir, ord, sum): FatFs put_lfn. Set Chksum/AM_LFN/Type0/FstClusLO; i=(ord-1)*13.
; Jump_009_6156 char loop: wc!=$FFFF → Jump_009_6163 load lfn[i++] (jr_009_616e); Jump_009_6186 st_word via LfnOfs; NUL→wc=$FFFF; Jump_009_61b4 ++s (jr_009_61bb) while s<13.
; After 13: more LFN → Jump_009_61d4 else Jump_009_61f0 LLEF; Jump_009_61f6 store LDIR_Ord; ret.

PutLfn_B9::
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

PutLfn_B9_charLoop::
    ld hl, sp+$02
    ld a, [hl]
    inc a
    jp nz, PutLfn_B9_loadWchar

    inc hl
    ld a, [hl]
    inc a
    jp z, PutLfn_B9_storeWchar

PutLfn_B9_loadWchar::
    ld hl, sp+$00
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, PutLfn_B9_indexLfn

    inc hl
    inc [hl]

PutLfn_B9_indexLfn::
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

PutLfn_B9_storeWchar::
    ld de, LfnOfs_B9
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
    jp nz, PutLfn_B9_nextSlot

    dec hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff

PutLfn_B9_nextSlot::
    ld hl, sp+$04
    inc [hl]
    jr nz, PutLfn_B9_checkDone

    inc hl
    inc [hl]

PutLfn_B9_checkDone::
    ld hl, sp+$04
    ld a, [hl]
    sub $0d
    inc hl
    ld a, [hl]
    sbc $00
    jp c, PutLfn_B9_charLoop

    ld hl, sp+$02
    ld a, [hl]
    inc a
    jp nz, PutLfn_B9_moreLfn

    inc hl
    ld a, [hl]
    inc a
    jp z, PutLfn_B9_setLlef

PutLfn_B9_moreLfn::
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
    jp nz, PutLfn_B9_storeOrd

PutLfn_B9_setLlef::
    ld hl, sp+$0c
    ld a, [hl]
    or $40
    ld [hl], a

PutLfn_B9_storeOrd::
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
; GenNumName_B9(dst, src, lfn, seq): FatFs gen_numname. Frame -$1d; MemCpy16_B9 11-byte SFN.
; seq>5 → Jump_009_623b CRC over LFN (poly $11021 via jr_009_62d7 xor); bit loop Jump_009_6263/Jump_009_62e5; done Jump_009_62f8 store hash→seq; else Jump_009_6304.
; Jump_009_6304: ns[8] buf; Jump_009_6313 hex digit (+$30 / +$07 if >'9') Jump_009_632b store + jr_009_634e seq>>=4; '~' at ns[i].
; Jump_009_637c find append offset (space or end jr_009_63a6); Jump_009_63a9/Jump_009_63b0 append loop (jr_009_63bb/jr_009_63dd); past i → Jump_009_63ea space else Jump_009_63ec store; j>=8 ret.

GenNumName_B9::
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
    call MemCpy16_B9
    add sp, $05
    ld a, $05
    ld hl, sp+$25
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp nc, GenNumName_B9_makeSuffix

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

GenNumName_B9_crcLfnLoop::
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
    jp z, GenNumName_B9_storeHashSeq

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

GenNumName_B9_crcBitLoop::
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
    jr nz, GenNumName_B9_crcPolyXor

    jp GenNumName_B9_crcBitNext


GenNumName_B9_crcPolyXor::
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

GenNumName_B9_crcBitNext::
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
    jp nz, GenNumName_B9_crcBitLoop

    jp GenNumName_B9_crcLfnLoop


GenNumName_B9_storeHashSeq::
    ld hl, sp+$0a
    ld a, [hl]
    ld hl, sp+$25
    ld [hl], a
    ld hl, sp+$0b
    ld a, [hl]
    ld hl, sp+$26
    ld [hl], a

GenNumName_B9_makeSuffix::
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

GenNumName_B9_hexDigit::
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
    jp nc, GenNumName_B9_storeDigit

    ld a, [hl]
    add $07
    ld [hl], a

GenNumName_B9_storeDigit::
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

GenNumName_B9_seqShr4::
    ld hl, sp+$26
    srl [hl]
    dec hl
    rr [hl]
    dec a
    jr nz, GenNumName_B9_seqShr4

    ld a, [hl+]
    or [hl]
    jp nz, GenNumName_B9_hexDigit

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

GenNumName_B9_findAppend::
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
    jp nc, GenNumName_B9_appendStart

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
    jp z, GenNumName_B9_appendStart

    ld hl, sp+$10
    inc [hl]
    jr nz, GenNumName_B9_findAppendCont

    inc hl
    inc [hl]

GenNumName_B9_findAppendCont::
    jp GenNumName_B9_findAppend


GenNumName_B9_appendStart::
    ld hl, sp+$04
    ld a, [hl+]
    ld e, [hl]
    dec hl
    ld [hl+], a
    ld [hl], e

GenNumName_B9_appendLoop::
    ld hl, sp+$10
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, GenNumName_B9_appendInc

    inc hl
    inc [hl]

GenNumName_B9_appendInc::
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
    jp nc, GenNumName_B9_appendSpace

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, GenNumName_B9_appendFromNs

    inc hl
    inc [hl]

GenNumName_B9_appendFromNs::
    ld hl, sp+$00
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    jp GenNumName_B9_appendStore


GenNumName_B9_appendSpace::
    ld c, $20

GenNumName_B9_appendStore::
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
    jp c, GenNumName_B9_appendLoop

    add sp, $1d
    ret


; [ezgb]
; SumSfn_B9(dir): FatFs sum_sfn. 11-byte SFN checksum: sum=(sum>>1)|(sum<<7)+*dir++.
; Jump_009_6417 loop; jr_009_6430 after ptr++ when lo!=wrap; exit when count→0, return sum in E.

SumSfn_B9::
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

SumSfn_B9_loop::
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
    jr nz, SumSfn_B9_afterPtrInc

    inc hl
    inc [hl]

SumSfn_B9_afterPtrInc::
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
    jp nz, SumSfn_B9_loop

    inc hl
    ld e, [hl]
    add sp, $05
    ret


; [ezgb]
; DirFind_B9(dp): FatFs dir_find. DirSdi_B9(0); fail Jump_009_6469 init else err Jump_009_66a3.
; Jump_009_6469: clear ord/hash ptrs; Jump_009_64db read entry + MoveWindow_B9; fail Jump_009_66a0; LFN chain Jump_009_6534 else ord=4 Jump_009_66a0.
; Jump_009_6534: attr - deleted $E5 Jump_009_6559; volume jr_009_6553; LFN ord $0F Jump_009_6574 else Jump_009_656c/Jump_009_6574 SFN path.
; jr_009_6577: empty LFN chk Jump_009_6688; AM_LFN jr_009_658f store ord/chksum else Jump_009_65bb ord compare (Jump_009_65c6/jr_009_65c9/Jump_009_65dd/Jump_009_65e2/Jump_009_65e4 CmpLfn_B9).
; Jump_009_6606/Jump_009_660b/Jump_009_660d/Jump_009_661a/Jump_009_661c: LFN ord update Jump_009_6688; Jump_009_6622 SumSfn_B9 match Jump_009_66a0.
; Jump_009_663b NTRES jr_009_6659 skip; Jump_009_665c MemCmp_B9 SFN match Jump_009_66a0 else Jump_009_6678 invalidate; Jump_009_6688 DirNext_B9 loop Jump_009_64db; Jump_009_66a0/Jump_009_66a3 epilogue.

DirFind_B9::
    add sp, -$1a
    ld hl, $0000
    push hl
    ld hl, sp+$1e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirSdi_B9
    add sp, $04
    ld c, e
    ld hl, sp+$19
    ld [hl], c
    xor a
    or [hl]
    jp z, DirFind_B9_initOrd

    ld e, [hl]
    jp DirFind_B9_epilogue


DirFind_B9_initOrd::
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

DirFind_B9_readEntry::
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
    call MoveWindow_B9
    add sp, $06
    ld b, e
    ld hl, sp+$19
    ld [hl], b
    xor a
    or [hl]
    jp nz, DirFind_B9_found

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
    jp nz, DirFind_B9_checkAttr

    inc hl
    ld [hl], $04
    jp DirFind_B9_found


DirFind_B9_checkAttr::
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
    jp z, DirFind_B9_deletedEntry

    ld a, c
    and $08
    jr nz, DirFind_B9_volumeSkip

    jp DirFind_B9_checkAmLfn


DirFind_B9_volumeSkip::
    ld a, c
    sub $0f
    jp z, DirFind_B9_checkAmLfn

DirFind_B9_deletedEntry::
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
    jp DirFind_B9_dirNextLoop


DirFind_B9_checkAmLfn::
    ld a, c
    sub $0f
    jp nz, DirFind_B9_sfnPath

    jr DirFind_B9_lfnChain

DirFind_B9_sfnPath::
    jp DirFind_B9_sumSfnMatch


DirFind_B9_lfnChain::
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
    jp z, DirFind_B9_dirNextLoop

    ld hl, sp+$18
    ld a, [hl]
    and $40
    jr nz, DirFind_B9_storeOrdChksum

    jp DirFind_B9_ordCompare


DirFind_B9_storeOrdChksum::
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

DirFind_B9_ordCompare::
    ld hl, sp+$18
    ld a, [hl]
    ld hl, sp+$15
    sub [hl]
    jp nz, DirFind_B9_ordMismatch

    jr DirFind_B9_ordMatch

DirFind_B9_ordMismatch::
    jp DirFind_B9_cmpLfnFail


DirFind_B9_ordMatch::
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
    jp z, DirFind_B9_cmpLfnOk

DirFind_B9_cmpLfnFail::
    ld c, $00
    jp DirFind_B9_afterCmpLfn


DirFind_B9_cmpLfnOk::
    ld c, $01

DirFind_B9_afterCmpLfn::
    xor a
    or c
    jp z, DirFind_B9_ordUpdateFail

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
    call CmpLfn_B9
    add sp, $04
    ld b, d
    ld c, e
    ld a, c
    or b
    jp nz, DirFind_B9_ordUpdateOk

DirFind_B9_ordUpdateFail::
    ld c, $00
    jp DirFind_B9_afterOrdUpdate


DirFind_B9_ordUpdateOk::
    ld c, $01

DirFind_B9_afterOrdUpdate::
    xor a
    or c
    jp z, DirFind_B9_ordInvalidate

    ld hl, sp+$15
    ld a, [hl]
    dec a
    ld c, a
    jp DirFind_B9_storeOrd


DirFind_B9_ordInvalidate::
    ld c, $ff

DirFind_B9_storeOrd::
    ld hl, sp+$15
    ld [hl], c
    jp DirFind_B9_dirNextLoop


DirFind_B9_sumSfnMatch::
    xor a
    ld hl, sp+$15
    or [hl]
    jp nz, DirFind_B9_checkNtres

    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call SumSfn_B9
    add sp, $02
    ld c, e
    ld hl, sp+$14
    ld a, [hl]
    sub c
    jp z, DirFind_B9_found

DirFind_B9_checkNtres::
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
    jr nz, DirFind_B9_ntresSkip

    jp DirFind_B9_memcmpSfn


DirFind_B9_ntresSkip::
    jp DirFind_B9_invalidate


DirFind_B9_memcmpSfn::
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
    call MemCmp_B9
    add sp, $05
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, DirFind_B9_found

DirFind_B9_invalidate::
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

DirFind_B9_dirNextLoop::
    ld hl, $0000
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirNext_B9
    add sp, $04
    ld c, e
    ld hl, sp+$19
    ld [hl], c
    xor a
    or [hl]
    jp z, DirFind_B9_readEntry

DirFind_B9_found::
    ld hl, sp+$19
    ld e, [hl]

DirFind_B9_epilogue::
    add sp, $1a
    ret


; [ezgb]
; DirRead_B9(dp, vol@sp+$13): FatFs dir_read. Frame -$0f; sp+$0e default E=$04; sp+$09 LFN ord/$ff.
; Jump_009_66c9: load dir ptr@dp+$0e - cluster zero → Jump_009_688f; MoveWindow_B9 err → Jump_009_688f.
; NTRES@dp+$1c≠0 → Jump_009_6736; else set mode $04 → Jump_009_688f.
; Jump_009_6736: SFN[0] DDEM $E5 → Jump_009_6776; AM_VOL vs vol arg (Jump_009_6764/jr_009_6765) mismatch → Jump_009_6776.
; Jump_009_677d: ord $0F → jr_009_678a else Jump_009_6787→Jump_009_6847 SFN path.
; jr_009_678a: AM_VOL → jr_009_6794 stash checksum + dptr else Jump_009_67d8 attr filter.
; Jump_009_67d8: attr≠sp+$09 → Jump_009_67e3→Jump_009_67fa; jr_009_67e6 checksum match → Jump_009_67ff else Jump_009_67fa.
; Jump_009_6801: LFN ord ok → call $4ef7; fail Jump_009_682b else Jump_009_6830; Jump_009_6832 dec ord or Jump_009_683f→$ff → Jump_009_6841→Jump_009_6877.
; Jump_009_6847: sp+$09≠0 → Jump_009_6860 clear lfn ptr; else SumSfn_B9 match → Jump_009_688f.
; Jump_009_6877: DirNext_B9(0); E=0 → Jump_009_66c9; Jump_009_688f: E=0 Jump_009_68aa else zero dir ptr → Jump_009_68aa ret E.

DirRead_B9::
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

DirRead_B9_entryLoop::
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
    jp z, DirRead_B9_done

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
    call MoveWindow_B9
    add sp, $06
    ld c, e
    ld hl, sp+$0e
    ld [hl], c
    xor a
    or [hl]
    jp nz, DirRead_B9_done

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
    jp nz, DirRead_B9_checkSfn

    inc hl
    inc hl
    ld [hl], $04
    jp DirRead_B9_done


DirRead_B9_checkSfn::
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
    jp z, DirRead_B9_skipEntry

    ld hl, sp+$0d
    ld c, [hl]
    ld b, $00
    ld a, c
    and $df
    ld c, a
    sub $08
    jp nz, DirRead_B9_volCompare

    or b
    jp nz, DirRead_B9_volCompare

    ld a, $01
    jr DirRead_B9_volCompareJr

DirRead_B9_volCompare::
    xor a

DirRead_B9_volCompareJr::
    ld c, a
    rla
    sbc a
    ld b, a
    ld a, c
    ld hl, sp+$13
    sub [hl]
    jp nz, DirRead_B9_skipEntry

    ld a, b
    inc hl
    sub [hl]
    jp z, DirRead_B9_checkOrd

DirRead_B9_skipEntry::
    ld hl, sp+$09
    ld [hl], $ff
    jp DirRead_B9_dirNext


DirRead_B9_checkOrd::
    ld hl, sp+$0d
    ld a, [hl]
    sub $0f
    jp nz, DirRead_B9_sfnPath

    jr DirRead_B9_lfnOrd

DirRead_B9_sfnPath::
    jp DirRead_B9_sfnSumCheck


DirRead_B9_lfnOrd::
    ld hl, sp+$0c
    ld a, [hl]
    and $40
    jr nz, DirRead_B9_stashChksum

    jp DirRead_B9_attrFilter


DirRead_B9_stashChksum::
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

DirRead_B9_attrFilter::
    ld hl, sp+$0c
    ld a, [hl]
    ld hl, sp+$09
    sub [hl]
    jp nz, DirRead_B9_attrMismatch

    jr DirRead_B9_chksumMatch

DirRead_B9_attrMismatch::
    jp DirRead_B9_lfnFail


DirRead_B9_chksumMatch::
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
    jp z, DirRead_B9_lfnOk

DirRead_B9_lfnFail::
    ld c, $00
    jp DirRead_B9_afterLfnGate


DirRead_B9_lfnOk::
    ld c, $01

DirRead_B9_afterLfnGate::
    xor a
    or c
    jp z, DirRead_B9_pickLfnFail

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
    call $5fc5
    add sp, $04
    ld b, d
    ld c, e
    ld a, c
    or b
    jp nz, DirRead_B9_pickLfnOk

DirRead_B9_pickLfnFail::
    ld c, $00
    jp DirRead_B9_afterPickLfn


DirRead_B9_pickLfnOk::
    ld c, $01

DirRead_B9_afterPickLfn::
    xor a
    or c
    jp z, DirRead_B9_ordInvalidate

    ld hl, sp+$09
    ld a, [hl]
    dec a
    ld c, a
    jp DirRead_B9_storeOrd


DirRead_B9_ordInvalidate::
    ld c, $ff

DirRead_B9_storeOrd::
    ld hl, sp+$09
    ld [hl], c
    jp DirRead_B9_dirNext


DirRead_B9_sfnSumCheck::
    xor a
    ld hl, sp+$09
    or [hl]
    jp nz, DirRead_B9_clearLfnPtr

    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call SumSfn_B9
    add sp, $02
    ld c, e
    ld hl, sp+$08
    ld a, [hl]
    sub c
    jp z, DirRead_B9_done

DirRead_B9_clearLfnPtr::
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
    jp DirRead_B9_done


DirRead_B9_dirNext::
    ld hl, $0000
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirNext_B9
    add sp, $04
    ld c, e
    ld hl, sp+$0e
    ld [hl], c
    xor a
    or [hl]
    jp z, DirRead_B9_entryLoop

DirRead_B9_done::
    xor a
    ld hl, sp+$0e
    or [hl]
    jp z, DirRead_B9_epilogue

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

DirRead_B9_epilogue::
    ld hl, sp+$0e
    ld e, [hl]
    add sp, $0f
    ret


; [ezgb]
; DirRegister_B9(dp): FatFs dir_register. Frame -$26; copy SFN/LFN from dp; sp+$25=E.
; NSFLAG directory → jr_009_6921 E=$06 Jump_009_6c3b; Jump_009_6926: AM_DIR → jr_009_692e GenNumName loop Jump_009_694f.
; Jump_009_694f: idx<100 GenNumName_B9+DirFind_B9; taken → jr_009_6992 ++idx; miss → Jump_009_6995.
; Jump_009_6995: idx==100 → jr_009_69a8 E=$07 else Jump_009_69a5→Jump_009_69ad; E==$04 → Jump_009_69bb patch attr/size.
; Jump_009_69da: LFN (attr&$02) → jr_009_69e8 count slots Jump_009_69ef/jr_009_6a12; Jump_009_6a15 U16Div → Jump_009_6a3a else Jump_009_6a33 n=1.
; Jump_009_6a3a: DirAlloc_B9; err → Jump_009_6b6c; LFN slots Jump_009_6ac2 (DirSdi, SumSfn, MoveWindow, PutLfn_B9, DirNext) loop.
; Jump_009_6b6c: err → Jump_009_6c38 else finalize SFN (MoveWindow, MemSet8, MemCpy16, attr mask) + FA_DIRTY.
; Jump_009_6c38/Jump_009_6c3b add sp,$26 ret E.

DirRegister_B9::
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
    call MemCpy16_B9
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
    jr nz, DirRegister_B9_deniedIsDir

    jp DirRegister_B9_checkCollision


DirRegister_B9_deniedIsDir::
    ld e, $06
    jp DirRegister_B9_epilogue


DirRegister_B9_checkCollision::
    ld a, c
    and $01
    jr nz, DirRegister_B9_genNumInit

    jp DirRegister_B9_checkLfn


DirRegister_B9_genNumInit::
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

DirRegister_B9_genNumLoop::
    ld hl, sp+$23
    ld a, [hl]
    sub $64
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, DirRegister_B9_afterGenNum

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
    call GenNumName_B9
    add sp, $08
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirFind_B9
    add sp, $02
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, DirRegister_B9_afterGenNum

    dec hl
    dec hl
    inc [hl]
    jr nz, DirRegister_B9_genNumNext

    inc hl
    inc [hl]

DirRegister_B9_genNumNext::
    jp DirRegister_B9_genNumLoop


DirRegister_B9_afterGenNum::
    ld hl, sp+$23
    ld a, [hl]
    sub $64
    jp nz, DirRegister_B9_genNumOk

    inc hl
    ld a, [hl]
    or a
    jp nz, DirRegister_B9_genNumOk

    jr DirRegister_B9_deniedTooMany

DirRegister_B9_genNumOk::
    jp DirRegister_B9_checkNoFile


DirRegister_B9_deniedTooMany::
    ld e, $07
    jp DirRegister_B9_epilogue


DirRegister_B9_checkNoFile::
    ld hl, sp+$25
    ld a, [hl]
    sub $04
    jp z, DirRegister_B9_patchAttrSize

    ld hl, sp+$25
    ld e, [hl]
    jp DirRegister_B9_epilogue


DirRegister_B9_patchAttrSize::
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

DirRegister_B9_checkLfn::
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $02
    jr nz, DirRegister_B9_countLfnSlots

    jp DirRegister_B9_slotsOne


DirRegister_B9_countLfnSlots::
    ld hl, sp+$23
    ld [hl], $00
    inc hl
    ld [hl], $00

DirRegister_B9_lfnLenLoop::
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
    jp z, DirRegister_B9_u16DivSlots

    ld hl, sp+$23
    inc [hl]
    jr nz, DirRegister_B9_lfnLenCont

    inc hl
    inc [hl]

DirRegister_B9_lfnLenCont::
    jp DirRegister_B9_lfnLenLoop


DirRegister_B9_u16DivSlots::
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
    jp DirRegister_B9_dirAlloc


DirRegister_B9_slotsOne::
    ld hl, sp+$21
    ld [hl], $01
    inc hl
    ld [hl], $00

DirRegister_B9_dirAlloc::
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
    call DirAlloc_B9
    add sp, $04
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, DirRegister_B9_finalizeSfn

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
    jp z, DirRegister_B9_finalizeSfn

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
    call DirSdi_B9
    add sp, $04
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, DirRegister_B9_finalizeSfn

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
    call SumSfn_B9
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

DirRegister_B9_putLfnLoop::
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
    call MoveWindow_B9
    add sp, $06
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, DirRegister_B9_finalizeSfn

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
    call PutLfn_B9
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
    call DirNext_B9
    add sp, $04
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, DirRegister_B9_finalizeSfn

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
    jp nz, DirRegister_B9_putLfnLoop

DirRegister_B9_finalizeSfn::
    xor a
    ld hl, sp+$25
    or [hl]
    jp nz, DirRegister_B9_setResult

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
    call MoveWindow_B9
    add sp, $06
    ld c, e
    ld hl, sp+$25
    ld [hl], c
    xor a
    or [hl]
    jp nz, DirRegister_B9_setResult

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
    ld hl, $0020
    push hl
    ld l, $00
    push hl
    push bc
    call MemSet16_B9
    add sp, $06
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
    call MemCpy16_B9
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

DirRegister_B9_setResult::
    ld hl, sp+$25
    ld e, [hl]

DirRegister_B9_epilogue::
    add sp, $26
    ret


; [ezgb]
; FatFs create_name (bank-9 canonical). Twin CF notes mirrored from CreateName_B3.
; CreateName_B9(dp, path): FatFs create_name twin of CreateName_B9 (09:6c3e). Frame -$1b; parse next path segment; build SFN/LFN+NSFLAG.
; Jump_009_6c59: skip leading '/' ($2f) or '\\' ($5c): Jump_009_6c6f/jr_009_6c6f ++BC loop; else Jump_009_6c6c → Jump_009_6c78 start segment.
; Jump_009_6c78: stash path; lfnbuf@dp+$16; clear counters. Jump_009_6caf: ++idx (jr_009_6cba); load char; <' ' or '/' or '\\' → Jump_009_6d81 end segment.
; Jump_009_6ceb/Jump_009_6cf9: not terminator; Jump_009_6d0a: if lfn idx≥$ff → E=$06 Jump_009_72b2; else MapCp437; fail → Jump_009_72b2.
; Jump_009_6d2f: if <*$80 MemChr illegal set; hit → Jump_009_72b2; Jump_009_6d55/jr_009_6d60 store wchar to lfnbuf → Jump_009_6caf.
; Jump_009_6d81: write advanced path ptr; last char <' ' → C=$04 (NSFLAG) else Jump_009_6da9 C=0; Jump_009_6dab store NSFLAG@sp+$19.
; If lfnlen!=1 Jump_009_6dbe → Jump_009_6de4; else jr_009_6dc1: last wchar=='.' → Jump_009_6e48/jr_009_6e48 else Jump_009_6de4.
; Jump_009_6de4: len!=2 → Jump_009_6df4 → Jump_009_6edb; else jr_009_6df7: '..' check (Jump_009_6e1c/jr_009_6e1f/Jump_009_6e45) → Jump_009_6e48 or Jump_009_6edb.
; Jump_009_6e48/jr_009_6e48: NUL-term LFN; Jump_009_6e78 fill SFN 11 slots (Jump_009_6eac/Jump_009_6eb0); done Jump_009_6ebe.
; SFN pad loop: Jump_009_6e78; insert '.' Jump_009_6eac else space Jump_009_6eb0; jr_009_6ebb → Jump_009_6e78; done Jump_009_6ebe OR NSFLAG|$20 → Jump_009_72b2 (dot-only names).
; Jump_009_6edb: normal path; Jump_009_6ee3 strip trailing ' '/' .' (Jump_009_6f14 / Jump_009_6f24 / Jump_009_6f27 / jr_009_6f27); Jump_009_6f3b empty → E=$06 Jump_009_72b2 else Jump_009_6f4f NUL-term + MemSet8_B9 spaces into SFN.
; Jump_009_6f99: skip leading ' '/' .' (Jump_009_6fbb / Jump_009_6fc7 / Jump_009_6fca / jr_009_6fca / jr_009_6fd1); non-lead Jump_009_6fdc; if skipped NSFLAG|$03 then Jump_009_6ff1.
; Jump_009_6ff1: walk for last '.' (Jump_009_7028 → Jump_009_6ff1); none/done Jump_009_7035 init body len=8 then Jump_009_7047.
; Jump_009_7047 SFN fill: next wchar (jr_009_7052); NUL→Jump_009_7211; space Jump_009_70a2; '.' Jump_009_707d/Jump_009_708d/jr_009_7090; else Jump_009_70ab; slot full Jump_009_70d1/jr_009_70d1/Jump_009_70e1/jr_009_70e4; body	oext Jump_009_70ed/Jump_009_70ff/Jump_009_7105; else Jump_009_70ce → Jump_009_7132 MapCp437.
; Jump_009_7132: wchar>=$80 MapCp437 (fail Jump_009_716d NSFLAG|$02); then Jump_009_7173 MemChr_B9 illegal set → '_' Jump_009_718f NSFLAG|$03 else Jump_009_719e.
; Case: A-Z Jump_009_71be skip else NSFLAG|$02 → Jump_009_71ec; a-z Jump_009_71be NSFLAG|$01 + toupper; store via jr_009_7202 → Jump_009_7047.
; Jump_009_7211: SFN[0]==$E5 → $05 (jr_009_722b) else Jump_009_7228/Jump_009_7233; body-only Jump_009_7243/jr_009_7246 NT<<2; case mix Jump_009_724c/Jump_009_7264/Jump_009_7267/jr_009_7267 → NSFLAG|$02; Jump_009_726d/jr_009_7277/Jump_009_727a/Jump_009_7287/jr_009_728a/Jump_009_7290/Jump_009_7298/jr_009_729b/Jump_009_72a1 store NSFLAG; E=0 → Jump_009_72b2.
; CreateName CF ends at cleanup Jump (add sp,$1b / ret). Post-ret illegal-char table then FollowPath_B9 @ 09:72c5 (already named) - not CreateName interior.

CreateName_B9::
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

CreateName_B9_skipLeadSep::
    ld a, [bc]
    ld hl, sp+$08
    ld [hl], a
    sub $2f
    jp z, CreateName_B9_skipLeadSepInc

    ld hl, sp+$08
    ld a, [hl]
    sub $5c
    jp nz, CreateName_B9_skipLeadSepElse

    jr CreateName_B9_skipLeadSepInc

CreateName_B9_skipLeadSepElse::
    jp CreateName_B9_startSegment


CreateName_B9_skipLeadSepInc::
    inc bc
    ld hl, sp+$0b
    ld [hl], c
    inc hl
    ld [hl], b
    jp CreateName_B9_skipLeadSep


CreateName_B9_startSegment::
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

CreateName_B9_lfnCharLoop::
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, CreateName_B9_afterLfnPtrInc

    inc hl
    inc [hl]

CreateName_B9_afterLfnPtrInc::
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
    jp c, CreateName_B9_endSegment

    dec hl
    ld a, [hl]
    sub $2f
    jp nz, CreateName_B9_checkBackslashSep

    inc hl
    ld a, [hl]
    or a
    jp z, CreateName_B9_endSegment

CreateName_B9_checkBackslashSep::
    ld hl, sp+$17
    ld a, [hl]
    sub $5c
    jp nz, CreateName_B9_notTerminator

    inc hl
    ld a, [hl]
    or a
    jp z, CreateName_B9_endSegment

CreateName_B9_notTerminator::
    ld hl, sp+$02
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp c, CreateName_B9_mapCp437

    ld e, $06
    jp CreateName_B9_cleanup


CreateName_B9_mapCp437::
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
    jp nz, CreateName_B9_checkIllegalAscii

    ld e, $06
    jp CreateName_B9_cleanup


CreateName_B9_checkIllegalAscii::
    ld hl, sp+$17
    ld a, [hl]
    sub $80
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, CreateName_B9_storeWcharLfn

    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $72b5
    push hl
    call MemChr_B9
    add sp, $04
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, CreateName_B9_storeWcharLfn

    ld e, $06
    jp CreateName_B9_cleanup


CreateName_B9_storeWcharLfn::
    ld hl, sp+$02
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, CreateName_B9_afterWcharIdxInc

    inc hl
    inc [hl]

CreateName_B9_afterWcharIdxInc::
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
    jp CreateName_B9_lfnCharLoop


CreateName_B9_endSegment::
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
    jp nc, CreateName_B9_nsflagNotLast

    ld c, $04
    jp CreateName_B9_storeNsflag


CreateName_B9_nsflagNotLast::
    ld c, $00

CreateName_B9_storeNsflag::
    ld hl, sp+$19
    ld [hl], c
    ld hl, sp+$0d
    ld a, [hl]
    sub $01
    jp nz, CreateName_B9_notLen1Dot

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateName_B9_notLen1Dot

    jr CreateName_B9_checkSingleDot

CreateName_B9_notLen1Dot::
    jp CreateName_B9_checkDotDot


CreateName_B9_checkSingleDot::
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
    jp nz, CreateName_B9_checkDotDot

    or b
    jp z, CreateName_B9_dotEntry

CreateName_B9_checkDotDot::
    ld hl, sp+$0d
    ld a, [hl]
    sub $02
    jp nz, CreateName_B9_notLen2DotDot

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateName_B9_notLen2DotDot

    jr CreateName_B9_checkDotDotTail

CreateName_B9_notLen2DotDot::
    jp CreateName_B9_normalPath


CreateName_B9_checkDotDotTail::
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
    jp nz, CreateName_B9_dotDotMismatch

    or b
    jp nz, CreateName_B9_dotDotMismatch

    jr CreateName_B9_checkDotDotHead

CreateName_B9_dotDotMismatch::
    jp CreateName_B9_normalPath


CreateName_B9_checkDotDotHead::
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
    jp nz, CreateName_B9_notDotDot

    or b
    jp nz, CreateName_B9_notDotDot

    jr CreateName_B9_dotEntry

CreateName_B9_notDotDot::
    jp CreateName_B9_normalPath


CreateName_B9_dotEntry::
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

CreateName_B9_sfnPadLoop::
    ld hl, sp+$13
    ld a, [hl]
    sub $0b
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, CreateName_B9_dotEntryDone

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
    jp nc, CreateName_B9_sfnPadSpace

    ld hl, sp+$02
    ld [hl], $2e
    jp CreateName_B9_sfnPadStore


CreateName_B9_sfnPadSpace::
    ld hl, sp+$02
    ld [hl], $20

CreateName_B9_sfnPadStore::
    ld hl, sp+$02
    ld a, [hl]
    ld [bc], a
    ld hl, sp+$13
    inc [hl]
    jr nz, CreateName_B9_afterSfnPadIdxInc

    inc hl
    inc [hl]

CreateName_B9_afterSfnPadIdxInc::
    jp CreateName_B9_sfnPadLoop


CreateName_B9_dotEntryDone::
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
    jp CreateName_B9_cleanup


CreateName_B9_normalPath::
    ld hl, sp+$0d
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e

CreateName_B9_stripTrailing::
    ld hl, sp+$00
    ld a, [hl+]
    or [hl]
    jp z, CreateName_B9_afterStripTrail

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
    jp nz, CreateName_B9_stripTrailNotSpace

    inc hl
    ld a, [hl]
    or a
    jp z, CreateName_B9_stripTrailDec

CreateName_B9_stripTrailNotSpace::
    ld hl, sp+$17
    ld a, [hl]
    sub $2e
    jp nz, CreateName_B9_stripTrailBreak

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateName_B9_stripTrailBreak

    jr CreateName_B9_stripTrailDec

CreateName_B9_stripTrailBreak::
    jp CreateName_B9_afterStripTrail


CreateName_B9_stripTrailDec::
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
    jp CreateName_B9_stripTrailing


CreateName_B9_afterStripTrail::
    ld hl, sp+$00
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0d
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$00
    ld a, [hl+]
    or [hl]
    jp nz, CreateName_B9_nulTermClearSfn

    ld e, $06
    jp CreateName_B9_cleanup


CreateName_B9_nulTermClearSfn::
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
    ld hl, $000b
    push hl
    ld l, $20
    push hl
    push bc
    call MemSet16_B9
    add sp, $06
    ld hl, sp+$0f
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$02
    ld [hl], $00
    inc hl
    ld [hl], $00

CreateName_B9_skipLeadSpaceDot::
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
    jp nz, CreateName_B9_skipLeadNotSpace

    or b
    jp z, CreateName_B9_skipLeadInc

CreateName_B9_skipLeadNotSpace::
    ld a, c
    sub $2e
    jp nz, CreateName_B9_skipLeadNonLead

    or b
    jp nz, CreateName_B9_skipLeadNonLead

    jr CreateName_B9_skipLeadInc

CreateName_B9_skipLeadNonLead::
    jp CreateName_B9_afterSkipLead


CreateName_B9_skipLeadInc::
    ld hl, sp+$02
    inc [hl]
    jr nz, CreateName_B9_afterSkipLeadIdxInc

    inc hl
    inc [hl]

CreateName_B9_afterSkipLeadIdxInc::
    ld hl, sp+$02
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0f
    ld [hl+], a
    ld [hl], e
    jp CreateName_B9_skipLeadSpaceDot


CreateName_B9_afterSkipLead::
    ld hl, sp+$02
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0f
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$02
    ld a, [hl+]
    or [hl]
    jp z, CreateName_B9_findLastDot

    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a

CreateName_B9_findLastDot::
    ld hl, sp+$0d
    ld a, [hl+]
    or [hl]
    jp z, CreateName_B9_initBodyLen

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
    jp nz, CreateName_B9_findLastDotCont

    or b
    jp z, CreateName_B9_initBodyLen

CreateName_B9_findLastDotCont::
    ld hl, sp+$02
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$0d
    ld [hl], c
    inc hl
    ld [hl], b
    jp CreateName_B9_findLastDot


CreateName_B9_initBodyLen::
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

CreateName_B9_sfnFillLoop::
    ld hl, sp+$0f
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec hl
    inc [hl]
    jr nz, CreateName_B9_afterSfnFillIdxInc

    inc hl
    inc [hl]

CreateName_B9_afterSfnFillIdxInc::
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
    jp z, CreateName_B9_sfnDoneDdem

    dec hl
    ld a, [hl]
    sub $20
    jp nz, CreateName_B9_sfnFillCheckDot

    inc hl
    ld a, [hl]
    or a
    jp z, CreateName_B9_sfnFillSpaceLoss

CreateName_B9_sfnFillCheckDot::
    ld hl, sp+$17
    ld a, [hl]
    sub $2e
    jp nz, CreateName_B9_sfnFillNotDot

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateName_B9_sfnFillNotDot

    jr CreateName_B9_sfnFillDotPath

CreateName_B9_sfnFillNotDot::
    jp CreateName_B9_sfnFillSlotCheck


CreateName_B9_sfnFillDotPath::
    ld hl, sp+$0f
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, CreateName_B9_sfnFillSpaceLoss

    ld hl, sp+$10
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp z, CreateName_B9_sfnFillSlotCheck

CreateName_B9_sfnFillSpaceLoss::
    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a
    jp CreateName_B9_sfnFillLoop


CreateName_B9_sfnFillSlotCheck::
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
    jp nc, CreateName_B9_sfnFillSlotFull

    ld hl, sp+$0f
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, CreateName_B9_sfnFillToMap

    ld hl, sp+$10
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, CreateName_B9_sfnFillToMap

    jr CreateName_B9_sfnFillSlotFull

CreateName_B9_sfnFillToMap::
    jp CreateName_B9_sfnMapCp437


CreateName_B9_sfnFillSlotFull::
    ld hl, sp+$11
    ld a, [hl]
    sub $0b
    jp nz, CreateName_B9_sfnFillToExt

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateName_B9_sfnFillToExt

    jr CreateName_B9_sfnFillSlotFullLoss

CreateName_B9_sfnFillToExt::
    jp CreateName_B9_sfnFillBodyToExt


CreateName_B9_sfnFillSlotFullLoss::
    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a
    jp CreateName_B9_sfnDoneDdem


CreateName_B9_sfnFillBodyToExt::
    ld hl, sp+$0f
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp nz, CreateName_B9_sfnFillBodyOverflow

    ld hl, sp+$10
    ld a, [hl]
    dec hl
    dec hl
    sub [hl]
    jp z, CreateName_B9_sfnFillEnterExt

CreateName_B9_sfnFillBodyOverflow::
    ld hl, sp+$19
    ld a, [hl]
    or $03
    ld [hl], a

CreateName_B9_sfnFillEnterExt::
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
    jp c, CreateName_B9_sfnDoneDdem

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
    jp CreateName_B9_sfnFillLoop


CreateName_B9_sfnMapCp437::
    ld hl, sp+$17
    ld a, [hl]
    sub $80
    inc hl
    ld a, [hl]
    sbc $00
    jp c, CreateName_B9_sfnCheckIllegal

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
    jp z, CreateName_B9_sfnMapCp437Fail

    dec hl
    ld c, [hl]
    ld a, c
    add $80
    add $82
    ld c, a
    ld a, $40
    adc $00
    ld b, a
    ld a, [bc]
    ld c, a
    ld [hl], c
    inc hl
    ld [hl], $00

CreateName_B9_sfnMapCp437Fail::
    ld hl, sp+$19
    ld a, [hl]
    or $02
    ld [hl], a

CreateName_B9_sfnCheckIllegal::
    ld hl, sp+$17
    ld a, [hl+]
    or [hl]
    jp z, CreateName_B9_sfnReplaceUnderscore

    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $72be
    push hl
    call MemChr_B9
    add sp, $04
    ld b, d
    ld c, e
    ld a, c
    or b
    jp z, CreateName_B9_sfnCaseUpper

CreateName_B9_sfnReplaceUnderscore::
    ld hl, sp+$17
    ld [hl], $5f
    inc hl
    ld [hl], $00
    inc hl
    ld a, [hl]
    or $03
    ld [hl], a
    jp CreateName_B9_sfnStoreByte


CreateName_B9_sfnCaseUpper::
    ld hl, sp+$17
    ld a, [hl]
    sub $41
    inc hl
    ld a, [hl]
    sbc $00
    jp c, CreateName_B9_sfnCaseLower

    ld a, $5a
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp c, CreateName_B9_sfnCaseLower

    inc hl
    inc hl
    ld a, [hl]
    or $02
    ld [hl], a
    jp CreateName_B9_sfnStoreByte


CreateName_B9_sfnCaseLower::
    ld hl, sp+$17
    ld a, [hl]
    sub $61
    inc hl
    ld a, [hl]
    sbc $00
    jp c, CreateName_B9_sfnStoreByte

    ld a, $7a
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp c, CreateName_B9_sfnStoreByte

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

CreateName_B9_sfnStoreByte::
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
    jr nz, CreateName_B9_sfnStoreByteJr

    inc hl
    inc [hl]

CreateName_B9_sfnStoreByteJr::
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
    jp CreateName_B9_sfnFillLoop


CreateName_B9_sfnDoneDdem::
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
    jp nz, CreateName_B9_afterDdem

    jr CreateName_B9_replaceDdem

CreateName_B9_afterDdem::
    jp CreateName_B9_checkBodyOnly


CreateName_B9_replaceDdem::
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $05
    ld [de], a

CreateName_B9_checkBodyOnly::
    ld hl, sp+$11
    ld a, [hl]
    sub $08
    jp nz, CreateName_B9_afterBodyOnly

    inc hl
    ld a, [hl]
    or a
    jp nz, CreateName_B9_afterBodyOnly

    jr CreateName_B9_ntShiftBodyOnly

CreateName_B9_afterBodyOnly::
    jp CreateName_B9_caseMixCheck


CreateName_B9_ntShiftBodyOnly::
    ld hl, sp+$1a
    sla [hl]
    sla [hl]

CreateName_B9_caseMixCheck::
    ld hl, sp+$1a
    ld a, [hl]
    and $0c
    ld c, a
    sub $0c
    jp z, CreateName_B9_caseMixSetLfn

    ld hl, sp+$1a
    ld a, [hl]
    and $03
    ld b, a
    sub $03
    jp nz, CreateName_B9_caseMixOk

    jr CreateName_B9_caseMixSetLfn

CreateName_B9_caseMixOk::
    jp CreateName_B9_storeNtFlags


CreateName_B9_caseMixSetLfn::
    ld hl, sp+$19
    ld a, [hl]
    or $02
    ld [hl], a

CreateName_B9_storeNtFlags::
    ld hl, sp+$19
    ld a, [hl]
    and $02
    jr nz, CreateName_B9_skipNtFlags

    jp CreateName_B9_ntExtCheck


CreateName_B9_skipNtFlags::
    jp CreateName_B9_storeNsflagFinal


CreateName_B9_ntExtCheck::
    ld hl, sp+$1a
    ld a, [hl]
    and $03
    ld b, a
    sub $01
    jp nz, CreateName_B9_afterNtExt

    jr CreateName_B9_setNsExt

CreateName_B9_afterNtExt::
    jp CreateName_B9_ntBodyCheck


CreateName_B9_setNsExt::
    ld hl, sp+$19
    ld a, [hl]
    or $10
    ld [hl], a

CreateName_B9_ntBodyCheck::
    ld a, c
    sub $04
    jp nz, CreateName_B9_afterNtBody

    jr CreateName_B9_setNsBody

CreateName_B9_afterNtBody::
    jp CreateName_B9_storeNsflagFinal


CreateName_B9_setNsBody::
    ld hl, sp+$19
    ld a, [hl]
    or $08
    ld [hl], a

CreateName_B9_storeNsflagFinal::
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

CreateName_B9_cleanup::
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
; FatFs follow_path (bank-9 canonical). Twin of FollowPath_B3/B5/B6; CreateName_B9 sibling.
; Entry: skip leading '/' '\' (Jump_009_72df → Jump_009_730b else Jump_009_72e2 / jr_009_72e2 clear sclust → Jump_009_7349).
; Jump_009_730b: copy fs->cdir into dp->sclust; Join Jump_009_7349.
; Jump_009_7349: path[0]<' ' → DirSdi_B9(0) + clear fn → Jump_009_750a else Jump_009_7386 segment loop (CreateName_B9 / DirFind_B9).
; Jump_009_7386 segment loop: CreateName_B9; err→Jump_009_750a; DirFind_B9; FR_NOFILE+$04 last-seg (jr_009_73e7) else Jump_009_73e4→Jump_009_750a; NSFLAG|$20 (jr_009_73f1) clear sclust/fn + more path→Jump_009_7386 else last (jr_009_742b E=0); non-last NSFLAG Jump_009_7432/jr_009_743c/Jump_009_743f E=$05.
; Found (Jump_009_7446): last-seg jr_009_748b→Jump_009_750a; else Jump_009_748e ATTR_DIR? jr_009_74b8→Jump_009_74c2 LdClust_B9 into sclust → Jump_009_7386 else Jump_009_74bb E=$05; Jump_009_750a epilogue ret E.

FollowPath_B9::
    add sp, -$0f
    ld hl, sp+$13
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, [bc]
    ld hl, sp+$0a
    ld [hl], a
    sub $2f
    jp z, FollowPath_B9_clearSclust

    ld hl, sp+$0a
    ld a, [hl]
    sub $5c
    jp nz, FollowPath_B9_hasLeadSep

    jr FollowPath_B9_clearSclust

FollowPath_B9_hasLeadSep::
    jp FollowPath_B9_copyCdir


FollowPath_B9_clearSclust::
    ld hl, $0001
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$13
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$11
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
    jp FollowPath_B9_checkEmptyPath


FollowPath_B9_copyCdir::
    ld hl, sp+$11
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, $0006
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$08
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

FollowPath_B9_checkEmptyPath::
    ld hl, sp+$13
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
    jp nc, FollowPath_B9_segmentLoop

    ld hl, $0000
    push hl
    ld hl, sp+$13
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirSdi_B9
    add sp, $04
    ld c, e
    ld hl, sp+$0e
    ld [hl], c
    ld hl, sp+$11
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
    jp FollowPath_B9_epilogue


FollowPath_B9_segmentLoop::
    ld hl, sp+$13
    ld c, l
    ld b, h
    push bc
    ld hl, sp+$13
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call CreateName_B9
    add sp, $04
    ld c, e
    ld hl, sp+$0e
    ld [hl], c
    xor a
    or [hl]
    jp nz, FollowPath_B9_epilogue

    ld hl, sp+$11
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call DirFind_B9
    add sp, $02
    ld c, e
    ld hl, sp+$0e
    ld [hl], c
    ld hl, sp+$11
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$08
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
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld e, a
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
    ld hl, sp+$0b
    ld [hl], c
    xor a
    ld hl, sp+$0e
    or [hl]
    jp z, FollowPath_B9_found

    ld a, [hl]
    sub $04
    jp nz, FollowPath_B9_findFail

    jr FollowPath_B9_noFileLastSeg

FollowPath_B9_findFail::
    jp FollowPath_B9_epilogue


FollowPath_B9_noFileLastSeg::
    ld hl, sp+$0b
    ld a, [hl]
    and $20
    jr nz, FollowPath_B9_dotEntry

    jp FollowPath_B9_nonLastNsflag


FollowPath_B9_dotEntry::
    ld hl, sp+$08
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
    ld hl, sp+$08
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
    ld hl, sp+$0b
    ld a, [hl]
    and $04
    jr nz, FollowPath_B9_lastSegOk

    jp FollowPath_B9_segmentLoop


FollowPath_B9_lastSegOk::
    ld hl, sp+$0e
    ld [hl], $00
    jp FollowPath_B9_epilogue


FollowPath_B9_nonLastNsflag::
    ld hl, sp+$0b
    ld a, [hl]
    and $04
    jr nz, FollowPath_B9_nsLastOk

    jp FollowPath_B9_deniedNotDir


FollowPath_B9_nsLastOk::
    jp FollowPath_B9_epilogue


FollowPath_B9_deniedNotDir::
    ld hl, sp+$0e
    ld [hl], $05
    jp FollowPath_B9_epilogue


FollowPath_B9_found::
    ld hl, $0000
    push hl
    ld hl, $0077
    push hl
    call RetStub_B9
    add sp, $04
    ld hl, sp+$04
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
    call RetStub_B9
    add sp, $04
    ld hl, sp+$0b
    ld a, [hl]
    and $04
    jr nz, FollowPath_B9_foundLastSeg

    jp FollowPath_B9_checkAttrDir


FollowPath_B9_foundLastSeg::
    jp FollowPath_B9_epilogue


FollowPath_B9_checkAttrDir::
    ld hl, sp+$08
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
    ld hl, sp+$0c
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
    jr nz, FollowPath_B9_isDir

    jp FollowPath_B9_notDir


FollowPath_B9_isDir::
    jp FollowPath_B9_ldClustEnter


FollowPath_B9_notDir::
    ld hl, sp+$0e
    ld [hl], $05
    jp FollowPath_B9_epilogue


FollowPath_B9_ldClustEnter::
    ld hl, sp+$08
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
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call LdClust_B9
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
    jp FollowPath_B9_segmentLoop


FollowPath_B9_epilogue::
    ld hl, sp+$0e
    ld e, [hl]
    add sp, $0f
    ret


; [ezgb]
; GetLdNumber_B9(path): FatFs get_ldnumber. Frame -$0b; returns DE=vol (-1 invalid).
; Init vol=-1; null *path → Jump_009_75df; else Jump_009_7539 scan for ':' or <' ' (jr_009_755c) → Jump_009_755f.
; No colon → Jump_009_756d→Jump_009_75d8 vol=0; colon → jr_009_7570 parse digit (jr_009_7586); ≥10 or not single-digit → Jump_009_75af→Jump_009_75d0 keep -1.
; jr_009_75b2: digit<FF_VOLUMES → store vol + snip path; Jump_009_75d0/Jump_009_75df→Jump_009_75e4 epilogue.

GetLdNumber_B9::
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
    jp z, GetLdNumber_B9_returnResult

    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b

GetLdNumber_B9_scanColon::
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
    jp c, GetLdNumber_B9_afterScan

    ld a, [hl]
    sub $3a
    jp z, GetLdNumber_B9_afterScan

    ld hl, sp+$00
    inc [hl]
    jr nz, GetLdNumber_B9_scanCont

    inc hl
    inc [hl]

GetLdNumber_B9_scanCont::
    jp GetLdNumber_B9_scanColon


GetLdNumber_B9_afterScan::
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $3a
    jp nz, GetLdNumber_B9_noColon

    jr GetLdNumber_B9_parseDigit

GetLdNumber_B9_noColon::
    jp GetLdNumber_B9_defaultVol0


GetLdNumber_B9_parseDigit::
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
    jr nz, GetLdNumber_B9_digitSignExt

    inc hl
    inc [hl]

GetLdNumber_B9_digitSignExt::
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
    jp nc, GetLdNumber_B9_returnVol

    ld hl, sp+$09
    ld a, [hl]
    ld hl, sp+$00
    sub [hl]
    jp nz, GetLdNumber_B9_notSingleDigit

    ld hl, sp+$0a
    ld a, [hl]
    ld hl, sp+$01
    sub [hl]
    jp nz, GetLdNumber_B9_notSingleDigit

    jr GetLdNumber_B9_checkVolRange

GetLdNumber_B9_notSingleDigit::
    jp GetLdNumber_B9_returnVol


GetLdNumber_B9_checkVolRange::
    ld a, c
    sub $01
    ld a, b
    sbc $00
    jp nc, GetLdNumber_B9_returnVol

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

GetLdNumber_B9_returnVol::
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    jp GetLdNumber_B9_epilogue


GetLdNumber_B9_defaultVol0::
    ld hl, sp+$07
    ld [hl], $00
    inc hl
    ld [hl], $00

GetLdNumber_B9_returnResult::
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]

GetLdNumber_B9_epilogue::
    add sp, $0b
    ret


; [ezgb]
; CheckFs_B9(fs, sect): FatFs check_fs. Frame -$06; MoveWindow sector; fail → E=$03 Jump_009_76f4.
; Jump_009_763d: win+$1FE boot sig $55AA; fail Jump_009_7669 E=$02; else Jump_009_766e check "FAT\0"@$36.
; Match → jr_009_76ab E=$00; else Jump_009_76a8→Jump_009_76b0 check "FAT32"@$52; match jr_009_76ed E=$00 else Jump_009_76ea→Jump_009_76f2 E=$01 (not FAT).
; Jump_009_76f4 epilogue (add sp,$06 / ret E).

CheckFs_B9::
    push af
    push af
    push af
    ld hl, sp+$08
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$04
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
    ld a, $00
    ld [bc], a
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $002e
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
    inc de
    ld a, $ff
    ld [de], a
    inc de
    ld a, $ff
    ld [de], a
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
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call MoveWindow_B9
    add sp, $06
    ld c, e
    xor a
    or c
    jp z, CheckFs_B9_checkBootSig

    ld e, $03
    jp CheckFs_B9_epilogue


CheckFs_B9_checkBootSig::
    ld hl, sp+$08
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, $0032
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $01fe
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
    sub $55
    jp nz, CheckFs_B9_noBootSig

    ld a, b
    sub $aa
    jp z, CheckFs_B9_checkFatStr

CheckFs_B9_noBootSig::
    ld e, $02
    jp CheckFs_B9_epilogue


CheckFs_B9_checkFatStr::
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0036
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
    ld [hl], $00
    ld hl, sp+$00
    ld a, [hl]
    sub $46
    jp nz, CheckFs_B9_notFat12Str

    inc hl
    ld a, [hl]
    sub $41
    jp nz, CheckFs_B9_notFat12Str

    inc hl
    ld a, [hl]
    sub $54
    jp nz, CheckFs_B9_notFat12Str

    inc hl
    ld a, [hl]
    or a
    jp nz, CheckFs_B9_notFat12Str

    jr CheckFs_B9_fatOk

CheckFs_B9_notFat12Str::
    jp CheckFs_B9_checkFat32Str


CheckFs_B9_fatOk::
    ld e, $00
    jp CheckFs_B9_epilogue


CheckFs_B9_checkFat32Str::
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0052
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
    ld [hl], $00
    ld hl, sp+$00
    ld a, [hl]
    sub $46
    jp nz, CheckFs_B9_notFat32Str

    inc hl
    ld a, [hl]
    sub $41
    jp nz, CheckFs_B9_notFat32Str

    inc hl
    ld a, [hl]
    sub $54
    jp nz, CheckFs_B9_notFat32Str

    inc hl
    ld a, [hl]
    or a
    jp nz, CheckFs_B9_notFat32Str

    jr CheckFs_B9_fat32Ok

CheckFs_B9_notFat32Str::
    jp CheckFs_B9_notFat


CheckFs_B9_fat32Ok::
    ld e, $00
    jp CheckFs_B9_epilogue


CheckFs_B9_notFat::
    ld e, $01

CheckFs_B9_epilogue::
    add sp, $06
    ret


; [ezgb]
; FindVolume stub (bank-9 near-call): FatFs find_volume front only; full mount in FindVolume_B5.
; Clear *rfs; GetLdNumber_B9: bit7→E=$0b Jump_009_7779; else Jump_009_7724: FatFs[vol] @$C5A5 null→E=$0c else Jump_009_773e.
; Jump_009_773e: bind *rfs; fs_type==0→Jump_009_7777; DiskStatus STA_NOINIT jr_009_7760→Jump_009_7777 else Jump_009_7763; mode0 Jump_009_7777 else WP jr_009_7772 E=$0a; Jump_009_7777 E=0 → Jump_009_7779 (add sp,$12 / ret).

FindVolume_B9::
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
    call GetLdNumber_B9
    add sp, $02
    ld b, d
    ld c, e
    ld a, b
    bit 7, a
    jp z, FindVolume_B9_lookupFs

    ld e, $0b
    jp FindVolume_B9_epilogue


FindVolume_B9_lookupFs::
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
    jp nz, FindVolume_B9_bindRfs

    ld e, $0c
    jp FindVolume_B9_epilogue


FindVolume_B9_bindRfs::
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
    jp z, FindVolume_B9_ok

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
    jr nz, FindVolume_B9_needInit

    jp FindVolume_B9_checkMode


FindVolume_B9_needInit::
    jp FindVolume_B9_ok


FindVolume_B9_checkMode::
    xor a
    ld hl, sp+$18
    or [hl]
    jp z, FindVolume_B9_ok

    ld a, c
    and $04
    jr nz, FindVolume_B9_writeProtect

    jp FindVolume_B9_ok


FindVolume_B9_writeProtect::
    ld e, $0a
    jp FindVolume_B9_epilogue


FindVolume_B9_ok::
    ld e, $00

FindVolume_B9_epilogue::
    add sp, $12
    ret


; [ezgb]
; Validate_B9(obj): FatFs validate. Push frame; reject null obj/fs, fs_type==0, or id mismatch → Jump_009_77f5 E=$09.
; obj->id vs fs->id mismatch → Jump_009_77da→Jump_009_77f5; jr_009_77dd DiskStatus&$01 set → jr_009_77f5 else Jump_009_77fa E=0.
; Jump_009_77fc add sp,$04 ret E.

Validate_B9::
    push af
    push af
    ld hl, sp+$06
    ld a, [hl+]
    or [hl]
    jp z, Validate_B9_invalid

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
    jp z, Validate_B9_invalid

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
    jp z, Validate_B9_invalid

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
    jp nz, Validate_B9_idMismatch

    inc hl
    ld a, [hl]
    sub b
    jp nz, Validate_B9_idMismatch

    jr Validate_B9_diskStatus

Validate_B9_idMismatch::
    jp Validate_B9_invalid


Validate_B9_diskStatus::
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
    jr nz, Validate_B9_invalid

    jp Validate_B9_ok


Validate_B9_invalid::
    ld e, $09
    jp Validate_B9_epilogue


Validate_B9_ok::
    ld e, $00

Validate_B9_epilogue::
    add sp, $04
    ret


; [ezgb]
; Open_B9(fp, path, mode): FatFs f_open. Frame -$47; RtcReadPage stash; sp+$46 holds E.
; FindVolume_B9(mode=1); err → Jump_009_7cb1. Init fp/dp; stamp $A9C5; FollowPath_B9.
; Follow err → Jump_009_7882; found → E=$08 (exist) → Jump_009_7882.
; Jump_009_7882: E==$04 (NO_FILE) → jr_009_788f else Jump_009_788c→Jump_009_78b3.
; jr_009_788f: ATTR_DIR → jr_009_78af E=$06 else Jump_009_78b3; Jump_009_78b3: E==$04 → jr_009_78c0 create else Jump_009_78bd→Jump_009_7cb1.
; jr_009_78c0: CreateChain_B9; cluster zero → Jump_009_7915 E=$07; cluster−1 zero → jr_009_7934 E=$02 else Jump_009_7931→Jump_009_7938.
; Jump_009_7938: cluster+1 wrap → jr_009_7956 E=$01 else Jump_009_7953→Jump_009_795a; ok SyncWindow_B9 Jump_009_7976.
; Jump_009_7976: err → Jump_009_7ba0 else Clust2Sect + MemSet16 dir buf + StClust + timestamp/attr copy.
; Attr==$03 → jr_009_7a87 else Jump_009_7a84→Jump_009_7ad7; size match → jr_009_7ad0 zero fsize else Jump_009_7acd→Jump_009_7ad7.
; Jump_009_7ad7: StClust + store cluster; Jump_009_7b17: LFN ord loop (jr_009_7b54) SyncWindow → Jump_009_7ba0.
; Jump_009_7ba0: E=0 DirRegister_B9; Jump_009_7bb5 RetStub; err RemoveChain_B9 → Jump_009_7cb1.
; Jump_009_7c07: ok path FA|$10, StClust, SyncFs_B9, RetStub → Jump_009_7cb1 add sp,$47 ret E.

Open_B9::
    add sp, -$47
    call RtcReadPage
    push hl
    ld hl, sp+$1c
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$4d
    ld a, l
    ld d, h
    ld hl, sp+$0c
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$2c
    ld c, l
    ld b, h
    ld a, $01
    push af
    inc sp
    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call FindVolume_B9
    add sp, $05
    ld c, e
    ld hl, sp+$46
    ld [hl], c
    xor a
    or [hl]
    jp nz, Open_B9_epilogue

    ld hl, sp+$2c
    ld c, l
    ld b, h
    ld hl, $0014
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$0e
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$08
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld hl, $0016
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $a9
    ld [de], a
    inc de
    ld a, $c5
    ld [de], a
    ld hl, sp+$4d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call FollowPath_B9
    add sp, $04
    ld b, e
    ld hl, sp+$46
    ld [hl], b
    xor a
    or [hl]
    jp nz, Open_B9_afterFollow

    ld [hl], $08

Open_B9_afterFollow::
    ld hl, sp+$46
    ld a, [hl]
    sub $04
    jp nz, Open_B9_notNoFile

    jr Open_B9_noFileCheckDir

Open_B9_notNoFile::
    jp Open_B9_checkCreate


Open_B9_noFileCheckDir::
    ld hl, sp+$2c
    ld c, l
    ld b, h
    ld hl, $0014
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
    ld hl, $000b
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    and $20
    jr nz, Open_B9_deniedIsDir

    jp Open_B9_checkCreate


Open_B9_deniedIsDir::
    ld hl, sp+$46
    ld [hl], $06

Open_B9_checkCreate::
    ld hl, sp+$46
    ld a, [hl]
    sub $04
    jp nz, Open_B9_openFail

    jr Open_B9_createChain

Open_B9_openFail::
    jp Open_B9_epilogue


Open_B9_createChain::
    ld hl, sp+$2c
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, $0000
    push hl
    ld hl, $0000
    push hl
    push bc
    call CreateChain_B9
    add sp, $06
    push hl
    ld hl, sp+$24
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$46
    ld [hl], $00
    ld hl, $0000
    push hl
    ld hl, $4413
    push hl
    call RetStub_B9
    add sp, $04
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
    call RetStub_B9
    add sp, $04
    ld hl, sp+$22
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, Open_B9_afterCreateChain

    ld hl, sp+$46
    ld [hl], $07

Open_B9_afterCreateChain::
    ld hl, sp+$22
    ld a, [hl]
    sub $01
    jp nz, Open_B9_newClustOk

    inc hl
    ld a, [hl]
    or a
    jp nz, Open_B9_newClustOk

    inc hl
    ld a, [hl]
    or a
    jp nz, Open_B9_newClustOk

    inc hl
    ld a, [hl]
    or a
    jp nz, Open_B9_newClustOk

    jr Open_B9_diskErr

Open_B9_newClustOk::
    jp Open_B9_checkClustWrap


Open_B9_diskErr::
    ld hl, sp+$46
    ld [hl], $02

Open_B9_checkClustWrap::
    ld hl, sp+$22
    ld a, [hl]
    inc a
    jp nz, Open_B9_clustWrapOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, Open_B9_clustWrapOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, Open_B9_clustWrapOk

    inc hl
    ld a, [hl]
    inc a
    jp nz, Open_B9_clustWrapOk

    jr Open_B9_intErr

Open_B9_clustWrapOk::
    jp Open_B9_syncWindow


Open_B9_intErr::
    ld hl, sp+$46
    ld [hl], $01

Open_B9_syncWindow::
    xor a
    ld hl, sp+$46
    or [hl]
    jp nz, Open_B9_afterSync

    ld hl, sp+$2c
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
    call SyncWindow_B9
    add sp, $02
    ld c, e
    ld hl, sp+$46
    ld [hl], c

Open_B9_afterSync::
    xor a
    ld hl, sp+$46
    or [hl]
    jp nz, Open_B9_dirRegister

    ld hl, sp+$2c
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
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
    push bc
    call Clust2Sect_B9
    add sp, $06
    push hl
    ld hl, sp+$28
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$2c
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, $0032
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$2a
    ld [hl+], a
    ld [hl], d
    ld hl, $0200
    push hl
    ld h, $00
    push hl
    ld hl, sp+$2e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call MemSet16_B9
    add sp, $06
    ld hl, $000b
    push hl
    ld l, $20
    push hl
    ld hl, sp+$2e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call MemSet16_B9
    add sp, $06
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $2e
    ld [de], a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000b
    add hl, de
    ld c, l
    ld b, h
    ld a, $10
    ld [bc], a
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0016
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
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
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
    ld hl, sp+$2e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call StClust_B9
    add sp, $06
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0020
    add hl, de
    ld c, l
    ld b, h
    ld a, $20
    push af
    inc sp
    ld hl, sp+$2b
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call MemCpy16_B9
    add sp, $05
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0021
    add hl, de
    ld c, l
    ld b, h
    ld a, $2e
    ld [bc], a
    ld hl, sp+$2c
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    dec hl
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
    ld hl, sp+$1e
    ld [hl+], a
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
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld a, [bc]
    ld c, a
    sub $03
    jp nz, Open_B9_attrNotTrunc

    jr Open_B9_truncAttr

Open_B9_attrNotTrunc::
    jp Open_B9_stClustStore


Open_B9_truncAttr::
    ld hl, sp+$2c
    ld c, l
    ld b, h
    ld e, c
    ld d, b
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
    ld hl, sp+$1e
    ld a, [hl]
    ld hl, sp+$04
    sub [hl]
    jp nz, Open_B9_sizeMismatch

    ld hl, sp+$1f
    ld a, [hl]
    ld hl, sp+$05
    sub [hl]
    jp nz, Open_B9_sizeMismatch

    ld hl, sp+$20
    ld a, [hl]
    ld hl, sp+$06
    sub [hl]
    jp nz, Open_B9_sizeMismatch

    ld hl, sp+$21
    ld a, [hl]
    ld hl, sp+$07
    sub [hl]
    jp nz, Open_B9_sizeMismatch

    jr Open_B9_zeroFsize

Open_B9_sizeMismatch::
    jp Open_B9_stClustStore


Open_B9_zeroFsize::
    xor a
    ld hl, sp+$1e
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

Open_B9_stClustStore::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0020
    add hl, de
    ld c, l
    ld b, h
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
    call StClust_B9
    add sp, $06
    ld hl, sp+$2c
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    inc bc
    inc bc
    ld a, [bc]
    ld c, a
    ld hl, sp+$26
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
    ld hl, sp+$08
    ld [hl], c

Open_B9_lfnOrdLoop::
    xor a
    ld hl, sp+$08
    or [hl]
    jp z, Open_B9_dirRegister

    ld hl, sp+$2c
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$0a
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl-], a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $002e
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld d, h
    ld e, l
    ld hl, sp+$00
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
    ld hl, sp+$04
    inc [hl]
    jr nz, Open_B9_lfnOrdCont

    inc hl
    inc [hl]
    jr nz, Open_B9_lfnOrdCont

    inc hl
    inc [hl]
    jr nz, Open_B9_lfnOrdCont

    inc hl
    inc [hl]

Open_B9_lfnOrdCont::
    ld e, c
    ld d, b
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
    call SyncWindow_B9
    add sp, $02
    ld c, e
    ld hl, sp+$46
    ld [hl], c
    xor a
    or [hl]
    jp nz, Open_B9_dirRegister

    ld hl, $0200
    push hl
    ld h, $00
    push hl
    ld hl, sp+$2e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call MemSet16_B9
    add sp, $06
    ld hl, sp+$08
    dec [hl]
    jp Open_B9_lfnOrdLoop


Open_B9_dirRegister::
    xor a
    ld hl, sp+$46
    or [hl]
    jp nz, Open_B9_regFailCleanup

    ld hl, sp+$2c
    ld c, l
    ld b, h
    push bc
    call DirRegister_B9
    add sp, $02
    ld c, e
    ld hl, sp+$46
    ld [hl], c

Open_B9_regFailCleanup::
    ld hl, $0000
    push hl
    ld hl, $3333
    push hl
    call RetStub_B9
    add sp, $04
    ld hl, sp+$46
    ld a, [hl]
    ld hl, sp+$00
    ld [hl+], a
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
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call RetStub_B9
    add sp, $04
    xor a
    ld hl, sp+$46
    or [hl]
    jp z, Open_B9_okPath

    ld hl, sp+$2c
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
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
    push bc
    call RemoveChain_B9
    add sp, $06
    jp Open_B9_epilogue


Open_B9_okPath::
    ld hl, sp+$2c
    ld c, l
    ld b, h
    ld hl, $0012
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
    ld hl, sp+$2a
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
    ld a, $10
    ld [bc], a
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0016
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
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
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
    ld hl, sp+$2e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call StClust_B9
    add sp, $06
    ld hl, sp+$2c
    ld c, l
    ld b, h
    ld e, c
    ld d, b
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
    call SyncFs_B9
    add sp, $02
    ld c, e
    ld hl, sp+$46
    ld [hl], c
    ld hl, $0000
    push hl
    ld hl, $2222
    push hl
    call RetStub_B9
    add sp, $04
    ld hl, sp+$46
    ld a, [hl]
    ld hl, sp+$00
    ld [hl+], a
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
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call RetStub_B9
    add sp, $04

Open_B9_epilogue::
    ld hl, sp+$46
    ld e, [hl]
    add sp, $47
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
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
