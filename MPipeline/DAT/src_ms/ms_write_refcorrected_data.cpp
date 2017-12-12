// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
// ms_write_refcorrected_data.cpp
//
// Purpose:
// 	If the -OR option is used then the pixel data after the referenced pixel and
//      reference output corrections have been applied are written out to a FITS file.
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
//void ms_write_refcorrected_data( const int iter,
//				 const int isubset,
//				 const int this_nrow,
//				 const int ramp_start,
//				 miri_data_info &data_info,
//				 vector<miri_pixel> &pixel)
//
//
// Arugments:
//
//  iter: current iteration
//  isubset: current subset being processed
//  this_nrow: number of rows in the subset
//  ramp_start: frame number to start fit on (ignore frames before this)
//  data_info: miri_data_info structure containing basic information on the dataset
//  pixel: miri_pixel class holding information on each pixel 
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
#include <iostream>
#include <vector>
#include <string>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_pixel.h"


void ms_write_refcorrected_data( const int iter,
				 const int isubset,
				 const int this_nrow,
				 const int ramp_start,
				 miri_data_info &data_info,
				 vector<miri_pixel> &pixel)


{
  
  // **********************************************************************
  //       

  // cout << " Writing the reference corrected data " << endl; 

  int status = 0;
  //fits_movabs_hdu(data_info.rc_file_ptr, 1, &hdutype,&status);
  int naxis = 3;
  long naxes[3];
  naxes[0] = data_info.ramp_naxes[0];
  naxes[1] = data_info.ramp_naxes[1];
  naxes[2] = data_info.raw_naxes[2];

  //cout << naxes[0] << " " << naxes[1] << " " << naxes[2] << endl;
  //cout << " ramp start " << ramp_start << endl;

  long fpixel[3] ;
  long lpixel[3];

  // lower left corner of subset
  fpixel[0]= 1;
  fpixel[1]= (isubset * data_info.subset_nrow) + 1;

  // number of rows of data to read in  
  lpixel[0] = data_info.ramp_naxes[0];
  lpixel[1] = fpixel[1] + this_nrow-1;

  
  int xsize = data_info.ramp_naxes[0];
  int istart = iter*data_info.NRamps+ ramp_start;
  
  // read in all the frames for the current integration
  fpixel[2]=istart +1;
  lpixel[2]=fpixel[2] + data_info.NRampsRead-1;    


  //cout << " first pixel " << fpixel[0] << " " << fpixel[1] << " "<< fpixel[2] << endl;
  //cout << " last pixel " << lpixel[0] << " " << lpixel[1] << " " <<lpixel[2] << endl;
  long ixyz =data_info.NRampsRead*this_nrow*xsize;
    
  vector<float>  data(ixyz);


  long ip = 0;
  long ik =0;    
  //cout << data_info.NRampsRead << " " << this_nrow << " " << xsize << endl;

  for (int m = 0; m < data_info.NRampsRead; m++){
    ik =0;
    for (register int k = 0; k < this_nrow ; k++){
      for (register int j = 0; j< xsize ; j++){
	
	float RampPt = pixel[ik].GetFrameData(m);
	data[ip] = (RampPt);
	ip++;
	ik++;
      }

    }
  }
  status = 0;
  fits_write_subset_flt(data_info.rc_file_ptr, 0, naxis, naxes, 
			fpixel,lpixel,
			&data[0], &status);

  if(status != 0) {
    cout <<" ms_write_refcorrected_data: Problem writing subset of data " << isubset << endl;
    cout << " status " << status << endl;
    exit(EXIT_FAILURE);
  }


}
