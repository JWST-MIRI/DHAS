// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//      ms_miri_segment.cpp
//
// Purpose:
// 	This programs defines the miri_segment class functions. 
//      The miri_segment class holds all the information for a pixel segments.
//      Pixel segments are the set of frames to find the linear fit to (slope).
//      If initial or final frames are not to be used in the fit the beginning
//      of the segment starts at the first frame to start the fit on and the
//      ending frame is the last frame to be used in the fit. If comic ray
//      detection has been done then there might be cosmic rays that are flagged
//      in the sample -up - the ramps values. The segments are then broken
//      down so that the flagged cosmic ray hits are not included in the segment.
//      So if there are 200 frames and the fit is to start on frame 4 and end on
//      frame 199 and if a cosmic ray was detected at frame 80. The a certain
//      number of frames are rejected after a cosmic ray hit 
//      (defined by control.n_frames_reject_after_cr), let say that is = 4.
//       The segment 1 would begin on frame 4 and end on frame 79. Segment
//       2 would begin on 85 (80+4 are ignored) and end on 199 .The slope is determined
//       for segment 1 and segment 2. After some checks that the slopes are consistent
//       the final slope is an average of the segment slopes. 
//      see include/miri_segment.h for a complete definition.
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
//  no calling sequence: describes class functions. 
//
// Arguments:
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

// ms_miri_segments.cpp - defines the miri_pixel class functions. 


#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>
#include <vector>
#include <algorithm>
#include "miri_segment.h"
#include "miri_constants.h"


// Default constructor to set initial values

miri_segment::miri_segment() 
{
}

//Default destructor
miri_segment::~miri_segment() {}


//_______________________________________________________________________
//void miri_pixel::PrintData(){
//  cout << " Data for pixel (1032 X 1024) " << pix_x_org << " " << pix_y << endl;
//  cout << " quality flag    " << quality_flag << endl;
//  cout << " number of ramps " << raw_data.size() << endl;
//  cout << " number of good segments " << num_good_segments << endl;
//  for (unsigned int i = 0 ; i < raw_data.size() ; i++){
//    cout << " ramp,raw data,id " << i << " " << raw_data[i] <<
//      " " << id_data[i] <<endl;
//  }
//  for (int i = 0; i< num_good_segments; i++){

//    cout << " Start, End of Segment " << seg_begin[i] << " " << seg_end[i] << endl;
//  }
//}

//_______________________________________________________________________
