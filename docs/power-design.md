# Power design and boot stability

Started 2026-10-09. This page covers how the Jr is powered, how the coin cell
fits in, and why boot stability tracks the cell. Most of it is still
hypothesis. Everything marked **observed** was seen on real hardware.
Everything else is a candidate explanation with a test that would settle it.

Related: [hardware-board.md](hardware-board.md) (chips),
[battery-sram-swap.md](battery-sram-swap.md) (cell drain),
[nor-reuse.md](nor-reuse.md) (pSRAM fade), [`re/stage0/docs/picoblaze.md`](../re/stage0/docs/picoblaze.md) and
`fpga-stage1.md` on the `bitstream-re` branch (power-on sequence), and
[issue #6](https://github.com/lukesau/ezgb/issues/6) (FPGBC + weak cell).

## Observations

| # | Observation | Source |
|---|---|---|
| O1 | Boot stability goes **no cell < weak cell << new cell**, and the steps look exponential rather than linear. With a new cell, boot failures basically never happen. | observed, user's FW4 Jr + FW5 |
| O2 | It is worst on the **first boot after the cart has been off a while**. | observed |
| O3 | After a failed boot, the next attempt is more likely to work. Something seems to **charge up**: batteryless carts sometimes need boot, wait, reboot, sometimes several times. | observed |
| O4 | With an **empty holder**, the save pSRAM (U4) fades much more slowly than expected: the BACKUPSAVE stamp `$A000=$AA` survived while the path at `$A010` turned to junk. | observed, mod 5.x save-stamp check |
| O5 | The game pSRAM (U9, not battery-backed) also holds data briefly. A fast power cycle reads back exact bytes, a longer off-time fades bits toward `$FF`, and pulling the cart clears it to `$FF`. | observed, [nor-reuse.md](nor-reuse.md) |
| O6 | Failures happen at every stage before the kernel: garbled Nintendo logo, logo striped with vertical lines like a bar code, and a hang on the level-1 (stage1) splash. | observed |
| O7 | Issue #6: after an FW4 to FW5 update, a cart showed full-screen repeating tile patterns at random, on both a GBA and an FPGBC. It was stable on the GBA after reflashing, but still marginal on the FPGBC with a weak cell. New cell result pending. | reported, issue #6 |

O7 shows that the corruption is not only a hang. A failure can also leave the
cart running with bad data (see H5).

## What is known about the power tree

| Item | Status |
|---|---|
| Cart supply | Console VCC on the edge connector: 5 V on DMG/CGB/GBA-in-GB-mode. **FPGBC slot voltage and its level shifting are unverified**, see below. |
| 3.3 V rail | Feeds the FPGA VCCO, the LVT162245 shifters (U6/U7), the config flash, and very likely both MCPs. **Regulator part not identified.** |
| 1.2 V rail | Spartan-3A VCCINT. VCCAUX is 2.5 or 3.3 V (board picks). **Regulator(s) not identified.** |
| Backup domain | Coin cell (CR2016/CR2032 holder) backs **U4's 512 KB pSRAM die** and the **PCF8563 RTC (U3)**. **The switchover part is not identified.** It could be a diode-OR (e.g. BAT54C), a single diode plus resistor, or the RTC's own supply. This decides most of the hypotheses below. |
| U9 game pSRAM | Main rail only. Volatile (O5). |
| Board capacitance | Unknown. The JTAG notes ([hardware-board.md](hardware-board.md)) confirm all rails beep together through decoupling caps when unpowered. That says nothing about bulk capacitance on the backup node. |

### FPGBC cart slot (unverified)

The FPGBC is FPGA-based, and FPGA I/O tops out at 3.3 V, so it has to do
*something* to talk to 5 V carts. No public schematic or teardown says what,
and FunnyPlaying notes some flash carts may not work. There are three likely
designs, and each one hurts the Jr differently:

| FPGBC design | Effect on the Jr |
|---|---|
| 5 V slot + level translators (likely) | Two translators in series: the Jr's LVT162245 outputs only reach ~3.3 V, which is marginal against a 5 V-side input threshold (0.65-0.7 × VCC ≈ 3.25-3.5 V). Translator delay also eats bus timing margin. Auto-direction parts (TXS0108-class) are known to misbehave against strong push-pull drivers like LVT. |
| 5 V slot + series resistors into the FPGA's clamp diodes | Fine for reads from the cart. Writes and the `/RD`/`/WR` levels reach the Jr at 3.3 V, which its 5 V-tolerant inputs accept. Least likely to be the problem. |
| 3.3 V slot, no translation (cheapest) | The Jr's 3.3 V regulator runs from a ~3.3 V input, so it is in dropout and the rail sits lower. That stacks directly with H1 and H3. |

Test: DMM on cart-edge pin 1 (VCC) with the Jr in the FPGBC, and the high level
of a data line during a read if a scope is available.

**First job:** trace the coin-cell holder's `+` terminal to whatever it feeds,
note every diode, resistor and cap on that net, and find out where the RTC's
I²C pull-ups get their supply.

## The power-on chain and where each symptom fits

> **Correction (2026-10-09).** The first version of this page said the boot
> ROM doesn't wait for the cart. It does: the Jr drives the Game Boy reset
> line (through 330 Ω, per nitro2k01 in
> [issue #5](https://github.com/lukesau/ezgb/issues/5), and
> [sgb-boot.md](sgb-boot.md)) and holds the CPU in reset while the FPGA loads.
> H2 below is rewritten to match. The race only exists if that hold fails or
> is released before the cart is ready.

The cart holds the Game Boy CPU in reset while the FPGA loads, then releases
it. The boot ROM then reads the logo from the cart, so the cart has to be
serving the header by the time reset is released.

```
console 5 V ramps ──► cart 3.3 V / 1.2 V ramp
                          │
                          ├─ Spartan-3A POR, then reads the bitstream from SPI flash (EN25F40)
                          │    FW4: slot A config ─► PicoBlaze bank 2 ─► IPROG ─► slot B config
                          │
cart releases CPU reset ──┼─ boot ROM clears VRAM, then reads logo $0104-$0133 from the cart   ◄── only safe if the hold held
                          │
                          ├─ PicoBlaze reset (re/stage0/docs/picoblaze.md, X3Y29 $000):
                          │    1. bank 2: SPI flash tally write at $070000, Device DNA, license read at $030000
                          │    2. SD init (CMD0, CMD8, ACMD41 ×255 max, ... 4-bit)
                          │    3. rtc_init: bit-banged I²C to the PCF8563
                          │    4. interrupts on, service kernel commands
                          │
                          └─ stage1 (BRAM): EZ-FLASH, LOADING, pf_mount, pf_open EZGB.DAT,
                               LoadKernel (PicoBlaze streams it into U9 pSRAM), jp $0100
```

| Symptom | Stage | What it implies |
|---|---|---|
| Blacked-out logo | header read | Data bus reads `$FF` everywhere: the FPGA is not configured or not driving yet, and the bus is pulled up. Same as the bricked-flash symptom in [hardware-board.md](hardware-board.md). |
| **Bar-code logo** (vertical stripes) | header read | Each logo byte draws the same pixel columns in every tile, so **one or more data lines stuck** at a fixed level while addressing works gives continuous vertical lines. This points to a partly up bus (shifters enabled, FPGA I/O not driving or driving a constant), not random noise. |
| Garbled logo | header read | Bytes arrive but are wrong or shifting: the FPGA is mid-configuration or mid-IPROG, so I/O are tri-stated, or the bus is marginal. |
| Logo OK, hang on stage1 splash | PicoBlaze / stage1 | The FPGA came up, but the PicoBlaze is stuck or refused to load (H3, H4), or SD init failed silently. |
| Kernel or game runs with tile garbage (O7) | load | The load "finished" but U9 pSRAM holds bad bytes (H5). |

## Hypotheses

Ranked by how well each one explains O1-O3 together.

### H1: rail sag from charging the backup domain at power-on

With a **new cell** (~3.0-3.2 V), the backup node already sits at or above
what the 3.3 V rail can feed through its OR diode, so the rail feeds nothing
there at power-on. With a **weak cell**, the rail has to top up the node,
and possibly the cell itself if the blocking is poor. With **no cell**, the
rail charges the node's capacitance plus U4's pSRAM and the RTC from near
zero. That extra inrush slows or dents the 3.3 V ramp at exactly the moment
the FPGA is doing POR and configuring.

- Explains O1: the load scales with how far below the rail the node sits, and
  the boot margin is a threshold, so the effect looks exponential.
- Explains O2/O3: a failed boot leaves the node charged. The next boot doesn't
  pay the inrush, so it succeeds (**the "charging up" effect**). After a long
  off-time the node has drained and the cost comes back.
- Fits O4 if the node has real capacitance: it keeps U4 alive (or near its
  retention voltage) long after power-off with an empty holder.
- Predicts: scope shows a slower or dented 3.3 V ramp with no cell, and that
  ramp gets better on the immediate retry.

### H2: the reset hold fails or lets go too early

Separate from H1, but H1 makes it worse. The cart is supposed to keep the CPU
in reset until it can serve the header. If the CPU starts early, the boot ROM
reads the logo from a cart that isn't ready, which produces exactly the
logo-stage symptoms. Ways that could happen:

- **Before the FPGA is configured.** Spartan-3A I/O are high-impedance during
  configuration, with optional weak pull-ups. Unless something else on the
  board (a pull-down, or a pin left low) holds reset during that time, the
  hold doesn't exist until the FPGA is up. Find what drives the reset pin
  (cart-edge pin 30) at power-on.
- **During the FW4 IPROG hand-over.** Slot A reboots the FPGA into slot B, and
  all I/O go high-impedance again for the second configuration. If the reset
  hold drops then, the CPU runs while slot B is still loading.
- **Weak drive under a sagging rail.** The hold is a 330 Ω series resistor
  from a 3.3 V output into the console's reset input. With the rail low it may
  not be held firmly enough.

Notes:

- Consoles differ in how their reset input and supply ramp behave, which
  could explain why the FPGBC is more marginal than the GBA (O7).
- Bitstream header values ([`re/stage0/docs/bitstream.md`](../re/stage0/docs/bitstream.md)): `COR1 2f08`, `COR2 89ee`,
  `CCLK_FREQ 3c0f`. Decoding `CCLK_FREQ` gives the config time
  (bitstream bits / CCLK, ×2 on FW4), which is how long the hold has to last.
- Test: scope the reset pin together with the 3.3 V rail at power-on, with no
  cell and with a new cell. The cart's reset button reconfigures without a
  power ramp. If reset always succeeds where cold boots fail, the ramp is the
  problem, not steady-state power.

### H3: flash writes and reads at every power-on, under marginal power

Bank 2 runs before anything else (`reset` → `call_bank2`):

- It **programs a tally byte in the config flash at `$070000` on every
  power-on**, and **erases that sector** when all 256 bytes are used. On FW4
  slot A it then reboots into slot B through ICAP.
- It reads the **license record at `$030000`** and the Device DNA. If the CRCs
  don't match, `license_a/b` ≠ `F1 F2`, and `cmd_load_rom` (`$1AB`) quietly
  **returns without loading**. Stage1 then waits forever on LOADING. This is
  one concrete way to get a silent level-1 hang: a single bad bit read from
  bit-banged SPI at low voltage.
- Tally semantics: if slot B never reaches bank 2, its byte stays `01`, and
  the next power-on **stays on slot A, the fallback image**. On a FW4 cart a
  power-induced slot B failure can therefore change *which FPGA design runs*
  on later boots. (FW5 images all carry `$1B8 = 02` and never hand over.
  Which image sits at flash 0 on FW5 is still open.)
- The sector `$070000` is a **free boot log**: dump it with the programmer.
  A `00` is a slot B boot that got as far as bank 2, and a `01` that stays put
  is one that didn't. Compare after a no-cell session and a new-cell session.
- An erase interrupted by a brown-out only hits the tally sector, not the
  bitstreams, but EN25F40 writes below ~2.7 V are out of spec. Issue #6's
  "bad flash" may simply have been an updater run on marginal power, which is
  what EZ Flash warns about ([1.05e-instability.md](1.05e-instability.md)).

### H4: the RTC holds the PicoBlaze before interrupts are enabled

`rtc_init` runs at the end of PicoBlaze reset, **before** interrupts are
enabled. `i2c_scl_high_wait` (`$30B`) spins on SCL reading high and has **no
timeout**. The PCF8563 never drives SCL, so this only hangs if the SCL
pull-up has no supply. That could happen if the pull-ups sit on the backup
node and that node is low at the moment of the read. A browned-out PCF8563
can also hold **SDA** low mid-byte. That doesn't hang this code, but it
returns garbage, and with VL set `rtc_init` then stops the clock and writes a
default date.

- If this hangs, the PicoBlaze never services commands, so stage1's first
  `DiskRead` never completes: **hang on the splash with no error message**.
- Test: find the pull-up supply (first job above). If it is the backup node,
  check the SCL level during a failing boot.
- Note that `sdc_wait_ack` (`$15C`) is also unbounded. It relies on the SD
  controller's own timeouts to raise an event. An SD card that browns out
  during init (cards draw big inrush at ACMD41) may or may not trip them.

### H5: marginal U9 pSRAM writes during the kernel/game load

The PicoBlaze streams the kernel (and later games) into U9's pSRAM. If the
rail is low, or pSRAM init timing (≥150 µs stable VCC before the first
access, typical for this class of part) is violated, writes can land with bit
errors. Nothing checks them. The result is not a hang but **a running
program with bad bytes**: issue #6's repeating tile patterns, Tetris running
1 in 4-5 times while larger games always fail. That fits too, since a larger
image is more likely to contain a bad bit.

- Test: launch a known ROM, then read it back. The NOR-reuse probe
  ([nor-reuse.md](nor-reuse.md)) already does this. Compare bit-error counts
  for no cell vs new cell.

### Why the fade is slow with an empty holder (O4, O5)

There are two explanations, and they predict different things:

1. **Stored charge** on the backup node keeps U4 at or near its retention
   voltage (supports H1). Measurable as a voltage across the empty holder
   that decays over seconds to minutes after power-off.
2. **DRAM cell remanence.** pSRAM is DRAM inside, and unpowered cells hold
   charge for seconds to minutes at room temperature (the cold-boot-attack
   effect). This needs no stored energy at all. U9, which has no backup,
   showing the same fade (O5) is evidence that remanence alone is enough.

Both may be true. Only (1) also explains the charging-up effect (O3).

## Test plan

In order of cost:

1. **Trace the backup net:** holder `+`, the switchover part, U4 pSRAM VCC,
   RTC VDD, and the I²C pull-up supply. Photograph the area.
2. **Empty-holder voltage vs time** after power-off (DMM across the holder,
   sampled at 1 s, 10 s, 1 min, 10 min). Non-zero and slowly decaying means
   stored charge (supports H1).
3. **Bench supply in the holder**, swept 0 / 2.0 / 2.4 / 2.7 / 3.0 / 3.3 V,
   with a fixed off-time (e.g. 10 min), 20 cold boots each. Log success and
   failure type per boot. This turns "exponential" into a curve with a knee.
   Also measure the **current direction** through the holder while the cart is
   on: current flowing into the cell means the cell is being charged (bad, and
   it supports H1).
4. **Off-time sweep** at no cell: 5 s / 1 min / 10 min / 1 h before a cold
   boot. Plots how fast the charging-up effect decays.
5. **Reset button vs power cycle** (H2).
6. **Scope** the cart 3.3 V and 1.2 V rails, triggered on console 5 V, with no
   cell vs new cell, first boot vs immediate retry. Add the reset pin (cart
   pin 30), the FPGA DONE pin, and cart `/RD` around the `$0104` read if they
   are reachable. Shows directly whether reset is held until config finishes.
7. **Dump the tally sector** `$070000` before and after a test session (H3).
8. **Load-integrity readback** for no cell vs new cell (H5).
9. **Decode `CCLK_FREQ 3c0f`** and compute config time (H2, desk work).

## Practical takeaways so far

- A fresh cell is a stability part on this cart, not just a save/RTC part.
  Advise a new cell before firmware updates and on any "random garbage at
  boot" report.
- Never run the FPGA updater on a weak or missing cell or weak console power.
  Bank 2's flash path is the same one the updater uses.
- The SRAM swap ([battery-sram-swap.md](battery-sram-swap.md)) keeps the cell
  healthy for years, which should also fix the stability problem if H1 holds.

## Open questions

- Is the switchover a proper diode-OR, or can the rail charge the cell?
- FPGBC cart-slot supply voltage, slew rate and level translation, compared
  with DMG/GBA (see "FPGBC cart slot").
- Does the kernel's `BATTERY` / `DRY!!!` check ([boot-map.md](boot-map.md)
  `Call_000_1835`) read the coin cell or console power? See
  [1.05e-instability.md](1.05e-instability.md), which says console power.
- After a failed slot B boot leaves a `01`, does slot A ever advance the tally
  again, or does the cart stay on slot A until the sector is erased?
