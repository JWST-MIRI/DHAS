// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//  ms_write_processing_to_header.cpp
//
// Purpose:
// 	Write all the processing parameters to the header of the reduced FITS file. 
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
//void ms_write_processing_to_header(fitsfile *file_ptr,
//				   int itype,
//				   miri_control control,
//				   string preference_filename,
//				   miri_data_info& data_info,
//				   int primary) // is this the primary header
//
//
// Arugments:
//  file_ptr: pointer to the reduced file
//  itype a flag, 0 = science data, 1 = reference output data. 
//  control: miri_control structure containing the processing options
//  preference_filename: name of the preference file used 
//  data_info: miri_data_info structure containing basic information on the dataset
//  primary : flag 1 = writing to the primary header. (averaged FINAl image)
//
// Return Value/ Variables modified:
//      No return value.  
// 
//
// History:
//
//	Written by Jane Morrison 2006
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/

#include <iostream>
#include <stdio.h>
#include <string.h>
#include <cstring>
#include "fitsio.h"
#include "miri_sloper.h"
#include "dhas_version.h"
#include "miri_constants.h"


// open and setup the header for the reduced FITS file: control.raw_bitsbase + ".LVL2.fits";
// Write all the options that were used in processing the data

void ms_write_processing_to_header(fitsfile *file_ptr,
				   const int intnum,
				   int itype,  // flag 0 - science data, 1 ref data
				   miri_control control,
				   int NFramesBad,
				   vector<int> FrameBad,
				   string preference_filename,
				   miri_data_info& data_info,
				   miri_CDP CDP,
				   int primary) // is this the primary header

