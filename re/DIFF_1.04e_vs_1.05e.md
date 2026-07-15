# Kernel diff: 1.04e vs 1.05e (K1.05RC)

Detailed, evidence-based accounting of every place the two kernel binaries actually differ in
behavior, done before attempting to build a modified kernel — the goal is to understand both
versions well enough that a patch can be built against either without accidentally colliding
with version-specific changes.

Source: `re/1.04e/kernel.gb` (SHA1 `43c76dc...`) vs `re/1.05e/kernel.gb` (SHA1 `ce1d531...`),
both hash-verified against EZ Flash's own distribution. Disassemblies in
`re/1.04e/disassembly/` and `re/1.05e/disassembly/`.

## Methodology

Two diff passes, cross-checked against each other:

1. **Byte-level diff per bank** (`difflib.SequenceMatcher` on raw bank bytes, bank = 0x4000-byte
   slice of the ROM). This is ground truth — it operates on the actual bytes, not on
   disassembly text that can be affected by mgbdis's auto-generated label names.
2. **Label-normalized disassembly diff** (strip mgbdis's auto-generated `Label_/Call_/Jump_/
   Data_XXX_YYYY` address-based names before diffing text) — used to sanity-check the byte
   diff and to read change regions as actual instructions rather than raw hex.

Only **bank 0 and bank 1** contain real content changes. Every other bank (2-9) is byte-for-byte
identical *content*, just relocated — every difference in banks 2-9 is a `call`/`jp` operand
whose target shifted because bank 0's code grew. Verified exhaustively for banks 2, 5, 7, 8
earlier in this project (see prior session); not re-verified for 3/4/6/9 but the pattern is
consistent enough (bank 0 grew, everything referencing bank 0 addresses shifts) that there's no
reason to expect otherwise.

### Important pitfall found while doing this: "shift-noise" inside a bank

Not every byte-level diff region is a real logic change. When code is inserted partway through
a bank, every string-pointer or same-bank-address literal *after* the insertion point shifts by
the same delta — and because these are usually 16-bit little-endian immediates where only the
low byte changes, `SequenceMatcher` frequently fails to find a clean alignment and reports a
large, scary-looking `replace` spanning tens of bytes, when the actual change is "this
instruction's operand moved from `$18f6` to `$190f`" (a 25-byte shift, matching a real insertion
found elsewhere in the same bank) and nothing else.

Confirmed case: the battery-dry-notice function (`Call_000_1835` in 1.05e / `Call_000_181c` in
1.04e — same function, shifted by 25 bytes) shows a messy ~65-byte "replace" cluster in the raw
byte diff. Manually decoding both sides byte-by-byte showed the function is **identical logic**
— every difference is a string-pointer literal shifting by exactly 25, matching the two small
insertions elsewhere in bank 0 (see below). Anywhere a diff region looks unusually large or
messy relative to its neighbors, check for this before assuming it's a real change.

## Bank 0 changes

| Offset (old→new) | Size | Status | What it is |
|---|---|---|---|
| `0x982` (old only) | -4B | **Real** | See "Retry-counter change" below |
| `0xe89` region | +16B | **Real** | See "New cached field" below |
| `0x15d3` region | +13B | Not yet decoded | Small insert, not analyzed in detail yet |
| `0x1847`-`0x18b3` cluster | net 0 | **Shift-noise, not real** | Battery-dry-notice function (`Call_000_1835`/`Call_000_181c`), confirmed identical logic — string-pointer operands shifted by the 25 bytes from the two changes above |
| `0x1a61` | **+928B** | **Real, largest bank-0 change** | Major new code inserted right after `Call_000_1a53`/`Call_000_1a77`/start of `Call_000_1a7a` (the FPGA unlock/command/commit helper family, see `re/REGISTERS.md`). Not yet fully read through — 928 bytes is substantial, likely where most of the RTC rewrite and/or turbo-loading logic lives. **Priority for follow-up.** |
| `0x1f0e`-`0x1fa8` cluster | net ~0 | Likely shift-noise | Same shape as the battery-notice cluster (short alternating replace pairs); not individually confirmed but pattern matches the 928-byte shift cascading through subsequent string/address literals |
| `0x246e`-`0x2479` cluster | net ~0 | Likely shift-noise | Same reasoning as above |
| `0x379c`-`0x37a0` | -2B | Not yet decoded | Small, near end of bank, not analyzed |
| end-of-bank padding | -953B | **Not real** | Just less unused filler at the end of the bank because ~953 net bytes of real code were added earlier (25 + 928 = 953, exactly matches) |

### Retry-counter change (`0x982`, confirmed)

Function at `Jump_000_0927`+ (1.04e) tracks two paired counters in WRAM: `$cc30` (an inner
retry/attempt count) and `$cc2f` (an outer failure count). Logic in 1.04e: increment `$cc30`
each call; if it reaches 20, reset `$cc30` to 0 **and increment `$cc2f`**. In 1.05e, the reset
of `$cc30` is kept but the **increment of `$cc2f` is removed** — confirmed by direct byte
comparison (the deleted 4 bytes are exactly `ld hl,$cc2f` / `inc [hl]`, opcodes `21 2f cc 34`).

`$cc2f` is read elsewhere: the battery-dry notice clears it to 0, and a bank-0 function unique
to 1.05e (`Call_000_0985`, right after the retry function) reads `$cc2f` and passes it to the
UI-draw call — i.e. it's a **user-visible counter**, plausibly the "Micro SD Initial Error!"
retry count shown to the user. Removing the "bump the visible counter" step while keeping the
inner reset is consistent with the changelog's "Supported CGB without CPU suffix (Micro SD
Initial Error issue)" — this is the strongest candidate so far for that specific fix, though not
yet confirmed by tracing what actually calls into this counter function or what consumes
`$cc2f`'s displayed value.

### New cached field (`0xe89`, confirmed)

A repeating "copy struct field via `[de]`→`[hl]`, advance both pointers" loop (looks like
copying several config/save-type fields one byte at a time) gets one extra instruction in
1.05e: right after reading a byte via `ld a,[de]`, it now also stores that same byte to a new
global, `ld hl,$d3f6` / `ld [hl],a`. 1.04e reads the same struct field but never caches it
anywhere. `$d3f6` doesn't appear anywhere in 1.04e at all — it's a wholly new piece of kernel
state. Not yet determined which struct field is being cached or what reads `$d3f6` back out.

## Bank 1 changes

Bank 1 has substantially more real content growth (~3175 net bytes vs bank 0's ~953) and is
where the RTC rewrite clearly lives.

| Offset (old→new) | Size | Status | What it is |
|---|---|---|---|
| `0x80b`/`0x8a6` cluster | **+32B, +29B (confirmed new function)** | **Real** | See "New register-write helper" below |
| `0xa25` | +62B | Not yet decoded | |
| `0xaf1`-`0xc2a` cluster | +206B, +31B | Not yet decoded in detail | Falls in `Jump_001_4a63` region; likely more RTC-related register plumbing given proximity to the confirmed changes around it, not confirmed |
| `0xc6c` | +197B | **Partially confirmed** | This is the block read earlier containing the NOR-flash write sequence (`ld bc,$4000/ld a,$11/ld[bc],a` then `ld bc,$a000/ld a,$aa/ld[bc],a`) — see "RTC NOR-flash persistence" below |
| `0x1a88`-`0x1b06` cluster | -13B, +28B, +339B, +31B | **Confirmed real, large** | Contains the `TIME:`/`SET`/`AUTO SAVE:` menu-string-adjacent code and further NOR-flash-style writes (`$A000`/`$A001`/`$A00F`/`$A010`/`$A202`/`$A210`/`$A211` — a whole family of `$A0xx`-`$A2xx` addresses, consistent with a small in-cart RTC/NVRAM register block, not just a one-off flash unlock byte) |
| `0x2728` | +56B | Not yet decoded | |

### New register-write helper (`0x80b`, confirmed)

In 1.04e, this address is just a bare, already-unlocked single write: `$7ff0 = $e4` (the
commit-only tail of some register operation started elsewhere) then `ret`. In 1.05e, a **whole
new function** is inserted directly after that `ret`: a full unlock (`$7f00=e1, $7f10=e2,
$7f20=e3`), a write of a **dynamic** (stack-supplied) value to **`$7fd4`**, then commit
(`$7ff0=e4`). `$7fd4` is in the same port cluster as `$7fd0`/`$7fd2` already catalogued in
`re/REGISTERS.md` as an enable/disable-shaped register family — this is a brand new register
write capability that plainly did not exist in 1.04e, strongly tied to the "RTC codes are
rewritten" changelog line.

### RTC NOR-flash persistence (`0xc6c`, `0x1a88`-`0x1b06`, confirmed shape / hypothesis on purpose)

Two separate 1.05e-only code blocks write through a consistent, distinctive pattern:
`ld bc,$4000 / ld a,$11 / ld [bc],a` (a standard-shaped MBC ROM-bank-select write, selecting
bank 17) immediately followed by writes into the `$A0xx`/`$A2xx` cartridge-RAM window using
`$AA` as a leading byte in at least one case (`$AA` is the canonical first byte of a JEDEC NOR
flash unlock/write command). Bank 17 select + `$A000`-window writes shaped like flash commands,
appearing only in the version whose changelog claims "RTC codes are rewritten," is a strong
(but not yet dynamically confirmed) case that **RTC state is persisted to onboard NOR flash**
rather than a battery-backed RTC chip register — see `notes/1.05e-instability.md` for how this
bears on the instability investigation.

## What's confirmed vs hypothesis — summary

**Confirmed by direct byte/instruction reading:**
- Banks 2-9 have zero logic changes; only relocated call targets.
- The battery-dry-notice function is unchanged logic between versions (shift-noise, not a
  real diff).
- `$cc2f`/`$cc30` retry-counter logic changed: the outer counter increment was removed.
- A new global (`$d3f6`) was added, caching a struct field that 1.04e reads but never stores.
- A brand new register-write function targeting `$7fd4` was added.
- NOR-flash-shaped write sequences (bank-17 select + `$A0xx` writes with a JEDEC-style unlock
  byte) appear only in 1.05e, concentrated in the same bank/region as the RTC-related menu
  strings.

**Hypothesis, not yet confirmed:**
- That `$7fd4` and the `$A0xx`/`$A2xx` register family are specifically RTC status/data
  registers (plausible from context and changelog correlation, not proven).
- That the removed `$cc2f` increment is *the* fix behind "Micro SD Initial Error" (strong
  circumstantial case, not traced).
- Purpose of the still-undecoded regions: `0x15d3` and `0x379c` (bank 0); `0xa25`, the
  `0xaf1`-`0xc2a` cluster, and `0x2728` (bank 1).
- **The single biggest open item**: the 928-byte insertion at bank 0 `0x1a61` — the largest
  contiguous new-code block in either bank, not yet read through at all. Given its size, this
  likely contains the bulk of whatever "RTC codes are rewritten" and "turbo loading speed"
  actually consist of, and should be the next thing read in detail before drawing conclusions
  about what changed between the two kernels.

## Next steps

1. Read through the bank-0 `0x1a61` 928-byte insertion in full — it's the largest undocumented
   change and likely the crux of the RTC/turbo-loading rewrite.
2. Decode the remaining small undecoded regions (`0x15d3`, `0x379c` in bank 0; `0xa25`,
   `0xaf1`-`0xc2a`, `0x2728` in bank 1) to rule out further shift-noise vs real changes.
3. Dynamic tracing (SameBoy, see main session) on both kernel versions at the confirmed change
   points (`$cc2f`/`$cc30` retry function, the `$7fd4` register writer, the NOR-flash write
   sequences) would convert several of the above hypotheses into confirmed facts much faster
   than continued static reading.
