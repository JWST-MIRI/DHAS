#include "miri_caler.h"
// open and setup the reduced FITS file: control.raw_bitsbase + ".red.fits";

void mc_write_calibrated_file(int i,
			      mc_control control,
			      mc_data_info& data_info,
			      string preference_filename,
			      vector<float> &Slope,
			      vector<float> &SlopeUnc,
			      vector<float> &SlopeID)


{
  int status = 0;    // status of a cfitsio call
  // **********************************************************************
  // **********************************************************************
  data_info.cal_naxis = 3;
  data_info.cal_naxes[0] = data_info.red_naxes[0];
  data_info.cal_naxes[1] = data_info.red_naxes[1];
  data_info.cal_naxes[2] = 3; // slope, uncertainity, id flag
  data_info.cal_bitpix = -32;

  // **********************************************************************
    // _______________________________________________________________________
  // create an image for the calibrated file- cube of data


  int hdutype = 0;
  fits_movabs_hdu(data_info.red_file_ptr,i+1,&hdutype,&status);

  status = 0;
  fits_create_img(data_info.cal_file_ptr, data_info.cal_bitpix, 
		  data_info.cal_naxis,data_info.cal_naxes, &status);
  if(status !=0) cout << " ms_write_calibrated_file: Problem creating image"<< endl;

  // _______________________________________________________________________
  // Only for Primary header
  // _______________________________________________________________________
  if(i == 0) { 
    char extname[15] = "FINAL CAL DATA";
    fits_write_key(data_info.cal_file_ptr,TSTRING,"EXTNAME",&extname," Extension Name ",&status);


    fits_write_comment(data_info.cal_file_ptr, 
		       "**==============================================================**",&status);
    fits_write_comment(data_info.cal_file_ptr, 
		       "**=begin Reduced file primary header================================**",&status);

    status = 0;
    miri_copy_header(data_info.red_file_ptr, data_info.cal_file_ptr, status);
  
    fits_write_comment(data_info.cal_file_ptr, 
		       "**=end Reduced file primary header==================================**",&status);
  }
  // _______________________________________________________________________
  else {
    char extname[17] = "CAL DATA FOR INT";
    fits_write_key(data_info.cal_file_ptr,TSTRING,"EXTNAME",&extname," Extension Name ",&status);

  }
  // _______________________________________________________________________

  // write a few values to header summarizing the ramp to slope processing (for this integration)

  mc_write_processing_to_header(data_info.cal_file_ptr,control,preference_filename,data_info);


  // _______________________________________________________________________
  // Loop through each subset of data and write out the subset to the fits fil
  int xsize = data_info.red_naxes[0];
  int ysize = data_info.red_naxes[1];

  long tsize = xsize*ysize;
  long tsize2 = tsize*2;

  long nelements = tsize*3;
  vector<float> data(nelements);

  copy(Slope.begin(),Slope.end(),data.begin());
  copy(SlopeUnc.begin(),SlopeUnc.end(),data.begin() + tsize);
  copy(SlopeID.begin(),SlopeID.end(),data.begin() + tsize2);


  fits_write_img(data_info.cal_file_ptr,TFLOAT,1,nelements,&data[0],&status);

  
  if(status != 0) {
    cout << " Problem writing Calibrated data " << endl;
    cout << " status " << status << endl;
    exit(EXIT_FAILURE);
  }

  //  cout << " Done writing calibrated file " << endl;
}
