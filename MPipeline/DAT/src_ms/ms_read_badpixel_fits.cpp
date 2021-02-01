// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//   ms_read_badpixel_fits.cpp
//
// Purpose:
//  If the option to flag bad pixels has been set (+b), then read in the correct
//  bad pixel mask for the data type (IM/SW/LW) and fill in the 
//	data_info.badpix[i] vector with 1 for bad pixels and 0 for good pixels  	
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
//int ms_read_badpixel_fits(string badpixel_filename, miri_data_info &data_info,
//			  miri_CDP &CDP,const int verbose)
//
//
// Arugments:
//
//  badpixel_filename: file that contains the bad pixel mask
//  data_info: miri_data_info structure containing basic information on the dataset
//  CDP - holds the name of the bad pixel mask and the mask 
//
//
// Return Value/ Variables modified:
//     status = 0, no problems encountered.
//     status not equal 0 then an error was encountered.  
// 
//
// History:
//
//	Written by Jane Morrison 2007
//     1/09/14 Added CDP class and read only region defined by first and last pixel
//             For subarray data this only reads in the subarry portion. 

#include <iostream>
#include <sstream> 
#include <vector>
#include <string>
#include <cstdlib>
#include <algorithm>
#include "fitsio.h"
#include "miri_CDP.h"
#include "miri_data_info.h"
#include "miri_sloper.h"

int ms_read_badpixel_fits(string badpixel_filename, miri_data_info &data_info,
			  miri_CDP &CDP,
			  const int verbose)
{

  cout << " Read Bad Pixel file: " <<badpixel_filename << endl; 
  long num_bad = 0; 
  
  fitsfile *fptr;
  int status = 0;
  status = Check_CDPfile(badpixel_filename); 
  if(status !=0 ) {
    cout << " Program exiting, check file " << badpixel_filename << endl;
    exit(EXIT_FAILURE);
  }


  int hdutype = 0 ; 
  fits_open_file(&fptr,badpixel_filename.c_str(),READONLY,&status);
  if(status != 0 ) {
    cout << " Problem opening Bad Pixel  file " << badpixel_filename << " " << status << endl;
    cout << " Run again and either correct bad pixel filename or run with -b option (no bad pixel correction)" << endl;

    exit(EXIT_FAILURE);
    status = 1;
    
  } else {

    long inc[2]={1,1};
    int anynul = 0;  // null values

    long fpixel[2] ;
    long lpixel[2];

  // lower left corner of subset
  
    fpixel[0]= data_info.ColStart;
    fpixel[1]= data_info.RowStart;

    lpixel[0] = fpixel[0] + data_info.ramp_naxes[0] -1;
    lpixel[1] = fpixel[1] + data_info.ramp_naxes[1] -1;

    //cout << data_info.ramp_naxes[0] << " " <<data_info.ramp_naxes[1] << endl;
    //cout << " reading bad pixel mask " << endl;
    //cout << " first pixel " << fpixel[0] << " " << fpixel[1]  << endl;
    //cout << " last  pixel " << lpixel[0] << " " << lpixel[1] << endl;


    long ixy =data_info.ramp_naxes[0] * data_info.ramp_naxes[1];
    vector<unsigned int>  data(ixy);
    status = 0;
    fits_movabs_hdu(fptr,2,&hdutype,&status); // for to first extension  
    fits_read_subset(fptr, TUINT, 
		     fpixel,lpixel,
		     inc,0, 
		     &data[0], &anynul, &status);
    if(status != 0 ) {
      cout << " Problem reading Bad Pixel  file " << badpixel_filename << " " << status << endl;
      cout << "fpixel" << fpixel[0] << " " << fpixel[1] << endl;
      cout << "lpixel" << lpixel[0] << " " << lpixel[1] << endl;
      cout << " Check Filename and run again " << endl;
      exit(EXIT_FAILURE); 
      status = 1;
    }

    fits_close_file(fptr,&status);
    for (long k = 0; k< ixy; k++){
      int ibad = (int) data[k];
	//      CDP.SetBadPixel(data[k]);
      CDP.SetBadPixel(ibad);
    }





    long ik = 0;
    for (int i = 0; i< data_info.ramp_naxes[1]; i++){
      for (int j = 0; j< data_info.ramp_naxes[0]; j++,ik++){
	if(data[ik] & CDP_DONOT_USE){
	  num_bad++;
	}
      }
    }
    cout << " Number of Bad Pixels " << num_bad << endl;

  }
  CDP.SetNumBadPixels(num_bad);

  //_______________________________________________________________________

  return status;
}







