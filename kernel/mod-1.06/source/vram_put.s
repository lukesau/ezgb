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

;; void color(UINT8 fg, UINT8 bg, UINT8 mode): the library's, with the theme's
;; accent (ezcfg.c, theme_apply). The kernel draws a highlight as the
;; background color on the ink, color(WHITE, BLACK), and a dialog as the ink
;; on dark gray:
;;   bg 3            becomes acc_idx when that is not 0, and fg with it when
;;                   it is 3 too (a solid fill)
;;   fg 2 and bg 2   a check mark or the frame under the cursor: index 2 is
;;                   a color theme's accent already; DV's is 1
;;   bg 2            becomes pop_idx
;;
;; The library has color() in one module with the three variables and
;; set_1bpp_colors_ex (the same code under another name), so all of that
;; module is here and the linker never takes the library's.
        .globl  _acc_idx, _pop_idx

        .area   _INITIALIZED
__current_1bpp_colors::
.fg_colour::
        .ds     1
.bg_colour::
        .ds     1
.draw_mode::
        .ds     1

        .area   _INITIALIZER
        .db     0x03, 0x00, 0x00

        .area   _HOME

_set_1bpp_colors_ex::
        LDA     HL,2(SP)
        LD      A,(HL+)
        LD      (.fg_colour),A
        LD      A,(HL+)
        LD      (.bg_colour),A
        LD      A,(HL)
        LD      (.draw_mode),A
        RET

_color::
        LDA     HL,2(SP)
        LD      A,(HL+)
        LD      B,A             ; fg
        LD      A,(HL+)
        LD      C,A             ; bg
        LD      A,(HL)
        LD      (.draw_mode),A
        LD      A,C
        CP      #3
        JR      NZ,2$
        LD      A,(_acc_idx)
        OR      A
        JR      Z,9$
        LD      C,A
        LD      A,B
        CP      #3
        JR      NZ,9$
        LD      B,C
        JR      9$
2$:
        CP      #2
        JR      NZ,9$
        LD      A,B
        CP      #2
        JR      NZ,3$
        LD      A,(_acc_idx)
        DEC     A
        JR      NZ,9$
        LD      BC,#0x0101
        JR      9$
3$:
        LD      A,(_pop_idx)
        LD      C,A
9$:
        LD      A,B
        LD      (.fg_colour),A
        LD      A,C
        LD      (.bg_colour),A
        RET

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

;; void vram_copy_line(UINT8 *dst, UINT8 *src): one pixel row of the
;; screen, the 20 tiles across it, both planes, copied from src to dst
;; (the address of the row's first plane byte in the first tile; tiles are
;; 16 bytes apart). For scrolling the file list by moving the rows that
;; stay (list12.c, list8.c).
;;
;; Seven batches of three tiles, the last one a tile back so it ends on
;; tile 20: reads and writes both need VRAM, so each batch starts at the
;; beginning of mode 0 with interrupts off, as font12.c's blit_col1 does
;; (its comment has why a batch from line 143 on waits for lines 145 to
;; 150 with interrupts on). A batch is 52 cycles; mode 0 and the mode 2
;; after it are 71, and the sync is up to 8 late.
_vram_copy_line::
        LD      H,B
        LD      L,C             ; HL = src, DE = dst
        LD      B,#7
1$:
        PUSH    BC
        LD      BC,#15
2$:
        DI
        LDH     A,(.STAT)
        AND     #3
        CP      #1
        JR      NZ,3$
        LDH     A,(.LY)
        CP      #144
        JR      C,3$
        CP      #152
        JR      NC,3$
        JR      7$
3$:
        LDH     A,(.LY)
        CP      #143
        JR      C,5$
        EI
4$:
        LDH     A,(.LY)
        CP      #143
        JR      C,2$
        CP      #145
        JR      C,4$
        CP      #151
        JR      C,2$
        JR      4$
5$:
        LDH     A,(.STAT)
        AND     #3
        CP      #3
        JR      NZ,5$
6$:
        LDH     A,(.STAT)
        AND     #3
        JR      NZ,6$
7$:
        LD      A,(HL+)
        LD      (DE),A
        INC     E
        LD      A,(HL)
        LD      (DE),A
        ADD     HL,BC
        LD      A,E
        ADD     #15
        LD      E,A
        JR      NC,11$
        INC     D
11$:
        LD      A,(HL+)
        LD      (DE),A
        INC     E
        LD      A,(HL)
        LD      (DE),A
        ADD     HL,BC
        LD      A,E
        ADD     #15
        LD      E,A
        JR      NC,12$
        INC     D
12$:
        LD      A,(HL+)
        LD      (DE),A
        INC     E
        LD      A,(HL)
        LD      (DE),A
        EI
        ;; on to the next tile, or back one before the last batch
        POP     BC
        DEC     B
        RET     Z
        LD      A,B
        DEC     A
        JR      Z,9$
        LD      A,L
        ADD     #15
        LD      L,A
        JR      NC,8$
        INC     H
8$:
        LD      A,E
        ADD     #15
        LD      E,A
        JR      NC,1$
        INC     D
        JR      1$
9$:
        ;; HL and DE are on the second byte of tile 3n + 2: the last batch
        ;; starts at tile 17, which is that tile again
        DEC     HL
        DEC     DE
        JR      1$
