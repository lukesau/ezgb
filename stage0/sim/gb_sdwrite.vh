// The kernel's DiskWrite_B2 for one sector: $7F30=1 then 3, fill the $A000
// window with a pattern, LBA to $7FB0-B3 and $7FB4=$81 (bit 7 = write) in
// an unlock envelope, poll $A000 until it reads non-zero, $7F30=0. The SD
// model logs the block it receives (first bytes and a sum) to compare.
`ifndef GB_START_NS
`define GB_START_NS 31000000
`endif
`ifndef SD_LBA
`define SD_LBA 4000
`endif
task fpga_set(input [15:0] r, input [7:0] v);
    begin gb_write(16'h7F00, 8'hE1); gb_write(16'h7F10, 8'hE2); gb_write(16'h7F20, 8'hE3);
          gb_write(r, v); gb_write(16'h7FF0, 8'hE4); end
endtask
integer wi, wpolls;
reg [7:0] wq;
reg [15:0] wsum;
reg [31:0] wlba;
initial begin
    #(`GB_START_NS);
    wlba = `SD_LBA;
    fpga_set(16'h7F30, 1);
    fpga_set(16'h7F30, 3);
    wsum = 0;
    for (wi = 0; wi < 512; wi = wi + 1) begin gb_write(16'hA000 + wi, wi * 7 + 3); wsum = wsum + ((wi * 7 + 3) & 8'hFF); end
    $display("%t gb: sd_write(%0d), pattern i*7+3, sum %h", $time, wlba, wsum);
    gb_write(16'h7F00, 8'hE1); gb_write(16'h7F10, 8'hE2); gb_write(16'h7F20, 8'hE3);
    gb_write(16'h7FB0, wlba[7:0]); gb_write(16'h7FB1, wlba[15:8]);
    gb_write(16'h7FB2, wlba[23:16]); gb_write(16'h7FB3, wlba[31:24]);
    gb_write(16'h7FB4, 8'h81);
    gb_write(16'h7FF0, 8'hE4);
    wpolls = 0; gb_read(16'hA000, wq);
    while (wq == 8'h00 && wpolls < 5000) begin wpolls = wpolls + 1; #20000; gb_read(16'hA000, wq); end
    $display("%t gb: write status %h after %0d polls", $time, wq, wpolls);
    #100000;
    fpga_set(16'h7F30, 0);
    $finish;
end
