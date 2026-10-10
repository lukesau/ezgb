# Last-ROM feature (START overlay), 1.05e

The file browser's **START** overlay shows the last-launched ROM and lets you re-run it
without navigating the tree. Reverse engineered statically from `re/1.05e-0731/disassembly`;
addresses are 1.05e. Confirmed against a photo of the physical menu (tab bar `SD / SET /
HELP`, a `1` index top-right, `DIR`-marked entries, the last-ROM line, and `[B]return` /
`[A]start` buttons).

## Summary

- The last-launched ROM's **full path** is persisted to **cart NVRAM at `$A300`** (255-byte
  record), written on every launch and read back when START is pressed.
- The overlay **displays only the basename** (path stripped at the last `/`), but **relaunch
  uses the full path**, so a ROM nested in a subdirectory (e.g. `/pokemon/Pokemon Blue.gb`)
  shows as `Pokemon Blue.gb` yet still loads from its real location.
- Confirmed joypad bits (post-`swap`, see `docs/launch-trace.md`): **START = `$80`**,
  **A = `$10`**, **B = `$20`**.

## The persisted record (`$A300`)

| Property | Value |
|---|---|
| Location | Cart address `$A300` (cart RAM/NVRAM window) |
| Access | Select **bank 17** (`ld a,$11` → `[$4000]`) + FPGA **rompage `$03`** |
| Size | 255 bytes (`$00`..`$fe` copy loop) |
| Contents | Full launch path as a C string, same format as `$c2a6` (e.g. `/pokemon/Pokemon Blue.gb`, long-filename form) |
| WRAM mirror | Read back into `$c4a4`; written from `$c2a6` |

## SD fallback when the coin cell dies (mod 3.8)

`$A300` is battery-backed, so a dead cell leaves random bytes there and the
stock overlay drew them as a garbage basename (confirmed on hardware). Two
changes fix this, both in the `ezcfg` settings module ([ezgb-cfg.md](ezgb-cfg.md)):

- **Validate the NVRAM record (option A).** Before the overlay draws, op
  `LASTLOAD` checks the `$A300` copy in `$c4a4`: first byte `/`, a NUL within
  255 bytes, no control/`$FF` bytes, and a non-empty basename with a `.`.
  Random NVRAM fails the first-byte test alone 255 times out of 256.
- **Fall back to the SD card (option B).** On every launch, op `LASTSAVE`
  also records the launch path as a `LASTROM=` line in `/EZGB.CFG`. When the
  `$A300` record fails validation, the overlay loads `LASTROM=` instead and
  draws that basename; `[A]` relaunches it through the normal path. If both
  are gone, the overlay shows `(none)` and only `[B]` responds.

NVRAM stays the primary source: a valid `$A300` record is used directly with
no SD access, so the common case is unchanged. The SD file is read only when
the record is corrupt.

Verified under SameBoy (corrupt record with and without a `LASTROM=` line, and
the write-on-launch path) and confirmed on GBC and GBA SP.

### Hooks

| Site | Was | Now |
|---|---|---|
| `01:48c1` | `add sp,$04; ret` (LastRomPersist tail, path assembled in `$c2a6`) | `jp LastRomSaveHook` (`01:7610`): op `LASTSAVE`, then the displaced tail |
| `00:12c8` | `jp nc, LastRomDrawBasename` (record-copy loop exit) | `jp nc, LastRomFallbackHook` (`00:0540`): op `LASTLOAD`, then `jp` to `LastRomDrawBasename` (`EZ_RES=1`) or `LastRomReturn` (`EZ_RES=0`) |

`LASTROM=` shares the module's 120-char path cap and the fixed-record rewrite,
so the record buffer grew to 512 B (`CFGBUF` at `$D800`) to hold three lines.
The save hook is at the persist **tail**, not its entry `01:4856`: the path is
assembled by the `FarCallTrampoline` early in `LastRomPersist`, so hooking the
entry captured a stale `/`.

## Overlay layout

The stock overlay draws its boxes first and its text afterwards, and the 8x8
text cells repaint parts of the boxes, on hardware as well as in SameBoy:

