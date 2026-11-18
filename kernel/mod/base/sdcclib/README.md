# SDCC library code

Bank 0 links some of SDCC 2.9.0's C library, built the way SDCC's
`device/lib` builds it: plain `sdcc -mgbz80`, no options.

| File | Address | kernel.sym |
|---|---|---|
| `_strrchr.c` | `00:2c42` | `Strrchr` |
| `_strncpy.c` | `00:2cd3` | `Strncpy` |
| `_strlen.c` | `00:2d95` | `CStrLen` |

The files are SDCC 2.9.0's `device/lib`, unchanged. They `#include
"string.h"`, which comes from the SDCC 2.9.0 install.

It also links SDCC 2.9.0's gbz80 asm library (`device/lib/gbz80`):

| File | Address | kernel.sym |
|---|---|---|
| `crt0_rle.s` | `00:20bb` | `RleUnpack` |
| `stubs.s` | `00:2826` | `U32Mul` to `U32Div`, then the `_rrf_s` stubs |
| `div.s` | `00:288f` | `S8Div` to `U16DivMod` |
| `shift.s` | `00:298f` | `U32Shr`, `S32Sar`, `U32Shl` |

`stubs.s`, `shift.s` and `crt0_rle.s` are unchanged. `div.s` differs from
2.9.0's in two places, marked `;; ezgb:`: `ret C` where 2.9.0 has `jr
C,.exit`, and `.dvloop`'s exit, which drops the saved remainder before
branching again. No SDCC release or revision in SDCC's history has that
`div.s`; 2.7.0 and 2.8.0 keep the state in RAM. The math `stubs.s` jumps
to is not SDCC's: see `../src/libasm.s`.

## License

SDCC's library is under the GNU Library General Public License, version 2
or later (the file headers), not this repo's AGPLv3.
