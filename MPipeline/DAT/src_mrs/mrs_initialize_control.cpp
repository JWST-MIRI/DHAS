#include "mrs_control.h"

void mrs_initialize_control(mrs_control &control)

{
  // **********************************************************************
  // create the parameter filename string and read in various user defined inputs
  //   paramter file must be in the Cal subdirectory of the MIPS Pipeline directory

  // setup the defaults for command line parameters
  // true  = 1
  // false = 0
  
  //control.fitsbase = "";
  control.input_list = "";
  control.OverWrite = false;
  control.output_name = "Spectral_Cube";
  control.numSlicesNTile = 0;


  control.flag_subchannel  = 0;

  control.preferences_file="";
  control.flag_pfile = 0;

  control.V2V3 = 0;
  control.ABL = 1; 

  control.Interpolate = 0;
  control.Interpolate_distance = 2;

  control.write_mapping  = 0;
  control.mapping_name_output = "";
  control.flag_mapping_name_output = 0;

  control.channel = 0;
  control.channel_flag = 0;

  control.dispersion_flag = 0;
  control.dispersion = 0.0;

  control.scale_axis1_flag = 0;
  control.scale_axis1 = 0.0;

  control.bin_wave = 1.0;
  control.bin_axis1 = 1.0;

  control.bin_wave_flag = 0;
  control.bin_axis1_flag = 0;

  control.integration_no = 1;
  control.flag_integration_no = 0;

  control.do_verbose = 0;               // -v output very detailed information to the screen

  // setup the defaults for parameter file values
  control.calib_dir = "";             // directory for calibration files - stores in preferences file
  control.scidata_dir = "";         // directory for location of science files
  control.output_dir = "";         // directory for output cibe files


  control.flag_dircal = 0;
  control.flag_dirsci = 0;
  control.flag_dirout = 0;
  control.flag_dirtel = 0;


  control.flag_output_name = 0;



//_______________________________________________________________________

}

