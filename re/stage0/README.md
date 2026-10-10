# Stage0: the FPGA's own logic

Everything here is about the hardware the XC3S200A becomes once it has
loaded a bitstream: the fabric (bus decode, the `$7Fxx` register file, the
SD controller, pSRAM addressing, the wiring that makes the kernel show
"FW4") and the PicoBlaze soft CPU that sequences SD, ROM loads and the RTC.
None of it is Game Boy code. The Game Boy program the FPGA serves from its
block RAM at power-on is stage1: our source is [stage1/](../../stage1/README.md)
at the top of the repo, the stock ones disassembled are in [re/stage1](../stage1/README.md).

## The boot chain

| Step | What runs | Where it lives |
|---|---|---|
| slot A | the FPGA's first configuration: its PicoBlaze updates the boot tally, then reconfigures the FPGA from slot B (MultiBoot) | config flash `$00000`, never rewritten |
| slot B | the configuration the cart runs from then on: fabric, PicoBlaze program, and stage1 in BRAM | config flash `$40000`, written by the updater |
| stage1 | the Game Boy runs it from slot B's BRAM: splash, fast launch, loads the kernel | slot B's BRAM (source: [stage1/](../../stage1/README.md)) |
| kernel | the menu, loaded from `ezgb.dat` into pSRAM | SD card |

Slots A and B are both stage0: two hardware configurations of the same chip.

## Versions

The docs below cover every firmware release we have, comparing where they
differ (FW4 against FW5 0731 and 0918 in [docs/fw5.md](docs/fw5.md)).
Material that belongs to one release goes in a per-release directory, the
most recent release of each line:

| Release | PicoBlaze | Simulation |
|---|---|---|
| FW4 slot B | [picoblaze/fw4/](picoblaze/fw4/): both programs annotated (`.notes`) and listed (`.psm`) | [sim/](sim/README.md) runs the FW4 design |
| FW5 0918 | [picoblaze/fw5-0918/](picoblaze/fw5-0918/): bank 1 listing and port map, not annotated yet | to do |
| FW5 0731 | [picoblaze/fw5-0731/](picoblaze/fw5-0731/): bank 1 listing and port map | |
| FW5 slot A | [picoblaze/fw5-slota/](picoblaze/fw5-slota/): bank 1 listing and port map | |
| FW5 SGB beta | [picoblaze/fw5-sgb-beta/](picoblaze/fw5-sgb-beta/): bank 1 listing and port map | |

The listings come from `scripts/fpga/picoblaze-dis.py` over each bitstream's
program BRAMs (the FW4 ones with `-a` and the `.notes`, and `--check`
reassembles them to the BRAM contents). The bitstreams themselves are EZ
Flash's and stay local, in `fpga/`. The updater that writes slot B is
disassembled in [../updater](../updater/README.md).

## Docs

| Page | What it covers |
|---|---|
| [docs/bitstream.md](docs/bitstream.md) | what the decoded FW4 bitstream holds; the slot A/B difference |
| [docs/flash-map.md](docs/flash-map.md) | the 512 KB config flash byte by byte: slots, license record, boot tally |
| [docs/picoblaze.md](docs/picoblaze.md) | the PicoBlaze's two programs: SD, ROM loader, RTC, license check, slot A to B hand-over |
| [docs/design.md](docs/design.md) | the design mapped from the netlist: pins (GB bus, SD, config flash, pSRAM bus), clocks, registers, and the simulation |
| [docs/version-byte.md](docs/version-byte.md) | where the FW version byte comes from (wiring, not a stored value) |
| [docs/personalities.md](docs/personalities.md) | the `$7FC0` values the kernel uses to map the `$A000` window |
| [docs/fw5.md](docs/fw5.md) | the FW5 designs, and what 0918 changed over 0731 |
| [docs/toolchain.md](docs/toolchain.md) | prjcombine and `s3decode`/`s3trace`/`s3patch`: flags and output |
| [docs/custom-logic.md](docs/custom-logic.md) | historical: the original plan for running our own logic |

## Tools and notes

| Directory | Contents |
|---|---|
| [picoblaze/](picoblaze/) | annotations for both PicoBlaze programs (`X3Y29` bank 1, `X3Y25` bank 2), merged into the disassembly by `scripts/fpga/picoblaze-dis.py` |
| [sim/](sim/README.md) | the netlist exported to Verilog, primitive models, SPI flash / SD card / pSRAM models, testbenches, and the scripts that mapped the pins and the pSRAM address bus |
| [netlist/](netlist/README.md) | research scripts over the `s3trace` netlist (constant bytes, decode paths) |

The bitstream tools themselves (`s3decode`, `s3trace`, `s3patch`, `s3pins`)
stay in `scripts/fpga/s3decode`, because the stage1 build uses them too.
