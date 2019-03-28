// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//    ms_setup_processing.cpp
//
// Purpose:
// This program first checks that not all the data has been rejected by havea too
// tight limit on the frame numbers to process (-a, -n, or  -z too limiting)
// 
// This program determines which Prefrences file is correct for the data - determined
// from routine ms_get_CDP_names(CDP,control,data_info) reads in the calibration files
// as set by the Preference file. 
//
//If control.apply_badpix set (read in the bad pixel file), then the correct bad pixel
// mask is found for the detector/origin. The bad pixel mask is read in with
// read_badpixel_fits and held in the data_info structure. 
// 
// If the apply pixel saturation flag is set then the correct pixel saturation file
// mask is found for the detector/origin of the file. The pixel saturation mask is read in
// and stored in the data_info structure
// 
//The darks are too large to read the entire thing in so just determine the filename
// read in the size of dark file to confirm it contains as many or more frames that
// science data
//
// Read in basic parameters of the reset file. 
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
//void ms_setup_processing(miri_control &control,
//			 miri_data_info& data_info)
//
//
// Arugments:
//
//  control: miri_control structure containing the processing options
//  data_info: miri_data_info structure containing basic information on the dataset
//
//
// Return Value/ Variabes modified:
//      No return value.  
//      data_info structure filled in  
//
// History:
//
//	Written by Jane Morrison 2006
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/
//    version 1.1 11/15/12 removed if SCAID = 493,494 or 495 can not be using VM data
//                                    SCAIDs same for FM and VM data
//    version 1.2 04/12/12 switched to reading CDP format 

#include <iostream>
#include <sstream> 
#include <vector>
#include <string>
#include <time.h>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_control.h"
#include "miri_constants.h"
#include "miri_sloper.h" 

string StringToLower(string);

void ms_setup_processing(miri_control &control,
			 miri_data_info& data_info,
			 miri_preference &preference,
			 miri_CDP &CDP)

