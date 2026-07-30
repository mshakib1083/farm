# Accuracy-Configurable Fast Approximate Recursive Multiplier (FARM) — Artifact

Reproduction artifact for the paper:

> *A 45 nm ASIC Realization of an Accuracy-Configurable Fast Approximate
> Recursive Multiplier: From Reconfigurable RTL to DRC-Clean Layout*

The architecture is due to Joshi, Agarwal and Mane, *Circuits, Systems, and
Signal Processing* **44**, 9643–9674 (2025). This repository contains an
independent RTL implementation in which the accuracy configuration is a
run-time input, together with everything needed to regenerate the error
characterization reported in the paper.

## Contents

| File | Purpose |
|---|---|
| `farm.v` | Synthesizable RTL: 32×32 FARM with run-time `sel24`/`sel32`/`sel48` control |
| `farm_tb.v` | Directed testbench; logs every transaction to `rtl_vectors.csv` |
| `reproduce_table1.py` | Bit-accurate reference model + error-metric harness (regenerates Table I) |
| `check_vs_rtl.py` | Diffs simulator output against the model |

## Requirements

- Icarus Verilog (or any Verilog-2001 simulator)
- Python 3.8+ with NumPy

Nothing else. No EDA licence is needed for the reproduction path.

## Reproducing Table I

```bash
python reproduce_table1.py --selftest      # sanity checks first
python reproduce_table1.py --n 2500000     # 32- and 16-bit sweeps
```

The seed is fixed, so the output is bit-for-bit reproducible. The self-test
verifies that the 2×2 base block equals `A*B` exhaustively, that exact mode
is bit-exact over 2×10⁵ random pairs, and that operands of 8 bits or fewer
produce exact products in the maximally approximate configuration.

## Reproducing the RTL cross-check

```bash
iverilog -o farm_sim farm.v farm_tb.v
vvp farm_sim                               # writes rtl_vectors.csv
python check_vs_rtl.py rtl_vectors.csv
```

Expected result: 10 000 vectors across five configurations, zero mismatches.
This is the check that establishes the Python model as a faithful stand-in
for the RTL; it exits non-zero on any mismatch so it can gate a CI script.

## Configurations

`sel` bits select the exact carry when `1` and the predicted carry when `0`.
The five points characterized in the paper:

| Label | `sel24` | `sel32` | `sel48` | Equivalent mode in the reference |
|---|---|---|---|---|
| C0 | `0x1F` | `0x7F` | `0x3FF` | FARM-V4 (exact) |
| C1 | `0x00` | `0x00` | `0x000` | FARM-V1 |
| C2 | `0x1B` | `0x00` | `0x000` | FARM-V2 |
| C3 | `0x1B` | `0x55` | `0x155` | FARM-V3 |
| C4 | `0x00` | `0x7F` | `0x3FF` | 24-bit stage approximate only |

Note that the first 4-bit block of every FARA instance, and the most
significant block of the 48-bit adder, are hardwired to the exact carry.
The all-zeros configuration therefore coincides with FARM-V1 rather than
with an unconstrained maximum.

## Licence

Released under the MIT Licence. See `LICENSE`.

## Citation

If you use this artifact, please cite the paper. A `CITATION.cff` is
provided for GitHub's citation widget.
