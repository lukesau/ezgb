# The cart's PicoBlaze firmware

The FW4 bitstream contains one PicoBlaze (Xilinx KCPSM3) soft processor
running a 2K program held in two block RAMs. It handles everything on the
cart that is sequential rather than fixed logic: the SD card, loading a game
into memory, the RTC, the config flash, and a license check tied to the FPGA's
Device DNA. Decoding background: [bitstream.md](bitstream.md);
tooling: [toolchain.md](toolchain.md).

The annotated listings are generated into
the ignored `fpga/` directory; only the annotation files and the tool are
tracked.

## Reproducing the listings

```bash
scripts/fpga/picoblaze-dis.py fpga/fw4-decode/bram/D0X3Y29.BEL.BRAM \
    -a re/stage0/picoblaze/fw4/X3Y29.notes -o re/stage0/picoblaze/fw4/X3Y29.psm
scripts/fpga/picoblaze-dis.py fpga/fw4-decode/bram/D0X3Y29.BEL.BRAM \
    --check re/stage0/picoblaze/fw4/X3Y29.psm      # -> identical
```

Same for `X3Y25`. The BRAM files come from `s3decode --blob-dir`.

`picoblaze-dis.py` traces control flow from the reset ($000) and interrupt
($3FF) vectors plus any `entry` in the notes, labels every target, names
ports, scratchpad bytes and routines from the notes file, and emits KCPSM3
`.psm` syntax. Unreached words are kept as commented `DATA_WORD`s. `--check`
reassembles a listing with a built-in assembler and compares every word, so
the annotated listing is provably lossless. `--summary` prints port,
scratchpad and call usage. The notes format is in the script's docstring.

Both listings reassemble identically. Every routine is named.

## Two banks, one processor

| BRAM | Bank | Role |
|---|---|---|
| X3Y29 | 1 (boots here) | SD card, game loader, RTC, kernel command dispatch |
| X3Y25 | 2 | config flash, Device DNA, license check, boot tally, flash update |

Port `C8` switches which BRAM the processor fetches from. Both banks carry the
same eight words at `$3F0`:

```
3F0  LOAD s0, 01
3F1  OUTPUT s0, C8        ; switch to bank 2
3F2  LOAD s0, s0          ; no-op: already fetched from bank 1
3F3  (bank 1: no-op)  (bank 2: CALL $1B5)
3F4  LOAD s0, 00
3F5  OUTPUT s0, C8        ; back to bank 1
3F6  LOAD s0, s0
3F7  RETURN
```

So a `CALL $3F0` in bank 1 runs bank 2's `$1B5` and comes back. The no-ops
cover the one-instruction fetch delay. Evidence beyond the shared window:
both banks use the same ports and the same scratchpad bytes (each reads values
the other writes), bank 2's own reset path is a dead delay loop, and bank 2's
interrupt vector is a stub, because the processor only ever resets in bank 1
and only enters bank 2 with interrupts off.

## Bank 1 (X3Y29): SD, loader, RTC

### SD card

The SD interface is an IP core whose register map and command word match the
OpenCores SD card controller (`sdc_controller`). The PicoBlaze reaches it
through a small bridge: ports `70-73` carry a 32-bit value (`73` = MSB), and
an indirect `OUTPUT sD, (sE)` selects register `sE`, then polls it for an ack.

| Reg | Use |
|---|---|
| `00` | argument (writing it starts the command) |
| `04` | command: `[13:8]` index, `b0` response, `b1` 136-bit, `b2` busy, `b3` CRC, `b4` index check, `b5` read, `b6` write |
| `08` | response |
| `18` / `20` | data / command timeout |
| `1C` | bus width (0 = 1-bit, 1 = 4-bit) |
| `24` | clock divider (`$48` during identification ≈ 400 kHz, implying a ~58 MHz clock; 0 afterwards) |
| `28` | software reset |
| `34` / `38` | command event status / enable |
| `3C` / `40` | data event status / enable |
| `44` | block size − 1 |
| `48` | block count − 1 |
| `60` | DMA address (always 0: the sector buffer) |

