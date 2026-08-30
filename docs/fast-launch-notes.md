# Fast-launch notes

**Status (2026-08-30): complete, confirmed on real hardware** (Game Boy Color and
Game Boy Advance SP). Fast launch from a `/FLAUNCH.CFG` config file (root or
subfolder paths), the `.fastlaunch` marker, the lone-ROM rule, hold-B to cancel,
and the no-flash pre-paint hook all work on metal. It is a stock-kernel in-place
hook, not a separate B-mode kernel.

Source of truth is `decomp/src/fastlaunch*.c`.

## How it is wired

- **Scan** (`decomp/src/fastlaunch.c`, `FastLaunchScan`, `02:4500`). Writes the
  full ROM path to the fixed WRAM buffer `$c4a4` (no arg crosses the far-call:
  FarCallTrampoline shifts stack args by 6 bytes). Trigger priority: config file,
  then `.fastlaunch` marker, then lone ROM. Selects `$7FC0=$00` before every SD
  read and restores `$03` on exit (see the `$7FC0` bug below). Returns an empty
  result on any "nothing to do" outcome, so the kernel boots to the normal
  browser.
- **Launch** (`decomp/src/fastlaunch_do_launch.c`, `00:0420`). Reuses the kernel's
  own `LastRomRelaunch` (`$1344`; see [`last-rom.md`](last-rom.md)) but skips the
  START overlay's `LastRomDrawBasename`, so it replicates the two things that step
  does that the load needs: `SetFpgaPage($00)` (far-call blob `e7 41 04 00` →
  `04:41e7`) for the directory traversal, and it zeros `$c2a6` (then seeds `/`) so
  a nested prefix is NUL-terminated at any depth. Then `Strrchr` for the basename,
  rebuild the `sp+$08` slot, and `jp $1344`.
- **Hook (active): pre-paint.** `fastlaunch_boot.c` (`00:0490`) over the sort call
  at `00:102f`, *before* `FileBrowserEntry_redraw` (`$1071`) paints, so a
  fast-launch card never flashes the browser. One-shot via `$DBFF`. It sorts first
  (state the launch needs), then, unless B is held (`ReadJoypad` `00:3a4a`, bit
  `$20`), scans and launches; a no-trigger card returns to `$1032` and
  paints/browses. The post-paint variant `fastlaunch_hook.c` (`00:0460`, over
  `$110B`) is an alternative; wire only one at a time. The active build uses the
  pre-paint hook and leaves `$110B` as the original `21 2d 00`.
- **Config read** uses the ready-made bank-0 FatFs thunks and the kernel's own FIL
  at `$ca0f` (free while the browser is idle): `FarCall_06_7309` (f_open,
  `00:1926`), `FarCall_06_779a` (f_read, `00:1941`), `FarCall_03_768f` (f_close,
  `00:19a1`). Matches the kernel's own f_open setup: `WaitVBlankFlag` (`00:0688`)
  then `SetFpgaPage($00)` before the call.
- **Shims:** `FarCallScan` (`00:0400`), `FarCallOpendir_B5` / `FarCallReaddir_B5`
  (`02:4380` / `02:4396`), `FarCallSetPage` (`02:43ac`).

## Triggers (priority order)

1. **Config file.** `/FLAUNCH.CFG`, first line = the ROM path. Highest priority and
   the only trigger that may point **anywhere**, including subfolders
   (`/Pokemon/Blue.gb`); the launch glue traverses into the directory. The other
   two are root-only.
2. **Marker file.** A `<name>.fastlaunch` file in root launches `<name>.gb` or
   `<name>.gbc` from root.
3. **Lone ROM.** If root holds exactly one real file (ignoring the kernel
   `ezgb.dat`, `FLAUNCH.CFG`, dot-files, and macOS junk; directories don't count)
   and it is a `.gb`/`.gbc`, launch it. No marker needed.

The marker/lone-ROM scan is root-only by design: one `f_opendir`/`f_readdir` pass,
one DIR object, no recursion. A whole-tree DFS is not an option here; it hits a
DIR-object-size overlap bug and never matches a nested ROM.

### Config file constraints

- **8.3 name required.** This kernel's `f_open` (`Open_B6`) rejects long names with
  FR_INVALID_NAME (6); readdir resolves LFNs but f_open does not. So the file is
  `FLAUNCH.CFG`, not `fastlaunch.cfg`. Its *contents* may still name a long or
  nested ROM.
- **Path must be in WRAM.** `f_open` runs in bank 6, so a path pointer into a
  bank-2 ROM const reads the wrong bank. `scan_config` copies the name into WRAM
  (`CFGBUF`) before calling, as the kernel's own opens do (`/SAVER/...`).

## Bug fixed: FPGA personality ($7FC0) around SD reads

Symptom (real hardware only; emulator was fine): the first build broke *all* FatFs
operations. Entering a directory showed "file system error" under the Reading…
modal then hung, and launching a ROM hung under Loading…

Cause: SD sector reads (`DiskRead_B2`, `02:4027`) require the FPGA personality
`$7FC0=$00`, and `DiskRead_B2` does not set it; the caller does (DirList wraps
every `f_readdir` in `SetFpgaPage($00)`, far-call blob `e7 41 04 00` →
`SetFpgaPageAlt_B4` `04:41e7`). The scan omitted this, so it ran its
`f_opendir`/`f_readdir` under the browser's resting `$7FC0=$03` (the PSRAM record
window). Confirmed by watching `$7FC0`: the last write before the scan's opendir
was `$03`. Reading an SD sector under the PSRAM personality reads the wrong window
and wedges the SD controller, breaking every later op (browse and launch).
Invisible in the emulator because the EZ Jr stub ignores `$7FC0`. Banks 2 and 5
(the scan, FatFs, `DiskRead_B2`) never write `$7FC0`; it is purely the caller's
job. (`$7FC0` register details: [`REGISTERS.md`](REGISTERS.md).)

