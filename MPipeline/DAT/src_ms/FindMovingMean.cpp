//FindMedian.cpp 
// developer: J Morrison, 04-23-13
// Given an input vector. Return the mean found by sigma_clipping of standard deviation (sigma_clip)

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>
#include <vector>
#include <numeric>
#include <algorithm>
// Routine to find the median value of an array
using namespace std;

void FindMovingMean(vector<float> input,  const int istart, const int iend, 
		    float &moving_mean)
{
//_______________________________________________________________________

  //int status = 0; 
  //int n = input.size();

  moving_mean = 0.0;
  int imean = 0; 
  //cout << " looping over " << istart << " " << iend << endl;
  for (int i = istart; i< iend;i++){ // for the section of the vector - find mean for values !=1
    if(input[i] !=1) {
      moving_mean = moving_mean + input[i];
      // cout << input[i] << " " << i << endl;
      imean++;
    }
  }
  if(imean > 1) {
    moving_mean = moving_mean/float(imean);
  } else {
    moving_mean = 0;
  } 
  //  cout << " mean imean " << moving_mean << " " << imean << endl;



}

