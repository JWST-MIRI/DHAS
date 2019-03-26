// This software is part of the MIRI Data Handling and Analysis Software (DHAS)

// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//       ms_get_param2.cpp
//
// Purpose:
//
// This program does the work of ms_read_preferences- it does the parsing all the
// parameters in the preferences file 	
//
//
// Author:
//
//	Jane Morrison
//      University of Arizona
//      email: morrison@as.arizona.edu
//      phone: 520-626-3181
// 
// 
// Calling Sequence:
//
//int ms_get_param2(string param_filename,
//		   miri_preference& preference)
//
//
// Arguments:
//
// filename : name of file to process
// preference: the miri_preference structure that holds all the default parameters found in
//            the preference file. 
//
// Return Value:
//
// 0 - worked ok  
// Additional routines: 
//void miri_parse_param; pulls out the parameters after the = in the preferences file.  
//
// History:
//
// Created Jan 07 2014 - replaced ms_get_param.cpp that did not search for keys. Used
// hardcoded location in the file to figure out what was what

#include <string>
#include <string.h>
#include <algorithm>
#include "miri_sloper.h"
#include "miri_preference.h"

void miri_search_keys(string keyname,miri_preference &preference, int& val, int &status);
void miri_search_keys(string keyname,miri_preference &preference, string& val, int &status);
void miri_search_keys(string keyname,miri_preference &preference, float& val, int &status);

int ms_get_param2(string param_filename,
		   miri_preference& preference)

