"""
interval(left, right, closed=:neither)

Constructor for various `AtomicInterval` types.

Arguments
=========
`left`, `right`: left and right limits of the interval.  Empty values will be considered
    unbounded.  Unbounded limits are ignored and considered `-∞` (left) or `+∞` (right) for the
    type of the limits in the sense that all values of type `T` will compare
    greater than an unbounded left limit and less than an unbounded right limit,
    except infinity itself (if `isfinite` is defined for the type).

`closed`: whether the left, right, both, or neither limit is included in the interval.
    Must be one of `:neither` (default), `:left`, `:right`, or `:both`.

Return Values
=============
The type returned is always an `AtomicInterval{T}` representing the particular choices of limit and closed sides.
"""
function interval(;left::Union{T, Nothing} = nothing, right::Union{T, Nothing} = nothing, closed::Symbol = :neither) where T
    closed ∈ (:neither, :left, :right, :both) || throw(ArgumentError("'closed' must be one of (:neither, :left, :right, :both)"))
    lu = isnothing(left)
    ru = isnothing(right)
    lc = ((closed == :left) || (closed == :both))
    rc = ((closed == :right) || (closed == :both))
    if (lu && ru)
        return EmptyInterval{T}()
    end
    if !lu && !ru
        if (right < left) || ((right == left) && !lc && !rc)
            return EmptyInterval{T}()
        end
        if (lc || rc) && left == right
            return SingletonInterval(left)
        end
        return Interval(left, right, lc, rc)
    elseif lu
        return LeftUnboundedInterval(right, rc)
    else
        return RightUnboundedInterval(left, lc)
    end
end

function _boundmin(a, b)
    (isnothing(a) || isnothing(b)) && return nothing
    min(a, b)
end

function _boundmax(a, b)
    (isnothing(a) || isnothing(b)) && return nothing
    max(a, b)
end

function _simplify(a::AtomicInterval{T}, b::AtomicInterval{T}) where T
    !overlaps(a, b) && return sort!([a, b])
    la = left(a)
    lb = left(b)
    ra = right(a)
    rb = right(b)

    left = _boundmin(la, lb)
    right = _boundmax(ra, rb)

    lc = (la == lb) ? closedleft(a) | closedleft(b) : left == la ? closedleft(a) : closedleft(b)
    rc = (ra == rb) ? closedright(a) | closedright(b) : right == ra ? closedright(a) : closedright(b)

    [interval(left=left, right=right, closed=_closebound(lc, rc))]
end

_simplify(::AtomicInterval{T}, b::UnboundedInterval{T}) where T = [b]
_simplify(a::UnboundedInterval{T}, ::AtomicInterval{T}) where T = [a]
_simplify(a::AtomicInterval{T}, ::EmptyInterval{T}) where T = [a]
_simplify(::EmptyInterval{T}, b::AtomicInterval{T}) where T = [b]
function _simplify(a::LeftUnboundedInterval{T}, b::RightUnboundedInterval{T}) where T
    overlaps(a, b) && return [UnboundedInterval{T}()]
    [a, b]
end
_simplify(a::RightUnboundedInterval{T}, b::LeftUnboundedInterval{T}) where T = _simplify(b, a)
# TODO: simplify disjoint Intervals

function _reduce(ivs::IntervalArray{T}) where T
    sorted = sort!(ivs, by=x -> ismissing(left(x)) ? typemin(T) : left(x))
    a = popfirst!(sorted)
    out = IntervalArray{T}()
    while !isempty(sorted)
        b = popfirst!(sorted)
        s = _simplify(a, b)
        if length(s) == 1
            a = s[1]
            continue
        else
            push!(out, s[1])
            a = s[2]
        end
    end

    push!(out, a)
end

"""
disjoint(iv...)

Constructor for a (possibly disjoint) collection of various `AtomicInterval` types.  The type returned is always a `DisjointInterval`.

Arguments
=========
`iv::AtomicInterval{T}...`: any number of `AbstractInterval` objects with the same limit type `T`.

Return Value
============
Returns a `DisjointInterval` object with one or more disjoint intervals representing a simplified version of the arguments `iv...`.
"""
function disjoint(ivs::AtomicInterval{T}...) where T
    DisjointInterval(_reduce(collect(ivs)))
end

disjoint(a::DisjointInterval) = a