`timescale 1ns/1ps
// Sample the GB data bus every 50 ns through reads of $A000 (after the load
// command), one line per read: when does the FPGA drive the status byte?
module stmon2;
    integer n = 0, k; reg [7:0] smp [0:19];
    always @(posedge tb.phi) if (tb.gb_doe === 1'b0 && n < 8 && $time > 64'd31400000) begin
        for (k = 0; k < 19; k = k + 1) begin #50 smp[k] = tb.gb_q; end
        if (tb.gb_a == 16'hA000) begin
            n = n + 1;
            $display("st A=%h +50..+950: %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h", tb.gb_a,
                     smp[0], smp[1], smp[2], smp[3], smp[4], smp[5], smp[6], smp[7], smp[8], smp[9],
                     smp[10], smp[11], smp[12], smp[13], smp[14], smp[15], smp[16], smp[17], smp[18]);
        end
    end
endmodule
