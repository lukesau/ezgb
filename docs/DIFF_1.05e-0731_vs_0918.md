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
the insertion, each moved by `+$262` (`+$26b` for targets between the insertion
and the 9 deleted bytes). They are relocations, not logic changes.

The bank's trailing free space paid for it: the 610 displaced bytes were all
`$ff` filler. Bank 1 is not full: stock 0918 still ends in 2,573 bytes of `$ff`
(`$75f3`-`$7fff`), against 3,183 in 0731.

### Where the new code went

A byte diff puts the divergence at `$4dd0`: the two builds are identical up to
`$4dcf`, whose last instructions are:

```asm
call SetFpgaPage_B1     ; 01:47a7
add  sp, $01
```

In 0731 that is 370 bytes into `RtcToDayCount` (`01:4c5e`), but the new code is
not spliced into that routine. It is a separate 619-byte routine placed in
front of it, at `01:4c5e`-`01:4ec8` (`RtcDebugDump` in
`re/1.05e-0918/kernel.sym`). It opens with the same 370 bytes of clock-reading
code as `RtcToDayCount`, which is why a byte diff finds the first difference
370 bytes in. The real `RtcToDayCount` follows at `01:4ec9`, byte for byte the
0731 routine, and its two callers (`01:505e` in `RtcWriteTimeFromDayDelta`,
`01:5348` in `RtcReadDaysClearRegs`) were repointed.

After the shared opening, the new routine does:

```asm
ld   hl, $00bc          ; \  32-bit literal $00BC614E = 12345678
push hl                 ;  |
ld   hl, $614e          ;  |
push hl                 ; /
call DrawU32Decimal     ; 00:092a
add  sp, $04
```

then prints the year, month, day, hour, minute and second it just decoded, each
with `DrawU32Decimal`, calls `WaitJoypadSelect` (`00:07bc`) and returns.

It is an RTC test screen left in the build, and nothing calls it: no `call` /
`jp` operand and no `FarCallTrampoline` entry in the ROM targets `01:4c5e`.
These seven calls are also the only calls to `DrawU32Decimal` in any of the
three kernels.

The 9 deleted bytes are at the end of `RtcWriteTimeFromDayDelta`. 0731 calls
`SetFpgaPage_B1($00)` twice in a row before returning
(`3e 00 f5 33 cd a7 47 e8 01`, twice); 0918 drops the redundant second call.

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
would be 8.0). The standard Xilinx sync word `AA995566` does not appear, in
normal or bit-reversed form. This section predates
[flash-map.md](../re/stage0/docs/flash-map.md), which found two bitstream sync words
in each FW5 payload: two images, the second identical between 0731 and 0918
(the golden / fallback image) and the first 61% different (the active image).
See that page for the layout.

## Assessment of the reported claims

**Super Game Boy support: not visible in the kernel, and that makes sense.**
`$0146` is `$00` in both builds, so the kernel still does not advertise itself
as SGB-enhanced. That is not evidence against the claim: an SGB reads the
cartridge header once at power-on, so SGB features for a *launched* game depend
on what the cart presents to the console at power-on, an FPGA behavior, not a
kernel one. Consistent with the payload being where the change is.

**SD corruption on slow cards: no evidence in the kernel.** The inserted
routine is an uncalled RTC test screen, not the SD path, and banks 2–9 (which
hold the SD and FatFs code) are byte-identical. If this fix is real, it is in
the FPGA payload too.

**Overall:** 0918 is the same kernel as 0731 plus one uncalled debug routine,
with a substantially different FPGA image. The interesting delta for this
project is not the kernel.

## What this means for our work

- Our `re/1.05e-0731` annotations remain valid for 0918, offset in bank 1 by
  `+619` for `$4c5e`-`$50ce` and `+$262` (610) from `$50d8`.
- Bank 1 has 2,573 free bytes left in stock 0918 (`$75f3` up). Our injections
  live in bank 0 (`$01e3-$02fa`, `$03cc`), which is unaffected, so
  `browser_scroll` and `DirListSkipDotLongName` would port across unchanged.
- The 0918 kernel's global checksum is `$f8b5` and correct for its own contents,
  unlike our patched build (see `scripts/build-ezgb-dat.sh`).

## Next steps

- [x] Identify the payload layout: done in
      [flash-map.md](../re/stage0/docs/flash-map.md) (two images per FW5 payload).
- [x] Determine what the inserted RTC block does: an uncalled test screen;
      `12345678` is a literal (see above).
- [ ] Decide whether to port our two bank-0 patches onto 0918 and run it.

## Port of the injected features (2026-08-30)

All injected features (fast launch, browser sort/scroll/page-end, dotfile
filter, tab banner, NOR reuse; see [nor-reuse.md](nor-reuse.md)) were ported
from the 0731 featured build to 0918 by replaying the byte diff
(`re/1.05e-0731/kernel.gb.orig` → `kernel.gb`) onto the stock 0918 dump:

- All 20 diff regions land in bytes that are identical between the two stock
  kernels (none overlap the six relocated bank-0 operands), so the port is
  byte-exact. The only bank-1 reference in any injected code is a far-call to
  `DrawBrowserDetail` (`01:42ba`), below the `$4dd0` insertion and therefore
  unmoved.
- `re/1.05e-0918/kernel.gb` is the ported featured build (md5 `6cf9bf64`);
  `kernel.gb.orig` is stock (md5 `5238ac59`). `kernel.sym` / `notes.json`
  were ported with the bank-1 remap (+619 for `$4dd0`–`$50ce`, +610 from
  `$50d8`; nothing named lived in the 9 deleted bytes), validated by 3-byte
  spot checks (all mismatches were pointer-relocation operands) and by the
  disassembly round-trip (`make` rebuilds the ROM bar the usual header bytes).
  That remap left the `RtcToDayCount` name on the new routine at `$4c5e`;
  corrected 2026-09-29 (`RtcDebugDump` at `$4c5e`, `RtcToDayCount` at `$4ec9`,
  `REMAP` / `TARGET_ONLY` in `scripts/port-mod.py`).
- SameBoy-verified on the 0918 build: boots to the (sorted, filtered) browser,
  and Start→A relaunch runs the full FPGA config then boots via the no-copy
  path with zero `$7f36` writes. Normal-launch copy path was verified on the
  identical 0731 code earlier the same day.

The `re/` folders were renamed to carry the build date (`re/1.05e-0731`,
`re/1.05e-0918`); the decomp/inject tools accept both as version keys.
