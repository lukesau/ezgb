# FPGA setup, from nothing to a built updater

How to set up every tool the FPGA work uses, starting from a bare machine,
and then build and install a stage1 updater end to end. Tool reference
(every flag, output formats, ISE details): [toolchain.md](../re/stage0/docs/toolchain.md).
Reading order for the rest: [fpga.md](fpga.md).

Nothing EZ Flash wrote is in this repository. Their updater, bitstreams,
flash dumps, logo and everything built from them live in the ignored
`fpga/` directory; section 8 says where to get each input.

## 1. What you need

| Machine | Runs | Current setup |
|---|---|---|
| Linux build host | prjcombine, the Rust tools (`s3decode`, `s3patch`, `s3trace`, `s3pins`), optionally ISE | Ubuntu 24.04 |
| Game Boy side | Python scripts, SDCC and RGBDS for stage1, SameBoy | macOS |

That split is just how it is set up now, not a requirement. The Python
scripts and stage1 build should work on Linux too, apart from the two image
scripts that call macOS `sips` (section 6). The Rust tools have only been
built on Linux; whether prjcombine builds on macOS hasn't been tried.

Files move between the two with `scp`/`rsync`. The examples use `<build host>`
for the Linux machine and `~/fpga/` as its working directory.

## 2. Rust

