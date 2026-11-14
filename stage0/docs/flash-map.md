# The config flash and the bitstreams in it

The FPGA has no memory of its own for its design. At every power-on it
loads a bitstream from a 512 KB SPI flash (an EON EN25F40,
[hardware-board.md](../../docs/hardware-board.md#the-config-flash)). This
page is the flash's layout and what a bitstream contains.

## Layout

| Range | Contents |
|---|---|
| `$00026` | **slot A**: a 149,516-byte bitstream. The FPGA loads it at power-on. No updater writes it |
| `$30000`-`$31FFF` | **the license block**: records tied to this FPGA's serial number |
| `$40026` | **slot B**: a 149,516-byte bitstream, the one the cart runs. Written by the updater |
| `$70000` | **the boot tally**: one byte programmed at every power-on, in a sector erased when it fills |
| everything else | erased, `$FF` |

Slot A's PicoBlaze reconfigures the FPGA from slot B at every boot, and
stays on slot A when the tally shows slot B did not come up last time
([picoblaze.md](picoblaze.md#at-boot-3f--0)). So slot A is both the first
stage and the fallback.

**The two slots differ by one PicoBlaze instruction and the CRC.** Slot A
has `LOAD s0, 01` and slot B `LOAD s0, 02` at the PicoBlaze's `$1B8`: the
switch that makes slot A hand over. That is two bytes in the stream, plus
six in the CRC at its end.

## A bitstream is plain `bitgen` output

Each slot is a standard Xilinx stream for the XC3S200A, not a custom
container: 32 dummy `$FF` bytes, the sync word `aa 99`, then configuration
writes. The device ID is `0x2218093`. prjcombine's parser reads them
unchanged, and every FW4 and FW5 image decodes with no set bit left
unexplained.

The configuration registers of FW4's slot B, the same in the FW5 images:

```
CTL0 0085   COR1 2f08   COR2 89ee   CCLK_FREQ 3c0f   POWERDOWN 0881
HC_OPT 001f   PU_GWE 0005   PU_GTS 0004   SEU_OPT 18f2   MODE 000e
GENERAL1 0000   GENERAL2 0000
```

`GENERAL1` and `GENERAL2`, the address of a next image, are zero. The
hand-over to slot B is done by the PicoBlaze through the ICAP, not by the
stream.

## What is in the block RAMs

Stage1 and the PicoBlaze's programs are the initial contents of block
RAMs, which is why no search of the flash for stage1's bytes finds it:

| Block RAM (FW4) | Width | Contents |
|---|---|---|
| `X19Y5`, `X19Y21`, `X19Y25`, `X3Y13`, `X3Y17`, `X19Y13`, `X19Y9`, `X19Y29` | 1 bit each | stage1 `$0000`-`$3FFF`, bits 0 to 7 in that order: one memory per data bit |
| `X19Y17` | 9 bits | stage1 `$4000`-`$47FF`, bytes in order |
| `X3Y29` | 18 bits | the PicoBlaze's first program (SD, the loader, the clock) |
| `X3Y25` | 18 bits | the PicoBlaze's second program (the flash, the license check, the hand-over) |

The others have no initial contents and are used as RAM: the sector
buffer, the two SD FIFOs and the load command table.

`stage1/tools/stage1-from-bram.py` rebuilds stage1's 32 KB from a decoded
bitstream, and the result matches a dump from a cart byte for byte. Going
the other way, `stage1-to-bram.py` and `s3patch` put a new stage1 in
([setup.md](setup.md)).

Every build is placed and routed from scratch, so the same contents land
on different tiles in each firmware:

| Contents | FW4 | FW5-0731 | FW5-0918, the SGB beta |
|---|---|---|---|
| PicoBlaze, second program | `X3Y25` | `X19Y21` | `X3Y5` |
| PicoBlaze, first program | `X3Y29` | `X19Y25` | `X3Y1` |
| stage1 `$4000`-`$47FF` | `X19Y17` | `X3Y17` | `X3Y17` |

For the same reason a byte diff of two firmwares' streams shows most of
the file changed and says nothing. The useful comparisons are by content:
block RAMs matched by their contents, PicoBlaze code matched routine by
routine (`stage0/tools/picoblaze-diff.py`), and the settings at fixed
positions. The second program is identical in every image, FW4 included.

## What the updaters carry

| Updater | Bitstreams |
|---|---|
| `Update_FW4.gb` | one, at `$8000`. It is slot B byte for byte |
| `Update_FW5_7-31.gb`, `Update_FW5_forSGB.gb`, `Update_FW5_2021-9-18.gb` | two each, at `$8000` and `$2C80C` |

Every updater writes only its first bitstream, to slot B
([updater.md](updater.md)). The second one in the FW5 updaters is
byte-identical in all three and is not written by the update loop.

So there are five distinct designs, each with a folder here: `fw4`,
`fw5-0731`, `fw5-sgb-beta`, `fw5-0918`, and that second image as
`fw5-slota`.

What slot A an FW5 cart shipped with has not been read from one. An FW4
cart's and a repaired cart's slot A are identical.

## Tools

```bash
stage0/tools/extract-bitstreams.py <updater or flash dump> -o fpga/images/   # every stream, named by offset
stage0/tools/flash-map.py <flash dump>                                       # the segments of a dump
stage0/tools/slot-diff.py <flash dump> --slots                               # slot A against slot B
stage0/tools/slot-diff.py <flash dump> --overlay Update_FW4.gb --slot B      # an updater's stream against a slot
```

Decoding, patching and encoding a stream are in
[toolchain.md](toolchain.md).
