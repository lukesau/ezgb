exec(open('vterm.py').read().split("for k in (2,1):")[0])
cube=B.cubes(R,1)[0]
assign={n:0 for n in B.names}
assign.update(cube)
def val(f):
    x=f
    while isinstance(x,tuple): x = x[2] if assign[B.names[x[0]]] else x[1]
    return x
print("state:", {n:v for n,v in cube.items()})
def show(pin, depth=0, inv=0, seen=None, maxd=3):
    if seen is None: seen=set()
    pad='  '*depth
    if pin is None: print(pad+"(unused)"); return
    v=val(memo[pin]) if pin in memo else assign.get(pin,'?')
    r=comb(pin); c=cells.get(tuple(pin.split(':')[:2]))
    tag=('LUT '+r[0]+'='+format(int(r[2],2),'04X')) if r else (('F5 F='+format(int(c['attrs']['F'],2),'04X')+' G='+format(int(c['attrs']['G'],2),'04X')) if c and pin.endswith(':X') and c['attrs'].get('FXMUX')=='F5' else 'leaf')
    print(f"{pad}{'~' if inv else ''}{pin} = {v ^ inv if isinstance(v,int) else v}  [{tag}]")
    if depth>=maxd or pin in seen: return
    seen.add(pin)
    if r:
        for s,i in r[1]: show(s,depth+1,i,seen,maxd)
    elif tag.startswith('F5'):
        for nm in ['BX','F1','F2','F3','F4']:
            s=c['in'].get(nm,[None,0]); print(f"{pad}  {nm}:"); show(s[0],depth+2,s[1],seen,maxd)
for k in (2,1):
    t=bits[k]; tt,b=t.split(':'); p,inv=cells[(tt,b)]['in']['O1']
    print(f"===== D{k}"); show(p,0,inv,maxd=3)
