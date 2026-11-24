# Kernel 1.06, modified

[kernel/stock-1.06](../stock-1.06/README.md) with this project's changes.
The pristine source stays there; this folder is a full copy, so it builds
without it. Apache License 2.0, as the source it comes from
([LICENSE-APACHE-2.0](../../LICENSE-APACHE-2.0)).

This is not the mod kernel. The mod with its features is
[kernel/mod](../mod/README.md), on the 1.05e-0918 base.

```sh
make mod-1.06          # from the repository root: release/en and release/zh
make -C kernel/mod-1.06            # English only
```

Needs GBDK-2020 4.5.0 in `tools/gbdk-2020-4.5.0`, or `GBDK=<its gbdk folder>`
([INSTALL.md](../../INSTALL.md)).

## Changes

`diff -r --strip-trailing-cr kernel/stock-1.06 kernel/mod-1.06` shows all of
them.

| Change | Files |
|---|---|
| The makefile runs `lcc` and `python3`, and finds GBDK in `tools/` | `makefile` |
| FW6 clock load | `source/GBcard_OP.c`, `source/Bank_fun.c` |

### FW6 clock load

FW6 keeps the MBC3 game clock in a counter in the FPGA
([stage0/docs/fw6.md](../../stage0/docs/fw6.md)). The kernel gives a game its
time by writing five bytes to `$A018-$A01C` on page 6 in kernel mode, as
1.05e does. FW6 stores those bytes but does not load the counter from them:
only a game's MBC3 write does. With the source as received, a clock game on
FW6 starts at 0 days 00:00:00 after every power cycle.

`Send_different_time` and `Send_different_time_0` now also keep the five
bytes in `game_rtc`, and set `game_rtc_load` when the game has a clock and
the FPGA reports version 6 or later. The launch stub
(`ramfun_DMA_Response`, run from WRAM) then writes them the way a game
would, after it has left kernel mode and before the reset: `$0000 = $0A`,
then `$4000 = $08` to `$0C` each followed by the value to `$A000`. On FW4
and FW5 the stub does what it did.

Checked by simulation of FW6's two clock modules: the kernel mode writes
leave the counter at 0, the stub's writes load it. Not yet run on a cart.

**Correction (2026-11-24).** The above describes the FW6 test build of
2026-11-17. The released FW6 (`Update_FW6_20261124.gb`) is a new build in
which the kernel mode write to `$A018-$A01C` does load the counter, so the
released firmware does not need this change. Read from its bitstream, not
yet seen on a cart. The change is harmless there: it loads the same values
a second time.

This is here until EZ Flash's kernel does it. When their source with FW6
support arrives it goes into `kernel/stock-1.06`, and this change comes out
of here.
