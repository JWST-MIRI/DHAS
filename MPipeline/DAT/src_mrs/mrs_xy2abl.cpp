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
// convert x,y -> alpha(a), beta(b), lambda(l)
/**********************************************************************/


void   mrs_xy2abl( int slice_no,float beta_zero,float beta_delta,float xas, vector<float>kalpha,
		  float xls,vector<float>klambda,float ix,float iy,float &alpha,float &beta,float &lambda){


  //cout << "in xy2abl" << endl;
  //cout << "x valuves " << xas << " " << xls << endl;

  beta = beta_zero + slice_no*beta_delta;


  int k = 0;
  alpha = 0.0;
  lambda =0.0;
  for (int i = 0 ; i< 5; i++){
    for (int j = 0 ; j< 5; j++){

      float xvalue_a = float(ix) - xas ;
      float xvalue_l = float(ix) - xls ;
      //cout  << k << " " <<  i << " " << j << " "  << kalpha[k] << " " << xas << " " << xvalue_a  << endl;
      //      cout  << k << " " << kalpha[k] << " " << klambda[k] << endl;
      //cout  << k << " " << xls << " " << " " << xvalue_l << " " << klambda[k] << endl;

      alpha = alpha  + kalpha[k]* pow(xvalue_a,j) * pow(float(iy),i);
      lambda = lambda + klambda[k]* pow(xvalue_l,j) * pow(float(iy),i);

      k = k + 1; 
    }
  }
  
  //cout << alpha << " " << lambda << " " << ix << " " << iy << " " << slice_no << endl;
  //if(ix == 60 and iy ==16) exit(-1);
  //cout << lambda << endl;
}
  


