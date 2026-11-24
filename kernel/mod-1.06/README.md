# Kernel 1.06, modified

[kernel/stock-1.06](../stock-1.06/README.md) with this project's changes:
fixes, and the 0918 mod's features as they are brought over.
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
them. The version is in `VERSION` and shows on the HELP tab as `MOD 0.1`,
under the kernel's version.

| Change | Files |
|---|---|
| The makefile runs `lcc` and `python3`, and finds GBDK in `tools/` | `makefile` |
| VRAM write race fixed | `source/drawing.s`, `source/vram_put.s`, `source/fill_fast.c`, `makefile` |
| A game's saved clock is kept | `source/Bank_fun.c` |
| Up and down repeat after a delay | `source/main.c` |
| The recent play list is `/SAVER/RecentlyPlay_gb.txt` | `source/Bank_fun.c` |
| The file list is sorted by name and hides what is not a game | `source/browser.c`, `source/main.c`, `source/main.h`, `makefile` |
| `/EZGB.CFG`: the clock and AUTO SAVE backed up on the card | `source/ezcfg.c`, `source/ezcfg.h`, `source/main.c`, `source/RTC.c`, `makefile` |
| A launch jumps past the boot ROM when the console allows it; the kernel sets the palettes in CGB mode | `source/launch.s`, `source/ezcfg.c`, `source/GBcard_OP.c`, `source/main.c`, `makefile` |
| Fast launch: `FLAUNCH=` starts a game at power-on | `source/ezcfg.c`, `source/main.c` |
| SGB BOOT: the header packets a Super Game Boy needs | `source/sgb.s`, `source/ezcfg.c`, `makefile` |
| A second SET page for the mod's settings | `source/ezcfg.c`, `source/RTC.c` |
| `MOD` version line on the HELP tab | `VERSION`, `makefile`, `source/ui_text.h`, `source/Help.c` |

The last four catch up with the 1.06e EZ Flash released on 2026-11-24, whose
source is not out yet
([what the release changed](../stock-1.06/README.md#the-released-106e)).
They are written from what the released kernel does, not from its code.

### VRAM write race

The drawing library waits for STAT to leave modes 2 and 3 and then reads or
writes VRAM with interrupts on. An interrupt taken between the wait and the
access lets the access land in mode 3, where a write is dropped and a read
gives `$FF`: a streak in a tile that stays until the tile is drawn again
([docs/drawing-timing.md](../../docs/drawing-timing.md)).

`source/drawing.s` is GBDK-2020 4.5.0's `drawing.s` with interrupts off from
before each wait to the last access after it: the four pixel modes, the
pixel read and the character writer. The makefile links it ahead of the
library, so the library's copy is not used. `fill_fast_rect` had the same
race in C; its tile write is now `vram_put2` (`source/vram_put.s`), which
does the wait and both writes with interrupts off, seven cycles from the
sample to the last write.

The released 1.06e closes the race another way: interrupts off around each
character in `Draw_Text` and around the fill's writes, and dialogs drawn
with the LCD off. Its library is unchanged, so its remaining `box` calls
still have it. Here the library is fixed, so every caller is covered and
interrupts are off for about ten cycles a write.

Checked in SameBoy as a DMG with
`watch $8000 to $9800 if ([$ff41] & 3) == 3` over the same steps (boot, the
list, SET, HELP): the source as received hits it 4 times, all in
`fill_fast_rect`, and this build never. Not yet run on a cart.

### Saved clock

`Send_different_time` gives a clock game its time at launch. The source as
received zeroes the saved clock and counts only the time since the save, so
a game's clock restarts from the time the cart was off. Now, as in the
released kernel, the saved seconds, minutes, hours and days are kept when
they are a valid time, and the time the cart was off is added. A cart clock
that moved back counts as no time passed. Two things go past the release: a
halted clock (DH bit 6) stays where it was, and DH bit 0 is always day
bit 8. Read through, not yet run with a clock game.

### Key repeat

In the file list the first frame of an up or down press moves the cursor,
then nothing until it has been held 19 frames, then every fourth frame, as
the released kernel does. Left and right keep the every other frame rate.

### Sorted list, hidden clutter

The first of the 0918 mod's features here
([docs/browser.md](../../docs/browser.md) describes the original).
`Read_all_DIR` moved from `main.c` to `source/browser.c` in bank 8, because
bank 0 has under 100 bytes left.

Folders come first, then files, each by name without regard to case. No
record is moved: the folder is read once to make a 16-byte key per entry in
save RAM bank 31, the keys are heapsorted, and a second read writes each
record straight to its row. Two names with the same first 13 characters
stay in card order.

Not listed, file or folder: a name that starts with `.` or `_`; one that
ends in `.gba`, `.nds`, `.sav`, `.esv` or `.dat`; `EZGB.CFG`, `FLAUNCH.CFG`
and the `SAVER` folder; and, as before, anything hidden or system.

The keys take the last bank of the list area, so a folder holds 416 entries
where the kernel as received held 448. A folder with more is cut at 416 and
left in card order.

Seen in SameBoy on the test card: the root lists as Pokemon, Zelda,
Kirby.gbc, readme.txt, Tetris.gb, Wario Land.gb. Not yet run on a cart, and
not with a folder near the cap. Not carried over yet: the card's own hide
list (`/.ezgbhide`), stars and the sort by play count, icons, and the
notice when a folder is cut.

### The settings file

`/EZGB.CFG` as the 0918 mod keeps it
([docs/ezgb-cfg.md](../../docs/ezgb-cfg.md)): `key=value` lines in one
512-byte sector padded with spaces. `source/ezcfg.c` (bank 2) knows three
keys, and keeps the lines of any other key as they are, so a card can go
between this kernel and the 0918 mod.

| Key | What |
|---|---|
| `RTC=2026-11-24 12:59:39` | the last good reading of the clock chip. Stored at every launch when the reading is valid, the chip's voltage-low flag is clear and it is later than the stored one, and at every TIME SET |
| `AUTOSAVE=0` or `1` | a copy of the SET tab's AUTO SAVE box, stored when the box changes and at every launch |
| `RTCSD=0` | turns the clock backup off. Only read: the SET tab has no row for it yet |

**At boot**, once the card is mounted and before a pending save is backed
up, the file is read. If the clock reads as the year 2000, is not a valid
time, has its voltage-low flag set, or is earlier than `RTC=`, a prompt
shows both times: A writes the stored time to the clock, B keeps the
clock's. A suspect reading is read again after a second until two readings
agree, as in the 0918 mod.

**On a `BATTERY DRY` boot** the pending save marker is cleared first, since
the save waiting in save RAM faded with everything else and must not reach
the card, and then AUTO SAVE is put back from the file.

Checked in SameBoy: a toggle of AUTO SAVE and a launch each rewrite the
file with the other kernel's `FLAUNCH=` line kept; a stored time ahead of
the clock gives the `RTC BEHIND?` prompt; a dry boot
(`SAMEBOY_EZFLASH_JR_DRY=1`) puts AUTO SAVE back; a game launches after the
write. Not checked: writing the clock from the prompt (the emulator's clock
is the computer's), TIME SET's write to the file, and anything on a cart.
The source as received has a comment that rewriting a file just before a
launch corrupted a directory entry on hardware. This write is at that
point, on a file whose size does not change, and showed no problem in the
emulator: it needs a cart to settle.

Not carried over yet: the clock stored after a save backup, the fallback
to an old `FLAUNCH.CFG`, and the keys of features this kernel does not have
(`FLAUNCH`, `LASTROM`, `UI`, `THEME`, `COLORS`, `TAGS`, `BOOTROM`,
`DAILYBACKUP`).

### The jump past the boot ROM

As in the 0918 mod ([docs/skip-boot-rom.md](../../docs/skip-boot-rom.md)).
The kernel as received ends every launch with a console reset, so the boot
ROM runs a second time. `source/launch.s` is the launch stub
(`ramfun_DMA_Response`) in assembly with the jump added: when the console
is already in the mode the game needs, it puts the hardware back as the
boot ROM leaves it and jumps to the game's `$0100` with the boot ROM's
registers.

| Console | Launch |
|---|---|
| The DMG family (DMG, Pocket) | jump, any game |
| A color console with the kernel in CGB mode (our stage1) | jump for a game with the CGB flag, reset for the rest |
| A color console in DMG compatibility mode (stock stage1) | reset |
| An SGB under our stage1 (it records `C = $14`) | reset |

`BOOTROM=1` in `/EZGB.CFG` makes every launch reset. The console is told
at boot (`console_detect` in `source/ezcfg.c`): from the registers our
stage1 leaves in save RAM when it left any, else from `VBK` and from
whether palette RAM takes a write.

**The kernel in CGB mode.** Under our stage1 a color console runs the
kernel in CGB mode, where `BGP` is ignored and nothing in the kernel as
received sets the color palettes. `console_init`, first thing in `main()`,
gives every palette the four grays and clears the tile attributes.

Checked in SameBoy: on the DMG model Pokemon Red starts with no reset; on
the CGB model (compatibility mode) it resets; with the kernel's header
given the CGB flag the kernel shows in grays, a DMG game resets and a ROM
with the CGB flag starts with no reset. Not run on a cart, and not with
our stage1's register record.

With stock stage1 an SGB cannot be told from a DMG, so SGB BOOT on stands
in for it: with it on, the DMG family resets. With it off a game on an SGB
is jumped to and does not get its SGB features, as in the 0918 mod.

### Fast launch

`FLAUNCH=/Pokemon/Pokemon Red.gb` in `/EZGB.CFG` starts that game at
power-on, before the first listing
([docs/fast-launch.md](../../docs/fast-launch.md)). A value that starts
with `#` is off. Holding START at power-on gives the browser, and so does a
path that does not open or is not a `.gb` or `.gbc`. Under our stage1,
stage1 does the launch itself, and its mark that the launch was canceled
is honored. The launch goes through the same code as one from the recent
list.

Checked in SameBoy: power-on goes straight into Pokemon Red, and with START
held the browser comes up, after a `FAST LAUNCH CANCELED` line that stays
until START is let go (START is also this kernel's key for the recent
list). Not carried over: the launch of a card's lone ROM.

### SGB BOOT

On a Super Game Boy the stock Jr shows a black screen: the SNES misses
the six packets the boot ROM sends with the cartridge header
([docs/sgb-boot.md](../../docs/sgb-boot.md)). With SGB BOOT on the kernel
sends them again, the set of six four times with gaps of 192, 64 and 48
frames. `source/sgb.s` has the 0918 mod's packet code.

- **The first set** goes out first thing in `main()`, blocking, 0.4 s.
  The 0918 mod sends it at `$0100`, before the runtime starts; here it is
  after GBDK's startup, a few milliseconds later.
- **Sets 2 to 4** go one packet per due frame from a VBlank handler.
- **The pad** is not driven for the 4 frames after a packet: `joypad` is
  this file's, not the library's, and returns the last state then.
- **A launch** before all the packets are out sends the rest first, and
  with SGB BOOT on the DMG family resets into the game, since the SNES
  takes the game's SGB features from the header it sees at a reset.
- **The header** has the SGB flag (`$0146 = $03`, `-Wm-ys`), without which
  the SGB BIOS ignores the packets.

The setting is the 0918 mod's record in save RAM (bank 17, `$A400`: `S`
`G` `$01` `$FE`), since the packets go out before the card is up. With no
SET tab row yet, `SGB=1` or `SGB=0` in `/EZGB.CFG` sets or clears the
record at boot, for the boots after it. Our stage1 sends the packets
itself, and then the kernel sends nothing.

Checked in SameBoy: `SGB=1` sets the record; with it on the kernel boots
and takes input on the SGB and DMG models, the VRAM watchpoint stays quiet
while the packets go out from VBlank, and a launch resets (Pokemon Red
comes up with its border on the SGB model). SameBoy shows a picture on its
SGB model with or without the packets, so whether a real SNES takes them
is not checked: that needs a Super Game Boy.

### The second SET page

DOWN from AUTO SAVE opens it, UP from its first row goes back, and SELECT
leaves the tab as on the first page. A toggles the row under the cursor
and writes `/EZGB.CFG`.

| Row | Does |
|---|---|
| `SKIP BOOT ROM:` | ticked is the jump; unticked writes `BOOTROM=1` |
| `FAST LAUNCH:` | on and off, by the `#` in front of the `FLAUNCH=` path. With no game set, turning it on takes the last game launched |
| `SGB BOOT:` | sets or clears the record in save RAM, for the boots after this one. `SGB=` in the file is updated only when the file already has it |
| `RTC SD BACKUP:` | unticked writes `RTCSD=0` |
| `FAST LAUNCH GAME` | shows the game by name; A makes it the last game launched |

So this kernel now writes `BOOTROM`, `FLAUNCH`, `RTCSD` and `SGB` as well
as reading them.

Checked in SameBoy: each row toggles and reaches the file or the record;
turning FAST LAUNCH on with no game set took Pokemon Red, and the next
power-on went straight into it; START held then shows
`FAST LAUNCH CANCELED` and gives the browser once it is let go.

Not carried over from the 0918 mod's SET tab: the grayed rows for a console
that cannot jump, `SGB: AUTO` under our stage1, and its other pages.

**A bug found on the way.** The mod's variables were read before anything
set them, and this runtime does not clear WRAM at startup in a way they
could count on: a boot could take itself for `BATTERY DRY` and drop a
pending save backup, or freeze the pad. `console_init` now sets them all,
first thing in `main()`. After the fix a save backup at boot writes the
same 32 KB file as the source as received does (checked in SameBoy on a
fresh card image).

### The FW6 clock load, removed

Until 2026-11-24 this tree had one change: the launch stub wrote a game's
clock the way a game does, because the FW6 test build of 2026-11-17 did not
load its clock from the kernel's write to `$A018-$A01C`. The released FW6
does ([stage0/docs/fw6.md](../../stage0/docs/fw6.md)), so the change is gone.
