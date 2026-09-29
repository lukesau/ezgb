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
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    db $fa, $fc, $db, $b7, $ca, $3f, $51, $fe
    db $01, $ca, $d0, $56, $fe, $02, $20, $08
    db $af, $f5, $33, $cd, $62, $4c, $33, $c9
    db $fe, $06, $20, $09, $3e, $01, $f5, $33
    db $cd, $62, $4c, $33, $c9, $fe, $07, $20
    db $0e, $cd, $3f, $51, $21, $4c, $00, $e5
    db $cd, $02, $4c, $e1, $c3, $d0, $56, $fe
    db $04, $ca, $5f, $5a, $fe, $05, $ca, $b0
    db $5a, $c3, $37, $4d, $21, $00, $7f, $36
    db $e1, $2e, $10, $36, $e2, $2e, $20, $36
    db $e3, $11, $c0, $7f, $f8, $02, $7e, $12
    db $21, $f0, $7f, $36, $e4, $c9, $21, $00
    db $7f, $36, $e1, $2e, $10, $36, $e2, $2e
    db $20, $36, $e3, $2e, $d0, $36, $01, $2e
    db $f0, $36, $e4, $c9, $cd, $88, $06, $af
    db $f5, $33, $cd, $44, $4a, $33, $c9, $3e
    db $06, $f5, $33, $cd, $44, $4a, $33, $0e
    db $00, $69, $26, $00, $11, $08, $a0, $19
    db $46, $69, $26, $00, $11, $50, $db, $19
    db $70, $69, $26, $00, $11, $48, $db, $19
    db $3e, $ba, $81, $5f, $3e, $4a, $ce, $00
    db $57, $1a, $a0, $77, $0c, $79, $d6, $07
    db $38, $d7, $af, $f5, $33, $cd, $44, $4a
    db $33, $c9, $7f, $7f, $3f, $3f, $07, $1f
    db $ff, $3b, $3e, $06, $f5, $33, $cd, $44
    db $4a, $33, $f8, $00, $36, $00, $f8, $00
    db $7e, $c6, $08, $4f, $3e, $00, $ce, $a0
    db $47, $f8, $03, $7e, $f8, $00, $86, $23
    db $23, $23, $23, $5f, $7e, $ce, $00, $57
    db $1a, $02, $f8, $00, $34, $7e, $d6, $07
    db $38, $dc, $cd, $5e, $4a, $af, $f5, $33
    db $cd, $44, $4a, $e1, $c9, $f8, $02, $7e
    db $e6, $0f, $fe, $0a, $38, $03, $1e, $00
    db $c9, $f8, $02, $7e, $cb, $37, $e6, $0f
    db $fe, $0a, $38, $03, $1e, $00, $c9, $f8
    db $03, $3a, $96, $3e, $00, $17, $ee, $01
    db $5f, $c9, $f8, $02, $2a, $4f, $46, $0a
    db $c5, $26, $59, $e5, $33, $f5, $33, $cd
    db $fd, $4a, $e1, $7b, $c1, $b7, $20, $02
    db $5f, $c9, $69, $60, $23, $7e, $c5, $26
    db $59, $e5, $33, $f5, $33, $cd, $fd, $4a
    db $e1, $7b, $c1, $b7, $20, $02, $5f, $c9
    db $69, $60, $23, $23, $7e, $c5, $26, $23
    db $e5, $33, $f5, $33, $cd, $fd, $4a, $e1
    db $7b, $c1, $b7, $20, $02, $5f, $c9, $69
    db $60, $23, $23, $23, $56, $c5, $d5, $3e
    db $31, $f5, $33, $d5, $33, $cd, $fd, $4a
    db $e1, $7b, $d1, $c1, $b7, $28, $04, $7a
    db $b7, $20, $03, $1e, $00, $c9, $21, $05
    db $00, $09, $56, $c5, $d5, $3e, $12, $f5
    db $33, $d5, $33, $cd, $fd, $4a, $e1, $7b
    db $d1, $c1, $b7, $28, $04, $7a, $b7, $20
    db $03, $1e, $00, $c9, $21, $06, $00, $09
    db $7e, $26, $99, $e5, $33, $f5, $33, $cd
    db $fd, $4a, $e1, $7b, $b7, $20, $02, $5f
    db $c9, $1e, $01, $c9, $3b, $0e, $00, $21
    db $fc, $4b, $06, $00, $09, $46, $f8, $03
    db $2a, $80, $5f, $7e, $ce, $00, $57, $1a
    db $f8, $00, $77, $f8, $05, $2a, $80, $47
    db $7e, $ce, $00, $68, $67, $46, $f8, $00
    db $7e, $90, $30, $04, $1e, $ff, $18, $12
    db $78, $f8, $00, $96, $30, $04, $1e, $01
    db $18, $08, $0c, $79, $d6, $06, $38, $c7
    db $1e, $00, $33, $c9, $06, $05, $03, $02
    db $01, $00, $cd, $7f, $4a, $11, $48, $db
    db $d5, $cd, $22, $4b, $e1, $7b, $b7, $c8
    db $f8, $03, $7e, $b7, $20, $2d, $fa, $50
    db $db, $07, $d8, $fa, $47, $db, $b7, $28
    db $22, $11, $40, $db, $d5, $11, $48, $db
    db $d5, $cd, $bc, $4b, $e8, $04, $4b, $af
    db $57, $91, $cb, $7b, $28, $07, $cb, $7a
    db $20, $08, $bf, $18, $05, $cb, $7a, $28
    db $01, $37, $d0, $1e, $00, $7b, $c6, $40
    db $4f, $3e, $00, $ce, $db, $47, $21, $48
    db $db, $16, $00, $19, $7e, $02, $1c, $7b
    db $d6, $07, $38, $e9, $21, $47, $db, $36
    db $01, $c9, $cd, $3f, $51, $f8, $02, $7e
    db $b7, $3e, $54, $20, $02, $3e, $42, $f8
    db $02, $66, $e5, $33, $f5, $33, $cd, $02
    db $4c, $e1, $c3, $d0, $56, $e8, $f3, $0e
    db $3c, $c5, $cd, $88, $06, $c1, $0d, $20
    db $f8, $cd, $7f, $4a, $f8, $00, $4d, $44
    db $f8, $0b, $36, $00, $f8, $0c, $36, $00
    db $79, $f8, $0c, $86, $f5, $f8, $09, $f1
    db $22, $78, $ce, $00, $77, $f8, $0c, $3a
    db $2b, $2b, $c6, $48, $22, $3e, $00, $ce
    db $db, $32, $2a, $5f, $56, $1a, $f8, $07
    db $5e, $23, $66, $6b, $77, $f8, $0c, $34
    db $7e, $d6, $07, $38, $d3, $c5, $cd, $88
    db $06, $cd, $7f, $4a, $c1, $f8, $0c, $36
    db $01, $1e, $00, $6b, $26, $00, $09, $56
    db $7b, $c6, $48, $6f, $3e, $00, $ce, $db
    db $67, $7e, $92, $28, $04, $f8, $0c, $36
    db $00, $1c, $7b, $d6, $07, $38, $e4, $f8
    db $0c, $7e, $b7, $20, $08, $f8, $0b, $34
    db $7e, $d6, $08, $38, $97, $e8, $0d, $c9
    db $fa, $4e, $db, $b7, $20, $03, $1e, $5a
    db $c9, $11, $48, $db, $d5, $cd, $22, $4b
    db $e1, $7b, $b7, $20, $03, $1e, $49, $c9
    db $fa, $50, $db, $07, $30, $03, $1e, $56
    db $c9, $11, $40, $db, $d5, $11, $48, $db
    db $d5, $cd, $bc, $4b, $e8, $04, $4b, $cb
    db $79, $1e, $45, $c0, $1e, $00, $c9, $cd
    db $3f, $51, $fa, $47, $db, $b7, $c8, $cd
    db $7f, $4a, $cd, $00, $4d, $7b, $b7, $c8
    db $cd, $7d, $4c, $cd, $00, $4d, $7b, $b7
    db $c8, $d5, $7b, $f5, $33, $cd, $6a, $4e
    db $33, $7b, $d1, $b7, $28, $09, $11, $40
    db $db, $d5, $cd, $c1, $4a, $e1, $c9, $7b
    db $d6, $56, $c0, $11, $48, $db, $d5, $cd
    db $c1, $4a, $e1, $c9, $f8, $04, $7e, $cb
    db $37, $e6, $0f, $4e, $2b, $2b, $f5, $79
    db $e6, $0f, $4f, $f1, $5e, $23, $56, $47
    db $d6, $0a, $30, $05, $78, $c6, $30, $18
    db $03, $78, $c6, $37, $12, $13, $41, $79
    db $d6, $0a, $30, $05, $78, $c6, $30, $18
    db $03, $78, $c6, $37, $12, $c9, $f8, $04
    db $2a, $c6, $06, $4f, $7e, $ce, $00, $47
    db $0a, $f5, $33, $f8, $03, $2a, $5f, $56
    db $d5, $cd, $74, $4d, $e8, $03, $f8, $02
    db $2a, $4f, $2a, $47, $03, $03, $3e, $2d
    db $02, $2a, $c6, $05, $4f, $7e, $ce, $00
    db $69, $67, $46, $f8, $02, $2a, $5f, $56
    db $13, $13, $13, $c5, $33, $d5, $cd, $74
    db $4d, $e8, $03, $f8, $02, $2a, $c6, $05
    db $4f, $7e, $ce, $00, $69, $67, $36, $2d
    db $f8, $04, $2a, $4f, $46, $03, $03, $03
    db $0a, $47, $f8, $02, $2a, $c6, $06, $4f
    db $7e, $ce, $00, $c5, $33, $47, $c5, $cd
    db $74, $4d, $e8, $03, $c9, $f8, $04, $2a
    db $4f, $46, $03, $03, $0a, $f5, $33, $f8
    db $03, $2a, $5f, $56, $d5, $cd, $74, $4d
    db $e8, $03, $f8, $02, $2a, $4f, $2a, $47
    db $03, $03, $3e, $3a, $02, $2a, $4f, $46
    db $03, $0a, $57, $f8, $02, $2a, $4f, $46
    db $03, $03, $03, $d5, $33, $c5, $cd, $74
    db $4d, $e8, $03, $f8, $02, $2a, $c6, $05
    db $4f, $7e, $ce, $00, $69, $67, $36, $3a
    db $f8, $04, $2a, $4f, $46, $0a, $47, $f8
    db $02, $2a, $c6, $06, $4f, $7e, $ce, $00
    db $c5, $33, $47, $c5, $cd, $74, $4d, $e8
    db $03, $c9, $e8, $f2, $f8, $10, $7e, $d6
    db $5a, $20, $05, $01, $33, $50, $18, $1b
    db $f8, $10, $7e, $d6, $49, $20, $05, $01
    db $3e, $50, $18, $0f, $f8, $10, $7e, $d6
    db $56, $20, $05, $01, $47, $50, $18, $03
    db $01, $52, $50, $16, $00, $6a, $26, $00
    db $09, $7e, $b7, $28, $03, $14, $18, $f5
    db $c5, $d5, $21, $05, $08, $e5, $3e, $01
    db $f5, $33, $21, $31, $50, $e5, $cd, $b7
    db $08, $e8, $05, $21, $03, $00, $e5, $af
    db $f5, $33, $cd, $91, $27, $e8, $03, $21
    db $6c, $01, $e5, $21, $25, $8d, $e5, $3e
    db $1b, $f5, $33, $cd, $ba, $27, $e8, $05
    db $d1, $c1, $21, $04, $06, $e5, $d5, $33
    db $c5, $cd, $b7, $08, $e8, $05, $0e, $00
    db $59, $16, $00, $21, $00, $00, $39, $19
    db $36, $20, $0c, $79, $d6, $0d, $38, $f0
    db $f8, $00, $3e, $43, $22, $3e, $48, $22
    db $3e, $49, $22, $11, $50, $db, $7b, $22
    db $23, $d5, $e5, $cd, $a6, $4d, $e8, $04
    db $21, $00, $00, $39, $4d, $44, $c5, $21
    db $04, $07, $e5, $3e, $0d, $f5, $33, $c5
    db $cd, $b7, $08, $e8, $05, $c1, $1e, $00
    db $d5, $16, $00, $21, $02, $00, $39, $19
    db $d1, $36, $20, $1c, $7b, $d6, $05, $38
    db $ef, $c5, $11, $50, $db, $d5, $21, $09
    db $00, $39, $e5, $cd, $0d, $4e, $e8, $04
    db $c1, $c5, $21, $04, $08, $e5, $3e, $0d
    db $f5, $33, $c5, $cd, $b7, $08, $e8, $05
    db $c1, $f8, $00, $3e, $53, $22, $36, $44
    db $c5, $11, $40, $db, $d5, $21, $09, $00
    db $39, $e5, $cd, $a6, $4d, $e8, $04, $c1
    db $c5, $21, $04, $09, $e5, $3e, $0d, $f5
    db $33, $c5, $cd, $b7, $08, $e8, $05, $c1
    db $f8, $00, $3e, $20, $22, $36, $20, $c5
    db $11, $40, $db, $d5, $21, $09, $00, $39
    db $e5, $cd, $0d, $4e, $e8, $04, $c1, $21
    db $04, $0a, $e5, $3e, $0d, $f5, $33, $c5
    db $cd, $b7, $08, $e8, $05, $21, $03, $00
    db $e5, $af, $f5, $33, $cd, $91, $27, $e8
    db $03, $21, $6a, $01, $e5, $21, $5d, $83
    db $e5, $3e, $1e, $f5, $33, $cd, $ba, $27
    db $e8, $05, $21, $04, $0c, $e5, $3e, $0c
    db $f5, $33, $11, $5e, $50, $d5, $cd, $b7
    db $08, $e8, $05, $f8, $0d, $36, $00, $cd
    db $88, $06, $cd, $4a, $3a, $7b, $e6, $30
    db $28, $06, $f8, $0d, $36, $00, $18, $03
    db $f8, $0d, $34, $f8, $0d, $7e, $d6, $08
    db $38, $e5, $cd, $88, $06, $cd, $4a, $3a
    db $cb, $63, $28, $06, $f8, $0d, $36, $01
    db $18, $08, $cb, $6b, $28, $ec, $f8, $0d
    db $36, $00, $cd, $4a, $3a, $7b, $e6, $30
    db $28, $05, $cd, $88, $06, $18, $f3, $af
    db $0f, $f5, $af, $f5, $33, $cd, $91, $27
    db $e8, $03, $21, $6c, $01, $e5, $21, $25
    db $8d, $e5, $3e, $1b, $f5, $33, $cd, $ba
    db $27, $e8, $05, $f8, $0d, $5e, $e8, $0e
    db $c9, $20, $00, $52, $54, $43, $20, $52
    db $45, $53, $45, $54, $3f, $00, $52, $54
    db $43, $20, $42, $41, $44, $3f, $00, $52
    db $54, $43, $20, $4c, $4f, $57, $20, $56
    db $3f, $00, $52, $54, $43, $20, $42, $45
    db $48, $49, $4e, $44, $3f, $00, $41, $3a
    db $53, $44, $20, $20, $42, $3a, $4b, $45
    db $45, $50, $00, $3b, $f8, $00, $36, $00
    db $f8, $00, $5e, $16, $db, $f8, $03, $7e
    db $f8, $00, $86, $23, $23, $23, $23, $4f
    db $7e, $ce, $00, $47, $0a, $12, $0a, $b7
    db $28, $05, $f8, $00, $34, $18, $e1, $33
    db $c9, $f8, $02, $2a, $5f, $56, $d5, $cd
    db $6b, $50, $e1, $cd, $74, $4a, $3e, $01
    db $f5, $33, $11, $00, $db, $d5, $11, $0f
    db $ca, $d5, $cd, $26, $19, $e8, $05, $7b
    db $b7, $28, $03, $1e, $00, $c9, $cd, $74
    db $4a, $f8, $04, $2a, $5f, $56, $d5, $11
    db $00, $02, $d5, $11, $00, $d8, $d5, $11
    db $0f, $ca, $d5, $cd, $41, $19, $e8, $08
    db $d5, $cd, $74, $4a, $01, $0f, $ca, $c5
    db $cd, $a1, $19, $e1, $d1, $f8, $04, $2a
    db $4f, $46, $7b, $b7, $28, $06, $af, $02
    db $03, $02, $18, $17, $69, $60, $2a, $66
    db $6f, $3e, $ff, $bd, $3e, $00, $9c, $30
    db $0a, $7c, $d6, $02, $30, $05, $7d, $02
    db $03, $af, $02, $1e, $01, $c9, $3b, $3b
    db $cd, $74, $4a, $f8, $00, $e5, $f8, $08
    db $2a, $5f, $56, $d5, $f8, $08, $2a, $5f
    db $56, $d5, $11, $0f, $ca, $d5, $cd, $63
    db $19, $e8, $08, $7b, $b7, $20, $15, $f8
    db $00, $7e, $f8, $06, $96, $20, $0b, $f8
    db $01, $7e, $f8, $07, $96, $20, $03, $5f
    db $18, $02, $1e, $ff, $33, $33, $c9, $3b
    db $3b, $21, $80, $da, $36, $01, $2e, $81
    db $36, $00, $2e, $82, $36, $00, $21, $47
    db $db, $36, $00, $21, $7f, $da, $36, $00
    db $2e, $00, $75, $f8, $00, $e5, $e5, $11
    db $9d, $51, $d5, $cd, $91, $50, $e8, $04
    db $7b, $e1, $b7, $28, $10, $af, $f5, $33
    db $f8, $01, $2a, $5f, $56, $d5, $cd, $b4
    db $51, $e8, $03, $18, $1d, $e5, $11, $a7
    db $51, $d5, $cd, $91, $50, $e8, $04, $7b
    db $b7, $28, $0f, $3e, $01, $f5, $33, $f8
    db $01, $2a, $5f, $56, $d5, $cd, $b4, $51
    db $e8, $03, $33, $33, $c9, $2f, $45, $5a
    db $47, $42, $2e, $43, $46, $47, $00, $2f
    db $46, $4c, $41, $55, $4e, $43, $48, $2e
    db $43, $46, $47, $00, $e8, $ed, $f8, $15
    db $af, $96, $23, $3e, $02, $9e, $30, $06
    db $f8, $15, $af, $22, $36, $02, $f8, $15
    db $2a, $4f, $7e, $c6, $d8, $47, $af, $02
    db $f8, $00, $af, $22, $22, $af, $22, $22
    db $af, $22, $77, $f8, $04, $5d, $54, $f8
    db $15, $1a, $13, $96, $23, $1a, $9e, $d2
    db $f3, $54, $f8, $04, $2a, $4f, $46, $f8
    db $15, $79, $96, $23, $78, $9e, $30, $0c
    db $21, $00, $d8, $09, $7e, $fe, $20, $20
    db $03, $03, $18, $eb, $f8, $06, $79, $22
    db $70, $f8, $11, $79, $22, $70, $f8, $11
    db $5d, $54, $f8, $15, $1a, $13, $96, $23
    db $1a, $9e, $30, $23, $f8, $11, $3a, $2b
    db $22, $23, $23, $3a, $2b, $c6, $d8, $32
    db $2a, $5f, $56, $1a, $fe, $0d, $28, $0f
    db $fe, $0a, $28, $0b, $b7, $28, $08, $23
    db $34, $20, $d3, $23, $34, $18, $cf, $f8
    db $11, $7e, $f8, $08, $77, $f8, $12, $7e
    db $f8, $09, $77, $f8, $11, $2a, $4f, $46
    db $f8, $15, $79, $96, $23, $78, $9e, $30
    db $10, $21, $00, $d8, $09, $7e, $fe, $0d
    db $28, $04, $fe, $0a, $20, $03, $03, $18
    db $e7, $f8, $04, $79, $22, $70, $f8, $08
    db $2a, $4f, $7e, $c6, $d8, $47, $0a, $b7
    db $20, $1a, $f8, $08, $5d, $54, $f8, $15
    db $1a, $13, $96, $23, $1a, $9e, $30, $0c
    db $f8, $15, $7e, $f8, $04, $77, $f8, $16
    db $7e, $f8, $05, $77, $f8, $06, $5d, $54
    db $f8, $08, $1a, $13, $96, $23, $1a, $9e
    db $30, $32, $f8, $08, $7e, $c6, $ff, $f5
    db $f8, $11, $f1, $77, $f5, $f8, $0b, $f1
    db $7e, $ce, $ff, $f8, $10, $32, $2a, $23
    db $32, $2a, $23, $c6, $d8, $32, $2a, $5f
    db $56, $1a, $fe, $20, $20, $0e, $f8, $0f
    db $7e, $f8, $08, $77, $f8, $10, $7e, $f8
    db $09, $77, $18, $c0, $f8, $06, $2a, $23
    db $96, $20, $07, $2b, $2a, $23, $96, $ca
    db $db, $51, $f8, $08, $2a, $23, $77, $f8
    db $06, $7e, $f8, $0b, $77, $f8, $06, $7e
    db $f5, $f8, $0e, $f1, $77, $f5, $f8, $09
    db $f1, $7e, $c6, $d8, $f8, $0d, $77, $f8
    db $17, $7e, $b7, $28, $13, $f8, $0a, $2a
    db $96, $23, $f5, $33, $2a, $5f, $56, $d5
    db $cd, $5e, $55, $e8, $03, $c3, $f3, $54
    db $f8, $06, $7e, $f8, $0e, $77, $f8, $07
    db $7e, $f8, $0f, $77, $f8, $0e, $5d, $54
    db $f8, $08, $1a, $13, $96, $23, $1a, $9e
    db $3e, $00, $17, $f8, $10, $32, $2b, $2a
    db $23, $23, $c6, $01, $32, $2b, $7e, $ce
    db $00, $f8, $12, $32, $2b, $7e, $b7, $28
    db $1b, $2b, $2b, $2a, $4f, $7e, $c6, $d8
    db $47, $0a, $fe, $3d, $28, $0e, $23, $23
    db $7e, $f8, $0e, $77, $f8, $12, $7e, $f8
    db $0f, $77, $18, $c0, $f8, $10, $cb, $46
    db $ca, $db, $51, $2b, $2b, $7e, $f8, $0b
    db $96, $4f, $f8, $11, $2a, $47, $5e, $79
    db $b7, $28, $1e, $79, $f8, $11, $22, $af
    db $32, $7e, $f8, $06, $86, $23, $57, $3e
    db $00, $8e, $6a, $67, $2b, $7c, $c6, $d8
    db $67, $7e, $fe, $20, $20, $03, $0d, $18
    db $de, $f8, $0e, $71, $f8, $11, $78, $22
    db $73, $f8, $11, $3a, $2b, $22, $23, $23
    db $3a, $2b, $c6, $d8, $77, $f8, $11, $5d
    db $54, $f8, $08, $1a, $13, $96, $23, $1a
    db $9e, $30, $12, $f8, $0f, $2a, $5f, $56
    db $1a, $fe, $20, $20, $08, $23, $34, $20
    db $d8, $23, $34, $18, $d4, $f8, $11, $2a
    db $4f, $46, $f8, $00, $7e, $b7, $20, $38
    db $c5, $3e, $07, $f5, $33, $11, $f6, $54
    db $d5, $f8, $13, $3a, $2b, $f5, $33, $2a
    db $5f, $56, $d5, $cd, $22, $55, $e8, $06
    db $7b, $c1, $b7, $28, $1b, $f8, $00, $36
    db $01, $f8, $11, $4e, $f8, $0a, $7e, $91
    db $f5, $33, $f8, $10, $2a, $5f, $56, $d5
    db $cd, $5e, $55, $e8, $03, $c3, $db, $51
    db $21, $00, $d8, $09, $e5, $7d, $f8, $13
    db $77, $e1, $7c, $f8, $12, $77, $f8, $01
    db $7e, $b7, $20, $35, $c5, $3e, $03, $f5
    db $33, $11, $fe, $54, $d5, $f8, $13, $3a
    db $2b, $f5, $33, $2a, $5f, $56, $d5, $cd
    db $22, $55, $e8, $06, $7b, $c1, $b7, $28
    db $18, $f8, $01, $36, $01, $f8, $0a, $7e
    db $91, $f5, $33, $f8, $12, $2a, $5f, $56
    db $d5, $cd, $ec, $55, $e8, $03, $c3, $db
    db $51, $f8, $08, $7e, $91, $f5, $f8, $11
    db $f1, $77, $f5, $f8, $0b, $f1, $7e, $98
    db $f8, $10, $77, $f8, $02, $7e, $b7, $20
    db $34, $11, $02, $55, $c5, $3e, $07, $f5
    db $33, $d5, $f8, $13, $3a, $2b, $f5, $33
    db $2a, $5f, $56, $d5, $cd, $22, $55, $e8
    db $06, $7b, $c1, $b7, $28, $17, $f8, $02
    db $36, $01, $f8, $0f, $2a, $5f, $2a, $57
    db $d5, $2a, $5f, $56, $d5, $cd, $9c, $59
    db $e8, $04, $c3, $db, $51, $f8, $03, $7e
    db $b7, $c2, $db, $51, $c5, $3e, $02, $f5
    db $33, $11, $0a, $55, $d5, $f8, $13, $3a
    db $2b, $f5, $33, $2a, $5f, $56, $d5, $cd
    db $22, $55, $e8, $06, $7b, $c1, $b7, $ca
    db $db, $51, $f8, $03, $36, $01, $f8, $0f
    db $2a, $d6, $02, $7e, $de, $00, $38, $15
    db $23, $2a, $5f, $56, $1a, $fe, $31, $20
    db $0c, $03, $21, $00, $d8, $09, $7e, $fe
    db $32, $3e, $01, $28, $01, $af, $e0, $fb
    db $c3, $db, $51, $e8, $13, $c9, $66, $6c
    db $61, $75, $6e, $63, $68, $00, $72, $74
    db $63, $00, $6c, $61, $73, $74, $72, $6f
    db $6d, $00, $75, $69, $00, $f8, $02, $7e
    db $d6, $41, $38, $0a, $3e, $5a, $96, $38
    db $05, $7e, $c6, $20, $5f, $c9, $f8, $02
    db $5e, $c9, $f8, $04, $7e, $f8, $07, $96
    db $28, $03, $1e, $00, $c9, $16, $00, $7a
    db $f8, $04, $96, $30, $26, $2b, $2b, $2a
    db $82, $4f, $7e, $ce, $00, $47, $0a, $d5
    db $f5, $33, $cd, $0d, $55, $33, $f1, $57
    db $f8, $05, $2a, $82, $4f, $7e, $ce, $00
    db $47, $0a, $93, $28, $03, $1e, $00, $c9
    db $14, $18, $d4, $1e, $01, $c9, $3b, $3b
    db $f8, $01, $36, $00, $f8, $06, $7e, $b7
    db $28, $26, $2b, $2b, $2a, $4f, $46, $0a
    db $fe, $23, $20, $1c, $21, $80, $da, $36
    db $00, $1e, $01, $7b, $f8, $06, $96, $30
    db $0c, $6b, $26, $00, $09, $7e, $fe, $20
    db $20, $03, $1c, $18, $ee, $f8, $01, $73
    db $f8, $01, $7e, $f8, $06, $96, $30, $51
    db $0e, $00, $f8, $04, $7e, $f8, $01, $86
    db $23, $23, $23, $23, $5f, $7e, $ce, $00
    db $57, $1a, $fe, $2f, $28, $07, $0e, $01
    db $21, $82, $da, $36, $2f, $f8, $01, $46
    db $79, $c6, $82, $f5, $f8, $02, $f1, $22
    db $3e, $00, $ce, $da, $77, $78, $f8, $06
    db $96, $30, $16, $79, $d6, $78, $30, $11
    db $2b, $2b, $0c, $2a, $80, $5f, $7e, $ce
    db $00, $57, $1a, $e1, $e5, $77, $04, $18
    db $d7, $e1, $36, $00, $e5, $21, $81, $da
    db $71, $33, $33, $c9, $e8, $f2, $0e, $00
    db $59, $16, $00, $21, $02, $00, $39, $19
    db $36, $00, $0c, $79, $d6, $06, $38, $f0
    db $f8, $08, $af, $22, $22, $23, $af, $22
    db $22, $36, $00, $f8, $0d, $7e, $f8, $12
    db $96, $30, $12, $2b, $2b, $7e, $f8, $0d
    db $86, $23, $23, $23, $23, $4f, $7e, $ce
    db $00, $47, $0a, $18, $01, $af, $f8, $0a
    db $77, $d6, $30, $38, $11, $3e, $39, $96
    db $38, $0c, $2b, $3a, $22, $23, $3a, $c6
    db $d0, $22, $23, $34, $18, $30, $f8, $0b
    db $7e, $b7, $28, $1e, $23, $7e, $d6, $06
    db $30, $18, $5e, $16, $00, $21, $02, $00
    db $39, $19, $d1, $e5, $f8, $0c, $34, $f8
    db $08, $2a, $cb, $37, $e6, $f0, $b6, $e1
    db $e5, $77, $f8, $08, $af, $22, $22, $23
    db $af, $32, $7e, $b7, $28, $0b, $f8, $0d
    db $34, $f8, $12, $7e, $f8, $0d, $96, $30
    db $92, $f8, $0c, $7e, $d6, $06, $38, $35
    db $f8, $02, $7e, $ea, $46, $db, $f8, $03
    db $7e, $ea, $45, $db, $f8, $04, $7e, $21
    db $43, $db, $77, $2e, $44, $36, $03, $f8
    db $05, $7e, $ea, $42, $db, $f8, $06, $7e
    db $ea, $41, $db, $f8, $07, $7e, $ea, $40
    db $db, $11, $40, $db, $d5, $cd, $22, $4b
    db $e1, $7b, $ea, $47, $db, $e8, $0e, $c9
    db $f8, $02, $2a, $4f, $2a, $47, $7e, $cb
    db $37, $e6, $0f, $c6, $30, $02, $03, $7e
    db $e6, $0f, $c6, $30, $02, $1e, $02, $c9
    db $e8, $fc, $af, $f8, $02, $22, $77, $0e
    db $00, $f8, $02, $2a, $5f, $3a, $c6, $d8
    db $57, $34, $20, $02, $23, $34, $21, $83
    db $59, $06, $00, $09, $7e, $12, $0c, $79
    db $d6, $08, $38, $e5, $f8, $02, $2a, $4f
    db $46, $fa, $80, $da, $b7, $20, $0f, $2b
    db $2a, $4f, $3a, $47, $03, $2a, $5f, $7e
    db $c6, $d8, $57, $3e, $23, $12, $d1, $c5
    db $f8, $03, $36, $00, $fa, $81, $da, $f8
    db $02, $77, $d1, $d5, $13, $f8, $00, $2a
    db $4f, $2a, $23, $c6, $d8, $47, $3a, $96
    db $30, $12, $e1, $d5, $f8, $03, $7e, $c6
    db $82, $5f, $3e, $00, $ce, $da, $57, $1a
    db $02, $34, $18, $d8, $3e, $0d, $02, $4b
    db $42, $13, $f8, $02, $73, $23, $72, $21
    db $00, $d8, $09, $36, $0a, $fa, $47, $db
    db $b7, $ca, $5d, $58, $f8, $02, $2a, $4f
    db $46, $36, $00, $21, $00, $d8, $09, $e5
    db $7d, $f8, $03, $77, $e1, $7c, $f8, $02
    db $22, $03, $3e, $8b, $86, $2b, $2b, $5f
    db $3e, $59, $ce, $00, $57, $1a, $5e, $23
    db $66, $6b, $77, $f8, $03, $34, $7e, $d6
    db $06, $38, $d8, $21, $46, $db, $66, $59
    db $78, $c6, $d8, $c5, $e5, $33, $57, $d5
    db $cd, $b8, $56, $e8, $03, $c1, $6b, $26
    db $00, $09, $4d, $44, $59, $50, $03, $21
    db $00, $d8, $19, $36, $2d, $21, $45, $db
    db $66, $59, $78, $c6, $d8, $c5, $e5, $33
    db $57, $d5, $cd, $b8, $56, $e8, $03, $c1
    db $6b, $26, $00, $09, $4d, $44, $59, $50
    db $03, $21, $00, $d8, $19, $36, $2d, $21
    db $43, $db, $66, $59, $78, $c6, $d8, $c5
    db $e5, $33, $57, $d5, $cd, $b8, $56, $e8
    db $03, $c1, $6b, $26, $00, $09, $4d, $44
    db $59, $50, $03, $21, $00, $d8, $19, $36
    db $20, $21, $42, $db, $66, $59, $78, $c6
    db $d8, $c5, $e5, $33, $57, $d5, $cd, $b8
    db $56, $e8, $03, $c1, $6b, $26, $00, $09
    db $4d, $44, $59, $50, $03, $21, $00, $d8
    db $19, $36, $3a, $21, $41, $db, $66, $59
    db $78, $c6, $d8, $c5, $e5, $33, $57, $d5
    db $cd, $b8, $56, $e8, $03, $c1, $6b, $26
    db $00, $09, $4d, $44, $59, $50, $03, $21
    db $00, $d8, $19, $36, $3a, $21, $40, $db
    db $66, $59, $78, $c6, $d8, $c5, $e5, $33
    db $57, $d5, $cd, $b8, $56, $e8, $03, $c1
    db $6b, $26, $00, $09, $5d, $54, $4b, $42
    db $13, $21, $00, $d8, $09, $36, $0d, $4b
    db $42, $13, $f8, $02, $73, $23, $72, $21
    db $00, $d8, $09, $36, $0a, $fa, $7f, $da
    db $b7, $28, $67, $0e, $00, $f8, $02, $2a
    db $5f, $3a, $c6, $d8, $57, $34, $20, $02
    db $23, $34, $21, $91, $59, $06, $00, $09
    db $7e, $12, $0c, $79, $d6, $08, $38, $e5
    db $f8, $02, $2a, $4f, $46, $36, $00, $f8
    db $03, $5e, $16, $da, $1a, $f8, $00, $77
    db $69, $60, $23, $e5, $7d, $f8, $03, $77
    db $e1, $7c, $f8, $02, $77, $21, $00, $d8
    db $09, $5d, $54, $f8, $00, $7e, $b7, $28
    db $0d, $23, $2a, $4f, $3a, $2b, $47, $7e
    db $12, $f8, $03, $34, $18, $d1, $f8, $01
    db $2a, $4f, $46, $3e, $0d, $12, $59, $50
    db $03, $71, $23, $70, $21, $00, $d8, $19
    db $36, $0a, $0e, $00, $f8, $02, $2a, $5f
    db $3a, $c6, $d8, $57, $34, $20, $02, $23
    db $34, $21, $99, $59, $06, $00, $09, $7e
    db $12, $0c, $79, $d6, $03, $38, $e5, $f8
    db $02, $2a, $4f, $46, $f0, $fb, $b7, $28
    db $0f, $2b, $2a, $4f, $3a, $47, $03, $2a
    db $5f, $7e, $c6, $d8, $57, $3e, $31, $12
    db $79, $58, $03, $f5, $f8, $04, $f1, $22
    db $7b, $c6, $d8, $77, $f0, $fb, $b7, $3e
    db $32, $20, $02, $3e, $38, $f8, $02, $5e
    db $23, $66, $6b, $77, $59, $50, $03, $21
    db $00, $d8, $19, $36, $0d, $59, $50, $03
    db $21, $00, $d8, $19, $36, $0a, $78, $d6
    db $02, $30, $09, $21, $00, $d8, $09, $03
    db $36, $20, $18, $f2, $01, $79, $59, $c5
    db $cd, $6b, $50, $e1, $cd, $74, $4a, $3e
    db $0a, $f5, $33, $11, $00, $db, $d5, $11
    db $0f, $ca, $d5, $cd, $26, $19, $e8, $05
    db $7b, $b7, $20, $1a, $11, $00, $02, $d5
    db $11, $00, $d8, $d5, $cd, $06, $51, $e8
    db $04, $d5, $cd, $74, $4a, $01, $0f, $ca
    db $c5, $cd, $a1, $19, $e1, $d1, $e8, $04
    db $c9, $2f, $45, $5a, $47, $42, $2e, $43
    db $46, $47, $00, $46, $4c, $41, $55, $4e
    db $43, $48, $3d, $52, $54, $43, $3d, $32
    db $30, $4c, $41, $53, $54, $52, $4f, $4d
    db $3d, $55, $49, $3d, $e8, $fb, $f8, $0a
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
    db $3f, $51, $1e, $00, $3e, $78, $93, $3e
    db $00, $17, $47, $cb, $40, $20, $0d, $21
    db $a6, $c2, $16, $00, $19, $7e, $b7, $28
    db $03, $1c, $18, $e8, $7b, $4f, $b7, $28
    db $24, $cb, $40, $20, $20, $06, $00, $78
    db $91, $30, $11, $58, $16, $da, $78, $c6
    db $a6, $6f, $3e, $00, $ce, $c2, $67, $7e
    db $12, $04, $18, $eb, $06, $da, $af, $02
    db $21, $7f, $da, $36, $01, $21, $4c, $00
    db $e5, $cd, $02, $4c, $e1, $c3, $d0, $56
    db $11, $a4, $c4, $d5, $cd, $01, $5a, $e1
    db $7b, $b7, $28, $06, $21, $fb, $db, $36
    db $01, $c9, $cd, $3f, $51, $fa, $7f, $da
    db $b7, $28, $2f, $11, $00, $da, $d5, $cd
    db $01, $5a, $e1, $7b, $b7, $28, $23, $0e
    db $00, $69, $26, $00, $11, $a4, $c4, $19
    db $59, $16, $da, $1a, $77, $1a, $b7, $28
    db $03, $0c, $18, $ed, $3e, $03, $f5, $33
    db $cd, $44, $4a, $33, $21, $fb, $db, $36
    db $01, $c9, $3e, $0f, $f5, $33, $21, $14
    db $00, $e5, $11, $1b, $5b, $d5, $cd, $b7
    db $08, $e8, $05, $cd, $88, $06, $cd, $4a
    db $3a, $cb, $6b, $28, $f6, $21, $fb, $db
    db $36, $00, $c9, $28, $6e, $6f, $6e, $65
    db $29, $00

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    db $00, $00, $06, $00, $06, $00, $06, $00
    db $06, $00, $06, $00, $06, $00, $00, $00
    db $06, $00, $06, $00, $00, $00, $00, $00
    db $00, $00, $19, $80, $19, $80, $19, $80
    db $19, $80, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $04, $80, $05, $80, $1f, $c0
    db $09, $00, $0b, $00, $3f, $80, $1a, $00
    db $12, $00, $12, $00, $00, $00, $00, $00
    db $04, $00, $04, $00, $1f, $00, $35, $00
    db $34, $00, $1f, $00, $05, $80, $05, $80
    db $35, $80, $1f, $00, $04, $00, $04, $00
    db $00, $00, $18, $00, $24, $00, $24, $00
    db $18, $c0, $07, $00, $39, $80, $02, $40
    db $02, $40, $01, $80, $00, $00, $00, $00
    db $00, $00, $0e, $00, $18, $00, $18, $00
    db $0c, $00, $1c, $80, $36, $80, $33, $80
    db $33, $00, $1f, $80, $00, $00, $00, $00
    db $00, $00, $06, $00, $06, $00, $06, $00
    db $06, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $06, $00, $04, $00, $0c, $00, $0c, $00
    db $0c, $00, $0c, $00, $0c, $00, $0c, $00
    db $04, $00, $06, $00, $02, $00, $00, $00
    db $0c, $00, $04, $00, $06, $00, $06, $00
    db $06, $00, $06, $00, $06, $00, $06, $00
    db $04, $00, $0c, $00, $08, $00, $00, $00
    db $00, $00, $00, $00, $04, $00, $04, $00
    db $35, $80, $0e, $00, $0e, $00, $35, $80
    db $04, $00, $04, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $06, $00, $06, $00
    db $06, $00, $3f, $c0, $3f, $c0, $06, $00
    db $06, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $06, $00, $06, $00, $04, $00, $08, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $1f, $80, $1f, $80, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $06, $00, $06, $00, $00, $00, $00, $00
    db $00, $00, $00, $80, $01, $00, $01, $00
    db $02, $00, $02, $00, $06, $00, $04, $00
    db $04, $00, $08, $00, $08, $00, $10, $00
    db $0f, $00, $0f, $00, $19, $80, $19, $80
    db $1f, $80, $1d, $80, $19, $80, $19, $80
    db $0f, $00, $0f, $00, $00, $00, $00, $00
    db $00, $00, $1e, $00, $06, $00, $06, $00
    db $06, $00, $06, $00, $06, $00, $06, $00
    db $06, $00, $1f, $80, $00, $00, $00, $00
    db $00, $00, $1f, $00, $21, $80, $01, $80
    db $01, $00, $03, $00, $06, $00, $0c, $00
    db $18, $00, $3f, $80, $00, $00, $00, $00
    db $00, $00, $1f, $00, $21, $80, $01, $80
    db $0e, $00, $03, $80, $01, $80, $01, $80
    db $23, $80, $1f, $00, $00, $00, $00, $00
    db $00, $00, $07, $00, $07, $00, $0f, $00
    db $1b, $00, $33, $00, $3f, $80, $03, $00
    db $03, $00, $03, $00, $00, $00, $00, $00
    db $00, $00, $3f, $00, $30, $00, $30, $00
    db $3e, $00, $23, $80, $01, $80, $01, $80
    db $23, $80, $1e, $00, $00, $00, $00, $00
    db $00, $00, $0e, $00, $19, $00, $30, $00
    db $3f, $00, $31, $80, $31, $80, $31, $80
    db $11, $80, $0f, $00, $00, $00, $00, $00
    db $00, $00, $3f, $80, $01, $80, $03, $00
    db $03, $00, $06, $00, $06, $00, $0c, $00
    db $0c, $00, $18, $00, $00, $00, $00, $00
    db $00, $00, $1f, $00, $31, $80, $31, $80
    db $0e, $00, $31, $80, $31, $80, $31, $80
    db $31, $80, $1f, $00, $00, $00, $00, $00
    db $00, $00, $1e, $00, $31, $00, $31, $80
    db $31, $80, $31, $80, $1f, $80, $01, $80
    db $13, $00, $0e, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $06, $00
    db $06, $00, $00, $00, $00, $00, $00, $00
    db $06, $00, $06, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $06, $00
    db $06, $00, $00, $00, $00, $00, $00, $00
    db $06, $00, $06, $00, $04, $00, $08, $00
    db $00, $00, $00, $00, $00, $00, $00, $80
    db $07, $80, $1e, $00, $30, $00, $1e, $00
    db $07, $80, $00, $80, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $3f, $80, $3f, $80, $00, $00, $3f, $80
    db $3f, $80, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $20, $00
    db $3c, $00, $0f, $00, $01, $80, $0f, $00
    db $3c, $00, $20, $00, $00, $00, $00, $00
    db $00, $00, $0e, $00, $13, $00, $03, $00
    db $06, $00, $0c, $00, $0c, $00, $00, $00
    db $0c, $00, $0c, $00, $00, $00, $00, $00
    db $00, $00, $0f, $00, $18, $80, $17, $80
    db $2d, $80, $28, $80, $28, $80, $28, $80
    db $2d, $80, $17, $80, $18, $80, $0f, $80
    db $00, $00, $0e, $00, $0e, $00, $0a, $00
    db $1b, $00, $1b, $00, $1f, $00, $1b, $00
    db $31, $80, $31, $80, $00, $00, $00, $00
    db $00, $00, $3f, $00, $31, $80, $31, $80
    db $31, $80, $3e, $00, $31, $80, $31, $80
    db $31, $80, $3f, $00, $00, $00, $00, $00
    db $00, $00, $0f, $00, $18, $80, $30, $00
    db $30, $00, $30, $00, $30, $00, $30, $00
    db $18, $80, $0f, $00, $00, $00, $00, $00
    db $00, $00, $3e, $00, $33, $00, $31, $80
    db $31, $80, $31, $80, $31, $80, $31, $80
    db $33, $00, $3e, $00, $00, $00, $00, $00
    db $00, $00, $3f, $80, $30, $00, $30, $00
    db $30, $00, $3f, $00, $30, $00, $30, $00
    db $30, $00, $3f, $80, $00, $00, $00, $00
    db $00, $00, $3f, $80, $30, $00, $30, $00
    db $30, $00, $3f, $00, $30, $00, $30, $00
    db $30, $00, $30, $00, $00, $00, $00, $00
    db $00, $00, $0f, $00, $18, $80, $30, $00
    db $30, $00, $33, $80, $31, $80, $31, $80
    db $19, $80, $0f, $80, $00, $00, $00, $00
    db $00, $00, $31, $80, $31, $80, $31, $80
    db $31, $80, $3f, $80, $31, $80, $31, $80
    db $31, $80, $31, $80, $00, $00, $00, $00
    db $00, $00, $1f, $80, $06, $00, $06, $00
    db $06, $00, $06, $00, $06, $00, $06, $00
    db $06, $00, $1f, $80, $00, $00, $00, $00
    db $00, $00, $07, $80, $01, $80, $01, $80
    db $01, $80, $01, $80, $01, $80, $01, $80
    db $21, $80, $1f, $00, $00, $00, $00, $00
    db $00, $00, $31, $80, $33, $00, $36, $00
    db $3c, $00, $3e, $00, $36, $00, $33, $00
    db $33, $00, $31, $80, $00, $00, $00, $00
    db $00, $00, $30, $00, $30, $00, $30, $00
    db $30, $00, $30, $00, $30, $00, $30, $00
    db $30, $00, $3f, $80, $00, $00, $00, $00
    db $00, $00, $3b, $80, $3b, $80, $3b, $80
    db $3b, $80, $3f, $80, $35, $80, $31, $80
    db $31, $80, $31, $80, $00, $00, $00, $00
    db $00, $00, $39, $80, $39, $80, $39, $80
    db $3d, $80, $35, $80, $37, $80, $33, $80
    db $33, $80, $33, $80, $00, $00, $00, $00
    db $00, $00, $0e, $00, $1b, $00, $31, $80
    db $31, $80, $31, $80, $31, $80, $31, $80
    db $1b, $00, $0e, $00, $00, $00, $00, $00
    db $00, $00, $3f, $00, $31, $80, $31, $80
    db $31, $80, $31, $80, $3f, $00, $30, $00
    db $30, $00, $30, $00, $00, $00, $00, $00
    db $00, $00, $0e, $00, $1b, $00, $31, $80
    db $31, $80, $31, $80, $31, $80, $31, $80
    db $1b, $00, $0f, $00, $03, $00, $01, $00
    db $00, $00, $3f, $00, $31, $80, $31, $80
    db $31, $80, $31, $80, $3e, $00, $33, $00
    db $31, $80, $30, $c0, $00, $00, $00, $00
    db $00, $00, $1f, $00, $30, $80, $30, $00
    db $38, $00, $1f, $00, $03, $80, $01, $80
    db $21, $80, $1f, $00, $00, $00, $00, $00
    db $00, $00, $1f, $80, $06, $00, $06, $00
    db $06, $00, $06, $00, $06, $00, $06, $00
    db $06, $00, $06, $00, $00, $00, $00, $00
    db $00, $00, $31, $80, $31, $80, $31, $80
    db $31, $80, $31, $80, $31, $80, $31, $80
    db $31, $80, $1f, $00, $00, $00, $00, $00
    db $00, $00, $31, $80, $31, $80, $11, $00
    db $1b, $00, $1b, $00, $1b, $00, $0a, $00
    db $0e, $00, $0e, $00, $00, $00, $00, $00
    db $00, $00, $30, $c0, $30, $c0, $36, $c0
    db $36, $c0, $16, $80, $17, $80, $19, $80
    db $19, $80, $19, $80, $00, $00, $00, $00
    db $00, $00, $31, $80, $1b, $00, $1b, $00
    db $0e, $00, $04, $00, $0e, $00, $1b, $00
    db $1b, $00, $31, $80, $00, $00, $00, $00
    db $00, $00, $30, $c0, $19, $80, $19, $80
    db $0f, $00, $0f, $00, $06, $00, $06, $00
    db $06, $00, $06, $00, $00, $00, $00, $00
    db $00, $00, $3f, $80, $01, $80, $03, $00
    db $06, $00, $0e, $00, $0c, $00, $18, $00
    db $30, $00, $3f, $80, $00, $00, $00, $00
    db $0c, $00, $0c, $00, $0c, $00, $0c, $00
    db $0c, $00, $0c, $00, $0c, $00, $0c, $00
    db $0c, $00, $0c, $00, $0f, $00, $00, $00
    db $00, $00, $18, $00, $08, $00, $08, $00
    db $0c, $00, $04, $00, $06, $00, $02, $00
    db $03, $00, $01, $00, $01, $00, $01, $80
    db $0e, $00, $06, $00, $06, $00, $06, $00
    db $06, $00, $06, $00, $06, $00, $06, $00
    db $06, $00, $06, $00, $06, $00, $0e, $00
    db $00, $00, $0e, $00, $0e, $00, $1b, $00
    db $31, $80, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $3f, $c0
    db $0c, $00, $06, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $07, $00
    db $09, $80, $01, $80, $0f, $80, $19, $80
    db $19, $80, $0f, $80, $00, $00, $00, $00
    db $18, $00, $18, $00, $18, $00, $1f, $00
    db $19, $80, $19, $80, $19, $80, $19, $80
    db $19, $80, $1f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $07, $00
    db $0c, $80, $18, $00, $18, $00, $18, $00
    db $0c, $80, $07, $00, $00, $00, $00, $00
    db $01, $80, $01, $80, $01, $80, $0f, $80
    db $19, $80, $19, $80, $19, $80, $19, $80
    db $19, $80, $0f, $80, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $0f, $00
    db $19, $80, $19, $80, $1f, $80, $18, $00
    db $18, $80, $0f, $00, $00, $00, $00, $00
    db $06, $00, $06, $00, $06, $00, $1f, $80
    db $06, $00, $06, $00, $06, $00, $06, $00
    db $06, $00, $06, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $0f, $80
    db $19, $80, $19, $80, $19, $80, $19, $80
    db $19, $80, $0f, $80, $01, $80, $0f, $80
    db $18, $00, $18, $00, $18, $00, $1f, $00
    db $19, $80, $19, $80, $19, $80, $19, $80
    db $19, $80, $19, $80, $00, $00, $00, $00
    db $06, $00, $00, $00, $00, $00, $1e, $00
    db $06, $00, $06, $00, $06, $00, $06, $00
    db $06, $00, $1f, $80, $00, $00, $00, $00
    db $03, $00, $00, $00, $00, $00, $0f, $00
    db $03, $00, $03, $00, $03, $00, $03, $00
    db $03, $00, $03, $00, $03, $00, $1e, $00
    db $18, $00, $18, $00, $18, $00, $19, $00
    db $1b, $00, $1e, $00, $1e, $00, $1b, $00
    db $1b, $00, $19, $80, $00, $00, $00, $00
    db $0c, $00, $0c, $00, $0c, $00, $0c, $00
    db $0c, $00, $0c, $00, $0c, $00, $0c, $00
    db $0c, $00, $07, $80, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $3f, $c0
    db $36, $c0, $36, $c0, $36, $c0, $36, $c0
    db $36, $c0, $36, $c0, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $1f, $00
    db $19, $80, $19, $80, $19, $80, $19, $80
    db $19, $80, $19, $80, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $0f, $00
    db $19, $80, $19, $80, $19, $80, $19, $80
    db $19, $80, $0f, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $1f, $00
    db $19, $80, $19, $80, $19, $80, $19, $80
    db $19, $80, $1f, $00, $18, $00, $18, $00
    db $00, $00, $00, $00, $00, $00, $0f, $80
    db $19, $80, $19, $80, $19, $80, $19, $80
    db $19, $80, $0f, $80, $01, $80, $01, $80
    db $00, $00, $00, $00, $00, $00, $1f, $00
    db $18, $00, $18, $00, $18, $00, $18, $00
    db $18, $00, $18, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $0f, $00
    db $18, $80, $1c, $00, $0f, $00, $01, $80
    db $11, $80, $0f, $00, $00, $00, $00, $00
    db $00, $00, $06, $00, $06, $00, $1f, $80
    db $06, $00, $06, $00, $06, $00, $06, $00
    db $06, $00, $03, $80, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $19, $80
    db $19, $80, $19, $80, $19, $80, $19, $80
    db $19, $80, $0f, $80, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $19, $80
    db $19, $80, $19, $80, $09, $00, $0f, $00
    db $0f, $00, $06, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $30, $c0
    db $30, $c0, $36, $c0, $16, $80, $16, $80
    db $19, $80, $19, $80, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $19, $80
    db $0f, $00, $06, $00, $06, $00, $0f, $00
    db $0f, $00, $19, $80, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $19, $80
    db $19, $80, $0b, $00, $0f, $00, $0f, $00
    db $06, $00, $06, $00, $06, $00, $0c, $00
    db $00, $00, $00, $00, $00, $00, $1f, $80
    db $01, $80, $03, $00, $06, $00, $0c, $00
    db $18, $00, $1f, $80, $00, $00, $00, $00
    db $06, $00, $06, $00, $06, $00, $06, $00
    db $06, $00, $18, $00, $06, $00, $06, $00
    db $06, $00, $06, $00, $07, $80, $00, $00
    db $04, $00, $04, $00, $04, $00, $04, $00
    db $04, $00, $04, $00, $04, $00, $04, $00
    db $04, $00, $04, $00, $04, $00, $04, $00
    db $06, $00, $06, $00, $06, $00, $06, $00
    db $06, $00, $01, $80, $06, $00, $06, $00
    db $06, $00, $06, $00, $1e, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $18, $00
    db $34, $00, $26, $80, $03, $80, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $3f, $80, $20, $80, $20, $80
    db $20, $80, $20, $80, $20, $80, $20, $80
    db $20, $80, $20, $80, $20, $80, $3f, $80
    db $00, $00, $7c, $00, $82, $00, $ff, $e0
    db $80, $20, $80, $20, $80, $20, $80, $20
    db $80, $20, $80, $20, $ff, $e0, $00, $00
    db $ff, $e0, $80, $20, $9f, $20, $9f, $20
    db $9f, $20, $9f, $20, $80, $20, $80, $20
    db $80, $20, $80, $20, $ff, $e0, $00, $00
    db $7f, $c0, $80, $20, $9f, $20, $95, $20
    db $9b, $20, $9f, $20, $80, $20, $80, $20
    db $80, $20, $40, $40, $3f, $00, $00, $00
    db $7f, $c0, $40, $40, $4e, $40, $51, $40
    db $41, $40, $42, $40, $44, $40, $44, $40
    db $40, $40, $44, $40, $7f, $c0, $00, $00
    db $7f, $00, $41, $80, $41, $40, $41, $e0
    db $40, $20, $40, $20, $40, $20, $40, $20
    db $40, $20, $40, $20, $7f, $e0, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $60, $00, $60, $00, $60
    db $00, $60, $00, $60, $00, $60, $00, $00
    db $00, $60, $00, $60, $00, $00, $00, $00
    db $00, $00, $01, $98, $01, $98, $01, $98
    db $01, $98, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $48, $00, $58, $01, $fc
    db $00, $90, $00, $b0, $03, $f8, $01, $a0
    db $01, $20, $01, $20, $00, $00, $00, $00
    db $00, $40, $00, $40, $01, $f0, $03, $50
    db $03, $40, $01, $f0, $00, $58, $00, $58
    db $03, $58, $01, $f0, $00, $40, $00, $40
    db $00, $00, $01, $80, $02, $40, $02, $40
    db $01, $8c, $00, $70, $03, $98, $00, $24
    db $00, $24, $00, $18, $00, $00, $00, $00
    db $00, $00, $00, $e0, $01, $80, $01, $80
    db $00, $c0, $01, $c8, $03, $68, $03, $38
    db $03, $30, $01, $f8, $00, $00, $00, $00
    db $00, $00, $00, $60, $00, $60, $00, $60
    db $00, $60, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $60, $00, $40, $00, $c0, $00, $c0
    db $00, $c0, $00, $c0, $00, $c0, $00, $c0
    db $00, $40, $00, $60, $00, $20, $00, $00
    db $00, $c0, $00, $40, $00, $60, $00, $60
    db $00, $60, $00, $60, $00, $60, $00, $60
    db $00, $40, $00, $c0, $00, $80, $00, $00
    db $00, $00, $00, $00, $00, $40, $00, $40
    db $03, $58, $00, $e0, $00, $e0, $03, $58
    db $00, $40, $00, $40, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $60, $00, $60
    db $00, $60, $03, $fc, $03, $fc, $00, $60
    db $00, $60, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $60, $00, $60, $00, $40, $00, $80
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $01, $f8, $01, $f8, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $60, $00, $60, $00, $00, $00, $00
    db $00, $00, $00, $08, $00, $10, $00, $10
    db $00, $20, $00, $20, $00, $60, $00, $40
    db $00, $40, $00, $80, $00, $80, $01, $00
    db $00, $f0, $00, $f0, $01, $98, $01, $98
    db $01, $f8, $01, $d8, $01, $98, $01, $98
    db $00, $f0, $00, $f0, $00, $00, $00, $00
    db $00, $00, $01, $e0, $00, $60, $00, $60
    db $00, $60, $00, $60, $00, $60, $00, $60
    db $00, $60, $01, $f8, $00, $00, $00, $00
    db $00, $00, $01, $f0, $02, $18, $00, $18
    db $00, $10, $00, $30, $00, $60, $00, $c0
    db $01, $80, $03, $f8, $00, $00, $00, $00
    db $00, $00, $01, $f0, $02, $18, $00, $18
    db $00, $e0, $00, $38, $00, $18, $00, $18
    db $02, $38, $01, $f0, $00, $00, $00, $00
    db $00, $00, $00, $70, $00, $70, $00, $f0
    db $01, $b0, $03, $30, $03, $f8, $00, $30
    db $00, $30, $00, $30, $00, $00, $00, $00
    db $00, $00, $03, $f0, $03, $00, $03, $00
    db $03, $e0, $02, $38, $00, $18, $00, $18
    db $02, $38, $01, $e0, $00, $00, $00, $00
    db $00, $00, $00, $e0, $01, $90, $03, $00
    db $03, $f0, $03, $18, $03, $18, $03, $18
    db $01, $18, $00, $f0, $00, $00, $00, $00
    db $00, $00, $03, $f8, $00, $18, $00, $30
    db $00, $30, $00, $60, $00, $60, $00, $c0
    db $00, $c0, $01, $80, $00, $00, $00, $00
    db $00, $00, $01, $f0, $03, $18, $03, $18
    db $00, $e0, $03, $18, $03, $18, $03, $18
    db $03, $18, $01, $f0, $00, $00, $00, $00
    db $00, $00, $01, $e0, $03, $10, $03, $18
    db $03, $18, $03, $18, $01, $f8, $00, $18
    db $01, $30, $00, $e0, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $60
    db $00, $60, $00, $00, $00, $00, $00, $00
    db $00, $60, $00, $60, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $60
    db $00, $60, $00, $00, $00, $00, $00, $00
    db $00, $60, $00, $60, $00, $40, $00, $80
    db $00, $00, $00, $00, $00, $00, $00, $08
    db $00, $78, $01, $e0, $03, $00, $01, $e0
    db $00, $78, $00, $08, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $03, $f8, $03, $f8, $00, $00, $03, $f8
    db $03, $f8, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $02, $00
    db $03, $c0, $00, $f0, $00, $18, $00, $f0
    db $03, $c0, $02, $00, $00, $00, $00, $00
    db $00, $00, $00, $e0, $01, $30, $00, $30
    db $00, $60, $00, $c0, $00, $c0, $00, $00
    db $00, $c0, $00, $c0, $00, $00, $00, $00
    db $00, $00, $00, $f0, $01, $88, $01, $78
    db $02, $d8, $02, $88, $02, $88, $02, $88
    db $02, $d8, $01, $78, $01, $88, $00, $f8
    db $00, $00, $00, $e0, $00, $e0, $00, $a0
    db $01, $b0, $01, $b0, $01, $f0, $01, $b0
    db $03, $18, $03, $18, $00, $00, $00, $00
    db $00, $00, $03, $f0, $03, $18, $03, $18
    db $03, $18, $03, $e0, $03, $18, $03, $18
    db $03, $18, $03, $f0, $00, $00, $00, $00
    db $00, $00, $00, $f0, $01, $88, $03, $00
    db $03, $00, $03, $00, $03, $00, $03, $00
    db $01, $88, $00, $f0, $00, $00, $00, $00
    db $00, $00, $03, $e0, $03, $30, $03, $18
    db $03, $18, $03, $18, $03, $18, $03, $18
    db $03, $30, $03, $e0, $00, $00, $00, $00
    db $00, $00, $03, $f8, $03, $00, $03, $00
    db $03, $00, $03, $f0, $03, $00, $03, $00
    db $03, $00, $03, $f8, $00, $00, $00, $00
    db $00, $00, $03, $f8, $03, $00, $03, $00
    db $03, $00, $03, $f0, $03, $00, $03, $00
    db $03, $00, $03, $00, $00, $00, $00, $00
    db $00, $00, $00, $f0, $01, $88, $03, $00
    db $03, $00, $03, $38, $03, $18, $03, $18
    db $01, $98, $00, $f8, $00, $00, $00, $00
    db $00, $00, $03, $18, $03, $18, $03, $18
    db $03, $18, $03, $f8, $03, $18, $03, $18
    db $03, $18, $03, $18, $00, $00, $00, $00
    db $00, $00, $01, $f8, $00, $60, $00, $60
    db $00, $60, $00, $60, $00, $60, $00, $60
    db $00, $60, $01, $f8, $00, $00, $00, $00
    db $00, $00, $00, $78, $00, $18, $00, $18
    db $00, $18, $00, $18, $00, $18, $00, $18
    db $02, $18, $01, $f0, $00, $00, $00, $00
    db $00, $00, $03, $18, $03, $30, $03, $60
    db $03, $c0, $03, $e0, $03, $60, $03, $30
    db $03, $30, $03, $18, $00, $00, $00, $00
    db $00, $00, $03, $00, $03, $00, $03, $00
    db $03, $00, $03, $00, $03, $00, $03, $00
    db $03, $00, $03, $f8, $00, $00, $00, $00
    db $00, $00, $03, $b8, $03, $b8, $03, $b8
    db $03, $b8, $03, $f8, $03, $58, $03, $18
    db $03, $18, $03, $18, $00, $00, $00, $00
    db $00, $00, $03, $98, $03, $98, $03, $98
    db $03, $d8, $03, $58, $03, $78, $03, $38
    db $03, $38, $03, $38, $00, $00, $00, $00
    db $00, $00, $00, $e0, $01, $b0, $03, $18
    db $03, $18, $03, $18, $03, $18, $03, $18
    db $01, $b0, $00, $e0, $00, $00, $00, $00
    db $00, $00, $03, $f0, $03, $18, $03, $18
    db $03, $18, $03, $18, $03, $f0, $03, $00
    db $03, $00, $03, $00, $00, $00, $00, $00
    db $00, $00, $00, $e0, $01, $b0, $03, $18
    db $03, $18, $03, $18, $03, $18, $03, $18
    db $01, $b0, $00, $f0, $00, $30, $00, $10
    db $00, $00, $03, $f0, $03, $18, $03, $18
    db $03, $18, $03, $18, $03, $e0, $03, $30
    db $03, $18, $03, $0c, $00, $00, $00, $00
    db $00, $00, $01, $f0, $03, $08, $03, $00
    db $03, $80, $01, $f0, $00, $38, $00, $18
    db $02, $18, $01, $f0, $00, $00, $00, $00
    db $00, $00, $01, $f8, $00, $60, $00, $60
    db $00, $60, $00, $60, $00, $60, $00, $60
    db $00, $60, $00, $60, $00, $00, $00, $00
    db $00, $00, $03, $18, $03, $18, $03, $18
    db $03, $18, $03, $18, $03, $18, $03, $18
    db $03, $18, $01, $f0, $00, $00, $00, $00
    db $00, $00, $03, $18, $03, $18, $01, $10
    db $01, $b0, $01, $b0, $01, $b0, $00, $a0
    db $00, $e0, $00, $e0, $00, $00, $00, $00
    db $00, $00, $03, $0c, $03, $0c, $03, $6c
    db $03, $6c, $01, $68, $01, $78, $01, $98
    db $01, $98, $01, $98, $00, $00, $00, $00
    db $00, $00, $03, $18, $01, $b0, $01, $b0
    db $00, $e0, $00, $40, $00, $e0, $01, $b0
    db $01, $b0, $03, $18, $00, $00, $00, $00
    db $00, $00, $03, $0c, $01, $98, $01, $98
    db $00, $f0, $00, $f0, $00, $60, $00, $60
    db $00, $60, $00, $60, $00, $00, $00, $00
    db $00, $00, $03, $f8, $00, $18, $00, $30
    db $00, $60, $00, $e0, $00, $c0, $01, $80
    db $03, $00, $03, $f8, $00, $00, $00, $00
    db $00, $c0, $00, $c0, $00, $c0, $00, $c0
    db $00, $c0, $00, $c0, $00, $c0, $00, $c0
    db $00, $c0, $00, $c0, $00, $f0, $00, $00
    db $00, $00, $01, $80, $00, $80, $00, $80
    db $00, $c0, $00, $40, $00, $60, $00, $20
    db $00, $30, $00, $10, $00, $10, $00, $18
    db $00, $e0, $00, $60, $00, $60, $00, $60
    db $00, $60, $00, $60, $00, $60, $00, $60
    db $00, $60, $00, $60, $00, $60, $00, $e0
    db $00, $00, $00, $e0, $00, $e0, $01, $b0
    db $03, $18, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $03, $fc
    db $00, $c0, $00, $60, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $70
    db $00, $98, $00, $18, $00, $f8, $01, $98
    db $01, $98, $00, $f8, $00, $00, $00, $00
    db $01, $80, $01, $80, $01, $80, $01, $f0
    db $01, $98, $01, $98, $01, $98, $01, $98
    db $01, $98, $01, $f0, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $70
    db $00, $c8, $01, $80, $01, $80, $01, $80
    db $00, $c8, $00, $70, $00, $00, $00, $00
    db $00, $18, $00, $18, $00, $18, $00, $f8
    db $01, $98, $01, $98, $01, $98, $01, $98
    db $01, $98, $00, $f8, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $f0
    db $01, $98, $01, $98, $01, $f8, $01, $80
    db $01, $88, $00, $f0, $00, $00, $00, $00
    db $00, $60, $00, $60, $00, $60, $01, $f8
    db $00, $60, $00, $60, $00, $60, $00, $60
    db $00, $60, $00, $60, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $f8
    db $01, $98, $01, $98, $01, $98, $01, $98
    db $01, $98, $00, $f8, $00, $18, $00, $f8
    db $01, $80, $01, $80, $01, $80, $01, $f0
    db $01, $98, $01, $98, $01, $98, $01, $98
    db $01, $98, $01, $98, $00, $00, $00, $00
    db $00, $60, $00, $00, $00, $00, $01, $e0
    db $00, $60, $00, $60, $00, $60, $00, $60
    db $00, $60, $01, $f8, $00, $00, $00, $00
    db $00, $30, $00, $00, $00, $00, $00, $f0
    db $00, $30, $00, $30, $00, $30, $00, $30
    db $00, $30, $00, $30, $00, $30, $01, $e0
    db $01, $80, $01, $80, $01, $80, $01, $90
    db $01, $b0, $01, $e0, $01, $e0, $01, $b0
    db $01, $b0, $01, $98, $00, $00, $00, $00
    db $00, $c0, $00, $c0, $00, $c0, $00, $c0
    db $00, $c0, $00, $c0, $00, $c0, $00, $c0
    db $00, $c0, $00, $78, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $03, $fc
    db $03, $6c, $03, $6c, $03, $6c, $03, $6c
    db $03, $6c, $03, $6c, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $01, $f0
    db $01, $98, $01, $98, $01, $98, $01, $98
    db $01, $98, $01, $98, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $f0
    db $01, $98, $01, $98, $01, $98, $01, $98
    db $01, $98, $00, $f0, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $01, $f0
    db $01, $98, $01, $98, $01, $98, $01, $98
    db $01, $98, $01, $f0, $01, $80, $01, $80
    db $00, $00, $00, $00, $00, $00, $00, $f8
    db $01, $98, $01, $98, $01, $98, $01, $98
    db $01, $98, $00, $f8, $00, $18, $00, $18
    db $00, $00, $00, $00, $00, $00, $01, $f0
    db $01, $80, $01, $80, $01, $80, $01, $80
    db $01, $80, $01, $80, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $f0
    db $01, $88, $01, $c0, $00, $f0, $00, $18
    db $01, $18, $00, $f0, $00, $00, $00, $00
    db $00, $00, $00, $60, $00, $60, $01, $f8
    db $00, $60, $00, $60, $00, $60, $00, $60
    db $00, $60, $00, $38, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $01, $98
    db $01, $98, $01, $98, $01, $98, $01, $98
    db $01, $98, $00, $f8, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $01, $98
    db $01, $98, $01, $98, $00, $90, $00, $f0
    db $00, $f0, $00, $60, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $03, $0c
    db $03, $0c, $03, $6c, $01, $68, $01, $68
    db $01, $98, $01, $98, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $01, $98
    db $00, $f0, $00, $60, $00, $60, $00, $f0
    db $00, $f0, $01, $98, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $01, $98
    db $01, $98, $00, $b0, $00, $f0, $00, $f0
    db $00, $60, $00, $60, $00, $60, $00, $c0
    db $00, $00, $00, $00, $00, $00, $01, $f8
    db $00, $18, $00, $30, $00, $60, $00, $c0
    db $01, $80, $01, $f8, $00, $00, $00, $00
    db $00, $60, $00, $60, $00, $60, $00, $60
    db $00, $60, $01, $80, $00, $60, $00, $60
    db $00, $60, $00, $60, $00, $78, $00, $00
    db $00, $40, $00, $40, $00, $40, $00, $40
    db $00, $40, $00, $40, $00, $40, $00, $40
    db $00, $40, $00, $40, $00, $40, $00, $40
    db $00, $60, $00, $60, $00, $60, $00, $60
    db $00, $60, $00, $18, $00, $60, $00, $60
    db $00, $60, $00, $60, $01, $e0, $00, $00
    db $00, $00, $00, $00, $00, $00, $01, $80
    db $03, $40, $02, $68, $00, $38, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $03, $f8, $02, $08, $02, $08
    db $02, $08, $02, $08, $02, $08, $02, $08
    db $02, $08, $02, $08, $02, $08, $03, $f8
    db $00, $00, $07, $c0, $08, $20, $0f, $fe
    db $08, $02, $08, $02, $08, $02, $08, $02
    db $08, $02, $08, $02, $0f, $fe, $00, $00
    db $0f, $fe, $08, $02, $09, $f2, $09, $f2
    db $09, $f2, $09, $f2, $08, $02, $08, $02
    db $08, $02, $08, $02, $0f, $fe, $00, $00
    db $07, $fc, $08, $02, $09, $f2, $09, $52
    db $09, $b2, $09, $f2, $08, $02, $08, $02
    db $08, $02, $04, $04, $03, $f0, $00, $00
    db $07, $fc, $04, $04, $04, $e4, $05, $14
    db $04, $14, $04, $24, $04, $44, $04, $44
    db $04, $04, $04, $44, $07, $fc, $00, $00
    db $07, $f0, $04, $18, $04, $14, $04, $1e
    db $04, $02, $04, $02, $04, $02, $04, $02
    db $04, $02, $04, $02, $07, $fe, $00, $00

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    db $e8, $ef, $f8, $1b, $7e, $b7, $20, $0b
    db $f8, $01, $36, $c0, $f8, $1b, $36, $13
    db $c3, $c0, $73, $01, $ff, $00, $78, $d6
    db $fe, $30, $15, $f8, $19, $2a, $80, $5f
    db $7e, $ce, $00, $57, $1a, $b7, $28, $08
    db $fe, $2e, $20, $01, $48, $04, $18, $e6
    db $f8, $01, $36, $c3, $79, $3c, $ca, $bc
    db $73, $2b, $78, $91, $3d, $77, $06, $00
    db $59, $50, $13, $f8, $19, $2a, $83, $5f
    db $7e, $8a, $57, $1a, $e6, $df, $f8, $10
    db $77, $59, $50, $13, $13, $f8, $19, $2a
    db $83, $5f, $7e, $8a, $57, $1a, $e6, $df
    db $5f, $f8, $00, $7e, $d6, $03, $3e, $01
    db $28, $01, $af, $57, $03, $03, $03, $f8
    db $19, $2a, $81, $4f, $7e, $88, $47, $f8
    db $10, $7e, $d6, $47, $20, $23, $7b, $d6
    db $42, $20, $1e, $f8, $00, $7e, $d6, $02
    db $20, $06, $f8, $01, $36, $c1, $18, $2c
    db $7a, $b7, $28, $28, $0a, $cb, $af, $fe
    db $43, $20, $21, $f8, $01, $36, $c2, $18
    db $1b, $7a, $b7, $28, $17, $f8, $10, $7e
    db $d6, $53, $20, $10, $7b, $d6, $41, $20
    db $0b, $0a, $cb, $af, $fe, $56, $20, $04
    db $f8, $01, $36, $c4, $f8, $1b, $35, $7e
    db $fa, $fb, $ff, $b7, $20, $2a, $f8, $01
    db $4d, $44, $f8, $1d, $7e, $f5, $33, $21
    db $01, $00, $e5, $c5, $cd, $b7, $08, $e8
    db $05, $f8, $1d, $3a, $2b, $57, $1e, $01
    db $d5, $3a, $2b, $f5, $33, $2a, $5f, $56
    db $d5, $cd, $b7, $08, $e8, $05, $18, $52
    db $f8, $01, $2a, $77, $f8, $10, $36, $00
    db $f8, $10, $5e, $1c, $16, $00, $21, $02
    db $00, $39, $19, $4d, $44, $f8, $19, $7e
    db $f8, $10, $86, $5f, $f5, $f8, $1c, $f1
    db $7e, $ce, $00, $57, $1a, $02, $1a, $b7
    db $28, $08, $f8, $10, $34, $7e, $d6, $0c
    db $38, $d6, $f8, $0f, $36, $00, $f8, $1d
    db $7e, $f5, $33, $21, $0d, $00, $e5, $21
    db $05, $00, $39, $e5, $af, $0f, $f5, $af
    db $0f, $f5, $af, $0f, $f5, $cd, $00, $75
    db $e8, $0b, $e8, $11, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    db $e8, $e5, $f8, $26, $7e, $d6, $0d, $d2
    db $59, $78, $f8, $27, $7e, $d6, $02, $38
    db $0c, $7e, $c6, $fe, $4f, $87, $81, $87
    db $87, $c6, $10, $18, $06, $f8, $27, $7e
    db $87, $87, $87, $f8, $0f, $77, $7e, $d6
    db $90, $d2, $59, $78, $f8, $26, $3e, $0d
    db $96, $2b, $4f, $7e, $b7, $28, $04, $79
    db $96, $30, $03, $f8, $25, $71, $f8, $26
    db $7e, $f8, $10, $77, $7e, $4f, $87, $81
    db $87, $87, $f8, $1a, $77, $f8, $02, $36
    db $00, $fa, $34, $d7, $47, $fa, $35, $d7
    db $4f, $fa, $d0, $d6, $b7, $20, $0a, $78
    db $b1, $fe, $03, $20, $04, $78, $a1, $28
    db $70, $f8, $19, $36, $00, $f8, $19, $7e
    db $f8, $25, $96, $30, $43, $21, $02, $00
    db $39, $e5, $f8, $1b, $7e, $f5, $33, $f8
    db $26, $2a, $5f, $56, $d5, $cd, $5c, $78
    db $e8, $05, $4b, $06, $00, $69, $60, $29
    db $09, $29, $29, $29, $11, $00, $60, $19
    db $4d, $44, $11, $f0, $ff, $d5, $f8, $11
    db $7e, $f5, $33, $f8, $1d, $7e, $f5, $33
    db $c5, $cd, $9c, $79, $e8, $06, $f8, $19
    db $34, $23, $7e, $c6, $0c, $77, $18, $b5
    db $f8, $10, $7e, $f8, $25, $86, $fe, $0d
    db $c2, $59, $78, $11, $00, $f0, $d5, $f8
    db $11, $66, $2e, $9c, $e5, $11, $00, $60
    db $d5, $cd, $9c, $79, $e8, $06, $c3, $59
    db $78, $f8, $11, $3e, $0c, $32, $2b, $3e
    db $90, $96, $47, $d6, $0c, $30, $0b, $23
    db $23, $78, $e6, $fc, $77, $7e, $b7, $ca
    db $59, $78, $79, $b7, $3e, $ff, $20, $01
    db $af, $f8, $12, $77, $f8, $19, $36, $00
    db $f8, $10, $7e, $0f, $30, $5d, $21, $02
    db $00, $39, $e5, $af, $f5, $33, $f8, $26
    db $2a, $5f, $56, $d5, $cd, $5c, $78, $e8
    db $05, $f8, $19, $73, $4e, $06, $00, $69
    db $60, $29, $09, $29, $29, $29, $e5, $7d
    db $f8, $1a, $77, $e1, $7c, $f8, $19, $32
    db $3a, $2b, $77, $f8, $19, $3a, $2b, $32
    db $2a, $23, $c6, $00, $32, $2a, $23, $ce
    db $60, $77, $11, $f0, $ff, $d5, $f8, $11
    db $7e, $f5, $33, $f8, $1d, $3a, $2b, $f5
    db $33, $2a, $5f, $56, $d5, $cd, $9c, $79
    db $e8, $06, $f8, $19, $3e, $01, $22, $7e
    db $c6, $0c, $77, $f8, $25, $7e, $f8, $19
    db $96, $4f, $f8, $0f, $5e, $16, $00, $f8
    db $1a, $6e, $cb, $3d, $cb, $3d, $cb, $3d
    db $7b, $42, $87, $cb, $10, $5d, $16, $00
    db $c6, $bb, $f5, $f8, $15, $f1, $22, $78
    db $ce, $2f, $22, $cb, $23, $cb, $12, $cb
    db $23, $cb, $12, $cb, $23, $cb, $12, $cb
    db $23, $cb, $12, $7b, $22, $72, $79, $d6
    db $02, $da, $72, $77, $21, $02, $00, $39
    db $e5, $f8, $1b, $7e, $f5, $33, $f8, $26
    db $2a, $5f, $56, $d5, $cd, $5c, $78, $e8
    db $05, $4b, $06, $00, $69, $60, $29, $09
    db $29, $29, $29, $11, $00, $60, $19, $4d
    db $44, $f8, $19, $56, $14, $c5, $21, $04
    db $00, $39, $e5, $d5, $33, $f8, $28, $2a
    db $5f, $56, $d5, $cd, $5c, $78, $e8, $05
    db $7b, $c1, $5f, $16, $00, $6b, $62, $29
    db $19, $29, $29, $29, $7d, $c6, $78, $5f
    db $7c, $ce, $69, $f8, $00, $73, $23, $77
    db $f8, $13, $2a, $5f, $56, $1a, $f8, $17
    db $22, $13, $1a, $32, $3a, $2b, $86, $23
    db $23, $23, $5f, $3a, $2b, $8e, $57, $c5
    db $d5, $21, $07, $00, $39, $e5, $f8, $06
    db $2a, $66, $6f, $e5, $c5, $cd, $71, $79
    db $e8, $06, $d1, $c1, $d5, $f8, $14, $3a
    db $f5, $33, $7e, $f5, $33, $d5, $c5, $cd
    db $0b, $79, $e8, $06, $d1, $21, $10, $00
    db $19, $4d, $44, $d5, $f8, $14, $3a, $57
    db $5e, $d5, $c5, $21, $09, $00, $39, $e5
    db $cd, $a9, $78, $e8, $06, $d1, $21, $20
    db $00, $19, $4d, $44, $d1, $d5, $13, $f8
    db $12, $3a, $f5, $33, $7e, $f5, $33, $c5
    db $d5, $cd, $0b, $79, $e8, $06, $f8, $19
    db $34, $34, $23, $7e, $c6, $18, $77, $c3
    db $63, $76, $f8, $19, $7e, $f8, $25, $96
    db $d2, $59, $78, $f8, $02, $e5, $f8, $1b
    db $7e, $f5, $33, $f8, $26, $2a, $5f, $56
    db $d5, $cd, $5c, $78, $e8, $05, $4b, $06
    db $00, $69, $60, $29, $09, $29, $29, $29
    db $e5, $7d, $f8, $19, $77, $e1, $7c, $f8
    db $18, $32, $7e, $f8, $00, $77, $f8, $18
    db $7e, $f8, $01, $32, $7e, $c6, $00, $f5
    db $f8, $19, $f1, $77, $f5, $f8, $03, $f1
    db $7e, $ce, $60, $f8, $18, $22, $7e, $f8
    db $10, $86, $f8, $19, $77, $7e, $d6, $0c
    db $20, $76, $f8, $13, $2a, $5f, $56, $1a
    db $f8, $19, $22, $13, $1a, $32, $7e, $f8
    db $15, $86, $2b, $2b, $77, $f5, $f8, $1c
    db $f1, $3a, $2b, $2b, $2b, $8e, $2b, $2b
    db $77, $21, $03, $00, $39, $e5, $11, $78
    db $69, $d5, $f8, $1b, $2a, $5f, $56, $d5
    db $cd, $71, $79, $e8, $06, $f8, $12, $3a
    db $57, $2a, $23, $5f, $d5, $2a, $5f, $56
    db $d5, $f8, $1b, $2a, $5f, $56, $d5, $cd
    db $0b, $79, $e8, $06, $f8, $13, $7e, $c6
    db $10, $f5, $f8, $1b, $f1, $77, $f5, $f8
    db $16, $f1, $7e, $ce, $00, $f8, $1a, $77
    db $f8, $12, $3a, $57, $5e, $d5, $f8, $1b
    db $2a, $5f, $56, $d5, $21, $07, $00, $39
    db $e5, $cd, $a9, $78, $e8, $06, $18, $19
    db $11, $f0, $ff, $d5, $f8, $11, $7e, $f5
    db $33, $f8, $1d, $7e, $f5, $33, $f8, $1b
    db $2a, $5f, $56, $d5, $cd, $9c, $79, $e8
    db $06, $e8, $1b, $c9, $06, $20, $f8, $05
    db $2a, $5f, $56, $1a, $b7, $20, $15, $f8
    db $02, $2a, $23, $86, $2b, $4f, $7e, $ce
    db $00, $47, $0a, $47, $b7, $20, $05, $3e
    db $01, $12, $06, $20, $c5, $33, $cd, $83
    db $78, $33, $c9, $f8, $02, $7e, $4f, $d6
    db $20, $38, $0a, $7e, $d6, $80, $30, $05
    db $79, $c6, $e0, $5f, $c9, $f8, $02, $7e
    db $d6, $c0, $38, $0a, $3e, $c4, $96, $38
    db $05, $79, $c6, $a0, $5f, $c9, $1e, $1f
    db $c9, $f8, $07, $4e, $f8, $06, $7e, $cb
    db $3f, $cb, $3f, $47, $f8, $04, $2a, $5f
    db $56, $f8, $02, $2a, $66, $6f, $f3, $f0
    db $41, $e6, $03, $fe, $01, $20, $0c, $f0
    db $44, $fe, $90, $38, $06, $fe, $98, $30
    db $02, $18, $0e, $f0, $41, $e6, $03, $fe
    db $03, $20, $f8, $f0, $41, $e6, $03, $20
    db $fa, $2a, $a9, $12, $1c, $12, $13, $2a
    db $a9, $12, $1c, $12, $13, $2a, $a9, $12
    db $1c, $12, $13, $2a, $a9, $12, $1c, $12
    db $13, $fb, $7b, $e6, $0f, $20, $08, $7b
    db $c6, $30, $5f, $7a, $ce, $01, $57, $05
    db $20, $b4, $c9, $f8, $07, $4e, $f8, $06
    db $7e, $cb, $3f, $cb, $3f, $47, $f8, $04
    db $2a, $5f, $56, $f8, $02, $2a, $66, $6f
    db $f3, $f0, $41, $e6, $03, $fe, $01, $20
    db $0c, $f0, $44, $fe, $90, $38, $06, $fe
    db $98, $30, $02, $18, $0e, $f0, $41, $e6
    db $03, $fe, $03, $20, $f8, $f0, $41, $e6
    db $03, $20, $fa, $2a, $23, $a9, $12, $1c
    db $12, $13, $2a, $23, $a9, $12, $1c, $12
    db $13, $2a, $23, $a9, $12, $1c, $12, $13
    db $2a, $23, $a9, $12, $1c, $12, $13, $fb
    db $7b, $e6, $0f, $20, $08, $7b, $c6, $30
    db $5f, $7a, $ce, $01, $57, $05, $20, $b0
    db $c9, $e8, $ff, $f8, $00, $36, $0c, $f8
    db $03, $2a, $5f, $56, $13, $f8, $05, $2a
    db $4f, $46, $f8, $07, $2a, $66, $6f, $1a
    db $e6, $f0, $77, $0a, $b6, $22, $13, $13
    db $03, $03, $e5, $f8, $02, $35, $e1, $20
    db $ee, $e8, $01, $c9, $e8, $e1, $f8, $24
    db $7e, $d6, $90, $d2, $30, $7b, $f8, $1a
    db $36, $0c, $f8, $24, $3e, $90, $96, $fe
    db $0c, $30, $03, $f8, $1a, $77, $fa, $34
    db $d7, $4f, $fa, $35, $d7, $5f, $fa, $d0
    db $d6, $b7, $c2, $b1, $7a, $f8, $25, $7e
    db $d6, $f0, $c2, $b1, $7a, $23, $7e, $3c
    db $c2, $b1, $7a, $79, $b3, $fe, $03, $c2
    db $b1, $7a, $79, $a3, $c2, $b1, $7a, $7b
    db $b7, $28, $38, $f8, $1e, $36, $00, $f8
    db $1e, $5e, $16, $00, $21, $02, $00, $39
    db $19, $4d, $44, $f8, $21, $7e, $f8, $1e
    db $86, $23, $23, $23, $23, $5f, $7e, $ce
    db $00, $57, $1a, $2f, $02, $f8, $1e, $34
    db $7e, $d6, $18, $38, $da, $21, $02, $00
    db $39, $e5, $7d, $f8, $23, $77, $e1, $7c
    db $f8, $22, $77, $f8, $23, $2a, $4f, $5e
    db $16, $00, $79, $cb, $37, $07, $e6, $1f
    db $cb, $23, $cb, $12, $e1, $d5, $5f, $16
    db $00, $cb, $23, $cb, $12, $cb, $23, $cb
    db $12, $cb, $23, $cb, $12, $cb, $23, $cb
    db $12, $f8, $1b, $7b, $22, $72, $79, $e6
    db $07, $28, $2a, $3e, $bb, $f8, $00, $86
    db $23, $4f, $3e, $2f, $8e, $69, $67, $2a
    db $4e, $f8, $1b, $86, $23, $5f, $79, $8e
    db $2b, $2b, $66, $e5, $33, $57, $d5, $f8
    db $24, $2a, $5f, $56, $d5, $cd, $89, $7b
    db $e8, $05, $c3, $30, $7b, $3e, $bb, $f8
    db $00, $86, $f5, $f8, $1f, $f1, $77, $3e
    db $2f, $f5, $f8, $03, $f1, $8e, $f8, $1e
    db $32, $2a, $5f, $3a, $57, $1a, $22, $13
    db $1a, $32, $3a, $2b, $86, $23, $23, $23
    db $4f, $3a, $2b, $8e, $2b, $2b, $66, $e5
    db $33, $47, $c5, $f8, $24, $2a, $5f, $56
    db $d5, $cd, $33, $7b, $e8, $05, $c3, $30
    db $7b, $79, $ab, $4f, $cb, $41, $3e, $ff
    db $20, $01, $af, $f8, $1b, $77, $cb, $43
    db $3e, $ff, $20, $01, $af, $f8, $1c, $77
    db $cb, $49, $3e, $ff, $20, $01, $af, $f8
    db $1d, $77, $cb, $4b, $3e, $ff, $20, $01
    db $af, $f8, $1e, $77, $f8, $23, $4e, $79
    db $e6, $07, $5f, $3c, $18, $07, $f8, $26
    db $cb, $3e, $2b, $cb, $1e, $3d, $20, $f6
    db $f8, $25, $2a, $56, $cb, $39, $cb, $39
    db $cb, $39, $69, $26, $00, $29, $29, $29
    db $29, $4d, $44, $f8, $1a, $66, $e5, $33
    db $f8, $25, $66, $e5, $33, $f8, $20, $66
    db $e5, $33, $f8, $20, $66, $e5, $33, $f8
    db $20, $66, $e5, $33, $f8, $20, $66, $e5
    db $33, $f5, $33, $d5, $c5, $f8, $2c, $2a
    db $5f, $56, $d5, $cd, $f1, $7b, $e8, $0d
    db $e8, $1f, $c9, $f8, $06, $46, $f8, $04
    db $2a, $5f, $56, $f8, $02, $2a, $66, $6f
    db $f3, $f0, $41, $cb, $4f, $20, $fa, $2a
    db $12, $1c, $12, $1d, $fb, $2a, $e6, $f0
    db $4f, $e5, $7b, $c6, $10, $6f, $7a, $ce
    db $00, $67, $f3, $f0, $41, $cb, $4f, $20
    db $fa, $7e, $e6, $0f, $b1, $22, $fb, $f3
    db $f0, $41, $cb, $4f, $20, $fa, $7e, $e6
    db $0f, $b1, $77, $fb, $e1, $13, $13, $7b
    db $e6, $0f, $20, $08, $7b, $c6, $30, $5f
    db $7a, $ce, $01, $57, $05, $c2, $40, $7b
    db $c9, $f8, $06, $46, $f8, $04, $2a, $5f
    db $56, $f8, $02, $2a, $66, $6f, $e5, $2a
    db $6e, $cb, $37, $67, $cb, $35, $7c, $e6
    db $f0, $4f, $7d, $e6, $0f, $b1, $4f, $7c
    db $e6, $0f, $6f, $f3, $f0, $41, $cb, $4f
    db $20, $fa, $1a, $e6, $f0, $b5, $12, $fb
    db $1c, $f3, $f0, $41, $cb, $4f, $20, $fa
    db $1a, $e6, $f0, $b5, $12, $fb, $7b, $c6
    db $0f, $6f, $7a, $ce, $00, $67, $1d, $f3
    db $f0, $41, $cb, $4f, $20, $fa, $79, $22
    db $77, $fb, $e1, $23, $23, $13, $13, $7b
    db $e6, $0f, $20, $08, $7b, $c6, $30, $5f
    db $7a, $ce, $01, $57, $05, $c2, $96, $7b
    db $c9, $e8, $fc, $f8, $06, $2a, $5f, $56
    db $1a, $47, $13, $1a, $4f, $13, $72, $2b
    db $73, $f8, $0a, $7e, $b7, $28, $10, $cb
    db $38, $cb, $19, $cb, $38, $cb, $19, $cb
    db $38, $cb, $19, $cb, $38, $cb, $19, $f8
    db $0d, $2a, $57, $5e, $78, $a2, $ab, $f8
    db $0b, $a6, $f8, $00, $22, $79, $a2, $ab
    db $f8, $0c, $a6, $f8, $01, $77, $f8, $0f
    db $2a, $57, $5e, $78, $a2, $ab, $f8, $0b
    db $a6, $f8, $02, $22, $79, $a2, $ab, $f8
    db $0c, $a6, $f8, $03, $77, $f8, $11, $6e
    db $26, $00, $29, $11, $bb, $2f, $19, $2a
    db $66, $6f, $e5, $f8, $0a, $2a, $5f, $56
    db $e1, $19, $54, $5d, $f8, $0b, $7e, $b7
    db $28, $1d, $2f, $4f, $f8, $00, $46, $23
    db $23, $cd, $fd, $06, $f0, $41, $cb, $4f
    db $20, $fa, $1a, $a1, $b0, $12, $13, $1a
    db $a1, $b6, $12, $cd, $06, $07, $1b, $f8
    db $0c, $7e, $b7, $28, $22, $2f, $4f, $21
    db $10, $00, $19, $54, $5d, $f8, $01, $46
    db $23, $23, $cd, $fd, $06, $f0, $41, $cb
    db $4f, $20, $fa, $1a, $a1, $b0, $12, $13
    db $1a, $a1, $b6, $12, $cd, $06, $07, $f8
    db $11, $34, $f8, $12, $35, $c2, $f3, $7b
    db $e8, $04, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
