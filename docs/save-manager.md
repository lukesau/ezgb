# Manage saves: dated backups, restore and delete

Hold A on a ROM, pick **Manage saves** ([rom-menu.md](rom-menu.md)):

```
Saves                     "Working...", then "Done" or "Error" after an action
<ROM name>                the Options box's band
Back up save              "No save yet" when the ROM has no save
26-10-11 12:00            backups, newest first
26-10-10 14:32 (2)
26-10-10 14:32
[B]back | [A]ok
```

- **Back up save** copies `/SAVER/<base>.sav` to a backup named after the
  save's last-modified time.
- **A on a backup** puts its time in the title and offers **Restore** /
  **Delete**, then asks `Restore this save?` or `Delete this save?`
  (`[B]no | [A]yes`).
  - Restore backs the current save up the same way, then copies the backup
    over `<base>.sav`. The next launch loads it, because every launch reads
    the save from SD (`BackupOpenSaverPath`).
  - Delete removes that backup file. Only backups are offered; the live save
    is never deleted.
- **B** goes back to Options. Start from there launches as usual.

`<base>` is the ROM's file name without `.gb`/`.gbc`, which is how
`BackupOpenSaverPath` names the save (`Tetris.gb` → `/SAVER/Tetris.sav`).

## Names

```
/SAVER/<base> YYYY-MM-DD HH-MM.sav
/SAVER/<base> YYYY-MM-DD HH-MM (2).sav
/SAVER/<base> YYYY-MM-DD HH-MM (3).sav ...
```

The time is the save file's FAT modified date. The kernel's `get_fattime`
reads the cart RTC (`RtcReadPage`, from `Fsync_B3`), so on a cart whose battery
died every save is stamped with the same reset clock. The counter covers that:
the backup takes the first name, counting up from no counter, that does not
open on the card (up to 250). Probing the card instead of the list means
backups that dropped off a full list are still counted.

Names are parsed strictly: `<base>`, any case; one space; the time with its
fields in range (year 1980-2107); then optionally ` (n)` with n from 2 to 250;
then `.sav`. So `Tetris DX.sav` never shows up as a backup of `Tetris.gb`.
The list shows the time as `YY-MM-DD HH:MM` so a counter still fits the 8px
row.

