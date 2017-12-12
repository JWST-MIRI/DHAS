// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//    ms_update_control.cpp
//
// Purpose:
//  The control structure  holds the parameters that control how the data is processed
//  The program : ms_parse_commandline.cpp parses the command line options the user has
//  used and sets to control structure to these user set values. The program ms_read_preferences.cpp
//  reads in the default processing options from the preferences file. This program
//  (ms_update_control) transfers the parameters from the preferences structure. However
//  any values set by the command line are NOT transferred. 
//
// Author:
//
//	Jane Morrison
//      University of Arizona//      email: morrison@as.arizona.edu
//      phone: 520-626-3181
// 
// Calling Sequence:
//
//void ms_update_control( miri_control &control,
//			miri_preference &preference)
//
// Arugments:
//
//  control: miri_control structure containing the processing options
//  preference: miri_preference structure containing the parameters found in the
//        preferences file. 
//
// Return Value/ Variables modified:
//      No return value.  
//  control structure updated 
//
// History:
//
//	Written by Jane Morrison 2005
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/

#include "miri_sloper.h"
#include "miri_control.h"
#include "miri_preference.h"
#include <cstdlib> // EXIT_FAILURE   , EXIT_SUCCESS

/**********************************************************************/
// update the control structure: replace preferences file values with
// command line variables

void ms_update_control( miri_control &control,
			miri_preference &preference)

