; Bank 0 additions in the free bytes after MoveHighlightStub (00:3ea4):
;   BrowserDelay       the browser loop's 45 ms wait, skipped while UP or DOWN is held
;   CounterDigitsStub  far stub -> 02 CounterDigits (move_highlight.c), the position
;                      digits for DrawBrowserDetail's counter (dv/build.py)
;
; FileBrowserEntry_inputLoop (00:1107) starts each pass of the browser loop
; with Delay(45), the stock menu's only pacing for a held key: the D-pad
; reports a held direction on every pass. ezjr_scroll.c paces UP and DOWN by
; hFrame now (a delay, then a repeat rate that speeds up), so while either is
; held the 45 ms only slowed every move down. dv/build.py points that call at
; BrowserDelay. The pass is also taken back from the marquee's tick, which
; the loop head ($1062) counts up once a pass and which sets how soon a long
; name in the bar starts scrolling; it is left alone when 0 (a repaint just
; zeroed it), so it never wraps.

DEF Delay       EQU $3a93           ; Delay(u16 ms)
DEF hPadCur     EQU $fff6           ; RomMenuPadTrack: the last poll's report
DEF PAD_UPDOWN  EQU $0C
DEF TICK_AT     EQU 4 + $0a         ; the loop frame's sp+$0a, past our return and the ms

SECTION "browser0", ROM0[$3EA4]
BrowserDelay::
    ldh a, [hPadCur]
    and PAD_UPDOWN
    jp z, Delay                     ; same frame: Delay(45)
    ld hl, sp+TICK_AT               ; the tick's low byte
    ld a, [hl]
    and a
    ret z
    dec [hl]
    ret
