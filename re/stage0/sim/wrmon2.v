`timescale 1ns/1ps
// At the end of each GB write (/WR rising), log the unlock state machine
// (X18Y31 S0/S3 XQ), the command-request enable and flag, and P61.
module wrmon2;
    reg pw = 1; integer n = 0;
    always #1 begin
        if (tb.P84 === 1'b1 && pw === 1'b0 && n < 30 && $time > 64'd31000000) begin
            n = n + 1;
            #30 $display("%t wr A=%h D=%h P61=%b unlock=%b%b reqce=%b req=%b bankce=%b", $time, tb.gb_a, tb.gb_d, tb.P61,
                         tb.dut.n_X18Y31_S0_XQ, tb.dut.n_X18Y31_S3_XQ, tb.dut.n_X23Y13_S2_X, tb.dut.n_X23Y29_S1_YQ, tb.dut.n_X13Y23_S3_X);
        end
        pw = tb.P84;
    end
endmodule
