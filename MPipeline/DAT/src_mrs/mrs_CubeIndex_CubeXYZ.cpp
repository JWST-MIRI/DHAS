#include <iostream>
#include <string>
#include <iomanip>
#include <fstream>
#include <cmath>
#include <cstdlib> // EXIT_FAILURE, EXIT_SUCCESS

/**********************************************************************/
// Purpose:
// Given a one dimensional pixel index starting at 0- convert this to the pixel
// location in x, y, z (starting at 1,1,1) 
//
// Inputs:
// Index - one dim array index
// xsize - number of pixel in x direction
// ysize - number of pixel in y direction

// 
// OUTPUTS:
//  X - x pixel location (starts at 1)
//  Y - y pixel location  (starts at 1) 
//  Z - z pixel location  (starts at 1) 
/**********************************************************************/

using namespace std;

void mrs_CubeIndex_CubeXYZ(const int xsize, const int ysize,
			  const long Index, int&x, int &y, int&z)
{
  long xyplane = xsize*ysize;

  z  = (Index/xyplane);
  long newi = Index - (z*xyplane);

  y  = (newi/xsize);
  x = newi - (y*xsize);
  z++;
  y++;
  x++;

}
