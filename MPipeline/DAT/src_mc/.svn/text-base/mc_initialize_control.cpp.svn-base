#include "mc_control.h"

void mc_initialize_control(mc_control &control)

{
  // **********************************************************************
  // create the parameter filename string and read in various user defined inputs
  //   paramter file must be in the Cal subdirectory of the MIPS Pipeline directory

  // setup the defaults for command line parameters
  // true  = 1
  // false = 0
  
  control.fitsbase = "";
  control.output_name = "";
  
  control.make_log = 0;

  control.apply_background = 0;                  // +/- d do(not do)  background subtraction
  control.apply_flat = 0;                  // +/- f do(not do)  flat fielding
  control.apply_fringe_flat = 0;                  // +/- f do(not do)  apply fringe flat
  control.subchannel = -10;
  control.flag_subchannel = 0;


  control.do_verbose = 0;               // -v output very detailed information to the screen
  

  // setup the defaults for parameter file values
  //  control.calib_dir = "";             // directory for calibration files - stores in preferences file
  control.scidata_dir = "";         // directory for location of science files
  control.scidata_out_dir = "";     // directory for location for output science files
  control.preferences_file="";


  //  control.flag_dircal = 0;
  control.flag_dirsci = 0;
  control.flag_dirout = 0;
  control.flag_dirtel = 0;
  control.flag_pfile = 0;
  
  
  control.flag_output_name = 0;

  control.flag_background_file=0;
  control.flag_flat_file=0;
  control.flag_fringe_file=0;


//_______________________________________________________________________

}

