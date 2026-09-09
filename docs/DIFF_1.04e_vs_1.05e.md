# Kernel diff: 1.04e vs 1.05e (K1.05RC)

Accounting of every place the two kernel binaries differ in behavior. Useful before any
modified or alternate kernel (including a future B-mode image): understand both versions well
enough that work against either does not collide with version-specific changes.

Source: `re/1.04e/kernel.gb` (SHA1 `43c76dc...`) vs `re/1.05e-0731/kernel.gb` (SHA1 `ce1d531...`),
both hash-verified against EZ Flash's own distribution. Disassemblies in
`re/1.04e/disassembly/` and `re/1.05e-0731/disassembly/`.

## Methodology

Two diff passes, cross-checked against each other:

1. Byte-level diff per bank (`difflib.SequenceMatcher` on raw bank bytes, bank = 0x4000-byte
   slice of the ROM). This is ground truth: it operates on the actual bytes, not on
   disassembly text that can be affected by mgbdis's auto-generated label names.
2. Label-normalized disassembly diff (strip mgbdis's auto-generated `Label_/Call_/Jump_/
   Data_XXX_YYYY` address-based names before diffing text), used to sanity-check the byte
   diff and to read change regions as actual instructions rather than raw hex.

Only bank 0 and bank 1 contain real content changes. Every other bank (2-9) is byte-for-byte
identical content, just relocated: every difference in banks 2-9 is a `call`/`jp` operand
whose target shifted because bank 0's code grew. Verified exhaustively for banks 2, 5, 7, 8;
not re-verified for 3/4/6/9, but the pattern is consistent (bank 0 grew, everything
referencing bank 0 addresses shifts).

### Pitfall: "shift-noise" inside a bank

Not every byte-level diff region is a real logic change. When code is inserted partway through
a bank, every string-pointer or same-bank-address literal after the insertion point shifts by
the same delta. Because these are usually 16-bit little-endian immediates where only the low
byte changes, `SequenceMatcher` frequently fails to find a clean alignment and reports a large
`replace` spanning tens of bytes, when the actual change is a single operand moving from
`$18f6` to `$190f` (a 25-byte shift matching a real insertion found elsewhere in the same bank)
and nothing else.

Confirmed case: the battery-dry-notice function (`Call_000_1835` in 1.05e / `Call_000_181c` in
1.04e, same function, shifted by 25 bytes) shows a ~65-byte "replace" cluster in the raw byte
diff. Manually decoding both sides byte-by-byte showed the function is identical logic: every
difference is a string-pointer literal shifting by exactly 25, matching the two small
insertions elsewhere in bank 0 (below). Any diff region that looks unusually large or messy
relative to its neighbors should be checked for this before being treated as a real change.

## Bank 0 changes

| Offset (old to new) | Size | Status | What it is |
|---|---|---|---|
| `0x982` (old only) | -4B | Real | See "Retry-counter change" below |
| `0xe89` region | +16B | Real | See "New cached field" below |
| `0x15d3` region | +13B | Not yet decoded | Small insert, not analyzed in detail yet |
| `0x1847`-`0x18b3` cluster | net 0 | Shift-noise, not real | Battery-dry-notice function (`Call_000_1835`/`Call_000_181c`), confirmed identical logic; string-pointer operands shifted by the 25 bytes from the two changes above |
| `0x1a61` | +928B | Real, largest bank-0 change | Confirmed to start exactly at `Call_000_1a7a` (1.05e address), a register-write helper targeting `$7fc0` (bank-select family, see `docs/REGISTERS.md`) that does not exist anywhere in bank 0 of 1.04e (`grep` for `7f00` in `1.04e/disassembly/bank_000.asm` returns zero hits, vs one in 1.05e). `Call_000_1a77` immediately before it (a trivial 3-byte `return 0`-shaped function, confirmed identical in both versions via `decomp/` matching, see `docs/PROGRESS.md`) is unaffected, confirming the insertion boundary. The other ~925 bytes of this insert haven't been read through yet; likely where most of the RTC rewrite and/or turbo-loading logic lives. Priority for follow-up. |
| `0x1f0e`-`0x1fa8` cluster | net ~0 | Likely shift-noise | Same shape as the battery-notice cluster (short alternating replace pairs); not individually confirmed but pattern matches the 928-byte shift cascading through subsequent string/address literals |
| `0x246e`-`0x2479` cluster | net ~0 | Likely shift-noise | Same reasoning as above |
| `0x379c`-`0x37a0` | -2B | Not yet decoded | Small, near end of bank, not analyzed |
| end-of-bank padding | -953B | Not real | Less unused filler at the end of the bank because ~953 net bytes of real code were added earlier (25 + 928 = 953, matches exactly) |

### Retry-counter change (`0x982`, confirmed)

`DrawU32Decimal` (`00:092a`; 1.04e notes pointed at the preceding `DrawString`
epilogue as a locator) tracks two paired counters in WRAM: `$cc30` (an inner
retry/attempt count) and `$cc2f` (an outer failure count). Logic in 1.04e: increment
`$cc30` each call; if it reaches 20, reset `$cc30` to 0 and increment `$cc2f`. In
1.05e, the reset of `$cc30` is kept but the increment of `$cc2f` is removed,
confirmed by direct byte comparison (the deleted 4 bytes are exactly `ld hl,$cc2f` /
`inc [hl]`, opcodes `21 2f cc 34`).

`$cc2f` is read elsewhere: the battery-dry notice clears it to 0, and
`SdReadRetryCount` (right after the retry function) reads `$cc2f` and passes it to
the UI-draw call, i.e. it's a user-visible counter, plausibly the "Micro SD Initial
Error!" retry count shown to the user. Removing the "bump the visible counter" step
while keeping the inner reset is consistent with the changelog's "Supported CGB
without CPU suffix (Micro SD Initial Error issue)." This is the strongest candidate
so far for that specific fix, not yet confirmed by tracing what actually calls into
this counter function or what consumes `$cc2f`'s displayed value.

### New cached field (`0xe89`, confirmed)

A repeating "copy struct field via `[de]` to `[hl]`, advance both pointers" loop (copying
several config/save-type fields one byte at a time) gets one extra instruction in 1.05e: right
after reading a byte via `ld a,[de]`, it now also stores that same byte to a new global,
`ld hl,$d3f6` / `ld [hl],a`. 1.04e reads the same struct field but never caches it anywhere.
`$d3f6` doesn't appear anywhere in 1.04e. It's a new piece of kernel state. Not yet determined
which struct field is being cached or what reads `$d3f6` back out.

## Bank 1 changes

Bank 1 has substantially more real content growth (~3175 net bytes vs bank 0's ~953) and is
where the RTC rewrite lives.

| Offset (old to new) | Size | Status | What it is |
|---|---|---|---|
| `0x80b`/`0x8a6` cluster | +32B, +29B (confirmed new function) | Real | See "New register-write helper" below |
| `0xa25` | +62B | Not yet decoded | |
| `0xaf1`-`0xc2a` cluster | +206B, +31B | Not yet decoded in detail | Falls in `DateToDaysSince1970` (`01:4xxx`); likely more RTC-related register plumbing given proximity to the confirmed changes around it, not confirmed |
| `0xc6c` | +197B | Partially confirmed | The block containing the NOR-flash write sequence (`ld bc,$4000/ld a,$11/ld[bc],a` then `ld bc,$a000/ld a,$aa/ld[bc],a`), see "RTC NOR-flash persistence" below |
| `0x1a88`-`0x1b06` cluster | -13B, +28B, +339B, +31B | Confirmed real, large | Contains the `TIME:`/`SET`/`AUTO SAVE:` menu-string-adjacent code and further NOR-flash-style writes (`$A000`/`$A001`/`$A00F`/`$A010`/`$A202`/`$A210`/`$A211`, a family of `$A0xx`-`$A2xx` addresses, consistent with a small in-cart RTC/NVRAM register block, not just a one-off flash unlock byte) |
| `0x2728` | +56B | Not yet decoded | |

### New register-write helper (`0x80b`, confirmed)

In 1.04e, this address is a bare, already-unlocked single write: `$7ff0 = $e4` (the
commit-only tail of some register operation started elsewhere), then `ret`. In 1.05e, a whole
new function is inserted directly after that `ret`: a full unlock (`$7f00=e1, $7f10=e2,
$7f20=e3`), a write of a dynamic (stack-supplied) value to `$7fd4`, then commit (`$7ff0=e4`).
`$7fd4` is in the same port cluster as `$7fd0`/`$7fd2` already catalogued in `docs/REGISTERS.md`
as an enable/disable-shaped register family. This register write capability did not exist in
1.04e, and correlates with the "RTC codes are rewritten" changelog line.

### RTC NOR-flash persistence (`0xc6c`, `0x1a88`-`0x1b06`, shape confirmed, purpose hypothesis)

Two separate 1.05e-only code blocks write through a consistent pattern: `ld bc,$4000 / ld
a,$11 / ld [bc],a` (a standard-shaped MBC ROM-bank-select write, selecting bank 17)
immediately followed by writes into the `$A0xx`/`$A2xx` cartridge-RAM window using `$AA` as a
leading byte in at least one case (`$AA` is the first byte of a JEDEC NOR flash unlock/write
command). Bank 17 select plus `$A000`-window writes shaped like flash commands, appearing only
in the version whose changelog claims "RTC codes are rewritten," is a case (not dynamically
confirmed) that those writes touch RTC-related persistence. **Caveat:** the Jr’s cart battery
backs the **RTC *and* the save PSRAM** (the Jr has no FRAM, see
`hardware-board.md`), and `$A000=$AA` is also the documented
BACKUPSAVE pending stamp in PSRAM (`docs/psram-save-map.md`). Do not treat `$AA` alone as proof
of JEDEC NOR. See `docs/1.05e-instability.md`.

## Confirmed vs hypothesis, summary

Confirmed by direct byte/instruction reading:
- Banks 2-9 have zero logic changes, only relocated call targets.
- The battery-dry-notice function is unchanged logic between versions (shift-noise, not a
  real diff).
- `$cc2f`/`$cc30` retry-counter logic changed: the outer counter increment was removed.
- A new global (`$d3f6`) was added, caching a struct field that 1.04e reads but never stores.
- A new register-write function targeting `$7fd4` was added.
- NOR-flash-shaped write sequences (bank-17 select plus `$A0xx` writes with a JEDEC-style
  unlock byte) appear only in 1.05e, concentrated in the same bank/region as the RTC-related
  menu strings.

Hypothesis, not yet confirmed:
- That `$7fd4` and the `$A0xx`/`$A2xx` register family are specifically RTC status/data
  registers (plausible from context and changelog correlation, not proven).
- That the removed `$cc2f` increment is the fix behind "Micro SD Initial Error" (circumstantial
  case, not traced).
- Purpose of the still-undecoded regions: `0x15d3` and `0x379c` (bank 0); `0xa25`, the
  `0xaf1`-`0xc2a` cluster, and `0x2728` (bank 1).
- The biggest open item: the 928-byte insertion at bank 0 `0x1a61`, the largest contiguous
  new-code block in either bank, not yet read through. Given its size, this likely contains
  the bulk of whatever "RTC codes are rewritten" and "turbo loading speed" actually consist
  of, and should be the next thing read in detail before drawing conclusions about what
  changed between the two kernels.

## Next steps

1. Read through the bank-0 `0x1a61` 928-byte insertion in full. It's the largest undocumented
   change and likely the crux of the RTC/turbo-loading rewrite.
2. Decode the remaining small undecoded regions (`0x15d3`, `0x379c` in bank 0; `0xa25`,
   `0xaf1`-`0xc2a`, `0x2728` in bank 1) to rule out further shift-noise vs real changes.
3. Dynamic tracing (SameBoy) on both kernel versions at the confirmed change points
   (`$cc2f`/`$cc30` retry function, the `$7fd4` register writer, the NOR-flash write
   sequences) would convert several of the above hypotheses into confirmed facts faster than
   continued static reading.

## Port of the injected features (2026-09-09)

All injected features (sorted browser, scrolling, icons and DMG contrast,
hide filter, fast launch, SET-tab configuration, EZGB.CFG with RTC backup,
last-ROM fallback, path bound check, HELP-tab version) were ported from the
1.05e-0731 build to 1.04e with `scripts/port-mod.py`
([DEVELOPMENT.md](DEVELOPMENT.md#porting-the-mod-to-another-kernel-build)),
not by hand. Unlike the 0918 port, this one could not be a byte replay: every
hook site in banks 0, 1 and 4 moves, and so do most bank-0 routines the
injected code calls.

What the port had to translate, all mechanically from the address map:

- **Injected blocks** land in the same free space in both kernels (bank 0
  `$01e3`–`$0588` and `$3d8c`–`$3fc5`, bank 1 `$7600`, bank 2 `$4380`/`$4500`/
  `$4a00`, bank 4 `$5932`–`$5f1b`, bank 8 `$746b`–`$7cff`); 1.04e has more
  free space than 1.05e everywhere.
- **Bank 0 targets** shift by `+4` after the retry-counter change (`$0982`),
  `-12` after the cached-field insert (`$0e89`), `-25` after `$15d3`, and
  `-953` after the `$1a61` insertion: `StoreDrawParams` `$2791`→`$23d8`,
  `DrawRect` `$27ba`→`$2401`, `ReadJoypad` `$3a4a`→`$3691`, `Strrchr`
  `$2c42`→`$2889`, the FatFs thunks `-25`, `LastRomRelaunch` `$1344`→`$1338`,
  the font glyphs `$3806`→`$344d`. `DrawString`, `DrawU32Decimal`,
  `FarCallTrampoline`, `WaitVBlankFlag` and the bank-0 cave are unmoved.
- **Bank 1** sites move by `-32` (`LoaderPrepPath`, `LastRomPersistDone`),
  `-2734` and `-3119` (the `BackupSaveDump` epilogue `$6738`→`$5b09`).
  The `DrawBrowserDetail`/`DrawBrowserEntries` sites below `$480b` are unmoved.
- **Bank 4** moves by `-4`, `-12`, `-15` or `-27` depending on the region;
  banks 2, 5, 7, 8 are identical, banks 3/6/9 only relocate bank-0 operands.
- **Two sites needed a human decision.** `DrawTimeAutosaveScreen_redraw`
  (`04:48f5`) keeps its address but opens with `call WaitVBlankFlag` in 1.04e
  where 1.05e tests its time-set flag, so the map cannot align it; it is
  pinned (`OVERRIDES`). And the DMG-contrast retune at `04:4e49` patches a
  `StoreDrawParams` + `DrawString` pair in `DrawTimeAutosaveScreen_savRedraw`
  that only 1.05e has; 1.04e has nothing to retune there (`SKIP_SITES`).
- **WRAM.** The browser buffers the mod uses (`$c2a2`, `$c2a6`, `$c4a4`,
  `$c5a4`, the FIL at `$ca0f`) and its own scratch (`$d780`–`$dbff`) have the
  same role or are equally unused in 1.04e. 1.05e's RTC day tables were
  inserted at `$d6a7`, so the kernel's runtime globals from `$d6cc` up sit 39
  bytes lower in 1.04e (`$d6ce`→`$d6a7` VBlank flag, callback lists
  `$d6d3`→`$d6ac`); nothing injected touches them directly, only through
  `WaitVBlankFlag`, which is pinned per version.
- The HELP screen draws `K1.04e` (no date; FW4 had a single kernel build).

`re/1.04e/kernel.sym` and `notes.json` are ports of the 0731 files through the
same map (53 names dropped: 1.05e-only routines such as `SetFpgaPage_B0` /
`RtcReadPage`, and the inserted day tables); comment text still quotes 0731
addresses. The regenerated disassembly reassembles to the ported kernel
byte for byte (`scripts/build-kernel.sh 1.04e`).

Verified under SameBoy with the EZ Jr stub: boot to the sorted, filtered,
icon-drawn browser; scrolling; SET tab with the FAST LAUNCH and ROM PICK rows;
PICK writing `EZGB.CFG` and reading it back; HELP tab text; launching a ROM
with a 32 KB save from the browser; fast launch of the configured ROM at the
next boot (Pokémon Red, save restored, `$7FE0=$80` issued), repeated from
clean state, and with the post-paint hook variant. One caveat: the very first
fast-launch attempt in the emulator crashed during the save restore (the
stub log showed the CPU looping on `rst $38`); it never recurred in a dozen
later runs on either kernel, including deliberate replays of that run's
config and PSRAM state, so it is recorded here rather than explained. Not
yet run on a real cart (both an FW4 and an FW5 cart are available, and the
stock 1.04e kernel is known to run on FW5), which is the test that matters.
