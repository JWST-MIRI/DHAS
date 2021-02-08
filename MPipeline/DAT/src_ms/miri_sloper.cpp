// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//      miri_sloper.cpp
//
// Purpose:
/**********************************************************************/
// miri_sloper.cpp The main program for Part 1 of the MIRI Team  DATA Analysis 
// Pipeline  (DHAS = Pipeline)
/// This software was modelled after the U of A MIPS team (DAT) pipeline,
// developed by Karl Gordon & James Muzerolle for reducing MIPS/SPITIZER data.
// Jane Morrison (U of A) modified it for the MIRI instrument.
// 
//  This software is being used during ground testing to help characterize the
//  array and help determine the best method to reduce the data. As a result this
//  software is in a state of flux.
//  
// This program processes a single MIRI exposure:  
//    This program can handle multiple integrations in an exposure, subarray
//    data, FAST mode, Slow mode, and  FAST Short mode (multiple integrations consisting
//    of single frames). For typical FAST and Slow mode data consisting
//    of multiple frames for an integration, the miri_sloper program
//    determines a slope for each pixel's frame values (samples up a ramp)  
//    while removing as much of the instrument signature as possible. 
//    
//    For FAST Short mode data (multiple integrations consisting of a single frame)
//    the data for each pixel is co-added. 

//   There are many command line options which change the processing. The user can 
//   get a list of by typing 'miri_sloper' on the command line.   // 	
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
//
//
// Arguments:
//   There are many command line options, which the user can get a list
//   of by typing 'miri_sloper' on the command line.  
//
//   Minimum arguments needed: miri_sloper filename 
//
// Result: 
//   See the DHAS web site: http://tiamat.as.arizona.edu/dhas/ for more details.
//   This program produces a reduced image in FITS extension format. The header of 
//   the FITS image contains an explanation of the processing options. Each
//   extension contains the results from 1 integration. If the exposure contains more
//   than 1 integration then the average results are found in the primary image. 
//   Primary Image: had 3 planes of data: reduced image (slope or coadded image), 
//   uncertainty plane, data quality flag. 
//   Image extensions for  Fast and Slow mode data:
//    plane 1 =  slope image (DN/s) 
//   plane 2: uncertainty (DN/s)                                             
//   plane 3: data flag (1 = Bad Pixel, 4 high/low global saturated        
//         see miri_constants.h for a complete up to date list             
//   plane 4: Zero Pt for first valid Frame (DN)                             
//   plane 5: # of good reads                                                
//   plane 6: read number of first saturated read (-1 if none)               
//   plane 7: number of good segments   
//   If the -d (diagnostic) flag is used the 5 additional planes are written:
//   plane 8: Empirical Uncertainty of fit, DN (Fitted pt-Data pt)
//   plane 9: maximum 2pt difference (DN)
//   plane 10: read number of maximum 2pt difference
//   planes 11: Standard Dev of 2pt differences
//   planes 12: Slope of 2pt differ                                   
//
//   For Fast-Short mode data only the first 6 planes are written to the output file. 
// History:
//
//	Written by Jane Morrison: version 1:  October, 2004
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/


#include <time.h>
#include <cstdlib> // EXIT_FAILURE   , EXIT_SUCCESS
#include "miri_sloper.h"


// written by Jane Morrison
// v1.0     - Oct 2004 - modified the MIPS DAT mips_sloper routine. 
// History of changes in journal & MIRI DHAS Website 
//
/**********************************************************************/
/**********************************************************************/


int main(int argc, char* argv[])

