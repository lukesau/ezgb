import json, sys, collections
net=sys.argv[1]
cells={}
for l in open(net):
    c=json.loads(l); cells[(c['tile'],c['bel'])]=c
pins={}
for l in open('vq100-pins.txt'):
    p,pad=l.split('\t'); pad=pad.strip()
    if '.IOI[' in pad and pad.endswith('.PAD'):
        t,rest=pad.split('.IOI['); pins[f"{t}.BEL:IOI[{rest[0]}]"]=p
sinks=collections.defaultdict(list)
for (t,b),c in cells.items():
    for p,(s,i) in c['in'].items():
        if s: sinks[s].append(f"{t}:{b}:{p}".replace('.BEL',''))
rows=[]
for io,p in pins.items():
    t,b=io.split(':'); c=cells.get((t,b))
    if not c: continue
    o=c['in'].get('O1',[None])[0]; tr=c['in'].get('T1',[None])[0]
    ins=sinks.get(io+':I',[])+sinks.get(io+':IQ1',[])+sinks.get(io+':IQ2',[])
    if not o and not ins: continue
    d='bidir' if o and tr and ins else 'out' if o else 'in'
    rows.append((int(p[1:]),p,io.replace('.BEL',''),d,len(ins),(o or '').replace('.BEL','')))
for r in sorted(rows): print("%-5s %-16s %-5s sinks=%-3d drv=%s" % r[1:])
print(len(rows),"used IO pins")
