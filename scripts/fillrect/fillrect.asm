; Fast rectangle fill for DrawRect (docs/screen-timing.md).
;
; DrawRectImpl fills a rectangle by calling DrawLine once per scanline, and
; every 8 pixels of that line go through ApplyPixel's op dispatch and its own
; VRAM wait: about 580 T-cycles a byte, 370-500 ms of every tab switch.
; FillRect does the same fill a tile byte pair at a time: per scanline it
; looks up the row once, then writes the left edge under its mask, whole
; bytes across the middle, and the right edge under its mask.
;
; Called from DrawRectImpl_fillScan (00:236d) through FarCallTrampoline, with
; the inner rectangle in wDrawX0/X1/Y0/Y1 (ordered, Y already inset) and the
; fill colors already swapped into wDrawColor. Only op 0 (replace) is done
; here; ops 1-3 fall back to the stock DrawLine loop.
;
; VRAM: the two edge tiles are written the way ApplyPixelSafe (00:2704)
; writes them (interrupts off, wait for STAT mode 0 or 1, read-modify-write
; both planes). The whole tiles between them go out in batches of five byte
; pairs, synced the way draw12.c's blit_col1 syncs (see its comment): to a
; fresh HBlank (mode 3, then mode 0), or straight away in VBlank on LY
; 144..151, and from LY 143 on interrupts stay on and the batch waits for LY
; 145..150 so the VBlank callback is never held off. A batch is 40 M-cycles,
; inside the 51 + 20 of HBlank plus OAM scan. With the LCD off every write
; goes straight out.
;
; Bitmap layout: GfxRowTable[y] is the address of pixel row y at x 0; each
; 8-pixel tile is 16 bytes further on, a row's two plane bytes adjacent.
;
; scripts/fillrect/inject-fillrect.py assembles this and injects it.

DEF rSTAT      EQU $ff41
DEF wDrawOp    EQU $d723
DEF wDrawX0    EQU $d725
DEF wDrawX1    EQU $d726
DEF wDrawY0    EQU $d727
DEF wDrawY1    EQU $d728
DEF wDrawColor EQU $d734
DEF rLCDC      EQU $ff40
DEF rLY        EQU $ff44
DEF BATCH      EQU 5
DEF GfxRowTable EQU $2fbb
DEF DrawLine   EQU $239c

; scratch, free mod WRAM (docs/ezgb-cfg.md)
DEF fLeft      EQU $dbf0   ; left edge mask
DEF fRight     EQU $dbf1   ; right edge mask
DEF fMid       EQU $dbf2   ; whole tiles between the edges
DEF fPlanes    EQU $dbf3   ; plane 0 and plane 1 fill bytes ($00/$ff)
DEF fLeftN     EQU $dbf5   ; whole tiles still to write on this row

SECTION "FillRect", ROMX[$6f40], BANK[2]
FillRect::
    ld a, [wDrawOp]
    or a
    jr z, .op0
; ops 1-3: the stock loop, one DrawLine per scanline
.slow
    ld a, [wDrawX0]
    ld b, a
    ld a, [wDrawX1]
    ld d, a
    ld a, [wDrawY0]
    ld c, a
    ld e, a
    call DrawLine
    ld a, [wDrawY1]
    ld b, a
    ld a, [wDrawY0]
    cp b
    ret z
    inc a
    ld [wDrawY0], a
    jr .slow

.op0
    ; fill bytes from the color: bit 0 -> plane 0, bit 1 -> plane 1
    ld a, [wDrawColor]
    ld b, a
    xor a
    bit 0, b
    jr z, .p0
    cpl
.p0
    ld [fPlanes], a
    xor a
    bit 1, b
    jr z, .p1
    cpl
.p1
    ld [fPlanes + 1], a

    ; left mask = $ff >> (x0 & 7)
    ld a, [wDrawX0]
    and 7
    ld b, a
    ld a, $ff
    inc b
    jr .lsh
.lshl
    srl a
.lsh
    dec b
    jr nz, .lshl
    ld [fLeft], a

    ; right mask = $ff << (7 - (x1 & 7))
    ld a, [wDrawX1]
    and 7
    cpl
    add 8                   ; 7 - (x1 & 7)
    ld b, a
    ld a, $ff
    inc b
    jr .rsh
