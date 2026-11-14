# The FPGA and the firmware

The Jr's FPGA work is in two folders, one per boot stage:

- **[stage0/](../stage0/README.md)** is the FPGA's logic: EZ Flash's
  bitstreams decoded, the PicoBlaze's programs, the design rewritten as
  readable Verilog, and the tools to patch a bitstream and build an
  updater. Start with its README, then
  [setup.md](../stage0/docs/setup.md) to build something.
- **[stage1/](../stage1/README.md)** is the Game Boy program the FPGA
  serves at power-on: ours from source
  ([design](../stage1/docs/design.md)) and EZ Flash's disassembled
  ([stock.md](../stage1/stock.md)).

The board, the config flash and how to recover a cart are in
[hardware-board.md](hardware-board.md).

## Terms

| Term | Meaning |
|---|---|
| **stage0** | the FPGA's logic once a bitstream is loaded: fabric, PicoBlaze and its firmware. Slots A and B are both stage0 |
| **stage1** (level 1) | the Game Boy program the cart shows at power-on (EZ-FLASH, LOADING), which loads the kernel. It lives in FPGA block RAM, so it ships inside the bitstream |
| **kernel** (`ezgb.dat`) | the menu/file browser on the SD card that stage1 loads. The kernel mod in the rest of this repo patches it |
| **slot A** | the bitstream at config flash `$00000`, which the FPGA loads at power-on. On FW4 its only extra job is handing over to slot B; it is the fallback image |
| **slot B** | the bitstream at `$40000`, the one that normally runs, and the only one an FW4 updater writes |
| **FW numbers** | EZ Flash's FPGA firmware releases (FW4, FW5), each a complete new design. The cart reports the number through `$7FC0=$04`; the kernel's HELP tab shows it |
| **mod versions** | our releases. The kernel mod is `MOD n.m` (`patches/kernel/VERSION`); stage1 has its own, shown as `FW<n>-MOD <m>` (`stage1/VERSION`) |
| **updater** | `Update_FW4.gb`, a program launched from the kernel that writes its payload to slot B. Ours are the stock file with the payload and label swapped |
