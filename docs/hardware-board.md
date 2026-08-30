# EZ Flash Jr board

Silkscreen `EZGB` on the front, `EZFLASH` logo and a `JTAG` header on the back.
Part numbers transcribed from a physical cart under magnification, so treat the
exact strings as approximate; the families are confident.

## Chips

| Ref | Marking | Identification | Confidence | Role |
|---|---|---|---|---|
| U1 | `XILINX SPARTAN XC3S200A VQG100AGQ1240` | Spartan-3A, 200K gates, 100-pin VQFP | High | The FPGA. Everything custom about this cart. |
| - | `25Q40H E20090N` (8-pin SOIC) | 4 Mbit / **512 KB** SPI NOR flash (W25Q40 family) | High | **FPGA configuration storage** (see below). |
| U4 | `Spansion 71GL032A40BFW0B` (BGA) | S71GL032A MCP, 32 Mbit / **4 MB** NOR flash | High | Game ROM storage: where a launched ROM is programmed. |
| U9 | `3350LLZDQD` / `Z544I208A`, lowercase-`i` logo (BGA) | **PSRAM** per community teardowns; not FRAM | Medium | Save + file-list storage, kept alive by the coin cell |
| U6, U7 | `LVT162245` ×2 (`P01AD` = lot code, Fairchild) | 74LVT162245, 16-bit bus transceiver, 3.3 V with 5 V-tolerant inputs | High | Cart-edge bus interface (PHY). Two × 16 bits ≈ 16 address + 8 data + control. |
| U3 | `8563S 2506 TMS` (8-pin) | PCF8563/BM8563 I²C real-time clock | High | The RTC. Paired with the coin cell; this is what 1.05e's "RTC codes are rewritten" refers to. |
| U2 | `74HC595D` (16-pin) | 8-bit shift register, serial in / parallel out with latch | High | I/O expansion: more signals than the FPGA has spare pins for. |
| Y1 | `24.545 MHz` crystal | - | High | FPGA clock. |
| Y2 | 32.768 kHz (near RTC) | - | Medium | RTC timebase. |
| - | Tactile button, centre of board | - | High | Reset button; reboots the cart. Sits right against the shell, so a light press on the plastic over it triggers a reset without opening the case. |
| - | `JTAG` header, back edge, 8 pads | - | High | Xilinx JTAG chain (FPGA and/or config flash). |

## U9 is battery-backed PSRAM

U9 is `3350LLZDQD`, PSRAM per community teardowns (not FRAM). The coin cell backs
**both the RTC and the save memory**. PSRAM draws far more standby current than
FRAM, so cell life runs roughly 1-8 months (depending on memory variant) against
10+ years for an original battery-backed cartridge, the recurring "battery dies
in a month" complaint. Some owners swap the cell for a CR2032 or replace the
memory part.

Because saves live in battery-backed PSRAM, they and the `$A300` last-ROM
metadata are **volatile if the coin cell dies**. Save layout is owned by
[psram-save-map.md](psram-save-map.md).

Community teardowns describe the Spansion `71GL032A` MCP as 32 Mbit flash for
ROMs plus additional memory, so exact U4/U9 partitioning is not settled.
Capacity checks out against the `$12 + (idx>>5)` page arithmetic (~2 MB; EZ
Flash's changelog states a 7000-file maximum).

Sources: beyondconsoles EZ-Flash Junior review; GBAtemp battery-drain threads.

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

**Consequence for CGB mode:** the "patch the bootstrap's CGB flag" shortcut is
dead. The remaining route is a replacement FPGA design (`fpga-ace.md`), serving
its own bootstrap from BRAM with whatever ROM header it chooses.
