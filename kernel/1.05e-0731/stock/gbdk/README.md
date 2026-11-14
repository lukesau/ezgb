# GBDK library code

The EZ Flash Jr kernel is a GBDK program: bank 0 starts with GBDK's runtime
(`crt0.s`), modified by EZ Flash. The files here reproduce it from GBDK's
source.

- `global.s`: GBDK 2.96a `libc/gb/global.s` with `.MODE_TABLE` at `$01E2`
  (2.96a has `$01E0`), marked `;; ezflash:`; crt0.s and the library modules
  all see it.
- `include/`: GBDK 2.96a's headers, unchanged, for the kernel C in `../src`
  (built with `-DBYTE_IS_UNSIGNED=1`).
- `crt0.s`: GBDK 2.96a `libc/gb/crt0.s` (identical to GBDK-2020 3.0.1's) with
  EZ Flash's changes, each marked `;; ezflash:`. In short: an interrupt nesting
  count (`__int_nest`) used by the dispatcher, `enable_interrupts`/
  `disable_interrupts` and `banked_call`; ROM bank 1 selected at startup; the
  kernel's init instead of `gsinit`/`banked_call _main`; `_reset`,
  `_clock` and `__printTStates` removed. Global
  labels without a leading dot are the kernel disassembly's names for the
  same addresses.
- `drawing.s`: GBDK 2.96a `libc/gb/drawing.s` with two changes, marked
  `;; ezgb:`, that reproduce stock's layout: `fg_colour` and `bg_colour`
  come after `.ty` in `_BSS` (`$D734`), and `.vbl`/`.lcd` sit in an area of
  their own, which the Makefile places at `$2A5F`, between other library
  code. The code itself is unchanged, so EZ Flash's GBDK was likely a
  nearby revision.
- `cpy_data.s`, `ibmfixed.s`, `pad.s`, `delay.s`, `init_tt.s`, `font.ms` and
  `wait_hbl.mh`: GBDK 2.96a `libc/gb`, unchanged. GBDK runs `.ms` files
  through its macro expander, maccer; `../tools/maccer.py` does the same
  for `font.ms` (into `build/font.s`).

## License

These files are GBDK library code and stay under GBDK's license, GPLv2 with a
linking exception (`LICENSE_GPLV2_LE`, from GBDK-2020, which relicensed the
historical GBDK library under it). They are not covered by this repo's AGPLv3.
