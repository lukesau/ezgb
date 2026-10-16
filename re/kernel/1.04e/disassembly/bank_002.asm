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
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    db $ac, $43, $33, $c9, $e8, $fb, $f8, $02
    db $3e, $a4, $22, $36, $c4, $21, $a4, $c4
    db $36, $00, $cd, $91, $36, $4b, $f0, $f7
    db $b1, $07, $da, $f1, $45, $cd, $46, $46
    db $7b, $b7, $c2, $f1, $45, $21, $96, $d7
    db $36, $a0, $2e, $97, $36, $d7, $2e, $98
    db $36, $fe, $2e, $99, $36, $00, $f8, $00
    db $3e, $2f, $22, $36, $00, $f8, $04, $36
    db $00, $af, $f5, $33, $cd, $ac, $43, $33
    db $21, $00, $00, $39, $e5, $11, $00, $d9
    db $d5, $cd, $80, $43, $e8, $04, $7b, $b7
    db $c2, $f1, $45, $cd, $ff, $46, $11, $80
    db $d7, $d5, $11, $00, $d9, $d5, $cd, $96
    db $43, $e8, $04, $7b, $b7, $28, $09, $f8
    db $02, $2a, $66, $6f, $36, $00, $18, $71
    db $cd, $f4, $46, $7b, $b7, $20, $6a, $fa
    db $88, $d7, $cb, $67, $20, $d5, $cd, $e6
    db $46, $1a, $fe, $2e, $28, $cd, $d5, $01
    db $f4, $45, $c5, $d5, $cd, $ae, $46, $e8
    db $04, $7b, $d1, $b7, $20, $bd, $01, $fd
    db $45, $d5, $c5, $d5, $cd, $ae, $46, $e8
    db $04, $7b, $d1, $b7, $20, $ad, $01, $06
    db $46, $d5, $c5, $d5, $cd, $ae, $46, $e8
    db $04, $7b, $d1, $b7, $20, $9d, $f8, $04
    db $7e, $b7, $28, $08, $2b, $3a, $6e, $67
    db $36, $00, $18, $1d, $f8, $04, $36, $01
    db $d5, $d5, $cd, $10, $47, $e1, $7b, $d1
    db $b7, $ca, $63, $45, $d5, $11, $a4, $c4
    db $d5, $cd, $12, $46, $e8, $04, $c3, $63
    db $45, $e8, $05, $c9, $65, $7a, $67, $62
    db $2e, $64, $61, $74, $00, $65, $7a, $67
    db $62, $2e, $63, $66, $67, $00, $66, $6c
    db $61, $75, $6e, $63, $68, $2e, $63, $66
    db $67, $00, $3b, $f8, $03, $2a, $4f, $46
    db $3e, $2f, $02, $f8, $00, $36, $00, $f8
    db $05, $7e, $f8, $00, $86, $5f, $f5, $f8
    db $08, $f1, $7e, $ce, $00, $57, $1a, $5f
    db $f8, $00, $56, $af, $6a, $67, $23, $09
    db $7b, $b7, $28, $06, $73, $f8, $00, $34
    db $18, $dd, $36, $00, $33, $c9, $fa, $f9
    db $db, $b7, $20, $08, $21, $fc, $db, $36
    db $00, $cd, $00, $4a, $fa, $80, $da, $b7
    db $20, $03, $1e, $02, $c9, $fa, $81, $da
    db $b7, $20, $02, $5f, $c9, $0e, $00, $21
    db $81, $da, $46, $69, $26, $00, $11, $a4
    db $c4, $19, $79, $b8, $30, $0d, $c6, $82
    db $5f, $3e, $00, $ce, $da, $57, $1a, $77
    db $0c, $18, $e4, $36, $00, $1e, $01, $c9
    db $f8, $02, $7e, $d6, $61, $38, $0a, $3e
    db $7a, $96, $38, $05, $7e, $c6, $e0, $5f
    db $c9, $f8, $02, $5e, $c9, $1e, $00, $f8
    db $02, $2a, $83, $4f, $7e, $ce, $00, $47
    db $0a, $b7, $c8, $1c, $18, $f1, $16, $00
    db $f8, $02, $2a, $82, $4f, $7e, $ce, $00
    db $47, $0a, $d5, $f5, $33, $cd, $88, $46
    db $33, $f1, $57, $f8, $04, $2a, $82, $4f
    db $7e, $ce, $00, $47, $0a, $d5, $f5, $33
    db $cd, $88, $46, $33, $7b, $d1, $93, $28
    db $03, $1e, $00, $c9, $7b, $b7, $20, $03
    db $1e, $01, $c9, $14, $18, $ca, $fa, $a0
    db $d7, $b7, $28, $04, $11, $a0, $d7, $c9
    db $11, $89, $d7, $c9, $fa, $89, $d7, $b7
    db $3e, $01, $28, $01, $af, $5f, $c9, $af
    db $f5, $33, $cd, $ac, $43, $33, $21, $89
    db $d7, $36, $00, $2e, $a0, $36, $00, $c9
    db $3b, $3b, $f8, $04, $2a, $5f, $56, $d5
    db $cd, $9d, $46, $e1, $7b, $d6, $03, $30
    db $05, $1e, $00, $c3, $a6, $47, $f8, $00
    db $af, $22, $77, $16, $00, $7a, $93, $30
    db $17, $f8, $04, $2a, $82, $4f, $7e, $ce
    db $00, $47, $0a, $fe, $2e, $20, $06, $f8
    db $00, $7a, $22, $36, $01, $14, $18, $e5
    db $f8, $01, $7e, $b7, $20, $03, $5f, $18
    db $55, $f8, $00, $7e, $f8, $04, $86, $23
    db $4f, $3e, $00, $8e, $47, $69, $60, $23
    db $7e, $c5, $f5, $33, $cd, $88, $46, $33
    db $7b, $c1, $fe, $47, $20, $36, $69, $60
    db $23, $23, $7e, $c5, $f5, $33, $cd, $88
    db $46, $33, $7b, $c1, $fe, $42, $20, $24
    db $69, $60, $23, $23, $23, $7e, $b7, $20
    db $04, $1e, $01, $18, $19, $c5, $f5, $33
    db $cd, $88, $46, $33, $7b, $c1, $fe, $43
    db $20, $0a, $21, $04, $00, $09, $7e, $b7
    db $1e, $01, $28, $02, $1e, $00, $33, $33
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

