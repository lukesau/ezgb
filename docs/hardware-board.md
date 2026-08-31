# EZ Flash Jr board

Silkscreen `EZGB` on the front, `EZFLASH` logo and a `JTAG` header on the back.
Part numbers transcribed from a physical cart under magnification, so treat the
exact strings as approximate; the families are confident.

## Chips

| Ref | Marking | Identification | Confidence | Role |
|---|---|---|---|---|
| U1 | `XILINX SPARTAN XC3S200A VQG100AGQ1240` | Spartan-3A, 200K gates, 100-pin VQFP | High | The FPGA. Everything custom about this cart. |
| - | `25Q40H E20090N` (8-pin SOIC) | 4 Mbit / **512 KB** SPI NOR flash (W25Q40 family) | High | **FPGA configuration storage** (see below). |
| U4 | `Spansion 71GL032A40BFW0B` (BGA) | **S71GL032A40 MCP** (datasheet, `tools/S71GL032A.PDF`): a stacked package of **one S29PL032A = 4 MB NOR flash die + a 512 KB (4 Mbit) pSRAM die** | High | Its **512 KB pSRAM die = the battery-backed save/settings store** (exact size match to the 64-page / 512 KB map — [psram-page-map.md](psram-page-map.md)). Its 4 MB NOR die: **no GB-side use found** (see below). |
| U9 | `3350LLZDQ0` (lowercase-`i`/Numonyx logo), 88-ball FBGA | **Numonyx RD38F3350LLZDQ0** — StrataFlash Wireless (L18/L30) SCSP MCP, datasheet-confirmed (`tools/RD38F3350-StrataFlash-Wireless-L18-L30.pdf`, Table 28): **two 128 Mbit L30 NOR dies (256 Mbit = 32 MB NOR) + one 64 Mbit (8 MB) pSRAM die**, on a shared x16 NOR+pSRAM bus (QUAD+ ballout `Q`). | High | Its **8 MB pSRAM die = the volatile game-ROM store** (holds the loaded ROM, exactly the 64 Mbit GB max; hardware-proven volatile — fades toward `$FF` off-power, [nor-reuse.md](nor-reuse.md)). Its **32 MB NOR: no GB-side use found**, but it shares U9's bus with the game pSRAM so it is very likely wired to the FPGA. |
| U6, U7 | `LVT162245` ×2 (`P01AD` = lot code, Fairchild) | 74LVT162245, 16-bit bus transceiver, 3.3 V with 5 V-tolerant inputs | High | Cart-edge bus interface (PHY). Two × 16 bits ≈ 16 address + 8 data + control. |
| U3 | `8563S 2506 TMS` (8-pin) | PCF8563/BM8563 I²C real-time clock | High | The RTC. Paired with the coin cell; this is what 1.05e's "RTC codes are rewritten" refers to. |
| U2 | `74HC595D` (16-pin) | 8-bit shift register, serial in / parallel out with latch | High | I/O expansion: more signals than the FPGA has spare pins for. |
| Y1 | `24.545 MHz` crystal | - | High | FPGA clock. |
| Y2 | 32.768 kHz (near RTC) | - | Medium | RTC timebase. |
| - | Tactile button, centre of board | - | High | Reset button; reboots the cart. Sits right against the shell, so a light press on the plastic over it triggers a reset without opening the case. |
| - | `JTAG` header, back edge, 8 pads | - | High | Xilinx JTAG chain (FPGA and/or config flash). |

## The two big memory chips (U4, U9) — memory map

The confusion ("is U4 the ROM chip? is U9 SRAM or PSRAM?") is settled by two
things we can actually stand behind: **U4's datasheet** and **our own
measurements**. (A GBAtemp thread raised the question and floated some IDs, but
it is not treated here as authoritative.)

U4's datasheet (`tools/S71GL032A.PDF`, p.3) is the firm anchor: the
`S71GL032A` is **not** a single part but a **stacked MCP** — "one S29PL032A
Flash memory die + pSRAM." So U4 alone contains both **4 MB NOR** and **512 KB
pSRAM**. That one fact forces the rest by deduction: an 8 MB game ROM cannot
live in U4's 512 KB pSRAM, so the game store must be a *different* chip (U9),
and it must hold ≥ 8 MB of pSRAM — no external part number needed to conclude
that.

What is **proven by our own measurements** (independent of any part number):

