// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//      ms_setup_reset
//
// Purpose:
// 
// If the entire reset was already read in (subset_number) = 0 then
// fill in reset to use
// If it has not been read in the read it in subset mode. 
// 	
//
//
// Author:
//
//	Jane Morrison
//      University of Arizona
//      email: morrison@as.arizona.edu
//      phone: 520-626-3181
// 
// Calling Sequence:

//
// Arugments:
//

// History:
//
//	Written by Jane Morrison 2013

#include <time.h>
#include <iostream>
#include <vector>
#include <string>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_constants.h"
#include "miri_sloper.h"
#include "miri_reset.h"


// converting 2-d  array to 1-d vector 
void PixelXY_PixelIndex(const int,const int , const int ,long &);

void ms_read_reset_file( const int integ,
		    miri_control &control,
		    miri_data_info &data_info,
		    miri_CDP &CDP,
		    vector<miri_reset> &reset)


{
  // Reset format:
  // Primary empty
  // SCI 1st ext
  // ERR 2nd ext
  // DQ 3rd ext
  
  // **********************************************************************
  // open the reset file - pull out data for integration 
  // a few variables for use in FITS I/O
  // As the data is read in ignore and reject data based on the following:
  // a. ignore an initial frames to be rejected (set by control.n_reads_start_fit)
  // b. ignore final frames to get rejected (determined by data_info.NRampsRead.
  //    data_info.NRampsRead = (control.n_reads_end_fit - control.n_reads_start_fit) + 1;

  //_______________________________________________________________________

  time_t t0; 
  t0 = time(NULL);

  long inc[4]={1,1,1,1};
  int anynul = 0;  // null values
  int status = 0;
  int hdutype = 0; 

  string reset_file = CDP.GetResetUseName();
  if(control.flag_reset_cor_file ==0) { // from CDP list add calibration directory
    reset_file= control.calib_dir+ reset_file;
  }   

  int nplanes = CDP.GetResetUseNPlanes();
  int max_int = CDP.GetResetMaxInt();
  int iplane = integ+1;


  if(iplane > max_int) iplane = max_int;
 
  cout << " Reset Calibration file name (integration) " << reset_file << " " << iplane <<  endl;
  //cout << " nplanes " << nplanes << endl;

  ifstream Reset_file(reset_file.c_str());
  if (!Reset_file) {
    cout << " Reset  Calibration file  does not exist" << reset_file << endl;
    cout << " Run again and either correct filename or run with -r option (no Reset  correction)" << endl;
    exit(EXIT_FAILURE);
  }


  status  = 0;
  fitsfile *file_ptr;   
  fits_open_file(&file_ptr, reset_file.c_str(), READONLY, &status);   // open the file
  if(status !=0) {
    cout << " Failed to open  Reset Calibration fits file: " <<reset_file << endl;
    cout << " Reason for failure, status = " << status << endl;
    exit(EXIT_FAILURE);
  }



  fits_movabs_hdu(file_ptr,2,&hdutype,&status); // One for primary array      
  if(status !=0) {
    cout <<" Error in moving to Reset Extension " << endl;
    exit(EXIT_FAILURE);
  }
    char comment[72];
  status = 0;
  long naxes1 = 0;
  fits_read_key(file_ptr, TLONG, "NAXIS1", &naxes1, comment, &status); // get the x size
  if(status !=0 ) cout << "ms_setup_reset:  Problem reading naxis1 of Reset Correction image " << endl;

  long naxes2 = 0;
  fits_read_key(file_ptr, TLONG, "NAXIS2", &naxes2, comment, &status); // get they  size
  if(status !=0 ) cout << "ms_setup_reset:  Problem reading naxis2 of Reset Correction image " << endl;

  long naxes3 = 0;
  fits_read_key(file_ptr, TLONG, "NAXIS3", &naxes3, comment, &status); // get the nplanes
  if(status !=0 ) cout << "ms_setup_reset:  Problem reading naxis3 of Reset Correction image " << endl;

  long naxes4 = 0;
  fits_read_key(file_ptr, TLONG, "NAXIS4", &naxes4, comment, &status); // get the nplanes
  if(status !=0 ) cout << "ms_setup_reset:  Problem reading naxis4 of Reset Correction image " << endl;


  //***********************************************************************
  //  cout << " Reset size " << naxes1 << " " << naxes2 << " " << naxes3 << " " << naxes4 << endl;
  status = 0;
  long fpixel[4] ;
  long lpixel[4];

  int istart = control.n_reads_start_fit;
  
  // read in all the frames for the current integration
  fpixel[2]=istart +1;

  // lower left corner of subset
  fpixel[0]= 1;
  fpixel[1]= 1;
  fpixel[2]= istart+1;
  fpixel[3]= iplane;

  int end_frame = fpixel[2] + data_info.NRampsRead-1;
  if(end_frame > naxes3-1) end_frame = naxes3;

  // number of rows of data to read in  
  lpixel[0] = naxes1;
  lpixel[1] = naxes2;
  lpixel[2] = end_frame;
  lpixel[3]= iplane;


  //    cout << " first pixel " << fpixel[0] << " " << fpixel[1] << " " << fpixel[2] << " " << fpixel[3] << endl;
  //cout << " last  pixel " << lpixel[0] << " " << lpixel[1] << " " << lpixel[2] << " " << lpixel[3] <<  endl;

  
  long ixyz =nplanes*naxes1*naxes2;
  long ixy = naxes1*naxes2;

  vector<float>  data(ixyz);
  status = 0;
  fits_read_subset(file_ptr,TFLOAT,
		   fpixel,lpixel,
		   inc,0, 
		   &data[0], &anynul, &status);

  if(status != 0 ) {
    cout << " Problem reading Data Plane from Reset File  " << reset_file << " " << status << endl;
    exit(EXIT_FAILURE);
  }

  long ik =0;
  for (register int k = 0; k < naxes2 ; k++){
    for (register int j = 0; j< naxes1 ; j++,ik++){
      for (int iplanes = 0; iplanes < nplanes ; iplanes++) {// number of frames
      
      long ielement = iplanes*ixy + k*naxes1 + j;
      float reset_value = data[ielement];
      reset[ik].SetResetValue(reset_value);

      }
    }
  }
  //_______________________________________________________________________
  // read in the DQ for the reset - single plane (same for all integrations) 


  hdutype =0;
  status  = 0; 

  fits_movabs_hdu(file_ptr,4,&hdutype,&status);

  if(status !=0) {
    cout <<" Error moving to  Reset DQ extension" << endl;
    exit(EXIT_FAILURE);
  }

  long fpixel2[2] ;
  long lpixel2[2];

    // lower left corner of subset
  fpixel2[0]= 1;
  fpixel2[1]= 1;


    // number of rows of data to read in  
  lpixel2[0] = naxes1;
  lpixel2[1] = naxes2;


  //    cout << " first pixel " << fpixel2[0] << " " << fpixel2[1]  << endl;
  //cout << " last  pixel " << lpixel2[0] << " " << lpixel2[1] << endl;
  //cout << " Going to read  Reset DQ Plane " << endl;

  long inc2[2]={1,1};
  vector<short>  idata(ixy); 
  status = 0;
  fits_read_subset(file_ptr,TSHORT,
		   fpixel2,lpixel2,
		   inc2,0, 
		   &idata[0], &anynul, &status);


  if(status != 0 ) {
    cout << " Problem reading DQ Plane from Reset   " << reset_file << " " << status << endl;
    exit(EXIT_FAILURE);
  }

  ik =0;
  for (register int k = 0; k < naxes2 ; k++){
    for (register int j = 0; j< naxes1 ; j++,ik++){
      short dq = idata[ik];
      reset[ik].SetResetDQ(dq);
    }
    
  }

  fits_close_file(file_ptr,&status);

  
  time_t tp; 
  tp = time(NULL);
  if(control.do_verbose_time == 1) cout << " Total Elapsed time read in reset  " << tp - t0 << endl;

  // ***********************************************************************

  if(control.do_verbose)   cout << " Done reading in subset of reset  data " <<endl;
}
