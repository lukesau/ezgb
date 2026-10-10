# The FW4 FPGA design, reversed from the bitstream

A map of EZ Flash's logic in the XC3S200A, rebuilt from the FW4 slot B
bitstream with no design files: `s3trace --netlist` (every configured bel
and the driver of each input pin), `s3pins` (prjcombine's VQ100 bond: package
pin -> bel pad), and the scripts in `re/stage0/netlist/`. Work in progress;
each section says how sure it is.

Related: [version-byte.md](version-byte.md) (the version byte),
[picoblaze.md](picoblaze.md) (the two programs),
[bitstream.md](bitstream.md) (format, BRAMs), hardware notes in
[../../../docs/hardware-board.md](../../../docs/hardware-board.md).

## Size

2,133 configured bels: about 1,700 of the 1,792 slices, 15 of 16 block RAMs,
1 of 4 DCMs, 67 of the package's IO pins.

## Pins

Checks: `s3pins` puts TMS on P1 and TDI on P2, as daid/ezflashjr's board
survey found by continuity; P62 (the survey's cart `/RESET`, through R5) is
an output.

### Game Boy cartridge bus

| Signal | Pin | How identified |
|---|---|---|
| A0-A7 | P88 P89 P90 P93 P94 P97 P98 P99 | stage1 BRAM `ADDRA[0-7]` straight from these pins |
| A8-A10 | P82 P68 P39 | `ADDRA[8-10]` |
| A11, A12 | P21, P4 | `ADDRA[11]`/`[12]` through one AND gate each, sharing an enable (`X13Y24 SLICE[2]` Y) |
| A13, A14, A15 | P5, P6, P7 | the version read needs them at `1 0 1` = `$A000-$BFFF` ([version-byte.md](version-byte.md)) |
| D0-D7 | P3 P9 P10 P12 P13 P15 P16 P19 | bidirectional; each reads back its own BRAM output bit |
| `/WR` | P84 | clock pad; through a global buffer it clocks the flip-flops that latch D0-D7 (the write registers); a simulated `/WR` pulse writes the registers as the kernel does |
| `/RESET` | P62 | output; daid's survey traces it to the cart edge |

There is no `/RD` or `/CS`: the D0-D7 output enable is a function of A13-A15
and `/WR` alone (LUT `X9Y20 SLICE[0]`), so the FPGA drives the bus for any
address in its ranges while `/WR` is high. On a DMG `/RD` is low except
during writes, so this amounts to the same thing. P61 (input, next to
`/RESET`) is still unplaced.

### Everything else

The bottom and right edges carry the memory buses (the two NOR+pSRAM
packages share a 16-bit bus), the SD card, the SPI config flash and the RTC
(I2C). Assigned so far:

| Function | Pins |
|---|---|
| SPI config flash | CS P27, CLK P53, MOSI P46, MISO P51 |
| SD card | CLK P23, CMD P28, DAT0 P34, DAT1 P25, DAT2 P30, DAT3 P29 (order from simulated block reads) |
| RTC (I2C) | probably P31/P32 |
| pSRAM word address A0-A10 | P56 P59 P65 P71 P70 P73 P44 P50 P83 P86 P20 |
| pSRAM word address A11-A13 | P53, P46, P51 (the config flash's CLK, MOSI and MISO, reused once bank 2 has read the flash) |
| pSRAM upper address | 74HC595: SRCLK P35, SER P33, RCLK P24 |
| pSRAM data | eight bidirectional pins, P41 P48 P49 P57 P64 P72 P77 P78 (bit order is a naming choice: the FPGA reads back through the same pins) |
| pSRAM /LB, /UB, /WE | P37 (even bytes), P36 (odd bytes), P40 |
| pSRAM /CE | P52 (U9, game ROM), P60 (U4, saves) |
| P85 | follows the Game Boy's `/WR` |

Full list: `re/stage0/netlist/pintable.py`.

## Clocks

| Source | Buffer | Clocks | Use |
|---|---|---|---|
| P43 (oscillator) | DCM `X13Y1`: CLK0, CLK2X, CLKFX (x2) | via 4 global buffers | system clocks |
| `X13Y19 SLICE[2]` YQ (a divided clock) | global `X0Y17` [6] | 661 flip-flops | main logic clock; also driven out on P23 |
| system clock / `X13Y25 SLICE[2]` Y, selected by the mode bit | global `X13Y33` [3] | 391 flip-flops | switches with the stage1/kernel/game mode |
| P84 (`/WR`) | global `X13Y33` [0]/[1] | 160 flip-flops | the Game Boy-written registers |
| system / `X2Y17 SLICE[3]` Y | global `X0Y17` [0], [4] | 196 flip-flops | |
| `X24Y16`/`X24Y19` | global `X25Y17` [7] | out on P35 | a clock driven off-chip |

## Registers written by the Game Boy

Flip-flops that latch D0-D7, grouped by clock enable: about 20 byte-wide
registers plus a few narrow ones. Identified so far: the 2-bit mode
register (`$7F31/$7F32`) and the 4-bit page register (`$7FC0`), both in
[version-byte.md](version-byte.md).

## Simulation

The whole design exports to structural Verilog and runs in iverilog
([re/stage0/sim/](../sim/README.md)). From power-on,
the PicoBlaze executes the FW4 program exactly as `X3Y29.psm` and
`X3Y25.psm` read: the switch to bank 2 at `$3F1`, `bank2_main` (`$1B5`)
with its Device DNA and flash routines, back to bank 1. That checks the
slice, LUT RAM, carry, BRAM, clock and start-up models against the real
design. Verilator runs it about 100 times faster than iverilog.

With the SPI flash and SD card models in `models.v`, the simulated FPGA
reads the boot tally and license from flash, then initializes the card:
CMD0, CMD8, CMD55/ACMD41, CMD2, CMD3, CMD7, CMD16, ACMD6 (4-bit bus),
CMD13, then idles with interrupts on. The testbench drives the Game Boy bus
(`gb_write` / `gb_read` in `tb_full.v`), and `gb_sdread.vh` runs stage1's
`sd_read`: the `$7FB4` write sets a request flag (`X23Y29 SLICE[1]`), which
reaches the PicoBlaze's interrupt input through a synchronizer
(`X2Y29 SLICE[0]`); the interrupt handler issues CMD18, and the sector read
back through the `$A000` window matches the card image byte for byte. Of
the 24 possible DAT orders only one does (`datvariants.sh` runs them all).

> **Correction (2026-10-09).** This paragraph first said P30 is input-only,
> so SD writes could not use the 4-bit bus. Wrong: P30 drives through the
> IO tile's second output register (FFO2/FFT2 on OTCLK2), which the pin
> table script didn't look at. The IO tile model also ignored latch mode
> and SR/REV until commit "io tile registers"; the DAT order above held up
> when the sweep was rerun on the corrected model.

**ROM loads.** With `gb_load.vh`, the GB side runs stage1's kernel launch
(`$7FC0=2`, the load command through the `$7F36=1` window, `$7F36=3`) and
the PicoBlaze streams `ezgb.dat` into U9: every byte of the 160 KB file lands
where it should (`loadcmd.py` builds the command, `memmap.py` works out the
address map from a capture of the writes). Each byte is one `/WE` pulse with
`/LB` or `/UB` low. Two findings on the way:

- The FPGA reuses the config flash's CLK, MOSI and MISO pins as pSRAM
  address lines A11-A13. P51 (MISO, A13) is driven by an IO-tile output
  latch whose SR and REV inputs carry the bit and its inverse, so the pin
  follows the address asynchronously.
- `cmd_load_rom` runs only after bank 2's license check passes, which
  needs the Device DNA. The simulation doesn't model the DNA, so
  `fastboot.py --no-license` patches the gate out of a sim-only copy of
  the program.

**Not understood yet: game-mode addressing.** After the kernel handoff
(`$7FC0=0`, ROM bank 1, `$7F31=0`, `$7F32=$80`), GB reads return pSRAM data
with the low address bits following the bus, but A14 and the bank number
don't: P51 stays high and the FPGA reloads the 595 on every access, with
`$00` after a `$2000` write and `$EB` for any `$4000` access whatever bank
was written. Possibly no MBC type is set (stage1 doesn't write `$7F37` for
the kernel), and some 595 outputs may be selects rather than address bits.
/OE is not identified either; the model ties it active. The SD controller is Marek Czerski's OpenCores `sdc_controller`
(command word at `$04` with the index in bits 13:8, argument at `$00`
starting the command, command status at `$34`); its registers cross from
the PicoBlaze's clock (BUFGMUX3) to the SD clock (BUFGMUX6) through 43
two-flop synchronizers.

What the simulation showed:

- In a SLICEM, `DIF_MUX=BX` / `DIG_MUX=BY` on a LUT that isn't in RAM mode
  goes with the flip-flop taking BX / BY directly, whatever `DXMUX` /
  `DYMUX` decode as. In FW4 those are exactly the 51 flip-flops that would
  otherwise be fed by a constant LUT, the synchronizers among them. Before
  `netlist2v.py` applied this, every SD command went out with index 0.
- The firmware races its own status clear. `sd_command` clears `$34`
  after a command completes, but the clear takes three SD clocks to
  cross and the next command's first status poll comes after two, so
  CMD55 reads as complete before it is sent and the ACMD41 written after
  it is lost. The ACMD41 retry loop covers it at the cost of one ~20 ms
  delay per boot. The PicoBlaze and the SD divider share a clock, so this
  should happen on the cart too.
- The flip-flops' REV input matters: KCPSM3 forces its program counter to
  the interrupt vector `$3FF` through REV (BY) on its ten PC flip-flops.
  The slice model ignored REV at first, so interrupts were taken but
  jumped nowhere.
- CMD7 goes out with RCA `$0200` whatever the card's CMD3 reply says.
  Not looked into yet.

> **Correction (2026-10-09).** An earlier version of this section said
> prjcombine's CLB document has the F5 mux backwards (`BX ? G : F`). It
> doesn't: `F5 = BX ? F : G` as documented. With the reversed mux the
> simulated PicoBlaze looped in `clear_scratchpad` and its bank switch did
> nothing; with the documented one it runs bank 2 as written. The
> version-byte analysis in [version-byte.md](version-byte.md) had used the
> reversed mux too; see the correction there.

## Plan

1. Finish the pin map (`/RD`, `/CS`, console clock; then the memory, SD,
   flash and RTC pins).
2. ~~Export the netlist as structural Verilog~~ (done, above). SD card
   model done: the boot gets through card init, and Game Boy-side sector
   reads work. pSRAM model done: ROM loads land byte for byte. Next:
   game-mode addressing (the 595 protocol, MBC registers, /OE).
3. Simulate Game Boy bus cycles from the kernel's own register sequences
   and watch each block respond.
4. Name the blocks from their anchors: the `$7Fxx` register file and its
   unlock sequence, the PicoBlaze (KCPSM3) and its port decode, the SD
   controller, the MBC emulation, the ROM-load engine.
