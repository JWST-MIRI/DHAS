// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//      ms_miri_refpixel.cpp
//
// Purpose:
// 	This programs defines the miri_refpixel class functions.
//      The miri_refpixel class holds all the information for the border reference pixels.
//      see include/miri_refpixel.h for a complete definition.
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
//	Written by Jane Morrison 2007
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/

//  class functions. 

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>
#include <vector>
#include <algorithm>
#include "miri_refpixel.h"
#include "miri_constants.h"

// Default constructor to set initial values

miri_refpixel::miri_refpixel() : pix_x(0), pix_y(0), quality_flag(0),signal(0.0),signal_unc(0.0),
  num_good_reads(0){}


//Default destructor
miri_refpixel::~miri_refpixel()
{
}

//_______________________________________________________________________
void miri_refpixel::PrintData(){
  cout << " Data for pixel  " << pix_x << " " << pix_y << endl;
  cout << " quality flag    " << quality_flag << endl;
  cout << " number of ramps " << ref_data.size() << endl;
  for (unsigned int i = 0 ; i < ref_data.size() ; i++){
    cout << "    frame, ref data, id  " << i+1<< " " << ref_data[i] << " " << id_data[i] << endl;;
  }
}

//_______________________________________________________________________
void miri_refpixel::BadPixelReject (){

  vector<short>::iterator iter = id_data.begin();
  vector<short>::iterator iter_end = id_data.end();
  for(; iter != iter_end; ++iter)
    *iter = BAD_PIXEL_ID;
  signal = strtod("NaN",NULL);
  signal_unc = strtod("NaN",NULL);
}
//_______________________________________________________________________




