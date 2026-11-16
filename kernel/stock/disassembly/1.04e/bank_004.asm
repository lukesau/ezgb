; Disassembly of "kernel.gb"
; This file was created with:
; mgbdis v3.0 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $004", ROMX[$4000], BANK[$4]

; [ezgb]
; ROM load + soft-boot (kernel FPGA path only — not used by launched games).
; $7F36=$03: 512-byte load cmd window at $A000; build ROM in FPGA buffer.
; $7FE0=$80: reset into loaded ROM; same PSRAM chip, FPGA emulates game MBC.
; See docs/psram-map.md and docs/DEVELOPMENT.md.


RomLoad_InitiatePoll::
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
    ld bc, $7f36
    ld a, $03
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ld bc, $a000
    ld a, [bc]
    ld c, a
    or a
    jp z, $d11f

    ld hl, sp+$00
    ld [hl], $00
    inc hl
    ld [hl], $a0
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    ld c, b
    ld a, c
    sub $01
    jp z, $d128

    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7f36
    ld a, $00
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7f31
    ld a, $00
    ld [bc], a
    ld bc, $7f32
    ld a, $00
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ld bc, $2000
    ld a, $01
    ld [bc], a
    ld bc, $3000
    ld a, $00
    ld [bc], a
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a

RomLoad_SoftReset::
    ld bc, $7fe0
    ld a, $80
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    add sp, $02
    ret


; [ezgb]
; Source: kernel/stock/src/bank4.c
; RomLoad_Build_B4(dst@sp+$06, src@sp+$08, n@sp+$0a): memcpy n bytes src→dst (build helper).
; RomLoad_Build_B4_decN: while n--: *src++ (RomLoad_Build_B4_incSrc carry) → *dst++ (RomLoad_Build_B4_storeCont carry); RomLoad_Build_B4_epilogueRet add sp,$04 ret.
; Used to plant trampolines (e.g. RomLoad_BuildAndRunPoll → $D100). Bank8 twin RomLoad_Build_B8.

RomLoad_Build_B4::
    push af
    push af
    ld hl, sp+$08
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$00
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$06
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$02
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$0a
    ld c, [hl]

RomLoad_Build_B4_decN::
    ld b, c
    dec c
    xor a
    or b
    jp z, RomLoad_Build_B4_epilogueRet

    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    dec hl
    inc [hl]
    jr nz, RomLoad_Build_B4_incSrc

    inc hl
    inc [hl]

RomLoad_Build_B4_incSrc::
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, RomLoad_Build_B4_storeCont

    inc hl
    inc [hl]

RomLoad_Build_B4_storeCont::
    jp RomLoad_Build_B4_decN


RomLoad_Build_B4_epilogueRet::
    add sp, $04
    ret


; [ezgb]
; Source: kernel/stock/src/bank4.c
; RomLoad_BuildAndRunPoll: build InitiatePoll trampoline at $D100
; (arg $ff) via RomLoad_Build_B4, then call $D100.

RomLoad_BuildAndRunPoll::
    ld bc, RomLoad_InitiatePoll
    ld a, $ff
    push af
    inc sp
    push bc
    ld hl, $d100
    push hl
    call RomLoad_Build_B4
    add sp, $05
    call $d100
    ret


; [ezgb]
; Source: kernel/stock/src/bank4.c
; SetFpga7F34_35_B4: unlock $7F00/10/20; write stack u8s to $7F34 then
; $7F35; commit $7FF0. Scratch via push af / add sp,$02.

SetFpga7F34_35_B4::
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
    ld hl, sp+$08
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
    ld hl, sp+$09
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
; Source: kernel/stock/src/bank4.c
; SetRomLoadCtrl_B4: $7F36 load mode ($00=off, $01=map cmd buf, $03=initiate).

SetRomLoadCtrl_B4::
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7f36
    ld hl, sp+$02
    ld a, [hl]
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ret


; [ezgb]
; Source: kernel/stock/src/bank4.c
; SetFpga7F37_B4: unlock; write stack u8 to $7F37; commit. Sibling of
; SetRomLoadCtrl_B4 ($4140). Orphan after SetRomLoadCtrl_B4.

SetFpga7F37_B4::
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7f37
    ld hl, sp+$06
    ld a, [hl]
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ret


; [ezgb]
; Source: kernel/stock/src/bank4.c
; RomLoad_ResetIntoRom_B4: clear $7F31/$7F32; MBC writes $2000=$01/$3000=$00;
; then $7FE0=$80 soft-boot into loaded ROM (hangs via jp self if still here).
; Unlock $7F00/10/20=$e1/e2/e3 twice around setup; $7FF0=$e4 commit; RomLoad_ResetIntoRom_B4_hang hang.

RomLoad_ResetIntoRom_B4::
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7f31
    ld a, $00
    ld [bc], a
    ld bc, $7f32
    ld a, $00
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ld bc, $2000
    ld a, $01
    ld [bc], a
    ld bc, $3000
    ld a, $00
    ld [bc], a
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7fe0
    ld a, $80
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a

RomLoad_ResetIntoRom_B4_hang::
    jp RomLoad_ResetIntoRom_B4_hang


    ret


; [ezgb]
; Source: kernel/stock/src/bank4.c
; RomLoad_BuildAndRunReset_B4: RomLoad_Build_B4 trampoline for
; RomLoad_ResetIntoRom_B4 at $D000 (arg $ff), then call it.

RomLoad_BuildAndRunReset_B4::
    ld bc, RomLoad_ResetIntoRom_B4
    ld a, $ff
    push af
    inc sp
    push bc
    ld hl, $d000
    push hl
    call RomLoad_Build_B4
    add sp, $05
    call $d000
    ret


; [ezgb]
; Source: kernel/stock/src/bank4.c
; SetFpgaPageAlt_B4: byte-identical to SetFpgaPage_B4 (04:466e) — unlock,
; $7FC0=stack u8, commit. Earlier copy sitting just before SetFpgaRomSize_B4.

SetFpgaPageAlt_B4::
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
    ld hl, sp+$06
    ld a, [hl]
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ret


; [ezgb]
; Source: kernel/stock/src/bank4.c
; SetFpgaRomSize_B4(arg@sp+$0a): switch → 16-bit bank mask@sp+$02; clamp vs $c2a4/$c2a5; write FPGA $7FC1/$7FC2. Launch @$1604.
; Codes 0..8: SetFpgaRomSize_B4_mask0=0, SetFpgaRomSize_B4_mask03=$03, SetFpgaRomSize_B4_mask07=$07, SetFpgaRomSize_B4_mask0f=$0f, SetFpgaRomSize_B4_mask1f=$1f, SetFpgaRomSize_B4_mask3f=$3f, SetFpgaRomSize_B4_mask7f=$7f, SetFpgaRomSize_B4_mask00ff=$00ff, SetFpgaRomSize_B4_mask01ff=$01ff.
; $52..$54: SetFpgaRomSize_B4_mask47=$47, SetFpgaRomSize_B4_mask4f=$4f, SetFpgaRomSize_B4_mask5f=$5f; SetFpgaRomSize_B4_maskDefault0 default 0; join SetFpgaRomSize_B4_clampCaps clamp if mask>(caps-1).
; Clamp $c2a4 bits: SetFpgaRomSize_B4_clamp01=$01 / SetFpgaRomSize_B4_afterClamp01; SetFpgaRomSize_B4_clamp03=$03 / SetFpgaRomSize_B4_afterClamp03; SetFpgaRomSize_B4_clamp07=$07 / SetFpgaRomSize_B4_afterClamp07; SetFpgaRomSize_B4_clamp0f=$0f / SetFpgaRomSize_B4_afterClamp0f;
; SetFpgaRomSize_B4_clamp1f=$1f / SetFpgaRomSize_B4_afterClamp1f; SetFpgaRomSize_B4_clamp3f=$3f / SetFpgaRomSize_B4_afterClamp3f; SetFpgaRomSize_B4_clamp7f=$7f / SetFpgaRomSize_B4_afterClamp7f; SetFpgaRomSize_B4_clampFf=$ff / SetFpgaRomSize_B4_afterClampFf; SetFpgaRomSize_B4_clamp01ff $c2a5.0→$01ff; SetFpgaRomSize_B4_unlockWriteCommit unlock+write+commit.

SetFpgaRomSize_B4::
    push af
    push af
    ld hl, sp+$0a
    ld a, [hl]
    or a
    jp z, SetFpgaRomSize_B4_mask0

    ld hl, sp+$0a
    ld a, [hl]
    sub $01
    jp z, SetFpgaRomSize_B4_mask03

    ld hl, sp+$0a
    ld a, [hl]
    sub $02
    jp z, SetFpgaRomSize_B4_mask07

    ld hl, sp+$0a
    ld a, [hl]
    sub $03
    jp z, SetFpgaRomSize_B4_mask0f

    ld hl, sp+$0a
    ld a, [hl]
    sub $04
    jp z, SetFpgaRomSize_B4_mask1f

    ld hl, sp+$0a
    ld a, [hl]
    sub $05
    jp z, SetFpgaRomSize_B4_mask3f

    ld hl, sp+$0a
    ld a, [hl]
    sub $06
    jp z, SetFpgaRomSize_B4_mask7f

    ld hl, sp+$0a
    ld a, [hl]
    sub $07
    jp z, SetFpgaRomSize_B4_mask00ff

    ld hl, sp+$0a
    ld a, [hl]
    sub $08
    jp z, SetFpgaRomSize_B4_mask01ff

    ld hl, sp+$0a
    ld a, [hl]
    sub $52
    jp z, SetFpgaRomSize_B4_mask47

    ld hl, sp+$0a
    ld a, [hl]
    sub $53
    jp z, SetFpgaRomSize_B4_mask4f

    ld hl, sp+$0a
    ld a, [hl]
    sub $54
    jp z, SetFpgaRomSize_B4_mask5f

    jp SetFpgaRomSize_B4_maskDefault0


