import argparse
import numpy as np

def _u(x):
    return np.uint64(x)

# adder_4bit
def adder_4bit(A, B, Cin, Cin_apx, sel):
    P = A ^ B
    G = A & B
    p = [(P >> _u(i)) & _u(1) for i in range(4)]
    g = [(G >> _u(i)) & _u(1) for i in range(4)]
    Cin_ = Cin if sel else Cin_apx
    s0 = p[0] ^ Cin
    c0 = g[0] | (p[0] & Cin_)
    s1 = p[1] ^ c0
    c1 = g[1] | (p[1] & c0)
    s2 = p[2] ^ c1
    c2 = g[2] | (p[2] & c1)
    s3 = p[3] ^ c2
    C_actual = g[3] | (p[3] & c2)
    C_approx = g[3] | (p[3] & (g[2] | (p[2] & (g[1] | (p[1] & g[0])))))
    S = s0 | (s1 << _u(1)) | (s2 << _u(2)) | (s3 << _u(3))
    return S, C_actual, C_approx

def _bits(v, n):
    return [(v >> i) & 1 for i in range(n)]

def _fara(A, B, Cin, sel_list, nblk):
    S = np.zeros_like(A)
    c_act = c_apx = Cin
    for k in range(nblk):
        a = (A >> _u(4 * k)) & _u(0xF)
        b = (B >> _u(4 * k)) & _u(0xF)
        s, c_act, c_apx = adder_4bit(a, b, c_act, c_apx, sel_list[k])
        S |= (s << _u(4 * k))
    return S, c_act

def adder_24bit(A, B, Cin, sel24):
    return _fara(A, B, Cin, [1] + _bits(sel24, 5), 6)

def adder_32bit(A, B, Cin, sel32):
    return _fara(A, B, Cin, [1] + _bits(sel32, 7), 8)

def adder_48bit(A, B, Cin, sel48):
    return _fara(A, B, Cin, [1] + _bits(sel48, 10) + [1], 12)

# Multipliers
def _mul16(A, B, sel24):
    Al, Ah = A & _u(0xFF), (A >> _u(8)) & _u(0xFF)
    Bl, Bh = B & _u(0xFF), (B >> _u(8)) & _u(0xFF)
    ALBL, ALBH, AHBL, AHBH = Al*Bl, Al*Bh, Ah*Bl, Ah*Bh
    add1 = ALBH + AHBL
    hi = (AHBH << _u(8)) | (ALBL >> _u(8))
    z = np.zeros_like(A)
    add2, _ = adder_24bit(hi & _u(0xFFFFFF), add1 & _u(0xFFFFFF), z, sel24)
    return ((add2 & _u(0xFFFFFF)) << _u(8)) | (ALBL & _u(0xFF))

def farm_multiply(A, B, sel24, sel32, sel48):
    Al, Ah = A & _u(0xFFFF), (A >> _u(16)) & _u(0xFFFF)
    Bl, Bh = B & _u(0xFFFF), (B >> _u(16)) & _u(0xFFFF)
    ALBL = _mul16(Al, Bl, sel24)
    ALBH = _mul16(Al, Bh, sel24)
    AHBL = _mul16(Ah, Bl, sel24)
    AHBH = _mul16(Ah, Bh, 0x1F)
    z = np.zeros_like(A)
    S32, C32 = adder_32bit(ALBH, AHBL, z, sel32)
    add1 = (C32 << _u(32)) | S32
    hi = (AHBH << _u(16)) | (ALBL >> _u(16))
    M = _u(0xFFFFFFFFFFFF)
    add2, _ = adder_48bit(hi & M, add1 & M, z, sel48)
    return ((add2 & M) << _u(16)) | (ALBL & _u(0xFFFF))


# Metrics
_POP = np.array([bin(i).count("1") for i in range(256)], dtype=np.uint8)
def _popcount(x):
    if hasattr(np, "bitwise_count"):
        return np.bitwise_count(x).astype(np.float64)
    return _POP[x.view(np.uint8).reshape(-1, 8)].sum(1).astype(np.float64)

