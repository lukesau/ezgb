// The clocks and ties, EZ Flash's own: the few LUTs that sit on clock
// buffers, the DCM and constant pins. Combinational only.
//
//   - pb_clk_run gates the PicoBlaze's clock: global buffer X0Y17 [0]
//     passes the system clock (X13Y0 [2]) while it is set and a constant
//     0 otherwise, so the processor runs in kernel mode and in game mode
//     only when the RTC flag ($7F37 bit 7) is set, for MBC3 clock games
//   - sh_clk_run gates the 74HC595's shift clock on P35 (X25Y17 [7]):
//     the inverted fx clock (clk_fx_n) while the controller's serializer
//     runs, 0 otherwise
//   - dcm_rst resets DCM X13Y1 while its CLKFX has stopped (STATUS[2])
//     and it is not locked, the usual DCM reset circuit; its phase-shift
//     inputs are tied to 0 (gnd[9])
//   - wr_a15_n is /WR | A15, the source of the $7Fxx write clock (X13Y33
//     [1]): it rises at the end of a write below $8000. The other write
//     clock (X13Y33 [0]) is the /WR pad itself
//   - gnd[14:0] are the constant-0 LUTs: 0 the PicoBlaze clock buffer's
//     other input (and block RAM X3Y17's ADDRB), 1 and 8 inputs of the
//     command master's logic, 2 and 5 the program block RAMs' write
//     enables (X3Y25, X3Y29), 3 the rx block RAM X3Y1's spare pins, 4
//     and 7 the tx block RAM X3Y9's, 6 an input of the register file's
//     logic, 9 the DCM's PSEN/PSINCDEC, 10, 11, 13 and 14 the stage1
//     block RAMs' spare pins (X19Y5-X19Y29), 12 the shift clock buffers'
//     other input
//
// Block: stage0/blocks/clocks.blk.

module clocks (
    input kernel_mode,
    input rtc_flag,                 // $7F37 bit 7
    input sh_run, sh_done,          // the serializer (psram_ctrl)
    input a15, wr_n,
    input clk_fx,
    input dcm_locked, dcm_status2,
    output pb_clk_run,
    output sh_clk_run,
    output dcm_rst,
    output wr_a15_n,
    output clk_fx_n,
    output [14:0] gnd
);
    assign pb_clk_run = kernel_mode | rtc_flag;
    assign sh_clk_run = sh_run & !sh_done;
    assign dcm_rst = dcm_status2 & !dcm_locked;
    assign wr_a15_n = wr_n | a15;
    assign clk_fx_n = !clk_fx;
    assign gnd = 15'd0;
endmodule
