//FindMedian.cpp 
// developer: J Morrison, 04-23-13
// Given an input vector. Return the mean found by sigma_clipping of standard deviation (sigma_clip)

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>
#include <numeric>
#include <vector>

#include <algorithm>
// Routine to find the median value of an array
using namespace std;

float FindCleanMean(vector<float> input,  const float sigma_clip, int &status)
{

  
  float Median = 0.0;
  sort(input.begin(),input.end());
  long num = input.size();
  long even_odd = num%2;

  bool even =false;
  if(even_odd ==0)even=true;
  int imedian = -1;
  
  //  cout << "num " << num << endl;
  if(!even) {
    imedian = (num+1)/2;
    Median = input[imedian-1];
    // cout << "odd : " << imedian << " " << Median << endl;
  }else{
    long k1 = num/2;
    long k2  = num/2 + 1;
    Median =(input[k1-1] + input[k2-1])/2.0;
    //cout << "even : " << k1 << " " << k2 << " " << Median << endl;
  }

//_______________________________________________________________________

  float std_dev = 0.0;
  int n = input.size();
  float mdiff = 0;
  for (int i = 0; i< n;i++){ // find the standard dev based on Median of diff
                                      // again - only looking at 0 to icut values
    mdiff = fabs(Median - input[i]);
    //    cout << input[i] << endl;
    std_dev += mdiff*mdiff;
  }
  std_dev =sqrt(std_dev/n-1);

  float testlimit = std_dev * sigma_clip;
  float upper = Median + testlimit;
  float lower = Median - testlimit;
  float channel_mean = 0 ; 
  int ic  = 0; 
  //  cout << "std dev " << std_dev << endl;

  for (int i = 0; i< n;i++){ // find the standard dev based on Median of diff
                                      // again - only looking at 0 to icut values
    if(input[i] < upper && input[i] > lower ){
      channel_mean = channel_mean + input[i];
      ic = ic + 1;
    } else{
      //      cout << " value outside of range " << input[i] << endl;
    }
  }
  channel_mean = channel_mean/float(ic);

  return channel_mean;
}
//_______________________________________________________________________
