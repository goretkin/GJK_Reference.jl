module GJK_Reference
import Libdl

build_path = joinpath(@__DIR__, "..", "deps", "build")

so_file = "gjk_dim3_double.so"
so_path = normpath(joinpath(build_path, so_file))
if !isfile(so_path)
  package_name = "GJK_Reference"
  error("$(package_name) not properly installed. Please run Pkg.build(\"$(package_name)\")")
end
const gjk_distance_handle = Ref{Ptr{Cvoid}}(0)

function __init__()
  # https://en.wikipedia.org/wiki/Dynamic_loading
  so_handle = Libdl.dlopen(so_path)
  gjk_distance_handle[] = Libdl.dlsym(so_handle, :gjk_distance)
end

const GJK_REAL = Cdouble
const GJK_DIM = 3

"""
// from gjk.h
struct Object_structure {
  int numpoints;
  REAL (* vertices)[DIM];
  int * rings;
};
"""

struct GJK_Object_structure
  numpoints::Cint
  vertices::Ptr{NTuple{GJK_DIM, GJK_REAL}}
  rings::Ptr{Cint}
end

const GJK_Object = Ptr{GJK_Object_structure}
const Tsimplex_point = Any  # TODO support

# TODO support StaticArray and other immutable types
function GJK_Object_structure(points::Vector{PT}) where PT
  @assert eltype(PT) == GJK_REAL
  # until `StaticArrays.Size` is part of Base
  @assert sizeof(PT) == sizeof(GJK_REAL) * GJK_DIM
  GJK_Object_structure(
    length(points),
    pointer(points),
    Ptr{Cint}(0)
  )
end


function gjk_transform_pointer(tr::Union{Nothing, Matrix{GJK_REAL}},)
  return (if tr === nothing
    Ptr{GJK_REAL}(0)
  else
    @assert size(tr) == (GJK_DIM, GJK_DIM+1)
    pointer(tr)
  end)
end


function gjk_distance(points1, transform1, points2, transform2)
  # TODO compile gjk_distance_handle[] pointer into this function
  obj1 = GJK_Object_structure(points1)
  obj2 = GJK_Object_structure(points2)
  tr1 = gjk_transform_pointer(transform1)
  tr2 = gjk_transform_pointer(transform2)

  # TODO use static-size array
  wpt1 = Vector{GJK_REAL}(undef, GJK_DIM)
  wpt2 = Vector{GJK_REAL}(undef, GJK_DIM)

  simplex = Ptr{Tsimplex_point}(0)
  use_seed = 0
  sq_dist =GC.@preserve points1 transform1 points2 transform2 obj1 obj2 begin
      ccall(gjk_distance_handle[], GJK_REAL,
        (GJK_Object, Ptr{GJK_REAL}, GJK_Object, Ptr{GJK_REAL}, Ptr{GJK_REAL}, Ptr{GJK_REAL}, Ptr{Tsimplex_point}, Cint),
        Ref(obj1), tr1, Ref(obj2), tr2, wpt1, wpt2, simplex, use_seed)
  end
  return (sq_dist=sq_dist, wpt1=wpt1, wpt2=wpt2)
end

end # module
