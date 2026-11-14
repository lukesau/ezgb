import os
conv=os.environ['F5']
F5SET=set()
F5_HI=(lambda f,g: f) if conv=='F' else (lambda f,g: g)
F5_LO=(lambda f,g: g) if conv=='F' else (lambda f,g: f)
exec(open('analyze2.py').read())
data=set()
for k in range(8):
    data|={n for n in B.support(F[k]) if is_data(n)}
C={k:B.restrict(F[k],{n:0 for n in data}) for k in range(8)}
def pattern(byte):
    f=1
    for k in range(8):
        f=B.AND(f, C[k] if (byte>>k)&1 else B.NOT(C[k]))
    return f
print("F5 = BX ?", "F : G" if conv=='F' else "G : F")
for byte in (0x04,0x05,0xE1,0x01,0x02,0x88):
    g=pattern(byte)
    print(f"  ${byte:02X}: {'impossible' if g==0 else 'possible, support '+str(len(B.support(g)))}")
import os
if os.environ.get('SHOW'):
    g=pattern(int(os.environ['SHOW'],16))
    for cube in B.cubes(g, 40):
        print("   ", "  ".join(f"{'' if v else '!'}{n}" for n,v in sorted(cube.items())))
