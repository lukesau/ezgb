; Disassembly of "kernel.gb"
; This file was created with:
; mgbdis v3.0 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $002", ROMX[$4000], BANK[$2]

; [ezgb]
; SetFpga7F30_B2: unlock $7F00/10/20, write stack u8 to $7F30, commit $7FF0.
; Same shape as SetFpgaPage but targets $7F30. SD read/write prologue uses
; $01 then $03. Sibling SdWindowPeek ($4020) reads $A000 (wait-for-ready).

SetFpga7F30_B2::
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7f30
    ld hl, sp+$02
    ld a, [hl]
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ret


; [ezgb]
; SdWindowPeek: ld a,[$a000] → E. SD paths poll until E==$e1 after SetFpga7F30.

SdWindowPeek::
    ld de, $a000
    ld a, [de]
    ld c, a
    ld e, c
    ret


; [ezgb]
; DiskRead_B2: SD sector read (FarCallDiskRead). Prologue SetFpga7F30_B2 $01; sibling DiskWrite_B2.
; Jump_002_4036: chunk loop vs count@sp+$1d; rem>4 → clamp BC=4 Jump_002_4071 else Jump_002_4065 rem then Jump_002_4071.
; Jump_002_4071: unlock $7F00/10/20=$e1/e2/e3; LBA+idx → $7FB0–B4; $7FF0=$e4; mode $03.
; Jump_002_418d: SdWindowPeek until !=$e1; Jump_002_419d: mode $01 + VramCopyStack $A000→buf, idx+=4 → Jump_002_4036.
; Jump_002_41c7: mode $00; E=0; add sp,$13 ret.

DiskRead_B2::
    add sp, -$13
    ld a, $01
    push af
    inc sp
    call SetFpga7F30_B2
    add sp, $01
    ld hl, sp+$12
    ld [hl], $00

DiskRead_B2_chunkLoop::
    ld hl, sp+$12
    ld a, [hl]
    ld hl, sp+$1d
    sub [hl]
    jp nc, DiskRead_B2_epilogueRet

    ld a, [hl]
    ld hl, sp+$0f
    ld [hl+], a
    ld [hl], $00
    inc hl
    inc hl
    ld c, [hl]
    ld b, $00
    ld hl, sp+$0f
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    sub c
    ld e, a
    ld a, d
    sbc b
    ld b, a
    ld c, e
    ld a, $04
    sub c
    ld a, $00
    sbc b
    jp nc, DiskRead_B2_remChunk

    ld bc, $0004
    jp DiskRead_B2_issueLba


DiskRead_B2_remChunk::
    ld hl, sp+$1d
    ld a, [hl]
    ld hl, sp+$12
    sub [hl]
    ld hl, sp+$0e
    ld [hl], a
    ld c, a
    ld b, $00

DiskRead_B2_issueLba::
    ld hl, sp+$11
    ld [hl], c
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld hl, sp+$0c
    ld [hl], $b0
    inc hl
    ld [hl], $7f
    ld hl, sp+$19
    ld c, [hl]
    ld a, c
    ld hl, sp+$12
    add [hl]
    ld c, a
    ld b, $00
    ld b, $00
    ld a, c
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld bc, $7fb1
    ld hl, sp+$12
    ld a, [hl]
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$19
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$08
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$1d
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$0c
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$04
    ld [hl], $00
    ld hl, sp+$09
    ld a, [hl]
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    push bc
    ld hl, $0008
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shr
    add sp, $06
    push hl
    ld hl, sp+$08
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    pop bc
    ld hl, sp+$04
    ld a, [hl]
    ld [bc], a
    ld bc, $7fb2
    ld hl, sp+$00
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$0a
    ld a, [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], $00
    push bc
    ld hl, $0010
    push hl
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
    call U32Shr
    add sp, $06
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
    ld bc, $7fb3
    ld hl, sp+$04
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$0b
    ld a, [hl]
    ld hl, sp+$07
    ld [hl], a
    push bc
    ld hl, $0018
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shr
    add sp, $06
    push hl
    ld hl, sp+$08
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    pop bc
    ld hl, sp+$04
    ld a, [hl]
    ld [bc], a
    ld bc, $7fb4
    ld hl, sp+$11
    ld a, [hl]
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call SetFpga7F30_B2
    add sp, $01

DiskRead_B2_waitPeek::
    call SdWindowPeek
    ld c, e
    ld b, $00
    ld a, c
    sub $e1
    jp nz, DiskRead_B2_copyWindow

    or b
    jp z, DiskRead_B2_waitPeek

DiskRead_B2_copyWindow::
    ld a, $01
    push af
    inc sp
    call SetFpga7F30_B2
    add sp, $01
    ld hl, sp+$0f
    ld b, [hl]
    ld a, [hl]
    add a
    ld b, a
    ld c, $00
    push bc
    ld hl, $a000
    push hl
    ld hl, sp+$22
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call VramCopyStack
    add sp, $06
    ld hl, sp+$12
    inc [hl]
    inc [hl]
    inc [hl]
    inc [hl]
    jp DiskRead_B2_chunkLoop


DiskRead_B2_epilogueRet::
    ld a, $00
    push af
    inc sp
    call SetFpga7F30_B2
    add sp, $01
    ld e, $00
    add sp, $13
    ret


; [ezgb]
; DiskWrite_B2: SD sector write (FarCallDiskWrite). Prologue SetFpga7F30_B2 $01 then $03; sibling DiskRead_B2.
; Jump_002_41ed: chunk loop vs count@sp+$1a; rem>4 → clamp Jump_002_4223 else Jump_002_421c rem then Jump_002_4223.
; Jump_002_4223: VramCopyStack buf→$A000; unlock e1/e2/e3; LBA→$7FB0–B3; $7FB4=chunk|$80; $7FF0=$e4.
; Jump_002_4350: SdWindowPeek until !=$e1; Jump_002_4360: idx+=4 → Jump_002_41ed.
; Jump_002_4369: Delay+$000a; mode $00; E=0 ret.

DiskWrite_B2::
    add sp, -$10
    ld a, $01
    push af
    inc sp
    call SetFpga7F30_B2
    add sp, $01
    ld a, $03
    push af
    inc sp
    call SetFpga7F30_B2
    add sp, $01
    ld hl, sp+$0f
    ld [hl], $00

DiskWrite_B2_chunkLoop::
    ld hl, sp+$0f
    ld a, [hl]
    ld hl, sp+$1a
    sub [hl]
    jp nc, DiskWrite_B2_epilogueRet

    ld a, [hl]
    ld hl, sp+$0c
    ld [hl+], a
    ld [hl], $00
    inc hl
    inc hl
    ld c, [hl]
    ld b, $00
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    sub c
    ld e, a
    ld a, d
    sbc b
    ld b, a
    ld c, e
    ld a, $04
    sub c
    ld a, $00
    sbc b
    rlca
    jp nc, DiskWrite_B2_remChunk

    ld c, $04
    jp DiskWrite_B2_issueLba


DiskWrite_B2_remChunk::
    ld hl, sp+$1a
    ld a, [hl]
    ld hl, sp+$0f
    sub [hl]
    ld c, a

DiskWrite_B2_issueLba::
    ld hl, sp+$0e
    ld [hl], c
    dec hl
    dec hl
    ld b, [hl]
    ld a, [hl]
    add a
    ld b, a
    ld c, $00
    push bc
    ld hl, sp+$1d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $a000
    push hl
    call VramCopyStack
    add sp, $06
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld hl, sp+$0c
    ld [hl], $b0
    inc hl
    ld [hl], $7f
    ld hl, sp+$16
    ld c, [hl]
    ld a, c
    ld hl, sp+$0f
    add [hl]
    ld c, a
    ld b, $00
    ld b, $00
    ld a, c
    ld hl, sp+$0c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld bc, $7fb1
    inc hl
    inc hl
    ld a, [hl]
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$08
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$1a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$0c
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$04
    ld [hl], $00
    ld hl, sp+$09
    ld a, [hl]
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    push bc
    ld hl, $0008
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shr
    add sp, $06
    push hl
    ld hl, sp+$08
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    pop bc
    ld hl, sp+$04
    ld a, [hl]
    ld [bc], a
    ld bc, $7fb2
    ld hl, sp+$00
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$0a
    ld a, [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], $00
    push bc
    ld hl, $0010
    push hl
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
    call U32Shr
    add sp, $06
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
    ld bc, $7fb3
    ld hl, sp+$04
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$0b
    ld a, [hl]
    ld hl, sp+$07
    ld [hl], a
    push bc
    ld hl, $0018
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shr
    add sp, $06
    push hl
    ld hl, sp+$08
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    pop bc
    ld hl, sp+$04
    ld a, [hl]
    ld [bc], a
    ld bc, $7fb4
    ld hl, sp+$0e
    ld a, [hl]
    add $80
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a

DiskWrite_B2_waitPeek::
    call SdWindowPeek
    ld c, e
    ld b, $00
    ld a, c
    sub $e1
    jp nz, DiskWrite_B2_advanceIdx

    or b
    jp z, DiskWrite_B2_waitPeek

DiskWrite_B2_advanceIdx::
    ld hl, sp+$0f
    inc [hl]
    inc [hl]
    inc [hl]
    inc [hl]
    jp DiskWrite_B2_chunkLoop


DiskWrite_B2_epilogueRet::
    ld hl, $000a
    push hl
    call Delay
    add sp, $02
    ld a, $00
    push af
    inc sp
    call SetFpga7F30_B2
    add sp, $01
    ld e, $00
    add sp, $10
    ret


FarCallOpendir_B5::
    db $f8, $04, $2a, $66, $6f, $e5, $f8, $04
    db $2a, $66, $6f, $e5, $cd, $8d, $07, $dd
    db $73, $05, $00, $e8, $04, $c9

FarCallReaddir_B5::
    db $f8, $04, $2a, $66, $6f, $e5, $f8, $04
    db $2a, $66, $6f, $e5, $cd, $8d, $07, $76
    db $75, $05, $00, $e8, $04, $c9

FarCallSetPage::
    db $f8, $02, $7e, $f5, $33, $cd, $8d, $07
    db $e7, $41, $04, $00, $e8, $01, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

FastLaunchScan::
    db $cd, $0c, $45, $3e, $03, $f5, $33, $cd
    db $ac, $43, $33, $c9, $e8, $f8, $21, $a4
    db $c4, $36, $00, $cd, $a1, $46, $f8, $07
    db $73, $7e, $b7, $c2, $4c, $46, $21, $96
    db $d7, $36, $a0, $2e, $97, $36, $d7, $2e
    db $98, $36, $fe, $2e, $99, $36, $00, $f8
    db $00, $3e, $2f, $22, $af, $22, $77, $f8
    db $05, $36, $00, $af, $f5, $33, $cd, $ac
    db $43, $33, $21, $00, $00, $39, $e5, $11
    db $00, $d9, $d5, $cd, $80, $43, $e8, $04
    db $7b, $b7, $c2, $4c, $46, $f8, $06, $36
    db $00, $cd, $54, $47, $11, $80, $d7, $d5
    db $11, $00, $d9, $d5, $cd, $96, $43, $e8
    db $04, $7b, $b7, $c2, $4c, $46, $cd, $49
    db $47, $f8, $07, $73, $7e, $b7, $c2, $33
    db $46, $fa, $88, $d7, $cb, $67, $20, $d9
    db $cd, $3b, $47, $f8, $03, $7b, $22, $7a
    db $32, $2a, $5f, $56, $1a, $fe, $2e, $28
    db $c8, $2b, $11, $4f, $46, $d5, $2a, $5f
    db $56, $d5, $cd, $03, $47, $e8, $04, $f8
    db $07, $73, $7e, $b7, $20, $b3, $11, $58
    db $46, $d5, $f8, $05, $2a, $5f, $56, $d5
    db $cd, $03, $47, $e8, $04, $f8, $07, $73
    db $7e, $b7, $20, $9d, $11, $61, $46, $d5
    db $f8, $05, $2a, $5f, $56, $d5, $cd, $03
    db $47, $e8, $04, $f8, $07, $73, $7e, $b7
    db $20, $87, $2b, $34, $7e, $f8, $02, $22
    db $2a, $5f, $56, $d5, $cd, $f2, $46, $e1
    db $f8, $05, $73, $7e, $d6, $30, $38, $02
    db $36, $2f, $f8, $07, $36, $00, $f8, $07
    db $3a, $2b, $96, $30, $20, $23, $23, $7e
    db $c6, $d0, $4f, $3e, $00, $ce, $d8, $47
    db $f8, $03, $7e, $f8, $07, $86, $2b, $2b
    db $2b, $5f, $7e, $ce, $00, $57, $1a, $02
    db $f8, $07, $34, $18, $d9, $f8, $05, $3a
    db $c6, $d0, $22, $3e, $00, $ce, $d8, $32
    db $2a, $66, $6f, $36, $00, $11, $d0, $d8
    db $d5, $cd, $65, $47, $e1, $f8, $05, $73
    db $c3, $59, $45, $f8, $02, $7e, $3d, $20
    db $13, $f8, $05, $7e, $b7, $28, $0d, $11
    db $d0, $d8, $d5, $11, $a4, $c4, $d5, $cd
    db $6d, $46, $e8, $04, $e8, $08, $c9, $65
    db $7a, $67, $62, $2e, $64, $61, $74, $00
    db $65, $7a, $67, $62, $2e, $63, $66, $67
    db $00, $66, $6c, $61, $75, $6e, $63, $68
    db $2e, $63, $66, $67, $00, $3b, $f8, $03
    db $2a, $4f, $46, $3e, $2f, $02, $f8, $00
    db $36, $00, $f8, $05, $7e, $f8, $00, $86
    db $5f, $f5, $f8, $08, $f1, $7e, $ce, $00
    db $57, $1a, $5f, $f8, $00, $56, $af, $6a
    db $67, $23, $09, $7b, $b7, $28, $06, $73
    db $f8, $00, $34, $18, $dd, $36, $00, $33
    db $c9, $21, $fc, $db, $36, $00, $cd, $00
    db $4a, $fa, $80, $da, $b7, $20, $03, $1e
    db $02, $c9, $fa, $81, $da, $b7, $20, $02
    db $5f, $c9, $0e, $00, $21, $81, $da, $46
    db $69, $26, $00, $11, $a4, $c4, $19, $79
    db $b8, $30, $0d, $c6, $82, $5f, $3e, $00
    db $ce, $da, $57, $1a, $77, $0c, $18, $e4
    db $36, $00, $1e, $01, $c9, $f8, $02, $7e
    db $d6, $61, $38, $0a, $3e, $7a, $96, $38
    db $05, $7e, $c6, $e0, $5f, $c9, $f8, $02
    db $5e, $c9, $1e, $00, $f8, $02, $2a, $83
    db $4f, $7e, $ce, $00, $47, $0a, $b7, $c8
    db $1c, $18, $f1, $16, $00, $f8, $02, $2a
    db $82, $4f, $7e, $ce, $00, $47, $0a, $d5
    db $f5, $33, $cd, $dd, $46, $33, $f1, $57
    db $f8, $04, $2a, $82, $4f, $7e, $ce, $00
    db $47, $0a, $d5, $f5, $33, $cd, $dd, $46
    db $33, $7b, $d1, $93, $28, $03, $1e, $00
    db $c9, $7b, $b7, $20, $03, $1e, $01, $c9
    db $14, $18, $ca, $fa, $a0, $d7, $b7, $28
    db $04, $11, $a0, $d7, $c9, $11, $89, $d7
    db $c9, $fa, $89, $d7, $b7, $3e, $01, $28
    db $01, $af, $5f, $c9, $af, $f5, $33, $cd
    db $ac, $43, $33, $21, $89, $d7, $36, $00
    db $2e, $a0, $36, $00, $c9, $3b, $3b, $f8
    db $04, $2a, $5f, $56, $d5, $cd, $f2, $46
    db $e1, $7b, $d6, $03, $30, $05, $1e, $00
    db $c3, $fb, $47, $f8, $00, $af, $22, $77
    db $16, $00, $7a, $93, $30, $17, $f8, $04
    db $2a, $82, $4f, $7e, $ce, $00, $47, $0a
    db $fe, $2e, $20, $06, $f8, $00, $7a, $22
    db $36, $01, $14, $18, $e5, $f8, $01, $7e
    db $b7, $20, $03, $5f, $18, $55, $f8, $00
    db $7e, $f8, $04, $86, $23, $4f, $3e, $00
    db $8e, $47, $69, $60, $23, $7e, $c5, $f5
    db $33, $cd, $dd, $46, $33, $7b, $c1, $fe
    db $47, $20, $36, $69, $60, $23, $23, $7e
    db $c5, $f5, $33, $cd, $dd, $46, $33, $7b
    db $c1, $fe, $42, $20, $24, $69, $60, $23
    db $23, $23, $7e, $b7, $20, $04, $1e, $01
    db $18, $19, $c5, $f5, $33, $cd, $dd, $46
    db $33, $7b, $c1, $fe, $43, $20, $0a, $21
    db $04, $00, $09, $7e, $b7, $1e, $01, $28
    db $02, $1e, $00, $33, $33, $c9

    rst RST_38
    rst RST_38

