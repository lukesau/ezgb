	;; EZ Flash Jr kernel runtime: GBDK 2.96a crt0.s as EZ Flash modified it.
	;; GBDK library code, GPLv2 with linking exception (LICENSE_GPLV2_LE).
	;;
	;; Changes from GBDK 2.96a (identical to GBDK-2020 3.0.1 here) are marked
	;; ";; ezflash:". Global labels with no leading dot are the names the
	;; kernel disassembly uses (re/kernel/1.05e-0731/kernel.sym); they alias
	;; the GBDK names so the rest of the rgbds source links against them.

	.include	"global.s"

	;; ezflash: MODE_TABLE moved up two bytes (global.s has 0x01E0)
	.MODE_TABLE	= 0x01E2

	.globl	BootUnpackWramTables
	.globl	BatteryCheck

	;; ****************************************
	;; Beginning of module
	;; BANKED: checked
	.title	"Runtime"
	.module	Runtime
	.area	_HEADER (ABS)

	;; Standard header for the GB
	.org	0x00
RST_00::
	RET			; Empty function (default for interrupts)

	.org	0x10
	.byte	0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01
	.byte	0x01,0x02,0x04,0x08,0x10,0x20,0x40,0x80

	;; Interrupt vectors
	.org	0x40		; VBL
VBlankInterrupt::
.int_VBL:
	PUSH	HL
	LD	HL,#.int_0x40
	JP	.int

	.org	0x48		; LCD
LCDCInterrupt::
.int_LCD:
	PUSH	HL
	LD	HL,#.int_0x48
	JP	.int

	.org	0x50		; TIM
TimerOverflowInterrupt::
.int_TIM:
	PUSH	HL
	LD	HL,#.int_0x50
	JP	.int

	.org	0x58		; SIO
SerialTransferCompleteInterrupt::
.int_SIO:
	PUSH	HL
	LD	HL,#.int_0x58
	JP	.int

	.org	0x60		; JOY
JoypadTransitionInterrupt::
.int_JOY:
	PUSH	HL
	LD	HL,#.int_0x60
	JP	.int

	;; ezflash: count nested handlers in __int_nest; only the outermost
	;; one returns with RETI, inner ones with RET
RunCallbackList::
.int:
	PUSH	AF
	PUSH	BC
	PUSH	DE
	LD	A,(__int_nest)
	INC	A
	LD	(__int_nest),A
1$:
	LD	A,(HL+)
	OR	(HL)
	JR	Z,2$
	PUSH	HL
	LD	A,(HL-)
	LD	L,(HL)
	LD	H,A
	CALL	CallHL	; ezflash name; GBDK: CALL 3$
	POP	HL
	INC	HL
	JR	1$
2$:
	LD	A,(__int_nest)
	DEC	A
	LD	(__int_nest),A
	JR	Z,4$
	POP	DE
	POP	BC
	POP	AF
	POP	HL
	RET
4$:
	POP	DE
	POP	BC
	POP	AF
	POP	HL
	RETI

CallHL::
	JP	(HL)

	;; GameBoy Header

	;; DO NOT CHANGE...
	.org	0x100
Boot::
.header:
	NOP
	JP	0x150
	.byte	0xCE,0xED,0x66,0x66
	.byte	0xCC,0x0D,0x00,0x0B
	.byte	0x03,0x73,0x00,0x83
	.byte	0x00,0x0C,0x00,0x0D
	.byte	0x00,0x08,0x11,0x1F
	.byte	0x88,0x89,0x00,0x0E
	.byte	0xDC,0xCC,0x6E,0xE6
	.byte	0xDD,0xDD,0xD9,0x99
	.byte	0xBB,0xBB,0x67,0x63
	.byte	0x6E,0x0E,0xEC,0xCC
	.byte	0xDD,0xDC,0x99,0x9F
	.byte	0xBB,0xB9,0x33,0x3E

	;; Title of the game
	;; ezflash: "EZGB", padded with zeros to 0x144
	.org	0x134
	.ascii	"EZGB"
	.byte	0,0,0,0,0,0,0,0,0,0,0,0

	.org	0x144
	.byte	0,0,0

	;; ezflash: cartridge type 0x01 (MBC1)
	.org	0x147
	.byte	0x01

	;; ROM size is 32kB
	.org	0x148
	.byte	0

	;; RAM size is 0kB
	.org	0x149
	.byte	0

	;; ezflash: maker ID 0x00,0x00 and version 0x01 are unchanged; the
	;; complement and global checksums are as shipped
	.org	0x14A
	.byte	0x00,0x00

	;; Version number
	.org	0x14C
	.byte	0x01

	;; Complement check
	.org	0x14D
	.byte	0xBD

	;; Checksum
	.org	0x14E
	.byte	0x7B,0x57

	;; ****************************************
	.org	0x150
