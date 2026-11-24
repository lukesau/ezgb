# The mod kernel

The modded kernel, built from source. It started as the source of the stock
1.05e-0918 kernel ([kernel/stock](../stock/README.md)) and is its own
codebase: nothing here has to build to EZ Flash's bytes, and stock code is
changed or removed wherever the mod wants it different.
[kernel/stock](../stock) is the archive that still builds exactly to stock,
and has nothing of the mod in it.

```sh
make -C kernel/mod        # build/kernel.gb, 16 banks (256 KB)
```

It needs SDCC 2.9.0 for `base/` (`SDCC29=<install prefix>`, by default
`tools/sdcc-2.9.0`), a current SDCC for `src/` and for the assembler and
linker, and rgbds for `rgbfix` alone, which writes the header checksums. The
version on the HELP tab comes from `patches/kernel/VERSION`. A build takes
about five seconds. There is no checksum to match: the mod is tested by
running it. It does not need `kernel/stock`.

Only 0918 is a base. The mod on 1.04e and on 1.05e-0731 ended with mod 7.2:
1.04e is 1.05e without the clock, and 0731 differs from 0918 by one unused
routine, so neither has anything 0918 lacks. Kernel 1.06 is a separate tree,
[kernel/mod-1.06](../mod-1.06/README.md), with fixes and the first of the
mod's features.

## Layout

| Folder | What |
|---|---|
| `base/` | What was stock: EZ Flash's C (`base/src`) and the GBDK and SDCC library code it links (`base/gbdk`, `base/sdcclib`). Built with SDCC 2.9.0. It has the mod's changes written into it, with no conditionals: there is no stock build of this tree. |
| `src/` | The mod's C, built with a current SDCC. |
| `asm/` | What the mod has in assembly: the SGB packet sender, the jump past the boot ROM, the fast fill and decimal, the VBlank and joypad pieces. `Font12.s` includes the 12px glyph sets, which the Makefile packs from the sheets in `font12/` (`kernel/tools/font12-pack.py`). |
| `manifest.py` | Every source, by bank, with the compiler flags and the RAM each group of sources uses. Code is laid out in a bank in the order listed. |
| `names.txt` | Names the sources use that no source defines: fixed RAM addresses, and the stock disassembly's names for library routines (`ReadJoypad = _joypad`). |
| `tools/` | `build.py` (compile, link, write the ROM), `faraudit.py` (check every call between banks), `maccer.py` (GBDK's macro files). The other scripts belong to the old patch-based build. |

`base/src/mod.h` declares what `base/` uses of `src/` and `asm/`.

## What differs from stock in base/

Every change is in the source, not patched in after the link. Compare with
`kernel/stock` to see them: `diff -r kernel/stock/src kernel/mod/base/src`.
Beyond the mod's features:

- `RtcDebugDump`, the clock test screen 0918 added and nothing calls, is
  gone, and so is `DrawU32Decimal`, which only it called.
- The 0731 and 1.04e variants of the code are gone.

## Build

`tools/build.py` compiles every source in `manifest.py` and links them all
in one `sdldgb` link, so the linker resolves every name and nothing has a
fixed place in the ROM: change, move or delete a routine and the rest
follows. `make` then runs `tools/faraudit.py`.

**Two compilers, one calling convention.** A source under `base/` is built
with SDCC 2.9.0 and anything else with the current SDCC; the two share the
stack calling convention and their objects link together.

**Banks.** A source's code goes in the bank its group has in `manifest.py`.
The build renames each object's `_CODE` area to `_CODE_<bank>` and places
that area at `<bank>:$4000`; the linker takes an address above `$FFFF` as
bank and address. Bank 0 is laid out after crt0's header: `_HOME`, the
mod's `_MOD0A` to `_MOD0C`, GBDK's `_BASE`, then the C. The startup code
that fills initialized variables (`_GSINIT`) is in bank 1 after its code,
where EZ Flash had it. The build fails when a bank is too long and prints
the bytes free in each.

**Calls between banks** are `__banked` in both compilers, and one frame: two
words between the return address and the arguments. SDCC 2.9.0 calls through
`banked_call` (crt0) with the target and bank after the call, and leaves the
bank word empty: the build fills it with the bank of the function called.
The current SDCC loads `e` with `b_NAME` and calls `___sdcc_bcall_ehl`
(`asm/Bcall.s`); the build defines `b_NAME` as that function's bank. So
`base/` calls the mod's functions, and the mod's C calls into `base/`, by
name, with no stub. A far call written by hand in assembly has its bank as a
number, and `faraudit.py` fails the build when one no longer lands on a
routine.

**FatFs** is compiled five times, a different cut of `ff.c` for each of
banks 3, 5, 6, 7 and 9, so most of its names are defined five times. A name
defined in several groups means, inside a group that defines it, that
group's own; `PREFER` in `manifest.py` says which copy a caller outside
them gets.

**RAM is where stock has it.** EZ Flash's code and the mod both use fixed
RAM addresses throughout, so each group's variables are placed at the
address the stock kernel has them (`data=` in `manifest.py`), and the
buffers no source defines are addresses in `names.txt`. This is the part of
the stock layout that is still fixed.

**One routine runs from RAM.** `base/src/bank4_wram.c` is linked for
`$D100`, where the loader copies it, and stored at `04:4000` (`RAM_CODE` in
`manifest.py`).

## Not done

- RAM is still laid out by hand (above), and `names.txt` still carries the
  stock disassembly's names for routines the mod's sources call.

- The header comments in `src/*.c` and [src/shims.md](src/shims.md) still
  give the addresses and hook names of the patched kernels (mod 7.2 and
  earlier).
- `FillRect`, the SGB pieces, the boot ROM skip and the fast decimal in
  `asm/` are dumps of the rgbds sources they were written in.
