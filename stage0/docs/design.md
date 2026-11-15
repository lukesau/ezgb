# The hardware map: pins, clocks and registers

What the FPGA connects to, and what the Game Boy sees of it: every register
it can write and what a read returns. This is FW4's design, reversed from
the slot B bitstream with no design files and since proven
([README](../README.md)). Where FW5 differs is in
[firmware-diff.md](firmware-diff.md).

## Pins

68 of the package's pins are used. The full table is `stage0/fw4/pins.txt`
and `stage0/netlist/pintable.py`.

### The Game Boy cartridge bus

| Signal | Pin |
|---|---|
| A0-A7 | P88 P89 P90 P93 P94 P97 P98 P99 |
| A8-A10 | P82 P68 P39 |
| A11, A12 | P21, P4 |
| A13, A14, A15 | P5, P6, P7 |
| D0-D7 | P3 P9 P10 P12 P13 P15 P16 P19 |
| `/WR` | P84, a clock pad: it clocks the registers that latch D0-D7 |
| `/RESET` in | P61 |
| `/RESET` out | P62 |

**There is no `/RD` or `/CS`.** The FPGA drives D0-D7 whenever `/WR` is
high, for any address in its ranges, except at `$C000`-`$DFFF`. On a
console `/RD` is low except during writes, so this amounts to the same
thing.

**Reset is a pair of pins.** P61 reads the console's `/RESET` at the cart
edge, and P62 is the FPGA's drive of it, through 330 ohms. A falling edge
on P61 asynchronously resets the unlock state machine and the mode
registers. P62 is driven push-pull, which is why the Jr fails on a Super
Game Boy ([sgb-boot.md](../../docs/sgb-boot.md)).

### Everything else

The two memory chips share a 16-bit bus.

| Function | Pins |
|---|---|
| SPI config flash | CS P27, CLK P53, MOSI P46, MISO P51 |
| SD card | CLK P23, CMD P28, DAT0 P34, DAT1 P25, DAT2 P30, DAT3 P29 |
| Clock chip (I2C) | SCL P31, SDA P32 |
| memory word address A0-A10 | P56 P59 P65 P71 P70 P73 P44 P50 P83 P86 P20 |
| memory word address A11-A13 | P53, P46, P51: the config flash's CLK, MOSI and MISO, reused once the flash has been read |
| memory upper address | through the 74HC595: SRCLK P35, SER P33, RCLK P24 |
| memory data | P41 P48 P49 P57 P64 P72 P77 P78 |
| memory `/LB`, `/UB`, `/WE` | P37 (even bytes), P36 (odd bytes), P40 |
| memory `/CE` | P52 (U9, the game store), P60 (U4, saves) |
| oscillator | P43, 24.545 MHz |

The memory's `/OE` is not identified.

## Clocks

| Source | Clocks | Use |
|---|---|---|
| P43 through a clock manager: the crystal, twice it (49.09 MHz), and a multiplied clock | the system clocks | everything below |
| a divided clock | 661 flip-flops | the SD logic's main clock, also driven out as the SD clock |
| the system clock or a gated one, by mode | 391 flip-flops | logic that switches with the stage1, kernel and game modes |
| P84, `/WR` | 160 flip-flops | the registers the Game Boy writes |
| twice the crystal, gated | the PicoBlaze and its ports | **stopped in a plain game**; runs in kernel mode, and in a game only when the RTC flag is set |
| the multiplied clock, gated | the ROM load's byte sequencer | kernel mode only |

So in a game without a clock the processor stands still, and the cart is
just memory behind an MBC.

## Modes

One register bit, `$7F32` bit 7, switches the whole design between kernel
mode and game mode.

| `$7F32` bits 7, 3 | State | Set by |
|---|---|---|
| `1 1` | stage1: reads below `$8000` return stage1 from block RAM | power-on |
| `1 0` | kernel: reads below `$8000` return the game store, where the kernel was loaded | stage1's hand-off, `$7F32 = $80` |
| `0 0` | game | the kernel's launch, `$7F31 = 0` and `$7F32 = 0` |

In kernel mode the bank registers are plain latches and the SD and
PicoBlaze logic runs. In game mode that logic stops and writes to
`$0000`-`$7FFF` go through the MBC the game's type names.

