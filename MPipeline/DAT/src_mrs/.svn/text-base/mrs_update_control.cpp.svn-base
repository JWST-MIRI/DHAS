#include <iostream>
#include <string>
#include <iomanip>
#include <fstream>
#include <cstdlib>
#include <string>
#include "mrs_control.h"
#include "mrs_preference.h"

#include <cstdlib> // EXIT_FAILURE   , EXIT_SUCCESS

/**********************************************************************/
// update the control structure: replace preferences file values with
// command line varibles

void mrs_update_control( mrs_control &control,
			 mrs_preference &preference)

{


  if(control.flag_dirsci ==0)
    control.scidata_dir = preference.scidata_dir;

  if(control.flag_dirtel ==0)
    control.teldata_dir = preference.teldata_dir;


  if(control.flag_dirout ==0)
    control.output_dir = preference.output_dir;


  if(control.bin_wave_flag ==0) 
    control.bin_wave = preference.bin_wave;

  if(control.bin_axis1_flag ==0) 
    control.bin_axis1 = preference.bin_axis1;

  if(control.write_mapping){
    if(control.numSlicesNTile !=1){
      cout << " The program is writing a mapping overlap file so each slice " << " has to be processed seperately. " << endl;
      cout << " Changing number of slices to read in and process  = 1" << endl;
    }
    control.numSlicesNTile = 1;
  }


}
