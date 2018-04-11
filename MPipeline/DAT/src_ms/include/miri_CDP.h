// include files

#ifndef CDP_H
#define CDP_H

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

class  miri_CDP {
 public:
  miri_CDP();            // default constructor
  ~miri_CDP();


  void InitializeLastFrameCoeff();
//_______________________________________________________________________
  // functions defined in ms_miri_dark.cpp
 
  inline void SetMasterList(string list) {MasterList = list;}
  inline void SetMasterListDir(string list) {MasterListDir = list;}
  inline string GetMasterList( )const  {return MasterList;}
  inline string GetMasterListDir( )const  {return MasterListDir;}

//_______________________________________________________________________
  // Bad Pixels
  inline void SetBadPixelName(string list) {BadPixelName= list;}
  inline string GetBadPixelName()const {return BadPixelName;}

  inline void SetBadPixel( int value) {badpix.push_back(value);}
  inline int GetBadPixel(long i ) const{return badpix[i];}
  inline void CleanBadPixel() { badpix.erase(badpix.begin(), badpix.end());}

  inline void SetNumBadPixels( long value) {num_badpixels = value;}
  inline long GetNumBadPixels( )const {return num_badpixels;}

//_______________________________________________________________________
// Reset
  inline void SetResetUseNPlanes(int i) {reset_use_nplanes = i;}
  inline int GetResetUseNPlanes() {return reset_use_nplanes;}

  inline void SetResetMaxInt(int i) {max_reset_use_int = i;}
  inline int GetResetMaxInt() {return max_reset_use_int;}

  inline void SetResetMaxFrames(int i) {max_reset_frames = i;}
  inline int GetResetMaxFrames() {return max_reset_frames;}

  inline string GetResetUseName() const { return ResetUse;}

  inline void PrintResetUse() const {cout << "Reset file"  " " << ResetUse << endl;}

  inline void SetResetUseUserSet(string file) {ResetUse = file;}

  inline void SetResetFastName(string list) {ResetFastName=list;}
  inline void SetResetUseFast() {
    ResetUse = ResetFastName;
    cout << "ResetUse" << ResetUse <<endl;
  }

  inline void SetResetSlowName(string list) {ResetSlowName=list;}
  inline void SetResetUseSlow() {ResetUse = ResetSlowName;}

  inline void SetResetBrightSkyName(string list) {ResetBrightSkyName=list;}
  inline void SetResetUseBrightSky() {ResetUse = ResetBrightSkyName;}
  inline string GetResetBrightSkyName() {return ResetBrightSkyName;}

  inline void SetResetMask1065Name(string list) {ResetMask1065Name=list;}
  inline void SetResetUseMask1065() {ResetUse = ResetMask1065Name;}
  inline string GetResetMask1065Name() {return ResetMask1065Name;}

  inline void SetResetMask1140Name(string list) {ResetMask1140Name=list;}
  inline void SetResetUseMask1140() {ResetUse = ResetMask1140Name;}
  inline string GetResetMask1140Name() {return ResetMask1140Name;}

  inline void SetResetMask1550Name(string list) {ResetMask1550Name=list;}
  inline void SetResetUseMask1550() {ResetUse = ResetMask1550Name;}
  inline string GetResetMask1550Name() {return ResetMask1550Name;}

  inline void SetResetMaskLYOTName(string list) {ResetMaskLYOTName=list;}
  inline void SetResetUseMaskLYOT() { ResetUse = ResetMaskLYOTName;}
  inline string GetResetMaskLYOTName() {return ResetMaskLYOTName;}

  inline void SetResetMaskSub256Name(string list) {ResetMaskSub256Name=list;}
  inline void SetResetUseMaskSub256() {ResetUse = ResetMaskSub256Name;}
  inline string GetResetMaskSub256Name() {return ResetMaskSub256Name;}

  inline void SetResetMaskSub128Name(string list) {ResetMaskSub128Name=list;}
  inline void SetResetUseMaskSub128() {ResetUse = ResetMaskSub128Name;}
  inline string GetResetMaskSub128Name() {return ResetMaskSub128Name;}

