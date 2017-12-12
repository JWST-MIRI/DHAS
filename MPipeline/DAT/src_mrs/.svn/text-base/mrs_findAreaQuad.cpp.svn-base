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
// Find the area of a quadrilateral
// Make all the values positive.
/**********************************************************************/

double mrs_findAreaQuad(
			 const double MinX,  const double MinY,
			const double X0, const double Y0,
			const double X1, const double Y1,
			const double X2, const double Y2,
			const double X3, const double Y3)       
{



  vector <double> PX(5);
  vector <double> PY(5);

  //cout << "MinX MinY " << MinX << " " << MinY << endl;

  PX[0]  = (X0 -MinX);
  PX[1]  = (X1 -MinX);
  PX[2]  = (X2 -MinX);
  PX[3]  = (X3 -MinX);
  PX[4]  = PX[0];

  PY[0]  = (Y0 -MinY);
  PY[1]  = (Y1 -MinY);
  PY[2]  = (Y2 -MinY);
  PY[3]  = (Y3 -MinY);
  PY[4] = PY[0];

  //  cout <<" corners" << PX[0] << " " << PX[1] << " " << PX[2] << " " << PX[3] << endl;
  //cout <<" corners" <<  PY[0] << " " << PY[1] << " " << PY[2] << " " << PY[3] << endl;

  double AREA = 0.0;


  AREA = 0.5*( (PX[0]*PY[1] - PX[1]*PY[0]) + 
	       (PX[1]*PY[2] - PX[2]*PY[1]) + 
	       (PX[2]*PY[3] - PX[3]*PY[2]) +
	       (PX[3]*PY[4] - PX[4]*PY[3]));



  AREA = fabs(AREA);

  return AREA;
}