| Store | Where | Size | Volatile? | Evidence |
|---|---|---|---|---|
| **Game ROM** (loaded game) | U9's pSRAM | **~8 MB** (64 Mbit) | Volatile, fades off-power | [nor-reuse.md](nor-reuse.md); loads 64 Mbit ROMs = GB max |
| **Saves + settings** | U4's pSRAM die | **512 KB** (4 Mbit) | Battery-backed (coin cell) | [psram-page-map.md](psram-page-map.md); 512 KB = 64 pages exactly |
| **FPGA bitstream** (+ stage1 as BRAM) | SPI flash (`25Q40H`, board revs vary) | 512 KB–2 MB | Nonvolatile | [fpga-flash-map.md](fpga-flash-map.md), [updater-flash-write.md](updater-flash-write.md) |
| **NOR die of U4** | S29PL032A (datasheet-confirmed) | 4 MB | Nonvolatile | **no GB-side use found** |

The size coincidences pin the pSRAM assignments hard: the game store loads
64 Mbit ROMs (= 8 MB pSRAM in U9); the save store is exactly 512 KB / 64 pages
(= U4's datasheet-confirmed 4 Mbit pSRAM die). So EZ-Flash appears to have
chosen these parts **for their pSRAM** (8 MB fast RAM for the ROM, 512 KB
battery-backed RAM for saves).

**What is *not* confirmed:** U9's exact identity and full contents. Its marking
`3350LLZDQ0` (lowercase-`i`/Intel-era logo) is undocumented — no datasheet turns
up for it (web search + the forum's own links are dead), and the forum's
`RD38F3350` guess can't be verified, so it is **not** asserted here. We know only
that U9 holds ≥ 8 MB pSRAM (by deduction above). Whether it *also* carries a NOR
die is speculative. What is certain is only U4's 4 MB NOR, and that **no
GB-visible firmware path reaches any NOR die**: the `$7FC0` sweep finds no
personality that maps NOR
([fpga-personalities.md](fpga-personalities.md)) and the updater writes only the
SPI config flash ([updater-flash-write.md](updater-flash-write.md)). Whether the
NOR is even wired to the FPGA is unknown; it may be dead silicon in the package.

The coin cell backs **the RTC and U4's 512 KB save pSRAM**. pSRAM draws far more
standby current than FRAM, so cell life runs ~1–8 months vs 10+ years for an
original battery-backed cart — the recurring "battery dies in a month"
complaint. Saves and the `$A300` last-ROM record are lost when the cell dies.

Sources: `tools/S71GL032A.PDF` (U4 datasheet — the one firm reference); GBAtemp
"how does EZ Flash Junior work" thread (U9 discussion, unverified); our own
measurements ([nor-reuse.md](nor-reuse.md), [psram-page-map.md](psram-page-map.md)).

## JTAG header: FPGA package pins

The 8-pad `JTAG` header on the back edge goes to the XC3S200A's dedicated JTAG
and configuration pins. From the VQ100 footprint (DS529, `tools/`), the pins to
identify a buzzed pad against are:

| Signal | VQ100 pin | Notes |
|---|---|---|
| **TMS** | 1 | dedicated JTAG |
| **TDI** | 2 | dedicated JTAG |
| **TDO** | 75 | dedicated JTAG; the only JTAG **output** (drives when powered) |
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
| 5 | **GND** | - |
| 6 | **VCC / VREF** | power rail (see below) |
| 7 | **VCC / VREF** | power rail (see below) |
| 8 | **GND** | - |

This is a JTAG-only header: all four TAP signals plus two GND and two VCC.
**No pad connects to PROG_B (pin 100), confirmed by direct continuity check**;
DONE/INIT_B are likewise not broken out. None are needed: JTAG can reconfigure
via `JPROGRAM`. Pad 1 is TDO (pin 75), not PROG_B.

**Pads 6 and 7 cannot be told apart by continuity.** On an unpowered board every
supply rail (VCCINT 1.2 V, VCCAUX, VCCO 3.3 V) reads continuous to every other
through the decoupling caps, so all VCC rails beep together. Resolve it **under
power**: backprobe pads 6/7 in DC-volts (GND on pad 5) and use whichever reads
**~2.5–3.3 V** as the cable's VREF; avoid a **1.2 V** reading (that is VCCINT). A
VREF-sensing cable (Digilent HS2) then adapts to that level.

The minimum to configure over JTAG is TDO/TCK/TMS/TDI + GND + a ~3.3 V VREF pad,
which this header fully provides.

**The separate 3-pad group** (left of the JTAG header) showed **no continuity to
the FPGA**, so those are not FPGA pins. Most likely the `EN25F40` SPI config
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
`0x02218093`). It does not need to be memorised: `xc3sprog`/iMPACT enumerate the
chain and name the device, the step-1 success check.

## Why the config flash matters

The Spartan-3A is **SRAM-based** with no internal configuration memory, so at
every power-on it loads its bitstream from the `25Q40H`/EN25F40 SPI flash. Three
consequences:

1. **The FPGA image is in a commodity, fully documented part.** SPI NOR with a
   standard command set, SOIC-8 package a test clip fits, readable/writable with
   a ~$5 CH341A-class programmer independent of the cart's own update path.
2. **It can be backed up.** A full 512 KB dump taken (and verified) before any
   modification is a complete restore image, turning FPGA work from brick risk
   into recoverable.
3. **Sizes suggest the bootstrap lives there, separate from the bitstream.** An
   XC3S200A bitstream is ~1,196,128 bits ≈ **146 KB**; the flash is 512 KB, so
   ~366 KB is unaccounted for. The updater payload is ~305 KB, roughly two
   bitstreams' worth.

## The bootstrap ROM

The factory bootstrap is the GB-visible program that shows `EZ-FLASH` /
`LOADING...`, reads `ezgb.dat` from the SD root, and runs it (see
`ezgb-dat-boot.md`). **Its header is what the console's boot ROM reads at
power-on**, which is why the CGB flag in `ezgb.dat` has no effect (`cgb-mode.md`).

Two possibilities:

- **(a)** factory-programmed into a region of the config flash that firmware
  updates never rewrite: header bytes plain data, CGB flag a byte patch + checksum.
- **(b)** embedded in the bitstream as block-RAM initialisation; patching it
  means Spartan-3A bitstream-format reverse engineering. The XC3S200A has
  ~16 × 18 Kbit block RAM ≈ 36 KB, so a 32 KB bootstrap ROM would fit.

**The bootstrap is not present in either firmware updater** (`Update_FW5_7-31.gb`,
`Update_FW4.gb`), searched for the Nintendo logo, `ezgb.dat`, `LOADING`, `not
found` under five encodings (plain, bit-reversed, inverted, nibble-swapped,
rev+inv); the only hit is each updater's own header logo at `$0104`. The full
512 KB flash dump likewise contains no plaintext bootstrap (see
[fpga-flash-map.md](fpga-flash-map.md) for its contents). This leaves **(b)** as
the best-supported answer; confirming it needs the bitstream format. See the
search detail and the alternative NOR hypothesis below.

Note: the ROM-space unlock/commit protocol the kernel and updater share
([REGISTERS.md](REGISTERS.md)) is a *separate* interface from SPI configuration:
reverse engineering the updater teaches the delivery mechanism, not how to author
the payload.

## Recovering a cart whose FPGA no longer configures

**Confirmed working, 2026-08-16.** A cart bricked by an aborted FPGA command
(see the warning in `game-slot-access.md`) was fully restored by reprogramming
the config flash. No second cart and no vendor image were needed: the flash
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
check can simply be disabled; `03h` is universal.

Desoldering the SOIC-8 and reading it in a socket avoids in-circuit bus
contention with the FPGA entirely, and on an already-dead cart costs nothing.

### Flash layout (512 KB)

Repair-critical view; full layout owned by [fpga-flash-map.md](fpga-flash-map.md).

| Range | Contents |
|---|---|
| `0x00000-0x24831` | **image A**, the one the FPGA actually boots. Sync `AA 99 30 A1` at `0x00046` |
| `0x30000-0x31FFF` | 8 KB, entropy 7.80, absent from the firmware updater. Unidentified |
| `0x40000-0x64831` | **image B**, a second near-identical bitstream. Sync at `0x40046` |
| everything else | erased (`FF`) |

Each image is `0x24832` bytes including its `FF` preamble; the bitstream proper
starts 0x46 in. Length ~149,484 bytes matches the XC3S200A's ~146 KB bitstream.
Images A and B differ in only 8 bytes, all in the tail (CRC-like). The repair
below relies on the tail being preserved.

### The repair

The failure erased `0x00000-0x0FFFF` (image A's first 64 KB), leaving its tail
at `0x10000-0x24831` intact. So:

```python
flash[0x00000:0x10000] = flash[0x40000:0x50000]   # image B's head
# everything else, including image A's own tail, left untouched
```

Program the whole 512 KB, **FLASH region only, leave STATUS/CFG unchecked**
(that is where the block-protect bits live), then verify, then resolder.

### Do not copy image B wholesale into slot A

Writing all `0x24832` bytes of image B over `0x00000-0x24831` does **not** boot:
black screen as before. Only filling the erased 64 KB and preserving image A's
original tail works: the images' heads are interchangeable but their tails are
not, so the repair must be minimal. This also proves the FPGA boots from address
0 and does *not* silently fall back to `0x40000`: image B sat intact throughout
and was never used.

## The bootstrap ROM is not in the config flash (searched and ruled out)

With a full 512 KB dump, the bootstrap was hunted for directly and not found.
Known plaintext available: the 48-byte Nintendo logo (fixed), plus `LOADING`,
`ezgb.dat`, `www.ezflash.cn`.

| Method | Result |
|---|---|
| Byte search, plain / bit-reversed / inverted / nibble-swapped | nothing |
| Statistical scan for BRAM-like frames | two dense regions at bitstream `+0x21400` (bit density 0.586) and `+0x1cc00` (0.520) against a 0.183 baseline; plausible, but see below |
| Logo under constant-stride bit interleaving; 302 strides (1-256 plus powers of two to 4096), both bit orders, inverted; across the whole bitstream, the dense tail, the 8 KB block, and all 512 KB | **nothing** |
| 8 KB block at `0x30000`: container headers, single-byte XOR, stride search | nothing. All 256 byte values present, entropy 7.799, not a copy of any bitstream region |

So the bootstrap is not plain data here, and if it is BRAM initialisation inside
the bitstream, the interleaving is not a constant stride. This settles the
(a)/(b) question in favour of **(b)**: patching the bootstrap's CGB flag would
require Spartan-3A bitstream reverse engineering.

**Alternative: it may live in the Spansion NOR (U4), not the config flash.** The
FPGA could serve the bootstrap from a reserved region of the 4 MB NOR,
consistent with the updater containing no trace of it and 512 KB of config flash
showing nothing under any encoding. Testing needs either a BGA dump or driving
the FPGA's NOR-read path over `$7Fxx` (the interface that bricked a cart on
2026-08-16; not recommended).

**Resolved toward BRAM, not the parallel NOR (2026-08-30).** A full read of the
FW4 updater's write path (see [updater-flash-write.md](updater-flash-write.md))
found **no separate stage1-write mechanism at all**: the updater writes only the
SPI config flash via `$7FD2`, its embedded payload is the FPGA bitstream, and
stage1 is not carried in it under any tested encoding. The clean explanation is
that stage1 is **BRAM-initialised inside the bitstream** — so flashing a new
bitstream to the SPI config flash implicitly updates stage1 on the next
power-on, which is exactly daid's "somehow updated, mechanism unknown". This
also explains why the config-flash dump shows no contiguous stage1 (BRAM init
is bit-interleaved across bitstream frames) and why every FW's stage1 differs
(37% FW4↔FW5) in lockstep with a different bitstream (64% FW4↔FW5).

**So what is the parallel NOR die for?** Now genuinely open. It is not the game
store (that is the volatile RAM die, [nor-reuse.md](nor-reuse.md)), the updater
never touches it, and stage1 most likely lives in BRAM. Candidates: vestigial /
reserved (nitro2k01's sibling revision even upgrades U4 to the 8 MB
`S71GL064A08`, suggesting it is populated but perhaps unused by GB-visible
firmware); or reached only by an FPGA feature/personality not exposed to the GB
CPU. If it is truly firmware-unused, it is a large nonvolatile store with **no
known GB-side access path** — the prize, but gated on either an undiscovered
FPGA command or a replacement FPGA design ([fpga-ace.md](fpga-ace.md)).

**Consequence for CGB mode:** the "patch the bootstrap's CGB flag" shortcut is
dead. The remaining route is a replacement FPGA design (`fpga-ace.md`), serving
its own bootstrap from BRAM with whatever ROM header it chooses.
