// include files
#ifndef MCCONTROL_H
#define MCCONTROL_H

#include <string>


// namespaces

using namespace std;

// The details of how the data were taken and how they should be processed are 
// contained in this structure.
  // command line inputs and parameter file inputs
struct mc_control {

  //________________________________________________________________________________________
  // environmental varible 
   string  miri_dir;      // base directory of th MIPS/IT DAT
  //________________________________________________________________________________________
  string fitsbase;  // base filename of dataset to process

  //________________________________________________________________________________________
  // command line option switches - actions to be takens

  int apply_background;         // apply the  background  file (subtract it) 
  int apply_flat;              // apply the  flat calibration file (divide by it) 
  int apply_fringe_flat;        // apply the  fringe flat calibration file (divide by it) 
  int subchannel;
  int flag_subchannel;

  int make_log;             // create a log file: statisitics

  int do_verbose;           // output various status messages during reduction

  string output_name;
  int flag_output_name;

    //________________________________________________________________________________________
  // varibles read in from the preferences file that can be replaced by the command line


  //  string calib_dir;        // directory for the location of the calibration files - User now gives the dir
  //int flag_dircal;                        // with the calibration file
  
  string scidata_dir;   
  int flag_dirsci;

  string scidata_out_dir;   
  int flag_dirout;

  string teldata_dir;   
  int flag_dirtel;

  string preferences_file; // user provided preferences file name
  int flag_pfile;

  string background_file;
  int flag_background_file;                 

  string flat_file  ;                //  flat calibration image 
  int flag_flat_file;                 

  string fringe_file;
  int flag_fringe_file;
  //________________________________________________________________________________________
};

#endif
