// Stage1's kernel launch and hand-off exactly as stage1/src/handoff.s does
// it: load command through the $7F36=1 window, $7F36=3, poll $A000 until it
// reads non-zero and then until it stops reading 1, then $7F36=0, $7FC0=0,
// ROM bank 1, $3000=0, $7F31=0/$7F32=$80. Then read ROM at $0000, $0100 and
// $4000 and report whether the pSRAM was selected for each read.
`ifndef GB_START_NS
`define GB_START_NS 31000000
`endif
task fpga_set(input [15:0] r, input [7:0] v);
    begin gb_write(16'h7F00, 8'hE1); gb_write(16'h7F10, 8'hE2); gb_write(16'h7F20, 8'hE3);
          gb_write(r, v); gb_write(16'h7FF0, 8'hE4); end
endtask
reg [7:0] lcmd [0:511];
integer li, polls;
reg [7:0] lq;
reg sel;
// was U9 selected at any point during the last read?
always #1 if (tb.P52 === 1'b0) sel = 1;
task rd(input [15:0] a);
    begin sel = 0; gb_read(a, lq);
          $display("%t gb: read $%h = %h  (595=%h P51=%b  a=%b b=%b m=%b gate=%b bankreg=%b%b%b%b%b%b%b%b)", $time, a, lq, tb.bank, tb.P51,
                   tb.dut.n_X11Y22_S3_YQ, tb.dut.n_X18Y8_S2_YQ, tb.dut.n_X17Y22_S2_YQ, tb.dut.n_X12Y23_S1_YQ,
                   tb.dut.n_X15Y26_S0_XQ, tb.dut.n_X17Y25_S2_XQ, tb.dut.n_X17Y25_S1_XQ, tb.dut.n_X15Y23_S0_XQ,
                   tb.dut.n_X18Y23_S3_XQ, tb.dut.n_X18Y23_S0_XQ, tb.dut.n_X17Y26_S1_XQ, tb.dut.n_X18Y24_S0_XQ); end
endtask
initial begin
    $readmemh("loadcmd.hex", lcmd);
    #(`GB_START_NS);
    fpga_set(16'h7FC0, 0);
    fpga_set(16'h7FC0, 2);
    fpga_set(16'h7F36, 1);
    for (li = 0; li < 512; li = li + 1) gb_write(16'hA000 + li, lcmd[li]);
    fpga_set(16'h7F36, 3);
    $display("%t gb: load started", $time);
    // stage1 fetches several instructions (the lock write, ld hl,$A000)
    // before its first poll; right after the command the window floats ($FF)
    // for about a cycle and a half while the FPGA switches it over
    #5000;
    polls = 0; gb_read(16'hA000, lq);
    while (lq == 0) begin polls = polls + 1; gb_read(16'hA000, lq); end
    $display("%t gb: status %h after %0d polls", $time, lq, polls);
    polls = 0;
    while (lq == 1) begin polls = polls + 1; #20000; gb_read(16'hA000, lq);
        if (polls % 200 == 0) $display("%t gb: status %h (%0d polls)", $time, lq, polls); end
    $display("%t gb: status %h, load done after %0d polls", $time, lq, polls);
    fpga_set(16'h7F36, 0);
    fpga_set(16'h7FC0, 0);
    gb_write(16'h2000, 8'h01);
    gb_write(16'h3000, 8'h00);
    gb_write(16'h7F00, 8'hE1); gb_write(16'h7F10, 8'hE2); gb_write(16'h7F20, 8'hE3);
    gb_write(16'h7F31, 8'h00); gb_write(16'h7F32, 8'h80);
    gb_write(16'h7FF0, 8'hE4);
    $display("%t gb: handed off", $time);
    rd(16'h0000); rd(16'h0001); rd(16'h0100); rd(16'h0101); rd(16'h4000); rd(16'h4001);
    gb_write(16'h2000, 8'h02); rd(16'h4000); rd(16'h4001);
    gb_write(16'h2000, 8'h05); rd(16'h4000);
end
