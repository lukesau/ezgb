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

Bank 0 is the one that cannot grow: everything every bank calls is in it,
and the English build has about 750 bytes of it left. A feature's code
goes in a banked file, with only its call in bank 0.

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
| SGB BOOT: the header packets a Super Game Boy needs | `source/sgb.s`, `source/ezcfg.c`, `makefile` |
| Two more SET pages for the mod's settings | `source/setpage.c`, `source/ezcfg.c`, `source/RTC.c` |
| Themes: light, dark and four colors | `source/ezcfg.c` |
| The 12px proportional font (English build) | `source/font12.c`, `source/font12_data.s`, `source/list12.c`, `source/ezcfg.c`, hooks in `source/Bank_fun.c`, `source/main.c`, `source/UI.c`, `makefile` |
| Hold A on a game for its options | `source/rommenu.c`, `source/main.c`, `source/sgb.s` |
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
bank 0 has no room: for the same reason `Filename_loop`, the 8px list's
name scroll, is in `source/list8.c` (bank 4).

Folders come first, then files, each by name without regard to case. No
record is moved: the folder is read once to make a 16-byte key per entry in
save RAM bank 31, the keys are heapsorted, and a second read writes each
record straight to its row. Two names with the same first 13 characters
stay in card order.

Not listed, file or folder: a name that starts with `.` or `_`; one that
ends in `.gba`, `.nds`, `.sav`, `.esv` or `.dat`; `EZGB.CFG`, `FLAUNCH.CFG`
and the `SAVER` folder; and, as before, anything hidden or system.

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
Each has four rows: DOWN from a page's last row is the next page, UP from
its first the one before, and UP from the very first goes back to the
tab's first page. SELECT leaves the tab. A acts on the row under the
cursor and writes `/EZGB.CFG`.

| Row | Does |
|---|---|
| `SKIP BOOT ROM:` | ticked is the jump; unticked writes `BOOTROM=1` |
| `FAST LAUNCH:` | on and off, by the `#` in front of the `FLAUNCH=` path. With no game set, turning it on takes the last game launched |
| `GAME:` | the fast launch game by name; A makes it the last game launched |
| `SGB BOOT:` | sets or clears the record in save RAM, for the boots after this one. `SGB=` in the file is updated only when the file already has it |
| `THEME:` | the next theme |
| `FONT:` | `8PX`, `12PX` or `EZF` |
| `CLEAN NAMES:` | unticked writes `TAGS=1` |
| `RTC SD BACKUP:` | unticked writes `RTCSD=0` |

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

Two differences from the 0918 mod:

- **The accents are deeper.** This kernel draws a highlight as the ink on
  index 2; the 0918 mod draws the background color on its accent. White
  text does not read on the 0918 accents (gold, apricot), so the color
  themes here have a darker color of the same hue at index 2: sky
  `#1A6FD0`, rose `#C2407F`, gold `#9A7A00`, apricot `#C85A1A`. These are
  my picks and have only been seen in the emulator.
- **No custom colors and no DV.** `THEME=6` and `7` from the 0918 mod show
  as dark, and the file keeps its number until the row is used.

The theme is applied once the card is read, so the first second of a boot
is light. On a DMG the dark theme's selected row is white on light gray,
the mirror of stock's black on dark gray, and as hard to read.

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
| The recent list | stays 8px: its rows are laid out 8 pixels apart, up to 14 of them |
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
- **Fast launch** makes this the game power-on starts (`FLAUNCH=` and its
  whole path), and turns it off again when it already is. This is how a
  game other than the last one launched is picked.
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

Not carried over: `Manage saves` and `Star`, which wait for those
features, and the text viewer for a file that is not a game.

### The FW6 clock load, removed

Until 2026-11-24 this tree had one change: the launch stub wrote a game's
clock the way a game does, because the FW6 test build of 2026-11-17 did not
load its clock from the kernel's write to `$A018-$A01C`. The released FW6
does ([stage0/docs/fw6.md](../../stage0/docs/fw6.md)), so the change is gone.
