# SD error recovery

On stock firmware a single SD error freezes the cart. This patch to the
PicoBlaze's first program makes an error time out, retries the transfer,
and drops to half clock for the rest of the session. It is for FW5-0918
([sd-recover-fw5-0918.psm](../sd-recover-fw5-0918.psm)), ships in every
FW5-0918 updater this project builds, and runs on hardware. FW4 would take
the same patch at its own addresses; that port is not done.

## Why a bad card freezes

FW4 and FW5 share all of this. Their SD routines are identical.

- **Timeouts are off.** `sdc_init` writes 0 to the command and data
  timeout registers, and in the controller 0 means none
  (`sd_cmd_master.v`, `sd_data_master.v` in [fw4/rtl](../fw4/rtl/)). A
  command the card never answers waits forever.
- **A data CRC error never completes.** The data master sets an error
  flag on a CRC error but not the completion flag, `CC`, and the
  PicoBlaze's `sd_command` waits on `CC` alone, with interrupts off.
- **The kernel waits on the same bit.** The `$A000` status window reads
  `$E1` until the data interrupt, and the kernel's disk read spins on
  `$E1` with no timeout. The screen just stops.

The SD clock is not the cause. It is in specification and the same on both
firmwares: the divider runs on twice the 24.545 MHz crystal, so the clock
is 49.09 MHz / (2 x (divider + 1)): 24.545 MHz at divider 0 and 336 kHz
during identification.

## What the patch does

75 words: 9 replaced in place and 66 new at `$3A4`-`$3E5`. It uses two
scratchpad bytes neither program uses, `$07` (`sd_slow`) and `$08`
(`sd_tries`).

| Site | Stock | Patched |
|---|---|---|
| `$12B`, `sdc_cmd_timeout` | `LOAD s1, 00` | `LOAD s1, FF`: a command timeout of `$FFFF` SD clocks, 2.7 ms |
| `$19F`-`$1A0` | a debug output | zero the spin count |
| `$1A5` | loop until `CC` | `JUMP data_wait` |
| `$224`, in `cmd_load_rom` | `STORE s0, 2B` | `CALL key_store`: the fast-load key, or 0 after the drop |
| `$23A`, the loader | `CALL sd_cmd12_stop` | `JUMP ld_tail` |
| `$326`, `rtc_dump` | `OUTPUT s5, EE` | `CALL wday_out` |
| `$370`, `$377`, the read and write interrupts | `CALL sd_cmd12_stop` | `JUMP rd_tail`, `JUMP wr_tail` |

### An error ends the wait

A lost response ends the command wait through the command timeout.
`data_wait` leaves the data wait on completion, on an error flag, or after
about 400 ms of polling. The controller's data timeout register cannot do
this job: its watchdog is 8 bits of SD clocks across the whole transfer,
and one block takes over 1,000.

A card that is busy programming after a write is not cut short: that wait
is the command master's busy check, which has no watchdog.

### Recovery

`sd_recover` soft-resets the controller's state machines (the register
file keeps the divider, bus width and enables), sets divider 1 (12.27
MHz), sets `sd_slow`, clears the fast-load key, then sends `CMD12` and
waits for the card to be ready again.

Both changes last until power-off, so the first error costs one retry and
later ones none. `cmd_load_rom` reads the fast-load key from the FPGA at
the start of every load, so `key_store` stores 0 in its place whenever
`sd_slow` is set. Without that the next load would run fast at half clock.

### Retry

- **Sector reads and writes**: on an error, recover and send the whole
  command again from its first sector, up to 4 times. The kernel sees only
  the completion of the try that worked. Redoing the command is safe in
  both directions, since the sector buffer is untouched until the kernel
  copies it out.
- **The ROM loader**: recover and go back to resend the run's destination
  and look the extent up again, with no retry limit.

The retry's yes-or-no answer is kept in register `s4`, not `s3`. The
interrupt handler saves no registers, and the idle loop's delay counts
down `s3`, so a 0 left there turns the next pause into 256 passes and
stalls the clock refresh.

### Telling the user

After the drop, the idle loop's copy of the clock reports weekday 7, which
the clock chip never holds. Nothing reads the weekday: stage1 skips it,
the kernel masks it out of its comparisons, and writes hard-code it.

The kernel's HELP pane ([help_sd.c](../../kernel/mod/src/help_sd.c)) reads
it and shows `SD SPEED: HALF` under the link when it is 7. At full speed,
and on stock firmware, the pane is unchanged.
`SAMEBOY_EZFLASH_JR_SDSLOW=1` shows the line in SameBoy.

## Testing it in simulation

[gb_sdfault.vh](../sim/gb_sdfault.vh) runs reads and writes against the
patched design with faults injected by the SD model
([models.v](../sim/models.v)): `+SD_BAD_READS=n`, `+SD_BAD_WRITES=n`,
`+SD_DROP_CMD=i` and `+SD_DROP_N=n`.

| Run | Result |
|---|---|
| stock, no faults | every transfer right |
| patched, no faults | identical to stock, transfer for transfer |
| one bad read CRC, or one write CRC error | retried at half speed, data right, weekday 7 |
| a dropped command during init | command timeout after 2.7 ms, init carries on at full speed |
| a dropped read or write command | command timeout, the 400 ms wait, recover, retry: data right |
| one bad read, then a ROM load with the fast-load key set | the load stores the key as 0 and pauses after every run, data exact |
| five bad reads or writes in a row | five attempts, then the Game Boy waits on `$E1` |

A test must wait as the kernel does, for `$A000` to leave `$E1`. Waiting
for it to be non-zero returns at once, since `$E1` already is.

## Open

- **The final give-up still freezes.** After the fifth failure the kernel
  waits on `$E1` forever. A timeout in the kernel's disk wait, with an
  error screen, would finish the job.
- **A timed-out `CMD13` leaves a stale response.** `sd_wait_tran` compares
  the response with the ready value, and a lost response leaves the
  previous one there, which may read as ready. The data path then fails
  and retries, so it recovers.
- **Whether halving the clock is wanted at all.** The clock is in
  specification, so the fallback could clear only the fast-load key, which
  is exactly FW4's behavior.
