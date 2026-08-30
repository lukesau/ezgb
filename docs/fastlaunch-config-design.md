# Fast-launch config: file-content read + on-device UI (design investigation)

Status: **design investigation.** The file-content config it recommends has since
shipped as `/FLAUNCH.CFG`, first line = ROM path (see
[`fast-launch-notes.md`](fast-launch-notes.md)). The on-device configuration UI
below is not built. All addresses are `bank:addr` for 1.05e.

## Verdict

- **A config file on SD is the right source of truth.** Reading it is nearly free
  (ready-made bank-0 thunks for `f_open` / `f_read` / `f_close` / `f_lseek`), it is
  non-volatile, editable from a computer, carries zero brick risk, and makes
  nested-directory ROMs work for free with the existing launch glue.
- **On-cart storage is a poor source of truth.** The NOR config flash is
  bitstream-only and brick-prone (off-limits); the parallel NOR holds the launched
  game and is only reachable through the same brick-risk interface. PSRAM is
  writable and precedented but battery-backed *volatile* memory on a cart whose
  coin cell notoriously dies in months. PSRAM's real role is an optional cache.

## A. File-content config

### Reading a file is nearly free

Every primitive a config read needs has a ready-made bank-0 thunk; injected C just
pins the label and calls it (no hand-assembled shim):

| Op | Bank-0 thunk | Target | Args |
|---|---|---|---|
| `f_open`  | `FarCall_06_7309` `00:1926` | `Open_B6` `06:7309` | (FIL*, path, mode) |
| `f_read`  | `FarCall_06_779a` `00:1941` | `Read_B6` `06:779a` | (FIL*, buf, len, &br) |
| `f_lseek` | `FarCall_03_76cc` `00:1985` | `Lseek_B3` `03:76cc` | (FIL*, ofs32) |
| `f_close` | `FarCall_03_768f` `00:19a1` | `Close_B3` `03:768f` | (FIL*) |

Mode flags are standard FatFs (`FA_READ=$01`, `FA_WRITE=$02`,
`FA_OPEN_ALWAYS=$10`, etc.), verified against the kernel's own save code. The
`FRESULT` returns in `E`. The kernel keeps its own FIL at `$ca0f` (FS_TINY
shared-window build); the shipped scan reuses it.

### The format and the quiet win

A small text file in root whose contents are a path, e.g. `/Pokemon/Blue.gb`.
Boot: `f_open(FA_READ)` → `f_read` → trim to the first line → hand the path to the
launch. (Shipped as `FLAUNCH.CFG`; the 8.3 filename constraint and WRAM-path
constraint are documented in [`fast-launch-notes.md`](fast-launch-notes.md).)

The launch glue (`fastlaunch_do_launch`, reusing `LastRomRelaunch`) **already
handles a full directory-qualified path**: it splits at the last `/`, opens that
directory, applies the basename, and boots. So a content-read config removes the
directory scan entirely for the pinned case: no tree search, just read the path
and feed it to the proven launch. It is both more capable (any path, any depth)
and simpler than a root-only directory scan. The lone-ROM auto-detect stays as a
no-config fallback.

### Writing (on-device edit) is proven

The kernel writes `SAVER/*.SAV` back to the FAT volume on every backup:
`f_open(FA_OPEN_ALWAYS|FA_WRITE = $12)` → `f_lseek` → `f_write` (`Write_B7` via
`FarCall_07_7739` `00:1963`) → `f_close` (`BackupSaveDump`, `bank_001.asm:7102`).
The volume is mounted read-write and `DiskStatus` reports not-write-protected. So
an on-device editor can persist a choice by rewriting the config file.

### On-device UI building blocks (all present)

- **Draw:** `DrawString` `00:08b7` (`ptr, len, pos`; pos low byte = column, high
  byte = row), `DrawRect` `00:~8118`, `StoreDrawParams` `00:2791` (sets
  `$d734/$d735/$d723`), `DrawGlyph` `00:2701`, cursor vars `$d732/$d733`.
- **Input:** `ReadJoypad` `00:3a4a` returns the post-swap key byte in `E`. Map:
  A=`$10`, B=`$20`, SELECT=`$40`, START=`$80`, Right=`$01`, Left=`$02`, Up=`$04`,
  Down=`$08`.
