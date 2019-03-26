// include files

#ifndef MULT_H
#define MULT_H

#include <iostream>
#include <iomanip>
#include <strstream>
#include <fstream>
#include <vector>
#include <cmath>
#include <string>
// namespaces

using namespace std;
// Class holding linearit correction

class  miri_mult {
 public:
  miri_mult();            // default constructor
  ~miri_mult();
//_______________________________________________________________________
  // MULT

    inline void SetParameters(float Tmin_tol_even, float Ta0_even, float Ta1_even,
			      float Tb0_even, float Tb1_even,
			      float Talpha_even, float Tsat_param_even, 
			      float Tmin_tol_odd, float Ta0_odd, float Ta1_odd,
			      float Tb0_odd, float Tb1_odd,
			      float Talpha_odd, float Tsat_param_odd){

      min_tol_even = Tmin_tol_even;
      a0_even = Ta0_even;
      a1_even = Ta1_even;
      b0_even = Tb0_even;
      b1_even = Tb1_even;
      alpha_even = Talpha_even;
      sat_param_even = Tsat_param_even;

      min_tol_odd = Tmin_tol_odd;
      a0_odd = Ta0_odd;
      a1_odd = Ta1_odd;
      b0_odd = Tb0_odd;
      b1_odd = Tb1_odd;
      alpha_odd = Talpha_odd;
      sat_param_odd = Tsat_param_odd;
    }

  inline void GetParams(float &mult_min_tol_even,
			float &mult_min_tol_odd,
			float &mult_a0_even,
			float &mult_a0_odd,
			float &mult_a1_even,
			float &mult_a1_odd,
			float &mult_b0_even,
			float &mult_b0_odd,
			float &mult_b1_even,
			float &mult_b1_odd,
			float &mult_alpha_even,
			float &mult_alpha_odd,
			float &mult_sat_param_even,
			float &mult_sat_param_odd) {


    mult_min_tol_even = min_tol_even;
    mult_min_tol_odd = min_tol_odd ;
    mult_a0_even = a0_even;
    mult_a0_odd = a0_odd ;
    mult_a1_even = a1_even;
    mult_a1_odd = a1_odd ;
    mult_b0_even = b0_even;
    mult_b0_odd = b0_odd ;
    mult_b1_even = b1_even;
    mult_b1_odd = b1_odd ;
    mult_alpha_even = alpha_even;
    mult_alpha_odd = alpha_odd ;
    mult_sat_param_even = sat_param_even;
    mult_sat_param_odd = sat_param_odd ;
  }
//_______________________________________________________________________
     private:

  float min_tol_even,a0_even,a1_even,
    b0_even,b1_even,alpha_even,sat_param_even;

  float min_tol_odd,a0_odd,a1_odd,
    b0_odd,b1_odd,alpha_odd,sat_param_odd;

};



#endif
