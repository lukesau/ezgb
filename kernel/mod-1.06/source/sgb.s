;; kernel/mod-1.06: SGB BOOT, the Super Game Boy header packets
;; (docs/sgb-boot.md; the packet code is the 0918 mod's SgbLaunchHook.s).
;;
;; The Jr holds the CPU in reset while its FPGA loads, so the SNES misses
;; the six packets the boot ROM sends with the cartridge header and never
;; shows a picture. With SGB BOOT on the kernel sends them again: the set of
;; six four times, with gaps of 192, 64 and 48 frames.
;;
;;   sgb_set1      the first set, blocking, 4 frames after each packet
;;                 (sgb_start in ezcfg.c calls it, first thing in main())
;;   _sgb_vbl      the VBlank handler: one packet of sets 2 to 4 per due frame
;;   _sgb_finish   before a launch: what is left of them, blocking
;;   _joypad       the library's, but for the 4 frames after a packet it
;;                 returns the last state and leaves P1 alone
;;
;; State (ezcfg.c):
;;   sgb_step   1 to 18: the next packet of sets 2 to 4. 19: the last
;;              packet's freeze. 0: nothing to do
;;   sgb_wait   frames until that step is due
;;   sgb_busy   frames of pad freeze left
;;   pad_last   what joypad last read

        .include        "global.s"

        .globl  _sgb_step, _sgb_wait, _sgb_busy, _pad_last

        .area   _HOME

;; UINT8 joypad(void): start, select, B, A, down, up, left, right in bits 7-0
_joypad::
        ld      a, (_sgb_busy)
        or      a
        jr      z, 1$
        ld      a, (_pad_last)
        ret
1$:
        ld      a, #0x20                ; the direction keys
        ldh     (.P1), a
        ldh     a, (.P1)
        ldh     a, (.P1)
        cpl
        and     #0x0F
        ld      b, a
        ld      a, #0x10                ; the buttons
        ldh     (.P1), a
        ldh     a, (.P1)
        ldh     a, (.P1)
        ldh     a, (.P1)
        ldh     a, (.P1)
        ldh     a, (.P1)
        ldh     a, (.P1)
        cpl
        and     #0x0F
        swap    a
        or      b
        ld      b, a
        ld      a, #0x30
        ldh     (.P1), a
        ld      a, b
        ld      (_pad_last), a
        ret

;; The VBlank handler (add_VBL). Nothing to do is the usual case.
_sgb_vbl::
        ld      a, (_sgb_step)
        or      a
        ret     z
        ldh     a, (__current_bank)
        push    af
        ld      a, #2
        ldh     (__current_bank), a
        ld      (0x2000), a
        call    sgb_frame
        pop     af
        ldh     (__current_bank), a
        ld      (0x2000), a
        ret

        .area   _CODE_2

;; One frame of the background send: count the freeze down, and send the
;; next packet when it is due.
sgb_frame:
        ld      a, (_sgb_busy)
        or      a
        jr      z, 1$
        dec     a
        ld      (_sgb_busy), a
1$:
        ld      hl, #_sgb_wait
        dec     (hl)
        ret     nz
        ;; fall through

;; Sends packet (step - 1) mod 6 and sets the wait to the next one
sgb_step_now:
        ld      a, (_sgb_step)
        cp      #19
        jr      c, 1$
        xor     a
        ld      (_sgb_step), a
        ret
1$:
        dec     a
2$:
        cp      #6
        jr      c, 3$
        sub     #6
        jr      2$
3$:
        call    sgb_packet
        ld      a, #4
        ld      (_sgb_busy), a
        ld      c, a
        ld      a, (_sgb_step)
        inc     a
        ld      (_sgb_step), a
        cp      #7
        jr      nz, 4$
        ld      c, #0x44                ; 64 frames after set 2, with the 4 of the freeze
4$:
        cp      #13
        jr      nz, 5$
        ld      c, #0x34                ; 48 after set 3
5$:
        ld      a, c
        ld      (_sgb_wait), a
        ret

;; void sgb_set1(void): the six packets, 4 frames after each
_sgb_set1::
        xor     a
1$:
        push    af
        call    sgb_packet
        ld      d, #4
        call    frames
        pop     af
        inc     a
        cp      #6
        jr      nz, 1$
        ret

;; void sgb_finish(void) __banked: sets 2 to 4 are not all out and a game
;; is about to start. A game never sends the header again, so the rest goes
;; now, with the gaps the background would have left.
        b_sgb_finish = 2
        .globl  b_sgb_finish
_sgb_finish::
        ld      a, (_sgb_step)
        or      a
        ret     z
        di
1$:
        ld      a, (_sgb_step)
        or      a
        jr      z, 2$
        ld      a, (_sgb_wait)
        ld      d, a
        call    frames
        call    sgb_step_now
        jr      1$
2$:
        ld      (_sgb_busy), a
        ei
        ret

;; Packet A (0 to 5): command $F1 + 2A, the sum of its 14 header bytes,
;; and the bytes, from $0104 + 14A, zero past $014F
sgb_packet:
        push    af
        ld      c, a
        add     a, a
        add     a, a
        add     a, a
        sub     c
        add     a, a
        add     a, #0x04
        ld      l, a
        ld      h, #0x01
        push    hl
        ld      c, #14
        ld      e, #0
1$:
        call    header_byte
        add     a, e
        ld      e, a
        dec     c
        jr      nz, 1$
        pop     hl
        pop     af
        add     a, a
        add     a, #0xF1
        ld      d, a
        xor     a                       ; the reset pulse
        ldh     (.P1), a
        ld      a, #0x30
        ldh     (.P1), a
        call    send_byte
        ld      d, e
        call    send_byte
        ld      c, #14
2$:
        call    header_byte
        ld      d, a
        call    send_byte
        dec     c
        jr      nz, 2$
        ld      a, #0x20                ; the stop bit
        ldh     (.P1), a
        ld      a, #0x30
        ldh     (.P1), a
        ret

header_byte:
        ld      a, l
        cp      #0x50
        ld      a, #0
        jr      nc, 1$
        ld      a, (hl)
1$:
        inc     hl
        ret

;; D, low bit first: P1 = $10 for a 1 and $20 for a 0, then $30
send_byte:
        ld      b, #8
1$:
        ld      a, #0x10
        rr      d
        jr      c, 2$
        ld      a, #0x20
2$:
        ldh     (.P1), a
        ld      a, #0x30
        ldh     (.P1), a
        dec     b
        jr      nz, 1$
        ret

;; D frames by counting cycles, so it does not need the LCD or interrupts
frames:
        ld      bc, #0x09CC
1$:
        dec     bc
        ld      a, b
        or      c
        jr      nz, 1$
        dec     d
        jr      nz, frames
        ret
