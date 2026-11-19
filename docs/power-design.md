# Power and boot stability: open questions

How well a Jr boots depends on its coin cell, and nobody has shown why.
This page records what has been observed, what is known about the cart's
power, and the hypotheses with the test that would settle each. None of the
boot stability tests has been run. The backup domain has been measured on
the bench ([below](#backup-domain-measurements)), and those readings show
the coin cell supplying current while the console is on.

## Observed

| # | Observation |
|---|---|
| O1 | Boot stability goes no cell, weak cell, new cell, and the steps are far from even. With a new cell boot failures all but stop. Seen on an FW4 and an FW5 cart |
| O2 | It is worst on the first boot after the cart has been off a while |
| O3 | After a failed boot the next attempt is more likely to work, as if something charges up. A cart with no cell sometimes needs boot, wait, reboot, several times |
| O4 | With an empty holder the save pSRAM fades more slowly than expected: a backup stamp survived while its path turned to junk |
| O5 | The game pSRAM, which has no backup, also holds data briefly ([game-store.md](game-store.md)) |
| O6 | Failures happen at every stage before the kernel: a garbled Nintendo logo, a logo striped with vertical lines, a hang on stage1's screen |
| O7 | Reported in [issue #6](https://github.com/lukesau/ezgb/issues/6): after an FW4 to FW5 update a cart showed full-screen repeating tile patterns at random, more on an FPGBC with a weak cell than on a GBA |

O7 shows a failure is not always a hang. The cart can also run with bad
data.

## What is known about the power

| Item | Known |
|---|---|
| Supply | The console's 5 V on the edge connector |
| 3.3 V rail | Feeds the FPGA's I/O, the level shifters, the config flash and very likely both memory chips. Measured at 3.38 V with the console on. The regulator is not identified |
| 1.2 V rail | The FPGA's core. The regulator is not identified |
| Backup domain | The coin cell backs U4's pSRAM and the clock chip. The cell feeds the backup node through D4, a Schottky. **No part that feeds the node from the rail has been found**, yet something does feed it when the console is on ([measurements](#backup-domain-measurements)). Most of the hypotheses below turn on it |
| U9, the game store | Main rail only |

## Backup domain measurements

Bench readings from 2026-11-07 and 2026-11-18, all with a bench supply on
the holder's pins in place of the cell. Which cart, and which console, were
not recorded.

### The parts

Left and right are as seen with the edge connector at the bottom.

| Part | Marking | What was found |
|---|---|---|
| D4 | `S4`, probably a 1N5819WS Schottky | The holder's `+` reaches D4's right side and nothing else. D4's left side is the backup node. The cathode band is on the left |
| D2 | `T4`, probably a 1N4148WS | Neither side reaches the holder's `+`. Not on the backup node |
| C9 | | Left side on the backup node, right side on ground (the holder's `-`) |
| R6 | taken as 10 kΩ, not measured | Top on the backup node, bottom to an FPGA pin. Suspected to be the pull-up on U4's chip enable, P60 ([design.md](../stage0/docs/design.md)). Which pin it is has not been checked |

Voltages to ground with the supply at 3.016 V, file browser showing for the
console-on column:

| Point | Console off | Console on |
|---|---|---|
| D4 right (cell side) | 3.016 V | 3.016 V |
| D4 left (backup node) | 2.9 V | 2.8 V |
| D2 right | 0.429 V | 3.383 V |
| D2 left | 0.003 V | 3.13 V |

- D2's right side is the 3.3 V rail. Its left side is a separate net that is
  only up with the console on. What that net does is not known.
- The 0.43 V on the rail with the console off is not explained. The backup
  supply may be leaking into the rail.
- A reading across D2 with the console off gave 0.42 to 0.45 V with the left
  side positive, which is the opposite sign to the table. Not resolved.
- With the supply below the crossover the current never went negative
  beyond meter noise, so the rail does not charge the cell.

### A second feed

With the holder empty and the console on, the backup node still sat at 2.7
to 2.9 V, and rose to 2.9 V while scrolling the file browser. So something
other than the cell feeds the node when the console is on. A supply sags
under load. This one rises with activity, which points at current coming in
through signal pins: R6 from the FPGA, or U4's input protection diodes. That
is a guess.

### Cell current, console off

2026-11-18, 966 Ω shunt read with a meter. About 26 µA at plug-in, settling
to 12.1 µA before any boot and 13.9 µA after a boot and power-off. The sweep
was taken after the boot cycle:

| Supply | Current |
|---|---|
| 2.90 V | 13.3 µA |
| 2.80 V | 12.7 µA |
| 2.70 V | 12.1 µA |
| 2.60 V | 11.7 µA |
| 2.50 V | 11.2 µA |
| 2.40 V | 10.7 µA |
| 2.30 V | 10.0 µA |
| 2.20 V | 9.3 µA |
| 2.10 V | 8.4 µA |
| 2.00 V | 7.7 µA |

- The reading is the same with the cart in or out of the console, so the
  load is on the cart.
- From 2.9 V to 2.4 V the line is 5.2 µA per volt and reaches zero at about
  0.34 V: a resistance of about 190 kΩ behind a diode drop. Below 2.3 V the
  current falls faster.
- A memory chip's standby current is not usually this linear, so part of
  this draw may be a resistive path and may outlast the SRAM swap. Not
  tested.

### Cell current, console on

2026-11-18, same shunt, sitting in the file browser:

| Supply | Current |
|---|---|
| 3.00 V | 24.8 µA (36.9 µA on an earlier run) |
| 2.90 V | 6.9 µA |
| 2.80 V | 2.9 µA |
| 2.70 V | 1.6 µA |

- At 3.00 V the current moves between 29 and 41 µA while navigating without
  touching the card.
- It drops to about zero while the card is being read: at the hand-over from
  stage1 to the kernel, and when entering a folder.
- Below about 2.95 V the cell supplies less with the console on than off, so
  the second feed carries the whole backup domain there.
- Not measured above 3.00 V, where a fresh cell sits.

The supply setting matters more than the meter here. Around 3.0 V the
current changes by 3.6 times for 100 mV.

2026-11-07, a meter in series, supply at 3 V. These are far higher than the
readings above and the difference is not explained. The kernel build and the
meter both differed.

| State | Current |
|---|---|
| Console off, settled | 20 to 40 µA |
| Just after power-off | zero, then about 700 µA, then settling |
| Boot | 70 µA |
| stage1's kernel picker, the help page | 30 to 70 µA |
| Set page | 150 µA |
| File browser | 450 µA |

Lowering the supply to just under 2.9 or 2.8 V cut the current sharply on
that day too, so the crossover is the same in both sets.

### What it means

- The cell supplies the backup domain while the console is on, until it has
  fallen to about 2.9 V. That fits a cell that weakens within weeks of play
  and then lasts a long time.
- The SRAM swap lowers the standby current. It does not stop the cell
  supplying current while the console is on.
- A larger drop on the cell side (a silicon diode in place of D4) would move
  the crossover above a fresh cell. With the console off U4 would then sit
  about 0.4 V below the cell, under the pSRAM's 2.7 V minimum, so it needs
  the SRAM swap first. It also makes the cart depend on the second feed at
  all times, and that feed is not identified. Not tried.

### Still to measure

- Whether R6's bottom end goes to P60, and the voltage across R6 in the
  file browser, on the help page and while scrolling.
- Whether D4's left side reaches C11, C16 and the clock chip's supply pin.
- What else connects to D2's left side.
- The console-on sweep from 3.0 V up to 3.3 V.
- The voltage at U4's supply in the menu and during a load.
- In-game current, with and without a save.
- The same readings on a second cart.

## The power-on chain

The cart holds the Game Boy CPU in reset, through a 330 ohm resistor, while
the FPGA loads, then releases it. The boot ROM then reads the logo from the
cart, so the cart has to be serving stage1's header by then.

```
console 5 V ramps -> cart 3.3 V and 1.2 V ramp
  the FPGA powers up and reads its design from the SPI flash
    slot A configures -> its PicoBlaze -> reconfigure from slot B
  the cart releases the CPU's reset
  the boot ROM reads the logo from the cart
  the PicoBlaze starts:
    1. writes a tally byte to the flash at $070000, reads the license record at $030000
    2. initializes the SD card
    3. initializes the clock chip over I2C
    4. enables interrupts and serves commands
  stage1 mounts the card, loads the kernel into U9, jumps to it
```

| Symptom | Stage | What it implies |
|---|---|---|
| Blacked-out logo | header read | The data bus reads `$FF` everywhere: the FPGA is not configured or not driving. The symptom of a damaged config flash too ([hardware-board.md](hardware-board.md#recovering-a-cart-whose-fpga-no-longer-configures)) |
| Logo striped like a bar code | header read | One or more data lines stuck while addressing works: a bus that is partly up |
| Garbled logo | header read | Bytes arrive wrong or shifting: the FPGA is in the middle of configuring |
| Logo fine, hang on stage1's screen | PicoBlaze or stage1 | The FPGA came up but the PicoBlaze is stuck or refused to load |
| The kernel or a game runs with tile garbage | load | The load finished but U9 holds bad bytes |

## Facts in the firmware that bear on it

From the PicoBlaze programs ([picoblaze.md](../stage0/docs/picoblaze.md)):

- **The config flash is written at every power-on.** A tally byte is
  programmed at `$070000`, and the sector is erased when all 256 are used.
  The flash is out of specification below about 2.7 V.
- **A bad license read hangs silently.** If the license record's CRCs do
  not match the FPGA's serial number, the load command returns without
  loading, and stage1 waits forever at `LOADING`. One bad bit read from the
  flash at low voltage is enough.
- **The tally decides which image runs next.** If slot B never gets as far
  as its PicoBlaze, the next power-on stays on slot A.
- **Two waits have no timeout**: the clock chip's `i2c_scl_high_wait` and
  the SD controller's `sdc_wait_ack`. A hang in either is a hang on
  stage1's screen with no message.

The tally sector is a free boot log: dump it with a programmer before and
after a session.

## Hypotheses

| | Hypothesis | Explains | The test |
|---|---|---|---|
| H1 | **The rail sags charging the backup domain at power-on.** With a new cell the backup node is already up and the rail feeds nothing there. With a weak or missing cell the rail has to charge it, just as the FPGA is powering up | O1, O2, O3 (a failed boot leaves the node charged), O4 | Scope the 3.3 V ramp with no cell and with a new cell, on a first boot and an immediate retry. Measure the voltage across the empty holder after power-off |
| H2 | **The reset hold fails or lets go early.** The FPGA's pins float while it configures, and again during the slot A to slot B hand-over, so unless something else holds reset the CPU may start before the cart can serve the header | O6's logo failures | Scope the reset pin with the 3.3 V rail. Compare the cart's reset button, which reconfigures with no power ramp, against a cold boot |
| H3 | **Flash reads and writes under marginal power**, per the firmware facts above | the hang at `LOADING`, and a cart changing which image it runs | Dump the tally sector after a session with no cell and one with a new cell |
| H4 | **The clock chip holds the PicoBlaze** before interrupts are on, if the I2C pull-ups are fed from the backup node and it is low | a hang on stage1's screen | Find what feeds the pull-ups. Check SCL during a failing boot |
| H5 | **Marginal writes to U9 during a load.** Nothing checks them, so the result is a running program with bad bytes, and a larger image is more likely to have one | O7 | Launch a known ROM and read it back, with no cell and with a new cell |

Two things could explain the slow fade of O4 and O5, and they predict
different things. Stored charge on the backup node would show as a voltage
across the empty holder that decays over seconds to minutes, and supports
H1. Remanence in the memory cells themselves needs no stored energy, and U9
showing the same fade with no backup at all says remanence alone is enough.
Only the first also explains O3.

The cheapest first steps: finish tracing the backup net (U4's supply, the
clock chip's supply, the I2C pull-ups), then put a
bench supply in the holder and count failures over 20 cold boots at each of
several voltages.

## What to do meanwhile

- A fresh cell is a stability part on this cart, not only a save and clock
  part. Fit one before a firmware update, and on any report of random
  garbage at boot.
- Never run a firmware updater on a weak or missing cell.
- The SRAM swap ([battery-sram-swap.md](battery-sram-swap.md)) keeps a cell
  healthy for years, which should also fix the stability if H1 holds. The
  years assume the cell only supplies standby current, and the measurements
  above show it also supplies current while the console is on.
