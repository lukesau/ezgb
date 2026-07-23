; Disassembly of "kernel.gb"
; This file was created with:
; mgbdis v3.0 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $001", ROMX[$4000], BANK[$1]

    push af
    push af
    ld hl, sp+$0a
    ld c, [hl]
    inc hl
    ld b, [hl]

Jump_001_4007:
    ld a, [bc]
    or a
    jp z, Jump_001_4010

    inc bc
    jp Jump_001_4007


Jump_001_4010:
    ld hl, sp+$0c
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    inc hl
    ld [hl], c
    inc hl
    ld [hl], b

Jump_001_401c:
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    or a
    jp z, Jump_001_403d

    ld a, c
    dec hl
    inc [hl]
    jr nz, jr_001_402e

    inc hl
    inc [hl]

jr_001_402e:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, jr_001_403a

    inc hl
    inc [hl]

jr_001_403a:
    jp Jump_001_401c


Jump_001_403d:
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    add sp, $04
    ret


; [ezgb]
; CStrCmp(a@sp+$0a, b@sp+$0c): signed char strcmp → DE=*a-*b (sex). Frame -$04; BC=a, DE=b.
; Jump_001_4056: load *a/*b; mismatch → Jump_001_4069 → Jump_001_4084 sex-sub; else jr_001_406c.
; jr_001_406c: *a==0 → DE=0 Jump_001_40a0; else Jump_001_4079 ++BC / ++b-ptr (jr_001_4081 carry) → Jump_001_4056.
; Jump_001_4084: sex(*a)-sex(*b) into DE; Jump_001_40a0: add sp,$04 ret.

CStrCmp::
    push af
    push af
    ld hl, sp+$0a
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc hl
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], e

CStrCmp_loop::
    ld a, [bc]
    ld hl, sp+$01
    ld [hl+], a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$00
    ld [hl+], a
    ld a, [hl]
    dec hl
    sub [hl]
    jp nz, CStrCmp_mismatch

    jr CStrCmp_matchGate

CStrCmp_mismatch::
    jp CStrCmp_sexSub


CStrCmp_matchGate::
    xor a
    ld hl, sp+$01
    or [hl]
    jp nz, CStrCmp_advance

    ld de, $0000
    jp CStrCmp_epilogueRet


CStrCmp_advance::
    inc bc
    ld hl, sp+$02
    inc [hl]
    jr nz, CStrCmp_advanceCont

    inc hl
    inc [hl]

CStrCmp_advanceCont::
    jp CStrCmp_loop


CStrCmp_sexSub::
    ld hl, sp+$01
    ld a, [hl+]
    ld [hl-], a
    ld a, [hl]
    rla
    sbc a
    inc hl
    inc hl
    ld [hl], a
    ld hl, sp+$00
    ld c, [hl]
    ld a, [hl]
    rla
    sbc a
    ld b, a
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    sub c
    ld e, a
    ld a, d
    sbc b
    ld d, a

CStrCmp_epilogueRet::
    add sp, $04
    ret


; [ezgb]
; CStrChr(s@sp+$09, c@sp+$0b): walk NUL-term s; DE=last match ptr (0 if none). Frame -$03; last-wins not first.
; Null s → DE=0 Jump_001_40e0; else Jump_001_40b9 BC=s; Jump_001_40be: *BC==0 → Jump_001_40db load saved.
; *BC==c → jr_001_40d2 store BC@sp+$01; else Jump_001_40cf → Jump_001_40d7; Jump_001_40d7 ++BC → Jump_001_40be.
; Jump_001_40db: DE=saved; Jump_001_40e0: add sp,$03 ret.

CStrChr::
    push af
    dec sp
    ld hl, sp+$01
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$09
    ld a, [hl+]
    or [hl]
    jp nz, CStrChr_initBc

    ld de, $0000
    jp CStrChr_epilogueRet


CStrChr_initBc::
    ld hl, sp+$09
    ld c, [hl]
    inc hl
    ld b, [hl]

CStrChr_loop::
    ld a, [bc]
    ld hl, sp+$00
    ld [hl], a
    or a
    jp z, CStrChr_loadSaved

    ld a, [hl]
    ld hl, sp+$0b
    sub [hl]
    jp nz, CStrChr_skipStore

    jr CStrChr_storeMatch

CStrChr_skipStore::
    jp CStrChr_advance


CStrChr_storeMatch::
    ld hl, sp+$01
    ld [hl], c
    inc hl
    ld [hl], b

CStrChr_advance::
    inc bc
    jp CStrChr_loop


CStrChr_loadSaved::
    ld hl, sp+$01
    ld e, [hl]
    inc hl
    ld d, [hl]

CStrChr_epilogueRet::
    add sp, $03
    ret


; [ezgb]
; DrawBrowserEntries(start@sp+$26, sel@sp+$28): clamp visible rows vs $c2a2 (max $10) at Jump_001_40ff.
; Jump_001_412c: clear ink StoreDrawParams; Jump_001_413d row loop → done Jump_001_4266.
; jr_001_415d hilite $0002 else Jump_001_415a → Jump_001_416a; jr_001_4181 >>5 bank+$12@$4000.
; Jump_001_41da/jr_001_41dd: attr+$fe==$10 dir (+BrowserDirStr) else Jump_001_4229 file DrawString $14; Jump_001_4253 reset ink → Jump_001_413d.
; Jump_001_4266: U32ToAscii selected size + DrawString ret.

DrawBrowserEntries::
    add sp, -$20
    ld hl, sp+$26
    ld d, h
    ld e, l
    ld hl, $c2a2
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp c, DrawBrowserEntries_clampRows

    ld hl, sp+$1e
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp DrawBrowserEntries_clearInk


DrawBrowserEntries_clampRows::
    ld hl, $c2a2
    ld hl, $c2a2
    ld e, [hl]
    ld hl, $c2a3
    ld d, [hl]
    ld hl, sp+$26
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld c, e
    ld hl, sp+$1e
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, $10
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp nc, DrawBrowserEntries_clearInk

    dec hl
    ld [hl], $10
    inc hl
    ld [hl], $00

DrawBrowserEntries_clearInk::
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, sp+$1d
    ld [hl], $00

DrawBrowserEntries_rowLoop::
    ld hl, sp+$1d
    ld c, [hl]
    ld b, $00
    ld a, c
    inc hl
    sub [hl]
    ld a, b
    inc hl
    sbc [hl]
    jp nc, DrawBrowserEntries_drawSelSize

    ld a, c
    ld hl, sp+$28
    sub [hl]
    jp nz, DrawBrowserEntries_skipHilite

    ld a, b
    inc hl
    sub [hl]
    jp nz, DrawBrowserEntries_skipHilite

    jr DrawBrowserEntries_hilite

DrawBrowserEntries_skipHilite::
    jp DrawBrowserEntries_rowBank


DrawBrowserEntries_hilite::
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

DrawBrowserEntries_rowBank::
    ld hl, sp+$1d
    ld c, [hl]
    ld b, $00
    ld hl, sp+$26
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, $05

DrawBrowserEntries_bankShift::
    srl b
    rr c
    dec a
    jr nz, DrawBrowserEntries_bankShift

    ld hl, sp+$1b
    ld [hl], c
    ld hl, sp+$05
    ld a, [hl]
    and $1f
    ld c, a
    ld b, $00
    ld hl, sp+$1c
    ld [hl], c
    ld bc, $4000
    dec hl
    ld a, [hl]
    add $12
    ld [bc], a
    inc hl
    ld e, [hl]
    ld d, $00
    ld l, e
    ld h, d
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, $00fe
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    sub $10
    jp nz, DrawBrowserEntries_skipDir

    jr DrawBrowserEntries_dirEntry

DrawBrowserEntries_skipDir::
    jp DrawBrowserEntries_fileEntry


DrawBrowserEntries_dirEntry::
    ld hl, sp+$1d
    ld a, [hl]
    add $02
    ld hl, sp+$04
    ld [hl], a
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, $0000
    push hl
    push bc
    call DrawString
    add sp, $05
    ld hl, $0003
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, $1103
    push hl
    ld hl, BrowserDirStr
    push hl
    call DrawString
    add sp, $05
    jp DrawBrowserEntries_resetInk


DrawBrowserEntries_fileEntry::
    ld hl, sp+$1d
    ld a, [hl]
    add $02
    ld hl, sp+$04
    ld [hl], a
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, $0014
    push hl
    push bc
    call DrawString
    add sp, $05

DrawBrowserEntries_resetInk::
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, sp+$1d
    inc [hl]
    jp DrawBrowserEntries_rowLoop


DrawBrowserEntries_drawSelSize::
    ld hl, sp+$07
    ld a, l
    ld d, h
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$26
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    inc bc
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld a, $0a
    push af
    inc sp
    inc hl
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32ToAscii_B0
    add sp, $07
    ld hl, sp+$07
    ld c, l
    ld b, h
    ld hl, $0010
    push hl
    ld a, $04
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05
    add sp, $20
    ret


BrowserDirStr::
    db "DIR", $00

; [ezgb]
; DrawBrowserDetail(base@sp+$2a, row@sp+$2c, mode@sp+$2e): draw two adjacent browser rows.
; Jump_001_42c8/jr_001_42c9: mode==2 → rows (n-1,n); else Jump_001_42fb (n,n+1). Jump_001_4324: jr_001_433b >>5 bank+$12@$4000.
; Jump_001_4364/jr_001_4365 vs Jump_001_437c: mode3 hilite StoreDrawParams; Jump_001_4390 entry0; Jump_001_43cd/jr_001_43d0 dir else Jump_001_441a file.
; Jump_001_4442 vs Jump_001_4459: focus ink; Jump_001_446d/jr_001_4484 row1 bank; Jump_001_44dd/jr_001_44e0 dir else Jump_001_452a file; Jump_001_4552 size U32ToAscii+DrawString.

DrawBrowserDetail::
    add sp, -$24
    ld hl, sp+$2e
    ld a, [hl]
    sub $02
    jp nz, DrawBrowserDetail_mode2Prep

    ld a, $01
    jr DrawBrowserDetail_mode2Rows

DrawBrowserDetail_mode2Prep::
    xor a

DrawBrowserDetail_mode2Rows::
    ld hl, sp+$07
    ld [hl], a
    or a
    jp z, DrawBrowserDetail_modeNormalRows

    ld hl, sp+$2c
    ld b, [hl]
    ld a, b
    dec a
    ld hl, sp+$09
    ld [hl-], a
    ld [hl], b
    ld hl, sp+$2c
    ld c, [hl]
    inc hl
    ld b, [hl]
    dec bc
    ld hl, $0002
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$22
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$2c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$20
    ld [hl+], a
    ld [hl], d
    jp DrawBrowserDetail_row0Bank


DrawBrowserDetail_modeNormalRows::
    ld hl, sp+$2c
    ld c, [hl]
    ld hl, sp+$09
    ld [hl], c
    ld a, c
    inc a
    dec hl
    ld [hl], a
    ld hl, sp+$2c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$22
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$2c
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld hl, $0002
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$20
    ld [hl+], a
    ld [hl], d

DrawBrowserDetail_row0Bank::
    ld hl, sp+$09
    ld c, [hl]
    ld b, $00
    ld hl, sp+$2a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, $05

DrawBrowserDetail_row0BankShift::
    srl b
    rr c
    dec a
    jr nz, DrawBrowserDetail_row0BankShift

    ld hl, sp+$1e
    ld [hl], c
    ld hl, sp+$05
    ld a, [hl]
    and $1f
    ld c, a
    ld b, $00
    ld hl, sp+$1f
    ld [hl], c
    ld bc, $4000
    dec hl
    ld a, [hl]
    add $12
    ld [bc], a
    ld hl, sp+$2e
    ld a, [hl]
    sub $03
    jp nz, DrawBrowserDetail_mode3Prep

    ld a, $01
    jr DrawBrowserDetail_mode3Hilite

DrawBrowserDetail_mode3Prep::
    xor a

DrawBrowserDetail_mode3Hilite::
    ld hl, sp+$09
    ld [hl], a
    or a
    jp z, DrawBrowserDetail_afterHilite

    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    jp DrawBrowserDetail_entry0


DrawBrowserDetail_afterHilite::
    xor a
    ld hl, sp+$07
    or [hl]
    jp z, DrawBrowserDetail_entry0

    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

DrawBrowserDetail_entry0::
    ld hl, sp+$1f
    ld e, [hl]
    ld d, $00
    ld l, e
    ld h, d
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, $00fe
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    sub $10
    jp nz, DrawBrowserDetail_entry0SkipDir

    jr DrawBrowserDetail_entry0Dir

DrawBrowserDetail_entry0SkipDir::
    jp DrawBrowserDetail_entry0File


DrawBrowserDetail_entry0Dir::
    ld hl, sp+$22
    ld a, [hl]
    ld hl, sp+$04
    ld [hl], a
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, $0000
    push hl
    push bc
    call DrawString
    add sp, $05
    ld hl, $0003
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, $1103
    push hl
    ld hl, BrowserDirStr2
    push hl
    call DrawString
    add sp, $05
    jp DrawBrowserDetail_focusInk


DrawBrowserDetail_entry0File::
    ld hl, sp+$22
    ld a, [hl]
    ld hl, sp+$04
    ld [hl], a
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, $0014
    push hl
    push bc
    call DrawString
    add sp, $05

DrawBrowserDetail_focusInk::
    xor a
    ld hl, sp+$09
    or [hl]
    jp z, DrawBrowserDetail_afterFocusInk

    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    jp DrawBrowserDetail_row1Bank


DrawBrowserDetail_afterFocusInk::
    xor a
    ld hl, sp+$07
    or [hl]
    jp z, DrawBrowserDetail_row1Bank

    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

DrawBrowserDetail_row1Bank::
    ld hl, sp+$08
    ld c, [hl]
    ld b, $00
    ld hl, sp+$2a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld a, $05

DrawBrowserDetail_row1BankShift::
    srl b
    rr c
    dec a
    jr nz, DrawBrowserDetail_row1BankShift

    ld hl, sp+$1e
    ld [hl], c
    ld hl, sp+$05
    ld a, [hl]
    and $1f
    ld c, a
    ld b, $00
    ld hl, sp+$1f
    ld [hl], c
    ld bc, $4000
    dec hl
    ld a, [hl]
    add $12
    ld [bc], a
    inc hl
    ld e, [hl]
    ld d, $00
    ld l, e
    ld h, d
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, $00fe
    add hl, bc
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    sub $10
    jp nz, DrawBrowserDetail_entry1SkipDir

    jr DrawBrowserDetail_entry1Dir

DrawBrowserDetail_entry1SkipDir::
    jp DrawBrowserDetail_entry1File


DrawBrowserDetail_entry1Dir::
    ld hl, sp+$20
    ld a, [hl]
    ld hl, sp+$04
    ld [hl], a
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, $0000
    push hl
    push bc
    call DrawString
    add sp, $05
    ld hl, $0003
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, $1103
    push hl
    ld hl, BrowserDirStr2
    push hl
    call DrawString
    add sp, $05
    jp DrawBrowserDetail_drawSize


DrawBrowserDetail_entry1File::
    ld hl, sp+$20
    ld a, [hl]
    ld hl, sp+$04
    ld [hl], a
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$04
    ld a, [hl]
    push af
    inc sp
    ld hl, $0014
    push hl
    push bc
    call DrawString
    add sp, $05

DrawBrowserDetail_drawSize::
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, sp+$0a
    ld a, l
    ld d, h
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    inc bc
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld a, $0a
    push af
    inc sp
    inc hl
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32ToAscii_B0
    add sp, $07
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, $0010
    push hl
    ld a, $04
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05
    add sp, $24
    ret


BrowserDirStr2::
    db "DIR", $00

; [ezgb]
; FormatFileSize(u32@sp+$10): if size≥$10000 Jump_001_479b passthrough; else Jump_001_45e7 pick fmt table.
; Jump_001_45e7: size≥$1000 → wFileSizeFmtHi else Jump_001_45ec wFileSizeFmtLo; Jump_001_45f1 walks {thr,op} pairs via $4676 jp-table.
; Ops: Jump_001_4691/Jump_001_46bd scale-sub thr; Jump_001_46e2 -$10; Jump_001_46f6 -$20; Jump_001_470a -$30; Jump_001_471e -$1a; Jump_001_4732 +8; Jump_001_4744 -$50; Jump_001_4758 -$1c60 → Jump_001_476c.
; Jump_001_476c: more entries → Jump_001_45f1 else advance; Jump_001_478a rewrite lo16@sp+$10; Jump_001_479b ret DE:HL.

FormatFileSize::
    add sp, -$0a
    ld hl, sp+$10
    ld a, [hl]
    sub $00
    inc hl
    ld a, [hl]
    sbc $00
    inc hl
    ld a, [hl]
    sbc $01
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, FormatFileSize_retDeHl

    ld hl, sp+$10
    ld a, [hl]
    ld hl, sp+$06
    ld [hl], a
    ld hl, sp+$11
    ld a, [hl]
    ld hl, sp+$07
    ld [hl-], a
    ld a, [hl]
    sub $00
    inc hl
    ld a, [hl]
    sbc $10
    jp nc, FormatFileSize_pickFmtHi

    ld de, wFileSizeFmtLo
    ld c, e
    ld b, d
    jp FormatFileSize_pickFmtLo


FormatFileSize_pickFmtHi::
    ld de, wFileSizeFmtHi
    ld c, e
    ld b, d

FormatFileSize_pickFmtLo::
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], b

FormatFileSize_walkTable::
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], b
    dec hl
    ld a, [hl+]
    or [hl]
    jp z, FormatFileSize_rewriteLo16

    inc hl
    ld d, h
    ld e, l
    dec hl
    dec hl
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp c, FormatFileSize_rewriteLo16

    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$02
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], $00
    inc hl
    inc hl
    ld [hl], $00
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$06
    ld a, [hl]
    sub c
    inc hl
    ld a, [hl]
    sbc b
    jp nc, FormatFileSize_afterOp

    ld a, $08
    ld hl, sp+$00
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp c, FormatFileSize_rewriteLo16

    dec hl
    ld e, [hl]
    ld d, $00
    ld hl, $4676
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp FormatFileSize_opScaleSubA


    jp FormatFileSize_opScaleSubB


    jp FormatFileSize_opSub10


    jp FormatFileSize_opSub20


    jp FormatFileSize_opSub30


    jp FormatFileSize_opSub1a


    jp FormatFileSize_opAdd8


    jp FormatFileSize_opSub50


    jp FormatFileSize_opSub1c60


FormatFileSize_opScaleSubA::
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld c, e
    sla c
    rl b
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$06
    ld [hl], c
    inc hl
    ld [hl], b
    jp FormatFileSize_rewriteLo16


FormatFileSize_opScaleSubB::
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld a, e
    and $01
    ld c, a
    ld b, $00
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    sub c
    ld e, a
    ld a, d
    sbc b
    ld [hl-], a
    ld [hl], e
    jp FormatFileSize_rewriteLo16


FormatFileSize_opSub10::
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0010
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    jp FormatFileSize_rewriteLo16


FormatFileSize_opSub20::
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0020
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    jp FormatFileSize_rewriteLo16


FormatFileSize_opSub30::
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0030
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    jp FormatFileSize_rewriteLo16


FormatFileSize_opSub1a::
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $001a
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    jp FormatFileSize_rewriteLo16


FormatFileSize_opAdd8::
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0008
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], d
    jp FormatFileSize_rewriteLo16


FormatFileSize_opSub50::
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0050
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    jp FormatFileSize_rewriteLo16


FormatFileSize_opSub1c60::
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $1c60
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    jp FormatFileSize_rewriteLo16


FormatFileSize_afterOp::
    ld hl, sp+$00
    ld a, [hl+]
    or [hl]
    jp nz, FormatFileSize_walkTable

    inc hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    sla c
    rl b
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    jp FormatFileSize_walkTable


FormatFileSize_rewriteLo16::
    ld hl, sp+$06
    ld a, [hl]
    ld hl, sp+$10
    ld [hl], a
    ld hl, sp+$07
    ld a, [hl]
    ld hl, sp+$11
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00

FormatFileSize_retDeHl::
    ld hl, sp+$10
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add sp, $0a
    ret


; [ezgb]
; SetFpgaPage: unlock → $7FC0=page (arg on stack; $03=cart FRAM window) → commit.
; With $7FC0=$03, $4000 latches FRAM bank; $A000-$BFFF is non-volatile FRAM
; (no battery; cart battery is RTC-only). See docs/fram-save-map.md.

SetFpgaPage_B1::
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7fc0
    ld hl, sp+$02
    ld a, [hl]
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ret


; [ezgb]
; SetFpga7F34_35_B1: same as SetFpga7F34_35_B4 (04:40fc). Unlock; write stack u8s
; to $7F34 then $7F35; commit $7FF0. Orphan after SetFpgaPage_B1.

SetFpga7F34_35_B1::
    push af
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld hl, sp+$00
    ld [hl], $34
    inc hl
    ld [hl], $7f
    ld hl, sp+$04
    ld c, [hl]
    ld b, $00
    ld a, c
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    ld [hl], $35
    inc hl
    ld [hl], $7f
    ld c, $00
    ld hl, sp+$05
    ld b, [hl]
    ld c, b
    ld b, $00
    ld a, c
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    add sp, $02
    ret


; [ezgb]
; SetFpga7FD4_B1: unlock $7F00/10/20; write stack u8 to $7FD4; commit $7FF0.
; Same shape as SetFpga7FD0_B4. Orphan before LoaderPrepPath.

SetFpga7FD4_B1::
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7fd4
    ld hl, sp+$06
    ld a, [hl]
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ret


; [ezgb]
; LoaderPrepPath: assemble /dir/NAME path into $c2a6. First hop of the $1569
; launch chain ($482b → $4048 → $4000 → $5e14). See docs/launch-trace.md.

LoaderPrepPath::
    push af
    push af
    ld hl, $48c4
    push hl
    ld hl, $c2a6
    push hl
    call FarCallTrampoline
    ld c, b
    ld b, b
    ld bc, $e800
    inc b
    ld b, d
    ld c, e
    ld a, c
    or a
    jp z, LastRomPersist

    ld hl, $48c4
    push hl
    ld hl, $c2a6
    push hl
    call FarCallTrampoline
    nop
    ld b, b
    ld bc, $e800
    inc b

; [ezgb]
; LastRomPersist: copy the assembled launch path ($c2a6, 255 bytes) into cart
; NVRAM $A300 (select bank 17, FPGA rompage $03). Read back by LastRomOverlay
; on START. See docs/last-rom.md.

LastRomPersist::
    ld hl, $c4a4
    push hl
    ld hl, $c2a6
    push hl
    call FarCallTrampoline
    nop
    ld b, b
    ld bc, $e800
    inc b
    ld bc, $4000
    ld a, $11
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld hl, sp+$02
    ld [hl], $00
    inc hl
    ld [hl], $00

; [ezgb]
; LastRomPersistLoop: copy $c2a6..+$00ff → $A300 (idx@sp+$02); then LastRomPersistDone.
; jr_001_48af → self until idx≥$00ff. Twin of LastRomLoadRecord (00:12bf) write path.

LastRomPersistLoop::
    ld hl, sp+$02
    ld a, [hl]
    sub $ff
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, LastRomPersistDone

    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $a300
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    ld de, $c2a6
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    inc hl
    inc [hl]
    jr nz, LastRomPersistLoop_copyCont

    inc hl
    inc [hl]

LastRomPersistLoop_copyCont::
    jp LastRomPersistLoop


LastRomPersistDone::
    ld bc, $4000
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    add sp, $04
    ret


    cpl
    nop

; [ezgb]
; IsLeapYear(year@sp+$04) → E=1 if leap else 0. Gregorian: %4, then %100/%400.
; year&3≠0 → jr_001_48d3 → Jump_001_4913 E=0; else Jump_001_48d6 U16Mod 100.
; rem≠0 → Jump_001_4911 leap; else U16Mod 400: rem==0 → Jump_001_4911 else C=0 Jump_001_4913.
; Jump_001_4911: C=1; Jump_001_4913: E=C; add sp,$02 ret.

IsLeapYear::
    push af
    ld c, $00
    ld hl, sp+$04
    ld a, [hl]
    and $03
    jr nz, IsLeapYear_notDiv4

    jp IsLeapYear_mod100


IsLeapYear_notDiv4::
    jp IsLeapYear_retFlag


IsLeapYear_mod100::
    ld hl, $0064
    push hl
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U16Mod
    add sp, $04
    ld hl, sp+$01
    ld [hl], d
    dec hl
    ld [hl], e
    ld hl, sp+$00
    ld a, [hl+]
    or [hl]
    jp nz, IsLeapYear_setLeap

    ld hl, $0190
    push hl
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U16Mod
    add sp, $04
    ld hl, sp+$01
    ld [hl], d
    dec hl
    ld [hl], e
    ld hl, sp+$00
    ld a, [hl+]
    or [hl]
    jp z, IsLeapYear_setLeap

    ld c, $00
    jp IsLeapYear_retFlag


IsLeapYear_setLeap::
    ld c, $01

IsLeapYear_retFlag::
    ld e, c
    add sp, $02
    ret


; [ezgb]
; DateToDaysSince1970(date*): returns seconds since 1970-01-01 (HL:DE), despite name. Feeds RtcToDayCount.
; Jump_001_492f: years from $07b2/1970; IsLeapYear → +$016e else Jump_001_4974 +$016d; Jump_001_4992 ++y (jr_001_4999) → Jump_001_492f; done Jump_001_499c.
; Jump_001_49b2: months via IsLeapYear → wDaysInMonthLeap else Jump_001_4a1c wDaysInMonth; Jump_001_4a59 ++m (jr_001_4a60) → Jump_001_49b2.
; Jump_001_4a63: +day-1; *24*60*60; add h/m/s from struct +5/+6/+7; subtract $7080 → HL:DE.

DateToDaysSince1970::
    add sp, -$18
    xor a
    ld hl, sp+$14
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld hl, sp+$1a
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$06
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$0e
    ld [hl], $b2
    inc hl
    ld [hl], $07

DateToDaysSince1970_yearLoop::
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$0e
    ld a, [hl]
    sub c
    inc hl
    ld a, [hl]
    sbc b
    jp nc, DateToDaysSince1970_afterYears

    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call IsLeapYear
    add sp, $02
    ld c, e
    xor a
    or c
    jp z, DateToDaysSince1970_nonLeapYear

    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    add $6e
    ld e, a
    ld a, d
    adc $01
    push af
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    adc $00
    ld e, a
    ld a, d
    adc $00
    ld [hl-], a
    ld [hl], e
    jp DateToDaysSince1970_incYear


DateToDaysSince1970_nonLeapYear::
    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    add $6d
    ld e, a
    ld a, d
    adc $01
    push af
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    adc $00
    ld e, a
    ld a, d
    adc $00
    ld [hl-], a
    ld [hl], e

DateToDaysSince1970_incYear::
    ld hl, sp+$0e
    inc [hl]
    jr nz, DateToDaysSince1970_yearCont

    inc hl
    inc [hl]

DateToDaysSince1970_yearCont::
    jp DateToDaysSince1970_yearLoop


DateToDaysSince1970_afterYears::
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$0c
    ld [hl], $00
    inc hl
    ld [hl], $00

DateToDaysSince1970_monthLoop::
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld b, $00
    dec bc
    ld hl, sp+$0c
    ld a, [hl]
    sub c
    inc hl
    ld a, [hl]
    sbc b
    jp nc, DateToDaysSince1970_addHms

    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    push bc
    call IsLeapYear
    add sp, $02
    ld c, e
    xor a
    or c
    jp z, DateToDaysSince1970_nonLeapMonths

    ld de, wDaysInMonthLeap
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$00
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld hl, sp+$17
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld hl, sp+$17
    ld [hl-], a
    ld [hl], e
    jp DateToDaysSince1970_incMonth


DateToDaysSince1970_nonLeapMonths::
    ld de, wDaysInMonth
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$00
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld hl, sp+$17
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld hl, sp+$17
    ld [hl-], a
    ld [hl], e

DateToDaysSince1970_incMonth::
    ld hl, sp+$0c
    inc [hl]
    jr nz, DateToDaysSince1970_monthCont

    inc hl
    inc [hl]

DateToDaysSince1970_monthCont::
    jp DateToDaysSince1970_monthLoop


DateToDaysSince1970_addHms::
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0003
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld b, $00
    dec bc
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, b
    rla
    sbc a
    inc hl
    ld [hl+], a
    ld [hl], a
    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$00
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld hl, sp+$17
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld hl, sp+$17
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$16
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $0000
    push hl
    ld hl, $0018
    push hl
    call U32Mul
    add sp, $08
    push hl
    ld hl, sp+$12
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$12
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$12
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $0000
    push hl
    ld hl, $003c
    push hl
    call U32Mul
    add sp, $08
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld d, h
    ld e, l
    ld hl, sp+$10
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld hl, sp+$12
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$12
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $0000
    push hl
    ld hl, $003c
    push hl
    call U32Mul
    add sp, $08
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld d, h
    ld e, l
    ld hl, sp+$10
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0005
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld e, c
    ld d, $00
    ld l, e
    ld h, d
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$08
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, b
    rla
    sbc a
    inc hl
    ld [hl+], a
    ld [hl-], a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $0000
    push hl
    ld hl, $003c
    push hl
    call U32Mul
    add sp, $08
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld d, h
    ld e, l
    ld hl, sp+$08
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld hl, sp+$10
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
    ld hl, sp+$13
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
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
    ld hl, sp+$13
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld e, c
    ld d, $00
    ld l, e
    ld h, d
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, b
    rla
    sbc a
    inc hl
    ld [hl+], a
    ld [hl], a
    ld hl, sp+$10
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$00
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld hl, sp+$13
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld hl, sp+$13
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$06
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0007
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$10
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$00
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld hl, sp+$13
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld hl, sp+$13
    ld [hl-], a
    ld [hl], e
    dec hl
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    sub $80
    ld e, a
    ld a, d
    sbc $70
    push af
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    sbc $00
    ld e, a
    ld a, d
    sbc $00
    ld [hl-], a
    ld [hl], e
    dec hl
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add sp, $18
    ret


; [ezgb]
; RtcToDayCount: SetFpgaPage_B1 $06, BCD-decode RTC bytes at $A00E/$A00D/$A00B…
; (year+=$07d0/2000), then DateToDaysSince1970. Returns HL:DE day count.

RtcToDayCount::
    add sp, -$11
    ld a, $06
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld hl, sp+$09
    ld a, l
    ld d, h
    ld hl, sp+$07
    ld [hl+], a
    ld [hl], d
    ld bc, $a00e
    ld a, [bc]
    and $0f
    ld c, a
    ld hl, sp+$05
    ld [hl], c
    inc hl
    ld [hl], $00
    ld bc, $a00e
    ld a, [bc]
    ld c, a
    srl c
    srl c
    srl c
    srl c
    ld e, c
    ld d, $00
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    ld hl, $07d0
    add hl, bc
    ld c, l
    ld b, h
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, c
    ld [de], a
    inc de
    ld a, b
    ld [de], a
    ld hl, sp+$09
    ld a, l
    ld d, h
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$07
    ld [hl+], a
    ld [hl], d
    ld bc, $a00d
    ld a, [bc]
    ld c, a
    and $0f
    ld hl, sp+$04
    ld [hl], a
    ld bc, $a00d
    ld a, [bc]
    ld c, a
    srl c
    srl c
    srl c
    srl c
    ld a, c
    ld e, a
    add a
    add a
    add e
    add a
    ld c, a
    ld hl, sp+$04
    ld a, [hl]
    add c
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$05
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0003
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$07
    ld [hl+], a
    ld [hl], d
    ld bc, $a00b
    ld a, [bc]
    ld c, a
    and $0f
    ld hl, sp+$04
    ld [hl], a
    ld bc, $a00b
    ld a, [bc]
    ld c, a
    srl c
    srl c
    srl c
    srl c
    ld a, c
    ld e, a
    add a
    add a
    add e
    add a
    ld c, a
    ld hl, sp+$04
    ld a, [hl]
    add c
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$05
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0005
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$07
    ld [hl+], a
    ld [hl], d
    ld bc, $a00a
    ld a, [bc]
    ld c, a
    and $0f
    ld hl, sp+$04
    ld [hl], a
    ld bc, $a00a
    ld a, [bc]
    ld c, a
    srl c
    srl c
    srl c
    srl c
    ld a, c
    ld e, a
    add a
    add a
    add e
    add a
    ld c, a
    ld hl, sp+$04
    ld a, [hl]
    add c
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$05
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$07
    ld [hl+], a
    ld [hl], d
    ld bc, $a009
    ld a, [bc]
    ld c, a
    and $0f
    ld hl, sp+$04
    ld [hl], a
    ld bc, $a009
    ld a, [bc]
    ld c, a
    srl c
    srl c
    srl c
    srl c
    ld a, c
    ld e, a
    add a
    add a
    add e
    add a
    ld c, a
    ld hl, sp+$04
    ld a, [hl]
    add c
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$05
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0007
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$05
    ld [hl+], a
    ld [hl], d
    ld bc, $a008
    ld a, [bc]
    ld c, a
    and $0f
    dec hl
    dec hl
    ld [hl], a
    ld bc, $a008
    ld a, [bc]
    ld c, a
    srl c
    srl c
    srl c
    srl c
    ld a, c
    ld e, a
    add a
    add a
    add e
    add a
    ld c, a
    ld hl, sp+$04
    ld a, [hl]
    add c
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld a, $03
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld hl, sp+$09
    ld c, l
    ld b, h
    push bc
    call DateToDaysSince1970
    add sp, $02
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add sp, $11
    ret


; [ezgb]
; RtcWriteTimeFromDayDelta(delta@sp+$18): RtcToDayCount − delta; if delta==0 or result<0 → Jump_001_4e38 zero HMS.
; Jump_001_4e50: seed from $c0a0..$c0b0; overflow → Jump_001_4e94 zero then Jump_001_4ea9 else fall Jump_001_4ea9.
; Cascade: Jump_001_4ea9 S32Div/60; Jump_001_4ee0 S32Mod/60 (sec) + Div/60; Jump_001_4f4c S32Mod/60 (min) + Div/24;
; Jump_001_4fc6/jr_001_4fc6: S32Mod/24 (hr); Jump_001_5063: write HMS/day $A018..$A01C (page $06) + mirror $A220..$A224 (page $03/$11).

RtcWriteTimeFromDayDelta::
    add sp, -$16
    call RtcToDayCount
    push hl
    ld hl, sp+$14
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$18
    sub [hl]
    ld e, a
    ld a, d
    inc hl
    sbc [hl]
    push af
    ld hl, sp+$11
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$1c
    pop af
    ld a, e
    sbc [hl]
    ld e, a
    ld a, d
    inc hl
    sbc [hl]
    ld hl, sp+$11
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$18
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, RtcWriteTimeFromDayDelta_zeroHms

    ld hl, sp+$11
    ld a, [hl]
    bit 7, a
    jp z, RtcWriteTimeFromDayDelta_seedC0a0

RtcWriteTimeFromDayDelta_zeroHms::
    ld hl, sp+$08
    ld [hl], $00
    dec hl
    ld [hl], $00
    dec hl
    ld [hl], $00
    xor a
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld hl, sp+$09
    ld [hl], $00
    jp RtcWriteTimeFromDayDelta_writeFpga


RtcWriteTimeFromDayDelta_seedC0a0::
    ld de, $c0a0
    ld a, [de]
    ld c, a
    ld hl, sp+$08
    ld [hl], c
    ld bc, $c0a4
    ld a, [bc]
    ld c, a
    dec hl
    ld [hl], c
    ld bc, $c0a8
    ld a, [bc]
    ld b, a
    dec hl
    ld [hl], b
    ld bc, $c0ac
    ld a, [bc]
    ld c, a
    ld hl, sp+$0a
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld bc, $c0b0
    ld a, [bc]
    ld c, a
    ld hl, sp+$09
    ld [hl], c
    ld a, $3b
    dec hl
    sub [hl]
    jp c, RtcWriteTimeFromDayDelta_overflowZero

    ld a, $3b
    dec hl
    sub [hl]
    jp c, RtcWriteTimeFromDayDelta_overflowZero

    ld a, $17
    dec hl
    sub [hl]
    jp nc, RtcWriteTimeFromDayDelta_div60a

RtcWriteTimeFromDayDelta_overflowZero::
    ld hl, sp+$08
    ld [hl], $00
    dec hl
    ld [hl], $00
    dec hl
    ld [hl], $00
    xor a
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld hl, sp+$09
    ld [hl], $00

RtcWriteTimeFromDayDelta_div60a::
    ld hl, $0000
    push hl
    ld hl, $003c
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call S32Div
    add sp, $08
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld c, [hl]
    ld hl, sp+$08
    ld a, [hl]
    add c
    ld [hl], a
    ld a, $3b
    sub [hl]
    jp nc, RtcWriteTimeFromDayDelta_modSec

    ld a, [hl]
    add $c4
    ld [hl-], a
    inc [hl]

RtcWriteTimeFromDayDelta_modSec::
    ld hl, $0000
    push hl
    ld hl, $003c
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call S32Mod
    add sp, $08
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld d, h
    ld e, l
    ld hl, sp+$0e
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld hl, $0000
    push hl
    ld hl, $003c
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call S32Div
    add sp, $08
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld c, [hl]
    ld hl, sp+$07
    ld a, [hl]
    add c
    ld [hl], a
    ld a, $3b
    sub [hl]
    jp nc, RtcWriteTimeFromDayDelta_modMin

    ld a, [hl]
    add $c4
    ld [hl-], a
    inc [hl]

RtcWriteTimeFromDayDelta_modMin::
    ld hl, $0000
    push hl
    ld hl, $003c
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call S32Mod
    add sp, $08
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld d, h
    ld e, l
    ld hl, sp+$0e
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld hl, $0000
    push hl
    ld hl, $0018
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call S32Div
    add sp, $08
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld c, [hl]
    ld hl, sp+$06
    ld a, [hl]
    add c
    ld [hl], a
    ld a, $17
    sub [hl]
    jp nc, RtcWriteTimeFromDayDelta_modHr

    ld a, [hl]
    add $e8
    ld [hl], a
    ld hl, sp+$0a
    inc [hl]
    jr nz, RtcWriteTimeFromDayDelta_modHr

    inc hl
    inc [hl]
    jr nz, RtcWriteTimeFromDayDelta_modHr

    inc hl
    inc [hl]
    jr nz, RtcWriteTimeFromDayDelta_modHr

    inc hl
    inc [hl]

RtcWriteTimeFromDayDelta_modHr::
    ld hl, $0000
    push hl
    ld hl, $0018
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$14
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call S32Mod
    add sp, $08
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld d, h
    ld e, l
    ld hl, sp+$0e
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld hl, sp+$0a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld hl, sp+$0e
    add [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    push af
    ld hl, sp+$0d
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$12
    pop af
    ld a, e
    adc [hl]
    ld e, a
    ld a, d
    inc hl
    adc [hl]
    ld hl, sp+$0d
    ld [hl-], a
    ld [hl], e
    ld a, $ff
    dec hl
    dec hl
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    ld a, $00
    inc hl
    sbc [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp nc, RtcWriteTimeFromDayDelta_writeFpga

    ld hl, sp+$09
    ld a, [hl]
    and $c1
    ld c, a
    or $01
    ld [hl], a
    ld a, $ff
    inc hl
    sub [hl]
    ld a, $01
    inc hl
    sbc [hl]
    ld a, $00
    inc hl
    sbc [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp nc, RtcWriteTimeFromDayDelta_writeFpga

    dec hl
    dec hl
    ld a, [hl]
    and $01
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$09
    ld a, [hl]
    or $80
    ld [hl], a
    and $c0
    ld [hl], a

RtcWriteTimeFromDayDelta_writeFpga::
    ld a, $06
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld bc, $a018
    ld hl, sp+$08
    ld a, [hl]
    ld [bc], a
    ld bc, $a019
    dec hl
    ld a, [hl]
    ld [bc], a
    ld bc, $a01a
    dec hl
    ld a, [hl]
    ld [bc], a
    ld bc, $a01b
    ld hl, sp+$0a
    ld a, [hl]
    ld hl, sp+$04
    ld [hl], a
    ld [bc], a
    ld bc, $a01c
    ld hl, sp+$09
    ld a, [hl]
    ld [bc], a
    ld bc, $4000
    ld a, $11
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld bc, $a220
    ld hl, sp+$08
    ld a, [hl]
    ld [bc], a
    ld bc, $a221
    dec hl
    ld a, [hl]
    ld [bc], a
    ld bc, $a222
    dec hl
    ld a, [hl]
    ld [bc], a
    ld bc, $a223
    dec hl
    dec hl
    ld a, [hl]
    ld [bc], a
    ld bc, $a224
    ld hl, sp+$09
    ld a, [hl]
    ld [bc], a
    ld bc, $4000
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add sp, $16
    ret


; [ezgb]
; RtcReadDaysClearRegs: RtcToDayCount → HL:DE; then zero $A018–$A01C (FPGA page $06)
; and $A220–$A224 (page $03, $4000=$11 window). Callers stash days before launch/FRAM.

RtcReadDaysClearRegs::
    push af
    push af
    call RtcToDayCount
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld a, $06
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld bc, $a018
    ld a, $00
    ld [bc], a
    ld bc, $a019
    ld a, $00
    ld [bc], a
    ld bc, $a01a
    ld a, $00
    ld [bc], a
    ld bc, $a01b
    ld a, $00
    ld [bc], a
    ld bc, $a01c
    ld a, $00
    ld [bc], a
    ld bc, $4000
    ld a, $11
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld bc, $a220
    ld a, $00
    ld [bc], a
    ld bc, $a221
    ld a, $00
    ld [bc], a
    ld bc, $a222
    ld a, $00
    ld [bc], a
    ld bc, $a223
    ld a, $00
    ld [bc], a
    ld bc, $a224
    ld a, $00
    ld [bc], a
    ld bc, $4000
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add sp, $04
    ret


; [ezgb]
; BackupOpenSaverPath: build $c3a5="/SAVER/"+name; Jump_001_51b2 force ".sav"; Open_B6 FarCall_06_7309 → $ca0f.
; Size from $d3ed: Jump_001_5233 ($d3eb==2 → Jump_001_523e/jr_001_5241 $2000 else Jump_001_5251 0); 1/2 Jump_001_525b $2000; 4 Jump_001_526b $20000; 5 Jump_001_527b $10000; else Jump_001_528b $8000.
; Jump_001_5298: open ok else Jump_001_54d1; and $30==$30 → Jump_001_530e/jr_001_5311 RTC flag else Jump_001_531c; Jump_001_5320/Jump_001_5327 read+$200 VramCopyStack loop.
; Jump_001_53ee RTC/meta restore else Jump_001_5495 RtcReadDaysClearRegs; Jump_001_54bc close → PreLaunchFramStamp.
; Jump_001_54d1 Memset $FF; Jump_001_54e9 blank write twin; Jump_001_559a RtcReadDaysClearRegs → PreLaunchFramStamp.

BackupOpenSaverPath::
    add sp, -$1e
    ld hl, $001e
    push hl
    ld hl, SaverDirSlashStr
    push hl
    ld hl, $c3a5
    push hl
    call Memcpy
    add sp, $06
    ld hl, sp+$24
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $c3a5
    push hl
    call FarCallTrampoline
    nop
    ld b, b
    ld bc, $e800
    inc b
    ld hl, $c3a5
    push hl
    call CStrLen
    add sp, $02
    ld b, d
    ld c, e
    ld hl, sp+$0b
    ld [hl], c
    ld a, [hl]
    dec a
    ld b, a
    add $a5
    ld c, a
    ld a, $c3
    adc $00
    ld b, a
    ld a, [bc]
    ld c, a
    sub $63
    jp z, BackupOpenSaverPath_forceSavExt

    ld a, c
    sub $43
    jp z, BackupOpenSaverPath_forceSavExt

    ld hl, sp+$0b
    inc [hl]

BackupOpenSaverPath_forceSavExt::
    ld hl, sp+$0b
    ld a, [hl]
    add $fd
    add $a5
    ld c, a
    ld a, $c3
    adc $00
    ld b, a
    ld a, $73
    ld [bc], a
    ld a, [hl]
    add $fe
    add $a5
    ld c, a
    ld a, $c3
    adc $00
    ld b, a
    ld a, $61
    ld [bc], a
    ld a, [hl]
    dec a
    add $a5
    ld c, a
    ld a, $c3
    adc $00
    ld b, a
    ld a, $76
    ld [bc], a
    ld de, $c3a5
    ld l, [hl]
    ld h, $00
    add hl, de
    ld c, l
    ld b, h
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld a, $00
    push af
    inc sp
    ld hl, $c3a5
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_06_7309
    add sp, $05
    ld c, e
    ld hl, $d3ed
    ld a, [hl]
    or a
    jp z, BackupOpenSaverPath_sizeFromD3eb

    ld hl, $d3ed
    ld a, [hl]
    sub $01
    jp z, BackupOpenSaverPath_size2k

    ld hl, $d3ed
    ld a, [hl]
    sub $02
    jp z, BackupOpenSaverPath_size2k

    ld hl, $d3ed
    ld a, [hl]
    sub $04
    jp z, BackupOpenSaverPath_size20000

    ld hl, $d3ed
    ld a, [hl]
    sub $05
    jp z, BackupOpenSaverPath_size10000

    jp BackupOpenSaverPath_size8000


BackupOpenSaverPath_sizeFromD3eb::
    ld hl, $d3eb
    ld a, [hl]
    sub $02
    jp nz, BackupOpenSaverPath_sizeSkip2k

    jr BackupOpenSaverPath_size2kRtc

BackupOpenSaverPath_sizeSkip2k::
    jp BackupOpenSaverPath_size0


BackupOpenSaverPath_size2kRtc::
    ld hl, sp+$14
    ld [hl], $00
    inc hl
    ld [hl], $20
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp BackupOpenSaverPath_openOk


BackupOpenSaverPath_size0::
    xor a
    ld hl, sp+$14
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    jp BackupOpenSaverPath_openOk


BackupOpenSaverPath_size2k::
    ld hl, sp+$14
    ld [hl], $00
    inc hl
    ld [hl], $20
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp BackupOpenSaverPath_openOk


BackupOpenSaverPath_size20000::
    ld hl, sp+$14
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $02
    inc hl
    ld [hl], $00
    jp BackupOpenSaverPath_openOk


BackupOpenSaverPath_size10000::
    ld hl, sp+$14
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $01
    inc hl
    ld [hl], $00
    jp BackupOpenSaverPath_openOk


BackupOpenSaverPath_size8000::
    ld hl, sp+$14
    ld [hl], $00
    inc hl
    ld [hl], $80
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00

BackupOpenSaverPath_openOk::
    xor a
    or c
    jp nz, BackupOpenSaverPath_failMemsetFf

    ld a, $03
    push af
    inc sp
    ld hl, $c3a5
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_06_7309
    add sp, $05
    ld bc, $ca19
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$04
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld hl, sp+$04
    ld d, h
    ld e, l
    ld hl, sp+$14
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld hl, $0000
    push hl
    ld hl, $0000
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_03_76cc
    add sp, $06
    ld hl, sp+$14
    ld a, [hl]
    and $30
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$04
    ld a, [hl]
    sub $30
    jp nz, BackupOpenSaverPath_rtcFlagSkip

    inc hl
    ld a, [hl]
    or a
    jp nz, BackupOpenSaverPath_rtcFlagSkip

    inc hl
    ld a, [hl]
    or a
    jp nz, BackupOpenSaverPath_rtcFlagSkip

    inc hl
    ld a, [hl]
    or a
    jp nz, BackupOpenSaverPath_rtcFlagSkip

    jr BackupOpenSaverPath_rtcFlagSet

BackupOpenSaverPath_rtcFlagSkip::
    jp BackupOpenSaverPath_afterRtcFlag


BackupOpenSaverPath_rtcFlagSet::
    ld hl, sp+$08
    ld [hl], $01
    ld hl, sp+$14
    ld [hl], $00
    jp BackupOpenSaverPath_readInit


BackupOpenSaverPath_afterRtcFlag::
    ld hl, sp+$08
    ld [hl], $00

BackupOpenSaverPath_readInit::
    xor a
    ld hl, sp+$1a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

BackupOpenSaverPath_readLoop::
    ld hl, sp+$1a
    ld d, h
    ld e, l
    ld hl, sp+$14
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp nc, BackupOpenSaverPath_rtcMetaRestore

    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld hl, sp+$18
    ld c, l
    ld b, h
    push bc
    ld hl, $0200
    push hl
    ld hl, $c0a0
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_06_779a
    add sp, $08
    ld bc, $4000
    push bc
    ld a, $0d
    push af
    inc sp
    ld hl, sp+$1f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$1f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shr
    add sp, $05
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
    ld a, $03
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld hl, sp+$1a
    ld a, [hl]
    ld hl, sp+$00
    ld [hl], a
    ld hl, sp+$1b
    ld a, [hl]
    and $1f
    ld hl, sp+$01
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld a, d
    add $a0
    push af
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    adc $00
    ld e, a
    ld a, d
    adc $00
    ld [hl-], a
    ld [hl], e
    dec hl
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, $0200
    push hl
    ld hl, $c0a0
    push hl
    push bc
    call VramCopyStack
    add sp, $06
    ld hl, sp+$1a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld a, d
    add $02
    push af
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    adc $00
    ld e, a
    ld a, d
    adc $00
    ld [hl-], a
    ld [hl], e
    jp BackupOpenSaverPath_readLoop


BackupOpenSaverPath_rtcMetaRestore::
    xor a
    ld hl, sp+$08
    or [hl]
    jp z, BackupOpenSaverPath_rtcReadDaysClear

    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    add $28
    ld e, a
    ld a, d
    adc $00
    push af
    ld hl, sp+$13
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$18
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    adc $00
    ld e, a
    ld a, d
    adc $00
    ld hl, sp+$13
    ld [hl-], a
    ld [hl], e
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$12
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_03_76cc
    add sp, $06
    ld hl, sp+$18
    ld c, l
    ld b, h
    push bc
    ld hl, $0004
    push hl
    ld hl, $d3f2
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_06_779a
    add sp, $08
    ld hl, sp+$16
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$16
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_03_76cc
    add sp, $06
    ld hl, sp+$18
    ld c, l
    ld b, h
    push bc
    ld hl, $0030
    push hl
    ld hl, $c0a0
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_06_779a
    add sp, $08
    ld hl, $d3f4
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $d3f2
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call RtcWriteTimeFromDayDelta
    add sp, $04
    push hl
    ld hl, sp+$0e
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    jp BackupOpenSaverPath_closePreLaunch


BackupOpenSaverPath_rtcReadDaysClear::
    xor a
    ld hl, $d3f0
    or [hl]
    jp z, BackupOpenSaverPath_closePreLaunch

    call RtcReadDaysClearRegs
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld d, h
    ld e, l
    ld hl, sp+$0c
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a

BackupOpenSaverPath_closePreLaunch::
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld hl, $ca0f
    push hl
    call FarCall_03_768f
    add sp, $02
    jp PreLaunchFramStamp


BackupOpenSaverPath_failMemsetFf::
    ld hl, $0200
    push hl
    ld a, $ff
    push af
    inc sp
    ld hl, $c0a0
    push hl
    call Memset
    add sp, $05
    xor a
    ld hl, sp+$1a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

BackupOpenSaverPath_failBlankWrite::
    ld hl, sp+$1a
    ld d, h
    ld e, l
    ld hl, sp+$14
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp nc, BackupOpenSaverPath_failRtcPreLaunch

    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld bc, $4000
    push bc
    ld a, $0d
    push af
    inc sp
    ld hl, sp+$1f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$1f
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shr
    add sp, $05
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
    ld a, $03
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld hl, sp+$1a
    ld a, [hl]
    ld hl, sp+$00
    ld [hl], a
    ld hl, sp+$1b
    ld a, [hl]
    and $1f
    ld hl, sp+$01
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld a, d
    add $a0
    push af
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    adc $00
    ld e, a
    ld a, d
    adc $00
    ld [hl-], a
    ld [hl], e
    dec hl
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, $0200
    push hl
    ld hl, $c0a0
    push hl
    push bc
    call VramCopyStack
    add sp, $06
    ld hl, sp+$1a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld a, d
    add $02
    push af
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    adc $00
    ld e, a
    ld a, d
    adc $00
    ld [hl-], a
    ld [hl], e
    jp BackupOpenSaverPath_failBlankWrite


BackupOpenSaverPath_failRtcPreLaunch::
    call RtcReadDaysClearRegs
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld d, h
    ld e, l
    ld hl, sp+$0c
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01

; [ezgb]
; PreLaunchFramStamp: page $11 (SetFpgaPage_B1 $03) per-launch FRAM stamp for SAVER/*.SAV.
; $A000=$AA backup-pending, $A001=auto-save, $A00F=save bank count, $A010+=basename from $c3a5.
; Jump_001_561d: copy basename until len@sp+$0b (jr_001_5654 ++idx); done → Jump_001_5657.
; Jump_001_5657: if $d3f0 → $A202=$77 + ROM size@$A210–13 else Jump_001_5716 $A202=0; Jump_001_571c: $4000=0, page $00 ret. Next LaunchSetup.

PreLaunchFramStamp::
    ld a, $0d
    push af
    inc sp
    ld hl, sp+$17
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$17
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shr
    add sp, $05
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld d, h
    ld e, l
    ld hl, sp+$14
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld bc, $4000
    ld a, $11
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld bc, $a000
    ld a, $aa
    ld [bc], a
    ld bc, $a001
    ld hl, sp+$14
    ld a, [hl]
    ld [bc], a
    ld bc, $a00f
    ld hl, sp+$0b
    ld a, [hl]
    ld [bc], a
    dec hl
    dec hl
    ld [hl], $00
    inc hl
    ld [hl], $00

PreLaunchFramStamp_copyBasename::
    ld hl, sp+$0b
    ld c, [hl]
    ld b, $00
    dec hl
    dec hl
    ld a, [hl]
    sub c
    inc hl
    ld a, [hl]
    sbc b
    jp nc, PreLaunchFramStamp_checkRtc

    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $a010
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    ld de, $c3a5
    ld hl, sp+$09
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$09
    inc [hl]
    jr nz, PreLaunchFramStamp_copyCont

    inc hl
    inc [hl]

PreLaunchFramStamp_copyCont::
    jp PreLaunchFramStamp_copyBasename


PreLaunchFramStamp_checkRtc::
    xor a
    ld hl, $d3f0
    or [hl]
    jp z, PreLaunchFramStamp_clearRtcFlag

    ld bc, $a202
    ld a, $77
    ld [bc], a
    ld bc, $a210
    ld hl, sp+$0c
    ld a, [hl]
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$04
    ld a, [hl]
    ld [bc], a
    ld bc, $a211
    push bc
    ld a, $08
    push af
    inc sp
    ld hl, sp+$11
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$11
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shr
    add sp, $05
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
    ld hl, sp+$05
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$04
    ld a, [hl]
    ld [bc], a
    ld bc, $a212
    push bc
    ld a, $10
    push af
    inc sp
    ld hl, sp+$11
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$11
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shr
    add sp, $05
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
    ld hl, sp+$05
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$04
    ld a, [hl]
    ld [bc], a
    ld bc, $a213
    push bc
    ld a, $18
    push af
    inc sp
    ld hl, sp+$11
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$11
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shr
    add sp, $05
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
    ld hl, sp+$05
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$04
    ld a, [hl]
    ld [bc], a
    jp PreLaunchFramStamp_epilogue


PreLaunchFramStamp_clearRtcFlag::
    ld bc, $a202
    ld a, $00
    ld [bc], a

PreLaunchFramStamp_epilogue::
    ld bc, $4000
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    add sp, $1e
    ret


SaverDirSlashStr::
    db "/SAVER/", $00

    add sp, -$0e
    ld a, $01
    ld hl, sp+$14
    sub [hl]
    ld a, $00
    inc hl
    sbc [hl]
    jp nc, Jump_001_58ad

    ld bc, $4000
    ld a, $01
    ld [bc], a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0001
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$09
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$0c
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_001_5761:
    ld hl, sp+$0c
    ld d, h
    ld e, l
    ld hl, sp+$08
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp nc, Jump_001_58ad

    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld b, a
    ld c, e
    ld de, $0001
    ld a, c
    sub e
    ld e, a
    ld a, b
    sbc d
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$0a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$04
    ld [hl], $00
    inc hl
    ld [hl], $00

Jump_001_579b:
    ld hl, sp+$0a
    ld d, h
    ld e, l
    ld hl, sp+$06
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp nc, Jump_001_58a3

    ld hl, sp+$0a
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld e, c
    ld d, b
    ld l, e
    ld h, d
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    add hl, hl
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], d
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, sp+$00
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call FarCallTrampoline
    ld c, b
    ld b, b
    ld bc, $e800
    inc b
    ld b, d
    ld c, e
    ld a, $00
    sub c
    ld a, $00
    sbc b
    rlca
    jp nc, Jump_001_588a

    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, $00ff
    push hl
    push bc
    ld hl, $c0a0
    push hl
    call Memcpy
    add sp, $06
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, $00ff
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call Memcpy
    add sp, $06
    ld hl, $c2a0
    ld hl, $c2a0
    ld e, [hl]
    ld hl, $c2a1
    ld d, [hl]
    ld hl, sp+$04
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld hl, $00ff
    push hl
    ld hl, $c0a0
    push hl
    push bc
    call Memcpy
    add sp, $06

Jump_001_588a:
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $00ff
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$0a
    inc [hl]
    jr nz, jr_001_58a0

    inc hl
    inc [hl]

jr_001_58a0:
    jp Jump_001_579b


Jump_001_58a3:
    ld hl, sp+$0c
    inc [hl]
    jr nz, jr_001_58aa

    inc hl
    inc [hl]

jr_001_58aa:
    jp Jump_001_5761


Jump_001_58ad:
    add sp, $0e
    ret


; [ezgb]
; LaunchSetup(path): Open_B6 → FIL@sp+$20; fail DE:HL=$ffffffff Jump_001_5c02. After BackupOpenSaverPath; see launch-trace.
; Jump_001_58f9: $c7a9==2 → Jump_001_5905/jr_001_5908 FAT12 limit $0000ffff else Jump_001_5918 $0ffffff7; join Jump_001_5925 seed FarCall_05_4279 @$c0a0.
; Jump_001_59e4: walk clusters FarCall_05_4378 (jr_001_5a2c); EOF → Jump_001_5b12 else Jump_001_5a72 U32Mul*$c7ab + 4279 append.
; Jump_001_5b12: if sum<limit → Jump_001_59e4 else close 768f + stamp footer @$c0a0+$1f0/+1f4/+1f8 → Jump_001_5c02 ret 0.

LaunchSetup::
    ld hl, $fdbc
    add hl, sp
    ld sp, hl
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld hl, sp+$20
    ld c, l
    ld b, h
    ld a, $01
    push af
    inc sp
    ld hl, $024b
    add hl, sp
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call FarCall_06_7309
    add sp, $05
    ld c, e
    ld hl, $0240
    add hl, sp
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, $0240
    add hl, sp
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, LaunchSetup_fatTypeCheck

    ld de, $ffff
    ld hl, $ffff
    jp LaunchSetup_epilogueRet


LaunchSetup_fatTypeCheck::
    ld de, $c7a9
    ld a, [de]
    ld c, a
    sub $02
    jp nz, LaunchSetup_skipFat12

    jr LaunchSetup_fat12Limit

LaunchSetup_skipFat12::
    jp LaunchSetup_fatOtherLimit


LaunchSetup_fat12Limit::
    ld hl, sp+$0e
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp LaunchSetup_seedClust2Sect


LaunchSetup_fatOtherLimit::
    ld hl, sp+$0e
    ld [hl], $f7
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $ff
    inc hl
    ld [hl], $0f

LaunchSetup_seedClust2Sect::
    ld hl, sp+$20
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000e
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$1a
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld hl, sp+$08
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $000a
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$0a
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld hl, sp+$1e
    ld [hl], $a0
    inc hl
    ld [hl], $c0
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$1e
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$1c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$1c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $c7a9
    push hl
    call FarCall_05_4279
    add sp, $06
    push hl
    ld hl, sp+$06
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$1e
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$1a
    ld d, h
    ld e, l
    ld hl, sp+$16
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    xor a
    ld hl, sp+$12
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

LaunchSetup_walkClusters::
    ld hl, sp+$20
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, [de]
    ld c, a
    inc de
    ld a, [de]
    ld b, a
    ld hl, sp+$1c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$1c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    push bc
    call FarCall_05_4378
    add sp, $06
    push hl
    ld hl, sp+$06
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$04
    ld d, h
    ld e, l
    ld hl, sp+$1a
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld hl, sp+$12
    inc [hl]
    jr nz, LaunchSetup_walkCont

    inc hl
    inc [hl]
    jr nz, LaunchSetup_walkCont

    inc hl
    inc [hl]
    jr nz, LaunchSetup_walkCont

    inc hl
    inc [hl]

LaunchSetup_walkCont::
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    add $01
    ld e, a
    ld a, d
    adc $00
    push af
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$1a
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    adc $00
    ld e, a
    ld a, d
    adc $00
    ld hl, sp+$07
    ld [hl-], a
    ld [hl], e
    ld hl, sp+$1a
    ld a, [hl]
    ld hl, sp+$04
    sub [hl]
    jp nz, LaunchSetup_appendCluster

    ld hl, sp+$1b
    ld a, [hl]
    ld hl, sp+$05
    sub [hl]
    jp nz, LaunchSetup_appendCluster

    ld hl, sp+$1c
    ld a, [hl]
    ld hl, sp+$06
    sub [hl]
    jp nz, LaunchSetup_appendCluster

    ld hl, sp+$1d
    ld a, [hl]
    ld hl, sp+$07
    sub [hl]
    jp z, LaunchSetup_eofCheck

LaunchSetup_appendCluster::
    ld bc, $c7ab
    ld a, [bc]
    ld c, a
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$06
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$18
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$18
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Mul
    add sp, $08
    push hl
    ld hl, sp+$06
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$1e
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$1c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$1c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $c7a9
    push hl
    call FarCall_05_4279
    add sp, $06
    push hl
    ld hl, sp+$06
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$04
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$1e
    ld [hl+], a
    ld [hl], d

LaunchSetup_eofCheck::
    ld hl, sp+$1a
    ld d, h
    ld e, l
    ld hl, sp+$16
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld hl, sp+$1a
    ld d, h
    ld e, l
    ld hl, sp+$0e
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp c, LaunchSetup_walkClusters

    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$1f
    ld [hl-], a
    ld [hl], e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, sp+$1f
    ld [hl-], a
    ld [hl], e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $ff
    ld [de], a
    inc de
    ld a, $ff
    ld [de], a
    inc de
    ld a, $ff
    ld [de], a
    inc de
    ld a, $ff
    ld [de], a
    ld hl, sp+$20
    ld c, l
    ld b, h
    push bc
    call FarCall_03_768f
    add sp, $02
    ld hl, sp+$1e
    ld [hl], $a0
    inc hl
    ld [hl], $c0
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $01f0
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld hl, sp+$0a
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $01f4
    add hl, de
    ld c, l
    ld b, h
    ld e, c
    ld d, b
    ld a, $01
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    inc de
    ld a, $00
    ld [de], a
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $01f8
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld bc, $c7ab
    ld a, [bc]
    ld c, a
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, sp+$00
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    inc de
    inc hl
    ld a, [hl]
    ld [de], a
    ld de, $0000
    ld hl, $0000

LaunchSetup_epilogueRet::
    ld hl, $0244
    add hl, sp
    ld sp, hl
    ret


; [ezgb]
; MapCartTypeToUi(type@sp+$02): cart byte → $d3eb UI bucket + battery/timer/rumble flags. Feeds DrawCardTypeScreen / launch.
; Buckets → $d3eb: Jump_001_5d11=$0; Jump_001_5d19=$1; Jump_001_5d21=$2; Jump_001_5d29=$3; Jump_001_5d31=$4; Jump_001_5d39/Jump_001_5d41=$6; join Jump_001_5d46.
; Jump_001_5d46: battery types → Jump_001_5db2/jr_001_5db2 $d3ef=1 else Jump_001_5daf → Jump_001_5dba=0; then Jump_001_5dbf.
; Jump_001_5dbf: $0f/$10 → Jump_001_5dd4/jr_001_5dd4 $d3f0=1 else Jump_001_5dd1 → Jump_001_5ddc=0; Jump_001_5de1.
; Jump_001_5de1: $1c..$1e jp-table → Jump_001_5e06 $d3f1=1 else Jump_001_5e0e=0; Jump_001_5e13 ret. Falls into RomLoaderMain.

MapCartTypeToUi::
    ld hl, sp+$02
    ld a, [hl]
    or a
    jp z, MapCartTypeToUi_bucket0

    ld hl, sp+$02
    ld a, [hl]
    sub $01
    jp z, MapCartTypeToUi_bucket1

    ld hl, sp+$02
    ld a, [hl]
    sub $02
    jp z, MapCartTypeToUi_bucket1

    ld hl, sp+$02
    ld a, [hl]
    sub $03
    jp z, MapCartTypeToUi_bucket1

    ld hl, sp+$02
    ld a, [hl]
    sub $05
    jp z, MapCartTypeToUi_bucket2

    ld hl, sp+$02
    ld a, [hl]
    sub $06
    jp z, MapCartTypeToUi_bucket2

    ld hl, sp+$02
    ld a, [hl]
    sub $08
    jp z, MapCartTypeToUi_bucket0

    ld hl, sp+$02
    ld a, [hl]
    sub $09
    jp z, MapCartTypeToUi_bucket0

    ld hl, sp+$02
    ld a, [hl]
    sub $0b
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $0c
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $0d
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $0f
    jp z, MapCartTypeToUi_bucket3

    ld hl, sp+$02
    ld a, [hl]
    sub $10
    jp z, MapCartTypeToUi_bucket3

    ld hl, sp+$02
    ld a, [hl]
    sub $11
    jp z, MapCartTypeToUi_bucket3

    ld hl, sp+$02
    ld a, [hl]
    sub $12
    jp z, MapCartTypeToUi_bucket3

    ld hl, sp+$02
    ld a, [hl]
    sub $13
    jp z, MapCartTypeToUi_bucket3

    ld hl, sp+$02
    ld a, [hl]
    sub $15
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $16
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $17
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $19
    jp z, MapCartTypeToUi_bucket4

    ld hl, sp+$02
    ld a, [hl]
    sub $1a
    jp z, MapCartTypeToUi_bucket4

    ld hl, sp+$02
    ld a, [hl]
    sub $1b
    jp z, MapCartTypeToUi_bucket4

    ld hl, sp+$02
    ld a, [hl]
    sub $1c
    jp z, MapCartTypeToUi_bucket4

    ld hl, sp+$02
    ld a, [hl]
    sub $1d
    jp z, MapCartTypeToUi_bucket4

    ld hl, sp+$02
    ld a, [hl]
    sub $1e
    jp z, MapCartTypeToUi_bucket4

    ld hl, sp+$02
    ld a, [hl]
    sub $22
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $55
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $56
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $ea
    jp z, MapCartTypeToUi_bucket1

    ld hl, sp+$02
    ld a, [hl]
    sub $fc
    jp z, MapCartTypeToUi_bucket3

    ld hl, sp+$02
    ld a, [hl]
    sub $fd
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    sub $fe
    jp z, MapCartTypeToUi_bucket6a

    ld hl, sp+$02
    ld a, [hl]
    inc a
    jp z, MapCartTypeToUi_bucket1

    jp MapCartTypeToUi_bucket6b


MapCartTypeToUi_bucket0::
    ld hl, $d3eb
    ld [hl], $00
    jp MapCartTypeToUi_batteryCheck


MapCartTypeToUi_bucket1::
    ld hl, $d3eb
    ld [hl], $01
    jp MapCartTypeToUi_batteryCheck


MapCartTypeToUi_bucket2::
    ld hl, $d3eb
    ld [hl], $02
    jp MapCartTypeToUi_batteryCheck


MapCartTypeToUi_bucket3::
    ld hl, $d3eb
    ld [hl], $03
    jp MapCartTypeToUi_batteryCheck


MapCartTypeToUi_bucket4::
    ld hl, $d3eb
    ld [hl], $04
    jp MapCartTypeToUi_batteryCheck


MapCartTypeToUi_bucket6a::
    ld hl, $d3eb
    ld [hl], $06
    jp MapCartTypeToUi_batteryCheck


MapCartTypeToUi_bucket6b::
    ld hl, $d3eb
    ld [hl], $06

MapCartTypeToUi_batteryCheck::
    ld hl, sp+$02
    ld a, [hl]
    sub $03
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $06
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $09
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $0d
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $0f
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $10
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $13
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $17
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $1b
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $1e
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $22
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    sub $fd
    jp z, MapCartTypeToUi_batterySet

    ld hl, sp+$02
    ld a, [hl]
    inc a
    jp nz, MapCartTypeToUi_batterySkip

    jr MapCartTypeToUi_batterySet

MapCartTypeToUi_batterySkip::
    jp MapCartTypeToUi_batteryClear


MapCartTypeToUi_batterySet::
    ld hl, $d3ef
    ld [hl], $01
    jp MapCartTypeToUi_timerCheck


MapCartTypeToUi_batteryClear::
    ld hl, $d3ef
    ld [hl], $00

MapCartTypeToUi_timerCheck::
    ld hl, sp+$02
    ld a, [hl]
    sub $0f
    jp z, MapCartTypeToUi_timerSet

    ld hl, sp+$02
    ld a, [hl]
    sub $10
    jp nz, MapCartTypeToUi_timerSkip

    jr MapCartTypeToUi_timerSet

MapCartTypeToUi_timerSkip::
    jp MapCartTypeToUi_timerClear


MapCartTypeToUi_timerSet::
    ld hl, $d3f0
    ld [hl], $01
    jp MapCartTypeToUi_rumbleCheck


MapCartTypeToUi_timerClear::
    ld hl, $d3f0
    ld [hl], $00

MapCartTypeToUi_rumbleCheck::
    ld hl, sp+$02
    ld a, [hl]
    sub $1c
    jp c, MapCartTypeToUi_rumbleClear

    ld a, $1e
    sub [hl]
    jp c, MapCartTypeToUi_rumbleClear

    ld a, [hl]
    add $e4
    ld c, a
    ld e, c
    ld d, $00
    ld hl, $5dfd
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp MapCartTypeToUi_rumbleSet


    jp MapCartTypeToUi_rumbleSet


    jp MapCartTypeToUi_rumbleSet


MapCartTypeToUi_rumbleSet::
    ld hl, $d3f1
    ld [hl], $01
    jp MapCartTypeToUi_ret


MapCartTypeToUi_rumbleClear::
    ld hl, $d3f1
    ld [hl], $00

MapCartTypeToUi_ret::
    ret


; [ezgb]
; RomLoaderMain(path@sp+$1c): Open_B6 → $ca0f; fail E=$ff Jump_001_601b. See launch-trace.
; Jump_001_5e56: fsize→$c2a4/$c2a5; seek0; read $200 hdr@$c0a0; Jump_001_5ec8 checksum $134..$14c → $c5a3 (jr_001_5ef2).
; Jump_001_5ef5: hdr cart/ROM/RAM → $d3ec/$d3ed/$d3ee + MapCartTypeToUi; if $d3eb!=1 Jump_001_5f2a → Jump_001_600f else jr_001_5f2d size gate.
; Jump_001_5f6a: XOR-fold bytes (jr_001_5fe5); Jump_001_5fe8 cmp LE $e06c8834; hit jr_001_600a $d3eb=$05 (MBC1m) else Jump_001_6007; Jump_001_600f close ret E=status.

RomLoaderMain::
    add sp, -$15
    xor a
    ld hl, sp+$08
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld a, $01
    push af
    inc sp
    ld hl, sp+$1c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_06_7309
    add sp, $05
    ld c, e
    ld hl, sp+$11
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$11
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp z, RomLoaderMain_readHdr

    ld e, $ff
    jp RomLoaderMain_failRetFf


RomLoaderMain_readHdr::
    ld bc, $ca19
    ld e, c
    ld d, b
    ld a, [de]
    ld hl, sp+$04
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld a, $0e
    push af
    inc sp
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$07
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shr
    add sp, $05
    push hl
    ld hl, sp+$06
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$04
    ld a, [hl]
    ld hl, $c2a4
    ld [hl], a
    ld hl, sp+$05
    ld a, [hl]
    ld hl, $c2a5
    ld [hl], a
    ld hl, $0000
    push hl
    ld hl, $0000
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_03_76cc
    add sp, $06
    ld hl, sp+$0f
    ld c, l
    ld b, h
    push bc
    ld hl, $0200
    push hl
    ld hl, $c0a0
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_06_779a
    add sp, $08
    ld hl, $c5a3
    ld [hl], $00
    ld hl, sp+$0d
    ld [hl], $34
    inc hl
    ld [hl], $01

RomLoaderMain_checksumLoop::
    ld a, $4c
    ld hl, sp+$0d
    sub [hl]
    ld a, $01
    inc hl
    sbc [hl]
    jp c, RomLoaderMain_mapCartType

    ld de, $c0a0
    dec hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, $c5a3
    ld a, [hl]
    sub c
    ld c, a
    dec a
    ld hl, $c5a3
    ld [hl], a
    ld hl, sp+$0d
    inc [hl]
    jr nz, RomLoaderMain_checksumCont

    inc hl
    inc [hl]

RomLoaderMain_checksumCont::
    jp RomLoaderMain_checksumLoop


RomLoaderMain_mapCartType::
    ld bc, $c1e7
    ld a, [bc]
    ld c, a
    ld hl, sp+$0c
    ld [hl], c
    ld bc, $c1e8
    ld a, [bc]
    ld hl, $d3ec
    ld [hl], a
    ld bc, $c1e9
    ld a, [bc]
    ld hl, $d3ed
    ld [hl], a
    ld bc, $c1ec
    ld a, [bc]
    ld hl, $d3ee
    ld [hl], a
    ld hl, sp+$0c
    ld a, [hl]
    push af
    inc sp
    call MapCartTypeToUi
    add sp, $01
    ld hl, $d3eb
    ld a, [hl]
    sub $01
    jp nz, RomLoaderMain_skipSizeGate

    jr RomLoaderMain_sizeGate

RomLoaderMain_skipSizeGate::
    jp RomLoaderMain_closeRet


RomLoaderMain_sizeGate::
    ld a, $20
    ld hl, $c2a4
    sub [hl]
    ld a, $00
    ld hl, $c2a5
    sbc [hl]
    jp nc, RomLoaderMain_closeRet

    ld hl, $0004
    push hl
    ld hl, $0000
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_03_76cc
    add sp, $06
    ld hl, sp+$0f
    ld c, l
    ld b, h
    push bc
    ld hl, $0200
    push hl
    ld hl, $c0a0
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_06_779a
    add sp, $08
    ld hl, sp+$0d
    ld [hl], $04
    inc hl
    ld [hl], $01

RomLoaderMain_xorFold::
    ld a, $33
    ld hl, sp+$0d
    sub [hl]
    ld a, $01
    inc hl
    sbc [hl]
    jp c, RomLoaderMain_cmpMagic

    ld a, $01
    push af
    inc sp
    ld hl, sp+$0b
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0b
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shl
    add sp, $05
    push hl
    ld hl, sp+$06
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld de, $c0a0
    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    ld a, [bc]
    ld c, a
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$00
    ld a, [hl]
    ld hl, sp+$04
    xor [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$05
    xor [hl]
    ld hl, sp+$01
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$06
    xor [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld a, [hl]
    ld hl, sp+$07
    xor [hl]
    ld hl, sp+$03
    ld [hl], a
    ld hl, sp+$00
    ld d, h
    ld e, l
    ld hl, sp+$08
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld hl, sp+$0d
    inc [hl]
    jr nz, RomLoaderMain_xorFoldCont

    inc hl
    inc [hl]

RomLoaderMain_xorFoldCont::
    jp RomLoaderMain_xorFold


RomLoaderMain_cmpMagic::
    ld hl, sp+$08
    ld a, [hl]
    sub $34
    jp nz, RomLoaderMain_skipMbc1m

    inc hl
    ld a, [hl]
    sub $88
    jp nz, RomLoaderMain_skipMbc1m

    inc hl
    ld a, [hl]
    sub $6c
    jp nz, RomLoaderMain_skipMbc1m

    inc hl
    ld a, [hl]
    sub $e0
    jp nz, RomLoaderMain_skipMbc1m

    jr RomLoaderMain_setMbc1m

RomLoaderMain_skipMbc1m::
    jp RomLoaderMain_closeRet


RomLoaderMain_setMbc1m::
    ld hl, $d3eb
    ld [hl], $05

RomLoaderMain_closeRet::
    ld hl, $ca0f
    push hl
    call FarCall_03_768f
    add sp, $02
    ld hl, sp+$11
    ld e, [hl]

RomLoaderMain_failRetFf::
    add sp, $15
    ret


; [ezgb]
; DrawCardTypeScreen: panel + CardtypeStr; $d3eb jp-table → MBC name ApplyBasename into sp+$0a then DrawString.
; MBC arms: Jump_001_606c, Jump_001_607d, Jump_001_608e, Jump_001_609f, Jump_001_60b0, Jump_001_60c1, Jump_001_60d2 → join Jump_001_60e0.
; Jump_001_60e0: ROM 32<<n KB (jr_001_6117/jr_001_611b) U32ToAscii+SizeKbStr; RAM Jump_001_619e=0, Jump_001_61a3=8, Jump_001_61a8=$80, Jump_001_61ad=$20 → Jump_001_61af.
; Jump_001_622e: $d3ef NoStr else YesStr; Jump_001_623f ReadJoypad; jr_001_624d/Jump_001_6250 until A/B; Jump_001_6258/jr_001_6258 ret.

DrawCardTypeScreen::
    add sp, -$1e
    call DrawInfoPanelRect
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $2a25
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, CardtypeStr
    push hl
    call DrawString
    add sp, $05
    ld a, $06
    ld hl, $d3eb
    sub [hl]
    jp c, DrawCardTypeScreen_afterMbc

    ld hl, $d3eb
    ld e, [hl]
    ld d, $00
    ld hl, $6057
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp DrawCardTypeScreen_mbcNone


    jp DrawCardTypeScreen_mbc1


    jp DrawCardTypeScreen_mbc2


    jp DrawCardTypeScreen_mbc3


    jp DrawCardTypeScreen_mbc5


    jp DrawCardTypeScreen_mbc1m


    jp DrawCardTypeScreen_mbcNot


DrawCardTypeScreen_mbcNone::
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, MbcNoneStr
    push hl
    push bc
    call ApplyBasename
    add sp, $04
    jp DrawCardTypeScreen_afterMbc


DrawCardTypeScreen_mbc1::
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, Mbc1Str
    push hl
    push bc
    call ApplyBasename
    add sp, $04
    jp DrawCardTypeScreen_afterMbc


DrawCardTypeScreen_mbc2::
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, Mbc2Str
    push hl
    push bc
    call ApplyBasename
    add sp, $04
    jp DrawCardTypeScreen_afterMbc


DrawCardTypeScreen_mbc3::
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, Mbc3Str
    push hl
    push bc
    call ApplyBasename
    add sp, $04
    jp DrawCardTypeScreen_afterMbc


DrawCardTypeScreen_mbc5::
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, Mbc5Str
    push hl
    push bc
    call ApplyBasename
    add sp, $04
    jp DrawCardTypeScreen_afterMbc


DrawCardTypeScreen_mbc1m::
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, Mbc1mStr
    push hl
    push bc
    call ApplyBasename
    add sp, $04
    jp DrawCardTypeScreen_afterMbc


DrawCardTypeScreen_mbcNot::
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, MbcNotStr
    push hl
    push bc
    call ApplyBasename
    add sp, $04

DrawCardTypeScreen_afterMbc::
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, S32DivImpl_epilogueRet
    push hl
    ld a, $00
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05
    ld hl, $3625
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, RomSizeLabelStr
    push hl
    call DrawString
    add sp, $05
    ld hl, sp+$0a
    ld a, l
    ld d, h
    ld hl, sp+$08
    ld [hl+], a
    ld [hl], d
    ld hl, $d3ec
    ld a, [hl]
    inc a
    push af
    ld bc, $0020
    pop af
    jr DrawCardTypeScreen_romShiftDone

DrawCardTypeScreen_romShiftLoop::
    sla c
    rl b

DrawCardTypeScreen_romShiftDone::
    dec a
    jr nz, DrawCardTypeScreen_romShiftLoop

    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], b
    ld a, b
    rla
    sbc a
    inc hl
    ld [hl+], a
    ld [hl], a
    ld a, $0a
    push af
    inc sp
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$09
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$09
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32ToAscii_B0
    add sp, $07
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, SizeKbStr
    push hl
    push bc
    call FarCallTrampoline
    nop
    ld b, b
    ld bc, $e800
    inc b
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, $365c
    push hl
    ld a, $00
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05
    ld hl, $4225
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, RamSizeLabelStr
    push hl
    call DrawString
    add sp, $05
    ld hl, $d3ed
    ld a, [hl]
    or a
    jp z, DrawCardTypeScreen_ram0

    ld hl, $d3ed
    ld a, [hl]
    sub $01
    jp z, DrawCardTypeScreen_ram8

    ld hl, $d3ed
    ld a, [hl]
    sub $02
    jp z, DrawCardTypeScreen_ram8

    ld hl, $d3ed
    ld a, [hl]
    sub $04
    jp z, DrawCardTypeScreen_ram80

    jp DrawCardTypeScreen_ram20


DrawCardTypeScreen_ram0::
    ld c, $00
    jp DrawCardTypeScreen_afterRam


DrawCardTypeScreen_ram8::
    ld c, $08
    jp DrawCardTypeScreen_afterRam


DrawCardTypeScreen_ram80::
    ld c, $80
    jp DrawCardTypeScreen_afterRam


DrawCardTypeScreen_ram20::
    ld c, $20

DrawCardTypeScreen_afterRam::
    ld hl, sp+$0a
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld a, $10
    push af
    inc sp
    inc hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$05
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32ToAscii_B0
    add sp, $07
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, SizeKbStr
    push hl
    push bc
    call FarCallTrampoline
    nop
    ld b, b
    ld bc, $e800
    inc b
    ld hl, sp+$0a
    ld c, l
    ld b, h
    ld hl, $425c
    push hl
    ld a, $00
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05
    ld hl, $4e25
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, BatteryLabelStr
    push hl
    call DrawString
    add sp, $05
    xor a
    ld hl, $d3ef
    or [hl]
    jp z, DrawCardTypeScreen_batteryNo

    ld hl, $4e5c
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, BatteryYesStr
    push hl
    call DrawString
    add sp, $05
    jp DrawCardTypeScreen_waitJoypad


DrawCardTypeScreen_batteryNo::
    ld hl, $4e5c
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, BatteryNoStr
    push hl
    call DrawString
    add sp, $05

DrawCardTypeScreen_waitJoypad::
    call ReadJoypad
    ld c, e
    ld b, $00
    ld a, c
    and $10
    jr nz, DrawCardTypeScreen_waitA

    jp DrawCardTypeScreen_waitB


DrawCardTypeScreen_waitA::
    jp DrawCardTypeScreen_epilogueRet


DrawCardTypeScreen_waitB::
    ld a, c
    and $20
    jr nz, DrawCardTypeScreen_epilogueRet

    jp DrawCardTypeScreen_waitJoypad


DrawCardTypeScreen_epilogueRet::
    add sp, $1e
    ret


CardtypeStr::
    db "Cardtype:", $00

MbcNoneStr::
    db "NoMBC", $00

Mbc1Str::
    db "MBC1", $00

Mbc2Str::
    db "MBC2", $00

Mbc3Str::
    db "MBC3", $00

Mbc5Str::
    db "MBC5", $00

Mbc1mStr::
    db "MBC1M", $00

MbcNotStr::
    db "Not", $00

RomSizeLabelStr::
    db "ROM size:", $00

SizeKbStr::
    db "KB", $00

RamSizeLabelStr::
    db "RAM size:", $00

BatteryLabelStr::
    db "Battery :", $00

BatteryYesStr::
    db "Yes", $00

BatteryNoStr::
    db "No", $00

; [ezgb]
; DrawInfoPanelRect: StoreDrawParams($0002,$03) then DrawRect fill=$23 corners $7d25/$016c.
; Shared chrome behind Cardtype/BOOT/ROM-info style screens.

DrawInfoPanelRect::
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $016c
    push hl
    ld hl, $7d25
    push hl
    ld a, $23
    push af
    inc sp
    call DrawRect
    add sp, $05
    ret


; [ezgb]
; BootRomInfoMenu: locals sel@sp+$02 (0=BOOT/1=ROM INFO), redraw@sp+$03. Jump_001_62d9 DrawInfoPanelRect; Jump_001_62dc hilite BOOT strings.
; Jump_001_6328: ROM INFO ink twin. Jump_001_6364 ReadJoypad: $04 jr_001_637b sel-- → Jump_001_6386; $08 jr_001_6390 sel++ → Jump_001_63a3.
; $10 jr_001_63ad: sel==1 jr_001_63ba DrawCardTypeScreen → Jump_001_62d9; else Jump_001_63b7 → Jump_001_63e2 LoadingStr.
; $20 Jump_001_63c7/jr_001_63d1 E=$ff → Jump_001_6421; else Jump_001_63d6 Delay → Jump_001_62dc. Jump_001_63e2 Loading then Jump_001_6421 ret E=sel.

BootRomInfoMenu::
    push af
    push af
    ld hl, sp+$03
    ld [hl], $01
    dec hl
    ld [hl], $00

BootRomInfoMenu_drawPanel::
    call DrawInfoPanelRect

BootRomInfoMenu_hiliteBoot::
    xor a
    ld hl, sp+$03
    or [hl]
    jp z, BootRomInfoMenu_inputLoop

    xor a
    dec hl
    or [hl]
    jp nz, BootRomInfoMenu_romInfoInk

    ld hl, $0002
    push hl
    ld a, $01
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $2a25
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, BootMenuBootStr
    push hl
    call DrawString
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $3a25
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, BootMenuRomInfoStr
    push hl
    call DrawString
    add sp, $05
    jp BootRomInfoMenu_inputLoop


BootRomInfoMenu_romInfoInk::
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $2a25
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, BootMenuBootStr
    push hl
    call DrawString
    add sp, $05
    ld hl, $0002
    push hl
    ld a, $01
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $3a25
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, BootMenuRomInfoStr
    push hl
    call DrawString
    add sp, $05

BootRomInfoMenu_inputLoop::
    ld hl, sp+$03
    ld [hl], $00
    call ReadJoypad
    ld c, e
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], $00
    dec hl
    ld a, [hl]
    and $04
    jr nz, BootRomInfoMenu_selDec

    jp BootRomInfoMenu_afterSelDec


BootRomInfoMenu_selDec::
    xor a
    ld hl, sp+$02
    or [hl]
    jp z, BootRomInfoMenu_afterSelDec

    dec [hl]
    inc hl
    ld [hl], $01

BootRomInfoMenu_afterSelDec::
    ld hl, sp+$00
    ld a, [hl]
    and $08
    jr nz, BootRomInfoMenu_selInc

    jp BootRomInfoMenu_afterSelInc


BootRomInfoMenu_selInc::
    ld hl, sp+$02
    ld c, [hl]
    ld b, $00
    ld a, c
    sub $01
    ld a, b
    sbc $00
    rlca
    jp nc, BootRomInfoMenu_afterSelInc

    inc [hl]
    inc hl
    ld [hl], $01

BootRomInfoMenu_afterSelInc::
    ld hl, sp+$00
    ld a, [hl]
    and $10
    jr nz, BootRomInfoMenu_confirmA

    jp BootRomInfoMenu_checkB


BootRomInfoMenu_confirmA::
    ld hl, sp+$02
    ld a, [hl]
    sub $01
    jp nz, BootRomInfoMenu_bootLoading

    jr BootRomInfoMenu_romInfoScreen

BootRomInfoMenu_bootLoading::
    jp BootRomInfoMenu_loadingStr


BootRomInfoMenu_romInfoScreen::
    call DrawCardTypeScreen
    ld hl, sp+$03
    ld [hl], $01
    dec hl
    ld [hl], $00
    jp BootRomInfoMenu_drawPanel


BootRomInfoMenu_checkB::
    ld hl, sp+$00
    ld a, [hl]
    and $20
    jr nz, BootRomInfoMenu_cancelRetFf

    jp BootRomInfoMenu_delayRedraw


BootRomInfoMenu_cancelRetFf::
    ld e, $ff
    jp BootRomInfoMenu_epilogueRet


BootRomInfoMenu_delayRedraw::
    ld hl, $0064
    push hl
    call Delay
    add sp, $02
    jp BootRomInfoMenu_hiliteBoot


BootRomInfoMenu_loadingStr::
    ld hl, $0000
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $018f
    push hl
    ld hl, $9f00
    push hl
    ld a, $00
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $4133
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, BootMenuLoadingStr
    push hl
    call DrawString
    add sp, $05
    ld hl, sp+$02
    ld e, [hl]

BootRomInfoMenu_epilogueRet::
    add sp, $04
    ret


BootMenuBootStr::
    db "BOOT", $00

BootMenuRomInfoStr::
    db "ROM info", $00

BootMenuLoadingStr::
    db "Loading", $00

; [ezgb]
; BackupSaveDump: open SAVER FarCall_06_7309 mode $12 → $ca0f; fail Jump_001_6738 ret.
; Jump_001_647b: while offset < size@sp+$0f: bank FRAM, VramCopyStack $200, FarCall_07_7739 write.
; Spinner ++sp+$04: Jump_001_652f; ==3 jr_001_6532 reset0; Jump_001_6536 "."; Jump_001_6551 → Jump_001_655b/jr_001_655e ".."; Jump_001_6572 "..."; Jump_001_6583 +=$200 → Jump_001_647b.
; Jump_001_65a1: $d3f6==$77 → jr_001_65af Memset+$A220 pack+write else Jump_001_65ac → Jump_001_672f close 768f; Jump_001_6738 fail (jr_001_673f/jr_001_6743 strs).

BackupSaveDump::
    add sp, -$0b
    call WaitVBlankFlag
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld a, $12
    push af
    inc sp
    ld hl, $c3a5
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_06_7309
    add sp, $05
    ld c, e
    ld a, c
    or a
    jp nz, BackupSaveDump_epilogueRet

    ld hl, $0000
    push hl
    ld hl, $0000
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_03_76cc
    add sp, $06
    ld hl, sp+$04
    ld [hl], $00
    xor a
    ld hl, sp+$07
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

BackupSaveDump_writeLoop::
    ld hl, sp+$07
    ld d, h
    ld e, l
    ld hl, sp+$0f
    ld a, [de]
    sub [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    inc hl
    inc de
    ld a, [de]
    sbc [hl]
    jp nc, BackupSaveDump_checkRtcMagic

    ld bc, $4000
    push bc
    ld a, $0d
    push af
    inc sp
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0c
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shr
    add sp, $05
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
    ld a, $03
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld hl, sp+$07
    ld a, [hl]
    ld hl, sp+$00
    ld [hl], a
    ld hl, sp+$08
    ld a, [hl]
    and $1f
    ld hl, sp+$01
    ld [hl+], a
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld a, d
    add $a0
    push af
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    adc $00
    ld e, a
    ld a, d
    adc $00
    ld [hl-], a
    ld [hl], e
    dec hl
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, $0200
    push hl
    push bc
    ld hl, $c0a0
    push hl
    call VramCopyStack
    add sp, $06
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld hl, sp+$05
    ld c, l
    ld b, h
    push bc
    ld hl, $0200
    push hl
    ld hl, $c0a0
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_07_7739
    add sp, $08
    ld hl, sp+$04
    inc [hl]
    ld a, [hl]
    sub $03
    jp nz, BackupSaveDump_spinnerSkipReset

    jr BackupSaveDump_spinnerReset0

BackupSaveDump_spinnerSkipReset::
    jp BackupSaveDump_spinnerDot


BackupSaveDump_spinnerReset0::
    ld hl, sp+$04
    ld [hl], $00

BackupSaveDump_spinnerDot::
    xor a
    ld hl, sp+$04
    or [hl]
    jp nz, BackupSaveDump_afterDot

    ld hl, $0a0b
    push hl
    ld a, $03
    push af
    inc sp
    ld hl, $673b
    push hl
    call DrawString
    add sp, $05
    jp BackupSaveDump_advance200


BackupSaveDump_afterDot::
    ld hl, sp+$04
    ld a, [hl]
    sub $01
    jp nz, BackupSaveDump_spinnerSkipDots

    jr BackupSaveDump_spinnerDots

BackupSaveDump_spinnerSkipDots::
    jp BackupSaveDump_spinnerEllipsis


BackupSaveDump_spinnerDots::
    ld hl, $0a0b
    push hl
    ld a, $03
    push af
    inc sp
    ld hl, $673f
    push hl
    call DrawString
    add sp, $05
    jp BackupSaveDump_advance200


BackupSaveDump_spinnerEllipsis::
    ld hl, $0a0b
    push hl
    ld a, $03
    push af
    inc sp
    ld hl, $6743
    push hl
    call DrawString
    add sp, $05

BackupSaveDump_advance200::
    ld hl, sp+$07
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, e
    ld a, d
    add $02
    push af
    ld [hl-], a
    ld [hl], e
    inc hl
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    pop af
    ld a, e
    adc $00
    ld e, a
    ld a, d
    adc $00
    ld [hl-], a
    ld [hl], e
    jp BackupSaveDump_writeLoop


BackupSaveDump_checkRtcMagic::
    ld hl, $d3f6
    ld a, [hl]
    sub $77
    jp nz, BackupSaveDump_skipRtcPack

    jr BackupSaveDump_rtcPackWrite

BackupSaveDump_skipRtcPack::
    jp BackupSaveDump_close


BackupSaveDump_rtcPackWrite::
    ld hl, $0030
    push hl
    ld a, $00
    push af
    inc sp
    ld hl, $c0a0
    push hl
    call Memset
    add sp, $05
    ld bc, $4000
    ld a, $11
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld bc, $a220
    ld a, [bc]
    ld de, $c0a0
    ld [de], a
    ld de, $c0a0
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a221
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $0008
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a222
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $000c
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a223
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $0010
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a224
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $0014
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a220
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $0018
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a221
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $001c
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a222
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $0020
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a223
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $0024
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a224
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $0028
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a210
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $0029
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a211
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $002a
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a212
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld de, $c0a0
    ld hl, $002b
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld bc, $a213
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld bc, $4000
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B1
    add sp, $01
    ld hl, sp+$11
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$11
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_03_76cc
    add sp, $06
    ld hl, sp+$05
    ld c, l
    ld b, h
    push bc
    ld hl, $0030
    push hl
    ld hl, $c0a0
    push hl
    ld hl, $ca0f
    push hl
    call FarCall_07_7739
    add sp, $08

BackupSaveDump_close::
    ld hl, $ca0f
    push hl
    call FarCall_03_768f
    add sp, $02

BackupSaveDump_epilogueRet::
    add sp, $0b
    ret


    ld l, $20
    jr nz, jr_001_673f

jr_001_673f:
    ld l, $2e
    jr nz, jr_001_6743

jr_001_6743:
    ld l, $2e
    ld l, $00

; [ezgb]
; BackupSavePrompt(auto@sp+$12, size@sp+$10): draw BACKUPSAVE box + BackupUiStrings.
; auto!=1 → Jump_001_6784 → Jump_001_67d0 prompt; else jr_001_6787: Saving str, U32Shl size<<$0d, BackupSaveDump → Jump_001_6891.
; Jump_001_67d0: draw [B]NO/[A]OK; Jump_001_6821 joy loop: A($10) jr_001_682f dump twin → Jump_001_6891; B($20) Jump_001_6889 skip → Jump_001_6891; else spin.
; Jump_001_6891/jr_001_6891: epilogue ret.

BackupSavePrompt::
    push af
    push af
    push af
    push af
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $016c
    push hl
    ld hl, $7d25
    push hl
    ld a, $23
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, $0505
    push hl
    ld a, $0a
    push af
    inc sp
    ld hl, BackupUiStrings
    push hl
    call DrawString
    add sp, $05
    ld hl, sp+$12
    ld a, [hl]
    sub $01
    jp nz, BackupSavePrompt_skipAuto

    jr BackupSavePrompt_autoDump

BackupSavePrompt_skipAuto::
    jp BackupSavePrompt_drawConfirm


BackupSavePrompt_autoDump::
    ld hl, $0a05
    push hl
    ld a, $09
    push af
    inc sp
    ld hl, $689f
    push hl
    call DrawString
    add sp, $05
    ld a, $0d
    push af
    inc sp
    ld hl, sp+$11
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$11
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shl
    add sp, $05
    push hl
    ld hl, sp+$06
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
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
    ld hl, $68a9
    push hl
    call BackupSaveDump
    add sp, $06
    jp BackupSavePrompt_epilogueRet


BackupSavePrompt_drawConfirm::
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $016a
    push hl
    ld hl, $505d
    push hl
    ld a, $27
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, $016a
    push hl
    ld hl, $7b5d
    push hl
    ld a, $52
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, $0c05
    push hl
    ld a, $05
    push af
    inc sp
    ld hl, $68aa
    push hl
    call DrawString
    add sp, $05
    ld hl, DrawDirEntryLabel_bankShift
    push hl
    ld a, $05
    push af
    inc sp
    ld hl, $68b0
    push hl
    call DrawString
    add sp, $05

BackupSavePrompt_joyLoop::
    call ReadJoypad
    ld c, e
    ld b, $00
    ld a, c
    and $10
    jr nz, BackupSavePrompt_confirmDump

    jp BackupSavePrompt_checkB


BackupSavePrompt_confirmDump::
    ld hl, $0a05
    push hl
    ld a, $09
    push af
    inc sp
    ld hl, $689f
    push hl
    call DrawString
    add sp, $05
    ld a, $0d
    push af
    inc sp
    ld hl, sp+$11
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$11
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Shl
    add sp, $05
    push hl
    ld hl, sp+$02
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$00
    ld d, h
    ld e, l
    ld hl, sp+$04
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
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
    ld hl, $68a9
    push hl
    call BackupSaveDump
    add sp, $06
    jp BackupSavePrompt_epilogueRet


BackupSavePrompt_checkB::
    ld a, c
    and $20
    jr nz, BackupSavePrompt_epilogueRet

    jp BackupSavePrompt_joyLoop


BackupSavePrompt_epilogueRet::
    add sp, $08
    ret


BackupUiStrings::
    db "BACKUPSAVE", $00, "Saving...", $00, $00, "[B]NO", $00, "[A]OK", $00

BootUnpackWramTables::
    ld hl, $cc31
    ld [hl], $ee
    ld hl, $cc32
    ld [hl], $ee
    ld hl, wWToUpperKeys
    call RleUnpack

    db $7f, $e0, $00, $e1, $00, $e2, $00, $e3, $00, $e4, $00, $e5, $00, $e6, $00, $e7
    db $00, $e8, $00, $e9, $00, $ea, $00, $eb, $00, $ec, $00, $ed, $00, $ee, $00, $ef
    db $00, $f0, $00, $f1, $00, $f2, $00, $f3, $00, $f4, $00, $f5, $00, $f6, $00, $f8
    db $00, $f9, $00, $fa, $00, $fb, $00, $fc, $00, $fd, $00, $fe, $00, $ff, $00, $01
    db $01, $03, $01, $05, $01, $07, $01, $09, $01, $0b, $01, $0d, $01, $0f, $01, $11
    db $01, $13, $01, $15, $01, $17, $01, $19, $01, $1b, $01, $1d, $01, $1f, $01, $21
    db $01, $23, $01, $25, $01, $27, $01, $29, $01, $2b, $01, $2d, $01, $2f, $01, $31
    db $01, $33, $01, $35, $01, $37, $01, $3a, $01, $3c, $01, $3e, $01, $40, $01, $42
    db $7f, $01, $44, $01, $46, $01, $48, $01, $4b, $01, $4d, $01, $4f, $01, $51, $01
    db $53, $01, $55, $01, $57, $01, $59, $01, $5b, $01, $5d, $01, $5f, $01, $61, $01
    db $63, $01, $65, $01, $67, $01, $69, $01, $6b, $01, $6d, $01, $6f, $01, $71, $01
    db $73, $01, $75, $01, $77, $01, $7a, $01, $7c, $01, $7e, $01, $83, $01, $85, $01
    db $88, $01, $8c, $01, $92, $01, $99, $01, $a1, $01, $a3, $01, $a8, $01, $ad, $01
    db $b0, $01, $b4, $01, $b6, $01, $b9, $01, $bd, $01, $c6, $01, $c9, $01, $cc, $01
    db $ce, $01, $d0, $01, $d2, $01, $d4, $01, $d6, $01, $d8, $01, $da, $01, $dc, $01
    db $dd, $01, $df, $01, $e1, $01, $e3, $01, $e5, $01, $e7, $01, $e9, $01, $eb, $01
    db $7f, $ed, $01, $ef, $01, $f3, $01, $f5, $01, $fb, $01, $fd, $01, $ff, $01, $01
    db $02, $03, $02, $05, $02, $07, $02, $09, $02, $0b, $02, $0d, $02, $0f, $02, $11
    db $02, $13, $02, $15, $02, $17, $02, $b1, $03, $b2, $03, $b3, $03, $b4, $03, $b5
    db $03, $b6, $03, $b7, $03, $b8, $03, $b9, $03, $ba, $03, $bb, $03, $bc, $03, $bd
    db $03, $be, $03, $bf, $03, $c0, $03, $c1, $03, $c3, $03, $c4, $03, $c5, $03, $c6
    db $03, $c7, $03, $c8, $03, $c9, $03, $ca, $03, $cb, $03, $cc, $03, $cd, $03, $ce
    db $03, $e3, $03, $e5, $03, $e7, $03, $e9, $03, $eb, $03, $30, $04, $31, $04, $32
    db $04, $33, $04, $34, $04, $35, $04, $36, $04, $37, $04, $38, $04, $39, $04, $3a
    db $7f, $04, $3b, $04, $3c, $04, $3d, $04, $3e, $04, $3f, $04, $40, $04, $41, $04
    db $42, $04, $43, $04, $44, $04, $45, $04, $46, $04, $47, $04, $48, $04, $49, $04
    db $4a, $04, $4b, $04, $4c, $04, $4d, $04, $4e, $04, $4f, $04, $52, $04, $53, $04
    db $54, $04, $55, $04, $56, $04, $57, $04, $58, $04, $59, $04, $5a, $04, $5b, $04
    db $5c, $04, $5e, $04, $5f, $04, $61, $04, $63, $04, $65, $04, $67, $04, $69, $04
    db $6b, $04, $6d, $04, $6f, $04, $71, $04, $73, $04, $75, $04, $77, $04, $79, $04
    db $7b, $04, $7d, $04, $7f, $04, $81, $04, $91, $04, $93, $04, $95, $04, $97, $04
    db $99, $04, $9b, $04, $9d, $04, $9f, $04, $a1, $04, $a3, $04, $a5, $04, $a7, $04
    db $7f, $a9, $04, $ab, $04, $ad, $04, $af, $04, $b1, $04, $b3, $04, $b5, $04, $b7
    db $04, $b9, $04, $bb, $04, $bd, $04, $bf, $04, $c2, $04, $c4, $04, $c8, $04, $d1
    db $04, $d3, $04, $d5, $04, $d7, $04, $d9, $04, $db, $04, $dd, $04, $df, $04, $e1
    db $04, $e3, $04, $e5, $04, $e7, $04, $e9, $04, $eb, $04, $ed, $04, $ef, $04, $f1
    db $04, $f3, $04, $f5, $04, $f9, $04, $61, $05, $62, $05, $63, $05, $64, $05, $65
    db $05, $66, $05, $67, $05, $68, $05, $69, $05, $6a, $05, $6b, $05, $6c, $05, $6d
    db $05, $6e, $05, $6f, $05, $70, $05, $71, $05, $72, $05, $73, $05, $74, $05, $75
    db $05, $76, $05, $77, $05, $78, $05, $79, $05, $7a, $05, $7b, $05, $7c, $05, $7d
    db $7f, $05, $7e, $05, $7f, $05, $80, $05, $81, $05, $82, $05, $83, $05, $84, $05
    db $85, $05, $86, $05, $01, $1e, $03, $1e, $05, $1e, $07, $1e, $09, $1e, $0b, $1e
    db $0d, $1e, $0f, $1e, $11, $1e, $13, $1e, $15, $1e, $17, $1e, $19, $1e, $1b, $1e
    db $1d, $1e, $1f, $1e, $21, $1e, $23, $1e, $25, $1e, $27, $1e, $29, $1e, $2b, $1e
    db $2d, $1e, $2f, $1e, $31, $1e, $33, $1e, $35, $1e, $37, $1e, $39, $1e, $3b, $1e
    db $3d, $1e, $3f, $1e, $41, $1e, $43, $1e, $45, $1e, $47, $1e, $49, $1e, $4b, $1e
    db $4d, $1e, $4f, $1e, $51, $1e, $53, $1e, $55, $1e, $57, $1e, $59, $1e, $5b, $1e
    db $5d, $1e, $5f, $1e, $61, $1e, $63, $1e, $65, $1e, $67, $1e, $69, $1e, $6b, $1e
    db $7f, $6d, $1e, $6f, $1e, $71, $1e, $73, $1e, $75, $1e, $77, $1e, $79, $1e, $7b
    db $1e, $7d, $1e, $7f, $1e, $81, $1e, $83, $1e, $85, $1e, $87, $1e, $89, $1e, $8b
    db $1e, $8d, $1e, $8f, $1e, $91, $1e, $93, $1e, $95, $1e, $97, $1e, $99, $1e, $9b
    db $1e, $9d, $1e, $9f, $1e, $a1, $1e, $a3, $1e, $a5, $1e, $a7, $1e, $a9, $1e, $ab
    db $1e, $ad, $1e, $af, $1e, $b1, $1e, $b3, $1e, $b5, $1e, $b7, $1e, $b9, $1e, $bb
    db $1e, $bd, $1e, $bf, $1e, $c1, $1e, $c3, $1e, $c5, $1e, $c7, $1e, $c9, $1e, $cb
    db $1e, $cd, $1e, $cf, $1e, $d1, $1e, $d3, $1e, $d5, $1e, $d7, $1e, $d9, $1e, $db
    db $1e, $dd, $1e, $df, $1e, $e1, $1e, $e3, $1e, $e5, $1e, $e7, $1e, $e9, $1e, $eb
    db $63, $1e, $ed, $1e, $ef, $1e, $f1, $1e, $f3, $1e, $f5, $1e, $f7, $1e, $f9, $1e
    db $70, $21, $71, $21, $72, $21, $73, $21, $74, $21, $75, $21, $76, $21, $77, $21
    db $78, $21, $79, $21, $7a, $21, $7b, $21, $7c, $21, $7d, $21, $7e, $21, $7f, $21
    db $41, $ff, $42, $ff, $43, $ff, $44, $ff, $45, $ff, $46, $ff, $47, $ff, $48, $ff
    db $49, $ff, $4a, $ff, $4b, $ff, $4c, $ff, $4d, $ff, $4e, $ff, $4f, $ff, $50, $ff
    db $51, $ff, $52, $ff, $53, $ff, $54, $ff, $55, $ff, $56, $ff, $57, $ff, $58, $ff
    db $59, $ff, $5a, $ff, $00

    ld hl, wWToUpperVals
    call RleUnpack

    db $7f, $c0, $00, $c1, $00, $c2, $00, $c3, $00, $c4, $00, $c5, $00, $c6, $00, $c7
    db $00, $c8, $00, $c9, $00, $ca, $00, $cb, $00, $cc, $00, $cd, $00, $ce, $00, $cf
    db $00, $d0, $00, $d1, $00, $d2, $00, $d3, $00, $d4, $00, $d5, $00, $d6, $00, $d8
    db $00, $d9, $00, $da, $00, $db, $00, $dc, $00, $dd, $00, $de, $00, $78, $01, $00
    db $01, $02, $01, $04, $01, $06, $01, $08, $01, $0a, $01, $0c, $01, $0e, $01, $10
    db $01, $12, $01, $14, $01, $16, $01, $18, $01, $1a, $01, $1c, $01, $1e, $01, $20
    db $01, $22, $01, $24, $01, $26, $01, $28, $01, $2a, $01, $2c, $01, $2e, $01, $30
    db $01, $32, $01, $34, $01, $36, $01, $39, $01, $3b, $01, $3d, $01, $3f, $01, $41
    db $7f, $01, $43, $01, $45, $01, $47, $01, $4a, $01, $4c, $01, $4e, $01, $50, $01
    db $52, $01, $54, $01, $56, $01, $58, $01, $5a, $01, $5c, $01, $5e, $01, $60, $01
    db $62, $01, $64, $01, $66, $01, $68, $01, $6a, $01, $6c, $01, $6e, $01, $70, $01
    db $72, $01, $74, $01, $76, $01, $79, $01, $7b, $01, $7d, $01, $82, $01, $84, $01
    db $87, $01, $8b, $01, $91, $01, $98, $01, $a0, $01, $a2, $01, $a7, $01, $ac, $01
    db $af, $01, $b3, $01, $b5, $01, $b8, $01, $bc, $01, $c4, $01, $c7, $01, $ca, $01
    db $cd, $01, $cf, $01, $d1, $01, $d3, $01, $d5, $01, $d7, $01, $d9, $01, $db, $01
    db $8e, $01, $de, $01, $e0, $01, $e2, $01, $e4, $01, $e6, $01, $e8, $01, $ea, $01
    db $7f, $ec, $01, $ee, $01, $f1, $01, $f4, $01, $fa, $01, $fc, $01, $fe, $01, $00
    db $02, $02, $02, $04, $02, $06, $02, $08, $02, $0a, $02, $0c, $02, $0e, $02, $10
    db $02, $12, $02, $14, $02, $16, $02, $91, $03, $92, $03, $93, $03, $94, $03, $95
    db $03, $96, $03, $97, $03, $98, $03, $99, $03, $9a, $03, $9b, $03, $9c, $03, $9d
    db $03, $9e, $03, $9f, $03, $a0, $03, $a1, $03, $a3, $03, $a4, $03, $a5, $03, $a6
    db $03, $a7, $03, $a8, $03, $a9, $03, $aa, $03, $ab, $03, $8c, $03, $8e, $03, $8f
    db $03, $e2, $03, $e4, $03, $e6, $03, $e8, $03, $ea, $03, $10, $04, $11, $04, $12
    db $04, $13, $04, $14, $04, $15, $04, $16, $04, $17, $04, $18, $04, $19, $04, $1a
    db $7f, $04, $1b, $04, $1c, $04, $1d, $04, $1e, $04, $1f, $04, $20, $04, $21, $04
    db $22, $04, $23, $04, $24, $04, $25, $04, $26, $04, $27, $04, $28, $04, $29, $04
    db $2a, $04, $2b, $04, $2c, $04, $2d, $04, $2e, $04, $2f, $04, $02, $04, $03, $04
    db $04, $04, $05, $04, $06, $04, $07, $04, $08, $04, $09, $04, $0a, $04, $0b, $04
    db $0c, $04, $0e, $04, $0f, $04, $60, $04, $62, $04, $64, $04, $66, $04, $68, $04
    db $6a, $04, $6c, $04, $6e, $04, $70, $04, $72, $04, $74, $04, $76, $04, $78, $04
    db $7a, $04, $7c, $04, $7e, $04, $80, $04, $90, $04, $92, $04, $94, $04, $96, $04
    db $98, $04, $9a, $04, $9c, $04, $9e, $04, $a0, $04, $a2, $04, $a4, $04, $a6, $04
    db $7f, $a8, $04, $aa, $04, $ac, $04, $ae, $04, $b0, $04, $b2, $04, $b4, $04, $b6
    db $04, $b8, $04, $ba, $04, $bc, $04, $be, $04, $c1, $04, $c3, $04, $c7, $05, $d0
    db $04, $d2, $04, $d4, $04, $d6, $04, $d8, $04, $da, $04, $dc, $04, $de, $04, $e0
    db $04, $e2, $04, $e4, $04, $e6, $04, $e8, $04, $ea, $04, $ec, $04, $ee, $04, $f0
    db $04, $f2, $04, $f4, $04, $f8, $04, $31, $05, $32, $05, $33, $05, $34, $05, $35
    db $05, $36, $05, $37, $05, $38, $05, $39, $05, $3a, $05, $3b, $05, $3c, $05, $3d
    db $05, $3e, $05, $3f, $05, $40, $05, $41, $05, $42, $05, $43, $05, $44, $05, $45
    db $05, $46, $05, $47, $05, $48, $05, $49, $05, $4a, $05, $4b, $05, $4c, $05, $4d
    db $7f, $05, $4e, $05, $4f, $05, $50, $05, $51, $05, $52, $05, $53, $05, $54, $05
    db $55, $05, $56, $05, $00, $1e, $02, $1e, $04, $1e, $06, $1e, $08, $1e, $0a, $1e
    db $0c, $1e, $0e, $1e, $10, $1e, $12, $1e, $14, $1e, $16, $1e, $18, $1e, $1a, $1e
    db $1c, $1e, $1e, $1e, $20, $1e, $22, $1e, $24, $1e, $26, $1e, $28, $1e, $2a, $1e
    db $2c, $1e, $2e, $1e, $30, $1e, $32, $1e, $34, $1e, $36, $1e, $38, $1e, $3a, $1e
    db $3c, $1e, $3e, $1e, $40, $1e, $42, $1e, $44, $1e, $46, $1e, $48, $1e, $4a, $1e
    db $4c, $1e, $4e, $1e, $50, $1e, $52, $1e, $54, $1e, $56, $1e, $58, $1e, $5a, $1e
    db $5c, $1e, $5e, $1e, $60, $1e, $62, $1e, $64, $1e, $66, $1e, $68, $1e, $6a, $1e
    db $7f, $6c, $1e, $6e, $1e, $70, $1e, $72, $1e, $74, $1e, $76, $1e, $78, $1e, $7a
    db $1e, $7c, $1e, $7e, $1e, $80, $1e, $82, $1e, $84, $1e, $86, $1e, $88, $1e, $8a
    db $1e, $8c, $1e, $8e, $1e, $90, $1e, $92, $1e, $94, $1e, $96, $1e, $98, $1e, $9a
    db $1e, $9c, $1e, $9e, $1e, $a0, $1e, $a2, $1e, $a4, $1e, $a6, $1e, $a8, $1e, $aa
    db $1e, $ac, $1e, $ae, $1e, $b0, $1e, $b2, $1e, $b4, $1e, $b6, $1e, $b8, $1e, $ba
    db $1e, $bc, $1e, $be, $1e, $c0, $1e, $c2, $1e, $c4, $1e, $c6, $1e, $c8, $1e, $ca
    db $1e, $cc, $1e, $ce, $1e, $d0, $1e, $d2, $1e, $d4, $1e, $d6, $1e, $d8, $1e, $da
    db $1e, $dc, $1e, $de, $1e, $e0, $1e, $e2, $1e, $e4, $1e, $e6, $1e, $e8, $1e, $ea
    db $63, $1e, $ec, $1e, $ee, $1e, $f0, $1e, $f2, $1e, $f4, $1e, $f6, $1e, $f8, $1e
    db $60, $21, $61, $21, $62, $21, $63, $21, $64, $21, $65, $21, $66, $21, $67, $21
    db $68, $21, $69, $21, $6a, $21, $6b, $21, $6c, $21, $6d, $21, $6e, $21, $6f, $21
    db $21, $ff, $22, $ff, $23, $ff, $24, $ff, $25, $ff, $26, $ff, $27, $ff, $28, $ff
    db $29, $ff, $2a, $ff, $2b, $ff, $2c, $ff, $2d, $ff, $2e, $ff, $2f, $ff, $30, $ff
    db $31, $ff, $32, $ff, $33, $ff, $34, $ff, $35, $ff, $36, $ff, $37, $ff, $38, $ff
    db $39, $ff, $3a, $ff, $00

    ld hl, wFileSizeFmtLo
    call RleUnpack

    db $7f, $61, $00, $1a, $03, $e0, $00, $17, $03, $f8, $00, $07, $03, $ff, $00, $01
    db $00, $78, $01, $00, $01, $30, $01, $32, $01, $06, $01, $39, $01, $10, $01, $4a
    db $01, $2e, $01, $79, $01, $06, $01, $80, $01, $4d, $00, $43, $02, $81, $01, $82
    db $01, $82, $01, $84, $01, $84, $01, $86, $01, $87, $01, $87, $01, $89, $01, $8a
    db $01, $8b, $01, $8b, $01, $8d, $01, $8e, $01, $8f, $01, $90, $01, $91, $01, $91
    db $01, $93, $01, $94, $01, $f6, $01, $96, $01, $97, $01, $98, $01, $98, $01, $3d
    db $02, $9b, $01, $9c, $01, $9d, $01, $20, $02, $9f, $01, $a0, $01, $a0, $01, $a2
    db $01, $a2, $01, $a4, $01, $a4, $01, $a6, $01, $a7, $01, $a7, $01, $a9, $01, $aa
    db $7f, $01, $ab, $01, $ac, $01, $ac, $01, $ae, $01, $af, $01, $af, $01, $b1, $01
    db $b2, $01, $b3, $01, $b3, $01, $b5, $01, $b5, $01, $b7, $01, $b8, $01, $b8, $01
    db $ba, $01, $bb, $01, $bc, $01, $bc, $01, $be, $01, $f7, $01, $c0, $01, $c1, $01
    db $c2, $01, $c3, $01, $c4, $01, $c5, $01, $c4, $01, $c7, $01, $c8, $01, $c7, $01
    db $ca, $01, $cb, $01, $ca, $01, $cd, $01, $10, $01, $dd, $01, $01, $00, $8e, $01
    db $de, $01, $12, $01, $f3, $01, $03, $00, $f1, $01, $f4, $01, $f4, $01, $f8, $01
    db $28, $01, $22, $02, $12, $01, $3a, $02, $09, $00, $65, $2c, $3b, $02, $3b, $02
    db $3d, $02, $66, $2c, $3f, $02, $40, $02, $41, $02, $41, $02, $46, $02, $0a, $01
    db $7f, $53, $02, $40, $00, $81, $01, $86, $01, $55, $02, $89, $01, $8a, $01, $58
    db $02, $8f, $01, $5a, $02, $90, $01, $5c, $02, $5d, $02, $5e, $02, $5f, $02, $93
    db $01, $61, $02, $62, $02, $94, $01, $64, $02, $65, $02, $66, $02, $67, $02, $97
    db $01, $96, $01, $6a, $02, $62, $2c, $6c, $02, $6d, $02, $6e, $02, $9c, $01, $70
    db $02, $71, $02, $9d, $01, $73, $02, $74, $02, $9f, $01, $76, $02, $77, $02, $78
    db $02, $79, $02, $7a, $02, $7b, $02, $7c, $02, $64, $2c, $7e, $02, $7f, $02, $a6
    db $01, $81, $02, $82, $02, $a9, $01, $84, $02, $85, $02, $86, $02, $87, $02, $ae
    db $01, $44, $02, $b1, $01, $b2, $01, $45, $02, $8d, $02, $8e, $02, $8f, $02, $90
    db $75, $02, $91, $02, $b7, $01, $7b, $03, $03, $00, $fd, $03, $fe, $03, $ff, $03
    db $ac, $03, $04, $00, $86, $03, $88, $03, $89, $03, $8a, $03, $b1, $03, $11, $03
    db $c2, $03, $02, $00, $a3, $03, $a3, $03, $c4, $03, $08, $03, $cc, $03, $03, $00
    db $8c, $03, $8e, $03, $8f, $03, $d8, $03, $18, $01, $f2, $03, $0a, $00, $f9, $03
    db $f3, $03, $f4, $03, $f5, $03, $f6, $03, $f7, $03, $f7, $03, $f9, $03, $fa, $03
    db $fa, $03, $30, $04, $20, $03, $50, $04, $10, $07, $60, $04, $22, $01, $8a, $04
    db $36, $01, $c1, $04, $0e, $01, $cf, $04, $01, $00, $c0, $04, $d0, $04, $44, $01
    db $61, $05, $26, $04, $00, $00, $00

    ld hl, wFileSizeFmtHi
    call RleUnpack

    db $7f, $7d, $1d, $01, $00, $63, $2c, $00, $1e, $96, $01, $a0, $1e, $5a, $01, $00
    db $1f, $08, $06, $10, $1f, $06, $06, $20, $1f, $08, $06, $30, $1f, $08, $06, $40
    db $1f, $06, $06, $51, $1f, $07, $00, $59, $1f, $52, $1f, $5b, $1f, $54, $1f, $5d
    db $1f, $56, $1f, $5f, $1f, $60, $1f, $08, $06, $70, $1f, $0e, $00, $ba, $1f, $bb
    db $1f, $c8, $1f, $c9, $1f, $ca, $1f, $cb, $1f, $da, $1f, $db, $1f, $f8, $1f, $f9
    db $1f, $ea, $1f, $eb, $1f, $fa, $1f, $fb, $1f, $80, $1f, $08, $06, $90, $1f, $08
    db $06, $a0, $1f, $08, $06, $b0, $1f, $04, $00, $b8, $1f, $b9, $1f, $b2, $1f, $bc
    db $1f, $cc, $1f, $01, $00, $c3, $1f, $d0, $1f, $02, $06, $e0, $1f, $02, $06, $e5
    db $3d, $1f, $01, $00, $ec, $1f, $f3, $1f, $01, $00, $fc, $1f, $4e, $21, $01, $00
    db $32, $21, $70, $21, $10, $02, $84, $21, $01, $00, $83, $21, $d0, $24, $1a, $05
    db $30, $2c, $2f, $04, $60, $2c, $02, $01, $67, $2c, $06, $01, $75, $2c, $02, $01
    db $80, $2c, $64, $01, $00, $2d, $26, $08, $41, $ff, $1a, $03, $00, $00, $00

    ld hl, wDaysInMonth
    call RleUnpack

    db $0c, $1f, $1c, $1f, $1e, $1f, $1e, $1f, $1f, $1e, $1f, $1e, $1f, $00

    ld hl, wDaysInMonthLeap
    call RleUnpack

    db $0c, $1f, $1d, $1f, $1e, $1f, $1e, $1f, $1f, $1e, $1f, $1e, $1f, $00

    ld hl, wDaysInYearTab
    call RleUnpack

    db $08, $6d, $01, $6d, $01, $6d, $01, $6e, $01, $00

    ret


    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