  inline void SetResetMaskSub64Name(string list) {ResetMaskSub64Name=list;}
  inline void SetResetUseMaskSub64() {ResetUse = ResetMaskSub64Name;}
  inline string GetResetMaskSub64Name() {return ResetMaskSub64Name;}

  inline void SetResetSPrismName(string list) {ResetSPrismName=list;}
  inline void SetResetUseSPrism() {ResetUse = ResetSPrismName;}
  inline string GetResetSPrismName() {return ResetSPrismName;}

//_______________________________________________________________________
  // RSCD
  inline void SetRSCDName(string list) {RSCDName= list;}
  inline string GetRSCDName()const {return RSCDName;}

//_______________________________________________________________________
// Pixel Saturation
  inline string GetPixelSatName()const {return PixelSatName;}
  inline void SetPixelSatName(string list) {PixelSatName= list;}

  inline void SetPixelSat(float value) {pixel_saturation.push_back(value);}
  inline void SetPixelSatDQ(int value) {pixel_saturation_dq.push_back(value);}

  inline float GetPixelSat(long i) {return pixel_saturation[i];}
  inline int GetPixelSatDQ(long i) {return pixel_saturation_dq[i];}

  inline void CleanPixelSat() { pixel_saturation.erase(pixel_saturation.begin(),pixel_saturation.end());}
  inline void CleanPixelSatDQ() { pixel_saturation_dq.erase(pixel_saturation_dq.begin(),pixel_saturation_dq.end());}

  inline void SetPixeSatDetSet(string value) {pixel_saturation_DetSet=value;}
//_______________________________________________________________________

//_______________________________________________________________________
// Linearity Correction
  inline void SetLinCorName(string lin) {LinCorName=lin ;}
  inline string GetLinCorName()const {return LinCorName;}

  inline void SetLinOrder(int i) {lin_order = i;}
  inline int GetLinOrder() {return lin_order;}


//_______________________________________________________________________
// Dark
  inline void SetDarkUseNPlanes(int i) {dark_use_nplanes = i;}
  inline int GetDarkUseNPlanes() {return dark_use_nplanes;}

  inline string GetDarkUseName( ) const { return DarkUse;}

  inline void PrintDarkUse() const {cout << "Dark to use" << DarkUse << endl;}

  inline void SetDarkUseUserSet(string file) {DarkUse = file;}

  inline void SetDarkFastName(string file) {DarkFastName=file;}
  inline void SetDarkUseFast() {DarkUse = DarkFastName;}

  inline void SetDarkSlowName(string file) {DarkSlowName=file;}
  inline void SetDarkUseSlow() {DarkUse = DarkSlowName;}

  inline void SetDarkBrightSkyName(string file) {DarkBrightSkyName=file;}
  inline string GetDarkBrightSkyName() {return DarkBrightSkyName;}
  inline void SetDarkUseBrightSky() {DarkUse = DarkBrightSkyName;}

  inline void SetDarkMask1065Name(string file) {DarkMask1065Name=file;}
  inline string GetDarkMask1065Name() {return DarkMask1065Name;}
  inline void SetDarkUseMask1065() {DarkUse = DarkMask1065Name;}

  inline void SetDarkMask1140Name(string file) {DarkMask1140Name=file;}
  inline void SetDarkUseMask1140() {DarkUse = DarkMask1140Name;}
  inline string GetDarkMask1140Name() {return DarkMask1140Name;}

  inline void SetDarkMask1550Name(string file) {DarkMask1550Name=file;}
  inline void SetDarkUseMask1550() {DarkUse = DarkMask1550Name;}
  inline string GetDarkMask1550Name() {return DarkMask1550Name;}

  inline void SetDarkMaskLYOTName(string file) {DarkMaskLYOTName=file;}
  inline void SetDarkUseMaskLYOT() {DarkUse = DarkMaskLYOTName;}
  inline string GetDarkMaskLYOTName() {return DarkMaskLYOTName;}

