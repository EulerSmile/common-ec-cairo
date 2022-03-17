# Computes `a + b + carry`, returning the result along with the new carry.
# Input and Output values must be in range of [0, BASE).
from param_def import BASE
func adc{range_check_ptr}(a: felt, b: felt, carry: felt) -> (res, new_carry):
    alloc_locals
    local res
    local new_carry
    %{
        # Python treat a, b, carry as bigint, which could be bigger than 172 bits
        ids.res, ids.new_carry = divmod(ids.a + ids.b + ids.carry, ids.BASE)
    %}

    # Check that 0 <= a < BASE
    [range_check_ptr] = a
    assert [range_check_ptr + 1] = BASE - 1 - a

    # Check that 0 <= b < BASE
    [range_check_ptr + 2] = b
    assert [range_check_ptr + 3] = BASE - 1 - b

    # Check that 0 <= carry < BASE
    [range_check_ptr + 4] = carry
    assert [range_check_ptr + 5] = BASE - 1 - carry

    # Check that 0 <= res < BASE
    [range_check_ptr + 6] = res
    assert [range_check_ptr + 7] = BASE - 1 - res

    # Check that 0 <= new_carry < BASE
    [range_check_ptr + 8] = new_carry
    assert [range_check_ptr + 9] = BASE - 1 - new_carry

    let range_check_ptr = range_check_ptr + 10
    return (res=res, new_carry=new_carry)
end

# Computes `a - (b + borrow)`, returning the result along with the new borrow.
# Input and Output values must be in range of [0, BASE).
func sbb{range_check_ptr}(a: felt, b: felt, borrow: felt) -> (res, new_borrow):
    alloc_locals
    local res
    local new_borrow
    %{
        # Python treat a, b, borrow as bigint, which is bigger than 172 bits
        move = (ids.a - (ids.b + ids.borrow // (BASE / 2) )) % BASE**2
        ids.res, ids.new_borrow = divmod(move, BASE)
    %}

    # Check that 0 <= a < BASE
    [range_check_ptr] = a
    assert [range_check_ptr + 1] = BASE - 1 - a

    # Check that 0 <= b < BASE
    [range_check_ptr + 2] = b
    assert [range_check_ptr + 3] = BASE - 1 - b

    # Check that 0 <= borrow < BASE
    [range_check_ptr + 4] = borrow
    assert [range_check_ptr + 5] = BASE - 1 - borrow

    # Check that 0 <= res < BASE
    [range_check_ptr + 6] = res
    assert [range_check_ptr + 7] = BASE - 1 - res

    # Check that 0 <= new_borrow < BASE
    [range_check_ptr + 8] = new_borrow
    assert [range_check_ptr + 9] = BASE - 1 - new_borrow

    let range_check_ptr = range_check_ptr + 10
    return (res=res, new_borrow=new_borrow)
end