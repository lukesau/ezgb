import json, sys, collections
cells={}
for line in open(sys.argv[1]):
    c=json.loads(line); cells[(c['tile'],c['bel'])]=c
def src(cell,pin):
    s=cell['in'].get(pin)
    return s if s else [None,0]
def comb(pin):
    """pin 'TILE:BEL:OUT' -> (lut_name, [input pins]) if combinational LUT output, else None"""
    t,b,o=pin.rsplit(':',2) if pin.count(':')>2 else pin.split(':')
    c=cells.get((t,b))
    if not c or not b.startswith('SLICE'): return None
    a=c['attrs']
    if o=='X' and a.get('FXMUX')=='F': return ('F',[src(c,'F%d'%i) for i in range(1,5)],a.get('F'))
    if o=='Y' and a.get('GYMUX')=='G': return ('G',[src(c,'G%d'%i) for i in range(1,5)],a.get('G'))
    return None
def cone(pin,depth=0,seen=None,leaves=None,luts=None):
    if seen is None: seen=set(); leaves=collections.Counter(); luts=[]
    if pin is None: leaves['<none>']+=1; return seen,leaves,luts
    if pin in seen: return seen,leaves,luts
    seen.add(pin)
    r=comb(pin)
    if r is None or depth>12:
        leaves[pin]+=1; return seen,leaves,luts
    luts.append((pin,r[0],r[2],[s[0] for s in r[1]]))
    for s,inv in r[1]:
        cone(s,depth+1,seen,leaves,luts)
    return seen,leaves,luts
def show(pin, depth=0, inv=0, seen=None):
    if seen is None: seen=set()
    pad='  '*depth
    r=comb(pin) if pin else None
    if r is None:
        print(f"{pad}{'~' if inv else ''}{pin}"); return
    if pin in seen:
        print(f"{pad}{'~' if inv else ''}{pin} (again)"); return
    seen.add(pin)
    print(f"{pad}{'~' if inv else ''}{pin} LUT {r[0]}={r[2]} ({int(r[2],2):04X})")
    for s,i in r[1]:
        show(s, depth+1, i, seen)
