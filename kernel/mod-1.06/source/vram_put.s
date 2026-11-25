;; kernel/mod-1.06: one tile row written to VRAM, both planes.
;;
;;   void vram_put2(UINT8 *dst, UINT16 planes);
;;
;; dst comes in DE and planes in BC (C is plane 0, B is plane 1). Interrupts
;; are off from before the STAT wait to the second write, and the two writes
;; are seven cycles after the STAT sample that passed: a passing sample only
;; guarantees about twenty (docs/drawing-timing.md). In _HOME, so any bank
;; can call it.

        .include        "global.s"

        .area   _HOME

_vram_put2::
        LD      H,D
        LD      L,E
        DI
1$:
        LDH     A,(.STAT)
        AND     #STATF_BUSY
        JR      NZ,1$
        LD      A,C
        LD      (HL+),A
        LD      (HL),B
        EI
        RET

;; UINT8 draw_colors(void): the library's foreground and background color,
;; foreground * 4 + background. They are the library's variables and have
;; no C name.
        .globl  .fg_colour, .bg_colour
_draw_colors::
        LD      A,(.fg_colour)
        AND     #0x03
        ADD     A
        ADD     A
        LD      B,A
        LD      A,(.bg_colour)
        AND     #0x03
        OR      B
        RET
