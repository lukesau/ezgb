# The last ROM: the START overlay

START in the browser shows the last launched ROM and A runs it again.
Stock has this, with a record that turns to garbage when the coin cell
dies and a box that is never drawn closed. The mod fixes both. Addresses
are 1.05e-0731's.

## The record

| | |
|---|---|
| Where | pSRAM page `$11`, `$A300`, reached with `$4000 = $11` and `$7FC0 = $03` ([psram-map.md](psram-map.md#page-11)) |
| Size | 255 bytes |
| Holds | the ROM's full path as a NUL-terminated string, one byte a character, in the form the loader uses: `/pokemon/Pokemon Blue.gb` |

Stock writes it on every launch (`LastRomPersist`, `01:4856`) from the
path buffer at `$c2a6`, and the overlay (`LastRomOverlay`, `00:129e`)
copies it back to `$c4a4`. The overlay shows only the basename, the part
after the last `/`, and relaunches with the full path, so a ROM in a folder
loads from where it is.

## When the record has faded

The record is battery-backed, so a dead cell leaves random bytes there,
and stock draws them as a name. The mod validates it and keeps a copy on
the card:

- **Validation.** Before the overlay draws, `EzCfg` op `OP_LASTLOAD`
  checks the copy in `$c4a4`: a first byte of `/`, a NUL within 255 bytes,
  no control or `$FF` bytes, and a basename that is not empty and has a
  `.`.
- **The copy.** On every launch, op `OP_LASTSAVE` records the path as
  `LASTROM=` in `EZGB.CFG` ([ezgb-cfg.md](ezgb-cfg.md)). When the record
  fails validation the overlay uses that, and with neither it shows
  `(none)`.

A valid record is used directly with no card access, so the usual case
costs nothing.

| Site | Stock | Now |
|---|---|---|
| `01:48c1`, `LastRomPersist`'s tail | `add sp,$04; ret` | a jump to `PlayLaunchHook` (`01:7ec6`, [stars.md](stars.md)), which goes on to `LastRomSaveHook` (`01:7610`): op `OP_LASTSAVE`, then the displaced tail |
| `00:12c8`, the end of the record copy | `jp nc, LastRomDrawBasename` | `jp nc, LastRomFallbackHook` (`00:0540`): op `OP_LASTLOAD`, then on to `LastRomDrawBasename` or, with nothing to show, `LastRomReturn` |

The save hook is at the persist routine's tail because the path is fully
assembled in `$c2a6` only there.

## The box

Stock draws its boxes first and its text afterwards, and the 8x8 text
cells repaint parts of the boxes, so the outer box loses its sides on the
name's row and the button frames lose their bottom edge.

The mod draws one closed box with three rows: a title, `Launch Last ROM?`,
the name on a solid band that spans the box, and the two button labels
with a vertical rule between them.

| | 8px | 12px |
|---|---|---|
| box | (0,91)-(159,139); the list is cleared from y 88 down | (0,92)-(159,143), flush under list row 5 |
| title | tile row 12, column 1 | y 96, from x 12 |
| name | tile row 14, column 1, 18 characters | y 112, from x 12, as many glyphs as end 2 px short of the right side |
| labels | tile row 16, columns 1 and 11 | y 128, from x 12 |
| name band | y 107..123; vertical rule at x 83 below it | y 109..125; vertical rule at x 79 below it |

**Draw the band and the frame after the text.** `DrawString12` paints its
row out to x 159, over the box's right side, so `LastRomBox` follows its
12px draws with an outline of the box, then the band and the rule.

A name that does not fit its field scrolls ([marquee.md](marquee.md)).

| Site | Stock | Now |
|---|---|---|
| `00:12a1`, the far call in `LastRomOverlay` | `DrawLastRomButtons` (`08:73f5`) | `LastRomBox` (`02:4800`, [lastrom_box.c](../kernel/mod/src/lastrom_box.c)) |
| `00:131d` | the name at column 0, 20 characters | column 1, 18 characters |
| `00:132b` | `call DrawString` | `call LastRomNameStub` (`00:0368`), a far stub to `LastRomName` (`02:7800`, [lastrom_name.c](../kernel/mod/src/lastrom_name.c)), which sets the name up and draws it |
| `00:1330`, `LastRomInputLoop` | `call ReadJoypad` | `call LastRomTickStub` (`00:0370`): the marquee's tick, then `ReadJoypad` |

The same box, name band and tick are used by the BACKUPSAVE prompt
([prompts.md](prompts.md)) and the ROM menu ([rom-menu.md](rom-menu.md)).

## Relaunching

A in the overlay goes to `LastRomRelaunch` (`00:1344`), which splits the
path into folder and name and runs the stock launch
([boot-and-launch.md](boot-and-launch.md#launching-a-game)). Fast launch
reuses the same routine ([fast-launch.md](fast-launch.md#the-launch)).
