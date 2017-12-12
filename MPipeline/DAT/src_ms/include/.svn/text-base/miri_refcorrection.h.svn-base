// include files

#ifndef REFCORRECT_H
#define REFCORRECT_H

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

class  miri_refcorrection {
 public:
  miri_refcorrection();            // default constructor
  ~miri_refcorrection();

//_______________________________________________________________________
  // functions defined in ms_miri_refcorrection.cpp
 
  void PrintSlope(int num)const;
  float GetCorrection(int option, short channel, int sign, int x, int y); 
  float GetTempCorrection(short channel);

//_______________________________________________________________________

  inline void SetRelativeTempCorrection(float amp1, float amp2, float amp3, float amp4){

  correction_amp[0]  = a[0] + TempGain*a[4] - amp1 ;     
  correction_amp[1]  = a[1] + TempGain*a[4] - amp2 ;     
  correction_amp[2]  = a[2] + TempGain*a[4] - amp3 ;     
  correction_amp[3]  = a[3] + TempGain*a[4] - amp4 ;     

  }

  inline float GetRelativeTempCorrection(int amp){
    return correction_amp[amp-1];
  }
  
  inline void SetEvenCorrection( int amp,float C){
    Even_Correction[amp-1]  = C ;}

  inline void SetOddCorrection( int amp, float C){
    Odd_Correction[amp-1] = C  ;}

  inline float GetOddCorrection(int amp )const {return Odd_Correction[amp];}
  inline float GetEvenCorrection(int amp )const {return Even_Correction[amp];}

  inline void SetDarkLeft( int amp,int irow,float D){
    Dark_Left[amp][irow]  = D ;}

  inline void SetDarkRight( int amp,int irow,float D){
    Dark_Right[amp][irow]  = D ;}

  inline float GetDarkLeft(int amp,int irow )const {return Dark_Left[amp][irow];}
  inline float GetDarkRight(int amp,int irow )const {return Dark_Right[amp][irow];}


  inline void SetLeft( int amp,float C){
    MeanLeft[amp-1]  = C ;}

  inline void SetRight( int amp,float C){
    MeanRight[amp-1]  = C ;}


  inline void SetTempTerms(float A1,float A2,float A3,float A4,float A5){
    a.push_back(A1);
    a.push_back(A2);
    a.push_back(A3);
    a.push_back(A4);
    a.push_back(A5);
  }
    

  inline void SetTempGain(float TEMPGAIN){ TempGain = TEMPGAIN;}

  inline float GetLeft(int amp )const {return MeanLeft[amp];}
  inline float GetRight(int amp )const {return MeanRight[amp];}

  inline vector<float> GetTempTerms( )const {return a;}


  inline void Initialize(){ // 
    for (int j = 0 ; j < 4; j++){
      Odd_Correction[j] = 0.0;
      Even_Correction[j] = 0.0;

      MeanLeft[j] = 0.0;
      MeanRight[j] = 0.0;

      for (int i =0; i< 1024;i++){
	
	slope[j][i] = 0.0;
	yintercept[j][i] = 0.0;
      }
    }
  }

  inline void SetMovingMean(int amp, int k, float DATA){MovingMean[amp-1][k] = DATA;}
  inline void SetSlope(int amp, int k, float DATA){slope[amp-1][k] = DATA;}
  inline void SetYintercept(int amp, int k, float DATA){yintercept[amp-1][k] = DATA;}

  inline float GetMovingMean(int amp, int k)const { return MovingMean[amp-1][k];}
  inline float GetSlope(int amp, int k)const { return slope[amp-1][k];}
  inline float GetYintercept(int amp, int k)const { return yintercept[amp-1][k];}

//_______________________________________________________________________

//_______________________________________________________________________
 
     private:

  // one value per output amplifier:

  float Odd_Correction[4];
  float Even_Correction[4];

  float MeanRight[4];
  float MeanLeft[4];

  float TempGain;
  float correction_amp[4];
  float Dark_Left[4][1024];
  float Dark_Right[4][1024];
 
  
  vector<float> a;
  float MovingMean[4][1024];


  float slope[4][1024];             // 1024 values for each amplifier
  float yintercept[4][1024];        // 1024 values for each amplifier



};


#endif


