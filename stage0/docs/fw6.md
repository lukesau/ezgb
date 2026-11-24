# FW5-0918 against FW6

FW6 is the firmware EZ Flash released on 2026-11-24 with kernel 1.06e
(`Update_FW6_20261124.gb`). Its updater writes slot B only, like FW4's and
FW5's, and the updater's program is FW5's with another label. The whole of
its slice logic is proven against readable Verilog
([stage0/fw6/](../fw6/README.md)), so everything below is read from the
design, not from testing: FW6 has not been run on a cart here.

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
| SD identification clock | divider `$48`, 336 kHz | divider `$3F`, 383.5 kHz |
| A game's clock (MBC3) | the PicoBlaze computes it from the clock chip | counters in the FPGA |
| Loading that clock | the kernel writes `$A018-$A01C`, the PicoBlaze takes it from there | the same write loads the counters directly, as a game's write does |
| The `$6000` latch | copies the clock for the game to read | the same; until a game's first latch it reads the clock live |
| The kernel reading that clock | not possible | `$A018-$A01C` read it, live |
| Stage1 | bit planes in eight block RAMs and a ninth of bytes | the same bytes, in nine block RAMs of 2 KB; past `$47FF` it reads `$FF` |
| SD controller, loader, flash, license check | | the same logic; the first program differs in three words |
| Timeouts and CRC handling of the SD controller | timeouts 0, a data CRC error never completes | the same: [sd-recovery.md](sd-recovery.md) applies to FW6 as it does to FW5 |

Everything else is FW5-0918 placed and routed again: the Game Boy
registers and bus, the unlock sequence, the fast-load key, the RTC bridge
the kernel reads, the memory controller, the reset logic.

## The PicoBlaze's programs

The first program differs in three words:

| Word | FW5-0918 | FW6 | |
|---|---|---|---|
| `$035` | `JUMP game_clock` | `JUMP idle` | the PicoBlaze no longer computes a game's clock; the routine is still there, never run |
| `$120` | `LOAD s0, 48` | `LOAD s0, 3F` | the SD clock divider `sdc_init` sets for card identification: CLK2X / (2 x (divider + 1)), 336 kHz to 383.5 kHz, both under the 400 kHz the SD specification allows |
| `$339` | `AND sD, 80` | `LOAD s0, 00` | `rtc_init` reset the clock chip when the seconds register's bit 7 (power was lost) was set; FW6 does it only when the register reads exactly `$80` |

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

**Loading it.** A write to a clock register flips a toggle on `/WR`
([mbc3_clock.v](../fw6/mbc3_clock.v)). The toggle crosses to the
PicoBlaze clock through two flip-flops, and the change loads that
counter from the written value. A seconds write also clears the
one-second counter. Two writes flip the toggles: a game's, to clock
registers `$08-$0C` through `$A000-$BFFF`, and the kernel's, to
`$A018-$A01C` of its register window. So the kernel sets a game's clock
the way the 1.05e kernel always did, with no PicoBlaze in between. Only
the bits the MBC3 has are kept: six of seconds and minutes, five of
hours, and bits 0, 6 and 7 of DH.

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
address order (`X3Y17 X3Y1 X3Y25 X3Y9 X3Y21 X3Y13 X3Y29 X3Y5 X19Y17`),
all enabled together, and registers the byte that A14-A11 pick
([gb_bus.v](../fw6/gb_bus.v)). The contents are FW5-0918's stage1 with
`$FF` after its last byte, and a read past `$47FF` gives `$FF` where
FW5 gives `$00`.

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
| The loader's busy flag | one register, where FW5 keeps two copies |
| PicoBlaze OUTPUT `A5-A9` | no registers behind them ([picoblaze_ports.v](../fw6/picoblaze_ports.v)) |
| PicoBlaze INPUT `A5-A9` | the value to load, with 0 in the bits FW6 does not keep |

## The test build

`Update_FW6_11-17.gb` was a build EZ Flash sent a week before the
release. It has the same updater program and the same second PicoBlaze
program. Read from its bitstream the same way, it differs from the
release in this:

| | Test build | Release |
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
