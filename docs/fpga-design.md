# The FW4 FPGA design, reversed from the bitstream

A map of EZ Flash's logic in the XC3S200A, rebuilt from the FW4 slot B
bitstream with no design files: `s3trace --netlist` (every configured bel
and the driver of each input pin), `s3pins` (prjcombine's VQ100 bond: package
pin -> bel pad), and the scripts in `scripts/fpga/netlist/`. Work in progress;
each section says how sure it is.

Related: [fpga-version.md](fpga-version.md) (the version byte),
[fpga-picoblaze.md](fpga-picoblaze.md) (the two programs),
[fpga-bitstream.md](fpga-bitstream.md) (format, BRAMs), hardware notes in
[hardware-board.md](hardware-board.md).

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
| A13, A14, A15 | P5, P6, P7 | the version read needs them at `1 0 1` = `$A000-$BFFF` ([fpga-version.md](fpga-version.md)) |
| D0-D7 | P3 P9 P10 P12 P13 P15 P16 P19 | bidirectional; each reads back its own BRAM output bit |
| `/WR` (probable) | P84 | clock pad; through a global buffer it clocks the flip-flops that latch D0-D7 (the write registers) |
| `/RESET` | P62 | output; daid's survey traces it to the cart edge |

Still to place: `/RD`, `/CS` (SRAM select) and the console clock, among the
inputs P30, P61 and P28 (P28 is bidirectional with 147 sinks, the largest
fan-out of any pin).

### Everything else

The bottom and right edges carry the memory buses (the two NOR+pSRAM
packages share a 16-bit bus), the SD card, the SPI config flash and the RTC
(I2C). Not assigned yet; the PicoBlaze port map
([fpga-picoblaze.md](fpga-picoblaze.md)) and the SD controller's known
structure are the next anchors. Full list: `scripts/fpga/netlist/pintable.py`.

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
[fpga-version.md](fpga-version.md).

## Simulation

The whole design exports to structural Verilog and runs in iverilog
([scripts/fpga/verilog/](../scripts/fpga/verilog/README.md)). From power-on,
the PicoBlaze executes the FW4 program exactly as `X3Y29.psm` reads: the
bank-2 call at `$3F0`, two debug-UART prints through `dbg_putc` (`$155`),
then `clear_scratchpad` (`$042`). That checks the slice, LUT RAM, carry,
BRAM, clock and start-up models against the real design. One correction to
prjcombine's CLB document found this way: the F5 mux is `BX ? G : F`
(standard Xilinx `MUXF5`), not `BX ? F : G`.

## Plan

1. Finish the pin map (`/RD`, `/CS`, console clock; then the memory, SD,
   flash and RTC pins).
2. ~~Export the netlist as structural Verilog~~ (done, above). Next: an SD
   card model so the boot can get past `sdc_init`.
3. Simulate Game Boy bus cycles from the kernel's own register sequences
   and watch each block respond.
4. Name the blocks from their anchors: the `$7Fxx` register file and its
   unlock sequence, the PicoBlaze (KCPSM3) and its port decode, the SD
   controller, the MBC emulation, the ROM-load engine.
