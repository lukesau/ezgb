; Fast decimal path for bank 4's U32ToAscii (docs/screen-timing.md).
;
; U32ToAscii (04:44f7) makes every digit with a U32Div and a U32Mod call
; through the generic 32-bit divide: tens of thousands of cycles a digit,
; about 250 ms of each SD -> SET switch for the six clock fields, and more
; each second while the SET tab redraws the clock. Every value the SET tab
; formats fits in 16 bits (the year is 2000 + two BCD digits, the rest are
; under 100), so for radix 10 and a value below 65536 this makes the digits
; by subtracting powers of ten instead. Same output as the original: at
; least two digits (a single digit gets a leading "0", which is how the clock
; shows 09:05:00), no other leading zeros, NUL-terminated. Any other radix or
; value goes to the original code.
;
; U32ToAscii's first four bytes (add sp, -$34; ld hl, sp+$13) are replaced by
; `jp U32ToAsciiFast; nop`; the slow path runs them and jumps back.
; Arguments (sdcccall 0): sp+2 value (u32), sp+6 buffer, sp+8 radix.
;
; scripts/fastdec/inject-fastdec.py assembles this and injects it.

DEF U32ToAsciiRest EQU $44fb   ; U32ToAscii + 4

MACRO DIGIT                    ; \1 = power of ten
    ld b, "0"
.sub\@
    ld a, l
    sub LOW(\1)
    ld l, a
    ld a, h
    sbc HIGH(\1)
    ld h, a
    jr c, .back\@
    inc b
    jr .sub\@
.back\@
    ld a, l                    ; undo the subtraction that went below zero
    add LOW(\1)
    ld l, a
    ld a, h
    adc HIGH(\1)
    ld h, a
    ld a, b
    cp "0"
    jr nz, .put\@
    bit 0, c                   ; a zero is written once a digit has been
    jr z, .skip\@
.put\@
    ld [de], a
    inc de
    ld c, 1
.skip\@
ENDM

SECTION "U32ToAsciiFast", ROMX[$7c00], BANK[4]
U32ToAsciiFast::
    ld hl, sp+8
    ld a, [hl]
    cp 10
    jp nz, .slow
    ld hl, sp+4                ; high word
    ld a, [hl+]
    or [hl]
    jp nz, .slow
    ld hl, sp+6
    ld a, [hl+]
    ld e, a
    ld d, [hl]                 ; DE = buffer
    ld hl, sp+2
    ld a, [hl+]
    ld h, [hl]
    ld l, a                    ; HL = value
    ld c, 0                    ; no digit written yet
    DIGIT 10000
    DIGIT 1000
    DIGIT 100
    DIGIT 10
    bit 0, c                   ; one digit only: "0" first, as the original
    jr nz, .last
    ld a, "0"
    ld [de], a
    inc de
.last
    ld a, l
    add "0"
    ld [de], a
    inc de
    xor a
    ld [de], a
    ret
.slow
    add sp, -$34
    ld hl, sp+$13
    jp U32ToAsciiRest
