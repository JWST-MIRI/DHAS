// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//      ms_setup_dark
//
// Purpose:
// 
// If the entire dark was already read in (subset_number) = 0 then
// fill in dark to use
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
#include "miri_dark.h"


// converting 2-d  array to 1-d vector 
void PixelXY_PixelIndex(const int,const int , const int ,long &);

void ms_setup_dark( const int integ,
		    const int isubset,
		    const int this_nrow,
		    miri_control &control,
		    miri_data_info &data_info,
		    miri_CDP &CDP,
		    vector<miri_dark> &dark)


{
  // Dark format:
  // Primary empty
  // SCI 1st ext
  // ERR 2nd ext
  // FITERR 3rd ext
  // DQ 4th ext
  
  // **********************************************************************
  // open the dark file - pull out subset
  // a few variables for use in FITS I/O
  // As the data is read in ignore and reject data based on the following:
  // a. ignore an initial frames to be rejected (set by control.n_reads_start_fit)
  // b. ignore final frames to get rejected (determined by data_info.NRampsRead.
  //    data_info.NRampsRead = (control.n_reads_end_fit - control.n_reads_start_fit) + 1;
  //    From ms_setup_processing.cpp

  //       

  //_______________________________________________________________________

  time_t t0; 
  t0 = time(NULL);

  long inc[4]={1,1,1,1};
  int anynul = 0;  // null values
  int status = 0;
  int hdutype = 0; 

  string dark_file = CDP.GetDarkUseName( );
  if(control.flag_dark_cor_file ==0) { // from CDP list add calibration directory
    dark_file= control.calib_dir+ dark_file;
  }   

  //  cout << " Reading Subset of  Dark Calibration file name " << dark_file << endl;
  ifstream Dark_file(dark_file.c_str());
  if (!Dark_file) {
    cout << " Dark  Calibration file  does not exist" << dark_file << endl;
    cout << " Run again and either correct filename or run with -D option (no Dark  correction)" << endl;
    exit(EXIT_FAILURE);
  }


  status  = 0;
  fitsfile *file_ptr;   
  fits_open_file(&file_ptr, dark_file.c_str(), READONLY, &status);   // open the file
  if(status !=0) {
    cout << " Failed to open  Dark Calibration fits file: " <<dark_file << endl;
    cout << " Reason for failure, status = " << status << endl;
    exit(EXIT_FAILURE);
  }


  char comment[72];
  status = 0;
  long nframes_dark = 0;


  fits_movabs_hdu(file_ptr,2,&hdutype,&status); // One for primary array      
  if(status !=0) {
    cout <<" Error in moving to Dark Extension " << endl;
    exit(EXIT_FAILURE);
  }

  status = 0;
  long naxes0 = 0;
  fits_read_key(file_ptr, TLONG, "NAXIS1", &naxes0, comment, &status); // get the x size
  if(status !=0 ) cout << "ms_setup_dark:  Problem reading naxis1 of Mean Dark Residual " << endl;

  long naxes1 = 0;
  fits_read_key(file_ptr, TLONG, "NAXIS2", &naxes1, comment, &status); // get the ysize
  if(status !=0 ) cout << "ms_setup_dark:  Problem reading naxis2 of Mean Dark Residual " << endl;

  long naxes2 = 0;
  fits_read_key(file_ptr, TLONG, "NAXIS3", &naxes2, comment, &status); // 
  if(status !=0 ) cout << "ms_setup_dark:  Problem reading naxis3 of Mean Dark Residual " << endl;

  long naxes3 = 0;
  fits_read_key(file_ptr, TLONG, "NAXIS4", &naxes3, comment, &status); // 
  if(status !=0 ) cout << "ms_setup_dark:  Problem reading naxis3 of Mean Dark Residual " << endl;


  nframes_dark  = naxes2;


  //***********************************************************************

  status = 0;
  long fpixel[4] ;
  long lpixel[4];

  // lower left corner of subset
  fpixel[0]= 1;
  fpixel[1]= (isubset * data_info.subset_nrow) + 1;

  // number of rows of data to read in  
  lpixel[0] = naxes0;
  lpixel[1] = fpixel[1] + this_nrow-1;

  int xsize = naxes0;
  int istart = control.n_reads_start_fit;
  int int_use = integ;
  if(int_use >= naxes3)  int_use = naxes3-1;
  if(isubset == 0) cout << " Using dark integration "  << int_use + 1 << "  Max dark integration " << naxes3 <<  endl;

  fpixel[3] = int_use+1;
  lpixel[3] = fpixel[3];

  fpixel[2]=istart +1 ;

  int end_frame = fpixel[2] + data_info.NRampsRead-1;
  if(end_frame > naxes2-1) end_frame = naxes2;
  lpixel[2] = end_frame;


  int nplanes = lpixel[2] - fpixel[2] + 1;
  // cout<< "dark region " << endl;
  //cout << " first pixel " << fpixel[0] << " " << fpixel[1] << " " << fpixel[2] << " " <<fpixel[3]<< endl;
  //cout << " last  pixel " << lpixel[0] << " " << lpixel[1] << " " << lpixel[2] <<  " " << lpixel[3] <<endl;
  //cout << " nplanes " << nplanes << endl;

  CDP.SetDarkUseNPlanes(nplanes);


  long ixyz =nplanes*this_nrow*xsize;
  long ixy = this_nrow*xsize;

  vector<float>  data(ixyz);
  status = 0;

  fits_read_subset(file_ptr,TFLOAT,
		   fpixel,lpixel,
		   inc,0, 
		   &data[0], &anynul, &status);

  if(status != 0 ) {
    cout << " Problem reading Data Plane from Dark File  " << dark_file << " " << status << endl;
    exit(EXIT_FAILURE);
  }


  long ik =0;
  for (register int k = 0; k < this_nrow ; k++){
    for (register int j = 0; j< xsize ; j++,ik++){
    for (int iplanes = 0; iplanes < nplanes ; iplanes++) {
      long ielement = iplanes*ixy + k*xsize + j;
      float dark_value = data[ielement];
      dark[ik].SetDarkValue(dark_value);
      }
    }
  }


  //_______________________________________________________________________
  // read in the DQ for the dark

  hdutype =0;
  status  = 0; 

  fits_movabs_hdu(file_ptr,4,&hdutype,&status);

  if(status !=0) {
    cout <<" Error moving to  Dark DQ extension" << endl;
    exit(EXIT_FAILURE);
  }
  

  long inc2[4]={1,1,1,1};
  long fpixel2[4] ;
  long lpixel2[4];

    // lower left corner of subset
  fpixel2[0]= 1;
  fpixel2[1]= (isubset * data_info.subset_nrow) + 1;


    // number of rows of data to read in  
  lpixel2[0] = naxes0;
  lpixel2[1] = fpixel2[1] + this_nrow-1;

  fpixel2[2] = 1;
  lpixel2[2] = 1;

  int int_use2 = integ;
  //  if(int_use2 > 1)  int_use2 = 1;
  if(int_use2 >= naxes3)  int_use2 = naxes3-1;

  fpixel2[3] = int_use2+1;
  lpixel2[3] = fpixel[3];
  //  cout << " first pixel " << fpixel2[0] << " " << fpixel2[1]  << endl;
  //cout << " last  pixel " << lpixel2[0] << " " << lpixel2[1] << endl;
  //cout << " Going to read  Dark DQ Plane " << endl;


  vector<short>  idata(ixy); 
  status = 0;
  fits_read_subset(file_ptr,TSHORT,
		   fpixel2,lpixel2,
		   inc2,0, 
		   &idata[0], &anynul, &status);

  if(status != 0 ) {
    cout << " Problem reading DQ Plane from Dark   " << dark_file << " " << status << endl;
    exit(EXIT_FAILURE);
  }


  ik =0;
  for (register int k = 0; k < this_nrow ; k++){
    for (register int j = 0; j< xsize ; j++,ik++){
      int dq = idata[ik];
      dark[ik].SetDarkDQ(dq);
    }
  }


  fits_close_file(file_ptr,&status);

  time_t tp; 
  tp = time(NULL);
  if(control.do_verbose_time == 1) cout << " Total Elapsed time read in dark  " << tp - t0 << endl;

  // ***********************************************************************

  if(control.do_verbose)   cout << " Done reading in subset of dark  data " <<endl;
}
