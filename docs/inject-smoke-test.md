# Injection smoke test

A deliberately trivial mod whose only job is to prove the
inject → hook → run chain works end to end, so that when a real feature
misbehaves the plumbing is not one of the suspects.

**What it does:** draws `*MOD*` on the file browser's tab row, in the empty
five cells to the right of ` HELP `.

**Status:** confirmed working on 1.05e under SameBoy — visible on screen, and
the breakpoint at the injected function's `ret` fires, so the body runs to
completion rather than just being branched into.

## The three pieces

| Piece | Where |
|---|---|
| The code | `decomp/src/ezgb_tab_banner.c` |
| Where it lives | bank 8 `$746b` (`EzgbTabBanner` in `kernel.sym`) |
| How it runs | bank 8 `$7200`, `jp $7331` → `jp $746b` |

```sh
cd decomp
python3 tools/inject.py src/ezgb_tab_banner.c 1.05e 8 746b EzgbTabBanner \
    --pin DrawString=08b7 --pin StoreDrawParams=2791 --apply
python3 tools/patch_call.py 1.05e 8 7200 3 08:746b --jp --apply --regen
```

Total ROM footprint: 38 bytes of code + a 3-byte hook. Revert with
`cp re/1.05e/kernel.gb.orig re/1.05e/kernel.gb`, then drop the two
`08:746b` lines from `kernel.sym` and regen.

Verify it fires:

```sh
./scripts/run-sameboy-debug.sh --script scripts/debug/inject-smoke.sbd --trace
```

## Why this hook site is easy

Bank 8 `$7200` is the `jp $7331` ending the SD-tab variant of the browser's
tab-row draw (tab index at `sp+$06`; 0 = SD = the default view). `$7331` is a
bare `ret`, so replacing that `jp` with `jp EzgbTabBanner` costs nothing:
the hook inherits the original function's stack frame untouched, and its own
`ret` becomes that function's return. No stolen instructions to replay, no
stack juggling.

That is the property to look for when picking a hook site. A `call`-style hook
in the middle of a function has to replicate whatever bytes it overwrote;
a `jp` over a tail `jp`/`ret` has to replicate nothing.

`patch_call.py --jp` exists for exactly this shape. A hook reached by `jp`
must be stack-neutral and must end in `ret` — an ordinary SDCC-compiled C
function with no `__naked` qualifies.

## Free space in 1.05e

Runs of ≥48 identical `$00`/`$FF` filler bytes in a virgin ROM. **Do not
eyeball this** — regenerate it against `kernel.gb.orig` before choosing an
address (the scan is a few lines of Python over the ROM; see git history of
this file if it needs rebuilding).

| Bank | Free range | Bytes | Notes |
|---|---|---|---|
| 0 | `$01e3`–`$03c8` | 486 | always mapped; plain `call` reaches it from anywhere |
| 0 | `$03cc`–`$05b5` | 490 | same |
| 0 | `$3d8c`–`$3fff` | 628 | same |
| 1 | `$7391`–`$7fff` | 3183 | |
| 2 | `$4380`–`$7fff` | 15488 | by far the largest; bank 2 is nearly empty |
| 4 | `$5932`–`$7fff` | 9934 | |
| 5 | `$767f`–`$7fff` | 2433 | |
| 8 | `$746b`–`$7fff` | 2965 | browser bank — same-bank `call` for browser hooks |
| 9 | `$7cb7`–`$7fff` | 841 | |

Banks 3, 6, 7 have under 500 bytes each.

Bank choice is a control-flow constraint, not just a capacity one: a bare
`call`/`jp` cannot cross ROMX banks. Code hooked from bank 8 must live in
bank 8 or bank 0; anything else needs `FarCallTrampoline`.

## What the previous (fastlaunch) attempt got wrong

Worth recording, because both failures were silent — the ROM booted and the
injected code ran, it just also corrupted the kernel underneath itself:

1. **It overwrote live code.** The injection at bank 8 `$4772` landed on the
   tail of `Fpga7FD2WaitClear_B8`, destroying its `$7FD2=$00` / `$7FF0=$E4`
   writes and its `ret`. That function is not dead — `RomLoad_BuildAndRun7FD2Wait_B8`
   copies it to WRAM as a trampoline on the ROM-launch path.
2. **It overwrote data that looks like padding.** Past that function is a long
   `ff 7f ff 7f 00 00 …` table. Alternating `$7FFF`/`$0000` is white/black in
   BGR555, i.e. a palette table, not filler. Only runs of a *single* repeated
   byte are safe to treat as free.

The `$4772` choice appears to have been made by eyeballing a hex dump for
"looks empty" rather than scanning for single-byte filler runs — and bank 8
had 2965 genuinely free bytes at `$746b` the whole time.

Any conclusion drawn from a test built on that ROM should be re-checked
against a clean injection before being trusted.
