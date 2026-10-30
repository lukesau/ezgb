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

FarCallPatchGuard::
    db $cd, $8d, $07, $70, $7d, $01, $00, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Theme::
    db $e8, $fc, $21, $00, $40, $36, $11, $3e
    db $03, $f5, $33, $cd, $8f, $44, $33, $fa
    db $f9, $db, $b7, $20, $27, $21, $16, $a4
    db $4e, $fa, $14, $a4, $fe, $54, $20, $18
    db $fa, $15, $a4, $fe, $48, $20, $11, $79
    db $d6, $07, $30, $0c, $21, $17, $a4, $46
    db $79, $2f, $90, $20, $03, $79, $18, $01
    db $af, $ea, $f7, $db, $cd, $98, $49, $4b
    db $42, $fa, $f7, $db, $f8, $00, $77, $fa
    db $f9, $db, $b7, $28, $3e, $21, $14, $a4
    db $36, $54, $2e, $15, $36, $48, $11, $16
    db $a4, $f8, $00, $7e, $12, $7e, $2f, $ea
    db $17, $a4, $f8, $03, $36, $00, $f8, $03
    db $3a, $2b, $c6, $04, $c6, $14, $22, $3e
    db $00, $ce, $a4, $22, $79, $86, $2b, $2b
    db $5f, $78, $ce, $00, $57, $1a, $5e, $23
    db $66, $6b, $77, $f8, $03, $34, $7e, $d6
    db $08, $38, $db, $21, $00, $40, $36, $00
    db $c5, $af, $f5, $33, $cd, $8f, $44, $33
    db $c1, $f8, $00, $7e, $b7, $3e, $1b, $20
    db $02, $3e, $e4, $e0, $47, $e0, $48, $2f
    db $e0, $49, $c5, $c5, $11, $68, $ff, $d5
    db $cd, $a9, $44, $e8, $04, $11, $6a, $ff
    db $d5, $cd, $a9, $44, $e8, $08, $c9, $21
    db $00, $7f, $36, $e1, $2e, $10, $36, $e2
    db $2e, $20, $36, $e3, $11, $c0, $7f, $f8
    db $02, $7e, $12, $21, $f0, $7f, $36, $e4
    db $c9, $e8, $fd, $f8, $01, $36, $00, $f8
    db $01, $7e, $e6, $07, $f8, $07, $86, $23
    db $4f, $3e, $00, $8e, $47, $0a, $f8, $00
    db $22, $23, $36, $08, $f8, $02, $4e, $35
    db $7e, $79, $b7, $28, $28, $f8, $05, $2a
    db $4f, $46, $f8, $01, $7e, $02, $f0, $41
    db $cb, $4f, $20, $fa, $03, $f8, $00, $7e
    db $02, $f0, $41, $cb, $4f, $20, $fa, $0a
    db $f8, $00, $96, $20, $d7, $f8, $01, $34
    db $7e, $d6, $40, $38, $ba, $e8, $03, $c9

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
    db $ac, $43, $33, $c9, $e8, $fb, $f8, $02
    db $3e, $a4, $22, $36, $c4, $21, $a4, $c4
    db $36, $00, $cd, $4a, $3a, $4b, $f0, $f7
    db $b1, $07, $da, $eb, $45, $cd, $37, $46
    db $7b, $b7, $c2, $eb, $45, $21, $96, $d7
    db $36, $a0, $2e, $97, $36, $d7, $2e, $98
    db $36, $fe, $2e, $99, $36, $00, $f8, $00
    db $3e, $2f, $22, $36, $00, $f8, $04, $36
    db $00, $af, $f5, $33, $cd, $ac, $43, $33
    db $21, $00, $00, $39, $e5, $11, $00, $d9
    db $d5, $cd, $80, $43, $e8, $04, $7b, $b7
    db $c2, $eb, $45, $cd, $f0, $46, $11, $80
    db $d7, $d5, $11, $00, $d9, $d5, $cd, $96
    db $43, $e8, $04, $7b, $b7, $28, $09, $f8
    db $02, $2a, $66, $6f, $36, $00, $18, $6b
    db $cd, $e5, $46, $7b, $b7, $20, $64, $fa
    db $88, $d7, $cb, $67, $20, $d5, $cd, $d7
    db $46, $1a, $fe, $2e, $28, $cd, $d5, $d5
    db $cd, $01, $47, $e1, $7b, $d1, $b7, $20
    db $c2, $01, $ee, $45, $d5, $c5, $d5, $cd
    db $9f, $46, $e8, $04, $7b, $d1, $b7, $20
    db $b2, $01, $f7, $45, $d5, $c5, $d5, $cd
    db $9f, $46, $e8, $04, $7b, $d1, $b7, $20
    db $a2, $f8, $04, $7e, $b7, $28, $08, $2b
    db $3a, $6e, $67, $36, $00, $18, $1c, $f8
    db $04, $36, $01, $d5, $d5, $cd, $3a, $47
    db $e1, $7b, $d1, $b7, $28, $85, $d5, $11
    db $a4, $c4, $d5, $cd, $03, $46, $e8, $04
    db $c3, $63, $45, $e8, $05, $c9, $65, $7a
    db $67, $62, $2e, $63, $66, $67, $00, $66
    db $6c, $61, $75, $6e, $63, $68, $2e, $63
    db $66, $67, $00, $3b, $f8, $03, $2a, $4f
    db $46, $3e, $2f, $02, $f8, $00, $36, $00
    db $f8, $05, $7e, $f8, $00, $86, $5f, $f5
    db $f8, $08, $f1, $7e, $ce, $00, $57, $1a
    db $5f, $f8, $00, $56, $af, $6a, $67, $23
    db $09, $7b, $b7, $28, $06, $73, $f8, $00
    db $34, $18, $dd, $36, $00, $33, $c9, $fa
    db $f9, $db, $b7, $20, $08, $21, $fc, $db
    db $36, $00, $cd, $00, $4a, $fa, $80, $da
    db $b7, $20, $03, $1e, $02, $c9, $fa, $81
    db $da, $b7, $20, $02, $5f, $c9, $0e, $00
    db $21, $81, $da, $46, $69, $26, $00, $11
    db $a4, $c4, $19, $79, $b8, $30, $0d, $c6
    db $82, $5f, $3e, $00, $ce, $da, $57, $1a
    db $77, $0c, $18, $e4, $36, $00, $1e, $01
    db $c9, $f8, $02, $7e, $d6, $61, $38, $0a
    db $3e, $7a, $96, $38, $05, $7e, $c6, $e0
    db $5f, $c9, $f8, $02, $5e, $c9, $1e, $00
    db $f8, $02, $2a, $83, $4f, $7e, $ce, $00
    db $47, $0a, $b7, $c8, $1c, $18, $f1, $16
    db $00, $f8, $02, $2a, $82, $4f, $7e, $ce
    db $00, $47, $0a, $d5, $f5, $33, $cd, $79
    db $46, $33, $f1, $57, $f8, $04, $2a, $82
    db $4f, $7e, $ce, $00, $47, $0a, $d5, $f5
    db $33, $cd, $79, $46, $33, $7b, $d1, $93
    db $28, $03, $1e, $00, $c9, $7b, $b7, $20
    db $03, $1e, $01, $c9, $14, $18, $ca, $fa
    db $a0, $d7, $b7, $28, $04, $11, $a0, $d7
    db $c9, $11, $89, $d7, $c9, $fa, $89, $d7
    db $b7, $3e, $01, $28, $01, $af, $5f, $c9
    db $af, $f5, $33, $cd, $ac, $43, $33, $21
    db $89, $d7, $36, $00, $2e, $a0, $36, $00
    db $c9, $f8, $02, $2a, $5f, $56, $d5, $cd
    db $8e, $46, $e1, $3e, $04, $93, $30, $1f
    db $f8, $02, $2a, $83, $4f, $7e, $ce, $00
    db $47, $79, $c6, $fc, $4f, $78, $ce, $ff
    db $11, $35, $47, $d5, $47, $c5, $cd, $9f
    db $46, $e8, $04, $7b, $b7, $20, $03, $1e
    db $00, $c9, $1e, $01, $c9, $2e, $64, $61
    db $74, $00, $3b, $3b, $f8, $04, $2a, $5f
    db $56, $d5, $cd, $8e, $46, $e1, $7b, $d6
    db $03, $30, $05, $1e, $00, $c3, $d0, $47
    db $f8, $00, $af, $22, $77, $16, $00, $7a
    db $93, $30, $17, $f8, $04, $2a, $82, $4f
    db $7e, $ce, $00, $47, $0a, $fe, $2e, $20
    db $06, $f8, $00, $7a, $22, $36, $01, $14
    db $18, $e5, $f8, $01, $7e, $b7, $20, $03
    db $5f, $18, $55, $f8, $00, $7e, $f8, $04
    db $86, $23, $4f, $3e, $00, $8e, $47, $69
    db $60, $23, $7e, $c5, $f5, $33, $cd, $79
    db $46, $33, $7b, $c1, $fe, $47, $20, $36
    db $69, $60, $23, $23, $7e, $c5, $f5, $33
    db $cd, $79, $46, $33, $7b, $c1, $fe, $42
    db $20, $24, $69, $60, $23, $23, $23, $7e
    db $b7, $20, $04, $1e, $01, $18, $19, $c5
    db $f5, $33, $cd, $79, $46, $33, $7b, $c1
    db $fe, $43, $20, $0a, $21, $04, $00, $09
    db $7e, $b7, $1e, $01, $28, $02, $1e, $00
    db $33, $33, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

LastRomBox::
    db $21, $3f, $db, $36, $00, $af, $0f, $f5
    db $af, $f5, $33, $cd, $91, $27, $e8, $03
    db $f0, $fb, $b7, $c2, $9b, $48, $21, $8f
    db $01, $e5, $21, $58, $9f, $e5, $af, $f5
    db $33, $cd, $ba, $27, $e8, $05, $21, $03
    db $00, $e5, $cd, $90, $02, $e1, $21, $8b
    db $01, $e5, $21, $5b, $9f, $e5, $af, $f5
    db $33, $cd, $ba, $27, $e8, $05, $21, $01
    db $0c, $e5, $3e, $10, $f5, $33, $11, $1f
    db $49, $d5, $cd, $b7, $08, $e8, $05, $21
    db $01, $10, $e5, $3e, $09, $f5, $33, $11
    db $30, $49, $d5, $cd, $b7, $08, $e8, $05
    db $21, $0b, $10, $e5, $3e, $08, $f5, $33
    db $11, $3c, $49, $d5, $cd, $b7, $08, $e8
    db $05, $21, $03, $03, $e5, $cd, $90, $02
    db $e1, $21, $7b, $01, $e5, $21, $6b, $9f
    db $e5, $af, $f5, $33, $cd, $ba, $27, $e8
    db $05, $21, $8b, $01, $e5, $21, $7b, $53
    db $e5, $3e, $53, $f5, $33, $cd, $ba, $27
    db $e8, $05, $c9, $21, $03, $00, $e5, $cd
    db $90, $02, $e1, $21, $8f, $01, $e5, $21
    db $5c, $9f, $e5, $af, $f5, $33, $cd, $ba
    db $27, $e8, $05, $21, $01, $60, $e5, $af
    db $f5, $33, $11, $1f, $49, $d5, $af, $0f
    db $f5, $af, $0f, $f5, $af, $0f, $f5, $cd
    db $00, $75, $e8, $0b, $21, $01, $80, $e5
    db $af, $f5, $33, $11, $30, $49, $d5, $af
    db $0f, $f5, $af, $0f, $f5, $af, $0f, $f5
    db $cd, $00, $75, $e8, $0b, $21, $8f, $00
    db $e5, $21, $5c, $9f, $e5, $af, $f5, $33
    db $cd, $ba, $27, $e8, $05, $21, $03, $03
    db $e5, $cd, $90, $02, $e1, $21, $7d, $01
    db $e5, $21, $6d, $9f, $e5, $af, $f5, $33
    db $cd, $ba, $27, $e8, $05, $21, $8f, $01
    db $e5, $21, $7d, $4f, $e5, $3e, $4f, $f5
    db $33, $cd, $ba, $27, $e8, $05, $c9, $4c
    db $61, $75, $6e, $63, $68, $20, $4c, $61
    db $73, $74, $20, $52, $4f, $4d, $3f, $00
    db $5b, $42, $5d, $72, $65, $74, $75, $72
    db $6e, $20, $20, $20, $5b, $41, $5d, $73
    db $74, $61, $72, $74, $00

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

