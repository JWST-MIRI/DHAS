#include "miri_caler.h"
#include "mc_preference.h"

void miri_parse_param(ifstream& param_file,int& val);
void miri_parse_param(ifstream& param_file,string& val);
void miri_parse_param(ifstream& param_file,float& val);
void miri_parse_param(ifstream& param_file,char* filename);

// ----------------------------------------------------------------------
// Main procedure to parse the parameter file
#include <string>
int mc_get_param(string param_filename,
		   mc_preference& preference)

{
  char chr;
  // open the parameter file  (determine the version number of the file)
  ifstream param_file(param_filename.c_str(),ios::in);
  if(!param_file){
    cerr<< " Preferences file does not exist " << endl;
    cout << " Check that you have the environment variable MIRI_DIR set up correctly in your .bashrc or equivalent file" << endl;
    exit(EXIT_FAILURE);
  }
  //_______________________________________________________________________

  string version = "1.0.0";
  string cur_string = "";
  string comp_string = "VER";
  while (param_file.get(chr) && chr != ':') {cur_string += chr;}
  if (cur_string == comp_string) {
    param_file >> version;
    cout << " version: " << version << endl;
  }      
  //cout << "parameter file version = " << version << endl;

  // close the parameter file
  param_file.close();

  //_______________________________________________________________________
  // open the parameter file (again)
  param_file.open(param_filename.c_str());
  comp_string = "DONOTCHANGE";
  cur_string = "";
  char chr1;
  while (param_file.get(chr1) && chr1 != ':') {cur_string += chr1;}
  while (cur_string != comp_string) {
    cur_string = "";
    while (param_file.get(chr1) && chr1 != '\n') {}
    while (param_file.get(chr1) && chr1 != ':') {cur_string += chr1;}
  }      
    
  // get the parameters by parsing the parameter file

  // defaults 

  miri_parse_param(param_file,preference.calib_dir);
  param_file.close();
  //_______________________________________________________________________

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

  miri_parse_param(param_file,preference.scidata_dir);
  miri_parse_param(param_file,preference.scidata_out_dir);
  miri_parse_param(param_file,preference.teldata_dir);
  param_file.close();

  //-----------------------------------------------------------------------

  return(0);
}
