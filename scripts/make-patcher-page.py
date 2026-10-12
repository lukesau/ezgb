#!/usr/bin/env python3
"""Build the in-browser patcher page: dist/patcher/index.html.

One self-contained HTML file (scripts/patcher/patcher.html filled in): the
kernel patches from patches/kernel/ and the firmware updater patches from
patches/updater/ inlined as base64, and a table of every file the page
recognizes by SHA-256: the stock kernels and updaters (patched only with
their own patch), files that are already patched, and the FW5 2020-7-31
updater, which is refused. Each result is checked against the expected
SHA-256 before it can be saved, so no stock file can be patched with the
wrong patch, the failure docs/distribution.md's mismatch test found
dangerous for 0731/0918 kernels and for firmware.

Needs the stock files (re/kernel/<ver>/kernel.gb.orig, the juniorkernel-*
updaters) to compute the hashes, and checks every patch reproduces its
manifest md5 before writing anything.

    scripts/make-patcher-page.py [out.html]      # default dist/patcher/index.html
"""
import base64
import hashlib
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "scripts"))
kp = __import__("kernel-patch")

KPKG = {"1.04e": "juniorkernel-1.04e-FW4", "1.05e-0731": "juniorkernel-1.05e-FW5-0731",
        "1.05e-0918": "juniorkernel-1.05e-FW5-0918"}
FW = {"fw4": ("FW4 updater (Update_FW4.gb)", "juniorkernel-1.04e-FW4", "Update_FW4-mod-{v}.gb"),
      "fw5-0918": ("FW5 2021-9-18 updater (Update_FW5_2021-9-18.gb)", "juniorkernel-1.05e-FW5-0918",
                   "Update_FW5-0918-mod-{v}.gb")}
REJECT = {"juniorkernel-1.05e-FW5-0731/Update_FW5_7-31.gb":
          "this is EZ Flash's FW5 2020-7-31 updater. The firmware mod is built for the 2021-9-18 FW5 updater "
          "(Update_FW5_2021-9-18.gb) and the FW4 updater (Update_FW4.gb) only."}


def h(alg, b):
    return hashlib.new(alg, b).hexdigest()


def main():
    out_path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "dist", "patcher", "index.html")
    modver = open(os.path.join(ROOT, "patches", "kernel", "VERSION")).read().strip()
    fwver = open(os.path.join(ROOT, "stage1", "VERSION")).read().split()[1]
    kman = json.load(open(os.path.join(ROOT, "patches", "kernel", "manifest.json")))
    fman = json.load(open(os.path.join(ROOT, "patches", "updater", "manifest.json")))
    known, patches, krows, frows = {}, {}, [], []

    def add(digest, entry):
        if digest in known:
            sys.exit(f"error: two known files share SHA-256 {digest}")
        known[digest] = entry

    for v, e in sorted(kman.items()):
        stock = open(os.path.join(ROOT, "re", "kernel", v, "kernel.gb.orig"), "rb").read()
        ips = open(os.path.join(ROOT, "patches", "kernel", e["patch"]), "rb").read()
        out = kp.apply_ips(stock, ips)
        if h("md5", stock) != e["stock_md5"] or h("md5", out) != e["patched_md5"]:
            sys.exit(f"error: kernel {v}: patch does not reproduce the manifest md5")
        pid = "k-" + v
        patches[pid] = base64.b64encode(ips).decode()
        name = f"kernel {v} ({KPKG[v]})"
        add(h("sha256", stock), dict(kind="kernel", name=name, patch=pid, out256=h("sha256", out), outName="ezgb.dat"))
        add(h("sha256", out), dict(kind="done", name=f"kernel {v} with mod {modver}"))
        krows.append(f"<tr><td>{v}</td><td>{KPKG[v]}</td><td><span class=\"hash\">{h('sha1', stock)}</span></td></tr>")

    for fw, e in sorted(fman.items()):
        if e["stage1"] != fwver:
            sys.exit(f"error: updater {fw} carries stage1 {e['stage1']}, stage1/VERSION says {fwver}")
        stock = open(os.path.join(ROOT, kp.UPDATER_STOCK[fw]), "rb").read()
        ips = open(os.path.join(ROOT, "patches", "updater", e["patch"]), "rb").read()
        out = kp.apply_ips(stock, ips)
        if h("md5", stock) != e["stock_md5"] or h("md5", out) != e["patched_md5"]:
            sys.exit(f"error: updater {fw}: patch does not reproduce the manifest md5")
        label, pkg, out_name = FW[fw]
        pid = "f-" + fw
        patches[pid] = base64.b64encode(ips).decode()
        add(h("sha256", stock), dict(kind="firmware", name=f"the {label}", patch=pid, out256=h("sha256", out),
                                     outName=out_name.format(v=fwver)))
        add(h("sha256", out), dict(kind="done", name=f"the {label} with firmware mod {fwver}"))
        frows.append(f"<tr><td>{os.path.basename(kp.UPDATER_STOCK[fw])}</td><td>{pkg}</td>"
                     f"<td><span class=\"hash\">{h('sha1', stock)}</span></td></tr>")

    for rel, why in REJECT.items():
        add(h("sha256", open(os.path.join(ROOT, rel), "rb").read()), dict(kind="reject", why=why))

    page = open(os.path.join(ROOT, "scripts", "patcher", "patcher.html")).read()
    for k, v in {"{MODVER}": modver, "{FWVER}": fwver, "{KROWS}": "\n    ".join(krows),
                 "{FROWS}": "\n    ".join(frows), "{KNOWN}": json.dumps(known, indent=1),
                 "{PATCHES}": json.dumps(patches)}.items():
        page = page.replace(k, v)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    open(out_path, "w").write(page)
    print(f"wrote {out_path} ({len(page) // 1024} KB): {len(kman)} kernels, {len(fman)} updaters, "
          f"{len(known)} known files")


if __name__ == "__main__":
    main()
