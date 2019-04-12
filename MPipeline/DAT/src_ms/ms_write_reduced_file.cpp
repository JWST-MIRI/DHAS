// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.
//
// Name:
//  ms_write_reduced_file.cpp
//
// Purpose:
//   Write the results of processing the science data for each integration. 	
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
//void ms_write_reduced_file(miri_data_info& data_info,
//			   miri_control control,
//			   string preference_filename,
//			   vector<float> &Slope,
//			   vector<float> &SlopeUnc,
//			   vector<float> &SlopeID,
//			   vector<float> &ZeroPt,
//			   vector<float> &NumGood,
//			   vector<float> &ReadNumFirstSat,
//			   vector<float> &NumGoodSeg,
//			   vector<float> &RMS,
//			   vector<float> &Max2ptDiff,
//			   vector<float> &IMax2ptDiff,
//			   vector<float> &StdDev2pt,
//			   vector<float> &Slope2ptDiff)
//
//
// Arugments:
//
//  data_info: miri_data_info structure containing basic information on the dataset
//  control: miri_control structure containing the processing options
//  preference_filename: name of preference file that was used
//  Slope: vector of slopes for current integration. 
//  SlopeUnc: vector of slope uncertainities  for current integration. 
//  SlopeID: vector of  data quality flag for current integration. 
//  ZeroPt: vector of zero pt of fit for current integration. 
//  NumGood: vector of number of good frames used in the fit for current integration. 
//  ReadNumFirstSat: vector of  frame number corresponding to th first saturated DN value
//        in the fit.
//  NumGoodSeg: vector of number of good segments used to find the slope for current integration. 
//  The following variables are only determined if the -d (diagnostic flag is set)
//  RMS: vector of empirical uncertainties determined for the fit
//  Max2ptDiff: vector of maximum 2 pt differences in DN values for adjacent frames
//  iMax2ptDiff: vector of frame numbers corresponding to the maximum 2 pt differences 
//    in DN values for adjacent frames
// StdDev2pt: standard deviation of the 2-pt differences 
// Slope2ptDiff: slope of the 2-pt differences
//
//
// Return Value/ Variables modified:
//      No return value.  
// 
//
// History:
//
//	Written by Jane Morrison January 2005
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/

#include "miri_sloper.h"
// open and setup the reduced FITS file: control.raw_bitsbase + ".red.fits";

void ms_write_reduced_file(const int intnum,
			   miri_data_info& data_info,
			   miri_control control,
			   miri_CDP CDP,
			   string preference_filename,
			   const int NFramesBad,
			   vector<int> FrameBad,
			   vector<float> &Slope,
			   vector<float> &SlopeUnc,
			   vector<float> &SlopeID,
			   vector<float> &ZeroPt,
			   vector<float> &NumGood,
			   vector<float> &ReadNumFirstSat,
			   vector<float> &NumGoodSeg,
			   vector<float> &RMS,
			   vector<float> &Max2ptDiff,
			   vector<float> &IMax2ptDiff,
			   vector<float> &StdDev2pt,
			   vector<float> &Slope2ptDiff)

{
  int status = 0;    // status of a cfitsio call

  // **********************************************************************
  // **********************************************************************
  data_info.red_naxis = 3;
  data_info.red_naxes[0] = data_info.ramp_naxes[0];
  data_info.red_naxes[1] = data_info.ramp_naxes[1];
  data_info.red_naxes[2] =8; // slope, uncertainty, id flag, zero pt, # good read,
                              // read num first sat, num good segments, std of fit
  if(control.do_diagnostic)  data_info.red_naxes[2] = 12;
  if(control.QuickMethod == 1)  data_info.red_naxes[2] = 3; // slope, zero pt, std fit

  data_info.red_bitpix = -32;

  // **********************************************************************
    // _______________________________________________________________________
  // create an image for the reduced file- cube of data

  status = 0;
  fits_create_img(data_info.red_file_ptr, data_info.red_bitpix, 
		  data_info.red_naxis,data_info.red_naxes, &status);
  if(status !=0) cout << " ms_write_reduced_file_refpixel: Problem creating image"
		      << endl;

  char extname[21] = "REDUCED DATA FOR INT";
  fits_write_key(data_info.red_file_ptr,TSTRING,"EXTNAME",&extname," Extension Name ",&status);
  // _______________________________________________________________________

  // write a few values to header summarizing the ramp to slope processing (for this integration)

  int primary = 0;
  ms_write_processing_to_header(data_info.red_file_ptr,
				intnum,
				0,             // 0 = science data
				control,
				NFramesBad,FrameBad,
				preference_filename,data_info,
			        CDP,primary);


  // _______________________________________________________________________
  // Loop through each subset of data and write out the subset to the fits file
  int xsize = data_info.ramp_naxes[0];
  int ysize = data_info.ramp_naxes[1];

  long tsize = xsize*ysize;
  long tsize2 = tsize*2;
  long tsize3 = tsize*3;
  long tsize4 = tsize*4;
  long tsize5 = tsize*5;
  long tsize6 = tsize*6;
  long tsize7 = tsize*7;
  long tsize8 = tsize*8;
  long tsize9 = tsize*9;
  long tsize10 = tsize*10;
  long tsize11 = tsize*11;
  long nelements = tsize*8;
  if(control.QuickMethod) nelements= tsize*3;

  if(control.do_diagnostic ==1)  nelements = tsize*12;
  vector<float> data(nelements);
  // _______________________________________________________________________
  // Write only Slope and Zero Pt

  if(control.QuickMethod == 1) {
    
    copy(Slope.begin(),Slope.end(),data.begin());
    copy(ZeroPt.begin(),ZeroPt.end(),data.begin() + tsize);
    copy(RMS.begin(),RMS.end(),data.begin() + tsize2);
  // _______________________________________________________________________
    // Write it Full Set of Processed Data
  }else {
    copy(Slope.begin(),Slope.end(),data.begin());
    copy(SlopeUnc.begin(),SlopeUnc.end(),data.begin() + tsize);

    copy(SlopeID.begin(),SlopeID.end(),data.begin() + tsize2);
    copy(ZeroPt.begin(),ZeroPt.end(),data.begin() + tsize3);
    copy(NumGood.begin(),NumGood.end(),data.begin() + tsize4);
    copy(ReadNumFirstSat.begin(),ReadNumFirstSat.end(),data.begin() + tsize5);
    copy(NumGoodSeg.begin(),NumGoodSeg.end(),data.begin() + tsize6);
    copy(RMS.begin(),RMS.end(),data.begin() + tsize7);

    if(control.do_diagnostic) {
      copy(Max2ptDiff.begin(),Max2ptDiff.end(),data.begin() + tsize8);
      copy(IMax2ptDiff.begin(),IMax2ptDiff.end(),data.begin() + tsize9);
      copy(StdDev2pt.begin(),StdDev2pt.end(),data.begin() + tsize10);
      copy(Slope2ptDiff.begin(),Slope2ptDiff.end(),data.begin() + tsize11);
    }
  }

  fits_write_img(data_info.red_file_ptr,TFLOAT,1,nelements,&data[0],&status);
  
  if(status != 0) {
    cout << " Problem writing Slope data " << endl;
    cout << " status " << status << endl;
    exit(EXIT_FAILURE);
  }

  //  cout << " Done writing reduced file " << endl;
}
