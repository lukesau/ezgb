# Building the stock software from source

Everything EZ Flash shipped for the Jr builds from this repository and is
checked against the stock files, with none of them present:

| Piece | Source | Check |
|---|---|---|
| kernels 1.04e, 1.05e-0731, 1.05e-0918 | [kernel/stock](../kernel/stock/README.md): C, GBDK, FatFs | md5 of the stock kernel |
| stage1, FW4 and FW5-0918 | [stage1/decomp](../stage1/decomp/README.md): C, GBDK | md5 of the stock stage1 |
| the updater's program, FW4 and FW5-0918 | [stage0/updater](../stage0/updater/README.md): C, the kernel's libraries | md5 of the stock program |
| slot B, FW4 and FW5-0918 | [stage0](../stage0/README.md): Verilog, the PicoBlaze's two programs, stage1 | proved equivalent to stock's netlist |

The first three are byte for byte. Slot B is not: ISE maps and routes the
logic its own way, so the result is proved to be the same design instead
([stage0/ise](../stage0/ise/README.md)).

## The Game Boy side

```sh
stage1/decomp/tools/build-sdcc29.sh    # once: SDCC 2.9.0 into tools/sdcc-2.9.0
make                                   # three kernels, two stage1s, two updater programs
```

`make` fails unless every result has its stock md5.

| Tool | Checked with | For |
|---|---|---|
| SDCC 2.9.0 | the 2009 source release, built by `build-sdcc29.sh` | compiling the C: the compiler EZ Flash used, and the only one that gives their code |
| a current [SDCC](https://sdcc.sourceforge.net/) | 4.6.0 | `sdasgb`, `sdldgb` and `sdcpp`: 2.9.0's assembler, linker and preprocessor no longer build |
| [RGBDS](https://rgbds.gbdev.io) | 1.0.1 | laying out the kernel's banks, the header checksums |
| GNU make | 3.81 (warns about `&:` rules, builds correctly), 4.3 or newer is quiet | |
| Python 3, a C compiler | | the link scripts, building SDCC 2.9.0 |

`build-sdcc29.sh` fetches SDCC's source release from SourceForge, or takes
the tarball as its argument.

## Slot B

```sh
make stage0-stock BUILD_HOST=<build host>            # both firmwares, proved
PROVE=0 make stage0-stock BUILD_HOST=<build host>    # built, not proved: no file of EZ Flash's
make check BUILD_HOST=<build host>                   # everything on this page
```

The results are `fpga/ise/<fw>-stock-nopatch/proj/top.raw`, a slot B image
each. `stage0/tools/build-stage0.sh <fw> LABEL OUT.gb` also wraps one in the
from-source updater.

ISE runs on a Linux machine reached over ssh, the build host. It needs:

| On the build host | Where | For |
|---|---|---|
| Xilinx ISE 14.7 | `~/Xilinx/14.7/ISE_DS` ([toolchain.md](../stage0/docs/toolchain.md#ise-147)) | synthesis, place and route, bitgen: the last ISE with Spartan-3A |
| prjcombine at `7ab08a02` | `~/fpga/prjcombine` ([toolchain.md](../stage0/docs/toolchain.md#prjcombine)) | the bitstream database |
| this repo's `s3decode`, built | `~/fpga/s3decode` | decoding the result, to read stage1 and the PicoBlaze's programs back out |
| a blank design's bitstream | `~/fpga/blank.bit` ([toolchain.md](../stage0/docs/toolchain.md#baseline)) | the decode's baseline |

The proof runs on the machine with the checkout and needs:

| Locally | Checked with | For |
|---|---|---|
| [yosys](https://github.com/YosysHQ/yosys) | 0.70 | the equivalence proofs |
| Rust, `(cd stage0/tools/s3decode && cargo build --release)` | 1.85 or newer | exporting a bitstream as a netlist |
| prjcombine's database as `fpga/db/spartan3.zstd` | the same revision | |
| the official updaters in `tools/ezflashjr/official/` ([DEVELOPMENT.md](DEVELOPMENT.md#what-you-need)) | | stock's slot B, the thing proved against |

Simulating the design ([stage0/sim](../stage0/sim/README.md)) also takes
Icarus Verilog (13.0) or Verilator (5.052).

## What is not from found source

Three pieces are rebuilt from the stock bytes because no published source
has them. Each says so where it lives:

- the long math, `strcpy`, `memset` and `memcpy` the kernel, stage1 and the
  updater link ([kernel/stock/src/libasm.s](../kernel/stock/src/libasm.s),
  [stage1/decomp/asm](../stage1/decomp/asm/README.md)): probably EZ Flash's
- the Verilog, written from the decoded bitstream and proved against it
- the PicoBlaze's programs, disassembled listings that assemble back to the
  stock words
