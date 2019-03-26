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

    inline void SetParameters(float Ttau_even, float Tmscale_even, float Tscaler_const_even,
			      float Tscaler_mult_even, float Tsigma0_even,
			      float Tsigma_mult_even, float Tmu_even, float Tsat_cross_even,
			      float Tcross_even, float Tconst_d_even,
			      float Ttau_odd, float Tmscale_odd, float Tscaler_const_odd,
			      float Tscaler_mult_odd, float Tsigma0_odd,
			      float Tsigma_mult_odd, float Tmu_odd, float Tsat_cross_odd,
			      float Tcross_odd, float Tconst_d_odd){
      tau_even = Ttau_even;
      mscale_even = Tmscale_even;
      scaler_const_even = Tscaler_const_even;
      scaler_mult_even = Tscaler_mult_even;
      sigma0_even = Tsigma0_even;
      sigma_mult_even = Tsigma_mult_even;
      mu_even = Tmu_even;
      crossopt_even = Tcross_even;
      sat_crossopt_even = Tsat_cross_even;
      const_d_even = Tconst_d_even;

      tau_odd = Ttau_odd;
      mscale_odd = Tmscale_odd;
      scaler_const_odd = Tscaler_const_odd;
      scaler_mult_odd = Tscaler_mult_odd;
      sigma0_odd = Tsigma0_odd;
      sigma_mult_odd = Tsigma_mult_odd;
      mu_odd = Tmu_odd;
      crossopt_odd = Tcross_odd;
      sat_crossopt_odd = Tsat_cross_odd;
      const_d_odd = Tconst_d_odd;
    }

  inline void GetParams(float &rscd_tau_even,
			float &rscd_tau_odd,
			float &rscd_mscale_even,
			float &rscd_mscale_odd,
			float &rscd_scaler_const_even,
			float &rscd_scaler_const_odd,
			float &rscd_scaler_mult_even,
			float &rscd_scaler_mult_odd,
			float &rscd_sigma0_even,
			float &rscd_sigma0_odd,
			float &rscd_sigma_mult_even,
			float &rscd_sigma_mult_odd,
			float &rscd_mu_even,
			float &rscd_mu_odd,
			float &rscd_crossopt_even,
			float &rscd_crossopt_odd,
			float &rscd_sat_crossopt_even,
			float &rscd_sat_crossopt_odd,
			float &rscd_const_d_even,
			float &rscd_const_d_odd) {


    rscd_tau_even = tau_even ;
    rscd_tau_odd  = tau_odd; 
    rscd_mscale_even= mscale_even ;
    rscd_mscale_odd=  mscale_odd;
    rscd_scaler_const_even= scaler_const_even;
    rscd_scaler_const_odd= scaler_const_odd;
    rscd_scaler_mult_even= scaler_mult_even;
    rscd_scaler_mult_odd= scaler_mult_odd;
    rscd_sigma0_even= sigma0_even;
    rscd_sigma0_odd= sigma0_odd;
    rscd_sigma_mult_even= sigma_mult_even;
    rscd_sigma_mult_odd= sigma_mult_odd;
    rscd_mu_even = mu_even;
    rscd_mu_odd = mu_odd;
    rscd_crossopt_even  = crossopt_even;
    rscd_crossopt_odd =     crossopt_odd;
    rscd_sat_crossopt_even  = sat_crossopt_even;
    rscd_sat_crossopt_odd =   sat_crossopt_odd;
    rscd_const_d_even =  const_d_even;
    rscd_const_d_odd =  const_d_odd;
  }
//_______________________________________________________________________
     private:

  float tau_even,mscale_even,scaler_const_even,scaler_mult_even,
    sigma0_even,mu_even,const_d_even,sigma_mult_even,
    sat_crossopt_even,crossopt_even;

  float tau_odd,mscale_odd,scaler_const_odd,scaler_mult_odd,
    sigma0_odd,mu_odd,const_d_odd, sigma_mult_odd,
    sat_crossopt_odd,crossopt_odd;


};



#endif
