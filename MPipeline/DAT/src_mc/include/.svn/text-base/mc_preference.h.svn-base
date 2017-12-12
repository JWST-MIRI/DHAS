// include files
#ifndef MCPREFERENCE_H
#define MCPREFERENCE_H
#include <vector>
#include <string>


// namespaces

using namespace std;

// The details of how the data were taken and how they should be processed are 
// contained in this structure.
  //  This structure holds the values in the preferences file
struct mc_preference {

  vector<string> key;
  vector<string> value;
  int keys_found;
  // location of files

  //string calib_dir; // directory containing the location of the calibration files- User now provides that
  // with the calibration name

  string scidata_dir; // location of science files
  string scidata_out_dir; // location of output LVL3 science files
  string teldata_dir; // location of telemetry data file - we need the ICE files
  string fitsbase;  // base filename of dataset to process
  string preference_filename_used;

  //________________________________________________________________________________________



};

#endif
