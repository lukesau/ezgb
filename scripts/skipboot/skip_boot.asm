; Skip boot ROM (issue #8): start a game with a jump to $0100 instead of the
; $7FE0 reset, when the console is already in the mode the game needs.
;
; The boot ROM picks CGB or DMG compatibility mode once, from stage1's
; header, and the choice can't be changed after it unmaps itself. Two cases
; jump, and everything else resets as before:
;
; - GBC/GBA with the kernel in CGB mode (mod stage1, CGB flag set) and a game
;   with the CGB flag ($0143 bit 7) without PGB mode (bits 2-3).
; - DMG family (VBK reads $FF) with stock stage1, a game without the CGB flag
;   and SGB BOOT off. The kernel can't tell an SGB from a DMG, so SGB BOOT
;   ticked or our stage1 (S1_SGB, it may be on an SGB) resets.
;
; SkipBootPrep replaces RomLoad_BuildAndRunPoll's `call $d100`. It copies
; SkipBoot to WRAM after the launch stub and points the stub's reset
; (RomLoad_SoftReset, $D19C in the copy) at it, then runs the stub. SkipBoot
; runs once the cart has switched to the game, so it can read the game's
; header and can't call anything in cart space.

DEF STUB_RESET EQU $d19c        ; RomLoad_SoftReset in the $D100 copy
DEF WRAM_AT    EQU $d1b0        ; past the stub's last byte ($D1AA)
DEF BOOT_RESET EQU $dbeb        ; kernel/src/vars.h
DEF S1_SGB     EQU $dbf8        ; kernel/src/ezcfg.h
DEF REC_FLAG   EQU $7f51        ; RecFlag(r, tag, toggle), kernel/src/rec_flag.c
DEF SGB_REC    EQU $a400        ; SGB BOOT's pSRAM record

SECTION "SkipBootPrep", ROMX[$6be6], BANK[4]
SkipBootPrep::
    ld a, [BOOT_RESET]          ; BOOTROM=1 in EZGB.CFG: always reset
    and a
    jp nz, $d100
    xor a                       ; RecFlag(SGB_REC, 'G', 0): reads while the
    push af                     ; kernel is still mapped
    inc sp
    ld a, 'G'
    push af
    inc sp
    ld hl, SGB_REC
    push hl
    call REC_FLAG
    add sp, 4
    ld a, [S1_SGB]
    or e
    ld c, a
    ld hl, SkipBootSrc
    ld de, WRAM_AT
    ld b, SkipBootSrcEnd - SkipBootSrc
.copy
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, .copy
    ld a, c
    ld [NoDmgJump], a
    ld hl, STUB_RESET           ; ld bc, $7fe0  ->  jp SkipBoot
    ld [hl], $c3
    inc hl
    ld [hl], LOW(WRAM_AT)
    inc hl
    ld [hl], HIGH(WRAM_AT)
    jp $d100

SkipBootSrc:
LOAD "SkipBoot", WRAMX[WRAM_AT]
; From the stub: $2000 = 1 and $3000 = 0 written, unlock $E1-$E3 written.
SkipBoot:
    ld a, [$0143]
    ld b, a
    xor a                       ; DMG family: VBK reads $FF
    ldh [$ff4f], a
    ldh a, [$ff4f]
    rra
    jr c, .dmg
    ld a, b
    and $8c
    cp $80
    jr z, .cgb
.reset
    ld bc, $7fe0                ; the instruction the hook replaced
    jp STUB_RESET + 3
.dmg
    bit 7, b
    jr nz, .reset
    ld a, [NoDmgJump]
    and a
    jr nz, .reset
.cgb
    di
    ldh a, [$ff40]                ; LCD off, in VBlank
    add a
    jr nc, .lcdoff
.vblank
    ldh a, [$ff44]
    cp 144
    jr c, .vblank
    xor a
    ldh [$ff40], a
.lcdoff
    ; CGB mode: palette RAM takes a write. In DMG compatibility mode it
    ; ignores it (VBK reads back there, so it is no test), on a DMG it
    ; reads $FF.
    ldh a, [$ff4f]
    rra
    jr c, .unlock
    ld hl, $ff69
    xor a
    ldh [$ff68], a
    ld a, $5a
    ld [hl], a
    cp [hl]
    jr nz, .reset
    cpl
    ld [hl], a
    cp [hl]
    jr nz, .reset

.unlock
    xor a                       ; finish the unlock with a no-change write
    ld [$7f32], a
    ld a, $e4
    ld [$7ff0], a
    xor a                       ; MBC as at power-on (the unlock wrote $6000)
    ld [$0000], a
    ld [$4000], a
    ld [$6000], a

    ld c, 2                     ; VRAM bank 1, then bank 0
.vbank
    ld a, c
    dec a
    ldh [$ff4f], a
    ld hl, $8000
    xor a
.vclear
    ld [hl+], a
    bit 5, h
    jr z, .vclear
    dec c
    jr nz, .vbank
    ld hl, $fe00                ; OAM
    ld b, $a0
.oclear
    ld [hl+], a
    dec b
    jr nz, .oclear

    ld a, $80                   ; BG and OBJ palettes white (no-op on DMG)
    ldh [$ff68], a
    ldh [$ff6a], a
    ld b, 64
    ld a, $ff
.pal
    ldh [$ff69], a
    ldh [$ff6b], a
    dec b
    jr nz, .pal

    ld hl, .zero                ; registers the kernel used, as at power-on
    ld b, .zero_end - .zero
    xor a
.io
    ld c, [hl]
    inc hl
    ldh [c], a
    dec b
    jr nz, .io
    ld a, $80                   ; sound on, as the boot ROM leaves it
    ldh [$ff26], a
    ld a, $77
    ldh [$ff24], a
    ld a, $f3
    ldh [$ff25], a
    ld a, $fc
    ldh [$ff47], a

    ld a, $91                   ; LCD on, hand over at the start of VBlank
    ldh [$ff40], a
    xor a
    ldh [$ff0f], a
.wait
    ldh a, [$ff44]
    cp 144
    jr nz, .wait

    ld sp, .cgb_regs
    ldh a, [$ff4f]
    rra
    jr nc, .regs
    ld sp, .dmg_regs
.regs
    pop af
    pop bc
    pop de
    pop hl
    ld sp, $fffe
    jp $0100

; AF, BC, DE, HL as each boot ROM leaves them
.cgb_regs
    dw $1180, $0000, $ff56, $000d
.dmg_regs
    dw $01b0, $0013, $00d8, $014d

; P1, SB, SC, TIMA, TMA, TAC, STAT, SCY, SCX, LYC, WY, WX, RP, SVBK, IE
.zero
    db $00, $01, $02, $05, $06, $07, $41, $42, $43, $45, $4a, $4b, $56, $70, $ff
.zero_end
NoDmgJump:
    db 0                        ; set by SkipBootPrep
ENDL
SkipBootSrcEnd:
