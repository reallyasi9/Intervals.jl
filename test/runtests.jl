using Intervals
using Test

@testset "Intervals.jl" begin
    @testset "interval" begin
        # standard interval, open both sides
        iv = interval(left=0, right=1)
        @test left(iv) == 0
        @test right(iv) == 1
        @test openleft(iv)
        @test openright(iv)
        @test boundedleft(iv)
        @test boundedright(iv)

        # same
        iv = interval(left=0, right=1, closed=:neither)
        @test left(iv) == 0
        @test right(iv) == 1
        @test openleft(iv)
        @test openright(iv)
        @test boundedleft(iv)
        @test boundedright(iv)

        # closed left
        iv = interval(left=0, right=1, closed=:left)
        @test left(iv) == 0
        @test right(iv) == 1
        @test closedleft(iv)
        @test openright(iv)
        @test boundedleft(iv)
        @test boundedright(iv)

        # closed right
        iv = interval(left=0, right=1, closed=:right)
        @test left(iv) == 0
        @test right(iv) == 1
        @test openleft(iv)
        @test closedright(iv)
        @test boundedleft(iv)
        @test boundedright(iv)

        # closed both
        iv = interval(left=0, right=1, closed=:both)
        @test left(iv) == 0
        @test right(iv) == 1
        @test closedleft(iv)
        @test closedright(iv)
        @test boundedleft(iv)
        @test boundedright(iv)

        # bad closed argument
        @test_throws ArgumentError interval(left=0, right=1, closed=:bananas)

        # unbounded left, open right
        iv = interval(right=0)
        @test isnothing(left(iv))
        @test right(iv) == 0
        @test openleft(iv)
        @test openright(iv)
        @test unboundedleft(iv)
        @test boundedright(iv)

        # unbounded left, closed right
        iv = interval(right=0, closed=:right)
        @test isnothing(left(iv))
        @test right(iv) == 0
        @test openleft(iv)
        @test closedright(iv)
        @test unboundedleft(iv)
        @test boundedright(iv)

        # same (closed left ignored)
        iv = interval(right=0, closed=:both)
        @test isnothing(left(iv))
        @test right(iv) == 0
        @test openleft(iv)
        @test closedright(iv)
        @test unboundedleft(iv)
        @test boundedright(iv)

        # unbounded right, open left
        iv = interval(left=0)
        @test isnothing(right(iv))
        @test left(iv) == 0
        @test openleft(iv)
        @test openright(iv)
        @test boundedleft(iv)
        @test unboundedright(iv)

        # unbounded right, closed left
        iv = interval(left=0, closed=:left)
        @test isnothing(right(iv))
        @test left(iv) == 0
        @test closedleft(iv)
        @test openright(iv)
        @test boundedleft(iv)
        @test unboundedright(iv)
        
        # same (closed right ignored)
        iv = interval(left=0, closed=:both)
        @test isnothing(right(iv))
        @test left(iv) == 0
        @test closedleft(iv)
        @test openright(iv)
        @test boundedleft(iv)
        @test unboundedright(iv)

        # empty (same left and right, both limits open)
        iv = interval(left=0, right=0)
        @test isnothing(left(iv))
        @test isnothing(right(iv))
        @test openleft(iv)
        @test openright(iv)
        @test unboundedleft(iv)
        @test unboundedright(iv)
        @test isempty(iv)

        # singleton (same left and right, at least one open bound)
        iv = interval(left=0, right=0, closed=:left)
        @test left(iv) == 0
        @test right(iv) == 0
        @test closedleft(iv)
        @test closedright(iv)
        @test boundedleft(iv)
        @test boundedright(iv)
        @test issingleton(iv)

        # singleton (same left and right, at least one open bound)
        iv = interval(left=0, right=0, closed=:right)
        @test left(iv) == 0
        @test right(iv) == 0
        @test closedleft(iv)
        @test closedright(iv)
        @test boundedleft(iv)
        @test boundedright(iv)
        @test issingleton(iv)

        # singleton (same left and right, closed interval)
        iv = interval(left=0, right=0, closed=:both)
        @test left(iv) == 0
        @test right(iv) == 0
        @test closedleft(iv)
        @test closedright(iv)
        @test boundedleft(iv)
        @test boundedright(iv)
        @test issingleton(iv)
    end;

    @testset "disjoint" begin
        # single interval
        iv = interval(left=0, right=1)
        di = disjoint(iv)
        @test di == iv
        @test !isdisjoint(di)  # only one interval, so not disjoint!

        # single empty interval
        iv = interval(left=0, right=0)
        di = disjoint(iv)
        @test di == iv
        @test !isdisjoint(di)
        @test isempty(di)

        # single singleton interval
        iv = interval(left=0, right=0, closed=:both)
        di = disjoint(iv)
        @test di == iv
        @test !isdisjoint(di)
        @test issingleton(di)

        # single left-unbounded interval
        iv = interval(right=0)
        di = disjoint(iv)
        @test di == iv
        @test !isdisjoint(di)
        @test !isbounded(di)
        @test unboundedleft(di)

        # single right-unbounded interval
        iv = interval(left=0)
        di = disjoint(iv)
        @test di == iv
        @test !isdisjoint(di)
        @test !isbounded(di)
        @test unboundedright(di)

        # two adjacent intervals
        iv1 = interval(left=-1, right=0, closed=:neither)
        iv2 = interval(left=0, right=1, closed=:left)
        di = disjoint(iv1, iv2)
        @test natomic(di) == 1
        @test left(di) == -1
        @test right(di) == 1
        @test openleft(di)
        @test openright(di)

        # two non-adjacent intervals
        iv1 = interval(left=-1, right=0, closed=:neither)
        iv2 = interval(left=0, right=1, closed=:neither)
        di = disjoint(iv1, iv2)
        @test natomic(di) == 2
        @test left(di) == -1
        @test right(di) == 1
        @test openleft(di)
        @test openright(di)

        # interval and empty interval
        iv1 = interval(left=1, right=2, closed=:neither)
        iv2 = interval(left=0, right=0, closed=:neither)
        di = disjoint(iv1, iv2)
        @test natomic(di) == 1
        @test left(di) == 1
        @test right(di) == 2
        @test openleft(di)
        @test openright(di)

        # two intervals spanning the space
        iv1 = interval(right=0, closed=:right)
        iv2 = interval(left=0)
        di = disjoint(iv1, iv2)
        @test natomic(di) == 1
        @test !isbounded(di)
        @test unboundedleft(di)
        @test unboundedright(di)

    end;
end;
