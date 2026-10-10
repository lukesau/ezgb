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
during writes, so this amounts to the same thing.

P61 reads the console's `/RESET` at the cart edge, and P62 is the FPGA's
drive of it (P62's LUT takes P61 as an input). The FPGA registers P61 into
the `X13Y0` BUFGMUX2 clock domain twice; a falling edge between the two
copies asynchronously resets the `$7F00/$7F10/$7F20` unlock state machine
(`X18Y31 SLICE[0]/[3]`, reset by `X12Y21 SLICE[0]`) and other registers.
It cannot be the bus clock, `/RD` or `/CS`: all three fall during normal
bus activity, often between the steps of an unlock (stage1's hand-off stub
unlocks from WRAM), which would make unlocking impossible.

### Everything else

The bottom and right edges carry the memory buses (the two NOR+pSRAM
packages share a 16-bit bus), the SD card, the SPI config flash and the RTC
(I2C). Assigned so far:

| Function | Pins |
|---|---|
| SPI config flash | CS P27, CLK P53, MOSI P46, MISO P51 |
| SD card | CLK P23, CMD P28, DAT0 P34, DAT1 P25, DAT2 P30, DAT3 P29 (order from simulated block reads) |
| RTC (I2C, PCF8563) | SCL P31, SDA P32 (only order that works in simulation, all three firmwares) |
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
registers plus a few narrow ones. `regmap.py` lists each with the address
that enables it and the data bit it takes. All `$7Fxx` registers decode only
the low address byte, after the `$7F00/$7F10/$7F20` unlock
(`X18Y31 SLICE[0]/[3]`):

| Address | Bits | Use |
|---|---|---|
| `$7F30` | 0-1 | written `$01`/`$03` by the kernel before sector reads and writes (`SetFpga7F30_B2`) |
| `$7F32` | 3, 7 | bit 7: kernel (1) / game (0) mode, see Game launch below; bit 3 not identified |
| `$7F36` | 0-1 | load window (1) / start load (3) |
| `$7F37` | 0-3, 7 | MBC type (0 none, 1 MBC1, 2 MBC2, 3 MBC3, 4 MBC5, 5 MBC1 multicart); bit 7 RTC |
| `$7FB0-$7FB3` | 8 each | LBA for sector reads |
| `$7FB4` | none | sector command; the write itself raises the PicoBlaze interrupt |
| `$7FC0` | 0-3 | page for the `$A000` window |
| `$7FC1`, `$7FC2` | 8, 1 | ROM bank mask (9 bits) |
| `$7FC3` | 8 | header checksum |
| `$7FC4` | 0-3 | RAM bank mask |
| `$7FD2` | 0 | config-flash operation; also freezes P51 (see Game launch) |
| `$2000` | 8 | ROM bank (plain latch in kernel mode, MBC logic in game mode) |
| `$4000` | 8 | kernel mode only: save pSRAM page for the `$7FC0=3` window (per the kernel's `SetFpgaPage` notes) |

The mode register halves and the page register also appear in
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

**Kernel launch.** `gb_kernel.vh` runs stage1's launch and hand-off as
`stage1/src/handoff.s` does, with bus cycles timed as GB-CTR's Appendix C
draws them (address just after the cycle starts, `/WR` low in the second
half, reads sampled in the second half) and P61 low for the first
millisecond like a console's power-on reset. The load runs to the end
(status `$01` for about 25 ms, then done) and the PicoBlaze writes the
whole kernel into U9. One detail for anyone polling the status: right after
the `$7F36=3` command the `$A000` window floats (`$FF`) for about a cycle
and a half while the FPGA switches it over; stage1 is past that by the
time its first poll runs.

**Game launch.** `gb_game.vh` runs the kernel's own launch (1.04e bank 4)
with the first 64 KB of Pokemon Red: `$7FC0=2`, the MBC type to `$7F37`,
the RAM bank mask to `$7FC4`, the ROM bank mask to `$7FC1/$7FC2`, the header
checksum to `$7FC3`, the load, `$7F36=0`, `$7F31/$7F32=0`, `$2000=1`,
`$3000=0`, then `$7FE0=$80`, which holds P62 low for 65536 fast clocks to
reset the console. After the reset, the header and banks 0-3 read back byte
for byte, including MBC3's bank 0 selecting bank 1 (48 reads, none wrong).
What it takes:

- **`$7F32` bit 7 (`X14Y20 SLICE[0]`) is the kernel/game switch.** It powers
  up 1 and stage1's hand-off writes `$80`, so the kernel runs with it set;
  the kernel's game launch clears it. While it is 1, the ROM bank register
  (`X18Y24 SLICE[0]` bit 0 ... `X15Y26 SLICE[0]` bit 7) is a plain latch at
  `$2000-$2FFF`, `$4000-$5FFF` writes a second 8-bit register, and the
  SD/PicoBlaze logic runs from the DCM. At 0, the global buffers `X13Y33[3]`,
  `X0Y17[4]` and (unless `$7F37` bit 7, the RTC flag, is set) `X0Y17[0]`
  switch to a constant, stopping that logic, and the bank register loads on
  every `/WR` through MBC logic selected by `$7F37` bits 0-3 and masked by
  `$7FC1/$7FC2`.
- **The pSRAM page is the bank register.** Bit 0 goes out on P51 (word
  address A13) and bits 7-1 through the 74HC595, which the FPGA reloads
  whenever a read moves into or out of `$4000-$7FFF` (0 below `$4000`). The
  load had put bank N at N×`$4000`, so no translation is needed.
- **P51's latch is transparent while `$7FD2` bit 0 is 0.** P51 is driven by
  an IO-tile output latch (`FFO1`) gated by `X12Y23 SLICE[1]`, which a write
  to `$xxD2` (unlocked, D0) sets. Its data comes from `X17Y4 SLICE[0]`:
  the load offset bit while loading, game-side bank logic otherwise. The
  decoded clock polarity makes the latch transparent while the bit is 1,
  and then P51 holds the 1 the load leaves behind and every bank-0 read
  lands 16 KB off. The kernel never sets `$7FD2` outside its config-flash
  routine, so the latch has to be open at 0 and closed during flash
  operations. `netlist2v.py` inverts output-latch gates for this reason;
  P51 is the only output latch in FW4, and the edge-triggered output
  registers keep the decoded polarity. A hardware check is still owed.
- **Bus contention at the `/WR` edge.** The FPGA drives D0-D7 whenever
  `/WR` is high (except at `$C000-$DFFF`), so it starts driving in the same
  instant `/WR` rises and clocks the bank register. With zero-delay pads
  the register caught the console's byte ORed with the FPGA's read data
  (written banks came back as bank|`$13`). The IO model now turns the
  output buffer on 3 ns after T falls, as real buffers do.

> **Correction (2026-10-09).** This section first listed game-mode reads as
> not understood, blaming a P51 gate "some write opens" and a bank register
> that corrupts its upper bits. Both runs were still in kernel mode
> (stage1's hand-off leaves `$7F32` bit 7 set), the corrupt bits were the
> pad contention above, and the gate is `$7FD2`, which the kernel doesn't
> touch on a game launch. The earlier note that P51's SR/REV make it follow
> the address asynchronously holds only while loading.

/OE is not identified; the model ties it active. The SD controller is Marek Czerski's OpenCores `sdc_controller`
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
   reads work. pSRAM model done: ROM loads land byte for byte, and the
   kernel launch runs as on hardware. Game launch done: ROM reads land in
   game mode with MBC3 banking. All MBC types, save RAM, the MBC3 clock and
   both launches now run on FW4, FW5-0731 and FW5-0918 alike
   ([firmware-diff.md](firmware-diff.md)). Next: what FW5's `$7FD3/$7FD4`
   drive, /OE.
3. Simulate Game Boy bus cycles from the kernel's own register sequences
   and watch each block respond.
4. Name the blocks from their anchors: the `$7Fxx` register file and its
   unlock sequence, the PicoBlaze (KCPSM3) and its port decode, the SD
   controller, the MBC emulation, the ROM-load engine.
