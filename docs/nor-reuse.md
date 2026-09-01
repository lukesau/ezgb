# NOR reuse: booting the game already in NOR (1.05e)

> **VERDICT (2026-08-30): dead - the game store is volatile RAM, not NOR.**
> The read-back probe (below) proved it on hardware: after a full launch, a
> *fast* power cycle reads back the game's exact bytes; leaving the cart off
> longer makes bits visibly fade toward `$FF`; pulling the cart discharges it
> to clean `$FF`. Charge decay over time is the signature of DRAM/pSRAM -
> flash cannot do this. The per-launch SD→cart copy is therefore a hardware
> requirement, not kernel laziness. All experimental wiring was reverted (the
> featured builds carry only fast launch + browser features again); this page
> stays as the record. Hardware identification corrected in
> [hardware-board.md](hardware-board.md).

The stock launch path re-copies the selected ROM from microSD into the cart's
4 MB Spansion NOR (U4) on **every** launch - that copy is the multi-second
"Loading...." wait. But the game from the previous launch is still sitting in
NOR (it's nonvolatile), so relaunching the *same* game shouldn't need the copy
at all. This page documents the kernel primitive that makes that possible, and
the experimental Start→A hook that uses it.

This is the Jr's latent equivalent of the Omega's **Mode B** (boot the game
previously burned to NOR, no OS in the way) - see
[omega-jr-compare.md](omega-jr-compare.md).

## The find: a dormant no-copy boot primitive

Bank 4 contains a complete "reset into whatever is in NOR" routine with **zero
callers** in the entire kernel:

| Symbol | Addr | Role |
|---|---|---|
| `RomLoad_ResetIntoRom_B4` | `04:4180` | The boot stub itself (runs from WRAM) |
| `RomLoad_BuildAndRunReset_B4` | `04:41d2` | Copies it to `$d000` via `RomLoad_Build_B4` and calls it |

Caller scan (2026-08-30): no far-call blob `d2 41 04 00` or `80 41 04 00`
anywhere in the ROM, and no bank-4-local `call`/`jp` to either address. (The
`cd d2 41` hits in banks 3/7 are unrelated - bank-local calls to the
`SyncWindow_B3`/`_B7` FatFs helpers that happen to live at their own `$41d2`.)
Presumably factory/test code, or a leftover from a planned feature.

`RomLoad_ResetIntoRom_B4`, decoded:

```asm
; runs from WRAM $d000 (copied there by RomLoad_BuildAndRunReset_B4)
ld bc,$7f00 : ld a,$e1 : ld [bc],a   ; unlock 1
ld bc,$7f10 : ld a,$e2 : ld [bc],a   ; unlock 2
ld bc,$7f20 : ld a,$e3 : ld [bc],a   ; command mode
ld bc,$7f31 : ld a,$00 : ld [bc],a   ; param $7F31 = 0
ld bc,$7f32 : ld a,$00 : ld [bc],a   ; param $7F32 = 0
ld bc,$7ff0 : ld a,$e4 : ld [bc],a   ; commit
ld bc,$2000 : ld a,$01 : ld [bc],a   ; MBC bank latch = 1
ld bc,$3000 : ld a,$00 : ld [bc],a   ; MBC upper latch = 0
; unlock triple again, then:
ld bc,$7fe0 : ld a,$80 : ld [bc],a   ; $7FE0 = $80 → boot
ld bc,$7ff0 : ld a,$e4 : ld [bc],a   ; commit
jp $41ce                             ; self-loop until the FPGA resets us
```

What it does **not** do is the load: no `$7f36` write, no command block, no SD
streaming. It configures nothing about the game either - it assumes the MBC
type / size mask / rompage registers are already set. That makes it composable
with the stock launch tail, which sets all of those *before* the copy step.

Safety note: the routine writes only `$7f31/$7f32/$7fe0` inside standard
unlock+commit envelopes. It never touches `$7FD2` (the config-flash trigger
that bricked a cart; see [game-slot-access.md](game-slot-access.md)), so the
worst case is a garbage boot you power-cycle out of.

## Where the copy actually happens (for contrast)

The launch tail (`MenuDispatchAB_launchFarcalls`, `00:1569`–`$162b`; full chain
in [launch-trace.md](launch-trace.md)) ends at:

```asm
00:161b  ld hl,sp+$16 / ld a,[hl] / push af   ; arg byte
00:161f  ld hl,$c0a0  / push hl               ; command block (from LaunchSetup)
00:1623  call FarCallTrampoline
00:1626  db $8f,$44,$04,$00                   ; → 04:448f
```

`RomLoad_CopyCmdWindowPoll_B4` (`04:448f`) is the copy: `$7f36=$01` (open the
load-cmd window), memcpy 512 bytes `$c0a0`→`$a000` (the cluster/extent list
`LaunchSetup` staged), then `RomLoad_BuildAndRunPoll` installs the WRAM stub
that polls the FPGA while it streams SD→NOR and finally fires `$7fe0=$80`.
Everything upstream of `$1623` - `RomLoaderMain` header read/checksum,
`LaunchSetup`, and the whole FPGA config block (`$7fc0`, `$7f37`, `$7fd4`,
`$7fc4`, `$7fc1/$7fc2`, `$7fc3`) - is game *configuration*, not the copy.

So "skip the copy, everything else the same" is precisely: run the tail
unchanged, but at `$1623` call `$41d2` instead of `$448f`.

## Experimental wiring: Start→A relaunch skips the copy

Applied 2026-08-30 to the featured `re/1.05e-0731/kernel.gb` (pre-patch backup
`kernel.gb.pre-norreuse`, md5 `670a06a7`; patched build md5 `9e3b067d`). Five
patches, `$DBFE` as the one-shot flag (zeroed by the boot WRAM clear):

| Patch | Where | What |
|---|---|---|
| `LastRomOverlayAHook` | `00:04b0` (15 B) | Replaces the START-overlay A-check at `00:133d` (7 B → `jp $04b0`): replays `and $10`; on A sets `$DBFE=1` and `jp $1344` (`LastRomRelaunch`), else `jp $1385` |
| `NorReuseBootShim_B4` | `04:5940` | Reads `$DBFE`, always clears it, dispatches the copy step (v1 and v2 differ here, see below) |
| `NorReuseBlobRepoint` | `00:1626` (2 B) | Far-call blob `8f 44` → `40 59`, routing the copy step through the shim |
| `BrowserEntryClearNorReuse` | `00:04c0` (8 B) | `FileBrowserEntry` head `00:0f8d` (3 B → `call $04c0`): clears `$DBFE` + replays `ld hl,$cc2f` |

**v1 shim (superseded):** flag set → `jp $41d2` (ResetIntoRom, no copy at all),
else `jp $448f`. **v2 shim (current, 18 B):** flag set → `call
NorReuseClampExtents` (`04:5960`, from
[`norreuse_clamp_extents.c`](../decomp/src/norreuse_clamp_extents.c)) then fall
into `jp $448f` - the *stock* copy path runs, but with the command table's
extent list clamped to the first 512 sectors (256 KB), so the FPGA gets its
full load cycle while only the prefix is re-streamed. The size/meta fields are
untouched. Files smaller than the clamp hit the list terminator and copy in
full. `$41d2` is no longer referenced.

Scope: **only** the START-overlay A press sets the flag. Browser launches and
fast-launch (whose `do_launch` jumps straight to `$1344`,
[fast-launch-notes.md](fast-launch-notes.md)) still take the full-copy path.
The `FileBrowserEntry` hook is hardening: if a relaunch errors out between
`$1344` and `$1623`, the kernel returns to the browser, which clears the flag -
a stale flag can't turn a later normal launch into a wrong-game no-copy boot.

The relaunch still runs the header read, save stamping, and FPGA config, so
the game the FPGA is configured for is whatever `$A300` names - which, by
construction of the last-ROM record ([last-rom.md](last-rom.md)), is the game
last copied into NOR.

## Verification status

**Emulator (SameBoy + EZ Jr stub, 2026-08-30) - confirmed:**

- Start→A on the last ROM: full FPGA config sequence in the log
  (`$7f37/$7fd4/$7fc4/$7fc1/$7fc2/$7fc3`), then the ResetIntoRom signature -
  `$7f32=$00` commit followed by `$7fe0=$80` commit, with **no `$7f36` write
  anywhere**. Stub reports `$7FE0=$80 but no pending ROM`, expected: the
  stub's "NOR" doesn't persist across processes.
- Regression: normal browser launch still performs the full copy
  (`built 1048576 / 1048576 bytes, title=POKEMON RED`) and boots.

**Hardware, v1 (2026-08-30) - FAILED, root cause identified.** On a real Jr
(FW5-0918, ported 0918 kernel) the no-copy Start→A boot hangs on the Game Boy
splash screen; fast launch (full copy) on the same build works. The failure is
**not** evidence about NOR volatility: per daid's stage1 RE
([daid/ezflashjr](https://github.com/daid/ezflashjr) `doc/General.md` /
`Sequence.md`), the factory bootstrap **loads `ezgb.dat` into the same rom
area** the game occupies - using the very same `$7f36` ROMLoadInfo mechanism -
on *every power-on*. So at Start→A time the rom area holds the 160 KB kernel
image followed by the stale tail of the last game. v1 booted that frankenimage
under the game's MBC config: the kernel's valid Nintendo logo gets the splash
drawn, then the console jumps into mismatched code and hangs. The observed
symptom is exactly this signature. (Same doc also confirms the stock flow
writes `$7f31/$7f32 = $00` before reset, so those values were never the
problem.)

**v2 test recipe (partial copy):** launch a game (≥ 512 KB ideally) normally
once, power off, power on, Start→A. Only the first 256 KB streams; everything
past it is whatever the cart retained. Outcomes:

- Game boots and plays correctly deep into content past 256 KB → the rom-area
  tail **survives power-off** (NOR-die storage): retention proven, and
  relaunch of a 1 MB game is ~4× faster (~16× for 4 MB). The clamp can then
  be bisected down toward the true 160 KB clobber boundary.
- Game boots but shows corruption/crashes once it reads past the copied
  region → the rom area is volatile (RAM-die or DRAM-backed): NOR reuse
  across power cycles is dead, definitively.

Hold-B and all fast-launch behavior are unchanged in both versions.

## Read-back probe (in both builds)

Because the kernel *runs from the rom area* as a banked ROM (MBC latch `$2000`
selects the 16KB bank at `$4000`, kernel = banks 0–9), the store can be read
directly - no boot, no copy, pure reads. `NorProbeDraw`
([`nor_probe_draw.c`](../decomp/src/nor_probe_draw.c), `00:3ed4`) draws four
lines `BB:XXXXXXXX` (bank number, first 4 bytes of that bank) at rows
`$0b`–`$0e` when the START overlay opens: banks `09` (control - always the
kernel's own last bank), `10` (rom area `$28000`, just past the kernel), `16`
(`$40000`, past v2's copy window), `32` (`$80000`, deep tail). One-shot hook
over the overlay input loop's `call ReadJoypad` at `00:1330` →
`NorProbeOverlayHook` (`00:04cc`), flag `$DBFD`, cleared with `$DBFE` on
browser entry. Interrupts are disabled around the latch flip and the latch is
restored from the trampoline's shadow `$D6CF`.

Reading the result: `09` must match kernel offset `$24000` (`C9F5F53B` for
these builds) or the probe itself is broken; `FFFFFFFF` = erased/absent;
a line equal to kernel `$0000` (`C9FFFFFF`) = the FPGA masks the kernel-mode
ROM and the bank wrapped; a repeated open-bus byte (`46464646`-style) = nothing
driving the bus. Anything matching the previous game's bytes at that offset =
retention.

Two injection lessons paid for here: SDCC emits `static` helpers and const
arrays *ahead* of the entry point, so an injected C entry must be the sole
top-level object in the file or the hook `call`s into a helper; and the
bank-0 `$03cc` cave really does end at `$05b5` (a lone `jp $3d21` stub lives
at `$05b6` - briefly clobbered by an oversized inject, restored from
`kernel.gb.orig`, probe relocated to the `$3ed4` cave).

## The probe experiments that settled it (hardware, 2026-08-30)

Cold Start→A probe reads vs the actual `Pokemon Crystal.gbc` bytes (the last
fully launched game):

| Bank / offset | Probe read | File bytes | |
|---|---|---|---|
| `0A` / `$28000` | `80C18180` | `CDF5310E` | mostly-0 bits |
| `10` / `$40000` | `EFBEFF9E` | `F0D16FF0` | mostly-1 bits |
| `20` / `$80000` | `FFF9FFFF` | `CD17403E` | nearly erased |

No region matched - and the bit-density gradient (0-heavy near the kernel,
1-heavy deep) was the decay tell. The controlled follow-up: full-launch
Crystal → power cycle → probe. **Fast cycle: all three read back the exact
file bytes. Longer off-time: bits fade toward `$FF`. Cart removal: clean
`$FF`.** Volatile RAM, decaying toward a 1s bias, holding data across brief
power drops on residual charge only.

## What this settles

- **The game store is a pSRAM die, and it's U9's, not U4's** (chip map, see
  [hardware-board.md](hardware-board.md)): deduced from U4's datasheet - an
  8 MB ROM can't fit in U4's 512 KB pSRAM die, so it must live in a larger
  pSRAM in U9, while U4's 512 KB pSRAM die is the battery-backed *save* store.
  (U4 is a datasheet-confirmed NOR+pSRAM MCP; U9's exact make-up is unverified.)
  This explains why every launch is fast and wear-free, and why the Jr never
  got an Omega-style Mode B: there is nothing nonvolatile to boot from.
- **The full copy on every launch is required for correctness.** Any
  partial-copy or no-copy scheme rides on residual charge and one faded bit
  is a corrupted game.
- **stage1's kernel load clobbers the first 160 KB regardless** (still true,
  still confirmed by v1's splash-then-hang signature).
- `RomLoad_ResetIntoRom_B4` can only ever make sense for a warm reset within
  a powered session - from power-on there is nothing valid to reset into.

All wiring (overlay hook, shim, blob repoint, browser-entry clear, probe) was
reverted; the featured builds are back to fast launch + browser features only
(0731 = md5 `670a06a7`, the hardware-confirmed build; 0918 = `448e90dd`).
The experiment builds are preserved as `kernel.gb.norreuse-experiment` beside
each kernel, and the sources remain in `decomp/src/`
(`norreuse_clamp_extents.c`, `nor_probe_draw.c`) with this page and
[DIFF_1.05e-0731_vs_0918.md](DIFF_1.05e-0731_vs_0918.md) as the record.
