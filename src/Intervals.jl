module Intervals

import Base: ∈, ==, <, ≤, >, ≥, isempty, show, union, intersect, empty

include("types.jl")
include("constructors.jl")
include("accessors.jl")
include("queries.jl")
include("operators.jl")
include("operations.jl")



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
export ∈, ==, <, ≤, >, ≥
# accessors
export left, right, boundedleft, boundedright, closedleft, closedright, unboundedleft, unboundedright, openleft, openright, natomic, closed, bounded
# queries
export isempty, isbounded, issingleton
# operations
# TODO: complement
# TODO: difference
export show, union, intersect, overlaps, adjacent

end # module
