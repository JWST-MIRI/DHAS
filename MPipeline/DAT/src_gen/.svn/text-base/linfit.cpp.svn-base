#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>
#include <vector>
#include <iostream>
#include "miri_constants.h"

using namespace std;

void linfit(vector<float> &data,
		float &slope, 
		float &yintercept, 
		int &flag)
{

  int num = data.size();

  flag = 0;

  double s(0.0);
  double sx(0.0);
  double sxx(0.0);
  double sy(0.0);
  double sxy(0.0);
  int num_good = 0;

  for (int i = 0; i< num  ; i++){
    
    int x  = i;
    s+= 1.0;
    sx += x ;
    sy += data[i];
    sxx += (x)*(x);
    sxy += (x)*data[i];
    num_good++;

    
  }

  double delta = s*sxx - sx*sx;
  double intercept = 0.0;
  double Slope = 0.0;
  double Slope_unc = 0.0;
  double RMS = 0.0;
  double var = 0.0;
  // when you don't know the individual measurement errors - need to adjust
  // how we find the varaiance in the slope measurement - see Numerical Recipes
  // in C, page 664. 
  if(num_good < 2) {
    flag = 1;
    Slope = NO_SLOPE_FOUND;
    Slope_unc = NO_SLOPE_FOUND;
    intercept = NO_SLOPE_FOUND;
    RMS= NO_SLOPE_FOUND;
  }else{
    intercept = (sxx*sy - sx*sxy)/delta;
    Slope = (s*sxy - sx*sy)/delta;
    double var(0.0);
    double vari(0.0);

    for (int i = 0; i< num  ; i++){
      int x =i;
      vari = data[i] - intercept - Slope*x;
      var += vari * vari;
    }
  }
  var = var/(s-2);
  RMS= sqrt(var);
  Slope_unc = (s * var)/delta;
  Slope_unc  = sqrt(Slope_unc); // see Numerical recipes C, pg 662 (when individual measurement
  // errors are unknown need to multiply sigma_slope = (s/delta) * sqrt(chi**2/(N-2). For case
  // sigma_measurement = 1, s = N.

    
  slope = Slope;
  yintercept = intercept;
}

