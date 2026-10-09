# FPGA bitstream toolchain

How to decode the cart's Spartan-3A (`XC3S200A-4VQG100`) bitstream, and how
the machine that does it was set up. Findings from using it are in
[fpga-bitstream.md](fpga-bitstream.md).

**This work is local-only.** It lives on the unpushed `bitstream-re` branch.
Decoded listings, BRAM dumps and anything else derived from EZ Flash's
bitstream stay in the ignored `fpga/` directory, same policy as the flash dumps
([fpga/README.md](../fpga/README.md)).

## The pieces

| Piece | What it does | Where |
|---|---|---|
| **prjcombine** | Open database of the Spartan-3 family bitstream format: every tile, routing mux and logic setting with its exact bit positions. Rust libraries to load it and parse bitstreams | `~/fpga/prjcombine` on the build host |
| **s3decode** | Our decoder. Walks every tile of a bitstream against the prjcombine database and prints what is configured | [`scripts/fpga/s3decode/`](../scripts/fpga/s3decode/) |
| **ISE 14.7** | Xilinx's toolchain, the last one that supports Spartan-3A. Only needed to *make* bitstreams (baselines, test designs, future fuzzing), not to decode | `~/Xilinx/14.7` on the build host |
| Scripts | Pull bitstreams out of updaters and flash dumps, rebuild stage1, dump PicoBlaze words, end-to-end smoke test | [`scripts/fpga/`](../scripts/fpga/) |

Decoding needs only prjcombine and s3decode. ISE is for generating the blank
baseline and for any experiment that builds a design.

## Build host

`ubuntu-desktop` (192.168.1.100, `ssh ubuntu-desktop`): Ubuntu 24.04, Xeon
E5-1680 v2 (8 cores / 16 threads), 62 GB RAM. Moved here from
`ubuntu-compute`, which is shared now; a copy of ISE and prjcombine is still
there but nothing uses it.

Everything lives under `~/fpga`:

```
~/fpga/prjcombine/         prjcombine checkout (rev below), built
~/fpga/s3decode/           s3decode build (same source as scripts/fpga/s3decode, local git, no remote)
~/fpga/scripts/            copy of scripts/fpga/ (rsync -a --exclude s3decode scripts/fpga/ ubuntu-desktop:~/fpga/scripts/)
~/fpga/blank/blank.bit     blank-design baseline for diffing
~/fpga/smoke/              smoke-test design and outputs
~/fpga/cart/               cart bitstream images, decodes, BRAM dumps
~/fpga/ise.kdl             prjcombine toolchain config for ISE (only for its fuzzers)
~/Xilinx/14.7/ISE_DS/      ISE 14.7
~/.Xilinx/Xilinx.lic       WebPACK licence
```

## prjcombine

Upstream: <https://codeberg.org/prjunnamed/prjcombine> (the GitHub repo is an
archived mirror). Its status table lists Spartan-3 (all variants, 3A
included) as bitstream-complete, timing and hardware-verification not started.
The `spartan3` database covers XC3S50A through XC3S1400A, 3AN and 3A DSP, with
package pinouts.

```bash
git clone https://codeberg.org/prjunnamed/prjcombine.git ~/fpga/prjcombine
cd ~/fpga/prjcombine && git checkout 7ab08a0207716b0417163301580c154d02d1654e
cargo build --release -p prjcombine-cli
```

**Pin the revision.** The database is bincode-serialised, so the Rust crates
and `databases/spartan3.zstd` must come from the same commit. s3decode's
`Cargo.toml` pins `7ab08a02…` (2026-09-28); the matching database has sha256
`fe6dad4f…6eb611`. To move to a newer prjcombine, bump the rev in
`Cargo.toml` and check out the same rev of the database together.

Browsing the database: `prjcombine-cli dumpdb <target>` resolves files as
`../databases/<target>.zstd`, so run it from `public/`:

```bash
cd ~/fpga/prjcombine/public
../target/release/prjcombine-cli dumpdb -d spartan3 | grep xc3s200a
```

`databases/spartan3.txt` is the same database as text and is the easiest thing
to read: search for `tile_class CLB`, `BRAM_S3A`, `IOB_S3A_S2` and so on.

**Contributions:** the repo's `AGENTS.md` says it does not accept anything
authored by an LLM. Fine to use locally; anything sent upstream has to be your
own work.

## s3decode

```bash
# on the build host
cd ~/fpga/s3decode && cargo build --release
./target/release/s3decode --db ~/fpga/prjcombine/databases/spartan3.zstd \
    --baseline ~/fpga/blank/blank.bit --blob-dir bram/ image.bin > image.decode.txt
```

