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

  void SetSATParameters(const int nframes,
			float Tsat_zp_even, float Tsat_slope_even, 
			float Tsat_2_even,float Tsat_mzp_even, 
			float Tsat_rowterm_even, float Tsat_scale_even,
			float Tsat_zp_odd, float Tsat_slope_odd, 
			float Tsat_2_odd,float Tsat_mzp_odd, 
			float Tsat_rowterm_odd, float Tsat_scale_odd);

  void SetParameters(const int nfrrames,
		     float Ttau_even, float Tascale_even, float Tpow_even,
		      float Tillum_zp_even, float Tillum_slope_even,
		      float Tillum2_even, float Tparam3_even, float Tcpt_even,
		      float Ttau_odd, float Tascale_odd, float Tpow_odd, 
		      float Tillum_zp_odd, float Tillum_slope_odd, 
		      float Tillum2_odd, float Tparam3_odd, float Tcpt_odd);



  inline void GetParams(float &rscd_tau_even,
			float &rscd_tau_odd,
			float &rscd_pow_even,
			float &rscd_pow_odd,
			float &rscd_param3_even,
			float &rscd_param3_odd,
			float &rscd_crossopt_even,
			float &rscd_crossopt_odd,
			float &rscd_b1_even,
			float &rscd_b1_odd,
			float &rscd_sat_slope_even,
			float &rscd_sat_slope_odd,
			float &rscd_sat_scale_even,
			float &rscd_sat_scale_odd,
			float &rscd_sat_mzp_even,
			float &rscd_sat_mzp_odd) {



    rscd_tau_even = tau_even ;
    rscd_tau_odd  = tau_odd; 
    rscd_pow_even= pow_even ;
    rscd_pow_odd=  pow_odd;
    rscd_param3_even= param3_even;
    rscd_param3_odd = param3_odd;
    rscd_crossopt_even  = crossopt_even;
    rscd_crossopt_odd =     crossopt_odd;
    rscd_b1_even =  b1_even;
    rscd_b1_odd =  b1_odd;
    rscd_sat_slope_even = sat_final_slope_even;
    rscd_sat_slope_odd = sat_final_slope_odd;
    rscd_sat_scale_even =  sat_scale_even;
    rscd_sat_scale_odd =  sat_scale_odd;
    rscd_sat_mzp_even = sat_mzp_even;
    rscd_sat_mzp_odd = sat_mzp_odd;
  }


//_______________________________________________________________________

//_______________________________________________________________________
     private:

  float tau_even,pow_even,ascale_even,illum_zp_even,illum_slope_even,illum2_even,
    param3_even,crossopt_even;

  float tau_odd,pow_odd,ascale_odd,illum_zp_odd,illum_slope_odd,illum2_odd, 
    param3_odd,crossopt_odd;

  float sat_zp_odd,sat_slope_odd,sat_2_odd,sat_mzp_odd,sat_rowterm_odd,sat_scale_odd;
  float sat_zp_even,sat_slope_even,sat_2_even,sat_mzp_even,sat_rowterm_even,sat_scale_even;
  float b1_even,b1_odd;
  float sat_final_slope_even,sat_final_slope_odd;

};



#endif
