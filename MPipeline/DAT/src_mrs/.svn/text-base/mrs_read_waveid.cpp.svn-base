// mrs_read_input_list.cpp
#include <dirent.h>
#include <sys/stat.h> 
#include <iostream>
#include <string>
#include <cstring>
#include <iomanip>
#include <fstream>
#include <math.h>
#include <cstdlib>
#include "fitsio.h"
#include "miri_constants.h"
#include "mrs_data_info.h"
#include "mrs_control.h"


/**********************************************************************/
// Description of program:

/**********************************************************************/
// Read in list of input image filenames

int mrs_read_waveid(const mrs_control control,
                        mrs_data_info &data_info)
  
{


  int status = 0;
  cout << "Reading Telemetry data from directory " << control.teldata_dir << endl;
  vector<string> TelemetryFile;

  string stmp,new_current_string;
  struct stat st;
  struct dirent *struct_current;

  DIR *pdir = opendir(control.teldata_dir.c_str());
  if(pdir ==NULL){
    cout << " Error opening telemetry directory. Check if directory exists: " << control.teldata_dir << endl;
    exit(EXIT_FAILURE);
  }

 // Loop over "files" in tel directory

  while (  (struct_current = readdir(pdir))  ) {


    if (strcmp(struct_current->d_name,".") !=0 && strcmp(struct_current->d_name,".") !=0) {
      stat(struct_current->d_name,&st);
    
      if(control.do_verbose ==1) cout << " Possible telemetry file " << struct_current->d_name << endl;
      TelemetryFile.push_back(struct_current->d_name);
    }
 }


  int numTel = TelemetryFile.size();
  // cout << " number of telemetry files " << numTel << endl;

 closedir(pdir);
 
 int Ngood_files = 0;

  for ( int i = 0 ; i < data_info.nfiles; i++){

    string filename_data =  data_info.input_filenames[i];
    if(control.do_verbose ==1) cout << " filename_data " << filename_data << endl;
    string obsid0 = filename_data.substr(9,8);  
    string:: size_type pos = obsid0.find_first_not_of('0');
    string obsid = obsid0.substr(pos,8-pos);
    //cout << "obsid " << obsid << endl;

    string expid = filename_data.substr(18,1);  
    expid = "1";

    string tmatch = "MIRI_"+obsid+"_"+expid+"_HK_ICE";
    //cout << tmatch << endl;
    vector <string> telfilename;
    int found_ICE_file = 0;
    int GWA = 0;
    int GWB = 0;
    

    for(int j = 0; j<numTel; j++){
      //      cout << tmatch << " " << TelemetryFile[j] << endl;
      string::size_type pos = TelemetryFile[j].find(tmatch);
      if(pos != string::npos) {
	string filename = control.teldata_dir+"/"+TelemetryFile[j];
	telfilename.push_back(filename);
	found_ICE_file++; 
	int lstatus  = 0;
	fitsfile *file_ptr;
	cout << " going to open " << filename << endl;
	fits_open_table(&file_ptr,filename.c_str(), READONLY, &lstatus);   // open the file
	if(lstatus !=0 ) {
	  cout << " mrs_read_waveid: Could not open file " <<filename << endl;
	  status = 1;
	}
	int hdutype = 0;
	status = 0;
	fits_movabs_hdu(file_ptr,3,&hdutype,&status);
	long nrows = 0;
	fits_get_num_rows(file_ptr,&nrows,&status);
	//cout << "Number of rows" << nrows << endl;
	vector <int> gwa(nrows);
	vector <int> gwb(nrows);
	int ncols = 0;
	fits_get_num_cols(file_ptr,&ncols,&status);
	//cout << "Number of columns" << ncols << endl;
	int ngwa = 0;
	char GWA_S [13] = "GWA_MEAS_POS";
	char GWB_S [13] = "GWB_MEAS_POS";
	fits_get_colnum(file_ptr,CASEINSEN,GWA_S,&ngwa,&status);
	int ngwb = 0;
	fits_get_colnum(file_ptr,CASEINSEN,GWB_S,&ngwb,&status);
	//cout << ngwa <<" " << ngwb  << endl;

	int anynul = 0;
	fits_read_col(file_ptr,TINT,ngwa,1,1,nrows,0,&gwa[0],&anynul,&status);
	GWA = gwa[0];
	GWA = gwa[nrows-1];
	anynul = 0;
	fits_read_col(file_ptr,TINT,ngwb,1,1,nrows,0,&gwb[0],&anynul,&status);
	GWB = gwb[0];
	GWB = gwb[nrows-1];
	
      } // end if - checking match
    } // done looping over all Telemetry files
    if(found_ICE_file ==0) {
      cout << " Could not find the ICE Engineering Telemetry file for " << filename_data << endl;
      cout << " Searched the directory " << control.teldata_dir << endl;
      cout << " Searched for the telemetry file of the form " << tmatch << endl;
      cout << " Number of telemetry files searched" << numTel << endl;
      cout << " The ICE FITS file contains the Filter Wheel position, which determine the wavelength range of the data" << endl;
      //cout << " Deleting the File " << filename_data << " from the list of data file to create the cube " << endl;
      data_info.Use_File[i] = 0;
    }
    if(found_ICE_file > 1) {
      data_info.Use_File[i] = 0;
      cout << " More than 1 ICE Engineering Telemetry file matched data file " << filename_data << endl;
      cout << " Because of confusion with GWA and GWB positions, deleting this file from cube building " << endl;
      cout << " The matching telemetry files are " << endl;
      for (unsigned int k = 0; k< telfilename.size(); k++){
	cout << telfilename[k] << endl;
      }
    }

    if(found_ICE_file ==1) {
      data_info.Use_File[i] = 1;
      data_info.GWA[i] = GWA;
      data_info.GWB[i] = GWB;
      //cout << filename_data << " GWA GWB " << GWA << " " << GWB << endl;
      int WAVE_ID = -1;
      if(GWA ==2 && GWB == 1) WAVE_ID = SUBCHANNEL_A;
      if(GWA ==3 && GWB == 2) WAVE_ID = SUBCHANNEL_B;
      if(GWA ==1 && GWB == 3) WAVE_ID = SUBCHANNEL_C;
      data_info.WAVE_ID[i] = WAVE_ID;
	cout << " The values of GWA and GWB are: " << GWA << " " << GWB << endl;
	cout << " WAVE ID (0= Subchannel A, 1 = Subchannel B, 2 = SubChannel C) " << WAVE_ID << endl;

      if(WAVE_ID ==-1) {
	cout << " Filter Wheel positions not of correct set  (GWA, GWB) " << GWA << " " <<  GWB << endl;
	data_info.Use_File[i] = 0;
      }
    }

    
    if(data_info.Use_File[i] == 1) Ngood_files++;
  }// Done looping over input data files

  if(Ngood_files ==0) {
    cout << " All the files were rejected, no data to build the cube with, exiting program" << endl;
    status = 1;
    return status;
  }


  return status;
}