LastRomBox::
    db $21, $3f, $db, $36, $00, $af, $0f, $f5
    db $af, $f5, $33, $cd, $d8, $23, $e8, $03
    db $fa, $fb, $ff, $b7, $c2, $a7, $48, $21
    db $8f, $01, $e5, $21, $58, $9f, $e5, $af
    db $f5, $33, $cd, $01, $24, $e8, $05, $af
    db $0f, $f5, $af, $3e, $03, $f5, $33, $cd
    db $d8, $23, $e8, $03, $21, $8b, $01, $e5
    db $21, $5b, $9f, $e5, $af, $f5, $33, $cd
    db $01, $24, $e8, $05, $21, $01, $0c, $e5
    db $3e, $10, $f5, $33, $11, $36, $49, $d5
    db $cd, $b7, $08, $e8, $05, $21, $01, $10
    db $e5, $3e, $09, $f5, $33, $11, $47, $49
    db $d5, $cd, $b7, $08, $e8, $05, $21, $0b
    db $10, $e5, $3e, $08, $f5, $33, $11, $53
    db $49, $d5, $cd, $b7, $08, $e8, $05, $af
    db $67, $2e, $03, $e5, $3e, $03, $f5, $33
    db $cd, $d8, $23, $e8, $03, $21, $7b, $01
    db $e5, $21, $6b, $9f, $e5, $af, $f5, $33
    db $cd, $01, $24, $e8, $05, $21, $8b, $01
    db $e5, $21, $7b, $53, $e5, $3e, $53, $f5
    db $33, $cd, $01, $24, $e8, $05, $c9, $af
    db $0f, $f5, $af, $3e, $03, $f5, $33, $cd
    db $d8, $23, $e8, $03, $21, $8f, $01, $e5
    db $21, $5c, $9f, $e5, $af, $f5, $33, $cd
    db $01, $24, $e8, $05, $21, $01, $60, $e5
    db $af, $f5, $33, $11, $36, $49, $d5, $af
    db $0f, $f5, $af, $0f, $f5, $af, $0f, $f5
    db $cd, $00, $75, $e8, $0b, $21, $01, $80
    db $e5, $af, $f5, $33, $11, $47, $49, $d5
    db $af, $0f, $f5, $af, $0f, $f5, $af, $0f
    db $f5, $cd, $00, $75, $e8, $0b, $21, $8f
    db $00, $e5, $21, $5c, $9f, $e5, $af, $f5
    db $33, $cd, $01, $24, $e8, $05, $af, $67
    db $2e, $03, $e5, $3e, $03, $f5, $33, $cd
    db $d8, $23, $e8, $03, $21, $7d, $01, $e5
    db $21, $6d, $9f, $e5, $af, $f5, $33, $cd
    db $01, $24, $e8, $05, $21, $8f, $01, $e5
    db $21, $7d, $4f, $e5, $3e, $4f, $f5, $33
    db $cd, $01, $24, $e8, $05, $c9, $4c, $61
    db $75, $6e, $63, $68, $20, $4c, $61, $73
    db $74, $20, $52, $4f, $4d, $3f, $00, $5b
    db $42, $5d, $72, $65, $74, $75, $72, $6e
    db $20, $20, $20, $5b, $41, $5d, $73, $74
    db $61, $72, $74, $00

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

