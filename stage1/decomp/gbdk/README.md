# GBDK library code

Stock stage1 is a GBDK program: bank 0 starts with GBDK's runtime
(`crt0.s`), modified by EZ Flash, and its library code includes several of
GBDK 2.96a's library modules. The files here are their sources, linked as
GBDK's `lcc` did: crt0 first, the library modules after the program.

- `global.s`: GBDK 2.96a `libc/gb/global.s`, unchanged.
- `crt0.s`: GBDK 2.96a `libc/gb/crt0.s` with EZ Flash's changes, each marked
  `;; ezflash:`. It is the kernel's crt0
  ([kernel/stock/gbdk](../../../kernel/stock/gbdk/README.md))
  with stage1's header (title `BOOTLOADER`; on FW5-0918 the SGB flag and
  licensee `$33`) and GBDK's ending put back: `call gsinit`, then `main`
  called directly (no `EI`, no `banked_call`). The header bytes that differ
  per firmware come from `fw.s`, which `link.py` writes.

## Library modules

GBDK 2.96a's `libc/gb` sources, unchanged:

| File | FW4 | What |
|---|---|---|
| `font.s` | `00:28F2`-`2930` (`_CODE`), `00:2D25`-`2FE2` (`_BASE`), `00:03CD` | `putchar`, the console, font loading and text mode |
| `cpy_data.s` | `00:2FE3`-`3004` | `set_data`, `get_data` |
| `ibmfixed.s` | `00:3005`-`390D` | the 8x8 font |
| `pad.s` | `00:390E`-`3960` | joypad |
| `delay.s` | `00:3961`-`39A3` | `delay` |

`font.s` is `font.ms` after GBDK's macro preprocessor (`maccer`), recovered
from the `font.lst` listing in the GBDK 2.96a binary release. Its mode-table
entry, `.org`ed at `$01E9`, is at `$03CD` in stock: GBDK 2.96a's linker put
it after crt0's `_HEADER` area (`$01E4` + `$01E9`), and `tools/link.py`
moves it there.

The rest of the library code is SDCC 2.9.0's ([../sdcclib](../sdcclib/README.md))
or matches no published source ([../asm](../asm/README.md)).

## License

These files are GBDK library code and stay under GBDK's license, GPLv2 with a
linking exception (`LICENSE_GPLV2_LE`, from GBDK-2020, which relicensed the
historical GBDK library under it). They are not covered by this repo's AGPLv3.