.rshl
    add a
.rsh
    dec b
    jr nz, .rshl
    ld [fRight], a

    ; tiles: t0 = x0 >> 3, t1 = x1 >> 3
    ld a, [wDrawX0]
    srl a
    srl a
    srl a
    ld b, a
    ld a, [wDrawX1]
    srl a
    srl a
    srl a
    sub b                   ; t1 - t0
    jr nz, .multi
    ; one tile: both masks in the left edge, no right edge
    ld a, [fRight]
    ld b, a
    ld a, [fLeft]
    and b
    ld [fLeft], a
    ld a, $ff
    ld [fMid], a            ; $ff = no middle, no right edge
    jr .rows
.multi
    dec a
    ld [fMid], a            ; whole tiles between the edges

.rows
    ; HL = GfxRowTable[y] + (x0 & $f8) * 2
    ld a, [wDrawY0]
    ld e, a
    ld d, 0
    ld hl, GfxRowTable
    add hl, de
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [wDrawX0]
    and $f8
    ld e, a
    add hl, de
    add hl, de

    ; left edge
    ld a, [fLeft]
    call .edge
    ld a, [fMid]
    cp $ff
    jp z, .nextrow
    ; middle: whole bytes, nothing to read
    or a
    jp z, .right
    ld [fLeftN], a
    ld a, [fPlanes]
    ld d, a
    ld a, [fPlanes + 1]
    ld e, a
    ld bc, 15               ; plane 1 to the next tile's plane 0
    ldh a, [rLCDC]
    bit 7, a
    jr nz, .batch
    ; LCD off: no waits
    ld a, [fLeftN]
.free
    ld [hl], d
    inc hl
    ld [hl], e
    add hl, bc
    dec a
    jr nz, .free
    jr .right

.batch
    ld a, [fLeftN]
    cp BATCH
    jr c, .single           ; fewer than a batch left: one pair per wait
    di
    ldh a, [rSTAT]
    and 3
    cp 1
    jr nz, .sync
    ldh a, [rLY]
    cp 144
    jr c, .sync
    cp 152
    jr c, .go               ; VBlank with at least a line left
.sync
    ldh a, [rLY]
    cp 143
    jr c, .m3
    ei                      ; end of frame: let the VBlank callback run
.vb
    ldh a, [rLY]
    cp 143
    jr c, .batch
    cp 145
    jr c, .vb
    cp 151
    jr c, .batch
    jr .vb
.m3
    ldh a, [rSTAT]
    and 3
    cp 3
    jr nz, .m3
.w0
    ldh a, [rSTAT]
    and 3
    jr nz, .w0
.go
    REPT BATCH
    ld [hl], d
    inc hl
    ld [hl], e
    add hl, bc
    ENDR
    ei
    ld a, [fLeftN]
    sub BATCH
    ld [fLeftN], a
    jr nz, .batch
    jr .right

.single
    or a
    jr z, .right
    di
.swait
    ldh a, [rSTAT]
    bit 1, a
    jr nz, .swait
    ld [hl], d
    inc hl
    ld a, e
    ei
    ld [hl], a
    add hl, bc
    ld a, [fLeftN]
    dec a
    ld [fLeftN], a
    jr .single
.right
    ld a, [fRight]
    call .edge

.nextrow
    ld a, [wDrawY1]
    ld b, a
    ld a, [wDrawY0]
    cp b
    ret z
    inc a
    ld [wDrawY0], a
    jp .rows

; One tile byte pair at HL under mask A; HL then points at the next tile.
.edge
    ld b, a
    cpl
    ld c, a                 ; keep mask
    ld a, [fPlanes]
    and b
    ld d, a                 ; plane 0 bits to set
    ld a, [fPlanes + 1]
    and b
    ld e, a                 ; plane 1 bits to set
    di
.edgewait
    ldh a, [rSTAT]
    bit 1, a
    jr nz, .edgewait
    ld a, [hl]
    and c
    or d
    ld [hl+], a
    ld a, [hl]
    and c
    or e
    ei
    ld [hl], a
    ld a, l
    add 15
    ld l, a
    ret nc
    inc h
    ret
