; Disassembly of "kernel.gb"
; This file was created with:
; mgbdis v3.0 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $004", ROMX[$4000], BANK[$4]

; [ezgb]
; ROM load + soft-boot (kernel FPGA path only — not used by launched games).
; $7F36=$03: 512-byte load cmd window at $A000; build ROM in FPGA buffer.
; $7FE0=$80: reset into loaded ROM; same PSRAM chip, FPGA emulates game MBC.
; See docs/psram-save-map.md and docs/DEVELOPMENT.md.


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
; RomLoad_Build_B4(dst@sp+$06, src@sp+$08, n@sp+$0a): memcpy n bytes src→dst (build helper).
; Jump_004_40c2: while n--: *src++ (jr_004_40d5 carry) → *dst++ (jr_004_40e1 carry); Jump_004_40e4 add sp,$04 ret.
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
; SetFpga7F37_B4: unlock; write stack u8 to $7F37; commit. Sibling of
; SetRomLoadCtrl_B4 ($7F36). Orphan after SetRomLoadCtrl_B4.

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
; RomLoad_ResetIntoRom_B4: clear $7F31/$7F32; MBC writes $2000=$01/$3000=$00;
; then $7FE0=$80 soft-boot into loaded ROM (hangs via jp self if still here).
; Unlock $7F00/10/20=$e1/e2/e3 twice around setup; $7FF0=$e4 commit; Jump_004_41ce hang.

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
; SetFpgaRomSize_B4(arg@sp+$0a): switch → 16-bit bank mask@sp+$02; clamp vs $c2a4/$c2a5; write FPGA $7FC1/$7FC2. Launch @$1604.
; Codes 0..8: Jump_004_426b=0, Jump_004_4275=$03, Jump_004_427f=$07, Jump_004_4289=$0f, Jump_004_4293=$1f, Jump_004_429d=$3f, Jump_004_42a7=$7f, Jump_004_42b1=$00ff, Jump_004_42bb=$01ff.
; $52..$54: Jump_004_42c5=$47, Jump_004_42cf=$4f, Jump_004_42d9=$5f; Jump_004_42e3 default 0; join Jump_004_42ea clamp if mask>(caps-1).
; Clamp $c2a4 bits: jr_004_4308=$01 / Jump_004_430f; jr_004_431a=$03 / Jump_004_4321; jr_004_432c=$07 / Jump_004_4333; jr_004_433e=$0f / Jump_004_4345;
; jr_004_4350=$1f / Jump_004_4357; jr_004_4362=$3f / Jump_004_4369; jr_004_4374=$7f / Jump_004_437b; jr_004_4386=$ff / Jump_004_438d; jr_004_4398 $c2a5.0→$01ff; Jump_004_439f unlock+write+commit.

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
; SetFpga7FC4_B4(mode@sp+$07): map mode → lo nibble@sp+$00; unlock+write $7FC4; commit $7FF0=$e4.
; Dispatch: mode0 → Jump_004_4417; 1 or 2 → Jump_004_4433; 4 → Jump_004_443a; 5 → Jump_004_4441; else Jump_004_4448.
; Jump_004_4417: if $d3eb!=2 → Jump_004_4422 → Jump_004_442c store $00; else jr_004_4425 store $00; both → Jump_004_444c.
; Jump_004_4433:$00; Jump_004_443a:$0f; Jump_004_4441:$07; Jump_004_4448:$03; fall Jump_004_444c: $7F00/10/20=$e1/e2/e3; [$7FC4]=nibble; $7FF0=$e4; ret.

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
; RomLoad_CopyCmdWindowPoll_B4: SetRomLoadCtrl_B4($01) map cmd window; copy $200
; bytes stack→$A000 via VramCopyStack; RomLoad_BuildAndRunPoll. Before CStrCat.

RomLoad_CopyCmdWindowPoll_B4::
    jp $7d00


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
; CStrCat(dest, src): append NUL-term src onto dest. Frame -$04; stack RTL dest@sp+$06, src@sp+$08.
; Jump_004_44b6: walk BC=dest until [BC]==0 → Jump_004_44bf stash src@sp+$00 + dest-end@sp+$02.
; Jump_004_44cb: load *src; if 0 → Jump_004_44ec write NUL; else inc src (jr_004_44dd carry), store to *dest, inc dest (jr_004_44e9 carry), loop.
; jr_004_44dd / jr_004_44e9: 16-bit pointer ++ after lo-byte wrap; Jump_004_44ec: [dest]=0 + add sp,$04 ret.

CStrCat::
    push af
    push af
    ld hl, sp+$06
    ld c, [hl]
    inc hl
    ld b, [hl]

CStrCat_findNul::
    ld a, [bc]
    or a
    jp z, CStrCat_stashPtrs

    inc bc
    jp CStrCat_findNul


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

CStrCat_afterStore::
    jp CStrCat_copyLoop


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
; U32ToAscii(val@sp+$36, buf@sp+$3a, radix@sp+$3c): frame -$34; digit scratch@sp+$13. Bank0 twin U32ToAscii_B0.
; Jump_004_451b: if val!=0 → Jump_004_453c; elif scratch advanced → Jump_004_4539 → Jump_004_45e8; else jr_004_453c fall into emit.
; Jump_004_453c/jr_004_453c: U32Div+U32Mod by radix; rem<$0a → '0'+n (jr_004_45d0) else Jump_004_45d3 +$57 (jr_004_45e5) → Jump_004_451b.
; Jump_004_45e8: setup reverse; Jump_004_4605: copy scratch→buf (jr_004_462a) until done → Jump_004_462d NUL; empty → plant "0"; Jump_004_466b epilogue.

U32ToAscii::
    jp $7c00


    nop
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

U32ToAscii_skipEmit::
    jp U32ToAscii_setupReverse


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

U32ToAscii_digit0to9::
    jp U32ToAscii_digitLoop


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

U32ToAscii_afterAlpha::
    jp U32ToAscii_digitLoop


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

U32ToAscii_copyCont::
    jp U32ToAscii_copyLoop


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

U32ToAscii_epilogueRet::
    add sp, $34
    ret


; [ezgb]
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
; SetFpga7FD0_B4: same unlock/commit as SetFpgaPage but writes stack u8 to $7FD0.
; See docs/REGISTERS.md ($7fd0/$7fd2/$7fd4 peripheral enable candidates).

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
; DrawTimeAutosaveScreen: sp+$3c=$A200; sp+$3d hilite; sp+$3e dirty; sp+$3f field 0..5; sp+$40 SET/SAV.
; Setup: sp+$3c!=1 → Jump_004_47ce; jr_004_47d1 DrawRect; Jump_004_47ef field slot ptrs → Jump_004_48f5.
; SET redraw Jump_004_48f5: sp+$40≠0 → SAV Jump_004_4e42; sp+$3e!=1 → Jump_004_4906/Jump_004_49ee; else jr_004_4909 hilite.
; Hilite: Jump_004_4920/Jump_004_492d StoreDrawParams; Jump_004_4959/Jump_004_496a/Jump_004_4992/jr_004_4995/Jump_004_49a5/Jump_004_49b2 SET strings; Jump_004_49cd/jr_004_49d0 → Jump_004_49ee.
; FPGA Jump_004_49ee: page6 $A008..$A00E → slots; Jump_004_4aa3/jr_004_4aa6 gate.
; Field clones: Jump_004_4aad (+Jump_004_4b2e/Jump_004_4b43/jr_004_4b46); Jump_004_4b4d (+Jump_004_4bcc/Jump_004_4be1/jr_004_4be4); Jump_004_4beb (+Jump_004_4c5a/Jump_004_4c6f/jr_004_4c72);
; Jump_004_4c79 (+Jump_004_4cf9/Jump_004_4d0e/jr_004_4d11); Jump_004_4d18 (+Jump_004_4d98/Jump_004_4dad/jr_004_4db0); Jump_004_4db7; Jump_004_4e26 Memcpy → Jump_004_5162.
; SAV date clones (Jump_004_4e42 dirty): yr Jump_004_4ec6; mon Jump_004_4f38/jr_004_4f3b/Jump_004_4f48; day Jump_004_4fba/jr_004_4fbd/Jump_004_4fca;
; hr Jump_004_502b/jr_004_502e/Jump_004_503b; min Jump_004_50ad/jr_004_50b0/Jump_004_50bd; sec Jump_004_512f/jr_004_5132/Jump_004_513f → Jump_004_5162.
; Input Jump_004_5162: $02 jr_004_5170 field-- (Jump_004_5189/Jump_004_5192/Jump_004_5199 wrap); $01 jr_004_51a1 field++ (Jump_004_51ba/jr_004_51bd/Jump_004_51c1/Jump_004_51c8).
; $04 bump jr_004_51d0 field0 yr (Jump_004_51f3/jr_004_51f6 wrap $63/Jump_004_5201); Jump_004_5211 field1 mon (Jump_004_521b/jr_004_521e/Jump_004_522c/jr_004_522f/Jump_004_523a).
; Jump_004_524a field2 day (Jump_004_5254/jr_004_5257; Jump_004_529a/Jump_004_52a8/jr_004_52ab/Jump_004_52b6; Jump_004_52c6/Jump_004_52d4/jr_004_52d7/Jump_004_52e2; Jump_004_52f2 U8Mod; Jump_004_5317/Jump_004_532c/Jump_004_532f/jr_004_532f/Jump_004_533a) → Jump_004_53f2.
; $04 fields 3..5: Jump_004_534a hr (Jump_004_5354/jr_004_5357/Jump_004_5365/jr_004_5368/Jump_004_5373); Jump_004_5383 min (Jump_004_538d/jr_004_5390/Jump_004_539e/jr_004_53a1/Jump_004_53ac);
; Jump_004_53bc sec (Jump_004_53c6/jr_004_53c9/Jump_004_53d7/jr_004_53da/Jump_004_53e5); join Jump_004_53f2 dirty; Jump_004_53f9 SET hilite-- twin → Jump_004_48f5.
; $08 dec Jump_004_5407/jr_004_540f: field0 yr Jump_004_5438/Jump_004_5448/Jump_004_5452/jr_004_5455/Jump_004_546c; field1 mon Jump_004_547c/Jump_004_5486/jr_004_5489;
; field2 day Jump_004_54cc/Jump_004_54e3/Jump_004_54f3/Jump_004_550a/Jump_004_551a/Jump_004_5528/jr_004_552b/Jump_004_554f/Jump_004_555a; field3 hr Jump_004_556a/Jump_004_5574/jr_004_5577/Jump_004_558b;
; field4 min Jump_004_559b/Jump_004_55a5/jr_004_55a8/Jump_004_55bc; field5 sec Jump_004_55cc/Jump_004_55d6/jr_004_55d9/Jump_004_55ed; Jump_004_55fa dirty; Jump_004_5601 SET hilite++.
; Exit: Jump_004_5610/jr_004_5618/Jump_004_561b/jr_004_5623/Jump_004_5626; $10 jr_004_562e confirm Jump_004_5747 BCD→$A008+$7FD0; $40 Jump_004_58d6/Jump_004_58e2/Jump_004_58e6 toggle $A200 → Jump_004_5912 ret.

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
    ld hl, $0200
    push hl
    ld a, $05
    push af
    inc sp
    ld hl, TimeLabelStr
    push hl
    call $6400
    add sp, $05
    ld hl, $0003
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0119
    push hl
    call $5f60
    push hl
    ld a, $7b
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, $0210
    push hl
    ld a, $03
    push af
    inc sp
    ld hl, TimeSetLabelStr
    push hl
    call $6400
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0800
    push hl
    ld a, $0a
    push af
    inc sp
    ld hl, AutoSaveLabelStr
    push hl
    call $6400
    add sp, $05
    ld hl, $0048
    push hl
    ld hl, $8a40
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

DrawTimeAutosaveScreen_setupSkipDrawRect::
    jp DrawTimeAutosaveScreen_fieldSlotPtrs


DrawTimeAutosaveScreen_setupDoDrawRect::
    ld hl, $0003
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, HeaderSGBFlag
    push hl
    ld hl, $8842
    push hl
    ld a, $84
    push af
    inc sp
    call DrawRect
    add sp, $05

DrawTimeAutosaveScreen_fieldSlotPtrs::
    call $5932
    nop
    nop
    nop
    nop
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

DrawTimeAutosaveScreen_redraw::
    call WaitVBlankFlag
    ld hl, sp+$3e
    ld a, [hl]
    sub $01
    jp nz, DrawTimeAutosaveScreen_hiliteGate

    jr DrawTimeAutosaveScreen_hilitePath

DrawTimeAutosaveScreen_hiliteGate::
    jp Jump_004_49ea


