// mrs_read_input_list.cpp
#include <iostream>
#include <string.h>
#include <iomanip>
#include <fstream>
#include <math.h>
#include <cstdlib>
#include "fitsio.h"
#include "mrs_data_info.h"
#include "mrs_control.h"


/**********************************************************************/
// Description of program:
// Read in the list of reduced files to build a spectrall cube with
// Varibles filled in by this program: 
// 1. File names read into varible data_info.input_filenames
// 2. number of files read in: data_info.num_files 
/**********************************************************************/
// Read in list of input image filenames

int mrs_read_input_list(const mrs_control control,
                        mrs_data_info &data_info)
  
{

  int status = 0;


  // read in the name of the file holding the list of fits files to build
  // the cube from
  // If the list file ends in *.fits - then we only have 1 file to build
  // the cube from and this is it. 

  int numFiles = 0;

  string::size_type ffits = control.input_list.find(".fits");
  cout << " Input list " << control.input_list << endl;
  int found_fits = 0;

  if(ffits != string::npos)  found_fits = 1;
  if(found_fits ==0) { 
    ffits = control.input_list.find(".Fits");
    if(ffits != string::npos)  found_fits = 1;
  }
  if(found_fits ==0) { 
    ffits = control.input_list.find(".FITS");
    if(ffits != string::npos)  found_fits = 1;
  }

  if(control.do_verbose ==1) {
    if(found_fits == 1) cout << " The input list is a fits file " << endl;
    if(found_fits == 0) cout << " The input list is a list of fits files  " << endl;
  }
    
  if(found_fits ==1) {
    data_info.input_filenames.push_back(control.input_list);
    numFiles = 1;
  }else {
    ifstream inputNames(control.input_list.c_str(),ios::in);
    if(!inputNames) {
      cerr << "Input list of images could not be opened or if running on a single file you forgot the  .fits at the end" << endl;
      exit(EXIT_FAILURE);
    }

    string ifile;
    while(inputNames >> ifile)
      {
	data_info.input_filenames.push_back(ifile);
	numFiles++;
      }      
  } 
    
    //_______________________________________________________________________
  data_info.nfiles = numFiles;

  if(control.do_verbose ==1) cout << " Number of input files " << numFiles << endl;

  if(numFiles ==1) {

    data_info.fitsbase = 
      data_info.input_filenames[0].substr(0,data_info.input_filenames[0].size()-10);
    cout << data_info.fitsbase << endl;
  }
  if(control.do_verbose == 1) {
    cout << " Number of files " << numFiles << endl;
    cout << " Input file names: " << endl;

    for ( int i = 0; i< numFiles; i++) 
      {
	cout << data_info.input_filenames[i] << endl;
      }
  }
    //_______________________________________________________________________
    // open the Input file names and figure out which SCA they are from

  data_info.DGAA_POS_FLAG =  0;
  data_info.DGAB_POS_FLAG = 0 ;
    

  for ( int i = 0 ; i < numFiles; i++){
    char comment[72]; 
    fitsfile *file_ptr;
    string filename =  control.scidata_dir + data_info.input_filenames[i];

    if(control.do_verbose ==1) cout << " Reading header information for file " << filename << endl;

    int lstatus  = 0;
    fits_open_file(&file_ptr,filename.c_str(), READONLY, &lstatus);   // open the file
    if(lstatus !=0 ) {
      cout << " mrs_read_input_list: Could not open file " <<filename << endl;
      cout << "Check if directory exists and filename exist " << endl;
      status = 1;
      return status;
    }


    char det[FLEN_VALUE];
    status = 0; 
    fits_read_key(file_ptr, TSTRING, "DETECTOR", &det, comment, &status); 
    data_info.Detector.push_back(det);
  
    cout << " Detector " << det  << endl;

    char orig[FLEN_VALUE];
    status = 0; 
    fits_read_key(file_ptr, TSTRING, "ORIGIN", &orig, comment, &status); 
    data_info.Origin.push_back(orig);
    


    int NSample = 0;
    lstatus = 0;
    fits_read_key(file_ptr, TINT, "NSAMPLE", &NSample, comment, &lstatus); 
    if(lstatus !=0 ){
      lstatus = 0;
      fits_read_key(file_ptr, TINT, "NSAMPLES", &NSample, comment, &lstatus); 
      if(lstatus !=0){
	cout << "mrs_read_input_list:  Problem reading NSAMPLE or NSAMPLES " << endl;
	status = 1;
	return status;
      }
    }
    data_info.NSample.push_back(NSample);


    int pint;
   lstatus = 0;
    fits_read_key(file_ptr,TINT,"NPINT", &pint, comment,&lstatus);
	
    if(lstatus !=0 ){
	cout << " mrs_read_input_list:You did not open a SLOPE file, run again with SLOPE (LVL2) input data" <<endl;
	status =1 ;
	return status;
    }
    

    const char shorttype[] = "SHORT";
    const char mediumtype[] = "MEDIUM";
    const char longtype[] = "LONG";


    char dgaa_pos[10];
    char dgab_pos[10];

    lstatus =0;
    int fstatus = 0;
    fits_read_key(file_ptr,TSTRING,"DGAA_POS", &dgaa_pos, comment,&lstatus); 
    if(lstatus == 0) { 
      int pstatus = -1;
      pstatus = strncmp(dgaa_pos,shorttype,5);
      if(pstatus ==0) {
	fstatus = 1; 
	//	cout <<" DGAA is short" << endl;
	data_info.DGAA_POS.push_back(0);
      }  else { // check if medium 

	pstatus = -1;
	pstatus = strncmp(dgaa_pos,mediumtype,6);
	if(pstatus ==0) {
	  fstatus = 1; 
	  //	  cout <<" DGAA is medium" << endl;
	  data_info.DGAA_POS.push_back(1);
	} else { // check if long
	  
	  pstatus = -1;
	  pstatus = strncmp(dgaa_pos,longtype,4);
	  if(pstatus ==0) {
	    fstatus = 1; 
	    //	    cout <<" DGAA is long" << endl;
	    data_info.DGAA_POS.push_back(2);
	  }
	}
      }
    }


    if(fstatus ==0){
      //      cout << " DGAA_POS not found" << endl; 
    }else{
      data_info.DGAA_POS_FLAG = 1;
    }


    lstatus =0;
    fstatus = 0;
    fits_read_key(file_ptr,TSTRING,"DGAB_POS", &dgab_pos, comment,&lstatus);

    if(lstatus == 0) { 
      int pstatus = -1;
      pstatus = strncmp(dgab_pos,shorttype,5);
      if(pstatus ==0) {
	fstatus = 1; 
	//	cout <<" DGAB is short" << endl;
	data_info.DGAB_POS.push_back(0);
      }  else { // check if medium 

	pstatus = -1;
	pstatus = strncmp(dgab_pos,mediumtype,6);
	if(pstatus ==0) {
	  fstatus = 1; 
	  //	  cout <<" DGAB is medium" << endl;
	  data_info.DGAB_POS.push_back(1);
	} else { // check if long
	  

	  pstatus = -1;
	  pstatus = strncmp(dgab_pos,longtype,4);
	  if(pstatus ==0) {
	    fstatus = 1; 
	    //	    cout <<" DGAB is long" << endl;
	    data_info.DGAB_POS.push_back(2);
	  }
	}
      }
    }

    if(fstatus ==0){
      //      cout << " DGAB_POS not found " << endl; 
    }else{
      data_info.DGAB_POS_FLAG = 1;
    }
    
    // For simulated or STScI formatted data the DGAA DGAB keyword is stored in BAND keyword
    if(data_info.DGAA_POS_FLAG == 0 && data_info.DGAB_POS_FLAG == 0) {
     
      cout << " DGAA_POS and DGAB_POS  not found, trying BAND " << endl; 
      lstatus =0;
      fstatus = 0;
      char band[10];
      fits_read_key(file_ptr,TSTRING,"BAND", &band, comment,&lstatus);

      if(lstatus == 0) { 
	int pstatus = -1;
	pstatus = strncmp(band,shorttype,5);
	if(pstatus ==0) {
	  fstatus = 1; 
	  cout <<" BAND is short" << endl;
	  data_info.DGAB_POS.push_back(0);
	  data_info.DGAA_POS.push_back(0);
	  data_info.DGAB_POS_FLAG = 2;
	  data_info.DGAA_POS_FLAG = 2;

	}  else { // check if medium 

	  pstatus = -1;
	  pstatus = strncmp(band,mediumtype,6);
	  if(pstatus ==0) {
	    fstatus = 1; 
	    cout <<" BAND is medium" << endl;
	    data_info.DGAB_POS.push_back(1);
	    data_info.DGAA_POS.push_back(1);
	    data_info.DGAB_POS_FLAG = 2;
	    data_info.DGAA_POS_FLAG = 2;
	} else { // check if long
	    pstatus = -1;
	    pstatus = strncmp(band,longtype,4);
	    if(pstatus ==0) {
	      fstatus = 1; 
	      cout <<" BAND is long" << endl;
	      data_info.DGAB_POS.push_back(2);
	      data_info.DGAA_POS.push_back(2);
	      data_info.DGAB_POS_FLAG = 2;
	      data_info.DGAA_POS_FLAG = 2;
	    }
	  }
	}
      }
    }


    int GWA = 0;
    int GWB = 0;
    int USE_FILE = 0;
    int Wave_ID = 0;
    data_info.GWA.push_back(GWA);
    data_info.GWB.push_back(GWB);
    data_info.Use_File.push_back(USE_FILE);
    data_info.WAVE_ID.push_back(Wave_ID);

  }

  if(control.do_verbose == 1) cout << " Done mrs_read_input_list " << endl;

    return 0; // ifstream destructor closes the file
}

