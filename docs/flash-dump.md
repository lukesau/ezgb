# Dumping the config flash from the Game Boy

Reads the whole 512 KB SPI config flash (EN25F40) and the FPGA's Device DNA
to the SD card, with no desoldering and no JTAG. Two parts:

- **A bank 2 PicoBlaze patch** ([stage0/flash-read.psm](../stage0/flash-read.psm))
  that adds a read mode to the flash-update command. It goes into slot B
  through a relabeled stock updater, like stage1.
- **START on the debug screen** ([kernel/src/flash_dump.c](../kernel/src/flash_dump.c),
  debug builds only, [debug-tab.md](debug-tab.md)) writes `/FLASH.BIN` and
  `/DNA.BIN`.

Status (2026-10-10): works on the FW4 cart (1.04e mod 5.6 debug build):
`OK 1024 SECT`. Its slot B in the dump is byte for byte the image the
updater had just written, and slot A matches the FW5 cart's 2026-08 chip
dump exactly. The license record and DNA pass bank 2's check when it is
run in Python (below).

## Why a patch

Stock firmware gives the Game Boy no way to read the flash. Bank 2 reads it
at boot (tally, license record, slot B check) but its only kernel command,
flash update (`$7FD2=1`, ISR op `$08`), erases and programs. The load table
the Game Boy writes is read-only for the PicoBlaze, the sector buffer is
filled by the SD core's DMA, and the debug and dead-loader ports aren't
decoded. The one PicoBlaze-written store the Game Boy can read is the RTC
register file: ports `ED`/`EE`, read at `$7FC0=6` `$A008-$A00E`, seven
full 8-bit registers (indices 2-8, not masked to BCD).

## Protocol

The Game Boy writes the table through the `$7F36=1` window (`$7FC0=2`):

| Entry | Bytes | Value |
|---|---|---|
| 0 | `$A000-$A003` | `00 FF 07` + mode: `'R'` read, `'D'` DNA |
| 1-`$40` | `$A004-$A103` | `$FF` |
| `$41` | `$A104-$A107` | read start address |
| `$42` | `$A108-$A10B` | chunk count (bits 23:0), first sequence number (bits 31:24) |

then `$7FC0=6`, `$7FB0=0`, and `$7FD2=1` from WRAM. The patch sends 6 bytes
per chunk in registers 2-7 (`$A008-$A00D`) and the sequence number last in
register 8 (`$A00E`); it waits for the Game Boy to echo the number into
`$7FB0` (port `B0`, a plain latch) before the next chunk. The number wraps
`$FF` to 1. The Game Boy picks a first number one above what `$A00E` reads
before the command, so a stale value is never taken for a chunk.
DNA mode sends two chunks: DNA bytes 0-5, then 6, 7 and `EZDN`.

