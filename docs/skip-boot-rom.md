# Skip boot ROM: jump to the game instead of resetting

Issue [#8](https://github.com/lukesau/ezgb/issues/8). Every launch used to
end with `$7FE0=$80`, which resets the console into the loaded game, so the
boot ROM ran a second time (logo and all, about 2-3 s). When it's safe, the
launch now jumps to the game's `$0100` instead. Otherwise it resets as before.

Verified in SameBoy on all three kernels, and working on the FW5 and FW4 carts (2026-11-03, below).

## When it jumps

The boot ROM chooses CGB mode or DMG compatibility mode once, at power-on,
from the header it sees. On the Jr that header is stage1's, and the choice is
locked once the boot ROM unmaps itself. DMG games can't run in CGB mode
either, because CGB mode ignores `BGP`/`OBP0`/`OBP1`. So the jump only
works when the console is already in the mode the game needs:

| Console | Kernel runs in | Game | Launch |
|---|---|---|---|
| GBC, GBA, mod stage1 (CGB flag set) | CGB mode | `$0143` bit 7 set, bits 2-3 clear | **jump** |
| GBC, GBA, mod stage1 | CGB mode | DMG only, or PGB bits set | reset |
| GBC, GBA, stock stage1 | DMG compatibility | any | reset |
| DMG, DMG0, Pocket, stock stage1, `SGB BOOT` off | DMG | `$0143` bit 7 clear | **jump** |
| DMG, DMG0, Pocket, mod stage1 | DMG | `$0143` bit 7 clear | **jump** |
| DMG, DMG0, Pocket | DMG | `$0143` bit 7 set | reset |
| SGB, SGB2, mod stage1 | DMG | any | reset |
| Anything DMG-family, stock stage1, `SGB BOOT` ticked | DMG | any | reset |
| DMG family, mod stage1 from before the register record | DMG | any | reset |

The kernel tells the DMG family from a GBC or GBA by reading `VBK`: `$FF` on
the DMG family, the written value on color consoles in either mode.

### Boot registers

Each jump pops AF, BC, DE and HL from `BOOT_REGS` (WRAM `$DC00`), which the
kernel fills at boot (`stage1_skip_mark`, [ezcfg.c](../kernel/src/ezcfg.c)):

- **Mod stage1.** Stage1 pushes the boot ROM's registers to `$FF80`-`$FF87` as
  its first instructions ([crt0.s](../stage1/src/crt0.s)) and copies them to
  pSRAM page `$11` `$A428`-`$A42F`, in pop order, `F A C B E D L H`. So every
  model gets what its boot ROM left: `A = $FF` on a Pocket, `B = $01` on a GBA,
  and the DMG0 values. `C = $14` shows an SGB, and sets `NO_DMG` (`$DC08`)
  so it resets, since the SNES enables SGB features from the game's header. The
  `SGB BOOT` record means nothing here, so one left ticked doesn't stop a jump.
- **Stock stage1.** It wipes the registers (`A` is `$E4` on every console at
  kernel entry), so the DMG boot ROM's values go in, and the DMG models can't
  be told apart: a DMG0's `F`, `BC`, `DE` and `HL` differ, and a Pocket gets
  `A = $01` instead of `$FF`. An SGB looks like a DMG too, so `SGB BOOT` ticked
  stands in for it, since the Jr needs that setting to run on an SGB here.
- **Mod stage1 from before the record.** The kernel sees the `"SB"`/`"SN"` mark
  but no plausible `A` (`$01`, `$11` or `$FF`). It can't rule out an SGB, so the
  DMG family resets (`NO_DMG`), and CGB mode gets the CGB boot ROM's values, so
  a GBA gets `B = 0`. The kernel zeroes `A` in the record each boot, so one left
  behind can't outlive a switch of stage1.

The flags in F come from stage1's header checksum, not the game's, which only
matters to a game with a header checksum of 0 on a DMG.

Non-color games on a GBC or GBA with stock stage1 still reset, because a jump
would lose the boot ROM's colorization. It picks the palette from stage1's
header at power-on, and palette RAM ignores writes in compatibility mode.

Turning it off: untick `SKIP BOOT ROM:` on the SET tab's second page
(`BOOTROM=1` in `/EZGB.CFG`). Every launch then resets, for
anyone who needs the boot ROM's exact timing (`DIV`, which some games use
for random numbers).

## How

Every launch (browser, START overlay, fast launch) ends in
`RomLoad_BuildAndRunPoll` (`04:40e7`), which copies the launch stub
`RomLoad_InitiatePoll` to `$D100` and calls it. The stub starts the load,
polls it, switches the cart to the game (`$7F31/$7F32 = 0`), writes
`$2000 = 1` and `$3000 = 0`, sends the unlock (`$E1`-`$E3`) and then resets
(`RomLoad_SoftReset`, `$D19C` in the copy). Interrupts are already off.

