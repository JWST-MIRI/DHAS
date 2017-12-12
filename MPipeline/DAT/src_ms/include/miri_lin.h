// include files

#ifndef LIN_H
#define LIN_H

#include <iostream>
#include <iomanip>
#include <strstream>
#include <fstream>
#include <vector>
#include <cmath>
#include <string>
// namespaces

using namespace std;


// Class holding linearit correction

class  miri_lin {
 public:
  miri_lin();            // default constructor
  ~miri_lin();

//_______________________________________________________________________
  // functions defined in ms_miri_dark.cpp
 
  inline void SetCorrection( float Value){correction.push_back(Value) ;}
  inline void SetDQ( int DataQuality){DQ = DataQuality ;}

  inline float GetCorrection(int i) const {return correction[i];}
  inline int GetDQ()const {return DQ;}

//_______________________________________________________________________
 
     private:

  // Linearity Correction for each pixel defined, size of correction = order+1 of fit 

  vector<float> correction;
  int DQ;


};


#endif

