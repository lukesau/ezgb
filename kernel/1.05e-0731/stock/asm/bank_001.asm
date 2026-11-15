; Disassembly of "kernel.gb"
; This file was created with:
; mgbdis v3.0 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $001", ROMX[$4000], BANK[$1]

; $4000-$5736: src/bank1.c
INCLUDE "b1_code.inc"


; [ezgb]
; BuildSaverBackupPath: sits between BackupOpenSaverPath and LaunchSetup in bank 1 (right
; after SaverDirSlashStr). Double loop (outer/inner) walking a table via WRAM pointer
; $c2a0/$c2a1, FarCallTrampoline + Memcpy($ff bytes) into $c0a0, size-limited against
; $e800. Reasonable inference from control flow and the Memcpy/FarCallTrampoline calls;
; exact role and caller not independently confirmed — named from shape + neighboring
; context, not a traced call site.

BuildSaverBackupPath::
    add sp, -$0e
    ld a, $01
    ld hl, sp+$14
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp nc, BuildSaverBackupPath_epilogue

    ld bc, CStrCat_B1
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

BuildSaverBackupPath_outerLoop::
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
    jp nc, BuildSaverBackupPath_epilogue

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

BuildSaverBackupPath_innerLoop::
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
    jp nc, BuildSaverBackupPath_outerNext

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
    call FarCallTrampoline
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
    jp nc, BuildSaverBackupPath_innerNext

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
    call Memcpy
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
    call Memcpy
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
    call Memcpy
    add sp, $06

BuildSaverBackupPath_innerNext::
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
    jr nz, BuildSaverBackupPath_innerContinue

    inc hl
    inc [hl]

BuildSaverBackupPath_innerContinue::
    jp BuildSaverBackupPath_innerLoop


BuildSaverBackupPath_outerNext::
    ld hl, sp+$0c
    inc [hl]
    jr nz, BuildSaverBackupPath_outerContinue

    inc hl
    inc [hl]

BuildSaverBackupPath_outerContinue::
    jp BuildSaverBackupPath_outerLoop


BuildSaverBackupPath_epilogue::
    add sp, $0e
    ret


; [ezgb]
; LaunchSetup(path): Open_B6 → FIL@sp+$20; fail DE:HL=$ffffffff Jump_001_5c02. After BackupOpenSaverPath; see docs/boot-and-launch.md.
; Jump_001_58f9: $c7a9==2 → Jump_001_5905/jr_001_5908 FAT12 limit $0000ffff else Jump_001_5918 $0ffffff7; join Jump_001_5925 seed FarCall_05_4279 @$c0a0.
; Jump_001_59e4: walk clusters FarCall_05_4378 (jr_001_5a2c); EOF → Jump_001_5b12 else Jump_001_5a72 U32Mul*$c7ab + 4279 append.
; Jump_001_5b12: if sum<limit → Jump_001_59e4 else close 768f + stamp footer @$c0a0+$1f0/+1f4/+1f8 → Jump_001_5c02 ret 0.

LaunchSetup::
    ld hl, $fdbc
    add hl, sp
    ld sp, hl
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
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
    call FarCall_06_7309
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
    jp z, LaunchSetup_fatTypeCheck

    ld de, $ffff
    ld hl, $ffff
    jp LaunchSetup_epilogueRet


LaunchSetup_fatTypeCheck::
    ld de, $c7a9
    ld a, [de]
    ld c, a
    sub $02
    jp nz, LaunchSetup_skipFat12

    jr LaunchSetup_fat12Limit

LaunchSetup_skipFat12::
    jp LaunchSetup_fatOtherLimit


LaunchSetup_fat12Limit::
    ld hl, sp+$0e
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp LaunchSetup_seedClust2Sect


LaunchSetup_fatOtherLimit::
    ld hl, sp+$0e
    ld [hl], $f7
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $0f

LaunchSetup_seedClust2Sect::
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
    call FarCall_05_4279
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

LaunchSetup_walkClusters::
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
    call FarCall_05_4378
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
    jr nz, LaunchSetup_walkCont

    inc hl
    inc [hl]
    jr nz, LaunchSetup_walkCont

    inc hl
    inc [hl]
    jr nz, LaunchSetup_walkCont

    inc hl
    inc [hl]

LaunchSetup_walkCont::
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
    jp nz, LaunchSetup_appendCluster

    ld hl, sp+$1b
    ld a, [hl]
    ld hl, sp+$05
    sub [hl]
    jp nz, LaunchSetup_appendCluster

    ld hl, sp+$1c
    ld a, [hl]
    ld hl, sp+$06
    sub [hl]
    jp nz, LaunchSetup_appendCluster

    ld hl, sp+$1d
    ld a, [hl]
    ld hl, sp+$07
    sub [hl]
    jp z, LaunchSetup_eofCheck

