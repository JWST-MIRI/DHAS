// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
// ms_write_intermediate_data.cpp
//
// Purpose:
// 	If the -OR option is used then the pixel data after the referenced pixel and
//      reference output corrections have been applied are written out to a FITS file.
// 	If the -OI option is set then the data quality flag of a pixel for each
//      frame is written out to a FITS file
//      data flag (see miri_constants for an up to data list 
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
//void ms_write_intermediate_data(  const int write_output_refpixel_corrections,
//				 const int write_output_ids,
//				 const int write_output_lc_correction,
//				  const int iter,
//				 const int isubset,
//				 const int this_nrow,
//				 const int ramp_start,
//				 miri_data_info &data_info,
//				 vector<miri_pixel> &pixel)
//
//
// Arugments:
//
//  write_output_refpixel: -OR option set, write reference corrected data
//  write_output_ids: -OI option set, write ID frame data
//  write_output_lc_correction: write linearity corrected data 
//  iter: current iteration
//  isubset: current subset being processed
//  this_nrow: number of rows in the subset
//  ramp_start: frame number to start fit on (ignore frames before this)
//  data_info: miri_data_info structure containing basic information on the dataset
//  pixel: miri_pixel class holding information on each pixel 
//
//
// Return Value/ Variables modified:
//      No return value.  
// 
//
// History:
//
//	Written by Jane Morrison 8/17/2009 - replaced ms_write_refcorrected_data and ms_write_ids
//      Written to speed code up if -OR and -OI are set
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/
#include <iostream>
#include <vector>
#include <string>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_pixel.h"


void ms_write_intermediate_data( const int write_output_refpixel_corrections,
				 const int write_output_ids,
				 const int write_output_lc_correction,
				 const int write_output_dark_correction,
				 const int subtract_dark,
				 const int write_output_reset_correction,
				 const int write_output_lastframe_correction,
				 const int write_output_rscd_correction,
				 const int iter,
				 const int isubset,
				 const int this_nrow,
				 const int ramp_start,
				 miri_data_info &data_info,
				 vector<miri_pixel> &pixel)



{
  
  // **********************************************************************
  //       

  //cout << " Writing intermediate  data " << endl; 

  int status = 0;
  int naxis = 3;
  long naxes[3];
  naxes[0] = data_info.ramp_naxes[0];
  naxes[1] = data_info.ramp_naxes[1];
  naxes[2] = data_info.raw_naxes[2];


  long fpixel[3] ;
  long lpixel[3];

  long fpixel2[2] ;
  long lpixel2[2];

  // lower left corner of subset
  fpixel[0]= 1;
  fpixel[1]= (isubset * data_info.subset_nrow) + 1;

  fpixel2[0]= fpixel[0];
  fpixel2[1]= fpixel[1];

  // number of rows of data to read in  
  lpixel[0] = data_info.ramp_naxes[0];
  lpixel[1] = fpixel[1] + this_nrow-1;

  lpixel2[0]= lpixel[0];
  lpixel2[1]= lpixel[1];
  
  int xsize = data_info.ramp_naxes[0];
  int istart = iter*data_info.NRamps+ ramp_start;
  
  // read in all the frames for the current integration
  fpixel[2]=istart +1;
  lpixel[2]=fpixel[2] + data_info.NRampsRead-1;    


  //cout << " first pixel " << fpixel[0] << " " << fpixel[1] << " "<< fpixel[2] << endl;
  //cout << " last pixel " << lpixel[0] << " " << lpixel[1] << " " <<lpixel[2] << endl;
  long ixy = this_nrow*xsize;
  long ixyz =data_info.NRampsRead*this_nrow*xsize;
  long irxyz = ixyz;
  long iixyz = ixyz;
  long ilxyz = ixyz;
  long idxyz = ixyz;
  long irsxyz = ixyz;
  long itxyz = ixyz;


  if(write_output_refpixel_corrections == 0) irxyz = 1;
  if(write_output_ids== 0) iixyz = 1;
  if(write_output_lc_correction== 0)  ilxyz = 1;

  if(write_output_dark_correction== 0) idxyz = 1;
  if(write_output_reset_correction== 0) itxyz = 1;
  if(write_output_rscd_correction== 0) irsxyz = 1;
  if(write_output_lastframe_correction== 0) ixy = 1;
  
  vector<float>  data(irxyz); // reference pixel correction
  vector<int>   idata(iixyz); // ids 
  vector<float> cdata(ilxyz); // linearity correction
  vector<float> ddata(idxyz); // dark correction
  vector<float> rscddata(irsxyz); // rscd correction
  vector<float> rdata(itxyz); // reset correction
 vector<float> ldata(ixy); //last frame correction


  long ip = 0;
  long ik =0;
  long ii = 0; 

  for (int m = 0; m < data_info.NRampsRead; m++){
    ik =0;
    for (register int k = 0; k < this_nrow ; k++){
      for (register int j = 0; j< xsize ; j++){
	
	if(write_output_refpixel_corrections ==1) {
	  float RampPt = pixel[ik].GetRefData(m);
	  data[ip] = (RampPt);
	}
	if(write_output_ids ==1){
	  short IDPt = -1;
	  IDPt = pixel[ik].GetIDData(m);
	  idata[ip] = int(IDPt);
	}

	if(write_output_lc_correction ==1){
	  float Cdata = pixel[ik].GetLinData(m);
	  cdata[ip] = Cdata;
	}

	if(write_output_dark_correction ==1 && subtract_dark == 1) {
	  float dcorr = pixel[ik].GetDarkData(m);
	  ddata[ip] = (dcorr);
	}

	if(write_output_reset_correction ==1) {
	  float rcorr = pixel[ik].GetResetData(m);
	  rdata[ip] = (rcorr);
	  //	  cout << ik << " " << rdata[ip] << endl;
	}


	if(write_output_rscd_correction ==1) {
	  float rcorr = pixel[ik].GetRSCDData(m);
	  rscddata[ip] = (rcorr);
	  

	}

	// only if on last frame

	if( write_output_lastframe_correction == 1  && m == data_info.NRampsRead-1) {
	  float lcorr = pixel[ik].GetLastFrameData();
	  //int pix_x = pixel[ik].GetX();
	  //int pix_y = pixel[ik].GetY();
	  //if(pix_x == 500 && pix_y == 500)  cout << "in write" << j+1 << " " << k+1 << " " << lcorr << endl;
	  ldata[ii] = lcorr; 
	  ii++;	
	}

	ip++;
	ik++;
      }
    }
  }
  //_______________________________________________________________________
  status = 0;
  if(write_output_refpixel_corrections ==1) {
    int hdutype = 0;
    fits_movabs_hdu(data_info.rc_file_ptr,1,&hdutype,&status);
    fits_write_subset(data_info.rc_file_ptr, TFLOAT, 
			  fpixel,lpixel,
			  &data[0], &status);

    if(status != 0) {
      cout <<" ms_write_intermediate_data: Problem writing reference corrected  data " << isubset << endl;
      cout << " status " << status << endl;
      exit(EXIT_FAILURE);
    }
  }



  //_______________________________________________________________________
  status = 0;
  if(write_output_dark_correction ==1 && subtract_dark == 1) {

    int hdutype = 0;
   
    fits_movabs_hdu(data_info.dark_file_ptr,1,&hdutype,&status);
    fits_write_subset(data_info.dark_file_ptr,TFLOAT, 
			  fpixel,lpixel,
			  &ddata[0], &status);

    if(status != 0) {
      cout <<" ms_write_intermediate_data: Problem writing dark corrected  data " << isubset << endl;
      cout << " status " << status << endl;
      exit(EXIT_FAILURE);
    }
  }


  //_______________________________________________________________________

  //_______________________________________________________________________
  status = 0;
  if(write_output_reset_correction ==1) {
    int hdutype = 0;
    fits_movabs_hdu(data_info.reset_file_ptr,1,&hdutype,&status);
    fits_write_subset(data_info.reset_file_ptr,TFLOAT, 
			  fpixel,lpixel,
			  &rdata[0], &status);

    if(status != 0) {
      cout <<" ms_write_intermediate_data: Problem writing reset corrected  data " << isubset << endl;
      cout << " status " << status << endl;
      exit(EXIT_FAILURE);
    }
  }


  //_______________________________________________________________________
  status = 0;
  if(write_output_rscd_correction ==1) {
    int hdutype = 0;
    fits_movabs_hdu(data_info.rscd_file_ptr,1,&hdutype,&status);
    fits_write_subset(data_info.rscd_file_ptr,TFLOAT, 
			  fpixel,lpixel,
			  &rscddata[0], &status);

    if(status != 0) {
      cout <<" ms_write_intermediate_data: Problem writing rscd corrected  data " << isubset << endl;
      cout << " status " << status << endl;
      exit(EXIT_FAILURE);
    }
  }

  //_______________________________________________________________________
  status = 0;

  if(write_output_lastframe_correction ==1) {

    fits_write_subset(data_info.lastframe_file_ptr,TFLOAT, 
			  fpixel2,lpixel2,
			  &ldata[0], &status);


    if(status != 0) {
      cout <<" ms_write_intermediate_data: Problem writing last corrected  data " << isubset << endl;
      cout << " status " << status << endl;
      exit(EXIT_FAILURE);
    }
  }

  //_______________________________________________________________________
  status = 0;
  if(write_output_ids ==1){
    int hdutype = 0;
    fits_movabs_hdu(data_info.id_file_ptr,1,&hdutype,&status);
    fits_write_subset_int(data_info.id_file_ptr, 0, naxis, naxes, 
			  fpixel,lpixel,
			  &idata[0], &status);

    if(status != 0) {
      cout <<" ms_write_intermediate_data: Problem writing IDs data " << isubset << endl;
      cout << " status " << status << endl;
      exit(EXIT_FAILURE);
    }

  }
  //_______________________________________________________________________
  status = 0;
  if(write_output_lc_correction ==1) {

    int hdutype = 0;
    fits_movabs_hdu(data_info.lc_file_ptr,1,&hdutype,&status);
    fits_write_subset(data_info.lc_file_ptr,TFLOAT, 
			  fpixel,lpixel,
			  &cdata[0], &status);


    if(status != 0) {
      cout <<" ms_write_intermediate_data: Problem writing linearity corrected  data " << isubset << endl;
      cout << " status " << status << endl;
      exit(EXIT_FAILURE);
    }


  }

}
