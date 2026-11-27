# Kernel 1.06, modified

[kernel/stock-1.06](../stock-1.06/README.md) with this project's changes:
fixes, and the 0918 mod's features as they are brought over.
The pristine source stays there; this folder is a full copy, so it builds
without it.

## License

EZ Flash's source is under the Apache License 2.0
([LICENSE-APACHE-2.0](../../LICENSE-APACHE-2.0)). This project's work in
this folder, the files it added and its changes to EZ Flash's files, is
dual licensed: the Apache License 2.0 or the repository's AGPLv3
([LICENSE](../../LICENSE)), at your choice. So the folder as a whole can be
taken under Apache 2.0, and EZ Flash can use any of it.

Three things here are someone else's and keep their license:

| What | License |
|---|---|
| `source/drawing.s`: GBDK-2020's drawing library, with this project's fix | GPLv2 with a linking exception, as GBDK's library is; the fix is offered under that too |
| FatFs (`ff*.c`, `ff.h`, `ffconf.h`, `diskio.h`, `integer.h`, `ccsbcs.c`, `cc936_zh.c`), `ff_5.c` among them | ChaN's, in the files' headers |
| The 12px glyph tables | not in this folder: the build packs them from `kernel/mod/font12/font12.txt`, which is drawn from the Tamzen font (`kernel/mod/font12/LICENSE-Tamzen`) |

This is not the mod kernel. The mod with its features is
[kernel/mod](../mod/README.md), on the 1.05e-0918 base.

```sh
make mod-1.06          # from the repository root: release/en and release/zh
make -C kernel/mod-1.06            # English only
```

Needs GBDK-2020 4.5.0 in `tools/gbdk-2020-4.5.0`, or `GBDK=<its gbdk folder>`
([INSTALL.md](../../INSTALL.md)).

## Size

The mod is not held to the stock kernel's bank count. The English kernel is
16 banks (256 KB) where stock is 10, and the Chinese one 32 (512 KB) where
stock is 30: `ROMBANKS` in the makefile. Stage1 loads the whole of
`ezgb.dat` by its size, and in kernel mode the bank register is a plain
8-bit latch, so up to 256 banks work
([docs/kernel-size.md](../../docs/kernel-size.md)); the count is kept to
what the code needs, since every boot loads all of it, and is a power of
two, as the ROM tool wants. Banks 10 to 15 (30 and 31 in the Chinese
build) are empty for now: new features go there.

Bank 0 is the one that cannot grow: everything every bank calls is in it.
A feature's code goes in a banked file, with only its call in bank 0.

The source as received had bank 0 nearly full, so what did not have to be
there was moved out, to the first new bank (`source/modbank.h`: bank 10,
or 30 in the Chinese build). The English build now has 7.3 KB of bank 0
free where it had 750 bytes:

| What | Was | Now | Size |
|---|---|---|---|
| `Show_SD_list`, the SD tab's main loop | `main.c` | `source/sdlist.c` | 2.9 KB |
| FatFs's upper-case and code page tables, English build | bank 0 | their own bank (`ffunicode.c`); `ff_wtoupper` and `ff_convert` are banked calls | 2.3 KB |
| `get_fattime`, `_ultoa` | `diskio.c`, `main.c` | `source/modmisc.c` | 0.6 KB |
| The library's circle drawing | `drawing.s` | gone: nothing draws a circle | 0.3 KB |
| `Filename_loop`, the SET pages, `Read_all_DIR` (earlier) | `main.c`, `ezcfg.c` | `list8.c`, `setpage.c`, `browser.c` | |

A function that moves to a bank takes its string literals with it, and a
function in another bank cannot read them. `Show_SD_list` passed six to
banked functions (the mount point, `/SAVER`, and `/` four times): they are
arrays in RAM now. This is the thing to check when their release source
arrives and these moves are made again.

What stays in bank 0: the startup code and vectors, the bank call
trampoline, the long arithmetic and memory routines, the drawing library,
`Draw_Text`, `joypad`, the disk I/O and the `f_*_bank` wrappers.

Both sizes boot and start a game in SameBoy. The 0918 mod runs at 16 banks
on FW4 and FW5 carts with our stage1; stock stage1 with a kernel this
size has not been tried, here or there.

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
| The fast-load key on every console: `$7FD3 = 0`, `$7FD4 = $11` before a load, as the 0918 mod writes it, where the source as received writes `$7FD4 = 0` and is fast on a color console only ([firmware-diff.md](../../stage0/docs/firmware-diff.md)). Not timed on a cart | `source/Bank_fun.c`, `source/sdlist.c`, `source/ezgb_hw.h` |
| SGB BOOT: the header packets a Super Game Boy needs | `source/sgb.s`, `source/ezcfg.c`, `makefile` |
| Two more SET pages for the mod's settings | `source/setpage.c`, `source/ezcfg.c`, `source/RTC.c` |
| Themes: light, dark and four colors | `source/ezcfg.c` |
| The 12px proportional font (English build) | `source/font12.c`, `source/font12_data.s`, `source/list12.c`, `source/ezcfg.c`, hooks in `source/Bank_fun.c`, `source/main.c`, `source/UI.c`, `makefile` |
| Hold A on a game for its options | `source/rommenu.c`, `source/main.c`, `source/sgb.s` |
| Manage saves: back up, restore and delete a game's saves | `source/savemgr.c`, `source/ff_5.c`, `source/rommenu.c`, `makefile` |
| Stars and play counts | `source/plays.c`, `source/browser.c`, `source/list12.c`, `source/rommenu.c`, `source/setpage.c`, `source/ezcfg.c` |
| A text viewer for `.txt`, `.ini`, `.md` and `.cfg` | `source/textview.c`, `source/rommenu.c` |
| The daily save backup | `source/savemgr.c`, `source/sdlist.c`, `source/ezcfg.c` |
| Custom and DV themes, the SLIM font, and the rest of the settings file | `source/ezcfg.c`, `source/font12.c`, `source/font12_data.s`, `source/setpage.c` |
| `MOD` version line on the HELP tab | `VERSION`, `makefile`, `source/ui_text.h`, `source/Help.c` |

