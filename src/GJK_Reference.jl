module GJK_Reference
import Libdl

include("../deps/param_string.jl")
build_path = joinpath(@__DIR__, "..", "deps", "build")


struct GJK_Object_structure{GJK_DIM, GJK_REAL}
  numpoints::Cint
  vertices::Ptr{NTuple{GJK_DIM, GJK_REAL}}
  rings::Ptr{Cint}
end

const GJK_Object{D, T} = Ptr{GJK_Object_structure{D,T}}
const Tsimplex_point = Any  # TODO support

"""
`ccall` requires arguments to be determined statically (at Julia codegen time).
TODO: if possible, use `@generated` to load (and possibly compile) the right function call.
For now, eagerly make all the instantiations.
"""
function _generate_wrappers()
  # https://en.wikipedia.org/wiki/Dynamic_loading
  for d = 3:3, t = [Cfloat, Cdouble]
    param_s = make_param_string(t, d)
    so_file = "gjk_$(param_s).so"
    so_path = normpath(joinpath(build_path, so_file))

    if !isfile(so_path)
      package_name = "GJK_Reference"
      error("$(package_name) not properly installed. Missing $(so_path). Please run Pkg.build(\"$(package_name)\")")
    end

    so_handle = Libdl.dlopen(so_path)
    gjk_distance_handle = Libdl.dlsym(so_handle, :gjk_distance)
    T_Object = Ptr{GJK_Object_structure{d, t}}
    fdef = (quote
      function _gjk_distance(::Type{$t}, ::Val{$d},
        obj1, tr1, obj2, tr2, wpt1, wpt2, simplex, use_seed)
          ccall($gjk_distance_handle, $t, ($T_Object, Ptr{Cvoid}, $T_Object, Ptr{Cvoid}, Ptr{$t}, Ptr{$t}, Ptr{Tsimplex_point}, Cint),
          obj1, tr1, obj2, tr2, wpt1, wpt2, simplex, use_seed)
      end
    end)
    eval(fdef)
  end
end

function __init__()
  _generate_wrappers()
end


"""
// from gjk.h
struct Object_structure {
  int numpoints;
  REAL (* vertices)[DIM];
  int * rings;
};
"""


# TODO support StaticArray and other immutable types
function GJK_Object_structure(points::Vector{PT}) where PT
  GJK_REAL = eltype(PT)
  # until `StaticArrays.Size` is part of Base
  GJK_DIM = sizeof(PT) ÷ sizeof(GJK_REAL)
  @assert sizeof(PT) == sizeof(GJK_REAL) * GJK_DIM
  GJK_Object_structure{GJK_DIM, GJK_REAL}(
    length(points),
    pointer(points),
    Ptr{Cint}(0)
  )
end

get_dim(::GJK_Object_structure{GJK_DIM, GJK_REAL}) where {GJK_DIM, GJK_REAL} = GJK_DIM
get_real(::GJK_Object_structure{GJK_DIM, GJK_REAL}) where {GJK_DIM, GJK_REAL} = GJK_REAL

# TODO check size of matrix to set GJK_DIM?
function gjk_transform_pointer(GJK_DIM, GJK_REAL, tr::Union{Nothing, Matrix{GJK_REAL2}}) where {GJK_REAL2}
  return (if tr === nothing
    Ptr{GJK_REAL}(0)
  else
    @assert GJK_REAL == GJK_REAL2
    @assert size(tr) == (GJK_DIM, GJK_DIM+1)
    pointer(tr)
  end)
end


function gjk_distance(points1, transform1, points2, transform2)
  GJK_DIM = 3
  obj1 = GJK_Object_structure(points1)
  obj2 = GJK_Object_structure(points2)
  @assert get_dim(obj1) == get_dim(obj2) == GJK_DIM
  @assert get_real(obj1) == get_real(obj2)
  GJK_REAL = get_real(obj1)

  tr1 = gjk_transform_pointer(GJK_DIM, GJK_REAL, transform1)
  tr2 = gjk_transform_pointer(GJK_DIM, GJK_REAL, transform2)

  # TODO use static-size array
  wpt1 = Vector{GJK_REAL}(undef, GJK_DIM)
  wpt2 = Vector{GJK_REAL}(undef, GJK_DIM)

  simplex = Ptr{Tsimplex_point}(0)
  use_seed = 0
  sq_dist =GC.@preserve points1 transform1 points2 transform2 obj1 obj2 begin
    _gjk_distance(GJK_REAL, Val(GJK_DIM),
        Ref(obj1), tr1, Ref(obj2), tr2, wpt1, wpt2, simplex, use_seed)
  end
  return (sq_dist=sq_dist, wpt1=wpt1, wpt2=wpt2)
end

end # module