SetFpgaRomSize_B4_mask0::
    ld hl, sp+$02
    ld [hl], $00
    inc hl
    ld [hl], $00
    jp SetFpgaRomSize_B4_clampCaps


SetFpgaRomSize_B4_mask03::
    ld hl, sp+$02
    ld [hl], $03
    inc hl
    ld [hl], $00
    jp SetFpgaRomSize_B4_clampCaps


SetFpgaRomSize_B4_mask07::
    ld hl, sp+$02
    ld [hl], $07
    inc hl
    ld [hl], $00
    jp SetFpgaRomSize_B4_clampCaps


SetFpgaRomSize_B4_mask0f::
    ld hl, sp+$02
    ld [hl], $0f
    inc hl
    ld [hl], $00
    jp SetFpgaRomSize_B4_clampCaps


SetFpgaRomSize_B4_mask1f::
    ld hl, sp+$02
    ld [hl], $1f
    inc hl
    ld [hl], $00
    jp SetFpgaRomSize_B4_clampCaps


SetFpgaRomSize_B4_mask3f::
    ld hl, sp+$02
    ld [hl], $3f
    inc hl
    ld [hl], $00
    jp SetFpgaRomSize_B4_clampCaps


SetFpgaRomSize_B4_mask7f::
    ld hl, sp+$02
    ld [hl], $7f
    inc hl
    ld [hl], $00
    jp SetFpgaRomSize_B4_clampCaps


SetFpgaRomSize_B4_mask00ff::
    ld hl, sp+$02
    ld [hl], $ff
    inc hl
    ld [hl], $00
    jp SetFpgaRomSize_B4_clampCaps


SetFpgaRomSize_B4_mask01ff::
    ld hl, sp+$02
    ld [hl], $ff
    inc hl
    ld [hl], $01
    jp SetFpgaRomSize_B4_clampCaps


SetFpgaRomSize_B4_mask47::
    ld hl, sp+$02
    ld [hl], $47
    inc hl
    ld [hl], $00
    jp SetFpgaRomSize_B4_clampCaps


SetFpgaRomSize_B4_mask4f::
    ld hl, sp+$02
    ld [hl], $4f
    inc hl
    ld [hl], $00
    jp SetFpgaRomSize_B4_clampCaps


SetFpgaRomSize_B4_mask5f::
    ld hl, sp+$02
    ld [hl], $5f
    inc hl
    ld [hl], $00
    jp SetFpgaRomSize_B4_clampCaps


SetFpgaRomSize_B4_maskDefault0::
    ld hl, sp+$02
    ld [hl], $00
    inc hl
    ld [hl], $00

SetFpgaRomSize_B4_clampCaps::
    ld hl, $c2a4
    ld c, [hl]
    ld hl, $c2a5
    ld b, [hl]
    dec bc
    ld hl, sp+$02
    ld a, [hl]
    sub c
    inc hl
    ld a, [hl]
    sbc b
    jp nc, SetFpgaRomSize_B4_unlockWriteCommit

    ld hl, $c2a4
    ld a, [hl]
    and $01
    jr nz, SetFpgaRomSize_B4_clamp01

    jp SetFpgaRomSize_B4_afterClamp01


SetFpgaRomSize_B4_clamp01::
    ld hl, sp+$02
    ld [hl], $01
    inc hl
    ld [hl], $00

SetFpgaRomSize_B4_afterClamp01::
    ld hl, $c2a4
    ld a, [hl]
    and $02
    jr nz, SetFpgaRomSize_B4_clamp03

    jp SetFpgaRomSize_B4_afterClamp03


SetFpgaRomSize_B4_clamp03::
    ld hl, sp+$02
    ld [hl], $03
    inc hl
    ld [hl], $00

SetFpgaRomSize_B4_afterClamp03::
    ld hl, $c2a4
    ld a, [hl]
    and $04
    jr nz, SetFpgaRomSize_B4_clamp07

    jp SetFpgaRomSize_B4_afterClamp07


SetFpgaRomSize_B4_clamp07::
    ld hl, sp+$02
    ld [hl], $07
    inc hl
    ld [hl], $00

SetFpgaRomSize_B4_afterClamp07::
    ld hl, $c2a4
    ld a, [hl]
    and $08
    jr nz, SetFpgaRomSize_B4_clamp0f

    jp SetFpgaRomSize_B4_afterClamp0f


SetFpgaRomSize_B4_clamp0f::
    ld hl, sp+$02
    ld [hl], $0f
    inc hl
    ld [hl], $00

SetFpgaRomSize_B4_afterClamp0f::
    ld hl, $c2a4
    ld a, [hl]
    and $10
    jr nz, SetFpgaRomSize_B4_clamp1f

    jp SetFpgaRomSize_B4_afterClamp1f


SetFpgaRomSize_B4_clamp1f::
    ld hl, sp+$02
    ld [hl], $1f
    inc hl
    ld [hl], $00

SetFpgaRomSize_B4_afterClamp1f::
    ld hl, $c2a4
    ld a, [hl]
    and $20
    jr nz, SetFpgaRomSize_B4_clamp3f

    jp SetFpgaRomSize_B4_afterClamp3f


SetFpgaRomSize_B4_clamp3f::
    ld hl, sp+$02
    ld [hl], $3f
    inc hl
    ld [hl], $00

SetFpgaRomSize_B4_afterClamp3f::
    ld hl, $c2a4
    ld a, [hl]
    and $40
    jr nz, SetFpgaRomSize_B4_clamp7f

    jp SetFpgaRomSize_B4_afterClamp7f


SetFpgaRomSize_B4_clamp7f::
    ld hl, sp+$02
    ld [hl], $7f
    inc hl
    ld [hl], $00

SetFpgaRomSize_B4_afterClamp7f::
    ld hl, $c2a4
    ld a, [hl]
    and $80
    jr nz, SetFpgaRomSize_B4_clampFf

    jp SetFpgaRomSize_B4_afterClampFf


SetFpgaRomSize_B4_clampFf::
    ld hl, sp+$02
    ld [hl], $ff
    inc hl
    ld [hl], $00

SetFpgaRomSize_B4_afterClampFf::
    ld hl, $c2a5
    ld a, [hl]
    and $01
    jr nz, SetFpgaRomSize_B4_clamp01ff

    jp SetFpgaRomSize_B4_unlockWriteCommit


SetFpgaRomSize_B4_clamp01ff::
    ld hl, sp+$02
    ld [hl], $ff
    inc hl
    ld [hl], $01

SetFpgaRomSize_B4_unlockWriteCommit::
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7fc1
    ld hl, sp+$02
    ld a, [hl]
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    dec hl
    dec hl
    ld [hl], $c2
    inc hl
    ld [hl], $7f
    inc hl
    inc hl
    ld c, [hl]
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
    add sp, $04
    ret


; [ezgb]
; Source: kernel/stock/src/bank4.c
; SetFpga7FC4_B4(mode@sp+$07): map mode → lo nibble@sp+$00; unlock+write $7FC4; commit $7FF0=$e4.
; Dispatch: mode0 → SetFpga7FC4_B4_mode0; 1 or 2 → SetFpga7FC4_B4_store00b; 4 → SetFpga7FC4_B4_store0f; 5 → SetFpga7FC4_B4_store07; else SetFpga7FC4_B4_store03.
; SetFpga7FC4_B4_mode0: if $d3eb!=2 → SetFpga7FC4_B4_mode0SkipRtc → SetFpga7FC4_B4_store00a store $00; else SetFpga7FC4_B4_mode0Rtc store $00; both → SetFpga7FC4_B4_unlockWriteCommit.
; SetFpga7FC4_B4_store00b:$00; SetFpga7FC4_B4_store0f:$0f; SetFpga7FC4_B4_store07:$07; SetFpga7FC4_B4_store03:$03; fall SetFpga7FC4_B4_unlockWriteCommit: $7F00/10/20=$e1/e2/e3; [$7FC4]=nibble; $7FF0=$e4; ret.

SetFpga7FC4_B4::
    dec sp
    ld hl, sp+$07
    ld a, [hl]
    or a
    jp z, SetFpga7FC4_B4_mode0

    ld hl, sp+$07
    ld a, [hl]
    sub $01
    jp z, SetFpga7FC4_B4_store00b

    ld hl, sp+$07
    ld a, [hl]
    sub $02
    jp z, SetFpga7FC4_B4_store00b

    ld hl, sp+$07
    ld a, [hl]
    sub $04
    jp z, SetFpga7FC4_B4_store0f

    ld hl, sp+$07
    ld a, [hl]
    sub $05
    jp z, SetFpga7FC4_B4_store07

    jp SetFpga7FC4_B4_store03


SetFpga7FC4_B4_mode0::
    ld hl, $d3eb
    ld a, [hl]
    sub $02
    jp nz, SetFpga7FC4_B4_mode0SkipRtc

    jr SetFpga7FC4_B4_mode0Rtc

SetFpga7FC4_B4_mode0SkipRtc::
    jp SetFpga7FC4_B4_store00a


SetFpga7FC4_B4_mode0Rtc::
    ld hl, sp+$00
    ld [hl], $00
    jp SetFpga7FC4_B4_unlockWriteCommit


SetFpga7FC4_B4_store00a::
    ld hl, sp+$00
    ld [hl], $00
    jp SetFpga7FC4_B4_unlockWriteCommit


SetFpga7FC4_B4_store00b::
    ld hl, sp+$00
    ld [hl], $00
    jp SetFpga7FC4_B4_unlockWriteCommit


SetFpga7FC4_B4_store0f::
    ld hl, sp+$00
    ld [hl], $0f
    jp SetFpga7FC4_B4_unlockWriteCommit


SetFpga7FC4_B4_store07::
    ld hl, sp+$00
    ld [hl], $07
    jp SetFpga7FC4_B4_unlockWriteCommit


SetFpga7FC4_B4_store03::
    ld hl, sp+$00
    ld [hl], $03

SetFpga7FC4_B4_unlockWriteCommit::
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7fc4
    ld hl, sp+$00
    ld a, [hl]
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    add sp, $01
    ret


; [ezgb]
; Source: kernel/stock/src/bank4.c
; SetFpga7FC3_B4: unlock; write [$c5a3] to $7FC3; commit. Sibling of SetFpgaPage
; ($7FC0) / SetFpga7FC4_B4.

SetFpga7FC3_B4::
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7fc3
    ld hl, $c5a3
    ld a, [hl]
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ret


; [ezgb]
; Source: kernel/stock/src/bank4.c
; RomLoad_CopyCmdWindowPoll_B4: SetRomLoadCtrl_B4($01) map cmd window; copy $200
; bytes stack→$A000 via VramCopyStack; RomLoad_BuildAndRunPoll. Before CStrCat.

RomLoad_CopyCmdWindowPoll_B4::
    ld a, $01
    push af
    inc sp
    call SetRomLoadCtrl_B4
    add sp, $01
    ld hl, $0200
    push hl
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, $a000
    push hl
    call VramCopyStack
    add sp, $06
    call RomLoad_BuildAndRunPoll
    ret


; [ezgb]
; Source: kernel/stock/src/bank4.c
; CStrCat(dest, src): append NUL-term src onto dest. Frame -$04; stack RTL dest@sp+$06, src@sp+$08.
; CStrCat_findNul: walk BC=dest until [BC]==0 → CStrCat_stashPtrs stash src@sp+$00 + dest-end@sp+$02.
; CStrCat_copyLoop: load *src; if 0 → CStrCat_writeNul write NUL; else inc src (CStrCat_incSrc carry), store to *dest, inc dest (CStrCat_afterStore carry), loop.
; CStrCat_incSrc / CStrCat_afterStore: 16-bit pointer ++ after lo-byte wrap; CStrCat_writeNul: [dest]=0 + add sp,$04 ret.

CStrCat::
    push af
    push af
    ld hl, sp+$06
    ld c, [hl]
    inc hl
    ld b, [hl]

; [ezgb]
; Source: kernel/stock/src/bank4.c

CStrCat_findNul::
    ld a, [bc]
    or a
    jp z, CStrCat_stashPtrs

    inc bc
    jp CStrCat_findNul


; [ezgb]
; Source: kernel/stock/src/bank4.c

CStrCat_stashPtrs::
    ld hl, sp+$08
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    inc hl
    ld [hl], c
    inc hl
    ld [hl], b

; [ezgb]
; Source: kernel/stock/src/bank4.c

CStrCat_copyLoop::
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    or a
    jp z, CStrCat_writeNul

    ld a, c
    dec hl
    inc [hl]
    jr nz, CStrCat_incSrc

    inc hl
    inc [hl]

; [ezgb]
; Source: kernel/stock/src/bank4.c

CStrCat_incSrc::
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, CStrCat_afterStore

    inc hl
    inc [hl]

; [ezgb]
; Source: kernel/stock/src/bank4.c

CStrCat_afterStore::
    jp CStrCat_copyLoop


; [ezgb]
; Source: kernel/stock/src/bank4.c

CStrCat_writeNul::
    ld hl, sp+$02
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    add sp, $04
    ret


; [ezgb]
; Source: kernel/stock/src/bank4.c
; U32ToAscii(val@sp+$36, buf@sp+$3a, radix@sp+$3c): frame -$34; digit scratch@sp+$13. Bank0 twin U32ToAscii_B0.
; U32ToAscii_digitLoop: if val!=0 → U32ToAscii_emitDigit; elif scratch advanced → U32ToAscii_skipEmit → U32ToAscii_setupReverse; else U32ToAscii_emitDigit fall into emit.
; U32ToAscii_emitDigit/U32ToAscii_emitDigit: U32Div+U32Mod by radix; rem<$0a → '0'+n (U32ToAscii_digit0to9) else U32ToAscii_digitAtoF +$57 (U32ToAscii_afterAlpha) → U32ToAscii_digitLoop.
; U32ToAscii_setupReverse: setup reverse; U32ToAscii_copyLoop: copy scratch→buf (U32ToAscii_copyCont) until done → U32ToAscii_writeNul NUL; empty → plant "0"; U32ToAscii_epilogueRet epilogue.

U32ToAscii::
    add sp, -$34
    ld hl, sp+$13
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$0b
    ld [hl], c
    inc hl
    ld [hl], b
    ld hl, sp+$36
    ld d, h
    ld e, l
    ld hl, sp+$07
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

; [ezgb]
; Source: kernel/stock/src/bank4.c

U32ToAscii_digitLoop::
    ld hl, sp+$07
    ld a, [hl+]
    or [hl]
    inc hl
    or [hl]
    inc hl
    or [hl]
    jp nz, U32ToAscii_emitDigit

    inc hl
    ld a, [hl]
    ld hl, sp+$04
    sub [hl]
    jp nz, U32ToAscii_skipEmit

    ld hl, sp+$0c
    ld a, [hl]
    ld hl, sp+$05
    sub [hl]
    jp nz, U32ToAscii_skipEmit

    jr U32ToAscii_emitDigit

; [ezgb]
; Source: kernel/stock/src/bank4.c

U32ToAscii_skipEmit::
    jp U32ToAscii_setupReverse


; [ezgb]
; Source: kernel/stock/src/bank4.c

U32ToAscii_emitDigit::
    ld hl, sp+$3c
    ld a, [hl]
    ld hl, sp+$00
    ld [hl+], a
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
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Div
    add sp, $08
    push hl
    ld hl, sp+$11
    ld [hl], e
    inc hl
    ld [hl], d
    pop de
    inc hl
    ld [hl], e
    inc hl
    ld [hl], d
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$02
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$0d
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call U32Mod
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
    ld hl, sp+$07
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
    ld hl, sp+$0f
    ld a, [hl]
    sub $0a
    inc hl
    ld a, [hl]
    sbc $00
    inc hl
    ld a, [hl]
    sbc $00
    inc hl
    ld a, [hl]
    sbc $00
    jp nc, U32ToAscii_digitAtoF

    ld hl, sp+$0f
    ld c, [hl]
    ld a, c
    add $30
    ld hl, sp+$0b
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, U32ToAscii_digit0to9

    inc hl
    inc [hl]

; [ezgb]
; Source: kernel/stock/src/bank4.c

U32ToAscii_digit0to9::
    jp U32ToAscii_digitLoop


; [ezgb]
; Source: kernel/stock/src/bank4.c

U32ToAscii_digitAtoF::
    ld hl, sp+$0f
    ld c, [hl]
    ld a, c
    add $57
    ld hl, sp+$0b
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, U32ToAscii_afterAlpha

    inc hl
    inc [hl]

; [ezgb]
; Source: kernel/stock/src/bank4.c

U32ToAscii_afterAlpha::
    jp U32ToAscii_digitLoop


; [ezgb]
; Source: kernel/stock/src/bank4.c

U32ToAscii_setupReverse::
    ld hl, sp+$3a
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0d
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$04
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld hl, sp+$0b
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    ld hl, sp+$0d
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], e

; [ezgb]
; Source: kernel/stock/src/bank4.c

U32ToAscii_copyLoop::
    ld a, c
    ld hl, sp+$00
    sub [hl]
    ld a, b
    inc hl
    sbc [hl]
    rlca
    jp nc, U32ToAscii_writeNul

    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    dec de
    dec hl
    ld [hl], e
    inc hl
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    inc [hl]
    jr nz, U32ToAscii_copyCont

    inc hl
    inc [hl]

; [ezgb]
; Source: kernel/stock/src/bank4.c

U32ToAscii_copyCont::
    jp U32ToAscii_copyLoop


; [ezgb]
; Source: kernel/stock/src/bank4.c

U32ToAscii_writeNul::
    ld hl, sp+$04
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    ld hl, sp+$3a
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld a, [bc]
    or a
    jp nz, U32ToAscii_epilogueRet

    dec hl
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], e
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld hl, sp+$06
    ld [hl], c
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $30
    ld [de], a
    dec hl
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    ld hl, sp+$06
    ld a, [hl]
    ld [bc], a
    ld hl, sp+$00
    ld c, [hl]
    inc hl
    ld b, [hl]
    inc bc
    inc bc
    ld a, $00
    ld [bc], a

; [ezgb]
; Source: kernel/stock/src/bank4.c

U32ToAscii_epilogueRet::
    add sp, $34
    ret


; [ezgb]
; Source: kernel/stock/src/bank4.c
; SetFpgaPage_B4: bank-4 copy of SetFpgaPage (unlock $7F00/10/20, $7FC0=page,
; commit $7FF0). Byte-identical to SetFpgaPage_B0/B1; near-call only within bank.

SetFpgaPage_B4::
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
; Source: kernel/stock/src/bank4.c
; SetFpga7FD0_B4: same unlock/commit as SetFpgaPage but writes stack u8 to $7FD0.
; See stage0/docs/design.md for the $7Fxx register map.

SetFpga7FD0_B4::
    ld bc, $7f00
    ld a, $e1
    ld [bc], a
    ld bc, $7f10
    ld a, $e2
    ld [bc], a
    ld bc, $7f20
    ld a, $e3
    ld [bc], a
    ld bc, $7fd0
    ld hl, sp+$02
    ld a, [hl]
    ld [bc], a
    ld bc, $7ff0
    ld a, $e4
    ld [bc], a
    ret


; [ezgb]
; Source: kernel/stock/src/bank4.c
; InitTimeAutosaveFpga_B4: SetFpgaPage $06; write key bytes $33..$19 to $A008–$A00E;
; SetFpga7FD0_B4($01); page $00. Orphan immediately before DrawTimeAutosaveScreen.

InitTimeAutosaveFpga_B4::
    ld a, $06
    push af
    inc sp
    call SetFpgaPage_B4
    add sp, $01
    ld bc, $a008
    ld a, $33
    ld [bc], a
    ld bc, $a009
    ld a, $22
    ld [bc], a
    ld bc, $a00a
    ld a, $11
    ld [bc], a
    ld bc, $a00b
    ld a, $24
    ld [bc], a
    ld bc, $a00c
    ld a, $03
    ld [bc], a
    ld bc, $a00d
    ld a, $07
    ld [bc], a
    ld bc, $a00e
    ld a, $19
    ld [bc], a
    ld a, $01
    push af
    inc sp
    call SetFpga7FD0_B4
    add sp, $01
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B4
    add sp, $01
    ret


; [ezgb]
; Source: kernel/stock/src/bank4.c
; DrawTimeAutosaveScreen: sp+$3c=$A200; sp+$3d hilite; sp+$3e dirty; sp+$3f field 0..5; sp+$40 SET/SAV.
; Setup: sp+$3c!=1 → DrawTimeAutosaveScreen_setupSkipDrawRect; DrawTimeAutosaveScreen_setupDoDrawRect DrawRect; Jump_004_47ef field slot ptrs → DrawTimeAutosaveScreen_redraw.
; SET redraw DrawTimeAutosaveScreen_redraw: sp+$40≠0 → SAV DrawTimeAutosaveScreen_savRedraw; sp+$3e!=1 → DrawTimeAutosaveScreen_hiliteGate/DrawTimeAutosaveScreen_fpgaPage6; else DrawTimeAutosaveScreen_hilitePath hilite.
; Hilite: DrawTimeAutosaveScreen_hiliteStoreDrawParamsA/DrawTimeAutosaveScreen_hiliteStoreDrawParamsB StoreDrawParams; DrawTimeAutosaveScreen_setStringA/DrawTimeAutosaveScreen_setStringB/DrawTimeAutosaveScreen_setStringC/DrawTimeAutosaveScreen_setStringCPath/DrawTimeAutosaveScreen_setStringD/DrawTimeAutosaveScreen_setStringE SET strings; DrawTimeAutosaveScreen_setStringsDone/DrawTimeAutosaveScreen_setStringsDonePath → DrawTimeAutosaveScreen_fpgaPage6.
; FPGA DrawTimeAutosaveScreen_fpgaPage6: page6 $A008..$A00E → slots; DrawTimeAutosaveScreen_fpgaSlotGate/DrawTimeAutosaveScreen_fpgaSlotGate gate.
; Field clones: DrawTimeAutosaveScreen_field0Clone (+DrawTimeAutosaveScreen_field0LoadVal/DrawTimeAutosaveScreen_field0Next/DrawTimeAutosaveScreen_field0Next); DrawTimeAutosaveScreen_field1Clone (+DrawTimeAutosaveScreen_field1LoadVal/DrawTimeAutosaveScreen_field1Next/DrawTimeAutosaveScreen_field1Next); DrawTimeAutosaveScreen_field2Clone (+DrawTimeAutosaveScreen_field2LoadVal/DrawTimeAutosaveScreen_field2Next/DrawTimeAutosaveScreen_field2Next);
; DrawTimeAutosaveScreen_field3Clone (+DrawTimeAutosaveScreen_field3LoadVal/DrawTimeAutosaveScreen_field3Next/DrawTimeAutosaveScreen_field3Next); DrawTimeAutosaveScreen_field4Clone (+DrawTimeAutosaveScreen_field4LoadVal/DrawTimeAutosaveScreen_field4Next/DrawTimeAutosaveScreen_field4Next); DrawTimeAutosaveScreen_field5Clone; DrawTimeAutosaveScreen_clearDirtyMemcpy Memcpy → DrawTimeAutosaveScreen_inputLoop.
; SAV date clones (DrawTimeAutosaveScreen_savRedraw dirty): yr DrawTimeAutosaveScreen_savYearClone; mon DrawTimeAutosaveScreen_savMonGate/DrawTimeAutosaveScreen_savMonGatePath/DrawTimeAutosaveScreen_savMonClone; day DrawTimeAutosaveScreen_savDayGate/DrawTimeAutosaveScreen_savDayGatePath/DrawTimeAutosaveScreen_savDayClone;
; hr DrawTimeAutosaveScreen_savHrGate/DrawTimeAutosaveScreen_savHrGatePath/DrawTimeAutosaveScreen_savHrClone; min DrawTimeAutosaveScreen_savMinGate/DrawTimeAutosaveScreen_savMinGatePath/DrawTimeAutosaveScreen_savMinClone; sec DrawTimeAutosaveScreen_savSecGate/DrawTimeAutosaveScreen_savSecGatePath/DrawTimeAutosaveScreen_savSecClone → DrawTimeAutosaveScreen_inputLoop.
; Input DrawTimeAutosaveScreen_inputLoop: $02 DrawTimeAutosaveScreen_inputLoopFieldDec field-- (DrawTimeAutosaveScreen_fieldDecCheck/DrawTimeAutosaveScreen_fieldDecDirty/DrawTimeAutosaveScreen_fieldDecWrap wrap); $01 DrawTimeAutosaveScreen_fieldDecWrapFieldInc field++ (DrawTimeAutosaveScreen_fieldIncGate/DrawTimeAutosaveScreen_fieldIncGateWrap0/DrawTimeAutosaveScreen_fieldIncDirty/DrawTimeAutosaveScreen_fieldIncWrap).
; $04 bump DrawTimeAutosaveScreen_fieldIncWrapBump field0 yr (DrawTimeAutosaveScreen_field0YrGate/DrawTimeAutosaveScreen_field1MonCheck wrap $63/DrawTimeAutosaveScreen_field0YrWrap); DrawTimeAutosaveScreen_field1MonPath field1 mon (DrawTimeAutosaveScreen_field1MonGate/DrawTimeAutosaveScreen_field1MonGatePath/DrawTimeAutosaveScreen_field1MonPath/DrawTimeAutosaveScreen_field2DayCheck/DrawTimeAutosaveScreen_field1MonLoad).
; DrawTimeAutosaveScreen_field2DayCheck field2 day (DrawTimeAutosaveScreen_field2DayGate/DrawTimeAutosaveScreen_field2DayGatePath; DrawTimeAutosaveScreen_field2DayLoadA/DrawTimeAutosaveScreen_field2DayPath/DrawTimeAutosaveScreen_field2DayLoadC/DrawTimeAutosaveScreen_field2DayLoadB; DrawTimeAutosaveScreen_field2DayLoadC/DrawTimeAutosaveScreen_field2DayPath2/DrawTimeAutosaveScreen_field2DayU8Mod/DrawTimeAutosaveScreen_field2DayLoadD; DrawTimeAutosaveScreen_field2DayU8Mod U8Mod; DrawTimeAutosaveScreen_field2DayModCheck/DrawTimeAutosaveScreen_field2DayModGate/DrawTimeAutosaveScreen_field3HrCheck/DrawTimeAutosaveScreen_field3HrCheck/DrawTimeAutosaveScreen_field2DayModLoad) → DrawTimeAutosaveScreen_fieldBumpDirty.
; $04 fields 3..5: DrawTimeAutosaveScreen_field3HrPath hr (DrawTimeAutosaveScreen_field3HrGate/DrawTimeAutosaveScreen_field3HrGatePath/DrawTimeAutosaveScreen_field3HrPath/DrawTimeAutosaveScreen_field4MinCheck/DrawTimeAutosaveScreen_field3HrLoad); DrawTimeAutosaveScreen_field4MinPath min (DrawTimeAutosaveScreen_field4MinGate/DrawTimeAutosaveScreen_field4MinGatePath/DrawTimeAutosaveScreen_field4MinPath/DrawTimeAutosaveScreen_field5SecCheck/DrawTimeAutosaveScreen_field4MinLoad);
; DrawTimeAutosaveScreen_field5SecPath sec (DrawTimeAutosaveScreen_field5SecGate/DrawTimeAutosaveScreen_field5SecGatePath/DrawTimeAutosaveScreen_fieldBumpDirty/DrawTimeAutosaveScreen_field5SecJr/DrawTimeAutosaveScreen_field5SecLoad); join DrawTimeAutosaveScreen_fieldBumpDirty dirty; DrawTimeAutosaveScreen_hiliteDec SET hilite-- twin → DrawTimeAutosaveScreen_redraw.
; $08 dec DrawTimeAutosaveScreen_fieldDecBtn/DrawTimeAutosaveScreen_fieldDecBtnJr: field0 yr DrawTimeAutosaveScreen_field0YrDecLoad/Jump_004_5448/DrawTimeAutosaveScreen_field0YrDecSkip/DrawTimeAutosaveScreen_field0YrDecJr/DrawTimeAutosaveScreen_field0YrDecPath; field1 mon DrawTimeAutosaveScreen_field1MonDecCheck/DrawTimeAutosaveScreen_field1MonDecSkip/DrawTimeAutosaveScreen_field1MonDecSkipPath;
; field2 day DrawTimeAutosaveScreen_field2DayDecLoadA/DrawTimeAutosaveScreen_field2DayDecLoadB/DrawTimeAutosaveScreen_field2DayDecLoadC/DrawTimeAutosaveScreen_field2DayDecLoadD/DrawTimeAutosaveScreen_field2DayDecLoadE/DrawTimeAutosaveScreen_field2DayDecSkip/DrawTimeAutosaveScreen_field2DayDecSkipPath/DrawTimeAutosaveScreen_field2DayDecLoadF/DrawTimeAutosaveScreen_field2DayDecLoadG; field3 hr DrawTimeAutosaveScreen_field3HrDecCheck/DrawTimeAutosaveScreen_field3HrDecSkip/DrawTimeAutosaveScreen_field3HrDecSkipPath/DrawTimeAutosaveScreen_field3HrDecLoad;
; field4 min DrawTimeAutosaveScreen_field4MinDecCheck/DrawTimeAutosaveScreen_field4MinDecSkip/DrawTimeAutosaveScreen_field4MinDecSkipPath/DrawTimeAutosaveScreen_field4MinDecLoad; field5 sec DrawTimeAutosaveScreen_field5SecDecCheck/DrawTimeAutosaveScreen_field5SecDecSkip/DrawTimeAutosaveScreen_field5SecDecSkipPath/DrawTimeAutosaveScreen_field5SecDecLoad; DrawTimeAutosaveScreen_fieldDecJoinDirty dirty; DrawTimeAutosaveScreen_hiliteInc SET hilite++.
; Exit: DrawTimeAutosaveScreen_exitCheck40/DrawTimeAutosaveScreen_exitCheck40Epilogue/DrawTimeAutosaveScreen_exitCheck20/DrawTimeAutosaveScreen_exitCheck20Redraw/FlSetAHookSite; $10 DrawTimeAutosaveScreen_exitCheck10Confirm confirm DrawTimeAutosaveScreen_confirmBcdWrite BCD→$A008+$7FD0; $40 DrawTimeAutosaveScreen_toggleA200Check/DrawTimeAutosaveScreen_toggleA200Clear/DrawTimeAutosaveScreen_toggleA200Apply toggle $A200 → Jump_004_5903 ret.

DrawTimeAutosaveScreen::
    add sp, -$6a
    ld hl, sp+$3d
    ld [hl], $00
    ld hl, sp+$40
    ld [hl], $00
    dec hl
    ld [hl], $00
    dec hl
    ld [hl], $00
    ld bc, RomLoad_InitiatePoll
    ld a, $11
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call SetFpgaPage_B4
    add sp, $01
    ld bc, $a200
    ld a, [bc]
    ld c, a
    ld hl, sp+$3c
    ld [hl], c
    ld bc, RomLoad_InitiatePoll
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B4
    add sp, $01
    ld hl, $0000
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0107
    push hl
    ld hl, $9f00
    push hl
    ld a, $78
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
    ld hl, $0300
    push hl
    ld a, $05
    push af
    inc sp
    ld hl, TimeLabelStr
    push hl
    call DrawString
    add sp, $05
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0121
    push hl
    ld hl, $9b15
    push hl
    ld a, $7b
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, $0310
    push hl
    ld a, $03
    push af
    inc sp
    ld hl, TimeSetLabelStr
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
    ld hl, $0700
    push hl
    ld a, $0a
    push af
    inc sp
    ld hl, AutoSaveLabelStr
    push hl
    call DrawString
    add sp, $05
    ld hl, $0040
    push hl
    ld hl, $8a38
    push hl
    ld a, $82
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, sp+$3c
    ld a, [hl]
    sub $01
    jp nz, DrawTimeAutosaveScreen_setupSkipDrawRect

    jr DrawTimeAutosaveScreen_setupDoDrawRect

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_setupSkipDrawRect::
    jp Jump_004_47ef


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_setupDoDrawRect::
    ld hl, $0002
    push hl
    ld a, $02
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $013e
    push hl
    ld hl, $883a
    push hl
    ld a, $84
    push af
    inc sp
    call DrawRect
    add sp, $05

Jump_004_47ef:
    ld hl, sp+$5c
    ld c, l
    ld b, h
    ld hl, $0007
    push hl
    ld a, $ff
    push af
    inc sp
    push bc
    call Memset
    add sp, $05
    ld hl, sp+$5c
    ld a, l
    ld d, h
    ld hl, sp+$16
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$3a
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0005
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$38
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0003
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$36
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$34
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0001
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$32
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$55
    ld a, l
    ld d, h
    ld hl, sp+$30
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$2e
    ld [hl+], a
    ld [hl], d
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0005
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$2c
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$30
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0003
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$2a
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$30
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$28
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$30
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0001
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$26
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$63
    ld a, l
    ld d, h
    ld hl, sp+$24
    ld [hl+], a
    ld [hl], d
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0006
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$22
    ld [hl+], a
    ld [hl], d
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0005
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$20
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0003
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$1e
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0002
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$1c
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0001
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$1a
    ld [hl+], a
    ld [hl], d

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_redraw::
    call WaitVBlankFlag
    ld hl, sp+$3e
    ld a, [hl]
    sub $01
    jp nz, DrawTimeAutosaveScreen_hiliteGate

    jr DrawTimeAutosaveScreen_hilitePath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_hiliteGate::
    jp Jump_004_49ea


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_hilitePath::
    xor a
    ld hl, sp+$3d
    or [hl]
    jp nz, DrawTimeAutosaveScreen_hiliteStoreDrawParamsA

    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    jp DrawTimeAutosaveScreen_hiliteStoreDrawParamsB


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_hiliteStoreDrawParamsA::
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_hiliteStoreDrawParamsB::
    ld hl, $0121
    push hl
    ld hl, $9b15
    push hl
    ld a, $7b
    push af
    inc sp
    call DrawRect
    add sp, $05
    xor a
    ld hl, sp+$40
    or [hl]
    jp nz, DrawTimeAutosaveScreen_setStringA

    ld hl, $0310
    push hl
    ld a, $03
    push af
    inc sp
    ld hl, TimeSetLabelStr
    push hl
    call DrawString
    add sp, $05
    jp DrawTimeAutosaveScreen_setStringB


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_setStringA::
    ld hl, $0310
    push hl
    ld a, $03
    push af
    inc sp
    ld hl, AutoSaveSavLabelStr
    push hl
    call DrawString
    add sp, $05

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_setStringB::
    ld hl, $0000
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0140
    push hl
    ld hl, $8a38
    push hl
    ld a, $82
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, sp+$3d
    ld a, [hl]
    sub $01
    jp nz, DrawTimeAutosaveScreen_setStringC

    jr DrawTimeAutosaveScreen_setStringCPath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_setStringC::
    jp DrawTimeAutosaveScreen_setStringD


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_setStringCPath::
    ld hl, $0002
    push hl
    ld a, $02
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    jp DrawTimeAutosaveScreen_setStringE


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_setStringD::
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_setStringE::
    ld hl, $0040
    push hl
    ld hl, $8a38
    push hl
    ld a, $82
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, sp+$3c
    ld a, [hl]
    sub $01
    jp nz, DrawTimeAutosaveScreen_setStringsDone

    jr DrawTimeAutosaveScreen_setStringsDonePath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_setStringsDone::
    jp Jump_004_49ea


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_setStringsDonePath::
    ld hl, $0002
    push hl
    ld a, $02
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $013e
    push hl
    ld hl, $883a
    push hl
    ld a, $84
    push af
    inc sp
    call DrawRect
    add sp, $05

