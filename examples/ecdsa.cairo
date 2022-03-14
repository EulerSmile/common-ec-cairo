from bigint import BASE, BigInt3, bigint_mul, nondet_bigint3, UnreducedBigInt5
from param_def import P0, P1, P2, N0, N1, N2, GX0, GX1, GX2, GY0, GY1, GY2, A0, A1, A2
from field import verify_urbigInt5_zero
from ec import EcPoint, ec_add, ec_mul

from starkware.cairo.common.math import assert_nn_le, assert_not_zero

# Computes x * s^(-1) modulo the size of the elliptic curve (N).
func mul_s_inv{range_check_ptr}(x : BigInt3, s : BigInt3, N : BigInt3) -> (res : BigInt3):
    
    %{
        from starkware.cairo.common.cairo_secp.secp_utils import pack
        from starkware.python.math_utils import div_mod, safe_div

        n = pack(ids.N, PRIME)
        x = pack(ids.x, PRIME) % n
        s = pack(ids.s, PRIME) % n
        value = res = div_mod(x, s, n)
    %}
    let (res) = nondet_bigint3()

    %{ value = k = safe_div(res * s - x, n) %}
    let (k) = nondet_bigint3()

    let (res_s) = bigint_mul(res, s)
    
    let (k_n) = bigint_mul(k, N)

    # We should now have res_s = k_n + x. Since the numbers are in unreduced form,
    # we should handle the carry.

    tempvar carry1 = (res_s.d0 - k_n.d0 - x.d0) / BASE
    assert [range_check_ptr + 0] = carry1 + 2 ** 127

    tempvar carry2 = (res_s.d1 - k_n.d1 - x.d1 + carry1) / BASE
    assert [range_check_ptr + 1] = carry2 + 2 ** 127

    tempvar carry3 = (res_s.d2 - k_n.d2 - x.d2 + carry2) / BASE
    assert [range_check_ptr + 2] = carry3 + 2 ** 127

    tempvar carry4 = (res_s.d3 - k_n.d3 + carry3) / BASE
    assert [range_check_ptr + 3] = carry4 + 2 ** 127

    assert res_s.d4 - k_n.d4 + carry4 = 0

    let range_check_ptr = range_check_ptr + 4

    return (res=res)
end

# Verifies that val is in the range [1, N).
func validate_signature_entry{range_check_ptr}(val : BigInt3):
    assert_nn_le(val.d2, N2)
    assert_nn_le(val.d1, BASE - 1)
    assert_nn_le(val.d0, BASE - 1)

    if val.d2 == N2:
        if val.d1 == N1:
            assert_nn_le(val.d0, N0 - 1)
            return ()
        end
        assert_nn_le(val.d1, N1 - 1)
        return ()
    end

    if val.d2 == 0:
        if val.d1 == 0:
            # Make sure val > 0.
            assert_not_zero(val.d0)
            return ()
        end
    end
    return ()
end

# Verify a point lies on the curve.
# In the EC lib, we don't use `b` parameter explictly,
# so to verify whether a point lies on the curve or not,
# we use `G` to compare.
# y_G^2 - y_pt^2 = x_G^3 - x_pt^3 + a(x_G - x_pt) =>
# (y_G - y_pt)(y_G + y_pt) = (x_G^2 + x_G*x_pt + x_pt^2 + a)(x_G - x_pt)
func verify_point{range_check_ptr}(pt: EcPoint):
    let GX = BigInt3(GX0, GX1, GX2)
    let GY = BigInt3(GY0, GY1, GY2)
    let P = BigInt3(P0, P1, P2)
    %{
        from starkware.cairo.common.cairo_secp.secp_utils import pack

        p = ids.P0 + ids.P1 * 2 ** 86 + ids.P2 *2 ** 172
        gx = ids.GX0 + ids.GX1 * 2 ** 86 + ids.GX2 * 2 ** 172
        kx = pack(ids.pt.x, PRIME)

        gx2 = (gx * gx) % p
        gkx_prod = (gx * kx) % p
        kx2 = (kx * kx) % p

        a = ids.A0 + ids.A1 * 2 ** 86 + ids.A2 * 2 ** 172
        value = q = (gx2 + gkx_prod + kx2 + a) % p
    %}

    let (q) = nondet_bigint3()

    # check correctness of q.
    let (gx2) = bigint_mul(GX, GX)
    let (gkx_prod) = bigint_mul(pt.x, GX)
    let (kx2) = bigint_mul(pt.x, pt.x)

    verify_urbigInt5_zero(UnreducedBigInt5(
        d0 = gx2.d0 + gkx_prod.d0 + kx2.d0 + A0 - q.d0,
        d1 = gx2.d1 + gkx_prod.d1 + kx2.d1 + A1 - q.d1,
        d2 = gx2.d2 + gkx_prod.d2 + kx2.d2 + A2 - q.d2,
        d3 = gx2.d3 + gkx_prod.d3 + kx2.d3,
        d4 = gx2.d4 + gkx_prod.d4 + kx2.d4,
    ), P)

    # check left == right
    let gky_diff = BigInt3(
        d0 = GY0 - pt.y.d0,
        d1 = GY1 - pt.y.d1,
        d2 = GY2 - pt.y.d2
    )
    let gky_sum = BigInt3(
        d0 = GY0 + pt.y.d0,
        d1 = GY1 + pt.y.d1,
        d2 = GY2 + pt.y.d2
    )
    let gkx_diff = BigInt3(
        d0 = GX0 - pt.x.d0,
        d1 = GX1 - pt.x.d1,
        d2 = GX2 - pt.x.d2
    )
    let (left_diff) = bigint_mul(gky_diff, gky_sum)
    let (right_diff) = bigint_mul(q, gkx_diff)

    verify_urbigInt5_zero(
        UnreducedBigInt5(
        d0 = left_diff.d0 - right_diff.d0,
        d1 = left_diff.d1 - right_diff.d1,
        d2 = left_diff.d2 - right_diff.d2,
        d3 = left_diff.d3 - right_diff.d3,
        d4 = left_diff.d4 - right_diff.d4,
    ), P)

    return ()
end

# Verifies a ECDSA signature.
# Soundness assumptions:
# * All the limbs of public_key_pt.x, public_key_pt.y, msg_hash are in the range [0, 3 * BASE).
func verify_ecdsa{range_check_ptr}(
        public_key_pt : EcPoint, msg_hash : BigInt3, r : BigInt3, s : BigInt3):
    alloc_locals
    verify_point(public_key_pt)
    validate_signature_entry(r)
    validate_signature_entry(s)

    let gen_pt = EcPoint(
        BigInt3(GX0, GX1, GX2),
        BigInt3(GY0, GY1, GY2))
    
    let N = BigInt3(N0, N1, N2)
    # Compute u1 and u2.
    let (u1 : BigInt3) = mul_s_inv(msg_hash, s, N)
    let (u2 : BigInt3) = mul_s_inv(r, s, N)

    let (gen_u1) = ec_mul(gen_pt, u1)
    let (pub_u2) = ec_mul(public_key_pt, u2)
    let (res) = ec_add(gen_u1, pub_u2)
    
    # The following assert also implies that res is not the zero point.
    assert res.x = r
    
    return ()
end