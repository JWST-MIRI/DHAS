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
#include "miri_constants.h"
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

  void Get2ptDiff(const int, vector<float>&, vector<float>&, int&);
  void Get2ptDiffIndex(const int start_fit, 
		       vector<float> &diff, 
		       vector<float> &true_diff, 
		       vector<long> &index, 
		       int &ngood);

  void Get2ptDiffIndexP(const int start_fit, 
		       vector<float> &diff, 
		       vector<float> &true_diff, 
		       vector<long> &index, 
		       vector<long> &pindex, 
		       int &ngood);

  void SetRejectAfterEvent(const int nreject_noise, const int nreject_cr);
  void RejectAfterEvent(const int iframe, const int FLAG, const int nreject_noise, const int nreject_cr);

  void PrintData();
  void PrintPixel();
  void PrintResults();


  void FindSegments();
  void CoAddData();
  void CalculateSlopeNoErrors(int,int,int);
  void CalculateSlope(int, float,int,int,int);
  float CalculateCorrelatedUncertainty(int iseg, float S, float SX, float gain, float Slope, float y_int, float Delta);
  void FinalSlope(float,int,int,int,int,int,ofstream&,int,int );
  void CalculatePixelFlag( );


  void GetLast2Frames(const int isecond, const int ithird,
		      float &lastframe_second, float  &lastframe_third);

  void CorrectNonLinearityOld(const int write_corrected_data,
					  const int apply_lin_offset,
					  const int istart_fit,
					  int linflag,
					  int lin_order,vector<float> lin);
  void CorrectNonLinearity(const int,
			   const int,
			   int linflag,
			   int lin_order,
			   vector<float> lin);

  float poly_ave(float a, float b, vector<float> coeff);

  void CorrectNonLinearityold(const int,
			   const int, 
			   const int, 
			   int linflag,
			    int lin_order,vector<float> lin);


  void SubtractDarkCorrection(const int,short,vector<float>);
  void SubtractResetCorrection(const int,short,vector<float>);
  void ApplyLastFrameCorrection(const int, float, int, 
				vector<float>, vector<float>,
				vector<float>, vector<float>);


  void ApplyMULTRSCD(const int write_output_rscd_correction,
		     int n_reads_start_fit,
		     int nframes,
		     int video_offset,
		     float lastframeDN,
		     float lastframeDN_sat,
		     float sat,
		     float mult_alpha,
		     float mult_min_tol,
		     vector<float> mult_a,
		     vector<float> mult_b,
		     vector<float> mult_c,
		     vector<float> mult_d,
		     float rscd_alpha,
		     float rscd_min_tol,
		     float rscd_a0,
		     float rscd_a1,
		     float rscd_a2,
		     float rscd_a3,
		     float first_a0,
		     float first_a1,
		     float first_a2,
		     float first_a3);


  vector<int> GetFlags(int &, int &);
  void SetPixel(int X, int Y, const int ColStart,int IREAD,int BADPIXEL);

  void InitializeLinCorData();
  void InitializeDarkCorData();
  void InitializeResetCorData();
  void InitializeRSCDCorData();
  void InitializeRefCorData();

  //_______________________________________________________________________
  // inline functions 



  inline void SetRefPixel(int X, int Y){
    channel = 5;
    pix_x = X; 
    pix_y = Y;}


  inline void SetReadNumFirstSat(int IREAD) {
    read_num_first_saturated = IREAD;
  }

  inline int GetProcessFlag() {return process_flag;}
  inline int GetBadPixelFlag() { return bad_pixel_flag;}
  inline int GetIsRef(){ return is_ref;}
  inline int GetIsEven(){ return is_even;}
  inline int GetX() {return pix_x;}
  inline int GetY() {return pix_y;}

  inline short GetChannel() {return channel;}


  inline void ReserveRampData(int nramps){
    raw_data.reserve(nramps);
    id_data.reserve(nramps);
    raw_data_var.reserve(nramps);
      }

  inline void SetRampData(int DATA,int ID, float gain,float read_noise_dn2, float video_offset){
    float dn = float(DATA) + video_offset;
    
    raw_data.push_back(dn);
    //    raw_data.push_back(float(DATA));
    id_data.push_back(ID);

    //float var = float(DATA) + read_noise_dn2;
    float var = dn + read_noise_dn2;
    raw_data_var.push_back(var);
  }


   inline void SetRefCorrected(){
     for (unsigned int i = 0 ; i < raw_data.size() ; i++){
       ref_cor_data[i] = raw_data[i]; // initialize 
     }
   }
  
   inline void PrintRamp(){
     for (unsigned int i = 0 ; i < raw_data.size() ; i++){
       cout << " Pixel data: " << i << " " << raw_data[i]<< endl; 
     }
   }

  inline void SetID(int i, int ID) { id_data[i] = ID;}

  inline void SetSignal(float S){signal=S;}
  inline void SetSignalUnc(float S){signal_unc=S;}
  inline void SetStdDev2ptDiff(float STDEV){std_dev_2pt_diff = STDEV;}
  inline void SetSlope2ptDiff(float S){slope_2pt_diff = S;}
  inline void SetLastFrameData( ) {
    int iframe = raw_data.size() -1 ;
    lastframe_cor_data = raw_data[iframe]; // initialize to raw data value
  }

  inline float GetFrameData(const int i) {return raw_data[i];}
  inline int GetIDData(const int i) {return id_data[i];}
  inline float GetLinData(const int i) {return lin_cor_data[i];}
  inline float GetDarkData(const int i) {return dark_cor_data[i];}
  inline float GetRSCDData(const int i) {return rscd_cor_data[i];}
  inline float GetResetData(const int i) {return reset_cor_data[i];}
  inline float GetLastFrameData() {return lastframe_cor_data;}
  inline float GetRefData(const int i) {return ref_cor_data[i];}

  inline float GetMax2ptDiff() const { return max_2pt_diff;}
  inline float GetSlope2ptDiff() const { return slope_2pt_diff;}
  inline int GetIMax2ptDiff() const { return read_num_max_2pt_diff;}
  inline float GetStdDev2ptDiff() const { return std_dev_2pt_diff;}
  inline float GetSignal()const { return signal;}
  inline float GetSignalUnc()const { return signal_unc;}
  inline long GetQualityFlag()const { return quality_flag;}
  inline long GetIndex_org()const { return index_org;}
  inline float GetZeroPt() const { return zero_pt;}
  inline float GetRMS() const { return rms;}
  inline float GetNumGood() const { return num_good_reads;}
  inline float GetReadNumFirstSat()const {return read_num_first_saturated;}

  inline int GetNumGoodSegments() const {return num_good_segments;}
  inline int GetNumSegments() const {return num_segments;}

  inline int GetBeginSeg(const int i) {return seg_begin[i];}
  inline int GetEndSeg(const int i) {return seg_end[i];}
  inline float GetSlopeSeg(const int i) {return seg_slope[i];}
  inline float GetSlopeSegUnc(const int i) {return seg_slope_unc[i];}
  inline float GetYIntSeg(const int i) {return seg_y_intercept[i];}
  inline float GetDnJumpSeg(const int i) {return seg_dn_jump[i];}
  inline int GetFlagSeg(const int i) {return seg_flag[i];}

    

  inline void Convert2DNperSec(float sec_per_frame){
    if(signal != NO_SLOPE_FOUND){
      //cout << signal << " " << sec_per_frame <<endl;
      signal=signal/sec_per_frame;
      signal_unc=signal_unc/sec_per_frame;
    }
  }
  inline void Convert2ElectronperSec(float gain){
    signal=signal*gain;
    signal_unc=signal_unc*gain;}


