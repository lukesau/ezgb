;; BrowserPoll: the browser loop's wait and joypad().
;; UINT8 BrowserPoll (void), from SdMenuMain (kernel/stock/src/kernel.c).
;; Two VBlanks, or none while UP or DOWN is held (BrowserMove times the
;; repeat); the report before this one is kept in $FFF5 for the ROM menu
;; and the repeat (rom_menu.c, browser_nav.c).
	.area	_MOD0A
BrowserPoll::
_BrowserPoll::
	ldh	a,(#0xf6)
	and	#0x0c
	jr	nz,1$
	call	WaitVBlankFlag
	call	WaitVBlankFlag
1$:
	ldh	a,(#0xf6)
	ldh	(#0xf5),a
	call	ReadJoypad
	ld	a,e
	ldh	(#0xf6),a
	ret
