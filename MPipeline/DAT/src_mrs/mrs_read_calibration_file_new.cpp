
#include <iostream>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <iomanip>
#include <fstream>
#include <math.h>
#include <cstdlib>
#include "fitsio.h"
#include "mrs_preference.h"
#include "mrs_data_info.h"
#include "mrs_control.h"
#include "mrs_constants.h"

/**********************************************************************/
// Description of program:
// Read Calibration file- new format (CDP4) - distortion information stored
// as polynomials, transformation to V2,V3 also stored in file. 
/**********************************************************************/
// Read in list of input image filenames
int Check_CDPfile(string filename);

int mrs_read_calibration_file_new(const mrs_control control,
			      const mrs_preference preference,
			      mrs_data_info &data_info)


{

  int hdutype = 0; 
  string SCACH[2] = {"MIRI_FM_MIRIFUSHORT_12","MIRI_FM_MIRIFULONG_34"};
  string WAVEL[3] = {"SHORT","MEDIUM","LONG"};
  

  string calibration_file = control.calib_dir + SCACH[data_info.SCA_CUBE] + 
    WAVEL[data_info.WAVE_CUBE] +
    "_DISTORTION_"  + preference.calibration_version[data_info.SCA_CUBE] + ".fits";

  string calibration_filename = SCACH[data_info.SCA_CUBE] + WAVEL[data_info.WAVE_CUBE] +
    "_DISTORTION_"  + preference.calibration_version[data_info.SCA_CUBE] + ".fits";
    
  data_info.calibration_file =     calibration_file;
  data_info.calibration_filename =     calibration_filename;

  cout << " Calibration file using " << calibration_filename << endl;

  int status = 0;
  status = Check_CDPfile(calibration_file); 
  if(status !=0 ) {
    cout << " Program exiting, check file " << calibration_file << endl;
    exit(EXIT_FAILURE);
  }

  fitsfile *fptr;

  int anynul = 0;
  fits_open_file(&fptr,calibration_file.c_str(),READONLY,&status);
  if(status != 0 ) {
      cout << " Problem openning Calibration file " << calibration_file << " " << status << endl;
      cout << " Check and see if this file exists " << endl;
      exit(EXIT_FAILURE);
  }


  char comment[72];
  status = 0;

  if(data_info.SCA_CUBE == 0) {
      status = 0;
      fits_read_key(fptr, TFLOAT, "B_ZERO1", &data_info.beta_zero[0], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading B_ZERO1 of calibration file " << endl;

      fits_read_key(fptr, TFLOAT, "B_ZERO2", &data_info.beta_zero[1], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading B_ZERO2 of calibration file " << endl;

      fits_read_key(fptr, TFLOAT, "B_DEL1", &data_info.beta_delta[0], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading B_DEL1 of calibration file " << endl;

      fits_read_key(fptr, TFLOAT, "B_DEL2", &data_info.beta_delta[1], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading B_DEL2 of calibration file " << endl;



  } else if (data_info.SCA_CUBE == 1) {
      status = 0;
      fits_read_key(fptr, TFLOAT, "B_ZERO3", &data_info.beta_zero[0], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading B_ZERO3 of calibration file " << endl;

      fits_read_key(fptr, TFLOAT, "B_ZERO4", &data_info.beta_zero[1], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading B_ZERO4 of calibration file " << endl;

      fits_read_key(fptr, TFLOAT, "B_DEL3", &data_info.beta_delta[0], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading B_DEL3 of calibration file " << endl;

      fits_read_key(fptr, TFLOAT, "B_DEL4", &data_info.beta_delta[1], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading B_DEL4 of calibration file " << endl;
  }

  cout << " Beta zero,del 0 " << data_info.beta_zero[0] << " " << data_info.beta_delta[0] << endl; 
  cout << " Beta zero,del 1 " << data_info.beta_zero[1] << " " << data_info.beta_delta[1] << endl; 


  fits_movabs_hdu(fptr,2,&hdutype,&status);

  fits_read_key(fptr, TLONG, "NAXIS1", &data_info.cal_naxes[0], comment, &status); // get the size
  if(status !=0 ) cout << "mrs_read_calibration_file:  Problem reading naxis[0] of calibration file " << endl;
  status = 0;
  fits_read_key(fptr, TLONG, "NAXIS2", &data_info.cal_naxes[1], comment, &status); // of the data
  if(status !=0 ) cout << "mrs_read_calibration:  Problem reading naxis[1] of calibration file " << endl;
  status = 0;

  long nelements = data_info.cal_naxes[0] * data_info.cal_naxes[1] ;

  vector<int>  data1(nelements); 

  fits_read_img(fptr,TINT,1,nelements,0,&data1[0],&anynul,&status);

  status = 0;
  if(status != 0) {
    cout <<" Problem calibration file, extenstion 1" << endl;
    cout << " status " << status << endl;
    status = 1;
    return status;
  }


  for (long ii = 0; ii<nelements; ii++){
    data_info.slice_number.push_back(int(data1[ii]));

  }


  //________________________________________________________________________________
  // read in tables

  // Alpha Ch 1 or 3
  fits_movabs_hdu(fptr,5,&hdutype,&status);

  long nrows=0;
  int ncols=0;
  status = 0;
  fits_get_num_rows(fptr, &nrows,&status);
  fits_get_num_cols(fptr, &ncols,&status);


  if(ncols != NUM_TABLE_COLS){
    cout << " The number of Columns is the distortion files is not what is expected" << endl;
    cout << " Number in Table " << ncols << endl;
    cout << " Number expected" << NUM_TABLE_COLS << endl;
    cout << " Contact Jane Morrison - morrison@as.arizona.ed - for this error" << endl;
    exit(EXIT_FAILURE);
  }
  int nulval = 0;
  vector<float>  coeff1(nrows); 
  
  for (int icol=0; icol< ncols; icol++){
    fits_read_col(fptr,TFLOAT,icol+1,1L,1L,nrows,&nulval,&coeff1[0],&anynul,&status);
    if( icol ==0){
      for (int j=0; j<nrows ; j++){
	data_info.xas[0][j] = coeff1[j];
      }
    }else {
      for (int j=0; j<nrows ; j++){
	data_info.kalpha[0][j][icol-1] = coeff1[j];
      }
    }
  }

  //________________________________________________________________________________
  // lambda Ch 1 or 3
  fits_movrel_hdu(fptr,1,&hdutype,&status);

  nrows=0;
  ncols=0;
  status = 0;
  fits_get_num_rows(fptr, &nrows,&status);
  fits_get_num_cols(fptr, &ncols,&status);
  if(ncols != NUM_TABLE_COLS){
    cout << " The number of Columns is the distortion files is not what is expected" << endl;
    cout << " Number in Table " << ncols << endl;
    cout << " Number expected" << NUM_TABLE_COLS << endl;
    cout << " Contact Jane Morrison - morrison@as.arizona.ed - for this error" << endl;
    exit(EXIT_FAILURE);
  }

  nulval = 0;

  vector<float>  coeff2(nrows); 
  for (int icol=0; icol< ncols; icol++){
    fits_read_col(fptr,TFLOAT,icol+1,1L,1L,nrows,&nulval,&coeff2[0],&anynul,&status);
    if( icol ==0){
      for (int j=0; j<nrows ; j++){
	data_info.xls[0][j] = coeff2[j];
      }
    }else {
      for (int j=0; j<nrows ; j++){
	data_info.klambda[0][j][icol-1] = coeff2[j];
      }
    }
  }
  //________________________________________________________________________________
  // read in tables

  // Alpha Ch 2 or 4
  fits_movrel_hdu(fptr,1,&hdutype,&status);

  nrows=0;
  ncols=0;
  status = 0;
  fits_get_num_rows(fptr, &nrows,&status);
  fits_get_num_cols(fptr, &ncols,&status);
  if(ncols != NUM_TABLE_COLS){
    cout << " The number of Columns is the distortion files is not what is expected" << endl;
    cout << " Number in Table " << ncols << endl;
    cout << " Number expected" << NUM_TABLE_COLS << endl;
    cout << " Contact Jane Morrison - morrison@as.arizona.ed - for this error" << endl;
    exit(EXIT_FAILURE);
  }

  nulval = 0;
  vector<float>  coeff3(nrows); 
  
  for (int icol=0; icol< ncols; icol++){
    fits_read_col(fptr,TFLOAT,icol+1,1L,1L,nrows,&nulval,&coeff3[0],&anynul,&status);
    if( icol ==0){
      for (int j=0; j<nrows ; j++){
	data_info.xas[1][j] = coeff3[j];
      }
    }else {
      for (int j=0; j<nrows ; j++){
	data_info.kalpha[1][j][icol-1] = coeff3[j];
      }
    }
  }
  //________________________________________________________________________________
  // lambda Ch 1 or 3
  fits_movrel_hdu(fptr,1,&hdutype,&status);

  nrows=0;
  ncols=0;
  status = 0;
  fits_get_num_rows(fptr, &nrows,&status);
  fits_get_num_cols(fptr, &ncols,&status);
  if(ncols != NUM_TABLE_COLS){
    cout << " The number of Columns is the distortion files is not what is expected" << endl;
    cout << " Number in Table " << ncols << endl;
    cout << " Number expected" << NUM_TABLE_COLS << endl;
    cout << " Contact Jane Morrison - morrison@as.arizona.ed - for this error" << endl;
    exit(EXIT_FAILURE);
  }

  nulval = 0;
  vector<float>  coeff4(nrows); 
  
  for (int icol=0; icol< ncols; icol++){
    fits_read_col(fptr,TFLOAT,icol+1,1L,1L,nrows,&nulval,&coeff4[0],&anynul,&status);
    if( icol ==0){
      for (int j=0; j<nrows ; j++){
	data_info.xls[1][j] = coeff4[j];
      }
    }else {
      for (int j=0; j<nrows ; j++){
	data_info.klambda[1][j][icol-1] = coeff4[j];
      }
    }
  }




  //________________________________________________________________________________
  // alb > V2/V3



  fits_movabs_hdu(fptr,13,&hdutype,&status);

  nrows=0;
  ncols=0;
  status = 0;
  fits_get_num_rows(fptr, &nrows,&status);
  fits_get_num_cols(fptr, &ncols,&status);
  if(ncols != NUM_V2V3_COLS){
    cout << " The number of Columns for V2V3 in the distortion files is not what is expected" << endl;
    cout << " Number in Table " << ncols << endl;
    cout << " Number expected" << NUM_TABLE_COLS << endl;
    cout << " Contact Jane Morrison - morrison@as.arizona.ed - for this error" << endl;
    exit(EXIT_FAILURE);
  }

  nulval = 0;
  vector<float>  v2v3(nrows); 

  for (int icol=1; icol< ncols; icol++){
   fits_read_col(fptr,TFLOAT,icol+1,1L,1L,nrows,&nulval,&v2v3[0],&anynul,&status);
   

   int k = 0;
   int m = 0;
   if (icol ==2) m= 1;
   if (icol ==3) {
     k = 1;
     m = 0;
   }
   if( icol ==4){
     m = 1;
     k = 1;
   }

   data_info.v2coeff[0][k][m] = v2v3[0];
   data_info.v3coeff[0][k][m] = v2v3[1];

   data_info.v2coeff[1][k][m] = v2v3[2];
   data_info.v3coeff[1][k][m] = v2v3[3];
   

  }


  return 0; // ifstream destructor closes the file
}





