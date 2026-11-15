# Setting up, and building an updater

How to set up the tools the FPGA work uses, and how to build and install a
firmware updater that carries our stage1. The reference for each tool is
[toolchain.md](toolchain.md).

Nothing EZ Flash wrote is in this repository. Their updaters, bitstreams,
flash dumps, logo, and everything built from them live in the ignored
`fpga/` folder.

## Tools

Two kinds of work, which here run on two machines. Nothing requires that
split.

| Work | Tools |
|---|---|
| Decoding and patching bitstreams | Rust, prjcombine's database, this repo's `s3decode` crate. Built and run on Linux |
| Stage1 and the scripts | SDCC, RGBDS, Python 3, SameBoy |

### Rust and prjcombine

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
git clone https://codeberg.org/prjunnamed/prjcombine.git ~/fpga/prjcombine
cd ~/fpga/prjcombine && git checkout 7ab08a0207716b0417163301580c154d02d1654e
```

The crate needs Rust 1.85 or newer. The checkout is needed for one file,
`databases/spartan3.zstd`.

**The database and the crates must come from the same commit.** The
database is a serialized binary, so one from another revision will not
load, or loads wrong. `stage0/tools/s3decode/Cargo.toml` pins the same
revision. To move to a newer prjcombine, change both together.

### The Rust tools

```bash
rsync -a stage0/tools/s3decode/ <build host>:~/fpga/s3decode/
ssh <build host> 'cd ~/fpga/s3decode && cargo build --release'
```

| Tool | Does |
|---|---|
| `s3decode` | decodes a bitstream: every configured tile, routing mux and block RAM. `--blob-dir` writes the block RAM contents as files |
| `s3patch` | writes block RAM contents back into a bitstream, recomputes the CRCs, and re-parses the result to prove only the requested bits changed |
| `s3encode` | writes a bitstream from a decode |
| `s3trace` | walks routing back from a pin, or dumps the netlist |
| `s3pins` | the package's pin map |

Xilinx ISE 14.7 is needed only to make bitstreams from scratch, which no
part of the updater build does ([toolchain.md](toolchain.md#ise-147)).

### The Game Boy side

| Tool | Version | For |
|---|---|---|
| SDCC | 4.x with the `sm83` port; 4.6.0 was used | compiling stage1 |
| RGBDS | 1.x | `rgbfix` for stage1; `rgbasm` and `rgblink` for the stock stage1 overlays |
| Python 3 | standard library only | every script |
| mgbdis | cloned to `tools/mgbdis` | the stock stage1 disassembly |
| SameBoy | `scripts/setup-sameboy.sh` | running stage1 and the kernel ([DEVELOPMENT.md](../../docs/DEVELOPMENT.md#trying-it-in-sameboy)) |

`mkicon.py` and `jr-trace.py` convert PNGs with macOS's `sips`. On Linux,
swap that call for another PNG to BMP converter.

SameBoy's stub takes these settings:

| Variable | Meaning |
|---|---|
| `SAMEBOY_EZFLASH_JR_IMG` | the SD card image, default `sd/card.img` |
| `SAMEBOY_EZFLASH_JR_LOG=1` | send the stub's messages to stderr |
| `SAMEBOY_EZFLASH_JR_NOCARD=<s>` | every SD read stays busy for the first `s` seconds, as with no card |
| `SAMEBOY_EZFLASH_JR_FW=4` | report firmware version 4 |
| `SAMEBOY_EZFLASH_JR_DRY=1` | boot as a cart whose coin cell died |
| `SAMEBOY_EZFLASH_JR=0` | turn the stub off |

## What you supply

| Input | Where to get it | For |
|---|---|---|
| the stock updaters | `tools/ezflashjr/official/` ([DEVELOPMENT.md](../../docs/DEVELOPMENT.md#what-you-need)) | every updater: slot B comes out of one |
| stock stage1 dumps | `tools/ezflashjr/stage1/FW4`, `FW5` | checking a decode |
| the EZ Flash logo, as `fpga/bootsplash/ezflash-logo.png` | EZ Flash's marketing logo with the console icon on the left | the boot screen's icon |
| your cart's flash dump (optional) | an SPI programmer ([hardware-board.md](../../docs/hardware-board.md#the-config-flash)) or the cart itself ([flash-dump.md](flash-dump.md)) | slot A, the license record, recovery |

## Building an updater

One script does it, once the stock slot B images and their decoded block
RAMs are in place (steps 1 to 3 below):

```bash
BUILD_HOST=<build host> stage0/tools/build-stage1-updater.sh fw4 "To FW4-MOD 2.1" out-fw4.gb
BUILD_HOST=<build host> stage0/tools/build-stage1-updater.sh fw5-0918 "To FW5-MOD 2.1" out-fw5.gb
```

It builds stage1, splits it into block RAM contents, adds the PicoBlaze
patches (the flash read patch on both, [flash-dump.md](flash-dump.md), and
SD recovery on FW5-0918, [sd-recovery.md](sd-recovery.md)), patches slot B
on the build host, and wraps the result in the stock updater with a new
screen label of at most 16 characters. It stops unless the patched image
decodes back to the same stage1 and the same PicoBlaze programs.

`make updaters BUILD_HOST=<build host>` at the top of the repo runs it for
both firmwares, with the label from `stage1/VERSION`, into
`fpga/stage1/Update-fw4.gb` and `Update-fw5-0918.gb`.

`STAGE1=stock` puts the stock stage1, built from source
([stage1/decomp](../../stage1/decomp/README.md), needs SDCC 2.9.0), in place
of ours, and `PATCHES=0` leaves the PicoBlaze programs stock. Both together
check the whole flow: `make check-slotb BUILD_HOST=<build host>` builds the
stock stage1 from source, patches it into stock slot B and stops unless the
result is stock's slot B byte for byte. It passes for FW4 and FW5-0918
(2026-11-14).

It runs `host-check.sh` first, which stops only when the build host's CPU
is fully busy.

It expects, on the build host, `~/fpga/cart/fw4-updater.bin` and
`~/fpga/cart/fw5/0918.bin` (the stock slot B images), and locally
`fpga/fw4-decode/bram` and `fpga/fw5-decode/bram-0918` (their decoded
block RAMs).

Turning the built updater into the patch that is published is in
[distribution.md](../../docs/distribution.md#the-firmware-updater-patch).

### The steps by hand

**1. Extract slot B** from a stock updater:

```bash
stage0/tools/extract-bitstreams.py tools/ezflashjr/official/2020-03-10_FW4_K1.04e/Update_FW4.gb -o fpga/images/
```

It writes one file per bitstream found, named by its offset
(`Update_FW4@08000.bin`). Given a flash dump it writes slot A and slot B.
The FW5-0918 image is the one at `$8000` of `Update_FW5_2021-9-18.gb`.

**2. Decode it**, keeping the block RAM contents:

```bash
s3decode --db $DB --blob-dir bram/ slotB.bin > slotB.decode.txt
tail -1 slotB.decode.txt         # ... 0 set bits unclaimed
```

**3. Rebuild the stock stage1** from the block RAMs and check it against
daid's dump:

```bash
stage1/tools/stage1-from-bram.py fpga/fw4-decode/bram -o fpga/cgb/stage1-fw4.gb \
    --ref tools/ezflashjr/stage1/FW4/stage1.gb      # matches reference: True