- `DrawLastRomButtons` (`08:73f5`) draws the outer box (x 0..159, y 112..143)
  and two button frames (x 5..81 and 85..155, y 132..142).
- The basename is `DrawString(name, 20, col 0, row 15)`, and `DrawString`
  pads an explicit length with spaces, so the whole row is repainted and the
  outer box loses its sides on that row: a bracket-like stub on each side.
- The button labels sit on row 17 (y 136..143), over the frames' bottom edge
  and the outer box's bottom line. Only the column between the labels kept
  its lines, which read as a bracket rotated by 90 degrees.

The mod replaces the chrome with one closed box holding three text rows: a
title (`Launch Last ROM?`), the name, and the two button labels. The name
sits on a solid ink band that spans the box, drawn in paper on ink, and a
vertical rule separates the two labels. It is drawn
in the font of the UI mode ([ui-mode.md](ui-mode.md)):

| | 8px | 12px |
|---|---|---|
| box | (0,91)-(159,139); the list is cleared from y 88 down | (0,92)-(159,143), flush under list row 5 (the 12px list starts at y 20, [tab-strip12.md](tab-strip12.md)) |
| title | tile row 12, column 1 | y 96, from x 12 |
| name | tile row 14, column 1, 18 characters | y 112, from x 12, as many glyphs as end 2 px short of the right side |
| labels | tile row 16, columns 1 and 11 | y 128, from x 12, one string |
| name band | y 107..123; vertical rule at x 83 below it | y 109..125; vertical rule at x 79 below it |

The 8x8 painter only draws on tile rows, so the 8px rows sit two tile rows
apart, and the band fills the name's row and half of the blank rows around it. For the 12px rows
`DrawString12` takes a pixel y: a `row` argument of 18 or more (past the
last tile row) is the y itself, rounded down to a multiple of 4 because the
flush writes in 4-row batches that must not cross a tile
([font12.md](font12.md)). The band and the rule are solid `DrawRect`s drawn
after the title and labels, since a text cell or a 12px row repaints all it
covers; `LastRomName` then draws with ink 0 on paper 3 and restores 3 on 0.

A name that does not fit its field scrolls, with the SET tab's marquee
behavior ([fastlaunch-set-tab.md](fastlaunch-set-tab.md)): a one-second
hold, then one character every 20 frames, repeating after three blanks. In
12px mode "fits" is the `Fit12` glyph count, and each step lays the window
out again, so a step is one character wide. The tick runs from the overlay's
input loop, timed by `hFrame` (`$fffa`); its state is the SET marquee's
`$DB38`/`$DB39`/`$DB3B` (the two screens are never up together) plus the
name pointer and length at `$DB3C`..`$DB3E`.

| Site (1.05e; 1.04e in brackets) | Was | Now |
|---|---|---|
| `00:12a1` (far-call target in `LastRomOverlay`) | `08:73f5` `DrawLastRomButtons` | `02:4800` `LastRomBox` (`lastrom_box.c`); the stock function is no longer called |
| `00:131d` (`00:1311`) | `ld hl,$0f00` .. `ld a,$14` | `ld hl,$0f01` .. `ld a,$12`: basename at column 1, 18 characters |
| `00:132b` | `call DrawString` | `call LastRomNameStub` (`00:0368`), a far stub to `02:7260` `LastRomName` (`lastrom_name.c`): sets the name up and draws it |
| `00:1330` (`LastRomInputLoop`) | `call ReadJoypad` | `call LastRomTickStub` (`00:0370`): pushes a null name pointer, calls `LastRomNameStub` (the marquee tick), then `jp ReadJoypad` |
| `ezcfg.c` `lastrom_load` | `DrawString("(none)", 20, 0, 15)` | near call to `LastRomName` |

`DrawString12` paints its row out to x 159, over the box's right side, so
`LastRomBox` follows its 12px draws with an outline-only `DrawRect` of the box, then the band and the rule; the name's row is ink out to the border, so it needs no repair. For
the name, `LastRomName` asks `Fit12` for the pen positions and drops
trailing glyphs that start past x 148, so the ink stops short of the border.

