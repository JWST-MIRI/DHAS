// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.
//
// Name:
//    ms_read_preferences.cpp
//
// Purpose:
//     The default parameters on how to process the data and the default directories to
//     read and write data are found in the preferences file. The preference file
//     has a name that includes the version of the DHAS. For example the preferences
//     file for DHAS version 3.9 is MIRI_DHAS_v3.9.preferences.The preferences file is 
//     located in directory defined by the the environment variable: "MIRI_DIR".
//     After reading in the preferences file the program ms_update_control.cpp is called
//     to update the control structure with the parameters read in from the 
//     preferences file.
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
//void ms_read_preferences(miri_control &control,
//			 miri_preference &preference)
//
// Arugments:
//
//  control: miri_control structure containing the processing options
//  preference: miri_preference structure containing the parameters found in the
//        preferences file. 
//
//
// Return Value/ Variables modified:
//      No return value.  
//      Preference structure updated
//
// History:
//
//	Written by Jane Morrison 2005
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/
#include "miri_sloper.h"

void ms_read_preferences(miri_control &control,
			 miri_preference &preference)


{
  // **********************************************************************
  // read in the preferences files contains - a prior knowledge values
  //    parameter file must be in the Cal sub directory of the 
  //    MIRI Pipeline directory
  //  
  // The control structure is used to check if the user set the name of the
  // of preferences file. Default name (hard coded below - includes version #)

//_______________________________________________________________________
// Read in the environmental variables: MIRI_DIR and CDP_DIR

 char * buffer = getenv("MIRI_DIR");
  if (buffer== NULL) {
    cout << "The environment variable MIRI_DIR is not set!" << endl;
    cout << "This variable must be set to the base directory of the" << endl;
    cout << "MIRI pipeline so it knows where preferences files are located." << endl;
    cout.flush();
    exit(EXIT_FAILURE);
  }
  control.miri_dir = buffer;
  int len = control.miri_dir.size();
  string slash = ("/");
  string test;
  test.assign(control.miri_dir,len-1,len);
  if( test.compare(slash) != 0 ) {
    control.miri_dir = control.miri_dir+slash;
  }

 char * buffer2 = getenv("CDP_DIR");
  if (buffer== NULL) {
    cout << "The environment variable CDP_DIR is not set!" << endl;
    cout << "This variable must be set to the location of the Calibration Reference Files" << endl;
    cout.flush();
    exit(EXIT_FAILURE);
  }
  control.calib_dir = buffer2;
  len = control.calib_dir.size();
  string test2;
  test2.assign(control.calib_dir,len-1,len);
  if( test2.compare(slash) != 0 ) {
    control.calib_dir = control.calib_dir+slash;
  }
  cout << " Calibration directory: " << control.calib_dir << endl;

//_______________________________________________________________________
  string Name ("MIRI_DHAS_v9.6.preferences");
  string param_filename = control.miri_dir + "Preferences/" + Name ;

  preference.preference_filename_used = Name;
  if(control.flag_pfile ==1) {
    param_filename = control.preferences_file;
    preference.preference_filename_used = param_filename;}

  cout << " Parameter file: " << param_filename << endl;

  // ***********************************************************************
  // read parameter file to
  // ***********************************************************************
  int status = 0;
  status =  ms_get_param2(param_filename, preference);
  if(status !=0) {
    cout << " Failure in reading Parameters from Preferences file " << endl;
    cout << " Error in format of preference file or missing important keys " << endl;
  }


  // if a / does not exist at the end add one
  len = preference.scidata_dir.size();
  slash = ("/");
  test.assign(preference.scidata_dir,len-1,len);
  if( test.compare(slash) != 0 ) {
    preference.scidata_dir = preference.scidata_dir+slash;
  }


  //cout << " Location of science data: " << preference.scidata_dir << endl;


  // if a / does not exist at the end add one
  len = preference.scidata_out_dir.size();
  slash = ("/");
  test.assign(preference.scidata_out_dir,len-1,len);
  if( test.compare(slash) != 0 ) {
    preference.scidata_out_dir = preference.scidata_out_dir+slash;
  }


  //cout << " Location of directory to put output science data: " << preference.scidata_out_dir << endl;
  
  // **********************************************************************
}

