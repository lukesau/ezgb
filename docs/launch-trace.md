# Load / launch debugger trace (1.05e)

Goal: confirm the file-open → ROM-boot path under SameBoy, especially what
`Call_000_078d`'s `jp hl` trampoline resolves to at each site, and how the
selected path is passed into the loader. Static decode of the `$1569` chain is
already in good shape; this is live confirmation + argument plumbing.

## Confirmed live (PKMRED.GB, 1.05e + SameBoy stub)

| Step | Evidence |
|---|---|
| File open | Break at `$145f` after A on `PKMRED.GB` |
| Ext match → load | Break at `$1569` (`CALL $078d`); UI shows `Loading...` |
| SD stream | Many `EZ Jr SD: READ LBA=…` (file LBAs then a long contiguous run) |
| FPGA config | Commits `$7f37=$03`, `$7fd4=$00`, `$7fc4=$03`, `$7fc1=$3f`, `$7fc2=$00`, `$7fc3=$20` |
| Load window | `$7f36=$01` (watch), then `$7f36=$03` status from **WRAM** stub `@$d119` |
| Build ROM | stub log: `size=$00100000` title=`POKEMON RED` mbc=`$03` mask=`$003f` |
| Close + boot | `$7f36=$00`, then **`$7fe0=$80`** from WRAM `@$d1a2` → boot |

Important: after `$7fe0=$80` the kernel ROM is replaced. Leftover breakpoints at
`$145f`/`$1569`/`$448f` will false-hit inside the *game*. Delete them before
continuing into the title screen:

```text
delete
c
```

The final `$7f36` / `$7fe0` sequence runs from a **WRAM-copied stub** (`$d1xx`),
not from live bank4 `$448f` at the moment of the writes — so a `$448f` breakpoint
can miss even though that routine is what installed the stub.

Product note: this SD → FPGA program → `$7fe0=$80` handoff is already the Jr’s
“authentic cart” launch. A future B-mode kernel reuses it and only skips the
browser OS; Omega needs NOR + a Mode B switch for the same idea. See
[`omega-jr-compare.md`](omega-jr-compare.md).

### WRAM at `$1569` → bank1 `$5e14` (PKMRED.GB)

Far-call hops confirmed at `$07ad`:

`$1569` → `$482b` → `$4048` → `$4000` → **`$5e14`** (all bank 1)

| When | Addr | Bytes / value | Meaning |
|---|---|---|---|
| At `$1569` | `$c4a4` | `PKMRED.GB\0` | Basename (NUL-terminated 8.3) |
| At `$1569` | `$c3a5` | `.GB\0` | Extension scratch for `.GB`/`.GBC` gate |
| At `$1569` | `$c2a0` | `00 a0 03 00 00 00 2f 00…` | Header + `'/'` only (path not filled yet) |
| At `$5e14` | `$c4a4` | `PKMRED.GB\0` | Basename still present |
| At `$5e14` | `$c2a0` | `00 a0 03 00 00 00 2f` + `PKMRED.GB` | Header + **`/PKMRED.GB`** path string at `$c2a6` |

### Tetris contrast (`TETRIS.GB`, mid-load / at `$7f36=$01`)

| Addr | Bytes | Notes |
|---|---|---|
| `$c4a4` | `TETRIS.GB\0` | Basename |
| `$c2a0` | `00 a0 03 00` **`02 00`** `2f` + `TETRIS.GB` | Same 4-byte prefix + `'/'`; **`$c2a4` = `$0002`** vs Pokemon **`$0000`** |

Far-call prefix matched Pokemon: `$482b` → `$4048` → `$4000` → `$5e14` (bank 1), then SD helpers (e.g. bank5 `$4378` in a loop — delete `$07ad` once past `$5e14`).

B-mode / direct-boot work is deferred behind full ASM mapping; WRAM / dir-list /
hook-site notes from a withdrawn patch attempt are in [`fast-launch-notes.md`](fast-launch-notes.md).
Product framing (Omega Mode B → Jr B-mode kernel): [`omega-jr-compare.md`](omega-jr-compare.md).

## Run

Preferred (preloads breakpoints from `scripts/debug/launch.sbd`, links
`kernel.sym` so SameBoy can resolve labels):

