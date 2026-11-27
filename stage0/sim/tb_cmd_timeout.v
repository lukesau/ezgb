// How late a card may answer a command before FW6's 8-bit command timeout
// ends it: the command master and the serializer with a card that answers
// N SD clocks after the host stops driving CMD, the timeout at $FF.
//
//   iverilog -g2012 -o /tmp/tb stage0/sim/tb_cmd_timeout.v stage0/fw6/sd_cmd_master.v stage0/fw5-0918/sd_cmd_serial.v && vvp /tmp/tb
//
// A short response completes when the card answers within 153 clocks, a
// long one (CMD2, the only one the program sends) within 65. The SD
// specification's longest wait is 64.
`timescale 1ns/1ps
module tb;
    reg clk = 0; always #5 clk = !clk;
    reg soft_rst = 1;
    reg [2:1] start_sync = 0;
    reg [13:0] command; reg [7:0] timeout;
    integer N, LEN, ncr, len, i, wd, exec_cycles;
    wire expect_response, long_response, start_xfr, go_idle, finish, crc_ok, index_ok;
    wire [38:0] cmd; wire [119:0] response; wire [4:0] int_status;
    wire cmd_out_next, cmd_t_next;
    reg cmd_out = 1, cmd_t = 1;        // the pad's output and tristate registers
    reg card_drv = 0, card_bit = 1;
    wire pad = !cmd_t ? cmd_out : card_drv ? card_bit : 1'b1;   // pulled up
    reg cmd_dat_q = 1;
    always @(posedge clk) begin cmd_out <= cmd_out_next; cmd_t <= cmd_t_next; cmd_dat_q <= pad; end
    sd_cmd_master m (.clk_sd(clk), .soft_rst(soft_rst), .start_sync(start_sync), .int_rst_sync(2'b00),
        .response_i(response), .finish_i(finish), .crc_ok_i(crc_ok), .index_ok_i(index_ok), .sd_dat0_q(1'b1),
        .argument_i(32'h12345678), .command_i(command), .timeout_i(timeout),
        .expect_response(expect_response), .long_response(long_response), .start_xfr_o(start_xfr), .go_idle_o(go_idle),
        .cmd_o(cmd), .int_status_o(int_status));
    sd_cmd_serial s (.clk_sd(clk), .soft_rst(soft_rst), .gb_reset_n_q(1'b1), .rst_prev(1'b1), .go_idle(go_idle),
        .start(start_xfr), .with_response_i(expect_response), .long_response_i(long_response), .cmd_i(cmd),
        .cmd_dat_q(cmd_dat_q), .response(response), .finish_o(finish), .crc_ok_o(crc_ok), .index_ok_o(index_ok),
        .cmd_out_next(cmd_out_next), .cmd_t_next(cmd_t_next));
    // the card: N idle clocks after the host stops driving, then len bits (start bit 0, the rest 1)
    reg host_was = 0; integer gap, sent; reg answering;
    always @(negedge clk) begin
        if (!cmd_t && m.state == 2'b01) begin host_was <= 1; gap <= 0; end   // the command, not the serializer's start-up drive
        else if (host_was && !answering) begin
            gap <= gap + 1;
            if (gap + 1 >= ncr) begin answering <= 1; sent <= 0; host_was <= 0; end
        end
        if (answering) begin
            card_drv <= 1; card_bit <= (sent != 0); sent <= sent + 1;
            if (sent == len) begin card_drv <= 0; answering <= 0; end
        end
    end
    always @(posedge clk) if (m.state == 2'b01) exec_cycles = exec_cycles + 1;
    task run(input integer n, input integer l, output integer ok, output integer cyc);
        begin
            ncr = n; len = l; answering = 0; host_was = 0; gap = 0; card_drv = 0; exec_cycles = 0;
            soft_rst = 1; repeat (4) @(posedge clk); soft_rst = 0; repeat (12) @(posedge clk);
            @(negedge clk) start_sync = 2'b01; @(negedge clk) start_sync = 2'b11;
            wd = 0;
            while (!(int_status[0] | int_status[1]) && wd < 2000) begin @(posedge clk); wd = wd + 1; end
            ok = int_status[0] & !int_status[2]; cyc = exec_cycles;
        end
    endtask
    integer ok, cyc, last_ok, last_cyc;
    initial begin
        timeout = 8'hff;
        for (LEN = 0; LEN < 2; LEN = LEN + 1) begin
            command = LEN ? 14'h0202 : 14'h0d19;      // long (CMD2-like) or short with CRC and index checks
            last_ok = -1;
            for (N = 1; N < 160; N = N + 1) begin
                run(N, LEN ? 136 : 48, ok, cyc);
                if (ok) begin last_ok = N; last_cyc = cyc; end
                if (N == 2 || N == 5 || N == 8 || N == 64 || N == 65 || N == 66) $display("%s response, card answers after %0d clocks: %s, %0d clocks in EXECUTE", LEN ? "long " : "short", N, ok ? "ok" : "TIMEOUT", cyc);
            end
            $display("%s response: last gap that completes = %0d clocks (%0d in EXECUTE)", LEN ? "long " : "short", last_ok, last_cyc);
        end
        $finish;
    end
endmodule
