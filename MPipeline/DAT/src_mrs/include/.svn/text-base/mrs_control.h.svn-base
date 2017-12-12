// include files
#ifndef CONTROL_H
#define CONTROL_H

#include <string>
// namespaces

using namespace std;

// The details of how the data were taken and how they should be processed are 
// contained in this structure.
  // command line inputs and parameter file inputs
struct mrs_control {

  //________________________________________________________________________________________
  // environmental varible 
   string  miri_dir;      // base directory of th MIPS/IT DAT
  //________________________________________________________________________________________
  //string fitsbase;  // base filename of dataset to process
  
  int num_reduced_files;
  //________________________________________________________________________________________
  // command line controlled - input list of files to build cube from and background sky files

  string input_list;        // list of reduced image to build cube from
  
  //________________________________________________________________________________________
  // command line option switches - actions to be takens

  int do_verbose;           // output various status messages during reduction

  int numSlicesNTile;
  bool OverWrite;

  string output_name;
  int flag_output_name;

  int Interpolate;
  int Interpolate_distance;

  int ABL;
  int V2V3;
  int subchannel;
  int flag_subchannel;

  int write_mapping;
  string mapping_name_output;
  int flag_mapping_name_output;


  int channel_flag;
  int channel;
	
  int dispersion_flag;
  double dispersion;

  int integration_no;
  int flag_integration_no;


  int scale_axis1_flag;
  double scale_axis1;

  double bin_wave;
  int bin_wave_flag;

  double bin_axis1;
  int bin_axis1_flag;

  string preferences_file; // user provided preferences file name
  int flag_pfile;

  
    //________________________________________________________________________________________
  // varibles read in from the preferences file that can be replaced by the command line

  string calib_dir;        // directory for the location of the calibration files
  int flag_dircal;
  
  string scidata_dir;     // directory for the location of the science data files   
  int flag_dirsci;

  string output_dir;     // directory for the location of the science data files   
  int flag_dirout;

  string teldata_dir;   // directory for the location of the telemetry data files 
  int flag_dirtel;

};

#endif
