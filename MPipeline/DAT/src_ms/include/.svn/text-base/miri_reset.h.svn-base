// include files

#ifndef RESET_H
#define RESET_H

#include <iostream>
#include <iomanip>
#include <strstream>
#include <fstream>
#include <vector>
#include <cmath>
#include <string>
// namespaces

using namespace std;


// Class holding reset

class  miri_reset {
 public:
  miri_reset();            // default constructor
  ~miri_reset();

//_______________________________________________________________________
  // functions defined in ms_miri_reset.cpp
 
  inline void SetResetValue( float ResetValue){value.push_back(ResetValue) ;}
  inline void SetResetDQ( short DQ){dq=DQ ;}

  inline float GetResetValue(int iplane) const {return value[iplane];}
  inline short GetResetDQ( )const {return dq;}

//_______________________________________________________________________
 
     private:

  // Reset for each pixel defined, size = nplanes 

  vector<float> value;
  short dq;

};


#endif

