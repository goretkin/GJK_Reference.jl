function gjk_parameters_header(REAL, DIM)
    sREAL = (if REAL === Cdouble
        "double"
    elseif REAL === Cfloat
        "float"
    else
        error()
    end)

    # guessing at what these mean
    cEPSILON = sqrt(eps(REAL))
    cTINY = eps(REAL)^1.25 / 2

    sEPSILON = string(cEPSILON)
    sTINY = string(cTINY)
    sDIM = string(DIM)
    gjk_parameters_header_s(sDIM, sREAL, sEPSILON, sTINY)
end

function gjk_parameters_header_s(sDIM, sREAL, sEPSILON, sTINY)
    """
    #define DIM		$(sDIM)       /* dimension of space (i.e., x/y/z = 3) */
    /* REAL is the type of a coordinate, INDEX of an index into the point arrays */
    typedef $(sREAL)	REAL;
    /* Arithmetic operators on type REAL: defined here to make it
       easy (say) to use fixed point arithmetic. Note that addition
       and subtraction are assumed to work normally.
       */

   /* Even this algorithm has an epsilon (fudge) factor.  It basically indicates
      how far apart two points have to be to declared different, expressed
      loosely as a proportion of the `average distance' between the point sets.
    */
    #define EPSILON ((REAL) $(sEPSILON))

    /* TINY is used in one place, to indicate when a positive number is getting
       so small that we loose confidence in being able to divide a positive
       number smaller than it into it, and still believing the result.
       */
    #define TINY	((REAL) $(sTINY))  /* probably pessimistic! */
    """
end
