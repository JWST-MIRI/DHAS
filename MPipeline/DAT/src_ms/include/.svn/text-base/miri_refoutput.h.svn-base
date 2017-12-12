// include files

#ifndef REFOUTPUT_H
#define REFOUTPUT_H

#include <iostream>
#include <iomanip>
#include <strstream>
#include <fstream>
#include <vector>
#include <cmath>
#include <string>
// namespaces

using namespace std;


// All the information needed for reducing a particular pixel is contained
// in this structure as well as the reduced data.

class  miri_refoutput {
 public:
  miri_refoutput();            // default constructor
  ~miri_refoutput();

//_______________________________________________________________________
  // functions defined in ms_miri_refoutput.cpp
 
  void PrintValues()const;

  float GetCorrection(const int i,float x);
  float GetFitValue(const int i,float x);
//_______________________________________________________________________


  inline void InitializeLine(int p){ // p is the size of 1024
    for (int i =0; i< p;i++){
      slope.push_back(0.0);
      yintercept.push_back(0.0);
      mean.push_back(0.0);
    }
  }

  inline void SetSlope(int k, float DATA){slope[k]=DATA;}
  inline void SetYintercept(int k, float DATA){yintercept[k]=DATA;}
  inline void SetMean(int k, float DATA){mean[k]=DATA;}

  inline float GetSlope(int k)const { return slope[k];}
  inline float GetYintercept(int k)const { return yintercept[k];}
  inline float GetMean(int k)const { return mean[k];}
//_______________________________________________________________________

//_______________________________________________________________________
 
     private:

  // one value per output amplifier:

  vector<float> slope; // one value per row
  vector<float> yintercept; // one value per row
  vector<float> mean;  // one value per row


};

#endif

