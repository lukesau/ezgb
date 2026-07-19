# EZ Flash Omega DE ↔ Jr comparison

Working notes for using Omega (published [`omega-de-kernel`](https://github.com/ez-flash/omega-de-kernel)
source + a real cart) to help map the Jr kernel. The menu UX on both feels closely related;
how much of that is shared code shape vs shared product design is still an open question.
Expect a **non-zero** set of 1:1 features, not a line-for-line port (different CPU, bus, and
storage models).

Primary use of this doc while naming ASM: when a Jr routine's purpose is unclear, check whether
Omega has an obvious counterpart (file browser, settings, SD helpers, last-played, etc.) and
steal naming / structure from the published C.

## Product goals (Jr)

| Priority | Work |
|---|---|
| **Now** | Name and document Jr ASM (`kernel.sym` / notes / traces) |
| **Later** | Build a **B-mode kernel** — a dedicated Jr firmware image that boots one chosen ROM without the file-browser OS |

Omega DE Mode A/B is the UX target for that later work, adapted to Jr hardware constraints.

## Omega DE Mode A / Mode B

On Omega Definitive Edition, a physical switch on the cart selects boot path:

| Switch | Behavior |
|---|---|
| **Mode A** | Full EZ Flash OS (SD browser, settings, flash-to-NOR, …) |
| **Mode B** | Boots the game previously burned to internal **NOR** flash; cart behaves closer to a single authentic GBA cart (important for GBA↔DS link and some RTC titles) |

In Mode A, Settings also configure what Mode B **enables** for that direct-boot game
(`gl_ModeB_init` in `source/setwindow2.c` / `CheckSwitch` in `ezkernelnew.c`):

- `0` rumble
- `1` RAM expansion
- `2` link

Workflow to put a game on Mode B: Mode A → highlight ROM → **Flash to NOR** → power off →
flip switch to B → power on. Hold **R** on power-on to force the menu if the switch/NOR path
misbehaves (community troubleshooting note).

Relevant Omega source (under `tools/omega-de-kernel/source/`):

- `NORflash_OP.c` — `Loadfile2NOR`, NOR file list / format
- `Ezcard_OP.c` — `SetRompage` / `SetRompageWithHardReset` (page select then hard/soft reset into game)
- `ezkernelnew.c` — browser; NOR list boot via `SetRompageWithHardReset(pNorFS[…].rompage, …)`
- `setwindow2.c` — Mode B rumble/RAM/link setting UI

## Jr constraint → B-mode kernel

The Jr has **no physical A/B switch**, but it also **does not need an Omega-style NOR burn**
to get an authentic in-game experience. Stock launch already:

1. Reads the ROM from microSD
2. Programs it into the cart FPGA (so the GB bus sees a real cart image, not an emulated one)
3. Soft-resets / hands off via the WRAM stub culminating in **`$7fe0=$80`** (kernel ROM
   replaced; game runs)

That is why link cable multiplayer works like original carts: after handoff, the FPGA is
presenting hardware-level cart behavior. Save-to-SD is a separate post-write flush (wait a
beat after in-game save before yanking power or starting link) — not evidence of emulation.

Omega Mode B exists because GBA Omega’s authentic path is “cold-boot a NOR-resident image
with the switch selecting NOR vs OS.” On Jr, that authenticity is already the **normal**
launch path. Mode B for us is only about **skipping Mode A (the browser OS)** so power-on
goes straight into “load chosen ROM → FPGA program → soft reset.”

So the Jr analogue is a **separate kernel build** (replace or dual-image `ezgb.dat`) whose
job is: minimal bring-up → resolve the chosen ROM → call the existing load/launch chain.
No NOR mirror, no new authenticity layer — reuse [`launch-trace.md`](launch-trace.md).

### Volatility (why cold boot still reloads)

The staged game image is almost certainly **volatile RAM** behind the FPGA (SRAM/PSRAM-class
—“FPGA buffer” in our notes; Omega’s analogue for SD launches is `Loadfile2PSRAM`), not a
NOR game slot. Cart memory that *does* keep state across power-off:

- **FRAM** — saves and meta such as `$A300` last-path; non-volatile, **no battery**
- **RTC** — the only **battery-backed** part of the Jr

Evidence the big game image does not persist across power-off:

- Every menu launch re-streams the ROM from SD before `$7fe0=$80`
- Cold boot always reloads `ezgb.dat` from SD (factory bootstrap), same class of “buffer is
  session storage”

Implication for B-mode shortcuts:

| Path | Skip browser? | Skip SD→FPGA program? |
|---|---|---|
| Cold boot (power cycle) | Yes (B-mode kernel) | **No** — buffer was lost; still need load (can still omit UI/dir enum) |
| Warm / soft path while image still resident | Yes | **Maybe** — page/handoff only; unproven, map `RomLoad_*` first |

Omega Mode B’s “already flashed, just boot” cold path has no Jr free lunch without inventing
persistent game storage the cart does not expose like Omega NOR.

Earlier experiments patched the stock kernel in place (“fast-launch”); that approach is
**deferred**. Salvageable plumbing is recorded in [`fast-launch-notes.md`](fast-launch-notes.md)
and [`last-rom.md`](last-rom.md) (especially cart NVRAM `$A300` last-path). Prefer designing
the B-mode kernel once the load path and related helpers are named from the full map.

## Already compared (hardware / structure)

| Area | Omega | Jr (1.05e) | Notes |
|---|---|---|---|
| FPGA unlock → command → latch | `SetSDControl` / friends in `Ezcard_OP.c` (`0x9fe0000` …) | `$7f00/$7f10/$7f20` unlock, command ports, `$7ff0` commit | Same design, different map — [`REGISTERS.md`](REGISTERS.md) |
| SD sector I/O | `Read_SD_sectors` / `Write_SD_sectors` | `$7fb0`–`$7fb4` LBA + count family | Hypothesis aligned; confirm with traces |
| Bank / page select | `SetRompage`, `SetRampage`, … | `$7fc0`–`$7fc4` family | Naming candidates once call sites sorted |
| Filesystem | FatFs (`source/ff15`) | FatFs-like DIR objects in WRAM after `DirList` | UX + on-disk layout likely cousins |
| File browser / settings chrome | Large UI in `ezkernelnew.c`, `setwindow*.c`, `draw.c` | `SdMenuMain`, dir list, SET/HELP tabs | Strong UX resemblance; ASM still mostly unnamed |
| Direct game boot | NOR page + `SetRompageWithHardReset` (needed for Mode B authenticity) | SD → program FPGA → WRAM stub → `$7fe0=$80` soft handoff | **Jr already authentic at every launch**; Omega reserves that for NOR/Mode B |
| Last / recent ROM | (Omega has its own persist — confirm while mapping) | `$A300` full path + START overlay | Jr side fully traced; Omega counterpart TBD for naming |

## Suspected UX 1:1 (to verify while mapping)

Use the real Omega OS side-by-side with the Jr menu. When behavior matches, hunt the Jr
routine and name it after the Omega C symbol (or a Jr-appropriate variant).

Candidates (not yet proven identical under the hood):

- SD browser: list, folders, hide system files, A to launch, B back
- Launch options sheet / “flash or boot” style menus (Jr may collapse some of these)
- Settings pages (LED, saver, language, …)
- Backup / saver prompts
- Error / “Reading…” / “Loading…” modal boxes (Jr: `DrawReadingBox`, `DrawLoadingBox`, …)
- Cheats / patches / RTC toggles where both products expose them

Add rows here as each is confirmed or rejected.

## Mapping workflow suggestion

1. Pick a high-fan-in unnamed Jr symbol (`./scripts/doc-symbol-coverage.py`).
2. If it sits on a UI or SD path, reproduce the same action on Omega and skim the matching
   `.c` function.
3. Name the Jr label in `re/1.05e/kernel.sym`, add a short note in `notes.json` if the Omega
   analogue is clear (cite Omega file/symbol).
4. Keep B-mode design notes out of the critical path until load + SD + boot helpers are named.

## Open questions

- How much Jr UI code is SDCC-shaped C parallel to Omega vs independently written for SM83?
- Does Jr persist anything equivalent to Omega’s NOR game list, or only the single `$A300` path?
  (Likely only `$A300` — Jr has no multi-slot NOR catalog to mirror.)
- Factory bootstrap vs `ezgb.dat`: closest Omega analogue for “which image runs at cold boot”
  when inventing a dual A/B kernel install story on Jr.
- Whether a B-mode Jr kernel should hardcode one path, read `$A300`, or read a small config
  file — decide after the loader helpers are mapped, not before.
- How much of the full OS kernel a B-mode image can strip (browser/UI) while still reaching
  the FPGA program + `$7fe0=$80` handoff cleanly.
- Whether any warm-reset path can soft-boot an already-resident FPGA buffer without
  re-streaming from SD (cold boot cannot, if the buffer is volatile RAM).
