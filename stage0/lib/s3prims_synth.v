// The Spartan-3A primitives of re/stage0/sim/s3prims.v in the form yosys
// takes for equivalence checking: the same functions in steady state, with
// the simulation-only parts left out (GSR/GTS start-up, the pad turn-on
// delay, the DCM's measured clocks). Keep the two files in step: any
// behavior that the simulation settles belongs in both.
//
// Strings in parameters are compared as yosys does (== on string params).

module s3_slice #(
    parameter [15:0] F = 16'hFFFF, G = 16'hFFFF,
    parameter SLICEM = 0,
    parameter F_RAM = 0, G_RAM = 0,
    parameter F_SRL = 0, G_SRL = 0,
    parameter DIF_ALT = 1, DIG_ALT = 1,
    parameter WE0USED = 0, WE1USED = 0,
    parameter FXMUX = "F", GYMUX = "G",
    parameter DXMUX = "BX", DYMUX = "BY",
    parameter XBMUX = "FCY", YBMUX = "GCY",
    parameter CYINIT = "BX", CYSELF = 1, CYSELG = 1,
    parameter CY0F = "BX", CY0G = "BY",
    parameter FFX_INIT = 0, FFY_INIT = 0, FFX_SRVAL = 0, FFY_SRVAL = 0,
    parameter FF_LATCH = 0, FF_SR_SYNC = 0, FF_SR_ENABLE = 0, FF_REV_ENABLE = 0,
    parameter BXINV = 0, BYINV = 0
) (
    input F1, F2, F3, F4, G1, G2, G3, G4, BX_i, BY_i, CE, SR, CLK,
    input CIN, FXINA, FXINB, SHIFTIN, ALTDIG, WE1,
    output X, Y, XQ, YQ, XB, YB, COUT, F5, FX, SHIFTOUT, DIG
);
    wire BX = BX_i ^ BXINV, BY = BY_i ^ BYINV;
    reg [15:0] fm = F, gm = G;
    wire [3:0] fa = {F4, F3, F2, F1}, ga = {G4, G3, G2, G1};
    wire fo = fm[fa], go = gm[ga];
    wire fmc15 = fm[15], gmc15 = gm[15];
    assign DIG = DIG_ALT ? (G_SRL ? SHIFTIN : ALTDIG) : BY;
    wire dif = DIF_ALT ? (F_SRL ? gmc15 : DIG) : BX;
    wire we = SR & (!WE1USED || WE1);
    wire fwe = we & (!WE0USED || BX), gwe = we & (!WE0USED || !BX);
    generate if (F_RAM || G_RAM || F_SRL || G_SRL) begin
        always @(posedge CLK) begin
            if (F_SRL && we) fm <= {fm[14:0], dif};
            else if (F_RAM && fwe) fm[ga] <= dif;
            if (G_SRL && we) gm <= {gm[14:0], DIG};
            else if (G_RAM && gwe) gm[ga] <= DIG;
        end
    end endgenerate
    assign SHIFTOUT = fmc15;
    assign F5 = BX ? fo : go;
    assign FX = BY ? FXINA : FXINB;
    wire cyin = (CYINIT == "CIN") ? CIN : BX;
    wire cy0f = (CY0F == "CONST_0") ? 1'b0 : (CY0F == "CONST_1") ? 1'b1 : (CY0F == "F1") ? F1 :
                (CY0F == "F2") ? F2 : (CY0F == "PROD") ? (F1 & F2) : BX;
    wire cy0g = (CY0G == "CONST_0") ? 1'b0 : (CY0G == "CONST_1") ? 1'b1 : (CY0G == "G1") ? G1 :
                (CY0G == "G2") ? G2 : (CY0G == "PROD") ? (G1 & G2) : BY;
    wire psf = CYSELF ? 1'b1 : fo, psg = CYSELG ? 1'b1 : go;
    wire fcy = psf ? cyin : cy0f;
    wire gcy = psg ? fcy : cy0g;
    assign COUT = gcy;
    wire fxor = fo ^ cyin, gxor = go ^ fcy;
    assign X = (FXMUX == "F5") ? F5 : (FXMUX == "FXOR") ? fxor : fo;
    assign Y = (GYMUX == "FX") ? FX : (GYMUX == "GXOR") ? gxor : go;
    assign XB = (XBMUX == "FMC15") ? fmc15 : fcy;
    assign YB = (YBMUX == "GMC15") ? gmc15 : gcy;
    wire dx = (DXMUX == "X") ? X : BX, dy = (DYMUX == "Y") ? Y : BY;
    reg qx = FFX_INIT, qy = FFY_INIT;
    wire srx = FF_SR_ENABLE & SR, rev = FF_REV_ENABLE & BY;
    generate if (FF_LATCH) begin
        always @* begin
            if (srx) begin qx = FFX_SRVAL; qy = FFY_SRVAL; end
            else if (rev) begin qx = !FFX_SRVAL; qy = !FFY_SRVAL; end
            else if (CLK & CE) begin qx = dx; qy = dy; end
        end
    end else if (FF_SR_SYNC) begin
        always @(posedge CLK)
            if (srx) begin qx <= FFX_SRVAL; qy <= FFY_SRVAL; end
            else if (rev) begin qx <= !FFX_SRVAL; qy <= !FFY_SRVAL; end
            else if (CE) begin qx <= dx; qy <= dy; end
    end else begin
        always @(posedge CLK or posedge srx or posedge rev)
            if (srx) begin qx <= FFX_SRVAL; qy <= FFY_SRVAL; end
            else if (rev) begin qx <= !FFX_SRVAL; qy <= !FFY_SRVAL; end
            else if (CE) begin qx <= dx; qy <= dy; end
    end endgenerate
    assign XQ = qx, YQ = qy;