EzCfg::
    db $fa, $fc, $db, $b7, $ca, $98, $52, $fe
    db $01, $ca, $7c, $58, $fe, $02, $20, $08
    db $af, $f5, $33, $cd, $6c, $4c, $33, $c9
    db $fe, $06, $20, $09, $3e, $01, $f5, $33
    db $cd, $6c, $4c, $33, $c9, $fe, $07, $20
    db $13, $fa, $3a, $db, $b7, $c0, $cd, $98
    db $52, $21, $4c, $00, $e5, $cd, $0c, $4c
    db $e1, $c3, $7c, $58, $fe, $04, $ca, $67
    db $5c, $fe, $05, $ca, $bf, $5c, $fe, $08
    db $ca, $3a, $5d, $c3, $46, $4d, $21, $00
    db $7f, $36, $e1, $2e, $10, $36, $e2, $2e
    db $20, $36, $e3, $11, $c0, $7f, $f8, $02
    db $7e, $12, $21, $f0, $7f, $36, $e4, $c9
    db $21, $00, $7f, $36, $e1, $2e, $10, $36
    db $e2, $2e, $20, $36, $e3, $2e, $d0, $36
    db $01, $2e, $f0, $36, $e4, $c9, $cd, $88
    db $06, $af, $f5, $33, $cd, $4e, $4a, $33
    db $c9, $3e, $06, $f5, $33, $cd, $4e, $4a
    db $33, $0e, $00, $69, $26, $00, $11, $08
    db $a0, $19, $46, $69, $26, $00, $11, $50
    db $db, $19, $70, $69, $26, $00, $11, $48
    db $db, $19, $3e, $c4, $81, $5f, $3e, $4a
    db $ce, $00, $57, $1a, $a0, $77, $0c, $79
    db $d6, $07, $38, $d7, $af, $f5, $33, $cd
    db $4e, $4a, $33, $c9, $7f, $7f, $3f, $3f
    db $07, $1f, $ff, $3b, $3e, $06, $f5, $33
    db $cd, $4e, $4a, $33, $f8, $00, $36, $00
    db $f8, $00, $7e, $c6, $08, $4f, $3e, $00
    db $ce, $a0, $47, $f8, $03, $7e, $f8, $00
    db $86, $23, $23, $23, $23, $5f, $7e, $ce
    db $00, $57, $1a, $02, $f8, $00, $34, $7e
    db $d6, $07, $38, $dc, $cd, $68, $4a, $af
    db $f5, $33, $cd, $4e, $4a, $e1, $c9, $f8
    db $02, $7e, $e6, $0f, $fe, $0a, $38, $03
    db $1e, $00, $c9, $f8, $02, $7e, $cb, $37
    db $e6, $0f, $fe, $0a, $38, $03, $1e, $00
    db $c9, $f8, $03, $3a, $96, $3e, $00, $17
    db $ee, $01, $5f, $c9, $f8, $02, $2a, $4f
    db $46, $0a, $c5, $26, $59, $e5, $33, $f5
    db $33, $cd, $07, $4b, $e1, $7b, $c1, $b7
    db $20, $02, $5f, $c9, $69, $60, $23, $7e
    db $c5, $26, $59, $e5, $33, $f5, $33, $cd
    db $07, $4b, $e1, $7b, $c1, $b7, $20, $02
    db $5f, $c9, $69, $60, $23, $23, $7e, $c5
    db $26, $23, $e5, $33, $f5, $33, $cd, $07
    db $4b, $e1, $7b, $c1, $b7, $20, $02, $5f
    db $c9, $69, $60, $23, $23, $23, $56, $c5
    db $d5, $3e, $31, $f5, $33, $d5, $33, $cd
    db $07, $4b, $e1, $7b, $d1, $c1, $b7, $28
    db $04, $7a, $b7, $20, $03, $1e, $00, $c9
    db $21, $05, $00, $09, $56, $c5, $d5, $3e
    db $12, $f5, $33, $d5, $33, $cd, $07, $4b
    db $e1, $7b, $d1, $c1, $b7, $28, $04, $7a
    db $b7, $20, $03, $1e, $00, $c9, $21, $06
    db $00, $09, $7e, $26, $99, $e5, $33, $f5
    db $33, $cd, $07, $4b, $e1, $7b, $b7, $20
    db $02, $5f, $c9, $1e, $01, $c9, $3b, $0e
    db $00, $21, $06, $4c, $06, $00, $09, $46
    db $f8, $03, $2a, $80, $5f, $7e, $ce, $00
    db $57, $1a, $f8, $00, $77, $f8, $05, $2a
    db $80, $47, $7e, $ce, $00, $68, $67, $46
    db $f8, $00, $7e, $90, $30, $04, $1e, $ff
    db $18, $12, $78, $f8, $00, $96, $30, $04
    db $1e, $01, $18, $08, $0c, $79, $d6, $06
    db $38, $c7, $1e, $00, $33, $c9, $06, $05
    db $03, $02, $01, $00, $cd, $89, $4a, $11
    db $48, $db, $d5, $cd, $2c, $4b, $e1, $7b
    db $b7, $c8, $f8, $03, $7e, $b7, $20, $2d
    db $fa, $50, $db, $07, $d8, $fa, $47, $db
    db $b7, $28, $22, $11, $40, $db, $d5, $11
    db $48, $db, $d5, $cd, $c6, $4b, $e8, $04
    db $4b, $af, $57, $91, $cb, $7b, $28, $07
    db $cb, $7a, $20, $08, $bf, $18, $05, $cb
    db $7a, $28, $01, $37, $d0, $1e, $00, $7b
    db $c6, $40, $4f, $3e, $00, $ce, $db, $47
    db $21, $48, $db, $16, $00, $19, $7e, $02
    db $1c, $7b, $d6, $07, $38, $e9, $21, $47
    db $db, $36, $01, $c9, $fa, $3a, $db, $b7
    db $c0, $cd, $98, $52, $f8, $02, $7e, $b7
    db $3e, $54, $20, $02, $3e, $42, $f8, $02
    db $66, $e5, $33, $f5, $33, $cd, $0c, $4c
    db $e1, $c3, $7c, $58, $e8, $f3, $0e, $3c
    db $c5, $cd, $88, $06, $c1, $0d, $20, $f8
    db $cd, $89, $4a, $f8, $00, $4d, $44, $f8
    db $0b, $36, $00, $f8, $0c, $36, $00, $79
    db $f8, $0c, $86, $f5, $f8, $09, $f1, $22
    db $78, $ce, $00, $77, $f8, $0c, $3a, $2b
    db $2b, $c6, $48, $22, $3e, $00, $ce, $db
    db $32, $2a, $5f, $56, $1a, $f8, $07, $5e
    db $23, $66, $6b, $77, $f8, $0c, $34, $7e
    db $d6, $07, $38, $d3, $c5, $cd, $88, $06
    db $cd, $89, $4a, $c1, $f8, $0c, $36, $01
    db $1e, $00, $6b, $26, $00, $09, $56, $7b
    db $c6, $48, $6f, $3e, $00, $ce, $db, $67
    db $7e, $92, $28, $04, $f8, $0c, $36, $00
    db $1c, $7b, $d6, $07, $38, $e4, $f8, $0c
    db $7e, $b7, $20, $08, $f8, $0b, $34, $7e
    db $d6, $08, $38, $97, $e8, $0d, $c9, $fa
    db $4e, $db, $b7, $20, $03, $1e, $5a, $c9
    db $11, $48, $db, $d5, $cd, $2c, $4b, $e1
    db $7b, $b7, $20, $03, $1e, $49, $c9, $fa
    db $50, $db, $07, $30, $03, $1e, $56, $c9
    db $11, $40, $db, $d5, $11, $48, $db, $d5
    db $cd, $c6, $4b, $e8, $04, $4b, $cb, $79
    db $1e, $45, $c0, $1e, $00, $c9, $cd, $98
    db $52, $fa, $3a, $db, $b7, $c0, $fa, $47
    db $db, $b7, $c8, $cd, $89, $4a, $cd, $0f
    db $4d, $7b, $b7, $c8, $cd, $8c, $4c, $cd
    db $0f, $4d, $7b, $b7, $c8, $d5, $7b, $f5
    db $33, $cd, $b7, $4e, $33, $7b, $d1, $b7
    db $28, $09, $11, $40, $db, $d5, $cd, $cb
    db $4a, $e1, $c9, $7b, $d6, $56, $c0, $11
    db $48, $db, $d5, $cd, $cb, $4a, $e1, $c9
    db $f8, $04, $7e, $cb, $37, $e6, $0f, $4e
    db $2b, $2b, $f5, $79, $e6, $0f, $4f, $f1
    db $5e, $23, $56, $47, $d6, $0a, $30, $05
    db $78, $c6, $30, $18, $03, $78, $c6, $37
    db $12, $13, $41, $79, $d6, $0a, $30, $05
    db $78, $c6, $30, $18, $03, $78, $c6, $37
    db $12, $c9, $f8, $04, $2a, $c6, $06, $4f
    db $7e, $ce, $00, $47, $0a, $f5, $33, $f8
    db $03, $2a, $5f, $56, $d5, $cd, $88, $4d
    db $e8, $03, $f8, $02, $2a, $4f, $2a, $47
    db $03, $03, $3e, $2d, $02, $2a, $c6, $05
    db $4f, $7e, $ce, $00, $69, $67, $46, $f8
    db $02, $2a, $5f, $56, $13, $13, $13, $c5
    db $33, $d5, $cd, $88, $4d, $e8, $03, $f8
    db $02, $2a, $c6, $05, $4f, $7e, $ce, $00
    db $69, $67, $36, $2d, $f8, $04, $2a, $4f
    db $46, $03, $03, $03, $0a, $47, $f8, $02
    db $2a, $c6, $06, $4f, $7e, $ce, $00, $c5
    db $33, $47, $c5, $cd, $88, $4d, $e8, $03
    db $c9, $f8, $04, $2a, $4f, $46, $03, $03
    db $0a, $f5, $33, $f8, $03, $2a, $5f, $56
    db $d5, $cd, $88, $4d, $e8, $03, $f8, $02
    db $2a, $4f, $2a, $47, $03, $03, $3e, $3a
    db $02, $2a, $4f, $46, $03, $0a, $57, $f8
    db $02, $2a, $4f, $46, $03, $03, $03, $d5
    db $33, $c5, $cd, $88, $4d, $e8, $03, $f8
    db $02, $2a, $c6, $05, $4f, $7e, $ce, $00
    db $69, $67, $36, $3a, $f8, $04, $2a, $4f
    db $46, $0a, $47, $f8, $02, $2a, $c6, $06
    db $4f, $7e, $ce, $00, $c5, $33, $47, $c5
    db $cd, $88, $4d, $e8, $03, $c9, $f0, $fb
    db $b7, $28, $1f, $f8, $08, $3a, $57, $5e
    db $d5, $f8, $06, $3a, $2b, $f5, $33, $2a
    db $5f, $56, $d5, $af, $0f, $f5, $af, $0f
    db $f5, $af, $0f, $f5, $cd, $00, $75, $e8
    db $0b, $c9, $f8, $06, $3a, $57, $3a, $5f
    db $d5, $3a, $2b, $f5, $33, $2a, $5f, $56
    db $d5, $cd, $b7, $08, $e8, $05, $c9, $e8
    db $f5, $f8, $0d, $7e, $d6, $5a, $20, $05
    db $01, $7d, $51, $18, $1b, $f8, $0d, $7e
    db $d6, $49, $20, $05, $01, $88, $51, $18
    db $0f, $f8, $0d, $7e, $d6, $56, $20, $05
    db $01, $91, $51, $18, $03, $01, $9c, $51
    db $1e, $00, $6b, $26, $00, $09, $7e, $b7
    db $28, $03, $1c, $18, $f5, $f8, $00, $73
    db $f0, $fb, $f8, $0a, $32, $36, $00, $c5
    db $21, $05, $08, $e5, $3e, $01, $f5, $33
    db $11, $7b, $51, $d5, $cd, $b7, $08, $e8
    db $05, $af, $0f, $f5, $af, $f5, $33, $cd
    db $d8, $23, $e8, $03, $21, $7f, $01, $e5
    db $21, $10, $9f, $e5, $af, $f5, $33, $cd
    db $01, $24, $e8, $05, $af, $0f, $f5, $af
    db $3e, $03, $f5, $33, $cd, $d8, $23, $e8
    db $03, $c1, $f8, $0a, $7e, $b7, $28, $14
    db $c5, $21, $73, $01, $e5, $21, $14, $9f
    db $e5, $af, $f5, $33, $cd, $01, $24, $e8
    db $05, $c1, $18, $12, $c5, $21, $63, $01
    db $e5, $21, $1b, $9f, $e5, $af, $f5, $33
    db $cd, $01, $24, $e8, $05, $c1, $21, $01
    db $18, $e5, $21, $01, $04, $e5, $f8, $04
    db $7e, $f5, $33, $c5, $cd, $7e, $4e, $e8
    db $07, $21, $01, $2c, $e5, $21, $01, $06
    db $e5, $3e, $04, $f5, $33, $11, $a8, $51
    db $d5, $cd, $7e, $4e, $e8, $07, $21, $01
    db $00, $39, $e5, $11, $50, $db, $d5, $e5
    db $cd, $ba, $4d, $e8, $04, $e1, $e5, $11
    db $3c, $2c, $d5, $11, $06, $06, $d5, $3e
    db $08, $f5, $33, $e5, $cd, $7e, $4e, $e8
    db $07, $e1, $e5, $11, $50, $db, $d5, $e5
    db $cd, $21, $4e, $e8, $04, $e1, $e5, $11
    db $3c, $38, $d5, $11, $06, $07, $d5, $3e
    db $08, $f5, $33, $e5, $cd, $7e, $4e, $e8
    db $07, $21, $01, $44, $e5, $21, $01, $08
    db $e5, $3e, $02, $f5, $33, $11, $ad, $51
    db $d5, $cd, $7e, $4e, $e8, $07, $e1, $e5
    db $11, $40, $db, $d5, $e5, $cd, $ba, $4d
    db $e8, $04, $e1, $e5, $11, $3c, $44, $d5
    db $11, $06, $08, $d5, $3e, $08, $f5, $33
    db $e5, $cd, $7e, $4e, $e8, $07, $e1, $e5
    db $11, $40, $db, $d5, $e5, $cd, $21, $4e
    db $e8, $04, $e1, $11, $3c, $50, $d5, $11
    db $06, $09, $d5, $3e, $08, $f5, $33, $e5
    db $cd, $7e, $4e, $e8, $07, $f8, $0a, $7e
    db $b7, $ca, $a8, $50, $21, $01, $64, $e5
    db $3e, $07, $f5, $33, $11, $b0, $51, $d5
    db $af, $0f, $f5, $af, $0f, $f5, $af, $0f
    db $f5, $cd, $00, $75, $e8, $0b, $21, $58
    db $64, $e5, $af, $f5, $33, $11, $ba, $51
    db $d5, $af, $0f, $f5, $af, $0f, $f5, $af
    db $0f, $f5, $cd, $00, $75, $e8, $0b, $21
    db $73, $00, $e5, $21, $14, $9f, $e5, $af
    db $f5, $33, $cd, $01, $24, $e8, $05, $af
    db $67, $2e, $03, $e5, $3e, $03, $f5, $33
    db $cd, $d8, $23, $e8, $03, $21, $26, $01
    db $e5, $21, $26, $9f, $e5, $af, $f5, $33
    db $cd, $01, $24, $e8, $05, $21, $5f, $01
    db $e5, $21, $5f, $9f, $e5, $af, $f5, $33
    db $cd, $01, $24, $e8, $05, $21, $73, $01
    db $e5, $21, $5f, $4f, $e5, $3e, $4f, $f5
    db $33, $cd, $01, $24, $e8, $05, $18, $61
    db $21, $01, $0b, $e5, $3e, $07, $f5, $33
    db $11, $b0, $51, $d5, $cd, $b7, $08, $e8
    db $05, $21, $0a, $0b, $e5, $3e, $09, $f5
    db $33, $11, $ba, $51, $d5, $cd, $b7, $08
    db $e8, $05, $af, $67, $2e, $03, $e5, $3e
    db $03, $f5, $33, $cd, $d8, $23, $e8, $03
    db $21, $2b, $01, $e5, $21, $2b, $9f, $e5
    db $af, $f5, $33, $cd, $01, $24, $e8, $05
    db $21, $53, $01, $e5, $21, $53, $9f, $e5
    db $af, $f5, $33, $cd, $01, $24, $e8, $05
    db $21, $63, $01, $e5, $21, $53, $4b, $e5
    db $3e, $4b, $f5, $33, $cd, $01, $24, $e8
    db $05, $af, $0f, $f5, $af, $3e, $03, $f5
    db $33, $cd, $d8, $23, $e8, $03, $f8, $0a
    db $36, $00, $cd, $88, $06, $cd, $91, $36
    db $7b, $e6, $30, $28, $06, $f8, $0a, $36
    db $00, $18, $03, $f8, $0a, $34, $f8, $0a
    db $7e, $d6, $08, $38, $e5, $cd, $88, $06
    db $cd, $91, $36, $cb, $63, $28, $06, $f8
    db $0a, $36, $01, $18, $08, $cb, $6b, $28
    db $ec, $f8, $0a, $36, $00, $cd, $91, $36
    db $7b, $e6, $30, $28, $05, $cd, $88, $06
    db $18, $f3, $af, $0f, $f5, $af, $f5, $33
    db $cd, $d8, $23, $e8, $03, $21, $7f, $01
    db $e5, $21, $10, $9f, $e5, $af, $f5, $33
    db $cd, $01, $24, $e8, $05, $f8, $0a, $5e
    db $e8, $0b, $c9, $20, $00, $52, $54, $43
    db $20, $52, $45, $53, $45, $54, $3f, $00
    db $52, $54, $43, $20, $42, $41, $44, $3f
    db $00, $52, $54, $43, $20, $4c, $4f, $57
    db $20, $56, $3f, $00, $52, $54, $43, $20
    db $42, $45, $48, $49, $4e, $44, $3f, $00
    db $43, $48, $49, $50, $00, $53, $44, $00
    db $5b, $42, $5d, $6b, $65, $65, $70, $20
    db $20, $20, $5b, $41, $5d, $75, $73, $65
    db $20, $53, $44, $00, $3b, $f8, $00, $36
    db $00, $f8, $00, $5e, $16, $db, $f8, $03
    db $7e, $f8, $00, $86, $23, $23, $23, $23
    db $4f, $7e, $ce, $00, $47, $0a, $12, $0a
    db $b7, $28, $05, $f8, $00, $34, $18, $e1
    db $33, $c9, $f8, $02, $2a, $5f, $56, $d5
    db $cd, $c4, $51, $e1, $cd, $7e, $4a, $3e
    db $01, $f5, $33, $11, $00, $db, $d5, $11
    db $0f, $ca, $d5, $cd, $0d, $19, $e8, $05
    db $7b, $b7, $28, $03, $1e, $00, $c9, $cd
    db $7e, $4a, $f8, $04, $2a, $5f, $56, $d5
    db $11, $00, $02, $d5, $11, $00, $d8, $d5
    db $11, $0f, $ca, $d5, $cd, $28, $19, $e8
    db $08, $d5, $cd, $7e, $4a, $01, $0f, $ca
    db $c5, $cd, $88, $19, $e1, $d1, $f8, $04
    db $2a, $4f, $46, $7b, $b7, $28, $06, $af
    db $02, $03, $02, $18, $17, $69, $60, $2a
    db $66, $6f, $3e, $ff, $bd, $3e, $00, $9c
    db $30, $0a, $7c, $d6, $02, $30, $05, $7d
    db $02, $03, $af, $02, $1e, $01, $c9, $3b
    db $3b, $cd, $7e, $4a, $f8, $00, $e5, $f8
    db $08, $2a, $5f, $56, $d5, $f8, $08, $2a
    db $5f, $56, $d5, $11, $0f, $ca, $d5, $cd
    db $4a, $19, $e8, $08, $7b, $b7, $20, $15
    db $f8, $00, $7e, $f8, $06, $96, $20, $0b
    db $f8, $01, $7e, $f8, $07, $96, $20, $03
    db $5f, $18, $02, $1e, $ff, $33, $33, $c9
    db $3b, $3b, $21, $80, $da, $36, $01, $2e
    db $81, $36, $00, $2e, $82, $36, $00, $21
    db $47, $db, $36, $00, $21, $7f, $da, $36
    db $00, $2e, $00, $75, $21, $3a, $db, $36
    db $00, $f8, $00, $e5, $e5, $11, $fb, $52
    db $d5, $cd, $ea, $51, $e8, $04, $7b, $e1
    db $b7, $28, $10, $af, $f5, $33, $f8, $01
    db $2a, $5f, $56, $d5, $cd, $12, $53, $e8
    db $03, $18, $1d, $e5, $11, $05, $53, $d5
    db $cd, $ea, $51, $e8, $04, $7b, $b7, $28
    db $0f, $3e, $01, $f5, $33, $f8, $01, $2a
    db $5f, $56, $d5, $cd, $12, $53, $e8, $03
    db $33, $33, $c9, $2f, $45, $5a, $47, $42
    db $2e, $43, $46, $47, $00, $2f, $46, $4c
    db $41, $55, $4e, $43, $48, $2e, $43, $46
    db $47, $00, $e8, $ee, $f8, $14, $af, $96
    db $23, $3e, $02, $9e, $30, $06, $f8, $14
    db $af, $22, $36, $02, $f8, $14, $2a, $4f
    db $7e, $c6, $d8, $47, $af, $02, $f8, $00
    db $af, $22, $22, $af, $22, $22, $af, $22
    db $22, $77, $f8, $05, $5d, $54, $f8, $14
    db $1a, $13, $96, $23, $1a, $9e, $d2, $99
    db $56, $f8, $05, $2a, $4f, $46, $f8, $14
    db $79, $96, $23, $78, $9e, $30, $0c, $21
    db $00, $d8, $09, $7e, $fe, $20, $20, $03
    db $03, $18, $eb, $f8, $0d, $79, $22, $78
    db $22, $23, $79, $22, $70, $f8, $10, $5d
    db $54, $f8, $14, $1a, $13, $96, $23, $1a
    db $9e, $30, $2a, $f8, $10, $7e, $f5, $f8
    db $0d, $f1, $77, $f5, $f8, $13, $f1, $7e
    db $c6, $d8, $f8, $0c, $32, $2a, $5f, $56
    db $1a, $fe, $0d, $28, $10, $fe, $0a, $28
    db $0c, $b7, $28, $09, $f8, $10, $34, $20
    db $cc, $23, $34, $18, $c8, $f8, $10, $7e
    db $f8, $07, $77, $f8, $11, $7e, $f8, $08
    db $77, $f8, $10, $2a, $4f, $46, $f8, $14
    db $79, $96, $23, $78, $9e, $30, $10, $21
    db $00, $d8, $09, $7e, $fe, $0d, $28, $04
    db $fe, $0a, $20, $03, $03, $18, $e7, $f8
    db $05, $79, $22, $78, $22, $2a, $4f, $7e
    db $c6, $d8, $47, $0a, $b7, $20, $1a, $f8
    db $07, $5d, $54, $f8, $14, $1a, $13, $96
    db $23, $1a, $9e, $30, $0c, $f8, $14, $7e
    db $f8, $05, $77, $f8, $15, $7e, $f8, $06
    db $77, $f8, $0d, $5d, $54, $f8, $07, $1a
    db $13, $96, $23, $1a, $9e, $30, $36, $f8
    db $07, $2a, $23, $23, $23, $c6, $ff, $32
    db $2b, $2b, $7e, $ce, $ff, $f8, $0c, $32
    db $7e, $f5, $f8, $12, $f1, $32, $2b, $2b
    db $2b, $7e, $c6, $d8, $f8, $11, $32, $2a
    db $5f, $56, $1a, $fe, $20, $20, $0e, $f8
    db $0b, $7e, $f8, $07, $77, $f8, $0c, $7e
    db $f8, $08, $77, $18, $bc, $f8, $07, $7e
    db $f8, $0d, $96, $20, $09, $f8, $08, $7e
    db $f8, $0e, $96, $ca, $3a, $53, $f8, $07
    db $4e, $f8, $0d, $46, $3a, $2b, $2b, $2b
    db $77, $f5, $f8, $10, $f1, $7e, $c6, $d8
    db $f8, $0a, $77, $f8, $16, $7e, $b7, $28
    db $12, $79, $90, $f5, $33, $f8, $0a, $2a
    db $5f, $56, $d5, $cd, $0a, $57, $e8, $03
    db $c3, $99, $56, $f8, $0d, $2a, $5f, $56
    db $f8, $07, $7b, $96, $23, $7a, $9e, $3e
    db $00, $17, $f8, $11, $77, $6b, $62, $23
    db $e5, $7d, $f8, $11, $77, $e1, $7c, $f8
    db $10, $22, $7e, $b7, $28, $10, $21, $00
    db $d8, $19, $7e, $fe, $3d, $28, $07, $f8
    db $0f, $2a, $5f, $56, $18, $d2, $f8, $11
    db $cb, $46, $ca, $3a, $53, $7b, $90, $f8
    db $11, $32, $2b, $2a, $5f, $56, $f8, $11
    db $7e, $b7, $28, $1e, $3a, $2b, $22, $af
    db $32, $3a, $2b, $86, $23, $47, $3e, $00
    db $8e, $68, $67, $2b, $7c, $c6, $d8, $67
    db $7e, $fe, $20, $20, $05, $f8, $11, $35
    db $18, $dc, $f8, $11, $7e, $f8, $0b, $77
    db $f8, $10, $7b, $22, $72, $f8, $10, $3a
    db $2b, $22, $23, $23, $3a, $2b, $c6, $d8
    db $77, $f8, $10, $5d, $54, $f8, $07, $1a
    db $13, $96, $23, $1a, $9e, $30, $12, $f8
    db $0e, $2a, $5f, $56, $1a, $fe, $20, $20
    db $08, $23, $34, $20, $d8, $23, $34, $18
    db $d4, $f8, $10, $7e, $f8, $0c, $77, $f8
    db $11, $7e, $f8, $0d, $77, $f8, $00, $7e
    db $b7, $20, $35, $c5, $3e, $07, $f5, $33
    db $11, $9c, $56, $d5, $f8, $10, $3a, $2b
    db $f5, $33, $2a, $5f, $56, $d5, $cd, $ce
    db $56, $e8, $06, $7b, $c1, $b7, $28, $18
    db $f8, $00, $36, $01, $f8, $10, $79, $96
    db $2b, $2b, $f5, $33, $2a, $5f, $56, $d5
    db $cd, $0a, $57, $e8, $03, $c3, $3a, $53
    db $f8, $0c, $2a, $23, $32, $2a, $23, $c6
    db $d8, $77, $f8, $01, $7e, $b7, $20, $35
    db $c5, $3e, $03, $f5, $33, $11, $a4, $56
    db $d5, $f8, $10, $3a, $2b, $f5, $33, $2a
    db $5f, $56, $d5, $cd, $ce, $56, $e8, $06
    db $c1, $7b, $b7, $28, $18, $f8, $01, $36
    db $01, $f8, $0c, $79, $96, $23, $23, $f5
    db $33, $2a, $5f, $56, $d5, $cd, $98, $57
    db $e8, $03, $c3, $3a, $53, $f8, $07, $7e
    db $f8, $0c, $96, $23, $23, $23, $23, $77
    db $f5, $f8, $0a, $f1, $7e, $f5, $f8, $0f
    db $f1, $9e, $f8, $11, $77, $f8, $02, $7e
    db $b7, $20, $33, $3e, $07, $f5, $33, $11
    db $a8, $56, $d5, $f8, $0e, $3a, $2b, $f5
    db $33, $2a, $5f, $56, $d5, $cd, $ce, $56
    db $e8, $06, $7b, $b7, $28, $18, $f8, $02
    db $36, $01, $f8, $10, $2a, $5f, $56, $d5
    db $f8, $10, $2a, $5f, $56, $d5, $cd, $a4
    db $5b, $e8, $04, $c3, $3a, $53, $f8, $03
    db $7e, $b7, $20, $55, $3e, $02, $f5, $33
    db $11, $b0, $56, $d5, $f8, $0e, $3a, $2b
    db $f5, $33, $2a, $5f, $56, $d5, $cd, $ce
    db $56, $e8, $06, $7b, $b7, $28, $3a, $f8
    db $03, $36, $01, $f8, $10, $2a, $d6, $02
    db $7e, $de, $00, $38, $20, $2b, $2b, $2b
    db $2a, $5f, $56, $1a, $fe, $31, $20, $15
    db $f8, $0c, $2a, $4f, $46, $03, $21, $00
    db $d8, $09, $7e, $fe, $32, $20, $06, $f8
    db $11, $36, $01, $18, $04, $f8, $11, $36
    db $00, $f8, $11, $7e, $e0, $fb, $c3, $3a
    db $53, $f8, $04, $7e, $b7, $c2, $3a, $53
    db $3e, $05, $f5, $33, $11, $b3, $56, $d5
    db $f8, $0e, $3a, $2b, $f5, $33, $2a, $5f
    db $56, $d5, $cd, $ce, $56, $e8, $06, $7b
    db $b7, $ca, $3a, $53, $f8, $04, $36, $01
    db $f8, $0c, $5d, $54, $f8, $07, $1a, $13
    db $96, $23, $1a, $9e, $30, $0c, $f8, $0e
    db $2a, $5f, $56, $1a, $fe, $30, $3e, $01
    db $28, $01, $af, $ea, $3a, $db, $c3, $3a
    db $53, $e8, $12, $c9, $66, $6c, $61, $75
    db $6e, $63, $68, $00, $72, $74, $63, $00
    db $6c, $61, $73, $74, $72, $6f, $6d, $00
    db $75, $69, $00, $72, $74, $63, $73, $64
    db $00, $f8, $02, $7e, $d6, $41, $38, $0a
    db $3e, $5a, $96, $38, $05, $7e, $c6, $20
    db $5f, $c9, $f8, $02, $5e, $c9, $f8, $04
    db $7e, $f8, $07, $96, $28, $03, $1e, $00
    db $c9, $16, $00, $7a, $f8, $04, $96, $30
    db $26, $2b, $2b, $2a, $82, $4f, $7e, $ce
    db $00, $47, $0a, $d5, $f5, $33, $cd, $b9
    db $56, $33, $f1, $57, $f8, $05, $2a, $82
    db $4f, $7e, $ce, $00, $47, $0a, $93, $28
    db $03, $1e, $00, $c9, $14, $18, $d4, $1e
    db $01, $c9, $3b, $3b, $f8, $01, $36, $00
    db $f8, $06, $7e, $b7, $28, $26, $2b, $2b
    db $2a, $4f, $46, $0a, $fe, $23, $20, $1c
    db $21, $80, $da, $36, $00, $1e, $01, $7b
    db $f8, $06, $96, $30, $0c, $6b, $26, $00
    db $09, $7e, $fe, $20, $20, $03, $1c, $18
    db $ee, $f8, $01, $73, $f8, $01, $7e, $f8
    db $06, $96, $30, $51, $0e, $00, $f8, $04
    db $7e, $f8, $01, $86, $23, $23, $23, $23
    db $5f, $7e, $ce, $00, $57, $1a, $fe, $2f
    db $28, $07, $0e, $01, $21, $82, $da, $36
    db $2f, $f8, $01, $46, $79, $c6, $82, $f5
    db $f8, $02, $f1, $22, $3e, $00, $ce, $da
    db $77, $78, $f8, $06, $96, $30, $16, $79
    db $d6, $78, $30, $11, $2b, $2b, $0c, $2a
    db $80, $5f, $7e, $ce, $00, $57, $1a, $e1
    db $e5, $77, $04, $18, $d7, $e1, $36, $00
    db $e5, $21, $81, $da, $71, $33, $33, $c9
    db $e8, $f2, $0e, $00, $59, $16, $00, $21
    db $02, $00, $39, $19, $36, $00, $0c, $79
    db $d6, $06, $38, $f0, $f8, $08, $af, $22
    db $22, $23, $af, $22, $22, $36, $00, $f8
    db $0d, $7e, $f8, $12, $96, $30, $12, $2b
    db $2b, $7e, $f8, $0d, $86, $23, $23, $23
    db $23, $4f, $7e, $ce, $00, $47, $0a, $18
    db $01, $af, $f8, $0a, $77, $d6, $30, $38
    db $11, $3e, $39, $96, $38, $0c, $2b, $3a
    db $22, $23, $3a, $c6, $d0, $22, $23, $34
    db $18, $30, $f8, $0b, $7e, $b7, $28, $1e
    db $23, $7e, $d6, $06, $30, $18, $5e, $16
    db $00, $21, $02, $00, $39, $19, $d1, $e5
    db $f8, $0c, $34, $f8, $08, $2a, $cb, $37
    db $e6, $f0, $b6, $e1, $e5, $77, $f8, $08
    db $af, $22, $22, $23, $af, $32, $7e, $b7
    db $28, $0b, $f8, $0d, $34, $f8, $12, $7e
    db $f8, $0d, $96, $30, $92, $f8, $0c, $7e
    db $d6, $06, $38, $35, $f8, $02, $7e, $ea
    db $46, $db, $f8, $03, $7e, $ea, $45, $db
    db $f8, $04, $7e, $21, $43, $db, $77, $2e
    db $44, $36, $03, $f8, $05, $7e, $ea, $42
    db $db, $f8, $06, $7e, $ea, $41, $db, $f8
    db $07, $7e, $ea, $40, $db, $11, $40, $db
    db $d5, $cd, $2c, $4b, $e1, $7b, $ea, $47
    db $db, $e8, $0e, $c9, $f8, $02, $2a, $4f
    db $2a, $47, $7e, $cb, $37, $e6, $0f, $c6
    db $30, $02, $03, $7e, $e6, $0f, $c6, $30
    db $02, $1e, $02, $c9, $e8, $fc, $af, $f8
    db $02, $22, $77, $0e, $00, $f8, $02, $2a
    db $5f, $3a, $c6, $d8, $57, $34, $20, $02
    db $23, $34, $21, $84, $5b, $06, $00, $09
    db $7e, $12, $0c, $79, $d6, $08, $38, $e5
    db $f8, $02, $2a, $4f, $46, $fa, $80, $da
    db $b7, $20, $0f, $2b, $2a, $4f, $3a, $47
    db $03, $2a, $5f, $7e, $c6, $d8, $57, $3e
    db $23, $12, $d1, $c5, $f8, $03, $36, $00
    db $fa, $81, $da, $f8, $02, $77, $d1, $d5
    db $13, $f8, $00, $2a, $4f, $2a, $23, $c6
    db $d8, $47, $3a, $96, $30, $12, $e1, $d5
    db $f8, $03, $7e, $c6, $82, $5f, $3e, $00
    db $ce, $da, $57, $1a, $02, $34, $18, $d8
    db $3e, $0d, $02, $4b, $42, $13, $f8, $02
    db $73, $23, $72, $21, $00, $d8, $09, $36
    db $0a, $fa, $47, $db, $b7, $ca, $09, $5a
    db $f8, $02, $2a, $4f, $46, $36, $00, $21
    db $00, $d8, $09, $e5, $7d, $f8, $03, $77
    db $e1, $7c, $f8, $02, $22, $03, $3e, $8c
    db $86, $2b, $2b, $5f, $3e, $5b, $ce, $00
    db $57, $1a, $5e, $23, $66, $6b, $77, $f8
    db $03, $34, $7e, $d6, $06, $38, $d8, $21
    db $46, $db, $66, $59, $78, $c6, $d8, $c5
    db $e5, $33, $57, $d5, $cd, $64, $58, $e8
    db $03, $c1, $6b, $26, $00, $09, $4d, $44
    db $59, $50, $03, $21, $00, $d8, $19, $36
    db $2d, $21, $45, $db, $66, $59, $78, $c6
    db $d8, $c5, $e5, $33, $57, $d5, $cd, $64
    db $58, $e8, $03, $c1, $6b, $26, $00, $09
    db $4d, $44, $59, $50, $03, $21, $00, $d8
    db $19, $36, $2d, $21, $43, $db, $66, $59
    db $78, $c6, $d8, $c5, $e5, $33, $57, $d5
    db $cd, $64, $58, $e8, $03, $c1, $6b, $26
    db $00, $09, $4d, $44, $59, $50, $03, $21
    db $00, $d8, $19, $36, $20, $21, $42, $db
    db $66, $59, $78, $c6, $d8, $c5, $e5, $33
    db $57, $d5, $cd, $64, $58, $e8, $03, $c1
    db $6b, $26, $00, $09, $4d, $44, $59, $50
    db $03, $21, $00, $d8, $19, $36, $3a, $21
    db $41, $db, $66, $59, $78, $c6, $d8, $c5
    db $e5, $33, $57, $d5, $cd, $64, $58, $e8
    db $03, $c1, $6b, $26, $00, $09, $4d, $44
    db $59, $50, $03, $21, $00, $d8, $19, $36
    db $3a, $21, $40, $db, $66, $59, $78, $c6
    db $d8, $c5, $e5, $33, $57, $d5, $cd, $64
    db $58, $e8, $03, $c1, $6b, $26, $00, $09
    db $5d, $54, $4b, $42, $13, $21, $00, $d8
    db $09, $36, $0d, $4b, $42, $13, $f8, $02
    db $73, $23, $72, $21, $00, $d8, $09, $36
    db $0a, $fa, $7f, $da, $b7, $28, $74, $f8
    db $02, $2a, $4f, $46, $36, $00, $21, $00
    db $d8, $09, $e5, $7d, $f8, $03, $77, $e1
    db $7c, $f8, $02, $22, $03, $3e, $92, $86
    db $2b, $2b, $5f, $3e, $5b, $ce, $00, $57
    db $1a, $5e, $23, $66, $6b, $77, $f8, $03
    db $34, $7e, $d6, $08, $38, $d8, $36, $00
    db $f8, $03, $5e, $16, $da, $1a, $f8, $00
    db $77, $69, $60, $23, $e5, $7d, $f8, $03
    db $77, $e1, $7c, $f8, $02, $77, $21, $00
    db $d8, $09, $5d, $54, $f8, $00, $7e, $b7
    db $28, $0d, $23, $2a, $4f, $3a, $2b, $47
    db $7e, $12, $f8, $03, $34, $18, $d1, $f8
    db $01, $2a, $4f, $46, $3e, $0d, $12, $59
    db $50, $03, $71, $23, $70, $21, $00, $d8
    db $19, $36, $0a, $0e, $00, $f8, $02, $2a
    db $5f, $3a, $c6, $d8, $57, $34, $20, $02
    db $23, $34, $21, $9a, $5b, $06, $00, $09
    db $7e, $12, $0c, $79, $d6, $03, $38, $e5
    db $f8, $02, $2a, $4f, $46, $f0, $fb, $b7
    db $28, $0f, $2b, $2a, $4f, $3a, $47, $03
    db $2a, $5f, $7e, $c6, $d8, $57, $3e, $31
    db $12, $79, $58, $03, $f5, $f8, $04, $f1
    db $22, $7b, $c6, $d8, $77, $f0, $fb, $b7
    db $3e, $32, $20, $02, $3e, $38, $f8, $02
    db $5e, $23, $66, $6b, $77, $59, $50, $03
    db $21, $00, $d8, $19, $36, $0d, $59, $50
    db $03, $21, $00, $d8, $19, $36, $0a, $fa
    db $3a, $db, $f8, $03, $77, $7e, $b7, $28
    db $3e, $36, $00, $21, $00, $d8, $09, $e5
    db $7d, $f8, $03, $77, $e1, $7c, $f8, $02
    db $22, $03, $3e, $9d, $86, $2b, $2b, $5f
    db $3e, $5b, $ce, $00, $57, $1a, $5e, $23
    db $66, $6b, $77, $f8, $03, $34, $7e, $d6
    db $07, $38, $d8, $59, $50, $13, $21, $00
    db $d8, $09, $36, $0d, $6b, $62, $4b, $42
    db $03, $11, $00, $d8, $19, $36, $0a, $78
    db $d6, $02, $30, $09, $21, $00, $d8, $09
    db $03, $36, $20, $18, $f2, $11, $7a, $5b
    db $d5, $cd, $c4, $51, $e1, $cd, $7e, $4a
    db $3e, $0a, $f5, $33, $11, $00, $db, $d5
    db $11, $0f, $ca, $d5, $cd, $0d, $19, $e8
    db $05, $7b, $b7, $20, $1a, $11, $00, $02
    db $d5, $11, $00, $d8, $d5, $cd, $5f, $52
    db $e8, $04, $d5, $cd, $7e, $4a, $01, $0f
    db $ca, $c5, $cd, $88, $19, $e1, $d1, $e8
    db $04, $c9, $2f, $45, $5a, $47, $42, $2e
    db $43, $46, $47, $00, $46, $4c, $41, $55
    db $4e, $43, $48, $3d, $52, $54, $43, $3d
    db $32, $30, $4c, $41, $53, $54, $52, $4f
    db $4d, $3d, $55, $49, $3d, $52, $54, $43
    db $53, $44, $3d, $30, $e8, $fb, $f8, $0a
    db $3a, $b6, $28, $5a, $f8, $04, $36, $00
    db $f8, $07, $2a, $4f, $46, $0a, $fe, $2f
    db $28, $09, $f8, $04, $36, $01, $21, $00
    db $da, $36, $2f, $f8, $04, $3a, $2b, $22
    db $af, $22, $77, $f8, $02, $3a, $2b, $22
    db $36, $da, $f8, $03, $5d, $54, $f8, $09
    db $1a, $13, $96, $23, $1a, $9e, $30, $1d
    db $f8, $02, $7e, $d6, $78, $30, $16, $34
    db $23, $79, $86, $23, $5f, $78, $8e, $57
    db $1a, $e1, $e5, $77, $f8, $03, $34, $20
    db $d2, $23, $34, $18, $ce, $e1, $36, $00
    db $e5, $21, $7f, $da, $36, $01, $e8, $05
    db $c9, $3b, $3b, $f8, $04, $2a, $4f, $46
    db $0a, $fe, $2f, $28, $04, $1e, $00, $18
    db $4b, $f8, $00, $af, $22, $16, $01, $72
    db $1e, $01, $7b, $3c, $20, $03, $5f, $18
    db $3b, $6b, $26, $00, $09, $7e, $b7, $28
    db $24, $fe, $20, $38, $04, $fe, $ff, $20
    db $04, $1e, $00, $18, $27, $fe, $2f, $20
    db $06, $53, $14, $f8, $00, $36, $00, $fe
    db $2e, $20, $04, $f8, $00, $36, $01, $1c
    db $f8, $01, $73, $18, $cd, $7a, $f8, $01
    db $96, $30, $07, $2b, $7e, $b7, $1e, $01
    db $20, $02, $1e, $00, $33, $33, $c9, $cd
    db $98, $52, $1e, $00, $3e, $78, $93, $3e
    db $00, $17, $47, $cb, $40, $20, $0d, $21
    db $a6, $c2, $16, $00, $19, $7e, $b7, $28
    db $03, $1c, $18, $e8, $7b, $4f, $b7, $28
    db $24, $cb, $40, $20, $20, $06, $00, $78
    db $91, $30, $11, $58, $16, $da, $78, $c6
    db $a6, $6f, $3e, $00, $ce, $c2, $67, $7e
    db $12, $04, $18, $eb, $06, $da, $af, $02
    db $21, $7f, $da, $36, $01, $fa, $3a, $db
    db $b7, $c2, $7c, $58, $21, $4c, $00, $e5
    db $cd, $0c, $4c, $e1, $c3, $7c, $58, $11
    db $a4, $c4, $d5, $cd, $09, $5c, $e1, $7b
    db $b7, $28, $06, $21, $fb, $db, $36, $01
    db $c9, $cd, $98, $52, $fa, $7f, $da, $b7
    db $28, $2f, $11, $00, $da, $d5, $cd, $09
    db $5c, $e1, $7b, $b7, $28, $23, $0e, $00
    db $69, $26, $00, $11, $a4, $c4, $19, $59
    db $16, $da, $1a, $77, $1a, $b7, $28, $03
    db $0c, $18, $ed, $3e, $03, $f5, $33, $cd
    db $4e, $4a, $33, $21, $fb, $db, $36, $01
    db $c9, $21, $01, $0f, $e5, $3e, $12, $f5
    db $33, $11, $33, $5d, $d5, $af, $0f, $f5
    db $af, $0f, $f5, $af, $0f, $f5, $cd, $60
    db $72, $e8, $0b, $cd, $88, $06, $cd, $91
    db $36, $cb, $6b, $28, $f6, $21, $fb, $db
    db $36, $00, $c9, $28, $6e, $6f, $6e, $65
    db $29, $00, $21, $fb, $db, $36, $00, $01
    db $65, $5d, $1e, $00, $21, $a5, $c3, $16
    db $00, $19, $56, $6b, $26, $00, $09, $7e
    db $92, $c0, $1c, $7b, $d6, $07, $38, $ec
    db $11, $a5, $c3, $d5, $cd, $09, $5c, $e1
    db $7b, $ea, $fb, $db, $c9, $2f, $53, $41
    db $56, $45, $52, $2f

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

