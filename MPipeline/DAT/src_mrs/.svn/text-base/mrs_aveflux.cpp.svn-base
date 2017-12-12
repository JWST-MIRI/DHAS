// mrs_Geometry_Cube.cpp
#include <iostream>
#include <string>
#include <iomanip>
#include <fstream>
#include <vector>
#include <math.h>
#include <cstdlib>
#include "mrs_CubeHeader.h"
#include "mrs_Tile.h"
#include "mrs_SubPixel.h"



void mrs_aveflux(const long numpixels,
		 CubeHeader cubeHead, 
		 Tile &tile,
		 vector<SubPixel> &subpixel)

{



  for (long i = 0; i< numpixels; i++){
    
    float flux = 0.0;
    float uncertainty = 0.0;
    float totaloverlap = 0.0;
    int flag = -1; // to check if subpixel is empty
    

    subpixel[i].AverageValues(i,flux,uncertainty,totaloverlap,flag);
      

    //    cout << " Sub Pixel results " << i << " " << flux << " " << uncertainty << " " << totaloverlap <<
    // " " << flag << " " << index << endl;

    
    tile.SetAveFlux(i,flux);
    tile.SetAveUncertainty(i,uncertainty);
    tile.SetBadPixelFlag(i,flag);
    tile.SetTotalOverlap(i,totaloverlap);


  }
}
