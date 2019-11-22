gjk_src_dir = joinpath(@__DIR__, "cameron_gjk_v2.4")
build_dir = joinpath(@__DIR__, "build")
mkpath(build_dir)

run(`gcc
    -shared -fPIC
    -I$(gjk_src_dir)
    -o$(joinpath(build_dir, "gjk_dim3_double.so"))
    $(joinpath(gjk_src_dir, "gjk_env.c"))
    $(joinpath(gjk_src_dir, "gjk.c"))`)
