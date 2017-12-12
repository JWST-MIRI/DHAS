// include files

#ifndef DARK_H
#define DARK_H

#include <iostream>
#include <iomanip>
#include <strstream>
#include <fstream>
#include <vector>
#include <cmath>
#include <string>
// namespaces

using namespace std;


// Class holding Darks

class  miri_dark {
 public:
  miri_dark();            // default constructor
  ~miri_dark();

//_______________________________________________________________________
  // functions defined in ms_miri_dark.cpp
 
  inline void SetDarkValue( float DarkValue){value.push_back(DarkValue) ;}
  inline void SetDarkDQ( short DQ){dq=DQ ;}

  inline float GetDarkValue(int iplane) const {return value[iplane];}
  inline short GetDarkDQ( )const {return dq;}

//_______________________________________________________________________
 
     private:

  // Dark for each pixel defined, size = nplanes 

  vector<float> value;
  short dq;

};


#endif

