// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//   ms_initialize_data.cpp
//
// Purpose:
// 	This program initialized the data_info structure. 
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
//void ms_initialize_data_info(miri_data_info &data_info)
//
// Arguments:
//

//  data_info: miri_data_info structure containing basic information on the dataset
//
//
// Return Value/ Variables modified:
//      No return value.  
//      data_info structure set to default values (which are mostly = 0)
//
// History:
//
//	Written by Jane Morrison 2004
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/

#include "miri_data_info.h"

void ms_initialize_data_info(miri_data_info &data_info)

{
  // **********************************************************************

  data_info.NSample = 1;
  data_info.Mode=0;
  data_info.NFrame=0;
  data_info.NRamps=0;
  data_info.NRampsRead=0;
  data_info.NInt=0;
  data_info.NReset=0;        // number of  resets 
  data_info.Flag_FrameTime = 0;

  data_info.ColStart = 1;
  data_info.RowStart = 1;
  data_info.FrameDiv = 1; 

  data_info.refimage_exist = 0;
  data_info.subarray_mode = 0;
  

  data_info.subset_nrow = 1024 ; // default to read the entire array 
  data_info.numpixels = 0;
  data_info.Max_Num_Segments  = 0;



  data_info.red_naxis=0;            // number of axis in file
  data_info.red_bitpix=0;           // bits per pixel (output data type)

  // summary values of processing

  data_info.total_cosmic_rays=0; // total number of possible cosmic rays 
  data_info.total_noise_spike=0; // total number of noise spikes
  data_info.total_cosmic_rays_neg=0; // total number of noise cases that acts like a negative cr
  
  data_info.num_cr_seg = 0;     // limited to seg > 1
  data_info.num_cr_seg_neg = 0;     // limited to seg > 1

//_______________________________________________________________________

}