Jump_004_49ea:
    xor a
    ld hl, sp+$40
    or [hl]
    jp nz, DrawTimeAutosaveScreen_savRedraw

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_fpgaPage6::
    ld a, $06
    push af
    inc sp
    call SetFpgaPage_B4
    add sp, $01
    ld hl, sp+$24
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$18
    ld [hl+], a
    ld [hl], e
    ld bc, $a008
    ld a, [bc]
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$1a
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$14
    ld [hl+], a
    ld [hl], e
    ld bc, $a009
    ld a, [bc]
    ld hl, sp+$1a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    inc hl
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$12
    ld [hl+], a
    ld [hl], e
    ld bc, $a00a
    ld a, [bc]
    ld hl, sp+$1c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    inc hl
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$10
    ld [hl+], a
    ld [hl], e
    ld bc, $a00b
    ld a, [bc]
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld hl, $0004
    add hl, de
    ld a, l
    ld d, h
    ld hl, sp+$0e
    ld [hl+], a
    ld [hl], d
    ld bc, $a00c
    ld a, [bc]
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$20
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0e
    ld [hl+], a
    ld [hl], e
    ld bc, $a00d
    ld a, [bc]
    ld hl, sp+$20
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    inc hl
    ld a, [hl+]
    ld e, [hl]
    ld hl, sp+$0c
    ld [hl+], a
    ld [hl], e
    ld bc, $a00e
    ld a, [bc]
    ld hl, sp+$22
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B4
    add sp, $01
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, sp+$22
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld hl, sp+$3a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    ld a, c
    sub b
    jp nz, DrawTimeAutosaveScreen_fpgaSlotGate

    jr DrawTimeAutosaveScreen_fpgaSlotGatePath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_fpgaSlotGate::
    jp DrawTimeAutosaveScreen_field0Clone


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_fpgaSlotGatePath::
    xor a
    ld hl, sp+$3e
    or [hl]
    jp z, DrawTimeAutosaveScreen_field0LoadVal

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field0Clone::
    ld hl, sp+$41
    ld a, l
    ld d, h
    ld hl, sp+$0a
    ld [hl+], a
    ld [hl], d
    inc hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $0f
    ld b, a
    ld hl, sp+$08
    ld [hl], b
    inc hl
    ld [hl], $00
    sra c
    sra c
    sra c
    sra c
    ld e, c
    ld a, e
    rlc a
    sbc a
    ld d, a
    ld l, e
    ld h, d
    add hl, hl
    add hl, hl
    add hl, de
    add hl, hl
    ld c, l
    ld b, h
    ld hl, sp+$08
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
    ld hl, sp+$0b
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
    call U32ToAscii
    add sp, $07
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, PathSlashStr_B4
    push hl
    push bc
    call CStrCat
    add sp, $04
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, $0500
    push hl
    ld a, $05
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field0LoadVal::
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld hl, sp+$38
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    ld a, c
    sub b
    jp nz, DrawTimeAutosaveScreen_field0Next

    jr DrawTimeAutosaveScreen_field0NextPath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field0Next::
    jp DrawTimeAutosaveScreen_field1Clone


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field0NextPath::
    xor a
    ld hl, sp+$3e
    or [hl]
    jp z, DrawTimeAutosaveScreen_field1LoadVal

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field1Clone::
    ld hl, sp+$41
    ld a, l
    ld d, h
    ld hl, sp+$04
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$0e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $0f
    ld b, a
    ld hl, sp+$0a
    ld [hl], b
    inc hl
    ld [hl], $00
    ld a, c
    and $1f
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
    ld hl, sp+$0a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
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
    ld a, $0a
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
    call U32ToAscii
    add sp, $07
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, $0505
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05
    ld hl, $0507
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, PathSlashStr_B4
    push hl
    call DrawString
    add sp, $05

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field1LoadVal::
    ld hl, sp+$10
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld hl, sp+$36
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    ld a, c
    sub b
    jp nz, DrawTimeAutosaveScreen_field1Next

    jr DrawTimeAutosaveScreen_field1NextPath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field1Next::
    jp DrawTimeAutosaveScreen_field2Clone


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field1NextPath::
    xor a
    ld hl, sp+$3e
    or [hl]
    jp z, DrawTimeAutosaveScreen_field2LoadVal

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2Clone::
    ld hl, sp+$41
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$10
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $0f
    ld b, a
    ld hl, sp+$08
    ld [hl], b
    inc hl
    ld [hl], $00
    ld a, c
    and $3f
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
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
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
    ld hl, sp+$01
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
    call U32ToAscii
    add sp, $07
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, $0508
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2LoadVal::
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld hl, sp+$34
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    ld a, c
    sub b
    jp nz, DrawTimeAutosaveScreen_field2Next

    jr DrawTimeAutosaveScreen_field2NextPath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2Next::
    jp DrawTimeAutosaveScreen_field3Clone


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2NextPath::
    xor a
    ld hl, sp+$3e
    or [hl]
    jp z, DrawTimeAutosaveScreen_field3LoadVal

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field3Clone::
    ld hl, sp+$41
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$12
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $0f
    ld b, a
    ld hl, sp+$08
    ld [hl], b
    inc hl
    ld [hl], $00
    ld a, c
    and $3f
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
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
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
    ld hl, sp+$01
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
    call U32ToAscii
    add sp, $07
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, $050b
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05
    ld hl, $050d
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, $5921
    push hl
    call DrawString
    add sp, $05

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field3LoadVal::
    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld hl, sp+$32
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    ld a, c
    sub b
    jp nz, DrawTimeAutosaveScreen_field3Next

    jr DrawTimeAutosaveScreen_field3NextPath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field3Next::
    jp DrawTimeAutosaveScreen_field4Clone


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field3NextPath::
    xor a
    ld hl, sp+$3e
    or [hl]
    jp z, DrawTimeAutosaveScreen_field4LoadVal

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field4Clone::
    ld hl, sp+$41
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$14
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $0f
    ld b, a
    ld hl, sp+$08
    ld [hl], b
    inc hl
    ld [hl], $00
    ld a, c
    and $7f
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
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
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
    ld hl, sp+$01
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
    call U32ToAscii
    add sp, $07
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, $050e
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05
    ld hl, $0510
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, $5921
    push hl
    call DrawString
    add sp, $05

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field4LoadVal::
    ld hl, sp+$18
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld hl, sp+$16
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    ld a, c
    sub b
    jp nz, DrawTimeAutosaveScreen_field4Next

    jr DrawTimeAutosaveScreen_field4NextPath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field4Next::
    jp DrawTimeAutosaveScreen_field5Clone


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field4NextPath::
    xor a
    ld hl, sp+$3e
    or [hl]
    jp z, DrawTimeAutosaveScreen_clearDirtyMemcpy

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field5Clone::
    ld hl, sp+$41
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$18
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $0f
    ld b, a
    ld hl, sp+$08
    ld [hl], b
    inc hl
    ld [hl], $00
    ld a, c
    and $7f
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
    ld hl, sp+$08
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
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
    ld hl, sp+$01
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
    call U32ToAscii
    add sp, $07
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, $0511
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_clearDirtyMemcpy::
    ld hl, sp+$3e
    ld [hl], $00
    ld hl, $0007
    push hl
    ld hl, sp+$1a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    ld hl, sp+$1a
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    call Memcpy
    add sp, $06
    jp DrawTimeAutosaveScreen_inputLoop


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_savRedraw::
    xor a
    ld hl, sp+$3e
    or [hl]
    jp z, DrawTimeAutosaveScreen_inputLoop

    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, sp+$41
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$2e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    rla
    sbc a
    ld b, a
    ld hl, $07d0
    add hl, bc
    ld c, l
    ld b, h
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
    ld hl, sp+$01
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
    call U32ToAscii
    add sp, $07
    xor a
    ld hl, sp+$3f
    or [hl]
    jp nz, DrawTimeAutosaveScreen_savYearClone

    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_savYearClone::
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, $0500
    push hl
    ld a, $04
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0504
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, PathSlashStr_B4
    push hl
    call DrawString
    add sp, $05
    ld hl, sp+$41
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$2c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    and $1f
    ld c, a
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld a, $0a
    push af
    inc sp
    ld hl, sp+$01
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
    call U32ToAscii
    add sp, $07
    ld hl, sp+$3f
    ld a, [hl]
    sub $01
    jp nz, DrawTimeAutosaveScreen_savMonGate

    jr DrawTimeAutosaveScreen_savMonGatePath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_savMonGate::
    jp DrawTimeAutosaveScreen_savMonClone


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_savMonGatePath::
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_savMonClone::
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, $0505
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0507
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, PathSlashStr_B4
    push hl
    call DrawString
    add sp, $05
    ld hl, sp+$41
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    and $3f
    ld c, a
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld a, $0a
    push af
    inc sp
    ld hl, sp+$01
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
    call U32ToAscii
    add sp, $07
    ld hl, sp+$3f
    ld a, [hl]
    sub $02
    jp nz, DrawTimeAutosaveScreen_savDayGate

    jr DrawTimeAutosaveScreen_savDayGatePath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_savDayGate::
    jp DrawTimeAutosaveScreen_savDayClone


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_savDayGatePath::
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_savDayClone::
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, $0508
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, sp+$41
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$28
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    and $3f
    ld c, a
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld a, $0a
    push af
    inc sp
    ld hl, sp+$01
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
    call U32ToAscii
    add sp, $07
    ld hl, sp+$3f
    ld a, [hl]
    sub $03
    jp nz, DrawTimeAutosaveScreen_savHrGate

    jr DrawTimeAutosaveScreen_savHrGatePath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_savHrGate::
    jp DrawTimeAutosaveScreen_savHrClone


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_savHrGatePath::
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_savHrClone::
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, $050b
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $050d
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, $5921
    push hl
    call DrawString
    add sp, $05
    ld hl, sp+$41
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$26
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    and $7f
    ld c, a
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld a, $0a
    push af
    inc sp
    ld hl, sp+$01
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
    call U32ToAscii
    add sp, $07
    ld hl, sp+$3f
    ld a, [hl]
    sub $04
    jp nz, DrawTimeAutosaveScreen_savMinGate

    jr DrawTimeAutosaveScreen_savMinGatePath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_savMinGate::
    jp DrawTimeAutosaveScreen_savMinClone


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_savMinGatePath::
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_savMinClone::
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, $050e
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0510
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, $5921
    push hl
    call DrawString
    add sp, $05
    ld hl, sp+$41
    ld a, l
    ld d, h
    ld hl, sp+$00
    ld [hl+], a
    ld [hl], d
    ld hl, sp+$30
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    and $7f
    ld c, a
    ld hl, sp+$04
    ld [hl], c
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    inc hl
    ld [hl], $00
    ld a, $0a
    push af
    inc sp
    ld hl, sp+$01
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
    call U32ToAscii
    add sp, $07
    ld hl, sp+$3f
    ld a, [hl]
    sub $05
    jp nz, DrawTimeAutosaveScreen_savSecGate

    jr DrawTimeAutosaveScreen_savSecGatePath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_savSecGate::
    jp DrawTimeAutosaveScreen_savSecClone


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_savSecGatePath::
    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_savSecClone::
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, $0511
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call DrawString
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, sp+$3e
    ld [hl], $00

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_inputLoop::
    call ReadJoypad
    ld c, e
    ld b, $00
    ld a, c
    and $02
    jr nz, DrawTimeAutosaveScreen_inputLoopFieldDec

    jp DrawTimeAutosaveScreen_fieldDecWrap


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_inputLoopFieldDec::
    xor a
    ld hl, sp+$40
    or [hl]
    jp z, DrawTimeAutosaveScreen_redraw

    xor a
    ld hl, sp+$3d
    or [hl]
    jp nz, DrawTimeAutosaveScreen_redraw

    xor a
    inc hl
    inc hl
    or [hl]
    jp z, DrawTimeAutosaveScreen_fieldDecCheck

    dec [hl]
    jp DrawTimeAutosaveScreen_fieldDecDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_fieldDecCheck::
    xor a
    ld hl, sp+$3f
    or [hl]
    jp nz, DrawTimeAutosaveScreen_fieldDecDirty

    ld [hl], $05

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_fieldDecDirty::
    ld hl, sp+$3e
    ld [hl], $02
    jp DrawTimeAutosaveScreen_redraw


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_fieldDecWrap::
    ld a, c
    and $01
    jr nz, DrawTimeAutosaveScreen_fieldDecWrapFieldInc

    jp DrawTimeAutosaveScreen_fieldIncWrap


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_fieldDecWrapFieldInc::
    xor a
    ld hl, sp+$40
    or [hl]
    jp z, DrawTimeAutosaveScreen_redraw

    xor a
    ld hl, sp+$3d
    or [hl]
    jp nz, DrawTimeAutosaveScreen_redraw

    inc hl
    inc hl
    inc [hl]
    ld a, [hl]
    sub $06
    jp nz, DrawTimeAutosaveScreen_fieldIncGate

    jr DrawTimeAutosaveScreen_fieldIncGateWrap0

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_fieldIncGate::
    jp DrawTimeAutosaveScreen_fieldIncDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_fieldIncGateWrap0::
    ld hl, sp+$3f
    ld [hl], $00

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_fieldIncDirty::
    ld hl, sp+$3e
    ld [hl], $03
    jp DrawTimeAutosaveScreen_redraw


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_fieldIncWrap::
    ld a, c
    and $04
    jr nz, DrawTimeAutosaveScreen_fieldIncWrapBump

    jp DrawTimeAutosaveScreen_fieldDecBtn


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_fieldIncWrapBump::
    xor a
    ld hl, sp+$40
    or [hl]
    jp z, DrawTimeAutosaveScreen_hiliteDec

    xor a
    ld hl, sp+$3d
    or [hl]
    jp nz, DrawTimeAutosaveScreen_redraw

    xor a
    inc hl
    inc hl
    or [hl]
    jp nz, DrawTimeAutosaveScreen_field1MonCheck

    ld hl, sp+$2e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $63
    jp nz, DrawTimeAutosaveScreen_field0YrGate

    jr DrawTimeAutosaveScreen_field0YrGateZero

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field0YrGate::
    jp DrawTimeAutosaveScreen_field0YrWrap


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field0YrGateZero::
    ld hl, sp+$2e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field0YrWrap::
    ld hl, sp+$2e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field1MonCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $01
    jp nz, DrawTimeAutosaveScreen_field1MonGate

    jr DrawTimeAutosaveScreen_field1MonGatePath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field1MonGate::
    jp DrawTimeAutosaveScreen_field2DayCheck


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field1MonGatePath::
    ld hl, sp+$2c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $0c
    jp nz, DrawTimeAutosaveScreen_field1MonPath

    jr DrawTimeAutosaveScreen_field1MonPathZero

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field1MonPath::
    jp DrawTimeAutosaveScreen_field1MonLoad


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field1MonPathZero::
    ld hl, sp+$2c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field1MonLoad::
    ld hl, sp+$2c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $02
    jp nz, DrawTimeAutosaveScreen_field2DayGate

    jr DrawTimeAutosaveScreen_field2DayGatePath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayGate::
    jp DrawTimeAutosaveScreen_field3HrCheck


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayGatePath::
    ld hl, sp+$2c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $01
    rlca
    jp c, DrawTimeAutosaveScreen_fieldBumpDirty

    ld a, $0c
    sub c
    rlca
    jp c, DrawTimeAutosaveScreen_fieldBumpDirty

    dec c
    ld e, c
    ld d, $00
    ld hl, $525b
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp DrawTimeAutosaveScreen_field2DayLoadA


    jp DrawTimeAutosaveScreen_field2DayU8Mod


    jp DrawTimeAutosaveScreen_field2DayLoadA


    jp DrawTimeAutosaveScreen_field2DayLoadC


    jp DrawTimeAutosaveScreen_field2DayLoadA


    jp DrawTimeAutosaveScreen_field2DayLoadC


    jp DrawTimeAutosaveScreen_field2DayLoadA


    jp DrawTimeAutosaveScreen_field2DayLoadA


    jp DrawTimeAutosaveScreen_field2DayLoadC


    jp DrawTimeAutosaveScreen_field2DayLoadA


    jp DrawTimeAutosaveScreen_field2DayLoadC


    jp DrawTimeAutosaveScreen_field2DayLoadA


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayLoadA::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $1f
    jp nz, DrawTimeAutosaveScreen_field2DayPath

    jr DrawTimeAutosaveScreen_field2DayPathZero

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayPath::
    jp DrawTimeAutosaveScreen_field2DayLoadB


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayPathZero::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayLoadB::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayLoadC::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $1e
    jp nz, DrawTimeAutosaveScreen_field2DayPath2

    jr DrawTimeAutosaveScreen_field2DayPath2Zero

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayPath2::
    jp DrawTimeAutosaveScreen_field2DayLoadD


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayPath2Zero::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayLoadD::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayU8Mod::
    ld hl, sp+$2e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld a, $04
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call U8Mod
    add sp, $02
    ld c, e
    xor a
    or c
    jp nz, DrawTimeAutosaveScreen_field2DayModCheck

    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld b, a
    sub $1d
    jp z, DrawTimeAutosaveScreen_field2DayModPath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayModCheck::
    ld a, $00
    sub c
    rlca
    jp nc, DrawTimeAutosaveScreen_field2DayModLoad

    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $1c
    jp nz, DrawTimeAutosaveScreen_field2DayModGate

    jr DrawTimeAutosaveScreen_field2DayModPath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayModGate::
    jp DrawTimeAutosaveScreen_field2DayModLoad


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayModPath::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayModLoad::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field3HrCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $03
    jp nz, DrawTimeAutosaveScreen_field3HrGate

    jr DrawTimeAutosaveScreen_field3HrGatePath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field3HrGate::
    jp DrawTimeAutosaveScreen_field4MinCheck


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field3HrGatePath::
    ld hl, sp+$28
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $17
    jp nz, DrawTimeAutosaveScreen_field3HrPath

    jr DrawTimeAutosaveScreen_field3HrPathZero

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field3HrPath::
    jp DrawTimeAutosaveScreen_field3HrLoad


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field3HrPathZero::
    ld hl, sp+$28
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field3HrLoad::
    ld hl, sp+$28
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field4MinCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $04
    jp nz, DrawTimeAutosaveScreen_field4MinGate

    jr DrawTimeAutosaveScreen_field4MinGatePath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field4MinGate::
    jp DrawTimeAutosaveScreen_field5SecCheck


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field4MinGatePath::
    ld hl, sp+$26
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $3b
    jp nz, DrawTimeAutosaveScreen_field4MinPath

    jr DrawTimeAutosaveScreen_field4MinPathZero

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field4MinPath::
    jp DrawTimeAutosaveScreen_field4MinLoad


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field4MinPathZero::
    ld hl, sp+$26
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field4MinLoad::
    ld hl, sp+$26
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field5SecCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $05
    jp nz, DrawTimeAutosaveScreen_field5SecGate

    jr DrawTimeAutosaveScreen_field5SecGatePath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field5SecGate::
    jp DrawTimeAutosaveScreen_fieldBumpDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field5SecGatePath::
    ld hl, sp+$30
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $3b
    jp nz, DrawTimeAutosaveScreen_field5SecPath

    jr DrawTimeAutosaveScreen_field5SecJr

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field5SecPath::
    jp DrawTimeAutosaveScreen_field5SecLoad


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field5SecJr::
    ld hl, sp+$30
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field5SecLoad::
    ld hl, sp+$30
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    inc a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_fieldBumpDirty::
    ld hl, sp+$3e
    ld [hl], $01
    jp DrawTimeAutosaveScreen_redraw


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_hiliteDec::
    xor a
    ld hl, sp+$3d
    or [hl]
    jp z, DrawTimeAutosaveScreen_redraw

    dec [hl]
    inc hl
    ld [hl], $01
    jp DrawTimeAutosaveScreen_redraw


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_fieldDecBtn::
    ld a, c
    and $08
    jr nz, DrawTimeAutosaveScreen_fieldDecBtnJr

    jp DrawTimeAutosaveScreen_exitCheck40


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_fieldDecBtnJr::
    xor a
    ld hl, sp+$40
    or [hl]
    jp z, DrawTimeAutosaveScreen_hiliteInc

    xor a
    ld hl, sp+$3d
    or [hl]
    jp nz, DrawTimeAutosaveScreen_redraw

    xor a
    inc hl
    inc hl
    or [hl]
    jp nz, DrawTimeAutosaveScreen_field0YrDecCheck

    ld hl, sp+$2e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    or a
    jp nz, DrawTimeAutosaveScreen_field0YrDecLoad

    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $63
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field0YrDecLoad::
    ld hl, sp+$2e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    dec a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field0YrDecCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $01
    jp nz, DrawTimeAutosaveScreen_field0YrDecSkip

    jr DrawTimeAutosaveScreen_field0YrDecJr

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field0YrDecSkip::
    jp DrawTimeAutosaveScreen_field1MonDecCheck


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field0YrDecJr::
    ld hl, sp+$2c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $01
    jp nz, Jump_004_5448

    jr jr_004_544b

Jump_004_5448:
    jp DrawTimeAutosaveScreen_field0YrDecPath


jr_004_544b:
    ld hl, sp+$2c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $0c
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field0YrDecPath::
    ld hl, sp+$2c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    dec a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field1MonDecCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $02
    jp nz, DrawTimeAutosaveScreen_field1MonDecSkip

    jr DrawTimeAutosaveScreen_field1MonDecSkipPath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field1MonDecSkip::
    jp DrawTimeAutosaveScreen_field3HrDecCheck


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field1MonDecSkipPath::
    ld hl, sp+$2c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $01
    rlca
    jp c, DrawTimeAutosaveScreen_fieldDecJoinDirty

    ld a, $0c
    sub c
    rlca
    jp c, DrawTimeAutosaveScreen_fieldDecJoinDirty

    dec c
    ld e, c
    ld d, $00
    ld hl, $5492
    add hl, de
    add hl, de
    add hl, de
    jp hl


    jp DrawTimeAutosaveScreen_field2DayDecLoadA


    jp DrawTimeAutosaveScreen_field2DayDecLoadE


    jp DrawTimeAutosaveScreen_field2DayDecLoadA


    jp DrawTimeAutosaveScreen_field2DayDecLoadC


    jp DrawTimeAutosaveScreen_field2DayDecLoadA


    jp DrawTimeAutosaveScreen_field2DayDecLoadC


    jp DrawTimeAutosaveScreen_field2DayDecLoadA


    jp DrawTimeAutosaveScreen_field2DayDecLoadA


    jp DrawTimeAutosaveScreen_field2DayDecLoadC


    jp DrawTimeAutosaveScreen_field2DayDecLoadA


    jp DrawTimeAutosaveScreen_field2DayDecLoadC


    jp DrawTimeAutosaveScreen_field2DayDecLoadA


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayDecLoadA::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $01
    jp nz, Jump_004_54c4

    jr jr_004_54c7

Jump_004_54c4:
    jp DrawTimeAutosaveScreen_field2DayDecLoadB