```sh
./scripts/run-sameboy-debug.sh              # interactive; BPs already set
./scripts/run-sameboy-debug.sh --trace      # dump WRAM/regs on each stop → scripts/debug/launch-trace.log
```

Manual equivalent:

```sh
export SAMEBOY_EZFLASH_JR_IMG="$PWD/sd/card.img"   # optional if cwd walk finds it
cd tools/SameBoy
./build/bin/SDL/sameboy -s ../../re/1.05e/kernel.gb
```

`-s` / `--stop-debugger` breaks before the first instruction. Debugger is also
reachable with Ctrl+C while running. Commands: type `help` in the console
([SameBoy debugger docs](https://sameboy.github.io/debugger/)).

In the file browser, **A** opens/launches. Use an 8.3 name on the SD image
(e.g. `TETRIS.GB`). At a stop, paste lines from `scripts/debug/dump-launch.sbd`
instead of inventing a stack dump each time.

Joypad note: `Call_000_3a16` ends with an extra `swap a`, so the menu byte is
**not** `hardware.inc` `PADF_*` order. Bit `$10` is **A** (confirm/open), `$20` is
**B**, `$80` is **START** (opens the last-ROM overlay, see `docs/last-rom.md`),
`$01`/`$02` are d-pad Right/Left. Older notes that said “Right opens” were
misreading `$10` as `PADF_RIGHT`.

## Breakpoints (set first)

Preloaded by `scripts/debug/launch.sbd`. Manual reference:

| Priority | Command | Why |
|---|---|---|
| 1 | `breakpoint $145f` | Non-dir file open (after A) |
| 2 | `breakpoint $1569` | `.GB`/`.GBC` matched — load sequence starts |
| 3 | `breakpoint $078d` | Banked far-call trampoline; **log HL and `$2000`/`$d6cf`** before `jp hl` — noisy during SD I/O; add only after `$1569` (`scripts/debug/farcall.sbd`) |
| 4 | `breakpoint $5e14` | Main loader (bank 1) — only hits after bank switch |
| 5 | `watch $7f36` / `watch $7fe0` | Prefer these over `$448f` for handoff (WRAM stub) |

Continue with `c`. On each `$078d` stop, note:

```text
HL = target address in switched bank
[$2000] / [$d6cf] = bank latch
```

Expected `$1569` chain (from static decode of inline far-call blobs):

| After `$078d` @ | HL | Bank | Role |
|---|---|---|---|
| `$1569` | `$482b` | 1 | Path/file prep |
| `$1574` | `$5e14` | 1 | Main loader |
| `$15a5` | `$5163` | 1 | Post-load |
| `$15b2` | `$58b0` | 1 | Setup |
| `$15bf` | `$41e7` | 4 | `$7fc0` rompage |
| `$15d9` | `$4160` | 4 | `$7f37` MBC type |
| `$15e6` | `$480b` | 1 | `$7fd4` |
| `$15f5` | `$43ec` | 4 | `$7fc4` MBC |
| `$1604` | `$4207` | 4 | `$7fc1`/`$7fc2` size |
| `$160d` | `$446e` | 4 | `$7fc3` |
| `$1623` | `$448f` | 4 | Installs WRAM boot stub |

## Watchpoints

```text
watch $7f36
watch $7fe0
watch $7fc0 $7fc4
```

Optional wider FPGA net: `watch $7f00 $7fff` (noisy).

`$7f36=$01` opens the load-cmd window; `$7fe0=$80` is the stub’s “boot loaded ROM”
trigger (see SameBoy EZ Jr patch).

## What to record

1. Confirm every `$078d` stop matches the table (or note deltas).
2. At `$5e14` / `$482b`: where the selected filename/path lives (stack? `$Cxxx`?).
3. At `$448f` / WRAM stub: last WRAM/SRAM args before `$7fe0`.
4. Anything that diverges between 1.04e and 1.05e on this path (later).

## Open → boot sketch

```text
menu idle ($0f8d/$1062)
  A → $1392
    file → $145f → ext check → $1569
      Call_000_078d × N  (banked helpers + SD READ)
      FPGA config ($7f37/$7fd4/$7fc*)
      WRAM stub: $7f36=1 → 3 → 0; $7fe0=$80 → boot game
```
