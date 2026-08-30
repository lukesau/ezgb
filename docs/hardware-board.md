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
| U9 | `3350LLZDQD` / `Z544I208A`, lowercase-`i` logo (BGA) | **PSRAM** — community teardowns identify this part. NOT FRAM. | Medium | Save + file-list storage, kept alive by the coin cell |
| U6, U7 | `LVT162245` ×2 (`P01AD` = lot code, Fairchild) | 74LVT162245, 16-bit bus transceiver, 3.3 V with 5 V-tolerant inputs | High | Cart-edge bus interface. Two × 16 bits ≈ 16 address + 8 data + control. Your "PHY" reading is right. |
| U3 | `8563S 2506 TMS` (8-pin) | PCF8563/BM8563 I²C real-time clock | High | The RTC. Paired with the coin cell; this is what 1.05e's "RTC codes are rewritten" refers to. |
| U2 | `74HC595D` (16-pin) | 8-bit shift register, serial in / parallel out with latch | High | I/O expansion — more signals than the FPGA has spare pins for. |
| Y1 | `24.545 MHz` crystal | — | High | FPGA clock. |
| Y2 | 32.768 kHz (near RTC) | — | Medium | RTC timebase. |
| — | Tactile button, centre of board | — | — | Inaccessible with the shell closed, so factory/recovery use. Purpose unverified. |
| — | `JTAG` header, back edge, 8 pads | — | High | Xilinx JTAG chain — FPGA and/or config flash. |

## There is no FRAM on this board — saves are battery-backed PSRAM

**This corrects an error that propagated through several docs in this repo.**
The Jr was believed to use FRAM, with the coin cell backing only the RTC. That
is the **Omega DE**, not the Junior.

U9 is `3350LLZDQD` — identified as **PSRAM** in community teardowns. The
coin cell backs **both the RTC and the save memory**, which is why "my EZ Flash
Jr battery dies in a month" is a recurring complaint: PSRAM draws far more
standby current than FRAM. Reported cell life runs roughly 1-8 months depending
on which memory variant a unit shipped with, against 10+ years for an original
battery-backed cartridge. Some owners swap the cell for a CR2032 or replace the
memory part outright.

Consequences for everything else in these notes:

- Saves and the `$A300` last-ROM metadata are **volatile if the coin cell
  dies**. They are not intrinsically non-volatile.
- The BACKUPSAVE `$AA` stamp at page `$11` surviving a power cycle proves the
  battery is doing its job, not that the storage is non-volatile.
- The earlier "page `$11` in FRAM, pages `$12`+ in PSRAM — one window, two
  backing stores" model is unsupported. One battery-backed memory covering both
  is simpler and fits the evidence.
- The argument that the kernel re-enumerates the file list "because PSRAM is
  volatile" was weak reasoning even if the conclusion is harmless: with the cell
  fitted the cache would survive, and re-enumerating is simply correct behaviour
  because the SD card may have changed.

Capacity still checks out against the `$12 + (idx>>5)` page arithmetic (~2 MB;
EZ Flash's changelog states a 7000-file maximum). Community teardowns also
describe the Spansion `71GL032A` MCP as 32 Mbit flash for ROMs plus additional
memory, so exact partitioning between U4 and U9 is not settled.

Sources: beyondconsoles EZ-Flash Junior review; GBAtemp battery-drain threads.

## JTAG header — FPGA package pins

The 8-pad `JTAG` header on the back edge goes to the XC3S200A's dedicated JTAG
and configuration pins. From the VQ100 footprint (DS529, `tools/`), the pins to
identify a buzzed pad against are:

| Signal | VQ100 pin | Notes |
|---|---|---|
| **TMS** | 1 | dedicated JTAG |
| **TDI** | 2 | dedicated JTAG |
| **TDO** | 75 | dedicated JTAG — the only JTAG **output** (drives when powered) |
| **TCK** | 76 | dedicated JTAG |
| PROG_B | 100 | config; pulse low to reconfigure |
| DONE | 54 | config; high when configured |
| INIT_B | 48 | config/status |
| VCCAUX | 22, 55, 92 | JTAG reference supply; dual-range **2.5 V or 3.3 V** (board picks one) |
| GND | 8,14,18,35,42,58,63,69,74,80,87,91,95 | many |

### Confirmed pad order (buzzed out 2026-08-19)

Left → right, pad 1 nearest the `JTAG` silkscreen. Verified by continuity from
each pad to the FPGA package pin:

| Pad | Signal | VQ100 pin |
|---|---|---|
| 1 | **TDO** | 75 |
| 2 | **TCK** | 76 |
| 3 | **TMS** | 1 |
| 4 | **TDI** | 2 |
| 5 | **GND** | — |
| 6 | **VCC / VREF** | power rail (see below) |
| 7 | **VCC / VREF** | power rail (see below) |
| 8 | **GND** | — |

This is a JTAG-only header — all four TAP signals plus two GND and two VCC.
**No pad connects to PROG_B (pin 100) — confirmed by direct continuity check**;
DONE/INIT_B are likewise not broken out. None are needed: JTAG can reconfigure
via `JPROGRAM`. Pad 1 was briefly mislabelled PROG_B before the package
orientation was corrected; it is TDO (pin 75), and PROG_B is absent entirely.

**Pads 6 and 7 cannot be told apart by continuity.** On an unpowered board every
supply rail (VCCINT 1.2 V, VCCAUX, VCCO 3.3 V) reads continuous to every other
through the decoupling caps and internal paths — pads 6, 7 and all VCC rails beep
together, which is expected and uninformative. Resolve it **under power**:
backprobe pads 6/7 in DC-volts (GND on pad 5) and use whichever reads **~2.5–3.3 V**
as the cable's VREF; avoid a **1.2 V** reading (that is VCCINT). A VREF-sensing
cable (Digilent HS2) then adapts to that level.

The minimum to configure over JTAG is TDO/TCK/TMS/TDI + GND + a ~3.3 V VREF pad —
which this header fully provides.

**The separate 3-pad group** (left of the JTAG header) showed **no continuity to
the FPGA** — so those are not FPGA pins. Most likely the `EN25F40` SPI config
flash lines (in-system reflash without clamshelling); buzz them to the flash chip
and to config pins 51/52/53 (CCLK/DIN/DOUT-MISO) to confirm.

### HS2 wiring

All same-name, straight through (no TDI/TDO crossover):

```
HS2 TCK  → pad 2      HS2 TDI → pad 4      HS2 GND  → pad 5 or 8
HS2 TMS  → pad 3      HS2 TDO → pad 1      HS2 VREF → pad 6 or 7 (the ~3.3 V one)
```

The exact JTAG **IDCODE** is not in this datasheet's extracted text; the
XC3S200A value follows the Spartan-3A pattern `0x0221x093` (expected
`0x02218093`). It does not need to be memorised — `xc3sprog`/iMPACT enumerate the
chain and name the device, which is the step-1 success check.

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

**Update (from the FW4 flash dump we hold — see
[fpga-flash-map.md](fpga-flash-map.md)):** the evidence now leans toward (b).
The 512 KB image contains only two FPGA bitstream slots plus one 8 KB
high-entropy blob at `$30000` (entropy 7.80, no logo under any encoding, no
strings, not GB code, absent from `ezgb.dat`). There is **no plaintext bootstrap
ROM anywhere in the flash** — no Nintendo logo, no `ezgb.dat`/`LOADING` strings
in any slot. So hypothesis (a) has no supporting evidence in the actual dump,
and the bootstrap is most likely embedded in the bitstream (b). Confirming it
still requires the bitstream format, but the "separate plaintext ROM" idea can
be set aside.

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
