# stage0: the FPGA design, readable

The goal: human-readable Verilog for the EZ Flash Jr's FPGA that we can
show is the same design as the FW4 bitstream, block by block, and that we
can later place and route back into an identical bitstream. The reversing
work it builds on is in [re/stage0/](../re/stage0/README.md): the decoded
bitstream, the PicoBlaze programs, the pin and register maps, and the
whole-design simulation.

Three layers were planned
([re/stage0/docs/design.md](../re/stage0/docs/design.md), plan):

1. **Encoder**: `s3encode` rebuilds every cart bitstream byte for byte
   from its decode. Done.
2. **Readable Verilog, proven equivalent to the extracted netlist**: this
   directory. In progress.
3. **Placement and routing sidecar**: the data that turns the readable
   design back into the exact bitstream. Not started; it needs layer 2's
   block structure first.

## How layer 2 works

The design is cut into blocks. For each block there is a block file, a
readable module, and a machine-made reference carved from the design:

| | Where | What |
|---|---|---|
| block file | `blocks/<name>.blk` | the bels that make up the block, and readable names for its boundary nets and flip-flops |
| readable module | `rtl/<name>.v` | our Verilog, module `<name>`, with the block file's port and register names |
| reference | `fpga/<fw>/blocks/<name>_ref.v` (untracked) | module `<name>_ref`: the block's bels exactly as the bitstream configures them, over `lib/s3bels.v` |

A **bel** is one LUT, flip-flop, wide mux or carry mux. `scripts/fpga/carve.py`
decomposes every configured slice of the exported design into its bels and
drops the ones whose output reaches nothing (an unused carry chain, an
unconnected flip-flop). The slice's fixed selections (which LUT feeds the
flip-flop, where the carry starts, input inversions) become wiring. A
block can take one LUT of a slice and leave the other to another block.

`scripts/fpga/equiv.sh <name>` proves the readable module equivalent to the
reference with yosys. The two are matched by name: the ports, and every
flip-flop the block file names. With the registers matched, each
next-state function and output is a combinational proof (SAT); what that
leaves is tried by induction. The check must reject a broken module to
mean anything: three mutants of `unlock` (an address off by one, the lock
data ignored, a feedback term dropped) all fail it.

One yosys detail matters: it matches a net only under its canonical name,
and after flattening that is often the primitive's own hierarchical alias
(`X18Y31_S0_FFX.Q`) rather than the block's name for it, in which case it
silently makes no check cell for that net. The scripts hide every
hierarchical name before matching, so the block file's names are the ones
that count. Unmatched state can only make a proof fail, never pass.