LastRomBox::
    db $21, $3f, $db, $36, $00, $af, $0f, $f5
    db $af, $f5, $33, $cd, $d8, $23, $e8, $03
    db $f0, $fb, $b7, $c2, $a6, $48, $21, $8f
    db $01, $e5, $21, $58, $9f, $e5, $af, $f5
    db $33, $cd, $01, $24, $e8, $05, $af, $0f
    db $f5, $af, $3e, $03, $f5, $33, $cd, $d8
    db $23, $e8, $03, $21, $8b, $01, $e5, $21
    db $5b, $9f, $e5, $af, $f5, $33, $cd, $01
    db $24, $e8, $05, $21, $01, $0c, $e5, $3e
    db $10, $f5, $33, $11, $35, $49, $d5, $cd
    db $b7, $08, $e8, $05, $21, $01, $10, $e5
    db $3e, $09, $f5, $33, $11, $46, $49, $d5
    db $cd, $b7, $08, $e8, $05, $21, $0b, $10
    db $e5, $3e, $08, $f5, $33, $11, $52, $49
    db $d5, $cd, $b7, $08, $e8, $05, $af, $67
    db $2e, $03, $e5, $3e, $03, $f5, $33, $cd
    db $d8, $23, $e8, $03, $21, $7b, $01, $e5
    db $21, $6b, $9f, $e5, $af, $f5, $33, $cd
    db $01, $24, $e8, $05, $21, $8b, $01, $e5
    db $21, $7b, $53, $e5, $3e, $53, $f5, $33
    db $cd, $01, $24, $e8, $05, $c9, $af, $0f
    db $f5, $af, $3e, $03, $f5, $33, $cd, $d8
    db $23, $e8, $03, $21, $8f, $01, $e5, $21
    db $5c, $9f, $e5, $af, $f5, $33, $cd, $01
    db $24, $e8, $05, $21, $01, $60, $e5, $af
    db $f5, $33, $11, $35, $49, $d5, $af, $0f
    db $f5, $af, $0f, $f5, $af, $0f, $f5, $cd
    db $00, $75, $e8, $0b, $21, $01, $80, $e5
    db $af, $f5, $33, $11, $46, $49, $d5, $af
    db $0f, $f5, $af, $0f, $f5, $af, $0f, $f5
    db $cd, $00, $75, $e8, $0b, $21, $8f, $00
    db $e5, $21, $5c, $9f, $e5, $af, $f5, $33
    db $cd, $01, $24, $e8, $05, $af, $67, $2e
    db $03, $e5, $3e, $03, $f5, $33, $cd, $d8
    db $23, $e8, $03, $21, $7d, $01, $e5, $21
    db $6d, $9f, $e5, $af, $f5, $33, $cd, $01
    db $24, $e8, $05, $21, $8f, $01, $e5, $21
    db $7d, $4f, $e5, $3e, $4f, $f5, $33, $cd
    db $01, $24, $e8, $05, $c9, $4c, $61, $75
    db $6e, $63, $68, $20, $4c, $61, $73, $74
    db $20, $52, $4f, $4d, $3f, $00, $5b, $42
    db $5d, $72, $65, $74, $75, $72, $6e, $20
    db $20, $20, $5b, $41, $5d, $73, $74, $61
    db $72, $74, $00

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    db $fa, $fc, $db, $b7, $ca, $64, $53, $fe
    db $01, $ca, $07, $5a, $fe, $02, $20, $08
    db $af, $f5, $33, $cd, $7f, $4c, $33, $c9
    db $fe, $06, $20, $09, $3e, $01, $f5, $33
    db $cd, $7f, $4c, $33, $c9, $fe, $07, $20
    db $13, $fa, $3a, $db, $b7, $c0, $cd, $64
    db $53, $21, $4c, $00, $e5, $cd, $1f, $4c
    db $e1, $c3, $07, $5a, $fe, $04, $ca, $86
    db $5c, $fe, $05, $ca, $e0, $5c, $fe, $08
    db $ca, $5b, $5d, $fe, $09, $c2, $fd, $4d
    db $cd, $64, $53, $cd, $b2, $4d, $7b, $21
    db $00, $40, $36, $00, $b7, $c2, $07, $5a
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
    db $3a, $db, $b7, $c0, $cd, $64, $53, $f8
    db $02, $7e, $b7, $3e, $54, $20, $02, $3e
    db $42, $f8, $02, $66, $e5, $33, $f5, $33
    db $cd, $1f, $4c, $e1, $c3, $07, $5a, $e8
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
    db $f0, $f7, $4f, $c5, $cd, $91, $36, $7b
    db $c1, $b1, $e0, $f7, $cd, $59, $4d, $cd
    db $64, $53, $cd, $d8, $4d, $fa, $3a, $db
    db $b7, $c0, $fa, $47, $db, $b7, $c8, $cd
    db $9c, $4a, $cd, $22, $4d, $7b, $b7, $c8
    db $cd, $9f, $4c, $cd, $22, $4d, $7b, $b7
    db $c8, $d5, $7b, $f5, $33, $cd, $83, $4f
    db $33, $7b, $d1, $b7, $28, $09, $11, $40
    db $db, $d5, $cd, $e4, $4a, $e1, $c9, $7b
    db $d6, $56, $c0, $11, $48, $db, $d5, $cd
    db $e4, $4a, $e1, $c9, $f8, $04, $7e, $cb
    db $37, $e6, $0f, $4e, $2b, $2b, $f5, $79
    db $e6, $0f, $4f, $f1, $5e, $23, $56, $47
    db $d6, $0a, $30, $05, $78, $c6, $30, $18
    db $03, $78, $c6, $37, $12, $13, $41, $79
    db $d6, $0a, $30, $05, $78, $c6, $30, $18
    db $03, $78, $c6, $37, $12, $c9, $f8, $04
    db $2a, $c6, $06, $4f, $7e, $ce, $00, $47
    db $0a, $f5, $33, $f8, $03, $2a, $5f, $56
    db $d5, $cd, $54, $4e, $e8, $03, $f8, $02
    db $2a, $4f, $2a, $47, $03, $03, $3e, $2d
    db $02, $2a, $c6, $05, $4f, $7e, $ce, $00
    db $69, $67, $46, $f8, $02, $2a, $5f, $56
    db $13, $13, $13, $c5, $33, $d5, $cd, $54
    db $4e, $e8, $03, $f8, $02, $2a, $c6, $05
    db $4f, $7e, $ce, $00, $69, $67, $36, $2d
    db $f8, $04, $2a, $4f, $46, $03, $03, $03
    db $0a, $47, $f8, $02, $2a, $c6, $06, $4f
    db $7e, $ce, $00, $c5, $33, $47, $c5, $cd
    db $54, $4e, $e8, $03, $c9, $f8, $04, $2a
    db $4f, $46, $03, $03, $0a, $f5, $33, $f8
    db $03, $2a, $5f, $56, $d5, $cd, $54, $4e
    db $e8, $03, $f8, $02, $2a, $4f, $2a, $47
    db $03, $03, $3e, $3a, $02, $2a, $4f, $46
    db $03, $0a, $57, $f8, $02, $2a, $4f, $46
    db $03, $03, $03, $d5, $33, $c5, $cd, $54
    db $4e, $e8, $03, $f8, $02, $2a, $c6, $05
    db $4f, $7e, $ce, $00, $69, $67, $36, $3a
    db $f8, $04, $2a, $4f, $46, $0a, $47, $f8
    db $02, $2a, $c6, $06, $4f, $7e, $ce, $00
    db $c5, $33, $47, $c5, $cd, $54, $4e, $e8
    db $03, $c9, $f0, $fb, $b7, $28, $1f, $f8
    db $08, $3a, $57, $5e, $d5, $f8, $06, $3a
    db $2b, $f5, $33, $2a, $5f, $56, $d5, $af
    db $0f, $f5, $af, $0f, $f5, $af, $0f, $f5
    db $cd, $00, $75, $e8, $0b, $c9, $f8, $06
    db $3a, $57, $3a, $5f, $d5, $3a, $2b, $f5
    db $33, $2a, $5f, $56, $d5, $cd, $b7, $08
    db $e8, $05, $c9, $e8, $f5, $f8, $0d, $7e
    db $d6, $5a, $20, $05, $01, $49, $52, $18
    db $1b, $f8, $0d, $7e, $d6, $49, $20, $05
    db $01, $54, $52, $18, $0f, $f8, $0d, $7e
    db $d6, $56, $20, $05, $01, $5d, $52, $18
    db $03, $01, $68, $52, $1e, $00, $6b, $26
    db $00, $09, $7e, $b7, $28, $03, $1c, $18
    db $f5, $f8, $00, $73, $f0, $fb, $f8, $0a
    db $32, $36, $00, $c5, $21, $05, $08, $e5
    db $3e, $01, $f5, $33, $11, $47, $52, $d5
    db $cd, $b7, $08, $e8, $05, $af, $0f, $f5
    db $af, $f5, $33, $cd, $d8, $23, $e8, $03
    db $21, $7f, $01, $e5, $21, $10, $9f, $e5
    db $af, $f5, $33, $cd, $01, $24, $e8, $05
    db $af, $0f, $f5, $af, $3e, $03, $f5, $33
    db $cd, $d8, $23, $e8, $03, $c1, $f8, $0a
    db $7e, $b7, $28, $14, $c5, $21, $73, $01
    db $e5, $21, $14, $9f, $e5, $af, $f5, $33
    db $cd, $01, $24, $e8, $05, $c1, $18, $12
    db $c5, $21, $63, $01, $e5, $21, $1b, $9f
    db $e5, $af, $f5, $33, $cd, $01, $24, $e8
    db $05, $c1, $21, $01, $18, $e5, $21, $01
    db $04, $e5, $f8, $04, $7e, $f5, $33, $c5
    db $cd, $4a, $4f, $e8, $07, $21, $01, $2c
    db $e5, $21, $01, $06, $e5, $3e, $04, $f5
    db $33, $11, $74, $52, $d5, $cd, $4a, $4f
    db $e8, $07, $21, $01, $00, $39, $e5, $11
    db $50, $db, $d5, $e5, $cd, $86, $4e, $e8
    db $04, $e1, $e5, $11, $3c, $2c, $d5, $11
    db $06, $06, $d5, $3e, $08, $f5, $33, $e5
    db $cd, $4a, $4f, $e8, $07, $e1, $e5, $11
    db $50, $db, $d5, $e5, $cd, $ed, $4e, $e8
    db $04, $e1, $e5, $11, $3c, $38, $d5, $11
    db $06, $07, $d5, $3e, $08, $f5, $33, $e5
    db $cd, $4a, $4f, $e8, $07, $21, $01, $44
    db $e5, $21, $01, $08, $e5, $3e, $02, $f5
    db $33, $11, $79, $52, $d5, $cd, $4a, $4f
    db $e8, $07, $e1, $e5, $11, $40, $db, $d5
    db $e5, $cd, $86, $4e, $e8, $04, $e1, $e5
    db $11, $3c, $44, $d5, $11, $06, $08, $d5
    db $3e, $08, $f5, $33, $e5, $cd, $4a, $4f
    db $e8, $07, $e1, $e5, $11, $40, $db, $d5
    db $e5, $cd, $ed, $4e, $e8, $04, $e1, $11
    db $3c, $50, $d5, $11, $06, $09, $d5, $3e
    db $08, $f5, $33, $e5, $cd, $4a, $4f, $e8
    db $07, $f8, $0a, $7e, $b7, $ca, $74, $51
    db $21, $01, $64, $e5, $3e, $07, $f5, $33
    db $11, $7c, $52, $d5, $af, $0f, $f5, $af
    db $0f, $f5, $af, $0f, $f5, $cd, $00, $75
    db $e8, $0b, $21, $58, $64, $e5, $af, $f5
    db $33, $11, $86, $52, $d5, $af, $0f, $f5
    db $af, $0f, $f5, $af, $0f, $f5, $cd, $00
    db $75, $e8, $0b, $21, $73, $00, $e5, $21
    db $14, $9f, $e5, $af, $f5, $33, $cd, $01
    db $24, $e8, $05, $af, $67, $2e, $03, $e5
    db $3e, $03, $f5, $33, $cd, $d8, $23, $e8
    db $03, $21, $26, $01, $e5, $21, $26, $9f
    db $e5, $af, $f5, $33, $cd, $01, $24, $e8
    db $05, $21, $5f, $01, $e5, $21, $5f, $9f
    db $e5, $af, $f5, $33, $cd, $01, $24, $e8
    db $05, $21, $73, $01, $e5, $21, $5f, $4f
    db $e5, $3e, $4f, $f5, $33, $cd, $01, $24
    db $e8, $05, $18, $61, $21, $01, $0b, $e5
    db $3e, $07, $f5, $33, $11, $7c, $52, $d5
    db $cd, $b7, $08, $e8, $05, $21, $0a, $0b
    db $e5, $3e, $09, $f5, $33, $11, $86, $52
    db $d5, $cd, $b7, $08, $e8, $05, $af, $67
    db $2e, $03, $e5, $3e, $03, $f5, $33, $cd
    db $d8, $23, $e8, $03, $21, $2b, $01, $e5
    db $21, $2b, $9f, $e5, $af, $f5, $33, $cd
    db $01, $24, $e8, $05, $21, $53, $01, $e5
    db $21, $53, $9f, $e5, $af, $f5, $33, $cd
    db $01, $24, $e8, $05, $21, $63, $01, $e5
    db $21, $53, $4b, $e5, $3e, $4b, $f5, $33
    db $cd, $01, $24, $e8, $05, $af, $0f, $f5
    db $af, $3e, $03, $f5, $33, $cd, $d8, $23
    db $e8, $03, $f8, $0a, $36, $00, $cd, $88
    db $06, $cd, $91, $36, $7b, $e6, $30, $28
    db $06, $f8, $0a, $36, $00, $18, $03, $f8
    db $0a, $34, $f8, $0a, $7e, $d6, $08, $38
    db $e5, $cd, $88, $06, $cd, $91, $36, $cb
    db $63, $28, $06, $f8, $0a, $36, $01, $18
    db $08, $cb, $6b, $28, $ec, $f8, $0a, $36
    db $00, $cd, $91, $36, $7b, $e6, $30, $28
    db $05, $cd, $88, $06, $18, $f3, $af, $0f
    db $f5, $af, $f5, $33, $cd, $d8, $23, $e8
    db $03, $21, $7f, $01, $e5, $21, $10, $9f
    db $e5, $af, $f5, $33, $cd, $01, $24, $e8
    db $05, $f8, $0a, $5e, $e8, $0b, $c9, $20
    db $00, $52, $54, $43, $20, $52, $45, $53
    db $45, $54, $3f, $00, $52, $54, $43, $20
    db $42, $41, $44, $3f, $00, $52, $54, $43
    db $20, $4c, $4f, $57, $20, $56, $3f, $00
    db $52, $54, $43, $20, $42, $45, $48, $49
    db $4e, $44, $3f, $00, $43, $48, $49, $50
    db $00, $53, $44, $00, $5b, $42, $5d, $6b
    db $65, $65, $70, $20, $20, $20, $5b, $41
    db $5d, $75, $73, $65, $20, $53, $44, $00
    db $3b, $f8, $00, $36, $00, $f8, $00, $5e
    db $16, $db, $f8, $03, $7e, $f8, $00, $86
    db $23, $23, $23, $23, $4f, $7e, $ce, $00
    db $47, $0a, $12, $0a, $b7, $28, $05, $f8
    db $00, $34, $18, $e1, $33, $c9, $f8, $02
    db $2a, $5f, $56, $d5, $cd, $90, $52, $e1
    db $cd, $91, $4a, $3e, $01, $f5, $33, $11
    db $00, $db, $d5, $11, $0f, $ca, $d5, $cd
    db $0d, $19, $e8, $05, $7b, $b7, $28, $03
    db $1e, $00, $c9, $cd, $91, $4a, $f8, $04
    db $2a, $5f, $56, $d5, $11, $00, $02, $d5
    db $11, $00, $d8, $d5, $11, $0f, $ca, $d5
    db $cd, $28, $19, $e8, $08, $d5, $cd, $91
    db $4a, $01, $0f, $ca, $c5, $cd, $88, $19
    db $e1, $d1, $f8, $04, $2a, $4f, $46, $7b
    db $b7, $28, $06, $af, $02, $03, $02, $18
    db $17, $69, $60, $2a, $66, $6f, $3e, $ff
    db $bd, $3e, $00, $9c, $30, $0a, $7c, $d6
    db $02, $30, $05, $7d, $02, $03, $af, $02
    db $1e, $01, $c9, $3b, $3b, $cd, $91, $4a
    db $f8, $00, $e5, $f8, $08, $2a, $5f, $56
    db $d5, $f8, $08, $2a, $5f, $56, $d5, $11
    db $0f, $ca, $d5, $cd, $4a, $19, $e8, $08
    db $7b, $b7, $20, $15, $f8, $00, $7e, $f8
    db $06, $96, $20, $0b, $f8, $01, $7e, $f8
    db $07, $96, $20, $03, $5f, $18, $02, $1e
    db $ff, $33, $33, $c9, $3b, $3b, $21, $f9
    db $db, $36, $01, $21, $80, $da, $36, $01
    db $2e, $81, $36, $00, $2e, $82, $36, $00
    db $21, $47, $db, $36, $00, $21, $7f, $da
    db $36, $00, $2e, $00, $75, $21, $3a, $db
    db $36, $00, $2e, $57, $36, $ff, $f8, $00
    db $e5, $e5, $11, $d0, $53, $d5, $cd, $b6
    db $52, $e8, $04, $7b, $e1, $b7, $28, $10
    db $af, $f5, $33, $f8, $01, $2a, $5f, $56
    db $d5, $cd, $e7, $53, $e8, $03, $18, $1d
    db $e5, $11, $da, $53, $d5, $cd, $b6, $52
    db $e8, $04, $7b, $b7, $28, $0f, $3e, $01
    db $f5, $33, $f8, $01, $2a, $5f, $56, $d5
    db $cd, $e7, $53, $e8, $03, $33, $33, $c9
    db $2f, $45, $5a, $47, $42, $2e, $43, $46
    db $47, $00, $2f, $46, $4c, $41, $55, $4e
    db $43, $48, $2e, $43, $46, $47, $00, $e8
    db $ed, $f8, $15, $af, $96, $23, $3e, $02
    db $9e, $30, $06, $f8, $15, $af, $22, $36
    db $02, $f8, $15, $2a, $4f, $7e, $c6, $d8
    db $47, $af, $02, $f8, $00, $af, $22, $22
    db $af, $22, $22, $af, $22, $22, $af, $22
    db $77, $f8, $06, $5d, $54, $f8, $15, $1a
    db $13, $96, $23, $1a, $9e, $d2, $df, $57
    db $f8, $06, $2a, $4f, $46, $f8, $15, $79
    db $96, $23, $78, $9e, $30, $0c, $21, $00
    db $d8, $09, $7e, $fe, $20, $20, $03, $03
    db $18, $eb, $f8, $0e, $79, $22, $78, $22
    db $23, $79, $22, $70, $f8, $11, $5d, $54
    db $f8, $15, $1a, $13, $96, $23, $1a, $9e
    db $30, $2a, $f8, $11, $7e, $f5, $f8, $0e
    db $f1, $77, $f5, $f8, $14, $f1, $7e, $c6
    db $d8, $f8, $0d, $32, $2a, $5f, $56, $1a
    db $fe, $0d, $28, $10, $fe, $0a, $28, $0c
    db $b7, $28, $09, $f8, $11, $34, $20, $cc
    db $23, $34, $18, $c8, $f8, $11, $7e, $f8
    db $08, $77, $f8, $12, $7e, $f8, $09, $77
    db $f8, $11, $2a, $4f, $46, $f8, $15, $79
    db $96, $23, $78, $9e, $30, $1d, $21, $00
    db $d8, $09, $e5, $7d, $f8, $13, $77, $e1
    db $7c, $f8, $12, $32, $2a, $5f, $56, $1a
    db $fe, $0d, $28, $04, $fe, $0a, $20, $03
    db $03, $18, $da, $f8, $06, $79, $22, $78
    db $22, $2a, $4f, $7e, $c6, $d8, $47, $0a
    db $b7, $20, $1a, $f8, $08, $5d, $54, $f8
    db $15, $1a, $13, $96, $23, $1a, $9e, $30
    db $0c, $f8, $15, $7e, $f8, $06, $77, $f8
    db $16, $7e, $f8, $07, $77, $f8, $0e, $5d
    db $54, $f8, $08, $1a, $13, $96, $23, $1a
    db $9e, $30, $36, $f8, $08, $2a, $23, $23
    db $23, $c6, $ff, $32, $2b, $2b, $7e, $ce
    db $ff, $f8, $0d, $32, $7e, $f5, $f8, $13
    db $f1, $32, $2b, $2b, $2b, $7e, $c6, $d8
    db $f8, $12, $32, $2a, $5f, $56, $1a, $fe
    db $20, $20, $0e, $f8, $0c, $7e, $f8, $08
    db $77, $f8, $0d, $7e, $f8, $09, $77, $18
    db $bc, $f8, $08, $7e, $f8, $0e, $96, $20
    db $09, $f8, $09, $7e, $f8, $0f, $96, $ca
    db $11, $54, $f8, $08, $4e, $f8, $0e, $46
    db $3a, $2b, $2b, $2b, $77, $f5, $f8, $11
    db $f1, $7e, $c6, $d8, $f8, $0b, $77, $f8
    db $17, $7e, $b7, $28, $12, $79, $90, $f5
    db $33, $f8, $0b, $2a, $5f, $56, $d5, $cd
    db $59, $58, $e8, $03, $c3, $df, $57, $f8
    db $0e, $2a, $5f, $56, $f8, $08, $7b, $96
    db $23, $7a, $9e, $3e, $00, $17, $f8, $12
    db $77, $6b, $62, $23, $e5, $7d, $f8, $12
    db $77, $e1, $7c, $f8, $11, $22, $7e, $b7
    db $28, $10, $21, $00, $d8, $19, $7e, $fe
    db $3d, $28, $07, $f8, $10, $2a, $5f, $56
    db $18, $d2, $f8, $12, $cb, $46, $ca, $11
    db $54, $7b, $90, $f8, $12, $32, $2b, $2a
    db $5f, $56, $f8, $12, $7e, $b7, $28, $1e
    db $3a, $2b, $22, $af, $32, $3a, $2b, $86
    db $23, $47, $3e, $00, $8e, $68, $67, $2b
    db $7c, $c6, $d8, $67, $7e, $fe, $20, $20
    db $05, $f8, $12, $35, $18, $dc, $f8, $12
    db $7e, $f8, $0c, $77, $f8, $11, $7b, $22
    db $72, $f8, $11, $3a, $2b, $22, $23, $23
    db $3a, $2b, $c6, $d8, $77, $f8, $11, $5d
    db $54, $f8, $08, $1a, $13, $96, $23, $1a
    db $9e, $30, $12, $f8, $0f, $2a, $5f, $56
    db $1a, $fe, $20, $20, $08, $23, $34, $20
    db $d8, $23, $34, $18, $d4, $f8, $11, $7e
    db $f8, $0d, $77, $f8, $12, $7e, $f8, $0e
    db $77, $f8, $00, $7e, $b7, $20, $35, $c5
    db $3e, $07, $f5, $33, $11, $e2, $57, $d5
    db $f8, $11, $3a, $2b, $f5, $33, $2a, $5f
    db $56, $d5, $cd, $1d, $58, $e8, $06, $7b
    db $c1, $b7, $28, $18, $f8, $00, $36, $01
    db $f8, $11, $79, $96, $2b, $2b, $f5, $33
    db $2a, $5f, $56, $d5, $cd, $59, $58, $e8
    db $03, $c3, $11, $54, $f8, $0d, $2a, $23
    db $32, $2a, $23, $c6, $d8, $77, $f8, $01
    db $7e, $b7, $20, $35, $c5, $3e, $03, $f5
    db $33, $11, $ea, $57, $d5, $f8, $11, $3a
    db $2b, $f5, $33, $2a, $5f, $56, $d5, $cd
    db $1d, $58, $e8, $06, $7b, $c1, $b7, $28
    db $18, $f8, $01, $36, $01, $f8, $0d, $79
    db $96, $23, $23, $f5, $33, $2a, $5f, $56
    db $d5, $cd, $e7, $58, $e8, $03, $c3, $11
    db $54, $f8, $08, $7e, $f8, $0d, $96, $23
    db $23, $23, $23, $77, $f5, $f8, $0b, $f1
    db $7e, $f5, $f8, $10, $f1, $9e, $f8, $12
    db $77, $f8, $02, $7e, $b7, $20, $33, $3e
    db $07, $f5, $33, $11, $ee, $57, $d5, $f8
    db $0f, $3a, $2b, $f5, $33, $2a, $5f, $56
    db $d5, $cd, $1d, $58, $e8, $06, $7b, $b7
    db $28, $18, $f8, $02, $36, $01, $f8, $11
    db $2a, $5f, $56, $d5, $f8, $11, $2a, $5f
    db $56, $d5, $cd, $c3, $5b, $e8, $04, $c3
    db $11, $54, $f8, $03, $7e, $b7, $20, $69
    db $3e, $02, $f5, $33, $11, $f6, $57, $d5
    db $f8, $0f, $3a, $2b, $f5, $33, $2a, $5f
    db $56, $d5, $cd, $1d, $58, $e8, $06, $7b
    db $b7, $28, $4e, $f8, $03, $36, $01, $f8
    db $11, $2a, $d6, $02, $7e, $de, $00, $38
    db $34, $2b, $2b, $2b, $2a, $5f, $56, $1a
    db $fe, $31, $20, $29, $f8, $0d, $2a, $23
    db $23, $23, $c6, $01, $32, $2b, $2b, $7e
    db $ce, $00, $f8, $12, $32, $3a, $2b, $22
    db $23, $23, $3a, $2b, $c6, $d8, $32, $2a
    db $5f, $56, $1a, $fe, $32, $20, $06, $23
    db $23, $36, $01, $18, $04, $f8, $12, $36
    db $00, $f8, $12, $7e, $e0, $fb, $c3, $11
    db $54, $f8, $04, $7e, $b7, $20, $4a, $3e
    db $05, $f5, $33, $11, $f9, $57, $d5, $f8
    db $0f, $3a, $2b, $f5, $33, $2a, $5f, $56
    db $d5, $cd, $1d, $58, $e8, $06, $7b, $b7
    db $28, $2f, $f8, $04, $36, $01, $f8, $0d
    db $5d, $54, $f8, $08, $1a, $13, $96, $23
    db $1a, $9e, $30, $10, $f8, $0f, $2a, $5f
    db $56, $1a, $fe, $30, $20, $06, $23, $23
    db $36, $01, $18, $04, $f8, $12, $36, $00
    db $f8, $12, $7e, $ea, $3a, $db, $c3, $11
    db $54, $f8, $05, $7e, $b7, $c2, $11, $54
    db $3e, $08, $f5, $33, $11, $ff, $57, $d5
    db $f8, $0f, $3a, $2b, $f5, $33, $2a, $5f
    db $56, $d5, $cd, $1d, $58, $e8, $06, $7b
    db $b7, $ca, $11, $54, $f8, $05, $36, $01
    db $f8, $11, $2a, $3d, $b6, $c2, $11, $54
    db $f8, $0f, $2a, $5f, $56, $1a, $fe, $30
    db $28, $05, $fe, $31, $c2, $11, $54, $c6
    db $d0, $ea, $57, $db, $c3, $11, $54, $e8
    db $13, $c9, $66, $6c, $61, $75, $6e, $63
    db $68, $00, $72, $74, $63, $00, $6c, $61
    db $73, $74, $72, $6f, $6d, $00, $75, $69
    db $00, $72, $74, $63, $73, $64, $00, $61
    db $75, $74, $6f, $73, $61, $76, $65, $00
    db $f8, $02, $7e, $d6, $41, $38, $0a, $3e
    db $5a, $96, $38, $05, $7e, $c6, $20, $5f
    db $c9, $f8, $02, $5e, $c9, $f8, $04, $7e
    db $f8, $07, $96, $28, $03, $1e, $00, $c9
    db $16, $00, $7a, $f8, $04, $96, $30, $26
    db $2b, $2b, $2a, $82, $4f, $7e, $ce, $00
    db $47, $0a, $d5, $f5, $33, $cd, $08, $58
    db $33, $f1, $57, $f8, $05, $2a, $82, $4f
    db $7e, $ce, $00, $47, $0a, $93, $28, $03
    db $1e, $00, $c9, $14, $18, $d4, $1e, $01
    db $c9, $3b, $3b, $f8, $01, $36, $00, $f8
    db $06, $7e, $b7, $28, $26, $2b, $2b, $2a
    db $4f, $46, $0a, $fe, $23, $20, $1c, $21
    db $80, $da, $36, $00, $1e, $01, $7b, $f8
    db $06, $96, $30, $0c, $6b, $26, $00, $09
    db $7e, $fe, $20, $20, $03, $1c, $18, $ee
    db $f8, $01, $73, $f8, $01, $7e, $f8, $06
    db $96, $30, $51, $0e, $00, $f8, $04, $7e
    db $f8, $01, $86, $23, $23, $23, $23, $5f
    db $7e, $ce, $00, $57, $1a, $fe, $2f, $28
    db $07, $0e, $01, $21, $82, $da, $36, $2f
    db $f8, $01, $46, $79, $c6, $82, $f5, $f8
    db $02, $f1, $22, $3e, $00, $ce, $da, $77
    db $78, $f8, $06, $96, $30, $16, $79, $d6
    db $78, $30, $11, $2b, $2b, $0c, $2a, $80
    db $5f, $7e, $ce, $00, $57, $1a, $e1, $e5
    db $77, $04, $18, $d7, $e1, $36, $00, $e5
    db $21, $81, $da, $71, $33, $33, $c9, $e8
    db $f2, $0e, $00, $59, $16, $00, $21, $02
    db $00, $39, $19, $36, $00, $0c, $79, $d6
    db $06, $38, $f0, $f8, $08, $af, $22, $22
    db $23, $af, $22, $22, $36, $00, $f8, $0d
    db $7e, $f8, $12, $96, $30, $12, $2b, $2b
    db $7e, $f8, $0d, $86, $23, $23, $23, $23
    db $4f, $7e, $ce, $00, $47, $0a, $18, $01
    db $af, $f8, $0a, $77, $d6, $30, $38, $11
    db $3e, $39, $96, $38, $0c, $2b, $3a, $22
    db $23, $3a, $c6, $d0, $22, $23, $34, $18
    db $30, $f8, $0b, $7e, $b7, $28, $1e, $23
    db $7e, $d6, $06, $30, $18, $5e, $16, $00
    db $21, $02, $00, $39, $19, $d1, $e5, $f8
    db $0c, $34, $f8, $08, $2a, $cb, $37, $e6
    db $f0, $b6, $e1, $e5, $77, $f8, $08, $af
    db $22, $22, $23, $af, $32, $7e, $b7, $28
    db $0b, $f8, $0d, $34, $f8, $12, $7e, $f8
    db $0d, $96, $30, $92, $f8, $0c, $7e, $d6
    db $06, $38, $35, $f8, $02, $7e, $ea, $46
    db $db, $f8, $03, $7e, $ea, $45, $db, $f8
    db $04, $7e, $21, $43, $db, $77, $2e, $44
    db $36, $03, $f8, $05, $7e, $ea, $42, $db
    db $f8, $06, $7e, $ea, $41, $db, $f8, $07
    db $7e, $ea, $40, $db, $11, $40, $db, $d5
    db $cd, $45, $4b, $e1, $7b, $ea, $47, $db
    db $e8, $0e, $c9, $f8, $02, $2a, $4f, $2a
    db $47, $7e, $cb, $37, $e6, $0f, $c6, $30
    db $02, $03, $7e, $e6, $0f, $c6, $30, $02
    db $1e, $02, $c9, $f8, $04, $2a, $4f, $46
    db $f8, $02, $2a, $5f, $56, $f8, $06, $7e
    db $6f, $3d, $2c, $2d, $c8, $f5, $0a, $6f
    db $f1, $03, $f5, $7d, $12, $f1, $13, $18
    db $ef, $f8, $02, $2a, $4f, $3a, $47, $3e
    db $0d, $02, $03, $79, $22, $78, $32, $2a
    db $4f, $3a, $47, $3e, $0a, $02, $03, $79
    db $22, $78, $32, $2a, $5f, $56, $c9, $e8
    db $fb, $3e, $08, $f5, $33, $11, $95, $5b
    db $d5, $11, $00, $d8, $d5, $cd, $cb, $59
    db $e8, $05, $4b, $42, $fa, $80, $da, $b7
    db $20, $04, $3e, $23, $02, $03, $fa, $81
    db $da, $f5, $33, $11, $82, $da, $d5, $c5
    db $cd, $cb, $59, $e8, $05, $d5, $cd, $e9
    db $59, $e1, $4b, $42, $fa, $47, $db, $b7
    db $28, $58, $3e, $06, $f5, $33, $11, $9d
    db $5b, $d5, $c5, $cd, $cb, $59, $e8, $05
    db $f8, $04, $36, $00, $3e, $d7, $f8, $04
    db $86, $4f, $3e, $4a, $ce, $00, $47, $0a
    db $6f, $26, $00, $01, $40, $db, $09, $7e
    db $d5, $f5, $33, $d5, $cd, $b3, $59, $e8
    db $03, $7b, $d1, $83, $4f, $3e, $00, $8a
    db $47, $f8, $04, $7e, $d6, $05, $28, $13
    db $3e, $a3, $f8, $04, $86, $5f, $3e, $5b
    db $ce, $00, $57, $1a, $02, $59, $50, $13
    db $34, $18, $c1, $c5, $cd, $e9, $59, $e1
    db $4b, $42, $fa, $7f, $da, $b7, $28, $21
    db $3e, $08, $f5, $33, $11, $a8, $5b, $d5
    db $c5, $cd, $cb, $59, $e8, $05, $01, $00
    db $da, $0a, $b7, $28, $05, $03, $12, $13
    db $18, $f7, $d5, $cd, $e9, $59, $e1, $4b
    db $42, $3e, $03, $f5, $33, $11, $b0, $5b
    db $d5, $c5, $cd, $cb, $59, $e8, $05, $4b
    db $42, $f0, $fb, $b7, $28, $04, $3e, $31
    db $02, $03, $d1, $c5, $03, $f8, $02, $79
    db $22, $70, $f0, $fb, $b7, $28, $05, $23
    db $36, $32, $18, $04, $f8, $04, $36, $38
    db $f8, $04, $7e, $e1, $e5, $77, $f8, $02
    db $2a, $5f, $56, $d5, $cd, $e9, $59, $e1
    db $4b, $42, $fa, $3a, $db, $b7, $28, $15
    db $3e, $07, $f5, $33, $11, $b3, $5b, $d5
    db $c5, $cd, $cb, $59, $e8, $05, $d5, $cd
    db $e9, $59, $e1, $4b, $42, $fa, $57, $db
    db $fe, $02, $30, $1e, $3e, $09, $f5, $33
    db $11, $ba, $5b, $d5, $c5, $cd, $cb, $59
    db $e8, $05, $4b, $42, $fa, $57, $db, $c6
    db $30, $02, $03, $c5, $cd, $e9, $59, $e1
    db $4b, $42, $69, $60, $7c, $d6, $da, $30
    db $05, $3e, $20, $22, $18, $f6, $11, $8b
    db $5b, $d5, $cd, $90, $52, $e1, $cd, $91
    db $4a, $3e, $0a, $f5, $33, $11, $00, $db
    db $d5, $11, $0f, $ca, $d5, $cd, $0d, $19
    db $e8, $05, $7b, $b7, $20, $1a, $11, $00
    db $02, $d5, $11, $00, $d8, $d5, $cd, $2b
    db $53, $e8, $04, $d5, $cd, $91, $4a, $01
    db $0f, $ca, $c5, $cd, $88, $19, $e1, $d1
    db $e8, $05, $c9, $2f, $45, $5a, $47, $42
    db $2e, $43, $46, $47, $00, $46, $4c, $41
    db $55, $4e, $43, $48, $3d, $52, $54, $43
    db $3d, $32, $30, $2d, $2d, $20, $3a, $3a
    db $4c, $41, $53, $54, $52, $4f, $4d, $3d
    db $55, $49, $3d, $52, $54, $43, $53, $44
    db $3d, $30, $41, $55, $54, $4f, $53, $41
    db $56, $45, $3d, $e8, $fb, $f8, $0a, $3a
    db $b6, $28, $5a, $f8, $04, $36, $00, $f8
    db $07, $2a, $4f, $46, $0a, $fe, $2f, $28
    db $09, $f8, $04, $36, $01, $21, $00, $da
    db $36, $2f, $f8, $04, $3a, $2b, $22, $af
    db $22, $77, $f8, $02, $3a, $2b, $22, $36
    db $da, $f8, $03, $5d, $54, $f8, $09, $1a
    db $13, $96, $23, $1a, $9e, $30, $1d, $f8
    db $02, $7e, $d6, $78, $30, $16, $34, $23
    db $79, $86, $23, $5f, $78, $8e, $57, $1a
    db $e1, $e5, $77, $f8, $03, $34, $20, $d2
    db $23, $34, $18, $ce, $e1, $36, $00, $e5
    db $21, $7f, $da, $36, $01, $e8, $05, $c9
    db $3b, $3b, $f8, $04, $2a, $4f, $46, $0a
    db $fe, $2f, $28, $04, $1e, $00, $18, $4b
    db $f8, $00, $af, $22, $16, $01, $72, $1e
    db $01, $7b, $3c, $20, $03, $5f, $18, $3b
    db $6b, $26, $00, $09, $7e, $b7, $28, $24
    db $fe, $20, $38, $04, $fe, $ff, $20, $04
    db $1e, $00, $18, $27, $fe, $2f, $20, $06
    db $53, $14, $f8, $00, $36, $00, $fe, $2e
    db $20, $04, $f8, $00, $36, $01, $1c, $f8
    db $01, $73, $18, $cd, $7a, $f8, $01, $96
    db $30, $07, $2b, $7e, $b7, $1e, $01, $20
    db $02, $1e, $00, $33, $33, $c9, $cd, $64
    db $53, $1e, $00, $3e, $78, $93, $3e, $00
    db $17, $47, $cb, $40, $20, $0d, $21, $a6
    db $c2, $16, $00, $19, $7e, $b7, $28, $03
    db $1c, $18, $e8, $7b, $4f, $b7, $28, $24
    db $cb, $40, $20, $20, $06, $00, $78, $91
    db $30, $11, $58, $16, $da, $78, $c6, $a6
    db $6f, $3e, $00, $ce, $c2, $67, $7e, $12
    db $04, $18, $eb, $06, $da, $af, $02, $21
    db $7f, $da, $36, $01, $fa, $3a, $db, $b7
    db $20, $08, $21, $4c, $00, $e5, $cd, $1f
    db $4c, $e1, $cd, $b2, $4d, $c3, $07, $5a
    db $11, $a4, $c4, $d5, $cd, $28, $5c, $e1
    db $7b, $b7, $28, $06, $21, $fb, $db, $36
    db $01, $c9, $cd, $64, $53, $fa, $7f, $da
    db $b7, $28, $2f, $11, $00, $da, $d5, $cd
    db $28, $5c, $e1, $7b, $b7, $28, $23, $0e
    db $00, $69, $26, $00, $11, $a4, $c4, $19
    db $59, $16, $da, $1a, $77, $1a, $b7, $28
    db $03, $0c, $18, $ed, $3e, $03, $f5, $33
    db $cd, $61, $4a, $33, $21, $fb, $db, $36
    db $01, $c9, $21, $01, $0f, $e5, $3e, $12
    db $f5, $33, $11, $54, $5d, $d5, $af, $0f
    db $f5, $af, $0f, $f5, $af, $0f, $f5, $cd
    db $60, $72, $e8, $0b, $cd, $88, $06, $cd
    db $91, $36, $cb, $6b, $28, $f6, $21, $fb
    db $db, $36, $00, $c9, $28, $6e, $6f, $6e
    db $65, $29, $00, $21, $fb, $db, $36, $00
    db $fa, $fd, $db, $b7, $c0, $01, $8b, $5d
    db $1e, $00, $21, $a5, $c3, $16, $00, $19
    db $56, $6b, $26, $00, $09, $7e, $92, $c0
    db $1c, $7b, $d6, $07, $38, $ec, $11, $a5
    db $c3, $d5, $cd, $28, $5c, $e1, $7b, $ea
    db $fb, $db, $c9, $2f, $53, $41, $56, $45
    db $52, $2f

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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