LaunchSetup_appendCluster::
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
    call FarCall_05_4279
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

LaunchSetup_eofCheck::
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
    jp c, LaunchSetup_walkClusters

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
    call FarCall_03_768f
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

LaunchSetup_epilogueRet::
    ld hl, $0244
    add hl, sp
    ld sp, hl
    ret


; [ezgb]
; MapCartTypeToUi(type@sp+$02): cart byte → $d3eb UI bucket + battery/timer/rumble flags. Feeds DrawCardTypeScreen / launch.
; Buckets → $d3eb: Jump_001_5d11=$0; Jump_001_5d19=$1; Jump_001_5d21=$2; Jump_001_5d29=$3; Jump_001_5d31=$4; Jump_001_5d39/Jump_001_5d41=$6; join Jump_001_5d46.
; Jump_001_5d46: battery types → Jump_001_5db2/jr_001_5db2 $d3ef=1 else Jump_001_5daf → Jump_001_5dba=0; then Jump_001_5dbf.
; Jump_001_5dbf: $0f/$10 → Jump_001_5dd4/jr_001_5dd4 $d3f0=1 else Jump_001_5dd1 → Jump_001_5ddc=0; Jump_001_5de1.
; Jump_001_5de1: $1c..$1e jp-table → Jump_001_5e06 $d3f1=1 else Jump_001_5e0e=0; Jump_001_5e13 ret. Falls into RomLoaderMain.

MapCartTypeToUi::
    ld hl, sp+$02
    ld a, [hl]
    or a
    jp z, MapCartTypeToUi_bucket0

    ld hl, sp+$02
    ld a, [hl]
    sub $01
    jp z, MapCartTypeToUi_bucket1

    ld hl, sp+$02
    ld a, [hl]
    sub $02
    jp z, MapCartTypeToUi_bucket1

    ld hl, sp+$02
    ld a, [hl]
    sub $03
    jp z, MapCartTypeToUi_bucket1

    ld hl, sp+$02
    ld a, [hl]
    sub $05
    jp z, MapCartTypeToUi_bucket2

    ld hl, sp+$02
    ld a, [hl]
    sub $06
    jp z, MapCartTypeToUi_bucket2

    ld hl, sp+$02
    ld a, [hl]
    sub $08
    jp z, MapCartTypeToUi_bucket0

    ld hl, sp+$02
    ld a, [hl]
    sub $09
    jp z, MapCartTypeToUi_bucket0

    ld hl, sp+$02
    ld a, [hl]
    sub $0b
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $0c
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $0d
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $0f
    jp z, MapCartTypeToUi_bucket3

    ld hl, sp+$02
    ld a, [hl]
    sub $10
    jp z, MapCartTypeToUi_bucket3

    ld hl, sp+$02
    ld a, [hl]
    sub $11
    jp z, MapCartTypeToUi_bucket3

    ld hl, sp+$02
    ld a, [hl]
    sub $12
    jp z, MapCartTypeToUi_bucket3

    ld hl, sp+$02
    ld a, [hl]
    sub $13
    jp z, MapCartTypeToUi_bucket3

    ld hl, sp+$02
    ld a, [hl]
    sub $15
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $16
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $17
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $19
    jp z, MapCartTypeToUi_bucket4

    ld hl, sp+$02
    ld a, [hl]
    sub $1a
    jp z, MapCartTypeToUi_bucket4

    ld hl, sp+$02
    ld a, [hl]
    sub $1b
    jp z, MapCartTypeToUi_bucket4

    ld hl, sp+$02
    ld a, [hl]
    sub $1c
    jp z, MapCartTypeToUi_bucket4

    ld hl, sp+$02
    ld a, [hl]
    sub $1d
    jp z, MapCartTypeToUi_bucket4

    ld hl, sp+$02
    ld a, [hl]
    sub $1e
    jp z, MapCartTypeToUi_bucket4

    ld hl, sp+$02
    ld a, [hl]
    sub $22
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $55
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $56
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $ea
    jp z, MapCartTypeToUi_bucket1

    ld hl, sp+$02
    ld a, [hl]
    sub $fc
    jp z, MapCartTypeToUi_bucket3

    ld hl, sp+$02
    ld a, [hl]
    sub $fd
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $fe
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    inc a
    jp z, MapCartTypeToUi_bucket1

    jp MapCartTypeToUi_bucket6b


