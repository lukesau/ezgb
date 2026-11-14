#!/usr/bin/env python3
"""snap.v: a `snapshot(tag)` task that writes every slice output (X, Y, XQ,
YQ) of the exported design to snap.txt, one line per net: tag, net, value.
Testbenches call tb.snap.snapshot(...) at the moments they want to compare.
usage (from the sim directory): mksnap.py DESIGN.v"""
import re, sys
src = open(sys.argv[1]).read()
nets = sorted(set(re.findall(r'\b(n_X\d+Y\d+_S\d_(?:X|Y|XQ|YQ))\b', src)))
L = ['`timescale 1ns/1ps', 'module snap;', '  integer fd;', '  initial fd = $fopen("snap.txt", "w");',
     '  task snapshot(input integer tag);', '    begin']
for n in nets:
    L.append(f'      $fwrite(fd, "%0d {n} %b\\n", tag, tb.dut.{n});')
L += ['    end', '  endtask', 'endmodule']
open('snap.v', 'w').write('\n'.join(L) + '\n')
print(len(nets), 'nets')
