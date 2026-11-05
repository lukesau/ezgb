; The selection bar as a VRAM recolor (02:7e02, where upstream's browser_icons.c
; sat before dv/build.py moved DrawNameWithIcon to 02:6b80; that copy is no
; longer called), and drawn in one pass (02:7480). A 12px browser row is 12
; pixel rows of all 20 tile columns, and its two looks are fixed functions of
; the glyph bits g (any pixel not paper):
;
;   plain      plane 0 = plane 1 = g, except the icon's pixels, which
;              RecolorIcon (bank2_recolor.asm) turned blue: plane 0 cleared in
;              tile column 0 and in bit 7 (x = 8) of tile column 1
;   selected   the bar, ink 0 on paper 1: plane 0 = ~g, plane 1 = 0
;
; so a row changes look without drawing its text again. HighlightRow does
; plain -> selected (g = plane 0 | plane 1), UnhighlightRow selected -> plain
; (g = ~plane 0); move_highlight.c moves the bar with both.
;
; A row drawn in the bar's colors goes through draw12.c's per-pixel-row
; flush_rmw (about 4.7 frames a row); only ink 3 on paper 0 or the inverse
; takes the fast blit_col1, which writes the same byte to both planes.
; DrawNameWithIcon draws the bar row with ink 3 on paper 0 and hBarBlit set,
; and BlitCol1Hook, on blit_col1's first three bytes, then writes each batch
; in the bar's planes instead: the same pixels, in the same pass, so the row
; never shows in plain colors on the way.
;
; Each group of 4 pixel rows of one tile column (8 bytes inside one tile:
; the rows start at y 20 + 12 * row, a multiple of 4) is read and written in
; one VRAM window from VramSync, which syncs exactly like draw12.c's
; blit_col1 (see the long comment there): a fresh HBlank (mode 3, then mode
; 0) with interrupts off, or straight away while LY reads 144..151 in mode 1;
; a sync from LY >= 143 waits with interrupts on for LY 145..150 or the next
; frame, so the VBlank callback that points the BG tile data back at $8000
; is never delayed. A group takes 52 (HighlightRow), 40 (UnhighlightRow) or
; 44 (BarBlit) M-cycles after VramSync's ret, inside the 51 + 20 blit_col1
; relies on. VramSync's di / ei are why none of this runs inside a DiNest
; section (wIntNest != 0): the callers check, as draw12.c does for blit_col1.

DEF GfxRowTable EQU $2fbb           ; 00: pixel row -> VRAM address of tile column 0
DEF ROW_GROUPS  EQU 3               ; 12 pixel rows, 4 at a time
DEF TILE_COLS   EQU 20
DEF hBarBlit    EQU $fff3           ; 1 while DrawNameWithIcon draws the bar row (HRAM nothing else uses; 0 from boot)
DEF blit_col1   EQU $7d89           ; draw12.c (02): `ld hl, sp+7; ld c, [hl]`, then the rest

SECTION "hilite", ROMX[$7E02], BANK[2]

; HighlightRow(u8 py), sdcccall 0: pixel rows py .. py + 11, plain -> selected.
HighlightRow::
    ld hl, sp+2
    ld c, [hl]                      ; py
    ld b, ROW_GROUPS
.group
    push bc
    ld a, c
    call RowAddr2
    ld b, TILE_COLS
.col
    call VramSync                   ; interrupts off, in a window
    REPT 4
    ld a, [hl+]                     ; plane 0
    or [hl]                         ; | plane 1 = g
    cpl
    ld [hl], 0                      ; plane 1 = 0
    dec l
    ld [hl+], a                     ; plane 0 = ~g
    inc hl
    ENDR
    ei
    ld de, 8                        ; next tile column: 16 on, 8 of them done
    add hl, de
    dec b
    jr nz, .col
    pop bc
    ld a, c
    add 4
    ld c, a
    dec b
    jr nz, .group
    ret

; UnhighlightRow(u8 py), sdcccall 0: pixel rows py .. py + 11, selected -> plain.
UnhighlightRow::
    ld hl, sp+2
    ld c, [hl]                      ; py
    ld b, ROW_GROUPS
.group
    push bc
    ld a, c
    call RowAddr2
    ld bc, (TILE_COLS << 8) | $00   ; b: columns; c: plane-0 mask, $00 for tile column 0
