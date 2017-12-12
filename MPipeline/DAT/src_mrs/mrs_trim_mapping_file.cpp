#include <iostream>
#include <string>
#include <vector>
#include <cmath>
#include <algorithm>
#include <cstdlib> // EXIT_FAILURE   , EXIT_SUCCESS
#include "fitsio.h"
#include "mrs_data_info.h"
// The overlap mapping file is written out seperatly for each slice
// so 1 Tile contains the inforamtion for 1 slice
/**********************************************************************/


int mrs_trim_mapping_file(mrs_data_info &data_info)

                    
  
{
   
  int status =0;
  int hdutype = 0;

  status = 0;
  fitsfile *file_ptr;
  cout <<" Opening " << data_info.mapping_d2c_overlap_file << endl;

  fits_open_file(&file_ptr,data_info.mapping_d2c_overlap_file.c_str(),
		 READWRITE,&status);
  if(status != 0 ) {
    cout << "mrs_trim_mapping_file: problem opening mapping file" << endl;
    cout << " Error status " << status << endl;
    cout << " You might trying running program with out writing the Cube mapping overlap file" << endl;
    exit(EXIT_FAILURE);

  }

  fits_movabs_hdu(file_ptr,2,&hdutype,&status);


  int NPlanes = data_info.Max_Overlap_Planes;
  if(data_info.Actual_Max_Overlap_Planes <  data_info.Max_Overlap_Planes){
    NPlanes = data_info.Actual_Max_Overlap_Planes;
  }

  status = 0;
  fits_write_key(data_info.cube_overlap_file_ptr,TINT,"NOVERLAP",&NPlanes,
		 " # of overlapping pairs (index in cube, overlap %) ",&status);
  if(status !=0 ){
    cout << "mrs_trim_mapping_file:  Problem adding NOVERLAP " << status << endl;
  }

  

  if(data_info.Actual_Max_Overlap_Planes != data_info.Max_Overlap_Planes){
    cout << " Triming/Adjusting size of Mapping file " << endl;

    status = 0;
    long actual_size = NPlanes*2;
    fits_update_key(file_ptr, TLONG, "NAXIS3", &actual_size, "Adjusted Naxes 3", &status); 
    if(status !=0 ){
      cout << "mrs_trim_mapping_file:  Problem modifying NAXIS3 " << status << endl;
    }
  }




  fits_close_file(file_ptr,&status);
  if(status !=0) cout << "mrs_trim_mapping_file:  Problem closing Mapping Overlap file " << status << endl;



  //_______________________________________________________________________

  return status;

}



