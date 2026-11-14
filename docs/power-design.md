# Power and boot stability: open questions

How well a Jr boots depends on its coin cell, and nobody has shown why.
This page records what has been observed, what is known about the cart's
power, and the hypotheses with the test that would settle each. None of the
tests has been run.

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
| 3.3 V rail | Feeds the FPGA's I/O, the level shifters, the config flash and very likely both memory chips. The regulator is not identified |
| 1.2 V rail | The FPGA's core. The regulator is not identified |
| Backup domain | The coin cell backs U4's pSRAM and the clock chip. **The part that switches between the cell and the rail is not identified**, and most of the hypotheses below turn on it |
| U9, the game store | Main rail only |

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

The cheapest first steps: trace the backup net (the holder, the switching
part, U4's supply, the clock chip's supply, the I2C pull-ups), then put a
bench supply in the holder and count failures over 20 cold boots at each of
several voltages.

## What to do meanwhile

- A fresh cell is a stability part on this cart, not only a save and clock
  part. Fit one before a firmware update, and on any report of random
  garbage at boot.
- Never run a firmware updater on a weak or missing cell.
- The SRAM swap ([battery-sram-swap.md](battery-sram-swap.md)) keeps a cell
  healthy for years, which should also fix the stability if H1 holds.
