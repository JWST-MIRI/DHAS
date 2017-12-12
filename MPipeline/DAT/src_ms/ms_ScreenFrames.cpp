// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//      ms_Screen_Frames.cpp
//
// Purpose:
// 
//Search for bad frames cause by electronics wackyness 	
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
// Arugments:
//
//  control: miri_control structure containing the processing options
//  data_info: miri_data_info structure containing basic information on the dataset
//
// History:
//
//	Written by Jane Morrison 2010
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/
//  v 1.2 04-16-13  JEM added a fix when data saturates at 65535 -> incorrectly flags as corrupt frame
#include <time.h>
#include <iostream>
#include <vector>
#include <string>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_control.h"
#include "miri_sloper.h"


// converting 2-d  array to 1-d vector 

int ms_ScreenFrames( const int iter,
		      miri_control &control,
		      miri_data_info &data_info,
		      vector<int> &FrameBad,
		      int &nBad)

{
  
  // **********************************************************************
  nBad = 0;

  int A2DSAT = 65535;
  int Result_Status  = 0;
  long inc[3]={1,1,1};
  int anynul = 0;  // null values
  int status = 0;

  int naxis = 3;
  long naxes[3];
  naxes[0] = data_info.raw_naxes[0];
  naxes[1] = data_info.raw_naxes[1];
  naxes[2] = data_info.raw_naxes[2];

  
  long fpixel[3] ;
  long lpixel[3];

    // lower left corner of subset 
  fpixel[0]= 1;
  fpixel[1]= 1;

      // number of   pixels to read in 
  int xsize = 1024;
  lpixel[0] = xsize;  // read in 1024 values in the row 
  lpixel[1] = 1;   // read in one row of data - first row of data

  int istart = iter*data_info.NRamps+ control.n_reads_start_fit;
  
  // read in all the frames for the current integration

  fpixel[2]=istart +1;
  lpixel[2]=fpixel[2] + data_info.NRampsRead-1;    


  //  cout << " first pixel " << fpixel[0] << " " << fpixel[1] << " " << fpixel[2] << endl;
  //cout << " last  pixel " << lpixel[0] << " " << lpixel[1] << " " << lpixel[2] << endl;

  long ixyz =data_info.NRampsRead*xsize;

  vector<int>  data(ixyz);


  status = 0;
  fits_read_subset_int(data_info.raw_file_ptr, 0, naxis, naxes, 
  			 fpixel,lpixel,
  			 inc,0, 
  			 &data[0], &anynul, &status);

  //  for (int i = 0; i< 1030; i++){
  // cout << i+1<< " " <<  data[i] << endl;
  //}

  int incr = 512;
  for (int i = 0; i<data_info.NRampsRead; i++){ // looping over frames 
    int  NZeroDiff = 0;    
    for ( int j = 0; j< xsize/2 ; j++){  // loop over the first 1/2 of the row read in 
    
      long i1 = (i*xsize) + j;
      long i2 = i1 + (incr);
      float value1 = data[i1]; 
      float value2 = data[i2];
      
      float diff = fabs(value2-value1);
      if(diff ==0 && value2 != A2DSAT && value2 !=0) {  // the value can equal 0 for 
	                                                // integrations > 1 where previous int saturated 
	NZeroDiff++;
	//cout <<  "Found DIFF = 0  " << i+1 << " " << i1 << " " << i2 << " " << value1 << " " <<value2 << endl;
      }


    }
    
    if(NZeroDiff > 10){
      cout << " Corrupt Frame (electronics): total frame #, frame # in itegration " << i + istart+1 <<  "," <<
	i + control.n_reads_start_fit+1 << endl;
      FrameBad[i] = 1;
      nBad++;
    }

  }

  return Result_Status;
}
