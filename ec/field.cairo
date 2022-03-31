from bigint import BigInt3, UnreducedBigInt3, UnreducedBigInt5, nondet_bigint3, bigint_mul, verify_urbigint5_zero
from param_def import BASE

func verify_urbigInt3_zero{range_check_ptr}(val : UnreducedBigInt3, n : BigInt3):
    verify_urbigint5_zero(UnreducedBigInt5(d0=val.d0, d1=val.d1, d2=val.d2, 0, 0), n)
    return ()
end

#return 1 if x ==0 mod n
func is_urbigInt3_zero{range_check_ptr}(x : BigInt3, n : BigInt3) -> (res : felt):
    %{
        from starkware.cairo.common.cairo_secp.secp_utils import  pack
        n = pack(ids.n, PRIME)
        x = pack(ids.x, PRIME) % n
    %}
    if nondet %{ x == 0 %} != 0:
        verify_urbigInt3_zero(UnreducedBigInt3(d0=x.d0, d1=x.d1, d2=x.d2), n)
        return (res=1)
    end
    
    %{
        from starkware.python.math_utils import div_mod
        value = x_inv = div_mod(1, x, n)
    %}
    let (x_inv) = nondet_bigint3()
    let (x_x_inv) = bigint_mul(x, x_inv)

    # Check that x * x_inv = 1 to verify that x != 0.
    verify_urbigint5_zero(UnreducedBigInt5(
        d0=x_x_inv.d0 - 1,
        d1=x_x_inv.d1,
        d2=x_x_inv.d2,
        d3=x_x_inv.d3,
        d4=x_x_inv.d4), n)
    return (res=0)
end