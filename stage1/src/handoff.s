; The hand-off, copied to WRAM and run from there: once the FPGA starts the
; load, cart space ($0000-$7FFF) becomes the kernel. Position independent
; (relative jumps only). Same register sequence as stock stage1's
; HandoffPoll, then the screen is left blank for the kernel (it switches
; the LCD on before it draws), and the kernel is entered with A = $E4 like
; stock leaves it.

        .module handoff
        .globl  _handoff_start, _handoff_end

        .macro  UNLOCK
        ld      hl, #0x7F00
        ld      (hl), #0xE1
        ld      hl, #0x7F10
        ld      (hl), #0xE2
        ld      hl, #0x7F20
        ld      (hl), #0xE3
        .endm
        .macro  LOCK
        ld      hl, #0x7FF0
        ld      (hl), #0xE4
        .endm
        .macro  FPGA reg, value
        UNLOCK
        ld      hl, #reg
        ld      (hl), #value
        LOCK
        .endm

        .area   _CODE
_handoff_start:
        FPGA    0x7F36, 0x03            ; start loading the command's file
        ld      hl, #0xA000             ; status: 0, then 1 while loading, 2 done
1$:     ld      a, (hl)
        or      a, a
        jr      z, 1$
2$:     ld      a, (hl)
        dec     a
        jr      z, 2$
        FPGA    0x7F36, 0x00
        FPGA    0x7FC0, 0x00
        ld      a, #0x01                ; ROM bank 1
        ld      (#0x2000), a
        xor     a, a
        ld      (#0x3000), a
        UNLOCK
        ld      hl, #0x7F31
        ld      (hl), #0x00
        inc     hl
        ld      (hl), #0x80
        LOCK

        ; blank screen: LCD off (in vblank), both tile maps to tile 0,
        ; tile 0 blank in both addressing modes, CGB attributes to 0
        ldh     a, (0x40)
        add     a, a
        jr      nc, 4$
3$:     ldh     a, (0x44)
        cp      a, #144
        jr      nz, 3$
4$:     xor     a, a
        ldh     (0x40), a
        ld      hl, #0x9800
        ld      bc, #0x0800
5$:     xor     a, a
        ld      (hl+), a
        dec     bc
        ld      a, b
        or      a, c
        jr      nz, 5$
        ld      hl, #0x8000
        ld      b, #16
6$:     ld      (hl+), a
        dec     b
        jr      nz, 6$
        ld      hl, #0x9000
        ld      b, #16
7$:     ld      (hl+), a
        dec     b
        jr      nz, 7$
        ldh     (0x4F), a               ; CGB mode only: VBK reads back bit 0
        ldh     a, (0x4F)               ; as written (DMG reads $FF)
        rra
        jr      c, 9$
        ld      a, #1
        ldh     (0x4F), a
        ld      hl, #0x9800
        ld      bc, #0x0800
8$:     xor     a, a
        ld      (hl+), a
        dec     bc
        ld      a, b
        or      a, c
        jr      nz, 8$
9$:     xor     a, a
        ldh     (0x4F), a
        ld      a, #0xE4
        jp      0x0100
_handoff_end:
