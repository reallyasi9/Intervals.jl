using Intervals
using Test
using Dates

@testset "Intervals.jl" begin
    @testset "EmptyInterval" begin
        iv = EmptyInterval{Int}()
        @test isnothing(left(iv))
        @test isnothing(right(iv))
        @test openleft(iv)
        @test openright(iv)
        @test unboundedleft(iv)
        @test unboundedright(iv)
        @test isempty(iv)
        @test !issingleton(iv)
        @test !isbounded(iv)
        @test !isdisjoint(iv)

        # All empty intervals are equal, regardless of domain.
        iv2 = EmptyInterval{Float64}()
        @test iv == iv2

        # Nothing is greater than, less than, or in an empty interval
        @test !(0 < iv)
        @test !(0 > iv)
        @test !(0 ≤ iv)
        @test !(0 ≥ iv)

        @test !(iv2 < iv)
        @test !(iv2 > iv)
        @test !(iv2 ≤ iv)
        @test !(iv2 ≥ iv)
        @test !(iv2 ∈ iv)

        # self-comparisons are not logical
        @test !(iv < iv)
        @test !(iv > iv)
        @test !(iv ≤ iv)
        @test !(iv ≥ iv)
        @test !(iv ∈ iv)
        @test (iv == iv)
    end

    @testset "SingletonInterval" begin
        dt = Date(1970, 1, 1)
        iv = SingletonInterval(dt)
        @test left(iv) == dt
        @test right(iv) == dt
        @test closedleft(iv)
        @test closedright(iv)
        @test boundedleft(iv)
        @test boundedright(iv)
        @test !isempty(iv)
        @test issingleton(iv)
        @test isbounded(iv)
        @test !isdisjoint(iv)

        # Only the value itself is in a singleton interval
        @test !(dt < iv)
        @test !(dt > iv)
        @test (dt ≤ iv)
        @test (dt ≥ iv)
        @test (dt ∈ iv)

        dt2 = DateTime(dt) + Second(1)
        @test !(dt2 < iv)
        @test (dt2 > iv)
        @test !(dt2 ≤ iv)
        @test (dt2 ≥ iv)
        @test !(dt2 ∈ iv)

        iv2 = SingletonInterval(dt2)
        @test !(iv2 < iv)
        @test (iv2 > iv)
        @test !(iv2 ≤ iv)
        @test (iv2 ≥ iv)
        @test !(iv2 ∈ iv)

        # Self-comparisons are logical
        @test !(iv < iv)
        @test !(iv > iv)
        @test (iv ≤ iv)
        @test (iv ≥ iv)
        @test (iv == iv)
        @test (iv ∈ iv)
    end

    @testset "LeftUnboundedInterval" begin
        x = π
        iv = LeftUnboundedInterval(x, false)
        @test isnothing(left(iv))
        @test right(iv) == x
        @test openleft(iv)
        @test openright(iv)
        @test unboundedleft(iv)
        @test boundedright(iv)
        @test !isempty(iv)
        @test !issingleton(iv)
        @test !isbounded(iv)
        @test !isdisjoint(iv)

        # Nothing is less than the interval
        @test !(x < iv)
        @test (x > iv)
        @test !(x ≤ iv)
        @test (x ≥ iv)
        @test !(x ∈ iv)

        # The limit is only in the interval if the limit is closed
        iv2 = LeftUnboundedInterval(x, true)
        @test !(x < iv2)
        @test !(x > iv2)
        @test (x ≤ iv2)
        @test (x ≥ iv2)
        @test (x ∈ iv2)

        @test !(iv2 < iv)
        @test !(iv2 > iv)
        @test !(iv2 ≤ iv)
        @test (iv2 ≥ iv)
        @test !(iv2 ∈ iv)
        @test (iv ∈ iv2)

        # Self-comparisons are logical
        @test !(iv < iv)
        @test !(iv > iv)
        @test (iv ≤ iv)
        @test (iv ≥ iv)
        @test (iv == iv)
        @test (iv ∈ iv)
    end

    @testset "RightUnboundedInterval" begin
        x = ℯ
        iv = RightUnboundedInterval(x, false)
        @test left(iv) == x
        @test isnothing(right(iv))
        @test openleft(iv)
        @test openright(iv)
        @test boundedleft(iv)
        @test unboundedright(iv)
        @test !isempty(iv)
        @test !issingleton(iv)
        @test !isbounded(iv)
        @test !isdisjoint(iv)

        # Nothing is greater than the interval
        @test (x < iv)
        @test !(x > iv)
        @test (x ≤ iv)
        @test !(x ≥ iv)
        @test !(x ∈ iv)

        # The limit is only in the interval if the limit is closed
        iv2 = RightUnboundedInterval(x, true)
        @test !(x < iv2)
        @test !(x > iv2)
        @test (x ≤ iv2)
        @test (x ≥ iv2)
        @test (x ∈ iv2)

        @test !(iv2 < iv)
        @test !(iv2 > iv)
        @test (iv2 ≤ iv)
        @test !(iv2 ≥ iv)
        @test !(iv2 ∈ iv)
        @test (iv ∈ iv2)

        # Self-comparisons are logical
        @test !(iv < iv)
        @test !(iv > iv)
        @test (iv ≤ iv)
        @test (iv ≥ iv)
        @test (iv == iv)
        @test (iv ∈ iv)
    end

    @testset "UnboundedInterval" begin
        iv = UnboundedInterval{Rational{Int128}}()
        @test isnothing(left(iv))
        @test isnothing(right(iv))
        @test openleft(iv)
        @test openright(iv)
        @test unboundedleft(iv)
        @test unboundedright(iv)
        @test !isempty(iv)
        @test !issingleton(iv)
        @test !isbounded(iv)
        @test !isdisjoint(iv)

        # Nothing is greater than, less than, or outside the interval
        x = 12345//6789
        @test !(x < iv)
        @test !(x > iv)
        @test (x ≤ iv)
        @test (x ≥ iv)
        @test (x ∈ iv)

        # Self-comparisons are logical
        @test !(iv < iv)
        @test !(iv > iv)
        @test (iv ≤ iv)
        @test (iv ≥ iv)
        @test (iv == iv)
        @test (iv ∈ iv)
    end

    @testset "Interval" begin
        # [-1, 1)
        iv = Interval(-1, 1, true, false)
        @test left(iv) == -1
        @test right(iv) == 1
        @test closedleft(iv)
        @test openright(iv)
        @test boundedleft(iv)
        @test boundedright(iv)
        @test !isempty(iv)
        @test !issingleton(iv)
        @test isbounded(iv)
        @test !isdisjoint(iv)

        # test limits
        @test !(-1 < iv)
        @test !(-1 > iv)
        @test !(1 < iv)
        @test (1 > iv)
        @test (-1 ≤ iv)
        @test (-1 ≥ iv)
        @test !(1 ≤ iv)
        @test (1 ≥ iv)
        @test (-1 ∈ iv)
        @test !(1 ∈ iv)

        # test strictly <
        # [-3, -1)
        ivlt = Interval(-3, -1, true, false)
        @test (ivlt < iv)
        @test (ivlt ≤ iv)
        @test !(ivlt == iv)
        @test !(ivlt ≥ iv)
        @test !(ivlt > iv)
        @test !(ivlt ∈ iv)
        @test !(iv ∈ ivlt)

        # test <=
        # [-3, 1)
        ivle = Interval(-3, 1, true, false)
        @test !(ivle < iv)
        @test (ivle ≤ iv)
        @test !(ivle == iv)
        @test !(ivle ≥ iv)
        @test !(ivle > iv)
        @test !(ivle ∈ iv)
        @test (iv ∈ ivle)

        # test ==
        # [-1, 1)
        iveq = Interval(-1, 1, true, false)
        @test !(iveq < iv)
        @test (iveq ≤ iv)
        @test (iveq == iv)
        @test (iveq ≥ iv)
        @test !(iveq > iv)
        @test (iveq ∈ iv)
        @test (iv ∈ iveq)

        # test >=
        # [-1, 1]
        ivge = Interval(-1, 1, true, true)
        @test !(ivge < iv)
        @test !(ivge ≤ iv)
        @test !(ivge == iv)
        @test (ivge ≥ iv)
        @test !(ivge > iv)
        @test !(ivge ∈ iv)
        @test (iv ∈ ivge)

        # test strictly >
        # [1, 2)
        ivgt = Interval(1, 2, true, false)
        @test !(ivgt < iv)
        @test !(ivgt ≤ iv)
        @test !(ivgt == iv)
        @test (ivgt ≥ iv)
        @test (ivgt > iv)
        @test !(ivgt ∈ iv)
        @test !(iv ∈ ivgt)

        # test strict subset
        # (-1, 0)
        ivsub = Interval(-1, 0, false, false)
        @test !(ivsub < iv)
        @test (ivsub ≤ iv)
        @test !(ivsub == iv)
        @test (ivsub ≥ iv)
        @test !(ivsub > iv)
        @test (ivsub ∈ iv)
        @test !(iv ∈ ivsub)

        # test strict superset
        # [-2, 1]
        ivsup = Interval(-2, 1, true, true)
        @test !(ivsup < iv)
        @test !(ivsup ≤ iv)
        @test !(ivsup == iv)
        @test !(ivsup ≥ iv)
        @test !(ivsup > iv)
        @test !(ivsup ∈ iv)
        @test (iv ∈ ivsup)

        # Self-comparisons are logical
        @test !(iv < iv)
        @test !(iv > iv)
        @test (iv ≤ iv)
        @test (iv ≥ iv)
        @test (iv == iv)
        @test (iv ∈ iv)
    end

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
        @test natomic(di) == 1
        @test !isdisjoint(di)  # only one interval, so not disjoint!

        # single empty interval
        iv = interval(left=0, right=0)
        di = disjoint(iv)
        @test di == iv
        @test natomic(di) == 1
        @test !isdisjoint(di)
        @test isempty(di)

        # single singleton interval
        iv = interval(left=0, right=0, closed=:both)
        di = disjoint(iv)
        @test di == iv
        @test natomic(di) == 1
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

        # two overlapping unbounded intervals
        iv1 = interval(right=0, closed=:right)
        iv2 = interval(left=0, closed=:left)
        di = disjoint(iv1, iv2)
        @test natomic(di) == 1
        @test !isbounded(di)
        @test unboundedleft(di)
        @test unboundedright(di)

        # two adjacent unbounded intervals
        iv1 = interval(right=0, closed=:right)
        iv2 = interval(left=0)
        di = disjoint(iv1, iv2)
        @test natomic(di) == 1
        @test !isbounded(di)
        @test unboundedleft(di)
        @test unboundedright(di)

        # two non-overlapping, non-adjacent unbounded intervals
        iv1 = interval(right=0)
        iv2 = interval(left=0)
        di = disjoint(iv1, iv2)
        @test natomic(di) == 2
        @test !isbounded(di)
        @test unboundedleft(di)
        @test unboundedright(di)
        @test 0 ∉ di

        # many intervals
        iv1 = interval(right=-1)
        iv2 = interval(left=-2, right=0)
        iv3 = interval(left=0, right=1, closed=:right)
        iv4 = interval(left=2, right=2, closed=:both)
        iv5 = interval(left=2, right=2, closed=:neither)
        di = disjoint(iv1, iv2, iv3, iv4, iv5)
        @test natomic(di) == 3
        @test !isbounded(di)
        @test unboundedleft(di)
        @test right(di) == 2
        @test closedright(di)

        # single disjoint interval
        iv1 = interval(left=0, right=1)
        iv2 = interval(left=1, right=2)
        di1 = disjoint(iv1, iv2)
        di2 = disjoint(di1)
        @test di2 == di1

        # many disjoint intervals
        iv1 = interval(left=0, right=1)
        iv2 = interval(left=1, right=2)
        iv3 = interval(left=3, right=3, closed=:both)
        iv4 = interval(left=4, right=4, closed=:both)
        iv5 = interval(left=5)
        di1 = disjoint(iv1, iv2)
        di2 = disjoint(iv3)
        di3 = disjoint(di1, iv4)
        di4 = disjoint(di2, di3, iv5)
        @test isdisjoint(di4)
        @test natomic(di4) == 5
        @test unboundedright(di4)
        @test boundedleft(di4)
        @test left(di4) == 0
    end;
end;
