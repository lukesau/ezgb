// Bel-level primitives: what scripts/fpga/carve.py decomposes a configured
// slice into. One cell per LUT, flip-flop, wide mux and carry mux; the
// slice's fixed selections (FXMUX, DXMUX, CYINIT, ...) become wiring.
// Equivalent to re/stage0/sim/s3prims.v's s3_slice in steady state
// (check: scripts/fpga/equiv.sh all --slices against the bel version).
// Synthesizable for yosys, simulatable in iverilog.

module s3_lut4 #(parameter [15:0] INIT = 16'hFFFF) (input I1, I2, I3, I4, output O);
    assign O = INIT[{I4, I3, I2, I1}];
endmodule

// 16x1 LUT RAM. The F LUT of a SLICEM reads at its own address and writes
// at the G LUT's (the slice's write port); the G LUT reads and writes at
// its own, so for it RA == WA.
module s3_ram16 #(parameter [15:0] INIT = 16'h0000) (
    input [3:0] RA, WA, input WE, CLK, D, output O, MC15
);
    reg [15:0] m = INIT;
    always @(posedge CLK) if (WE) m[WA] <= D;
    assign O = m[RA], MC15 = m[15];
endmodule

// 16-bit shift register LUT: shifts D in on CLK when CE, reads bit A.
module s3_srl16 #(parameter [15:0] INIT = 16'h0000) (
    input [3:0] A, input CE, CLK, D, output O, MC15
);
    reg [15:0] m = INIT;
    always @(posedge CLK) if (CE) m <= {m[14:0], D};
    assign O = m[A], MC15 = m[15];
endmodule

// Slice or IO-tile flip-flop (LATCH: transparent while CLK is high).
// SR forces SRVAL, REV forces !SRVAL, SR winning; async unless SYNC.
module s3_ff #(parameter INIT = 0, SRVAL = 0, LATCH = 0, SYNC = 0) (
    input D, CE, CLK, SR, REV, output reg Q = INIT
);
    generate if (LATCH) begin
        always @* begin if (SR) Q = SRVAL; else if (REV) Q = !SRVAL; else if (CLK & CE) Q = D; end
    end else if (SYNC) begin
        always @(posedge CLK) if (SR) Q <= SRVAL; else if (REV) Q <= !SRVAL; else if (CE) Q <= D;
    end else begin
        always @(posedge CLK or posedge SR or posedge REV)
            if (SR) Q <= SRVAL; else if (REV) Q <= !SRVAL; else if (CE) Q <= D;
    end endgenerate
endmodule

// F5 (S = BX: I1 = F, I0 = G), FX (S = BY: I1 = FXINA, I0 = FXINB)
module s3_mux2 (input S, I0, I1, output O);
    assign O = S ? I1 : I0;
endmodule

// MUXCY: O = S ? CI : DI
module s3_muxcy (input S, CI, DI, output O);
    assign O = S ? CI : DI;
endmodule

module s3_xorcy (input LI, CI, output O);
    assign O = LI ^ CI;
endmodule
