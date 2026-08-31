# Kernel diff: 1.05e FW5 2020-07-31 vs 2021-09-18

A newer FW5 exists that EZ Flash never posted on their site, reported in
[issue #1](https://github.com/lukesau/ezgb/issues/1) by `gus33000`:
`ezjunior-fw5-0918.zip`, sha1 `d3c6b091677ce0ab5b02b2575c23d1e7fa9194b7`, from
`https://www.ezflash.cn/zip/ezjunior-fw5-0918.zip`. The claims made there are
SD-card corruption fixes on slower cards, and Super Game Boy support.

This is the same comparison as [DIFF_1.04e_vs_1.05e.md](DIFF_1.04e_vs_1.05e.md),
applied to the two FW5 builds.

> **Never run or modify `Update_FW*.gb`.** Everything here is static analysis of
> the files. Launching an updater is what bricked a cart earlier in this project
> (see [hardware-board.md](hardware-board.md)).

## Identity

| | 0731 | 0918 |
|---|---|---|
| `ezgb.dat` | 163,840 B, sha1 `ce1d5316…0f3a134f` | 163,840 B, sha1 `d575f637…adb4b2ff` |
| file date | 2020-07-29 | 2021-09-09 |
| `Update_FW5*.gb` | 331,800 B, sha1 `80ef33af…f59e90557` | 331,800 B, sha1 `46464fe0…f88f10b67` |
| file date | 2020-07-31 | 2021-09-18 |

Both kernels are byte-identical in header: title `EZGB`, `$0143`=`$00`,
`$0146`=`$00`, `$0147`=`$01`, `$0148`=`$00`, `$0149`=`$00`, `$014B`=`$00`.

## Methodology

Byte diff, then `difflib.SequenceMatcher` per bank to separate real edits from
shift-noise, the pitfall documented in the 1.04e/1.05e diff. Symbol context
comes from `re/1.05e-0731/kernel.sym`, which is annotated against the 0731 build.

A fresh mgbdis disassembly of the new build is at `re/1.05e-0918/`.

## The kernel changed very little

Only **banks 0 and 1** differ. Banks 2–9 are byte-identical.

### Bank 0: 12 bytes, all mechanical

| Offset | 0731 → 0918 | Meaning |
|---|---|---|
| `$014e`-`$014f` | `$7b57` → `$f8b5` | ROM global checksum |
| `$01da` | `$68b6` → `$6b18` | far-call target, +610 |
| `$0f55` | `$6747` → `$69a9` | far-call target, +610 |
| `$1577` | `$5e14` → `$6076` | `RomLoaderMain`, +610 |
| `$15a8` | `$5163` → `$53c5` | `BackupOpenSaverPath`, +610 |
| `$15b5` | `$58b0` → `$5b12` | far-call target, +610 |

No new call sites in bank 0. Every change is a relocation of an existing
`FarCallTrampoline` target by exactly **+610 (`$262`)**.

### Bank 1: one 610-byte insertion, plus ~200 pointer fixups

```
insert  619 bytes at $4dd0
delete    9 bytes at $50cf
delete  610 bytes of $ff filler from the bank tail ($7d9e-$7fff)
net       +0 file size, +610 bytes of code
```

The ~200 remaining two-byte edits are all 16-bit operands pointing at or past
the insertion, each moved by `+$262`. They are relocations, not logic changes.

The bank's trailing free space paid for it: the 610 displaced bytes were all
`$ff` filler, so the insertion consumed the bank's remaining headroom exactly.
**Bank 1 is now full**, worth knowing before planning any injection there.

### Where the new code went

The two builds are identical up to `$4dcf`, whose last instructions are:

```asm
call SetFpgaPage_B1     ; 01:47a7
add  sp, $01
```

and then diverge. That is **inside `RtcToDayCount` (01:4c5e)**: the new code is
spliced into the middle of an RTC routine, immediately after an FPGA page
select.

What the inserted block does, confirmed from its bytes:

```asm
ld   hl, $00bc          ; \  32-bit literal $00BC614E = 12345678
push hl                 ;  |
ld   hl, $614e          ;  |
push hl                 ; /
call DrawU32Decimal     ; 00:092a
add  sp, $04
```

then repeats a pattern of reading successive bytes from a structure
(offsets +0, +3, +6, +7 …) and writing them into a stack frame, interleaved
with further `DrawU32Decimal` calls.

**Confirmed:** location, size, that it calls `DrawU32Decimal`, and that it is
reached inline from `RtcToDayCount` after an FPGA page select.

**Not established:** its purpose. Drawing the literal `12345678` reads like a
diagnostic or placeholder rather than a shipping feature, but that is a guess
from one constant. Nothing calls `$4dd0` as a function: no `call`/`jp` and no
`FarCallTrampoline` data entry targets it, consistent with it being inline
code rather than a new routine.

## The real payload is the FPGA side

The updater is where the substantive change is:

| Region | Size | 0731 vs 0918 |
|---|---|---|
| banks 0–1 (`$00000-$07fff`) | 32 KB | **identical**, the updater program itself |
| banks 2–11 (`$08000-$2ffff`) | 163,840 B | 91,495 bytes differ (~56%) |

That payload region is **not** the kernel: `ezgb.dat` is not embedded verbatim
anywhere in the updater, and the kernel's own diff is only 10,134 bytes, far
short of 91,495. A ~56% byte difference across a region is the signature of
replacing high-entropy data wholesale.

Its size matches what [hardware-board.md](hardware-board.md) already
established: an XC3S200A bitstream is ~1,196,128 bits ≈ 146 KB, and 163,840 B
is that plus a wrapper.

The payload is neither raw nor encrypted: entropy is 4.61 bits/byte (random
would be 8.0), but no Xilinx sync word `AA995566` appears, in normal or
bit-reversed form. So it is encoded or wrapped in a format not yet identified.

## Assessment of the reported claims

**Super Game Boy support: not visible in the kernel, and that makes sense.**
`$0146` is `$00` in both builds, so the kernel still does not advertise itself
as SGB-enhanced. That is not evidence against the claim: an SGB reads the
cartridge header once at power-on, so SGB features for a *launched* game depend
on what the cart presents to the console at power-on, an FPGA behaviour, not a
kernel one. Consistent with the payload being where the change is.

**SD corruption on slow cards: no evidence in the kernel.** The 610 inserted
bytes are in an RTC routine, not the SD path, and banks 2–9 (which hold the SD
and FatFs code) are byte-identical. If this fix is real, it is in the FPGA
payload too.

**Overall:** 0918 is essentially the same kernel as 0731 plus one inlined block,
with a substantially different FPGA image. The interesting delta for this
project is not the kernel.

## What this means for our work

- Our `re/1.05e-0731` annotations remain valid for 0918, offset by `+$262` for bank-1
  addresses at or beyond `$4dd0`. `kernel.sym` needs no rework to read the new
  build.
- **Bank 1 has no free space left in 0918.** Our injections live in bank 0
  (`$01e3-$02fa`, `$03cc`), which is unaffected, so `browser_scroll` and
  `DirListSkipDotLongName` would port across unchanged.
- The 0918 kernel's global checksum is `$f8b5` and correct for its own contents,
  unlike our patched build (see `scripts/build-ezgb-dat.sh`).

## Next steps

- [ ] Identify the payload encoding; the missing sync word is the thread to
      pull. Compare against the SPI flash dump taken during the cart repair;
      that dump is a known-good decoded image of the same data.
- [ ] Determine what the inserted RTC block actually does, and whether
      `12345678` is a literal or a misread of a pointer pair.
- [ ] Decide whether to port our two bank-0 patches onto 0918 and run it.

## Port of the injected features (2026-08-30)

All injected features (fast launch, browser sort/scroll/page-end, dotfile
filter, tab banner, NOR reuse — see [nor-reuse.md](nor-reuse.md)) were ported
from the 0731 featured build to 0918 by replaying the byte diff
(`re/1.05e-0731/kernel.gb.orig` → `kernel.gb`) onto the stock 0918 dump:

- All 20 diff regions land in bytes that are identical between the two stock
  kernels (none overlap the six relocated bank-0 operands), so the port is
  byte-exact. The only bank-1 reference in any injected code is a far-call to
  `DrawBrowserDetail` (`01:42ba`), below the `$4dd0` insertion — unmoved.
- `re/1.05e-0918/kernel.gb` is the ported featured build (md5 `6cf9bf64`);
  `kernel.gb.orig` is stock (md5 `5238ac59`). `kernel.sym` / `notes.json`
  were ported with the bank-1 remap (+619 for `$4dd0`–`$50ce`, +610 from
  `$50d8`; nothing named lived in the 9 deleted bytes), validated by 3-byte
  spot checks (all mismatches were pointer-relocation operands) and by the
  disassembly round-trip (`make` rebuilds the ROM bar the usual header bytes).
- SameBoy-verified on the 0918 build: boots to the (sorted, filtered) browser,
  and Start→A relaunch runs the full FPGA config then boots via the no-copy
  path with zero `$7f36` writes. Normal-launch copy path was verified on the
  identical 0731 code earlier the same day.

The `re/` folders were renamed to carry the build date (`re/1.05e-0731`,
`re/1.05e-0918`); the decomp/inject tools accept both as version keys.