{
  // **********************************************************************
  // tell the user how to use the program if it was not called with enough
  // parameters

  if (argc < 2) {
    ms_usage();
    exit(EXIT_FAILURE);
  }

  // **********************************************************************
  // declare the structure which contains the information on how to control
  // the program - determined from the command line options
  // Defaults set in the preferences file.
  int status = 0; 
  time_t t0 ; 
  t0 = time(NULL);

  miri_control control;

  miri_preference  preference;
  // **********************************************************************
  // parse the commandline for all the joyous switches as well as the 
  // name of the FITS file to reduce

  ms_initialize_control(control);

  // read in the commandline options the user has set
  ms_parse_commandline(argc,argv,control);

  //  cout << " Control.subset_nrow " << control.subset_nrow << endl;
  // read in the preferences file containing the default values to use
  ms_read_preferences(control,preference);
  
  if(control.do_verbose == 1 )cout << " Done reading preferences file" << endl;
  // Override any variables read in from the preferences file if the user set 
  // them on the command line

  ms_update_control(control,preference);
  
  // **********************************************************************
  // open and parse the raw data FITS header to get the details of the data
  // and how it was taken

  miri_data_info data_info;

  ms_initialize_data_info(data_info);

  // define the file names to open and write (Slope LVL2 filename, other
  // output files if set by command line)

  ms_filenames(data_info,control);

  //_______________________________________________________________________
  // Loop over the files and read in the headers

  for (int II = 0; II < data_info.numFiles; II++){
    data_info.total_cosmic_rays = 0;
    data_info.total_noise_spike = 0;
    data_info.total_cosmic_rays_neg = 0;
    data_info.num_cr_seg = 0;
    data_info.num_cr_seg_neg = 0 ;

    data_info.this_file_num = II;

    ms_read_header(data_info,control);

    // if the data was taken in FAST Short Mode - so adjustments are made
    // to run with this pipeline
    ms_adjust_control(data_info,control);
    control.subtract_dark = control.apply_dark_cor; 

  // **********************************************************************
    // Read in the names of the CDP files for detector type 

    // If using it read in pixel saturation mask
    // If using it read in bad pixel mask
    // Determine the name of the dark calibration file. The darks 
    // are large so do not read in the entire dark now - save it and read it in stages
    // Determine reset filename, max ints and nplanes for reset correction
    // Detemine the lastframe filename

    miri_CDP  CDP;
    ms_setup_processing(control,data_info,preference,CDP);

    
    // Read in RSCD file 
    miri_rscd RSCD;
    if(control.apply_rscd_cor == 1) {
      ms_read_RSCD_file(data_info,control,CDP,RSCD); 
      cout << " going to read in RSCD first frame parameters" << endl;
      RSCD.SetFirstFrameParams();
    }

    // Read in MULT file 
    miri_mult MULT;
    if(control.apply_rscd_cor == 1 ) {
      ms_read_MULT_file(data_info,control,CDP,MULT); 
    }

    //_______________________________________________________________________   
    // set up the name of the linearity file and read it in
    long NL = data_info.ramp_naxes[0] * data_info.ramp_naxes[1];
    if(control.apply_lin_cor ==0) NL = 1; 
    vector<miri_lin> linearity(NL);
    if(control.apply_lin_cor == 1 ) {
      status = ms_read_linearity_file(data_info, control,CDP, linearity);
    }

  // **********************************************************************
  // output the details of the reduction
    ms_screen_info(control,data_info);							     

  // **********************************************************************
  // if the number of frames in an integration > frame_limit set in preferences file or on commandline
  // then we can not read the entire array in for all the frames in the
  // integration. We have to read a portion of the array at a time (but
  // all the frames for that portion)
    if(control.num_ignore >= data_info.NInt) {
      cout << " All the integrations are not used in Averaged Slope, you must use at least 1 integration " << endl;
      cout << " Run again do not set all the integrations to be ignored with the -i option " << endl;
      exit(-1);
    }


    if(data_info.NRamps > control.frame_limit && data_info.subarray_mode == 0) {
      data_info.subset_nrow = control.subset_nrow;
      //      cout << " Number of frames is: " << data_info.NRamps << 
      //	" (which is > frame limit: "  << control.frame_limit<< "). Data will be read in groups of rows. " << endl;
    } else {
      data_info.subset_nrow = data_info.ramp_naxes[1];
    }

    float num = float(data_info.ramp_naxes[1])/float(data_info.subset_nrow);
    int subset_number = int(num);
    float rem = num - (subset_number);
    //cout << " Subset Number " << subset_number << endl;

    if(rem > 0)  subset_number++;
    //cout << " Number of Rows to read in and process at one time: " << data_info.subset_nrow<<endl;

  // ***********************************************************************
     // use frame time in the header unless the user has set the frame time
     // Changing the frame time is an expert user situation.

    data_info.frame_time_to_use = data_info.GroupTime; 

    // set up the name of the output header and the primary header
    // This program also sets up the intermediate files 

    ms_write_reduced_header(control,preference.preference_filename_used,data_info,CDP);

    // If the option to write an ascii file of reference pixel corrections is used -
    // this program sets up the file
    ms_setup_output_files(control,data_info);

  // ***********************************************************************
    // Set up the Final data arrays. The program fills these values in 
    // pixel by pixel (groups of rows) and then moves on to the next set

    int refimage = 0; // are we working with the reference image slope
  
  // science data 
    int xsize = data_info.ramp_naxes[0];
    int ysize = data_info.ramp_naxes[1];
    long tsize = xsize*ysize;
    long tsize2 = tsize;
    if(control.QuickMethod ==1) tsize2 = 1; 

    vector<float> Final_Slope(tsize);
    vector<float> Final_SlopeUnc(tsize);
    vector<float> Final_ID(tsize2);
    vector<float> Final_RMS(tsize2);

  // reference image (5th channel) data
    int xr_size = data_info.ref_naxes[0];
    int yr_size = data_info.ref_naxes[1];
    long tr_size = xr_size*yr_size;
    if(control.write_output_refslope ==0) tr_size = 1;

    vector<float> Final_RefSlope(tr_size);
    vector<float> Final_RefSlopeUnc(tr_size);
    vector<float> Final_RefID(tr_size);
    vector<float> Final_RefRMS(tr_size);
    
    int Total_NFramesBad = 0; 

    long NLF = data_info.ramp_naxes[0] * data_info.ramp_naxes[1];
    vector<float> lastframe_rscd(NLF,0.0);
    vector<float> lastframe_rscd_sat(NLF,0.0);

    // the lastframe to use the rscd correction is filled in according to the how the correction is is applied
    // . -rx: extrapolated linearity correctede last frame using (second to last and third to last frames). 

    // _______________________________________________________________________
    // Starting New Integration
    // _______________________________________________________________________
    for (int i=0;i<data_info.NInt; i++){
      vector<float> lastframe_lincor(NLF,0.0);  // last frame of current integration (to be used in lastframe correction)

      data_info.Max_Num_Segments =0; // for each integration - zero out 

      if(data_info.NInt < 20) cout << " Working on data in integration # " << i+1 << endl;

    // 3 output data types
      vector<float> Slope;
      vector<float> SlopeUnc;
      vector<float> ID;
      vector<float> ZeroPt;
      vector<float> NumGood;
      vector<float> NumGoodSeg;
      vector<float> RMS;
      vector<float> Max2ptDiff;
      vector<float> IMax2ptDiff;
      vector<float> StdDev2ptDiff;
      vector<float> Slope2ptDiff;
      vector<float> ReadNumFirstSat;

      Slope.reserve(tsize);
      SlopeUnc.reserve(tsize2);
      ID.reserve(tsize2);
      ZeroPt.reserve(tsize);
      NumGood.reserve(tsize2);
      NumGoodSeg.reserve(tsize2);
      RMS.reserve(tsize);
      ReadNumFirstSat.reserve(tsize2);
      if(control.do_diagnostic) {
	Max2ptDiff.reserve(tsize);
	IMax2ptDiff.reserve(tsize);
	StdDev2ptDiff.reserve(tsize);
	Slope2ptDiff.reserve(tsize);
      }else {
	Max2ptDiff.reserve(1);
	IMax2ptDiff.reserve(1);
	StdDev2ptDiff.reserve(1);
	Slope2ptDiff.reserve(1);
      }

      //_______________________________________________________________________
    // Set up lastframe, lastframe_corr
    // Set up the data to be used in the RSCD correction
    // Two options:

      // -rx: rscd lastframe = extrapolated to last frame using 2nd and 3rd to last frames
      // -rc: rscd lastframe = corrected last frame (filled in after ms_read_process) 

      //long NSCD = data_info.ramp_naxes[0] * data_info.ramp_naxes[1];
      //if(control.apply_lastframe_cor ==0 && control.apply_rscd_cor == 0) NSCD = 1; 
      //vector<float> lastframe(NSCD,0.0);  // last frame of current integration (to be used in lastframe correction)
      //vector<float> lastframe_corr(NSCD,0.0); // corrected last frame

      //________________________________________________________________________________
      //if (control.apply_lastframe_cor ==1 ){
	// read in the last frame from current integration 
	//ms_read_frame_from_int(data_info,i,data_info.NRamps, lastframe);
	// set up the next image in the last frame file 
	//if(control.write_output_lastframe_correction ==1) {
      // int naxis_lf = 2;
      //	  long naxes_lf[2];
      //  int bitpix_lf =-32; 
      //  naxes_lf[0] = data_info.ramp_naxes[0];
      //  naxes_lf[1] = data_info.ramp_naxes[1];
      //  status = 0 ;
      //  fits_create_img(data_info.lastframe_file_ptr, bitpix_lf,naxis_lf,naxes_lf, &status);  
      //}
      //}
      //_______________________________________________________________________   
      // Read in Reset Frame Correction for integration
      // Determine the size of the reset correction
      long NR = data_info.ramp_naxes[0] * data_info.ramp_naxes[1];
      if(control.apply_reset_cor ==0) NR = 1; 
      vector<miri_reset> reset(NR);
      if(control.apply_reset_cor == 1 ) {
	ms_read_reset_file(i,control,data_info,CDP,reset);
      }
      
    // **********************************************************************
      vector<int> FrameBad;
      int NFramesBad = 0;
      for (int ib = 0; ib<data_info.NRampsRead; ib++){
	FrameBad.push_back(0);
      }
      if(control.ScreenFrames == 1) {
	int status = ms_ScreenFrames(i,control,data_info,FrameBad,NFramesBad);
	if(status !=0) cout << "Problem with Screening Frames " << status <<  endl;
      }

      // Reference correction class
      int NN = data_info.NRampsRead;
      if(control.do_refpixel_option ==0) NN = 1; 
      vector<miri_refcorrection> ref_correction(NN);


      // write segments out 
      long isegments = tsize;
      if (control.write_segment_output == 0) isegments = 1;
      vector<miri_segment> segment(isegments);      

    // **********************************************************************
      // reference pixel correction - Removed Options to use reference output
	  // If correcting the science data with border reference pixels, then read
	  // border reference pixels, dark and other needed reference data. 
	  // and calculate the correction factor  to apply
	  // to the data. Do this for all the frames in the integration. 


      if(control.do_refpixel_option !=0){
	if(data_info.subarray_mode ==1) {
	  cout << "******************************************************" << endl;
	  cout << "  You set using the reference pixels for subarray data" << endl;
	  cout << " This is experimental " << endl;
	  cout << "******************************************************" << endl;
	}

	    
	ms_find_refcorrection(i,control,data_info,CDP,
			      ref_correction);
      }

    // **********************************************************************
    // Science Image slope determination
    // **********************************************************************
    // read in the data and process data in subsets

      time_t ta; 
      ta = time(NULL);      
      if(control.do_verbose_time) cout << "Elapsed time after setting everthing up " << ta - t0 << endl;
  
      int subnum = 1;
      refimage = 0;

      
      for (int isubset = 0; isubset < subset_number ; isubset++){

	//  cout << " Working on subset # " << subnum  <<  " " << isubset << " " << subset_number << endl ;
	cout << " Working on subset # " << subnum   << " \r" ;
	cout.flush();

	int this_nrow = data_info.subset_nrow;
	int icheck = data_info.ramp_naxes[1] - isubset*data_info.subset_nrow;
	if(icheck < this_nrow) this_nrow = icheck;
	
	data_info.numpixels =data_info.ramp_naxes[0]*this_nrow;
	
	time_t tv; 
	tv = time(NULL);
	//***********************************************************************
	if(control.QuickMethod == 1) {
	  ms_QuickerSlope(i,isubset,this_nrow,
			  control,data_info,
			  Slope,
			  ZeroPt,
			  RMS);
	}  else{
	  
	//***********************************************************************
	  time_t ts; 
	  ts = time(NULL);	
	  if(control.do_verbose_time == 1) cout << " Time to Create pixel  " << ts - tv << endl;
	  vector<miri_pixel> pixel(data_info.numpixels);
	  // set up dark class
	  int ND = data_info.numpixels;
	  if(control.apply_dark_cor ==0) ND = 1; 
	  vector<miri_dark> dark(ND);

	  if(control.subtract_dark==1)ms_setup_dark(i,isubset,this_nrow,control,data_info,CDP,dark);

	  if(control.do_verbose == 1 )cout << " starting ms_read_process_data" << endl;
	  ms_read_process_data(i,isubset,this_nrow,refimage,
			       reset,
			       RSCD,
			       MULT,
			       //			       lastframe,
			       //			       lastframe_corr,
			       lastframe_rscd,
			       lastframe_rscd_sat,
			       lastframe_lincor,
			       dark,linearity,
			       control,data_info,CDP,FrameBad,NFramesBad,
			       pixel,ref_correction,
			       Slope,SlopeUnc,ID,
			       ZeroPt, NumGood, ReadNumFirstSat,NumGoodSeg,RMS,
			       Max2ptDiff,IMax2ptDiff,StdDev2ptDiff,Slope2ptDiff);
	    
	  time_t tp; 
	  tp = time(NULL);
	  if(control.do_verbose_time) cout << "Time to  Read/Process DATA " << tp - ts << endl;
	  if(control.do_verbose == 1 )cout << " end ms_read_process_data" << endl;
  // **********************************************************************
	// If set - write the intermediate ID FITS file
	  if(control.write_output_ids || control.write_output_refpixel_corrections ||
	     control.write_output_lc_correction || control.write_output_dark_correction ||
	     control.write_output_rscd_correction ||
	     control.write_output_reset_correction) {

	    if(control.do_verbose == 1 )cout << " starting write intermediate data" << endl;
	    ms_write_intermediate_data(control.write_output_refpixel_corrections,
				       control.write_output_ids,
				       control.write_output_lc_correction,
				       control.write_output_dark_correction,
				       control.subtract_dark,
				       control.write_output_reset_correction,
				       //				       control.write_output_lastframe_correction,
				       control.write_output_rscd_correction,
				       i,isubset,this_nrow,
				       control.n_reads_start_fit,
				       control.video_offset,
				       data_info,pixel);
	  }
	  if(control.do_verbose == 1 )cout << " done write intermediate data" << endl;
  // **********************************************************************
	  if(control.write_segment_output) {
	    ms_fillin_segments(isubset,this_nrow,control.n_reads_start_fit,
			       data_info,pixel,segment);
	  }

  // **********************************************************************
	}// end loop over doing full slope calulation QuickMethod == 0


	subnum++; 
      } // end loop over isubset

      // **********************************************************************
    // output the reduced and ancillary info to the FITS files

      time_t tb; 
      tb = time(NULL);
      if(control.do_verbose_time) cout << "Time  Elapsed to read/process all subsets: " << tb - ta <<   endl;
      //______________________________________________________________________
      // If applying rscd then determine the lastframe_rscd_sat- last frame using
      // the slope and zeropt to be used for the next integration
      if(data_info.NInt > 1) {
	long ik = 0; 
	for (long i = 0; i< data_info.ramp_naxes[1] ; i++){
	  for (long j = 0; j < data_info.ramp_naxes[0]; j++){
	    
	    lastframe_rscd_sat[ik] = ZeroPt[ik] + Slope[ik] * data_info.frame_time_to_use * float(data_info.NRamps);
	    if(i+1 == 161 and j+1 == -181) {
	      cout << "SLOPE RESULTS *******" << ZeroPt[ik] << " " << Slope[ik] << " " << data_info.frame_time_to_use <<
		" " << data_info.NRamps << " " << lastframe_rscd_sat[ik] << endl;
	    }
	    ik++;
	  } 
	}
      }

      ms_write_reduced_file(i,  // integration number
			    data_info,
			    control,
			    CDP,
			    preference.preference_filename_used,
			    NFramesBad,FrameBad,
      			    Slope,SlopeUnc,ID,ZeroPt,NumGood,ReadNumFirstSat,NumGoodSeg,
      			    RMS,Max2ptDiff,IMax2ptDiff,StdDev2ptDiff,Slope2ptDiff);

      // the Final slope is an average of all the slopes for the exposure.
      // One slope per integration. If there is only one integration then the
      // Final slope = Slope (first and only integration)

      ms_final_slope(i,
		     control,
		     data_info.NInt,
		     Slope,
		     SlopeUnc, 
		     ID,
		     Final_Slope,
		     Final_SlopeUnc,
		     Final_ID);

      if(control.do_cr_id) {
	cout << " Total number large noise spikes (+/-) in 2pt differences " << 
	  data_info.total_noise_spike << endl;

	cout << " Number of Cosmic rays found " << data_info.total_cosmic_rays << endl;
	cout << " Number of Cosmic rays (negative) found " << data_info.total_cosmic_rays_neg << endl;
      }

      if(control.write_segment_output == 1) {
	ms_write_segments(i,data_info,segment);
      }


      time_t tr; 
      tr = time(NULL);      
      // cout << "Elapsed time after writing files out: " << tr - ta <<  endl;

  // **********************************************************************
    // Reference Image slope determination
      // This is the 5th output. The Quick Look tool uses this data when displaying
      // the slope image by Channel - so by default it is produced. 
      // The processing for the reference image is the same as the science data
      // except if the option to subtract the reference image is used (that is of
      // course not used here or the data would = 0).

  // **********************************************************************
      if(control.write_output_refslope == 1) {
	cout << " " << endl;
	cout << " Working on reference image slopes" << endl;
	refimage = 1; // now we are working with the reference image slope

	int ref_subset_number = 1;
	int nrow = data_info.subset_nrow * 4;

	vector<float> RefSlope;
	vector<float> RefSlopeUnc;
	vector<float> RefID;

	vector<float> RefZeroPt;
	vector<float> RefNumGood;
	vector<float> RefReadNumFirstSat;
	vector<float> RefRMS;

	RefSlope.reserve(tr_size);
	RefSlopeUnc.reserve(tr_size);
	RefID.reserve(tr_size);
	RefZeroPt.reserve(tr_size);
	RefNumGood.reserve(tr_size);
	RefReadNumFirstSat.reserve(tr_size);
	RefRMS.reserve(tr_size);

	int nstop = data_info.raw_naxes[1] - data_info.ramp_naxes[1];

	if(subset_number > 1) {
	  if(nrow > nstop) nrow = nstop ;  //reference image only 256 rows (full image)
	  data_info.subset_ref_nrow = nrow;
			

	  float num = float(nstop)/float(nrow);
	  ref_subset_number =   int(num);
	  float rem = num - (ref_subset_number);

	  if(rem > 0)  ref_subset_number++;
	  cout << " Number of Reference Image Subsets " <<ref_subset_number <<  endl;
	}


	int rsubnum = 1;
	for (int isubset = 0; isubset < ref_subset_number ; isubset++){
	  cout << " Working on subset # " << rsubnum  << " \r" ;
	  cout.flush();
	  int this_nrow = nrow;
	  int icheck = nstop - isubset*nrow;
	  if(icheck < this_nrow) this_nrow = icheck;

	  data_info.ref_numpixels =data_info.ramp_naxes[0]*this_nrow; // 258 * 4  (ref pixels/row)
	
	  vector<miri_pixel> refpixel(data_info.ref_numpixels);
	  ms_read_refdata(i,isubset,this_nrow,
			  control.n_reads_start_fit,
			  control.dn_high_sat,
			  control.gain,
			  control.read_noise_electrons,
			  control.video_offset,
			  data_info,refpixel); 
  // **********************************************************************
	  // flag bad pixels- will there be bad pixels in reference output
          // if so then need to mark them not to be used in reducing the science data. 

  // **********************************************************************
	  // do not subtract the reference image (end up with zero) but
	 // allow correction for border reference pixels

	  if( control.do_refpixel_option !=0){
	    ms_subtract_refdata(i,isubset,this_nrow,refimage,
				control,data_info,refpixel,ref_correction);
	  }

 // **********************************************************************
	  ms_process_refimage_data(control, data_info,FrameBad, NFramesBad,refpixel,
				   RefSlope,RefSlopeUnc,RefID,RefZeroPt,RefNumGood,
				   RefReadNumFirstSat,RefRMS);

    // **********************************************************************
	  rsubnum++;
	} // end loop over isubset
  // **********************************************************************
    // output the reduced data

	//cout << " ms_write_reduced_refimage " << endl;
	ms_write_reduced_refimage(i,     // integration number
				  data_info,
				  control,CDP,
				  preference.preference_filename_used,
				  NFramesBad,FrameBad,
				  RefSlope,RefSlopeUnc,RefID,RefZeroPt,RefNumGood,
				  RefReadNumFirstSat,RefRMS);


	ms_final_slope(i,
		       control,
		       data_info.NInt,
		       RefSlope,
		       RefSlopeUnc, 
		       RefID,
		       Final_RefSlope,
		       Final_RefSlopeUnc,
		       Final_RefID);
	//cout << "done reference final slope " << endl;
	time_t t2; 
	t2 = time(NULL);
        cout << "Time to process & write reference output image ti " << t2 - tr<< endl;
      } // end if write output reference slope image

      //      cout << "going to next integration" << i << endl;


      Total_NFramesBad = Total_NFramesBad + NFramesBad; 
  // **********************************************************************
      //	if(control.rscd_lastframe_corrected ==1) {
      // copy(lastframe_corr.begin(), lastframe_corr.end(),lastframe_rscd.begin());
      //}
      copy(lastframe_lincor.begin(), lastframe_lincor.end(),lastframe_rscd.begin());

  // **********************************************************************
    }   // close the loop over the integrations

    ms_write_final_data(0,
			data_info.red_file_ptr,
			data_info.red_naxes,
			control.QuickMethod,
			data_info,Final_Slope,Final_SlopeUnc,Final_ID);
    int status = 0;
    int hdutype = 0;

    // update NFrames_Bad

    fits_movabs_hdu(data_info.red_file_ptr,1,&hdutype,&status);

    fits_update_key(data_info.red_file_ptr,TINT, "NCORRUPT", &Total_NFramesBad, "# Corrupt Frames in Exposure", &status);
    status = 0 ;
    fits_close_file(data_info.red_file_ptr, &status);

    // cout << " done writing final data " << endl;
    if(control.write_output_refslope) {
      ms_write_final_data(1,
			  data_info.red_ref_file_ptr,
			  data_info.red_ref_naxes,
			  control.QuickMethod,
			  data_info,Final_RefSlope,Final_RefSlopeUnc,Final_RefID);
      fits_close_file(data_info.red_ref_file_ptr, &status);
    }
    //cout << " ms_write_final_data " << endl;

  // **********************************************************************
  // close all open fits files

    if(control.write_output_refpixel_corrections){
      status = 0;
      fits_close_file(data_info.rc_file_ptr,&status);
      if(status !=0) cout << " problem closing reference corrected data " << endl;
    }

    if(control.write_output_ids == 1){
      status = 0;
      fits_close_file(data_info.id_file_ptr,&status);
      if(status !=0) cout << " problem closing ID data " << endl;
    }

    if(control.write_output_lc_correction == 1){
      status = 0;
      fits_close_file(data_info.lc_file_ptr,&status);
      if(status !=0) cout << " problem closing Linearity Corrected data " << endl;
    }

    if(control.write_output_dark_correction == 1 && control.subtract_dark == 1){
      status = 0;
      fits_close_file(data_info.dark_file_ptr,&status);
      if(status !=0) cout << " problem closing Mean Dark Corrected data " << endl;
    }


    if(control.write_output_rscd_correction == 1){
      status = 0;
      fits_close_file(data_info.rscd_file_ptr,&status);
      if(status !=0) cout << " problem closing Rscd Corrected data " << endl;
    }

    if(control.write_output_reset_correction == 1){
      status = 0;
      fits_close_file(data_info.reset_file_ptr,&status);
      if(status !=0) cout << " problem closing Reset Corrected data " << endl;
    }

    if(control.write_output_lastframe_correction == 1){
      status = 0;
      fits_close_file(data_info.lastframe_file_ptr,&status);
      if(status !=0) cout << " problem closing last frame Corrected data " << endl;
    }

    if(control.write_segment_output == 1){
      status = 0;
      fits_close_file(data_info.sg_file_ptr,&status);
      if(status !=0) cout << " problem closing Segment data " << endl;
    }
    if(control.write_output_refpixel) data_info.output_rp.close();
    if(control.write_detailed_cr) data_info.output_cr.close();

  // If running fast short mode and running over a list - need to set back values that were changed
    ms_adjust_control_end(data_info, control);

    status = 0;
    fits_close_file(data_info.raw_file_ptr,&status);
    if(status !=0) cout << " problem data" << endl;

  } // end loop over files 
  time_t t1; 
  t1 = time(NULL);

  cout << " " << endl;
  cout << " Done miri_sloper" << endl;
  cout << "Total time " << t1 - t0 << endl;


  return 0;


  // **********************************************************************


}
