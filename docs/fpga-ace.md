# Running your own logic on the Jr's FPGA

Goal: arbitrary code execution at the *hardware* layer — our own bitstream on
the cart's Spartan-3A, rather than patched bytes inside EZ Flash's kernel.

## The strategy: replace, don't reverse

Reverse engineering the factory bitstream is a research project (undocumented
proprietary format, per-family, CRC-protected). Writing a *new* bitstream for a
known part is ordinary FPGA development. The part is fully documented and
supported by free tools:

| | |
|---|---|
| FPGA | `XC3S200A-4VQG100` — Spartan-3A, 200K gates, 100-pin VQFP |
| Toolchain | Xilinx **ISE 14.7 WebPACK** — free, and the last version supporting Spartan-3A. Runs on Linux; a VM is fine |
| Config flash | EON `EN25F40`, 512 KB SPI (see `hardware-board.md`) |
| Programming | JTAG header on the board's back edge, 8 pads |

## Why JTAG changes everything

Configuration over JTAG loads straight into the FPGA's **SRAM**. It does not
touch the config flash. Power-cycle and the factory image reloads from flash,
unchanged.

That is a reversible, unlimited-iteration loop — the exact opposite of the
write-once-to-nonvolatile experiments that bricked a cart on 2026-08-16. **Do
all development over JTAG. Only write the SPI flash once a design is proven,
and only with a verified dump of the working image in hand** (procedure in
`hardware-board.md`).

## Roadmap

### 1. Get a JTAG connection

Identify the 8 pads: Xilinx JTAG needs TCK, TMS, TDI, TDO, plus GND and VCC.
Buzz them out against the FPGA's dedicated JTAG pins from the XC3S200A VQ100
pinout (they are fixed-function, so the package pinout tells you which balls to
probe).

Adapter options: any FT2232H breakout (~$15), a Digilent HS2/HS3, or a
Raspberry Pi bit-banging. Software: **`xc3sprog`** or **OpenOCD** — both
open-source, both handle Spartan-3 configuration and SPI-flash-via-FPGA.

Success criterion: the chain enumerates and reports the IDCODE for an
XC3S200A. That alone proves wiring, levels and power are right, and is
completely passive.

### 2. Map the pinout by boundary scan

This is the highest-leverage step and it replaces board tracing with software.
Grab the **BSDL file** for `XC3S200A_VQ100` and use JTAG boundary scan to:

- **SAMPLE** pin states while the cart sits in a powered console — the address
  and data lines will be visibly toggling as the CPU fetches, which identifies
  the cart-edge bus without probing anything.
- **EXTEST** to drive pins one at a time and observe where the signal appears
  (SD card socket, the two `LVT162245` transceivers, the SPI flash, the NOR).

Output: a pin map from FPGA balls to cart edge signals, SD, flash, RTC and the
shift register. Everything afterward depends on this.

### 3. Minimal bring-up design

Smallest useful target: present a static ROM on the Game Boy bus. Decode the
cart-edge address lines, drive data from an internal block RAM, ignore
everything else. If a console boots it and shows anything on screen, the pin
map is right and the whole toolchain works.

From there: MBC emulation, then SD access, then whatever the point of all this
turns out to be — including the CGB header, which at that layer is just bytes
you choose to present.

### 4. Persistence

Only once a design is proven over JTAG: write it to the `EN25F40`. Keep the
factory dump. Note the confirmed layout — image A at `0x00000` is what the FPGA
boots; image B at `0x40000` is a spare that is *not* an automatic fallback.

## What we already know that helps

- Full config flash layout, and a working repair procedure
  (`hardware-board.md`).
- A dump of the factory bitstream, if it is ever worth studying for pin
  assignments rather than logic.
- The FPGA's register interface as seen from the Game Boy side — the
  unlock/command/commit protocol and the meaning of many `$7Fxx` ports
  (`REGISTERS.md`, `game-slot-access.md`). A replacement design can either
  reimplement that interface for kernel compatibility, or discard it entirely
  and define its own.
- The kernel disassembly, fully labelled, if compatibility is wanted.

## Reality check

This is a project measured in weeks, not an afternoon, and step 2 is where it
will actually be won or lost. But nothing in it requires defeating anything —
only a JTAG cable, a free toolchain, and a pin map.