Bring-up at reset, in **native SD mode, 4-bit bus** (not SPI mode):
`CMD0`, `CMD8 $1AA`, `CMD55`+`ACMD41` until ready, `CMD2`, `CMD3`, `CMD7`,
`CMD16 512`, `CMD55`+`ACMD6` (4-bit), `CMD13`. High-capacity cards are
sector-addressed; standard ones get the sector number shifted left 9.

Minor bug: `sd_acmd41` sets the HCS bit only for v2 cards, then overwrites
the argument with HCS set anyway (`$085`/`$086`).

### Kernel commands

Commands arrive as interrupts; the handler (`isr`, `$395`) reads port `B5`:

| `B5` | Action |
|---|---|
| `$80` | read `B4` sectors from LBA `B0-B3` into the sector buffer (`CMD18` + `CMD12`) |
| `$40` | write them (`CMD25` + `CMD12`) |
| `$20` | load a ROM from SD into game memory (below) |
| `$10` | set the RTC from port `B6` |
| `$08` | run bank 2 in flash-update mode |

The kernel side ([`DiskRead_B2`/`DiskWrite_B2`](../../kernel/1.05e-0731/disassembly/bank_002.asm))
writes the LBA to `$7FB0-B3` and the count to `$7FB4`, adding `$80` for a
write, in chunks of up to 4 sectors. FPGA logic between the two turns that
into ports `B0-B4` and the `B5` command; the mapping is consistent but not
one-to-one.

### ROM loader (command `$20`)

The kernel fills a 128-entry table of 32-bit words, read through
`TBL_INDEX` (`BF`) and `TBL_Q0-3` (`C3-C0`): entries `$00-$7B` are
(file offset, SD address) pairs, one pair per contiguous run of the file;
`$7C` the length; `$7D` an enable flag; `$7E` the run step. The loader walks
the file run by run: destination offset out on `E0-E3`, file offset turned
into an SD address by scanning the pairs, then `CMD18` for the run and
`CMD12`. Port `EF` is held high for the whole load, which reads like the busy
flag the kernel polls.

**It refuses to load unless bank 2's license check passed** (scratchpad
`$3E`/`$3F` = `F1 F2`, see below).

### RTC

Bit-banged I²C on ports `EC` (out: bit 0 SCL, bit 1 SDA, open drain) and
`EB` (in, with clock stretching) to a **PCF8563** at address `$51`. At reset
it checks the VL bit and, if the clock lost power, stops it and loads a
default date. Whenever port `B9` reads 1 the idle loop copies registers 2-8
(seconds to years) out as index/value pairs on `ED`/`EE`; command `$10`
writes them back from `B6`.

### Debug output

`dbg_putc` waits for `A0` bit 2 to clear and writes a byte to `A1`, which
looks like a UART or a debug FIFO. Codes: `B0` card reset, `82`/`88` card is
high/standard capacity (or timed out), `EE` init done, `55` waiting for data,
`99` + argument per transfer, and at boot the two license bytes.

## Bank 2 (X3Y25): flash, DNA, license

Entered from bank 1 at reset (scratchpad `$3F` = 0) and from command `$08`
(`$3F` = 1).

**Config flash** is bit-banged SPI: `D4` out bit 0 SCK, bit 1 CS_B; `D5`
bit 7 MOSI; `D4` in bit 7 MISO. Commands used: `$03` read, `$06` WREN,
`$05` status (WIP poll), `$02` page program, `$D8` 64 KB sector erase.
`$9F`, `$AB` and `$50` exist only in unreached code.

**Device DNA**: port `D3` drives the Spartan-3A `DNA_PORT` (bit 0 CLK,
bit 1 SHIFT, bit 2 READ) and reads its output bit; 57 bits land in
scratchpad `$0A-$11`. Unreached code at `$029` would print them.

