# FW4, FW5-0731 and FW5-0918 side by side

The three updaters in the `juniorkernel-*` folders each carry an FPGA
bitstream: `Update_FW4.gb`, `Update_FW5_7-31.gb` and
`Update_FW5_2021-9-18.gb` (for FW5, the image at `$8000`; see
[fw5.md](fw5.md) for the second image and the BRAM and PicoBlaze
comparisons). Each one is exported to Verilog the same way
([../sim/README.md](../sim/README.md)) and put through the same tools, so
the three map together and their differences fall out. Placement differs
from build to build, so the comparisons are by function (pins, addresses,
data bits), not by slice name. The per-firmware outputs are in
[../maps/](../maps/).

## Pins

`pinconf.py` lists each package pin's output source, tristate source, input
use and register clocking (`maps/<fw>.pins.txt`). All three use the same 68
pins in the same modes, so the board wiring and the FPGA's view of it didn't
change between FW4 and FW5. The differences:

- **Global buffer numbering.** FW5 routes the same clocks through different
  buffers. The SD pins' registers are clocked from `X13Y33[1]` in FW5 and
  from `X0Y17[6]` in FW4; the Game Boy data pins' input registers from
  `X13Y33[0]` (FW5) and `X13Y33[1]` (FW4); the 595's shift clock comes
  straight from `X0Y17[0]` in FW5.
- **P51's tristate is registered in FW5** (`FFT2` on a system clock), not
  driven from logic. P51 is the config flash's MISO before it becomes
  pSRAM address bit 13, so this is the hand-over between the two uses.
- FW5-0731 and FW5-0918 have identical pin configurations.

## Registers written by the Game Boy

`regmap.py` finds the `/WR` clocks itself (FW4 has two global buffers on
`/WR`, one of them ORed with A15; FW5 has one) and lists every flip-flop
they clock with its enabling address; `regsum.py` groups them by address
(`maps/<fw>.regs.txt`).

| Address | FW4 | FW5 (both) |
|---|---|---|
| `$7Fxx` decode | low byte only; A15 handled by the `/WR` OR A15 clock | low byte plus A15=0 in the enable |
| `$7F30/32/36/37`, `$7FB0-B3`, `$7FC0-C2`, `$7FC4`, `$7FD2` | as in [design.md](design.md) | same bits |
| `$7FC3` (header checksum) | D0-D6 | D0-D7 |
| `$7FD3` | none | D0-D6 |
| `$7FD4` | none | 8 flip-flops through logic (a counter or shift register) |
| `$6000-$7FFF` | none | an 8-bit register (MBC3 clock latch or RTC access) |
| `$0000-$1FFF` | none | 4 bits through logic (RAM enable path) |

The kernel writes `$7FD4` in 1.05e (cataloged in `docs/REGISTERS.md`
beside `$7FD0`/`$7FD2`); FW4's design doesn't decode it.

Between FW5-0731 and FW5-0918 the register map is the same except for five
extra flip-flops loaded on every write and a regrouped set of data-path
flip-flops whose enables are too wide for `regmap.py` to resolve. That fits
the MBC3 real-time clock work [fw5.md](fw5.md) found in 0918's PicoBlaze
code; the cone diff is where it gets pinned down.

## Kernel and game launches (simulated)

Both launch paths run unchanged on all three firmwares, loading from the
simulated SD card through the PicoBlaze loader:

- **Stage1's kernel launch and hand-off** (`gb_kernel.vh`): `ezgb.dat`
  loads (status `$01` for 1170-1171 polls), and kernel-mode reads after
  the hand-off match the file at `$0000`, `$0100` and banks 1, 2 and 5.
- **The kernel's game launch** (`gb_game.vh`, the first 64 KB of Pokemon
  Red as MBC3): the load takes 468 polls on each, and all 48 reads after
  the `$7FE0` console reset (header, banks 0-3, bank 0 selecting 1) match
  the ROM.

So everything that differs between the three sits in the clock handling,
the `$7FD3/$7FD4` pair and the bootstrap header, not in loading or banking.

## FW5's new registers

