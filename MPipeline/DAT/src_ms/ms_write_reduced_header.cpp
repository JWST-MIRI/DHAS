// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//      ms_write_reduced_header.cpp
//
// Purpose:
//
// Open and setup the header for the reduced FITS file (control.raw_bitsbase + ".LVL2.fits" or
//   control.raw_bitsbase + ".FASTMODE_MEAS.fits")
// Write the processing parameters to the header. 
// Fill in the FINAL Slope values (primary header image) with zero data
// 
// If option to write reduced reference image is set (control.write_output_refslope)- 
// then create that file and write header. 
// Write the processing parameters to the header. 
//
// Set up all the output Intermediate FITS files that are to be created.
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
//
//void ms_write_reduced_header(miri_control control,
//			     string preference_filename,
//			     miri_data_info& data_info)
//
//
// Arugments:
//
//  control: miri_control structure containing the processing options
//  preference_filename: name of the preference file that was used. 
//  data_info: miri_data_info structure containing basic information on the dataset
//
//
// Return Value/ Variables modified:
//      No return value.  
// 
//
// History:
//
//	Written by Jane Morrison January 1, 2009
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/
//      7/27/09: morrison, added back copying the orginal header into the refererence corrected
//               data.
#include "miri_sloper.h"
#include "miri_constants.h"
#include "dhas_version.h"
#include <iostream>
#include <stdio.h>
#include <string.h>

void ms_write_reduced_header(miri_control control,
			     string preference_filename,
			     miri_data_info& data_info,
			     miri_CDP CDP)

