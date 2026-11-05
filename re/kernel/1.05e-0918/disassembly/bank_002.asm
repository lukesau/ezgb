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
    db $03, $f5, $33, $cd, $91, $44, $33, $fa
    db $f9, $db, $b7, $20, $27, $21, $16, $a4
    db $4e, $fa, $14, $a4, $fe, $54, $20, $18
    db $fa, $15, $a4, $fe, $48, $20, $11, $79
    db $d6, $08, $30, $0c, $21, $17, $a4, $46
    db $79, $2f, $90, $20, $03, $79, $18, $01
    db $af, $ea, $f7, $db, $cd, $98, $49, $e1
    db $d5, $21, $f7, $db, $4e, $fa, $f9, $db
    db $b7, $28, $37, $21, $14, $a4, $36, $54
    db $2e, $15, $36, $48, $2e, $16, $71, $79
    db $2f, $2e, $17, $77, $06, $00, $78, $c6
    db $04, $c6, $14, $f5, $f8, $04, $f1, $22
    db $3e, $00, $ce, $a4, $77, $f8, $00, $2a
    db $80, $5f, $2a, $ce, $00, $57, $1a, $5e
    db $23, $66, $6b, $77, $04, $78, $d6, $08
    db $38, $dc, $21, $00, $40, $36, $00, $c5
    db $af, $f5, $33, $cd, $91, $44, $33, $c1
    db $79, $d6, $07, $20, $04, $3e, $27, $18
    db $08, $79, $b7, $3e, $1b, $20, $02, $3e
    db $e4, $e0, $47, $e0, $48, $2f, $e0, $49
    db $d1, $d5, $d5, $11, $68, $ff, $d5, $cd
    db $ab, $44, $e8, $04, $d1, $d5, $d5, $11
    db $6a, $ff, $d5, $cd, $ab, $44, $e8, $08
    db $c9, $21, $00, $7f, $36, $e1, $2e, $10
    db $36, $e2, $2e, $20, $36, $e3, $11, $c0
    db $7f, $f8, $02, $7e, $12, $21, $f0, $7f
    db $36, $e4, $c9, $e8, $fd, $f8, $01, $36
    db $00, $f8, $01, $7e, $e6, $07, $f8, $07
    db $86, $23, $4f, $3e, $00, $8e, $47, $0a
    db $f8, $00, $22, $23, $36, $08, $f8, $02
    db $4e, $35, $7e, $79, $b7, $20, $06, $3e
    db $01, $e0, $f8, $18, $28, $f8, $05, $2a
    db $4f, $46, $f8, $01, $7e, $02, $f0, $41
    db $cb, $4f, $20, $fa, $03, $f8, $00, $7e
    db $02, $f0, $41, $cb, $4f, $20, $fa, $0a
    db $f8, $00, $96, $20, $d1, $f8, $01, $34
    db $7e, $d6, $40, $38, $b4, $e8, $03, $c9

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
    db $f7, $db, $fe, $06, $c8, $11, $c6, $49
    db $fe, $07, $c8, $87, $87, $87, $c6, $60
    db $5f, $ce, $49, $93, $57, $c9, $00, $00
    db $ef, $1b, $80, $61, $ff, $7f

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    db $fa, $fc, $db, $b7, $ca, $4f, $54, $fe
    db $01, $ca, $ab, $5a, $fe, $02, $20, $08
    db $af, $f5, $33, $cd, $80, $4c, $33, $c9
    db $fe, $06, $20, $09, $3e, $01, $f5, $33
    db $cd, $80, $4c, $33, $c9, $fe, $07, $20
    db $13, $fa, $3a, $db, $b7, $c0, $cd, $4f
    db $54, $21, $4c, $00, $e5, $cd, $20, $4c
    db $e1, $c3, $ab, $5a, $fe, $04, $ca, $5a
    db $5d, $fe, $05, $ca, $b4, $5d, $fe, $08
    db $ca, $2f, $5e, $fe, $09, $c2, $f8, $4e
    db $cd, $ad, $4e, $7b, $b7, $28, $05, $21
    db $fd, $da, $36, $01, $21, $00, $40, $36
    db $00, $c9, $21, $00, $7f, $36, $e1, $2e
    db $10, $36, $e2, $2e, $20, $36, $e3, $11
    db $c0, $7f, $f8, $02, $7e, $12, $21, $f0
    db $7f, $36, $e4, $c9, $21, $00, $7f, $36
    db $e1, $2e, $10, $36, $e2, $2e, $20, $36
    db $e3, $2e, $d0, $36, $01, $2e, $f0, $36
    db $e4, $c9, $cd, $88, $06, $af, $f5, $33
    db $cd, $62, $4a, $33, $c9, $3e, $06, $f5
    db $33, $cd, $62, $4a, $33, $0e, $00, $69
    db $26, $00, $11, $08, $a0, $19, $46, $69
    db $26, $00, $11, $50, $db, $19, $70, $69
    db $26, $00, $11, $48, $db, $19, $3e, $de
    db $81, $5f, $3e, $4a, $ce, $00, $57, $1a
    db $a0, $77, $0c, $79, $d6, $07, $38, $d7
    db $af, $f5, $33, $cd, $62, $4a, $33, $c9
    db $06, $05, $03, $02, $01, $00, $7f, $7f
    db $3f, $3f, $07, $1f, $ff, $3b, $3e, $06
    db $f5, $33, $cd, $62, $4a, $33, $f8, $00
    db $36, $00, $f8, $00, $7e, $c6, $08, $4f
    db $3e, $00, $ce, $a0, $47, $f8, $03, $7e
    db $f8, $00, $86, $23, $23, $23, $23, $5f
    db $7e, $ce, $00, $57, $1a, $02, $f8, $00
    db $34, $7e, $d6, $07, $38, $dc, $cd, $7c
    db $4a, $af, $f5, $33, $cd, $62, $4a, $e1
    db $c9, $f8, $02, $7e, $e6, $0f, $fe, $0a
    db $38, $03, $1e, $00, $c9, $f8, $02, $7e
    db $cb, $37, $e6, $0f, $fe, $0a, $38, $03
    db $1e, $00, $c9, $f8, $03, $3a, $96, $3e
    db $00, $17, $ee, $01, $5f, $c9, $f8, $02
    db $2a, $4f, $46, $0a, $c5, $26, $59, $e5
    db $33, $f5, $33, $cd, $21, $4b, $e1, $7b
    db $c1, $b7, $20, $02, $5f, $c9, $69, $60
    db $23, $7e, $c5, $26, $59, $e5, $33, $f5
    db $33, $cd, $21, $4b, $e1, $7b, $c1, $b7
    db $20, $02, $5f, $c9, $69, $60, $23, $23
    db $7e, $c5, $26, $23, $e5, $33, $f5, $33
    db $cd, $21, $4b, $e1, $7b, $c1, $b7, $20
    db $02, $5f, $c9, $69, $60, $23, $23, $23
    db $56, $c5, $d5, $3e, $31, $f5, $33, $d5
    db $33, $cd, $21, $4b, $e1, $7b, $d1, $c1
    db $b7, $28, $04, $7a, $b7, $20, $03, $1e
    db $00, $c9, $21, $05, $00, $09, $56, $c5
    db $d5, $3e, $12, $f5, $33, $d5, $33, $cd
    db $21, $4b, $e1, $7b, $d1, $c1, $b7, $28
    db $04, $7a, $b7, $20, $03, $1e, $00, $c9
    db $21, $06, $00, $09, $7e, $26, $99, $e5
    db $33, $f5, $33, $cd, $21, $4b, $e1, $7b
    db $b7, $20, $02, $5f, $c9, $1e, $01, $c9
    db $3b, $0e, $00, $21, $d8, $4a, $06, $00
    db $09, $46, $f8, $03, $2a, $80, $5f, $7e
    db $ce, $00, $57, $1a, $f8, $00, $77, $f8
    db $05, $2a, $80, $47, $7e, $ce, $00, $68
    db $67, $46, $f8, $00, $7e, $90, $30, $04
    db $1e, $ff, $18, $12, $78, $f8, $00, $96
    db $30, $04, $1e, $01, $18, $08, $0c, $79
    db $d6, $06, $38, $c7, $1e, $00, $33, $c9
    db $cd, $9d, $4a, $11, $48, $db, $d5, $cd
    db $46, $4b, $e1, $7b, $b7, $c8, $f8, $03
    db $7e, $b7, $20, $2d, $fa, $50, $db, $07
    db $d8, $fa, $47, $db, $b7, $28, $22, $11
    db $40, $db, $d5, $11, $48, $db, $d5, $cd
    db $e0, $4b, $e8, $04, $4b, $af, $57, $91
    db $cb, $7b, $28, $07, $cb, $7a, $20, $08
    db $bf, $18, $05, $cb, $7a, $28, $01, $37
    db $d0, $1e, $00, $7b, $c6, $40, $4f, $3e
    db $00, $ce, $db, $47, $21, $48, $db, $16
    db $00, $19, $7e, $02, $1c, $7b, $d6, $07
    db $38, $e9, $21, $47, $db, $36, $01, $c9
    db $fa, $3a, $db, $b7, $c0, $f8, $02, $7e
    db $b7, $28, $0e, $21, $54, $01, $e5, $cd
    db $20, $4c, $e1, $21, $fd, $da, $36, $01
    db $c9, $cd, $4f, $54, $21, $42, $00, $e5
    db $cd, $20, $4c, $e1, $c3, $ab, $5a, $e8
    db $f3, $0e, $3c, $c5, $cd, $88, $06, $c1
    db $0d, $20, $f8, $cd, $9d, $4a, $f8, $00
    db $4d, $44, $f8, $0b, $36, $00, $f8, $0c
    db $36, $00, $79, $f8, $0c, $86, $f5, $f8
    db $09, $f1, $22, $78, $ce, $00, $77, $f8
    db $0c, $3a, $2b, $2b, $c6, $48, $22, $3e
    db $00, $ce, $db, $32, $2a, $5f, $56, $1a
    db $f8, $07, $5e, $23, $66, $6b, $77, $f8
    db $0c, $34, $7e, $d6, $07, $38, $d3, $c5
    db $cd, $88, $06, $cd, $9d, $4a, $c1, $f8
    db $0c, $36, $01, $1e, $00, $6b, $26, $00
    db $09, $56, $7b, $c6, $48, $6f, $3e, $00
    db $ce, $db, $67, $7e, $92, $28, $04, $f8
    db $0c, $36, $00, $1c, $7b, $d6, $07, $38
    db $e4, $f8, $0c, $7e, $b7, $20, $08, $f8
    db $0b, $34, $7e, $d6, $08, $38, $97, $e8
    db $0d, $c9, $fa, $4e, $db, $b7, $20, $03
    db $1e, $5a, $c9, $11, $48, $db, $d5, $cd
    db $46, $4b, $e1, $7b, $b7, $20, $03, $1e
    db $49, $c9, $fa, $50, $db, $07, $30, $03
    db $1e, $56, $c9, $11, $40, $db, $d5, $11
    db $48, $db, $d5, $cd, $e0, $4b, $e8, $04
    db $4b, $cb, $79, $1e, $45, $c0, $1e, $00
    db $c9, $e8, $f5, $cd, $9c, $4e, $21, $10
    db $04, $19, $4d, $44, $0a, $fe, $53, $20
    db $11, $69, $60, $23, $7e, $fe, $31, $20
    db $09, $af, $02, $36, $00, $21, $ff, $db
    db $36, $01, $f0, $f8, $b7, $28, $05, $11
    db $8c, $4e, $18, $03, $11, $94, $4e, $e1
    db $d5, $21, $18, $00, $09, $e5, $7d, $f8
    db $0a, $77, $e1, $7c, $f8, $09, $77, $af
    db $e0, $4f, $f0, $4f, $e6, $01, $ea, $09
    db $dc, $21, $02, $00, $09, $e5, $7d, $f8
    db $04, $77, $e1, $7c, $f8, $03, $32, $2a
    db $5f, $56, $1a, $f8, $0a, $77, $03, $03
    db $03, $f8, $04, $79, $22, $70, $f8, $08
    db $3a, $2b, $c6, $01, $22, $23, $23, $3a
    db $2b, $ce, $00, $77, $f8, $0a, $7e, $d6
    db $53, $20, $69, $f8, $04, $2a, $5f, $56
    db $1a, $fe, $42, $28, $09, $2b, $2a, $5f
    db $56, $1a, $fe, $4e, $20, $56, $21, $f8
    db $db, $36, $01, $21, $08, $dc, $36, $01
    db $f8, $06, $2a, $5f, $56, $1a, $fe, $01
    db $28, $12, $2b, $2a, $5f, $56, $1a, $fe
    db $11, $28, $09, $2b, $2a, $5f, $56, $1a
    db $fe, $ff, $20, $30, $f8, $08, $7e, $f8
    db $00, $77, $f8, $09, $7e, $f8, $01, $77
    db $f8, $08, $2a, $4f, $46, $03, $03, $0a
    db $fe, $14, $3e, $01, $28, $01, $af, $ea
    db $08, $dc, $f8, $06, $2a, $5f, $56, $1a
    db $fe, $11, $3e, $01, $28, $01, $af, $ee
    db $01, $ea, $09, $dc, $f8, $0a, $36, $00
    db $f8, $0a, $3a, $2b, $22, $36, $dc, $f8
    db $00, $7e, $f8, $0a, $86, $4f, $f5, $f8
    db $03, $f1, $7e, $ce, $00, $47, $0a, $f8
    db $08, $5e, $23, $66, $6b, $77, $f8, $0a
    db $34, $7e, $d6, $08, $38, $da, $f8, $06
    db $2a, $66, $6f, $36, $00, $f8, $02, $2a
    db $66, $6f, $36, $00, $f8, $04, $2a, $66
    db $6f, $36, $00, $af, $f5, $33, $cd, $62
    db $4a, $e8, $0c, $c9, $b0, $01, $13, $00
    db $d8, $00, $4d, $01, $80, $11, $00, $00
    db $56, $ff, $0d, $00, $21, $00, $40, $36
    db $11, $3e, $03, $f5, $33, $cd, $62, $4a
    db $33, $11, $00, $a0, $c9, $cd, $9c, $4e
    db $21, $00, $02, $19, $4e, $c5, $af, $f5
    db $33, $cd, $62, $4a, $33, $c1, $3e, $01
    db $91, $38, $06, $fa, $57, $db, $91, $20
    db $03, $1e, $00, $c9, $21, $57, $db, $71
    db $1e, $01, $c9, $fa, $fd, $db, $b7, $c8
    db $cd, $9c, $4e, $4b, $42, $af, $02, $fa
    db $57, $db, $fe, $02, $30, $0a, $21, $00
    db $02, $09, $4d, $44, $fa, $57, $db, $02
    db $af, $f5, $33, $cd, $62, $4a, $33, $c9
    db $cd, $c0, $43, $f0, $f7, $4f, $c5, $cd
    db $4a, $3a, $7b, $c1, $b1, $e0, $f7, $cd
    db $61, $4d, $cd, $4f, $54, $cd, $d0, $43
    db $cd, $d3, $4e, $cd, $b0, $78, $fa, $3a
    db $db, $b7, $c0, $fa, $47, $db, $b7, $c8
    db $cd, $9d, $4a, $cd, $2a, $4d, $7b, $b7
    db $c8, $cd, $a7, $4c, $cd, $2a, $4d, $7b
    db $b7, $c8, $d5, $7b, $f5, $33, $cd, $84
    db $50, $33, $7b, $d1, $b7, $28, $09, $11
    db $40, $db, $d5, $cd, $e5, $4a, $e1, $c9
    db $7b, $d6, $56, $c0, $11, $48, $db, $d5
    db $cd, $e5, $4a, $e1, $c9, $f8, $04, $7e
    db $cb, $37, $e6, $0f, $4e, $2b, $2b, $f5
    db $79, $e6, $0f, $4f, $f1, $5e, $23, $56
    db $47, $d6, $0a, $30, $05, $78, $c6, $30
    db $18, $03, $78, $c6, $37, $12, $13, $41
    db $79, $d6, $0a, $30, $05, $78, $c6, $30
    db $18, $03, $78, $c6, $37, $12, $c9, $f8
    db $04, $2a, $c6, $06, $4f, $7e, $ce, $00
    db $47, $0a, $f5, $33, $f8, $03, $2a, $5f
    db $56, $d5, $cd, $55, $4f, $e8, $03, $f8
    db $02, $2a, $4f, $2a, $47, $03, $03, $3e
    db $2d, $02, $2a, $c6, $05, $4f, $7e, $ce
    db $00, $69, $67, $46, $f8, $02, $2a, $5f
    db $56, $13, $13, $13, $c5, $33, $d5, $cd
    db $55, $4f, $e8, $03, $f8, $02, $2a, $c6
    db $05, $4f, $7e, $ce, $00, $69, $67, $36
    db $2d, $f8, $04, $2a, $4f, $46, $03, $03
    db $03, $0a, $47, $f8, $02, $2a, $c6, $06
    db $4f, $7e, $ce, $00, $c5, $33, $47, $c5
    db $cd, $55, $4f, $e8, $03, $c9, $f8, $04
    db $2a, $4f, $46, $03, $03, $0a, $f5, $33
    db $f8, $03, $2a, $5f, $56, $d5, $cd, $55
    db $4f, $e8, $03, $f8, $02, $2a, $4f, $2a
    db $47, $03, $03, $3e, $3a, $02, $2a, $4f
    db $46, $03, $0a, $57, $f8, $02, $2a, $4f
    db $46, $03, $03, $03, $d5, $33, $c5, $cd
    db $55, $4f, $e8, $03, $f8, $02, $2a, $c6
    db $05, $4f, $7e, $ce, $00, $69, $67, $36
    db $3a, $f8, $04, $2a, $4f, $46, $0a, $47
    db $f8, $02, $2a, $c6, $06, $4f, $7e, $ce
    db $00, $c5, $33, $47, $c5, $cd, $55, $4f
    db $e8, $03, $c9, $f0, $fb, $b7, $28, $1f
    db $f8, $08, $3a, $57, $5e, $d5, $f8, $06
    db $3a, $2b, $f5, $33, $2a, $5f, $56, $d5
    db $af, $0f, $f5, $af, $0f, $f5, $af, $0f
    db $f5, $cd, $00, $75, $e8, $0b, $c9, $f8
    db $06, $3a, $57, $3a, $5f, $d5, $3a, $2b
    db $f5, $33, $2a, $5f, $56, $d5, $cd, $b7
    db $08, $e8, $05, $c9, $e8, $f5, $f8, $0d
    db $7e, $d6, $5a, $20, $05, $01, $34, $53
    db $18, $1b, $f8, $0d, $7e, $d6, $49, $20
    db $05, $01, $3f, $53, $18, $0f, $f8, $0d
    db $7e, $d6, $56, $20, $05, $01, $48, $53
    db $18, $03, $01, $53, $53, $1e, $00, $6b
    db $26, $00, $09, $7e, $b7, $28, $03, $1c
    db $18, $f5, $f8, $00, $73, $f0, $fb, $f8
    db $0a, $32, $36, $00, $c5, $21, $05, $08
    db $e5, $3e, $01, $f5, $33, $11, $32, $53
    db $d5, $cd, $b7, $08, $e8, $05, $af, $0f
    db $f5, $af, $f5, $33, $cd, $91, $27, $e8
    db $03, $21, $7f, $01, $e5, $21, $10, $9f
    db $e5, $af, $f5, $33, $cd, $ba, $27, $e8
    db $05, $21, $03, $00, $e5, $cd, $90, $02
    db $e1, $c1, $f8, $0a, $7e, $b7, $28, $14
    db $c5, $21, $73, $01, $e5, $21, $14, $9f
    db $e5, $af, $f5, $33, $cd, $ba, $27, $e8
    db $05, $c1, $18, $12, $c5, $21, $63, $01
    db $e5, $21, $1b, $9f, $e5, $af, $f5, $33
    db $cd, $ba, $27, $e8, $05, $c1, $21, $01
    db $18, $e5, $21, $01, $04, $e5, $f8, $04
    db $7e, $f5, $33, $c5, $cd, $4b, $50, $e8
    db $07, $21, $01, $2c, $e5, $21, $01, $06
    db $e5, $3e, $04, $f5, $33, $11, $5f, $53
    db $d5, $cd, $4b, $50, $e8, $07, $21, $01
    db $00, $39, $e5, $11, $50, $db, $d5, $e5
    db $cd, $87, $4f, $e8, $04, $e1, $e5, $11
    db $3c, $2c, $d5, $11, $06, $06, $d5, $3e
    db $08, $f5, $33, $e5, $cd, $4b, $50, $e8
    db $07, $e1, $e5, $11, $50, $db, $d5, $e5
    db $cd, $ee, $4f, $e8, $04, $e1, $e5, $11
    db $3c, $38, $d5, $11, $06, $07, $d5, $3e
    db $08, $f5, $33, $e5, $cd, $4b, $50, $e8
    db $07, $21, $01, $44, $e5, $21, $01, $08
    db $e5, $3e, $02, $f5, $33, $11, $64, $53
    db $d5, $cd, $4b, $50, $e8, $07, $e1, $e5
    db $11, $40, $db, $d5, $e5, $cd, $87, $4f
    db $e8, $04, $e1, $e5, $11, $3c, $44, $d5
    db $11, $06, $08, $d5, $3e, $08, $f5, $33
    db $e5, $cd, $4b, $50, $e8, $07, $e1, $e5
    db $11, $40, $db, $d5, $e5, $cd, $ee, $4f
    db $e8, $04, $e1, $11, $3c, $50, $d5, $11
    db $06, $09, $d5, $3e, $08, $f5, $33, $e5
    db $cd, $4b, $50, $e8, $07, $f8, $0a, $7e
    db $b7, $ca, $6a, $52, $21, $01, $64, $e5
    db $3e, $07, $f5, $33, $11, $67, $53, $d5
    db $af, $0f, $f5, $af, $0f, $f5, $af, $0f
    db $f5, $cd, $00, $75, $e8, $0b, $21, $58
    db $64, $e5, $af, $f5, $33, $11, $71, $53
    db $d5, $af, $0f, $f5, $af, $0f, $f5, $af
    db $0f, $f5, $cd, $00, $75, $e8, $0b, $21
    db $73, $00, $e5, $21, $14, $9f, $e5, $af
    db $f5, $33, $cd, $ba, $27, $e8, $05, $21
    db $03, $03, $e5, $cd, $90, $02, $e1, $21
    db $26, $01, $e5, $21, $26, $9f, $e5, $af
    db $f5, $33, $cd, $ba, $27, $e8, $05, $21
    db $5f, $01, $e5, $21, $5f, $9f, $e5, $af
    db $f5, $33, $cd, $ba, $27, $e8, $05, $21
    db $73, $01, $e5, $21, $5f, $4f, $e5, $3e
    db $4f, $f5, $33, $cd, $ba, $27, $e8, $05
    db $18, $5b, $21, $01, $0b, $e5, $3e, $07
    db $f5, $33, $11, $67, $53, $d5, $cd, $b7
    db $08, $e8, $05, $21, $0a, $0b, $e5, $3e
    db $09, $f5, $33, $11, $71, $53, $d5, $cd
    db $b7, $08, $e8, $05, $21, $03, $03, $e5
    db $cd, $90, $02, $e1, $21, $2b, $01, $e5
    db $21, $2b, $9f, $e5, $af, $f5, $33, $cd
    db $ba, $27, $e8, $05, $21, $53, $01, $e5
    db $21, $53, $9f, $e5, $af, $f5, $33, $cd
    db $ba, $27, $e8, $05, $21, $63, $01, $e5
    db $21, $53, $4b, $e5, $3e, $4b, $f5, $33
    db $cd, $ba, $27, $e8, $05, $21, $03, $00
    db $e5, $cd, $90, $02, $e1, $f8, $0a, $36
    db $00, $cd, $88, $06, $cd, $4a, $3a, $7b
    db $e6, $30, $28, $06, $f8, $0a, $36, $00
    db $18, $03, $f8, $0a, $34, $f8, $0a, $7e
    db $d6, $08, $38, $e5, $cd, $88, $06, $cd
    db $4a, $3a, $cb, $63, $28, $06, $f8, $0a
    db $36, $01, $18, $08, $cb, $6b, $28, $ec
    db $f8, $0a, $36, $00, $cd, $4a, $3a, $7b
    db $e6, $30, $28, $05, $cd, $88, $06, $18
    db $f3, $af, $0f, $f5, $af, $f5, $33, $cd
    db $91, $27, $e8, $03, $21, $7f, $01, $e5
    db $21, $10, $9f, $e5, $af, $f5, $33, $cd
    db $ba, $27, $e8, $05, $f8, $0a, $5e, $e8
    db $0b, $c9, $20, $00, $52, $54, $43, $20
    db $52, $45, $53, $45, $54, $3f, $00, $52
    db $54, $43, $20, $42, $41, $44, $3f, $00
    db $52, $54, $43, $20, $4c, $4f, $57, $20
    db $56, $3f, $00, $52, $54, $43, $20, $42
    db $45, $48, $49, $4e, $44, $3f, $00, $43
    db $48, $49, $50, $00, $53, $44, $00, $5b
    db $42, $5d, $6b, $65, $65, $70, $20, $20
    db $20, $5b, $41, $5d, $75, $73, $65, $20
    db $53, $44, $00, $3b, $f8, $00, $36, $00
    db $f8, $00, $5e, $16, $db, $f8, $03, $7e
    db $f8, $00, $86, $23, $23, $23, $23, $4f
    db $7e, $ce, $00, $47, $0a, $12, $0a, $b7
    db $28, $05, $f8, $00, $34, $18, $e1, $33
    db $c9, $f8, $02, $2a, $5f, $56, $d5, $cd
    db $7b, $53, $e1, $cd, $92, $4a, $3e, $01
    db $f5, $33, $11, $00, $db, $d5, $11, $0f
    db $ca, $d5, $cd, $26, $19, $e8, $05, $7b
    db $b7, $28, $03, $1e, $00, $c9, $cd, $92
    db $4a, $f8, $04, $2a, $5f, $56, $d5, $11
    db $00, $02, $d5, $11, $00, $d8, $d5, $11
    db $0f, $ca, $d5, $cd, $41, $19, $e8, $08
    db $d5, $cd, $92, $4a, $01, $0f, $ca, $c5
    db $cd, $a1, $19, $e1, $d1, $f8, $04, $2a
    db $4f, $46, $7b, $b7, $28, $06, $af, $02
    db $03, $02, $18, $17, $69, $60, $2a, $66
    db $6f, $3e, $ff, $bd, $3e, $00, $9c, $30
    db $0a, $7c, $d6, $02, $30, $05, $7d, $02
    db $03, $af, $02, $1e, $01, $c9, $3b, $3b
    db $cd, $92, $4a, $f8, $00, $e5, $f8, $08
    db $2a, $5f, $56, $d5, $f8, $08, $2a, $5f
    db $56, $d5, $11, $0f, $ca, $d5, $cd, $63
    db $19, $e8, $08, $7b, $b7, $20, $15, $f8
    db $00, $7e, $f8, $06, $96, $20, $0b, $f8
    db $01, $7e, $f8, $07, $96, $20, $03, $5f
    db $18, $02, $1e, $ff, $33, $33, $c9, $e8
    db $fd, $21, $f9, $db, $36, $01, $21, $80
    db $da, $36, $01, $2e, $81, $36, $00, $2e
    db $82, $36, $00, $21, $47, $db, $36, $00
    db $21, $7f, $da, $36, $00, $2e, $00, $75
    db $21, $3a, $db, $36, $00, $2e, $57, $36
    db $ff, $2e, $f7, $36, $00, $2e, $f6, $36
    db $01, $f8, $02, $af, $32, $2b, $e5, $11
    db $e1, $54, $d5, $cd, $a1, $53, $e8, $04
    db $7b, $b7, $20, $16, $21, $00, $00, $39
    db $e5, $11, $eb, $54, $d5, $cd, $a1, $53
    db $e8, $04, $7b, $b7, $28, $38, $f8, $02
    db $36, $01, $f8, $02, $3a, $2b, $f5, $33
    db $2a, $5f, $56, $d5, $cd, $f8, $54, $e8
    db $03, $21, $f7, $db, $4e, $fa, $ea, $db
    db $c6, $06, $47, $79, $90, $38, $0c, $fa
    db $f7, $db, $fe, $07, $28, $05, $21, $f7
    db $db, $36, $00, $fa, $f7, $db, $fe, $07
    db $20, $04, $3e, $01, $e0, $fb, $e8, $03
    db $c9, $2f, $45, $5a, $47, $42, $2e, $43
    db $46, $47, $00, $2f, $46, $4c, $41, $55
    db $4e, $43, $48, $2e, $43, $46, $47, $00
    db $e8, $ee, $f8, $14, $af, $96, $23, $3e
    db $02, $9e, $30, $06, $f8, $14, $af, $22
    db $36, $02, $f8, $14, $2a, $4f, $7e, $c6
    db $d8, $47, $af, $02, $f8, $0d, $36, $00
    db $af, $f8, $04, $22, $77, $f8, $04, $5d
    db $54, $f8, $14, $1a, $13, $96, $23, $1a
    db $9e, $d2, $68, $58, $f8, $04, $2a, $4f
    db $46, $f8, $14, $79, $96, $23, $78, $9e
    db $30, $0c, $21, $00, $d8, $09, $7e, $fe
    db $20, $20, $03, $03, $18, $eb, $f8, $09
    db $79, $22, $70, $f8, $14, $79, $96, $23
    db $78, $9e, $30, $20, $21, $00, $d8, $09
    db $e5, $7d, $f8, $12, $77, $e1, $7c, $f8
    db $11, $32, $2a, $5f, $56, $1a, $fe, $0d
    db $28, $0a, $fe, $0a, $28, $06, $b7, $28
    db $03, $03, $18, $d7, $f8, $0f, $79, $22
    db $70, $f8, $14, $79, $96, $23, $78, $9e
    db $30, $10, $21, $00, $d8, $09, $7e, $fe
    db $0d, $28, $04, $fe, $0a, $20, $03, $03
    db $18, $e7, $f8, $04, $79, $22, $70, $f8
    db $0f, $2a, $4f, $7e, $c6, $d8, $47, $0a
    db $b7, $20, $1a, $f8, $0f, $5d, $54, $f8
    db $14, $1a, $13, $96, $23, $1a, $9e, $30
    db $0c, $f8, $14, $7e, $f8, $04, $77, $f8
    db $15, $7e, $f8, $05, $77, $f8, $09, $5d
    db $54, $f8, $0f, $1a, $13, $96, $23, $1a
    db $9e, $30, $37, $f8, $0f, $7e, $c6, $ff
    db $f5, $f8, $09, $f1, $77, $f5, $f8, $12
    db $f1, $7e, $ce, $ff, $f8, $08, $32, $2a
    db $23, $23, $23, $32, $2b, $2b, $7e, $c6
    db $d8, $f8, $0c, $32, $2a, $5f, $56, $1a
    db $fe, $20, $20, $0e, $f8, $07, $7e, $f8
    db $0f, $77, $f8, $08, $7e, $f8, $10, $77
    db $18, $bb, $f8, $09, $7e, $f8, $0f, $96
    db $20, $09, $f8, $0a, $7e, $f8, $10, $96
    db $ca, $1d, $55, $f8, $09, $7e, $f8, $11
    db $77, $f8, $09, $3a, $2b, $2b, $22, $23
    db $23, $23, $7e, $c6, $d8, $f8, $07, $77
    db $f8, $16, $7e, $b7, $28, $15, $f8, $0f
    db $2a, $23, $96, $f5, $33, $f8, $07, $2a
    db $5f, $56, $d5, $cd, $fd, $58, $e8, $03
    db $c3, $68, $58, $f8, $09, $7e, $f8, $00
    db $77, $f8, $0a, $7e, $f8, $01, $77, $f8
    db $00, $5d, $54, $f8, $0f, $1a, $13, $96
    db $23, $1a, $9e, $3e, $00, $17, $f8, $0e
    db $77, $f8, $00, $7e, $c6, $01, $f5, $f8
    db $0d, $f1, $77, $f5, $f8, $03, $f1, $7e
    db $ce, $00, $f8, $0c, $22, $23, $7e, $b7
    db $28, $20, $f8, $00, $2a, $23, $32, $2a
    db $23, $c6, $d8, $32, $2a, $5f, $56, $1a
    db $fe, $3d, $28, $0e, $f8, $0b, $7e, $f8
    db $00, $77, $f8, $0c, $7e, $f8, $01, $77
    db $18, $b5, $f8, $0e, $cb, $46, $ca, $1d
    db $55, $f8, $00, $7e, $f8, $11, $96, $77
    db $f8, $0b, $2a, $4f, $46, $f8, $11, $7e
    db $b7, $28, $1e, $7e, $f8, $0b, $22, $af
    db $32, $3a, $2b, $86, $23, $5f, $3e, $00
    db $8e, $57, $1b, $21, $00, $d8, $19, $7e
    db $fe, $20, $20, $05, $f8, $11, $35, $18
    db $dc, $f8, $11, $7e, $f8, $08, $77, $21
    db $00, $d8, $09, $e5, $7d, $f8, $0d, $77
    db $e1, $7c, $f8, $0c, $77, $f8, $0f, $79
    db $96, $23, $78, $9e, $30, $0d, $f8, $0b
    db $2a, $5f, $56, $1a, $fe, $20, $20, $03
    db $03, $18, $dc, $f8, $0b, $3a, $2b, $77
    db $f8, $0c, $3a, $2b, $77, $f8, $0f, $2a
    db $91, $4f, $7e, $98, $47, $79, $3d, $b0
    db $20, $0b, $f8, $09, $2a, $5f, $56, $1a
    db $c6, $d0, $5f, $18, $02, $1e, $ff, $f8
    db $0b, $73, $f8, $0e, $3e, $01, $22, $3e
    db $6b, $22, $3e, $58, $22, $36, $00, $f8
    db $0f, $2a, $5f, $56, $1a, $f8, $0c, $77
    db $b7, $28, $43, $f8, $0f, $2a, $5f, $56
    db $13, $c5, $f8, $0e, $7e, $f5, $33, $d5
    db $f8, $0d, $3a, $2b, $f5, $33, $2a, $5f
    db $56, $d5, $cd, $c1, $58, $e8, $06, $7b
    db $c1, $f8, $0f, $5e, $23, $56, $f5, $1a
    db $f8, $0e, $77, $f1, $b7, $20, $17, $f8
    db $11, $34, $f8, $0e, $cb, $26, $2b, $2b
    db $5e, $af, $57, $13, $7b, $f8, $0f, $86
    db $22, $7a, $8e, $77, $18, $b1, $f8, $0c
    db $7e, $b7, $ca, $1d, $55, $23, $2a, $a6
    db $c2, $1d, $55, $2b, $2a, $b6, $2b, $77
    db $51, $3e, $07, $f8, $11, $96, $da, $53
    db $58, $d5, $5e, $16, $00, $21, $a8, $57
    db $19, $19, $5e, $23, $66, $6b, $d1, $e9
    db $b8, $57, $c8, $57, $d8, $57, $e7, $57
    db $0b, $58, $22, $58, $32, $58, $3c, $58
    db $d5, $33, $f8, $0a, $2a, $5f, $56, $d5
    db $cd, $fd, $58, $e8, $03, $c3, $1d, $55
    db $d5, $33, $f8, $0a, $2a, $5f, $56, $d5
    db $cd, $8b, $59, $e8, $03, $c3, $1d, $55
    db $c5, $f8, $0b, $2a, $5f, $56, $d5, $cd
    db $97, $5c, $e8, $04, $c3, $1d, $55, $79
    db $d6, $02, $78, $de, $00, $38, $16, $f8
    db $09, $2a, $5f, $56, $1a, $fe, $31, $20
    db $0c, $2b, $2a, $4f, $46, $03, $0a, $fe
    db $32, $3e, $01, $28, $01, $af, $e0, $fb
    db $c3, $1d, $55, $78, $b1, $28, $0c, $f8
    db $09, $2a, $5f, $56, $1a, $fe, $30, $3e
    db $01, $28, $01, $af, $ea, $3a, $db, $c3
    db $1d, $55, $3e, $01, $f8, $0b, $96, $da
    db $1d, $55, $11, $57, $db, $7e, $12, $c3
    db $1d, $55, $11, $f7, $db, $f8, $0b, $7e
    db $12, $c3, $1d, $55, $78, $b1, $28, $0c
    db $f8, $09, $2a, $5f, $56, $1a, $fe, $30
    db $3e, $01, $28, $01, $af, $ea, $f6, $db
    db $c3, $1d, $55, $d5, $33, $f8, $0a, $2a
    db $5f, $56, $d5, $f8, $14, $7e, $f5, $33
    db $cd, $90, $49, $e8, $04, $c3, $1d, $55
    db $e8, $12, $c9, $07, $66, $6c, $61, $75
    db $6e, $63, $68, $03, $72, $74, $63, $07
    db $6c, $61, $73, $74, $72, $6f, $6d, $02
    db $75, $69, $05, $72, $74, $63, $73, $64
    db $08, $61, $75, $74, $6f, $73, $61, $76
    db $65, $05, $74, $68, $65, $6d, $65, $04
    db $74, $61, $67, $73, $06, $63, $6f, $6c
    db $6f, $72, $73, $07, $62, $6f, $6f, $74
    db $72, $6f, $6d, $00, $f8, $02, $7e, $d6
    db $41, $38, $0a, $3e, $5a, $96, $38, $05
    db $7e, $c6, $20, $5f, $c9, $f8, $02, $5e
    db $c9, $f8, $04, $7e, $f8, $07, $96, $28
    db $03, $1e, $00, $c9, $16, $00, $7a, $f8
    db $04, $96, $30, $26, $2b, $2b, $2a, $82
    db $4f, $7e, $ce, $00, $47, $0a, $d5, $f5
    db $33, $cd, $ac, $58, $33, $f1, $57, $f8
    db $05, $2a, $82, $4f, $7e, $ce, $00, $47
    db $0a, $93, $28, $03, $1e, $00, $c9, $14
    db $18, $d4, $1e, $01, $c9, $3b, $3b, $f8
    db $01, $36, $00, $f8, $06, $7e, $b7, $28
    db $26, $2b, $2b, $2a, $4f, $46, $0a, $fe
    db $23, $20, $1c, $21, $80, $da, $36, $00
    db $1e, $01, $7b, $f8, $06, $96, $30, $0c
    db $6b, $26, $00, $09, $7e, $fe, $20, $20
    db $03, $1c, $18, $ee, $f8, $01, $73, $f8
    db $01, $7e, $f8, $06, $96, $30, $51, $0e
    db $00, $f8, $04, $7e, $f8, $01, $86, $23
    db $23, $23, $23, $5f, $7e, $ce, $00, $57
    db $1a, $fe, $2f, $28, $07, $0e, $01, $21
    db $82, $da, $36, $2f, $f8, $01, $46, $79
    db $c6, $82, $f5, $f8, $02, $f1, $22, $3e
    db $00, $ce, $da, $77, $78, $f8, $06, $96
    db $30, $16, $79, $d6, $78, $30, $11, $2b
    db $2b, $0c, $2a, $80, $5f, $7e, $ce, $00
    db $57, $1a, $e1, $e5, $77, $04, $18, $d7
    db $e1, $36, $00, $e5, $21, $81, $da, $71
    db $33, $33, $c9, $e8, $f2, $0e, $00, $59
    db $16, $00, $21, $02, $00, $39, $19, $36
    db $00, $0c, $79, $d6, $06, $38, $f0, $f8
    db $08, $af, $22, $22, $23, $af, $22, $22
    db $36, $00, $f8, $0d, $7e, $f8, $12, $96
    db $30, $12, $2b, $2b, $7e, $f8, $0d, $86
    db $23, $23, $23, $23, $4f, $7e, $ce, $00
    db $47, $0a, $18, $01, $af, $f8, $0a, $77
    db $d6, $30, $38, $11, $3e, $39, $96, $38
    db $0c, $2b, $3a, $22, $23, $3a, $c6, $d0
    db $22, $23, $34, $18, $30, $f8, $0b, $7e
    db $b7, $28, $1e, $23, $7e, $d6, $06, $30
    db $18, $5e, $16, $00, $21, $02, $00, $39
    db $19, $d1, $e5, $f8, $0c, $34, $f8, $08
    db $2a, $cb, $37, $e6, $f0, $b6, $e1, $e5
    db $77, $f8, $08, $af, $22, $22, $23, $af
    db $32, $7e, $b7, $28, $0b, $f8, $0d, $34
    db $f8, $12, $7e, $f8, $0d, $96, $30, $92
    db $f8, $0c, $7e, $d6, $06, $38, $35, $f8
    db $02, $7e, $ea, $46, $db, $f8, $03, $7e
    db $ea, $45, $db, $f8, $04, $7e, $21, $43
    db $db, $77, $2e, $44, $36, $03, $f8, $05
    db $7e, $ea, $42, $db, $f8, $06, $7e, $ea
    db $41, $db, $f8, $07, $7e, $ea, $40, $db
    db $11, $40, $db, $d5, $cd, $46, $4b, $e1
    db $7b, $ea, $47, $db, $e8, $0e, $c9, $f8
    db $02, $2a, $4f, $2a, $47, $7e, $cb, $37
    db $e6, $0f, $c6, $30, $02, $03, $7e, $e6
    db $0f, $c6, $30, $02, $1e, $02, $c9, $f8
    db $04, $2a, $4f, $46, $f8, $02, $2a, $5f
    db $56, $f8, $06, $7e, $6f, $3d, $2c, $2d
    db $c8, $f5, $0a, $6f, $f1, $03, $f5, $7d
    db $12, $f1, $13, $18, $ef, $f8, $02, $2a
    db $4f, $3a, $47, $3e, $0d, $02, $03, $79
    db $22, $78, $32, $2a, $4f, $3a, $47, $3e
    db $0a, $02, $03, $79, $22, $78, $32, $2a
    db $5f, $56, $c9, $e8, $fb, $3e, $08, $f5
    db $33, $11, $63, $5c, $d5, $11, $00, $d8
    db $d5, $cd, $6f, $5a, $e8, $05, $4b, $42
    db $fa, $80, $da, $b7, $20, $04, $3e, $23
    db $02, $03, $fa, $81, $da, $f5, $33, $11
    db $82, $da, $d5, $c5, $cd, $6f, $5a, $e8
    db $05, $d5, $cd, $8d, $5a, $e1, $4b, $42
    db $fa, $47, $db, $b7, $28, $58, $3e, $06
    db $f5, $33, $11, $6b, $5c, $d5, $c5, $cd
    db $6f, $5a, $e8, $05, $f8, $04, $36, $00
    db $3e, $d8, $f8, $04, $86, $4f, $3e, $4a
    db $ce, $00, $47, $0a, $6f, $26, $00, $01
    db $40, $db, $09, $7e, $d5, $f5, $33, $d5
    db $cd, $57, $5a, $e8, $03, $7b, $d1, $83
    db $4f, $3e, $00, $8a, $47, $f8, $04, $7e
    db $d6, $05, $28, $13, $3e, $71, $f8, $04
    db $86, $5f, $3e, $5c, $ce, $00, $57, $1a
    db $02, $59, $50, $13, $34, $18, $c1, $c5
    db $cd, $8d, $5a, $e1, $4b, $42, $fa, $7f
    db $da, $b7, $28, $21, $3e, $08, $f5, $33
    db $11, $76, $5c, $d5, $c5, $cd, $6f, $5a
    db $e8, $05, $01, $00, $da, $0a, $b7, $28
    db $05, $03, $12, $13, $18, $f7, $d5, $cd
    db $8d, $5a, $e1, $4b, $42, $3e, $03, $f5
    db $33, $11, $7e, $5c, $d5, $c5, $cd, $6f
    db $5a, $e8, $05, $4b, $42, $f0, $fb, $b7
    db $28, $04, $3e, $31, $02, $03, $d1, $c5
    db $03, $f8, $02, $79, $22, $70, $f0, $fb
    db $b7, $28, $05, $23, $36, $32, $18, $04
    db $f8, $04, $36, $38, $f8, $04, $7e, $e1
    db $e5, $77, $f8, $02, $2a, $5f, $56, $d5
    db $cd, $8d, $5a, $e1, $4b, $42, $fa, $3a
    db $db, $b7, $28, $15, $3e, $07, $f5, $33
    db $11, $81, $5c, $d5, $c5, $cd, $6f, $5a
    db $e8, $05, $d5, $cd, $8d, $5a, $e1, $4b
    db $42, $fa, $57, $db, $fe, $02, $30, $1e
    db $3e, $09, $f5, $33, $11, $88, $5c, $d5
    db $c5, $cd, $6f, $5a, $e8, $05, $4b, $42
    db $fa, $57, $db, $c6, $30, $02, $03, $c5
    db $cd, $8d, $5a, $e1, $4b, $42, $af, $f5
    db $33, $c5, $3e, $01, $f5, $33, $cd, $90
    db $49, $e8, $04, $4b, $42, $fa, $f6, $db
    db $b7, $20, $15, $3e, $06, $f5, $33, $11
    db $91, $5c, $d5, $c5, $cd, $6f, $5a, $e8
    db $05, $d5, $cd, $8d, $5a, $e1, $4b, $42
    db $69, $60, $7c, $d6, $da, $30, $05, $3e
    db $20, $22, $18, $f6, $11, $59, $5c, $d5
    db $cd, $7b, $53, $e1, $cd, $92, $4a, $3e
    db $0a, $f5, $33, $11, $00, $db, $d5, $11
    db $0f, $ca, $d5, $cd, $26, $19, $e8, $05
    db $7b, $b7, $20, $1a, $11, $00, $02, $d5
    db $11, $00, $d8, $d5, $cd, $16, $54, $e8
    db $04, $d5, $cd, $92, $4a, $01, $0f, $ca
    db $c5, $cd, $a1, $19, $e1, $d1, $e8, $05
    db $c9, $2f, $45, $5a, $47, $42, $2e, $43
    db $46, $47, $00, $46, $4c, $41, $55, $4e
    db $43, $48, $3d, $52, $54, $43, $3d, $32
    db $30, $2d, $2d, $20, $3a, $3a, $4c, $41
    db $53, $54, $52, $4f, $4d, $3d, $55, $49
    db $3d, $52, $54, $43, $53, $44, $3d, $30
    db $41, $55, $54, $4f, $53, $41, $56, $45
    db $3d, $54, $41, $47, $53, $3d, $31, $e8
    db $fb, $f8, $0a, $3a, $b6, $28, $5a, $f8
    db $04, $36, $00, $f8, $07, $2a, $4f, $46
    db $0a, $fe, $2f, $28, $09, $f8, $04, $36
    db $01, $21, $00, $da, $36, $2f, $f8, $04
    db $3a, $2b, $22, $af, $22, $77, $f8, $02
    db $3a, $2b, $22, $36, $da, $f8, $03, $5d
    db $54, $f8, $09, $1a, $13, $96, $23, $1a
    db $9e, $30, $1d, $f8, $02, $7e, $d6, $78
    db $30, $16, $34, $23, $79, $86, $23, $5f
    db $78, $8e, $57, $1a, $e1, $e5, $77, $f8
    db $03, $34, $20, $d2, $23, $34, $18, $ce
    db $e1, $36, $00, $e5, $21, $7f, $da, $36
    db $01, $e8, $05, $c9, $3b, $3b, $f8, $04
    db $2a, $4f, $46, $0a, $fe, $2f, $28, $04
    db $1e, $00, $18, $4b, $f8, $00, $af, $22
    db $16, $01, $72, $1e, $01, $7b, $3c, $20
    db $03, $5f, $18, $3b, $6b, $26, $00, $09
    db $7e, $b7, $28, $24, $fe, $20, $38, $04
    db $fe, $ff, $20, $04, $1e, $00, $18, $27
    db $fe, $2f, $20, $06, $53, $14, $f8, $00
    db $36, $00, $fe, $2e, $20, $04, $f8, $00
    db $36, $01, $1c, $f8, $01, $73, $18, $cd
    db $7a, $f8, $01, $96, $30, $07, $2b, $7e
    db $b7, $1e, $01, $20, $02, $1e, $00, $33
    db $33, $c9, $cd, $4f, $54, $1e, $00, $3e
    db $78, $93, $3e, $00, $17, $47, $cb, $40
    db $20, $0d, $21, $a6, $c2, $16, $00, $19
    db $7e, $b7, $28, $03, $1c, $18, $e8, $7b
    db $4f, $b7, $28, $24, $cb, $40, $20, $20
    db $06, $00, $78, $91, $30, $11, $58, $16
    db $da, $78, $c6, $a6, $6f, $3e, $00, $ce
    db $c2, $67, $7e, $12, $04, $18, $eb, $06
    db $da, $af, $02, $21, $7f, $da, $36, $01
    db $fa, $3a, $db, $b7, $20, $08, $21, $4c
    db $00, $e5, $cd, $20, $4c, $e1, $cd, $ad
    db $4e, $c3, $ab, $5a, $11, $a4, $c4, $d5
    db $cd, $fc, $5c, $e1, $7b, $b7, $28, $06
    db $21, $fb, $db, $36, $01, $c9, $cd, $4f
    db $54, $fa, $7f, $da, $b7, $28, $2f, $11
    db $00, $da, $d5, $cd, $fc, $5c, $e1, $7b
    db $b7, $28, $23, $0e, $00, $69, $26, $00
    db $11, $a4, $c4, $19, $59, $16, $da, $1a
    db $77, $1a, $b7, $28, $03, $0c, $18, $ed
    db $3e, $03, $f5, $33, $cd, $62, $4a, $33
    db $21, $fb, $db, $36, $01, $c9, $21, $01
    db $0f, $e5, $3e, $12, $f5, $33, $11, $28
    db $5e, $d5, $af, $0f, $f5, $af, $0f, $f5
    db $af, $0f, $f5, $cd, $00, $78, $e8, $0b
    db $cd, $88, $06, $cd, $4a, $3a, $cb, $6b
    db $28, $f6, $21, $fb, $db, $36, $00, $c9
    db $28, $6e, $6f, $6e, $65, $29, $00, $21
    db $fb, $db, $36, $00, $fa, $fd, $db, $b7
    db $c0, $01, $5f, $5e, $1e, $00, $21, $a5
    db $c3, $16, $00, $19, $56, $6b, $26, $00
    db $09, $7e, $92, $c0, $1c, $7b, $d6, $07
    db $38, $ec, $11, $a5, $c3, $d5, $cd, $fc
    db $5c, $e1, $7b, $ea, $fb, $db, $c9, $2f
    db $53, $41, $56, $45, $52, $2f

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    db $e8, $d6, $f8, $30, $2a, $5f, $2a, $57
    db $7e, $b7, $28, $04, $fe, $29, $38, $02
    db $3e, $28, $4f, $f8, $00, $1a, $22, $b7
    db $28, $05, $13, $0d, $20, $f7, $71, $f8
    db $35, $3a, $57, $3a, $5f, $3a, $47, $4e
    db $d5, $c5, $f8, $04, $e5, $cd, $8d, $07
    db $00, $4a, $0a, $00, $e8, $30, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    db $e8, $d6, $f8, $32, $2a, $5f, $2a, $57
    db $7e, $b7, $28, $04, $fe, $29, $38, $02
    db $3e, $28, $4f, $f8, $00, $1a, $22, $b7
    db $28, $05, $13, $0d, $20, $f7, $71, $f8
    db $36, $3a, $47, $3a, $4f, $7e, $c5, $f5
    db $33, $f8, $03, $e5, $cd, $8d, $07, $00
    db $40, $0a, $00, $e8, $2f, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    db $f5, $33, $11, $8f, $77, $d5, $af, $0f
    db $f5, $af, $0f, $f5, $af, $0f, $f5, $cd
    db $00, $75, $e8, $0b, $c3, $4e, $77, $cb
    db $41, $c2, $4e, $77, $21, $00, $00, $39
    db $e5, $af, $0f, $f5, $11, $7a, $77, $d5
    db $af, $0f, $f5, $af, $0f, $f5, $cd, $00
    db $71, $e8, $0a, $f8, $2c, $36, $00, $3e
    db $8b, $f8, $2c, $86, $2b, $4f, $3e, $77
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
    db $ce, $77, $32, $2a, $5f, $2a, $57, $1a
    db $96, $2b, $77, $f8, $2a, $3a, $22, $23
    db $3a, $c6, $7a, $22, $3e, $00, $ce, $77
    db $77, $af, $f5, $33, $f8, $29, $2a, $57
    db $2a, $5f, $d5, $2a, $5f, $56, $d5, $af
    db $0f, $f5, $af, $0f, $f5, $af, $0f, $f5
    db $cd, $00, $75, $e8, $0b, $f8, $2c, $34
    db $7e, $d6, $04, $da, $af, $76, $af, $67
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

