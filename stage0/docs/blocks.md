# What each block is

What carving and proving each block of the FW4 design established about
the hardware. The blocks, their sizes and their proofs are listed in the
[README](../README.md#the-blocks); the Verilog is in [fw4/rtl](../fw4/rtl/).

Tile names such as `X3Y5` are positions on the chip, as the decode and the
[floorplan](https://lukesau.github.io/ezgb/floorplan/) show them.

## The PicoBlaze (`picoblaze`)

The core is stock KCPSM3 (two cycles per
instruction, the ALU as three partial-result registers OR-ed together, the
stack pointer counting up and down across the two phases), the
instruction register in front of it is clocked on the falling edge and
picks bank 1 or 2 by the port C8 bit, in_port arrives through eight
falling-edge registers outside the block, and the interface is otherwise
KCPSM3's: pc, port_id, out_port, read/write strobes, interrupt and
its ack.

## The SD command line (`sd_cmd_serial`, `sd_cmd_master`)

The controller is Czerski's 2013 version
(https://github.com/mczerski/SD-card-controller), unchanged in this module
apart from what synthesis did to it; the Wishbone side lives in the mode
clock domain and crosses into the SD clock domain through the source's
two-flop synchronizers; `cmd_dat_reg` is the pad's input register and
`cmd_out_o`/`cmd_oe_o` are registered again in the pad's output cells.
The command master's timeout register and watchdog are 16 bits (the
register file never sets the upper byte), and its busy input is the DAT0
pad inverted: the card holds DAT0 low while busy.

## The SD data host (`sd_data_serial`)

It is the source at revision bf94521b (2013:
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

## The SD data master (`sd_data_master`)

The synthesis merged it with the transfer
trigger (`sd_data_xfer_trig`) and kept both FSMs' source codes; the
timeout is 8 bits (`DATA_TIMEOUT_W`); the data interrupt status register
is the source's, each flag a flip-flop enabled by "set or reset" with the
inverted reset as its data;
the command start reaches the trigger as the two sync taps of the source's monostable
crossing; the command master's `int_status_cc` and `cmd_int_n` LUTs feed
the trigger, so they stay in that block. The buffer flags it watches
(`tx_fifo_full`, `tx_fifo_empty`, `rx_fifo_full`) come from the source's
own FIFOs (below), and `tx_fifo_full` is a Game Boy-domain register read
without a synchronizer, as in the source.

## The SD clock divider and the clock crossings (`sd_clock_divider`, `sd_crossings`)

The SD clock is the source's
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

## The FIFOs (`sd_fifos`)

The buffers around the data host are not EZ
Flash's but the source's `sd_fifo_filler` FIFOs, two instances of
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

## The SD register file (`sd_controller_wb`)

It is the source's `sd_controller_wb` at
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
is gone, unused; its `int_data` is kept in a register EZ Flash added,
with one more register behind it (`X15Y19_S2`, outside the block). The
`dma_addr` register is the full 32 bits: bits 1:0 cross as the byte
alignment and bits 22:2 are the FIFO filler's start address.

## The FIFO filler (`sd_fifo_filler`)

The source's `sd_fifo_filler` is all there on
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

## The PicoBlaze's ports (`picoblaze_ports`)

The firmware's port map (stage0/docs/picoblaze.md)
is the hardware's, write for write and read for read, including the
bank select on C8. Writes land one cycle
after the strobe, while port_id and out_port still hold. The SD bridge is
written by EZ Flash: INPUT from a port below A0 loads that address and starts
a Wishbone read, OUTPUT to 70 starts a write and the OUTPUT after it names
the register, the strobe is set with the address and held until the
acknowledge, the read data is captured into 32 registers that 70-73 read,
and reading the selected register's port returns the done flag in bits
1:0, the ack the firmware polls for. The loader's address is 14 bits,
staged by E0 and E1 and committed by E3 (E2 is unused); the table index
is 7 bits into block RAM X3Y21, whose other port the Game Boy writes. B9
reads a constant 1, so the RTC refresh in the idle loop runs always; D1
reads the ICAP output bit-reversed. The I2C output register (EC) and the
ICAP writes (D1, D2) are in the peripherals block.

## The SD memory path (`sd_mem_path`)

The 2 KB buffer (X3Y5) is at $A000-$BFFF in
kernel mode when $7FC0's low nibble is 0 and $7F30 bit 0 is set (the bit
the kernel writes before sector reads and writes), with the Game Boy's
address and data pads on the port directly and a write on /WR low. The
ROM load path is separate from the buffer: every word the filler takes
from the rx FIFO is latched with the filler's address into the memory
clock, a rising edge of the filler's write enable starts a 16-cycle
counter on the system clock, and that counter presents the word as four
bytes, top byte first, each with a strobe low for its first two cycles;
the counter's upper bits and the strobe go out to the pSRAM control
logic (the controller, below). On the pins, while the loader runs (port
EF, through its 2x-domain copy), the pSRAM word address is the filler's
word address ORed with the loader's destination in 512-byte units (not
added: a run must not cross into the bits the destination sets), and the
data pins carry the byte; otherwise both carry the Game Boy's. Only
six bits of the destination go through here; the rest select the pSRAM
page elsewhere.

## The pSRAM controller (`psram_ctrl`)

The page above A13 is byte-address bits
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
own. The P51 output latch (A13 during a load) is a latch and
stays outside.

## The Game Boy data bus (`gb_data_out`)

The FPGA drives D0-D7 whenever /WR is high
except at $C000-$DFFF,. A read returns, in
order: $01 while the loader runs (the status the kernel polls); in the
sector buffer window, $E1 from the $7FB4 write until the transfer's data interrupt, $01
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

## The Game Boy's registers (`gb_regs`)

The register map in
stage0/docs/design.md is the hardware's, bit for bit, and a few
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
MBC2 takes five bits at $2000-$3FFF with A8 set, unmasked; MBC3 seven bits unmasked,
and at $4000-$5FFF the RAM bank ($00-$03) or the RTC select ($08-$0C),
which sets the bank register to all ones for the data bus's register
window; MBC5 eight bits at $2000-$2FFF, bit 8 at $3000-$3FFF and four
RAM bank bits; the multicart has its own four-bit $2000 register and
three bits derived from the MBC1 ones, and the plain ROM bank holds.
The ROM bank mask ($7FC1/$7FC2) applies to MBC1 and MBC5 only, the RAM
bank mask ($7FC4) to all three RAM banks. The RAM enable is a low nibble of $A written
to $0000-$1FFF for types 1-5 (MBC2 with A8 clear). Its proof takes the
shared decodes (the address terms from `gb_data_out`, `unlock` and
`psram_ctrl`, the type terms from `psram_ctrl`) as the functions those
blocks make of the bus and of this block's type register.

## The PicoBlaze's peripherals (`pb_periph`)

The ICAP is bit-banged like the SPI
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
through the window remap), the same split the lower pins make (the bus block). The Device DNA port has no logic of
its own: its four inputs are port D3's bits straight from the ports
block. The interrupt source lives on the 2x clock: five request flags
from `gb_regs` (sector read and write from $7FB4, the ROM load from
$7F36, the RTC set from $7FD0, the flash mode from $7FD2) go through
two-stage synchronizers, and a rising edge of any of them sets the
interrupt and loads port B5's bits 7:3 with which flags rose (read,
write, load, RTC set, flash). The core's acknowledge clears the interrupt synchronously and
wins over a request in the same cycle. Only a rising edge counts, so a
flag that is already set raises nothing until something clears it; the
lock write ($7FF0=$E4) that the kernel issues right after every command
(`DiskRead_B2`, `DiskWrite_B2`) is what does that.

