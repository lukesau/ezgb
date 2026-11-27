# The firmware updater from source

EZ Flash's updaters (`Update_FW4.gb`, `Update_FW5_2021-9-18.gb`, `Update_FW6_20261127.gb`) are a
32 KB Game Boy program followed by the bitstream it writes to the config
flash ([../docs/updater.md](../docs/updater.md)). This is that program in
C, for all three firmwares from one source. `make` builds it identical to stock:
with the stock bitstreams after it, the result is the official file.

```bash
stage1/decomp/tools/build-sdcc29.sh     # once: SDCC 2.9.0 into tools/sdcc-2.9.0
make -C stage0/updater                  # build/<fw4|fw5-0918|fw6>/updater-code.gb
make -C stage0/updater match            # per function, against the official updaters
stage0/updater/tools/link.py fw4 --label "My build" --payload slotB.bin -o Update.gb
```

Needs SDCC 2.9.0 for the C, a current SDCC for `sdasgb` and `sdldgb`, and
Python 3. No file of EZ Flash's: the build checks its result against [stock.sha1](../../stock.sha1).
`stage0/tools/build-stage0.sh` wraps the bitstream it builds this way.

## What the updater is

A cut-down kernel. It has the kernel's startup code and libraries, some of
the kernel's functions unchanged, and about 1 KB of its own: the screen and
the write loop.

| Where (FW4) | Source | What |
|---|---|---|
| `00:0000`-`07BB` | the kernel's `gbdk/crt0.s` | vectors, header (title `UPDATE`), startup, interrupts, `banked_call` |
| `00:07BC`-`120E` | `src/updater.c` | `WaitJoypadSelect`, `PlotBitRowXY` and `U32ToAscii_B0` as in the kernel; a string routine for a 12-pixel font; `main` |
| `00:120F`-`14FD` | `src/flash.c` | the register writes, the version read, `Update` |
| `00:14FE`-`1559` | `src/fpga.c` | the `$7FC0` write |
| `00:155A`-`1C98` | `src/font12.c` | the kernel's 8x12 font and its glyph plotter |
| `00:1C99`-`386B` | libraries | GBDK's console, drawing, font, joypad and delay; SDCC's stubs, divide, shifts, `strlen` and `puts`; the long math |
| `01:4000`-`404D` | `src/poll.c` | `FlashPoll`, linked to run at `$D000` (FW6: to `405D`) |
| `01:404E`-`4181` | `src/bank1.c` | `RunFlashPoll`, and three of the kernel's string functions nothing calls |

The libraries are not copied here. `tools/link.py` takes them from
`kernel/stock` and `stage1/decomp`, and edits three things at
build time: the header's title and ROM size and the function the startup
code calls (`crt0.s`), the order of the drawing library's variables, and
where the long math is cut into objects. EZ Flash's linker interleaved the
library objects in an order of its own, so each gets an address
(`OBJS` in `link.py`), and the build fails unless they tile the ROM.

## FW4 against FW5-0918

One source, `#if FW == 5`:

- FW5's `Update` prints `Do not touch any key when updating!!!` and turns
  interrupts off for the whole update. FW4's turns them off around each
  block's flash operation.
- The progress and `Update finish` lines are three rows lower.
- The version line says `ver:5`.

That makes `Update` `$38` bytes longer, and everything after it in bank 0
`$38` higher. Bank 1 is the same.

FW6's program (`-DFW=6`) is FW5's with `ver:6` on the version line and a
longer `FlashPoll`: after it starts the flash operation it reads `$A000`
59 times before the first read it acts on. That is 16 bytes more, so the
rest of bank 1 sits 16 bytes higher. With FW6's bitstream after it, the
build is `Update_FW6_20261127.gb` byte for byte. The global checksum in
its header is the sum of the program plus `$7EE0`, where every earlier
updater has `$7F70`; what the constant stands for is not known. The
release of 2026-11-24 and the test build of 11-17 had FW5's `FlashPoll`
(two bytes from FW5's program: the digit and the checksum).

The FW5 file carries a second bitstream after the first. The program's
loop stops at 149,516 bytes, so it is never written; `link.py` leaves it
out unless given a second `--payload`.

## What the source shows

- **The percentage has no variable.** The line is
  `i * 100 / 0x2480c + 1`, with `i` the byte offset. The compiler turned
  `i * 100` into a second counter that steps by `$6400`, which is why the
  disassembly looks as if the source kept one.
- **`Current ver:` reads `$A000`** with `$7FC0 = 4`, from a routine copied
  to WRAM, like the flash poll.
- **The string routine handles GB2312.** A byte from `$80` starts a
  two-byte character drawn from a 12x12 font in ROM banks `$0A`-`$15`,
  which the updater does not have. The kernel's 12-pixel font (its bank 8,
  unused there) is what draws the hex numbers of a debug routine nothing
  calls.
- **`ReadVersion` has no prototype where `main` calls it**, so the call
  returns an `int`. The text goes out through SDCC's `puts` and the copies
  through GBDK's `set_data`.
- **The global checksum** in the header is the sum of the 32 KB program
  plus `$7F70` in both stock files, whatever the bitstream. Nothing checks
  it. `link.py` writes it the same way.

## Matching

```bash
stage0/updater/tools/match.py [fw4|fw5-0918] [-v] [file ...]
stage0/updater/tools/fdiff.py FILE FUNCTION [fw4|fw5-0918] [-n]
```

`match.py` compiles each file and compares every function `updater.sym`
names with the official updater, masking what the linker fills in.
`fdiff.py` shows one function as an instruction diff. All 25 match on both
firmwares.
