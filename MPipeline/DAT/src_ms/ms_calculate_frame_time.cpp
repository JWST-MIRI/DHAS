// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
// ms_calculate_frame_time.cpp
//
// Purpose:
// 
// This routine is called my miri_sloper.cpp to calculate the frame time. The frame
// found in the FITS headers of the raw science data is incorrect (as of Jan 1 2009).
// Therefore for FAST mode data the frame time is found in the preference file.
// The frame_time_to_use for processing the data  = 
//                                    frame_time_to_use * float(data_info.NSample);
// data_info.NSample = 1 for fast mode and 10 for Slow mode data. 
// The user can also set the frame time. If they do then the frame_time_to_use =
// user provided value. 
// For subarray data the frame time has to be calculated if it is not provided by
// the user. This program will return the frame_time_to_use for subarray data/ 
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
//void ms_calculate_frame_time(miri_control control, miri_data_info &data_info)
//
// Arguments:
// control: miri_control structure containing a flag if the user set the frame time and
//          the frame time to use if it was set.  
// data_info: miri_data_info structure containing information on the science data
//
// Return Value/ Variables modified:
//      No return value.
// data_info.frame_time_to_use
//
// History:
//
//	Written by Jane Morrison January 1, 2009
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/


#include <iostream>
#include "miri_control.h"
#include "miri_data_info.h"
#include <cstdlib> // EXIT_FAILURE   , EXIT_SUCCESS


void ms_calculate_frame_time(miri_control control, miri_data_info &data_info)

{
  int type = 0;
  float frame_time_to_use = 0;

  if(control.ModelType == 1 && data_info.Flag_FrameTime ==1) {
    frame_time_to_use = data_info.FrameTime;
    } else {
      // not in header use the one provide by user or from the preferences file
      // if from the preferences file (control.flag_frametime == 0 and the time
      // have to multiplied by NSample (NSample =1 Fast, NSample = 10 Slow)

      frame_time_to_use = control.frametime;
      type = 1; 
      if(control.flag_frametime == 0){ // not set by user
	type = 2; 
	if(data_info.subarray_mode == 0) { // full array - check NSample
	  frame_time_to_use = frame_time_to_use * float(data_info.NSample);
	} else {  // subarray mode use the frame time in the header.
	  cout << " Your Science Fits Header does not include the Frame Time and you are running over subarray data" << endl;
	  cout << " You must supply the frame time, with -t # (# seconds/frame) " <<endl;
	  exit(EXIT_FAILURE);
	}
      }
  }
  data_info.frame_time_to_use = frame_time_to_use;
  if(type ==0)  cout << " Frame time read in from Header " << data_info.frame_time_to_use << endl;
  if(type ==1)  cout << " Frame time provided by user " << data_info.frame_time_to_use << endl;
  if(type ==2)  cout << " Frame time read in from Preference File " << data_info.frame_time_to_use << endl;


    if (control.do_verbose == 1) cout << "finished ms_calculate_frame_time" << endl;	

}

