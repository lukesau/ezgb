# FW4, FW5-0731 and FW5-0918 side by side

The three updaters in `tools/ezflashjr/official/` each carry an FPGA
bitstream: `Update_FW4.gb`, `Update_FW5_7-31.gb` and
`Update_FW5_2021-9-18.gb` (for FW5, the image at `$8000`; see
[fw5.md](fw5.md) for the second image and the BRAM and PicoBlaze
comparisons). Each one is exported to Verilog the same way
([../sim/README.md](../re/sim/README.md)) and put through the same tools, so
the three map together and their differences fall out. Placement differs
from build to build, so the comparisons are by function (pins, addresses,
data bits), not by slice name. The per-firmware outputs are in
[../maps/](../re/maps/).

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
flip-flops only 0918 has, plus a regrouped set of data-path flip-flops whose
enables are too wide for `regmap.py` to resolve. The five are enabled only
for MBC3 and set on a write to `$A000-$BFFF` (A13-A15) while a given clock
register is selected through the RAM bank register, then hold: one flag per
clock register, the "game wrote S/M/H/DL/DH" events that 0918's interrupt
handler takes from `CMD_OP` `$04/$02/$01` and port `$B8`. 0731's fabric
never captures clock writes at all, which is why its PicoBlaze can't honor
them (the clock comparison below).

A second probe (`mbctest.py rtcx`) sets the halt bit, then writes a full
time of day 511, 23:59:58 and lets it run past midnight:

| | FW4 | FW5-0731 | FW5-0918 |
|---|---|---|---|
| DH = `$40` (halt), 7 ms later | still ticking (wall clock) | still ticking (S `$01` to `$04`) | stopped (S stays `$02`) |
| after writing S `$3A`, M `$3B`, H `$17`, DL `$FF`, DH `$01` | wall clock unchanged | S keeps the elapsed count, M/H/DL read 0, DH `$40` | reads back exactly what was written |
| 10 ms later | wall clock | DH `$81` with no day overflow | S `$02`, M/H/DL 0, DH `$80`: day 511 rolled to 0, carry set, day bit 8 cleared |

So the simulation confirms each 0918 change [fw5.md](fw5.md) read out of the
PicoBlaze code: halt honored, writes taken, day carry as on a real MBC3.
0731's clock only counts up from the launch.

## Save pages from the kernel

In kernel mode the save pSRAM is reached with `$7FC0 = 3`, a page number
written to `$4000` and the `$A000-$BFFF` window. Sweeping `$4000` over
0-63 and `$40`, `$80`, `$FF` (`mbctest.py kwin`) gives the same result on
all three firmwares:

- **The page latch is 5 bits.** `$4000 = $20-$3F` puts exactly the same
  address on the memory pins as `$00-$1F`; `$40` and `$80` land on `$00`,
  `$FF` on `$1F`. No pin carries bit 5, and U4's chip enable is the one
  asserted in every case.
- **Only the low byte lane is used**, in kernel mode and for the game's save
  RAM alike: `$A000+k` lands on U4 byte `page × $4000 + 2k` (with `/LB`
  only). A page is 8 KB to the Game Boy and spans a 16 KB slot of U4, so
  the 32 pages use the whole 512 KB part at one byte per word.
- Game save RAM bank N and kernel page N are the same memory.

The kernel's page map (`docs/psram-page-map.md`) assumes 64 pages, as
the emulator does; see the correction there for what a 5-bit latch means
for the browser's record pages.

## Stage1's header (simulated)

Reading `$0100-$014F` off the bus at power-on, before any FPGA write
(`mbctest.py stage1hdr`), gives stage1's header from BRAM on each build.
All three: title `BOOTLOADER`, cart type `$01`, the Nintendo logo intact.
FW5-0918 alone has the SGB flag `$146 = $03`, old licensee `$14B = $33` and
header checksum `$14D = $C4` (FW4 and 0731: `$00`, `$00`, `$FA`), as
[fw5.md](fw5.md) found in the BRAM dumps. FW4 and 0731 differ only in the
global checksum (`$B32E` against `$8EE3`), so stage1's code changed between
FW4 and FW5 while its header didn't.

## PicoBlaze bank 1, FW4 to FW5

`picoblaze-diff.py` FW4 (X3Y29) against FW5-0731 (X19Y25): 72 of 78 routines
identical (bank 2 is identical in every build, [fw5.md](fw5.md)). The FW4
annotations carry over to both FW5 listings through
`stage0/tools/picoblaze-port-notes.py`. What changed:

| FW4 routine | FW5-0731 |
|---|---|
| main loop (`$000`) | adds the game clock: when port `$B9` reads 1, count PCF8563 seconds into elapsed S/M/H/day (scratchpad `$33-$36`) and output base + elapsed on ports `$A5-$A9`, with wrap arithmetic and `OR $80` on day overflow |
| `sd_setup_dma` | the debug `99` + four argument bytes are gone |
| `cmd_load_rom` | reads port `$BB` (the `$7FD3+$7FD4` key) into scratchpad `$2B` |
| `load_rom_loop` | skips `delay_long` after each run when that key is `$11` |
| `rtc_init` | no longer writes PCF8563 control 1 = STOP and the CLKOUT register at boot |
| `isr` | debug `DD` + command byte on every interrupt; command `$20` (load ROM) also zeroes the elapsed clock; `$10` (set RTC) prints `AA` |

0731 to 0918 then changes only the main loop and the interrupt handler (the
clock writes, halt and day carry above; table in [fw5.md](fw5.md)).

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

  **The sum is a fast-load key.** It reaches the PicoBlaze as input port
  `$BB` (through the input mux). FW5's `cmd_load_rom` reads `$BB` once when
  a load starts (`$223` in 0918, `$209` in 0731) and, if it is `$11`,
  skips `delay_long` after every SD run (`$23C` / `$222`); FW4's loader
  always waits. Both `$7FD3` and the sum power up 0, but stock FW5-0918
  stage1 writes the console's boot `A` to `$7FD3` before handing over
  (`stage1/re/fw5-0918/disassembly/bank_000.asm`, `$07F1`), and the kernel
  then writes `$7FD4=$00`: the sum is `$11` on CGB and GBA, so stock loads
  are fast there and slow on DMG, MGB and SGB.
  In simulation,
  `$7FD4=$11` before the game launch's load makes FW5 issue each next
  `CMD18` 15 µs after `CMD12` instead of about 1.1 ms: the 64 KB load
  finishes in 5.5 ms instead of 10.1 ms (261 status polls against 468), and
  all 48 reads after the launch are still right. FW4 ignores it. The
  simulation runs `delay_long` at 1/20 of its real length (`fastboot.py`),
  so on a cart each skipped delay should be about 20 ms per SD run, roughly
  0.7 s per MB of ROM with 32 KB runs. Whether every card copes without the
  pause after `CMD12` is untested; the first attempt here stalled until the
  SD model was fixed to stop a block mid-way on `CMD12` and to retire a
  read superseded by a newer `CMD18`, which real cards do.

  > **Correction (2026-10-12).** This said stock loads are always slow
  > because nothing writes `$7FD3`, missing stock stage1's `$7FD3` write
  > (FW5-0918; 0731's stage1 isn't disassembled). Mod 5.5 inherited it:
  > writing `$7FD4=$11` gave `$22` on CGB, turning off the stock fast load
  > there, and `$12` on DMG, so with stock stage1 it sped nothing up.
  > The mod's `SetFpga7FD4_B1` now writes `$7FD3=$00` before `$7FD4`. Our
  > stage1 never wrote `$7FD3`, so a stock kernel lost the CGB fast load on
  > our firmware; it now passes the boot `A` like stock before entering the
  > kernel, and writes `$7FD3=$00` before its own fast launch. Flagged by
  > [fishcu](https://github.com/fishcu)'s EZ-Flash Junior research notes
  > (shared privately).

## Banking and save RAM (simulated)

`gb_mbc.vh` with `mbctest.py` runs the kernel's launch writes against
tagged pSRAM images, sweeps each cart type's bank registers and exercises
save RAM, and checks every read against a Pan Docs model of the MBC
(about 50-105 ROM reads and up to 16 RAM banks per type). All three
firmwares give **identical results**:

| Type (`$7F37`) | ROM banking | Save RAM |
|---|---|---|
| 0 none | 32 KB fixed | disabled, reads `$FF` |
| 1 MBC1 | 5-bit low register (0 selects 1); the ROM upper bits and the RAM bank are **separate registers**: a `$4000` write in mode 0 sets the upper bits, in mode 1 the RAM bank, and switching modes doesn't move one into the other. `$0000-$3FFF` is always bank 0 | banks 0-3, used only in mode 1 (bank 0 in mode 0) |
| 2 MBC2 | **5-bit** bank register at `$2000-$3FFF` with A8=1, not limited by the ROM mask (`$1F` selects `$1F` with mask `$0F`); 0 selects 1 | enabled only from `$0000-$1FFF` (`$2000=$0A` doesn't); full bytes, not 4-bit |
| 3 MBC3 | 7-bit, 0 selects 1 | banks 0-3; `$08-$0C` select the clock |
| 4 MBC5 | 9-bit (`$3000` D0 is bit 8, other bits ignored), 0 selects 0 | banks 0-15, masked by `$7FC4` |
| 5 MBC1 multicart | 4-bit low register, upper bits shifted by 4, mode 1 banks `$0000-$3FFF` with the upper bits | bank 0 only |

`mbctest.py`'s model encodes exactly this, and every simulated read (about
1000 across 10 test types × 3 firmwares, plus the edge-case probes
`mbc1x`, `mbc2x`, `mbc5x`) matches it.

Save RAM bank N sits at U4 offset N×`$4000`: the RAM bank goes out on the
same address lines as the ROM bank, so each 8 KB bank uses a 16 KB slot of
the 512 KB chip. Reads with RAM disabled return `$FF`, and writes land only
in the selected bank. The ROM bank mask (`$7FC1/$7FC2`) applies to every type except MBC2.
RAM enable looks only at the low nibble anywhere in `$0000-$1FFF` (`$1A`,
`$FA`, and `$0A` at `$1FFF` all enable; `$0B` and `$00` disable), and writes
while RAM is disabled never reach U4 (`mbctest.py ramx`, all three).

The ROM bank mask is applied: MBC5 with `$7FC1/$7FC2 = $00F` reads banks
`$55`, `$AA`, `$FF`, `$1xx` as their low four bits on all three firmwares.

## SD sector reads and writes (simulated)

`gb_sdread.vh` (stage1's `sd_read` from the Game Boy side, sector 2052) reads
back byte for byte on all three. FW5 answers a little sooner: the status
reads ready after 8 polls against FW4's 12.

`gb_sdwrite.vh` follows the kernel's `DiskWrite_B2` for one sector
(`$7F30=1` then 3, 512 bytes into the `$A000` window, LBA and `$7FB4=$81`
in an unlock envelope, poll `$A000`). On all three the card gets `CMD25`
for the right block with exactly the bytes written (pattern `i*7+3`: first
`03 0a 11 18`, last `fc`, sum `$FF00`), then `CMD12`; FW5 issues the
command about 1 µs sooner. This is the path the kernel's save backup uses.

## Console /RESET, FW4 to FW5-0918 (simulated)

P61 reads the console's /RESET at the cart edge. FW4 registers it on every
CLK2X edge, and a falling edge (two samples) resets about 46 Game
Boy-side flip-flops: the unlock sequence, kernel mode, the window and
MBC1 bits, the `$7FB4` command flag and the soft-reset counter. FW5-0918
debounces it: P61's input register is enabled only by the all-ones carry
of a 20-bit counter that restarts whenever P61 changes, so a level must
hold for 2^20 CLK0 cycles (about 43 ms on the cart's crystal) to be taken.
Its edge then restarts the PicoBlaze (license check and full card init,
which waits for /RESET to rise) and resets the SD controller and more
Game Boy registers: 16 LUTs use the edge, 4 as asynchronous resets and 12
as synchronous ones.

`gb_glitch.vh` pulses P61 during stage1's `sd_read`:

| Pulse | FW4 | FW5-0918 |
|---|---|---|
| 10 µs, during the read | window registers reset, the poll reads `$FF` and the sector comes back wrong; the next read is right | ignored |
| 10 µs to 30 ms | | ignored |
| 50 ms | | PicoBlaze restarts at the debounce, card re-init 16 ms after /RESET rises; a read issued meanwhile waits and comes back right |

So a short glitch hurts FW4, not FW5, and the low that FW5 does take also
holds the console's CPU in reset. The counter's one-cycle window opens and
closes on CLK0 edges, so a zero-delay simulation never sees P61 at all;
`+define+P61_TICK_CAPTURE` takes P61 at the window's closing edge as the
hardware does.

## The SD controller, FW4 to FW5-0918 (proved)

`stage0/tools/fw5-prove.sh` carries every SD block file to FW5 through
`belmatch.py` and `blkmap.py` and proves it with `equiv.sh`, against a copy
of FW5's design without the /RESET edge (`fw5-noedge.py`; every edit exact
and checked). The DCM change does not reach the SD side: the PicoBlaze,
the SD clock divider and the SD pads run on CLK2X in both, and FW5's
faster CLKFX (x10/3 against x3) clocks only the pSRAM controller and the
ROM-load byte sequencer.

| Block | Against FW5-0918 |
|---|---|
| clock divider, command master, command serializer, register file (`sd_controller_wb`), data master, FIFO filler, FIFOs | equivalent to FW4's module |
| crossings | equivalent to [stage0/fw5-0918/sd_crossings.v](../fw5-0918/sd_crossings.v): the 43 bits FW4 carries into the SD domain in one stage (command index, checks and with-data bits, command timeout, block size, bus width, byte alignment, soft reset) cross in two, as the source and FW4's argument, block count and data timeout do |
| data serializer | equivalent to [stage0/fw5-0918/sd_data_serial.v](../fw5-0918/sd_data_serial.v): the 4-bit data cycle count is the source's `(blksize << 1) + 2`, not FW4's `blksize \| 4`; the same for the 8n - 1 sizes the firmware uses |
| memory path | carried (116 of 131 bels) but not proved: its address inputs come from FW5's rebuilt Game Boy bus and pSRAM blocks |

## The rest of the design, FW4 to FW5-0918 (proved)

The same script now carries all twenty-two of FW4's block files
(`stage0/tools/fw5-prove.sh` with no arguments). Three things made the
Game Boy side carry at all:

- FW4 clocks its `$7Fxx` registers from `/WR | A15` and FW5 from `/WR`
  with A15 in every enable, so no decode LUT pairs. `regseed.py` pairs the
  registers instead, by address and data pin from the two register maps
  (76 of them).
- `belmatch.py --shape` pairs bels by the shape of the logic around them
  (a few rounds out, flip-flop and block RAM clocks left out), for logic
  no matched bel reaches or that moved to another clock. Block RAMs pair
  by how many bus bits agree; the PicoBlaze program banks and stage1's bit
  planes, alike in every port, are hand seeds in `fw5-seed.txt` by their
  contents (FW4's bank 0 is FW5's word for word).
- A pass can pair the wrong one of two alike registers (FW4's `port_id[1]`
  went to FW5's `port_id[3]`), so `belmatch.py` now drops any flip-flop
  pair whose D drivers are matched to other bels and reruns; 16 such pairs
  went on the first run. It also drops a pair whose D drivers differ in
  kind while one is matched elsewhere: FW4's `out_port[5]` and
  `out_port[6]` had gone to FW5 registers those bits feed.
- Where FW5 packs the same logic into other LUTs, a named net has no bel
  to carry to. `simblk.py` builds those blocks instead: it simulates both
  designs on random values (paired registers and pads sharing theirs),
  names each FW5 net that computes what a named FW4 net does, and takes
  the logic between the named inputs and outputs. A named pin output with
  no FW5 net of its function is named by its pad, and the proof shows
  what changed. `padseed.py` pairs the LUTs that drive each pad.

| Block | Against FW5-0918 (2026-11-02) |
|---|---|
| the nine SD blocks above | as above |
| soft reset | equivalent to [stage0/fw5-0918/soft_reset.v](../fw5-0918/soft_reset.v): FW4's module on CLK0 instead of CLK2X (synchronizer and counter both), so the console reset is held for 65536 CLK0 cycles, twice FW4's time; its carry-in is the shared constant-0 LUT |
| PicoBlaze | equivalent to FW4's module, unchanged. The packing difference the first run showed was two wrong `out_port` pairs, not FW5 |
| pSRAM controller | equivalent to [stage0/fw5-0918/psram_ctrl.v](../fw5-0918/psram_ctrl.v): one more way to reach U4, a `$A000-$BFFF` access with bank bit 7 set when the game bank is all ones with RAM enabled (an access FW4 keeps off both chips) or the kernel window mode is 6, 7 or 8 up. It is on page `$08`, with A0 carrying bit 0 of the MBC3 clock register number (`rtc_sel`). Port EF reaches it without FW4's CLK2X copy |
| SD memory path | equivalent to [stage0/fw5-0918/sd_mem_path.v](../fw5-0918/sd_mem_path.v), which also builds the Game Boy side of the address pins (FW4's `mem_a_gb`, from three blocks). On that clock access A7-A0 hold `rtc_sel + $18`, so each clock register has its own location in U4, and A9/A13 set. The sector buffer is block RAM X19Y17 |
| Game Boy registers | equivalent to [stage0/fw5-0918/gb_regs.v](../fw5-0918/gb_regs.v): one `/WR` clock with A15 in the `$7Fxx` key, no `/RESET`-level reset, the key from the unlock block's last register. MBC3 takes RAM banks `$00-$07` (FW4 `$00-$03`) and MBC1's mode-1 bank four masked bits (FW4 two). A data interrupt with the window off clears the `$7FB4` flag. (An earlier version of this row said only hours, day and year can be set; the other four registers and the `$7FD0` go flag are there, found while proving the RTC bridge.) The `$08-$0C` select loads the all-ones bank as on FW4 |
| RTC bridge | equivalent to [stage0/fw5-0918/rtc_bridge.v](../fw5-0918/rtc_bridge.v): FW4's on the PicoBlaze clock instead of the 2x clock, the readings on its falling edge and kept only as wide as each BCD value |
| Game Boy bus | equivalent to [stage0/fw5-0918/gb_bus.v](../fw5-0918/gb_bus.v): FW4's window remap, stage1 copies and block RAM enables, without the address pins (built in the SD memory path). The `$7FB4` write is on `/WR` with no `/RESET`-level term, the loader's busy flag has no CLK2X copy (a second port EF register stands in), the second stage of `/RESET` is unread, and the loader's table RAM (X3Y13) has its Game Boy port on the PicoBlaze clock |
| PicoBlaze ports | equivalent to [stage0/fw5-0918/picoblaze_ports.v](../fw5-0918/picoblaze_ports.v): FW4's port registers and SD bridge, plus OUTPUT A5-A9 (the seconds, minutes, hours, DL and DH the game's MBC3 latch copies) and an OUTPUT A1 that starts a 4-bit timer INPUT A0 reads. New reads: A5-A9 the game's writes to MBC3 clock registers `$08-$0C` (the kernel can write them at `$A010-$A014`), BB `$7FD3 + $7FD4` (a sum taken on the `$7FD4` write), B5 eight command bits (FW4 five), B8 two more (see the peripherals row). B9 reads `!kernel_mode` (FW4 1), B7 holds (FW4 0). The timer and the registers behind A5-A9 and BB are the FW5-only blocks below |
| peripherals | equivalent to [stage0/fw5-0918/pb_periph.v](../fw5-0918/pb_periph.v): FW4's ICAP registers and I2C enable; the interrupt source moves to the PicoBlaze clock and watches ten flags, FW4's five and the MBC3 clock's five wrote flags. B5 reads read, write, load, RTC set, flash, seconds, minutes, hours (bit 7 down), B8 DL and DH. The SPI pins moved to the SD memory path |
| MBC3 clock (FW5 only) | proven against [stage0/fw5-0918/mbc3_clock.v](../fw5-0918/mbc3_clock.v): the game's writes to clock registers `$08-$0C` (masked to the MBC3 widths: S/M 6 bits, H 5, DH bits 0/6/7; the kernel writes all eight at `$A010-$A014`), five flags that say which register the game wrote (cleared by a `$6000-$7FFF` write, DH's also by a seconds write), the `$6000` register and the latch (`$01` over `$00` copies OUTPUT A5-A9 into `lat_*`), and a RAM enable (`$0A` at `$0000-$1FFF`) that gates only the clock registers |
| `$7Fxx` additions (FW5 only) | proven against [stage0/fw5-0918/fw5_7fxx.v](../fw5-0918/fw5_7fxx.v): `$7FD3`, whose bit 7 sits in the d7 pad's input register (FW5 loads that pad on `$7FD3`, the other seven on `$7FB4`), the sum `$7FD3 + $7FD4` taken on the `$7FD4` write (port BB), and `$7FC3` bit 7. A3 isn't decoded, so `$7FDB`/`$7FDC` alias them |
| PicoBlaze timer (FW5 only) | proven against [stage0/fw5-0918/pb_timer.v](../fw5-0918/pb_timer.v): OUTPUT A1 queues a unit of 540 PicoBlaze clocks (up to 15), INPUT A0 reads the queue. The prescaler is a 0-26 counter and a 20-step phase machine with a 3-bit counter, kept as XST encoded them |
| data out | equivalent to [stage0/fw5-0918/gb_data_out.v](../fw5-0918/gb_data_out.v): the game's MBC3 clock reads return five latched registers (S, M, H, DL, DH, loaded on the `$6000` latch: `$01` after `$00`), where FW4 converts the live PCF8563 BCD and serves DH as 1. The kernel window reads the RTC bridge's registers, which keep only the bits each BCD value uses. Other register-window reads return 0 (FW4 `$FF`), `$7FC0 = 4` reads `$05` (FW4 `$04`), and `$7FC3` bit 7 is a register. Two of stage1's bit-plane RAMs are now paired by the data bit they drive |
| unlock | equivalent to [stage0/fw5-0918/unlock.v](../fw5-0918/unlock.v): four one-hot registers (idle, after `$E1`, after `$E2`, unlocked) where FW4 encodes the states in two. FW5 unlocks on the `$E3`, where FW4 unlocks on the `$E2` and the `$E3` only keeps it, and the writes that stay unlocked add `$7FD3` and `$7FD4` |
| clocks | equivalent to [stage0/fw5-0918/clocks.v](../fw5-0918/clocks.v): FW4's clock gates and DCM reset on other buffers, no `/WR \| A15` clock (FW5's Game Boy registers all run on the `/WR` pad), 22 constant-0 LUTs (FW4 15) |
| P51 latch | equivalent to FW4's module, unchanged: a latch on `flash_op` in FW5 too. The carry took the A13 mux's whole cone with it, so its block file is written in FW5's coordinates ([stage0/fw5-0918/p51_latch.blk](../fw5-0918/p51_latch.blk)) |
| `/RESET` debounce (FW5 only) | proven against [stage0/fw5-0918/reset_debounce.v](../fw5-0918/reset_debounce.v): `/RESET` synchronized on CLK0 and a 20-bit counter, restarted when it falls, whose all-ones state enables the `/RESET` pad's input register. The pad is sampled once every 2^20 CLK0 cycles, the first time 2^20 after it fell |

> **Correction (2026-11-02):** an earlier version of this table called
> FW5's P51 register a flip-flop and its DCM-clock counter 22 bits. The
> P51 register is a latch on `flash_op`, as on FW4, and the counter is 20
> bits; the other two flip-flops on that clock are its `/RESET`
> synchronizer.

> **Correction (2026-11-02):** an earlier version of this paragraph said FW5
> serves the MBC3 clock registers from U4. `gb_data_out` (in the table above)
> shows the read data comes from FPGA registers: the latched S, M, H, DL
> and DH. What U4 page `$08` gets is the access itself, so a game's write
> to a clock register lands there.

Selecting `$08-$0C` loads the all-ones bank and `rtc_sel` (proved in
`gb_regs`, as on FW4), and a `$A000-$BFFF` access with RAM enabled then
selects U4 page `$08`, the register number on the address pins, while the
FPGA drives the read from its latched copies. A game's write to a clock
register also lands in an FPGA register the PicoBlaze reads (INPUT
A5-A9), and the PicoBlaze writes the values the latch copies (OUTPUT
A5-A9), so the clock runs through the PicoBlaze both ways. Not checked
yet: what its firmware does with them.

The whole of it is proved too, as FW4's is (2026-11-02):
`stage0/tools/fw5-top.sh` stitches the 26 blocks into
[stage0/fw5-0918/fw5_top.v](../fw5-0918/fw5_top.v) with
`mktop.py` and runs `prove-top.sh` on them. The wiring pass proves
`fw5_logic` over the carved blocks equal to every slice bel of the design
(7,657 signals); the rtl pass proves it equal over the readable modules
(4,679 signals, 130 of them under the modules' invariants), and every
invariant, the `env_*` assumptions about other blocks included, holds on
the reference from reset. Four cells sit in two blocks each (the shared
constant-0 LUT, and three LUTs `gb_data_out` and `psram_ctrl` share); the
first block's copy drives the net. Stitching found one wrong assumption:
`mbc3_clock` stated `type0_n2`, `type1_n2` and `rtc_sel_d` in terms of
`mbc_type[2]`, a bit no cell of the block reads, so the top tied it to 0
and the assumptions failed for any type with bit 2 set. The module now
builds its MBC3 test from those decodes, as the hardware does.

The design proved against still lacks FW5's /RESET edge, which also resets
FW5's 34 `/WR` registers (FW4 resets 15 from the /RESET level), so
modules with a reset port will prove with it tied off until the edge has
a block of its own.

The extra stage still leaves the command one SD clock ahead of the
three-stage start pulse that triggers it. The PicoBlaze's card init is
unchanged too (it is not in the bank 1 table above), and a slow card
initializes the same way on both in simulation: with ACMD41 answered busy
(`models.v +SD_BUSY_N`) both give up after the 255th try and carry on as a
standard-capacity card, and 64-clock response delays (`+SD_NCR`) work on
both. With stage1 changed only at `$7FD3`, none of this explains a card
that fails to initialize on FW5 and not on FW4.

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
