  // This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//  ms_subtract_refdata.cpp
//
// Purpose:
//
//    If the options to correct the data using the reference pixels are set-
//       apply the correct corrections.These are found in ms_find_refcorrection.cpp
//       see ms_find_refcorrection - for details on correction using the 
//       reference pixels. 
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
//void ms_subtract_refdata(const int iter,
//			 const int isubset,
//			 const int this_nrow,
//			 const int refimage,  // = 0 if science data, = 1 if ref output 
//			 miri_control &control,
//			 miri_data_info &data_info,
//			 vector<miri_pixel> &pixel,
//			 vector<miri_refcorrection> &refcorrection)
//
//
// Arugments:
//
//  iter: current iteration
//  isubset: current subset being processed
//  this_nrow: number of rows in the subset
//  refimage a flag , = 0 if science data, = 1 if ref output 
//  control: miri_control structure containing the processing options
//  data_info: miri_data_info structure containing basic information on the dataset
//  pixel: miri_pixel class holding all the information on the pixels

//  refcorection: miri_refcorrection class holding information on the reference pixel 
//     corrections. 
//
// Return Value/ Variables modified:
//      No return value.  
// 
//
// History:
//
//	Written by Jane Morrison 2006 (expanded in 2008) 
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/


#include <iostream>
#include <vector>
#include <string>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_control.h"
#include "miri_pixel.h"
#include "miri_refcorrection.h"

//Correct the data using the reference output (5th channel) and reference pixels

void ms_subtract_refdata(const int iter,
			 const int isubset,
			 const int this_nrow,
			 const int refimage,  // = 0 if science data, = 1 if ref output 
			 miri_control &control,
			 miri_data_info &data_info,
			 vector<miri_pixel> &pixel,
			 vector<miri_refcorrection> &refcorrection)


{
  
  // *********************************************************************
  // For each frame in the integration:
  //   a.  read in the entire reference images
  //   b. loop over the pixel subset and subtract the reference image for this
  // subset.


  
  long naxes[3];
  naxes[0] = data_info.raw_naxes[0];
  naxes[1] = data_info.raw_naxes[1];
  naxes[2] = data_info.raw_naxes[2];
  int arow = isubset*data_info.subset_nrow;  // starting row in full image



  int xsize = data_info.raw_naxes[0];


  //***********************************************************************
      // Loop over the science data - making corrections that are set
  //***********************************************************************


  for ( int i = 0; i< data_info.NRampsRead; i++){
    long j = 0;
    int mrow = 0;
    for (register long l = 0; l < this_nrow; l++){
      for (register long m = 0; m < xsize; m++) {
//_______________________________________________________________________

// if option to subtract reference output was set the reference pixels
// already have this correction applied (done in ms_find_refcorrection.cpp)
	
	if(control.do_refpixel_option !=0){

	  short channel = pixel[j].GetChannel();

	  int yy = (arow + l);
	  int rem = (yy)%2;

	  float correct = 0.0;
	  correct = refcorrection[i].GetCorrection(control.do_refpixel_option,
						   channel,
						   rem,   // rem = 0: even, 1: odd
						   m,
						   yy);

	  pixel[j].SubtractValue(i,correct);
	}
//_______________________________________________________________________
	j++;
      }// end loop over m (x values)
      mrow++;
      if(mrow > 3) mrow = 0;
    }

  }// end looping over ramps

  
}
 
