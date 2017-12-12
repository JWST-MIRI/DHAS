// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//      ms_miri_refcorrection.cpp
//
// Purpose:
// 	This programs defines the miri_refcorrection class functions. 
//      The miri_refcorrection class holds all the reference pixel (border pixels) corrections.
//      The corrections are determined in ms_find_refcorrection.cpp 
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
//	Written by Jane Morrison 2007
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/
//      May 7 2013 updated reference pixel corrections

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>
#include <vector>
#include <algorithm>
#include "miri_refcorrection.h"
#include "miri_constants.h"

// Default constructor to set initial values

miri_refcorrection::miri_refcorrection()
{

}

//Default destructor
miri_refcorrection::~miri_refcorrection()
{
}




float miri_refcorrection::GetCorrection(int option, short channel, int sign, int x, int y){
  float correction = 0.0;
  // r3 or r6
  if(option == 3 || option == 6) {
    if(sign == 0){
      correction = Even_Correction[channel-1];
    } else{
      correction = Odd_Correction[channel-1];
    }
  }

  // r2
  if(option== 2)  correction = slope[channel-1][y] * x + yintercept[channel-1][y];     

  // r1
  if(option== 1)  correction = MovingMean[channel-1][y] ;     

  // r7
  if(option== 7)  correction = correction_amp[channel-1] ;     
  


  return correction;
}



float miri_refcorrection::GetTempCorrection(short channel){
  float correction = 0.0;
  correction = a[channel-1] + TempGain*a[4] ;     
  return correction;
}



void miri_refcorrection::PrintSlope(int num)const{


  for (int i = 0; i< num; i++){
	 cout << "Column #, slope ,y-intercpet " << i+1 << " " << slope[0][i] << " " 
	<< slope[1][i] << " " << slope[2][i] << " " << slope[3][i] << 
	" " << yintercept[0][i] <<  " " << yintercept[1][i] << " " << yintercept[2][i] <<
	" " << yintercept[3][i] << endl;
      
  }

}

