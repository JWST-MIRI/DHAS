#include <string>
#include <fstream>
#include <iostream>
using namespace std;
// ----------------------------------------------------------------------
// Helper procedure
void miri_parse_param(ifstream& param_file,
		     int& val)

{
  char chr;
  while (param_file.get(chr) && chr != '=') {}
  param_file >> val;
  //cout << param.file.get(chr) << endl;
}
// ----------------------------------------------------------------------
// Helper procedure

void miri_parse_param(ifstream& param_file,
		     string& val)

{
  char chr;
  while (param_file.get(chr) && chr != '=') {}
  param_file >> val;
}

// ----------------------------------------------------------------------
// Helper procedure

void miri_parse_param(ifstream& param_file,
		     float& val)

{
  char chr;
  while (param_file.get(chr) && chr != '=') {}
  param_file >> val;
}

// ----------------------------------------------------------------------
// Helper procedure

void miri_parse_param(ifstream& param_file,
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

