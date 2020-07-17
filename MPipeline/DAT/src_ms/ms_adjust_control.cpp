// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//  ms_fastshort_mode_adjustments.cpp
//
// Purpose:
// 	
// This program is called from miri_sloper.cpp
// If the data is Fast Short mode - then the output name has to be changed from
//  LVL2 to FASTSHORT_MEAN. The program also checks that command line options
//  not appropriate for Fast Short mode data are not set. The original value of
// the parameters are stored in case miri_sloper is being run over a list of files.   
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
//void ms_adjust_control(miri_data_info& data_info, miri_control &control)
//
// Arguments:
//
// data_info: miri_data_info structure that holds basic information of the science data
//            being processed.
// control: miri_control structure hold the processing options. Some of these parameters
//          are not appropriated for fast short mode data and are turned off. 
//
// Return Value/ Variables modified:
//      No return value.
// the original control parameters that are turned off are stored. 
//
// History:
//
//	Written by Jane Morrison  June 2008
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/



#include <iostream>
#include <vector>
#include <string>
#include <cstring>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_control.h"




void ms_adjust_control(miri_data_info& data_info, miri_control &control) 

{


  control.n_frames_reject_after_cr = control.n_frames_reject_after_cr_save;


  if(data_info.NRamps <= 10 && control.flag_n_frames_reject_after_cr ==0) 
    control.n_frames_reject_after_cr = control.n_frames_reject_after_cr_small_frameno;


  //***********************************************************************
  //***********************************************************************

  if(data_info.Mode == 3){                  // NFRAME ! = 1
    if(control.apply_dark_cor ==1) {
      cout << " Dark Calibration file can not be applied to data with NFRAME NOT EQUAL to 1" << endl;
      cout << " Turning off applying Dark" << endl;
      control.apply_dark_FS = control.apply_dark_cor;
      control.write_output_dark_FS = control.write_output_dark_correction;
      
      control.apply_dark_cor = 0;
      control.write_output_dark_correction = 0;
    }
  }

  //***********************************************************************

  //***********************************************************************

  if(control.flag_frametime == 1 ) {
    //    cout << " Changing Frame from " << data_info.FrameTime << " to " << control.frametime << endl;
    //data_info.FrameTime = control.frametime;

    cout << " Changing Frame from " << data_info.GroupTime << " to " << control.frametime << endl;
    data_info.GroupTime = control.frametime;
  } 

  //***********************************************************************

    // if in subarray mode - turn off reference option r2 
    if(data_info.subarray_mode != 0 && control.do_refpixel_option == 2) {

      // For subarray we can not do +r2 - We can either 
      // 1. Stop 
      cout << " You can not use the +r2 option with subarray data (no right reference pixels)" << endl;
      cout << " Run again and remove +r2 option " << endl;
      exit(EXIT_FAILURE);

      // 2. turn off and turn back on later 
      // If many files are given in a list to process this will prevent the program from stopping
      // if there are subarray file mixed with full array

     
      control.do_refpixel_option_SA = control.do_refpixel_option;
      control.do_refpixel_option = 0;
      if(control.do_refpixel_option_SA !=0) 
	cout << " This is subarray data, turning off reference pixels option r2  to correct data " << endl;  
    }

    if(data_info.subarray_mode == 2 && control.do_refpixel_option != 0) {

      // Burst Mode data there are no reference pixels
      // 1. Stop 
      cout << " You can not use the +r2 option with subarray burst mode data (no  reference pixels)" << endl;
      cout << " Turning off using reference pixels for this file " << endl;
      //exit(EXIT_FAILURE);

      // 2. turn off and turn back on later 
      // If many files are given in a list to process this will prevent the program from stopping
      // if there are subarray file mixed with full array

     
      control.do_refpixel_option_SA = control.do_refpixel_option;
      control.do_refpixel_option = 0;

    }


    control.apply_rscd_cor_Input =control.apply_rscd_cor;
    control.write_output_rscd_correction_Input = control.write_output_rscd_correction;
    //    if(data_info.NInt == 1 && control.apply_rscd_cor ==1) {
    // cout << " Reset Switch Charge Decay correction can not be applied to data with only 1 integration" << endl;
    //}
    if(control.apply_rscd_cor ==0) control.write_output_rscd_correction = 0;
  //***********************************************************************

    if(control.QuickMethod ==1) {
      control.apply_badpix = 0;
      control.apply_pixel_saturation = 0;
      control.apply_dark_cor = 0;
      control.apply_lin_cor = 0;
	
      control.do_cr_id = 0;
      control.do_refpixel_option = 0;
      control.do_diagnostic =0;
      control.write_output_refslope = 0;
      control.write_output_lc_correction =0;	
      control.write_output_refpixel = 0;
      control.write_output_refpixel_corrections = 0; 
      control.write_output_ids= 0;
      control.write_output_dark_correction = 0 ;
      control.write_output_reset_correction = 0;
      control.write_output_lastframe_correction = 0 ;

    }


}