DrawTimeAutosaveScreen_hilitePath::
    xor a
    ld hl, sp+$3d
    or [hl]
    jp nz, DrawTimeAutosaveScreen_hiliteStoreDrawParamsA

    ld hl, $0003
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    jp DrawTimeAutosaveScreen_hiliteStoreDrawParamsB


DrawTimeAutosaveScreen_hiliteStoreDrawParamsA::
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

DrawTimeAutosaveScreen_hiliteStoreDrawParamsB::
    ld hl, $0119
    push hl
    call $5f60
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

    ld hl, $0210
    push hl
    ld a, $03
    push af
    inc sp
    ld hl, TimeSetLabelStr
    push hl
    call $6400
    add sp, $05
    jp DrawTimeAutosaveScreen_setStringB


DrawTimeAutosaveScreen_setStringA::
    ld hl, $0210
    push hl
    ld a, $03
    push af
    inc sp
    ld hl, AutoSaveSavLabelStr
    push hl
    call $6400
    add sp, $05

DrawTimeAutosaveScreen_setStringB::
    ld hl, $0000
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, HeaderROMSize
    push hl
    ld hl, $8a40
    push hl
    ld a, $82
    push af
    inc sp
    call DrawRect
    add sp, $05
    ld hl, sp+$3d
    ld a, [hl]
    sub $02
    jp nz, DrawTimeAutosaveScreen_setStringC

    jr DrawTimeAutosaveScreen_setStringCPath

DrawTimeAutosaveScreen_setStringC::
    jp DrawTimeAutosaveScreen_setStringD


DrawTimeAutosaveScreen_setStringCPath::
    ld hl, $0001
    push hl
    ld a, $01
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    jp DrawTimeAutosaveScreen_setStringE


DrawTimeAutosaveScreen_setStringD::
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

DrawTimeAutosaveScreen_setStringE::
    ld hl, $0048
    push hl
    ld hl, $8a40
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

DrawTimeAutosaveScreen_setStringsDone::
    jp Jump_004_49ea


DrawTimeAutosaveScreen_setStringsDonePath::
    ld hl, $0003
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, HeaderSGBFlag
    push hl
    ld hl, $8842
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

DrawTimeAutosaveScreen_fpgaSlotGate::
    jp DrawTimeAutosaveScreen_field0Clone


DrawTimeAutosaveScreen_fpgaSlotGatePath::
    xor a
    ld hl, sp+$3e
    or [hl]
    jp z, DrawTimeAutosaveScreen_field0LoadVal

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
    ld hl, FarCallScan
    push hl
    ld a, $05
    push af
    inc sp
    push bc
    call $6400
    add sp, $05

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

DrawTimeAutosaveScreen_field0Next::
    jp DrawTimeAutosaveScreen_field1Clone


DrawTimeAutosaveScreen_field0NextPath::
    xor a
    ld hl, sp+$3e
    or [hl]
    jp z, DrawTimeAutosaveScreen_field1LoadVal

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
    ld hl, $0405
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call $6400
    add sp, $05
    ld hl, $0407
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, PathSlashStr_B4
    push hl
    call $6400
    add sp, $05

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

DrawTimeAutosaveScreen_field1Next::
    jp DrawTimeAutosaveScreen_field2Clone


DrawTimeAutosaveScreen_field1NextPath::
    xor a
    ld hl, sp+$3e
    or [hl]
    jp z, DrawTimeAutosaveScreen_field2LoadVal

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
    ld hl, $0408
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call $6400
    add sp, $05

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

DrawTimeAutosaveScreen_field2Next::
    jp DrawTimeAutosaveScreen_field3Clone


DrawTimeAutosaveScreen_field2NextPath::
    xor a
    ld hl, sp+$3e
    or [hl]
    jp z, DrawTimeAutosaveScreen_field3LoadVal

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
    ld hl, $040b
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call $6400
    add sp, $05
    ld hl, $040d
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, $5921
    push hl
    call $6400
    add sp, $05

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

DrawTimeAutosaveScreen_field3Next::
    jp DrawTimeAutosaveScreen_field4Clone


DrawTimeAutosaveScreen_field3NextPath::
    xor a
    ld hl, sp+$3e
    or [hl]
    jp z, DrawTimeAutosaveScreen_field4LoadVal

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
    ld hl, $040e
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call $6400
    add sp, $05
    ld hl, $0410
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, $5921
    push hl
    call $6400
    add sp, $05

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

DrawTimeAutosaveScreen_field4Next::
    jp DrawTimeAutosaveScreen_field5Clone


DrawTimeAutosaveScreen_field4NextPath::
    xor a
    ld hl, sp+$3e
    or [hl]
    jp z, DrawTimeAutosaveScreen_clearDirtyMemcpy

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
    ld hl, $0411
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call $6400
    add sp, $05

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

    ld hl, $0003
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

DrawTimeAutosaveScreen_savYearClone::
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, FarCallScan
    push hl
    ld a, $04
    push af
    inc sp
    push bc
    call $6400
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0404
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, PathSlashStr_B4
    push hl
    call $6400
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

DrawTimeAutosaveScreen_savMonGate::
    jp DrawTimeAutosaveScreen_savMonClone


DrawTimeAutosaveScreen_savMonGatePath::
    ld hl, $0003
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

DrawTimeAutosaveScreen_savMonClone::
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, $0405
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call $6400
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0407
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, PathSlashStr_B4
    push hl
    call $6400
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

DrawTimeAutosaveScreen_savDayGate::
    jp DrawTimeAutosaveScreen_savDayClone


DrawTimeAutosaveScreen_savDayGatePath::
    ld hl, $0003
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

DrawTimeAutosaveScreen_savDayClone::
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, $0408
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call $6400
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

DrawTimeAutosaveScreen_savHrGate::
    jp DrawTimeAutosaveScreen_savHrClone


DrawTimeAutosaveScreen_savHrGatePath::
    ld hl, $0003
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

DrawTimeAutosaveScreen_savHrClone::
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, $040b
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call $6400
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $040d
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, $5921
    push hl
    call $6400
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

DrawTimeAutosaveScreen_savMinGate::
    jp DrawTimeAutosaveScreen_savMinClone


DrawTimeAutosaveScreen_savMinGatePath::
    ld hl, $0003
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

DrawTimeAutosaveScreen_savMinClone::
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, $040e
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call $6400
    add sp, $05
    ld hl, $0000
    push hl
    ld a, $03
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0410
    push hl
    ld a, $01
    push af
    inc sp
    ld hl, $5921
    push hl
    call $6400
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

DrawTimeAutosaveScreen_savSecGate::
    jp DrawTimeAutosaveScreen_savSecClone


DrawTimeAutosaveScreen_savSecGatePath::
    ld hl, $0003
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03

DrawTimeAutosaveScreen_savSecClone::
    ld hl, sp+$41
    ld c, l
    ld b, h
    ld hl, $0411
    push hl
    ld a, $02
    push af
    inc sp
    push bc
    call $6400
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

DrawTimeAutosaveScreen_inputLoop::
    call $5f20
    ld c, e
    ld b, $00
    ld a, c
    and $02
    jr nz, DrawTimeAutosaveScreen_inputLoopFieldDec

    jp DrawTimeAutosaveScreen_fieldDecWrap


DrawTimeAutosaveScreen_inputLoopFieldDec::
    xor a
    ld hl, sp+$40
    or [hl]
    jp z, $5f80

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


DrawTimeAutosaveScreen_fieldDecCheck::
    xor a
    ld hl, sp+$3f
    or [hl]
    jp nz, DrawTimeAutosaveScreen_fieldDecDirty

    ld [hl], $05

DrawTimeAutosaveScreen_fieldDecDirty::
    ld hl, sp+$3e
    ld [hl], $02
    jp DrawTimeAutosaveScreen_redraw


DrawTimeAutosaveScreen_fieldDecWrap::
    ld a, c
    and $01
    jr nz, DrawTimeAutosaveScreen_fieldDecWrapFieldInc

    jp DrawTimeAutosaveScreen_fieldIncWrap


DrawTimeAutosaveScreen_fieldDecWrapFieldInc::
    xor a
    ld hl, sp+$40
    or [hl]
    jp z, $5f90

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

DrawTimeAutosaveScreen_fieldIncGate::
    jp DrawTimeAutosaveScreen_fieldIncDirty


DrawTimeAutosaveScreen_fieldIncGateWrap0::
    ld hl, sp+$3f
    ld [hl], $00

DrawTimeAutosaveScreen_fieldIncDirty::
    ld hl, sp+$3e
    ld [hl], $03
    jp DrawTimeAutosaveScreen_redraw


DrawTimeAutosaveScreen_fieldIncWrap::
    ld a, c
    and $04
    jr nz, DrawTimeAutosaveScreen_fieldIncWrapBump

    jp DrawTimeAutosaveScreen_fieldDecBtn


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

DrawTimeAutosaveScreen_field0YrGate::
    jp DrawTimeAutosaveScreen_field0YrWrap


DrawTimeAutosaveScreen_field0YrGateZero::
    ld hl, sp+$2e
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


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


DrawTimeAutosaveScreen_field1MonCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $01
    jp nz, DrawTimeAutosaveScreen_field1MonGate

    jr DrawTimeAutosaveScreen_field1MonGatePath

DrawTimeAutosaveScreen_field1MonGate::
    jp DrawTimeAutosaveScreen_field2DayCheck


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

DrawTimeAutosaveScreen_field1MonPath::
    jp DrawTimeAutosaveScreen_field1MonLoad


DrawTimeAutosaveScreen_field1MonPathZero::
    ld hl, sp+$2c
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


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


DrawTimeAutosaveScreen_field2DayCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $02
    jp nz, DrawTimeAutosaveScreen_field2DayGate

    jr DrawTimeAutosaveScreen_field2DayGatePath

DrawTimeAutosaveScreen_field2DayGate::
    jp DrawTimeAutosaveScreen_field3HrCheck


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

DrawTimeAutosaveScreen_field2DayPath::
    jp DrawTimeAutosaveScreen_field2DayLoadB


DrawTimeAutosaveScreen_field2DayPathZero::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


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

DrawTimeAutosaveScreen_field2DayPath2::
    jp DrawTimeAutosaveScreen_field2DayLoadD


DrawTimeAutosaveScreen_field2DayPath2Zero::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


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

DrawTimeAutosaveScreen_field2DayModGate::
    jp DrawTimeAutosaveScreen_field2DayModLoad


DrawTimeAutosaveScreen_field2DayModPath::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $01
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


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


DrawTimeAutosaveScreen_field3HrCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $03
    jp nz, DrawTimeAutosaveScreen_field3HrGate

    jr DrawTimeAutosaveScreen_field3HrGatePath

DrawTimeAutosaveScreen_field3HrGate::
    jp DrawTimeAutosaveScreen_field4MinCheck


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

DrawTimeAutosaveScreen_field3HrPath::
    jp DrawTimeAutosaveScreen_field3HrLoad


DrawTimeAutosaveScreen_field3HrPathZero::
    ld hl, sp+$28
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


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


DrawTimeAutosaveScreen_field4MinCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $04
    jp nz, DrawTimeAutosaveScreen_field4MinGate

    jr DrawTimeAutosaveScreen_field4MinGatePath

DrawTimeAutosaveScreen_field4MinGate::
    jp DrawTimeAutosaveScreen_field5SecCheck


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

DrawTimeAutosaveScreen_field4MinPath::
    jp DrawTimeAutosaveScreen_field4MinLoad


DrawTimeAutosaveScreen_field4MinPathZero::
    ld hl, sp+$26
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


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


DrawTimeAutosaveScreen_field5SecCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $05
    jp nz, DrawTimeAutosaveScreen_field5SecGate

    jr DrawTimeAutosaveScreen_field5SecGatePath

DrawTimeAutosaveScreen_field5SecGate::
    jp DrawTimeAutosaveScreen_fieldBumpDirty


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

DrawTimeAutosaveScreen_field5SecPath::
    jp DrawTimeAutosaveScreen_field5SecLoad


DrawTimeAutosaveScreen_field5SecJr::
    ld hl, sp+$30
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $00
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldBumpDirty


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

DrawTimeAutosaveScreen_fieldBumpDirty::
    ld hl, sp+$3e
    ld [hl], $01
    jp DrawTimeAutosaveScreen_redraw


DrawTimeAutosaveScreen_hiliteDec::
    xor a
    ld hl, sp+$3d
    or [hl]
    jp z, DrawTimeAutosaveScreen_redraw

    dec [hl]
    inc hl
    ld [hl], $01
    jp $5948


DrawTimeAutosaveScreen_fieldDecBtn::
    ld a, c
    and $08
    jr nz, DrawTimeAutosaveScreen_fieldDecBtnJr

    jp DrawTimeAutosaveScreen_exitCheck40


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


DrawTimeAutosaveScreen_field0YrDecCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $01
    jp nz, DrawTimeAutosaveScreen_field0YrDecSkip

    jr DrawTimeAutosaveScreen_field0YrDecJr

DrawTimeAutosaveScreen_field0YrDecSkip::
    jp DrawTimeAutosaveScreen_field1MonDecCheck


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


DrawTimeAutosaveScreen_field1MonDecCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $02
    jp nz, DrawTimeAutosaveScreen_field1MonDecSkip

    jr DrawTimeAutosaveScreen_field1MonDecSkipPath

DrawTimeAutosaveScreen_field1MonDecSkip::
    jp DrawTimeAutosaveScreen_field3HrDecCheck


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

DrawTimeAutosaveScreen_field2DayDecSkip::
    jp DrawTimeAutosaveScreen_field2DayDecLoadG


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


DrawTimeAutosaveScreen_field2DayDecLoadF::
    ld hl, sp+$2a
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld a, $1c
    ld [de], a
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


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


DrawTimeAutosaveScreen_field3HrDecCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $03
    jp nz, DrawTimeAutosaveScreen_field3HrDecSkip

    jr DrawTimeAutosaveScreen_field3HrDecSkipPath

DrawTimeAutosaveScreen_field3HrDecSkip::
    jp DrawTimeAutosaveScreen_field4MinDecCheck


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


DrawTimeAutosaveScreen_field4MinDecCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $04
    jp nz, DrawTimeAutosaveScreen_field4MinDecSkip

    jr DrawTimeAutosaveScreen_field4MinDecSkipPath

DrawTimeAutosaveScreen_field4MinDecSkip::
    jp DrawTimeAutosaveScreen_field5SecDecCheck


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


DrawTimeAutosaveScreen_field5SecDecCheck::
    ld hl, sp+$3f
    ld a, [hl]
    sub $05
    jp nz, DrawTimeAutosaveScreen_field5SecDecSkip

    jr DrawTimeAutosaveScreen_field5SecDecSkipPath

DrawTimeAutosaveScreen_field5SecDecSkip::
    jp DrawTimeAutosaveScreen_fieldDecJoinDirty


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

DrawTimeAutosaveScreen_fieldDecJoinDirty::
    ld hl, sp+$3e
    ld [hl], $01
    jp DrawTimeAutosaveScreen_redraw


DrawTimeAutosaveScreen_hiliteInc::
    ld hl, sp+$3d
    ld a, [hl]

FlSetHiliteClamp::
    db $d6, $07

    jp nc, DrawTimeAutosaveScreen_redraw

    inc [hl]
    inc hl
    ld [hl], $01
    jp $5948


DrawTimeAutosaveScreen_exitCheck40::
    ld a, c
    and $40
    jr nz, DrawTimeAutosaveScreen_exitCheck40Epilogue

    jp DrawTimeAutosaveScreen_exitCheck20


DrawTimeAutosaveScreen_exitCheck40Epilogue::
    jp DrawTimeAutosaveScreen_epilogueRet


DrawTimeAutosaveScreen_exitCheck20::
    ld a, c
    and $20
    jr nz, DrawTimeAutosaveScreen_exitCheck20Redraw

    jp DrawTimeAutosaveScreen_exitCheck10


DrawTimeAutosaveScreen_exitCheck20Redraw::
    jp DrawTimeAutosaveScreen_redraw


DrawTimeAutosaveScreen_exitCheck10::
    ld a, c
    and $10
    jr nz, DrawTimeAutosaveScreen_exitCheck10Confirm

    jp DrawTimeAutosaveScreen_redraw


DrawTimeAutosaveScreen_exitCheck10Confirm::
    xor a
    ld hl, sp+$3d
    or [hl]

FlSetAHookSite::
    db $c2, $30, $5f

    ld hl, $0003
    push hl
    ld a, $00
    push af
    inc sp
    call StoreDrawParams
    add sp, $03
    ld hl, $0119
    push hl
    call $5f60
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
    jp $5f10


DrawTimeAutosaveScreen_toggleA200Check::
    xor a
    ld hl, sp+$3c
    or [hl]
    jp nz, DrawTimeAutosaveScreen_toggleA200Clear

    ld [hl], $01
    jp DrawTimeAutosaveScreen_toggleA200Apply


DrawTimeAutosaveScreen_toggleA200Clear::
    ld hl, sp+$3c
    ld [hl], $00

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
    jp $5fa0


DrawTimeAutosaveScreen_epilogueRet::
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

FlSetEnterHook::
    db $f8, $02, $4d, $44, $3e, $00, $f5, $33
    db $c5, $cd, $00, $66, $e8, $03, $f8, $5e
    db $4d, $44, $21, $07, $00, $c9

FlSetRowsHook::
    db $f8, $00, $4d, $44, $3e, $01, $f5, $33
    db $c5, $cd, $00, $66, $e8, $03, $c3, $f5
    db $48

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

FlPickCommitFar::
    db $3e, $03, $f5, $33, $21, $00, $00, $e5
    db $cd, $00, $66, $e8, $03, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

FarCallTheme_B4::
    db $cd, $8d, $07, $d0, $43, $02, $00, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

RomMenu::
    db $e8, $fb, $fa, $fe, $db, $b7, $c2, $7e
    db $5b, $f8, $0b, $2a, $5f, $56, $1a, $4f
    db $13, $1a, $47, $21, $a0, $c2, $2a, $6e
    db $81, $4f, $7d, $88, $f8, $02, $71, $23
    db $32, $2a, $5f, $56, $d5, $cd, $89, $5b
    db $e1, $7b, $b7, $ca, $7e, $5b, $f0, $f5
    db $cb, $67, $28, $0e, $cd, $f2, $5b, $7b
    db $b7, $20, $f9, $e0, $f6, $1e, $01, $c3
    db $86, $5b, $f0, $fa, $4f, $c5, $cd, $f2
    db $5b, $7b, $c1, $b7, $ca, $7e, $5b, $f0
    db $fa, $91, $d6, $1e, $38, $ef, $f8, $04
    db $36, $00, $f8, $04, $7e, $c6, $a4, $4f
    db $3e, $00, $ce, $c4, $47, $7e, $d6, $fe
    db $30, $14, $2b, $2b, $2a, $23, $86, $2b
    db $5f, $7e, $ce, $00, $57, $1a, $b7, $28
    db $05, $23, $02, $34, $18, $dc, $af, $02
    db $cd, $00, $5c, $f8, $04, $36, $00, $af
    db $f5, $33, $cd, $34, $5d, $33, $f8, $03
    db $36, $10, $f8, $0b, $2a, $c6, $0f, $4f
    db $3a, $ce, $00, $47, $7e, $c6, $11, $f5
    db $f8, $02, $f1, $77, $f5, $f8, $0e, $f1
    db $7e, $ce, $00, $f8, $01, $77, $f0, $fa
    db $21, $fa, $ff, $6e, $bd, $28, $f9, $c5
    db $cd, $70, $03, $c1, $f8, $03, $7e, $2f
    db $a3, $57, $73, $e6, $0c, $28, $11, $f8
    db $04, $7e, $ee, $01, $77, $c5, $7e, $f5
    db $33, $cd, $34, $5d, $33, $c1, $18, $d6
    db $cb, $6a, $20, $4f, $cb, $62, $28, $ce
    db $f8, $04, $7e, $b7, $ca, $7e, $5b, $2b
    db $2b, $59, $50, $1a, $22, $13, $1a, $32
    db $d1, $d5, $1a, $16, $00, $86, $23, $5f
    db $7a, $8e, $57, $cb, $3a, $cb, $1b, $cb
    db $3a, $cb, $1b, $cb, $3a, $cb, $1b, $cb
    db $3a, $cb, $1b, $cb, $3a, $cb, $1b, $7b
    db $c6, $12, $c5, $f5, $33, $cd, $11, $6d
    db $33, $cd, $00, $5c, $3e, $01, $f5, $33
    db $cd, $34, $5d, $33, $c1, $f8, $03, $36
    db $ff, $18, $83, $af, $0f, $f5, $af, $f5
    db $33, $cd, $d8, $23, $e8, $03, $f0, $fb
    db $b7, $28, $12, $21, $7b, $01, $e5, $21
    db $20, $9f, $e5, $af, $f5, $33, $cd, $01
    db $24, $e8, $05, $18, $10, $21, $77, $01
    db $e5, $21, $20, $9f, $e5, $af, $f5, $33
    db $cd, $01, $24, $e8, $05, $af, $0f, $f5
    db $af, $3e, $03, $f5, $33, $cd, $d8, $23
    db $e8, $03, $f8, $0b, $2a, $c6, $0e, $4f
    db $7e, $ce, $00, $69, $67, $36, $01, $af
    db $e0, $f6, $1e, $01, $18, $08, $af, $e0
    db $f6, $cd, $83, $04, $1e, $00, $e8, $05
    db $c9, $3b, $01, $00, $00, $f8, $00, $36
    db $00, $f8, $00, $7e, $d6, $fe, $30, $1e
    db $f8, $03, $7e, $f8, $00, $86, $23, $23
    db $23, $23, $5f, $7e, $ce, $00, $57, $1a
    db $b7, $28, $0b, $fe, $2e, $20, $02, $4b
    db $42, $f8, $00, $34, $18, $db, $78, $b1
    db $28, $15, $69, $60, $23, $7e, $cb, $ef
    db $fe, $67, $20, $0b, $69, $60, $23, $23
    db $7e, $cb, $ef, $fe, $62, $28, $04, $1e
    db $00, $18, $1d, $69, $60, $23, $23, $23
    db $7e, $b7, $28, $12, $cb, $ef, $fe, $63
    db $20, $08, $21, $04, $00, $09, $7e, $b7
    db $28, $04, $1e, $00, $18, $02, $1e, $01
    db $33, $c9, $f0, $fa, $4f, $f0, $fa, $91
    db $28, $fb, $f0, $fc, $e6, $10, $5f, $c9
    db $e8, $fa, $af, $0f, $f5, $af, $f5, $33
    db $cd, $d8, $23, $e8, $03, $f0, $fb, $b7
    db $28, $12, $21, $7b, $01, $e5, $21, $20
    db $9f, $e5, $af, $f5, $33, $cd, $01, $24
    db $e8, $05, $18, $10, $21, $77, $01, $e5
    db $21, $20, $9f, $e5, $af, $f5, $33, $cd
    db $01, $24, $e8, $05, $af, $0f, $f5, $af
    db $3e, $03, $f5, $33, $cd, $d8, $23, $e8
    db $03, $f0, $fb, $b7, $28, $12, $21, $77
    db $01, $e5, $21, $24, $9f, $e5, $af, $f5
    db $33, $cd, $01, $24, $e8, $05, $18, $10
    db $21, $73, $01, $e5, $21, $23, $9f, $e5
    db $af, $f5, $33, $cd, $01, $24, $e8, $05
    db $21, $05, $28, $e5, $11, $1e, $5d, $d5
    db $cd, $c4, $5d, $e8, $04, $f0, $fb, $b7
    db $28, $3a, $21, $0d, $68, $e5, $11, $26
    db $5d, $d5, $cd, $c4, $5d, $e8, $04, $0e
    db $00, $59, $16, $00, $21, $00, $00, $39
    db $19, $5d, $54, $21, $2e, $5d, $06, $00
    db $09, $7e, $12, $0c, $79, $d6, $06, $38
    db $e8, $21, $00, $00, $39, $11, $56, $68
    db $d5, $af, $f5, $33, $e5, $cd, $c0, $05
    db $e8, $05, $18, $22, $21, $01, $0d, $e5
    db $3e, $07, $f5, $33, $11, $26, $5d, $d5
    db $cd, $b7, $08, $e8, $05, $21, $0b, $0d
    db $e5, $3e, $05, $f5, $33, $11, $2e, $5d
    db $d5, $cd, $b7, $08, $e8, $05, $cd, $2a
    db $5e, $af, $67, $2e, $03, $e5, $3e, $03
    db $f5, $33, $cd, $d8, $23, $e8, $03, $f0
    db $fb, $b7, $28, $12, $21, $45, $01, $e5
    db $21, $35, $9f, $e5, $af, $f5, $33, $cd
    db $01, $24, $e8, $05, $18, $10, $21, $43
    db $01, $e5, $21, $33, $9f, $e5, $af, $f5
    db $33, $cd, $01, $24, $e8, $05, $21, $3f
    db $db, $36, $01, $11, $a4, $c4, $d5, $cd
    db $68, $03, $e1, $e8, $06, $c9, $4f, $70
    db $74, $69, $6f, $6e, $73, $00, $5b, $42
    db $5d, $62, $61, $63, $6b, $00, $5b, $41
    db $5d, $6f, $6b, $00, $e8, $f1, $af, $0f
    db $f5, $af, $3e, $03, $f5, $33, $cd, $d8
    db $23, $e8, $03, $0e, $00, $59, $16, $00
    db $21, $00, $00, $39, $19, $5d, $54, $21
    db $ad, $5d, $06, $00, $09, $7e, $12, $0c
    db $79, $d6, $08, $38, $e8, $f8, $11, $7e
    db $b7, $20, $04, $f8, $00, $36, $3e, $21
    db $09, $48, $e5, $21, $02, $00, $39, $e5
    db $cd, $c4, $5d, $e8, $04, $0e, $00, $59
    db $16, $00, $21, $00, $00, $39, $19, $5d
    db $54, $21, $b5, $5d, $06, $00, $09, $7e
    db $12, $0c, $79, $d6, $0f, $38, $e8, $f8
    db $11, $7e, $3d, $20, $04, $f8, $00, $36
    db $3e, $21, $0b, $58, $e5, $21, $02, $00
    db $39, $e5, $cd, $c4, $5d, $e8, $04, $cd
    db $2a, $5e, $e8, $0f, $c9, $20, $20, $53
    db $74, $61, $72, $74, $00, $20, $20, $4d
    db $61, $6e, $61, $67, $65, $20, $73, $61
    db $76, $65, $73, $00, $e8, $e7, $f0, $fb
    db $b7, $20, $17, $f8, $1d, $3a, $2b, $57
    db $1e, $01, $d5, $3e, $12, $f5, $33, $2a
    db $5f, $56, $d5, $cd, $b7, $08, $e8, $05
    db $18, $45, $f8, $18, $36, $00, $f8, $18
    db $5e, $16, $00, $21, $00, $00, $39, $19
    db $5d, $54, $f8, $18, $7e, $d6, $17, $30
    db $19, $f8, $1b, $7e, $f8, $18, $86, $23
    db $23, $23, $23, $4f, $7e, $ce, $00, $47
    db $0a, $b7, $28, $06, $12, $f8, $18, $34
    db $18, $d4, $af, $12, $f8, $1e, $66, $2e
    db $01, $e5, $af, $f5, $33, $21, $03, $00
    db $39, $e5, $cd, $c0, $05, $e8, $05, $e8
    db $19, $c9, $af, $0f, $f5, $af, $3e, $03
    db $f5, $33, $cd, $d8, $23, $e8, $03, $f0
    db $fb, $b7, $28, $12, $21, $77, $00, $e5
    db $21, $24, $9f, $e5, $af, $f5, $33, $cd
    db $01, $24, $e8, $05, $18, $10, $21, $73
    db $00, $e5, $21, $23, $9f, $e5, $af, $f5
    db $33, $cd, $01, $24, $e8, $05, $af, $67
    db $2e, $03, $e5, $3e, $03, $f5, $33, $cd
    db $d8, $23, $e8, $03, $f0, $fb, $b7, $28
    db $23, $21, $65, $01, $e5, $21, $65, $9f
    db $e5, $af, $f5, $33, $cd, $01, $24, $e8
    db $05, $21, $77, $01, $e5, $21, $65, $4f
    db $e5, $3e, $4f, $f5, $33, $cd, $01, $24
    db $e8, $05, $18, $21, $21, $63, $01, $e5
    db $21, $63, $9f, $e5, $af, $f5, $33, $cd
    db $01, $24, $e8, $05, $21, $73, $01, $e5
    db $21, $63, $53, $e5, $3e, $53, $f5, $33
    db $cd, $01, $24, $e8, $05, $af, $0f, $f5
    db $af, $3e, $03, $f5, $33, $cd, $d8, $23
    db $e8, $03, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

FarCallEzCfg::
    db $cd, $8d, $07, $00, $4a, $02, $00, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

RtcSetHook::
    db $3e, $06, $ea, $fc, $db, $cd, $00, $5f
    db $c3, $f5, $48

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

SetLoopTickHook::
    db $3e, $05, $f5, $33, $01, $00, $00, $c5
    db $cd, $00, $66, $e8, $03, $c3, $91, $36

FlSetADispatch::
    db $f8, $3d, $7e, $fe, $02, $ca, $c7, $58
    db $f8, $00, $4d, $44, $3e, $02, $f5, $33
    db $c5, $cd, $00, $66, $e8, $03, $7b, $b7
    db $ca, $f5, $48, $3d, $ca, $03, $59, $e8
    db $6a, $c3, $f4, $46

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

SetBtnTopHL::
    db $21, $0d, $9b, $f0, $fb, $b7, $c8, $f8
    db $02, $36, $1c, $21, $0f, $9b, $c9

    rst RST_38

FarCallMenuTabs::
    db $f8, $02, $7e, $f5, $33, $cd, $8d, $07
    db $69, $71, $08, $00, $33, $c9

    rst RST_38
    rst RST_38

FlSetJumpTop::
    db $f8, $3d, $7e, $b7, $ca, $f5, $48, $36
    db $00, $23, $36, $01, $c3, $48, $59

    rst RST_38

FlSetJumpBottom::
    db $f8, $3d, $7e, $fe, $07, $ca, $f5, $48
    db $36, $07, $23, $36, $01, $c3, $48, $59

AutosaveSetHook::
    db $3e, $09, $ea, $fc, $db, $cd, $00, $5f
    db $c3, $f5, $48

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

BkPrompt::
    db $e8, $e9, $f8, $1d, $7e, $b7, $c2, $4d
    db $61, $0f, $f5, $af, $f5, $33, $cd, $d8
    db $23, $e8, $03, $21, $6b, $01, $e5, $21
    db $20, $9f, $e5, $af, $f5, $33, $cd, $01
    db $24, $e8, $05, $af, $0f, $f5, $af, $3e
    db $03, $f5, $33, $cd, $d8, $23, $e8, $03
    db $f0, $fb, $b7, $28, $12, $21, $67, $01
    db $e5, $21, $24, $9f, $e5, $af, $f5, $33
    db $cd, $01, $24, $e8, $05, $18, $10, $21
    db $63, $01, $e5, $21, $23, $9f, $e5, $af
    db $f5, $33, $cd, $01, $24, $e8, $05, $21
    db $05, $28, $e5, $11, $c4, $62, $d5, $cd
    db $28, $63, $e8, $04, $cd, $8e, $63, $af
    db $67, $2e, $03, $e5, $3e, $03, $f5, $33
    db $cd, $d8, $23, $e8, $03, $f0, $fb, $b7
    db $28, $12, $21, $45, $01, $e5, $21, $35
    db $9f, $e5, $af, $f5, $33, $cd, $01, $24
    db $e8, $05, $18, $10, $21, $43, $01, $e5
    db $21, $33, $9f, $e5, $af, $f5, $33, $cd
    db $01, $24, $e8, $05, $f8, $00, $3e, $a5
    db $22, $36, $c3, $11, $a5, $c3, $1a, $f8
    db $16, $77, $7e, $b7, $28, $0a, $13, $7e
    db $d6, $2f, $20, $f2, $e1, $d5, $18, $ee
    db $21, $3f, $db, $36, $01, $d1, $d5, $d5
    db $cd, $68, $03, $e1, $fa, $47, $db, $b7
    db $ca, $c1, $62, $0e, $00, $79, $c6, $10
    db $5f, $3e, $00, $ce, $db, $57, $21, $d2
    db $62, $06, $00, $09, $7e, $12, $0c, $79
    db $d6, $14, $38, $e9, $21, $45, $db, $4e
    db $cb, $61, $28, $04, $79, $c6, $fa, $4f
    db $79, $87, $81, $c6, $fd, $c6, $e6, $4f
    db $3e, $00, $ce, $62, $47, $0a, $ea, $17
    db $db, $69, $60, $23, $7e, $21, $18, $db
    db $77, $03, $03, $0a, $2e, $19, $77, $1e
    db $0b, $01, $43, $db, $7b, $d6, $14, $30
    db $24, $21, $10, $db, $16, $00, $19, $0a
    db $cb, $37, $e6, $0f, $c6, $30, $77, $7b
    db $3c, $c6, $10, $6f, $3e, $00, $ce, $db
    db $67, $0a, $e6, $0f, $c6, $30, $77, $0b
    db $1c, $1c, $1c, $18, $d7, $21, $3f, $db
    db $36, $02, $11, $10, $db, $d5, $cd, $68
    db $03, $e1, $c3, $c1, $62, $f8, $1d, $7e
    db $d6, $03, $c2, $e6, $61, $21, $3e, $db
    db $4e, $0c, $21, $3e, $db, $71, $79, $e6
    db $07, $c2, $c1, $62, $79, $cb, $37, $07
    db $e6, $03, $4f, $b7, $20, $0a, $fa, $3e
    db $db, $c6, $08, $ea, $3e, $db, $0e, $01
    db $06, $00, $58, $16, $00, $21, $02, $00
    db $39, $19, $3e, $1e, $80, $5f, $3e, $63
    db $ce, $00, $57, $1a, $77, $04, $78, $d6
    db $06, $38, $e7, $f8, $16, $36, $06, $41
    db $0d, $f8, $16, $5e, $16, $00, $21, $02
    db $00, $39, $19, $5d, $54, $78, $b7, $28
    db $08, $f8, $16, $34, $3e, $2e, $12, $18
    db $e6, $af, $12, $0f, $f5, $af, $3e, $03
    db $f5, $33, $cd, $d8, $23, $e8, $03, $21
    db $02, $00, $39, $11, $0b, $58, $d5, $e5
    db $cd, $28, $63, $e8, $04, $f0, $fb, $b7
    db $ca, $c1, $62, $21, $67, $00, $e5, $21
    db $24, $9f, $e5, $af, $f5, $33, $cd, $01
    db $24, $e8, $05, $c3, $c1, $62, $af, $0f
    db $f5, $af, $f5, $33, $cd, $d8, $23, $e8
    db $03, $f0, $fb, $b7, $28, $13, $21, $66
    db $01, $e5, $21, $56, $9e, $e5, $3e, $01
    db $f5, $33, $cd, $01, $24, $e8, $05, $18
    db $11, $21, $62, $01, $e5, $21, $54, $9e
    db $e5, $3e, $01, $f5, $33, $cd, $01, $24
    db $e8, $05, $af, $0f, $f5, $af, $3e, $03
    db $f5, $33, $cd, $d8, $23, $e8, $03, $f8
    db $1d, $7e, $d6, $02, $20, $24, $21, $3e
    db $db, $36, $00, $21, $0b, $58, $e5, $11
    db $1e, $63, $d5, $cd, $28, $63, $e8, $04
    db $cd, $8e, $63, $af, $0f, $f5, $af, $3e
    db $03, $f5, $33, $cd, $d8, $23, $e8, $03
    db $18, $6f, $f0, $fb, $b7, $28, $0f, $21
    db $0b, $58, $e5, $11, $0a, $63, $d5, $cd
    db $28, $63, $e8, $04, $18, $22, $01, $0a
    db $63, $21, $01, $0b, $e5, $3e, $07, $f5
    db $33, $c5, $cd, $b7, $08, $e8, $05, $21
    db $0b, $0b, $e5, $3e, $07, $f5, $33, $11
    db $16, $63, $d5, $cd, $b7, $08, $e8, $05
    db $cd, $8e, $63, $f0, $fb, $b7, $28, $13
    db $21, $67, $01, $e5, $21, $55, $4f, $e5
    db $3e, $4f, $f5, $33, $cd, $01, $24, $e8
    db $05, $18, $11, $21, $63, $01, $e5, $21
    db $53, $53, $e5, $3e, $53, $f5, $33, $cd
    db $01, $24, $e8, $05, $af, $0f, $f5, $af
    db $3e, $03, $f5, $33, $cd, $d8, $23, $e8
    db $03, $e8, $17, $c9, $42, $61, $63, $6b
    db $20, $75, $70, $20, $73, $61, $76, $65
    db $3f, $00, $50, $6c, $61, $79, $65, $64
    db $20, $4d, $6d, $6d, $20, $64, $64, $20
    db $68, $68, $3a, $6d, $6d, $00, $4a, $61
    db $6e, $46, $65, $62, $4d, $61, $72, $41
    db $70, $72, $4d, $61, $79, $4a, $75, $6e
    db $4a, $75, $6c, $41, $75, $67, $53, $65
    db $70, $4f, $63, $74, $4e, $6f, $76, $44
    db $65, $63, $5b, $42, $5d, $73, $6b, $69
    db $70, $20, $20, $20, $20, $20, $5b, $41
    db $5d, $73, $61, $76, $65, $00, $53, $61
    db $76, $69, $6e, $67, $2e, $2e, $2e, $00
    db $e8, $e7, $f0, $fb, $b7, $20, $17, $f8
    db $1d, $3a, $2b, $57, $1e, $01, $d5, $3e
    db $12, $f5, $33, $2a, $5f, $56, $d5, $cd
    db $b7, $08, $e8, $05, $18, $45, $f8, $18
    db $36, $00, $f8, $18, $5e, $16, $00, $21
    db $00, $00, $39, $19, $5d, $54, $f8, $18
    db $7e, $d6, $17, $30, $19, $f8, $1b, $7e
    db $f8, $18, $86, $23, $23, $23, $23, $4f
    db $7e, $ce, $00, $47, $0a, $b7, $28, $06
    db $12, $f8, $18, $34, $18, $d4, $af, $12
    db $f8, $1e, $66, $2e, $01, $e5, $af, $f5
    db $33, $21, $03, $00, $39, $e5, $cd, $c0
    db $05, $e8, $05, $e8, $19, $c9, $af, $0f
    db $f5, $af, $3e, $03, $f5, $33, $cd, $d8
    db $23, $e8, $03, $f0, $fb, $b7, $28, $12
    db $21, $67, $00, $e5, $21, $24, $9f, $e5
    db $af, $f5, $33, $cd, $01, $24, $e8, $05
    db $18, $10, $21, $63, $00, $e5, $21, $23
    db $9f, $e5, $af, $f5, $33, $cd, $01, $24
    db $e8, $05, $af, $67, $2e, $03, $e5, $3e
    db $03, $f5, $33, $cd, $d8, $23, $e8, $03
    db $f0, $fb, $b7, $28, $11, $21, $55, $01
    db $e5, $21, $55, $9f, $e5, $af, $f5, $33
    db $cd, $01, $24, $e8, $05, $c9, $21, $53
    db $01, $e5, $21, $53, $9f, $e5, $af, $f5
    db $33, $cd, $01, $24, $e8, $05, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

SetText::
    db $e8, $e5, $f0, $fb, $4f, $b7, $20, $17
    db $f8, $21, $3a, $57, $3a, $5f, $d5, $3a
    db $2b, $f5, $33, $2a, $5f, $56, $d5, $cd
    db $b7, $08, $e8, $05, $c3, $49, $65, $f8
    db $18, $af, $22, $36, $80, $f8, $21, $7e
    db $d6, $02, $28, $27, $f8, $21, $7e, $d6
    db $04, $28, $36, $f8, $21, $7e, $d6, $06
    db $28, $4d, $f8, $21, $7e, $d6, $0c, $28
    db $6b, $f8, $21, $7e, $d6, $0e, $28, $79
    db $f8, $21, $7e, $d6, $10, $ca, $d6, $64
    db $c3, $e3, $64, $f8, $20, $7e, $b7, $28
    db $0a, $f8, $18, $3e, $7f, $22, $36, $9b
    db $c3, $e3, $64, $f8, $19, $36, $78, $18
    db $7a, $01, $4c, $65, $79, $f8, $20, $86
    db $5f, $78, $ce, $00, $57, $1a, $f8, $18
    db $77, $f8, $20, $3a, $86, $6f, $26, $00
    db $09, $7e, $f8, $19, $77, $18, $5c, $f8
    db $20, $7e, $b7, $20, $06, $f8, $19, $36
    db $2c, $18, $50, $f8, $20, $7e, $d6, $06
    db $20, $09, $f8, $18, $3e, $2c, $22, $36
    db $42, $18, $40, $f8, $18, $3e, $56, $22
    db $36, $82, $18, $37, $f8, $20, $7e, $b7
    db $28, $09, $f8, $18, $3e, $58, $22, $36
    db $9b, $18, $28, $f8, $19, $36, $50, $18
    db $22, $f8, $20, $7e, $b7, $28, $09, $f8
    db $18, $3e, $78, $22, $36, $9b, $18, $13
    db $f8, $19, $36, $70, $18, $0d, $f8, $20
    db $7e, $b7, $28, $07, $f8, $18, $3e, $78
    db $22, $36, $9b, $f8, $1f, $7e, $b7, $28
    db $05, $3e, $17, $96, $30, $04, $f8, $1f
    db $36, $17, $f8, $1a, $36, $00, $f8, $1a
    db $5e, $16, $00, $21, $00, $00, $39, $19
    db $4d, $44, $f8, $1a, $7e, $f8, $1f, $96
    db $30, $19, $2b, $2b, $7e, $f8, $1a, $86
    db $23, $23, $23, $23, $5f, $7e, $ce, $00
    db $57, $1a, $b7, $28, $06, $02, $f8, $1a
    db $34, $18, $d3, $af, $02, $f8, $19, $7e
    db $e0, $f9, $f8, $21, $7e, $87, $87, $87
    db $c6, $02, $21, $00, $00, $39, $4d, $44
    db $f5, $33, $f8, $19, $66, $2e, $00, $e5
    db $c5, $cd, $c0, $05, $e8, $05, $af, $e0
    db $f9, $e8, $1b, $c9, $00, $09, $12, $1b
    db $24, $2c, $35, $3e, $46, $4f, $58, $5e
    db $67, $70, $76, $7f, $88, $8e, $97, $a0

    rst RST_38
    rst RST_38

SmSaveOp::
    db $f8, $02, $2a, $66, $6f, $e5, $cd, $8d
    db $07, $70, $76, $01, $00, $e8, $02, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

FlCfg::
    db $f8, $02, $2a, $c6, $3d, $4f, $2a, $ce
    db $00, $47, $7e, $b7, $20, $58, $21, $fe
    db $db, $36, $00, $2e, $38, $6e, $2c, $20
    db $26, $3e, $06, $02, $c5, $21, $9b, $19
    db $e5, $21, $7b, $0d, $e5, $af, $f5, $33
    db $cd, $6a, $6b, $e8, $05, $21, $10, $02
    db $e5, $3e, $03, $f5, $33, $11, $9f, $67
    db $d5, $cd, $00, $64, $e8, $05, $c1, $21
    db $38, $db, $36, $00, $2e, $39, $36, $00
    db $f0, $fa, $2e, $3b, $77, $c5, $cd, $a3
    db $67, $cd, $ee, $68, $c1, $0a, $f5, $33
    db $cd, $b0, $6b, $33, $af, $f5, $33, $cd
    db $6e, $46, $33, $1e, $00, $c9, $f8, $04
    db $7e, $3d, $20, $0a, $0a, $f5, $33, $cd
    db $b0, $6b, $33, $1e, $00, $c9, $f8, $04
    db $7e, $d6, $02, $c2, $49, $67, $0a, $6f
    db $45, $78, $d6, $03, $3e, $01, $28, $01
    db $af, $4f, $78, $d6, $05, $3e, $01, $28
    db $01, $af, $5f, $79, $b7, $20, $08, $78
    db $3d, $28, $04, $7b, $b7, $28, $46, $7b
    db $b7, $28, $0a, $3e, $02, $f5, $33, $cd
    db $70, $76, $33, $18, $2b, $79, $b7, $28
    db $10, $fa, $80, $da, $b7, $28, $03, $af
    db $18, $02, $3e, $01, $ea, $80, $da, $18
    db $0e, $fa, $3a, $db, $b7, $28, $03, $af
    db $18, $02, $3e, $01, $ea, $3a, $db, $c5
    db $cd, $ab, $67, $33, $cd, $b0, $6b, $33
    db $cd, $e6, $68, $af, $f5, $33, $cd, $6e
    db $46, $33, $1e, $00, $c9, $7d, $d6, $07
    db $20, $26, $fa, $f8, $db, $b7, $28, $03
    db $1e, $00, $c9, $cd, $78, $68, $7b, $d6
    db $01, $3e, $00, $17, $f5, $33, $cd, $b7
    db $68, $33, $3e, $07, $f5, $33, $cd, $b0
    db $6b, $33, $cd, $e6, $68, $1e, $00, $c9
    db $7d, $d6, $06, $20, $29, $f0, $fb, $b7
    db $28, $03, $af, $18, $02, $3e, $01, $e0
    db $fb, $cd, $ab, $67, $3e, $01, $f5, $33
    db $cd, $70, $5f, $33, $cd, $e6, $68, $af
    db $f5, $33, $cd, $6e, $46, $33, $21, $38
    db $db, $36, $ff, $1e, $02, $c9, $21, $fe
    db $db, $36, $01, $cd, $e6, $68, $1e, $01
    db $c9, $f8, $04, $7e, $d6, $03, $20, $06
    db $cd, $b3, $67, $1e, $00, $c9, $f8, $04
    db $7e, $d6, $05, $20, $3c, $f0, $fa, $4f
    db $21, $3b, $db, $96, $21, $3b, $db, $71
    db $fe, $65, $38, $02, $3e, $64, $21, $39
    db $db, $86, $21, $39, $db, $77, $fa, $39
    db $db, $2e, $38, $4e, $0c, $0d, $0e, $3c
    db $28, $02, $0e, $14, $91, $38, $0f, $21
    db $39, $db, $36, $00, $fa, $38, $db, $3c
    db $2e, $38, $77, $cd, $8d, $69, $1e, $00
    db $c9, $cd, $a3, $67, $1e, $00, $c9, $53
    db $45, $54, $00, $21, $fc, $db, $36, $00
    db $c3, $00, $5f, $21, $fc, $db, $36, $01
    db $c3, $00, $5f, $e8, $fb, $cd, $a3, $67
    db $0e, $00, $69, $26, $00, $11, $a6, $c2
    db $19, $7e, $b7, $28, $03, $0c, $18, $f2
    db $f8, $00, $71, $0e, $00, $69, $26, $00
    db $11, $a4, $c4, $19, $7e, $b7, $28, $03
    db $0c, $18, $f2, $f8, $01, $79, $32, $7e
    db $81, $4f, $7e, $b7, $28, $0d, $5e, $af
    db $57, $1b, $21, $a6, $c2, $19, $7e, $fe
    db $2f, $28, $01, $0c, $3e, $78, $91, $38
    db $74, $0e, $00, $f8, $04, $36, $00, $f8
    db $04, $7e, $f8, $00, $96, $30, $21, $23
    db $23, $79, $c6, $82, $22, $3e, $00, $ce
    db $da, $22, $0c, $3a, $2b, $c6, $a6, $5f
    db $3e, $00, $ce, $c2, $57, $1a, $5e, $23
    db $66, $6b, $77, $f8, $04, $34, $18, $d7
    db $41, $79, $b7, $28, $0d, $af, $59, $57
    db $1b, $21, $82, $da, $19, $7e, $fe, $2f
    db $28, $0a, $68, $04, $26, $00, $11, $82
    db $da, $19, $36, $2f, $0e, $00, $78, $c6
    db $82, $5f, $3e, $00, $ce, $da, $57, $79
    db $f8, $01, $96, $30, $0f, $04, $79, $c6
    db $a4, $6f, $3e, $00, $ce, $c4, $67, $7e
    db $12, $0c, $18, $e2, $af, $12, $21, $81
    db $da, $70, $cd, $ab, $67, $21, $fe, $db
    db $36, $00, $cd, $e6, $68, $e8, $05, $c9
    db $21, $00, $40, $36, $11, $3e, $03, $f5
    db $33, $cd, $6e, $46, $33, $fa, $00, $a4
    db $fe, $53, $20, $15, $fa, $01, $a4, $fe
    db $47, $20, $0e, $21, $02, $a4, $4e, $0d
    db $20, $07, $fa, $03, $a4, $fe, $fe, $28
    db $04, $0e, $00, $18, $02, $0e, $01, $21
    db $00, $40, $36, $00, $c5, $af, $f5, $33
    db $cd, $6e, $46, $33, $c1, $59, $c9, $21
    db $00, $40, $36, $11, $3e, $03, $f5, $33
    db $cd, $6e, $46, $33, $21, $00, $a4, $36
    db $53, $2e, $01, $36, $47, $11, $02, $a4
    db $f8, $02, $7e, $12, $7e, $2f, $ea, $03
    db $a4, $21, $00, $40, $36, $00, $af, $f5
    db $33, $cd, $6e, $46, $33, $c9, $cd, $91
    db $36, $cb, $63, $20, $f9, $c9, $af, $0f
    db $f5, $af, $3e, $03, $f5, $33, $cd, $d8
    db $23, $e8, $03, $3e, $06, $f5, $33, $21
    db $04, $00, $e5, $11, $64, $69, $d5, $cd
    db $00, $64, $e8, $05, $21, $06, $06, $e5
    db $3e, $02, $f5, $33, $11, $69, $69, $d5
    db $cd, $00, $64, $e8, $05, $21, $0b, $06
    db $e5, $3e, $05, $f5, $33, $11, $6c, $69
    db $d5, $cd, $00, $64, $e8, $05, $3e, $0a
    db $f5, $33, $21, $0c, $00, $e5, $11, $72
    db $69, $d5, $cd, $00, $64, $e8, $05, $3e
    db $0e, $f5, $33, $21, $03, $00, $e5, $11
    db $7f, $69, $d5, $cd, $00, $64, $e8, $05
    db $3e, $10, $f5, $33, $21, $09, $00, $e5
    db $11, $83, $69, $d5, $cd, $00, $64, $e8
    db $05, $c3, $8d, $69, $52, $54, $43, $3a
    db $00, $53, $44, $00, $4e, $4f, $20, $53
    db $44, $00, $46, $41, $53, $54, $20, $4c
    db $41, $55, $4e, $43, $48, $3a, $00, $55
    db $49, $3a, $00, $53, $47, $42, $20, $42
    db $4f, $4f, $54, $3a, $00, $e8, $f9, $fa
    db $81, $da, $b7, $20, $09, $f8, $00, $36
    db $c7, $23, $36, $6a, $18, $23, $0e, $00
    db $59, $21, $82, $da, $16, $00, $19, $7e
    db $b7, $28, $09, $fe, $2f, $20, $02, $4b
    db $0c, $1c, $18, $ed, $79, $c6, $82, $f5
    db $f8, $02, $f1, $22, $3e, $00, $ce, $da
    db $77, $0e, $00, $f8, $00, $2a, $81, $5f
    db $7e, $ce, $00, $57, $1a, $b7, $28, $03
    db $0c, $18, $f0, $f8, $02, $71, $3e, $0a
    db $91, $38, $41, $f0, $fb, $b7, $28, $05
    db $79, $d6, $0a, $28, $37, $21, $38, $db
    db $36, $00, $0e, $00, $79, $c6, $10, $f5
    db $f8, $07, $f1, $22, $3e, $00, $ce, $db
    db $77, $79, $f8, $02, $96, $30, $0c, $2b
    db $2b, $2a, $81, $5f, $7e, $ce, $00, $57
    db $1a, $18, $01, $af, $f8, $05, $5e, $23
    db $66, $6b, $77, $0c, $79, $d6, $0a, $38
    db $d3, $c3, $a8, $6a, $21, $38, $db, $4e
    db $f8, $02, $2a, $5f, $16, $00, $13, $13
    db $13, $7b, $22, $7a, $32, $06, $00, $79
    db $96, $23, $78, $9e, $50, $cb, $7e, $28
    db $07, $cb, $7a, $20, $08, $bf, $18, $05
    db $cb, $7a, $28, $01, $37, $38, $05, $21
    db $38, $db, $36, $00, $fa, $38, $db, $f8
    db $05, $77, $f8, $06, $36, $00, $f8, $06
    db $3a, $c6, $10, $5f, $3e, $00, $ce, $db
    db $57, $7e, $f8, $02, $96, $30, $12, $2b
    db $2b, $7e, $f8, $05, $86, $2b, $2b, $2b
    db $2b, $4f, $7e, $ce, $00, $47, $0a, $18
    db $02, $3e, $20, $12, $f8, $05, $34, $3a
    db $2b, $4f, $06, $00, $79, $96, $23, $78
    db $9e, $50, $cb, $7e, $28, $07, $cb, $7a
    db $20, $08, $bf, $18, $05, $cb, $7a, $28
    db $01, $37, $38, $04, $f8, $05, $36, $00
    db $f8, $06, $34, $7e, $d6, $0a, $38, $ae
    db $af, $0f, $f5, $af, $3e, $03, $f5, $33
    db $cd, $d8, $23, $e8, $03, $3e, $0c, $f5
    db $33, $21, $0a, $00, $e5, $11, $10, $db
    db $d5, $cd, $00, $64, $e8, $0c, $c9, $28
    db $41, $55, $54, $4f, $29, $00, $af, $0f
    db $f5, $af, $f5, $33, $cd, $d8, $23, $e8
    db $03, $f8, $03, $3a, $4f, $c6, $08, $5f
    db $2a, $47, $c6, $08, $57, $c5, $d5, $3e
    db $01, $f5, $33, $7b, $f5, $33, $d5, $33
    db $3a, $57, $5e, $d5, $cd, $01, $24, $e8
    db $05, $d1, $c1, $f8, $05, $7e, $b7, $28
    db $14, $c5, $d5, $af, $67, $2e, $01, $e5
    db $3e, $01, $f5, $33, $cd, $d8, $23, $e8
    db $03, $d1, $c1, $18, $11, $c5, $d5, $af
    db $0f, $f5, $af, $3e, $03, $f5, $33, $cd
    db $d8, $23, $e8, $03, $d1, $c1, $c5, $af
    db $f5, $33, $7b, $f5, $33, $d5, $33, $f8
    db $08, $3a, $57, $5e, $d5, $cd, $01, $24
    db $e8, $05, $c1, $f8, $04, $7e, $b7, $c8
    db $c5, $af, $67, $2e, $03, $e5, $3e, $03
    db $f5, $33, $cd, $d8, $23, $e8, $03, $c1
    db $79, $c6, $06, $57, $78, $c6, $06, $0c
    db $0c, $58, $1c, $1c, $26, $01, $6a, $e5
    db $f5, $33, $51, $d5, $cd, $01, $24, $e8
    db $05, $c9, $f8, $02, $7e, $b7, $28, $0e
    db $21, $03, $00, $e5, $af, $f5, $33, $cd
    db $d8, $23, $e8, $03, $18, $0d, $af, $0f
    db $f5, $af, $3e, $03, $f5, $33, $cd, $d8
    db $23, $e8, $03, $f0, $fb, $b7, $28, $0b
    db $f8, $04, $7e, $c6, $02, $22, $23, $7e
    db $c6, $03, $77, $3e, $01, $f5, $33, $f8
    db $07, $3a, $57, $3a, $5f, $d5, $3a, $57
    db $5e, $d5, $cd, $01, $24, $e8, $05, $c9
    db $f8, $02, $7e, $3d, $3e, $01, $28, $01
    db $af, $47, $fa, $3a, $db, $d6, $01, $3e
    db $00, $17, $c5, $c5, $33, $67, $2e, $30
    db $e5, $3e, $42, $f5, $33, $cd, $ce, $6a
    db $e8, $04, $fa, $3a, $db, $33, $67, $2e
    db $30, $e5, $3e, $82, $f5, $33, $cd, $ce
    db $6a, $e8, $04, $f8, $02, $7e, $d6, $03
    db $3e, $01, $28, $01, $af, $21, $80, $da
    db $46, $f5, $33, $c5, $33, $21, $82, $50
    db $e5, $cd, $ce, $6a, $e8, $04, $21, $f8
    db $db, $4e, $f8, $02, $7e, $d6, $07, $3e
    db $01, $28, $01, $af, $47, $79, $b7, $28
    db $32, $78, $b7, $28, $0e, $21, $03, $00
    db $e5, $af, $f5, $33, $cd, $d8, $23, $e8
    db $03, $18, $0d, $af, $0f, $f5, $af, $3e
    db $03, $f5, $33, $cd, $d8, $23, $e8, $03
    db $21, $0f, $10, $e5, $3e, $04, $f5, $33
    db $11, $f5, $6c, $d5, $cd, $00, $64, $e8
    db $05, $18, $13, $c5, $cd, $78, $68, $7b
    db $33, $67, $2e, $80, $e5, $3e, $82, $f5
    db $33, $cd, $ce, $6a, $e8, $04, $f8, $02
    db $7e, $d6, $04, $3e, $01, $28, $01, $af
    db $26, $69, $e5, $33, $26, $9b, $e5, $33
    db $26, $5d, $e5, $33, $26, $53, $e5, $33
    db $f5, $33, $cd, $6a, $6b, $e8, $05, $21
    db $0b, $0c, $e5, $3e, $08, $f5, $33, $11
    db $e2, $6c, $d5, $cd, $00, $64, $e8, $05
    db $f8, $02, $7e, $d6, $05, $3e, $01, $28
    db $01, $af, $f5, $33, $cd, $70, $76, $33
    db $f8, $02, $7e, $d6, $06, $3e, $01, $28
    db $01, $af, $26, $79, $e5, $33, $26, $9b
    db $e5, $33, $26, $6d, $e5, $33, $26, $73
    db $e5, $33, $f5, $33, $cd, $6a, $6b, $e8
    db $05, $f0, $fb, $b7, $28, $05, $01, $f0
    db $6c, $18, $03, $01, $eb, $6c, $21, $0f
    db $0e, $e5, $3e, $04, $f5, $33, $c5, $cd
    db $00, $64, $e8, $05, $af, $0f, $f5, $af
    db $3e, $03, $f5, $33, $cd, $d8, $23, $e8
    db $03, $c9, $50, $49, $43, $4b, $20, $52
    db $4f, $4d, $00, $20, $38, $70, $78, $00
    db $31, $32, $70, $78, $00, $41, $55, $54
    db $4f, $00

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

ManageSaves::
    db $e8, $fa, $af, $0f, $f5, $cd, $62, $65
    db $e1, $cd, $9e, $6f, $11, $c6, $6e, $d5
    db $cd, $88, $71, $e1, $af, $f5, $33, $cd
    db $a7, $71, $33, $f8, $05, $36, $00, $f8
    db $01, $36, $00, $f0, $fb, $b7, $3e, $04
    db $20, $02, $3e, $06, $f8, $02, $77, $af
    db $0f, $f5, $af, $f5, $33, $cd, $33, $70
    db $e8, $03, $f8, $00, $36, $ff, $f8, $00
    db $e5, $cd, $07, $6f, $e1, $f8, $04, $73
    db $7e, $e6, $20, $c2, $91, $6e, $f8, $04
    db $7e, $e6, $0c, $28, $65, $f8, $04, $7e
    db $e6, $04, $28, $08, $f8, $05, $7e, $b7
    db $28, $02, $35, $7e, $f8, $04, $7e, $e6
    db $08, $28, $0b, $21, $77, $d7, $4e, $f8
    db $05, $7e, $91, $30, $01, $34, $f8, $05
    db $7e, $f8, $01, $96, $30, $06, $f8, $05
    db $7e, $f8, $01, $77, $f8, $01, $2a, $4f
    db $06, $00, $5e, $16, $00, $7b, $81, $4f
    db $7a, $88, $47, $f8, $05, $3a, $2b, $22
    db $af, $32, $2a, $91, $7e, $98, $38, $08
    db $23, $7e, $f8, $02, $96, $2b, $3c, $77
    db $f8, $01, $7e, $f5, $33, $f8, $06, $66
    db $2e, $00, $e5, $cd, $33, $70, $e8, $03
    db $18, $84, $f8, $04, $7e, $e6, $10, $ca
    db $4f, $6d, $f8, $05, $4e, $0d, $7e, $b7
    db $20, $0b, $fa, $70, $d7, $b7, $ca, $4f
    db $6d, $06, $01, $18, $5d, $c5, $79, $f5
    db $33, $cd, $3b, $6f, $33, $7b, $c1, $47
    db $b7, $28, $2c, $d6, $02, $20, $05, $11
    db $cc, $6e, $18, $03, $11, $df, $6e, $c5
    db $d5, $cd, $88, $71, $e1, $3e, $01, $f5
    db $33, $cd, $a7, $71, $33, $cd, $1f, $6f
    db $7b, $c1, $b7, $20, $01, $47, $c5, $af
    db $f5, $33, $cd, $a7, $71, $33, $c1, $78
    db $b7, $20, $1f, $11, $c6, $6e, $d5, $cd
    db $88, $71, $e1, $f8, $01, $7e, $f5, $33
    db $f8, $06, $66, $2e, $00, $e5, $cd, $33
    db $70, $e8, $03, $f8, $00, $36, $ff, $c3
    db $4f, $6d, $c5, $11, $f1, $6e, $d5, $cd
    db $88, $71, $e1, $cd, $62, $65, $e1, $d5
    db $af, $0f, $f5, $cd, $62, $65, $e1, $d1
    db $7b, $b7, $28, $09, $f8, $04, $36, $fc
    db $23, $36, $6e, $18, $07, $f8, $04, $36
    db $01, $23, $36, $6f, $f8, $04, $2a, $4f
    db $46, $c5, $cd, $88, $71, $e1, $f8, $05
    db $36, $00, $f8, $01, $36, $00, $af, $0f
    db $f5, $af, $f5, $33, $cd, $33, $70, $e8
    db $03, $f8, $00, $36, $ff, $c3, $4f, $6d
    db $af, $0f, $f5, $af, $f5, $33, $cd, $d8
    db $23, $e8, $03, $21, $8f, $01, $e5, $21
    db $20, $9f, $e5, $af, $f5, $33, $cd, $01
    db $24, $e8, $05, $af, $0f, $f5, $af, $3e
    db $03, $f5, $33, $cd, $d8, $23, $e8, $03
    db $f8, $08, $4e, $06, $05, $c5, $cd, $62
    db $65, $e1, $e8, $06, $c9, $53, $61, $76
    db $65, $73, $00, $52, $65, $73, $74, $6f
    db $72, $65, $20, $74, $68, $69, $73, $20
    db $73, $61, $76, $65, $3f, $00, $44, $65
    db $6c, $65, $74, $65, $20, $74, $68, $69
    db $73, $20, $73, $61, $76, $65, $3f, $00
    db $57, $6f, $72, $6b, $69, $6e, $67, $2e
    db $2e, $2e, $00, $44, $6f, $6e, $65, $00
    db $45, $72, $72, $6f, $72, $00, $f0, $fa
    db $4f, $f0, $fa, $91, $28, $fb, $cd, $70
    db $03, $53, $f8, $02, $2a, $4f, $46, $0a
    db $2f, $a2, $5f, $7a, $02, $c9, $3b, $f8
    db $00, $36, $ff, $f8, $00, $e5, $cd, $07
    db $6f, $e1, $cb, $63, $28, $04, $1e, $01
    db $18, $06, $cb, $6b, $28, $ed, $1e, $00
    db $33, $c9, $3b, $f8, $00, $36, $ff, $06
    db $00, $f8, $03, $5e, $16, $04, $c5, $d5
    db $cd, $62, $65, $e1, $11, $50, $d7, $d5
    db $cd, $88, $71, $e1, $af, $0f, $f5, $af
    db $3e, $01, $f5, $33, $cd, $33, $70, $e8
    db $03, $c1, $f8, $00, $c5, $e5, $cd, $07
    db $6f, $e1, $7b, $c1, $cb, $6f, $28, $04
    db $1e, $00, $18, $27, $cb, $67, $28, $0c
    db $78, $b7, $28, $04, $1e, $03, $18, $1b
    db $1e, $02, $18, $17, $e6, $0c, $28, $da
    db $78, $ee, $01, $47, $c5, $af, $f5, $33
    db $0e, $01, $c5, $cd, $33, $70, $e8, $03
    db $c1, $18, $c7, $33, $c9, $af, $0f, $f5
    db $af, $f5, $33, $cd, $d8, $23, $e8, $03
    db $21, $8f, $01, $e5, $21, $20, $9f, $e5
    db $af, $f5, $33, $cd, $01, $24, $e8, $05
    db $af, $0f, $f5, $af, $3e, $03, $f5, $33
    db $cd, $d8, $23, $e8, $03, $f0, $fb, $b7
    db $28, $12, $21, $8f, $01, $e5, $21, $24
    db $9f, $e5, $af, $f5, $33, $cd, $01, $24
    db $e8, $05, $18, $10, $21, $8b, $01, $e5
    db $21, $23, $9f, $e5, $af, $f5, $33, $cd
    db $01, $24, $e8, $05, $cd, $09, $73, $af
    db $67, $2e, $03, $e5, $3e, $03, $f5, $33
    db $cd, $d8, $23, $e8, $03, $f0, $fb, $b7
    db $28, $12, $21, $45, $01, $e5, $21, $35
    db $9f, $e5, $af, $f5, $33, $cd, $01, $24
    db $e8, $05, $18, $10, $21, $43, $01, $e5
    db $21, $33, $9f, $e5, $af, $f5, $33, $cd
    db $01, $24, $e8, $05, $21, $3f, $db, $36
    db $01, $11, $a4, $c4, $d5, $cd, $68, $03
    db $e1, $c9, $e8, $fa, $f0, $fb, $b7, $3e
    db $04, $20, $02, $3e, $06, $f8, $00, $77
    db $f0, $fb, $b7, $3e, $0c, $20, $02, $3e
    db $08, $f8, $01, $77, $f8, $05, $36, $00
    db $f8, $05, $7e, $f8, $00, $96, $d2, $59
    db $71, $f8, $0a, $7e, $f8, $05, $86, $f8
    db $02, $22, $36, $87, $23, $36, $71, $f8
    db $08, $7e, $b7, $28, $1a, $f8, $02, $7e
    db $d6, $02, $30, $48, $7e, $b7, $28, $05
    db $01, $80, $71, $18, $03, $01, $78, $71
    db $f8, $03, $79, $22, $70, $18, $35, $f8
    db $02, $7e, $b7, $20, $17, $fa, $70, $d7
    db $b7, $28, $08, $23, $36, $5f, $23, $36
    db $71, $18, $21, $f8, $03, $36, $6c, $23
    db $36, $71, $18, $18, $fa, $77, $d7, $f8
    db $02, $96, $38, $10, $4e, $0d, $06, $04
    db $c5, $cd, $62, $65, $e1, $f8, $03, $3e
    db $50, $22, $36, $d7, $f0, $fb, $f8, $05
    db $4e, $b7, $28, $09, $79, $87, $81, $87
    db $87, $c6, $48, $18, $06, $79, $87, $87
    db $87, $c6, $48, $4f, $f8, $09, $7e, $f8
    db $02, $96, $3e, $01, $28, $01, $af, $47
    db $b7, $28, $12, $c5, $af, $67, $2e, $03
    db $e5, $3e, $03, $f5, $33, $cd, $d8, $23
    db $e8, $03, $c1, $18, $0d, $c5, $af, $0f
    db $f5, $af, $f5, $33, $cd, $d8, $23, $e8
    db $03, $c1, $f8, $01, $79, $86, $3d, $c5
    db $26, $01, $e5, $33, $67, $2e, $9e, $e5
    db $61, $2e, $01, $e5, $cd, $01, $24, $e8
    db $05, $c1, $78, $b7, $28, $10, $c5, $21
    db $03, $00, $e5, $af, $f5, $33, $cd, $d8
    db $23, $e8, $03, $c1, $18, $0f, $c5, $af
    db $0f, $f5, $af, $3e, $03, $f5, $33, $cd
    db $d8, $23, $e8, $03, $c1, $f8, $05, $7e
    db $c6, $09, $61, $e5, $33, $f5, $33, $f8
    db $05, $2a, $5f, $56, $d5, $cd, $a3, $72
    db $e8, $04, $f8, $05, $34, $c3, $51, $70
    db $cd, $09, $73, $e8, $06, $c9, $42, $61
    db $63, $6b, $20, $75, $70, $20, $73, $61
    db $76, $65, $00, $4e, $6f, $20, $73, $61
    db $76, $65, $20, $79, $65, $74, $00, $52
    db $65, $73, $74, $6f, $72, $65, $00, $44
    db $65, $6c, $65, $74, $65, $00, $00, $af
    db $0f, $f5, $af, $3e, $03, $f5, $33, $cd
    db $d8, $23, $e8, $03, $21, $05, $28, $e5
    db $f8, $04, $2a, $5f, $56, $d5, $cd, $a3
    db $72, $e8, $04, $c3, $09, $73, $e8, $f4
    db $f8, $0e, $7e, $b7, $28, $05, $01, $9c
    db $72, $18, $03, $01, $90, $72, $f8, $08
    db $79, $22, $70, $af, $0f, $f5, $af, $f5
    db $33, $cd, $d8, $23, $e8, $03, $f0, $fb
    db $b7, $28, $13, $21, $8e, $01, $e5, $21
    db $7c, $9e, $e5, $3e, $01, $f5, $33, $cd
    db $01, $24, $e8, $05, $18, $11, $21, $8a
    db $01, $e5, $21, $7c, $9e, $e5, $3e, $01
    db $f5, $33, $cd, $01, $24, $e8, $05, $af
    db $0f, $f5, $af, $3e, $03, $f5, $33, $cd
    db $d8, $23, $e8, $03, $f8, $0e, $7e, $b7
    db $28, $05, $01, $96, $72, $18, $03, $01
    db $88, $72, $21, $10, $80, $e5, $c5, $cd
    db $a3, $72, $e8, $04, $f0, $fb, $b7, $28
    db $49, $0e, $00, $59, $16, $00, $21, $00
    db $00, $39, $19, $e5, $7d, $f8, $0c, $77
    db $e1, $7c, $f8, $0b, $77, $79, $d6, $08
    db $30, $16, $f8, $08, $2a, $81, $5f, $7e
    db $ce, $00, $57, $1a, $b7, $28, $09, $23
    db $5e, $23, $66, $6b, $77, $0c, $18, $d3
    db $f8, $0a, $2a, $66, $6f, $36, $00, $21
    db $00, $00, $39, $11, $56, $80, $d5, $af
    db $f5, $33, $e5, $cd, $c0, $05, $e8, $05
    db $18, $1f, $f8, $0e, $7e, $b7, $3e, $06
    db $20, $02, $3e, $05, $26, $10, $e5, $33
    db $26, $0b, $e5, $33, $f5, $33, $f8, $0b
    db $2a, $5f, $56, $d5, $cd, $b7, $08, $e8
    db $05, $cd, $09, $73, $e8, $0c, $c9, $5b
    db $42, $5d, $62, $61, $63, $6b, $00, $5b
    db $41, $5d, $6f, $6b, $00, $5b, $42, $5d
    db $6e, $6f, $00, $5b, $41, $5d, $79, $65
    db $73, $00, $e8, $e7, $f0, $fb, $b7, $20
    db $17, $f8, $1d, $3a, $2b, $57, $1e, $01
    db $d5, $3e, $12, $f5, $33, $2a, $5f, $56
    db $d5, $cd, $b7, $08, $e8, $05, $18, $45
    db $f8, $18, $36, $00, $f8, $18, $5e, $16
    db $00, $21, $00, $00, $39, $19, $5d, $54
    db $f8, $18, $7e, $d6, $17, $30, $19, $f8
    db $1b, $7e, $f8, $18, $86, $23, $23, $23
    db $23, $4f, $7e, $ce, $00, $47, $0a, $b7
    db $28, $06, $12, $f8, $18, $34, $18, $d4
    db $af, $12, $f8, $1e, $66, $2e, $01, $e5
    db $af, $f5, $33, $21, $03, $00, $39, $e5
    db $cd, $c0, $05, $e8, $05, $e8, $19, $c9
    db $af, $0f, $f5, $af, $3e, $03, $f5, $33
    db $cd, $d8, $23, $e8, $03, $f0, $fb, $b7
    db $28, $12, $21, $8f, $00, $e5, $21, $24
    db $9f, $e5, $af, $f5, $33, $cd, $01, $24
    db $e8, $05, $18, $10, $21, $8b, $00, $e5
    db $21, $23, $9f, $e5, $af, $f5, $33, $cd
    db $01, $24, $e8, $05, $af, $67, $2e, $03
    db $e5, $3e, $03, $f5, $33, $cd, $d8, $23
    db $e8, $03, $21, $7b, $01, $e5, $21, $7b
    db $9f, $e5, $af, $f5, $33, $cd, $01, $24
    db $e8, $05, $f0, $fb, $b7, $28, $13, $21
    db $8f, $01, $e5, $21, $7b, $4f, $e5, $3e
    db $4f, $f5, $33, $cd, $01, $24, $e8, $05
    db $18, $11, $21, $8b, $01, $e5, $21, $7b
    db $53, $e5, $3e, $53, $f5, $33, $cd, $01
    db $24, $e8, $05, $af, $0f, $f5, $af, $3e
    db $03, $f5, $33, $cd, $d8, $23, $e8, $03
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

SaveNameMatch::
    db $e8, $fb, $06, $00, $21, $78, $d7, $4e
    db $78, $91, $30, $30, $f8, $0b, $2a, $80
    db $5f, $7e, $ce, $00, $57, $1a, $c5, $f5
    db $33, $cd, $56, $76, $33, $4b, $f1, $47
    db $68, $26, $00, $11, $a4, $c4, $19, $7e
    db $c5, $f5, $33, $cd, $56, $76, $33, $7b
    db $c1, $91, $28, $05, $1e, $00, $c3, $ac
    db $75, $04, $18, $c8, $fa, $78, $d7, $f8
    db $0b, $86, $23, $4f, $3e, $00, $8e, $47
    db $0a, $fe, $2e, $ca, $4d, $75, $f8, $04
    db $36, $00, $3e, $af, $f8, $04, $86, $5f
    db $3e, $75, $ce, $00, $57, $1a, $f8, $00
    db $77, $5e, $16, $00, $1b, $69, $60, $19
    db $7e, $f8, $01, $77, $3e, $b4, $f8, $04
    db $86, $5f, $3e, $75, $ce, $00, $57, $1a
    db $f8, $01, $96, $20, $25, $f8, $04, $7e
    db $b7, $28, $04, $16, $02, $18, $02, $16
    db $04, $f8, $00, $2a, $23, $81, $5f, $3e
    db $00, $88, $c5, $e5, $d5, $33, $57, $d5
    db $cd, $c3, $75, $e8, $05, $7b, $c1, $b7
    db $20, $05, $1e, $00, $c3, $ac, $75, $f8
    db $04, $7e, $b7, $20, $19, $2b, $2b, $2a
    db $d6, $bc, $7e, $de, $07, $30, $05, $1e
    db $00, $c3, $ac, $75, $f8, $02, $7e, $c6
    db $44, $22, $7e, $ce, $f8, $77, $3e, $b9
    db $f8, $04, $86, $2b, $2b, $5f, $3e, $75
    db $ce, $00, $57, $1a, $5f, $16, $00, $2a
    db $93, $7e, $9a, $38, $17, $23, $3e, $be
    db $86, $2b, $2b, $5f, $3e, $75, $ce, $00
    db $57, $1a, $5f, $16, $00, $7b, $96, $23
    db $7a, $9e, $30, $05, $1e, $00, $c3, $ac
    db $75, $f8, $0d, $7e, $f8, $04, $86, $5f
    db $f5, $f8, $10, $f1, $7e, $ce, $00, $57
    db $f8, $02, $2a, $23, $12, $34, $7e, $d6
    db $05, $da, $f2, $73, $21, $11, $00, $09
    db $4d, $44, $f8, $0d, $7e, $c6, $05, $f5
    db $f8, $02, $f1, $77, $f5, $f8, $10, $f1
    db $7e, $ce, $00, $f8, $01, $77, $e1, $36
    db $01, $e5, $0a, $fe, $20, $20, $76, $69
    db $60, $23, $7e, $fe, $28, $20, $6e, $16
    db $00, $6a, $26, $00, $23, $23, $09, $7e
    db $fe, $30, $38, $07, $fe, $3a, $30, $03
    db $14, $18, $ee, $7a, $b7, $28, $40, $3e
    db $03, $92, $38, $3b, $f8, $04, $72, $6e
    db $2c, $2c, $26, $00, $09, $7e, $fe, $29
    db $20, $2d, $f8, $02, $79, $c6, $02, $5f
    db $78, $ce, $00, $c5, $e5, $d5, $33, $57
    db $d5, $cd, $c3, $75, $e8, $05, $7b, $c1
    db $b7, $28, $14, $f8, $02, $2a, $d6, $02
    db $7e, $de, $00, $38, $0a, $2b, $3e, $fa
    db $96, $23, $3e, $00, $9e, $30, $04, $1e
    db $00, $18, $71, $f8, $02, $7e, $e1, $e5
    db $77, $f8, $04, $7e, $3c, $3c, $3c, $81
    db $4f, $3e, $00, $88, $47, $0a, $fe, $2e
    db $20, $3e, $69, $60, $23, $7e, $c5, $f5
    db $33, $cd, $56, $76, $33, $7b, $c1, $fe
    db $73, $20, $2d, $69, $60, $23, $23, $7e
    db $c5, $f5, $33, $cd, $56, $76, $33, $7b
    db $c1, $fe, $61, $20, $1b, $69, $60, $23
    db $23, $23, $7e, $c5, $f5, $33, $cd, $56
    db $76, $33, $7b, $c1, $fe, $76, $20, $08
    db $21, $04, $00, $09, $7e, $b7, $28, $04
    db $1e, $00, $18, $18, $fa, $78, $d7, $f8
    db $0b, $86, $23, $5f, $3e, $00, $8e, $57
    db $7b, $91, $20, $06, $7a, $90, $1e, $01
    db $28, $02, $1e, $02, $e8, $05, $c9, $01
    db $06, $09, $0c, $0f, $20, $2d, $2d, $20
    db $2d, $00, $01, $01, $00, $00, $7f, $0c
    db $1f, $17, $3b, $e8, $f8, $af, $f8, $03
    db $22, $77, $f8, $0c, $7e, $f8, $07, $77
    db $f8, $07, $3a, $22, $7e, $3d, $32, $7e
    db $b7, $28, $6a, $f8, $0a, $2a, $5f, $56
    db $1a, $f8, $00, $77, $d6, $30, $38, $05
    db $3e, $39, $96, $30, $04, $1e, $00, $18
    db $62, $f8, $03, $3a, $2b, $77, $f8, $04
    db $3a, $2b, $77, $3e, $03, $f8, $01, $cb
    db $26, $23, $cb, $16, $3d, $20, $f6, $23
    db $cb, $26, $23, $cb, $16, $2b, $3a, $2b
    db $86, $23, $23, $23, $23, $32, $3a, $2b
    db $8e, $f8, $06, $77, $f8, $00, $7e, $f8
    db $04, $77, $f8, $0a, $34, $20, $02, $23
    db $34, $f8, $04, $7e, $c6, $d0, $77, $f8
    db $01, $22, $af, $32, $7e, $f8, $05, $86
    db $2b, $2b, $22, $23, $23, $3e, $00, $8e
    db $2b, $2b, $77, $18, $8b, $f8, $0d, $2a
    db $4f, $46, $f8, $03, $2a, $02, $03, $7e
    db $02, $1e, $01, $e8, $08, $c9, $f8, $02
    db $7e, $d6, $41, $38, $0a, $3e, $5a, $96
    db $38, $05, $7e, $c6, $20, $5f, $c9, $f8
    db $02, $5e, $c9

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

ThemeRow::
    db $e8, $f6, $f8, $0c, $7e, $d6, $02, $20
    db $1f, $fa, $58, $db, $3c, $d6, $07, $30
    db $07, $fa, $58, $db, $3c, $4f, $18, $02
    db $0e, $00, $21, $58, $db, $71, $2e, $fc
    db $36, $01, $cd, $00, $5f, $cd, $90, $59
    db $f8, $0c, $7e, $b7, $28, $0e, $21, $03
    db $00, $e5, $af, $f5, $33, $cd, $d8, $23
    db $e8, $03, $18, $0d, $af, $0f, $f5, $af
    db $3e, $03, $f5, $33, $cd, $d8, $23, $e8
    db $03, $f0, $fb, $b7, $28, $6d, $21, $7c
    db $01, $e5, $21, $6f, $6c, $e5, $3e, $28
    db $f5, $33, $cd, $01, $24, $e8, $05, $21
    db $58, $db, $4e, $06, $00, $69, $60, $29
    db $09, $29, $09, $11, $68, $77, $19, $4d
    db $44, $0a, $fe, $20, $20, $03, $03, $18
    db $f8, $f8, $07, $79, $22, $78, $22, $36
    db $00, $f8, $09, $5e, $16, $00, $21, $00
    db $00, $39, $19, $4d, $44, $f8, $07, $2a
    db $23, $86, $2b, $5f, $7e, $ce, $00, $57
    db $1a, $02, $b7, $28, $04, $23, $34, $18
    db $e0, $3e, $6b, $e0, $f9, $21, $00, $00
    db $39, $11, $2d, $72, $d5, $af, $f5, $33
    db $e5, $cd, $c0, $05, $e8, $05, $af, $e0
    db $f9, $18, $2f, $21, $79, $01, $e5, $21
    db $6d, $6c, $e5, $3e, $33, $f5, $33, $cd
    db $01, $24, $e8, $05, $21, $58, $db, $4e
    db $06, $00, $69, $60, $29, $09, $29, $09
    db $11, $68, $77, $19, $11, $07, $0e, $d5
    db $3e, $06, $f5, $33, $e5, $cd, $b7, $08
    db $e8, $05, $af, $0f, $f5, $af, $3e, $03
    db $f5, $33, $cd, $d8, $23, $e8, $0d, $c9
    db $20, $4c, $49, $47, $48, $54, $00, $20
    db $20, $44, $41, $52, $4b, $00, $20, $42
    db $4c, $41, $43, $4b, $00, $20, $20, $20
    db $52, $45, $44, $00, $20, $47, $52, $45
    db $45, $4e, $00, $50, $55, $52, $50, $4c
    db $45, $00, $20, $20, $42, $4c, $55, $45
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
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

U32ToAsciiFast::
    db $f8, $08, $7e, $fe, $0a, $c2, $bb, $7c
    db $f8, $04, $2a, $b6, $c2, $bb, $7c, $f8
    db $06, $2a, $5f, $56, $f8, $02, $2a, $66
    db $6f, $0e, $00, $06, $30, $7d, $d6, $10
    db $6f, $7c, $de, $27, $67, $38, $03, $04
    db $18, $f3, $7d, $c6, $10, $6f, $7c, $ce
    db $27, $67, $78, $fe, $30, $20, $04, $cb
    db $41, $28, $04, $12, $13, $0e, $01, $06
    db $30, $7d, $d6, $e8, $6f, $7c, $de, $03
    db $67, $38, $03, $04, $18, $f3, $7d, $c6
    db $e8, $6f, $7c, $ce, $03, $67, $78, $fe
    db $30, $20, $04, $cb, $41, $28, $04, $12
    db $13, $0e, $01, $06, $30, $7d, $d6, $64
    db $6f, $7c, $de, $00, $67, $38, $03, $04
    db $18, $f3, $7d, $c6, $64, $6f, $7c, $ce
    db $00, $67, $78, $fe, $30, $20, $04, $cb
    db $41, $28, $04, $12, $13, $0e, $01, $06
    db $30, $7d, $d6, $0a, $6f, $7c, $de, $00
    db $67, $38, $03, $04, $18, $f3, $7d, $c6
    db $0a, $6f, $7c, $ce, $00, $67, $78, $fe
    db $30, $20, $04, $cb, $41, $28, $04, $12
    db $13, $0e, $01, $cb, $41, $20, $04, $3e
    db $30, $12, $13, $7d, $c6, $30, $12, $13
    db $af, $12, $c9, $e8, $cc, $f8, $13, $c3
    db $fb, $44

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38

SgbLaunchHook::
    db $cd, $3a, $7e, $3e, $01, $f5, $c3, $92
    db $44, $cd, $26, $7d, $1e, $00, $28, $12
    db $af, $f5, $cd, $88, $7d, $16, $04, $cd
    db $e8, $7d, $f1, $3c, $fe, $06, $20, $f1
    db $1e, $01, $f1, $c3, $50, $01, $3e, $11
    db $ea, $00, $40, $06, $03, $cd, $6f, $7d
    db $21, $12, $a4, $2a, $fe, $53, $20, $0d
    db $7e, $fe, $42, $28, $04, $fe, $4e, $20
    db $04, $0e, $00, $18, $0a, $21, $00, $a4
    db $2a, $4f, $2a, $57, $2a, $5f, $66, $af
    db $ea, $00, $40, $47, $cd, $6f, $7d, $79
    db $fe, $53, $20, $11, $7a, $fe, $47, $20
    db $0c, $7b, $fe, $01, $20, $07, $7c, $fe
    db $fe, $20, $02, $b7, $c9, $af, $c9, $3e
    db $e1, $ea, $00, $7f, $3e, $e2, $ea, $10
    db $7f, $3e, $e3, $ea, $20, $7f, $78, $ea
    db $c0, $7f, $3e, $e4, $ea, $f0, $7f, $c9
    db $f5, $4f, $87, $87, $87, $91, $87, $c6
    db $04, $6f, $26, $01, $e5, $0e, $0e, $1e
    db $00, $cd, $ca, $7d, $83, $5f, $0d, $20
    db $f8, $e1, $f1, $87, $c6, $f1, $57, $af
    db $e0, $00, $3e, $30, $e0, $00, $cd, $d4
    db $7d, $53, $cd, $d4, $7d, $0e, $0e, $cd
    db $ca, $7d, $57, $cd, $d4, $7d, $0d, $20
    db $f6, $3e, $20, $e0, $00, $3e, $30, $e0
    db $00, $c9, $7d, $fe, $50, $3e, $00, $30
    db $01, $7e, $23, $c9, $06, $08, $3e, $10
    db $cb, $1a, $38, $02, $3e, $20, $e0, $00
    db $3e, $30, $e0, $00, $05, $20, $ef, $c9
    db $01, $cc, $09, $0b, $78, $b1, $20, $fb
    db $15, $20, $f5, $c9, $c5, $d5, $e5, $f0
    db $f4, $a7, $28, $03, $3d, $e0, $f4, $21
    db $f3, $ff, $35, $cc, $0a, $7e, $e1, $d1
    db $c1, $c9, $f0, $f2, $fe, $13, $38, $04
    db $af, $e0, $f2, $c9, $3d, $fe, $06, $38
    db $04, $d6, $06, $18, $f8, $cd, $88, $7d
    db $3e, $04, $e0, $f4, $4f, $f0, $f2, $3c
    db $e0, $f2, $fe, $07, $20, $02, $0e, $44
    db $fe, $0d, $20, $02, $0e, $34, $79, $e0
    db $f3, $c9, $cd, $fd, $06, $f0, $f2, $a7
    db $28, $0b, $f0, $f3, $57, $cd, $e8, $7d
    db $cd, $0a, $7e, $18, $f0, $e0, $f4, $c3
    db $06, $07

    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
    rst RST_38