ThemeRamps::
    db $ff, $7f, $b5, $56, $4a, $29, $00, $00
    db $00, $00, $c6, $18, $31, $46, $ff, $7f
    db $28, $04, $ed, $1c, $55, $4a, $ff, $7f
    db $22, $0d, $a8, $25, $b2, $4e, $ff, $7f
    db $48, $30, $0d, $41, $55, $5e, $ff, $7f
    db $a2, $30, $48, $41, $92, $5e, $ff, $7f

ThemeCustom::
    db $cd, $8d, $07, $50, $7b, $05, $00, $c9
    db $11, $58, $db, $fa, $f9, $db, $b7, $20
    db $0e, $21, $18, $a4, $06, $08, $2a, $12
    db $13, $05, $20, $fa, $11, $58, $db, $fa
    db $f7, $db, $fe, $06, $c8, $87, $87, $87
    db $c6, $60, $5f, $ce, $49, $93, $57, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    db $fa, $fc, $db, $b7, $ca, $51, $53, $fe
    db $01, $ca, $92, $59, $fe, $02, $20, $08
    db $af, $f5, $33, $cd, $7f, $4c, $33, $c9
    db $fe, $06, $20, $09, $3e, $01, $f5, $33
    db $cd, $7f, $4c, $33, $c9, $fe, $07, $20
    db $13, $fa, $3a, $db, $b7, $c0, $cd, $51
    db $53, $21, $4c, $00, $e5, $cd, $1f, $4c
    db $e1, $c3, $92, $59, $fe, $04, $ca, $41
    db $5c, $fe, $05, $ca, $9b, $5c, $fe, $08
    db $ca, $16, $5d, $fe, $09, $c2, $fd, $4d
    db $cd, $51, $53, $cd, $b2, $4d, $7b, $21
    db $00, $40, $36, $00, $b7, $c2, $92, $59
    db $c9, $21, $00, $7f, $36, $e1, $2e, $10
    db $36, $e2, $2e, $20, $36, $e3, $11, $c0
    db $7f, $f8, $02, $7e, $12, $21, $f0, $7f
    db $36, $e4, $c9, $21, $00, $7f, $36, $e1
    db $2e, $10, $36, $e2, $2e, $20, $36, $e3
    db $2e, $d0, $36, $01, $2e, $f0, $36, $e4
    db $c9, $cd, $88, $06, $af, $f5, $33, $cd
    db $61, $4a, $33, $c9, $3e, $06, $f5, $33
    db $cd, $61, $4a, $33, $0e, $00, $69, $26
    db $00, $11, $08, $a0, $19, $46, $69, $26
    db $00, $11, $50, $db, $19, $70, $69, $26
    db $00, $11, $48, $db, $19, $3e, $dd, $81
    db $5f, $3e, $4a, $ce, $00, $57, $1a, $a0
    db $77, $0c, $79, $d6, $07, $38, $d7, $af
    db $f5, $33, $cd, $61, $4a, $33, $c9, $06
    db $05, $03, $02, $01, $00, $7f, $7f, $3f
    db $3f, $07, $1f, $ff, $3b, $3e, $06, $f5
    db $33, $cd, $61, $4a, $33, $f8, $00, $36
    db $00, $f8, $00, $7e, $c6, $08, $4f, $3e
    db $00, $ce, $a0, $47, $f8, $03, $7e, $f8
    db $00, $86, $23, $23, $23, $23, $5f, $7e
    db $ce, $00, $57, $1a, $02, $f8, $00, $34
    db $7e, $d6, $07, $38, $dc, $cd, $7b, $4a
    db $af, $f5, $33, $cd, $61, $4a, $e1, $c9
    db $f8, $02, $7e, $e6, $0f, $fe, $0a, $38
    db $03, $1e, $00, $c9, $f8, $02, $7e, $cb
    db $37, $e6, $0f, $fe, $0a, $38, $03, $1e
    db $00, $c9, $f8, $03, $3a, $96, $3e, $00
    db $17, $ee, $01, $5f, $c9, $f8, $02, $2a
    db $4f, $46, $0a, $c5, $26, $59, $e5, $33
    db $f5, $33, $cd, $20, $4b, $e1, $7b, $c1
    db $b7, $20, $02, $5f, $c9, $69, $60, $23
    db $7e, $c5, $26, $59, $e5, $33, $f5, $33
    db $cd, $20, $4b, $e1, $7b, $c1, $b7, $20
    db $02, $5f, $c9, $69, $60, $23, $23, $7e
    db $c5, $26, $23, $e5, $33, $f5, $33, $cd
    db $20, $4b, $e1, $7b, $c1, $b7, $20, $02
    db $5f, $c9, $69, $60, $23, $23, $23, $56
    db $c5, $d5, $3e, $31, $f5, $33, $d5, $33
    db $cd, $20, $4b, $e1, $7b, $d1, $c1, $b7
    db $28, $04, $7a, $b7, $20, $03, $1e, $00
    db $c9, $21, $05, $00, $09, $56, $c5, $d5
    db $3e, $12, $f5, $33, $d5, $33, $cd, $20
    db $4b, $e1, $7b, $d1, $c1, $b7, $28, $04
    db $7a, $b7, $20, $03, $1e, $00, $c9, $21
    db $06, $00, $09, $7e, $26, $99, $e5, $33
    db $f5, $33, $cd, $20, $4b, $e1, $7b, $b7
    db $20, $02, $5f, $c9, $1e, $01, $c9, $3b
    db $0e, $00, $21, $d7, $4a, $06, $00, $09
    db $46, $f8, $03, $2a, $80, $5f, $7e, $ce
    db $00, $57, $1a, $f8, $00, $77, $f8, $05
    db $2a, $80, $47, $7e, $ce, $00, $68, $67
    db $46, $f8, $00, $7e, $90, $30, $04, $1e
    db $ff, $18, $12, $78, $f8, $00, $96, $30
    db $04, $1e, $01, $18, $08, $0c, $79, $d6
    db $06, $38, $c7, $1e, $00, $33, $c9, $cd
    db $9c, $4a, $11, $48, $db, $d5, $cd, $45
    db $4b, $e1, $7b, $b7, $c8, $f8, $03, $7e
    db $b7, $20, $2d, $fa, $50, $db, $07, $d8
    db $fa, $47, $db, $b7, $28, $22, $11, $40
    db $db, $d5, $11, $48, $db, $d5, $cd, $df
    db $4b, $e8, $04, $4b, $af, $57, $91, $cb
    db $7b, $28, $07, $cb, $7a, $20, $08, $bf
    db $18, $05, $cb, $7a, $28, $01, $37, $d0
    db $1e, $00, $7b, $c6, $40, $4f, $3e, $00
    db $ce, $db, $47, $21, $48, $db, $16, $00
    db $19, $7e, $02, $1c, $7b, $d6, $07, $38
    db $e9, $21, $47, $db, $36, $01, $c9, $fa
    db $3a, $db, $b7, $c0, $cd, $51, $53, $f8
    db $02, $7e, $b7, $3e, $54, $20, $02, $3e
    db $42, $f8, $02, $66, $e5, $33, $f5, $33
    db $cd, $1f, $4c, $e1, $c3, $92, $59, $e8
    db $f3, $0e, $3c, $c5, $cd, $88, $06, $c1
    db $0d, $20, $f8, $cd, $9c, $4a, $f8, $00
    db $4d, $44, $f8, $0b, $36, $00, $f8, $0c
    db $36, $00, $79, $f8, $0c, $86, $f5, $f8
    db $09, $f1, $22, $78, $ce, $00, $77, $f8
    db $0c, $3a, $2b, $2b, $c6, $48, $22, $3e
    db $00, $ce, $db, $32, $2a, $5f, $56, $1a
    db $f8, $07, $5e, $23, $66, $6b, $77, $f8
    db $0c, $34, $7e, $d6, $07, $38, $d3, $c5
    db $cd, $88, $06, $cd, $9c, $4a, $c1, $f8
    db $0c, $36, $01, $1e, $00, $6b, $26, $00
    db $09, $56, $7b, $c6, $48, $6f, $3e, $00
    db $ce, $db, $67, $7e, $92, $28, $04, $f8
    db $0c, $36, $00, $1c, $7b, $d6, $07, $38
    db $e4, $f8, $0c, $7e, $b7, $20, $08, $f8
    db $0b, $34, $7e, $d6, $08, $38, $97, $e8
    db $0d, $c9, $fa, $4e, $db, $b7, $20, $03
    db $1e, $5a, $c9, $11, $48, $db, $d5, $cd
    db $45, $4b, $e1, $7b, $b7, $20, $03, $1e
    db $49, $c9, $fa, $50, $db, $07, $30, $03
    db $1e, $56, $c9, $11, $40, $db, $d5, $11
    db $48, $db, $d5, $cd, $df, $4b, $e8, $04
    db $4b, $cb, $79, $1e, $45, $c0, $1e, $00
    db $c9, $cd, $a1, $4d, $21, $10, $04, $19
    db $4d, $44, $0a, $fe, $53, $20, $11, $69
    db $60, $23, $7e, $fe, $31, $20, $09, $af
    db $02, $36, $00, $21, $ff, $db, $36, $01
    db $69, $60, $23, $23, $5e, $03, $03, $03
    db $7b, $d6, $53, $20, $11, $0a, $fe, $42
    db $28, $05, $0a, $fe, $4e, $20, $07, $e5
    db $21, $f8, $db, $36, $01, $e1, $36, $00
    db $af, $02, $f5, $33, $cd, $61, $4a, $33
    db $c9, $21, $00, $40, $36, $11, $3e, $03
    db $f5, $33, $cd, $61, $4a, $33, $11, $00
    db $a0, $c9, $cd, $a1, $4d, $21, $00, $02
    db $19, $4e, $c5, $af, $f5, $33, $cd, $61
    db $4a, $33, $c1, $3e, $01, $91, $38, $06
    db $fa, $57, $db, $91, $20, $03, $1e, $00
    db $c9, $21, $57, $db, $71, $1e, $01, $c9
    db $fa, $fd, $db, $b7, $c8, $cd, $a1, $4d
    db $4b, $42, $af, $02, $fa, $57, $db, $fe
    db $02, $30, $0a, $21, $00, $02, $09, $4d
    db $44, $fa, $57, $db, $02, $af, $f5, $33
    db $cd, $61, $4a, $33, $c9, $cd, $c0, $43
    db $f0, $f7, $4f, $c5, $cd, $4a, $3a, $7b
    db $c1, $b1, $e0, $f7, $cd, $59, $4d, $cd
    db $51, $53, $cd, $d0, $43, $cd, $d8, $4d
    db $fa, $3a, $db, $b7, $c0, $fa, $47, $db
    db $b7, $c8, $cd, $9c, $4a, $cd, $22, $4d
    db $7b, $b7, $c8, $cd, $9f, $4c, $cd, $22
    db $4d, $7b, $b7, $c8, $d5, $7b, $f5, $33
    db $cd, $86, $4f, $33, $7b, $d1, $b7, $28
    db $09, $11, $40, $db, $d5, $cd, $e4, $4a
    db $e1, $c9, $7b, $d6, $56, $c0, $11, $48
    db $db, $d5, $cd, $e4, $4a, $e1, $c9, $f8
    db $04, $7e, $cb, $37, $e6, $0f, $4e, $2b
    db $2b, $f5, $79, $e6, $0f, $4f, $f1, $5e
    db $23, $56, $47, $d6, $0a, $30, $05, $78
    db $c6, $30, $18, $03, $78, $c6, $37, $12
    db $13, $41, $79, $d6, $0a, $30, $05, $78
    db $c6, $30, $18, $03, $78, $c6, $37, $12
    db $c9, $f8, $04, $2a, $c6, $06, $4f, $7e
    db $ce, $00, $47, $0a, $f5, $33, $f8, $03
    db $2a, $5f, $56, $d5, $cd, $57, $4e, $e8
    db $03, $f8, $02, $2a, $4f, $2a, $47, $03
    db $03, $3e, $2d, $02, $2a, $c6, $05, $4f
    db $7e, $ce, $00, $69, $67, $46, $f8, $02
    db $2a, $5f, $56, $13, $13, $13, $c5, $33
    db $d5, $cd, $57, $4e, $e8, $03, $f8, $02
    db $2a, $c6, $05, $4f, $7e, $ce, $00, $69
    db $67, $36, $2d, $f8, $04, $2a, $4f, $46
    db $03, $03, $03, $0a, $47, $f8, $02, $2a
    db $c6, $06, $4f, $7e, $ce, $00, $c5, $33
    db $47, $c5, $cd, $57, $4e, $e8, $03, $c9
    db $f8, $04, $2a, $4f, $46, $03, $03, $0a
    db $f5, $33, $f8, $03, $2a, $5f, $56, $d5
    db $cd, $57, $4e, $e8, $03, $f8, $02, $2a
    db $4f, $2a, $47, $03, $03, $3e, $3a, $02
    db $2a, $4f, $46, $03, $0a, $57, $f8, $02
    db $2a, $4f, $46, $03, $03, $03, $d5, $33
    db $c5, $cd, $57, $4e, $e8, $03, $f8, $02
    db $2a, $c6, $05, $4f, $7e, $ce, $00, $69
    db $67, $36, $3a, $f8, $04, $2a, $4f, $46
    db $0a, $47, $f8, $02, $2a, $c6, $06, $4f
    db $7e, $ce, $00, $c5, $33, $47, $c5, $cd
    db $57, $4e, $e8, $03, $c9, $f0, $fb, $b7
    db $28, $1f, $f8, $08, $3a, $57, $5e, $d5
    db $f8, $06, $3a, $2b, $f5, $33, $2a, $5f
    db $56, $d5, $af, $0f, $f5, $af, $0f, $f5
    db $af, $0f, $f5, $cd, $00, $75, $e8, $0b
    db $c9, $f8, $06, $3a, $57, $3a, $5f, $d5
    db $3a, $2b, $f5, $33, $2a, $5f, $56, $d5
    db $cd, $b7, $08, $e8, $05, $c9, $e8, $f5
    db $f8, $0d, $7e, $d6, $5a, $20, $05, $01
    db $36, $52, $18, $1b, $f8, $0d, $7e, $d6
    db $49, $20, $05, $01, $41, $52, $18, $0f
    db $f8, $0d, $7e, $d6, $56, $20, $05, $01
    db $4a, $52, $18, $03, $01, $55, $52, $1e
    db $00, $6b, $26, $00, $09, $7e, $b7, $28
    db $03, $1c, $18, $f5, $f8, $00, $73, $f0
    db $fb, $f8, $0a, $32, $36, $00, $c5, $21
    db $05, $08, $e5, $3e, $01, $f5, $33, $11
    db $34, $52, $d5, $cd, $b7, $08, $e8, $05
    db $af, $0f, $f5, $af, $f5, $33, $cd, $91
    db $27, $e8, $03, $21, $7f, $01, $e5, $21
    db $10, $9f, $e5, $af, $f5, $33, $cd, $ba
    db $27, $e8, $05, $21, $03, $00, $e5, $cd
    db $90, $02, $e1, $c1, $f8, $0a, $7e, $b7
    db $28, $14, $c5, $21, $73, $01, $e5, $21
    db $14, $9f, $e5, $af, $f5, $33, $cd, $ba
    db $27, $e8, $05, $c1, $18, $12, $c5, $21
    db $63, $01, $e5, $21, $1b, $9f, $e5, $af
    db $f5, $33, $cd, $ba, $27, $e8, $05, $c1
    db $21, $01, $18, $e5, $21, $01, $04, $e5
    db $f8, $04, $7e, $f5, $33, $c5, $cd, $4d
    db $4f, $e8, $07, $21, $01, $2c, $e5, $21
    db $01, $06, $e5, $3e, $04, $f5, $33, $11
    db $61, $52, $d5, $cd, $4d, $4f, $e8, $07
    db $21, $01, $00, $39, $e5, $11, $50, $db
    db $d5, $e5, $cd, $89, $4e, $e8, $04, $e1
    db $e5, $11, $3c, $2c, $d5, $11, $06, $06
    db $d5, $3e, $08, $f5, $33, $e5, $cd, $4d
    db $4f, $e8, $07, $e1, $e5, $11, $50, $db
    db $d5, $e5, $cd, $f0, $4e, $e8, $04, $e1
    db $e5, $11, $3c, $38, $d5, $11, $06, $07
    db $d5, $3e, $08, $f5, $33, $e5, $cd, $4d
    db $4f, $e8, $07, $21, $01, $44, $e5, $21
    db $01, $08, $e5, $3e, $02, $f5, $33, $11
    db $66, $52, $d5, $cd, $4d, $4f, $e8, $07
    db $e1, $e5, $11, $40, $db, $d5, $e5, $cd
    db $89, $4e, $e8, $04, $e1, $e5, $11, $3c
    db $44, $d5, $11, $06, $08, $d5, $3e, $08
    db $f5, $33, $e5, $cd, $4d, $4f, $e8, $07
    db $e1, $e5, $11, $40, $db, $d5, $e5, $cd
    db $f0, $4e, $e8, $04, $e1, $11, $3c, $50
    db $d5, $11, $06, $09, $d5, $3e, $08, $f5
    db $33, $e5, $cd, $4d, $4f, $e8, $07, $f8
    db $0a, $7e, $b7, $ca, $6c, $51, $21, $01
    db $64, $e5, $3e, $07, $f5, $33, $11, $69
    db $52, $d5, $af, $0f, $f5, $af, $0f, $f5
    db $af, $0f, $f5, $cd, $00, $75, $e8, $0b
    db $21, $58, $64, $e5, $af, $f5, $33, $11
    db $73, $52, $d5, $af, $0f, $f5, $af, $0f
    db $f5, $af, $0f, $f5, $cd, $00, $75, $e8
    db $0b, $21, $73, $00, $e5, $21, $14, $9f
    db $e5, $af, $f5, $33, $cd, $ba, $27, $e8
    db $05, $21, $03, $03, $e5, $cd, $90, $02
    db $e1, $21, $26, $01, $e5, $21, $26, $9f
    db $e5, $af, $f5, $33, $cd, $ba, $27, $e8
    db $05, $21, $5f, $01, $e5, $21, $5f, $9f
    db $e5, $af, $f5, $33, $cd, $ba, $27, $e8
    db $05, $21, $73, $01, $e5, $21, $5f, $4f
    db $e5, $3e, $4f, $f5, $33, $cd, $ba, $27
    db $e8, $05, $18, $5b, $21, $01, $0b, $e5
    db $3e, $07, $f5, $33, $11, $69, $52, $d5
    db $cd, $b7, $08, $e8, $05, $21, $0a, $0b
    db $e5, $3e, $09, $f5, $33, $11, $73, $52
    db $d5, $cd, $b7, $08, $e8, $05, $21, $03
    db $03, $e5, $cd, $90, $02, $e1, $21, $2b
    db $01, $e5, $21, $2b, $9f, $e5, $af, $f5
    db $33, $cd, $ba, $27, $e8, $05, $21, $53
    db $01, $e5, $21, $53, $9f, $e5, $af, $f5
    db $33, $cd, $ba, $27, $e8, $05, $21, $63
    db $01, $e5, $21, $53, $4b, $e5, $3e, $4b
    db $f5, $33, $cd, $ba, $27, $e8, $05, $21
    db $03, $00, $e5, $cd, $90, $02, $e1, $f8
    db $0a, $36, $00, $cd, $88, $06, $cd, $4a
    db $3a, $7b, $e6, $30, $28, $06, $f8, $0a
    db $36, $00, $18, $03, $f8, $0a, $34, $f8
    db $0a, $7e, $d6, $08, $38, $e5, $cd, $88
    db $06, $cd, $4a, $3a, $cb, $63, $28, $06
    db $f8, $0a, $36, $01, $18, $08, $cb, $6b
    db $28, $ec, $f8, $0a, $36, $00, $cd, $4a
    db $3a, $7b, $e6, $30, $28, $05, $cd, $88
    db $06, $18, $f3, $af, $0f, $f5, $af, $f5
    db $33, $cd, $91, $27, $e8, $03, $21, $7f
    db $01, $e5, $21, $10, $9f, $e5, $af, $f5
    db $33, $cd, $ba, $27, $e8, $05, $f8, $0a
    db $5e, $e8, $0b, $c9, $20, $00, $52, $54
    db $43, $20, $52, $45, $53, $45, $54, $3f
    db $00, $52, $54, $43, $20, $42, $41, $44
    db $3f, $00, $52, $54, $43, $20, $4c, $4f
    db $57, $20, $56, $3f, $00, $52, $54, $43
    db $20, $42, $45, $48, $49, $4e, $44, $3f
    db $00, $43, $48, $49, $50, $00, $53, $44
    db $00, $5b, $42, $5d, $6b, $65, $65, $70
    db $20, $20, $20, $5b, $41, $5d, $75, $73
    db $65, $20, $53, $44, $00, $3b, $f8, $00
    db $36, $00, $f8, $00, $5e, $16, $db, $f8
    db $03, $7e, $f8, $00, $86, $23, $23, $23
    db $23, $4f, $7e, $ce, $00, $47, $0a, $12
    db $0a, $b7, $28, $05, $f8, $00, $34, $18
    db $e1, $33, $c9, $f8, $02, $2a, $5f, $56
    db $d5, $cd, $7d, $52, $e1, $cd, $91, $4a
    db $3e, $01, $f5, $33, $11, $00, $db, $d5
    db $11, $0f, $ca, $d5, $cd, $26, $19, $e8
    db $05, $7b, $b7, $28, $03, $1e, $00, $c9
    db $cd, $91, $4a, $f8, $04, $2a, $5f, $56
    db $d5, $11, $00, $02, $d5, $11, $00, $d8
    db $d5, $11, $0f, $ca, $d5, $cd, $41, $19
    db $e8, $08, $d5, $cd, $91, $4a, $01, $0f
    db $ca, $c5, $cd, $a1, $19, $e1, $d1, $f8
    db $04, $2a, $4f, $46, $7b, $b7, $28, $06
    db $af, $02, $03, $02, $18, $17, $69, $60
    db $2a, $66, $6f, $3e, $ff, $bd, $3e, $00
    db $9c, $30, $0a, $7c, $d6, $02, $30, $05
    db $7d, $02, $03, $af, $02, $1e, $01, $c9
    db $3b, $3b, $cd, $91, $4a, $f8, $00, $e5
    db $f8, $08, $2a, $5f, $56, $d5, $f8, $08
    db $2a, $5f, $56, $d5, $11, $0f, $ca, $d5
    db $cd, $63, $19, $e8, $08, $7b, $b7, $20
    db $15, $f8, $00, $7e, $f8, $06, $96, $20
    db $0b, $f8, $01, $7e, $f8, $07, $96, $20
    db $03, $5f, $18, $02, $1e, $ff, $33, $33
    db $c9, $e8, $fd, $21, $f9, $db, $36, $01
    db $21, $80, $da, $36, $01, $2e, $81, $36
    db $00, $2e, $82, $36, $00, $21, $47, $db
    db $36, $00, $21, $7f, $da, $36, $00, $2e
    db $00, $75, $21, $3a, $db, $36, $00, $2e
    db $57, $36, $ff, $2e, $f7, $36, $00, $2e
    db $f6, $36, $00, $f8, $02, $36, $00, $f8
    db $00, $e5, $e5, $11, $d0, $53, $d5, $cd
    db $a3, $52, $e8, $04, $7b, $e1, $b7, $20
    db $12, $e5, $11, $da, $53, $d5, $cd, $a3
    db $52, $e8, $04, $7b, $b7, $28, $26, $f8
    db $02, $36, $01, $f8, $02, $3a, $2b, $f5
    db $33, $2a, $5f, $56, $d5, $cd, $e7, $53
    db $e8, $03, $21, $f7, $db, $4e, $fa, $ea
    db $db, $c6, $06, $47, $79, $90, $38, $05
    db $21, $f7, $db, $36, $00, $e8, $03, $c9
    db $2f, $45, $5a, $47, $42, $2e, $43, $46
    db $47, $00, $2f, $46, $4c, $41, $55, $4e
    db $43, $48, $2e, $43, $46, $47, $00, $e8
    db $ee, $f8, $14, $af, $96, $23, $3e, $02
    db $9e, $30, $06, $f8, $14, $af, $22, $36
    db $02, $f8, $14, $2a, $4f, $7e, $c6, $d8
    db $47, $af, $02, $f8, $0d, $36, $00, $af
    db $f8, $04, $22, $77, $f8, $04, $5d, $54
    db $f8, $14, $1a, $13, $96, $23, $1a, $9e
    db $d2, $57, $57, $f8, $04, $2a, $4f, $46
    db $f8, $14, $79, $96, $23, $78, $9e, $30
    db $0c, $21, $00, $d8, $09, $7e, $fe, $20
    db $20, $03, $03, $18, $eb, $f8, $09, $79
    db $22, $70, $f8, $14, $79, $96, $23, $78
    db $9e, $30, $20, $21, $00, $d8, $09, $e5
    db $7d, $f8, $12, $77, $e1, $7c, $f8, $11
    db $32, $2a, $5f, $56, $1a, $fe, $0d, $28
    db $0a, $fe, $0a, $28, $06, $b7, $28, $03
    db $03, $18, $d7, $f8, $0f, $79, $22, $70
    db $f8, $14, $79, $96, $23, $78, $9e, $30
    db $10, $21, $00, $d8, $09, $7e, $fe, $0d
    db $28, $04, $fe, $0a, $20, $03, $03, $18
    db $e7, $f8, $04, $79, $22, $70, $f8, $0f
    db $2a, $4f, $7e, $c6, $d8, $47, $0a, $b7
    db $20, $1a, $f8, $0f, $5d, $54, $f8, $14
    db $1a, $13, $96, $23, $1a, $9e, $30, $0c
    db $f8, $14, $7e, $f8, $04, $77, $f8, $15
    db $7e, $f8, $05, $77, $f8, $09, $5d, $54
    db $f8, $0f, $1a, $13, $96, $23, $1a, $9e
    db $30, $37, $f8, $0f, $7e, $c6, $ff, $f5
    db $f8, $09, $f1, $77, $f5, $f8, $12, $f1
    db $7e, $ce, $ff, $f8, $08, $32, $2a, $23
    db $23, $23, $32, $2b, $2b, $7e, $c6, $d8
    db $f8, $0c, $32, $2a, $5f, $56, $1a, $fe
    db $20, $20, $0e, $f8, $07, $7e, $f8, $0f
    db $77, $f8, $08, $7e, $f8, $10, $77, $18
    db $bb, $f8, $09, $7e, $f8, $0f, $96, $20
    db $09, $f8, $0a, $7e, $f8, $10, $96, $ca
    db $0c, $54, $f8, $09, $7e, $f8, $11, $77
    db $f8, $09, $3a, $2b, $2b, $22, $23, $23
    db $23, $7e, $c6, $d8, $f8, $07, $77, $f8
    db $16, $7e, $b7, $28, $15, $f8, $0f, $2a
    db $23, $96, $f5, $33, $f8, $07, $2a, $5f
    db $56, $d5, $cd, $e4, $57, $e8, $03, $c3
    db $57, $57, $f8, $09, $7e, $f8, $00, $77
    db $f8, $0a, $7e, $f8, $01, $77, $f8, $00
    db $5d, $54, $f8, $0f, $1a, $13, $96, $23
    db $1a, $9e, $3e, $00, $17, $f8, $0e, $77
    db $f8, $00, $7e, $c6, $01, $f5, $f8, $0d
    db $f1, $77, $f5, $f8, $03, $f1, $7e, $ce
    db $00, $f8, $0c, $22, $23, $7e, $b7, $28
    db $20, $f8, $00, $2a, $23, $32, $2a, $23
    db $c6, $d8, $32, $2a, $5f, $56, $1a, $fe
    db $3d, $28, $0e, $f8, $0b, $7e, $f8, $00
    db $77, $f8, $0c, $7e, $f8, $01, $77, $18
    db $b5, $f8, $0e, $cb, $46, $ca, $0c, $54
    db $f8, $00, $7e, $f8, $11, $96, $77, $f8
    db $0b, $2a, $4f, $46, $f8, $11, $7e, $b7
    db $28, $1e, $7e, $f8, $0b, $22, $af, $32
    db $3a, $2b, $86, $23, $5f, $3e, $00, $8e
    db $57, $1b, $21, $00, $d8, $19, $7e, $fe
    db $20, $20, $05, $f8, $11, $35, $18, $dc
    db $f8, $11, $7e, $f8, $08, $77, $21, $00
    db $d8, $09, $e5, $7d, $f8, $0d, $77, $e1
    db $7c, $f8, $0c, $77, $f8, $0f, $79, $96
    db $23, $78, $9e, $30, $0d, $f8, $0b, $2a
    db $5f, $56, $1a, $fe, $20, $20, $03, $03
    db $18, $dc, $f8, $0b, $3a, $2b, $77, $f8
    db $0c, $3a, $2b, $77, $f8, $0f, $2a, $91
    db $4f, $7e, $98, $47, $79, $3d, $b0, $20
    db $0b, $f8, $09, $2a, $5f, $56, $1a, $c6
    db $d0, $5f, $18, $02, $1e, $ff, $f8, $0b
    db $73, $f8, $0e, $3e, $01, $22, $3e, $5a
    db $22, $3e, $57, $22, $36, $00, $f8, $0f
    db $2a, $5f, $56, $1a, $f8, $0c, $77, $b7
    db $28, $43, $f8, $0f, $2a, $5f, $56, $13
    db $c5, $f8, $0e, $7e, $f5, $33, $d5, $f8
    db $0d, $3a, $2b, $f5, $33, $2a, $5f, $56
    db $d5, $cd, $a8, $57, $e8, $06, $7b, $c1
    db $f8, $0f, $5e, $23, $56, $f5, $1a, $f8
    db $0e, $77, $f1, $b7, $20, $17, $f8, $11
    db $34, $f8, $0e, $cb, $26, $2b, $2b, $5e
    db $16, $00, $13, $7b, $f8, $0f, $86, $22
    db $7a, $8e, $77, $18, $b1, $f8, $0c, $7e
    db $b7, $ca, $0c, $54, $23, $2a, $a6, $c2
    db $0c, $54, $2b, $2a, $b6, $2b, $77, $3e
    db $08, $f8, $11, $96, $da, $0c, $54, $51
    db $d5, $5e, $16, $00, $21, $97, $56, $19
    db $19, $5e, $23, $66, $6b, $d1, $e9, $a9
    db $56, $b9, $56, $c9, $56, $d8, $56, $fc
    db $56, $13, $57, $23, $57, $2d, $57, $44
    db $57, $d5, $33, $f8, $0a, $2a, $5f, $56
    db $d5, $cd, $e4, $57, $e8, $03, $c3, $0c
    db $54, $d5, $33, $f8, $0a, $2a, $5f, $56
    db $d5, $cd, $72, $58, $e8, $03, $c3, $0c
    db $54, $c5, $f8, $0b, $2a, $5f, $56, $d5
    db $cd, $7e, $5b, $e8, $04, $c3, $0c, $54
    db $79, $d6, $02, $78, $de, $00, $38, $16
    db $f8, $09, $2a, $5f, $56, $1a, $fe, $31
    db $20, $0c, $2b, $2a, $4f, $46, $03, $0a
    db $fe, $32, $3e, $01, $28, $01, $af, $e0
    db $fb, $c3, $0c, $54, $78, $b1, $28, $0c
    db $f8, $09, $2a, $5f, $56, $1a, $fe, $30
    db $3e, $01, $28, $01, $af, $ea, $3a, $db
    db $c3, $0c, $54, $3e, $01, $f8, $0b, $96
    db $da, $0c, $54, $11, $57, $db, $7e, $12
    db $c3, $0c, $54, $11, $f7, $db, $f8, $0b
    db $7e, $12, $c3, $0c, $54, $78, $b1, $28
    db $0c, $f8, $09, $2a, $5f, $56, $1a, $fe
    db $30, $3e, $01, $28, $01, $af, $ea, $f6
    db $db, $c3, $0c, $54, $d5, $33, $f8, $0a
    db $2a, $5f, $56, $d5, $af, $f5, $33, $cd
    db $90, $49, $e8, $04, $c3, $0c, $54, $e8
    db $12, $c9, $07, $66, $6c, $61, $75, $6e
    db $63, $68, $03, $72, $74, $63, $07, $6c
    db $61, $73, $74, $72, $6f, $6d, $02, $75
    db $69, $05, $72, $74, $63, $73, $64, $08
    db $61, $75, $74, $6f, $73, $61, $76, $65
    db $05, $74, $68, $65, $6d, $65, $04, $74
    db $61, $67, $73, $06, $63, $6f, $6c, $6f
    db $72, $73, $00, $f8, $02, $7e, $d6, $41
    db $38, $0a, $3e, $5a, $96, $38, $05, $7e
    db $c6, $20, $5f, $c9, $f8, $02, $5e, $c9
    db $f8, $04, $7e, $f8, $07, $96, $28, $03
    db $1e, $00, $c9, $16, $00, $7a, $f8, $04
    db $96, $30, $26, $2b, $2b, $2a, $82, $4f
    db $7e, $ce, $00, $47, $0a, $d5, $f5, $33
    db $cd, $93, $57, $33, $f1, $57, $f8, $05
    db $2a, $82, $4f, $7e, $ce, $00, $47, $0a
    db $93, $28, $03, $1e, $00, $c9, $14, $18
    db $d4, $1e, $01, $c9, $3b, $3b, $f8, $01
    db $36, $00, $f8, $06, $7e, $b7, $28, $26
    db $2b, $2b, $2a, $4f, $46, $0a, $fe, $23
    db $20, $1c, $21, $80, $da, $36, $00, $1e
    db $01, $7b, $f8, $06, $96, $30, $0c, $6b
    db $26, $00, $09, $7e, $fe, $20, $20, $03
    db $1c, $18, $ee, $f8, $01, $73, $f8, $01
    db $7e, $f8, $06, $96, $30, $51, $0e, $00
    db $f8, $04, $7e, $f8, $01, $86, $23, $23
    db $23, $23, $5f, $7e, $ce, $00, $57, $1a
    db $fe, $2f, $28, $07, $0e, $01, $21, $82
    db $da, $36, $2f, $f8, $01, $46, $79, $c6
    db $82, $f5, $f8, $02, $f1, $22, $3e, $00
    db $ce, $da, $77, $78, $f8, $06, $96, $30
    db $16, $79, $d6, $78, $30, $11, $2b, $2b
    db $0c, $2a, $80, $5f, $7e, $ce, $00, $57
    db $1a, $e1, $e5, $77, $04, $18, $d7, $e1
    db $36, $00, $e5, $21, $81, $da, $71, $33
    db $33, $c9, $e8, $f2, $0e, $00, $59, $16
    db $00, $21, $02, $00, $39, $19, $36, $00
    db $0c, $79, $d6, $06, $38, $f0, $f8, $08
    db $af, $22, $22, $23, $af, $22, $22, $36
    db $00, $f8, $0d, $7e, $f8, $12, $96, $30
    db $12, $2b, $2b, $7e, $f8, $0d, $86, $23
    db $23, $23, $23, $4f, $7e, $ce, $00, $47
    db $0a, $18, $01, $af, $f8, $0a, $77, $d6
    db $30, $38, $11, $3e, $39, $96, $38, $0c
    db $2b, $3a, $22, $23, $3a, $c6, $d0, $22
    db $23, $34, $18, $30, $f8, $0b, $7e, $b7
    db $28, $1e, $23, $7e, $d6, $06, $30, $18
    db $5e, $16, $00, $21, $02, $00, $39, $19
    db $d1, $e5, $f8, $0c, $34, $f8, $08, $2a
    db $cb, $37, $e6, $f0, $b6, $e1, $e5, $77
    db $f8, $08, $af, $22, $22, $23, $af, $32
    db $7e, $b7, $28, $0b, $f8, $0d, $34, $f8
    db $12, $7e, $f8, $0d, $96, $30, $92, $f8
    db $0c, $7e, $d6, $06, $38, $35, $f8, $02
    db $7e, $ea, $46, $db, $f8, $03, $7e, $ea
    db $45, $db, $f8, $04, $7e, $21, $43, $db
    db $77, $2e, $44, $36, $03, $f8, $05, $7e
    db $ea, $42, $db, $f8, $06, $7e, $ea, $41
    db $db, $f8, $07, $7e, $ea, $40, $db, $11
    db $40, $db, $d5, $cd, $45, $4b, $e1, $7b
    db $ea, $47, $db, $e8, $0e, $c9, $f8, $02
    db $2a, $4f, $2a, $47, $7e, $cb, $37, $e6
    db $0f, $c6, $30, $02, $03, $7e, $e6, $0f
    db $c6, $30, $02, $1e, $02, $c9, $f8, $04
    db $2a, $4f, $46, $f8, $02, $2a, $5f, $56
    db $f8, $06, $7e, $6f, $3d, $2c, $2d, $c8
    db $f5, $0a, $6f, $f1, $03, $f5, $7d, $12
    db $f1, $13, $18, $ef, $f8, $02, $2a, $4f
    db $3a, $47, $3e, $0d, $02, $03, $79, $22
    db $78, $32, $2a, $4f, $3a, $47, $3e, $0a
    db $02, $03, $79, $22, $78, $32, $2a, $5f
    db $56, $c9, $e8, $fb, $3e, $08, $f5, $33
    db $11, $4a, $5b, $d5, $11, $00, $d8, $d5
    db $cd, $56, $59, $e8, $05, $4b, $42, $fa
    db $80, $da, $b7, $20, $04, $3e, $23, $02
    db $03, $fa, $81, $da, $f5, $33, $11, $82
    db $da, $d5, $c5, $cd, $56, $59, $e8, $05
    db $d5, $cd, $74, $59, $e1, $4b, $42, $fa
    db $47, $db, $b7, $28, $58, $3e, $06, $f5
    db $33, $11, $52, $5b, $d5, $c5, $cd, $56
    db $59, $e8, $05, $f8, $04, $36, $00, $3e
    db $d7, $f8, $04, $86, $4f, $3e, $4a, $ce
    db $00, $47, $0a, $6f, $26, $00, $01, $40
    db $db, $09, $7e, $d5, $f5, $33, $d5, $cd
    db $3e, $59, $e8, $03, $7b, $d1, $83, $4f
    db $3e, $00, $8a, $47, $f8, $04, $7e, $d6
    db $05, $28, $13, $3e, $58, $f8, $04, $86
    db $5f, $3e, $5b, $ce, $00, $57, $1a, $02
    db $59, $50, $13, $34, $18, $c1, $c5, $cd
    db $74, $59, $e1, $4b, $42, $fa, $7f, $da
    db $b7, $28, $21, $3e, $08, $f5, $33, $11
    db $5d, $5b, $d5, $c5, $cd, $56, $59, $e8
    db $05, $01, $00, $da, $0a, $b7, $28, $05
    db $03, $12, $13, $18, $f7, $d5, $cd, $74
    db $59, $e1, $4b, $42, $3e, $03, $f5, $33
    db $11, $65, $5b, $d5, $c5, $cd, $56, $59
    db $e8, $05, $4b, $42, $f0, $fb, $b7, $28
    db $04, $3e, $31, $02, $03, $d1, $c5, $03
    db $f8, $02, $79, $22, $70, $f0, $fb, $b7
    db $28, $05, $23, $36, $32, $18, $04, $f8
    db $04, $36, $38, $f8, $04, $7e, $e1, $e5
    db $77, $f8, $02, $2a, $5f, $56, $d5, $cd
    db $74, $59, $e1, $4b, $42, $fa, $3a, $db
    db $b7, $28, $15, $3e, $07, $f5, $33, $11
    db $68, $5b, $d5, $c5, $cd, $56, $59, $e8
    db $05, $d5, $cd, $74, $59, $e1, $4b, $42
    db $fa, $57, $db, $fe, $02, $30, $1e, $3e
    db $09, $f5, $33, $11, $6f, $5b, $d5, $c5
    db $cd, $56, $59, $e8, $05, $4b, $42, $fa
    db $57, $db, $c6, $30, $02, $03, $c5, $cd
    db $74, $59, $e1, $4b, $42, $af, $f5, $33
    db $c5, $3e, $01, $f5, $33, $cd, $90, $49
    db $e8, $04, $4b, $42, $fa, $f6, $db, $b7
    db $28, $15, $3e, $06, $f5, $33, $11, $78
    db $5b, $d5, $c5, $cd, $56, $59, $e8, $05
    db $d5, $cd, $74, $59, $e1, $4b, $42, $69
    db $60, $7c, $d6, $da, $30, $05, $3e, $20
    db $22, $18, $f6, $11, $40, $5b, $d5, $cd
    db $7d, $52, $e1, $cd, $91, $4a, $3e, $0a
    db $f5, $33, $11, $00, $db, $d5, $11, $0f
    db $ca, $d5, $cd, $26, $19, $e8, $05, $7b
    db $b7, $20, $1a, $11, $00, $02, $d5, $11
    db $00, $d8, $d5, $cd, $18, $53, $e8, $04
    db $d5, $cd, $91, $4a, $01, $0f, $ca, $c5
    db $cd, $a1, $19, $e1, $d1, $e8, $05, $c9
    db $2f, $45, $5a, $47, $42, $2e, $43, $46
    db $47, $00, $46, $4c, $41, $55, $4e, $43
    db $48, $3d, $52, $54, $43, $3d, $32, $30
    db $2d, $2d, $20, $3a, $3a, $4c, $41, $53
    db $54, $52, $4f, $4d, $3d, $55, $49, $3d
    db $52, $54, $43, $53, $44, $3d, $30, $41
    db $55, $54, $4f, $53, $41, $56, $45, $3d
    db $54, $41, $47, $53, $3d, $30, $e8, $fb
    db $f8, $0a, $3a, $b6, $28, $5a, $f8, $04
    db $36, $00, $f8, $07, $2a, $4f, $46, $0a
    db $fe, $2f, $28, $09, $f8, $04, $36, $01
    db $21, $00, $da, $36, $2f, $f8, $04, $3a
    db $2b, $22, $af, $22, $77, $f8, $02, $3a
    db $2b, $22, $36, $da, $f8, $03, $5d, $54
    db $f8, $09, $1a, $13, $96, $23, $1a, $9e
    db $30, $1d, $f8, $02, $7e, $d6, $78, $30
    db $16, $34, $23, $79, $86, $23, $5f, $78
    db $8e, $57, $1a, $e1, $e5, $77, $f8, $03
    db $34, $20, $d2, $23, $34, $18, $ce, $e1
    db $36, $00, $e5, $21, $7f, $da, $36, $01
    db $e8, $05, $c9, $3b, $3b, $f8, $04, $2a
    db $4f, $46, $0a, $fe, $2f, $28, $04, $1e
    db $00, $18, $4b, $f8, $00, $af, $22, $16
    db $01, $72, $1e, $01, $7b, $3c, $20, $03
    db $5f, $18, $3b, $6b, $26, $00, $09, $7e
    db $b7, $28, $24, $fe, $20, $38, $04, $fe
    db $ff, $20, $04, $1e, $00, $18, $27, $fe
    db $2f, $20, $06, $53, $14, $f8, $00, $36
    db $00, $fe, $2e, $20, $04, $f8, $00, $36
    db $01, $1c, $f8, $01, $73, $18, $cd, $7a
    db $f8, $01, $96, $30, $07, $2b, $7e, $b7
    db $1e, $01, $20, $02, $1e, $00, $33, $33
    db $c9, $cd, $51, $53, $1e, $00, $3e, $78
    db $93, $3e, $00, $17, $47, $cb, $40, $20
    db $0d, $21, $a6, $c2, $16, $00, $19, $7e
    db $b7, $28, $03, $1c, $18, $e8, $7b, $4f
    db $b7, $28, $24, $cb, $40, $20, $20, $06
    db $00, $78, $91, $30, $11, $58, $16, $da
    db $78, $c6, $a6, $6f, $3e, $00, $ce, $c2
    db $67, $7e, $12, $04, $18, $eb, $06, $da
    db $af, $02, $21, $7f, $da, $36, $01, $fa
    db $3a, $db, $b7, $20, $08, $21, $4c, $00
    db $e5, $cd, $1f, $4c, $e1, $cd, $b2, $4d
    db $c3, $92, $59, $11, $a4, $c4, $d5, $cd
    db $e3, $5b, $e1, $7b, $b7, $28, $06, $21
    db $fb, $db, $36, $01, $c9, $cd, $51, $53
    db $fa, $7f, $da, $b7, $28, $2f, $11, $00
    db $da, $d5, $cd, $e3, $5b, $e1, $7b, $b7
    db $28, $23, $0e, $00, $69, $26, $00, $11
    db $a4, $c4, $19, $59, $16, $da, $1a, $77
    db $1a, $b7, $28, $03, $0c, $18, $ed, $3e
    db $03, $f5, $33, $cd, $61, $4a, $33, $21
    db $fb, $db, $36, $01, $c9, $21, $01, $0f
    db $e5, $3e, $12, $f5, $33, $11, $0f, $5d
    db $d5, $af, $0f, $f5, $af, $0f, $f5, $af
    db $0f, $f5, $cd, $58, $5d, $e8, $0b, $cd
    db $88, $06, $cd, $4a, $3a, $cb, $6b, $28
    db $f6, $21, $fb, $db, $36, $00, $c9, $28
    db $6e, $6f, $6e, $65, $29, $00, $21, $fb
    db $db, $36, $00, $fa, $fd, $db, $b7, $c0
    db $01, $46, $5d, $1e, $00, $21, $a5, $c3
    db $16, $00, $19, $56, $6b, $26, $00, $09
    db $7e, $92, $c0, $1c, $7b, $d6, $07, $38
    db $ec, $11, $a5, $c3, $d5, $cd, $e3, $5b
    db $e1, $7b, $ea, $fb, $db, $c9, $2f, $53
    db $41, $56, $45, $52, $2f

    rst RST_38
    rst RST_38
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
    db $f8, $09, $3a, $b6, $20, $24, $21, $c2
    db $db, $3e, $d0, $22, $36, $db, $2e, $ce
    db $36, $01, $cd, $60, $72, $21, $da, $db
    db $2a, $b6, $c8, $21, $c2, $db, $3e, $da
    db $22, $36, $db, $2e, $ce, $36, $01, $c3
    db $60, $72, $fa, $3f, $db, $fe, $02, $20
    db $0a, $cd, $e9, $5d, $21, $d9, $db, $36
    db $83, $18, $0a, $21, $da, $db, $af, $22
    db $77, $2e, $d9, $36, $8c, $11, $d0, $db
    db $f8, $08, $2a, $12, $13, $7e, $12, $21
    db $d6, $db, $36, $08, $2e, $d7, $36, $97
    db $f0, $fb, $b7, $28, $08, $2e, $d6, $36
    db $0c, $2e, $d7, $36, $9c, $01, $e6, $5d
    db $21, $3f, $db, $6e, $26, $00, $09, $7e
    db $87, $87, $87, $21, $d8, $db, $77, $2e
    db $c2, $3e, $d0, $22, $36, $db, $2e, $ce
    db $36, $00, $cd, $60, $72, $fa, $3f, $db
    db $fe, $02, $ca, $e9, $5d, $c9, $0e, $07
    db $09, $0e, $0a, $11, $d0, $db, $1a, $47
    db $21, $0a, $00, $19, $7e, $12, $70, $0d
    db $13, $79, $b7, $20, $f1, $c9

    rst RST_38
    rst RST_38

