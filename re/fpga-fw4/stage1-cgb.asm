; stage1 CGB proof patch (FW4 bootstrap).
; Header declares CGB support, so a colour console boots it in CGB mode.
; Hook A: at the boot LCD-on, clear the CGB tile attributes and load a
;         greyscale palette, so EZ-FLASH / LOADING look as before.
; Hook B: when OSINIT... is printed, turn the background colour red.
; Both hooks do nothing unless the console is really in CGB mode.

DEF rLCDC EQU $FF40
DEF rLY   EQU $FF44
DEF rVBK  EQU $FF4F
DEF rBCPS EQU $FF68
DEF rBCPD EQU $FF69
DEF rOCPS EQU $FF6A
DEF rOCPD EQU $FF6B
DEF BCPSF_AUTOINC EQU $80
DEF OCPSF_AUTOINC EQU $80

; ---- header ----
SECTION "cgb_flag", ROM0[$0143]
    db $80                      ; CGB enhanced, still runs on DMG

; header checksum at $014D is fixed by rgbfix afterwards

; ---- hook sites ----
SECTION "hook_a_site", ROM0[$01BA]
    call CgbBootInit            ; was: ld a,$c0 / ldh [rLCDC],a
    nop

SECTION "hook_b_site", ROM0[$0885]
    call CgbOsinitRed           ; was: ld hl,$0b7d (the OSINIT... string)

; ---- hook code, in the $FF filler after the boot halt loop ----
SECTION "hooks", ROM0[$01E4]

; Z set if the console is running this ROM in CGB mode. VBK only exists
; there: write 0 and bit 0 reads back 0. On DMG (or CGB compat) it reads $FF.
IsCgbMode:
    xor a
    ldh [rVBK], a
    ldh a, [rVBK]
    and 1
    ret

CgbBootInit:
    call IsCgbMode
    jr nz, .lcd_on
    ; attributes for both tilemaps ($9800-$9FFF) in VRAM bank 1 = 0
    ld a, 1
    ldh [rVBK], a
    ld hl, $9800
    ld bc, $0800
.clear
    xor a
    ld [hl+], a
    dec bc
    ld a, b
    or c
    jr nz, .clear
    xor a
    ldh [rVBK], a
    ; BG palette 0 and OBJ palettes 0/1: the old BGP $E4 shades
    ld a, BCPSF_AUTOINC
    ldh [rBCPS], a
    ld hl, Greys
    ld b, 8
.bg
    ld a, [hl+]
    ldh [rBCPD], a
    dec b
    jr nz, .bg
    ld a, OCPSF_AUTOINC
    ldh [rOCPS], a
    ld hl, Greys
    ld b, 16
.obj
    ld a, [hl+]
    ldh [rOCPD], a
    dec b
    jr nz, .obj
.lcd_on
    ld a, $c0                   ; the instruction hook A replaced
    ldh [rLCDC], a
    ret

CgbOsinitRed:
    call IsCgbMode
    jr nz, .done
    ; palette RAM is only writable outside LCD mode 3: wait for vblank
.out_of_vblank
    ldh a, [rLY]
    cp 144
    jr nc, .out_of_vblank
.into_vblank
    ldh a, [rLY]
    cp 144
    jr c, .into_vblank
    ld a, BCPSF_AUTOINC
    ldh [rBCPS], a
    ld hl, RedGreys
    ld b, 8
.bg
    ld a, [hl+]
    ldh [rBCPD], a
    dec b
    jr nz, .bg
.done
    ld hl, $0b7d                ; the instruction hook B replaced
    ret

; BGR555, little endian. Shade 0 = background.
Greys:
    dw $7FFF, $56B5, $294A, $0000
    dw $7FFF, $56B5, $294A, $0000   ; OBJ palette 1 (read past the end above)
RedGreys:
    dw $001F, $56B5, $294A, $0000
