// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//  ms_adjust_control_end.cpp
//
// Purpose:
// 	
// This program is called from miri_sloper.cpp
// Set the control variables that were changes in ms_adjust_control.cpp back
// to orginal values
// It is only useful if miri_sloper is being run over a list of files. 
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
//void ms_adjust_control_end( miri_control &control)
//
// Arugments:
//
// control: miri_control structure hold the processing options. The values that
//    were turned off in ms_short_mode_adjustments.cpp are turned back on. 
//
// Return Value/ Variabes modified:
//      No return value.
// the original control parameters are set to original values  
//
// History:
//
//	Written by Jane Morrison  June 2008
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/

#include <iostream>
#include <vector>
#include <string>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_control.h"


void ms_adjust_control_end(miri_data_info &data_info, miri_control &control)

{
  // get back to the way they were
  if(data_info.Mode == 3){                  // NFRAME ! = 1

    control.apply_dark_cor = control.apply_dark_FS;
    control.write_output_dark_correction = control.write_output_dark_FS;

  }


  //***********************************************************************
    // If running over subarray data and in a list - if r2 set - reset. 
  //***********************************************************************

    if(data_info.subarray_mode != 0 && control.do_refpixel_option_SA == 2) {
      control.do_refpixel_option = control.do_refpixel_option_SA;
    }


    if(data_info.subarray_mode ==2 && control.do_refpixel_option_SA != 0) {
      control.do_refpixel_option = control.do_refpixel_option_SA;
    }

  //***********************************************************************
    control.apply_rscd_cor = control.apply_rscd_cor_Input;
    control.write_output_rscd_correction = control.write_output_rscd_correction_Input;

}
