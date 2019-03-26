#include <string>
#include <iostream>
#include <string>
#include <iomanip>
#include <fstream>
#include <cstdlib>
#include "miri_cube.h"
#include "mrs_control.h"
#include "mrs_preference.h"

void mrs_read_preferences(mrs_control &control,
			  mrs_preference &preference,
			  mrs_data_info &data_info)


{
  // **********************************************************************
  // read in the preferences files contains - a prior knowledge values
  //    paramter file must be in the Cal subdirectory of the 
  //    MIRI Pipeline directory
  //  
  // The control structure is used to check if the user set the name of the
  // of preferences file. Default name (hard coded below - includes version #)

//_______________________________________________________________________
// Read in enviromental varibles

 control.miri_dir = getenv("MIRI_DIR");
  if (control.miri_dir == "NULL") {
    cout << "The environment variable MIRI_DIR is not set!" << endl;
    cout << "This variable must be set to the base directory of the" << endl;
    cout << "MIPS pipeline so it knows where various calibration files are located." << endl;
    cout.flush();
    exit(EXIT_FAILURE);
  }

  int len = control.miri_dir.size();
  string slash = ("/");
  string test;
  test.assign(control.miri_dir,len-1,len);
  if( test.compare(slash) != 0 ) {
    control.miri_dir = control.miri_dir+slash;
  }

 control.calib_dir = getenv("CDP_DIR");
  if (control.miri_dir == "NULL") {
    cout << "The environment variable CDP_DIR is not set!" << endl;
    cout << "This variable must be set to the location of the c2d files" << endl;

    cout.flush();
    exit(EXIT_FAILURE);
  }

  len = control.calib_dir.size();
  string test2;
  test2.assign(control.calib_dir,len-1,len);
  if( test2.compare(slash) != 0 ) {
    control.calib_dir = control.calib_dir+slash;
  }

  cout << " Calibration directory " << control.calib_dir << endl;

//_______________________________________________________________________
  string Name ("MIRI_MRS_DHAS_v9.6.FM_preferences");

  string param_filename = control.miri_dir +"Preferences/" +  Name ;
  data_info.preference_filename_used = param_filename;
  data_info.preference_dir_only = control.miri_dir + "Preferences/";
  data_info.preference_filename_only = Name;

  if(control.flag_pfile ==1) {
    param_filename = control.preferences_file;
    data_info.preference_filename_used = param_filename;
    data_info.preference_dir_only = param_filename;
    data_info.preference_filename_only = param_filename;

    size_t dir = param_filename.find_last_of("/");
    if(dir !=string::npos){
      data_info.preference_filename_only = param_filename.substr(dir+1,param_filename.size());
      data_info.preference_dir_only = param_filename.substr(0,dir+1);
    }
  }

  
  //cout <<  data_info.preference_filename_only << endl;
  //cout <<  data_info.preference_dir_only << endl;
  //cout << " Preference Filename Only" << endl;
  //cout << "  Parameter file: " << data_info.preference_filename_used << endl;
  cout << " Reading Preference file: " <<  param_filename << endl;

  // ***********************************************************************
  // read parameter file to
  // ***********************************************************************
  mrs_get_param(param_filename, preference);

  //_______________________________________________________________________

 // if a / does not exist at the end add one
  len = preference.scidata_dir.size();
  slash = ("/");
  test.assign(preference.scidata_dir,len-1,len);
  if( test.compare(slash) != 0 ) {
    preference.scidata_dir = preference.scidata_dir+slash;
  }


  len = preference.output_dir.size();
  slash = ("/");
  test.assign(preference.output_dir,len-1,len);
  if( test.compare(slash) != 0 ) {
    preference.output_dir = preference.output_dir+slash;
  }

  // **********************************************************************
}