FillRect::
    db $fa, $fc, $d6, $b7, $28, $1f, $fa, $fe
    db $d6, $47, $fa, $ff, $d6, $57, $fa, $00
    db $d7, $4f, $5f, $cd, $e3, $1f, $fa, $01
    db $d7, $47, $fa, $00, $d7, $b8, $c8, $3c
    db $ea, $00, $d7, $18, $e1, $fa, $0d, $d7
    db $47, $af, $cb, $40, $28, $01, $2f, $ea
    db $f3, $db, $af, $cb, $48, $28, $01, $2f
    db $ea, $f4, $db, $fa, $fe, $d6, $e6, $07
    db $47, $3e, $ff, $04, $18, $02, $cb, $3f
    db $05, $20, $fb, $ea, $f0, $db, $fa, $ff
    db $d6, $e6, $07, $2f, $c6, $08, $47, $3e
    db $ff, $04, $18, $01, $87, $05, $20, $fc
    db $ea, $f1, $db, $fa, $fe, $d6, $cb, $3f
    db $cb, $3f, $cb, $3f, $47, $fa, $ff, $d6
    db $cb, $3f, $cb, $3f, $cb, $3f, $90, $20
    db $12, $fa, $f1, $db, $47, $fa, $f0, $db
    db $a0, $ea, $f0, $db, $3e, $ff, $ea, $f2
    db $db, $18, $04, $3d, $ea, $f2, $db, $fa
    db $00, $d7, $5f, $16, $00, $21, $02, $2c
    db $19, $19, $2a, $66, $6f, $fa, $fe, $d6
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
    db $fa, $f1, $db, $cd, $a6, $70, $fa, $01
    db $d7, $47, $fa, $00, $d7, $b8, $c8, $3c
    db $ea, $00, $d7, $c3, $cf, $6f, $47, $2f
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