**No rename.** This FatFs build has no `f_rename`, so restore copies the
backup over the save rather than renaming it back, and the backup restored
from stays on the card (delete it afterwards if it isn't wanted).

## Delete

The build has no `f_unlink` either. [kernel/src/fs_unlink.c](../kernel/src/fs_unlink.c)
adds one: R0.10's `f_unlink` and `dir_remove`, injected into bank 9 next to
that bank's copy of the FatFs internals and calling them directly
(`find_volume`, `follow_path`, `ld_clust`, `dir_sdi`, `move_window`,
`dir_next`, `remove_chain`, `sync_fs`), so the FAT is changed by the same
code that writes the saves. Directories and read-only files are refused.

The structures come from `Open_B9`, which is really `f_mkdir` (it calls
`get_fattime` first and turns `FR_OK` from `follow_path` into `FR_EXIST`):
a 26-byte DIR with `fn` at `+$14` (a 12-byte stack buffer) and `lfn` at
`+$16` (`LfnBuf`, `$C5A9`), and a FATFS with `wflag` `+4`, `fsi_flag` `+5`,
`free_clust` `+$0e` and `winsect` `+$2e` (R0.10 with `_FS_RPATH`). Each
internal's argument size matches the `add sp` after its calls in bank 9.
The bank's annotation gives `RemoveChain_B9` a third `pclst` argument; it
has none (it reads `fs` and `clst` only, and its caller pops 6 bytes).

**FSInfo.** This kernel's mount starts `free_clust` at 0 instead of
reading the FAT32 FSInfo sector. Any allocation underflows it to
`$FFFFFFFF`, which `sync_fs` writes as "unset", and hosts recount; the
kernel's own save dumps leave the card that way. But a free with no
allocation earlier in the boot counts up from 0: the first delete wrote 65
(clusters freed by a 32 KB save) as the card's free space, which a host
could believe. `FsUnlink` sets `free_clust` to `$FFFFFFFF` and flags FSInfo
before `sync_fs`, so a delete leaves it "unset" like everything else.

## Copying

Source on the kernel FIL (`$CA0F`), destination on a second FIL, 512 bytes at
a time through the loader's `$C0A0` scratch buffer. Only whole sectors and a
tail under 256 bytes are moved. This FatFs copies a partial-sector transfer
with an 8-bit count ([ezgb-cfg.md](ezgb-cfg.md), ezcfg.c's `far_write`), so a
256-511 byte tail would be cut short. Saves are whole 8 KB banks plus at most
the 48-byte RTC footer, so they never hit it. A file with such a tail is left
out of the list (and the save itself can't be backed up).

> **Correction (2026-10-11).** [fastlaunch-config-design.md](fastlaunch-config-design.md)
> called this FatFs an FS_TINY build. It is not: every FIL carries its own
> 512-byte sector buffer at `+$20` (`Fsync_B3` writes it back from there,
> `Lseek_B3` reads it), so a FIL is `$220` = 544 bytes. The kernel's FIL at
> `$CA0F` runs to `$CC2E`, and the next kernel variable, `wDebugTextRow`, is at
> `$CC2F`. The first version of this feature put a second FIL in 32 bytes at
> `$D750` and overran its own state; the backup it wrote was fine, but the list
> came back empty. Earlier code that reuses `$CA0F` is unaffected.

SD discipline is ezcfg's: `WaitVBlankFlag` and `$7FC0 = $00` before every
FatFs call, paths in WRAM. On the way out (`SO_DONE`) `$7FC0` goes back to
`$03` and `$4000` to the browser's record page, which `RomMenu` works out
from the loop frame (entry index `sp+$13` + `sp+$15`, / 32, + `$12`, as
`MenuDispatchAB_bankEntry` does), because the open path reads the selected
record through that window when Start follows.

## Memory

| | Address | Size | |
|---|---|---|---|
| `LABEL` | `$D750` | 24 | `SO_LABEL`'s text |
| `LIVE` | `$D770` | 7 | save found; its time as a list entry |
| `COUNT`, `BLEN` | `$D777`, `$D778` | 1, 1 | backups listed; length of `<base>` |
| scan | `$D780` FILINFO, `$D7A0` LFN (128), `$D820` list, `$D900` DIR | | the fast-launch scan window |
| copy | `$D780` second FIL (544), `$D9A0` path (96), `$C0A0` buffer (512) | | the list is rescanned after a copy |

A list entry is 6 bytes: year - 1980, month, day, hour, minute, counter. The
list keeps the newest 37. A 96-byte path allows a `<base>` of up to 60
characters; a longer ROM name shows "No save yet".

`$D74E-$D77F` sits between the kernel's last variable (`wTileCursorY`,
`$D74D`) and the fast-launch window, and nothing references it.

## The patch

Bank 4 has the screens, but not room for the file work as well, so that is
`SaveOp` in bank 1, far-called with an op and a list index in one word
(op in the high byte): `SO_SCAN`, `SO_BACKUP`, `SO_RESTORE`, `SO_DELETE`,
`SO_LABEL` (a backup's time as list text, into `LABEL`) and `SO_DONE`. The
name parser didn't fit bank 1 with it and went back to bank 4 as a far
target of its own; `f_unlink` has to live in bank 9.

| Block | Size | What |
|---|---|---|
| `ManageSaves` `04:6d11` | 1678 | [kernel/src/save_mgr.c](../kernel/src/save_mgr.c): the screens, near-called by `RomMenu` |
| `SaveNameMatch` `04:73a0` | 715 | [kernel/src/save_name.c](../kernel/src/save_name.c): `<base>.sav` or a backup's name |
| `SmSaveOp` `04:6562` | 16 | far stub to `SaveOp` |
| `SaveOp` `01:7670` | 1750 | [kernel/src/save_ops.c](../kernel/src/save_ops.c): scan, copy, back up, restore, delete, labels |
| `SoOpendir` `01:7630`, `SoReaddir` `01:7646` | 22, 22 | far stubs to `Opendir_B5` (`05:73dd`) and `Readdir_B5` (`05:7576`), the bank-2 `FarCallOpendir_B5`'s bytes |
| `SoUnlink` `01:765c` | 16 | far stub to `FsUnlink` |
| `SoMatch` `01:7d50` | 22 | far stub to `SaveNameMatch` |
| `FsUnlink` `09:7cc0` | 486 | [kernel/src/fs_unlink.c](../kernel/src/fs_unlink.c) |

Every block sits where all three stock kernels are free: 0918's bank 1 has
data at `01:7391`, which 0731 and 1.04e leave free.

```sh
cd kernel
V=1.05e-0731
python3 tools/inject_bytes.py $V 4 6562 SmSaveOp f8022a666fe5cd8d0770760100e802c9 --apply
python3 tools/inject_bytes.py $V 1 7630 SoOpendir f8042a666fe5f8042a666fe5cd8d07dd730500e804c9 --apply
python3 tools/inject_bytes.py $V 1 7646 SoReaddir f8042a666fe5f8042a666fe5cd8d0776750500e804c9 --apply
python3 tools/inject_bytes.py $V 1 765c SoUnlink f8022a666fe5cd8d07c07c0900e802c9 --apply
python3 tools/inject_bytes.py $V 1 7d50 SoMatch f8042a666fe5f8042a666fe5cd8d07a0730400e804c9 --apply
python3 tools/inject.py src/fs_unlink.c $V 9 7cc0 FsUnlink \
    --pin FindVolume_B9=76f7 --pin FollowPath_B9=72c5 --pin DirSdi_B9=54db \
    --pin DirNext_B9=580c --pin MoveWindow_B9=437e --pin LdClust_B9=5d72 \
    --pin RemoveChain_B9=4f94 --pin SyncFs_B9=4447 --apply
python3 tools/inject.py src/save_ops.c $V 1 7670 SaveOp \
    --pin WaitVBlankFlag=0688 --pin FarCall_06_7309=1926 --pin FarCall_06_779a=1941 \
    --pin FarCall_07_7739=1963 --pin FarCall_03_768f=19a1 --pin SoOpendir=7630 \
    --pin SoReaddir=7646 --pin SoUnlink=765c --pin SoMatch=7d50 --apply
python3 tools/inject.py src/save_name.c $V 4 73a0 SaveNameMatch --apply
python3 tools/inject.py src/save_mgr.c $V 4 6d11 ManageSaves \
    --pin FarCallDrawString12=05c0 --pin LastRomNameStub=0368 \
    --pin LastRomTickStub=0370 --pin DrawString=08b7 --pin DrawRect=27ba \
    --pin StoreDrawParams=2791 --pin SmSaveOp=6562 --apply
```

## Testing

SameBoy `--model dmg`, 0731, the `sd/` card plus a `/SAVER/Tetris.sav` of
32,816 bytes (32 KB + a 48-byte footer) dated 2026-10-10 14:32:

- Back up twice: `Tetris 2026-10-10 14-32.sav` and `Tetris 2026-10-10 14-32 (2).sav`,
  each byte-identical to the save, listed newest first; the save's own date
  unchanged
- Replace the save on the card with different contents dated 2026-10-11
  12:00, restore `26-10-10 14:32`: `Tetris.sav` is byte-identical to the
  first backup, and the replaced save is in `Tetris 2026-10-11 12-00.sav`,
  byte-identical, at the top of the list
- `UI=12`: four list rows, the selection band, B back to Options, then Start:
  `Loading...` and `LASTROM=/Tetris.gb` in `EZGB.CFG`, so the record page
  was put back
- 0918: the same list

Delete, after the split into banks 1, 4 and 9:

- 0731, two backups on the card: Restore / Delete on the older one, Delete,
  yes: the file is gone, 65 clusters (its 32,816 bytes) are free again, the
  other backup and the save are byte-identical to before, and `fsck_msdos`
  reports nothing new beyond FSInfo "unset" (it reported 65 before the
  FSInfo fix)
- 0918, one run: back up, restore the 12:00 backup, delete the ` (2)` backup
  the restore made. The save holds the 12:00 contents, `14-32` the old save,
  `12-00` unchanged, ` (2)` gone; `fsck_msdos`: FSInfo "unset" plus the test
  image's own volume-label warning, which the untouched card has too

SameBoy's SD stub is slow at writes: a 32 KB copy takes about 40 seconds
there.
