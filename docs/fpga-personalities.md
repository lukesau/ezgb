# `$7FC0` personality map (1.05e kernel)

`$7FC0` selects what the FPGA maps into the `$A000`–`$BFFF` cart window (the
"personality"). Written inside the standard unlock/commit envelope by the
`SetFpgaPage_Bx` family (bank-local copies at `00:1a7a`, `01:47a7`, `04:466e`,
`04:41e7` "Alt", `08:6e7a`), each taking the value as a stack argument.

Full static sweep of every call site in `re/1.05e-0731/` (values are the
constant pushed before the call). Register meanings cross-checked against
[daid/ezflashjr](https://github.com/daid/ezflashjr) `doc/Protocol.md`.

| Value | Calls | Maps into `$A000` window | Used by |
|---|---|---|---|
| `$00` | 32 | nothing (unmap) | every access epilogue |
| `$02` | 2 | **game-store write path** (ROM-load command window with `$7F36=$01`) | `RomLoad_WriteCmdWindow_B8` (`08:6e9e`), launch tail (`00:15bf`) |
| `$03` | 17 | **battery-backed pSRAM pages** (page via `$4000` latch) | saves, file list, and all settings - see below |
| `$04` | 1 | FW version bytes | `DrawFwVersionScreen` (`08:7087`) |
| `$05` | 1 | config-flash / fw-update | `RomLoad_ClearCartWindow_B8` (`08:6f98`) - **dead code** (unreferenced) |
| `$06` | 7 | RTC registers (BCD, `$Ax08`+) | clock read/set |

Only the six documented personalities appear. **No undocumented value, and no
personality that opens a fresh, general-purpose nonvolatile window** onto the
parallel NOR die. This is the GB-side counterpart to the updater finding
([updater-flash-write.md](updater-flash-write.md)): neither the kernel nor the
updater exposes a path to the U4 NOR die.

## `$02` is the game-store personality, and the store is volatile

`$02` is set while the ROM-load command window (`$7F36=$01`, 512 bytes at
`$A000`) is written, then the FPGA streams the game from SD into the store.
daid notes `$02` is "used during stage1, but SRAM is not accessed afterwards" -
i.e. it arms the FPGA's SD→store path rather than exposing a CPU-readable
window. The store it targets is the **volatile pSRAM die** (proven in
[nor-reuse.md](nor-reuse.md)). So `$02` does touch the U4 device - but the RAM
die, not the NOR die. Whether the NOR die is even selectable on that bus (by a
different sub-address or chip-enable) is unknown and not reachable through any
existing `$7FC0` value.

## `$05` only appears in dead code

`RomLoad_ClearCartWindow_B8` (`08:6efc`) loops ~`0x2000` times packing
addresses `$40000+i`, writing the command window, and doing a `$05` +
`$7FD2`-wait per iteration - the shape of a config-flash erase/program pass.
But nothing references it (no `call`/`jp`/far-call blob targets it); it is an
orphan sitting before `DrawFwVersionScreen`. So the kernel carries a
config-flash-write routine it never invokes - consistent with config-flash
programming being the updater's job, not the kernel's.

## Where settings actually live (answering "where's the auto-save flag?")

Every persistent kernel value is in the **battery-backed pSRAM**, page `$11`
(17), reached by `$4000 = $11` then `$7FC0 = $03`, read/written through the
`$A000` window, then `$7FC0 = $00`:

| Offset | Value |
|---|---|
| `$A200` | **auto-save flag** (`$00`/`$01`) - read in `DrawTimeAutosaveScreen` (`04:46f4`); toggled by SELECT (`04:58d6`) |
| `$A201` | cart-init stamp (`$88`) - `00:4842`, `00:4929` |
| `$A300` | last-launched ROM full path (255 B) - `00:12bf` read, `01:4856` write ([last-rom.md](last-rom.md)) |
| save data + file list | other pages of the same pSRAM |

So the auto-save checkbox is "nonvolatile" only as long as the coin cell lasts:
it lives in the exact same battery-backed pSRAM as saves and the last-ROM
record, and dies with the battery (the recurring "settings reset when the
battery drains" complaint, [hardware-board.md](hardware-board.md)). The kernel
uses **no truly-nonvolatile store for settings** - which is itself evidence
that no such GB-writable store is available to it. A settings/config store that
survives a dead battery would need exactly the parallel-NOR access path that
does not currently exist.

## Reproduce

```bash
# every $7FC0 value the kernel ever writes (constant before each SetFpgaPage call)
python3 - <<'PY'
import re
d=open('re/1.05e-0731/kernel.gb','rb').read()
E={(0,0x1a7a),(1,0x47a7),(4,0x466e),(8,0x6e7a),(4,0x41e7)}
from collections import Counter; t=Counter()
for m in re.finditer(re.escape(bytes([0xcd,0x8d,0x07])),d):
    lo,hi,bk,_=d[m.start()+3:m.start()+7]
    if (bk,lo|hi<<8) in E and d[m.start()-4]==0x3e and d[m.start()-2:m.start()]==b'\xf5\x33': t[d[m.start()-3]]+=1
for bk,ad in E:
    for m in re.finditer(re.escape(bytes([0xcd,ad&0xff,ad>>8])),d):
        if (m.start()//0x4000==bk or bk==0) and d[m.start()-4]==0x3e and d[m.start()-2:m.start()]==b'\xf5\x33': t[d[m.start()-3]]+=1
print({f"${v:02x}":n for v,n in sorted(t.items())})
PY
```