### At boot (`$3F` = 0)

1. **Fail-safe MultiBoot, with a boot tally.** Flash `$070000` holds 256
   tally bytes; bank 2 finds the first one that isn't `00` (erasing the
   sector when all are). What happens next depends on which image is
   running, decided by one constant at `$1B8`:

   | Image | `$1B8` | Behavior |
   |---|---|---|
   | slot A, the fallback image, at flash 0 | `LOAD s0, 01` | if the tally byte is `FF` and `$040000` starts with a sync word, program the byte to `01` and reboot into slot B through ICAP (`AA99`, GENERAL1/2 = `$040000`, `IPROG`); otherwise boot itself (debug `44` if slot B looks invalid) |
   | slot B, active, at `$40000` | `LOAD s0, 02` | never hands over; program the tally byte to `00` |

   Tally byte states: `FF` unused, `01` slot A handed over, `00` slot B
   booted. If slot B fails to come up, the next power-on finds a `01`
   instead of `FF`, skips the hand-over and stays on the fallback image, so a
   bad update can't brick the cart. One byte per power-on: the "52 B at
   `$70000`" in [flash-map.md](flash-map.md) are 52 successful
   slot B boots since the sector was last erased.
2. **License check.** Read the 8 KB block at `$030000` (the flash map's
   "unidentified high-entropy blob") as 128-byte records up to `$031500`,
   each with its own checksum byte. The record at `$031100` also supplies an
   expected CRC-16 (poly `$A001`) and CRC-7 (the SD card CRC). Both are
   recomputed over record bytes with this chip's Device DNA mixed in. A
   match sets `F1` and `F2`; if every record checked out, they are copied to
   `$3E`/`$3F` for bank 1.

So the `$30000` block is a per-chip license record bound to the FPGA's DNA,
and without it bank 1 will not load ROMs. That explains why it is absent from
the updater (it is per-cart, written at the factory) and why it has no twin in
slot B's half of the flash.

### Flash update (`$3F` = 1, kernel command `$08`)

Table entry 0 is a flash address; entries 1-`$40` are 256 bytes of data.
If the address is on a 64 KB boundary the sector is erased first, then the
page is programmed. Port `F1` is high while it runs. This is the write path
behind the updater's `$7FD2` command ([../../../docs/updater-flash-write.md](../../../docs/updater-flash-write.md));
the updater's per-block poll matches waiting on this.

## Slot A vs slot B

The single differing instruction between the two FW4 slots
([bitstream.md](bitstream.md)) is that `$1B8` constant. So the
slots are not a spare copy: slot A is the fallback image whose only extra job
is handing over to slot B, and slot B is what normally runs. The FW4 updater
writes slot B. (Read from code, not tested on hardware.)

This fits [../../../docs/hardware-board.md](../../../docs/hardware-board.md)'s finding from the
2026-08-16 recovery that the FPGA does not fall back to `$40000` on its own:
the hardware always loads address 0, and it is slot A's firmware that hands
over. With slot A's head erased nothing could reach slot B. On a healthy
cart, slot B runs on every boot, via slot A.

Still unexplained: copying slot B wholesale over slot A gave a black screen.
That image would skip the hand-over and run as slot B from address 0, which
on its contents should work.

## Open

- Port `C8` is inferred as a bank select from the code; confirm in the
  netlist. Net tracing exists now (`s3trace`,
  [toolchain.md](toolchain.md#s3trace)); this hasn't been traced yet.
- What drives `B9` (RTC refresh) and reads `ED`/`EE`, `E0-E3`, `EF` on the
  GB side; tie each to its `$7Fxx` register.
- The license check's exact data layout, and whether the record can be
  regenerated for another chip.
- The dead `$1EE-$289` loader in bank 1 (ports `B7`, `E4-E7`, `A2`/`A3`).
- Repeat for the FW5 images. Done for bank 1 and bank 2:
  [fw5.md](fw5.md).
