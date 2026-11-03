// FW5-0918's PicoBlaze timer, which FW4 doesn't have, on the PicoBlaze
// clock. OUTPUT A1 queues one unit of delay, INPUT A0 reads the queue
// (picoblaze_ports): tmr counts the units still to run (at most 15), each
// tick takes one away, and tmr_run drops when a tick finds none left. A
// unit lasts 540 clocks (27 x 20); the first ends sooner, as the
// prescaler runs freely.
//
// The prescaler, as XST built it:
//
//   - pre1 {p_d, p_a, p_n, p_c, p_m, p_b}: a 6-bit counter from 0 to 26,
//     p_on the cycle after it wraps (every 27 clocks); p_d never sets
//   - a phase machine p_e..p_i and a 3-bit counter {p_l, p_k, p_j}, which
//     step on p_on while the timer runs (p_f and p_h hold it in place
//     while it doesn't); the counter clears on p_f, counts p_i while p_h,
//     and its carry out is the tick, every 20 steps. The phase bits are
//     written as XST's next-state equations: the encoding has no simpler
//     form with these flip-flops
//
// Block: stage0/fw5-0918/pb_timer.blk (FW5 only).

module pb_timer (
    input clk_pb,
    input wr_a1,                    // OUTPUT A1 (picoblaze_ports)
    input tmr_full,                 // &tmr, from picoblaze_ports
    output reg tmr_run,
    output reg [3:0] tmr,
    output reg tick
);
    reg p_a, p_b, p_c, p_d, p_m, p_n, p_on;
    reg p_e, p_f, p_g, p_h, p_i, p_j, p_k, p_l;

    // ---- stage 1: 0..26
    wire [5:0] pre1 = {p_d, p_a, p_n, p_c, p_m, p_b};
    wire wrap = pre1 == 6'd26;
    wire [5:0] pre1_n = wrap ? 6'd0 : pre1 + 6'd1;

    // ---- stage 2
    wire hold = !p_h & !p_f & tmr_run;
    wire [2:0] cnt = {p_l, p_k, p_j};
    wire co = p_h & p_i & (&cnt);           // the counter's carry out
    wire [2:0] cnt_n = p_f ? 3'd0 : p_h ? cnt + p_i : {2'b00, p_i};

    // ---- the timer
    wire none = tmr == 4'd0;
    wire add = wr_a1 & (tick | !tmr_full);  // a unit queued, unless the queue is full

    initial begin
        {p_d, p_a, p_n, p_c, p_m, p_b, p_on} = 7'd0;
        {p_e, p_f, p_g, p_h, p_i, p_j, p_k, p_l} = 8'd0;
        tmr_run = 1'b0; tmr = 4'd0; tick = 1'b0;
    end
    always @(posedge clk_pb) begin
        {p_d, p_a, p_n, p_c, p_m, p_b} <= pre1_n;
        p_on <= wrap;
        if (p_on) begin
            p_e <= !p_e & p_i & p_h & co | p_e & !p_i & !p_h & !co;
            p_f <= !p_i & !hold & !p_e & p_f | !p_i & hold & !p_e & !p_f | p_i & hold & p_e & !p_f;
            p_g <= !p_e & !hold & p_i | !p_e & hold & !p_i | p_e & hold & p_i;
            p_h <= !co & (!p_i & p_h | p_i & p_f & !p_h | !p_f & p_h);
            p_i <= p_g;
        end
        if (p_f) {p_l, p_k, p_j} <= 3'd0;
        else if (p_on) {p_l, p_k, p_j} <= cnt_n;
        tick <= p_on & co;
        tmr_run <= tmr_run & !tick | wr_a1 & none | tmr_run & !none;
        if (tmr_run) tmr <= none & !wr_a1 ? 4'd0 : tmr - tick + add;
    end

`ifdef FORMAL
    always @* env_full: assume (tmr_full == &tmr);
`endif
endmodule
