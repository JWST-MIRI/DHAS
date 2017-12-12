#include <iostream>
#include <vector>
#include <string>
#include <cmath>
#include "mc_data_info.h"
#include "mc_control.h"


void mc_apply_calibration_data(mc_control control,
			       mc_data_info& data_info,
			       vector<float> &Slope,
			       vector<float> &SlopeUnc,
			       vector<float> &SlopeID)
{

  // **********************************************************************
  // If control.apply_background flag set - then apply the background data to the science data (subtract it)
  // If control.apply_flat flag set - then apply the flat data to the science data (divide by  it)


  for (long j = 0; j < data_info.numpixels; j++) {

    int badpixel = 0;
    if (isnan(Slope[j]) ) badpixel = 1;
    if(badpixel == 0) {
      
      if(control.apply_background ==1) Slope[j] = Slope[j] - data_info.background[j];
      if(control.apply_flat ==1) Slope[j] = Slope[j]/ data_info.flat[j];
      if(control.apply_fringe_flat ==1) Slope[j] = Slope[j]/ data_info.fringe_flat[j];
    }
    // update uncertainty - when we have an error for the background and flat
    // use proprogation of errors. 
    
    // update SlopeID = if not background applied or no flat applied (for example)


  }


  //  cout << "done apply calibration data to reduced data " << endl;

}
