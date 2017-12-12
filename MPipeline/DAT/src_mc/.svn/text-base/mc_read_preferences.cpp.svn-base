#include "miri_caler.h"

void mc_read_preferences(mc_control &control,
			 mc_preference &preference)


{
  // **********************************************************************
  // read in the preferences files contains - a prior knowledge values
  //    paramter file must be in the Cal subdirectory of the 
  //    MIRI Pipeline directory
  //  
  // The control structure is used to check if the user set the name of the
  // of preferences file. Default name (hard coded below - includes version #)

//_______________________________________________________________________
  char * buffer = getenv("MIRI_DIR");
  if (buffer== NULL) {
    cout << "The environment variable MIRI_DIR is not set!" << endl;
    cout << "This variable must be set to the base directory of the" << endl;
    cout << "MIPS pipeline so it knows where various calibration files are located." << endl;
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

  string Name ("MIRI_DHAS_v9.4.preferences");

  string param_filename = control.miri_dir + "Preferences/" + Name ;


  preference.preference_filename_used = Name;
  if(control.flag_pfile ==1) {
    param_filename = control.preferences_file;
    preference.preference_filename_used = param_filename;}

  cout << "  Parameter file: " << param_filename << endl;

  // ***********************************************************************
  // read parameter file to
  // ***********************************************************************
  mc_get_param2(param_filename, preference);

// if a / does not exist at the end add one
  len = preference.scidata_dir.size();
  slash = ("/");
  test.assign(preference.scidata_dir,len-1,len);
  if( test.compare(slash) != 0 ) {
    preference.scidata_dir = preference.scidata_dir+slash;
  }

// if a / does not exist at the end add one
  len = preference.scidata_out_dir.size();
  slash = ("/");
  test.assign(preference.scidata_out_dir,len-1,len);
  if( test.compare(slash) != 0 ) {
    preference.scidata_out_dir = preference.scidata_out_dir+slash;
  }

// if a / does not exist at the end add one
  len = preference.teldata_dir.size();
  slash = ("/");
  test.assign(preference.teldata_dir,len-1,len);
  if( test.compare(slash) != 0 ) {
    preference.teldata_dir = preference.teldata_dir+slash;
  }




  // **********************************************************************
}

