// The primitives fw4_top.v instantiates, for building it with ISE (XST).
// The same modules as stage0/lib/s3prims_synth.v and stage0/sim/s3prims.v,
// written over the Spartan-3A UNISIM primitives. Placement, IO standards
// and BRAM contents come from the UCF tools/mkise.py writes.

// One IO-tile register, as in s3prims_synth.v. XST makes it an FDCPE or
// LDCPE; map -pr b packs it into the IOB where it fits.
module s3_iff #(parameter INIT = 1, LATCH = 0, SR_EN = 0, REV_EN = 0, SR_SYNC = 0, SRVAL = 0) (
    input D, C, CE, SR, REV, output reg Q = INIT
);
    wire sr = SR_EN && SR, rev = REV_EN && REV;
    generate if (LATCH) begin
        always @* begin if (sr) Q = SRVAL; else if (rev) Q = !SRVAL; else if (C && CE) Q = D; end
    end else if (SR_SYNC) begin
        always @(posedge C) if (sr) Q <= SRVAL; else if (rev) Q <= !SRVAL; else if (CE) Q <= D;
    end else begin
        always @(posedge C or posedge sr or posedge rev)
            if (sr) Q <= SRVAL; else if (rev) Q <= !SRVAL; else if (CE) Q <= D;
    end endgenerate
endmodule

// IO tile: the pad buffer and the tile's registers. CLKPAD is the pad
// through an IBUFG, for the two pins that feed a DCM or a clock buffer.
module s3_ioi #(parameter MUX_O = "NONE", MUX_T = "NONE", MUX_FFI = "NONE",
                parameter FFO_INIT = 1, FFT_INIT = 1, FFI_INIT = 1,
                parameter FFO1_LATCH = 0, FFO2_LATCH = 0, FFT1_LATCH = 0, FFT2_LATCH = 0, FFI_LATCH = 0,
                parameter FFO_SR_EN = 0, FFO_REV_EN = 0, FFO_SR_SYNC = 0, FFO1_SRVAL = 1, FFO2_SRVAL = 1,
                parameter FFT_SR_EN = 0, FFT_REV_EN = 0, FFT_SR_SYNC = 0, FFT1_SRVAL = 1, FFT2_SRVAL = 1,
                parameter FFI_SR_EN = 0, FFI_REV_EN = 0, FFI_SR_SYNC = 0, FFI1_SRVAL = 1,
                parameter CLOCK_PAD = 0) (
    inout PAD, input O1, O2, T1, T2, OTCLK1, OTCLK2, ICLK1, OCE, TCE, ICE, SR, REV,
    output I, IQ1, CLKPAD
);
    wire ffo1, ffo2, fft1, fft2, ffi, pad_i;
    s3_iff #(FFO_INIT, FFO1_LATCH, FFO_SR_EN, FFO_REV_EN, FFO_SR_SYNC, FFO1_SRVAL) o1(O1, OTCLK1, OCE, SR, REV, ffo1);
    s3_iff #(FFO_INIT, FFO2_LATCH, FFO_SR_EN, FFO_REV_EN, FFO_SR_SYNC, FFO2_SRVAL) o2(O2, OTCLK2, OCE, SR, REV, ffo2);
    s3_iff #(FFT_INIT, FFT1_LATCH, FFT_SR_EN, FFT_REV_EN, FFT_SR_SYNC, FFT1_SRVAL) t1(T1, OTCLK1, TCE, SR, REV, fft1);
    s3_iff #(FFT_INIT, FFT2_LATCH, FFT_SR_EN, FFT_REV_EN, FFT_SR_SYNC, FFT2_SRVAL) t2(T2, OTCLK2, TCE, SR, REV, fft2);
    s3_iff #(FFI_INIT, FFI_LATCH, FFI_SR_EN, FFI_REV_EN, FFI_SR_SYNC, FFI1_SRVAL) i1(pad_i, ICLK1, ICE, SR, REV, ffi);
    wire o = (MUX_O == "O1") ? O1 : (MUX_O == "FFO1") ? ffo1 : (MUX_O == "FFO2") ? ffo2 : 1'b0;
    wire t = (MUX_T == "T1") ? T1 : (MUX_T == "FFT1") ? fft1 : (MUX_T == "FFT2") ? fft2 : 1'b1;
    generate if (CLOCK_PAD) begin
        IBUFG ib(.I(PAD), .O(pad_i));
    end else if (MUX_O == "NONE") begin
        IBUF ib(.I(PAD), .O(pad_i));
    end else begin
        IOBUF iob(.IO(PAD), .I(o), .T(t), .O(pad_i));
    end endgenerate
    assign I = pad_i, CLKPAD = pad_i, IQ1 = ffi;
endmodule

// a clock buffer mux with its select tied, written by mkise.py
module s3_bufg (input I, output O);
    BUFG b(.I(I), .O(O));
endmodule

module s3_bufgmux (input I0, I1, S, output O);
    BUFGMUX b(.I0(I0), .I1(I1), .S(S), .O(O));
endmodule

// The block RAM, pin for pin: the port widths are data plus parity bits
// (1, 9, 18 or 36), and its contents are INIT_xx / INITP_xx in the UCF.
module s3_bram #(
    parameter WA = 1, WB = 1, PA = 0, PB = 0,
    parameter MODEA = "WRITE_FIRST", MODEB = "WRITE_FIRST",
    parameter [35:0] INITA = 0, INITB = 0, SRVALA = 0, SRVALB = 0,
    parameter ENA_ATTR = 1, ENB_ATTR = 1,
    parameter DATAFILE = "", PARFILE = ""
) (
    input CLKA, CLKB, ENA, ENB, RSTA, RSTB, input [3:0] WEA, WEB,
    input [13:0] ADDRA, ADDRB, input [31:0] DIA, DIB, input [3:0] DIPA, DIPB,
    output [31:0] DOA, DOB, output [3:0] DOPA, DOPB
);
    RAMB16BWE #(.DATA_WIDTH_A(WA + PA), .DATA_WIDTH_B(WB + PB),
                .WRITE_MODE_A(MODEA), .WRITE_MODE_B(MODEB),
                .INIT_A(INITA), .INIT_B(INITB), .SRVAL_A(SRVALA), .SRVAL_B(SRVALB))
        ram(.CLKA(CLKA), .ENA(ENA), .SSRA(RSTA), .WEA(WEA), .ADDRA(ADDRA), .DIA(DIA), .DIPA(DIPA), .DOA(DOA), .DOPA(DOPA),
            .CLKB(CLKB), .ENB(ENB), .SSRB(RSTB), .WEB(WEB), .ADDRB(ADDRB), .DIB(DIB), .DIPB(DIPB), .DOB(DOB), .DOPB(DOPB));
endmodule

// DCM: only the one fed by P43 (24.545 MHz) is used. The phase shift pins
// are wired as in the bitstream, but phase shifting is off.
module s3_dcm #(parameter FX_MUL = 2, FX_DIV = 1) (
    input CLKIN, CLKFB, RST, PSCLK, PSEN, PSINCDEC,
    output CLK0, CLK2X, CLKFX, LOCKED, output [7:0] STATUS
);
    DCM_SP #(.CLKFX_MULTIPLY(FX_MUL), .CLKFX_DIVIDE(FX_DIV), .CLKIN_PERIOD(40.74),
             .CLK_FEEDBACK("1X"), .CLKOUT_PHASE_SHIFT("NONE"), .DFS_FREQUENCY_MODE("LOW"),
             .DLL_FREQUENCY_MODE("LOW"), .DUTY_CYCLE_CORRECTION("TRUE"), .STARTUP_WAIT("FALSE"))
        dcm(.CLKIN(CLKIN), .CLKFB(CLKFB), .RST(RST), .PSCLK(PSCLK), .PSEN(PSEN), .PSINCDEC(PSINCDEC),
            .DSSEN(1'b0), .CLK0(CLK0), .CLK2X(CLK2X), .CLKFX(CLKFX), .LOCKED(LOCKED), .STATUS(STATUS));
endmodule

module s3_dna #(parameter [56:0] DNA = 57'h0) (input CLK, DIN, READ, SHIFT, output DOUT);
    DNA_PORT d(.CLK(CLK), .DIN(DIN), .READ(READ), .SHIFT(SHIFT), .DOUT(DOUT));
endmodule

module s3_icap (input CLK, CE, WRITE, input [7:0] I, output [7:0] O);
    ICAP_SPARTAN3A i(.CLK(CLK), .CE(CE), .WRITE(WRITE), .I(I), .O(O), .BUSY());
endmodule

module s3_stub (output O);
    assign O = 1'b0;
endmodule

// The LUT RAM shapes of stage0/lib/s3bels.v, as the primitives they are.
module s3_ram16x1d #(parameter [15:0] INIT = 16'h0000) (
    input [3:0] A, DPRA, input WE, CLK, D, output SPO, DPO
);
    RAM16X1D #(.INIT(INIT)) r(.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]),
        .DPRA0(DPRA[0]), .DPRA1(DPRA[1]), .DPRA2(DPRA[2]), .DPRA3(DPRA[3]),
        .WE(WE), .WCLK(CLK), .D(D), .SPO(SPO), .DPO(DPO));
endmodule

module s3_ram32x1s #(parameter [31:0] INIT = 32'h0) (
    input [4:0] A, input WE, CLK, D, output O
);
    RAM32X1S #(.INIT(INIT)) r(.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]),
        .WE(WE), .WCLK(CLK), .D(D), .O(O));
endmodule

module s3_ram64x1s #(parameter [63:0] INIT = 64'h0) (
    input [5:0] A, input WE, CLK, D, output O
);
    RAM64X1S #(.INIT(INIT)) r(.A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]), .A4(A[4]), .A5(A[5]),
        .WE(WE), .WCLK(CLK), .D(D), .O(O));
endmodule
