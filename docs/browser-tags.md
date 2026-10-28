# Clean ROM names: hiding the tags in file names

A ROM set names its files after a convention: No-Intro writes
`Tetris (World) (Rev 1).gb`, GoodTools `Tetris (W) (V1.1) [!].gb`. The tags
say which dump this is, which the browser's 19 columns (or the 12px row)
would rather spend on the title. With the `TAGS:` box on the SET tab
unticked (`TAGS=0` in `EZGB.CFG`, [ezgb-cfg.md](ezgb-cfg.md)) the browser
shows `Tetris` for either. The default is the full name, as before.

## The rule

A file's name as drawn is the name cut at the first ` (` or ` [`, or, when
it has neither, at its last `.` (the extension), with blanks before the cut
dropped. Both conventions keep parentheses and brackets out of the title
itself, so no tag list is needed: the rule was checked against 695 GoodGBX
names and never cut into a title. A name starting with a tag or a dot is
left alone (the cut is never at 0), and a folder is never cut.

Two files that differ only in a tag, `Tetris (World).gb` and
`Tetris (World) (Rev 1).gb`, show the same name. That is by design: the full
name is one hold of A away ([rom-menu.md](rom-menu.md)), and so is
everything else that names a file: the START overlay, the BACKUPSAVE
prompt, the save manager, the SET tab's fast-launch name. The cut is
display-only. The record keeps the whole name, so sorting, launching and
the save file's name are unchanged.

## Where the cut happens

Two places draw a browser name: the row draw, for every entry on the page,
and the stock marquee, which scrolls the selected row's name when it does
not fit. Both now measure the name through one function.

| Block | Where | Does |
|---|---|---|
| `TagCat` | `05:7a00`, [kernel/src/tagtrim.c](../kernel/src/tagtrim.c), 324 B with `TagLen` (after the hide filter's slot, bank 5 having the room) | The marquee's gap strcat. `DrawDirEntryLabel` copies `name[offset..]` to `$c4a4`, far-calls `CStrCat_B1` (`01:4000`) to append the three-blank gap, then the name's start again for the wrap. The far target at `00:0d6c` is now `TagCat`: with `TAG_CUT` set it NUL-terminates the buffer at the cut first (the marquee's offset stays below the cut, so the cut point is always still in the buffer), then appends the gap as before. Inline far call: two pad parameters |
| `TagLen` | `05:7a55` | The name's length as drawn: the cut, when `TAGS_HIDE` is set and the record's attribute byte (`name[254]`) is not a directory, else `strlen`. Sets `TAG_CUT`. Called stub: three pad parameters |
| `FarCallTagLen` | `00:0408`, 8 B | `call FarCallTrampoline; db 55 7a 05 00; ret`. The marquee's `call CStrLen` on the name (`00:0c55`) calls this instead, so `namelen` (frame `sp+$0e`) is the drawn length: the scroll check, the offset modulus and the 12px fit check (`MarqueeWidth12` compares `Fit12`'s count with that slot) all see the short name |
| `DrawNameWithIcon` | `02:7e80`, [kernel/src/browser_icons.c](../kernel/src/browser_icons.c) | The row draw calls the same stub (one argument: the stub and the trampoline supply the three words `TagLen`'s pads stand for) and copies that many characters into its zero-padded row buffer, in both UI modes. 8px `DrawString` draws its `len` cells whatever the buffer holds, hence the padding |

`TAGS_HIDE` is WRAM `$DBF6`, loaded with the file (`ezcfg.c`, key index 7,
written only as `TAGS=0`). `TAG_CUT` is `$DAFF`, past `FL_PATH`'s end
(`$DBF0-$DBF5`, the obvious neighbors, are FillRect's scratch).

## SET tab

The `TAGS:` checkbox shares row 16 with `SGB BOOT:` and is cursor row 8
(clamp `04:5604` `d6 08`, [fastlaunch-set-tab.md](fastlaunch-set-tab.md)).
Ticked means the tags are shown. The row's two boxes are drawn and toggled by
`SgbTagsRow` (`04:77a0`, [kernel/src/sgbtags_row.c](../kernel/src/sgbtags_row.c)),
near-called by `flcfg` like `ThemeRow`: `flcfg` (`04:6600`) had outgrown
its slot with the box in it, and moving the SGB record access and the row
out took it from 1786 to 1594 bytes. `SetText` (`04:6400`) grew by 21 bytes
for the row's 12px spans ([set-pane12.md](set-pane12.md)), so the `SmSaveOp`
stub moved from `04:6562` to `04:65f0` ([save-manager.md](save-manager.md)).

```
SGB BOOT: [ ]  TAGS: [x]     8px: "SGB BOOT:" cols 0-8, box x 74 (68 in 12px);
                             "TAGS:" cols 11-15, box x 130
SGB: AUTO      TAGS: [x]     when our stage1 handles the SGB: the short label
                             and AUTO from col 5 (12px x 34..86)
```

## Reproduce

```sh
cd kernel; V=1.05e-0731
python3 tools/inject.py src/tagtrim.c $V 5 7a00 TagCat --apply
python3 tools/inject_bytes.py $V 0 0408 FarCallTagLen cd8d07557a0500c9 --apply
python3 tools/patch_bytes.py $V 0 0c55 cd952d cd0804 --apply        # marquee: CStrLen(name) -> FarCallTagLen
python3 tools/patch_bytes.py $V 0 0d6c 00400100 007a0500 --apply    # marquee: CStrCat_B1 -> TagCat
python3 tools/patch_bytes.py $V 4 5604 d607 d608 --apply            # cursor clamp: row 8
python3 tools/inject_bytes.py $V 4 65f0 SmSaveOp f8022a666fe5cd8d0770760100e802c9 --apply   # moved from 04:6562
python3 tools/inject.py src/sgbtags_row.c $V 4 77a0 SgbTagsRow --pin FarCallEzCfg=5f00 \
    --pin SetFpgaPage_B4=466e --pin SetText=6400 --pin StoreDrawParams=2791 --pin DrawRect=27ba --apply
cd ..; scripts/rebuild-blocks.py --apply     # ezcfg.c, browser_icons.c, settext.c, flcfg.c, save_mgr.c (SmSaveOp pin)
```

The blocks are in `scripts/port-mod.py`'s `REGISTRY` (`TagLen` as an
export, since the stub calls it by address), so the other kernels are
ports. Checked in SameBoy (DMG model) on 0731, 0918 and 1.04e, 8px and
12px: the page, the marquee on a 50-character title, the hold-A menu's
full name, the SET tab box in both states and the file it writes.