TabStrip12::
    db $e8, $d3, $af, $0f, $f5, $af, $f5, $33
    db $cd, $d8, $23, $e8, $03, $f8, $33, $7e
    db $d6, $03, $3e, $01, $28, $01, $af, $4f
    db $f8, $33, $7e, $b7, $20, $14, $c5, $21
    db $13, $01, $e5, $3e, $9f, $f5, $33, $af
    db $0f, $f5, $cd, $01, $24, $e8, $05, $c1
    db $18, $2a, $79, $b7, $28, $14, $c5, $21
    db $8f, $01, $e5, $21, $0d, $9f, $e5, $af
    db $f5, $33, $cd, $01, $24, $e8, $05, $c1
    db $18, $12, $c5, $21, $8f, $01, $e5, $3e
    db $9f, $f5, $33, $af, $0f, $f5, $cd, $01
    db $24, $e8, $05, $c1, $f8, $33, $7e, $b7
    db $20, $2d, $fa, $fe, $db, $b7, $28, $27
    db $21, $03, $00, $e5, $af, $f5, $33, $cd
    db $d8, $23, $e8, $03, $af, $0f, $f5, $af
    db $f5, $33, $11, $8f, $5f, $d5, $af, $0f
    db $f5, $af, $0f, $f5, $af, $0f, $f5, $cd
    db $00, $75, $e8, $0b, $c3, $4e, $5f, $cb
    db $41, $c2, $4e, $5f, $21, $00, $00, $39
    db $e5, $af, $0f, $f5, $11, $7a, $5f, $d5
    db $af, $0f, $f5, $af, $0f, $f5, $cd, $00
    db $71, $e8, $0a, $f8, $2c, $36, $00, $3e
    db $8b, $f8, $2c, $86, $2b, $4f, $3e, $5f
    db $ce, $00, $47, $0a, $77, $f8, $33, $7e
    db $f8, $2c, $96, $20, $0e, $21, $03, $00
    db $e5, $af, $f5, $33, $cd, $d8, $23, $e8
    db $03, $18, $0d, $af, $0f, $f5, $af, $3e
    db $03, $f5, $33, $cd, $d8, $23, $e8, $03
    db $f8, $2c, $7e, $b7, $28, $0e, $2b, $5e
    db $16, $00, $21, $00, $00, $39, $19, $4d
    db $44, $0a, $18, $01, $af, $f8, $28, $77
    db $f8, $2c, $7e, $d6, $03, $20, $06, $f8
    db $2a, $36, $01, $18, $16, $f8, $2c, $3a
    db $2b, $3c, $32, $c6, $8b, $22, $3e, $00
    db $ce, $5f, $32, $2a, $5f, $2a, $57, $1a
    db $96, $2b, $77, $f8, $2a, $3a, $22, $23
    db $3a, $c6, $7a, $22, $3e, $00, $ce, $5f
    db $77, $af, $f5, $33, $f8, $29, $2a, $57
    db $2a, $5f, $d5, $2a, $5f, $56, $d5, $af
    db $0f, $f5, $af, $0f, $f5, $af, $0f, $f5
    db $cd, $00, $75, $e8, $0b, $f8, $2c, $34
    db $7e, $d6, $04, $da, $af, $5e, $af, $67
    db $2e, $03, $e5, $3e, $03, $f5, $33, $cd
    db $d8, $23, $e8, $03, $21, $0c, $01, $e5
    db $21, $0c, $9f, $e5, $af, $f5, $33, $cd
    db $01, $24, $e8, $05, $af, $0f, $f5, $af
    db $3e, $03, $f5, $33, $cd, $d8, $23, $e8
    db $30, $c9, $20, $53, $44, $20, $20, $53
    db $45, $54, $20, $20, $48, $45, $4c, $50
    db $20, $20, $00, $00, $04, $09, $0f, $20
    db $50, $49, $43, $4b, $20, $41, $20, $52
    db $4f, $4d, $20, $00

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Font12::
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $c0, $00, $c0, $00, $c0, $00
    db $c0, $00, $c0, $00, $c0, $00, $00, $00
    db $c0, $00, $c0, $00, $00, $00, $00, $00
    db $00, $00, $cc, $00, $cc, $00, $cc, $00
    db $cc, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $12, $00, $16, $00, $7f, $00
    db $24, $00, $2c, $00, $fe, $00, $68, $00
    db $48, $00, $48, $00, $00, $00, $00, $00
    db $10, $00, $10, $00, $7c, $00, $d4, $00
    db $d0, $00, $7c, $00, $16, $00, $16, $00
    db $d6, $00, $7c, $00, $10, $00, $10, $00
    db $00, $00, $60, $00, $90, $00, $90, $00
    db $63, $00, $1c, $00, $e6, $00, $09, $00
    db $09, $00, $06, $00, $00, $00, $00, $00
    db $00, $00, $38, $00, $60, $00, $60, $00
    db $30, $00, $72, $00, $da, $00, $ce, $00
    db $cc, $00, $7e, $00, $00, $00, $00, $00
    db $00, $00, $c0, $00, $c0, $00, $c0, $00
    db $c0, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $60, $00, $40, $00, $c0, $00, $c0, $00
    db $c0, $00, $c0, $00, $c0, $00, $c0, $00
    db $c0, $00, $40, $00, $60, $00, $00, $00
    db $c0, $00, $40, $00, $60, $00, $60, $00
    db $60, $00, $60, $00, $60, $00, $60, $00
    db $60, $00, $40, $00, $c0, $00, $00, $00
    db $00, $00, $00, $00, $10, $00, $10, $00
    db $d6, $00, $38, $00, $38, $00, $d6, $00
    db $10, $00, $10, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $18, $00, $18, $00
    db $18, $00, $ff, $00, $ff, $00, $18, $00
    db $18, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $60, $00, $60, $00, $40, $00, $80, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $fc, $00, $fc, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $c0, $00, $c0, $00, $00, $00, $00, $00
    db $00, $00, $04, $00, $08, $00, $08, $00
    db $10, $00, $10, $00, $30, $00, $20, $00
    db $20, $00, $40, $00, $40, $00, $80, $00
    db $00, $00, $7c, $00, $c6, $00, $c6, $00
    db $c6, $00, $c6, $00, $c6, $00, $c6, $00
    db $c6, $00, $7c, $00, $00, $00, $00, $00
    db $00, $00, $18, $00, $38, $00, $78, $00
    db $18, $00, $18, $00, $18, $00, $18, $00
    db $18, $00, $7e, $00, $00, $00, $00, $00
    db $00, $00, $7c, $00, $c6, $00, $06, $00
    db $06, $00, $0c, $00, $18, $00, $30, $00
    db $60, $00, $fe, $00, $00, $00, $00, $00
    db $00, $00, $7c, $00, $c6, $00, $06, $00
    db $06, $00, $3c, $00, $06, $00, $06, $00
    db $c6, $00, $7c, $00, $00, $00, $00, $00
    db $00, $00, $0c, $00, $1c, $00, $3c, $00
    db $6c, $00, $cc, $00, $fe, $00, $0c, $00
    db $0c, $00, $0c, $00, $00, $00, $00, $00
    db $00, $00, $fe, $00, $c0, $00, $c0, $00
    db $fc, $00, $06, $00, $06, $00, $06, $00
    db $c6, $00, $7c, $00, $00, $00, $00, $00
    db $00, $00, $3c, $00, $60, $00, $c0, $00
    db $fc, $00, $c6, $00, $c6, $00, $c6, $00
    db $c6, $00, $7c, $00, $00, $00, $00, $00
    db $00, $00, $fe, $00, $06, $00, $06, $00
    db $0c, $00, $0c, $00, $18, $00, $18, $00
    db $30, $00, $30, $00, $00, $00, $00, $00
    db $00, $00, $7c, $00, $c6, $00, $c6, $00
    db $c6, $00, $7c, $00, $c6, $00, $c6, $00
    db $c6, $00, $7c, $00, $00, $00, $00, $00
    db $00, $00, $7c, $00, $c6, $00, $c6, $00
    db $c6, $00, $c6, $00, $7e, $00, $06, $00
    db $0c, $00, $78, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $c0, $00
    db $c0, $00, $00, $00, $00, $00, $00, $00
    db $c0, $00, $c0, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $60, $00
    db $60, $00, $00, $00, $00, $00, $00, $00
    db $60, $00, $60, $00, $40, $00, $80, $00
    db $00, $00, $00, $00, $00, $00, $02, $00
    db $1e, $00, $78, $00, $c0, $00, $78, $00
    db $1e, $00, $02, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $fe, $00, $fe, $00, $00, $00, $fe, $00
    db $fe, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $80, $00
    db $f0, $00, $3c, $00, $06, $00, $3c, $00
    db $f0, $00, $80, $00, $00, $00, $00, $00
    db $00, $00, $70, $00, $98, $00, $18, $00
    db $30, $00, $60, $00, $60, $00, $00, $00
    db $60, $00, $60, $00, $00, $00, $00, $00
    db $00, $00, $3c, $00, $62, $00, $5e, $00
    db $b6, $00, $a2, $00, $a2, $00, $a2, $00
    db $b6, $00, $5e, $00, $62, $00, $3e, $00
    db $00, $00, $38, $00, $38, $00, $28, $00
    db $6c, $00, $6c, $00, $7c, $00, $6c, $00
    db $c6, $00, $c6, $00, $00, $00, $00, $00
    db $00, $00, $fc, $00, $c6, $00, $c6, $00
    db $c6, $00, $f8, $00, $c6, $00, $c6, $00
    db $c6, $00, $fc, $00, $00, $00, $00, $00
    db $00, $00, $3c, $00, $62, $00, $c0, $00
    db $c0, $00, $c0, $00, $c0, $00, $c0, $00
    db $62, $00, $3c, $00, $00, $00, $00, $00
    db $00, $00, $f8, $00, $cc, $00, $c6, $00
    db $c6, $00, $c6, $00, $c6, $00, $c6, $00
    db $cc, $00, $f8, $00, $00, $00, $00, $00
    db $00, $00, $fe, $00, $c0, $00, $c0, $00
    db $c0, $00, $fc, $00, $c0, $00, $c0, $00
    db $c0, $00, $fe, $00, $00, $00, $00, $00
    db $00, $00, $fe, $00, $c0, $00, $c0, $00
    db $c0, $00, $fc, $00, $c0, $00, $c0, $00
    db $c0, $00, $c0, $00, $00, $00, $00, $00
    db $00, $00, $3c, $00, $62, $00, $c0, $00
    db $c0, $00, $ce, $00, $c6, $00, $c6, $00
    db $66, $00, $3e, $00, $00, $00, $00, $00
    db $00, $00, $c6, $00, $c6, $00, $c6, $00
    db $c6, $00, $fe, $00, $c6, $00, $c6, $00
    db $c6, $00, $c6, $00, $00, $00, $00, $00
    db $00, $00, $fc, $00, $30, $00, $30, $00
    db $30, $00, $30, $00, $30, $00, $30, $00
    db $30, $00, $fc, $00, $00, $00, $00, $00
    db $00, $00, $1e, $00, $06, $00, $06, $00
    db $06, $00, $06, $00, $06, $00, $06, $00
    db $86, $00, $7c, $00, $00, $00, $00, $00
    db $00, $00, $c6, $00, $cc, $00, $d8, $00
    db $f0, $00, $f8, $00, $d8, $00, $cc, $00
    db $cc, $00, $c6, $00, $00, $00, $00, $00
    db $00, $00, $c0, $00, $c0, $00, $c0, $00
    db $c0, $00, $c0, $00, $c0, $00, $c0, $00
    db $c0, $00, $fe, $00, $00, $00, $00, $00
    db $00, $00, $ee, $00, $ee, $00, $ee, $00
    db $ee, $00, $fe, $00, $d6, $00, $c6, $00
    db $c6, $00, $c6, $00, $00, $00, $00, $00
    db $00, $00, $e6, $00, $e6, $00, $e6, $00
    db $f6, $00, $d6, $00, $de, $00, $ce, $00
    db $ce, $00, $ce, $00, $00, $00, $00, $00
    db $00, $00, $38, $00, $6c, $00, $c6, $00
    db $c6, $00, $c6, $00, $c6, $00, $c6, $00
    db $6c, $00, $38, $00, $00, $00, $00, $00
    db $00, $00, $fc, $00, $c6, $00, $c6, $00
    db $c6, $00, $c6, $00, $fc, $00, $c0, $00
    db $c0, $00, $c0, $00, $00, $00, $00, $00
    db $00, $00, $38, $00, $6c, $00, $c6, $00
    db $c6, $00, $c6, $00, $c6, $00, $c6, $00
    db $6c, $00, $3c, $00, $0c, $00, $04, $00
    db $00, $00, $fc, $00, $c6, $00, $c6, $00
    db $c6, $00, $c6, $00, $f8, $00, $cc, $00
    db $c6, $00, $c3, $00, $00, $00, $00, $00
    db $00, $00, $7c, $00, $c2, $00, $c0, $00
    db $e0, $00, $7c, $00, $0e, $00, $06, $00
    db $86, $00, $7c, $00, $00, $00, $00, $00
    db $00, $00, $fc, $00, $30, $00, $30, $00
    db $30, $00, $30, $00, $30, $00, $30, $00
    db $30, $00, $30, $00, $00, $00, $00, $00
    db $00, $00, $c6, $00, $c6, $00, $c6, $00
    db $c6, $00, $c6, $00, $c6, $00, $c6, $00
    db $c6, $00, $7c, $00, $00, $00, $00, $00
    db $00, $00, $c6, $00, $c6, $00, $44, $00
    db $6c, $00, $6c, $00, $6c, $00, $28, $00
    db $38, $00, $38, $00, $00, $00, $00, $00
    db $00, $00, $c3, $00, $c3, $00, $db, $00
    db $db, $00, $5a, $00, $5e, $00, $66, $00
    db $66, $00, $66, $00, $00, $00, $00, $00
    db $00, $00, $c6, $00, $6c, $00, $6c, $00
    db $38, $00, $10, $00, $38, $00, $6c, $00
    db $6c, $00, $c6, $00, $00, $00, $00, $00
    db $00, $00, $c3, $00, $66, $00, $66, $00
    db $3c, $00, $3c, $00, $18, $00, $18, $00
    db $18, $00, $18, $00, $00, $00, $00, $00
    db $00, $00, $fe, $00, $06, $00, $0c, $00
    db $18, $00, $38, $00, $30, $00, $60, $00
    db $c0, $00, $fe, $00, $00, $00, $00, $00
    db $f0, $00, $c0, $00, $c0, $00, $c0, $00
    db $c0, $00, $c0, $00, $c0, $00, $c0, $00
    db $c0, $00, $c0, $00, $f0, $00, $00, $00
    db $00, $00, $c0, $00, $40, $00, $40, $00
    db $60, $00, $20, $00, $30, $00, $10, $00
    db $18, $00, $08, $00, $08, $00, $0c, $00
    db $f0, $00, $30, $00, $30, $00, $30, $00
    db $30, $00, $30, $00, $30, $00, $30, $00
    db $30, $00, $30, $00, $f0, $00, $00, $00
    db $00, $00, $38, $00, $38, $00, $6c, $00
    db $c6, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $ff, $00
    db $c0, $00, $60, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $38, $00
    db $4c, $00, $0c, $00, $7c, $00, $cc, $00
    db $cc, $00, $7c, $00, $00, $00, $00, $00
    db $c0, $00, $c0, $00, $c0, $00, $f8, $00
    db $cc, $00, $cc, $00, $cc, $00, $cc, $00
    db $cc, $00, $f8, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $38, $00
    db $64, $00, $c0, $00, $c0, $00, $c0, $00
    db $64, $00, $38, $00, $00, $00, $00, $00
    db $0c, $00, $0c, $00, $0c, $00, $7c, $00
    db $cc, $00, $cc, $00, $cc, $00, $cc, $00
    db $cc, $00, $7c, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $78, $00
    db $cc, $00, $cc, $00, $fc, $00, $c0, $00
    db $c4, $00, $78, $00, $00, $00, $00, $00
    db $1c, $00, $30, $00, $30, $00, $fc, $00
    db $30, $00, $30, $00, $30, $00, $30, $00
    db $30, $00, $30, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $7c, $00
    db $cc, $00, $cc, $00, $cc, $00, $cc, $00
    db $cc, $00, $7c, $00, $0c, $00, $7c, $00
    db $c0, $00, $c0, $00, $c0, $00, $f8, $00
    db $cc, $00, $cc, $00, $cc, $00, $cc, $00
    db $cc, $00, $cc, $00, $00, $00, $00, $00
    db $30, $00, $00, $00, $00, $00, $f0, $00
    db $30, $00, $30, $00, $30, $00, $30, $00
    db $30, $00, $fc, $00, $00, $00, $00, $00
    db $18, $00, $00, $00, $00, $00, $78, $00
    db $18, $00, $18, $00, $18, $00, $18, $00
    db $18, $00, $18, $00, $18, $00, $f0, $00
    db $c0, $00, $c0, $00, $c0, $00, $c8, $00
    db $d8, $00, $f0, $00, $f0, $00, $d8, $00
    db $d8, $00, $cc, $00, $00, $00, $00, $00
    db $c0, $00, $c0, $00, $c0, $00, $c0, $00
    db $c0, $00, $c0, $00, $c0, $00, $c0, $00
    db $c0, $00, $78, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $ff, $00
    db $db, $00, $db, $00, $db, $00, $db, $00
    db $db, $00, $db, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $f8, $00
    db $cc, $00, $cc, $00, $cc, $00, $cc, $00
    db $cc, $00, $cc, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $78, $00
    db $cc, $00, $cc, $00, $cc, $00, $cc, $00
    db $cc, $00, $78, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $f8, $00
    db $cc, $00, $cc, $00, $cc, $00, $cc, $00
    db $cc, $00, $f8, $00, $c0, $00, $c0, $00
    db $00, $00, $00, $00, $00, $00, $7c, $00
    db $cc, $00, $cc, $00, $cc, $00, $cc, $00
    db $cc, $00, $7c, $00, $0c, $00, $0c, $00
    db $00, $00, $00, $00, $00, $00, $f8, $00
    db $c0, $00, $c0, $00, $c0, $00, $c0, $00
    db $c0, $00, $c0, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $78, $00
    db $c4, $00, $e0, $00, $78, $00, $0c, $00
    db $8c, $00, $78, $00, $00, $00, $00, $00
    db $00, $00, $30, $00, $30, $00, $fc, $00
    db $30, $00, $30, $00, $30, $00, $30, $00
    db $30, $00, $1c, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $cc, $00
    db $cc, $00, $cc, $00, $cc, $00, $cc, $00
    db $cc, $00, $7c, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $cc, $00
    db $cc, $00, $cc, $00, $48, $00, $78, $00
    db $78, $00, $30, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $c3, $00
    db $c3, $00, $db, $00, $5a, $00, $5a, $00
    db $66, $00, $66, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $cc, $00
    db $78, $00, $30, $00, $30, $00, $78, $00
    db $78, $00, $cc, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $cc, $00
    db $cc, $00, $58, $00, $78, $00, $78, $00
    db $30, $00, $30, $00, $30, $00, $60, $00
    db $00, $00, $00, $00, $00, $00, $fc, $00
    db $0c, $00, $18, $00, $30, $00, $60, $00
    db $c0, $00, $fc, $00, $00, $00, $00, $00
    db $3c, $00, $30, $00, $30, $00, $30, $00
    db $30, $00, $c0, $00, $30, $00, $30, $00
    db $30, $00, $30, $00, $3c, $00, $00, $00
    db $80, $00, $80, $00, $80, $00, $80, $00
    db $80, $00, $80, $00, $80, $00, $80, $00
    db $80, $00, $80, $00, $80, $00, $80, $00
    db $f0, $00, $30, $00, $30, $00, $30, $00
    db $30, $00, $0c, $00, $30, $00, $30, $00
    db $30, $00, $30, $00, $f0, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $60, $00
    db $d0, $00, $9a, $00, $0e, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $fe, $00, $82, $00, $82, $00
    db $82, $00, $82, $00, $82, $00, $82, $00
    db $82, $00, $82, $00, $82, $00, $fe, $00
    db $00, $00, $7c, $00, $82, $00, $ff, $c0
    db $80, $40, $80, $40, $80, $40, $80, $40
    db $80, $40, $80, $40, $ff, $c0, $00, $00
    db $ff, $c0, $80, $40, $bf, $40, $bf, $40
    db $bf, $40, $bf, $40, $80, $40, $80, $40
    db $80, $40, $80, $40, $ff, $80, $00, $00
    db $7f, $80, $80, $40, $bf, $40, $b9, $40
    db $bd, $40, $bf, $40, $80, $40, $80, $40
    db $80, $40, $61, $80, $1e, $00, $00, $00
    db $ff, $c0, $80, $40, $9e, $40, $b3, $40
    db $83, $40, $86, $40, $8c, $40, $8c, $40
    db $80, $40, $8c, $40, $ff, $c0, $00, $00
    db $fe, $00, $83, $00, $82, $80, $83, $c0
    db $80, $40, $80, $40, $80, $40, $80, $40
    db $80, $40, $80, $40, $ff, $c0, $00, $00