On the build host, through rustup:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
. "$HOME/.cargo/env"
```

`s3decode`'s crate uses edition 2024, so it needs Rust 1.85 or newer
(`rustup update` if an older toolchain is already installed).

## 3. prjcombine

```bash
git clone https://codeberg.org/prjunnamed/prjcombine.git ~/fpga/prjcombine
cd ~/fpga/prjcombine && git checkout 7ab08a0207716b0417163301580c154d02d1654e
```

The checkout is needed for the database file,
`databases/spartan3.zstd`. Our tools pull the prjcombine crates from the
same revision through cargo.

**The database and the crates must come from the same commit.** The database
is bincode-serialized, so a database from another revision won't load, or
loads wrong. `scripts/fpga/s3decode/Cargo.toml` pins `7ab08a02…`; to move to
a newer prjcombine, change the rev there and check out the same rev of the
database together. More in
[toolchain.md](../re/stage0/docs/toolchain.md#prjcombine), including building
`prjcombine-cli` to browse the database (optional).

The project's `AGENTS.md` says it does not accept contributions authored by
an LLM. Using it locally is fine; anything sent upstream has to be your own
work.

## 4. Our Rust tools

Copy `scripts/fpga/s3decode/` to the build host and build it there:

```bash
rsync -a scripts/fpga/s3decode/ <build host>:~/fpga/s3decode/
ssh <build host>
cd ~/fpga/s3decode && cargo build --release
```

That builds four binaries in `target/release/`. Every one takes `--db`
(default `../prjcombine/databases/spartan3.zstd`, which is right when run
from `~/fpga/s3decode`) and `--device` (default `xc3s200a`).

| Tool | Does |
|---|---|
| `s3decode` | decode a bitstream: every configured tile, routing mux and BRAM; `--blob-dir` writes BRAM contents as files |
| `s3patch` | write bel attributes, mainly BRAM `DATA`, back into a bitstream. Recomputes the CRCs, refuses frames written by MFWR, and re-parses the output to prove only the requested bits changed |
| `s3trace` | walk routing back from a bel pin (`--from TILE:BEL:PIN --depth N`), list pins (`--list-pins TILE`), or dump the netlist as JSON lines (`--netlist out.jsonl`) |
| `s3pins` | the package pin map, e.g. `--bond vq100` |

Flags and output formats: [toolchain.md](../re/stage0/docs/toolchain.md#s3decode).

## 5. ISE 14.7 (optional)

Only needed to *make* bitstreams: the blank baseline that `s3decode
--baseline` diffs against, and the smoke test. Nothing in the updater build
needs it. Getting it (copied out of AMD's VM appliance), the Ubuntu 24.04
packages, the free WebPACK license and how to run it are all in
[toolchain.md](../re/stage0/docs/toolchain.md#ise-147). Once it's in place:

```bash
rsync -a --exclude s3decode scripts/fpga/ <build host>:~/fpga/scripts/
ssh <build host> ~/fpga/scripts/smoke-test.sh
```

The smoke test also rebuilds `~/fpga/blank/blank.bit`. Without ISE, decode
without `--baseline`: the output then lists every unused tile's default
settings too, which is fine for BRAM work.

## 6. The stage1 toolchain

On the Game Boy side machine:

| Tool | Version | Used for |
|---|---|---|
| SDCC | 4.x with the `sm83` port (`-msm83`); 4.6.0 was used | compiling `stage1/` (`sdcc`, `sdasgb`, `sdldgb`, `makebin`) |
| RGBDS | 1.x (1.0.1 was used) | `rgbfix` for stage1; `rgbasm`/`rgblink` for the splash lab in `re/fpga-fw4/bootsplash/` and the overlay patches in `re/fpga-fw4/` |
| Python 3 | standard library only | every script in `scripts/fpga/`; PIL isn't needed |
| mgbdis | cloned into `tools/mgbdis` | the stock stage1 disassembly (`scripts/fpga/stage1-regen.sh`) |

On macOS: `brew install sdcc rgbds python`. mgbdis:

```bash
git clone https://github.com/mattcurrie/mgbdis tools/mgbdis
```

`mkicon.py` and `jr-trace.py` read PNGs by converting them with macOS
`sips`. On Linux, swap that call for another PNG-to-BMP converter
(`mkicon.py` wants a 32-bit BMP with alpha; `jr-trace.py` takes 24 or 32
bits).

## 7. SameBoy for testing

```bash
scripts/setup-sameboy.sh                 # clones into tools/SameBoy, applies patches/sameboy/
cd tools/SameBoy && make CONF=debug sdl  # needs SDL2 (brew install sdl2)
```

Run it from a `bitstream-re` checkout: this branch's
`patches/sameboy/0001-ezflash-jr-stub.patch` is the one that runs stage1.
Main's version only runs the kernel. On this branch the stub:

- turns on for the title `BOOTLOADER` (stage1) as well as `EZGB` (the kernel);
- after stage1 writes `$7F32`, swaps the loaded file in for the cart in place,
  with no reset, as the FPGA does;
- answers reads with `$7F30=$03` with the read status instead of sector data;
- reads extent `end` words as running totals.

| Env var | Meaning |
|---|---|
| `SAMEBOY_EZFLASH_JR_IMG` | the SD card image. Default `sd/card.img` (see [DEVELOPMENT.md](DEVELOPMENT.md)) |
| `SAMEBOY_EZFLASH_JR_LOG=1` | send the stub's messages to stderr |
| `SAMEBOY_EZFLASH_JR=0` | turn the stub off |

Default keys: Return = START, Backspace = SELECT, X = A, Z = B, arrows =
D-pad.

## 8. Inputs you supply yourself

None of these are in the repository. Put them where the commands below
expect them, or adjust the paths.

| Input | Where to get it | Used by |
|---|---|---|
| stock `Update_FW4.gb` | EZ Flash's 1.04e FW4 package (`juniorkernel-1.04e-FW4/`), or `official/2020-03-10_FW4_K1.04e/` in [daid/ezflashjr](https://github.com/daid/ezflashjr). Both copies are the same file | every updater; slot B comes out of it |
| stock stage1 dumps | daid/ezflashjr `stage1/FW1`..`FW5/stage1.gb` (clone it to `tools/ezflashjr`) | `stage1-from-bram.py --ref`, to prove a decode |
| your cart's config-flash dump (optional) | read with an SPI programmer, [hardware-board.md](hardware-board.md) | slot A, the license record, recovery |
| the EZ Flash logo PNG | EZ Flash's marketing logo with the console icon on the left, saved as `fpga/bootsplash/ezflash-logo.png` | `mkicon.py`, via `re/fpga-fw4/bootsplash/build.sh`; stage1 needs its `icon.2bpp` |
| the cart-label photo (optional) | a photo of the Jr's label, `fpga/bootsplash/cart-label.png` | `jr-trace.py`, only to retrace the committed `stage1/art/jr.txt` |

## 9. End to end: build and install a stage1 updater

`<repo>` is your checkout; commands without a host run on the Game Boy side
machine from `<repo>`. `$DB` on the build host is
`~/fpga/prjcombine/databases/spartan3.zstd`.

**1. Extract slot B** from the stock updater:

```bash
scripts/fpga/extract-bitstreams.py juniorkernel-1.04e-FW4/Update_FW4.gb -o fpga/images/
# Update_FW4@08000.bin  sha1 65aff9ce6a20
scp fpga/images/Update_FW4@08000.bin <build host>:~/fpga/cart/slotB.bin
```

With a flash dump as well, it also writes slot A (`@00026`) and slot B
(`@40026`).

**2. Decode it**, keeping the BRAM contents:

```bash
# on the build host
cd ~/fpga/cart
~/fpga/s3decode/target/release/s3decode --db $DB --blob-dir bram/ slotB.bin > slotB.decode.txt
tail -1 slotB.decode.txt         # ... 0 set bits unclaimed
```

Add `--baseline ~/fpga/blank/blank.bit` if you have ISE's blank design.
Copy `bram/` back.

**3. Rebuild the stock stage1** from the BRAMs and check it against daid's
dump:

```bash
scp -r <build host>:~/fpga/cart/bram fpga/fw4-decode/
mkdir -p fpga/cgb
scripts/fpga/stage1-from-bram.py fpga/fw4-decode/bram -o fpga/cgb/stage1-fw4.gb \
    --ref tools/ezflashjr/stage1/FW4/stage1.gb
