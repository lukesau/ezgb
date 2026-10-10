import os,sys
NETFILE=os.environ['NET']
os.environ['F5']='G'
exec(open('g_const.py').read().split("for byte in (0x04")[0])
found=[]
for byte in range(256):
    v=const_byte(byte)
    if v!=0: found.append(byte)
print(NETFILE, "constant bytes:", " ".join(f"${b:02X}" for b in found))
ver=int(os.environ.get('VER','5'),16)
V=const_byte(ver)
for cube in B.cubes(V,6):
    print("   ","  ".join(f"{'' if x else '!'}{n.replace('.BEL','')}" for n,x in sorted(cube.items())))
