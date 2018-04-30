// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//    ms_read_header.cpp
//
// Purpose:
// 	Read in the header of the file being processed. Fill in the
//      data_info structure with basic information of the data set, such as,
//      number of integrations, number of frames/integration, detector
//      mode (fast or slow from NSAMPLE).
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
//void ms_read_header(miri_data_info& data_info, miri_control control)
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
//	Written by Jane Morrison 2008
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/


#include <iostream>
#include <string>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_constants.h"
#include "miri_control.h"

// program to parse the raw data file and determine the details of how the data
// was taken.  
// Keywords needed which describe the exposure:
// NGROUPS: # of ramps in an integration
// NINTS:   # of integrations in the exposure
// NFRAMES: # for miri = 1
// NSAMPLE: # (on board sampling factor) 1 = fast, 10 = slow
// MODE:    # fast mode (0) ,slow (1), fast-short (2) [frames =1, int > 1]

void ms_read_header(miri_data_info& data_info, miri_control control)

{

  int II = data_info.this_file_num;
  // **********************************************************************
  // open the raw data file and get various useful bits of info from the header
  int status = 0;   // status of a cfitsio call
  fits_open_file(&data_info.raw_file_ptr, data_info.raw_filename[II].c_str(), READONLY, &status);   // open the file
  if(status !=0) {
    cout << " Failed to open fits raw file: " << data_info.raw_filename[II] << endl;
    cout << " Reason for failure, status = " << status << endl;
    exit(EXIT_FAILURE);
  }

  char comment[72];
  status = 0;
  // get the size of teh data cube
  fits_read_key(data_info.raw_file_ptr, TLONG, "NAXIS1", &data_info.raw_naxes[0], comment, &status); 
  if(status !=0 ) cout << "ms_read_header:  Problem reading NAXIS1 " << endl;
  fits_read_key(data_info.raw_file_ptr, TLONG, "NAXIS2", &data_info.raw_naxes[1], comment, &status); 
  if(status !=0 ) cout << "ms_read_header:  Problem reading NAXIS2 " << endl;
  fits_read_key(data_info.raw_file_ptr, TLONG, "NAXIS3", &data_info.raw_naxes[2], comment, &status); 
  if(status !=0 ) cout << "ms_read_header:  Problem reading NAXIS3 " << endl;
  int naxis3 = data_info.raw_naxes[2];

  // **********************************************************************

  data_info.NSample = 1; // 1 for fast, 10 for slow
  
  data_info.Mode = 0;
  data_info.NFrame = 1;
  data_info.NRamps = data_info.raw_naxes[2]; // initialize to same size as number planes
                                             // redefine if NGROUPS exists
  data_info.NInt = 1;
  data_info.NReset = 2;

  
  status = 0; 
  fits_read_key(data_info.raw_file_ptr, TINT, "NFRAME", &data_info.NFrame, comment, &status); 
  if(status != 0) data_info.NFrame = 1;
  if(data_info.NFrame != 1) data_info.Mode = 3;

  status = 0; 
  int NSample = 0;
  fits_read_key(data_info.raw_file_ptr, TINT, "NSAMPLE", &NSample, comment, &status); 
  if(status ==0){
  }else { //did not find
    status = 0; 
    fits_read_key(data_info.raw_file_ptr, TINT, "NSAMPLES", &NSample, comment, &status); 
    if(status ==0) {
    } else{ // did not find second way
      cout << " Did not find NSAMPLE or NSAMPLES in header, go to set it to FAST mode data =1" << endl;
      
      NSample = 1;
    }
  } 
  //  cout << " NSamples: " << NSample << " (Fast = 1, Slow = 10)" <<  endl;
  data_info.NSample = NSample;


  status = 0; 
  fits_read_key(data_info.raw_file_ptr, TFLOAT, "TFRAME", &data_info.FrameTime, comment, &status); 
  if(status == 0) data_info.Flag_FrameTime = 1;


  status = 0; 
  fits_read_key(data_info.raw_file_ptr, TFLOAT, "TGROUP", &data_info.GroupTime, comment, &status); 


  status = 0; 
  fits_read_key(data_info.raw_file_ptr, TINT, "COLSTART", &data_info.ColStart, comment, &status); 
  if(status != 0) data_info.ColStart = 1;
  status = 0; 
  fits_read_key(data_info.raw_file_ptr, TINT, "ROWSTART", &data_info.RowStart, comment, &status); 
  if(status != 0) data_info.RowStart = 1;


  status = 0; 
  fits_read_key(data_info.raw_file_ptr, TINT, "FRMRSETS", &data_info.frame_resets, comment, &status); 
  if(status != 0) data_info.frame_resets = 0;

  status = 0; 
  fits_read_key(data_info.raw_file_ptr, TINT, "ROWRSETS", &data_info.row_resets, comment, &status); 
  if(status != 0) data_info.row_resets = 0;

  status = 0; 
  fits_read_key(data_info.raw_file_ptr, TINT, "RPCDELAY", &data_info.rpc_delay, comment, &status); 
  if(status != 0) data_info.rpc_delay = 0;
  
  int nGroups = 0;
  status = 0; 
  fits_read_key(data_info.raw_file_ptr, TINT, "NGROUP", &nGroups, comment, &status); 
  if(status ==0) {
  }else{ // did not find
    status = 0; 
    fits_read_key(data_info.raw_file_ptr, TINT, "NGROUPS", &nGroups, comment, &status); 
    if(status ==0) {
    } else{ // did not find second way
      nGroups= int(data_info.raw_naxes[2]);
    }
  }
  data_info.NRamps = nGroups;


  status = 0; 
  int numINT = 0;

  fits_read_key(data_info.raw_file_ptr, TINT, "NINT", &numINT, comment, &status); 
  if(status ==0) {
  }else{   // did not find

    status = 0; 
    fits_read_key(data_info.raw_file_ptr, TINT, "NINTS", &numINT, comment, &status); 
    if(status ==0) {
    }else{ // did not find second way
      numINT= 1;
    }
  }

  data_info.NInt = numINT;

 status = 0; 
  fits_read_key(data_info.raw_file_ptr, TINT, "FRMDIVSR", &data_info.FrameDiv, comment, &status); 
  if(status != 0) data_info.FrameDiv = 1;
 
  char rout[FLEN_VALUE];
  status = 0; 
  fits_read_key(data_info.raw_file_ptr, TSTRING, "READOUT", &rout, comment, &status); 
  data_info.Readout = rout;

  char det[FLEN_VALUE];
  status = 0; 
  fits_read_key(data_info.raw_file_ptr, TSTRING, "DETECTOR", &det, comment, &status); 
  data_info.Detector = det;

  char detm[FLEN_VALUE];
  status = 0; 
  fits_read_key(data_info.raw_file_ptr, TSTRING, "DETMODE", &detm, comment, &status); 
  data_info.detmode = detm;


  char dgaa[FLEN_VALUE];
  status = 0; 
  fits_read_key(data_info.raw_file_ptr, TSTRING, "DGAA_POS", &dgaa, comment, &status); 
  if(status == 0){
    data_info.DGAA = dgaa;
  } else{
    data_info.DGAA  = "NA";
  }


  char dgab[FLEN_VALUE];
  status = 0; 
  fits_read_key(data_info.raw_file_ptr, TSTRING, "DGAB_POS", &dgab, comment, &status); 
  if(status ==0) { 
    data_info.DGAB = dgab;
  } else {
    data_info.DGAB = "NA";
  }

  char band[FLEN_VALUE];
  status = 0; 
  fits_read_key(data_info.raw_file_ptr, TSTRING, "BAND", &band, comment, &status); 
  if(status ==0) { 
    data_info.Band = band;
  } else {
    data_info.Band = "NA";
  }

  char filter[FLEN_VALUE];
  status = 0; 
  fits_read_key(data_info.raw_file_ptr, TSTRING, "FWA_POS", &filter, comment, &status); 
  data_info.filter = filter;
  
  //cout << " Detector " << data_info.Detector  << endl;
  //cout << " DGAA " << data_info.DGAA  << endl;
  //cout << " DGAB " << data_info.DGAB  << endl;
  //cout << " Filter " << data_info.filter  << endl;

  

  char orig[FLEN_VALUE];
  status = 0; 
  fits_read_key(data_info.raw_file_ptr, TSTRING, "ORIGIN", &orig, comment, &status); 
  data_info.Origin = orig;
  
  // cout << " Origin " << data_info.Origin  << endl;
  

  // Mode = 0, Fast, Mode= 1, Slow, Mode = 2 Fast Short mode. 

  if(data_info.NSample !=1) data_info.Mode = 1;
  if(data_info.NSample == 1 && data_info.NRamps == 1 && data_info.NInt > 1) data_info.Mode = 2;


  if(data_info.NRamps <= 1 && data_info.Mode !=2 ) {
    cout << " *****************************************************" << endl;
    cout << " The determination of the slope image is not possible. " << endl;
    cout << " This file only contains one ramp point/integration " << endl;
    cout << " *****************************************************" << endl;
    cout << data_info.raw_filename[data_info.this_file_num] << endl;
    exit(EXIT_FAILURE);
  }


  // **********************************************************************
  // calculate or get the exposure time
  // the exposure for the array starts at the first read
  //  fits_read_key(data_info.raw_file_ptr, TFLOAT, "INTTIME", &data_info.frametime, comment, &status); // cube


  // **********************************************************************

  // Check if mode is FASTGRPAVG

  int test_ratio = data_info.FrameDiv/data_info.NFrame;
  //cout << "test_ratio " << test_ratio << endl;
  // if(data_info.Readout == "FASTGRPAVG" && data_info.FrameDiv !=0){
  if(data_info.Readout == "FASTGRPAVG" && test_ratio  !=1){
    cout << " This data is FASTGRPAVG, adjusted NGROUP to process data correctly" << endl;
    cout << " NGROUPS and FrameDiv values in header " <<data_info.NRamps << " "  << data_info.FrameDiv << endl;
    data_info.NRamps = data_info.NRamps/data_info.FrameDiv;
    cout << " NGroups has been modified internally in the program to: "<< data_info.NRamps << endl;
  }
  if(data_info.FrameDiv !=1) cout << " FRMDIVSR keyword is non-standard " << data_info.FrameDiv << endl;
  if(data_info.NFrame !=1) cout << " NFRAME keyword is non-standard " << data_info.NFrame << endl; 

  // **********************************************************************



  long itest = data_info.NInt * data_info.NRamps ;

  if(naxis3 > itest) {
    cout << " ************** WARNING ******************" << endl;
    cout << " NAXES3 > NINTS * NGROUPS " << endl;
    cout << " NAXES3 " << naxis3 << endl;
    cout << " NINTS " << data_info.NInt << endl;
    cout << " NGROUPS " << data_info.NRamps << endl;

    cout << " Only processing " << itest << " Frames " << endl;
    cout << " *****************************************" << endl;
  }
  //if(naxis3 < itest) {
    //    int newINT = naxis3/data_info.NRamps;

    // cout << " ************** WARNING ******************" << endl;
    //cout << " The raw data file did not have all the data corresponding to NGROUPS and NINT" << endl;
    //    cout << " NAXES3 " << naxis3 << endl;
    //cout << " NINTS " << data_info.NInt << endl;
    //cout << " NGROUPS " << data_info.NRamps << endl;
    //data_info.NInt = (newINT)+1;
    //data_info.NRamps = naxis3;

    //cout << " Setting NINT to " << data_info.NInt << endl;

    //cout << " Changed number of Frames/integration =  " << data_info.NRamps << endl;
    //if(data_info.NInt > 1) {
    //  cout << " There is a missing frame from one of the integrations, but which one ? " << endl;
    // cout << " This program can not run on this data set, report this problem to Jane Morrison " << endl;
    // cout << "  morrison@as.arizona.edu" << endl;
    // exit(EXIT_FAILURE);
    //}
    //cout << " *****************************************" << endl;
    //}  
  // **********************************************************************

  data_info.refimage_exist = 1;
  int rsize = data_info.raw_naxes[0]/4;
  data_info.ramp_naxes[0] = data_info.raw_naxes[0];
  data_info.ramp_naxes[1] = data_info.raw_naxes[1] - data_info.raw_naxes[1]/5;
  data_info.ramp_naxes[2] = data_info.NRamps;
  data_info.ref_naxes[0] = rsize;
  data_info.ref_naxes[1] =  data_info.ramp_naxes[1];
  data_info.ref_naxes[2] = data_info.NRamps;
  data_info.subarray_mode = 0; // full array

  if(data_info.raw_naxes[0] < 1032 ) {
    cout << " This is subarray Data " << endl;
    if(data_info.ColStart ==1)  data_info.subarray_mode = 1; // sub array and can use left reference pixels 
    if(data_info.ColStart !=1)  data_info.subarray_mode = 2;  // sub array and no reference pixels
  }      
      // No reference image - this case will probably not happen
  if(data_info.raw_naxes[1] == 1024){

      data_info.refimage_exist = 0;
      data_info.ramp_naxes[0] = 1032;
      data_info.ramp_naxes[1] = 1024;
      data_info.ramp_naxes[2] = data_info.NRamps;
      data_info.ref_naxes[0] = 1;// make it one so when we create miri_refimage vector it is not 0
      data_info.ref_naxes[1] = 1;
      data_info. ref_naxes[2] = 1;
  }

  // **********************************************************************
  if(control.do_verbose == 10 ) {
    cout << " Number of Integrations  " << data_info.NInt << endl;
    cout << " Number of frames/int    " << data_info.NRamps << endl;
    cout << " Size of input data      " << data_info.raw_naxes[0] << " " <<
      data_info.raw_naxes[1] << " " <<data_info.raw_naxes[2] << " " <<endl;
    cout << " reference image exist   " << data_info.refimage_exist << endl;
    cout << " Size of science image   " << data_info.ramp_naxes[0] << " " <<
      data_info.ramp_naxes[1] << " " <<data_info.ramp_naxes[2] << " " <<endl;
    if(data_info.refimage_exist) 
    cout << " Size of reference image " << data_info.ref_naxes[0] << " " <<
      data_info.ref_naxes[1] << " " 
	 <<data_info.ref_naxes[2] << " " <<endl;
  }

    if (control.do_verbose == 1) cout << "finished ms_read_header" << endl;
}


