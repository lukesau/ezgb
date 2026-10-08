; SGB unlock at boot, after nitro2k01's SGB Enabler for 1.04e (2021).
;
; The Jr holds the CPU in reset while the FPGA configures, so the SGB BIOS
; misses the 6 header packets the boot ROM normally sends and the SNES stays
; black. This resends them from the kernel before KernelEntry: 4 rounds with
; the Enabler's gaps (192/64/48 frames), ~6.7 s total.
;
; Differences from the Enabler:
;   - packets are built from the live header at $0104-$014F (zero past it)
;     instead of a prebuilt table, so the checksums can't go stale
;   - waits count cycles instead of halting on VBlank, so they don't depend
;     on the LCD being on, and IE/IF are left alone
;   - code lives at the end of bank 1; bank 0 only holds the 9-byte stub
;   - A is preserved for KernelEntry's `ld d, a`
;
; Assembled by scripts/make-sgb-dist.py, which splices the two sections into
; the mod kernel and points $0100 at SgbStub.

DEF rP1        EQU $ff00
DEF wSgbPacket EQU $c000   ; 16 B; KernelEntry clears WRAM after us
DEF HDR_START  EQU $0104
DEF HDR_END    EQU $0150   ; packet bytes from here on are 0

SECTION "SgbStub", ROM0[$0020]
SgbStub::
    push af
    ld a, $01
    ld [$2000], a
    jp SgbUnlock

SECTION "SgbBank1", ROMX[$7f00], BANK[1]
SgbUnlock::
    call SgbSendHeader
    ld d, 192
    call SgbWaitFrames
    call SgbSendHeader
    ld d, 64
    call SgbWaitFrames
    call SgbSendHeader
    ld d, 48
    call SgbWaitFrames
    call SgbSendHeader
    pop af
    jp $0150

; Send the 6 header packets, commands $F1, $F3, ... $FB. Each is
; [cmd][sum of the 14 data bytes][14 header bytes].
SgbSendHeader:
    ld de, HDR_START
    ld b, $f1
.packet
    ld hl, wSgbPacket
    ld a, b
    ld [hl+], a
    inc hl
    ld c, 14
.copy
    ld a, e
    cp LOW(HDR_END)   ; d is always $01 here
    ld a, 0
    jr nc, .pad
    ld a, [de]
.pad
    ld [hl+], a
    inc de
    dec c
    jr nz, .copy

    ld hl, wSgbPacket + 2
    ld c, 14
    xor a
.sum
    add a, [hl]
    inc hl
    dec c
    jr nz, .sum
    ld [wSgbPacket + 1], a

    push bc
    push de
    ld hl, wSgbPacket
    call SgbSendPacket
    pop de
    pop bc
    inc b
    inc b
    ld a, b
    cp $fd
    jr nz, .packet
    ret

; Send the 16-byte packet at hl over P1: reset pulse, 128 bits LSB first
; (P15 low = 1, P14 low = 0), stop bit 0, then 4 frames for the SGB.
SgbSendPacket:
    ld c, LOW(rP1)
    xor a
    ldh [c], a
    ld a, $30
    ldh [c], a
    ld b, 16
.byte
    ld e, 8
    ld a, [hl+]
    ld d, a
.bit
    bit 0, d
    ld a, $10
    jr nz, .one
    add a, a
.one
    ldh [c], a
    ld a, $30
    ldh [c], a
    rr d
    dec e
    jr nz, .bit
    dec b
    jr nz, .byte
    ld a, $20
    ldh [c], a
    ld a, $30
    ldh [c], a
    ld d, 4
    ; fall through

; Busy-wait d frames (17556 M-cycles each), whether or not the LCD is on.
SgbWaitFrames:
    ld bc, 2508     ; 2508 * 7 M-cycles = 17556
.loop
    dec bc          ; 2
    ld a, b         ; 1
    or c            ; 1
    jr nz, .loop    ; 3
    dec d
    jr nz, SgbWaitFrames
    ret
