module Intervals

import Base: in, ==, <, <=, >, >=, isempty, show, union, intersect, empty

include("types.jl")
include("constructors.jl")
include("accessors.jl")
include("queries.jl")


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

function (<)(a::AbstractInterval, b::AbstractInterval)
    return boundedright(a) && boundedleft(b) && ((right(a) < left(b)) || ((openright(a) || openleft(b)) && (right(a) == left(b))))
end

function (<=)(a::AbstractInterval, b::AbstractInterval)
    return boundedright(a) && boundedright(b) && ((right(a) < right(b)) || ((openright(a) || closedright(b)) && (right(a) == right(b))))
end

function (>)(a::AbstractInterval, b::AbstractInterval)
    return boundedleft(a) && boundedright(b) && ((right(b) < left(a)) || ((openleft(a) || openright(b)) && (right(a) == left(b))))
end

function (>=)(a::AbstractInterval, b::AbstractInterval)
    return boundedleft(a) && boundedleft(b) && ((left(b) < left(a)) || ((openleft(a) || closedleft(b)) && (left(a) == left(b))))
end

function (<)(x, a::AbstractInterval)
    return boundedleft(a) && ((x < left(a)) || ((openleft(a) && (x == left(a)))))
end

function (<=)(x, a::AbstractInterval)
    return boundedright(a) && ((x < right(a)) || ((closedright(a) && (x == right(a)))))
end

function (>)(x, a::AbstractInterval)
    return boundedright(a) && ((right(a) < x) || ((openright(a) && (x == right(a)))))
end

function (>=)(x, a::AbstractInterval)
    return boundedleft(a) && ((left(a) < x) || ((closedleft(a) && (x == left(a)))))
end

function in(x, a::AbstractInterval)
    return (x <= a) && (x >= a)
end



function show(io::IO, a::AbstractInterval)
    if isempty(a)
        print(io, "()")
    elseif issingleton(a)
        print(io, "[$(left(a))]")
    else
        closedleft(a) ? print(io, '[') : print(io, '(')
        unboundedleft(a) ? print(io, "-∞") : print(io, left(a))
        print(",")
        unboundedright(a) ? print(io, "+∞") : print(io, right(a))
        closedright(a) ? print(io, ']') : print(io, ')')
    end
    return nothing
end

function overlaps(a::AbstractInterval, b::AbstractInterval)
    return ((a <= b) && !(a < b)) || ((a >= b) && !(a > b))
end





(<)(::EmptyInterval, ::Any) = false
(<=)(::EmptyInterval, ::Any) = false
(>)(::EmptyInterval, ::Any) = false
(>=)(::EmptyInterval, ::Any) = false
(<)(::Any, ::EmptyInterval) = false
(<=)(::Any, ::EmptyInterval) = false
(>)(::Any, ::EmptyInterval) = false
(>=)(::Any, ::EmptyInterval) = false





(<)(::LeftUnboundedInterval, ::Any) = true
(<)(::Any, ::LeftUnboundedInterval) = false



(>)(::RightUnboundedInterval, ::Any) = true
(>)(::Any, ::RightUnboundedInterval) = false


(>)(::UnboundedInterval, ::Any) = false
(>)(::Any, ::UnboundedInterval) = false
(<)(::UnboundedInterval, ::Any) = false
(<)(::Any, ::UnboundedInterval) = false
in(::Any, ::UnboundedInterval) = true




# Union between an empty interval and anything is that other thing.
union(a::AbstractInterval{T}, ::EmptyInterval{T}) where T = a
union(::EmptyInterval{T}, b::AbstractInterval{T}) where T = b

# Union between an unbounded interval and anything is unbounded
union(::AbstractInterval{T}, b::UnboundedInterval{T}) where T = b
union(a::UnboundedInterval{T}, ::AbstractInterval{T}) where T = a

# Everything else
union(a::AbstractInterval{T}, b::AbstractInterval{T}) where T = disjoint(a, b)

# Intersection between an empty and anything is empty.
intersect(::EmptyInterval{T}, ::AbstractInterval{T}) where T = EmptyInterval(T)
intersect(::AbstractArray{T}, ::EmptyInterval{T}) where T = EmptyInterval(T)

# Intersection between unbounded and anything is that thing.
intersect(::UnboundedInterval{T}, b::AbstractInterval{T}) where T = b
intersect(a::AbstractArray{T}, ::UnboundedInterval{T}) where T = a

# Intersection between a singleton and anything is either the singleton or empty.
intersect(a::AbstractInterval{T}, b::SingletonInterval{T}) where T = overlaps(a, b) ? b : EmptyInterval(T)
intersect(a::SingletonInterval{T}, b::AbstractInterval{T}) where T = intersect(b, a)

# Everything else
function intersect(a::AbstractInterval{T}, b::AbstractInterval{T}) where T
    !overlaps(a, b) && return EmptyInterval(T)
    la = left(a)
    lb = left(b)
    ra = right(a)
    rb = right(b)

    left = _boundmax(la, lb)
    right = _boundmin(ra, rb)

    lc = (la == lb) ? closedleft(a) & closedleft(b) : left == la ? closedleft(a) : closedleft(b)
    rc = (ra == rb) ? closedright(a) & closedright(b) : right == ra ? closedright(a) : closedright(b)

    interval(left=left, right=right, closed=_closebound(lc, rc))
end

# constructors
export interval, disjoint
# operators
export in, ==, <, <=, >, >=
# accessors
export left, right, boundedleft, boundedright, closedleft, closedright, unboundedleft, unboundedright, openleft, openright, natomic, closed, bounded
# queries
# TODO: adjacent
export isempty, isbounded, issingleton, overlaps
# operations
# TODO: complement
# TODO: difference
export show, union, intersect

end # module
