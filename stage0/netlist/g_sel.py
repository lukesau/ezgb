import os
NETFILE=os.environ['NET']; os.environ['F5']='G'
exec(open('g_const.py').read().split("for byte in (0x04")[0])
ver=int(os.environ['VER'],16)
V=const_byte(ver)
cube=B.cubes(V,1)[0]
# nodes that are 1 in the version state and whose control function is small: candidate selects
def ctl(pin): return B.restrict(memo[pin],{n:0 for n in data})
def at(f,assign):
    x=f
    while isinstance(x,tuple): x = x[2] if assign.get(B.names[x[0]],0) else x[1]
    return x
hits=[]
for pin in memo:
    f=ctl(pin)
    if f in (0,1): continue
    if at(f,cube)==1 and B.AND(V,B.NOT(f))==0:
        sup=B.support(f)
        if len(sup)<=8:
            hits.append((len(sup),pin,sorted(sup)))
for n,pin,sup in sorted(hits)[:12]:
    c=cells.get(tuple(pin.split(':')[:2])); r=comb(pin)
    tag=('LUT '+r[0]+'='+format(int(r[2],2),'04X')) if r else c['attrs'].get('FXMUX','?')
    sinks=[f"{t}:{b}:{p}" for (t,b),cc in cells.items() for p,(s,i) in cc['in'].items() if s==pin]
    print(n, pin, tag); print("     inputs:", " ".join(s.replace('.BEL','') for s in sup)); print("     sinks:", " ".join(x.replace('.BEL','') for x in sinks))
