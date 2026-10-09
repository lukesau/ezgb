import os
NETFILE=os.environ['NET']; os.environ['F5']='G'
exec(open('g_const.py').read().split("for byte in (0x04")[0])
ver=int(os.environ['VER'],16)
V=const_byte(ver); cube=B.cubes(V,1)[0]
assign={n:0 for n in B.names}; assign.update(cube)
def val(f):
    x=f
    while isinstance(x,tuple): x = x[2] if assign[B.names[x[0]]] else x[1]
    return x
def kids(pin):
    r=comb(pin); c=cells.get(tuple(pin.split(':')[:2]))
    if r: return [(s,i,'') for s,i in r[1] if s]
    if c and pin.endswith(':X') and c['attrs'].get('FXMUX')=='F5':
        return [(c['in'][n][0],c['in'][n][1],n) for n in ['BX','F1','F2','F3','F4','G1','G2','G3','G4'] if c['in'].get(n,[None])[0]]
    return []
def tag(pin):
    r=comb(pin); c=cells.get(tuple(pin.split(':')[:2]))
    if r: return 'LUT '+r[0]+'='+format(int(r[2],2),'04X')
    if c and pin.endswith(':X') and c['attrs'].get('FXMUX')=='F5': return 'F5 F=%04X G=%04X'%(int(c['attrs']['F'],2),int(c['attrs']['G'],2))
    return 'leaf'
def ones(pin,depth=0,seen=None,label=''):
    """print only the path of nodes that are 1 in the version state"""
    if seen is None: seen=set()
    if pin not in memo or val(memo[pin])!=1 or pin in seen: return
    seen.add(pin)
    print('  '*depth+f"{label}{pin.replace('.BEL','')} [{tag(pin)}]")
    for s,i,l in kids(pin):
        if s in memo and val(memo[s])^i==1: ones(s,depth+1,seen,(l+': ' if l else '')+('~' if i else ''))
for k in range(8):
    if (ver>>k)&1:
        t=bits[k]; tt,b=t.split(':'); p,inv=cells[(tt,b)]['in']['O1']
        print(f"===== D{k}"); ones(p)
