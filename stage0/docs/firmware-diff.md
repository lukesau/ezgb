# FW4 against FW5

What changed between the three firmwares the mod supports: FW4,
FW5-0731 and FW5-0918. Each was exported to Verilog the same way and put
through the same tests, and FW5-0918 is proven block by block against
FW4's readable Verilog. Every build is placed from scratch, so the
comparisons are by function, not by position. The images themselves are
in [flash-map.md](flash-map.md).

## What did not change

- **The pins.** All three use the same 68 pins in the same modes, so the
  board did not change.
- **Loading and banking.** Stage1's kernel load, the kernel's game launch,
  every MBC type and save RAM behave identically in simulation on all
  three ([below](#banking-and-save-ram)).
- **The SD routines.** The PicoBlaze's card init and its read and write
  commands are the same code. FW5 answers a sector read a little sooner (8
  status polls against 12).
- **The PicoBlaze's second program** (the flash, the license check, the
  hand-over) is identical in every image.

So everything that differs is in the clock handling, two new registers,
reset, and stage1's header.

## What FW5 changed, in short

| | FW4 | FW5 |
|---|---|---|
| Fast loading | every SD run is followed by a pause | the pause is skipped when the fast-load key is set |
| A game's clock (MBC3) | the game reads the cart's wall clock, and its writes are ignored | an emulated MBC3 clock with latch, writes and (0918) halt |
| Console `/RESET` | sampled every clock edge; a 10 µs glitch resets the registers | debounced for about 43 ms (0918) |
| Stage1's header | no SGB marks | SGB flag and licensee code set (0918 and the SGB beta) |
| The multiplied clock | x3 | x10/3. It clocks only the memory controller and the ROM load's byte sequencer |
| `$7Fxx` decode | the low address byte, on a `/WR | A15` clock | the low byte with A15 in the enable, on `/WR` |
| The unlock | unlocked from the `$E2` write | unlocked on the `$E3` write |
| MBC3 RAM banks | `$00`-`$03` | `$00`-`$07` |
| Soft reset length | 65,536 cycles of twice the crystal | 65,536 cycles of the crystal: twice as long |

## FW5's new registers

| Address | What |
|---|---|
| `$7FD3` | a byte, added to the next `$7FD4` write |
| `$7FD4` | the write stores `$7FD3` plus the byte written. The sum is the fast-load key |
| `$6000`-`$7FFF` | the MBC3 latch: writing `$01` after `$00` copies the live clock into the copy a game reads |

FW4 decodes none of them.

### The fast-load key

The sum reaches the PicoBlaze as an input port. FW5's loader reads it once
when a load starts, and if it is `$11` it skips the long delay after every
SD run. FW4's loader always waits.

Both registers power up 0. What happens next decides the speed:

| Firmware and kernel | `$7FD3` | `$7FD4` | Result |
|---|---|---|---|
| stock stage1, stock 1.05e | stage1 writes the console's boot `A`: `$11` on a GBC or GBA, `$01` on a DMG | the kernel writes `$00` | fast on GBC and GBA only |
| stock stage1, 1.04e | as above | never written | slow: the sum is never taken |
| the modded kernel | writes `$00` | writes `$11` | fast on every console |
| our stage1 with a stock kernel | passes the boot `A`, as stock does | `$00` | as stock |

In simulation the key makes FW5 issue each next read command 15 µs after
the stop command where it otherwise waits about 1.1 ms: a 64 KB load takes
5.5 ms against 10.1 ms. The simulation runs the delay at a twentieth of
its real length, so on a cart each skipped delay is about 20 ms per SD
run, roughly 0.7 s per MB of ROM. That has not been timed on hardware.

## Console `/RESET`

FW4 samples the console's `/RESET` on every edge of the fast clock, and a
falling edge resets about 46 flip-flops: the unlock, kernel mode, the
window and MBC1 bits, the sector command flag and the soft reset counter.

FW5-0918 debounces it. The pin's input register is enabled only when a
20-bit counter, restarted whenever the pin changes, reaches all ones, so a
level must hold for 2^20 crystal cycles, about 43 ms, to be taken. Its
edge then restarts the PicoBlaze, with a full card init, and resets the SD
controller.

| A low pulse during a sector read | FW4 | FW5-0918 |
|---|---|---|
| 10 µs | the window registers reset and the sector comes back wrong | ignored |
| up to 30 ms | | ignored |
| 50 ms | | the PicoBlaze restarts and the card is initialized again; a read issued meanwhile waits and comes back right |

## The game clock

| | FW4 | FW5-0731 | FW5-0918 |
|---|---|---|---|
| What a game reads | the cart's wall clock, converted to binary | time elapsed since the launch, from a base the kernel sets | the same |
| The `$6000` latch | none: the live clock | latched | latched |
| A game writes seconds or minutes | ignored | taken through wrap arithmetic, so an out-of-range value carries into the next field | taken as written, masked to the field's width |
| The halt bit | ignored | ignored | honored |
| Day counter overflow | | the carry is set and day bit 8 stays set | the carry is set and day bit 8 is cleared, as on a real MBC3 |
| With RAM disabled | `$FF` | `$FF` | `$FF` |

How FW5 does it: selecting clock register `$08`-`$0C` through the RAM bank
register makes a `$A000` read return one of five latched registers in the
FPGA. A game's write lands in a register the PicoBlaze reads, with a flag
per register saying it was written, and the PicoBlaze writes the values
the latch copies. So the clock runs through the PicoBlaze both ways: it
counts the clock chip's seconds into elapsed seconds, minutes, hours and
days and outputs base plus elapsed.

FW5-0731's fabric has no flags for a game's writes, which is why its
clock cannot honor them. The SGB beta added them, and 0918 added halt,
range masking and the day carry. In 0918 the clock chip is polled only
while no game's clock is running.

The kernel's side of this is in
[kernel-versions.md](../../docs/kernel-versions.md#104e-to-105e).

## Stage1's header

Read off the bus at power-on, all three have the title `BOOTLOADER` and
cart type `$01`. FW5-0918 and the SGB beta differ from FW5-0731 in three
bytes:

| Offset | FW4, FW5-0731 | FW5-0918, the SGB beta |
|---|---|---|
| `$0146` | `00` | `03`: supports SGB functions |
| `$014B` | `00` | `33`: the licensee code an SGB requires |
| `$014D` | `FA` | `C4`: the header checksum |

That is all of the "SGB support" in the bootloader, and it is not enough
to make the cart work on one ([sgb-boot.md](../../docs/sgb-boot.md)).
FW5-0918's stage1 also writes the boot `A` to `$7FD3`.

## The PicoBlaze's first program

FW4 to FW5-0731: 72 of 78 routines are identical
(`stage0/tools/picoblaze-diff.py`).

| Routine | FW5-0731 |
|---|---|
| the main loop | adds the game clock |
| `cmd_load_rom` | reads the fast-load key |
| `load_rom_loop` | skips the long delay after each run when the key is `$11` |
| `rtc_init` | no longer stops the clock chip and writes its clock-out register at boot |
| `sd_setup_dma` | a debug output removed |
| the interrupt handler | a debug output added; a ROM load also zeroes the elapsed clock |

FW5-0731 to FW5-0918: 76 of 78 identical. Only the main loop and the
interrupt handler changed, for the clock, and the per-interrupt debug
output is gone.

## Save pages from the kernel

In kernel mode the save pSRAM is reached with `$7FC0 = 3`, a page number
written to `$4000`, and the `$A000`-`$BFFF` window. The same on all three:

- **The page latch is 5 bits.** `$4000 = $20`-`$3F` puts exactly the same
  address on the memory pins as `$00`-`$1F`. No pin carries bit 5.
- **Only the low byte of each memory word is used**, in kernel mode and
  for a game's save RAM alike: `$A000 + k` lands on U4 byte
  `page x $4000 + 2k`. A page is 8 KB to the Game Boy and spans a 16 KB
  slot, so the 32 pages use the whole 512 KB part.
- A game's save RAM bank N and kernel page N are the same memory.

## Banking and save RAM

A model of each MBC, checked against about 1,000 simulated reads across
the three firmwares (`mbctest.py`):

| Type (`$7F37`) | ROM banking | Save RAM |
|---|---|---|
| 0 none | 32 KB fixed | disabled, reads `$FF` |
| 1 MBC1 | 5-bit low register (0 selects 1); the ROM upper bits and the RAM bank are **separate registers**: a `$4000` write in mode 0 sets the upper bits, in mode 1 the RAM bank, and switching modes doesn't move one into the other. `$0000-$3FFF` is always bank 0 | banks 0-3, used only in mode 1 (bank 0 in mode 0) |
| 2 MBC2 | **5-bit** bank register at `$2000-$3FFF` with A8=1, not limited by the ROM mask (`$1F` selects `$1F` with mask `$0F`); 0 selects 1 | enabled only from `$0000-$1FFF` (`$2000=$0A` doesn't); full bytes, not 4-bit |
| 3 MBC3 | 7-bit, 0 selects 1 | banks 0-3; `$08-$0C` select the clock |
| 4 MBC5 | 9-bit (`$3000` D0 is bit 8, other bits ignored), 0 selects 0 | banks 0-15, masked by `$7FC4` |
| 5 MBC1 multicart | 4-bit low register, upper bits shifted by 4, mode 1 banks `$0000-$3FFF` with the upper bits | bank 0 only |

- The ROM bank mask (`$7FC1`, `$7FC2`) applies to MBC1, the multicart and
  MBC5. MBC2 and MBC3 are not masked.
- Save RAM bank N sits at U4 offset N x `$4000`.
- The RAM enable looks only at the low nibble, anywhere in
  `$0000`-`$1FFF`: `$1A`, `$FA` and `$0A` all enable.
- Reads with RAM disabled return `$FF`, and writes never reach the chip.

## FW5-0918, block by block

`stage0/tools/fw5-prove.sh` carries each of FW4's 22 block files to
FW5-0918 and proves it, against FW4's module where the block is unchanged
and against a module in [fw5-0918/](../fw5-0918/) where it differs. Four
blocks exist only in FW5. `fw5-top.sh` then stitches the 26 and proves the
whole, as for FW4.

The SD controller:

| Block | Against FW5-0918 |
|---|---|
| command master, data master, FIFO filler | equivalent to FW4's module, with the `/RESET` edge in the soft reset they take |
| clock divider, command serializer, register file (`sd_controller_wb`), FIFOs | equivalent to FW4's module with the `/RESET` edge added ([stage0/fw5-0918](../fw5-0918/)): the source's Wishbone reset, see the `/RESET` edge row |
| crossings | equivalent to [stage0/fw5-0918/sd_crossings.v](../fw5-0918/sd_crossings.v): the 43 bits FW4 carries into the SD domain in one stage (command index, checks and with-data bits, command timeout, block size, bus width, byte alignment, soft reset) cross in two, as the source and FW4's argument, block count and data timeout do |
| data serializer | equivalent to [stage0/fw5-0918/sd_data_serial.v](../fw5-0918/sd_data_serial.v): the 4-bit data cycle count is the source's `(blksize << 1) + 2`, not FW4's `blksize \| 4`; the same for the 8n - 1 sizes the firmware uses |

The rest:

| Block | Against FW5-0918 |
|---|---|
| soft reset | equivalent to [stage0/fw5-0918/soft_reset.v](../fw5-0918/soft_reset.v): FW4's module on CLK0 instead of CLK2X (synchronizer and counter both), so the console reset is held for 65536 CLK0 cycles, twice FW4's time; its carry-in is the shared constant-0 LUT |
| PicoBlaze | equivalent to FW4's module, unchanged. |
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

| `/RESET` edge (FW5 only) | proven against [stage0/fw5-0918/reset_edge.v](../fw5-0918/reset_edge.v): the debounced `/RESET` register one CLK0 cycle late (`rst_prev`) and the edge, `rst_prev & !gb_reset_n_q`. The edge is the SD controller's Wishbone reset (every register of the clock divider, register file and crossings; the register file's block size back to 511), joins the soft reset (`sd_rst`, made in the FIFOs block) for the command master, data master, data host and filler, and joins `go_idle` in the command serializer's reset. It restarts the PicoBlaze (its reset synchronizer), clears the unlock, the `$7FD4` sum, the MBC3 clock's RAM enable, the memory page and 21 Game Boy registers (kernel mode and `$7F32` bit 3 back to 1, the window, the MBC registers), and no `/WR` register takes a write in its cycle |

### What the proof covers

The blocks are proven against FW5 as it is, with the console `/RESET`
edge (`fw5-noedge.py --keep-edge`, which keeps only its two other
normalizations). `fw5-prove.sh` still matches FW4 and FW5 on the design
without the edge, where the two line up, and carries the block files from
that match.

> **Correction (2026-11-14).** This section used to say the proof left the
> `/RESET` edge out, with the modules' reset ports tied off. A build from
> that readable design would not reset the SD controller, the PicoBlaze or
> the `/WR` registers when the console resets, as it does when the kernel
> starts a game. The edge is now in the readable modules (the `reset_edge`
> row above) and every block and the top level prove against FW5 with it.
> Also corrected the same day: `netlist2v.py` wrote FW5's DCM as x10, so
> simulations of FW5 ran the multiplied clock at x10, not x10/3; it now
> writes the divider.

### The SD init error

Some cards that work on FW4 stop at `Micro SD initial error` on FW5.
Nothing found here explains it. The PicoBlaze's card init is unchanged,
the SD clock is the same and in specification, the extra synchronizer
stage leaves the command path's timing intact, and in simulation a card
that answers slowly or stays busy initializes the same way on both. The
practical answer is the recovery patch
([sd-recovery.md](sd-recovery.md)).
