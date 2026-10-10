; Game hand-off, copied to WRAM and run from there: the kernel's stub
; (RomLoad_InitiatePoll 04:4000 copied to $D100) after a game launch.
; $7FE0=$80 resets the console into the loaded game. Position independent.

        .module game_handoff
        .globl  _game_handoff_start, _game_handoff_end

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

        .area   _CODE
_game_handoff_start:
        UNLOCK
        ld      hl, #0x7F36
        ld      (hl), #0x03             ; load the command's file
        LOCK
        ld      hl, #0xA000             ; wait while 0 or 1 (busy)
1$:     ld      a, (hl)
        cp      a, #2
        jr      c, 1$
        UNLOCK
        ld      hl, #0x7F36
        ld      (hl), #0x00
        LOCK
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
        UNLOCK
        ld      hl, #0x7FE0
        ld      (hl), #0x80             ; reset into the game
        LOCK
2$:     jr      2$
_game_handoff_end:
