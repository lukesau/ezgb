; Boot splash lab: the EZ Flash icon, static, where it would sit on the
; stage1 boot screen (stage1 prints EZ-FLASH at tile row 8).
; Build: ./build.sh   Run: sameboy --model cgb|dmg splash.gb

INCLUDE "build/icon.inc"

DEF rLCDC EQU $FF40
DEF rLY   EQU $FF44
DEF rBGP  EQU $FF47
DEF rVBK  EQU $FF4F
DEF rBCPS EQU $FF68
DEF rBCPD EQU $FF69

DEF ICON_X EQU 7                ; tile column (20 wide screen, 6 wide icon)
DEF ICON_Y EQU 1                ; tile row; EZ-FLASH text is at row 8

SECTION "header", ROM0[$0100]
    nop
    jp Start
    ds $0150 - @, 0             ; rgbfix fills the header

SECTION "main", ROM0[$0150]
Start:
    di
    ld sp, $E000
    call LcdOff

    ; VRAM bank 0: clear tiles and map, then load the icon at tile 1+
    xor a
    ld hl, $8000
    ld bc, $2000
    call Fill
    ld hl, IconTiles
    ld de, $8010                ; tile 0 stays blank for the empty map
    ld bc, IconTilesEnd - IconTiles
    call Copy
    call DrawMap

    call IsCgbMode
    jr nz, .dmg
    ; CGB: attributes (VRAM bank 1) all palette 0, then palette 0
    ld a, 1
    ldh [rVBK], a
    xor a
    ld hl, $9800
    ld bc, $0400
    call Fill
    xor a
    ldh [rVBK], a
    ld a, $80                   ; BG palette 0, auto-increment
    ldh [rBCPS], a
    ld hl, Palette
    ld b, 8
.pal
    ld a, [hl+]
    ldh [rBCPD], a
    dec b
    jr nz, .pal
.dmg
    ld a, $E4                   ; DMG shades 0-3 = white, light, dark, black
    ldh [rBGP], a

    ld a, $91                   ; LCD on, BG on, tiles $8000, map $9800
    ldh [rLCDC], a
.idle
    jr .idle

; Z set in CGB mode (VBK only exists there; DMG reads $FF)
IsCgbMode:
    xor a
    ldh [rVBK], a
    ldh a, [rVBK]
    and 1
    ret

LcdOff:
    ldh a, [rLCDC]
    add a
    ret nc                      ; already off
.wait
    ldh a, [rLY]
    cp 144
    jr nz, .wait
    xor a
    ldh [rLCDC], a
    ret

; icon map: ICON_W x ICON_H tiles numbered 1.. in row order
DrawMap:
    ld hl, $9800 + ICON_Y * 32 + ICON_X
    ld a, 1
    ld c, ICON_H
.row
    ld b, ICON_W
.col
    ld [hl+], a
    inc a
    dec b
    jr nz, .col
    ld de, 32 - ICON_W
    add hl, de
    dec c
    jr nz, .row
    ret

Fill:                           ; hl = dst, bc = count, a = value
    ld d, a
.loop
    ld a, d
    ld [hl+], a
    dec bc
    ld a, b
    or c
    jr nz, .loop
    ret

Copy:                           ; hl = src, de = dst, bc = count
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, Copy
    ret

SECTION "data", ROM0
; BGR555. 0 screen background, 1 orange screen, 2 frames (darkened), 3 lip
Palette:
    dw (28 << 10) | (30 << 5) | 31, $129E, $294A, $14A5   ; off-white paper
IconTiles:
    INCBIN "build/icon.2bpp"
IconTilesEnd:
