// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//   ms_write_final_data.cpp
//
// Purpose:
//  Write the averaged final data to the primary image in the reduced data file.
//  If the number of integrations = 1, then the data in the first extension 
//   (processed 1st integration data) = that found in Primary image.
//  If the number of integrations > 1, then the Primary image is a average of
//  the results of all the processed integrations.  	
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
//void ms_write_final_data(int type,
//			 miri_data_info& data_info,
//			 vector<float> &Final_Slope,
//			 vector<float> &Final_SlopeUnc,
//			 vector<float> &Final_SlopeID)
//
//
// Arugments:
// 
//  type - flag = 0 science data, 1 reference output data 
//  data_info: miri_data_info structure containing basic information on the dataset
//  Final_Slope :vector of  averaged slopes
//  Final_SlopeUnc: vector of averaged slope uncertainties
//  Final_SlopeID: vector of merged data quality flags.

//
// Return Value/ Variables modified:
//      No return value.  
// 
//
// History:
//
//	Written by Jane Morrison 2007
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/

#include "fitsio.h"
#include "miri_sloper.h"
// open and setup the reduced FITS file: control.raw_bitsbase + ".red.fits";

void ms_write_final_data(int type,
			 fitsfile *file_ptr,
			 const long naxes[3],
			 const int QuickMethod,
			 miri_data_info& data_info,
			 vector<float> &Final_Slope,
			 vector<float> &Final_SlopeUnc,
			 vector<float> &Final_SlopeID)

{
  int status = 0;    // status of a cfitsio call
  // **********************************************************************
  // **********************************************************************

  
  // fitsfile *file_ptr=0;
  //long naxes[2] = {0};

  if(QuickMethod ==1) { 
    //    if(type ==0){ // Science Image
    //  file_ptr = data_info.red_file_ptr;
    //  naxes[0] = data_info.ramp_naxes[0];
    // naxes[1] = data_info.ramp_naxes[1];
    //}
    //if(type ==1){// reference image
    // file_ptr = data_info.red_ref_file_ptr;
    // naxes[0] = data_info.ref_naxes[0];
    // naxes[1] = data_info.ref_naxes[1];
    //}

    //naxes[2] = 1; // slope
    long num = Final_Slope.size();
    if(data_info.NInt > 1) { // take average - not need to if only 1 int - see ms_final_slope
      for (long i = 0; i < num ; i++){
	if(Final_SlopeUnc[i] != 0) {
	  Final_Slope[i] = Final_Slope[i]/Final_SlopeUnc[i];
	}else{
	  Final_Slope[i] =  strtod("NaN",NULL);
	}
      }
    }
    // _______________________________________________________________________
  // create an image for the reduced file- cube of data

  // _______________________________________________________________________
  // Loop through each subset of data and write out the subset to the fits file

    long tsize = naxes[0]*naxes[1];
    long nelements = tsize;

    vector<float> data(nelements);
    copy(Final_Slope.begin(),Final_Slope.end(),data.begin());
  
    int hdutype = 0;
    fits_movabs_hdu(file_ptr,1,&hdutype,&status);
    fits_write_img(file_ptr,TFLOAT,1,nelements,&data[0],&status);

  
    if(status != 0) {
      cout << " Problem Average Slope  " << endl;
      cout << " status " << status << endl;
      exit(EXIT_FAILURE);
    }
    //***********************************************************************
	// Standard  Science Pipeline

	// Write out 3 planes - standard
    } else { 

    //if(type ==0){ // Science Image
    //  file_ptr = data_info.red_file_ptr;
    //  naxes[0] = data_info.ramp_naxes[0];
    //  naxes[1] = data_info.ramp_naxes[1];
    // }
    //if(type ==1){// reference image
    //  file_ptr = data_info.red_ref_file_ptr;
    //  naxes[0] = data_info.ref_naxes[0];
    //  naxes[1] = data_info.ref_naxes[1];
    //}

    //naxes[2] = 3; // slope, uncertainty, id flag, zero pt, # good read,
                              // read num first sat
    long num_flag = 0;
    long num = Final_Slope.size();
    if(data_info.NInt > 1) { // take average - not need to if only 1 int - see ms_final_slope
      for (long i = 0; i < num ; i++){
	if(Final_SlopeUnc[i] != 0) {
	  Final_Slope[i] = Final_Slope[i]/Final_SlopeUnc[i];
	  Final_SlopeUnc[i] = sqrt(1.0/Final_SlopeUnc[i]);
	  
	}else{
	  Final_Slope[i] =  strtod("NaN",NULL);
	  Final_SlopeUnc[i] = strtod("NaN",NULL);
	}
	if(Final_SlopeID[i] !=0){
	  //cout << "final ID " << i << " " << Final_SlopeID[i] << endl;
	  num_flag++;
	}
      }
    }
    //    cout << " Final number of non zero ID " << num_flag << endl;
  
  // **********************************************************************
    // _______________________________________________________________________
  // create an image for the reduced file- cube of data


  // _______________________________________________________________________
  // Loop through each subset of data and write out the subset to the fits file

    long tsize = naxes[0]*naxes[1];
    long tsize2 = tsize*2;
    long nelements = tsize*3;

    vector<float> data(nelements);
    copy(Final_Slope.begin(),Final_Slope.end(),data.begin());
    copy(Final_SlopeUnc.begin(),Final_SlopeUnc.end(),data.begin() + tsize);
    copy(Final_SlopeID.begin(),Final_SlopeID.end(),data.begin() + tsize2);

    int hdutype = 0;
    fits_movabs_hdu(file_ptr,1,&hdutype,&status);
    fits_write_img(file_ptr,TFLOAT,1,nelements,&data[0],&status);
    
    if(status != 0) {
      cout << " Problem Average Slope  " << endl;
      cout << " status " << status << endl;
      exit(EXIT_FAILURE);
    }
  }

  //  cout << " Done writing Final Slope " << endl;
}