{
  int Final_Status = 0 ; 
  char chr;
  // open the parameter file  (determine the version number of the file)
  ifstream param_file(param_filename.c_str(),ios::in);
  if(!param_file){
    cerr<< " Preferences file does not exist " << endl;
    cout << " Check that you have the environment variable MIRI_DIR set up correctly in your .bashrc or equivalent file" << endl;
    exit(EXIT_FAILURE);
  }

  //_______________________________________________________________________
  string key = "" ;    
  string value = "";
  string comment;
  int keys_found = 0; 
  while(!param_file.eof() ){
    key="";
    while (param_file.get(chr) && chr != '=') {key += chr;}
    //    cout <<  "key" << key <<  "end " << key.length() << endl;
    // skip over the comments and grab information after =
    value ="";
    while (param_file.get(chr) && chr != ':') {value +=chr;}
    param_file >> comment;

    while (param_file.get(chr) && chr != '\n') {  } // read to end of line

    key.erase( remove_if( key.begin(), key.end(), (int(*)(int))isspace),key.end()); // remove leading or trailing blanks
    value.erase( remove_if(value.begin(), value.end(), (int(*)(int))isspace),value.end()); // remove leading or trailing blanks

    preference.key.push_back(key);
    preference.value.push_back(value);
    keys_found++;
  }

  //  cout << "Number of Keys" << keys_found << endl;
  preference.keys_found = keys_found;
  //for (int k = 0; k < keys_found-1; k++){
  // cout << preference.key[k] << " = " << preference.value[k] << endl;
  // }

  // close the parameter file
  param_file.close();

  //_______________________________________________________________________
  // loop over parameters and find matches
    int status = 0;


  miri_search_keys("SCIDIR",preference,preference.scidata_dir,status);
  if(status == 1) {
    cout << "Failure to parse SCIDIR from preferences file" << endl;
    Final_Status = 1;
  } 

  miri_search_keys("LVL2DIR",preference,preference.scidata_out_dir,status);
  if(status == 1) {
    cout << "Failure to parse LVL2DIR from preferences file" << endl;
    Final_Status = 1;
  } 

  miri_search_keys("CALIM_RAL1",preference,preference.CDP_IM_RAL1_file,status);
  if(status == 1) {
    cout << "Failure to parse CALIM_RAL1 from preferences file" << endl;
    Final_Status = 1;
  } 

  miri_search_keys("CALIM_JPL3",preference,preference.CDP_IM_JPL3_file,status);
  if(status == 1) {
    cout << "Failure to parse CALIM_JPL3 from preferences file" << endl;
    Final_Status = 1;
  } 

  miri_search_keys("CALLW_RAL1",preference,preference.CDP_LW_RAL1_file,status);
  if(status == 1){
    cout << "Failure to parse CALLW_RAL1 from preferences file" << endl;
    Final_Status = 1;
  } 
  miri_search_keys("CALLW_JPL3",preference,preference.CDP_LW_JPL3_file,status);
  if(status == 1){
    cout << "Failure to parse CALLW_JPL3 from preferences file" << endl;
    Final_Status = 1;
  } 

  miri_search_keys("CALSW_RAL1",preference,preference.CDP_SW_RAL1_file,status);
  if(status == 1) {
    cout << "Failure to parse CALSW_RAL1 from preferences file" << endl;
    Final_Status = 1;
  } 

  miri_search_keys("CALSW_JPL3",preference,preference.CDP_SW_JPL3_file,status);
  if(status == 1) {
    cout << "Failure to parse CALSW_JPL3 from preferences file" << endl;
    Final_Status = 1;
  } 

  miri_search_keys("JPLRUN",preference,preference.jpl_run,status);
  if(status == 1) {
    cout << "Failure to parse JPLRun from preferences file" << endl;
    Final_Status = 1;
  } 

  miri_search_keys("FRAME_LIMIT",preference,preference.frame_limit,status);
  if(status == 1) cout << "Failure to parse FRAME_LIMIT from preferences file" << endl;

  miri_search_keys("ROW_LIMIT",preference,preference.subset_nrow,status);
  if(status == 1) cout << "Failure to parse ROW_LIMIT from preferences file" << endl;
  //_______________________________________________________________________

  miri_search_keys("APPLY_BAD_PIX",preference,preference.apply_bad_pixel,status);
  if(status == 1) cout << "Failure to parse APPLY_BAD_PIX from preferences file" << endl;


  miri_search_keys("APPLY_RSCD",preference,preference.apply_rscd,status);
  if(status == 1) cout << "Failure to parse APPLY_RSCD from preferences file" << endl;

  miri_search_keys("APPLY_MULT",preference,preference.apply_mult,status);
  if(status == 1) cout << "Failure to parse APPLY_MULT from preferences file" << endl;

  miri_search_keys("APPLY_RESET",preference,preference.apply_reset,status);
  if(status == 1) cout << "Failure to parse APPLY_RESET from preferences file" << endl;

  miri_search_keys("APPLY_LASTFRAME",preference,preference.apply_lastframe,status);
    if(status == 1) cout << "Failure to parse APPLY_LASTFRAME from preferences file" << endl;

  miri_search_keys("APPLY_DARK",preference,preference.apply_dark,status);
  if(status == 1) cout << "Failure to parse APPLY_DARK from preferences file" << endl;

  miri_search_keys("APPLY_LIN",preference,preference.apply_lin,status);
  if(status == 1) cout << "Failure to parse APPLY_LIN from preferences file" << endl;

  status = 0;
  miri_search_keys("APPLY_PIXEL_SAT",preference,preference.apply_pixel_sat,status);
  if(status == 1) cout << "Failure to parse APPLY_PIXEL_SAT from preferences file" << endl;

  miri_search_keys("APPLY_REF_PIX",preference,preference.do_refpixel_option,status);
  if(status == 1) cout << "Failure to parse APPLY_REF_PIX  from preferences file" << endl;


  miri_search_keys("REF_TEMP_SCALE",preference,preference.refpixel_temp_scale,status);
  if(status == 1) cout << "Failure to parse REF_TEMP_SCALE  from preferences file" << endl;

  miri_search_keys("REF_TEMP_GAIN",preference,preference.refpixel_temp_gain,status);
  if(status == 1) cout << "Failure to parse REF_TEMP_GAIN  from preferences file" << endl;


  miri_search_keys("REF_PIX_DELTA",preference,preference.delta_refpixel_even_odd,status);
  if(status == 1) cout << "Failure to parse REF_PIX_DELTA  from preferences file" << endl;


  if(preference.do_refpixel_option < 0 || preference.do_refpixel_option > 5){
   cout << " Preferences file contains invalid value using the reference pixel  " << endl;
     cout << " Valid values 0,1,2,3,4 " << endl;
     exit(EXIT_FAILURE);
  }
 
  if(preference.delta_refpixel_even_odd< 0) {
   cout << " Preferences file contains invalid value for number of rows to used with option +r2 " << endl;
   cout << " Valid values > 0 " << endl;
   exit(EXIT_FAILURE);
  }
  //_______________________________________________________________________
  miri_search_keys("FIT_A",preference,preference.n_reads_start_fit,status);
  if(status == 1) cout << "Failure to parse FIT_A  from preferences file" << endl;
  miri_search_keys("FIT_N",preference,preference.n_frames_end_fit,status);
  if(status == 1) cout << "Failure to parse FIT_N from preferences file" << endl;
  if(preference.n_reads_start_fit < 0) { 
    cout << " Preferences files contains invalid frame # to start the fit on" << endl;
    cout << " Frame # must be greater than 0" << endl;
    exit(EXIT_FAILURE);
  }

  
  if(preference.n_frames_end_fit < 0) { 
    cout << " Preferences files contains invalid number of frames from the last frame to end the fit on" << endl;
    cout << " Valid must be greater than 0" << endl;
      exit(EXIT_FAILURE);
  }
  miri_search_keys("HIGH_SAT",preference,preference.dn_high_sat,status);
  if(status == 1) cout << "Failure to parse HIGH_SAT from preferences file" << endl;
  //_______________________________________________________________________

  miri_search_keys("CR_STD",preference,preference.cr_sigma_reject,status);
  if(status == 1) cout << "Failure to parse CR_STD  from preferences file" << endl;
  miri_search_keys("CR_NFRAMES",preference,preference.n_frames_reject_after_cr,status);
  if(status == 1) cout << "Failure to parse  CR_NFRAMES from preferences file" << endl;
  miri_search_keys("CR_NFRAMES2",preference,preference.n_frames_reject_after_cr_small_frameno,status);
  if(status == 1) cout << "Failure to parse  CR_NFRAMES2 from preferences file" << endl;
  miri_search_keys("CR_NOISE_LEVEL",preference,preference.cosmic_ray_noise_level,status);
  if(status == 1) cout << "Failure to parse CR_NOISE_LEVEL  from preferences file" << endl;
  miri_search_keys("CR_MAX",preference,preference.max_iterations_cr,status);
  if(status == 1) cout << "Failure to parse  CR_MAX from preferences file" << endl;
  miri_search_keys("CR_MIN_GOOD",preference,preference.cr_min_good_diffs,status);
  if(status == 1) cout << "Failure to parse  CR_MIN_GOODfrom preferences file" << endl;
  miri_search_keys("CR_SLOPE_STD",preference,preference.slope_seg_cr_sigma_reject,status);
  if(status == 1) cout << "Failure to parse CR_SLOPE_STD from preferences file" << endl;
  //_______________________________________________________________________

  miri_search_keys("READ_NOISE",preference,preference.read_noise,status);
  if(status == 1) cout << "Failure to parse READ_NOISE from preferences file" << endl;
  miri_search_keys("GAIN",preference,preference.gain,status);
  if(status == 1) cout << "Failure to parse GAIN from preferences file" << endl;

  if(preference.gain < 0) {
    cout << " Preferences files contains invalid Gain number" << endl;
   exit(EXIT_FAILURE);
  }
  //_______________________________________________________________________
  miri_search_keys("METHOD_UNCER",preference,preference.UncertaintyMethod,status);
  if(status == 1) cout << "Failure to parse METHOD_UNCER from preferences file" << endl;

  miri_search_keys("WRITE_REF_OUT",preference,preference.write_refoutput_slope,status);
  if(status == 1) cout << "Failure to parse WRITE_REF_OUT  from preferences file" << endl;
  if(preference.write_refoutput_slope != 0) preference.write_refoutput_slope = 1;


  miri_search_keys("WRITE_REF_COR",preference,preference.write_output_refpixel_corrections,status);
  if(status == 1) cout << "Failure to parse WRITE_REF_COR  from preferences file" << endl;
  if(preference.write_output_refpixel_corrections != 0) preference.write_output_refpixel_corrections = 1;

  miri_search_keys("WRITE_ID",preference,preference.write_output_ids,status);
  if(status == 1) cout << "Failure to parse WRITE_ID  from preferences file" << endl;
  if(preference.write_output_ids != 0) preference.write_output_ids = 1;

  miri_search_keys("WRITE_LIN_COR",preference,preference.write_output_lc_correction,status);
  if(status == 1) cout << "Failure to parse  WRITE_LIN_COR from preferences file" << endl;
  if(preference.write_output_lc_correction != 0) preference.write_output_lc_correction = 1;

  miri_search_keys("WRITE_DARK_COR",preference,preference.write_output_dark_correction,status);
  if(status == 1) cout << "Failure to parse WRITE_DARK_COR  from preferences file" << endl;
  if(preference.write_output_dark_correction != 0) preference.write_output_dark_correction = 1;


  miri_search_keys("WRITE_RSCD_COR",preference,preference.write_output_rscd_correction,status);
  if(status == 1) cout << "Failure to parse WRITE_RSCD_COR  from preferences file" << endl;
  if(preference.write_output_rscd_correction != 0) preference.write_output_rscd_correction = 1;

  preference.write_output_reset_correction = 0;

  miri_search_keys("WRITE_CR_ID",preference,preference.write_detailed_cr,status);
  if(status == 1) cout << "Failure to parse WRITE_CR_ID  from preferences file" << endl;
  if(preference.write_detailed_cr != 0) preference.write_detailed_cr = 1;
 
  return Final_Status; 

}