TabStrip12::
    db $e8, $d3, $af, $0f, $f5, $af, $f5, $33
    db $cd, $91, $27, $e8, $03, $f8, $33, $7e
    db $d6, $03, $3e, $01, $28, $01, $af, $4f
    db $f8, $33, $7e, $b7, $20, $14, $c5, $21
    db $13, $01, $e5, $3e, $9f, $f5, $33, $af
    db $0f, $f5, $cd, $ba, $27, $e8, $05, $c1
    db $18, $2a, $79, $b7, $28, $14, $c5, $21
    db $8f, $01, $e5, $21, $0d, $9f, $e5, $af
    db $f5, $33, $cd, $ba, $27, $e8, $05, $c1
    db $18, $12, $c5, $21, $8f, $01, $e5, $3e
    db $9f, $f5, $33, $af, $0f, $f5, $cd, $ba
    db $27, $e8, $05, $c1, $f8, $33, $7e, $b7
    db $20, $2d, $fa, $fe, $db, $b7, $28, $27
    db $21, $03, $00, $e5, $af, $f5, $33, $cd
    db $91, $27, $e8, $03, $af, $0f, $f5, $af
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
    db $e5, $af, $f5, $33, $cd, $91, $27, $e8
    db $03, $18, $0d, $af, $0f, $f5, $af, $3e
    db $03, $f5, $33, $cd, $91, $27, $e8, $03
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
    db $91, $27, $e8, $03, $21, $0c, $01, $e5
    db $21, $0c, $9f, $e5, $af, $f5, $33, $cd
    db $ba, $27, $e8, $05, $af, $0f, $f5, $af
    db $3e, $03, $f5, $33, $cd, $91, $27, $e8
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

