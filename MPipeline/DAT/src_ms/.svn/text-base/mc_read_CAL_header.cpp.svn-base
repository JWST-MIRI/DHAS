// Read in the size of Calibration File (reset, dark or lastframe)
       
// Author:
//
//	Jane Morrison
//      University of Arizona
//      email: morrison@as.arizona.edu
//      phone: 520-626-3181
// 
// Calling Sequence:
//

//
// Arguments:
//
//
//
// Return Value/ Variables modified:
//      No return value.

//
// History:
//
//	Written by Jane Morrison 3/23/14

#include <iostream>
#include <vector>
#include <string>
#include <string.h>
#include <cstring>
#include <sstream>
#include "fitsio.h"
#include "miri_sloper.h"

void ms_read_CAL_header(string calfile, long &xsize, long &ysize,  long& zsize, long& isize,int &colstart, int &rowstart)

{
  
  int status = 0; 
  //   cout << " Subarray CAl opening" << calfile << endl;
    fitsfile *fptr;    
    fits_open_file(&fptr, calfile.c_str(), READONLY, &status);   // open the file
    if(status !=0) {
      cout << " Failed to open CAL Subarrray  file: " << calfile << endl;
      cout << " Reason for failure, status = " << status << endl;
      exit(EXIT_FAILURE);
    }

    int hdutype =0;
    status  = 0; 
    char comment[72];
    int ifail = 0;
    
    status = 0; 
    fits_read_key(fptr, TINT, "SUBXSTRT", &colstart, comment, &status); 
    if(status !=0 ) cout << "ms_read_CAL_header:  Problem reading SUBXSRT " << endl;
    status = 0; 
    fits_read_key(fptr, TINT, "SUBYSTRT", &rowstart, comment, &status); 
    if(status !=0 ) cout << "ms_read_CAL_header:  Problem reading SUBYSRT " << endl;

    status = 0;
    fits_movabs_hdu(fptr,2,&hdutype,&status);
    if(status !=0 ) cout << "Could not move the SCI data in CAL file" << endl;
    fits_read_key(fptr, TLONG, "NAXIS1", &xsize, comment, &status); 
    if(status !=0 ){
      cout << "ms_read_CAL_header  Problem reading NAXIS1 " << endl;
      ifail = 1;
    }
    status = 0; 
    fits_read_key(fptr, TLONG, "NAXIS2", &ysize, comment, &status); 
    if(status !=0 ){
      cout << "ms_read_CAL_header:  Problem reading NAXIS2 " << endl;
      ifail = 1;
    }
    status = 0; 
    fits_read_key(fptr, TLONG, "NAXIS3", &zsize, comment, &status); 
    if(status !=0 ){
      cout << "ms_read_CAL_header:  Problem reading NAXIS3 " << endl;
      ifail = 1;
    }

    status = 0; 
    fits_read_key(fptr, TLONG, "NAXIS4", &isize, comment, &status); 
    if(status !=0 ) {
      cout << "ms_read_CAL_header:  Problem reading NAXIS4 " << endl;
      ifail = 1;
    } 
      
    if(ifail ==1) {
      cout << " ms_read_CAL_header: Could not read the dimensions of the CAL Correction file " << endl;
      exit(EXIT_FAILURE);
    }
    cout << "size of CAL File " << xsize << " " << ysize << " " << zsize << " " << isize <<  endl;

}
