# Fast launch: configuring from the SET tab

Fast launch (boot straight into one ROM, skipping the browser) is configurable
on the cart itself, from the kernel's **SET** tab, without mounting the SD card
on a computer. `/FLAUNCH.CFG` on the card stays the single source of truth; the
UI reads and rewrites that file. See [`fast-launch-notes.md`](fast-launch-notes.md)
for the boot-time scan this configures.

All addresses are `bank:addr` for 1.05e; banks 0/2/4/8 are byte-identical across
1.05e-0731 and 1.05e-0918, so every injection below is the same bytes for both.

## What the user sees

The SET tab (SELECT cycles SD → SET → HELP) gains two rows below AUTO SAVE:

| Row | Control |
|---|---|
| 9  | `FAST LAUNCH:` + a checkbox (like AUTO SAVE). A toggles it and rewrites the file. |
| 11 | `ROM:` + a `PICK` button. A arms pick mode and drops into the browser. |
| 13-14 | the chosen ROM's basename, or `(AUTO)` when no explicit path is set. |

UP/DOWN move a cursor over four rows: 0 TIME SET, 1 AUTO SAVE, 2 FAST LAUNCH,
3 PICK. SELECT exits the tab; B redraws (both unchanged from stock).

**Pick mode:** pressing A on PICK arms a flag and returns to the browser, whose
tab strip now reads ` PICK A ROM `. Browse normally; pressing A on a `.gb`/`.gbc`
writes its full path (`current dir` + `/` + `name`) into `/FLAUNCH.CFG` and
returns to the SET tab, which shows the new basename. Back out without choosing
with **SELECT** (returns to SET) or **B at the root** (also returns to SET). The
picked ROM's enabled/disabled state is preserved (picking does not auto-enable).

## CFG format

`/FLAUNCH.CFG`, 8.3 name, root. Only line 1 matters (ends at CR/LF/NUL; trailing
spaces trimmed).

| Line 1 | Meaning |
|---|---|
| missing / empty | enabled, no explicit target → lone-ROM rule |
| `/Pokemon/Blue.gb` | enabled, launch that path |
| `#/Pokemon/Blue.gb` | disabled: skip every trigger; path kept for re-enable |
| `#` | disabled, no path |

The SET tab always writes a fixed-width record: `[#]path`, CR/LF, then spaces to
`REC_LEN` (124 bytes). Writing the same byte count every time lets `cfg_save`
open `FA_CREATE_ALWAYS` and overwrite in place without needing `f_truncate`
(which this kernel lacks); the parser reads only line 1 and trims the padding.

## Code

- [`../decomp/src/flcfg.c`](../decomp/src/flcfg.c) — bank 4 at `04:5990`, label
  `FlCfg`. One entry, `u8 flcfg(u8 *frame, u8 op)`, op-selected: 0 ENTER (load +
  draw the rows), 1 ROWS (redraw on cursor move), 2 A (row 2 toggle+save, row 3
  arm pick), 3 PICK (compose path from `$c2a6`+`$c4a4` and save), 4 LOAD (test).
  Same bank as `DrawTimeAutosaveScreen` (`04:46f4`), so the shims reach it with a
  plain `call`. Uses the bank-0 FatFs thunks (`f_open` `00:1926`, `f_read`
  `00:1941`, `f_write` `00:1963`, `f_close` `00:19a1`) and the kernel FIL at
  `$CA0F`, following the same `WaitVBlankFlag` + `$7FC0=$00` discipline as
  `fastlaunch.c`'s `scan_config` and the kernel's own `BackupSaveDump`.
- [`../decomp/src/flpick_banner.c`](../decomp/src/flpick_banner.c) — bank 8 at
  `08:7b8d`. Draws the ` PICK A ROM ` banner over the tab strip while pick mode
  is armed.
- `scan_config` in [`../decomp/src/fastlaunch.c`](../decomp/src/fastlaunch.c) —
  returns 2 on a leading `#` (disabled).

### WRAM (all zero at boot)

| Addr | Use |
|---|---|
| `$DA00-$DA7F` | `CFGBUF` — file contents on read, record to write (shared with `fastlaunch.c`) |
| `$DA80` | `FL_EN` — 1 = enabled |
| `$DA81` | `FL_PLEN` — stored path length (0 = no explicit target) |
| `$DA82-$DAFF` | `FL_PATH` — stored path, NUL-terminated |
| `$DB00-$DB0F` | `FL_SCR` — `"/FLAUNCH.CFG"` bounce for `f_open` (path must be in WRAM) |
| `$DB10-$DB37` | `FL_DISP` — 40-byte zero-padded basename display buffer |
| `$DBFE` | `FL_PICK` — pick-mode flag |
| `$DBFF` | (existing) fast-launch one-shot, untouched |

