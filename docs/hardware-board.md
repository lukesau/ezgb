# EZ Flash Jr board

Silkscreen `EZGB` on the front, `EZFLASH` logo and a `JTAG` header on the back.
Part numbers transcribed from a physical cart under magnification, so treat the
exact strings as approximate; the families are confident.

## Chips

| Ref | Marking | Identification | Confidence | Role |
|---|---|---|---|---|
| U1 | `XILINX SPARTAN XC3S200A VQG100AGQ1240` | Spartan-3A, 200K gates, 100-pin VQFP | High | The FPGA. Everything custom about this cart. |
| — | `25Q40H E20090N` (8-pin SOIC) | 4 Mbit / **512 KB** SPI NOR flash (W25Q40 family) | High | **FPGA configuration storage.** See below — this is the important one. |
| U4 | `Spansion 71GL032A40BFW0B` (BGA) | S71GL032A MCP, 32 Mbit / **4 MB** NOR flash | High | Game ROM storage — where a launched ROM is programmed. |
| U9 | `3350LLZD… Z544I208A` (BGA) | **Unidentified.** Best candidate for the **FRAM**, by elimination — see below. | Low | Save storage. |
| U6, U7 | `LVT162245` ×2 (`P01AD` = lot code, Fairchild) | 74LVT162245, 16-bit bus transceiver, 3.3 V with 5 V-tolerant inputs | High | Cart-edge bus interface. Two × 16 bits ≈ 16 address + 8 data + control. Your "PHY" reading is right. |
| U3 | `8563S 2506 TMS` (8-pin) | PCF8563/BM8563 I²C real-time clock | High | The RTC. Paired with the coin cell; this is what 1.05e's "RTC codes are rewritten" refers to. |
| U2 | `74HC595D` (16-pin) | 8-bit shift register, serial in / parallel out with latch | High | I/O expansion — more signals than the FPGA has spare pins for. |
| Y1 | `24.545 MHz` crystal | — | High | FPGA clock. |
| Y2 | 32.768 kHz (near RTC) | — | Medium | RTC timebase. |
| — | Tactile button, centre of board | — | — | Inaccessible with the shell closed, so factory/recovery use. Purpose unverified. |
| — | `JTAG` header, back edge, 8 pads | — | High | Xilinx JTAG chain — FPGA and/or config flash. |

## Where the FRAM is — and why the `$A000` window is probably two devices

The Jr's saves are non-volatile without a battery (the coin cell backs only the
RTC), so a real FRAM exists. Every other part on the board is accounted for, so
the unidentified BGA (U9) is the candidate by elimination. But it is probably
*not* the whole story behind the `$A000` cart-RAM window:

- The file-list cache needs ~2 MB. EZ Flash's own changelog states a maximum of
  7000 files; at the 255-byte entry stride that is ~1.78 MB. Independently, the
  page-latch arithmetic (`$12 + (idx>>5)`, overflowing at 7,616 entries) gives
  238 pages × 8 KB ≈ 1.95 MB. Two derivations, same ~2 MB.
- FRAM at that density would be an expensive part for a cart at this price.
- U4 is an **MCP**: the Spansion `S71` prefix denotes a multi-chip package,
  typically GL-series NOR stacked with PSRAM. `71GL032A` plausibly carries 4 MB
  NOR **plus** ~2 MB PSRAM — which would cover both the game ROM and the file
  cache.

Behavioural evidence for the file cache being **volatile**: the kernel never
trusts it. `FileBrowserEntry` zeroes `$c2a2/$c2a3` and re-runs `Opendir_B5` +
`DirList` from scratch on every entry to the browser, and no code path reads
those pages without having just written them. That is the correct behaviour for
PSRAM that is garbage after a power cycle, and wasteful behaviour for
non-volatile storage.

So the working model is: **page `$11` (BACKUPSAVE meta, last-ROM path) in FRAM;
pages `$12`+ (file list) in PSRAM** — one `$A000` window, two backing stores,
selected by the page latch. This supersedes an earlier note claiming the
file-list pages "survive power-off (it's FRAM)".

All of the above is inference from part families, capacity arithmetic and
kernel behaviour — not measurement. To settle it: read U9's marking under
better magnification (a manufacturer logo would probably decide it), and
confirm the split functionally by checking whether data written to a page
`$12`+ survives a power cycle while page `$11` does.

## Why the config flash matters

The Spartan-3A is **SRAM-based**. It has no internal configuration memory, so
at every power-on it loads its bitstream from external flash — the `25Q40H`.
Three consequences:

1. **The FPGA image is in a commodity, fully documented part.** SPI NOR with a
   standard command set, in a SOIC-8 package a test clip fits. It can be read
   and written with a ~$5 CH341A-class programmer, independent of the cart's
   own update path.

2. **It can be backed up.** A full 512 KB dump taken before any modification is
   a complete restore image. This is what turns FPGA work from "brick risk" into
   "recoverable" — provided the backup is taken *first* and verified.

3. **Sizes suggest the bootstrap lives there, separate from the bitstream.** An
   XC3S200A bitstream is ~1,196,128 bits ≈ **146 KB**. The flash is 512 KB, so
   ~366 KB is unaccounted for. The updater payload is ~305 KB — roughly two
   bitstreams' worth, or a bitstream plus other data.

## What we know about the bootstrap ROM

The factory bootstrap is the GB-visible program that shows `EZ-FLASH` /
`LOADING...`, reads `ezgb.dat` from the SD root, and runs it (see
`ezgb-dat-boot.md`). **Its header is what the console's boot ROM reads at
power-on**, which is why the CGB flag in `ezgb.dat` has no effect
(`cgb-mode.md`).

It is **not** present in either firmware updater. Searched both
`Update_FW5_7-31.gb` and `Update_FW4.gb` for the Nintendo logo, `ezgb.dat`,
`LOADING` and `not found`, under five encodings — plain, bit-reversed,
inverted, nibble-swapped, and bit-reversed+inverted. The only hit in either
file is each updater's own header logo at `$0104`.

So the bootstrap is either:

- **(a)** factory-programmed into a region of the `25Q40H` that firmware
  updates never rewrite — in which case its header bytes are plain data and
  changing the CGB flag is a byte patch plus a checksum, or
- **(b)** embedded in the bitstream as block-RAM initialisation, scattered
  through the configuration bit ordering — in which case patching it means
  bitstream-format reverse engineering for Spartan-3A, which is a research
  project, not a task. (The XC3S200A has ~16 × 18 Kbit block RAM ≈ 36 KB, so a
  32 KB bootstrap ROM would fit, making this entirely plausible.)

**Dumping the `25Q40H` distinguishes (a) from (b) definitively, and reading is
completely non-destructive.** If the Nintendo logo and the `ezgb.dat not found`
strings appear in the dump as plain data, it is (a) and the path is short.

## Suggested experiment order (all non-destructive)

1. **Dump the `25Q40H` from both carts.** Read-only, no writes, no risk.
   Verify each dump by reading twice and comparing.
2. **Search the dumps** for the Nintendo logo and the bootstrap strings. This
   answers (a) vs (b).
3. **Diff the two carts' dumps.** If the carts are on different firmware
   versions, the diff shows exactly which region the updater rewrites — and by
   elimination, which region is factory-static. That identifies where the
   bootstrap lives without any bitstream knowledge.
4. Only after all of that, and only with verified backups, consider writing.

Nothing above requires the FPGA's bitstream format, a custom updater, or the
JTAG header. Note also that the ROM-space unlock/commit protocol the kernel and
updater both use (`docs/REGISTERS.md`) is a *separate* interface from SPI
configuration — reverse engineering the updater teaches you the delivery
mechanism, not how to author the payload.


## Recovering a cart whose FPGA no longer configures

**Confirmed working, 2026-08-16.** A cart bricked by an aborted FPGA command
(see the warning in `game-slot-access.md`) was fully restored by reprogramming
the config flash. No second cart and no vendor image were needed — the flash
carries a spare copy of the bitstream that the repair is built from.

### Symptom

Blacked-out / garbled Nintendo logo at power-on, on every console, with or
without an SD card. The Spartan-3A is SRAM-based and reloads its bitstream from
the config flash at power-on; with that image gone the FPGA never configures,
the cart drives nothing, and the boot ROM halts on a logo it cannot verify.

### The chip

Silkscreened `25Q40H`, but the JEDEC ID reads **`1C 31 13`** = **EON
EN25F40**, 4 Mbit / 512 KB. Manufacturer `1C` is EON, not Winbond (`EF`), and
type byte `31` is the F series (`30` would be Q). Select `EN25F40` in the
programmer; `W25Q40*` and `EN25Q40` both fail the ID check. For *reads* the ID
check can simply be disabled — `03h` is universal.

Desoldering the SOIC-8 and reading it in a socket avoids in-circuit bus
contention with the FPGA entirely, and on an already-dead cart costs nothing.

### Flash layout (512 KB)

