#include <iostream>
#include <string>
#include <iomanip>
#include <fstream>
#include <vector>
#include <cstdlib> 

/**********************************************************************/
// Purpose:
// Given 3-d array index (starting at 1,1)  - convert to a 1-d index
// starting a 0
//
// InPUTS:
//  X - x pixel location (starts at 1)
//  Y - y pixel location (starts at 1)
//  Z - y pixel location (starts at 1)
// xsize - number of pixel in x direction

// Outputs:
// Index - one dim array index (starts at zero)
/**********************************************************************/

using namespace std;

void mrs_CubeXYZ_CubeIndex(const int xsize, 
			   const int ysize, 
			   const int x, const int y, const int z,
			   long &index)
{
  
  long xyplane = xsize*ysize;



  index = (y-1)*xsize + (x-1);

  index = index + (z-1)*xyplane;
  

}