## Hook map (stock bytes → patch)

### Bank 4 (`DrawTimeAutosaveScreen`; `redraw`=`$48f5`, `epilogueRet`=`$5912`)

| Site | Stock | Patch | Purpose |
|---|---|---|---|
| `04:47ef` | `f8 5c 4d 44 21 07 00` | `call $5932` + 4 nops | run `FlSetEnterHook` (op ENTER) then replay the displaced prologue |
| `04:5404` | `c3 f5 48` | `jp $5948` | hiliteDec tail → `FlSetRowsHook` (op ROWS) |
| `04:560d` | `c3 f5 48` | `jp $5948` | hiliteInc tail → `FlSetRowsHook` |
| `04:5604` | `d6 01` | `d6 03` | cursor clamp 0..1 → 0..3 |
| `04:5632` | `c2 d6 58` | `c2 59 59` | A-with-cursor≠0 → `FlSetADispatch` |

### Bank 0 (cave `$04c7-$05b5`)

| Site | Stock | Patch | Purpose |
|---|---|---|---|
| `00:1263` | `f8 0e 36 02` | `jp $04e8` + nop | `FlSetExitHook`: enter browser if pick armed, else stock |
| `00:1569` | `cd 8d 07 2b 48 01 00` | `jp $04c7` + 4 nops | `FlPickHook`: capture the ROM instead of launching, if pick armed |
| `00:164e` | `ca ab 16` | `ca f8 04` | B-at-root → `FlPickCancelHook` |

### Bank 8

| Site | Stock | Patch | Purpose |
|---|---|---|---|
| `08:7200` | `c3 31 73` | `jp $7b8d` | tab-strip tail → `FlPickBanner` |

## Shims (hand-assembled; see also [`../decomp/src/shims.md`](../decomp/src/shims.md))

`flcfg` is pinned at `$5990`; args are pushed last-first (op via `push af; inc sp`,
frame via `push bc`), return in `E`.

- `FlSetEnterHook` `04:5932` (22 B) — **called**, so the frame is at `sp+$02` and
  the replayed `ld hl,sp+$5c` becomes `ld hl,sp+$5e`:
  `f8 02 4d 44 3e 00 f5 33 c5 cd 90 59 e8 03 f8 5e 4d 44 21 07 00 c9`
