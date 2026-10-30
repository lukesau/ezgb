// SD drop vs the fast-load key (stage0/sd-recover-fw5-0918.psm, key_store):
// one sector read (fault it with +SD_BAD_READS=1), then $7FD3=0 and
// $7FD4=$11 as stage1's fast launch writes them, then a ROM load
// (loadcmd.hex, from loadcmd.py) through the $7F36 window. The PC monitor
// counts cmd_load_rom's key_store and its zeroing branch, each run's
// fast-key check (LOAD_NEXT $23B) and the pause after it ($23E CALL
// delay_long). The load is checked byte for byte against card.img in U9.
// +define+GB_TEST=\"gb_sdload.vh\" +define+PC_BRAM=i_D0X3Y1_bram
// plusargs: +LOAD_LBA=n +LOAD_LEN=n (the file in loadcmd.hex),
// +KS=hex +KS0=hex (key_store and its LOAD s0,00; 3d8/3db in the patch),
// +W7=hex (wday_out's LOAD s5,07; 3e3)
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
reg [9:0] a_ks = 10'h3d8, a_ks0 = 10'h3db, a_w7 = 10'h3e3;
reg in_load = 0;
integer n_ks = 0, n_ks0 = 0, n_next = 0, n_pause = 0, n_rec = 0, n_done = 0, n_w7 = 0, n_run = 0, n_dump = 0;
initial begin
    if ($value$plusargs("KS=%h", a_ks)) ;
    if ($value$plusargs("KS0=%h", a_ks0)) ;
    if ($value$plusargs("W7=%h", a_w7)) ;
end
wire [9:0] mon_pc = tb.dut.`PC_BRAM.ADDRA[13:4];
always @(mon_pc) begin
    if (in_load && mon_pc == a_ks) begin n_ks = n_ks + 1; $display("%t gb: key_store", $time); end
    if (in_load && mon_pc == a_ks0) begin n_ks0 = n_ks0 + 1; $display("%t gb: key_store zeroes the key (sd_slow set)", $time); end
    if (mon_pc == 10'h230) n_run = n_run + 1;
    if (mon_pc == 10'h23b) n_next = n_next + 1;
    if (mon_pc == 10'h23e) n_pause = n_pause + 1;
    if (mon_pc == 10'h3b0) begin n_rec = n_rec + 1; $display("%t gb: sd_recover", $time); end
    if (mon_pc == 10'h226) begin n_done = n_done + 1; $display("%t gb: load_rom_loop returned", $time); end
    if (mon_pc == a_w7) n_w7 = n_w7 + 1;
    if (mon_pc == 10'h323) n_dump = n_dump + 1;
end
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
reg [7:0] lcmd [0:511];
reg [7:0] limg [0:1048575];
integer li, load_lba = 4210, load_len = 32768, lwait, lbad, lfirst;
real t_load;
initial begin
    $readmemh("loadcmd.hex", lcmd);
    if ($value$plusargs("LOAD_LBA=%d", load_lba)) ;
    if ($value$plusargs("LOAD_LEN=%d", load_len)) ;
    #(`GB_START_NS);
    ffail = 0;
    read_check(0);
    #3000000;
    $display("%t gb: after the read: rtc_dump entered %0d times, weekday 7 stored %0d times", $time, n_dump, n_w7);
    // stage1's fast launch: $7FD3=0, then $7FD4=$11 ($BB = $7FD3 + $7FD4)
    fpga_set(16'h7FD3, 8'h00);
    fpga_set(16'h7FD4, 8'h11);
    n_ks = 0; n_ks0 = 0; n_next = 0; n_pause = 0; n_run = 0; n_done = 0; in_load = 1;
    $display("%t gb: load, %0d bytes at LBA %0d, step %0d", $time, load_len, load_lba, lcmd[504]);
    fpga_set(16'h7FC0, 0);
    fpga_set(16'h7FC0, 2);
    fpga_set(16'h7F36, 1);
    for (li = 0; li < 512; li = li + 1) gb_write(16'hA000 + li, lcmd[li]);
    fpga_set(16'h7F36, 3);
    t_load = $realtime;
    $display("%t gb: load started", $time);
    lwait = 0;
    while (n_done == 0 && lwait < 1500) begin #100000; lwait = lwait + 1; end
    if (n_done == 0) ffail = ffail + 1;
    in_load = 0;
    $display("%t gb: load %s in %0.3f ms: %0d runs, %0d fast-key checks, %0d pauses (CALL delay_long at $23E), key_store %0d, zeroed %0d, sd_recover %0d so far",
             $time, n_done ? "done" : "TIMED OUT", ($realtime - t_load) / 1e6, n_run, n_next, n_pause, n_ks, n_ks0, n_rec);
    fpga_set(16'h7F36, 0);
    ffd = $fopen("card.img", "rb"); fr = $fseek(ffd, load_lba * 512, 0); fr = $fread(limg, ffd, 0, load_len); $fclose(ffd);
    lbad = 0; lfirst = -1;
    for (li = 0; li < load_len; li = li + 1)
        if (tb.u9.mem[li] !== limg[li]) begin lbad = lbad + 1; if (lfirst < 0) lfirst = li; end
    if (lbad) ffail = ffail + 1;
    $display("%t gb: U9 vs card.img: %0d of %0d bytes differ%s; U9 past the file: %h %h", $time, lbad, load_len,
             lbad ? $sformatf(" (first at %0d: %h, want %h)", lfirst, tb.u9.mem[lfirst], limg[lfirst]) : "",
             tb.u9.mem[load_len], tb.u9.mem[load_len + 1]);
    // weekday in kernel mode, as gb_sdfault.vh reads it
    fpga_set(16'h7FC0, 0);
    #6000000;
    gb_write(16'h7F00, 8'hE1); gb_write(16'h7F10, 8'hE2); gb_write(16'h7F20, 8'hE3);
    gb_write(16'h7F31, 8'h00); gb_write(16'h7F32, 8'h80);
    gb_write(16'h7FF0, 8'hE4);
    fpga_set(16'h7FC0, 6);
    gb_read(16'hA00C, fq);
    fpga_set(16'h7FC0, 0);
    $display("%t gb: weekday byte %h: %s (weekday 7 stored %0d times, rtc_dump entered %0d times)", $time, fq,
             (fq & 8'h07) == 8'h07 ? "dropped to half speed" : "full speed", n_w7, n_dump);
    $display("%t gb: %0d failure(s)", $time, ffail);
    $finish;
end
