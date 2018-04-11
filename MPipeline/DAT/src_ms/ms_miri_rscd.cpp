// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//      ms_miri_rscd.cpp
//
// Purpose:
// 	This programs defines the rscd class functions. 
//      see include/miri_rscd.h for a complete definition
//
// Author:
//
//	Jane Morrison
//      University of Arizona
//      email: morrison@as.arizona.edu
//      phone: 520-626-3181
// 
// Calling Sequence:
//
////  no calling sequence: describes class functions. 
//
// Arguments:
//
//
// Return Value/ Variables modified:
//      No return value.  
// 
//
// History:
//
//	Written by Jane Morrison 2014
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>
#include <vector>
#include <algorithm>
#include "miri_rscd.h"
#include "miri_constants.h"

// Default constructor to set initial values

miri_rscd::miri_rscd()
{

}

//Default destructor
miri_rscd::~miri_rscd()
{
}


void miri_rscd::SetParameters(const int  nframes,
			      float Ttau_even, float Tascale_even, float Tpow_even,
			      float Tillum_zp_even, float Tillum_slope_even,
			      float Tillum2_even, float Tparam3_even, float Tcpt_even,
			      float Ttau_odd, float Tascale_odd, float Tpow_odd, 
			      float Tillum_zp_odd, float Tillum_slope_odd, 
			      float Tillum2_odd, float Tparam3_odd, float Tcpt_odd){
    tau_even = Ttau_even;
    ascale_even = Tascale_even;
    pow_even = Tpow_even;
    illum_zp_even = Tillum_zp_even;
    illum_slope_even = Tillum_slope_even;
    illum2_even = Tillum2_even;
    param3_even = Tparam3_even;
    crossopt_even = Tcpt_even;

    tau_odd = Ttau_odd;
    ascale_odd = Tascale_odd;
    pow_odd = Tpow_odd;
    illum_zp_odd = Tillum_zp_odd;
    illum_slope_odd = Tillum_slope_odd;
    illum2_odd = Tillum2_odd;
    param3_odd = Tparam3_odd;
    crossopt_odd = Tcpt_odd;

    b1_even = ascale_even * 
      (illum_zp_even + illum_slope_even*nframes + 
       (illum2_even*nframes*nframes));

    b1_odd = ascale_odd * 
      (illum_zp_odd + illum_slope_odd*nframes + 
       (illum2_odd*nframes*nframes));


    cout << "b1 " << b1_even << " " << b1_odd << endl;

  }

void miri_rscd::SetSATParameters(const int nframes,
				 float Tsat_zp_even, float Tsat_slope_even, 
				 float Tsat_2_even,float Tsat_mzp_even, 
				 float Tsat_rowterm_even, float Tsat_scale_even,
				 float Tsat_zp_odd, float Tsat_slope_odd, 
				 float Tsat_2_odd,float Tsat_mzp_odd, 
				 float Tsat_rowterm_odd, float Tsat_scale_odd){
    sat_zp_even = Tsat_zp_even;
    sat_slope_even = Tsat_slope_even;
    sat_2_even = Tsat_2_even;
    sat_mzp_even = Tsat_mzp_even;
    sat_rowterm_even = Tsat_rowterm_even;
    sat_scale_even = Tsat_scale_even;

    sat_zp_odd = Tsat_zp_odd;
    sat_slope_odd = Tsat_slope_odd;
    sat_2_odd = Tsat_2_odd;
    sat_mzp_odd = Tsat_mzp_odd;
    sat_rowterm_odd = Tsat_rowterm_odd;
    sat_scale_odd = Tsat_scale_odd;
    
    sat_final_slope_even = sat_zp_even + sat_slope_even *nframes + 
      (sat_2_even*nframes*nframes) + sat_rowterm_even;

    sat_final_slope_odd = sat_zp_odd + sat_slope_odd *nframes + 
      (sat_2_odd*nframes*nframes) + sat_rowterm_odd;
   
    cout << " Sat 2 " << sat_2_even << " " << sat_2_odd << endl;
    cout << " Sat scale " << sat_scale_even << " " << sat_scale_odd << endl;
  }




