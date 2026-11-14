`timescale 1ns/1ps
// Print every change of the bus and memory-side signals in a window
// (WAVE_T0..WAVE_T1, ns), for reading one game-mode access cycle by cycle.
`ifndef WAVE_T0
`define WAVE_T0 57530000
`endif
`ifndef WAVE_T1
`define WAVE_T1 57537000
`endif
module wavemon;
    wire [63:0] v = {tb.phi, tb.gb_a, tb.P84, tb.P52, tb.P60, tb.P37, tb.P36, tb.P40, tb.mem_a, tb.gb_q, tb.bank, tb.P51};
    reg [63:0] l = 0;
    always #2 if ($time >= 64'd`WAVE_T0 && $time < 64'd`WAVE_T1 && v !== l) begin
        $display("%t w phi=%b A=%h wr=%b ce9=%b ce4=%b lb=%b ub=%b we=%b memA=%h gbD=%h 595=%h P51=%b", $time,
                 tb.phi, tb.gb_a, tb.P84, tb.P52, tb.P60, tb.P37, tb.P36, tb.P40, tb.mem_a, tb.gb_q, tb.bank, tb.P51);
        l = v;
    end
endmodule