Font12Metrics::
    db $05, $04, $08, $0a, $09, $0a, $09, $04
    db $05, $05, $09, $0a, $05, $08, $04, $08
    db $09, $09, $09, $09, $09, $09, $09, $09
    db $09, $09, $04, $05, $09, $09, $09, $07
    db $09, $09, $09, $09, $09, $09, $09, $09
    db $09, $08, $09, $09, $09, $09, $09, $09
    db $09, $09, $0a, $09, $08, $09, $09, $0a
    db $09, $0a, $09, $06, $08, $06, $09, $0a
    db $05, $08, $08, $08, $08, $08, $08, $08
    db $08, $08, $07, $08, $07, $0a, $08, $08
    db $08, $08, $07, $08, $08, $08, $08, $0a
    db $08, $08, $08, $08, $03, $08, $09, $09
    db $0c, $0c, $0c, $0c, $0c, $00, $02, $06
    db $08, $07, $08, $07, $02, $03, $03, $07
    db $08, $03, $06, $02, $06, $07, $07, $07
    db $07, $07, $07, $07, $07, $07, $07, $02
    db $03, $07, $07, $07, $05, $07, $07, $07
    db $07, $07, $07, $07, $07, $07, $06, $07
    db $07, $07, $07, $07, $07, $07, $07, $08
    db $07, $06, $07, $07, $08, $07, $08, $07
    db $04, $06, $04, $07, $08, $03, $06, $06
    db $06, $06, $06, $06, $06, $06, $06, $05
    db $06, $05, $08, $06, $06, $06, $06, $05
    db $06, $06, $06, $06, $08, $06, $06, $06
    db $06, $01, $06, $07, $07, $0a, $0a, $0a
    db $0a, $0a, $00, $01, $02, $03, $04, $05
    db $06, $02, $07, $08, $09, $0a, $0b, $0a
    db $0c, $0d, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $0e, $0f, $10, $11
    db $0e, $12, $13, $14, $01, $15, $01, $01
    db $01, $15, $01, $16, $17, $01, $01, $01
    db $01, $15, $01, $15, $01, $18, $19, $1a
    db $1b, $1c, $1d, $1e, $1f, $20, $21, $22
    db $23, $24, $25, $26, $20, $27, $28, $28
    db $29, $2a, $20, $2b, $2c, $20, $2d, $2e
    db $2e, $28, $2f, $28, $2e, $30, $29, $31
    db $32, $33, $34, $35, $36, $37, $00, $22
    db $38, $00, $00, $00, $00, $00, $00, $f9
    db $01, $08, $02, $17, $02, $26, $02, $35
    db $02, $44, $02, $53, $02, $17, $02, $62
    db $02, $71, $02, $80, $02, $8f, $02, $9e
    db $02, $8f, $02, $ad, $02, $bc, $02, $f9
    db $01, $f9, $01, $f9, $01, $f9, $01, $f9
    db $01, $f9, $01, $f9, $01, $f9, $01, $f9
    db $01, $f9, $01, $cb, $02, $da, $02, $cb
    db $02, $e9, $02, $f8, $02, $07, $03, $16
    db $03, $25, $03, $34, $03, $43, $03, $52
    db $03, $61, $03, $70, $03, $7f, $03, $08
    db $02, $8e, $03, $9d, $03, $ac, $03, $bb
    db $03, $08, $02, $08, $02, $52, $03, $ca
    db $03, $d9, $03, $e8, $03, $f7, $03, $06
    db $04, $9d, $03, $15, $04, $24, $04, $33
    db $04, $bc, $02, $42, $04, $51, $04, $60
    db $04, $6f, $04, $7e, $04, $8d, $04, $9c
    db $04, $ab, $04, $ba, $04, $c9, $04, $6f
    db $04, $ba, $04, $d8, $04, $e7, $04, $ab
    db $04, $bb, $03, $f6, $04, $05, $05, $bb
    db $03, $14, $05, $ab, $04, $ba, $04, $ba
    db $04, $e7, $04, $23, $05, $32, $05, $41
    db $05, $14, $05, $50, $05, $5f, $05, $6e
    db $05, $7d, $05, $8c, $05, $51, $04, $f9
    db $01, $9b, $05, $8f, $02, $aa, $05, $f9
    db $01, $f9, $01, $f9, $01, $f9, $01, $f9
    db $01, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $41, $44, $00, $00, $00, $00
    db $20, $06, $00, $01, $00, $00, $00, $40
    db $10, $a1, $4a, $02, $81, $00, $00, $20
    db $56, $00, $01, $00, $80, $00, $40, $10
    db $99, $4a, $59, $92, $44, $54, $64, $6a
    db $11, $01, $01, $80, $01, $10, $00, $41
    db $48, $10, $10, $48, $25, $a8, $0a, $44
    db $02, $50, $45, $01, $40, $04, $51, $48
    db $11, $10, $48, $24, $24, $0a, $48, $02
    db $00, $81, $00, $20, $01, $41, $44, $10
    db $40, $49, $21, $a8, $0a, $08, $02, $00
    db $04, $00, $54, $55, $54, $55, $55, $55
    db $55, $55, $44, $52, $55, $12, $55, $55
    db $01, $00, $00, $41, $48, $00, $10, $04
    db $14, $14, $06, $00, $01, $00, $00, $00
    db $40, $04, $a1, $4a, $21, $a1, $48, $64
    db $24, $0a, $88, $02, $00, $91, $00, $20
    db $01, $89, $aa, $10, $a1, $49, $a9, $a8
    db $1a, $88, $02, $00, $26, $00, $60, $08
    db $69, $44, $12, $04, $88, $21, $98, $4a
    db $08, $02, $50, $88, $02, $60, $08, $69
    db $44, $12, $04, $88, $21, $a8, $4a, $08
    db $02, $50, $88, $02, $80, $65, $a9, $9a
    db $9a, $86, $01, $00, $a0, $a6, $66, $52
    db $56, $95, $02, $40, $00, $61, $44, $12
    db $00, $48, $10, $24, $4a, $00, $01, $00
    db $80, $00, $40, $00, $61, $44, $12, $00
    db $48, $10, $14, $4a, $00, $01, $00, $80
    db $00, $40, $04, $41, $48, $11, $20, $48
    db $24, $24, $0a, $88, $02, $00, $01, $00
    db $20, $02, $85, $aa, $14, $a1, $4a, $a9
    db $a8, $1a, $88, $02, $51, $66, $01, $40
    db $10, $a5, $4a, $46, $92, $04, $54, $64
    db $aa, $11, $01, $01, $80, $01, $00, $00
    db $00, $00, $00, $00, $04, $10, $04, $08
    db $00, $00, $00, $00, $00, $50, $04, $55
    db $44, $11, $04, $88, $21, $68, $4a, $08
    db $02, $50, $44, $01, $00, $00, $41, $48
    db $00, $10, $04, $14, $24, $0a, $00, $01
    db $00, $80, $00, $40, $00, $69, $48, $02
    db $14, $04, $14, $a4, $4a, $48, $02, $50
    db $89, $02, $00, $00, $81, $49, $10, $61
    db $48, $54, $24, $0a, $00, $01, $00, $00
    db $00, $40, $55, $59, $44, $56, $44, $01
    db $00, $a0, $56, $19, $02, $55, $48, $01
    db $80, $66, $99, $aa, $56, $86, $01, $00
    db $a0, $66, $99, $52, $55, $6a, $01, $00
    db $00, $41, $44, $00, $00, $04, $10, $a4
    db $0a, $08, $02, $00, $04, $00, $40, $55
    db $69, $44, $5a, $48, $01, $00, $a0, $96
    db $19, $02, $65, $88, $02, $00, $00, $41
    db $48, $00, $00, $00, $00, $20, $06, $00
    db $01, $00, $00, $00, $40, $55, $65, $44
    db $56, $44, $01, $00, $a0, $56, $19, $02
    db $65, $88, $02, $60, $59, $69, $44, $5a
    db $48, $99, $21, $a8, $9a, $19, $06, $65
    db $88, $02, $40, $10, $81, $4a, $01, $91
    db $04, $54, $24, $1a, $00, $01, $00, $00
    db $00, $00, $00, $41, $45, $10, $51, $48
    db $54, $14, $09, $00, $01, $00, $00, $00
    db $50, $55, $55, $44, $56, $44, $59, $21
    db $68, $5a, $15, $06, $55, $44, $01, $00
    db $00, $41, $48, $00, $10, $04, $14, $a4
    db $0a, $48, $02, $50, $45, $01, $80, $66
    db $a9, $aa, $9a, $8a, $01, $00, $a0, $a6
    db $aa, $a2, $aa, $aa, $02, $40, $11, $95
    db $9a, $45, $86, $00, $00, $60, $66, $55
    db $52, $55, $55, $01, $40, $10, $91, $49
    db $01, $41, $00, $00, $20, $56, $00, $01
    db $00, $40, $00, $40, $55, $65, $44, $56
    db $44, $01, $00, $a0, $56, $15, $02, $55
    db $84, $02, $40, $11, $69, $44, $4a, $44
    db $00, $00, $a0, $96, $15, $02, $55, $84
    db $02, $a8, $6a, $68, $66, $6a, $aa, $aa
    db $aa, $88, $a2, $aa, $22, $aa, $aa, $02
    db $a4, $59, $29, $11, $66, $59, $99, $66
    db $99, $98, $59, $14, $a5, $95, $02, $00
    db $00, $40, $44, $00, $00, $00, $00, $00
    db $02, $00, $01, $00, $00, $00, $80, $24
    db $a1, $4a, $22, $a1, $48, $a8, $24, $5a
    db $44, $02, $00, $91, $00, $a8, $aa, $2a
    db $22, $aa, $aa, $aa, $aa, $aa, $a8, $9a
    db $28, $aa, $a6, $02, $80, $66, $a9, $aa
    db $9a, $8a, $01, $00, $90, $a6, $aa, $a2
    db $aa, $aa, $02, $00, $00, $41, $44, $10
    db $00, $48, $20, $24, $0a, $04, $02, $00
    db $00, $00, $00, $00, $41, $48, $10, $10
    db $48, $24, $24, $0a, $44, $02, $00, $01
    db $00, $40, $04, $61, $48, $12, $10, $48
    db $24, $24, $4a, $44, $02, $00, $81, $00
    db $40, $10, $a8, $4a, $6a, $a2, $48, $94
    db $44, $a2, $11, $01, $01, $80, $01, $00
    db $00, $00, $00, $10, $00, $48, $10, $04
    db $08, $00, $00, $00, $00, $00, $00, $00
    db $40, $44, $10, $00, $48, $10, $04, $01
    db $00, $01, $00, $00, $00, $50, $55, $65
    db $44, $56, $44, $99, $21, $68, $5a, $15
    db $06, $55, $84, $01, $00, $00, $41, $44
    db $10, $00, $48, $10, $24, $0a, $00, $01
    db $00, $00, $00, $40, $10, $a9, $4a, $6a
    db $a2, $48, $94, $64, $aa, $11, $01, $01
    db $80, $01, $40, $04, $51, $48, $11, $10
    db $48, $24, $24, $0a, $44, $02, $00, $81
    db $00, $40, $10, $69, $44, $5a, $40, $48
    db $10, $64, $9a, $11, $01, $01, $80, $01
    db $40, $10, $81, $49, $11, $61, $48, $54
    db $24, $1a, $00, $01, $00, $00, $00, $40
    db $10, $81, $49, $11, $51, $48, $54, $24
    db $1a, $00, $01, $00, $00, $00, $40, $10
    db $65, $44, $56, $40, $48, $10, $64, $5a
    db $11, $01, $01, $80, $01, $40, $10, $91
    db $4a, $21, $a1, $48, $94, $24, $5a, $00
    db $01, $00, $40, $00, $40, $10, $51, $44
    db $12, $40, $48, $10, $24, $5a, $00, $01
    db $00, $40, $00, $a0, $19, $89, $aa, $11
    db $a1, $49, $a9, $a8, $2a, $88, $02, $00
    db $26, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $04, $00, $00, $00, $00
    db $00

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Fit12::
    db $e8, $f8, $f8, $11, $7e, $d6, $02, $38
    db $03, $7e, $18, $0c, $f8, $11, $7e, $b7
    db $28, $05, $fa, $d8, $69, $18, $01, $af
    db $f8, $06, $77, $fa, $f9, $ff, $f8, $02
    db $77, $7e, $b7, $28, $05, $3e, $a0, $96
    db $30, $04, $f8, $02, $36, $a0, $f8, $10
    db $7e, $b7, $28, $05, $3e, $28, $96, $30
    db $04, $f8, $10, $36, $28, $f8, $05, $3e
    db $ff, $22, $23, $36, $00, $f8, $07, $7e
    db $f8, $10, $96, $d2, $e5, $71, $2b, $2b
    db $7e, $f8, $07, $86, $4f, $f5, $f8, $11
    db $f1, $7e, $ce, $00, $47, $0a, $47, $b7
    db $ca, $e5, $71, $c5, $33, $cd, $2c, $72
    db $33, $f8, $03, $7b, $22, $23, $7e, $3c
    db $28, $12, $f8, $03, $2a, $23, $f5, $33
    db $7e, $f5, $33, $cd, $eb, $71, $e1, $f8
    db $06, $7e, $93, $77, $f8, $06, $7e, $f8
    db $02, $96, $30, $59, $23, $7e, $f8, $00
    db $22, $af, $32, $7e, $c6, $65, $4f, $3e
    db $00, $ce, $00, $47, $21, $78, $69, $09
    db $7e, $f8, $06, $86, $4f, $f8, $02, $7e
    db $91, $38, $3a, $f8, $12, $7e, $f8, $07
    db $86, $2b, $2b, $2b, $77, $f5, $f8, $15
    db $f1, $7e, $ce, $00, $f8, $05, $32, $2a
    db $5f, $2a, $57, $7e, $12, $f8, $00, $2a
    db $23, $23, $23, $c6, $78, $22, $3e, $00
    db $ce, $69, $32, $2a, $5f, $56, $1a, $77
    db $2a, $86, $77, $f8, $03, $2a, $23, $22
    db $23, $34, $c3, $45, $71, $f8, $07, $5e
    db $e8, $08, $c9, $f8, $03, $4e, $06, $00
    db $21, $ca, $00, $09, $11, $78, $69, $19
    db $4e, $79, $b7, $20, $02, $5f, $c9, $f8
    db $02, $7e, $87, $6f, $26, $00, $11, $a7
    db $6a, $19, $2a, $66, $59, $cb, $3b, $cb
    db $3b, $16, $00, $6f, $19, $11, $78, $69
    db $19, $5e, $79, $e6, $03, $87, $47, $7b
    db $04, $18, $02, $cb, $3f, $05, $20, $fb
    db $e6, $03, $5f, $c9, $f8, $02, $7e, $4f
    db $d6, $20, $38, $0a, $7e, $d6, $80, $30
    db $05, $79, $c6, $e0, $5f, $c9, $f8, $02
    db $7e, $d6, $c0, $38, $0a, $3e, $c4, $96
    db $38, $05, $79, $c6, $a0, $5f, $c9, $1e
    db $1f, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