## Unlock and commit

Every write to a `$7Fxx` control register sits inside the same envelope:
three unlock writes, the register writes, then a commit.

```
$7F00 = $E1
$7F10 = $E2
$7F20 = $E3
  ... one or more register writes ...
$7FF0 = $E4
```

The kernel inlines this at every call site (29 in 1.05e), and stage1 and
the updater use it too. The Omega kernel has the same design at GBA
addresses (`SetSDControl` in its `Ezcard_OP.c`).

The `$7Fxx` registers decode only the low address byte. The commit also
clears the request flags below, which matters: a request raises the
PicoBlaze's interrupt on its rising edge only.

## Registers written by the Game Boy

The proven source for all of this is
[gb_regs.v](../fw4/rtl/gb_regs.v).

| Address | Bits | Use |
|---|---|---|
| `$7F30` | 0-1 | the `$A000` window's enables: bit 0 makes the sector buffer readable, bit 1 makes it read `$01` |
| `$7F32` | 7, 3 | the mode, above |
| `$7F36` | 0-1 | bit 0 the load command window, bit 1 the loader's start |
| `$7F37` | 0-3, 7 | the MBC type a game gets: 0 none, 1 MBC1, 2 MBC2, 3 MBC3, 4 MBC5, 5 MBC1 multicart. Bit 7 is the RTC flag |
| `$7FB0`-`$7FB3` | 8 each | the sector address |
| `$7FB4` | 8 | the sector count, with bit 7 set for a write. The write is the request |
| `$7FC0` | 0-3 | what the `$A000` window shows, below |
| `$7FC1`, `$7FC2` | 8, 1 | the ROM bank mask, 9 bits |
| `$7FC3` | 8 | the header checksum a game reads at `$014D` |
| `$7FC4` | 0-3 | the RAM bank mask |
| `$7FD0` | 0 | the request to set the clock |
| `$7FD2` | 0 | the request for a config flash operation. It also hands two memory address pins to the flash ([updater.md](updater.md)) |
| `$7FE0` | 7 | the soft reset request: the console's `/RESET` is held low for 65,536 cycles |
| `$7FD3`, `$7FD4` | | FW5 only: the fast-load key ([firmware-diff.md](firmware-diff.md)) |

The bank registers, in kernel mode:

| Address | Use |
|---|---|
| `$2000`-`$2FFF` | the ROM bank, a plain 8-bit latch |
| `$3000`-`$3FFF` | its bit 8 |
| `$4000`-`$5FFF` | the save page, for the `$7FC0 = 3` window |
| `$A008`-`$A00E` in the clock window | the seven clock values to set |

In game mode:

| Type | ROM bank | RAM |
|---|---|---|
| MBC1 | five bits at `$2000`-`$3FFF`, two at `$4000`-`$5FFF`, the mode at `$6000`-`$7FFF`. Masked | the two high bits, in mode 1 |
| MBC2 | five bits at `$2000`-`$3FFF` with A8 set. Not masked | enabled from `$0000`-`$1FFF` with A8 clear |
| MBC3 | seven bits at `$2000`-`$3FFF`. Not masked | bank `$00`-`$03`, or `$08`-`$0C` to select a clock register |
| MBC5 | eight bits at `$2000`-`$2FFF`, bit 8 at `$3000`-`$3FFF`. Masked | four bank bits, masked |
| MBC1 multicart | its own four-bit register | bank 0 |

The RAM enable is a low nibble of `$A` written to `$0000`-`$1FFF`.

**The memory page is the bank register.** A load puts bank N at
N x `$4000` in the game store, so no translation is needed: bit 0 of the
bank goes out on memory address A13 and the rest through the 74HC595.

## What a read returns

In order of precedence ([gb_data_out.v](../fw4/rtl/gb_data_out.v)):

1. `$01` while the loader runs: the status the kernel polls.
2. In the sector buffer window (`$7FC0 = 0`, `$A000`-`$BFFF`): `$E1` from
   the `$7FB4` write until the transfer's data interrupt, `$01` while
   `$7F30` bit 1 is set, else the buffer's byte.
