# Skip boot ROM: jump to color games instead of resetting

Issue [#8](https://github.com/lukesau/ezgb/issues/8). Every launch used to
end with `$7FE0=$80`, which resets the console into the loaded game, so the
boot ROM ran a second time (logo and all, about 2-3 s). When it's safe, the
launch now jumps to the game's `$0100` instead. Otherwise it resets as before.

Emulator-verified (SameBoy, all three kernels). **Not yet tested on hardware.**

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
| DMG, Pocket, SGB | DMG | any | reset |

This first pass covers only the CGB case. DMG and Pocket could jump for
every game too, but that needs stage1 to pass the boot registers to the
kernel (A tells DMG from Pocket, and B tells GBA from GBC). The same record
would give a GBA its own B. For now a GBA gets B = 0, the GBC value.

Turning it off: `BOOTROM=1` in `/EZGB.CFG` resets on every launch, for
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
| `04:6be6` `SkipBootPrep` | 225 B, [skip_boot.asm](../scripts/skipboot/skip_boot.asm). Unless `BOOTROM=1` is set, copies `SkipBoot` to `$D1B0` (the stub ends at `$D1AA`) and patches the copy's `ld bc, $7fe0` at `$D19C` into `jp $d1b0`, then `jp $d100` |
| `$D1B0` `SkipBoot` (WRAM) | Runs after the cart has switched, so it reads the game's header and can't call anything in cart space |

`SkipBoot`:

1. Reads the game's `$0143`. Unless bit 7 is set and bits 2-3 are clear,
   it resets: the replaced `ld bc, $7fe0`, then back into the stub.
2. `di`, then turns the LCD off in VBlank.
3. **CGB mode test.** It writes `$5A` and then `$A5` to palette RAM (`BCPS = 0`)
   and reads each back. In compatibility mode palette RAM ignores writes; on a
   DMG it reads `$FF`. Either one resets. `VBK` can't be used for this test
   because it reads back in compatibility mode
   ([cgb-mode.md](cgb-mode.md)).
4. Finishes the unlock with a write that changes nothing (`$7F32 = 0`) and the
   lock (`$7FF0 = $E4`). It then writes `$0000`, `$4000` and `$6000` to 0. The
   unlock went to the game's MBC too (`$7F00` is in MBC1's mode register range).
5. Puts back what the boot ROM leaves and the kernel changed:
   - VRAM banks 1 and 0 and OAM cleared, `VBK = 0`.
   - BG and OBJ palettes white.
   - `P1`, `SB`, `SC`, the timer, `STAT`, scroll, `LYC`, window, `RP`, `SVBK` and `IE` set to 0.
   - Sound on (`NR52 = $80`, `NR50 = $77`, `NR51 = $F3`) and `BGP = $FC`.
6. `LCDC = $91`, `IF = 0`, then waits for LY 144. The jump comes at the start
   of VBlank with VBlank's `IF` bit set by the hardware, as after the boot
   ROM.
7. Loads the CGB boot ROM's registers: AF = `$1180` (popped from `$FFFC`),
   BC = 0, DE = `$FF56`, HL = `$000D`, SP = `$FFFE`. Then it jumps to `$0100`.

`DIV` and the exact LY don't match the boot ROM. `DMA` is never written,
because writing it starts a transfer.

### `BOOTROM=` and `BOOT_RESET`

`BOOT_RESET` is WRAM `$DBEB` ([vars.h](../kernel/src/vars.h)). EzCfg had 11 B
left, so it only gains the key's table entry. Keys 8 (`COLORS=`) and 9
(`BOOTROM=`) both go through the switch's `default` to `FarCallColors` with
the key index as the op, and `ThemeColors` (`05:7b50`, now 335 B) handles them:

- op 8 parses `COLORS=`.
- op 9 sets `BOOT_RESET` for a value of `1` and clears it otherwise.
- op 1 (the save) writes `BOOTROM=1` ahead of the theme lines.

EzCfg is 4949 B, 3 B short of `LastRomName` (`02:5d58`).

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

Still owed: a hardware test on a GBC or GBA with the mod stage1, and the
same on stock stage1 (it should reset every time).
