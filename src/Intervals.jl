module Intervals

import Base: ∈, ==, <, ≤, >, ≥, -, isempty, show, union, intersect, empty

include("types.jl")
include("constructors.jl")
include("accessors.jl")
include("queries.jl")
include("operators.jl")
include("operations.jl")

# constructors
export interval, disjoint
# operators
export ∈, ==, <, ≤, >, ≥, -, difference
# accessors
export left, right, boundedleft, boundedright, closedleft, closedright, unboundedleft, unboundedright, openleft, openright, natomic, closed, bounded
# queries
export isempty, isbounded, issingleton
# operations
# TODO: complement
export show, union, intersect, overlaps, adjacent

end # module