The last four catch up with the 1.06e EZ Flash released on 2026-11-24 (and
again on 2026-11-27, with two changes to the recent list that are here
too: `/SAVER` made when the list file does not open, and a `Recent...` box
while the list is written at boot), whose
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
bank 0 has no room: for the same reason `Filename_loop`, the 8px list's
name scroll, is in `source/list8.c` (bank 4).

Folders come first, then files, each by name without regard to case. No
record is moved: the folder is read once to make a 16-byte key per entry in
save RAM bank 31, the keys are heapsorted, and a second read writes each
record straight to its row. Names with the same first 13 characters are
then put in order by their whole names
([2026-11-26](#the-list-the-saves-and-names-that-scroll-2026-11-26)).

Not listed, file or folder: a name that starts with `.` or `_`; one that
ends in `.gba`, `.nds`, `.sav`, `.esv` or `.dat`; `EZGB.CFG`, `FLAUNCH.CFG`
and anything named `SAVER`; and, as before, anything hidden or system.

**The card's list.** `/.ezgbhide` in the card's root names more to leave
out, one name a line, any case: a plain name hides a file or folder with
exactly that name in any folder, `*` and an ending hides every name with
that ending, and `#` starts a comment. Its first 510 bytes are read, for
every listing.

**Clean names.** With `CLEAN NAMES` ticked on the SET tab, the default, a
file's name is drawn up to its first ` (` or ` [`, or else its last `.`:
`Tetris (World) (Rev 1).gb` and `Tetris.gb` both show as `Tetris`. Only
the drawing is shorter: sorting, launching and the save's name use the
whole name. `TAGS=1` in `/EZGB.CFG` shows full names. Both lists and their
name scroll use it (`name_shown` in `source/browser.c`).

The keys take the last bank of the list area, so a folder holds 416 entries
where the kernel as received held 448. A folder with more is cut at 416 and
left in card order.

A folder with more than 416 entries shows `Too many files. Showing first
416` for two seconds.

Seen in SameBoy on the test card: the root lists as Pokemon, Zelda, then
the files by name; a hide list with a name, an ending, a comment and a
blank line hides what it should; names show cut and, with the box
unticked, in full. Not checked: a folder near the cap and its notice.
Nothing on a cart. Not carried over yet: stars and the sort by play count.

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

The clock is also stored after a save backup at boot (not checked in the
emulator). Not carried over yet: the fallback to an old `FLAUNCH.CFG`, and
the keys of features this kernel does not have (`LASTROM`, `COLORS`,
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
list).

**A lone ROM.** With no `FLAUNCH=` at all, a card whose root lists exactly
one file, a `.gb` or `.gbc`, starts it at power-on, whatever folders it
has; what the list hides is not counted. START held gives the browser.
Seen in SameBoy both ways.

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

### The SET tab's other pages

`source/setpage.c` (bank 4). DOWN from AUTO SAVE opens the first of them.
Each has up to four rows: DOWN from a page's last row is the next page, UP from
its first the one before, and UP from the very first goes back to the
tab's first page. SELECT leaves the tab. A acts on the row under the
cursor and writes `/EZGB.CFG`.

| Row | Does |
|---|---|
| `SKIP BOOT ROM:` | ticked is the jump; unticked writes `BOOTROM=1` |
| `FAST LAUNCH:` | on and off, by the `#` in front of the `FLAUNCH=` path. With no game set, turning it on takes the newest game of the recent list |
| `GAME:` | the fast launch game by name; A makes it the next game of the recent list, and leaves fast launch on or off as it was |
| `SGB BOOT:` | sets or clears the record in save RAM, for the boots after this one. `SGB=` in the file is updated only when the file already has it |
| `THEME:` | the next theme |
| `FONT:` | `8PX`, `12PX`, `SLIM` or `EZ-FLASH` (`UI=EZF` in the file; the row read `EZF` until 2026-11-25) |
| `CLEAN NAMES:` | unticked writes `TAGS=1` |
| `RTC SD BACKUP:` | unticked writes `RTCSD=0` |
| `SORT BY PLAYS:` | most played files first; kept with the stars, not in `/EZGB.CFG` |
| `DAILY BACKUP:` | ticked writes `DAILYBACKUP=1` |

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

### Themes

`THEME=` in `/EZGB.CFG`, and a `THEME:` row on the second SET page that
steps through them ([docs/themes.md](../../docs/themes.md)): 0 light, 1
dark, 2 red, 3 green, 4 purple, 5 blue. A theme is what the four color
indices draw as: the background, a shade of it, the highlight and the ink.

In CGB mode (a color console under our stage1) the colors go to every BG
and OBJ palette. A DMG, and a color console in DMG compatibility mode,
have only `BGP`: light is the stock `$E4`, every other theme is the
inverted `$1B`, and the row offers light and dark.

> **Correction (2026-11-25).** Until this date the section said the color
> themes had deeper accents than the 0918 mod's, drawn under white text,
> and that a DMG's dark theme had a selected row of white on light gray.
> Neither was what the kernel did by then: the selected row had become the
> background color on the ink, so in every theme it was black and white and
> the accent showed only in the SET tab. The accents are now the 0918
> mod's, drawn as below. The same day's sections further down that call
> DV's highlight blue are wrong the same way: it is lime, and the blue is
> its icons'.

**The accent.** A highlight is drawn as `color(WHITE, BLACK)`, the
background color on the ink: the selected row, the active tab, the name
band of the menus and prompts, and the SET tab's cursor (as received those
last two were black on dark gray, which an original Game Boy cannot read).
`color()` is replaced (`source/vram_put.s`) and is where a theme changes
that, with two numbers `theme_apply` sets (`source/ezcfg.c`):

| | Light | Dark | Red, green, purple, blue, custom | DV |
|---|---|---|---|---|
| A paper of 3, and the ink of a solid fill of 3 | 3 | 3 | 2, the accent | 1, its lime |
| A paper of 2, the dialogs' dark gray | 2 | 1 | 1 | 0 |

So a color theme's highlight is its background color on sky `#42A5FF`,
rose `#FF94C5`, gold `#EFD63A` or apricot `#FFA56B`, and its dialogs are
the background's lighter shade. DV's highlight is lime and its dialogs are
black in a white frame. Check marks and the frame of a checkbox under the
cursor are in the accent. The 12px renderer takes the selected row's
colors from the same number, and the rule under its tab strip.

DV draws a row's icon in its blue, index 2, on a row that is not selected:
`font12_field` keeps the leading icon's pixels and the flush clears plane 0
under them (`source/font12.c`, as the 0918 mod's `draw12.c`).

Where only `BGP` can be set there is no accent: a highlight is the
background shade on the ink, and a dialog past light is index 1.

The library has `color()` in one module with its three variables, so that
module is in `vram_put.s` whole and the linker never takes the library's.

Checked in SameBoy: green and purple on the CGB model with the kernel's
header given the CGB flag, the row stepping through the themes and writing
the key, and dark on the DMG model.

### The 12px font

The 0918 mod's proportional, kerned 12px font
([docs/font12.md](../../docs/font12.md)). `UI=12` in `/EZGB.CFG`, or the `FONT:` row on the second
SET page, switches it at once; with no key the kernel is 8px as before.
English build only: the Chinese build has EZ Flash's 12px text.

- `source/font12.c` is the 0918 mod's renderer and layout (`draw12.c`,
  `layout12.c`) for this kernel, with one glyph set. The glyph tables are
  packed by the makefile from the same sheet, `kernel/mod/font12/font12.txt`.
- `source/list12.c` is the list: ten rows of 12 pixels from y 20, each an
  icon and the name. Folders show by their icon with no `DIR` tag, and a
  `.gb` or `.gbc` shows without its ending. The selected row is inverted,
  ink 0 on paper 3, which reads on an original Game Boy. A name that does
  not fit scrolls a character at a time.
- The tab strip is 12 pixels with the active tab inverted and a rule under
  it, and the position in the folder is at its right.
- The row count is a variable now (`LIST_ROWS` is `list_rows`: 16 or 10),
  so paging follows the font.

**EZF.** A third choice of the `FONT:` row, `UI=EZF` in the file: EZ
Flash's 6x12 font, the one the Chinese build draws ASCII in
(`source/asc12x6.c`), in this layout. `tools/ezf-pack.py` packs it as a
second glyph set for the same renderer: its letters as they are, each in a
fixed 6 pixel cell with no kerning, and the mod font's star and icons,
since it has none. A row holds about 24 characters of a name where the
mod's font holds about 18. Seen in SameBoy on the list and the SET tab.

**Everything else that draws text** goes through `Draw_Text`, which hands
the string to `text12` (`source/list12.c`) when the font is 12px. The
callers lay their text out in 8 pixel cells: the column and row are kept,
the field is as wide as its cells, and the text is 12 pixels tall from the
top of its row, in the colors `color()` last set. What is right of a field
stays. Where two lines were on adjacent rows the layout changes with the
font:

| Screen | In 12px |
|---|---|
| SET, first page | the date and time are one line (`clock12`), the field being set inverted; the `SET` button's box is three rows taller |
| SET, the mod's pages | their rows are two apart in both fonts |
| HELP | its lines are on rows 3, 5 and 7 |
| Dialogs | lines on rows 10 and 11 of column 5 draw 12 pixels apart, at y 72 and 84 |
| The clock prompt | its two times are on rows 7 and 9 |
| The recent list | nine rows of 12 pixels (`recent12_show`) |
| The boot messages and `BATTERY DRY` | 8px, since they come before the settings are read |

Checked in SameBoy: the list with its icons, the cursor, a long name
scrolling, the three tabs, both SET pages, setting the time, HELP, the
load and save dialogs, the recent list and back, the `FONT:` row switching
both ways, the same screens in 8px, and no hit on the VRAM watchpoint. Not
checked: a folder longer than a page in 12px, and the error dialogs.
Nothing on a cart.

Not carried over: the star, a 12px recent list, `UI=SLIM` (read as 12px)
and the DV glyph set.

### Hold A on a game

As in the 0918 mod ([docs/rom-menu.md](../../docs/rom-menu.md)). A tap of
A on a `.gb` or `.gbc` starts it when A comes up. A held for half a second
opens a menu for that game:

```
Options
<the whole name>          on an inverted band; scrolls when too long
> Start
  Fast launch: NO
[B]back          [A]ok
```

- **Start** starts the game, as a tap does.
- **Fast launch** makes this the fast launch game (`FLAUNCH=` and its
  whole path), and A on the game that already is clears it. It does not
  turn fast launch on or off, which is the SET tab's box: the item reads
  `YES` for the game when fast launch is on, `OFF` for the game when it is
  off, and `NO` for any other.
- **B** closes the menu and draws the list as it was, the cursor where it
  was.

The band shows the name in full, tags and ending included, which is where
to read it when CLEAN NAMES has cut it in the list.

Two things about A in the list change with it. A tap is delayed by its own
length, since until A comes up a tap and a hold look the same. And an A
that was already down at the list's poll before is no press: holding A
used to go on into whatever the opened folder's first entry was. Folders
still open on the press, and a file that is not a game takes the path it
did.

Checked in SameBoy, in both fonts: a hold opens the menu, a hold on a
folder opens it and leaves its first game alone, Fast launch writes the
path and shows `YES`, B puts the list back, and Start and a tap both start
the game.

`Manage saves` opens the save manager and `Star` stars the game, both
below. The menu has no title line: with four rows there is no room for
it. Not carried over: the text viewer for a file that is not a game.

### Stars and play counts

As in the 0918 mod ([docs/stars.md](../../docs/stars.md)), with its table
and its file, so a card's stars and counts are the same under both
kernels.

- **Star**, in a game's hold-A menu, moves it to the top of its folder's
  files, under the folders, with a star for its icon in the 12px fonts.
  **Unstar** puts it back. The folder is listed again after either, with
  the cursor on the game.
- **Every launch** adds one to the game's count.
- **`SORT BY PLAYS:`**, on the SET tab's third page, lists files most
  played first, the unplayed by name after them. Starred files stay on top.

The table is in save RAM (bank 17, `$B7F8`), keyed by a hash of the file
name alone, so a game keeps its count when it moves to another folder. It
is mirrored to `/.ezgbplays` in the card's root, 2048 bytes: at boot a file
with the header replaces the table, and a launch, a star or a change of the
setting writes it. A full table (254 games) replaces its least launched
unstarred entry.

`source/plays.c` is new C to the 0918 mod's formats, in a second new bank
(`source/modbank2.h`: 12, or 8 in the Chinese build). The sort
(`source/browser.c`) asks it for each file only when something is starred
or the setting is on.

Checked in SameBoy: starring a game from the menu moved it under the
folders with its star and wrote the file (one entry, one star); a launch
added a second entry with a count of 1; with `SORT BY PLAYS:` on, the
played game listed ahead of the others and the file had the setting's
record. Not checked: Unstar, a full table, and a file written by the 0918
mod. Nothing on a cart.

Differences from the 0918 mod: the whole file is written on a change, four
sectors, where it writes only the sectors that differ; and the 8px list has
no star, only the order.

### Manage saves

As in the 0918 mod ([docs/save-manager.md](../../docs/save-manager.md)),
from a game's hold-A menu:

```
Saves                     "Working...", then "Done" or "Error"
<the game's name>
> Back up save            "No save yet" when the game has none
  26-11-25 08:57          its backups, newest first
  26-11-25 08:55
[B]back          [A]ok
```

- **Back up save** copies `/SAVER/<base>.sav` to
  `/SAVER/<base> YYYY-MM-DD HH-MM.sav`, the time being the save's
  last-modified time, with ` (2)`, ` (3)` and so on when that name is taken.
- **A on a backup** offers Restore and Delete, and asks before either.
  Restore backs the current save up first, then copies the backup over
  `<base>.sav`; the next launch loads it. Delete removes that backup. The
  live save is never deleted.

The names are the 0918 mod's and are parsed as strictly, so a card's
backups show under both kernels and `Tetris DX.sav` is not taken for a
backup of `Tetris.gb`. The newest 24 are listed, four on screen at a time.

**Delete** needed a routine this FatFs is built without. `source/ff_5.c`
is the kernel's `ff_4.c`, the cut of FatFs with the write internals, with
R0.11a's `f_unlink` where `f_mkdir` was, for files only, in a bank of its
own. Before it syncs it sets the free cluster count to unknown, for the
reason the 0918 mod does (docs/save-manager.md, "FSInfo").

Checked in SameBoy on a card image, reading the files back out with
mtools: a backup has the save's bytes; a restore over a changed save puts
the backup's bytes in the live save and leaves the replaced save in a
backup of its own; a delete removes that one file and leaves the others'
bytes as they were. Both fonts. The emulator's card writes are slow: a
32 KB copy takes most of a minute there. Not checked: a full list of 24,
a name collision counter, and what a host makes of the card after a
delete (mtools reads it). Nothing on a cart.

Not carried over: the daily backup (`DAILYBACKUP=1`).

### Sprint of 2026-11-25

Brought over quickly, built, and looked at once each in SameBoy, for a
test on a cart: none of these has had the checking the sections above
describe.

**Text viewer** (`source/textview.c`,
[docs/text-viewer.md](../../docs/text-viewer.md)). A on a `.txt`, `.ini`,
`.md` or `.cfg` file opens it read-only, in the font the list is in. UP
and LEFT go a page back, DOWN, RIGHT and A a page on, B back to the list.
Lines wrap at the last space that fits. The first 65,024 bytes are shown.
Unlike the 0918 mod's it has no line scroll and no font of its own.

**Daily backup** (`save_daily` in `source/savemgr.c`,
[docs/save-manager.md](../../docs/save-manager.md)). `DAILY BACKUP:` on the
SET tab's third page, `DAILYBACKUP=1` in the file, off by default. At
boot, when a save is waiting to be written and the save on the card was
last written before today by the cart's clock, that file is copied to a
backup first and the game's other backups are deleted. Written here from
the description, not from the 0918 mod's code, which is davidesqalv's.

**Themes.** `THEME=6` is the custom theme, from a `COLORS=RRGGBB,RRGGBB`
line (background and text, and a third color for the highlight; without
one the highlight was halfway between them until later the same day: see
"Icons in the 8px list" below). `THEME=7` is DV: black, with a
blue highlight. The `THEME:` row offers custom only when the file has the
line or the picker, below, has set a color.

**SLIM**, a fourth choice of the `FONT:` row and `UI=SLIM`: the 0918
mod's slim set, a fixed 6 pixels, packed from
`kernel/mod/font12/font12_dv.txt`. The fonts and the 12px list moved to
bank 13 to make room for a third glyph set.

**The color picker**, a fourth SET page on a console whose palettes can
be set (`source/setpage.c`, docs/themes.md "The picker"): `BG:`, `TEXT:`
and `ACCENT:`, each red, green and blue from 0 to 31. A on a row starts
setting it: LEFT and RIGHT pick the channel, UP and DOWN change it, A or
B ends. Every step applies. The first change made in another theme starts
from that theme's colors and turns the custom theme on. It is saved as
`COLORS=RRGGBB,RRGGBB,RRGGBB`, which this kernel now writes.

**The recent list in the 12px fonts** (`recent12_show` in
`source/list12.c`): nine rows that follow the cursor, the selected one
inverted. A name too long for a row is cut, not scrolled.

**The 8px list's selected row** is white on black, where it was black on
dark gray, which an original Game Boy cannot tell apart. So the list has
the same bar in every font.

**Moving in the list** (`source/sdlist.c`; docs/browser.md "Moving
around" has the 0918 mod's, which is davidesqalv's code: this is written
here from what it does). The list wraps at both ends. RIGHT on the last
page goes to its bottom row. In the 12px fonts the entry number reads
`n/total` when that fits right of HELP. A held UP or DOWN speeds up:
after the delay it repeats 6, 6, 5, 5, 4, 4 and then every 3 frames, and
while the list scrolls it moves 1, 1, 2, 2, 3, 3 and then 4 rows a step.
Not carried over: its recoloring of rows in VRAM, which saves a redraw.

**The cursor follows a star**: after Star or Unstar the list comes back
with the cursor on the game, where it now sorts (`list_follow` in
`source/browser.c`).

**The theme from power-on.** Applying a theme leaves a mark in save RAM
(bank 17, `$A414`: `T`, `H`, the theme, its complement, the four colors),
and the next boot takes the theme from it before the card is read. It is
the 0918 mod's mark, which our stage1 reads for its boot screen.

**`SKIP BOOT ROM:` reads `N/A`** on a console that resets into every
game (a color console under stock stage1, an SGB under ours), and A does
nothing there; `BOOTROM=` keeps its value.

**`SD SPEED: HALF` on the HELP tab**, when the firmware mod's SD recovery
has dropped the card clock to half speed
([stage0/docs/sd-recovery.md](../../stage0/docs/sd-recovery.md)). On stock
firmware and at full speed the tab is as it was.

**The settings file.** (`LASTROM=` was written at each launch until later
the same day: see the second run.) With no `/EZGB.CFG`, a one-line `/FLAUNCH.CFG` gives
the fast launch game. `SGB BOOT:` shows `AUTO` when our stage1 handles the
Super Game Boy.

### After the first run on a cart (2026-11-25)

The kernel ran on an FW5 cart, and what its user asked for next:

**The SET tab is three pages**, as the 0918 mod's is, six rows to a page
and two text rows apart, with the page's number at the foot:

| Page | Rows |
|---|---|
| 1 | `TIME:` and `SET`, the date and time, `AUTO SAVE:` (EZ Flash's), then `RTC SD BACKUP:`, `FAST LAUNCH:`, `GAME:` |
| 2 | `CLEAN NAMES:`, `SORT BY PLAYS:`, `SGB BOOT:`, `SKIP BOOT ROM:`, `DAILY BACKUP:` |
| 3 | `THEME:`, `FONT:`, and the picker's `BG:`, `TEXT:`, `ACCENT:` |

The cursor still runs down through all of them: DOWN from a page's last
row is the next page. LEFT and RIGHT change the page from any row, to its
first row, and the pages go round; while the time is being set they step
through its fields, as before. START on the SET tab or the HELP tab goes back
to the SD tab, as in the 0918 mod, where SELECT steps on to the next tab. EZ Flash's three rows keep their own loop, and
`Set_window` hands the cursor to `set_page2` (`source/setpage.c`) when it
leaves AUTO SAVE downward and takes it back when it comes up. This
replaces the pages of four rows the sections above describe.

**The clock does not blink.** In the 12px fonts each of its six numbers has
a fixed place, and only a number that changed is drawn (`clock12` in
`source/list12.c`); it used to draw the whole line every second. The
places are set by hand for the proportional font, whose digits are 7
pixels in 9 and whose slash leans across 6, so the slashes and colons sit
a pixel from the digits. The clock also keeps time while the cursor is in
the mod's rows of page 1.

**The status boxes are the 0918 mod's**
([docs/prompts.md](../../docs/prompts.md)): `Reading...`, `Loading...`,
`Error file` and the save load's messages are a box 96 pixels wide and
only as tall as its line of text, in a frame of a 2 pixel line, a gap and
a 1 pixel line (`source/msgbox.c`), where the kernel as received draws a
91 by 72 block of dark gray. The save prompt at boot is its band across
the screen: `Back up save?`, the save's name, and `[B]skip` / `[A]save`.
The rule in `text12` that moved the old dialogs' lines apart is gone with
them. Not carried over: the `Played` line of that prompt.

Seen in SameBoy in the 12px font: the three pages and the walk through
them and back, the clock, the `Loading...` box, the save prompt and its
`Saving...`. Not seen: the 8px versions of the boxes, and the error
messages.

### Second run on a cart (2026-11-25)

**The last game became the fast launch game.** `file_read` took the value
of `LASTROM=` into the fast launch setting: one branch handled both keys.
A launch writes `LASTROM=`, so the next boot started that game, and the
next write of the file made it `FLAUNCH=`. Each key now has its variable.
A card that went through it has a `FLAUNCH=` line it was never given:
turn FAST LAUNCH off on the SET tab, or delete the line.

**The accent, and DV's blue icons**: [Themes](#themes) above.

**Choosing the game does not turn fast launch on.** `GAME:` took the last
game launched and wrote its path without the `#`, so on a card whose game
was that one already A did nothing but tick the box. A now steps through
the recent list (`/SAVER/RecentlyPlay_gb.txt`, newest first, `cfg_flaunch_next`
in `source/ezcfg.c`), and both it and the menu's Fast launch item keep the
`#` unless fast launch is on. Ticking FAST LAUNCH with no game set takes
the newest of that list. Seen in SameBoy: two presses on `GAME:`
giving the newest and the next game with the box unticked, and the menu
item reading `OFF` and writing `FLAUNCH=#/Kirby.gbc`.

Seen in SameBoy on the CGB model: red and DV in 12px (list, tab strip, the
hold-A menu, the SET pages), blue in 8px (the same), purple's SET cursor
on a checkbox, and a card with only `LASTROM=` booting to the list with
FAST LAUNCH off. Light on the DMG model. Not seen: dark, green, custom,
the save manager and the prompts in a color theme.

**No last game.** The 0918 mod kept the last game launched for its START
overlay as `LASTROM=`, and read its path from `$A300` of save RAM bank 17.
This kernel has EZ Flash's recent list in `/SAVER/RecentlyPlay_gb.txt`, so
the mod no longer writes or reads `LASTROM=` (a line already in the file
stays, untouched) and no longer reads `$A300`: FAST LAUNCH and `GAME:`
both take their game from the recent list. Seen in SameBoy: ticking FAST
LAUNCH with no game set took the newest of the list, and a `LASTROM=` line
in the file was left as it was.

EZ Flash's kernel still writes `$A300` at every launch (`Save_filename`,
`source/Bank_fun.c`), with a flag at `$A2FF`. Its only reader is
`Recently_Commit` at the next boot, which appends that path to the text
file when the append at launch did not go through. So save RAM holds a
copy of the last path for one boot, and the text file is the list.

### The prompts and the viewer's line scroll (2026-11-25)

Four leftovers of the 0918 mod ([docs/prompts.md](../../docs/prompts.md),
[docs/text-viewer.md](../../docs/text-viewer.md)), in the English build:

- **`Played Oct 23 14:05`** in the save prompt, under the save's name: the
  clock the settings file has, which every launch stores, so it is when the
  game whose save is waiting was started (`cfg_played`, `source/ezcfg.c`).
  Left out when the file has no `RTC=`.
- **The clock prompt** is the save prompt's band: its question in the name
  band, `NOW` and `SD` with their date and time, `[B]keep  [A]use SD`. It
  was a box with `[A]RESTORE` on the left.
- **BATTERY DRY** is the small framed box, `Battery dry!` over `[A] ok`
  (`battery_box`, `source/msgbox.c`), and is taken off the screen once A is
  pressed. It comes before the settings are read, so it is always 8px.
- **The text viewer** scrolls a line on UP and DOWN, again and again while
  held, and pages on LEFT, RIGHT and A. A row's start depends on the
  wrapping of every row before it, so the start of every eighth row is kept
  and a row is found from the mark before it. The first 2,040 rows of a
  file are shown, where it was 127 pages.

Seen in SameBoy in the 12px font: the save prompt with its `Played` line,
the clock prompt for a clock behind the file, the battery box, and a 60
line file scrolled a line down and up, paged, and scrolled with DOWN held.
Not seen: the clock prompt's other three questions, the 8px font, a file
past 2,040 rows.

### DV's locks and the boxed picker (2026-11-25)

After a look at the third SET page next to mod 7.2's
([docs/themes.md](../../docs/themes.md) "DV", "The picker"):

- **DV is black, white and the slim font.** With DV on the font is SLIM
  whatever `UI=` says (`font_set`, `source/ezcfg.c`), and `UI=` keeps its
  value for the other themes. `FONT:`, `BG:` and `TEXT:` show what DV has
  in its blue, and the cursor passes over them.
- **DV's accent** is its lime until an accent is chosen: a third color in
  `COLORS=`, or the picker. Then DV's highlight is the custom theme's
  accent. Setting `ACCENT:` in DV changes that color and leaves DV on. The
  boot mark carries it, so it is there from power-on.
- **Any other theme**: the first change in the picker turns the custom
  theme on, starting from the colors of the theme it was made in.
- **`COLORS=` keeps two colors** when no accent was chosen. It was always
  written with three, and the third, worked out from the other two, would
  have become DV's highlight at the next boot.
- **The picker** has a `COLORS:  R G B` heading and each value right
  justified in a box (`boxed`, `source/setpage.c`); `THEME:` and `FONT:`
  have their values boxed too. The box under the cursor is filled with the
  highlight, and a locked one is drawn in index 2.

The foot of each SET page is `<  3/3  >`: the arrows say that LEFT and
RIGHT change the page, and are not buttons.

Seen in SameBoy: DV in 12px with its three locked rows, the cursor going
from `THEME:` to `ACCENT:`, the accent changed with DV still on and
`COLORS=000000,FFFFFF,6BF731` written; red's `BG:` changed, giving
`THEME=6` and red's colors as the start; a card with `THEME=7` and no
`UI=` coming up in SLIM, and 8PX again after leaving DV. Not seen: DV with
an accent across a power cycle, the Chinese build's page.

### 12px text laid out by pixels (2026-11-25)

The mod's pages were laid out in 8 pixel cells and `Draw_Text` drew them
in a 12px font from each cell's x, cut to the cell count. So the page
number sat left of center and a name stopped after as many characters as
the 8px font fits, with room left. In a 12px font now (`source/list12.c`):

- **A row of two buttons** (`[B]back      [A]ok`, a string that begins
  with `[` and has a second `[` after two spaces): the first at the left
  of its field, the second against its right edge. `text12` does it, so
  every such row has it.
- **`<  1/3  >`** at the foot of the SET pages is centered by its width
  (`text12_center`).
- **Names** take what fits their field's pixels: `GAME:`, the name band of
  the hold-A menu (which scrolls when `font12_fit` cannot place all of the
  name), the save prompt's, and the save manager's lines. Those go to
  `text12` directly, since `Draw_Text` cuts a string to its cells first.

Seen in SameBoy in 12PX and SLIM: the SET page's foot and `GAME:` with a
long name, the menu and the save prompt. Not seen: EZF, the save manager,
a name long enough to scroll in the menu.

### Icons in the 8px list, and two theme details (2026-11-25)

- **Every row of the 8px list has an icon** in column 0 and its name in
  columns 1 to 19, folders and files alike ([docs/browser.md](../../docs/browser.md)
  "Icons and the selection bar"). The kernel as received gave a folder 17
  columns and a `DIR` tag, which is gone. The icons are the 0918 mod's six
  (folder, `.gb`, `.gbc`, other file, text file, star), which it keeps in
  the kernel's 1bpp glyph sheet; their bytes were read out of its build
  into `source/list8.c` (the first build of this had six drawn for it,
  replaced the same day). They are written to the tile with `vram_put2` in the
  row's colors, so an icon inverts with the selected row. The row is one
  string padded to 19, so the selection is a bar across the screen.
- **DV where only `BGP` can be set** is `$27`, as in the 0918 mod, where
  every theme past light was `$1B`.
- **A custom theme with no accent given** has the background's complement
  at full brightness, or the text color on a gray background, as the 0918
  mod. It was halfway between the two colors.

Seen in SameBoy: the 8px list on the DMG model with the bar on a folder, a
`.gbc` and a text file; DV on the DMG model; `COLORS=1E2A44,F2D7A0` with a
cream highlight. Not seen: a starred game in the 8px list, a name scrolling
beside its icon.

### The selected row's fast copy, and the viewer's font (2026-11-25)

- **A selected row in a color theme or DV is drawn as fast as any other.**
  The 12px renderer had its fast copy only for ink 3 on paper 0 and ink 0
  on paper 3; with the accent the selected row is ink 0 on paper 2, or 1 in
  DV, and went through the flush that reads and writes VRAM a byte at a
  time. `blit_colA` and `blit_colB` (`source/font12.c`) are the fast copy
  for those two: the same sync, one plane written 0 and the other the
  row's bits.
- **The text viewer is in the slim font** whenever the list is in a 12px
  one: 26 characters a row where the 12PX font has about 18.

Seen in SameBoy, with no VRAM write landing in mode 3: the cursor moved
through the 12px list in red and in DV, and a text file opened in 12PX.
Not timed against the old path, and not run on a cart, where the mode 3
watch does not exist.

### The checkbox under the cursor (2026-11-25)

A checkbox under the cursor has a second outline right outside its box, in
the text's color, and the box's frame is in the highlight color, as the
0918 mod's `SetBox` ([kernel/mod/src/setbox.c](../mod/src/setbox.c)).
`set_check_ring` in `source/setpage.c` draws it, and Set_window calls it
for AUTO SAVE. The first build of this had a pixel between the two and the
outline in the accent, from a guess; the source settled it. Seen in SameBoy
in red on the CGB model and in light on the DMG model.

### Scrolling the list (2026-11-25)

Three changes to how the list moves, after docs/browser.md "Moving
around". The 0918 mod's `browser_nav.c` is davidesqalv's and none of it is
here: this is written from what it does.

- **The row under the cursor is drawn first** whenever a page is drawn,
  then the rest (`list12_show`).
- **A scroll moves the rows that stay.** When the cursor leaves the top or
  bottom of a full page, the rows still on it are copied in VRAM
  (`vram_copy_line`, `source/vram_put.s`: a pixel row of 20 tiles a call,
  three tiles a batch at the start of mode 0), and only the row under the
  cursor, the row it was on and the rows uncovered are drawn
  (`list12_scroll`, `list8_scroll`). It drew the page from the top.
- **A held UP or DOWN is timed in frames**, from `sys_time`: 18 frames,
  then 6, 6, 5, 5, 4, 4 and 3 for good. It was counted in passes of the
  list's loop, each a frame or two and whatever it drew, so it ran at less
  than half that. A press's 18 frames start when its move is drawn.

Measured in SameBoy at real speed, DOWN held for six seconds in a folder
of 80: the 12px list in red went from entry 18 to entry 42, the 8px list
on the DMG model from 24 to 60. With the mode 3 watch on, a run down and
back up left the page right and had no hit. Not run on a cart.

### The pad, read once a frame (2026-11-25)

After [docs/input.md](../../docs/input.md). `joypad()` read the pad
whenever it was called, so a button held across a screen change acted
again on the next screen, and a tap made while the kernel was drawing or
reading the card was never seen.

- **`pad_vbl`** (`source/sgb.s`, a VBlank handler `console_init` installs)
  reads the pad every frame into `pad_now` and adds each button that went
  down to `pad_new`. `joypad()` returns `pad_now`, so P1 is only driven
  from VBlank; it reads the pad itself with the LCD off and before the
  handler is there. `pad_take()` returns `pad_new` and clears it.
- **The list** takes its directions as held and A, B, SELECT and START
  from `pad_take()`: one action a press. An A held after opening a folder
  does not open the next, a held B climbs one level, and a tap made during
  `Reading...` is acted on when the list is up.
- **The SET and HELP tabs** use `pad_menu()` (`source/modmisc.c`): a
  direction acts at once, again after 24 frames and then every 6, and a
  button once a press. A held SELECT stops at the next tab. EZ Flash's
  rows took every key every fourth frame, a held A included; the mod's
  rows had no repeat.
- **The save prompt** takes a press made while it is up, not an A or B
  held since before it.

Seen in SameBoy: SELECT held for three seconds from the list stopping on
SET, and from HELP stopping on SD; A held on a folder opening that one
only; DOWN held on SET walking the rows onto page 2; A held on a checkbox
changing it once; the save prompt waiting through a held A and saving on
the next press. Not seen: a tap during `Reading...`, and the Super Game
Boy, where the handler stands off for four frames after a packet.

### Daily backup, popups and the SET tab (2026-11-25)

From a read of the 0918 mod's source against this one.

**Two bugs found on the way, both in every build before this one.**

- **The settings file could be written with 256 bytes of stack in it.**
  SDCC 4.5 compiles `n = p - line`, with `line` an array on the stack, as
  `sub a, l` / `ld hl, #2` / `add hl, sp` / `sbc a, h`, and the `add`
  clears the borrow. So a line's length came out 256 too big whenever the
  line crossed a 256 byte boundary of the stack, which depends on how deep
  the call is: a change to the SET tab moved the stack and FAST LAUNCH
  began writing a corrupt `/EZGB.CFG` every time. `line` is static now
  (`file_write`, `source/ezcfg.c`), and no other place in either build
  compiles to that sequence (searched in the `.asm` listings).
- **Bank 13 was 17 bytes too big** from the scroll change of the same day:
  the linker only warns, and what ran off the end was the 12px list's
  code. `list12.c` is in bank 14 now, the one literal it passed to
  `font12.c` is on the stack, and the makefile fails the link on that
  warning.

**Daily backup** makes the new backup first and deletes the older ones
only when it is on the card; it deleted them first, so a copy that failed
left none. Its box is the save prompt's band: `Daily save backup`, the
game, `Copy of older save`, `About N seconds...` from the save's size.

**Popups** are the background color in an outline in light and in DV, and
the background's shade in the other themes; in light they were the dark
gray the kernel as received has. A popup with two buttons has a rule above
them and one between them (`popup_rules`, `source/msgbox.c`).

**The SET tab.**

- `GAME:` sends the list up with ` PICK A ROM ` for its tab strip: A on a
  game takes it, SELECT or B in the root gives up, and both come back to
  the SET tab. It stepped through the recent list.
- FAST LAUNCH with no game set is on, as the file means it: `GAME:` reads
  `(AUTO)`, the card's one game. Unticking writes `FLAUNCH=#`, which turns
  that off too. Ticking shows `Hold START at boot to cancel`.
- `THEME:` steps with A and back with B through light, dark, DV, red,
  green, purple, blue, custom; where only `BGP` can be set it is light,
  dark, DV, and a color theme from the file is dark and reads `DARK`.
- SKIP BOOT ROM is drawn in index 2 with an empty box, and passed over,
  on a console with nothing to choose: one that cannot start a game
  without its boot ROM, or the DMG family with SGB BOOT on.
- CLEAN NAMES has an example under it, `Game Title (USA) (Rev 1) [!].gb`
  or `Game Title`.
- A channel of the color picker stops at 0 and 31, and a held direction
  there repeats as on the rest of the tab.

Seen in SameBoy: the daily backup making its copy and then deleting an
older one; the menu, the save manager and the save prompt in light in both
fonts; the notice, a pick and a canceled pick; B on `THEME:`; the example;
`/EZGB.CFG` written right from FAST LAUNCH with three different files. Not
seen: SKIP BOOT ROM grayed, DV where only `BGP` can be set through the
row, the Chinese build.

### The list, the saves and names that scroll (2026-11-26)

More of the audit against the 0918 mod.

**The list**

- **Sort.** The keys hold 13 characters of a name (12 with SORT BY PLAYS),
  so `Legend of Zelda, The - Oracle of Ages` and `... Oracle of Seasons`
  had the same key and stayed in card order. After the records are
  written, each run of rows with the same key is put in order by the whole
  names, case aside, an insertion sort that swaps records through
  `SD_buffer` (`ties_fix`, `browser.c`). Runs are short and their rows are
  next to each other, so few records move.
- **After Star or Unstar** nothing is read from the card and there is no
  `Reading...`. The keys are made again from the records in save RAM and
  sorted, and each record goes straight to its row (`list_resort`). The
  cursor stays with the game, on the screen row it was on when the list
  reaches that far. A folder that was cut at 416 stays in card order and
  only its marks change.
- **The position.** 8px: `n/total` in the five columns right of `HELP`
  while the total has under three digits, else `n` alone, from a column
  that holds for the folder (`list8_counter`). 12px: `n/total` when
  `total/total` fits right of `HELP`, else `n` alone, decided once for the
  folder and drawn from one x, so the total no longer comes and goes as
  the number grows.
- **Text files** (`.txt`, `.ini`, `.cfg`, `.md`) have the page icon in the
  12px list too. They had the `?` there.
- **`Too many files.`** is in the status boxes' frame, in the list's font.
- A file named `SAVER` is hidden like the folder.

**Plays and the pending save**

- **A play** is a launch picked in the list. Fast launch and the recent
  list no longer count (`cfg_launch(count)`).
- **A lone ROM** is counted as the 0918 mod counts it: every file in the
  root but `*.dat`, the settings files, and names that start with `.` or
  `_`. A save, a text file or a hidden name beside the game means the list
  comes up. It was counted by what the list shows.
- **The boot stamp.** The prompt and the daily backup only come up when
  the stamp's path is `/SAVER/` and a save's name (`save_stamp_ok`). The
  write already refused anything else; the prompt showed the garbage first.

**Names that scroll**

`mq_start`, `mq_step` and `mq_stop` in `modmisc.c`: one name at a time, in
a field of 8 pixel cells, held 60 frames and then moved a character every
20, starting again after three blanks ([docs/marquee.md](../../docs/marquee.md)
has the 0918 mod's). In a 12px font the field is the same pixels. The text
is read from RAM, so a caller in another bank copies a literal first. The
Chinese build draws the start of the name and does not scroll, since a
step could cut a two-byte character.

- the hold-A menu's name band, which stepped every 12 frames with no hold
- the save manager's band, now the game's whole file name
- the save prompt's band, now the save's file name with `.sav`
- the SET tab's `GAME:` name
- the CLEAN NAMES example

**Manage saves**

- A row a backup, a text row apart: seven rows in 8px and five in the 12px
  fonts. It was four, two rows apart. The Chinese build keeps four.
- The selected row is a band in the selection's colors. It had a `>`.
- UP and DOWN stop at the ends, and repeat when held (`pad_menu`).
- The newest 37 backups are listed. It was 24.
- The box is drawn once. A move draws the rows, so the name goes on
  scrolling. The Restore or Delete question is in the title's place.
- A game whose name is too long for the paths opens the screen with
  `No save yet`. It did not open.

**The Chinese build's bank 8** was full with the sort's new code: the text
viewer is in bank 30 there (`modbank3.h`).

**The text viewer**

- UP and DOWN move a row: the rows that stay are moved in VRAM and only
  the row that comes in is read and drawn (`rows_move`, as the list does).
  The page was cleared and drawn again for each line.
- A held UP or DOWN waits before it repeats (`pad_menu`).
- LEFT and RIGHT move a page less a row, so the last row read is the first
  of the next page. A pages on like RIGHT.

**The clock prompt** is the 0918 mod's: `CHIP` and `SD`, each a date and
under it a time with seconds, a rule under the title and over the buttons.
The chip's bytes are shown as read, in hex, so a bad one can be seen; the
line was left out for `RTC BAD?`. The box is cleared when it is answered.

**The hold-A menu** has the title `Options` and its box starts under the
tab strip. It comes up while A is still down.

**The HELP tab** has `github.com/lukesau/` and `ezgb` under the site.

**Settings and the file.** A setting changed on the SET tab takes effect
at once, and so do the records in save RAM, but `/EZGB.CFG` is written on a
change of page and on leaving the tab (`cfg_flush`), not at each A. AUTO
SAVE is the same. TIME SET, a picked game and the hold-A menu's
`Fast launch:` still write at once. Power off with the tab up and the
change is not in the file.

The save's `Saving.`, `..`, `...` was already here: `Save_new_SAVE` steps
it a sector at a time, too fast to see on a small save.

Seen in SameBoy: the tie order and the star's new place with no card read
in 12px; both counters, with two and three digit totals; the page icon;
the notice; the save manager in both fonts and on the DMG model; the SET
tab's name and the menu's scrolling; the save prompt's name; a card with
one game beside a save opening the list, and without the save starting
the game; a launch from the list counted in `/.ezgbplays` and a fast
launch not; a stamp with a bad path giving no prompt; the viewer's line
scroll and pages, the clock prompt, the menu and the HELP tab in both
fonts; the file unchanged with the SET tab still up, and written on
leaving it and on a change of page. Not seen: the Chinese build.

### What of the 0918 mod is not here

- **The debug page and the flash dump**, which are a debug build's there.
- **The START overlay for the last game.** This kernel has its recent list
  on START.
- **Moving the cursor by recoloring rows in VRAM.** A row is drawn again
  instead, with the fast copy in every theme.
- **The text viewer's 10 pixel rows and its slim font in the 8px UI.** Here
  it is in the slim font when the list is in a 12px one, 12 pixels a row,
  and in the 8px font otherwise.

### The FW6 clock load, removed

Until 2026-11-24 this tree had one change: the launch stub wrote a game's
clock the way a game does, because the FW6 test build of 2026-11-17 did not
load its clock from the kernel's write to `$A018-$A01C`. The released FW6
does ([stage0/docs/fw6.md](../../stage0/docs/fw6.md)), so the change is gone.
