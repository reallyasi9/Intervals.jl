function show(io::IO, a::AtomicInterval)
    if isempty(a)
        print(io, "()")
    elseif issingleton(a)
        print(io, "[$(left(a))]")
    else
        closedleft(a) ? print(io, '[') : print(io, '(')
        unboundedleft(a) ? print(io, "-∞") : print(io, left(a))
        print(io, ",")
        unboundedright(a) ? print(io, "+∞") : print(io, right(a))
        closedright(a) ? print(io, ']') : print(io, ')')
    end
    return nothing
end

function show(io::IO, a::DisjointInterval)
    join(io, a.ivs, " | ")
end

"""
overlaps(a, b)

Determine if two intervals overlap in domain.
"""
function overlaps(a::AtomicInterval, b::AtomicInterval)
    return ((a ≤ b) && !(a < b)) || ((a ≥ b) && !(a > b))
end

overlaps(a::AtomicInterval, b::DisjointInterval) = all(x -> overlaps(x, a), b.ivs)
overlaps(a::DisjointInterval, b::AtomicInterval)  = overlaps(b, a)

function overlaps(a::DisjointInterval, b::DisjointInterval)
    # Sort the disjoint intervals into each other in a new disjoint interval.
    # If the number of atomic intervals in the new disjoint is less than the sum of the number in the two inputs, there must be an overlap.
    # This runs in O(n*log(n) + m*log(m)), where n and m are the number of atomic intervals in a and b, respectively.
    if isempty(a) || isempty(b)
        return false
    end
    c = disjoint(a.ivs...,b.ivs...)
    natomic(c) < natomic(a) + natomic(b)
end

"""
adjacent(a, b)

Determine if two intervals are immediately adjacent (with no overlap).
"""
function adjacent(a::AbstractInterval, b::AbstractInterval)
    ((right(a) == left(b)) && ((openright(a) && closedleft(b)) || (closedright(a) && openleft(b)))) ||
    ((left(a) == right(b)) && ((openleft(a) && closedright(b)) || (closedleft(a) && openright(b))))
end

adjacent(::EmptyInterval, ::AbstractInterval) = false
adjacent(::AbstractInterval, ::EmptyInterval) = false
adjacent(::UnboundedInterval, ::AbstractInterval) = false
adjacent(::AbstractInterval, ::UnboundedInterval) = false

"""
complement(a)

Returns a `DisjointInterval` that represents the union of intervals that are adjacent to the interval `a` and, with `a`, form an unbounded interval across the entire domain.
"""
function complement(a::AbstractInterval{T}) where T
    difference(UnboundedInterval{T}(), a)
end

complement(::EmptyInterval{T}) where T = disjoint(UnboundedInterval{T}())
complement(::UnboundedInterval{T}) where T = disjoint(EmptyInterval{T}())


"""
union(a, b)

Return the union of intervals `a` and `b`.  Always returns a `DisjointInterval` for type stability, even if the union is an `AtomicInterval`.
"""
union(a::AbstractInterval{T}, b::AbstractInterval{T}) where T = disjoint(a, b)

# Union between an empty interval and anything is that other thing.
union(a::AbstractInterval{T}, ::EmptyInterval{T}) where T = disjoint(a)
union(::EmptyInterval{T}, b::AbstractInterval{T}) where T = disjoint(b)

# Union between an unbounded interval and anything is unbounded
union(::AbstractInterval{T}, b::UnboundedInterval{T}) where T = disjoint(b)
union(a::UnboundedInterval{T}, ::AbstractInterval{T}) where T = disjoint(a)


"""
intersect(a, b)

Return the intersection of intervals `a` and `b`.  Always returns a `DisjointInterval` for type stability.
"""
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

    disjoint(interval(left=left, right=right, closed=_closebound(lc, rc)))
end

# Intersection between an empty and anything is empty.
intersect(::EmptyInterval{T}, ::AbstractInterval{T}) where T = disjoint(EmptyInterval{T}())
intersect(::AbstractArray{T}, ::EmptyInterval{T}) where T = disjoint(EmptyInterval{T}())

# Intersection between unbounded and anything is that thing.
intersect(::UnboundedInterval{T}, b::AbstractInterval{T}) where T = disjoint(b)
intersect(a::AbstractArray{T}, ::UnboundedInterval{T}) where T = disjoint(a)

# Intersection between a singleton and anything is either the singleton or empty.
intersect(a::AbstractInterval{T}, b::SingletonInterval{T}) where T = overlaps(a, b) ? disjoint(b) : disjoint(EmptyInterval{T}())
intersect(a::SingletonInterval{T}, b::AbstractInterval{T}) where T = intersect(b, a)

intersect(a::DisjointInterval{T}, b::AtomicInterval{T}) where T = disjoint(intersect(iv, b) for iv in a.ivs)
intersect(a::AtomicInterval{T}, b::DisjointInterval{T}) where T = intersect(b, a)

function intersect(a::DisjointInterval{T}, b::DisjointInterval{T}) where T
    out = IntervalArray{T}()
    i = 1
    j = 1
    while i <= length(a.ivs) && j <= length(b.ivs)
        if a.ivs[i] < b.ivs[j]
            i += 1
            continue
        elseif a.ivs[i] > b.ivs[j]
            j += 1
            continue
        elseif a.ivs[i] ≤ b.ivs[j]
            push!(out, intersect(a.ivs[i], b.ivs[j]))
            i += 1
            continue
        elseif a.ivs[i] ≥ b.ivs[j]
            push!(out, intersect(a.ivs[i], b.ivs[j]))
            j += 1
            continue
        end
    end
    disjoint(out...)
end
    