{

  char yes_str[4] = "Yes"; // string for the yes answer
  char no_str[3] = "No";   // string for the no answer

  char version[strlen(dhas_version)+1];
  strcpy(version,dhas_version);
  int status = 0;

  fits_write_comment(file_ptr, 
		     "**==============================================================**",&status);

  fits_write_comment(file_ptr, "**--------------------------------------------------------------**",&status);
  fits_write_comment(file_ptr, "file created by miri_sloper program",&status);
  fits_write_comment(file_ptr, "MIRI Team Pipeline",&status);
  fits_write_comment(file_ptr, "Jane Morrison",&status);
  fits_write_comment(file_ptr, "email morrison@as.arizona.edu for info",&status);
  fits_write_comment(file_ptr, "**--------------------------------------------------------------**",&status);

  //_______________________________________________________________________

  if(control.QuickMethod ==1) { 

    fits_write_comment(file_ptr, "plane 1: Average signal (DN/Frame)",&status);
    if(primary == 0) {
      fits_write_comment(file_ptr, "plane 2: Zero Pt for first valid Frame (DN) ",&status);
    } 

    //***********************************************************************
  } else  if(control.do_Pulse_Mode ==1) { 

    fits_write_comment(file_ptr, "Image: Amplitude for Frame f - Frame i",&status);
    fits_write_comment(file_ptr, "Units of Image: DN ",&status);
    fits_write_key(file_ptr, TINT, "FRAMEI", &control.Pulse_Frame_i, 
		   " Frame i for pulse mode (Amp = Frame f - frame i)", &status);
    fits_write_key(file_ptr, TINT, "FRAMEF", &control.Pulse_Frame_f, 
		   " Frame f for pulse mode (Amp = Frame f - frame i)", &status);


  }else { // Full Slope determination + other 6 planes of information
    //***********************************************************************
      if(data_info.Mode ==2 ) { // Fast Mode Short
	fits_write_comment(file_ptr, "plane 1: Average signal (DN/Frame)",&status);
	fits_write_comment(file_ptr, "plane 2: uncertainty (DN/Frame)",&status);
	fits_write_comment(file_ptr, "plane 3: data quality flag ",&status);

	int dq_0 = BAD_PIXEL_ID;
	fits_write_key(file_ptr, TINT, "DQ_0", &dq_0, "Bad Pixel", &status);
	int dq_1 = HIGHSAT_ID;
	fits_write_key(file_ptr, TINT, "DQ_1", &dq_1, "Saturated Data", &status);
	int dq_2 = COSMICRAY_ID;
	fits_write_key(file_ptr, TINT, "DQ_2", &dq_2, "Cosmic Ray Detected ", &status);
	int dq_3 = NOISE_SPIKE_DOWN_ID;
	fits_write_key(file_ptr, TINT, "DQ_3", &dq_3, " Noise Spike ", &status);
	int dq_4 = COSMICRAY_NEG_ID;
	fits_write_key(file_ptr, TINT, "DQ_4", &dq_4, " Negative Cosmic Ray Detected", &status);

	int dq_6 = UNRELIABLE_DARK;
	fits_write_key(file_ptr, TINT, "DQ_6", &dq_6, " Unrealible Dark Correction", &status);
	int dq_7 = UNRELIABLE_LIN;
	fits_write_key(file_ptr, TINT, "DQ_7", &dq_7, " Unreliable  Linearity Correction", &status);
	//	int dq_8 = LINRANGE;
	//fits_write_key(file_ptr, TINT, "DQ_8", &dq_8, " Linearity Out of Range", &status);

	int dq_8 = NOLASTFRAME;
	fits_write_key(file_ptr, TINT, "DQ_9", &dq_8, " No Last Frame Correction", &status);

	if(primary == 0) {
	  fits_write_comment(file_ptr, "plane 4: NA for Fast Short Mode ",&status);
	  fits_write_comment(file_ptr, "plane 5: # of good reads",&status);
	  fits_write_comment(file_ptr, "plane 6: read number of first saturated read (-1 if none)",&status);
	}


  //_______________________________________________________________________
    }else{ // Fast Mode or Slow Mode
      fits_write_comment(file_ptr, "Reduced Data",&status);
      if(control.convert_to_electrons_per_second ==0) {
	fits_write_comment(file_ptr, "plane 1: signal (DN/s)",&status);
	fits_write_comment(file_ptr, "plane 2: uncertainty (DN/s)",&status);

      }else{
	fits_write_comment(file_ptr, "plane 1: signal (e/s)",&status);
	fits_write_comment(file_ptr, "plane 2: uncertainty (e/s)",&status);
      }
      
      fits_write_comment(file_ptr, "plane 3: data quality flag ",&status);
      
	int dq_0 = BAD_PIXEL_ID;
	fits_write_key(file_ptr, TINT, "DQ_0", &dq_0, "Bad Pixel", &status);
	int dq_1 = HIGHSAT_ID;
	fits_write_key(file_ptr, TINT, "DQ_1", &dq_1, "Saturated Data", &status);
	int dq_2 = COSMICRAY_ID;
	fits_write_key(file_ptr, TINT, "DQ_2", &dq_2, "Cosmic Ray Detected ", &status);
	int dq_3 = NOISE_SPIKE_DOWN_ID;
	fits_write_key(file_ptr, TINT, "DQ_3", &dq_3, " Noise Spike ", &status);
	int dq_4 = COSMICRAY_NEG_ID;
	fits_write_key(file_ptr, TINT, "DQ_4", &dq_4, " Negative Cosmic Ray Detected", &status);

	int dq_6 = UNRELIABLE_DARK;
	fits_write_key(file_ptr, TINT, "DQ_6", &dq_6, " Unreliable Dark Correction", &status);
	int dq_7 = UNRELIABLE_LIN;
	fits_write_key(file_ptr, TINT, "DQ_7", &dq_7, " Unreliable Linearity Correction", &status);
	//	int dq_8 = LINRANGE;
	//fits_write_key(file_ptr, TINT, "DQ_8", &dq_8, " Linearity Out of Range", &status);

	int dq_8 = NOLASTFRAME;
	fits_write_key(file_ptr, TINT, "DQ_8", &dq_8, " No Last Frame Correction", &status);


      if(primary == 0) {
	fits_write_comment(file_ptr, "plane 4: Zero Pt for first valid Frame (DN) ",&status);
	fits_write_comment(file_ptr, "plane 5: # of good reads",&status);
	fits_write_comment(file_ptr, "plane 6: read number of first saturated read (-1 if none)",&status);
	fits_write_comment(file_ptr, "plane 7: number of good segments",&status);
	;if(itype == 1) fits_write_comment(file_ptr, "plane 7: Empirical Uncertainty, DN (Fitted pt-Data pt",&status);
	fits_write_comment(file_ptr, "plane 8: Standard Dev of fit, DN (Fitted pt-Data pt)",&status);
  
	if (control.do_diagnostic && itype == 0) {

	  fits_write_comment(file_ptr, "plane 9: maximum 2pt difference (DN)",&status);
	  fits_write_comment(file_ptr, "plane 10: read number of maximum 2pt difference",&status);
	  fits_write_comment(file_ptr, "planes 11: Standard Dev of 2pt differences",&status);
	  fits_write_comment(file_ptr, "planes 12: Slope of 2pt differences",&status);
	}
      }
    }
  }
  // _______________________________________________________________________
  // Processing Common to All modes
  fits_write_comment(file_ptr, "**--------------------------------------------------------------**",&status)  ;
  fits_write_comment(file_ptr, "**-miri_sloper processing info----------------------------------**",&status);
  
  char array_type_char_string[MAX_FILENAME_LENGTH];  // necessary as fits_write_key does not support C++ strings
  ostrstream array_type_stream(array_type_char_string,MAX_FILENAME_LENGTH);
  
  int SET1 = 1;
  fits_write_key(file_ptr, TSTRING, "MS_VER", &version, "miri_sloper version", &status);
  if(itype == 0) fits_write_key(file_ptr, TINT, "REDUCED", &SET1, " This file contains the reduced data", &status);
  if(itype == 1) fits_write_key(file_ptr, TINT, "REDUCEDO", &SET1, " This file contains the reduced ref output data", &status);
    //_______________________________________________________________________
    //convert from a string class to character string
    // see page 957 How to Program in c++ (Deitel and Deitel)
  int len = control.miri_dir.length();
  char *ptr1 = new char[len+1];
  control.miri_dir.copy(ptr1,len,0);
  ptr1[len] = 0;

  status = 0 ;
  fits_write_key(file_ptr, TSTRING, "MIRI_DIR", ptr1, "Default Preferences Location", &status);
  if(status !=0) cout << " Problem MIRI_DIR" << status << " " << control.miri_dir << endl;
  delete [] ptr1;


  len = preference_filename.length();
  char *ptr = new char[len+1];
  preference_filename.copy(ptr,len,0);
  ptr[len] = 0;

  status = 0 ;
  fits_write_key(file_ptr, TSTRING, "PREFFILE", ptr, "Preferences Filename Used", &status);
  if(status !=0) cout << " Problem writing Preferences Filename " << status << " " << preference_filename << endl;
  delete [] ptr;
    
  len = control.calib_dir.length();
  char *ptr4 = new char[len+1];
  control.calib_dir.copy(ptr4,len,0);
  ptr4[len] = 0;

  status = 0 ;
  fits_write_key(file_ptr, TSTRING, "CALIDIR", ptr4, "Calibration Directory", &status);
  if(status !=0) cout << " Problem writing calibration directory " << status << " " <<
    control.calib_dir<< endl;
  delete [] ptr4;


  // 
  // ***********************************************************************
  if(control.do_Pulse_Mode ==1) { return;}

  // ***********************************************************************
  if(data_info.Mode ==2) {

    int sunit = 3;
    fits_write_key(file_ptr,TINT,"SUNITS",&sunit," Units of Reduced image DN/Frame ",&status);
    fits_write_key(file_ptr, TFLOAT, "FRMTIME", &data_info.frame_time_to_use, "Time to read Frame in seconds)", &status);

    fits_write_key(file_ptr, TINT, "NPINT", &data_info.NRamps,
		   "Number of Integrations Processed", &status);

    fits_write_key(file_ptr, TINT, "NPGROUP", &data_info.NInt,
		   "Number of Frames/Int- ", &status);

    
    int istart = control.n_reads_start_fit + 1;
  
    fits_write_key(file_ptr, TINT, "NSFITS", &istart, 
		   " Starting Integration number to co-add", &status);

    int iend = control.n_reads_end_fit + 1;
    fits_write_key(file_ptr, TINT, "NSFITE", &iend, 
		   " Ending Integration number to co-add", &status);

    fits_write_key(file_ptr, TSTRING, "COADD", yes_str, 
		   "Data Averaged: no slope determination", &status);

    } else {

  
    //_______________________________________________________________________

    if(control.convert_to_electrons_per_second == 0 ) {
      int sunit = 1;
      fits_write_key(file_ptr,TINT,"SUNITS",&sunit," Units of Reduced image DN/s ",&status);
    } else{
      int sunit = 2;
      fits_write_key(file_ptr,TINT,"SUNITS",&sunit," Units of Reduced image e/s",&status);
    }
    if(control.UncertaintyMethod > 0) {
        fits_write_key(file_ptr, TFLOAT, "GAIN", &control.gain, "Gain used (e/DN)", &status);
       fits_write_key(file_ptr, TFLOAT, "RNOISE", &control.read_noise_electrons, "Read Noise used (electrons)", &status);
    }
    fits_write_key(file_ptr, TFLOAT, "FRMTIME", &data_info.frame_time_to_use, "Time to read Frame in seconds)", &status);
    
    if(control.UncertaintyMethod ==0)  fits_write_key(file_ptr, TSTRING, "UNCER_N", yes_str, 
		   "Uncertainty of measurements = 1", &status);

    if(control.UncertaintyMethod ==1)  fits_write_key(file_ptr, TSTRING, "UNCER_U", yes_str, 
		   "Used uncertainty of measurements in slope determination", &status);

    if(control.UncertaintyMethod ==2)  fits_write_key(file_ptr, TSTRING, "UNCER_C", yes_str, 
		   "Correlated uncertainties used to calculate slope error", &status);



    fits_write_key(file_ptr, TINT, "NPINT", &data_info.NInt,
		   "Number of Integrations Processed", &status);


    int int_use = data_info.NInt - control.num_ignore;
    
    fits_write_key(file_ptr,TINT,"NINTAVE",&int_use,"Number Integrations used for Ave Slope,Primary",&status);


    // write if the integration was used in calculating the Average Slope

    if(primary ==0) {

      int use = 1;
      if(control.num_ignore > 0) {
	int found = 0;
	int iv = 0;
	while(found ==0 && iv < control.num_ignore ){
	  if( (intnum+1) == control.ignore_int[iv]) found = 1;
	  iv++;
	}
	if(found ==1) use = 0;
      }
      if(use == 1){
	fits_write_key(file_ptr, TINT, "USEINT", &use,
		       " 1 = This int used in Average Slope in Primary", &status);
      } else {
	fits_write_key(file_ptr, TINT, "USEINT", &use,
		       " 0 = This int NOT used in Average Slope in Primary", &status);
      }
    }
    //_______________________________________________________________________
      

    fits_write_key(file_ptr, TINT, "NPGROUP", &data_info.NRamps,
		   "Number of Frames/Int- ", &status);

    int istart = control.n_reads_start_fit + 1;
  
    fits_write_key(file_ptr, TINT, "NSFITS", &istart, 
		   "Frame number to start slope fit", &status);




    int iend = control.n_reads_end_fit + 1;
    fits_write_key(file_ptr, TINT, "NSFITE", &iend, 
		   "Frame number to end slope fit", &status);
    
  }


  //Back to common Processing  

  //  if(NFramesBad !=0) {
    if(primary ==1) {
      fits_write_key(file_ptr, TINT, "NCORRUPT", &NFramesBad, "# Corrupt Frames in Exposure", &status);
    } else{
      fits_write_key(file_ptr, TINT, "NCORRUPT", &NFramesBad, "# Corrupt Frames in Integration", &status);

    }
    //}


  if (control.do_refpixel_option ==0)
    fits_write_key(file_ptr, TSTRING, "SUBRP0", no_str, 
		   "Did not use reference pixels to correct data", &status);

  if(control.do_refpixel_option !=0){
    fits_write_key(file_ptr, TINT, "RFREJFS", &control.refpixel_filter_size, 
		   "Ref Pixel Outlier Reject Filter Size Window", &status);

    fits_write_key(file_ptr, TFLOAT, "RFREJSG", &control.refpixel_sigma_clip, 
		   "Ref Pixel Outlier Reject Sigma ", &status);
  }

  if (control.do_refpixel_option ==2){
    fits_write_key(file_ptr, TSTRING, "SUBRP2", yes_str, 
		   "Used Ref Pixels using option 2", &status);

    fits_write_key(file_ptr, TINT, "DELTARP", &control.delta_refpixel_even_odd,
		   "# of +/- Rows (even/odd) used to find Ref Pixel correction, option 2", &status);

  }

  
  if (control.do_refpixel_option ==1){
    fits_write_key(file_ptr, TSTRING, "SUBRP1", yes_str, 
		   "Used Ref Pixels using option 1", &status);

    fits_write_key(file_ptr, TINT, "DELFILT", &control.delta_refpixel_even_odd,
		   " size of moving filter", &status);

  }

  
  if (control.do_refpixel_option ==7)
    fits_write_key(file_ptr, TSTRING, "SUBRP7", yes_str, 
		   "Used Ref Pixels using option 7", &status);

  if (control.do_refpixel_option ==6)
    fits_write_key(file_ptr, TSTRING, "SUBRP6", yes_str, 
		   "used Ref Pixels using option 6", &status);


  if(control.write_output_refpixel_corrections ==1)
    fits_write_key(file_ptr, TSTRING, "WREFPIXC", yes_str, 
		   "Wrote reference pixel correction FITS file", &status);


  
  fits_write_key(file_ptr, TFLOAT, "HIGHSAT", &control.dn_high_sat, "High Saturation Value", &status);
  
  if(control.do_cr_id == 1) {
    fits_write_key(file_ptr, TINT, "NFREJCR", &control.n_frames_reject_after_cr,
		   "Number of frames rejected after any cosmic ray", &status);
    fits_write_key(file_ptr, TFLOAT, "CRSTDEV", &control.cr_sigma_reject, 
		   "# of std dev for cosmic ray identification", &status);
    fits_write_key(file_ptr, TINT, "CRMNGOOD", &control.cr_min_good_diffs, 
		   "# 2pt differences needed  cosmic ray identification", &status);

    fits_write_key(file_ptr, TFLOAT, "CRNL", &control.cosmic_ray_noise_level,
		   "Cosmic Ray Noise Min Level", &status);

    fits_write_key(file_ptr, TFLOAT, "SS_STDEV", &control.slope_seg_cr_sigma_reject, 
		   "# of std dev for cosmic ray slope segment rejection", &status);

    fits_write_key(file_ptr, TFLOAT, "CRMAXI", &control.max_iterations_cr, 
		   "# of std dev for cosmic ray slope segment rejection", &status);

    if(primary ==0) { // only write results of processing after processing is done. 
 
      fits_write_key(file_ptr, TLONG, "NCR", &data_info.total_cosmic_rays, 
		     "# of cosmic rays detected ", &status);
      
      fits_write_key(file_ptr, TLONG, "NNOISESP", &data_info.total_noise_spike, 
		     "# of large noise spikes detectect (postive & negative)", &status);
      
      fits_write_key(file_ptr, TLONG, "NNOISEDW", &data_info.total_cosmic_rays_neg, 
		     "# of large negative jump that stay down (look like neg cr)", &status);
      
      fits_write_key(file_ptr, TLONG, "NSEGGT1", &data_info.num_cr_seg, 
		     "# number of segments gt 1", &status);
    }

    if(control.write_detailed_cr ==1)
      fits_write_key(file_ptr, TSTRING, "WDETCR", yes_str, 
		     "Wrote detailed cosmic ray information to file", &status);
  }
  


  if(control.write_output_ids ==1)
    fits_write_key(file_ptr, TSTRING, "WID", yes_str, 
		     "Wrote ID flags for each frame", &status);

  if(control.write_output_dark_correction ==1 && control.subtract_dark == 1)
    fits_write_key(file_ptr, TSTRING, "WMDC", yes_str, 
		     "Wrote Mean Dark Corrected data", &status);


  if(control.write_output_rscd_correction ==1)
    fits_write_key(file_ptr, TSTRING, "WRSCD", yes_str, 
		     "Wrote RSCD Corrected data", &status);

  if(control.write_output_reset_correction ==1)
    fits_write_key(file_ptr, TSTRING, "WRESET", yes_str, 
		     "Wrote Reset Corrected data", &status);

  if(control.write_output_lastframe_correction ==1)
    fits_write_key(file_ptr, TSTRING, "WLASTF", yes_str, 
		     "Wrote Last Frame Corrected data", &status);

  if(control.write_segment_output ==1)
    fits_write_key(file_ptr, TSTRING, "WSGOUT", yes_str,  
		   "Wrote Slope Segment Results to FITS file", &status);


  if(control.write_output_lc_correction==1)
    fits_write_key(file_ptr, TSTRING, "WLINC", yes_str, 
		     "Wrote Linearity Corrected Data", &status);
  //_______________________________________________________________________

  if (control.apply_badpix ==1){
    fits_write_key(file_ptr, TSTRING, "RMBADPIX", yes_str, " Set Bad Pixels to NaN ?", &status);

    string badfile = control.badpix_file;
    string bfile = badfile; 
    //    unsigned int dir = badfile.find_last_of("/");
    size_t dir = badfile.find_last_of("/");
    if (dir != string::npos) {
      bfile = badfile.substr(dir+1,badfile.size());
    }
    
    len = bfile.length();
    char *ptr2 = new char[len+1];
    bfile.copy(ptr2,len,0);
    ptr2[len] = 0;
    status = 0 ;
    long num_bad = CDP.GetNumBadPixels(); 
    fits_write_key(file_ptr, TSTRING, "BADPFILE", ptr2, "Bad Pixel File", &status);
    delete [] ptr2;
    fits_write_key(file_ptr, TLONG, "NBAD", &num_bad, " # Bad Pixels read in from  File", &status);
  }else{
    fits_write_key(file_ptr, TSTRING, "RMBADPIX", no_str, " Set Bad Pixels to NaN?", &status);
  }

  //_______________________________________________________________________
  if(control.apply_pixel_saturation ==1){
    fits_write_key(file_ptr, TSTRING, "USE_PSM", yes_str, "Used Pixel Saturation Mask", &status);
    
    string pixelfile = control.pixel_saturation_file;
    string pfile = pixelfile; 
    //    unsigned int dir = pixelfile.find_last_of("/");
    size_t dir = pixelfile.find_last_of("/");
    if (dir != string::npos) {
      pfile = pixelfile.substr(dir+1,pixelfile.size());
    }


    len = pfile.length();
    char *ptr3 = new char[len+1];
    pfile.copy(ptr3,len,0);
    ptr3[len] = 0;
    status = 0 ;
    fits_write_key(file_ptr, TSTRING, "PSM", ptr3, "Pixel Saturation Mask", &status);
    delete [] ptr3;
  }else{
    fits_write_key(file_ptr, TSTRING, "USE_PSM", no_str, "Did Not Use Pixel Saturation Mask?", &status);
  }


//_______________________________________________________________________
  if(control.apply_reset_cor ==1){
    fits_write_key(file_ptr, TSTRING, "USE_RES", yes_str, "Used Reset Correction File", &status);
    
    string resetfile = CDP.GetResetUseName();
    string rfile = resetfile;

    size_t dir = resetfile.find_last_of("/");
    if (dir != string::npos) {
      rfile = resetfile.substr(dir+1,resetfile.size());
    }

    len = rfile.length();
    char *ptr3 = new char[len+1];
    rfile.copy(ptr3,len,0);
    ptr3[len] = 0;
    status = 0 ;
    fits_write_key(file_ptr, TSTRING, "RESET", ptr3, "Reset Correction File", &status);
    delete [] ptr3;
  }else{
    fits_write_key(file_ptr, TSTRING, "USE_RES", no_str, "Did Not Use Reset Correction File", &status);
  }



  //_______________________________________________________________________
  if(control.apply_rscd_cor ==1){
    fits_write_key(file_ptr, TSTRING, "USE_RSCD", yes_str, "Used RSCD Correction File", &status);
    
    string rscdfile = CDP.GetRSCDName();
    string rfile = rscdfile;

    size_t dir = rscdfile.find_last_of("/");
    if (dir != string::npos) {
      rfile = rscdfile.substr(dir+1,rscdfile.size());
    }

    len = rfile.length();
    char *ptr3 = new char[len+1];
    rfile.copy(ptr3,len,0);
    ptr3[len] = 0;
    status = 0 ;
    fits_write_key(file_ptr, TSTRING, "RSCD", ptr3, "RSCD Correction File", &status);
    delete [] ptr3;
  }else{
    fits_write_key(file_ptr, TSTRING, "USE_RSCD", no_str, "Did Not Use RSCD Correction File", &status);
  }
  //_______________________________________________________________________

  //_______________________________________________________________________
  if(control.apply_lastframe_cor ==1){
    fits_write_key(file_ptr, TSTRING, "USE_LAST", yes_str, "Used Last Frame Correction File", &status);
    
    string lastframefile = CDP.GetLastFrameName();
    string rfile = lastframefile;

    size_t dir = lastframefile.find_last_of("/");
    if (dir != string::npos) {
      rfile = lastframefile.substr(dir+1,lastframefile.size());
    }

    len = rfile.length();
    char *ptr3 = new char[len+1];
    rfile.copy(ptr3,len,0);
    ptr3[len] = 0;
    status = 0 ;
    fits_write_key(file_ptr, TSTRING, "LASTFR", ptr3, "Lastframe Correction File", &status);
    delete [] ptr3;
  }else{
    fits_write_key(file_ptr, TSTRING, "USE_LAST", no_str, "Did Not Use Lastframe Correction File", &status);
  }
  //_______________________________________________________________________
  if(control.apply_lin_cor ==1){
    fits_write_key(file_ptr, TSTRING, "USE_LIN", yes_str, "Used Linearity Correction File", &status);
    
    string lcfile = control.lin_cor_file;
    string pfile = lcfile; 
    size_t dir = lcfile.find_last_of("/");
    if (dir != string::npos) {
      pfile = lcfile.substr(dir+1,lcfile.size());
    }


    len = pfile.length();
    char *ptr3 = new char[len+1];
    pfile.copy(ptr3,len,0);
    ptr3[len] = 0;
    status = 0 ;
    fits_write_key(file_ptr, TSTRING, "LIN", ptr3, "Linearity Correction File", &status);
    delete [] ptr3;
  }else{
    fits_write_key(file_ptr, TSTRING, "USE_LIN", no_str, "Did not Use Linearity Correction File", &status);
  }

  //_______________________________________________________________________
  if(control.subtract_dark  ==1){
    fits_write_key(file_ptr, TSTRING, "USE_DARK", yes_str, "Used Dark Correction File", &status);
    
    //    string dcfile = control.dark_cor_file;
    string dcfile;// = data_info.dark_file;
    string pfile = dcfile; 
    size_t dir = dcfile.find_last_of("/");
    if (dir != string::npos) {
      pfile = dcfile.substr(dir+1,dcfile.size());
    }


    len = pfile.length();
    char *ptr3 = new char[len+1];
    pfile.copy(ptr3,len,0);
    ptr3[len] = 0;
    status = 0 ;
    fits_write_key(file_ptr, TSTRING, "DARK", ptr3, "Dark Correction File", &status);
    delete [] ptr3;
  }else{
    fits_write_key(file_ptr, TSTRING, "USE_DARK", no_str, "Did not Use Dark Correction File", &status);
  }

    
  
}