{
  int status = 0;
    
//_______________________________________________________________________
  // Check that last ramps to use in fit - set by n_reads_end_fit is not = 0
  // if so then set = number of ramps (-1 because counting starts at 0)

  if(control.flag_n_reads_end_fit !=0 && control.n_reads_end_fit > data_info.NRamps){
    cout << " You entered too large a number of the -z option " << endl;
    cout << " -z #, where # is the last frame number of use in the fit " << endl;
    cout << " There are " << data_info.NRamps << " frames in this integration " << endl;
    cout << data_info.raw_filename[data_info.this_file_num] << endl;
    exit(EXIT_FAILURE);
  }

  // check if set -z option - use this one
  if(control.flag_n_reads_end_fit ==0) control.n_reads_end_fit = data_info.NRamps - control.n_frames_end_fit -1 ;

  // initialized to zero - so if not set then set to end of ramps
  if(control.n_reads_end_fit == 0 && control.n_frames_end_fit == 0)control.n_reads_end_fit = data_info.NRamps -1;

  data_info.NRampsRead = (control.n_reads_end_fit - control.n_reads_start_fit) + 1;

  if( (control.n_reads_end_fit+1)  != data_info.NRamps) { // control.n_reads_end_fit referenced to zero
    if(control.apply_lastframe_cor ==1) cout << " Not using last frame in fit, turning off applying last frame correction" << endl;
    control.apply_lastframe_cor = 0;
    control.write_output_lastframe_correction = 0;
    
  } 
//_______________________________________________________________________

//check if data is a test pattern
  if(data_info.detmode == "TEST_PATTERN"){
    cout << " Data is a test pattern, not processing data" <<endl;
    exit(EXIT_FAILURE);
  }
//_______________________________________________________________________
  // check not rejecting all the data

  int test1 = data_info.NRamps - control.n_reads_start_fit;
  if(test1 <= 1) {
    cout <<" Rejecting too many frames at the start of the ramp" << endl;
    cout <<" Number of frames in integration " << data_info.NRamps << endl;
    cout <<" Starting slope fit on frame " << control.n_reads_start_fit  +1 << endl;
    cout <<" Run again and either change the preference file or the command line for this varible"<< endl;
    cout << data_info.raw_filename[data_info.this_file_num] << endl;
       exit(EXIT_FAILURE);
  }
  if(control.n_reads_end_fit > data_info.NRamps) {
    cout << " The parameter setting the frame number to end the slope fit is greater than the number of frames" << endl;
    cout << " Run again and either change the preferences file or the command line for this varible" << endl;
    cout << data_info.raw_filename[data_info.this_file_num] << endl;
    exit(EXIT_FAILURE);
  }
  if( (control.n_reads_end_fit - control.n_reads_start_fit) <1) {
    cout << " Parameters govering frames to use for slope fit - too restrictive " << endl;
    cout <<" Starting slope fit on frame " << control.n_reads_start_fit+1 << endl;
    cout <<" Ending slope fit on frame " << control.n_reads_end_fit+1 << endl;
    cout <<" Run again and either change the preference file or the command line for this varible"<< endl;
    cout << data_info.raw_filename[data_info.this_file_num] << endl;
    exit(EXIT_FAILURE);
  }
  //_________________________________________________________________________________________________
  // check if applying any of the calibration files. Then figure out which detector and Model (FM/JPL) we
  // have to know the correct CDP file to read in. 
  if ( control.apply_pixel_saturation== 1 ||  control.apply_badpix== 1  ||  control.apply_lin_cor ||
       control.subtract_dark == 1 || control.apply_lastframe_cor ||
       control.apply_rscd_cor == 1 || control.apply_reset_cor || control.apply_mult_cor == 1 ) {

    int found = 0;
    if(data_info.Origin == "JPL"    ){
      if(control.flag_jpl_run ==0){
	cout << " This is JPL test data. You are using the default test run in the preferences file " << control.jpl_run <<   endl;
	cout << " If you want a different run then use option -run #" << endl;
      }

      int corrected_value  = (data_info.ColStart -1)*4/5 + 1;
      cout << "Correcting COLSTART value in memory from " << data_info.ColStart << " to " << corrected_value<< endl;
      data_info.ColStart = corrected_value;

      if(control.jpl_run == "8") {
	if(control.jpl_detector_flag ==0) {
	  cout << " This is JPL Run 8, you must also set which detector the data is from, use option -jdet 101,106,124 " << endl;
	  cout << "  -jdet 101 is for FPM-101 data " << endl;
	  cout << "  -jdet 106 is for SCA-106 data " << endl;
	  cout << "  -jdet 124 is for SCA-124 data " << endl;
	  exit(EXIT_FAILURE);
	} else {
	  preference.CDP_file = "MIRI_CDP_JPL_RUN" + control.jpl_run + "_D"+control.jpl_detector + ".list";
	  cout << " Using " << preference.CDP_file;
	  found = 1;
	}

      } else {
	preference.CDP_file = "MIRI_CDP_JPL_RUN" + control.jpl_run +".list";	
	found = 1;      
	
      }
    }

    string det_setting = "JPL3"; 
    if(data_info.Origin == "RAL" )  det_setting = "RAL1";
    cout << "Detector " << data_info.Detector << endl;
      //_______________________________________________________________________
    if(found ==0) { 
      if(data_info.Detector == IM || data_info.Detector == MIRIIM) {
	if(det_setting == "RAL1") { 
	  preference.CDP_file  =preference.CDP_IM_RAL1_file;
	  found = 1;
	}
	if(det_setting == "JPL3") { 
	  preference.CDP_file  =preference.CDP_IM_JPL3_file;
	  found = 1;
	}
	data_info.Detector = IM;
      }
      //_______________________________________________________________________

      if(data_info.Detector == LW || data_info.Detector == MIRILW){
	if(det_setting == "RAL1") { 
	  preference.CDP_file  =preference.CDP_LW_RAL1_file;
	  found = 1;
	}
	if(det_setting == "JPL3") { 
	  preference.CDP_file  =preference.CDP_LW_JPL3_file;
	  found = 1;
	}
	data_info.Detector = LW;
      }

      //_______________________________________________________________________
      if(data_info.Detector == SW || data_info.Detector == MIRISW){
	if(det_setting == "RAL1") { 
	  preference.CDP_file  =preference.CDP_SW_RAL1_file;
	  found = 1;
	}
	if(det_setting == "JPL3") { 
	  preference.CDP_file  =preference.CDP_SW_JPL3_file;
	  found = 1;
	}
	data_info.Detector = SW;
      }      
    }
    

    data_info.det_setting = det_setting;
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    cout << "Data is for detector: " << data_info.Detector << " " << endl;
    cout << "Origin of data: " << data_info.Origin << endl;
    cout << "Reading Reference files from "<< preference.CDP_file << endl;

    // check if user supplied a CDP file
    string master_list = preference.CDP_file;
    if(control.flag_CDP_file ==1)master_list = control.CDP_file;


    if(found ==0 and control.flag_CDP_file ==0 ) {
      cout << " ms_setup_processing: Could not determine correct CDP from Detector and Origin " << endl;
      cout << " ms_setup_processing: Can not apply calibration files " << endl;
      cout << data_info.raw_filename[data_info.this_file_num] << endl;
      exit(EXIT_FAILURE);
    }
    CDP.SetMasterList(master_list); 

    master_list = control.miri_dir+ "Preferences/" +  master_list;
    CDP.SetMasterListDir(master_list);    
    cout << " CDP master list " << master_list << endl;

    //********************************************************************************
    // read in the calibration files for the detector
    ms_get_CDP_names(CDP,control,data_info);
    //********************************************************************************
  }// done check on applying ANY calibration files

  // **********************************************************************
  // read in pixel saturation mask. 

  if ( control.apply_pixel_saturation== 1) {
    string ps_filename = "null";
    if(control.flag_pixel_saturation_file == 1){ // set by user
      ps_filename = control.pixel_saturation_file;
    }
    if(control.flag_pixel_saturation_file == 0){ // not set by the user
      // use the one in the CDP list 
      control.pixel_saturation_file = CDP.GetPixelSatName();
      ps_filename= control.calib_dir+ control.pixel_saturation_file;   
    }

    control.pixel_saturation_file = ps_filename;
    status = Check_CDPfile(ps_filename); 
    if(status !=0 ) {
      cout << " Program exiting, check file " << ps_filename << endl;
      exit(EXIT_FAILURE);
    }
    fitsfile *fptr;
    int hdutype = 0; 
    fits_open_file(&fptr,ps_filename.c_str(),READONLY,&status);
    if(status != 0 ) {
      cout << " Problem openning Pixel Satuaration file " << ps_filename << " " << status << endl;
      cout << " Contining with program, ignoring pixel saturation file, using single saturation value" << endl;
      control.apply_pixel_saturation = 0;
    } else {

      long inc[2]={1,1};
      int anynul = 0;  // null values
      long fpixel[2] ;
      long lpixel[2];
      fpixel[0]= data_info.ColStart;
      fpixel[1]= data_info.RowStart;

      lpixel[0] = fpixel[0] + data_info.ramp_naxes[0] -1;
      lpixel[1] = fpixel[1] + data_info.ramp_naxes[1] -1;
      long ixy =data_info.ramp_naxes[0] * data_info.ramp_naxes[1];
      vector<float>  data(ixy);
      status = 0;
      fits_movabs_hdu(fptr,2,&hdutype,&status); // for to first extension  
      fits_read_subset(fptr, TFLOAT, 
		       fpixel,lpixel,
		       inc,0, 
		       &data[0], &anynul, &status);
      if(status != 0 ) {
	cout << " Problem reading pixel saturation file " << ps_filename << " " << status << endl;
	cout << " Check Filename and run again " << endl;
	cout << data_info.raw_filename[data_info.this_file_num] << endl;
	exit(EXIT_FAILURE); 
	status = 1;
      }
      
      // Read in Pixel Saturation DQ flag
      hdutype = 0;
      fits_movabs_hdu(fptr,4,&hdutype,&status);
      vector<int>  dq(ixy); 
      status = 0;
 
      fits_read_subset(fptr, TINT, 
		       fpixel,lpixel,
		       inc,0, 
		       &dq[0], &anynul, &status);
      if(status != 0 ) {
	cout << " Problem reading pixel saturation  file " << ps_filename << " " << status << endl;
	cout << " Check Filename and run again " << endl;
	cout << data_info.raw_filename[data_info.this_file_num] << endl;
	exit(EXIT_FAILURE); 
	status = 1;
      }

      fits_close_file(fptr,&status);

      for (long k = 0; k< ixy; k++){
	CDP.SetPixelSat(data[k]);
	CDP.SetPixelSatDQ(dq[k]);
      }
    }

  }
  
  // **********************************************************************
  // If using - Get the bad pixel  fits file. If using

  if ( control.apply_badpix== 1) {
    string badpix_filename = "null";

    if(control.flag_badpix_file == 1){ // set by user
      badpix_filename = control.badpix_file;
    }

    if(control.flag_badpix_file == 0){ // not set by the user
      control.badpix_file = CDP.GetBadPixelName();
      badpix_filename= control.calib_dir+ control.badpix_file;   
    }
    cout << " Reading in bad pixel file " << badpix_filename << endl;

    control.badpix_file = badpix_filename; 
    status = 0;
    status = ms_read_badpixel_fits(badpix_filename,data_info,CDP,control.do_verbose);

  }// end control.do_badpixel
  if (control.do_verbose == 10) cout << "finished bad pixel file read" << endl;

  // **********************************************************************

  // **********************************************************************
  if(control.subtract_dark == 1) {
    if(control.flag_dark_cor_file ==1) { // user proved dark
      // string dark_file = control.dark_cor_file;
      CDP.SetDarkUseUserSet(control.dark_cor_file);
    }

    if(control.flag_dark_cor_file == 0){ // User did not provide a dark to use 
      // Dark to use is Fast mode
      if(data_info.Mode == 0 && data_info.subarray_mode ==0 ) { CDP.SetDarkUseFast();}

	// Dark to use is Slow  mode
      if( data_info.Mode == 1 && data_info.subarray_mode ==0) { CDP.SetDarkUseSlow();}

      if(data_info.subarray_mode !=0) {
	cout << " Looking for Dark Subarray Filename" << endl;
	int status = ms_determine_CAL_Subarray(0,data_info,control,CDP);
	if(status !=0) { 
	  cout << "Subarray dark not found " << endl;
	  cout << " The Calibration directory could be incorrect or you do not have the dark subarray " << endl;
	  cout << " To continue you can remove subtracting the dark with the -D option " << endl;
	  cout << data_info.raw_filename[data_info.this_file_num] << endl;
	  exit(EXIT_FAILURE);
	}
      }// end searching over subarray
    }
    // Read in the dark to find out how many frames it contains
    

    int status = 0;
    int hdutype = 0; 

    string dark_file = CDP.GetDarkUseName( );
    if(control.flag_dark_cor_file ==0) { // from CDP list add calibration directory
      dark_file= control.calib_dir+ dark_file;
    }   

    cout << " Dark Calibration file " << dark_file << endl;
    ifstream Dark_file(dark_file.c_str());
    if (!Dark_file) {
      cout << " Dark  Calibration file  does not exist" << dark_file << endl;
      cout << " Run again and either correct filename or run with -D option (no Dark  correction)" << endl;
      cout << data_info.raw_filename[data_info.this_file_num] << endl;
      exit(EXIT_FAILURE);
    }


    status  = 0;
    fitsfile *file_ptr;   
    fits_open_file(&file_ptr, dark_file.c_str(), READONLY, &status);   // open the file
    if(status !=0) {
      cout << " Failed to open  Dark Calibration fits file: " <<dark_file << endl;
      cout << " Reason for failure, status = " << status << endl;
      cout << data_info.raw_filename[data_info.this_file_num] << endl;
      exit(EXIT_FAILURE);
    }

    fits_movabs_hdu(file_ptr,1,&hdutype,&status); // One for primary array      
    if(status !=0) {
      cout <<" Error in moving to Dark Extension " << endl;
      cout << data_info.raw_filename[data_info.this_file_num] << endl;
      exit(EXIT_FAILURE);
    }
    char comment[72];
    status = 0;

    int dark_nframes = 0;
    long nframes_cal = 0;
    fits_read_key(file_ptr, TLONG, "NGROUPS", &nframes_cal, comment, &status); // get the nplanes
    if(status !=0 ) cout << "ms_setup_processing:  Problem reading NGROUPS of Mean Dark Residual" << endl;
    dark_nframes = nframes_cal;
    
    if(data_info.NRamps > dark_nframes) {

      cout << " *******************************Warning**************************** " << endl; 
      cout <<" The Dark reference file does not have enough frames for this dataset." << endl;
      cout <<" Turning off Dark subtraction" << endl;
      cout << " Dark reference file has " << dark_nframes << " frames " << endl;
      cout << " Input data has " << data_info.NRamps << " frames " << endl;
      cout << " ******************************************************************" << endl;
      control.subtract_dark = 0;
    }

  } // end apply dark


 // **********************************************************************
  // Determine reset name
  // open file and determine # frames and integration correction file covers
  if(control.apply_reset_cor == 1) {
    if(control.flag_reset_cor_file ==1) { // user proved reset
      CDP.SetResetUseUserSet(control.reset_cor_file);
    }

    if(control.flag_reset_cor_file == 0){ // User did not provide a reset to use 
      // Reset to use is Fast mode
      if(data_info.Mode == 0 && data_info.subarray_mode ==0 ) { CDP.SetResetUseFast();}
      // Reset to use is Slow  mode
      if( data_info.Mode == 1 && data_info.subarray_mode ==0) { CDP.SetResetUseSlow();}
      if(data_info.subarray_mode !=0) {
	cout<< " Looking for Reset Subarray Filename" << endl;
	int status = ms_determine_CAL_Subarray(1,data_info,control,CDP);
	if(status !=0) { 
	  cout << "Subarray reset not found " << endl;
	  cout << " The Calibration directory could be incorrect or you do not have the reset subarray " << endl;
	  cout << " To continue you can remove subtracting the reset with the -D option " << endl;
	  exit(EXIT_FAILURE);
	}
      } // end searching over subarray
    }

    string rc_filename = CDP.GetResetUseName( );
    if(control.flag_reset_cor_file ==0) { // from CDP list add calibration directory
      rc_filename= control.calib_dir+ rc_filename;
    }   


    //string rc_filename= control.calib_dir+ CDP.GetResetUseName();
    cout << "Reset file" << rc_filename << endl;;
    long  xsize,ysize,zsize,isize;
    int colstart, rowstart;
    
    ms_read_CAL_header(rc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    
    CDP.SetResetMaxFrames(zsize);
    CDP.SetResetMaxInt(isize);
    int istart = control.n_reads_start_fit;
    int end_frame = istart + data_info.NRampsRead; // istart 0 indexed

    if(end_frame > zsize) end_frame = zsize;
    int nplanes = end_frame - istart ;
    CDP.SetResetUseNPlanes(nplanes);


    
  } // end apply reset correction 

  // **********************************************************************




  if (control.do_verbose == 1) cout << "finished ms_setup_processing" << endl;

}

