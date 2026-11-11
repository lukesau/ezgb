# Fast launch: configuring from the SET tab

Fast launch (boot straight into one ROM, skipping the browser) is configurable
on the cart itself, from the kernel's **SET** tab, without mounting the SD card
on a computer. The `FLAUNCH=` key of `/EZGB.CFG` on the card is the single source
of truth; the UI reads and rewrites it through the shared settings module
([`ezgb-cfg.md`](ezgb-cfg.md); until mod 3.0 this was a one-line `/FLAUNCH.CFG`). See [`fast-launch-notes.md`](fast-launch-notes.md)
for the boot-time scan this configures.

All addresses are `bank:addr` for 1.05e; banks 0/2/4/8 are byte-identical across
1.05e-0731 and 1.05e-0918, so every injection below is the same bytes for both.

## What the user sees

The SET tab (SELECT cycles SD → SET → HELP; START goes back a tab, HELP → SET → SD, [below](#start-goes-back-a-tab)). The stock rows were slid up one
row (every row immediate and y pixel of TIME/SET and the date/time digits,
the time-edit mode included) and AUTO SAVE moved down one, below the new RTC
row (`scripts/inject-ezcfg.sh` step 3b, each byte checked against stock):

The pane has three pages (two until 2026-11-10, and the three reported
working on hardware that day); row 16 of each steps to
the next or the previous one, and they go round: PREV on page 1 is page 3,
NEXT on page 3 page 1.

| Row | Page 1 | Page 2 | Page 3 (the theme) |
|---|---|---|---|
| 2 | `TIME:` + `SET` (stock) | `CLEAN UP NAMES:` checkbox ([`browser-tags.md`](browser-tags.md), `TAGS=`) | `THEME:` button, `LIGHT`, `DARK`, `DV`, four colors and `CUSTOM` ([`dark-mode.md`](dark-mode.md)) |
| 4 | date and time (stock) | an example name, scrolling, the whole row: `Game Title (USA) (Rev 1) [!].gb` with the box unticked, `Game Title` with it ticked (`TagExample`, `04:7e60`) | `FONT:` 8px / 12px / SLIM button ([`ui-mode.md`](ui-mode.md)) |
| 6 | `RTC:  SD [ ]  NO SD [ ]`: RTC backup/restore on or off ([`ezgb-cfg.md`](ezgb-cfg.md), `RTCSD=`) | `SORT BY PLAYS:` checkbox, a pSRAM record ([`stars.md`](stars.md)) | `COLORS:` and the `R` `G` `B` column heads |
| 8 | `AUTO SAVE:` checkbox (stock, moved down one row) | `SGB BOOT:` checkbox, a pSRAM record rather than an `EZGB.CFG` key ([`sgb-boot.md`](sgb-boot.md)), or `SGB: AUTO` | `BG:` and its three values, 0 to 31 ([color picker](dark-mode.md#color-picker)) |
| 10 | `FAST LAUNCH:` checkbox | `SKIP BOOT ROM:` checkbox, ticked unless `BOOTROM=1`; gray, and passed over by the cursor, when this console can't jump ([`skip-boot-rom.md`](skip-boot-rom.md)) | `TEXT:` and its three values |
| 12 | the target's basename in 10 columns, scrolling continuously when longer, and a `PICK ROM` button. A arms pick mode and drops into the browser. | `DAILY BACKUP:` checkbox ([save-manager.md](save-manager.md#daily-backup); on page 1's row 14 until 2026-11-10) | `ACCENT:` and its three values |
| 16 | a `< PREV` button, `1/3` and a `NEXT >` button | the same with `2/3` | the same with `3/3` |

UP/DOWN move a cursor over the page's rows. Its numbers run on across the
pages, and a page's last two are its PREV and NEXT: 0 TIME SET, 1 RTC, 2
AUTO SAVE, 3 FAST LAUNCH, 4 PICK ROM, 5 PREV, 6 NEXT on page 1; 7 TAGS, 8
SORT BY PLAYS, 9 SGB BOOT, 10 SKIP BOOT ROM, 11 DAILY BACKUP, 12 PREV, 13 NEXT
on page 2; 14 THEME, 15 FONT, 16 BG, 17 TEXT, 18 ACCENT, 19 PREV, 20 NEXT on
page 3 (clamp `04:5604` `d6 14`, and `flcfg` op ROWS keeps the cursor on its
page). The cursor wraps within its page: UP on row 0 goes to `SetWrapUp`
(`04:5fdc`, row 6, page 1's NEXT), DOWN on row 20 to `SetWrapDown` (`04:5fe4`, row 8, which
is off page 3, so its first row), and op ROWS turns a step off a page's end
into its other end.

LEFT puts the cursor on the page's PREV button and RIGHT on its NEXT, from
any row (since 2026-11-10; from mod 6.3 until then they jumped to the top
and bottom rows, as in the browser): `FlSetJumpTop` and `FlSetJumpBottom`
(`scripts/inject-set-jump.py`) store `$FE` and `$FF` as the cursor row, and
op ROWS turns those into the page's last row but one and its last. While the
time is being set they still step through its fields. A new cursor row
moves the clamp, `SetWrapUp` / `SetWrapDown` and the `first` / `last` tables
in `flcfg.c` and `setpage.c`.

### Pages

**When settings reach the card:** changes on the SET tab stay in RAM and set
`SET_DIRTY` (WRAM `$DAFD`). `SetCommit` (`04:5fc0`, 28 B) writes `EZGB.CFG` and
syncs `/.ezgbplays` when it is set, on NEXT, on PREV and when the screen is left
(SELECT, or PICK ROM on its way to the browser). Nothing is written if nothing
changed. So power off before one of those and `EZGB.CFG` keeps the old values;
this covers the checkboxes, THEME, FONT, the colors and AUTO SAVE. TIME SET's `RTC=` is the
exception: it writes the file at once, with any other changes then pending. Marks
in pSRAM still change at once: the SGB BOOT and SORT BY PLAYS records, and the
theme mark, so after a power off the boot starts in the new theme and the file's
theme then takes over at the restore. `RTC` itself, the clock chip, changes at
TIME SET as before. A re-entry (`SET_RE` set, after a page or font switch)
doesn't read the file, since RAM may be ahead of it, and `OP_AUTOSAVE` and
`OP_TIMESET` no longer read it either; they only run on this screen. Until
2026-11-04 every press wrote the file.

A on NEXT or PREV steps `SET_PAGE` (WRAM `$DBEE`, 0 to 2), clears the pane and
enters the SET screen again from the top, as the UI toggle does
(`FlSetADispatch`'s return 2), with the cursor on the same button of the new page (`SET_RE`, `$DBEF`, the
cursor row + 1), so A again goes on the same way, round and round
(`SetPage` op 6). Leaving the tab ends on page 1: the screen's exit (`04:5912`,
`add sp,$6a; ret`) goes through `SetExitHook` (`04:5fb0`), which calls `SetCommit` and clears
`SET_PAGE` first.

Pages 2 and 3 are drawn over the stock screen, which keeps running under
them: the clock still ticks and its fields are redrawn every second. Two
things keep the stock rows off them. `SetText`, which all the stock text
goes through, draws nothing while `SET_PAGE` is exactly 1 or 2; `flcfg`
sets bit 7 for as long as it runs, so its own text (and `SetPage`'s) still
draws. The stock boxes (the SET button, AUTO SAVE's checkbox) are drawn
only when the screen's dirty flag (`sp+$3e`) is set after a cursor move; op
ROWS clears it on pages 2 and 3. The entry code draws those boxes once
before op ENTER, which clears the pane again on those pages.

Page 3 is `ThemePage` (`0D:4000`,
[`../kernel/src/themepage.c`](../kernel/src/themepage.c), 2753 B), in bank
13 because bank 4 had no room for it; `flcfg` reaches it through
`FarCallThemePage` (`04:5990`): op 0 the labels, op 1 the rows, op 3 A on a
row, op 5 the loop's tick. It holds the THEME button (`ThemeRow`,
`04:77a0`, until then), the FONT button and the color picker
([dark-mode.md](dark-mode.md#color-picker)), and draws its own text; only
its page row is `SetPage`'s (op 5). The name marquee has nothing to scroll
there, so `flcfg` op 5 only keeps its frame count going for the key repeat.

Page 2 and the page row are drawn by `SetPage` (`04:6610`, since
2026-10-31; at `04:77a0`, then `04:7792` after `ThemeRow`, until it outgrew
those slots; [`../kernel/src/setpage.c`](../kernel/src/setpage.c)), near-called
by `flcfg`, which had no room for them; it replaced `SgbTagsRow`, which
held the SGB BOOT and TAGS boxes when they shared row 16. The stock checkbox
highlight tests the cursor against 2 instead of 1 (`04:498c`), and
`FlSetADispatch` moved to `04:5f30` (30 B; its old slot at `04:5959` had no
room for `cp $02`): row 2 goes to the stock AUTO SAVE toggle (`$58d6`), every
other row to `flcfg` op A. The dispatch site `04:5632` now reads `c2 30 5f`.

**Tab-switch clear.** The tab drawer (`08:7169`) wipes the content area as
`DrawRect(0, y0, $9f, $8f)` in three per-tab copies (`08:7222`, `729d`,
`7318` hold y0). Stock y0 was `$0f`; the slid-up SET button box starts at
y 13, so its top two lines survived onto HELP. y0 is now `$0a`, just below
the tab underline (y 8-9); both browser layouts start at y 16.

**Name marquee.** Since 2026-10-30 the name (and page 2's tag example) is
the shared marquee's `MQ_A`, run through `FarCallMarquee`
([marquee.md](marquee.md)); op 5 calls its `MQ_STEP`, and the pacing below
is unchanged. `flcfg` op 5 runs once per pass of the SET input loop:
its `call ReadJoypad` at `04:5162` goes through `SetLoopTickHook` (`04:5f20`,
14 B: op 5, then `ret`; op 5 does the pad read itself, with the D-pad
repeat in [`joypad-latch.md`](joypad-latch.md#set-tab-d-pad-repeat)). The scroll is paced by `hFrame` (`$fffa`),
a VBlank counter added to the joypad latch's callback
([`joypad-latch.md`](joypad-latch.md)): one character per 20 frames, a
60-frame hold at the start of the name, 3 blanks between repeats. Counting
loop passes did not work: a pass is a fraction of a frame on 1.05e and
exactly one on 1.04e, whose loop waits for VBlank.

**Pick mode:** pressing A on PICK arms a flag and returns to the browser, whose
tab strip now reads ` PICK A ROM `. Browse normally; pressing A on a `.gb`/`.gbc`
writes its full path (`current dir` + `/` + `name`) into `/EZGB.CFG` and
returns to the SET tab, which shows the new basename. Back out without choosing
with **SELECT** (returns to SET) or **B at the root** (also returns to SET). The
picked ROM's enabled/disabled state is preserved (picking does not auto-enable).

## CFG format

The `FLAUNCH=` value in `/EZGB.CFG` (full file format, parser and writer:
[`ezgb-cfg.md`](ezgb-cfg.md)). A legacy one-line `/FLAUNCH.CFG` is read when
`EZGB.CFG` is missing, with the same meanings for its line 1.

| `FLAUNCH=` value | Meaning |
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

- [`../kernel/src/flcfg.c`](../kernel/src/flcfg.c) — bank 4 at `04:6d19` (at
  `04:6600` until 2026-10-31; a `jp` there, `FlCfgJump`, keeps the hook
  shims' calls), label `FlCfg`. One entry, `u8 flcfg(u8 *frame, u8 op)`, op-selected: 0 ENTER (load +
  draw the rows), 1 ROWS (redraw on cursor move), 2 A (row 2 toggle+save, row 3
  arm pick), 3 PICK (compose path from `$c2a6`+`$c4a4` and save), 4 LOAD (test).
  Same bank as `DrawTimeAutosaveScreen` (`04:46f4`), so the shims reach it with a
  plain `call`. Uses the bank-0 FatFs thunks (`f_open` `00:1926`, `f_read`
  `00:1941`, `f_write` `00:1963`, `f_close` `00:19a1`) and the kernel FIL at
  `$CA0F`, following the same `WaitVBlankFlag` + `$7FC0=$00` discipline as
  `fastlaunch.c`'s `scan_config` and the kernel's `BackupSaveDump`.
- [`../kernel/src/flpick_banner.c`](../kernel/src/flpick_banner.c) — bank 8 at
  `08:7b8d`. Draws the ` PICK A ROM ` banner over the tab strip while pick mode
  is armed.
- `scan_config` in [`../kernel/src/fastlaunch.c`](../kernel/src/fastlaunch.c) —
  returns 2 on a leading `#` (disabled).

### WRAM (all zero at boot)

| Addr | Use |
|---|---|
| `$D980-$DA7F` | `CFGBUF` — file contents on read, record to write (owned by `ezcfg.c`; was `$DA00-$DA7F`) |
| `$DA80` | `FL_EN` — 1 = enabled |
| `$DA81` | `FL_PLEN` — stored path length (0 = no explicit target) |
| `$DA82-$DAFF` | `FL_PATH` — stored path, NUL-terminated |
| `$DB00-$DB0F` | `FL_SCR` — file-name bounce for `f_open` (path must be in WRAM) |
| `$DB40-$DB4E`, `$DBFC`, `$DBFD` | RTC copy, `ezcfg` op selector, DRY flag: see [`ezgb-cfg.md`](ezgb-cfg.md) |
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
| `04:5174` | `ca f5 48` | `ca 80 5f` | LEFT when not setting the time → `FlSetJumpTop` (cursor row = `$FE`: the page's PREV; row 0 until 2026-11-10) |
| `04:51a5` | `ca f5 48` | `ca 90 5f` | RIGHT when not setting the time → `FlSetJumpBottom` (cursor row = `$FF`: the page's NEXT; until 2026-11-10 the last row of all, which op ROWS turned into the page's last: row 13 with two pages, row 11 before SKIP BOOT ROM, row 10 until SORT BY PLAYS took it, when RIGHT stopped one short of PREV) |
| `04:5604` | `d6 01` | `d6 14` | cursor clamp 0..1 → 0..20, all three pages (`d6 0d` with two pages, `d6 0c` before DAILY BACKUP, `d6 0b` before SKIP BOOT ROM, `d6 0a` before SORT BY PLAYS, [stars.md](stars.md); `d6 08` with TAGS on row 16, [browser-tags.md](browser-tags.md); `d6 07` before it, `d6 04` with the `UI:` button, [ui-mode.md](ui-mode.md), `d6 06` before `THEME`, [dark-mode.md](dark-mode.md)) |
| `04:5912` | `e8 6a c9` | `c3 b0 5f` | the screen's exit → `SetExitHook` (`cd c0 5f af ea ee db e8 6a c9`: `call SetCommit`, clear `SET_PAGE`, then the displaced `add sp,$6a; ret`) |
| `04:5632` | `c2 d6 58` | `c2 59 59` | A-with-cursor≠0 → `FlSetADispatch` |

### Bank 0 (cave `$04c7-$05b5`)

| Site | Stock | Patch | Purpose |
|---|---|---|---|
| `00:1263` | `f8 0e 36 02` | `jp $04e8` + nop | `FlSetExitHook`: enter browser if pick armed or START left the tab, else HELP |
| `00:1288` | `21 32 00 e5 cd 93 3a e8 02 c3 8d 0f` | `cb 79 c2 4f 12 c3 8d 0f` + 4 nops | HELP's exit: START → the SET tab (`$124f`), else the browser |
| `00:1569` | `cd 8d 07 2b 48 01 00` | `jp $04c7` + 4 nops | `FlPickHook`: capture the ROM instead of launching, if pick armed |
| `00:164e` | `ca ab 16` | `ca f8 04` | B-at-root → `FlPickCancelHook` |

### Bank 8

| Site | Stock | Patch | Purpose |
|---|---|---|---|
| `08:7200` | `c3 31 73` | `jp $7b8d` | tab-strip tail → `FlPickBanner` |
| `08:714c` | `40` | `c0` | HELP's wait loop leaves on SELECT or START |

## START goes back a tab

SELECT steps SD → SET → HELP → SD. START on the SD tab is the last-ROM overlay
([last-rom.md](last-rom.md)) and did nothing on the other two; since
2026-11-11 it undoes SELECT there: HELP → SET, SET → SD.

- **SET.** `flcfg` op TICK returns a START as SELECT and sets `SET_BACK`
  (WRAM `$DC1C`, cleared on every other pass), so the screen leaves the way it
  does on SELECT, `SetCommit` included. `FlSetExitHook` then enters the browser
  instead of HELP. The color picker takes the keys while a color is being set,
  START among them, as it does SELECT.
- **HELP.** The wait loop (`08:7141`) tests `$c0` instead of `$40`, and
  returns with the pad in C, which `FarCallTrampoline` leaves alone. HELP's
  exit in bank 0 tests bit 7: START jumps to `$124f` (draw the tabs, enter
  SET), anything else to `FileBrowserEntry`. The stock `Delay($32)` there is
  gone to make room; `ReadJoypad` reports a button once per press
  ([joypad-latch.md](joypad-latch.md)), so a held START stops at SET.

Checked in SameBoy (1.05e-0731 and 1.05e-0918 as a CGB, 1.04e as a DMG): every step of both directions, the
overlay still on START in the browser, and START held on HELP.

## Shims (hand-assembled; see also [`../kernel/src/shims.md`](../kernel/src/shims.md))

`flcfg` is pinned at `$6600`; args are pushed last-first (op via `push af; inc sp`,
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
- `FlSetExitHook` `00:04e8` (13 B): armed or `SET_BACK` → `jp $0f8d` (browser);
  else `jp $1274` (HELP):
  `fa fe db 21 1c dc b6 c2 8d 0f c3 74 12`
  (14 B until 2026-11-11: `fa fe db b7 c2 8d 0f f8 0e 36 02 c3 67 12`, which
  replayed the mode variable's `= 2` and went through the stock check at
  `$1267`; nothing reads that variable past here)
- `FlPickCancelHook` `00:04f8` (10 B): not armed → stock no-op `$16ab`; armed →
  `jp $124f` (back to SET, which clears the flag):
  `fa fe db b7 ca ab 16 c3 4f 12`

The called-prologue offset (`FlSetEnterHook`) is the one to double-check on any
change: entering via `call` (not `jp`) puts SP two below the SET frame, so every
frame reference in the replayed instruction shifts by +2.

## Reproduce

Since mod 3.0 the file I/O lives in `ezcfg.c`, and `fastlaunch.c`, `flcfg.c`
and the hide filter are re-injected together by
[`scripts/inject-ezcfg.sh`](../scripts/inject-ezcfg.sh) (see
[`ezgb-cfg.md`](ezgb-cfg.md)). The shims and site patches below are unchanged
and are listed here as the record of what that script leaves in place; run it
for each version key, then one `python3 scripts/kernel-patch.py make`.

```bash
cd kernel; V=1.05e-0731
# bank 4: flcfg (via scripts/inject-ezcfg.sh) + shims + site patches
python3 tools/inject_bytes.py $V 4 5932 FlSetEnterHook  f8024d443e00f533c5cd0066e803f85e4d44210700c9 --apply
python3 tools/inject_bytes.py $V 4 5948 FlSetRowsHook   f8004d443e01f533c5cd0066e803c3f548 --apply
python3 tools/inject_bytes.py $V 4 5959 FlSetADispatch  f83d7e3dcad658f8004d443e02f533c5cd0066e8037bb7caf548c31259 --apply
python3 tools/inject_bytes.py $V 4 5976 FlPickCommitFar 3e03f533210000e5cd0066e803c9 --apply
python3 tools/patch_call.py   $V 4 47ef 7 04:5932 --apply
python3 tools/patch_call.py   $V 4 5404 3 04:5948 --jp --apply
python3 tools/patch_call.py   $V 4 560d 3 04:5948 --jp --apply
python3 tools/inject_bytes.py $V 4 5604 FlSetHiliteClamp d603 --apply
python3 tools/inject_bytes.py $V 4 5632 FlSetAHookSite  c25959 --apply
# bank 0
python3 tools/inject_bytes.py $V 0 04c7 FlPickHook       fafedbb7280acd8d0776590400c34f12cd8d072b480100c37015 --apply
python3 tools/inject_bytes.py $V 0 04e8 FlSetExitHook    fafedb211cdcb6c28d0fc37412 --apply
python3 tools/inject_bytes.py $V 0 04f8 FlPickCancelHook fafedbb7caab16c34f12 --apply
python3 tools/patch_call.py   $V 0 1263 4 00:04e8 --jp --apply
python3 tools/patch_call.py   $V 0 1569 7 00:04c7 --jp --apply
python3 tools/inject_bytes.py $V 0 164e FlPickCancelSite caf804 --apply
# START goes back a tab
python3 tools/patch_bytes.py  $V 0 1288 213200e5cd933ae802c38d0f cb79c24f12c38d0f00000000 --apply
python3 tools/patch_bytes.py  $V 8 714c 40 c0 --apply
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
`/FLAUNCH.CFG` files (pre-3.0 format): a fresh 25-byte create and a clean overwrite of a longer
file). The full live UI round-trip (checkbox toggle, pick-and-return, banner) was
not conclusively driven under the emulator; the emulator harness also ignores
`$7FC0`, so SD/FPGA-personality behavior only shows on hardware. **Hardware
testing is required** before relying on the feature, as with every prior
fast-launch milestone (GBC + GBA SP): confirm the toggle persists across a power
cycle, a picked root ROM and a subfolder LFN ROM both boot, browsing/launching
still work after a toggle or pick (no wedged SD controller), and a `#`-disabled
lone-ROM card boots to the browser.
