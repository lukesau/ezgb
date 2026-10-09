; stage1 boot splash (FW4 bootstrap): CGB flag + EZ Flash icon.
; Overlay on the stock FW4 stage1 with rgblink -O, then rgbfix -f h.
;
; - Header declares CGB support: a colour console boots stage1 (and the
;   kernel after it) in CGB mode; DMG ignores the flag.
; - Hook A, at the boot LCD-on ($01BA), LCD still off: on CGB zero the tile
;   attributes and load palette 0 (the old BGP $E4 greys, for the text) and
;   palette 1 (the icon).
; - Hook C, just before EZ-FLASH is printed ($07FC): stage1's console setup
;   (on its first print, $07F3) clears VRAM, so the icon is drawn here: wait
;   for vblank, LCD off (the screen is still blank), load the icon to tiles
;   $80-$A9 ($8800, unused by the font at $20-$7F), draw it on map rows 1-7
;   above EZ-FLASH (row 8), give it palette 1 on CGB, LCD back on.
; - Hand-off: stage1 copies a routine from $4000 to $D100 (WRAM) that waits
;   for the FPGA to finish loading the kernel, switches the cart space over
;   and calls $0100. The copy is extended from $0150 to $0200 bytes so it
;   also carries HandoffBlank (ROM $4161, runs at $D261), and the routine's
;   final call $0100 goes there instead: reset every CGB tile attribute to
;   palette 0 (the kernel knows nothing about attributes), clear both maps
;   and tile 0 so nothing of the boot screen is left in VRAM, and leave the
;   LCD off. The kernel switches the LCD on before it draws, so without the
;   clear it showed the old screen (now grey) for a moment. Runs from WRAM with interrupts off
;   because the cart space is already the kernel.
; - No other stage1 code is changed.
; Note: GBDK's display-mode dispatcher ($0400) jumps through a 4-entry table
; at $01E2; only entry 0 (a ret) exists in stock stage1, entries 1-3 were
; $FF filler (rst $38) and land in this code, so they are evidently unused.

INCLUDE "build/icon.inc"

DEF rLCDC EQU $FF40
DEF rLY   EQU $FF44
DEF rVBK  EQU $FF4F
DEF rBCPS EQU $FF68
DEF rBCPD EQU $FF69
DEF rOCPS EQU $FF6A
DEF rOCPD EQU $FF6B

DEF ICON_X     EQU 7            ; tile column (centred: 20 - 6 = 14 / 2)
DEF ICON_Y     EQU 1            ; tile row; stage1 prints EZ-FLASH at row 8
DEF ICON_TILE  EQU $80          ; first tile number ($8800 in signed mode)

; ---- header ----
SECTION "cgb_flag", ROM0[$0143]
    db $80                      ; CGB enhanced, still runs on DMG

; ---- hook site ----
SECTION "hook_a_site", ROM0[$01BA]
    call CgbBootInit            ; was: ld a,$c0 / ldh [rLCDC],a
    nop

SECTION "hook_c_site", ROM0[$07FC]
    call SplashDraw             ; was: ld hl,$0b5f (the EZ-FLASH string)

SECTION "handoff_copy_len", ROMX[$40ED], BANK[1]
    ld hl, $0200                ; was: ld hl,$0150 (bytes copied $4000 -> $D100)

SECTION "handoff_call", ROMX[$40A8], BANK[1]
    call HandoffBlank           ; was: call $0100 (kernel entry)

DEF HANDOFF_ROM  EQU $4161      ; free $FF filler inside the extended copy
DEF HANDOFF_WRAM EQU $D100 + HANDOFF_ROM - $4000

SECTION "handoff_code", ROMX[HANDOFF_ROM], BANK[1]
LOAD "handoff_wram", WRAMX[HANDOFF_WRAM], BANK[1]
HandoffBlank::
    di                          ; cart space is the kernel now: no vectors
    push af                     ; the kernel stores A at entry: hand it the
    push bc                     ; same registers stock stage1 does
    push de
    push hl
    ldh a, [rLCDC]
    add a
    jr nc, .off                 ; LCD already off: no vblank to wait for
.vblank
    ldh a, [rLY]
    cp 144
    jr nz, .vblank
.off
    xor a
    ldh [rLCDC], a              ; LCD off; the kernel switches it back on
    ; CGB mode only (VBK exists; inline test, the ROM0 helpers are gone):
    ; every tile attribute -> palette 0
    ldh [rVBK], a
    ldh a, [rVBK]
    and 1
    jr nz, .clear
    inc a
    ldh [rVBK], a
    ld hl, $9800
    call .clear_maps
    xor a
    ldh [rVBK], a
