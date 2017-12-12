// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//
//      ms_filenames.cpp
//
// Purpose:
//
// This program defines the input and output file names for miri_sloper. 
// If the user provides a list of files to process (instead of a single FITS file), then
// this program will read in list of FITS files to process.
// Also if the user has used the -o option to set the filename prefixes then
// this program forms the output names using the user provided prefix. If the user
// did not use the -o option then the prefix is equal to the name of the input file
// without the .fits. So if the input file was 
// MIRI_VM2T00003045_1_IM_S_2008-09-08T11h01m58.fits
// The Output filenames will be:
// MIRI_VM2T00003045_1_IM_S_2008-09-08T11h01m58_LVL2.fits
// MIRI_VM2T00003045_1_IM_S_2008-09-08T11h01m58_LVL2_REF.fits
//
// There are a number of options the user can select to write out addition output
// files 
// -OL option:  writes out the linearity  corrected data the filename the filename will be
//      MIRI_VM2T00003045_1_IM_S_2008-09-08T11h01m58_LinCorrected.fits
// -OR option:  writes out the reference corrected data the filename the filename will be
//      MIRI_VM2T00003045_1_IM_S_2008-09-08T11h01m58_RefCorrection.fits
// -OC option: write information on cosmic ray detection. The filename will be 
//     MIRI_VM2T00003045_1_IM_S_2008-09-08T11h01m5_cosmic_rays.txt
// -OI option: write the intermediate file containing the data quality flag given
//      to all the pixels sample-up-the-ramp frames. . The filename will be 
//     MIRI_VM2T00003045_1_IM_S_2008-09-08T11h01m5_IDS.fits
// -OS option: writes the intermediate file containing the segments of all the pixels. 
//     The filename will be  MIRI_VM2T00003045_1_IM_S_2008-09-08T11h01m5_SEGMENTS.fits
// -Op option: writes information on the reference pixel corrections applied to each frame.
//     The filename will be (depending on the reference pixel option chosen something
//     like  MIRI_VM2T00003045_1_IM_S_2008-09-08T11h01m58_RefPixelCorr_Option3.txt
// -Ord write RSCD corrected data
// -Or  write reset corrected data
       
// Author:
//
//	Jane Morrison
//      University of Arizona
//      email: morrison@as.arizona.edu
//      phone: 520-626-3181
// 
// Calling Sequence:
//
//void ms_filenames(miri_data_info& data_info, miri_control control)
//
// Arguments:
//
// data_info: miri_data_info structure containing basic information on the file
//            to process.
// control: miri_control structure containing the processing options
//
//
// Return Value/ Variables modified:
//      No return value.
// The filenames contained in the data_info structure are filled in with the correct names
//
// History:
//
//	Written by Jane Morrison 2004
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/

#include <iostream>
#include <vector>
#include <string>
#include <cstring>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_control.h"

void ms_filenames(miri_data_info& data_info, miri_control control)

{
  // get the base file name of the raw data and get basic information about the dataset
  // making sure a file has actually been specified

  // remove the .fits if it exists

  int numFiles = 1;
  string output_name ="null";
  string output_ref_name ="null";

  size_t fs = control.raw_fitsbase.find("fits");
  if (fs == string::npos) {
    //    unsigned int FS = control.raw_fitsbase.find("FITS");
    size_t FS = control.raw_fitsbase.find("FITS");
    if (FS == string::npos) {
      cout << " Input file is a list of files " << endl;

      data_info.input_list = control.raw_fitsbase;

      ifstream inputNames(data_info.input_list.c_str(),ios::in);
      if(!inputNames){
	cout << " Input list of FITS files could not be opened or You forgot the .fits on the end of the filename" << endl;
        exit(EXIT_FAILURE);
      }
      
      string ifile;
      while(inputNames >> ifile){
	data_info.filenames.push_back(ifile);
	numFiles++;
      }
      numFiles--;

    }
  }

  if(numFiles ==1 ) data_info.filenames.push_back(control.raw_fitsbase);

  data_info.numFiles  = numFiles;

  //_______________________________________________________________________
  if(control.do_verbose) {
    cout << " Number of files " << numFiles << endl;
    cout << " Input file names " << endl;
    for (int i = 0; i < numFiles; i++){
      cout << data_info.filenames[i] << endl;
    }
  }

  // _______________________________________________________________________
  // Figure out the name of the output file from the input file name
  // _______________________________________________________________________
  for (int i = 0; i< numFiles ; i++) {
    string file = data_info.filenames[i];

    string raw_fitsbase = file.substr(0,file.size()-5);
    data_info.raw_filename.push_back (control.scidata_dir + raw_fitsbase + ".fits");
    output_name =  raw_fitsbase + "_LVL2.fits";
    output_ref_name =  raw_fitsbase + "_LVL2_REF.fits";
    if(control.do_Pulse_Mode ==1)     output_name =  raw_fitsbase + "_PulseAmp.fits";
  
  // _______________________________________________________________________
  // Use the user provided output filename
  // _______________________________________________________________________
    if(control.flag_output_name ==1) {
      if(control.do_Pulse_Mode ==1) {
	output_name = control.output_name;
	size_t fitspos = control.output_name.find(".fits");
	if (fitspos != string::npos) {
	  output_name = output_name.substr(0,output_name.size()-5);
	}
	size_t lvl2 = output_name.find("PulseAmp");
	if (lvl2 == string::npos) {
	output_name = output_name + "_PulseAmp.fits";
	}else{
	  output_name = output_name + ".fits";
	}
	raw_fitsbase = output_name.substr(0,output_name.size()-10);



      }else {
	output_name = control.output_name;
	size_t fitspos = control.output_name.find(".fits");
	if (fitspos != string::npos) {
	  output_name = output_name.substr(0,output_name.size()-5);
	}
	size_t lvl2 = output_name.find("LVL2");
	if (lvl2 == string::npos) {
	output_name = output_name + "_LVL2.fits";
	}else{
	  output_name = output_name + ".fits";
	}
	raw_fitsbase = output_name.substr(0,output_name.size()-10);
	output_ref_name = raw_fitsbase + "_LVL2_REF.fits";
      }
    }

    cout << " Output file " << output_name <<  endl;
    data_info.red_filename.push_back( "!" + control.scidata_out_dir + output_name);
    data_info.red_ref_filename.push_back("!" + control.scidata_out_dir +output_ref_name);
  // _______________________________________________________________________
  // Work out the name of the other output file names
  // _______________________________________________________________________

    if(control.write_output_lc_correction == 1) {
      string lc_file = raw_fitsbase + "_LinCorrected.fits";
      data_info.lc_filename.push_back("!" + control.scidata_out_dir + lc_file);
    }

    if(control.write_output_refpixel_corrections == 1) {
      string rc_file = raw_fitsbase + "_RefCorrection.fits";
      data_info.rc_filename.push_back("!" + control.scidata_out_dir + rc_file);
    }

    if(control.write_output_ids == 1) {
      string id_file = raw_fitsbase + "_IDS.fits";
      data_info.id_filename.push_back("!" + control.scidata_out_dir + id_file);
    }


    if(control.write_output_dark_correction == 1) {
      string dark_file = raw_fitsbase + "_DarkCorrected.fits";
      data_info.dark_filename.push_back("!" + control.scidata_out_dir + dark_file);
    }


    if(control.write_output_rscd_correction == 1) {
      string rscd_file = raw_fitsbase + "_RSCDCorrected.fits";
      data_info.rscd_filename.push_back("!" + control.scidata_out_dir + rscd_file);
    }

    if(control.write_output_reset_correction == 1) {
      string reset_file = raw_fitsbase + "_ResetCorrected.fits";
      data_info.reset_filename.push_back("!" + control.scidata_out_dir + reset_file);
    }

    if(control.write_output_lastframe_correction == 1) {
      string lastframe_file = raw_fitsbase + "_LastFrameCorrected.fits";
      data_info.lastframe_filename.push_back("!" + control.scidata_out_dir + lastframe_file);
    }

    if(control.write_segment_output == 1) {
      string id_file = raw_fitsbase + "_SEGMENTS.fits";
      data_info.sg_filename.push_back("!" + control.scidata_out_dir + id_file);
    }

    
    if(control.write_output_refpixel == 1){
      string output_ref ="null";

      if(control.do_refpixel_option == 2) {
	output_ref =  raw_fitsbase + "_RefPixelCorr_Option2.txt";
      }
      
      if(control.do_refpixel_option == 7) {
	output_ref =  raw_fitsbase + "_RefPixelCorr_Option7.txt";
      }

      if(control.do_refpixel_option == 6) {
	output_ref =  raw_fitsbase + "_RefPixelCorr_Option6.txt";
      }

      if(control.do_refpixel_option == 1) {
	output_ref =  raw_fitsbase + "_RefPixelCorr_Option1.txt";
      }
      data_info.output_refpixel.push_back(control.scidata_out_dir + output_ref);
    }


    if(control.write_detailed_cr == 1){
      string output_cr ="null";
      output_cr = raw_fitsbase + "_cosmic_rays.txt";
      data_info.cr_filename.push_back(control.scidata_out_dir + output_cr);
    }


    data_info.raw_fitsbase.push_back(raw_fitsbase);
  // _______________________________________________________________________
    cout << " Raw fits base              " << data_info.raw_fitsbase[i] << endl;
    cout << " Raw filename               " << data_info.raw_filename[i] << endl;
    cout << " Output filename            " << data_info.red_filename[i] << endl;
    if(control.write_output_refslope == 1) 
      cout << " Output Reference Filename  " << data_info.red_ref_filename[i] << endl;

    if(control.write_output_refpixel == 1) 
      cout << " Output reference correction filename " << data_info.output_refpixel[i] << endl;


    if(control.write_output_lastframe_correction == 1) 
      cout << " Output Last Frame correction filename " << data_info.lastframe_filename[i] << endl;

    if(control.write_output_rscd_correction == 1) 
      cout << " Output RSCD correction filename " << data_info.rscd_filename[i] << endl;


    if(control.write_output_lc_correction ==1)
      cout << " Data with Linearity Correction applied (intermediate file)" << data_info.lc_filename[i] << endl;

    if(control.write_segment_output ==1)
      cout << " Data with Slope Segment results (intermediate file)" << data_info.sg_filename[i] << endl;


    if(control.write_detailed_cr == 1)
      cout << " Cosmic ray information found in file " << data_info.cr_filename[i] << endl;

    if(control.write_output_refpixel_corrections ==1)
      cout << " Data with Reference Pixels applied (intermediate file) " << data_info.rc_filename[i] << endl;
    
    if(control.write_output_ids ==1)
      cout << " ID flags written to file "<< data_info.id_filename[i] << endl;
  // _______________________________________________________________________
  // test if raw file exists

    int status = 0;
    int testfile = 0;
    fits_file_exists(data_info.raw_filename[i].c_str(),&testfile,&status);
    if( testfile !=1) { // open failed
      cout << " Can not open the file: " << data_info.raw_filename[i] << endl;
      cout << " Is the directory correct ? " << endl;
      cout << "    If not either modify preference file or commandline option -DI" << endl;
      cout << " Is the filename correct ? "  << endl;
    cout << "    If not you provided an incorrect name (case sensitive) " << endl;
     exit(EXIT_FAILURE);
    }
  }

}
