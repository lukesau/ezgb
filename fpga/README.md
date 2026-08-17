# Local FPGA config-flash images (not tracked)

Dumps of the cart's `EN25F40` SPI config flash, and any repair images built
from them. **Nothing here is committed** — the contents are EZ Flash's FPGA
bitstream, the same category as `ezgb.dat` and the firmware packages, which
this project does not redistribute (see the README's licence note).

Suggested layout:

```
fpga/
├── README.md                    # this file (tracked)
├── <cart>-original.bin          # 512 KB raw dump, as read
├── <cart>-original.status.bin   # optional: the trailing STATUS/CFG bytes
└── <cart>-repaired.bin          # any reconstructed image
```

Keep the **as-read dump of every cart, forever**. It is the restore source, and
for a damaged cart it is the only record of what the damage was. Store a copy
off the working machine — on 2026-08-16 the only copy briefly lived on a
removable volume.

Note the programmer appends 272 bytes of status/config data when STATUS/CFG is
ticked, so a dump may be 524,560 bytes rather than 524,288. Only the first
524,288 are flash contents; strip the tail before diffing or repairing.

Procedure — reading, repairing and writing — is in
[`../docs/hardware-board.md`](../docs/hardware-board.md).
