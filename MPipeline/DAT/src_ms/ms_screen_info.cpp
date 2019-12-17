// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//      ms_screen_info.cpp   
//   
// Purpose:
// Search for corrupt frames. Corrupt frames occur when pixels 512 pixels from each other
// have the same value. A quick check for corrupt frames is to read in the first row
// for all the frames. If on a frame there are at least 10 cases where pixels seperated by
// 512 pixels have the same value then the frame is marked as corrupt.  
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
//void ms_screen_info(miri_control control, miri_data_info &data_info)
//
//
// Arugments:
//
//  control: miri_control structure containing the processing options
//  data_info: miri_data_info structure containing basic information on the dataset
//
//
// Return Value/ Variables modified:
//      No return value.  
// 
//
// History:
//

//	Written by Jane Morrison 2006
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/


#include "miri_sloper.h"

// Write to the screen the processing options that are being used:

void ms_screen_info(miri_control control, miri_data_info &data_info)

{

  int II = data_info.this_file_num;

  cout << "Processing file =               " << data_info.raw_fitsbase[II] << " " << endl;
  
  cout << "Calibration directory used      " << control.calib_dir << endl;
  cout << "Science input data directory   " << control.scidata_dir << endl;
  cout << "Science output data directory  " << control.scidata_out_dir << endl;

  
  if(control.write_output_refslope == 1)
    cout << " Writing output reference image slope to " << data_info.red_ref_filename[II] << endl;
  if(control.write_output_refpixel_corrections) 
    cout << " Writing reference pixel corrected data " << data_info.rc_filename[II] << endl; 
  if(control.do_diagnostic) cout << " Writing 4 additional planes to LVL2 file (2pt difference information)" << endl;

  if(control.write_output_lc_correction == 1) 
    cout << " Writing linear corrected data " << data_info.lc_filename[II] << endl;;

  if(control.write_output_dark_correction == 1) 
    cout << " Writing  Dark  corrected data " << data_info.dark_filename[II] << endl;;

  if(control.write_output_rscd_correction == 1) 
    cout << " Writing RSCD corrected data " << data_info.rscd_filename[II] << endl;;

  if(control.write_output_reset_correction == 1) 
    cout << " Writing Reset corrected data " << data_info.reset_filename[II] << endl;;

  if(control.write_output_lastframe_correction == 1) 
    cout << " Writing LastFrame corrected data " << data_info.lastframe_filename[II] << endl;;

  if(control.write_output_ids == 1) 
	cout << " Writing pixel ID FITS file " << data_info.id_filename[II] << endl;

  if(control.write_detailed_cr == 1)
    cout << " Writing details of the cosmic ray detection " << data_info.cr_filename[II] << endl;
  
  cout << "Processing options " << endl;
    
  
  if(control.do_refpixel_option ==0) cout << " Not using border reference pixels to correct data " << endl; 

  if(control.do_refpixel_option ==6) {
    cout << " Using reference pixels to correct science data (Correction: mean [even/odd rows] /channel after subtracting corresponding reference pixels in frame 1, 8 values/frame)" << endl; 
  }

  if(control.do_refpixel_option ==7) {
    cout << " Using reference pixels to correct science data. Removing Temperature dependence from reference pixels" << endl;
  }

  if (control.apply_badpix==1){
    cout << " Removing Bad Pixels using the Bad Pixel File" << endl;
    cout << " Bad pixel file: " << control.badpix_file << endl;
  }

  if(control.apply_pixel_saturation ==1 ){
    cout << " Using the pixel saturation mask to mark saturated pixels " << control.pixel_saturation_file << endl;
  }

  if (control.apply_reset_cor==1)cout << " Applying Reset  correction" << endl;

  if (control.apply_lin_cor==1){
    cout << " Applying linearity correction" << endl;
    cout << " Linearity Correction file: " << control.lin_cor_file << endl;
  }

  if (control.subtract_dark==1)cout << " Applying Mean Dark correction" << endl;

  if (control.apply_mult_cor==1)cout << " Applying multiple integration correction" << endl;
  if (control.apply_rscd_cor==1){
    cout << " Applying RSCD  correction" << endl;
    if(control.rscd_lastframe_corrected ==1) cout << " RSCD correction uses the corrected last frame " << endl;
    if(control.rscd_lastframe_extrap ==1) cout << " RSCD correction extrapolates to find last(first) frame " << endl;
    //cout << " RSCD frame a to use in estimating frame 1 for RSCD 1st int " << control.rscd_int1_frame_a  << endl;
    //cout << " RSCD frame z to use in estimating frame 1 for RSCD 1st int " << control.rscd_int1_frame_z  << endl;
  }

  if (control.apply_lastframe_cor==1)cout << " Applying Lastframe  correction" << endl;

  cout << " Frame number to start slope fit: " << control.n_reads_start_fit+1 << endl;
  cout << " Frame number to end slope fit:   " << control.n_reads_end_fit+1 << endl;
  cout << " Hi dn saturation:            " <<control.dn_high_sat << endl;

  if(control.flag_video_offset ==1) cout <<" Video offset to add to data (in DN) = " << control.video_offset << endl;
  if(control.flag_gain ==1) cout <<" The gain (in electrons/DN) = " << control.gain << endl;
  if(control.flag_read_noise ==1) cout << " The read noise (in electrons) = " << control.read_noise_electrons << endl;
  if(control.UncertaintyMethod == 0)cout<<" The slope is determined by setting uncertainty in the measurements =1 "<<endl;
  if(control.UncertaintyMethod == 1)cout<<" The slope is determined by using the uncertainty in the measurements"<<endl;
  if(control.UncertaintyMethod == 2 )cout<<" The slope is determined by using the uncertainty in the measurements and the uncertainty of the slope is determined from correlated measurements"<<endl;

  cout << " Number of Integrations         " << data_info.NInt << endl;
  cout << " Number of frames/int           " << data_info.NRamps << endl;
  
  cout << " Size of input data             " << data_info.raw_naxes[0] << " x " <<
    data_info.raw_naxes[1] << " x " <<data_info.raw_naxes[2] <<endl;
  cout << " Size of science image          " << data_info.ramp_naxes[0] << " x " <<
      data_info.ramp_naxes[1] << " x " <<data_info.ramp_naxes[2] <<endl;

  if(data_info.refimage_exist== 0) 
    cout << " Reference image does not exist " << endl;
  if(data_info.refimage_exist == 1) {
    cout << " Reference image exist " << endl;
    cout << " Size of reference image        " << data_info.ref_naxes[0] << " x " <<
      data_info.ref_naxes[1] << " x " 
	 <<data_info.ref_naxes[2] <<endl;
  }
  

  if(control.do_cr_id)  {
    cout << " Doing Identification of large jumps in data (possible cosmic rays) " << endl;
    cout << " cosmic ray sigma reject:          " << control.cr_sigma_reject << endl;
    cout << " cosmic ray min # differences needed:  " << control.cr_min_good_diffs << endl;
    cout << " # of frames to reject after a cosmic ray detection " << control.n_frames_reject_after_cr << endl;
    cout << " Minimun DN noise level limit, above limit jump could flag as cosmic ray " << control.cosmic_ray_noise_level << endl;
  }

}


