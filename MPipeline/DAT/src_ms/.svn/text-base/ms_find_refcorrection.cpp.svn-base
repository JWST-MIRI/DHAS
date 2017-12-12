// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//     ms_find_refcorrection.cppp
//
// Purpose:
//
// This program reads the border reference pixels and determines the correction factor to
// apply to the data. These correction values are stored in the class  ref_correction. If 
// the data is also to be corrected by the reference output (channel 5) then these correction
// are first applied to the reference pixels and then the reference pixel corrections are 
// determined. 
// All the reference pixel corrections are  found a frame by frame and channel by channel basis.
// In addition even and odd rows are handled separately.  So for options  +r6 and +r7
// There are 8 correction values/frame (4 channels corrections split by even/odd rows).
//
// reference pixel correction options: (all are
//
// Define Set A reference pixels to be: pixels 1-4
//        Set B reference pixels to be pixel 1029-1032

// 
// +r6:
//     1. subtract first frame from reference pixels
//     2. from this difference find correction/frame/channel based on mean of (even or odd) reference pixels. 
// +r7 remove the temperature dependence from the reference pixels (correction if relative to frame 1)
// +r1: subtract value based on moving mean (box of mean determined from same box used in
//      r2: -rd #
// +r2 is different than the above corrections and bases the correction on an interpolation
//     between the left side reference pixels and right side reference pixels The interpolation
//     uses the slope and y-intercept between determined from the left and right reference pixels. 
//    The option -rd # size of box for find averages. 

// If the option to write these corrections to an ascii file was set - then they are written. 
// Keywords needed which describe the exposure:
// NGROUPS: # of frames in an integration
// NINTS:   # of integrations in the exposure 	
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
//void ms_find_refcorrection( const int iter,
//		       miri_control &control,
//		       miri_data_info &data_info,
//                     miri_CDP CDP,
//		       vector<miri_refcorrection> &ref_correction)
//
// Arguments:
//
//  iter: current iteration 
//  control: miri_control structure containing the processing options
//  data_info: miri_data_info structure containing basic information on the dataset
//  ref_correction: miri_refcorrection class holding the corrections associated with
//             the reference pixels.
//
// Return Value/ Variables modified:
//      No return value.  
//      ref_correction is updated with correct correction values. 
// 
// Additional Programs called 
// void FindMedian(vector<float> flux,float& Median);
// finds the median of a vector. 

// History:
//
//	Written by Jane Morrison 2007
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/
//      7-27-09, changed +r2 so that it always averages -rd # rows. If it is near an 
//               edge it adds more on the other side. 
//      5-07-13 Reorganized Vectors (7.0.1 version) easier to follow
//              Added +r1 option - moving mean value
//      02-10-16 Removed Reference Output options
//               moved reference pixel correction after dark subtraction (CDP5 RTS flow)
//               added apply reset anomaly correction, RSCD correction, subtracting dark
//               before determining the reference pixel correction
#include <vector>
#include <numeric>
#include <algorithm>
#include <iostream>
#include "miri_data_info.h"
#include "miri_control.h"
#include "miri_sloper.h"
#include "miri_refcorrection.h"
#include "miri_CDP.h"
#include "fitsio.h"


void FilterRefPixel(vector<float> &,const float, const int , float & ,int &status);

void FindMovingMean(vector<float> input,  const int istart, const int iend, 
		    float &moving_mean);




void ms_find_refcorrection( const int iter,
			    miri_control &control,
			    miri_data_info &data_info,
			    miri_CDP CDP,
			    vector<miri_refcorrection> &ref_correction)
 

{

  int  ysize = data_info.ramp_naxes[1];
  int ysize_half = ysize/2;

  int  ii = 0;
  ii = iter;
  if(ii >= 2) ii =1; 
    if(control.subtract_dark ==1)ms_read_dark_reference_pixels(ii,control,
  							       data_info,
  							       CDP,
  							       ref_correction);


   

  // reference pixels from Frame 1
  // Pull out data into 16 vectors: (for frame 1) 
  // 16 vectors: 4 amplifiers X 2 (Left/Right) X 2 (Even/Odd)


  vector<float> channel_1L_e1(ysize_half);
  vector<float> channel_1R_e1(ysize_half);
  vector<float> channel_2L_e1(ysize_half);
  vector<float> channel_2R_e1(ysize_half);
  vector<float> channel_3L_e1(ysize_half);
  vector<float> channel_3R_e1(ysize_half);
  vector<float> channel_4L_e1(ysize_half);
  vector<float> channel_4R_e1(ysize_half);

  // odd rows frame 1 
  vector<float> channel_1L_o1(ysize_half);
  vector<float> channel_1R_o1(ysize_half);
  vector<float> channel_2L_o1(ysize_half);
  vector<float> channel_2R_o1(ysize_half);
  vector<float> channel_3L_o1(ysize_half);
  vector<float> channel_3R_o1(ysize_half);
  vector<float> channel_4L_o1(ysize_half);
  vector<float> channel_4R_o1(ysize_half);

  // set for other frames 
  // 16 vectors: 4 amplifiers X 2 (Left/Right) X 2 (Even/Odd)
  vector<float> channel_1L_o(ysize_half);
  vector<float> channel_1R_o(ysize_half);
  vector<float> channel_2L_o(ysize_half);
  vector<float> channel_2R_o(ysize_half);
  vector<float> channel_3L_o(ysize_half);
  vector<float> channel_3R_o(ysize_half);
  vector<float> channel_4L_o(ysize_half);
  vector<float> channel_4R_o(ysize_half);

  vector<float> channel_1L_e(ysize_half);
  vector<float> channel_1R_e(ysize_half);
  vector<float> channel_2L_e(ysize_half);
  vector<float> channel_2R_e(ysize_half);
  vector<float> channel_3L_e(ysize_half);
  vector<float> channel_3R_e(ysize_half);
  vector<float> channel_4L_e(ysize_half);
  vector<float> channel_4R_e(ysize_half);


  int naxis = 3;
  long naxes[3];
  naxes[0] = data_info.raw_naxes[0];
  naxes[1] = data_info.raw_naxes[1];
  naxes[2] = data_info.raw_naxes[2];
  int ramp_start = control.n_reads_start_fit;
  long inc[3]={1,1,1};
  int anynul = 0;  // null values
  int status = 0;
  long fpixel[3] ;
  long lpixel[3];
  float unc = 1.0;

  //_______________________________________________________________________
  // Get the first frame reference pixels, on the left
  int istart = iter*data_info.NRamps;

  // read first (left) 4 columns of reference pixels 
  fpixel[1]=1;  // starting y values (does not change for routine)
  lpixel[1] = ysize;

  fpixel[0]=1;   // lefthand 4 reference pixels 
  lpixel[0] = 4;
    
  fpixel[2]=1;// first frame
  lpixel[2]=1;    
    
  // initialize the vectors
  int ref_data[ysize][4];
  for (int k = 0;k < ysize; k++){
    ref_data[k][0] = 0;
    ref_data[k][1] = 0;
    ref_data[k][2] = 0;
    ref_data[k][3] = 0;
  }

  // read in the left hand reference pixels of first frame
  status = 0;
  fits_read_subset_int(data_info.raw_file_ptr, 0, naxis, naxes, 
		       fpixel,lpixel,
		       inc,0, 
		       ref_data[0], &anynul, &status);
  if(status != 0) {
    cout << " Problem reading first frame left side of reference pixels " << endl;
    cout << " status " << status << endl;
    exit(-1);
  }

  // pull out even and odd rows and fill in channel_L for even/odd  arrays for first frame 
  int ieven = 0;
  int iodd = 0;
  for(register int k = 0; k < ysize ; k++){
    
    float dark_left_0 = 0.0;
    float dark_left_1 = 0.0;
    float dark_left_2 = 0.0;
    float dark_left_3 = 0.0;
    if(control.subtract_dark ==1){
      dark_left_0 = ref_correction[0].GetDarkLeft(0,k);
      dark_left_1 = ref_correction[0].GetDarkLeft(1,k);
      dark_left_2 = ref_correction[0].GetDarkLeft(2,k);
      dark_left_3 = ref_correction[0].GetDarkLeft(3,k);

    }

    int rem = k%2;
    if(rem ==0) { // even values
      channel_1L_e1[ieven] = ref_data[k][0] - dark_left_0 ;
      channel_2L_e1[ieven] = ref_data[k][1] - dark_left_1;
      channel_3L_e1[ieven] = ref_data[k][2] - dark_left_2;
      channel_4L_e1[ieven] = ref_data[k][3] - dark_left_3;
      ieven++;
    }else {
      channel_1L_o1[iodd] = ref_data[k][0] - dark_left_0 ;
      channel_2L_o1[iodd] = ref_data[k][1] - dark_left_1 ;
      channel_3L_o1[iodd] = ref_data[k][2] - dark_left_2 ;
      channel_4L_o1[iodd] = ref_data[k][3] - dark_left_3 ;
      iodd++;
    }
  }



  //_______________________________________________________________________
  // Get first frame reference pixels on the right 

  fpixel[0]=1029;  // reference pixels on the right 
  lpixel[0] = 1032;
  //********************************************************************************
  // Right reference pixels exist
  if(data_info.subarray_mode ==0) {
    anynul = 0;  // null values
    status = 0;
  // initialize the data 
    for (int k = 0;k < ysize; k++){
      ref_data[k][0] = 0;
      ref_data[k][1] = 0;
      ref_data[k][2] = 0;
      ref_data[k][3] = 0;
    }
    // read in the righthand reference pixels of the first frame
    fits_read_subset_int(data_info.raw_file_ptr, 0, naxis, naxes, 
			 fpixel,lpixel,
			 inc,0, 
			 ref_data[0], &anynul, &status);
    
    if(status != 0) {
      cout << " Problem reading first frame right side of reference pixels " << endl;
      cout << " status " << status << endl;
      exit(-1);
    }

  //********************************************************************************
  // Right reference pixels DONOT exist
  }else{
    for (int k = 0;k < ysize; k++){
      ref_data[k][0] = 0;
      ref_data[k][1] = 0;
      ref_data[k][2] = 0;
      ref_data[k][3] = 0;
    }
  }
  // pull out even and odd rows and fill in channel_R for even/odd  arrays for first frame 

  ieven = 0;
  iodd = 0;
  for(register int k = 0; k < ysize ; k++){
    float dark_right_0 = 0.0;
    float dark_right_1 = 0.0;
    float dark_right_2 = 0.0;
    float dark_right_3 = 0.0;
    if(control.subtract_dark ==1){
      dark_right_0 = ref_correction[0].GetDarkRight(0,k);
      dark_right_1 = ref_correction[0].GetDarkRight(1,k);
      dark_right_2 = ref_correction[0].GetDarkRight(2,k);
      dark_right_3 = ref_correction[0].GetDarkRight(3,k);
    }

    int rem = k%2;
    if(rem ==0) { // even values
      channel_1R_e1[ieven] = ref_data[k][0] - dark_right_0;
      channel_2R_e1[ieven] = ref_data[k][1] - dark_right_1;
      channel_3R_e1[ieven] = ref_data[k][2] - dark_right_2;
      channel_4R_e1[ieven] = ref_data[k][3] - dark_right_3;
      ieven++;
    }else {
      channel_1R_o1[iodd] = ref_data[k][0] - dark_right_0;
      channel_2R_o1[iodd] = ref_data[k][1] - dark_right_1;
      channel_3R_o1[iodd] = ref_data[k][2]  -dark_right_2;
      channel_4R_o1[iodd] = ref_data[k][3] - dark_right_3;
      iodd++;
    }
  }
    
  //_______________________________________________________________________
  // loop over the other frames that are used and read in the left and right data 

  istart = iter*data_info.NRamps + ramp_start;
  for(int iframe =0;iframe<data_info.NRampsRead;iframe++){

  // read first (left) 4 columns of reference pixels 
    fpixel[0]=1;
    lpixel[0] = 4;
    
    fpixel[2]=istart +iframe+1;
    lpixel[2]=istart +iframe+1;    
    

    int ref_data[ysize][4];
    for (int k = 0;k < ysize; k++){
      ref_data[k][0] = 0;
      ref_data[k][1] = 0;
      ref_data[k][2] = 0;
      ref_data[k][3] = 0;
    }

    status = 0;
    fits_read_subset_int(data_info.raw_file_ptr, 0, naxis, naxes, 
			 fpixel,lpixel,
			 inc,0, 
			 ref_data[0], &anynul, &status);
    if(status != 0) {
      cout << " Problem reading left side of reference pixels " << endl;
      cout << " status " << status << endl;
      exit(-1);
    }


    int ieven = 0;
    int iodd = 0;
    for(register int k = 0; k < ysize ; k++){
      float dark_left_0 = 0.0;
      float dark_left_1 = 0.0;
      float dark_left_2 = 0.0;
      float dark_left_3 = 0.0;
      if(control.subtract_dark ==1){
	dark_left_0 = ref_correction[iframe].GetDarkLeft(0,k);
	dark_left_1 = ref_correction[iframe].GetDarkLeft(1,k);
	dark_left_2 = ref_correction[iframe].GetDarkLeft(2,k);
	dark_left_3 = ref_correction[iframe].GetDarkLeft(3,k);
      } 
      int rem = k%2;
      if(rem ==0) { // even values
	channel_1L_e[ieven] = ref_data[k][0] - dark_left_0;
	channel_2L_e[ieven] = ref_data[k][1] - dark_left_1;
	channel_3L_e[ieven] = ref_data[k][2] - dark_left_2;
	channel_4L_e[ieven] = ref_data[k][3] - dark_left_3;

	// subtract frame 1 is refpixel option = 6
	if(control.do_refpixel_option == 6  || control.do_refpixel_option == 1 ) {
	  channel_1L_e[ieven] = channel_1L_e[ieven] - channel_1L_e1[ieven];
	  channel_2L_e[ieven] = channel_2L_e[ieven] - channel_2L_e1[ieven];
	  channel_3L_e[ieven] = channel_3L_e[ieven] - channel_3L_e1[ieven];
	  channel_4L_e[ieven] = channel_4L_e[ieven] - channel_4L_e1[ieven];
	}

	ieven++;

      } else{
	channel_1L_o[iodd] = ref_data[k][0] - dark_left_0;
	channel_2L_o[iodd] = ref_data[k][1] - dark_left_1;
	channel_3L_o[iodd] = ref_data[k][2] - dark_left_2;
	channel_4L_o[iodd] = ref_data[k][3] - dark_left_3;

	// subtract frame 1 is refpixel option = 6
	if(control.do_refpixel_option == 6  || control.do_refpixel_option == 1 ) {
	  channel_1L_o[iodd] = channel_1L_o[iodd] - channel_1L_o1[iodd];
	  channel_2L_o[iodd] = channel_2L_o[iodd] - channel_2L_o1[iodd];
	  channel_3L_o[iodd] = channel_3L_o[iodd] - channel_3L_o1[iodd];
	  channel_4L_o[iodd] = channel_4L_o[iodd] - channel_4L_o1[iodd];
	}
	iodd++;
      }  
    }

   
  // _______________________________________________________________________
  // read right (last) 4 columns of reference pixels 
  // reference pixel 
    fpixel[0]=1029;
    lpixel[0] = 1032;
  //********************************************************************************
  // Right reference pixels exist
    if(data_info.subarray_mode ==0) {


      anynul = 0;  // null values
      status = 0;
      unc = 1.0;  

      fpixel[2]=istart +iframe+1;
      lpixel[2]=istart +iframe+1;    

      for (int k = 0;k < ysize; k++){
	ref_data[k][0] = 0;
	ref_data[k][1] = 0;
	ref_data[k][2] = 0;
	ref_data[k][3] = 0;
      }
    

      fits_read_subset_int(data_info.raw_file_ptr, 0, naxis, naxes, 
			   fpixel,lpixel,
			   inc,0, 
			   ref_data[0], &anynul, &status);
    
      if(status != 0) {
	cout << " Problem reading right side of reference pixels " << endl;
	cout << " status " << status << endl;
	cout << " slice " << istart+iframe + 1 << endl; 
	exit(-1);
      }
  //********************************************************************************
  // Right reference pixels DO NOTexist
    } else{
      for (int k = 0;k < ysize; k++){
	ref_data[k][0] = 0;
	ref_data[k][1] = 0;
	ref_data[k][2] = 0;
	ref_data[k][3] = 0;
      }
    }

    
    ieven = 0;
    iodd = 0;

    for(register int k = 0; k < ysize ; k++){
      int rem = k%2;
      float dark_right_0 = 0.0;
      float dark_right_1 = 0.0;
      float dark_right_2 = 0.0;
      float dark_right_3 = 0.0;
      if(control.subtract_dark ==1){
	dark_right_0 = ref_correction[iframe].GetDarkRight(0,k);
	dark_right_1 = ref_correction[iframe].GetDarkRight(1,k);
	dark_right_2 = ref_correction[iframe].GetDarkRight(2,k);
	dark_right_3 = ref_correction[iframe].GetDarkRight(3,k);
      }

      if(rem ==0) { // even values
	channel_1R_e[ieven] = ref_data[k][0] - dark_right_0;
	channel_2R_e[ieven] = ref_data[k][1] - dark_right_1;
	channel_3R_e[ieven] = ref_data[k][2] - dark_right_2;
	channel_4R_e[ieven] = ref_data[k][3] - dark_right_3;

      // subtract frame 1 is refpixel option = 6
      if(control.do_refpixel_option == 6  || control.do_refpixel_option == 1 ) {
      	channel_1R_e[ieven] = channel_1R_e[ieven] - channel_1R_e1[ieven];
      	channel_2R_e[ieven] = channel_2R_e[ieven] - channel_2R_e1[ieven];
      	channel_3R_e[ieven] = channel_3R_e[ieven] - channel_3R_e1[ieven];
      	channel_4R_e[ieven] = channel_4R_e[ieven] - channel_4R_e1[ieven];
      }

      ieven++;

    } else{
      channel_1R_o[iodd] = ref_data[k][0] - dark_right_0;
      channel_2R_o[iodd] = ref_data[k][1] - dark_right_1;
      channel_3R_o[iodd] = ref_data[k][2] - dark_right_2;
      channel_4R_o[iodd] = ref_data[k][3] - dark_right_3;
      
      // subtract frame 1 is refpixel option = 6
      if(control.do_refpixel_option == 6  || control.do_refpixel_option == 1 ) {
      	channel_1R_o[iodd] = channel_1R_o[iodd] - channel_1R_o1[iodd];
      	channel_2R_o[iodd] = channel_2R_o[iodd] - channel_2R_o1[iodd];
      	channel_3R_o[iodd] = channel_3R_o[iodd] - channel_3R_o1[iodd];
      	channel_4R_o[iodd] = channel_4R_o[iodd] - channel_4R_o1[iodd];
      }

      iodd++;
    }
  }

//***********************************************************************
    // Clean up reference pixels- filter and sigma clip
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // we have 16 vectors of reference pixel values. 
    // Perform a moving box filter: Filter size is set by control.refpixel_filter_size
    // Sigma clipping is set by control.refpixel_sigma_clip
      
    float ch_mean_1R_e = 0 ;
    float ch_mean_2R_e = 0 ;
    float ch_mean_3R_e = 0 ;
    float ch_mean_4R_e = 0 ;
	
    float ch_mean_1R_o = 0 ;
    float ch_mean_2R_o = 0 ;
    float ch_mean_3R_o = 0 ;
    float ch_mean_4R_o = 0 ;
      
    float ch_mean_1L_e = 0 ;
    float ch_mean_2L_e = 0 ;
    float ch_mean_3L_e = 0 ;
    float ch_mean_4L_e = 0 ;
      
    float ch_mean_1L_o = 0 ;
    float ch_mean_2L_o = 0 ;
    float ch_mean_3L_o = 0 ;
    float ch_mean_4L_o = 0 ;

    FilterRefPixel(channel_1L_e,control.refpixel_sigma_clip, control.refpixel_filter_size,ch_mean_1L_e,status);
    FilterRefPixel(channel_2L_e,control.refpixel_sigma_clip, control.refpixel_filter_size,ch_mean_2L_e,status);
    FilterRefPixel(channel_3L_e,control.refpixel_sigma_clip, control.refpixel_filter_size,ch_mean_3L_e,status);
    FilterRefPixel(channel_4L_e,control.refpixel_sigma_clip, control.refpixel_filter_size,ch_mean_4L_e,status);

    FilterRefPixel(channel_1R_e,control.refpixel_sigma_clip, control.refpixel_filter_size,ch_mean_1R_e,status);
    FilterRefPixel(channel_2R_e,control.refpixel_sigma_clip, control.refpixel_filter_size,ch_mean_2R_e,status);
    FilterRefPixel(channel_3R_e,control.refpixel_sigma_clip, control.refpixel_filter_size,ch_mean_3R_e,status);
    FilterRefPixel(channel_4R_e,control.refpixel_sigma_clip, control.refpixel_filter_size,ch_mean_4R_e,status);

    FilterRefPixel(channel_1L_o,control.refpixel_sigma_clip, control.refpixel_filter_size,ch_mean_1L_o,status);
    FilterRefPixel(channel_2L_o,control.refpixel_sigma_clip, control.refpixel_filter_size,ch_mean_2L_o,status);
    FilterRefPixel(channel_3L_o,control.refpixel_sigma_clip, control.refpixel_filter_size,ch_mean_3L_o,status);
    FilterRefPixel(channel_4L_o,control.refpixel_sigma_clip, control.refpixel_filter_size,ch_mean_4L_o,status);

    FilterRefPixel(channel_1R_o,control.refpixel_sigma_clip, control.refpixel_filter_size,ch_mean_1R_o,status);
    FilterRefPixel(channel_2R_o,control.refpixel_sigma_clip, control.refpixel_filter_size,ch_mean_2R_o,status);
    FilterRefPixel(channel_3R_o,control.refpixel_sigma_clip, control.refpixel_filter_size,ch_mean_3R_o,status);
    FilterRefPixel(channel_4R_o,control.refpixel_sigma_clip, control.refpixel_filter_size,ch_mean_4R_o,status);

    //    cout << " Channel_LMean_1e" << " " << ch_mean_1L_e << endl;
    //cout << " Channel_LMean_1o" << " " << ch_mean_1L_o << endl;

    //cout << " Channel_RMean_1e" << " " << ch_mean_1R_e << endl;
    //cout << " Channel_RMean_1o" << " " << ch_mean_1R_o << endl;

    //cout << " Channel_LMean_2e" << " " << ch_mean_2L_e << endl;
    //cout << " Channel_LMean_2o" << " " << ch_mean_2L_o << endl;

    //cout << " Channel_RMean_2e" << " " << ch_mean_2R_e << endl;
    //cout << " Channel_RMean_2o" << " " << ch_mean_2R_o << endl;

    //cout << " Channel_LMean_3e" << " " << ch_mean_3L_e << endl;
    //cout << " Channel_LMean_3o" << " " << ch_mean_3L_o << endl;

    //cout << " Channel_RMean_3e" << " " << ch_mean_3R_e << endl;
    //cout << " Channel_RMean_3o" << " " << ch_mean_3R_o << endl;

    //cout << " Channel_LMean_4e" << " " << ch_mean_4L_e << endl;
    //cout << " Channel_LMean_4o" << " " << ch_mean_4L_o << endl;

    //cout << " Channel_RMean_4e" << " " << ch_mean_4R_e << endl;
    //cout << " Channel_RMean_4o" << " " << ch_mean_4R_o << endl;

	
    if(control.do_refpixel_option == 6){
      float MeanEven  = (ch_mean_1R_e + ch_mean_1L_e)/2.0;
      float MeanOdd  = (ch_mean_1R_o + ch_mean_1L_o)/2.0;
      ref_correction[iframe].SetEvenCorrection(1,MeanEven);
      ref_correction[iframe].SetOddCorrection(1,MeanOdd);

      MeanEven  = (ch_mean_2R_e + ch_mean_2L_e)/2.0;
      MeanOdd   = (ch_mean_2R_o + ch_mean_2L_o)/2.0;
      ref_correction[iframe].SetEvenCorrection(2,MeanEven);
      ref_correction[iframe].SetOddCorrection(2,MeanOdd);

      MeanEven  = (ch_mean_3R_e + ch_mean_3L_e)/2.0;
      MeanOdd   = (ch_mean_3R_o + ch_mean_3L_o)/2.0;
      ref_correction[iframe].SetEvenCorrection(3,MeanEven);
      ref_correction[iframe].SetOddCorrection(3,MeanOdd);
      
      MeanEven  = (ch_mean_4R_e + ch_mean_4L_e)/2.0;
      MeanOdd   = (ch_mean_4R_o + ch_mean_4L_o)/2.0;
      ref_correction[iframe].SetEvenCorrection(4,MeanEven);
      ref_correction[iframe].SetOddCorrection(4,MeanOdd);

    }
    // _______________________________________________________________________
    // Removal of temperature effects

    if(control.do_refpixel_option == 7){
      
      float yvalue[8];

      yvalue[0]  = (ch_mean_1L_e + ch_mean_1L_o)/2.0;
      yvalue[1]  = (ch_mean_2L_e + ch_mean_2L_o)/2.0;
      yvalue[2]  = (ch_mean_3L_e + ch_mean_3L_o)/2.0;
      yvalue[3]  = (ch_mean_4L_e + ch_mean_4L_o)/2.0;

      yvalue[4]  = (ch_mean_1R_e + ch_mean_1R_o)/2.0;
      yvalue[5]  = (ch_mean_2R_e + ch_mean_2R_o)/2.0;
      yvalue[6]  = (ch_mean_3R_e + ch_mean_3R_o)/2.0;
      yvalue[7]  = (ch_mean_4R_e + ch_mean_4R_o)/2.0;

      float b = control.refpixel_temp_scale;
      float bterm = b + 1.0;
      float b2term = b*b + 1.0;
      float bbot = 4.0 * bterm*bterm - (8.0 *b2term);
      float a5 = 0.0;
      for (int k = 0; k< 4; k++){
	float yterm = yvalue[k] + yvalue[k+4];
	float ybterm = b*yvalue[k] + yvalue[k+4];
	float term1 = bterm * yterm;
	float termtop = term1 - 2.0*ybterm;
	a5 = a5 + termtop;
      }
      a5 = a5/bbot;
      float a1 = (-a5 * bterm/2.0)+ (yvalue[0] + yvalue[4])/2.0;
      float a2 = (-a5 * bterm/2.0)+ (yvalue[1] + yvalue[5])/2.0;
      float a3 = (-a5 * bterm/2.0)+ (yvalue[2] + yvalue[6])/2.0;
      float a4 = (-a5 * bterm/2.0)+ (yvalue[3] + yvalue[7])/2.0;

      ref_correction[iframe].SetLeft(1,yvalue[0]);
      ref_correction[iframe].SetRight(1,yvalue[4]);

      ref_correction[iframe].SetLeft(2,yvalue[1]);
      ref_correction[iframe].SetRight(2,yvalue[5]);

      ref_correction[iframe].SetLeft(3,yvalue[2]);
      ref_correction[iframe].SetRight(3,yvalue[6]);

      ref_correction[iframe].SetLeft(4,yvalue[3]);
      ref_correction[iframe].SetRight(4,yvalue[7]);

      ref_correction[iframe].SetTempTerms(a1,a2,a3,a4,a5);
      ref_correction[iframe].SetTempGain(control.refpixel_temp_gain);
    }
  //_______________________________________________________________________
    // Reference pixel correction = 2 
  //_______________________________________________________________________      
    // reference pixel option =2 (even/odd split
    //    float zero = 0.0;
    if(control.do_refpixel_option == 2 || control.do_refpixel_option == 1){
      int ik = 0 ; 
       
      for (int ii= 0 ; ii< ysize_half; ii++){
	int istart = ii - control.delta_refpixel_even_odd/2;
	int iend = ii + control.delta_refpixel_even_odd/2;
	if(istart < 0){
	  istart = 0;
	  iend = ii + control.delta_refpixel_even_odd;
	}
	if(iend > ysize_half-1){

	  iend = ysize_half-1;
	  istart = iend - control.delta_refpixel_even_odd;
	}
	
	// channel 1
	vector<float> left;
	vector<float> right;

	float LMean = 0.0;
	float RMean = 0.0; 
	FindMovingMean(channel_1L_e,istart,iend,LMean);
	FindMovingMean(channel_1R_e,istart,iend,RMean);

	float slope = (RMean - LMean)/1025.0;
	ref_correction[iframe].SetYintercept(1,ik,LMean);
	ref_correction[iframe].SetSlope(1,ik,slope);

	float MovingMean = (RMean+LMean)/2.0;
	ref_correction[iframe].SetMovingMean(1,ik,MovingMean);

	// Channel 2
	FindMovingMean(channel_2L_e,istart,iend,LMean);
	FindMovingMean(channel_2R_e,istart,iend,RMean);

	slope = (RMean - LMean)/1025.0;
	ref_correction[iframe].SetYintercept(2,ik,LMean);
	ref_correction[iframe].SetSlope(2,ik,slope);
	MovingMean = (RMean+LMean)/2.0;
	ref_correction[iframe].SetMovingMean(2,ik,MovingMean);

	// channel 3
	FindMovingMean(channel_3L_e,istart,iend,LMean);
	FindMovingMean(channel_3R_e,istart,iend,RMean);

	slope = (RMean - LMean)/1025.0;
	ref_correction[iframe].SetYintercept(3,ik,LMean);
	ref_correction[iframe].SetSlope(3,ik,slope);
	MovingMean = (RMean+LMean)/2.0;
	ref_correction[iframe].SetMovingMean(3,ik,MovingMean);

	// channel 4
	FindMovingMean(channel_4L_e,istart,iend,LMean);
	FindMovingMean(channel_4R_e,istart,iend,RMean);
	slope = (RMean - LMean)/1025.0;
	ref_correction[iframe].SetYintercept(4,ik,LMean);
	ref_correction[iframe].SetSlope(4,ik,slope);
      	MovingMean = (RMean+LMean)/2.0;
	ref_correction[iframe].SetMovingMean(4,ik,MovingMean);

	// Go to odd values
	ik++;

	// channel 1
	FindMovingMean(channel_1L_o,istart,iend,LMean);
	FindMovingMean(channel_1R_o,istart,iend,RMean);
	slope = (RMean - LMean)/1025.0;
	ref_correction[iframe].SetYintercept(1,ik,LMean);
	ref_correction[iframe].SetSlope(1,ik,slope);
	MovingMean = (RMean+LMean)/2.0;
	ref_correction[iframe].SetMovingMean(1,ik,MovingMean);

	// channel 2
	FindMovingMean(channel_2L_o,istart,iend,LMean);
	FindMovingMean(channel_2R_o,istart,iend,RMean);
	slope = (RMean - LMean)/1025.0;
	ref_correction[iframe].SetYintercept(2,ik,LMean);
	ref_correction[iframe].SetSlope(2,ik,slope);
	MovingMean = (RMean+LMean)/2.0;
	ref_correction[iframe].SetMovingMean(2,ik,MovingMean);

	// channel 3
	FindMovingMean(channel_3L_o,istart,iend,LMean);
	FindMovingMean(channel_3R_o,istart,iend,RMean);
	slope = (RMean - LMean)/1025.0;
	ref_correction[iframe].SetYintercept(3,ik,LMean);
	ref_correction[iframe].SetSlope(3,ik,slope);
	MovingMean = (RMean+LMean)/2.0;
	ref_correction[iframe].SetMovingMean(3,ik,MovingMean);

	// channel 4
	FindMovingMean(channel_4L_o,istart,iend,LMean);
	FindMovingMean(channel_4R_o,istart,iend,RMean);
	slope = (RMean - LMean)/1025.0;
	ref_correction[iframe].SetYintercept(4,ik,LMean);
	ref_correction[iframe].SetSlope(4,ik,slope);
	MovingMean = (RMean+LMean)/2.0;
	ref_correction[iframe].SetMovingMean(4,ik,MovingMean);
	
	ik++;

      }
    }
  //_______________________________________________________________________
    if(control.write_output_refpixel) {
    //cout << " Writing Reference Pixel Correction to " << data_info.output_refpixel << endl;
    //_______________________________________________________________________
      // The even and odd corrections are consistent but for printing information
      // out they are really revervsed
      if(control.do_refpixel_option == 6) {
	float c1odd = ref_correction[iframe].GetEvenCorrection(0);
	float c1even =  ref_correction[iframe].GetOddCorrection(0);
	float c2odd = ref_correction[iframe].GetEvenCorrection(1);
	float c2even = ref_correction[iframe].GetOddCorrection(1);
	float c3odd = ref_correction[iframe].GetEvenCorrection(2);
	float c3even = ref_correction[iframe].GetOddCorrection(2);
	float c4odd = ref_correction[iframe].GetEvenCorrection(3);
	float c4even = ref_correction[iframe].GetOddCorrection(3);
	data_info.output_rp << setiosflags(ios::fixed| ios::showpoint) <<setprecision(3) << 
	setw(8) << iter+1 << setw(10) << iframe+ramp_start+1 << setw(16) << c1even <<  
	  setw(12) << c1odd << setw(12) << c2even << setw(12) << c2odd <<
	  setw(12) << c3even  << setw(12) << c3odd << setw(12) << c4even <<  setw(12) << c4odd << endl;
      }


    //_______________________________________________________________________

      if(control.do_refpixel_option == 2) {
	
	for(int k = 0; k < ysize ; k++){
	  // loop over 4 border reference pixels
	  float slope[4]= {0};
	  float yint[4] ={0};

	  slope[0] = ref_correction[iframe].GetSlope(1,k);
	  yint[0] = ref_correction[iframe].GetYintercept(1,k);

	  slope[1] = ref_correction[iframe].GetSlope(2,k);
	  yint[1] = ref_correction[iframe].GetYintercept(2,k);

	  slope[2] = ref_correction[iframe].GetSlope(3,k);
	  yint[2] = ref_correction[iframe].GetYintercept(3,k);

	  slope[3] = ref_correction[iframe].GetSlope(4,k);
	  yint[3] = ref_correction[iframe].GetYintercept(4,k);
	    
	  data_info.output_rp << setiosflags(ios::fixed| ios::showpoint) <<setprecision(3) <<  
	    setw(8) << iter+1 << setw(8) << iframe+ramp_start +1   << setw(8) << k+1 << 
	    setw(12) << slope[0] << setw(12) << yint[0] << 
	    setw(10) << slope[1] << setw(12) << yint[1] << 
	    setw(10) << slope[2] << setw(12) << yint[2] << 
	    setw(10) << slope[3] << setw(12) << yint[3] << endl;
	} // end loop of k
      }// end loop do_refpixel_option == 2



    //_______________________________________________________________________
      if(control.do_refpixel_option == 1) {
	
	for(int k = 0; k < ysize ; k++){
	  // loop over 4 border reference pixels
	  float mean[4] ={0};

	  mean[0] = ref_correction[iframe].GetMovingMean(1,k);
	  mean[1] = ref_correction[iframe].GetMovingMean(2,k);
	  mean[2] = ref_correction[iframe].GetMovingMean(3,k);
	  mean[3] = ref_correction[iframe].GetMovingMean(4,k);

	  //cout << mean[0] << " " << mean[1] << endl;
	  data_info.output_rp << setiosflags(ios::fixed| ios::showpoint) <<setprecision(5) <<  
	    setw(8) << iter+1 << setw(8) << iframe+ramp_start +1   << setw(8) << k+1 << 
	    setw(20) << mean[0] << 
	    setw(20) << mean[1] << 
	    setw(20) << mean[2] << 
	    setw(20) << mean[3] << endl;
	} // end loop of k
      }// end loop do_refpixel_option == 1

    } // end write reference pixel corrections
  
    //_______________________________________________________________________
  
  } //end  loop over NRamps 

    // if refpixel correction option = 7
  // Correction is relative to Frame 1, subtract correction for frame 1 from all other frames
  
  if(control.do_refpixel_option == 7){
    float amp1 = ref_correction[0].GetTempCorrection(1);
    float amp2 = ref_correction[0].GetTempCorrection(2);
    float amp3 = ref_correction[0].GetTempCorrection(3);
    float amp4 = ref_correction[0].GetTempCorrection(4);

    
    for(int iframe =0;iframe<data_info.NRampsRead;iframe++){
      ref_correction[iframe].SetRelativeTempCorrection(amp1,amp2,amp3,amp4);
      if(control.write_output_refpixel) {
	float cor1 = ref_correction[iframe].GetRelativeTempCorrection(1);
	float cor2 = ref_correction[iframe].GetRelativeTempCorrection(2);
	float cor3 = ref_correction[iframe].GetRelativeTempCorrection(3);
	float cor4 = ref_correction[iframe].GetRelativeTempCorrection(4);

	vector<float> a  = ref_correction[iframe].GetTempTerms();

	data_info.output_rp << setiosflags(ios::fixed| ios::showpoint) <<setprecision(3) << 
	  setw(8) << iter+1 << setw(10) << iframe+ramp_start+1 << setw(16) << a[0] <<  
	  setw(12) << a[1] << setw(12) << a[2] << setw(12) << a[3] <<
	  setw(12) << a[4] << endl;

	data_info.output_rp << setiosflags(ios::fixed| ios::showpoint) <<setprecision(3) << 
	  setw(8) << iter+1 << setw(10) << iframe+ramp_start+1 << setw(16) << cor1 <<  
	  setw(12) << cor2 << setw(12) << cor3 << setw(12) << cor4 << endl;
      }
    }
  }

}
