// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//      ms_QuickerSlope.cpp
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
//void ms_QuickerSlope( const int iter,
//		    const int isubset,
//		    const int this_nrow,
//		    miri_control &control,
//		    miri_data_info &data_info,
//		    vector<float> &Slope,
//		    vector<float> &ZeroPt)
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
//  Slope - vector of final slopes
// ZeroPt - vector of final zero points
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
//	Written by Jane Morrison 2010
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/
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

void ms_QuickerSlope( const int iter,
		      const int isubset,
		      const int this_nrow,
		      miri_control &control,
		      miri_data_info &data_info,
		      vector<float> &Slope,
		      vector<float> &ZeroPt,
		      vector<float> &RMS)

{
  
  // **********************************************************************
  // open the file - pull out subset
  // a few variables for use in FITS I/O
  // As the data is read in ignore and reject data based on the following:
  // a. ignore an initial frames to be rejected (set by control.n_reads_start_fit)
  // b. ignore final frames to get rejected (determined by data_info.NRampsRead.
  //    data_info.NRampsRead = (control.n_reads_end_fit - control.n_reads_start_fit) + 1;
  //    From ms_setup_processing.cpp
  //       

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

      
  //time_t t0; 
  //t0 = time(NULL);


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
  int istart = iter*data_info.NRamps+ control.n_reads_start_fit;
  
  // read in all the frames for the current integration
  fpixel[2]=istart +1;
  lpixel[2]=fpixel[2] + data_info.NRampsRead-1;    


  //cout << " first pixel " << fpixel[0] << " " << fpixel[1] << " " << fpixel[2] << endl;
  // cout << " last  pixel " << lpixel[0] << " " << lpixel[1] << " " << lpixel[2] << endl;

  long ixyz =data_info.NRampsRead*this_nrow*xsize;
    

  vector<int>  data(ixyz);


  status = 0;
  fits_read_subset_int(data_info.raw_file_ptr, 0, naxis, naxes, 
		       fpixel,lpixel,
		       inc,0, 
		       &data[0], &anynul, &status);


  time_t tr; 
  tr = time(NULL);
  //cout << " Total Elapsed time to read data " << tr - t0 << endl;
  if(status != 0) {
    cout <<" Problem reading subset of data " << isubset << endl;
    cout << " status " << status << endl;
    exit(-1);
  }

  long ik =0;
  int incr = xsize*this_nrow;

  for (register int k = 0; k < this_nrow ; k++){
    for (register int j = 0; j< xsize ; j++,ik++){
      

      vector<int>:: iterator Iter = data.begin()+ik;
      vector<int>:: iterator Iter_end = data.end();

      float s(0.0);
      float sx(0.0);
      float sy(0.0);

      float x = 0.0;

      while(Iter < Iter_end && *Iter< control.dn_high_sat){
	s+= 1.0;
	sx += x ;
	sy += float(*Iter);
	x+= 1.0;
	Iter = Iter+incr;
      }
      

      float SxS = sx/s;
      float stt(0.0);
      float ty(0.0);
      x = 0.0;

      Iter = data.begin()+ik;
      while(Iter < Iter_end && *Iter< control.dn_high_sat){
      	float t = x - SxS;
      	stt += t*t;
      	ty += (*Iter)*t;
      	x+=1.0;
      	Iter = Iter+incr;
      }
      

      float intercept = NO_SLOPE_FOUND;
      float slope = NO_SLOPE_FOUND;
      float zero_pt = NO_SLOPE_FOUND;
      float rms = NO_SLOPE_FOUND;
      if(s >= 2) {
	int z_pt = control.n_reads_start_fit +1; // +1 because data from frame 1 occurs frame time=1 
	slope  = ty/stt;
	intercept = (sy - (sx*slope))/s;


	// we want zero pt at x = 0  
        // y = mx + b (zero pt where x  = -z_pt zero point of entire ramps 

	zero_pt = intercept - z_pt*slope; 


	// now find the RMS of the FIT
	// -----------------------------------------------------------------------
	float var(0.0);
	float vari(0.0);
	x = 0.0;
	Iter = data.begin()+ik;
	while(Iter < Iter_end && *Iter< control.dn_high_sat){
	  vari = float(*Iter) -intercept - slope*x;
	  var += vari * vari;
	  x+= 1.0;
	  Iter = Iter+incr;
	}
	var = var/(s-2);                     // See Bevington pg 106
	rms= sqrt(var);

	// -----------------------------------------------------------------------

	slope /=data_info.frame_time_to_use;
	if(control.convert_to_electrons_per_second ==1) slope *= control.gain;

      }
	
      if(slope == NO_SLOPE_FOUND ) {
	slope = strtod("NaN",NULL);
	zero_pt = strtod("NaN",NULL);
        rms = strtod("NaN",NULL);
      }
      Slope.push_back(slope);
      ZeroPt.push_back(zero_pt);
      RMS.push_back(rms);
    } // end loop over x values


  }

  //  time_t tp; 
  //tp = time(NULL);
  //cout << " Total Elapsed time process in QuickSlope " << tp - tr << endl;
  if(control.do_verbose)cout <<  " Done doing Quick Slope " << endl;

}