Checked in SameBoy (DMG model, 0731): both modes, a short name, a long one
scrolling, `(none)`, and B back to the browser (the list is redrawn in full).

`$A300` (bank 17 + rompage `$03`) sits in the same battery-backed cart PSRAM window as save
meta, so `$A300` is lost if the coin cell dies; see [psram-save-map.md](psram-save-map.md) and
`hardware-board.md`.

## Write side (persist on launch), bank 1

On the normal load path, after the launch path is assembled in `$c2a6`, the loader copies it
into `$A300`:

```1677:1749:re/1.05e-0731/disassembly/bank_001.asm
Jump_001_4856:
    ld hl, $c4a4
    push hl
    ld hl, $c2a6
    push hl
    call Call_000_078d          ; assemble/copy path into $c2a6
    ...
    ld bc, $4000
    ld a, $11
    ld [bc], a                  ; select cart bank 17
    ld a, $03
    push af
    inc sp
    call Call_001_47a7          ; FPGA rompage $03 (bank-1-local; cf. bank4 $41e7)
    ...
Jump_001_487d:                  ; for i in 0..254:
    ...
    ld hl, $a300
    add hl, de                  ; dest = $a300 + i
    ...
    ld de, $c2a6                ; src  = $c2a6 + i
    ...
    ld [de], a                  ; $a300[i] = $c2a6[i]
    ...
Jump_001_48b2:
    ld bc, $4000
    ld a, $00
    ld [bc], a                  ; restore bank 0
```

## Read + display + relaunch, bank 0 (START handler)

### Trigger: START = bit `$80`

```4015:4021:re/1.05e-0731/disassembly/bank_000.asm
Jump_000_1294:
    ld hl, sp+$00
    ld a, [hl]
    and $80                     ; START?
    jr nz, jr_000_129e          ; -> last-ROM overlay
    jp Jump_000_1392            ; else A / other keys
```

### `jr_000_129e`: draw overlay + load the record

1. Far-call bank8 **`$73f5`**: draws the overlay chrome and the `[B]return` / `[A]start`
   buttons (button strings at bank8 `$7458` / `$7462`, right after that function's `ret` at
   `$7457`).
2. Select cart NVRAM (bank 17; rompage `$03` via bank4 `$41e7`) and copy 255 bytes
   `$A300` → `$c4a4` (`Jump_000_12bf` loop), the mirror of the bank-1 write.

### `Jump_000_12f1`: display basename only

```4094:4133:re/1.05e-0731/disassembly/bank_000.asm
Jump_000_12f1:
    ld bc, $4000
    ld a, $00
    ld [bc], a                  ; restore bank 0
    ...
    ld a, $2f                   ; '/'
    push af
    inc sp
    ld hl, $c4a4
    push hl
    call Call_000_2c42          ; strrchr(path, '/')
    add sp, $03
    ld b, d
    ld c, e
    ld hl, $0001
    add hl, bc                  ; basename = last '/' + 1
    ...
    ld hl, $0f00                ; screen position
    push hl
    ld a, $14                   ; max 20 chars
    push af
    inc sp
    ...
    call Call_000_08b7          ; draw basename
```

`Call_000_2c42` is a `strrchr`: it walks to the NUL, then scans backward for the target
character, returning the last `/` regardless of nesting depth. The overlay draws only from
`last '/' + 1`, hiding the directory prefix.

### `Jump_000_1330`: overlay input loop (A = start, B = return)

```4131:4201:re/1.05e-0731/disassembly/bank_000.asm
Jump_000_1330:
    call Call_000_3a4a
    ...
    and $10                     ; A = start
    jr nz, jr_000_1344
    jp Jump_000_1385
jr_000_1344:
    ...                         ; split path at last '/':
    call Call_000_2cba          ;   copy directory prefix ($c4a4) -> $c2a6
    ...
    call Call_000_078d          ;   open directory
    ...
    call Call_000_20e2          ;   apply basename against $c4a4
    add sp, $04
    call Call_000_078d          ;   -> normal load path (bank8 $737f "Loading....")
Jump_000_1385:
    ld hl, sp+$04
    ld a, [hl]
    and $20                     ; B = return
    jr nz, jr_000_138f
    jp Jump_000_1330
jr_000_138f:
    jp Jump_000_0f8d            ; back to browser entry -> re-enumerates directory
```

