// include files

#ifndef MCDATA_INFO_H
#define MCDATA_INFO_H
#include <strstream>
#include <fstream>
#include <string>
#include <vector>
#include "fitsio.h"

// namespaces

using namespace std;

// The details of how the data were taken and how they should be processed are 
// contained in this structure.

struct mc_data_info {

  // details of how the data was taken
  // values read in from the fits header
  

  int GWA;
  int GWB;
  int DGAA_POS;
  int DGAB_POS;
  int DGAA_POS_FLAG;
  int DGAB_POS_FLAG;
  int FILTER;
  int NFrames;
  int NInt;

  string Detector;
  string Origin;
  int NFrames_org;
  int NInt_org;
  int ColStart;
  int RowStart;
  int NSample;
  int subarray_mode;       // initialize to 0
                           // -1 full array
                           // 1-5 indicates which subarray we are on

  long numpixels;          // number of pixels in the subset;


  // input raw image as well as output files
  string fitsbase;
  string redbase;
  string red_filename;
  string cal_filename;

  fitsfile *red_file_ptr;   // reduced data FITS file
  int red_naxis;            // number of axis in file
  long red_naxes[3];        // dimensions of axis
  int red_bitpix;           // bits per pixel (output data type)


  fitsfile *cal_file_ptr;   // Calibratedd data FITS file (dark and flat applied)
  int cal_naxis;            // number of axis in file
  long cal_naxes[3];        // dimensions of axis
  int cal_bitpix;           // bits per pixel (output data type)


  long background_naxes[2];
  long flat_naxes[2];
  long fringe_flat_naxes[2];

  vector <float> background;
  vector <float> flat;
  vector <float> fringe_flat;

};

#endif
