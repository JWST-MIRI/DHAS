// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//      ms_setup_dark
//
// Purpose:
// 
// If the entire dark was already read in (subset_number) = 0 then
// fill in dark to use
// If it has not been read in the read it in subset mode. 
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
// Arugments:
//

// History:
//
//	Written by Jane Morrison 2013

#include <time.h>
#include <iostream>
#include <vector>
#include <string>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_control.h"
#include "miri_constants.h"
#include "miri_sloper.h"
#include "miri_CDP.h"
#include "miri_refcorrection.h"


void ms_read_dark_reference_pixels(int ii,
				   miri_control &control,
				   miri_data_info &data_info,
				   miri_CDP CDP,
				   vector<miri_refcorrection> &refcorrection)



{
  // Dark format:
  // Primary empty
  // SCI 1st ext
  // ERR 2nd ext
  // FITERR 3rd ext
  // DQ 4th ext
  
  // **********************************************************************
  // open the dark file - pull out reference pixels
  // a few variables for use in FITS I/O
  // As the data is read in ignore and reject data based on the following:
  // a. ignore an initial frames to be rejected (set by control.n_reads_start_fit)
  // b. ignore final frames to get rejected (determined by data_info.NRampsRead.
  //    data_info.NRampsRead = (control.n_reads_end_fit - control.n_reads_start_fit) + 1;
  //_______________________________________________________________________

  long inc[4]={1,1,1,1};
  int anynul = 0;  // null values
  int status = 0;
  int hdutype = 0; 

  string dark_file = CDP.GetDarkUseName( );
  if(control.flag_dark_cor_file ==0) { // from CDP list add calibration directory
    dark_file= control.calib_dir+ dark_file;
  }   

  cout << " Reading   Dark Calibration file name " << dark_file << endl;
  ifstream Dark_file(dark_file.c_str());
  if (!Dark_file) {
    cout << " Dark  Calibration file  does not exist" << dark_file << endl;
    cout << " Run again and either correct filename or run with -D option (no Dark  correction)" << endl;
    exit(EXIT_FAILURE);
  }


  status  = 0;
  fitsfile *file_ptr;   
  fits_open_file(&file_ptr, dark_file.c_str(), READONLY, &status);   // open the file
  if(status !=0) {
    cout << " Failed to open  Dark Calibration fits file: " <<dark_file << endl;
    cout << " Reason for failure, status = " << status << endl;
    exit(EXIT_FAILURE);
  }


  fits_movabs_hdu(file_ptr,2,&hdutype,&status); // One for primary array      
  if(status !=0) {
    cout <<" Error in moving to Dark Extension " << endl;
    exit(EXIT_FAILURE);
  }
  char comment[72];
  status = 0;
  long naxes0 = 0;
  fits_read_key(file_ptr, TLONG, "NAXIS1", &naxes0, comment, &status); // get the x size
  if(status !=0 ) cout << "ms_setup_dark:  Problem reading naxis1 of Mean Dark Correction image " << endl;

  long naxes1 = 0;
  fits_read_key(file_ptr, TLONG, "NAXIS2", &naxes1, comment, &status); // get they  size
  if(status !=0 ) cout << "ms_setup_dark:  Problem reading naxis2 of Mean Dark Correction image " << endl;

  long naxes2 = 0;
  fits_read_key(file_ptr, TLONG, "NAXIS3", &naxes2, comment, &status); // get the nplanes
  if(status !=0 ) cout << "ms_setup_dark:  Problem reading naxis3 of Mean Dark Correction image " << endl;

  long naxes3 = 0;
  fits_read_key(file_ptr, TLONG, "NAXIS4", &naxes3, comment, &status); // get the nplanes
  if(status !=0 ) cout << "ms_setup_dark:  Problem reading naxis4 of Mean Dark Correction image " << endl;


  //***********************************************************************

  status = 0;
  long fpixel[4] ;
  long lpixel[4];
  long  ysize = data_info.ramp_naxes[1];
  
  fpixel[1]= 1;  // starting y values (does not change for routine)
  lpixel[1] = ysize;

  fpixel[3]= ii+1;  // integration # = 1 or 2 
  lpixel[3] =fpixel[3];

  int istart = control.n_reads_start_fit;
  // read in all frames 
  fpixel[2]=istart +1;

  int end_frame = fpixel[2] + data_info.NRampsRead-1;
  if(end_frame > naxes2-1) end_frame = naxes2;
  lpixel[2] = end_frame;

  long nplanes = lpixel[2] - fpixel[2] + 1;
  long irxyz =nplanes*ysize*4;
  long irxy = ysize*4;


  // ********************************************************************************
  // Left reference pixels
  fpixel[0]=1;   // lefthand 4 reference pixels 
  lpixel[0] = 4;

  //cout << " left side parameters 1: " << fpixel[0] << " " << lpixel[0] << endl;
  //cout << " left side parameters 2: " << fpixel[1] << " " << lpixel[1] << endl;
  //cout << " left side parameters 3: " << fpixel[2] << " " << lpixel[2] << endl;
  //cout << " left side parameters 4: " << fpixel[3] << " " << lpixel[3] << endl;
  vector<float>  data(irxyz);

  status = 0;

  fits_read_subset(file_ptr,TFLOAT,
		   fpixel,lpixel,
		   inc,0, 
		   &data[0], &anynul, &status);

  if(status != 0 ) {
    cout << " Problem reading left reference pixels from Dark File  " << dark_file << " " << status << endl;
    exit(EXIT_FAILURE);
  }


  long ik =0;
  for (register int k = 0; k < ysize ; k++){ // 0 to 1024
    for (register int j = 0; j< 4 ; j++,ik++){  // 0 to 4
      for (int iplanes = 0; iplanes < nplanes ; iplanes++) {
	long ielement = iplanes*irxy + k*4 + j;
	float dark_value = data[ielement];
	refcorrection[iplanes].SetDarkLeft(j,k,dark_value);
	//		cout << k << " " << j << " " << iplanes << " " << ielement << " " << dark_value << endl;
      }
    }
  }


  // ********************************************************************************
  // right reference pixels
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  if(data_info.subarray_mode ==0) { // full array data
    fpixel[0]=1029;   // right hand 4 reference pixels 
    lpixel[0] = 1032;

    vector<float>  rdata(irxyz);
    status = 0;
    //cout << " right side parameters 1: " << fpixel[0] << " " << lpixel[0] << endl;
    //cout << " right side parameters 2: " << fpixel[1] << " " << lpixel[1] << endl;
    //cout << " right side parameters 3: " << fpixel[2] << " " << lpixel[2] << endl;
    //cout << " right side parameters 4: " << fpixel[3] << " " << lpixel[3] << endl;
    fits_read_subset(file_ptr,TFLOAT,
		     fpixel,lpixel,
		     inc,0, 
		     &rdata[0], &anynul, &status);

    if(status != 0 ) {
      cout << " Problem reading right  reference pixels from Dark File  " << dark_file << " " << status << endl;
      exit(EXIT_FAILURE);
    }

    long ik =0;
    for (register int k = 0; k < ysize ; k++){ // 0 to 1024
      for (register int j = 0; j< 4 ; j++,ik++){  // 0 to 4
	for (int iplanes = 0; iplanes < nplanes ; iplanes++) {
	  long ielement = iplanes*irxy + k*4 + j;
	  float dark_value = rdata[ielement];
	  refcorrection[iplanes].SetDarkRight(j,k,dark_value);
	  //	cout << k << " " << j << " " << iplanes << " " << ielement << " " << dark_value << endl;
	}
      }
    }

  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  } else{ // there are no right reference pixels - for ease set = 0
    for (register int k = 0; k < ysize ; k++){ // 0 to 1024
      for (register int j = 0; j< 4 ; j++,ik++){  // 0 to 4
	for (int iplanes = 0; iplanes < nplanes ; iplanes++) {
	  float dark_value = 0.0;
    	  refcorrection[iplanes].SetDarkRight(j,k,dark_value);
	}
      }
    }
  }

  fits_close_file(file_ptr,&status);


}
