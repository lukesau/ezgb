// After a kernel load and stage1's kernel handoff, write a series of ROM
// bank numbers to $2000 and snapshot the whole design after each (via
// snap.v), then read $4000 so the FPGA reloads the 595. bankfind.py then
// looks for nets that equal bits of the written bank.
`ifndef GB_START_NS
`define GB_START_NS 31000000
`endif
`ifndef LOAD_NS
`define LOAD_NS 26000000
`endif
task fpga_set(input [15:0] r, input [7:0] v);
    begin gb_write(16'h7F00, 8'hE1); gb_write(16'h7F10, 8'hE2); gb_write(16'h7F20, 8'hE3);
          gb_write(r, v); gb_write(16'h7FF0, 8'hE4); end
endtask
reg [7:0] lcmd [0:511];
reg [7:0] bv [0:7];
integer li, bi;
reg [7:0] lq;
reg [7:0] rb [0:3];
initial begin
    bv[0] = 8'h01; bv[1] = 8'h02; bv[2] = 8'h03; bv[3] = 8'h05; bv[4] = 8'h0A; bv[5] = 8'h15; bv[6] = 8'h2C; bv[7] = 8'h53;
    $readmemh("loadcmd.hex", lcmd);
    #(`GB_START_NS);
    fpga_set(16'h7FC0, 0);
    fpga_set(16'h7FC0, 2);
    fpga_set(16'h7F36, 1);
    for (li = 0; li < 512; li = li + 1) gb_write(16'hA000 + li, lcmd[li]);
    fpga_set(16'h7F36, 3);
    #(`LOAD_NS);
    fpga_set(16'h7F36, 0);
    fpga_set(16'h7FC0, 0);
    gb_write(16'h2000, 8'h01);
    gb_write(16'h3000, 8'h00);
    gb_write(16'h7F00, 8'hE1); gb_write(16'h7F10, 8'hE2); gb_write(16'h7F20, 8'hE3);
    gb_write(16'h7F31, 8'h00); gb_write(16'h7F32, 8'h80);
    gb_write(16'h7FF0, 8'hE4);
    #10000;
    for (bi = 0; bi < 8; bi = bi + 1) begin
        gb_write(16'h2000, bv[bi]);
        #2000; snap.snapshot(bi);
        gb_read(16'h0000, lq);
        $display("%t gb: bank %h, $0000 reads %h (595=%h P51=%b)", $time, bv[bi], lq, tb.bank, tb.P51);
        for (li = 0; li < 4; li = li + 1) begin gb_read(16'h4000 + li, rb[li]); end
        $display("%t gb: bank %h, $4000 reads %h %h %h %h (595=%h P51=%b)", $time, bv[bi], rb[0], rb[1], rb[2], rb[3], tb.bank, tb.P51);
    end
end
