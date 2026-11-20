# FW5-0918 against FW6

FW6 is a test build EZ Flash sent in November 2026
(`Update_FW6_11-17.gb`). Its updater writes slot B only, like FW4's and
FW5's. The whole of its slice logic is proven against readable Verilog
([stage0/fw6/](../fw6/README.md)), so everything below is read from the
design, not from testing: FW6 has not been run on a cart here.

## In short

| | FW5-0918 | FW6 |
|---|---|---|
| The version byte (`$7FC0 = 4`) | `$05` | `$06` |
| SD identification clock | divider `$48`, 336 kHz | divider `$3F`, 383.5 kHz |
| A game's clock (MBC3) | the PicoBlaze computes it from the clock chip; the game reads latched copies | counters in the FPGA; the game reads them live |
| The `$6000` latch | copies the clock for the game to read | none |
| A game's clock writes | reach the clock when the PicoBlaze next looks | load the counter a few PicoBlaze clock cycles later; a seconds write restarts the second |
| Stage1 | | the same bytes |
| SD controller, loader, flash, license check | | the same logic and the same program |
| Timeouts and CRC handling of the SD controller | timeouts 0, a data CRC error never completes | the same: [sd-recovery.md](sd-recovery.md) applies to FW6 as it does to FW5 |

Everything else is FW5-0918 placed and routed again: the Game Boy
registers and bus, the unlock sequence, the fast-load key, the RTC bridge
the kernel reads, the memory controller, the reset logic.

## The PicoBlaze's programs

The first program differs in one word: `$120` loads `$3F` where FW4 and
FW5 load `$48`, the SD clock divider `sdc_init` sets for card
identification. The SD clock is CLK2X / (2 x (divider + 1)), so the
identification clock goes from 336 kHz to 383.5 kHz. Both are under the
400 kHz the SD specification allows.

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

A game's write to a clock register flips a toggle on `/WR`
([mbc3_clock.v](../fw6/mbc3_clock.v)). The toggle crosses to the
PicoBlaze clock through two flip-flops, and the change loads that
counter from the written value. A seconds write also clears the
one-second counter.

A game reads the counters as they are. FW6 has no `$6000` latch, so a
read that falls on a tick can pair an old byte with a new one.

Two things follow from the logic that are worth testing on a cart:

1. **Nothing but a game's write loads the counters.** The kernel's
   writes at `$A010-$A014` still reach the registers the PicoBlaze reads,
   but they flip no toggle, and the PicoBlaze's OUTPUT to ports `A5-A9`,
   which FW5's game read, goes nowhere in FW6. So the clock a game reads
   starts at zero when the FPGA is configured and never takes the time
   from the clock chip. A game that keeps its clock across power-off
   would lose it.
2. **The PicoBlaze still runs FW5's clock code.** Its program is
   unchanged, and the five bits that told it of a game's write are now
   the toggles: each holds its level until the next write to that
   register, where FW5's flag was cleared by the latch write.

## The other differences

None of these changes what the cart does:

| Where | What |
|---|---|
| PicoBlaze carry flag | on TEST, FW6 sets the carry on odd parity and otherwise takes the arithmetic carry, which is always 0 then. FW4 and FW5 load the parity. One LUT differs, `FF7F` for `FF3F` ([picoblaze.v](../fw6/picoblaze.v)) |
| Save page in game mode | page bits 4 and 5 take RAM bank register bits 6 and 5, where FW5 takes 5 and 6. The register's bits 7:4 are always written as one value ([psram_ctrl.v](../fw6/psram_ctrl.v)) |
| The loader's busy flag | one register, where FW5 keeps two copies |
| PicoBlaze OUTPUT `A5-A9` | no registers behind them ([picoblaze_ports.v](../fw6/picoblaze_ports.v)) |

## How it was compared

FW6 packs its logic into other LUTs than FW5, so FW5's block files could
be carried to it for 14 of the 27 blocks only (the SD controller's nine
among them). The rest is proven with the whole design at once, matched at
the registers: [stage0/fw6/README.md](../fw6/README.md).