```

**4. Build our stage1.** It needs the icon tiles first:

```bash
stage1/fw4/patches/bootsplash/build.sh     # -> fpga/bootsplash/build/icon.2bpp
stage1/build.sh                            # -> fpga/stage1/stage1.gb
```

**5. Split it into block RAM contents.** Use a relative output directory,
since the printed arguments carry that path:

```bash
cd fpga/stage1
../../stage1/tools/stage1-to-bram.py stage1.gb blobs > sets.txt
```

For FW5-0918 add `--layout fw5-0918`: its stage1 sits in different block
RAMs.

**6. Patch slot B**, on the build host:

```bash
s3patch --db $DB slotB.bin slotB-stage1.bin $(cat sets.txt)
```

**7. Check the round trip.** Decode the patched image and rebuild stage1
from it. It must equal `stage1.gb` byte for byte:

```bash
s3decode --db $DB --blob-dir bram-new/ slotB-stage1.bin > /dev/null
stage1/tools/stage1-from-bram.py bram-new -o check.gb --ref fpga/stage1/stage1.gb
```

**8. Build the updater:**

```bash
stage0/tools/make-updater.py tools/ezflashjr/official/2020-03-10_FW4_K1.04e/Update_FW4.gb \
    slotB-stage1.bin out.gb --label "Update: my s1"
```

The result is the stock updater with the bitstream at `$8000` replaced,
the screen line relabeled so it cannot be mistaken for stock, and the
ROM's checksum fixed. The updater's code is unchanged
([updater.md](updater.md)).

**9. Test in SameBoy.** Stage1 itself, with a card image holding a kernel:

```bash
SAMEBOY_EZFLASH_JR_IMG=sd/card.img tools/SameBoy/build/bin/SDL/sameboy fpga/stage1/stage1.gb
```

The stub does not emulate the config flash, so pressing A in the updater
there tests nothing.

**10. Install.** Copy the updater to the card, launch it from the kernel
like a game, press A, and wait until it stops. Then power-cycle.

## Risk and recovery

- **The updater writes only slot B.** Slot A and the license record are
  untouched.
- **Slot A is the fallback.** It is what the FPGA loads at power-on, and
  its PicoBlaze hands over to slot B. If slot B fails to come up, the boot
  tally makes the next power-on stay on slot A
  ([picoblaze.md](picoblaze.md#at-boot-3f--0)), and the updater can be run
  again from there. This is confirmed on an FW4 cart. On FW5 it is
  inferred from the updater writing the same slot.
- **The fallback covers a corrupt slot B, not one that configures and then
  misbehaves.** A stage1 that hangs cannot run the updater again, because
  the updater is launched from the kernel and stage1 is what loads the
  kernel. Recovery then needs an SPI programmer and a dump of that cart,
  or JTAG ([hardware-board.md](../../docs/hardware-board.md#the-jtag-header)).
- **A write can go bad** through the load from the SD card or through
  power, since the updater writes its payload from RAM without checking
  it. Use a good card and fresh batteries.
- **An FW5 that stops at `Micro SD initial error` with a slow card is not
  a failed update.** Put the kernel and `Update_FW4.gb` on a good card and
  flash FW4 to use the slow card again.
- **Keep every original dump forever**, with a copy off the working
  machine. A dump holds that cart's license record, so never program one
  cart's full image onto another.

**Recovering slot B without a prior dump.** An updater writes nothing
below `$40000`, so after a failed stage1 the cart's slot A and license
record are intact. Desolder the flash, read the whole chip (that read is
now the dump), and program only `$40000`-`$6FFFF` with a slot B region
built from a stock updater: `$FF` everywhere, and its 149,516-byte payload
at offset `$26`. Leave `$70000` and everything below `$40000` alone.
