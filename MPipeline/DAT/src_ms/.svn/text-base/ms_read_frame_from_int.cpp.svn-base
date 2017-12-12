// This routine belongs to the miri_sloper package which processes raw science data.

// Name:

//
// Purpose:
// 
// Read last frame of the last integration for the Reset Switch Charge Decay step
// iframe holds the frame number, it can be the last frame or it could be the last 
// frame used in fit
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
//
// Arugments:
//
//  control: miri_control structure containing the processing options
//  data_info: miri_data_info structure containing basic information on the dataset

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
//	Written by Jane Morrison 2016
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/
#include <time.h>
#include <iostream>
#include <vector>
#include <string>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_sloper.h"




void PixelXY_PixelIndex(const int,const int , const int ,long &);
// converting 2-d  array to 1-d vector 
void ms_read_frame_from_int(miri_data_info &data_info,
				const int i,  // integration number (passed as starting at zero) 
				int iframe, // frame number of read in 
				vector<float>&lastframe)

{
  
  // **********************************************************************

  long inc[3]={1,1,1};
  int anynul = 0;  // null values
  int status = 0;

  long NSCD = data_info.ramp_naxes[0] * data_info.ramp_naxes[1];
  vector<int> lastframe_int(NSCD);
  int naxis = 3;
  long naxes[3];
  naxes[0] = data_info.raw_naxes[0];
  naxes[1] = data_info.raw_naxes[1];
  naxes[2] = data_info.raw_naxes[2];
  //_______________________________________________________________________

  status = 0;
  long fpixel[3] ;
  long lpixel[3];

  // lower left corner 
  fpixel[0]= 1;
  fpixel[1]= 1;

  // all pixels in frame 
  lpixel[0] = data_info.ramp_naxes[0];
  lpixel[1] = data_info.ramp_naxes[1];
  
  
  // read in all the frames for the current integration
  //  fpixel[2]=(data_info.NRamps) + (i)*data_info.NRamps;
  //lpixel[2]=(data_info.NRamps) + (i)*data_info.NRamps;    

  fpixel[2]=(iframe) + (i)*data_info.NRamps;
  lpixel[2]=(iframe) + (i)*data_info.NRamps;    

  //  cout << " first pixel " << fpixel[0] << " " << fpixel[1] << " " << fpixel[2] << endl;
  //cout << " last  pixel " << lpixel[0] << " " << lpixel[1] << " " << lpixel[2] << endl;
  //cout << " integration " << i+1 << endl;

  status = 0;
  fits_read_subset_int(data_info.raw_file_ptr, 0, naxis, naxes, 
  			 fpixel,lpixel,
  			 inc,0, 
  			 &lastframe_int[0], &anynul, &status);


  for (unsigned int i = 0 ; i < lastframe_int.size() ; i++){
    lastframe[i] = (float) lastframe_int[i];
  }
  

}
