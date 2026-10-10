// Stage1's sd_read(0) from the Game Boy side (stage1/src/fpga.c), once the
// PicoBlaze has finished card init; checks the sector against card.img.
// +define+GB_TEST=\"gb_sdread.vh\" +define+GB_START_NS=... +define+SD_LBA=...
`ifndef GB_START_NS
`define GB_START_NS 52000000
`endif
`ifndef SD_LBA
`define SD_LBA 0
`endif
task fpga_set(input [15:0] r, input [7:0] v);
    begin gb_write(16'h7F00, 8'hE1); gb_write(16'h7F10, 8'hE2); gb_write(16'h7F20, 8'hE3);
          gb_write(r, v); gb_write(16'h7FF0, 8'hE4); end
endtask
reg [7:0] sect [0:511];
reg [7:0] img [0:511];
integer gi, gpolls, gbad, gfd, gr;
reg [7:0] gq;
reg [31:0] glba;
initial begin
    #(`GB_START_NS);
    glba = `SD_LBA;
    $display("%t gb: sd_read(%0d)", $time, glba);
    fpga_set(16'h7F30, 1);
    gb_write(16'h7F00, 8'hE1); gb_write(16'h7F10, 8'hE2); gb_write(16'h7F20, 8'hE3);
    gb_write(16'h7FB0, glba[7:0]); gb_write(16'h7FB1, glba[15:8]);
    gb_write(16'h7FB2, glba[23:16]); gb_write(16'h7FB3, glba[31:24]);
    gb_write(16'h7FB4, 8'h01);
    gb_write(16'h7FF0, 8'hE4);
    fpga_set(16'h7F30, 3);
    gpolls = 0;
    gb_read(16'hA000, gq);
    while (gq == 8'hE1) begin gpolls = gpolls + 1; #20000; gb_read(16'hA000, gq); end
    $display("%t gb: ready after %0d polls, status %h", $time, gpolls, gq);
    fpga_set(16'h7F30, 1);
    for (gi = 0; gi < 512; gi = gi + 1) begin gb_read(16'hA000 + gi, gq); sect[gi] = gq; end
    fpga_set(16'h7F30, 0);
    gfd = $fopen("card.img", "rb"); gr = $fseek(gfd, glba * 512, 0); gr = $fread(img, gfd); $fclose(gfd);
    gbad = 0;
    for (gi = 0; gi < 512; gi = gi + 1) if (sect[gi] !== img[gi]) begin
        if (gbad < 8) $display("gb: byte %0d got %h want %h", gi, sect[gi], img[gi]);
        gbad = gbad + 1;
    end
    $display("%t gb: sector %0d %s (%0d bytes differ); first bytes %h %h %h %h, last %h %h", $time, glba,
             gbad ? "MISMATCH" : "matches card.img", gbad, sect[0], sect[1], sect[2], sect[3], sect[510], sect[511]);
end
