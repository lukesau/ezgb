# SD error recovery in the PicoBlaze

Status: **built 2026-10-29 for FW5-0918, checked in simulation, not yet on
hardware.** FW4 (`X3Y29`) would take the same patch at its own addresses;
not done. Source: [stage0/sd-recover-fw5-0918.psm](../stage0/sd-recover-fw5-0918.psm),
on bank 1 = BRAM `D0X3Y1` (listing `re/stage0/picoblaze/fw5-0918/bank1.psm`).
Shipped in slot B by `scripts/fpga/build-stage1-updater.sh fw5-0918`.

## Why a bad card freezes instead of slowing down

- **Timeouts are off.** `sdc_init` writes 0 to the command timeout (`$20`)
  and data timeout (`$18`), and in the controller 0 means none
  (`timed_out = |timeout_reg && ...` in `stage0/rtl/sd_cmd_master.v` and
  `sd_data_master.v`). A command the card never answers waits forever.
- **A data CRC error never completes.** The data master sets `EI|CCRCE`
  on a CRC error (and `EI|CFE` on a buffer error) but not `CC`
  (`sd_data_master.v` ~L157-182). `sd_command` waits on `CC` alone
  (`$1A1-$1A5`: `TEST s3, 01`), so the PicoBlaze sits in that loop with
  interrupts off.
- **The kernel waits on the same bit.** The data interrupt enable is
  `$01` (CC only, `$13E`), and the `$A000` status window reads `$E1`
  until that interrupt (`stage0/rtl/gb_data_out.v` L94, `cmd_b4_flag`).
  `DiskRead_B2_waitPeek` spins on `$E1` with no timeout, so the screen
  just stops.

FW4 and FW5 share all of this; the SD routines are identical.

**The SD clock is in spec and the same on both.** The divider runs on the
DCM's CLK2X of the 24.545 MHz crystal (Y1), so f_sd = 49.09 MHz /
(2 × (div + 1)): 24.545 MHz at divider 0, 336 kHz at `$48` during
identification, on FW4 and FW5-0918 alike. FW5's faster CLKFX (×10/3
against ×3) only clocks the 595. FW5's one SD speed-up is the fast-load key
(`$7FD3+$7FD4 = $11`, [firmware-diff.md](../re/stage0/docs/firmware-diff.md#fw5s-new-registers)), which skips the
~20 ms pause after each `CMD12` during a ROM load.

> **Correction (2026-10-29).** The plan this doc started as put the SD
> clock at ~29 MHz, past the 25 MHz default-speed limit, from a ~58 MHz base
> inferred from `$48` giving 400 kHz. The netlist trace above replaced it;
> divider 1 is 12.27 MHz, not 14.6. `re/stage0/docs/picoblaze.md` carried
> the same inference and is corrected too.

## What the patch does

75 words: 9 replaced in place, 66 new at `$3A4-$3E5` (of the 76 free
there; `$3F0-$3F7` is the bank-switch window and stays untouched). Two
scratchpad bytes unused by bank 1 and bank 2 (stock and
`stage0/flash-read.psm`): `$07` `sd_slow`, `$08` `sd_tries`.

| Site | Was | Now |
|---|---|---|
| `$12B` (`sdc_cmd_timeout`) | `LOAD s1, 00` | `LOAD s1, FF`: command timeout `$FFFF` SD clocks (2.7 ms) |
| `$19F-$1A0` | debug `55` putc | `LOAD s4, 00`, `CALL dw_init`: zero the spin count |
| `$1A5` | `JUMP Z, L_1A1` | `JUMP data_wait` |
| `$224` (`cmd_load_rom`) | `STORE s0, 2B` | `CALL key_store`: the fast-load key, or 0 after the drop |
| `$23A` (loader) | `CALL sd_cmd12_stop` | `JUMP ld_tail` |
| `$326` (`rtc_dump`) | `OUTPUT s5, EE` | `CALL wday_out` |
| `$370` / `$377` (ISR `$80` / `$40`) | `CALL sd_cmd12_stop` | `JUMP rd_tail` / `wr_tail` |

**Error exit.** A lost response now ends with `EI|CTE` = `$06`, which the
command wait already treats as done (`$194`). `data_wait` leaves the data
wait on `CC` or `EI`, or after `SPIN_HI` × 65536 polls (`$08`: ~400 ms at
0.76 µs a poll, measured in simulation), reporting `EI`. The data timeout
register can't do this: its watchdog is 8 bits of SD clocks across the
whole transfer, and one block is over 1000. R1b busy (`CMD12` after a
write) is the command master's `BUSY_CHECK`, which has no watchdog, so a
slow card's programming time is never cut short. The poll count lives in
`s4/sB/sC`, which every data path has already clobbered.

**Recovery (`sd_recover`).** Soft reset the controller's masters (`$124`,
`$138`; the register file keeps the divider, bus width and enables), set
divider 1 (12.27 MHz), set `sd_slow`, clear the fast-load key (scratchpad
`$2B`, so loads pause after each run again, as on FW4), then `CMD12` and
`sd_wait_tran` to put the card back in tran. Both changes stay until
power-off; the first error costs one retry and later ones none. The divider
stays by itself, but `cmd_load_rom` reads the key from the FPGA into `$2B`
at the start of every load, so `key_store` (at `$224`) stores 0 instead
whenever `sd_slow` is set.

> **Correction (2026-10-30).** The first build cleared `$2B` only in
> `sd_recover`, which lasts for the load that failed: the next load read
> `$7FD3+$7FD4` again and ran fast at half clock, stage1's fast launch
> (`game.c` writes `$7FD4=$11` right before it) included. Fixed with
> `key_store`; the earlier claim that the key stayed off until power-off
> was wrong for that build.

**Retry.** Sector reads and writes (`rd_tail`/`wr_tail` → `xfer_check`):
on `EI` in `data_status`, recover and go back to `$36D`/`$374`
(`sd_wait_tran`, LBA, the command) up to 4 times; the kernel only ever
sees the `CC` of the try that worked. The whole multi-block command is
redone from its first LBA, safe both ways (the sector buffer is untouched
until the kernel copies it out). The Z/NZ answer goes in `s4`, not `s3`:
the ISR saves no registers, stock leaves `s3 = $01` there, and the idle
loop's interrupted `delay_long` counts down `s3`, so a 0 would turn the
next pause into 256 passes and stall the RTC refresh (the first build did
exactly that). The ROM loader (`ld_tail`) recovers and jumps back to
`L_230`, which re-sends the run's destination and re-runs the table
lookup (`extent_lookup` keeps no state), with no retry limit.

**Indicator.** After the drop, `wday_out` makes the idle loop's RTC copy
report weekday 7, which a PCF8563 never holds (0-6). The FPGA keeps only
the weekday's three bits (a tagged `$55` read back `$05`), so the unused
high bits can't carry it. Nothing reads the weekday: stage1 skips `$A00C`,
`ezcfg` masks it out of its comparisons, and the kernel's writes hardcode
`$03`. The kernel's HELP pane ([help_sd.c](../kernel/src/help_sd.c),
`08:7c00`) reads `$A00C` in page 6 and draws `SD SPEED: HALF` under the
GitHub link when it is 7, in both UI modes (8px: `DrawHelpModVersion`'s
closing `jp $7141` at `08:7af1` goes through `HelpSdHook`, `08:7cc0`;
12px: `Help12` calls it). At full speed, and on stock firmware, the pane
is unchanged. SameBoy shows the line with `SAMEBOY_EZFLASH_JR_SDSLOW=1`.

