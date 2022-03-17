from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from param_def import P0, P1, P2, BASE
from utils import adc, sbb

# Represents an integer defined by
#   d0 + BASE * d1 + BASE**2 * d2.
# Note that the limbs (d_i) are NOT restricted to the range [0, BASE) and in particular they
# can be negative.
# In most cases this is used to represent a elliptic curve field element.
struct UnreducedBigInt3:
    member d0 : felt
    member d1 : felt
    member d2 : felt
end

# Same as UnreducedBigInt3, except that d0, d1 and d2 must be in the range [0, 3 * BASE).
# In most cases this is used to represent a elliptic curve field element.
struct BigInt3:
    member d0 : felt
    member d1 : felt
    member d2 : felt
end

# Represents a big integer: sum_i(BASE**i * d_i).
# Note that the limbs (d_i) are NOT restricted to the range [0, BASE) and in particular they
# can be negative.
struct UnreducedBigInt5:
    member d0 : felt
    member d1 : felt
    member d2 : felt
    member d3 : felt
    member d4 : felt
end

func bigint_mul(x : BigInt3, y : BigInt3) -> (res : UnreducedBigInt5):
    return (
        UnreducedBigInt5(
        d0=x.d0 * y.d0,
        d1=x.d0 * y.d1 + x.d1 * y.d0,
        d2=x.d0 * y.d2 + x.d1 * y.d1 + x.d2 * y.d0,
        d3=x.d1 * y.d2 + x.d2 * y.d1,
        d4=x.d2 * y.d2))
end

func sub_inner{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(l0, l1, l2, l3, r0, r1, r2, r3) -> (res:BigInt3, borrow):
    let (w0, borrow) = sbb(l0, r0, 0)
    let (w1, borrow) = sbb(l1, r1, borrow)
    let (w2, borrow) = sbb(l2, r2, borrow)
    let (_, borrow) = sbb(l3, r3, borrow)

    let (ba0) = bitwise_and(P0, borrow)
    let (ba1) = bitwise_and(P1, borrow)
    let (ba2) = bitwise_and(P2, borrow)

    let (w0, carry) = adc(w0, ba0, 0)
    let (w1, carry) = adc(w1, ba1, carry)
    let (w2, _) = adc(w2, ba2, carry)

    return (
        res=BigInt3(
        d0=w0,
        d1=w1,
        d2=w2,
    ),
    borrow=borrow)
end

# Returns x - y mod p
func bigint_sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x: BigInt3, y: BigInt3) -> (res: BigInt3):
    let (res, borrow) = sub_inner(x.d0, x.d1, x.d2, 0, y.d0, y.d1, y.d2, 0)
    return (res=res)
end

# Returns a BigInt3 instance whose value is controlled by a prover hint.
#
# Soundness guarantee: each limb is in the range [0, 3 * BASE).
# Completeness guarantee (honest prover): the value is in reduced form and in particular,
# each limb is in the range [0, BASE).
#
# Hint arguments: value.
func nondet_bigint3{range_check_ptr}() -> (res : BigInt3):
    # The result should be at the end of the stack after the function returns.
    let res : BigInt3 = [cast(ap + 5, BigInt3*)]
    %{
        from starkware.cairo.common.cairo_secp.secp_utils import split
        segments.write_arg(ids.res.address_, split(value))
    %}
    # The maximal possible sum of the limbs, assuming each of them is in the range [0, BASE).
    const MAX_SUM = 3 * (BASE - 1)
    assert [range_check_ptr] = MAX_SUM - (res.d0 + res.d1 + res.d2)

    # Prepare the result at the end of the stack.
    tempvar range_check_ptr = range_check_ptr + 4
    [range_check_ptr - 3] = res.d0; ap++
    [range_check_ptr - 2] = res.d1; ap++
    [range_check_ptr - 1] = res.d2; ap++
    static_assert &res + BigInt3.SIZE == ap
    return (res=res)
end