LastRomName::
    db $f8, $09, $3a, $b6, $28, $5f, $0e, $00
    db $79, $d6, $fe, $30, $10, $f8, $08, $2a
    db $81, $5f, $7e, $ce, $00, $57, $1a, $b7
    db $28, $03, $0c, $18, $eb, $41, $11, $3c
    db $db, $f8, $08, $2a, $12, $13, $7e, $12
    db $21, $38, $db, $36, $00, $2e, $39, $36
    db $00, $f0, $fa, $2e, $3b, $77, $fa, $fb
    db $ff, $b7, $28, $15, $c5, $f8, $0a, $2a
    db $5f, $56, $d5, $cd, $17, $73, $e1, $c1
    db $7b, $91, $3e, $00, $17, $ee, $01, $18
    db $08, $3e, $12, $91, $3e, $00, $17, $ee
    db $01, $b7, $28, $02, $06, $00, $21, $3e
    db $db, $70, $c3, $4d, $73, $21, $3e, $db
    db $4e, $79, $b7, $c8, $f0, $fa, $47, $21
    db $3b, $db, $96, $21, $3b, $db, $70, $fe
    db $65, $38, $02, $3e, $64, $21, $39, $db
    db $86, $21, $39, $db, $77, $46, $fa, $38
    db $db, $b7, $1e, $3c, $28, $02, $1e, $14
    db $78, $93, $d8, $21, $39, $db, $36, $00
    db $2e, $38, $46, $04, $21, $38, $db, $70
    db $26, $00, $69, $23, $23, $23, $0e, $00
    db $78, $95, $79, $9c, $da, $4d, $73, $21
    db $38, $db, $36, $00, $c3, $4d, $73, $e8
    db $d8, $21, $00, $00, $39, $e5, $af, $3c
    db $f5, $f8, $2e, $2a, $5f, $56, $d5, $af
    db $0f, $f5, $af, $0f, $f5, $cd, $00, $71
    db $e8, $0a, $3e, $01, $93, $30, $13, $4b
    db $0d, $79, $07, $9f, $47, $21, $00, $00
    db $39, $09, $7e, $fe, $95, $38, $03, $1d
    db $18, $e8, $e8, $28, $c9, $e8, $d1, $11
    db $3c, $db, $1a, $f8, $28, $22, $13, $1a
    db $77, $21, $3e, $db, $4e, $79, $b7, $20
    db $34, $f8, $2e, $36, $00, $f8, $2e, $5e
    db $16, $00, $21, $00, $00, $39, $19, $4d
    db $44, $f8, $2e, $7e, $d6, $27, $30, $19
    db $f8, $28, $7e, $f8, $2e, $86, $5f, $f5
    db $f8, $2b, $f1, $7e, $ce, $00, $57, $1a
    db $b7, $28, $06, $02, $f8, $2e, $34, $18
    db $d4, $af, $02, $18, $62, $21, $38, $db
    db $46, $f8, $2e, $36, $00, $f8, $2e, $5e
    db $16, $00, $21, $00, $00, $39, $19, $e5
    db $7d, $f8, $2e, $77, $e1, $7c, $f8, $2d
    db $77, $78, $91, $30, $0c, $f8, $28, $2a
    db $80, $5f, $7e, $ce, $00, $57, $1a, $18
    db $02, $3e, $20, $f8, $2c, $5e, $23, $66
    db $6b, $77, $04, $59, $16, $00, $13, $13
    db $13, $f8, $2a, $7b, $22, $7a, $22, $78
    db $22, $36, $00, $f8, $2c, $5d, $54, $f8
    db $2a, $1a, $13, $96, $23, $1a, $9e, $38
    db $02, $06, $00, $f8, $2e, $34, $7e, $d6
    db $27, $38, $aa, $f8, $27, $36, $00, $21
    db $03, $00, $e5, $af, $f5, $33, $cd, $d8
    db $23, $e8, $03, $fa, $fb, $ff, $b7, $20
    db $29, $fa, $3f, $db, $b7, $28, $04, $06
    db $07, $18, $02, $06, $0e, $f8, $00, $c5
    db $33, $11, $12, $01, $d5, $e5, $cd, $b7
    db $08, $e8, $05, $af, $0f, $f5, $af, $3e
    db $03, $f5, $33, $cd, $d8, $23, $e8, $03
    db $18, $44, $f8, $00, $4d, $44, $c5, $c5
    db $cd, $17, $73, $e1, $c1, $7b, $1c, $1d
    db $20, $02, $3e, $01, $21, $3f, $db, $6e
    db $2c, $2d, $28, $04, $16, $38, $18, $02
    db $16, $70, $d5, $33, $26, $01, $e5, $33
    db $f5, $33, $c5, $af, $0f, $f5, $af, $0f
    db $f5, $af, $0f, $f5, $cd, $00, $75, $e8
    db $0b, $af, $0f, $f5, $af, $3e, $03, $f5
    db $33, $cd, $d8, $23, $e8, $03, $e8, $2f
    db $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

