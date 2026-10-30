// SD error recovery (docs/sd-error-recovery.md): two sector reads, a sector
// write, another read, then the RTC window's weekday tag at $A00C. Run with
// the SD model's fault plusargs (+SD_BAD_READS, +SD_BAD_WRITES, +SD_DROP_CMD)
// to check that each fault is retried and the data still comes back right.
// +define+GB_TEST=\"gb_sdfault.vh\"
`ifndef GB_START_NS
`define GB_START_NS 31000000
`endif
task fpga_set(input [15:0] r, input [7:0] v);
    begin gb_write(16'h7F00, 8'hE1); gb_write(16'h7F10, 8'hE2); gb_write(16'h7F20, 8'hE3);
          gb_write(r, v); gb_write(16'h7FF0, 8'hE4); end
endtask
task issue(input [31:0] lba, input [7:0] op);
    begin
        gb_write(16'h7F00, 8'hE1); gb_write(16'h7F10, 8'hE2); gb_write(16'h7F20, 8'hE3);
        gb_write(16'h7FB0, lba[7:0]); gb_write(16'h7FB1, lba[15:8]);
        gb_write(16'h7FB2, lba[23:16]); gb_write(16'h7FB3, lba[31:24]);
        gb_write(16'h7FB4, op);
        gb_write(16'h7FF0, 8'hE4);
    end
endtask
`ifdef PC_BRAM
// rtc_dump entries and weekday-7 stores (FW5-0918 patch addresses)
integer n_dump = 0, n_w7 = 0, n_gc = 0;
always @(tb.dut.`PC_BRAM.ADDRA[13:4]) begin
    if (tb.dut.`PC_BRAM.ADDRA[13:4] == 10'h323) begin n_dump = n_dump + 1; $display("%t gb: rtc_dump", $time); end
    if (tb.dut.`PC_BRAM.ADDRA[13:4] == 10'h3dd) n_w7 = n_w7 + 1;
    if (tb.dut.`PC_BRAM.ADDRA[13:4] == 10'h03c && n_gc < 3) begin n_gc = n_gc + 1; $display("%t gb: game_clock", $time); end
end
integer n_pc;
initial begin
    #(`GB_START_NS);
    for (n_pc = 0; n_pc < 14; n_pc = n_pc + 1) begin #500000; $display("%t gb: pc %h", $time, tb.dut.`PC_BRAM.ADDRA[13:4]); end
end
`endif
reg [7:0] fimg [0:511];
reg [7:0] fq;
integer fi, fpolls, fbad, ffd, fr, ffail;
task read_check(input [31:0] lba);
    begin
        $display("%t gb: read %0d", $time, lba);
        fpga_set(16'h7F30, 1);
        issue(lba, 8'h01);
        fpga_set(16'h7F30, 3);
        fpolls = 0; gb_read(16'hA000, fq);
        while (fq == 8'hE1 && fpolls < 20000) begin fpolls = fpolls + 1; #20000; gb_read(16'hA000, fq); end
        fpga_set(16'h7F30, 1);
        ffd = $fopen("card.img", "rb"); fr = $fseek(ffd, lba * 512, 0); fr = $fread(fimg, ffd); $fclose(ffd);
        fbad = 0;
        for (fi = 0; fi < 512; fi = fi + 1) begin gb_read(16'hA000 + fi, fq); if (fq !== fimg[fi]) fbad = fbad + 1; end
        fpga_set(16'h7F30, 0);
        if (fpolls >= 20000 || fbad) ffail = ffail + 1;
        $display("%t gb: read %0d %s after %0d polls (%0d bytes differ)", $time, lba,
                 fpolls >= 20000 ? "TIMED OUT" : fbad ? "MISMATCH" : "ok", fpolls, fbad);
    end
endtask
task write_one(input [31:0] lba);
    begin
        fpga_set(16'h7F30, 1);
        fpga_set(16'h7F30, 3);
        for (fi = 0; fi < 512; fi = fi + 1) gb_write(16'hA000 + fi, fi * 7 + 3);
        $display("%t gb: write %0d, pattern i*7+3 (sum ff00)", $time, lba);
        issue(lba, 8'h81);
        // wait as DiskWrite_B2 does: $E1 until the data interrupt
        fpolls = 0; gb_read(16'hA000, fq);
        while (fq == 8'hE1 && fpolls < 20000) begin fpolls = fpolls + 1; #20000; gb_read(16'hA000, fq); end
        fpga_set(16'h7F30, 0);
        if (fpolls >= 20000) ffail = ffail + 1;
        $display("%t gb: write %0d %s after %0d polls", $time, lba, fpolls >= 20000 ? "TIMED OUT" : "done", fpolls);
    end
endtask
initial begin
    #(`GB_START_NS);
    ffail = 0;
    read_check(0);
    read_check(1);
    write_one(4000);
    #200000;
    read_check(2);
    #3000000;                                       // a few idle loops: rtc_dump runs
    // kernel mode, as stage1's hand-off leaves it: only there does the RTC
    // window serve the PicoBlaze's raw copies
    gb_write(16'h7F00, 8'hE1); gb_write(16'h7F10, 8'hE2); gb_write(16'h7F20, 8'hE3);
    gb_write(16'h7F31, 8'h00); gb_write(16'h7F32, 8'h80);
    gb_write(16'h7FF0, 8'hE4);
    fpga_set(16'h7FC0, 6);
    gb_read(16'hA00C, fq);
    fpga_set(16'h7FC0, 0);
    $display("%t gb: weekday byte %h: %s", $time, fq, (fq & 8'h07) == 8'h07 ? "dropped to half speed" : "full speed");
`ifdef PC_BRAM
    $display("%t gb: rtc_dump entered %0d times, weekday 7 stored %0d times", $time, n_dump, n_w7);
`endif
    $display("%t gb: %0d failure(s)", $time, ffail);
    $finish;
end