.clear
    ; nothing of the boot screen left for the kernel to show before it
    ; draws: both maps -> tile 0, tile 0 blank in both addressing modes
    ld hl, $9800
    call .clear_maps
    ld hl, $8000
    call .blank_tile
    ld hl, $9000
    call .blank_tile
.kernel::
    pop hl
    pop de
    pop bc
    pop af
    jp $0100                    ; the kernel entry hook replaced
.clear_maps                     ; hl = $9800: zero $9800-$9FFF
    ld bc, $0800
.map_byte
    xor a
    ld [hl+], a
    dec bc
    ld a, b
    or c
    jr nz, .map_byte
    ret
.blank_tile                     ; zero the 16 bytes at hl
    xor a
    ld b, 16
.tile_byte
    ld [hl+], a
    dec b
    jr nz, .tile_byte
    ret
ENDL

; ---- code, in the $FF filler after the boot halt loop ----
SECTION "splash_code", ROM0[$01E4]

; Z set if the console runs this ROM in CGB mode: VBK only exists there
; (write 0, bit 0 reads back 0); DMG and CGB compat read $FF.
IsCgbMode:
    xor a
    ldh [rVBK], a
    ldh a, [rVBK]
    and 1
    ret

CgbBootInit:
    call IsCgbMode
    jr nz, .lcd_on
    ; attributes in VRAM bank 1: all palette 0
    ld a, 1
    ldh [rVBK], a
    ld hl, $9800
    ld bc, $0800
.attrs
    xor a
    ld [hl+], a
    dec bc
    ld a, b
    or c
    jr nz, .attrs
    xor a
    ldh [rVBK], a
    ; BG palette 0 = text greys, palette 1 = icon; OBJ palette 0 greys
    ld a, $80
    ldh [rBCPS], a
    ld hl, Greys
    ld b, 16
.bg
    ld a, [hl+]
    ldh [rBCPD], a
    dec b
    jr nz, .bg
    ld a, $80
    ldh [rOCPS], a
    ld hl, Greys
    ld b, 8
.obj
    ld a, [hl+]
    ldh [rOCPD], a
    dec b
    jr nz, .obj
.lcd_on
    ld a, $C0                   ; the instruction hook A replaced
    ldh [rLCDC], a
    ret

SplashDraw:
.vblank
    ldh a, [rLY]
    cp 144
    jr nz, .vblank
    ldh a, [rLCDC]
    push af
    xor a
    ldh [rLCDC], a              ; LCD off: VRAM free, screen is blank anyway
    ld hl, IconTiles
    ld de, $8000 + ICON_TILE * 16
    ld bc, IconTilesEnd - IconTiles
.tiles
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .tiles
    ld a, ICON_TILE
    call DrawIconMap
    call IsCgbMode
    jr nz, .on
    ld a, 1
    ldh [rVBK], a
    ld a, $FF                   ; DrawIconMap with a = $FF writes 1 everywhere
    call DrawIconMap
    xor a
    ldh [rVBK], a
.on
    pop af
    ldh [rLCDC], a
    ld hl, $0b5f                ; the instruction hook C replaced
    ret

; Write the ICON_W x ICON_H block at (ICON_X, ICON_Y) on map $9800:
; consecutive tile numbers from a, or all 1 (palette 1) when a = $FF.
DrawIconMap:
    ld hl, $9800 + ICON_Y * 32 + ICON_X
    ld c, ICON_H
.row
    ld b, ICON_W
.col
    cp $FF
    jr z, .attr
    ld [hl+], a
    inc a
    jr .next
.attr
    ld [hl], 1
    inc hl
.next
    dec b
    jr nz, .col
    ld de, 32 - ICON_W
    add hl, de
    dec c
    jr nz, .row
    ret

; ---- data, in the $FF filler at the end of the 16 KB bit-plane area ----
SECTION "splash_data", ROM0[$39A4]
; BGR555. Palette 0: the old BGP $E4 shades (text). Palette 1: the icon:
; 0 screen background, 1 orange screen, 2 frames (darkened), 3 lip.
Greys:
    dw $7FFF, $56B5, $294A, $0000
IconPalette:
    dw $7FFF, $129E, $294A, $14A5
IconTiles:
    INCBIN "build/icon.2bpp"
IconTilesEnd:
