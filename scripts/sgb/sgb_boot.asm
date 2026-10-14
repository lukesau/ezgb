; SGB unlock, after nitro2k01's SGB Enabler for 1.04e (2021).
;
; The Jr holds the CPU in reset while the FPGA configures, so the SGB BIOS
; misses the 6 header packets the boot ROM normally sends and the SNES stays
; black. This resends them from the kernel: 4 sets with the Enabler's gaps
; (192/64/48 frames), 4 frames after every packet.
;
; Only set 1 blocks the boot (~0.4 s, at $0100 before KernelEntry). Sets 2-4
; go out from the VBlank interrupt while the kernel starts up and runs
; (docs/sgb-background-send.md, after nitro2k01's plan in issue #5):
;   - the VBlank vector runs the callback list and then SgbVblTail, so a
;     packet (~2,500 M-cycles, longer than VBlank) never delays the list's
;     LCDC/OAM work
;   - for the 4 frames after a packet ReadJoypadRaw returns the last state
;     ($fffc) instead of driving P1 (SgbPadGate)
;   - a game launch sends whatever is left first, blocking (SgbLaunchHook),
;     since a fast launch can start a game with no input before the SGB is up
; The frame count only runs while the LCD is on, so a gap can come out
; longer than listed, never shorter.
;
; Differences from the Enabler:
;   - packets are built from the live header at $0104-$014F (zero past it)
;     instead of a prebuilt table, so the checksums can't go stale
;   - set 1's waits count cycles instead of halting for VBlank, so they don't
;     depend on the LCD being on, and IE/IF are left alone
;   - A is preserved for KernelEntry's `ld d, a`
;
; The SET tab's SGB BOOT checkbox (kernel/src/flcfg.c) turns it on: it writes
; 'S','G',flag,~flag to battery-backed pSRAM page $11 at $A400
; (docs/psram-page-map.md), and SgbCheck says send only when that record reads
; back valid with flag 1. Anything else (a dead coin cell's garbage, a cart
; that never had the mod) boots straight on. So does any boot through our
; stage1, which handles the SGB itself (stage1/src/sgb.c) and says so with
; 'S','B' (sent) or 'S','N' (no SGB) at $A412. The mark is left for ezcfg's
; boot hook to read and clear, so the SET tab can show SGB BOOT as AUTO. Built
; with -D SGB_ALWAYS (the mod-5.2-sgb test build, scripts/make-sgb-dist.py) it
; skips the check.
;
; Everything but two small bank-0 stubs and SgbBootHook lives at the end of
; bank 4, the only bank with room in all three kernels. Kernel addresses
; (RunCallbackList, wRomBank, ...) come from kernel.sym as -D definitions;
; scripts/inject-sgb.py assembles this, injects every section and points the
; hook sites at them.

DEF rP1        EQU $ff00
DEF rVBK       EQU $ff4f
DEF HDR_START  EQU $0104
DEF HDR_END    EQU $0150   ; packet bytes from here on are 0
DEF SGB_REC    EQU $a400   ; pSRAM page $11: 'S', 'G', flag, ~flag
DEF SGB_MARK   EQU $a412   ; pSRAM page $11: 'S', 'B'/'N' from our stage1

; Background state, HRAM (KernelEntry clears it; 0 = nothing to send)
DEF hSgbStep   EQU $fff2   ; 1-18: next packet of sets 2-4; 19: last freeze; 0: done
DEF hSgbWait   EQU $fff3   ; frames until that step is due
DEF hSgbBusy   EQU $fff4   ; frames of joypad freeze left
DEF hPadPrev   EQU $fffc   ; VBlankPadLatch's last pad state

DEF SET_GAP_2  EQU 192     ; frames between sets, as in the Enabler
DEF SET_GAP_3  EQU 64
DEF SET_GAP_4  EQU 48
DEF PKT_WAIT   EQU 4       ; frames after every packet

SECTION "SgbStub", ROM0[$0020]
SgbStub::
    push af
    ld a, BANK(SgbUnlock)
    ld [$2000], a
    jp SgbUnlock

; VBlank vector at $0040 is `call SgbVblList` / `jp SgbVblTail`.
SECTION "SgbVblList", ROM0[$04e1]
SgbVblList::                ; the stock vector, returning here by reti
    push hl
    ld hl, wVBlankCallbacks
    jp RunCallbackList

SECTION "SgbVblTail", ROM0[$02c3]
SgbVblTail::                ; after the callback list; IME is on again
    push af
    ldh a, [hSgbStep]
    and a
    jr z, .done
    di
    ld a, [wRomBank]        ; main code switches banks with interrupts off,
    push af                 ; so this is the bank it's running in
    ld a, BANK(SgbFrame)
    ld [$2000], a
    call SgbFrame
    pop af
    ld [$2000], a
.done
    pop af
    reti

; ReadJoypadRaw's first two instructions (`push bc / ld a, $20`) become
; `jp SgbPadGate`.
SECTION "SgbPadGate", ROM0[$05f2]
SgbPadGate::
    ldh a, [hSgbBusy]
    and a
    jr nz, .frozen
    push bc
    ld a, $20
    jp ReadJoypadRaw + 3
.frozen                     ; same as last frame: no new presses, no P1 writes
    ldh a, [hPadPrev]
    ret

; KernelEntry's `call CgbInit` (bank 1 is mapped there). HRAM is clear by
; now. E is still what SgbUnlock left in it at $0100 (KernelEntry doesn't
; touch E before this): 1 when set 1 went out, so start the count to set 2.
SECTION "SgbBootHook", ROMX[$7f00], BANK[1]
SgbBootHook::
    dec e
    jr nz, .off
    ld a, 1
    ldh [hSgbStep], a
    ld a, SET_GAP_2
    ldh [hSgbWait], a
.off
    jp CgbInit

SECTION "SgbBank4", ROMX[$7d00], BANK[4]
; RomLoad_CopyCmdWindowPoll_B4's first two instructions (`ld a, $01 / push
; af`) become `jp SgbLaunchHook`; everything after it is the game's handoff.
SgbLaunchHook::
    call SgbFinish
    ld a, $01
    push af
    jp RomLoad_CopyCmdWindowPoll_B4 + 3

SgbUnlock::                 ; from $0100 via SgbStub, A on the stack
    call SgbCheck
    ld e, 0                 ; for SgbBootHook: nothing sent
    jr z, .off
    xor a                   ; set 1: packets 0-5, PKT_WAIT frames after each
.set1
    push af
    call SgbSendPacket
    ld d, PKT_WAIT
    call SgbWaitFrames
    pop af
    inc a
    cp 6
    jr nz, .set1
    ld e, 1                 ; for SgbBootHook: send sets 2-4
.off
    pop af
    jp $0150

; nz when the kernel should send: SGB BOOT on and no stage1 mark.
SgbCheck::
IF DEF(SGB_ALWAYS)
    or $ff
    ret
ELSE
    ; map pSRAM page $11 the way the kernel does ($4000 = page, then
    ; $7FC0 = $03), read the record, and unmap again ($4000 = 0, $7FC0 = 0)
    ld a, $11
    ld [$4000], a
    ld b, $03
    call SgbSetFpgaPage
    ld hl, SGB_MARK     ; our stage1's mark: 'S', then 'B' or 'N'
    ld a, [hl+]
    cp 'S'
    jr nz, .record
    ld a, [hl]
    cp 'B'
    jr z, .stage1
    cp 'N'
    jr nz, .record
.stage1
    ld c, 0             ; stage1 handles the SGB: fail the record check
    jr .unmap
.record
    ld hl, SGB_REC
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld e, a
    ld h, [hl]
.unmap
    xor a
    ld [$4000], a
    ld b, a
    call SgbSetFpgaPage
    ld a, c
    cp 'S'
    jr nz, .off
    ld a, d
    cp 'G'
    jr nz, .off
    ld a, e
    cp $01
    jr nz, .off
    ld a, h
    cp $fe
    jr nz, .off
    or a                ; nz
    ret
.off
    xor a
    ret

; $7FC0 = b, inside the FPGA's unlock / commit sequence.
SgbSetFpgaPage:
    ld a, $e1
    ld [$7f00], a
    ld a, $e2
    ld [$7f10], a
    ld a, $e3
    ld [$7f20], a
    ld a, b
    ld [$7fc0], a
    ld a, $e4
    ld [$7ff0], a
    ret
ENDC

; Send header packet A (0-5) over P1: [$F1 + 2A][sum of the 14 data bytes]
; [14 bytes of $0104 + 14A, zero from $0150 on]. Reset pulse, 128 bits LSB
; first (P15 low = 1, P14 low = 0), stop bit 0. No wait afterwards.
; Clobbers AF, BC, DE, HL.
SgbSendPacket::
    push af
    ld c, a
    add a, a
    add a, a
    add a, a
    sub c                   ; 7A
    add a, a                ; 14A
    add a, LOW(HDR_START)
    ld l, a
    ld h, HIGH(HDR_START)
    push hl
    ld c, 14
    ld e, 0
.sum
    call SgbHdrByte
    add a, e
    ld e, a
    dec c
    jr nz, .sum
    pop hl
    pop af
    add a, a
    add a, $f1
    ld d, a
    xor a                   ; reset pulse
    ldh [rP1], a
    ld a, $30
    ldh [rP1], a
    call SgbSendByte        ; command
    ld d, e
    call SgbSendByte        ; sum
    ld c, 14
.data
    call SgbHdrByte
    ld d, a
    call SgbSendByte
    dec c
    jr nz, .data
    ld a, $20               ; stop bit
    ldh [rP1], a
    ld a, $30
    ldh [rP1], a
    ret

; A = header byte at HL ($01xx), 0 from HDR_END on; HL + 1.
SgbHdrByte:
    ld a, l
    cp LOW(HDR_END)
    ld a, 0
    jr nc, .pad
    ld a, [hl]
.pad
    inc hl
    ret

; Send D, LSB first. Clobbers A, B, D.
SgbSendByte:
    ld b, 8
.bit
    ld a, $10
    rr d
    jr c, .one
    ld a, $20
.one
    ldh [rP1], a
    ld a, $30
    ldh [rP1], a
    dec b
    jr nz, .bit
    ret

; Busy-wait D frames (17556 M-cycles each), whether or not the LCD is on.
; Clobbers A, BC, D.
SgbWaitFrames::
    ld bc, 2508     ; 2508 * 7 M-cycles = 17556
.loop
    dec bc          ; 2
    ld a, b         ; 1
    or c            ; 1
    jr nz, .loop    ; 3
    dec d
    jr nz, SgbWaitFrames
    ret

; Once per VBlank while hSgbStep is nonzero, from SgbVblTail.
SgbFrame::
    push bc
    push de
    push hl
    ldh a, [hSgbBusy]
    and a
    jr z, .notBusy
    dec a
    ldh [hSgbBusy], a
.notBusy
    ld hl, hSgbWait
    dec [hl]
    call z, SgbStep
    pop hl
    pop de
    pop bc
    ret

; Do the due step: send the next packet and set the wait to the one after,
; or (step 19) finish. Clobbers AF, BC, DE, HL.
SgbStep:
    ldh a, [hSgbStep]
    cp 19
    jr c, .send
    xor a
    ldh [hSgbStep], a
    ret
.send
    dec a                   ; 0-17
.mod6
    cp 6
    jr c, .idx
    sub 6
    jr .mod6
.idx
    call SgbSendPacket
    ld a, PKT_WAIT
    ldh [hSgbBusy], a
    ld c, a
    ldh a, [hSgbStep]
    inc a
    ldh [hSgbStep], a
    cp 7                    ; set 2 done
    jr nz, .not3
    ld c, PKT_WAIT + SET_GAP_3
.not3
    cp 13                   ; set 3 done
    jr nz, .wait
    ld c, PKT_WAIT + SET_GAP_4
.wait
    ld a, c
    ldh [hSgbWait], a
    ret

; Before a game launch: send what's left, blocking, with interrupts off so
; nothing else drives P1.
SgbFinish::
    call DiNest
.loop
    ldh a, [hSgbStep]
    and a
    jr z, .done
    ldh a, [hSgbWait]
    ld d, a
    call SgbWaitFrames
    call SgbStep
    jr .loop
.done
    ldh [hSgbBusy], a
    jp EiNest
