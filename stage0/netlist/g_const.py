import os
os.environ['F5']='G'
exec(open('g_byte.py').read().split("print(\"F5 = BX ?\"")[0])
def forall(f, vs):
    for v in vs:
        f=B.AND(B.restrict(f,{v:0}),B.restrict(f,{v:1}))
    return f
def const_byte(byte):
    v=1
    for k in range(8):
        dk=[n for n in B.support(F[k]) if is_data(n)]
        want=F[k] if (byte>>k)&1 else B.NOT(F[k])
        v=B.AND(v, forall(want, dk))
    return v
for byte in (0x04,0xE1,0x01,0x00,0xFF):
    v=const_byte(byte)
    print(f"${byte:02X} for any data: {'never' if v==0 else 'yes, support '+str(len(B.support(v)))}")
    if v!=0 and byte in (0x04,):
        for cube in B.cubes(v,12):
            print("   ","  ".join(f"{'' if x else '!'}{n.replace('.BEL','')}" for n,x in sorted(cube.items())))
