// Behavioral models of the Spartan-3A primitives the FW4 netlist uses,
// written from prjcombine's documentation (docs/src/spartan3/clb.md):
// F5 = BX ? F : G, and with SLICEWE0USED the F LUT is written when BX = 1.
// Simulation of the real design confirms the F5 convention: with it the
// PicoBlaze switches program banks exactly as its code says.
// Parameters carry the bitstream attributes as strings or bit vectors, in
// the netlist's encoding (s3trace --netlist). Not a timing model.
`timescale 1ns/1ps

// Start-up, as in Xilinx's own simulation libraries: GSR holds every
// flip-flop at its INIT value and GTS keeps every pin undriven until the
// configuration start-up sequence releases them.
module glbl;
    reg GSR = 1, GTS = 1;
    initial begin #100 GSR = 0; #20 GTS = 0; end
endmodule

module s3_slice #(
    parameter [15:0] F = 16'hFFFF, G = 16'hFFFF,
    parameter SLICEM = 0,
    parameter F_RAM = 0, G_RAM = 0,      // LUT RAM (RAM_ENABLE=1, SHIFT_ENABLE=0)
    parameter F_SRL = 0, G_SRL = 0,      // shift register mode
    parameter DIF_ALT = 1, DIG_ALT = 1,
    parameter WE0USED = 0, WE1USED = 0,
    parameter FXMUX = "F", GYMUX = "G",  // F|F5|FXOR, G|FX|GXOR
    parameter DXMUX = "BX", DYMUX = "BY",
    parameter XBMUX = "FCY", YBMUX = "GCY",
    parameter CYINIT = "BX", CYSELF = 1, CYSELG = 1, // CYSEL: 1 = CONST_1, 0 = LUT
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
    // LUT RAM / SRL writes (CLK = write clock, SR = write enable)
    wire fmc15 = fm[15], gmc15 = gm[15];
    assign DIG = DIG_ALT ? (G_SRL ? SHIFTIN : ALTDIG) : BY;
    wire dif = DIF_ALT ? (F_SRL ? gmc15 : DIG) : BX;
    wire we = SR & (!WE1USED || WE1);
    // SLICEWE0USED: BX is address bit 4; F holds the BX=1 half, G the BX=0 half
    wire fwe = we & (!WE0USED || BX), gwe = we & (!WE0USED || !BX);
    always @(posedge CLK) if (!glbl.GSR) begin
        if (F_SRL && we) fm <= {fm[14:0], dif};
        else if (F_RAM && fwe) fm[ga] <= dif;
        if (G_SRL && we) gm <= {gm[14:0], DIG};
        else if (G_RAM && gwe) gm[ga] <= DIG;
    end
    assign SHIFTOUT = fmc15;
    // wide muxes and carry
    assign F5 = BX ? fo : go;
    assign FX = BY ? FXINA : FXINB;
    wire cyin = (CYINIT == "CIN") ? CIN : BX;
    wire cy0f = (CY0F == "CONST_0") ? 1'b0 : (CY0F == "CONST_1") ? 1'b1 : (CY0F == "F1") ? F1 :
                (CY0F == "F2") ? F2 : (CY0F == "PROD") ? (F1 & F2) : BX;
    wire cy0g = (CY0G == "CONST_0") ? 1'b0 : (CY0G == "CONST_1") ? 1'b1 : (CY0G == "G1") ? G1 :
                (CY0G == "G2") ? G2 : (CY0G == "PROD") ? (G1 & G2) : BY;
    wire psf = CYSELF ? 1'b1 : fo, psg = CYSELG ? 1'b1 : go;
    // MUXCY: O = S ? CI : DI (S = propagate)
    wire fcy = psf ? cyin : cy0f;
    wire gcy = psg ? fcy : cy0g;
    assign COUT = gcy;
    wire fxor = fo ^ cyin, gxor = go ^ fcy;
    assign X = (FXMUX == "F5") ? F5 : (FXMUX == "FXOR") ? fxor : fo;
    assign Y = (GYMUX == "FX") ? FX : (GYMUX == "GXOR") ? gxor : go;
    assign XB = (XBMUX == "FMC15") ? fmc15 : fcy;
    assign YB = (YBMUX == "GMC15") ? gmc15 : gcy;
    // registers
    wire dx = (DXMUX == "X") ? X : BX, dy = (DYMUX == "Y") ? Y : BY;
    reg qx = FFX_INIT, qy = FFY_INIT;
    wire srx = FF_SR_ENABLE & SR, rev = FF_REV_ENABLE & BY;
    // REV (BY, when FF_REV_ENABLE) sets the opposite of SRVAL; SR wins over it
    generate if (FF_LATCH) begin
        always @* if (glbl.GSR) begin qx = FFX_INIT; qy = FFY_INIT; end
                  else if (srx) begin qx = FFX_SRVAL; qy = FFY_SRVAL; end
                  else if (rev) begin qx = !FFX_SRVAL; qy = !FFY_SRVAL; end
                  else if (CLK & CE) begin qx = dx; qy = dy; end
    end else if (FF_SR_SYNC) begin
        always @(posedge CLK or posedge glbl.GSR)
            if (glbl.GSR) begin qx <= FFX_INIT; qy <= FFY_INIT; end
            else if (srx) begin qx <= FFX_SRVAL; qy <= FFY_SRVAL; end
            else if (rev) begin qx <= !FFX_SRVAL; qy <= !FFY_SRVAL; end
            else if (CE) begin qx <= dx; qy <= dy; end
    end else begin
        always @(posedge CLK or posedge srx or posedge rev or posedge glbl.GSR)
            if (glbl.GSR) begin qx <= FFX_INIT; qy <= FFY_INIT; end
            else if (srx) begin qx <= FFX_SRVAL; qy <= FFY_SRVAL; end
            else if (rev) begin qx <= !FFX_SRVAL; qy <= !FFY_SRVAL; end
            else if (CE) begin qx <= dx; qy <= dy; end
    end endgenerate
    assign XQ = qx, YQ = qy;
endmodule

// RAMB16, both ports; width in data bits (1, 2, 4, 8, 16, 32) plus parity
module s3_bram #(
    parameter WA = 1, WB = 1,            // data bits per port
    parameter PA = 0, PB = 0,            // parity bits per port
    parameter MODEA = "WRITE_FIRST", MODEB = "WRITE_FIRST",
    parameter [35:0] INITA = 0, INITB = 0, SRVALA = 0, SRVALB = 0,
    parameter ENA_ATTR = 1, ENB_ATTR = 1,
    parameter DATAFILE = "", PARFILE = ""
) (
    input CLKA, CLKB, ENA, ENB, RSTA, RSTB, input [3:0] WEA, WEB,
    input [13:0] ADDRA, ADDRB, input [31:0] DIA, DIB, input [3:0] DIPA, DIPB,
    output reg [31:0] DOA, DOB, output reg [3:0] DOPA, DOPB
);
    reg [0:0] mem [0:16383];
    reg [0:0] par [0:2047];
    integer k;
    initial begin
        // the bitstream initializes every BRAM; no blob means all zeros
        for (k = 0; k < 16384; k = k + 1) mem[k] = 0;
        for (k = 0; k < 2048; k = k + 1) par[k] = 0;
        if (DATAFILE != "") $readmemb(DATAFILE, mem);
        if (PARFILE != "") $readmemb(PARFILE, par);
        {DOPA, DOA} = INITA; {DOPB, DOB} = INITB;
    end
    function integer lg(input integer w); lg = w >= 32 ? 5 : w >= 16 ? 4 : w >= 8 ? 3 : w >= 4 ? 2 : w >= 2 ? 1 : 0; endfunction
    localparam LA = lg(WA), LB = lg(WB);
    integer i;
    always @(posedge CLKA) if (ENA & ENA_ATTR) begin
        if (RSTA) {DOPA, DOA} <= SRVALA;
        else if (MODEA == "READ_FIRST" || !WEA[0]) begin
            for (i = 0; i < WA; i = i + 1) DOA[i] <= mem[(ADDRA >> LA << LA) + i];
            for (i = 0; i < PA; i = i + 1) DOPA[i] <= par[((ADDRA >> LA << LA) >> 3) + i];
        end
        if (WEA[0]) begin
            for (i = 0; i < WA; i = i + 1) mem[(ADDRA >> LA << LA) + i] <= DIA[i];
            for (i = 0; i < PA; i = i + 1) par[((ADDRA >> LA << LA) >> 3) + i] <= DIPA[i];
            if (MODEA == "WRITE_FIRST" && !RSTA) begin
                for (i = 0; i < WA; i = i + 1) DOA[i] <= DIA[i];
                for (i = 0; i < PA; i = i + 1) DOPA[i] <= DIPA[i];
            end
        end
    end
    always @(posedge CLKB) if (ENB & ENB_ATTR) begin
        if (RSTB) {DOPB, DOB} <= SRVALB;
        else if (MODEB == "READ_FIRST" || !WEB[0]) begin
            for (i = 0; i < WB; i = i + 1) DOB[i] <= mem[(ADDRB >> LB << LB) + i];
            for (i = 0; i < PB; i = i + 1) DOPB[i] <= par[((ADDRB >> LB << LB) >> 3) + i];
        end
        if (WEB[0]) begin
            for (i = 0; i < WB; i = i + 1) mem[(ADDRB >> LB << LB) + i] <= DIB[i];
            for (i = 0; i < PB; i = i + 1) par[((ADDRB >> LB << LB) >> 3) + i] <= DIPB[i];
            if (MODEB == "WRITE_FIRST" && !RSTB) begin
                for (i = 0; i < WB; i = i + 1) DOB[i] <= DIB[i];
                for (i = 0; i < PB; i = i + 1) DOPB[i] <= DIPB[i];
            end
        end
    end
endmodule

// One IO-tile register: flip-flop on the rising edge of C, or latch
// transparent while C is high; SR forces SRVAL and REV forces !SRVAL when
// enabled (SR wins), asynchronously unless SR_SYNC.
module s3_iff #(parameter INIT = 1, LATCH = 0, SR_EN = 0, REV_EN = 0, SR_SYNC = 0, SRVAL = 0) (
    input D, C, CE, SR, REV, output reg Q = INIT
);
    wire sr = SR_EN && SR, rev = REV_EN && REV;
    generate if (LATCH) begin
        always @* if (glbl.GSR) Q = INIT; else if (sr) Q = SRVAL; else if (rev) Q = !SRVAL; else if (C && CE) Q = D;
    end else if (SR_SYNC) begin
        always @(posedge C or posedge glbl.GSR)
            if (glbl.GSR) Q <= INIT; else if (sr) Q <= SRVAL; else if (rev) Q <= !SRVAL; else if (CE) Q <= D;
    end else begin
        always @(posedge C or posedge sr or posedge rev or posedge glbl.GSR)
            if (glbl.GSR) Q <= INIT; else if (sr) Q <= SRVAL; else if (rev) Q <= !SRVAL; else if (CE) Q <= D;
    end endgenerate
endmodule

// IO tile: output and tristate straight from O1/T1 or through the FFO1/FFO2
// and FFT1/FFT2 registers (clocked by OTCLK1/OTCLK2), input straight through
// or registered on ICLK1. Register options are the bitstream's: latch mode,
// SR/REV enables, SRVAL, sync or async. The exporter ties unrouted enables
// (OCE/TCE/ICE) high.
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
    assign PAD = (MUX_O != "NONE" && !t && !glbl.GTS) ? o : 1'bz;
    assign I = PAD, CLKPAD = PAD, IQ1 = ffi;
endmodule

module s3_bufgmux (input I0, I1, S, output O);
    assign O = S ? I1 : I0;
endmodule

// DCM for simulation: CLK0 follows CLKIN; CLK2X and CLKFX are generated
// from the period measured on CLKIN (CLKFX = CLKIN * FX_MUL / FX_DIV).
module s3_dcm #(parameter FX_MUL = 2, FX_DIV = 1) (
    input CLKIN, CLKFB, RST, PSCLK, PSEN, PSINCDEC,
    output CLK0, output reg CLK2X = 0, output reg CLKFX = 0, output LOCKED, output [7:0] STATUS
);
    assign CLK0 = CLKIN, LOCKED = 1'b1, STATUS = 8'b0;
    realtime last = 0, period = 0;
    always @(posedge CLKIN) begin
        if (last > 0) period = $realtime - last;
        last = $realtime;
    end
    always begin
        if (period > 0) begin #(period / 4) CLK2X = !CLK2X; end else #10;
    end
    always begin
        if (period > 0) begin #(period * FX_DIV / FX_MUL / 2) CLKFX = !CLKFX; end else #10;
    end
endmodule

// DNA_PORT: READ loads the 57-bit Device DNA, SHIFT shifts it out MSB
// first on CLK (DIN in at the bottom); DOUT is the top bit.
module s3_dna #(parameter [56:0] DNA = 57'h0) (input CLK, DIN, READ, SHIFT, output DOUT);
    reg [56:0] sr = DNA;
    always @(posedge CLK)
        if (READ) sr <= DNA;
        else if (SHIFT) sr <= {sr[55:0], DIN};
    assign DOUT = sr[56];
endmodule

module s3_stub (output O);
    assign O = 1'b0;
endmodule