{



  if(control.flag_dir ==0)
    control.scidata_dir = preference.scidata_dir;

  if(control.flag_dirout ==0)
    control.scidata_out_dir = preference.scidata_out_dir;

   if(control.flag_jpl_run ==0)
    control.jpl_run = preference.jpl_run;

  if(control.flag_gain ==0) 
    control.gain= preference.gain;

  if(control.flag_read_noise ==0) 
    control.read_noise_electrons= preference.read_noise;

  control.UncertaintyMethod = 0; // set to NoUncertainty 
  if(control.UseUncertainty ==1) control.UncertaintyMethod = 1;
  if(control.UseCorrelatedUnc ==1) control.UncertaintyMethod = 2;

  
   if(control.flag_Uncertainty ==0)
    control.UncertaintyMethod = preference.UncertaintyMethod;

  if(control.UncertaintyMethod < 0 || control.UncertaintyMethod > 2) {
    cout << " Invalid Uncertainty Method, Check the value in the prefereces files" <<  endl;
    cout << " Current Method set to " << control.UncertaintyMethod << endl;
    exit(EXIT_FAILURE);
  }


  if(control.flag_n_reads_start_fit ==0) 
    control.n_reads_start_fit = preference.n_reads_start_fit;

  if(control.flag_n_frames_end_fit ==0) 
    control.n_frames_end_fit = preference.n_frames_end_fit;

  //_______________________________________________________________________
  // also have start fit and end fit - (start counting at 0, rather than 1)
  if(control.n_reads_start_fit !=0) 
    control.n_reads_start_fit = control.n_reads_start_fit -1;
  if(control.n_reads_end_fit !=0) 
    control.n_reads_end_fit = control.n_reads_end_fit -1;

 

  //_______________________________________________________________________
  


  if(control.flag_do_refpixel_option ==0) 
    control.do_refpixel_option = preference.do_refpixel_option;


  if(control.do_refpixel_option ==0 && 
    control.write_output_refpixel_corrections ==1){ 
        control.write_output_refpixel_corrections =0;	
	control.flag_write_output_refpixel_corrections = 0;
    }
    
  if(control.flag_write_output_refpixel_corrections ==0) 
      control.write_output_refpixel_corrections = preference.write_output_refpixel_corrections;

  if( control.flag_write_output_ids == 0)
	control.write_output_ids = preference.write_output_ids;

 if( control.flag_write_detailed_cr == 0)
	control.write_detailed_cr = preference.write_detailed_cr;

	
 if( control.flag_write_output_lc_correction == 0)
	control.write_output_lc_correction = preference.write_output_lc_correction;


 if( control.flag_write_output_rscd_correction == 0)
	control.write_output_rscd_correction = preference.write_output_rscd_correction;

 if( control.flag_write_output_reset_correction == 0)
	control.write_output_reset_correction = preference.write_output_reset_correction;
      
  if(control.write_all ==1) {
	control.write_output_refpixel_corrections = 1;
	control.write_detailed_cr =1;
	control.write_output_ids = 1;
	control.write_output_lc_correction = 1;
  }

  if(control.flag_delta_refpixel_even_odd ==0) 
    control.delta_refpixel_even_odd = preference.delta_refpixel_even_odd;

  // the following are not command line options yet
  control.refpixel_temp_gain = preference.refpixel_temp_gain;
  control.refpixel_temp_scale = preference.refpixel_temp_scale;

  if(control.flag_n_frames_reject_after_cr ==0) 
    control.n_frames_reject_after_cr = preference.n_frames_reject_after_cr;
  
  control.n_frames_reject_after_cr_save = control.n_frames_reject_after_cr;

  control.n_frames_reject_after_cr_small_frameno = preference.n_frames_reject_after_cr_small_frameno;


  if(control.flag_max_iterations_cr ==0) 
    control.max_iterations_cr = preference.max_iterations_cr;
  

  if(control.flag_dn_high_sat == 0) 
    control.dn_high_sat = preference.dn_high_sat;
      
  if(control.flag_cr_sigma_reject ==0) 
    control.cr_sigma_reject = preference.cr_sigma_reject;

  if(control.flag_slope_seg_cr_sigma_reject ==0) 
    control.slope_seg_cr_sigma_reject = preference.slope_seg_cr_sigma_reject;


  if(control.flag_cr_min_good_diffs ==0) 
    control.cr_min_good_diffs = preference.cr_min_good_diffs;


  if(control.flag_cosmic_ray_noise_level ==0) 
    control.cosmic_ray_noise_level = preference.cosmic_ray_noise_level;


  if(control.flag_frame_limit ==0)
    control.frame_limit = preference.frame_limit;

  if(control.flag_apply_badpix ==0)
    control.apply_badpix = preference.apply_bad_pixel;

  if(control.flag_apply_dark_cor ==0)
    control.apply_dark_cor = preference.apply_dark;

  if(control.flag_apply_rscd_cor ==0)
    control.apply_rscd_cor = preference.apply_rscd;

  if(control.flag_apply_reset_cor ==0)
    control.apply_reset_cor = preference.apply_reset;

  if(control.flag_apply_lastframe_cor ==0)
    control.apply_lastframe_cor = preference.apply_lastframe;

  if(control.flag_apply_lin_cor ==0)
    control.apply_lin_cor = preference.apply_lin;

  if(control.flag_apply_pixel_saturation ==0)
    control.apply_pixel_saturation = preference.apply_pixel_sat;
  
  if(control.flag_subset_nrow==0)
    control.subset_nrow = preference.subset_nrow;
  int rem = control.subset_nrow%4;


  if(rem != 0 )  {
    control.subset_nrow = (control.subset_nrow/4) * 4;
    cout << " Reset the number of rows to read in and process at one time to " << control.subset_nrow << endl;
  }


  if(control.do_cr_id ==0 ) control.write_detailed_cr =0;
  if(control.apply_dark_cor ==0) control.write_output_dark_correction = 0;   		
  if(control.apply_rscd_cor ==0) control.write_output_rscd_correction = 0;   		
  if(control.apply_reset_cor ==0) control.write_output_reset_correction = 0;   		
  if(control.apply_lastframe_cor ==0) control.write_output_lastframe_correction = 0;   		
  if(control.apply_lin_cor ==0) control.write_output_lc_correction = 0;   		
  if(control.do_refpixel_option ==0)control.write_output_refpixel_corrections = 0;

  

  if(control.apply_rscd_cor ==1  && control.apply_lastframe_cor == 0 && control.rscd_lastframe_extrap == 0){
    control.rscd_lastframe_absolute =1;
    control.rscd_lastframe_corrected =0;
    control.rscd_lastframe_extrap = 0;
    cout << " Apply RSCD  and  using the uncorrected last frame in the RSCD correction" << endl;
  }

  

  
}
