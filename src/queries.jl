isempty(::AbstractInterval) = false
issingleton(::AbstractInterval) = false
isbounded(::AbstractInterval) = true
isdisjoint(::AbstractInterval) = false

isempty(::EmptyInterval) = true
isbounded(::EmptyInterval) = false

issingleton(::SingletonInterval) = true

isbounded(::LeftUnboundedInterval) = false

isbounded(::RightUnboundedInterval) = false

isbounded(::UnboundedInterval) = false

issingleton(a::DisjointInterval) = length(a.ivs) == 1 && issingleton(first(a.ivs))
isempty(a::DisjointInterval) = length(a.ivs) == 1 && isempty(first(a.ivs))
isbounded(a::DisjointInterval) = isbounded(first(a.ivs)) && isbounded(last(a.ivs))
isdisjoint(a::DisjointInterval) = length(a.ivs) > 1