// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//    ms_initialize_control.cpp
//
// Purpose:
// 	Initialize the control structure. This structure holds the parameters
//      that control how the data is processed. 
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
//void ms_initialize_control(miri_control &control)
//
// Arguments:
//
//  control: miri_control structure containing the processing options
//
//
// Return Value/ Variables modified:
//      No return value.  
//      control structure basically set to zero (or empty string)
//
// History:
//
//	Written by Jane Morrison January 2004
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/


#include "miri_control.h"
// Initialize the structure control

void ms_initialize_control(miri_control &control)

{
  // **********************************************************************

  // setup the defaults for command line parameters
  // true  = 1
  // false = 0

  control.QuickMethod = 0;
  control.raw_fitsbase = "";
  control.output_name = "";

  control.flag_CDP_file = 0; 

  control.flag_jpl_run = 0;
  control.jpl_run = '0';

  control.jpl_detector_flag = 0;
  control.jpl_detector = '0';


  control.frame_limit = 20; // 20 might be a good start 
  control.subset_nrow = 256; // 

  control.UseUncertainty = 0;
  control.NoUncertainty = 0;
  control.UseCorrelatedUnc = 0;
  control.flag_Uncertainty = 0;
  control.UncertaintyMethod = 0;


  control.num_ignore = 0;
  control.do_refpixel_option = 0;
  control.flag_do_refpixel_option = 0;
  control.do_refpixel_options[0] = 0;
  control.do_refpixel_options[1]= 0;


  control.do_refpixel_option_SA = 0;
  control.refpixel_sigma_clip = 3.0;
  control.refpixel_filter_size = 128;  // 1024, 512, 256, 128, 64, 32 possible options

  
  control.make_log = 0;


  control.delta_refpixel_even_odd = 0;
  control.flag_delta_refpixel_even_odd = 0;


  control.apply_badpix = 0;               // +/- b use (not use) bad pixel list
  control.apply_pixel_saturation = 0;     // +/- s use (not use) pixel saturation list
  control.apply_lin_cor = 0;              // +/- L do (not do) electronic non linearity correction
  control.apply_dark_cor = 0;             // +/- D do (not do) dark correction
  control.subtract_dark = 0;

  control.apply_lastframe_cor = 0;        // +/- l do (not do) last frame correction
  control.apply_rscd_cor = 0;             // +/- rd do (not do) RSCD correction
  control.apply_mult_cor = 0;             // +/- m do (not do) multi integration correction
  control.apply_reset_cor = 0;            //  +/- r do( do not) apply reset anomaly correction
  control.rscd_lastframe_corrected = 0;
  control.rscd_lastframe_extrap = 1;


  control.flag_apply_badpix = 0;
  control.flag_apply_lin_cor = 0;
  control.flag_apply_dark_cor = 0;
  control.flag_apply_pixel_saturation = 0;
  control.flag_apply_lastframe_cor = 0;
  control.flag_apply_rscd_cor = 0; 
  control.flag_apply_mult_cor = 0; 
  control.flag_apply_reset_cor = 0;


  control.do_cr_id = 0;                 // +/- c do (not do) the cosmic ray identification

  control.do_verbose = 0;               // -v output very detailed information to the screen
  control.do_verbose_time = 0;           // - output timing information
  control.do_diagnostic = 0;            // -d write diagnostic planes to slope FITS file
  control.convert_to_electrons_per_second = 0;



  // setup the defaults for parameter file values
  control.calib_dir = "";             // directory for calibration files - stores in preferences file
  control.scidata_dir = "";         // directory for location of input science files
  control.scidata_out_dir = "";         // directory for location of output science files
  control.preferences_file="";

  control.write_all = 0;
  control.write_output_refpixel = 0;
  control.write_output_refslope = 0; // 
  control.flag_write_output_refslope = 0; // 
  control.write_output_refpixel_corrections = 0;
  control.flag_write_output_refpixel_corrections = 0;
  control.write_output_lc_correction = 0;
  control.flag_write_output_lc_correction = 0;

  control.write_output_dark_correction = 0;
  control.flag_write_output_dark_correction = 0;

  control.write_output_rscd_correction = 0;
  control.flag_write_output_rscd_correction = 0;

  control.write_output_reset_correction = 0;
  control.flag_write_output_reset_correction = 0;


  control.write_output_lastframe_correction = 0;
  control.flag_write_output_lastframe_correction = 0;

  control.write_output_ids = 0;
  control.flag_write_output_ids = 0;
  control.write_detailed_cr = 0;
  control.flag_write_detailed_cr = 0;
  control.write_segment_output = 0;
  control.write_all = 0;

  control.flag_dircal = 0;
  control.flag_dir = 0;
  control.flag_dirout = 0;
  control.flag_pfile = 0;
  control.flag_frame_limit=0;
  control.flag_subset_nrow=0;

  control.do_noise_spike_id = 0;
  control.n_reads_start_fit = 0;
  control.n_reads_end_fit = 0;
  control.n_frames_end_fit = 0;
  control.n_frames_reject_after_cr = 0;
  control.n_frames_reject_after_cr_save = 0;
  control.n_frames_reject_after_cr_small_frameno = 0;
  control.dn_high_sat = 0;
  control.cr_sigma_reject = 5.0;
  control.max_iterations_cr  = 20;
  control.slope_seg_cr_sigma_reject = 10.0;
  control.cosmic_ray_noise_level = 0.0;
  control.flag_cosmic_ray_noise_level = 0; 

  control.read_noise_electrons= 0;	// read noise per read in electrons
  control.badpix_file = "";
  control.gain = 1;      //e/DN
 
  control.frametime = 1;  //seconds;

  control.do_Pulse_Mode = 0;
  control.Pulse_Frame_i = 0;
  control.Pulse_Frame_f = 0;
  control.flag_Pulse_Frame_f = 0;

  
  control.flag_output_name = 0;
  control.flag_badpix_file=0;
  control.flag_pixel_saturation_file=0;
  control.flag_lin_cor_file=0;              
  control.flag_lastframe_file=0;              
  control.flag_dark_cor_file=0;     
  control.flag_rscd_cor_file  = 0;
  control.flag_mult_cor_file  = 0;
  control.flag_reset_cor_file  = 0;

  control.apply_lin_offset = 1; // apply correction for DN at time 0, so we can overplot linearity corrected data
  control.flag_n_reads_start_fit=0;        
  control.flag_n_reads_end_fit=0;        
  control.flag_n_frames_end_fit=0;        
  control.flag_n_frames_reject_after_cr=0;     
  control.flag_dn_high_sat=0;
  control.flag_cr_sigma_reject=0 ; 
  control.flag_max_iterations_cr=0 ; 
  control.flag_slope_seg_cr_sigma_reject=0 ; 
  control.flag_cr_min_good_diffs=0;
  control.flag_read_noise=0;


  control.flag_gain = 0;
  control.flag_frametime = 0;

  control.xdebug = 0;
  control.ydebug = 0;
  control.ScreenFrames = 1;

//_______________________________________________________________________

}

