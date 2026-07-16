# Fast-launch notes (experiment paused)

Goal remains: boot a chosen ROM without the file browser (on-disk config or
marker). A binary patch was tried against 1.05e and **withdrawn**; keep using
virgin `re/1.05e/kernel.gb`. Confirmed load plumbing stays in
[`launch-trace.md`](launch-trace.md) / [`boot-map.md`](boot-map.md).

## What is solid (reuse later)

### Open → load chain

- File open in the browser is **Right**, not A (`$145f` → … → `$1569`).
- `$1569` far-call chain (bank 1): `$482b` → `$4048` → `$4000` → **`$5e14`**
  (main loader), then FPGA / WRAM stub handoff culminating in **`$7fe0=$80`**.

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

## Suggested next attempt (when resumed)

1. A/B virgin vs any patch on the **same** `sd/card.img`.
2. Break `$102f` / `$0a43` / `$1569` before inventing more cave logic.
3. Prefer calling the same prep that `$145f` uses so `$c2a0`/`$c2a6`/`$c3a5`
   match a normal Right-open, instead of jumping straight to `$1569` with a
   hand-built basename.
4. Or skip markers entirely: small config file read through existing FatFs
   open helpers once those are identified — more work, clearer semantics.