FillRect::
    db $fa, $23, $d7, $b7, $28, $1f, $fa, $25
    db $d7, $47, $fa, $26, $d7, $57, $fa, $27
    db $d7, $4f, $5f, $cd, $9c, $23, $fa, $28
    db $d7, $47, $fa, $27, $d7, $b8, $c8, $3c
    db $ea, $27, $d7, $18, $e1, $fa, $34, $d7
    db $47, $af, $cb, $40, $28, $01, $2f, $ea
    db $f3, $db, $af, $cb, $48, $28, $01, $2f
    db $ea, $f4, $db, $fa, $25, $d7, $e6, $07
    db $47, $3e, $ff, $04, $18, $02, $cb, $3f
    db $05, $20, $fb, $ea, $f0, $db, $fa, $26
    db $d7, $e6, $07, $2f, $c6, $08, $47, $3e
    db $ff, $04, $18, $01, $87, $05, $20, $fc
    db $ea, $f1, $db, $fa, $25, $d7, $cb, $3f
    db $cb, $3f, $cb, $3f, $47, $fa, $26, $d7
    db $cb, $3f, $cb, $3f, $cb, $3f, $90, $20
    db $12, $fa, $f1, $db, $47, $fa, $f0, $db
    db $a0, $ea, $f0, $db, $3e, $ff, $ea, $f2
    db $db, $18, $04, $3d, $ea, $f2, $db, $fa
    db $27, $d7, $5f, $16, $00, $21, $bb, $2f
    db $19, $19, $2a, $66, $6f, $fa, $25, $d7
    db $e6, $f8, $5f, $19, $19, $fa, $f0, $db
    db $cd, $a6, $70, $fa, $f2, $db, $fe, $ff
    db $ca, $96, $70, $b7, $ca, $90, $70, $ea
    db $f5, $db, $fa, $f3, $db, $57, $fa, $f4
    db $db, $5f, $01, $0f, $00, $f0, $40, $cb
    db $7f, $20, $0c, $fa, $f5, $db, $72, $23
    db $73, $09, $3d, $20, $f9, $18, $79, $fa
    db $f5, $db, $fe, $05, $38, $59, $f3, $f0
    db $41, $e6, $03, $fe, $01, $20, $0a, $f0
    db $44, $fe, $90, $38, $04, $fe, $98, $38
    db $25, $f0, $44, $fe, $8f, $38, $11, $fb
    db $f0, $44, $fe, $8f, $38, $d9, $fe, $91
    db $38, $f6, $fe, $97, $38, $d1, $18, $f0
    db $f0, $41, $e6, $03, $fe, $03, $20, $f8
    db $f0, $41, $e6, $03, $20, $fa, $72, $23
    db $73, $09, $72, $23, $73, $09, $72, $23
    db $73, $09, $72, $23, $73, $09, $72, $23
    db $73, $09, $fb, $fa, $f5, $db, $d6, $05
    db $ea, $f5, $db, $20, $a2, $18, $19, $b7
    db $28, $16, $f3, $f0, $41, $cb, $4f, $20
    db $fa, $72, $23, $7b, $fb, $77, $09, $fa
    db $f5, $db, $3d, $ea, $f5, $db, $18, $e7
    db $fa, $f1, $db, $cd, $a6, $70, $fa, $28
    db $d7, $47, $fa, $27, $d7, $b8, $c8, $3c
    db $ea, $27, $d7, $c3, $cf, $6f, $47, $2f
    db $4f, $fa, $f3, $db, $a0, $57, $fa, $f4
    db $db, $a0, $5f, $f3, $f0, $41, $cb, $4f
    db $20, $fa, $7e, $a1, $b2, $22, $7e, $a1
    db $b3, $fb, $77, $7d, $c6, $0f, $6f, $d0
    db $24, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    db $e8, $fc, $f8, $0d, $7e, $d6, $02, $38
    db $03, $7e, $18, $0c, $f8, $0d, $7e, $b7
    db $28, $05, $fa, $d8, $69, $18, $01, $af
    db $f8, $03, $77, $f0, $f9, $4f, $b7, $28
    db $05, $3e, $a0, $91, $30, $02, $0e, $a0
    db $f8, $0c, $7e, $b7, $28, $05, $3e, $28
    db $96, $30, $04, $f8, $0c, $36, $28, $f8
    db $02, $36, $ff, $06, $00, $78, $f8, $0c
    db $96, $30, $78, $2b, $2b, $2a, $80, $5f
    db $7e, $ce, $00, $57, $1a, $57, $b7, $28
    db $6a, $c5, $d5, $33, $cd, $00, $72, $33
    db $f8, $02, $7b, $22, $23, $c1, $7e, $3c
    db $28, $14, $c5, $f8, $02, $2a, $23, $f5
    db $33, $7e, $f5, $33, $cd, $bf, $71, $e1
    db $c1, $f8, $03, $7e, $93, $77, $f8, $03
    db $7e, $91, $30, $3f, $f8, $00, $2a, $22
    db $af, $32, $7e, $c6, $65, $5f, $3e, $00
    db $ce, $00, $57, $21, $78, $69, $19, $7e
    db $f8, $03, $86, $5f, $79, $93, $38, $23
    db $f8, $0e, $2a, $80, $5f, $7e, $ce, $00
    db $57, $f8, $03, $3a, $2b, $12, $2a, $23
    db $c6, $78, $5f, $3e, $00, $ce, $69, $57
    db $1a, $86, $77, $f8, $00, $2a, $23, $77
    db $04, $18, $82, $58, $e8, $04, $c9, $f8
    db $03, $4e, $06, $00, $21, $ca, $00, $09
    db $11, $78, $69, $19, $4e, $79, $b7, $20
    db $02, $5f, $c9, $f8, $02, $7e, $87, $6f
    db $26, $00, $11, $a7, $6a, $19, $2a, $66
    db $59, $cb, $3b, $cb, $3b, $16, $00, $6f
    db $19, $11, $78, $69, $19, $5e, $79, $e6
    db $03, $87, $47, $7b, $04, $18, $02, $cb
    db $3f, $05, $20, $fb, $e6, $03, $5f, $c9
    db $f8, $02, $7e, $4f, $d6, $20, $38, $0a
    db $7e, $d6, $80, $30, $05, $79, $c6, $e0
    db $5f, $c9, $f8, $02, $7e, $d6, $c0, $38
    db $0a, $3e, $c4, $96, $38, $05, $79, $c6
    db $a0, $5f, $c9, $1e, $1f, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