| Range | Contents |
|---|---|
| `0x00000-0x24831` | **image A** — the one the FPGA actually boots. Sync `AA 99 30 A1` at `0x00046` |
| `0x30000-0x31FFF` | 8 KB, entropy 7.80, absent from the firmware updater. Unidentified |
| `0x40000-0x64831` | **image B** — a second, near-identical bitstream. Sync at `0x40046` |
| everything else | erased (`FF`) |

Each image is `0x24832` bytes including its `FF` preamble; the bitstream proper
starts 0x46 in. Length ~149,484 bytes matches the XC3S200A's ~146 KB bitstream.
`Update_FW5_7-31.gb`'s payload at file offset `0x8020` is byte-identical to the
flash at `0x40046` for its first 224 bytes, confirming the updater writes this
same bitstream.

**Images A and B differ in only 8 bytes, all of them in the tail** (offsets
`+0x09872`, `+0x147e9..eb`, `+0x1480b..0d` relative to `0x10000`/`0x50000`).
The two 3-byte clusters sit at the very end and behave like CRCs.

### The repair

The failure erased `0x00000-0x0FFFF` — image A's first 64 KB — leaving its tail
at `0x10000-0x24831` intact. So:

```python
flash[0x00000:0x10000] = flash[0x40000:0x50000]   # image B's head
# everything else, including image A's own tail, left untouched
```

Program the whole 512 KB, **FLASH region only — leave STATUS/CFG unchecked**
(that is where the block-protect bits live), then verify, then resolder.

### Do not copy image B wholesale into slot A

Tried first, and it does **not** boot. Writing all `0x24832` bytes of image B
over `0x00000-0x24831` yields a black screen exactly as before. Only filling the
erased 64 KB and preserving image A's original tail works.

That is the useful detail: the images' heads are interchangeable but their tails
are not, so the repair must be minimal. It also proves the FPGA boots from
address 0 and does *not* silently fall back to `0x40000` — image B sat intact
throughout and never got used.

### What this rules out

No Nintendo logo and no `ezgb.dat` / `LOADING` / `EZ-FLASH` strings appear
anywhere in the flash, under plain, bit-reversed or inverted encodings. So the
factory bootstrap ROM is **not** stored as plain data here — it is inside the
bitstream as block-RAM initialisation. That settles the (a)/(b) question above
in favour of **(b)**, and means patching the bootstrap's CGB flag would require
Spartan-3A bitstream reverse engineering. The one region unaccounted for is the
8 KB at `0x30000`, whose entropy (7.80) suggests compressed or encrypted data.


## The bootstrap ROM is not in the config flash — searched and ruled out

Having a full 512 KB dump, the bootstrap was hunted for directly. Every attempt
failed, and the negatives are worth recording so nobody repeats them.

Known plaintext available: the 48-byte Nintendo logo (fixed), plus `LOADING`,
`ezgb.dat`, `www.ezflash.cn`.

| Method | Result |
|---|---|
| Byte search, plain / bit-reversed / inverted / nibble-swapped | nothing |
| Statistical scan for BRAM-like frames | two dense regions at bitstream `+0x21400` (bit density 0.586) and `+0x1cc00` (0.520) against a 0.183 baseline — plausible, but see below |
| Logo under constant-stride bit interleaving — 302 strides (1-256 plus powers of two to 4096), both bit orders, inverted — across the whole bitstream, the dense tail, the 8 KB block, and all 512 KB | **nothing** |
| 8 KB block at `0x30000`: container headers, single-byte XOR, stride search | nothing. All 256 byte values present, entropy 7.799, not a copy of any bitstream region |

So the bootstrap is not stored here as plain data, and if it is BRAM
initialisation inside the bitstream, the interleaving is not a constant stride —
which would put it back into genuine bitstream-format reverse engineering.

**More likely: it lives in the Spansion NOR (U4), not the config flash.** The
FPGA configures from the SPI flash and could then serve the bootstrap from a
reserved region of the 4 MB NOR. That is consistent with the firmware updater
containing no trace of it (updates rewrite only the bitstream) and with 512 KB
of config flash showing nothing under any encoding.

Testing that needs either a BGA dump or driving the FPGA's NOR-read path over
`$7Fxx` — the latter being the interface that bricked a cart on 2026-08-16.
Not recommended.

**Consequence for CGB mode:** the "patch the bootstrap's CGB flag" shortcut is
dead. The remaining route is a replacement FPGA design (`fpga-ace.md`), which
would serve its own bootstrap from BRAM with whatever ROM header it likes —
making the flag a design choice rather than something to patch.
