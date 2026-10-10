# Debug screen (debug builds only)

A page of hardware readouts after HELP, for investigating the cart. Release
kernels don't have it; build one when it's needed:

```bash
scripts/make-debug-build.py 1.05e-0918 --install /Volumes/EZGB_FW4
```

That writes `dist/debug/ezgb-mod-N.M-debug-for-<ver>.dat` from
`re/kernel/<ver>/kernel.gb` (the mod build, left untouched) and, with `--install`,
copies it to the card as `ezgb.dat`. HELP then reads `MOD N.MDBG`, and SELECT
on HELP opens the debug screen instead of returning to the browser; SELECT
there goes on to the browser. The tab strip stays on HELP.

## The page

Built on the fly from a snapshot taken on entry ("READING PSRAM..." for a few
seconds while it reads 40 KB); UP/DOWN scroll once it has more than 16 lines.

| Lines | Meaning |
|---|---|
| `PSRAM PAGE SUMS` / `P00:` `P01:` `P10:` `P11:` | 16-bit sums of pSRAM pages `$00`, `$01` (game save RAM), `$10` (the probe page) and `$11` (kernel meta) |
| `P10 FIRST 8 BYTES` | page `$10`'s first bytes |
| `P10 VALUES:` | how many of the 256 byte values occur in page `$10`: random power-on contents give about 250+, a cleared page 1 |
| `P10 PATTERN:` | `OK` = the test pattern is intact, `NONE` = not there, `BAD n` = n bytes differ |
| `A:WRITE P10 PATTERN` | A fills page `$10` with the pattern. Refused (`P10 ALIAS:NO WRITE`) when page `$10` matches `$00`, `$01` or `$11`, which would mean it is the same memory |
| `B:ALIAS TEST P20/3F` / `P20=P00:` / `P3F=P1F:` | B checks whether the page latch is 5 bits (below). `--` until B is pressed |
| `SGB BOOT P11:A400` | the SGB BOOT record and whether it reads as on ([sgb-boot.md](sgb-boot.md)) |
| `BOOT A REGISTER:` | the A register KernelEntry saved at boot |

## Page-latch alias test (B)

Simulating the FW4, FW5-0731 and FW5-0918 bitstreams found only 5 bits of the
`$4000` page latch reach the pSRAM: pages `$20-$3F` would be `$00-$1F` again
(`re/stage0/docs/firmware-diff.md`, "Save pages from the kernel", on the
`bitstream-re` branch, and the correction in [psram-page-map.md](psram-page-map.md)
there). B checks that on the cart, for `$20` against `$00` and `$3F` against
`$1F`, without losing data:

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

SameBoy models 64 pages (`EZJR_SRAM_BANKS`), so it shows `NO ALIAS` for both;
a scratch build with 32 pages shows `ALIAS` for both, and neither shows `!RST`.

## Findings (FW4 Jr, GBC, no coin cell, 2026-10-08)

- Page `$10` is real, independent storage: the pattern read back intact and
  its sum never matched another page's. Nothing the kernel or stage 1 does
  between boots touched it. See [psram-page-map.md](psram-page-map.md).
- `BOOT A REGISTER: E4`: the Jr's boot leaves the palette value in A, not the
  model ID the boot ROM puts there, so A can't tell DMG, GBC and SGB apart.
- Without a coin cell the pSRAM keeps its contents for about a minute out of
  the console; one reading showed 101 pattern bytes changed and the SGB record
  `01 FE` read back as `00 FF`, then a longer wait lost everything.

## Code

`kernel/src/debug_tab.c` (bank 4, `04:7400` when free, `04:6cca` in mod 5.4)
and `DbgTabHook` (bank 0, `00:02c4` when free): far-call the screen, delay,
`jp FileBrowserEntry`. HELP's exit (`00:1288` in 1.05e, `00:127c` in 1.04e)
keeps its delay and jumps to the hook instead of the browser, and the screen
itself starts with `DrawMenuTabs(3)` (clear the pane, keep the strip). That
keeps the hook at 19 bytes: since `CgbInit` took `00:0259` (mod 5.3), 1.05e's
largest free run in bank 0 is 31 bytes, and the old 41-byte hook no longer fit. Addresses are written for
1.05e-0731 and matched into other builds with `scripts/portmap.py`; the script
checks the exit's bytes before patching.
