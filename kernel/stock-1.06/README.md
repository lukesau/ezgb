# Kernel 1.06 source, as received

EZ Flash's source for kernel 1.06e (English) and 1.06c (Chinese file names),
from the EZ Flash team on 2026-11-18. Unlike the three kernels in
[kernel/stock](../stock/README.md), this is their source and not a rebuild
from the binary. It is the 1.05e kernel moved to GBDK-2020 and SDCC 4.5.1,
with their names for everything.

Nothing in this folder is changed. Everything but this README is the
archive as it came (`source/`, `tools/`, `makefile`, `build.bat`), line
endings included, without its `release/` folder of built kernels. When a
newer archive arrives, copy it over this folder. The changes this project
makes are in [kernel/mod-1.06](../mod-1.06/README.md).

## The released 1.06e

EZ Flash released kernel 1.06e with FW6 on 2026-11-24 (`ezgb.dat`, sha1
`e4b935f24888c5785490d9147e6701a74227deec`), withdrew that release two days
later and put out another on 2026-11-27 (sha1
`6f791ae4d34fc29a773e9b2cd308761b9a0d04ce`). This source is older than both
and builds neither. EZ Flash has said the kernel's source will be
published; when it is, it goes here.

Compared function by function against the kernel built in the 11-18
archive (`release/en/ezgb.dat`, md5 `fd22f02f`), with addresses and stack
offsets masked. Banks 2, 3, 5, 6, 7 and 9 are identical. What changed:

| File | Function | Change |
|---|---|---|
| `main.c` | `Draw_Text` | interrupts are off around each `wrtchr` call (`di` before, `ei` after), so the library's STAT wait and its writes cannot be split by an interrupt |
| `fill_fast.c` | `fill_fast_rect` | each tile write is: wait for STAT, `di`, test STAT again, write both planes, `ei`; a failed second test does `ei` and waits again |
| `fill_fast.c` | new, `01:6925` | `plot_point` with the same wait, `di`, second test and `ei` around the call; the fill's edge pixels go through it |
| `fill_fast.c` | new, `01:6B45`, `01:6BE4`, `01:6C17` | a filled box with a one pixel border made of five `fill_fast_rect` calls; that box drawn with the LCD off; and a whole screen clear with the LCD off (`display_off`, fill, LCDC bit 7 set again) |
| `UI.c` | `DrawGB` | the two `line` calls are `fill_fast_rect` of one row each, and the clears go through the LCD-off clear |
| `UI.c` | `Show_reading`, `Show_loading`, `Show_Error_file` | the dialog box is the LCD-off box, not the library's `box` |
| `UI.c` | `Show_gamelist_BG` | the two `line` calls are `fill_fast_rect` |
| `main.c` | `Show_SD_list` | up and down repeat while held: the first press acts, then after 19 polls every fourth; one `DrawGB` call is gone |
| `Bank_fun.c` | `Send_different_time` | the saved clock is kept when its seconds, minutes and hours are in range (this source zeroes it), day bit 8 is taken from the saved DH, a negative elapsed time counts as 0 where this source zeroed the clock, and the elapsed time is added with the carries as before |
| `Bank_fun.c` | `recent_set_paths` | the recent play list is `/SAVER/RecentlyPlay_gb.txt`, was `/SAVER/Recently play.txt` |
| `Bank_fun.c` | `LoadSAVE2SRAM` | 25 bytes longer, with one more local; not read through |
| `RTC.c` | `Set_window` | 41 bytes longer, three library `box` calls fewer; not read through |

`Show_recent_list`, `save_name_is_sane` and `Save_new_SAVE` differ only in
the addresses of moved strings.

The kernel of 2026-11-27 has all of that and two changes more, both to the
recent play list (compared with the 11-24 kernel the same way; banks 2,
3, 5, 6, 7 and 9 are identical, banks 0 and 4 differ in addresses only):

| File | Function | Change |
|---|---|---|
| `Bank_fun.c` | `recent_append` | when the list file does not open, it makes `/SAVER` and tries once more; the 11-24 kernel returned |
| `UI.c` | new, `08:439B` | a `Recent...` box, drawn like `Show_reading`'s; `Recently_Commit` shows it before it writes a pending entry at boot, and the list's compaction before it reloads the file |

The library's drawing code (`drawing.s`: `.plot`, `wrtchr`) is byte for
byte what it was, with no `di`. Thirteen calls to the library's `box`
remain (bank 0: 2, bank 1: 4, bank 4: 6, bank 8: 1) and run with
interrupts on, so the write race of
[docs/drawing-timing.md](../../docs/drawing-timing.md) is closed for text
and for fills and still open for those boxes. All of `line`'s callers are
gone.

The launch stub (`ramfun_DMA_Response`) is unchanged: the released kernel
sets a game's clock by the write to `$A018-$A01C`, which the released FW6
takes ([stage0/docs/fw6.md](../../stage0/docs/fw6.md)).

## License

Apache License 2.0 ([LICENSE-APACHE-2.0](../../LICENSE-APACHE-2.0)), by the
author's statement of 2026-11-18: the same license as the EZ Flash Omega
kernel. The archive has no license file. FatFs (`ff*.c`, `ff.h`, `ffconf.h`,
`diskio.h`, `integer.h`, `ccsbcs.c`, `cc936_zh.c`) is ChaN's, under the
license in its headers.

## Building

```sh
make stock-1.06        # from the repository root
```

That builds `release/en/ezgb.dat` (10 banks) and `release/zh/ezgb.dat`
(30 banks) with GBDK-2020 4.5.0 in `tools/gbdk-2020-4.5.0`
([INSTALL.md](../../INSTALL.md)). The makefile is written for Windows, so
the target passes `LCC` without `.exe`.

The result is not byte-identical to the kernels in the archive. The English
kernel there has md5 `fd22f02f273cf7c33c5a3f3eb323bb13`; GBDK-2020 4.5.0
gives `917b7e3fc1fb632100c16eb65ac48e77`, about 19,000 bytes apart, in the
runtime and library code. 4.4.0 does not match either. Both report SDCC
4.5.1 #15267, so the difference is the GBDK library build EZ Flash used,
which is not known.
