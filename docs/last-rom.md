# Last-ROM feature (START overlay), 1.05e

The file browser's **START** overlay shows the last-launched ROM and lets you re-run it
without navigating the tree. Reverse engineered statically from `re/1.05e/disassembly`;
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

`$A300` (bank 17 + rompage `$03`) sits in the same cart FRAM window as save meta (see
`docs/fram-save-map.md`). FRAM needs no battery; the cart’s battery is for the RTC only.
Older notes that lumped this window with “NOR/NVRAM for RTC” should be read with that
split in mind (`docs/DIFF_1.04e_vs_1.05e.md` / `docs/1.05e-instability.md`).

## Write side (persist on launch) — bank 1

On the normal load path, after the launch path is assembled in `$c2a6`, the loader copies it
into `$A300`:

```1677:1749:re/1.05e/disassembly/bank_001.asm
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

## Read + display + relaunch — bank 0 (START handler)

### Trigger: START = bit `$80`

```4015:4021:re/1.05e/disassembly/bank_000.asm
Jump_000_1294:
    ld hl, sp+$00
    ld a, [hl]
    and $80                     ; START?
    jr nz, jr_000_129e          ; -> last-ROM overlay
    jp Jump_000_1392            ; else A / other keys
```

### `jr_000_129e`: draw overlay + load the record

1. Far-call bank8 **`$73f5`** — draws the overlay chrome and the `[B]return` / `[A]start`
   buttons (button strings at bank8 `$7458` / `$7462`, right after that function's `ret` at
   `$7457`).
2. Select cart NVRAM (bank 17; rompage `$03` via bank4 `$41e7`) and copy 255 bytes
   `$A300` → `$c4a4` (`Jump_000_12bf` loop) — the mirror of the bank-1 write.

### `Jump_000_12f1`: display basename only

```4094:4133:re/1.05e/disassembly/bank_000.asm
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

`Call_000_2c42` is a `strrchr`: it walks to the string's NUL, then scans backward for the
target character, so it returns the last `/` regardless of nesting depth. The overlay draws
only from `last '/' + 1`, hiding the directory prefix in the prompt.

### `Jump_000_1330`: overlay input loop (A = start, B = return)

```4131:4201:re/1.05e/disassembly/bank_000.asm
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
(`basename_ptr − $c4a4 − 1`), copies the prefix into `$c2a6` and opens that directory, then
uses the basename before funneling into the same load sequence the file browser uses. That is
why a nested ROM shown by basename still loads from its full path. B (`$20`) returns via
`jp Jump_000_0f8d`, the browser entry, which re-reads the directory (a fresh FS read).

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
| `Call_000_2c42` | `strrchr(ptr, char)` — used with `'/'` to find the basename |
| `Call_000_2cba` | `memcpy(dest, src, len)` — copies the directory prefix |
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
(`$c2a6` = `/dir/NAME.GB`). A later B-mode kernel (or a deferred stock-kernel hook) that reads
`$A300` and drives the `jr_000_1344` split-and-load sequence would handle nested ROMs without
the file browser. Mapping the ASM comes first; see [`omega-jr-compare.md`](omega-jr-compare.md)
and [`fast-launch-notes.md`](fast-launch-notes.md).

## Open questions / verification TODO

- Live-confirm under SameBoy: break at `$1294` / `$129e`, dump `$A300` and `$c4a4`; break at
  bank1 `$4856`/`$487d` on a launch to watch the write.
- Exact semantics of `Call_000_20e2` in the relaunch path (basename apply vs. concat).
- Whether `$A300` is also read at cold boot (initial overlay contents) or only on first START.
- 1.04e counterpart addresses for the same chain (expect same shape, shifted).
