# Hand-assembled blocks

Not everything in the mod is C. Hooks that replace a few stock instructions,
far-call stubs, and entry stubs that must not disturb the stack are written
as bytes with `kernel/mod/tools/inject_bytes.py`. They have no source file:
each is a named `.data` block in `kernel/<ver>/kernel.sym` and reads as
`db` lines in the disassembly. `port-mod.py` decodes them and translates
their addresses when it carries the mod to another kernel. This page gives
the conventions they follow and lists the ones that are hard to understand
from the bytes alone. Addresses are 1.05e-0731's.

## Far calls

`FarCallTrampoline` (`00:078d`) takes its target from the four bytes after
the `call`:

```asm
call FarCallTrampoline          ; cd 8d 07
db   dest_lo, dest_hi, bank, 0  ; the last byte is read and ignored
```

It saves and restores the ROM bank, so a stub can sit in any bank, and code
in the same bank reaches the stub with a plain `call`. C cannot express the
inline bytes, which is why these are hand-assembled.

A far stub that forwards stack arguments follows the stock
`FarCall_06_7309` pattern: read each incoming argument, push it again in the
order the target expects, call the trampoline, drop the pushed bytes, `ret`.
An 8-bit result comes back in `E`, as SDCC's stack calling convention
expects, and the stub leaves `E` alone.

The trampoline puts two more return addresses on the stack, so a C function
reached through it finds its arguments at `sp+6` when the stub is inline and
`sp+8` when the stub was itself `call`ed. Injected C takes pad parameters to
line them up. A function that takes no stack arguments avoids the question:
`EzCfg` (`02:4a00`) gets its op in WRAM `$DBFC` (`ezcfg.h`), so one entry
serves a bank-2 `call` and a far call alike.

## Hooks into a stock frame

Stock code addresses its locals as `sp+N`. A hook has to account for how it
was entered:

- Reached by `jp`: SP is the stock frame, and the hook ends by jumping back
  into stock code.
- Reached by `call`: SP is two lower, so every replayed `ld hl,sp+N` becomes
  `sp+N+2`.

A hook replays the stock instructions it overwrote before it returns.

`FileBrowserEntry_rowInc` (`00:1200`) and `FileBrowserEntry_rowDec`
(`00:11e7`) are the hardest case. They are labels inside `FileBrowserEntry`,
not functions: they read and write the enclosing frame and leave by
`jp MenuDispatchAB_waitVBlankLoop` (`00:16ab`). Each has its first three
bytes replaced by a `jp` to an entry stub (`BrowserScrollDownHook`
`00:02e0`, `BrowserScrollUpHook` `00:02f0`), which is jumped to, never
called, and takes the frame address before pushing anything:

```asm
ld   hl, sp+$12     ; &frame.dirty; must come before any push
push hl
call NavDownStub    ; 00:3d8c, a far stub to BrowserNav in bank 12
add  sp, $02
jp   MenuDispatchAB_waitVBlankLoop
```

The frame slots are contiguous, so that one pointer stands for all of them:
`sp+$12` dirty flag, `sp+$13`-`$14` first row shown (u16), `sp+$15` selected
row. `BrowserPageEndHook` (`00:03f4`) uses the same frame.

## The blocks

| Block | Entered from | By | What it does |
|---|---|---|---|
| `FarCallOpendir_B5` `02:4380`, `FarCallReaddir_B5` `02:4396` | injected C in bank 2 | `call` | far stubs to FatFs `f_opendir` (`05:73dd`) and `f_readdir` (`05:7576`), two pointer arguments each |
| `FarCallEzCfg` `04:5f00` | bank 4 | `call` | far stub to `EzCfg` |
| `FlCfgJump` `04:6600` | the SET hooks below | `call` | fixed entry that jumps to `FlCfg` (`04:6d19`), so the hooks need no change when `flcfg.c` moves |
| `FlSetEnterHook` `04:5932` | SET prologue `04:47ef` | `call` | op 0, then replays `ld hl,sp+$5c; ld c,l; ld b,h; ld hl,$0007` (as `sp+$5e`) |
| `FlSetRowsHook` `04:5948` | the cursor up and down tails `04:5404`, `04:560d` | `jp` | op 1, then `jp DrawTimeAutosaveScreen_redraw` (`04:48f5`) |
| `FlSetADispatch` `04:5f30` | A with the cursor off row 0, `jp nz` at `04:5632` | `jp` | sends the row to the stock handler or to `FlCfg` |
| `FlPickCommitFar` `04:5976` | `FlPickHook` | far call | op 3 with a null frame; takes no arguments |
| `FlPickHook` `00:04c7` | the browser's launch site `00:1569` | `jp` | in pick mode, commits the pick and returns to SET; otherwise replays the `LoaderPrepPath` far call |
| `FlSetExitHook` `00:04e8` | the SET return site `00:1263` | `jp` | in pick mode, enters the browser; otherwise replays `ld hl,sp+$0e; ld [hl],$02` |
| `FlPickCancelHook` `00:04f8` | B at the card root `00:164e` | `jp` | in pick mode, back to SET |
| `RtcSetHook` `04:5f10` | the TIME SET confirm tail `04:58d3` | `jp` | op `OP_TIMESET`, then the displaced `jp` to the redraw |
| `RtcBootHook` `00:0510` | `00:0e49`, after the SD card mounts | `jp` | op `OP_RESTORE`, sets `$4000=$11` again, replays the `SetFpgaPage(3)` far call |
| `BatteryDryHook` `00:0530` | `BatteryCheck_markOk` `00:18e5` | `call` | sets `$DBFD`, then the displaced canary write (`$A201=$88`) |
| `RtcDumpHook` `01:7600` | `BackupSaveDump`'s epilogue (`01:6738`) | `jp` | pops the frame, op `OP_BACKUP`, `ret` |

`FlPickBanner` (`08:7b8d`) is C (`flpick_banner.c`) but is reached the same
way: by `jp` from the tab strip's tail at `08:7200`, ending in a `ret` that
returns through the tab drawer.

Pick mode is the flag at `$DBFE`. The SET tab's hooks and `FlCfg`'s ops are
described in [docs/fastlaunch-set-tab.md](../../../docs/fastlaunch-set-tab.md),
and `EzCfg`'s in [docs/ezgb-cfg.md](../../../docs/ezgb-cfg.md).
