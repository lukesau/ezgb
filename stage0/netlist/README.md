# Netlist analysis: the version byte

Python scratch tools over `s3trace --netlist` output (`fw4-netlist.jsonl`,
kept untracked in `fpga/fw4-decode/netlist/`). Run them from a directory
holding that file. Findings: [stage0/docs/design.md#the-version-byte](../docs/design.md#the-version-byte).

| File | What |
|---|---|
| `net.py` | load the netlist; `comb()` LUT outputs, `cone()`, `show()` trees |
| `bdd.py` | a small BDD |
| `analyze.py`, `analyze2.py` | data-bit functions as BDDs; `analyze2` adds F5 muxes, with the select reversed (`BX ? G : F`; the hardware is `BX ? F : G`) |
| `byte.py` | data-forced-to-0 byte patterns |
| `const.py` | bytes the bus outputs whatever the data leaves hold |
| `state.py` | evaluate the D1/D2 trees in one concrete state |
| `search.py`, `search2.py` | LUT edits in D1's tree that would add the version bit |
| `g_*.py` | variants of the same analyses that take the netlist file and the F5 mux convention as settings |
| `pintable.py` | the package pin table |

These are research scripts, kept as they were run, not polished tools.