## Simulation

`re/stage0/sim/gb_sdfault.vh` on the patched FW5-0918 design (exported
with `scripts/fpga/export-netlist.sh`, `fastboot.py --fw fw5-0918`, RTC on
P31/P32): reads of LBA 0 and 1, a write of 4000, a read of 2, then the
weekday in kernel mode. The SD model's fault plusargs (`models.v`):
`+SD_BAD_READS=n`, `+SD_BAD_WRITES=n`, `+SD_DROP_CMD=i [+SD_DROP_N=n]`.

| Run | Result |
|---|---|
| stock FW5-0918, no faults | all four transfers right, weekday `05` |
| patched, no faults | identical to stock, transfer for transfer |
| one bad read CRC | retried at half speed, data right, weekday `07` |
| one write CRC error | retried, the card got the block again, weekday `07` |
| dropped CMD13 (during init) | command timeout after 2.7 ms, init carries on, full speed |
| dropped CMD18 | command timeout, then the ~400 ms spin, recover, retry: read right at 433 ms, weekday `07` |
| dropped CMD25 | the same for the write (done at 434 ms), read-back right, weekday `07` |
| one bad read, then a ROM load with `$7FD3=0`, `$7FD4=$11` (`gb_sdload.vh`) | the load stores the key as 0 and pauses after all 8 runs, data byte-exact, weekday `07`; clean, the same load stores `$11` and never pauses; the first build took the fast path |
| five bad reads / five bad writes | exactly five attempts, then the GB waits on `$E1` (the give-up, see Open) |

The test's first version waited for the write as `gb_sdwrite.vh` does
(`$A000` non-zero), which `$E1` already is, so the next read raced the
write and read back wrong bytes on stock and patched alike. It now waits
as `DiskWrite_B2_waitPeek` does, for `$A000` to leave `$E1`.

## Open

- **Final give-up still freezes.** After the fifth failure the kernel
  waits on `$E1` forever. Pair with a kernel-side timeout on
  `DiskRead_B2_waitPeek` / the write poll that shows an SD error screen.
- **Stale response on a timed-out CMD13.** `sd_wait_tran` compares
  `resp2` with `$09`; a lost CMD13 response leaves the previous response
  there, which may read as ready. The data path then fails and retries,
  so it recovers (the dropped-CMD13 run), but checking `EI` in
  `sd_wait_tran` would be cleaner.
- Whether halving the clock is wanted at all: the clock is in spec, so
  the fallback could clear only the fast-load key, which is exactly FW4's
  behavior.
- The FW4 port, and a hardware run on a card that misbehaves.
