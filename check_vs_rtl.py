import sys
import numpy as np

try:
    from reproduce_table1 import farm_multiply
except ImportError:
    from farm_model import mult_32 as farm_multiply


def main(path):
    A, B, S24, S32, S48, AB = [], [], [], [], [], []
    bad_lines = 0

    with open(path) as f:
        for lineno, line in enumerate(f, 1):
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            parts = [p.strip() for p in line.split(",")]
            if len(parts) != 6:
                bad_lines += 1
                continue
            try:
                a, b, s24, s32, s48, ab = (int(p, 16) for p in parts)
            except ValueError:
                bad_lines += 1
                continue
            A.append(a); B.append(b)
            S24.append(s24); S32.append(s32); S48.append(s48)
            AB.append(ab)

    n = len(A)
    if n == 0:
        print(f"No usable vectors found in {path}")
        return 1
    if bad_lines:
        print(f"note: skipped {bad_lines} unparseable lines")

    A = np.array(A, dtype=np.uint64)
    B = np.array(B, dtype=np.uint64)
    AB = np.array(AB, dtype=np.uint64)
    S24 = np.array(S24); S32 = np.array(S32); S48 = np.array(S48)

    total_mismatch = 0
    combos = set(zip(S24.tolist(), S32.tolist(), S48.tolist()))
    print(f"{n} vectors, {len(combos)} distinct configurations\n")
    print(f"{'sel24':>6} {'sel32':>6} {'sel48':>6} {'vectors':>8} {'mismatch':>9}")

    for (s24, s32, s48) in sorted(combos):
        m = (S24 == s24) & (S32 == s32) & (S48 == s48)
        got = farm_multiply(A[m], B[m], s24, s32, s48)
        diff = got != AB[m]
        k = int(np.count_nonzero(diff))
        total_mismatch += k
        print(f"{s24:#06x} {s32:#06x} {s48:#06x} {int(m.sum()):>8} {k:>9}")

        if k:
            idx = np.flatnonzero(m)[np.flatnonzero(diff)[:3]]
            for i in idx:
                exp = farm_multiply(A[i:i+1], B[i:i+1], s24, s32, s48)[0]
                print(f"    A={int(A[i]):#010x} B={int(B[i]):#010x}")
                print(f"      RTL   = {int(AB[i]):#018x}")
                print(f"      model = {int(exp):#018x}")

    print()
    if total_mismatch == 0:
        print(f"Pass: model matches RTL on all {n} vectors.")
        return 0
    print(f"Fail: {total_mismatch}/{n} mismatches.")
    return 1


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(2)
    sys.exit(main(sys.argv[1]))
