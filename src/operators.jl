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
    if natomic(a) != natomic(b)
        return false
    end
    for i = 1:natomic(a)
        if a.ivs[i] != b.ivs[i]
            return false
        end
    end
    true
end

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