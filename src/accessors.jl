function left(::AbstractInterval) end
left(a::Interval) = a.left
left(a::SingletonInterval) = a.value
left(a::RightUnboundedInterval) = a.left
left(a::DisjointInterval) = left(first(a.ivs))

function right(::AbstractInterval) end
right(a::Interval) = a.right
right(a::SingletonInterval) = a.value
right(a::LeftUnboundedInterval) = a.right
right(a::DisjointInterval) = right(last(a.ivs))


function closedleft(::AbstractInterval) end
closedleft(a::Interval) = a.left_closed
closedleft(::EmptyInterval) = false
closedleft(a::SingletonInterval) = true
closedleft(a::LeftUnboundedInterval) = false
closedleft(a::RightUnboundedInterval) = a.left_closed
closedleft(::UnboundedInterval) = false
closedleft(a::DisjointInterval) = closedleft(first(a.ivs))


function closedright(::AbstractInterval) end
closedright(a::Interval) = a.right_closed
closedright(::EmptyInterval) = false
closedright(a::SingletonInterval) = true
closedright(a::LeftUnboundedInterval) = a.right_closed
closedright(a::RightUnboundedInterval) = false
closedright(::UnboundedInterval) = false
closedright(a::DisjointInterval) = closedright(last(a.ivs))


function boundedleft(::AbstractInterval) true end
boundedleft(::EmptyInterval) = false
boundedleft(a::LeftUnboundedInterval) = false
boundedleft(::UnboundedInterval) = false
boundedleft(a::DisjointInterval) = boundedleft(first(a.ivs))


function boundedright(::AbstractInterval) true end
boundedright(::EmptyInterval) = false
boundedright(a::RightUnboundedInterval) = false
boundedright(::UnboundedInterval) = false
boundedright(a::DisjointInterval) = boundedright(last(a.ivs))



openleft(a) = !closedleft(a)
openright(a) = !closedright(a)
unboundedleft(a) = !boundedleft(a)
unboundedright(a) = !boundedright(a)

natomic(::AtomicInterval) = 1
natomic(a::DisjointInterval) = length(a.ivs)