KernelEntry::
.code_start:
	;; Beginning of the code
	DI			; Disable interrupts
	LD	D,A		; Store CPU type in D
	XOR	A
	;; Initialize the stack
	LD	SP,#.STACK
	;; Clear from 0xC000 to 0xDFFF
	LD	HL,#0xDFFF
	LD	C,#0x20
	LD	B,#0x00
1$:
	LD	(HL-),A
	DEC	B
	JR	NZ,1$
	DEC	C
	JR	NZ,1$
	;; Clear from 0xFE00 to 0xFEFF
	LD	HL,#0xFEFF
	LD	B,#0x00
2$:
	LD	(HL-),A
	DEC	B
	JR	NZ,2$
	;; Clear from 0xFF80 to 0xFFFF
	LD	HL,#0xFFFF
	LD	B,#0x80
3$:
	LD	(HL-),A
	DEC	B
	JR	NZ,3$
; 	LD	(.mode),A	; Clearing (.mode) is performed when clearing RAM
	;; Store CPU type
	LD	A,D
	LD	(__cpu),A

	;; ezflash: select ROM bank 1 and clear the interrupt nesting count
	LD	A,#0x01
	LD	(__current_bank),A
	LD	(.MBC1_ROM_PAGE),A
	XOR	A
	LD	(__int_nest),A

	;; Turn the screen off
	CALL	.display_off

	;; Initialize the display
	XOR	A
	LDH	(.SCY),A
	LDH	(.SCX),A
	LDH	(.STAT),A
	LDH	(.WY),A
	LD	A,#0x07
	LDH	(.WX),A

	;; Copy refresh_OAM routine to HIRAM
	LD	BC,#.refresh_OAM
	LD	HL,#.start_refresh_OAM
	LD	B,#.end_refresh_OAM-.start_refresh_OAM
4$:
	LD	A,(HL+)
	LDH	(C),A
	INC	C
	DEC	B
	JR	NZ,4$

	;; Install interrupt routines
	LD	BC,#.vbl
	CALL	.add_VBL
	LD	BC,#.serial_IO
	CALL	.add_SIO

	;; Standard color palettes
	LD	A,#0b11100100	; Grey 3 = 11 (Black)
				; Grey 2 = 10 (Dark grey)
				; Grey 1 = 01 (Light grey)
				; Grey 0 = 00 (Transparent)
	LDH	(.BGP),A
	LDH	(.OBP0),A
	LD	A,#0b00011011
	LDH	(.OBP1),A

	;; Turn the screen on
	LD	A,#0b11000000	; LCD		= On
				; WindowBank	= 0x9C00
				; Window	= Off
				; BG Chr	= 0x8800
				; BG Bank	= 0x9800
				; OBJ		= 8x8
				; OBJ		= Off
				; BG		= Off
	LDH	(.LCDC),A
	XOR	A
	LDH	(.IF),A
	LD	A,#0b00001001	; Pin P10-P13	=   Off
				; Serial I/O	=   On
				; Timer Ovfl	=   Off
				; LCDC		=   Off
				; V-Blank	=   On
	LDH	(.IE),A

	XOR	A
	LDH	(.NR52),A	; Turn sound off
	LDH	(.SC),A		; Use external clock
	LD	A,#.DT_IDLE
	LDH	(.SB),A		; Send IDLE byte
	LD	A,#0x80
	LDH	(.SC),A		; Use external clock

	XOR	A		; Erase the malloc list
