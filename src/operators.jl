"""
Two `AtomicInterval` are equal iff their limits are equal in all respects (value, closedness, and boundedness).
"""
function (==)(a::AtomicInterval, b::AtomicInterval)
    # empty and unbounded intervals might look the same, but they are not.
    if isempty(a) && isempty(b)
        return true
    end
    (left(a) == left(b)) &&
        (right(a) == right(b)) &&
        (closedleft(a) == closedleft(b)) && 
        (closedright(a) == closedright(b)) &&
        (boundedleft(a) == boundedleft(b)) &&
        (boundedright(a) == boundedright(b))
end

"""
Two `DisjointInterval` types are equal iff all of their contained `AtomicInterval` values compare equal.
"""
function (==)(a::DisjointInterval, b::DisjointInterval)
    natomic(a) != natomic(b) && return false
    all(a.ivs .== b.ivs)
end

"""
An 'AtomicInterval` and a `DisjointInterval` are equal iff the `DisjointInterval` has exactly one contained interval and it equals the `AtomicInterval`.
"""
function (==)(a::DisjointInterval, b::AtomicInterval)
    natomic(a) != 1 && return false
    a.ivs[1] == b
end
(==)(a::AtomicInterval, b::DisjointInterval) = b == a

"""
Interval `a` compares less than interval `b` iff the entire span of `a` lies to the left of the _left limit_ of interval `b`.
"""
function (<)(a::AbstractInterval, b::AbstractInterval)
    return boundedright(a) && boundedleft(b) && ((right(a) < left(b)) || ((openright(a) || openleft(b)) && (right(a) == left(b))))
end

"""
Interval `a` compares less than or equal to interval `b` iff the entire span of `a` lies to the left of the _right limit_ (inclusive if closed) of interval `b`.
"""
function (≤)(a::AbstractInterval, b::AbstractInterval)
    return boundedright(a) && boundedright(b) && ((right(a) < right(b)) || ((openright(a) || closedright(b)) && (right(a) == right(b))))
end

"""
Interval `a` compares greater than interval `b` iff the entire span of `a` lies to the right of the _right limit_ of interval `b`.
"""
function (>)(a::AbstractInterval, b::AbstractInterval)
    return boundedleft(a) && boundedright(b) && ((right(b) < left(a)) || ((openleft(a) || openright(b)) && (right(a) == left(b))))
end

"""
Interval `a` compares greater than or equal to interval `b` iff the entire span of `a` lies to the right of the _left limit_ (inclusive if closed) of interval `b`.
"""
function (≥)(a::AbstractInterval, b::AbstractInterval)
    return boundedleft(a) && boundedleft(b) && ((left(b) < left(a)) || ((openleft(a) || closedleft(b)) && (left(a) == left(b))))
end

"""
Value `x` compares less than interval `a` iff it lies to the left of the _left limit_ of interval `a`.
"""
function (<)(x, a::AbstractInterval)
    return boundedleft(a) && ((x < left(a)) || ((openleft(a) && (x == left(a)))))
end

"""
Value `x` compares less than or equal to interval `a` iff it lies to the left of the _right limit_ (inclusive if closed) of interval `a`.
"""
function (≤)(x, a::AbstractInterval)
    return boundedright(a) && ((x < right(a)) || ((closedright(a) && (x == right(a)))))
end

"""
Value `x` compares greater than interval `a` iff it lies to the right of the _right limit_ of interval `a`.
"""
function (>)(x, a::AbstractInterval)
    return boundedright(a) && ((right(a) < x) || ((openright(a) && (x == right(a)))))
end

"""
Value `x` compares less than or equal to interval `a` iff it lies to the right of the _left limit_ (inclusive if closed) of interval `a`.
"""
function (≥)(x, a::AbstractInterval)
    return boundedleft(a) && ((left(a) < x) || ((closedleft(a) && (x == left(a)))))
end

"""
Value `x` is in interval `a` iff it lies between the left and right limits (inclusive if closed) of interval `a`.
"""
function (∈)(x, a::AbstractInterval)
    return (x ≤ a) && (x ≥ a)
