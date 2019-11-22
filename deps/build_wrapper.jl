using Clang
jl_wrap_dir = joinpath(@__DIR__, "wrap")
mkpath(jl_wrap_dir)


# LIBCLANG_HEADERS are those headers to be wrapped.
const LIBCLANG_INCLUDE = gjk_src_dir |> normpath
const LIBCLANG_HEADERS = [joinpath(LIBCLANG_INCLUDE, header) for header in readdir(LIBCLANG_INCLUDE) if endswith(header, ".h")]

wc = init(; headers = LIBCLANG_HEADERS,
            output_file = joinpath(jl_wrap_dir, "libclang_api.jl"),
            common_file = joinpath(jl_wrap_dir, "libclang_common.jl"),
            clang_includes = vcat(LIBCLANG_INCLUDE, CLANG_INCLUDE),
            clang_args = ["-I", joinpath(LIBCLANG_INCLUDE, "..")],
            header_wrapped = (root, current)->root == current,
            header_library = x->"libclang",
            clang_diagnostics = true,
            )

run(wc)
