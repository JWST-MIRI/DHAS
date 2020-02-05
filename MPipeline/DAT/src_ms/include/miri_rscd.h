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

  inline void SetFirstFrameParams(){

    first2_even.push_back(137.924);
    first2_even.push_back(-0.0125981);
    first2_even.push_back(-3.97437e-08);
    first2_even.push_back(2.38704e-12);

    first2_odd.push_back(118.097);
    first2_odd.push_back(-0.0147386);
    first2_odd.push_back(3.55408e-07);
    first2_odd.push_back(-1.80501e-12);

    first3_even.push_back(49.8972);
    first3_even.push_back(-0.000120392);
    first3_even.push_back(-4.16299e-07);
    first3_even.push_back(5.71461e-12);

    first3_odd.push_back(41.162);
    first3_odd.push_back(-0.00377325);
    first3_odd.push_back(-3.47460e-08);
    first3_odd.push_back(2.01877e-12);
  }

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

      int iuse = i;
      rscd_lower_cutoff = lower_cutoff ;
      rscd_alpha_odd  = alpha_odd; 
      rscd_alpha_even  = alpha_even;

      //cout << "rscd parameters: " << rscd_lower_cutoff << " " << 
      //	rscd_alpha_odd << " " << rscd_alpha_even << endl;

      if(i > 2)  iuse = 2;
      rscd_a0_even = a0_even[iuse];
      rscd_a0_odd = a0_odd[iuse];
	
      rscd_a1_even = a1_even[iuse];
      rscd_a1_odd = a1_odd[iuse];
	
      rscd_a2_even = a2_even[iuse];
      rscd_a2_odd = a2_odd[iuse];

      rscd_a3_even = a3_even[iuse];
      rscd_a3_odd = a3_odd[iuse];
  }


    inline void GetFirstParams(int i,
			  float &first_a0_even,
			  float &first_a1_even,
			  float &first_a2_even,
			  float &first_a3_even,
			  float &first_a0_odd,
			  float &first_a1_odd,
			  float &first_a2_odd,
			  float &first_a3_odd){

      first_a0_even = 0;
      first_a0_odd = 0;
      
      first_a1_even = 0;
      first_a1_odd = 0;
	
      first_a2_even = 0;
      first_a2_odd = 0;

      first_a3_even = 0;
      first_a3_odd = 0;
      if(i == 1) { // second integration
	first_a0_even = first2_even[0];
	first_a0_odd = first2_odd[0];
      
	first_a1_even = first2_even[1];
	first_a1_odd = first2_odd[1];
	
	first_a2_even = first2_even[2];
	first_a2_odd = first2_odd[2];

	first_a3_even = first2_even[3];
	first_a3_odd = first2_odd[3];
      } else { 

	first_a0_even = first3_even[0];
	first_a0_odd = first3_odd[0];
      
	first_a1_even = first3_even[1];
	first_a1_odd = first3_odd[1];
	
	first_a2_even = first3_even[2];
	first_a2_odd = first3_odd[2];

	first_a3_even = first3_even[3];
	first_a3_odd = first3_odd[3];
      } 
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

  vector<float> first2_even;
  vector<float> first2_odd;

  vector<float> first3_even;
  vector<float> first3_odd;
};



#endif