MapCartTypeToUi_bucket0::
    ld hl, $d3eb
    ld [hl], $00
    jp MapCartTypeToUi_batteryCheck


MapCartTypeToUi_bucket1::
    ld hl, $d3eb
    ld [hl], $01
    jp MapCartTypeToUi_batteryCheck


MapCartTypeToUi_bucket2::
    ld hl, $d3eb
    ld [hl], $02
    jp MapCartTypeToUi_batteryCheck


MapCartTypeToUi_bucket3::
    ld hl, $d3eb
    ld [hl], $03
    jp MapCartTypeToUi_batteryCheck


MapCartTypeToUi_bucket4::
    ld hl, $d3eb
    ld [hl], $04
    jp MapCartTypeToUi_batteryCheck


MapCartTypeToUi_bucket6a::
    ld hl, $d3eb
    ld [hl], $06
    jp MapCartTypeToUi_batteryCheck


MapCartTypeToUi_bucket6b::
    ld hl, $d3eb
    ld [hl], $06

MapCartTypeToUi_batteryCheck::
    ld hl, sp+$02
    ld a, [hl]
    sub $03
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $06
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $09
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $0d
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $0f
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $10
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $13
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $17
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $1b
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $1e
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $22
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $fd
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    inc a
    jp nz, MapCartTypeToUi_batterySkip

    jr MapCartTypeToUi_batterySet

MapCartTypeToUi_batterySkip::
    jp MapCartTypeToUi_batteryClear


MapCartTypeToUi_batterySet::
    ld hl, $d3ef
    ld [hl], $01
    jp MapCartTypeToUi_timerCheck


MapCartTypeToUi_batteryClear::
    ld hl, $d3ef
    ld [hl], $00

MapCartTypeToUi_timerCheck::
    ld hl, sp+$02
    ld a, [hl]
    sub $0f
    jp z, MapCartTypeToUi_timerSet

    ld hl, sp+$02
    ld a, [hl]
    sub $10
    jp nz, MapCartTypeToUi_timerSkip

    jr MapCartTypeToUi_timerSet

MapCartTypeToUi_timerSkip::
    jp MapCartTypeToUi_timerClear


MapCartTypeToUi_timerSet::
    ld hl, $d3f0
    ld [hl], $01
    jp MapCartTypeToUi_rumbleCheck


MapCartTypeToUi_timerClear::
    ld hl, $d3f0
    ld [hl], $00

MapCartTypeToUi_rumbleCheck::
    ld hl, sp+$02
    ld a, [hl]
    sub $1c
    jp c, MapCartTypeToUi_rumbleClear

    ld a, $1e
    sub [hl]
    jp c, MapCartTypeToUi_rumbleClear

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


    jp MapCartTypeToUi_rumbleSet


    jp MapCartTypeToUi_rumbleSet


    jp MapCartTypeToUi_rumbleSet


MapCartTypeToUi_rumbleSet::
    ld hl, $d3f1
    ld [hl], $01
    jp MapCartTypeToUi_ret


MapCartTypeToUi_rumbleClear::
    ld hl, $d3f1
    ld [hl], $00

MapCartTypeToUi_ret::
    ret


; [ezgb]
; RomLoaderMain(path@sp+$1c): Open_B6 → $ca0f; fail E=$ff Jump_001_601b. See docs/boot-and-launch.md.
; Jump_001_5e56: fsize→$c2a4/$c2a5; seek0; read $200 hdr@$c0a0; Jump_001_5ec8 checksum $134..$14c → $c5a3 (jr_001_5ef2).
; Jump_001_5ef5: hdr cart/ROM/RAM → $d3ec/$d3ed/$d3ee + MapCartTypeToUi; if $d3eb!=1 Jump_001_5f2a → Jump_001_600f else jr_001_5f2d size gate.
; Jump_001_5f6a: XOR-fold bytes (jr_001_5fe5); Jump_001_5fe8 cmp LE $e06c8834; hit jr_001_600a $d3eb=$05 (MBC1m) else Jump_001_6007; Jump_001_600f close ret E=status.

RomLoaderMain::
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
    call SetFpgaPage_B1
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
    call FarCall_06_7309
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
    jp z, RomLoaderMain_readHdr

    ld e, $ff
    jp RomLoaderMain_failRetFf


RomLoaderMain_readHdr::
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
    call FarCall_03_76cc
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
    call FarCall_06_779a
    add sp, $08
    ld hl, $c5a3
    ld [hl], $00
    ld hl, sp+$0d
    ld [hl], $34
    inc hl
    ld [hl], $01

