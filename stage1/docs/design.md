# What our stage1 does

Our stage1 replaces EZ Flash's ([stock.md](../stock.md)) in the slot B
bitstream. It is SDCC C plus a few small assembly files, with no GBDK and no
Petit FatFs, and it fits the same 18,432 bytes. It builds for FW4 and FW5.
How to build it is in the [README](../README.md).

## Against stock

| | Stock | Ours |
|---|---|---|
| SD reads to boot a FAT32 test card | 366 | 20 |
| An error | a message, then it hangs | a message, retried every second |
| Color consoles | DMG-only header | CGB flag set; icon in color, grays on a DMG |
| The boot screen | text | icon and wordmark, in the kernel's theme |

- **Reads.** Stock reads the FAT sector again for every cluster. Ours
  caches one sector, so walking a chain costs one read per FAT sector.
- **FAT.** FAT16 and FAT32, with an MBR or without a partition table, root
  directory, 8.3 names. FAT12 is refused with a message. A GPT card gets
  `GPT CARD: USE MBR`; stock and the kernel cannot read GPT either.
- **The load command** is the one stock builds. A file in more than 61
  extents gets `KERNEL FRAGMENTED` instead of overrunning the table.
- **The hand-off** ([handoff.s](../src/handoff.s)) runs at `$D000`. It is
  stock's sequence followed by a clear of the tile map and the CGB
  attributes, since the kernel turns the LCD on before it draws. The kernel
  is entered at `$0100` with `A = $E4`, the value stock leaves there.
- **On FW5**, the console's boot `A` goes to `$7FD3` before the hand-off,
  as stock FW5-0918 does, so a stock kernel still gets the fast-load key on
  a color console ([firmware-diff.md](../../stage0/docs/firmware-diff.md)).

Messages: `SD CARD ERROR`, `INSERT SD CARD`, `EZGB.DAT NOT FOUND`,
`KERNEL DAMAGED`, `KERNEL FRAGMENTED`, `GPT CARD: USE MBR`.

## The boot sequence

1. `crt0.s` saves the boot ROM's registers to HRAM `$FF80`-`$FF87` as its
   first instructions (`A` at `$FF81`, `C` at `$FF82`).
