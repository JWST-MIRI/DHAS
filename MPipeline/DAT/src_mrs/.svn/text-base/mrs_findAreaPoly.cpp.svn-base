#include <iostream>
#include <string>
#include <iomanip>
#include <fstream>
#include <math.h>
#include <cstdlib> // EXIT_FAILURE, EXIT_SUCCESS
#include <vector>
#include <algorithm>
using namespace std;
/**********************************************************************/
// Developer: Jane Morrison
// Description: 
// Find the area of a polygon = Green's formula
// Make all the values positive.
/**********************************************************************/



double findAreaPoly(int nVertices,double xPixel[],double yPixel[]){
  
  double areaPoly = 0.0;
  double xmin = xPixel[0];
  double ymin = yPixel[0];
  //  cout << nVertices << endl;

  for (int i = 1; i < nVertices; i++){ 
    if(xPixel[i] < xmin) xmin = xPixel[i];
    if(yPixel[i] < ymin) ymin = yPixel[i];

  }
  
  //cout << "xmin ymin " << xmin << " " << ymin << endl;
  for (int i = 0; i < nVertices-1; i++){
    double area = ( xPixel[i]- xmin)*(yPixel[i+1]-ymin) - (xPixel[i+1]-xmin)*(yPixel[i]-ymin);
    //cout << "area "<< area << endl;
    areaPoly = areaPoly + area;
  }
  areaPoly = 0.5* areaPoly;
  return fabs(areaPoly);
}
  


