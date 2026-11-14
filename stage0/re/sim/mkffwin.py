# ffwin.v: report flip-flops quiet in [T0,T1) that change in [T1,T2) (ns)
import re, sys
T0, T1, T2 = sys.argv[1:4]
src = open('../design_di.v').read()
nets = sorted(set(re.findall(r'\b(n_X\d+Y\d+_S\d_[XY]Q)\b', src)))
L = ['`timescale 1ns/1ps', 'module ffwin;', f'  integer a [0:{len(nets)-1}]; integer b [0:{len(nets)-1}]; integer i;',
     f'  initial for (i = 0; i < {len(nets)}; i = i + 1) begin a[i] = 0; b[i] = 0; end']
for i, n in enumerate(nets):
    L.append(f"  always @(tb.dut.{n}) if ($time > 64'd{T0} && $time < 64'd{T1}) a[{i}] = a[{i}] + 1; "
             f"else if ($time >= 64'd{T1} && $time < 64'd{T2}) b[{i}] = b[{i}] + 1;")
L.append(f"  initial begin #(64'd{T2});")
for i, n in enumerate(nets):
    L.append(f'    if (a[{i}] == 0 && b[{i}] > 0) $display("ffwin {n} %0d", b[{i}]);')
L += ['  end', 'endmodule']
open('ffwin.v', 'w').write('\n'.join(L) + '\n')
print(len(nets), 'flip-flops watched')
