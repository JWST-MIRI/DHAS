// mrs_Setup_Tile.cpp
#include <iostream>
#include <string>
#include <iomanip>
#include <fstream>
#include <vector>
#include <math.h>
#include <cstdlib>
#include "mrs_CubeHeader.h"
#include "mrs_Tile.h"
#include "mrs_constants.h"
#include "mrs_data_info.h"

void mrs_Setup_Tile(const int it,
		    mrs_data_info data_info, CubeHeader &cubeHead, 
		    Tile &tile,
		    const int verbose)

{

  
  long NX = cubeHead.GetNgridX();
  long NY = cubeHead.GetNgridY();
  long NZ = cubeHead.GetNgridZ();

  long ny = NY;

  int NS = cubeHead.GetNumSlices();


  tile.SetNumSlices(NS);
  tile.SetTileNo(it);


  //  long nelements = cubeHead.GetTile_NumPixels(it);
  long nelements = cubeHead.GetNumPixels();
  tile.SetNumPixels(nelements);
  cout << " Size of Tile " <<  NX << " " << NY << " " << NZ <<endl;

  // ***********************************************************************
  // Set up the cube

  //  long nelements =  NX * ny * NZ;
  tile.Reserve_Grid(nelements);

  // length of each pixel in cube space
  double pixel_y = cubeHead.GetCdelt2();
  double pixel_x = cubeHead.GetCdelt1();
  double pixel_z = cubeHead.GetCdelt3();;


  //cout << " Size of Cube " << nx << " " << ny << " " << nz << endl;
  // x,y z initial starting values (center of first pixel)
  // on  the center of the first pixel is defined to be 1.0
  // So the first pixel ranges from 0.5 to 1.5 

  // center of first pixel

  // 3 different 1 dimension vectors : center of cube pixels


  for (long iz = 0; iz < NZ; iz++){
    double zcoord = cubeHead.GetZCoord(iz);
    tile.SetZCoord(zcoord);
  }

  for (long ix = 0; ix < NX; ix++){
    double xcoord = cubeHead.GetXCoord(ix);
    tile.SetXCoord(xcoord);
  }


  for (long iy = 0; iy< ny ; iy++){
    long iyy =  iy;
    double ycoord = cubeHead.GetYCoord(iyy);
    tile.SetYCoord(ycoord);
  }



  // fill in the location of the tile  element center pixel value

  // zint is CRVAL3 located at 0.5 
  double zint = cubeHead.GetCrval3() ; //  wavemin = located at center of pixel
  double xint = cubeHead.GetCrval1();  // 
  double yint = cubeHead.GetCrval2();;

  yint = yint + pixel_y/2.0;


  double xvalue = 0.0;
  double yvalue = 0.0;
  double zvalue = 0.0;

  zvalue = zint + pixel_z/2.0;
  long index = 0;
  for (long iz = 0; iz < NZ; iz++){
     yvalue = yint + pixel_y/2.0;
    for (long iy = 0; iy< ny ; iy++){
      xvalue= xint + pixel_x/2.0;;
      for (long ix = 0 ; ix < NX; ix++){
        tile.Initialize_Elements(xvalue,yvalue,zvalue);
	index++;
	xvalue = xvalue + pixel_x;
      }
      yvalue = yvalue + pixel_y;
    }
    zvalue = zvalue + pixel_z;
  }



  
}
  

  
