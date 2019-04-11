// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.
//
// Name:
//  ms_write_reduced_refimage.cpp
//
// Purpose:
//   Write the results of processing the reference output image (channel 5)  for each integration. 	
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
//void ms_write_reduced_refimage(
//			       miri_data_info& data_info,
//			       miri_control control,
//			       string preference_filename,
//			       vector<float> &Slope,
//			       vector<float> &SlopeUnc,
//			       vector<float> &SlopeID,
//			       vector<float> &ZeroPt,
//			       vector<float> &NumGood,
//			       vector<float> &ReadNumFirstSat,
//			       vector<float> &RMS)
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
//  RMS: vector of empirical uncertainties determined for the fit
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

void ms_write_reduced_refimage(const int intnum,
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
			       vector<float> &RMS)

{
  int status = 0;    // status of a cfitsio call
  data_info.red_ref_naxis = 3;
  data_info.red_ref_naxes[0] = data_info.ref_naxes[0];
  data_info.red_ref_naxes[1] = data_info.ref_naxes[1];
  data_info.red_ref_naxes[2] = 7; // slope, uncertainty, id flag, zero pt, # good read,
                              // read num first sat, emp uncertainty
  data_info.red_ref_bitpix = -32;

  // **********************************************************************
  // if on first integration and the first subset then 
  // a.  write the header (primary header with no image)
  // b.  define the size of the image created
  // _______________________________________________________________________
  // create an image for the reduced file- cube of data

  status = 0;
  fits_create_img(data_info.red_ref_file_ptr, data_info.red_ref_bitpix, data_info.red_ref_naxis, 
		    data_info.red_ref_naxes, &status);  

  if(status !=0) cout << "ms_setup_reduced_refimage: failure to create image " << status << endl;
  // _______________________________________________________________________

  // write a few values to header summarizing the ramp to slope processing (for this integration) 

  int primary = 0;
  ms_write_processing_to_header(data_info.red_ref_file_ptr,
				intnum,
				1,       // type = reference image
				control,
				NFramesBad,FrameBad,
				preference_filename,data_info,CDP,primary);
    
    
  char extname[21] = "REDUCED DATA FOR INT";
  fits_write_key(data_info.red_ref_file_ptr,TSTRING,"EXTNAME",&extname,
		 " Extension Name ",&status);
  // **********************************************************************
  // write reduced reference image to FITS file

  // **********************************************************************
// Loop through each subset of data and write out the subset to the fits file
  int xsize = data_info.ref_naxes[0];
  int ysize = data_info.ref_naxes[1];
                                          

  long tsize = xsize*ysize;
  long tsize2 = tsize*2;
  long tsize3 = tsize*3;
  long tsize4 = tsize*4;
  long tsize5 = tsize*5;
  long tsize6 = tsize*6;
  long nelements = tsize*7;

  vector<float> data(nelements);
  
  copy(Slope.begin(),Slope.end(),data.begin());
  copy(SlopeUnc.begin(),SlopeUnc.end(),data.begin() + tsize);
  copy(SlopeID.begin(),SlopeID.end(),data.begin() + tsize2); 
  copy(ZeroPt.begin(),ZeroPt.end(),data.begin() + tsize3);
  copy(NumGood.begin(),NumGood.end(),data.begin() + tsize4);
  copy(ReadNumFirstSat.begin(),ReadNumFirstSat.end(),data.begin() + tsize5);
  copy(RMS.begin(),RMS.end(),data.begin() + tsize6);

  fits_write_img(data_info.red_ref_file_ptr,TFLOAT,1,nelements,&data[0],&status);
  if(status != 0) {
    cout << " Problem writing reference subset pixels " << endl;
    cout << " status " << status << endl;
    exit(EXIT_FAILURE);
  }
  


}
