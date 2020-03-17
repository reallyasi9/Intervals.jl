module Intervals

import Base: in, ==, <, <=, >, >=, isempty, show, union, intersect, empty

"""
AbstractInterval{T}

A base class for interval types with limits of type `T`.
"""
abstract type AbstractInterval{T} end

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
    return (left(a) == left(b)) &&
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

isempty(a::AbstractInterval) = false
issingleton(a::AbstractInterval) = false

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

"""
Interval{T}

A type describing the interval between two comparable limits of type `T`.
    
Limits have three requirements:
1. They must be of the same type `T`.
2. They must be less-than comparable (a defined `<` operator).
3. They must be equals comparable (a defined `==` operator).

`Interval` supports open, closed, and semi-open/semi-closed limits.
"""
struct Interval{T} <: AbstractInterval{T}
    left::T
    right::T
    left_closed::Bool
    right_closed::Bool
end

left(a::Interval) = a.left
right(a::Interval) = a.right
closedleft(a::Interval) = a.left_closed
closedright(a::Interval) = a.right_closed

struct EmptyInterval{T} <: AbstractInterval{T}
    eltype::Type{T}
end

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

struct SingletonInterval{T} <: AbstractInterval{T}
    value::T
end

left(a::SingletonInterval) = a.value
right(a::SingletonInterval) = a.value
closedleft(a::SingletonInterval) = true
closedright(a::SingletonInterval) = true

struct LeftUnboundedInterval{T} <: AbstractInterval{T}
    right::T
    right_closed::Bool
end

right(a::LeftUnboundedInterval) = a.right
closedleft(a::LeftUnboundedInterval) = false
closedright(a::LeftUnboundedInterval) = a.right_closed
boundedleft(a::LeftUnboundedInterval) = false
(<)(::LeftUnboundedInterval, ::Any) = true
(<)(::Any, ::LeftUnboundedInterval) = false

struct RightUnboundedInterval{T} <: AbstractInterval{T}
    left::T
    left_closed::Bool
end

left(a::RightUnboundedInterval) = a.left
closedleft(a::RightUnboundedInterval) = a.left_closed
closedright(a::RightUnboundedInterval) = false
boundedright(a::RightUnboundedInterval) = false
(>)(::RightUnboundedInterval, ::Any) = true
(>)(::Any, ::RightUnboundedInterval) = false


"""
interval(left, right, closed=:neither)

Constructor for various `Interval` types.  The type returned depends on the arguments.

Arguments
=========
`left`, `right`: left and right limits of the interval.  Empty values will be considered
    unbounded.  Unbounded limits are ignored and considered `-∞` (left) or `+∞` (right) for the
    type of the limits in the sense that all values of type `T` will compare
    greater than an unbounded left limit and less than an unbounded right limit,
    except infinity itself (if `isfinite` is defined for the type).

`closed`: whether the left, right, both, or neither limit is included in the interval.
    Must be one of `:neither` (default), `:left`, `:right`, or `:both`.
"""
function interval(;left::Union{T, Nothing} = nothing, right::Union{T, Nothing} = nothing, closed::Symbol = :neither) where T
    closed ∈ (:neither, :left, :right, :both) || throw(ArgumentError("'closed' must be one of (:neither, :left, :right, :both)"))
    lu = isnothing(left)
    ru = isnothing(right)
    lc = ((closed == :left) || (closed == :both))
    rc = ((closed == :right) || (closed == :both))
    if (lu && ru) || (right < left) || ((right == left) && !lc && !rc)
        return EmptyInterval(T)
    end
    if !lu && !ru
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

struct DisjointIntervals{T} <: AbstractInterval{T}
    ivs::Vector{AbstractInterval{T}}
end

function simplify(a::AbstractInterval{T}, b::AbstractInterval{T}) where T
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

function disjoint(ivs::AbstractInterval{T}...) where T
    sorted = sort!(collect(ivs), by=x -> ismissing(left(x)) ? typemin(T) : left(x))
    a = popfirst!(sorted)
    out = Vector{AbstractInterval{T}}()
    while !isempty(sorted)
        b = popfirst!(sorted)
        s = simplify(a, b)
        if length(s) == 1
            a = s[1]
            continue
        else
            push!(out, s[1])
            a = s[2]
        end
    end
    push!(out, a)
    DisjointIntervals(out)
end

left(a::DisjointIntervals) = left(first(a.ivs))
right(a::DisjointIntervals) = right(last(a.ivs))
closedleft(a::DisjointIntervals) = closedleft(first(a))
closedright(a::DisjointIntervals) = closedright(last(a))
boundedleft(a::DisjointIntervals) = boundedleft(first(a))
boundedright(a::DisjointIntervals) = boundedright(last(a))

# Union between an empty interval and anything is that other thing.
union(a::AbstractInterval{T}, ::EmptyInterval{T}) where T = a
union(::EmptyInterval{T}, b::AbstractInterval{T}) where T = b

# Everything else
union(a::AbstractInterval{T}, b::AbstractInterval{T}) where T = disjoint(a, b)

# Intersection between an empty and anything is empty.
intersect(::EmptyInterval{T}, ::AbstractInterval{T}) where T = EmptyInterval(T)
intersect(::AbstractArray{T}, ::EmptyInterval{T}) where T = EmptyInterval(T)

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

export interval
export in, ==, isempty, show, union, intersect, left, right, boundedleft, boundedright, closedleft, closedright, unboundedleft, unboundedright, openleft, openright, <, <=, >, >=

end # module