RomLoaderMain_checksumLoop::
    ld a, $4c
    ld hl, sp+$0d
    sub [hl]
    ld a, $01
    inc hl
    sbc [hl]
    jp c, RomLoaderMain_mapCartType

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
    jr nz, RomLoaderMain_checksumCont

    inc hl
    inc [hl]

RomLoaderMain_checksumCont::
    jp RomLoaderMain_checksumLoop


RomLoaderMain_mapCartType::
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
    call MapCartTypeToUi
    add sp, $01
    ld hl, $d3eb
    ld a, [hl]
    sub $01
    jp nz, RomLoaderMain_skipSizeGate

    jr RomLoaderMain_sizeGate

RomLoaderMain_skipSizeGate::
    jp RomLoaderMain_closeRet


RomLoaderMain_sizeGate::
    ld a, $20
    ld hl, $c2a4
    sub [hl]
    ld a, $00
    ld hl, $c2a5
    sbc [hl]
    jp nc, RomLoaderMain_closeRet

    ld hl, $0004
    push hl
    ld hl, $0000
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_03_76cc
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
    call FarCall_06_779a
    add sp, $08
    ld hl, sp+$0d
    ld [hl], $04
    inc hl
    ld [hl], $01

RomLoaderMain_xorFold::
    ld a, $33
    ld hl, sp+$0d
    sub [hl]
    ld a, $01
    inc hl
    sbc [hl]
    jp c, RomLoaderMain_cmpMagic

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
    jr nz, RomLoaderMain_xorFoldCont

    inc hl
    inc [hl]

RomLoaderMain_xorFoldCont::
    jp RomLoaderMain_xorFold


RomLoaderMain_cmpMagic::
    ld hl, sp+$08
    ld a, [hl]
    sub $34
    jp nz, RomLoaderMain_skipMbc1m

    inc hl
    ld a, [hl]
    sub $88
    jp nz, RomLoaderMain_skipMbc1m

    inc hl
    ld a, [hl]
    sub $6c
    jp nz, RomLoaderMain_skipMbc1m

    inc hl
    ld a, [hl]
    sub $e0
    jp nz, RomLoaderMain_skipMbc1m

    jr RomLoaderMain_setMbc1m

RomLoaderMain_skipMbc1m::
    jp RomLoaderMain_closeRet


RomLoaderMain_setMbc1m::
    ld hl, $d3eb
    ld [hl], $05

RomLoaderMain_closeRet::
    ld hl, $ca0f
    push hl
    call FarCall_03_768f
    add sp, $02
    ld hl, sp+$11
    ld e, [hl]

RomLoaderMain_failRetFf::
    add sp, $15
    ret


; [ezgb]
; DrawCardTypeScreen: panel + CardtypeStr; $d3eb jp-table → MBC name ApplyBasename into sp+$0a then DrawString.
; MBC arms: Jump_001_606c, Jump_001_607d, Jump_001_608e, Jump_001_609f, Jump_001_60b0, Jump_001_60c1, Jump_001_60d2 → join Jump_001_60e0.
; Jump_001_60e0: ROM 32<<n KB (jr_001_6117/jr_001_611b) U32ToAscii+SizeKbStr; RAM Jump_001_619e=0, Jump_001_61a3=8, Jump_001_61a8=$80, Jump_001_61ad=$20 → Jump_001_61af.
; Jump_001_622e: $d3ef NoStr else YesStr; Jump_001_623f ReadJoypad; jr_001_624d/Jump_001_6250 until A/B; Jump_001_6258/jr_001_6258 ret.

DrawCardTypeScreen::
    add sp, -$1e
    call DrawInfoPanelRect
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $2a25
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, CardtypeStr
    push hl
    call DrawString
    add sp, $05
    ld a, $06
    ld hl, $d3eb
    sub [hl]
    jp c, DrawCardTypeScreen_afterMbc

    ld hl, $d3eb
    ld e, [hl]
    ld d, $00
    ld hl, $6057
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp DrawCardTypeScreen_mbcNone


    jp DrawCardTypeScreen_mbc1


    jp DrawCardTypeScreen_mbc2


    jp DrawCardTypeScreen_mbc3


    jp DrawCardTypeScreen_mbc5


    jp DrawCardTypeScreen_mbc1m


    jp DrawCardTypeScreen_mbcNot


DrawCardTypeScreen_mbcNone::
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, MbcNoneStr
    push hl
    push bc
    call ApplyBasename
    add sp, $04
    jp DrawCardTypeScreen_afterMbc