Relaunch (A) does **not** discard the directory prefix: it computes the prefix length
(`basename_ptr − $c4a4 − 1`), copies the prefix into `$c2a6`, opens that directory, then uses
the basename before funneling into the same load sequence the file browser uses, so a nested
ROM shown by basename still loads from its full path. B (`$20`) returns via `jp Jump_000_0f8d`,
the browser entry, which re-reads the directory (a fresh FS read).

## Related bank-8 status-box draws

The overlay button drawer is one of a small family of status-box functions in bank 8, each
reached via the `$078d` far-call trampoline. Entry addresses and their strings:

| Bank8 entry | String (addr) | Text | Caller(s) |
|---|---|---|---|
| `$7344` | `$7374` | `Reading....` | bank0 `$0fa0` |
| `$737f` | `$73af` | `Loading....` | bank0 `$137b`, `$145f`, and relaunch `$1344` |
| `$73ba` | `$73ea` | `Error file` | bank0 `$1550` |
| `$73f5` | `$7458` / `$7462` | `[B]return` / `[A]start` | bank0 `$129e` (this overlay) |

## Helpers referenced

| Symbol | Role |
|---|---|
| `Call_000_078d` | Far-call trampoline; 4-byte inline blob `[lo][hi][bank][pad]` (see `docs/launch-trace.md`) |
| `Call_000_2c42` | `strrchr(ptr, char)`, used with `'/'` to find the basename |
| `Call_000_2cba` | `memcpy(dest, src, len)`, copies the directory prefix |
| `Call_000_20e2` | Applies/appends the basename against `$c4a4` (exact semantics unconfirmed) |
| `Call_000_08b7` | Draw string `(ptr, len, pos)` |
| `Call_000_3a4a` | Read joypad (returns key byte) |
| `Call_001_47a7` | FPGA rompage set (bank-1-local; counterpart to bank4 `$41e7`) |

## Confirmed key bits (post-`swap` joypad byte)

| Bit | Key | Status |
|---|---|---|
| `$80` | START | Confirmed (this trace) |
| `$20` | B | Confirmed |
| `$10` | A | Confirmed |
| `$02` | Left | From `docs/launch-trace.md` |
| `$01` | Right | From `docs/launch-trace.md` |
| `$40` | SELECT (SET/HELP tabs) | Not yet confirmed |
| `$04` / `$08` | Up / Down | Not yet confirmed |

## B-mode / direct-boot implication

`$A300` already holds a full, directory-qualified path in the exact format the loader consumes
(`$c2a6` = `/dir/NAME.GB`). A later B-mode kernel (or a deferred stock-kernel hook) reading
`$A300` and driving the `jr_000_1344` split-and-load sequence would handle nested ROMs without
the file browser. See [`omega-jr-compare.md`](omega-jr-compare.md) and
[`fast-launch-notes.md`](fast-launch-notes.md).

The other half of a B-mode boot, skipping the SD→NOR copy because the game is already in
NOR, exists as a dormant, caller-less kernel primitive (`RomLoad_ResetIntoRom_B4`,
`04:4180`); an experimental hook makes this overlay's A press use it. See
[`nor-reuse.md`](nor-reuse.md).

> **Correction (2026-10-09).** The game is not in NOR. It is in **U9's volatile
> pSRAM**, so after a power cycle there is nothing valid to boot. The hook was
> reverted on 2026-08-30. See the correction at the top of
> [`nor-reuse.md`](nor-reuse.md).

## Open questions / verification TODO

- Live-confirm under SameBoy: break at `$1294` / `$129e`, dump `$A300` and `$c4a4`; break at
  bank1 `$4856`/`$487d` on a launch to watch the write.
- Exact semantics of `Call_000_20e2` in the relaunch path (basename apply vs. concat).
- Whether `$A300` is also read at cold boot (initial overlay contents) or only on first START.
- 1.04e counterpart addresses for the same chain (expect same shape, shifted).
