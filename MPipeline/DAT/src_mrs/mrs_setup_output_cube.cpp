#include <iostream>
#include <vector>
#include <string>
#include "fitsio.h"
#include "mrs_CubeHeader.h"

#include "mrs_data_info.h"
#include "mrs_control.h"
#include "miri_cube.h"

// program to define the filenames - input and outputcdme


void mrs_setup_output_cube(fitsfile *fptr,
			   CubeHeader &cubeHead, 
			   mrs_control control, 
			   mrs_data_info data_info){



  long nx = cubeHead.GetNgridX();
  long ny = cubeHead.GetNgridY();
  long nz = cubeHead.GetNgridZ();

  int naxis = 3;
  long naxes[3];
  naxes[0] = nx;
  naxes[1] = ny;
  naxes[2] = nz;
  long nelements = nx*ny*nz;
  int status= 0;

  int bitpix = -32;


  for (int iextension = 0; iextension < 4; iextension++){
    //cout << " writing extension " << iextension << endl;
  status = 0;
  fits_create_img(fptr, bitpix,naxis,naxes, &status);

  if(status !=0) {
    cout << " mrs_setup_output_files: Problem creating image"<< endl;
    cout << " status " << status <<endl;
    exit(EXIT_FAILURE);
  }

  if(iextension == 0) {
    char extname[4] = "SCI";
    fits_write_key(fptr,TSTRING,"EXTNAME",&extname," Extension Name ",&status);
  }
  if(iextension == 1) {
    char extname[4] = "UNC";
    fits_write_key(fptr,TSTRING,"EXTNAME",&extname," Extension Name ",&status);
  }
  if(iextension == 2){ 
    char extname[5] = "FLAG";
    fits_write_key(fptr,TSTRING,"EXTNAME",&extname," Extension Name ",&status);
  }
  if(iextension == 3){ 
    char extname[9] = "NOVERLAP";
    fits_write_key(fptr,TSTRING,"EXTNAME",&extname," Extension Name ",&status);
  }


  mrs_write_header(fptr,cubeHead,control,data_info);


  float *data = new float[nx*ny*nz];
  long nplane = nx * ny;

  for (register long iz = 0; iz< nz; iz++){
    long zz = iz*nplane;
      for (register long iy = 0; iy< ny; iy++){
	for(register long ix = 0; ix< nx; ix++){
	  long index = (iy*nx + ix) + zz;
	  data[index] = 0.0;
	} // end ix
      } // end iy
  } // end iz


    fits_write_img(fptr,TFLOAT,1,nelements,data,&status);
    if(status !=0) {
      cout << " mrs_setup_output_files: Problem writing image, extension " << iextension<<  endl;
      cout << " status " << status <<endl;
      exit(EXIT_FAILURE);
    }

    delete [] data;
  }


  status = 0;

  
}



