// mrs_Geometry_Cube.cpp
#include <iostream>
#include <string>
#include <iomanip>
#include <fstream>
#include <vector>
#include <math.h>
#include <cstdlib>
#include "mrs_SubPixel.h"
#include "mrs_CubeHeader.h"


void mrs_SetIndex(const int it, CubeHeader cubeHead,
		  vector<SubPixel> &subpixel)

{


  //  int ny = cubeHead.GetTile_NgridY(it);
  long NY = cubeHead.GetNgridY();
  long NZ = cubeHead.GetNgridZ();
  long NX = cubeHead.GetNgridX();

  //  long ystart = cubeHead.GetTile_StartValue(it);

  long ystart = 0;


  long index = 0;
  long tile_index = 0;

  long nplane = NX * NY;
  for (long p = 0; p< NZ; p++){
    long iz = p * nplane;
    //    for (long j = 0; j< ny; j++){
    for (long j = 0; j< NY; j++){
      for (long i = 0; i< NX; i++){

	index = (j+ystart)*NX  + i;
	index = index + iz;


      subpixel[tile_index].SetIndex(index);

      tile_index++;
      }
    }
  }
  //cout << " done with MRS_SetIndex " << endl;

}