  inline void SetDarkMaskSub256Name(string file) {DarkMaskSub256Name=file;}
  inline void SetDarkUseMaskSub256() {DarkUse = DarkMaskSub256Name;}
  inline string GetDarkMaskSub256Name() {return DarkMaskSub256Name;}

  inline void SetDarkMaskSub128Name(string file) {DarkMaskSub128Name=file;}
  inline void SetDarkUseMaskSub128() {DarkUse = DarkMaskSub128Name;}
  inline string GetDarkMaskSub128Name() {return DarkMaskSub128Name;}

  inline void SetDarkMaskSub64Name(string file) {DarkMaskSub64Name=file;}
  inline void SetDarkUseMaskSub64() {DarkUse = DarkMaskSub64Name;}
  inline string GetDarkMaskSub64Name() {return DarkMaskSub64Name;}

  inline void SetDarkSPrismName(string file) {DarkSPrismName=file;}
  inline void SetDarkUseSPrism() { DarkUse = DarkSPrismName;}
  inline string GetDarkSPrismName() {return DarkSPrismName;}

//_______________________________________________________________________


  // Last Frame Correction
  inline void SetLastFrameName(string file) {LastFrameName=file;}
  inline string GetLastFrameName( ) const { return LastFrameName;}

  
  inline void SetLastFrameParameters(int channel, float A_even , float B_even, 
				     float A_odd, float B_odd){
    LastFrameCoeff_Even_A[channel]  = A_even;
    LastFrameCoeff_Even_B[channel]  = B_even;
    LastFrameCoeff_Odd_A[channel]  = A_odd;
    LastFrameCoeff_Odd_B[channel]  = B_odd;
    
  }


  inline float GetLastFrame_Aeven (int ic) {return LastFrameCoeff_Even_A[ic];}
  inline float GetLastFrame_Aodd (int ic)  {return LastFrameCoeff_Odd_A[ic];}
  inline float GetLastFrame_Beven (int ic) {return LastFrameCoeff_Even_B[ic];}
  inline float GetLastFrame_Bodd (int ic)  {return LastFrameCoeff_Odd_B[ic];}


  // 


//_______________________________________________________________________
     private:

  // Linearity Correction for each pixel defined, size of correction = order+1 of fit 

  string MasterList; 
  string MasterListDir;

  vector <int> badpix;
  vector <float> pixel_saturation;
  vector <int> pixel_saturation_dq;
  string pixel_saturation_DetSet;

  string BadPixelName;              // filename of bad pixel 
  long num_badpixels; 

  string PixelSatName;              // filename of pixel saturation mask 

  string RSCDName;

  string LastFrameName;

  vector<float> LastFrameCoeff_Even_A;
  vector<float> LastFrameCoeff_Even_B;
  vector<float> LastFrameCoeff_Odd_A;
  vector<float> LastFrameCoeff_Odd_B;

  string LinCorName;    // linearity correction filename 
  int lin_order;

  string DarkUse;
  int dark_use_nplanes;

  string  DarkFastName; 
  string  DarkSlowName; 
  string DarkBrightSkyName; 
  string DarkMask1065Name; 
  string DarkMask1140Name; 
  string DarkMask1550Name; 
  string DarkMaskLYOTName; 
  string DarkMaskSub256Name; 
  string DarkMaskSub128Name; 
  string DarkMaskSub64Name; 
  string DarkSPrismName; 

  string  ResetUse;
  int max_reset_use_int;
  int reset_use_nplanes;
  int max_reset_frames;
  string ResetFastName;
  string ResetSlowName; 
  string ResetBrightSkyName; 
  string ResetMask1065Name; 
  string ResetMask1140Name;
  string ResetMask1550Name;
  string ResetMaskLYOTName;
  string ResetMaskSub256Name;
  string ResetMaskSub128Name;
  string ResetSPrismName; 
  string ResetMaskSub64Name;

};



#endif
