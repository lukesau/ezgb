; Game hand-off, copied to WRAM and run from there: the kernel's stub
; (RomLoad_InitiatePoll 04:4000 copied to $D100) after a game launch.
; $7FE0=$80 resets the console into the loaded game, or with SKIP_BOOT set
; it jumps there (kernel/mod/asm/skip_boot.asm, docs/skip-boot-rom.md): the
; registers stage1 saved, and only the state stage1 changed put back. The LCD
; is off already. Runs at $D000.

        .module game_handoff
        .globl  _game_handoff_start, _game_handoff_end

        .macro  UNLOCK
        call    0xD000 + game_handoff_unlock - _game_handoff_start
        .endm
        .macro  LOCK
        call    0xD000 + game_handoff_lock - _game_handoff_start
        .endm
        .macro  FPGA reg, value
        ld      de, #reg
        ld      a, #value
        call    0xD000 + game_handoff_fpga - _game_handoff_start
        .endm

        .area   _CODE
_game_handoff_start:
        FPGA    0x7F36, 0x03            ; load the command's file
        ld      hl, #0xA000             ; wait while 0 or 1 (busy)
1$:     ld      a, (hl)
        cp      a, #2
        jr      c, 1$
        FPGA    0x7F36, 0x00
        UNLOCK
        ld      hl, #0x7F31
        ld      (hl), #0x00
        inc     hl
        ld      (hl), #0x00
        LOCK
        ld      a, #0x01
        ld      (#0x2000), a
        xor     a, a
        ld      (#0x3000), a
        ldh     a, (0x88)               ; SKIP_BOOT, hw.h
        or      a, a
        jr      nz, 3$
        FPGA    0x7FE0, 0x80            ; reset into the game
2$:     jr      2$

3$:     FPGA    0x7F32, 0x00            ; the unlock the reset would use, no change
        xor     a, a                    ; MBC as at power-on
        ld      (#0x0000), a
        ld      (#0x4000), a
        ld      (#0x6000), a
        ldh     (0x00), a               ; P1
        ld      c, #2                   ; VRAM bank 1, then bank 0
4$:     ld      a, c
        dec     a
        ldh     (0x4F), a
        ld      hl, #0x8000
        xor     a, a
5$:     ld      (hl+), a
        bit     5, h
        jr      z, 5$
        dec     c
        jr      nz, 4$
        ld      a, #0x80                ; palettes white (no-op on a DMG), sound on
        ldh     (0x68), a
        ldh     (0x6A), a
        ldh     (0x26), a
        ld      b, #64
        ld      a, #0xFF
6$:     ldh     (0x69), a
        ldh     (0x6B), a
        dec     b
        jr      nz, 6$
        ld      a, #0x77
        ldh     (0x24), a
        ld      a, #0xF3
        ldh     (0x25), a
        ld      a, #0xFC
        ldh     (0x47), a
        ld      a, #0x91                ; LCD on, hand over at the start of VBlank
        ldh     (0x40), a
        xor     a, a
        ldh     (0x0F), a
7$:     ldh     a, (0x44)
        cp      a, #144
        jr      nz, 7$
        ld      sp, #0xFF80             ; BOOT_REGS
        pop     af
        pop     bc
        pop     de
        pop     hl
        ld      sp, #0xFFFE
        jp      0x0100

; The copy always runs at $D000, so these calls are absolute.
game_handoff_unlock:
        ld      hl, #0x7F00
        ld      (hl), #0xE1
        ld      hl, #0x7F10
        ld      (hl), #0xE2
        ld      hl, #0x7F20
        ld      (hl), #0xE3
        ret
; $(DE) = A inside unlock/lock
game_handoff_fpga:
        call    0xD000 + game_handoff_unlock - _game_handoff_start
        ld      h, d
        ld      l, e
        ld      (hl), a
game_handoff_lock:
        ld      hl, #0x7FF0
        ld      (hl), #0xE4
        ret
_game_handoff_end:
