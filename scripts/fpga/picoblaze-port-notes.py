#!/usr/bin/env python3
"""Carry a PicoBlaze annotation file from one build to another.

    picoblaze-port-notes.py OLD_BRAM_PREFIX OLD_NOTES NEW_BRAM_PREFIX > NEW_NOTES

Routines are matched the way picoblaze-diff.py matches them (identical after
normalizing addresses, else the most similar above 0.5), instructions inside
a matched pair are aligned, and every address-keyed annotation (label, sub,
note, block, entry) moves to its new address. Port, scratchpad, register and
constant names are copied as they are. Annotations whose instruction has no
counterpart are listed at the end as comments for a person to place."""
import difflib, importlib.util, os, sys

spec = importlib.util.spec_from_file_location(
    "pd", os.path.join(os.path.dirname(os.path.abspath(__file__)), "picoblaze-dis.py"))
pd = importlib.util.module_from_spec(spec)
spec.loader.exec_module(pd)

def funcs(path):
    w = pd.load_words(path); ins = [pd.Insn(a, x) for a, x in enumerate(w)]
    reach, callers, jumpers = pd.trace(ins)
    entries = sorted(set(callers) | {0, 0x3FF} | {ins[0x3FF].target})
    F = {}
    for k, e in enumerate(entries):
        end = entries[k + 1] if k + 1 < len(entries) else 1024
        F[e] = [a for a in range(e, end) if a in reach]
    def norm(a, e, body):
        i = ins[a]
        if i.flow in ("jump", "call"):
            t = i.target
            tgt = f"+{t - e:03X}" if t in body else ("FN" if t in F else "EXT")
            return f"{i.mn} {i.cond or ''} {tgt}"
        return f"{i.mn} {', '.join(i.ops)}"
    return F, {e: [norm(a, e, b) for a in b] for e, b in F.items()}

oldb, oldn, newb = sys.argv[1:4]
FA, NA = funcs(oldb); FB, NB = funcs(newb)
amap, used = {}, set()
key = lambda L: "\n".join(L)
byB = {}
for e, v in NB.items(): byB.setdefault(key(v), []).append(e)
pairs = []
for ea, va in NA.items():
    cand = [e for e in byB.get(key(va), []) if e not in used]
    if cand: pairs.append((ea, cand[0], 1.0)); used.add(cand[0])
done = {p[0] for p in pairs}
for ea, va in NA.items():
    if ea in done: continue
    best, r = None, 0
    for eb, vb in NB.items():
        if eb in used: continue
        x = difflib.SequenceMatcher(None, va, vb).ratio()
        if x > r: best, r = eb, x
    if best is not None and r > 0.5: pairs.append((ea, best, r)); used.add(best)
for ea, eb, r in pairs:
    sm = difflib.SequenceMatcher(None, NA[ea], NB[eb], autojunk=False)
    for blk in sm.get_matching_blocks():
        for k in range(blk.size):
            amap[FA[ea][blk.a + k]] = FB[eb][blk.b + k]
    amap.setdefault(ea, eb)

lost = []
out = [f"# carried from {os.path.basename(oldn)} by picoblaze-port-notes.py; "
       f"{sum(1 for p in pairs if p[2] == 1.0)} routines identical, "
       f"{sum(1 for p in pairs if p[2] < 1.0)} matched by similarity, {len(NB) - len(pairs)} new"]
for raw in open(oldn):
    line = raw.rstrip("\n")
    s = line.strip()
    if not s or s.startswith("#"):
        out.append(line); continue
    kw, rest = s.split(None, 1)
    if kw in ("label", "sub", "note", "block", "entry"):
        a, *tail = rest.split(None, 1)
        old = int(a, 16)
        if old in amap:
            out.append(f"{kw} {amap[old]:03X}" + (" " + tail[0] if tail else ""))
        else:
            lost.append(line)
    else:
        out.append(line)
if lost:
    out.append("")
    out.append(f"# ---- {len(lost)} annotations with no counterpart in this build ----")
    out += ["# " + l for l in lost]
print("\n".join(out))