LastRomName::
    db $f8, $09, $3a, $b6, $28, $57, $0e, $00
    db $79, $d6, $fe, $30, $10, $f8, $08, $2a
    db $81, $5f, $7e, $ce, $00, $57, $1a, $b7
    db $28, $03, $0c, $18, $eb, $41, $11, $3c
    db $db, $f8, $08, $2a, $12, $13, $7e, $12
    db $21, $38, $db, $36, $00, $2e, $39, $36
    db $00, $f0, $fa, $2e, $3b, $77, $f0, $fb
    db $b7, $28, $14, $c5, $f8, $0a, $2a, $5f
    db $56, $d5, $cd, $13, $73, $e1, $7b, $c1
    db $91, $38, $0b, $06, $00, $18, $07, $3e
    db $12, $91, $38, $02, $06, $00, $21, $3e
    db $db, $70, $c3, $49, $73, $21, $3e, $db
    db $4e, $79, $b7, $c8, $f0, $fa, $47, $21
    db $3b, $db, $96, $21, $3b, $db, $70, $fe
    db $65, $38, $02, $3e, $64, $21, $39, $db
    db $86, $21, $39, $db, $77, $fa, $39, $db
    db $2e, $38, $46, $04, $05, $20, $04, $06
    db $3c, $18, $02, $06, $14, $90, $d8, $21
    db $39, $db, $36, $00, $2e, $38, $46, $04
    db $21, $38, $db, $70, $26, $00, $69, $23
    db $23, $23, $0e, $00, $78, $95, $79, $9c
    db $da, $49, $73, $21, $38, $db, $36, $00
    db $c3, $49, $73, $e8, $d8, $21, $00, $00
    db $39, $e5, $af, $3c, $f5, $f8, $2e, $2a
    db $5f, $56, $d5, $af, $0f, $f5, $af, $0f
    db $f5, $cd, $00, $71, $e8, $0a, $3e, $01
    db $93, $30, $13, $4b, $0d, $79, $07, $9f
    db $47, $21, $00, $00, $39, $09, $7e, $fe
    db $95, $38, $03, $1d, $18, $e8, $e8, $28
    db $c9, $e8, $d1, $11, $3c, $db, $1a, $f8
    db $28, $22, $13, $1a, $77, $21, $3e, $db
    db $4e, $79, $b7, $20, $34, $f8, $2e, $36
    db $00, $f8, $2e, $5e, $16, $00, $21, $00
    db $00, $39, $19, $4d, $44, $f8, $2e, $7e
    db $d6, $27, $30, $19, $f8, $28, $7e, $f8
    db $2e, $86, $5f, $f5, $f8, $2b, $f1, $7e
    db $ce, $00, $57, $1a, $b7, $28, $06, $02
    db $f8, $2e, $34, $18, $d4, $af, $02, $18
    db $62, $21, $38, $db, $46, $f8, $2e, $36
    db $00, $f8, $2e, $5e, $16, $00, $21, $00
    db $00, $39, $19, $e5, $7d, $f8, $2e, $77
    db $e1, $7c, $f8, $2d, $77, $78, $91, $30
    db $0c, $f8, $28, $2a, $80, $5f, $7e, $ce
    db $00, $57, $1a, $18, $02, $3e, $20, $f8
    db $2c, $5e, $23, $66, $6b, $77, $04, $59
    db $16, $00, $13, $13, $13, $f8, $2a, $7b
    db $22, $7a, $22, $78, $22, $36, $00, $f8
    db $2c, $5d, $54, $f8, $2a, $1a, $13, $96
    db $23, $1a, $9e, $38, $02, $06, $00, $f8
    db $2e, $34, $7e, $d6, $27, $38, $aa, $f8
    db $27, $36, $00, $21, $03, $00, $e5, $af
    db $f5, $33, $cd, $d8, $23, $e8, $03, $f0
    db $fb, $b7, $20, $29, $fa, $3f, $db, $b7
    db $28, $04, $06, $07, $18, $02, $06, $0e
    db $f8, $00, $c5, $33, $11, $12, $01, $d5
    db $e5, $cd, $b7, $08, $e8, $05, $af, $0f
    db $f5, $af, $3e, $03, $f5, $33, $cd, $d8
    db $23, $e8, $03, $18, $44, $f8, $00, $4d
    db $44, $c5, $c5, $cd, $13, $73, $e1, $c1
    db $7b, $1c, $1d, $20, $02, $3e, $01, $21
    db $3f, $db, $6e, $2c, $2d, $28, $04, $16
    db $38, $18, $02, $16, $70, $d5, $33, $26
    db $01, $e5, $33, $f5, $33, $c5, $af, $0f
    db $f5, $af, $0f, $f5, $af, $0f, $f5, $cd
    db $00, $75, $e8, $0b, $af, $0f, $f5, $af
    db $3e, $03, $f5, $33, $cd, $d8, $23, $e8
    db $03, $e8, $2f, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
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
    db $77, $01, $02, $2c, $21, $37, $01, $39
    db $5e, $16, $00, $6b, $62, $29, $09, $2a
    db $4f, $46, $21, $24, $01, $39, $2a, $23
    db $23, $23, $5f, $16, $00, $7b, $87, $cb
    db $12, $87, $cb, $12, $87, $cb, $12, $87
    db $cb, $12, $81, $22, $7a, $88, $77, $fa
    db $0d, $d7, $21, $2a, $01, $39, $77, $fa
    db $0e, $d7, $21, $2b, $01, $39, $77, $7e
    db $b7, $3e, $ff, $20, $01, $af, $21, $2c
    db $01, $39, $77, $fa, $a9, $d6, $b7, $20
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
    db $f0, $fb, $b7, $20, $2a, $f8, $01, $4d
    db $44, $f8, $38, $7e, $f5, $33, $21, $01
    db $00, $e5, $c5, $cd, $b7, $08, $e8, $05
    db $f8, $38, $3a, $2b, $57, $1e, $01, $d5
    db $3a, $2b, $f5, $33, $2a, $5f, $56, $d5
    db $cd, $b7, $08, $e8, $05, $18, $51, $f8
    db $01, $2a, $77, $f8, $2b, $36, $00, $f8
    db $2b, $5e, $1c, $16, $00, $21, $02, $00
    db $39, $19, $4d, $44, $f8, $34, $7e, $f8
    db $2b, $86, $5f, $f5, $f8, $37, $f1, $7e
    db $ce, $00, $57, $1a, $02, $1a, $b7, $28
    db $08, $f8, $2b, $34, $7e, $d6, $27, $38
    db $d6, $f8, $2a, $36, $00, $f8, $38, $7e
    db $f5, $33, $af, $0f, $f5, $21, $05, $00
    db $39, $e5, $af, $0f, $f5, $af, $0f, $f5
    db $af, $0f, $f5, $cd, $00, $75, $e8, $0b
    db $e8, $2c, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
