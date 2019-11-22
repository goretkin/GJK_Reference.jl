// copied from gjkdemo.c
#include "gjk.h"

int
      gjk_num_g_test,     /* how many times the G-test is performed -- the
                             same as the number of main-loop iterations */
      gjk_num_simplices,  /* how many times the simplex routine
                             was called */
      gjk_num_backups,    /* how many times (if ever!) the GJK backup
                             procedure was called */
      gjk_num_dot_products, /* how many dot-product operations are called */
      gjk_num_support_dp, /* how many dot-product operations are called
        whilst executing the support function */
      gjk_num_other_ops; /* how many other mults and divides are called */

void apply_trans(  Transform t, REAL * src, REAL * tgt)
{
  int i;

  if ( t==0 )
    for ( i=0 ; i<DIM ; i++ )
      tgt[i] = src[i];
  else {
    for ( i=0 ; i<DIM ; i++ )
      tgt[i] = t[i][DIM] + OTHER_DOT_PRODUCT( t[i], src);
  }
  return;
}


void
apply_rot_transpose( Transform t, REAL * src, REAL * tgt)
{
  int i;

  if ( t==0 )
    for ( i=0 ; i<DIM ; i++ )
      tgt[i] = src[i];
  else {
    for ( i=0 ; i<DIM ; i++ )
      tgt[i] = DO_MULTIPLY( t[0][i], src[0]) + DO_MULTIPLY( t[1][i], src[1])
               + DO_MULTIPLY( t[2][i], src[2]);
  }
  return;
}
