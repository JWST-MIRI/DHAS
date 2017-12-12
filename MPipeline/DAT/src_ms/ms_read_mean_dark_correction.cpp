// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//   ms_read_mean_dark_correction.cpp
//
// Purpose:
// Read in the mean dark correction
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
//
// Arugments:
//
//
//
// Return Value/ Variables modified:
//     status = 0, no problems encountered.
//     status not equal 0 then an error was encountered.  
// 
//
// History:
//
//	Written by Jane Morrison 2010
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/

#include <iostream>
#include <sstream> 
#include <vector>
#include <string>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_sloper.h"

int ms_read_mean_dark_correction(string mdc_filename, const int n_reads_start_fit, 
				 miri_data_info &data_info,
				 const int verbose)
{
  
  int status = 0;


  cout << " Reading Mean Dark correction file name " << mdc_filename << endl;
  ifstream mdc_file(mdc_filename.c_str());
  if (!mdc_file) {
    cout << " Mean Dark  Correction file  does not exist" << mdc_filename << endl;
    cout << " Run again and either correct filename or run with -D option (no Dark  correction)" << endl;
    exit(EXIT_FAILURE);
  }

  status = Check_CDPfile(mdc_filename); 
  if(status !=0 ) {
    cout << " Program exiting, check file " << mdc_filename << endl;
    exit(EXIT_FAILURE);
  }

  status  = 0;
  fitsfile *file_ptr;   
  fits_open_file(&file_ptr, mdc_filename.c_str(), READONLY, &status);   // open the file
  if(status !=0) {
    cout << " Failed to open Mean Dark Correction fits file: " << mdc_filename << endl;
    cout << " Reason for failure, status = " << status << endl;
    exit(EXIT_FAILURE);
  }

  status = 0;
  int hdutype = 0;


  fits_movabs_hdu(file_ptr,2,&hdutype,&status);

  status = 0;

  long inc[3]={1,1,1};
  int anynul = 0;  // null values

  long fpixel[3] ;
  long lpixel[3];

  // lower left corner of subset

  
  fpixel[0]= data_info.ColStart;
  fpixel[1]= data_info.RowStart;

  lpixel[0] = fpixel[0] + data_info.ramp_naxes[0] -1;
  lpixel[1] = fpixel[1] + data_info.ramp_naxes[1] -1;

  fpixel[2]=1 + n_reads_start_fit;
  lpixel[2]=data_info.mdc_cor_naxes[2];
  if(data_info.mdc_cor_naxes[2] > data_info.NRamps) 
    lpixel[2]= data_info.NRamps;  // only read in the number of frames needed

  //  int nplanes = data_info.mdc_cor_naxes[2];;
  int nplanes = lpixel[2] - fpixel[2] + 1;
  
  
  // cout << " Number of frames reading from Mean Dark " << nplanes << endl;
  //cout << " Number of dark frames reading and storing in memory" << lpixel[2] << endl;
  //cout << " first pixel " << fpixel[0] << " " << fpixel[1] << " " << fpixel[2] << endl;
  // cout << " last  pixel " << lpixel[0] << " " << lpixel[1] << " " << lpixel[2] << endl;


  long ixyz =data_info.ramp_naxes[0] * data_info.ramp_naxes[1] * nplanes;


  vector<float>  data(ixyz);

  status = 0;
  fits_read_subset_flt(file_ptr, 0, data_info.mdc_cor_naxis, data_info.mdc_cor_naxes, 
                         fpixel,lpixel,
                         inc,0, 
                         &data[0], &anynul, &status);

  if(status !=0) {
    cout << " Problem reading in Mean Dark Correction Coefficients " << endl;
    cout << " Error status " << status << endl;
    exit(EXIT_FAILURE);
  }


  long nelements = data_info.mdc_cor_naxes[0] * data_info.mdc_cor_naxes[1];
  data_info.MeanDark.erase(data_info.MeanDark.begin(),data_info.MeanDark.end());


  for (long iy = 0 ; iy < data_info.ramp_naxes[1]; iy ++){

    for (long ix = 0 ; ix < data_info.ramp_naxes[0]; ix++){
      vector<float>  terms(nplanes);
      for (int iplanes = 0; iplanes < nplanes ; iplanes++) {
	long ielement = iplanes*nelements + iy*data_info.ramp_naxes[0] + ix;
	
	terms[iplanes] = data[ielement];
	//	cout << ix << " " << iy << " " << iplanes << " " <<  ielement << " " << data[ielement] << endl;
      }

      data_info.MeanDark.push_back(terms);
    }
  }



  //_______________________________________________________________________
  // read in the error plane for mean dark
  data_info.use_mean_dark_error_plane = 0; 
  hdutype =0;
    
  status  = 0; 
  fits_movabs_hdu(file_ptr,4,&hdutype,&status);
  if(status !=0) {
    cout <<" Error reading in Mean Dark Error Fit" << endl;
  } else { 
    //    cout << " Going to read  Mean Dark Error Plane " << endl;
    long nelements = data_info.mdc_cor_naxes[0] * data_info.mdc_cor_naxes[1];
    vector<float>  data(nelements); 
    status = 0;
    fits_read_img(file_ptr,TFLOAT,1,nelements,0,&data[0],&anynul,&status);
    if(status != 0 ) {
      cout << " Problem reading Error Plane from Mean Dark File  " << mdc_filename << " " << status << endl;
      cout << " Contining with program, ignoring Error Plane " <<endl;
      data_info.use_mean_dark_error_plane = 0;
    }
    data_info.MeanDark_Error.assign(data.begin(),data.end());
    data_info.use_mean_dark_error_plane  = 1; 
  } 
  

  fits_close_file(file_ptr,&status);

  return status;
}