LastRomName::
    db $f8, $09, $3a, $b6, $20, $24, $21, $c2
    db $db, $3e, $d0, $22, $36, $db, $2e, $ce
    db $36, $01, $cd, $60, $72, $21, $da, $db
    db $2a, $b6, $c8, $21, $c2, $db, $3e, $da
    db $22, $36, $db, $2e, $ce, $36, $01, $c3
    db $60, $72, $fa, $3f, $db, $fe, $02, $20
    db $0a, $cd, $91, $78, $21, $d9, $db, $36
    db $83, $18, $0a, $21, $da, $db, $af, $22
    db $77, $2e, $d9, $36, $8c, $11, $d0, $db
    db $f8, $08, $2a, $12, $13, $7e, $12, $21
    db $d6, $db, $36, $08, $2e, $d7, $36, $97
    db $f0, $fb, $b7, $28, $08, $2e, $d6, $36
    db $0c, $2e, $d7, $36, $9c, $01, $8e, $78
    db $21, $3f, $db, $6e, $26, $00, $09, $7e
    db $87, $87, $87, $21, $d8, $db, $77, $2e
    db $c2, $3e, $d0, $22, $36, $db, $2e, $ce
    db $36, $00, $cd, $60, $72, $fa, $3f, $db
    db $fe, $02, $ca, $91, $78, $c9, $0e, $07
    db $09, $0e, $0a, $11, $d0, $db, $1a, $47
    db $21, $0a, $00, $19, $7e, $12, $70, $0d
    db $13, $79, $b7, $20, $f1, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

