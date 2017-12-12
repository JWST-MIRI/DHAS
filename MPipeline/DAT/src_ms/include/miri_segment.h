// include file fpr miri_pixel class

#ifndef SEG_H
#define SEG_H

#include <iostream>
#include <iomanip>
#include <strstream>
#include <fstream>
#include <vector>
#include <cmath>
#include <string>
#include "miri_constants.h"
// namespaces

using namespace std;


// All the information needed for reducing a particular pixel is contained
// in this structure as well as the reduced data.

class  miri_segment {
 public:
  miri_segment();            // default constructor
  ~miri_segment();


  // inline functions 


  inline void SetSegNum(int I) {nsegments = I;}
  inline void SetSegBegin(int I){seg_begin.push_back(I);}
  inline void SetSegEnd(int I){seg_end.push_back(I);}
  inline void SetSegFlag(int I){seg_flag.push_back(I);}
  inline void SetSegSlope(float S){seg_slope.push_back(S);}
  inline void SetSegUnc(float S){seg_unc.push_back(S);}

  inline int GetSegNum() const {return nsegments;}

  inline int GetSegBegin(const int i) {return seg_begin[i];}
  inline int GetSegEnd(const int i) {return seg_end[i];}
  inline float GetSegSlope(const int i) {return seg_slope[i];}
  inline float GetSegUnc(const int i) {return seg_unc[i];}
  inline int GetSegFlag(const int i) {return seg_flag[i];}




//_______________________________________________________l________________

     private:

  int nsegments;
  vector <float> seg_slope;      // slopes of the individual segments
  vector <float> seg_unc;  // uncertainties in slopes of the individual segments
  vector<int> seg_begin;         // begin of slope segment (in read # - 1st read = 1)
  vector<int> seg_end;           // end of slope segment (in read #)
  vector<int> seg_flag;

};

#endif

