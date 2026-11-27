# FW5-0918 against FW6

FW6 is the firmware EZ Flash released with kernel 1.06e. This page
describes the build of 2026-11-27 (`Update_FW6_20261127.gb`), which
replaced the one of 2026-11-24 after EZ Flash withdrew that. Its updater
writes slot B only, like FW4's and FW5's, and the updater's program is
FW5's with another label and a longer wait
([stage0/updater](../updater/README.md)). The whole of its slice logic is
proven against readable Verilog ([stage0/fw6/](../fw6/README.md)), so
everything below is read from the design, not from testing: FW6 has not
been run on a cart here. What sits outside the slices, the clock buffers
and what feeds them, is read from the bitstream and not part of that
proof.

> **Correction (2026-11-27).** From 2026-11-24 this page and `stage0/fw6`
> described the build released that day (`Update_FW6_20261124.gb`), which
> EZ Flash rolled back two days later. The build of 2026-11-27 differs
> from it where [The build of 2026-11-24](#the-build-of-2026-11-24) says.
> What the page said of `rtc_init` (the clock chip reset only when its
> seconds read exactly `$80`), of the PicoBlaze's gated clock and of the
> SD clock divider (383.5 kHz for identification) was true of that build
> and is not true of this one. Anything built on the 11-24 files, the
> FW6 mod included, describes a firmware EZ Flash no longer ships.

> **Correction (2026-11-24).** Until the release this page described a
> test build of 2026-11-17 (`Update_FW6_11-17.gb`), and so did
> `stage0/fw6`. The release is another build and differs from it where
> [The test build](#the-test-build) says. What the page said of the game
> clock (no latch, nothing but a game's write loads it) was true of the
> test build and is not true of FW6 as released.

## In short

| | FW5-0918 | FW6 |
|---|---|---|
| The version byte (`$7FC0 = 4`) | `$05` | `$06` |
| SD identification clock | divider `$48`, 336 kHz | the program loads `$3F`; the divider keeps five bits, so `$1F`: 767 kHz |
| The PicoBlaze's clock | stopped in a game unless `$7F37` bit 7 is set | runs always; `$7F37` bit 7 has no register |
| A game's clock (MBC3) | the PicoBlaze computes it from the clock chip | counters in the FPGA |
| Loading that clock | the kernel writes `$A018-$A01C`, the PicoBlaze takes it from there | the same write loads the counters directly, as a game's write does |
| The `$6000` latch | copies the clock for the game to read | the same; until a game's first latch it reads the clock live |
| The kernel reading that clock | not possible | `$A018-$A01C` read it, live |
| Stage1 | bit planes in eight block RAMs and a ninth of bytes | the same bytes, in nine block RAMs of 2 KB; past `$47FF` it reads `$FF` |
| SD controller, loader, flash, license check | | the same but for the widths under [The SD controller](#the-sd-controller); the first program differs in two words |
| Timeouts and CRC handling of the SD controller | timeouts 0, a data CRC error never completes | the same: [sd-recovery.md](sd-recovery.md) applies to FW6 as it does to FW5 |
| The PicoBlaze's timer (ports `A0`, `A1`) | paces the debug bytes | gone: `A0` reads 0 |

Everything else is FW5-0918 placed and routed again: the Game Boy
registers and bus, the unlock sequence, the fast-load key, the RTC bridge
the kernel reads, the memory controller, the reset logic.

## The PicoBlaze's programs

The first program differs in two words:

| Word | FW5-0918 | FW6 | |
|---|---|---|---|
| `$035` | `JUMP game_clock` | `JUMP idle` | the PicoBlaze no longer computes a game's clock; the routine is still there, never run |
| `$120` | `LOAD s0, 48` | `LOAD s0, 3F` | the SD clock divider `sdc_init` sets for card identification. The clock is CLK2X / (2 x (divider + 1)), and FW6's divider keeps bits 4:0 of what is written ([sd_clock_divider.v](../fw6/sd_clock_divider.v)), so `$3F` divides as `$1F`: 49.09 MHz / 64 = 767 kHz, where FW5's `$48` gives 336 kHz. The SD specification allows 400 kHz for identification |

`rtc_init` is FW5's: it resets the clock chip when the seconds register's
bit 7 (power was lost) is set.

The second program loses one instruction: the `CALL delay_huge` at
`$1BD`, in the MultiBoot check, and the code after it moves up a word.

## The game clock

FW5 runs a game's clock through the PicoBlaze both ways
([firmware-diff.md](firmware-diff.md#the-game-clock)). FW6 keeps it in
the FPGA ([mbc3_rtc.v](../fw6/mbc3_rtc.v)):

- a 26-bit counter of PicoBlaze clock cycles ticks the second when it
  reaches 49,090,908, which is where the 49.0909 MHz figure for CLK2X
  comes from in EZ Flash's design;
- seconds, minutes, hours and a nine-bit day count from it, with the
  MBC3's field widths and its behavior past the range: seconds 60 to 63
  count on and wrap without a carry;
- DH bit 6 stops the clock and bit 7 is the day carry.

The counters run on the PicoBlaze's clock, which FW6 never stops
([The clocks](#the-clocks)), so the time runs in the kernel and in any
game.

**Loading it.** A write to a clock register flips a toggle on `/WR`
([mbc3_clock.v](../fw6/mbc3_clock.v)). The toggle crosses to the
PicoBlaze clock through two flip-flops, and the change loads that
counter from the written value. A seconds write also clears the
one-second counter. Two writes flip the toggles: a game's, to clock
registers `$08-$0C` through `$A000-$BFFF`, and the kernel's, to
`$A018-$A01C` of its register window. So the kernel sets a game's clock
the way the 1.05e kernel always did, with no PicoBlaze in between. Only
the bits the MBC3 has are kept: six of seconds and minutes, five of
hours, and bits 0, 6 and 7 of DH. A DL write loads the day's bit 8 as
well, from the DH value last written; a DH write loads bit 8, the halt
bit and the carry and leaves the low eight bits alone.

**Reading it.** A game that writes `$00` and then `$01` to `$6000-$7FFF`
gets a copy of the five registers, and reads the copy from then on. Until
its first latch after a console reset it reads the counters as they are.
The kernel reads them at `$A018-$A01C`, always as they are.

Nothing loads the counters from the clock chip. They start at zero when
the FPGA is configured, and the time a game sees is what the kernel
wrote before launching it plus what has run since.

The PicoBlaze's five command bits that told it of a game's write in FW5
are now the toggles. The routine that read them is the one `$035` no
longer jumps to.

## Stage1

FW5 stores stage1's first 16 KB as eight block RAMs of one bit each and
the next 2 KB as bytes in a ninth, and registers the address bits that
pick between them. FW6 stores it as bytes, 2 KB to a block RAM, nine in
address order (`X3Y17 X3Y1 X3Y25 X3Y13 X3Y21 X3Y5 X3Y29 X3Y9 X19Y17`),
all enabled together, and registers the byte that A14-A11 pick
([gb_bus.v](../fw6/gb_bus.v)). The contents are FW5-0918's stage1 with
`$FF` after its last byte, and a read past `$47FF` gives `$FF` where
FW5 gives `$00`.

## The clocks

Read from the clock buffers in the bitstream:

| Clock | FW5-0918 | FW6 |
|---|---|---|
| PicoBlaze | CLK2X through a buffer that passes it in kernel mode, and in a game only while `$7F37` bit 7 is set | CLK2X, always |
| SD controller's register side | CLK2X through a buffer that passes it in kernel mode | the same net as the PicoBlaze's, always |
| The loader's write to memory (16 registers of `sd_mem_path`) | the DCM's CLKFX (x10/3, 81.8 MHz) while the loader is busy | CLK2X (49.09 MHz) while the loader is busy; the buffer's select is the busy flag registered on the falling edge ([gb_bus.v](../fw6/gb_bus.v)) |
| Memory controller | CLKFX | CLKFX |

`$7F37` bit 7 was the kernel's way to keep the PicoBlaze running in a
game with a clock. FW6 has no register behind it
([gb_regs.v](../fw6/gb_regs.v)): the write does nothing, and the
PicoBlaze runs in every game.

## The SD controller

The registers are narrower than FW5's
([sd_controller_wb.v](../fw6/sd_controller_wb.v),
[sd_cmd_master.v](../fw6/sd_cmd_master.v)):

| | FW4, FW5 | FW6 |
|---|---|---|
| Clock divider | 8 bits | 5 bits |
| Command timeout and its watchdog | 16 bits | 8 bits |

The program writes 0 to the timeout, so that width changes nothing it
does. The divider's does: see `$120` above.

In 4-bit mode the data cycle count is FW4's again,
`((blksize | 4) << 1) + 2` where FW5-0918 has `(blksize << 1) + 2`
([sd_data_serial.v](../fw6/sd_data_serial.v)). With 512-byte blocks the
two are equal.

## The PicoBlaze's timer

FW5-0918 has a timer on ports `A0` and `A1` that paces the program's
debug bytes: `dbg_putc` waits while `A0` bit 2 is set. FW6 has no timer.
`OUTPUT A1` does nothing and `INPUT A0` reads 0, so `dbg_putc` returns at
once in its ten call sites. The delay routines are loops and do not use
it.

## The PicoBlaze's carry on COMPARE

In FW4 and FW5 an arithmetic instruction loads the carry flag with its
carry. FW6's carry chain reads that carry in its select
([picoblaze.v](../fw6/picoblaze.v)): when it is set the flag is set, and
when it is clear the flag takes the terms below it. For ADD, ADDCY, SUB
and SUBCY that is 0, the same result. For COMPARE it is the shift
carry, which is bit 7 of the first operand, or bit 0 when bit 3 of the
instruction word is set. So `COMPARE sX, kk` sets the carry when
sX < kk, and also when that bit of sX is 1.

The two programs test the carry after a COMPARE in three places, all
loops that count `s4` up to a constant with bit 3 set, so the extra term
is bit 0 of `s4`:

| Where | Loop | Effect |
|---|---|---|
| bank 1 `$0B3`, bank 2 `$1AE` | clear the scratchpad while `s4 < $3E` | none: `$3E` is even |
| bank 2 `$09E` | keep the license record's bytes while `s4 < $3F` | one more byte is kept, at scratchpad `$3F` |

Scratchpad `$3F` is where the license check keeps slot B's verdict. This
follows from the logic and is not tested; whether the byte is overwritten
before it is read was not traced.

## The other differences

None of these changes what the cart does:

| Where | What |
|---|---|
| Save page in game mode | page bits 4 and 5 take RAM bank register bits 6 and 5, where FW5 takes 5 and 6. The register's bits 7:4 are always written as one value ([psram_ctrl.v](../fw6/psram_ctrl.v)) |
| The loader's busy flag | one register and a copy half a clock later for the write clock's buffer, where FW5 keeps two copies |
| PicoBlaze `port_id` | bit 1 has a second register, which the input mux reads |
| PicoBlaze OUTPUT `A5-A9` | no registers behind them ([picoblaze_ports.v](../fw6/picoblaze_ports.v)) |
| PicoBlaze INPUT `A5-A9` | the value to load, with 0 in the bits FW6 does not keep |

## The build of 2026-11-24

`Update_FW6_20261124.gb` was the first release, withdrawn by EZ Flash on
2026-11-26 for "a small bug" they did not name. Read the same way (its
export is kept as `fpga/fw6-1124`), it differs from the build above in
this:

| | 2026-11-24 | 2026-11-27 |
|---|---|---|
| First PicoBlaze program, `$339` | `LOAD s0, 00`: `rtc_init` reset the clock chip only when its seconds read exactly `$80` | `AND sD, 80`, as FW5: whenever bit 7 is set |
| PicoBlaze and SD register clocks | gated as in FW5 (kernel mode, or `$7F37` bit 7) | never gated |
| The game clock in a game without `$7F37` bit 7 | stopped, with the PicoBlaze's clock | runs |
| A DL write | left the day's bit 8 alone | loads it from the last DH value |
| SD clock divider | 8 bits: `$3F`, 383.5 kHz | 5 bits: `$1F`, 767 kHz |
| SD command timeout | 16 bits | 8 bits |
| 4-bit data cycle count | FW5's | FW4's |
| PicoBlaze timer | FW5's | none |
| The loader's write clock | CLKFX | CLK2X |
| Stage1's block RAMs | `X3Y17 X3Y1 X3Y25 X3Y9 X3Y21 X3Y13 X3Y29 X3Y5 X19Y17` | three in other places, the same bytes |
| Updater program | FW5's with `ver:6` | 59 reads of `$A000` before `FlashPoll` starts polling |
| Flip-flops | 2,378 | 2,306 |

The second PicoBlaze program, the game clock's latch, the kernel's read
and write of the clock at `$A018-$A01C`, the version byte and the carry
on COMPARE are the same in both.

## The test build

`Update_FW6_11-17.gb` was a build EZ Flash sent a week before the
first release. It has that release's updater program and the same second
PicoBlaze program. Read from its bitstream the same way, it differs from
the release of 2026-11-24 in this:

| | Test build | Release of 2026-11-24 |
|---|---|---|
| Loading the game clock | only a game's write; the kernel's write at `$A018-$A01C` reached no counter | either write |
| The `$6000` latch | none: a game read the counters live | as above |
| The kernel reading the game clock | `$A018-$A01C` read 0 | they read the counters |
| First PicoBlaze program | `$120` only | `$035`, `$120`, `$339` |
| Stage1 | FW5's bit planes | bytes |
| PicoBlaze carry | TEST with even parity took the arithmetic carry (always 0 then) | COMPARE, as above |
| Clock load registers | all eight bits of each | the MBC3's bits |

> **Correction (2026-11-23).** This page, firmware-diff.md and the
> comments in both `mbc3_clock.v` files used to give the kernel's write
> addresses as `$A010-$A014`. The decode takes A4 and A3, so they are
> `$A018-$A01C`, as the kernel source has them. Nothing was built on the
> wrong addresses.

## How it was compared

FW6 packs its logic into other LUTs than FW5, so FW5's block files do not
carry to it block by block. It is proven with the whole design at once,
matched at the registers: [stage0/fw6/README.md](../fw6/README.md).
