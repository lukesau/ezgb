# Directory-path bound check

The browser keeps the current directory path as a NUL-terminated string in a
fixed 255-byte WRAM buffer at `$c2a6`, immediately followed by the save-file
path buffer at `$c3a5`. Stock appends `"/" + name` when a directory is
entered, with no length check (`MenuDispatchAB_dirAppend`, `00:140f`), so a
deep enough nesting overflows into `$c3a5` and corrupts the save path.

The buffer cannot move: FatFs's work areas follow it in low WRAM and are
reached through pointers a static scan does not find.

`DirEnterBoundCheck` (`00:0556`) guards the append instead. Reached by `jp`
from `00:140f`, it measures the path and the selected name (the record at
`[$c2a0] + [sp+$04]`), and if path + `/` + name would exceed 254 bytes it
jumps to `FileBrowserEntry` (`00:0f8d`) with the path untouched, so entering
that directory does nothing. Otherwise it replays the displaced
`ld hl, PathSlashStr` and continues into the stock append.

Confirmed on a GBC and a GBA SP.
