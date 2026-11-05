; TabNumFar (02:495c, moved from bank 5, where ezjr_scroll.c needed the room;
; it fills the 164 bytes between the mod's LastRomBox block and EzCfg at
; 02:4a00): the list position as "n/total" in green, right-aligned. TabNum12
; at 00:0380 is a far stub to it.

DEF FarCallDrawString12 EQU $05c0
DEF wDrawColor  EQU $d734
DEF wDrawColorB EQU $d735
DEF ENTRY_COUNT EQU $c2a2
DEF COUNTER_X   EQU 118             ; 7 glyphs x 6 px, ending at x 160

SECTION "tabnum", ROMX[$495C], BANK[2]
; Called through a far stub with DrawString's frame: three pads, then
; s (u16, the stock "n" digits), len, x, y. Draws "  n/total" in ink 1.
TabNumFar::
    add sp, -12                     ; buf[12]: s now at sp+20
    ld a, [wDrawColor]
    ld b, a
    ld a, [wDrawColorB]
    ld c, a
    push bc                         ; saved draw state; buf at sp+2, s at sp+22
    ld hl, sp+22
    ld a, [hl+]
    ld e, a
    ld d, [hl]                      ; de = s
    ld hl, sp+2                     ; buf
    call FormatCounter
    ld a, 1
    ld [wDrawColor], a              ; green
    xor a
    ld [wDrawColorB], a             ; on black
    ld hl, (0 << 8) | COUNTER_X     ; row 0, col x
    push hl
    xor a
    push af
    inc sp                          ; len 0: to the NUL
    ld hl, sp+5                     ; buf
    push hl
    call FarCallDrawString12
    add sp, 5
    pop bc
    ld a, b
    ld [wDrawColor], a
    ld a, c
    ld [wDrawColorB], a
    add sp, 12
    ret

; FormatCounter: hl = 8-byte buffer, de = the stock number text (digits, maybe
; padded, up to 4 chars or a NUL). Writes "  n/total" right-aligned in 7 glyphs
; plus a NUL, total from ENTRY_COUNT.
FormatCounter::
    push hl                         ; buf
    push de                         ; s
    ld a, $20
    ld b, 7
.fill:
    ld [hl+], a
    dec b
    jr nz, .fill
    xor a
    ld [hl], a                      ; buf[7] = NUL
    dec hl                          ; &buf[6]
    ld a, [ENTRY_COUNT]
    ld e, a
    ld a, [ENTRY_COUNT + 1]
    ld d, a
    call PutDec                     ; total, right to left
    ld [hl], $2F                    ; "/"
    dec hl
    ld b, h
    ld c, l                         ; bc = where n ends
    pop hl                          ; s
    push bc
    ld de, 0
    ld b, 4
.parse:
    ld a, [hl+]
    and a
    jr z, .parsed
    sub $30
    cp 10
    jr nc, .skip                    ; spaces and anything else
    push hl
    push bc
    ld c, a
    ld h, d
    ld l, e
    add hl, hl
    ld d, h
    ld e, l
    add hl, hl
    add hl, hl
    add hl, de                      ; value * 10
    ld a, l
    add a, c
    ld e, a
    ld a, h
    adc 0
    ld d, a                         ; + digit
    pop bc
    pop hl
.skip:
    dec b
    jr nz, .parse
.parsed:
    pop hl                          ; where n ends
    call PutDec
    pop hl                          ; buf
    ret

; PutDec: de = value, hl = where its last digit goes; writes the digits right
; to left and returns hl just left of the first one.
PutDec:
.digit:
    push hl
    ld hl, 0                        ; quotient
.div:
    ld a, e
    sub 10
    ld c, a
    ld a, d
    sbc 0
    jr c, .rem
    ld d, a
    ld e, c
    inc hl
    jr .div
.rem:
    ld a, e
    add a, $30
    ld b, a
    ld d, h
    ld e, l                         ; de = quotient
    pop hl
    ld [hl], b
    dec hl
    ld a, d
    or e
    jr nz, .digit
    ret