- `FlSetRowsHook` `04:5948` (17 B, jp'd, sp = frame):
  `f8 00 4d 44 3e 01 f5 33 c5 cd 90 59 e8 03 c3 f5 48`
- `FlSetADispatch` `04:5959` (29 B, jp'd): row 1 → stock autosave toggle `$58d6`;
  else op A; E=0 → `jp $48f5` (redraw), E=1 → `jp $5912` (leave SET):
  `f8 3d 7e 3d ca d6 58 f8 00 4d 44 3e 02 f5 33 c5 cd 90 59 e8 03 7b b7 ca f5 48 c3 12 59`
- `FlPickCommitFar` `04:5976` (14 B) — no-arg far target (trampoline arg shift
  irrelevant): `3e 03 f5 33 21 00 00 e5 cd 90 59 e8 03 c9`
- `FlPickHook` `00:04c7` (26 B): armed → far-call `FlPickCommitFar` then
  `jp $124f` (tabs+SET screen); else replay `LoaderPrepPath` far-call and
  `jp $1570`:
  `fa fe db b7 28 0a cd 8d 07 76 59 04 00 c3 4f 12 cd 8d 07 2b 48 01 00 c3 70 15`
- `FlSetExitHook` `00:04e8` (14 B): armed → `jp $0f8d` (browser); else replay and
  `jp $1267` (HELP as stock):
  `fa fe db b7 c2 8d 0f f8 0e 36 02 c3 67 12`
- `FlPickCancelHook` `00:04f8` (10 B): not armed → stock no-op `$16ab`; armed →
  `jp $124f` (back to SET, which clears the flag):
  `fa fe db b7 ca ab 16 c3 4f 12`

The called-prologue offset (`FlSetEnterHook`) is the one to double-check on any
change: entering via `call` (not `jp`) puts SP two below the SET frame, so every
frame reference in the replayed instruction shifts by +2.

## Reproduce

After the base fast-launch injection (see [`fast-launch-notes.md`](fast-launch-notes.md)),
run for each version key (`1.05e-0731` then `1.05e-0918`), then one
`python3 scripts/kernel-patch.py make`:

```bash
cd decomp; V=1.05e-0731
# scan '#'-disable rule (delete the two 02:4500 lines from re/$V/kernel.sym first)
python3 tools/inject.py src/fastlaunch.c $V 2 4500 FastLaunchScan \
  --pin FarCallOpendir_B5=4380 --pin FarCallReaddir_B5=4396 --pin FarCallSetPage=43ac \
  --pin FarCall_06_7309=1926 --pin FarCall_06_779a=1941 --pin FarCall_03_768f=19a1 \
  --pin WaitVBlankFlag=0688 --apply
# bank 4: flcfg + shims + site patches
python3 tools/inject.py src/flcfg.c $V 4 5990 FlCfg \
  --pin FarCall_06_7309=1926 --pin FarCall_06_779a=1941 --pin FarCall_07_7739=1963 \
  --pin FarCall_03_768f=19a1 --pin WaitVBlankFlag=0688 --pin SetFpgaPage_B4=466e \
  --pin DrawString=08b7 --pin DrawRect=27ba --pin StoreDrawParams=2791 --pin ReadJoypad=3a4a --apply
python3 tools/inject_bytes.py $V 4 5932 FlSetEnterHook  f8024d443e00f533c5cd9059e803f85e4d44210700c9 --apply
python3 tools/inject_bytes.py $V 4 5948 FlSetRowsHook   f8004d443e01f533c5cd9059e803c3f548 --apply
python3 tools/inject_bytes.py $V 4 5959 FlSetADispatch  f83d7e3dcad658f8004d443e02f533c5cd9059e8037bb7caf548c31259 --apply
python3 tools/inject_bytes.py $V 4 5976 FlPickCommitFar 3e03f533210000e5cd9059e803c9 --apply
python3 tools/patch_call.py   $V 4 47ef 7 04:5932 --apply
python3 tools/patch_call.py   $V 4 5404 3 04:5948 --jp --apply
python3 tools/patch_call.py   $V 4 560d 3 04:5948 --jp --apply
python3 tools/inject_bytes.py $V 4 5604 FlSetHiliteClamp d603 --apply
python3 tools/inject_bytes.py $V 4 5632 FlSetAHookSite  c25959 --apply
# bank 0
python3 tools/inject_bytes.py $V 0 04c7 FlPickHook       fafedbb7280acd8d0776590400c34f12cd8d072b480100c37015 --apply
python3 tools/inject_bytes.py $V 0 04e8 FlSetExitHook    fafedbb7c28d0ff80e3602c36712 --apply
python3 tools/inject_bytes.py $V 0 04f8 FlPickCancelHook fafedbb7caab16c34f12 --apply
python3 tools/patch_call.py   $V 0 1263 4 00:04e8 --jp --apply
python3 tools/patch_call.py   $V 0 1569 7 00:04c7 --jp --apply
python3 tools/inject_bytes.py $V 0 164e FlPickCancelSite caf804 --apply
# bank 8
python3 tools/inject.py src/flpick_banner.c $V 8 7b8d FlPickBanner --pin DrawString=08b7 --pin StoreDrawParams=2791 --apply
python3 tools/patch_call.py   $V 8 7200 3 08:7b8d --jp --apply --regen
```

## Verification status

Structural: both versions round-trip byte-exact through `scripts/build-kernel.sh`
(disassembly → `kernel.gb`), and `scripts/kernel-patch.py` regenerates matching
IPS patches; `apply` to a stock `ezgb.dat` reproduces the manifest md5.

Under SameBoy (EZ Jr stub): the `#`-disable scan was confirmed (a `#`-prefixed
cfg boots to the browser; the same path without `#` fast-launches), and the
config **write primitive** was confirmed (the PICK path wrote correct
`/FLAUNCH.CFG` files: a fresh 25-byte create and a clean overwrite of a longer
file). The full live UI round-trip (checkbox toggle, pick-and-return, banner) was
not conclusively driven under the emulator; the emulator harness also ignores
`$7FC0`, so SD/FPGA-personality behavior only shows on hardware. **Hardware
testing is required** before relying on the feature, as with every prior
fast-launch milestone (GBC + GBA SP): confirm the toggle persists across a power
cycle, a picked root ROM and a subfolder LFN ROM both boot, browsing/launching
still work after a toggle or pick (no wedged SD controller), and a `#`-disabled
lone-ROM card boots to the browser.
