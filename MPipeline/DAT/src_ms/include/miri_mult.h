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

      inline void SetParameters(float Talpha_even, float B_even, float A_even,
				float D_even, float C_even,
				float Fsat_even, float Esat_even, 
				float Hsat_even, float Gsat_even, float low_tol_even,
				float Talpha_odd, float B_odd, float A_odd,
				float D_odd, float C_odd,
				float Fsat_odd, float Esat_odd, 
				float Hsat_odd, float Gsat_odd, float low_tol_odd){


	
	min_tol_even = low_tol_even;
	alpha_even = Talpha_even;
	a_even.push_back(B_even);
	a_even.push_back(A_even);
	b_even.push_back(D_even);
	b_even.push_back(C_even);
	c_even.push_back(Fsat_even);
	c_even.push_back(Esat_even);
	d_even.push_back(Hsat_even);
	d_even.push_back(Gsat_even);

	cout << " in set parameters" << a_even[0] << " " << a_even[1] << endl;
	min_tol_odd = low_tol_odd;
	alpha_odd = Talpha_odd;
	a_odd.push_back(B_odd);
	a_odd.push_back(A_odd);
	b_odd.push_back(D_odd);
	b_odd.push_back(C_odd);
	c_odd.push_back(Fsat_odd);
	c_odd.push_back(Esat_odd);
	d_odd.push_back(Hsat_odd);
	d_odd.push_back(Gsat_odd);
    }

  inline void GetParams(float &mult_min_tol_even,
			float &mult_min_tol_odd,
			float &mult_alpha_even,
			float &mult_alpha_odd,
			vector <float> &A_even,
			vector <float> &A_odd,
			vector <float> &B_even,
			vector <float> &B_odd,
			vector <float> &C_even,
			vector <float> &C_odd,
			vector <float> &D_even,
			vector <float> &D_odd){



    mult_min_tol_even = min_tol_even;
    mult_min_tol_odd = min_tol_odd ;
    mult_alpha_even = alpha_even;
    mult_alpha_odd = alpha_odd ;

    for (int i = 0; i< 2; i++){
      A_even[i] = a_even[i];
      A_odd[i] = a_odd[i];
      B_even[i] = b_even[i];
      B_odd[i] = b_odd[i];
      C_even[i] = c_even[i];
      C_odd[i] = c_odd[i];
      D_even[i] = d_even[i];
      D_odd[i] = d_odd[i];
    }


  }
//_______________________________________________________________________
     private:

  float alpha_even,min_tol_even;
  float alpha_odd,min_tol_odd;

  vector<float> a_even;
  vector<float> a_odd;

  vector<float> b_even;
  vector<float> b_odd;

  vector<float> c_even;
  vector<float> c_odd;

  vector<float> d_even;
  vector<float> d_odd;

};



#endif
