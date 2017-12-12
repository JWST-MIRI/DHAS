// include file fpr miri_pixel class

#ifndef PIXEL_H
#define PIXEL_H

#include <iostream>
#include <iomanip>
#include <strstream>
#include <fstream>
#include <vector>
#include <cmath>
#include <string>
// namespaces

using namespace std;


// All the information needed for reducing a particular pixel is contained
// in this structure as well as the reduced data.

class  miri_pixel {
 public:
  miri_pixel();            // default constructor
  ~miri_pixel();

  //_______________________________________________________________________
  // functions defined in ms_miri_pixel.cpp
  void BadPixelReject();
  void Get2ptDiff(vector<double>&, vector<double>&, int&);
  void PrintData();

  void CalculateSlopeFaster();
  void CalculateSlope(int const);
  void CalculateSlope();
  void CalculatePixelFlag( int );

  //_______________________________________________________________________
  // inline functions 

  inline void SetPixel(int X, int Y){
    if(X <= 3){
      X = 0;
    }else if( X >= 4 && X <=1027){
      X = X -3;
    }else
      X = 1025;
    pix_x= X;
    pix_y =Y;}


  inline void SetPixelSubArray(int X, int Y){
    pix_x= X;
    pix_y =Y;}

  inline void SetReadNumFirstSat(int IREAD) {
    read_num_first_saturated = IREAD;
  }
  inline int GetX() {return pix_x;}
  inline int GetY() {return pix_y;}
  inline void ReserveRampData(int nramps){
    raw_data.reserve(nramps);
    raw_data_unc.reserve(nramps);
    id_data.reserve(nramps);}


  inline void SetRampData(int DATA,short ID){
    raw_data.push_back(float(DATA));
    raw_data_unc.push_back(1.0);
    id_data.push_back(ID); }

  inline void SetID(int i, short ID) { id_data[i] = ID;}

  inline void SetSignal(float S){signal=S;}
  inline void SetSignalUnc(float S){signal_unc=S;}
  inline void Set2ptStdev(float STDEV){twopt_std_dev = STDEV;}

  inline float GetRawData(const int i) {return raw_data[i];}

  inline float GetMax2ptDiff() const { return max_2pt_diff;}
  inline int GetIMax2ptDiff() const { return read_num_max_2pt_diff;}
  inline float GetSignal()const { return signal;}
  inline float GetSignalUnc()const { return signal_unc;}
  inline long GetQualityFlag()const { return quality_flag;}
  inline long GetIndex_org()const { return index_org;}
  inline float GetZeroPt() const { return zero_pt;}
  inline int GetNumGood() const { return num_good_reads;}
  inline int GetReadNumFirstSat()const {return read_num_first_saturated;}

  inline void Convert2DNperSec(float frame_per_sec){signal=signal*frame_per_sec;}
  inline void Convert2ElectronperSec(float gain,float frametime){
    signal=signal*gain/frametime;}

//_______________________________________________________l________________
  //inline float GetSlope(){return slope; } // this function need to be more
  // complex = get slope from segments
  //inline float GetSlopeUnc(){return slope_unc; }

//_______________________________________________________________________
  inline void SubtractDark(const int framenum, const float dark){
    raw_data[framenum] = raw_data[framenum] - dark;
  }

//_______________________________________________________________________
  inline void SubtractRefImage(const int framenum, const float refvalue){
    raw_data[framenum] = raw_data[framenum] - refvalue;
}

  inline void SubtractRefImage(const int framenum, const float refvalue, const int debug_flag){
    if(debug_flag == 1)  cout << " data and refdata " << raw_data[framenum] << " " << refvalue << endl;
    raw_data[framenum] = raw_data[framenum] - refvalue;
    if(debug_flag ==1 ) cout << " final number " << raw_data[framenum] << endl;
}

//_______________________________________________________________________
  inline void SubtractRefCorrection(const int framenum, const float refcorrection){
    raw_data[framenum] = raw_data[framenum] - refcorrection;
}

//_______________________________________________________________________
inline void SubtractRefSlope(const int framenum, const float slope,const float yintercept){
  // y = mx + b
  float correction = slope * pix_x + yintercept; 
  raw_data[framenum] = raw_data[framenum] - correction;
}


 inline void SubtractRefSlope(const int framenum, const float slope,
				  const float yintercept, const int debug){
  // y = mx + b
  float correction = slope * pix_x + yintercept; 
  raw_data[framenum] = raw_data[framenum] - correction;
  if(debug == 1) 
    cout << pix_x << " " << slope << " " << yintercept << " " << correction << endl;
}
//_______________________________________________________________________
     private:

  // one value per pixel:
  int pix_x;              // x pixel value (1 to subset_size) 
  int pix_y;              // y pixel value (1 to subset_size)
  long index_org;           // index of pixel in the 1024 X 1024 reference frame

  long  quality_flag;     // quality of data- values found in miri_flags.h

  // reduced data values
  float signal;           // in DN/(real sec)
  float signal_unc;       // uncertainty of signal in DN/(real sec)
  float zero_pt; 
  int num_good_reads;     // number of good reads

  float max_2pt_diff;          // largest 2pt different in ramp
  int read_num_max_2pt_diff;   // read # of maximum 2pt difference
  float twopt_std_dev;
  
  int read_num_first_saturated; 

  
  // vectors for each pixel
  vector<float>  raw_data;       // raw data ramp versus read number
  vector<float>  raw_data_unc;   // raw data ramp uncertainty versus read number
  vector<short>  id_data;        // identification for each read: flags 

  // will need to make follow variables vectors when determining segments.

  //vector<float> ramp_zero_pt;     // zero point of ramp (y-intercept)
  //vector<float> ramp_zero_pt_unc;     // zero point of ramp (y-intercept)
  //vector <float> slope;           // slopes of the individual segements
  //vector <float> slope_unc;           // slopes of the individual segements

  //float ramp_zero_pt;         // zero point of ramp (y-intercept)
  //float ramp_zero_pt_unc;     // zero point of ramp (y-intercept)
  //float slope;                // slopes of the individual segements
  //float slope_unc;            // slopes of the individual segements

  // _______________________________________________________________________
  // values to add later (cosmic ray detection and linearity correction)


  //vector<float> ramp_begin;       // begin of slope segement (in read # - 1st read = 1)
  //vector<int> ramp_end;           // end of slope segement (in read #)

  //vector<float> lin_cor_vals;   // vector of linearity corrections 
  //vector<float> lin_cor_unc;    // vector of linearity corrections uncertainities
  //vector<float> lin_cor_dn;     // vector of linearity corrections dn values (x)


  //float readnoise;        // in electrons/read
  //int num_good_segments;  // number of good segments in ramp
  //int read_num_first_sat; // read # of first high saturuated read


  //int lc_cor_type;        // type of correction (0 = multiplicative, 1 = additive)
  //int n_lin_cor_vals;     // number of DN values in linearity correction
  //float lin_cor_mm_dn[2]; // min/max valid dn for the linearity correction

  // diagnositic data values
  // float empir_unc;             // empirical uncertainty in DN/read (change later)


};

#endif