| Site | What |
|---|---|
| `04:40f8` | `call $d100` -> `call SkipBootPrep` |
| `04:6be6` `SkipBootPrep` | 273 B of 299 (`ManageSaves` is at `04:6d11`), [skip_boot.asm](../scripts/skipboot/skip_boot.asm). Unless `BOOTROM=1` is set, reads the `SGB BOOT` record (`RecFlag`) under stock stage1, copies `SkipBoot` to `$D1B0` (the stub ends at `$D1AA`), stores `NO_DMG` or the record in its `NoDmgJump` byte and patches the copy's `ld bc, $7fe0` at `$D19C` into `jp $d1b0`, then `jp $d100` |
| `$D1B0` `SkipBoot` (WRAM) | Runs after the cart has switched, so it reads the game's header and can't call anything in cart space |

`SkipBoot`:

1. Reads the game's `$0143` and `VBK`, and resets unless one of these holds:
   the replaced `ld bc, $7fe0`, then back into the stub.
   - Color console (`VBK` bit 0 reads 0), bit 7 set and bits 2-3 clear.
   - DMG family (`VBK` reads `$FF`), bit 7 clear and `NoDmgJump` 0.
2. `di`, then turns the LCD off in VBlank.
3. **CGB mode test, color consoles only.** It writes `$5A` and then `$A5` to palette RAM (`BCPS = 0`)
   and reads each back. In compatibility mode palette RAM ignores writes; on a
   DMG it reads `$FF`. Either one resets. `VBK` can't be used for this test
   because it reads back in compatibility mode
   ([cgb-mode.md](cgb-mode.md)).
4. Finishes the unlock with a write that changes nothing (`$7F32 = 0`) and the
   lock (`$7FF0 = $E4`). It then writes `$0000`, `$4000` and `$6000` to 0. The
   unlock went to the game's MBC too (`$7F00` is in MBC1's mode register range).
5. Puts back what the boot ROM leaves and the kernel changed:
   - VRAM banks 1 and 0 and OAM cleared, `VBK = 0`.
   - BG and OBJ palettes white (these writes and `VBK` do nothing on the DMG family, so it shares this code).
   - `P1`, `SB`, `SC`, the timer, `STAT`, scroll, `LYC`, window, `RP`, `SVBK` and `IE` set to 0.
   - Sound on (`NR52 = $80`, `NR50 = $77`, `NR51 = $F3`) and `BGP = $FC`.
6. `LCDC = $91`, `IF = 0`, then waits for LY 144. The jump comes at the start
   of VBlank with VBlank's `IF` bit set by the hardware, as after the boot
   ROM.
