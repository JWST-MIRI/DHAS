#include "miri_caler.h"

void mc_screen_info(mc_control control, mc_data_info &data_info)

{
  cout << "Processing file =               " << control.fitsbase << " " << endl;
  
  //  cout << "Calibration directory used      " << control.calib_dir << endl;
  cout << "Science input data directory    " << control.scidata_dir << endl;
  cout << "Science out data directory     " << control.scidata_out_dir << endl;


  if(control.apply_background == 1){ 
    cout << "  Subtracting a Background image" << endl;
    cout << "  Background file: " << control.background_file << endl;
  }
  if(control.apply_flat == 1){ 
    cout << "  Dividing by a Flat image" << endl;
    cout << "  Flat Calibration file: " << control.flat_file << endl;
  }

  if(control.apply_fringe_flat == 1){ 
    cout << "  Dividing by a Fringe Flat image" << endl;
    cout << "  Fringe Flat Calibration file: " << control.fringe_file << endl;
  }


  cout << "Number of Integrations         " << data_info.NInt << endl;
  cout << "Size of input data             " << data_info.red_naxes[0] << " x " <<
      data_info.red_naxes[1] << " x " <<data_info.red_naxes[2] <<endl;



}
