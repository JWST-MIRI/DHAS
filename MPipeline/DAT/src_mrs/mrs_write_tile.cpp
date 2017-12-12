#include <iostream>
#include <vector>
#include <string>
#include "fitsio.h"
#include "mrs_CubeHeader.h"
#include "mrs_Tile.h"
#include "mrs_data_info.h"
#include "mrs_control.h"
#include "miri_cube.h"

// program to define the filenames - input and outputcdme


void mrs_write_tile(fitsfile *fptr,const int itile,
		    CubeHeader &cubeHead, Tile &tile, 
		    mrs_control control, mrs_data_info data_info){



  long nx = cubeHead.GetNgridX();
  long ny = cubeHead.GetNgridY();
  long nz = cubeHead.GetNgridZ();


  int nytile = ny;

  int naxis = 3;
  long naxes[3];
  naxes[0] = nx;
  naxes[1] = ny;
  naxes[2] = nz;


  int hdutype =0;
  int status = 0;
  long fpixel[3] ;
  long lpixel[3];
  fpixel[0]= 1;
  fpixel[1]= 1;
  fpixel[2]  = 1;
  // number of rows of data to read in  
  lpixel[0] = nx;
  lpixel[1] = fpixel[1] + nytile-1;
  lpixel[2] = nz;
  //cout << "nytile " << nytile << endl;
  //cout << " nx nz " << nx << " " << nz << endl;
  //cout << fpixel[0] << " " << fpixel[1] << " " << fpixel[2] << endl;
  //cout << lpixel[0] << " " << lpixel[1] << " " << lpixel[2] << endl;
  
  for (int iextension = 0; iextension < 4; iextension++){

    status = 0;

    float *data = new float[nx*nytile*nz];
    long nplane = nx * nytile;

    for (register long iz = 0; iz< nz; iz++){
      long zz = iz*nplane;

      for (register long iy = 0; iy< nytile; iy++){
	for(register long ix = 0; ix< nx; ix++){
	  long index = (iy*nx + ix) + zz;
	  if(iextension == 0){data[index] = tile.GetAveFlux(index);}
	  if(iextension == 1){data[index] = tile.GetAveUncertainty(index);}
	  if(iextension == 2){data[index] = tile.GetBadPixelFlag(index);}
	  if(iextension == 3){data[index] = tile.GetTotalOverlap(index);}
	} // end ix
      } // end iy
    } // end iz

    status = 0;

    //cout << "iextension " << iextension+1 << endl;
    fits_movabs_hdu(fptr,iextension+1,&hdutype,&status);
    if(status !=0 ) {
      cout << " mrs_write_tile:Problem moving to extension in  cube " << status << endl;
      exit(EXIT_FAILURE);
    }
    

    fits_write_subset_flt(fptr,0,naxis,naxes,fpixel,lpixel,&data[0],&status);

    if(status !=0) {
      cout << " mrs_write_cube: Problem writing image, extension " << iextension+1<<  endl;
      cout << " status " << status <<endl;
      exit(EXIT_FAILURE);
    }

    delete [] data;
  }


  status = 0;
  
}