;	LD	(_malloc_heap_start+0),A
;	LD	(_malloc_heap_start+1),A
	;; ezflash: the system clock is zeroed here
	LD	(.sys_time+0),A	; Zero the system clock
	LD	(.sys_time+1),A

	;; ezflash: no gsinit, EI or banked_call _main; the kernel unpacks its
	;; WRAM tables from bank 1 and runs its main loop from BatteryCheck
	CALL	BootUnpackWramTables
	CALL	BatteryCheck
HaltLoop::
_exit::
99$:
	HALT
	JR	99$		; Wait forever

	.org	.MODE_TABLE
	;; Jump table for modes
	RET

	;; ****************************************

	;; Ordering of segments for the linker
	;; Code that really needs to be in bank 0
	.area	_HOME
	;; Similar to _HOME
	.area	_BASE
	;; Code
	.area	_CODE
	;; Constant data
	.area	_LIT
	;; Constant data used to init _DATA
	.area	_GSINIT
	.area	_GSINITTAIL
	.area	_GSFINAL
	;; Initialised in ram data
	.area	_DATA
	;; Uninitialised ram data
	.area	_BSS
	;; For malloc
	.area	_HEAP

	.area	_BSS
__cpu::
	.ds	0x01		; GB type (GB, PGB, CGB)
.mode::
	.ds	0x01		; Current mode
__io_out::
	.ds	0x01		; Byte to send
__io_in::
	.ds	0x01		; Received byte
__io_status::
	.ds	0x01		; Status of serial IO
.vbl_done::
	.ds	0x01		; Is VBL interrupt finished?
__current_bank::
	.ds	0x01		; Current MBC1 style bank.
	;; ezflash: interrupt nesting count (DiNest/EiNest, .int)
__int_nest::
	.ds	0x01
.sys_time::
_sys_time::
	.ds	0x02		; System time in VBL units
.int_0x40::
	.blkw	0x08
.int_0x48::
	.blkw	0x08
.int_0x50::
	.blkw	0x08
.int_0x58::
	.blkw	0x08
.int_0x60::
	.blkw	0x08

	.area	_HOME
	;; Call the initialization function for the mode specified in HL
SetGfxMode::
.set_mode::
	LD	A,L
	LD	(.mode),A

	;; AND to get rid of the extra flags
	AND	#0x03
	LD	L,A
	LD	BC,#.MODE_TABLE
	SLA	L		; Multiply mode by 4
	SLA	L
	ADD	HL,BC
	JP	(HL)		; Jump to initialization routine

	;; Add interrupt routine in BC to the interrupt list
RemoveVBlankCallback::
.remove_VBL::
	LD	HL,#.int_0x40
	JP	.remove_int
RemoveLcdCallback::
.remove_LCD::
	LD	HL,#.int_0x48
	JP	.remove_int
RemoveTimerCallback::
.remove_TIM::
	LD	HL,#.int_0x50
	JP	.remove_int
RemoveSerialCallback::
.remove_SIO::
	LD	HL,#.int_0x58
	JP	.remove_int
RemoveJoypadCallback::
.remove_JOY::
	LD	HL,#.int_0x60
	JP	.remove_int
RegisterVBlankCallback::
.add_VBL::
	LD	HL,#.int_0x40
	JP	.add_int
RegisterLcdCallback::
.add_LCD::
	LD	HL,#.int_0x48
	JP	.add_int
RegisterTimerCallback::
.add_TIM::
	LD	HL,#.int_0x50
	JP	.add_int
RegisterSerialCallback::
.add_SIO::
	LD	HL,#.int_0x58
	JP	.add_int
RegisterJoypadCallback::
.add_JOY::
	LD	HL,#.int_0x60
	JP	.add_int

	;; Remove interrupt BC from interrupt list HL if it exists
	;; Abort if a 0000 is found (end of list)
	;; Will only remove last int on list
