// include files
#ifndef PREFERENCE_H
#define PREFERENCE_H

#include <string>


// namespaces

using namespace std;

// The details of how the data were taken and how they should be processed are 
// contained in this structure.
  //  This structure holds the values in the preferences file
struct miri_preference {


  // location of files
  vector<string> key;
  vector<string> value;
  int keys_found;
  
  //  string calib_dir; // directory containing the location of the calibration files
  string scidata_dir;
  string scidata_out_dir;
  string CDP_IM_RAL1_file;
  string CDP_IM_JPL3_file;
  string CDP_LW_RAL1_file;
  string CDP_LW_JPL3_file;
  string CDP_SW_RAL1_file;
  string CDP_SW_JPL3_file;

  string jpl_run;

  string CDP_file; 
  string raw_fitsbase;  // base filename of dataset to process
  
  string preference_filename_used;

  float gain;                  // e/DN

  int UncertaintyMethod;       // method of using uncertainties for determining slope & error plane

  int n_reads_start_fit;       // frame number to start fit
  int n_frames_end_fit;        // number of frames before last frame to end fit 

  int dn_high_sat;             // "high saturation" in DN
  int apply_rscd;              // Apply RSCD correction
  int apply_reset;              // Apply Reset correction
  int apply_lastframe;         // Apply lastframe correction
  int apply_dark;              // Apply dark subtraction
  int apply_lin;               // Apply linearity Correction
  int apply_pixel_sat;         // Apply pixel saturation mask
  int apply_bad_pixel;         // Apply bad pixel mask
  int do_refpixel_option;      // Apply a correction determined from reference pixels
  int delta_refpixel_even_odd;      // number of rows to use if using reference pixels
                                    // to correct science data (slope, y-intercept option)
  float refpixel_temp_gain;
  float refpixel_temp_scale;
  float cr_sigma_reject ;           // # of sigmas above the noise for which a jump is a cr
  float slope_seg_cr_sigma_reject ; // # of sigmas above the noise for which a jump is a cr

  int max_iterations_cr;            // maximum number of iterations for cosmic ray/noise id
  int n_frames_reject_after_cr;     // number of reads to reject after a cosmic ray/noise
  int n_frames_reject_after_cr_small_frameno;     // number of reads to reject after a cosmic ray/noise 
                                                  // - if frame num<= 10
  int cr_min_good_diffs;            // minimum # of good differences in the cr/noise detection
                                    // set so a reasonable standard deviation can be determined

  float cosmic_ray_noise_level;     // cosmic ray jumps need to be above this level (DN)

  float read_noise;	            // read noise per read in electrons

  int frame_limit;    // limit on number of frames per integration for reading
                      // in full array. If number of frames is larger go into
                      // reading data in subsets
  int subset_nrow;   // number to rows to read in  when reading in subset mode 


  int write_detailed_cr;                  // output detailed information on cosmic rays
  int write_output_refpixel_corrections; // write an intermediate FITS file after the correction
                                         // for the ref output and ref border pixels (if set)
  int write_output_lc_correction; // write intermediate FITS file after linearity correction 
  int write_output_ids;           // write out the data ID for each pixel in each frame 
  int write_refoutput_slope;      // write the reference output slope
  int write_output_dark_correction;
  int write_output_rscd_correction;
  int write_output_reset_correction;
  //________________________________________________________________________________________



};

#endif
