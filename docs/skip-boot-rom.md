# Skipping the boot ROM

Stock ends every launch with `$7FE0 = $80`, which resets the console into
the loaded game, so the boot ROM runs a second time, logo and all, for two
or three seconds. When it is safe, the mod jumps to the game's `$0100`
instead ([issue #8](https://github.com/lukesau/ezgb/issues/8)). Addresses
are 1.05e-0731's.

It works on FW4 and FW5 carts, on color consoles and on an original Game
Boy.

## When it jumps

The boot ROM chooses CGB mode or DMG compatibility mode once, at power-on,
from the header it sees. On the Jr that header is stage1's, and the choice
is locked once the boot ROM unmaps itself. So a jump only works when the
console is already in the mode the game needs:

| Console | Kernel runs in | Game | Launch |
|---|---|---|---|
| GBC, GBA, our stage1 | CGB mode | `$0143` bit 7 set, bits 2-3 clear | **jump** |
| GBC, GBA, our stage1 | CGB mode | DMG only, or bits 2-3 set | reset |
| GBC, GBA, stock stage1 | DMG compatibility | any | reset |
| DMG, Pocket, stock stage1, `SGB BOOT` off | DMG | any | **jump** |
| DMG, Pocket, our stage1 | DMG | any | **jump** |
| SGB, our stage1 | DMG | any | reset |
| the DMG family, stock stage1, `SGB BOOT` ticked | DMG | any | reset |

The choice is made at each launch, by the same code under either stage1.
The DMG family needs no check of the game, because a DMG has one mode and
ignores the CGB flag.

A non-color game on a GBC or GBA always resets: a jump would lose the boot
ROM's colorization, and a DMG game cannot run in CGB mode, which ignores
`BGP`.

**Turning it off.** Untick `SKIP BOOT ROM:` on the SET tab's second page,
`BOOTROM=1` in `EZGB.CFG`. Every launch then resets, for anyone who needs
the boot ROM's exact timing. On a console that cannot jump the row is gray
and the cursor passes over it; `BOOTROM=` keeps its value there.

## Telling the console

The kernel separates the DMG family from a color console by stage1's record
when there is one (an `A` other than `$11`), else by `VBK`, which reads
`$FF` on the DMG family and the written value on a color console in either
mode. The answer is `DMG_FAM` (WRAM `$DC09`), set at boot.

### Boot registers

A game expects the registers the boot ROM leaves, and some check them to
tell consoles apart. Each jump pops AF, BC, DE and HL from `BOOT_REGS`
(WRAM `$DC00`), which the kernel fills at boot (`stage1_skip_mark` in
[ezcfg.c](../kernel/mod/src/ezcfg.c)):

- **Our stage1** pushes the boot ROM's registers as its first instructions
  ([crt0.s](../stage1/src/crt0.s)) and copies them to pSRAM page `$11`,
  `$A428`-`$A42F`, in pop order: `F A C B E D L H`. So every model gets
  what its boot ROM left. `C = $14` shows an SGB, and sets `NO_DMG`
  (`$DC08`) so it resets, since the SNES enables SGB features from the
  game's header.
- **Stock stage1** wipes the registers, so the DMG boot ROM's values go in
  and the DMG models cannot be told apart. An SGB looks like a DMG too, so
  `SGB BOOT` ticked stands in for it.

The kernel zeroes `A` in the record each boot, so a record cannot outlive a
switch of stage1.

What our stage1 records, by SameBoy model. The two color rows match
hardware ([debug-tab.md](debug-tab.md#what-it-has-shown-on-hardware)):

| Model | F | B | C | D | E | H | L |
|---|---|---|---|---|---|---|---|
| `dmg`, `mgb` | `$B0` | 0 | `$13` | 0 | `$D8` | `$01` | `$4D` |
| `sgb` | 0 | 0 | `$14` | 0 | 0 | `$C0` | `$60` |
| `cgb` | `$80` | 0 | 0 | `$FF` | `$56` | 0 | `$0D` |
| `agb` | 0 | `$01` | 0 | `$FF` | `$56` | 0 | `$0D` |

The flags in F come from stage1's header checksum, not the game's.

## How

Every launch ends in `RomLoad_BuildAndRunPoll` (`04:40e7`), which copies
the launch stub to `$D100` and calls it
([boot-and-launch.md](boot-and-launch.md#launching-a-game)). The stub
starts the load, polls it, switches the cart to the game, sends the unlock
and resets.

| Site | What |
|---|---|
| `04:40f8` | `call $d100` becomes `call SkipBootPrep` |
| `SkipBootPrep` `04:6be6` | [skip_boot.asm](../kernel/mod/asm/skip_boot.asm). Unless `BOOTROM=1` is set, it copies `SkipBoot` to `$D1B0`, after the stub, and patches the stub's reset to jump there. Then it runs the stub |
| `SkipBoot`, in WRAM at `$D1B0` | Runs after the cart has switched to the game, so it can read the game's header and cannot call anything in cart space |

`SkipBoot`:

1. Reads the game's `$0143` and resets unless the table above says jump.
2. `di`, then turns the LCD off in VBlank.
3. **On a color console, tests for CGB mode.** It writes `$5A` and then
   `$A5` to palette RAM and reads each back. In compatibility mode palette
   RAM ignores writes, and that resets. `VBK` cannot be used for this,
   because it reads back in compatibility mode ([cgb-mode.md](cgb-mode.md)).
4. Finishes the FPGA unlock with a write that changes nothing and the
   commit. It then writes 0 to `$0000`, `$4000` and `$6000`, because the
   unlock went to the game's MBC too.
5. Puts back what the boot ROM leaves and the kernel changed: VRAM and OAM
   cleared, palettes white, the I/O registers zeroed, sound on, and
   `BGP = $FC`.
6. `LCDC = $91`, `IF = 0`, then waits for LY 144, so the jump comes at the
   start of VBlank, as after the boot ROM.
7. Pops the registers from `BOOT_REGS`, sets SP to `$FFFE` and jumps to
   `$0100`.

### What does not match the boot ROM

- `DIV` and the exact LY.
- `DMA` is never written, because writing it starts a transfer.
- On the DMG family VRAM is cleared where the boot ROM would leave the
  logo, and `NR52` reads `$F0` plus any channel the game starts, not `$F1`.

## In stage1's fast launch

A boot with `FLAUNCH=` under our stage1 never reaches the kernel, so stage1
makes the same choice itself (`game_launch` in
[game.c](../stage1/src/game.c), with the jump at the end of
[game_handoff.s](../stage1/src/game_handoff.s)). The rules are the same,
from the registers stage1 saved: `A = $11` jumps for a game with the CGB
flag, any other `A` jumps unless `C = $14`, and `BOOTROM=1` always resets.
Stage1 needs no mode test, since its header puts a color console in CGB
mode.

It puts back less than `SkipBoot`, only what stage1 changed.

## Trying the DMG path on a color console

`STAGE1_CFLAGS=-DFORCE_DMG` builds a stage1 without the CGB flag that
records a DMG's registers whatever the console's were. The kernel then
sees a DMG and games get `A = $01`. Colors still come from the boot ROM's
compatibility palette and the color registers still answer, so it is not a
DMG to a test ROM.
