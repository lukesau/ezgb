;; kernel/mod-1.06: the launch stub, with the jump past the boot ROM.
;;
;;   void launch_run(void) __banked;      does not return
;;
;; The kernel as received ends a launch in ramfun_DMA_Response (GBcard_OP.c),
;; C that is copied to WRAM and run there: it starts the load, waits for it,
;; switches the cart to the game and resets the console, so the boot ROM
;; runs a second time. This is that routine in assembly with one thing
;; added. When the console is already in the mode the game needs, it jumps
;; to the game's $0100 with the registers the boot ROM would have left
;; (docs/skip-boot-rom.md).
;;
;; launch_mode (ezcfg.c, set at boot) says what this console can do:
;;   0  always reset
;;   1  the DMG family: jump, whatever the game
;;   2  a color console with the kernel in CGB mode: jump when the game has
;;      the CGB flag without the PGB bits, else reset
;;
;; The stub is assembled here and runs at RUN. Inside it every jump is
;; relative, and a call names its target as RUN + (label - stub).
;;
;; Called with interrupts off and the LCD off, as the C stub was.

        .include        "global.s"

        .globl  _boot_regs, _launch_mode

        RUN     = 0xD100
        .include        "debug.inc"     ; MOD_DEBUG, 1 in a make DEBUG=1 build (makefile)
        ROM_CHECK = MOD_DEBUG           ; development: the loaded game's checksum (below)

        .area   _CODE_2

        b_launch_run = 2
        .globl  b_launch_run

_launch_run::
        ld      hl, #stub
        ld      de, #RUN
        ld      bc, #(stub_end - stub)
1$:
        ld      a, (hl+)
        ld      (de), a
        inc     de
        dec     bc
        ld      a, b
        or      c
        jr      nz, 1$
        jp      RUN

stub:
        ;; start the load: $7F36 = 3
        call    RUN + (unlock - stub)
        ld      a, #0x03
        ld      (0x7F36), a
        call    RUN + (commit - stub)
        ;; the window reads 0 until the load starts and 1 while it runs
1$:
        ld      a, (0xA000)
        or      a
        jr      z, 1$
2$:
        ld      a, (0xA000)
        dec     a
        jr      z, 2$
        call    RUN + (unlock - stub)
        xor     a
        ld      (0x7F36), a
        call    RUN + (commit - stub)
        .if     ROM_CHECK
        ;; The game is in the game store and the cart still in kernel mode,
        ;; where the bank register is a plain latch: every byte is summed and
        ;; the sum compared with the header's global checksum ($014E, high
        ;; byte first, which is not part of the sum). Up to 4 MB; a size code
        ;; past that is not checked. A sum that differs gives a black screen
        ;; until A is pressed, and then the launch goes on. For development:
        ;; it takes about 6 s a megabyte on a DMG, and a ROM whose header has
        ;; the wrong checksum, as hacks often do, fails it.
        ld      a, (0x0148)
        cp      #8
        jr      nc, 29$
        ld      b, a
        inc     b
        ld      a, #1
20$:
        add     a
        dec     b
        jr      nz, 20$
        ld      c, a                    ; banks, 0 for 256
        ld      de, #0x0001             ; d the sum's high byte, e the next bank
        ld      hl, #0x0000
        xor     a                       ; the sum's low byte
21$:
        ld      b, #0x40
22$:
        add     (hl)
        jr      nc, 23$
        inc     d
23$:
        inc     l
        add     (hl)
        jr      nc, 24$
        inc     d
24$:
        inc     l
        add     (hl)
        jr      nc, 25$
        inc     d
25$:
        inc     l
        add     (hl)
        jr      nc, 26$
        inc     d
26$:
        inc     l
        jr      nz, 22$
        inc     h
        dec     b
        jr      nz, 22$
        dec     c
        jr      z, 27$
        ld      b, a
        ld      a, e
        ld      (0x2000), a
        inc     e
        ld      a, b
        ld      hl, #0x4000
        jr      21$
27$:
        ld      hl, #0x014E
        sub     (hl)
        jr      nc, 28$
        dec     d
28$:
        inc     l
        sub     (hl)
        jr      nc, 30$
        dec     d
30$:
        cp      (hl)
        jr      nz, 31$
        dec     l
        ld      a, d
        cp      (hl)
        jr      z, 29$
31$:
        ld      a, #0xFF                ; black, on a DMG and in CGB mode
        ldh     (0x47), a
        ld      a, #0x80
        ldh     (0x68), a
        ld      b, #64
        xor     a
