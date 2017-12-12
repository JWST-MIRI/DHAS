#include <iostream>
#include <sstream> 
#include <vector>
#include <string>
#include <time.h>
#include "fitsio.h"
#include "mc_data_info.h"
#include "mc_control.h"
#include "miri_caler.h" 
#include "miri_constants.h" 



void mc_read_data(const int i , 
		  mc_data_info &data_info,
		  vector<float> &Slope,
		  vector<float> &SlopeUnc,
		  vector<float> &SlopeID)

{
  // **********************************************************************
 

//_______________________________________________________________________

  int hdutype = 0;
  int status = 0;
  int anynul = 0;

  fits_movabs_hdu(data_info.red_file_ptr,i+1,&hdutype,&status);

  long nelements = data_info.red_naxes[0] * data_info.red_naxes[1] * data_info.red_naxes[2];
  if(i == 0) nelements = data_info.red_naxes[0] * data_info.red_naxes[1] * 3;
  vector<float>  data(nelements); 
  status = 0;
  fits_read_img(data_info.red_file_ptr,TFLOAT,1,nelements,0,&data[0],&anynul,&status);
  if(status != 0 ) {  
    cout << " Failed to read in data " << status <<  endl; 
  }
  int xsize = data_info.red_naxes[0];
  int ysize = data_info.red_naxes[1];
  long tsize = xsize*ysize;

  long tsize2 = tsize*2;
  long tsize3 = tsize*3;
  
  copy(data.begin(),data.begin() + tsize-1,Slope.begin());
  copy(data.begin()+tsize,data.begin()+ tsize2-1,SlopeUnc.begin());
  copy(data.begin()+tsize2, data.begin()+tsize3-1,SlopeID.begin());
      

}

