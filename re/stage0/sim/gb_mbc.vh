// Script-driven Game Boy bus test for the MBC and save-RAM logic. With
// +define+PRELOAD the pSRAMs start from tagged images (u9.img, u4.img), so no
// SD load is needed. ops.hex holds one op per line, TTAAAADD:
//   00 write DD to AAAA      01 read AAAA (logged as "R aaaa dd")
//   02 wait for the console reset (P62) to end   03 delay AAAA us
//   04 snapshot the design with tag DD (needs +define+SNAP and snap.v)
// At the end U4 is dumped to u4.out. mbctest.py writes the script and the
// images, and checks the log against its MBC model.
`ifndef GB_START_NS
`define GB_START_NS 31000000
`endif
`ifdef SNAP
snap snap();
`endif
reg [31:0] ops [0:4095];
// P62 drops while the $7FE0 write is still finishing, so latch the fall
reg rst_seen = 0;
always #10 if (P62 === 1'b0) rst_seen = 1;
integer oi;
reg [7:0] q;
initial begin
    for (oi = 0; oi < 4096; oi = oi + 1) ops[oi] = 32'hFFFFFFFF;
    $readmemh("ops.hex", ops);
    #(`GB_START_NS);
    rst_seen = 0;
    for (oi = 0; oi < 4096 && ops[oi] !== 32'hFFFFFFFF; oi = oi + 1) begin
        case (ops[oi][31:24])
            8'h00: begin gb_write(ops[oi][23:8], ops[oi][7:0]); $display("W %h %h", ops[oi][23:8], ops[oi][7:0]); end
            8'h01: begin gb_read(ops[oi][23:8], q); $display("R %h %h   p51=%b 595=%h", ops[oi][23:8], q, P51, bank); end
            8'h02: begin wait (rst_seen); wait (P62 === 1'b1); rst_seen = 0; #10000; $display("X reset done"); end
            8'h03: #(ops[oi][23:8] * 1000);
`ifdef SNAP
            8'h04: begin #2000; snap.snapshot(ops[oi][7:0]); end
`endif
        endcase
    end
    u4.dump("u4.out", 524288);
    $display("ops done: %0d", oi);
    $finish;
end
