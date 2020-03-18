module Intervals

import Base: in, ==, <, <=, >, >=, isempty, show, union, intersect, empty

include("types.jl")
include("constructors.jl")

function left(::AbstractInterval) end
function right(::AbstractInterval) end
function closedleft(::AbstractInterval) end
function closedright(::AbstractInterval) end
function boundedleft(::AbstractInterval) true end
function boundedright(::AbstractInterval) true end

openleft(a) = !closedleft(a)
openright(a) = !closedright(a)
unboundedleft(a) = !boundedleft(a)
unboundedright(a) = !boundedright(a)

function _closebound(l, r)
    l && r && return :both
    l && return :left
    r && return :right
    return :neither
end

closed(a) = _closebound(closedleft(a), closedright(a))
bounded(a) = _closebound(boundedleft(a), boundedright(a))

function (==)(a::AbstractInterval, b::AbstractInterval)
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

isempty(::AbstractInterval) = false
issingleton(::AbstractInterval) = false
isbounded(::AbstractInterval) = true
isdisjoint(::AbstractInterval) = false

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


left(a::Interval) = a.left
right(a::Interval) = a.right
closedleft(a::Interval) = a.left_closed
closedright(a::Interval) = a.right_closed

closedleft(::EmptyInterval) = false
closedright(::EmptyInterval) = false
boundedleft(::EmptyInterval) = false
boundedright(::EmptyInterval) = false
(<)(::EmptyInterval, ::Any) = false
(<=)(::EmptyInterval, ::Any) = false
(>)(::EmptyInterval, ::Any) = false
(>=)(::EmptyInterval, ::Any) = false
(<)(::Any, ::EmptyInterval) = false
(<=)(::Any, ::EmptyInterval) = false
(>)(::Any, ::EmptyInterval) = false
(>=)(::Any, ::EmptyInterval) = false
isempty(::EmptyInterval) = true
isbounded(::EmptyInterval) = false

left(a::SingletonInterval) = a.value
right(a::SingletonInterval) = a.value
closedleft(a::SingletonInterval) = true
closedright(a::SingletonInterval) = true

right(a::LeftUnboundedInterval) = a.right
closedleft(a::LeftUnboundedInterval) = false
closedright(a::LeftUnboundedInterval) = a.right_closed
boundedleft(a::LeftUnboundedInterval) = false
(<)(::LeftUnboundedInterval, ::Any) = true
(<)(::Any, ::LeftUnboundedInterval) = false
isbounded(::LeftUnboundedInterval) = false

left(a::RightUnboundedInterval) = a.left
closedleft(a::RightUnboundedInterval) = a.left_closed
closedright(a::RightUnboundedInterval) = false
boundedright(a::RightUnboundedInterval) = false
(>)(::RightUnboundedInterval, ::Any) = true
(>)(::Any, ::RightUnboundedInterval) = false
isbounded(::RightUnboundedInterval) = false

closedleft(::UnboundedInterval) = false
closedright(::UnboundedInterval) = false
boundedleft(::UnboundedInterval) = false
boundedright(::UnboundedInterval) = false
(>)(::UnboundedInterval, ::Any) = false
(>)(::Any, ::UnboundedInterval) = false
(<)(::UnboundedInterval, ::Any) = false
(<)(::Any, ::UnboundedInterval) = false
isbounded(::UnboundedInterval) = false
in(::Any, ::UnboundedInterval) = true

left(a::DisjointInterval) = left(first(a.ivs))
right(a::DisjointInterval) = right(last(a.ivs))
closedleft(a::DisjointInterval) = closedleft(first(a.ivs))
closedright(a::DisjointInterval) = closedright(last(a.ivs))
boundedleft(a::DisjointInterval) = boundedleft(first(a.ivs))
boundedright(a::DisjointInterval) = boundedright(last(a.ivs))
issingleton(a::DisjointInterval) = length(a.ivs) == 1 && issingleton(first(a.ivs))
isempty(a::DisjointInterval) = length(a.ivs) == 1 && isempty(first(a.ivs))
isbounded(a::DisjointInterval) = isbounded(first(a.ivs)) && isbounded(last(a.ivs))
isdisjoint(a::DisjointInterval) = length(a.ivs) > 1

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
# queries
# TODO: adjacent
export isempty, isbounded, issingleton, overlaps
# accessors
export left, right, boundedleft, boundedright, closedleft, closedright, unboundedleft, unboundedright, openleft, openright, natomic
# operations
# TODO: complement
# TODO: difference
export show, union, intersect

end # module
