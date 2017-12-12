// mrs_read_pixel_mask.cpp
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
// Read Calibration file: 1025 X 1025 X 4 
/**********************************************************************/
// Read in list of input image filenames
int Check_CDPfile(string filename);

int mrs_read_calibration_file(const mrs_control control,
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
  //  cout << " Done checking calibration file" << endl;

  fitsfile *fptr;

  int anynul = 0;
  fits_open_file(&fptr,calibration_file.c_str(),READONLY,&status);
  if(status != 0 ) {
      cout << " Problem openning Calibration file " << calibration_file << " " << status << endl;
      cout << " Check and see if this file exists " << endl;
      if(control.ModelType ==1) cout << " The FM data flag is set, is this FM data ?, if not run with -VM  (or -ZM) option" << endl;
      exit(EXIT_FAILURE);
      //status = 1;
      //return status;
  }


  char comment[72];
  status = 0;

  if(data_info.SCA_CUBE == 0) {
      status = 0;
      fits_read_key(fptr, TDOUBLE, "L_MIN1", &data_info.wave_min[0], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading L_MIN1 of calibration file " << endl;
      fits_read_key(fptr, TDOUBLE, "L_MAX1", &data_info.wave_max[0], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading L_MAX1 of calibration file " << endl;

      fits_read_key(fptr, TDOUBLE, "L_MIN2", &data_info.wave_min[1], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading L_MIN2 of calibration file " << endl;
      fits_read_key(fptr, TDOUBLE, "L_MAX2", &data_info.wave_max[1], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading L_MAX2 of calibration file " << endl;


      fits_read_key(fptr, TDOUBLE, "A_MIN1", &data_info.alpha_min[0], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading A_MIN1 of calibration file " << endl;
      fits_read_key(fptr, TDOUBLE, "A_MAX1", &data_info.alpha_max[0], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading A_MAX1 of calibration file " << endl;

      fits_read_key(fptr, TDOUBLE, "A_MIN2", &data_info.alpha_min[1], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading A_MIN2 of calibration file " << endl;
      fits_read_key(fptr, TDOUBLE, "A_MAX2", &data_info.alpha_max[1], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading A_MAX2 of calibration file " << endl;

      fits_read_key(fptr, TDOUBLE, "B_MIN1", &data_info.beta_min[0], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading B_MIN1 of calibration file " << endl;
      fits_read_key(fptr, TDOUBLE, "B_DEL1", &data_info.beta_delta[0], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading B_DEL1 of calibration file " << endl;

      fits_read_key(fptr, TDOUBLE, "B_MIN2", &data_info.beta_min[1], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading B_MIN2 of calibration file " << endl;
      fits_read_key(fptr, TDOUBLE, "B_DEL2", &data_info.beta_delta[1], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading B_DEL2 of calibration file " << endl;

  } else if (data_info.SCA_CUBE == 1) {
      status = 0;
      fits_read_key(fptr, TDOUBLE, "L_MIN3", &data_info.wave_min[0], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading WVMIN3 of calibration file " << endl;
      fits_read_key(fptr, TDOUBLE, "L_MAX3", &data_info.wave_max[0], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading WVMAX3 of calibration file " << endl;

      fits_read_key(fptr, TDOUBLE, "L_MIN4", &data_info.wave_min[1], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading L_MIN4 of calibration file " << endl;
      fits_read_key(fptr, TDOUBLE, "L_MAX4", &data_info.wave_max[1], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading L_MAX4 of calibration file " << endl;


      fits_read_key(fptr, TDOUBLE, "A_MIN3", &data_info.alpha_min[0], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading A_MIN3 of calibration file " << endl;
      fits_read_key(fptr, TDOUBLE, "A_MAX3", &data_info.alpha_max[0], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading A_MAX3 of calibration file " << endl;

      fits_read_key(fptr, TDOUBLE, "A_MIN4", &data_info.alpha_min[1], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading A_MIN4 of calibration file " << endl;
      fits_read_key(fptr, TDOUBLE, "A_MAX4", &data_info.alpha_max[1], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading A_MAX4 of calibration file " << endl;

      fits_read_key(fptr, TDOUBLE, "B_MIN3", &data_info.beta_min[0], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading B_MIN3 of calibration file " << endl;
      fits_read_key(fptr, TDOUBLE, "B_DEL3", &data_info.beta_delta[0], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading B_DEL3 of calibration file " << endl;

      fits_read_key(fptr, TDOUBLE, "B_MIN4", &data_info.beta_min[1], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading B_MIN4 of calibration file " << endl;
      fits_read_key(fptr, TDOUBLE, "B_DEL4", &data_info.beta_delta[1], comment, &status); // of the data
      if(status !=0 ) cout << "mrs_read_calibration:  Problem reading B_DEL4 of calibration file " << endl;
  }

  float conversion_factor = 1.0;
  //  if(control.ModelType < 2) conversion_factor = 60.0;
  for (int i = 0; i< 2; i++){
    data_info.alpha_min[i] = data_info.alpha_min[i]*conversion_factor;  // convert to arc seconds
    data_info.alpha_max[i] = data_info.alpha_max[i]*conversion_factor; // convert to arc seconds

    data_info.beta_min[i] = data_info.beta_min[i]*conversion_factor;  // convert to arc seconds
    data_info.beta_delta[i] = data_info.beta_delta[i]*conversion_factor;  //  convert to arc seconds

    //cout << "Wavelength range  " << data_info.wave_min[i] << " " << data_info.wave_max[i] << endl;
    //cout << "Alpha range  " << data_info.alpha_min[i] << " " << data_info.alpha_max[i] << endl;
    //cout << "Beta parameters " <<data_info.beta_min[i] << " " << data_info.beta_delta[i] << endl;
  }




  if(data_info.SCA_CUBE ==0 ) {

    int nslice[2];
    nslice[0] = SLICENO[0]; 
    nslice[1] = SLICENO[1];

    string  xmin1[] = {"XMN_1_1","XMN_1_2","XMN_1_3","XMN_1_4","XMN_1_5","XMN_1_6",
		       "XMN_1_7","XMN_1_8","XMN_1_9","XMN_1_10","XMN_1_11","XMN_1_12",
		       "XMN_1_13","XMN_1_14","XMN_1_15","XMN_1_16","XMN_1_17","XMN_1_18",
		       "XMN_1_19","XMN_1_20","XMN_1_21"};


    string  xmax1[] = {"XMX_1_1","XMX_1_2","XMX_1_3","XMX_1_4","XMX_1_5","XMX_1_6",
		       "XMX_1_7","XMX_1_8","XMX_1_9","XMX_1_10","XMX_1_11","XMX_1_12",
		       "XMX_1_13","XMX_1_14","XMX_1_15","XMX_1_16","XMX_1_17","XMX_1_18",
		       "XMX_1_19","XMX_1_20","XMX_1_21"};

    string  xmin2[] = {"XMN_2_1","XMN_2_2","XMN_2_3","XMN_2_4","XMN_2_5","XMN_2_6",
		       "XMN_2_7","XMN_2_8","XMN_2_9","XMN_2_10","XMN_2_11","XMN_2_12",
		       "XMN_2_13","XMN_2_14","XMN_2_15","XMN_2_16","XMN_2_17"};


    string  xmax2[] = {"XMX_2_1","XMX_2_2","XMX_2_3","XMX_2_4","XMX_2_5","XMX_2_6",
		       "XMX_2_7","XMX_2_8","XMX_2_9","XMX_2_10","XMX_2_11","XMX_2_12",
		       "XMX_2_13","XMX_2_14","XMX_2_15","XMX_2_16","XMX_2_17"};


    for (int j = 0; j< 2; j++){
      for (int i = 0; i < nslice[j]; i++){
	int xmin = 0;
	int xmax = 0;

      if(j == 0) {
	int len = xmin1[i].length();
	char *min = new char[len+1];
	xmin1[i].copy(min,len,0);
	min[len] = 0;
	
	len = xmax1[i].length();
	char *max = new char[len+1];
	xmax1[i].copy(max,len,0);
	max[len] = 0;

	fits_read_key(fptr, TINT, min, &xmin, comment, &status); 
	if(status !=0 ) cout << "mrs_read_channel_files:  Problem reading " << min <<  " " 
			     << " status " <<status << endl;
	data_info.slice_range_min[j][i] = xmin;

	fits_read_key(fptr, TINT, max, &xmax, comment, &status); 
	if(status !=0 ) cout << "mrs_read_channel_files:  Problem reading " << max <<  " " 
			     << " status " << status << endl;
	data_info.slice_range_max[j][i] = xmax;

      } else {
	int len = xmin2[i].length();
	char *min = new char[len+1];
	xmin2[i].copy(min,len,0);
	min[len] = 0;

	len = xmax2[i].length();
	char *max = new char[len+1];
	xmax2[i].copy(max,len,0);
	max[len] = 0;

	fits_read_key(fptr, TINT, min, &xmin, comment, &status); 
	if(status !=0 ) cout << "mrs_read_channel_files:  Problem reading " << min <<  status << endl;
	data_info.slice_range_min[j][i] = xmin;

	fits_read_key(fptr, TINT, max, &xmax, comment, &status); 
	if(status !=0 ) cout << "mrs_read_channel_files:  Problem reading " << max <<  status << endl;
	data_info.slice_range_max[j][i] = xmax;
      }

      //cout <<" Slice edges " <<  i << " " << j  << " " << data_info.slice_range_min[j][i] << " " << 
      //	data_info.slice_range_max[j][i] << endl;
      }

    }
  }

  if(data_info.SCA_CUBE == 1) { 
    int nslice[2];
    nslice[0] = SLICENO[2];
    nslice[1] = SLICENO[3];

    string xmin3[] = {"XMN_3_1","XMN_3_2","XMN_3_3","XMN_3_4","XMN_3_5","XMN_3_6",
		      "XMN_3_7","XMN_3_8","XMN_3_9","XMN_3_10","XMN_3_11","XMN_3_12",
		      "XMN_3_13","XMN_3_14","XMN_3_15","XMN_3_16"};


    string  xmax3[] = {"XMX_3_1","XMX_3_2","XMX_3_3","XMX_3_4","XMX_3_5","XMX_3_6",
		       "XMX_3_7","XMX_3_8","XMX_3_9","XMX_3_10","XMX_3_11","XMX_3_12",
		       "XMX_3_13","XMX_3_14","XMX_3_15","XMX_3_16"};
    
    string  xmin4[] = {"XMN_4_1","XMN_4_2","XMN_4_3","XMN_4_4","XMN_4_5","XMN_4_6",
		       "XMN_4_7","XMN_4_8","XMN_4_9","XMN_4_10","XMN_4_11","XMN_4_12"};


    string  xmax4[] = {"XMX_4_1","XMX_4_2","XMX_4_3","XMX_4_4","XMX_4_5","XMX_4_6",
		       "XMX_4_7","XMX_4_8","XMX_4_9","XMX_4_10","XMX_4_11","XMX_4_12"};


    for (int j = 0; j< 2; j++){
      for (int i = 0; i < nslice[j]; i++){
	int xmin = 0;
	int xmax = 0;

	if(j == 0) {
	  int len = xmin3[i].length();
	  char *min = new char[len+1];
	  xmin3[i].copy(min,len,0);
	  min[len] = 0;
	
	  len = xmax3[i].length();
	  char *max = new char[len+1];
	  xmax3[i].copy(max,len,0);
	  max[len] = 0;
	  
	  fits_read_key(fptr, TINT, min, &xmin, comment, &status); 
	  if(status !=0 ) cout << "mrs_read_channel_files:  Problem reading " << min <<  " " 
			     << " status " <<status << endl;
	  data_info.slice_range_min[j][i] = xmin;

	  fits_read_key(fptr, TINT, max, &xmax, comment, &status); 
	  if(status !=0 ) cout << "mrs_read_channel_files:  Problem reading " << max <<  " " 
			       << " status " << status << endl;
	  data_info.slice_range_max[j][i] = xmax;

	} else {
	  
	  int len = xmin4[i].length();
	  char *min = new char[len+1];
	  xmin4[i].copy(min,len,0);
	  min[len] = 0;
	
	  len = xmax4[i].length();
	  char *max = new char[len+1];
	  xmax4[i].copy(max,len,0);
	  max[len] = 0;

	  fits_read_key(fptr, TINT, min, &xmin, comment, &status); 
	  if(status !=0 ) cout << "mrs_read_channel_files:  Problem reading " << min <<  status << endl;
	  data_info.slice_range_min[j][i] = xmin;

	  fits_read_key(fptr, TINT, max, &xmax, comment, &status); 
	  if(status !=0 ) cout << "mrs_read_channel_files:  Problem reading " << max <<  status << endl;
	  data_info.slice_range_max[j][i] = xmax;
	}

	//cout <<" Slice edges " <<  i << " " << j  << " " << data_info.slice_range_min[j][i] << " " << 
	//	data_info.slice_range_max[j][i] << endl;

      }
    }
  }
  
  //_______________________________________________________________________
  


  fits_movabs_hdu(fptr,2,&hdutype,&status);


  fits_read_key(fptr, TLONG, "NAXIS1", &data_info.cal_naxes[0], comment, &status); // get the size
  if(status !=0 ) cout << "mrs_read_calibration_file:  Problem reading naxis[0] of calibration file " << endl;
  status = 0;
  fits_read_key(fptr, TLONG, "NAXIS2", &data_info.cal_naxes[1], comment, &status); // of the data
  if(status !=0 ) cout << "mrs_read_calibration:  Problem reading naxis[1] of calibration file " << endl;
  status = 0;

  long nelements = data_info.cal_naxes[0] * data_info.cal_naxes[1] ;
  //  cout << nelements <<  " " << data_info.cal_naxes[0] << " " <<  data_info.cal_naxes[1] ;
  vector<double>  data1(nelements); 
  vector<double>  data2(nelements); 
  vector<double>  data3(nelements); 

  fits_read_img(fptr,TDOUBLE,1,nelements,0,&data1[0],&anynul,&status);

  status = 0;
  if(status != 0) {
    cout <<" Problem calibration file, extenstion 1" << endl;
    cout << " status " << status << endl;
    status = 1;
    return status;
  }


  status = 0;
  fits_movabs_hdu(fptr,3,&hdutype,&status);
  fits_read_img(fptr,TDOUBLE,1,nelements,0,&data2[0],&anynul,&status);

  if(status != 0) {
    cout <<" Problem calibration file, extenstion 2" << endl;
    cout << " status " << status << endl;
    status = 1;
    return status;
  }
  status = 0;
  fits_movabs_hdu(fptr,4,&hdutype,&status);
  fits_read_img(fptr,TDOUBLE,1,nelements,0,&data3[0],&anynul,&status);

  if(status != 0) {
    cout <<" Problem calibration file, extenstion 3" << endl;
      cout << " status " << status << endl;
      status = 1;
      return status;
  }

  for (long ii = 0; ii<nelements; ii++){
    data_info.wavelength.push_back(data1[ii]);
    data_info.alpha.push_back(data2[ii]*conversion_factor); // convert to arc seconds
    data_info.slice_number.push_back(int(data3[ii]));

  }
  

	

  return 0; // ifstream destructor closes the file
}





