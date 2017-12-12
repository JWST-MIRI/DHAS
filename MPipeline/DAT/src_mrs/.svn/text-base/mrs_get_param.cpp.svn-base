#include <string>
#include <iostream>
#include <string>
#include <iomanip>
#include <fstream>
#include <cstdlib>
#include <fstream>
#include <iomanip>

#include "miri_cube.h"
#include "mrs_preference.h"

// ----------------------------------------------------------------------
// Helper procedure
void mrs_parse_param(ifstream& param_file,
		     int& val)

{
  char chr;
  while (param_file.get(chr) && chr != '=') {}
  param_file >> val;

}
// ----------------------------------------------------------------------
// Helper procedure

void mrs_parse_param(ifstream& param_file,
		     string& val)

{
  char chr;
  while (param_file.get(chr) && chr != '=') {}
  param_file >> val;

}

// ----------------------------------------------------------------------
// Helper procedure

void mrs_parse_param(ifstream& param_file,
		     float& val)

{
  char chr;
  while (param_file.get(chr) && chr != '=') {}
  param_file >> val;
}

// ----------------------------------------------------------------------
// Helper procedure

void mrs_parse_param(ifstream& param_file,
		     double& val)

{
  char chr;
  while (param_file.get(chr) && chr != '=') {}
  param_file >> val;
}

// ----------------------------------------------------------------------
// Helper procedure

void mrs_parse_param(ifstream& param_file,
		     char* filename)

{
  char chr;
  while (param_file.get(chr) && chr != '=') {}
  param_file.get(chr);
  int k = 0;
  while (param_file.get(chr) && chr != '\n') { 
    filename[k] = chr;
    k++;
  }
  filename[k] = '\0';
  
}

// ----------------------------------------------------------------------
// Main procedure to parse the parameter file
#include <string>

int mrs_get_param(string param_filename,
		   mrs_preference& preference)

{
  char chr;
  // open the parameter file  (determine the version number of the file)
  ifstream param_file(param_filename.c_str(),ios::in);
  if(!param_file){
    cerr<< " Preferences file does not exist " << param_filename.c_str() << endl;
    cout << " Check that you have the environment variable MIRI_DIR set up correctly in your .bashrc or equivalent file" << endl;
    exit(EXIT_FAILURE);
  }


  string version = "1.0.0";
  string cur_string = "";
  string comp_string = "VER";
  while (param_file.get(chr) && chr != ':') {cur_string += chr;}
  if (cur_string == comp_string) {
    param_file >> version;
    cout << " version: " << version << endl;
  }      
  // close the parameter file
  param_file.close();

  // _______________________________________________________________________


  // Read in values flagged by CHANGE
  // open the parameter file (again)
  param_file.open(param_filename.c_str());
  
  comp_string = "CHANGE";
  cur_string = "";
  char chr2;
  while (param_file.get(chr2) && chr2 != ':') {cur_string += chr2;}
  while (cur_string != comp_string) {
    cur_string = "";
    while (param_file.get(chr2) && chr2 != '\n') {}
    while (param_file.get(chr2) && chr2 != ':') {cur_string += chr2;}
  }      
    
  // get the parameters by parsing the parameter file

  // defaults 

  mrs_parse_param(param_file,preference.scidata_dir);
  mrs_parse_param(param_file,preference.teldata_dir);
  mrs_parse_param(param_file,preference.output_dir);

  //cout << preference.scidata_dir << endl;
  //cout << preference.teldata_dir << endl;
  //cout << preference.output_dir << endl;
  param_file.close();
 

  // _______________________________________________________________________
  // Read in values flagged by CUBE
  // open the parameter file (again)
  param_file.open(param_filename.c_str());
  
  comp_string = "CUBE";
  cur_string = "";
  char chr3;
  while (param_file.get(chr3) && chr3 != ':') {cur_string += chr3;}
  while (cur_string != comp_string) {
    cur_string = "";
    while (param_file.get(chr3) && chr3 != '\n') {}
    while (param_file.get(chr3) && chr3 != ':') {cur_string += chr3;}
  }      
    
  // get the parameters by parsing the parameter file

  // defaults 


  mrs_parse_param(param_file,preference.cube_plate_scale_file);
  mrs_parse_param(param_file,preference.bin_wave);
  mrs_parse_param(param_file,preference.bin_axis1);
  mrs_parse_param(param_file,preference.calibration_version[0]);
  mrs_parse_param(param_file,preference.calibration_version[1]);
  // close the parameter file
  param_file.close();
  //cout << " Done reading preferences file" << endl;
  return(0);
}






// ----------------------------------------------------------------------
// Main procedure to read in the cube pixel size file
#include <string>

int mrs_get_cube_size(string cubedim_filename,
		   mrs_preference& preference)

{
  char chr;
  // open the cube size file  (determine the version number of the file)
  ifstream cubedim_file(cubedim_filename.c_str(),ios::in);
  if(!cubedim_file){
    cerr<< " Cube dimension file does not exist " << cubedim_filename << endl;
    exit(EXIT_FAILURE);
  }


  string version = "1.0.0";
  string cur_string = "";
  string comp_string = "VER";
  while (cubedim_file.get(chr) && chr != ':') {cur_string += chr;}
  if (cur_string == comp_string) {
    cubedim_file >> version;
    cout << " version: " << version << endl;
  }      
  // close the cubedimeter file
  cubedim_file.close();

  // open the cubedimeter file (again)
  cubedim_file.open(cubedim_filename.c_str());
  
  comp_string = "CUBE";
  cur_string = "";
  char chr2;
  while (cubedim_file.get(chr2) && chr2 != ':') {cur_string += chr2;}
  while (cur_string != comp_string) {
    cur_string = "";
    while (cubedim_file.get(chr2) && chr2 != '\n') {}
    while (cubedim_file.get(chr2) && chr2 != ':') {cur_string += chr2;}
  }      
    

  //  read in defaults 

  for (int i = 0 ; i < 3 ; i++){
    mrs_parse_param(cubedim_file,preference.scale_axis1[0][i]);
    mrs_parse_param(cubedim_file,preference.dispersion[0][i]);
  }

  for (int i = 0 ; i < 3 ; i++){
    mrs_parse_param(cubedim_file,preference.scale_axis1[1][i]);
    mrs_parse_param(cubedim_file,preference.dispersion[1][i]);
    
  }

  for (int i = 0 ; i < 3 ; i++){
    mrs_parse_param(cubedim_file,preference.scale_axis1[2][i]);
    mrs_parse_param(cubedim_file,preference.dispersion[2][i]);
    
  }

  for (int i = 0 ; i < 3 ; i++){
    mrs_parse_param(cubedim_file,preference.scale_axis1[3][i]);
    mrs_parse_param(cubedim_file,preference.dispersion[3][i]);
    
  }

  
  
  // close the parameter file
  cubedim_file.close();

  return(0);
}
