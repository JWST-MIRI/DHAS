// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//      ms_miri_CDP.cpp
//
// Purpose:
// 	This programs defines the lin class functions. 
//      see include/miri_lin.h for a complete definition
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
//	Written by Jane Morrison 2013
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>
#include <vector>
#include <algorithm>
#include "miri_CDP.h"
#include "miri_constants.h"

// Default constructor to set initial values

miri_CDP::miri_CDP()
{

}

//Default destructor
miri_CDP::~miri_CDP()
{
}


void miri_CDP::InitializeLastFrameCoeff(){

  float f = 0.0;
  for (int i = 0 ; i < 4 ; i++){
    LastFrameCoeff_Even_A.push_back(f);
    LastFrameCoeff_Odd_A.push_back(f);
    LastFrameCoeff_Even_B.push_back(f);
    LastFrameCoeff_Odd_B.push_back(f);
  }
}