Fix: `fastlaunch_scan` selects `$7FC0=$00` before every read (before each
`f_opendir`, and in `readdir_prep` before each `f_readdir`, mirroring DirList) and
restores the browser's resting `$7FC0=$03` on exit, via the `FarCallSetPage` shim
(`02:43ac` → `04:41e7`). `$03` is also the state `LastRomRelaunch` is normally
entered in from the START overlay, so the launch path is unaffected.

## Bank-0 cave layout (watch for collisions)

`FarCallScan` `$0400`, `do_launch` `$0420` (51 B → `$0453`), `fastlaunch_hook`
`$0460` (35 B, dead when pre-paint is active), `fastlaunch_boot` `$0490` (30 B).
If a grown `fastlaunch_boot` overlaps `do_launch`'s `jp $1344`, the launch
crashes; always check injected size vs the next address after any change. (Bank-0
free ranges: [`inject-smoke-test.md`](inject-smoke-test.md).)

## FILINFO / LFN layout (confirmed live)

`decomp/src/fastlaunch_filinfo_probe.c` dumped a real `f_readdir` of the root and
confirmed the classic FatFs `_USE_LFN` external-buffer layout (also visible in the
browser's own `FileBrowserEntry_memsetWireDirList`):

| Offset | Field |
|---|---|
| `+0..3` | fsize |
| `+8` | fattrib (`$10` = dir) |
| `+9..21` | fname[13], 8.3 name |
| `+22..23` | **lfname pointer** (external buffer you set) |
| `+24..25` | lfsize |

The long name lands in that buffer (empty for 8.3-only entries, in which case fall
back to fname); end-of-dir is fname[0]==0. LFN support is required because the
marker and nested ROMs are long names, and it works only if the lfname pointer is
set before `f_readdir`.

## Reproduce

From a clean 1.05e `kernel.gb` (browser features may already be applied; fast
launch is independent of them):

```bash
cd decomp
# --- bank 2 ---
# FatFs opendir/readdir shims
python3 tools/inject_bytes.py 1.05e 2 4380 FarCallOpendir_B5 \
    f8042a666fe5f8042a666fe5cd8d07dd730500e804c9 --apply
python3 tools/inject_bytes.py 1.05e 2 4396 FarCallReaddir_B5 \
    f8042a666fe5f8042a666fe5cd8d0776750500e804c9 --apply
# FarCallSetPage shim: SetFpgaPageAlt_B4 ($41e7), the $7FC0 personality
python3 tools/inject_bytes.py 1.05e 2 43ac FarCallSetPage \
    f8027ef533cd8d07e7410400e801c9 --apply
# scan (config read via ready-made f_open/f_read/f_close thunks + VBlank)
python3 tools/inject.py src/fastlaunch.c 1.05e 2 4500 FastLaunchScan \
    --pin FarCallOpendir_B5=4380 --pin FarCallReaddir_B5=4396 --pin FarCallSetPage=43ac \
    --pin FarCall_06_7309=1926 --pin FarCall_06_779a=1941 --pin FarCall_03_768f=19a1 \
    --pin WaitVBlankFlag=0688 --apply
# --- bank 0 (mind the cave layout) ---
python3 tools/inject_bytes.py 1.05e 0 0400 FarCallScan cd8d0700450200c9 --apply
python3 tools/inject.py src/fastlaunch_do_launch.c 1.05e 0 0420 fastlaunch_do_launch --apply
python3 tools/inject.py src/fastlaunch_hook.c 1.05e 0 0460 fastlaunch_hook --apply   # post-paint variant (unwired)
python3 tools/inject.py src/fastlaunch_boot.c 1.05e 0 0490 fastlaunch_boot \
    --pin FarCallScan=0400 --pin fastlaunch_do_launch=0420 \
    --pin BrowserSortAllStub=03d4 --pin ReadJoypad=3a4a --apply
# wire the pre-paint hook: `call $03d4` (cd d4 03) at 00:102f -> `call $0490` (cd 90 04)
python3 tools/inject_bytes.py 1.05e 0 102f FastLaunchHookSite cd9004 --apply --regen
```

The scan lives in [`../decomp/src/fastlaunch.c`](../decomp/src/fastlaunch.c)
(`fastlaunch_scan`), using the two FatFs shims in
[`../decomp/src/shims.md`](../decomp/src/shims.md).

**Verified under SameBoy** (both triggers) via `decomp/src/fastlaunch_scan_test.c`
injected into empty bank 2, hooked from `FileBrowserEntry_inputLoop` (`00:1107`):
a lone-ROM card returned `/PKMRED.GB`, and a `PKMRED.fastlaunch` marker card (with
a second ROM present, so the lone-rule stayed out) resolved to `/PKMRED.GB` via
the marker path. The verified test ROM is preserved at
`re/1.05e/kernel.gb.fl-scan-verified`.

Possible follow-up: loosen the lone-ROM rule to "exactly one *ROM* file" (ignore
non-ROM clutter in root) instead of "exactly one real file".

---

## Historical notes (earlier withdrawn attempts)

Preserved for the WRAM / dir-enum / hook-site facts learned along the way.
Confirmed load plumbing is in [`launch-trace.md`](launch-trace.md) /
[`boot-map.md`](boot-map.md).

### Load chain and WRAM the loader understands

- File open in the browser is **A** (`$145f` → … → `$1569`; joypad byte is
  post-`swap`, bit `$10` = A). `$1569` far-call chain (bank 1): `$482b` → `$4048` →
  `$4000` → **`$5e14`** (main loader) → FPGA/WRAM stub handoff → `$7fe0=$80`.
- The kernel persists the last-run ROM's full launch path to cart NVRAM at `$A300`
  (bank 17 + rompage `$03`) in the exact `$c2a6` loader format, and the START
  overlay relaunches it; this is the primitive fast launch reuses. Full trace in
  [`last-rom.md`](last-rom.md).

| WRAM addr | Role |
|---|---|
| `$c4a4` | Basename, NUL-terminated 8.3 (e.g. `PKMRED.GB`) |
| `$c3a5` | Extension scratch (`.GB` / `.GBC` gate before `$1569`) |
| `$c2a0` | 6-byte header + path; path string at **`$c2a6`** as `/NAME.GB` |
| `$c2a4` | Per-file field (Pokemon `$0000` vs Tetris `$0002` in live dumps) |

Staging `$c4a4` alone is not enough; the UI path also fills `$c2a0`/`$c2a6` (and
likely more) before `$1569`.

### Root directory in WRAM after enum

After `Call_000_0a43` (dir list; hides `ezgb.dat` via `$09af`): `{$c9f5}` = DIR
object (observed base `$c7a9`), `{$c9f9}` = entry count, first 32-byte FAT row at
dir+`$32`, stride `$20`. Skip empty (`$00`), deleted (`$E5`), volume (attr bit 3),
directories (bit 4). **Row order is not stable across boots**, so scan by name/ext
and never hardcode slot indices.

### Hook geography

| Site | Notes |
|---|---|
| `$102f` | Stock `call $0a43`; natural "after enum" seam (`$1032` = fallthrough) |
| `$01e3` | Free cave after the dead `$01df` halt loop (FF pad) |
| Prefer `jp` into cave + `call $0a43` there | Same stack depth as stock `call` at `$102f` |

### Withdrawn `NAME.RUN` marker design (removed)

An early design used a content-free `NAME.RUN` marker next to `NAME.GB`: patch
`$102f` → `jp $01e3`; cave calls `$0a43`, scans WRAM FAT rows for ext `RUN`, builds
`NAME.GB` at `$c4a4`, `jp $1569`. Removed artifacts:
`scripts/apply-fast-launch.py`, `patches/fast-launch/`, `re/*/kernel-fast.gb`, root
`*.RUN` test markers. Lessons kept:

- Empty `NAME.RUN` (0 bytes) often becomes cluster = 0, size = 0 on FAT16; use a
  ≥1-byte marker if that design is ever revisited.
- Early death under SameBoy on a bad build: SD `READ` LBA 0, 257, 258 then a
  `rst $38` spiral (`PC` in `$003x` FF pad) with cascading IO writes, i.e. a
  runaway store rather than a clean error string.
- Absolute `SAMEBOY_EZFLASH_JR_IMG` matters when cwd is `tools/SameBoy`.
