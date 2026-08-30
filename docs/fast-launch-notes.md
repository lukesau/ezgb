# Fast-launch notes

**Status (2026-08-30): complete and CONFIRMED on real hardware** (Game Boy Color
and Game Boy Advance SP). Fast launch from a `/FLAUNCH.CFG` config file (root and
subfolder paths), the `.fastlaunch` marker and lone-ROM rules, hold-B to cancel,
and the no-flash pre-paint hook all work on metal. Stock-kernel in-place hook,
not a separate B-mode kernel.

This file grew section-by-section as the feature evolved; where an earlier
section disagrees with a later one, the later one and the source in
`decomp/src/fastlaunch*.c` win. The current shape:

## How it is wired (current)

- **Scan** (`decomp/src/fastlaunch.c`, `FastLaunchScan`, `02:4500`) writes the
  full path to `$c4a4` (no arg crosses the far-call — FarCallTrampoline shifts
  stack args by 6 bytes, so the scan uses the fixed buffer). Priority: config
  file → `.fastlaunch` marker → lone ROM. It selects `$7FC0=$00` before every SD
  read and restores `$03` on the way out (see the `$7FC0` section below).
- **Launch** (`decomp/src/fastlaunch_do_launch.c`, `00:0420`) reuses the kernel's
  own `LastRomRelaunch` (`$1344`) but skips the START overlay's
  `LastRomDrawBasename`, so it replicates the two things that step does that the
  load needs: `SetFpgaPage($00)` (far-call blob `e7 41 04 00` → `04:41e7`) for
  the directory traversal, and it zeros `$c2a6` (then seeds `/`) so a nested
  prefix is NUL-terminated. Then `Strrchr` for the basename, rebuild the sp+$08
  slot, and `jp $1344`.
- **Hook (active): pre-paint.** `fastlaunch_boot.c` (`00:0490`) over the sort
  call at `00:102f`, before `FileBrowserEntry_redraw` (`$1071`) paints — so a
  fast-launch card never flashes the browser. One-shot via `$DBFF`; sorts first,
  then (unless B is held — `ReadJoypad` `00:3a4a`, bit `$20`) scans and launches;
  no-trigger returns to `$1032` and paints/browses. The post-paint variant
  `fastlaunch_hook.c` (`00:0460`, over `$110B`) is the alternative — wire only
  one at a time (the active build uses the pre-paint one; `$110B` is left as the
  original `21 2d 00`).
- **Config read** uses the ready-made bank-0 FatFs thunks `FarCall_06_7309`
  (f_open `00:1926`), `FarCall_06_779a` (f_read `00:1941`), `FarCall_03_768f`
  (f_close `00:19a1`) and the kernel FIL at `$ca0f`. It matches the kernel's own
  f_open setup: `WaitVBlankFlag` (`00:0688`) then `SetFpgaPage($00)` before the
  call. See the config section below for the 8.3-name and WRAM-path constraints.
- Shims: `FarCallScan` (`00:0400`), `FarCallOpendir_B5`/`FarCallReaddir_B5`
  (`02:4380`/`02:4396`), `FarCallSetPage` (`02:43ac`).

## Bug fixed: FPGA personality ($7FC0) around SD reads

Symptom (real hardware only; emulator was fine): the first fast-launch build
broke *all* FatFs operations — entering a directory showed "file system error"
under the Reading… modal then hung, and launching a ROM hung under Loading…

Cause: SD sector reads (`DiskRead_B2`, `02:4027`) require the FPGA personality
`$7FC0=$00`, and `DiskRead_B2` does not set it — the caller does (DirList wraps
every `f_readdir` in `SetFpgaPage($00)`, far-call blob `e7 41 04 00` →
`SetFpgaPageAlt_B4` `04:41e7`). The scan omitted this, so it ran its
`f_opendir`/`f_readdir` under the browser's resting `$7FC0=$03` (the PSRAM
record window). Confirmed by watching `$7FC0`: the last write before the scan's
opendir was `$03`. Reading an SD sector under the PSRAM personality reads the
wrong window and wedges the SD controller, breaking every later op (browse and
launch). It is invisible in the emulator because the EZ Jr stub ignores `$7FC0`
— exactly why the emulator passed while hardware failed. Banks 2 and 5 (the
scan, FatFs, `DiskRead_B2`) never write `$7FC0`, so it is purely the caller's
job.

