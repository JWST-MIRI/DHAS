#include <iostream>
#include <stdio.h>
#include <string.h>
#include <vector>
#include <string>
#include "fitsio.h"
#include "mrs_CubeHeader.h"
#include "mrs_control.h"
#include "dhas_version.h"
#include "mrs_data_info.h"
#include "miri_cube.h"
// program to define the filenames - input and outputcdme


void mrs_write_header(fitsfile *file_ptr,
		      CubeHeader cubeHead, mrs_control control,
		      mrs_data_info data_info)

{


  //char *yes_str = "Yes"; // string for the yes answer
  //char *no_str = "No";   // string for the no answer
  char version[30];
  strcpy(version,dhas_version);

  int status = 0;


  // ______________________________

  fits_write_comment(file_ptr, "file created by miri_cube program",&status);
  fits_write_comment(file_ptr, "MIRI DHAS  Team Pipeline",&status);
  fits_write_comment(file_ptr, "Jane Morrison",&status);
  fits_write_comment(file_ptr, "email morrison@as.arizona.edu for info",&status);
  fits_write_comment(file_ptr, "**--------------------------------------------------------------**",&status);

 //_______________________________________________________________________
  // open first Filename (miri_cube has been set up to run with 1 file) 

  string filename = cubeHead.GetInputFilename(0);
  //cout << " filename reading header" << filename << endl;

  fitsfile *raw_file_ptr;
  status = 0;   
  fits_open_file(&raw_file_ptr,filename.c_str(), READONLY, &status);   // open the file
  if(status !=0) {
    cout << " Failed to open fits file: " << filename << endl;
    cout << " Reason for failure, status = " << status << endl;
    exit(EXIT_FAILURE);
  }
  status = 0;
  fits_write_comment(file_ptr, 
		    "Original LVL2 sloper  Header Copied ",&status);

  miri_copy_slope_header(raw_file_ptr, file_ptr, status);
 if(status !=0 ) {
   cout << " Did not copy the original header to Cube Fits file " << endl;
   cout << " Status " << status << endl;
 }

 fits_write_comment(file_ptr, 
		    "Finished Copying Original Header ",&status);
 fits_write_comment(file_ptr, "**--------------------------------------------------------------**",&status);

 //_______________________________________________________________________
  fits_write_comment(file_ptr, "Reduced Data",&status);
  fits_write_comment(file_ptr, "Primary: signal (DN/s)",&status);
  fits_write_comment(file_ptr, "Extension 1: uncertainty (DN/s)",&status);
  fits_write_comment(file_ptr, "Extension 2: Data Quality Flag",&status);
  fits_write_comment(file_ptr, "Extension 3: Total Overlap",&status);
  fits_write_comment(file_ptr, "X axis: cube direction: Alpha",&status);
  fits_write_comment(file_ptr, "Y axis: cube direction: Beta",&status);
  fits_write_comment(file_ptr, "Z axis: cube direction: Lamba",&status);
  fits_write_comment(file_ptr, "**--------------------------------------------------------------**",&status);

 fits_write_key(file_ptr, TSTRING, "MRS_VER", &version, "dhas cube build version", &status);


 double crpix1 = cubeHead.GetCrpix1();
 double crpix2 = cubeHead.GetCrpix2();
 double crpix3 = cubeHead.GetCrpix3();

 double crval1 = cubeHead.GetCrval1();
 double crval2 = cubeHead.GetCrval2();
 double crval3 = cubeHead.GetCrval3();

 double cdelt1 = cubeHead.GetCdelt1();
 double cdelt2 = cubeHead.GetCdelt2();
 double cdelt3 = cubeHead.GetCdelt3();

 int channel = cubeHead.GetChannel();

 int subchannel = cubeHead.GetSubChannel();

 int numTiles = cubeHead.GetNumTiles();
 
 int NSample = cubeHead.GetNSample();
 int integration_no = 0;
 if(control.flag_integration_no !=0) {
   integration_no = control.integration_no;
 }
 //_______________________________________________________________________
    //convert from a string class to character string
    // see page 957 How to Program in c++ (Deitel and Deitel)
  int len = control.miri_dir.length();
  char *ptr1 = new char[len+1];
  control.miri_dir.copy(ptr1,len,0);
  ptr1[len] = 0;

  status = 0 ;
  fits_write_key(file_ptr, TSTRING, "MIRI_DIR", ptr1, "Default Preferences Location", &status);
  if(status !=0) cout << " Problem MIRI_DIR" << status << " " << control.miri_dir << endl;
  delete [] ptr1;


  len = data_info.preference_dir_only.length();
  char *ptr_pdir = new char[len+1];
  data_info.preference_dir_only.copy(ptr_pdir,len,0);
  ptr_pdir[len] = 0;

  status = 0 ;
  fits_write_key(file_ptr, TSTRING, "PREFDIR", ptr_pdir, "Directory Preferences", &status);
  if(status !=0) cout << " Problem writing Preferences Directory " << status << " " 
		      << data_info.preference_dir_only << endl;
  delete [] ptr_pdir;

  len = data_info.preference_filename_only.length();
  char *ptr = new char[len+1];
  data_info.preference_filename_only.copy(ptr,len,0);
  ptr[len] = 0;

  status = 0 ;
  fits_write_key(file_ptr, TSTRING, "PREFFILE", ptr, "Preferences Filename Used", &status);
  if(status !=0) cout << " Problem writing Preferences Filename " << status << " " 
		      << data_info.preference_filename_only << endl;
  delete [] ptr;


  
  len = control.calib_dir.length();
  char *ptr4 = new char[len+1];
  control.calib_dir.copy(ptr4,len,0);
  ptr4[len] = 0;

  status = 0 ;
  fits_write_key(file_ptr, TSTRING, "CALDIR", ptr4, "Calibration Directory", &status);
  if(status !=0) cout << " Problem writing calibration directory " << status << " " <<
                        control.calib_dir<< endl;
  delete [] ptr4;


  len = control.scidata_dir.length();
  char *ptr7 = new char[len+1];
  control.scidata_dir.copy(ptr7,len,0);
  ptr7[len] = 0;

  status = 0 ;
  fits_write_key(file_ptr, TSTRING, "SCIDIR", ptr7, "Science Data Directory", &status);
  if(status !=0) cout << " Problem writing Science Data directory " << status << " " <<
                        control.scidata_dir<< endl;
  delete [] ptr7;


  len = data_info.calibration_filename.length();
  char *ptr5 = new char[len+1];
  data_info.calibration_filename.copy(ptr5,len,0);
  ptr5[len] = 0;

  status = 0 ;
  fits_write_key(file_ptr, TSTRING, "D2CFILE", ptr5, "Detector to Cube File", &status);
  if(status !=0) cout << " Problem writing detector to cube filename " << status << " " <<
                        data_info.calibration_filename<< endl;
  delete [] ptr5;


  len = data_info.scale_file.length();
  char *ptr6 = new char[len+1];
  data_info.scale_file.copy(ptr6,len,0);
  ptr6[len] = 0;

  status = 0 ;
  fits_write_key(file_ptr, TSTRING, "SCFILE", ptr6, "Plate Scale & Dispersion File", &status);
  if(status !=0) cout << " Problem Plate Scale and Dispersion filename" << status << " " <<
                        data_info.scale_file<< endl;
  delete [] ptr6;

  int numfiles = data_info.input_filenames.size();
  for (int ii = 0; ii< numfiles; ii++) {
    
    len = data_info.input_filenames[ii].length();
    char *ptrA = new char[len+1];
    data_info.input_filenames[ii].copy(ptrA,len,0);
    ptrA[len] = 0;

    status = 0 ;
    fits_write_key(file_ptr, TSTRING, "FILEName", ptrA, "Science File cube Created from", &status);
    if(status !=0) cout << " Problem writing science file name cube created from " << status << " " <<
                        data_info.input_filenames[ii]<< endl;
    delete [] ptrA;
  }




  int schannel = subchannel + 1;

  fits_write_key(file_ptr,TINT,"CHANNEL",&channel," Channel # ",&status);
  fits_write_key(file_ptr,TINT,"SUBCH",&schannel," SubChannel (1=a,2=b,3=c)",&status);

  fits_write_key(file_ptr,TINT,"NSAMPLE",&NSample," NSample of data used to create cube ",&status);


  fits_write_key(file_ptr,TINT,"NTILES",&numTiles," # Tiles ",&status);
  fits_write_key(file_ptr,TINT,"INTNO",&integration_no," Cube Created from Integration No (Average = 0)",&status);
  fits_write_key(file_ptr,TDOUBLE,"CRPIX1",&crpix1," X Pixel values at CRVAL1",&status);
  fits_write_key(file_ptr,TDOUBLE,"CRPIX2",&crpix2," Y Pixel values at CRVAL2",&status);
  fits_write_key(file_ptr,TDOUBLE,"CRPIX3",&crpix3," Z Pixel values at CRVAL3",&status);

  fits_write_key(file_ptr,TDOUBLE,"CRVAL1",&crval1," Reference pt (arc seconds) at CRPIX1",&status);
  fits_write_key(file_ptr,TDOUBLE,"CRVAL2",&crval2," Reference pt (arc seconds) at CRPIX2",&status);
  fits_write_key(file_ptr,TDOUBLE,"CRVAL3",&crval3," Reference pt (microns) at CRPIX3",&status);
  
  fits_write_key(file_ptr,TDOUBLE,"CDELT1",&cdelt1," Plate Scale in X axis (arc seconds/pixel)",&status);
  fits_write_key(file_ptr,TDOUBLE,"CDELT2",&cdelt2," Plate Scale in Y axis (arc seconds/pixel)",&status);
  fits_write_key(file_ptr,TDOUBLE,"CDELT3",&cdelt3," Dispersion in Z axis (microns/pixel)",&status);


  int interpolate = control.Interpolate;
  int interpolate_distance = control.Interpolate_distance;
  fits_write_key(file_ptr,TINT,"INTERP",&interpolate," Interpolate NaN (1=yes, 0 = no)",&status);
  if(control.Interpolate ==1) 
    fits_write_key(file_ptr,TINT,"INTERPD",&interpolate_distance," Interpolate NN Pixel #",&status);
    
  if(control.bin_wave_flag ==1) {
    float wave_bin = control.bin_wave;
      fits_write_key(file_ptr,TFLOAT,"BINWAVE",&wave_bin,"Wavelength bin factor",&status);
  }

  if(control.bin_axis1_flag ==1) {
    float axis1_bin = control.bin_axis1;
      fits_write_key(file_ptr,TFLOAT,"BINAXIS1",&axis1_bin,"AXIS1 bin factor",&status);
  }


}