7. Pops AF, BC, DE and HL from `BOOT_REGS` ([Boot registers](#boot-registers)),
   sets SP = `$FFFE` and jumps to `$0100`.

`DIV` and the exact LY don't match the boot ROM. `DMA` is never written,
because writing it starts a transfer. On the DMG family VRAM is cleared where
the boot ROM would leave the logo, and `NR52` reads `$F0` plus any channel the
game starts, not `$F1`.

### `BOOTROM=` and `BOOT_RESET`

`BOOT_RESET` is WRAM `$DBEB` ([vars.h](../kernel/src/vars.h)). EzCfg had 11 B
left, so it only gains the key's table entry. Keys 8 (`COLORS=`) and 9
(`BOOTROM=`) both go through the switch's `default` to `FarCallColors` with
the key index as the op, and `ThemeColors` (`05:7b50`, now 335 B) handles them:

- op 8 parses `COLORS=`.
- op 9 sets `BOOT_RESET` for a value of `1` and clears it otherwise.
- op 1 (the save) writes `BOOTROM=1` ahead of the theme lines.


## Emulator support

The SameBoy stub used to swap in the loaded ROM only on `$7FE0`. The FPGA
switches on `$7F32` bit 7 ([design.md](../re/stage0/docs/design.md), Game
launch), so the stub now does too. It loads the game when the kernel clears
the bit, and a later `$7FE0 = $80` resets into it
(`boot_no_reset` / `reset_armed` in `ezflash_jr.c`).

## Verification (SameBoy, 2026-10-30)

These were fast launches of Pokemon Crystal (`$0143 = $C0`) and Pokemon Red
(`$00`), on 1.05e-0731, 1.05e-0918 and 1.04e:

- **Crystal, `--model cgb`:** jumps. At `jp $0100` the registers are
  AF = `$1180`, BC = 0, DE = `$FF56`, HL = `$000D`, SP = `$FFFE`, with
  LCDC `$91`, LY `$90`, `IF = $E1` and `IE = 0`. The intro runs in color, a
  boot ROM's length ahead of the reset run.
- **Red, `--model cgb`:** resets, and the boot ROM gives it its red
  colorization.
- **Crystal, `--model dmg`:** resets to its "Game Boy Color only" screen.
- **Crystal on a kernel copy with `$0143 = $00` (compatibility mode):** the
  palette test fails, and it resets into CGB mode.
- **`BOOTROM=1`:** Crystal resets. The key survives the kernel's rewrite of
  `EZGB.CFG`.

## Verification, DMG path (SameBoy, 2026-11-04)

Fast launches with `--model dmg` unless noted, on a scratch card:

| Case | Kernels | Result |
|---|---|---|
| Red (`$0143 = $00`) | 0731, 0918, 1.04e | jumps, AF = `$01B0`, BC = `$0013`, DE = `$00D8`, HL = `$014D`, SP = `$FFFE`, LCDC `$91`, LY `$90`. On 0731 the game's intro runs |
| Crystal (`$0143 = $C0`) | 0731, 1.04e | resets |
| Red, `SGB BOOT` record set | 0731 | resets |
| Red, stage1's `"SN"` mark set | 0731 | resets |
| Red, `BOOTROM=1` | 0731 | resets without entering `SkipBoot` |
| Crystal, `--model cgb` | 0731, 0918 | jumps with the CGB registers |
| Red, `--model cgb` | 0731 | resets |
| Red and Crystal, `--model cgb` on a copy with `$0143 = $00` (stands in for stock stage1 on a GBC) | 0731 | resets |

Not tested: any real DMG-family console, stock stage1 running through to the
kernel (SameBoy stops at OSINIT), and a real SGB.

## Verification, register record (SameBoy, 2026-11-04)

Our stage1 run through to the kernel on each model, then `psram.bin` read. The
kernel had zeroed `A`, and consumed the mark; the other seven bytes:

| Model | F | B | C | D | E | H | L |
|---|---|---|---|---|---|---|---|
| `dmg` | `$B0` | 0 | `$13` | 0 | `$D8` | `$01` | `$4D` |
| `mgb` | `$B0` | 0 | `$13` | 0 | `$D8` | `$01` | `$4D` |
| `sgb` | 0 | 0 | `$14` | 0 | 0 | `$C0` | `$60` |
| `cgb` | `$80` | 0 | 0 | `$FF` | `$56` | 0 | `$0D` |
| `agb` | 0 | `$01` | 0 | `$FF` | `$56` | 0 | `$0D` |

Launches with the record seeded in pSRAM, at `jp $0100`:

| Case | Result |
|---|---|
| DMG0 values, Red | jumps, AF = `$0100`, BC = `$FF13`, DE = `$00C1`, HL = `$8403` (0731, 1.04e) |
| Pocket values, Red | jumps, AF = `$FFB0` |
| GBA values, Crystal, `--model cgb` | jumps, AF = `$1100`, BC = `$0100` |
| GBC values, Crystal, `--model cgb` | jumps, AF = `$1180` (0918) |
| GBC values, Red, `--model cgb` | resets |
| SGB values, Red | resets |
| DMG values, Crystal | resets |
| DMG values, `SGB BOOT` record left set, Red | jumps |
| Mark only, no record, Red, `--model dmg` | resets |
| Mark only, no record, Crystal, `--model cgb` | jumps with the CGB values |
| No mark, Red, `--model dmg` | jumps with the DMG values (0731, 1.04e); resets with the `SGB BOOT` record set (0731) |

The pSRAM check doesn't cover a launch through real stage1 end to end. On
hardware the record has been read but no launch has used it yet (below).

## Hardware (mod 7.2, 2026-11-03)

- **FW5 and FW4 carts:** Pokemon Crystal works. These runs had no timing
  measurements, and the console used wasn't recorded.
- **`.gb` games:** they still reset. A color-patched Gen 1 Pokemon ROM with a
  `.gb` extension was treated as a color game, because the check reads
  `$0143` and not the file name.
- **Open, FW4:** there is a blank screen for a few seconds before the game
  appears, longer than on FW5. FW4 has no fast-load path (`$7FD3`/`$7FD4`), so
  its load is slower, but the launch doesn't turn the LCD off until the load
  is done, so that doesn't yet explain a blank screen. Comparing against a
  `BOOTROM=1` launch of the same game on that cart would show if the jump is
  involved.

## Hardware, register record (2026-11-04)

The debug screen read the record correctly on a GBA SP (`AF:1100 BC:0100`) and
a GBC (`AF:1180 BC:0000`), both `DE:FF56 HL:000D`, as in SameBoy
([debug-tab.md](debug-tab.md#findings-boot-registers-2026-11-04)).

Still owed: a color game launched with these registers (a game that checks
B = 1 on the GBA), the DMG path and SGB reset on real consoles, a Pocket's
values, stock stage1 on hardware (it should reset every color game), and
Crystal's clock and saves checked across a power cycle.
