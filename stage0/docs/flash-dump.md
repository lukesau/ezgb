# Dumping the config flash from the Game Boy

Reads the whole 512 KB config flash and the FPGA's serial number (its
Device DNA) to the SD card, with no desoldering and no JTAG. It works on an
FW4 cart. Two parts:

- **A PicoBlaze patch** ([flash-read.psm](../flash-read.psm)) that adds a
  read mode to the flash-update command. It is in every updater this
  project builds.
- **START on the debug screen**
  ([flash_dump.c](../../kernel/mod/src/flash_dump.c), debug builds only,
  [debug-tab.md](../../docs/debug-tab.md)), which writes `/FLASH.BIN` and
  `/DNA.BIN`.

## Why it needs a patch

Stock firmware gives the Game Boy no way to read the flash. The PicoBlaze
reads it at boot, but its only command the kernel can issue erases and
programs. The one store the PicoBlaze writes and the Game Boy can read is
the clock's register file: seven full 8-bit registers, read at
`$7FC0 = 6`, `$A008`-`$A00E`. So the patch sends the flash through the
clock registers, six bytes at a time.

## Protocol

The Game Boy writes the load table through the `$7F36 = 1` window
(`$7FC0 = 2`):

| Entry | Bytes | Value |
|---|---|---|
| 0 | `$A000`-`$A003` | `00 FF 07`, then the mode: `'R'` read, `'D'` DNA |
| 1 to `$40` | `$A004`-`$A103` | `$FF` |
| `$41` | `$A104`-`$A107` | the read's start address |
| `$42` | `$A108`-`$A10B` | the chunk count (bits 23:0) and the first sequence number (bits 31:24) |

Then `$7FC0 = 6`, `$7FB0 = 0`, and `$7FD2 = 1`, from WRAM.

The patch sends 6 bytes a chunk in registers 2 to 7 (`$A008`-`$A00D`) and a
sequence number last, in register 8 (`$A00E`). It waits for the Game Boy to
echo the number into `$7FB0` before the next chunk. The number wraps from
`$FF` to 1, and the Game Boy picks a first number one above what `$A00E`
reads beforehand, so a stale value is never taken for a chunk. DNA mode
sends two chunks: DNA bytes 0 to 5, then 6, 7 and the letters `EZDN`.

### Safe on stock firmware

On unpatched firmware the same command is a stock flash update at
`$07FF00` with `$FF` data: no erase, since the address is not on a sector
boundary, and a page program that clears no bits. The dump always sends the
DNA command first and stops unless `EZDN` comes back.

Stock then refuses ROM loads until power-off, as after any flash update.

### Why the loop runs from WRAM

`$7FD2 = 1` hands two of the game store's address pins to the flash's clock
and data, so the kernel cannot be fetched until it is cleared. The loop
(`flash_stub`, at `$D780`) sets `$7FD2 = 1`, collects the chunks, clears
it, and times out after about 0.9 s without a chunk.

### Writing a clock register takes two writes

A value written to the PicoBlaze's port `EE` lands in the register that
`ED` points at on the next `OUTPUT`, so the patch writes each value twice.
Found in simulation: the last register written held the previous value.

## The dump

DNA first (`/DNA.BIN`, 8 bytes), then 1,024 read commands of one 512-byte
sector each, written to `/FLASH.BIN`. The screen ends with one of:

| Screen | Means |
|---|---|
| `OK 1024 SECT` and the DNA | done |
| `NO PATCH` | the firmware is stock |
| `TIMEOUT` | a chunk did not arrive. Power-cycle: the PicoBlaze may still be waiting |
| `SD ERR nn` | a card write failed |

What a dump contains:

| Range | Contents |
|---|---|
| `$00000` | slot A, the same on both carts examined |
| `$30000`-`$31FFF` | the license block, different on every cart |
| `$40000` | slot B |
| `$70000` | the boot tally |

## The license check

With a dump and its DNA the PicoBlaze's license check can be reproduced.
It reads a record from the license block, takes an expected CRC-7 from
byte 10 and an expected CRC-16 from bytes 20 and 21, and computes:

- CRC-16 (initial value `$FFFF`, reflected polynomial `$A001`) over record
  bytes 0 to 19 followed by the DNA, last byte first
- CRC-7 (the SD card CRC) over record bytes 0 to 9 followed by the DNA,
  last byte first

So the binding of a cart to its FPGA is two CRCs over a few record bytes
and the DNA, not a signature.

## Building it

`stage0/tools/build-stage1-updater.sh` applies the patch together with
stage1 ([setup.md](setup.md)). On its own:

```bash
stage0/tools/picoblaze-patch.py <bram dir>/D0X3Y25.BEL.BRAM \
    stage0/flash-read.psm blobs --tile D0X3Y25 --allow 1B7 > sets.txt
```

The PicoBlaze's second program is in tile `X3Y25` on FW4 and `X3Y5` on
FW5-0918, and is the same in both. `scripts/make-debug-build.py <version>`
builds the kernel with the debug screen.

In simulation the patched firmware returned 300 chunks from two addresses
with no byte wrong, and the same Game Boy code on stock firmware issued no
erase.
