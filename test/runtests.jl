using GJK_Reference
using Test

using LinearAlgebra: dot, norm, I
normsq(x) = dot(x, x)

# https://discourse.julialang.org/t/print-debug-info-for-failed-test/22311/2
onfail(body, _::Test.Pass) = nothing
onfail(body, _::Tuple{Test.Fail,T}) where {T} = body()

#TODO test transforms!
@testset "one-point hulls" begin
    for GJK_REAL = [Cdouble, Cfloat], GJK_DIM = 3:3, tr = [nothing, Matrix{GJK_REAL}(I, GJK_DIM+1, GJK_DIM)], i = 1:100
        p1 = tuple(rand(GJK_REAL, GJK_DIM)...)
        p2 = tuple(rand(GJK_REAL, GJK_DIM)...)
        r = GJK_Reference.gjk_distance([p1], tr, [p2], tr)
        doprint = false

        onfail(@test isapprox(r.sq_dist, normsq(p1 .- p2); atol=eps(GJK_REAL))) do; doprint=true; end
        onfail(@test norm(r.wpt1 .- p1) < eps(GJK_REAL)) do; doprint=true; end
        onfail(@test norm(r.wpt2 .- p2) < eps(GJK_REAL)) do; doprint=true; end
        if doprint
            @show p1
            @show p2
            @show r
        end
    end
end
