// The kernel's game launch (04:40xx-41xx in 1.04e): $7FC0=2, MBC type to
// $7F37, RAM bank mask to $7FC4, ROM bank mask to $7FC1/$7FC2, header
// checksum to $7FC3, the load through the $7F36 window, then $7F36=0,
// $7F31/$7F32=0, $2000=1, $3000=0 and $7FE0=$80 (console reset). After the
// reset pulse on P62, read the header and a few banks and compare them with
// the ROM file (rom.hex, the first 64KB).
`ifndef GB_START_NS
`define GB_START_NS 31000000
`endif
`ifndef MBC
`define MBC 8'h03
`endif
task fpga_set(input [15:0] r, input [7:0] v);
    begin gb_write(16'h7F00, 8'hE1); gb_write(16'h7F10, 8'hE2); gb_write(16'h7F20, 8'hE3);
          gb_write(r, v); gb_write(16'h7FF0, 8'hE4); end
endtask
reg [7:0] lcmd [0:511];
reg [7:0] rom [0:65535];
integer li, polls, bad, nrd;
reg [7:0] lq;
reg [15:0] cur_bank;
// game-mode state worth seeing beside every read
task rd(input [15:0] a);
    reg [7:0] want;
    begin gb_read(a, lq);
          want = rom[a < 16'h4000 ? a : {cur_bank[1:0], a[13:0]}];
          nrd = nrd + 1; if (lq !== want) bad = bad + 1;
          $display("%t gb: read $%h = %h want %h %s (595=%h P51=%b m=%b k=%b mem_a=%h)", $time, a, lq, want,
                   lq === want ? "ok " : "BAD", tb.bank, tb.P51, tb.dut.n_X17Y22_S2_YQ, tb.dut.n_X14Y20_S0_YQ, tb.mem_a); end
endtask
task setbank(input [7:0] b);
    begin gb_write(16'h2000, b); cur_bank = (b == 0) ? 1 : b;
          $display("%t gb: $2000=%h  bankreg=%b%b%b%b%b%b%b%b", $time, b,
                   tb.dut.n_X15Y26_S0_XQ, tb.dut.n_X17Y25_S2_XQ, tb.dut.n_X17Y25_S1_XQ, tb.dut.n_X15Y23_S0_XQ,
                   tb.dut.n_X18Y23_S3_XQ, tb.dut.n_X18Y23_S0_XQ, tb.dut.n_X17Y26_S1_XQ, tb.dut.n_X18Y24_S0_XQ); end
endtask
// 595 activity: count shift clocks per latch and the bits shifted
integer nsh; reg [31:0] shbits; reg p35, p24;
always #1 begin
    if (P35 === 1'b1 && p35 !== 1'b1) begin nsh = nsh + 1; shbits = {shbits[30:0], P33 === 1'b1}; end
    if (P24 === 1'b1 && p24 !== 1'b1 && $time > `GB_START_NS) begin
        $display("%t 595: latch after %0d shifts, bits %b (GB A=%h)", $time, nsh, shbits[15:0], tb.gb_a); nsh = 0; end
    p35 = P35; p24 = P24;
end
initial nsh = 0;
`ifdef SNAP
snap snap();
reg [7:0] sb [0:7];
initial begin sb[0] = 8'h01; sb[1] = 8'h02; sb[2] = 8'h03; sb[3] = 8'h05; sb[4] = 8'h0A; sb[5] = 8'h15; sb[6] = 8'h2C; sb[7] = 8'h33; end
`endif
reg p62;
always #10 begin if (P62 !== p62 && $time > `GB_START_NS) $display("%t P62 -> %b", $time, P62); p62 = P62; end
initial begin
    bad = 0; nrd = 0; cur_bank = 1;
    $readmemh("loadcmd.hex", lcmd);
    $readmemh("rom.hex", rom);
    #(`GB_START_NS);
    fpga_set(16'h7FC0, 2);
    fpga_set(16'h7F37, `MBC);
    fpga_set(16'h7FC4, 8'h03);
    fpga_set(16'h7FC1, 8'h3F);
    fpga_set(16'h7FC2, 8'h00);
    fpga_set(16'h7FC3, rom[16'h14D]);
    fpga_set(16'h7F36, 1);
    for (li = 0; li < 512; li = li + 1) gb_write(16'hA000 + li, lcmd[li]);
    fpga_set(16'h7F36, 3);
    $display("%t gb: load started", $time);
    #5000;
    polls = 0; gb_read(16'hA000, lq);
    while (lq == 0) begin polls = polls + 1; gb_read(16'hA000, lq); end
    $display("%t gb: status %h after %0d polls", $time, lq, polls);
    polls = 0;
    while (lq == 1) begin polls = polls + 1; #20000; gb_read(16'hA000, lq);
        if (polls % 200 == 0) $display("%t gb: status %h (%0d polls)", $time, lq, polls); end
    $display("%t gb: status %h, load done after %0d polls", $time, lq, polls);
`ifdef U9_DUMP
    u9.dump("u9.bin", `U9_DUMP);
`endif
    fpga_set(16'h7F36, 0);
    gb_write(16'h7F00, 8'hE1); gb_write(16'h7F10, 8'hE2); gb_write(16'h7F20, 8'hE3);
    gb_write(16'h7F31, 8'h00); gb_write(16'h7F32, 8'h00);
    gb_write(16'h7FF0, 8'hE4);
    gb_write(16'h2000, 8'h01);
    gb_write(16'h3000, 8'h00);
    gb_write(16'h7F00, 8'hE1); gb_write(16'h7F10, 8'hE2); gb_write(16'h7F20, 8'hE3);
    gb_write(16'h7FE0, 8'h80);
    gb_write(16'h7FF0, 8'hE4);
    $display("%t gb: reset into ROM", $time);
    // the console sits in reset while P62 is low
    #100; wait (P62 === 1'b1); #10000;
    $display("%t gb: out of reset", $time);
    rd(16'h0100); rd(16'h0101); rd(16'h0102); rd(16'h0103);
    for (li = 16'h0134; li < 16'h0150; li = li + 1) rd(li);
    rd(16'h0000); rd(16'h1234); rd(16'h3FFF);
    rd(16'h4000); rd(16'h4001); rd(16'h5555); rd(16'h7FFF);
`ifdef SNAP
    for (li = 0; li < 8; li = li + 1) begin
        setbank(sb[li]); #2000; snap.snapshot(li); rd(16'h4000); rd(16'h0100);
    end
`endif
    setbank(8'h02); rd(16'h4000); rd(16'h4001); rd(16'h6000);
    setbank(8'h03); rd(16'h4000); rd(16'h7FFE);
    setbank(8'h00); rd(16'h4000); rd(16'h4001);
    setbank(8'h01); rd(16'h4000); rd(16'h0100);
    $display("game reads: %0d, %0d wrong", nrd, bad);
    $finish;
end