DrawString12::
    db $21, $c8, $fe, $39, $f9, $21, $44, $01
    db $39, $4e, $7e, $d6, $12, $38, $0a, $79
    db $e6, $fc, $21, $37, $01, $39, $77, $18
    db $1e, $21, $44, $01, $39, $7e, $d6, $02
    db $38, $0c, $7e, $c6, $fe, $4f, $87, $81
    db $87, $87, $c6, $14, $18, $04, $79, $87
    db $87, $87, $21, $37, $01, $39, $77, $21
    db $37, $01, $39, $7e, $d6, $90, $d2, $cc
    db $79, $21, $36, $01, $39, $3e, $0c, $22
    db $3e, $90, $96, $fe, $0c, $30, $02, $2b
    db $77, $21, $43, $01, $39, $7e, $d6, $02
    db $38, $03, $7e, $18, $0e, $21, $43, $01
    db $39, $7e, $b7, $28, $05, $fa, $d8, $69
    db $18, $01, $af, $21, $34, $01, $39, $77
    db $7e, $cb, $37, $07, $e6, $1f, $21, $24
    db $01, $39, $77, $fa, $f9, $ff, $21, $33
    db $01, $39, $77, $7e, $b7, $28, $05, $3e
    db $a0, $96, $30, $06, $21, $33, $01, $39
    db $36, $a0, $21, $34, $01, $39, $3a, $96
    db $d2, $cc, $79, $21, $33, $01, $39, $2a
    db $23, $77, $7e, $c6, $07, $77, $7e, $cb
    db $37, $07, $e6, $1f, $77, $7e, $21, $24
    db $01, $39, $96, $23, $77, $21, $33, $01
    db $39, $7e, $e6, $07, $28, $1b, $21, $33
    db $01, $39, $7e, $e6, $07, $01, $ff, $00
    db $3c, $18, $04, $cb, $28, $cb, $19, $3d
    db $20, $f9, $21, $35, $01, $39, $71, $18
    db $06, $21, $35, $01, $39, $36, $00, $21
    db $35, $01, $39, $7e, $21, $26, $01, $39
    db $77, $21, $34, $01, $39, $7e, $e6, $07
    db $28, $14, $21, $34, $01, $39, $7e, $e6
    db $07, $4f, $3e, $08, $91, $47, $3e, $ff
    db $87, $05, $20, $fc, $18, $01, $af, $21
    db $27, $01, $39, $77, $01, $02, $2c, $21
    db $37, $01, $39, $5e, $16, $00, $6b, $62
    db $29, $09, $2a, $4f, $46, $21, $24, $01
    db $39, $2a, $23, $23, $23, $5f, $16, $00
    db $7b, $87, $cb, $12, $87, $cb, $12, $87
    db $cb, $12, $87, $cb, $12, $81, $22, $7a
    db $88, $77, $fa, $0d, $d7, $21, $2a, $01
    db $39, $77, $fa, $0e, $d7, $21, $2b, $01
    db $39, $77, $7e, $b7, $3e, $ff, $20, $01
    db $af, $21, $2c, $01, $39, $77, $fa, $a9
    db $d6, $b7, $20, $0f, $21, $2a, $01, $39
    db $2a, $b6, $fe, $03, $20, $05, $2b, $2a
    db $a6, $28, $03, $af, $18, $02, $3e, $01
    db $21, $2d, $01, $39, $77, $21, $25, $01
    db $39, $7e, $21, $2e, $01, $39, $77, $7e
    db $3c, $21, $37, $01, $39, $77, $7e, $4f
    db $87, $81, $47, $c5, $33, $21, $01, $00
    db $39, $e5, $cd, $46, $7b, $e8, $03, $21
    db $2d, $01, $39, $7e, $b7, $28, $3c, $21
    db $36, $01, $39, $7e, $e6, $fc, $77, $7e
    db $b7, $ca, $cc, $79, $21, $27, $01, $39
    db $7e, $b7, $28, $27, $21, $2c, $01, $39
    db $7e, $f5, $33, $21, $28, $01, $39, $7e
    db $f5, $33, $21, $38, $01, $39, $7e, $f5
    db $33, $21, $2b, $01, $39, $2a, $5f, $56
    db $d5, $21, $05, $00, $39, $e5, $cd, $d2
    db $79, $e8, $07, $21, $fc, $00, $39, $e5
    db $21, $45, $01, $39, $3a, $57, $3a, $2b
    db $5f, $d5, $2a, $5f, $56, $d5, $af, $0f
    db $f5, $af, $0f, $f5, $cd, $00, $71, $e8
    db $0a, $21, $2f, $01, $39, $73, $21, $37
    db $01, $39, $36, $00, $21, $37, $01, $39
    db $7e, $21, $2f, $01, $39, $96, $d2, $75
    db $78, $21, $37, $01, $39, $5e, $16, $00
    db $21, $fc, $00, $39, $19, $e5, $7d, $21
    db $36, $01, $39, $77, $e1, $7c, $21, $35
    db $01, $39, $32, $2a, $5f, $56, $1a, $4f
    db $21, $40, $01, $39, $7e, $21, $37, $01
    db $39, $86, $5f, $f5, $21, $43, $01, $39
    db $f1, $7e, $ce, $00, $57, $1a, $c5, $f5
    db $33, $cd, $20, $7b, $33, $c1, $16, $00
    db $6b, $62, $29, $19, $29, $29, $29, $7d
    db $c6, $00, $47, $7c, $ce, $60, $21, $30
    db $01, $39, $70, $23, $77, $79, $cb, $37
    db $07, $e6, $1f, $21, $24, $01, $39, $96
    db $5f, $87, $83, $87, $87, $5f, $16, $00
    db $21, $00, $00, $39, $19, $45, $7c, $21
    db $32, $01, $39, $70, $23, $22, $79, $e6
    db $07, $22, $af, $32, $3e, $06, $96, $23
    db $3e, $00, $9e, $da, $58, $78, $21, $34
    db $01, $39, $4e, $06, $00, $21, $a7, $77
    db $09, $09, $4e, $23, $66, $69, $e9, $b5
    db $77, $cd, $77, $e5, $77, $fc, $77, $13
    db $78, $2a, $78, $41, $78, $21, $32, $01
    db $39, $2a, $5f, $56, $d5, $21, $32, $01
    db $39, $2a, $5f, $56, $d5, $cd, $57, $7b
    db $e8, $04, $c3, $6d, $78, $21, $32, $01
    db $39, $2a, $5f, $56, $d5, $21, $32, $01
    db $39, $2a, $5f, $56, $d5, $cd, $86, $7b
    db $e8, $04, $c3, $6d, $78, $21, $32, $01
    db $39, $2a, $5f, $56, $d5, $21, $32, $01
    db $39, $2a, $5f, $56, $d5, $cd, $b9, $7b
    db $e8, $04, $18, $71, $21, $32, $01, $39
    db $2a, $5f, $56, $d5, $21, $32, $01, $39
    db $2a, $5f, $56, $d5, $cd, $f0, $7b, $e8
    db $04, $18, $5a, $21, $32, $01, $39, $2a
    db $5f, $56, $d5, $21, $32, $01, $39, $2a
    db $5f, $56, $d5, $cd, $2b, $7c, $e8, $04
    db $18, $43, $21, $32, $01, $39, $2a, $5f
    db $56, $d5, $21, $32, $01, $39, $2a, $5f
    db $56, $d5, $cd, $6a, $7c, $e8, $04, $18
    db $2c, $21, $32, $01, $39, $2a, $5f, $56
    db $d5, $21, $32, $01, $39, $2a, $5f, $56
    db $d5, $cd, $ad, $7c, $e8, $04, $18, $15
    db $21, $32, $01, $39, $2a, $5f, $56, $d5
    db $21, $32, $01, $39, $2a, $5f, $56, $d5
    db $cd, $f4, $7c, $e8, $04, $21, $37, $01
    db $39, $34, $c3, $04, $77, $21, $2d, $01
    db $39, $7e, $b7, $20, $2f, $2b, $2b, $3a
    db $57, $5e, $d5, $21, $28, $01, $39, $2a
    db $57, $3a, $2b, $5f, $d5, $7e, $f5, $33
    db $21, $3b, $01, $39, $7e, $f5, $33, $21
    db $2e, $01, $39, $2a, $5f, $56, $d5, $21
    db $08, $00, $39, $e5, $cd, $01, $7a, $e8
    db $0a, $c3, $cc, $79, $21, $00, $00, $39
    db $e5, $7d, $21, $33, $01, $39, $77, $e1
    db $7c, $21, $32, $01, $39, $77, $21, $2e
    db $01, $39, $7e, $3d, $21, $33, $01, $39
    db $77, $21, $37, $01, $39, $36, $00, $21
    db $28, $01, $39, $7e, $21, $34, $01, $39
    db $77, $21, $29, $01, $39, $7e, $21, $35
    db $01, $39, $77, $21, $37, $01, $39, $7e
    db $21, $25, $01, $39, $96, $d2, $cc, $79
    db $21, $31, $01, $39, $3a, $2b, $2b, $2b
    db $c6, $0c, $77, $f5, $21, $34, $01, $39
    db $f1, $7e, $ce, $00, $21, $2e, $01, $39
    db $77, $21, $26, $01, $39, $7e, $b7, $28
    db $76, $21, $33, $01, $39, $7e, $21, $37
    db $01, $39, $96, $20, $6a, $21, $2c, $01
    db $39, $7e, $f5, $33, $21, $27, $01, $39
    db $7e, $f5, $33, $21, $38, $01, $39, $3a
    db $2b, $f5, $33, $2a, $5f, $56, $d5, $21
    db $32, $01, $39, $2a, $5f, $56, $d5, $cd
    db $d2, $79, $e8, $07, $21, $30, $01, $39
    db $36, $00, $21, $30, $01, $39, $7e, $21
    db $36, $01, $39, $96, $30, $31, $21, $31
    db $01, $39, $3a, $86, $23, $23, $4f, $7e
    db $ce, $00, $47, $0a, $21, $2f, $01, $39
    db $22, $5e, $16, $00, $21, $0c, $00, $19
    db $5d, $54, $21, $31, $01, $39, $2a, $83
    db $5f, $7e, $8a, $57, $1a, $21, $2f, $01
    db $39, $b6, $23, $02, $34, $18, $c3, $21
    db $2c, $01, $39, $7e, $f5, $33, $21, $37
    db $01, $39, $3a, $2b, $f5, $33, $2a, $5f
    db $56, $d5, $21, $35, $01, $39, $2a, $5f
    db $56, $d5, $cd, $89, $7d, $e8, $06, $21
    db $37, $01, $39, $34, $21, $2d, $01, $39
    db $7e, $21, $31, $01, $39, $77, $21, $2e
    db $01, $39, $7e, $21, $32, $01, $39, $22
    db $23, $7e, $c6, $10, $22, $7e, $ce, $00
    db $77, $c3, $e3, $78, $21, $38, $01, $39
    db $f9, $c9, $f8, $06, $7e, $f5, $33, $f8
    db $03, $2a, $5f, $2a, $57, $d5, $2a, $5f
    db $56, $d5, $cd, $3f, $7d, $e8, $05, $0e
    db $00, $79, $f8, $06, $96, $d0, $f8, $02
    db $2a, $81, $5f, $7e, $ce, $00, $57, $1a
    db $f8, $08, $ae, $2b, $a6, $12, $0c, $18
    db $e8, $e8, $f0, $f8, $1a, $2a, $ae, $0f
    db $30, $04, $3e, $ff, $18, $01, $af, $f8
    db $00, $77, $f8, $1b, $4e, $cb, $41, $3e
    db $ff, $20, $01, $af, $f8, $01, $77, $f8
    db $1a, $7e, $a9, $cb, $4f, $3e, $ff, $20
    db $01, $af, $f8, $02, $77, $cb, $49, $3e
    db $ff, $20, $01, $af, $f8, $03, $77, $f8
    db $07, $36, $00, $f8, $12, $7e, $f8, $08
    db $77, $f8, $13, $7e, $f8, $09, $77, $f8
    db $14, $7e, $f8, $0a, $77, $f8, $15, $7e
    db $f8, $0b, $77, $f8, $07, $7e, $f8, $17
    db $96, $d2, $1d, $7b, $f8, $07, $7e, $b7
    db $28, $03, $af, $18, $03, $f8, $18, $7e
    db $f8, $0c, $77, $f8, $17, $7e, $3d, $f8
    db $07, $96, $20, $09, $f8, $0c, $7e, $f8
    db $19, $b6, $f8, $0c, $77, $f8, $0a, $7e
    db $f8, $0d, $32, $2b, $7e, $f8, $0e, $32
    db $2b, $7e, $2f, $f8, $04, $77, $f8, $0f
    db $36, $00, $f8, $0f, $7e, $f8, $16, $96
    db $30, $6c, $f8, $08, $7e, $f8, $0f, $86
    db $f5, $f8, $07, $f1, $22, $23, $23, $23
    db $7e, $ce, $00, $f8, $06, $32, $2a, $5f
    db $56, $1a, $77, $f8, $02, $a6, $f8, $05
    db $77, $3a, $2b, $ae, $23, $23, $77, $3a
    db $a6, $23, $22, $7e, $f8, $00, $a6, $f8
    db $06, $77, $f8, $01, $ae, $f8, $06, $77
    db $3a, $2b, $a6, $23, $23, $32, $2a, $57
    db $5e, $d5, $f8, $0e, $2a, $f5, $33, $2a
    db $5f, $56, $d5, $cd, $69, $7d, $e8, $05
    db $f8, $0d, $7e, $c6, $02, $22, $7e, $ce
    db $00, $32, $7e, $e6, $0f, $20, $0a, $f8
    db $0d, $7e, $c6, $30, $22, $7e, $ce, $01
    db $77, $f8, $0f, $34, $18, $8c, $f8, $07
    db $34, $23, $7e, $c6, $0c, $22, $7e, $ce
    db $00, $22, $7e, $c6, $10, $22, $7e, $ce
    db $00, $77, $c3, $53, $7a, $e8, $10, $c9
    db $f8, $02, $7e, $4f, $d6, $20, $38, $0a
    db $7e, $d6, $80, $30, $05, $79, $c6, $e0
    db $5f, $c9, $f8, $02, $7e, $d6, $c0, $38
    db $0a, $3e, $c4, $96, $38, $05, $79, $c6
    db $a0, $5f, $c9, $1e, $1f, $c9, $f8, $04
    db $46, $f8, $02, $2a, $66, $6f, $af, $22
    db $22, $22, $22, $05, $20, $f9, $c9, $f8
    db $02, $2a, $5f, $56, $23, $2a, $66, $6f
    db $7d, $c6, $0c, $6f, $8c, $95, $67, $06
    db $0c, $1a, $13, $4f, $1a, $13, $b6, $77
    db $7d, $d6, $0c, $6f, $7c, $de, $00, $67
    db $7e, $b1, $77, $7d, $c6, $0d, $6f, $8c
    db $95, $67, $05, $20, $e4, $c9, $f8, $02
    db $2a, $5f, $56, $23, $2a, $66, $6f, $7d
    db $c6, $0c, $6f, $8c, $95, $67, $06, $0c
    db $1a, $13, $4f, $1a, $13, $cb, $39, $cb
    db $1f, $b6, $77, $7d, $d6, $0c, $6f, $7c
    db $de, $00, $67, $7e, $b1, $77, $7d, $c6
    db $0d, $6f, $8c, $95, $67, $05, $20, $e0
    db $c9, $f8, $02, $2a, $5f, $56, $23, $2a
    db $66, $6f, $7d, $c6, $0c, $6f, $8c, $95
    db $67, $06, $0c, $1a, $13, $4f, $1a, $13
    db $cb, $39, $cb, $1f, $cb, $39, $cb, $1f
    db $b6, $77, $7d, $d6, $0c, $6f, $7c, $de
    db $00, $67, $7e, $b1, $77, $7d, $c6, $0d
    db $6f, $8c, $95, $67, $05, $20, $dc, $c9
    db $f8, $02, $2a, $5f, $56, $23, $2a, $66
    db $6f, $7d, $c6, $0c, $6f, $8c, $95, $67
    db $06, $0c, $1a, $13, $4f, $1a, $13, $cb
    db $39, $cb, $1f, $cb, $39, $cb, $1f, $cb
    db $39, $cb, $1f, $b6, $77, $7d, $d6, $0c
    db $6f, $7c, $de, $00, $67, $7e, $b1, $77
    db $7d, $c6, $0d, $6f, $8c, $95, $67, $05
    db $20, $d8, $c9, $f8, $02, $2a, $5f, $56
    db $23, $2a, $66, $6f, $7d, $c6, $0c, $6f
    db $8c, $95, $67, $06, $0c, $1a, $13, $4f
    db $1a, $13, $cb, $39, $cb, $1f, $cb, $39
    db $cb, $1f, $cb, $39, $cb, $1f, $cb, $39
    db $cb, $1f, $b6, $77, $7d, $d6, $0c, $6f
    db $7c, $de, $00, $67, $7e, $b1, $77, $7d
    db $c6, $0d, $6f, $8c, $95, $67, $05, $20
    db $d4, $c9, $f8, $02, $2a, $5f, $56, $23
    db $2a, $66, $6f, $7d, $c6, $0c, $6f, $8c
    db $95, $67, $06, $0c, $1a, $13, $4f, $1a
    db $13, $cb, $39, $cb, $1f, $cb, $39, $cb
    db $1f, $cb, $39, $cb, $1f, $cb, $39, $cb
    db $1f, $cb, $39, $cb, $1f, $b6, $77, $7d
    db $d6, $0c, $6f, $7c, $de, $00, $67, $7e
    db $b1, $77, $7d, $c6, $0d, $6f, $8c, $95
    db $67, $05, $20, $d0, $c9, $f8, $02, $2a
    db $5f, $56, $23, $2a, $66, $6f, $7d, $c6
    db $0c, $6f, $8c, $95, $67, $06, $0c, $1a
    db $13, $4f, $1a, $13, $cb, $39, $cb, $1f
    db $cb, $39, $cb, $1f, $cb, $39, $cb, $1f
    db $cb, $39, $cb, $1f, $cb, $39, $cb, $1f
    db $cb, $39, $cb, $1f, $b6, $77, $7d, $d6
    db $0c, $6f, $7c, $de, $00, $67, $7e, $b1
    db $77, $7d, $c6, $0d, $6f, $8c, $95, $67
    db $05, $20, $cc, $c9, $f8, $02, $2a, $5f
    db $56, $23, $2a, $66, $6f, $7d, $c6, $0c
    db $6f, $8c, $95, $67, $06, $0c, $1a, $13
    db $4f, $1a, $13, $cb, $39, $cb, $1f, $cb
    db $39, $cb, $1f, $cb, $39, $cb, $1f, $cb
    db $39, $cb, $1f, $cb, $39, $cb, $1f, $cb
    db $39, $cb, $1f, $cb, $39, $cb, $1f, $b6
    db $77, $7d, $d6, $0c, $6f, $7c, $de, $00
    db $67, $7e, $b1, $77, $7d, $c6, $0d, $6f
    db $8c, $95, $67, $05, $20, $c8, $c9, $f8
    db $06, $46, $f8, $02, $2a, $5f, $56, $f8
    db $04, $2a, $66, $6f, $f3, $f0, $41, $cb
    db $4f, $20, $fa, $1a, $fb, $22, $13, $13
    db $7b, $e6, $0f, $20, $08, $7b, $c6, $30
    db $5f, $7a, $ce, $01, $57, $05, $20, $e4
    db $c9, $f8, $02, $2a, $5f, $2a, $57, $4e
    db $23, $46, $23, $6e, $cd, $fd, $06, $f0
    db $41, $cb, $4f, $20, $fa, $1a, $a1, $b0
    db $12, $1c, $1a, $a1, $b5, $12, $c3, $06
    db $07, $f8, $07, $4e, $f8, $06, $7e, $cb
    db $3f, $cb, $3f, $47, $f8, $04, $2a, $5f
    db $56, $f8, $02, $2a, $66, $6f, $f3, $f0
    db $41, $e6, $03, $fe, $01, $20, $0c, $f0
    db $44, $fe, $90, $38, $06, $fe, $98, $30
    db $02, $18, $25, $f0, $44, $fe, $8f, $38
    db $11, $fb, $f0, $44, $fe, $8f, $38, $de
    db $fe, $91, $38, $f6, $fe, $97, $38, $d6
    db $18, $f0, $f0, $41, $e6, $03, $fe, $03
    db $20, $f8, $f0, $41, $e6, $03, $20, $fa
    db $2a, $a9, $12, $1c, $12, $13, $2a, $a9
    db $12, $1c, $12, $13, $2a, $a9, $12, $1c
    db $12, $13, $2a, $a9, $12, $1c, $12, $13
    db $fb, $7b, $e6, $0f, $20, $08, $7b, $c6
    db $30, $5f, $7a, $ce, $01, $57, $05, $20
    db $9d, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

