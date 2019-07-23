// include files
#ifndef CONTROL_H
#define CONTROL_H

#include <string>
#include <vector>

// namespaces

using namespace std;

// The details of how the data were taken and how they should be processed are 
// contained in this structure.
  // command line inputs and parameter file inputs
struct miri_control {

  //________________________________________________________________________________________
  // environmental variable 
  string  miri_dir;      // base directory of the DHAS
  string raw_fitsbase;  // base filename of dataset to process

  vector<int>  ignore_int;
  int num_ignore;
  //________________________________________________________________________________________
  // command line option switches - actions to be takens

  int flag_CDP_file;
  string CDP_file;

  int QuickMethod;

  int UseUncertainty;
  int UseCorrelatedUnc;
  int NoUncertainty;
  int flag_Uncertainty;
  int UncertaintyMethod; 

  int flag_jpl_run;
  string jpl_run;

  int jpl_detector_flag;  //  flag for Run 8 detector name 
  string jpl_detector;  // value for Run 8 detector name (101 or 106)

  // Options dealing with reference pixels

  int do_refpixel_option;   
                            // 6. subtract frame 1, then determine mean value (based on channel and even/odd)
                            // 7. Determination of temperature factor
  


  int do_refpixel_options[2]; // a flag that sets which option to do
  int flag_do_refpixel_option; 

  float refpixel_sigma_clip;
  int refpixel_filter_size;

  int delta_refpixel_even_odd; // the number of rows to using in finding the correction
                               // for do_refpixel_option2, but only using even or odd rows based
                               // on row in question
  int flag_delta_refpixel_even_odd;  // delta_refpixel set by command line

  float refpixel_temp_gain; // read in from preferences file
  float refpixel_temp_scale; // read in from preferences file


  int apply_badpix;            //  remove  bad pixels
  int apply_pixel_saturation;  //  use pixel saturation mask
  int apply_lin_cor;           // apply linearity correctionn
  int apply_dark_cor;          // apply dark correection
  int apply_rscd_cor;          // apply RSCD correction
  int apply_mult_cor;          // apply multiple integration (secondard)  correction
  int apply_reset_cor;         // apply reset anomaly correction
  int rscd_lastframe_corrected; // use corrected last frame for rscd correction
  int rscd_lastframe_extrap;    // use extrapolated last frame for rscd correction
  int apply_lastframe_cor;         // apply lastframe correction 
  int subtract_dark; // = apply_dark_cor but can be turned off if input data nframes > dark nframes
                     // made this a seperate varible if running miri sloper from a list of file and
                     // turning off apply_dark_cor would affect the other files to be processed in the list
  int flag_apply_badpix;
  int flag_apply_lin_cor;
  int flag_apply_pixel_saturation;
  int flag_apply_dark_cor;
  int flag_apply_rscd_cor;
  int flag_apply_mult_cor;
  int flag_apply_reset_cor;
  int flag_apply_lastframe_cor;


  int rscd_int1_frame_a;
  int rscd_int1_frame_z;
  int rscd_int1_scale; 
  int do_cr_id;             // do cosmic ray identification

  int do_verbose;           // output various status messages during reduction
  int do_verbose_jump;     // out more information on Jumps on ramp found- cr or noise
  int do_verbose_time;      // output time required to do different steps
  int do_diagnostic; 

  string output_name;       // output prefix name to use instead of default on 
  int flag_output_name;

    //________________________________________________________________________________________
  // variables read in from the preferences file that can be replaced by the command line


  int frame_limit;         // limit on number of frames per integration for reading
                           // in full array. If number of frames is larger go into
                           // reading data in subsets
  int flag_frame_limit;    // frame_limit value set by command line

  int subset_nrow;         // number of rows to read in and process - if
                           // in subset mode

  int flag_subset_nrow;

  string calib_dir;        // directory for the location of the calibration files
  int flag_dircal;

  string scidata_dir;      // directory location for the science files to reduce
  int flag_dir;

  string scidata_out_dir;      // directory location for output LVL2 files to be written
  int flag_dirout;

  string preferences_file; // user provided preferences file name
  int flag_pfile;

  float gain;              // gain to use instead of the one in the preferences file
  int flag_gain;           // only used if converting from dn/s to e/s

  float frametime;
  int flag_frametime;

  int convert_to_electrons_per_second; // convert output from dn/s to e/s


  int write_detailed_cr;       // output detailed information on cosmic rays
  int flag_write_detailed_cr;

  int write_segment_output;    // output the segment info for each ramp

