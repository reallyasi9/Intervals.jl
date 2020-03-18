"""
AbstractInterval

A base class for interval types with limits of type `T`.

The type `T` has two simple requirements in order to be a valid limit type:
1. It must be less-than comparable to other instances of type `T` (a defined `<` operator).
2. It must be equals comparable to other instances of type `T` (a defined `==` operator).
Note that the less-than comparable does not specify that the type necessarily solve the triangle inequality.
"""
abstract type AbstractInterval{T} end

"""
EmptyInterval

A type that describes trivial empty intervals.

`EmptyInterval` objects have some special and sometimes confusing properties:
1. They are typed with type `T`.  Even though `EmptyInterval` describes basically the empty set, it still must be a valid interval on a particular domain.
2. `left(empty) === right(empty) === nothing`
3. `closedleft(empty) == closedright(empty) == false` and `boundedleft(empty) == boundedright(empty) == false`
4. `empty ∪ other == other` and `empty ∩ other == empty`
5. `disjoint(empty, other) == other` and `disjoint(empty, empty) == empty`
"""
struct EmptyInterval{T} <: AbstractInterval{T} end

"""
SingletonInterval

A type that describes single-value intervals.

`SingletonInterval` objects are closed on both ends and have equal left and right limits.
"""
struct SingletonInterval{T} <: AbstractInterval{T}
    value::T
end

"""
Interval

A type that describes open, closed, and semi-open/semi-closed limits.
"""
struct Interval{T} <: AbstractInterval{T}
    left::T
    right::T
    left_closed::Bool
    right_closed::Bool
end

"""
LeftUnboundedInterval

A type that describes an interval unbounded from the left (but bounded from the right).
"""
struct LeftUnboundedInterval{T} <: AbstractInterval{T}
    right::T
    right_closed::Bool
end

"""
RightUnboundedInterval

A type that describes an interval unbounded from the right (but bounded from the left).
"""
struct RightUnboundedInterval{T} <: AbstractInterval{T}
    left::T
    left_closed::Bool
end

"""
UnboundedInterval

A type that describes a trivial interval unbounded from both sides.

You cannot directly construct an unbounded interval from the `interval` command.  This special type represents the outcome of certain operations, like `complement(empty)` and `leftunbounded ∪ rightunbounded` with overlapping limits.

Like `EmptyInterval`, `UnboundedInterval` objects have some special and sometimes confusing properties:
1. They are typed with type `T`.  Even though `UnboundedInterval` describes basically an unbounded set, it still must be a valid interval on a particular domain.
2. `left(unbounded) === right(unbounded) === nothing`
3. `closedleft(unbounded) == closedright(unbounded) == false` and `boundedleft(unbounded) == boundedright(unbounded) == false`
4. `unbounded ∪ other == unbounded` and `unbounded ∩ other == other`
5. `disjoint(unbounded, other) == unbounded`
"""
struct UnboundedInterval{T} <: AbstractInterval{T} end
