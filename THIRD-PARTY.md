# Code in this repository that is not ours

The repository is AGPLv3 ([LICENSE](LICENSE)). That covers what this
project wrote: the notes, the tooling, the mod, our stage1, the readable
Verilog. The stock software also links other people's code, and building
it from source means having that code here. Each piece keeps its license.

| Piece | Where | From | License |
|---|---|---|---|
| GBDK's runtime, library modules and headers | `kernel/stock/gbdk/`, `stage1/decomp/gbdk/` | GBDK 2.96a, with EZ Flash's edits marked `ezflash:` | GPLv2 with a linking exception (`LICENSE_GPLV2_LE` in each folder; GBDK-2020 relicensed the historical library under it) |
| SDCC's library | `kernel/stock/sdcclib/`, `stage1/decomp/sdcclib/` | SDCC 2.9.0 `device/lib`, unchanged but for `div.s` | GNU Library GPL v2 or later (the C files' headers); [LICENSE-LGPL-2.1](LICENSE-LGPL-2.1) is its next version |
| FatFs | `kernel/stock/src/ff.c`, `ff.h`, `ffconf.h`, `integer.h`, `diskio.h`, `option/ccsbcs.c` | ChaN's FatFs R0.11a, with EZ Flash's edits marked `ezflash:` | ChaN's FatFs license (in `ff.c`'s header): source redistributions keep the notice |
| The SD card controller | `stage0/fw4/rtl/sd_*.v`, `stage0/fw5-0918/sd_*.v` | Marek Czerski's [SD card controller](https://github.com/mczerski/SD-card-controller) (2013), after Adam Edvardsson's (2009); the FIFO is Rudolf Usselmann's generic FIFO (2000-2002). Rewritten here from the bitstream with the source beside it | GNU LGPL 2.1 or later ([LICENSE-LGPL-2.1](LICENSE-LGPL-2.1)); the FIFO under its BSD-style notice (each module's header) |
| The PicoBlaze | `stage0/fw4/rtl/picoblaze.v` | Xilinx's KCPSM3, by Ken Chapman. Written here from the bitstream, keeping KCPSM3's structure register for register; none of Xilinx's source is in the repository | Xilinx's KCPSM3 terms allow its use in Xilinx devices |
| `hardware.inc` | `kernel/*/disassembly/`, `stage1/*/disassembly/` | the gbdev hardware definitions, as mgbdis writes them | public domain (CC0) |
| The Tamzen font | `kernel/mod/font12/` | Tamzen, after Tamsyn | `kernel/mod/font12/LICENSE-Tamzen` |

## EZ Flash's code

The rest of the stock software is EZ Flash's: the kernel's and stage1's C,
the updater, the PicoBlaze's two programs, the FPGA design, and the library
math no published source has (`kernel/stock/src/libasm.s`,
`stage1/decomp/asm/`). EZ Flash published no source for any of it. What is
here was written from their binaries: C that compiles to the same bytes,
Verilog proved equivalent to their bitstream, listings that assemble to the
same words. It is here for study and repair of the hardware, and the AGPLv3
does not relicense it.

EZ Flash's binaries themselves are not in the repository: no kernel, no
updater, no bitstream. The builds check against md5s, and the tools that
need a stock file read it from the ignored `tools/` and `fpga/` folders.

The GBDK, SDCC and FatFs code is in EZ Flash's binaries too, under the
licenses above.
