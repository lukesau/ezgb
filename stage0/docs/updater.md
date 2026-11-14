# The firmware updater

`Update_FW4.gb` and `Update_FW5_*.gb` are Game Boy programs, launched from
the kernel like a game, that write a new FPGA design to the cart's config
flash. The FW4 one is disassembled in [fw4/updater/](../fw4/updater/)
(`kernel.sym` and the generated `disassembly/`). The updaters themselves are
EZ Flash's and stay local. Building our own from one is in
[setup.md](setup.md).

## What is in the file

`Update_FW4.gb` is 182,284 bytes:

| Offset | Contents |
|---|---|
| bank 0 | the updater program |
| bank 1 | a few routines that are copied to WRAM; otherwise empty |
| `$8000` on | the bitstream it writes: 149,516 bytes, with the sync word `aa 99 30 a1` at `$8020` |

The bitstream is byte for byte what ends up in the config flash's slot B
([flash-map.md](flash-map.md)). The FW5 updaters are 331,800 bytes and
carry two bitstreams, at `$8000` and `$2C80C`; only the first is written.

The updater runs from the game store with its payload embedded and never
reads the SD card.

## How it writes

Every write to the flash goes through one register, `$7FD2`, inside the
unlock and commit envelope ([design.md](design.md#unlock-and-commit)):

| Address | Does |
|---|---|
| `00:153a` `FpgaSetPersonality` | `$7FC0 = arg`. The flash loop is bracketed by `$7FC0 = $05` and `$7FC0 = $00` |
| `00:12b0` | stages one block: maps the command window (`$7F36 = 1`), copies `$110` bytes to `$A000`, unmaps |
| `00:124b` | `$7FD2 = $01`: begin a flash operation |
| `01:4000` | `$7FD2 = $01`, then reads `$A000` until it is zero, then `$7FD2 = $00` |
| `01:4076` | copies that routine to `$D000` and calls it there, since the ROM window is busy during the operation |
| `00:1271` | `$7FD2 = $00`: end the operation |

Before each block, `$7F31 = $00` and `$7F32 = $80` set the address. The
PicoBlaze does the actual SPI work
([picoblaze.md](picoblaze.md)): the file's bitstream goes to flash offset
`$040000` on, a page at a time.

### The poll must run to completion

`$7FD2 = $01` starts a flash operation, and the updater waits for `$A000`
to read zero before it writes `$00`. A probe ROM that wrote `$01`, sampled
`$A000` once and wrote `$00` cut an operation off, and the cart's FPGA
never configured again until its flash was reprogrammed with a hardware
programmer
([hardware-board.md](../../docs/hardware-board.md#recovering-a-cart-whose-fpga-no-longer-configures)).

**Writing `$7Fxx` is never a read-only experiment.** Replicate the whole
protocol, handshakes included, or do not issue the write.

## What it does not do

- **No checksum, no read-back, no version check.** Whatever bitstream is
  in the file is written. That is what makes a patched updater possible,
  and what makes a wrong one dangerous ([distribution.md](../../docs/distribution.md#wrong-patch)).
- **It writes slot B only.** Slot A, the license record and the boot tally
  are untouched, which is why a bad slot B can be recovered from: the cart
  falls back to slot A and the right updater can be run again.
- **It never touches the NOR dies** in U4 and U9. Nothing in it issues a
  flash command sequence to the `$A000` window.

The version on its screen is a fixed string, `Update to ver:4`, at `$11D2`.
It does not read the cart's version.

## What a launched ROM can reach

Probed on hardware with small ROMs launched from the kernel:

- A read of `$A000` that returns `$46` means nothing answered. `ld b,(hl)`
  is opcode `$46`, and the floating bus hands back the last byte driven.
- `$A000`-`$BFFF` is live and writable from a launched ROM, but only after
  the standard cart-RAM enable (`$0A` to `$0000`-`$1FFF`). The kernel never
  writes that enable; stage1 hands it an open window.
- Whether the paged control interface (unlock, `$7FC0`, the `$4000` page
  latch) works from a launched ROM was not established.