class Acc:
    def __init__(s): s.n=s.ne=s.nr=0; s.ed=s.red=s.hd=0.0
    def add(s, e, a):
        d=np.where(e>=a, e-a, a-e).astype(np.float64)
        s.n+=d.size; s.ne+=int(np.count_nonzero(d)); s.ed+=float(d.sum())
        nz=e!=0
        s.red+=float((d[nz]/e[nz].astype(np.float64)).sum()); s.nr+=int(nz.sum())
        s.hd+=float(_popcount(e^a).sum())
    def out(s):
        M=float(2**64-1)
        return dict(ER=100*s.ne/s.n, ED=s.ed/s.n,
                    MRED=100*s.red/max(s.nr,1),
                    NMED=100*(s.ed/s.n)/M, HDP=s.hd/s.n)

CONFIGS = [
    ("C0 exact (=V4)",     (0x1F, 0x7F, 0x3FF)),
    ("C1 (=V1)",           (0x00, 0x00, 0x000)),
    ("C2 (=V2)",           (0x1B, 0x00, 0x000)),
    ("C3 (=V3)",           (0x1B, 0x55, 0x155)),
    ("C4 (32/48 exact)",   (0x00, 0x7F, 0x3FF)),
]

def _napx(sel):
    z=lambda v,w: w-bin(v).count("1")
    return z(sel[0],5)+z(sel[1],7)+z(sel[2],10)

def run(bits, n, seed):
    hi=1<<bits
    print(f"\n{bits}-bit operands, N={n:,} per config, seed={seed}")
    print(f"{'config':<20}{'n_a':>5}{'ER%':>9}{'ED':>11}"
          f"{'MRED%':>9}{'NMED%':>11}{'HDP':>8}")
    for name,sel in CONFIGS:
        s24,s32,s48=sel
        rng=np.random.default_rng(seed); acc=Acc(); d=0
        while d<n:
            m=min(250_000,n-d)
            A=rng.integers(0,hi,size=m,dtype=np.uint64)
            B=rng.integers(0,hi,size=m,dtype=np.uint64)
            acc.add(A*B, farm_multiply(A,B,s24,s32,s48)); d+=m
        r=acc.out()
        print(f"{name:<20}{_napx(sel):>5}{r['ER']:>9.3f}{r['ED']:>11.3e}"
              f"{r['MRED']:>9.4f}{r['NMED']:>11.3e}{r['HDP']:>8.3f}")

def selftest():
    ok=True
    a=np.arange(4,dtype=np.uint64); A,B=np.meshgrid(a,a); A,B=A.ravel(),B.ravel()
    a0,a1=A&_u(1),(A>>_u(1))&_u(1); b0,b1=B&_u(1),(B>>_u(1))&_u(1)
    pp01,pp10,pp11=a0&b1,a1&b0,a1&b1
    P=(a0&b0)|((pp01^pp10)<<_u(1))|(((pp01&pp10)^pp11)<<_u(2))|((pp01&pp10&pp11)<<_u(3))
    print("2x2 == A*B (exhaustive):", "pass" if np.array_equal(P,A*B) else "FAIL")
    ok&=np.array_equal(P,A*B)
    rng=np.random.default_rng(1)
    A=rng.integers(0,1<<32,size=200_000,dtype=np.uint64)
    B=rng.integers(0,1<<32,size=200_000,dtype=np.uint64)
    exact_ok=np.array_equal(farm_multiply(A,B,0x1F,0x7F,0x3FF),A*B)
    print("exact mode bit-exact (2e5 random):", "pass" if exact_ok else "FAIL")
    ok&=exact_ok
    small=np.arange(256,dtype=np.uint64); A,B=np.meshgrid(small,small)
    A,B=A.ravel(),B.ravel()
    nb=int(np.count_nonzero(farm_multiply(A,B,0,0,0)!=A*B))
    print(f"8-bit operands exact in max-apx mode: {nb}/65536 differ",
          "(expected 0)")
    ok&=(nb==0)
    print("Selftest", "Okay" if ok else "Failed")

if __name__=="__main__":
    ap=argparse.ArgumentParser()
    ap.add_argument("--n",type=int,default=2_500_000)
    ap.add_argument("--seed",type=int,default=20260719)
    ap.add_argument("--selftest",action="store_true")
    a=ap.parse_args()
    if a.selftest:
        selftest()
    else:
        selftest()
        run(32,a.n,a.seed)
        run(16,a.n,a.seed)
