# bitmatch.v: at every memory write strobe (P40 falling) during a ROM load,
# compare every slice output with bits 12-14 of the write's byte offset;
# report nets that always match (or always match inverted).
import re, sys
T0, T1 = sys.argv[1:3]
src = open('../design_di.v').read()
nets = sorted(set(re.findall(r'\b(n_X\d+Y\d+_S\d_(?:X|Y|XQ|YQ))\b', src)))
N = len(nets)
L = ['`timescale 1ns/1ps', 'module bitmatch;',
     f'  integer m [0:{3*N-1}]; integer i, k = 0; reg pw = 1; reg [2:0] b;',
     f'  initial for (i = 0; i < {3*N}; i = i + 1) m[i] = 0;',
     '  always #2 begin',
     f"    if ($time > 64'd{T0} && $time < 64'd{T1} && tb.P40 === 1'b0 && pw === 1'b1) begin",
     '      b = k >> 12;']
for i, n in enumerate(nets):
    L.append(f'      if (tb.dut.{n} !== b[0]) m[{3*i}] = m[{3*i}] + 1; if (tb.dut.{n} !== b[1]) m[{3*i+1}] = m[{3*i+1}] + 1; if (tb.dut.{n} !== b[2]) m[{3*i+2}] = m[{3*i+2}] + 1;')
L += ['      k = k + 1;', '    end', '    pw = tb.P40;', '  end', f"  initial begin #(64'd{T1}); #10;",
      '    $display("bitmatch: %0d writes", k);']
for i, n in enumerate(nets):
    for j in range(3):
        L.append(f'    if (m[{3*i+j}] == 0) $display("bitmatch {n} = offset bit {12+j}"); else if (m[{3*i+j}] == k) $display("bitmatch {n} = NOT offset bit {12+j}");')
L += ['  end', 'endmodule']
open('bitmatch.v', 'w').write('\n'.join(L) + '\n')
print(N, 'nets')
