; ShiftRows (04:7cd0, in bank 4's free tail, moved from 05:7680 so that it sits
; with RepaintRows, rows_repaint.c, its one caller, right after it).

DEF GfxRowTable EQU $2fbb           ; 00: pixel row -> VRAM address of its tile column 0

SECTION "vrammove", ROMX[$7CD0], BANK[4]
; ShiftRows(dst_y, src_y, batches, step), sdcccall 0, u8 arguments at sp+2..5:
; copies `batches` groups of 4 canvas pixel rows, all 20 tile columns, from
; src_y to dst_y (both multiples of 4, so a group is 8 bytes inside one tile
; and never crosses a tile boundary), then steps both by `step`: 4, or -4 to
; copy bottom first when moving rows down so nothing is overwritten before it
; is read. A scroll of k rows moves the 9 - k rows that stay on screen this
; way and leaves only k + 1 rows to draw (rows_repaint.c), instead of all ten.
;
; Each group goes out in one VRAM window, synced exactly like draw12.c's
; blit_col1 (see the long comment there): a fresh HBlank (mode 3, then mode
; 0) with interrupts off, or straight away while LY reads 144..151 in mode 1;
; a sync from LY >= 143 waits with interrupts on for LY 145..150 or the next
; frame, so the VBlank callback that points the BG tile data back at $8000
; is never delayed. The group is two passes of 4 bytes: 57 M-cycles, inside
; the 51 + 20 that blit_col1 relies on.
ShiftRows::
.batch
    ld hl, sp+3                      ; src_y
    ld a, [hl]
    call RowAddr
    push hl
    ld hl, sp+4                      ; dst_y (the push moved sp)
    ld a, [hl]
    call RowAddr
    ld d, h
    ld e, l
    pop hl
    ld b, 20                        ; tile columns
.col
    di
    ldh a, [$ff41]
    and 3
    cp 1
    jr nz, .sync
    ldh a, [$ff44]
    cp 144
    jr c, .sync
    cp 152
    jr nc, .sync
    jr .go
.sync
    ldh a, [$ff44]
    cp 143
    jr c, .m3
    ei
.vb
    ldh a, [$ff44]
    cp 143
    jr c, .col
    cp 145
    jr c, .vb
    cp 151
    jr c, .col
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
.go
    ld c, 2
.half
    REPT 4
    ld a, [hl+]
    ld [de], a
    inc de
    ENDR
    dec c
    jr nz, .half
    ei
    ld a, l                         ; next tile column: 16 on, 8 of them done
    add 8
    ld l, a
    jr nc, .src
    inc h
.src
    ld a, e
    add 8
    ld e, a
    jr nc, .dst
    inc d
.dst
    dec b
    jr nz, .col
    ld hl, sp+5                      ; step
    ld c, [hl]
    dec hl                          ; batches
    dec [hl]
    ret z
    dec hl                          ; src_y
    ld a, [hl]
    add c
    ld [hl-], a                     ; dst_y
    ld a, [hl]
    add c
    ld [hl], a
    jp .batch

; a = pixel row -> hl = its VRAM address in tile column 0. Clobbers bc.
; ShiftRows' helper.
RowAddr:
    ld l, a
    ld h, 0
    add hl, hl
    ld bc, GfxRowTable
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ret
