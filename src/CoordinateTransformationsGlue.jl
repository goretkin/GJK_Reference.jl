module CoordinateTransformationsGlue

import CoordinateTransformations
import StaticArrays
using CoordinateTransformations: IdentityTransformation, AffineMap, LinearMap, Translation, transform_deriv
using StaticArrays: SVector
using LinearAlgebra: I

# For the sake of explanation, assume the C code was compiled with DIM=3.
# the C code expects the transforms to be a 12-element chunk of memory.
# The identity transform is `[1,0,0,0, 0,1,0,0, 0,0,1,0]`
# an (x,y,z) translation is `[1,0,0,x, 0,1,0,y, 0,0,1,z]`
# because Arrays in Julia are column-major, you can think of it as a Julia transformation matrix that multiplies on the right
# If you're used to a 4-by-4 matrix multipliying on the left:
# | R t |
# | 0 1 |

# then construct the Julia matrix
# | R' |
# | t' |

# and it will have the correct memory layout

_zero_vec(dim) = SVector(ntuple(i->0, dim)...)

function allocate_gjk_tr(gjk_dim, gjk_real)
    Matrix{gjk_real}(undef, gjk_dim + 1, gjk_dim)
end

function gjk_tr!(tr, gjk_dim, ::IdentityTransformation)
    tr .= Matrix(I, gjk_dim + 1, gjk_dim)
    tr
end

function gjk_tr!(tr, gjk_dim, m::AffineMap)
    tr[1:3, 1:3] .= transform_deriv(m, _zero_vec(gjk_dim))'
    tr[4, 1:3] .= m(_zero_vec(gjk_dim))
    tr
end

gjk_tr!(tr, gjk_dim, m::LinearMap) = gjk_tr!(tr, gjk_dim, m ∘ Translation(_zero_vec(gjk_dim)...))

gjk_tr!(tr, gjk_dim, t::Translation) = gjk_tr!(tr, gjk_dim, AffineMap(Matrix(I, gjk_dim, gjk_dim), t(_zero_vec(gjk_dim))))
end