DrawCardTypeScreen_mbc1::
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, Mbc1Str
    push hl
    push bc
    call ApplyBasename
    add sp, $04
    jp DrawCardTypeScreen_afterMbc


DrawCardTypeScreen_mbc2::
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, Mbc2Str
    push hl
    push bc
    call ApplyBasename
    add sp, $04
    jp DrawCardTypeScreen_afterMbc


DrawCardTypeScreen_mbc3::
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, Mbc3Str
    push hl
    push bc
    call ApplyBasename
    add sp, $04
    jp DrawCardTypeScreen_afterMbc


DrawCardTypeScreen_mbc5::
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, Mbc5Str
    push hl
    push bc
    call ApplyBasename
    add sp, $04
    jp DrawCardTypeScreen_afterMbc


DrawCardTypeScreen_mbc1m::
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, Mbc1mStr
    push hl
    push bc
    call ApplyBasename
    add sp, $04
    jp DrawCardTypeScreen_afterMbc


DrawCardTypeScreen_mbcNot::
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, MbcNotStr
    push hl
    push bc
    call ApplyBasename
    add sp, $04

DrawCardTypeScreen_afterMbc::
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, S32DivImpl_epilogueRet
    push hl
    ld a, $00
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05
    ld hl, $3625
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, RomSizeLabelStr
    push hl
    call DrawString
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
    jr DrawCardTypeScreen_romShiftDone

DrawCardTypeScreen_romShiftLoop::
    sla c
    rl b

DrawCardTypeScreen_romShiftDone::
    dec a
    jr nz, DrawCardTypeScreen_romShiftLoop

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
    call U32ToAscii_B0
    add sp, $07
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, SizeKbStr
    push hl
    push bc
    call FarCallTrampoline
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
    call DrawString
    add sp, $05
    ld hl, $4225
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, RamSizeLabelStr
    push hl
    call DrawString
    add sp, $05
    ld hl, $d3ed
    ld a, [hl]
    or a
    jp z, DrawCardTypeScreen_ram0

    ld hl, $d3ed
    ld a, [hl]
    sub $01
    jp z, DrawCardTypeScreen_ram8

    ld hl, $d3ed
    ld a, [hl]
    sub $02
    jp z, DrawCardTypeScreen_ram8

    ld hl, $d3ed
    ld a, [hl]
    sub $04
    jp z, DrawCardTypeScreen_ram80

    jp DrawCardTypeScreen_ram20


DrawCardTypeScreen_ram0::
    ld c, $00
    jp DrawCardTypeScreen_afterRam


DrawCardTypeScreen_ram8::
    ld c, $08
    jp DrawCardTypeScreen_afterRam


DrawCardTypeScreen_ram80::
    ld c, $80
    jp DrawCardTypeScreen_afterRam


DrawCardTypeScreen_ram20::
    ld c, $20

DrawCardTypeScreen_afterRam::
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
    call U32ToAscii_B0
    add sp, $07
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, SizeKbStr
    push hl
    push bc
    call FarCallTrampoline
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
    call DrawString
    add sp, $05
    ld hl, $4e25
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, BatteryLabelStr
    push hl
    call DrawString
    add sp, $05
    xor a
    ld hl, $d3ef
    or [hl]
    jp z, DrawCardTypeScreen_batteryNo

    ld hl, $4e5c
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, BatteryYesStr
    push hl
    call DrawString
    add sp, $05
    jp DrawCardTypeScreen_waitJoypad


DrawCardTypeScreen_batteryNo::
    ld hl, $4e5c
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, BatteryNoStr
    push hl
    call DrawString
    add sp, $05

DrawCardTypeScreen_waitJoypad::
    call ReadJoypad
    ld c, e
    ld b, $00
    ld a, c
    and $10
    jr nz, DrawCardTypeScreen_waitA

    jp DrawCardTypeScreen_waitB


DrawCardTypeScreen_waitA::
    jp DrawCardTypeScreen_epilogueRet


DrawCardTypeScreen_waitB::
    ld a, c
    and $20
    jr nz, DrawCardTypeScreen_epilogueRet

    jp DrawCardTypeScreen_waitJoypad


DrawCardTypeScreen_epilogueRet::
    add sp, $1e
    ret


CardtypeStr::
    db "Cardtype:", $00

MbcNoneStr::
    db "NoMBC", $00

Mbc1Str::
    db "MBC1", $00

Mbc2Str::
    db "MBC2", $00

