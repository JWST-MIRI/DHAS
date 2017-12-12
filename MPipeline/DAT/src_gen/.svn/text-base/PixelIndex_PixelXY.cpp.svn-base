#include <iostream>
#include <string>
#include <iomanip>
#include <fstream>
#include <cmath>
#include <cstdlib> // EXIT_FAILURE, EXIT_SUCCESS

/**********************************************************************/
// Purpose:
// Given a one dimensional pixel index starting at 0- convert this to the pixel
// location in x and y (starting at 1,1) 
//
// Inputs:
// Index - one dim array index
// xsize - number of pixel in x direction

// 
// OUTPUTS:
//  X - x pixel location (starts at 1)
//  Y - y pixel location  (starts at 1) 
/**********************************************************************/

using namespace std;

void PixelIndex_PixelXY(const int xsize, const long Index, int&x, int &y)
{
  
  y  = (Index/xsize) +1;
  x = (Index - ((y -1)*xsize))+ 1;
}