Fix: `fastlaunch_scan` selects `$7FC0=$00` before every read (before each
`f_opendir`, and in `readdir_prep` before each `f_readdir`, mirroring DirList)
and restores the browser's resting `$7FC0=$03` on the way out (the wrapper).
`$03` is also the state `LastRomRelaunch` is normally entered in from the START
overlay, so the launch path is unaffected. Via the `FarCallSetPage` shim
(`02:43ac` → `04:41e7`). Confirmed on real hardware.

## File-content config + pre-paint hook (confirmed on GBC + GBA SP hardware)

**Config file.** `/FLAUNCH.CFG` in the SD root, first line = the ROM path (root
or nested, e.g. `/Pokemon/Blue.gb`). It is the highest-priority trigger (then
marker, then lone-ROM). Read via the kernel's ready-made bank-0 thunks
`FarCall_06_7309` (f_open, `00:1926`), `FarCall_06_779a` (f_read, `00:1941`),
`FarCall_03_768f` (f_close, `00:19a1`), using the kernel's own FIL at `$ca0f`
(free while the browser is idle). Two constraints learned the hard way:

- **8.3 name required.** This kernel's `f_open` (`Open_B6`) rejects long names
  with FR_INVALID_NAME (6) — unlike readdir, which resolves LFNs. So the config
  file is `FLAUNCH.CFG`, not `fastlaunch.cfg`. (Its *contents* may still name a
  long/nested ROM; the launch path handles those.)
- **Path must be in WRAM.** `f_open` runs in bank 6, so a path pointer into a
  bank-2 ROM const reads the wrong bank. `scan_config` copies the name into
  WRAM (`CFGBUF`) before calling, as the kernel's own opens do (`/SAVER/...`).

Nested paths work because `fastlaunch_do_launch` now zeros `$c2a6` before seeding
'/', so `LastRomRelaunch`'s prefix Memcpy is NUL-terminated for any depth.

**Pre-paint hook (no browser flash).** `fastlaunch_boot.c` (`00:0490`) hooks the
sort call at `00:102f`, *before* `FileBrowserEntry_redraw` (`$1071`) paints — so
a fast-launch card goes straight to Loading with no browser flash. One-shot via
`$DBFF`; it does the sort FIRST (state the launch needs) then, unless B is held,
scans/launches; a no-trigger card returns to `$1032` and paints/browses. This
supersedes the post-paint hook `fastlaunch_hook.c` (`00:0460`, over `$110B`) —
wire only one at a time. Confirmed on hardware.

**Bank-0 cave layout (watch for collisions).** `FarCallScan` `$0400`, `do_launch`
`$0420` (51 B → `$0453`), `fastlaunch_hook` `$0460` (35 B, dead when pre-paint is
active), `fastlaunch_boot` `$0490` (30 B). An earlier layout let a grown
`fastlaunch_boot` overlap `do_launch`'s `jp $1344`, which crashed the launch and
briefly looked like a pre-paint problem — always check injected size vs the next
address after any change.

## Reproduce

From a clean 1.05e `kernel.gb` (the browser features may already be applied;
fast launch is independent of them):

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
# --- bank 0 (mind the cave layout; see below) ---
python3 tools/inject_bytes.py 1.05e 0 0400 FarCallScan cd8d0700450200c9 --apply
python3 tools/inject.py src/fastlaunch_do_launch.c 1.05e 0 0420 fastlaunch_do_launch --apply
python3 tools/inject.py src/fastlaunch_hook.c 1.05e 0 0460 fastlaunch_hook --apply   # post-paint variant (unwired)
python3 tools/inject.py src/fastlaunch_boot.c 1.05e 0 0490 fastlaunch_boot \
    --pin FarCallScan=0400 --pin fastlaunch_do_launch=0420 \
    --pin BrowserSortAllStub=03d4 --pin ReadJoypad=3a4a --apply
