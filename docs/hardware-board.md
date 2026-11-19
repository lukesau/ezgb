# The EZ Flash Jr board

Silkscreen `EZGB` on the front, the `EZFLASH` logo and a `JTAG` header on
the back. Part numbers were read from a cart under magnification.

**Orientation.** On the front, the Game Boy edge connector is the bottom
and the coin cell, U4 and U9 are the top. Seen that way the top row runs
U9, U4, coin cell from left to right, the FPGA is below U9 and U4, and the
SD slot is on the right above the connector.

## Chips

| Ref | Marking | What it is | Role |
|---|---|---|---|
| U1 | `XILINX SPARTAN XC3S200A VQG100` | Spartan-3A FPGA, 200K gates, 100-pin VQFP | Everything custom about the cart ([stage0/](../stage0/README.md)) |
| - | `25Q40H`, 8-pin SOIC | EON EN25F40, 512 KB SPI NOR flash (JEDEC ID `1C 31 13`) | The FPGA's configuration |
| U4 | `Spansion 71GL032A40BFW0B`, BGA | S71GL032A40: a 4 MB NOR die and a 512 KB pSRAM die in one package (`tools/S71GL032A.PDF`) | Its pSRAM is the battery-backed save store. Its NOR is unused |
| U9 | `3350LLZDQ0`, 88-ball BGA | Numonyx RD38F3350LLZDQ0: 32 MB of NOR and an 8 MB pSRAM die (`tools/RD38F3350-StrataFlash-Wireless-L18-L30.pdf`) | Its pSRAM holds the loaded game. Its NOR is unused |
| U6, U7 | `LVT162245` x2 | 16-bit bus transceivers, 3.3 V with 5 V-tolerant inputs | Level shifters on the cart edge |
| U3 | `8563S`, 8-pin | PCF8563 real-time clock, on I2C | The clock |
| U2 | `74HC595D` | 8-bit shift register | Extra outputs for the FPGA: the upper ROM bank bits |
| Y1 | 24.545 MHz crystal | | The FPGA's clock |
| Y2 | 32.768 kHz crystal | | The clock chip's timebase |
| - | button, center of board | | Reset. It sits against the shell, so a press on the plastic over it works |
| - | `JTAG`, 8 pads on the back edge | | The FPGA's JTAG port |

## What is stored where

| Store | Where | Size | Kept without power? |
|---|---|---|---|
| The loaded game | U9's pSRAM | 8 MB, the largest Game Boy ROM | No. It fades within seconds to minutes ([game-store.md](game-store.md)) |
| Saves and the kernel's records | U4's pSRAM | 32 pages of 8 KB ([psram-map.md](psram-map.md)) | By the coin cell |
| The FPGA design, with stage1 inside it | the SPI flash | 512 KB ([flash-map.md](../stage0/docs/flash-map.md)) | Yes |
| The kernel | the SD card, as `ezgb.dat` | | Yes |

The kernel reaches 256 KB of U4's 512 KB die: the page latch is 5 bits,
and each byte takes one 16-bit word of the chip.

**Neither NOR die has any use the Game Boy can reach.** No value of
`$7FC0` maps one, and the updater writes only the SPI flash
([updater.md](../stage0/docs/updater.md)). About 36 MB of flash
sits on the board unused.

**The coin cell** runs the clock and U4's pSRAM. pSRAM draws far more
standby current than the SRAM or FRAM of an original cart, so a cell lasts
one to eight months, not ten years. Swapping U4 for a pin-identical part
with a true SRAM die fixes that ([battery-sram-swap.md](battery-sram-swap.md)).
The cell also supplies current while the console is on, which the swap does
not change ([power-design.md](power-design.md#backup-domain-measurements)).

## The config flash

The Spartan-3A has no configuration memory of its own, so at every
power-on it loads its design from the SPI flash. That flash is a commodity
part: a SOIC-8 a test clip fits, readable and writable with a cheap
CH341A-class programmer, independent of the cart's update path. **A full
512 KB dump taken before any firmware work is a complete restore image.**

The silkscreen says `25Q40H`, but select `EN25F40` in the programmer:
`W25Q40` and `EN25Q40` fail the ID check. Desoldering the chip and reading
it in a socket avoids contention with the FPGA.

| Range | Contents |
|---|---|
| `$00000` | slot A, the image the FPGA loads at power-on. Never rewritten by an updater |
| `$30000`-`$31FFF` | the cart's license record, tied to the FPGA's serial number |
| `$40000` | slot B, the image the cart runs. Written by the updater |
| `$70000` | the boot tally |

Slot A's PicoBlaze hands over to slot B on a healthy cart, and falls back
to running itself when slot B fails its CRC. The two images differ by one
PicoBlaze instruction and the CRC. The details are in
[flash-map.md](../stage0/docs/flash-map.md) and
[picoblaze.md](../stage0/docs/picoblaze.md).

## Recovering a cart whose FPGA no longer configures

**The symptom:** a blacked-out or garbled Nintendo logo at power-on, on
every console, with or without a card. With slot A damaged the FPGA never
configures, the cart drives nothing, and the boot ROM halts on a logo it
cannot verify.

This has been done once, on a cart whose slot A lost its first 64 KB to an
aborted flash command. The flash still held slot B, and the repair was
built from it:

```python
flash[0x00000:0x10000] = flash[0x40000:0x50000]   # slot B's first 64 KB
# everything else, slot A's tail included, left untouched
```

Program the whole 512 KB, the flash region only, leaving the status and
configuration bits unchecked, since that is where the block-protect bits
live. Then verify, and resolder.

**Do not copy slot B wholesale over slot A.** That does not boot. The two
images' heads are interchangeable and their tails are not, so the repair
must be minimal: fill what was erased and nothing else.

**Never program one cart's full image onto another.** The license record
is tied to each FPGA's serial number, and a cart with the wrong record
hangs at `LOADING`.

The repaired cart's slot A matched a second, never-damaged cart's exactly.

## The JTAG header

Configuring the FPGA over JTAG loads its SRAM only and is gone at
power-off, which makes it the way to try a design without writing the
flash.

Pad 1 is the one nearest the `JTAG` silkscreen. The order was found by
continuity from each pad to the FPGA's pins:

| Pad | Signal | VQ100 pin |
|---|---|---|
| 1 | TDO | 75 |
| 2 | TCK | 76 |
| 3 | TMS | 1 |
| 4 | TDI | 2 |
| 5 | GND | |
| 6, 7 | supply rails | |
| 8 | GND | |

It is a JTAG-only header. `PROG_B`, `DONE` and `INIT_B` are not brought
out, and are not needed: JTAG can reconfigure with `JPROGRAM`.

**Pads 6 and 7 cannot be told apart by continuity**, since every supply
rail reads continuous to every other through the decoupling capacitors.
Measure them under power, with ground on pad 5: use the one that reads 2.5
to 3.3 V as the cable's reference, and not one that reads 1.2 V, which is
the core supply.

Wiring for a Digilent HS2, straight through:

```
TCK -> pad 2     TDI -> pad 4     GND  -> pad 5 or 8
TMS -> pad 3     TDO -> pad 1     VREF -> pad 6 or 7, the 3.3 V one
```

The FPGA's IDCODE is `0x02218093`.

A separate group of three pads beside the header has no continuity to the
FPGA. They are probably the SPI flash's lines; that has not been checked.
