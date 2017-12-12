// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//      ms_PulseMode.cpp
//
// Purpose:
// 
// Read in the science data and do a quick processing - find the slope and zeropt.
// Options to drop initial and final frames allowed. All others ignored
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
//void ms_PulseMode( const int iter,
//		    const int isubset,
//		    const int this_nrow,
//		    miri_control &control,
//		    miri_data_info &data_info,
//		    vector<float> &Slope)
//
//
// Arugments:
//
//  iter: current iteration
//  isubset: current subset being processed
//  this_nrow: number of rows in the subset
//  apply_badpxiel: flag to apply bad pixel mask. If = 1 then apply. 
//  control : miri_control structure holding basic information on processing
//  data_info: miri_data_info structure containing basic information on the dataset
//  Slope -Really this is just the amplitude of Pulse_Frame_f - Pulse_Frame_i
//
//
// Return Value/ Variables modified:
//      No return value
//      pixel class updated with pixel information
//
// Additional programs called  
// void PixelXY_PixelIndex(const int,const int , const int ,long &);
// converts the 2-d x,y values into the equivalent 1-d index array value

//
// History:
//
//	Written by Jane Morrison April 17, 2013

#include <time.h>
#include <iostream>
#include <vector>
#include <string>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_constants.h"
#include "miri_sloper.h"


// converting 2-d  array to 1-d vector 
void PixelXY_PixelIndex(const int,const int , const int ,long &);

void ms_PulseMode ( const int iter,
		    const int isubset,
		    const int this_nrow,
		    miri_control &control,
		    miri_data_info &data_info,
		    vector<float> &Slope)

{
  
  // **********************************************************************
  // open the file - pull out subset

  cout << " Running Pulse Mode pipeline " << endl;

  if(control.flag_Pulse_Frame_f == 0) {
    control.Pulse_Frame_f = data_info.NRamps -1;
  }

  cout << " Frame i = " << control.Pulse_Frame_i << endl;
  cout << " Frame f = " << control.Pulse_Frame_f << endl;

  //_______________________________________________________________________

  
  long inc[3]={1,1,1};
  int anynul = 0;  // null values
  int status = 0;

  int naxis = 3;
  long naxes[3];
  naxes[0] = data_info.raw_naxes[0];
  naxes[1] = data_info.raw_naxes[1];
  naxes[2] = data_info.raw_naxes[2];

  //_______________________________________________________________________

  // Read in the Frame i data      
  status = 0;
  long fpixel[3] ;
  long lpixel[3];

  // lower left corner of subset
  fpixel[0]= 1;
  fpixel[1]= (isubset * data_info.subset_nrow) + 1;

  // number of rows of data to read in  
  lpixel[0] = data_info.ramp_naxes[0];
  lpixel[1] = fpixel[1] + this_nrow-1;

  
  int xsize = data_info.ramp_naxes[0];
  
  // frame i for current integration 
  fpixel[2]= control.Pulse_Frame_i + iter*data_info.NRamps;
  lpixel[2]= control.Pulse_Frame_i + iter*data_info.NRamps;    

  
  //cout << " first pixel " << fpixel[0] << " " << fpixel[1] << " " << fpixel[2] << endl;
  // cout << " last  pixel " << lpixel[0] << " " << lpixel[1] << " " << lpixel[2] << endl;

  long ixyz =this_nrow*xsize;
    

  vector<int>  frame_i(ixyz);


  status = 0;
  fits_read_subset_int(data_info.raw_file_ptr, 0, naxis, naxes, 
		       fpixel,lpixel,
		       inc,0, 
		       &frame_i[0], &anynul, &status);



  if(status != 0) {
    cout <<" Problem reading subset of data " << isubset << endl;
    cout << " status " << status << endl;
    exit(-1);
  }

  // read in frame F for current integration
  fpixel[2]= control.Pulse_Frame_f + iter*data_info.NRamps;
  lpixel[2]= control.Pulse_Frame_f + iter*data_info.NRamps;    


  //cout << " first pixel " << fpixel[0] << " " << fpixel[1] << " " << fpixel[2] << endl;
  //cout << " last  pixel " << lpixel[0] << " " << lpixel[1] << " " << lpixel[2] << endl;

  vector<int>  frame_f(ixyz);


  status = 0;
  fits_read_subset_int(data_info.raw_file_ptr, 0, naxis, naxes, 
		       fpixel,lpixel,
		       inc,0, 
		       &frame_f[0], &anynul, &status);



  if(status != 0) {
    cout <<" Problem reading subset of data " << isubset << endl;
    cout << " status " << status << endl;
    exit(-1);
  }


  long ik =0;
  //int incr = xsize*this_nrow;

  for (register int k = 0; k < this_nrow ; k++){
    for (register int j = 0; j< xsize ; j++,ik++){
      float amp = 0 ;
      amp = frame_f[ik] - frame_i[ik];
      Slope.push_back(amp);
      
    } // end loop over x values


  }

  if(control.do_verbose)cout <<  " Done doing Pulse Mode " << endl;

}