| Flag | Meaning |
|---|---|
| `bitstream` | `.bit` file, or raw config data starting with the `ff` dummy words (what `extract-bitstreams.py` writes) |
| `--db` | prjcombine `spartan3.zstd`. Default `../prjcombine/databases/spartan3.zstd` |
| `--device` | default `xc3s200a` |
| `--baseline` | blank-design bitstream; print only differences from it (`+` added, `-` removed). Without it every unused tile's default settings are printed too (~6,700 lines vs ~120 for a small design) |
| `--blob-dir` | write large settings (BRAM `DATA` / `DATAP`) as binary files, named `<tile>.BEL.BRAM.DATA.bin` |
| `--all` | also print settings whose bits are all zero |

Takes about 0.3 s per bitstream.

### Reading the output

```
tile D0X10Y5.BEL CLB                 cell X10 Y5, tile slot BEL, tile class CLB
	+ SLICE[1] F = 0b0011110000111100    LUT contents, msb first
	+ SLICE[1] DXMUX = X                 enum setting
tile D0X10Y5.INT INT_CLB
	+ INT mux IMUX_CLK[1] <- GCLK[3]     routing mux: destination <- source
	- INT inv IMUX_CE_OPTINV[1] <- ~IMUX_CE[1]   default the design turned off
tile D0X19Y17.BEL BRAM_S3A
	+ BRAM DATA = <2048 bytes, 490 nonzero, fnv 504b05b316f50e08>   see --blob-dir
...
# regs:                               configuration registers (COR1/2, CTL0, ...)
# 56010 features, 1018942 claimed bit positions, 0 set bits unclaimed
```

Cell coordinates match ISE's: `CLB_X10Y5` in XDL is `D0X10Y5` here.

**The last line is the completeness check.** Every set bit in the frame data
that no database item accounts for is listed as `unclaimed`. Zero means the
whole bitstream is explained. Both the test design and the FW4 cart image
decode with zero.

BRAM bit order in the blob files: bit *i* of the attribute is bit `i % 8` of
byte `i / 8`, and the attribute is in logical memory order (x1 address order),
so a BRAM used as 2K × 8 dumps as plain bytes and a BRAM used as 16K × 1 dumps
as a packed bit-plane.

### Baseline

`blank.bit` is a design with no instances, made by hand in XDL so no
synthesis is involved:

```bash
printf 'design "blank" xc3s200avq100-4 v3.2 ;\n' > blank.xdl
xdl -xdl2ncd -force blank.xdl blank.ncd
bitgen -w -d blank.ncd blank.bit
```

`smoke-test.sh` regenerates it.

### Known limits

- **Parser is strict.** prjcombine's Spartan-3A parser expects the exact packet
  sequence a stock `bitgen` file has. The cart's images parse as-is; a
  compressed or hand-edited stream may need work.
- **Routing isn't cross-checked against XDL wire names yet.** ISE names wires
  differently (`DOUBLE_*` etc.); prjcombine's `re/xilinx/naming` translates.
  Slices and settings have been checked against XDL, individual routing hops
  have not.
- **Test muxes and legacy bels are skipped.** Neither occurs in the claimed-bit
  count for our images, so nothing is hidden by this.
- **Decode only.** No encoder yet; writing a modified bitstream (for example
  the stage1 header patch in [fpga-bitstream.md](fpga-bitstream.md)) needs one,
  plus CRC.

## Pulling a bitstream out of the cart's files

```bash
scripts/fpga/extract-bitstreams.py juniorkernel-1.04e-FW4/Update_FW4.gb \
    tools/EN25F40-repaired-v2.bin -o fpga/images/
scp fpga/images/*.bin ubuntu-desktop:~/fpga/cart/
```

It finds every 32 × `ff` + `aa 99 30 a1` head and cuts 149,516 bytes (one
XC3S200A stream). FW4's updater holds one image at `$8000`; the flash dump
holds slot A at `$26` and slot B at `$40026`; each FW5 updater holds two (at
`$8000` and `$2c80c`).

Then:

```bash
scripts/fpga/stage1-from-bram.py bram/ -o stage1.gb --ref tools/ezflashjr/stage1/FW4/stage1.gb
scripts/fpga/stage1-from-bram.py bram/ --ref <stage1.gb> --discover   # other FW revisions
scripts/fpga/picoblaze-words.py bram/D0X3Y25.BEL.BRAM > pb-x3y25.txt
scripts/fpga/picoblaze-dis.py bram/D0X3Y29.BEL.BRAM -a re/fpga-fw4/X3Y29.notes -o X3Y29.psm
```

## ISE 14.7

### Getting it

AMD's legacy ISE page now only offers **"ISE 14.7 Windows 10 and Windows
11"** (TAR/GZIP, ~15.5 GB, needs an AMD login). Old xilinx.com links redirect
there; the Linux full installer is no longer listed. Despite the name, that
package is a VirtualBox appliance: `ova/14.7_VM.ova` holds an **Oracle Linux
6.4** disk with the Linux build of ISE 14.7 already installed in
`/opt/Xilinx/14.7`. Copy it out instead of running the VM:

```bash
sudo apt-get install qemu-utils
tar xf Xilinx_ISE_14.7_Win10_14.7_VM_0213_1/ova/14.7_VM.ova 14.7_VM-disk001.vmdk
sudo modprobe nbd max_part=16
sudo qemu-nbd -r -c /dev/nbd0 14.7_VM-disk001.vmdk      # read-only
sudo mount -o ro,noload /dev/nbd0p1 /mnt/isevm         # partition 1 is ext4 root
mkdir -p ~/Xilinx && sudo rsync -a /mnt/isevm/opt/Xilinx/14.7 ~/Xilinx/
sudo chown -R "$USER": ~/Xilinx
sudo umount /mnt/isevm && sudo qemu-nbd -d /dev/nbd0
```

21 GB installed. The 16 GB `.vmdk` and the package can be deleted afterwards.

The VM ships a `~/.Xilinx/Xilinx.lic` (System Edition) node-locked to the VM's
own VirtualBox MAC. Don't reuse it on another machine; get a WebPACK licence
instead.

### Ubuntu 24.04 dependencies

```bash
# ncurses 5 was dropped in 24.04; take it from 22.04 (jammy)
curl -O http://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.3_amd64.deb
curl -O http://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libncurses5_6.3-2ubuntu0.3_amd64.deb
sudo apt-get install ./libtinfo5_*.deb ./libncurses5_*.deb \
    xvfb x11-utils libxtst6 libxi6 libxrender1 libsm6 libxrandr2 libfontconfig1 \
    libglib2.0-0t64 libusb-0.1-4 libusb-1.0-0

# the FlexLM licence tools (lmutil) want the LSB loader
sudo ln -s /lib64/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3
```

libusb is only for `impact` with a Xilinx cable. Xvfb is only for running a
GUI tool headless.

### Licence

Free **ISE WebPACK** licence, which covers Spartan-3A:

1. <https://www.xilinx.com/getlicense> (redirects to AMD Product Licensing), log in.
2. Create New Licenses → Certificate Based Licenses → tick **ISE WebPACK
   License** → Generate Node-Locked License.
3. Host ID: the machine's Ethernet MAC, OS Linux 64-bit.
4. Copy the emailed `Xilinx.lic` to `~/.Xilinx/Xilinx.lic`.

The licence issued on 2026-10-08 came back as `HOSTID=ANY`, so it works on any
machine regardless of what host ID was entered.

What needs it: `xst` and `ngdbuild` run without a licence; `map` fails with
`No 'ISE' nor 'WebPack' feature`, so `map`, `par` and `bitgen` need it.

If you ever get a licence that really is node-locked: FlexLM on Linux reads
only an interface named `eth0`, and with Ubuntu's predictable names
(`enp5s0`, `eno1`) `lmutil lmhostid` reports `000000000000`. The fix used on
ubuntu-compute was renaming an unused real NIC, persistently:

```
# /etc/systemd/network/10-flexlm-eth0.link
[Match]
MACAddress=<that NIC's MAC>
[Link]
Name=eth0
```

Not needed on ubuntu-desktop with the `ANY` licence.

### Using it

```bash
source ~/Xilinx/14.7/ISE_DS/settings64.sh ~/Xilinx/14.7/ISE_DS
```

**Always pass the install path.** `settings64.sh` treats `$1` as the install
location, so when it's sourced from a script that was given an argument it
silently uses that argument, and none of the tools end up on `PATH`.

Command-line flow for a Verilog design (`xc3s200a-4-vq100` is the cart's part):

```bash
xst -ifn top.xst                          # synth, top.prj lists sources
ngdbuild -p xc3s200a-4-vq100 top.ngc
map -w -p xc3s200a-4-vq100 -o top_map.ncd top.ngd
par -w top_map.ncd top.ncd
bitgen -w top.ncd top.bit
xdl -ncd2xdl top.ncd top.xdl              # placed+routed design as text
```

**XDL round trip is exact.** `xdl -xdl2ncd` then `bitgen` reproduces the same
config data byte for byte, and the same XDL gives identical bits on
ubuntu-compute and ubuntu-desktop. So designs can be written directly as XDL,
skipping synthesis and place-and-route, which is the basis for any fuzzing.

`bitgen` on a small design: ~3.3 s on ubuntu-desktop (~2.2 s on
ubuntu-compute), single-threaded. With 16 threads that is roughly 15-17k
bitstreams an hour.

## Smoke test

```bash
~/fpga/scripts/smoke-test.sh [workdir]    # on the build host; default workdir ~/fpga/smoke
```

Builds a 4-flop test design, checks the XDL round trip is byte-identical and
149,516 bytes, rebuilds `blank.bit`, decodes the design against it and checks
for zero unclaimed bits. Expected tail:

```
xdl round trip: identical, 149516 bytes
# 118 features, 1018942 claimed bit positions, 0 set bits unclaimed
slices used (CLB tiles): 2
```

Override locations with `ISE=`, `S3DECODE=`, `S3DB=`.
