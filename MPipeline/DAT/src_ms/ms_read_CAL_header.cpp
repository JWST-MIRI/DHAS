// Read in the size of the CAL file
       
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

void ms_read_CAL_header(string CALfile, long &xsize, long &ysize,  long& zsize, long& isize,int &colstart, int &rowstart)

{
  
  int status = 0; 
  //  cout << " Reading CAL FILE " << CALfile << endl;
  fitsfile *fptr;    
  fits_open_file(&fptr, CALfile.c_str(), READONLY, &status);   // open the file
  if(status !=0) {
    cout << " Failed to open CAL   file: " << CALfile << endl;
    cout << " Reason for failure, status = " << status << endl;
    exit(EXIT_FAILURE);
  }

    int hdutype =0;
    status  = 0; 
    char comment[72];
    int ifail = 0;
    

    status = 0; 
    fits_read_key(fptr, TINT, "SUBSTRT1", &colstart, comment, &status); 
    if(status !=0 ) cout << "ms_read_CAL_header:  Problem reading SUBXSRT " << endl;
    status = 0; 
    fits_read_key(fptr, TINT, "SUBSTRT2", &rowstart, comment, &status); 
    if(status !=0 ) cout << "ms_read_CAL_header:  Problem reading SUBYSRT " << endl;

    char type[FLEN_VALUE];
    status = 0; 
    fits_read_key(fptr, TSTRING, "REFTYPE", &type, comment, &status); 
    if(status !=0 ) {
      cout << "ms_read_CAL_header:  Problem reading REFTYPE, trying TYPE " << endl;    
      status = 0; 
      fits_read_key(fptr, TSTRING, "TYPE", &type, comment, &status); 
      if(status !=0 ) {
	cout << "ms_read_CAL_header:  Problem reading TYPE " << endl;    
	exit(EXIT_FAILURE);
      }
    }
    string Type = type;


    //    cout << " Type of Calibration file: " << type << endl;
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
    //_______________________________________________________________________
    // If Calibration file is Reset Correction - 4 dimensions
    if(Type == "RESET" || Type == "Dark" ) { 
      status = 0; 
      fits_read_key(fptr, TLONG, "NAXIS3", &zsize, comment, &status); 
      if(status !=0 ){
	cout << "ms_read_CAL_header:  Problem reading NAXIS3 " << endl;
	ifail = 1;
      }
    }
    //_______________________________________________________________________    
    // If Calibration file is Reset Correction - 4 dimensions
    if(Type == "RESET") { 
    
      status = 0; 
      fits_read_key(fptr, TLONG, "NAXIS4", &isize, comment, &status); 
      if(status !=0 ) {
	cout << "ms_read_CAL_header:  Problem reading NAXIS4 " << endl;
	ifail = 1;
      } 
    }
    //_______________________________________________________________________
      
    if(ifail ==1) {
      cout << " ms_read_CAL_header: Could not read the dimensions of the CAL Correction file " << endl;
      exit(EXIT_FAILURE);
    }
    //cout << "size of CAL file " << xsize << " " << ysize << " " << zsize << " " << isize <<  endl;

    fits_close_file(fptr, &status);   // close the file
}
