// The PicoBlaze (Xilinx KCPSM3) that sequences the SD card, ROM loads and
// the RTC, with EZ Flash's two-bank instruction register in front of it.
//
// Two program BRAMs (bank 1 at X3Y29, bank 2 at X3Y25) are both addressed by
// the program counter; the instruction register picks one by the bank bit
// (port C8) on the falling clock edge. The core itself is the stock KCPSM3
// structure, kept register for register:
//
//   - two cycles per instruction, t_state toggling; the register file and
//     scratchpad are written, and the flags and PC updated, on one phase
//   - the ALU is three partial-result registers, arith (an add/subtract
//     chain), logical and shift, each cleared unless its instruction class
//     is executing, OR-ed into the register write data; INPUT and FETCH
//     data come through the same mux via input_fetch
//   - the stack pointer counts up while t_state is 1 and down while it is
//     0, so it stands still over an instruction; a taken CALL holds it on
//     the down phase (net +1) and a RETURN drops it by two (net -1). The
//     stack RAM is written with the PC at [sp] on every down phase, and
//     its read side is registered into stack_data.
//   - an interrupt sets the PC to $3FF through the flip-flops' REV input,
//     pushes like a CALL, saves the flags and clears int_enable
//
// Instruction fields: ir[17:12] opcode, ir[11:8] sX, ir[7:4] sY, ir[7:0]
// constant, ir[9:0] address. Opcode bits used below (KCPSM3 encodings):
//   LOAD 000000  AND 001010  OR 001100  XOR 001110  TEST 010010
//   COMPARE 010100  ADD 011000 ADDCY 011010 SUB 011100 SUBCY 011110
//   INPUT 000100  FETCH 000110  OUTPUT 101100  STORE 101110
//   shifts 100000  RETURN 101010  CALL 110000  JUMP 110100
//   RETURNI 111000  ENABLE/DISABLE INTERRUPT 111100
//
// Block: stage0/blocks/picoblaze.blk. Register names there match the
// ones here; the LUT RAMs are the s3_ram* shapes with the block's names.