# wire the pre-paint hook: `call $03d4` (cd d4 03) at 00:102f -> `call $0490` (cd 90 04)
python3 tools/inject_bytes.py 1.05e 0 102f FastLaunchHookSite cd9004 --apply --regen
```

## Current design (three triggers, in priority order)

1. **Config file.** `/FLAUNCH.CFG` whose first line is the ROM path. This one may
   point **anywhere**, including subfolders (`/Pokemon/Blue.gb`) — the launch
   glue traverses into the directory. The other two triggers are root-only.
2. **Marker file.** A `<name>.fastlaunch` file in root launches `<name>.gb` or
   `<name>.gbc` from root.
3. **Lone ROM.** If the root holds exactly one real file — ignoring the kernel
   `ezgb.dat`, `FLAUNCH.CFG`, dot-files, and macOS junk (directories don't
   count) — and it is a `.gb`/`.gbc`, launch it. No marker needed.

On any "nothing to do" outcome the scan leaves an empty result and the kernel
boots to the normal browser.

The marker/lone-ROM *scan* is root-only — a deliberate simplification over an
earlier whole-tree DFS: one `f_opendir`/`f_readdir` pass, one DIR object, no
recursion (that DFS
attempt hit a DIR-object-size overlap bug that never matched a nested ROM).

The scan lives in [`../decomp/src/fastlaunch.c`](../decomp/src/fastlaunch.c)
(`fastlaunch_scan`), using the two FatFs shims in
[`../decomp/src/shims.md`](../decomp/src/shims.md) and the **confirmed** FILINFO
/ LFN layout (see below). It returns the full path (e.g. `/PKMRED.GB`) in a WRAM
buffer.

**Verified under SameBoy** (both triggers) via `decomp/src/fastlaunch_scan_test.c`
injected into empty bank 2, hooked from `FileBrowserEntry_inputLoop` (`00:1107`):
a lone-ROM card returned `/PKMRED.GB`, and a `PKMRED.fastlaunch` marker card
(with a second ROM present, so the lone-rule stayed out) resolved to `/PKMRED.GB`
via the marker path. The verified test ROM is preserved at
`re/1.05e/kernel.gb.fl-scan-verified`.

### FILINFO / LFN layout (confirmed live)

`decomp/src/fastlaunch_filinfo_probe.c` dumped a real `f_readdir` of the root
and confirmed the classic FatFs `_USE_LFN` external-buffer layout (also visible
in the browser's own `FileBrowserEntry_memsetWireDirList`): `+0..3` fsize,
`+8` fattrib (`$10`=dir), `+9..21` fname[13] 8.3 name, `+22..23` **lfname
pointer** to an external buffer you set, `+24..25` lfsize. The long name lands
in that buffer (empty for 8.3-only entries — fall back to fname); end-of-dir is
fname[0]==0. LFN support is required because the marker and nested ROMs are long
names, and it works only if you set the lfname pointer before `f_readdir`.

### Remaining / possible follow-ups

- On-hardware confirmation on a real Jr. The launch reuses the shipping
  START-relaunch path (`LastRomRelaunch`), so it is expected to work, but it has
  not been run on metal yet.
- Optional: loosen the lone-ROM rule to "exactly one *ROM* file" (ignore non-ROM
  clutter in root) instead of "exactly one real file".

## Historical notes (earlier withdrawn attempts)

The rest of this file preserves what earlier binary-hook experiments learned
about WRAM, dir enum, and hook sites. Confirmed load plumbing is in
[`launch-trace.md`](launch-trace.md) / [`boot-map.md`](boot-map.md).

## What is solid (reuse later for a B-mode kernel)

### Open → load chain

- File open in the browser is **A** (`$145f` → … → `$1569`). Kernel joypad
  byte is post-`swap` (see `docs/launch-trace.md`); bit `$10` means A, not Right.
- `$1569` far-call chain (bank 1): `$482b` → `$4048` → `$4000` → **`$5e14`**
  (main loader), then FPGA / WRAM stub handoff culminating in **`$7fe0=$80`**.

### Persisted last-ROM path (cart NVRAM `$A300`)

The kernel already saves the **full launch path** of the last-run ROM to cart NVRAM at
`$A300` (bank 17 + rompage `$03`), and the START overlay reads it back and relaunches it.
This is a persisted, directory-qualified path in the exact `$c2a6` format the loader consumes
— a strong candidate input for a later B-mode kernel (read `$A300`, drive the `jr_000_1344`
split-and-load path, skip the browser). Full trace in [`last-rom.md`](last-rom.md).

### WRAM the loader already understands

| Addr | Role |
|---|---|
| `$c4a4` | Basename, NUL-terminated 8.3 (e.g. `PKMRED.GB`) |
| `$c3a5` | Extension scratch (`.GB` / `.GBC` gate before `$1569`) |
| `$c2a0` | 6-byte header + path; path string at **`$c2a6`** as `/NAME.GB` |
| `$c2a4` | Per-file field (Pokemon `$0000` vs Tetris `$0002` in live dumps) |

Staging `$c4a4` alone is not enough for a clean boot; the UI path also fills
`$c2a0`/`$c2a6` (and likely more) before `$1569`.

### Root directory already in WRAM after enum

After `Call_000_0a43` (dir list; hides `ezgb.dat` via `$09af`):

| Addr | Meaning |
|---|---|
| `{$c9f5}` | FatFs-like DIR object (observed base `$c7a9`) |
| `{$c9f9}` | Entry count |
| dir + `$32` | First 32-byte FAT row |
| stride | `$20` |

Skip empty (`$00`), deleted (`$E5`), volume (attr bit 3), directories (bit 4).
**Order of rows is not stable across boots** — scan by name/ext, do not hardcode
slot indices.

### Hook geography (if patching again)

| Site | Notes |
|---|---|
| `$102f` | Stock `call $0a43`; natural “after enum” seam (`$1032` = fallthrough) |
| `$01e3` | Free cave after the dead `$01df` halt loop (FF pad) |
| Prefer `jp` into cave + `call $0a43` there | Same stack depth as stock `call` at `$102f` |

Earlier idea of embedding at `$0f8d` (menu idle) was abandoned in favor of the
post-enum seam.

## What we tried (and removed)

1. Marker file `NAME.RUN` next to `NAME.GB` on SD root (no file-content reads).
2. Patch: `$102f` → `jp $01e3`; cave calls `$0a43`, scans WRAM FAT rows for
   ext `RUN`, builds `NAME.GB` at `$c4a4`, `jp $1569`; else `jp $1032`.
3. Breadcrumb at `$c49f` (only useful if written **before** `$0a43` as well as
   after): `$E0` = entered cave / enum not finished; `$E1` = no match; `$E2` =
   about to launch. `$00` alone does **not** mean “hook never hit” if magic is
   only stored after `$0a43` returns.

Artifacts removed from the tree: `scripts/apply-fast-launch.py`,
`patches/fast-launch/`, `re/*/kernel-fast.gb`, root `*.RUN` test markers.

## The later `.fastlaunch` scan attempt was built on a corrupted ROM

The `fastlaunch_scan_debug` round (`decomp/src/fastlaunch_debug.c`, injected at
bank 8 `$4772`) landed on live code and live data, not free space — details in
[`inject-smoke-test.md`](inject-smoke-test.md). It clobbered the tail of
`Fpga7FD2WaitClear_B8` (used by the ROM-launch path) and the head of a palette
table.

So the conclusion recorded in that file's header comment — "every entry's name
read back as the same wrong garbage byte, therefore `Readdir_B5` is overrunning
a too-small `fno[]`" — is not safe. A corrupted-ROM run is not evidence about
`FILINFO` layout. Re-run the probe from a clean injection (bank 8 `$746b`, or
bank 2 for room) before sizing `FNO_SIZE` again.

## Failure modes observed under SameBoy

- Early death: SD `READ` LBA 0, 257, 258 (boot + two root sectors) then
  `rst $38` spiral (`PC` in `$003x` FF pad), with cascading writes into IO
  (`ff7f`…`ff44`). Looks like a runaway store, not a clean error string.
- With the late-only breadcrumb, `$c49f` stayed `$00` — consistent with never
  finishing `$0a43` (or never reaching `$102f`), not with a successful scan.
- Empty `NAME.RUN` (0 bytes) often becomes **cluster = 0, size = 0** on FAT16;
  prefer a ≥1-byte marker if revisiting that design.
- Leftover `BOOT.TXT` from an earlier “bake name into ROM” sketch only added
  root noise; unused by the `*.RUN` design.
- Absolute `SAMEBOY_EZFLASH_JR_IMG` matters when cwd is `tools/SameBoy`.

We did **not** prove whether virgin `kernel.gb` also dies on the same card
image, or whether `$1569` with only `$c4a4` + `$c2a6="/"` is sufficient once
enum succeeds. Those are the next checks if this is revived.

## Suggested next attempt (when a B-mode kernel is in scope)

Prefer a dedicated kernel image over patching the stock browser (see
[`omega-jr-compare.md`](omega-jr-compare.md)). If revisiting the stock-kernel hook path first:

1. A/B virgin vs any patch on the **same** `sd/card.img`.
2. Break `$102f` / `$0a43` / `$1569` before inventing more cave logic.
3. Prefer calling the same prep that `$145f` uses so `$c2a0`/`$c2a6`/`$c3a5`
   match a normal A-open, instead of jumping straight to `$1569` with a
   hand-built basename.
4. Or skip markers entirely: small config file read through existing FatFs
   open helpers once those are identified — more work, clearer semantics.
