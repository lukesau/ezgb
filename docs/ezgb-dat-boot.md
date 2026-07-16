# `ezgb.dat` vs `Update_FW*.gb` (boot / install)

How a "blank" Jr gets a menu without running the updater ROM.

## Two different binaries

| File | Role | Where it runs from |
|---|---|---|
| **`ezgb.dat`** | Menu / OS kernel (what `re/*/kernel.gb` is a copy of) | Loaded by a **factory-resident bootloader**, then executed |
| **`Update_FW*.gb`** | FPGA **firmware** updater (title `UPDATE`) | Launched **as a game** from the kernel file browser |

They are not interchangeable. Skipping `Update_FW*.gb` is fine if the cart’s FPGA already reports the FW version you need (HELP tab). Updating **kernel** is: replace `ezgb.dat` on the SD root and reboot.

Official FW4 package `readme.txt` only documents the updater-ROM path for FPGA. The SD-root `ezgb.dat` path is what a bare cart uses to obtain a kernel at all.

## First boot with no kernel on the cart

Factory behavior (**not** inside `kernel.gb` — photo-confirmed on a physical Jr with a blank SD):

1. Cart powers on with a small **factory bootstrap** (FPGA / on-cart side — **not** the menu kernel).
2. Shows branded `EZ-FLASH` + `LOADING...` and looks for **`ezgb.dat` on the SD root**.
3. If missing → exact text:
   ```
   LOADING...
   ezgb.dat not found
   on SD card
   Please download it
   from www.ezflash.cn
   ```
4. If present → loads and runs that file as the kernel.

Blank-SD → this screen on every cold boot is strong evidence the **menu is not permanently
installed as the sole OS**; the cart expects `ezgb.dat` from disk each boot (whatever buffer
the bootstrap uses is session / remap, not “flash once and you’re done”).

Once the kernel is running you get its own strings, e.g. `Micro SD initial OK!`, BACKUPSAVE,
file browser / `Loading…`.

## What *this* kernel does with the name `ezgb.dat`

The only hit for the literal `ezgb.dat` inside `kernel.gb` is the C string at **`$0bc8`**.

It is used from the directory enumerator (`Call_000_0a43`) via unlabeled helper **`$09af`** (sits immediately after the `File system error!` string; mgbdis does not label it):

```text
; bank_000 ≈ $0b4f — when a dirent looks like a file (attr bit $20):
;   memcmp/strncmp-style call: length 8, "ezgb.dat", current name
;   if equal → skip (jp z $0a56), so the kernel file is hidden in the browser
```

Same helper is reused for extension filters (`.GBC` at `$16eb`, `.GB` at `$16f0`).

**Conclusion:** after the factory bootstrap has already loaded the kernel, the running OS treats `ezgb.dat` as an **invisible support file**, not as something it re-flashes on every boot from this code path.

Those bootstrap strings (`ezgb.dat not found` / `Please download it` / `from www.ezflash.cn`)
are **absent** from `ezgb.dat` and `Update_FW*.gb`. That UI is only in the factory layer we
do not currently have a dump of.

## FPGA update path (the `.gb` you did not need)

`Update_FW5_7-31.gb` (and FW4 sibling) is a separate program:

- Title: `UPDATE`
- UI strings: `EZ-FLASH FW UPDATE`, `Update to ver:N`, `Press [A] to update`, `Update finish,power off`
- Procedure (package readme): run it like a game → A → wait → **power off** (not reset) → next boot HELP should show the new FWn

That path programs **FPGA firmware**, not the menu image. A cart that already has a matching FW can run forever on SD-only `ezgb.dat` drops.

## Mental model

```text
Power on
   │
   ▼
Factory bootstrap ──(no ezgb.dat)──► "ezgb.dat not found…" (not in kernel.gb)
   │
   └──(ezgb.dat on SD root)──► load kernel into cart exec slot
                                   │
                                   ▼
                              Kernel (ezgb.dat)
                                 SD init, BACKUPSAVE, file browser
                                 (hides "ezgb.dat" from the list)
                                   │
                                   └── optional: launch Update_FW*.gb
                                                 → FPGA flash → power off
```

## Open RE work

- Dump or behaviorally reimplement the **factory bootstrap** (this screen’s ROM/bitstream).
  Outside `re/*/kernel.gb`; needed only for full cold-boot fidelity.
- Measure bootstrap load: size, destination map, any checksum — Analog Discovery on SD + cart
  bus during a good boot is the clean experiment (vs blank-SD for this error path).