## The RTC bridge (`rtc_bridge`)

The seven readings the register window
serves are plain copies on the 2x clock, one per PCF8563 register (2
seconds, 3 minutes, 4 hours, 5 days, 6 weekdays, 7 months, 8 years). A copy loads the port EE register whenever any OUTPUT's
strobe comes while port ED holds its index, so in the firmware's loop
(OUTPUT index to ED, OUTPUT value to EE, then the I2C acknowledge's
OUTPUTs) the EE write's strobe first loads the previous reading and
the acknowledge's first OUTPUT loads the right one, a few processor
cycles later. The RTC set path is the mirror: port F0 selects one of the
seven $A008-$A00E registers, a registered mux on the 2x clock follows it
one cycle later (the firmware's NOP between OUTPUT F0 and INPUT B6 is
for that), and indices outside 2-8 hold the last value.

## The soft reset (`soft_reset`)

The $7FE0 request flag goes through
a two-stage synchronizer on the 2x clock, and its rising edge
asynchronously clears a 16-bit counter on the inverted 2x clock together
with the reset drive. The counter counts up to $FFFF and stops there,
and the cycle after it arrives the drive is set again, so the drive is
low for 65536 falling edges of the 2x clock. `psram_ctrl` ANDs it with
the console's /RESET onto P62. The drive starts high, an initial
value the structural proof cannot check.

## The Game Boy bus state (`gb_bus`)

The four page bits the data bus block's
stage1 read uses are copies of the controller's pg15 and A13 terms and
of the remapped A12 and A11, registered on the 2x clock while that read
is enabled. The window remap clears address bits 11 and 12 in kernel
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

## The clocks and the P51 latch (`clocks`, `p51_latch`)

The PicoBlaze's clock is the system
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
gate. Both are transparent while the flash bit is 0; the gate bit
decodes the other way, which ISE settles ([design.md](design.md)).