- **`$6000-$7FFF`** holds the written byte; writing `$01` after `$00`
  copies the live clock value into the latched copy the game reads (the
  MBC3 latch). FW4 has no such register and serves the live clock.
- **`$7FD4`**: a write goes through an 8-bit adder with **`$7FD3`** (carry
  chain, XOR sum outputs) into a register. Kernel 1.05e writes `$7FD4=$00`
  on every game launch, right after `$7F37` (the far call to
  `SetFpga7FD4_B1` at `00:15E6`), and never writes `$7FD3`. Writing
  `$7FD4=$05` (and `$7FD3=$03`) before a launch changes nothing in ROM
  banking or save RAM on any of the three, so the sum isn't a ROM or RAM
  base offset.

## Banking and save RAM (simulated)

`gb_mbc.vh` with `mbctest.py` runs the kernel's launch writes against
tagged pSRAM images, sweeps each cart type's bank registers and exercises
save RAM, and checks every read against a Pan Docs model of the MBC
(about 50-105 ROM reads and up to 16 RAM banks per type). All three
firmwares give **identical results**:

| Type (`$7F37`) | ROM banking | Save RAM |
|---|---|---|
| 0 none | 32 KB fixed, exact | disabled, reads `$FF` |
| 1 MBC1 | exact in mode 0; mode 1 keeps `$0000-$3FFF` on bank 0, and `$4000` writes in mode 1 don't change the ROM upper bits | banks 0-3 |
| 2 MBC2 | the bank register takes 5 bits (`$2100=$13` selects bank `$13`, not 3) | one bank, full bytes (not 4-bit) |
| 3 MBC3 | exact (7-bit bank, 0 selects 1) | banks 0-3 |
| 4 MBC5 | exact (9-bit bank, 0 selects 0) | banks 0-15 |
| 5 MBC1 multicart | exact (4-bit low register) | bank 0 only |

Save RAM bank N sits at U4 offset N×`$4000`: the RAM bank goes out on the
same address lines as the ROM bank, so each 8 KB bank uses a 16 KB slot of
the 512 KB chip. Reads with RAM disabled return `$FF`, and writes land only
in the selected bank. The ROM bank mask (`$7FC1/$7FC2`) wasn't exercised
beyond these values; MBC2's `$13` suggests the mask isn't applied there.

The ROM bank mask is applied: MBC5 with `$7FC1/$7FC2 = $00F` reads banks
`$55`, `$AA`, `$FF`, `$1xx` as their low four bits on all three firmwares.

## SD sector reads (simulated)

`gb_sdread.vh` (stage1's `sd_read` from the Game Boy side, sector 2052) reads
back byte for byte on all three. FW5 answers a little sooner: the status
reads ready after 8 polls against FW4's 12.

## The MBC3 clock (simulated)

`models.v` now has a PCF8563 on I2C (time registers in BCD, a tick shortened
to 3 ms) and `mbctest.py mbc3rtc` launches with `$7F37 = $83` (MBC3, clock
flag), then latches (`$6000` 0 then 1) and reads registers `$08-$0C` through
`$A000` several times, 7 ms apart, writes S=`$15` and M=`$42`, and reads
again. Only SCL=P31, SDA=P32 works (the other order reads `$A5` on FW4 and a
frozen clock on FW5), which settles the I2C pins.

| | FW4 | FW5-0731 | FW5-0918 |
|---|---|---|---|
| what the game sees | the cart's wall clock, converted to binary (here 12:30, day 9) | elapsed time since the launch, starting at 0 | same as 0731 |
| ticking | yes | yes | yes |
| game writes S=`$15`, M=`$42` | ignored | taken through plain wrap arithmetic (M `$42` becomes H+1, M 6; S lands at `$20`) | taken as written: S=`$15`, M=`$02` (masked to 6 bits), ticking resumes from there |
| DH while running | `$01` | `$00` | `$00` |
| RAM disabled | `$FF` | `$FF` | `$FF` |

The 0918 row matches the routine-level diff in [fw5.md](fw5.md) (writes
honored, values masked). FW4 has no `$6000` latch register, which fits it
serving the live clock with no latch semantics.
