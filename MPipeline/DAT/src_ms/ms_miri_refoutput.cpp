// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//      ms_miri_refoutput.cpp
//
// Purpose:
// 	This programs defines the miri_refoutput class functions. 
//      The miri_refoutput class holds all the reference output (5th amplifier) corrections.
//      The corrections are determined in ms_find_refoutput_correction.cpp 
//      see include/miri_refcorrection.h for a complete definition
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
//	Written by Jane Morrison 2008
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/

// ms_miri_refoutput  defines the reference pixel correction
//  class functions. 

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>
#include <vector>
#include <algorithm>
#include "miri_refoutput.h"
#include "miri_constants.h"

// Default constructor to set initial values

miri_refoutput::miri_refoutput()
{

}

//Default destructor
miri_refoutput::~miri_refoutput()
{
}


void miri_refoutput::PrintValues()const{

  //  int num = slope.size();
  


}

float miri_refoutput::GetCorrection(const int i,float x) {
 
  float yfit = slope[i]*x + yintercept[i];
  float ynew = yfit - mean[i];

  // cout << " in GetCorrection" << i << " " << x << " " << slope[i] << " " << yintercept[i] << " " << mean[i] << " " << yfit << " " << ynew  <<endl;
  return ynew;
}




float miri_refoutput::GetFitValue(const int i,float x) {
 
  float yfit = slope[i]*x + yintercept[i];

  return yfit;
}
