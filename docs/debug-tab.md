# Debug screen (debug builds only)

A page of hardware readouts after HELP, for investigating the cart. Release
kernels don't have it; build one when it's needed:

```bash
scripts/make-debug-build.py 1.05e-0918 --install /Volumes/EZGB_FW4
```

That writes `dist/debug/ezgb-mod-N.M-debug-for-<ver>.dat` from
`kernel/<ver>/kernel.gb` (the mod build, left untouched) and, with `--install`,
copies it to the card as `ezgb.dat`. HELP then reads `MOD N.MDBG`, and SELECT
on HELP opens the debug screen instead of returning to the browser; SELECT
there goes on to the browser. START on HELP goes back to the browser as in a release build; START on the debug screen is still the flash dump. The tab strip stays on HELP.

## The page

Built on the fly from a snapshot taken on entry ("READING PSRAM..." for a few
seconds while it reads 40 KB); UP/DOWN scroll once it has more than 16 lines.

| Lines | Meaning |
|---|---|
| `BOOT REGS:` | where the registers the jump hands over came from: `STAGE1` (the record, [skip-boot-rom.md](skip-boot-rom.md#boot-registers)), `STOCK S1` or `OLD S1` (the kernel's fallback values) |
| `AF:` `BC:` / `DE:` `HL:` | `BOOT_REGS`, the values themselves |
| `CONSOLE:` | what those mean: `DMG`, `DMG0`, `POCK`, `SGB`, `SGB2`, `GBC`, `GBA`. `UNKNOWN` without the record |
| `PALETTE:` | `CGB MODE` or `LOCKED` (`PAL_LOCKED`: a DMG, or a color console in compatibility mode) |
| `DMG JUMP:` | `YES` or `NO`: whether a non-color game may jump on the DMG family (`NO_DMG`, or the `SGB BOOT` record under stock stage1). `BOOTROM=1` when that turns off every jump |
| `PSRAM PAGE SUMS` / `P00:` `P01:` `P10:` `P11:` | 16-bit sums of pSRAM pages `$00`, `$01` (game save RAM), `$10` (the probe page) and `$11` (kernel meta) |
| `P10 FIRST 8 BYTES` | page `$10`'s first bytes |
| `P10 VALUES:` | how many of the 256 byte values occur in page `$10`: random power-on contents give about 250+, a cleared page 1 |
| `P10 PATTERN:` | `OK` = the test pattern is intact, `NONE` = not there, `BAD n` = n bytes differ |
| `A:WRITE P10 PATTERN` | A fills page `$10` with the pattern. Refused (`P10 ALIAS:NO WRITE`) when page `$10` matches `$00`, `$01` or `$11`, which would mean it is the same memory |
| `B:ALIAS TEST P20/3F` / `P20=P00:` / `P3F=P1F:` | B checks whether the page latch is 5 bits (below). `--` until B is pressed |
| `SGB BOOT P11:A400` | the SGB BOOT record and whether it reads as on ([sgb-boot.md](sgb-boot.md)) |
| `KERNEL ENTRY A` | the A register KernelEntry saved at boot. `$E4` on every console: stage1's last write, not the boot ROM's value |
| `START:DUMP FLASH` / result / `DNA:` | START dumps the config flash to `/FLASH.BIN` and the Device DNA to `/DNA.BIN`; needs the flash-read patch in slot B ([flash-dump.md](flash-dump.md)) |

## Page-latch alias test (B)

Simulating the FW4, FW5-0731 and FW5-0918 bitstreams found only 5 bits of the
`$4000` page latch reach the pSRAM: pages `$20-$3F` would be `$00-$1F` again
([firmware-diff.md](../stage0/docs/firmware-diff.md#save-pages-from-the-kernel),
[psram-page-map.md](psram-page-map.md)). B checks that on the cart, for `$20`
against `$00` and `$3F` against `$1F`, without losing data:

1. With interrupts off, read the 4 bytes at `$BFFC` (past the end of most
   games' saves) in the low page and in the high page.
2. Write their complement through the high page, then read the low page.
3. Write the high page's bytes back, then the low page's, and read both back.

| Result | Meaning |
|---|---|
| `ALIAS` | the low page took the sentinel: `$20` is `$00` (`$3F` is `$1F`), the latch is 5 bits |
| `NO ALIAS` | the low page kept its bytes and the high page held the sentinel: separate memory |
| `ODD` | anything else, e.g. the high page doesn't hold what was written |
| `!RST` after it | the bytes read back after step 3 differ from the originals |

SameBoy's stub models 32 pages and shows `ALIAS` for both.

## What it has shown on hardware

- **The page latch is 5 bits.** `ALIAS` on both lines on an FW5 cart, as
  simulated: 32 pages, and page `$20` up alias onto them
  ([psram-page-map.md](psram-page-map.md)).
- **Page `$10` is independent, battery-backed storage.** The pattern read
  back `OK` after 30 minutes off with the coin cell in, and nothing the
  kernel or stage1 does between boots touches it.
- **Without a coin cell the save pSRAM keeps its contents for about a
  minute** out of the console, then loses everything: game saves, the
  last-ROM record and the SGB setting.
- **`KERNEL ENTRY A` is `E4`** on FW4 and FW5. Stage1 leaves the value of
  its last register write in A, so A cannot tell consoles apart.
- **The boot registers** stage1 records, as read on two consoles (both
  match SameBoy; DMG, Pocket and SGB are unread on hardware):

| Console | `AF` | `BC` | `DE` | `HL` |
|---|---|---|---|---|
| GBA SP | `1100` | `0100` | `FF56` | `000D` |
| GBC | `1180` | `0000` | `FF56` | `000D` |

## Code

[debug_tab.c](../kernel/mod/src/debug_tab.c), in bank 12, and `DbgTabHook`
in bank 0: far-call the screen, delay, `jp FileBrowserEntry`. HELP returns
with the pad in C, so its exit (`00:1288` in 1.05e) becomes
`bit 7,c; jp nz,FileBrowserEntry; jp DbgTabHook`: START goes to the browser
and SELECT to the debug screen. The screen starts with `DrawMenuTabs(3)`,
which clears the pane and keeps the strip. The script places the hook in
each build through `scripts/portmap.py` and checks the exit's bytes before
patching.
