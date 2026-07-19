# Kernel boot map (1.05e)

We **do** know the entry point. This is the menu kernel after the factory
bootstrap has already loaded `ezgb.dat` (SameBoy skips that and jumps here).

## Entry

| Vector | Bytes | Meaning |
|---|---|---|
| `$0100` `Boot::` | `nop` / `jp $0150` | Standard GB cart entry after boot ROM |
| `$0150` `Jump_000_0150` | — | Real C / runtime start |

Title in header: `EZGB`.

## Synchronous chain (`$0150` → … → halt)

```text
Jump_000_0150
  di
  clear WRAM ($C000–$DFFF style wipe), OAM mirror area, HRAM
  SP = $E000
  save boot A → $D6C9; bank latch $D6CF / $2000 = 1
  Call_000_069f          ; wait LY + turn LCD off
  zero scroll/STAT/WY; WX=$07
  copy 10 bytes $06B6 → HRAM $FF80   ; OAM DMA stub
  Call_000_062e($0677)   ; install interrupt callback slot
  Call_000_0640($06C0)   ; install another slot
  palettes, LCDC=$C0, IE=$09 (VBlank+…), sound off
  call $68B6             ; bank 1: clear some WRAM / setup (near Jump_001_6891)
  Call_000_1835          ; battery, then SD/menu
    …
    Call_000_0de4          ; SD init + BACKUPSAVE + **file browser (does not return)**
      Micro SD OK / error
      optional BACKUPSAVE
      dir enum / UI → loops via Jump_000_0f8d / jp $1062
      ; trailing `add sp,$17 / ret` in the listing is not the live menu path
  jr_000_01df:             ; halt loop — only if 1835/0de4 ever returned (they don’t in normal use)
    halt
    jr jr_000_01df
```

Foreground boot **enters `Call_000_0de4` and stays there** for the browser. The `$01DF` halt after `call $1835` is real bytes but a **dead exit** for the usual “boot to menu” path.

## Milestone labels we already care about

| Step | Addr / symbol | Notes |
|---|---|---|
| LCD off | `Call_000_069f` | Small, hardware wait — possible leaf later |
| Battery | `Call_000_1835` | Soft-path we stub `$A201=$88` for |
| SD + saver + FS | `Call_000_0de4` | Large; not a verify leaf yet (many callees) |
| Dir list | `Call_000_0a43` | Hides `ezgb.dat` via `$09af` |
| Idle / menu | inside `Call_000_0de4` (`$0F8D` / `$1062` area) | Browser loop — **does not return** to `$01DF` |
| START overlay (last ROM) | `Jump_000_1294` → `$129e` | Last-launched ROM persisted at cart `$A300`; see `docs/last-rom.md` |
| `$01DF` halt | after `call $1835` | Present in ROM but **not hit** on normal boot→menu |

## Emulator vs cart

| Layer | Physical Jr | SameBoy today |
|---|---|---|
| Factory bootstrap | `LOADING…` / `ezgb.dat not found` | **Skipped** — ROM load = kernel |
| This map (`$0100`+) | Runs after `ezgb.dat` load | Runs immediately |

## Decomp outlook

- **Good for mapping / notes** (this file): done enough to navigate.
- **Bad as one verify target:** `$0150` and `Call_000_0de4` call many unknowns; need
  callee pins or more matched leaves before byte-identical `main`.
- **Next matchable bites on this path:** leaves *inside* `0de4` once listed (callee
  pins via `verify.py --pin` / `--pins` are available now).
  Boot IRQ/setup helpers `$062e`–`$06c0` are fully matched.
- Naming/mapping the wider ASM (and Omega comparisons) outranks growing `decomp/` for now;
  see [`omega-jr-compare.md`](omega-jr-compare.md).

## Open questions

- Exact function of `$68B6` / installed VBlank handlers (menu frame).
- Where “Loading…” / file browser paint is kicked from interrupt vs leftover state
  after `0de4` returns.
- 1.04e address shift for the same chain (expect same shape, moved).