RemoveCallbackSlot::
.remove_int::
1$:
	LD	A,(HL+)
	LD	E,A
	LD	D,(HL)
	OR	D
	RET	Z		; No interrupt found

	LD	A,E
	CP	C
	JR	NZ,1$
	LD	A,D
	CP	B
	JR	NZ,1$

	XOR	A
	LD	(HL-),A
	LD	(HL),A
	INC	A		; Clear Z flag

	;; Now do a memcpy from here until the end of the list
	LD	D,H
	LD	E,L
	DEC	DE

	INC	HL
2$:
	LD	A,(HL+)
	LD	(DE),A
	LD	B,A
	INC	DE
	LD	A,(HL+)
	LD	(DE),A
	INC	DE
	OR	B
	RET	Z
	JR	2$

	;; Add interrupt routine in BC to the interrupt list in HL
InstallCallbackSlot::
.add_int::
1$:
	LD	A,(HL+)
	OR	(HL)
	JR	Z,2$
	INC	HL
	JR	1$
2$:
	LD	(HL),B
	DEC	HL
	LD	(HL),C
	RET


	;; VBlank interrupt
VBlankCallback::
.vbl:
	LD	HL,#.sys_time
	INC	(HL)
	JR	NZ,2$
	INC	HL
	INC	(HL)
2$:
	CALL	.refresh_OAM

	LD	A,#0x01
	LD	(.vbl_done),A
	RET

	;; Wait for VBL interrupt to be finished
WaitVBlankFlag::
.wait_vbl_done::
_wait_vbl_done::
	;; Check if the screen is on
	LDH	A,(.LCDC)
	ADD	A
	RET	NC		; Return if screen is off
	XOR	A
	DI
	LD	(.vbl_done),A	; Clear any previous sets of vbl_done
	EI
1$:
	HALT			; Wait for any interrupt
	NOP			; HALT sometimes skips the next instruction
	LD	A,(.vbl_done)	; Was it a VBlank interrupt?
	;; Warning: we may lose a VBlank interrupt, if it occurs now
	OR	A
	JR	Z,1$		; No: back to sleep!

	XOR	A
	LD	(.vbl_done),A
	RET

LcdOff::
.display_off::
_display_off::
	;; Check if the screen is on
	LDH	A,(.LCDC)
	ADD	A
	RET	NC		; Return if screen is off
1$:				; We wait for the *NEXT* VBL
	LDH	A,(.LY)
	CP	#0x92		; Smaller than or equal to 0x91?
	JR	NC,1$		; Loop until smaller than or equal to 0x91
2$:
	LDH	A,(.LY)
	CP	#0x91		; Bigger than 0x90?
	JR	C,2$		; Loop until bigger than 0x90

	LDH	A,(.LCDC)
	AND	#0b01111111
	LDH	(.LCDC),A	; Turn off screen
	RET

	;; Copy OAM data to OAM RAM
OamDmaStub::
.start_refresh_OAM:
	LD	A,#>.OAM
	LDH	(.DMA),A	; Put A into DMA registers
	LD	A,#0x28		; We need to wait 160 ns
1$:
	DEC	A
	JR	NZ,1$
	RET
.end_refresh_OAM:

	;; Serial interrupt
SerialCallback::
.serial_IO::
	LD	A,(__io_status) ; Get status

	CP	#.IO_RECEIVING
	JR	NZ,10$

	;; Receiving data
	LDH	A,(.SB)		; Get data byte
	LD	(__io_in),A	; Store it
	LD	A,#.IO_IDLE
	JR	11$

10$:

	CP	#.IO_SENDING
	JR	NZ,99$

	;; Sending data
	LDH	A,(.SB)		; Get data byte
	CP	#.DT_RECEIVING
	JR	Z,11$
	LD	A,#.IO_ERROR
	JR	12$
11$:
	LD	A,#.IO_IDLE
12$:
	LD	(__io_status),A ; Store status

	XOR	A
	LDH	(.SC),A		; Use external clock
	LD	A,#.DT_IDLE
	LDH	(.SB),A		; Reply with IDLE byte
99$:
	LD	A,#0x80
	LDH	(.SC),A		; Enable transfer with external clock
	RET

SetGfxModeStack::
_mode::
	LDA	HL,2(SP)	; Skip return address
	LD	L,(HL)
	LD	H,#0x00
	CALL	.set_mode
	RET

