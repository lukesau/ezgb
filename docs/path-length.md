# Directory-path bound check

The browser keeps the current directory path as a NUL-terminated string in a
fixed 255-byte WRAM buffer at `$c2a6`, immediately followed by the save-file
path buffer at `$c3a5`. Entering a directory appends `"/" + name` to the path
with no length check (`MenuDispatchAB_dirAppend`, `00:140f`), so a deep enough
nesting overflowed `$c2a6` into `$c3a5` and silently corrupted the save path.

The path buffer cannot be safely enlarged in place: low WRAM from `$c4c3` up is
saturated with FatFs's 512-byte work buffers (the long-name buffer, the FATFS
sector window, the directory and file objects), all reached through base
pointers that a static scan does not see, and two relocation attempts corrupted
directory reads (verified under SameBoy). See the reasoning in the session
notes; the buffer stays at `$c2a6`.

Instead, `DirEnterBoundCheck` (`00:0556`, 50 bytes, bank-0 cave after the
last-ROM hooks) guards the append. Reached by `jp` from `00:140f`, it measures
`strlen(path)` and `strlen(name)` (the selected record at `[$c2a0] + [sp+$04]`,
the same pointer `dirToBrowser` uses) and, if `L1 + 1 + L2` would exceed 254,
jumps straight to `FileBrowserEntry` (`00:0f8d`) leaving the path untouched, so
the descent is a harmless no-op. Otherwise it replays the displaced
`ld hl, PathSlashStr` and continues into the stock append.

Bank 0 is byte-identical across 1.05e-0731 and 1.05e-0918, so the hook and its
call site are the same address and bytes in both.

## Verification

Under SameBoy (`--model dmg`): normal descent into `/Pokemon` still works; with
the threshold temporarily lowered so a short name trips it, pressing A on a
directory is a no-op that leaves the browser at the current directory, fully
navigable. Confirmed on GBC and GBA SP.
