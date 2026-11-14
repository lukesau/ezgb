// Console /RESET glitch during stage1's sd_read: read LBA 0 clean, then
// issue a read of LBA 1 as stage1/src/fpga.c does and pulse P61 low for
// GLITCH_LEN ns, GLITCH_AT ns after the $7FB4 write, while the Game Boy
// polls $A000 (stage1's DiskRead waits for it to leave $E1, with no
// timeout; here it gives up after POLL_MAX_NS). Then the sector is copied
// out and checked, and LBA 2 is read clean to see whether the card still
// answers. The SD model logs every command, so a card re-init shows as
// CMD0; the PC monitor counts PicoBlaze restarts (PC back to 0).
// +define+P61_GLITCH +define+GB_TEST=\"gb_glitch.vh\"
// plusargs: +GLITCH_AT=ns +GLITCH_LEN=ns (+GLITCH_AT=-1: no pulse), +START=ns (when the Game Boy starts, default GB_START_NS), +PRE=ns (wait before the
// glitched read), +HOLD=ns (wait before the last sector read, e.g. to cover a long pulse)
`ifndef GB_START_NS
`define GB_START_NS 31000000
`endif
`ifndef POLL_MAX_NS
`define POLL_MAX_NS 80000000
`endif
task fpga_set(input [15:0] r, input [7:0] v);
    begin gb_write(16'h7F00, 8'hE1); gb_write(16'h7F10, 8'hE2); gb_write(16'h7F20, 8'hE3);
          gb_write(r, v); gb_write(16'h7FF0, 8'hE4); end
endtask
integer g_at = 20000, g_len = 10000, g_hold = 0, g_pre = 0, n_pc0 = 0;
reg [63:0] g_start = `GB_START_NS;
event issued;
initial begin
    if ($value$plusargs("GLITCH_AT=%d", g_at)) ;
    if ($value$plusargs("GLITCH_LEN=%d", g_len)) ;
    if ($value$plusargs("HOLD=%d", g_hold)) ;
    if ($value$plusargs("PRE=%d", g_pre)) ;
    if ($value$plusargs("START=%d", g_start)) ;
end
always @(tb.dut.`PC_BRAM.ADDRA[13:4])
    if ($time > g_start && tb.dut.`PC_BRAM.ADDRA[13:4] == 10'h000) begin
        n_pc0 = n_pc0 + 1; $display("%t gb: PicoBlaze at 000 (restart)", $time);
    end
initial begin
    @(issued);
    if (g_at >= 0) begin
        #(g_at); p61_n = 0; $display("%t gb: /RESET low", $time);
        #(g_len); p61_n = 1; $display("%t gb: /RESET high", $time);
    end
end
reg [7:0] sect [0:511];
reg [7:0] img [0:511];
integer gi, gpolls, gbad, gfd, gr;
reg [7:0] gq;
reg [63:0] t0;
task sd_read(input [31:0] lba, input glitch);
    begin
        $display("%t gb: sd_read(%0d)%s", $time, lba, glitch ? ", glitch armed" : "");
        fpga_set(16'h7F30, 1);
        gb_write(16'h7F00, 8'hE1); gb_write(16'h7F10, 8'hE2); gb_write(16'h7F20, 8'hE3);
        gb_write(16'h7FB0, lba[7:0]); gb_write(16'h7FB1, lba[15:8]);
        gb_write(16'h7FB2, lba[23:16]); gb_write(16'h7FB3, lba[31:24]);
        gb_write(16'h7FB4, 8'h01);
        if (glitch) -> issued;
        gb_write(16'h7FF0, 8'hE4);
        fpga_set(16'h7F30, 3);
        gpolls = 0; t0 = $time;
        gb_read(16'hA000, gq);
        while (gq == 8'hE1 && $time - t0 < `POLL_MAX_NS) begin gpolls = gpolls + 1; #20000; gb_read(16'hA000, gq); end
        if (gq == 8'hE1) $display("%t gb: still $E1 after %0d ms: stage1 would hang here", $time, `POLL_MAX_NS / 1000000);
        else $display("%t gb: status %h after %0d polls", $time, gq, gpolls);
        fpga_set(16'h7F30, 1);
        for (gi = 0; gi < 512; gi = gi + 1) begin gb_read(16'hA000 + gi, gq); sect[gi] = gq; end
        fpga_set(16'h7F30, 0);
        gfd = $fopen("card.img", "rb"); gr = $fseek(gfd, lba * 512, 0); gr = $fread(img, gfd); $fclose(gfd);
        gbad = 0;
        for (gi = 0; gi < 512; gi = gi + 1) if (sect[gi] !== img[gi]) gbad = gbad + 1;
        $display("%t gb: sector %0d %s (%0d bytes differ); first %h %h %h %h, last %h %h", $time, lba,
                 gbad ? "MISMATCH" : "matches card.img", gbad, sect[0], sect[1], sect[2], sect[3], sect[510], sect[511]);
    end
endtask
initial begin
    #1;
    #(g_start);
    sd_read(0, 0);
    #(g_pre);
    sd_read(1, 1);
    #100000;
    #(g_hold);
    sd_read(2, 0);
    $display("%t gb: done, %0d PicoBlaze restart(s)", $time, n_pc0);
    $finish;
end
`ifdef WATCH_NET
// log a design net (e.g. the reset net under test) whenever it changes, the
// first 40 changes from +WATCH_FROM=ns on
integer n_watch = 0;
reg [63:0] w_from = 0;
initial if ($value$plusargs("WATCH_FROM=%d", w_from)) ;
always @(tb.dut.`WATCH_NET) if ($time >= w_from && n_watch < 40) begin n_watch = n_watch + 1; $display("%t gb: %s = %b", $time, `"`WATCH_NET`", tb.dut.`WATCH_NET); end
`endif
`ifdef P61_TICK_CAPTURE
// FW5-0918 clocks P61's input register (X25Y15 IOI0) on CLK0 with ICE from
// a 20-bit counter's all-ones carry (n_X24Y4_S1_XB), high for one cycle every
// 2^20. That window opens and closes exactly on CLK0 rising edges, so with
// zero delays the register misses it at both; on hardware the counter's
// clock-to-out delay keeps ICE high through the closing edge, and the
// register takes P61 there. This models that capture.
reg iq_cap = 1;
initial force tb.dut.n_X25Y15_IOI0_IQ1 = iq_cap;
always @(negedge tb.dut.n_X24Y4_S1_XB) begin
    #1 iq_cap = tb.P61;
    $display("%t gb: tick, P61 register takes %b", $time, iq_cap);
end
`endif
