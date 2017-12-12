// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//       mc_get_param2.cpp
//
// Purpose:
//
// This program does the work of ms_read_preferences- it does the parsing all the
// parameters in the preferences file 	
//
//
// Author:
//
//	Jane Morrison
//      University of Arizona
//      email: morrison@as.arizona.edu
//      phone: 520-626-3181
// 
// 
// Calling Sequence:
//
//int mc_get_param2(string param_filename,
//		   miri_preference& preference)
//
//
// Arguments:
//
// filename : name of file to process
// preference: the miri_preference structure that holds all the default parameters found in
//            the preference file. 
//
// Return Value:
//
// 0 - worked ok  
// Additional routines: 
//void miri_parse_param; pulls out the parameters after the = in the preferences file.  
//
// History:
//
// Created Jan 07 2014 - replaced mc_get_param.cpp that did not search for keys. Used
// hardcoded location in the file to figure out what was what

#include <string>
#include <string.h>
#include <algorithm>
#include "miri_caler.h"
#include "mc_preference.h"

void mc_search_keys(string keyname,mc_preference &preference, int& val, int &status);
void mc_search_keys(string keyname,mc_preference &preference, string& val, int &status);
void mc_search_keys(string keyname,mc_preference &preference, float& val, int &status);

int mc_get_param2(string param_filename,
		   mc_preference& preference)

{
  int Final_Status = 0 ; 
  char chr;
  // open the parameter file  (determine the version number of the file)
  ifstream param_file(param_filename.c_str(),ios::in);
  if(!param_file){
    cerr<< " Preferences file does not exist " << endl;
    cout << " Check that you have the environment variable MIRI_DIR set up correctly in your .bashrc or equivalent file" << endl;
    exit(EXIT_FAILURE);
  }

  //_______________________________________________________________________
  string key = "" ;    
  string value = "";
  string comment;
  int keys_found = 0; 
  while(!param_file.eof() ){
    key="";
    while (param_file.get(chr) && chr != '=') {key += chr;}
    //    cout <<  "key" << key <<  "end " << key.length() << endl;
    // skip over the comments and grab information after =
    value ="";
    while (param_file.get(chr) && chr != ':') {value +=chr;}
    param_file >> comment;

    while (param_file.get(chr) && chr != '\n') {  } // read to end of line

    key.erase( remove_if( key.begin(), key.end(), (int(*)(int))isspace),key.end()); // remove leading or trailing blanks
    value.erase( remove_if(value.begin(), value.end(), (int(*)(int))isspace),value.end()); // remove leading or trailing blanks

    preference.key.push_back(key);
    preference.value.push_back(value);
    keys_found++;
  }

  //  cout << "Number of Keys" << keys_found << endl;
  preference.keys_found = keys_found;
  //for (int k = 0; k < keys_found-1; k++){
  // cout << preference.key[k] << " = " << preference.value[k] << endl;
  // }

  // close the parameter file
  param_file.close();

  //_______________________________________________________________________
  // loop over parameters and find matches
  int status = 0;
  //  mc_search_keys("CALDIR",preference,preference.calib_dir,status);
  //if(status == 1) {
  //  cout << "Failure to parse CALDIR from preferences file" << endl;
  //  Final_Status = 1;
  //} 

  mc_search_keys("SCIDIR",preference,preference.scidata_dir,status);
  if(status == 1) {
    cout << "Failure to parse SCIDIR from preferences file" << endl;
    Final_Status = 1;
  } 

  mc_search_keys("LVL2DIR",preference,preference.scidata_out_dir,status);
  if(status == 1) {
    cout << "Failure to parse LVL2DIR from preferences file" << endl;
    Final_Status = 1;
  } 

  mc_search_keys("TELDIR",preference,preference.teldata_dir,status);
  if(status == 1) {
    cout << "Failure to parse TELDIR from preferences file" << endl;
    Final_Status = 1;
  } 

 
  return Final_Status; 

}