FarCallPlayLoad::
    db $cd, $8d, $07, $00, $47, $0b, $00, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    db $f8, $37, $36, $13, $c3, $f6, $7e, $f8
    db $35, $2a, $5f, $56, $d5, $cd, $08, $04
    db $e1, $7b, $fe, $27, $30, $03, $f8, $2b
    db $77, $f8, $2c, $36, $ff, $1e, $00, $7b
    db $d6, $fe, $30, $17, $f8, $35, $2a, $83
    db $4f, $7e, $ce, $00, $47, $0a, $b7, $28
    db $0a, $fe, $2e, $20, $03, $f8, $2c, $73
    db $1c, $18, $e4, $f8, $01, $36, $c3, $f8
    db $2c, $7e, $3c, $ca, $df, $7e, $7b, $f8
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
    db $35, $2a, $c6, $fd, $4f, $7e, $ce, $00
    db $47, $0a, $fe, $2a, $20, $04, $f8, $01
    db $36, $7f, $f8, $37, $35, $7e, $f8, $02
    db $4d, $44, $f8, $01, $7e, $02, $f8, $2c
    db $36, $00, $f8, $2c, $3a, $96, $30, $23
    db $f8, $35, $7e, $f8, $2c, $86, $5f, $f5
    db $f8, $38, $f1, $7e, $ce, $00, $57, $1a
    db $5f, $b7, $28, $0f, $f8, $2c, $7e, $3c
    db $6f, $07, $9f, $67, $09, $73, $f8, $2c
    db $34, $18, $d7, $f8, $2c, $5e, $7b, $d6
    db $28, $30, $0a, $6b, $2c, $26, $00, $09
    db $36, $00, $1c, $18, $f1, $f0, $fb, $b7
    db $20, $29, $f8, $01, $5d, $54, $c5, $f8
    db $3b, $7e, $f5, $33, $21, $01, $00, $e5
    db $d5, $cd, $b7, $08, $e8, $05, $c1, $03
    db $f8, $39, $3a, $2b, $57, $1e, $01, $d5
    db $7e, $f5, $33, $c5, $cd, $b7, $08, $e8
    db $05, $18, $17, $f8, $39, $7e, $f5, $33
    db $af, $0f, $f5, $c5, $af, $0f, $f5, $af
    db $0f, $f5, $af, $0f, $f5, $cd, $00, $75
    db $e8, $0b, $e8, $2d, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
