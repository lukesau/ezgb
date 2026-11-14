# Kernel size: 16 banks

The stock kernels are 10 banks (160 KB). The modded kernel is 16 banks
(256 KB): the stock banks were nearly full, so the mod's larger features
live in banks 10 to 14, and bank 15 is empty.

## Why it works

Stage1 loads the whole of `ezgb.dat`, by its file size, into the cart's game
pSRAM with bank N at N × `$4000` ([fpga-stage1.md](fpga-stage1.md)). In
kernel mode the FPGA's ROM bank register at `$2000` is a plain 8-bit latch
([design.md](../stage0/docs/design.md)), so the kernel can map any of 256
banks of whatever the file holds, with the same `$2000` write
`FarCallTrampoline` already does.

Confirmed on an FW4 and an FW5 cart with the firmware mod. Stock stage1
builds the same load command but has not been tried with a 16-bank kernel.

256 KB is the next power of two, so `rgbfix` pads the reassembled ROM to
exactly that.

## Using the new banks

`inject.py` and `inject_bytes.py` take any bank, and `port-mod.py` carries a
block in bank 10 or above to the other builds like any other. In the stock
image those banks do not exist, so `portmap.py` treats them as `$FF` free
space that maps one to one between builds.

Reach new code with a far stub from wherever it is called:

```
cd 8d 07 <addr lo> <addr hi> <bank> 00      ; call FarCallTrampoline, then the target
```

Behind a stub that is itself `call`ed, the callee's arguments start at
`sp+8`; behind an inline one, at `sp+6`. Injected C takes pad parameters to
line its arguments up.

An IPS patch may grow the file, and `kernel-patch.py` diffs against stock
padded with zeros and records `patched_size` in the manifest.
