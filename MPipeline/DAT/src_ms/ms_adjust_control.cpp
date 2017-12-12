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
  if(data_info.Mode == 2){                  // FASTSHORT MODE DATA
  //***********************************************************************
  // get the base file name of the raw data and get basic information about the dataset
  // making sure a file has actually been specified
  // remove the .fits if it exists
	
    string output_name ="null";
    int II = data_info.this_file_num;
    string file = data_info.filenames[II];
    string raw_fitsbase = file.substr(0,file.size()-5);
  // _______________________________________________________________________
  // Figure out the name of the output file from the input file name
  // _______________________________________________________________________

    output_name = raw_fitsbase +  "_FASTSHORT_MEAN.fits";
  
  // _______________________________________________________________________
  // Use the user provided output filename
  // _______________________________________________________________________
      if(control.flag_output_name ==1) {
  
	output_name = control.output_name;
	size_t fitspos = control.output_name.find(".fits");
	if (fitspos != string::npos) {
	  output_name = output_name.substr(0,output_name.size()-5);
	}
	size_t fsm = output_name.find("FASTSHORT_MEAN");
	if (fsm == string::npos) {
	  output_name = output_name + "_FASTSHORT_MEAN.fits";
	}else{
	  output_name = output_name + ".fits";
	}
	data_info.raw_fitsbase[II] = output_name.substr(0,output_name.size()-9);
      }

      cout << " Working with Fast Short Mode data, turning off writing extra output files " << endl;
      cout << " and options not appropriate for this type of data" << endl; 
      cout << " Output file " << output_name <<  endl;
      data_info.red_filename[II] = "!" + control.scidata_out_dir + output_name;
  // _______________________________________________________________________
  // Options not allowed in FAST SHORT mode

      control.write_output_refslope_FS =   control.write_output_refslope;
      control.write_output_lc_correction_FS =  control.write_output_lc_correction;
      control.apply_lin_cor_FS =  control.apply_lin_cor;
      control.do_cr_id_FS = control.do_cr_id; 
      control.do_diagnostic_FS  = control.do_diagnostic;
      control.apply_dark_FS = control.apply_dark_cor;
      control.write_output_dark_FS = control.write_output_dark_correction;
      
      if(control.apply_lin_cor ==1) cout << "Turning off applying linearity correcton for data " << endl;
      if(control.apply_dark_cor ==1) cout << "Turning off applying dark correcton for data " << endl;


      control.write_output_refslope = 0;
      control.write_output_lc_correction =0;
      control.apply_lin_cor = 0;  // no linearity correction allowed
      control.do_cr_id = 0; // no cosmic ray detection allowed
      control.do_diagnostic = 0;
      control.apply_dark_cor = 0;
      control.write_output_dark_correction = 0;

  // switch the NRamps and NInt to get the data processed with miri_sloper -
  // swtich back at the end

      data_info.NRamps = data_info.NInt;
      data_info.NInt  = 1;

  // _______________________________________________________________________
      cout << " Raw fits base              " << data_info.raw_fitsbase[II] << endl;
      cout << " Raw filename               " << data_info.raw_filename[II] << endl;
      cout << " Output filename            " << data_info.red_filename[II] << endl;
      if(control.write_output_refslope == 1) 
	cout << " Output Reference Filename  " << data_info.red_ref_filename[II] << endl;
  // _______________________________________________________________________
  // test if raw file exists

      int status = 0;
      int testfile = 0;
      fits_file_exists(data_info.raw_filename[II].c_str(),&testfile,&status);
      if( testfile !=1) { // open failed
	cout << " Can not open the file: " << data_info.raw_filename[II] << endl;
	cout << " Is the directory correct ? " << endl;
	cout << "    If not either modify preference file or commandline option -DI" << endl;
	cout << " Is the filename correct ? "  << endl;
	cout << "    If not you provided an incorrect name (case sensitive) " << endl;
	exit(EXIT_FAILURE);
      }
  }
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
    if(data_info.NInt == 1 && control.apply_rscd_cor ==1) {
      cout << " Reset Switch Charge Decay correction can not be applied to data with only 1 integration" << endl;
      //control.apply_rscd_cor = 0;
    }
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
	if(data_info.Mode == 2) {
	  control.QuickMethod = 0;
	  // cout << " You can not use the Quick Method on data to be Co-added " << endl;
	// cout << " Run again and do you use the -Q option " << endl;
	// exit(EXIT_FAILURE);
	}
      }




      if(control.do_Pulse_Mode ==1) {
	control.apply_badpix = 0;
	control.apply_pixel_saturation = 0;
	control.apply_lin_cor = 0;
	control.apply_dark_cor = 0; 
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
	if(data_info.Mode == 2) {
	  cout << " You can not use Pulse mode on data to be Co-added data " << endl;

	  exit(EXIT_FAILURE);
	}
      }
}
