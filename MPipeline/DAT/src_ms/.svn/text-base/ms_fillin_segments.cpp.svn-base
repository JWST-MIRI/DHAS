// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//     ms_fillin_segments.cpp
//
// Purpose:
//
// The routine is called by miri_sloper.cpp if the user has chosen to write the
// segment information to and output file.  The segment information is transfered
// from the pixel class to the segment class. 
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
//void ms_fillin_segments( const int isubset,
//			 const int this_nrow,
//			 const int nframe_start_fit,
//			 miri_data_info &data_info,
//			 vector<miri_pixel> &pixel,
//			 vector<miri_segment> &segment)
//
//
// Arguments:
// 
// isubset:   the subset number controlling which group of rows to read in and process.
// this_nrow: the number of rows to read in and process at one time
// nframe_start_fit: the frame number where the fit starts on
// data_info: the miri_data_info structure that holds basic information on the file
//            being processed.
// pixel: a class that holds the pixel information 
// segment: a class that hold information on the segments
//
// Return Value/ Variables modified:
//      No return value. 
// The segment class is filled in with the information from the pixel class. 
//
// History:
//
//	Written by Jane Morrison June  2008
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/



#include <iostream>
#include <vector>
#include <string>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_pixel.h"
#include "miri_segment.h"


void ms_fillin_segments( const int isubset,
			 const int this_nrow,
			 const int nframe_start_fit,
			 miri_data_info &data_info,
			 vector<miri_pixel> &pixel,
			 vector<miri_segment> &segment)



{
  
  // **********************************************************************
  //       

  int xsize = data_info.ramp_naxes[0];  
  long istart = (isubset * data_info.subset_nrow)*xsize ;
 
  for (long j = 0; j < data_info.numpixels; j++) {
    long ipixel = istart + j;

    int nseg = pixel[j].GetNumSegments();
    int begini = 0;
    int endi = 0;
    int flag = 0;
    float slope = 0.0;
    float unc = 0.0;

    segment[ipixel].SetSegNum(nseg);

    for (int i = 0 ; i< nseg; i++){
      begini =pixel[j].GetBeginSeg(i);
      endi = pixel[j].GetEndSeg(i);
      begini = begini + nframe_start_fit +1;
      endi =   endi + nframe_start_fit + 1;
      flag = pixel[j].GetFlagSeg(i);
      slope = pixel[j].GetSlopeSeg(i);

      unc = pixel[j].GetSlopeSegUnc(i);

      slope=slope/data_info.frame_time_to_use;
      unc=unc/data_info.frame_time_to_use;
      

      segment[ipixel].SetSegBegin(begini);
      segment[ipixel].SetSegEnd(endi);
      segment[ipixel].SetSegFlag(flag);
      segment[ipixel].SetSegSlope(slope);
      segment[ipixel].SetSegUnc(unc);
    }
  }
      

}