3. In stage1 mode, below `$8000`: stage1, from block RAM.
4. `$04` at `$7FC0 = 4`, and the flash writer's busy flag at `$7FC0 = 5`.
5. In the clock window: the seven values the PicoBlaze reads from the
   clock chip, at `$A008`-`$A00E` in kernel mode. In game mode they are
   served the MBC3 way, by the value written to `$4000`, converted from
   BCD to binary.
6. The header checksum register at `$014D` in game mode.
7. Otherwise the memory chip's data pins.

### The values of `$7FC0`

| Value | The `$A000` window shows | Used by |
|---|---|---|
| `$00` | the sector buffer, with `$7F30` bit 0 | every SD read and write |
| `$01` | the game store | |
| `$02` | the load command table, with `$7F36` bit 0 | stage1, and the kernel's launch |
| `$03` | the save pSRAM, at the page in `$4000` | saves, the browser's records, the kernel's records |
| `$04` | the firmware version byte | the HELP tab |
| `$05` | the flash writer's busy flag | the updater. In the kernel only in a routine nothing calls |
| `$06` and up | the clock registers | reading and setting the clock |

No value maps either NOR die.

### The version byte

`$7FC0 = 4` reads `$04` on FW4 and `$05` on FW5. The number is not stored
anywhere. One LUT decodes "version read" (kernel mode, window 4,
`$A000`-`$BFFF`), and the version is simply which data bits that signal is
wired into:

| Design | The decode | Wired into | Byte |
|---|---|---|---|
| FW4 | `X12Y18 SLICE[3]` | D2 | `$04` |
| FW5-0731 | `X9Y23 SLICE[2]` | D0 and D2 | `$05` |
| FW5-0918 | `X9Y21 SLICE[3]` | D0 and D2 | `$05` |

It is a constant in EZ Flash's source that synthesis turned into routing.
Each firmware is a complete design written whole to slot B, which is why
the number changes with no "set version" step.

## Launch sequences, as register writes

**Stage1 loading the kernel:** `$7FC0 = 2`, the load command through the
`$7F36 = 1` window, `$7F36 = 3`, poll `$A000` until the load is done, then
`$7F36 = 0`, `$7FC0 = 0`, ROM bank 1, `$7F31 = 0`, `$7F32 = $80`.

**The kernel launching a game:** `$7FC0 = 2`, the type to `$7F37`, the
masks to `$7FC4`, `$7FC1` and `$7FC2`, the header checksum to `$7FC3`, the
load, `$7F36 = 0`, `$7F31 = 0`, `$7F32 = 0`, `$2000 = 1`, `$3000 = 0`, then
`$7FE0 = $80`.

Right after `$7F36 = 3` the `$A000` window floats for about a cycle and a
half while the FPGA switches it over. A poll that fast reads `$FF`.

## Two things found in simulation

- **The firmware races its own status clear.** The PicoBlaze clears the
  SD command status after a command completes, but the clear takes three
  SD clocks to cross domains and the next command's first poll comes after
  two. So `CMD55` reads as complete before it is sent, and the `ACMD41`
  after it is lost. The retry loop covers it, at the cost of one 20 ms
  delay a boot.
- **`CMD7` goes out with the address `$0200`** whatever the card's `CMD3`
  reply says. Why has not been looked into.

P51, the pin that carries memory address A13, is driven through a latch
gated by `$7FD2` bit 0, and a second latch in a slice holds the same
value. Both are transparent while the bit is 0, which is what the kernel
leaves it at. The decoded gate bit reads the other way round.

> **Correction (2026-11-14).** This paragraph used to say the latch's
> polarity was still owed a check on hardware, and the slice latch was
> modeled as decoded (transparent while the bit is 1). ISE settles it
> ([stage0/ise](../ise/README.md)): built from `p51_latch.v` written
> transparent-while-1, it sets the slice's CLK inversion where stock's is
> clear; written transparent-while-0, it matches stock. So every latch's
> gate is inverted against the decoded bit, the slice latch included.
> `p51_latch.v` and `netlist2v.py` (which already inverted the IO tile's
> latch) are corrected; anything simulated or proven on the old slice
> latch inherits the fix.