A synthesized FSM adds a wrinkle. XST decodes a one-hot state with a test
per bit, so a register assigned in several states takes the OR of what
every active state assigns; the readable module writes those registers the
same way (`sd_cmd_serial` shows the pattern). What it cannot reproduce is
the hardware's behavior in states that never occur, such as a buffer index
past its end, and the proof covers all states. So a module may state
reachable-state invariants with `assume()` under `` `ifdef FORMAL`` (the
state is one-hot, the counter is bounded per state), and `equiv.sh` then
proves every matched signal by temporal induction with those assumptions
in force.

The invariants have to be true of the hardware, and a wrong one fails
silently: the proof says nothing about the states it excludes, and the
run still reports "equivalent". Writing `sd_data_serial`, a wrong code
for one FSM state hid that whole state from the proof, and a bound that
was off by one hid another; mutants in those states passed. So `equiv.sh`
has a third pass that turns the assumptions into assertions and proves
them on the reference itself, from its reset state and by induction. That
needs them written inductively (what they allow at one step must imply
them at the next): the data host's crc_c assumption, for one, tracks the
counter exactly through the CRC window. Assumptions about inputs (a
constant-0 LUT another block owns) can't be proven and are labeled
`env_…`, which the pass leaves as assumptions. The other check on a proof
is mutation: a module with one thing wrong in each state must fail, and
the blocks table says how many such mutants each block was tried with.

The rule that makes this work: **the readable design keeps the hardware's
registers one for one.** Every flip-flop in the bitstream has a named
register in the readable module; the combinational logic between them is
rewritten freely. That is also what layer 3 needs, since a register that
does not exist in the bitstream cannot be placed.

Block RAMs, the DCMs, the Device DNA port, the ICAP and the IO tiles are
not decomposed: blocks are cut at them, their pins become block ports, and the
readable design will instantiate the same primitives.

LUT RAM is kept cell for cell too. `lib/s3bels.v` has the shapes a design
builds from 16x1 cells (`s3_ram16x1d`, `s3_ram32x1s`, `s3_ram64x1s`); the
readable module instantiates them, and the block file names each hardware
cell after the instance path (`X7Y26_S0_F.m regs0.sy`), which is how the
proof matches the contents. A `pc[3]`-style name in the block file makes
a vector port.

What the proof does not see: the structural passes compare next-state
and output functions, so a module clocked on the other edge, or from
another clock, proves the same (`picoblaze_ports` keeps `in_port` on the
falling edge because the carve says so, not because the proof would
notice), and a register's power-up value is not checked either. Those two
come from the block file and the bels, and a mutant that changes only them
passes.

## Setup

Everything runs on this machine. The cart bitstreams are EZ Flash's and
stay out of the repository (`/fpga/` is ignored), so the first step
exports a design from a local image:

```bash
brew install yosys icarus-verilog rust
(cd scripts/fpga/s3decode && cargo build --release)
# fpga/db/spartan3.zstd: prjcombine's Spartan-3 database (see re/stage0/docs/toolchain.md)
scripts/fpga/export-netlist.sh fpga/cart/fw4-updater.bin fpga/fw4
```

`fpga/fw4/design.v` is then the structural design (`netlist2v.py`, module
`fpga_top`), and:

```bash
python3 scripts/fpga/carve.py fpga/fw4/design.v stage0/blocks/unlock.blk --stub   # port skeleton for a new block
python3 scripts/fpga/carve.py fpga/fw4/design.v --cone n_X18Y31_S0_XQ            # bels driving a net
python3 scripts/fpga/carve.py fpga/fw4/design.v --coverage stage0/blocks/*.blk    # what no block claims yet
python3 scripts/fpga/dumpblk.py fpga/fw4/design.v stage0/blocks/unlock.blk          # the block's equations, with its names
scripts/fpga/equiv.sh unlock                                                      # the proof
```

## Checking the decomposition itself

The bel decomposition is checked against the exporter's slice model, which
the simulations validated against the cart: `scripts/fpga/check-bels.sh`
carves a block of every live slice bel twice, as whole `s3_slice`
instances (`--slices`, over `lib/s3prims_synth.v`, the simulation
primitives without their start-up and delay modeling) and as bels, and
matches the two net for net: every flip-flop, LUT RAM and LUT output. For
FW4 that is 4,883 matched signals, all proven (about five minutes).

## Blocks

| Block | Bels | What | Proof |
|---|---|---|---|
| `unlock` | 23 | the `$7F00/$7F10/$7F20` unlock state machine that gates the `$7Fxx` registers | equivalent |
| `picoblaze` | 425 | the KCPSM3 soft CPU with EZ Flash's two-bank instruction register: 108 flip-flops, all 68 LUT RAMs (register file, 31-deep stack, 64-byte scratchpad) | equivalent, 1,213 signals |
| `sd_cmd_serial` | 1,333 | the SD command line: OpenCores `sd_cmd_serial_host` (LGPL, kept in the module), 358 flip-flops, 975 LUTs and muxes, most of them the 32-bit counter's compares and the response buffer's indexed writes | equivalent, 361 signals, under stated invariants (proven); 3 mutants |
| `sd_cmd_master` | 338 | OpenCores `sd_cmd_master`: the command and argument latch, the 16-bit timeout watchdog, the response and interrupt-status registers; 205 flip-flops | equivalent, 212 signals, under stated invariants (proven); 2 mutants |
| `sd_data_serial` | 1,347 | OpenCores `sd_data_serial_host`: the DAT lines, the four CRC16s, the 14-bit transfer counter, the receive word and its write enable; 174 flip-flops | equivalent, 180 signals, under stated invariants (proven); 28 mutants, all caught |
| `sd_data_master` | 123 | OpenCores `sd_data_master` with `sd_data_xfer_trig`: starts and stops the data host, the 8-bit timeout watchdog, the data interrupt status register, the command-with-data trigger; 35 flip-flops | equivalent, 40 signals, under stated invariants (proven); 18 mutants, all caught |
| `sd_clock_divider` | 53 | OpenCores `sd_clock_divider` on the mode clock, with the divider register's two sync stages; 25 flip-flops | equivalent, 25 signals; 4 mutants, all caught |
| `sd_fifos` | 71 | the SD-clock side of the two data FIFOs: Usselmann's `generic_fifo_dc_gray` as `sd_fifo_filler` instantiates it (rx written by the data host, tx read by it): binary and gray pointers, the other side's gray pointer synchronized, full and empty, the reset and clear synchronizers; 34 flip-flops | equivalent, 36 signals; 12 of 14 mutants caught, the other two remove the clear chain, which the reset chain makes redundant |
| `sd_crossings` | 414 | the controller's `bistable_domain_cross` / `monostable_domain_cross` instances: every register and pulse synchronizer between the mode and SD clock domains; 411 flip-flops | equivalent, 411 signals; 7 mutants, all caught |
| `sd_controller_wb` | 531 | the register file: OpenCores `sd_controller_wb` (its 2013 revision) on the mode clock, written and read by the PicoBlaze's SD ports: the registers the crossings carry, the read mux, the three write-pulse edge detects, the data interrupt; 183 flip-flops | equivalent, 183 signals; 13 mutants, all caught (a fourteenth was no mutant) |
| `sd_fifo_filler` | 189 | the mode-clock side of the two data FIFOs and the Wishbone master between them and memory: OpenCores `sd_fifo_filler` (the FIFO halves Usselmann's), the 21-bit address counter, and EZ Flash's three-cycle acknowledge; 59 flip-flops | equivalent, 62 signals; 13 mutants, all caught (a fourteenth was no mutant) |
| `picoblaze_ports` | 393 | EZ Flash's own: the registers the PicoBlaze's OUTPUT instructions write (the SD data word, the loader's address and table index, the bank bit, DNA, SPI and RTC bits), the in_port mux its INPUT instructions read, the bridge to the SD register file, and the reset synchronizer; 150 flip-flops | equivalent, 153 signals; 15 of 18 mutants caught: one removes a hold term for a state the bridge never reaches, the other two change what the proof does not see (below) |
| `sd_mem_path` | 131 | EZ Flash's own: block RAM X3Y5's Game Boy port (the 2 KB sector buffer at $A000), the rx word and the filler's address latched into the memory clock, the 16-cycle byte sequencer on the system clock that writes a word into the pSRAM, and the SD side of the pSRAM address and data pad muxes; 61 flip-flops | equivalent, 91 signals; 14 mutants, all caught |
| `psram_ctrl` | 185 | EZ Flash's own: the pSRAM controller: which chip a Game Boy access reaches and the page it gets from the bank registers and the MBC state, the page's pipeline into the fast clock and the 74HC595 serializer behind the address pins, the byte strobes, write enable, chip selects and address tristate; 38 flip-flops | equivalent, 125 signals; 12 of 14 mutants caught: one changes the clock edge the proof does not see, the other drops a term a save access makes redundant |
| `gb_data_out` | 202 | EZ Flash's own: the Game Boy data bus output: the sector buffer and its status, the stage1 bit planes, the RTC window in kernel mode and the MBC3 RTC registers in game mode (BCD to binary), the header checksum, the pSRAM's data, and the bus's output enable; no flip-flops | equivalent, 12 signals, under stated input assumptions (the window decode's stages are consistent); 15 mutants, all caught |
| `gb_regs` | 358 | EZ Flash's own: every register the Game Boy writes: the `$7Fxx` registers after the unlock (the mode bits, the window, the MBC type, the bank masks, the header checksum, the sector command and its flag, the loader's, flash writer's, RTC set's and soft reset's bits), the bank registers (plain in kernel mode; through the MBC the type names in game mode: MBC1, MBC2, MBC3, MBC5, the MBC1 multicart's own), the MBC3 RTC select and the seven RTC values to set; 174 flip-flops in the two write-strobe domains | equivalent, 178 signals, under stated input assumptions (the shared address and type decodes are what their blocks make them); 20 mutants, all caught |
| `pb_periph` | 43 | EZ Flash's own: the PicoBlaze's peripherals outside its ports block: the ICAP's eleven driver registers and the I2C output enable on the processor clock, the SPI flash's clock and MOSI muxed onto pSRAM address pins A11 and A12, and the interrupt source on the 2x clock (five Game Boy request flags synchronized, their rising edges setting the interrupt and the port B5 command bits); 27 flip-flops | equivalent, 33 signals, under stated input assumptions (two port decodes, the remapped A12); 16 mutants, all caught |
| `rtc_bridge` | 147 | EZ Flash's own: the RTC bridge on the 2x clock: the seven copies of the PicoBlaze's PCF8563 readings (port ED index, port EE value, loaded on the next OUTPUT strobe) that the register window serves, and the registered port B6 mux over the seven RTC set registers the Game Boy wrote, selected by port F0; 64 flip-flops | equivalent, 64 registers; 10 mutants, all caught |
| `soft_reset` | 74 | EZ Flash's own: the console reset a $7FE0 write starts: the request synchronized into the 2x clock, its rising edge clearing a 16-bit counter on the inverted 2x clock and the reset drive, which returns when the counter saturates; 19 flip-flops | equivalent, 19 registers; 7 of 8 mutants caught, the one that passes changes the drive's initial value, which the proof does not see (below) |
| `gb_bus` | 28 | EZ Flash's own: the Game Boy bus's state in the 2x domain and its address on the pSRAM pins: the registered page bits, busy flag, /RESET and data-interrupt copies, the window remap that clears A11 and A12 in kernel mode above $8000, the lower address pins' word/byte muxes, the stage1 and table block RAMs' port enables, the data pads' input register enable; 7 flip-flops | equivalent, 26 signals, under the assumption that two controller terms arriving under two nets are one signal; 11 of 12 mutants caught, the one that passes changes an initial value |
| `clocks` | 20 | EZ Flash's own: the PicoBlaze clock's gate (kernel mode or the RTC flag), the 74HC595 shift clock's gate and inverted source, the DCM's reset, the /WR \| A15 term the $7Fxx write clock takes, and fifteen constant-0 LUTs on block RAM, clock buffer, DCM and other blocks' pins | equivalent; 6 mutants, all caught |
| `p51_latch` | 1 | the one slice latch: a second latch of the pSRAM A13 mux beside P51's IO-tile output latch, gated by $7FD2 bit 0 and forced to the loader's A13 while a load runs | equivalent; 4 mutants, all caught |
The `sd_cmd_serial` proof was first made with an IDLE counter bound of 4;
the hardware hands IDLE a 5 for one cycle, so that one state was outside
the proof until the invariant was corrected (2026-10-27).

Correction (2026-10-28): the `sd_data_master` block was first written and
proven without the source's data interrupt status register, and its notes
said the synthesis had dropped it as unread. It had not: the five flags
(CC, EI, CTE, CCRCE, CFE) sit at `X11Y15`..`X12Y17`, reset by the software
reset and by the data interrupt reset pulse, and the Game Boy side reads
them. They turned up in the carve of the FIFOs and are in the data master
block now, with the CRC result and the interrupt reset as its inputs; the
crossings paragraph below inherits the fix (the third toggle's status
register exists).

Correction (2026-10-28, later that day): the FIFOs paragraph first said
the FIFOs came "minus the filler's Wishbone master, whose place the Game
Boy side takes". The master is there, on the mode clock, with its address
counter, its read handshake and the FIFO halves it drives (the
`sd_fifo_filler` block); what it talks to is a slave of EZ Flash's own, a
2 KB block RAM (X3Y5) that the Game Boy bus reads and writes on its
other port, and the pSRAM path in the memory clock domain, which takes
the same address. The Game Boy never touches the FIFOs. The FIFOs and
filler paragraphs below are as corrected.

Coverage: 6,429 of 6,543 live cells in twenty-two blocks: every slice
cell. The 114 others are the primitives the blocks are cut at (16 block
RAMs, 68 IO tiles, 24 clock buffers, the DCMs, the DNA port and the ICAP). The design's
live cells are 3,024 LUTs, 2,135 flip-flops, 68 LUT RAMs, 919 muxes, 283
carry XORs, 16 block RAMs, 68 IO tiles, 24 clock buffers, the DCMs, the
DNA port and the ICAP (the ICAP was added to the design model with the
peripherals block: `netlist2v.py` had tied its readback to 0 and dropped
its inputs, so the twelve registers that drive it were dead and
uncounted).

What the PicoBlaze block settled: the core is stock KCPSM3 (two cycles per
instruction, the ALU as three partial-result registers OR-ed together, the
stack pointer counting up and down across the two phases), the
instruction register in front of it is clocked on the falling edge and
picks bank 1 or 2 by the port C8 bit, in_port arrives through eight
falling-edge registers outside the block, and the interface is otherwise
KCPSM3's own: pc, port_id, out_port, read/write strobes, interrupt and
its ack.

What the SD block settled: the controller is Czerski's 2013 version
(https://github.com/mczerski/SD-card-controller), unchanged in this module
apart from what synthesis did to it; the Wishbone side lives in the mode
clock domain and crosses into the SD clock domain through the source's
two-flop synchronizers; `cmd_dat_reg` is the pad's input register and
`cmd_out_o`/`cmd_oe_o` are registered again in the pad's output cells.
The command master's timeout register and watchdog are 16 bits (the
register file never sets the upper byte), and its busy input is the DAT0
pad inverted: the card holds DAT0 low while busy.

What the data host settled: it is the source at revision bf94521b (2013:
the abort from every state, a three-bit crc_status), built with
`BLKSIZE_W` 10 and `BLKCNT_W` 8, so the transfer counter is 14 bits and
the block count 8. The synthesis made its FSM binary (IDLE 000, WRITE_DAT
001, WRITE_CRC 101, WRITE_BUSY 010, READ_WAIT 100, READ_DAT 011), kept
only the two bits of `blksize_reg` the byte-alignment update reads, and
dropped their reset. One thing is not in the source: in 4-bit mode the
cycle count is `((blksize | 4) << 1) + 2`, as if bit 2 of the block size
were always set; harmless for the sizes used (8n - 1 bytes), origin
unknown. Around the block: `data_in` is the transmit buffer's read port
(block RAM X3Y9) and `data_out` feeds the receive buffer's write port
(X3Y1) directly, `we` is that RAM's write enable, and `rd`/`we` step the
FIFOs' pointers; the DAT pads take the next values of
`DAT_dat_o` and `DAT_oe_o` into their own output registers, and the DAT2
pad is input only.

What the data master settled: the synthesis merged it with the transfer
trigger (`sd_data_xfer_trig`) and kept both FSMs' source codes; the
timeout is 8 bits (`DATA_TIMEOUT_W`); the data interrupt status register
is the source's, each flag a flip-flop enabled by "set or reset" with the
inverted reset as its data (missed at first, see the correction above);
the command start reaches the trigger as the two sync taps of the source's monostable
crossing; the command master's `int_status_cc` and `cmd_int_n` LUTs feed
the trigger, so they stay in that block. The buffer flags it watches
(`tx_fifo_full`, `tx_fifo_empty`, `rx_fifo_full`) come from the source's
own FIFOs (below), and `tx_fifo_full` is a Game Boy-domain register read
without a synchronizer, as in the source.

What the divider and the crossings settled: the SD clock is the source's
divider on the mode clock, with no reset anywhere (the controller's
`wb_rst` is tied off throughout), toggling every `divider + 1` cycles into
the clock buffer and the SD CLK pad. The registers cross into the SD
domain without resets, some in the source's two stages (argument, block
count, data timeout) and the rest in one (command, command timeout, block
size, bus width, byte alignment, software reset); the command's bits 7:5
do not cross at all (7 is unused, 6:5 go to the data master's trigger).
The responses and the two interrupt status registers cross back in two
stages.
The three write pulses cross as the source's toggles, each flipped by a
rising-edge detect in the register file (two mode-domain flags), and the
third of them is the data interrupt reset, for the status register in
the data master block. The mode-domain sources of all of these (`*_m`) are the
register file (below).

What the FIFOs settled: the buffers around the data host are not EZ
Flash's own but the source's `sd_fifo_filler` FIFOs, two instances of
the OpenCores `generic_fifo_dc_gray` with `aw` 4 (16 words of 32 bits:
block RAMs X3Y1 for rx and X3Y9 for tx), with the filler's Wishbone
master on their other side (the filler paragraph). Each side has a 5-bit
binary pointer for its memory port and a gray copy latched by the same
enable (the top bit is one register for both), takes the other side's
gray pointer through one flip-flop, and computes its flag as the source
does: full from the binary pointers with the top bit inverted, empty
from the gray ones, each "now, or after this access". The FIFO reset is
the filler's: software reset or no transfer started, so the pointers
clear between transfers; its two-stage release synchronizer survives
(merged for the two FIFOs), and so does the clear synchronizer with
`clr` tied to 0, as a two-cycle clear after configuration that the reset
chain covers anyway. The level outputs and their registers are gone. The
mode-clock side (the other two pointer pairs, X13Y14..X16Y10 and
X16Y5..X17Y7, and their flags) is in the filler block.

What the register file settled: it is the source's `sd_controller_wb` at
its 2013 revision, which writes the registers without byte enables and
whose read mux zero-extends each register and holds on an undecoded
address (the 2019 revision clears the output first; the hardware holds).
Its Wishbone master is the PicoBlaze: four port registers hold the data
word, one the address, one the strobe (`stb & cyc` in one) and one the
write flag, all in the PicoBlaze's clock domain and read from the mode
domain without synchronizers. The widths are EZ Flash's (`sd_defines.h`
edited: command timeout 16, data timeout 8, block size 10, block count
8); the voltage register still reads 3300 and the capabilities 0; there
is no reset, so the block size's reset value of 511 is gone. The three
write pulses go through the top level's `sd_edge_detect` instances (two
registers each, the crossings' `<pulse>_m[1:0]`). The source's `int_cmd`
is gone, unused; its `int_data` is kept in a register of EZ Flash's own,
with one more register behind it (`X15Y19_S2`, outside the block). The
`dma_addr` register is the full 32 bits: bits 1:0 cross as the byte
alignment and bits 22:2 are the FIFO filler's start address.

What the filler settled: the source's `sd_fifo_filler` is all there on
the mode clock, less its Wishbone data path, which is the block RAMs'
own: `wbm_cyc_o`, `wbm_stb_o` and `wbm_we_o` as the source has them, the
`fifo_rd_reg`/`fifo_rd_ack` handshake that spaces the rx FIFO's reads,
and the address counter, 21 bits (`wbm_adr_o[22:2]`, the word address;
nothing reads the bits above 22), loaded from `dma_addr` while no
transfer runs and stepped by one word per acknowledge. The acknowledge
is EZ Flash's: a two-bit counter that answers every strobe on its third
cycle, so each word takes three mode cycles. The rx FIFO's read port
(X3Y1) writes the 2 KB buffer X3Y5 at that address, and X3Y5's other read
feeds the tx FIFO's write port (X3Y9); the pSRAM path takes the address
and write enable into the memory clock domain through registers outside
the block. The FIFO halves are the source's read and write sides as on
the SD side (pointer pairs, one-stage sync, flags "now or after this
access", the reset synchronizer on the SD side's FIFO reset), and the
clear synchronizer's asynchronous set became a plain data input of the
constant-0 LUT it is tied to. `en_rx_i`/`en_tx_i` are the data master's
registers read straight from the SD clock domain, as in the source.

What the ports settled: the firmware's port map (re/stage0/docs/picoblaze.md)
is the hardware's, write for write and read for read, including the
bank select on C8 that the notes had only inferred. Writes land one cycle
after the strobe, while port_id and out_port still hold. The SD bridge is
EZ Flash's own: INPUT from a port below A0 loads that address and starts
a Wishbone read, OUTPUT to 70 starts a write and the OUTPUT after it names
the register, the strobe is set with the address and held until the
acknowledge, the read data is captured into 32 registers that 70-73 read,
and reading the selected register's port returns the done flag in bits
1:0, the ack the firmware polls for. The loader's address is 14 bits,
staged by E0 and E1 and committed by E3 (E2 is unused); the table index
is 7 bits into block RAM X3Y21, whose other port the Game Boy writes. B9
reads a constant 1, so the RTC refresh in the idle loop runs always; D1
reads the ICAP output bit-reversed. The I2C output register (EC) and the
ICAP writes (D1, D2) are not in the PicoBlaze's clock domain and are
elsewhere.

> **Correction (2026-10-28, with the peripherals block).** The last
> sentence was wrong: both are on the processor clock. The EC register is
> the SCL and SDA pads' tristate flip-flops in their IO tiles, which the
> block decomposition never sees, and the D1/D2 registers were invisible
> because the design model had no ICAP primitive, so nothing read them
> and they were pruned as dead. The Next list and the memory note
> inherited the error; `pb_periph` below has the facts.

What the memory path settled: the 2 KB buffer (X3Y5) is at $A000-$BFFF in
kernel mode when $7FC0's low nibble is 0 and $7F30 bit 0 is set (the bit
the kernel writes before sector reads and writes), with the Game Boy's
address and data pads on the port directly and a write on /WR low. The
ROM load path is separate from the buffer: every word the filler takes
from the rx FIFO is latched with the filler's address into the memory
clock, a rising edge of the filler's write enable starts a 16-cycle
counter on the system clock, and that counter presents the word as four
bytes, top byte first, each with a strobe low for its first two cycles;
the counter's upper bits and the strobe go out to the pSRAM control
logic, which is not carved yet. On the pins, while the loader runs (port
EF, through its 2x-domain copy), the pSRAM word address is the filler's
word address ORed with the loader's destination in 512-byte units (not
added: a run must not cross into the bits the destination sets), and the
data pins carry the byte; otherwise both carry the Game Boy's own. Only
six bits of the destination go through here; the rest select the pSRAM
page elsewhere.

What the controller settled: the page above A13 is byte-address bits
22:15, one 9-bit bank vector read one bit apart by the two chips: for
U9 the ROM bank ($2000 with $3000's bit on top) at 16 KB a bank, for U4
the save page ($4000 in kernel mode, the MBC logic's bank in game mode)
one bit higher, since the save window is 8 KB wide in a 16 KB page; the
MBC1 multicart folds its RAM bits into bits 1:5 of a $4000-$7FFF
access, and the loader's address replaces the whole vector while it
runs. The page is registered twice on the fast clock, sampled on the falling edge when it holds still,
and when it differs from the last value sent, shifted MSB first into the
74HC595 over eight clocks and latched; a bank of all ones in game mode
and the header checksum address $x14D are special cases, the latter
served from a register. The chip selects: U9 for $0000-$7FFF (and the
$7FC0=1 window), U4 for the save window, neither during a load or a
config-flash operation, when the address pins are tristated. The write
enable, /LB and /UB follow /WR and A0 for the Game Boy and the byte
sequencer during a load. The MBC1 multicart keeps four registers of its
own. The game-mode registers were first named by how they are written,
not by what the kernel calls them; the register block below settles
what they are. The P51 output latch (A13 during a load) is a latch and
stays outside.

Correction (2026-10-28, with the register block): the controller's
input `gm_wr_d0` was described as bit 0 of the last game-mode write. It
is the MBC1 mode bit, written only at $6000-$7FFF when the type is MBC1
or the multicart, and is now `mbc1_mode` in both blocks; the
controller's use of it (mode 0 keeps the save window on page 0) was
right.

What the data bus settled: the FPGA drives D0-D7 whenever /WR is high
except at $C000-$DFFF, as the simulation had found. A read returns, in
order: $01 while the loader runs (the status the kernel polls); in the
sector buffer window, $E1 until the $7FB4 command has been taken, $01
while $7F30 bit 1 is set, else the buffer's byte; in kernel mode with
$7F32 bit 3 set, below $8000, stage1 from block RAM bit planes, one bit
per RAM, or bytes from block RAM X19Y17 one page up; $04 at $7FC0=4 and
the flash writer's busy flag at $7FC0=5; in the register window ($7FC0
6, 7 or 8 and up in kernel mode, the bank register at all ones with RAM
enabled in game mode) the seven RTC values the PicoBlaze sends: at
offsets $08-$0E in kernel mode (seconds, minutes, hours, days, weekday,
month, year; $FF elsewhere in the window) and in game mode the MBC3
way, by the value written to $4000, with $08-$0B converted from the
PCF8563's BCD to binary by the small adder chain, $0C a constant 1 for
the day counter's high byte, anything else $FF; the header checksum
register at $014D in game mode, its bit 7 straight from the data pad's
input register; and the pSRAM's data pins otherwise. The module is
written as that precedence of cases. Its proof takes the window
decode's three stages as consistent with the address and mode bits,
which is how `sd_mem_path` makes them.

Correction (2026-10-28, with the register block): the buffer window's
$E1 lasts from the $7FB4 write until the transfer's data interrupt, not
"until the command has been taken": the flag the $7FB4 write clears is
set again by the interrupt, asynchronously. The data bus module's
comment says so now.

What the register block settled: the register map in
re/stage0/docs/design.md is the hardware's, bit for bit, and a few
registers it did not have are the four flag bits: $7FB4's bit 7 is kept
as the command's direction (two flip-flops, read and write), $7FD0 bit
0 is the RTC set's go and $7FE0 bit 7 the soft reset request, and the
lock write ($7FF0=$E4) clears all four. Every $7Fxx write goes through
the unlock state; most are also blocked for the one cycle after /RESET
falls (`rst`), when the mode registers ($7F32's two bits, $7F30 bit 0,
$7FC0, the MBC1 mode and high bits, the multicart's bits) are reset
through the slices' asynchronous SR, the first block where that
mattered to the proof. The bank registers: in kernel mode $2000-$2FFF
is the ROM bank, $3000-$3FFF its bit 8, $4000-$5FFF the $4000 register,
and offsets $A008-$A00E of the register window take the seven RTC
values to set, in the order the window reads them back. In game mode
the writes go through the MBC the type names: MBC1 takes five bank bits
at $2000-$3FFF and two at $4000-$5FFF (kept in `mbc1_hi`, folded into
the bank in mode 0, the RAM bank in mode 1), the mode at $6000-$7FFF;
MBC2 takes four bits at $2100-$21FF unmasked; MBC3 seven bits unmasked,
and at $4000-$5FFF the RAM bank ($00-$03) or the RTC select ($08-$0C),
which sets the bank register to all ones for the data bus's register
window; MBC5 eight bits at $2000-$2FFF, bit 8 at $3000-$3FFF and four
RAM bank bits; the multicart has its own four-bit $2000 register and
three bits derived from the MBC1 ones, and the plain ROM bank holds.
The ROM bank mask ($7FC1/$7FC2) applies to MBC1 and MBC5 only, the RAM
bank mask ($7FC4) to all three RAM banks. The RAM enable is $0A written
to $0000-$1FFF for types 1-5 (MBC2 with A8 clear). Its proof takes the
shared decodes (the address terms from `gb_data_out`, `unlock` and
`psram_ctrl`, the type terms from `psram_ctrl`) as the functions those
blocks make of the bus and of this block's own type register.

What the peripherals block settled: the ICAP is bit-banged like the SPI
flash. OUTPUT to D1 loads its eight data bits (bit-reversed, out_port
bit 7 on I[0], the order the readback on D1 undoes), OUTPUT to D2 its
clock, CE and WRITE in bits 0-2, each a plain register on the processor
clock wired to the primitive. The I2C lines are open drain: an OUTPUT to
EC clocks out_port bits 0 and 1 into the SCL and SDA pads' tristate
flip-flops, and the pads drive 0 when enabled. The SPI flash shares the
pSRAM address pins: SCK rides on A11 (P53) and MOSI on A12 (P46) whenever
$7FD2's flash bit is set or neither pSRAM is selected, the address
otherwise, and that address is U9's word address (byte bit 12 on A11,
A13 or the bank's bit 0 on A12) or U4's byte address (bits 11 and 12
through the window remap), the same split the lower pins make in the
not-yet-claimed muxes beside them. The Device DNA port has no logic of
its own: its four inputs are port D3's bits straight from the ports
block. The interrupt source lives on the 2x clock: five request flags
from `gb_regs` (sector read and write from $7FB4, the ROM load from
$7F36, the RTC set from $7FD0, the flash mode from $7FD2) go through
two-stage synchronizers, and a rising edge of any of them sets the
interrupt and loads port B5's bits 7:3 with which flags rose (read,
write, load, RTC set, flash), the mapping the firmware notes had only
observed. The core's acknowledge clears the interrupt synchronously and
wins over a request in the same cycle. Only a rising edge counts, so a
flag that is already set raises nothing until something clears it; the
lock write ($7FF0=$E4) that the kernel issues right after every command
(`DiskRead_B2`, `DiskWrite_B2`) is what does that.

What the RTC bridge settled: the seven readings the register window
serves are plain copies on the 2x clock, one per PCF8563 register (2
seconds, 3 minutes, 4 hours, 5 days, 6 weekdays, 7 months, 8 years; the
data bus block's inputs are now named after them instead of by
position). A copy loads the port EE register whenever any OUTPUT's
strobe comes while port ED holds its index, so in the firmware's loop
(OUTPUT index to ED, OUTPUT value to EE, then the I2C acknowledge's
OUTPUTs) the EE write's own strobe first loads the previous reading and
the acknowledge's first OUTPUT loads the right one, a few processor
cycles later. The RTC set path is the mirror: port F0 selects one of the
seven $A008-$A00E registers, a registered mux on the 2x clock follows it
one cycle later (the firmware's NOP between OUTPUT F0 and INPUT B6 is
for that), and indices outside 2-8 hold the last value.

What the soft reset block settled: the $7FE0 request flag goes through
a two-stage synchronizer on the 2x clock, and its rising edge
asynchronously clears a 16-bit counter on the inverted 2x clock together
with the reset drive. The counter counts up to $FFFF and stops there,
and the cycle after it arrives the drive is set again, so the drive is
low for 65536 falling edges of the 2x clock. `psram_ctrl` ANDs it with
the console's own /RESET onto P62. The drive starts high, an initial
value the structural proof cannot check.

What the bus block settled: the four page bits the data bus block's
stage1 read uses are copies of the controller's pg15 and A13 terms and
of the remapped A12 and A11, registered on the 2x clock while that read
is enabled, so the earlier `bank_q_a`/`bank_q_b` are a12_pass_q and
a11_pass_q now. The window remap clears address bits 11 and 12 in kernel
mode at $8000 and above except in the loader's table window ($A000 with
$7FC0 = 2 and $7F36 bit 0) and in window modes 1 and 3 there. The lower
address pins A1-A10 carry the next address bit up for a U9 (word) access
and the bit itself for U4's byte address, A10's being the remapped A11,
which completes the word/byte split the peripherals block found on A11
and A12. The byte ROM X19Y17 reads when the stage1 read is enabled, the
page bit is set and the remapped A11-A13 are 0; the eight bit-plane
block RAMs read when the page bit is clear; the table block RAM X3Y21 is
enabled in its window and written there on /WR. The data pads' input
registers, which hold the sector count and command bit for port B4 and
the checksum register's bit 7, clock on the $7FB4 write. The /RESET
copy starts high, an initial value the proof cannot see.

What the last two blocks settled: the PicoBlaze's clock is the system
clock gated by a LUT, on in kernel mode and in game mode only when the
RTC flag ($7F37 bit 7) is set, so the processor stands still in a plain
game; the ROM load's byte sequencer clock is the fx clock gated by
kernel mode at its buffer directly. The 74HC595's shift clock on P35 is
the inverted fx clock while the controller's serializer runs. The DCM
resets itself while its CLKFX has stopped and it is unlocked. The $7Fxx
write clock is /WR | A15 and the other write clock the /WR pad itself.
The fifteen constant LUTs tie block RAM, clock buffer and DCM pins and a
few inputs of other blocks. The one slice latch is a second latch of
the A13 mux beside P51's IO-tile latch, with the same set, clear and
gate; it keeps the decoded gate polarity (transparent while the flash
bit is 1) where the generator inverts the IO tile's, and the hardware
check design.md owes for that polarity covers both.

## The top level

`scripts/fpga/mktop.py` stitches the blocks into `rtl/fw4_top.v`: a
module `fw4_logic` that instantiates the twenty-two blocks and has as
ports the nets crossing between the slice logic and everything else, and
`fw4_top`, which wraps it with the 114 primitives (block RAMs, IO tiles,
clock buffers, DCMs, DNA port, ICAP) copied from design.v as wired there,
under the pads as ports. Blocks connect to each other by the design's net
names, so a block's names only have to suit that block.

`scripts/fpga/prove-top.sh` proves it against design.v in two steps that
compose with the block proofs and the bel check:

- `wiring`: a block of every live slice bel, carved flat, against
  `fw4_logic` over name-free carved references of the blocks. The same
  cells on both sides; what it proves is the stitching. 7,282 signals,
  about a minute.
- `rtl`: `fw4_logic` over the named references (what equiv.sh proves each
  readable module against) against `fw4_logic` over the readable modules,
  flattened with the same hierarchy so every register matches under its
  path. 4,314 signals: 4,184 by the structural passes, the other 130
  (127 in `sd_cmd_serial`) by temporal induction under the modules'
  invariants, and then every invariant, the env_ ones included since
  their inputs are other blocks' outputs here, proven on the reference
  from reset by induction. About three and a half minutes.

With check-bels.sh (design.v's slices equal their bels) that chain makes
`fw4_top` equivalent to design.v: its primitives are design.v's lines,
byte for byte.

`fw4_top` also runs in re/stage0/sim's testbench in design.v's place
(`re/stage0/sim/topsim.sh`, verilator): a full boot with the flash and
SD card models and stage1's sector read through the window at 31 ms.
The two logs are identical line for line, timestamps included: 1,003
timed events, among them 885 PicoBlaze first executions, 98 flash and
17 SD card transactions, the sector matching card.img byte for byte,
and the same pins toggling the same number of times. One allowance
makes that so: the design.v run is built with `NO_SLICE_GSR`
(`re/stage0/sim/s3prims.v`), which lets the slice model's flip-flops
start from their INIT values at time 0 as the readable registers do,
instead of holding them under GSR for the first 100 ns of start-up.
Without it the readable top runs a constant 20 ns ahead from the second
event on, and nothing else differs. The readable top also simulates a
quarter faster.

## Next

- The P51 latch gate polarity, a hardware check, for the IO tile's latch
  and the slice latch both.
- Marek Czerski's `sdc_controller` (OpenCores), with a published source to
  compare against.
