# Stock kernel from source

A build of the stock 1.05e-0731 kernel (`ezgb.dat`, md5
`91eb7fc67332ef20b5691029181ff748`) that the C rewrite grows in. It starts as
the rgbds disassembly and replaces routines with real source one at a time;
`make` fails unless the result is still byte-identical to stock.

This is separate from `re/kernel/`, whose disassembly is regenerated from the
modded kernel after every injection. Everything here is stock.

```sh
make -C decomp        # build/kernel.gb, checked against the stock md5
```

Needs rgbds and SDCC 4.x (`sdasgb`, `sdldgb`, `sdcc`). No dump is needed: the
build compares against the md5, not a file.

## Layout

| Path | What |
|---|---|
| `asm/` | Stock disassembly (mgbdis + `re/kernel/1.05e-0731/kernel.sym` names and notes). Hand-maintained from here on: a routine that moves to source is deleted here and replaced by an `INCLUDE` of its generated file. |
| `gbdk/` | GBDK library code the kernel links, as EZ Flash modified it. GPLv2 with linking exception, not this repo's AGPLv3: see `gbdk/README.md`. |
| `tools/sdinc.py` | Assembles or compiles one source with SDCC, links its areas at the stock addresses, and writes each address range as an rgbds include (`db` bytes plus `Name::` labels for the source's global symbols). External symbols come from `kernel.sym`. |
| `build/` | Generated includes and the built kernel (gitignored). |

## Moving a routine to source

1. Write the source: GBDK library asm in `gbdk/`, C in `src/` (once the
   compiler is pinned, see below). Give its globals the names `asm/` uses
   (`LcdOff::` next to `.display_off::`) so the rest of the disassembly links.
2. Add an `sdinc.py` rule to the `Makefile` with the area placements (`-b`)
   and the address range(s) to emit.
3. In `asm/bank_NNN.asm`, delete the routine's lines and `INCLUDE` the
   generated file in their place.
4. `make`. A wrong byte fails the md5 check; a label the rest of the asm still
   needs fails the rgbds link.

## Status

| Range | Source | What |
|---|---|---|
| `00:0000`-`01e3` | `gbdk/crt0.s` | RST/interrupt vectors, interrupt dispatcher, cartridge header, startup (`KernelEntry`) |
| `00:0600`-`07bc` | `gbdk/crt0.s` | `crt0` `_HOME` area: mode table jump, interrupt list add/remove, VBlank and serial handlers, `display_off`, OAM DMA stub, `banked_call` |

Compiled C is not in yet. The bank-9 FatFs is R0.11a (config in
`docs/PROGRESS.md`), and the closest compiler found so far is an SDCC
development build from early 2012 with `--opt-code-size`, but no function
matches byte for byte yet.
