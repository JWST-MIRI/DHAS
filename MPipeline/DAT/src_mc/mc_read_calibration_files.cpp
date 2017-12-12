#include <iostream>
#include <sstream> 
#include <vector>
#include <string>
#include <time.h>
#include "fitsio.h"
#include "mc_data_info.h"
#include "mc_control.h"
#include "mc_preference.h"
#include "miri_caler.h" 
#include "miri_constants.h" 
void PixelXY_PixelIndex(const int,const int , const int ,long &);
int Check_CDPfile(string filename);


int mc_read_calibration_files(mc_preference preference,
			       mc_control &control,
			       mc_data_info& data_info)

{
  // **********************************************************************
  // This routine does the following:
  // If control.apply_background is set, then read in background calibration data.
  // If control.apply_flat is set, then read in flat calibration data.


  int xsize = 1032; // full array 
//_______________________________________________________________________

// initialize the data

  int return_status = 0;
  int anynul = 0;
  int hdutype = 0;
  long total_elements = data_info.red_naxes[0] * data_info.red_naxes[1];
  for (long k = 0; k< total_elements; k++){
    data_info.background.push_back(0.0);
    data_info.flat.push_back(1.0);
  }

  
//_______________________________________________________________________
  // read in background Image - of type LVL2 or LVL3 
//_______________________________________________________________________

  if ( control.apply_background== 1) {
    string background_filename = "null";


    if(control.flag_background_file == 1){ // set by user
      background_filename = control.background_file;
    }

    cout << "  Reading Background Image " << background_filename << endl;
    int status  = 0;
    fitsfile *fptr;   
    fits_open_file(&fptr, background_filename.c_str(), READONLY, &status);   // open the file
    if(status !=0) {
      cout << " Failed to open background fits file: " << background_filename << endl;
      cout << " Does this file exist ?  " << endl;
      cout << " Reason for failure, status = " << status << endl;
      exit(EXIT_FAILURE);
    }
    fits_movabs_hdu(fptr,1,&hdutype,&status);

    char comment[72];
    status = 0;
    fits_read_key(fptr, TLONG, "NAXIS1", &data_info.background_naxes[0], comment, &status); // get the size
    if(status !=0 ) cout << "mc_read_calibraton_files:  Problem reading naxis[0] of background image " << endl;
    status = 0;
    fits_read_key(fptr, TLONG, "NAXIS2", &data_info.background_naxes[1], comment, &status); // of the data
    if(status !=0 ) cout << "mc_read_calibration_files:  Problem reading naxis[1] of background image " << endl;
    

    status = 0;
    long nelements = data_info.background_naxes[0] * data_info.background_naxes[1];
    vector<float>  data(nelements); 
    status = 0;
    anynul = 0;
    fits_read_img(fptr,TFLOAT,1,nelements,0,&data[0],&anynul,&status);
    if(status != 0 ) {
      cout << " Problem reading background  file " << control.background_file << " " << status << endl;
      exit(EXIT_FAILURE);
    }

    fits_close_file(fptr,&status);

      data_info.background.assign(data.begin(),data.end());
    if(data_info.background_naxes[0] != data_info.red_naxes[0] || data_info.background_naxes[1] != data_info.red_naxes[1]){
      cout << "The size of the background image you are subtracting is not the same size and science image" << endl;
      cout << " Size of Science Image " << data_info.red_naxes[0] << " by " << 
	data_info.red_naxes[1] << endl;
      cout  << " Size of Backgound imgage " << data_info.background_naxes[0] << " by " <<
	data_info.background_naxes[1] << endl;
      exit(EXIT_FAILURE);
    }
  } // end if control.apply_background

  //_______________________________________________________________________
  // read in  PIXEL flat  calibration file
//_______________________________________________________________________
  if ( control.apply_flat== 1) {

    string flat_filename = "null";

    if(control.flag_flat_file == 1){ // set by user
      flat_filename = control.flat_file;
    }
    cout << "  Reading Flat calibration file " << flat_filename << endl;
    
    int status  = 0;
    status = Check_CDPfile(flat_filename); 
    if(status !=0 ) {
      cout << " Program exiting, check file " << flat_filename << endl;
      cout << " If calibration data is from VM, then the file needs to be converted to the CDP standard format" << endl;

      exit(EXIT_FAILURE);
    }

    fitsfile *fptr;   
    fits_open_file(&fptr, flat_filename.c_str(), READONLY, &status);   // open the file
    if(status !=0) {
      cout << " Failed to open flat fits file: " << flat_filename << endl;
      cout << " Reason for failure, status = " << status << endl;
      cout << " Does this file exist ?  " << endl;
      exit(EXIT_FAILURE);
    }

    fits_movabs_hdu(fptr,2,&hdutype,&status);
    char comment[72];
    status = 0;
    fits_read_key(fptr, TLONG, "NAXIS1", &data_info.flat_naxes[0], comment, &status); // get the size
    if(status !=0 ) cout << "mc_read_calibration_files:  Problem reading naxis[0] of flat image " << endl;
    status = 0;
    fits_read_key(fptr, TLONG, "NAXIS2", &data_info.flat_naxes[1], comment, &status); // of the data
    if(status !=0 ) cout << "mc_read_calibration_files:  Problem reading naxis[1] of flat image " << endl;
    

    status = 0;
    long nelements = data_info.flat_naxes[0] * data_info.flat_naxes[1];
    vector<float>  data(nelements); 
    status = 0;
    anynul = 0;
    fits_read_img(fptr,TFLOAT,1,nelements,0,&data[0],&anynul,&status);
    if(status != 0 ) {
      cout << " Problem reading Flat Calibration file " << control.flat_file << " " << status << endl;
      exit(EXIT_FAILURE);
    }

    fits_close_file(fptr,&status);

    data_info.flat.assign(data.begin(),data.end());



    if(data_info.flat_naxes[0] != data_info.red_naxes[0] || data_info.flat_naxes[1] != data_info.red_naxes[1]){

      cout << " This is Subarray Data, going to pull out the region in the Full frames Flat that matches the subarray region " << endl;

      vector<float> flat;

      for (int i = 0; i< data_info.red_naxes[1] ; i++){
	int istart = (data_info.RowStart) + i;
	for (int j = 0; j < data_info.red_naxes[0] ; j++){
	  int jstart = (data_info.ColStart) + j;
	  long pixel_index = -1;

	  PixelXY_PixelIndex(xsize,
			     jstart,istart,
			     pixel_index);

	  float ps = data_info.flat[pixel_index];
	  flat.push_back(ps);
	}

      }

      data_info.flat.erase(data_info.flat.begin(),data_info.flat.end());
      for (unsigned long i = 0; i< flat.size();i++) {
	data_info.flat.push_back(flat[i]);
      }
    }


 
  } // end if control.apply_flat


  //_______________________________________________________________________

  //_______________________________________________________________________
  // read in fringe flat  calibration file

  if ( control.apply_fringe_flat== 1) {


    string fringe_filename = "null";

    if(control.flag_fringe_file == 1){ // set by user
      fringe_filename = control.fringe_file;
    }

    cout << "  Reading Fringe Flat calibration file " << fringe_filename << endl;
    
    int status  = 0;
    status = Check_CDPfile(fringe_filename); 
    if(status !=0 ) {
      cout << " Program exiting, check file " << fringe_filename << endl;
      cout << " If calibration data is from VM, then the file needs to be converted to the CDP standard format" << endl;
      exit(EXIT_FAILURE);
    }
    fitsfile *fptr;   
    fits_open_file(&fptr, fringe_filename.c_str(), READONLY, &status);   // open the file
    if(status !=0) {
      cout << " Failed to open fringe flat fits file: " << fringe_filename << endl;
      cout << control.fringe_file << endl;
      cout << " Reason for failure, status = " << status << endl;
      cout << " Filter ID " << data_info.FILTER << endl;
      cout << " Does this file exist ?  " << endl;
      exit(EXIT_FAILURE);
    }

    fits_movabs_hdu(fptr,2,&hdutype,&status);
    char comment[72];
    status = 0;
    fits_read_key(fptr, TLONG, "NAXIS1", &data_info.fringe_flat_naxes[0], comment, &status); // get the size
    if(status !=0 ) cout << "mc_read_calibration_files:  Problem reading naxis[0] of fringe flat image " << endl;
    status = 0;
    fits_read_key(fptr, TLONG, "NAXIS2", &data_info.fringe_flat_naxes[1], comment, &status); // of the data
    if(status !=0 ) cout << "mc_read_calibration_files:  Problem reading naxis[1] of fringe flat image " << endl;
    

    status = 0;
    long nelements = data_info.fringe_flat_naxes[0] * data_info.fringe_flat_naxes[1];
    vector<float>  data(nelements); 
    status = 0;
    anynul = 0;
    fits_read_img(fptr,TFLOAT,1,nelements,0,&data[0],&anynul,&status);
    if(status != 0 ) {
      cout << " Problem reading fringe flag Calibration file " << control.fringe_file << " " << status << endl;
      exit(EXIT_FAILURE);
    }

    fits_close_file(fptr,&status);

    // 1032 X 1024 
    data_info.fringe_flat.assign(data.begin(),data.end()); // fringe flats are only with MRS- always full array

    if(data_info.fringe_flat_naxes[0] != data_info.red_naxes[0] || 
       data_info.fringe_flat_naxes[1] != data_info.red_naxes[1]){
      cout << " You are trying to apply a fringe flat to Subarray data or data that not the same size a Fringe Flat" << endl;
      exit(EXIT_FAILURE);
    } 

	
 
  } // end if control.apply_fringe_flat

    

  if (control.do_verbose == 10) cout << "end of ms_read_calibration_files   " << endl;
  
  return return_status;
}

