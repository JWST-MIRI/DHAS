// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//   check_CDPfile.cpp
//
// Purpose:
// This routine is used with MIRI DHAS 7.0 and higher. It that the new format of
// the calibration file is being use. This program is used to make sure we are not
// using an old calibrations file. 
// Verision 1 of this program just check that the primary image is Blank.

//
// Author:
//
//	Jane Morrison
//      University of Arizona
//      email: morrison@as.arizona.edu
//      phone: 520-626-3181
// 
// Calling Sequence:

// int = Check_CDPFile(string); 
//
//
// Arugments:
//  string - filename to check format of 
//
//
// Return Value/ Variables modified:
//     status = 0, no problems encountered.
//     status not equal 0 in correct format of CDP file  
// 
//
// History:
//
//	Written by Jane Morrison May 2013
//      V 1.0 Check that primary image is blank 

#include <iostream>
#include <sstream> 
#include <string>
#include <cstdlib>
#include "fitsio.h"


using namespace std;
int Check_CDPfile(string filename)
{


  fitsfile *fptr;
  int status = 0;
  int local_status = 0; 
  int hdutype = 0 ; 
  fits_open_file(&fptr,filename.c_str(),READONLY,&local_status);
  if(local_status != 0 ) {
    cout << " check_CPDFile: Problem opening  file " << filename << " " << local_status << endl;
    exit(EXIT_FAILURE);
    status = 1;
  } else {

    fits_movabs_hdu(fptr,1,&hdutype,&status); // Primary  
    char comment[72];
    status = 0;
    long naxis = 0; 
    fits_read_key(fptr, TLONG, "NAXIS", &naxis, comment, &local_status); // get the size
    if(local_status !=0 ) cout << "check_CDPFile:  Problem reading naxis from file  " << filename << " " << local_status << endl;
    if(naxis !=0) {
      status = 1;
      cout << " CDP has the wrong format, check the file " << filename << endl;
      cout << " The file could be of the old format (pre MIRI DHAS 7.0) " << endl;
      cout << " Update your CDP file  " << endl;
    }
  }
    
  fits_close_file(fptr,&local_status);
  if(local_status !=0 ) cout << "check_CDPFile:  Closing Fits File " << filename << " " << local_status << endl;

  return status;
}







