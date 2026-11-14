# The game store is volatile

A launched game lives in the 8 MB pSRAM die of U9
([hardware-board.md](hardware-board.md)), not in flash. The kernel copies
the ROM from the SD card into it on every launch, and that copy cannot be
skipped: there is nothing nonvolatile to boot a game from, which is why the
Jr has no equivalent of the Omega's Mode B.

## The evidence

A probe read three places in the game store after a full launch of Pokemon
Crystal and a power cycle:

- After a fast power cycle, all three read back the exact file bytes.
- With a longer time off, bits fade toward `$FF`.
- After pulling the cart, everything reads `$FF`.

Charge decaying over time is what DRAM and pSRAM do, and flash cannot. A
cold read after a longer time off showed the fade in progress:

| Bank / offset | Probe read | File bytes |
|---|---|---|
| `0A` / `$28000` | `80C18180` | `CDF5310E` |
| `10` / `$40000` | `EFBEFF9E` | `F0D16FF0` |
| `20` / `$80000` | `FFF9FFFF` | `CD17403E` |

So any scheme that skips or shortens the copy rides on residual charge, and
one faded bit is a corrupted game. Stage1 also loads `ezgb.dat` over the
start of the same store at every power-on.

## Where the copy happens

The launch tail (`MenuDispatchAB_launchFarcalls`, `00:1569`; the full chain
is in [launch-trace.md](launch-trace.md)) sets up the game's configuration
and ends with a far call at `00:1623` to `RomLoad_CopyCmdWindowPoll_B4`
(`04:448f`). That routine opens the load command window (`$7F36 = $01`),
copies the 512-byte extent list from `$c0a0` to `$A000`, and installs the
WRAM stub that polls the FPGA while it streams the ROM from SD and then
fires `$7FE0 = $80`.

## An unused reset stub

Bank 4 has a complete "reset into whatever is loaded" routine that nothing
calls: `RomLoad_ResetIntoRom_B4` (`04:4180`), copied to WRAM and run by
`RomLoad_BuildAndRunReset_B4` (`04:41d2`). It unlocks, writes `$7F31 = 0`
and `$7F32 = 0`, sets the bank latches (`$2000 = 1`, `$3000 = 0`), and
fires `$7FE0 = $80`. It issues no load command and configures nothing about
the game, so it could only work as a warm reset within a powered session.

## Two lessons from the experiment

Wiring that stub into the last-ROM relaunch was tried and reverted. Two
things it taught about injecting code:

- SDCC emits a file's static functions ahead of its entry point, so the
  entry is not at the block's first byte unless it is the only function.
- The bank-0 cave after the last-ROM hooks ends at `$05b5`. A block that
  grows past it overwrites live code without any error at boot.