  int write_output_refpixel; // write the reference pixel correction file
  int write_output_refslope; // write the reduced reference image file
  int flag_write_output_refslope; 

  int write_output_refpixel_corrections; // write an intermediate FITS file after the correction
                                         // for the reference output and reference border pixels (if set)
  int flag_write_output_refpixel_corrections ;	

  int write_all;

  int write_output_lc_correction; // write intermediate FITS file after linearity correction 
  int flag_write_output_lc_correction;

  int write_output_dark_correction; // write intermediate FITS file after dark correction 
  int flag_write_output_dark_correction;

  int write_output_rscd_correction; // write intermediate FITS file after rscd correction 
  int flag_write_output_rscd_correction;

  int write_output_reset_correction; // write intermediate FITS file after reset anomlay correction 
  int flag_write_output_reset_correction;

  int write_output_lastframe_correction; // write intermediate FITS file after last frame correction 
  int flag_write_output_lastframe_correction;

  int write_output_ids;  // write out the data ID for each pixel in each frame 
  int flag_write_output_ids ;

  string badpix_file;                 // filename of bad pixel list using for this data
  int flag_badpix_file;               // if not set on command line use preference value

  string pixel_saturation_file;      // pixel saturation file to use for this data set
  int flag_pixel_saturation_file;    //  if not set on command line use preference value

  string lin_cor_file;          // linearity correction filename
  int flag_lin_cor_file;
  int apply_lin_offset; 

  string dark_cor_file;          // dark filename
  int flag_dark_cor_file; 

  string lastframe_file;          // lastframe filename
  int flag_lastframe_file;

  string rscd_cor_file;
  int flag_rscd_cor_file;

  string mult_cor_file;
  int flag_mult_cor_file;

  string reset_cor_file;
  int flag_reset_cor_file;

  int n_reads_start_fit;           // frame number to start slope fit
  int flag_n_reads_start_fit;      // if not set on command line use preference value

  int n_reads_end_fit;             // frame number to end slope fit
  int flag_n_reads_end_fit;        // if not set on command line use preference value

  int n_frames_end_fit;             // end the fit on number of frames - this value
  int flag_n_frames_end_fit;        // if not set on command line use preference value

  int n_frames_reject_after_cr;     // number of reads to reject after a cosmic ray
  int flag_n_frames_reject_after_cr; // if not set on command line use preference value
  int n_frames_reject_after_cr_save;     // number of reads to reject after a cosmic ray
  int n_frames_reject_after_cr_small_frameno;   // number of reads to reject after a cosmic ray  
  float cosmic_ray_noise_level;      // jumps flagged as cr must be above this level
  int flag_cosmic_ray_noise_level;
  

  float dn_high_sat;                 // "high saturation" in DN
  int flag_dn_high_sat;            // if not set on command line use preference value

  float cr_sigma_reject ;          // # of sigmas above the noise for which a jump is a cosmic ray/noise
  int  flag_cr_sigma_reject ;     // if not set on command line use preference value

  int max_iterations_cr;       // maximum # iterations for cosmic ray/noise id
  int flag_max_iterations_cr; // if not set on command line use preference value    

  float slope_seg_cr_sigma_reject ;          // # of sigmas above the noise for which a jump is a cosmic ray
  int  flag_slope_seg_cr_sigma_reject ;          // # of sigmas above the noise for which a jump is a cosmic ray

  int cr_min_good_diffs;           // minimum # of good differences in the cosmic ray detection
  int flag_cr_min_good_diffs;      // if not set on command line use preference value
                                   // set so a reasonable standard deviation can be determined
  float read_noise_electrons;	   // read noise per read in electrons
  int  flag_read_noise;   // if not set on command line use preference value

  int xdebug;
  int ydebug;
  int debug_flag;
  int ScreenFrames;

  //________________________________________________________________________________________

  // fastmode adjustments: options changed for Fast Short, but if running over a list of
  // files - need to store values and put back the original values
  

  int do_cr_id_FS;             // do cosmic ray identification
  int do_diagnostic_FS;             // do 2pt differences
  int apply_lin_cor_FS;           // apply linearity correction
  int write_output_refslope_FS; // write the reduced reference image file
  int write_output_lc_correction_FS; // write intermediate FITS file after linearity correction 
  int apply_dark_FS;
  int write_output_dark_FS;


  // if running over a list of files and subarray data is on the list (subarray turns off ref pixel correction)
  int do_refpixel_option_SA;
  int apply_rscd_cor_Input;
  int apply_mult_cor_Input;
  int write_output_rscd_correction_Input;

  


};

#endif
