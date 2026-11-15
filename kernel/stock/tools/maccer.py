#!/usr/bin/env python3
"""maccer.py IN.ms OUT.s: GBDK's maccer step, enough for GBDK 2.96a's font.ms.

GBDK builds its .ms sources with maccer, a macro expander: `INCLUDE "x.mh"`
reads macro definitions (`NAME MACRO` ... `ENDM`) and each line that names
a macro is replaced by its body. Only argument-free macros are handled,
which is all font.ms uses.
"""
import os
import re
import sys

src, out = sys.argv[1], sys.argv[2]
macros = {}


def load(path):
    name = None
    for line in open(path):
        m = re.match(r"(\w+)\s+MACRO\b", line)
        if m:
            name, macros[m.group(1)] = m.group(1), []
        elif re.match(r"\s+ENDM\b", line):
            name = None
        elif name:
            macros[name].append(line)


lines = []
for line in open(src):
    m = re.match(r'\s*INCLUDE\s+"([^"]+)"', line)
    if m:
        load(os.path.join(os.path.dirname(src), m.group(1)))
        continue
    m = re.match(r"\s+(\w+)\s*(;.*)?$", line)
    if m and m.group(1) in macros:
        lines += macros[m.group(1)]
        continue
    lines.append(line)
open(out, "w").write("".join(lines))
