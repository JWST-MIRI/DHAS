// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.
//
// Name:
//    ms_process_refimage_data.cpp
//
// Purpose:
// If Fast or Slow mode data: convert the frames values in a integrations 
// (sample up the ramp)  to slopes.
// If Fast Short mode data: coadded the frames together. 
//
// There are some "processing" steps done in other preceding programs
// Steps done in ms_read_refdata: 
//   Reject data: 
//     bad pixels, 
//     reject initial or final frames in integration
//     reject saturated data. 
//
// This program  either coadds the data or determines the reduced values: slope, uncertainty,
// data quality flag, zero pt, # of good reads, first saturated frame (-1 if none),
// empirical RMS. 
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
//void ms_process_refimage_data( 
//				miri_control control,
//				miri_data_info& data_info,
//				vector<miri_pixel> &refpixel,
//				vector<float> &Slope,
//				vector<float> &SlopeUnc,
//				vector<float> &SlopeID,
//				vector<float> &ZeroPt,
//				vector<float> &NumGood,
//				vector<float> &ReadNumFirstSat,
//				vector<float> &RMS)
//
// Arugments:
//
//  control: miri_control structure containing the processing options
//  data_info: miri_data_info structure containing basic information on the dataset
// 
//  The following values have a size = full array. They are filled as the subsets
//  are processed. 
//  Slope: vector of slope for current integration. 
//  SlopeUnc: vector of slope uncertainities  for current integration. 
//  SlopeID: vector of  data quality flag for current integration. 
//  ZeroPt: vector of zero pt of fit for current integration. 
//  NumGood: vector of number of good frames used in the fit for current integration. 
//  ReadNumFirstSat: vector of  frame number corresponding to th first saturated DN value
//        in the fit.
//  RMS: vector of empirical uncertainties determined for the fit
// 
// Return Value
//      No return value.  
//     
//
// History:
//
//	Written by Jane Morrison 2007
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/
#include <iostream>
#include <vector>
#include <string>
#include "miri_data_info.h"
#include "miri_control.h"
#include "miri_pixel.h"
#include "miri_constants.h"




void ms_process_refimage_data( miri_control control,
				miri_data_info& data_info,
			       vector<int> FramesBad,
			       const int NFramesBad,
				vector<miri_pixel> &refpixel,
				vector<float> &Slope,
				vector<float> &SlopeUnc,
				vector<float> &SlopeID,
				vector<float> &ZeroPt,
				vector<float> &NumGood,
				vector<float> &ReadNumFirstSat,
				vector<float> &RMS)
{

  // **********************************************************************
// 1st iteration over array to identify auto rejects and saturation
//  for (piter = pixel.begin(); piter != pixel.end();++piter) {   

  int debug_flag = 0;

  for (long j = 0; j < data_info.ref_numpixels; j++) {
    debug_flag = 0;
    refpixel[j].FindSegments();
    refpixel[j].CalculateSlopeNoErrors(0,0);       // Find Slopes for each segment dn/read

    refpixel[j].FinalSlope(control.slope_seg_cr_sigma_reject,
			   control.n_frames_reject_after_cr,
			   control.cr_min_good_diffs,
			   control.write_detailed_cr,
			   control.UncertaintyMethod,
			   data_info.output_cr,
			   0,0);


    refpixel[j].CalculatePixelFlag(); // update this as needed

      //_______________________________________________________________________

    int badpixel = refpixel[j].GetBadPixelFlag();

    if(badpixel == 0) {
      refpixel[j].Convert2DNperSec(data_info.frame_time_to_use); // dn/read * read/seconds
      if(control.convert_to_electrons_per_second ==1) 
	refpixel[j].Convert2ElectronperSec(control.gain); 
    }
      
    float signal = refpixel[j].GetSignal();
    float signal_unc = refpixel[j].GetSignalUnc();
    float id = float(refpixel[j].GetQualityFlag());
    float rms_data = refpixel[j].GetRMS();

    float zeropt = refpixel[j].GetZeroPt();
    float numgood = refpixel[j].GetNumGood();
    float numgoodseg = refpixel[j].GetNumGoodSegments();
    if(numgoodseg > 1) {
      cout << " this should not happen with reference pixels " << endl;
    }
    float readnumfirstsat = refpixel[j].GetReadNumFirstSat();

    if(signal == NO_SLOPE_FOUND ) {
      signal = strtod("NaN",NULL);
      signal_unc = strtod("NaN",NULL);
      zeropt = strtod("NaN",NULL);
      readnumfirstsat = strtod("NaN",NULL);
      numgood = 0.0;
      numgoodseg = 0.0;
      rms_data = strtod("NaN",NULL);

    }

    Slope.push_back(signal);
    SlopeUnc.push_back(signal_unc);
    SlopeID.push_back(id);
    ZeroPt.push_back(zeropt);
    NumGood.push_back(numgood);

    ReadNumFirstSat.push_back(readnumfirstsat);
    RMS.push_back(rms_data);

  }
}

