#include <iostream>
#include <string>
#include <iomanip>
#include <fstream>
#include <math.h>
#include <cstdlib> // EXIT_FAILURE, EXIT_SUCCESS
#include <vector>
#include <algorithm>
#include "mrs_data_info.h"
using namespace std;
/**********************************************************************/
// Developer: Jane Morrison
// Description: 
// alpha(a), beta(b), lambda(l) -> V2 V3
/**********************************************************************/


void   mrs_ab2v2v3( float alpha,float beta,float v2coeff[NUM_V2V3_COEFF][NUM_V2V3_COEFF], 
		    float v3coeff[NUM_V2V3_COEFF][NUM_V2V3_COEFF],
		     float &v2, float &v3)
{
  v2 = 0.0;
  v3 =0.0;
  for (int i = 0 ; i< 2; i++){
    for (int j = 0 ; j< 2; j++){
      float v2temp = 0.0;
      float v3temp = 0.0;
      //cout << "V2 " << i << " " << j << " " << v2coeff[i][j] << endl;
      //cout << "V3 " << i << " " << j << " " << v3coeff[i][j] << endl;
      v2temp = v2coeff[i][j] * pow(alpha,j) * pow(beta,i);
      v3temp = v3coeff[i][j] * pow(alpha,j) * pow(beta,i);
      v2 = v2 + v2temp;
      v3 = v3 + v3temp;
      //cout << alpha << " " << beta << " " << pow(alpha,j)  << " " << pow(beta,i)  << endl;
      //cout << " v2 v3 temp" << v2temp << " " << v3temp << endl;
    }
  }
}
  