jr_004_54c7:
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $1f
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayDecLoadB::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    dec a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayDecLoadC::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $01
    jp nz, Jump_004_54f0

    jr jr_004_54f3

Jump_004_54f0:
    jp DrawTimeAutosaveScreen_field2DayDecLoadD


jr_004_54f3:
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $1e
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayDecLoadD::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    dec a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayDecLoadE::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    sub $01
    jp nz, DrawTimeAutosaveScreen_field2DayDecSkip

    jr DrawTimeAutosaveScreen_field2DayDecSkipPath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayDecSkip::
    jp DrawTimeAutosaveScreen_field2DayDecLoadG


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayDecSkipPath::
    ld hl, sp+$2e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    ld a, $04
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call U8Mod
    add sp, $02
    ld c, e
    xor a
    or c
    jp nz, DrawTimeAutosaveScreen_field2DayDecLoadF

    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $1d
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayDecLoadF::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $1c
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field2DayDecLoadG::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    dec a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field3HrDecCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $03
    jp nz, DrawTimeAutosaveScreen_field3HrDecSkip

    jr DrawTimeAutosaveScreen_field3HrDecSkipPath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field3HrDecSkip::
    jp DrawTimeAutosaveScreen_field4MinDecCheck


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field3HrDecSkipPath::
    ld hl, sp+$28
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    or a
    jp nz, DrawTimeAutosaveScreen_field3HrDecLoad

    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $17
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field3HrDecLoad::
    ld hl, sp+$28
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    dec a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field4MinDecCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $04
    jp nz, DrawTimeAutosaveScreen_field4MinDecSkip

    jr DrawTimeAutosaveScreen_field4MinDecSkipPath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field4MinDecSkip::
    jp DrawTimeAutosaveScreen_field5SecDecCheck


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field4MinDecSkipPath::
    ld hl, sp+$26
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    or a
    jp nz, DrawTimeAutosaveScreen_field4MinDecLoad

    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $3b
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field4MinDecLoad::
    ld hl, sp+$26
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    dec a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field5SecDecCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $05
    jp nz, DrawTimeAutosaveScreen_field5SecDecSkip

    jr DrawTimeAutosaveScreen_field5SecDecSkipPath

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field5SecDecSkip::
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field5SecDecSkipPath::
    ld hl, sp+$30
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    or a
    jp nz, DrawTimeAutosaveScreen_field5SecDecLoad

    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $3b
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_field5SecDecLoad::
    ld hl, sp+$30
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    dec a
    dec hl
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_fieldDecJoinDirty::
    ld hl, sp+$3e
    ld [hl], $01
    jp DrawTimeAutosaveScreen_redraw


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_hiliteInc::
    ld hl, sp+$3d
    ld a, [hl]

; [ezgb]
; Source: kernel/stock/src/bank4.c

FlSetHiliteClamp::
    sub $01
    jp nc, DrawTimeAutosaveScreen_redraw

    inc [hl]
    inc hl
    ld [hl], $01
    jp DrawTimeAutosaveScreen_redraw


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_exitCheck40::
    ld a, c
    and $40
    jr nz, DrawTimeAutosaveScreen_exitCheck40Epilogue

    jp DrawTimeAutosaveScreen_exitCheck20


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_exitCheck40Epilogue::
    jp Jump_004_5903


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_exitCheck20::
    ld a, c
    and $20
    jr nz, DrawTimeAutosaveScreen_exitCheck20Redraw

    jp DrawTimeAutosaveScreen_exitCheck10


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_exitCheck20Redraw::
    jp DrawTimeAutosaveScreen_redraw


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_exitCheck10::
    ld a, c
    and $10
    jr nz, DrawTimeAutosaveScreen_exitCheck10Confirm

    jp DrawTimeAutosaveScreen_redraw


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_exitCheck10Confirm::
    xor a
    ld hl, sp+$3d
    or [hl]

; [ezgb]
; Source: kernel/stock/src/bank4.c

FlSetAHookSite::
    jp nz, DrawTimeAutosaveScreen_toggleA200Check

    ld hl, $0002
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0121
    push hl
    ld hl, $9b15
    push hl
    ld a, $7b
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
    xor a
    ld hl, sp+$40
    or [hl]
    jp nz, DrawTimeAutosaveScreen_confirmBcdWrite

    ld [hl], $01
    dec hl
    dec hl
    ld [hl], $01
    ld hl, sp+$22
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $0f
    ld b, a
    sra c
    sra c
    sra c
    sra c
    ld a, c
    ld e, a
    add a
    add a
    add e
    add a
    ld c, a
    add b
    ld hl, sp+$2e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$20
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $0f
    ld b, a
    ld a, c
    and $1f
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
    add b
    ld hl, sp+$2c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$1e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $0f
    ld b, a
    ld a, c
    and $3f
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
    add b
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$1c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $0f
    ld b, a
    ld a, c
    and $3f
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
    add b
    ld hl, sp+$28
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$1a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $0f
    ld b, a
    ld a, c
    and $7f
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
    add b
    ld hl, sp+$26
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld hl, sp+$24
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    and $0f
    ld b, a
    ld a, c
    and $7f
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
    add b
    ld hl, sp+$30
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    jp DrawTimeAutosaveScreen_redraw


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_confirmBcdWrite::
    ld hl, sp+$40
    ld [hl], $00
    dec hl
    dec hl
    ld [hl], $01
    ld a, $06
    push af
    inc sp
    call SetFpgaPage_B4
    add sp, $01
    ld hl, sp+$00
    ld [hl], $08
    inc hl
    ld [hl], $a0
    ld hl, sp+$30
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    push bc
    ld a, $0a
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call U8Div
    add sp, $02
    ld a, e
    pop bc
    ld b, a
    rlca
    rlca
    rlca
    rlca
    and $f0
    ld b, a
    push bc
    ld a, $0a
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call U8Mod
    add sp, $02
    ld c, e
    pop af
    ld b, a
    add c
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    ld [hl], $09
    inc hl
    ld [hl], $a0
    ld hl, sp+$26
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    push bc
    ld a, $0a
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call U8Div
    add sp, $02
    ld a, e
    pop bc
    ld b, a
    rlca
    rlca
    rlca
    rlca
    and $f0
    ld b, a
    push bc
    ld a, $0a
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call U8Mod
    add sp, $02
    ld c, e
    pop af
    ld b, a
    add c
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    ld [hl], $0a
    inc hl
    ld [hl], $a0
    ld hl, sp+$28
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    push bc
    ld a, $0a
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call U8Div
    add sp, $02
    ld a, e
    pop bc
    ld b, a
    rlca
    rlca
    rlca
    rlca
    and $f0
    ld b, a
    push bc
    ld a, $0a
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call U8Mod
    add sp, $02
    ld c, e
    pop af
    ld b, a
    add c
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    ld [hl], $0b
    inc hl
    ld [hl], $a0
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    push bc
    ld a, $0a
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call U8Div
    add sp, $02
    ld a, e
    pop bc
    ld b, a
    rlca
    rlca
    rlca
    rlca
    and $f0
    ld b, a
    push bc
    ld a, $0a
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call U8Mod
    add sp, $02
    ld c, e
    pop af
    ld b, a
    add c
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld bc, $a00c
    ld a, $03
    ld [bc], a
    dec hl
    ld [hl], $0d
    inc hl
    ld [hl], $a0
    ld hl, sp+$2c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    push bc
    ld a, $0a
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call U8Div
    add sp, $02
    ld a, e
    pop bc
    ld b, a
    rlca
    rlca
    rlca
    rlca
    and $f0
    ld b, a
    push bc
    ld a, $0a
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call U8Mod
    add sp, $02
    ld c, e
    pop af
    ld b, a
    add c
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    dec hl
    ld [hl], $0e
    inc hl
    ld [hl], $a0
    ld hl, sp+$2e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, [de]
    ld c, a
    push bc
    ld a, $0a
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call U8Div
    add sp, $02
    ld a, e
    pop bc
    ld b, a
    rlca
    rlca
    rlca
    rlca
    and $f0
    ld b, a
    push bc
    ld a, $0a
    push af
    inc sp
    ld a, c
    push af
    inc sp
    call U8Mod
    add sp, $02
    ld c, e
    pop af
    ld b, a
    add c
    ld hl, sp+$00
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld [de], a
    ld a, $01
    push af
    inc sp
    call SetFpga7FD0_B4
    add sp, $01
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B4
    add sp, $01
    jp DrawTimeAutosaveScreen_redraw


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_toggleA200Check::
    xor a
    ld hl, sp+$3c
    or [hl]
    jp nz, DrawTimeAutosaveScreen_toggleA200Clear

    ld [hl], $01
    jp DrawTimeAutosaveScreen_toggleA200Apply


; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_toggleA200Clear::
    ld hl, sp+$3c
    ld [hl], $00

; [ezgb]
; Source: kernel/stock/src/bank4.c

DrawTimeAutosaveScreen_toggleA200Apply::
    ld hl, sp+$3e
    ld [hl], $01
    ld bc, RomLoad_InitiatePoll
    ld a, $11
    ld [bc], a
    ld a, $03
    push af
    inc sp
    call SetFpgaPage_B4
    add sp, $01
    ld bc, $a200
    ld hl, sp+$3c
    ld a, [hl]
    ld [bc], a
    ld bc, RomLoad_InitiatePoll
    ld a, $00
    ld [bc], a
    ld a, $00
    push af
    inc sp
    call SetFpgaPage_B4
    add sp, $01
    jp DrawTimeAutosaveScreen_redraw


Jump_004_5903:
    add sp, $6a
    ret


TimeLabelStr::
    db "TIME:", $00

TimeSetLabelStr::
    db "SET", $00

AutoSaveLabelStr::
    db "AUTO SAVE:", $00

AutoSaveSavLabelStr::
    db "SAV", $00

PathSlashStr_B4::
    db "/", $00

    ld a, [hl-]
    nop
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
