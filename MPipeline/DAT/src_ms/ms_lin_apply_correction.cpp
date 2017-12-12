#include <cstdlib>
#include <vector>
#include <cmath>
#include "miri_sloper.h"
/**********************************************************************/
// Purpose:

//
// InPUTS:


// Outputs:

/**********************************************************************/


using namespace std;

float ms_lin_apply_correction(float data, const int order, vector<float> lin){
 
  float yfit = 0.0;

  if(order == 1) yfit = lin[0] + lin[1]*data;
    
  if(order == 2) yfit = lin[0] + lin[1]*data + lin[2]*data*data;
      
  if(order == 3) yfit = lin[0] + lin[1]*data + lin[2]*data*data + lin[3]*data*data*data;

  if(order == 4) {
    float data3 = data*data*data;
    yfit = lin[0] + lin[1]*data + lin[2]*data*data + lin[3]*data3 + lin[4]*data3*data;
  }

  if(order == 5) {
    float data4 = data*data*data*data;
    yfit = lin[0] + lin[1]*data + lin[2]*data*data + lin[3]*data*data*data + 
      lin[4]*data4 + lin[5]*data4*data;
  }

  if(order == 6){
    float data4 = data*data*data*data;
    yfit = lin[0] + lin[1]*data + lin[2]*data*data + lin[3]*data*data*data + 
      lin[4]*data4 + lin[5]*data4*data + lin[6]*data4*data*data;
  }

  return yfit;
}
