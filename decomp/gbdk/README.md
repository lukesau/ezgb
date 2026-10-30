# GBDK library code

The EZ Flash Jr kernel is a GBDK program: bank 0 starts with GBDK's runtime
(`crt0.s`), modified by EZ Flash. The files here reproduce it from GBDK's
source.

- `global.s`: GBDK 2.96a `libc/gb/global.s`, unchanged.
- `crt0.s`: GBDK 2.96a `libc/gb/crt0.s` (identical to GBDK-2020 3.0.1's) with
  EZ Flash's changes, each marked `;; ezflash:`. In short: an interrupt nesting
  count (`__int_nest`) used by the dispatcher, `enable_interrupts`/
  `disable_interrupts` and `banked_call`; ROM bank 1 selected at startup; the
  kernel's own init instead of `gsinit`/`banked_call _main`; `_reset`,
  `_clock` and `__printTStates` removed; the mode table at `$01E2`. Global
  labels without a leading dot are the kernel disassembly's names for the
  same addresses.

## License

These files are GBDK library code and stay under GBDK's license, GPLv2 with a
linking exception (`LICENSE_GPLV2_LE`, from GBDK-2020, which relicensed the
historical GBDK library under it). They are not covered by this repo's AGPLv3.
