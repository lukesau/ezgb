module top(input clk, input [3:0] a, output reg [3:0] q);
  always @(posedge clk) q <= q ^ a;
endmodule
