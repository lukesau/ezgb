# Fast-launch notes

**Status (2026-08-29): complete and verified under SameBoy.**
Implemented as a stock-kernel in-place hook (not the separate B-mode kernel).
All three cases pass: lone-ROM card launches, marker-with-other-files launches
via the marker, and a multi-file card with no trigger boots to the browser
unharmed. The launch reaches `LastRomRelaunch` and fires `$7fe0=$80` (the
stub's boot-the-loaded-ROM trigger).

## How it is wired

- **Scan** (`decomp/src/fastlaunch.c`, `FastLaunchScan`, bank 2) writes the full
  path to `$c4a4` (no arg is passed across the far-call — FarCallTrampoline
  shifts stack args by 6 bytes, so the scan reads/writes the fixed buffer).
- **Launch** (`decomp/src/fastlaunch_do_launch.c`, bank 0) computes the basename
  via `Strrchr`, rebuilds the one stack slot `LastRomRelaunch` reads (sp+$08),
  sets `$c2a6="/"`, and `jp`s into the kernel's own `LastRomRelaunch` ($1344) —
  reusing the exact shipping load-and-boot sequence.
- **Hook** (`decomp/src/fastlaunch_hook.c`, bank 0) is a one-shot over
  `ld hl,$002d` at `00:110B` inside `FileBrowserEntry_inputLoop`: it runs once
  per power-on (WRAM flag `$DBFF`) after the browser is mounted, listed and
  drawn, then replays the displaced instruction. Hooking here (not before the
  browser's own DirList) is why a no-trigger card keeps browsing cleanly.
  **Escape hatch:** it reads `ReadJoypad` (`00:3a4a`, post-swap byte in E) and,
  if B (`$20`) is held, skips the launch and drops to the browser. The decision
  is locked to the first loop iteration (the flag is set before the read).
- Shims `FarCallScan` (`00:0400`), `FarCallOpendir_B5`/`FarCallReaddir_B5`
  (`02:4380`/`02:4396`), `FarCallSetPage` (`02:43ac`). `fastlaunch_boot.c`
  (`00:0440`) is a superseded earlier hook variant, left injected but never
  called.

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
(`02:43ac` → `04:41e7`). Pending confirmation on real hardware.

## File-content config + pre-paint hook (2026-08-29, emulator-verified)

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
`$DBFF`; it does the sort FIRST (state the launch needs) then scan/launch; a
no-trigger card returns to `$1032` and paints/browses normally. This supersedes
the post-paint hook `fastlaunch_hook.c` (`00:0460`, over `$110B`) — wire only one
at a time. Verified in the emulator: fast-launch reaches `$1344`/`$7fe0=$80`
without hitting `$1071`; no-trigger hits `$1071`+`$1107` and browses.

**Bank-0 cave layout (watch for collisions).** `FarCallScan` `$0400`, `do_launch`
`$0420` (38 B → `$0446`), `fastlaunch_hook` `$0460` (35 B, dead when pre-paint is
active), `fastlaunch_boot` `$0490` (24 B). An earlier layout let `fastlaunch_boot`
overlap `do_launch`'s `jp $1344`, which crashed the launch and briefly looked
like a pre-paint problem — always check injected size vs the next address.

## Reproduce

From a clean 1.05e `kernel.gb` (the browser features may already be applied;
fast launch is independent of them):

```bash
cd decomp
# FatFs shims (bank 2)
python3 tools/inject_bytes.py 1.05e 2 4380 FarCallOpendir_B5 \
    f8042a666fe5f8042a666fe5cd8d07dd730500e804c9 --apply
python3 tools/inject_bytes.py 1.05e 2 4396 FarCallReaddir_B5 \
    f8042a666fe5f8042a666fe5cd8d0776750500e804c9 --apply
# FarCallSetPage shim (bank 2): SetFpgaPageAlt_B4 ($41e7) — $7FC0 personality
python3 tools/inject_bytes.py 1.05e 2 43ac FarCallSetPage \
    f8027ef533cd8d07e7410400e801c9 --apply
# scan (bank 2)
python3 tools/inject.py src/fastlaunch.c 1.05e 2 4500 FastLaunchScan \
    --pin FarCallOpendir_B5=4380 --pin FarCallReaddir_B5=4396 \
    --pin FarCallSetPage=43ac --apply
# far-call-to-scan shim (bank 0)
python3 tools/inject_bytes.py 1.05e 0 0400 FarCallScan cd8d0700450200c9 --apply
# launch glue (bank 0)
python3 tools/inject.py src/fastlaunch_do_launch.c 1.05e 0 0420 fastlaunch_do_launch --apply
# one-shot boot hook (bank 0)
python3 tools/inject.py src/fastlaunch_hook.c 1.05e 0 0450 fastlaunch_hook --apply
# wire it: overwrite `ld hl,$002d` (21 2d 00) at 00:110B with
# `call fastlaunch_hook` (cd 50 04)
python3 tools/inject_bytes.py 1.05e 0 110b FastLaunchHookSite cd5004 --apply --regen
```

## Current design (root-only, two triggers)

ROMs to fast-launch must live in the **SD root**. Two triggers, both scanning
only the root directory:

1. **Marker file.** A `<name>.fastlaunch` file in root launches `<name>.gb` or
   `<name>.gbc` from root.
2. **Lone ROM.** If the root holds exactly one real file — ignoring the kernel
   `ezgb.dat`, dot-files, and macOS junk (directories don't count) — and it is a
   `.gb`/`.gbc`, launch it. No marker needed.

The marker wins if both could apply. On any "nothing to do" outcome the scan
leaves an empty result and the kernel boots to the normal browser.

Root-only is a deliberate simplification over the earlier whole-tree DFS: one
`f_opendir`/`f_readdir` pass, one DIR object, no recursion (an earlier DFS
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
