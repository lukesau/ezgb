# Development guide

How to set up a checkout, change the mod, carry the change to all three
kernels and cut the patches. What the project is and how to install the mod
are in the [README](../README.md).

## What you need

| Tool | For |
|---|---|
| [RGBDS](https://rgbds.gbdev.io) 1.x (`rgbasm`, `rgblink`, `rgbfix`) | assembling the disassemblies and the mod's asm |
| [SDCC](https://sdcc.sourceforge.net/) 4.6.0 | compiling the mod's C |
| Python 3, perl | the scripts |
| [mtools](https://www.gnu.org/software/mtools/) | building the emulator's SD card image |

The SDCC version matters. `rebuild-blocks.py` compares what the compiler
produces with the bytes in the kernel, so a different SDCC reports every
block as stale. The committed kernels were built with 4.6.0 (#16555).

Other people's repositories are cloned into `tools/`, which is ignored:

```sh
git clone https://github.com/mattcurrie/mgbdis tools/mgbdis          # the disassembler
git clone https://github.com/daid/ezflashjr tools/ezflashjr          # EZ Flash's firmware packages
git clone https://github.com/pret/gb-asm-tools tools/gb-asm-tools    # optional, for scripts/gbdiff.sh
git clone https://github.com/ezflash-team/omega-de-kernel tools/omega-de-kernel   # optional, naming reference
./scripts/setup-sameboy.sh && make -C tools/SameBoy CONF=debug sdl   # the emulator, with the EZ Jr stub
```

`tools/ezflashjr/official/` stops at the 2020 packages. The 2021-09-18 one
goes beside them in the same format, as `official/2021-09-18_FW5_K1.05e/`
holding `ezgb.dat` and `Update_FW5_2021-9-18.gb` (md5s in
[kernel-versions.md](kernel-versions.md)).

## Setting up a checkout

EZ Flash's binaries are not in the repo. Each kernel version needs two
files beside its disassembly, both ignored by git:

| File | What it is |
|---|---|
| `kernel/<ver>/kernel.gb.orig` | the stock `ezgb.dat`, untouched |
| `kernel/<ver>/kernel.gb` | the modded kernel, the image every tool reads and patches |

```sh
O=tools/ezflashjr/official
cp $O/2020-03-10_FW4_K1.04e/ezgb.dat   kernel/1.04e/kernel.gb.orig
cp $O/2020-07-31_FW5_K1.05RC/ezgb.dat  kernel/1.05e-0731/kernel.gb.orig
cp $O/2021-09-18_FW5_K1.05e/ezgb.dat   kernel/1.05e-0918/kernel.gb.orig

for v in 1.04e 1.05e-0731 1.05e-0918; do scripts/build-kernel.sh $v --install; done
```

`build-kernel.sh` assembles the committed disassembly, checks the result
against the md5 in `patches/kernel/manifest.json`, and with `--install`
writes it to `kernel.gb`. Then confirm the checkout is whole:

```sh
scripts/rebuild-blocks.py                           # "all C blocks match their sources"
scripts/port-mod.py 1.05e-0731 1.05e-0918 --check   # "identical"
scripts/port-mod.py 1.05e-0731 1.04e --check
```

Put the `.orig` files in place before running anything else. Without one,
`inject.py` saves the modded kernel as the "pristine" copy and `portmap.py`
maps from the modded kernel, and neither says so.

## How the mod is stored

The mod has no single source tree that builds into a kernel. It is the
modded `kernel.gb` itself, described by tracked files:

- `kernel/<ver>/disassembly/` reassembles to `kernel.gb`, apart from four
  header bytes (`$0148` and the checksums at `$014D`-`$014F`) that
  `build-kernel.sh` sets.
- `kernel/<ver>/kernel.sym` names every label and marks each injected block
  as `bank:addr .data:LEN`. `kernel/<ver>/notes.json` holds the comment
  blocks. The disassembly is regenerated from these two, so hand edits to
  `bank_*.asm` are lost.
- `kernel/mod/src/` is the C, `kernel/mod/asm/` the assembly. `REGISTRY` in
  `scripts/port-mod.py` is the one list of C blocks: source file, bank,
  address and pins.
- Hand-assembled hooks, and every patched call site in stock code, have no
  source file. They exist only as bytes in `kernel.gb` and as blocks in the
  disassembly ([shims.md](../kernel/mod/src/shims.md) describes them).

1.05e-0731 is where features are written. The other two kernels are never
edited by hand; they are ports of it.

## Changing the mod

```sh
# 1. edit C in kernel/mod/src, then bring 0731 up to date
scripts/rebuild-blocks.py --apply          # re-injects every block whose source changed
scripts/regen-disasm.sh 1.05e-0731         # disassembly from kernel.gb + kernel.sym + notes.json

# 2. carry it to the other kernels
scripts/port-mod.py 1.05e-0731 1.05e-0918 --apply --sym
scripts/port-mod.py 1.05e-0731 1.04e --apply --sym
scripts/regen-disasm.sh 1.05e-0918 && scripts/regen-disasm.sh 1.04e

# 3. cut the patches
scripts/kernel-patch.py make               # patches/kernel/*.ips and manifest.json
```

Commit the sources together with the three disassemblies, `kernel.sym`,
`notes.json`, the `.ips` files and `manifest.json`.

### Adding a C block

```sh
cd kernel/mod
tools/inject.py src/<file>.c <version> <bank> <address_hex> <Name> \
    [--pin SYM=ADDR ...] [--apply] [--replace]
```

`inject.py` compiles the file and links it at its real ROM address, so its
internal jumps and calls are right for where it lives. Externs the kernel
provides are given as pins. Before writing it checks that the block fits:
it must not run into another label or block, and every new byte must be
`$FF` free space. It reports the free bytes left after it. `--replace`
rebuilds an existing block of the same name in place. Without `--apply`
nothing is written.

A new block needs a `REGISTRY` entry in `port-mod.py`, or it is neither
rebuilt nor ported. A source must not hard-code a kernel address; use an
`extern` and a pin, so the port can translate it.

Two companions in `kernel/mod/tools`: `inject_bytes.py` places
hand-assembled bytes as a named block, and `patch_call.py` repoints a
`call` or `jp` operand to a new target.

### Assembly features

The features written in assembly have their own inject scripts, each run on
1.05e-0731 and then ported:

| Script | Feature |
|---|---|
| `scripts/inject-ezcfg.sh` | the settings module and everything that hooks into it (the largest; it also places most hand-assembled hooks) |
| `scripts/inject-font12.sh` | the 12px glyph tables, after editing a sheet |
| `scripts/inject-sgb.py` | Super Game Boy boot |
| `scripts/inject-skipboot.py` | skipping the boot ROM |
| `scripts/inject-fillrect.py`, `inject-fastdec.py` | the fast rectangle fill and decimal conversion |
| `scripts/inject-set-jump.py` | LEFT and RIGHT on the SET tab |

### Choosing a hook site

- Prefer replacing a tail `jp` or a `jp` to a bare `ret`. The hook inherits
  the stack frame untouched and its `ret` becomes the function's return, so
  there are no stolen instructions to replay. `patch_call.py --jp` is for
  this shape. A hook reached by `jp` must be stack-neutral and end in `ret`;
  an ordinary SDCC function without `__naked` qualifies.
- A `call` in the middle of a function has to replay whatever bytes it
  overwrote.
- A bare `call` or `jp` cannot cross ROMX banks. Code hooked from bank 8
  must live in bank 8 or bank 0; anything else goes through
  `FarCallTrampoline` ([kernel-size.md](kernel-size.md) has the stub bytes
  and the argument rule).
- Only a run of one repeated byte is free space. Tables of `ff 7f ff 7f`
  look empty in a hex dump and are data.
- Banks 10 to 15 were added by the mod: 10 to 14 hold code and 15 is empty
  ([kernel-size.md](kernel-size.md)). The stock banks are close to full.
- To find what draws something, break on `DrawGlyph` (`$2701`) and look at
  the caller: `scripts/debug/who-draws-row0-right.sbd` is an example.

## How the port works

The three kernels are the same program with code inserted or removed in a
few places, so `port-mod.py` moves the mod across mechanically
(`scripts/portmap.py` does the mapping).

- **Address map.** Each bank of both stock ROMs is decoded into a stream of
  opcodes, operands ignored, and the two streams are aligned. An address
  inside a matched run maps by offset. Try it:
  `scripts/portmap.py 1.05e-0731 1.04e 00:1344`.
- **C blocks** are recompiled at the same address with every pin translated
  through the map.
- **Hand-assembled blocks** are decoded and their absolute operands
  translated. `ld rr,nn` counts as a pointer only when `nn` is a label or
  injected code, so screen coordinates survive. Blocks ending in a string
  give their code length; pure data is copied as it is.
- **Hook sites**, every remaining byte that differs from stock, are widened
  to instruction boundaries and translated the same way. Before writing,
  the tool proves the target kernel has the same stock instructions at the
  translated site, and aborts if not.
- **Symbols.** `--sym` ports `kernel.sym` and `notes.json` through the same
  map.

The exceptions are tables at the top of `port-mod.py`, each entry with its
reason:

| Table | For |
|---|---|
| `SKIP_SITES` | a site that patches code the target does not have |
| `OVERRIDES` | an address the map cannot align, pinned by hand |
| `REMAP` | a range where the target repeats code and the map picks the wrong copy |
| `WRAM_SHIFT` | 1.04e's runtime WRAM sits 39 bytes below 1.05e's from `$D6CC` up |
| `TARGET_ONLY` | names for code only the target build has |
| `VERSION_TEXT` | the `K1.0xe-…` string each kernel shows |

`--check` compares a fresh port with the kernel already there, which makes
porting 0731 onto 0918 the regression test for the whole tool.

## The disassembly

```sh
scripts/regen-disasm.sh 1.05e-0731     # after editing kernel.sym or notes.json
```

It runs mgbdis over `kernel.gb` with the names from `kernel.sym`, adds the
comment blocks from `notes.json`, and assembles the result to prove it
still matches. The naming conventions and how to read a `bank:addr` are in
[MAPPING.md](MAPPING.md).

The stock 1.05e-0731 kernel is also being rebuilt from source, byte for
byte, in [kernel/1.05e-0731/stock](../kernel/1.05e-0731/stock/README.md).

## Trying it in SameBoy

The emulator runs stage1 and the kernel against a card image.

```sh
mkdir -p sd/root                   # put ROMs here; sd/ is ignored
scripts/make-sd-image.sh           # sd/card.img, with kernel/1.05e-0731/kernel.gb as ezgb.dat
scripts/run-sameboy-debug.sh       # plain boot; --model dmg for an original Game Boy
```

`EZGB_KERNEL_VERSION=1.04e` picks another kernel for the card. The card is
built with mtools, so its directory order is exactly what `sd/ORDER` lists,
which matters because the stock browser shows raw FAT order.
`run-sameboy-debug.sh --breakpoints` loads `scripts/debug/launch.sbd`, and
`--script` takes any other file from `scripts/debug/`.

`scripts/make-debug-build.py` builds a kernel with the debug screen
([debug-tab.md](debug-tab.md)).

## Releases

`patches/kernel/VERSION` holds the mod version `N.M`. It is changed by
hand, once per release, and never by a script:

```sh
$EDITOR patches/kernel/VERSION
scripts/stamp-mod-version.sh       # writes it into the HELP tab of every kernel, rebuilds, cuts patches
```

`stamp-mod-version.sh` ends by running `make-dist.sh`, which lays out
`dist/mod-N.M/` with each `.ips` and the patched kernel it produces, both
checked against the manifest. `dist/` is ignored.

Only patches are published, never a built kernel, an updater or a
bitstream. What goes on a release, how the firmware patches are made and
what a wrong patch does are in [distribution.md](distribution.md).