end

"""
difference(a, b)

Remove interval `b` from interval `a`.  This difference is _not_ symmetric.

Always returns a `DisjointInterval`, regardless of whether or not `b` overlaps `a`.
"""
function difference(a::AtomicInterval{T}, b::AtomicInterval{T}) where T
    # trivial cases
    overlaps(a, b) || return disjoint(a)
    a ∈ b && return disjoint(EmptyInterval{T}())  # includes ==

    la = left(a)
    ra = right(a)
    lb = left(b)
    rb = right(b)

    # simplest case: adjacent difference
    ra == lb && return disjoint(interval(left=la, right=ra, closed=_closebound(closedleft(a), true)), interval(left=lb, right=rb, closed=_closebound(false, closedright(b))))
    la == rb && return disjoint(interval(left=la, right=ra, closed=_closebound(true, closedright(a))), interval(left=lb, right=rb, closed=_closebound(closedleft(b), false)))

    # next, overlapping of one of the limits
    a ≤ b && return disjoint(interval(left=la, right=lb, closed=_closebound(closedleft(a), openleft(b))))
    a ≥ b && return disjoint(interval(left=rb, right=ra, closed=_closebound(openright(b), closedright(a))))

    # finally, split a
    disjoint(interval(left=la, right=lb, closed=_closebound(closedleft(a), openleft(b))), interval(left=ra, right=rb, closed=_closebound(openright(b), closedright(a))))
end

difference(a::EmptyInterval{T}, ::AbstractInterval{T}) where T = disjoint(a)
difference(a::AbstractInterval{T}, ::EmptyInterval{T}) where T = disjoint(a)
difference(::AbstractInterval{T}, ::UnboundedInterval{T}) where T = disjoint(EmptyInterval{T}())

difference(a::DisjointInterval{T}, b::AtomicInterval{T}) where T = disjoint(difference(iv, b) for iv in a.ivs)
difference(a::AtomicInterval{T}, b::DisjointInterval{T}) where T = disjoint(difference(a, iv) for iv in b.ivs)

function difference(a::DisjointInterval{T}, b::DisjointInterval{T}) where T
    out = IntervalArray{T}()
    i = 1
    j = 1
    while i <= length(a.ivs) && j <= length(b.ivs)
        if a.ivs[i] < b.ivs[j]
            push!(out, a.ivs[i])
            i += 1
            continue
        elseif a.ivs[i] > b.ivs[j]
            j += 1
            continue
        else
            push!(out, difference(a.ivs[i], b.ivs[j]))
            j += 1
            continue
        end
    end
    if i == length(a.ivs)
        push!(out, a.ivs[i])
    end
    disjoint(out...)
end

(-)(a::AbstractInterval{T}, b::AbstractInterval{T}) where T = difference(a, b)

(<)(a::AbstractInterval, x) = x > a
(≤)(a::AbstractInterval, x) = x ≥ a
(>)(a::AbstractInterval, x) = x < a
(≥)(a::AbstractInterval, x) = x ≤ a

# Special definitions
(<)(::EmptyInterval, ::Any) = false
(<=)(::EmptyInterval, ::Any) = false
(>)(::EmptyInterval, ::Any) = false
(>=)(::EmptyInterval, ::Any) = false
(<)(::Any, ::EmptyInterval) = false
(<=)(::Any, ::EmptyInterval) = false
(>)(::Any, ::EmptyInterval) = false
(>=)(::Any, ::EmptyInterval) = false
(∈)(::Any, ::EmptyInterval) = false

(<)(::LeftUnboundedInterval, ::Any) = true
(<)(::Any, ::LeftUnboundedInterval) = false

(>)(::RightUnboundedInterval, ::Any) = true
(>)(::Any, ::RightUnboundedInterval) = false

(>)(::UnboundedInterval, ::Any) = false
(>)(::Any, ::UnboundedInterval) = false
(<)(::UnboundedInterval, ::Any) = false
(<)(::Any, ::UnboundedInterval) = false
(∈)(::Any, ::UnboundedInterval) = true