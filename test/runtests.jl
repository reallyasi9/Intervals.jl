using Intervals
using Test

@testset "Intervals.jl" begin
    @testset "interval constructor" begin
        let iv = interval(left=0, right=1)
            @test left(iv) == 0
            @test right(iv) == 1
            @test openleft(iv)
            @test openright(iv)
            @test boundedleft(iv)
            @test boundedright(iv)
            @test typeof(iv) == Intervals.Interval{Int}
        end

        let iv = interval(left=0, right=1, closed=:neither)
            @test left(iv) == 0
            @test right(iv) == 1
            @test openleft(iv)
            @test openright(iv)
            @test boundedleft(iv)
            @test boundedright(iv)
            @test typeof(iv) == Intervals.Interval{Int}
        end

        let iv = interval(left=0, right=1, closed=:left)
            @test left(iv) == 0
            @test right(iv) == 1
            @test closedleft(iv)
            @test openright(iv)
            @test boundedleft(iv)
            @test boundedright(iv)
            @test typeof(iv) == Intervals.Interval{Int}
        end

        let iv = interval(left=0, right=1, closed=:right)
            @test left(iv) == 0
            @test right(iv) == 1
            @test openleft(iv)
            @test closedright(iv)
            @test boundedleft(iv)
            @test boundedright(iv)
            @test typeof(iv) == Intervals.Interval{Int}
        end

        let iv = interval(left=0, right=1, closed=:both)
            @test left(iv) == 0
            @test right(iv) == 1
            @test closedleft(iv)
            @test closedright(iv)
            @test boundedleft(iv)
            @test boundedright(iv)
            @test typeof(iv) == Intervals.Interval{Int}
        end

        @test_throws ArgumentError interval(left=0, right=1, closed=:bananas)

        let iv = interval(right=0)
            @test isnothing(left(iv))
            @test right(iv) == 0
            @test openleft(iv)
            @test openright(iv)
            @test unboundedleft(iv)
            @test boundedright(iv)
            @test typeof(iv) == Intervals.LeftUnboundedInterval{Int}
        end

        let iv = interval(right=0, closed=:right)
            @test isnothing(left(iv))
            @test right(iv) == 0
            @test openleft(iv)
            @test closedright(iv)
            @test unboundedleft(iv)
            @test boundedright(iv)
            @test typeof(iv) == Intervals.LeftUnboundedInterval{Int}
        end

        let iv = interval(right=0, closed=:both)
            @test isnothing(left(iv))
            @test right(iv) == 0
            @test openleft(iv)
            @test closedright(iv)
            @test unboundedleft(iv)
            @test boundedright(iv)
            @test typeof(iv) == Intervals.LeftUnboundedInterval{Int}
        end

        let iv = interval(left=0)
            @test isnothing(right(iv))
            @test left(iv) == 0
            @test openleft(iv)
            @test openright(iv)
            @test boundedleft(iv)
            @test unboundedright(iv)
            @test typeof(iv) == Intervals.RightUnboundedInterval{Int}
        end

        let iv = interval(left=0, closed=:left)
            @test isnothing(right(iv))
            @test left(iv) == 0
            @test closedleft(iv)
            @test openright(iv)
            @test boundedleft(iv)
            @test unboundedright(iv)
            @test typeof(iv) == Intervals.RightUnboundedInterval{Int}
        end
        
        let iv = interval(left=0, closed=:both)
            @test isnothing(right(iv))
            @test left(iv) == 0
            @test closedleft(iv)
            @test openright(iv)
            @test boundedleft(iv)
            @test unboundedright(iv)
            @test typeof(iv) == Intervals.RightUnboundedInterval{Int}
        end

        let iv = interval(left=0, right=0)
            @test isnothing(left(iv))
            @test isnothing(right(iv))
            @test openleft(iv)
            @test openright(iv)
            @test unboundedleft(iv)
            @test unboundedright(iv)
            @test typeof(iv) == Intervals.EmptyInterval{Int}
        end

        let iv = interval(left=0, right=0, closed=:both)
            @test left(iv) == 0
            @test right(iv) == 0
            @test closedleft(iv)
            @test closedright(iv)
            @test boundedleft(iv)
            @test boundedright(iv)
            @test typeof(iv) == Intervals.SingletonInterval{Int}
        end
    end
end
