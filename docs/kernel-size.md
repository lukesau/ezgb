# Kernel size: 16 banks

The stock kernels are 10 banks (160 KB). After stars and play counts, banks 2,
4 and 5 were full, and the space free in all three builds was a few hundred
bytes in each of banks 3, 6, 7 and 9. Since 2026-10-30 the modded kernel is
**16 banks (256 KB)**: banks 10 to 15 were empty (10 to 13 hold code now, 14 and 15 are still empty), room for the theme engine
([issue 12](https://github.com/lukesau/ezgb/issues/12)) and anything after it.

## Why it works

Stage1 loads the whole of `ezgb.dat`, by its file size, into the cart's game
pSRAM with bank N at N × `$4000` ([fpga-stage1.md](fpga-stage1.md)). In kernel
mode the FPGA's ROM bank register at `$2000` is a plain 8-bit latch: bit 0 is
address line A13 and bits 1 to 7 go out through the 74HC595
(`stage0/docs/design.md` on the bitstream-re branch). So the kernel can map
any of 256 banks of whatever the file holds, with the same `$2000` write
`FarCallTrampoline` already does.

Hardware test, 2026-10-30: a kernel with an 11th bank, a copy of bank 8 with
its version text changed to `BANK 10` and every far call into bank 8 pointed
at bank 10, showed `BANK 10` on the HELP screen on both the FW4 and the FW5
cart (mod firmware 2.0, through the picker). Not tested with stock stage1,
which builds the same load command.

256 KB is the next power of two, so `rgbfix` pads the reassembled ROM to
exactly that, and the six extra banks cost little at boot: with FW5's fast
load, about 0.07 s more to load (an estimate).

## What changed in the tools

| Tool | Change |
|---|---|
| `kernel/re/<ver>/kernel.gb` | 262,144 bytes; banks 10-15 are `$FF` until code goes there |
| `scripts/build-kernel.sh` | `SIZE = 262144`, no truncation |
| `scripts/portmap.py` | `load_stock` pads a stock image with `$FF` to `KERNEL_BANKS` (16), so the new banks are free space and map one to one between builds |
| `scripts/kernel-patch.py` | the modded kernel may be longer than stock: it diffs against stock padded with zeros (as an IPS grows the file), writes runs of 16 or more equal bytes as RLE records, and records `patched_size` in the manifest. The patches grew about 1 KB |
| patcher page | only its comment: `applyIps` already grew the file and handled RLE, and it checks the result's SHA-256 |

`inject.py` and `inject_bytes.py` take any bank; a block in bank 10+ is
injected like any other, and `port-mod.py` carries it to the other builds.
Reach new code with a far stub (`cd 8d 07 <addr> <bank> 00`) from wherever
it is called: behind a `call`ed stub the callee's arguments start at sp+8,
behind an inline one at sp+6.