# matches reference: True
```

`fpga/cgb/stage1-fw4.gb` is where the splash lab expects stock stage1. To
regenerate the annotated disassembly of it, copy it to
`re/stage1/fw4/kernel.gb` and run `scripts/fpga/stage1-regen.sh` ("rebuild
matches kernel.gb").

**4. Build our stage1.** It needs the icon tiles from the splash build first:

```bash
re/fpga-fw4/bootsplash/build.sh          # -> fpga/bootsplash/build/icon.2bpp (and the splash lab)
EZGB_ROOT=<repo> stage1/build.sh         # -> fpga/stage1/stage1.gb
# stage1: 11410 bytes used of 18432
```

`EZGB_ROOT` names the checkout whose `fpga/` holds the inputs and outputs. It
defaults to the checkout `build.sh` is in, so set it when building from a
second worktree. rgbfix prints "Overwrote a non-zero byte" warnings; they
are expected. Version and build options: [stage1/README.md](../stage1/README.md).

**5. Split it into BRAM contents.** Use a relative output directory, because
the printed `--set` arguments carry that path:

```bash
cd fpga/stage1
../../scripts/fpga/stage1-to-bram.py stage1.gb blobs > sets.txt
scp -r blobs <build host>:~/fpga/cart/
scp sets.txt <build host>:~/fpga/cart/
```

**6. Patch slot B:**

```bash
# on the build host
cd ~/fpga/cart
~/fpga/s3decode/target/release/s3patch --db $DB slotB.bin slotB-stage1.bin $(cat sets.txt)
```

**7. Check the round trip.** Decode the patched image and rebuild stage1
from it. It must equal `stage1.gb` byte for byte:

```bash
# on the build host
~/fpga/s3decode/target/release/s3decode --db $DB --blob-dir bram-new/ slotB-stage1.bin > slotB-stage1.decode.txt
tail -1 slotB-stage1.decode.txt  # 0 set bits unclaimed
# back on the Game Boy side
scp -r <build host>:~/fpga/cart/bram-new <build host>:~/fpga/cart/slotB-stage1.bin fpga/stage1/
scripts/fpga/stage1-from-bram.py fpga/stage1/bram-new -o fpga/stage1/stage1-from-slotB.gb \
    --ref fpga/stage1/stage1.gb
# matches reference: True
```

**8. Build the updater:**

```bash
scripts/fpga/make-updater.py juniorkernel-1.04e-FW4/Update_FW4.gb \
    fpga/stage1/slotB-stage1.bin fpga/load/Update_FW4-stage1.gb --label "Update: my s1"
```

The result is the stock updater with the payload at `$8000` replaced and the
16-byte screen line at `$11D2` relabeled (at most 16 characters), so it
can't be mistaken for stock. The script also fixes the ROM's global header
checksum. The updater code is unchanged, and it has no payload checksum,
read-back or version check, so nothing else needs fixing up.

**9. Test in SameBoy.** Stage1 itself, with a card image holding `EZGB.DAT`:

```bash
SAMEBOY_EZFLASH_JR_IMG=sd/card.img SAMEBOY_EZFLASH_JR_LOG=1 \
    tools/SameBoy/build/bin/SDL/sameboy fpga/stage1/stage1.gb
```

It should show the boot screen and boot the kernel, on both the CGB and DMG
models. Then open the updater the same way and check its start screen shows
your label. The stub doesn't emulate the config flash, so don't take
pressing A in the emulator as a test of the write.

**10. Install on the cart.** Copy the updater to the SD card, launch it from
the kernel like a game, press A, and wait until it stops. Then power-cycle.
The new stage1 runs from the next power-on.

## 10. Risk and recovery

- The updater writes only slot B: config flash `$40026`, 149,516 bytes
  (erasing the three 64 KB sectors from `$40000`). Slot A and the per-chip
  license record at `$30000` are untouched.
- Slot A is what the FPGA loads at power-on; its PicoBlaze firmware hands
  over to slot B. If slot B fails to come up, a boot tally makes the next
  power-on stay on slot A
  ([picoblaze.md](../re/stage0/docs/picoblaze.md#at-boot-3f--0)). That covers a
  corrupt slot B, not a slot B that configures and then misbehaves.
- A stage1 that configures but hangs can't run the updater again, because
  the updater is launched from the kernel and stage1 is what loads the
  kernel. Recovery then means an SPI programmer and a known-good flash dump
  of that cart ([hardware-board.md](hardware-board.md)).
- **Keep every original dump forever**, with a copy off the working machine.
  The as-read dump is the restore source, and for a damaged cart the only
  record of the damage. A dump holds that cart's own license record, so
  never program one cart's full image onto another; splice slot B into a
  fresh dump of that cart instead.
- Everything here has run on one FW4 Jr. An FW5 design doesn't hand over
  from one image to the other ([fw5.md](../re/stage0/docs/fw5.md)), so check what
  your cart's slot A is before trusting the fallback.
