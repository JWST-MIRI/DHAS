// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//       ms_get_CDP_names.cpp
//
// Purpose:
//
// Read in the names of Calibration data products for Detector
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
//int ms_get_CDP_names(miri_CDP CDP, miri_control control, miri_preference& preference)
//
//
// Arguments:
//
// Control holds the name of the cdp file to open along with processing options
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
// Created Jan 07 2014 - replaced ms_get_param.cpp that did not search for keys. Used
// hardcoded location in the file to figure out what was what
// Added ability to read in wavelength dependent non-linearity file

#include <string>
#include <string.h>
#include <algorithm>
#include <iostream>
#include <vector>
#include <sstream>
#include <cstring>
#include "miri_sloper.h"
#include "miri_CDP.h"
#include "miri_data_info.h"
#include "miri_control.h"


void miri_search_CDP(string key,vector<string> keyname, vector<string> value,  int& val, int &status);
void miri_search_CDP(string key,vector<string> keyname, vector<string> value,  string& val, int &status);
void miri_search_CDP(string key,vector<string> keyname, vector<string> value,  float& val, int &status);

void ms_get_CDP_names(miri_CDP &CDP, miri_control &control, miri_data_info &data_info)

{
  char chr;
  
  // open the parameter file  (determine the version number of the file)
  string master_list = CDP.GetMasterListDir();
  //cout << "  CDP list of files" << master_list << endl;

  ifstream cdp_file(master_list.c_str(),ios::in);

  if(!cdp_file){
    cerr<< " CDP list of  files does not exist " << endl;
    exit(EXIT_FAILURE);
  }

  //_______________________________________________________________________
  string  kname = "" ;    
  string  vname = "";
  string comment; 
  int files_found = 0; 
  vector<string>keyname;
  vector<string>value;
  while(!cdp_file.eof() ){
    kname="";
    while (cdp_file.get(chr) && chr != '=') {kname += chr;}
    //cout <<  "key" << kname <<  "end " << kname.length() << endl;

    // skip over the comments and grab information after =

    vname ="";
    while (cdp_file.get(chr) && chr != ':') {vname +=chr;}
    cdp_file >> comment;

    while (cdp_file.get(chr) && chr != '\n') {  } // read to end of line

    vname.erase( remove_if( vname.begin(), vname.end(), (int(*)(int))isspace),vname.end()); // remove leading or trailing blanks
    kname.erase( remove_if(kname.begin(), kname.end(), (int(*)(int))isspace),kname.end()); // remove leading or trailing blanks

    keyname.push_back(kname);
    value.push_back(vname);
    files_found++;
  }

  //cout << "Number of CDP files" << files_found << endl;

  //  for (int k = 0; k < files_found-1; k++){
  // cout << keyname[k] << " = " << value[k] << endl;
  //}

  // close the parameter file
  cdp_file.close();

  //_______________________________________________________________________
  // loop over parameters and find matches
  int status = 0;
  string file;


  if(control.apply_badpix == 1) {

    miri_search_CDP("BAD",keyname,value,file,status);
    if(file == "NA" ) {
      cout << " No Bad pixel mask file exist, turnning off using bad pixel mask" << endl;
      control.apply_badpix = 0;
    } else {

      if(status == 1){
	cout << "Failure to parse BAD from CDP list of files" << endl;
	cout << " check the Bad file name " << master_list << endl;
	cout << " aborting program ... if the reference file can not be found do not use this calibration file" << endl;
	exit(EXIT_FAILURE);
      }
      CDP.SetBadPixelName(file);
    }
  }


  if(control.apply_lastframe_cor == 1) {
    miri_search_CDP("LASTFRAME",keyname,value,file,status);

    if(file == "NA" ) {
      cout << " No last frame correction file exist, turnning off step" << endl;
      control.apply_lastframe_cor = 0;
    } else {
      if(status == 1){
	cout << "Failure to parse LASTFRAME from CDP list of files" << endl;
	cout << " check the LastFrame file name in ` " << master_list << endl;
	cout << " aborting program ... if the reference file can not be found do not use this calibration file" << endl;
	exit(EXIT_FAILURE);
      }
      CDP.SetLastFrameName(file);
      cout << " Lastframe file = " << file << endl;
    }

  }

  if(control.apply_pixel_saturation ==1) {
    file = "";
    miri_search_CDP("PIXELSAT",keyname,value,file,status);

    if(file == "NA" ) {
      cout << " No pixel saturation file exist, turnning off step" << endl;
      control.apply_pixel_saturation = 0;
    } else{
      if(status == 1){
	cout << "Failure to parse PIXELSAT from CDP list of files" << endl;
	cout << " check the pixel saturation file name " << master_list << endl;
	cout << " aborting program ... if the reference file can not be found do not use this calibration file" << endl;
	exit(EXIT_FAILURE);
      }
      CDP.SetPixelSatName(file);
    }
  }

  if(control.apply_lin_cor ==1) {
    string LIN_COR = "NA";
    if(data_info.Detector == IM  ){
      LIN_COR = "LIN_COR";
      if(data_info.filter == "F2100W")  LIN_COR = "LIN_COR_F2100W";
      if(data_info.filter == "F2500W") LIN_COR = "LIN_COR_F2500W";
    }
	
    if(data_info.Detector == IC  ) { LIN_COR = "LIN_COR";}

    if(data_info.Detector == LW  ) {
      if(data_info.DGAA == "SHORT" && data_info.DGAB == "SHORT")  LIN_COR = "LIN_COR_SHORT";
      if(data_info.DGAA == "MEDIUM" && data_info.DGAB == "MEDIUM")  LIN_COR = "LIN_COR_MEDIUM";
      if(data_info.DGAA == "LONG" && data_info.DGAB == "LONG") LIN_COR = "LIN_COR_LONG";

      if(data_info.Band == "SHORT" )  LIN_COR = "LIN_COR_SHORT";
      if(data_info.Band == "MEDIUM")  LIN_COR = "LIN_COR_MEDIUM";
      if(data_info.Band == "LONG" ) LIN_COR = "LIN_COR_LONG";
    }

    if(data_info.Detector == SW  ) {
      if(data_info.DGAA == "SHORT" && data_info.DGAB == "SHORT")  LIN_COR = "LIN_COR_SHORT";
      if(data_info.DGAA == "MEDIUM" && data_info.DGAB == "MEDIUM")  LIN_COR = "LIN_COR_MEDIUM";
      if(data_info.DGAA == "LONG" && data_info.DGAB == "LONG") LIN_COR = "LIN_COR_LONG";

      if(data_info.Band == "SHORT" )  LIN_COR = "LIN_COR_SHORT";
      if(data_info.Band == "MEDIUM")  LIN_COR = "LIN_COR_MEDIUM";
      if(data_info.Band == "LONG" ) LIN_COR = "LIN_COR_LONG";
    }


    miri_search_CDP(LIN_COR,keyname,value,file,status);      

    if(file == "NA" ) {
      cout << " No linearity correction file exist, turnning off step" << endl;
      control.apply_lin_cor= 0;
    } else{
      if(status == 1) {
	cout << "LIN_COR: " << LIN_COR << endl;
	cout << "Detector" << data_info.Detector << endl;
	cout << "DGAA" << data_info.DGAA << endl;
	cout << "DGAB" << data_info.DGAB << endl;
	cout << "Band" << data_info.Band << endl;
	
	cout << "Failure to parse LIN_COR  from CDP list of files" << endl;
	cout << " check the linearity file name " << master_list << endl;
	cout << " aborting program ... if the reference file can not be found do not use this calibration file" << endl;
	exit(EXIT_FAILURE);
      }
      CDP.SetLinCorName(file);
    }
    
    }

  if(control.apply_rscd_cor == 1) {
    miri_search_CDP("RSCD",keyname,value,file,status);

    if(file == "NA" ) {
      cout << " No rscd correction file exist, turnning off step" << endl;
      control.apply_rscd_cor = 0;
    } else {
      if(status == 1) {
	cout << "Failure to parse RSCD from CDP list of files" << endl;
	cout << " check the RSCD file name " << master_list << endl;
	cout << " aborting program ... if the reference file can not be found do not use this calibration file" << endl;
	exit(EXIT_FAILURE);
      }
      CDP.SetRSCDName(file);
      //cout << " RSCD file name: " << file << endl;
    }
  }

  if(control.apply_rscd_cor == 1) {
    miri_search_CDP("MULT",keyname,value,file,status);

    if(file == "NA" ) {
      cout << " No mult correction file exist, turnning off step" << endl;
      control.apply_rscd_cor = 0;
    } else {
      if(status == 1) {
	cout << "Failure to parse MULT from CDP list of files" << endl;
	cout << " check the MULT file name " << master_list << endl;
	cout << " aborting program ... if the reference file can not be found do not use this calibration file" << endl;
	exit(EXIT_FAILURE);
      }
      CDP.SetMULTName(file);
      cout << " MULT file name: " << file << endl;
    }
  }
  //***********************************************************************
  // _______________________________________________________________________
  // Read in Dark Names
  // All detectors have darks for FAST mode
  // 

  if(control.apply_dark_cor == 1) {

    miri_search_CDP("DARK_FAST",keyname,value,file,status);
    if(status == 1){
      cout << "Failure to parse DARK_FAST from CDP list files" << endl;
      cout << " check the Dark file name " << master_list << endl;
      cout << " aborting program ... if the reference file can not be found do not use this calibration file" << endl;
      exit(EXIT_FAILURE);
    }
    CDP.SetDarkFastName(file);
    
  // _______________________________________________________________________
  // if in slow mode 
  // 
    if(data_info.Mode == 1 ) { 
      miri_search_CDP("DARK_SLOW",keyname,value,file,status);
      if(status == 1) {
	cout << "Failure to parse DARK_SLOW from CDP list files" << endl;
	cout << " check the Dark file name " << master_list << endl;
	cout << " aborting program ... if the reference file can not be found do not use this calibration file" << endl;
	exit(EXIT_FAILURE);
      }
      CDP.SetDarkSlowName(file);
    }
//_______________________________________________________________________
// Run 8 SCA 106

    if(data_info.Origin == "JPL"   && control.jpl_detector == "106") {
	miri_search_CDP("DARK_MASK4QPM",keyname,value,file,status);

	if(status ==  1) cout << "Failure to parse DARK_MASK4QPM from CDP list files" << endl;
	CDP.SetDarkMask4QPMName(file);

	miri_search_CDP("DARK_SUBLARGE",keyname,value,file,status);
	if(status == 1) cout << "Failure to parse Dark_SUBLARGE from CDP list files" << endl;
	CDP.SetDarkSubLargeName(file);

    } 
//_______________________________________________________________________
// Read in the subarray darks 
    status = 0;
    if(data_info.Detector == IM && data_info.subarray_mode !=0) {

      miri_search_CDP("DARK_BRIGHTSKY",keyname,value,file,status);
      if(status == 1) cout << "Failure to parse DARK_BRIGHTSKY from CDP list files" << endl;
      CDP.SetDarkBrightSkyName(file);

      miri_search_CDP("DARK_MASK1065",keyname,value,file,status);
      if(status == 1) cout << "Failure to parse DARK_MASK1065 from CDP list files" << endl;
      CDP.SetDarkMask1065Name(file);

      miri_search_CDP("DARK_MASK1140",keyname,value,file,status);
      if(status == 1) cout << "Failure to parse DARK_MASK1140 from CDP list files" << endl;
      CDP.SetDarkMask1140Name(file);

      miri_search_CDP("DARK_MASK1550",keyname,value,file,status);
      if(status == 1) cout << "Failure to parse DARK_MASK1550 from CDP list files" << endl;
      CDP.SetDarkMask1550Name(file);

      miri_search_CDP("DARK_MASKLYOT",keyname,value,file,status);
      if(status == 1) cout << "Failure to parse DARK_MASKLYOT from CDP list files" << endl;
      CDP.SetDarkMaskLYOTName(file);

      miri_search_CDP("DARK_SPRISM",keyname,value,file,status);
      if(status == 1) cout << "Failure to parse DARK_SPRISM from CDP list files" << endl;
      CDP.SetDarkSPrismName(file);

      miri_search_CDP("DARK_MASKSUB128",keyname,value,file,status);
      if(status == 1) cout << "Failure to parse DARK_MASKSUB128 from CDP list files" << endl;
      CDP.SetDarkMaskSub128Name(file);

      miri_search_CDP("DARK_MASKSUB64",keyname,value,file,status);
      if(status == 1) cout << "Failure to parse DARK_MASKSUB64 from CDP list files" << endl;
      CDP.SetDarkMaskSub64Name(file);

      miri_search_CDP("DARK_MASKSUB256",keyname,value,file,status);
      if(status == 1) cout << "Failure to parse DARK_MASKSUB256 from CDP list files" << endl;
      CDP.SetDarkMaskSub256Name(file);

      if(status ==1 && control.apply_dark_cor == 1) {
	cout << " check the Dark file name " << master_list << endl;
	cout << " aborting program ... if the reference file can not be found do not use this calibration file" << endl;
	exit(EXIT_FAILURE);
      }
    }
  }


 //***********************************************************************
  // _______________________________________________________________________
  // Read in Reset Names
  // All detectors have darks for FAST mode
  // 

  if(control.apply_reset_cor == 1) {

    miri_search_CDP("RESET_FAST",keyname,value,file,status);
    if(status == 1) cout << "Failure to parse RESET_FAST from CDP list files" << endl;
    CDP.SetResetFastName(file);    

  // _______________________________________________________________________
  // if in slow mode 
  // 
    if(data_info.Mode == 1 ) { 
      miri_search_CDP("RESET_SLOW",keyname,value,file,status);
      CDP.SetResetSlowName(file);
    } 

  // _______________________________________________________________________
  // JPL Run 8 and SCA106  
  // 
    if(data_info.Origin == "JPL"   && control.jpl_detector == "106") {
	miri_search_CDP("RESET_MASK4QPM",keyname,value,file,status);
	CDP.SetResetMask4QPMName(file);
	if(status == 1) cout << "Failure to parse RESET_MASK4QPM from CDP list files" << endl;

	miri_search_CDP("RESET_SUBLARGE",keyname,value,file,status);
	CDP.SetResetSubLargeName(file);
	if(status == 1) cout << "Failure to parse RESET_SUBLARGE from CDP list files" << endl;
    } 
//_______________________________________________________________________
// Read in the subarray resets 

    if(data_info.Detector == IM && data_info.subarray_mode ==1) {

      miri_search_CDP("RESET_BRIGHTSKY",keyname,value,file,status);
      if(status == 1) cout << "Failure to parse RESET_BRIGHTSKY from CDP list files" << endl;
      CDP.SetResetBrightSkyName(file);

      miri_search_CDP("RESET_MASK1065",keyname,value,file,status);
      if(status == 1) cout << "Failure to parse RESET_MASK1065 from CDP list files" << endl;
      CDP.SetResetMask1065Name(file);

      miri_search_CDP("RESET_MASK1140",keyname,value,file,status);
      if(status == 1) cout << "Failure to parse RESET_MASK1140 from CDP list files" << endl;
      CDP.SetResetMask1140Name(file);

      miri_search_CDP("RESET_MASK1550",keyname,value,file,status);
      if(status == 1) cout << "Failure to parse RESET_MASK1550 from CDP list files" << endl;
      CDP.SetResetMask1550Name(file);

      miri_search_CDP("RESET_MASKLYOT",keyname,value,file,status);
      if(status == 1) cout << "Failure to parse RESET_MASKLYOT from CDP list files" << endl;
      CDP.SetResetMaskLYOTName(file);

      miri_search_CDP("RESET_SPRISM",keyname,value,file,status);
      if(status == 1) cout << "Failure to parse RESET_SPRISM from CDP list files" << endl;
      CDP.SetResetSPrismName(file);

      miri_search_CDP("RESET_MASKSUB128",keyname,value,file,status);
      if(status == 1) cout << "Failure to parse RESET_MASKSUB128 from CDP list files" << endl;
      CDP.SetResetMaskSub128Name(file);

      miri_search_CDP("RESET_MASKSUB64",keyname,value,file,status);
      if(status == 1) cout << "Failure to parse RESET_MASKSUB64 from CDP list files" << endl;
      CDP.SetResetMaskSub64Name(file);

      miri_search_CDP("RESET_MASKSUB256",keyname,value,file,status);
      if(status == 1) cout << "Failure to parse RESET_MASKSUB256 from CDP list files" << endl;
      CDP.SetResetMaskSub256Name(file);
        
    }
  }



}
