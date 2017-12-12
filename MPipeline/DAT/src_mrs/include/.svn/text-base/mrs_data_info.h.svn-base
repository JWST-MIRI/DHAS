// include files

#ifndef DATA_INFO_H
#define DATA_INFO_H
#include <strstream>
#include <fstream>
#include <string>
#include <vector>
#include "fitsio.h"


// namespaces

using namespace std;

#define NUM_COEFF 25
#define NUM_TABLE_COLS 26
#define NUM_V2V3_COLS 5
#define NUM_V2V3_COEFF 2
#define XMIDDLE 500

// Details on input data

struct mrs_data_info {

  string preference_filename_used;
  string preference_filename_only;
  string preference_dir_only;
  vector <string> input_filenames;
  string mapping_d2c_overlap_file;
  
  int Max_Overlap_Planes;
  int Actual_Max_Overlap_Planes;

  string fitsbase;
  string calibration_file;
  string calibration_filename;
  
  string scale_file;
  fitsfile *cube_overlap_file_ptr;
  long cal_naxes[2];
  vector <string> Detector;
  vector <string> Origin;

  vector <int> WAVE_ID; // 1 = short, 2 = medium, 3 = long
  vector <int> GWA;
  vector <int> GWB;
  vector <int> Use_File;
  vector <int> NSample;
  vector <int> DGAA_POS;
  vector <int> DGAB_POS;
  int DGAA_POS_FLAG;
  int DGAB_POS_FLAG;
  int nfiles;

  float wave_min[2];
  float wave_max[2];
  float alpha_min[2];
  float alpha_max[2];
  float beta_min[2];
  float beta_delta[2];

  float v2_min[2];
  float v2_max[2];
  float v3_min[2];
  float v3_max[2];

  int slice_range_min[2][21];
  int slice_range_max[2][21];

  float beta_zero[2];
  
  float xas[2][21];
  float kalpha[2][21][NUM_COEFF];
  float xls[2][21];
  float klambda[2][21][NUM_COEFF];

  float v2coeff[2][NUM_V2V3_COEFF][NUM_V2V3_COEFF];
  float v3coeff[2][NUM_V2V3_COEFF][NUM_V2V3_COEFF];



  vector <int> slice_number;



  int SCA_CUBE;  // 0 = channel 1 & 2  1 = channel 3&4
  int WAVE_CUBE ;// 0 = channel 1 & 2  1 = channel 3&4




};

#endif