GetGfxMode::
_get_mode::
	LD	HL,#.mode
	LD	E,(HL)
	RET

	;; ezflash: interrupt enable/disable nest; only the outermost
	;; _enable_interrupts turns interrupts back on. _reset is removed.
DiNest::
_disable_interrupts::
	DI
	LD	A,(__int_nest)
	INC	A
	LD	(__int_nest),A
	RET

EiNest::
_enable_interrupts::
	LD	A,(__int_nest)
	DEC	A
	LD	(__int_nest),A
	RET	NZ
	EI
	RET

SetIeReg::
_set_interrupts::
	CALL	_disable_interrupts
	LDA	HL,2(SP)	; Skip return address
	XOR	A
	LDH	(.IF),A		; Clear pending interrupts
	LD	A,(HL)
	LDH	(.IE),A
	CALL	_enable_interrupts
	RET

RemoveVBlankCallbackArg::
_remove_VBL::
	PUSH	BC
	LDA	HL,4(SP)	; Skip return address and registers
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	CALL	.remove_VBL
	POP	BC
	RET

RemoveLcdCallbackArg::
_remove_LCD::
	PUSH	BC
	LDA	HL,4(SP)	; Skip return address and registers
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	CALL	.remove_LCD
	POP	BC
	RET

RemoveTimerCallbackArg::
_remove_TIM::
	PUSH	BC
	LDA	HL,4(SP)	; Skip return address and registers
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	CALL	.remove_TIM
	POP	BC
	RET

RemoveSerialCallbackArg::
_remove_SIO::
	PUSH	BC
	LDA	HL,4(SP)	; Skip return address and registers
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	CALL	.remove_SIO
	POP	BC
	RET

RemoveJoypadCallbackArg::
_remove_JOY::
	PUSH	BC
	LDA	HL,4(SP)	; Skip return address and registers
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	CALL	.remove_JOY
	POP	BC
	RET

RegisterVBlankCallbackArg::
_add_VBL::
	PUSH	BC
	LDA	HL,4(SP)	; Skip return address and registers
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	CALL	.add_VBL
	POP	BC
	RET

RegisterLcdCallbackArg::
_add_LCD::
	PUSH	BC
	LDA	HL,4(SP)	; Skip return address and registers
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	CALL	.add_LCD
	POP	BC
	RET

RegisterTimerCallbackArg::
_add_TIM::
	PUSH	BC
	LDA	HL,4(SP)	; Skip return address and registers
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	CALL	.add_TIM
	POP	BC
	RET

RegisterSerialCallbackArg::
_add_SIO::
	PUSH	BC
	LDA	HL,4(SP)	; Skip return address and registers
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	CALL	.add_SIO
	POP	BC
	RET

RegisterJoypadCallbackArg::
_add_JOY::
	PUSH	BC
	LDA	HL,4(SP)	; Skip return address and registers
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	CALL	.add_JOY
	POP	BC
	RET

	;; ezflash: _clock and __printTStates are removed

	;; Performs a long call.
	;; Basically:
	;;   call banked_call
	;;   .dw low
	;;   .dw bank
	;;   remainder of the code
	;; ezflash: the bank switch runs with interrupts held off through
	;; the nesting count, and the page is read before the current bank
	;; is pushed
FarCallTrampoline::
banked_call::
	call	_disable_interrupts
	pop	hl		; Get the return address
	ld	e,(hl)		; Fetch the call address
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	a,(hl+)		; ...and page
	inc	hl		; Yes this should be here
	push	hl		; Push the real return address
	ld	b,a
	ld	a,(__current_bank)
	push	af		; Push the current bank onto the stack
	ld	a,b
	ld	(__current_bank),a
	ld	(.MBC1_ROM_PAGE),a	; Perform the switch
	call	_enable_interrupts
	ld	hl,#banked_ret	; Push the fake return address
	push	hl
	ld	l,e
	ld	h,d
	jp	(hl)

banked_ret::
	call	_disable_interrupts
	pop	af		; Pop the old bank
	ld	(.MBC1_ROM_PAGE),a
	ld	(__current_bank),a
	call	_enable_interrupts
	ret
