import functools
class BDD:
    def __init__(s): s.nodes={}; s.order={}; s.names=[]
    def var(s,name):
        if name not in s.order: s.order[name]=len(s.names); s.names.append(name)
        return s.mk(s.order[name],0,1)
    def mk(s,v,lo,hi):
        if lo==hi: return lo
        k=(v,lo,hi)
        if k not in s.nodes: s.nodes[k]=k
        return s.nodes[k]
    def top(s,a): return a[0] if isinstance(a,tuple) else 1<<30
    @functools.lru_cache(maxsize=None)
    def ite(s,f,g,h):
        if f==1: return g
        if f==0: return h
        if g==1 and h==0: return f
        if g==h: return g
        v=min(s.top(f),s.top(g),s.top(h))
        def co(x,b):
            if isinstance(x,tuple) and x[0]==v: return x[2] if b else x[1]
            return x
        return s.mk(v, s.ite(co(f,0),co(g,0),co(h,0)), s.ite(co(f,1),co(g,1),co(h,1)))
    def NOT(s,a): return s.ite(a,0,1)
    def AND(s,a,b): return s.ite(a,b,0)
    def OR(s,a,b): return s.ite(a,1,b)
    def restrict(s,f,assign):
        @functools.lru_cache(maxsize=None)
        def r(x):
            if not isinstance(x,tuple): return x
            n=s.names[x[0]]
            if n in assign: return r(x[2] if assign[n] else x[1])
            return s.mk(x[0],r(x[1]),r(x[2]))
        return r(f)
    def cubes(s,f,limit=64):
        out=[]
        def walk(x,path):
            if len(out)>=limit: return
            if x==1: out.append(dict(path)); return
            if x==0: return
            walk(x[1],path+[(s.names[x[0]],0)]); walk(x[2],path+[(s.names[x[0]],1)])
        walk(f,[]); return out
    def support(s,f):
        res=set()
        def w(x):
            if isinstance(x,tuple): res.add(s.names[x[0]]); w(x[1]); w(x[2])
        w(f); return res