**Stock-safe.** On unpatched firmware the same command is a stock flash
update at `$07FF00` with `$FF` data: no erase (address bits 15:8 aren't 0)
and a page program that clears no bits. Entries `$41`/`$42` are past what
stock reads. The dump always sends the DNA command first and stops unless
`EZDN` comes back. (Stock then refuses ROM loads until power-off, as after
any flash update: it leaves `license_b` = 1. The patch puts back `F2`
when the boot check had passed.)

**Why WRAM.** `$7FD2=1` hands pins P53/P46 (pSRAM A11/A12) to the flash
clock and data, so the kernel in U9 can't be fetched until it's cleared.
The loop (`flash_stub`, 112 bytes at `$D780`) does `$7FD2=1`, collects the
chunks into `$D800`, `$7FD2=0`, and times out after about 0.9 s without a
chunk.

**RTC register file timing.** A value written to `EE` lands in the register
`ED` points at on the *next* `OUTPUT`, so the patch writes each value twice.
Found in simulation: the last register written (the sequence byte) held the
previous value.

After the command the clock registers hold the last chunk until bank 1's
idle loop refreshes them. The command reuses s0-s3 like stock flash update
does, and the interrupted delay loop then runs long, about 0.25 s on the
cart by the counter widths.

## Dump

DNA first (`/DNA.BIN`, 8 bytes, the order bank 2 stores them: `dna0` at
offset 0), then 1024 read commands of 86 chunks (85 of 6 bytes and one of
2: a 512-byte sector), each written with one whole-sector `f_write` to
`/FLASH.BIN`. The screen shows `OK 1024 SECT` and the DNA, or `NO PATCH`,
`TIMEOUT` (power-cycle: the PicoBlaze may still be waiting) or `SD ERR nn`.

## Build

```bash
# bank 2 BRAM with the patch (FW4 tile X3Y25, FW5-0918 X3Y5; same program)
cd fpga/flashread
../../scripts/fpga/picoblaze-patch.py ../fw4-decode/bram/D0X3Y25.BEL.BRAM \
    ../../stage0/flash-read.psm blobs-fw4 --tile D0X3Y25 --allow 1B7 > sets-fw4.txt
../../scripts/fpga/picoblaze-patch.py ../fw5-decode/bram-0918/D0X3Y5.BEL.BRAM \
    ../../stage0/flash-read.psm blobs-fw5 --tile D0X3Y5 --allow 1B7 > sets-fw5.txt
# on the build host: s3patch onto the slot B the cart already runs, then
# decode it and check only that tile changed
s3patch --db $DB base-fw4.bin patched-fw4.bin $(cat sets-fw4.txt)
# back here
scripts/fpga/make-updater.py juniorkernel-1.04e-FW4/Update_FW4.gb \
    fpga/flashread/patched-fw4.bin fpga/load/Update_FW4-flashread.gb --label "Update: fw4 read"
scripts/make-debug-build.py 1.04e        # and 1.05e-0918 for the FW5 cart
```

The bases were the slot B images in `Update_FW4-stage1src-v4.gb` and
`Update_FW5-0918-stage1-fast.gb`: our stage1, stock bank 2. The decoded
patched images differ from them only in the bank 2 BRAM.

## Simulation

FW4 design, `fast/` BRAMs, flash model loaded with the cart dump:

| Run | Result |
|---|---|
| 300 chunks from `$030000` and from `$000000` | 1800 bytes each, none differ, ~36 µs per chunk, sequence wrap crossed |
| DNA, then 300 chunks | `EZDN` back, 1800 bytes, none differ |
| the same Game Boy code on stock firmware | flash commands: `06`, `02` at `$07FF00` (260 bytes of `$FF`), `05`; no erase |

## FW4 cart dump (2026-10-10)

Kept in the ignored `fpga/dumps/` (`fw4cart-flash.bin`, sha1 `9d9ec477a44a`;
`fw4cart-dna.bin`). Against the FW5 cart's original chip dump:

| Range | Contents |
|---|---|
| `$00000-$2480B` | slot A, identical (both carts shipped the same fallback image) |
| `$2480C` | 38 bytes, identical: the tail of the last programmed page |
| `$30000-$31FFF` | license block, different (per chip): 42 records to `$31500`, all checksums good, then data to about `$32000` that the check never reads |
| `$40000-$6480B` | slot B, our patched image |
| `$70000` | boot tally: 228 boots since the sector was erased |

DNA (`dna0`..`dna7`): `56 9F CD DE 7F 23 51 01`.

**The license check, run on this record.** Bank 2 reads the record at
`$031100` into scratchpad `$1E`.., takes the expected CRC-7 from byte 10
and the expected CRC-16 from bytes 20-21, then overwrites part of that copy
with the DNA:

- CRC-16 (init `$FFFF`, reflected poly `$A001`) over record bytes 0-19
  followed by `dna7`..`dna0`: `$CDE0`, matching bytes 20-21.
- CRC-7 (the SD card CRC) over record bytes 0-9 followed by `dna7`..`dna0`:
  `$A5`, matching byte 10.

So the binding is two CRCs over a few record bytes and the DNA, not a
signature.
