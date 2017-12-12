//mrs_ReducedData.h - Header file which defines BCD pixel Structure

#ifndef ReducedData_H
#define ReducedData_H

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <ctype.h>
#include <vector>
using namespace std;

class ReducedData {

public:
  ReducedData();            //default constructor
  ~ReducedData();           //deconstructor
  
  void PrintPixelInfo();

  //set routines
  
  inline void SetSlice(int NO){slice= NO;}

  inline void SetFileNo(int FILENO){FileNo= FILENO;}
  inline void SetIntNo(int INTNO){IntNo= INTNO;}
  inline void SetPixelNo(long NO){PixelNo= NO;}
  inline void SetPixelX(int X){x= X;}
  inline void SetPixelY(int Y){y= Y;}
  inline void InitializeNOverlap(){noverlap = 0;}


  inline void SetWaveCorners(double W[4]){
    wavecorner[0] = W[0];
    wavecorner[1] = W[1];
    wavecorner[2] = W[2];
    wavecorner[3] = W[3];
  }

  inline void SetAlphaCorners(double L[4]){
    alphacorner[0] = L[0];
    alphacorner[1] = L[1];
    alphacorner[2] = L[2];
    alphacorner[3] = L[3];
  }


  inline void SetYcenter(float Y){ycenter = Y;}
  
  inline void SetFlux(float FLUX){flux = FLUX;}
  inline void SetUncertainty(float UNCER){uncertainty = UNCER;}
  inline void SetBadPixelFlag(int BAD){BadPixelFlag = BAD;}
  inline void SetInputFlag(long FLAG){InputFlag = FLAG;}

  inline void SetCubeTies(long CINDEX, double OVERLAP){
    CubeIndex.push_back(CINDEX);
    Overlap.push_back(OVERLAP);
    noverlap++;
  }

  //_______________________________________________________________________


  inline long GetCubeIndex(long i){return CubeIndex[i];}
  inline double GetOverlap(long i){return Overlap[i];}
  inline int GetNOverlap() const {return noverlap;}
  inline int GetFileNo()const {return FileNo;}
  inline int GetIntNo()const {return IntNo;}
  inline long GetPixelNo()const {return PixelNo;}
  inline int GetPixelX()const {return x;}
  inline int GetPixelY()const {return y;}

  inline int GetSlice()const {return slice;}

  inline float GetFlux() const {return flux;}
  inline float GetUncertainty() const {return uncertainty;}
  inline int GetBadPixelFlag() const {return BadPixelFlag;}
  inline long GetInputFlag() const {return InputFlag;}

  inline float GetYcenter() const {return ycenter;}

  inline void GetWaveCorners(double  WCORNER[5] )
  {
    WCORNER[0] = wavecorner[0];
    WCORNER[1] = wavecorner[1];
    WCORNER[2] = wavecorner[2];
    WCORNER[3] = wavecorner[3];
    WCORNER[4] = wavecorner[0];
  }



  inline void GetAlphaCorners(double   LCORNER[5] )
  {
    LCORNER[0] = alphacorner[0];
    LCORNER[1] = alphacorner[1];
    LCORNER[2] = alphacorner[2];
    LCORNER[3] = alphacorner[3];
    LCORNER[4] = alphacorner[0];
  }




 private:
  /***************************************************************************/
  // the following values are set in me_read_image.cpp (first time image read in)

  int FileNo;
  int waveid;                 // which wavelength range the data is from 1: short, 2: medium, 3: long
  long PixelNo; 
  int x;
  int y;
  int IntNo;
  int slice;


  float flux;               // output from DHAS
  float uncertainty;        // output from DHas
  long InputFlag;           // output from DHAS
  int BadPixelFlag;        


  double wavecorner[4]; // 4 corners 
  double alphacorner[4]; // 4 corners 
  double ycenter;

  /***************************************************************************/
  // used if writing out mapping overlap file

  vector <long> CubeIndex;
  vector <double> Overlap;
  int noverlap;

};

#endif 






