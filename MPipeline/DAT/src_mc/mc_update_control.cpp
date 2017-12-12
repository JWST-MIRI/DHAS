#include <iostream>
#include "miri_caler.h"
#include "mc_control.h"
#include "mc_preference.h"

#include <cstdlib> // EXIT_FAILURE   , EXIT_SUCCESS

/**********************************************************************/
// update the control structure: replace preferences file values with
// command line varibles

void mc_update_control( mc_control &control,
			mc_preference &preference)

{



  //if(control.flag_dircal ==0) control.calib_dir = preference.calib_dir;

  // LVL2 images are written to the scidata_out_dir by miri_sloper
  if(control.flag_dirsci ==0)control.scidata_dir = preference.scidata_out_dir;
  if(control.flag_dirout ==0)control.scidata_out_dir = preference.scidata_out_dir;
  if(control.flag_dirtel ==0)control.teldata_dir = preference.teldata_dir;


  if(control.apply_flat ==0  &&  control.apply_background ==0 && control.apply_fringe_flat == 0) {
    cout << " Not applying a background file, flat calibration file or fringe flat calibration file" << endl;
    cout << " Run again and use the +b, +f, or +r  option " << endl;
    exit(EXIT_FAILURE);
    
  }

  if(control.apply_flat==1 && control.flag_flat_file ==0 ) {
    cout << " You did not specify the Flat file "<< endl;
    cout << " Run again and supply flat calibration file using -ff full filename (including directory)" << endl;
    exit(EXIT_FAILURE);
  }

  if(control.apply_background==1 && control.flag_background_file ==0 ) {
    cout << " You did not specify the background file "<< endl;
    cout << " Run again and supply background, calibration file using -df full filename (including directory)" << endl;
    exit(EXIT_FAILURE);
  }

  if(control.apply_fringe_flat==1 && control.flag_fringe_file ==0 ) {
    cout << " You did not specify the Fringe Flat file "<< endl;
    cout << " Run again and supply fringe flag calibration file using -rf full filename (including directory)" << endl;
    exit(EXIT_FAILURE);
  }
  
}
