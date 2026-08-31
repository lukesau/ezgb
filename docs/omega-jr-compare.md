# EZ Flash Omega DE ↔ Jr comparison

Working notes for using Omega (published [`omega-de-kernel`](https://github.com/ez-flash/omega-de-kernel)
source + a real cart) to help map the Jr kernel. The menu UX on both is closely related;
how much is shared code vs shared product design is open. Expect some 1:1 features, not a
line-for-line port (different CPU, bus, and storage models).

Primary use while naming ASM: when a Jr routine's purpose is unclear, check whether
Omega has an obvious counterpart (file browser, settings, SD helpers, last-played, etc.) and
borrow naming/structure from the published C.

## Product goals (Jr)

| Priority | Work |
|---|---|
| **Now** | Name and document Jr ASM (`kernel.sym` / notes / traces) |
| **Later** | Build a **B-mode kernel**: a dedicated Jr firmware image that boots one chosen ROM without the file-browser OS |

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

- `NORflash_OP.c`: `Loadfile2NOR`, NOR file list / format
- `Ezcard_OP.c`: `SetRompage` / `SetRompageWithHardReset` (page select then hard/soft reset into game)
- `ezkernelnew.c`: browser; NOR list boot via `SetRompageWithHardReset(pNorFS[…].rompage, …)`
- `setwindow2.c`: Mode B rumble/RAM/link setting UI

## Jr constraint → B-mode kernel

The Jr has no physical A/B switch, and needs no Omega-style manual NOR burn to get an
authentic in-game experience. Stock launch already:

1. Reads the ROM from microSD
2. Programs it into the cart NOR/FPGA (so the GB bus sees a real cart image, not an emulated one)
3. Hands off via the WRAM stub culminating in **`$7fe0=$80`** (kernel ROM replaced; game runs)

That is why link-cable multiplayer works like original carts: after handoff, the FPGA presents
hardware-level cart behavior. Save-to-SD is a separate post-write flush (wait a beat after an
in-game save before yanking power or starting link), not evidence of emulation.

Omega Mode B exists because GBA Omega's authentic path is "cold-boot a NOR-resident image,
switch selecting NOR vs OS." On Jr that authenticity is the normal launch path already; Mode B
here means only skipping Mode A (the browser OS) so power-on goes straight into "load chosen
ROM → FPGA program → soft reset."

The Jr analogue is a separate kernel build (replace or dual-image `ezgb.dat`): minimal bring-up
→ resolve the chosen ROM → call the existing load/launch chain. No new authenticity layer;
reuse [`launch-trace.md`](launch-trace.md).

### Game staging and reuse

The launch programs the ROM into the **Spansion 71GL032A NOR** (U4, 4 MB), then
`$7fe0=$80` soft-resets and boots it. See [hardware-board.md](hardware-board.md).
That NOR is non-volatile, so the last game persists across power-off.

The stock kernel re-streams the ROM from SD and re-programs it on every launch. It
never checks whether the wanted game is already in NOR, so it never reuses NOR contents.
Cold boot reloads `ezgb.dat` because the factory bootstrap presents the kernel at
power-on, not the NOR game, independent of NOR persistence.

Whether the NOR game is usably readable back at runtime, and the exact U4/U9 partitioning,
is unconfirmed; confirming needs a chip dump or driving the FPGA NOR-read path.

Other battery-backed memory (lost only if the coin cell dies): **PSRAM** (U9) holds
saves and the `$A300` last-path; the **RTC** shares the same cell. See
[psram-save-map.md](psram-save-map.md), [last-rom.md](last-rom.md).

Implication for B-mode / no-splash shortcuts:

| Path | Skip browser? | Skip SD→NOR program? |
|---|---|---|
| Cold boot (power cycle) | Needs a B-mode kernel / bootstrap change | Only if the resident NOR game can be read back and mapped (unconfirmed) |
| Warm / in-place handoff after the load | Yes | Page/handoff only; map `RomLoad_*` and the `$7fe0` WRAM stub first |

The Jr's authentic-cart launch (SD → program NOR → soft handoff) is the normal path;
Omega reserves that for its NOR/Mode-B slot with a physical A/B switch.

Earlier experiments patched the stock kernel in place ("fast-launch"); that approach is
deferred. Salvageable plumbing is in [`fast-launch-notes.md`](fast-launch-notes.md) and
[`last-rom.md`](last-rom.md) (cart NVRAM `$A300` last-path). Prefer designing the B-mode
kernel once the load path and helpers are named from the full map.

## Already compared (hardware / structure)

| Area | Omega | Jr (1.05e) | Notes |
|---|---|---|---|
| FPGA unlock → command → latch | `SetSDControl` / friends in `Ezcard_OP.c` (`0x9fe0000` …) | `$7f00/$7f10/$7f20` unlock, command ports, `$7ff0` commit | Same design, different map; see [`REGISTERS.md`](REGISTERS.md) |
| SD sector I/O | `Read_SD_sectors` / `Write_SD_sectors` | `$7fb0`–`$7fb4` LBA + count family | Hypothesis aligned; confirm with traces |
| Bank / page select | `SetRompage`, `SetRampage`, … | `$7fc0`–`$7fc4` family | Naming candidates once call sites sorted |
| Filesystem | FatFs (`source/ff15`) | FatFs-like DIR objects in WRAM after `DirList` | UX + on-disk layout likely cousins |
| File browser / settings chrome | Large UI in `ezkernelnew.c`, `setwindow*.c`, `draw.c` | `SdMenuMain`, dir list, SET/HELP tabs | Strong UX resemblance; ASM still mostly unnamed |
| Direct game boot | NOR page + `SetRompageWithHardReset` (needed for Mode B authenticity) | SD → program FPGA → WRAM stub → `$7fe0=$80` soft handoff | **Jr already authentic at every launch**; Omega reserves that for NOR/Mode B |
| Last / recent ROM | (Omega has its own persist; confirm while mapping) | `$A300` full path + START overlay | Jr side fully traced; Omega counterpart TBD for naming |

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

1. Pick an app-focused unnamed Jr symbol (`./scripts/map-next.sh`, or `./scripts/doc-symbol-coverage.py --app`).
2. If it sits on a UI or SD path, reproduce the same action on Omega and skim the matching
   `.c` function.
3. Name the Jr label in `re/1.05e-0731/kernel.sym`, add a short note in `notes.json` if the Omega
   analogue is clear (cite Omega file/symbol).
4. Keep B-mode design notes out of the critical path until load + SD + boot helpers are named.

## Open questions

- How much Jr UI code is SDCC-shaped C parallel to Omega vs independently written for SM83?
- Does Jr persist anything equivalent to Omega’s NOR game list, or only the single `$A300` path?
  (Likely only `$A300`; Jr has no multi-slot NOR catalog to mirror.)
- Factory bootstrap vs `ezgb.dat`: closest Omega analogue for “which image runs at cold boot”
  when inventing a dual A/B kernel install story on Jr.
- Whether a B-mode Jr kernel should hardcode one path, read `$A300`, or read a small config
  file: decide after the loader helpers are mapped, not before.
- How much of the full OS kernel a B-mode image can strip (browser/UI) while still reaching
  the FPGA program + `$7fe0=$80` handoff cleanly.
- Whether any warm-reset path can soft-boot the already-resident NOR game without
  re-streaming from SD (depends on whether the NOR game is readable back at runtime;
  unconfirmed, see Game staging and reuse).
