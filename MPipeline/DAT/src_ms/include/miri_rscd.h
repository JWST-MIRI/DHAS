// include files

#ifndef RSCD_H
#define RSCD_H

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

class  miri_rscd {
  
 public:
  miri_rscd();            // default constructor
  ~miri_rscd();

//_______________________________________________________________________
  // RSCD

    inline void SetParametersGen(float Tlower_cutoff, float Talpha_even, 
			      float Talpha_odd){

      lower_cutoff = Tlower_cutoff;
      alpha_even = Talpha_even;
      alpha_odd = Talpha_odd;

    }

    inline void SetParameters(float Ta0_even, float Ta1_even,
			      float Ta2_even, float Ta3_even,
			      float Ta0_odd, float Ta1_odd,
			      float Ta2_odd, float Ta3_odd){
      
      a0_even.push_back(Ta0_even);
      a1_even.push_back(Ta1_even);
      a2_even.push_back(Ta2_even);
      a3_even.push_back(Ta3_even);

      a0_odd.push_back(Ta0_odd);
      a1_odd.push_back(Ta1_odd);
      a2_odd.push_back(Ta2_odd);
      a3_odd.push_back(Ta3_odd);
    }

    inline void GetParams(int i,
			  float &rscd_lower_cutoff,
			  float &rscd_alpha_even,
			  float &rscd_alpha_odd,
			  float &rscd_a0_even,
			  float &rscd_a0_odd,
			  float &rscd_a1_even,
			  float &rscd_a1_odd,
			  float &rscd_a2_even,
			  float &rscd_a2_odd,
			  float &rscd_a3_even,
			  float &rscd_a3_odd){


    rscd_lower_cutoff = lower_cutoff ;
    rscd_alpha_odd  = alpha_odd; 
    rscd_alpha_even  = alpha_even;

    cout << "rscd parameters" << rscd_lower_cutoff << " " << 
      rscd_alpha_odd << " " << rscd_alpha_even << endl;

    rscd_a0_even = a0_even[i];
    rscd_a0_odd = a0_odd[i];
	
    rscd_a1_even = a1_even[i];
    rscd_a1_odd = a1_odd[i];
	
    rscd_a2_even = a2_even[i];
    rscd_a2_odd = a2_odd[i];

    rscd_a3_even = a3_even[i];
    rscd_a3_odd = a3_odd[i];
    cout << i << " " << rscd_a0_even << " "  << rscd_a1_even << " " << rscd_a2_even << " " << rscd_a3_even  << endl;

  }
//_______________________________________________________________________
     private:

  float lower_cutoff;
  float alpha_even;
  float alpha_odd;
  
  vector<float> a0_even;
  vector<float> a0_odd;

  vector<float> a1_even;
  vector<float> a1_odd;

  vector<float> a2_even;
  vector<float> a2_odd;

  vector<float> a3_even;
  vector<float> a3_odd;

};



#endif
