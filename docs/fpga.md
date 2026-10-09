# FPGA docs

The Jr's FPGA (a Spartan-3A XC3S200A) work: decoding EZ Flash's bitstream,
the PicoBlaze firmware inside it, and our own stage1 written to the cart
through a relabelled stock updater.

## Reading order

1. [fpga-setup.md](fpga-setup.md): set up every tool from nothing and build
   an updater end to end. [fpga-toolchain.md](fpga-toolchain.md) is the
   reference for each tool's flags and output.
2. [fpga-bitstream.md](fpga-bitstream.md): what the decoded FW4 bitstream
   holds; stage1 in BRAM, the slot A/B difference.
3. [fpga-flash-map.md](fpga-flash-map.md): the 512 KB config flash, byte by
   byte: slots, licence record, boot tally.
4. [fpga-picoblaze.md](fpga-picoblaze.md): the soft CPU's two programs: SD,
   ROM loader, RTC, licence check, slot A to slot B hand-over.
5. [fpga-fw5.md](fpga-fw5.md): the FW5 designs, and what 0918 changed over
   0731.
6. [fpga-stage1.md](fpga-stage1.md): stock stage1 disassembled, our rewrite,
   fast launch, hardware status.
7. [fpga-cgb.md](fpga-cgb.md): the first patched firmware (CGB flag, boot
   splash) and how an updater is built.
8. [fpga-version.md](fpga-version.md): where the FW version byte comes from
   (wiring, not a stored value).
9. [fpga-design.md](fpga-design.md): the design mapped from the netlist:
   pins, clocks, registers. Work in progress.

Also:

- [stage1/README.md](../stage1/README.md): the stage1 source tree, its
  version file and build options.
- [scripts/fpga/netlist/README.md](../scripts/fpga/netlist/README.md): the
  research scripts over the `s3trace` netlist.

Older pages, kept as they were with notes on what changed:
[fpga-ace.md](fpga-ace.md) (the original replace-over-JTAG plan) and
[fpga-personalities.md](fpga-personalities.md) (the kernel's `$7FC0` values).
Hardware and flash recovery: [hardware-board.md](hardware-board.md).

## Terms

| Term | Meaning |
|---|---|
| **stage1** (level 1) | the Game Boy program the cart shows at power-on (EZ-FLASH, LOADING), which loads the kernel. It lives in FPGA block RAM, so it ships inside the bitstream |
| **kernel** (`ezgb.dat`) | the menu/file browser on the SD card that stage1 loads. The kernel mod in the rest of this repo patches it |
| **slot A** | the bitstream at config flash `$00000`, which the FPGA loads at power-on. On FW4 its only extra job is handing over to slot B; it is the fallback image |
| **slot B** | the bitstream at `$40000`, the one that normally runs, and the only one an FW4 updater writes |
| **FW numbers** | EZ Flash's FPGA firmware releases (FW4, FW5), each a complete new design. The cart reports the number through `$7FC0=$04`; the kernel's HELP tab shows it |
| **mod versions** | our releases. The kernel mod is `MOD n.m` (`patches/kernel/VERSION`); stage1 has its own, shown as `FW<n>-MOD <m>` (`stage1/VERSION`) |
| **updater** | `Update_FW4.gb`, a program launched from the kernel that writes its payload to slot B. Ours are the stock file with the payload and label swapped |
