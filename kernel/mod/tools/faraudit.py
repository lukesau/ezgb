#!/usr/bin/env python3
"""faraudit.py [BUILD]: every call between banks in the built kernel must land
on a symbol in the bank it names. It reads BUILD/kernel.gb and
BUILD/kernel.sym (default build/), finds each call to banked_call (SDCC
2.9.0's far call, the target and bank after it) and to ___sdcc_bcall_ehl
(the current SDCC's, the bank in e and the target in hl), and fails on a
target that is no symbol: a bank number written by hand in assembly that
no longer matches where the routine is."""
import re, sys
B=sys.argv[1] if len(sys.argv)>1 else 'build'
rom=open(B+'/kernel.gb','rb').read()
at={}; byname={}
for f in (B+'/kernel.sym',):
    for l in open(f):
        m=re.match(r'\s*([0-9a-f]{2}):([0-9a-f]{4}) (\S+)', l)
        if m: at.setdefault((int(m[1],16),int(m[2],16)),m[3]); byname[m[3]]=int(m[2],16)
tr=byname['banked_call']
pat=bytes((0xcd,tr&255,tr>>8))
bad=n=0
i=rom.find(pat)
while i>=0:
    a=rom[i+3]|rom[i+4]<<8; b=rom[i+5]|rom[i+6]<<8
    src=f"{i>>14:02x}:{(i&0x3fff)+(0x4000 if i>=0x4000 else 0):04x}"
    if b<16 and 0x4000<=a<0x8000 or (b==0 and a<0x4000):
        n+=1
        if (b,a) not in at and not ((b,a-3) in at or (b,a-6) in at):
            bad+=1; print(f"{src}: far call to {b:02x}:{a:04x}, no symbol there")
    i=rom.find(pat,i+1)
print(n,'far calls,',bad,'bad')
total=bad
bc=[byname['___sdcc_bcall_ehl']] if '___sdcc_bcall_ehl' in byname else []
if bc:
    pat=bytes((0xcd,bc[0]&255,bc[0]>>8)); n=bad=0
    i=rom.find(pat)
    while i>=0:
        src=f"{i>>14:02x}:{(i&0x3fff)+(0x4000 if i>=0x4000 else 0):04x}"
        if rom[i-5]==0x1e and rom[i-3]==0x21:
            b=rom[i-4]; a=rom[i-2]|rom[i-1]<<8; n+=1
            if (b,a) not in at or b==0 or not 0x4000<=a<0x8000:
                bad+=1; print(f"{src}: banked call to {b:02x}:{a:04x}, no symbol there")
        else:
            bad+=1; print(f"{src}: call to the bcall routine, not the usual sequence")
        i=rom.find(pat,i+1)
    print(n,'banked calls (SDCC 4),',bad,'bad')
    total+=bad
sys.exit(1 if total else 0)