2. The boot screen: the icon and `EZ-FLASH`, then the `Jr.` painted on. Its
   colors come from the kernel's theme mark on pSRAM page `$11`
   ([themes.md](../../docs/themes.md#where-the-setting-lives)), so the
   screen is dark when the kernel is.
3. On a Super Game Boy, the header packets (below).
4. The card is mounted and `EZGB.CFG` read while the wordmark is still
   being shown, so the pause costs no extra time.
5. A fast launch, when one is set and not canceled (below).
6. Otherwise the kernel: the one `.dat` file, or the
   [picker](../../docs/kernel-picker.md) when there are several.

Every boot it writes its marks to page `$11` for the kernel to read
([psram-map.md](../../docs/psram-map.md#marks-from-stage1)): the boot
registers, the SGB mark, and the cancel mark.

## Fast launch

With `FLAUNCH=` set in `EZGB.CFG`, stage1 launches the game itself without
loading the kernel ([game.c](../src/game.c)). It follows the kernel's
launch path step for step:

1. The full path goes to the last-ROM record at `$A300`.
2. The header: the MBC code from `$0147`, the battery and timer flags, the
   ROM mask from `$0148` (raised to cover the file), the RAM mask from
   `$0149`, the header checksum, and the MBC1M logo check.
3. The save: `/SAVER/` and the ROM's name with `.sav`. An existing file is
   copied to pSRAM; with none the expected size is filled with `$FF`. Then
   the backup stamp on page `$11`.
4. The load command, then the game's registers: `$7FC0 = $02`, `$7F37`,
   `$7FC4`, `$7FC1`, `$7FC2`, `$7FC3`, and on FW5 `$7FD3 = $00` and
   `$7FD4 = $11`, the fast-load key.
5. LCD off, the command copied in, then from WRAM
   ([game_handoff.s](../src/game_handoff.s)): start the load, wait for it,
   switch the cart to the game, and reset the console into it or jump to
   its `$0100` ([skip-boot-rom.md](../../docs/skip-boot-rom.md#in-stage1s-fast-launch)).

**Canceling.** START cancels when it is held at power-on or pressed at any
time until the launch is decided. A fast-launch boot shows `HOLD START TO
CANCEL`. A cancel writes the `"S1"` mark, so the kernel does not launch the
game itself. SELECT is read at power-on only.

**What it will not do.** Stage1 boots the kernel instead for anything it
cannot do exactly the kernel's way: a target that is not a `.gb` or
`.gbc`, any file error, or an empty `FLAUNCH=`, which is the kernel's
lone-ROM rule.

### The save rule

While a game runs, its save lives only in pSRAM. The kernel copies it to
`/SAVER` at its next boot when page `$11` holds the `$AA` stamp. So stage1
decides from the stamp:

| Stamp on page `$11` | Stage1 |
|---|---|
| none | launches, loading the `.sav` or filling with `$FF`, and writes the stamp |
| this game's save | launches without copying anything: pSRAM already holds the newest save, and the stamp stays armed |
| another game's save | offers the backup (below); if it cannot write that save, boots the kernel |

### The save backup

Stage1 offers the backup the kernel would
([backup.c](../src/backup.c), after the kernel's `BackupSaveDump`), on
every fast-launch boot with a pending save, and on any boot with SELECT
held at power-on:

0. **The battery canary** (`$A201`) is not `$88`: the cell died and the
   pending save faded with it. Nothing is written. Stage1 skips its fast
   launch and boots the kernel, which handles a dry boot
   ([ezgb-cfg.md](../../docs/ezgb-cfg.md#the-auto-save-backup)).
1. **No stamp**: with SELECT, `NO SAVE TO BACK UP`; then it boots as usual.
2. **A save stage1 cannot write** (a path outside `/SAVER/`, or a file of
   another size): `BACKING UP IN THE KERNEL`, and it boots the kernel.
3. **Otherwise** it shows the game's name and `BACK UP SAVE? B:NO A:YES`,
   or goes straight to saving when AUTO SAVE is on. B on the fast-launch
   game's save carries on with the stamp still armed. B on another game's
   save drops the stamp, as the kernel's does.
4. **A** writes the pSRAM pages over the file's clusters. For a game with a
   clock the 48-byte footer goes in after them, built as the kernel builds
   it. The stamp is cleared and `SAVE BACKED UP` shown. A write error
   (`SAVE ERROR`) boots the kernel.

**When the file does not exist**, `fat_create`
([fat.c](../src/fat.c)) makes it first: a long-name entry with a
FatFs-style short name, a free run of directory entries in `/SAVER`, the
clusters chained in both FATs (counted first, so a full card changes
nothing), FAT32's free count lowered to match, and the clock's date and
time on FW5. It fails, and stage1 boots the kernel, when `/SAVER` is
missing, the name is not plain ASCII, `/SAVER` has no free run of entries
(stage1 does not grow a directory), or the card is full.

### Games with a clock

On FW5, an MBC3 game with a timer has its clock set the kernel's way
([rtc.c](../src/rtc.c)). The cart serves the game a base clock plus the
time since the ROM was loaded, so the base must be the saved clock moved on
by the time since it was saved:

- **A `.sav` with the 48-byte footer**: the clock is advanced by now minus
  the footer's launch stamp, with the kernel's carry rules and the mod's
  clamp of a negative interval to zero.
- **No footer, or no `.sav`**: the clock starts at zero.
- **pSRAM already holds this game's save**: the kernel's copy on page `$11`
  (`$A220`-`$A224`, stamp at `$A210`, present when `$A202 = $77`) is
  advanced the same way. Without that record stage1 boots the kernel.

The result goes to the FPGA's clock window (`$7FC0 = 6`,
`$A018`-`$A01C`) and to page `$11`, as the kernel leaves them, so the
kernel's next backup writes a correct footer.

On FW4 stage1 skips this: FW4 has no game clock. It tells the two apart by
the firmware version byte (`$7FC0 = 4`, then `$A000` reads 4 or 5,
[version-byte.md](../../stage0/docs/version-byte.md)).

## Super Game Boy

The Jr does not work on an SGB as shipped. The FPGA drives the cart's
`/RESET` line push-pull, so the SNES cannot hold the Game Boy CPU in reset
while it starts, and the boot ROM sends its header packets before anything
listens (nitro2k01, [issue #5](https://github.com/lukesau/ezgb/issues/5)).
The header bytes alone, which stock 0918 already sets, do not fix it.

Stage1 sends the packets again ([sgb.c](../src/sgb.c)): the six packets
built from its header, four rounds with the SGB Enabler's 192, 64 and 48
frame gaps, about 6.7 s, right after the boot screen comes up. Only on an
SGB: the boot ROM leaves `C = $14` on an SGB and SGB2, and `$13` on a DMG
and Pocket.

Every boot it leaves `"SB"` (sent) or `"SN"` (no SGB) at `$A412`. With
that mark the kernel never sends the packets itself and shows `SGB: AUTO`
([sgb-boot.md](../../docs/sgb-boot.md)).

This is checked in SameBoy only. The real fix is to drive `/RESET` as an
open drain, which needs a routing change in the bitstream.

## In the emulator

The SameBoy stub runs stage1 as well as the kernel
([DEVELOPMENT.md](../../docs/DEVELOPMENT.md#trying-it-in-sameboy)). It is
enabled for a ROM whose title is `BOOTLOADER`. After stage1's hand-off
write the loaded file replaces the cart with no reset, as the FPGA does.
`SAMEBOY_EZFLASH_JR_LOG=1` sends the stub's messages to stderr, and
`SAMEBOY_SGB_LOG=1` logs every SGB header packet.

## Status

It boots the kernel on FW4 and FW5 carts, and fast launch, the save
backup, file creation and the picker have run on hardware. START
canceling after power-on and the SGB send are checked in SameBoy only.