Mbc3Str::
    db "MBC3", $00

Mbc5Str::
    db "MBC5", $00

Mbc1mStr::
    db "MBC1M", $00

MbcNotStr::
    db "Not", $00

RomSizeLabelStr::
    db "ROM size:", $00

SizeKbStr::
    db "KB", $00

RamSizeLabelStr::
    db "RAM size:", $00

BatteryLabelStr::
    db "Battery :", $00

BatteryYesStr::
    db "Yes", $00

BatteryNoStr::
    db "No", $00

; [ezgb]
; DrawInfoPanelRect: StoreDrawParams($0002,$03) then DrawRect fill=$23 corners $7d25/$016c.
; Shared chrome behind Cardtype/BOOT/ROM-info style screens.

DrawInfoPanelRect::
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
    ret


; [ezgb]
; BootRomInfoMenu: locals sel@sp+$02 (0=BOOT/1=ROM INFO), redraw@sp+$03. Jump_001_62d9 DrawInfoPanelRect; Jump_001_62dc hilite BOOT strings.
; Jump_001_6328: ROM INFO ink twin. Jump_001_6364 ReadJoypad: $04 jr_001_637b sel-- → Jump_001_6386; $08 jr_001_6390 sel++ → Jump_001_63a3.
; $10 jr_001_63ad: sel==1 jr_001_63ba DrawCardTypeScreen → Jump_001_62d9; else Jump_001_63b7 → Jump_001_63e2 LoadingStr.
; $20 Jump_001_63c7/jr_001_63d1 E=$ff → Jump_001_6421; else Jump_001_63d6 Delay → Jump_001_62dc. Jump_001_63e2 Loading then Jump_001_6421 ret E=sel.

BootRomInfoMenu::
    push af
    push af
    ld hl, sp+$03
    ld [hl], $01
    dec hl
    ld [hl], $00

BootRomInfoMenu_drawPanel::
    call DrawInfoPanelRect

BootRomInfoMenu_hiliteBoot::
    xor a
    ld hl, sp+$03
    or [hl]
    jp z, BootRomInfoMenu_inputLoop

    xor a
    dec hl
    or [hl]
    jp nz, BootRomInfoMenu_romInfoInk

    ld hl, $0002
    push hl
    ld a, $01
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $2a25
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, BootMenuBootStr
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
    ld hl, $3a25
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, BootMenuRomInfoStr
    push hl
    call DrawString
    add sp, $05
    jp BootRomInfoMenu_inputLoop


BootRomInfoMenu_romInfoInk::
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $2a25
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, BootMenuBootStr
    push hl
    call DrawString
    add sp, $05
    ld hl, $0002
    push hl
    ld a, $01
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $3a25
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, BootMenuRomInfoStr
    push hl
    call DrawString
    add sp, $05

BootRomInfoMenu_inputLoop::
    ld hl, sp+$03
    ld [hl], $00
    call ReadJoypad
    ld c, e
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], $00
    dec hl
    ld a, [hl]
    and $04
    jr nz, BootRomInfoMenu_selDec

    jp BootRomInfoMenu_afterSelDec


BootRomInfoMenu_selDec::
    xor a
    ld hl, sp+$02
    or [hl]
    jp z, BootRomInfoMenu_afterSelDec

    dec [hl]
    inc hl
    ld [hl], $01

BootRomInfoMenu_afterSelDec::
    ld hl, sp+$00
    ld a, [hl]
    and $08
    jr nz, BootRomInfoMenu_selInc

    jp BootRomInfoMenu_afterSelInc


BootRomInfoMenu_selInc::
    ld hl, sp+$02
    ld c, [hl]
    ld b, $00
    ld a, c
    sub $01
    ld a, b
    sbc $00
    rlca
    jp nc, BootRomInfoMenu_afterSelInc

    inc [hl]
    inc hl
    ld [hl], $01

BootRomInfoMenu_afterSelInc::
    ld hl, sp+$00
    ld a, [hl]
    and $10
    jr nz, BootRomInfoMenu_confirmA

    jp BootRomInfoMenu_checkB


BootRomInfoMenu_confirmA::
    ld hl, sp+$02
    ld a, [hl]
    sub $01
    jp nz, BootRomInfoMenu_bootLoading

    jr BootRomInfoMenu_romInfoScreen

BootRomInfoMenu_bootLoading::
    jp BootRomInfoMenu_loadingStr


BootRomInfoMenu_romInfoScreen::
    call DrawCardTypeScreen
    ld hl, sp+$03
    ld [hl], $01
    dec hl
    ld [hl], $00
    jp BootRomInfoMenu_drawPanel


