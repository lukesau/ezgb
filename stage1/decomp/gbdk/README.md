# GBDK library code

Stock stage1 is a GBDK program: bank 0 starts with GBDK's runtime
(`crt0.s`), modified by EZ Flash. The files here reproduce it from GBDK's
source, and `tools/link.py` links it first, as GBDK's `lcc` did.

- `global.s`: GBDK 2.96a `libc/gb/global.s`, unchanged.
- `crt0.s`: GBDK 2.96a `libc/gb/crt0.s` with EZ Flash's changes, each marked
  `;; ezflash:`. It is the kernel's crt0
  ([kernel/1.05e-0731/stock/gbdk](../../../kernel/1.05e-0731/stock/gbdk/README.md))
  with stage1's header (title `BOOTLOADER`; on FW5-0918 the SGB flag and
  licensee `$33`) and GBDK's ending put back: `call gsinit`, then `main`
  called directly (no `EI`, no `banked_call`). The header bytes that differ
  per firmware come from `fw.s`, which `link.py` writes.

## The rest of bank 0

The library code after the C (`$2732` on) is still disassembly. Matched by
function against GBDK 2.96a's prebuilt library and SDCC 2.9.0's gbz80
library, relocated bytes masked (FW4 addresses):

| FW4 | Module | Source |
|---|---|---|
| `2732`-`279A` | `stubs` (16/32-bit math entry points) | SDCC 2.9.0 `device/lib/gbz80/stubs.s` |
| `279B`-`289A` | 8/16-bit divide | SDCC 2.9.0 `div.s` up to `$283D`; the unsigned 16-bit loop differs from every SDCC and GBDK version tried |
| `289B`-`28F1` | 32-bit shifts | `shift.s` (same in SDCC 2.9.0 and GBDK 2.96a) |
| `28F2`-`2927`, `2DB0`-`2FE2` | console and font code | GBDK 2.96a `libc/gb/font.s`, by function |
| `2928`-`2BA5`, `2BEB`-`2DAF` | 32-bit multiply and divide engines, `memcpy`, compares, the rest of `font.s`'s neighbors | not identified: not SDCC 2.9.0's C library under any flags tried |
| `2BA6`-`2BEA` | `puts` | SDCC 2.9.0 `device/lib/puts.c` |
| `2FE3`-`3004` | `set_data` / `get_data` | GBDK 2.96a `cpy_data.s` |
| `3005`-`390D` | the 8x8 font | GBDK 2.96a `ibmfixed.s` |
| `390E`-`3960` | joypad | GBDK 2.96a `pad.s` |
| `3961`-`39A3` | `delay` | GBDK 2.96a `delay.s` |

`$03CD` (`jp EnterGfxMode2`) is a mode-table entry another GBDK module
places at an absolute address; it stays disassembly too.

## License

These files are GBDK library code and stay under GBDK's license, GPLv2 with a
linking exception (`LICENSE_GPLV2_LE`, from GBDK-2020, which relicensed the
historical GBDK library under it). They are not covered by this repo's AGPLv3.
