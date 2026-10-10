#!/usr/bin/env python3
"""Routine-level diff of two PicoBlaze programs (e.g. one bank across firmware builds).

    picoblaze-diff.py OLD_BRAM_PREFIX NEW_BRAM_PREFIX

Splits each program into routines (every CALL target, reset, interrupt
handler), normalizes away absolute addresses (jumps inside a routine become
relative, calls and jumps out of it become FN / EXT), then reports how many
routines are identical, pairs up changed ones by similarity and prints an
instruction diff for each, plus routines that are new or removed. Place and
route moves everything around between builds; this shows what changed in the
code.
"""
import difflib
import importlib.util
import os
import sys

spec = importlib.util.spec_from_file_location(
    "pd", os.path.join(os.path.dirname(os.path.abspath(__file__)), "picoblaze-dis.py"))
pd = importlib.util.module_from_spec(spec)
spec.loader.exec_module(pd)
def funcs(path):
    w=pd.load_words(path); ins=[pd.Insn(a,x) for a,x in enumerate(w)]
    reach,callers,jumpers=pd.trace(ins)
    entries=sorted(set(callers)|{0,0x3FF}|{ins[0x3FF].target})
    F={}
    for k,e in enumerate(entries):
        end=entries[k+1] if k+1<len(entries) else 1024
        body=[a for a in range(e,end) if a in reach]
        F[e]=body
    def norm(a,e,body):
        i=ins[a]
        if i.flow in("jump","call"):
            t=i.target
            tgt=f"+{t-e:03X}" if t in body else ("FN" if t in F else "EXT")
            return f"{i.mn} {i.cond or ''} {tgt}"
        return f"{i.mn} {', '.join(i.ops)}"
    N={e:[norm(a,e,b) for a in b] for e,b in F.items()}
    return w,ins,F,N
wa,ia,FA,NA=funcs(sys.argv[1]); wb,ib,FB,NB=funcs(sys.argv[2])
key=lambda L:"\n".join(L)
byA={};[byA.setdefault(key(v),[]).append(e) for e,v in NA.items()]
byB={};[byB.setdefault(key(v),[]).append(e) for e,v in NB.items()]
same=[k for k in byA if k in byB]
onlyA=[e for e,v in NA.items() if key(v) not in byB]
onlyB=[e for e,v in NB.items() if key(v) not in byA]
print(f"functions: A {len(NA)}  B {len(NB)}  identical {sum(len(byA[k]) for k in same)}  changed/removed in A {len(onlyA)}  changed/new in B {len(onlyB)}")
# pair unmatched by best similarity
used=set()
for eb in onlyB:
    best=max(onlyA,key=lambda ea:difflib.SequenceMatcher(None,NA[ea],NB[eb]).ratio(),default=None)
    r=difflib.SequenceMatcher(None,NA[best],NB[eb]).ratio() if best is not None else 0
    if r>0.5 and best not in used:
        used.add(best)
        print(f"\n=== changed: A ${best:03X} ({len(NA[best])}) -> B ${eb:03X} ({len(NB[eb])})  similarity {r:.2f}")
        la=[f"{a:03X} "+NA[best][k] for k,a in enumerate(FA[best])]
        lb=[f"{a:03X} "+NB[eb][k] for k,a in enumerate(FB[eb])]
        sm=difflib.SequenceMatcher(None,NA[best],NB[eb])
        for op,i1,i2,j1,j2 in sm.get_opcodes():
            if op=="equal": continue
            for l in la[i1:i2]: print("  - "+l)
            for l in lb[j1:j2]: print("  + "+l)
    else:
        print(f"\n=== new in B: ${eb:03X} ({len(NB[eb])} insns)")
        for k,a in enumerate(FB[eb]): print(f"  + {a:03X} {NB[eb][k]}")
for ea in onlyA:
    if ea not in used:
        print(f"\n=== removed from A: ${ea:03X} ({len(NA[ea])} insns)")
        for k,a in enumerate(FA[ea]): print(f"  - {a:03X} {NA[ea][k]}")
