// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//  ms_write_segments.cpp
//
// Purpose:
// 	If the -OS option is set then information on each pixel's segments are 
//      written out to a FITS file.  
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
//void ms_write_segments( const int iter,
//			miri_data_info &data_info,
//			vector<miri_segment> &segment)
//
// Arugments:
//  
//  iter: current iteration number
//  data_info: miri_data_info structure containing basic information on the dataset
//  segment: miri_segment class containing information on the segments. 
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
#include <cstdlib>
#include <climits>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <cstring>
#include <algorithm>
#include <vector>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_segment.h"
#include "miri_sloper.h"


void ms_write_segments( const int iter,
			miri_data_info &data_info,
			vector<miri_segment> &segment)


{
  
  // **********************************************************************
  //       


  string filenum("NSGI");
  ostringstream SName;
  char p[FLEN_KEYWORD];

  int ime = iter + 1;
  SName << filenum << ime  ;
  filenum = SName.str();
  //cout << filenum << endl;
  //const char *p = filenum.c_str();
  strcpy(p,filenum.c_str());
  //_______________________________________________________________________
  long Number_In_Segments[4000]; //initialize max number of iterations

  for (int im =0; im < 4000; im++){
    Number_In_Segments[im] = 0;
  }

  //_______________________________________________________________________
  int status = 0;
  int hdutype = 0;
  int bitpix =-32;
  int naxis = 3;
  long naxes[3];
  naxes[0] = data_info.ramp_naxes[0];
  naxes[1] = data_info.ramp_naxes[1];
  naxes[2] = 5;
  
  long npixels = naxes[0]*naxes[1];
  long nelements = npixels*naxes[2];

  for (int i = 1; i< data_info.Max_Num_Segments+1; i++){
    vector<float> data(nelements);

    for (long j = 0; j < npixels; j++) {
      int nseg = segment[j].GetSegNum();

      if(i == 1) Number_In_Segments[nseg]++;

      float begini = 0;
      float endi = 0;
      float slopeseg = 0.0;
      float uncseg = 0.0;
      float flag = 0;
      if(nseg < i ) { // nseg = 0 can occur for pixels where all point rejected because above saturation limit
	
	slopeseg =  strtod("NaN",NULL);
	uncseg =  strtod("NaN",NULL);
	begini =  strtod("NaN",NULL);
	endi =  strtod("NaN",NULL);
	flag =  strtod("NaN",NULL);
	
      } else {
	slopeseg = segment[j].GetSegSlope(i-1);
	if(slopeseg == NO_SLOPE_FOUND) {
	  slopeseg =  strtod("NaN",NULL);
	  uncseg =  strtod("NaN",NULL);
	} else {
	  uncseg = segment[j].GetSegUnc(i-1);
	}
	begini = float(segment[j].GetSegBegin(i-1));
	endi = float(segment[j].GetSegEnd(i-1));
	flag = float(segment[j].GetSegFlag(i-1));
      } 

      data[j] = begini;
      data[j+npixels] = endi;
      data[j+(npixels*2)] = flag;
      data[j+(npixels*3)] = slopeseg;
      data[j+(npixels*4)] = uncseg;	
    } // end loop over j 


    status = 0;
    fits_create_img(data_info.sg_file_ptr, bitpix,naxis,naxes, &status);  // write the primary header- blank image
    if(status !=0) cout << " Problem creating image for segment file " << endl;

  
    status = 0;
    fits_write_img(data_info.sg_file_ptr,TFLOAT,1,nelements,&data[0],&status);

    if(status != 0) {
      cout <<" Problem writing  segment data "<< endl;
      cout << " status " << status << endl;
      exit(EXIT_FAILURE);
    }

//_______________________________________________________________________

    if(i == 1) { // print out number of segments = 0
      cout << "Number pixels with segment # =  0 " << Number_In_Segments[0] <<endl;
    

    
      status = 0;
      fits_write_key(data_info.sg_file_ptr,TLONG,"NSG0", &Number_In_Segments[0],
		     " Number of Pixels with Segments # (NSG#) ",&status);


      if(status !=0) {
	cout << "ms_write_segments: Failed to write Segment Number " << endl;
	cout << "Status = " << status << endl;
      }
    }
    // _______________________________________________________________________
    status = 0;

    
    fits_write_comment(data_info.sg_file_ptr, "**--------------------------------------------------------------**",&status);
    fits_write_comment(data_info.sg_file_ptr, "file created by miri_sloper program",&status);
    fits_write_comment(data_info.sg_file_ptr, "MIRI Team Pipeline",&status);
    fits_write_comment(data_info.sg_file_ptr, "Jane Morrison",&status);
    fits_write_comment(data_info.sg_file_ptr, "email morrison@as.arizona.edu for info",&status);
    fits_write_comment(data_info.sg_file_ptr, "**--------------------------------------------------------------**",&status);
    fits_write_comment(data_info.sg_file_ptr, "This file contains information on the Segments",&status);
    fits_write_comment(data_info.sg_file_ptr, "NULL means there was no segment information ",&status);    
    fits_write_comment(data_info.sg_file_ptr, "plane 1: Frame # of the beginning of the segment",&status);
    fits_write_comment(data_info.sg_file_ptr, "plane 2: Frame # of the end of the segment",&status);
    fits_write_comment(data_info.sg_file_ptr, "plane 3: Flag for the segment segment",&status);
    fits_write_comment(data_info.sg_file_ptr, "plane 4: Slope of the segment",&status);
    fits_write_comment(data_info.sg_file_ptr, "plane 5: Slope Uncertainty of  the segment",&status);
    fits_write_comment(data_info.sg_file_ptr, "   Flag = 1 (# frames in segment < 2",&status);
    fits_write_comment(data_info.sg_file_ptr, "   Flag = 2 (Segment failed Slope Sigma test with other segment",&status);


    fits_write_key(data_info.sg_file_ptr,TINT,p, &data_info.Max_Num_Segments,
                   " Max Number of Segments for Iteration # (NSGI#)",&status);

    string segnum("NSG");
    ostringstream SGName;
    int im = i;
    SGName << segnum << im  ;
    segnum = SGName.str();
    //const char *p2 = segnum.c_str();
    char p2[FLEN_KEYWORD];
    strcpy(p2,segnum.c_str());

    cout << "Number pixels with segment # =  " << i << " " << Number_In_Segments[i] << endl;
    status = 0;
    fits_write_key(data_info.sg_file_ptr,TLONG,p2, &Number_In_Segments[i],
		   " Number of Pixels with Segments # (NSG#) ",&status);


    if(status !=0) {
      cout << "ms_write_segments: Failed to write Segment Number " << endl;
      cout << "Status = " << status << endl;
    }
    // _______________________________________________________________________



  } // end loop over Segments in Iteration
    //_______________________________________________________________________



    status = 0;
    fits_movabs_hdu(data_info.sg_file_ptr,1,&hdutype,&status);  // Primary Header

    status = 0;

    fits_write_key(data_info.sg_file_ptr,TINT,p, &data_info.Max_Num_Segments,
		   " Max Number of Segments for Iteration # (NSGI#)",&status);


    if(status !=0) {
      cout << "ms_write_segments: Failed to write Segment info to header " << endl;
      cout << "Status = " << status << endl;
    }



}
