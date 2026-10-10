exec(open('search.py').read().split("hits=[]")[0])
def build_free(pin_out, tb, lut):
    """D1 with LUT (tb,lut)'s output replaced by var Z; returns (f, [input fns])"""
    global memo
    memo={}
    c=cells[tuple(tb.split(':'))]
    pref=lut
    ins=[]
    for i in range(1,5):
        s=c['in'].get(f'{pref}{i}',[None,0])
        ins.append(fn(s[0],s[1]) if s[0] else None)
    Z=B.var('Z')
    old=c['attrs'][lut]
    # make the LUT compute Z regardless of inputs: special marker
    c['attrs'][lut]='ZZ'
    orig_lutf=globals()['lutf']
    def lutf2(bits_,ins_):
        return Z if bits_=='ZZ' else orig_lutf(bits_,ins_)
    globals()['lutf']=lutf2
    memo={}
    t,b=pin_out.split(':'); p,inv=cells[(t,b)]['in']['O1']
    f=fn(p,inv)
    globals()['lutf']=orig_lutf; c['attrs'][lut]=old
    return f, ins
results=[]
for tb,lut in cands:
    f,ins=build_free(D1pin,tb,lut)
    if 'Z' not in B.support(f): continue
    H1=B.restrict(f,{'Z':1}); H0=B.restrict(f,{'Z':0})
    table=[]; ok=True
    for m in range(16):
        M=1
        for k,x in enumerate(ins):
            if x is None: continue
            M=B.AND(M, x if (m>>k)&1 else B.NOT(x))
        g=B.AND(goal,M)
        c1 = B.AND(H1,M)==g; c0 = B.AND(H0,M)==g
        if c1 and c0: table.append('-')
        elif c1: table.append('1')
        elif c0: table.append('0')
        else: ok=False; break
    old=cells[tuple(tb.split(':'))]['attrs'][lut]
    if ok:
        new=''.join(table[::-1])
        print("POSSIBLE", tb, lut, "old", old, "needed (msb first, - = either)", new)
        results.append((tb,lut,old,new))
print(len(results), "LUTs can take the version bit")
