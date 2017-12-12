// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//   ms_adjust_caldata.cpp
//
// Purpose:
//
// This routine is called by ms_setup_processing.cpp to adjust either the bad pixel mask
// or the pixel saturation mask (or both) if the data is subarray. 
// as bad.  	
//
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
// void ms_adjust_caldata(miri_data_info &data_info)
//
// Arguments:
//
// data_info (structure miri_data_info) is a structure that holds calibration masks 
// Return Value/ Variables modified:
//      No return value.
//  bad pixel array modified for subarray data. 
// 
//
// History:
//
//	Written by Jane Morrison December  2008
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/



#include <iostream>
#include <sstream> 
#include <vector>
#include <string>
#include "miri_CDP.h"
#include "miri_sloper.h"

// converting 2-d  array to 1-d vector 
void PixelXY_PixelIndex(const int,const int , const int ,long &);

void ms_adjust_caldata(const int apply_bad, const int apply_pixel_sat, 
		       miri_data_info &data_info,miri_CDP &CDP)
{
  int xsize = 1032; // bad pixel mask (1032 X 1024). 

  long num = 0;

  vector <int> badpix;
  vector <float> pixsat;
  vector <int> pixsat_dq;

  long m = 0;
  for (int i = 0; i< data_info.ramp_naxes[1] ; i++){
    int istart = (data_info.RowStart) + i;
    for (int j = 0; j < data_info.ramp_naxes[0] ; j++){
      int jstart = (data_info.ColStart) + j;
      long pixel_index = -1;


      PixelXY_PixelIndex(xsize,
			    jstart,istart,
			    pixel_index);

      if(apply_bad) {
	int bad = CDP.GetBadPixel(pixel_index);
	if(bad != 0) num++;

	badpix.push_back(bad);
      }

      if(apply_pixel_sat) {
	float ps = CDP.GetPixelSat(pixel_index);
	int ps_dq = CDP.GetPixelSat(pixel_index);
	pixsat.push_back(ps);
	pixsat_dq.push_back(ps_dq);
      }

      m++;
    }
  }
  //-----------------------------------------------------------------------
  if(apply_bad) { 
    
    CDP.CleanBadPixel();
    CDP.SetNumBadPixels(num);
    cout << " After adjusting bad pixel mask to sub array, # of bad pixels " << num << endl;
    for (unsigned int i = 0; i< badpix.size();i++) {
      CDP.SetBadPixel(badpix[i]);
      if(i < 300) cout << i+1<< " " <<  badpix[i] << endl;
    }

  }


  //-----------------------------------------------------------------------

  if(apply_pixel_sat) { 
    
    CDP.CleanPixelSat();
    CDP.CleanPixelSatDQ();
    for (unsigned int i = 0; i< pixsat.size();i++) {
      CDP.SetPixelSat(pixsat[i]);
      CDP.SetPixelSatDQ(pixsat_dq[i]);
    }
  }

}
