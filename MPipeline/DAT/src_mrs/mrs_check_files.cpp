// mrs_read_input_list.cpp
#include <dirent.h>
#include <sys/stat.h> 
#include <iostream>
#include <string>
#include <iomanip>
#include <fstream>
#include <math.h>
#include <cstdlib>
#include "fitsio.h"
#include "miri_constants.h"
#include "mrs_constants.h"
#include "mrs_data_info.h"

/**********************************************************************/
// Description of program:

/**********************************************************************/
// Read in list of input image filenames

int mrs_check_files(mrs_data_info &data_info)
  
{

  int status = 0;
  int WAVE_TYPE = data_info.WAVE_ID[0]; // set WAVE_TYPE to type of   
  int NSample = data_info.NSample[0];

  string detector = data_info.Detector[0];
  if(detector == IM || detector == MIRIIM) {
    cout << " You are trying to build a cube with Imager data - NOT ALLOWED" << endl;
    cout << " Run again" << endl;
    status = 1;
    return status;
  }


  string origin = data_info.Origin[0];
  if(origin == "JPL") {
    cout << " You are trying to build a cube with JPL - NOT ALLOWED" << endl;
    cout << " Run again" << endl;
    status = 1;
    return status;
  }
  //***********************************************************************

  for ( int i = 1 ; i < data_info.nfiles; i++){

    if(WAVE_TYPE != data_info.WAVE_ID[i]) {
      status = 1;
      cout << " The input files cover different Wavelength ranges " << endl;
      cout << " Cube_Build only works over the same wavelength range " << endl;
      cout << " Run again " << endl;
    }


    if(NSample != data_info.NSample[i]) {
      status = 1;
      cout << " The input files cover files with different NSample values " << endl;
      cout << " Cube_Build only works over NSample  " << endl;
      cout << " Run again " << endl;
    }


    if(data_info.Detector[i] == IM || data_info.Detector[i] == MIRIIM) {
      cout << " You are trying to build a cube with Imager data - NOT ALLOWED" << endl;
      cout << " Run again" << endl;
      status = 1;
    }

    if(data_info.Origin[i] == "JPL") {
      cout << " You are trying to build a cube with JPL data - NOT ALLOWED" << endl;
      cout << " Run again" << endl;
      status = 1;
    }


    if(detector != data_info.Detector[i] ) {
      cout << " You are trying to build a cube with files from different detectors." << endl;
      cout << " Run again and only use data from the same detector " << endl;
    }
	
  }

  // set which channels working with
  
  // SCA_SW or SCA_SW_B = mrs channel 12 (SCA_12 = 0)
  // SCA_LW or SCA_LW_B = mrs channel 34 (SCA_34 = 1)
  // Detector == LW or MIRILW  mrs channel 34
  // Detector == SW or MIRISW mrs_channel 12
  data_info.SCA_CUBE = -1; 
  if(status ==0) {
    if(data_info.Detector[0] == SW || data_info.Detector[0] == MIRISW) data_info.SCA_CUBE = SCA_12;
    if(data_info.Detector[0] == LW || data_info.Detector[0] == MIRILW) data_info.SCA_CUBE = SCA_34;
    if(data_info.SCA_CUBE == -1) {
      cout << " Could not determine the channels (1/2) or (3/4) from the files" << endl;
      status = 1;
    }
  }    

  data_info.WAVE_CUBE = -1;// (WAVE_ID, Subchannel A(0), Subchannel B (1), subchannel C(2)
  if(status == 0) {
    data_info.WAVE_CUBE = data_info.WAVE_ID[0];
  }



  return status;
}

