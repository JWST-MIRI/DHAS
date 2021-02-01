// include files

#ifndef DATA_HEADER_H
#define DATA_HEADER_H
#include <strstream>
#include <fstream>
#include <string>
#include <vector>
#include "fitsio.h"

// namespaces

using namespace std;

// The details of how the data were taken and how they should be processed are 
// contained in this structure.

struct miri_data_info {

  // details of how the data was taken
  // values read in from the fits header
  
  int NSample;
  int Mode;                 // 0: Fast mult frames, 1: slow, 3: NFRAME!=1
  int NFrame;
  int NRamps;              // number of frames per integration (samples in a ramp)
  int NRampsRead;           // number of actual ramps read  in 
                           // NRamps - (skip first reads + skip end reads) 

  
  int NInt;
  int NReset;              // number of  resets 
  int ColStart;
  int RowStart;

  int JPLFixes;
  int Flag_obs_id; 
  int obs_id;
  int Flag_exp_id; 
  int exp_id;
  

  int FrameDiv;
  string Readout;
  string Detector;
  string detmode;          // checking for test patterns
  string Origin;
  string det_setting;
  int subarray_mode;       // initialize to 0
                           // -1 full array
                           // 1 subarray 

  string DGAA;
  string DGAB;
  string Band;
  string filter;

  int frame_resets;
  int row_resets;
  int rpc_delay;

  int subset_nrow;         // number of rows to read in and process
  int subset_ref_nrow;

  float FrameTime;         // read in from header 
  float GroupTime;         // read in from header 

  int Flag_FrameTime; 
  float frame_time_to_use; // 


  long numpixels;          // number of pixels in the subset;
  long ref_numpixels;      // number of reference pixels in subset


  long raw_naxes[3];        // size of input file  (ie 1032 X 1280 X n)
  long ramp_naxes[3];       // size of image that is actually processed (ie 1032 X 1024 X n)
 
  long ref_naxes[3];   // size of reference output image (ie 256 X 1024 X N)



  // input raw image as well as output files
  string input_list;         // holds the list of files to process


  int numFiles;             // number of files in numFiles
  int this_file_num;         // current file number working on 
  vector<string> filenames; // names of files in input_list  

  vector <string> raw_fitsbase;     // base filename of dataset to process
  vector <string> raw_filename;
  vector <string> red_filename;
  vector <string> red_ref_filename;
  vector <string> output_refpixel;
  vector <string> lc_filename;
  vector <string> rc_filename;
  vector <string> rscd_filename;
  vector <string> reset_filename;
  vector <string> id_filename;
  vector <string> dark_filename;

  vector <string> lastframe_filename;
  vector <string> cr_filename; // cosmic ray filename
  vector <string> sg_filename; // segment output filename

  ofstream output_rp;
  ofstream output_cr;

  fitsfile *raw_file_ptr;   // raw data FITS file
  fitsfile *lc_file_ptr;    // linearity corrected data  
  fitsfile *rc_file_ptr;    // reference pixel (and reference output)  corrected data 
  fitsfile *rscd_file_ptr;    // rscd corrected data
  fitsfile *reset_file_ptr;    // rscd corrected data
  fitsfile *id_file_ptr;
  fitsfile *dark_file_ptr;

  fitsfile *lastframe_file_ptr;
  fitsfile *sg_file_ptr;


  int refimage_exist;

  fitsfile *red_file_ptr;   // reduced data FITS file
  int red_naxis;            // number of axis in file
  long red_naxes[3];        // dimensions of axis
  int red_bitpix;           // bits per pixel (output data type)

  fitsfile *red_ref_file_ptr;   // reduced data FITS file
  int red_ref_naxis;            // number of axis in file
  long red_ref_naxes[3];        // dimensions of axis
  int red_ref_bitpix;           // bits per pixel (output data type)


  // summary values of processing


  int Max_Num_Segments;

  long total_cosmic_rays; // total number of cosmic rays
  long total_noise_spike;
  long total_cosmic_rays_neg;

  long num_cr_seg;       // # pixels segments > 1
  long num_cr_seg_neg;   // # pixels segments > 1 



};

#endif
