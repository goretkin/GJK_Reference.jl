using GJK_Reference
using Test

using LinearAlgebra: dot, norm
normsq(x) = dot(x, x)

# https://discourse.julialang.org/t/print-debug-info-for-failed-test/22311/2
onfail(body, _::Test.Pass) = nothing
onfail(body, _::Tuple{Test.Fail,T}) where {T} = body()

@testset "one-point hulls" begin
    for i = 1:100
        p1 = tuple(rand(GJK_Reference.GJK_REAL, GJK_Reference.GJK_DIM)...)
        p2 = tuple(rand(GJK_Reference.GJK_REAL, GJK_Reference.GJK_DIM)...)
        r = GJK_Reference.gjk_distance([p1], nothing, [p2], nothing)
        doprint = false

        onfail(@test isapprox(r.sq_dist, normsq(p1 .- p2); atol=eps(GJK_Reference.GJK_REAL))) do; doprint=true; end
        onfail(@test norm(r.wpt1 .- p1) < eps(GJK_Reference.GJK_REAL)) do; doprint=true; end
        onfail(@test norm(r.wpt2 .- p2) < eps(GJK_Reference.GJK_REAL)) do; doprint=true; end
        if doprint
            @show p1
            @show p2
            @show r
        end
    end
end
