# The save pSRAM

The cart's battery-backed memory: what the kernel keeps in it, how saves
get from it to the SD card, and what is free. It is the 512 KB pSRAM die in
U4 ([hardware-board.md](hardware-board.md)), kept alive by the coin cell,
which also runs the clock. A dead cell loses both, and the pSRAM draws
enough to empty a cell in about a month
([battery-sram-swap.md](battery-sram-swap.md)).

## Two ways in

| Who | How it reaches the memory |
|---|---|
| The kernel | unlock, `$4000` = page, `$7FC0 = $03`, then the `$A000`-`$BFFF` window, 8 KB a page |
| A launched game | ordinary MBC cart RAM (`$A000`-`$BFFF`). The FPGA emulates the game's MBC and maps those writes into the same memory. A game issues no `$7Fxx` commands |

Only 5 bits of the page latch reach the memory, so the kernel sees 32
pages: simulated on all three firmwares
([firmware-diff.md](../stage0/docs/firmware-diff.md#save-pages-from-the-kernel))
and confirmed on an FW5 cart with the debug screen
([debug-tab.md](debug-tab.md)). A page number of `$20` or more aliases a
lower page.

## Pages

| Page | Holds |
|---|---|
| `$00`-`$0F` | Game save RAM, the 128 KB a game can see |
| `$10` | Unused. Independent, battery-backed, and safe to use with the mod |
| `$11` | The kernel's records, below |
| `$12`-`$1E` | Browser records: entry *i* at page `$12 + (i >> 5)`, offset `255 * (i & $1F)` |
| `$1F` | The mod's sort keys, 16 bytes an entry |

The stock browser computes the record page with no mask and no cap. A
folder of 417 entries reaches `$1F`, 449 wrap onto `$00` and overwrite a
save, 961 reach `$10` and 993 reach page `$11`. The mod lists at most 416
entries ([browser.md](browser.md#the-416-entry-cap)).

## Page `$11`

| Address | Record | Written by |
|---|---|---|
| `$A000` | `$AA`: a save is waiting to be backed up | stock, at every launch |
| `$A001` | the size of that save, in 8 KB banks | stock |
| `$A00F`, `$A010`+ | the save path's length and the path, one byte a character, as `/SAVER/PKMRED.sav` | stock |
| `$A200` | AUTO SAVE: 1 skips the prompt | stock, the SET tab |
| `$A201` | `$88`: the cart has power. Anything else is `BATTERY DRY` | stock (`BatteryCheck`, `00:1835`) |
| `$A202`, `$A210`-`$A213`, `$A220`-`$A224` | RTC game mark (`$77`), launch time, game clock copy | stock 1.05e |
| `$A300`-`$A3FE` | the last ROM's full path, NUL-terminated ([last-rom.md](last-rom.md)) | stock (`LastRomPersist`, `01:4856`) |
| `$A400`-`$A403` | SGB BOOT: `'S'`, `'G'`, value, complement ([sgb-boot.md](sgb-boot.md)) | mod |
| `$A404`-`$A407` | SORT BY PLAYS ([stars.md](stars.md)) | mod |
| `$A410`-`$A411` | `"S1"`: fast launch was canceled in stage1 | our stage1 |
| `$A412`-`$A413` | `"SB"` or `"SN"`: stage1 handled the Super Game Boy | our stage1 |
| `$A414`-`$A41F` | theme mark and its four colors ([themes.md](themes.md#where-the-setting-lives)) | mod |
| `$A428`-`$A42F` | the console's boot registers ([skip-boot-rom.md](skip-boot-rom.md)) | our stage1 |
| `$B7F8`-`$BFEF` | play counts and stars ([stars.md](stars.md)) | mod |

**Free:** `$A408`-`$A40F`, `$A420`-`$A427` (reserved for the kernel
picker's last pick, [kernel-picker.md](kernel-picker.md)) and
`$A430`-`$B7F7`.

The page is not cleared at boot, and no game can reach it. Everything in it
fades when the cell dies, so a record is validated before use, and settings
that must survive are in `EZGB.CFG` on the card
([ezgb-cfg.md](ezgb-cfg.md)).

### Marks from stage1

Our stage1 writes three marks every boot, and the kernel's boot hook
(`stage1_skip_mark` in [ezcfg.c](../kernel/mod/src/ezcfg.c)) reads them:

- **`"S1"`** when START canceled a fast launch, zero otherwise. The kernel
  clears it and skips its fast launch for that boot, so the cancel holds
  after START is let go.
- **`"SB"` or `"SN"`**: an SGB was found and unlocked, or there was none.
  Either says our stage1 handles the SGB, so the kernel does not send, sets
  `S1_SGB` (`$DBF8`) so the SET tab shows SGB BOOT as AUTO, and clears the
  mark so a stale one cannot outlive a switch back to stock stage1.
- **The boot registers**, in pop order `F A C B E D L H`. The kernel copies
  them for the jump to a game.

## The save backup

1. **In a game**, cart RAM writes land in pages `$00`-`$0F`. Nothing goes
   to the card.
2. **At every launch**, the loader stamps `$A000 = $AA` with the save's
   size and path (`PreLaunchSaveStamp`).
3. **At the next boot**, `SdMenuMain` (`00:0de4`) maps page `$11` after
   `Micro SD initial OK!`. If `$A000` is `$AA` it takes the backup branch
   (`BackupBranchEntry`, `00:0e76`); otherwise it goes to the browser.

The backup branch reads AUTO SAVE, clears `$A000`, and copies the path to
`$c3a5`. `BackupSavePrompt` (`01:6747`) then shows `BACKUPSAVE` with
`[B]NO` and `[A]OK`, or with AUTO SAVE on goes straight to `Saving`, and
copies the save from pSRAM to `SAVER/` on the card.

Two things follow from where the stamp is set and cleared:

- **It is armed per launch, not per save.** Launching a game arms it
  whether or not the game saved, so the prompt also appears after a session
  with no new save.
- **It is cleared on entry to the branch**, before the prompt is drawn, so
  answering NO clears it too. The prompt appears once per launch.

AUTO SAVE is read at the boot that does the backup, so the setting in
effect then decides. The mod validates the stamp's path before using it,
and keeps AUTO SAVE in `EZGB.CFG` as well ([prompts.md](prompts.md),
[ezgb-cfg.md](ezgb-cfg.md)).

## Against daid's Protocol.md

[daid/ezflashjr](https://github.com/daid/ezflashjr)'s `doc/Protocol.md`
lists the page `$11` fields too. It agrees with the above except that it
gives the save path and the last-ROM path as `wchar_t`. In 1.04e and 1.05e
both are one byte a character, which is why the last-ROM record ends at
`$A3FE` and `$A400` up is free.
