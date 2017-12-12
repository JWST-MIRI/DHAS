// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//     ms_setup_output_files.cpp
//
// Purpose:
//   If -Op is used- set up writing reference pixel corrections used
//   If -OC is set then set up file on details of cosmic rays found
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
//void ms_setup_output_files(miri_control control,
//			   miri_data_info& data_info)
//
//
// Arugments:
//
//  control: miri_control structure containing the processing options
//  data_info: miri_data_info structure containing basic information on the dataset
//
//
// Return Value/ Variables modified:
//      No return value.  
// 
//
// History:
//
//	Written by Jane Morrison 2005
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/

#include <iostream>
#include "miri_control.h"
#include "miri_data_info.h"
// If control.write_output_refpixel is set, this program sets up the ASCII file that will
// contain the reference pixel corrections applied to the data 

void ms_setup_output_files(miri_control control,
			   miri_data_info& data_info)

{
  int II = data_info.this_file_num;
  if(control.write_output_refpixel) {
    cout << " Writing Reference Pixel Correction to " << data_info.output_refpixel[II] << endl;
    
    data_info.output_rp.open(data_info.output_refpixel[II].c_str(), ios::out);
    if( !data_info.output_rp) { // open failed
      cerr << " Can not open the file: " << data_info.output_refpixel[II] << endl;
      exit(EXIT_FAILURE);
    }
    // _______________________________________________________________________


    if(control.do_refpixel_option ==7) {
      data_info.output_rp << 
	" This file contains the reference pixel corrections based removing temp effects (a1... a5) " <<endl;
      data_info.output_rp <<  
	" INTEGRATION # FRAME #    a1           a2             a3          a4         a5" << endl;
    }


    if(control.do_refpixel_option ==6) {
      data_info.output_rp << 
	" This file contains the reference pixel corrections based on the modified mean of each channel for even and odd rows after subtracting Frame 1. " <<endl;
      data_info.output_rp << " Reference pixels from frame 1 subtracted" << endl;
      data_info.output_rp << " Set A = cols 1 to 4, Set B = cols 1029 - 1032" << endl;
      data_info.output_rp <<  
	" INTEGRATION # FRAME #   Ch 1 Even    Odd        Ch 2 Even    Odd        Ch 3 Even    Odd        Ch 4 Even    Odd" << endl;
    }

    

    // _______________________________________________________________________
    if(control.do_refpixel_option == 2) {
      data_info.output_rp << 
	" This file contains the reference pixel corrections based on the slope (S) and the y-intercept (Y-I) " <<endl;
      data_info.output_rp <<  " of the reference border pixels" << endl;
      if(control.delta_refpixel_even_odd !=0) 
	data_info.output_rp << " Number of even/odd delta rows used to find values " << 
	  control.delta_refpixel_even_odd << endl;
      data_info.output_rp << " Columns correspond to:" << endl;
      data_info.output_rp <<  
	" INTEGRATION # FRAME #  Row #  Ch 1  S   Y-I        Ch 2  S   Y-I         Ch 3  S    Y-I        Ch 4  S    Y-I"<< endl;

    }
    // _______________________________________________________________________
    if(control.do_refpixel_option == 1) {
      data_info.output_rp << 
	" This file contains the reference pixel corrections based on a moving mean filter " <<endl;


      data_info.output_rp << " Size of moving mean filter " << 
	  control.delta_refpixel_even_odd << endl;
      data_info.output_rp << " Columns correspond to:" << endl;
      data_info.output_rp <<  
	" INTEGRATION # FRAME #  Row #  Ch 1 Final Mean    Ch 2 Final Mean     Ch 3 Final Mean     Ch 4 Final Mean"<< endl;

    }
    
  }
  //_______________________________________________________________________

  if(control.write_detailed_cr) {
    cout << " Writing Cosmic Ray Information to " << data_info.cr_filename[II] << endl;
    
    data_info.output_cr.open(data_info.cr_filename[II].c_str(), ios::out);
    if( !data_info.output_cr) { // open failed
      cerr << " Can not open the file: " << data_info.cr_filename[II] << endl;
      exit(EXIT_FAILURE);
    }

  }


    if (control.do_verbose == 1) cout << "finished setup output files" << endl;	
}

