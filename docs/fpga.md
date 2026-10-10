# FPGA docs

The Jr's FPGA (a Spartan-3A XC3S200A) work: decoding EZ Flash's bitstream,
the PicoBlaze firmware inside it, and our own stage1 written to the cart
through a relabelled stock updater.

The work splits by boot stage, both under `re/`. **Stage0** is the FPGA's
own logic: fabric, PicoBlaze and its firmware, bitstream and config flash
([re/stage0](../re/stage0/README.md) has the boot chain and an index).
**Stage1** is the Game Boy program the FPGA serves from block RAM at
power-on: our source in [re/stage1](../re/stage1/README.md), the stock one
disassembled in [re/stage1-fw4](../re/stage1-fw4/).

## Reading order

1. [fpga-setup.md](fpga-setup.md): set up every tool from nothing and build
   an updater end to end. [toolchain.md](../re/stage0/docs/toolchain.md) is
   the reference for each tool's flags and output.
2. Stage0, in the order its [README](../re/stage0/README.md) lists: the
   bitstream, the config flash, the PicoBlaze, the design and simulation.
3. [fpga-stage1.md](fpga-stage1.md): stock stage1 disassembled, our rewrite,
   fast launch, hardware status.
4. [fpga-cgb.md](fpga-cgb.md): the first patched firmware (CGB flag, boot
   splash) and how an updater is built.
5. [updater-flash-write.md](updater-flash-write.md): how the stock updater
   writes slot B.

Hardware and flash recovery: [hardware-board.md](hardware-board.md).

## Terms

| Term | Meaning |
|---|---|
| **stage0** | the FPGA's own logic once a bitstream is loaded: fabric, PicoBlaze and its firmware. Slots A and B are both stage0 ([re/stage0](../re/stage0/README.md)) |
| **stage1** (level 1) | the Game Boy program the cart shows at power-on (EZ-FLASH, LOADING), which loads the kernel. It lives in FPGA block RAM, so it ships inside the bitstream |
| **kernel** (`ezgb.dat`) | the menu/file browser on the SD card that stage1 loads. The kernel mod in the rest of this repo patches it |
| **slot A** | the bitstream at config flash `$00000`, which the FPGA loads at power-on. On FW4 its only extra job is handing over to slot B; it is the fallback image |
| **slot B** | the bitstream at `$40000`, the one that normally runs, and the only one an FW4 updater writes |
| **FW numbers** | EZ Flash's FPGA firmware releases (FW4, FW5), each a complete new design. The cart reports the number through `$7FC0=$04`; the kernel's HELP tab shows it |
| **mod versions** | our releases. The kernel mod is `MOD n.m` (`patches/kernel/VERSION`); stage1 has its own, shown as `FW<n>-MOD <m>` (`re/stage1/VERSION`) |
| **updater** | `Update_FW4.gb`, a program launched from the kernel that writes its payload to slot B. Ours are the stock file with the payload and label swapped |
