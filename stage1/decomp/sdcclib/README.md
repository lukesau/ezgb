# SDCC library code

Stage1 links three modules of SDCC 2.9.0's gbz80 library, the files from
SDCC 2.9.0's `device/lib`, unchanged:

| File | FW4 | What |
|---|---|---|
| `stubs.s` | `00:2732`-`279A` | the `_rrx_s` / `_rrf_s` entry points the compiler calls, jumping to the math |
| `shift.s` | `00:289B`-`28F1` | 32-bit shifts |
| `puts.c` | `00:2BA6`-`2BEA` | `puts`, compiled by SDCC 2.9.0 with no options |

The math the stubs jump to is not SDCC's: see [../asm](../asm/README.md).

## License

SDCC's library is under the GNU Library General Public License, version 2
or later (the file headers), not this repo's AGPLv3.
