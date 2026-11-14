exec(open('net.py').read().replace("sys.argv[1]","NETFILE"))
exec(open('bdd.py').read())
B=BDD()
memo={}
def lutf(bits, ins):
    # bits: msb-first string, index i = F4F3F2F1
    val=int(bits,2); f=0
    for i in range(16):
        if (val>>i)&1:
            term=1
            for k,x in enumerate(ins):
                if x is None: continue     # unused input: table is replicated
                term=B.AND(term, x if (i>>k)&1 else B.NOT(x))
            # only add each distinct term once per replicated pattern
            f=B.OR(f,term)
    return f
def fn(pin, inv=0):
    if pin is None: return None
    key=pin
    if key not in memo:
        r=comb(pin)
        if r is None: memo[key]=B.var(pin)
        else:
            ins=[fn(s, i) for s,i in r[1]]
            memo[key]=lutf(r[2], ins)
    f=memo[key]
    return B.NOT(f) if inv else f
bits={0:"D0X0Y32.BEL:IOI[1]",1:"D0X0Y19.BEL:IOI[1]",2:"D0X0Y19.BEL:IOI[0]",3:"D0X0Y18.BEL:IOI[1]",4:"D0X0Y18.BEL:IOI[0]",5:"D0X0Y15.BEL:IOI[1]",6:"D0X0Y15.BEL:IOI[0]",7:"D0X0Y2.BEL:IOI[1]"}
F={}
for k,t in bits.items():
    tt,b=t.split(':'); p,inv=cells[(tt,b)]['in']['O1']
    F[k]=fn(p,inv)
def is_data(n):
    return ':BRAM:' in n or (':IOI' in n and not n.startswith('D0X0Y')) or (n.endswith(':X') and comb(n) is None)
