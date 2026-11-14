# The kernel picker

Stock stage1 boots `/EZGB.DAT` and nothing else. Our stage1
([stage1/](../stage1/README.md)) lets a card carry several kernels and
choose between them at power-on, which makes trying a build a matter of
copying a file.

## Which files count

On the kernel path only, that is once fast launch is ruled out, stage1
scans the card's root for files whose 8.3 extension is `DAT`. It skips
directories, the volume label and names starting with `.`. The first four,
in directory order, are kept.

| `.dat` files in the root | What happens |
|---|---|
| 0 | `EZGB.DAT NOT FOUND`, retried every second |
| 1 | it boots, whatever its name, with no prompt |
| 2 to 4 | the picker |
| more | the picker, with the first four |

## The picker

The boot screen stays as it is. The picker takes the five text rows under
the wordmark:

```
     CHOOSE A KERNEL
>EZGB.DAT
 EZGB-104E.DAT
 STOCK-0918.DAT
 MOD-7.0-TEST.DAT
```

Names are upper-cased like all stage1 text and cut at 19 characters. UP and
DOWN move the cursor and wrap. A or START boots the kernel under it. B does
nothing, and there is no timeout.

The cursor starts on `ezgb.dat` when it is in the list, else on the first
entry.

A kernel that fails to load (`KERNEL DAMAGED`, `KERNEL FRAGMENTED`) shows
its error for a second and then the list again, so another can be picked.

## What goes with it

- **In the kernel**, the browser hides every `*.dat`
  ([browser.md](browser.md#what-is-hidden)), and fast launch's lone-ROM
  count ignores them ([fast-launch.md](fast-launch.md)).
- **With stock stage1** a card set up for the picker still boots: stock
  knows only the name `ezgb.dat`, which stays the name of the main kernel.
- **`$A420` on pSRAM page `$11`** is reserved for remembering the last
  pick ([psram-map.md](psram-map.md#page-11)). Nothing uses it yet.

## The code

In `stage1/src`: `fat_scan_dat()` and `fat_select()` in `fat.c`, the picker
itself in `main.c`. The scan also reports which entry is `EZGB.DAT`
(`kernel_default`), so the picker needs no string compare.

Do not test with a 16 MB image formatted as FAT32. It has too few clusters
to be FAT32, and stage1 and the kernel's FatFs both read it wrongly.
