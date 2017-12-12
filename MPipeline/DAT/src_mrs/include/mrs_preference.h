// include files
#ifndef PREFERENCE_H
#define PREFERENCE_H

#include <string>


// namespaces

using namespace std;

// The details of how the data were taken and how they should be processed are 
// contained in this structure.
  //  This structure holds the values in the preferences file
struct mrs_preference {

  // location of files



  string scidata_dir;
  string teldata_dir;
  string output_dir;

  string calibration_version[2];

  string cube_plate_scale_file;
  double bin_wave;
  double bin_axis1;
  
  // the following values are read in from the cube_plate_scale_file:
  double scale_axis1[4][3];
  double dispersion[4][3];


  //________________________________________________________________________________________

};

#endif
