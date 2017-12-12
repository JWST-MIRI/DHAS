// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//   ms_read_refdata.cpp
// 
// Purpose:
// 
// Read in the reference output image (channel 5). The reading and processing is
//  broken down into integrations. In order to process data for a pixel all the 
// frames for the  current integration have to read in and stored in memory.
// If file has frame/integration number > control.frame_limit (default
// value found in preference file) then the data 
// is read in groups of rows (subsets). 
//  The data for each group of rows is read in and according to a set of
// parameters it my be flagged as bad data. The data is then  processed together
// in the ms_process_refimage_data.cpp program. 
// 	
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
//void ms_read_refdata(const int iter,
//		     const int isubset,
//		     const int this_nrow,
//		     const int ramp_start,
//		     const float dn_high_sat,
//                   const float gain,
//		     miri_data_info &data_info,
//		     vector<miri_pixel> &refpixel)
//
//
// Arugments:
//
//  iter: current iteration
//  isubset: current subset being processed
//  this_nrow: number of rows in the subset
//  ramp_start: frame number to start fit on (ignore frames before this)
//  dn_high_sat: if pixel DN value above this limit - set the flag to ignore this value
//  data_info: miri_data_info structure containing basic information on the dataset
//  refpixel: miri_pixel class holding all the information on the reference output  pixels
//
//
// Return Value/ Variables modified:
//      No return value
//      refpixel class updated with pixel information
//
//
// History:
//
//	Written by Jane Morrison 2005
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/

#include <iostream>
#include <vector>
#include <string>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_pixel.h"
#include "miri_constants.h"


void ms_read_refdata(const int iter,
		     const int isubset,
		     const int this_nrow,
		     const int ramp_start,
		     const float dn_high_sat,
		     const float gain,
		     const float read_noise,
		     miri_data_info &data_info,
		     vector<miri_pixel> &refpixel)

{

  // *********************************************************************
  // For each frame in the integration:
  //   read in the entire reference images- store subset

  // open the file - pull out subset
  float read_noise_factor = read_noise/gain;
  read_noise_factor = read_noise_factor*read_noise_factor; 

  int naxis = 3;
  long naxes[3];
  naxes[0] = data_info.raw_naxes[0];
  naxes[1] = data_info.raw_naxes[1];
  naxes[2] = data_info.raw_naxes[2];

  int xsizefull = data_info.raw_naxes[0];

  long inc[3]={1,1,1};
  int anynul = 0;  // null values
  int status = 0;

  long fpixel[3];
  long lpixel[3];

  // lower left corner of the reference output
      
  fpixel[0]= 1;

  fpixel[1]= data_info.ref_naxes[1] + 1+ (isubset*data_info.subset_ref_nrow );
      
  lpixel[0] = xsizefull ;
  lpixel[1] = fpixel[1] + (this_nrow -1) ;

  int istart = iter*data_info.NRamps + ramp_start;
  int xsize = data_info.ref_naxes[0];    
 
  fpixel[2]=istart +1;
  lpixel[2]=fpixel[2] + data_info.NRampsRead -1 ;    
  long ixyz =data_info.NRampsRead*this_nrow*data_info.raw_naxes[0];

  //cout << " first pixel " << fpixel[0] << " " << fpixel[1] << endl;
  //cout << " last  pixel " << lpixel[0] << " " << lpixel[1] << endl;
  //cout << " dimension " << fpixel[2] << " " << lpixel[2] << endl;
  vector<int>  data(ixyz);

  status = 0;
  fits_read_subset_int(data_info.raw_file_ptr, 0, naxis, naxes,
		       fpixel,lpixel,
		       inc,0,
		       &data[0], &anynul, &status);
    
  if(status != 0) {
    cout <<" Problem reading reference data " <<  endl;
    cout << " status " << status << endl;
    exit(EXIT_FAILURE);
  }

  long ik =0;
  
  //cout << "xsize " << xsize << endl;
  int incr = xsizefull*this_nrow;

  long yy = (isubset*data_info.subset_ref_nrow)*4;
  //cout << "yy" << yy << endl;
  for (register int k = 0; k < this_nrow ; k++){
    for (register int p =0 ; p< 4; p++){

      for (register int j = 0; j< xsize ; j++){
	refpixel[ik].SetRefPixel(j+1,yy+1);
	refpixel[ik].ReserveRampData(data_info.NRampsRead);
	// No need to look for saturated data, reference output does
	// not have light no it. 
	vector<int>:: iterator Iter = data.begin()+ik;
        vector<int>:: iterator Iter_end = data.end();

	for(; Iter < Iter_end; Iter=Iter+incr){
	  short id = 0;
	  refpixel[ik].SetRampData(*Iter,id,gain,read_noise_factor);
	}


	int read_num_first_saturated = -1;

	refpixel[ik].SetReadNumFirstSat(read_num_first_saturated);
	ik++;
      } // end j to xsize
      yy++;
    }
    

  }// end loop over rows




  
}
