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

void FilterRefPixel(vector<float> &input,  const float sigma_clip, const int filter_size, 
		    float &channel_mean, int &status)
{
//_______________________________________________________________________

  //cout << " in FilterRefPixel" <<filter_size << " " << sigma_clip <<   endl;
  status = 0; 


  int n = input.size();
  vector<float> output(n);
  vector<int> flag(n);
  float zero = 0.0;
  //cout << "size of input " << n << " " << filter_size << endl;

  copy(input.begin(), input.end(), output.begin());

  int ireject = 0; 
  for (int i = 0; i< (n-filter_size+1);i++){ // find the standard dev based on Median of diff
    float moving_mean = 0;


    int iend = i + filter_size;
    moving_mean = accumulate(input.begin()+i, input.begin()+iend,zero);
    moving_mean = moving_mean/float(filter_size);
    //cout << " moving mean for i " << moving_mean << " " << i << endl;
    float stdev = 0.0;
    for(int k = i; k<iend;k++){
      float diff = moving_mean - input[k];
      stdev +=diff*diff;
    }
    stdev =sqrt(stdev/ (filter_size-1));
    
    float testlimit = stdev * sigma_clip;

    float upper = moving_mean + testlimit;
    float lower = moving_mean - testlimit;
    //cout << "upper Lower" << upper << " " << lower << endl;

    for(int j = i; j< iend;j++){
      if(input[j] > upper ||  input[j] < lower ) {
	flag[j] = 1.0;
	//cout << " Rejected value from mean " << input[j] << endl;

      }
    }
  }


  channel_mean = 0.0;
  int imean = 0;
  for (int i = 0; i< n;i++){ // find the standard dev based on Median of diff
    if(flag[i] != 1) {
      channel_mean += output[i];
      imean++;
    } else {
      ireject++; 
    } 
    input[i] = output[i];
  }
  channel_mean = channel_mean/float(imean);

  //cout << " Number values rejected " << ireject << endl;

}