endmodule

// RAMB16: kept as a black box. Blocks are cut at the block RAMs (their
// ports become block ports), so the readable design and the carved
// reference share the same memory primitive rather than proving one.
(* blackbox *)
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
endmodule

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

// IO tile without the pad turn-on delay; the pad is a plain tristate.
module s3_ioi #(parameter MUX_O = "NONE", MUX_T = "NONE", MUX_FFI = "NONE",
                parameter FFO_INIT = 1, FFT_INIT = 1, FFI_INIT = 1,
                parameter FFO1_LATCH = 0, FFO2_LATCH = 0, FFT1_LATCH = 0, FFT2_LATCH = 0, FFI_LATCH = 0,
                parameter FFO_SR_EN = 0, FFO_REV_EN = 0, FFO_SR_SYNC = 0, FFO1_SRVAL = 1, FFO2_SRVAL = 1,
                parameter FFT_SR_EN = 0, FFT_REV_EN = 0, FFT_SR_SYNC = 0, FFT1_SRVAL = 1, FFT2_SRVAL = 1,
                parameter FFI_SR_EN = 0, FFI_REV_EN = 0, FFI_SR_SYNC = 0, FFI1_SRVAL = 1) (
    inout PAD, input O1, O2, T1, T2, OTCLK1, OTCLK2, ICLK1, OCE, TCE, ICE, SR, REV,
    output I, IQ1, CLKPAD
);
    wire ffo1, ffo2, fft1, fft2, ffi;
    s3_iff #(FFO_INIT, FFO1_LATCH, FFO_SR_EN, FFO_REV_EN, FFO_SR_SYNC, FFO1_SRVAL) o1(O1, OTCLK1, OCE, SR, REV, ffo1);
    s3_iff #(FFO_INIT, FFO2_LATCH, FFO_SR_EN, FFO_REV_EN, FFO_SR_SYNC, FFO2_SRVAL) o2(O2, OTCLK2, OCE, SR, REV, ffo2);
    s3_iff #(FFT_INIT, FFT1_LATCH, FFT_SR_EN, FFT_REV_EN, FFT_SR_SYNC, FFT1_SRVAL) t1(T1, OTCLK1, TCE, SR, REV, fft1);
    s3_iff #(FFT_INIT, FFT2_LATCH, FFT_SR_EN, FFT_REV_EN, FFT_SR_SYNC, FFT2_SRVAL) t2(T2, OTCLK2, TCE, SR, REV, fft2);
    s3_iff #(FFI_INIT, FFI_LATCH, FFI_SR_EN, FFI_REV_EN, FFI_SR_SYNC, FFI1_SRVAL) i1(PAD, ICLK1, ICE, SR, REV, ffi);
    wire o = (MUX_O == "O1") ? O1 : (MUX_O == "FFO1") ? ffo1 : (MUX_O == "FFO2") ? ffo2 : 1'b0;
    wire t = (MUX_T == "T1") ? T1 : (MUX_T == "FFT1") ? fft1 : (MUX_T == "FFT2") ? fft2 : 1'b1;
    wire en = MUX_O != "NONE" && !t;
    assign PAD = en ? o : 1'bz;
    assign I = PAD, CLKPAD = PAD, IQ1 = ffi;
endmodule

module s3_bufgmux (input I0, I1, S, output O);
    assign O = S ? I1 : I0;
endmodule

// DCM: a block never contains it; the clocks it makes are block inputs.
(* blackbox *)
module s3_dcm #(parameter FX_MUL = 2, FX_DIV = 1) (
    input CLKIN, CLKFB, RST, PSCLK, PSEN, PSINCDEC,
    output CLK0, CLK2X, CLKFX, LOCKED, output [7:0] STATUS
);
endmodule

(* blackbox *)
module s3_dna #(parameter [56:0] DNA = 57'h0) (input CLK, DIN, READ, SHIFT, output DOUT);
endmodule

(* blackbox *)
module s3_icap (input CLK, CE, WRITE, input [7:0] I, output [7:0] O);
endmodule

module s3_stub (output O);
    assign O = 1'b0;
endmodule