BootRomInfoMenu_checkB::
    ld hl, sp+$00
    ld a, [hl]
    and $20
    jr nz, BootRomInfoMenu_cancelRetFf

    jp BootRomInfoMenu_delayRedraw


BootRomInfoMenu_cancelRetFf::
    ld e, $ff
    jp BootRomInfoMenu_epilogueRet


BootRomInfoMenu_delayRedraw::
    ld hl, $0064
    push hl
    call Delay
    add sp, $02
    jp BootRomInfoMenu_hiliteBoot


BootRomInfoMenu_loadingStr::
    ld hl, $0000
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $018f
    push hl
    ld hl, $9f00
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
    ld hl, $4133
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, BootMenuLoadingStr
    push hl
    call DrawString
    add sp, $05
    ld hl, sp+$02
    ld e, [hl]

BootRomInfoMenu_epilogueRet::
    add sp, $04
    ret


BootMenuBootStr::
    db "BOOT", $00

BootMenuRomInfoStr::
    db "ROM info", $00

BootMenuLoadingStr::
    db "Loading", $00

; [ezgb]
; BackupSaveDump: open SAVER FarCall_06_7309 mode $12 → $ca0f; fail Jump_001_6738 ret.
; Jump_001_647b: while offset < size@sp+$0f: bank PSRAM, VramCopyStack $200, FarCall_07_7739 write.
; Spinner ++sp+$04: Jump_001_652f; ==3 jr_001_6532 reset0; Jump_001_6536 "."; Jump_001_6551 → Jump_001_655b/jr_001_655e ".."; Jump_001_6572 "..."; Jump_001_6583 +=$200 → Jump_001_647b.
; Jump_001_65a1: $d3f6==$77 → jr_001_65af Memset+$A220 pack+write else Jump_001_65ac → Jump_001_672f close 768f; Jump_001_6738 fail (jr_001_673f/jr_001_6743 strs).

BackupSaveDump::
    add sp, -$0b
    call WaitVBlankFlag
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld a, $12
    push af
    inc sp
    ld hl, $c3a5
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_06_7309
    add sp, $05
    ld c, e
    ld a, c
    or a
    jp nz, BackupSaveDump_epilogueRet

    ld hl, $0000
    push hl
    ld hl, $0000
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_03_76cc
    add sp, $06
    ld hl, sp+$04
    ld [hl], $00
    xor a
    ld hl, sp+$07
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

BackupSaveDump_writeLoop::
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
    jp nc, BackupSaveDump_checkRtcMagic

    ld bc, CStrCat_B1
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
    call U32Shr
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
    call SetFpgaPage_B1
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
    call VramCopyStack
    add sp, $06
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
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
    call FarCall_07_7739
    add sp, $08
    ld hl, sp+$04
    inc [hl]
    ld a, [hl]
    sub $03
    jp nz, BackupSaveDump_spinnerSkipReset

    jr BackupSaveDump_spinnerReset0

BackupSaveDump_spinnerSkipReset::
    jp BackupSaveDump_spinnerDot


BackupSaveDump_spinnerReset0::
    ld hl, sp+$04
    ld [hl], $00

BackupSaveDump_spinnerDot::
    xor a
    ld hl, sp+$04
    or [hl]
    jp nz, BackupSaveDump_afterDot

    ld hl, $0a0b
    push hl
    ld a, $03
    push af
    inc sp
    ld hl, $673b
    push hl
    call DrawString
    add sp, $05
    jp BackupSaveDump_advance200


BackupSaveDump_afterDot::
    ld hl, sp+$04
    ld a, [hl]
    sub $01
    jp nz, BackupSaveDump_spinnerSkipDots

    jr BackupSaveDump_spinnerDots

BackupSaveDump_spinnerSkipDots::
    jp BackupSaveDump_spinnerEllipsis


BackupSaveDump_spinnerDots::
    ld hl, $0a0b
    push hl
    ld a, $03
    push af
    inc sp
    ld hl, $673f
    push hl
    call DrawString
    add sp, $05
    jp BackupSaveDump_advance200


BackupSaveDump_spinnerEllipsis::
    ld hl, $0a0b
    push hl
    ld a, $03
    push af
    inc sp
    ld hl, $6743
    push hl
    call DrawString
    add sp, $05

BackupSaveDump_advance200::
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
    jp BackupSaveDump_writeLoop


BackupSaveDump_checkRtcMagic::
    ld hl, $d3f6
    ld a, [hl]
    sub $77
    jp nz, BackupSaveDump_skipRtcPack

    jr BackupSaveDump_rtcPackWrite

