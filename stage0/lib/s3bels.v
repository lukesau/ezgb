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

// The LUT RAM shapes a design builds from the 16x1 cells, named so a
// readable module can keep the hardware's cells one for one: a block file
// names each hardware cell after the instance path here (regs0.sy,
// stack3.hi, scratch5.q2), and equiv.sh matches the contents by that name.

// 16x1 dual port: the G LUT reads and writes at A, the F LUT reads at
// DPRA and is written at A alongside it.
module s3_ram16x1d #(parameter [15:0] INIT = 16'h0000) (
    input [3:0] A, DPRA, input WE, CLK, D, output SPO, DPO
);
    s3_ram16 #(.INIT(INIT)) sx (.RA(A), .WA(A), .WE(WE), .CLK(CLK), .D(D), .O(SPO), .MC15());
    s3_ram16 #(.INIT(INIT)) sy (.RA(DPRA), .WA(A), .WE(WE), .CLK(CLK), .D(D), .O(DPO), .MC15());
endmodule

// 32x1 single port: two cells, A[4] picks the high one (the F5 mux)
module s3_ram32x1s #(parameter [31:0] INIT = 32'h0) (
    input [4:0] A, input WE, CLK, D, output O
);
    wire lo_o, hi_o;
    s3_ram16 #(.INIT(INIT[15:0])) lo (.RA(A[3:0]), .WA(A[3:0]), .WE(WE & !A[4]), .CLK(CLK), .D(D), .O(lo_o), .MC15());
    s3_ram16 #(.INIT(INIT[31:16])) hi (.RA(A[3:0]), .WA(A[3:0]), .WE(WE & A[4]), .CLK(CLK), .D(D), .O(hi_o), .MC15());
    assign O = A[4] ? hi_o : lo_o;
endmodule

// 64x1 single port: four cells, A[5:4] picks one (F5 then FX muxes)
module s3_ram64x1s #(parameter [63:0] INIT = 64'h0) (
    input [5:0] A, input WE, CLK, D, output O
);
    wire [3:0] q;
    s3_ram16 #(.INIT(INIT[15:0]))  q0 (.RA(A[3:0]), .WA(A[3:0]), .WE(WE & A[5:4] == 2'd0), .CLK(CLK), .D(D), .O(q[0]), .MC15());
    s3_ram16 #(.INIT(INIT[31:16])) q1 (.RA(A[3:0]), .WA(A[3:0]), .WE(WE & A[5:4] == 2'd1), .CLK(CLK), .D(D), .O(q[1]), .MC15());
    s3_ram16 #(.INIT(INIT[47:32])) q2 (.RA(A[3:0]), .WA(A[3:0]), .WE(WE & A[5:4] == 2'd2), .CLK(CLK), .D(D), .O(q[2]), .MC15());
    s3_ram16 #(.INIT(INIT[63:48])) q3 (.RA(A[3:0]), .WA(A[3:0]), .WE(WE & A[5:4] == 2'd3), .CLK(CLK), .D(D), .O(q[3]), .MC15());
    assign O = q[A[5:4]];
endmodule
