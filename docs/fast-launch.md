# Fast launch

Power on straight into a game, without the browser. Hold START at power-on
to get the browser instead. The setting is on the cart's SET tab
([set-tab.md](set-tab.md)) and in `EZGB.CFG`
([ezgb-cfg.md](ezgb-cfg.md)). Addresses are 1.05e-0731's.

## What triggers it

In this order:

1. **Disabled.** A `FLAUNCH=` value that begins with `#` turns fast launch
   off: no trigger below applies and the card boots to the browser. The
   path after the `#` is kept, so enabling it again restores the game. This
   is what unticking FAST LAUNCH on the SET tab writes.
2. **The configured game.** `FLAUNCH=` in `/EZGB.CFG` is the ROM's path. It
   may be anywhere on the card, as `/Pokemon/Blue.gb`.
3. **A lone ROM.** If the card's root holds exactly one real file and it is
   a `.gb` or `.gbc`, that file is launched, with nothing configured. The
   count ignores kernels (`*.dat`), `EZGB.CFG`, `FLAUNCH.CFG`, dot-files and
   folders. Only the root is looked at.

## Who launches

| Firmware | Configured game | Lone ROM |
|---|---|---|
| stock stage1 | the kernel | the kernel |
| our stage1 ([stage1/](../stage1/README.md)) | stage1 itself, without loading the kernel ([stage1 design](../stage1/docs/design.md)) | the kernel |

**Canceling.** The kernel reads START when it starts its scan. Our stage1
watches START from power-on until the launch is decided, shows `HOLD START
TO CANCEL` on a fast-launch boot, and tells the kernel about a cancel
through the `"S1"` mark in pSRAM ([psram-map.md](psram-map.md#marks-from-stage1)),
so the kernel does not then launch the game itself.

## In the kernel

| Block | Where | Does |
|---|---|---|
| `fastlaunch_boot` | `00:0490`, [fastlaunch_boot.c](../kernel/mod/src/fastlaunch_boot.c) | The hook. It sits over the browser's sort call at `00:102f`, before the first page is painted, so a fast-launch card never flashes the browser. It runs once a boot (`$DBFF`): sort, scan, launch. With no trigger it returns and the browser paints |
| `FastLaunchScan` | `02:4500`, [fastlaunch.c](../kernel/mod/src/fastlaunch.c), through `FarCallScan` `00:0400` | Applies the triggers and leaves the ROM's full path in `$c4a4`, or leaves it empty |
| `fastlaunch_do_launch` | `00:0420`, [fastlaunch_do_launch.c](../kernel/mod/src/fastlaunch_do_launch.c) | Launches the path through the stock START-overlay relaunch |

[fastlaunch_hook.c](../kernel/mod/src/fastlaunch_hook.c) (`00:0460`) is an
earlier hook that ran after the first paint. It is still built but nothing
calls it.

### The launch

`fastlaunch_do_launch` reuses `LastRomRelaunch` (`00:1344`), the routine
the START overlay uses to start the last game ([last-rom.md](last-rom.md)).
The overlay's drawing step does two things the load depends on, so the
launch does them itself first:

- `SetFpgaPage($00)`, for the directory traversal
- zeroing the path buffer at `$c2a6` and seeding it with `/`, so a nested
  path is NUL-terminated at any depth

Then it finds the basename, rebuilds the stack slot the relaunch reads, and
jumps to `$1344`.

## Rules the scan follows

These apply to any injected code that reads the card.

**Select the SD window before every read.** SD sector reads need
`$7FC0 = $00`, and the disk routine does not set it: the caller does. The
browser rests at `$7FC0 = $03`, the pSRAM record window. A sector read
under `$03` reads the wrong window and wedges the SD controller, which
breaks every later operation. The scan selects `$00` before each
`f_opendir` and `f_readdir` and restores `$03` on exit (`FarCallSetPage`,
`02:43ac`). SameBoy's stub ignores `$7FC0`, so this fails only on hardware.

**`f_open` takes 8.3 names only.** This FatFs resolves long names in
`f_readdir` but rejects them in `f_open`. That is why the settings file is
`EZGB.CFG`. Its contents may still name a ROM with a long name or in a
folder: the launch walks the directories.

**A path passed to FatFs must be in WRAM.** `f_open` runs in bank 6, so a
pointer to a string in another bank's ROM reads the wrong bank.

**No stack arguments across a far call** unless the callee pads for them
([shims.md](../kernel/mod/src/shims.md)). The scan returns its result in a
fixed WRAM buffer.

### FatFs from injected C

Each primitive has a bank-0 thunk, so injected C pins the label and calls
it. `FRESULT` comes back in `E`, and the mode flags are the standard FatFs
ones (`FA_READ=$01`, `FA_WRITE=$02`, `FA_OPEN_ALWAYS=$10`).

| Op | Bank-0 thunk | Target | Args |
|---|---|---|---|
| `f_open` | `FarCall_06_7309` `00:1926` | `Open_B6` `06:7309` | (FIL*, path, mode) |
| `f_read` | `FarCall_06_779a` `00:1941` | `Read_B6` `06:779a` | (FIL*, buf, len, &br) |
| `f_lseek` | `FarCall_03_76cc` `00:1985` | `Lseek_B3` `03:76cc` | (FIL*, ofs32) |
| `f_close` | `FarCall_03_768f` `00:19a1` | `Close_B3` `03:768f` | (FIL*) |
| `f_opendir`, `f_readdir` | `FarCallOpendir_B5` `02:4380`, `FarCallReaddir_B5` `02:4396` | bank 5 | (DIR*, path), (DIR*, FILINFO*) |

The kernel keeps one FIL at `$CA0F`, idle while the browser is. A FIL is
544 bytes ([save-manager.md](save-manager.md)). Stock calls `WaitVBlankFlag`
(`00:0688`) before an open, and the scan does the same.

`FILINFO` is the classic FatFs layout with an external long-name buffer:

| Offset | Field |
|---|---|
| `+0..3` | file size |
| `+8` | attributes (`$10` is a directory) |
| `+9..21` | the 8.3 name |
| `+22..23` | pointer to the long-name buffer, which the caller sets before `f_readdir` |
| `+24..25` | that buffer's size |

The long name lands in the buffer, empty for an entry that has only an 8.3
name. The end of a directory is an empty 8.3 name.
