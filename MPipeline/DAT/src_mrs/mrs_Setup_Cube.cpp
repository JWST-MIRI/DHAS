// mrs_Setup_Cube.cpp
#include <iostream>
#include <string>
#include <iomanip>
#include <fstream>
#include <vector>
#include <math.h>
#include <cstdlib>
#include "mrs_CubeHeader.h"
#include "mrs_constants.h"
#include "mrs_data_info.h"

void mrs_Setup_Cube(mrs_data_info data_info, CubeHeader &cubeHead,
		    const int verbose)

{

  
  long nx = cubeHead.GetNgridX();
  long ny = cubeHead.GetNgridY();
  long nz = cubeHead.GetNgridZ();

  // ***********************************************************************
  // Set up the cube


  // length of each pixel in cube space
  double pixel_y = cubeHead.GetCdelt2();
  double pixel_x = cubeHead.GetCdelt1();
  double pixel_z = cubeHead.GetCdelt3();;


  //cout << " Size of Cube " << nx << " " << ny << " " << nz << endl;
  // x,y z initial starting values (center of first pixel)
  // on  the center of the first pixel is defined to be 1.0
  // So the first pixel ranges from 0.5 to 1.5 

  // center of first pixel

  double zint = cubeHead.GetCrval3() ; //  wavemin = located at center of pixel
  double xint = cubeHead.GetCrval1();  // 
  double yint = cubeHead.GetCrval2();;



  // 3 different 1 dimension vectors : center of cube pixels
  // zint is CRVAL3 located at 0.5 
  double zstart = zint + pixel_z/2.0;
  for (long iz = 0; iz < nz; iz++){
    if(verbose) cout << "Zcenter " << zstart << endl;
    cubeHead.SetZCoord(zstart);
    zstart = zstart + pixel_z;

  }

  double ystart = yint + pixel_y/2.0 ;
  for (long iy = 0; iy< ny ; iy++){
    if(verbose) cout  << "Ycenter " << ystart << endl;
    cubeHead.SetYCoord(ystart);
      ystart = ystart + pixel_y;
  }

  double xstart = xint + pixel_x/2.0;
  for (long ix = 0 ; ix < nx; ix++){
    if(verbose) cout  << "Xcenter " << xstart << endl;
    cubeHead.SetXCoord(xstart);
    xstart = xstart + pixel_x;
  }



  // Set the slice number in each row
 
  int channel = cubeHead.GetChannel();
  int nslice =  SLICENO[channel-1];
  if(verbose) cout << " n slices " << nslice << endl;


  for (int i = 0; i < nslice; i++){
	cubeHead.SetSliceNo(i+1);
  }	



  cubeHead.PrintCubeInfo();
  
  
}
  

  
