# SDCC library code

Bank 0 links some of SDCC 2.9.0's own C library, built the way SDCC's
`device/lib` builds it: plain `sdcc -mgbz80`, no options.

| File | Address | kernel.sym |
|---|---|---|
| `_strrchr.c` | `00:2c42` | `Strrchr` |
| `_strncpy.c` | `00:2cd3` | `Strncpy` |
| `_strlen.c` | `00:2d95` | `CStrLen` |

The files are SDCC 2.9.0's `device/lib`, unchanged. They `#include
"string.h"`, which comes from the SDCC 2.9.0 install.

## License

SDCC's library is under the GNU Library General Public License, version 2
or later (the file headers), not this repo's AGPLv3.
