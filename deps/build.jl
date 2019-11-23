gjk_src_dir = joinpath(@__DIR__, "cameron_gjk_v2.4")
build_dir = joinpath(@__DIR__, "build")
mkpath(build_dir)

include("cameron_gjk_v2.4/parameters/template.h.jl")
include("param_string.jl")
# generate a distinct static library for each parameterization.
# very old-school generics!

function compile_it(param)
    cmd = `gcc
        -shared -fPIC
        -I$(gjk_src_dir)
        -I$(joinpath(gjk_src_dir, "parameters", param))
        -o$(joinpath(build_dir, "gjk_$(param).so"))
        $(joinpath(gjk_src_dir, "gjk_env.c"))
        $(joinpath(gjk_src_dir, "gjk.c"))`
    @show cmd
    run(cmd)
end


for T = [Cdouble, Cfloat]
    for d = 3:3
        param_s = make_param_string(T, d)
        include_path = joinpath(gjk_src_dir, "parameters", param_s)
        mkpath(include_path)
        param_header = joinpath(include_path, "gjk_parameters.h")
        open(param_header, "w") do io
            write(io, gjk_parameters_header(T, d))
        end
        compile_it(param_s)
    end
end