.col
    call VramSync
    REPT 4
    ld a, [hl]                      ; plane 0 = ~g
    cpl
    ld d, a                         ; g
    and c
    ld [hl+], a                     ; plane 0: g, minus the icon's pixels
    ld a, d
    ld [hl+], a                     ; plane 1: g
    ENDR
    ei
    ld de, 8
    add hl, de
    ld a, c                         ; next mask: $00 (column 0) -> $7F (column 1) -> $FF
    cp $7F
    ld c, $FF
    jr nc, .mask
    ld c, $7F
.mask
    dec b
    jr nz, .col
    pop bc
    ld a, c
    add 4
    ld c, a
    dec b
    jr nz, .group
    ret

; Returns in a VRAM window with interrupts off (blit_col1's sync).
VramSync::
.try
    di
    ldh a, [$ff41]
    and 3
    cp 1
    jr nz, .sync
    ldh a, [$ff44]
    cp 144
    jr c, .sync
    cp 152
    ret c
.sync
    ldh a, [$ff44]
    cp 143
    jr c, .m3
    ei
.vb
    ldh a, [$ff44]
    cp 143
    jr c, .try
    cp 145
    jr c, .vb
    cp 151
    jr c, .try
    jr .vb
.m3
    ldh a, [$ff41]
    and 3
    cp 3
    jr nz, .m3
.w0
    ldh a, [$ff41]
    and 3
    jr nz, .w0
    ret

; Digits4(u16 n, u8 *buf), sdcccall 0: n < 10000 as 4 digits and a NUL, for
; TabNumFar, which reads up to 4 digits back as a number (move_highlight.c).
Digits4::
    ld hl, sp+4
    ld e, [hl]
    inc hl
    ld d, [hl]                      ; de = buf
    ld hl, sp+2
    ld a, [hl+]
    ld h, [hl]
    ld l, a                         ; hl = n
DigitsHLDE:
    ld bc, -1000
    call .digit
    ld bc, -100
    call .digit
    ld bc, -10
    call .digit
    ld a, l
    add "0"
    ld [de], a
    inc de
    xor a
    ld [de], a
    ret
.digit                              ; [de++] = "0" + hl / -bc, hl = hl % -bc
    ld a, "0" - 1
.sub
    inc a
    add hl, bc                      ; carry while hl was >= -bc
    jr c, .sub
    ld [de], a
    inc de
    ld a, l                         ; undo the subtraction that went below 0
    sub c
    ld l, a
    ld a, h
    sbc b
    ld h, a
    ret

; CounterDigits, for U32ToAscii_B0(u32 v, u8 *buf, u8 radix) at
; DrawBrowserDetail's counter, through CounterDigitsStub (bank0_browser.asm's
; room): the far stub's three pads, then v at sp+8 (its high half is always
; 0 there), buf at sp+12. See move_highlight.c.
CounterDigits::
    ld hl, sp+12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+8
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jr DigitsHLDE

; a = pixel row -> hl = its VRAM address in tile column 0. Clobbers de.
RowAddr2:
    ld l, a
    ld h, 0
    add hl, hl
    ld de, GfxRowTable
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ret

SECTION "barblit", ROMX[$7480], BANK[2]

; blit_col1's first three bytes jump here (dv/build.py). With hBarBlit clear
; this is blit_col1 itself; with it set, BarBlit.
BlitCol1Hook::
    ldh a, [hBarBlit]
    and a
    jr nz, BarBlit
    ld hl, sp+7                     ; the three bytes the jump replaced
    ld c, [hl]
    jp blit_col1 + 3

; blit_col1(src, addr, n, xm) in the bar's planes, sdcccall 0 (jumped into, so
; blit_col1's frame: sp+2 src, +4 addr, +6 n, +7 xm): n / 4 batches of 4 pixel
; rows of one tile column, plane 0 = bits ^ xm ^ $FF, plane 1 = 0. The step to
; the next tile row (+$130 past the tile) is blit_col1's.
BarBlit:
    ld hl, sp+7
    ld a, [hl-]                     ; xm
    cpl
    ld c, a
    ld a, [hl-]                     ; n
    srl a
    srl a
    ld b, a
    ld a, [hl-]
    ld d, a
    ld a, [hl-]
    ld e, a                         ; de = addr
    ld a, [hl-]
    ld l, [hl]
    ld h, a                         ; hl = src
.batch
    call VramSync
    REPT 4
    ld a, [hl+]
    xor c
    ld [de], a                      ; plane 0
    inc e
    xor a
    ld [de], a                      ; plane 1
    inc de
    ENDR
    ei
    ld a, e
    and $0F
    jr nz, .next
    ld a, e
    add $30
    ld e, a
    ld a, d
    adc 1
    ld d, a
.next
    dec b
    jr nz, .batch
    ret
