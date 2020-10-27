// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//   ms_read_linearity_file.cpp
//
// Purpose:
// Read in the linearity correction file
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
//int ms_read_linearity_file(string lc_filename,miri_data_info &data_info)
// Primary - empty
// 1st extension- Correction
// 2nd extension - error on terms
// 3rd extension - DQ
//
//
// Arugments:
//
//  lc_filename: file that contains the linearity correction terms 
//  data_info: miri_data_info structure containing basic information on the dataset
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
//      Updated in April 2015 to read in CDP4 format and method of correcting for non-linearity
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/

#include <iostream>
#include <sstream> 
#include <vector>
#include <string>
#include "fitsio.h"
#include "miri_sloper.h"
#include "miri_control.h"
#include "miri_data_info.h"
#include "miri_lin.h"
#include "miri_CDP.h"

int ms_read_linearity_file(miri_data_info &data_info,
			   miri_control &control,
			   miri_CDP &CDP,
			   vector<miri_lin> &linearity)
{
  
  int status = 0;
  int hdutype = 0 ; 

  string lc_filename = "null";

  if(control.flag_lin_cor_file == 1){ // set by user
    lc_filename = control.lin_cor_file;
  }
  if(control.flag_lin_cor_file == 0){ // not set by the user
	                       
    control.lin_cor_file = CDP.GetLinCorName();
    lc_filename= control.calib_dir+ control.lin_cor_file;   
  }

  control.lin_cor_file = lc_filename; 
  cout << " reading in Linearity Correction Calibration file: "<< control.lin_cor_file << endl;
  status = 0;

  ifstream lc_file(lc_filename.c_str());
  if (!lc_file) {
    cout << " Linearity Correction file  does not exist" << lc_filename << endl;
    cout << " Run again and either correct linearity filename or run with -L option (no Linearity correction)" << endl;

    exit(EXIT_FAILURE);
  }


  if(control.do_verbose ==1) cout << " Going to read Linearity file " << endl;

  status  = 0;
  fitsfile *file_ptr;   
  fits_open_file(&file_ptr, lc_filename.c_str(), READONLY, &status);   // open the file
  if(status !=0) {
    cout << " Failed to open linearity Correction fits file: " << lc_filename << endl;
    cout << " Reason for failure, status = " << status << endl;
    exit(EXIT_FAILURE);
  }
  

  char comment[72];
  fits_movabs_hdu(file_ptr,2,&hdutype,&status); // for to first extension  
  long lin_cor_naxes[3];
  status = 0;
  fits_read_key(file_ptr, TLONG, "NAXIS1", &lin_cor_naxes[0], comment, &status); // get the size
  if(status !=0 ) cout << "ms_read_linearity:  Problem reading naxis[0] of Linearity Correction image " << endl;
  status = 0;
  fits_read_key(file_ptr, TLONG, "NAXIS2", &lin_cor_naxes[1], comment, &status); // of the data
  if(status !=0 ) cout << "ms_read_linearity:  Problem reading naxis[1] of Linearity Correction image " << endl;
  fits_read_key(file_ptr, TLONG, "NAXIS3", &lin_cor_naxes[2], comment, &status); // of the data
  if(status !=0 ) cout << "ms_read_linearity:  Problem reading naxis[2] of Linearity Correction image " << endl;


  int lin_order =0;
  lin_order = lin_cor_naxes[2] -1;

  CDP.SetLinOrder(lin_order); 

  if(lin_order < 2 || lin_order > 5) {
    cout << " Linearity correction order not supported by this software" << endl;
    cout << " Order in given linearity correction file " << lin_order << endl;
    cout << " Order allowed : 2, 3, 4, 5" << endl;
    cout << " run again and provide a different linearity correction file (-Lf filename) or do not correct for non-linearity (-L)" << endl;
    exit(EXIT_FAILURE);
  }
  long inc[3]={1,1,1};
  int anynul = 0;  // null values

  long fpixel[3] ;
  long lpixel[3];

  // lower left corner of subset
  
  fpixel[0]= data_info.ColStart;
  fpixel[1]= data_info.RowStart;

  lpixel[0] = fpixel[0] + data_info.ramp_naxes[0] -1;
  lpixel[1] = fpixel[1] + data_info.ramp_naxes[1] -1;

  int nplanes = lin_order+1;  

  fpixel[2]=1;
  lpixel[2]=nplanes;

  //  cout << " reading linearity correction" << endl;
  //cout << " first pixel " << fpixel[0] << " " << fpixel[1] << " " << fpixel[2] << endl;
  //cout << " last  pixel " << lpixel[0] << " " << lpixel[1] << " " << lpixel[2] << endl;


  long ixyz =data_info.ramp_naxes[0] * data_info.ramp_naxes[1] * nplanes;
  vector<float>  data(ixyz);

  status = 0;

  fits_read_subset(file_ptr, TFLOAT, 
		   fpixel,lpixel,
		   inc,0, 
		   &data[0], &anynul, &status);

  if(status !=0) {
    cout << " Problem reading in Linearity Correction Coefficients " << endl;
    cout << " Error status " << status << endl;
    exit(EXIT_FAILURE);
  }
  
  long nelements = data_info.ramp_naxes[0] * data_info.ramp_naxes[1];


  long ik = 0 ;
  for (long iy = 0 ; iy < data_info.ramp_naxes[1]; iy ++){
    for (long ix = 0 ; ix < data_info.ramp_naxes[0]; ix++){
      vector<float>  terms(nplanes);
      for (int iplanes = 0; iplanes < nplanes ; iplanes++) {
	long ielement = iplanes*nelements + iy*data_info.ramp_naxes[0] + ix;
	linearity[ik].SetCorrection(data[ielement]);
	if(ix+1 == -195 && iy+1 == 215) {
	  cout << "lin ref data " <<  iplanes << " " << data[ielement] << endl;
	}

      }
      ik++;

    }
  }


 
  //_______________________________________________________________________
  // Now read data quality flag

  long ixy =data_info.ramp_naxes[0] * data_info.ramp_naxes[1];
  vector<int>  lin_dq(ixy);

  lpixel[2]=1; // set up  dimension for dq  to be 1 plane


  // Move and read in Data Quaility Flag
  //  fits_movabs_hdu(file_ptr,4,&hdutype,&status); // 
  fits_movabs_hdu(file_ptr,4,&hdutype,&status); // 
  if(status !=0 ) cout << "ms_read_linearity:  Could not move to DQ extension " << endl;
  status = 0;
  fits_read_subset(file_ptr, TINT, 
		   fpixel,lpixel,
		   inc,0, 
		   &lin_dq[0], &anynul, &status);

  if(control.do_verbose == 1) cout << "Done reading all data " << endl;

  ik = 0; 
  for (long iy = 0 ; iy < data_info.ramp_naxes[1]; iy ++){
    for (long ix = 0 ; ix < data_info.ramp_naxes[0]; ix++){
	long ielement = iy*data_info.ramp_naxes[0] + ix;
	linearity[ik].SetDQ(lin_dq[ielement]);
	ik++;
    }
  }


  fits_close_file(file_ptr,&status);
  return status;
}







