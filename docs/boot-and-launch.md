# Boot and launch

How the stock kernel starts, and how it launches a game. Addresses are
1.05e-0731's.

## Before the kernel

The kernel is not installed on the cart. Stage1, the Game Boy program in
the FPGA bitstream ([stage1/](../stage1/README.md)), reads `/ezgb.dat` from
the SD card at every power-on, loads it into the game store and jumps to
it. `Update_FW*.gb` is a different thing: a game launched from the menu
that rewrites the FPGA firmware and needs a power cycle afterwards.

## Kernel entry

`$0100` is `nop` / `jp $0150` in stock (the mod's goes through `$0020`
first, for the Super Game Boy, [sgb-boot.md](sgb-boot.md)). `KernelEntry`
(`00:0150`) is the GBDK runtime start
([crt0.s](../kernel/1.05e-0731/stock/gbdk/crt0.s)):

```text
KernelEntry
  di
  clear WRAM, OAM and HRAM; SP = $E000
  save A to $D6C9; ROM bank 1
  LcdOff
  copy the OAM DMA stub to HRAM $FF80
  install the VBlank and serial interrupt callbacks
  BGP = $E4, LCDC = $C0, IE = $09, sound off
  BootUnpackWramTables     ; 01:68b6: RLE tables into WRAM
  BatteryCheck             ; 00:1835: BATTERY DRY when $A201 is not $88
  SdMenuMain               ; 00:0de4: never returns
    Micro SD initial OK! / error
    the save backup, when one is pending
    FileBrowserEntry       ; 00:0f8d: the browser loop
```

The `halt` loop after the call is dead code: `SdMenuMain` stays in the
browser. The backup branch is in [psram-map.md](psram-map.md#the-save-backup).

## Launching a game

A on a `.gb` or `.gbc` file reaches `MenuDispatchAB_launchFarcalls`
(`00:1569`), a run of far calls that read the ROM's header, set up the
FPGA for it, and hand over:

| Far call at | Target | Does |
|---|---|---|
| `$1569` | `LoaderPrepPath` `01:482b` | builds the path |
| `$1574` | `RomLoaderMain` `01:5e14` | reads and checks the header |
| `$15a5` | `01:5163` | opens the save and restores an RTC game's clock |
| `$15b2` | `LaunchSetup` `01:58b0` | walks the file's cluster chain into the load command table |
| `$15bf` | `04:41e7` | `$7FC0`, the ROM page |
| `$15d9` | `04:4160` | `$7F37`, the MBC type |
| `$15e6` | `01:480b` | `$7FD4`, half of FW5's fast-load key |
| `$15f5` | `04:43ec` | `$7FC4` |
| `$1604` | `04:4207` | `$7FC1` and `$7FC2`, the size mask |
| `$160d` | `04:446e` | `$7FC3` |
| `$1623` | `RomLoad_CopyCmdWindowPoll_B4` `04:448f` | the load itself |

The last one opens the load command window (`$7F36 = $01`), copies the
table into it, and installs a stub in WRAM at `$D1xx` that starts the load
(`$7F36 = $03`), polls the FPGA while it streams the ROM from the card
into the game store, and then writes `$7FE0 = $80`, which resets the
console into the game. The registers are in
[design.md](../stage0/docs/design.md#registers-written-by-the-game-boy).

Because those final writes run from WRAM, a breakpoint in bank 4 does not
catch them. Watch the registers instead:

```
watch $7f36
watch $7fe0
```

`scripts/debug/launch.sbd` has the launch path's breakpoints, and
`scripts/debug/farcall.sbd` logs every far call
([DEVELOPMENT.md](DEVELOPMENT.md#trying-it-in-sameboy)).

## The load command table

`LaunchSetup` builds 512 bytes at `$c0a0`, 128 little-endian 32-bit words:

| Index | Content |
|---|---|
| `[0]` | 0 |
| `[1..]` | extent pairs `{start LBA, end}`, one per contiguous run of clusters. The last pair's `end` is `$FFFFFFFF`, meaning the rest of the file, and the word after it is 0 |
| `[$7C]` | the file size in bytes |
| `[$7D]` | 1 |
| `[$7E]` | sectors per cluster |

**`end` is a running total, not a count**: the number of file sectors up to
the end of that extent, counted from the start of the file. The cluster
counter is zeroed once before the walk and never reset. For the first
extent the total equals the count, so the two readings differ only from
the third extent on. daid's `Protocol.md` describes it as a count, which is
wrong for a file in three or more fragments. Stock stage1 builds the same
table for `ezgb.dat`.

61 extents and the closing 0 fit before `[$7C]`. Stock does not check the
count, so a file in more fragments than that overruns the table.
