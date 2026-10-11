# Tab switch timing

How long the SD, SET and HELP tabs take to come up, and where the time goes.
Measured 2026-10-11 in SameBoy (DMG model, 1.05e-0918 kernel, mod 6.1).

## Method

Every idle screen polls the joypad through `ReadJoypad` (`00:3a4a`): the SD
browser every 3 frames, HELP every frame, SET many times a frame. After
SELECT the next poll comes only once the new tab is drawn, so the gap between
the two polls is the switch time.

The SameBoy stub has a sampling profiler for these gaps
(`patches/sameboy/`, `Core/ezflash_jr.c` `profile_step`): with
`SAMEBOY_PROFILE_GAP=<file>` set it samples bank:PC and the call stack every
256 T-cycles, and at each poll writes out the samples of a gap over 1M
T-cycles. `scripts/debug/gap-profile.py <kernel.sym> <file>` prints each
gap's self and inclusive time per function.

```sh
SAMEBOY_PROFILE_GAP=/tmp/prof.txt SAMEBOY_EZFLASH_JR_IMG=card.img \
    tools/SameBoy/build/bin/SDL/sameboy --model dmg ezgb.dat
# press SELECT a few times, quit
scripts/debug/gap-profile.py re/kernel/1.05e-0918/kernel.sym /tmp/prof.txt
```

SameBoy's SD reads don't take the time a real card does, so the HELP -> SD
switch (a directory reread) is only indicative. SET and HELP do almost no
card access apart from SET's config read.

## Results

| Switch | 8px | 12px |
|---|---|---|
| SD -> SET | 61.8 frames, 1035 ms | 77.4 frames, 1296 ms |
| SET -> HELP | 30.0 frames, 503 ms | 39.0 frames, 652 ms |
| HELP -> SD | 70.6 frames, 1181 ms | 77.4 frames, 1295 ms |

Where it goes (inclusive, so rows overlap):

| Cost | SD -> SET | SET -> HELP | What |
|---|---|---|---|
| tab strip redraw (`TabStrip12`; in 8px the tab code at `08:7169`) | 385-460 ms | 385-460 ms | on every switch, almost all of it `DrawRect` |
| `DrawRect` | 460-500 ms | 370-400 ms | `DrawRectImpl` -> `DrawLine` -> `ApplyPixel`: rectangles filled one pixel at a time |
| `U32ToAscii` | 250 ms | 20 ms | SET's date and time digits through the 32-bit divide |
| `EzCfg` | 120 ms | | SET reads `EZGB.CFG` |
| 12px text (`DrawString12`, `Fit12`) | 230 ms | 160 ms | |
| 8px text (`DrawString`) | 100 ms | 80 ms | |

So the largest single cost is not text but `DrawRect`, the pixel-by-pixel
rectangle fill under the tab strip and the pane clear, paid on every tab
switch (and by every other screen that clears with it). The SET tab adds the
32-bit number formatting of the clock and the config read.