32$:
        ldh     (0x69), a
        dec     b
        jr      nz, 32$
        ld      a, #0x81
        ldh     (0x40), a
        ld      a, #0x10                ; the buttons
        ldh     (0x00), a
33$:
        ldh     a, (0x00)
        rra
        jr      c, 33$
29$:
        .endif
        ;; game mode
        call    RUN + (unlock - stub)
        xor     a
        ld      (0x7F31), a
        ld      (0x7F32), a
        call    RUN + (commit - stub)
        ld      a, #0x01
        ld      (0x2000), a
        xor     a
        ld      (0x3000), a

        ;; the cart is the game from here: nothing in cart space but its header
        ld      a, (_launch_mode)
        or      a
        jr      z, reset
        dec     a
        jr      z, go                   ; the DMG family has one mode
        ld      a, (0x0143)
        and     #0x8C
        cp      #0x80
        jr      nz, reset
        ;; CGB mode takes a write to palette RAM, DMG compatibility mode
        ;; ignores it
        ld      hl, #0xFF69
        xor     a
        ldh     (0x68), a
        ld      a, #0x5A
        ld      (hl), a
        cp      (hl)
        jr      nz, reset
        cpl
        ld      (hl), a
        cp      (hl)
        jr      z, go

reset:
        call    RUN + (unlock - stub)
        ld      a, #0x80
        ld      (0x7FE0), a
        call    RUN + (commit - stub)
3$:
        jr      3$

go:
        di
        ldh     a, (0x40)               ; LCD off, in VBlank
        add     a
        jr      nc, 5$
4$:
        ldh     a, (0x44)
        cp      #144
        jr      c, 4$
        xor     a
        ldh     (0x40), a
5$:
        xor     a                       ; the MBC as at power-on
        ld      (0x0000), a
        ld      (0x4000), a
        ld      (0x6000), a

        ld      c, #2                   ; VRAM bank 1, then bank 0
6$:
        ld      a, c
        dec     a
        ldh     (0x4F), a
        ld      hl, #0x8000
        xor     a
7$:
        ld      (hl+), a
        bit     5, h
        jr      z, 7$
        dec     c
        jr      nz, 6$
        ld      hl, #0xFE00             ; OAM
        ld      b, #0xA0
8$:
        ld      (hl+), a
        dec     b
        jr      nz, 8$

        ld      a, #0x80                ; BG and OBJ palettes white (nothing on a DMG)
        ldh     (0x68), a
        ldh     (0x6A), a
        ld      b, #64
        ld      a, #0xFF
9$:
        ldh     (0x69), a
        ldh     (0x6B), a
        dec     b
        jr      nz, 9$

        ld      hl, #(RUN + (zero - stub))      ; registers the kernel used, as at power-on
        ld      b, #(zero_end - zero)
        xor     a
10$:
        ld      c, (hl)
        inc     hl
        ldh     (c), a
        dec     b
        jr      nz, 10$
        ld      a, #0x80                ; sound on, as the boot ROM leaves it
        ldh     (0x26), a
        ld      a, #0x77
        ldh     (0x24), a
        ld      a, #0xF3
        ldh     (0x25), a
        ld      a, #0xFC
        ldh     (0x47), a

        ld      a, #0x91                ; LCD on, hand over at the start of VBlank
        ldh     (0x40), a
        xor     a
        ldh     (0x0F), a
11$:
        ldh     a, (0x44)
        cp      #144
        jr      nz, 11$

        ld      sp, #_boot_regs         ; F A C B E D L H
        pop     af
        pop     bc
        pop     de
        pop     hl
        ld      sp, #0xFFFE
        jp      0x0100

unlock:
        ld      a, #0xE1
        ld      (0x7F00), a
        ld      a, #0xE2
        ld      (0x7F10), a
        ld      a, #0xE3
        ld      (0x7F20), a
        ret
commit:
        ld      a, #0xE4
        ld      (0x7FF0), a
        ret

;; P1, SB, SC, TIMA, TMA, TAC, STAT, SCY, SCX, LYC, WY, WX, RP, SVBK, IE
zero:
        .db     0x00, 0x01, 0x02, 0x05, 0x06, 0x07, 0x41, 0x42, 0x43, 0x45, 0x4A, 0x4B, 0x56, 0x70, 0xFF
zero_end:
stub_end:
