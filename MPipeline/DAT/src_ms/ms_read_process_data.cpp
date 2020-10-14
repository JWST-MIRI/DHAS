// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//      ms_read_process_data.cpp
//
// Purpose:
// 
// Read in the science data. The reading and processing is broken down into
// integrations. In order to process data for a pixel all the frames for the 
// current integration have to read in and stored in memory.
// If file has frame/integration number > control.frame_limit (default
// value found in preference file) then the data 
// is read in groups of rows (subsets). The number of rows to read in at one time is
// controlled by control.subset_nrow (default in preferences file). 
//  The data for each group of rows is read in and according to a set of
// parameters it my be flagged as bad data. The data is then  processed together
// in the ms_process_data.cpp program. 
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
//void ms_read_process_data( const int iter,
//			   const int isubset,
//			   const int this_nrow,
//			   const int refimage,  // = 0 if science data, = 1 if ref output 
//                         vector<int> rscd,
//                         vector<miri_dark>  &dark,
//                         vector<miri_lin>  &linearity,
//			   miri_control &control,
//			   miri_data_info &data_info,
//			   vector<miri_pixel> &pixel,
//			   vector<miri_refcorrection> &refcorrection,
//			   vector<float> &Slope,
//			   vector<float> &SlopeUnc,
//			   vector<float> &SlopeID,
//			   vector<float> &ZeroPt,
//			   vector<float> &NumGood,
//			   vector<float> &ReadNumFirstSat,
//			   vector<float> &NumGoodSeg,
//			   vector<float> &RMS,
//			   vector<float> &Max2ptDiff,
//			   vector<float> &IMax2ptDiff,
//			   vector<float> &StdDev2pt,
//			   vector<float> &Slope2ptDiff)
//
// Arugments:
//
//  iter: current iteration
//  isubset: current subset being processed
//  this_nrow: number of rows in the subset
//  control: miri_control structure containing the processing options
//  data_info: miri_data_info structure containing basic information on the dataset
//  refimage : this data set is the reference image
//  data_info: miri_data_info structure containing basic information on the dataset
//  pixel miri_pixel class holding all the information on the pixels
//  refcorrection: reference pixel corrections
//
//  The following values have a size = full array. They are filled as the subsets
//  are processed. 
//  Slope: vector of slope for current integration. 
//  SlopeUnc: vector of slope uncertainities  for current integration. 
//  SlopeID: vector of  data quality flag for current integration. 
//  ZeroPt: vector of zero pt of fit for current integration. 
//  NumGood: vector of number of good frames used in the fit for current integration. 
//  ReadNumFirstSat: vector of  frame number corresponding to th first saturated DN value
//        in the fit.
//  NumGoodSeg: vector of number of good segments used to find the slope for current integration. 
//  The following variables are only determined if the -d (diagnostic flag is set)
//  RMS: vector of empirical uncertainties determined for the fit
//  Max2ptDiff: vector of maximum 2 pt differences in DN values for adjacent frames
//  iMax2ptDiff: vector of frame numbers corresponding to the maximum 2 pt differences 
//    in DN values for adjacent frames
// StdDev2pt: standard deviation of the 2-pt differences 
// Slope2ptDiff: slope of the 2-pt differences
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
//	Written by Jane Morrison 2004
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/
#include <time.h>
#include <iostream>
#include <vector>
#include <string>
#include <math.h>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_pixel.h"
#include "miri_constants.h"
#include "miri_sloper.h"
#include "miri_CDP.h"
#include "miri_rscd.h"
#include "miri_mult.h"

// converting 2-d  array to 1-d vector 
void PixelXY_PixelIndex(const int,const int , const int ,long &);

void ms_read_process_data( const int iteration,
			   const int isubset,
			   const int this_nrow,
			   const int refimage,  // = 0 if science data, = 1 if ref output 
			   vector<miri_reset> &reset,
			   miri_rscd RSCD,
			   miri_mult MULT,
			   vector<float> lastframe_rscd, // last frame of last integration 
			   vector<float> lastframe_rscd_sat, // last frame of last integration to use for saturating data 
			   vector<float> &lastframe_lincor,
			   vector<miri_dark> &dark,
			   vector<miri_lin> &linearity,
			   miri_control &control,
			   miri_data_info &data_info,
			   miri_CDP CDP,
			   vector<int> FrameBad,
			   const int NFramesBad,
			   vector<miri_pixel> &pixel,
			   vector<miri_refcorrection> &refcorrection,
			   vector<float> &Slope,
			   vector<float> &SlopeUnc,
			   vector<float> &SlopeID,
			   vector<float> &ZeroPt,
			   vector<float> &NumGood,
			   vector<float> &ReadNumFirstSat,
			   vector<float> &NumGoodSeg,
			   vector<float> &RMS,
			   vector<float> &Max2ptDiff,
			   vector<float> &IMax2ptDiff,
			   vector<float> &StdDev2pt,
			   vector<float> &Slope2ptDiff)
{
  
  // **********************************************************************
  // open the file - pull out subset
  // a few variables for use in FITS I/O
  // As the data is read in ignore and reject data based on the following:
  // a. ignore an initial frames to be rejected (set by control.n_reads_start_fit)
  // b. ignore final frames to get rejected (determined by data_info.NRampsRead.
  //    data_info.NRampsRead = (control.n_reads_end_fit - control.n_reads_start_fit) + 1;
  //    From ms_setup_processing.cpp
  // c. If the option is set to use the bad pixel list (default is yes) the flag bad pixels
  // d. reject saturated data flagged by control.dn_high_sat (global saturation value)
  // e. if the option to apply the pixel saturation mask is set, then for each pixel set any
  //    data that is above the saturation limit for this pixel.  
  //       
  //_______________________________________________________________________

  //  const long double PI = 3.141592653589793238L;
  // float pi_value = 1.0 /sqrt(PI*2.0);
  long inc[3]={1,1,1};
  int anynul = 0;  // null values
  int status = 0;

  int naxis = 3;
  long naxes[3];
  naxes[0] = data_info.raw_naxes[0];
  naxes[1] = data_info.raw_naxes[1];
  naxes[2] = data_info.raw_naxes[2];

  int debug_flag = 0;

  long num_cosmic_rays = 0;
  long num_cosmic_rays_neg = 0;
  long num_noise_spike = 0;

  long num_cr_seg = 0;
  long num_cr_seg_neg = 0;

  float read_noise_dn2 = control.read_noise_electrons/control.gain;
  read_noise_dn2 = read_noise_dn2*read_noise_dn2;
  // ______________________________________________________________________ 
  // Set up parameters for RSCD correction
  float rscd_lower_cutoff = 0.0;
  float rscd_alpha_even=0.0;
  float rscd_alpha_odd=0.0;
  float rscd_a0_even=0.0;
  float rscd_a0_odd=0.0;
  float rscd_a1_even=0.0;
  float rscd_a1_odd=0.0;
  float rscd_a2_even=0.0;
  float rscd_a2_odd=0.0;
  float rscd_a3_even=0.0;
  float rscd_a3_odd=0.0;

  float first_a0_even=0;
  float first_a1_even=0.0;
  float first_a2_even=0.0;
  float first_a3_even=0.0;

  float first_a0_odd=0;
  float first_a1_odd=0.0;
  float first_a2_odd=0.0;
  float first_a3_odd=0.0;

  if(control.apply_rscd_cor ==1 ) {

    RSCD.GetParams(iteration, rscd_lower_cutoff,
		   rscd_alpha_even, rscd_alpha_odd,
		   rscd_a0_even, rscd_a0_odd,
		   rscd_a1_even, rscd_a1_odd,
		   rscd_a2_even, rscd_a2_odd,
		   rscd_a3_even, rscd_a3_odd);

    RSCD.GetFirstParams(iteration, first_a0_even, first_a1_even,
			first_a2_even, first_a3_even,
		        first_a0_odd, first_a1_odd,
			first_a2_odd, first_a3_odd);
  }


  // set up parameters for multiple integration correction

  float mult_min_tol_even = 0.0;
  float mult_min_tol_odd= 0.0;
  float mult_alpha_even = 0.0;
  float mult_alpha_odd= 0.0;

  vector<float> mult_a_even(2);
  vector<float> mult_a_odd(2);
  vector<float> mult_b_even(2);
  vector<float> mult_b_odd(2);
  vector<float> mult_c_even(2);
  vector<float> mult_c_odd(2);
  vector<float> mult_d_even(2);
  vector<float> mult_d_odd(2);

  if(control.apply_rscd_cor ==1 ) {
    MULT.GetParams(mult_min_tol_even,
		   mult_min_tol_odd,
		   mult_alpha_even,
		   mult_alpha_odd,
		   mult_a_even, mult_a_odd,
		   mult_b_even, mult_b_odd,
		   mult_c_even, mult_c_odd,
		   mult_d_even, mult_d_odd);
  }
  //***********************************************************************
  time_t t0; 
  t0 = time(NULL);

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
  int istart = iteration*data_info.NRamps; //+ control.n_reads_start_fit;
  
  // read in all the frames for the current integration
  fpixel[2]=istart +1;
  lpixel[2]=fpixel[2] + data_info.NRampsRead-1;    

  //cout << " first pixel " << fpixel[0] << " " << fpixel[1] << " " << fpixel[2] << endl;
  //cout << " last  pixel " << lpixel[0] << " " << lpixel[1] << " " << lpixel[2] << endl;

  long ixyz =data_info.NRampsRead*this_nrow*xsize;
  vector<int>  data(ixyz);

  status = 0;
  fits_read_subset_int(data_info.raw_file_ptr, 0, naxis, naxes, 
  			 fpixel,lpixel,
  			 inc,0, 
  			 &data[0], &anynul, &status);

  time_t tr; 
  tr = time(NULL);
  
  if(status != 0) {
    cout <<" ms_read_process_data: Problem reading subset of data " << isubset << endl;
    cout << " status " << status << endl;
    exit(-1);
  }

  long ik =0;

  long ystart = isubset*data_info.subset_nrow;
  int incr = xsize*this_nrow;
  int mrow = 0; 

  //  cout << "data_info.NRampsRead " << data_info.NRampsRead << endl;

  for (register int k = 0; k < this_nrow ; k++){
    int yy = ystart + k;

    for (register int j = 0; j< xsize ; j++,ik++){

      pixel[ik].ReserveRampData(data_info.NRampsRead);
      int badpixel = 0;
      float sat = control.dn_high_sat;
      long pixel_index = -1;

      PixelXY_PixelIndex(xsize,
			 j+1,yy+1,
			 pixel_index);


      if(control.apply_pixel_saturation) sat = CDP.GetPixelSat(pixel_index);
      if(control.apply_badpix) badpixel = CDP.GetBadPixel(pixel_index); 

      vector<int>:: iterator Iter = data.begin()+ik;
      vector<int>:: iterator Iter_end = data.end();

      //_______________________________________________________________________
      int read_num_first_saturated = 50000;
      int iread = 0;
      for(; Iter < Iter_end; Iter=Iter+incr,iread++){
	int id = 0;
	if(*Iter >= control.dn_high_sat)id = HIGHSAT_ID;
	if(control.apply_pixel_saturation==1 && *Iter >= sat)id = HIGHSAT_ID;

	if( (id !=0 && iread< read_num_first_saturated) ) read_num_first_saturated = iread;

	if(NFramesBad !=0 && FrameBad[iread] ==1) { // corrupt frame
	  id = BADFRAME;
	}
	if (iread < control.n_reads_start_fit) id = SKIP_FRAME;
	if (iread > control.n_reads_end_fit) id = SKIP_FRAME;
	pixel[ik].SetRampData(*Iter,id,control.gain,read_noise_dn2,control.video_offset);
      }
      //_______________________________________________________________________
      if(read_num_first_saturated == 50000){
      	read_num_first_saturated = -1;
      } else {
      	read_num_first_saturated = read_num_first_saturated + control.n_reads_start_fit + 1;
      }
      //_______________________________________________________________________

      pixel[ik].SetPixel(j+1,yy+1,data_info.ColStart,read_num_first_saturated,badpixel); //

      int pix_x = pixel[ik].GetX();
      int pix_y = pixel[ik].GetY();
      
      //_______________________________________________________________________
      
      int is_ref = pixel[ik].GetIsRef();

      if(control.write_output_refpixel_corrections ==1)pixel[ik].InitializeRefCorData();
      if(control.write_output_dark_correction ==1 )pixel[ik].InitializeDarkCorData();
      if(control.write_output_rscd_correction ==1 )pixel[ik].InitializeRSCDCorData();
      if(control.write_output_reset_correction ==1 )pixel[ik].InitializeResetCorData();

      int is_even = pixel[ik].GetIsEven();
      
      float max2ptdiff = 0.0;
      float imax2ptdiff = 0.0;
      float stddev2ptdiff = 0.0;
      float slope2ptdiff = 0.0;
      debug_flag= 0;
      long num_found_cr = 0;
      long num_found_noise_spike_up = 0;
      long num_found_noise_spike_down = 0;
      long num_found_cr_neg = 0;
      int process_flag = pixel[ik].GetProcessFlag();

	//***********************************************************************
	    // Do not process hot or dead pixels
      if(process_flag ==1) { 
	//***********************************************************************
	// now start processing of data
      //_______________________________________________________________________

	// Subtract Reset Anomaly Correction 
	if(control.apply_reset_cor ==1) { 
	  vector<float> areset; 
	  int nplanes = CDP.GetResetUseNPlanes();
	  int reset_dq = reset[pixel_index].GetResetDQ();      // Get Data Quality flag of reset
	  for(int im = 0; im < nplanes; im++) {areset.push_back(reset[pixel_index].GetResetValue(im));}
	  pixel[ik].SubtractResetCorrection(control.write_output_reset_correction,
					   reset_dq,
					   areset); 

	}

      //_______________________________________________________________________

	if(control.apply_lin_cor ==1 ) { 
	
	  int  lin_dq =linearity[pixel_index].GetDQ();
	  int lin_order = CDP.GetLinOrder(); 
	  vector<float> lin(lin_order+1);
	
	  for (int kp = 0; kp < lin_order+1; kp++){
	    lin[kp] = linearity[pixel_index].GetCorrection(kp);
	  }
	  pixel[ik].CorrectNonLinearity(control.write_output_lc_correction,
					lin_dq,
					lin_order,
					lin);
	}      
    //-----------------------------------------------------------------------
	if(control.apply_rscd_cor==1) {
	  float lastint_lastframe= lastframe_rscd[pixel_index];
	  float lastint_lastframe_sat = lastframe_rscd_sat[pixel_index];

	  float firstframe = pixel[ik].GetFirstFrame();
	  
	  if(iteration == 0){
	    lastint_lastframe = firstframe;
	    lastint_lastframe_sat = firstframe;
	    if(pix_x == 181 && pix_y == -161)  cout << " First frame " << lastint_lastframe << endl;
	  }
	  
	  //if(pix_x == 181 && pix_y == 161) {
	  // if(iteration ==1) lastint_lastframe_sat = 98430.3+5028;
	  //  if(iteration ==2) lastint_lastframe_sat = 82352.7+5028;
	  //  if(iteration ==3) lastint_lastframe_sat = 80954.2+5028;
	  //  if(iteration ==4) lastint_lastframe_sat = 81289.1+5028;
	  //}
	    // mult terms
	  vector<float> mult_a;
	  vector<float> mult_b;
	  vector<float> mult_c;
	  vector<float> mult_d;

	  float mult_alpha  = mult_alpha_even;
	  float mult_min_tol = mult_min_tol_even;

	  mult_a = mult_a_even;
	  mult_b = mult_b_even;
	  mult_c = mult_c_even;
	  mult_d = mult_d_even;
	  if(iteration ==0){
	    mult_min_tol = 70000; // do not apply to first int
	  }
	      
	    // rscd terms
	  float rscd_alpha = rscd_alpha_even;
	  float rscd_min_tol = rscd_lower_cutoff;
	  if( iteration == 0) rscd_min_tol = 0;

	  float rscd_a0 = rscd_a0_even;
	  float rscd_a1 = rscd_a1_even;
	  float rscd_a2 = rscd_a2_even;
	  float rscd_a3 = rscd_a3_even;

	  float first_a0 = first_a0_even;
	  float first_a1 = first_a1_even;
	  float first_a2 = first_a2_even;
	  float first_a3 = first_a3_even;

	  if(is_even ==0) {
	    mult_alpha = mult_alpha_odd;
	    mult_min_tol = mult_min_tol_odd;
	    rscd_alpha = rscd_alpha_odd;

	    mult_a = mult_a_odd;
	    mult_b = mult_b_odd;
	    mult_c = mult_c_odd;
	    mult_d = mult_d_odd;

	    rscd_a0 = rscd_a0_odd;
	    rscd_a1 = rscd_a1_odd;
	    rscd_a2 = rscd_a2_odd;
	    rscd_a3 = rscd_a3_odd;

	    first_a0 = first_a0_odd;
	    first_a1 = first_a1_odd;
	    first_a2 = first_a2_odd;
	    first_a3 = first_a3_odd;
	  }


	  if(pix_x == 181 && pix_y == -161) {
	    cout << " sign of data " << is_even << endl;
	    cout << " last frame " << 	    lastint_lastframe << " " << lastint_lastframe_sat << endl;
	    cout << "rscd terms" << rscd_a0 << " " << rscd_a1 << " " << rscd_a2 <<  " " << rscd_a3 << " " <<
	      rscd_alpha_even << " " << rscd_lower_cutoff << endl;
	    cout << " mult terms " << mult_a[0]  << " " << mult_a[1] << " " << 
	      mult_b[0] << " " << mult_b[1]  << " " << 
	      mult_c[0]  << " " << mult_c[1] << " " << 
	      mult_d[0] << " " << mult_d[1]  << endl;
	    cout << " first frame terms " << first_a0 << " " << first_a1 << " " << first_a2 << " " << 
	      first_a3 << endl;
	  }

	  if (iteration == 0){  // first integration, first frame
	    if(lastint_lastframe < sat){ // not a hot pixel
	      //rscd_min_tol = 0;
	    } else { // a hot pixel do not apply correction
	      rscd_min_tol = 700000;
	    }
	  }
		  
	  pixel[ik].ApplyMULTRSCD(control.write_output_rscd_correction,
				  data_info.NRamps,
				  control.video_offset_rscd,
				  lastint_lastframe,
				  lastint_lastframe_sat,
				  sat,
				  mult_alpha,
				  mult_min_tol,
				  mult_a,
				  mult_b,
				  mult_c,
				  mult_d,
				  rscd_alpha,
				  rscd_min_tol,
				  rscd_a0,
				  rscd_a1,
				  rscd_a2,
				  rscd_a3,
				  first_a0,
				  first_a1,
				  first_a2,
				  first_a3);

	}
	
    //-----------------------------------------------------------------------
      } // end process flag - then re-check it 

      process_flag = pixel[ik].GetProcessFlag(); //  corrections  can change process flag to 0 
    //-----------------------------------------------------------------------
      // Subtract Dark 

      if(control.subtract_dark ==1 && process_flag ==1) { 
	vector<float> adark; 
	int nplanes = CDP.GetDarkUseNPlanes();
	short dark_dq = dark[ik].GetDarkDQ(); 	  // Get Data Quality flag of Dark
	for(int im = 0; im < nplanes; im++) {adark.push_back(dark[ik].GetDarkValue(im));}
	pixel[ik].SubtractDarkCorrection(control.write_output_dark_correction,
					 dark_dq,
					   adark); 

      }
    //-----------------------------------------------------------------------
    
      process_flag = pixel[ik].GetProcessFlag(); // Dark can change process flag to 0 

      if(process_flag == 1) {  // have check for process flag again because the dark or
	// reset can change it  

      //_______________________________________________________________________
	    //-------Subtract Reference Pixel-------
	if( control.do_refpixel_option !=0 ) {
	  for ( int i = 0; i< data_info.NRampsRead; i++){

	    short channel = pixel[ik].GetChannel();
	    int rem = (yy)%2;
	    float correct = 0.0;
	    correct = refcorrection[i].GetCorrection(control.do_refpixel_option,
						     channel,
						     rem,   // rem = 0: even, 1: odd
						     j,
						     yy);
	    pixel[ik].SubtractValue(i,correct);

	  } // end loop i over data_info.NRampsRead

	  if(control.write_output_refpixel_corrections ==1) pixel[ik].SetRefCorrected();
	} // end if over doing reference corrections

    //-----------------------------------------------------------------------
      // search for  cosmic rays 
	if(control.do_cr_id || control.do_diagnostic){
	  if(is_ref ==0 ) { 
	    ms_2pt_diff_quick(control.do_verbose_jump,
			      control.do_cr_id,
			      data_info.NRampsRead,
			      pixel[ik],
			      control.cr_sigma_reject,
			      control.cr_min_good_diffs,
			      control.n_frames_reject_after_cr,
			      control.max_iterations_cr,
			      control.cosmic_ray_noise_level,
			      num_found_cr,
			      num_found_noise_spike_up,
			      num_found_noise_spike_down,
			      num_found_cr_neg);

	    max2ptdiff = pixel[ik].GetMax2ptDiff();
	    imax2ptdiff = float(pixel[ik].GetIMax2ptDiff());
	    stddev2ptdiff = float(pixel[ik].GetStdDev2ptDiff());
	    slope2ptdiff = float(pixel[ik].GetSlope2ptDiff());
	    num_cosmic_rays = num_cosmic_rays + num_found_cr;
	    num_cosmic_rays_neg = num_cosmic_rays_neg + num_found_cr_neg;
	    num_noise_spike = num_noise_spike + num_found_noise_spike_up + num_found_noise_spike_down;
	  }
	}

	if(control.do_verbose_time == 1) cout << " Finished Cosmic Ray check"<< endl;
    //_______________________________________________________________________
	// find slope - standard 
	pixel[ik].FindSegments();

// Find Slopes for each segment dn/read	

	int find_uncorrelated = 0;
	if(control.UncertaintyMethod == 0) pixel[ik].CalculateSlopeNoErrors(control.xdebug,control.ydebug);  
	if(control.UncertaintyMethod == 1) pixel[ik].CalculateSlope(control.gain,find_uncorrelated,
								    control.xdebug,control.ydebug);  
	if(control.UncertaintyMethod == 2) {
	  find_uncorrelated = 1; 
	  pixel[ik].CalculateSlope(control.gain,find_uncorrelated,
				   control.xdebug, control.ydebug);  
	} 

	pixel[ik].FinalSlope(control.slope_seg_cr_sigma_reject, 
			     control.n_frames_reject_after_cr,
			     control.cr_min_good_diffs,
			     control.write_detailed_cr,
			     control.UncertaintyMethod,
			     data_info.output_cr,
			     control.xdebug,control.ydebug);
	  //________________________________________________________________________________
	  //pull out the linearity corrected data and fill in lastframe_lin_co

	  int ilast2 = data_info.NRampsRead-2;
	  int ilast3 = ilast2 - 1;
	  float second_lastframe = 0;
	  float third_lastframe = 0;
	  pixel[ik].GetLast2Frames(ilast2,ilast3,second_lastframe,third_lastframe);
	  float this_lastframe= second_lastframe + (second_lastframe  - third_lastframe);
	  if(pix_x == 181 && pix_y == -161) {
	    cout << " Linearity corrected last frame is determined using " << 
	      ilast3+1 << " " << ilast2+1 << endl;
	    cout << "LASTFRAME "<< third_lastframe<< " " << second_lastframe << " " <<
	      this_lastframe << endl;
	  }
	  lastframe_lincor[pixel_index] = this_lastframe;
	  
	  //________________________________________________________________________________
	int nseg = pixel[ik].GetNumGoodSegments();

	if(nseg >= 3 && control.do_verbose) cout << " number segments = " << nseg << " " <<   
					      pixel[ik].GetX() << " " << pixel[ik].GetY()<< endl;

	if(nseg > data_info.Max_Num_Segments)data_info.Max_Num_Segments = nseg;
	pixel[ik].CalculatePixelFlag(); // update this as needed


	if(control.do_cr_id || control.write_detailed_cr == 1){
	  int numgoodseg = pixel[ik].GetNumGoodSegments();
	  vector<int> flags;
	  int nflags = 0;
	  if(numgoodseg > 1) {
	    int flag_pos  = 0;
	    int flag_neg = 0;
          
	    flags = pixel[ik].GetFlags(flag_pos,flag_neg);
	    nflags = flags.size();
          // a pixel may have more than 1 cosmic ray hit
	    if(flag_pos !=0 ) num_cr_seg++;
	    if(flag_neg !=0 ) num_cr_seg_neg++;
	  }
      //_______________________________________________________________________
	  if(control.write_detailed_cr == 1 ) {
	    int numseg = pixel[ik].GetNumSegments();      
	    if(numgoodseg > 1) {
	      int x = pixel[ik].GetX();
	      int y = pixel[ik].GetY();
	      
	      data_info.output_cr << " " << endl;
	      data_info.output_cr << " Cosmic Ray x,y:  " << x << " " << y << " # of segments: " << numgoodseg <<  endl;
	      data_info.output_cr << " Flags : " ;
	      for (int p = 0; p< nflags; p++) data_info.output_cr << flags[p] << " "  ;
	      data_info.output_cr << " " << endl;
	      for (int jk = 0; jk< numseg ; jk++){
		int seg_begin = pixel[ik].GetBeginSeg(jk);
		int seg_end = pixel[ik].GetEndSeg(jk);
		int seg_flag = pixel[ik].GetFlagSeg(jk);
		float seg_slope = pixel[ik].GetSlopeSeg(jk);
		
		float seg_unc = pixel[ik].GetSlopeSegUnc(jk);
		float seg_y_intercept = pixel[ik].GetYIntSeg(jk);
		float seg_dn_jump = pixel[ik].GetDnJumpSeg(jk);
		data_info.output_cr <<"Begin Segment, End Segment, Slope, Unc, Y-intercept, DN-Jump, Seg Flag: " <<
		  seg_begin << " " << seg_end << " " << seg_slope << " " << seg_unc << 
		  "  " << seg_y_intercept<< " " << seg_dn_jump << " " << seg_flag << endl;
	      }
	    }//numgoodseg > 1
	  } // end write detailed cr
	}// do_cr_id or write_detailed_cr

	pixel[ik].Convert2DNperSec(data_info.frame_time_to_use); // dn/read * read/seconds
	if(control.convert_to_electrons_per_second ==1) 
	  pixel[ik].Convert2ElectronperSec(control.gain); 
      } // end process_flag =1
      //***********************************************************************

      float signal = pixel[ik].GetSignal();
      float signal_unc = pixel[ik].GetSignalUnc();
      float id = float(pixel[ik].GetQualityFlag());
      float rms_data = pixel[ik].GetRMS();

      float zeropt = pixel[ik].GetZeroPt();
      float numgood = pixel[ik].GetNumGood();
      float numgoodseg = pixel[ik].GetNumGoodSegments();
      float readnumfirstsat = pixel[ik].GetReadNumFirstSat();

      if(signal == NO_SLOPE_FOUND ) {
	signal = strtod("NaN",NULL);
	signal_unc = strtod("NaN",NULL);
	zeropt = strtod("NaN",NULL);
	readnumfirstsat = strtod("NaN",NULL);
	numgood = 0.0;
	numgoodseg = 0.0;
	rms_data = strtod("NaN",NULL);
	max2ptdiff = strtod("NaN",NULL);
	imax2ptdiff = strtod("NaN",NULL);
	stddev2ptdiff = strtod("NaN",NULL);
	slope2ptdiff = strtod("NaN",NULL);
      }


      Slope.push_back(signal);
      SlopeUnc.push_back(signal_unc);
      SlopeID.push_back(id);
      ZeroPt.push_back(zeropt);
      NumGood.push_back(numgood);
      NumGoodSeg.push_back(numgoodseg);

      ReadNumFirstSat.push_back(readnumfirstsat);
      RMS.push_back(rms_data);
      if(control.do_diagnostic) {
	Max2ptDiff.push_back(max2ptdiff);
	IMax2ptDiff.push_back(imax2ptdiff);
	StdDev2pt.push_back(stddev2ptdiff);
	Slope2ptDiff.push_back(slope2ptdiff);
      }



    } // end loop over x values
    mrow++;
    if(mrow>3) mrow = 0;
      

  } //end loop over y values


  data_info.total_cosmic_rays = data_info.total_cosmic_rays + num_cosmic_rays;
  data_info.total_noise_spike = data_info.total_noise_spike + num_noise_spike;

  data_info.total_cosmic_rays_neg = data_info.total_cosmic_rays_neg + num_cosmic_rays_neg;

  data_info.num_cr_seg = data_info.num_cr_seg + num_cr_seg;
  data_info.num_cr_seg_neg = data_info.num_cr_seg_neg + num_cr_seg_neg;


  time_t tp; 
  tp = time(NULL);
  if(control.do_verbose_time == 1) cout << " Total Elapsed time process " << tp - tr << endl;

  // ***********************************************************************


  if(control.do_verbose)   cout << " Done reading in data " <<endl;
}
