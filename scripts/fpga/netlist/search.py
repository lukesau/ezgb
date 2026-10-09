import os, itertools
os.environ['F5']='G'
exec(open('analyze2.py').read().replace("F5SET=set()","").replace("exec(open('net.py')","F5SET=set(); F5_HI=lambda f,g: g; F5_LO=lambda f,g: f\nexec(open('net.py')") if False else "")
F5SET=set(); F5_HI=lambda f,g: g; F5_LO=lambda f,g: f
exec(open('analyze2.py').read())
OVR={}      # (tile:bel, 'F'|'G') -> bits string
def build(pin_out, override):
    global memo
    memo={}
    for k,v in override.items(): pass
    # patch cells temporarily
    saved={}
    for (tb,lut),bits_ in override.items():
        c=cells[tuple(tb.split(':'))]; saved[(tb,lut)]=c['attrs'][lut]; c['attrs'][lut]=bits_
    t,b=pin_out.split(':'); p,inv=cells[(t,b)]['in']['O1']
    f=fn(p,inv)
    for (tb,lut),bits_ in saved.items(): cells[tuple(tb.split(':'))]['attrs'][lut]=bits_
    return f
D1pin=bits[1]; D2pin=bits[2]
D1=build(D1pin,{}); D2=build(D2pin,{})
D2nov=build(D2pin,{('D0X12Y18.BEL:SLICE[3]','F'):'0'*16})
T=B.AND(D2,B.NOT(D2nov))
print("version term states nonempty:", T!=0, "support", len(B.support(T)))
goal=B.OR(D1,T)
# LUTs in D1's tree
memo={}; build(D1pin,{})
cands=[]
for pin in list(memo):
    t,b,o=pin.split(':'); c=cells.get((t,b))
    if not c or not b.startswith('SLICE'): continue
    a=c['attrs']
    if o=='X' and a.get('FXMUX') in ('F','F5'): cands.append((t+':'+b,'F'))
    if o=='X' and a.get('FXMUX')=='F5': cands.append((t+':'+b,'G'))
    if o=='Y' and a.get('GYMUX')=='G': cands.append((t+':'+b,'G'))
cands=sorted(set(cands))
print(len(cands),"candidate LUTs in D1's tree")
hits=[]
for tb,lut in cands:
    old=cells[tuple(tb.split(':'))]['attrs'][lut]
    for i in range(16):
        if old[15-i]=='1': continue
        new=list(old); new[15-i]='1'; new=''.join(new)
        f=build(D1pin,{(tb,lut):new})
        if f==goal:
            hits.append((tb,lut,old,new,i)); print("  MATCH", tb, lut, old, "->", new, "entry", i)
        else:
            # does it at least cover T without breaking anything else? (D1 ⊆ f ⊆ goal)
            if B.AND(D1,B.NOT(f))==0 and B.AND(f,B.NOT(goal))==0 and B.AND(T,B.NOT(f))!=T:
                print("  partial", tb, lut, "entry", i)
print("matches:", len(hits))
