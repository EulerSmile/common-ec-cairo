# The domain paramters of elliptic curve.

# P = sum(P_i * BASE^i)
    # NIST P-256
    # const P0 = 0x3fffffffffffffffffffff
    # const P1 = 0x3ff
    # const P2 = 0xffffffff0000000100000

    # Secp256 K1
    const P0 = 0x3ffffffffffffefffffc2f
    const P1 = 0x3fffffffffffffffffffff
    const P2 = 0xfffffffffffffffffffff

# N = sum(N_i * BASE^i)
    # NIST P-256
    # const N0 = 0x179e84f3b9cac2fc632551
    # const N1 = 0x3ffffffffffef39beab69c
    # const N2 = 0xffffffff00000000fffff

    # Secp256 K1
    const N0 = 0x8a03bbfd25e8cd0364141
    const N1 = 0x3ffffffffffaeabb739abd
    const N2 = 0xfffffffffffffffffffff

# A
    # NIST P-256
    # const A = -3

    # Secp256 K1
    const A = 0

# Gx = sum(Gx_i * BASE^i)
    # NIST P-256
    # const GX0 = 0x2b33a0f4a13945d898c296
    # const GX1 = 0x1b958e9103c9dc0df604b7
    # const GX2 = 0x6b17d1f2e12c4247f8bce

    # Secp256 K1
    const GX0 = 0xe28d959f2815b16f81798
    const GX1 = 0xa573a1c2c1c0a6ff36cb7
    const GX2 = 0x79be667ef9dcbbac55a06

# Gy = sum(Gy_i * BASE^i)
    # NIST P-256
    # const GY0 = 0x315ececbb6406837bf51f5
    # const GY1 = 0x2d29f03e7858af38cd5dac
    # const GY2 = 0x4fe342e2fe1a7f9b8ee7e

    # Secp256 K1
    const GY0 = 0x554199c47d08ffb10d4b8
    const GY1 = 0x2ff0384422a3f45ed1229a
    const GY2 = 0x483ada7726a3c4655da4f