BackupSaveDump_skipRtcPack::
    jp BackupSaveDump_close


BackupSaveDump_rtcPackWrite::
    ld hl, $0030
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $c0a0
    push hl
    call Memset
    add sp, $05
    ld bc, CStrCat_B1
    ld a, $11
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call SetFpgaPage_B1
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
    ld bc, CStrCat_B1
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
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
    call FarCall_03_76cc
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
    call FarCall_07_7739
    add sp, $08

BackupSaveDump_close::
    ld hl, $ca0f
    push hl
    call FarCall_03_768f
    add sp, $02

BackupSaveDump_epilogueRet::
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

; [ezgb]
; BackupSavePrompt(auto@sp+$12, size@sp+$10): draw BACKUPSAVE box + BackupUiStrings.
; auto!=1 → Jump_001_6784 → Jump_001_67d0 prompt; else jr_001_6787: Saving str, U32Shl size<<$0d, BackupSaveDump → Jump_001_6891.
; Jump_001_67d0: draw [B]NO/[A]OK; Jump_001_6821 joy loop: A($10) jr_001_682f dump twin → Jump_001_6891; B($20) Jump_001_6889 skip → Jump_001_6891; else spin.
; Jump_001_6891/jr_001_6891: epilogue ret.

BackupSavePrompt::
    push af
    push af
    push af
    push af
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
    ld hl, $0505
    push hl
    ld a, $0a
    push af
    inc sp
    ld hl, BackupUiStrings
    push hl
    call DrawString
    add sp, $05
    ld hl, sp+$12
    ld a, [hl]
    sub $01
    jp nz, BackupSavePrompt_skipAuto

    jr BackupSavePrompt_autoDump

BackupSavePrompt_skipAuto::
    jp BackupSavePrompt_drawConfirm


BackupSavePrompt_autoDump::
    ld hl, $0a05
    push hl
    ld a, $09
    push af
    inc sp
    ld hl, $689f
    push hl
    call DrawString
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
    call BackupSaveDump
    add sp, $06
    jp BackupSavePrompt_epilogueRet


BackupSavePrompt_drawConfirm::
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $016a
    push hl
    ld hl, $505d
    push hl
    ld a, $27
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, $016a
    push hl
    ld hl, $7b5d
    push hl
    ld a, $52
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, $0c05
    push hl
    ld a, $05
    push af
    inc sp
    ld hl, $68aa
    push hl
    call DrawString
    add sp, $05
    ld hl, DrawDirEntryLabel_bankShift
    push hl
    ld a, $05
    push af
    inc sp
    ld hl, $68b0
    push hl
    call DrawString
    add sp, $05

BackupSavePrompt_joyLoop::
    call ReadJoypad
    ld c, e
    ld b, $00
    ld a, c
    and $10
    jr nz, BackupSavePrompt_confirmDump

    jp BackupSavePrompt_checkB


BackupSavePrompt_confirmDump::
    ld hl, $0a05
    push hl
    ld a, $09
    push af
    inc sp
    ld hl, $689f
    push hl
    call DrawString
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
    call BackupSaveDump
    add sp, $06
    jp BackupSavePrompt_epilogueRet


BackupSavePrompt_checkB::
    ld a, c
    and $20
    jr nz, BackupSavePrompt_epilogueRet

    jp BackupSavePrompt_joyLoop


BackupSavePrompt_epilogueRet::
    add sp, $08
    ret


BackupUiStrings::
    db "BACKUPSAVE", $00, "Saving...", $00, $00, "[B]NO", $00, "[A]OK", $00

; $68b6-$68c0: src/kernel.c (_GSINIT: gsinit, wMarqueePos)
INCLUDE "b1_kernel_init.inc"
INCLUDE "b1_ccsbcs_init.inc"

; $7096-$7390: src/bank1.c (_GSINIT)
INCLUDE "b1_init.inc"
; $7390-$7600: gbdk/crt0.s (_GSINITTAIL), $FF fill
INCLUDE "b1_gsinittail.inc"


RtcDumpHook::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff

    rst $38

LastRomSaveHook::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff

    rst $38

RtcNegClampHook::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff

    rst $38

SoOpendir::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff

SoReaddir::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff

SoUnlink::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

    rst $38
    rst $38
    rst $38
    rst $38

SaveOp::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff

    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

SoMatch::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff

    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

PatchGuard::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff

    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38

SgbBootHook::
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff

    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
    rst $38
