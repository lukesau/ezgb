# What a launched ROM can reach (game-slot hardware access)

> **WARNING — this line of investigation bricked a cart.**
>
> The probes below issue the *firmware updater's* FPGA commands
> (`$7F31/$7F32 = $8000`, `$7F36 = $03`, `$7FD2 = $01`) on live hardware. On
> 2026-08-16 a probe run left an EZ Flash Jr unable to configure its FPGA: the
> cart drives nothing onto the bus at power-on, so the console's boot ROM reads
> garbage where the Nintendo logo should be and halts with a blacked-out logo,
> on every console tried.
>
> The most likely cause is that the probe **initiated a config-flash operation
> and aborted it**. `$7FD2 = $01` is a trigger; the kernel's own routine
> (`Fpga7FD2WaitClear_B8`) writes `$01`, then **polls `$A000` until it reads
> zero**, and only then writes `$00`. The probe sampled once and immediately
> wrote `$00`, cutting the operation off mid-flight.
>
> **Writing to `$7Fxx` is not a read-only experiment.** These are command
> registers on a device whose configuration lives in rewritable flash. An
> earlier claim in this repo that "everything we're touching is `ezgb.dat`, a
> file on the SD card, so there is no brick risk" was true only until the first
> probe wrote to `$7Fxx`, and was not corrected at the time.
>
> If you repeat any of this: replicate the **whole** protocol including its
> handshakes, or do not issue the write at all. Prefer reads. And dump the
> `25Q40H` config flash of every cart you own *before* touching `$7Fxx`, so a
> restore image exists.

When the kernel launches a ROM, the FPGA programs it into the game slot and
resets the console into it (`$7FE0=$80`). A ROM running there is **not** in the
same environment the factory bootstrap gives the kernel. This page records what
was measured about the difference, because it decides whether the kernel can
ever run as a launched ROM — the "chain-boot" idea from `cgb-mode.md`.

## Why it mattered

CGB mode is unreachable at first boot (`cgb-mode.md`): the bootstrap's header
decides DMG-vs-CGB before our code exists. But the flag *is* honoured on a game
launch. So chain-booting a CGB-flagged kernel — ideally the kernel rebooting
itself automatically — was the only route to CGB mode without FPGA work. It
only works if the kernel can still reach the SD card and FRAM from the game
slot. It hangs with BATTERY DRY and "Micro SD initial error!" instead.

## Method

`decomp/src/chainboot_probe.c`, injected into a copy of the kernel and hooked
over three candidate stopping points, each tagged so the output identifies
which one executed:

| Tag | Site | Instruction replaced |
|---|---|---|
| `B` | `$18e2` | `jp $18d7`, the `BatteryCheck_waitA` back-edge |
| `S` | `$0e21` | `jp $0e21`, `SdMenuMain_initErrorHang` |
| `F` | `$0998` | `jp $0998`, `SdReadRetryCount_errorHang` |

All three are bare 3-byte self-loops with nothing to preserve, reached *after*
the kernel has drawn text, so rendering is known-good.

**Print before each step, not after** — the last visible line is then whatever
killed it. Two earlier versions printed nothing at all and were misread as
"probe crashed"; they had simply hooked a site the hardware never reached.
A liveness marker before touching any hardware is what made that diagnosable.

## Results

`RAW0` = raw read of `$A000`; `REN0`/`REN1` = after `$0A` to `$0000`/`$1000`
(MBC cart-RAM enable); `UNLK` = after the unlock triple + commit; `PERS` = after
`$7FC0=$03`; `PAGE` = `$A201` after `$4000=$11`; `WRRD` = write `$5A` to
`$A100`, read back.

| | MBC1, no RAM enable | MBC1 + RAM enable | MBC5 + RAM enable |
|---|---|---|---|
| header `$0147`/`$0149` | `$01` / `$00` | `$01` / `$00` | `$1B` / `$03` |
| `RAW0` | `46` | `46` | `46` |
| `REN0` / `REN1` | — | `39` | `FF` |
| `UNLK` | `46` | `39` | `FF` |
| `PERS` | `46` | `39` | `FF` |
| `PAGE` | `46` | `00` | `FF` |
| `WRRD` | `46` | **`5A`** | **`5A`** |

## Established

**`$46` is not data, it is open bus.** The read compiles to `ld hl,$a000` /
`ld b,(hl)`, and `ld b,(hl)` *is* opcode `$46` — the floating data bus handing
back the last byte the CPU drove. Every `46` above means "nothing responded".

**The `$A000-$BFFF` window is live and writable from the game slot**, but only
after the standard MBC cart-RAM enable (`$0A` → `$0000-$1FFF`). `WRRD=5A` is a
genuine write-then-read round trip under both MBC1 and MBC5.

**The kernel never performs that enable write.** In OS mode the bootstrap hands
it an already-open window, so the kernel has no reason to. This is a real
missing ingredient for any chain-boot attempt, though not by itself sufficient.

**Header cart-type/RAM-size/ROM-size changes do not restore the EZ interface.**
Tried MBC1 no-RAM, MBC1+RAM, MBC5+RAM, and (in `cgb-mode.md`) MBC1+RAM with
corrected ROM size.

## Not established — and why the last run proves less than it looks

Whether the **EZ paged control interface** (unlock → `$7FC0` personality →
`$4000` page latch → `$A000` window) is reachable from the game slot is still
open.

The detector was insensitive. Change was measured by reading `$A000`, but under
MBC5 every region read `$FF`. If the personality switch *had* worked and
remapped `$A000` to the SD data window, an idle SD window would also read `$FF`.
So "no change" cannot distinguish "ignored" from "worked, also blank."

A sensitive version exists and has not been run: write a known pattern to
`$A000`, *then* unlock and switch personality, then read back. If the window was
remapped the pattern vanishes; if the writes were ignored it survives. That
discriminates even when every region is blank.

## Corrections to earlier claims in this repo

- "The FPGA does not expose cart RAM to a launched ROM" — **wrong**. It does,
  behind the MBC RAM-enable gate.
- "`$7F00-$7FFF` returns ROM in game mode, so the control window cannot exist
  there" — **unsupported**. Writes to ROM space always reach cart hardware
  (that is how every MBC works), and the probe's `$7Fxx` and `$4000` writes were
  inert rather than destructive: nothing crashed.
- An earlier fear that MBC1 would remap code out from under the program counter
  did not occur.

## The unread evidence

`Update_FW5_7-31.gb` runs as an **ordinary launched game** — the kernel contains
no `UPDATE` string and special-cases nothing — and drives the same registers:
seven unlock triples, seven `$7FF0` commits, plus `$7FC0`, `$7FD2`,
`$7F31`/`$7F32`, `$7F36`, `$7F37`, and eleven `$A000` pointer loads.

So a launched ROM demonstrably *can* reach this hardware. Every hypothesis about
*how* has so far been guesswork that explained one result and failed the next.
The updater is the only known-working example, its GB-side program is small
(bank 1 is 97.6% `$FF`; the payload starts at `$8020`), and reading it costs no
hardware cycles. **Start there, not with more probe builds.**