{


  char yes_str[4] = "Yes"; // string for the yes answer
  char no_str[3] = "No";   // string for the no answer
  int status = 0;
  char version[strlen(dhas_version)+1];
  strcpy(version,dhas_version);

  int SET1 = 1;
  // **********************************************************************

  // open and setup the reduced FITS file
  status =0;

  int II = data_info.this_file_num;
  fits_create_file(&data_info.red_file_ptr, data_info.red_filename[II].c_str(), &status); 
  if(status !=0){
    cout << "******************************" << endl;
    cout << " Problem opening file " << data_info.red_filename[II] << endl;
    cout << " Check if directory exists " <<endl;
    exit(EXIT_FAILURE);
    cout << "******************************" << endl;
  }

  if(control.write_output_refslope == 1) {
    fits_create_file(&data_info.red_ref_file_ptr, data_info.red_ref_filename[II].c_str(), &status); 
    if(status !=0){
      cout << "******************************" << endl;
      cout << " Problem opening file " << data_info.red_ref_filename[II]  << endl;
      cout << " Check if directory exists " <<endl;
      exit(EXIT_FAILURE);
      cout << "******************************" << endl;
    }
  }


  // Set up the primary image - Final Slope, Uncertainty and ID flag

  int filenum = 2;
  if(control.write_output_refslope  == 0) filenum = 1;
  for (int i = 0; i< filenum ; i++){
    fitsfile *file_ptr=0;

    int naxis = 3;
    long naxes[3];
    naxes[2] = 3; // slope, uncertainty, id flag, zero pt
    int bitpix = -32;

    if(i ==0){ // Science Image
      file_ptr = data_info.red_file_ptr;
      naxes[0] = data_info.ramp_naxes[0];
      naxes[1] = data_info.ramp_naxes[1];
    }
    if(i ==1){// reference image
      file_ptr = data_info.red_ref_file_ptr;
      naxes[0] = data_info.ref_naxes[0];
      naxes[1] = data_info.ref_naxes[1];
    }
    if(control.QuickMethod ==1){
      naxis = 2;
      long naxes2[2];
      naxes2[0] = naxes[0];
      naxes2[1] = naxes[1];
      status = 0;
      fits_create_img(file_ptr, bitpix, naxis,naxes2, &status);
      if(status !=0) {
	cout << " ms_write_reduced_header: Problem creating image"<< endl;
	exit(EXIT_FAILURE);
      }
    } else { 

  // **********************************************************************
    // _______________________________________________________________________
  // create an image for the reduced file- cube of data
    
      status = 0;
      fits_create_img(file_ptr, bitpix, naxis,naxes, &status);
      if(status !=0) {
	cout << " ms_write_reduced_header: Problem creating image"<< endl;
	exit(EXIT_FAILURE);
      }
    }

    char extname[19] = "FINAL REDUCED DATA";
    fits_write_key(file_ptr,TSTRING,"EXTNAME",&extname," Extension Name ",&status);

      
  // _______________________________________________________________________
  // copy the header of the raw file to the reduced file
    
    status = 0;

    fits_write_comment(file_ptr, 
		       "**==============================================================**",&status);
    fits_write_comment(file_ptr, 
		       "**=begin RAW file primary header================================**",&status);

    status = 0;
    miri_copy_header(data_info.raw_file_ptr, file_ptr, status);

    fits_write_comment(file_ptr, 
		       "**=end RAW file primary header==================================**",&status);


  // _______________________________________________________________________
    // Write all the processing options to the header 
    int primary = 1;
    int aveint = -1;
    int NFramesBad  = 0;
    vector<int> FrameBad;
    ms_write_processing_to_header(file_ptr,
				  aveint, // integration number flag 
				  i,  // controls the type, science data, reference image
				  control,
				  NFramesBad,FrameBad,
				  preference_filename,data_info,CDP,primary);
  }
  // _______________________________________________________________________
  // Write intermediate files 
  // _______________________________________________________________________
  //***********************************************************************

  if(control.write_output_lc_correction == 1){
    fits_create_file(&data_info.lc_file_ptr, data_info.lc_filename[II].c_str(), &status); 
    if(status !=0){
      cout << "******************************" << endl;
      cout << " Problem opening Linearity Corrected file " << data_info.lc_filename[II] << endl;
      cout << " Check if directory exists " <<endl;
      exit(EXIT_FAILURE);
      cout << "******************************" << endl;
    }
    int naxis = 3;
    long naxes[3];
    int bitpix =-32; 
    naxes[0] = data_info.ramp_naxes[0];
    naxes[1] = data_info.ramp_naxes[1];
    naxes[2] = data_info.raw_naxes[2];

    fits_create_img(data_info.lc_file_ptr, bitpix,naxis,naxes, &status);  // write the primary header- blank image
    if(status !=0) cout << " Problem creating image for Linearity Corrected Data " << endl;
    status = 0;
        fits_write_comment(data_info.lc_file_ptr, 
    		       "Original Header Copied ",&status);
    miri_copy_header(data_info.raw_file_ptr, data_info.lc_file_ptr, status);
    if(status !=0 ) {
      cout << " Did not copy the original header to Linearity Corrected Fits file " << endl;
      cout << " Status " << status << endl;
     }

    fits_write_comment(data_info.lc_file_ptr, "**--------------------------------------------------------------**",&status);
    fits_write_comment(data_info.lc_file_ptr, "file created by miri_sloper program",&status);
    fits_write_comment(data_info.lc_file_ptr, "MIRI Team Pipeline",&status);
    fits_write_comment(data_info.lc_file_ptr, "Jane Morrison",&status);
    fits_write_comment(data_info.lc_file_ptr, "email morrison@as.arizona.edu for info",&status);
    fits_write_comment(data_info.lc_file_ptr, "**--------------------------------------------------------------**",&status);
    fits_write_comment(data_info.lc_file_ptr, "This file contains linearity corrected data",&status);

    fits_write_key(data_info.lc_file_ptr, TSTRING, "MS_VER", &version, "miri_sloper version", &status);

    int istart = control.n_reads_start_fit + 1;
    fits_write_key(data_info.lc_file_ptr, TINT, "NSFITS", &istart, 
		   "Frame number to start reference correction", &status);

    int iend = control.n_reads_end_fit + 1;
    fits_write_key(data_info.lc_file_ptr, TINT, "NSFITE", &iend, 
		   "Frame number to end reference correction", &status);

    int lin_order = CDP.GetLinOrder();
    fits_write_key(data_info.lc_file_ptr, TINT, "LORDER", &lin_order, 
		   "Linearity Correction Order", &status);


  }
  //_______________________________________________________________________
  // Write Dark Corrected data
  if(control.write_output_dark_correction == 1 && control.subtract_dark){
    fits_create_file(&data_info.dark_file_ptr, data_info.dark_filename[II].c_str(), &status); 
    if(status !=0){
      cout << "******************************" << endl;
      cout << " Problem opening Mean Dark Corrected file " << data_info.dark_filename[II] << endl;
      cout << " Check if directory exists " <<endl;
      exit(EXIT_FAILURE);
      cout << "******************************" << endl;
     }
    int naxis = 3;
    long naxes[3];
    int bitpix =-32; 
    naxes[0] = data_info.ramp_naxes[0];
    naxes[1] = data_info.ramp_naxes[1];
    naxes[2] = data_info.raw_naxes[2];

    fits_create_img(data_info.dark_file_ptr, bitpix,naxis,naxes, &status);  // write the primary header- blank image
    if(status !=0) cout << " Problem creating image for Mean Dark Corrected Data " << endl;
    status = 0;
        fits_write_comment(data_info.dark_file_ptr, 
    		       "Original Header Copied ",&status);
    miri_copy_header(data_info.raw_file_ptr, data_info.dark_file_ptr, status);
    if(status !=0 ) {
      cout << " Did not copy the original header to Mean Dark Corrected Fits file " << endl;
      cout << " Status " << status << endl;
     }

      fits_write_comment(data_info.dark_file_ptr, "**--------------------------------------------------------------**",&status);
    fits_write_comment(data_info.dark_file_ptr, "file created by miri_sloper program",&status);
    fits_write_comment(data_info.dark_file_ptr, "MIRI Team Pipeline",&status);
    fits_write_comment(data_info.dark_file_ptr, "Jane Morrison",&status);
    fits_write_comment(data_info.dark_file_ptr, "email morrison@as.arizona.edu for info",&status);
    fits_write_comment(data_info.dark_file_ptr, "**--------------------------------------------------------------**",&status);
    fits_write_comment(data_info.dark_file_ptr, "This file contains Mean Dark corrected data",&status);

    fits_write_key(data_info.dark_file_ptr, TSTRING, "MS_VER", &version, "miri_sloper version", &status);

    int istart = control.n_reads_start_fit + 1;
    fits_write_key(data_info.dark_file_ptr, TINT, "NSFITS", &istart, 
    		   "Frame number to start  correction", &status);

    int iend = control.n_reads_end_fit + 1;
    fits_write_key(data_info.dark_file_ptr, TINT, "NSFITE", &iend, 
    		   "Frame number to end  correction", &status);

  }

  //_______________________________________________________________________
// Write Reset Corrected data
  if(control.write_output_reset_correction == 1){
    fits_create_file(&data_info.reset_file_ptr, data_info.reset_filename[II].c_str(), &status); 
    if(status !=0){
      cout << "******************************" << endl;
      cout << " Problem opening Reset Corrected file " << data_info.reset_filename[II] << endl;
      cout << " Check if directory exists " <<endl;
      exit(EXIT_FAILURE);
      cout << "******************************" << endl;
     }
    int naxis = 3;
    long naxes[3];
    int bitpix =-32; 
    naxes[0] = data_info.ramp_naxes[0];
    naxes[1] = data_info.ramp_naxes[1];
    naxes[2] = data_info.raw_naxes[2];

    fits_create_img(data_info.reset_file_ptr, bitpix,naxis,naxes, &status);  // write the primary header- blank image
    if(status !=0) cout << " Problem creating image for Resetk Corrected Data " << endl;
    status = 0;
        fits_write_comment(data_info.reset_file_ptr, 
    		       "Original Header Copied ",&status);
    miri_copy_header(data_info.raw_file_ptr, data_info.reset_file_ptr, status);
    if(status !=0 ) {
      cout << " Did not copy the original header to Reset Corrected Fits file " << endl;
      cout << " Status " << status << endl;
     }

    fits_write_comment(data_info.reset_file_ptr, "**--------------------------------------------------------------**",&
status);
    fits_write_comment(data_info.reset_file_ptr, "file created by miri_sloper program",&status);
    fits_write_comment(data_info.reset_file_ptr, "MIRI Team Pipeline",&status);
    fits_write_comment(data_info.reset_file_ptr, "Jane Morrison",&status);
    fits_write_comment(data_info.reset_file_ptr, "email morrison@as.arizona.edu for info",&status);
    fits_write_comment(data_info.reset_file_ptr, "**--------------------------------------------------------------**",&status);
    fits_write_comment(data_info.reset_file_ptr, "This file contains Reset corrected data",&status);

    fits_write_key(data_info.reset_file_ptr, TSTRING, "MS_VER", &version, "miri_sloper version", &status);

    int istart = control.n_reads_start_fit + 1;
    fits_write_key(data_info.reset_file_ptr, TINT, "NSFITS", &istart, 
    		   "Frame number to start  correction", &status);

    int iend = control.n_reads_end_fit + 1;
    fits_write_key(data_info.reset_file_ptr, TINT, "NSFITE", &iend, 
    		   "Frame number to end  correction", &status);

  }



  //_______________________________________________________________________
  // Write RSCD Corrected data
  if(control.write_output_rscd_correction == 1){
    fits_create_file(&data_info.rscd_file_ptr, data_info.rscd_filename[II].c_str(), &status); 
    if(status !=0){
      cout << "******************************" << endl;
      cout << " Problem opening RSCD Corrected file " << data_info.rscd_filename[II] << endl;
      cout << " Check if directory exists " <<endl;
      exit(EXIT_FAILURE);
      cout << "******************************" << endl;
     }
    int naxis = 3;
    long naxes[3];
    int bitpix =-32; 
    naxes[0] = data_info.ramp_naxes[0];
    naxes[1] = data_info.ramp_naxes[1];
    naxes[2] = data_info.raw_naxes[2];

    fits_create_img(data_info.rscd_file_ptr, bitpix,naxis,naxes, &status);  // write the primary header- blank image
    if(status !=0) cout << " Problem creating image for RSCD Corrected Data " << endl;
    status = 0;
        fits_write_comment(data_info.rscd_file_ptr, 
    		       "Original Header Copied ",&status);
    miri_copy_header(data_info.raw_file_ptr, data_info.rscd_file_ptr, status);
    if(status !=0 ) {
      cout << " Did not copy the original header to Rscd Corrected Fits file " << endl;
      cout << " Status " << status << endl;
     }

      fits_write_comment(data_info.rscd_file_ptr, "**--------------------------------------------------------------**",&status);
    fits_write_comment(data_info.rscd_file_ptr, "file created by miri_sloper program",&status);
    fits_write_comment(data_info.rscd_file_ptr, "MIRI Team Pipeline",&status);
    fits_write_comment(data_info.rscd_file_ptr, "Jane Morrison",&status);
    fits_write_comment(data_info.rscd_file_ptr, "email morrison@as.arizona.edu for info",&status);
    fits_write_comment(data_info.rscd_file_ptr, "**--------------------------------------------------------------**",&status);
    fits_write_comment(data_info.rscd_file_ptr, "This file contains Rscd corrected data",&status);

    fits_write_key(data_info.rscd_file_ptr, TSTRING, "MS_VER", &version, "miri_sloper version", &status);

    int istart = control.n_reads_start_fit + 1;
    fits_write_key(data_info.rscd_file_ptr, TINT, "NSFITS", &istart, 
    		   "Frame number to start  correction", &status);

    int iend = control.n_reads_end_fit + 1;
    fits_write_key(data_info.rscd_file_ptr, TINT, "NSFITE", &iend, 
    		   "Frame number to end  correction", &status);

  }



  //_______________________________________________________________________
  // Write lastframe correction 
  if(control.write_output_lastframe_correction == 1){
    fits_create_file(&data_info.lastframe_file_ptr, data_info.lastframe_filename[II].c_str(), &status); 
    if(status !=0){
      cout << "******************************" << endl;
      cout << " Problem opening lastframe Corrected file " << data_info.lastframe_filename[II] << endl;
      cout << " Check if directory exists " <<endl;
      exit(EXIT_FAILURE);
      cout << "******************************" << endl;
     }


    fits_create_img(data_info.lastframe_file_ptr,8,0,0,&status);
    
    if(status !=0) cout << " Problem image for last frame Corrected Data " << endl;
    status = 0;
    fits_write_comment(data_info.lastframe_file_ptr, 
    		       "Original Header Copied ",&status);
    miri_copy_header(data_info.raw_file_ptr, data_info.lastframe_file_ptr, status);
    if(status !=0 ) {
      cout << " Did not copy the original header to Lastframe Corrected Fits file " << endl;
      cout << " Status " << status << endl;
     }

    fits_write_comment(data_info.lastframe_file_ptr, "**--------------------------------------------------------------**",&status);
    fits_write_comment(data_info.lastframe_file_ptr, "file created by miri_sloper program",&status);
    fits_write_comment(data_info.lastframe_file_ptr, "MIRI Team Pipeline",&status);
    fits_write_comment(data_info.lastframe_file_ptr, "Jane Morrison",&status);
    fits_write_comment(data_info.lastframe_file_ptr, "email morrison@as.arizona.edu for info",&status);
    fits_write_comment(data_info.lastframe_file_ptr, "**--------------------------------------------------------------**",&status);
    fits_write_comment(data_info.lastframe_file_ptr, "This file contains Lastframe corrected data",&status);

    fits_write_key(data_info.lastframe_file_ptr, TSTRING, "MS_VER", &version, "miri_sloper version", &status);
    //for (int i=0;i<data_info.NInt; i++){
    // int naxis2 = 2;
    //long naxes2[2];

    //naxes2[0] = data_info.ramp_naxes[0];
    // naxes2[1] = data_info.ramp_naxes[1];
    //int bitpix = -32;
    //fits_create_img(data_info.lastframe_file_ptr, bitpix,naxis2,naxes2, &status);  // write the extension blank image
    //if(status !=0) cout << " Problem creating extension image for lastframe Corrected Data " << endl;
    //status = 0;
    //fits_write_comment(data_info.lastframe_file_ptr, "**--------------------------------------------------------------**",&status);
    //fits_write_comment(data_info.lastframe_file_ptr, "file created by miri_sloper program",&status);
    //fits_write_comment(data_info.lastframe_file_ptr, "MIRI Team Pipeline",&status);
    //fits_write_comment(data_info.lastframe_file_ptr, "Jane Morrison",&status);
    //fits_write_comment(data_info.lastframe_file_ptr, "email morrison@as.arizona.edu for info",&status);
    //fits_write_comment(data_info.lastframe_file_ptr, "**--------------------------------------------------------------**",&status);
    //}
    

  }

  //***********************************************************************
  if(control.write_output_refpixel_corrections ==1 ){
    fits_create_file(&data_info.rc_file_ptr, data_info.rc_filename[II].c_str(), &status); 
    if(status !=0){
      cout << "******************************" << endl;
      cout << " Problem opening Reference Pixel Corrected file " << data_info.rc_filename[II] << endl;
      cout << " Check if directory exists " <<endl;
      cout << " Status " << status << endl;
      exit(EXIT_FAILURE);
      cout << "******************************" << endl;
    }
    int naxis = 3;
    long naxes[3];
    int bitpix =-32; 
    naxes[0] = data_info.ramp_naxes[0];
    naxes[1] = data_info.ramp_naxes[1];
    naxes[2] = data_info.raw_naxes[2];


    fits_create_img(data_info.rc_file_ptr, bitpix,naxis,naxes, &status);  // write the primary header- blank image
    if(status !=0) cout << " Problem creating image for Reference Corrected Data " << endl;
    status = 0;
        fits_write_comment(data_info.rc_file_ptr, 
    		       "Original Header Copied ",&status);
    miri_copy_header(data_info.raw_file_ptr, data_info.rc_file_ptr, status);
    if(status !=0 ) {
      cout << " Did not copy the original header to Reference Corrected Fits file " << endl;
      cout << " Status " << status << endl;
     }

    fits_write_comment(data_info.rc_file_ptr, "**--------------------------------------------------------------**",&status);
    fits_write_comment(data_info.rc_file_ptr, "file created by miri_sloper program",&status);
    fits_write_comment(data_info.rc_file_ptr, "MIRI Team Pipeline",&status);
    fits_write_comment(data_info.rc_file_ptr, "Jane Morrison",&status);
    fits_write_comment(data_info.rc_file_ptr, "email morrison@as.arizona.edu for info",&status);
    fits_write_comment(data_info.rc_file_ptr, "**--------------------------------------------------------------**",&status);
    fits_write_comment(data_info.rc_file_ptr, "This file contains reference corrected data",&status);

    fits_write_key(data_info.rc_file_ptr, TSTRING, "MS_VER", &version, "miri_sloper version", &status);
    fits_write_key(data_info.rc_file_ptr, TINT, "REFCOR", &SET1, "This file contains reference corrected data for each pixel", &status);

    int istart = control.n_reads_start_fit + 1;
    fits_write_key(data_info.rc_file_ptr, TINT, "NSFITS", &istart, 
		   "Frame number to start reference correction", &status);

    int iend = control.n_reads_end_fit + 1;
    fits_write_key(data_info.rc_file_ptr, TINT, "NSFITE", &iend, 
		   "Frame number to end reference correction", &status);


  if (control.do_refpixel_option ==0)
    fits_write_key(data_info.rc_file_ptr, TSTRING, "SUBRP1", no_str, 
		   "Did not use reference pixels to correct data", &status);

  if(control.do_refpixel_option !=0){
    fits_write_key(data_info.rc_file_ptr, TINT, "RFREJFS", &control.refpixel_filter_size, 
		   "Ref Pixel Outlier Reject Filter Size Window", &status);

    fits_write_key(data_info.rc_file_ptr, TFLOAT, "RFREJSG", &control.refpixel_sigma_clip, 
		   "Ref Pixel Outlier Reject Sigma ", &status);  
  }

  if (control.do_refpixel_option ==2){
    fits_write_key(data_info.rc_file_ptr, TSTRING, "SUBRP2", yes_str, 
		   "Used Ref Pixels using option 2", &status);

      fits_write_key(data_info.rc_file_ptr, TINT, "DELTARP", &control.delta_refpixel_even_odd,
		     "# of +/- Rows (even/odd) used to find Ref Pixel correction, option 2", &status);
  }

  if (control.do_refpixel_option ==1){
    fits_write_key(data_info.rc_file_ptr, TSTRING, "SUBRP1", yes_str, 
		   "Used Ref Pixels using option 1", &status);

      fits_write_key(data_info.rc_file_ptr, TINT, "DELFILT", &control.delta_refpixel_even_odd,
		     "size of moving filter", &status);
  }

  if (control.do_refpixel_option ==7)
    fits_write_key(data_info.rc_file_ptr, TSTRING, "SUBRP7", yes_str, 
		   "Used Ref Pixels using option 7", &status);

  if (control.do_refpixel_option ==6)
    fits_write_key(data_info.rc_file_ptr, TSTRING, "SUBRP6", yes_str, 
		   "used Ref Pixels using option 6", &status);


  if(control.write_output_refpixel_corrections ==1)
    fits_write_key(data_info.rc_file_ptr, TSTRING, "WREFPIXC", yes_str, 
		   "Wrote reference pixel correction FITS file", &status);


  
  fits_write_key(data_info.rc_file_ptr, TFLOAT, "HIGHSAT", &control.dn_high_sat, "High Saturation Value", &status);
  

  }
  //***********************************************************************

  //***********************************************************************
  if(control.write_segment_output ==1 ){
    fits_create_file(&data_info.sg_file_ptr, data_info.sg_filename[II].c_str(), &status); 
    if(status !=0){
      cout << "******************************" << endl;
      cout << " Problem opening Segments file " << data_info.sg_filename[II] << endl;
      cout << " Check if directory exists " <<endl;
      cout << " Status " << status << endl;
      exit(EXIT_FAILURE);
      cout << "******************************" << endl;
    }
    int naxis = 0;
    long naxes[2];
    int bitpix =8; 
    naxes[0] = 0;
    naxes[1] = 0;

    fits_create_img(data_info.sg_file_ptr, bitpix,naxis,naxes, &status);  // write the primary header- blank image
    if(status !=0) cout << " Problem creating image for Segment Data " << endl;
    status = 0;

    fits_write_comment(data_info.sg_file_ptr, "**--------------------------------------------------------------**",&status);
    fits_write_comment(data_info.sg_file_ptr, "file created by miri_sloper program",&status);
    fits_write_comment(data_info.sg_file_ptr, "MIRI Team Pipeline",&status);
    fits_write_comment(data_info.sg_file_ptr, "Jane Morrison",&status);
    fits_write_comment(data_info.sg_file_ptr, "email morrison@as.arizona.edu for info",&status);
    fits_write_comment(data_info.sg_file_ptr, "**--------------------------------------------------------------**",&status);

    fits_write_comment(data_info.sg_file_ptr, "This file contains information on the Segments",&status);
    fits_write_comment(data_info.sg_file_ptr, "Each extension contains the information for different segments",&status);
    fits_write_comment(data_info.sg_file_ptr, " Segment 1 information is in the first extension",&status);
    fits_write_comment(data_info.sg_file_ptr, " Segment 2 information (if it exists) is in the second extension, and so on",&status);
    fits_write_key(data_info.sg_file_ptr, TSTRING, "MS_VER", &version, "miri_sloper version", &status);
    fits_write_key(data_info.sg_file_ptr, TINT, "SEGMENTS", &SET1, "This file contains Segment information for each pixel", &status);

  }
  //***********************************************************************


  if(control.write_output_ids ==1 ){
    if(control.do_verbose) cout << " Creating ID Fits file" << endl;

    fits_create_file(&data_info.id_file_ptr, data_info.id_filename[II].c_str(), &status); 
    if(status !=0){
      cout << "******************************" << endl;
      cout << " Problem opening ID file " << data_info.id_filename[II] << endl;
      cout << " Check if directory exists " <<endl;
      cout << " Status " << status << endl;
      exit(EXIT_FAILURE);
      cout << "******************************" << endl;
    }

    if(control.do_verbose) cout << " Created ID Fits file" << endl;
    int naxis = 3;
    long naxes[3];
    int bitpix =16; 
    naxes[0] = data_info.ramp_naxes[0];
    naxes[1] = data_info.ramp_naxes[1];
    naxes[2] = data_info.raw_naxes[2];

    if(control.do_verbose) cout << " Image Size" << naxes[0] << " " << naxes[1] << " " << naxes[2] <<  endl;
    fits_create_img(data_info.id_file_ptr, bitpix,naxis,naxes, &status);  // write the primary header- blank image
    if(status !=0) cout << " Problem creating image for ID  Data " << endl;
    status = 0;

    // fill in frames that are not used in the fits with -1

    if(control.n_reads_start_fit > 0  || control.n_reads_end_fit > data_info.NRamps ) {
      long fpixel[3] ;
      long lpixel[3];

      // lower left corner of subset<
      fpixel[0]= 1;
      fpixel[1]= 1;

      // number of rows of data to read in  
      lpixel[0] = data_info.ramp_naxes[0];
      lpixel[1] = data_info.ramp_naxes[1];

    // first fill in the leading frames
      for (int i=0;i<data_info.NInt; i++){
	if(control.n_reads_start_fit >0) {
	  int istart = i*data_info.NRamps+1;

    // write -1 to the frames that are not used in the fit
	  fpixel[2]=istart;
	  lpixel[2]=istart + control.n_reads_start_fit-1;
	  
	  long ixyz = data_info.ramp_naxes[0] * data_info.ramp_naxes[1] * control.n_reads_start_fit;

	  vector<int>   idata(ixyz,-1);

	  status = 0;

	  fits_write_subset_int(data_info.id_file_ptr, 0, naxis, naxes, 
				fpixel,lpixel,
				&idata[0], &status);
	  //cout << " Wrote initial -1 for 7 planes " << endl;

	  if(status != 0) {
	    cout <<" ms_write_reduced_data: Problem writing IDs data- setting initial unused frames to -1 " << endl;
	    cout << " status " << status << endl;
	    exit(EXIT_FAILURE);
	  }

	} // n_reads_start_fit ge 1

	if(control.n_reads_end_fit < data_info.NRamps ) {

	  int iend = (i+1)*data_info.NRamps;
	  int fend = data_info.NRamps - (control.n_reads_end_fit+1) ;
	  int istart = iend - fend + 1; 
	    
	  //cout << " orginal istart iend " << istart << " " << iend << endl;

    // write -1 to the frames that are not used in the fit
	  // if too many planes are to = -1, can get a allocation problem

	  fpixel[2]=istart;
	  lpixel[2]=iend;
	  int nframes = (iend - istart)+1;
	  //_______________________________________________________________________
	  // number of frames to write -1 for is too large - break it up 
	  if(nframes > control.frame_limit) {
	    int nsets = nframes/control.frame_limit;
	    int jk_start = istart;
	    if(control.do_verbose ) {
	      cout << " Broke up writing ID files in " << nsets << " of frames size" << control.frame_limit <<endl;
	    }
	    for (int jk = 0; jk<nsets; jk++) {
	      int jk_end = jk_start+ control.frame_limit;
	      if(jk_end > iend) jk_end = iend;
	      int new_nframes = jk_end - jk_start + 1;
	      fpixel[2]=jk_start;
	      lpixel[2]=jk_end;
	      if(control.do_verbose) cout<< "Setting frames=-1,not used in fit " <<jk_start<< " " <<jk_end << endl; 
	      long ixyz = data_info.ramp_naxes[0] * data_info.ramp_naxes[1] * new_nframes;
	      
	      vector<int>   idata(ixyz,-1);
	      status = 0;
	      fits_write_subset_int(data_info.id_file_ptr, 0, naxis, naxes, 
				    fpixel,lpixel,
				    &idata[0], &status);

	      if(status != 0) {
		cout <<" ms_write_reduced_data: Problem writing IDs data- setting initial unused frames to -1 " << endl;
		cout << " status " << status << endl;
		exit(EXIT_FAILURE);
	      }
	      jk_start = jk_end+1;
		  
	    }

	  //_______________________________________________________________________
	  }else{
	    //	    cout << fpixel[2] << " " << lpixel[2] << " " << control.n_reads_end_fit << endl;
	    long ixyz = data_info.ramp_naxes[0] * data_info.ramp_naxes[1] * nframes;
	    vector<int>   idata(ixyz,-1);
	    status = 0;
	    fits_write_subset_int(data_info.id_file_ptr, 0, naxis, naxes, 
				fpixel,lpixel,
				&idata[0], &status);

	    if(status != 0) {
	      cout <<" ms_write_reduced_data: Problem writing IDs data- setting initial unused frames to -1 " << endl;
	      cout << " status " << status << endl;
	      exit(EXIT_FAILURE);
	    }
	  }
	  //_______________________________________________________________________

	} // n_reads_start_fit ge 1
      } // loop over integrations
    } // need to write -1 frames
  //_______________________________________________________________________



    fits_write_comment(data_info.id_file_ptr, 
    		       "Original Header Copied ",&status);
    miri_copy_header(data_info.raw_file_ptr, data_info.id_file_ptr, status);
    if(status !=0 ) {
      cout << " Did not copy the original header to ID file " << endl;
      cout << " Status " << status << endl;
    }


    fits_write_comment(data_info.id_file_ptr, "**--------------------------------------------------------------**",&status);
    fits_write_comment(data_info.id_file_ptr, "file created by miri_sloper program",&status);
    fits_write_comment(data_info.id_file_ptr, "MIRI Team Pipeline",&status);
    fits_write_comment(data_info.id_file_ptr, "Jane Morrison",&status);
    fits_write_comment(data_info.id_file_ptr, "email morrison@as.arizona.edu for info",&status);
    fits_write_comment(data_info.id_file_ptr, "**--------------------------------------------------------------**",&status);
    fits_write_comment(data_info.id_file_ptr, "This file contains the IDs assigned to all the frames for each pixel   ",&status);
    fits_write_comment(data_info.id_file_ptr, "ID = 1, flagged as bad pixel from  the bad pixel mask",&status);
    fits_write_comment(data_info.id_file_ptr, "ID = 2, contains data above  global saturation limit",&status);
    fits_write_comment(data_info.id_file_ptr, "ID = 4, possible cosmic ray",&status);

    fits_write_comment(data_info.id_file_ptr, "ID = 8 or 16, noise anomaly or low level cosmic ray",&status);

    fits_write_comment(data_info.id_file_ptr, "ID = 64, No dark correction for pixel",&status);
    fits_write_comment(data_info.id_file_ptr, "ID = 128, No electronic linearity correction for pixel",&status);
    fits_write_comment(data_info.id_file_ptr, "ID = 256, Data outside electronic linearity correction",&status);

    fits_write_comment(data_info.id_file_ptr, "ID =512 , No lastframe  correction for pixel",&status);

    fits_write_comment(data_info.id_file_ptr, "ID =-2, Corrupt Frame",&status);
    fits_write_comment(data_info.id_file_ptr, "ID =-8, reject after  noise jump",&status);
    fits_write_comment(data_info.id_file_ptr, "ID =-4, value rejected after a cosmic ray",&status);
    fits_write_comment(data_info.id_file_ptr, "ID =-16, failed minimum number frames in segment",&status);
    fits_write_comment(data_info.id_file_ptr, "ID =-16, failed slope segment consistency testing",&status);

     fits_write_key(data_info.id_file_ptr, TSTRING, "MS_VER", &version, "miri_sloper version", &status);
    fits_write_key(data_info.id_file_ptr, TINT, "IDS", &SET1, "This file contains the IDs for each pixel", &status);


  } // done writing id file
      

    if (control.do_verbose == 1) cout << "finished writing reduced header" << endl;	

}