DrawNameWithIconImpl::
    db $e8, $d4, $f8, $36, $7e, $b7, $20, $0b
    db $f8, $01, $36, $c0, $f8, $36, $36, $13
    db $c3, $40, $7f, $01, $ff, $00, $78, $d6
    db $fe, $30, $15, $f8, $34, $2a, $80, $5f
    db $7e, $ce, $00, $57, $1a, $b7, $28, $08
    db $fe, $2e, $20, $01, $48, $04, $18, $e6
    db $f8, $01, $36, $c3, $79, $3c, $ca, $3c
    db $7f, $2b, $78, $91, $3d, $77, $06, $00
    db $59, $50, $13, $f8, $34, $2a, $83, $5f
    db $7e, $8a, $57, $1a, $e6, $df, $f8, $2b
    db $77, $59, $50, $13, $13, $f8, $34, $2a
    db $83, $5f, $7e, $8a, $57, $1a, $e6, $df
    db $5f, $f8, $00, $7e, $d6, $03, $3e, $01
    db $28, $01, $af, $57, $03, $03, $03, $f8
    db $34, $2a, $81, $4f, $7e, $88, $47, $f8
    db $2b, $7e, $d6, $47, $20, $23, $7b, $d6
    db $42, $20, $1e, $f8, $00, $7e, $d6, $02
    db $20, $06, $f8, $01, $36, $c1, $18, $2c
    db $7a, $b7, $28, $28, $0a, $cb, $af, $fe
    db $43, $20, $21, $f8, $01, $36, $c2, $18
    db $1b, $7a, $b7, $28, $17, $f8, $2b, $7e
    db $d6, $53, $20, $10, $7b, $d6, $41, $20
    db $0b, $0a, $cb, $af, $fe, $56, $20, $04
    db $f8, $01, $36, $c4, $f8, $36, $35, $7e
    db $fa, $fb, $ff, $b7, $20, $2a, $f8, $01
    db $4d, $44, $f8, $38, $7e, $f5, $33, $21
    db $01, $00, $e5, $c5, $cd, $b7, $08, $e8
    db $05, $f8, $38, $3a, $2b, $57, $1e, $01
    db $d5, $3a, $2b, $f5, $33, $2a, $5f, $56
    db $d5, $cd, $b7, $08, $e8, $05, $18, $51
    db $f8, $01, $2a, $77, $f8, $2b, $36, $00
    db $f8, $2b, $5e, $1c, $16, $00, $21, $02
    db $00, $39, $19, $4d, $44, $f8, $34, $7e
    db $f8, $2b, $86, $5f, $f5, $f8, $37, $f1
    db $7e, $ce, $00, $57, $1a, $02, $1a, $b7
    db $28, $08, $f8, $2b, $34, $7e, $d6, $27
    db $38, $d6, $f8, $2a, $36, $00, $f8, $38
    db $7e, $f5, $33, $af, $0f, $f5, $21, $05
    db $00, $39, $e5, $af, $0f, $f5, $af, $0f
    db $f5, $af, $0f, $f5, $cd, $00, $75, $e8
    db $0b, $e8, $2c, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