Marquee::
    db $e8, $d6, $21, $ce, $db, $4e, $21, $c2
    db $db, $2a, $66, $6f, $c5, $e5, $11, $c4
    db $db, $d5, $cd, $70, $74, $e8, $04, $c1
    db $79, $b7, $c2, $17, $73, $f8, $29, $36
    db $00, $f8, $29, $7e, $d6, $fc, $30, $13
    db $21, $c4, $db, $2a, $46, $f8, $29, $86
    db $4f, $30, $01, $04, $0a, $b7, $28, $03
    db $34, $18, $e6, $11, $c6, $db, $f8, $29
    db $7e, $12, $21, $c7, $db, $36, $00, $2e
    db $c8, $36, $00, $f0, $fa, $2e, $c9, $77
    db $fa, $cd, $db, $cb, $f7, $2e, $cd, $77
    db $f0, $fb, $4f, $fa, $cb, $db, $3c, $f8
    db $28, $77, $79, $b7, $28, $34, $7e, $e0
    db $f9, $fa, $ca, $db, $21, $c4, $db, $4e
    db $23, $46, $21, $00, $00, $39, $e5, $67
    db $2e, $00, $e5, $c5, $af, $0f, $f5, $af
    db $0f, $f5, $cd, $00, $71, $e8, $0a, $7b
    db $f8, $29, $96, $38, $08, $fa, $cd, $db
    db $cb, $b7, $ea, $cd, $db, $af, $e0, $f9
    db $18, $18, $21, $ca, $db, $4e, $f8, $28
    db $2a, $91, $cb, $37, $07, $e6, $1f, $96
    db $38, $08, $fa, $cd, $db, $cb, $b7, $ea
    db $cd, $db, $cd, $7c, $73, $18, $54, $0d
    db $20, $4e, $f0, $fa, $4f, $21, $c9, $db
    db $96, $21, $c9, $db, $71, $2e, $cd, $cb
    db $76, $28, $40, $fe, $65, $38, $02, $3e
    db $64, $21, $c8, $db, $86, $21, $c8, $db
    db $77, $fa, $c8, $db, $2e, $c7, $4e, $0c
    db $0d, $0e, $3c, $28, $02, $0e, $14, $91
    db $38, $21, $21, $c8, $db, $36, $00, $2e
    db $c7, $4e, $0c, $21, $c7, $db, $71, $fa
    db $c6, $db, $c6, $03, $47, $79, $90, $38
    db $02, $36, $00, $cd, $7c, $73, $18, $03
    db $cd, $7c, $73, $21, $c2, $db, $2a, $4f
    db $46, $11, $c4, $db, $d5, $c5, $cd, $70
    db $74, $e8, $2e, $c9, $e8, $d0, $21, $00
    db $00, $39, $4d, $44, $11, $c4, $db, $1a
    db $f8, $28, $22, $13, $1a, $77, $fa, $c7
    db $db, $f8, $2c, $77, $fa, $c6, $db, $f8
    db $2a, $77, $f8, $2b, $36, $00, $fa, $cd
    db $db, $cb, $77, $28, $06, $f8, $2a, $2a
    db $c6, $03, $77, $f8, $2d, $3e, $27, $22
    db $79, $22, $70, $f8, $2e, $2a, $5f, $3a
    db $57, $34, $20, $02, $23, $34, $f8, $2c
    db $3a, $2b, $96, $30, $11, $2b, $2b, $7e
    db $f8, $2c, $86, $2b, $2b, $2b, $4f, $7e
    db $ce, $00, $47, $0a, $18, $02, $3e, $20
    db $12, $f8, $2c, $34, $3a, $96, $20, $04
    db $f8, $2c, $36, $00, $f8, $2d, $35, $7e
    db $20, $c9, $23, $2a, $66, $6f, $36, $00
    db $21, $cd, $db, $4e, $79, $0f, $0f, $e6
    db $03, $47, $79, $e6, $03, $c5, $33, $f5
    db $33, $cd, $84, $74, $e1, $f0, $fb, $4f
    db $fa, $cb, $db, $3c, $0c, $0d, $28, $28
    db $e0, $f9, $fa, $cc, $db, $21, $ca, $db
    db $46, $f5, $33, $c5, $33, $af, $f5, $33
    db $21, $03, $00, $39, $e5, $af, $0f, $f5
    db $af, $0f, $f5, $af, $0f, $f5, $cd, $00
    db $75, $e8, $0b, $af, $e0, $f9, $18, $2d
    db $21, $cc, $db, $4e, $cb, $39, $cb, $39
    db $cb, $39, $21, $ca, $db, $6e, $5d, $cb
    db $3b, $cb, $3b, $cb, $3b, $95, $cb, $37
    db $07, $e6, $1f, $61, $e5, $33, $63, $e5
    db $33, $f5, $33, $21, $03, $00, $39, $e5
    db $cd, $b7, $08, $e8, $05, $21, $03, $00
    db $e5, $cd, $84, $74, $e1, $e8, $30, $c9
    db $f8, $04, $2a, $4f, $46, $f8, $02, $2a
    db $5f, $56, $2e, $0a, $0a, $03, $12, $13
    db $2d, $20, $f9, $c9, $fa, $cd, $db, $07
    db $30, $0b, $f8, $03, $3a, $57, $5e, $d5
    db $cd, $90, $02, $e1, $c9, $af, $f5, $33
    db $f8, $04, $3a, $57, $5e, $d5, $cd, $91
    db $27, $e8, $03, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    db $37, $01, $39, $7e, $d6, $90, $d2, $a1
    db $79, $21, $36, $01, $39, $3e, $0c, $22
    db $3e, $90, $96, $fe, $0c, $30, $02, $2b
    db $77, $21, $43, $01, $39, $7e, $d6, $02
    db $38, $03, $7e, $18, $0e, $21, $43, $01
    db $39, $7e, $b7, $28, $05, $fa, $d8, $69
    db $18, $01, $af, $21, $35, $01, $39, $77
    db $7e, $cb, $37, $07, $e6, $1f, $21, $24
    db $01, $39, $77, $f0, $f9, $4f, $b7, $28
    db $05, $3e, $a0, $91, $30, $02, $0e, $a0
    db $21, $35, $01, $39, $7e, $91, $d2, $a1
    db $79, $79, $c6, $07, $cb, $37, $07, $e6
    db $1f, $21, $24, $01, $39, $96, $23, $77
    db $79, $e6, $07, $28, $12, $79, $e6, $07
    db $01, $ff, $00, $3c, $18, $04, $cb, $28
    db $cb, $19, $3d, $20, $f9, $18, $02, $0e
    db $00, $21, $26, $01, $39, $71, $21, $35
    db $01, $39, $7e, $e6, $07, $28, $14, $21
    db $35, $01, $39, $7e, $e6, $07, $4f, $3e
    db $08, $91, $47, $3e, $ff, $87, $05, $20
    db $fc, $18, $01, $af, $21, $27, $01, $39
    db $77, $01, $bb, $2f, $21, $37, $01, $39
    db $5e, $16, $00, $6b, $62, $29, $09, $2a
    db $4f, $46, $21, $24, $01, $39, $2a, $23
    db $23, $23, $5f, $16, $00, $7b, $87, $cb
    db $12, $87, $cb, $12, $87, $cb, $12, $87
    db $cb, $12, $81, $22, $7a, $88, $77, $fa
    db $34, $d7, $21, $2a, $01, $39, $77, $fa
    db $35, $d7, $21, $2b, $01, $39, $77, $7e
    db $b7, $3e, $ff, $20, $01, $af, $21, $2c
    db $01, $39, $77, $fa, $d0, $d6, $b7, $20
    db $0f, $21, $2a, $01, $39, $2a, $b6, $fe
    db $03, $20, $05, $2b, $2a, $a6, $28, $03
    db $af, $18, $02, $3e, $01, $21, $2d, $01
    db $39, $77, $21, $25, $01, $39, $7e, $21
    db $2e, $01, $39, $77, $7e, $3c, $21, $37
    db $01, $39, $77, $7e, $4f, $87, $81, $47
    db $c5, $33, $21, $01, $00, $39, $e5, $cd
    db $1b, $7b, $e8, $03, $21, $2d, $01, $39
    db $7e, $b7, $28, $3c, $21, $36, $01, $39
    db $7e, $e6, $fc, $77, $7e, $b7, $ca, $a1
    db $79, $21, $27, $01, $39, $7e, $b7, $28
    db $27, $21, $2c, $01, $39, $7e, $f5, $33
    db $21, $28, $01, $39, $7e, $f5, $33, $21
    db $38, $01, $39, $7e, $f5, $33, $21, $2b
    db $01, $39, $2a, $5f, $56, $d5, $21, $05
    db $00, $39, $e5, $cd, $a7, $79, $e8, $07
    db $21, $fc, $00, $39, $e5, $21, $45, $01
    db $39, $3a, $57, $3a, $2b, $5f, $d5, $2a
    db $5f, $56, $d5, $af, $0f, $f5, $af, $0f
    db $f5, $cd, $00, $71, $e8, $0a, $21, $2f
    db $01, $39, $73, $21, $37, $01, $39, $36
    db $00, $21, $37, $01, $39, $7e, $21, $2f
    db $01, $39, $96, $d2, $4a, $78, $21, $37
    db $01, $39, $5e, $16, $00, $21, $fc, $00
    db $39, $19, $e5, $7d, $21, $36, $01, $39
    db $77, $e1, $7c, $21, $35, $01, $39, $32
    db $2a, $5f, $56, $1a, $4f, $21, $40, $01
    db $39, $7e, $21, $37, $01, $39, $86, $5f
    db $f5, $21, $43, $01, $39, $f1, $7e, $ce
    db $00, $57, $1a, $c5, $f5, $33, $cd, $f5
    db $7a, $33, $c1, $16, $00, $6b, $62, $29
    db $19, $29, $29, $29, $7d, $c6, $00, $47
    db $7c, $ce, $60, $21, $30, $01, $39, $70
    db $23, $77, $79, $cb, $37, $07, $e6, $1f
    db $21, $24, $01, $39, $96, $5f, $87, $83
    db $87, $87, $5f, $16, $00, $21, $00, $00
    db $39, $19, $45, $7c, $21, $32, $01, $39
    db $70, $23, $22, $79, $e6, $07, $22, $af
    db $32, $3e, $06, $96, $23, $3e, $00, $9e
    db $da, $2d, $78, $21, $34, $01, $39, $4e
    db $06, $00, $21, $7c, $77, $09, $09, $4e
    db $23, $66, $69, $e9, $8a, $77, $a2, $77
    db $ba, $77, $d1, $77, $e8, $77, $ff, $77
    db $16, $78, $21, $32, $01, $39, $2a, $5f
    db $56, $d5, $21, $32, $01, $39, $2a, $5f
    db $56, $d5, $cd, $2c, $7b, $e8, $04, $c3
    db $42, $78, $21, $32, $01, $39, $2a, $5f
    db $56, $d5, $21, $32, $01, $39, $2a, $5f
    db $56, $d5, $cd, $5b, $7b, $e8, $04, $c3
    db $42, $78, $21, $32, $01, $39, $2a, $5f
    db $56, $d5, $21, $32, $01, $39, $2a, $5f
    db $56, $d5, $cd, $8e, $7b, $e8, $04, $18
    db $71, $21, $32, $01, $39, $2a, $5f, $56
    db $d5, $21, $32, $01, $39, $2a, $5f, $56
    db $d5, $cd, $c5, $7b, $e8, $04, $18, $5a
    db $21, $32, $01, $39, $2a, $5f, $56, $d5
    db $21, $32, $01, $39, $2a, $5f, $56, $d5
    db $cd, $00, $7c, $e8, $04, $18, $43, $21
    db $32, $01, $39, $2a, $5f, $56, $d5, $21
    db $32, $01, $39, $2a, $5f, $56, $d5, $cd
    db $3f, $7c, $e8, $04, $18, $2c, $21, $32
    db $01, $39, $2a, $5f, $56, $d5, $21, $32
    db $01, $39, $2a, $5f, $56, $d5, $cd, $82
    db $7c, $e8, $04, $18, $15, $21, $32, $01
    db $39, $2a, $5f, $56, $d5, $21, $32, $01
    db $39, $2a, $5f, $56, $d5, $cd, $c9, $7c
    db $e8, $04, $21, $37, $01, $39, $34, $c3
    db $d9, $76, $21, $2d, $01, $39, $7e, $b7
    db $20, $2f, $2b, $2b, $3a, $57, $5e, $d5
    db $21, $28, $01, $39, $2a, $57, $3a, $2b
    db $5f, $d5, $7e, $f5, $33, $21, $3b, $01
    db $39, $7e, $f5, $33, $21, $2e, $01, $39
    db $2a, $5f, $56, $d5, $21, $08, $00, $39
    db $e5, $cd, $d6, $79, $e8, $0a, $c3, $a1
    db $79, $21, $00, $00, $39, $e5, $7d, $21
    db $33, $01, $39, $77, $e1, $7c, $21, $32
    db $01, $39, $77, $21, $2e, $01, $39, $7e
    db $3d, $21, $33, $01, $39, $77, $21, $37
    db $01, $39, $36, $00, $21, $28, $01, $39
    db $7e, $21, $34, $01, $39, $77, $21, $29
    db $01, $39, $7e, $21, $35, $01, $39, $77
    db $21, $37, $01, $39, $7e, $21, $25, $01
    db $39, $96, $d2, $a1, $79, $21, $31, $01
    db $39, $3a, $2b, $2b, $2b, $c6, $0c, $77
    db $f5, $21, $34, $01, $39, $f1, $7e, $ce
    db $00, $21, $2e, $01, $39, $77, $21, $26
    db $01, $39, $7e, $b7, $28, $76, $21, $33
    db $01, $39, $7e, $21, $37, $01, $39, $96
    db $20, $6a, $21, $2c, $01, $39, $7e, $f5
    db $33, $21, $27, $01, $39, $7e, $f5, $33
    db $21, $38, $01, $39, $3a, $2b, $f5, $33
    db $2a, $5f, $56, $d5, $21, $32, $01, $39
    db $2a, $5f, $56, $d5, $cd, $a7, $79, $e8
    db $07, $21, $30, $01, $39, $36, $00, $21
    db $30, $01, $39, $7e, $21, $36, $01, $39
    db $96, $30, $31, $21, $31, $01, $39, $3a
    db $86, $23, $23, $4f, $7e, $ce, $00, $47
    db $0a, $21, $2f, $01, $39, $22, $5e, $16
    db $00, $21, $0c, $00, $19, $5d, $54, $21
    db $31, $01, $39, $2a, $83, $5f, $7e, $8a
    db $57, $1a, $21, $2f, $01, $39, $b6, $23
    db $02, $34, $18, $c3, $21, $2c, $01, $39
    db $7e, $f5, $33, $21, $37, $01, $39, $3a
    db $2b, $f5, $33, $2a, $5f, $56, $d5, $21
    db $35, $01, $39, $2a, $5f, $56, $d5, $cd
    db $5e, $7d, $e8, $06, $21, $37, $01, $39
    db $34, $21, $2d, $01, $39, $7e, $21, $31
    db $01, $39, $77, $21, $2e, $01, $39, $7e
    db $21, $32, $01, $39, $22, $23, $7e, $c6
    db $10, $22, $7e, $ce, $00, $77, $c3, $b8
    db $78, $21, $38, $01, $39, $f9, $c9, $f8
    db $06, $7e, $f5, $33, $f8, $03, $2a, $5f
    db $2a, $57, $d5, $2a, $5f, $56, $d5, $cd
    db $14, $7d, $e8, $05, $0e, $00, $79, $f8
    db $06, $96, $d0, $f8, $02, $2a, $81, $5f
    db $7e, $ce, $00, $57, $1a, $f8, $08, $ae
    db $2b, $a6, $12, $0c, $18, $e8, $e8, $f0
    db $f8, $1a, $2a, $ae, $0f, $30, $04, $3e
    db $ff, $18, $01, $af, $f8, $00, $77, $f8
    db $1b, $4e, $cb, $41, $3e, $ff, $20, $01
    db $af, $f8, $01, $77, $f8, $1a, $7e, $a9
    db $cb, $4f, $3e, $ff, $20, $01, $af, $f8
    db $02, $77, $cb, $49, $3e, $ff, $20, $01
    db $af, $f8, $03, $77, $f8, $07, $36, $00
    db $f8, $12, $7e, $f8, $08, $77, $f8, $13
    db $7e, $f8, $09, $77, $f8, $14, $7e, $f8
    db $0a, $77, $f8, $15, $7e, $f8, $0b, $77
    db $f8, $07, $7e, $f8, $17, $96, $d2, $f2
    db $7a, $f8, $07, $7e, $b7, $28, $03, $af
    db $18, $03, $f8, $18, $7e, $f8, $0c, $77
    db $f8, $17, $7e, $3d, $f8, $07, $96, $20
    db $09, $f8, $0c, $7e, $f8, $19, $b6, $f8
    db $0c, $77, $f8, $0a, $7e, $f8, $0d, $32
    db $2b, $7e, $f8, $0e, $32, $2b, $7e, $2f
    db $f8, $04, $77, $f8, $0f, $36, $00, $f8
    db $0f, $7e, $f8, $16, $96, $30, $6c, $f8
    db $08, $7e, $f8, $0f, $86, $f5, $f8, $07
    db $f1, $22, $23, $23, $23, $7e, $ce, $00
    db $f8, $06, $32, $2a, $5f, $56, $1a, $77
    db $f8, $02, $a6, $f8, $05, $77, $3a, $2b
    db $ae, $23, $23, $77, $3a, $a6, $23, $22
    db $7e, $f8, $00, $a6, $f8, $06, $77, $f8
    db $01, $ae, $f8, $06, $77, $3a, $2b, $a6
    db $23, $23, $32, $2a, $57, $5e, $d5, $f8
    db $0e, $2a, $f5, $33, $2a, $5f, $56, $d5
    db $cd, $3e, $7d, $e8, $05, $f8, $0d, $7e
    db $c6, $02, $22, $7e, $ce, $00, $32, $7e
    db $e6, $0f, $20, $0a, $f8, $0d, $7e, $c6
    db $30, $22, $7e, $ce, $01, $77, $f8, $0f
    db $34, $18, $8c, $f8, $07, $34, $23, $7e
    db $c6, $0c, $22, $7e, $ce, $00, $22, $7e
    db $c6, $10, $22, $7e, $ce, $00, $77, $c3
    db $28, $7a, $e8, $10, $c9, $f8, $02, $7e
    db $4f, $d6, $20, $38, $0a, $7e, $d6, $80
    db $30, $05, $79, $c6, $e0, $5f, $c9, $f8
    db $02, $7e, $d6, $c0, $38, $0a, $3e, $c4
    db $96, $38, $05, $79, $c6, $a0, $5f, $c9
    db $1e, $1f, $c9, $f8, $04, $46, $f8, $02
    db $2a, $66, $6f, $af, $22, $22, $22, $22
    db $05, $20, $f9, $c9, $f8, $02, $2a, $5f
    db $56, $23, $2a, $66, $6f, $7d, $c6, $0c
    db $6f, $8c, $95, $67, $06, $0c, $1a, $13
    db $4f, $1a, $13, $b6, $77, $7d, $d6, $0c
    db $6f, $7c, $de, $00, $67, $7e, $b1, $77
    db $7d, $c6, $0d, $6f, $8c, $95, $67, $05
    db $20, $e4, $c9, $f8, $02, $2a, $5f, $56
    db $23, $2a, $66, $6f, $7d, $c6, $0c, $6f
    db $8c, $95, $67, $06, $0c, $1a, $13, $4f
    db $1a, $13, $cb, $39, $cb, $1f, $b6, $77
    db $7d, $d6, $0c, $6f, $7c, $de, $00, $67
    db $7e, $b1, $77, $7d, $c6, $0d, $6f, $8c
    db $95, $67, $05, $20, $e0, $c9, $f8, $02
    db $2a, $5f, $56, $23, $2a, $66, $6f, $7d
    db $c6, $0c, $6f, $8c, $95, $67, $06, $0c
    db $1a, $13, $4f, $1a, $13, $cb, $39, $cb
    db $1f, $cb, $39, $cb, $1f, $b6, $77, $7d
    db $d6, $0c, $6f, $7c, $de, $00, $67, $7e
    db $b1, $77, $7d, $c6, $0d, $6f, $8c, $95
    db $67, $05, $20, $dc, $c9, $f8, $02, $2a
    db $5f, $56, $23, $2a, $66, $6f, $7d, $c6
    db $0c, $6f, $8c, $95, $67, $06, $0c, $1a
    db $13, $4f, $1a, $13, $cb, $39, $cb, $1f
    db $cb, $39, $cb, $1f, $cb, $39, $cb, $1f
    db $b6, $77, $7d, $d6, $0c, $6f, $7c, $de
    db $00, $67, $7e, $b1, $77, $7d, $c6, $0d
    db $6f, $8c, $95, $67, $05, $20, $d8, $c9
    db $f8, $02, $2a, $5f, $56, $23, $2a, $66
    db $6f, $7d, $c6, $0c, $6f, $8c, $95, $67
    db $06, $0c, $1a, $13, $4f, $1a, $13, $cb
    db $39, $cb, $1f, $cb, $39, $cb, $1f, $cb
    db $39, $cb, $1f, $cb, $39, $cb, $1f, $b6
    db $77, $7d, $d6, $0c, $6f, $7c, $de, $00
    db $67, $7e, $b1, $77, $7d, $c6, $0d, $6f
    db $8c, $95, $67, $05, $20, $d4, $c9, $f8
    db $02, $2a, $5f, $56, $23, $2a, $66, $6f
    db $7d, $c6, $0c, $6f, $8c, $95, $67, $06
    db $0c, $1a, $13, $4f, $1a, $13, $cb, $39
    db $cb, $1f, $cb, $39, $cb, $1f, $cb, $39
    db $cb, $1f, $cb, $39, $cb, $1f, $cb, $39
    db $cb, $1f, $b6, $77, $7d, $d6, $0c, $6f
    db $7c, $de, $00, $67, $7e, $b1, $77, $7d
    db $c6, $0d, $6f, $8c, $95, $67, $05, $20
    db $d0, $c9, $f8, $02, $2a, $5f, $56, $23
    db $2a, $66, $6f, $7d, $c6, $0c, $6f, $8c
    db $95, $67, $06, $0c, $1a, $13, $4f, $1a
    db $13, $cb, $39, $cb, $1f, $cb, $39, $cb
    db $1f, $cb, $39, $cb, $1f, $cb, $39, $cb
    db $1f, $cb, $39, $cb, $1f, $cb, $39, $cb
    db $1f, $b6, $77, $7d, $d6, $0c, $6f, $7c
    db $de, $00, $67, $7e, $b1, $77, $7d, $c6
    db $0d, $6f, $8c, $95, $67, $05, $20, $cc
    db $c9, $f8, $02, $2a, $5f, $56, $23, $2a
    db $66, $6f, $7d, $c6, $0c, $6f, $8c, $95
    db $67, $06, $0c, $1a, $13, $4f, $1a, $13
    db $cb, $39, $cb, $1f, $cb, $39, $cb, $1f
    db $cb, $39, $cb, $1f, $cb, $39, $cb, $1f
    db $cb, $39, $cb, $1f, $cb, $39, $cb, $1f
    db $cb, $39, $cb, $1f, $b6, $77, $7d, $d6
    db $0c, $6f, $7c, $de, $00, $67, $7e, $b1
    db $77, $7d, $c6, $0d, $6f, $8c, $95, $67
    db $05, $20, $c8, $c9, $f8, $06, $46, $f8
    db $02, $2a, $5f, $56, $f8, $04, $2a, $66
    db $6f, $f3, $f0, $41, $cb, $4f, $20, $fa
    db $1a, $fb, $22, $13, $13, $7b, $e6, $0f
    db $20, $08, $7b, $c6, $30, $5f, $7a, $ce
    db $01, $57, $05, $20, $e4, $c9, $f8, $02
    db $2a, $5f, $2a, $57, $4e, $23, $46, $23
    db $6e, $cd, $fd, $06, $f0, $41, $cb, $4f
    db $20, $fa, $1a, $a1, $b0, $12, $1c, $1a
    db $a1, $b5, $12, $c3, $06, $07, $f8, $07
    db $4e, $f8, $06, $7e, $cb, $3f, $cb, $3f
    db $47, $f8, $04, $2a, $5f, $56, $f8, $02
    db $2a, $66, $6f, $f3, $f0, $41, $e6, $03
    db $fe, $01, $20, $0c, $f0, $44, $fe, $90
    db $38, $06, $fe, $98, $30, $02, $18, $25
    db $f0, $44, $fe, $8f, $38, $11, $fb, $f0
    db $44, $fe, $8f, $38, $de, $fe, $91, $38
    db $f6, $fe, $97, $38, $d6, $18, $f0, $f0
    db $41, $e6, $03, $fe, $03, $20, $f8, $f0
    db $41, $e6, $03, $20, $fa, $2a, $a9, $12
    db $1c, $12, $13, $2a, $a9, $12, $1c, $12
    db $13, $2a, $a9, $12, $1c, $12, $13, $2a
    db $a9, $12, $1c, $12, $13, $fb, $7b, $e6
    db $0f, $20, $08, $7b, $c6, $30, $5f, $7a
    db $ce, $01, $57, $05, $20, $9d, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    db $e8, $d3, $f8, $2b, $36, $27, $f8, $37
    db $7e, $b7, $20, $0b, $f8, $01, $36, $c0
    db $f8, $37, $36, $13, $c3, $63, $7f, $f8
    db $35, $2a, $5f, $56, $d5, $cd, $08, $04
    db $e1, $7b, $fe, $27, $30, $03, $f8, $2b
    db $77, $f8, $2c, $36, $ff, $1e, $00, $7b
    db $d6, $fe, $30, $17, $f8, $35, $2a, $83
    db $4f, $7e, $ce, $00, $47, $0a, $b7, $28
    db $0a, $fe, $2e, $20, $03, $f8, $2c, $73
    db $1c, $18, $e4, $f8, $01, $36, $c3, $f8
    db $2c, $7e, $3c, $ca, $5f, $7f, $7b, $f8
    db $2c, $96, $3d, $f8, $00, $77, $f8, $2c
    db $4e, $06, $00, $59, $50, $13, $f8, $35
    db $2a, $83, $5f, $7e, $8a, $57, $1a, $e6
    db $df, $f8, $2c, $77, $59, $50, $13, $13
    db $f8, $35, $2a, $83, $5f, $7e, $8a, $57
    db $1a, $e6, $df, $5f, $f8, $00, $7e, $d6
    db $03, $3e, $01, $28, $01, $af, $57, $03
    db $03, $03, $f8, $35, $2a, $81, $4f, $7e
    db $88, $47, $f8, $2c, $7e, $d6, $47, $20
    db $23, $7b, $d6, $42, $20, $1e, $f8, $00
    db $7e, $d6, $02, $20, $06, $f8, $01, $36
    db $c1, $18, $2c, $7a, $b7, $28, $28, $0a
    db $cb, $af, $fe, $43, $20, $21, $f8, $01
    db $36, $c2, $18, $1b, $7a, $b7, $28, $17
    db $f8, $2c, $7e, $d6, $53, $20, $10, $7b
    db $d6, $41, $20, $0b, $0a, $cb, $af, $fe
    db $56, $20, $04, $f8, $01, $36, $c4, $f8
    db $37, $35, $7e, $f8, $02, $4d, $44, $f8
    db $01, $7e, $02, $f8, $2c, $36, $00, $f8
    db $2c, $3a, $96, $30, $23, $f8, $35, $7e
    db $f8, $2c, $86, $5f, $f5, $f8, $38, $f1
    db $7e, $ce, $00, $57, $1a, $5f, $b7, $28
    db $0f, $f8, $2c, $7e, $3c, $6f, $07, $9f
    db $67, $09, $73, $f8, $2c, $34, $18, $d7
    db $f8, $2c, $5e, $7b, $d6, $28, $30, $0a
    db $6b, $2c, $26, $00, $09, $36, $00, $1c
    db $18, $f1, $f0, $fb, $b7, $20, $29, $f8
    db $01, $5d, $54, $c5, $f8, $3b, $7e, $f5
    db $33, $21, $01, $00, $e5, $d5, $cd, $b7
    db $08, $e8, $05, $c1, $03, $f8, $39, $3a
    db $2b, $57, $1e, $01, $d5, $7e, $f5, $33
    db $c5, $cd, $b7, $08, $e8, $05, $18, $17
    db $f8, $39, $7e, $f5, $33, $af, $0f, $f5
    db $c5, $af, $0f, $f5, $af, $0f, $f5, $af
    db $0f, $f5, $cd, $00, $75, $e8, $0b, $e8
    db $2d, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