//_______________________________________________________l________________

  inline void SubtractValue(const int framenum, const float value){
    raw_data[framenum] = raw_data[framenum] - value;
  }

//_______________________________________________________________________

//_______________________________________________________________________
     private:

  // one value per pixel:

  int pix_y;                // y pixel value (1 to subset_size)
  int pix_x;                // x pixel value (1 to subset_size) 
  long index_org;           // index of pixel in the 1024 X 1024 reference frame
  short channel;

  long  quality_flag;       // quality of data- values found in miri_flags.h
  int noisy_pixel_flag;
  int bad_pixel_flag;
  int process_flag;
  int is_ref;
  int is_even;
  

  // reduced data values
  float signal;                  // in DN/frames - converted to DN/sec
  float signal_unc;              // uncertainty of signal 
  float zero_pt;                 // y-intercept 
  int num_good_reads;          // number of good reads
  int read_num_first_saturated; // read number of first saturated read 
  float rms;

  float max_2pt_diff;            // largest 2pt different in ramp
  int read_num_max_2pt_diff;     // read # of maximum 2pt difference
  float std_dev_2pt_diff;
  float slope_2pt_diff;
  int num_good_segments;  // number of good segments in ramp
  int num_segments;  // number of segments found  in ramp
  //_______________________________________________________________________  
  // vectors for each pixel
  vector<float>  raw_data;       // raw data ramp for each frame
  vector<int>  id_data;        // identification for each read: flags 
  vector<float>  raw_data_var;   // variance of read (sigma^2, where sigma is uncertainty)

  // will need to make follow variables vectors when determining segments.

  vector <float> seg_slope;      // slopes of the individual segements
  vector <float> seg_slope_unc;  // uncertainties in slopes of the individual segements
  vector<int> seg_begin;         // begin of slope segement (in read # - 1st read = 1)
  vector<int> seg_end;           // end of slope segement (in read #)
  vector<float> seg_y_intercept;     // y_intercept
  vector<float> seg_zero_pt;
  vector<float> seg_rms;
  vector<int> seg_flag;
  vector <int> seg_num_good_reads; 
  vector <float> seg_dn_jump;


  vector<float>  lin_cor_data;     // raw_data corrected for linearity correction.
                        // stored as seperate varible for writing out and rscd correction

  vector<float>  dark_cor_data;     // raw_data corrected for dark correction.
                        // stored as seperate varible only with writing out


  vector<float>  rscd_cor_data;     // raw_data corrected for rscd correction.
                        // stored as seperate varible only with writing out

  vector<float>  reset_cor_data;     // raw_data corrected for reset anomaly correction.
                        // stored as seperate varible only with writing out


  vector<float>  ref_cor_data;     // raw_data corrected for linearity correction.
                        // stored as seperate varible only with writing out


  float lastframe_cor_data; // each pixel has one value corrected - the value in the last frame
  // _______________________________________________________________________




};

#endif

