// Stage1's kernel launch from the Game Boy side (docs/fpga-stage1.md): game
// mode, the load command (loadcmd.hex, from loadcmd.py) through the $7F36=1
// window, $7F36=3, then poll $A000 until the PicoBlaze reports done (>= 2).
// +define+GB_TEST=\"gb_load.vh\" +define+GB_START_NS=...
`ifndef GB_START_NS
`define GB_START_NS 31000000
`endif
task fpga_set(input [15:0] r, input [7:0] v);
    begin gb_write(16'h7F00, 8'hE1); gb_write(16'h7F10, 8'hE2); gb_write(16'h7F20, 8'hE3);
          gb_write(r, v); gb_write(16'h7FF0, 8'hE4); end
endtask
reg [7:0] lcmd [0:511];
integer li;
reg [7:0] rom0 [0:15];
reg [13:0] mpins;
integer lb, lr;
reg [7:0] banks [0:4];
initial begin banks[0] = 1; banks[1] = 2; banks[2] = 3; banks[3] = 5; banks[4] = 1; end
reg [7:0] lq;
initial begin
    $readmemh("loadcmd.hex", lcmd);
    #(`GB_START_NS);
    $display("%t gb: load, %0d-byte file at LBA %0d", $time,
             {lcmd[499], lcmd[498], lcmd[497], lcmd[496]}, {lcmd[7], lcmd[6], lcmd[5], lcmd[4]});
    fpga_set(16'h7FC0, 0);
    fpga_set(16'h7FC0, 2);
    fpga_set(16'h7F36, 1);
    for (li = 0; li < 512; li = li + 1) gb_write(16'hA000 + li, lcmd[li]);
    fpga_set(16'h7F36, 3);
    $display("%t gb: load started", $time);
    // The status read at $A000 comes from the pSRAM in game mode, so wait a
    // fixed time (`LOAD_NS) instead of polling, then hand off as stage1 does
    // and read ROM back through the FPGA
`ifndef LOAD_NS
`define LOAD_NS 26000000
`endif
    #(`LOAD_NS);
    fpga_set(16'h7F36, 0);
    fpga_set(16'h7F31, 0);
    fpga_set(16'h7F32, 0);
    gb_write(16'h2000, 8'h01);
    gb_write(16'h3000, 8'h00);
    fpga_set(16'h7FE0, 8'h80);
    #10000;
    $display("%t gb: handed off; reading ROM", $time);
    // read 8 bytes at $0000 and at $4000 under several ROM banks, with the
    // memory-side pins at the first byte of each
    for (lb = 0; lb < 5; lb = lb + 1) begin
        gb_write(16'h2000, banks[lb]);
        for (lr = 0; lr < 2; lr = lr + 1) begin
            for (li = 0; li < 8; li = li + 1) begin
                gb_read((lr ? 16'h4000 : 16'h0000) + li, lq); rom0[li] = lq;
                if (li == 0) mpins = {tb.P51, tb.P46, tb.P53, tb.P20, tb.P86, tb.P83, tb.P50, tb.P44, tb.P73, tb.P70, tb.P71, tb.P65, tb.P59, tb.P56};
            end
            $display("%t gb: bank %0d $%h: %h %h %h %h %h %h %h %h | A13..0=%b 595=%h ce=%b%b", $time, banks[lb], lr ? 16'h4000 : 16'h0000,
                     rom0[0], rom0[1], rom0[2], rom0[3], rom0[4], rom0[5], rom0[6], rom0[7], mpins, tb.bank, tb.P52, tb.P60);
        end
    end
end
