// Testbench models of the parts around the FPGA.
`timescale 1ns/1ps

// SPI NOR config flash (EN25F40, 512 KB), SPI mode 0/3: MOSI sampled on the
// rising edge of CLK, MISO changes on the falling edge. Backed by a hex
// image of a real dump; writes and erases change the in-memory copy only.
module spi_flash #(parameter IMAGE = "flash.hex", parameter VERBOSE = 1) (
    input CS_N, CLK, MOSI, output reg MISO = 1'b1
);
    reg [7:0] mem [0:524287];
    initial $readmemh(IMAGE, mem);
    reg [7:0] sh, cmd, outb;
    reg [23:0] addr;
    reg [2:0] bitn;
    integer nbytes;
    reg wel = 0;
    always @(negedge CS_N) begin nbytes = 0; bitn = 0; MISO = 1'b1; end
    always @(posedge CS_N) begin
        if (VERBOSE && nbytes > 0)
            $display("%t flash: cmd %h addr %h, %0d bytes", $time, cmd, addr, nbytes);
        if (cmd == 8'h06 && nbytes == 1) wel = 1;
        if (cmd == 8'h04 && nbytes == 1) wel = 0;
    end
    function [7:0] status(input dummy); status = {6'b0, wel, 1'b0}; endfunction
    always @(posedge CLK) if (!CS_N) begin
        sh = {sh[6:0], MOSI};
        bitn = bitn + 1;
        if (bitn == 0) begin                   // a whole byte in
            nbytes = nbytes + 1;
            if (nbytes == 1) cmd = sh;
            else if (nbytes <= 4 && (cmd == 8'h03 || cmd == 8'h0B || cmd == 8'h02 ||
                                     cmd == 8'h20 || cmd == 8'hD8))
                addr = {addr[15:0], sh};
            if (cmd == 8'h02 && nbytes > 4 && wel) begin
                mem[addr] = mem[addr] & sh;
                addr = {addr[23:8], addr[7:0] + 8'd1};
            end
            if (nbytes == 4 && cmd == 8'h20 && wel) begin : er4
                integer i; for (i = 0; i < 4096; i = i + 1) mem[(addr & 24'h07F000) + i] = 8'hFF;
                wel = 0;
            end
            if (nbytes == 4 && cmd == 8'hD8 && wel) begin : er64
                integer i; for (i = 0; i < 65536; i = i + 1) mem[(addr & 24'h070000) + i] = 8'hFF;
                wel = 0;
            end
        end
    end
    // next output byte, chosen when a byte boundary is crossed
    always @(negedge CLK) if (!CS_N) begin
        if (bitn == 0) begin
            case (cmd)
                8'h03: outb = (nbytes >= 4) ? mem[addr[18:0]] : 8'hFF;
                8'h0B: outb = (nbytes >= 5) ? mem[addr[18:0]] : 8'hFF;
                8'h05: outb = status(0);
                8'h9F: outb = (nbytes == 1) ? 8'h1C : (nbytes == 2) ? 8'h31 : 8'h13;
                8'hAB: outb = 8'h12;
                default: outb = 8'hFF;
            endcase
            if ((cmd == 8'h03 && nbytes >= 4) || (cmd == 8'h0B && nbytes >= 5)) addr = addr + 1;
        end
        MISO = outb[7 - bitn];
    end
endmodule

// SD card, native bus (CLK, CMD, DAT0-3), as an SDHC card behind the
// OpenCores sdc_controller that bank 1 drives. Commands and responses on
// CMD with CRC7; data blocks on DAT0-3 (4-bit after ACMD6) with a CRC16 per
// line. Host outputs are sampled on the rising edge of CLK; the card drives
// on the falling edge. Blocks come from IMAGE on demand ($fread), so a
// whole card image never has to be loaded. Covers what bank 1 uses: CMD0,
// CMD8, CMD55/ACMD41, CMD2, CMD3, CMD7, CMD16, CMD55/ACMD6, CMD13, CMD18 +
// CMD12, CMD25.
module sd_card #(parameter IMAGE = "card.img", parameter VERBOSE = 1) (
    input CLK, inout CMD, inout [3:0] DAT
);
    reg cmd_oe = 0, cmd_o = 1;
    reg [3:0] dat_oe = 0, dat_o = 4'hF;
    assign CMD = cmd_oe ? cmd_o : 1'bz;
    assign DAT[0] = dat_oe[0] ? dat_o[0] : 1'bz;
    assign DAT[1] = dat_oe[1] ? dat_o[1] : 1'bz;
    assign DAT[2] = dat_oe[2] ? dat_o[2] : 1'bz;
    assign DAT[3] = dat_oe[3] ? dat_o[3] : 1'bz;

    integer fd;
    initial begin
        fd = $fopen(IMAGE, "rb");
        if (fd == 0) $display("sd: cannot open %s", IMAGE);
    end

    function [6:0] crc7(input [39:0] d);
        integer i; reg [6:0] c; reg b;
        begin
            c = 0;
            for (i = 39; i >= 0; i = i - 1) begin
                b = d[i] ^ c[6];
                c = {c[5:0], 1'b0};
                if (b) c = c ^ 7'h09;
            end
            crc7 = c;
        end
    endfunction

    // ---- receive commands ----
    reg [47:0] rx; integer rxn = 0; reg rxing = 0;
    reg [5:0] idx; reg [31:0] arg;
    reg app = 0, wide = 0, reading = 0, writing = 0;
    integer rgen = 0;    // each CMD17/18 read task stops once a newer one starts
    reg [15:0] rca = 16'h1234;
    reg [31:0] blk;
    event got_cmd;
    always @(posedge CLK) begin
        if (!rxing && !cmd_oe && CMD === 1'b0) begin rxing = 1; rxn = 1; rx = 0; end
        else if (rxing) begin
            rxn = rxn + 1;
            rx = {rx[46:0], CMD === 1'b1};
            if (rxn == 48) begin
                rxing = 0;
                idx = rx[45:40]; arg = rx[39:8];
                -> got_cmd;
            end
        end
    end

    // ---- respond ----
    task send_bits(input integer n, input [135:0] v);
        integer i;
        begin
            repeat (2) @(negedge CLK);         // N_CR
            cmd_oe = 1;
            for (i = n - 1; i >= 0; i = i - 1) begin cmd_o = v[i]; @(negedge CLK); end
            cmd_oe = 0; cmd_o = 1;
        end
    endtask
    task r48(input [5:0] i, input [31:0] v);
        reg [39:0] d;
        begin d = {2'b00, i, v}; send_bits(48, {88'b0, d, crc7(d), 1'b1}); end
    endtask
    task r3(input [31:0] ocr);
        send_bits(48, {88'b0, 2'b00, 6'b111111, ocr, 7'b1111111, 1'b1});
    endtask
    function [6:0] crc7_120(input [119:0] d);
        integer i; reg [6:0] c; reg b;
        begin
            c = 0;
            for (i = 119; i >= 0; i = i - 1) begin
                b = d[i] ^ c[6]; c = {c[5:0], 1'b0}; if (b) c = c ^ 7'h09;
            end
            crc7_120 = c;
        end
    endfunction
    task r2(input [119:0] reg120);
        send_bits(136, {2'b00, 6'b111111, reg120, crc7_120(reg120), 1'b1});
    endtask
    localparam [31:0] ST_TRAN = 32'h00000900, ST_APP = 32'h00000920;

    always @(got_cmd) begin
        if (VERBOSE) $display("%t sd: %sCMD%0d arg %h", $time, app ? "A" : "", idx, arg);
        if (app && idx == 55) r48(55, ST_APP);         // CMD55 again: still CMD55
        else if (app) begin
            app = 0;
            case (idx)
                41: r3(32'hC0FF8000);                      // powered up, SDHC
                6:  begin wide = arg[1]; r48(6, ST_TRAN); end
                default: r48(idx, ST_TRAN);
            endcase
        end else case (idx)
            0:  ;
            8:  r48(8, {20'b0, arg[11:0]});
            55: begin app = 1; r48(55, ST_APP); end
            2:  r2(120'h1D_4144_45_4247_4231_10_12345678_0153);   // CID, CRC appended
            3:  r48(3, {rca, 16'h0500});
            7:  r48(7, 32'h00000700);
            9:  r2(120'h400E_0032_5B59_0000_EDC8_7F80_0A40_00);   // CSD v2
            13: r48(13, ST_TRAN);
            16: r48(16, ST_TRAN);
            12: begin reading = 0; writing = 0; r48(12, ST_TRAN); end
            17, 18: begin r48(idx, ST_TRAN); blk = arg; reading = 1; rgen = rgen + 1; fork read_blocks(idx == 17, rgen); join_none end
            24, 25: begin r48(idx, ST_TRAN); blk = arg; writing = 1; fork write_blocks(idx == 24); join_none end
            default: r48(idx, ST_TRAN);
        endcase
    end

    // ---- data ----
    reg [7:0] buffer [0:511];
    function [15:0] crc16_step(input [15:0] c, input b);
        crc16_step = {c[14:0], 1'b0} ^ ((c[15] ^ b) ? 16'h1021 : 16'h0);
    endfunction
    task read_blocks(input single, input integer g);
        integer i, k, r; reg [15:0] crc [0:3]; reg [3:0] nib;
        begin
            // a CMD18 right after CMD12: let the previous block finish first
            while (dat_oe !== 0) @(negedge CLK);
            while (reading && g == rgen) begin
                r = $fseek(fd, blk * 512, 0);
                r = $fread(buffer, fd);
                if (VERBOSE) $display("%t sd: read block %0d", $time, blk);
                repeat (8) @(negedge CLK);
                for (k = 0; k < 4; k = k + 1) crc[k] = 0;
                dat_oe = wide ? 4'hF : 4'h1; dat_o = 4'h0;          // start bit
                @(negedge CLK);
                for (i = 0; i < 512; i = i + 1) begin
                    if (wide) begin
                        nib = buffer[i][7:4];
                        for (k = 0; k < 4; k = k + 1) crc[k] = crc16_step(crc[k], nib[k]);
                        dat_o = nib; @(negedge CLK);
                        nib = buffer[i][3:0];
                        for (k = 0; k < 4; k = k + 1) crc[k] = crc16_step(crc[k], nib[k]);
                        dat_o = nib; @(negedge CLK);
                    end else begin
                        for (k = 7; k >= 0; k = k - 1) begin
                            crc[0] = crc16_step(crc[0], buffer[i][k]);
                            dat_o = {3'b111, buffer[i][k]}; @(negedge CLK);
                        end
                    end
                end
                for (k = 15; k >= 0; k = k - 1) begin
                    dat_o = {crc[3][k], crc[2][k], crc[1][k], crc[0][k]}; @(negedge CLK);
                end
                dat_o = 4'hF; @(negedge CLK);                        // end bit
                dat_oe = 0;
                blk = blk + 1;
                if (single) reading = 0;
            end
        end
    endtask
    task write_blocks(input single);
        integer i, k, r; reg [3:0] nib;
        begin
            while (writing) begin
                @(posedge CLK);
                while (writing && DAT[0] !== 1'b0) @(posedge CLK);  // start bit
                if (writing) begin
                for (i = 0; i < 512; i = i + 1) begin
                    if (wide) begin
                        @(posedge CLK); buffer[i][7:4] = DAT;
                        @(posedge CLK); buffer[i][3:0] = DAT;
                    end else
                        for (k = 7; k >= 0; k = k - 1) begin @(posedge CLK); buffer[i][k] = DAT[0]; end
                end
                repeat (17) @(posedge CLK);                          // CRC + end bit
                r = $fseek(fd, blk * 512, 0);
                if (VERBOSE) $display("%t sd: write block %0d (not stored)", $time, blk);
                // CRC status token "010" on DAT0, then a short busy
                @(negedge CLK); @(negedge CLK);
                dat_oe = 4'h1; dat_o = 4'hE;                         // start 0
                @(negedge CLK); dat_o = 4'hE;                        // 0
                @(negedge CLK); dat_o = 4'hF;                        // 1
                @(negedge CLK); dat_o = 4'hE;                        // 0
                @(negedge CLK); dat_o = 4'hF;                        // end 1
                @(negedge CLK); dat_o = 4'hE;                        // busy
                repeat (8) @(negedge CLK);
                dat_o = 4'hF; @(negedge CLK); dat_oe = 0;
                blk = blk + 1;
                if (single) writing = 0;
                end
            end
        end
    endtask
endmodule

// pSRAM die of a NOR+pSRAM MCP (U9: game ROM, U4: saves), 16-bit words with
// byte lanes, wired as on the Jr: the eight data lines serve both lanes
// (/LB = even byte, /UB = odd byte). Writes land at the end of the /WE
// pulse (sampled, like the other monitors, so tri-state nets are safe).
// Q and OE are for the testbench to gate onto the bus. WORDS is the size
// in 16-bit words; IMAGE, if set, preloads bytes.
module psram #(parameter WORDS = 4194304, parameter IMAGE = "", parameter NAME = "psram") (
    input [22:0] A, input [7:0] D, output [7:0] Q, output OE,
    input CE_N, WE_N, OE_N, LB_N, UB_N
);
    reg [7:0] mem [0:2*WORDS-1];
    integer i, fd, r, writes = 0;
    initial begin
        for (i = 0; i < 2 * WORDS; i = i + 1) mem[i] = 8'hFF;
        if (IMAGE != "") begin
            fd = $fopen(IMAGE, "rb");
            if (fd) begin r = $fread(mem, fd); $fclose(fd); end
        end
    end
    wire [23:0] lo = {A, 1'b0}, hi = {A, 1'b1};
    wire wr = !CE_N && !WE_N;
    // the FPGA releases data and address as /WE rises, so keep the values
    // seen during the pulse and commit them when it ends
    reg pw = 0, l_lb, l_ub;
    reg [7:0] l_d;
    reg [23:0] l_lo, l_hi;
    always #1 begin
        if (wr) begin l_d = D; l_lo = lo; l_hi = hi; l_lb = LB_N; l_ub = UB_N; end
        else if (pw) begin
            if (!l_lb) mem[l_lo % (2 * WORDS)] = l_d;
            if (!l_ub) mem[l_hi % (2 * WORDS)] = l_d;
            writes = writes + 1;
        end
        pw = wr;
    end
    assign Q = !LB_N ? mem[lo % (2 * WORDS)] : mem[hi % (2 * WORDS)];
    assign OE = !CE_N && !OE_N && WE_N && !(LB_N && UB_N);
    task dump(input [8*64-1:0] file, input integer nbytes);
        integer f, j;
        begin
            f = $fopen(file, "wb");
            for (j = 0; j < nbytes; j = j + 1) $fwrite(f, "%c", mem[j]);
            $fclose(f);
            $display("%t %0s: %0d writes, first %0d bytes dumped to %0s", $time, NAME, writes, nbytes, file);
        end
    endtask
endmodule

// 74HC595: shift on the rising edge of SRCLK, copy to Q on the rising edge
// of RCLK (sampled every 1 ns: the FPGA's pulses are tens of ns wide)
module hc595 (input SRCLK, SER, RCLK, output reg [7:0] Q = 0);
    reg [7:0] sr = 0;
    reg ps = 0, pr = 0;
    always #1 begin
        if (SRCLK === 1'b1 && ps !== 1'b1) sr = {sr[6:0], SER === 1'b1};
        if (RCLK === 1'b1 && pr !== 1'b1) Q = sr;
        ps = SRCLK; pr = RCLK;
    end
endmodule

// PCF8563 real-time clock on I2C (address $51), sampled every 5 ns. Time
// registers 2-8 in BCD; the seconds tick every TICK_NS (shortened for
// simulation). SDA_LOW pulls the shared line low for ACKs and read data.
module pcf8563 #(parameter TICK_NS = 3000000) (input SCL, input SDA, output reg SDA_LOW = 0);
    reg [7:0] r [0:15];
    integer i, bitn = 0, tick = 0;
    reg ps = 1, pd = 1, active = 0, rd = 0, ack = 0, addr_ok = 0, first = 0, mack = 0;
    reg [7:0] sh = 0, ptr = 0, tx = 0;
    reg [3:0] st = 0;                      // 0 idle, 1 address, 2 data in, 3 data out
    initial begin
        for (i = 0; i < 16; i = i + 1) r[i] = 0;
        r[2] = 8'h00; r[3] = 8'h30; r[4] = 8'h12; r[5] = 8'h09; r[6] = 8'h05; r[7] = 8'h10; r[8] = 8'h26;
    end
    function [7:0] binc(input [7:0] v); binc = (v[3:0] == 9) ? {v[7:4] + 4'd1, 4'd0} : v + 8'd1; endfunction
    always #1000 begin
        tick = tick + 1000;
        if (tick >= TICK_NS) begin
            tick = 0;
            r[2] = binc(r[2] & 8'h7F);
            if (r[2] == 8'h60) begin r[2] = 0; r[3] = binc(r[3]);
                if (r[3] == 8'h60) begin r[3] = 0; r[4] = binc(r[4]);
                    if (r[4] == 8'h24) begin r[4] = 0; r[5] = binc(r[5]); end end end
        end
    end
    wire scl = SCL !== 1'b0, sda = SDA !== 1'b0;
    always #5 begin
        if (scl && ps && pd && !sda) begin st = 1; bitn = 0; SDA_LOW = 0; ack = 0; end        // START
        else if (scl && ps && !pd && sda) begin st = 0; SDA_LOW = 0; end                     // STOP
        else if (scl && !ps) begin                                                            // SCL rises
            if (ack) ;                                                                        // ACK clock
            else if (st == 3) begin
                if (bitn == 8) begin mack = !sda; end
            end else if (st == 1 || st == 2) begin sh = {sh[6:0], sda}; bitn = bitn + 1; end
        end else if (!scl && ps) begin                                                        // SCL falls
            if (ack) begin
                ack = 0; SDA_LOW = 0; bitn = 0;
                if (st == 3) begin tx = r[ptr[3:0]]; ptr = ptr + 1; SDA_LOW = !tx[7]; end
            end else if ((st == 1 || st == 2) && bitn == 8) begin
                if (st == 1) begin
                    if (sh[7:1] == 7'h51) begin ack = 1; SDA_LOW = 1; rd = sh[0]; first = 1;
                        st = sh[0] ? 3 : 2; end
                    else st = 0;
                end else begin
                    if (first) begin ptr = sh; first = 0; end
                    else begin r[ptr[3:0]] = sh; ptr = ptr + 1; end
                    ack = 1; SDA_LOW = 1;
                end
                bitn = 0;
            end else if (st == 3) begin
                if (bitn < 7) begin bitn = bitn + 1; SDA_LOW = !tx[7 - bitn]; end
                else if (bitn == 7) begin bitn = 8; SDA_LOW = 0; end                          // master ACK/NACK
                else begin                                                                    // after master ACK
                    if (mack) begin tx = r[ptr[3:0]]; ptr = ptr + 1; bitn = 0; SDA_LOW = !tx[7]; end
                    else begin st = 0; SDA_LOW = 0; end
                end
            end
        end
        ps = scl; pd = sda;
    end
endmodule