module picoblaze (
    input clk_pb,
    input [17:0] rom_a,         // bank 1 BRAM output
    input [17:0] rom_b,         // bank 2 BRAM output
    input bank,                 // port C8: 1 selects bank 2
    input reset,
    input interrupt,
    input [7:0] in_port,
    output reg [9:0] pc,
    output reg int_ack,
    output reg [7:0] port_id,
    output reg [7:0] out_port,
    output reg read_strobe,
    output reg write_strobe,
    output gnd                  // a constant-0 LUT the design routes to the BRAMs
);
    assign gnd = 1'b0;

    // ---- instruction register, on the falling edge
    reg [17:0] ir;
    always @(negedge clk_pb)
        ir <= bank ? rom_b : rom_a;

    wire [3:0] sx_addr = ir[11:8], sy_addr = ir[7:4];

    // ---- state
    reg t_state, int_q, active_int, int_enable;
    reg [4:0] sp;
    reg [9:0] stack_data;
    reg input_fetch, reg_write, output_store, flag_enable;
    reg carry, zero, saved_carry, saved_zero, shift_carry, arith_carry;
    reg [7:0] arith, logical, shift, scratch_data;

    // ---- decode
    wire is_shift   = ir[17] & !ir[16] & !ir[15] & !ir[14];             // 100xxx
    wire is_call    = ir[17] &  ir[16] & !ir[15] & !ir[14];             // 110000
    wire stack_op   = ir[17] & !ir[14] & (ir[15] | ir[16]);             // CALL, RETURN, RETURNI
    wire jump_class = ir[17] & ((ir[16] & !ir[14]) | (ir[15] & !ir[14]) | (ir[16] & !ir[15]));  // JUMP CALL RETURN RETURNI
    wire input_or_fetch = !ir[17] & !ir[16] & !ir[15] & ir[14];         // 00010x 00011x
    wire io_op = ir[17] & !ir[16] & ir[15];                              // 101xxx: RETURN OUTPUT STORE
    wire int_op = ir[17] & ir[16] & ir[15];                              // RETURNI, ENABLE/DISABLE INTERRUPT

    // conditional: ir[12] set, ir[11:10] = Z, NZ, C, NC
    wire cond_met = ir[11] ? (carry ^ ir[10]) : (zero ^ ir[10]);
    wire cond_ok  = !ir[12] | cond_met;
    wire pc_inc   = !(jump_class & cond_ok);

    // ---- second operand: sY or the constant
    wire [7:0] sx, sy;
    wire [7:0] sy_kk = ir[12] ? sy : ir[7:0];

    // ---- ALU partial results (registered, cleared outside their class)
    wire arith_class = ir[16] & (ir[15] | ir[14]);                      // ADD.. SUB.. COMPARE
    wire logic_class = !ir[17] & !(ir[16] & (ir[15] | ir[14])) & !(ir[14] & !ir[15]);  // LOAD AND OR XOR TEST
    wire arith_cin = ir[14] ? !(ir[13] & carry) : (ir[13] & carry);     // SUB: 1 or !carry; ADD: 0 or carry
    wire [8:0] sum = {1'b0, sx} + {1'b0, sy_kk ^ {8{ir[14]}}} + arith_cin;
    wire [7:0] logic_res = ir[13] ? (ir[14] ? sx ^ sy_kk : sx & sy_kk)
                                  : (ir[14] ? sx | sy_kk : sy_kk);
    wire shift_in = ir[2] ? (ir[1] ? ir[0] : sx[0])        // SL0/SL1/SR0/SR1 a constant, SLX/RR bit 0
                          : (ir[1] ? sx[7] : carry);       // RL/SRX bit 7, SLA/SRA the carry
    wire [7:0] shift_res = ir[3] ? {shift_in, sx[7:1]} : {sx[6:0], shift_in};

    always @(posedge clk_pb) begin
        arith       <= arith_class ? sum[7:0] : 8'h00;
        arith_carry <= arith_class ? (sum[8] ^ ir[14]) : 1'b0;
        logical     <= logic_class ? logic_res : 8'h00;
        shift       <= ir[17] ? shift_res : 8'h00;
        shift_carry <= ir[3] ? sx[0] : sx[7];
    end

    // ---- register write data
    wire [7:0] data_in = input_fetch ? (ir[13] ? scratch_data : in_port)
                                     : (arith | logical | shift);

    // ---- flags
    wire parity = ^logical;
    wire carry_next = (ir[16] & !ir[15] & ir[13]) ? parity         // TEST
                    : (ir[16] & !ir[17])          ? arith_carry
                    : !ir[15]                     ? shift_carry
                    : ir[17]                      ? saved_carry    // RETURNI
                    :                               1'b0;          // AND OR XOR
    wire zero_next = (ir[17] & ir[16]) ? saved_zero : data_in == 8'h00;

    // ---- control registers (one cycle behind the instruction register)
    always @(posedge clk_pb) begin
        input_fetch  <= input_or_fetch;
        reg_write    <= !active_int & (!ir[17] & !ir[16] | !ir[17] & ir[15] | !ir[16] & !ir[15]);
        output_store <= !active_int & io_op;
        flag_enable  <= !ir[17] & (ir[16] | ir[15]) | is_shift | (ir[17] & ir[16] & ir[15] & !ir[14]);
        port_id      <= sy_kk;
        out_port     <= sx;
        int_ack      <= active_int;
        if (active_int) begin
            saved_zero  <= zero;
            saved_carry <= carry;
        end
    end

    always @(posedge clk_pb)
        if (reset) begin
            t_state <= 1'b0; int_q <= 1'b0; active_int <= 1'b0; int_enable <= 1'b0;
            carry <= 1'b0; zero <= 1'b0; read_strobe <= 1'b0; write_strobe <= 1'b0;
        end else begin
            t_state    <= !t_state;
            int_q      <= interrupt;
            active_int <= !active_int & int_enable & int_q & t_state;
            if (active_int | int_op)
                int_enable <= ir[0] & !int_ack & !active_int;
            if (flag_enable & t_state) begin
                carry <= carry_next;
                zero  <= zero_next;
            end
            read_strobe  <= !t_state & !active_int & !ir[17] & !ir[16] & !ir[15] & ir[14] & !ir[13];  // INPUT
            write_strobe <= !t_state & !active_int &  ir[17] & !ir[16] &  ir[15] & ir[14] & !ir[13];  // OUTPUT
        end

    // ---- program counter
    wire [9:0] vector = (ir[15] ? stack_data : ir[9:0]) + ir[13];      // RETURN: stack + 1
    always @(posedge clk_pb)
        if (reset)           pc <= 10'h000;
        else if (active_int) pc <= 10'h3FF;
        else if (!t_state)   pc <= pc_inc ? pc + 10'd1 : vector;

    // ---- stack pointer
    always @(posedge clk_pb)
        if (reset) sp <= 5'd0;
        else if (!active_int) begin
            if (t_state)                  sp <= sp + 5'd1;
            else if (is_call & cond_ok)   sp <= sp;
            else if (stack_op & cond_ok)  sp <= sp - 5'd2;
            else                          sp <= sp - 5'd1;
        end

    // ---- memories: the LUT RAM shapes, one cell set per bit
    wire regs_we = reg_write & t_state;
    wire [9:0] stack_rd;
    wire [7:0] scratch_rd;
    wire scratch_we = output_store & ir[14] & ir[13] & t_state;        // STORE

    s3_ram16x1d regs0 (.A(sx_addr), .DPRA(sy_addr), .WE(regs_we), .CLK(clk_pb), .D(data_in[0]), .SPO(sx[0]), .DPO(sy[0]));
    s3_ram16x1d regs1 (.A(sx_addr), .DPRA(sy_addr), .WE(regs_we), .CLK(clk_pb), .D(data_in[1]), .SPO(sx[1]), .DPO(sy[1]));
    s3_ram16x1d regs2 (.A(sx_addr), .DPRA(sy_addr), .WE(regs_we), .CLK(clk_pb), .D(data_in[2]), .SPO(sx[2]), .DPO(sy[2]));
    s3_ram16x1d regs3 (.A(sx_addr), .DPRA(sy_addr), .WE(regs_we), .CLK(clk_pb), .D(data_in[3]), .SPO(sx[3]), .DPO(sy[3]));
    s3_ram16x1d regs4 (.A(sx_addr), .DPRA(sy_addr), .WE(regs_we), .CLK(clk_pb), .D(data_in[4]), .SPO(sx[4]), .DPO(sy[4]));
    s3_ram16x1d regs5 (.A(sx_addr), .DPRA(sy_addr), .WE(regs_we), .CLK(clk_pb), .D(data_in[5]), .SPO(sx[5]), .DPO(sy[5]));
    s3_ram16x1d regs6 (.A(sx_addr), .DPRA(sy_addr), .WE(regs_we), .CLK(clk_pb), .D(data_in[6]), .SPO(sx[6]), .DPO(sy[6]));
    s3_ram16x1d regs7 (.A(sx_addr), .DPRA(sy_addr), .WE(regs_we), .CLK(clk_pb), .D(data_in[7]), .SPO(sx[7]), .DPO(sy[7]));

    s3_ram32x1s stack0 (.A(sp), .WE(!t_state), .CLK(clk_pb), .D(pc[0]), .O(stack_rd[0]));
    s3_ram32x1s stack1 (.A(sp), .WE(!t_state), .CLK(clk_pb), .D(pc[1]), .O(stack_rd[1]));
    s3_ram32x1s stack2 (.A(sp), .WE(!t_state), .CLK(clk_pb), .D(pc[2]), .O(stack_rd[2]));
    s3_ram32x1s stack3 (.A(sp), .WE(!t_state), .CLK(clk_pb), .D(pc[3]), .O(stack_rd[3]));
    s3_ram32x1s stack4 (.A(sp), .WE(!t_state), .CLK(clk_pb), .D(pc[4]), .O(stack_rd[4]));
    s3_ram32x1s stack5 (.A(sp), .WE(!t_state), .CLK(clk_pb), .D(pc[5]), .O(stack_rd[5]));
    s3_ram32x1s stack6 (.A(sp), .WE(!t_state), .CLK(clk_pb), .D(pc[6]), .O(stack_rd[6]));
    s3_ram32x1s stack7 (.A(sp), .WE(!t_state), .CLK(clk_pb), .D(pc[7]), .O(stack_rd[7]));
    s3_ram32x1s stack8 (.A(sp), .WE(!t_state), .CLK(clk_pb), .D(pc[8]), .O(stack_rd[8]));
    s3_ram32x1s stack9 (.A(sp), .WE(!t_state), .CLK(clk_pb), .D(pc[9]), .O(stack_rd[9]));

    s3_ram64x1s scratch0 (.A(sy_kk[5:0]), .WE(scratch_we), .CLK(clk_pb), .D(sx[0]), .O(scratch_rd[0]));
    s3_ram64x1s scratch1 (.A(sy_kk[5:0]), .WE(scratch_we), .CLK(clk_pb), .D(sx[1]), .O(scratch_rd[1]));
    s3_ram64x1s scratch2 (.A(sy_kk[5:0]), .WE(scratch_we), .CLK(clk_pb), .D(sx[2]), .O(scratch_rd[2]));
    s3_ram64x1s scratch3 (.A(sy_kk[5:0]), .WE(scratch_we), .CLK(clk_pb), .D(sx[3]), .O(scratch_rd[3]));
    s3_ram64x1s scratch4 (.A(sy_kk[5:0]), .WE(scratch_we), .CLK(clk_pb), .D(sx[4]), .O(scratch_rd[4]));
    s3_ram64x1s scratch5 (.A(sy_kk[5:0]), .WE(scratch_we), .CLK(clk_pb), .D(sx[5]), .O(scratch_rd[5]));
    s3_ram64x1s scratch6 (.A(sy_kk[5:0]), .WE(scratch_we), .CLK(clk_pb), .D(sx[6]), .O(scratch_rd[6]));
    s3_ram64x1s scratch7 (.A(sy_kk[5:0]), .WE(scratch_we), .CLK(clk_pb), .D(sx[7]), .O(scratch_rd[7]));

    always @(posedge clk_pb) begin
        stack_data   <= stack_rd;
        scratch_data <= scratch_rd;
    end
endmodule
