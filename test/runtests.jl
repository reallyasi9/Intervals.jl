using Intervals
using Test

@testset "Intervals.jl" begin
    @testset "interval constructor" begin
        let iv = interval(left=0, right=1)
            @test left(iv) == 0
            @test right(iv) == 1
            @test openleft(iv)
            @test openright(iv)
        end

        let iv = interval(left=0, right=1, closed=:neither)
            @test left(iv) == 0
            @test right(iv) == 1
            @test openleft(iv)
            @test openright(iv)
        end

        let iv = interval(left=0, right=1, closed=:left)
            @test left(iv) == 0
            @test right(iv) == 1
            @test closedleft(iv)
            @test openright(iv)
        end

        let iv = interval(left=0, right=1, closed=:right)
            @test left(iv) == 0
            @test right(iv) == 1
            @test openleft(iv)
            @test closedright(iv)
        end

        let iv = interval(left=0, right=1, closed=:both)
            @test left(iv) == 0
            @test right(iv) == 1
            @test closedleft(iv)
            @test closedright(iv)
        end

        @test_throws ArgumentError interval(left=0, right=1, closed=:bananas)
    end
end