- **Modal template:** the last-ROM START overlay (`LastRomOverlay` `00:129e` →
  draw chrome `08:73f5` → input loop `00:1330` → A/B → return) is a self-contained
  modal to clone.
- **Pick a ROM by reusing the browser:** selection state is cursor row `sp+$15`,
  page base `sp+$13/14`, entry-record array pointer `$c2a0` (32-byte records,
  count `$c2a2`); `MenuDispatchAB` `00:1392` resolves highlighted entry → full
  path. A "pin this ROM" action assembles that path and `f_write`s it to the cfg.

Rollout: (1) content-read cfg [shipped]; (2) a "pin current selection" key in the
browser that writes the cfg; (3) a dedicated config modal.

## B. On-cart storage (PSRAM / NOR)

### PSRAM: writable, precedented, but volatile

The `$A300` last-ROM record is the proof: the kernel writes a 255-byte path there
(cart PSRAM, page 17 via `$4000=$11`, FPGA personality `$7FC0=$03`) on every
launch and reads it back on START (`LastRomPersist` `01:4856`, `LastRomLoadRecord`
`00:12bf`; see [`last-rom.md`](last-rom.md), [`psram-save-map.md`](psram-save-map.md)).
This is ordinary RAM banking, distinct from the brick-risk config-flash command
path. ~7 KB is free in that page (`$A400–$AFFF` plus all of `$B000–$BFFF`, never
referenced), and the mechanics clone the last-ROM code.

But PSRAM is battery-backed **volatile** memory (coin cell backs RTC + PSRAM). On
a cart whose cell dies in 1–8 months, a config there is wiped along with saves and
the clock, and it is not editable from a computer. Only `$A300–$A3FE` is *proven*
backed by kernel access; that `$A400+` in the same page is equally backed is
likely (contiguous page) but should be a write/read-back probe if pursued.

### NOR: effectively off-limits

- **EN25F40 SPI config flash (512 KB)** holds the FPGA bitstream. The only write
  path is the `$7FD2` config-flash command sequence that bricked a cart on
  2026-08-16 (recovered only by desoldering). No safe runtime write path.
- **Spansion 71GL032A parallel NOR (4 MB),** the game-ROM store: the kernel
  programs the launched game into it on every launch (re-flashed each time, never
  reused), so it is neither free nor idle, and it is only reachable via the same
  brick-risk `$7Fxx` interface. No settings partition.

(NOR/hardware detail: [`hardware-board.md`](hardware-board.md),
[`fpga-flash-map.md`](fpga-flash-map.md).)

## Contrast

| | Config file on SD | PSRAM blob | NOR flash |
|---|---|---|---|
| Truly non-volatile | Yes | No (battery) | Yes |
| Survives dead battery | Yes | **No** | Yes |
| Editable from a computer | Yes | No | No |
| Brick risk | None | None | **High (proven)** |
| Kernel support today | thunks ready | clone `$A300` | off-limits |
| Nested-ROM paths | free (launch glue) | free | n/a |

**Recommended architecture: hybrid, with the file as source of truth and PSRAM an
optional cache.** Keep a human-editable, non-volatile config on SD; if instant
boot without even a directory read is wanted later, mirror the resolved path into
a PSRAM slot the way `$A300` does, reseeding from the file when the cache is empty
(dead battery). NOR stays out entirely.

## Open questions (small probes, no commitment)

`f_open`/`f_read` at the boot-hook point, and the FPGA page state around SD I/O,
are both settled by the shipped scan: FatFs works there, and the sector path does
depend on `$7FC0` (see the `$7FC0` bug in
[`fast-launch-notes.md`](fast-launch-notes.md)). Still open: whether `$A400+` is
actually battery-backed, which needs one write/read-back if the PSRAM cache is
pursued.

## Sources

Investigated read-only across `docs/hardware-board.md`, `docs/fpga-flash-map.md`,
`docs/fpga-ace.md`, `docs/game-slot-access.md`, `docs/psram-save-map.md`,
`docs/last-rom.md`, `docs/omega-jr-compare.md`, `decomp/src/shims.md`,
`re/1.05e/disassembly/bank_*.asm`, and `re/1.05e/kernel.sym`.
